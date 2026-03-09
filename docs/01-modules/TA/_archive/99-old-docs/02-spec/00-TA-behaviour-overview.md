# Time & Absence - Behavioural Specification Overview

> This document provides an overview of the behavioural specifications for the Time & Absence module, which consists of two integrated sub-modules: Absence Management and Time & Attendance.

---

## Document Information

- **Module**: Time & Absence (TA)
- **Version**: 1.0
- **Last Updated**: 2025-12-01
- **Author**: xTalent Documentation Team
- **Status**: Draft

---

## Module Structure

The Time & Absence module is divided into two main sub-modules, each with its own detailed behavioural specification:

### 1. Absence Management
**Document**: [01-absence-behaviour-spec.md](./01-absence-behaviour-spec.md)

**Scope**: Leave request management, balance tracking, and policy enforcement

**Key Features**:
- Leave request creation and approval workflow
- Leave balance calculation and tracking
- Flexible rule system (Eligibility, Validation, Accrual, Carryover, Limits, Overdraft, Proration, Rounding)
- Reservation system to prevent double-booking
- Immutable ledger for balance movements
- Multi-level approval workflows
- Period profile management (leave years)

**Primary Use Cases**:
- UC-ABS-001: Employee Requests Leave
- UC-ABS-002: Manager Approves/Rejects Leave
- UC-ABS-003: System Allocates Annual Leave
- UC-ABS-004: System Accrues Monthly Leave
- UC-ABS-005: System Processes Carryover
- UC-ABS-006: HR Adjusts Leave Balance
- UC-ABS-007: Employee Withdraws Leave Request
- UC-ABS-008: HR Cancels Approved Leave

### 2. Time & Attendance
**Document**: [02-time-attendance-behaviour-spec.md](./02-time-attendance-behaviour-spec.md)

**Scope**: Shift scheduling, time tracking, attendance recording, and overtime management

**Key Features**:
- Shift pattern configuration and scheduling
- Time clock integration (biometric, RFID, mobile)
- Attendance tracking with clock in/out
- Timesheet entry and approval
- Attendance exception detection and management
- Shift swap and bidding
- Overtime rules and calculation
- Grace period and time rounding

**Primary Use Cases**:
- UC-ATT-001: Employee Clocks In/Out
- UC-ATT-002: Manager Creates Schedule
- UC-ATT-003: Employee Submits Timesheet
- UC-ATT-004: Manager Reviews Attendance Exceptions
- UC-ATT-005: Employee Requests Shift Swap
- UC-ATT-006: Employee Bids for Open Shift
- UC-ATT-007: Employee Requests Overtime
- UC-ATT-008: System Calculates Overtime

---

## Shared Components

Both sub-modules share the following components:

### Working Schedule
Defines working days and hours for calculating working days in leave requests and attendance.

### Holiday Calendar
Public and company holidays that are excluded from working day calculations.

### Period Profile
Time period definitions (leave year, pay period) used by both sub-modules.

### Event System
Event-driven notifications and integrations triggered by actions in either sub-module.

### Audit Trail
Complete history tracking for all transactions and state changes.

---

## Cross-Module Integration

### Leave and Attendance Coordination

**Rule**: Approved leave creates attendance records
- When leave request is approved, system creates AttendanceRecord with status ON_LEAVE
- Prevents scheduling conflicts (cannot schedule shift during approved leave)
- Blocks clock-in during approved leave period

**Rule**: Leave requests block shift assignments
- Manager cannot assign shift to employee with approved leave
- System shows warning if attempting to schedule during pending leave

**Rule**: Attendance exceptions may trigger leave suggestions
- If employee is absent without leave, system can suggest creating leave request
- Manager can convert unauthorized absence to leave request

---

## Common Business Rules

### BR-COMMON-001: Working Day Calculation
**Category**: Calculation  
**Description**: All date-based calculations use working days, not calendar days  
**Applies To**: Leave requests, attendance records, timesheet entries  
**Logic**:
```
workingDays = 0
for each day in dateRange:
  if day is not weekend AND day is not holiday:
    workingDays += 1
```

### BR-COMMON-002: No Retroactive Changes Without Approval
**Category**: Validation  
**Description**: Changes to past dates require special approval  
**Applies To**: Leave requests, attendance corrections, timesheet edits  
**Logic**:
- If date < today: Require manager or HR approval
- If date >= today: Normal approval flow

### BR-COMMON-003: Audit All State Changes
**Category**: Audit  
**Description**: All entity state changes must be logged  
**Applies To**: All entities  
**Logic**: Capture who, when, what changed, old value, new value

### BR-COMMON-004: Manager Cannot Approve Own Requests
**Category**: Authorization  
**Description**: Employees cannot approve their own leave/overtime requests  
**Applies To**: Leave requests, overtime requests, timesheet approvals  
**Logic**:
- If approver.id == requester.id: Show error "Cannot approve own request"
- Route to next level approver or HR

---

## Common Validation Rules

### Date Validations

| Validation | Rule | Error Message |
|------------|------|---------------|
| Date Format | Must be YYYY-MM-DD | "Invalid date format" |
| Date Range | Start date <= End date | "End date must be on or after start date" |
| Future Date | Date >= today (for new requests) | "Date cannot be in the past" |
| Max Future | Date <= today + 1 year | "Date cannot be more than 1 year in future" |

### Time Validations

| Validation | Rule | Error Message |
|------------|------|---------------|
| Time Format | Must be HH:MM (24-hour) | "Invalid time format" |
| Time Range | Start time < End time (unless overnight) | "End time must be after start time" |
| Business Hours | Within configured business hours | "Time is outside business hours" |

---

## Common Calculations

### Calculation: Working Days Between Dates

**Purpose**: Calculate number of working days between two dates

**Formula**:
```
function calculateWorkingDays(startDate, endDate, schedule, holidays):
  workingDays = 0
  currentDate = startDate
  
  while currentDate <= endDate:
    dayOfWeek = getDayOfWeek(currentDate)
    
    if schedule.workingDays.includes(dayOfWeek) AND
       not holidays.includes(currentDate):
      workingDays += 1
    
    currentDate = currentDate + 1 day
  
  return workingDays
```

**Inputs**:
- startDate: First date (inclusive)
- endDate: Last date (inclusive)
- schedule: Working schedule definition
- holidays: List of holiday dates

**Output**: Number of working days

**Example**:
```
Input:
  startDate: 2025-02-03 (Monday)
  endDate: 2025-02-07 (Friday)
  schedule: Mon-Fri (5-day week)
  holidays: []

Output: 5 working days

Breakdown:
  - Feb 3 (Mon): Working day ✓
  - Feb 4 (Tue): Working day ✓
  - Feb 5 (Wed): Working day ✓
  - Feb 6 (Thu): Working day ✓
  - Feb 7 (Fri): Working day ✓
```

---

## Common State Transitions

### Generic Approval Workflow

Most entities in Time & Absence follow this approval pattern:

```
DRAFT → PENDING → APPROVED/REJECTED
                ↓
            WITHDRAWN/CANCELLED
```

**States**:
- **DRAFT**: Being composed by user
- **PENDING**: Submitted, awaiting approval
- **APPROVED**: Approved by authorized person
- **REJECTED**: Rejected by authorized person
- **WITHDRAWN**: Cancelled by requester before approval
- **CANCELLED**: Cancelled after approval (exceptional)

---

## Common Permission Matrix

| Action | Employee (Self) | Employee (Other) | Manager (Team) | HR Admin | System Admin |
|--------|----------------|------------------|----------------|----------|--------------|
| Create Request | ✅ | ❌ | ✅ | ✅ | ✅ |
| View Own Data | ✅ | ❌ | ✅ | ✅ | ✅ |
| View Others Data | ❌ | ❌ | ✅ (team only) | ✅ (all) | ✅ (all) |
| Edit Draft | ✅ | ❌ | ❌ | ✅ | ✅ |
| Delete Draft | ✅ | ❌ | ❌ | ✅ | ✅ |
| Approve Request | ❌ | ❌ | ✅ (team only) | ✅ (all) | ✅ (all) |
| Reject Request | ❌ | ❌ | ✅ (team only) | ✅ (all) | ✅ (all) |
| Adjust Balance/Time | ❌ | ❌ | ❌ | ✅ | ✅ |
| Configure Rules | ❌ | ❌ | ❌ | ✅ | ✅ |

---

## Common Error Codes

### General Errors

| Code | Message | HTTP Status |
|------|---------|-------------|
| TA_GEN_001 | "Invalid date format" | 400 |
| TA_GEN_002 | "Invalid time format" | 400 |
| TA_GEN_003 | "End date must be on or after start date" | 400 |
| TA_GEN_004 | "Date cannot be in the past" | 400 |
| TA_GEN_005 | "Unauthorized action" | 403 |
| TA_GEN_006 | "Resource not found" | 404 |
| TA_GEN_007 | "Duplicate entry" | 409 |
| TA_GEN_008 | "System error" | 500 |

### Absence-Specific Errors

See [01-absence-behaviour-spec.md](./01-absence-behaviour-spec.md#error-handling)

### Time & Attendance-Specific Errors

See [02-time-attendance-behaviour-spec.md](./02-time-attendance-behaviour-spec.md#error-handling)

---

## Performance Requirements

### Response Time Targets

| Operation Type | Target | Maximum |
|----------------|--------|---------|
| Simple Query (view balance, view schedule) | < 200ms | 500ms |
| Create Request (leave, overtime) | < 500ms | 1s |
| Approval Action | < 300ms | 500ms |
| Calculation (balance, overtime) | < 1s | 2s |
| Report Generation (simple) | < 5s | 10s |
| Report Generation (complex) | < 30s | 60s |

### Throughput Targets

| Metric | Normal Load | Peak Load |
|--------|-------------|-----------|
| Concurrent Users | 100 | 500 |
| Requests per Second | 50 | 200 |
| Clock-in Events per Minute | 100 | 500 |
| Leave Requests per Hour | 50 | 200 |

---

## Audit Requirements

### Events to Audit

All sub-modules must audit:

1. **Entity Creation**: Who, when, initial values
2. **State Changes**: Who, when, from state, to state
3. **Field Updates**: Who, when, field name, old value, new value
4. **Deletions**: Who, when, what was deleted
5. **Approvals**: Who, when, decision, comments
6. **Access**: Who, when, what was viewed (for sensitive data)

### Audit Log Retention

- **Active Records**: Indefinite
- **Archived Records**: 7 years (compliance requirement)
- **Access Logs**: 1 year

---

## Integration Points

### Core HR (CO)
- **Direction**: Inbound
- **Data**: Worker, Assignment, OrgUnit, Position
- **Timing**: Real-time for lookups, nightly sync for updates
- **Purpose**: Employee and organizational data

### Payroll (PR)
- **Direction**: Outbound
- **Data**: Leave days, attendance hours, overtime hours
- **Timing**: At payroll period close
- **Purpose**: Payroll calculation

### Total Rewards (TR)
- **Direction**: Outbound
- **Data**: Overtime hours, shift differentials
- **Timing**: Real-time
- **Purpose**: Compensation calculation

### Calendar Systems (External)
- **Direction**: Outbound
- **Data**: Approved leave, scheduled shifts
- **Timing**: Real-time
- **Purpose**: Calendar synchronization

### Time Clock Devices (External)
- **Direction**: Inbound
- **Data**: Clock-in/out events
- **Timing**: Real-time
- **Purpose**: Attendance tracking

---

## Testing Strategy

### Test Coverage Requirements

- **Unit Tests**: 80% code coverage minimum
- **Integration Tests**: All integration points
- **End-to-End Tests**: All critical user journeys
- **Performance Tests**: All operations under load
- **Security Tests**: All permission checks

### Test Data Requirements

Test data must include:
- Multiple employee types (full-time, part-time, contractor)
- Multiple leave types (paid, unpaid, statutory)
- Multiple shift patterns (day, night, rotating)
- Edge cases (leap years, DST changes, etc.)
- Error scenarios (insufficient balance, overlapping dates, etc.)

---

## Acceptance Criteria

The Time & Absence module is considered complete when:

**Absence Management**:
- [ ] All leave request workflows function correctly
- [ ] Balance calculations are accurate
- [ ] All rule types are enforced
- [ ] Carryover processing works correctly
- [ ] Multi-level approvals work

**Time & Attendance**:
- [ ] Clock-in/out records accurately
- [ ] Shift scheduling prevents conflicts
- [ ] Attendance exceptions are detected
- [ ] Overtime is calculated correctly
- [ ] Shift swaps work end-to-end

**Shared**:
- [ ] Working day calculations are accurate
- [ ] Holiday calendar integration works
- [ ] Audit logging is complete
- [ ] Permissions are enforced correctly
- [ ] Performance targets are met
- [ ] All integrations work correctly

---

## Related Documents

- [Concept Overview](../01-concept/01-concept-overview.md) - What and why
- [Conceptual Guide](../01-concept/02-conceptual-guide.md) - How it works
- [Absence Ontology](../00-ontology/absence-ontology.yaml) - Absence domain model
- [Time & Attendance Ontology](../00-ontology/time-attendance-ontology.yaml) - T&A domain model
- [Module Summary](../00-ontology/TA-MODULE-SUMMARY.yaml) - Complete overview
- [Absence Behaviour Spec](./01-absence-behaviour-spec.md) - Detailed absence spec
- [Time & Attendance Behaviour Spec](./02-time-attendance-behaviour-spec.md) - Detailed T&A spec

---

## Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-01 | xTalent Documentation Team | Initial version |

---

**Approval**

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Business Analyst | | | |
| Tech Lead | | | |
| Product Owner | | | |
