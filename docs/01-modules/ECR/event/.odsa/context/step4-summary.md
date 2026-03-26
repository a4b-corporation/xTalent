# Step 4 Summary: Solution Architecture
*ECR Module | xTalent HCM Solution | Completed: 2026-03-26*

---

## What Was Produced

| Artifact | Path | Description |
|----------|------|-------------|
| C4 Level 1 | `architecture/context-map-l1.md` | System context: ECR, 4 actors, 3 external systems (xTalent Platform, Email Delivery Service, Assessment Engine), integration patterns, NFR coverage |
| C4 Level 2 | `architecture/context-map-l2.md` | Container diagram: 10 containers within Vietnam DC, Kafka topic map, DDD relationship map, offline kiosk sync protocol |
| Database Schema | `architecture/db.dbml` | DBML for PostgreSQL operational DB — all tables across BC-01, BC-02, BC-04, BC-05, BC-06, BC-07; enums; FK constraints; indexes; SQLite kiosk tables documented as comments; Audit Store documented separately |
| Use-Case API | `architecture/api-usecase.openapi.yaml` | OpenAPI 3.0 — 27 endpoints derived from flow intent (business-verb naming); organized by BC; all schemas derived from LinkML |
| Domain API | `architecture/api-domain.openapi.yaml` | OpenAPI 3.0 — CRUD endpoints for all aggregate roots across 8 BCs; resource-noun naming; complements use-case API without overlap |
| Event Repository | `architecture/events.yaml` | 54 domain events across 8 BCs (EVT-001 to EVT-054); each with payload, consumers, producers, stability classification, Event Storming cross-reference |

---

## Architecture Decisions Made

### Container Architecture

**10 containers** within a single Vietnam Data Center boundary.

- **API Gateway (NGINX/Kong)** chosen over embedding auth in Core API: cleanly separates infrastructure cross-cuts (TLS termination, JWT validation against xTalent RBAC, rate limiting) from business logic. All 8 BCs automatically inherit the Conformist RBAC relationship.
- **Apache Kafka** chosen for pub/sub backbone over direct BC-to-BC HTTP calls: decouples all 8 BCs from each other, provides at-least-once delivery with consumer-side idempotency, supports the `ecr-audit` consumer group that subscribes to all topics, and enables full event replay from retained messages for audit rebuild. 7 Kafka topics, one per producing BC.
- **Separate Audit Store** (append-only PostgreSQL, separate DB instance): isolates write-once semantics from operational DB so UPDATE/DELETE triggers cannot share schema with mutable tables; prevents operational DB load from impacting audit write latency; enables independent 3-year archival policy without operational DB retention constraints.
- **Offline-First Kiosk as distinct container**: Electron/PWA on device with embedded SQLite is a deployment-level decision. It is not a library — it runs independently without network, owns its own data store, and has a defined sync protocol (ordered FIFO, atomic per-record). Making it a distinct container makes the offline boundary explicit in the architecture and avoids treating it as a UI feature of the Core API.
- **Assessment ACL Adapter as standalone microservice container** (not a library inside Core API): BC-03 represents an Anti-Corruption Layer boundary. Deploying it as a separate container means ECR Core API is shielded from vendor model changes at deployment level (not just code level). The vendor is TBD; when the decision is made, only this container changes. The blast radius of a vendor swap is limited to one container.

### Database Design

- **PostgreSQL 15+** for all operational aggregates: ACID transactions required for SBD generation (unique constraint), slot allocation (capacity enforcement), duplicate flag resolution, and waitlist promotion. All these operations require row-level locking or serializable isolation.
- **Separate Audit Store instance**: append-only semantics enforced by DB trigger (no UPDATE/DELETE on `audit_entries`). Hash chain integrity (`SHA256(prev_chain_hash + content_hash)`) requires sequential writes; a separate instance guarantees this write path is not contended by operational writes. 3-year retention via infrastructure archival policy.
- **SQLite on kiosk device**: embedded in Electron/PWA, no network dependency. Stores `checkin_records_local`, `kiosk_sessions_local`, `sbd_blocks_local`, `offline_sync_queue`. WAL mode for power-loss safety. Records promoted to PostgreSQL on sync.
- **Read replicas for dashboard queries**: HM dashboard and analytics reports query read replicas (not primary) to avoid contention with write-heavy check-in and registration flows during event day.
- **Metrics/Snapshot Store** — Redis (real-time counters, sub-second) + PostgreSQL (hourly/daily snapshots): two-tier design satisfies NFR-03 (< 5s HM dashboard) without polling the operational DB.

### API Design

**Dual API strategy** — two separate OpenAPI specs that complement each other and do not overlap on paths:

- **Use-case API** (`api-usecase.openapi.yaml`) — 27 endpoints, business-intent naming derived directly from flow use cases: `publishEvent`, `allocateCandidatesToSlots`, `scanCheckIn`, `dispatchSessionDigest`, `submitInterviewScore`, `sendBulkCommunication`. Each endpoint corresponds to a command handler and emits one or more domain events. This is the API consumed by frontend applications and integrators with business workflows in mind.
- **Domain API** (`api-domain.openapi.yaml`) — standard CRUD for all aggregate roots (Event, Track, Registration, InterviewSession, CommunicationJob, etc.). This is used for data management tooling, admin operations, and any access pattern not covered by a named flow. Paths are resource-noun based (`/events/{id}`, `/registrations/{id}`).
- The separation prevents CRUD leakage into workflow endpoints and avoids business operations being expressed as raw resource mutations.

### Event Design

- 54 domain events cataloged from three sources: Event Storming (DE-01 to DE-54 cross-referenced), bounded context interaction patterns, and flow use cases.
- Events distributed across 8 BCs: BC-01 (9), BC-02 (12), BC-03 (5), BC-04 (6), BC-05 (7), BC-06 (9), BC-07 (5), BC-08 (1).
- Each event has: `domain_event_id` (UUID for idempotency), `occurred_at`, typed payload fields, producer, consumers, stability classification (`stable`, `volatile`, `deferred`), and Event Storming ES-ID reference.
- Events marked `deferred` (BC-03 Assessment): contract is fixed but implementation TBD.

---

## NFR Coverage

| NFR | Requirement | Architectural Response |
|-----|-------------|------------------------|
| NFR-01 | 1,000 concurrent users | Stateless ECR Core API (min 3 instances, horizontally scaled); stateless API Gateway (min 2 instances); Kafka consumer groups scale independently |
| NFR-03 | HM dashboard < 5s P95 | Redis counters updated by Kafka consumer on every relevant domain event (< 1s end-to-end); dashboard reads Redis, not primary DB |
| NFR-04 | Kiosk local ops < 5s P95 | Offline-first kiosk container; all local ops against SQLite; never blocks on network; SBD generated from pre-allocated block without server round-trip |
| NFR-07 | Bulk email max 500/min | Email Worker: token bucket rate limiter (500 tokens/min); Redis-backed distributed counter enables horizontal worker scaling while respecting global rate limit |
| NFR-09 | Vietnam data residency | All containers (API Gateway, Core API, Kafka, PostgreSQL, Redis, Audit Store, Kiosk) deployed within Vietnam Data Center. Assessment vendor must contractually support VN data residency (deferred constraint). |
| NFR-10 | 3-year audit retention | Separate append-only Audit Store; hash-chained AuditEntry; retention enforced by infrastructure archival policy; chain rebuild from stored events |

---

## Risks Addressed vs. Carried Forward

| Risk | Status | Architectural Response |
|------|--------|------------------------|
| R-01: SBD exhaustion under concurrent kiosk load | Addressed | Pre-allocated SBD blocks (100/block) assigned at session start. Near-exhaustion (< 10 remaining) triggers re-allocation request on next sync. Kiosk-to-kiosk conflicts eliminated because blocks are server-assigned ranges. |
| R-02: Assessment vendor decision not made | Carried forward (mitigated) | Architecture is vendor-neutral. ACL Adapter container exists with fixed ECR-side contract. Internal model and vendor TBD. When vendor is chosen, only BC-03 container changes; ECR Core API unchanged. |
| R-03: KitLink expiry mid-session | Addressed | `kit_link_expires_at` field on `interview_kits` table. `accessInterviewKit` endpoint validates expiry server-side on every request; returns 403 on expired link. 24-hour TTL modeled in domain schema. |
| R-04: Concurrent bulk allocation operations | Addressed | `EventSchedule` exclusive lock modeled in `allocateCandidatesToSlots` endpoint design. Allocation run tracked in `allocation_runs` table with `in_progress` state. Concurrent allocation on same event rejected with 409 Conflict. |
| R-05: Audit hash chain horizontal partition | Carried forward (under evaluation) | Current design: single chain per `ecr_event_id`. Sequential writes on separate Audit Store instance. Per-event sub-chain isolation flagged as R-05 open question; recommended before scaling audit write throughput. |

---

## What Step 5 (Product Experience) Needs

- **API surface is complete**: 27 use-case endpoints + CRUD domain API available. UX flows must be designed around the use-case API operation names.
- **Performance SLAs to design around**: Kiosk local operations < 5s P95; HM dashboard refresh < 5s P95; bulk email 500/min ceiling means large batches will be queued, not instant.
- **Offline kiosk constraints**: Check-in and walk-in registration work fully offline. Sync UX must communicate sync queue depth, conflict states (ManualReviewQueue), and SBD block exhaustion warning to onsite staff.
- **KitLink UX**: Hiring Managers access interview kits via single-use 24-hour links in email. No ECR login. Expiry must be communicated clearly; re-issuance workflow needed.
- **Candidate PII**: All candidate PII is Vietnam-resident. Assessment vendor data transfer requires contractual VN data residency guarantee before it can be implemented.
- **Waiting list UX**: Candidates can be promoted from waitlist when slot capacity opens (from cancellations). Waitlist position communication needed.

---

## Artifact Paths

```
architecture/
  context-map-l1.md          (134 lines — C4 Level 1)
  context-map-l2.md          (296 lines — C4 Level 2)
  db.dbml                    (811 lines — DBML database schema)
  api-usecase.openapi.yaml   (2015 lines — 27 use-case endpoints)
  api-domain.openapi.yaml    (2042 lines — CRUD domain endpoints)
  events.yaml                (2326 lines — 54 domain events)
```
