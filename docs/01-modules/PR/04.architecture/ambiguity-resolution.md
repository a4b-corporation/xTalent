# Ambiguity Resolution — Solution Architecture

**Artifact**: ambiguity-resolution.md
**Module**: Payroll (PR)
**Solution**: xTalent HCM
**Step**: 4 — Solution Architecture
**Date**: 2026-03-31
**Version**: 1.0

---

## Purpose

This document captures all open questions, ambiguities, and architecture decisions encountered during Step 4 Solution Architecture. Each item includes a score, recommended resolution, and required stakeholder action before Step 5 (Experience Architecture) can begin.

---

## Scoring Guide

| Dimension | 0.0 | 0.5 | 1.0 |
|-----------|-----|-----|-----|
| Impact | Low (cosmetic) | Medium (design change) | High (architecture rework) |
| Confidence | High (>0.8) | Medium (0.5–0.8) | Low (<0.5) |
| Urgency | Not blocking | Blocks a future step | Blocks Step 4 completion |

Flag threshold: any dimension > 0.3. Items above 0.5 on impact require stakeholder decision before proceeding.

---

## AQ-S1: Database Deployment Model — Shared vs. Separate Instances

**Question**: Should each bounded context get its own dedicated PostgreSQL database instance, or should all 7 BCs share a single PostgreSQL instance with separate schemas?

**Options**:

| Option | Description | Trade-offs |
|--------|-------------|-----------|
| A: Shared instance, separate schemas | One PostgreSQL cluster; schemas: `pay_master`, `statutory_rules`, `payroll_execution`, `payment_output`, `statutory_reporting`, `worker_self_service`, `audit_trail` | Lower infra cost; simpler ops; cross-schema reads allowed via read-only connections; schema-level RLS per BC |
| B: Separate instances per BC | Each BC runs its own PostgreSQL; communication strictly via API/events; no cross-schema queries | Better isolation; independent scaling; harder operational overhead; requires all cross-BC data to flow via API or event |
| C: Hybrid — audit_trail isolated; others shared | Audit Trail is isolated (append-only, long retention, different backup policy); other 6 BCs share an instance | Practical compromise; audit trail has genuinely different NFRs |

**Recommendation**: Option C (hybrid). The audit trail has 7-year retention, different backup policy (point-in-time recovery irreversible protection), and append-only semantics — it justifies isolation. The other 6 BCs benefit from shared-instance operational simplicity while still maintaining schema-level isolation.

**Scores**: Impact = 0.7 | Confidence = 0.5 | Urgency = 0.6

**Status**: OPEN — requires Platform Engineering sign-off

**Blocking**: DBML assumes schema isolation (Option A as minimum). Separate instance IDs and connection strings are an infrastructure concern separate from schema design.

---

## AQ-S2: Message Broker Technology — Kafka vs. RabbitMQ vs. DB-backed Outbox

**Question**: What message broker should be used for async event delivery between BCs and external systems?

**Options**:

| Option | Description | Trade-offs |
|--------|-------------|-----------|
| A: Apache Kafka | Distributed log; high throughput; event replay; topic partitioning; well-suited for 60+ events; supports audit trail consumption from all topics | Higher operational complexity; requires Zookeeper/KRaft; overkill if event volume is low at V1 |
| B: RabbitMQ | Message queue; simpler ops; good for command-style events; well-supported in Spring Boot | No event replay; messages deleted on consumption; less suitable for audit trail fan-out |
| C: DB-backed Transactional Outbox | Events stored in DB table; polling worker picks up and delivers; guaranteed delivery with DB transaction | Simple ops; zero new infra; limited throughput; polling latency; suitable for V1 |
| D: Managed service (AWS SQS/SNS or GCP Pub/Sub) | Cloud-managed; low operational overhead; event fan-out via SNS; dead-letter queues built-in | Vendor lock-in; may conflict with on-premise deployment requirement |

**Recommendation**: Option C (DB-backed Outbox) for V1, with Kafka designed-in for V2. The Outbox pattern gives guaranteed delivery with no additional infrastructure. At V1 scale (< 1,000 workers per run), Outbox throughput is sufficient. The `events.yaml` Kafka topic names are pre-defined for V2 migration.

**Scores**: Impact = 0.8 | Confidence = 0.45 | Urgency = 0.7

**Status**: OPEN — requires Platform Engineering + DevOps review. Type 1 (irreversible) decision for production deployment.

**Action Required**: DevOps team must assess existing xTalent infrastructure — if Kafka is already deployed for other modules (CO, TA), using it for PR removes the operational cost concern. Interview required.

---

## AQ-S3: API Gateway Routing Strategy

**Question**: How should the API Gateway route requests to internal BC services? What routing key is used?

**Options**:

| Option | Description | Trade-offs |
|--------|-------------|-----------|
| A: Path-based routing | `/api/v1/payroll-domain/pay-groups` → BC-01 API; `/api/v1/payroll-uc/payroll/runs` → BC-03 API | Simple; deterministic; URL hierarchy reveals BC ownership |
| B: Header-based routing | X-Target-Service header routes to BC; frontend-agnostic URLs | More flexible for future refactoring; adds header complexity; non-standard |
| C: Monolithic API surface with facade | Single payroll API service receives all requests and internally delegates to BC services | Simpler for UI team; extra network hop; potential hotspot at facade |

**Recommendation**: Option A (path-based routing). The dual-API design (api-usecase vs api-domain) provides natural path prefix separation. API Gateway enforces JWT auth and injects `legal_entity_id` from token claims into requests.

**Scores**: Impact = 0.4 | Confidence = 0.7 | Urgency = 0.3

**Status**: LOW PRIORITY — can be decided during Step 5 (Experience Architecture). Path-based routing is the default assumption in both OpenAPI specs.

---

## AQ-S4: Drools 8 Performance POC (HS-5) — Architecture Gate

**Question**: Can Drools 8 process 1,000 workers in < 30 seconds? What partitioning strategy achieves this?

**Context**: This is a P0 hot spot from the Step 3 handoff. The payroll calculation engine (BC-03) uses Drools 8 KieSessions for formula execution. At 1,000 workers, the target SLA is < 30 seconds for a full gross-to-net run.

**Architecture Decision Recorded**:
- One KieSession per partition
- Partition strategy: workers are split into batches of 50, executed in parallel via Spring @Async thread pool
- 1,000 workers = 20 parallel batches
- Formula registry loaded once per run; shared (read-only) across sessions
- POC must validate: 20 × 50-worker batches complete < 30s on target hardware

**Status**: BLOCKER — Step 4 architecture includes the Drools container design, but the solution design for BC-03 MUST NOT be finalized until POC results are available. If POC fails (> 30s):
- Alternative A: Replace Drools with pure Java calculation engine (gives up rule externalization)
- Alternative B: Reduce batch to 25 workers, scale compute horizontally (adds infra cost)
- Alternative C: Cache formula compilation; only recompile on formula version change (reduces per-run overhead)

**Scores**: Impact = 1.0 | Confidence = 0.4 | Urgency = 1.0

**Status**: OPEN — POC must run before Step 5. Architecture Lead must sign off on POC results.

---

## AQ-S5: calc_log Storage Decision

**Question**: Should calculation log entries be stored as a separate `calc_log_entry` table or as a JSONB column on `payroll_result`?

**Options**:

| Option | Description | Trade-offs |
|--------|-------------|-----------|
| A: Separate `calc_log_entry` table | One row per calculation step; composite key (result_id, step_order) | Queryable; supports debugging queries like "show all results where BHXH was zero"; index-friendly; chosen in DBML |
| B: JSONB column on `payroll_result` | Entire calc log stored as JSONB array | Simpler schema; no JOIN required; not queryable at element level; large payloads in single column |

**Decision**: Option A (separate table) — **chosen and implemented in db.dbml**.

**Rationale**: Audit query performance is a stated requirement (step 3 handoff preference). Forensic debugging requires element-level queries (e.g., "find all workers where BHXH formula version 3 was used"). JSONB approach cannot support this efficiently. Storage overhead is acceptable (estimated 15–40 rows per worker per period).

**Scores**: Impact = 0.5 | Confidence = 0.9 | Urgency = 0.0

**Status**: RESOLVED — Decision recorded. No further action required.

---

## AQ-S6: TR Boundary Acceptance (AQ-01 from Step 3)

**Question**: Has the TR team accepted the dual-ownership boundary where TR provides data-only (no formulas) to PR?

**Context**: From step 3 handoff: "AQ-01 (P0) — TR team acceptance of dual-ownership boundary. Confidence 0.75. If TR rejects AQ-01 Decision D: BC-01 and BC-02 scope must be revisited before finalizing DBML."

**Current Status**: Treated as accepted for Step 4 architecture purposes. The DBML, ACL adapter design, and event catalog all enforce the boundary: TR delivers `compensation_snapshot` (amounts only) to PR via ACL; no TR `calculation_rule_def` entity references appear in any PR schema or API.

**Scores**: Impact = 1.0 | Confidence = 0.75 | Urgency = 0.8

**Status**: OPEN — Architecture Lead must confirm TR team acceptance before Step 4 is marked complete. If TR rejects: `pay_master` and `statutory_rules` schema scope requires re-evaluation; this is a blocker for finalization.

---

## AQ-S7: TA Data Completeness Recovery Behavior (HS-1)

**Question**: When AttendanceLocked events are below the 95% threshold at cut-off + 2 hours, what is the exact recovery procedure?

**Architecture Decision Recorded**:
- Threshold: attendance received for ≥ 95% of workers in pay group
- Window: cut-off time + 2 hours grace period
- Below threshold: PayrollRun is blocked with `PreValidationFailed` event; alert to Payroll Admin
- Recovery options: (a) Payroll Admin manually approves run with partial attendance (exception acknowledged), or (b) Payroll Admin extends cut-off window by up to 24 hours (new command: `ExtendCutOffWindow`)
- Workers with no attendance data: excluded from run with `MISSING_ATTENDANCE` exception type; can be included in a CORRECTION off-cycle run once TA data arrives

**Open Sub-questions**:
1. Is 95% the correct threshold? HR/Operations may want configurable threshold per pay group.
2. Should missing-attendance workers default to zero pay or to standard days (less conservative)?

**Scores**: Impact = 0.6 | Confidence = 0.55 | Urgency = 0.5

**Status**: OPEN — Payroll Admin and HR Operations must confirm threshold and default behavior. Configurable threshold per pay group is recommended and should be added to `pay_group` table as `attendance_completeness_threshold` column (AQ item for Step 5 data model review).

---

## AQ-S8: Bank Payment Confirmation Feedback Loop (HS-8)

**Question**: V1 design uses file download + manual upload to bank. V2 requires bank API push with payment confirmation. What interface should be reserved in V1 to avoid rework in V2?

**Architecture Decision Recorded**:
- V1: `bank_payment_file` table + file download endpoint. Finance Manager downloads file and uploads to bank portal manually.
- V2 reservation: `bank_payment_item.status` column is already defined with `PENDING | PROCESSED | FAILED | REVERSED` enum — this supports V2 webhook confirmation without schema change.
- V2 webhook endpoint: `POST /payment-output/bank-payment-items/{itemId}/confirm` — defined but NOT implemented in V1. Interface reserved in api-usecase spec with `x-status: reserved-v2` annotation.
- `BankPaymentItem.bank_transaction_ref` column should be added at V2 (not yet in DBML to avoid false completeness signal).

**Scores**: Impact = 0.3 | Confidence = 0.8 | Urgency = 0.2

**Status**: LOW PRIORITY — V2 interface reservation is documented. No blocking action required for Step 4. Step 5 should include V2 bank webhook flow in UX consideration.

---

## AQ-S9: Multi-Tenancy Row-Level Security Implementation

**Question**: Should Row-Level Security (RLS) be implemented at the PostgreSQL layer or at the application layer (service-level filtering)?

**Options**:

| Option | Trade-offs |
|--------|-----------|
| PostgreSQL RLS policies per table | Enforced even if application has a bug; performance overhead on every query; complex policy management across 7 schemas |
| Application-layer filtering | Simpler; all queries include `WHERE legal_entity_id = :tenant_id`; no DB policy overhead; relies on service layer correctness |
| Hybrid: RLS on most sensitive tables only | RLS on `payroll_result`, `compensation_snapshot`, `audit_log`; application filtering on configuration tables | Balance of security and performance |

**Recommendation**: Hybrid approach. RLS on the three immutable/sensitive tables (payroll_result, compensation_snapshot, audit_log). Application-layer `WHERE legal_entity_id = ?` on all other tables, enforced at repository layer with test coverage.

**Scores**: Impact = 0.6 | Confidence = 0.6 | Urgency = 0.3

**Status**: OPEN — Security Architecture review required. Database engineer must assess PostgreSQL RLS performance impact at target query volume (1,000 workers × 12 periods × multi-tenant).

---

## Summary of Open Items

| ID | Title | Impact | Confidence | Urgency | Status | Blocking |
|----|-------|--------|------------|---------|--------|----------|
| AQ-S1 | DB deployment model (shared vs separate) | 0.7 | 0.5 | 0.6 | OPEN | Step 5 infra design |
| AQ-S2 | Message broker choice (Kafka vs Outbox) | 0.8 | 0.45 | 0.7 | OPEN | Step 5 event infrastructure |
| AQ-S3 | API Gateway routing strategy | 0.4 | 0.7 | 0.3 | LOW PRIORITY | — |
| AQ-S4 | Drools 8 POC result (HS-5) | 1.0 | 0.4 | 1.0 | OPEN — BLOCKER | BC-03 final design |
| AQ-S5 | calc_log storage (separate table vs JSONB) | 0.5 | 0.9 | 0.0 | RESOLVED | — |
| AQ-S6 | TR boundary acceptance (AQ-01) | 1.0 | 0.75 | 0.8 | OPEN — BLOCKER | DBML finalization |
| AQ-S7 | TA completeness recovery behavior (HS-1) | 0.6 | 0.55 | 0.5 | OPEN | Step 5 UX for partial run |
| AQ-S8 | Bank payment V2 interface reservation (HS-8) | 0.3 | 0.8 | 0.2 | LOW PRIORITY | — |
| AQ-S9 | Multi-tenancy RLS implementation | 0.6 | 0.6 | 0.3 | OPEN | Security review |

**Blockers for Gate G4**:
- AQ-S4: Drools POC must be initiated (not necessarily completed, but resourced)
- AQ-S6: TR team acceptance must be confirmed by Architecture Lead

**Blockers for Step 5**:
- AQ-S2: Message broker choice must be decided (affects event delivery guarantees in UX flows)
- AQ-S7: Partial run behavior must be confirmed (affects Payroll Admin UX for exception management)

---

*This document is maintained by the Solution Architect. Update status fields as decisions are made.*
