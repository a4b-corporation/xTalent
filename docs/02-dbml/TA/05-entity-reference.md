# Entity Reference - Technical Glossary with Sample Data

**Purpose:** Technical reference cho tất cả entities trong TA module  
**Last Updated:** 2026-04-01

---

## How to Use This Document

**Entity Detail Level:**
- ⭐ **Critical entities** → Full details + multiple samples
- ⚡ **Important entities** → Key fields + sample data
- 📄 **Supporting entities** → Summary only

**Legend:**
- `PK` = Primary Key
- `FK` = Foreign Key
- `UK` = Unique Key
- `NN` = Not Null

---

## ta.scheduling - Scheduling Entities

### ⭐ TimeSegment (Level 1 - Atomic Unit)

**Business Definition:** Đơn vị atomic nhất của thời gian làm việc (WORK, BREAK, MEAL, TRANSFER).

**Database Purpose:** Building block để compose lên Shift. Có thể relative (offset) hoặc absolute (fixed time).

**Key Fields:**

| Field | Type | Purpose | Constraints |
|-------|------|---------|-------------|
| `code` | varchar(50) | Unique identifier | UK |
| `segment_type` | varchar(20) | WORK, BREAK, MEAL, TRANSFER | NN |
| `duration_minutes` | int | Segment duration | NN |
| `is_paid` | boolean | Paid or unpaid | Default: false |
| `premium_code` | varchar(50) | Night shift, hazard premium | Nullable |

**Sample Data:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "code": "WORK_MORNING",
  "name": "Work Morning Session",
  "segment_type": "WORK",
  "start_offset_min": 0,
  "end_offset_min": 240,
  "duration_minutes": 240,
  "is_paid": true,
  "is_mandatory": true,
  "premium_code": null,
  "is_active": true
}
```

**Relationships:**
- Referenced by: `ShiftSegment.segment_id`
- Used in: Shift composition

---

### ⭐ ShiftDefinition (Level 2 - Shift Template)

**Business Definition:** Composition của TimeSegments tạo thành một ca làm việc hoàn chỉnh.

**Database Purpose:** Template cho shift assignment. 3 types: ELAPSED (fixed), PUNCH (flexible), FLEX (hybrid).

**Key Fields:**

| Field | Type | Purpose | Constraints |
|-------|------|---------|-------------|
| `code` | varchar(50) | Unique identifier | UK |
| `shift_type` | varchar(20) | ELAPSED, PUNCH, FLEX | NN |
| `reference_start_time` | time | Fixed shift start (ELAPSED) | Nullable |
| `reference_end_time` | time | Fixed shift end (ELAPSED) | Nullable |
| `total_work_hours` | decimal(5,2) | Total work hours | NN |
| `cross_midnight` | boolean | Overnight shift | Default: false |
| `grace_in_minutes` | int | Late arrival tolerance | Default: 0 |
| `rounding_interval_min` | int | Time rounding | Default: 15 |

**Sample Data:**

**Day Shift (ELAPSED):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440010",
  "code": "DAY_SHIFT_8H",
  "name": "Day Shift 8 Hours",
  "shift_type": "ELAPSED",
  "reference_start_time": "08:00:00",
  "reference_end_time": "17:00:00",
  "total_work_hours": 8.00,
  "total_break_hours": 1.00,
  "total_paid_hours": 8.00,
  "cross_midnight": false,
  "grace_in_minutes": 0,
  "color": "#4A90E2"
}
```

**Night Shift (Overnight):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440011",
  "code": "NIGHT_SHIFT",
  "name": "Night Shift",
  "shift_type": "ELAPSED",
  "reference_start_time": "22:00:00",
  "reference_end_time": "06:00:00",
  "total_work_hours": 8.00,
  "cross_midnight": true,
  "color": "#9013FE"
}
```

**Retail Flexible (PUNCH):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440012",
  "code": "RETAIL_FLEX",
  "name": "Retail Flexible Shift",
  "shift_type": "PUNCH",
  "total_work_hours": 8.00,
  "grace_in_minutes": 10,
  "grace_out_minutes": 10,
  "rounding_interval_min": 15,
  "rounding_mode": "NEAREST",
  "color": "#7ED321"
}
```

**Relationships:**
- Composed of: `ShiftSegment` → `TimeSegment`
- Has breaks: `ShiftBreak`
- Referenced by: `DayModel.shift_id`, `AttendanceRecord.shift_id`

---

### ⚡ DayModel (Level 3 - Daily Template)

**Business Definition:** Template định nghĩa điều gì xảy ra trong một ngày (WORK, OFF, HOLIDAY, HALF_DAY).

**Database Purpose:** Connect pattern to shift. Handle holiday overrides.

**Key Fields:**

| Field | Type | Purpose |
|-------|------|---------|
| `day_type` | varchar(20) | WORK, OFF, HOLIDAY, HALF_DAY |
| `shift_id` | uuid | FK to ShiftDef (if WORK) |
| `is_half_day` | boolean | Half-day flag |
| `half_day_period` | varchar(10) | MORNING, AFTERNOON |

**Sample Data:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440030",
  "code": "WORK_DAY",
  "name": "Standard Work Day",
  "day_type": "WORK",
  "shift_id": "550e8400-e29b-41d4-a716-446655440010",
  "is_half_day": false
}
```

**Relationships:**
- References: `ShiftDef.id`
- Referenced by: `PatternDay.day_model_id`

---

### ⚡ PatternTemplate (Level 4 - Cycle)

**Business Definition:** Chu kỳ lặp lại của DayModels (5x8, 4on-4off, 14/14, etc.).

**Database Purpose:** Define repeating schedule pattern with rotation support.

**Key Fields:**

| Field | Type | Purpose |
|-------|------|---------|
| `cycle_length_days` | int | Number of days in cycle |
| `rotation_type` | varchar(20) | FIXED, ROTATING |
| `pattern_json` | jsonb | Array of day model references |

**Sample Data:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440040",
  "code": "5X8_STANDARD",
  "name": "5x8 Standard Week",
  "cycle_length_days": 7,
  "rotation_type": "FIXED",
  "pattern_json": {
    "days": [
      {"day_number": 1, "day_model_id": "DAY_MODEL_ID"},
      {"day_number": 2, "day_model_id": "DAY_MODEL_ID"},
      {"day_number": 3, "day_model_id": "DAY_MODEL_ID"},
      {"day_number": 4, "day_model_id": "DAY_MODEL_ID"},
      {"day_number": 5, "day_model_id": "DAY_MODEL_ID"},
      {"day_number": 6, "day_model_id": "OFF_DAY_ID"},
      {"day_number": 7, "day_model_id": "OFF_DAY_ID"}
    ]
  }
}
```

---

### ⭐ ScheduleAssignment (Level 5 - Assignment)

**Business Definition:** Kết nối Pattern với Calendar và Rotation Offset, xác định WHO gets WHICH pattern.

**Database Purpose:** Critical entity for roster generation. Defines assignment scope and rotation.

**Key Fields:**

| Field | Type | Purpose |
|-------|------|---------|
| `pattern_id` | uuid | FK to PatternTemplate |
| `holiday_calendar_id` | uuid | FK to HolidayCalendar |
| `start_reference_date` | date | Rotation anchor point |
| `offset_days` | int | Rotation offset (0, 7, 14, etc.) |
| `employee_id` | uuid | Individual assignment |
| `employee_group_id` | uuid | Group assignment |
| `position_id` | uuid | Position-based assignment |

**Sample Data:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440050",
  "code": "CREW_A_24X7",
  "name": "Production Crew A - 24/7 Rotation",
  "pattern_id": "PATTERN_21DAY_ID",
  "holiday_calendar_id": "VN_CALENDAR_2026",
  "start_reference_date": "2025-01-01",
  "offset_days": 0,
  "employee_group_id": "TEAM_CREW_A",
  "effective_start": "2025-01-01"
}
```

**Rotation Offset Explanation:**
```
Pattern: 21-day cycle [Day×7 · Off×7 · Evening×7]

Crew A: offset=0  → Week 1: Day Shift
Crew B: offset=7  → Week 1: Off
Crew C: offset=14 → Week 1: Evening Shift
```

---

### ⭐ GeneratedRoster (Level 6 - Materialized Schedule)

**Business Definition:** Kết quả cuối cùng - 1 row cho mỗi employee × mỗi day.

**Database Purpose:** Materialized schedule with full lineage tracking.

**Key Fields:**

| Field | Type | Purpose |
|-------|------|---------|
| `employee_id` | uuid | FK to Employee |
| `work_date` | date | Schedule date |
| `schedule_rule_id` | uuid | FK to ScheduleAssignment |
| `shift_id` | uuid | FK to ShiftDef |
| `is_override` | boolean | Manual override flag |
| `is_holiday` | boolean | Holiday flag |
| `status_code` | varchar(20) | SCHEDULED, CONFIRMED, COMPLETED, CANCELLED |

**Sample Data:**

```json
{
  "employee_id": "EMP001",
  "work_date": "2026-04-07",
  "schedule_rule_id": "SCHEDULE_RULE_ID",
  "pattern_id": "PATTERN_ID",
  "day_model_id": "DAY_MODEL_ID",
  "shift_id": "DAY_SHIFT_ID",
  "is_override": false,
  "is_holiday": false,
  "status_code": "SCHEDULED"
}
```

**Unique Constraint:** `(employee_id, work_date)` UK

---

### 📄 Supporting Tables

**ShiftSegment:** Links ShiftDef to TimeSegment with sequence
- Composite PK: `(shift_id, segment_id)`
- Fields: `sequence_order`, `override_duration_min`, `override_is_paid`

**PatternDay:** Links PatternTemplate to DayModel with sequence
- Composite PK: `(pattern_id, day_number)`
- Fields: `day_model_id`

**ScheduleOverride:** Ad-hoc changes to generated roster
- Fields: `employee_id`, `work_date`, `shift_id`, `reason_code`

**OpenShiftPool:** Unfilled shifts for bidding
- Fields: `work_date`, `shift_id`, `qty_needed`, `qty_claimed`, `status_code`

---

## ta.attendance - Attendance Entities

### ⭐ ClockEvent (Raw Punch Data)

**Business Definition:** Immutable record của mỗi lần clock in/out.

**Database Purpose:** Source of truth for attendance. Append-only (ADR-TA-001).

**Key Fields:**

| Field | Type | Purpose | Constraints |
|-------|------|---------|-------------|
| `employee_id` | uuid | FK to Employee | NN |
| `event_dt` | timestamptz | Event timestamp (UTC) | NN |
| `event_type` | varchar(10) | IN, OUT, BREAK_IN, BREAK_OUT | NN |
| `source` | varchar(50) | MOBILE, KIOSK, WEB, API | NN |
| `sync_status` | varchar(20) | PENDING, SYNCED, CONFLICT | Default: SYNCED |
| `geofence_validated` | boolean | Location validated | Default: false |
| `is_correction` | boolean | Correction punch | Default: false |
| `idempotency_key` | varchar(255) | Deduplication key | UK |

**Sample Data:**

**Regular Clock In:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "employee_id": "EMP001",
  "event_dt": "2026-04-07T01:02:00Z",
  "event_type": "IN",
  "source": "MOBILE",
  "device_id": "mobile-iphone-123",
  "geo_lat": 10.7769,
  "geo_long": 106.7009,
  "sync_status": "SYNCED",
  "geofence_validated": true,
  "is_correction": false,
  "idempotency_key": "emp001-20260407-in-mobile"
}
```

**Offline Punch:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440002",
  "employee_id": "EMP002",
  "event_dt": "2026-04-07T00:58:00Z",
  "event_type": "IN",
  "source": "MOBILE",
  "sync_status": "PENDING",
  "synced_at": null,
  "geofence_validated": true
}
```

**Correction Punch:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440003",
  "employee_id": "EMP001",
  "event_dt": "2026-04-07T06:30:00Z",
  "event_type": "OUT",
  "source": "WEB",
  "is_correction": true,
  "corrects_event_id": "ORIGINAL_EVENT_ID"
}
```

**Indexes:**
- `(employee_id, event_dt)`
- `(idempotency_key)` UK
- `(employee_id, sync_status)`

---

### ⚡ AttendanceRecord (Processed Daily Attendance)

**Business Definition:** Bản ghi chấm công đã xử lý cho mỗi ngày.

**Database Purpose:** Calculated attendance with hours, status, exceptions.

**Key Fields:**

| Field | Type | Purpose |
|-------|------|---------|
| `attendance_date` | date | Ngày chấm công |
| `clock_in_time` | timestamptz | Giờ vào thực tế |
| `clock_out_time` | timestamptz | Giờ ra thực tế |
| `actual_hours` | decimal(5,2) | Giờ làm việc calculated |
| `status_code` | varchar(20) | PRESENT, ABSENT, LATE, EARLY_DEPARTURE, HALF_DAY, ON_LEAVE |
| `late_minutes` | int | Số phút đi muộn |
| `early_departure_minutes` | int | Số phút về sớm |

**Sample Data:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440010",
  "employee_id": "EMP001",
  "shift_id": "DAY_SHIFT_ID",
  "attendance_date": "2026-04-07",
  "clock_in_time": "2026-04-07T01:02:00Z",
  "clock_out_time": "2026-04-07T10:05:00Z",
  "scheduled_start_time": "01:00:00",
  "scheduled_end_time": "10:00:00",
  "actual_hours": 8.05,
  "scheduled_hours": 8.00,
  "status_code": "PRESENT",
  "late_minutes": 0
}
```

---

### ⚡ TimesheetHeader (Period Summary)

**Business Definition:** Period-level aggregation của attendance data, requiring approval.

**Database Purpose:** Payroll integration interface. Approval workflow.

**Key Fields:**

| Field | Type | Purpose |
|-------|------|---------|
| `employee_id` | uuid | FK to Employee |
| `period_start` | date | Period start |
| `period_end` | date | Period end |
| `status_code` | varchar(20) | OPEN, SUBMITTED, APPROVED, LOCKED |
| `total_hours` | decimal(6,2) | Total hours for period |
| `period_id` | uuid | FK to Period |

**Sample Data:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440020",
  "employee_id": "EMP001",
  "period_start": "2026-04-01",
  "period_end": "2026-04-30",
  "status_code": "SUBMITTED",
  "total_hours": 184.00,
  "period_id": "PERIOD_202604"
}
```

---

### ⚡ OvertimeRequest (Pre-Approval)

**Business Definition:** Request for authorization to work beyond scheduled hours.

**Database Purpose:** OT workflow with VLC cap enforcement.

**Key Fields:**

| Field | Type | Purpose | VLC Reference |
|-------|------|---------|---------------|
| `ot_type` | varchar(20) | WEEKDAY, WEEKEND, PUBLIC_HOLIDAY | Art. 98 |
| `ot_rate` | decimal(4,2) | 1.5, 2.0, 3.0 | Art. 98 |
| `daily_ot_cap_hours` | decimal(4,2) | Max OT/day (4) | Art. 107 |
| `monthly_ot_cap_hours` | decimal(6,2) | Max OT/month (40) | Art. 107 |
| `annual_ot_cap_hours` | decimal(6,2) | Max OT/year (200-300) | Art. 107 |
| `comp_time_elected` | boolean | Comp time instead of pay | - |

**Sample Data:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440040",
  "worker_id": "EMP001",
  "planned_date": "2026-04-07",
  "estimated_hours": 2.00,
  "reason": "Project deadline",
  "ot_type": "WEEKDAY",
  "ot_rate": 1.50,
  "comp_time_elected": false,
  "daily_ot_cap_hours": 4.00,
  "monthly_ot_cap_hours": 40.00,
  "annual_ot_cap_hours": 200.00,
  "status_code": "APPROVED",
  "approved_by": "MGR001"
}
```

---

### 📄 CompTimeBalance

**Fields:** `earned_hours`, `used_hours`, `available_hours`, `expiry_date`, `expiry_action`

**Sample:**
```json
{
  "employee_id": "EMP001",
  "earned_hours": 12.00,
  "used_hours": 4.00,
  "available_hours": 8.00,
  "expiry_date": "2026-06-30",
  "expiry_action": "CASHOUT"
}
```

---

## ta.absence - Absence Entities

### ⭐ LeaveType (Configuration Root)

**Business Definition:** Configuration object định nghĩa từng loại nghỉ phép.

**Database Purpose:** Root entity for leave configuration. VLC compliance built-in.

**Key Fields:**

| Field | Type | Purpose | Constraints |
|-------|------|---------|-------------|
| `code` | varchar(50) | Unique identifier | PK |
| `entitlement_basis` | enum | FIXED, ACCRUAL, UNLIMITED | - |
| `unit_code` | varchar(10) | DAY, HOUR | NN |
| `allows_half_day` | boolean | Allow 0.5-day requests | Default: false |
| `cancellation_deadline_days` | int | Days before start for self-cancel | Default: 1 |

**Sample Data:**

**Annual Leave:**
```json
{
  "code": "ANNUAL",
  "name": "Nghỉ phép năm",
  "is_paid": true,
  "is_quota_based": true,
  "requires_approval": true,
  "unit_code": "DAY",
  "core_min_unit": 0.50,
  "allows_half_day": true,
  "holiday_handling": "EXCLUDE_HOLIDAYS",
  "cancellation_deadline_days": 1,
  "country_code": "VN"
}
```

**Sick Leave:**
```json
{
  "code": "SICK",
  "name": "Nghỉ ốm đau",
  "is_paid": true,
  "unit_code": "DAY",
  "core_min_unit": 1.00,
  "allows_half_day": false,
  "holiday_handling": "INCLUDE_HOLIDAYS"
}
```

---

### ⚡ LeaveClass (Grouping)

**Business Definition:** Groups LeaveTypes for shared policy rules.

**Database Purpose:** Policy assignment and deduction priority.

**Key Fields:**

| Field | Type | Purpose |
|-------|------|---------|
| `type_code` | varchar(50) | FK to LeaveType.code |
| `code` | varchar(50) | Unique identifier |
| `mode_code` | varchar(10) | ACCOUNT, LIMIT, UNPAID |
| `default_eligibility_profile_id` | uuid | WHO is eligible |

**Sample Data:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440101",
  "type_code": "ANNUAL",
  "code": "ANNUAL_STANDARD",
  "name": "Annual Leave - Standard",
  "mode_code": "ACCOUNT",
  "unit_code": "DAY"
}
```

---

### ⚡ LeavePolicy (Rules Engine)

**Business Definition:** Defines rules for accrual, carryover, limits, validation, proration, seniority.

**Database Purpose:** Configurable policy framework.

**Policy Types:**

| Type | Config Schema |
|------|---------------|
| `ACCRUAL` | `{method, amount_per_period, frequency, max_balance}` |
| `CARRY` | `{allow_carry, max_carry_qty, expiry_months}` |
| `LIMIT` | `{max_per_request, max_per_month, max_per_year}` |
| `SENIORITY` | `{tiers[{min_years, max_years, days}]}` |

**Sample Data:**

**Accrual Policy:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440111",
  "type_code": "ANNUAL",
  "code": "ACCRUAL_MONTHLY_14D",
  "name": "Monthly Accrual - 14 Days/Year",
  "policy_type": "ACCRUAL",
  "config_json": {
    "method": "MONTHLY_PRO_RATA",
    "amount_per_period": 1.167,
    "frequency": "MONTHLY",
    "max_balance": 30.0
  }
}
```

**Seniority Policy:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440112",
  "code": "SENIORITY_VLC113",
  "policy_type": "SENIORITY",
  "config_json": {
    "vlc_reference": "Vietnam Labor Code 2019, Article 113",
    "tiers": [
      {"min_years": 0, "max_years": 5, "entitlement_days": 14},
      {"min_years": 5, "max_years": 10, "entitlement_days": 15}
    ]
  }
}
```

---

### ⭐ LeaveInstant (Balance Snapshot)

**Business Definition:** Point-in-time balance state per employee × leave class.

**Database Purpose:** Computed balance view from ledger stream.

**Key Fields:**

| Field | Type | Purpose |
|-------|------|---------|
| `current_qty` | decimal(10,2) | Earned - Used |
| `hold_qty` | decimal(10,2) | Reserved for pending requests |
| `available_qty` | decimal(10,2) | current - hold |
| `limit_yearly` | decimal(10,2) | Annual usage limit |
| `used_ytd` | decimal(10,2) | Used this year |

**Sample Data:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440131",
  "employee_id": "EMP001",
  "class_id": "CLASS_ID",
  "state_code": "ACTIVE",
  "current_qty": 14.00,
  "hold_qty": 2.00,
  "available_qty": 12.00,
  "limit_yearly": 15.00,
  "used_ytd": 0.00
}
```

---

### ⭐ LeaveMovement (Immutable Ledger)

**Business Definition:** Immutable ledger record of every balance change event.

**Database Purpose:** Source of truth for balance. Append-only (ADR-TA-001).

**Movement Types:**

| Type | Effect | Description |
|------|--------|-------------|
| `EARN` | +credit | Accrual, grant, carryover |
| `USE` | -debit | Leave taken |
| `RESERVE` | -debit | Pending request hold |
| `RELEASE` | +credit | Reservation released |
| `EXPIRE` | -debit | Balance expired |
| `ADJUST` | ± | Manual HR adjustment |

**Sample Data:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440151",
  "instant_id": "INSTANT_ID",
  "class_id": "CLASS_ID",
  "event_code": "ACCRUAL_MONTHLY",
  "qty": 1.17,
  "unit_code": "DAY",
  "effective_date": "2026-01-31",
  "expire_date": "2026-12-31",
  "idempotency_key": "ACC-EMP001-202601"
}
```

---

### ⚡ LeaveRequest (Workflow)

**Business Definition:** Employee request for time off.

**Database Purpose:** Workflow object with full lifecycle.

**States:** SUBMITTED → UNDER_REVIEW → APPROVED/REJECTED → CANCELLATION_PENDING → CANCELLED

**Sample Data:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440161",
  "employee_id": "EMP001",
  "class_id": "CLASS_ID",
  "start_dt": "2026-04-07T00:00:00Z",
  "end_dt": "2026-04-09T23:59:59Z",
  "total_days": 3.00,
  "status_code": "APPROVED",
  "reason": "Family vacation",
  "approved_by": "MGR001"
}
```

---

### ⚡ LeaveInstantDetail (FEFO Lots)

**Business Definition:** Tracks individual lots/grants with expiry dates.

**Database Purpose:** Foundation for FEFO consumption.

**Lot Kinds:** GRANT, CARRY, BONUS, TRANSFER, OTHER

**Sample Data:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440141",
  "instant_id": "INSTANT_ID",
  "lot_kind": "CARRY",
  "eff_date": "2026-01-01",
  "expire_date": "2026-03-31",
  "lot_qty": 3.00,
  "used_qty": 0.00,
  "priority": 50
}
```

---

### ⚡ LeaveEventRun (Generalized Batch Tracking)

**Business Definition:** Tracks all batch event executions (ACCRUAL, CARRY, EXPIRE, etc.).

**Database Purpose:** Replaces LeaveAccrualRun with generalized event processing.

**Key Fields:**

| Field | Type | Purpose |
|-------|------|---------|
| `event_def_id` | uuid | FK to LeaveEventDef |
| `class_id` | uuid | Leave class (null = all) |
| `period_id` | uuid | FK to LeavePeriod |
| `run_status` | varchar | RUNNING, COMPLETED, FAILED, SKIPPED, CANCELED |
| `employee_count` | int | Employees processed |
| `movements_created` | int | LeaveMovement records created |
| `idempotency_key` | varchar | Prevents double-run |

**Sample Data:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440181",
  "event_def_id": "EVENT_DEF_ACCRUAL",
  "class_id": "CLASS_ANNUAL_STD",
  "period_id": "PERIOD_202604",
  "run_status": "COMPLETED",
  "started_at": "2026-04-30T23:00:00Z",
  "completed_at": "2026-04-30T23:05:00Z",
  "employee_count": 500,
  "movements_created": 500,
  "employees_skipped": 25
}
```

---

### 📄 LeaveClassEvent (N:N Mapping)

**Business Definition:** Maps LeaveClass to LeaveEventDef with qty formula.

**Database Purpose:** Event routing configuration.

**Sample Data:**
```json
{
  "class_id": "CLASS_ANNUAL_STD",
  "event_def_id": "EVENT_DEF_ACCRUAL",
  "qty_formula": "+seniority_calc",
  "idempotent": true
}
```

---

### 📄 LeavePeriod (Period Hierarchy)

**Business Definition:** Period hierarchy YEAR → QUARTER → MONTH.

**Database Purpose:** Financial reporting structure for leave movements.

**Sample Data:**
```json
{
  "id": "PERIOD_FY2026M04",
  "code": "FY2026M04",
  "parent_id": "PERIOD_FY2026Q2",
  "level_code": "MONTH",
  "start_date": "2026-04-01",
  "end_date": "2026-04-30",
  "status_code": "OPEN"
}
```

---

### 📄 TeamLeaveLimit (Staffing Rules)

**Business Definition:** Limits concurrent absence in org unit.

**Database Purpose:** Prevents understaffing.

**Sample Data:**
```json
{
  "org_unit_id": "TEAM_ENGINEERING",
  "leave_type_code": "ANNUAL",
  "limit_pct": 20.00,
  "escalation_level": 2
}
```

---

### ⚡ LeaveReservationLine (FEFO Lot Allocation)

**Business Definition:** Maps reservation to specific LeaveInstantDetail lots.

**Database Purpose:** FEFO tracking with FK integrity.

**Sample Data:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440171",
  "reservation_id": "RESERVATION_ID",
  "source_lot_id": "LOT_ID",
  "reserved_amount": 3.00,
  "expiry_date": "2026-03-31"
}
```

---

### 📄 ClassPolicyAssignment (N:N Mapping)

**Business Definition:** Maps LeaveClass to LeavePolicy with priority.

**Database Purpose:** Replaces ClassRuleAssignment (absence_rule deprecated).

**Sample Data:**
```json
{
  "class_id": "CLASS_ANNUAL_STD",
  "policy_id": "POLICY_ACCRUAL_ID",
  "priority": 10,
  "is_override": false,
  "is_current_flag": true
}
```

---

## ta.shared - Shared Entities

### ⚡ Period (Payroll Period)

**Business Definition:** Payroll period lifecycle.

**States:** OPEN → LOCKED → CLOSED

**Sample Data:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440301",
  "code": "2026-04",
  "name": "April 2026",
  "period_type": "MONTHLY",
  "start_date": "2026-04-01",
  "end_date": "2026-04-30",
  "status_code": "OPEN"
}
```

---

### ⚡ HolidayCalendar

**Business Definition:** Country-specific public holidays.

**Sample Data:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440311",
  "code": "VN_2026",
  "name": "Vietnam Public Holidays 2026",
  "region_code": "VN"
}
```

---

### ⚡ TimeTypeElementMap

**Business Definition:** Maps time types to payroll pay elements.

**Sample Data:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440321",
  "time_type_code": "OT1.5",
  "pay_element_code": "OVERTIME_150",
  "rate_source_code": "FORMULA",
  "default_rate": 1.50,
  "rate_unit": "MULTIPLIER"
}
```

---

## Quick Reference: All Entities

| Context | Entity | Critical? | Purpose |
|---------|--------|:---------:|---------|
| **scheduling** | TimeSegment | ⭐ | Atomic time unit |
| | ShiftDefinition | ⭐ | Shift template |
| | DayModel | ⚡ | Daily template |
| | PatternTemplate | ⚡ | Cycle pattern |
| | ScheduleAssignment | ⭐ | Assignment + rotation |
| | GeneratedRoster | ⭐ | Materialized schedule |
| **attendance** | ClockEvent | ⭐ | Raw punch (append-only) |
| | AttendanceRecord | ⚡ | Daily attendance |
| | TimesheetHeader | ⚡ | Period summary |
| | OvertimeRequest | ⚡ | OT pre-approval |
| | CompTimeBalance | 📄 | Comp time tracking |
| | PayrollExportPackage | ⚡ | Payroll dispatch tracking |
| **absence** | LeaveType | ⭐ | Leave configuration |
| | LeaveClass | ⚡ | Leave grouping |
| | LeavePolicy | ⚡ | Policy rules |
| | ClassPolicyAssignment | 📄 | Class-Policy N:N mapping |
| | LeaveInstant | ⭐ | Balance snapshot |
| | LeaveMovement | ⭐ | Immutable ledger |
| | LeaveInstantDetail | ⚡ | FEFO lots |
| | LeaveRequest | ⚡ | Request workflow |
| | LeaveReservation | ⚡ | Balance hold |
| | LeaveReservationLine | ⚡ | FEFO lot allocation |
| | LeaveEventDef | 📄 | Event type definitions |
| | LeaveEventRun | ⚡ | Batch event execution |
| | LeaveClassEvent | 📄 | Class-Event N:N mapping |
| | LeavePeriod | 📄 | Period hierarchy (YEAR→QTR→MO) |
| | TeamLeaveLimit | 📄 | Staffing rules |
| | TerminationBalanceRecord | ⚡ | Exit balance snapshot |
| **shared** | Period | ⚡ | Payroll period |
| | HolidayCalendar | ⚡ | Public holidays |
| | TimeTypeElementMap | ⚡ | TA→Payroll mapping |

### Deprecated Entities

| Entity | Status | Replacement |
|--------|:------:|-------------|
| LeaveAccrualRun | ❌ | LeaveEventRun (generalized) |
| AbsenceRule | ❌ | LeavePolicy.config_json |
| PolicyAssignment | ❌ | Core eligibility engine |

---

*Next: [06-erd-diagrams.md](./06-erd-diagrams.md) - Complete ERD Collection*