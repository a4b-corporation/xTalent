# Step 3 Summary: Domain Architecture
## ECR Module — Event-Centric Recruitment
## Completed: 2026-03-25

---

## Artifacts Produced

### B1: Bounded Contexts
- `domain/bounded-contexts.md`

### B2: Glossaries (one per BC)
- `domain/event-management/glossary.md`
- `domain/candidate-registration/glossary.md`
- `domain/assessment/glossary.md`
- `domain/schedule-capacity/glossary.md`
- `domain/onsite-operations/glossary.md`
- `domain/interview-management/glossary.md`
- `domain/communication/glossary.md`
- `domain/analytics-audit/glossary.md`

### B3: LinkML Schemas (one per BC)
- `domain/event-management/model.linkml.yaml`
- `domain/candidate-registration/model.linkml.yaml`
- `domain/assessment/model.linkml.yaml`
- `domain/schedule-capacity/model.linkml.yaml`
- `domain/onsite-operations/model.linkml.yaml`
- `domain/interview-management/model.linkml.yaml`
- `domain/communication/model.linkml.yaml`
- `domain/analytics-audit/model.linkml.yaml`

### B4: Use Case Flows (2+ per BC where applicable)
- `domain/event-management/flows/publish-event.flow.md`
- `domain/event-management/flows/clone-event.flow.md`
- `domain/candidate-registration/flows/register-candidate.flow.md`
- `domain/candidate-registration/flows/resolve-duplicate.flow.md`
- `domain/assessment/flows/deliver-assessment.flow.md`
- `domain/schedule-capacity/flows/allocate-candidates.flow.md`
- `domain/schedule-capacity/flows/waitlist-backfill.flow.md`
- `domain/onsite-operations/flows/kiosk-checkin.flow.md`
- `domain/onsite-operations/flows/offline-sync.flow.md`
- `domain/interview-management/flows/session-digest-dispatch.flow.md`
- `domain/interview-management/flows/score-submission.flow.md`
- `domain/communication/flows/bulk-email-dispatch.flow.md`
- `domain/analytics-audit/flows/audit-trail.flow.md`

---

## Bounded Context Decisions

| ID | Name | Type | Aggregates |
|----|------|------|-----------|
| BC-01 | Event Management | Core Domain | Event, Track, EventPhase (VO), RegistrationForm |
| BC-02 | Candidate Registration | Core Domain | CandidateEventRegistration, WaitlistEntry, DuplicateFlag |
| BC-03 | Assessment | Interface Boundary (ACL) | None (contract only; build/integrate deferred) |
| BC-04 | Schedule & Capacity | Supporting Domain | EventSchedule, ScheduleSlot, AllocationRun |
| BC-05 | Onsite Operations | Core Domain | CheckInRecord, KioskSession, OfflineSyncQueue, ManualReviewItem |
| BC-06 | Interview Management | Supporting Domain | InterviewSession, InterviewerAssignment, SessionDigest, InterviewScore, ScoreEditRequest |
| BC-07 | Communication | Generic Supporting | CommunicationJob, EmailTemplate, DeliveryRecord |
| BC-08 | Analytics & Audit | Generic Supporting | AuditEntry, EventMetricsSnapshot, ReportDefinition |

Integration pattern summary:
- BC-01 is the root publisher (Open Host Service); all other BCs subscribe downstream
- BC-03 is ACL-only; no internal aggregates modeled pending build/integrate decision
- BC-08 is a terminal consumer; publishes no domain events
- xTalent RBAC: all BCs are Conformist upstream
- xTalent Job Request API: BC-01 is Customer-Supplier

---

## Open Questions Resolved

**OQ-D1: CandidateEventRegistration scope**
`CandidateEventRegistration` is fully event-scoped (not a global projection). Each event creates independent registration records with their own SBD, status, and track. A global candidate identity entity is outside ECR scope. Walk-in kiosk registrations may be anonymous — requiring a global identity before registration would violate the offline-first kiosk requirement. Future global identity reconciliation happens outside ECR via the `CandidateRegistered` published event.

**OQ-D2: 5s SLA for HM dashboard updates**
Satisfied by subscribing to BOTH `CheckInCaptured` (Provisional) and `CheckInConfirmed` (Synced) in Interview Management BC. `CheckInCaptured` populates the interviewer queue immediately (sub-second, Provisional indicator shown). The 5s SLA (NFR-03) is met by the Provisional path. Confirmed promotion arrives asynchronously with no SLA constraint. No tight synchronous coupling between Onsite Operations and Interview Management.

**OQ-D3: SBD sequence consistency across offline kiosks**
Pre-allocated SBD block per kiosk session. On `KioskSessionStarted`, server assigns a contiguous SBD block (e.g., 100 numbers). Kiosk allocates within its block offline. Block near-exhaustion triggers pre-emptive re-allocation request at next sync. Inter-kiosk SBD conflicts are eliminated by block ownership. Unused numbers at kiosk decommission are reclaimed as permitted gaps. Gaps are expected behavior, documented in the Onsite Operations glossary.

**OQ-D4: Analytics & Audit architecture**
Separate BC (BC-08) subscribing to all consequential domain events via pub/sub. Not a shared kernel (would require compile-time dependency on audit model) and not middleware (would make audit invisible in the domain). Audit entries are created asynchronously — no performance impact on primary flows. The audit contract is explicit: only published domain events are audited.

**OQ-D5: Event cloning semantics**
Copy by value (snapshot at clone time). All structural data (tracks, capacities, form schema, schedule blueprint) is copied as independent values. No runtime reference to the source event is maintained. The `EventCloned` event records the source event ID as metadata for traceability only. Rationale: a cloned event must be independently mutable; reference-based cloning would cause unintended coupling.

---

## What Step 4 Needs

- All 8 BC definitions with aggregate ownership and integration contracts (see bounded-contexts.md)
- Context map: BC-01 (core, root publisher), BC-02 (core), BC-03 (ACL interface), BC-04 (supporting), BC-05 (core, offline-first), BC-06 (supporting), BC-07 (generic), BC-08 (generic, terminal consumer)
- ACID requirements: Event aggregate (lifecycle state machine), InterviewScore (immutability), AuditEntry (append-only guaranteed)
- Eventual consistency tolerance: EventMetricsSnapshot, DeliveryRecord, interviewer Queue (Provisional state)
- Offline storage: CheckInRecord (kiosk-local until sync), KioskSession + SBDBlock, OfflineSyncQueue
- Key NFRs: 1,000 concurrent users, kiosk <5s P95 local ops, HM dashboard <5s real-time, offline-first kiosk, Vietnam data residency
- Integration surface: xTalent RBAC (sync), Job Request API (sync), Email Delivery Service (async + webhook), Assessment Engine (ACL, TBD)
- Risks to carry into architecture: SBD block exhaustion under high kiosk load, Assessment build/integrate decision still open, KitLink validity in browser tabs opened before expiry, bulk operation concurrency locking on EventSchedule
