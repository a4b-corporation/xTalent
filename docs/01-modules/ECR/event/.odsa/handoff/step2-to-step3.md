# Handoff: Step 2 → Step 3
## Reality Layer → Domain Architecture
## ECR Module | xTalent HCM Solution | 2026-03-25

---

## Handoff Contract

This document is the formal input contract for the Step 3 Domain Architect. All artifacts referenced below are complete and gate-reviewed.

---

## Completed Artifacts

| Artifact | Path | Gate G2 Status |
|----------|------|---------------|
| Business Requirements Document | `reality/brd.md` | Pending review |
| User Stories (39 stories, 89 scenarios) | `reality/user-stories.md` | Pending review |
| Event Storming (54 events, 36 commands, 12 hot spots) | `reality/event-storming.md` | Pending review |
| Step 2 Context Summary | `.odsa/context/step2-summary.md` | Complete |

---

## Input Summary for Step 3

### Problem Domain
Event-Centric Recruitment (ECR) for Vietnamese enterprises running mass hiring events (500–1,000+ candidates, 1–2 day events, multiple parallel tracks). The primary organizing entity is the Event, not the job requisition. All ATS functions are subordinate to the event context.

### Confirmed Scope
- 44 functional requirements across 10 capability groups
- 10 business rules (BR-01 to BR-10)
- 12 NFRs with measurement criteria
- 4 deferred items (assessment FR-14–18, face capture FR-25, badge printing FR-26, SMS FR-35)

### Key Business Rules That Constrain Domain Design
- BR-01: SBD generated at capture, not at email delivery — SBD generation must be offline-capable
- BR-02: No auto-merge/reject of duplicates — system surfaces, human decides
- BR-04: Score finality with approval workflow — InterviewScore is an immutable value object post-submission
- BR-05: Session Digest links expire 24h after event day — KitLink has a computed expiry attribute enforced server-side
- BR-06: Structural immutability once In Progress — Event aggregate enforces a locked flag on structural mutations
- BR-08: Offline data integrity — CheckInRecord and CandidateEventRegistration support a Provisional state
- BR-10: Waitlist FCFS only — WaitlistEntry ordering is by registration timestamp, no manual reorder

---

## Bounded Context Candidates

Based on the event storming aggregates, the following bounded contexts are recommended as starting points for Step 3. These are candidates, not final decisions.

### BC-01: Event Management Context
**Core Aggregates:** Event, Track, EventPhase, RegistrationForm
**Responsibilities:** Event lifecycle state machine, track configuration, form building, event cloning
**Key Invariants:** State transition validation, structural immutability In Progress, minimum 1 track
**Integration:** Publishes events (state changes, track added) consumed by all other contexts

### BC-02: Candidate Registration Context
**Core Aggregates:** CandidateEventRegistration, SBD, DuplicateFlag, WaitlistEntry
**Responsibilities:** Online/kiosk/offline registration, SBD generation, multi-factor duplicate detection, waitlist management
**Key Invariants:** SBD unique per event, generated at capture regardless of email status, duplicate detection on every registration, waitlist ordering by timestamp
**Hot Spot:** SBD sequence management in offline multi-kiosk scenarios (HS-01) — requires pre-allocated SBD block design

### BC-03: Assessment Context (Interface-Defined Only)
**Core Aggregates:** CandidateAssessment, AssessmentResult (internal structure TBD pending build/integrate decision)
**Responsibilities:** Assessment delivery gating, blueprint application, result ingestion
**Key Invariants:** Delivery gate — Confirmed/Checked-In only (BR-07); assessment link time-limited
**Critical Note:** This context has an undefined internal structure. Step 3 must define the interface contract: Input = (CandidateEventRegistration reference, BlueprintID), Output = AssessmentResult. Internal implementation is deferred (Risk-01).

### BC-04: Schedule & Capacity Context
**Core Aggregates:** EventSchedule, ScheduleSlot, Room, Shift, AllocationStrategy
**Responsibilities:** Schedule matrix definition, candidate-to-slot allocation (Round-Robin / Fill-First), waitlist backfill, capacity override with audit
**Key Invariants:** No room double-booking, capacity overrides require reason + logged, structural capacity changes locked In Progress (BR-06)
**Integration:** Consumes CandidateConfirmed events from Candidate Registration BC; emits CandidatesAllocatedToSlots

### BC-05: Onsite Operations Context
**Core Aggregates:** CheckInRecord, KioskSession, OfflineSyncQueue, ManualReviewQueue
**Responsibilities:** QR and SBD check-in, offline mode management, sync orchestration, manual review queue
**Key Invariants:** Check-in <5s P95 (NFR-02); duplicate check-in detected; offline data provisional until sync; sync atomic per record; no data loss on sync failure (BR-08)
**Hot Spot:** Multi-kiosk offline SBD conflict at sync (HS-01, HS-03) — requires conflict resolution protocol definition

### BC-06: Interview Management Context
**Core Aggregates:** InterviewSession, InterviewerAssignment, SessionDigest, KitLink, InterviewScore, ScoreEditRequest
**Responsibilities:** Interviewer assignment, Session Digest generation and dispatch, digital interview kit access, score submission and lock, score edit approval workflow, skip/defer queue management
**Key Invariants:** KitLink expires 24h after event day server-side (BR-05); InterviewScore is immutable post-submission (BR-04); all score edits require TA Coordinator approval and audit entry
**Hot Spot:** KitLink expiry for open browser tabs — client-side graceful warning needed (HS-05)

### BC-07: Communication Context
**Core Aggregates:** CommunicationJob, EmailTemplate, DeliveryRecord
**Responsibilities:** Bulk email dispatch (500/min), Session Digest delivery, reschedule notifications, delivery tracking and retry
**Key Invariants:** Never silently discard failed deliveries; retry with backoff; email is sole guaranteed channel (SMS deferred)

### BC-08: Analytics & Audit Context
**Core Aggregates:** AuditEntry, EventMetricsSnapshot, ReportDefinition
**Responsibilities:** Append-only audit trail for all consequential actions, real-time dashboard metrics, dynamic report builder
**Key Invariants:** Audit log is append-only and tamper-evident; minimum 3-year retention; all score changes, bulk ops, duplicate resolutions, structural changes generate an entry

---

## Key Domain Concepts Requiring Ubiquitous Language Definitions

The following terms appeared consistently across all three Reality artifacts and must have formal definitions established in the Step 3 ubiquitous language glossary:

| Term | Context | Ambiguity to Resolve |
|------|---------|---------------------|
| SBD (Số Báo Danh) | Candidate Registration | Is SBD an event-scoped identifier or a global one? (Assumption: event-scoped) |
| Track | Event Management | Does a Track have sub-tracks? Is a Track also a pipeline configuration? |
| Phase | Event Management | Phase vs. State — are these synonymous or layered? (State machine drives transitions; Phase describes the operational context) |
| Provisional | Onsite Operations / Candidate Registration | What operations are permitted on Provisional records? Can a Provisional record be used for queue display? |
| Confirmed | Candidate Registration / Schedule | Does Confirmed mean "confirmed in the event" or "confirmed in a schedule slot"? These may be two different status dimensions. |
| Session Digest | Interview Management | Is Session Digest a document or a notification event? (It is a notification that contains a document) |
| Blueprint | Assessment | Is Blueprint a template or an instance? Does each assessment delivery create a Blueprint instance? |
| Aggregate | Ubiquitous Language | "Aggregate" must not be used colloquially in domain discussions — only in the DDD technical sense |

---

## Integration Points with External Systems

| External System | BC Consuming It | Integration Pattern | Data Sensitivity |
|----------------|-----------------|---------------------|-----------------|
| xTalent RBAC Service | All contexts (authentication) | Synchronous API | High |
| xTalent Job Request API | Event Management BC | Synchronous API | Medium |
| Email Delivery Service | Communication BC | Async (fire and forget + webhook) | Medium |
| Assessment Engine (TBD) | Assessment BC | Synchronous API (interface TBD) | High |
| SMS Gateway (deferred) | Communication BC | Async | Medium |
| Vietnam Data Center | All contexts | Infrastructure constraint | Critical |

---

## Constraints for Domain Design

1. **Data residency is non-negotiable** — No data may leave Vietnamese data centers. Any cross-context communication involving candidate PII must stay within the Vietnam region boundary.

2. **xTalent RBAC cannot be bypassed** — Per-event role extensions must delegate to the xTalent RBAC service. ECR cannot maintain its own independent permission store.

3. **Assessment interface is a black box** — Until the build/integrate decision is made, the Assessment BC must be modeled as a bounded interface. Do not design internal Assessment domain models in Step 3 — only the Anti-Corruption Layer (ACL) and contract.

4. **Offline-first is an architectural constraint, not a feature** — The Onsite Operations BC must be designed for offline-first from the ground up. This affects all design decisions about the CheckInRecord aggregate and SBD generation.

5. **Audit log is cross-cutting** — AuditEntry creation touches all contexts. Step 3 must decide: is this a shared kernel, a separate context with event subscriptions, or a cross-cutting concern implemented as middleware?

---

## Recommended Starting Point for Step 3

**Start with the Event Management BC.** It is the root aggregate that all other contexts depend on. Its state machine (Draft → Published → Registration Open → In Progress → Closed → Archived) and its structural immutability rule (BR-06) create the invariants that other contexts must respect.

**Second priority: Candidate Registration BC.** The SBD generation mechanism (especially offline multi-kiosk design) is the highest-risk technical design in the module (HS-01). Getting the SBD pre-allocation block strategy right early prevents a redesign of all onsite operations.

**Third priority: Define the Assessment BC interface contract.** Even if the internals are deferred, all other contexts (Registration, Schedule, Interview) need to know what signals Assessment emits (assessment completed, score available) and what it consumes (candidate context, blueprint). This unblocks the rest of domain design.

---

## Gate G2 Status

- [x] BRD has all 9 sections; objectives are SMART with baselines, targets, and deadlines
- [x] User Stories have specific actors (not "user"); 89 Gherkin scenarios with happy + error paths
- [x] Event Storming has 54 domain events (past tense), 36 commands, 8 aggregates, 15 policies, 12 hot spots
- [x] No "TBD" items — all unknowns marked as assumptions or deferred items with explicit rationale
- [x] Cross-reference: all 5 BRD actors appear in user stories and event storming commands
- [ ] Gate G2 review pending — awaiting Product Owner and Domain Architect sign-off before Step 3 begins
