# Payroll-as-a-Service — API Contract Design

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-06  
**Đối tượng**: Solution Architect, Backend Developer, Integration Engineer  
**Thời gian đọc**: ~25 phút

---

## 1. Mục tiêu

Định nghĩa API Contract để PR module có thể vận hành như một **independent service** — nhận input từ bất kỳ HCM platform (xTalent, 3rd party), thực thi payroll, trả kết quả.

**Nguyên tắc thiết kế**:
1. **Contract First**: OpenAPI spec → implementation
2. **Stateless**: Cùng input → cùng output
3. **Idempotent**: Retry safe
4. **Versioned**: v1, v2... backward compatible
5. **Secure**: OAuth2, data masking, rate limiting

---

## 2. API Domain Model

```
PR Service API Surface:
│
├── Configuration APIs (Setup & Config)
│   ├── /pay-calendars
│   ├── /pay-groups
│   ├── /pay-elements
│   ├── /pay-profiles
│   ├── /statutory-rules
│   ├── /pay-formulas
│   └── /country-configs
│
├── Input APIs (Data Ingestion)
│   ├── /payroll-inputs/compensation  ← from TR
│   ├── /payroll-inputs/attendance    ← from TA
│   ├── /payroll-inputs/taxable-items ← from TR (equity/perks)
│   ├── /payroll-inputs/adjustments   ← manual/HR
│   └── /payroll-inputs/benefits      ← from TR (premiums)
│
├── Execution APIs (Payroll Processing)
│   ├── /payroll-runs (CRUD + lifecycle)
│   ├── /payroll-runs/{id}/calculate  ← dry-run / simulation
│   ├── /payroll-runs/{id}/approve
│   ├── /payroll-runs/{id}/finalize
│   └── /payroll-runs/{id}/reverse
│
├── Output APIs (Results & Reports)
│   ├── /payroll-runs/{id}/results
│   ├── /payroll-runs/{id}/payslips
│   ├── /payroll-runs/{id}/bank-files
│   ├── /payroll-runs/{id}/gl-entries
│   ├── /payroll-runs/{id}/tax-reports
│   └── /payroll-runs/{id}/calc-logs
│
└── Event APIs (Async Integration)
    ├── Webhooks/Event subscriptions
    └── AsyncAPI event catalog
```

---

## 3. Configuration APIs

### 3.1 Pay Element Management

```yaml
# POST /api/v1/pay-elements
# Tạo/cập nhật pay element definition

Request:
  code: "BASE_SALARY"
  name: "Lương cơ bản"
  classification: "EARNING"        # EARNING | DEDUCTION | TAX | EMPLOYER_CONTRIBUTION | INFORMATIONAL
  unit: "AMOUNT"                   # AMOUNT | HOURS | DAYS
  tax_treatment: "FULLY_TAXABLE"   # FULLY_TAXABLE | TAX_EXEMPT | PARTIALLY_EXEMPT
  tax_exempt_cap: null             # decimal, e.g. 730000 for lunch
  si_basis: "CAPPED"              # FULL_AMOUNT | CAPPED | EXCLUDED
  proration_method: "WORKING_DAYS" # CALENDAR_DAYS | WORKING_DAYS | NONE
  formula_code: "BASIC_SALARY_FORMULA"  # ref to pay_formula
  statutory_rule_code: null        # ref to statutory_rule (if applicable)
  gl_account_code: "6411"
  priority_order: 10
  input_required: false
  effective_start: "2025-01-01"
  effective_end: null

Response:
  id: "uuid"
  code: "BASE_SALARY"
  status: "CREATED"
```

### 3.2 Statutory Rule Management

```yaml
# POST /api/v1/statutory-rules
# Tax brackets, SI rates, OT multipliers

Request:
  code: "VN_PIT_2025"
  name: "Vietnam PIT Progressive Tax 2025"
  market_code: "VN"                # country/market
  rule_type: "PROGRESSIVE_TAX"
  formula_json:
    brackets:
      - { from: 0, to: 5000000, rate: 0.05 }
      - { from: 5000001, to: 10000000, rate: 0.10 }
      - { from: 10000001, to: 18000000, rate: 0.15 }
      - { from: 18000001, to: 32000000, rate: 0.20 }
      - { from: 32000001, to: 52000000, rate: 0.25 }
      - { from: 52000001, to: 80000000, rate: 0.30 }
      - { from: 80000001, to: null, rate: 0.35 }
    personal_deduction: 11000000
    dependent_deduction: 4400000
  legal_reference: "PIT Law 04/2007/QH12, amended"
  valid_from: "2025-01-01"
  valid_to: null

Response:
  id: "uuid"
  code: "VN_PIT_2025"
  status: "ACTIVE"
```

### 3.3 Country Configuration

```yaml
# POST /api/v1/country-configs
Request:
  country_code: "VN"
  country_name: "Vietnam"
  currency_code: "VND"
  tax_system: "PROGRESSIVE"        # PROGRESSIVE | FLAT | DUAL
  si_system: "MANDATORY"           # MANDATORY | OPTIONAL | HYBRID
  standard_working_hours_per_day: 8
  standard_working_days_per_week: 5
  standard_working_days_per_month: 22
  config_json:
    max_si_base: 46800000          # 20x region-1 min wage
    min_si_base: 2340000           # region-1 minimum wage
    night_shift_premium: 0.30
```

---

## 4. Input APIs — Compensation Data Ingestion

### 4.1 Compensation Snapshot (from TR)

```yaml
# POST /api/v1/payroll-inputs/compensation
# TR sends employee compensation data for a pay period

Request:
  batch_id: "uuid"                 # idempotency key
  pay_calendar_code: "VN_MONTHLY_2025"
  period:
    start: "2025-03-01"
    end: "2025-03-31"
  employees:
    - employee_id: "emp-001"
      assignment_id: "asg-001"
      legal_entity_code: "VNG-CORP"
      pay_group_code: "VN-HCM-STAFF"
      components:
        - element_code: "BASE_SALARY"
          amount: 30000000
          currency: "VND"
          effective_start: "2025-01-01"
        - element_code: "LUNCH_ALLOWANCE"
          amount: 730000
          currency: "VND"
        - element_code: "TRANSPORT"
          amount: 500000
          currency: "VND"
      start_date: "2020-06-15"     # hire date (for seniority calc)
      dependents_count: 2          # for PIT personal deduction

Response:
  batch_id: "uuid"
  status: "ACCEPTED"
  employees_received: 1
  validation_warnings: []
```

### 4.2 Attendance Input (from TA)

```yaml
# POST /api/v1/payroll-inputs/attendance
Request:
  batch_id: "uuid"
  period: { start: "2025-03-01", end: "2025-03-31" }
  employees:
    - employee_id: "emp-001"
      standard_days: 22
      actual_days: 20
      absent_days: 2
      absent_details:
        - type: "ANNUAL_LEAVE"
          days: 1
          paid: true
        - type: "SICK_LEAVE"
          days: 1
          paid: true
      overtime:
        - type: "WEEKDAY_NORMAL"
          hours: 10
          multiplier: 1.5
        - type: "WEEKEND"
          hours: 8
          multiplier: 2.0
        - type: "HOLIDAY"
          hours: 0
          multiplier: 3.0

Response:
  batch_id: "uuid"
  status: "ACCEPTED"
```

### 4.3 Taxable Items (from TR — Equity/Perk Bridge)

```yaml
# POST /api/v1/payroll-inputs/taxable-items
Request:
  items:
    - employee_id: "emp-001"
      source_module: "EQUITY"
      source_type: "RSU_VEST"
      source_id: "vest-event-123"
      taxable_amount: 50000000
      currency: "VND"
      tax_year: 2025
      description: "RSU vest - 100 shares @ 500K"

Response:
  status: "ACCEPTED"
  items_received: 1
```

### 4.4 Benefit Deductions (from TR)

```yaml
# POST /api/v1/payroll-inputs/benefits
Request:
  items:
    - employee_id: "emp-001"
      element_code: "HEALTH_PREMIUM_EE"
      amount: 500000
      currency: "VND"
      source: "benefit.enrollment.id-123"

Response:
  status: "ACCEPTED"
```

---

## 5. Execution APIs

### 5.1 Payroll Run Lifecycle

```
CREATE → CALCULATE → REVIEW → APPROVE → FINALIZE → (optional: REVERSE)
  │         │           │         │          │              │
  ▼         ▼           ▼         ▼          ▼              ▼
 INIT     CALC_OK    REVIEW    CONFIRMED   CLOSED       REVERSED
          CALC_ERR
```

### 5.2 Create Payroll Run

```yaml
# POST /api/v1/payroll-runs
Request:
  calendar_code: "VN_MONTHLY_2025"
  period:
    start: "2025-03-01"
    end: "2025-03-31"
  batch_type: "REGULAR"            # REGULAR | SUPPLEMENTAL | RETRO
  run_label: "March 2025 Regular Run"
  pay_group_codes: ["VN-HCM-STAFF", "VN-HCM-MANAGERS"]

Response:
  id: "run-uuid-001"
  status: "INIT"
  employees_selected: 150
  period: { start: "2025-03-01", end: "2025-03-31" }
```

### 5.3 Calculate (Dry Run / Simulation / Production)

```yaml
# POST /api/v1/payroll-runs/{id}/calculate
Request:
  mode: "DRY_RUN"                  # DRY_RUN | SIMULATION | PRODUCTION
  options:
    include_retro_check: true
    include_validation: true
    trace_level: "DETAIL"          # SUMMARY | DETAIL | DEBUG

# Dry Run: Không lưu, chỉ trả kết quả
# Simulation: Lưu tạm, có thể compare
# Production: Lưu chính thức, trigger approval

Response:
  run_id: "run-uuid-001"
  mode: "DRY_RUN"
  status: "CALC_OK"
  summary:
    total_employees: 150
    total_gross: 4500000000
    total_deductions: 945000000
    total_net: 3555000000
    total_employer_cost: 832500000
    currency: "VND"
  errors: []
  warnings:
    - employee_id: "emp-042"
      warning: "Base salary below minimum wage"
      element: "BASE_SALARY"
```

### 5.4 Approve & Finalize

```yaml
# POST /api/v1/payroll-runs/{id}/approve
Request:
  approved_by: "user-uuid"
  approval_note: "Reviewed and approved"

# POST /api/v1/payroll-runs/{id}/finalize
# Locks period, generates outputs (payslips, bank files, GL)
Request:
  generate_payslips: true
  generate_bank_file: true
  generate_gl_entries: true
  bank_account_code: "VCB-001"
  payslip_template_code: "VN-STANDARD"

Response:
  status: "CLOSED"
  outputs:
    payslips_generated: 150
    bank_file_id: "file-uuid-001"
    gl_batch_id: "gl-uuid-001"
```

---

## 6. Output APIs

### 6.1 Payroll Results

```yaml
# GET /api/v1/payroll-runs/{id}/results
# Query params: employee_id, element_code, classification

Response:
  run_id: "run-uuid-001"
  results:
    - employee_id: "emp-001"
      gross: 31730000
      net: 27145800
      currency: "VND"
      elements:
        - code: "BASE_SALARY"
          classification: "EARNING"
          amount: 30000000
        - code: "LUNCH_ALLOWANCE"
          classification: "EARNING"
          amount: 730000
        - code: "OT_WEEKDAY"
          classification: "EARNING"
          amount: 1000000
        - code: "BHXH_EE"
          classification: "DEDUCTION"
          amount: -2400000
        - code: "BHYT_EE"
          classification: "DEDUCTION"
          amount: -450000
        - code: "BHTN_EE"
          classification: "DEDUCTION"
          amount: -300000
        - code: "PIT"
          classification: "TAX"
          amount: -1434200
      employer_contributions:
        - code: "BHXH_ER"
          amount: 4200000
        - code: "BHYT_ER"
          amount: 900000
        - code: "BHTN_ER"
          amount: 300000
```

### 6.2 Calculation Trace

```yaml
# GET /api/v1/payroll-runs/{id}/calc-logs?employee_id=emp-001
Response:
  employee_id: "emp-001"
  trace:
    - step: 1
      label: "PRORATION"
      message: "Full month — 22/22 working days"
      input: { standard: 22, actual: 22 }
      output: { ratio: 1.0 }

    - step: 2
      label: "GROSS_CALC"
      message: "Base + Allowances + OT"
      detail:
        base: 30000000
        lunch: 730000
        ot: "10h × 170455/h × 1.5 = 2556818 → rounded 2557000"
      output: { gross: 33287000 }

    - step: 3
      label: "SI_CALC"
      message: "BHXH 8% + BHYT 1.5% + BHTN 1%"
      input: { si_base: "min(30000000, 46800000)" }
      output: { bhxh: 2400000, bhyt: 450000, bhtn: 300000 }

    - step: 4
      label: "TAX_CALC"
      message: "PIT progressive 7 brackets"
      input:
        taxable_income: 33287000
        personal_deduction: 11000000
        dependent_deduction: 8800000  # 2 dependents
        si_deduction: 3150000
        assessable: 10337000
      output:
        pit: 683700
        bracket_applied: "5% on first 5M + 10% on next 5M + 15% on 337K"

    - step: 5
      label: "NET_CALC"
      message: "Gross - EE deductions - PIT"
      output: { net: 26653300 }
```

---

## 7. Event Contract (AsyncAPI)

### 7.1 Events Published by PR

| Event | Trigger | Payload |
|-------|---------|---------|
| `payroll.run.created` | New payroll run created | run_id, period, pay_groups |
| `payroll.run.calculated` | Calculation completed | run_id, mode, summary (gross/net/count) |
| `payroll.run.approved` | Run approved | run_id, approved_by, timestamp |
| `payroll.run.finalized` | Period locked, outputs generated | run_id, outputs list |
| `payroll.run.reversed` | Run reversed | run_id, reason, reversed_by |
| `payroll.period.locked` | Period immutable | calendar_code, period_start, period_end |
| `payroll.payslip.generated` | Individual payslip ready | employee_id, run_id, file_url |
| `payroll.bank.file_ready` | Bank file generated | run_id, file_id, bank_code |
| `payroll.gl.entries_posted` | GL entries created | run_id, gl_batch_id, total_entries |

### 7.2 Events Consumed by PR

| Event | Source | Action |
|-------|--------|--------|
| `tr.compensation.changed` | TR | Update employee base salary for next run |
| `tr.bonus.approved` | TR | Queue bonus for inclusion in next/special run |
| `tr.taxable_item.created` | TR | Add to taxable income for next run |
| `tr.benefit.enrollment_changed` | TR | Update premium deduction |
| `ta.attendance.locked` | TA | Mark attendance data ready for payroll |
| `co.employee.terminated` | CO | Process final paycheck |
| `co.employee.transferred` | CO | Update pay group assignment |

---

## 8. Cross-cutting Concerns

### 8.1 Security

| Concern | Implementation |
|---------|---------------|
| **Authentication** | OAuth2 / API Key per client |
| **Authorization** | Scope-based: `payroll:read`, `payroll:write`, `payroll:admin` |
| **Data Masking** | SSN, bank account masked in responses; full data only with `payroll:pii` scope |
| **Encryption** | TLS 1.3 in transit; AES-256 at rest for PII |
| **Rate Limiting** | 1000 req/min per client (configurable) |

### 8.2 Idempotency

```yaml
# All POST/PUT operations support Idempotency-Key header
Headers:
  Idempotency-Key: "batch-2025-03-001"

# If same key sent again, returns cached response (not re-processed)
```

### 8.3 API Versioning

```
/api/v1/payroll-runs          ← Current version
/api/v2/payroll-runs          ← Next version (when breaking changes needed)

Deprecation: v1 supported for 12 months after v2 release
Header: Sunset: Sat, 01 Mar 2027 00:00:00 GMT
```

### 8.4 Error Handling

```yaml
# Standard error response
{
  error_code: "PAYROLL_VALIDATION_FAILED",
  message: "3 employees failed validation",
  details: [
    { employee_id: "emp-042", field: "base_salary", error: "Below minimum wage" },
    { employee_id: "emp-078", field: "bank_account", error: "Missing bank account" },
    { employee_id: "emp-103", field: "si_base", error: "Exceeds SI ceiling" }
  ],
  request_id: "req-uuid-001",
  timestamp: "2025-03-15T14:30:00+07:00"
}
```

---

## 9. Tóm tắt API Surface

| Domain | Endpoints | Methods |
|--------|:---------:|:-------:|
| Configuration | 7 resources | CRUD |
| Input | 5 resources | POST (batch) |
| Execution | 1 resource + 4 actions | POST lifecycle |
| Output | 6 resources | GET (query) |
| Events | 9 published, 7 consumed | Async |
| **Total** | **~28 endpoints** | |

---

*← [03 Calculation Responsibility Split](./03-calculation-responsibility-split.md) · [05 Design Assessment →](./05-design-assessment.md)*
