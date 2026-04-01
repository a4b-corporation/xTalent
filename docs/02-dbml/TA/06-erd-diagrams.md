# ERD Diagrams - Complete Collection

**Purpose:** Visual relationship diagrams cho từng bounded context  
**Last Updated:** 2026-04-01

---

## How to Read These Diagrams

**Mermaid ERD Notation:**
- `||--o{` : One-to-Many
- `||--||` : One-to-One
- `}o--||` : Many-to-One (FK)
- `||--o{` : One-to-Many with ownership

**Legend:**
- **Bold entities** = Critical tables
- *Italic fields* = Primary Key
- Regular fields = Important columns only

---

## 1. Scheduling ERD (6-Level Hierarchy)

```mermaid
erDiagram
    TIME_SEGMENT ||--o{ SHIFT_SEGMENT : "composed into"
    SHIFT_DEF ||--o{ SHIFT_SEGMENT : "contains"
    SHIFT_DEF ||--o{ SHIFT_BREAK : "has breaks"
    
    SHIFT_DEF ||--o{ DAY_MODEL : "linked to"
    DAY_MODEL ||--o{ PATTERN_DAY : "sequenced in"
    PATTERN_TEMPLATE ||--o{ PATTERN_DAY : "defines cycle"
    
    PATTERN_TEMPLATE ||--o{ SCHEDULE_ASSIGNMENT : "used by"
    HOLIDAY_CALENDAR ||--o{ SCHEDULE_ASSIGNMENT : "referenced by"
    
    SCHEDULE_ASSIGNMENT ||--o{ GENERATED_ROSTER : "generates"
    PATTERN_TEMPLATE ||--o{ GENERATED_ROSTER : "pattern"
    DAY_MODEL ||--o{ GENERATED_ROSTER : "day model"
    SHIFT_DEF ||--o{ GENERATED_ROSTER : "shift"
    
    GENERATED_ROSTER ||--o| SCHEDULE_OVERRIDE : "overridden by"
    SHIFT_DEF ||--o{ OPEN_SHIFT_POOL : "creates open shifts"
    OPEN_SHIFT_POOL ||--o{ SHIFT_BID : "receives bids"
    
    TIME_SEGMENT {
        uuid id PK
        string code UK
        string segment_type
        int duration_minutes
        boolean is_paid
    }
    
    SHIFT_DEF {
        uuid id PK
        string code UK
        string shift_type
        time reference_start_time
        time reference_end_time
        decimal total_work_hours
        boolean cross_midnight
    }
    
    DAY_MODEL {
        uuid id PK
        string code UK
        string day_type
        uuid shift_id FK
        boolean is_half_day
    }
    
    PATTERN_TEMPLATE {
        uuid id PK
        string code UK
        int cycle_length_days
        string rotation_type
        jsonb pattern_json
    }
    
    SCHEDULE_ASSIGNMENT {
        uuid id PK
        string code UK
        uuid pattern_id FK
        uuid holiday_calendar_id FK
        date start_reference_date
        int offset_days
        uuid employee_group_id FK
    }
    
    GENERATED_ROSTER {
        uuid employee_id PK,FK
        date work_date PK
        uuid schedule_rule_id FK
        uuid pattern_id FK
        uuid day_model_id FK
        uuid shift_id FK
        boolean is_override
        string status_code
    }
```

### Scheduling Data Flow

```
Level 1: TIME_SEGMENT (atomic unit)
         ↓ compose
Level 2: SHIFT_DEF (combination of segments)
         ↓ link
Level 3: DAY_MODEL (what happens on 1 day)
         ↓ sequence
Level 4: PATTERN_TEMPLATE (repeating cycle)
         ↓ configure
Level 5: SCHEDULE_ASSIGNMENT (WHO gets WHICH pattern)
         ↓ generate
Level 6: GENERATED_ROSTER (1 row per employee per day)
```

---

## 2. Attendance ERD (Punch → Timesheet)

```mermaid
erDiagram
    EMPLOYEE ||--o{ CLOCK_EVENT : "creates"
    EMPLOYEE ||--o{ ATTENDANCE_RECORD : "has daily"
    EMPLOYEE ||--o{ TIMESHEET_HEADER : "submits"
    EMPLOYEE ||--o{ OVERTIME_REQUEST : "requests OT"
    EMPLOYEE ||--o{ COMP_TIME_BALANCE : "owns comp time"
    EMPLOYEE ||--o{ SHIFT_SWAP_REQUEST : "initiates swap"
    EMPLOYEE ||--o{ SHIFT_BID : "bids on shifts"
    
    SHIFT_DEF ||--o{ ATTENDANCE_RECORD : "assigned to"
    
    TIMESHEET_HEADER ||--o{ TIMESHEET_LINE : "contains lines"
    TIMESHEET_LINE }o--o| CLOCK_EVENT : "sourced from"
    TIMESHEET_HEADER }o--o| PERIOD : "belongs to"
    
    OVERTIME_REQUEST }o--|| EMPLOYEE : "approved by"
    
    OPEN_SHIFT_POOL ||--o{ SHIFT_BID : "receives bids"
    
    PERIOD ||--o| PAYROLL_EXPORT_PACKAGE : "exports"
    
    CLOCK_EVENT {
        uuid id PK
        uuid employee_id FK
        timestamptz event_dt
        string event_type
        string source
        string sync_status
        boolean geofence_validated
        boolean is_correction
        string idempotency_key UK
    }
    
    ATTENDANCE_RECORD {
        uuid id PK
        uuid employee_id FK
        uuid shift_id FK
        date attendance_date
        timestamptz clock_in_time
        timestamptz clock_out_time
        decimal actual_hours
        string status_code
        int late_minutes
    }
    
    TIMESHEET_HEADER {
        uuid id PK
        uuid employee_id FK
        date period_start
        date period_end
        string status_code
        decimal total_hours
        uuid period_id FK
    }
    
    TIMESHEET_LINE {
        uuid id PK
        uuid header_id FK
        date work_date
        string time_type_code
        decimal qty_hours
        uuid source_clock_id FK
    }
    
    OVERTIME_REQUEST {
        uuid id PK
        uuid worker_id FK
        date planned_date
        decimal estimated_hours
        string ot_type
        decimal ot_rate
        boolean comp_time_elected
        string status_code
        decimal monthly_ot_cap_hours
    }
    
    COMP_TIME_BALANCE {
        uuid id PK
        uuid employee_id FK
        decimal earned_hours
        decimal used_hours
        decimal available_hours
        date expiry_date
        string expiry_action
    }
```

### Attendance States

**ClockEvent Sync Status:**
```
PENDING → SYNCED
        ↘ CONFLICT (requires resolution)
```

**Timesheet Status:**
```
OPEN → SUBMITTED → APPROVED → LOCKED
                    ↓
                 REJECTED
```

**OvertimeRequest Status:**
```
PENDING → APPROVED → (Work Completed)
        ↘ REJECTED
```

---

## 3. Absence ERD (Leave Management)

```mermaid
erDiagram
    LEAVE_TYPE ||--o{ LEAVE_CLASS : "grouped by"
    LEAVE_CLASS ||--o{ CLASS_POLICY_ASSIGNMENT : "has policies"
    LEAVE_POLICY ||--o{ CLASS_POLICY_ASSIGNMENT : "assigned to classes"
    
    LEAVE_CLASS ||--o{ LEAVE_INSTANT : "has balance per employee"
    LEAVE_INSTANT ||--o{ LEAVE_INSTANT_DETAIL : "has lots"
    LEAVE_INSTANT ||--o{ LEAVE_MOVEMENT : "tracks changes"
    
    LEAVE_CLASS ||--o{ LEAVE_REQUEST : "requested under"
    LEAVE_REQUEST ||--o| LEAVE_RESERVATION : "reserves balance"
    LEAVE_RESERVATION ||--o{ LEAVE_RESERVATION_LINE : "allocates lots"
    LEAVE_RESERVATION_LINE }o--|| LEAVE_INSTANT_DETAIL : "consumes from"
    
    LEAVE_CLASS ||--o{ LEAVE_CLASS_EVENT : "triggers events"
    LEAVE_EVENT_DEF ||--o{ LEAVE_CLASS_EVENT : "defined by"
    LEAVE_EVENT_DEF ||--o{ LEAVE_EVENT_RUN : "executed in batches"
    LEAVE_CLASS ||--o{ LEAVE_EVENT_RUN : "for class"
    LEAVE_PERIOD ||--o{ LEAVE_EVENT_RUN : "in period"
    LEAVE_EVENT_RUN ||--o{ LEAVE_MOVEMENT : "creates movements"
    
    LEAVE_PERIOD ||--o{ LEAVE_PERIOD : "parent-child hierarchy"
    LEAVE_MOVEMENT }o--o| LEAVE_PERIOD : "period reference"
    
    LEAVE_INSTANT ||--o| TERMINATION_BALANCE_RECORD : "snapshot at termination"
    
    LEAVE_TYPE ||--o{ TEAM_LEAVE_LIMIT : "staffing rules"
    
    HOLIDAY_CALENDAR ||--o{ HOLIDAY_DATE : "defines dates"
    
    LEAVE_TYPE {
        string code PK
        string name
        boolean is_paid
        string entitlement_basis
        string unit_code
        boolean allows_half_day
        int cancellation_deadline_days
    }
    
    LEAVE_CLASS {
        uuid id PK
        string code UK
        string type_code FK
        string mode_code
        string unit_code
        uuid default_eligibility_profile_id FK
    }
    
    LEAVE_POLICY {
        uuid id PK
        string code UK
        string type_code FK
        string policy_type
        jsonb config_json
        date effective_start
    }
    
    LEAVE_INSTANT {
        uuid id PK
        uuid employee_id FK
        uuid class_id FK
        decimal current_qty
        decimal hold_qty
        decimal available_qty
    }
    
    LEAVE_INSTANT_DETAIL {
        uuid id PK
        uuid instant_id FK
        string lot_kind
        date eff_date
        date expire_date
        decimal lot_qty
        decimal used_qty
        int priority
    }
    
    LEAVE_MOVEMENT {
        uuid id PK
        uuid instant_id FK
        uuid class_id FK
        string event_code
        decimal qty
        string unit_code
        date effective_date
        date expire_date
        uuid request_id FK
        uuid lot_id FK
        uuid period_id FK
        string idempotency_key
    }
    
    LEAVE_REQUEST {
        uuid id PK
        uuid employee_id FK
        uuid class_id FK
        timestamp start_dt
        timestamp end_dt
        decimal total_days
        string status_code
        string reason
        uuid approved_by FK
    }
    
    LEAVE_RESERVATION {
        uuid request_id PK,FK
        uuid instant_id FK
        decimal reserved_qty
        timestamp expires_at
    }
    
    LEAVE_RESERVATION_LINE {
        uuid id PK
        uuid reservation_id FK
        uuid source_lot_id FK
        decimal reserved_amount
        date expiry_date
    }
    
    LEAVE_EVENT_DEF {
        uuid id PK
        string code UK
        string name
        string trigger_kind
        string schedule_expr
        jsonb policy_refs
    }
    
    LEAVE_EVENT_RUN {
        uuid id PK
        uuid event_def_id FK
        uuid class_id FK
        uuid period_id FK
        string run_status
        int employee_count
        int movements_created
        string idempotency_key UK
    }
    
    LEAVE_CLASS_EVENT {
        uuid class_id PK,FK
        uuid event_def_id PK,FK
        string qty_formula
        boolean idempotent
    }
    
    LEAVE_PERIOD {
        uuid id PK
        string code UK
        uuid parent_id FK
        string level_code
        date start_date
        date end_date
        string status_code
    }
    
    TEAM_LEAVE_LIMIT {
        uuid id PK
        uuid org_unit_id FK
        string leave_type_code FK
        decimal limit_pct
        int limit_abs_cnt
        int escalation_level
    }
    
    TERMINATION_BALANCE_RECORD {
        uuid id PK
        uuid employee_id FK
        date termination_date
        jsonb balance_snapshots
        string balance_action
        boolean employee_consent_obtained
    }
```

### Absence Balance Flow

```
LeaveInstant (Balance Snapshot)
    ├── current_qty = SUM(EARN movements) - SUM(USE movements)
    ├── hold_qty = SUM(RESERVE movements) - SUM(RELEASE movements)
    └── available_qty = current_qty - hold_qty

LeaveInstantDetail (FEFO Lots)
    ├── Lot A: 3 days, expires 2026-03-31, priority=50
    └── Lot B: 14 days, expires 2026-12-31, priority=100

Reservation (FEFO Consumption)
    ├── Line 1: 3 days from Lot A (earliest expiry)
    └── Line 2: 1 day from Lot B
```

### Event Processing Flow

```
LeaveEventDef (Event Type)
    └── LeaveClassEvent (Class-Event Mapping + Formula)
        └── LeaveEventRun (Batch Execution)
            └── LeaveMovement (Balance Change)
                └── LeaveInstant (Updated Balance)
```

---

## 4. Shared ERD (Period, Calendar, Mapping)

```mermaid
erDiagram
    PERIOD ||--o| PAYROLL_EXPORT_PACKAGE : "exports to payroll"
    PERIOD ||--o{ TIMESHEET_HEADER : "contains timesheets"
    
    HOLIDAY_CALENDAR ||--o{ HOLIDAY_DATE : "defines dates"
    HOLIDAY_CALENDAR ||--o{ SCHEDULE_ASSIGNMENT : "used by schedules"
    
    TIME_TYPE_ELEMENT_MAP }o--|| PAY_ELEMENT : "maps to"
    
    EMPLOYEE ||--o{ PERIOD : "locked by"
    
    PERIOD {
        uuid id PK
        string code UK
        string name
        string period_type
        date start_date
        date end_date
        string status_code
        timestamptz locked_at
        uuid locked_by FK
    }
    
    HOLIDAY_CALENDAR {
        uuid id PK
        string code UK
        string name
        string region_code
        boolean deduct_flag
    }
    
    HOLIDAY_DATE {
        uuid calendar_id PK,FK
        date holiday_date PK
        string name
        boolean is_half_day
    }
    
    TIME_TYPE_ELEMENT_MAP {
        uuid id PK
        string time_type_code
        string pay_element_code
        string rate_source_code
        decimal default_rate
        string rate_unit
    }
    
    PAYROLL_EXPORT_PACKAGE {
        uuid id PK
        uuid period_id FK
        timestamptz generated_at
        uuid generated_by FK
        int employee_count
        decimal total_regular_hours
        decimal total_ot_hours
        string checksum
        string dispatch_status
    }
```

### Period Lifecycle

```
OPEN (Active)
  ↓ All timesheets APPROVED
LOCKED (Frozen for payroll)
  ↓ Payroll export complete
CLOSED (Finalized)
```

---

## 5. Cross-Context Integration

```mermaid
erDiagram
    EMPLOYEE ||--o{ SCHEDULE_ASSIGNMENT : "assigned schedule"
    EMPLOYEE ||--o{ GENERATED_ROSTER : "has roster"
    EMPLOYEE ||--o{ CLOCK_EVENT : "creates punches"
    EMPLOYEE ||--o{ ATTENDANCE_RECORD : "daily attendance"
    EMPLOYEE ||--o{ TIMESHEET_HEADER : "submits timesheet"
    EMPLOYEE ||--o{ LEAVE_INSTANT : "owns leave balance"
    EMPLOYEE ||--o{ LEAVE_REQUEST : "requests leave"
    EMPLOYEE ||--o{ OVERTIME_REQUEST : "requests OT"
    EMPLOYEE ||--o{ COMP_TIME_BALANCE : "has comp time"
    EMPLOYEE ||--o{ TERMINATION_BALANCE_RECORD : "termination snapshot"
    
    SHIFT_DEF ||--o{ GENERATED_ROSTER : "assigned shift"
    SHIFT_DEF ||--o{ ATTENDANCE_RECORD : "attendance shift"
    SHIFT_DEF ||--o{ OVERTIME_REQUEST : "OT shift"
    
    PERIOD ||--o{ TIMESHEET_HEADER : "timesheet period"
    PERIOD ||--o{ PAYROLL_EXPORT_PACKAGE : "payroll export"
    
    HOLIDAY_CALENDAR ||--o{ SCHEDULE_ASSIGNMENT : "schedule calendar"
    HOLIDAY_CALENDAR ||--o{ HOLIDAY_DATE : "holiday dates"
    
    LEAVE_INSTANT ||--o{ LEAVE_MOVEMENT : "balance ledger"
    LEAVE_INSTANT ||--o{ LEAVE_INSTANT_DETAIL : "FEFO lots"
    LEAVE_INSTANT ||--o{ TERMINATION_BALANCE_RECORD : "termination snapshot"
    
    LEAVE_REQUEST ||--o| LEAVE_RESERVATION : "balance reservation"
    LEAVE_RESERVATION ||--o{ LEAVE_RESERVATION_LINE : "lot allocation"
```

---

## 6. Enums Reference

### Scheduling Enums

```mermaid
classDiagram
    class SegmentType {
        <<enumeration>>
        WORK
        BREAK
        MEAL
        TRANSFER
    }
    
    class ShiftType {
        <<enumeration>>
        ELAPSED
        PUNCH
        FLEX
    }
    
    class DayType {
        <<enumeration>>
        WORK
        OFF
        HOLIDAY
        HALF_DAY
    }
    
    class RotationType {
        <<enumeration>>
        FIXED
        ROTATING
    }
    
    class RosterStatus {
        <<enumeration>>
        SCHEDULED
        CONFIRMED
        COMPLETED
        CANCELLED
    }
```

### Attendance Enums

```mermaid
classDiagram
    class PunchType {
        <<enumeration>>
        IN
        OUT
    }
    
    class PunchSyncStatus {
        <<enumeration>>
        PENDING
        SYNCED
        CONFLICT
    }
    
    class TimesheetStatus {
        <<enumeration>>
        OPEN
        SUBMITTED
        APPROVED
        LOCKED
    }
    
    class OimeType {
        <<enumeration>>
        WEEKDAY
        WEEKEND
        PUBLIC_HOLIDAY
    }
    
    class CompTimeExpiryAction {
        <<enumeration>>
        EXTENSION
        CASHOUT
        FORFEITURE
    }
```

### Absence Enums

```mermaid
classDiagram
    class LeaveCategory {
        <<enumeration>>
        ANNUAL
        SICK
        MATERNITY
        PATERNITY
        UNPAID
        COMP_TIME
        CUSTOM
    }
    
    class EntitlementBasis {
        <<enumeration>>
        FIXED
        ACCRUAL
        UNLIMITED
    }
    
    class MovementType {
        <<enumeration>>
        EARN
        USE
        RESERVE
        RELEASE
        EXPIRE
        ADJUST
        CASHOUT
    }
    
    class LeaveRequestStatus {
        <<enumeration>>
        SUBMITTED
        UNDER_REVIEW
        APPROVED
        REJECTED
        CANCELLATION_PENDING
        CANCELLED
    }
    
    class ReservationStatus {
        <<enumeration>>
        ACTIVE
        RELEASED
        CONVERTED
    }
    
    class TerminationBalanceAction {
        <<enumeration>>
        AUTO_DEDUCT
        HR_REVIEW
        WRITE_OFF
        RULE_BASED
    }
```

### Shared Enums

```mermaid
classDiagram
    class PeriodStatus {
        <<enumeration>>
        OPEN
        LOCKED
        CLOSED
    }
    
    class PeriodType {
        <<enumeration>>
        MONTHLY
        CUSTOM
    }
```

---

## 7. Key Relationships Summary

| From | To | Relationship | Business Meaning |
|------|----|--------------|--------------------|
| ShiftDef | TimeSegment | 1:N (via ShiftSegment) | Shift composed of segments |
| DayModel | ShiftDef | N:1 | Day model links to shift |
| PatternTemplate | DayModel | 1:N (via PatternDay) | Pattern sequences day models |
| ScheduleAssignment | PatternTemplate | N:1 | Rule uses pattern |
| GeneratedRoster | ScheduleAssignment | N:1 | Roster generated from rule |
| ClockEvent | Employee | N:1 | Employee creates punches |
| TimesheetHeader | Period | N:1 | Timesheet belongs to period |
| LeaveRequest | LeaveClass | N:1 | Request under leave class |
| LeaveMovement | LeaveInstant | N:1 | Movement tracks balance |
| LeaveReservation | LeaveInstantDetail | N:M (via Line) | Reservation consumes lots |

---

## 8. Index Strategy

### High-Performance Queries

**ClockEvent:**
- `(employee_id, event_dt)` - Query punches by employee over time
- `(idempotency_key)` UK - Prevent duplicate syncs
- `(employee_id, sync_status)` - Query pending syncs

**GeneratedRoster:**
- `(employee_id, work_date)` UK - One roster per employee per day
- `(schedule_rule_id, work_date)` - Query by rule
- `(work_date)` - Query all rosters for a date

**LeaveMovement:**
- `(instant_id, effective_date)` - Query movements by instant over time
- `(class_id, event_code, effective_date)` - Query by event type
- `(request_id)` - Query movements for a request
- `(idempotency_key)` - Idempotent accrual

**TimesheetHeader:**
- `(employee_id, period_start)` - Query timesheet by employee
- `(period_id)` - Query all timesheets in period

---

*Next: [07-workflow-diagrams.md](./07-workflow-diagrams.md) - State Machines & Workflows*