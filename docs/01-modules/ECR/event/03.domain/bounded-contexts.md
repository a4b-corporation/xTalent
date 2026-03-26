# Bounded Contexts: ECR Module
## xTalent HCM Solution | 2026-03-25

---

## Overview

The Event-Centric Recruitment (ECR) module is organized around the **Event** as the primary aggregate root. All recruitment functions — candidate intake, assessment, scheduling, onsite operations, interviews, and communications — are scoped within an event context. This is a deliberate departure from traditional ATS design where the job requisition is the organizing entity.

The domain spans 8 bounded contexts. Three are **Core Domain** (Event Management, Candidate Registration, Onsite Operations), three are **Supporting Domain** (Schedule & Capacity, Interview Management, Communication), one is **Generic Supporting** (Analytics & Audit), and one is an **Interface Boundary** (Assessment).

All contexts operate within Vietnamese data residency constraints (NFR-09). No candidate PII may leave Vietnam-region infrastructure. The xTalent RBAC Service is an upstream shared authority; all ECR contexts are conformist to its permission model.

---

## Context Map

```
                         ┌─────────────────────────────────────────────────────────┐
                         │               xTalent Platform (Upstream)                │
                         │  RBAC Service          Job Request API                   │
                         └──────┬──────────────────────┬──────────────────────────-─┘
                                │ Conformist            │ Customer-Supplier
                                │ (all contexts)        │ (Event Mgmt only)
                                ▼                       ▼
                    ┌───────────────────────────────────────────────┐
                    │           BC-01: Event Management              │
                    │           [CORE DOMAIN]                        │
                    │  Event · Track · EventPhase · RegistrationForm │
                    └──────┬────────────────────────────────────────┘
                           │  Publishes: EventPublished, EventStarted,
                           │             TrackAdded, EventClosed
                           │  (Open Host Service — domain events)
          ┌────────────────┼────────────────────────────────────────────┐
          │                │                                            │
          ▼                ▼                                            ▼
┌─────────────────┐  ┌─────────────────────┐                ┌──────────────────────┐
│  BC-02:         │  │  BC-04:             │                │  BC-07:              │
│  Candidate      │  │  Schedule &         │                │  Communication       │
│  Registration   │  │  Capacity           │                │  [SUPPORTING]        │
│  [CORE]         │  │  [SUPPORTING]       │                │                      │
└────────┬────────┘  └──────────┬──────────┘                └──────────┬───────────┘
         │                      │                                       │
         │ CandidateConfirmed   │ SlotAllocated                        │ Async events
         │ WaitlistActivated    │ CapacityUpdated                      │ + webhook
         ▼                      ▼                                       ▼
┌─────────────────┐  ┌─────────────────────┐                ┌──────────────────────┐
│  BC-05:         │  │  BC-06:             │                │  External:           │
│  Onsite         │  │  Interview          │                │  Email Delivery      │
│  Operations     │  │  Management         │                │  Service             │
│  [CORE]         │  │  [SUPPORTING]       │                └──────────────────────┘
└────────┬────────┘  └──────────┬──────────┘
         │                      │
         │ CheckInConfirmed      │ ScoreSubmitted
         │                       │ ScoreEditApproved
         ▼                       ▼
┌─────────────────────────────────────────────────────────┐
│            BC-08: Analytics & Audit                      │
│            [GENERIC SUPPORTING]                          │
│  Subscribes to: all consequential domain events          │
│  Append-only · Tamper-evident · 3-year retention         │
└─────────────────────────────────────────────────────────┘

         ┌─────────────────────────────────────────┐
         │  BC-03: Assessment                       │
         │  [INTERFACE BOUNDARY — ACL]              │
         │  Internal model deferred (build/integrate│
         │  decision pending). Exposes contract:    │
         │  IN:  (RegistrationRef, BlueprintID)     │
         │  OUT: AssessmentResult                   │
         └────────────────┬────────────────────────┘
                          │ ACL — Anti-Corruption Layer
                          │ Consumed by: Candidate Registration,
                          │             Schedule & Capacity
                          ▼
                  External Assessment Engine (TBD)

Integration Patterns Legend:
  Conformist       — ECR adopts upstream model as-is
  Customer-Supplier— ECR negotiates requirements with upstream
  ACL              — Anti-Corruption Layer shields ECR from external model
  Open Host Service— Published domain events; consumers subscribe
  Partnership      — None used (no symmetric co-evolution relationships)
```

---

## Bounded Contexts

---

### BC-01: Event Management

**Type:** Core Domain
**Directory:** `domain/event-management/`

**Aggregates:**
- `Event` (aggregate root) — lifecycle, structural configuration, cloning
- `Track` (entity, child of Event) — pipeline configuration, slot allocation strategy
- `EventPhase` (value object) — describes the operational context of the current state
- `RegistrationForm` (entity, child of Event) — form field schema, validation rules

**Responsibilities:**
- Manage the full Event lifecycle state machine
- Enforce structural immutability once event transitions to In Progress (BR-06)
- Configure tracks, capacities, and registration form schemas
- Publish domain events consumed by all downstream contexts
- Support event cloning (by value — see OQ-D5 resolution below)
- Integrate with xTalent Job Request API for track-to-requisition mapping

**Invariants:**
- An Event must have at least 1 Track before it can be Published
- A Track must have a positive integer capacity
- No structural mutations (Track add/remove, capacity change, form schema change) are permitted once Event is In Progress
- Operational mutations (individual schedule adjustments, status transitions) remain permitted In Progress
- An Event cannot skip lifecycle states (e.g., cannot go from Draft directly to In Progress)
- Event title and date are mandatory before Publishing

**State Machine:**

```
Draft ──Publish──► Published ──OpenReg──► Registration Open ──StartEvent──► In Progress
  ▲                                                                               │
  │ Clone (by value)                                              CloseEvent ─────┘
  │                                                                    │
  └──────────────────────────────────────────────────────── Closed ───► Archived
```

Transition guards:
- `Publish`: requires >= 1 Track, valid date range, RegistrationForm defined
- `OpenReg`: requires event date is in the future
- `StartEvent`: may only occur on or after event start date; triggers structural lock
- `CloseEvent`: requires event date has passed or TA Coordinator override
- `Archive`: administrative action; requires Closed state

**Publishes (Domain Events):**
- `EventDrafted` — new event created in Draft
- `EventPublished` — event made visible to candidates
- `RegistrationOpened` — registration window activated
- `EventStarted` — event transitioned to In Progress; structural lock engaged
- `TrackAdded` — new track appended to Published event
- `EventClosed` — event concluded, no further operations
- `EventArchived` — event moved to archive
- `EventCloned` — new event created by copying existing event by value

**Subscribes to:** None (root publisher)

**Integration:**
- Upstream (Customer-Supplier): xTalent Job Request API — track-to-requisition linking
- Upstream (Conformist): xTalent RBAC Service — event creator/manager role validation
- Downstream: all other ECR contexts subscribe to this context's events

---

### BC-02: Candidate Registration

**Type:** Core Domain
**Directory:** `domain/candidate-registration/`

**Aggregates:**
- `CandidateEventRegistration` (aggregate root) — the event-scoped candidate record
- `WaitlistEntry` (entity, child of registration) — queue position and activation state
- `DuplicateFlag` (entity, child of registration) — flagged duplicate pair with resolution state

**Value Objects (within aggregates):**
- `SBD` (Số Báo Danh) — event-scoped unique identifier, immutable once assigned
- `PersonalInfo` — name, phone, email, student ID (multi-factor dedup key)
- `RegistrationSource` — enum: Online, Kiosk, Offline, Import

**Responsibilities:**
- Accept candidate registrations via online portal, kiosk, and import
- Generate SBD at point of capture, regardless of connectivity (BR-01)
- Detect duplicates using multi-factor key: phone + student ID (BR-02)
- Surface duplicate flags to TA Coordinators for human resolution (BR-02)
- Exclude unresolved duplicates from bulk advancement operations (BR-03)
- Manage waitlist with FCFS ordering (BR-10); activate when confirmed slots open
- Track registration status through the confirmation lifecycle

**Invariants:**
- SBD is unique per event and assigned at capture, never reassigned
- Every registration must pass duplicate detection before confirmation
- Unresolved DuplicateFlag blocks bulk advancement (BR-03)
- Waitlist ordering is strictly by `registeredAt` timestamp; no manual reorder (BR-10)
- A CandidateEventRegistration cannot be deleted; only cancelled (soft state)
- Registration status must follow: Pending → Confirmed | Waitlisted | Cancelled

**Publishes (Domain Events):**
- `CandidateRegistered` — new registration captured (SBD assigned)
- `CandidateConfirmed` — registration status set to Confirmed
- `DuplicateFlagRaised` — potential duplicate detected
- `DuplicateResolved` — TA Coordinator resolved duplicate (merge/keep/discard)
- `CandidateWaitlisted` — placed on waitlist (capacity full)
- `WaitlistActivated` — waitlist candidate promoted to Confirmed
- `RegistrationCancelled` — candidate withdrawn or admin-cancelled

**Subscribes to:**
- `RegistrationOpened` (Event Management) — gates registration acceptance
- `EventStarted` (Event Management) — prevents new registrations after event starts
- `SlotAllocated` (Schedule & Capacity) — updates confirmed slot reference

**Integration:**
- Upstream (Conformist): xTalent RBAC — role validation for TA Coordinator actions
- Downstream: Schedule & Capacity, Onsite Operations, Communication, Assessment (ACL)

---

### BC-03: Assessment

**Type:** Interface Boundary (ACL)
**Directory:** `domain/assessment/`

**Note:** Internal domain model is intentionally undefined pending build vs. integrate decision. This bounded context is modeled as a pure interface contract with an Anti-Corruption Layer (ACL). No internal aggregates are defined in Step 3.

**Interface Contract:**

```
Input:
  - CandidateEventRegistrationRef (eventId + sbdNumber)
  - BlueprintID (assessment template identifier)
  - DeliveryContext (eventId, trackId, timestamp)

Output:
  - AssessmentResult
      - candidateRef: CandidateEventRegistrationRef
      - blueprintId: BlueprintID
      - completedAt: DateTime
      - score: Decimal (0–100)
      - passed: Boolean
      - rawData: JSON (opaque to ECR domain)
```

**Delivery Gate (BR-07):** Assessment may only be dispatched to candidates with status = `Confirmed` or `CheckedIn`. ACL enforces this guard before calling the external engine.

**Responsibilities (ACL only):**
- Gate assessment dispatch to eligible candidates only (BR-07)
- Translate ECR candidate references to the external engine's format
- Ingest `AssessmentResult` and translate to ECR domain events
- Shield ECR domain from any future changes to the external engine's model

**Publishes (Domain Events, translated by ACL):**
- `AssessmentDispatched` — link sent to candidate
- `AssessmentCompleted` — result received from engine
- `AssessmentFailed` — delivery or completion failure

**Subscribes to:**
- `CandidateConfirmed` (Candidate Registration) — eligibility signal
- `CheckInConfirmed` (Onsite Operations) — eligibility signal

**Integration:**
- External (ACL): Assessment Engine (vendor TBD) — interface contract above
- Upstream (Conformist): xTalent RBAC — proctor/admin role validation

---

### BC-04: Schedule & Capacity

**Type:** Supporting Domain
**Directory:** `domain/schedule-capacity/`

**Aggregates:**
- `EventSchedule` (aggregate root) — the schedule matrix for an event
- `ScheduleSlot` (entity, child of schedule) — a time+room+track combination with capacity
- `AllocationRun` (entity) — a single execution of the allocation algorithm

**Value Objects:**
- `Room` — identifier, name, physical capacity
- `Shift` — start time, end time
- `AllocationStrategy` — enum: RoundRobin, FillFirst
- `CapacityOverride` — new capacity, reason, authorizedBy, timestamp

**Responsibilities:**
- Define the schedule matrix (rooms x timeslots x tracks)
- Execute candidate-to-slot allocation using configurable strategy (Round-Robin or Fill-First)
- Enforce room double-booking prevention
- Process waitlist backfill on slot vacancies (FCFS, per BR-10)
- Lock structural schedule changes once event is In Progress (BR-06)
- Audit all capacity override actions

**Invariants:**
- No two ScheduleSlots may reference the same Room at overlapping times
- ScheduleSlot capacity may not exceed Room physical capacity (unless overridden with audit)
- Structural schedule changes blocked once Event is In Progress (BR-06)
- AllocationRun is idempotent — re-running produces same result for same input set
- Waitlist backfill follows FCFS; no manual slot assignment (BR-10)

**Publishes (Domain Events):**
- `ScheduleCreated` — schedule matrix defined for event
- `SlotAllocated` — candidate assigned to a specific slot
- `CandidatesAllocatedToSlots` — bulk allocation run completed
- `CapacityOverridden` — slot capacity changed with audit entry
- `WaitlistBackfillTriggered` — vacated slot triggers waitlist promotion

**Subscribes to:**
- `EventStarted` (Event Management) — triggers structural lock on schedule
- `CandidateConfirmed` (Candidate Registration) — triggers slot allocation
- `WaitlistActivated` (Candidate Registration) — triggers slot backfill
- `RegistrationCancelled` (Candidate Registration) — vacates slot, triggers backfill

**Integration:**
- Upstream (Conformist): xTalent RBAC — schedule manager role validation
- Downstream: Interview Management (slot context for interview room assignment)

---

### BC-05: Onsite Operations

**Type:** Core Domain
**Directory:** `domain/onsite-operations/`

**Aggregates:**
- `CheckInRecord` (aggregate root) — the single source of truth for a candidate's onsite presence
- `KioskSession` (aggregate root) — represents an active kiosk device's operational session
- `OfflineSyncQueue` (entity, child of KioskSession) — ordered queue of offline-captured records
- `ManualReviewItem` (entity) — a sync conflict or anomaly requiring human resolution

**Value Objects:**
- `CheckInMethod` — enum: QRScan, SBDLookup, ManualEntry
- `SyncStatus` — enum: Provisional, Synced, Conflict, ReviewRequired
- `SBDBlock` — pre-allocated SBD range assigned to a kiosk (startSBD, endSBD, kioskId)
- `ConflictType` — enum: DuplicateCheckIn, SBDConflict, RecordMismatch

**Responsibilities:**
- Process candidate check-ins via QR code, SBD lookup, or manual entry
- Operate in offline-first mode; all data is Provisional until sync confirmed (BR-08)
- Manage per-kiosk SBD block pre-allocation to prevent sequence conflicts (resolution for OQ-D3)
- Execute atomic sync per record; failures route to ManualReviewQueue (BR-08)
- Detect duplicate check-ins (same candidate, same event)
- Surface unresolved sync conflicts to TA Coordinator

**Invariants:**
- A Provisional CheckInRecord may be displayed in the interviewer queue (eventual consistency; see OQ-D2 resolution)
- A CheckInRecord transitions to Synced only after server-side confirmation
- Sync failures never silently discard data — always route to ManualReviewQueue (BR-08)
- Each KioskSession holds exactly one SBDBlock; block exhaustion triggers re-allocation request
- A candidate may have at most one non-cancelled CheckInRecord per event

**Publishes (Domain Events):**
- `CheckInCaptured` — check-in recorded locally (Provisional state)
- `CheckInConfirmed` — sync successful; record promoted from Provisional to Synced
- `CheckInConflict` — sync conflict detected; routed to manual review
- `KioskSessionStarted` — kiosk came online with assigned SBD block
- `KioskSessionSynced` — kiosk completed sync run
- `ManualReviewResolved` — TA Coordinator resolved a conflict item

**Subscribes to:**
- `CandidateConfirmed` (Candidate Registration) — populates local candidate lookup cache
- `SlotAllocated` (Schedule & Capacity) — populates slot reference for check-in validation
- `EventStarted` (Event Management) — activates kiosk check-in mode

**Integration:**
- Upstream (Conformist): xTalent RBAC — kiosk operator role validation
- Downstream: Interview Management (CheckInConfirmed triggers queue update)
- Downstream: Analytics & Audit (all check-in events)

---

### BC-06: Interview Management

**Type:** Supporting Domain
**Directory:** `domain/interview-management/`

**Aggregates:**
- `InterviewSession` (aggregate root) — a scheduled interview between an interviewer and candidate(s)
- `InterviewerAssignment` (entity, child of session) — links an interviewer (xTalent User) to a session
- `SessionDigest` (entity, child of session) — the notification + embedded kit sent to interviewers
- `InterviewScore` (aggregate root) — an immutable score record post-submission
- `ScoreEditRequest` (entity) — a request to amend a submitted score, requiring TA approval

**Value Objects:**
- `KitLink` — URL, expiresAt (event_date + 24h), serverSideEnforced: true (BR-05)
- `ScoreComponents` — per-criterion scores summing to total
- `SkipReason` — enum: NoShow, TechnicalIssue, CandidateWithdrew, Other
- `SessionStatus` — enum: Scheduled, Active, Completed, Skipped, Deferred

**Responsibilities:**
- Assign interviewers to sessions and tracks
- Generate and dispatch Session Digest with KitLink (BR-05)
- Manage the interviewer's digital kit view (candidate list, scoring form)
- Accept and lock interview scores on submission (BR-04)
- Process score edit requests through TA Coordinator approval workflow (BR-04)
- Manage skip/defer queue for no-show or deferred candidates
- Update the HM queue within 5s of check-in event receipt (OQ-D2 SLA)

**Invariants:**
- KitLink expires 24h after event day; server-side validation on every request (BR-05)
- InterviewScore is immutable once submitted; no direct edits permitted (BR-04)
- Score edits require TA Coordinator approval and generate an AuditEntry (BR-04)
- An InterviewSession cannot be started unless at least 1 InterviewerAssignment exists
- SessionDigest may only be dispatched if event is in Registration Open or In Progress state

**Publishes (Domain Events):**
- `InterviewerAssigned` — interviewer linked to session
- `SessionDigestDispatched` — kit notification sent to interviewer(s)
- `KitLinkExpired` — server-side expiry of KitLink reached
- `InterviewScoreSubmitted` — score locked and immutable
- `ScoreEditRequested` — interviewer requests amendment
- `ScoreEditApproved` — TA Coordinator approved edit; new InterviewScore created
- `ScoreEditRejected` — TA Coordinator rejected edit request
- `CandidateSkipped` — candidate marked no-show or skipped

**Subscribes to:**
- `CheckInConfirmed` (Onsite Operations) — adds candidate to active interviewer queue (<5s SLA)
- `CheckInCaptured` (Onsite Operations) — provisional queue update (eventual, pre-sync display)
- `SlotAllocated` (Schedule & Capacity) — links candidate to interview room/time
- `EventStarted` (Event Management) — activates interview mode

**Integration:**
- Upstream (Conformist): xTalent RBAC — interviewer/TA Coordinator role validation
- Downstream: Communication (SessionDigest triggers email dispatch)
- Downstream: Analytics & Audit (all score events)

---

### BC-07: Communication

**Type:** Supporting Domain
**Directory:** `domain/communication/`

**Aggregates:**
- `CommunicationJob` (aggregate root) — a bulk or individual communication dispatch task
- `EmailTemplate` (aggregate root) — a versioned template with variable slots
- `DeliveryRecord` (entity, child of job) — per-recipient delivery status and tracking

**Value Objects:**
- `RecipientList` — list of (candidateRef, emailAddress) pairs
- `DeliveryStatus` — enum: Queued, Sent, Delivered, Bounced, Failed, Retrying
- `RetryPolicy` — maxAttempts, backoffSeconds, lastAttemptedAt
- `TemplateVariables` — key-value map injected at render time

**Responsibilities:**
- Dispatch bulk email at up to 500 messages/minute (NFR-07)
- Manage email template versioning
- Track per-recipient delivery status via webhook callbacks
- Implement retry with exponential backoff for failed deliveries
- Never silently discard failed deliveries (publish failure events, alert TA Coordinator)
- Dispatch Session Digest emails triggered by Interview Management events

**Invariants:**
- A failed DeliveryRecord must never be silently dropped — always retry or escalate
- CommunicationJob is idempotent — re-triggering same job does not produce duplicate sends
- EmailTemplate versions are append-only; published versions cannot be mutated
- Bulk jobs are rate-limited to 500/min to respect Email Delivery Service constraints

**Publishes (Domain Events):**
- `CommunicationJobCreated` — new dispatch job queued
- `EmailDispatched` — individual email submitted to delivery service
- `EmailDelivered` — delivery webhook confirmed success
- `EmailFailed` — delivery failed after all retries
- `TemplatePublished` — new template version made active

**Subscribes to:**
- `CandidateConfirmed` (Candidate Registration) — triggers confirmation email
- `WaitlistActivated` (Candidate Registration) — triggers waitlist promotion email
- `RegistrationCancelled` (Candidate Registration) — triggers cancellation notification
- `SlotAllocated` (Schedule & Capacity) — triggers slot assignment email
- `SessionDigestDispatched` (Interview Management) — triggers interviewer kit email
- `EventPublished` (Event Management) — may trigger announcement emails (configurable)

**Integration:**
- External (Async + Webhook): Email Delivery Service — fire and forget with delivery callback
- Upstream (Conformist): xTalent RBAC — template manager role validation

---

### BC-08: Analytics & Audit

**Type:** Generic Supporting Domain
**Directory:** `domain/analytics-audit/`

**Aggregates:**
- `AuditEntry` (aggregate root) — a single immutable audit log record
- `EventMetricsSnapshot` (aggregate root) — a point-in-time metrics snapshot for an event
- `ReportDefinition` (aggregate root) — a saved dynamic report configuration

**Value Objects:**
- `AuditAction` — enum covering all auditable operations (score edits, bulk ops, duplicate resolutions, structural changes, capacity overrides, RBAC changes)
- `MetricsDimension` — enum: Registration, CheckIn, Assessment, Interview, Funnel
- `SnapshotInterval` — enum: RealTime, Hourly, Daily
- `ActorRef` — userId, role, ipAddress (immutable at time of capture)

**Responsibilities:**
- Receive and store all consequential domain events as AuditEntries (append-only, tamper-evident)
- Resolve OQ-D4: implemented as a **separate context subscribing to domain events** (not middleware, not shared kernel)
- Maintain 3-year minimum retention for audit records (NFR-10)
- Compute real-time and snapshot metrics for event dashboards
- Support dynamic report definitions with configurable dimensions and filters

**Invariants:**
- AuditEntry is immutable after creation — no update or delete operations
- All score changes, bulk operations, duplicate resolutions, structural changes, and capacity overrides must produce an AuditEntry
- EventMetricsSnapshot may be computed from AuditEntry projections (read model)
- ReportDefinition references must resolve to valid MetricsDimensions
- Retention policy is enforced at the infrastructure level, not the domain level

**Publishes (Domain Events):** None (terminal consumer)

**Subscribes to (all consequential events):**
- `InterviewScoreSubmitted`, `ScoreEditApproved` (Interview Management)
- `DuplicateResolved`, `CandidateRegistered`, `CandidateConfirmed` (Candidate Registration)
- `CapacityOverridden`, `CandidatesAllocatedToSlots` (Schedule & Capacity)
- `EventStarted`, `EventClosed`, `EventCloned` (Event Management)
- `CheckInConfirmed`, `CheckInConflict`, `ManualReviewResolved` (Onsite Operations)
- `AssessmentCompleted` (Assessment)

**Integration:**
- Upstream (Conformist): xTalent RBAC — report viewer/admin role validation
- Infrastructure: append-only data store with tamper-evidence (hash chaining recommended)

---

## Context Map Decisions

### Why Assessment is ACL, Not Partnership

A Partnership pattern implies co-evolution: both sides adapt to each other. The Assessment Engine's build vs. integrate decision is unresolved. Modeling it as a Partnership would require ECR to commit to the external engine's evolution cycle before the decision is made. The ACL pattern protects the ECR domain model from any changes to the external engine's interface, regardless of which vendor or build approach is chosen.

### Why Analytics & Audit is Not a Shared Kernel or Middleware

Shared Kernel would require all contexts to take a compile-time dependency on the audit model. Middleware (cross-cutting aspect) would make audit invisible in the domain model — violating the requirement that audit is explicitly designed and testable. The chosen approach (separate context, event subscriptions) means:
1. Audit entries are created asynchronously — no performance impact on the primary flow
2. Each context publishes its own domain events; audit is a subscriber, not an intrusion
3. The audit contract is explicit: only published domain events are audited, not internal state

### Why Candidate Registration is Event-Scoped (OQ-D1 Resolution)

`CandidateEventRegistration` is fully event-scoped, not a projection of a global Candidate entity. Rationale:
- ECR events may include anonymous candidates (walk-ins at the kiosk)
- Each registration is a distinct participation act with its own SBD, status, and track
- A global Candidate entity would require a resolved identity before registration, which contradicts the offline kiosk requirement
- If a global Candidate entity exists in xTalent (future), the Registration BC may emit `CandidateRegistered` events that a future Identity BC consumes — but this is not a dependency within ECR scope

---

## Open Questions Resolved

### OQ-D1: CandidateEventRegistration — Event-Scoped or Global Projection?

**Resolution: Fully event-scoped.**

`CandidateEventRegistration` is an independent aggregate per event, not a projection of a global identity. See Context Map Decisions above. Each registration stands alone. Future global identity reconciliation is handled outside ECR scope via the `CandidateRegistered` published event.

### OQ-D2: 5s Real-Time SLA — Eventual Consistency or Tighter Coupling?

**Resolution: Provisional eventual consistency with a hard SLA bound.**

The Interview Management BC subscribes to **both** `CheckInCaptured` (Provisional) and `CheckInConfirmed` (Synced). On receipt of `CheckInCaptured`, the candidate is added to the interviewer queue in Provisional state immediately (sub-second). The `CheckInConfirmed` event promotes the record to Confirmed state. The 5-second SLA (NFR-03) is met by the Provisional path, not the Confirmed path. This avoids tight synchronous coupling between Onsite Operations and Interview Management while satisfying the operational requirement. The interviewer queue displays a visual indicator for Provisional records.

### OQ-D3: SBD Sequence Consistency Across Multiple Offline Kiosks

**Resolution: Pre-allocated SBD block per kiosk session.**

On `KioskSessionStarted`, the server assigns a contiguous SBD block (e.g., 1001–1100) to the kiosk. The kiosk allocates SBDs sequentially within its block offline. When a block nears exhaustion (< 10 remaining), the kiosk requests a new block at next sync. This eliminates inter-kiosk SBD conflicts at sync time. If a kiosk is decommissioned with unused SBD numbers in its block, those numbers are reclaimed — they appear as gaps in the SBD sequence. Gaps are permitted and documented as expected behavior in the glossary.

### OQ-D4: Audit Log Architecture — Shared Kernel, Separate Context, or Middleware?

**Resolution: Separate context with event subscriptions.**

Analytics & Audit (BC-08) is a terminal subscriber to all other contexts' domain events. No context takes a dependency on the audit model. Audit entries are created asynchronously from published domain events. This is the correct pattern: explicit, testable, non-invasive. See Context Map Decisions above.

### OQ-D5: Event Cloning — Copy by Value or by Reference?

**Resolution: Copy by value (snapshot at clone time).**

An Event clone creates a new Event aggregate with all structural data (tracks, capacities, form schema, schedule blueprint) copied as independent values. References to the original event are not maintained post-clone. Rationale: A cloned event must be independently mutable. If clone-by-reference were used, changes to the original's track configuration would unexpectedly affect the clone (violating BR-06's spirit). The `EventCloned` domain event records the source event ID as metadata for traceability, but the clone has no runtime dependency on the source.
