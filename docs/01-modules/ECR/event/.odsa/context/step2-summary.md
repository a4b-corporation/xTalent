# Step 2 Context Summary — Reality Layer
## ECR Module | xTalent HCM Solution | 2026-03-25

---

## What Was Produced

### Artifacts

| Artifact | Path | Status |
|----------|------|--------|
| BRD | `reality/brd.md` | Complete |
| User Stories | `reality/user-stories.md` | Complete |
| Event Storming | `reality/event-storming.md` | Complete |

### Key Stats

| Metric | Count |
|--------|-------|
| Business Requirements (BR-IDs) | 31 (across 10 capability groups) |
| Business Rules | 10 (BR-01 to BR-10) |
| Non-Functional Requirements | 12 (NFR-01 to NFR-12) |
| User Stories | 39 (across 10 epics) |
| Gherkin Scenarios | 89 (2–4 per story) |
| Domain Events | 54 (DE-01 to DE-54) |
| Commands | 36 (CMD-01 to CMD-36) |
| Policies | 15 (POL-01 to POL-15) |
| Hot Spots | 12 (HS-01 to HS-12) |
| External Systems | 8 |
| Aggregates Identified | 8 |

---

## Key BRD Decisions Made

1. **Event as first-class entity** — The ECR module is organized around Event as the root aggregate, not job requisitions. All ATS functions (candidate capture, assessment, scheduling, interviews) are subordinate to the event context.

2. **SBD Decoupling** — SBD is generated at registration capture, not at email delivery (BR-01). This is a hard constraint on the implementation — SBD generation cannot have an email dependency.

3. **Human-in-the-loop for duplicates** — All duplicate resolution is human-driven (BR-02). No automated merge or reject. System's role is detection and surfacing, not resolution.

4. **Assessment deferred** — FR-14 to FR-18 are documented but blocked pending build vs. integrate decision. The interface contract (in: candidate context; out: score) must be defined in Step 3 regardless of the decision.

5. **Offline-first kiosk design** — Kiosk must operate without connectivity (BR-08). Offline data is provisional until sync; sync is atomic per record; failures go to manual review queue, not silent data loss.

6. **Structural immutability once In Progress** — No track, capacity, or form changes permitted after event starts (BR-06). Operational changes (individual schedule adjustments, scores, status updates) remain permitted.

7. **Four items formally deferred** — FR-25 (face capture, legal block), FR-26 (badge printing, hardware), FR-35 (SMS, vendor), FR-14–18 (assessment, product decision).

---

## Business Rules Finalized

| BR-ID | Rule | Category |
|-------|------|----------|
| BR-01 | SBD Decoupling | Operational |
| BR-02 | Duplicate Resolution Is Human | Data Integrity |
| BR-03 | Bulk Advancement Exclusions (unresolved duplicates) | Data Integrity |
| BR-04 | Score Finality (edit requires TA approval + audit log) | Compliance |
| BR-05 | Manager Link Expiry (24h, server-side) | Security |
| BR-06 | Event Structural Immutability In Progress | Operational Integrity |
| BR-07 | Assessment Delivery Gate (Confirmed/Checked-In only) | Fairness |
| BR-08 | Offline Data Integrity (provisional, atomic sync, no loss) | Data Integrity |
| BR-09 | Per-Event RBAC (extends xTalent base, does not bypass) | Security |
| BR-10 | Waitlist Ordering (FCFS, no manual override) | Fairness |

---

## Scope Decisions

- **In scope, 44 FRs** across 10 capability groups
- **Deferred (4 items)**: Assessment (FR-14–18), Face Capture (FR-25), Badge Printing (FR-26), SMS (FR-35)
- **Out of scope**: Offer management, onboarding, payroll, performance management, video interviewing
- **Constraint confirmed**: All data must reside in Vietnam (NFR-09) — this is a hard constraint for vendor selection and architecture

---

## What Step 3 (Domain Architecture) Needs to Know

### Critical Design Decisions Required in Step 3

1. **SBD generation in offline mode** — How does the SBD sequence counter stay consistent across multiple kiosks operating simultaneously offline? (HS-01) Suggested approach: pre-allocated SBD blocks per kiosk at sync time.

2. **Assessment aggregate boundary** — Until the build vs. integrate decision is made, Step 3 must model Assessment as an interface boundary with a defined contract: `(CandidateEventRegistration, BlueprintID) → AssessmentResult`. Domain design should not assume internal structure of Assessment.

3. **Offline sync conflict resolution protocol** — The domain model must specify what happens when an offline-captured candidate conflicts with an existing record at sync time (HS-03).

4. **Bulk operation concurrency** — Bulk advancement must be serialized per event to prevent duplicate processing (HS-11). Step 3 should specify aggregate-level locking strategy.

5. **Event Cloning and Question Bank references** — Clone copies by value (snapshot) or by reference? Step 3 must decide and document (HS-10).

### Aggregate Candidates Identified

The event storming identified 8 aggregate clusters for bounded context mapping:
1. Event Management (Event, Track, EventPhase)
2. Candidate Registration (CandidateEventRegistration, SBD, DuplicateFlag, Waitlist)
3. Assessment (Blueprint, QuestionBank, CandidateAssessment)
4. Schedule Management (EventSchedule, ScheduleSlot, AllocationStrategy)
5. Onsite Operations (CheckInRecord, KioskSession, OfflineSyncQueue)
6. Interview Management (InterviewSession, SessionDigest, InterviewScore)
7. Communication (CommunicationJob, EmailTemplate, DeliveryRecord)
8. Analytics & Audit (AuditEntry, EventMetrics, ReportDefinition)

### Integration Dependencies
- xTalent RBAC Service (P0 — all auth depends on this)
- xTalent Job Request API (P1 — fallback allowed)
- Email Delivery Service (P0 — primary notification channel)
- Assessment Engine (P1 — interface contract needed now; implementation deferred)

---

## Open Questions for Step 3

1. Should CandidateEventRegistration be a projection of a global Candidate entity, or is the event-scoped registration fully independent?
2. What is the consistency boundary between Onsite Operations (check-in) and Interview Management (queue display)? Is the 5-second SLA (NFR-03) satisfied by eventual consistency or does it require a tighter coupling?
3. How does the xTalent RBAC model extend to per-event roles without creating a separate permission store?
