# Absence Sub-Module — Data Flow & Model Guide

> **Scope:** `absence` schema — `leave_type`, `leave_class`, `leave_policy`, `leave_instant`, `leave_movement`, `leave_request`, `leave_reservation`, `leave_reservation_line`, `absence_rule`, `class_rule_assignment`
> **Version:** TA-database-design-v5 (30Mar2026)
> **Cross-ref:** `bounded-contexts.md`, `glossary.md`, `CHANGELOG.md [30Mar2026]`

---

## 1. Mẫu Khái Niệm — 3 Tầng Cấu Trúc

Trước khi đọc data flow, cần nắm 3 tầng cốt lõi:

```
TẦNG 1: DEFINITION (HR Admin cấu hình — ít thay đổi)
  leave_type     — Danh mục nghỉ phép (ANNUAL, SICK, MATERNITY...)
  leave_class    — Variant cụ thể của type (ANNUAL_FTE, ANNUAL_PART_TIME...)
  leave_policy   — Bộ quy tắc gán cho type (thông qua class_id FK)
  absence_rule   — Rule engine tập trung (ACCRUAL, CARRY, LIMIT...)
  class_rule_assignment — Kết nối N:N class ↔ rule

TẦNG 2: ENTITLEMENT (Employee level — khởi tạo 1 lần/năm)
  leave_instant  — Số dư nghỉ phép của 1 employee cho 1 class
  leave_instant_detail — Chi tiết từng lot/grant (FEFO tracking)

TẦNG 3: TRANSACTION (Hàng ngày — nhiều records)
  leave_request           — Đơn xin nghỉ
  leave_reservation       — Giữ chỗ số dư (UNCOMMITTED)
  leave_reservation_line  — Chi tiết FEFO reservation line
  leave_movement          — Ledger bất biến (COMMITTED changes)
```

---

## 2. Thứ Tự Khởi Tạo Dữ Liệu (Init Order)

> **Quan trọng:** Phải theo đúng thứ tự dependency. Không thể tạo `leave_class` trước `leave_type`.

```
STEP 1 — Core Dependencies (phải có trước)
──────────────────────────────────────────────────────
1.1  eligibility.eligibility_profile    ← WHO có thể dùng class này
1.2  employment.employee                ← Nhân viên
1.3  shared.period_profile              ← Năm tài chính / Calendar year
1.4  shared.holiday + holiday_calendar  ← Ngày lễ

STEP 2 — Absence Definition (HR Admin)
──────────────────────────────────────────────────────
2.1  absence.leave_type                 ← Danh mục (ANNUAL, SICK...)
2.2  absence.leave_class                ← Variant + gán eligibility_profile_id
2.3  absence.absence_rule               ← Tạo tất cả rules (ACCRUAL, CARRY, LIMIT...)
2.4  absence.class_rule_assignment      ← Map N:N class ↔ rule
2.5  absence.leave_policy               ← Policy gán cho type + class_id FK
                                           (JSONB rule columns: keep for legacy)
2.6  absence.leave_event_def            ← Event triggers (ACCRUAL, CARRY, EXPIRE...)

STEP 3 — Employee Entitlement (Grant / Accrual)
──────────────────────────────────────────────────────
3.1  absence.leave_instant              ← Tạo 1 record/employee/class
3.2  absence.leave_instant_detail       ← Tạo lots (GRANT/CARRY/BONUS)
3.3  absence.leave_movement (EARN)      ← Ledger entry cho grant ban đầu

STEP 4 — Transactions (Run-time)
──────────────────────────────────────────────────────
4.1  absence.leave_request              ← Employee submit đơn
4.2  absence.leave_reservation          ← System giữ chỗ số dư
4.3  absence.leave_reservation_line     ← FEFO breakdown per lot
4.4  absence.leave_movement (BOOK/DEDUCT/CANCEL) ← Committed ledger entries
```

---

## 3. Data Flow Tổng Thể — Absence Sub-Module

### 3.1 Flow: Tạo Entitlement (Accrual Batch)

```
[Scheduler / Cron Job]
        │
        ▼
absence.leave_accrual_run
  (status: RUNNING)
  plan_rule_id → absence_rule(ACCRUAL)
  period_start / period_end
  idempotency: unique(plan_rule_id, period_start)
        │
        ▼ Query: class_rule_assignment WHERE rule_type='ACCRUAL'
        │
        ├── absence.absence_rule      (rule config: amount, frequency, seniority_tiers)
        │
        ├── absence.leave_class       (class list eligible)
        │         │
        │         └── eligibility.eligibility_profile  (WHO is eligible)
        │                   │
        │                   └── eligibility.eligibility_member  (employee list)
        │
        ▼ For each eligible employee:
absence.leave_instant          (get or create balance record)
        │
        ▼
absence.leave_instant_detail   (create new lot: lot_kind=ACCRUAL)
        │
        ▼
absence.leave_movement (event_code=ACCRUAL, qty=+N)
        │
        ▼
absence.leave_accrual_run      (status: COMPLETED, movements_created=N)
```

### 3.2 Flow: Employee Submit Leave Request

```
[Employee UI / API]
        │
        ▼ POST /leave-requests
absence.leave_request
  (status: DRAFT → PENDING)
  class_id, employee_id, start_dt, end_dt
        │
        ├── VALIDATE: Shift/Working Day
        │     └── [SERVICE CALL] → TA Scheduling Service
        │           (không dùng FK — loose coupling)
        │
        ├── VALIDATE: Absence Rules
        │     └── absence.class_rule_assignment WHERE class_id=:class_id
        │           └── absence.absence_rule (LIMIT, VALIDATION rules)
        │                 check: min_notice_days, max_per_request, max_per_year...
        │
        ├── VALIDATE: Balance
        │     └── absence.leave_instant WHERE employee_id AND class_id
        │           check: available_qty >= requested_qty
        │
        ▼ (nếu pass hết validation)
absence.leave_reservation      (1 record — tổng qty)
        │
        ▼ FEFO Ordering
absence.leave_reservation_line (N lines — per lot)
  source_lot_id → leave_instant_detail (lot với expiry_date sớm nhất trước)
        │
        ▼
absence.leave_movement (event_code=BOOK_HOLD, qty=-N)
leave_instant.hold_qty += N
leave_instant.available_qty -= N
        │
        ▼ [Workflow Engine — Temporal]
  Approval workflow begin...
```

### 3.3 Flow: Duyệt / Từ Chối Request

```
APPROVE PATH:
  leave_request.status → APPROVED
  leave_movement (event_code=START_POST, qty=0)   // commit reservation
  leave_reservation → expires (reservation consumed)
  leave_instant.hold_qty -= N, used_qty += N      // settle balance

REJECT / CANCEL PATH:
  leave_request.status → REJECTED | CANCELLED
  leave_movement (event_code=CANCEL, qty=+N)      // release hold
  leave_reservation + leave_reservation_line → deleted
  leave_instant.hold_qty -= N, available_qty += N // restore balance
```

---

## 4. Bounded Context Absence — Phân Nhánh: Policy Flow vs Rule Flow

> Đây là điểm quan trọng nhất của kiến trúc v5 (post-30Mar2026 Option C).
> Có **2 luồng song song** để resolve business rules cho 1 leave_class:
> - **Legacy Path** (Policy Flow): đọc JSONB từ `leave_policy`
> - **New Path** (Rule Engine Flow): đọc từ `absence_rule` via `class_rule_assignment`

### 4.1 Sơ Đồ Phân Nhánh

```
                    [leave_class]
                         │
                         ├──────────────────────────────────────┐
                         │  PATH A: Policy Flow (Legacy)        │  PATH B: Rule Flow (New)
                         │  (đọc qua leave_policy)              │  (đọc qua class_rule_assignment)
                         ▼                                       ▼
              leave_policy (class_id FK)             class_rule_assignment
              ├── accrual_rule_json [DEPRECATED]     ├── rule_id → absence_rule(ACCRUAL)
              ├── carry_rule_json   [DEPRECATED]     ├── rule_id → absence_rule(CARRY)
              ├── limit_rule_json   [DEPRECATED]     ├── rule_id → absence_rule(LIMIT)
              ├── validation_json   [DEPRECATED]     ├── rule_id → absence_rule(VALIDATION)
              ├── rounding_json     [DEPRECATED]     ├── rule_id → absence_rule(SENIORITY)
              └── proration_json    [DEPRECATED]     └── rule_id → absence_rule(PRORATION)

                    ↓ (app reads JSONB)                     ↓ (app reads structured rows)
              rule_resolver.fromPolicy()           rule_resolver.fromRuleEngine()
                         │                                       │
                         └────────────── merge ─────────────────┘
                                          │
                                          ▼
                                  effective_rules{}
                         (app-level merge: Rule Engine wins if exists)
```

### 4.2 Logic Ưu Tiên (Application Layer)

```
PRIORITY ORDER (highest first):
  1. absence_rule via class_rule_assignment   ← WINS nếu tồn tại
  2. leave_policy JSONB columns              ← Fallback nếu class chưa migrate

IMPLEMENTATION PATTERN:
  function resolve_accrual_rule(class_id):
    // Try Rule Engine first
    rule = SELECT ar.*
           FROM absence.absence_rule ar
           JOIN absence.class_rule_assignment cra ON ar.id = cra.rule_id
           WHERE cra.class_id = :class_id
             AND ar.rule_type = 'ACCRUAL'
             AND ar.is_current_flag = true
             AND cra.is_current_flag = true
           ORDER BY cra.priority ASC
           LIMIT 1

    if rule exists:
      return parse_config_json(rule.config_json)   // New path

    // Fallback to Policy legacy
    policy = SELECT lp.accrual_rule_json
             FROM absence.leave_policy lp
             WHERE lp.class_id = :class_id
               AND now() BETWEEN lp.effective_start AND coalesce(lp.effective_end, 'infinity')

    if policy.accrual_rule_json is not null:
      return parse_legacy_json(policy.accrual_rule_json)  // Legacy path

    return default_accrual_rule()
```

### 4.3 Use Case Khi Nào Dùng Rule Flow

| Tình huống | Dùng Path A (Policy) | Dùng Path B (Rule Engine) |
|-----------|---------------------|--------------------------|
| Class chưa được migrate | ✅ | ❌ (class_rule_assignment chưa có) |
| Class đã được migrate | ❌ (JSONB deprecated) | ✅ |
| Batch Accrual Job | ❌ | ✅ (query `WHERE rule_type='ACCRUAL'`) |
| Rule reuse nhiều classes | ❌ | ✅ (1 rule → N classes via assignment) |
| Audit lịch sử rule | ❌ | ✅ (SCD Type 2: is_current_flag) |
| Override per BU/LE | ❌ | ✅ (is_override + country/le scope) |

### 4.4 Migration Roadmap (Dần Dần)

```
Phase 1 (NOW): Dual-read, Rule Engine wins if exists
  ├── New classes → Rule Engine only
  └── Existing classes → Policy JSONB (until migrated)

Phase 2 (Sprint N): Data migration script
  ├── Extract JSONB từ leave_policy
  ├── Insert vào absence_rule per rule_type
  └── Create class_rule_assignment records

Phase 3 (Sprint N+2): Remove JSONB columns
  ├── Drop DEPRECATED JSONB columns từ leave_policy
  └── Single path: Rule Engine only
```

---

## 5. Eligibility Flow — WHO Có Thể Dùng Leave Class

```
[HR Admin Setup]
  eligibility.eligibility_profile (domain='ABSENCE')
        │ defined by rules: grade=SENIOR, department=ENGINEERING...
        │
        ▼
  eligibility.eligibility_member   (pre-computed O(1) membership)
        │ employee_id, profile_id, start_date, end_date
        │
  absence.leave_class.default_eligibility_profile_id
        │
        ▼ Check: is employee eligible for this class?
  SELECT 1 FROM eligibility.eligibility_member
  WHERE employee_id = :eid
    AND profile_id = :leave_class.eligibility_profile_id
    AND end_date IS NULL   -- currently eligible

  → YES: allow accrual + request
  → NO:  skip accrual, block request
```

> **Note:** `policy_assignment` table đã bị DEPRECATED (30Mar2026, Change 13).
> `leave_type.eligibility_profile_id` và `leave_policy.eligibility_profile_id` cũng bị REMOVED.
> **Single source of truth:** `leave_class.default_eligibility_profile_id`

---

## 6. Balance State Machine — leave_instant

```
  current_qty   = Tổng đã earn (grant + accrual, không bao giờ giảm khi request)
  hold_qty      = Đang giữ chỗ (reservation confirmed, chưa duyệt)
  available_qty = current_qty - hold_qty - used_qty

  Sự kiện:            current_qty  hold_qty  used_qty  available_qty
  ─────────────────────────────────────────────────────────────────
  GRANT/ACCRUAL:          +N           0         0           +N
  CARRY (đầu năm):        +N           0         0           +N
  BOOK_HOLD (request):     0          +N         0           -N
  CANCEL/REJECT:            0          -N         0           +N
  APPROVE (settle):         0          -N        +N            0
  EXPIRE (FEFO expired):   -N           0         0           -N
  ADJUST (HR manual):      ±N           0         0           ±N
```

---

## 7. FEFO Engine — leave_instant_detail + leave_reservation_line

```
Employee có 2 lots:
  Lot A: CARRY, lot_qty=3, expire_date=2026-03-31, priority=1
  Lot B: GRANT, lot_qty=14, expire_date=2026-12-31, priority=2

Employee xin nghỉ 5 ngày:
  Step 1: Query lots theo FEFO
    SELECT id, lot_qty - used_qty AS remaining, expire_date
    FROM leave_instant_detail
    WHERE instant_id = :id AND (lot_qty - used_qty) > 0
    ORDER BY expire_date ASC, priority ASC

  Step 2: Calculate allocation
    Lot A: remaining=3, allocate=3  → reservation_line_1 (reserved_amount=3)
    Lot B: remaining=14, allocate=2 → reservation_line_2 (reserved_amount=2)

  Step 3: Create reservation_lines
    leave_reservation_line (Lot A, 3 days, expiry=2026-03-31)
    leave_reservation_line (Lot B, 2 days, expiry=2026-12-31)

  On Approve: lot_qty deducted từ Lot A first → Lot A.used_qty=3, Lot B.used_qty=2
```

---

## 8. Cross-Context Integration — Attendance ↔ Absence

> Rule: **Service-level calls only, KHÔNG dùng FK cross-schema.**

```
Absence Service → Attendance Service (khi validate leave request):
  API Call: POST /attendance/validate-working-days
  Request:  { employee_id, start_date, end_date }
  Response: { working_days: 4, day_details: [...] }
  Usage:    leave_request.total_days = response.working_days
```

```
Attendance Service → Absence Service (khi tính công):
  API Call: GET /absence/requests?employee_id=:id&date=:date&status=APPROVED
  Response: { approved_leaves: [...] }
  Usage:    Trừ ngày nghỉ khỏi working_time calculation
```

---

## 9. Tóm Tắt Entities và Vai Trò

| Entity | Tầng | Vai Trò | Tần suất thay đổi |
|--------|------|---------|-------------------|
| `leave_type` | Definition | Danh mục nghỉ phép cấp cao | Rất hiếm (HR Admin) |
| `leave_class` | Definition | Variant + eligibility + unit | Hiếm (HR Admin) |
| `leave_policy` | Definition | Bộ quy tắc gán cho type | Hiếm (HR Admin) |
| `absence_rule` | Definition | Rule engine centralized | Hiếm, versioned (SCD-2) |
| `class_rule_assignment` | Definition | N:N class ↔ rule | Hiếm |
| `leave_instant` | Entitlement | Số dư per employee/class | Monthly (accrual) |
| `leave_instant_detail` | Entitlement | Lot chi tiết (FEFO) | Monthly |
| `leave_movement` | Transaction | Immutable ledger | Daily (nhiều) |
| `leave_request` | Transaction | Đơn xin nghỉ | Daily |
| `leave_reservation` | Transaction | Giữ chỗ số dư | Daily |
| `leave_reservation_line` | Transaction | FEFO reservation breakdown | Daily |

---

## Appendix: Index Strategy per Query Pattern

| Query Pattern | Index dùng |
|--------------|-----------|
| Tìm rules cho 1 class | `class_rule_assignment(class_id, is_current_flag)` |
| Batch accrual: tìm tất cả ACCRUAL rules | `absence_rule(rule_type, status_code)` |
| Check balance employee | `leave_instant(employee_id, class_id)` |
| FEFO lots | `leave_instant_detail(instant_id, expire_date)` |
| Pending requests | `leave_request(employee_id, status_code)` |
| Idempotency accrual run | `leave_accrual_run(plan_rule_id, period_start) UNIQUE` |
