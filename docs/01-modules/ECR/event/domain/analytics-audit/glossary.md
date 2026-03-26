# Glossary: Analytics & Audit
## ECR Domain | 2026-03-25

This glossary defines the ubiquitous language for the Analytics & Audit bounded context. This context is a **terminal event consumer** — it subscribes to consequential domain events from all other ECR bounded contexts and produces an immutable audit log, real-time metrics snapshots, and configurable reports. It publishes no domain events of its own.

---

| Term | Definition | Notes / Disambiguations |
|------|-----------|------------------------|
| **AuditEntry** | The aggregate root of this context. An immutable, tamper-evident record of one consequential action that occurred in any ECR bounded context. Created from a domain event and never modified. | AuditEntry is append-only. Once written, the record cannot be updated or deleted by any application-layer operation. Tamper-evidence is achieved via hash chaining: each AuditEntry includes the hash of the previous entry in the sequence. Minimum retention: 3 years (NFR-10). |
| **TamperEvidence** | The property of an AuditEntry chain whereby any post-hoc modification to a stored entry is detectable. Implemented via hash chaining: `entry.chain_hash = SHA256(previous_entry.chain_hash + entry.content_hash)`. | TamperEvidence is a system property, not a domain concept visible to users. It is mentioned here because it constrains implementation: the audit store must be an append-only data structure, and the chain hash must be computed at write time, not retroactively. |
| **AuditAction** | The classification of what happened in the audited event. An enum covering all consequential operations across all ECR bounded contexts: score submissions, score edits, duplicate resolutions, bulk operations, structural event changes, capacity overrides, KitLink access, offline sync failures, and RBAC role changes. | AuditAction is a controlled vocabulary. Adding a new auditable operation requires explicitly adding it to this enum. This is intentional — the list of auditable actions is a governance decision, not an implementation accident. |
| **ActorRef** | An immutable value object embedded in an AuditEntry. Captures `userId`, `role` (at time of action), and `ipAddress` of the actor who triggered the event. | ActorRef is captured at event creation time and is never updated. If a user's role changes after an action, the AuditEntry still records the role they held at the time of the action. This is critical for forensic accuracy. |
| **AuditableEvent** | Any domain event from any ECR bounded context that must produce an AuditEntry. The set of auditable events is defined explicitly (see Integration Points below). | Not every domain event is auditable. Routine operational events (e.g., a kiosk heartbeat) are not audited. Only consequential events — those that affect candidate outcomes, data integrity, or system configuration — are in scope. |
| **EventMetricsSnapshot** | A point-in-time aggregate of metrics for a specific ECR event. Computed from AuditEntry projections and/or direct event subscriptions. Stored as a read model — it is not the source of truth; AuditEntry is. | EventMetricsSnapshot can be recomputed from the AuditEntry log at any time (eventual consistency). Real-time snapshots are updated on every relevant domain event receipt; hourly and daily snapshots are computed on schedule. |
| **MetricsDimension** | The categorization of what an EventMetricsSnapshot measures: `REGISTRATION` (candidate counts, waitlist depth), `CHECK_IN` (onsite attendance, no-show rate), `ASSESSMENT` (completion rate, pass rate), `INTERVIEW` (scores, recommendations, skip rate), `FUNNEL` (conversion rates across the full pipeline). | MetricsDimension is not a flat counter. A snapshot along the FUNNEL dimension captures multiple stages and their conversion rates as a structured object, not a single number. |
| **SnapshotInterval** | How frequently an EventMetricsSnapshot is computed and stored: `REAL_TIME` (on every domain event), `HOURLY` (scheduled), `DAILY` (scheduled end-of-day). | REAL_TIME snapshots are lightweight projections — they update in-memory counters on event receipt. HOURLY and DAILY snapshots persist computed summaries to the read store for dashboard queries. The distinction is a performance optimization, not a data model distinction. |
| **ReportDefinition** | A saved configuration specifying the dimensions, filters, groupings, and time range for a dynamic report. Created and managed by report managers. Executed on demand or on schedule. | ReportDefinition is an aggregate root within this context. It is not a generated report — it is the specification for generating one. The generated output is ephemeral (not stored as a domain object); only the definition is persisted. |
| **RetentionPolicy** | The rule governing how long AuditEntries and EventMetricsSnapshots are retained. Minimum 3 years for AuditEntries (NFR-10). MetricsSnapshots have a shorter retention (configurable, defaulting to 1 year for REAL_TIME, 3 years for DAILY). | RetentionPolicy is enforced at the infrastructure level (data store TTL or archival jobs), not at the domain model level. The domain model expresses the constraint; the infrastructure enforces it. The domain does not expose a delete operation on AuditEntry. |
| **ChainHash** | The tamper-evidence hash value stored on each AuditEntry. Computed as `SHA256(previous_entry.chain_hash + current_entry.content_hash)`. The chain starts with a genesis entry whose previous hash is a fixed sentinel value. | ChainHash is a technical implementation of TamperEvidence. Verification of the chain is an administrative operation (audit verification run) that reads all entries in sequence and recomputes hashes. A broken chain signals tampering or corruption. |
| **FunnelConversion** | A computed metric within the FUNNEL dimension expressing the percentage of candidates who progressed from one pipeline stage to the next (e.g., Registered → Confirmed → Checked In → Interviewed → Passed). | FunnelConversion is a derived value computed at snapshot time from raw event counts. It is not an entity or aggregate — it is an output of the metrics computation engine. |

---

## Business Rules in This Context

| BR-ID | Rule | Implementation |
|-------|------|---------------|
| NFR-10 | 3-year minimum retention for AuditEntries | Infrastructure-level retention policy. No application delete path. |
| (Implied) | AuditEntry is append-only and tamper-evident | No update or delete operations on AuditEntry. Hash chaining on write. |
| (Implied) | All consequential actions from all BCs produce an AuditEntry | Explicit subscription list (see Integration Points). Adding a new auditable action requires explicit list update. |
| BR-04 | Score changes (submission and all edits) produce AuditEntry | `InterviewScoreSubmitted`, `ScoreEditApproved`, `ScoreEditRejected` are all subscribed. |

---

## Lifecycle States

### AuditEntry States
```
WRITTEN (immutable, permanent)
```
No state machine. An AuditEntry has no lifecycle — it is created once and never transitions.

### EventMetricsSnapshot States
```
COMPUTING → CURRENT → ARCHIVED
```
- **COMPUTING**: Snapshot is being calculated (for HOURLY/DAILY; REAL_TIME skips this).
- **CURRENT**: Latest completed snapshot for this event + interval.
- **ARCHIVED**: Superseded by a newer snapshot of the same interval type.

### ReportDefinition States
```
DRAFT → PUBLISHED → DEPRECATED
```
- **DRAFT**: Being configured; not yet available for execution.
- **PUBLISHED**: Active and available for on-demand or scheduled execution.
- **DEPRECATED**: No longer actively maintained; historical reference only.

---

## Integration Points

### Subscribed Events (All Auditable)

| Domain Event | Origin BC | AuditAction Mapped |
|-------------|-----------|-------------------|
| `InterviewScoreSubmitted` | Interview Management | `SCORE_SUBMITTED` |
| `ScoreEditRequested` | Interview Management | `SCORE_EDIT_REQUESTED` |
| `ScoreEditApproved` | Interview Management | `SCORE_EDIT_APPROVED` |
| `ScoreEditRejected` | Interview Management | `SCORE_EDIT_REJECTED` |
| `DuplicateFlagRaised` | Candidate Registration | `DUPLICATE_FLAGGED` |
| `DuplicateResolved` | Candidate Registration | `DUPLICATE_RESOLVED` |
| `CandidateRegistered` | Candidate Registration | `CANDIDATE_REGISTERED` |
| `CandidateConfirmed` | Candidate Registration | `CANDIDATE_CONFIRMED` |
| `RegistrationCancelled` | Candidate Registration | `REGISTRATION_CANCELLED` |
| `CapacityOverridden` | Schedule & Capacity | `CAPACITY_OVERRIDDEN` |
| `CandidatesAllocatedToSlots` | Schedule & Capacity | `BULK_ALLOCATION_RUN` |
| `EventStarted` | Event Management | `EVENT_STARTED` |
| `EventClosed` | Event Management | `EVENT_CLOSED` |
| `EventCloned` | Event Management | `EVENT_CLONED` |
| `CheckInConfirmed` | Onsite Operations | `CHECKIN_CONFIRMED` |
| `CheckInConflict` | Onsite Operations | `CHECKIN_CONFLICT` |
| `ManualReviewResolved` | Onsite Operations | `MANUAL_REVIEW_RESOLVED` |
| `KitLinkExpired` | Interview Management | `KIT_LINK_EXPIRED` |
| `AssessmentCompleted` | Assessment (ACL) | `ASSESSMENT_COMPLETED` |
| `EmailFailed` | Communication | `DELIVERY_FAILED` |
| `CommunicationJobCreated` | Communication | `BULK_EMAIL_INITIATED` |

### Published Events
None. Analytics & Audit is a terminal consumer.

### External Integration
- Infrastructure: append-only data store with hash-chain support (e.g., immutable object storage or ledger DB)
- Upstream (Conformist): xTalent RBAC — report viewer and audit admin role validation
