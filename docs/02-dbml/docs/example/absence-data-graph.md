# Absence Sub-module - Data Graph

## Tổng quan

Data graph mô tả quan hệ từ **employee** đến các实体 trong sub-module **Absence Management**, bao gồm:
- Eligibility mapping
- Leave Class → Leave Type → Leave Policy
- Leave Instant (instance per employee per class)
- Leave Request và workflow approval

---

## Entity-Relationship Diagram

```mermaid
erDiagram
    %% ========== EMPLOYEE CORE ==========
    employment.employee ||--o{ eligibility.eligibility_member : "assigned to"
    employment.employee ||--o{ absence.leave_instant : "has many"
    employment.employee ||--o{ absence.leave_request : "submits"
    
    %% ========== EMPLOYEE ATTRIBUTES ==========
    employment.employee {
        uuid id PK
        uuid worker_id FK
        varchar employee_code
        varchar employee_type_code
        varchar status_code
        date hire_date
        date termination_date
    }
    
    person.worker ||--|| employment.employee : "has employment"
    person.worker {
        uuid id PK
        varchar first_name
        varchar last_name
        date date_of_birth
        varchar nationality_code
    }
    
    employment.assignment {
        uuid id PK
        uuid employee_id FK
        uuid position_id FK
        uuid business_unit_id FK
        uuid job_id FK
    }
    
    employment.employee ||--o{ employment.assignment : "has assignments"
    
    %% ========== ELIGIBILITY ENGINE ==========
    eligibility.eligibility_profile ||--o{ eligibility.eligibility_member : "contains"
    eligibility.eligibility_profile {
        uuid id PK
        varchar code UK
        varchar name
        varchar domain "ABSENCE | BENEFITS | COMPENSATION"
        jsonb rule_json "dynamic criteria"
        int priority
    }
    
    eligibility.eligibility_member {
        uuid id PK
        uuid profile_id FK
        uuid employee_id FK
        date start_date
        date end_date
        timestamp last_evaluated_at
        varchar evaluation_source
    }
    
    %% Link eligibility to leave class
    absence.leave_class ||--o{ eligibility.eligibility_profile : "uses for eligibility"
    absence.leave_class {
        uuid id PK
        varchar type_code FK
        varchar code UK
        varchar name
        uuid default_eligibility_profile_id FK
        jsonb eligibility_json "deprecated"
        jsonb rules_json "deprecated"
    }
    
    %% ========== LEAVE TYPE HIERARCHY ==========
    absence.leave_type ||--o{ absence.leave_class : "categorized into"
    absence.leave_type {
        varchar code PK
        varchar name
        boolean is_paid
        boolean is_quota_based
        varchar unit_code "HOUR | DAY"
        int cancellation_deadline_days
    }
    
    absence.leave_class ||--o{ absence.leave_policy : "defined by"
    
    absence.leave_policy {
        uuid id PK
        varchar type_code FK
        varchar code UK
        uuid class_id FK
        jsonb accrual_rule_json "deprecated"
        jsonb carry_rule_json "deprecated"
    }
    
    %% ========== LEAVE INSTANT (per employee instance) ==========
    absence.leave_instant {
        uuid id PK
        uuid employee_id FK
        uuid class_id FK
        varchar state_code "ACTIVE | SUSPENDED"
        decimal current_qty
        decimal hold_qty
        decimal available_qty
        decimal used_ytd
        decimal used_mtd
    }
    
    absence.leave_instant ||--o{ absence.leave_instant_detail : "contains lots"
    absence.leave_instant_detail {
        uuid id PK
        uuid instant_id FK
        varchar lot_kind "GRANT | CARRY | BONUS"
        date eff_date
        date expire_date
        decimal lot_qty
        decimal used_qty
        int priority "FEFO ordering"
    }
    
    absence.leave_instant ||--o{ absence.leave_movement : "tracks movements"
    absence.leave_movement {
        uuid id PK
        uuid instant_id FK
        uuid class_id FK
        varchar event_code "EARN | USE | RESERVE | RELEASE"
        decimal qty
        date effective_date
        uuid request_id FK
        uuid lot_id FK
    }
    
    %% ========== LEAVE REQUEST WORKFLOW ==========
    absence.leave_request {
        uuid id PK
        uuid employee_id FK
        uuid class_id FK
        timestamp start_dt
        timestamp end_dt
        decimal total_days
        varchar status_code "DRAFT | PENDING | APPROVED | REJECTED"
        uuid instant_id FK
    }
    
    absence.leave_request ||--|| absence.leave_reservation : "has reservation"
    absence.leave_reservation {
        uuid request_id PK FK
        uuid instant_id FK
        decimal reserved_qty
        timestamp expires_at
    }
    
    absence.leave_reservation ||--o{ absence.leave_reservation_line : "contains lines"
    absence.leave_reservation_line {
        uuid id PK
        uuid reservation_id FK
        uuid source_lot_id FK "FK to leave_instant_detail"
        decimal reserved_amount
        date expiry_date
    }
    
    %% ========== ABSENCE RULE ENGINE (30Mar2026) ==========
    absence.absence_rule ||--o{ absence.class_rule_assignment : "assigned to class"
    absence.absence_rule {
        uuid id PK
        varchar rule_type "ACCRUAL | CARRY | LIMIT | VALIDATION | SENIORITY"
        varchar code UK
        varchar name
        jsonb config_json
        date effective_start
        boolean is_current_flag
    }
    
    absence.class_rule_assignment {
        uuid id PK
        uuid class_id FK
        uuid rule_id FK
        int priority
        boolean is_override
    }
    
    absence.leave_class ||--o{ absence.class_rule_assignment : "has rules"
    
    %% ========== ACCRUAL BATCH ==========
    absence.leave_accrual_run {
        uuid id PK
        uuid plan_rule_id FK "ACCRUAL rule"
        date period_start
        date period_end
        varchar status_code "RUNNING | COMPLETED | FAILED"
        int employee_count
        int movements_created
    }
    
    %% ========== RELATIONSHIPS ==========
    absence.leave_class }|--|{ absence.leave_instant : "generates instance per employee"
    absence.leave_instant }|--|{ absence.leave_request : "backed by"
    absence.leave_request }|--|| absence.leave_movement : "triggers movement on approval"
    
    %% ========== HOLIDAY CALENDAR ==========
    absence.holiday_calendar ||--o{ absence.holiday_date : "contains dates"
    absence.holiday_calendar {
        uuid id PK
        varchar code UK
        varchar name
        varchar region_code
        boolean deduct_flag
    }
    
    absence.holiday_date {
        uuid calendar_id PK FK
        date holiday_date PK
        varchar name
        boolean is_half_day
    }
    
    %% ========== TERMINATION BALANCE ==========
    employment.employee ||--o| absence.termination_balance_record : "snapshot on termination"
    absence.termination_balance_record {
        uuid id PK
        uuid employee_id FK
        date termination_date
        jsonb balance_snapshots
        varchar balance_action "AUTO_DEDUCT | HR_REVIEW | WRITE_OFF"
        boolean employee_consent_obtained
    }
```

---

## Mối quan hệ chi tiết

### 1. Employee → Eligibility Mapping

```
employee (1) ──< eligibility_member (N) >── (1) eligibility_profile
```

**Mô tả:**
- Mỗi employee có thể thuộc nhiều `eligibility_profile` khác nhau
- `eligibility_profile` chứa `rule_json` để xác định tiêu chí (grade, country, tenure, v.v.)
- `eligibility_member` là bảng cached membership để check O(1)

**Ví dụ:**
```json
// eligibility_profile.rule_json
{
  "grades": ["G4", "G5", "G6"],
  "countries": ["VN"],
  "employee_types": ["FULL_TIME"],
  "min_tenure_months": 12
}
```

---

### 2. Employee → Leave Instant (Leave Account)

```
employee (1) ──< leave_instant (N) >── (1) leave_class >── (1) leave_type
```

**Mô tả:**
- `leave_instant` là "tài khoản leave" của employee cho một `leave_class` cụ thể
- Mỗi employee có thể có nhiều `leave_instant` (một cho mỗi class mà employee được eligible)
- Track: `current_qty`, `hold_qty`, `available_qty`, `used_ytd`, `used_mtd`

---

### 3. Leave Instant → Leave Instant Detail (FEFO Lots)

```
leave_instant (1) ──< leave_instant_detail (N)
```

**Mô tả:**
- `leave_instant_detail` track từng "lot" grant với:
  - `lot_kind`: GRANT, CARRY, BONUS, TRANSFER
  - `expire_date`: ngày hết hạn
  - `priority`: FEFO (First-Expired-First-Out) ordering
  - `lot_qty` / `used_qty`: số dư còn lại

**Ví dụ FEFO consumption:**
```
Employee có 2 lots:
- Lot A: 3 days, expires 2026-03-31, priority=10
- Lot B: 7 days, expires 2026-12-31, priority=20

Request 4 days → consume Lot A (3d) + Lot B (1d)
```

---

### 4. Leave Instant → Leave Movement (Ledger)

```
leave_instant (1) ──< leave_movement (N)
```

**Mô tả:**
- `leave_movement` là immutable ledger ghi nhận mọi biến động:
  - `event_code`: EARN, USE, RESERVE, RELEASE, EXPIRE, ADJUST, CASHOUT
  - `qty`: số lượng (positive cho EARN, negative cho USE)
  - `effective_date`: ngày hiệu lực
  - `lot_id`: FK đến lot cụ thể (FEFO tracking)

---

### 5. Leave Request → Leave Reservation

```
leave_request (1) ──|| leave_reservation (1) ──< leave_reservation_line (N)
```

**Mô tả:**
- Khi employee submit request → tạo `leave_reservation` để giữ chỗ (hold balance)
- `leave_reservation_line` link đến từng `leave_instant_detail` lot theo FEFO
- Status flow:
  - SUBMITTED → RESERVE movement created
  - APPROVED → CONVERTED to USE movement
  - REJECTED → RELEASED movement created

---

### 6. Leave Class → Absence Rule (Rule Engine)

```
leave_class (1) ──< class_rule_assignment (N) >── (N) absence_rule
```

**Mô tả:**
- `absence_rule` là centralized repository cho tất cả business rules
- `rule_type`: ACCRUAL, CARRY, LIMIT, VALIDATION, PRORATION, ROUNDING, SENIORITY
- `class_rule_assignment` là N:N mapping table với `priority` và `is_override`

**Ví dụ absence_rule.config_json:**

```json
// ACCRUAL rule
{
  "method": "MONTHLY",
  "amount_per_period": 1.0833,
  "frequency": "MONTHLY",
  "unit": "DAY",
  "max_balance": 25,
  "tenure_tiers": [
    {"min_years": 0, "entitlement_per_year": 13},
    {"min_years": 5, "entitlement_per_year": 14},
    {"min_years": 10, "entitlement_per_year": 15}
  ]
}

// CARRY rule
{
  "allow_carry": true,
  "max_carry_qty": 5,
  "carry_unit": "DAY",
  "expiry_months_after_year_end": 6,
  "expiry_action": "FORFEITURE"
}

// SENIORITY rule (VLC Art. 113)
{
  "tiers": [
    {"min_years": 0, "max_years": 5, "entitlement_days": 12},
    {"min_years": 5, "max_years": 10, "entitlement_days": 14},
    {"min_years": 10, "max_years": null, "entitlement_days": 16}
  ],
  "vlc_reference": "VLC 2019 Article 113"
}
```

---

### 7. Leave Accrual Run (Batch Processing)

```
absence_rule (ACCRUAL) (1) ──< leave_accrual_run (N) ──> create leave_movement (N)
```

**Mô tả:**
- `leave_accrual_run` track batch execution với idempotency constraint
- Unique constraint: `(plan_rule_id, period_start)` → prevent duplicate runs
- Status: RUNNING → COMPLETED (hoặc FAILED)

---

## Data Flow Example

### Kịch bản: Employee submit annual leave request

```
1. Employee submit leave_request
   ↓
2. System check eligibility via eligibility_member
   ↓
3. Find employee's leave_instant for ANNUAL class
   ↓
4. Check available_qty >= requested_qty
   ↓
5. Create leave_reservation + leave_reservation_line (FEFO from leave_instant_detail)
   ↓
6. Create leave_movement (event_code=RESERVE)
   ↓
7. Update leave_instant.hold_qty
   ↓
8. Manager approves
   ↓
9. Convert RESERVE → USE movement
   ↓
10. Update leave_instant.current_qty, leave_instant_detail.used_qty
   ↓
11. Update leave_instant.hold_qty = 0
```

---

## Indexes & Performance

### Critical Indexes

| Table | Index | Purpose |
|-------|-------|---------|
| `eligibility_member` | `(profile_id, employee_id)` WHERE end_date IS NULL | Fast eligibility check |
| `eligibility_member` | `(employee_id, profile_id)` WHERE end_date IS NULL | Employee's profiles |
| `leave_instant` | `(employee_id, class_id)` | Find instant per employee |
| `leave_instant_detail` | `(instant_id, expire_date)` | FEFO query |
| `leave_movement` | `(instant_id, effective_date)` | Balance history |
| `leave_reservation_line` | `(reservation_id)` | Load reservation details |
| `absence_rule` | `(rule_type, country_code)` | Filter rules by type |

---

## Ghi chú thiết kế

### 1. Centralized Eligibility Engine
- `eligibility_profile` với `domain = 'ABSENCE'` xác định WHO được eligible cho leave class
- `eligibility_member` cached membership → O(1) lookup thay vì evaluate rule_json mỗi lần

### 2. FEFO Engine
- `leave_instant_detail` với `priority` và `expire_date`
- `leave_reservation_line` đảm bảo FK integrity đến lot cụ thể

### 3. Rule Engine (30Mar2026)
- `absence_rule` thay thế JSONB trong `leave_policy`
- `class_rule_assignment` cho phép N:N mapping và reuse rules

### 4. Idempotent Accrual
- `leave_accrual_run` với unique constraint `(plan_rule_id, period_start)`
- Prevent duplicate accrual for same period

---

## Tham chiếu

- File gốc: `/TA/TA-database-design-v5.dbml`
- Core schema: `/CO/1.Core.V4.dbml` (eligibility engine)
- Ngày thiết kế: 2026-03-31
