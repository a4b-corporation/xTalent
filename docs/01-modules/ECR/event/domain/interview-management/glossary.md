# Glossary: Interview Management
## ECR Domain | 2026-03-25

This glossary defines the ubiquitous language for the Interview Management bounded context. This context owns interviewer assignment, session digest dispatch, candidate queue management, score submission and immutability enforcement, and score edit request workflow.

---

| Term | Definition | Notes / Disambiguations |
|------|-----------|------------------------|
| **InterviewSession** | A scheduled block of time during which one or more interviewers evaluate candidates assigned to a specific room and track. The aggregate root of the interview lifecycle. | An InterviewSession is not a 1-on-1 conversation. It is a scheduling unit: one session may process multiple candidates sequentially. The session is tied to a ScheduleSlot (owned by Schedule & Capacity BC) but is not the same thing as the slot. |
| **InterviewerAssignment** | The link between an xTalent User (in the Interviewer role) and an InterviewSession. One session may have multiple assignments forming a Panel. | InterviewerAssignment is a `HardAssignment` or `SoftAssignment` (see below). An unaccepted SoftAssignment does not count toward the minimum panel requirement. |
| **HardAssignment** | An assignment mode where the interviewer is definitively assigned to the session by a TA Coordinator. The interviewer cannot decline. Affects Session Digest dispatch (kit is sent to all HardAssigned interviewers). | HardAssignment is used when an interviewer has confirmed availability. Contrast with SoftAssignment. |
| **SoftAssignment** | A tentative assignment mode used when an interviewer's availability is unconfirmed. Soft-assigned interviewers receive a preliminary notice but not the full Session Digest kit until the assignment is confirmed (promoted to HardAssignment). | SoftAssignment is a planning tool, not an operational commitment. The system does not count SoftAssigned interviewers toward the InterviewSession's active panel. |
| **Panel** | The set of all HardAssigned interviewers for an InterviewSession at the time of session execution. The Panel evaluates candidates and submits scores. | A Panel must have at least 1 member for an InterviewSession to be considered active. Panels are defined per-session, not per-event. A TA Coordinator may change the Panel up until the session starts (RegistrationOpen or InProgress state). |
| **Queue** | The ordered list of candidates assigned to an InterviewSession, managed in real-time during the event. Candidates enter the queue when their `CheckInCaptured` event is received (Provisional state) and are promoted to Confirmed state on `CheckInConfirmed`. | The Queue is a real-time operational artifact within an InterviewSession. It is not persisted as a standalone aggregate — it is a projection of CheckIn events onto the session's assigned candidates. The order within the queue may be based on slot time, SBD order, or check-in arrival time (configurable per event). |
| **SessionDigest** | The notification package sent to all HardAssigned interviewers for an InterviewSession. Contains: event details, room and time assignment, candidate list, and a KitLink. | SessionDigest dispatch is triggered by TA Coordinator command, not automatically. The TA Coordinator chooses when to send — typically after all assignments are confirmed and a day before the event. A SessionDigest is tied to a specific point-in-time snapshot of the session's candidate list and interviewer assignments. |
| **KitLink** | A time-limited URL embedded in the SessionDigest email that gives an interviewer access to their digital interview kit: the live candidate queue, scoring forms, and session notes. | KitLink expires 24 hours after the event day (`event_date + 24h`). **Every request to the KitLink is validated server-side against the expiry timestamp** — the expiry is not merely advisory (BR-05). After expiry, the link returns a 403 response. There is no KitLink refresh mechanism after expiry; score access post-expiry is via the TA Coordinator portal only. |
| **InterviewScore** | An immutable record of the score awarded by one interviewer to one candidate in one InterviewSession. Created at the moment an interviewer submits their scoring form via the KitLink interface. | InterviewScore is immutable post-submission. No in-place edits are permitted (BR-04). The only way to change a submitted score is via an approved ScoreEditRequest, which creates a **new** InterviewScore rather than modifying the old one. The old score is retained for audit purposes. |
| **ScoreEditRequest** | A formal request by an interviewer (or TA Coordinator on their behalf) to amend a submitted InterviewScore. Requires TA Coordinator approval before any change takes effect (BR-04). | ScoreEditRequest does not modify the original InterviewScore directly. On approval, a new InterviewScore is created with the amended values, and both the original and the new score are retained. The ScoreEditRequest captures: requester, reason, original score ref, proposed new score values, and approval decision. |
| **ScoreComponents** | The per-criterion breakdown within an InterviewScore. Each criterion maps to a configured scoring dimension (e.g., Technical, Communication, Problem Solving). The sum or weighted aggregate of components equals the total score. | ScoreComponents are defined by the scoring template attached to the Track/Session. They are captured as part of the InterviewScore value object and are immutable once the score is submitted. |
| **SkipReason** | A classification for why a candidate was not interviewed in a session: `NoShow` (candidate did not appear), `TechnicalIssue`, `CandidateWithdrew`, `Other`. | SkipReason is attached to a `CandidateSkipped` event. A skipped candidate remains in the Candidate Registration system — they are not cancelled, just marked as not interviewed in this session. The TA Coordinator may manually schedule a make-up session. |
| **SessionDigestDelivery** | The act of dispatching the SessionDigest package to a specific interviewer. One SessionDigest dispatch may result in multiple SessionDigestDeliveries (one per HardAssigned interviewer). Tracked in Communication BC's DeliveryRecord. | SessionDigestDelivery is tracked by Communication BC, not Interview Management BC. Interview Management emits `SessionDigestDispatched`; Communication BC handles the actual email delivery and tracks per-recipient delivery status. |

---

## Business Rules in This Context

| BR-ID | Rule | Implementation |
|-------|------|---------------|
| BR-04 | InterviewScore is immutable post-submission | No direct edit slots. Score amendment requires ScoreEditRequest → TA approval → new InterviewScore creation. |
| BR-05 | KitLink expires 24h after event day; server-side enforced | `KitLink.expiry_at = event_date + 24h`. Every request validated server-side. Expired links return HTTP 403. |

---

## Lifecycle States

### InterviewSession States
```
Scheduled → Active → Completed
         → Deferred
         → Skipped
```
- **Scheduled**: Panel assigned; SessionDigest may or may not have been sent.
- **Active**: Event is In Progress; candidates are being interviewed.
- **Completed**: All assigned candidates have been scored or skipped.
- **Deferred**: Session postponed (rescheduled to a different slot).
- **Skipped**: Entire session skipped (no interviews conducted).

### InterviewScore States
```
Submitted (immutable)
```
No state machine — an InterviewScore is a point-in-time fact. Its existence IS its state.

### ScoreEditRequest States
```
Pending → Approved → [New InterviewScore created]
        → Rejected
```

### KitLink States
```
Active → Expired
```
- **Active**: `current_time < expiry_at`. All requests served.
- **Expired**: `current_time >= expiry_at`. Requests return HTTP 403.

---

## Integration Points

| Upstream Event | Origin BC | Action in This Context |
|---------------|-----------|------------------------|
| `CheckInCaptured` | Onsite Operations | Add candidate to Queue in Provisional state; display with indicator |
| `CheckInConfirmed` | Onsite Operations | Promote Queue entry to Confirmed state (<5s SLA, NFR-03) |
| `CheckInConflict` | Onsite Operations | Mark Queue entry as Conflict; display warning to interviewer |
| `SlotAllocated` | Schedule & Capacity | Link candidate to interview room and time within this context |
| `EventStarted` | Event Management | Activate interview mode; enable scoring forms |

| Downstream Event | Consuming BC | Purpose |
|-----------------|--------------|---------|
| `SessionDigestDispatched` | Communication | Trigger interviewer kit email dispatch |
| `InterviewScoreSubmitted` | Analytics & Audit | Audit + metrics |
| `ScoreEditApproved` | Analytics & Audit | Audit trail for score amendments |
| `ScoreEditRejected` | Analytics & Audit | Audit trail |
