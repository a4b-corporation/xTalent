# Review #03 – Payroll Engine Separation & Cross-Module Status

> Ngày: 27Mar2026  
> Phạm vi: Core V4, TotalReward V5, Payroll V3, TA v5.1  
> Mục đích: (1) Tổng duyệt status tất cả modules, (2) Plan chi tiết tách Payroll Engine, (3) Đề xuất cải tiến Payroll

---

## 1. Cross-Module Status Summary

| Module | File | Status | Ghi chú |
|--------|------|--------|---------|
| **Core V4** | `1.Core.V4.dbml` | ✅ Solid | G1 (assignment_id), G2 (piece-rate), F4 (eligibility domain PAYROLL) đã fix |
| **Time & Absence v5.1** | `TA-database-design-v5.dbml` | ✅ Good | G3/G4 (time_type_element_map bridge), F1 (schema name) đã fix. Absence v4 kept as legacy |
| **Total Rewards V5** | `4.TotalReward.V5.dbml` | ✅ Good | G5/G6 (unified eligibility), G8 (employee_reward_summary), multi-country scoping đã fix |
| **Payroll V3** | `5.Payroll.V3.dbml` | ⚠️ Needs work | G7 (eligibility) đã fix. **Cần tách Engine + nhiều cải tiến** |

> [!IMPORTANT]
> **Core, TA, Total Rewards** đã ổn định sau 3 review cycles. **Payroll** là module cần đầu tư cải tiến lớn nhất.

---

## 2. Payroll V3 – Hiện trạng

### 2.1 Cấu trúc hiện tại (6 schemas, ~30 tables)

```
┌─────────────────────────────────────────────────────┐
│  pay_master (Configuration)          14 tables       │
│  ├── pay_frequency, pay_calendar, pay_group          │
│  ├── pay_element, balance_def, costing_rule          │
│  ├── statutory_rule, gl_mapping, validation_rule     │
│  ├── payslip_template, pay_formula                   │
│  ├── pay_profile, pay_profile_map                    │
│  └── pay_adjust_reason, pay_deduction_policy,        │
│      pay_benefit_link                                │
├─────────────────────────────────────────────────────┤
│  pay_run (Execution + Results)        9 tables       │
│  ├── batch, employee, input_value                    │
│  ├── result, balance, retro_delta                    │
│  ├── calc_log, costing, manual_adjust                │
├─────────────────────────────────────────────────────┤
│  pay_gateway (Integration)            4 tables       │
│  pay_bank (Payment)                   3 tables       │
│  pay_audit (Audit)                    1 table        │
│  Standalone (import_job, generated_file, etc.)       │
└─────────────────────────────────────────────────────┘
```

### 2.2 Vấn đề kiến trúc

| # | Vấn đề | Impact |
|---|--------|--------|
| P1 | `pay_run` schema trộn lẫn **batch management** (orchestration) với **calculation** (engine) | Không thể scale engine độc lập |
| P2 | `pay_run.batch.status_code` dùng chung cho cả payroll workflow + engine execution state | Tight coupling |
| P3 | Không có **interface contract** rõ ràng giữa "yêu cầu tính lương" và "thực thi tính lương" | Không thể swap engine |
| P4 | Input collection (từ TA, Absence, CompBasis) là implicit — không có mechanism chuẩn | Manual process |
| P5 | Thiếu `pay_period` table — periods ẩn trong `calendar_json` | Không track period status |
| P6 | `pay_run.employee` thiếu `assignment_id` | Không hỗ trợ multi-assignment payroll |
| P7 | YTD/QTD balances chỉ tính per-run, thiếu cumulative tracking | Phải re-aggregate mỗi lần |
| P8 | Không có approval workflow cho batch | Thiếu governance |

---

## 3. Payroll Engine Separation Plan

### 3.1 Kiến trúc đề xuất

```
┌──────────────────────────────────────────────────────────────────────┐
│                     PAYROLL MODULE (Orchestration)                    │
│                                                                      │
│  pay_master (Config)              pay_mgmt (Management)              │
│  ├── pay_frequency                ├── pay_period [NEW]               │
│  ├── pay_calendar                 ├── batch (from pay_run.batch)     │
│  ├── pay_group                    ├── batch_employee_selection [NEW] │
│  ├── pay_element                  ├── batch_approval [NEW]           │
│  ├── balance_def                  ├── manual_adjust (from pay_run)   │
│  ├── costing_rule                 └── batch_comparison [NEW]         │
│  ├── statutory_rule               │
│  ├── pay_formula                  │
│  └── ...                          │
│                                                                      │
│  pay_gateway (Integration)        pay_bank (Payment)                 │
│  └── iface_def/job/file/line      └── bank_account/payment_batch    │
├──────────────────────┬───────────────────────────────────────────────┤
│                      │  Interface: pay_engine.run_request            │
│                      ▼                                               │
│              PAYROLL ENGINE (Calculation)                             │
│                                                                      │
│  pay_engine                                                          │
│  ├── run_request [NEW]          ← Yêu cầu tính lương               │
│  ├── calculation_step [NEW]     ← Bước tính (config)                │
│  ├── run_step [NEW]             ← Tracking từng bước               │
│  ├── run_employee (from pay_run.employee)                            │
│  ├── input_value (from pay_run.input_value)                          │
│  ├── input_source_config [NEW]  ← Config thu thập input tự động    │
│  ├── result (from pay_run.result)                                    │
│  ├── balance (from pay_run.balance)                                  │
│  ├── cumulative_balance [NEW]   ← YTD/QTD persistence              │
│  ├── element_dependency [NEW]   ← Dependency graph                  │
│  ├── retro_delta (from pay_run.retro_delta)                          │
│  ├── calc_log (from pay_run.calc_log)                                │
│  └── costing (from pay_run.costing)                                  │
└──────────────────────────────────────────────────────────────────────┘
```

### 3.2 Table Migration Map

#### Tables giữ nguyên trong Payroll Management

| Schema | Table | Vai trò | Thay đổi |
|--------|-------|---------|----------|
| `pay_master` | Tất cả 14 tables | Configuration/Master Data | Không đổi |
| `pay_gateway` | Tất cả 4 tables | Integration | Không đổi |
| `pay_bank` | Tất cả 3 tables | Payment | Không đổi |
| `pay_audit` | `audit_log` | Audit | Không đổi |
| — | `import_job`, `generated_file`, `bank_template`, `tax_report_template` | Utilities | Không đổi |

#### Tables chuyển sang Payroll Engine (`pay_engine`)

| Hiện tại | Mới | Lý do chuyển |
|----------|-----|-------------|
| `pay_run.employee` | `pay_engine.run_employee` | Execution data — per-employee calculation record |
| `pay_run.input_value` | `pay_engine.input_value` | Input cho engine xử lý |
| `pay_run.result` | `pay_engine.result` | Output của engine |
| `pay_run.balance` | `pay_engine.balance` | Balance per-run (engine output) |
| `pay_run.retro_delta` | `pay_engine.retro_delta` | Retro calculation (engine logic) |
| `pay_run.calc_log` | `pay_engine.calc_log` | Calculation trace/debug |
| `pay_run.costing` | `pay_engine.costing` | Costing output |

#### Tables chuyển sang Payroll Management (`pay_mgmt`)

| Hiện tại | Mới | Lý do |
|----------|-----|-------|
| `pay_run.batch` | `pay_mgmt.batch` | Batch orchestration thuộc management |
| `pay_run.manual_adjust` | `pay_mgmt.manual_adjust` | Manual input thuộc management |

### 3.3 Tables Mới

#### 3.3.1 `pay_mgmt.pay_period` — Explicit Period Records

> [!IMPORTANT]
> Thay thế `calendar_json` implicit periods bằng explicit records để track period lifecycle.

```dbml
Table pay_mgmt.pay_period {
  id              uuid [pk]
  calendar_id     uuid [ref: > pay_master.pay_calendar.id]
  period_seq      int                               // thứ tự kỳ trong năm (1, 2, ..., 12)
  period_year     smallint                           // năm
  period_start    date                               // ngày bắt đầu kỳ
  period_end      date                               // ngày kết thúc kỳ
  pay_date        date                               // ngày trả lương
  cut_off_date    date [null]                        // ngày chốt data
  status_code     varchar(20) [default: 'FUTURE']    // FUTURE | OPEN | PROCESSING | CLOSED | ADJUSTED
  closed_at       timestamp [null]
  closed_by       uuid [null]
  metadata        jsonb [null]
  
  Indexes {
    (calendar_id, period_year, period_seq) [unique]
    (calendar_id, status_code)
    (period_start, period_end)
  }
}
```

#### 3.3.2 `pay_mgmt.batch` — Enhanced Batch (từ `pay_run.batch`)

```dbml
Table pay_mgmt.batch {
  id              uuid [pk]
  calendar_id     uuid [ref: > pay_master.pay_calendar.id]
  period_id       uuid [ref: > pay_mgmt.pay_period.id]     // NEW — link period mới
  pay_group_id    uuid [ref: > pay_master.pay_group.id]     // RESTORED — pay group là required
  period_start    date
  period_end      date
  batch_type      varchar(20)                               // REGULAR | SUPPLEMENTAL | RETRO | QUICKPAY
  run_label       varchar(100)
  
  // Payroll Management status (orchestration)
  status_code     varchar(20)                               // DRAFT | SELECTING | SUBMITTED | ENGINE_PROCESSING | REVIEW | APPROVED | CONFIRMED | CLOSED
  
  // Engine tracking
  engine_request_id uuid [null]                             // NEW — FK to pay_engine.run_request
  
  // Retro / Reversal
  original_run_id         uuid [ref: > pay_mgmt.batch.id, null]
  reversed_by_run_id      uuid [ref: > pay_mgmt.batch.id, null]
  
  // Lifecycle
  submitted_at    timestamp [null]                          // khi submit sang engine
  executed_at     timestamp [null]                          // khi engine bắt đầu chạy
  calc_completed_at timestamp [null]                        // khi engine hoàn thành
  finalized_at    timestamp [null]                          // khi confirm kết quả
  costed_flag     bool [default: false]
  
  metadata        jsonb
  created_at      timestamp
  created_by      varchar(100)
  updated_at      timestamp
  updated_by      varchar(100)
}
```

#### 3.3.3 `pay_mgmt.batch_approval` — Approval Workflow

```dbml
Table pay_mgmt.batch_approval {
  id              uuid [pk]
  batch_id        uuid [ref: > pay_mgmt.batch.id]
  approval_level  smallint [default: 1]                     // 1, 2, 3...
  approver_id     uuid [ref: > employment.employee.id]
  status_code     varchar(20)                               // PENDING | APPROVED | REJECTED | DELEGATED
  approved_at     timestamp [null]
  comments        text [null]
  delegated_to_id uuid [ref: > employment.employee.id, null]
  
  Indexes {
    (batch_id, approval_level) [unique]
    (approver_id, status_code)
  }
}
```

#### 3.3.4 `pay_engine.run_request` — Engine Interface Contract

> [!IMPORTANT]
> Đây là **bảng giao tiếp chính** giữa Payroll Management và Engine. Management tạo request, Engine xử lý.

```dbml
Table pay_engine.run_request {
  id              uuid [pk]
  batch_id        uuid [ref: > pay_mgmt.batch.id]           // batch nào yêu cầu
  request_type    varchar(20)                                // CALCULATE | VALIDATE | COSTING | RETRO | QUICKPAY | REVERSAL
  
  // Status tracking (Engine-side)
  status_code     varchar(20) [default: 'QUEUED']            // QUEUED | PROCESSING | COMPLETED | FAILED | CANCELLED
  priority        smallint [default: 5]                       // 1 (high) → 10 (low)
  
  // Parameters
  parameters_json jsonb [null]                                // override settings, filters, etc.
  employee_count  int [null]                                  // số employee cần xử lý
  
  // Execution tracking
  engine_version  varchar(20) [null]                          // version engine thực thi
  requested_by    uuid
  requested_at    timestamp [default: `now()`]
  started_at      timestamp [null]
  completed_at    timestamp [null]
  
  // Error tracking
  error_count     int [default: 0]
  warning_count   int [default: 0]
  error_summary   text [null]
  
  metadata        jsonb [null]
  
  Indexes {
    (batch_id)
    (status_code, priority)
    (requested_at)
  }
}
```

#### 3.3.5 `pay_engine.calculation_step` — Step Configuration

```dbml
Table pay_engine.calculation_step {
  code            varchar(30) [pk]                            // INPUT_COLLECTION, PRE_CALC, EARNINGS, STATUTORY_DEDUCTIONS, VOLUNTARY_DEDUCTIONS, TAX, NET_PAY, POST_CALC, BALANCING, COSTING
  name            varchar(100)
  sequence        smallint                                    // thứ tự thực thi
  description     text [null]
  is_active       boolean [default: true]
  is_mandatory    boolean [default: true]                     // bước bắt buộc?
  
  Indexes {
    (sequence)
  }
}
```

#### 3.3.6 `pay_engine.run_step` — Per-Run Step Tracking

```dbml
Table pay_engine.run_step {
  id              uuid [pk]
  request_id      uuid [ref: > pay_engine.run_request.id]
  step_code       varchar(30) [ref: > pay_engine.calculation_step.code]
  status_code     varchar(20) [default: 'PENDING']            // PENDING | RUNNING | COMPLETED | FAILED | SKIPPED
  started_at      timestamp [null]
  completed_at    timestamp [null]
  record_count    int [default: 0]
  error_count     int [default: 0]
  duration_ms     bigint [null]
  error_detail    text [null]
  
  Indexes {
    (request_id, step_code) [unique]
    (request_id, status_code)
  }
}
```

#### 3.3.7 `pay_engine.run_employee` — Enhanced (từ `pay_run.employee`)

```dbml
Table pay_engine.run_employee {
  id              uuid [pk]
  request_id      uuid [ref: > pay_engine.run_request.id]     // NEW — link tới engine request (thay batch_id)
  batch_id        uuid [ref: > pay_mgmt.batch.id]             // giữ backward compat
  employee_id     uuid [ref: > employment.employee.id]
  assignment_id   uuid [ref: > employment.assignment.id, null] // NEW — hỗ trợ multi-assignment
  pay_group_id    uuid [ref: > pay_master.pay_group.id, null]  // NEW — employee thuộc group nào
  
  status_code     varchar(20)                                  // SELECTED | CALC_OK | WARNINGS | ERROR | EXCLUDED
  gross_amount    decimal(18,2) [null]
  net_amount      decimal(18,2) [null]
  currency_code   char(3)
  
  // Comparison with previous period
  prev_gross_amount decimal(18,2) [null]                       // NEW — gross kỳ trước
  prev_net_amount   decimal(18,2) [null]                       // NEW — net kỳ trước
  variance_amount   decimal(18,2) [null]                       // NEW — chênh lệch
  variance_flag     boolean [default: false]                   // NEW — cờ có bất thường
  
  error_message   text [null]                                  // NEW — chi tiết lỗi
  metadata        jsonb
  
  Indexes {
    (request_id, employee_id) [unique]
    (batch_id, employee_id)
    (status_code)
  }
}
```

#### 3.3.8 `pay_engine.cumulative_balance` — YTD/QTD Tracking

```dbml
Table pay_engine.cumulative_balance {
  id              uuid [pk]
  employee_id     uuid [ref: > employment.employee.id]
  balance_def_id  uuid [ref: > pay_master.balance_def.id]
  balance_type    varchar(10)                                  // QTD | YTD | LTD
  period_year     smallint                                     // năm
  period_quarter  smallint [null]                              // quý (cho QTD)
  balance_value   decimal(18,2) [default: 0]
  currency_code   char(3)
  last_updated_by_run_id uuid [null]                           // run cuối cùng cập nhật
  last_updated_at timestamp [null]
  
  Indexes {
    (employee_id, balance_def_id, balance_type, period_year) [unique]
    (employee_id, period_year)
    (balance_type, period_year)
  }
}
```

#### 3.3.9 `pay_engine.element_dependency` — Dependency Graph

```dbml
Table pay_engine.element_dependency {
  id                    uuid [pk]
  element_id            uuid [ref: > pay_master.pay_element.id]
  depends_on_element_id uuid [ref: > pay_master.pay_element.id]
  dependency_type       varchar(20)                            // REQUIRES_OUTPUT | USES_BALANCE | SEQUENCED_AFTER
  description           text [null]
  is_active             boolean [default: true]
  
  Indexes {
    (element_id, depends_on_element_id) [unique]
    (depends_on_element_id)
  }
}
```

#### 3.3.10 `pay_engine.input_source_config` — Automated Input Collection

```dbml
Table pay_engine.input_source_config {
  id              uuid [pk]
  source_module   varchar(30)                                  // TIME_ATTENDANCE | ABSENCE | COMPENSATION | BENEFITS | MANUAL
  source_type     varchar(50)                                  // TIMESHEET | LEAVE_DEDUCTION | COMP_BASIS_CHANGE | BENEFIT_PREMIUM | ...
  target_element_id uuid [ref: > pay_master.pay_element.id]    // element nhận giá trị
  mapping_json    jsonb [null]                                 // mapping rules
  is_active       boolean [default: true]
  priority        smallint [default: 0]
  description     text [null]
  
  Indexes {
    (source_module, source_type, target_element_id) [unique]
    (target_element_id)
  }
}
```

### 3.4 Batch Lifecycle — Before vs After

#### Before (hiện tại)

```
pay_run.batch.status_code:
  INIT → CALC → REVIEW → CONFIRM → CLOSED
  (1 status cho cả orchestration + engine)
```

#### After (tách biệt)

```
┌─────────────────────────────────┐     ┌──────────────────────────────────┐
│  pay_mgmt.batch.status_code     │     │  pay_engine.run_request.status   │
│  (Payroll Management)           │     │  (Engine)                        │
│                                 │     │                                  │
│  DRAFT                          │     │                                  │
│    ↓                            │     │                                  │
│  SELECTING (chọn employees)     │     │                                  │
│    ↓                            │     │                                  │
│  SUBMITTED ─────────────────────┼────▶│  QUEUED                          │
│    ↓                            │     │    ↓                             │
│  ENGINE_PROCESSING              │     │  PROCESSING                      │
│    ↓                            │◀────┼────↓                             │
│  REVIEW ◀───────────────────────┤     │  COMPLETED / FAILED              │
│    ↓                            │     │                                  │
│  APPROVED (approval workflow)   │     │                                  │
│    ↓                            │     │                                  │
│  CONFIRMED (final)              │     │                                  │
│    ↓                            │     │                                  │
│  CLOSED                         │     │                                  │
└─────────────────────────────────┘     └──────────────────────────────────┘
```

### 3.5 Flow Tính Lương End-to-End

```
1. HR mở period          →  pay_mgmt.pay_period.status = OPEN
2. HR tạo batch          →  pay_mgmt.batch (DRAFT)
3. System chọn employees →  pay_mgmt.batch_employee_selection
4. HR submit             →  pay_mgmt.batch.status = SUBMITTED
                             pay_engine.run_request (QUEUED)
                         
5. Engine bắt đầu       →  run_request.status = PROCESSING
   5a. Input Collection  →  Thu thập từ TA, Absence, CompBasis, Manual
                             → pay_engine.input_value (nhiều dòng)
   5b. Earnings Calc     →  Tính thu nhập (base + allowances + OT)
                             → pay_engine.result (classification=EARNING)
   5c. Deductions        →  Tính khấu trừ (BHXH, BHYT, thuế)
                             → pay_engine.result (classification=DEDUCTION)
   5d. Tax               →  Tính thuế TNCN (progressive)
                             → pay_engine.result (classification=TAX)
   5e. Net Pay           →  Tính lương ròng
   5f. Balance Update    →  Cập nhật YTD/QTD
                             → pay_engine.balance + cumulative_balance
   5g. Costing           →  Phân bổ kế toán
                             → pay_engine.costing
   5h. Comparison        →  So sánh với kỳ trước
                         
6. Engine hoàn thành     →  run_request.status = COMPLETED
                             pay_mgmt.batch.status = REVIEW
                         
7. HR/Manager review     →  Xem kết quả, variance, exceptions
8. Approval              →  pay_mgmt.batch_approval
9. Confirm               →  pay_mgmt.batch.status = CONFIRMED
10. Payment              →  pay_bank.payment_batch (generate bank file)
11. Payslip              →  generated_file (type=PAYSLIP)
12. Close period         →  pay_mgmt.pay_period.status = CLOSED
```

---

## 4. Các Cải Tiến Bổ Sung (Ngoài Engine Separation)

### 4.1 High Priority

| # | Cải tiến | Mô tả | Bảng ảnh hưởng |
|---|---------|-------|----------------|
| I1 | **Pay Period table** | Explicit period tracking thay calendar_json | `pay_mgmt.pay_period` [NEW] |
| I2 | **Assignment-level payroll** | Thêm `assignment_id` vào pay_run/engine employee | `pay_engine.run_employee` |
| I3 | **YTD/QTD cumulative balances** | Persist aggregate balances cross-period | `pay_engine.cumulative_balance` [NEW] |
| I4 | **Batch approval workflow** | Governance cho payroll run | `pay_mgmt.batch_approval` [NEW] |
| I5 | **Element dependency graph** | Đảm bảo thứ tự tính toán đúng | `pay_engine.element_dependency` [NEW] |

### 4.2 Medium Priority

| # | Cải tiến | Mô tả | Bảng ảnh hưởng |
|---|---------|-------|----------------|
| I6 | **Input source config** | Automated input collection từ các module | `pay_engine.input_source_config` [NEW] |
| I7 | **Period-over-period comparison** | Variance tracking cho review dễ hơn | Fields on `pay_engine.run_employee` |
| I8 | **QuickPay** | Simulate single employee trước full run | `batch_type = 'QUICKPAY'` |

### 4.3 Future / Low Priority

| # | Cải tiến | Mô tả |
|---|---------|-------|
| I9 | Shadow payroll per currency | Global assignment multi-currency |
| I10 | Tax bracket tables | Structured VN PIT brackets thay generic formula_json |
| I11 | Payslip digital signing | E-signature cho payslip |

---

## 5. Tổng Hợp Thay Đổi DBML

### 5.1 Tables chuyển schema (rename)

| Từ | Sang | Ghi chú |
|----|------|---------|
| `pay_run.batch` | `pay_mgmt.batch` | + thêm fields mới |
| `pay_run.manual_adjust` | `pay_mgmt.manual_adjust` | Giữ nguyên |
| `pay_run.employee` | `pay_engine.run_employee` | + thêm fields |
| `pay_run.input_value` | `pay_engine.input_value` | Giữ nguyên |
| `pay_run.result` | `pay_engine.result` | Giữ nguyên |
| `pay_run.balance` | `pay_engine.balance` | Giữ nguyên |
| `pay_run.retro_delta` | `pay_engine.retro_delta` | Giữ nguyên |
| `pay_run.calc_log` | `pay_engine.calc_log` | Giữ nguyên |
| `pay_run.costing` | `pay_engine.costing` | Giữ nguyên |

### 5.2 Tables mới

| Table | Schema | Mục đích |
|-------|--------|----------|
| `pay_period` | `pay_mgmt` | Explicit pay period records |
| `batch_approval` | `pay_mgmt` | Approval workflow |
| `run_request` | `pay_engine` | **Engine interface contract** |
| `calculation_step` | `pay_engine` | Step configuration |
| `run_step` | `pay_engine` | Step execution tracking |
| `cumulative_balance` | `pay_engine` | YTD/QTD persistence |
| `element_dependency` | `pay_engine` | Element ordering |
| `input_source_config` | `pay_engine` | Input collection config |

### 5.3 Fields mới trên tables hiện có

| Table | Field | Mô tả |
|-------|-------|-------|
| `pay_mgmt.batch` | `period_id` | FK tới `pay_period` |
| `pay_mgmt.batch` | `pay_group_id` | Restored (đã deprecated) |
| `pay_mgmt.batch` | `engine_request_id` | FK tới `run_request` |
| `pay_mgmt.batch` | `submitted_at`, `calc_completed_at` | Lifecycle timestamps |
| `pay_engine.run_employee` | `request_id` | FK tới `run_request` |
| `pay_engine.run_employee` | `assignment_id` | Multi-assignment support |
| `pay_engine.run_employee` | `pay_group_id` | Group tracking |
| `pay_engine.run_employee` | `prev_gross/net_amount`, `variance_*` | Comparison fields |

---

## 6. So Sánh Với Industry

| Tiêu chí | Oracle HCM | SAP | Workday | **xTalent (After)** |
|----------|-----------|-----|---------|---------------------|
| Engine separation | ✅ Flow Tasks → Payroll Engine | ✅ HR-PY → PI Engine | ✅ Calc Engine separate | ✅ pay_mgmt → pay_engine |
| Period management | ✅ Time Periods | ✅ Payroll Periods | ✅ Pay Period | ✅ `pay_period` |
| Approval workflow | ✅ Flow Approvals | ✅ Workflow | ✅ Business Process | ✅ `batch_approval` |
| Element dependencies | ✅ Element Classification | ✅ Eval Rule groups | ✅ Calc Groups | ✅ `element_dependency` |
| YTD tracking | ✅ Balance Feeds | ✅ Cumulation Types | ✅ Accumulators | ✅ `cumulative_balance` |
| Comparison/Variance | ✅ Comparison Report | ✅ Retro Diff | ✅ Audit Compare | ✅ Variance fields |

---

*Plan này cần user approval trước khi thực hiện. Nếu đồng ý, sẽ update DBML Payroll V4 + CHANGELOG.*
