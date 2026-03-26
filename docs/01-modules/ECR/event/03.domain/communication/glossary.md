# Glossary: Communication
## ECR Domain | 2026-03-25

This glossary defines the ubiquitous language for the Communication bounded context. This context owns bulk and individual email dispatch, template versioning, per-recipient delivery tracking, retry management, and failure escalation. SMS is acknowledged as a future concern but is explicitly out of scope for ECR v1 — no SMS internals are modeled.

---

| Term | Definition | Notes / Disambiguations |
|------|-----------|------------------------|
| **CommunicationJob** | The aggregate root representing a single dispatch task — either a bulk send (many recipients) or a targeted send (one or a few recipients). A CommunicationJob groups all DeliveryRecords produced by one send action and governs the lifecycle of that dispatch. | A CommunicationJob is not the same as a single email. One job may produce hundreds of DeliveryRecords. A job is created when a triggering domain event (e.g., `SessionDigestDispatched`, `CandidateConfirmed`) is received, or when a TA Coordinator initiates a manual bulk send. |
| **EmailTemplate** | A versioned template with named variable slots (e.g., `{{candidate_name}}`, `{{kit_link_url}}`). Templates define the subject line and body. An EmailTemplate is authored and published by a template manager. | Each published version of a template is immutable. A new version must be created for any changes. Published versions cannot be edited or deleted — only deprecated. This preserves the historical integrity of communications sent. |
| **TemplateVersion** | A specific, immutable rendition of an EmailTemplate. Identified by a monotonically incrementing version number per template. Only one version may be in `ACTIVE` status per template at a time; all others are `DEPRECATED`. | TemplateVersion is not a separate aggregate — it is an entity owned by EmailTemplate. The EmailTemplate aggregate manages which version is currently active. |
| **DeliveryRecord** | A per-recipient tracking entity owned by a CommunicationJob. Records the email address targeted, the current delivery status, retry count, and timestamps. The single source of truth for whether an individual email was successfully delivered. | DeliveryRecord is owned by the CommunicationJob aggregate. It is NOT a global delivery ledger — it is scoped to the job that created it. Status is updated via webhook callbacks from the Email Delivery Service. |
| **DeliveryStatus** | The current state of a DeliveryRecord: `QUEUED`, `SENT`, `DELIVERED`, `BOUNCED`, `FAILED`, `RETRYING`. | `SENT` means the email was accepted by the delivery service. `DELIVERED` means a delivery confirmation webhook was received. These are distinct. A `BOUNCED` status indicates the recipient address is invalid or undeliverable — this is a permanent failure. A `FAILED` status after all retries exhausted means the send was not confirmed. Neither `BOUNCED` nor `FAILED` are ever silently ignored. |
| **RecipientList** | A value object on a CommunicationJob. Contains the list of (candidateRef, emailAddress) pairs to be contacted by the job. | RecipientList is built at job creation time and is immutable. If the intended recipient list changes after job creation (e.g., a candidate's email is corrected), a new CommunicationJob must be created rather than mutating the existing one. |
| **RetryPolicy** | A value object specifying the retry behavior for failed deliveries: `maxAttempts`, `backoffSeconds` (initial interval for exponential backoff), `lastAttemptedAt`. | The RetryPolicy is defined at the CommunicationJob level. By default: 3 attempts, starting with 60s backoff, doubling each time. Exhausted retries result in `DeliveryStatus = FAILED` and trigger a `DeliveryFailureEscalated` event for TA Coordinator notification. |
| **BulkEmailDispatch** | A CommunicationJob targeting more than one recipient, rate-limited to 500 messages per minute to respect Email Delivery Service constraints (NFR-07). | BulkEmailDispatch is not a separate entity — it is a behavior of CommunicationJob when `recipient_count > 1`. The rate limit is enforced by the Communication BC's sending engine, which queues outbound messages and releases them at the permitted rate. |
| **TemplateVariables** | A key-value map injected into an EmailTemplate at render time to produce the final email content for a specific recipient. | TemplateVariables are scoped to a single DeliveryRecord. Two recipients of the same CommunicationJob receive the same template but different variable values (e.g., different candidate names, different KitLink URLs). |
| **DeliveryWebhook** | An inbound callback from the Email Delivery Service that updates a DeliveryRecord's status. The Communication BC is the recipient of these webhooks. | DeliveryWebhook events are the only mechanism by which `SENT` transitions to `DELIVERED` or `BOUNCED`. Without a webhook, the status remains `SENT` indefinitely. A webhook timeout policy should be defined (e.g., if no webhook received within 48h, mark status as `UNCONFIRMED`). |
| **FailureEscalation** | The process by which a permanently failed DeliveryRecord (all retries exhausted, or BOUNCED) is surfaced to the TA Coordinator via an in-app alert and a `DeliveryFailureEscalated` event. | Failure escalation is the mechanism that prevents silent delivery failures. Every failed delivery must either succeed via retry or be escalated. There is no path to silent discard. |
| **IdempotencyKey** | A unique key generated per CommunicationJob that prevents duplicate sends if the same triggering domain event is received more than once (e.g., due to message broker at-least-once delivery). | The IdempotencyKey is derived from the triggering event ID + job type. If a job with the same IdempotencyKey already exists, the new dispatch command is ignored and the existing job is returned. |

---

## Business Rules in This Context

| BR-ID | Rule | Implementation |
|-------|------|---------------|
| NFR-07 | Bulk email rate-limited to 500 messages/minute | CommunicationJob sending engine enforces rate cap. Excess messages queued and released when capacity allows. |
| (Implied) | No silent delivery failures | Every DeliveryRecord with status FAILED or BOUNCED must trigger FailureEscalation. |
| (Implied) | CommunicationJob idempotency | Triggering the same job twice (same IdempotencyKey) produces one job, not two. |
| (Implied) | EmailTemplate version immutability | Published template versions are append-only. No edits or deletes on published versions. |

---

## Lifecycle States

### CommunicationJob States
```
CREATED → SENDING → COMPLETED
                  → PARTIAL_FAILURE (some recipients failed after all retries)
                  → FAILED (all recipients failed)
```
- **CREATED**: Job initialized; DeliveryRecords created, none yet sent.
- **SENDING**: At least one email has been dispatched; job in flight.
- **COMPLETED**: All DeliveryRecords reached terminal status (DELIVERED or BOUNCED).
- **PARTIAL_FAILURE**: At least one DeliveryRecord is FAILED or BOUNCED after exhaustion; escalation triggered.
- **FAILED**: All DeliveryRecords are FAILED or BOUNCED.

### DeliveryRecord States
```
QUEUED → SENT → DELIVERED (terminal — success)
              → BOUNCED   (terminal — permanent failure)
       → RETRYING → SENT
                  → FAILED (terminal — retries exhausted)
```

### EmailTemplate Version States
```
DRAFT → ACTIVE (only 1 per template at a time)
      → DEPRECATED
```

---

## Integration Points

| Upstream Event | Origin BC | Action in This Context |
|---------------|-----------|------------------------|
| `CandidateConfirmed` | Candidate Registration | Create CommunicationJob for confirmation email |
| `WaitlistActivated` | Candidate Registration | Create CommunicationJob for waitlist promotion email |
| `RegistrationCancelled` | Candidate Registration | Create CommunicationJob for cancellation notification |
| `SlotAllocated` | Schedule & Capacity | Create CommunicationJob for slot assignment email |
| `SessionDigestDispatched` | Interview Management | Create CommunicationJob for interviewer kit email (one per HardAssigned interviewer) |
| `EventPublished` | Event Management | Optionally create CommunicationJob for announcement email (configurable per event) |

| Downstream Event | Consuming BC | Purpose |
|-----------------|--------------|---------|
| `EmailFailed` | (TA Coordinator alert) | Notify TA Coordinator of unrecoverable delivery failure |
| `CommunicationJobCreated` | Analytics & Audit | Audit log of bulk operations |
| `EmailDelivered` | Analytics & Audit | Delivery metrics |

| External Integration | Direction | Pattern |
|---------------------|-----------|---------|
| Email Delivery Service | Outbound (async fire-and-forget) + Inbound (delivery webhook) | Async + callback |
