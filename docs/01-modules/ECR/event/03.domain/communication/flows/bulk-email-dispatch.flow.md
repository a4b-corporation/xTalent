# Use Case: Bulk Email Dispatch
## Bounded Context: Communication
## ECR Module | 2026-03-25

**Actor:** System (triggered by domain events from other BCs) or TA Coordinator (manual bulk send)
**Trigger:**
- Automated: A domain event is received from another BC (e.g., `CandidateConfirmed`, `SessionDigestDispatched`, `SlotAllocated`)
- Manual: TA Coordinator initiates a bulk announcement from the operations dashboard

**Preconditions:**
- For automated jobs: a valid triggering domain event with a non-duplicate idempotency key has been received
- For manual jobs: TA Coordinator has the required RBAC permission (`ecr.communication.send_bulk`)
- An ACTIVE EmailTemplate version exists for the job_type
- Recipient list is non-empty
- Event is in a state that permits the communication type (e.g., REGISTRATION_OPEN or IN_PROGRESS for most candidate emails)

**Postconditions:**
- A `CommunicationJob` exists with one `DeliveryRecord` per recipient
- All emails have been submitted to the Email Delivery Service (DeliveryStatus = SENT or terminal state)
- All delivery outcomes are tracked via webhook callbacks
- Any FAILED or BOUNCED DeliveryRecord has triggered a FailureEscalation alert to the TA Coordinator
- A `CommunicationJobCreated` event has been emitted and consumed by Analytics & Audit

**Business Rules:**
- Rate limit: maximum 500 emails per minute (NFR-07)
- No silent delivery failures: every FAILED or BOUNCED DeliveryRecord triggers escalation
- Job idempotency: same idempotency_key (trigger_event_id + job_type) cannot produce two jobs
- Template version immutability: the template version used is captured at job creation and cannot change mid-job

---

## Happy Path: Automated Trigger (e.g., CandidateConfirmed)

1. Communication BC receives `CandidateConfirmed` domain event from Candidate Registration BC via pub/sub.
2. System checks idempotency: compute `idempotency_key = "CandidateConfirmed:" + source_event_id`. If a CommunicationJob with this key already exists, discard and stop (duplicate message protection).
3. System resolves the active EmailTemplate for job_type = `CANDIDATE_CONFIRMATION` and captures `template_version_number`.
4. System builds the RecipientList:
   - One entry: (candidate_registration_id, email_address from event payload)
   - Template variables: `{{candidate_name}}`, `{{event_name}}`, `{{sbd_number}}`, `{{event_date}}`
5. System creates `CommunicationJob`:
   - `job_status = CREATED`
   - `trigger_event_type = "CandidateConfirmed"`
   - `trigger_event_id` from the source event
   - `recipient_count = 1`
   - Creates one `DeliveryRecord` with `delivery_status = QUEUED`
6. System emits `CommunicationJobCreated`. Analytics & Audit records this for bulk operation tracking.
7. System renders the email: injects template variables into the ACTIVE template version body and subject.
8. System submits the rendered email to the Email Delivery Service:
   - Receives `external_message_id` in response
   - Updates `DeliveryRecord.delivery_status = SENT`
   - Updates `DeliveryRecord.last_attempted_at = now()`
   - Emits `EmailDispatched`
9. System updates `CommunicationJob.job_status = SENDING`.
10. Email Delivery Service sends the email to the candidate's inbox.
11. Email Delivery Service fires a delivery webhook callback:
    - System matches webhook to `DeliveryRecord` via `external_message_id`
    - Updates `DeliveryRecord.delivery_status = DELIVERED`
    - Updates `DeliveryRecord.delivered_at = webhook_timestamp`
    - Emits `EmailDelivered`
12. System updates `CommunicationJob.job_status = COMPLETED`.

---

## Happy Path: Bulk Announcement (Manual, > 1 Recipient)

1. TA Coordinator opens the Communications dashboard and selects a recipient cohort (e.g., all Confirmed candidates for Track A).
2. TA Coordinator selects an EmailTemplate and reviews the current ACTIVE version.
3. TA Coordinator adds any additional template variable overrides for this send.
4. TA Coordinator clicks "Send Bulk Email."
5. System validates:
   - Recipient list resolved (count > 0).
   - Active template version exists.
   - TA Coordinator has `ecr.communication.send_bulk` permission.
6. System creates `CommunicationJob`:
   - `job_type = BULK_ANNOUNCEMENT`
   - `created_by = ta_coordinator_user_id`
   - `recipient_count = N` (where N may be > 500)
   - Creates N `DeliveryRecord` entries, all `delivery_status = QUEUED`
7. System emits `CommunicationJobCreated`.
8. System starts the sending engine with rate limiting:
   - Dispatches up to 500 emails per minute
   - For each batch of 500 (or less for the final batch):
     - Renders email per recipient (unique template variables)
     - Submits to Email Delivery Service
     - Updates DeliveryRecord to SENT; records `external_message_id`
     - Emits `EmailDispatched` per email
   - If total recipients > 500: waits 60 seconds before next batch
9. As delivery webhooks arrive, system updates DeliveryRecords to DELIVERED.
10. When all DeliveryRecords reach terminal status: `CommunicationJob.job_status = COMPLETED`.
11. TA Coordinator sees job completion summary: "Email sent to [N] recipients. [M] delivered, [K] failed."

---

## Alternate Flows

### A1: Partial Delivery Failure (Some Recipients Fail)

After step 8, some DeliveryRecords reach FAILED or BOUNCED status:

For RETRYING path:
- Initial send attempt fails (non-permanent error, e.g., temporary service unavailable)
- System updates `DeliveryRecord.delivery_status = RETRYING`
- System waits `initial_backoff_seconds` (exponential: 60s, 120s, 240s)
- System retries up to `max_attempts` times
- On eventual success: `DELIVERED`
- On exhaustion: proceed to FAILED path

For FAILED path:
- All retries exhausted without delivery confirmation
- System updates `DeliveryRecord.delivery_status = FAILED`
- System sets `DeliveryRecord.escalated = true`
- System emits `EmailFailed` event
- TA Coordinator receives in-app alert: "Delivery failed for [N] recipients in job [job_id]. Review required."
- `CommunicationJob.job_status = PARTIAL_FAILURE` if at least one record succeeded, `FAILED` if all failed

For BOUNCED path:
- Email Delivery Service webhook returns a permanent bounce signal
- System updates `DeliveryRecord.delivery_status = BOUNCED`
- System sets `DeliveryRecord.escalated = true`
- System emits `EmailFailed` (with `delivery_status = BOUNCED`)
- TA Coordinator alerted; may update the candidate's email address and trigger a new job

### A2: Re-trigger After Failure (TA Coordinator Action)

TA Coordinator reviews failed DeliveryRecords and corrects recipient data (e.g., wrong email address):
- TA Coordinator creates a new CommunicationJob manually, targeting only the failed recipients with corrected addresses
- New job has a fresh `idempotency_key` (manual job uses a TA-generated reference, not the original event ID)
- New job processes normally

### A3: Template Version Change Mid-Dispatch

A template manager publishes a new TemplateVersion while a bulk job is in flight:
- The in-flight CommunicationJob continues using the `template_version_number` captured at job creation
- Newly created jobs use the new ACTIVE version
- The version used is immutable per job — no mid-job template switch

### A4: Idempotent Re-delivery (Duplicate Domain Event)

The pub/sub broker delivers `CandidateConfirmed` twice (at-least-once semantics):
- First delivery: system creates CommunicationJob with `idempotency_key = "CandidateConfirmed:" + event_id`
- Second delivery: system checks idempotency key, finds existing job, discards the duplicate
- Only one CommunicationJob is created; only one email is sent
- No error raised; duplicate handling is silent and expected

---

## Error Flows

### E1: No Active Template for Job Type

At step 3 (automated) or step 6 (manual):
- No published ACTIVE TemplateVersion exists for the required job_type
- System raises an internal alert to the template manager and TA Coordinator
- CommunicationJob is NOT created
- The triggering domain event is logged as unprocessed (not silently dropped — goes to a dead-letter queue for manual resolution)
- TA Coordinator must publish a template before retrying

### E2: Email Delivery Service Unavailable

At step 8 (submission):
- Email Delivery Service returns a 5xx error
- System treats this as a retryable failure
- DeliveryRecord set to RETRYING
- RetryPolicy governs retry schedule
- If service is down for extended period and max retries exhausted: FAILED + escalation (not silent)

### E3: Webhook Not Received Within Timeout Window

After step 8, if no delivery webhook arrives within 48 hours:
- System marks DeliveryRecord as FAILED with `failure_reason = "webhook_timeout"`
- Escalation triggered
- TA Coordinator decides whether to re-send

### E4: Recipient List Empty

At step 5 (manual) or step 4 (automated):
- Resolved recipient list has zero entries (e.g., no Confirmed candidates for the selected cohort)
- No CommunicationJob is created
- System notifies TA Coordinator: "No eligible recipients found for this communication."
- For automated jobs: event is logged as processed with zero-recipient result (no job created, no error)

---

## Domain Events Emitted

- `CommunicationJobCreated` — when a new job is created and queued
- `EmailDispatched` — when an individual email is submitted to the delivery service
- `EmailDelivered` — when a delivery webhook confirms success
- `EmailFailed` — when a DeliveryRecord reaches terminal failure (FAILED or BOUNCED)
- `TemplatePublished` — (separate flow) when a new template version is activated

---

## Sequence Diagram

```
Trigger (BC Event    Communication BC    Rate Limiter    Email Delivery Svc    Delivery Webhook
or TA Coordinator)        │                   │                 │                    │
        │                 │                   │                 │                    │
        │── Event/Command ►│                   │                 │                    │
        │                 │── Check Idempotency                  │                    │
        │                 │── Resolve Template                   │                    │
        │                 │── Build RecipientList                │                    │
        │                 │── Create CommunicationJob            │                    │
        │                 │── Emit JobCreated ──────────────────►│ (Audit BC)         │
        │                 │── Start Sending ──►│                 │                    │
        │                 │                   │── Rate check    │                    │
        │                 │                   │── Submit Email ──►│                    │
        │                 │                   │◄── MessageID ───│                    │
        │                 │── UpdateRecord(SENT)                 │                    │
        │                 │── Emit EmailDispatched               │                    │
        │                 │   (repeat per batch, ≤500/min)       │                    │
        │                 │                   │                 │── Deliver to inbox  │
        │                 │                   │                 │── Webhook ──────────►│
        │                 │◄── Webhook callback ─────────────────────────────────────│
        │                 │── UpdateRecord(DELIVERED)            │                    │
        │                 │── Emit EmailDelivered                │                    │
        │                 │── UpdateJob(COMPLETED)               │                    │
        │                 │                   │                 │                    │
        │   (failure path)│                   │                 │                    │
        │                 │── Retry(backoff) ──►│                │                    │
        │                 │── [max retries exhausted]            │                    │
        │                 │── UpdateRecord(FAILED)               │                    │
        │                 │── Escalated=true                     │                    │
        │                 │── Emit EmailFailed                   │                    │
        │◄── Alert ────────│                   │                 │                    │
```

---

## Notes

- **Rate limiting protects external dependencies.** The 500/min cap (NFR-07) is enforced by the Communication BC's sending engine, not by the Email Delivery Service. Overloading the external service risks account suspension and cascading delivery failures. The rate limiter ensures ECR is a responsible caller.
- **No silent failures is a design principle, not an optional feature.** Every FAILED or BOUNCED DeliveryRecord must surface to the TA Coordinator. The risk of undiscovered delivery failures (e.g., a candidate who never received their confirmation email) is a compliance and user experience issue, not merely a technical concern.
- **Idempotency protects against at-least-once message delivery.** The pub/sub backbone used by ECR delivers messages at least once. Without the idempotency key check, a message delivered twice would produce two emails to the same candidate — a user experience failure. The key check is the guard.
- **The job is the unit of retries, not the entire campaign.** Each DeliveryRecord retries independently. A single failed recipient does not pause the rest of the job. Partial failures are expected at scale; the PARTIAL_FAILURE job status communicates this without blocking the successful recipients.
- **SMS is deferred.** SMS delivery is acknowledged as a future capability. No SMS-related entities, enums, or flows are defined in this version of the domain model. When SMS is introduced, a new channel type will be added to the Communication BC without modifying the existing email model.
