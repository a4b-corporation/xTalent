# ECR Container Diagram — C4 Level 2

## xTalent HCM Solution | 2026-03-25

---

## ASCII Container Overview

```
  USERS
  ──────────────────────────────────────────────────────────────────────────────
  TA Coordinator │ Candidate │ Hiring Manager │ HR Analytics Lead
        │               │           │                │
        │               │           │                │                  Onsite Staff
        └───────────────┴───────────┴────────────────┘                      │
                                    │ HTTPS                                  │ Local UI
                                    ▼                                        ▼
  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐
  │  ECR Module (Vietnam Data Center)                                                            │
  │                                                                                              │
  │  ┌──────────────────────────────────────┐    ┌────────────────────────────────────────────┐ │
  │  │         API Gateway                  │    │        Kiosk Application                   │ │
  │  │  NGINX / Kong                        │    │  Electron / PWA (device-local)             │ │
  │  │  - TLS termination                   │    │  - Offline-first check-in (QR/SBD/manual)  │ │
  │  │  - JWT validation → xTalent RBAC     │    │  - Walk-in registration                    │ │
  │  │  - Rate limiting per user/IP         │    │  - Embedded SQLite: CheckInRecord,         │ │
  │  │  - Routes to ECR Core API            │    │    KioskSession, SBDBlock, SyncQueue       │ │
  │  │  - Exposes Webhook Receiver path     │    │  - SBDBlock pre-allocated at session start │ │
  │  └──────────────────┬───────────────────┘    │  - Sync on reconnect → API Gateway         │ │
  │                     │ HTTP/gRPC (internal)    └──────────────────────────────────────────── ┘ │
  │                     ▼                                                                       │
  │  ┌──────────────────────────────────────────────────────────────────────────────────────┐  │
  │  │                             ECR Core API                                              │  │
  │  │  Node.js / Java Spring Boot (stateless, horizontally scaled)                          │  │
  │  │                                                                                       │  │
  │  │  BC-01 Event Management  │  BC-02 Candidate Registration  │  BC-04 Schedule & Cap.   │  │
  │  │  BC-05 Onsite Ops (srv)  │  BC-06 Interview Management    │  BC-07 Communication     │  │
  │  │  BC-08 Analytics & Audit                                                              │  │
  │  └────────┬─────────────────────────────────────────────────┬──────────────────────────┘  │
  │           │ write/read                                       │ publish / subscribe          │
  │           │                                                  │                              │
  │     ┌─────┴──────────────────────────┐          ┌───────────┴──────────────────────────┐  │
  │     │  Operational Database           │          │   Pub/Sub Backbone                   │  │
  │     │  PostgreSQL primary + replicas  │          │   Apache Kafka                       │  │
  │     │                                 │          │                                      │  │
  │     │  BC-01: events, tracks          │          │  Topics:                             │  │
  │     │  BC-02: registrations, sbd,     │          │  ecr.event-management                │  │
  │     │         dup_flags, waitlist     │          │  ecr.candidate-registration          │  │
  │     │  BC-04: schedules, slots,       │          │  ecr.schedule-capacity               │  │
  │     │         rooms, allocation_runs  │          │  ecr.onsite-operations               │  │
  │     │  BC-06: sessions, scores,       │          │  ecr.interview-management            │  │
  │     │         kit_links               │          │  ecr.communication                   │  │
  │     │  BC-07: comm_jobs, templates,   │          │  ecr.assessment                      │  │
  │     │         delivery_records        │          │                                      │  │
  │     │  (read replicas → dashboards)   │          │  At-least-once; idempotent consumers │  │
  │     └─────────────────────────────────┘          └────────┬─────────────────────────────┘  │
  │                                                           │                                 │
  │     ┌──────────────────────┐  ┌───────────────────────┐  │  ┌────────────────────────────┐ │
  │     │    Audit Store       │  │ Metrics / Snapshot    │  │  │  Assessment ACL Adapter    │ │
  │     │  PostgreSQL          │  │    Store              │  │  │  Node.js microservice      │ │
  │     │  (append-only)       │  │  Redis + PostgreSQL   │  │  │                            │ │
  │     │                      │  │                       │  │  │  BC-03: ACL pattern        │ │
  │     │  AuditEntry (BC-08)  │  │  Redis: real-time     │  │  │  Translates ECR ↔ external │ │
  │     │  hash chain writes   │  │  counters (< 1s)      │  │  │  assessment engine format  │ │
  │     │  write-once, no DEL  │  │                       │  │  │                            │ │
  │     │  3-year retention    │  │  PostgreSQL:          │  │  │  Deployed standalone to    │ │
  │     │                      │  │  hourly/daily         │  │  │  minimize blast radius     │ │
  │     │  Separate instance   │  │  snapshots            │  │  │  from vendor changes       │ │
  │     │  from op_db          │  │                       │  │  │                            │ │
  │     │                      │  │  HM dashboard SLA     │  │  │  [DEFERRED — contract      │ │
  │     │                      │  │  < 5s P95 (NFR-03)    │  │  │   fixed, impl TBD]         │ │
  │     └──────────────────────┘  └───────────────────────┘  │  └────────────────────────────┘ │
  │                                                           │                                 │
  │     ┌──────────────────────────────┐                      │                                 │
  │     │       Email Worker           │◄─────────────────────┘                                 │
  │     │  Node.js worker              │  Consumes: CommunicationJobCreated,                    │
  │     │  - Renders templates         │            SessionDigestDispatched                     │
  │     │  - Rate limiter: 500/min     │                                                        │
  │     │    (token bucket, Redis)     │  ┌──────────────────────────────┐                      │
  │     │  - Dispatch to Email Svc     │  │     Webhook Receiver         │                      │
  │     │  - Retry / escalation        │  │  Node.js HTTP service        │                      │
  │     └──────────────────────────────┘  │  - Accepts delivery callbacks│                      │
  │                                       │  - Validates HMAC signature  │                      │
  │                                       │  - Publishes EmailDelivered/ │                      │
  │                                       │    EmailFailed to Pub/Sub    │                      │
  │                                       └──────────────────────────────┘                      │
  └──────────────────────────────────────────────────────────────────────────────────────────────┘
                    │                                    │                          │
                    ▼                                    ▼                          ▼
        ┌───────────────────────┐         ┌──────────────────────────┐  ┌───────────────────────┐
        │   xTalent Platform    │         │  Email Delivery Service  │  │   Assessment Engine   │
        │                       │         │  (AWS SES / SendGrid)    │  │   (External, TBD)     │
        │  RBAC: Sync HTTPS     │         │  - Receives bulk payloads│  │                       │
        │  (all 8 BCs via GW)   │         │  - 500 msg/min inbound   │  │  ACL Adapter bridges  │
        │                       │         │  - Sends delivery/bounce │  │  ECR ↔ vendor model   │
        │  Job Req API: Sync    │         │    callbacks to Webhook  │  │                       │
        │  (BC-01 only)         │         │    Receiver (HTTPS POST) │  │  [Deferred]           │
        └───────────────────────┘         └──────────────────────────┘  └───────────────────────┘
```

---

## Container Descriptions

### 1. API Gateway

| Attribute | Detail |
|-----------|--------|
| Technology | NGINX or Kong |
| Responsibility | TLS termination; JWT validation (delegates to xTalent RBAC); rate limiting per user/IP; routes to ECR Core API; exposes Webhook Receiver endpoint path |
| Deployment | Min 2 instances behind load balancer; stateless |
| NFR | Supports 1,000 concurrent users (NFR-01) |
| DDD Relationship | Enforces Conformist relationship to xTalent RBAC on every authenticated request |

### 2. ECR Core API

| Attribute | Detail |
|-----------|--------|
| Technology | Node.js or Java Spring Boot |
| Responsibility | Business logic for all 8 BCs (except kiosk device-local ops). Domain command handlers, aggregate state machines, domain event publishing, inter-BC event subscriptions |
| Deployment | Horizontally scaled, stateless. Min 3 instances in production |
| Storage | Reads/writes Operational DB (primary); reads from read replicas for dashboards/reports |
| Events | Kafka producer (all domain events); Kafka consumer (per-BC subscriptions) |
| NFR | Horizontal scaling satisfies NFR-01 |

### 3. Assessment ACL Adapter

| Attribute | Detail |
|-----------|--------|
| Technology | Node.js microservice (standalone container) |
| Responsibility | BC-03: translates ECR domain objects (CandidateEventRegistrationRef, BlueprintID) to external assessment engine format; ingests AssessmentResult; emits ECR domain events; shields ECR from vendor model changes |
| Deployment | Separate container — swappable per vendor without modifying ECR Core API |
| Trigger | Subscribes to `CandidateConfirmed` and `CheckInConfirmed` from Pub/Sub |
| Status | DEFERRED — container exists; internal model and vendor TBD |
| Pattern | Anti-Corruption Layer (ACL) |

### 4. Pub/Sub Backbone

| Attribute | Detail |
|-----------|--------|
| Technology | Apache Kafka (or AWS MSK / Azure Event Hubs — Kafka-compatible) |
| Responsibility | Primary integration mechanism between all BCs. At-least-once delivery; consumers enforce idempotency via `domain_event_id` deduplication |
| Topics | `ecr.event-management`, `ecr.candidate-registration`, `ecr.schedule-capacity`, `ecr.onsite-operations`, `ecr.interview-management`, `ecr.communication`, `ecr.assessment` |
| Consumer Groups | One group per BC subscription; `ecr-audit` subscribes to ALL topics |
| Retention | 7-day message retention (long-term in Audit Store) |
| NFR | Supports NFR-03 (< 5s HM dashboard) via in-memory Redis projection on check-in events |

### 5. Operational Database

| Attribute | Detail |
|-----------|--------|
| Technology | PostgreSQL 15+ |
| Responsibility | ACID storage for all operational aggregates across BC-01, BC-02, BC-04, BC-06, BC-07 |
| Deployment | Primary + 1-2 read replicas (read replicas serve dashboard and report queries) |
| Isolation | Separate schema per BC (logical isolation; single cluster for MVP) |
| Note | CheckInRecord and KioskSession reside on kiosk device (SQLite); promoted to operational DB on sync |

### 6. Audit Store

| Attribute | Detail |
|-----------|--------|
| Technology | PostgreSQL (append-only with DB trigger preventing UPDATE/DELETE) |
| Responsibility | BC-08 AuditEntry persistence. Append-only, hash-chained, tamper-evident |
| Hash Chain | `chain_hash = SHA256(prev_chain_hash + content_hash)`. Sequential writes enforce chain integrity |
| Retention | 3-year minimum via infrastructure archival policy (NFR-10) |
| Isolation | Separate DB instance — prevents operational DB load from impacting audit write latency |
| Scaling Note | Per-event chain isolation under evaluation (R-05): one sub-chain per `ecr_event_id` |

### 7. Metrics / Snapshot Store

| Attribute | Detail |
|-----------|--------|
| Technology | Redis (real-time) + PostgreSQL (snapshot persistence) |
| Responsibility | BC-08 EventMetricsSnapshot projections for HM dashboard and analytics |
| Real-Time Path | Redis counters updated by Kafka consumer on every relevant domain event. Sub-second latency satisfies NFR-03 |
| Snapshot Path | Background job writes hourly/daily snapshots to PostgreSQL for historical queries |
| Rebuild | Entire store can be rebuilt from Audit Store event log at any time |

### 8. Email Worker

| Attribute | Detail |
|-----------|--------|
| Technology | Node.js worker process |
| Responsibility | BC-07: consumes `CommunicationJobCreated` from Pub/Sub; renders templates; enforces 500 msg/min token bucket rate limiter; dispatches to Email Delivery Service; handles retry with exponential backoff |
| Rate Limiter | Token bucket at 500 tokens/minute; Redis-backed distributed counter for horizontal scaling |
| Deployment | Horizontally scalable workers |

### 9. Webhook Receiver

| Attribute | Detail |
|-----------|--------|
| Technology | Node.js HTTP service |
| Responsibility | Accepts inbound delivery/bounce callbacks from Email Delivery Service; validates HMAC-SHA256 signature; publishes `EmailDelivered` / `EmailFailed` to Pub/Sub |
| Isolation | Separate from Core API — isolates external vendor callback traffic |

### 10. Kiosk Application

| Attribute | Detail |
|-----------|--------|
| Technology | Electron (desktop) or PWA (Chrome in kiosk mode) |
| Responsibility | BC-05 device-local: check-in (QR scan, SBD lookup, manual entry), walk-in registration, offline SBD generation from pre-allocated block |
| Embedded Store | SQLite: `checkin_records_local`, `kiosk_sessions_local`, `sbd_blocks_local`, `offline_sync_queue` |
| SBDBlock | Pre-allocated block of 100 SBD numbers assigned at session start. Near-exhaustion (< 10 remaining) flags re-allocation request on next sync |
| Sync Protocol | Ordered FIFO queue; atomic per record; failed records → ManualReviewQueue; never silently discarded |
| NFR | All local ops < 5s P95 (NFR-04); never blocks on network |

---

## Communication Paths

| Path | Pattern | Protocol | SLA / Notes |
|------|---------|----------|-------------|
| User → API Gateway | Request/Response | HTTPS TLS 1.3 | < 500ms P95 |
| API Gateway → xTalent RBAC | Request/Response | Sync HTTPS | < 100ms P95; circuit-breaker at 200ms |
| API Gateway → ECR Core API | Request/Response | HTTP/1.1 or gRPC (internal) | < 200ms P95 |
| ECR Core API → Pub/Sub | Async publish | Kafka produce (acks=all) | < 50ms produce latency |
| Pub/Sub → BC Consumers | Async subscribe | Kafka consume | < 1s end-to-end delivery |
| Pub/Sub → Email Worker | Async subscribe | Kafka consume | 500/min dispatch cap |
| Email Worker → Email Service | Fire-and-forget | Async HTTPS | Rate-limited 500/min |
| Email Service → Webhook Receiver | Callback | HTTPS POST | Vendor SLA; HMAC verified |
| Webhook Receiver → Pub/Sub | Async publish | Kafka produce | < 50ms |
| Kiosk → API Gateway (sync) | Request/Response | HTTPS | On reconnect only; non-blocking |
| Core API → Operational DB | Request/Response | PostgreSQL wire | < 20ms P95 |
| Core API → Audit Store | Append | PostgreSQL wire (sequential) | < 50ms per write |
| Pub/Sub → Metrics Store | Async projection | Kafka → Redis | < 1s (satisfies NFR-03 5s budget) |

---

## Kafka Topic Map

| Topic | Published By | Consumed By |
|-------|-------------|-------------|
| `ecr.event-management` | BC-01 | BC-02, BC-04, BC-05, BC-06, BC-07, BC-08 |
| `ecr.candidate-registration` | BC-02 | BC-04, BC-05, BC-06, BC-07, BC-08 |
| `ecr.schedule-capacity` | BC-04 | BC-02, BC-05, BC-06, BC-07, BC-08 |
| `ecr.onsite-operations` | BC-05 | BC-06, BC-08, Metrics Store |
| `ecr.interview-management` | BC-06 | BC-07, BC-08, Metrics Store |
| `ecr.communication` | BC-07 | BC-08 |
| `ecr.assessment` | BC-03 ACL Adapter | BC-06, BC-08 |

---

## DDD Relationship Map

| From | To | Pattern | Notes |
|------|----|---------|-------|
| xTalent RBAC | All 8 BCs | Conformist | ECR adopts RBAC model; no custom auth |
| xTalent Job Req API | BC-01 | Customer-Supplier | BC-01 links tracks to requisitions |
| BC-01 | BC-02, BC-04, BC-05, BC-06, BC-07, BC-08 | Open Host Service | Publishes domain events to Pub/Sub |
| BC-02 | BC-04, BC-05, BC-06, BC-07, BC-08 | Open Host Service | Publishes domain events to Pub/Sub |
| BC-03 | External Assessment Engine | Anti-Corruption Layer | ACL Adapter as standalone container |
| BC-04 | BC-02, BC-06, BC-07, BC-08 | Open Host Service | Slot allocation events trigger downstream |
| BC-05 | BC-06, BC-08 | Open Host Service | Check-in events feed interview queue |
| BC-06 | BC-07, BC-08 | Open Host Service | Score submission triggers comms + audit |
| BC-07 | BC-08, Email Delivery Service | Open Host Service + Async Webhook | Delivery status fed back via webhook |
| BC-08 | (terminal — no downstream) | — | Audit + metrics only |

---

## Offline Kiosk Sync Protocol

```
[Kiosk Device — SQLite]                          [ECR Core API — PostgreSQL]
        │                                                    │
  1.    │── POST /kiosk/sessions ──────────────────────────►│  (session start, online)
        │◄─ { sessionId, sbdBlock: {start, end} } ──────────│  (SBDBlock pre-allocated)
        │                                                    │
  2.    │  [Network lost — offline mode]                     │
        │  - All check-ins against local SQLite              │
        │  - SBD generated from pre-allocated block          │
        │  - Records enqueued to offline_sync_queue          │
        │                                                    │
  3.    │  [Network restored OR operator-initiated sync]     │
        │── POST /kiosk/sessions/{id}/sync ───────────────►  │  (ordered batch upload)
        │   { records: [...] }                               │
        │◄─ { accepted: [...], conflicts: [...] } ──────────│
        │                                                    │
  4.    │  [Conflict handling]                               │
        │  - Accepted: CheckInRecord promoted to SYNCED      │
        │  - Conflicts: → ManualReviewQueue (never lost)     │
        │                                                    │
  5.    │  [SBD near-exhaustion < 10 remaining]              │
        │── POST /kiosk/sessions/{id}/request-sbd-block ──► │
        │◄─ { newBlock: {start, end} } ─────────────────────│
```

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Offline-first — never block on network | NFR-04: local ops < 5s P95 |
| SBD pre-allocation in blocks (100/block) | Eliminates inter-kiosk SBD conflicts without server coordination |
| Re-allocation at < 10 remaining | Prevents SBD exhaustion under high kiosk load |
| Provisional state until sync confirmed | Offline data is provisional; still visible in HM queue |
| Atomic sync per record | No silent data loss; conflicts route to ManualReviewQueue |
| Power-loss-safe sync queue | SQLite WAL mode; queue survives crash |
