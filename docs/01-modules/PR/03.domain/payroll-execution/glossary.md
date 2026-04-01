# Glossary — BC-03: Payroll Execution

**Bounded Context**: Payroll Execution
**Module**: Payroll (PR)
**Step**: 3 — Domain Architecture
**Date**: 2026-03-31

---

## Purpose

This glossary defines the ubiquitous language for the Payroll Execution bounded context. BC-03 is the computation core of the payroll module — it takes configuration from BC-01, rates from BC-02, and upstream data from CO/TA/TR, then produces immutable PayrollResult records for each worker in each period.

---

## Aggregate Roots

### PayPeriod

| Field | Value |
|-------|-------|
| **Name** | PayPeriod |
| **xTalent Term** | `pay_period` |
| **Type** | Aggregate Root |
| **Definition** | A single payroll processing period for a PayGroup. Generated from the PayCalendar schedule. Contains: `period_id`, `pay_group_id`, `legal_entity_id`, `period_start`, `period_end`, `cut_off_date`, `payment_date`, and current state. PayPeriod progresses through a state machine: OPEN → CUT_OFF → RUNNING → PENDING_APPROVAL → APPROVED → LOCKED. Once LOCKED, no changes to PayrollResult records within this period are permitted. |
| **Khac voi** | Not the same as a PayrollRun. A PayPeriod is the time container; a PayrollRun is an execution of the payroll engine within a PayPeriod. Multiple runs (DRY_RUN, SIMULATION, PRODUCTION) can occur within a single PayPeriod, but only one PRODUCTION run can be APPROVED. |
| **States** | OPEN, CUT_OFF, RUNNING, PENDING_APPROVAL, APPROVED, LOCKED |
| **Lifecycle Events** | PayPeriodOpened, CutOffReached, PayPeriodLocked, IntegrityVerificationPassed, IntegrityViolationDetected |

---

### PayrollRun

| Field | Value |
|-------|-------|
| **Name** | PayrollRun |
| **xTalent Term** | `payroll_run` / `production_run` (when run_mode = PRODUCTION) |
| **Type** | Aggregate Root |
| **Definition** | A single execution of the payroll calculation engine for a PayGroup within a PayPeriod. Has `run_id`, `pay_group_id`, `period_id`, `legal_entity_id`, `run_mode` (DRY_RUN, SIMULATION, PRODUCTION), `run_type` (REGULAR, TERMINATION, ADVANCE, CORRECTION, BONUS_RUN, ANNUAL_SETTLEMENT, TASK_PAYMENT), and a state machine: QUEUED → PRE_VALIDATING → RUNNING → COMPLETED → PENDING_APPROVAL → APPROVED → FAILED. The payroll engine processes workers in parallel partitioned batches (Drools KieSessions). All workers in a run share the same CompensationSnapshot version and StatutoryRule effective dates. |
| **Khac voi** | "Payroll run" in casual usage. In domain language, a `PayrollRun` is the formal execution record. A "production run" specifically refers to a PayrollRun with run_mode = PRODUCTION. DRY_RUN and SIMULATION modes do not produce final PayrollResult records. |
| **States** | QUEUED, PRE_VALIDATING, RUNNING, COMPLETED, PENDING_APPROVAL, APPROVED, FAILED |
| **Lifecycle Events** | PayrollRunInitiated, PreValidationPassed, PreValidationFailed, GrossCalculationCompleted, StatutoryDeductionsCalculated, PitCalculated, NetCalculationCompleted, ExceptionFlagged, ExceptionAcknowledged, PayrollRunCompleted, PayrollRunFailed, PayrollRunSubmittedForApproval, ApprovalLevelPassed, PayrollRunRejected, PayrollRunApproved, OffCycleRunInitiated, TerminationPayCalculated, SalaryAdvancePaid, AdvanceRecoveryScheduled, RetroactiveAdjustmentQueued, RetroactiveAdjustmentApplied, AnnualPitSettlementInitiated, AnnualPitSettlementCompleted |

---

### PayrollResult

| Field | Value |
|-------|-------|
| **Name** | PayrollResult |
| **xTalent Term** | `payroll_result` |
| **Type** | Aggregate Root |
| **Definition** | An immutable per-worker per-period calculation result. Created once when a PRODUCTION run completes; never updated. Contains: `result_id`, `run_id`, `working_relationship_id`, `period_id`, `legal_entity_id`, `gross_amount`, `si_employee_total`, `pit_amount`, `net_amount`, `all element amounts` (as a structured map), `calc_log` (ordered list of calculation steps — see below), `exception_flags` (list), `integrity_hash` (SHA-256, set at period lock), `status` (DRAFT during run, FINAL when period locks). |
| **Khac voi** | Not a "payroll record" in the legacy sense. PayrollResult is append-only: a retroactive adjustment does NOT modify an existing PayrollResult — it creates a new `RetroactiveAdjustment` record and adds a RETRO_ADJUSTMENT element to the next period's PayrollResult. |
| **States** | DRAFT (during run), FINAL (after period lock) |
| **Lifecycle Events** | ExceptionFlagged, ExceptionAcknowledged, IntegrityHashGenerated |

---

### CompensationSnapshot

| Field | Value |
|-------|-------|
| **Name** | CompensationSnapshot |
| **xTalent Term** | `compensation_snapshot` |
| **Type** | Aggregate Root |
| **Definition** | An immutable point-in-time record of all compensation-relevant data for a `working_relationship_id` at the payroll cut-off date. Created by BC-03 when `CutOffReached` is emitted; data is pulled from CO (for contract/identity attributes) and from TR (for compensation amounts). Once created, a CompensationSnapshot is never updated. If data corrections are needed after cut-off, they apply to the NEXT period's snapshot. Contains: `snapshot_id`, `working_relationship_id`, `period_id`, `legal_entity_id`, `snapshot_at`, `base_salary`, `allowances_json` (list of {element_code, amount}), `contract_type`, `dependent_count`, `tax_residency_status`, `nationality_code`, `cost_center_id`, `bank_account_id`, `hourly_rate_multiplier`, `grade_code`, `step_code`. |
| **Khac voi** | CompensationSnapshot contains data from CO and TR, translated through the ACL. It is not a reference to those systems' live records — it is a frozen copy. This immutability is what enables payroll result reproducibility (HS-5, AQ-03 Decision D). |
| **States** | Immutable — no state transitions after creation |
| **Lifecycle Events** | CompensationSnapshotTaken |

---

## Entities

### PayrollException (Entity within PayrollResult)

| Field | Value |
|-------|-------|
| **Name** | PayrollException |
| **Type** | Entity |
| **Definition** | A flagged anomaly for a specific worker in a specific run. Contains: `exception_type` (NEGATIVE_NET, MIN_WAGE_VIOLATION, ZERO_BHXH_SI_ELIGIBLE, OT_CAP_EXCEEDED), `details`, `status` (OPEN, ACKNOWLEDGED), `acknowledged_by`, `acknowledged_at`, `reason_code`. All exceptions must be ACKNOWLEDGED before a PayrollRun can proceed to PENDING_APPROVAL. |

---

### RetroactiveAdjustment (Entity within PayrollResult context)

| Field | Value |
|-------|-------|
| **Name** | RetroactiveAdjustment |
| **Type** | Entity |
| **Definition** | Records a backdated compensation change and its delta impact. Contains: `adjustment_id`, `working_relationship_id`, `source_change_type` (SALARY_CHANGE, ALLOWANCE_CHANGE, etc.), `retroactive_from_period`, `retroactive_to_period`, `delta_amount`, `applied_to_period_id`. The delta is surfaced as a RETRO_ADJUSTMENT PayElement in the target period's PayrollResult. The original locked PayrollResult records are NOT modified. |

---

### ApprovalRecord (Entity within PayrollRun)

| Field | Value |
|-------|-------|
| **Name** | ApprovalRecord |
| **Type** | Entity |
| **Definition** | Records a single approval or rejection action. Contains: `approval_level` (2 = HR Manager, 3 = Finance Manager), `action` (APPROVED, REJECTED), `actor_id`, `timestamp`, `notes`, `reason_code` (on rejection). Multi-level approval: Level 2 (HR Manager) then Level 3 (Finance Manager). |

---

## Value Objects

### CalcLog

| Field | Value |
|-------|-------|
| **Name** | CalcLog |
| **Type** | Value Object (on PayrollResult) |
| **Definition** | An ordered list of calculation step records. Each step contains: `step_order`, `element_code`, `element_name`, `formula_version`, `input_variables` (map of variable names to values), `output_value`, `currency`, `notes`. The CalcLog enables full reproducibility — given the same CompensationSnapshot and StatutoryRule versions, the engine must produce the same CalcLog. This satisfies audit requirements and supports the HS-5 performance model. |

---

### GrossToNetSummary

| Field | Value |
|-------|-------|
| **Name** | GrossToNetSummary |
| **Type** | Value Object (on PayrollResult) |
| **Definition** | A structured summary of the gross-to-net pipeline: `gross_amount`, `si_employee_bhxh`, `si_employee_bhyt`, `si_employee_bhtn`, `si_employee_total`, `pit_amount`, `total_deductions`, `net_amount`. Not a calculation input — derived from CalcLog for display purposes. |

---

## Domain Events

| Event Name | Aggregate | Description |
|------------|-----------|-------------|
| PayPeriodOpened | PayPeriod | New pay period opened for a PayGroup |
| CutOffReached | PayPeriod | Cut-off date reached; snapshots triggered |
| AttendanceDataReceived | PayrollRun | TA attendance data received for a working_relationship |
| CompensationSnapshotTaken | CompensationSnapshot | Immutable snapshot created at cut-off |
| PayrollRunInitiated | PayrollRun | Run entered QUEUED state |
| PreValidationPassed | PayrollRun | Pre-validation completed without critical errors |
| PreValidationFailed | PayrollRun | Pre-validation found blocking data issues |
| GrossCalculationCompleted | PayrollRun | All workers' gross amounts computed |
| StatutoryDeductionsCalculated | PayrollRun | SI contributions computed for all workers |
| PitCalculated | PayrollRun | PIT computed for all workers |
| NetCalculationCompleted | PayrollRun | Net salary computed for all workers |
| ExceptionFlagged | PayrollResult | An anomaly was flagged for a worker |
| ExceptionAcknowledged | PayrollResult | Anomaly was acknowledged by Payroll Admin |
| PayrollRunCompleted | PayrollRun | Run processing complete; ready for approval submission |
| PayrollRunFailed | PayrollRun | Run failed; rolled back |
| PayrollRunSubmittedForApproval | PayrollRun | Submitted to Level 2 approver |
| ApprovalLevelPassed | PayrollRun | Approved at a given level |
| PayrollRunRejected | PayrollRun | Rejected by an approver |
| PayrollRunApproved | PayrollRun | Final (Level 3) approval granted |
| PayPeriodLocked | PayPeriod | Period locked; results immutable |
| IntegrityHashGenerated | PayrollResult | SHA-256 hash computed for each worker result |
| IntegrityVerificationPassed | PayPeriod | Nightly hash verification passed |
| IntegrityViolationDetected | PayPeriod | Hash mismatch detected — critical alert |
| OffCycleRunInitiated | PayrollRun | Off-cycle run started (TERMINATION, ADVANCE, etc.) |
| TerminationPayCalculated | PayrollRun | Termination final pay computed |
| SalaryAdvancePaid | PayrollRun | Advance disbursed; recovery scheduled |
| AdvanceRecoveryScheduled | PayrollRun | Advance recovery element queued for next period |
| RetroactiveAdjustmentQueued | PayrollResult | Retro adjustment queued for calculation |
| RetroactiveAdjustmentApplied | PayrollResult | Retro delta applied to target period |
| AnnualPitSettlementInitiated | PayrollRun | Year-end PIT settlement run started |
| AnnualPitSettlementCompleted | PayrollRun | Annual PIT reconciliation complete |
| YtdBalancesReset | Balance | YTD balances reset on January 1 |

---

## Commands

| Command Name | Actor | Description |
|--------------|-------|-------------|
| OpenPayPeriod | Payroll Admin / Scheduler | Open a new pay period |
| TriggerCutOff | Payroll Admin / Scheduler | Manually trigger cut-off (or auto on cut-off date) |
| InitiatePayrollRun | Payroll Admin | Start a payroll run (DRY_RUN, SIMULATION, or PRODUCTION) |
| AcknowledgeException | Payroll Admin | Acknowledge a flagged exception with reason |
| SubmitForApproval | Payroll Admin | Submit completed run for Level 2 approval |
| ApprovePayrollRun | HR Manager / Finance Manager | Approve at Level 2 or Level 3 |
| RejectPayrollRun | HR Manager / Finance Manager | Reject with reason code |
| InitiateOffCycleRun | Payroll Admin | Start off-cycle run (TERMINATION, ADVANCE, etc.) |
| QueueRetroactiveAdjustment | Payroll Admin | Queue a retroactive salary adjustment |
| TriggerAnnualPitSettlement | Payroll Admin | Initiate year-end PIT settlement run |

---

## Business Rules (in scope for BC-03)

| Rule ID | Summary |
|---------|---------|
| BR-033 | Split-period SI calculation logic (applied during execution using StatutoryRule dates) |
| BR-047 | Monthly PIT computed directly (not annualized) |
| BR-048 | Annual PIT settlement: ANNUAL_TAXABLE computation, delta calculation, refund/collection |
| BR-060 | Deduction priority order enforcement |
| BR-061 | Net salary formula: Gross − SI − PIT − Deductions |
| BR-062 | Rounding rule (per PayProfile.rounding_method) |
| BR-063 | Negative net salary: flag as NEGATIVE_NET exception; cannot disburse |
| BR-080 | PayPeriod state machine (OPEN → LOCKED) |
| BR-081 | PayrollRun state machine |
| BR-082 | Multi-level approval (Level 2 HR Manager; Level 3 Finance Manager) |
| BR-083 | Approval time limit (configurable SLA) |
| BR-084 | Retroactive adjustment (up to 12 closed periods) |
| BR-085 | Run locking: PRODUCTION run approved → period locked |
| BR-086 | Off-cycle run types |
| BR-087 | Split-period proration for mid-period join/leave |
| BR-100 | Legal entity isolation (legal_entity_id row-level security) |
| BR-101 | CompensationSnapshot immutability |
| BR-102 | PayrollResult immutability after period lock |
| BR-103 | SHA-256 integrity hash at period lock |
| BR-104 | Nightly integrity verification |

---

## Terms Used from External Bounded Contexts

| Term | Source BC | How Used in BC-03 |
|------|-----------|------------------|
| `working_relationship_id` | CO (EXT-01) | Primary key linking PayrollResult and CompensationSnapshot to the worker's employment context |
| `legal_entity_id` | CO (EXT-01) | Multi-tenancy isolation on PayPeriod, PayrollRun, PayrollResult, CompensationSnapshot |
| `AttendanceLocked` event | TA (EXT-02) | Triggers `AttendanceDataReceived` in BC-03; provides actual_work_days, OT hours, piece data |
| `compensation_snapshot` data | TR (EXT-03) | Pulled at cut-off and stored immutably in CompensationSnapshot |
| `PayProfile` | BC-01 | Provides pay_method, proration_method, rounding_method, element bindings for each worker |
| `StatutoryRule` | BC-02 | Looked up by effective date during each calculation stage |
| `SiEligibilityMatrix` | BC-02 | Queried during SI deduction stage per worker's contract_type |
