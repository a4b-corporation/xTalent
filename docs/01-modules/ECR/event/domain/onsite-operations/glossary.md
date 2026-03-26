# Glossary: Onsite Operations
## ECR Domain | 2026-03-25

This glossary defines the ubiquitous language for the Onsite Operations bounded context. This context owns physical check-in, kiosk session management, offline-first data integrity, and sync conflict resolution.

---

| Term | Definition | Notes / Disambiguations |
|------|-----------|------------------------|
| **CheckInRecord** | The single source of truth for a candidate's physical presence at the event. Contains check-in method, timestamp, sync status, and the kiosk or operator who captured it. The aggregate root of this context. | A CheckInRecord is distinct from a CandidateEventRegistration (owned by Candidate Registration BC). CheckInRecord records onsite presence; CandidateEventRegistration records event participation. One does not replace the other. |
| **Provisional** | The initial state of every CheckInRecord created offline (or synchronously at a kiosk before server acknowledgment). A Provisional record is real and visible in the interviewer queue, but has not been confirmed by the server. | Provisional is not "unconfirmed" in the sense of "uncertain." It is a state meaning "captured locally; awaiting server sync." A Provisional record CAN be displayed in the interviewer queue (OQ-D2 resolution). Interviewers see a visual indicator. |
| **Synced** | The state of a CheckInRecord after the server has confirmed receipt and validated the record. Transitions from Provisional to Synced on receipt of sync acknowledgment. | Once Synced, a CheckInRecord cannot regress to Provisional. It can transition to Conflict if a server-side validation discovers an inconsistency during sync. |
| **Conflict** | A sync state where the server detected an inconsistency in the CheckInRecord that cannot be auto-resolved. Routed to ManualReviewQueue. Examples: duplicate check-in, SBD not found in server records. | Conflict state does not mean the candidate is turned away. The kiosk operator is notified; a TA Coordinator resolves the conflict from the ManualReviewQueue. |
| **KioskSession** | The operational session of a single kiosk device at the event. Created when a kiosk authenticates and comes online. Holds the SBDBlock assignment for that session. | A KioskSession is not a user session. Multiple operators may use the same kiosk within one KioskSession. The session models the device, not the operator. |
| **SBDBlock** | A pre-allocated contiguous range of Số Báo Danh numbers assigned exclusively to one KioskSession. Kiosk uses numbers from its block sequentially without server coordination (OQ-D3 resolution). | Each KioskSession holds exactly one active SBDBlock. When the block nears exhaustion (< 10 remaining), the kiosk requests a new block at next sync. Unused numbers at session end are reclaimed. Gaps in the SBD sequence are expected and documented. |
| **OfflineSyncQueue** | An ordered queue within a KioskSession holding all CheckInRecords captured while the kiosk was offline (disconnected from server). Processed atomically per record on reconnection (BR-08). | OfflineSyncQueue is a local-first buffer. Records are never deleted from the queue until successfully acknowledged by the server. On sync failure for a record, it is routed to ManualReviewQueue — not silently dropped (BR-08). |
| **ManualReviewItem** | A CheckInRecord or sync event that could not be auto-resolved and requires TA Coordinator review. Created when sync conflict is detected or when a check-in triggers an exception (duplicate SBD, candidate not found, etc.). | ManualReviewItems are visible to TA Coordinators in real-time. Resolution options: Approve (record stands), Reject (record cancelled), Merge (duplicate resolution). |
| **QR Scan** | A check-in method where the candidate presents a QR code (printed on their confirmation email or shown on-screen) and the kiosk's scanner reads it. The fastest check-in method. | QR code encodes the registration_id or a secure token. The kiosk resolves it against the local candidate cache. If not in cache (new registration), falls back to SBD lookup. |
| **SBD Lookup** | A check-in method where the kiosk operator or candidate types in the Số Báo Danh. Used as fallback when QR scan fails or candidate does not have a QR code. | SBD lookup uses the pre-loaded local candidate cache (loaded from server at KioskSession start and updated on sync). Offline SBD lookup uses the cache only. |
| **Manual Entry** | A check-in method where the kiosk operator manually enters candidate name and/or student ID when neither QR code nor SBD are available (walk-ins, lost confirmation). Always creates a ManualReviewItem for TA Coordinator confirmation. | Manual Entry creates a Provisional CheckInRecord with a new SBD from the kiosk's SBDBlock. The TA Coordinator later resolves whether this is a new registration or a match to an existing one. |
| **CheckInConfirmed** | The domain event emitted when a CheckInRecord successfully transitions from Provisional to Synced. This is the signal consumed by Interview Management BC to add the candidate to the interviewer queue. | CheckInConfirmed is the authoritative "candidate is onsite" signal. Interview Management's 5-second queue update SLA (NFR-03) is measured from the receipt of this event — though a visual indicator appears on receipt of CheckInCaptured (Provisional path). |
| **CheckInCaptured** | The domain event emitted when a CheckInRecord is first created in Provisional state (at the point of capture on the kiosk). Consumed by Interview Management BC for provisional queue display (OQ-D2 resolution). | CheckInCaptured does NOT indicate server confirmation. It is an early signal for immediate queue display. Interview Management shows a "Provisional" badge for records sourced from CheckInCaptured until CheckInConfirmed arrives. |
| **Sync Run** | A scheduled or triggered execution that sends all records in a KioskSession's OfflineSyncQueue to the server. Sync runs are atomic per record — a failure on one record does not block processing of subsequent records. | Sync runs are triggered automatically when connectivity is restored or on a configurable timer. TA Coordinators can also manually trigger a sync from the operations dashboard. |

---

## Business Rules in This Context

| BR-ID | Rule | Implementation |
|-------|------|---------------|
| BR-01 | SBD generated at capture, not at email delivery | SBD assigned from kiosk SBDBlock at check-in capture, regardless of connectivity. |
| BR-08 | Offline data integrity — no silent data loss | Sync failures route to ManualReviewQueue. OfflineSyncQueue records not deleted until server-acknowledged. |

---

## Lifecycle States

### CheckInRecord States
```
Provisional → Synced
Provisional → Conflict → [ManualReview] → Synced | Rejected
```

### KioskSession States
```
Initialized → Active → Suspended → Syncing → Active
                                 → Closed
```

### SBDBlock States
```
Allocated → Partial → Near-Exhausted → Exhausted
```
- **Near-Exhausted**: < 10 SBD numbers remaining. Kiosk requests new block at next sync.
- **Exhausted**: All numbers used. Kiosk cannot capture new walk-in registrations until new block received.

---

## Integration Points

| Upstream Event | Origin BC | Action in This Context |
|---------------|-----------|------------------------|
| `CandidateConfirmed` | Candidate Registration | Update local candidate lookup cache on kiosk |
| `SlotAllocated` | Schedule & Capacity | Update slot reference in local cache for check-in validation |
| `EventStarted` | Event Management | Activate kiosk check-in mode; begin accepting check-ins |

| Downstream Event | Consuming BC | Purpose |
|-----------------|--------------|---------|
| `CheckInCaptured` | Interview Management | Provisional queue display (immediate, pre-sync) |
| `CheckInConfirmed` | Interview Management | Authoritative queue update (<5s SLA, NFR-03) |
| `CheckInConfirmed` | Assessment ACL | Eligibility signal for assessment dispatch (BR-07) |
| `CheckInConfirmed` | Analytics & Audit | Audit trail |
| `CheckInConflict` | Analytics & Audit | Conflict audit record |
