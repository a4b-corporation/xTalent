# Glossary: Candidate Registration
## ECR Domain | 2026-03-25

This glossary defines the ubiquitous language for the Candidate Registration bounded context. Terms here are event-scoped — they describe a candidate's participation in one specific Event, not a global identity record.

---

| Term | Definition | Notes / Disambiguations |
|------|-----------|------------------------|
| **CandidateEventRegistration** | The aggregate root representing a specific candidate's participation record in a specific Event. Fully event-scoped: it is not a projection of a global Candidate identity. Contains personal information captured at registration, SBD, status, and track assignment. | Not a "candidate profile." A person may have multiple CandidateEventRegistrations across different Events. Each is an independent aggregate. There is no global Candidate entity within ECR scope. |
| **SBD (Số Báo Danh)** | A short, human-readable numeric identifier assigned to a CandidateEventRegistration at the moment of capture, unique within a single Event. Used for check-in, interview assignment, and score lookup. | Event-scoped: the same person may have SBD 042 in one event and SBD 317 in another. SBD is assigned at capture (BR-01) — even if no email is ever sent, the SBD exists. SBD gaps in the sequence are permitted (from unused offline kiosk blocks). |
| **Registration Capture** | The moment when a candidate's data is first recorded in the system, regardless of channel (online portal, kiosk, import). SBD is generated at this exact moment. | "Capture" is preferred over "submission" because it applies to all channels including offline kiosk (where the candidate does not submit digitally). |
| **RegistrationSource** | The channel through which a CandidateEventRegistration was created. Values: Online (candidate self-served portal), Kiosk (checked in at event venue), Offline (kiosk operating without connectivity), Import (bulk upload by TA Coordinator). | Relevant for audit and offline sync flow. Offline-captured records are Provisional until sync. |
| **PersonalInfo** | A value object containing the candidate's captured personal data: full name, phone number, email address, and student ID. This combination is the multi-factor deduplication key. | Not a permanent identity record. PersonalInfo is captured at registration and may differ from a candidate's global xTalent profile (if one exists). Phone + Student ID is the primary dedup key (BR-02). |
| **RegistrationStatus** | The current state of a CandidateEventRegistration in its lifecycle. Values: Pending (awaiting confirmation), Confirmed (accepted, slot allocated), Waitlisted (capacity full, queue position assigned), Cancelled (withdrawn or admin-cancelled). | "Confirmed" in this context means confirmed for the Event overall, not confirmed in a specific schedule slot. Slot confirmation is managed by the Schedule & Capacity BC and reflected back as a slot reference. |
| **Confirmed** | A RegistrationStatus value indicating the candidate has been accepted into the Event and a schedule slot is being or has been allocated. Confirmed candidates are eligible for check-in, assessment dispatch (BR-07), and interview assignment. | Disambiguate from "slot confirmed" (a Schedule & Capacity concept). Here, Confirmed means event-level acceptance. A candidate may be Confirmed but not yet slot-allocated if the allocation run has not completed. |
| **Provisional** | A registration status variant applied to records captured via offline kiosk that have not yet been synced to the server. Provisional records exist in the local kiosk store and are visible in the interviewer queue as a pre-confirmation signal, but are not authoritative until sync completes. | Provisional is an operational state, not a lifecycle state. A Provisional record becomes a full CandidateEventRegistration upon successful sync. If sync fails, it becomes a ManualReviewItem in the Onsite Operations BC. |
| **DuplicateFlag** | An entity within a CandidateEventRegistration that marks a suspected duplicate relationship with another registration. Contains the flagged registration ID, the dedup key match type (phone, student ID, or both), and the resolution state. | A DuplicateFlag must be resolved by a human TA Coordinator (BR-02). System never auto-merges or auto-rejects. An unresolved DuplicateFlag on any registration in a bulk operation excludes that registration from the operation (BR-03). |
| **WaitlistEntry** | An entity tracking a candidate's position and status in the event waitlist. Contains the waitlist position (assigned at capture time), activation state, and FCFS timestamp. | Ordering is strictly by `registeredAt` timestamp. No manual reordering is permitted under any circumstance (BR-10). Position number is informational; actual promotion order is always determined by timestamp. |
| **Waitlisted** | A RegistrationStatus value indicating the candidate's registration was accepted but they are on the waitlist because the Event (or their Track) has reached capacity. The candidate has a WaitlistEntry with a queue position. | A Waitlisted candidate is not yet eligible for check-in or assessment. They become eligible only after being activated (promoted to Confirmed). |
| **Multi-Factor Deduplication** | The duplicate detection mechanism that compares incoming registrations against existing records using a composite key of phone number AND student ID. A match on either dimension raises a DuplicateFlag. | Detection is mandatory on every registration capture across all channels. Offline kiosks must perform local dedup against their cached registration list, then server-side dedup occurs at sync time. |
| **Bulk Advancement** | An operation performed by a TA Coordinator to advance multiple CandidateEventRegistrations through a pipeline stage simultaneously. Registrations with unresolved DuplicateFlags are automatically excluded from bulk advancement operations (BR-03). | "Advancement" is a pipeline stage transition, not a status change. The status remains Confirmed; the pipeline stage within the Track changes. |

---

## Business Rules in This Context

| BR-ID | Rule | Domain Impact |
|-------|------|--------------|
| BR-01 | SBD generated at capture | SBD must be assigned at the time of registration capture, with no dependency on email delivery. Offline kiosks use pre-allocated SBD blocks. |
| BR-02 | Duplicate resolution is human | System raises DuplicateFlag; human resolves. No automated merge or rejection. |
| BR-03 | Unresolved duplicates excluded from bulk ops | DuplicateFlag.resolved = false blocks bulk advancement for that registration. |
| BR-10 | Waitlist FCFS only | WaitlistEntry.position derived from registeredAt timestamp. No manual reorder API. |

## Registration Lifecycle

```
Capture ──► Pending ──► Confirmed ──► [Check-In eligible, Assessment eligible]
                  └──► Waitlisted ──► [Activated] ──► Confirmed
                  └──► Cancelled (terminal)
```
