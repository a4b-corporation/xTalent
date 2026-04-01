# UCF-07: Termination Final Pay

**Bounded Context**: BC-04 Payment Output (triggers off BC-03 Payroll Execution)
**Timeline**: T3 — Off-Cycle Payroll
**Actors**: HR Manager, Payroll Admin, System
**Trigger**: `WorkerTerminationReceived` event from CO (Core HR) module

---

## Preconditions

- worker has an active `working_relationship` in CO
- Active `PayGroup` membership exists in BC-01
- Current pay period is in OPEN or CUT_OFF state (not LOCKED)
- Termination date is confirmed in CO (`WorkerTerminated` event published)

---

## Main Flow

| Step | Actor | Action | System Response |
|------|-------|--------|-----------------|
| 1 | System (CO) | Publishes `WorkerTerminated` event with `working_relationship_id`, `termination_date`, `termination_type` | PR event handler receives event |
| 2 | System | Creates off-cycle `PayPeriod` (run_type = TERMINATION) covering from last-paid-period-end to `termination_date` | `TerminationPayPeriodCreated` event emitted |
| 3 | System | Takes `CompensationSnapshot` at `termination_date` for the worker | `CompensationSnapshotCreated` event emitted; snapshot is immutable |
| 4 | Payroll Admin | Reviews auto-selected pay elements for final pay; may add/remove configurable elements (e.g., unused annual leave payout, severance) | System shows element checklist per PayProfile rules |
| 5 | Payroll Admin | Submits termination payroll run | `PayrollRunQueued` (run_type=TERMINATION, run_mode=PRODUCTION) |
| 6 | System (Drools) | Calculates gross: prorate base salary to termination date; apply approved elements | `WorkerPayrollCalculated` event emitted |
| 7 | System | Calculates SI deductions (prorated to last working day); check SI eligibility | SI amounts computed per BR-033 (split-period SI) |
| 8 | System | Calculates PIT on final pay: apply cumulative YTD income + final pay; apply family deductions; compute PIT delta | PIT computed per BR-040–051; final PIT certificate triggered if full settlement |
| 9 | System | Computes net pay; checks for negative net (NEGATIVE_NET exception if applicable) | `PayrollRunCompleted` if no blocking exceptions |
| 10 | HR Manager | Approves termination payroll run (Level 2) | `ApprovalRecorded` (LEVEL_2_HR_MANAGER) |
| 11 | Finance Manager | Approves termination payroll run (Level 3) | `ApprovalRecorded` (LEVEL_3_FINANCE_MANAGER) |
| 12 | System | Locks termination pay period; generates `PayrollResult` with `integrity_hash` | `PayPeriodLocked`, `PayrollRunApproved` events emitted |
| 13 | System (BC-04) | Generates final payslip PDF with all element breakdowns and termination date | `FinalPayslipGenerated` event emitted |
| 14 | System (BC-04) | Generates bank payment file for final net pay disbursement | `TerminationBankPaymentCreated` event emitted |
| 15 | System (BC-05) | Generates PIT withholding certificate (Form 05/QTT-TNCN variant) if requested or year-end | `PitCertificateIssued` event emitted |
| 16 | System (BC-07) | Records all state changes to AuditLog with immutable entries | Audit trail complete |

---

## Alternate Flows

### AF-1: Termination Date Falls Mid-Period (not at period end)
- At step 2: system creates partial period from last full period end to termination date
- At step 6: proration applies — `actual_working_days / total_calendar_days × monthly_salary`
- Business rule: BR-002 (calendar-day proration) or BR-003 (working-day proration) per PayProfile setting

### AF-2: Worker Has GRADE_STEP Pay Method
- At step 6: system looks up `pay_scale_table` for current `grade_code` × `step_code`
- Applies prorated scale amount instead of base_salary

### AF-3: Unused Annual Leave Payout
- At step 4: Payroll Admin selects "annual leave payout" element
- System calculates: `remaining_leave_days × daily_rate`; daily_rate = `monthly_salary / 26` (BR-001)
- Amount added to gross; subject to PIT but NOT SI

### AF-4: Severance Pay (Trợ cấp thôi việc)
- Applies when `termination_type = VOLUNTARY_RESIGNATION` and tenure >= 12 months
- Severance = 0.5 × monthly_salary × years_worked (Labor Code Art. 46)
- Exempt from PIT if within statutory threshold (BR-048)
- NOT subject to SI

---

## Exception Flows

### EF-1: TA Data Incomplete at Termination Date
- At step 3: `AttendanceLocked` event not yet received from TA for the final period
- System creates exception: TA_DATA_MISSING; run blocked
- Payroll Admin can override with manual attendance input (requires reason_code = MANUAL_ATTENDANCE_OVERRIDE)
- Resolves HS-1 (TA data completeness)

### EF-2: Negative Net Salary
- At step 9: computed net is negative (e.g., large PIT on bonus + advance deduction)
- `NEGATIVE_NET` exception flagged per PayrollException
- Payroll Admin must acknowledge with resolution: ZERO_NET_WITH_RECOVERY (excess recovered from future payments) or SET_TO_ZERO (absorb by company)
- Resolves HS-3

### EF-3: Approval Rejected
- At step 10 or 11: Approver rejects the run
- `PayrollRunRejected` event emitted; run status → FAILED
- Payroll Admin must correct and re-initiate (new run_id created)
- Original rejected run is retained for audit purposes

### EF-4: Worker Has Active Salary Advance Deduction
- At step 8: system detects outstanding advance balance from advance_deduction PayElement
- Full outstanding balance deducted from final net pay
- If final net insufficient, remainder flagged as PARTIAL_RECOVERY exception

---

## Domain Events Emitted

| Event | Emitted At Step | Payload Key Fields |
|-------|-----------------|-------------------|
| `TerminationPayPeriodCreated` | 2 | period_id, working_relationship_id, termination_date, legal_entity_id |
| `CompensationSnapshotCreated` | 3 | snapshot_id, working_relationship_id, period_id, snapshot_at |
| `PayrollRunQueued` | 5 | run_id, run_type=TERMINATION, run_mode=PRODUCTION, period_id |
| `WorkerPayrollCalculated` | 6 | result_id, run_id, working_relationship_id, gross_amount |
| `PayrollRunCompleted` | 9 | run_id, worker_count=1, exception_count |
| `ApprovalRecorded` | 10, 11 | run_id, approval_level, action, actor_id, timestamp |
| `PayrollRunApproved` | 12 | run_id, final_approval_at |
| `PayPeriodLocked` | 12 | period_id, locked_at, integrity_hash |
| `FinalPayslipGenerated` | 13 | payslip_id, working_relationship_id, period_id, document_url |
| `TerminationBankPaymentCreated` | 14 | payment_file_id, working_relationship_id, net_amount, bank_account_id |
| `PitCertificateIssued` | 15 | certificate_id, working_relationship_id, ytd_income, ytd_pit |

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-002 | Calendar-day proration: salary × (actual_days / calendar_days_in_period) |
| BR-003 | Working-day proration: salary × (actual_working_days / standard_working_days) |
| BR-020–035 | SI contribution rates: BHXH employee 8%, employer 17.5%; BHYT employee 1.5%, employer 3%; BHTN employee 1%, employer 1% |
| BR-033 | Split-period SI: SI ceiling applies proportionally to partial period |
| BR-040–051 | PIT progressive brackets for resident workers; 20% flat for non-resident |
| BR-048 | Severance/redundancy pay within statutory threshold exempt from PIT |
| BR-061 | Deduction order: statutory SI first, then PIT, then other deductions |
| BR-080 | Off-cycle run requires explicit run_type declaration |
| BR-082 | Two-level approval required for all PRODUCTION runs |
| BR-096 | PayrollResult integrity hash must be recorded at period lock |
| BR-100 | legal_entity_id must match across period, run, snapshot, and result |

---

## Hot Spots / Risks

- **HS-3 (Negative net salary)**: Final pay scenarios (advance recovery + PIT) are the most common source of negative net. The PARTIAL_RECOVERY exception path must be fully implemented.
- **HS-5 (Performance)**: Termination runs are single-worker — no batch performance concern.
- **HS-8 (Bank file rejection)**: No payment confirmation feedback in V1. Bank rejection not surfaced back to PR.
