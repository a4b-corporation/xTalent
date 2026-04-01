# Glossary — BC-07: Audit Trail

**Bounded Context**: Audit Trail
**Module**: Payroll (PR)
**Step**: 3 — Domain Architecture
**Date**: 2026-03-31

---

## Purpose

This glossary defines the ubiquitous language for the Audit Trail bounded context. BC-07 is a cross-cutting context that receives immutable audit records from all other Payroll bounded contexts. It owns insert-only storage with 7-year retention, SHA-256 integrity verification, and tamper-detection capabilities. BC-07 has no business logic — it records, stores, and verifies.

---

## Aggregate Roots

### AuditLog

| Field | Value |
|-------|-------|
| **Name** | AuditLog |
| **xTalent Term** | `audit_log` |
| **Type** | Aggregate Root |
| **Definition** | An immutable record of a single auditable event emitted by any bounded context within the Payroll module. Contains: `log_id` (UUID, globally unique), `legal_entity_id`, `source_context` (BC-01 through BC-06), `aggregate_type` (e.g., PayrollRun, PayElement, StatutoryRule), `aggregate_id`, `event_type` (e.g., PayrollRunApproved, PayElementActivated), `actor_id` (user who triggered the action, or SYSTEM for automated events), `actor_role`, `event_at` (timestamp, UTC), `before_state_json` (nullable — state before change), `after_state_json` (nullable — state after change), `correlation_id` (ties events from the same user action or batch), `ip_address`, `channel` (API, UI, BATCH, INTEGRATION). AuditLog is insert-only — no UPDATE or DELETE operations are permitted at any layer. |
| **Khac voi** | Not a general application log (error logs, debug logs). AuditLog records domain-significant state changes with before/after snapshots. Application performance logs live in the infrastructure layer; AuditLog is a domain artifact for compliance and forensic investigation. |
| **States** | Immutable — no state transitions after insertion |
| **Lifecycle Events** | AuditLogEntryCreated (the insertion itself; emitted for monitoring purposes) |

---

### IntegrityHash

| Field | Value |
|-------|-------|
| **Name** | IntegrityHash |
| **xTalent Term** | `integrity_hash` |
| **Type** | Aggregate Root |
| **Definition** | A SHA-256 hash record created per PayrollResult per PayPeriod at the moment the PayPeriod is LOCKED. Contains: `hash_id`, `legal_entity_id`, `period_id`, `working_relationship_id`, `payroll_result_id`, `hash_value` (SHA-256 hex string), `hashed_at`, `last_verified_at`, `last_verification_status` (PASSED, FAILED, PENDING). The nightly verification job recomputes SHA-256 over each PayrollResult and compares against the stored `hash_value`. Any mismatch triggers an IntegrityViolationDetected alert with severity CRITICAL. |
| **Khac voi** | Not a login or session token hash. IntegrityHash is specifically a data integrity verification record for PayrollResult records. Its purpose is to detect unauthorized tampering with locked payroll data — a compliance requirement under Accounting Law 88/2015/QH13. |
| **States** | Verification status: PENDING, PASSED, FAILED |
| **Lifecycle Events** | IntegrityHashCreated, IntegrityVerificationPassed, IntegrityViolationDetected |

---

## Value Objects

### AuditContext

| Field | Value |
|-------|-------|
| **Name** | AuditContext |
| **Type** | Value Object (embedded in AuditLog) |
| **Definition** | Contextual metadata about the environment in which an event occurred: `session_id`, `request_id`, `ip_address`, `user_agent`, `channel` (API, UI, BATCH, INTEGRATION). Captured automatically by the audit infrastructure. |

---

## Domain Events

| Event Name | Aggregate | Description |
|------------|-----------|-------------|
| AuditLogEntryCreated | AuditLog | A new audit record was inserted (monitoring hook) |
| IntegrityHashCreated | IntegrityHash | SHA-256 hash computed and stored at period lock |
| IntegrityVerificationPassed | IntegrityHash | Nightly hash verification confirmed no tampering |
| IntegrityViolationDetected | IntegrityHash | Hash mismatch detected — critical tamper alert |

---

## Commands

| Command Name | Actor | Description |
|--------------|-------|-------------|
| RecordAuditEvent | System (all BCs) | Insert a new AuditLog entry (internal command — not user-facing) |
| CreateIntegrityHash | System (BC-03) | Compute and store SHA-256 hash for PayrollResult at period lock |
| RunIntegrityVerification | System (Scheduler) | Nightly job recomputes hashes and compares with stored values |
| QueryAuditTrail | Payroll Admin / Finance Manager / Auditor | Search and retrieve audit log entries with filters |

---

## Retention Policy

| Data Type | Retention Period | Legal Basis |
|-----------|-----------------|-------------|
| AuditLog entries | 7 years minimum | Accounting Law 88/2015/QH13, Art. 12 |
| IntegrityHash records | 7 years minimum, co-terminus with PayrollResult | Same |
| Purge mechanism | Scheduled purge after retention expiry; requires two-party authorization | Internal policy |

---

## Events Published BY Other BCs to Audit Trail

BC-07 receives (as audit events) all state changes from all other bounded contexts. Key events that MUST generate AuditLog entries:

| Source BC | Event | Audit Significance |
|-----------|-------|--------------------|
| BC-01 | PayElementFormulaApproved, PayElementActivated | Formula lifecycle compliance |
| BC-01 | WorkerAssignedToPayGroup | Worker configuration change |
| BC-02 | StatutoryRuleActivated | Regulatory parameter change |
| BC-03 | PayrollRunApproved, PayrollRunRejected | Approval chain record |
| BC-03 | PayPeriodLocked | Period lock — triggers IntegrityHash creation |
| BC-03 | IntegrityViolationDetected | Critical tamper alert |
| BC-03 | RetroactiveAdjustmentApplied | Retroactive pay change |
| BC-04 | BankPaymentFileGenerated | Financial disbursement record |
| BC-05 | PitDeclarationGenerated | Tax filing record |
| BC-06 | PayslipAccessed, PayslipDownloaded | Worker data access record |

---

## Business Rules (in scope for BC-07)

| Rule ID | Summary |
|---------|---------|
| BR-AT-01 | AuditLog is insert-only: UPDATE and DELETE are prohibited at the database, application, and API layers |
| BR-AT-02 | Every audit entry must carry `legal_entity_id` from the source event |
| BR-AT-03 | IntegrityHash is created for every PayrollResult within 30 seconds of PayPeriodLocked event |
| BR-AT-04 | Nightly verification job runs at 02:00 local time; any FAILED result must page on-call within 5 minutes |
| BR-AT-05 | Audit log retention: minimum 7 years. Purge requires two authorized signatories |
| BR-AT-06 | `actor_id = SYSTEM` is used for all automated/scheduled events; human actor_id for all user-initiated actions |

---

## Terms Used from External Bounded Contexts

| Term | Source BC | How Used in BC-07 |
|------|-----------|------------------|
| `legal_entity_id` | CO (EXT-01) | All audit entries carry the legal_entity_id from the source event for multi-tenancy compliance reporting |
| `working_relationship_id` | CO (EXT-01) | Carried in audit entries where the event concerns a specific worker |
| `PayrollResult` | BC-03 | The subject of IntegrityHash records; hash is computed over serialized PayrollResult |
| All domain events | BC-01 to BC-06 | Every significant domain event published by any BC is received and recorded as an AuditLog entry |
