# Use Case: Audit Trail — Consequential Event Capture and Chain Integrity
## Bounded Context: Analytics & Audit
## ECR Module | 2026-03-25

**Actor:** System (automated event subscription) for capture; TA Coordinator or Audit Admin for query/verification
**Trigger:**
- Any subscribed consequential domain event arrives from any ECR bounded context
- Audit Admin initiates a chain integrity verification run
- TA Coordinator queries audit trail for a specific entity or actor

**Preconditions (Event Capture):**
- The domain event has a `domain_event_id` (UUID), `occurred_at` timestamp, and actor context
- The event type is in the subscribed auditable event list
- The audit store is available (append-only store)

**Postconditions (Event Capture):**
- An immutable `AuditEntry` exists with the full event payload, ActorRef, AuditAction classification, and chain hash
- The entry is linked to the previous entry in the chain via `previous_entry_id` and `chain_hash`
- The AuditEntry is retained for a minimum of 3 years (NFR-10)
- No AuditEntry is ever updated or deleted at the application layer

**Business Rules:**
- AuditEntry is append-only and tamper-evident (hash chaining)
- All consequential actions from all ECR BCs must produce an AuditEntry (explicit subscription list)
- Minimum 3-year retention (NFR-10)
- BR-04: Every score submission, score edit (approved or rejected), and ScoreEditRequest generates a mandatory AuditEntry

---

## Happy Path: Domain Event Capture (Score Submission Example)

1. Interview Management BC emits `InterviewScoreSubmitted` domain event via pub/sub backbone.
2. Analytics & Audit BC receives the event on its subscription channel.
3. System validates event structure:
   - `domain_event_id` is present and unique (not previously ingested)
   - `occurred_at` is a valid datetime
   - Event type is in the auditable event list (`SCORE_SUBMITTED`)
4. System retrieves the ID and `chain_hash` of the most recent AuditEntry (the tail of the chain).
5. System computes `content_hash = SHA256(domain_event_id + source_event_type + payload_json)`.
6. System computes `chain_hash = SHA256(previous_entry.chain_hash + content_hash)`.
7. System creates `AuditEntry`:
   - `audit_entry_id` = new UUID
   - `source_event_id` = domain_event_id from the event
   - `source_event_type` = "InterviewScoreSubmitted"
   - `source_bc` = INTERVIEW_MANAGEMENT
   - `audit_action` = SCORE_SUBMITTED
   - `actor_ref` = { userId, role, ipAddress } captured from event payload
   - `ecr_event_id` = from event payload
   - `subject_type` = "InterviewScore"
   - `subject_id` = score_id from event payload
   - `payload_json` = full JSON payload of the domain event (immutable capture)
   - `content_hash` = computed above
   - `chain_hash` = computed above
   - `previous_entry_id` = tail entry's audit_entry_id
   - `recorded_at` = server_now() (store write time)
8. System writes the AuditEntry to the append-only audit store atomically.
9. The entry is now immutable. No application path exists to update or delete it.
10. The new AuditEntry becomes the tail of the chain (used by the next entry's chain_hash computation).

---

## Happy Path: Score Edit Approved (Multi-Entry Audit)

When a ScoreEditRequest is approved by a TA Coordinator, two separate domain events are published by Interview Management BC:
- `ScoreEditApproved` (containing both `original_score_id` and `new_score_id`)

This produces TWO AuditEntries (one per event) but they are correlated by the `edit_request_id` in the payload:

1. `ScoreEditApproved` event arrives.
2. System creates AuditEntry with `audit_action = SCORE_EDIT_APPROVED`.
   - `subject_type = "InterviewScore"`
   - `subject_id = new_score_id` (the active score after amendment)
   - `payload_json` contains: `original_score_id`, `new_score_id`, `edit_request_id`, `reviewed_by`, `reviewed_at`, original and amended score values, `reason`
3. Chain hash is computed and appended as normal.

The original `InterviewScoreSubmitted` AuditEntry (from the initial submission) is not modified. Both entries coexist in the audit chain. The forensic trail shows: (1) score submitted, (2) edit requested, (3) edit approved. The full amendment history is preserved.

---

## Happy Path: Audit Chain Verification Run

An Audit Admin initiates a periodic chain integrity check:

1. Audit Admin triggers "Verify Audit Chain" from the admin portal (or a scheduled nightly job runs).
2. System reads all AuditEntries in `recorded_at` order from the genesis entry.
3. For each entry (starting from entry 2):
   a. Retrieve the previous entry's `chain_hash`.
   b. Recompute `content_hash = SHA256(entry.audit_entry_id + entry.source_event_type + entry.payload_json)`.
   c. Recompute expected `chain_hash = SHA256(previous_entry.chain_hash + content_hash)`.
   d. Compare recomputed hash to stored `chain_hash`.
   e. If they match: chain is intact at this entry. Continue.
   f. If they do not match: **chain break detected**. Record the entry ID of the first broken link.
4. On success: report "Chain integrity verified. [N] entries verified. No tampering detected."
5. On chain break:
   - Alert raised to security team and platform admin
   - Report specifies: first broken entry ID, `recorded_at` of that entry, and the discrepancy
   - Incident investigation triggered — this is a critical security event
   - Analytics & Audit BC does not attempt to "repair" the chain; this is an infrastructure forensic matter

---

## Happy Path: TA Coordinator Queries Audit Trail

1. TA Coordinator opens "Audit Trail" view in operations dashboard.
2. TA Coordinator filters by one or more of:
   - ECR event ID
   - Subject type + subject ID (e.g., a specific InterviewScore ID)
   - Actor (user ID or role)
   - AuditAction type
   - Date range
3. System queries the audit store read model (projected from AuditEntries for performance).
4. System returns a chronological list of AuditEntries matching the filters.
5. TA Coordinator sees: timestamp, actor (name + role), action classification, subject, and a summary extracted from `payload_json`.
6. TA Coordinator can click any entry to view the full `payload_json` (raw event data).

---

## Alternate Flows

### A1: Duplicate Domain Event Received (At-Least-Once Delivery)

At step 3 (idempotency check):
- `source_event_id` already exists in the audit store
- System recognizes the duplicate event (same `domain_event_id` already ingested)
- System discards the duplicate without creating a new AuditEntry
- No audit chain impact; no duplicate entries
- Duplicate handling is logged at system level for monitoring but is not an error condition

### A2: Score Edit Rejected (ScoreEditRejected Event)

For a rejected ScoreEditRequest:
- `ScoreEditRejected` event arrives
- System creates AuditEntry with `audit_action = SCORE_EDIT_REJECTED`
- `subject_type = "ScoreEditRequest"`, `subject_id = edit_request_id`
- `payload_json` captures: `edit_request_id`, `original_score_id`, `reviewed_by`, `reviewed_at`, `review_notes`
- The original `InterviewScore` AuditEntry (SCORE_SUBMITTED) is unmodified
- Chain is extended with one new entry (the rejection)
- No second score is created; the rejection audit trail is complete

### A3: Bulk Operation Audit (CandidatesAllocatedToSlots)

Bulk operations produce one AuditEntry per bulk event (not per individual record):
- `CandidatesAllocatedToSlots` arrives from Schedule & Capacity BC
- System creates one AuditEntry with `audit_action = BULK_ALLOCATION_RUN`
- `payload_json` captures: `allocation_run_id`, candidate count, slot count, strategy used
- Individual candidate-to-slot mappings are in the payload but do not each get their own AuditEntry
- This is a deliberate trade-off: individual-level audit would create performance and storage concerns at scale; the bulk event captures the operation at the appropriate granularity

### A4: Offline Sync Failure Audit

When `CheckInConflict` arrives from Onsite Operations:
- System creates AuditEntry with `audit_action = CHECKIN_CONFLICT`
- `payload_json` includes: kiosk_id, candidate_registration_id, conflict_type, sync_attempted_at
- If a subsequent `ManualReviewResolved` arrives: second AuditEntry with `audit_action = MANUAL_REVIEW_RESOLVED`
- Both entries are chained; the full offline incident trace is preserved

---

## Error Flows

### E1: Audit Store Unavailable

At step 8 (write):
- The append-only audit store is temporarily unavailable (e.g., network partition)
- System places the pending AuditEntry in a durable in-memory or local queue (not discarded)
- System retries write with exponential backoff
- If audit store remains unavailable beyond the retry window: critical alert raised
- The domain event is NOT acknowledged as processed until the AuditEntry is written
- **Under no circumstances is an auditable event discarded without producing an AuditEntry.**

### E2: Malformed Domain Event Payload

At step 3 (validation):
- Domain event payload is missing required fields (`domain_event_id`, `occurred_at`, or `actor` context)
- System creates an AuditEntry with a partial payload and `audit_action` mapped to a best-effort classification
- `failure_reason` is noted in the entry's metadata
- Alert raised to the owning BC's engineering team (data quality issue in the emitted event)
- The partial entry is chained normally — a malformed event is still an auditable occurrence

### E3: Chain Hash Computation Failure

If the SHA256 computation fails for any reason (extremely rare; hardware fault):
- The entry is not written
- Alert raised immediately (chain integrity must be guaranteed at write time)
- Entry is queued for retry after the fault is resolved
- The audit chain remains intact (no partial or corrupt entry is committed)

---

## Domain Events Emitted

None. Analytics & Audit is a terminal consumer. It does not publish domain events.

---

## Sequence Diagrams

### Audit Entry Capture

```
Source BC            Pub/Sub Bus        Analytics & Audit BC      Audit Store
(any BC)                 │                      │                      │
    │── Emit DomainEvent ►│                      │                      │
    │                    │── Deliver Event ───────►│                      │
    │                    │                      │── Check Idempotency   │
    │                    │                      │── Get Chain Tail ──────►│
    │                    │                      │◄── tail_hash ──────────│
    │                    │                      │── ComputeContentHash   │
    │                    │                      │── ComputeChainHash     │
    │                    │                      │── WriteAuditEntry ──────►│
    │                    │                      │◄── ACK ────────────────│
    │                    │◄── ACK Event ─────────│                      │
```

### Chain Verification

```
Audit Admin    Admin Portal    Analytics & Audit BC    Audit Store
    │               │                  │                    │
    │── Verify ──────►│                  │                    │
    │               │── StartVerify ────►│                    │
    │               │                  │── ReadAll(ordered) ─►│
    │               │                  │◄── Entries ──────────│
    │               │                  │── RecomputeHashes    │
    │               │                  │── Compare stored vs computed
    │               │                  │                    │
    │               │          [if match]                   │
    │               │◄── "Chain intact: N entries" ─────────│
    │◄── Report ─────│                  │                    │
    │               │          [if mismatch]                │
    │               │◄── "Chain break at entry X" ──────────│
    │               │── SecurityAlert ──────────────────────►│ (security team)
    │◄── Alert ──────│                  │                    │
```

---

## Notes

- **AuditEntry immutability is a business invariant, not a technical preference.** The audit log is the legal and compliance record of what happened in the system. Any mutation of a historical entry — even to "correct" an error — would undermine its value as evidence. The correct response to an incorrect AuditEntry is to write a new corrective entry, never to modify the original.
- **Hash chaining provides tamper-evidence, not encryption.** The SHA256 chain hash does not encrypt the audit data. It detects whether any stored entry has been modified after the fact, because any change to an entry's content would invalidate the chain from that point forward. Audit data confidentiality is a separate concern addressed by the storage layer (access controls, not cryptographic confidentiality).
- **The 3-year retention is a floor, not a ceiling.** NFR-10 specifies a minimum 3-year retention. Some regulatory contexts may require longer retention. The domain model does not enforce a maximum — retention upper bounds are a legal and storage cost decision made at the infrastructure layer.
- **The audit log is not a debug log.** Only consequential events are audited. High-frequency operational events (kiosk heartbeats, real-time queue position updates, read-only dashboard views) are not in scope. The audit log captures actions that affect candidate outcomes, data integrity, or system configuration.
- **Eventual consistency with durability.** The AuditEntry may be written milliseconds after the originating domain event occurred (pub/sub latency). The `occurred_at` field on the AuditEntry reflects when the original action happened; `recorded_at` reflects when the AuditEntry was written. For forensic purposes, both timestamps are preserved.
