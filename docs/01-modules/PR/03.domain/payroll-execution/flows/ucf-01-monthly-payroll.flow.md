# UCF-01: Monthly Payroll Execution

**Bounded Context**: Payroll Execution (BC-03)
**Timeline**: T2 — Monthly payroll cycle (recurring)
**Actors**: Payroll Admin, System (Drools engine), HR Manager, Finance Manager
**Trigger**: PayCalendar cut-off date reached (auto) or Payroll Admin manually triggers cut-off

---

## Preconditions

- PayPeriod exists in OPEN state for the target PayGroup and month
- All workers have active WorkerPayGroupAssignment records
- TA module has locked attendance for the period (`AttendanceLocked` event received)
- CompensationSnapshot has not yet been taken for this period
- All PayElement formulas for this PayGroup are in ACTIVE state
- StatutoryRules valid for the period cut-off date are in ACTIVE state (SI rates, PIT brackets, minimum wage)

---

## Main Flow

| Step | Actor | Action | System Response |
|------|-------|--------|-----------------|
| 1 | Scheduler / Payroll Admin | Cut-off date reached (auto) or admin triggers `TriggerCutOff` command | System transitions PayPeriod: OPEN → CUT_OFF. Emits `PayPeriodCutOffApplied` event. |
| 2 | System | Snapshot trigger: for each active working_relationship in the PayGroup | System calls CO ACL to retrieve worker identity, contract_type, dependent_count, nationality, bank_account. Calls TR ACL to retrieve base_salary, allowances_json, approved_bonuses. Creates immutable `CompensationSnapshot` per worker. Emits `CompensationSnapshotCreated` event. |
| 3 | Payroll Admin | Issues `InitiatePayrollRun` command (run_mode = PRODUCTION, run_type = REGULAR) | System creates PayrollRun in QUEUED state. Assigns run_id. Emits `PayrollRunQueued` event. PayPeriod transitions to RUNNING. |
| 4 | System | Pre-validation phase begins | System transitions PayrollRun: QUEUED → PRE_VALIDATING. Validates: all CompensationSnapshots present, attendance data received for all workers, no missing StatutoryRule for cut-off date, no active formula in PENDING_APPROVAL state. |
| 5a | System (pass) | Pre-validation passes | Emits `PreValidationPassed`. PayrollRun transitions: PRE_VALIDATING → RUNNING. Emits `PayrollRunStarted`. |
| 5b | System (fail) | Pre-validation fails (e.g., TA data missing for 3 workers) | Emits `PreValidationFailed` with blocking_issues list. PayrollRun stays in PRE_VALIDATING or transitions to FAILED. Payroll Admin is alerted. Flow halts — resolve blockers and re-initiate run. |
| 6 | System | Gross calculation per worker (parallel batch, partitioned by worker set) | For each worker, Drools KieSession evaluates PayProfile.pay_method. Applies BR-001 to BR-019. See gross calculation sub-flows by pay method (Steps 6A–6E). Emits `GrossCalculationCompleted` when all workers processed. |
| 7 | System | SI contribution calculation per worker | For each worker, system looks up SiEligibilityMatrix by contract_type. For eligible contract types, calculates SI basis = sum of pay elements where si_basis_inclusion = INCLUDED. Applies: BHXH employee 8%, BHYT employee 1.5%, BHTN employee 1% (BR-020 to BR-024). SI ceiling = 20 × VN_LUONG_CO_SO (currently 2,340,000 VND × 20 = 46,800,000 VND per BR-026). If SI basis > ceiling, cap is applied. BHXH employer 17.5%, BHYT employer 3%, BHTN employer 1% (BR-021, BR-023, BR-025) are computed for GL purposes. Emits `StatutoryDeductionsCalculated`. |
| 8 | System | PIT withholding calculation per worker | System determines tax residency (resident vs. non-resident) from CompensationSnapshot.tax_residency_status. For residents: PIT taxable = gross − SI employee − personal deduction (11,000,000 VND) − dependents × 4,400,000 VND (BR-050, BR-051). Applies 7-bracket progressive PIT schedule per NQ 954/2020 (BR-041). For non-residents: 20% flat on gross (BR-042). Emits `PitCalculated`. |
| 9 | System | Net salary calculation per worker | Net = Gross − SI (employee total) − PIT − Other Deductions (in priority order per BR-060). Applies PayProfile.rounding_method. Validates: net ≥ 0 (BR-063). Checks net ≥ regional minimum wage (BR-070 to BR-073). Emits `NetCalculationCompleted`. |
| 10 | System | Exception flagging | For each worker: if net < 0, flags NEGATIVE_NET exception. If SI-eligible but SI_basis = 0, flags ZERO_BHXH_SI_ELIGIBLE exception. If OT hours > monthly cap, flags OT_CAP_EXCEEDED exception. If minimum wage violated, flags MIN_WAGE_VIOLATION exception. |
| 11 | Payroll Admin | Reviews exceptions in portal | Admin reviews each PayrollException. For each, either corrects underlying data (re-runs) or acknowledges with `AcknowledgeException` command and reason_code. |
| 12 | System | All exceptions acknowledged check | Once all PayrollExceptions are in ACKNOWLEDGED state, PayrollRun transitions: RUNNING → COMPLETED. Emits `PayrollRunCompleted`. |
| 13 | Payroll Admin | Issues `SubmitForApproval` command | PayrollRun transitions: COMPLETED → PENDING_APPROVAL. Emits `PayrollRunSubmittedForApproval`. HR Manager is notified. |
| 14 | HR Manager | Reviews payroll results at Level 2 | HR Manager inspects aggregate totals, sample worker results, exception acknowledgement log. Issues `ApprovePayrollRun` (Level 2) or `RejectPayrollRun` with reason_code. |
| 15a | System (approved L2) | Level 2 approved | Emits `ApprovalLevelPassed` (level = 2). Finance Manager is notified. |
| 15b | System (rejected L2) | Level 2 rejected | Emits `PayrollRunRejected`. PayrollRun returns to RUNNING state. Payroll Admin must address issues and re-submit. |
| 16 | Finance Manager | Reviews payroll results at Level 3 | Finance Manager reviews total labor cost, GL impact, bank payment total. Issues `ApprovePayrollRun` (Level 3) or `RejectPayrollRun`. |
| 17a | System (approved L3) | Final approval granted | Emits `PayrollRunApproved`. PayPeriod transitions: RUNNING → PENDING_APPROVAL → APPROVED. |
| 17b | System (rejected L3) | Final rejected | Emits `PayrollRunRejected`. Returns to Payroll Admin. |
| 18 | System | Period lock | PayPeriod transitions: APPROVED → LOCKED. System generates SHA-256 `integrity_hash` for each PayrollResult. All PayrollResult records transition from DRAFT to FINAL. Emits `PayPeriodLocked`. Emits `IntegrityHashGenerated` per worker. Triggers downstream: BC-04 generates bank files, GL journal, payslips; BC-05 generates BHXH D02-LT. |

---

### Step 6 Sub-flows: Gross Calculation by Pay Method

#### 6A: MONTHLY_SALARY
- Retrieve base_salary from CompensationSnapshot
- If period is full (no join/leave mid-month): gross_base = base_salary
- If partial period: apply PayProfile.proration_method
  - CALENDAR_DAYS: gross_base = base_salary × (actual_calendar_days / period_calendar_days)
  - WORK_DAYS: gross_base = base_salary × (actual_work_days / standard_work_days)
- Add eligible allowances: sum of elements where classification = EARNINGS

#### 6B: HOURLY (see UCF-02 for full detail)
- Retrieve HourlyRateConfig from PayProfile
- For each shift_type, apply rate_per_hour × hours_worked
- Apply OT premium multipliers for OT_WEEKDAY (150%), OT_WEEKEND (200%), OT_HOLIDAY (300%)

#### 6C: PIECE_RATE (see UCF-03 for full detail)
- Retrieve PieceRateTable from PayProfile
- For each (product_code, quality_grade): gross += quantity × rate_per_unit
- Apply quality multiplier

#### 6D: GRADE_STEP
- Retrieve grade_code and step_code from CompensationSnapshot
- Look up PayScaleTable: TABLE_LOOKUP returns salary_amount_vnd directly; COEFFICIENT_FORMULA multiplies coefficient × VN_LUONG_CO_SO

#### 6E: TASK_BASED
- Check milestone completion triggers from TA or manual input
- For each triggered milestone: add milestone amount to gross
- If FREELANCE contract type: apply 10% withholding (BR-043) instead of progressive PIT

---

### PIT 7-Bracket Progressive Schedule (NQ 954/2020/UBTVQH14)

| Bracket | Taxable Income (VND/month) | Rate |
|---------|--------------------------|------|
| 1 | 0 – 5,000,000 | 5% |
| 2 | 5,000,001 – 10,000,000 | 10% |
| 3 | 10,000,001 – 18,000,000 | 15% |
| 4 | 18,000,001 – 32,000,000 | 20% |
| 5 | 32,000,001 – 52,000,000 | 25% |
| 6 | 52,000,001 – 80,000,000 | 30% |
| 7 | > 80,000,000 | 35% |

Personal deduction: 11,000,000 VND/month. Dependent deduction: 4,400,000 VND/dependent/month.

---

## Alternate Flows

### AF-1: Dry Run / Simulation
- At step 3, if admin issues `InitiatePayrollRun` with run_mode = DRY_RUN or SIMULATION
- System executes all calculation steps (6–10) but does NOT create final PayrollResult records
- Results are preview-only; no approval workflow triggered
- Useful for month-start validation before actual cut-off

### AF-2: Re-run After Rejection
- At step 15b or 17b, after rejection: Payroll Admin corrects data (e.g., updates attendance correction, fixes benefit override)
- Issues new `InitiatePayrollRun` command for the same period (PRODUCTION)
- System creates a new PayrollRun; the previous failed/rejected run is marked as superseded
- The period remains RUNNING (not re-opened) during correction window

### AF-3: Split-Period SI (BR-033)
- At step 7, if SI ceiling or VN_LUONG_CO_SO changed mid-period (new StatutoryRule valid_from is within the current period)
- System splits SI calculation: days before change date use old ceiling; days from change date use new ceiling
- Emits `StatutoryDeductionsCalculated` with split_period_si_flag = true

---

## Exception Flows

### EF-1: TA Data Not Received (HS-1)
- At step 4 (pre-validation): if `AttendanceLocked` event not received for ≥ 1 worker
- System includes MISSING_ATTENDANCE blocking issue in `PreValidationFailed`
- Payroll Admin must either wait for TA to lock attendance, or manually override with default (requires supervisor acknowledgement)
- Once all blocking issues resolved, admin re-runs pre-validation

### EF-2: Negative Net Salary (HS-3)
- At step 9: if gross − SI − PIT − deductions < 0 for a worker
- System does NOT halt the run; flags NEGATIVE_NET exception for that worker
- Payroll Admin must acknowledge before run can be submitted
- Resolution options: (a) waive deductions partially (requires Finance approval), (b) mark as recoverable advance deducted next period, (c) if structural (e.g., unpaid leave entire month), set net = 0 and carry forward
- NEGATIVE_NET workers are excluded from bank payment file generation until resolved

### EF-3: StatutoryRule Missing for Cut-Off Date
- At step 4: if no ACTIVE StatutoryRule found for the required rule_category at cut-off date
- Pre-validation fails with MISSING_STATUTORY_RULE blocking issue
- Platform Admin must create and activate the missing StatutoryRule
- This can occur when a new decree's effective date passes without the rule being entered

### EF-4: PayrollRun Timeout / Infrastructure Failure (HS-5)
- At step 6: if batch processing exceeds configured timeout (default 120 seconds)
- System emits `PayrollRunFailed` with reason = TIMEOUT
- PayrollRun transitions to FAILED state
- Operations team alerted; Drools KieSession partitioning may need adjustment
- Admin may re-initiate run; previous FAILED run is archived

---

## Domain Events Emitted

| Event | Emitted At Step | Payload Key Fields |
|-------|-----------------|-------------------|
| PayPeriodCutOffApplied | 1 | period_id, pay_group_id, cut_off_date, legal_entity_id |
| CompensationSnapshotCreated | 2 | snapshot_id, working_relationship_id, period_id, snapshot_at, base_salary, allowances_json, contract_type |
| PayrollRunQueued | 3 | run_id, period_id, pay_group_id, run_mode, run_type |
| PayrollRunStarted | 5a | run_id, started_at, worker_count |
| PreValidationFailed | 5b | run_id, blocking_issues[{type, working_relationship_id, detail}] |
| GrossCalculationCompleted | 6 | run_id, worker_count, total_gross_amount |
| StatutoryDeductionsCalculated | 7 | run_id, total_si_employee, total_si_employer, split_period_flag |
| PitCalculated | 8 | run_id, total_pit_withheld, non_resident_count |
| NetCalculationCompleted | 9 | run_id, total_net_amount, exception_count |
| ExceptionFlagged | 10 | result_id, working_relationship_id, exception_type, details |
| ExceptionAcknowledged | 11 | result_id, working_relationship_id, exception_type, acknowledged_by, reason_code |
| PayrollRunCompleted | 12 | run_id, completed_at, total_net_amount |
| PayrollRunSubmittedForApproval | 13 | run_id, submitted_by, submitted_at |
| ApprovalLevelPassed | 14/16 | run_id, approval_level, approved_by, approved_at |
| PayrollRunRejected | 15b/17b | run_id, rejection_level, rejected_by, reason_code |
| PayrollRunApproved | 17a | run_id, final_approved_by, approved_at |
| PayPeriodLocked | 18 | period_id, locked_at, worker_count, total_net_amount |
| IntegrityHashGenerated | 18 | result_id, working_relationship_id, sha256_hash |
| WorkerPayrollCalculated | 6–9 (per worker) | result_id, run_id, working_relationship_id, gross, si_total, pit, net |

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-001 | Base salary pro-ration by calendar days |
| BR-002 | Base salary pro-ration by work days |
| BR-003 | Element-level proration override (NONE = always full pay) |
| BR-004 to BR-008 | OT premium multipliers: 150% weekday, 200% weekend, 300% holiday; 30% night shift supplement |
| BR-009 | Hourly rate derivation divisors per PayGroup |
| BR-020 | BHXH employee rate: 8% |
| BR-021 | BHXH employer rate: 17.5% |
| BR-022 | BHYT employee rate: 1.5% |
| BR-023 | BHYT employer rate: 3% |
| BR-024 | BHTN employee rate: 1% |
| BR-025 | BHTN employer rate: 1% |
| BR-026 | SI ceiling = 20 × VN_LUONG_CO_SO (currently 46,800,000 VND/month) |
| BR-027 | SI basis = sum of elements where si_basis_inclusion = INCLUDED |
| BR-028 to BR-032 | SI eligibility by contract type (SiEligibilityMatrix lookup) |
| BR-033 | Split-period SI when ceiling changes mid-period |
| BR-040 | PIT taxable income = gross − SI employee − personal deduction − dependent deductions |
| BR-041 | 7-bracket progressive PIT (NQ 954/2020) |
| BR-042 | Non-resident: 20% flat PIT on gross |
| BR-043 | Freelance/service contract: 10% withholding |
| BR-047 | Monthly PIT computed directly (not annualized) |
| BR-050 | Personal deduction: 11,000,000 VND/month |
| BR-051 | Dependent deduction: 4,400,000 VND/dependent/month |
| BR-060 | Deduction priority order enforcement |
| BR-061 | Net = Gross − SI − PIT − Deductions |
| BR-062 | Rounding per PayProfile.rounding_method |
| BR-063 | Negative net: flag NEGATIVE_NET exception; cannot disburse |
| BR-070 to BR-073 | Regional minimum wage floor check |
| BR-080 | PayPeriod state machine |
| BR-081 | PayrollRun state machine |
| BR-082 | Multi-level approval (Level 2: HR Manager; Level 3: Finance Manager) |
| BR-083 | Approval SLA (configurable) |
| BR-085 | PRODUCTION run approved → period locked; PayrollResult immutable |
| BR-100 | Legal entity isolation (legal_entity_id row-level security) |
| BR-101 | CompensationSnapshot immutability |
| BR-102 | PayrollResult immutability after period lock |
| BR-103 | SHA-256 integrity hash at period lock |

---

## Hot Spots / Risks

- HS-1: TA data completeness — Attendance data must arrive before cut-off. TA module must emit `AttendanceLocked` event reliably; TA late-lock is the most frequent cause of payroll delay.
- HS-3: Negative net salary — Occurs when deductions (loan recovery, advance recovery, overpayment) exceed gross. Must not disburse negative amounts. Exception acknowledgement workflow is the control gate.
- HS-5: Performance at scale — Target: < 30 seconds for 1,000 workers (SO-03). Drools batch must partition workers to parallel KieSessions. CompensationSnapshot immutability enables read-parallelism without locking. StatutoryRule lookup must be cached in-process (invalidated by `StatutoryRuleActivated` event).
- HS-9: Holiday calendar invalidation — If TA emits `HolidayCalendarUpdated` after snapshots are taken, the proration computation may be stale. System must detect and alert.
