# Cross-Module Data Flow Map

**Scope**: Complete data flow between CO, TA, TR, PR modules  
**Assessed**: 2026-03-16

---

## 1. Module Dependency Graph

```
                    ┌──────────────┐
                    │  CORE (CO)   │
                    │  Foundation   │
                    └───┬──┬──┬────┘
                        │  │  │
              ┌─────────┘  │  └──────────┐
              ▼            ▼             ▼
        ┌───────────┐ ┌────────────┐ ┌──────────┐
        │  TA       │ │  TR        │ │  PR      │
        │  Time &   │ │  Total     │ │  Payroll │
        │  Absence  │ │  Rewards   │ │          │
        └─────┬─────┘ └──────┬─────┘ └──────────┘
              │              │             ▲
              │              │             │
              └──────────────┴─────────────┘
                   (Both feed into PR)
```

**Direction**: CO → {TA, TR, PR} → PR aggregates for processing

---

## 2. Data Flow Detail — CO → Other Modules

### 2.1 CO → TA

| Data | CO Source | TA Consumer | Frequency |
|------|----------|-------------|:---------:|
| Employee record | `employment.employee` | `ta.shift.*`, `absence.leave_*` FK | Real-time |
| Assignment/Position | `employment.assignment` | Schedule assignment eligibility | Real-time |
| Work pattern | `employment.assignment.work_pattern_code` | `ta.pattern_template` link | Real-time |
| Eligibility profiles | `eligibility.eligibility_profile` | Leave type/class/policy profiles | On change |
| Holiday calendar | `common.holiday_calendar` [proposed] | Leave calculation | On change |

### 2.2 CO → TR

| Data | CO Source | TR Consumer | Frequency |
|------|----------|-------------|:---------:|
| Employee record | `employment.employee` | `employee_comp_snapshot`, `enrollment` | Real-time |
| Job/Grade | `jobpos.job.grade_code` | `comp_core.grade_v` lookup | On change |
| Position | `jobpos.position` | Pay range determination | On change |
| Worker | `person.worker` | `tr_offer.offer_package.worker_id` | Real-time |
| Eligibility profiles | `eligibility.eligibility_profile` [proposed] | Benefit plan eligibility | On change |
| Country config | `common.country_config` [proposed] | Statement/proration parameters | On change |

### 2.3 CO → PR

| Data | CO Source | PR Consumer | Frequency |
|------|----------|-------------|:---------:|
| Employee record | `employment.employee` | `pay_run.result.employee_id` | Per run |
| Legal entity | `org_legal.entity` | `pay_master.pay_group.legal_entity_id` | Setup |
| Assignment | `employment.assignment` | Pay group determination | Per run |
| Compensation basis | `compensation.basis` | Base salary input | Per run |
| Country config | `common.country_config` [proposed] | Working days, parameters | Setup |
| Holiday calendar | `common.holiday_calendar` [proposed] | OT multiplier | Per run |

---

## 3. Data Flow Detail — TA → PR

### 3.1 Current (Informal)

```
TA                                    PR
──                                    ──
ta.attendance_record
  → worked hours             ──?──▶  pay_run.input_value
ta.overtime_calculation
  → OT hours by type         ──?──▶  pay_run.input_value
absence.leave_movement
  → paid/unpaid leave         ──?──▶  pay_run.input_value
ta.timesheet_entry (APPROVED)
  → reviewed hours            ──?──▶  pay_run.input_value

No formal API, no staging, no event contract.
```

### 3.2 Proposed (Formal)

```yaml
# TA → PR Attendance Data API
POST /api/v1/payroll/input/attendance
{
  "source": "TA",
  "period": { "start": "2026-03-01", "end": "2026-03-31" },
  "employees": [
    {
      "employee_id": "uuid",
      "attendance_summary": {
        "regular_hours": 160.0,
        "overtime": {
          "weekday_normal": 12.0,
          "weekday_night": 4.0,
          "weekend": 8.0,
          "holiday": 0.0
        },
        "absence": {
          "paid_leave_days": 2.0,
          "unpaid_leave_days": 0.0,
          "sick_leave_days": 1.0
        },
        "working_days_in_period": 22,
        "actual_working_days": 19,
        "late_arrivals": 2,
        "early_departures": 0
      }
    }
  ]
}
```

### 3.3 Event Contract (AsyncAPI)

```yaml
events:
  ta.attendance.period.approved:
    description: Period attendance approved by supervisor
    payload:
      employee_id: uuid
      period_start: date
      period_end: date
      approved_by: uuid
      summary_url: string  # GET URL for full summary

  ta.overtime.approved:
    description: OT request approved
    payload:
      employee_id: uuid
      ot_date: date
      ot_hours: decimal
      ot_type: WEEKDAY | WEEKEND | HOLIDAY
      approved_by: uuid

  ta.leave.approved:
    description: Leave request approved
    payload:
      employee_id: uuid
      leave_type: string
      start_date: date
      end_date: date
      is_paid: boolean
      total_days: decimal
```

---

## 4. Data Flow Detail — TR → PR

### 4.1 Compensation Snapshot

```
TR                                    PR
──                                    ──
employee_comp_snapshot (ACTIVE)
  → component amounts         ──API──▶  pay_staging.input_record
comp_adjustment (APPROVED, this period)
  → salary changes             ──API──▶  pay_staging.input_record (+ retro)
bonus_allocation (APPROVED)
  → bonus amounts              ──API──▶  pay_staging.input_record
taxable_item (PENDING)
  → equity/perk tax events     ──API──▶  pay_staging.input_record
enrollment.premium_employee
  → benefit deductions         ──API──▶  pay_staging.input_record
```

### 4.2 Event Contract

```yaml
events:
  tr.compensation.snapshot.updated:
    description: Employee compensation changed
    payload:
      employee_id: uuid
      effective_date: date
      change_type: HIRE | PROMOTION | ANNUAL_REVIEW | ADJUSTMENT
      components: [{ code, amount, currency }]

  tr.bonus.allocated:
    description: Bonus approved for payroll processing
    payload:
      employee_id: uuid
      bonus_plan_code: string
      amount: decimal
      currency: string
      effective_date: date

  tr.taxable_item.created:
    description: New taxable item for payroll
    payload:
      employee_id: uuid
      source_module: EQUITY | BENEFIT | PERK | RECOGNITION
      amount: decimal
      tax_year: int

  tr.benefit.premium.changed:
    description: Benefit premium changed
    payload:
      employee_id: uuid
      enrollment_id: uuid
      premium_amount: decimal
      effective_date: date
```

---

## 5. Data Flow Detail — PR → Outbound

### 5.1 PR → External Systems

```
PR                                    External
──                                    ────────
pay_run.result
  → payslip data              ──File──▶  Employee Self-Service (PDF)
pay_bank.payment_batch/line
  → payment instructions      ──File──▶  Banking System (MT103/MT940)
pay_run.costing + gl_mapping
  → GL entries                ──API──▶   Finance/ERP System
tax_report_template + results
  → tax declarations          ──File──▶  Tax Authority (XML/PDF)
```

### 5.2 PR → TR (Feedback Loop)

```yaml
# PR publishes payroll results for TR Statement generation
events:
  pr.payrun.completed:
    description: Pay run completed successfully
    payload:
      batch_id: uuid
      period: { start: date, end: date }
      legal_entity_id: uuid
      employee_count: int
      results_url: string  # GET URL for results

# TR queries PR for statement data
GET /api/v1/payroll/results/{batch_id}/employee/{employee_id}
Response:
{
  "employee_id": "uuid",
  "period": { "start": "2026-03-01", "end": "2026-03-31" },
  "components": [
    { "code": "BASE_SALARY", "gross": 30000000, "deductions": 3150000, "net": 26850000 },
    { "code": "LUNCH_ALLOWANCE", "gross": 730000, "deductions": 0, "net": 730000 }
  ],
  "totals": {
    "gross": 30730000,
    "si_employee": 3150000,
    "pit": 3600000,
    "net": 23980000,
    "si_employer": 5550000,
    "total_cost": 36280000
  }
}
```

---

## 6. Complete Flow — Pay Period Lifecycle

```
Day 1-25: Data Collection
  ├── TA: Attendance tracking, OT, leave requests
  ├── TR: Compensation changes, bonus approvals, benefit enrollment
  └── CO: New hires, terminations, transfers

Day 26: Period Closing
  ├── TA: Supervisor reviews → approve timesheets
  │     → Emit: ta.attendance.period.approved
  ├── TR: HR reviews → approve compensation changes
  │     → Emit: tr.compensation.snapshot.updated
  └── CO: Confirm employee roster for period

Day 27: Payroll Input Collection
  └── PR: 
      ├── Receive TA attendance data (API/Event)
      ├── Receive TR compensation snapshot (API/Event)
      ├── Stage all inputs → pay_staging.input_record
      └── Validate inputs → flag errors

Day 28: Payroll Execution
  └── PR:
      ├── Pre-validation (Stage 1)
      ├── Gross calculation (Stage 2)
      ├── Insurance calculation (Stage 3)
      ├── Tax calculation (Stage 4)
      ├── Net + post-process (Stage 5)
      └── Status: CALCULATED → review

Day 29: Approval & Output
  └── PR:
      ├── Manager/HR review → APPROVE
      ├── Generate: Payslips (PDF)
      ├── Generate: Bank file (MT103)
      ├── Generate: GL entries
      ├── Generate: Tax reports
      └── Emit: pr.payrun.completed

Day 30: Distribution
  ├── PR → Bank: Payment execution
  ├── PR → Finance: GL posting
  ├── PR → Employee: Payslip distribution
  └── PR → TR: Results for statement generation
```

---

## 7. Integration Protocol Summary

| Integration | Protocol | Trigger | Direction |
|------------|:--------:|---------|:---------:|
| CO → TA | FK + Events | Real-time | → |
| CO → TR | FK + Events | Real-time | → |
| CO → PR | FK + API | Per run | → |
| TA → PR | API + Events | Period close | → |
| TR → PR | API + Events | Period close + on-demand | → |
| PR → Bank | File export | Post-approval | → |
| PR → Finance | API/File | Post-approval | → |
| PR → TR (feedback) | API + Events | Post-completion | ← |
| PR → Employee | File (PDF) | Post-approval | → |

---

*← [07 TR-PR Boundary Resolution](./07-tr-pr-boundary-resolution.md) · [09 Naming Convention Standard →](./09-naming-convention-standard.md)*
