# ECR System Context Map — C4 Level 1

## System: Event-Centric Recruitment (ECR) | xTalent HCM Solution | 2026-03-25

ECR is a core module of the xTalent platform. It manages the complete lifecycle
of mass recruitment events — from event creation and candidate registration through
onsite check-in, interview scoring, communication, and post-event analytics.
All PII and operational data are stored within Vietnam data centers (NFR-09).

---

## ASCII System Context Diagram

```
                          ┌──────────────────────────────────────────────────────────────────┐
                          │                    VIETNAM DATA CENTER                            │
                          │              (All PII · All Persistent Storage)                   │
                          │                                                                    │
  ┌─────────────────┐     │  ┌──────────────────────────────────────────────────────────────┐ │
  │  TA Coordinator │─────┼─►│                                                              │ │
  │  (Recruiter)    │     │  │          Event-Centric Recruitment (ECR)                     │ │
  └─────────────────┘     │  │                                                              │ │
                          │  │  Orchestrates mass recruitment events end-to-end:             │ │
  ┌─────────────────┐     │  │  - Event lifecycle management (Draft → Archived)             │ │
  │   Candidate     │─────┼─►│  - Candidate registration, SBD assignment, waitlist          │ │
  │                 │     │  │  - Schedule building & capacity allocation                   │ │
  └─────────────────┘     │  │  - Onsite check-in (offline-first kiosk)                    │ │
                          │  │  - Interview session management & immutable scoring           │ │
  ┌─────────────────┐     │  │  - Bulk email communications                                 │ │
  │ Hiring Manager  │─────┼─►│  - Real-time HM dashboard (< 5s P95)                        │ │
  │     (HM)        │     │  │  - Append-only audit log (hash chain, 3-year retention)      │ │
  └─────────────────┘     │  │                                                              │ │
                          │  │  8 Bounded Contexts · 1,000 concurrent users (NFR-01)        │ │
  ┌─────────────────┐     │  │                                                              │ │
  │  Onsite Staff   │─────┼─►│                                                              │ │
  │  (Kiosk Ops)    │     │  └────────────────────┬─────────────────────────────────────────┘ │
  └─────────────────┘     │                       │                                            │
                          └───────────────────────┼────────────────────────────────────────────┘
                                                  │
                 ┌────────────────────────────────┼──────────────────────────────────────┐
                 │                                │                                      │
                 ▼                                ▼                                      ▼
  ┌──────────────────────────┐  ┌────────────────────────────┐  ┌───────────────────────────────┐
  │    xTalent Platform      │  │   Email Delivery Service   │  │   Assessment Engine           │
  │                          │  │                            │  │   [DEFERRED — ACL boundary]   │
  │  RBAC & identity:        │  │  - Transactional/bulk SMTP │  │                               │
  │    conformist (all 8 BCs)│  │  - 500 msg/min rate limit  │  │  - External assessment        │
  │                          │  │  - Delivery webhooks       │  │    platform (vendor TBD)      │
  │  Job Request API:        │  │    (delivered / bounced)   │  │  - Returns scored results     │
  │    customer-supplier     │  │                            │  │  - ACL adapter insulates ECR  │
  │    (BC-01 only)          │  │  [Async + Webhook]         │  │                               │
  │                          │  │                            │  │  [ACL Adapter — BC-03]        │
  │  [Sync HTTP]             │  │                            │  │  [Vendor decision deferred]   │
  └──────────────────────────┘  └────────────────────────────┘  └───────────────────────────────┘
```

---

## User Types

| Actor | Role | Primary Interactions with ECR |
|-------|------|-------------------------------|
| TA Coordinator | Recruiter owning the event lifecycle | Create events, manage tracks, build schedule, manage registrations, trigger bulk comms, dispatch interview digests, view analytics |
| Candidate | Job applicant attending a recruitment event | Self-register online, receive notifications (invitation, slot, assessment), check in onsite |
| Hiring Manager (HM) | Decision-maker conducting interviews | Receive Session Digest via email KitLink (no ECR login required), view live candidate queue, submit interview scores |
| Onsite Staff | Event-day kiosk operators | Capture walk-in registrations, perform QR/SBD check-in (works offline), manage manual review queue |

---

## External Systems

| System | Integration Pattern | Boundary Type | Direction | Notes |
|--------|---------------------|---------------|-----------|-------|
| xTalent Platform — RBAC | Synchronous HTTP (token introspection) | Conformist | ECR → xTalent | ECR adopts xTalent RBAC model as-is. No custom permission model. Circuit-breaker required (P0 dependency). |
| xTalent Platform — Job Request API | Synchronous HTTP | Customer-Supplier | xTalent → BC-01 | BC-01 (Event Management) links tracks to requisitions. Freeform track allowed if unavailable. |
| Email Delivery Service | Async publish + inbound webhook | Open Host Service | BC-07 ↔ External | BC-07 enqueues jobs, receives delivery callbacks. Rate-limited at 500 msg/min. Exponential backoff retry on failure. |
| Assessment Engine | ACL Adapter (deferred) | Anti-Corruption Layer | BC-03 ↔ External | BC-03 is a pure ACL interface; ECR domain insulated from vendor model. Build vs. integrate decision pending. |

---

## System Boundary

### Inside ECR

| Component | Bounded Context | Description |
|-----------|----------------|-------------|
| Event lifecycle management | BC-01 | Create, publish, open-registration, start, close, clone, archive events |
| Candidate registration | BC-02 | Online portal, kiosk (online + offline), walk-in capture, SBD generation, duplicate detection, waitlist |
| Assessment ACL interface | BC-03 | Anti-corruption layer adapter; internal model deferred; contract fixed |
| Schedule & capacity | BC-04 | Room-shift matrix, slot allocation, waitlist backfill, invite dispatch |
| Onsite operations | BC-05 | QR/SBD check-in, offline-first kiosk, sync queue, conflict resolution, manual review |
| Interview management | BC-06 | Session config, interviewer assignment, digital kit (KitLink 24h expiry), score submission, edit workflow |
| Communication | BC-07 | Bulk email dispatch, template management, delivery tracking, retry/escalation |
| Analytics & audit | BC-08 | Append-only audit log (hash chain), metrics snapshots, custom reports |

### Outside ECR (Upstream Platform)

| Component | Description |
|-----------|-------------|
| xTalent RBAC Service | User identity, roles, permissions — ECR is conformist |
| xTalent Job Request API | Job requisitions — BC-01 links tracks to requisitions |

### Outside ECR (External Services)

| Component | Description |
|-----------|-------------|
| Email Delivery Service | Bulk email provider — ECR dispatches and receives delivery webhooks |
| Assessment Engine | Candidate assessment — ECR sends candidate refs, receives scored results |
| Vietnam Data Center | All storage infrastructure — ECR data never leaves this boundary |

---

## Integration Patterns Summary

| Pattern | Applied To | Rationale |
|---------|-----------|-----------|
| Conformist | xTalent RBAC → All 8 BCs | ECR cannot define its own identity/permission model; adopts upstream as-is |
| Customer-Supplier | xTalent Job Req API → BC-01 | BC-01 negotiates its needs but xTalent controls the API |
| Anti-Corruption Layer (ACL) | BC-03 ↔ Assessment Engine | Shields ECR domain from vendor model volatility; vendor is TBD |
| Open Host Service + Async Webhook | BC-07 ↔ Email Delivery Service | Async fire-and-forget for bulk dispatch; webhook for delivery callbacks |
| Published Language (Domain Events) | All 8 BCs via Pub/Sub backbone | BCs communicate via named domain events on Kafka topics |

---

## Key NFRs at System Level

| NFR ID | Requirement | Architectural Response |
|--------|-------------|------------------------|
| NFR-01 | 1,000 concurrent users | Stateless horizontally-scalable API tier; Pub/Sub backbone |
| NFR-03 | HM dashboard update < 5s P95 | In-memory projection store (Redis); event-driven update on check-in events |
| NFR-04 | Kiosk local ops < 5s P95 | Offline-first kiosk; embedded SQLite; never blocks on network |
| NFR-07 | Bulk email max 500/min | Rate-limited email worker (token bucket); distributed Redis counter |
| NFR-09 | Vietnam data residency — all PII | All storage within Vietnam DC; assessment vendor must support VN residency |
| NFR-10 | 3-year audit retention | Separate append-only audit store; hash chain; infrastructure archival policy |
