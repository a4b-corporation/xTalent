# Integration Event Model & Data Flow Specification

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-06  
**Đối tượng**: Integration Engineer, Backend Developer, Solution Architect  
**Thời gian đọc**: ~25 phút

---

## 1. Tổng quan Data Flow

```
┌────────┐    ┌────────┐    ┌────────┐
│   CO   │    │   TR   │    │   TA   │
│  Core  │    │ Total  │    │ Time & │
│   HR   │    │Rewards │    │Absence │
└───┬────┘    └───┬────┘    └───┬────┘
    │             │             │
    │ Employee    │ Comp        │ Attendance
    │ Assignment  │ Salary      │ Overtime
    │ LegalEntity │ Bonus       │ Leave
    │ Job         │ Taxable     │
    │ Termination │ Benefits    │
    │             │             │
    ▼             ▼             ▼
┌─────────────────────────────────────┐
│         PAYROLL SERVICE (PR)         │
│                                      │
│  Input    →  Engine   →  Output      │
│  Staging     Drools      Results     │
│              Formula     Payslips    │
│              Pipeline    Bank Files  │
│                          GL Entries  │
└────────┬──────────┬──────────┬──────┘
         │          │          │
         ▼          ▼          ▼
    ┌────────┐ ┌────────┐ ┌────────┐
    │  Bank  │ │   GL   │ │  Tax   │
    │Systems │ │Accounts│ │ Filing │
    └────────┘ └────────┘ └────────┘
```

---

## 2. Inbound Data Flows

### 2.1 CO → PR: Employee & Organization Data

| Data Flow | Source Entity (CO) | Target use in PR | Trigger |
|-----------|-------------------|-----------------|---------|
| Employee master | `employment.employee` | Employee selection for payroll run | Employee created/updated |
| Assignment | `employment.assignment` | Pay group assignment, grade context | Assignment changed |
| Legal Entity | `org_legal.entity` | Calendar/group scope, SI rules | Entity config changed |
| Job | `employment.job` | Grade-based calculations | Job changed |
| Bank details | `person.bank_account` (CO owns) | Payment line generation | Account updated |
| Termination | `employment.employee.termination_date` | Final paycheck trigger | Employee terminated |
| Transfer | `employment.assignment.business_unit_id` | Pay group change | Transfer processed |

**Event Catalog (CO → PR)**:

```yaml
event: co.employee.created
payload:
  employee_id: uuid
  person_id: uuid
  legal_entity_id: uuid
  hire_date: date
  employment_type: "FULL_TIME | PART_TIME | CONTRACTOR"
trigger: New employee onboarding

event: co.employee.terminated
payload:
  employee_id: uuid
  termination_date: date
  termination_type: "VOLUNTARY | INVOLUNTARY | RETIREMENT"
  final_pay_date: date
trigger: Termination processed in CO
action: PR queues final paycheck calculation

event: co.assignment.changed
payload:
  employee_id: uuid
  assignment_id: uuid
  changes:
    - field: "business_unit_id"
      old: "bu-old"
      new: "bu-new"
    - field: "grade_code"
      old: "G5"
      new: "G6"
  effective_date: date
trigger: Assignment update (promotion, transfer, etc.)
action: PR updates pay_group assignment if changed
```

### 2.2 TR → PR: Compensation Data

| Data Flow | Source Entity (TR) | Target use in PR | Trigger |
|-----------|-------------------|-----------------|---------|
| Base salary | `comp_core.employee_comp_snapshot` (ACTIVE, BASE) | `pay_run.input_value` (BASE_SALARY) | Comp snapshot created/updated |
| Allowances | `comp_core.employee_comp_snapshot` (ACTIVE, ALLOWANCE) | `pay_run.input_value` (LUNCH, TRANSPORT...) | Comp snapshot created |
| Bonus allocation | `comp_incentive.bonus_allocation` (APPROVED) | `pay_run.input_value` (BONUS) | Bonus approved |
| Equity vest | `comp_incentive.equity_vesting_event` | `tr_taxable.taxable_item` → PR taxable income | Vest event triggered |
| Perk redemption | `recognition.perk_redeem` (FULFILLED) | `tr_taxable.taxable_item` → PR taxable income | Perk redeemed |
| Benefit premium | `benefit.enrollment` (ACTIVE) | `pay_run.input_value` (DEDUCTION) | Enrollment created/changed |
| Compensation change | `comp_core.comp_adjustment` (APPROVED) | Updated base salary (may trigger retro) | Adjustment approved |
| Deduction transaction | `benefit.reimbursement_request` (APPROVED) | `pay_run.input_value` (REIMBURSEMENT) | Reimbursement approved |

**Event Catalog (TR → PR)**:

```yaml
event: tr.compensation.snapshot_updated
payload:
  employee_id: uuid
  assignment_id: uuid
  components:
    - code: "BASE_SALARY"
      amount: 30000000
      currency: "VND"
      frequency: "MONTHLY"
      effective_start: "2025-01-01"
    - code: "LUNCH_ALLOWANCE"
      amount: 730000
      currency: "VND"
  source: "COMP_ADJUSTMENT | OFFER_PACKAGE | MANUAL"
  source_ref: "adj-uuid-001"
trigger: New compensation snapshot activated
action: PR stores as pending input for next pay period

event: tr.bonus.approved
payload:
  employee_id: uuid
  bonus_plan_code: "ANNUAL_STI"
  cycle_code: "2025-Q1"
  approved_amount: 15000000
  currency: "VND"
  payment_schedule: "NEXT_REGULAR_RUN | SEPARATE_RUN"
trigger: Bonus allocation approved by manager
action: PR creates BONUS input value

event: tr.taxable_item.created
payload:
  id: uuid
  employee_id: uuid
  source_module: "EQUITY | BENEFIT | PERK | RECOGNITION"
  source_type: "RSU_VEST | GIFT_CARD | CAR_ALLOWANCE"
  taxable_amount: 50000000
  currency: "VND"
  tax_year: 2025
  description: "RSU vest: 100 shares @ 500,000 VND"
trigger: Equity vest event / perk redemption
action: PR adds to employee's taxable income for period

event: tr.benefit.enrollment_changed
payload:
  employee_id: uuid
  plan_code: "HEALTH_PREMIUM"
  option_code: "FAMILY"
  premium_employee: 500000
  premium_employer: 1500000
  currency: "VND"
  coverage_start: "2025-01-01"
  change_type: "NEW | UPDATE | CANCEL"
trigger: Benefit enrollment created/changed
action: PR creates/updates DEDUCTION input
```

### 2.3 TA → PR: Attendance & Time Data

| Data Flow | Source (TA) | Target use in PR | Trigger |
|-----------|------------|-----------------|---------|
| Working days | Attendance summary | Proration calculation | Period attendance locked |
| Overtime hours | OT records by type | OT pay calculation | Period attendance locked |
| Leave days (paid) | `absence.leave_movement` | Paid leave inclusion | Leave approved + posted |
| Leave days (unpaid) | `absence.leave_movement` (UNPAID type) | Salary reduction | Leave approved + posted |
| Late/absent penalties | Attendance violations | Deduction element | Period locked |

**Event Catalog (TA → PR)**:

```yaml
event: ta.attendance.period_locked
payload:
  period:
    start: "2025-03-01"
    end: "2025-03-31"
  calendar_code: "VN_MONTHLY_2025"
  employees:
    - employee_id: "emp-001"
      standard_days: 22
      actual_days: 20
      absent_days: 2
      absent_paid: 2
      absent_unpaid: 0
      overtime:
        - type: "WEEKDAY_NORMAL"
          hours: 10
        - type: "WEEKEND"
          hours: 8
        - type: "HOLIDAY"
          hours: 0
      late_count: 1
      early_leave_count: 0
trigger: HR/manager locks attendance period
action: PR marks attendance data ready, creates input values
```

---

## 3. Outbound Data Flows

### 3.1 PR → Banking

```yaml
event: payroll.bank.file_ready
payload:
  run_id: uuid
  bank_code: "VCB | VIETIN | BIDC"
  file_type: "CSV | TXT | XML"
  file_url: "/payroll/2025/03/VCB_payment_20250325.csv"
  total_employees: 150
  total_amount: 3555000000
  currency: "VND"
  submitted_at: timestamp
trigger: Payroll run finalized
```

### 3.2 PR → GL (Accounting)

```yaml
event: payroll.gl.entries_posted
payload:
  run_id: uuid
  gl_batch_id: uuid
  period: { start: "2025-03-01", end: "2025-03-31" }
  entries:
    - account: "6411"   # Salary expense
      debit: 4500000000
      credit: 0
    - account: "3341"   # Salary payable
      debit: 0
      credit: 3555000000
    - account: "3383"   # BHXH payable (EE + ER)
      debit: 0
      credit: 630000000
    - account: "3384"   # BHYT payable
      debit: 0
      credit: 135000000
    - account: "3386"   # BHTN payable
      debit: 0
      credit: 90000000
    - account: "3335"   # PIT payable
      debit: 0
      credit: 90000000
  total_entries: 6
  currency: "VND"
trigger: Payroll run finalized + costing applied
```

### 3.3 PR → Tax Authorities

```yaml
event: payroll.tax.report_generated
payload:
  run_id: uuid
  report_type: "05QTT_TNCN | 02KK_TNCN"
  period: { start: "2025-03-01", end: "2025-03-31" }
  file_url: "/payroll/2025/03/05QTT_TNCN_Q1_2025.xml"
  total_pit: 90000000
  total_employees: 150
  filing_deadline: "2025-04-20"
trigger: Quarter end / Year end
```

### 3.4 PR → Employee (Payslip)

```yaml
event: payroll.payslip.generated
payload:
  employee_id: uuid
  run_id: uuid
  period: { start: "2025-03-01", end: "2025-03-31" }
  file_url: "/payslips/2025/03/emp-001_payslip.pdf"
  gross: 33287000
  net: 29653300
  currency: "VND"
  generated_at: timestamp
trigger: Payroll finalized
action: Employee notification (email/app push)
```

---

## 4. Sequence Diagrams

### 4.1 Regular Monthly Payroll — Happy Path

```
HR Admin        TA Module       TR Module       PR Module        Bank       GL
   │               │               │               │              │          │
   │               │               │               │              │          │
   │  1. Lock attendance period    │               │              │          │
   │──────────────▶│               │               │              │          │
   │               │──ta.attendance.period_locked──▶│              │          │
   │               │               │               │              │          │
   │               │               │  2. Send comp │              │          │
   │               │               │  snapshot     │              │          │
   │               │               │──tr.comp.snap─▶│              │          │
   │               │               │               │              │          │
   │               │               │  3. Send      │              │          │
   │               │               │  taxable items│              │          │
   │               │               │──tr.taxable───▶│              │          │
   │               │               │               │              │          │
   │  4. Create payroll run        │               │              │          │
   │──────────────────────────────────────────────▶│              │          │
   │               │               │               │              │          │
   │  5. Calculate (DRY_RUN)       │               │              │          │
   │──────────────────────────────────────────────▶│              │          │
   │               │               │               │◄─────────────│          │
   │               │               │               │  (internal   │          │
   │               │               │               │   Drools)    │          │
   │◄──────────────────────────────────────────────│              │          │
   │    Results preview             │               │              │          │
   │               │               │               │              │          │
   │  6. Review & Approve          │               │              │          │
   │──────────────────────────────────────────────▶│              │          │
   │               │               │               │              │          │
   │  7. Finalize                  │               │              │          │
   │──────────────────────────────────────────────▶│              │          │
   │               │               │               │──bank file──▶│          │
   │               │               │               │──gl entries─────────────▶│
   │               │               │               │──payslips───▶(Employee)  │
   │               │               │               │              │          │
   │               │               │               │──payroll.run.finalized──▶│
   │               │               │               │  (event broadcast)       │
```

### 4.2 Taxable Bridge Flow (Equity Vest → Payroll)

```
Employee    TR Equity       TR Taxable      PR Module
   │           │                │               │
   │  RSU vest │                │               │
   │  event    │                │               │
   │──────────▶│                │               │
   │           │                │               │
   │           │ 1. Record      │               │
   │           │ vest event     │               │
   │           │ (equity_       │               │
   │           │  vesting_      │               │
   │           │  event)        │               │
   │           │                │               │
   │           │ 2. Create      │               │
   │           │ taxable item   │               │
   │           │───────────────▶│               │
   │           │                │               │
   │           │                │ 3. Publish    │
   │           │                │ tr.taxable_   │
   │           │                │ item.created  │
   │           │                │──────────────▶│
   │           │                │               │
   │           │                │               │ 4. Add to
   │           │                │               │ employee's
   │           │                │               │ taxable
   │           │                │               │ income
   │           │                │               │
   │           │                │               │ 5. During
   │           │                │               │ payroll run:
   │           │                │               │ include in
   │           │                │               │ PIT calc
   │           │                │               │
   │           │                │ 6. Mark       │
   │           │                │ processed     │
   │           │                │◄──────────────│
   │           │                │ processed_    │
   │           │                │ flag = true   │
```

### 4.3 Retroactive Adjustment Flow

```
HR Admin       TR Module          PR Module
   │               │                  │
   │  1. Approve   │                  │
   │  salary       │                  │
   │  increase     │                  │
   │  effective    │                  │
   │  Jan 1 (now   │                  │
   │  is March)    │                  │
   │──────────────▶│                  │
   │               │                  │
   │               │ 2. New snapshot  │
   │               │ effective Jan 1  │
   │               │ base: 28M → 30M │
   │               │──comp.changed──▶│
   │               │                  │
   │               │                  │ 3. PR detects
   │               │                  │ retro: diff for
   │               │                  │ Jan + Feb =
   │               │                  │ 2M × 2 = 4M
   │               │                  │
   │ 4. Create     │                  │
   │ RETRO batch   │                  │
   │──────────────────────────────────▶│
   │               │                  │
   │               │                  │ 5. Calculate
   │               │                  │ retro delta:
   │               │                  │ recalc Jan & Feb
   │               │                  │ with new salary
   │               │                  │ delta = new - old
   │               │                  │
   │◄─────────────────────────────────│
   │  Retro results:                  │
   │  Jan delta: +2,000,000          │
   │  Feb delta: +2,000,000          │
   │  Tax diff: +xxx                 │
   │  SI diff: +yyy                  │
```

---

## 5. Error Handling & Retry Strategy

### 5.1 Event Processing Errors

| Error Type | Strategy | Max Retries | Backoff |
|-----------|----------|:-----------:|---------|
| Network timeout | Retry with exponential backoff | 5 | 1s, 2s, 4s, 8s, 16s |
| Validation error | Dead-letter queue + alert | 0 | N/A (manual fix) |
| Partial failure | Continue processing, flag failed records | N/A | Individual retry |
| Duplicate event | Idempotency check (event_id + idempotency_key) | N/A | Skip |

### 5.2 Data Consistency

| Scenario | Risk | Mitigation |
|----------|------|-----------|
| TR snapshot updated mid-payroll | Using stale data | **Cutoff rule**: lock input data before calculation |
| TA attendance corrected after payroll | Incorrect pay | **Retro batch**: detect changes, create adjustment |
| CO termination during payroll | Employee in run | **Status check**: validate employee active at calculation time |
| Bank file rejected | Payment failed | **Retry + manual fallback**: re-generate with corrections |

---

## 6. Data Contract Summary

| Direction | Source | Target | Data | Volume (monthly) |
|:---------:|:------:|:------:|------|:-----------------:|
| **IN** | CO | PR | Employee/Assignment | ~200 events |
| **IN** | TR | PR | Compensation snapshots | ~500 events |
| **IN** | TR | PR | Bonus allocations | ~50 events |
| **IN** | TR | PR | Taxable items | ~20 events |
| **IN** | TR | PR | Benefit premiums | ~100 events |
| **IN** | TA | PR | Attendance summaries | 1 batch/period (~500 records) |
| **OUT** | PR | Bank | Payment files | 1-3 files/period |
| **OUT** | PR | GL | Journal entries | 5-20 entries/period |
| **OUT** | PR | Tax | Filing reports | 1 report/quarter |
| **OUT** | PR | Employee | Payslips | ~500 files/period |

---

*← [05 Design Assessment](./05-design-assessment.md) · [README →](./README.md)*
