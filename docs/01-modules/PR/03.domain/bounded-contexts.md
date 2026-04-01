# Bounded Contexts — Payroll Module (PR)

**Artifact**: bounded-contexts.md
**Module**: Payroll (PR)
**Solution**: xTalent HCM
**Step**: 3 — Domain Architecture
**Date**: 2026-03-31
**Version**: 1.0

---

## 1. Overview

The Payroll module is decomposed into 7 internal bounded contexts (BC-01 through BC-07) and integrates with 3 external bounded contexts (CO, TA, TR). Each context has a clearly defined responsibility boundary, owns specific aggregates, and integrates with others through explicit patterns.

---

## 2. Internal Bounded Contexts

| ID | Name | Slug | Core Aggregates | Primary Responsibility |
|----|------|------|----------------|----------------------|
| BC-01 | Pay Master | `pay-master` | PayGroup, PayProfile, PayElement, PayCalendar | Configuration: who is paid, how, when, via what formula |
| BC-02 | Statutory Rules | `statutory-rules` | StatutoryRule | Versioned regulatory rates, brackets, ceilings, OT multipliers |
| BC-03 | Payroll Execution | `payroll-execution` | PayrollRun, PayrollResult, CompensationSnapshot, PayPeriod | Gross-to-net computation, batch engine, run lifecycle |
| BC-04 | Payment Output | `payment-output` | BankPaymentFile, GlJournal, PayslipDocument | Bank files, GL entries, payslip documents, statutory filing docs |
| BC-05 | Statutory Reporting | `statutory-reporting` | BhxhReport, PitDeclaration, PitCertificate | BHXH D02-LT, PIT Form 05/KK-TNCN, Form 05/QTT-TNCN |
| BC-06 | Worker Self-Service | `worker-self-service` | PayslipView, YtdSummary, PitCertificateRequest | Worker portal: payslip access, PIT certificate, YTD view |
| BC-07 | Audit Trail | `audit-trail` | AuditLog, IntegrityHash | Immutable audit records, SHA-256, 7-year retention |

---

## 3. External Bounded Contexts (Upstream Providers)

| ID | Name | Module Code | Data Provided to PR | Integration Type |
|----|------|-------------|--------------------|--------------------|
| EXT-01 | Core HR | CO | worker identity, working_relationship, contract_type, dependent_count, bank_account, cost_center, nationality | ACL (Translation Layer) |
| EXT-02 | Time & Attendance | TA | attendance data, actual_work_days, OT hours by type, shift_data, unpaid_leave_days, holiday_calendar | OHS (Open Host Service) |
| EXT-03 | Total Rewards | TR | compensation_snapshot: base_salary, allowances, approved_bonuses, taxable_bridge_items | ACL (Snapshot Pull) |

---

## 4. Context Responsibilities

### BC-01: Pay Master

**Owns**:
- PayGroup configuration (legal entity binding, calendar association, night window config, OT caps, standard hours)
- PayElement definitions: formula lifecycle (DRAFT → PENDING_APPROVAL → APPROVED → ACTIVE → DEPRECATED), tax treatment, SI basis inclusion, proration method, priority order
- PayProfile definitions: pay method enum, proration method, rounding method, element bindings, rule bindings, parent hierarchy (inheritance), piece_rate_table, hourly_rate_config, pay_scale_table
- PayCalendar: period schedule, cut-off dates, payment dates

**Does NOT own**:
- Statutory calculation rates and thresholds (owned by BC-02)
- Any calculation rule from TR's `calculation_rule_def` (ADR-enforced boundary — HS-2)
- Worker identity or working relationship data (owned by EXT-01/CO)
- Payroll execution state or results (owned by BC-03)

**Key business rules in scope**: BR-001 to BR-019 (gross calculation configuration), BR-027 (SI basis flag per element), BR-060 (deduction priority order per element)

---

### BC-02: Statutory Rules

**Owns**:
- StatutoryRule: versioned regulatory data with `valid_from` / `valid_to` effective-date pattern
- All statutory rate categories: PIT brackets, SI rates (BHXH/BHYT/BHTN), OT multipliers, minimum wage by region, base salary (lương cơ sở), freelance withholding thresholds, lunch allowance exemption caps
- SI eligibility matrix: contract_type → [BHXH, BHYT, BHTN] eligibility flags (configurable table, not code logic)
- Statutory rule lifecycle: DRAFT → ACTIVE → SUPERSEDED

**Does NOT own**:
- HR-policy calculation rules (owned by TR — AQ-01 Decision D)
- PayProfile or PayElement formula configuration (owned by BC-01)
- How rates are applied in calculation (owned by BC-03)

**Key business rules in scope**: BR-020 to BR-035 (SI rates and ceilings), BR-040 to BR-051 (PIT brackets and deductions), BR-070 to BR-073 (minimum wage), BR-033 (split-period SI)

---

### BC-03: Payroll Execution

**Owns**:
- PayPeriod: state machine (OPEN → CUT_OFF → RUNNING → PENDING_APPROVAL → APPROVED → LOCKED)
- PayrollRun: batch execution state machine (QUEUED → PRE_VALIDATING → RUNNING → PENDING_APPROVAL → APPROVED → FAILED), run modes (DRY_RUN, SIMULATION, PRODUCTION), off-cycle types (TERMINATION, ADVANCE, CORRECTION, BONUS_RUN, ANNUAL_SETTLEMENT, TASK_PAYMENT)
- PayrollResult: per-worker per-period immutable record including calc_log (ordered list of elements, input values, formula versions, output values)
- CompensationSnapshot: immutable snapshot created at cut-off per working_relationship

**Does NOT own**:
- Output file generation (owned by BC-04)
- Statutory report generation (owned by BC-05)
- Audit log persistence (delegated to BC-07)

**Key business rules in scope**: BR-060 to BR-064 (net calculation, deductions), BR-080 to BR-096 (run lifecycle, approval, retro), BR-100 to BR-104 (multi-tenancy)

---

### BC-04: Payment Output

**Owns**:
- BankPaymentFile: bank-agnostic payment request record; bank-specific adapters (VCB, BIDV, TCB formats)
- GlJournal: VAS-compliant GL journal entry generation (TK 334, 338, 3383, 3335, 642)
- PayslipDocument: payslip PDF generation and storage

**Does NOT own**:
- Payroll calculation results (consumed from BC-03 as read-only)
- Statutory report filing documents (owned by BC-05)
- Worker portal access to payslips (owned by BC-06)

---

### BC-05: Statutory Reporting

**Owns**:
- BhxhReport: BHXH D02-LT monthly contribution list (VssID format)
- PitDeclaration: PIT Form 05/KK-TNCN quarterly XML (Circular 08/2013/TT-BTC format)
- PitCertificate: PIT withholding certificate generation (Form 05/QTT-TNCN for annual settlement)

**Does NOT own**:
- Payroll result data (consumed read-only from BC-03)
- Worker self-service certificate access (owned by BC-06)

---

### BC-06: Worker Self-Service

**Owns**:
- PayslipView: worker's read-only payslip view session
- YtdSummary: worker's year-to-date salary and deduction summary
- PitCertificateRequest: worker-initiated PIT certificate request workflow

**Does NOT own**:
- Payslip document generation (owned by BC-04)
- PIT certificate generation (owned by BC-05)
- Any write access to payroll data

---

### BC-07: Audit Trail

**Owns**:
- AuditLog: immutable event records for all state changes across all aggregates (insert-only, no update/delete)
- IntegrityHash: SHA-256 hash records per PayrollResult per period; nightly verification job

**Does NOT own**:
- Business logic (pure recording and verification)
- Any mutable data

**Retention**: 7-year minimum per Accounting Law 88/2015/QH13

---

## 5. Context Map

```
╔══════════════════════════════════════════════════════════════════════════╗
║                        EXTERNAL CONTEXTS (Upstream)                      ║
║                                                                          ║
║  ┌──────────────┐    ┌────────────────────────┐    ┌──────────────────┐ ║
║  │   CO         │    │   TA                   │    │   TR             │ ║
║  │  (Core HR)   │    │  (Time & Attendance)   │    │ (Total Rewards)  │ ║
║  │              │    │                        │    │                  │ ║
║  │ worker       │    │ AttendanceLocked event  │    │ compensation_    │ ║
║  │ working_rel  │    │ actual_work_days        │    │ snapshot         │ ║
║  │ contract_type│    │ OT hours by type        │    │ base_salary      │ ║
║  │ dependents   │    │ holiday_calendar        │    │ allowances       │ ║
║  │ bank_account │    │                        │    │ bonuses          │ ║
║  └──────┬───────┘    └───────────┬────────────┘    └───────┬──────────┘ ║
║         │ ACL                    │ OHS                     │ ACL        ║
╚═════════╪════════════════════════╪═════════════════════════╪════════════╝
          │                        │                         │
          ▼                        ▼                         ▼
╔══════════════════════════════════════════════════════════════════════════╗
║                          PAYROLL MODULE (PR)                             ║
║                                                                          ║
║  ┌─────────────────────────────────────────────────────────────────────┐ ║
║  │  BC-01: Pay Master                                                  │ ║
║  │  PayGroup · PayProfile · PayElement · PayCalendar                  │ ║
║  └───────────────────────────────┬─────────────────────────────────────┘ ║
║                                  │ Configuration provides                ║
║  ┌───────────────────────────────▼─────────────────────────────────────┐ ║
║  │  BC-02: Statutory Rules                                             │ ║
║  │  StatutoryRule (versioned, effective-dated)                        │ ║
║  └───────────────────────────────┬─────────────────────────────────────┘ ║
║                                  │ Rates consumed by                     ║
║  ┌───────────────────────────────▼─────────────────────────────────────┐ ║
║  │  BC-03: Payroll Execution                                           │ ║
║  │  PayPeriod · PayrollRun · PayrollResult · CompensationSnapshot     │ ║
║  └───┬──────────────────────┬────────────────────────┬────────────────┘ ║
║      │                      │                        │                  ║
║      ▼                      ▼                        ▼                  ║
║  ┌──────────┐    ┌────────────────────┐    ┌─────────────────────────┐  ║
║  │  BC-04   │    │  BC-05             │    │  BC-06                  │  ║
║  │ Payment  │    │ Statutory          │    │ Worker                  │  ║
║  │ Output   │    │ Reporting          │    │ Self-Service            │  ║
║  └──────────┘    └────────────────────┘    └─────────────────────────┘  ║
║                                                                          ║
║  ┌─────────────────────────────────────────────────────────────────────┐ ║
║  │  BC-07: Audit Trail  (cross-cutting — all BCs publish to this)     │ ║
║  └─────────────────────────────────────────────────────────────────────┘ ║
╚══════════════════════════════════════════════════════════════════════════╝
          │
          ▼
╔══════════════════════════════════════════════════════════════════════════╗
║                    EXTERNAL CONTEXTS (Downstream)                        ║
║                                                                          ║
║  ┌──────────┐  ┌────────────┐  ┌───────────────┐  ┌──────────────────┐ ║
║  │  Bank    │  │ Accounting │  │  GDT           │  │  BHXH Agency    │ ║
║  │ VCB/BIDV │  │ GL System  │  │ (Tax Auth.)    │  │  (VssID)        │ ║
║  │ /TCB     │  │            │  │                │  │                 │ ║
║  └──────────┘  └────────────┘  └───────────────┘  └──────────────────┘ ║
╚══════════════════════════════════════════════════════════════════════════╝
```

---

## 6. Integration Patterns

### 6.1 Upstream Integration

| Integration | Pattern | Mechanism | Notes |
|-------------|---------|-----------|-------|
| CO → PR | Anti-Corruption Layer (ACL) | PR translates CO "worker/assignment" language into PR "working_relationship/compensation_snapshot" language. PR never exposes CO internal types to its own domain model. | Translation occurs at the `CompensationSnapshotTranslator` service boundary |
| TA → PR | Open Host Service (OHS) | TA publishes `AttendanceLocked` event via a well-defined event schema. PR subscribes and maps to internal payroll input variables. TA defines the contract; PR conforms to it. | PR caches holiday_calendar; invalidated by `HolidayCalendarUpdated` event (HS-9) |
| TR → PR | Anti-Corruption Layer (ACL) | PR pulls compensation snapshot from TR at cut-off. TR provides data, not executable rules. ACL ensures `calculation_rule_def` from TR never enters PR domain. | Enforced by ADR (AQ-01 Decision D). BC-01 must NOT reference TR `calculation_rule_def`. |

### 6.2 Downstream Integration

| Integration | Pattern | Mechanism | Notes |
|-------------|---------|-----------|-------|
| PR → Bank | Open Host Service (OHS) | PR produces bank-agnostic `BankPaymentRequest`; bank-specific adapters format to VCB/BIDV/TCB. V1 = manual file upload. V2 = API push (deferred). | Payment confirmation feedback loop is a P1 hot spot (HS-8) |
| PR → Accounting | Open Host Service (OHS) | PR produces `GlJournalGenerated` domain event; accounting adapter translates to VAS GL journal format with TK codes. | Finance team configures GL account code mapping |
| PR → GDT | Conformist | PR generates XML per Circular 08/2013/TT-BTC format (non-negotiable regulatory format). | Quarterly (05/KK-TNCN) and annual (05/QTT-TNCN) |
| PR → BHXH | Conformist | PR generates D02-LT per VssID format (non-negotiable). | Monthly filing |

---

## 7. HS-2: TR/PR Boundary Resolution

Hot spot HS-2 is explicitly resolved as follows:

**Rule**: BC-01 (Pay Master) must NOT import, reference, or consume any entity from TR's `calculation_rule_def`, `basis_calculation_rule`, or `tax_calculation_cache` tables.

**Enforcement**:
1. The ADR (AQ-01 Decision D) establishes that TR owns HR-policy rules; PR owns statutory rules.
2. In the domain model: `StatutoryRule` (BC-02) is the ONLY source of calculation rates and thresholds for the payroll engine.
3. TR delivers compensation data to PR as an immutable `CompensationSnapshot` — amounts only, no formulas or rules.
4. BC-03 (Payroll Execution) reads `CompensationSnapshot` for amounts and `StatutoryRule` for all calculation parameters. It never calls TR APIs during calculation.
5. Any future request to add TR calculation rules to PR must be blocked and referred to the Architecture Lead for ADR amendment.

---

## 8. Multi-Tenancy Boundary

Every aggregate root in every BC carries `legal_entity_id`. Cross-entity data access requires `CROSS_ENTITY_REPORT_VIEWER` role. Row-level security is enforced at the persistence layer, not in domain logic.

| BC | Root Aggregates with legal_entity_id |
|----|-------------------------------------|
| BC-01 | PayGroup, PayProfile, PayElement, PayCalendar |
| BC-02 | StatutoryRule (country_code + legal_entity_id for overrides; global rules have legal_entity_id = NULL) |
| BC-03 | PayrollRun, PayrollResult, CompensationSnapshot, PayPeriod |
| BC-04 | BankPaymentFile, GlJournal, PayslipDocument |
| BC-05 | BhxhReport, PitDeclaration, PitCertificate |
| BC-06 | PayslipView, YtdSummary, PitCertificateRequest |
| BC-07 | AuditLog (includes legal_entity_id from source event) |

---

## 9. Temporal/Effective-Date Pattern

The following entities use the effective-date pattern (`effective_from`, `effective_to`):

| Entity | BC | Pattern Used |
|--------|----|-|
| StatutoryRule | BC-02 | `valid_from` / `valid_to` — rate lookup always uses the rule valid at payroll period cut-off date |
| PayElement formula version | BC-01 | `active_from` — each formula version has an activation date |
| PayProfile element binding | BC-01 | `effective_date` — binding is effective from a specific date |
| WorkerPayGroupAssignment | BC-01 | `effective_date` — assignment is effective from a date |
| CompensationSnapshot | BC-03 | `snapshot_at` — point-in-time immutable record (no effective_to; it is fixed to the cut-off moment) |
| PieceRateTable entry | BC-01 | `effective_date` — rate applies from a date forward |
| PayScaleTable entry | BC-01 | `effective_date` — pay scale entry applies from a date |

---

*This document is the primary reference for bounded context boundaries. All downstream artifacts (glossaries, LinkML schemas, flow documents) must respect these boundaries.*
