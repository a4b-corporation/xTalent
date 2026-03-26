# Step 3 to Step 4 Handoff: Domain Architecture → Solution Architecture
## ECR Module — Event-Centric Recruitment
## Handoff Date: 2026-03-25

---

## Input Summary

**Step 3 produced:**
- 8 Bounded Context definitions (bounded-contexts.md)
- 8 Glossaries (ubiquitous language per BC)
- 8 LinkML schemas (machine-validatable domain models)
- 13 Use case flow documents (covering all major operational scenarios)

**Total aggregates modeled:** 21 aggregate roots across 8 BCs
**Total domain events defined:** 47 (see per-BC models)
**Open questions resolved:** 5 (OQ-D1 through OQ-D5)
**Open questions carried forward:** Assessment build/integrate decision (BC-03 internal model deferred)

---

## Bounded Context Inventory

| ID | Name | Directory | Type | Key Aggregates |
|----|------|-----------|------|---------------|
| BC-01 | Event Management | `domain/event-management/` | Core Domain | Event, Track, RegistrationForm |
| BC-02 | Candidate Registration | `domain/candidate-registration/` | Core Domain | CandidateEventRegistration, WaitlistEntry, DuplicateFlag |
| BC-03 | Assessment | `domain/assessment/` | Interface Boundary (ACL) | None (contract only) |
| BC-04 | Schedule & Capacity | `domain/schedule-capacity/` | Supporting Domain | EventSchedule, ScheduleSlot, AllocationRun |
| BC-05 | Onsite Operations | `domain/onsite-operations/` | Core Domain | CheckInRecord, KioskSession, OfflineSyncQueue |
| BC-06 | Interview Management | `domain/interview-management/` | Supporting Domain | InterviewSession, InterviewScore, ScoreEditRequest |
| BC-07 | Communication | `domain/communication/` | Generic Supporting | CommunicationJob, EmailTemplate, DeliveryRecord |
| BC-08 | Analytics & Audit | `domain/analytics-audit/` | Generic Supporting | AuditEntry, EventMetricsSnapshot, ReportDefinition |

---

## Context Map

```
Domain Classification:
  Core Domain    : BC-01 (Event Management), BC-02 (Candidate Registration), BC-05 (Onsite Operations)
  Supporting     : BC-04 (Schedule & Capacity), BC-06 (Interview Management)
  Generic        : BC-07 (Communication), BC-08 (Analytics & Audit)
  ACL Interface  : BC-03 (Assessment — build/integrate TBD)

Integration Pattern Map:
  xTalent RBAC Service  ──Conformist──────► All 8 BCs
  xTalent Job Req API   ──Customer-Supplier► BC-01 (Event Management)
  BC-01                 ──Open Host Svc────► BC-02, BC-04, BC-05, BC-06, BC-07, BC-08
  BC-02                 ──Open Host Svc────► BC-04, BC-05, BC-06, BC-07, BC-08
  BC-03                 ──ACL──────────────► External Assessment Engine (vendor TBD)
  BC-04                 ──Open Host Svc────► BC-02, BC-06, BC-07, BC-08
  BC-05                 ──Open Host Svc────► BC-06, BC-08
  BC-06                 ──Open Host Svc────► BC-07, BC-08
  BC-07                 ──Open Host Svc────► BC-08
  BC-07                 ──Async+Webhook────► External Email Delivery Service
  BC-08                 ──terminal consumer (no downstream)
```

---

## Persistence Requirements

### ACID Required (Strong Consistency)

| Aggregate | BC | Rationale |
|-----------|-----|-----------|
| Event | BC-01 | Lifecycle state machine must be serialized; structural lock on EventStarted is a critical invariant |
| CandidateEventRegistration | BC-02 | SBD uniqueness guarantee; duplicate flag creation must be atomic with registration |
| InterviewScore | BC-06 | Immutability enforced at write; no concurrent score creation for same (session, candidate, interviewer) triple |
| ScoreEditRequest | BC-06 | Approval state machine; exactly-once approval processing |
| AuditEntry | BC-08 | Append-only + hash chain integrity; chain_hash must be computed atomically with the previous entry read |

### Eventual Consistency Acceptable

| Aggregate / Projection | BC | Rationale |
|-----------------------|-----|-----------|
| EventMetricsSnapshot | BC-08 | Computed read model; can be rebuilt from AuditEntry at any time |
| DeliveryRecord | BC-07 | Delivery status updated asynchronously via webhooks; temporary staleness acceptable |
| Interviewer Queue | BC-06 | Provisional state explicitly signals unconfirmed data; eventual promotion via CheckInConfirmed |
| AllocationRun | BC-04 | Algorithm is idempotent; re-execution produces same result |

### Offline-First Storage (Kiosk Tier)

| Aggregate | BC | Requirement |
|-----------|-----|-------------|
| CheckInRecord | BC-05 | Created offline on kiosk device; Provisional until server sync confirms |
| KioskSession | BC-05 | Persists SBDBlock assignment and OfflineSyncQueue locally during offline mode |
| OfflineSyncQueue | BC-05 | Durable ordered queue on kiosk device; survives power loss |

---

## Integration Contracts

### xTalent RBAC Service (Upstream, Synchronous)
- Pattern: Conformist — ECR adopts RBAC model as-is
- Call type: Synchronous HTTP (token introspection + permission check)
- All 8 BCs validate roles against this service
- Key permissions: `ecr.event.publish`, `ecr.registration.manage`, `ecr.interview.dispatch_digest`, `ecr.communication.send_bulk`, `ecr.audit.view`
- Dependency: ECR cannot operate without RBAC; circuit-breaker required for resilience

### xTalent Job Request API (Upstream, Synchronous)
- Pattern: Customer-Supplier — ECR negotiates track-to-requisition linking requirements
- Call type: Synchronous HTTP (on Track creation/update)
- Consumer: BC-01 (Event Management) only
- Contract: ECR provides trackId, receives requisitionRef back

### External Email Delivery Service (Async, Webhook Callback)
- Pattern: Fire-and-forget outbound + inbound delivery webhook
- Consumer: BC-07 (Communication)
- Rate limit: 500 outbound messages/minute (NFR-07)
- Webhook endpoint: ECR exposes a webhook receiver; delivery service POSTs delivery/bounce confirmations
- Failure handling: exponential backoff retry; escalation after max_attempts exhausted; never silent

### External Assessment Engine (ACL Interface — Deferred)
- Pattern: ACL — Anti-Corruption Layer shields ECR from external model
- Consumer: BC-03 (Assessment)
- Current status: Build/integrate decision unresolved; internal model not defined
- Contract (fixed, regardless of vendor/build):
  - IN: (CandidateEventRegistrationRef, BlueprintID, DeliveryContext)
  - OUT: AssessmentResult { candidateRef, blueprintId, completedAt, score, passed, rawData }
- Guard: only Confirmed or CheckedIn candidates may receive assessment dispatches (BR-07)

---

## NFR Constraints for Architecture

| NFR-ID | Constraint | Architecture Implication |
|--------|-----------|------------------------|
| NFR-01 | 1,000 concurrent users | Horizontal scaling required for API tier; read replicas for dashboard queries |
| NFR-03 | HM dashboard update < 5s P95 | Event-driven pub/sub with in-memory projection on Interview Management; no polling |
| NFR-04 | Kiosk local operations < 5s P95 | Offline-first architecture; all check-in ops against local store, never blocking on network |
| NFR-07 | Bulk email max 500/minute | Rate limiter in Communication BC sending engine; queued dispatch |
| NFR-09 | Vietnam data residency | All PII stored in Vietnam-region infrastructure only; no cross-border data transfer |
| NFR-10 | 3-year audit retention | Append-only audit store with TTL/archival policy enforced at infrastructure |

---

## Recommended C4 Start Point

**System Context Diagram first**, then drill to Container Diagram.

Recommended Container focus areas:
1. **Offline Kiosk Container** — the device-local application with its own SQLite/embedded store and SBDBlock management. Must be modeled as a distinct container with explicit sync boundary, not merely a thin client.
2. **Event-Driven Pub/Sub Backbone** — the message broker (e.g., Kafka or equivalent) that connects all 8 BCs. All domain event flows pass through this backbone. It is the primary integration mechanism; the Container diagram must show it explicitly.
3. **Audit Store** — a separate append-only store (distinct from the operational DB) with hash-chain write support. Should be modeled as its own container with explicit write-once semantics.
4. **Assessment ACL Adapter** — a dedicated adapter container (not merely a library) that translates between ECR domain objects and the external assessment engine's protocol. This isolation is what makes the ACL pattern real in the architecture.

---

## Risks Carried Forward

| Risk ID | Description | Severity | Mitigation Status |
|---------|-------------|----------|------------------|
| R-01 | SBD block exhaustion under high kiosk load | High | Mitigated by pre-emptive re-allocation at < 10 remaining; design the re-allocation request path before architecture is finalized |
| R-02 | Assessment build/integrate decision still open | High | BC-03 is modeled as ACL contract; internal model deferred. Architecture must not pre-commit to a specific vendor or build approach |
| R-03 | KitLink validity in browser tabs opened before expiry | Medium | Server validates on every request (BR-05); tab open before expiry but used after expiry returns 403. UX implication: interviewers should be warned before expiry |
| R-04 | Bulk operation concurrency locking on EventSchedule | Medium | AllocationRun is idempotent but requires exclusive lock on EventSchedule during execution; concurrent allocation runs for the same event must be serialized |
| R-05 | Audit store write latency under peak load | Low | Hash chain requires sequential writes; audit store cannot be horizontally partitioned without segmenting the chain. Evaluate per-event chain isolation as a scaling approach |

---

## Artifacts for Step 4 Review

All domain artifacts are in `domain/` relative to the module root. The bounded-contexts.md is the entry point. Each BC directory contains glossary.md (ubiquitous language), model.linkml.yaml (machine-validatable schema), and flows/ (use case documentation).

Step 4 (Solution Architecture) should read:
1. `domain/bounded-contexts.md` — full context map and BC inventory
2. LinkML schemas for ACID aggregates (BC-01, BC-02, BC-06, BC-08) — to understand state machines and invariants
3. `domain/onsite-operations/flows/offline-sync.flow.md` — to understand the offline sync complexity before designing the kiosk container
4. `domain/analytics-audit/flows/audit-trail.flow.md` — to understand the hash chain constraint before designing the audit store
