# Data Examples - Complete Scenarios

**Purpose:** End-to-end data scenarios với realistic sample data  
**Last Updated:** 2026-04-01

---

## Scenario Overview

| # | Scenario | Bounded Contexts | Purpose |
|---|----------|-----------------|---------|
| 1 | New Employee Onboarding | All | Setup employee với schedule, leave balance |
| 2 | Daily Punch → Timesheet | Attendance | Punch flow, OT detection, timesheet |
| 3 | Leave Request (3 Days) | Absence | Request, FEFO reservation, approval, balance |
| 4 | Overtime with Comp Time | Attendance | OT request, approval, comp time accrual |
| 5 | Monthly Accrual Batch | Absence | Batch processing, movements, balance update |
| 6 | 24/7 Roster Generation | Scheduling | 3-shift rotation, crew assignments |
| 7 | Period Close & Payroll Export | Shared | Period lifecycle, export package |
| 8 | Employee Termination | Absence | Balance snapshot, disposition, payroll |

---

## Scenario 1: New Employee Onboarding

### Context
Nguyen Van A joins VNG Corp as Software Engineer on 2026-04-01.

### Prerequisites - Configuration Data

**Leave Type (ANNUAL):**
```json
{
  "code": "ANNUAL",
  "name": "Nghỉ phép năm",
  "is_paid": true,
  "is_quota_based": true,
  "unit_code": "DAY",
  "allows_half_day": true,
  "cancellation_deadline_days": 1,
  "country_code": "VN"
}
```

**Leave Class (Annual Standard):**
```json
{
  "id": "LC-ANNUAL-STD",
  "type_code": "ANNUAL",
  "code": "ANNUAL_STANDARD",
  "name": "Annual Leave - Standard",
  "mode_code": "ACCOUNT",
  "unit_code": "DAY",
  "default_eligibility_profile_id": "ELIG-ALL"
}
```

**Leave Policy (Monthly Accrual):**
```json
{
  "id": "LP-ACCRUAL-14D",
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

**Seniority Policy (VLC Art. 113):**
```json
{
  "id": "LP-SENIORITY",
  "code": "SENIORITY_VLC113",
  "policy_type": "SENIORITY",
  "config_json": {
    "tiers": [
      {"min_years": 0, "max_years": 5, "entitlement_days": 14},
      {"min_years": 5, "max_years": 10, "entitlement_days": 15}
    ]
  }
}
```

**Shift Definition (Day Shift):**
```json
{
  "id": "SHIFT-DAY-8H",
  "code": "DAY_SHIFT_8H",
  "name": "Day Shift 8 Hours",
  "shift_type": "ELAPSED",
  "reference_start_time": "08:00:00",
  "reference_end_time": "17:00:00",
  "total_work_hours": 8.00,
  "cross_midnight": false
}
```

**Pattern Template (5x8):**
```json
{
  "id": "PATTERN-5X8",
  "code": "5X8_STANDARD",
  "name": "5x8 Standard Week",
  "cycle_length_days": 7,
  "rotation_type": "FIXED"
}
```

**Schedule Assignment:**
```json
{
  "id": "SCHED-ENGINEERING",
  "code": "ENGINEERING_TEAM",
  "name": "Engineering Team Schedule",
  "pattern_id": "PATTERN-5X8",
  "holiday_calendar_id": "CAL-VN-2026",
  "start_reference_date": "2025-01-01",
  "offset_days": 0,
  "employee_group_id": "TEAM-ENGINEERING",
  "effective_start": "2025-01-01"
}
```

### Employee Data Created

**Employee:**
```json
{
  "id": "EMP-NVA-001",
  "employee_code": "NVAN001",
  "worker_id": "W-NVA-001",
  "legal_entity_id": "LE-VNG",
  "status_code": "ACTIVE",
  "hire_date": "2026-04-01",
  "termination_date": null
}
```

**Leave Instant (Initial):**
```json
{
  "id": "LI-NVA-ANNUAL",
  "employee_id": "EMP-NVA-001",
  "class_id": "LC-ANNUAL-STD",
  "state_code": "ACTIVE",
  "current_qty": 0.00,
  "hold_qty": 0.00,
  "available_qty": 0.00,
  "limit_yearly": 14.00,
  "used_ytd": 0.00
}
```

**Generated Roster (First Week):**
```json
[
  {
    "employee_id": "EMP-NVA-001",
    "work_date": "2026-04-01",
    "schedule_rule_id": "SCHED-ENGINEERING",
    "shift_id": "SHIFT-DAY-8H",
    "status_code": "SCHEDULED"
  },
  {
    "employee_id": "EMP-NVA-001",
    "work_date": "2026-04-02",
    "schedule_rule_id": "SCHED-ENGINEERING",
    "shift_id": "SHIFT-DAY-8H",
    "status_code": "SCHEDULED"
  }
]
```

---

## Scenario 2: Daily Punch → Timesheet

### Context
Employee NVAN001 works on 2026-04-07, clocks in at 08:02, clocks out at 18:05.

### Step 1: Clock In Event

**Clock Event (IN):**
```json
{
  "id": "CE-IN-20260407",
  "employee_id": "EMP-NVA-001",
  "event_dt": "2026-04-07T01:02:00Z",
  "event_type": "IN",
  "source": "MOBILE",
  "device_id": "iphone-nvan001",
  "geo_lat": 10.7769,
  "geo_long": 106.7009,
  "sync_status": "SYNCED",
  "geofence_validated": true,
  "is_correction": false,
  "idempotency_key": "nvan001-20260407-in-mobile"
}
```

### Step 2: Clock Out Event

**Clock Event (OUT):**
```json
{
  "id": "CE-OUT-20260407",
  "employee_id": "EMP-NVA-001",
  "event_dt": "2026-04-07T11:05:00Z",
  "event_type": "OUT",
  "source": "MOBILE",
  "sync_status": "SYNCED",
  "is_correction": false,
  "idempotency_key": "nvan001-20260407-out-mobile"
}
```

### Step 3: Attendance Record Created

**Calculated:**
- Raw duration: 18:05 - 08:02 = 10h 03min = 603 min
- Break deduction: -60 min (lunch)
- Worked minutes: 543 min = 9.05 hours
- Scheduled: 8 hours
- Overtime: 9.05 - 8 = 1.05 hours
- Late: 2 min (within grace)

**Attendance Record:**
```json
{
  "id": "AR-20260407-NVA",
  "employee_id": "EMP-NVA-001",
  "shift_id": "SHIFT-DAY-8H",
  "attendance_date": "2026-04-07",
  "clock_in_time": "2026-04-07T01:02:00Z",
  "clock_out_time": "2026-04-07T11:05:00Z",
  "scheduled_start_time": "01:00:00",
  "scheduled_end_time": "10:00:00",
  "actual_hours": 9.05,
  "scheduled_hours": 8.00,
  "status_code": "PRESENT",
  "late_minutes": 0,
  "early_departure_minutes": 0,
  "is_approved": true
}
```

### Step 4: Timesheet Line Populated

**Timesheet Line (Regular Hours):**
```json
{
  "id": "TL-20260407-NVA-REG",
  "header_id": "TS-202604-NVA",
  "work_date": "2026-04-07",
  "time_type_code": "REG",
  "qty_hours": 8.00,
  "source_clock_id": "CE-IN-20260407",
  "cost_center_code": "CC-ENGINEERING"
}
```

**Timesheet Line (Overtime):**
```json
{
  "id": "TL-20260407-NVA-OT",
  "header_id": "TS-202604-NVA",
  "work_date": "2026-04-07",
  "time_type_code": "OT1.5",
  "qty_hours": 1.05,
  "source_clock_id": "CE-IN-20260407"
}
```

### Step 5: Timesheet Header

**Timesheet Header:**
```json
{
  "id": "TS-202604-NVA",
  "employee_id": "EMP-NVA-001",
  "period_start": "2026-04-01",
  "period_end": "2026-04-30",
  "status_code": "OPEN",
  "total_hours": 176.00,
  "period_id": "PERIOD-202604"
}
```

---

## Scenario 3: Leave Request (3 Days)

### Context
Employee NVAN001 requests 3 days Annual Leave from 2026-04-20 to 2026-04-22.

### Prerequisites - Balance State

**Leave Instant (Before Request):**
```json
{
  "id": "LI-NVA-ANNUAL",
  "employee_id": "EMP-NVA-001",
  "current_qty": 8.00,
  "hold_qty": 0.00,
  "available_qty": 8.00
}
```

**Leave Instant Detail (Lots - FEFO):**
```json
[
  {
    "id": "LID-LOT-A",
    "instant_id": "LI-NVA-ANNUAL",
    "lot_kind": "CARRY",
    "eff_date": "2026-01-01",
    "expire_date": "2026-03-31",
    "lot_qty": 3.00,
    "used_qty": 3.00,
    "priority": 50
  },
  {
    "id": "LID-LOT-B",
    "instant_id": "LI-NVA-ANNUAL",
    "lot_kind": "GRANT",
    "eff_date": "2026-01-01",
    "expire_date": "2026-12-31",
    "lot_qty": 8.00,
    "used_qty": 0.00,
    "priority": 100
  }
]
```

### Step 1: Leave Request Submitted

**Leave Request:**
```json
{
  "id": "LR-202604-NVA-001",
  "employee_id": "EMP-NVA-001",
  "class_id": "LC-ANNUAL-STD",
  "start_dt": "2026-04-20T00:00:00Z",
  "end_dt": "2026-04-22T23:59:59Z",
  "total_days": 3.00,
  "is_half_day": false,
  "status_code": "SUBMITTED",
  "reason": "Family vacation",
  "submitted_at": "2026-04-15T10:00:00Z"
}
```

### Step 2: Reservation Created (FEFO)

**Leave Reservation:**
```json
{
  "request_id": "LR-202604-NVA-001",
  "instant_id": "LI-NVA-ANNUAL",
  "reserved_qty": 3.00,
  "expires_at": null,
  "created_at": "2026-04-15T10:00:00Z"
}
```

**Leave Reservation Line (FEFO - All from Lot B):**
```json
{
  "id": "LRL-001",
  "reservation_id": "LR-202604-NVA-001",
  "source_lot_id": "LID-LOT-B",
  "reserved_amount": 3.00,
  "expiry_date": "2026-12-31"
}
```

### Step 3: Balance Updated

**Leave Instant (After Reservation):**
```json
{
  "current_qty": 8.00,
  "hold_qty": 3.00,
  "available_qty": 5.00
}
```

**Leave Movement (RESERVE):**
```json
{
  "id": "LM-RESERVE-001",
  "instant_id": "LI-NVA-ANNUAL",
  "class_id": "LC-ANNUAL-STD",
  "event_code": "REQUEST_RESERVE",
  "qty": -3.00,
  "unit_code": "DAY",
  "request_id": "LR-202604-NVA-001",
  "effective_date": "2026-04-15"
}
```

### Step 4: Request Approved

**Leave Request (Approved):**
```json
{
  "status_code": "APPROVED",
  "approved_by": "MGR-LEADER",
  "approved_at": "2026-04-15T14:00:00Z"
}
```

### Step 5: On Leave Start Date (2026-04-20)

**Leave Movement (USE):**
```json
{
  "id": "LM-USE-001",
  "instant_id": "LI-NVA-ANNUAL",
  "class_id": "LC-ANNUAL-STD",
  "event_code": "LEAVE_TAKEN",
  "qty": -3.00,
  "unit_code": "DAY",
  "request_id": "LR-202604-NVA-001",
  "effective_date": "2026-04-20",
  "lot_id": "LID-LOT-B"
}
```

**Leave Instant Detail (Updated):**
```json
{
  "id": "LID-LOT-B",
  "lot_qty": 8.00,
  "used_qty": 3.00
}
```

**Leave Instant (Final):**
```json
{
  "current_qty": 5.00,
  "hold_qty": 0.00,
  "available_qty": 5.00
}
```

---

## Scenario 4: Overtime with Comp Time

### Context
Employee NVAN001 works OT on Saturday 2026-04-12 (4 hours), elects comp time instead of pay.

### Step 1: Overtime Request Submitted

**Overtime Request:**
```json
{
  "id": "OT-202604-NVA-001",
  "worker_id": "EMP-NVA-001",
  "request_date": "2026-04-10T15:00:00Z",
  "planned_date": "2026-04-12",
  "estimated_hours": 4.00,
  "reason": "Project deadline - system deployment",
  "project_id": "PROJ-XTALENT",
  "ot_type": "WEEKEND",
  "ot_rate": 2.00,
  "comp_time_elected": true,
  "daily_ot_cap_hours": 4.00,
  "monthly_ot_cap_hours": 40.00,
  "status_code": "PENDING"
}
```

### Step 2: Approval with Cap Check

**Current OT Hours:**
- Monthly (April): 8 hours approved
- New request: 4 hours
- Total: 12 hours < 40 hours cap ✓

**Overtime Request (Approved):**
```json
{
  "status_code": "APPROVED",
  "approved_by": "MGR-LEADER",
  "approved_at": "2026-04-10T16:00:00Z"
}
```

### Step 3: Work Completed

**Overtime Request (Actual Hours):**
```json
{
  "actual_hours": 4.50
}
```

### Step 4: Comp Time Balance Updated

**Comp Time Balance:**
```json
{
  "id": "CTB-NVA",
  "employee_id": "EMP-NVA-001",
  "earned_hours": 9.00,
  "used_hours": 0.00,
  "available_hours": 9.00,
  "expiry_date": "2026-07-12",
  "expiry_action": "CASHOUT"
}
```

**Note:** 4.5 hours OT × 2.0 rate = 9 hours comp time

---

## Scenario 5: Monthly Accrual Batch

### Context
End of April 2026 - monthly accrual batch runs for all employees with Annual Leave.

### Step 1: Accrual Run Started

**Leave Accrual Run:**
```json
{
  "id": "LAR-202604",
  "tenant_id": "TENANT-VNG",
  "plan_policy_id": "LP-ACCRUAL-14D",
  "period_start": "2026-04-01",
  "period_end": "2026-04-30",
  "status_code": "RUNNING",
  "employee_count": 0,
  "movements_created": 0,
  "started_at": "2026-04-30T23:00:00Z"
}
```

### Step 2: For Employee NVAN001

**Calculation:**
- Base entitlement: 14 days/year
- Monthly pro-rata: 14 / 12 = 1.167 days/month
- Tenure: 0 years (< 5 years) → Tier 1: 14 days/year

**Leave Movement (EARN):**
```json
{
  "id": "LM-EARN-202604-NVA",
  "instant_id": "LI-NVA-ANNUAL",
  "class_id": "LC-ANNUAL-STD",
  "event_code": "ACCRUAL_MONTHLY",
  "qty": 1.17,
  "unit_code": "DAY",
  "period_id": "PERIOD-202604",
  "effective_date": "2026-04-30",
  "expire_date": "2026-12-31",
  "run_id": "LAR-202604",
  "idempotency_key": "ACC-NVA-202604"
}
```

**Leave Instant Detail (New Lot):**
```json
{
  "id": "LID-LOT-APR",
  "instant_id": "LI-NVA-ANNUAL",
  "lot_kind": "GRANT",
  "eff_date": "2026-04-30",
  "expire_date": "2026-12-31",
  "lot_qty": 1.17,
  "used_qty": 0.00,
  "priority": 100,
  "tag": "ACCRUAL_202604"
}
```

**Leave Instant (Updated):**
```json
{
  "current_qty": 6.17,
  "hold_qty": 0.00,
  "available_qty": 6.17
}
```

### Step 3: Batch Complete

**Leave Accrual Run (Completed):**
```json
{
  "status_code": "COMPLETED",
  "employee_count": 500,
  "movements_created": 500,
  "completed_at": "2026-04-30T23:05:00Z"
}
```

---

## Scenario 6: 24/7 Roster Generation

### Context
Production floor with 3 crews (A, B, C) working 24/7 rotating shifts.

### Configuration

**Shifts:**
```json
[
  {
    "id": "SHIFT-DAY",
    "code": "DAY_SHIFT",
    "name": "Day Shift",
    "reference_start_time": "08:00:00",
    "reference_end_time": "16:00:00"
  },
  {
    "id": "SHIFT-EVENING",
    "code": "EVENING_SHIFT",
    "name": "Evening Shift",
    "reference_start_time": "16:00:00",
    "reference_end_time": "00:00:00",
    "cross_midnight": true
  },
  {
    "id": "SHIFT-NIGHT",
    "code": "NIGHT_SHIFT",
    "name": "Night Shift",
    "reference_start_time": "00:00:00",
    "reference_end_time": "08:00:00"
  }
]
```

**Pattern (21-day cycle):**
```json
{
  "id": "PATTERN-3SHIFT",
  "code": "3SHIFT_ROTATION",
  "cycle_length_days": 21,
  "rotation_type": "ROTATING",
  "pattern_json": {
    "days": [
      // Days 1-7: Day Shift
      {"day_number": 1, "day_model_id": "DM-DAY"},
      {"day_number": 7, "day_model_id": "DM-DAY"},
      // Days 8-14: Off
      {"day_number": 8, "day_model_id": "DM-OFF"},
      {"day_number": 14, "day_model_id": "DM-OFF"},
      // Days 15-21: Evening Shift
      {"day_number": 15, "day_model_id": "DM-EVENING"},
      {"day_number": 21, "day_model_id": "DM-EVENING"}
    ]
  }
}
```

**Schedule Assignments (Crews with different offsets):**
```json
[
  {
    "id": "SCHED-CREW-A",
    "pattern_id": "PATTERN-3SHIFT",
    "offset_days": 0,
    "employee_group_id": "CREW-A"
  },
  {
    "id": "SCHED-CREW-B",
    "pattern_id": "PATTERN-3SHIFT",
    "offset_days": 7,
    "employee_group_id": "CREW-B"
  },
  {
    "id": "SCHED-CREW-C",
    "pattern_id": "PATTERN-3SHIFT",
    "offset_days": 14,
    "employee_group_id": "CREW-C"
  }
]
```

### Generated Roster (Week 1 - 2026-04-06 to 2026-04-12)

**Crew A (offset=0):**
```json
[
  {"work_date": "2026-04-06", "shift_id": "SHIFT-DAY"},
  {"work_date": "2026-04-07", "shift_id": "SHIFT-DAY"},
  {"work_date": "2026-04-08", "shift_id": "SHIFT-DAY"},
  {"work_date": "2026-04-09", "shift_id": "SHIFT-DAY"},
  {"work_date": "2026-04-10", "shift_id": "SHIFT-DAY"},
  {"work_date": "2026-04-11", "shift_id": "SHIFT-DAY"},
  {"work_date": "2026-04-12", "shift_id": "SHIFT-DAY"}
]
```

**Crew B (offset=7):**
```json
[
  {"work_date": "2026-04-06", "shift_id": null, "status_code": "OFF"},
  {"work_date": "2026-04-07", "shift_id": null, "status_code": "OFF"},
  {"work_date": "2026-04-08", "shift_id": null, "status_code": "OFF"},
  {"work_date": "2026-04-09", "shift_id": null, "status_code": "OFF"},
  {"work_date": "2026-04-10", "shift_id": null, "status_code": "OFF"},
  {"work_date": "2026-04-11", "shift_id": null, "status_code": "OFF"},
  {"work_date": "2026-04-12", "shift_id": null, "status_code": "OFF"}
]
```

**Crew C (offset=14):**
```json
[
  {"work_date": "2026-04-06", "shift_id": "SHIFT-EVENING"},
  {"work_date": "2026-04-07", "shift_id": "SHIFT-EVENING"},
  {"work_date": "2026-04-08", "shift_id": "SHIFT-EVENING"},
  {"work_date": "2026-04-09", "shift_id": "SHIFT-EVENING"},
  {"work_date": "2026-04-10", "shift_id": "SHIFT-EVENING"},
  {"work_date": "2026-04-11", "shift_id": "SHIFT-EVENING"},
  {"work_date": "2026-04-12", "shift_id": "SHIFT-EVENING"}
]
```

### Rotation Result

```
Week 1: Crew A=Day, Crew B=Off, Crew C=Evening
Week 2: Crew A=Off, Crew B=Evening, Crew C=Night (from pattern day 15 with offset 14)
Week 3: Crew A=Evening, Crew B=Night, Crew C=Day
Week 4: Return to Week 1 (21-day cycle)
```

---

## Scenario 7: Period Close & Payroll Export

### Context
April 2026 period close - all timesheets approved, ready for payroll export.

### Step 1: Pre-Close Validation

**Validation Checks:**
- ✅ All timesheets APPROVED
- ✅ No pending leave requests in period
- ✅ No unresolved attendance exceptions

### Step 2: Period Locked

**Period (Locked):**
```json
{
  "id": "PERIOD-202604",
  "code": "2026-04",
  "name": "April 2026",
  "status_code": "LOCKED",
  "locked_at": "2026-05-01T00:00:00Z",
  "locked_by": "HR-PAYROLL-ADMIN"
}
```

### Step 3: Payroll Export Generated

**Payroll Export Package:**
```json
{
  "id": "PEP-202604",
  "period_id": "PERIOD-202604",
  "generated_at": "2026-05-01T02:00:00Z",
  "generated_by": "HR-PAYROLL-ADMIN",
  "employee_count": 500,
  "total_regular_hours": 88000.00,
  "total_ot_hours": 1250.00,
  "total_leave_days": 480.00,
  "total_comp_time_hours": 95.00,
  "export_format": "JSON",
  "checksum": "a1b2c3d4e5f6...",
  "dispatch_status": "PENDING"
}
```

### Step 4: Dispatched to Payroll

**Payroll Export Package (Dispatched):**
```json
{
  "dispatch_status": "DISPATCHED",
  "dispatched_at": "2026-05-01T02:05:00Z",
  "payroll_system_ref": null
}
```

### Step 5: Acknowledged by Payroll

**Payroll Export Package (Acknowledged):**
```json
{
  "dispatch_status": "ACKNOWLEDGED",
  "payroll_system_ref": "PAYROLL-202604-001"
}
```

### Step 6: Period Closed

**Period (Closed):**
```json
{
  "status_code": "CLOSED"
}
```

---

## Scenario 8: Employee Termination

### Context
Employee NVAN001 resigns, last working day 2026-06-30. Has 5 days unused annual leave.

### Step 1: Termination Event

**Employee (Terminated):**
```json
{
  "id": "EMP-NVA-001",
  "status_code": "TERMINATED",
  "termination_date": "2026-06-30"
}
```

### Step 2: Balance Snapshot

**Leave Instant (Final):**
```json
{
  "current_qty": 5.00,
  "hold_qty": 0.00,
  "available_qty": 5.00
}
```

### Step 3: Termination Balance Record

**Termination Balance Record:**
```json
{
  "id": "TBR-NVA-001",
  "employee_id": "EMP-NVA-001",
  "termination_date": "2026-06-30",
  "balance_snapshots": [
    {
      "leave_type_code": "ANNUAL",
      "earned": 8.17,
      "used": 3.00,
      "reserved": 0.00,
      "available": 5.17
    },
    {
      "leave_type_code": "SICK",
      "earned": 30.00,
      "used": 0.00,
      "reserved": 0.00,
      "available": 30.00
    }
  ],
  "balance_action": "HR_REVIEW",
  "employee_consent_obtained": false,
  "hr_reviewer_id": null,
  "hr_review_notes": null
}
```

### Step 4: HR Review & Decision

**HR Review:**
- Positive balance: 5.17 days annual leave
- Action: Encashment to final payroll

**Termination Balance Record (Reviewed):**
```json
{
  "balance_action": "WRITE_OFF",
  "hr_reviewer_id": "HR-ADMIN",
  "hr_review_notes": "5.17 days unused annual leave. Encash to final payroll per company policy.",
  "reviewed_at": "2026-07-02T10:00:00Z",
  "payroll_deduction_amount": 0.00
}
```

### Step 5: Leave Movement (Final)

**Leave Movement (WRITE_OFF / ENCASHMENT):**
```json
{
  "id": "LM-TERM-NVA",
  "instant_id": "LI-NVA-ANNUAL",
  "class_id": "LC-ANNUAL-STD",
  "event_code": "TERMINATION_ENCASH",
  "qty": -5.17,
  "unit_code": "DAY",
  "effective_date": "2026-06-30"
}
```

**Leave Instant (Final - Zeroed):**
```json
{
  "current_qty": 0.00,
  "hold_qty": 0.00,
  "available_qty": 0.00,
  "state_code": "TERMINATED"
}
```

---

## Summary: Data Entities by Scenario

| Scenario | Key Entities | Purpose |
|----------|-------------|---------|
| **Onboarding** | Employee, LeaveInstant, ScheduleAssignment, GeneratedRoster | Initial setup |
| **Punch → Timesheet** | ClockEvent, AttendanceRecord, TimesheetHeader, TimesheetLine | Daily attendance |
| **Leave Request** | LeaveRequest, LeaveReservation, LeaveMovement, LeaveInstant | Absence workflow |
| **Overtime** | OvertimeRequest, CompTimeBalance | OT & comp time |
| **Accrual** | LeaveAccrualRun, LeaveMovement, LeaveInstantDetail | Batch processing |
| **Roster Generation** | TimeSegment, ShiftDef, PatternTemplate, ScheduleAssignment, GeneratedRoster | Scheduling |
| **Period Close** | Period, PayrollExportPackage | Payroll integration |
| **Termination** | TerminationBalanceRecord, LeaveMovement | Exit processing |

---

*End of Documentation Series*