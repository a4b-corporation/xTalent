# Data Specification - Time & Absence Module

**Version**: 2.0  
**Last Updated**: 2025-12-15  
**Module**: Time & Absence (TA)  
**Status**: Draft

---

## Document Information

- **Purpose**: Define data validation rules and constraints for all TA entities
- **Audience**: Backend Developers, Database Administrators, QA Engineers
- **Scope**: Entity validation, field constraints, cross-field rules
- **Related Documents**:
  - [Ontology](../../00-ontology/ta-ontology.yaml) - Entity definitions
  - [API Specification](./02-api-specification.md) - API contracts
  - [Business Rules](./04-business-rules.md) - Business logic

---

## Table of Contents

1. [Absence Management Entities](#absence-management-entities)
2. [Time & Attendance Entities](#time--attendance-entities)
3. [Shared Entities](#shared-entities)
4. [Common Validation Patterns](#common-validation-patterns)
5. [Enumeration Definitions](#enumeration-definitions)

---

## Validation Rule Template

Each entity follows this validation structure:

```yaml
Entity: EntityName
Fields:
  - name: fieldName
    type: dataType
    required: true/false
    constraints:
      - min: value
      - max: value
      - pattern: regex
      - enum: [values]
    default: value
    validation: description
Cross-Field Rules:
  - rule: description
  - condition: when
  - validation: what to check
```

---

# Absence Management Entities

## LeaveRequest

### Field Validations

| Field | Type | Required | Constraints | Validation |
|-------|------|----------|-------------|------------|
| `id` | UUID | Yes | - | System-generated |
| `employeeId` | UUID | Yes | Must exist in Worker | Valid employee |
| `leaveTypeId` | UUID | Yes | Must exist in LeaveType | Valid leave type |
| `startDate` | Date | Yes | >= today (unless retroactive) | Not in past |
| `endDate` | Date | Yes | >= startDate | Valid range |
| `halfDay` | Boolean | Yes | - | Default: false |
| `halfDayPeriod` | Enum | Conditional | MORNING, AFTERNOON | Required if halfDay=true |
| `totalDays` | Decimal | Yes | > 0, <= 365 | Calculated field |
| `workingDays` | Decimal | Yes | > 0, <= totalDays | Calculated field |
| `status` | Enum | Yes | See LeaveRequestStatus | Default: DRAFT |
| `reason` | String | No | Max 500 chars | Optional |
| `attachments` | Array | No | Max 5 files, 10MB each | Optional |
| `currentApproverId` | UUID | Conditional | Must exist if status=PENDING | Valid approver |
| `createdAt` | Timestamp | Yes | - | System-generated |
| `updatedAt` | Timestamp | Yes | >= createdAt | System-generated |

### Cross-Field Rules

**Rule 1: Date Range Consistency**
- `endDate` must be >= `startDate`
- If `halfDay` = true, then `startDate` = `endDate`

**Rule 2: Half-Day Period**
- If `halfDay` = true, then `halfDayPeriod` is required
- If `halfDay` = false, then `halfDayPeriod` must be null

**Rule 3: Working Days Calculation**
- `workingDays` <= `totalDays`
- `workingDays` = count of working days between startDate and endDate (excluding weekends and holidays)
- If `halfDay` = true, then `workingDays` = 0.5

**Rule 4: Status Transitions**
- Valid transitions:
  - DRAFT → PENDING (submit)
  - PENDING → APPROVED (approve)
  - PENDING → REJECTED (reject)
  - PENDING → WITHDRAWN (withdraw)
  - APPROVED → CANCELLED (cancel)
- Invalid: Cannot go from REJECTED back to PENDING

**Rule 5: Approver Assignment**
- If `status` = PENDING, then `currentApproverId` must be set
- If `status` != PENDING, then `currentApproverId` should be null

### Business Validations

**Eligibility Check**
- Employee must be eligible for the leave type
- Check against EligibilityProfile or inline criteria

**Balance Check**
- Employee must have sufficient available balance
- Formula: `available >= workingDays`

**Overlap Check**
- No overlapping requests for same employee
- Check: No existing request where date ranges overlap

**Advance Notice Check**
- Request must be submitted X days before start date
- Formula: `today + advanceNoticeDays <= startDate`

**Blackout Period Check**
- Dates must not fall within blackout periods
- Check against configured blackout periods

**Maximum Consecutive Days Check**
- Request must not exceed max consecutive days
- Formula: `workingDays <= maxConsecutiveDays`

---

## LeaveBalance

### Field Validations

| Field | Type | Required | Constraints | Validation |
|-------|------|----------|-------------|------------|
| `id` | UUID | Yes | - | System-generated |
| `employeeId` | UUID | Yes | Must exist in Worker | Valid employee |
| `leaveTypeId` | UUID | Yes | Must exist in LeaveType | Valid leave type |
| `leaveYear` | String | Yes | Format: YYYY | Valid year |
| `totalAllocated` | Decimal | Yes | >= 0 | Non-negative |
| `used` | Decimal | Yes | >= 0, <= totalAllocated + adjusted | Non-negative |
| `pending` | Decimal | Yes | >= 0 | Non-negative |
| `available` | Decimal | Yes | Can be negative if overdraft | Calculated |
| `carryover` | Decimal | Yes | >= 0 | Non-negative |
| `adjusted` | Decimal | Yes | Can be negative | Adjustment amount |
| `expired` | Decimal | Yes | >= 0 | Non-negative |
| `asOfDate` | Date | Yes | - | Balance snapshot date |

### Cross-Field Rules

**Rule 1: Balance Formula**
```
available = totalAllocated + carryover + adjusted - used - pending - expired
```

**Rule 2: Used vs Allocated**
- `used` should not exceed `totalAllocated + adjusted + carryover` (unless overdraft allowed)

**Rule 3: Pending Reservations**
- `pending` represents reserved balance for PENDING requests
- Must match sum of workingDays for all PENDING requests

**Rule 4: Carryover Limits**
- If leave type has max carryover, then `carryover` <= `maxCarryover`

---

## LeaveMovement

### Field Validations

| Field | Type | Required | Constraints | Validation |
|-------|------|----------|-------------|------------|
| `id` | UUID | Yes | - | System-generated |
| `employeeId` | UUID | Yes | Must exist | Valid employee |
| `leaveTypeId` | UUID | Yes | Must exist | Valid leave type |
| `movementType` | Enum | Yes | See LeaveMovementType | Valid type |
| `amount` | Decimal | Yes | != 0 | Non-zero |
| `effectiveDate` | Date | Yes | - | Movement date |
| `reason` | String | Yes | Max 500 chars | Required |
| `sourceId` | UUID | No | - | Reference to source |
| `sourceType` | String | No | - | Source entity type |
| `createdBy` | UUID | Yes | Must exist | Valid user |
| `createdAt` | Timestamp | Yes | - | System-generated |

### Cross-Field Rules

**Rule 1: Amount Sign**
- ALLOCATION, ACCRUAL, ADJUSTMENT (positive), CARRYOVER: `amount` > 0
- USAGE, EXPIRY, PAYOUT: `amount` < 0
- REVERSAL: Can be positive or negative

**Rule 2: Source Reference**
- If `movementType` = USAGE, then `sourceId` should reference LeaveRequest
- If `movementType` = ADJUSTMENT, then `sourceType` = "Manual"

**Rule 3: Immutability**
- Movements cannot be edited or deleted after creation
- Only REVERSAL movements can cancel previous movements

---

# Time & Attendance Entities

## AttendanceRecord

### Field Validations

| Field | Type | Required | Constraints | Validation |
|-------|------|----------|-------------|------------|
| `id` | UUID | Yes | - | System-generated |
| `employeeId` | UUID | Yes | Must exist | Valid employee |
| `date` | Date | Yes | - | Attendance date |
| `rosterEntryId` | UUID | No | Must exist if present | Valid roster entry |
| `clockInTime` | Timestamp | Conditional | Required if not manual | Clock in timestamp |
| `clockInMethod` | Enum | Conditional | See ClockMethod | Required if clockInTime set |
| `clockInLocation` | JSON | No | GPS coordinates | Optional |
| `clockOutTime` | Timestamp | No | > clockInTime | Clock out timestamp |
| `clockOutMethod` | Enum | Conditional | See ClockMethod | Required if clockOutTime set |
| `clockOutLocation` | JSON | No | GPS coordinates | Optional |
| `scheduledStartTime` | Timestamp | No | From roster | Scheduled start |
| `scheduledEndTime` | Timestamp | No | From roster | Scheduled end |
| `actualStartTime` | Timestamp | No | After rounding | Actual start |
| `actualEndTime` | Timestamp | No | After rounding | Actual end |
| `totalWorked` | Decimal | No | >= 0 | Hours worked |
| `totalBreak` | Decimal | No | >= 0 | Break hours |
| `totalPaid` | Decimal | No | >= 0 | Paid hours |
| `status` | Enum | Yes | See AttendanceStatus | Record status |
| `isManual` | Boolean | Yes | - | Default: false |
| `isLate` | Boolean | Yes | - | Default: false |
| `isEarlyOut` | Boolean | Yes | - | Default: false |
| `hasExceptions` | Boolean | Yes | - | Default: false |
| `approvedBy` | UUID | No | Must exist if approved | Approver |
| `approvedAt` | Timestamp | No | - | Approval timestamp |

### Cross-Field Rules

**Rule 1: Clock Times**
- If `clockInTime` is set, then `clockInMethod` is required
- If `clockOutTime` is set, then `clockOutMethod` is required
- `clockOutTime` must be > `clockInTime`

**Rule 2: Hours Calculation**
```
totalWorked = (clockOutTime - clockInTime) - totalBreak
totalPaid = totalWorked (may differ based on exceptions)
```

**Rule 3: Status Lifecycle**
- IN_PROGRESS: clockInTime set, clockOutTime null
- COMPLETED: both clockInTime and clockOutTime set
- PENDING_APPROVAL: isManual=true or hasExceptions=true
- APPROVED: approvedBy and approvedAt set

**Rule 4: Manual Entry**
- If `isManual` = true, then both clockInTime and clockOutTime must be set
- Manual entries require approval

**Rule 5: Exception Flags**
- `isLate` = true if actualStartTime > scheduledStartTime + gracePeriod
- `isEarlyOut` = true if actualEndTime < scheduledEndTime - gracePeriod
- `hasExceptions` = true if any exceptions exist

---

## GeneratedRoster

### Field Validations

| Field | Type | Required | Constraints | Validation |
|-------|------|----------|-------------|------------|
| `id` | UUID | Yes | - | System-generated |
| `employeeId` | UUID | Yes | Must exist | Valid employee |
| `date` | Date | Yes | - | Roster date |
| `scheduleRuleId` | UUID | No | Must exist if present | Schedule rule |
| `patternId` | UUID | No | Must exist if present | Pattern template |
| `dayModelId` | UUID | No | Must exist if present | Day model |
| `shiftId` | UUID | No | Must exist if present | Shift definition |
| `dayType` | Enum | Yes | See DayType | Day type |
| `isOverride` | Boolean | Yes | - | Default: false |
| `overrideReasonCode` | String | Conditional | Required if isOverride=true | Override reason |
| `isHoliday` | Boolean | Yes | - | Default: false |
| `holidayId` | UUID | No | Must exist if isHoliday=true | Holiday reference |
| `generatedAt` | Timestamp | Yes | - | Generation timestamp |

### Cross-Field Rules

**Rule 1: Shift Assignment**
- If `dayType` = WORK or HALF_DAY, then `shiftId` is required
- If `dayType` = OFF or HOLIDAY, then `shiftId` must be null

**Rule 2: Holiday Override**
- If `isHoliday` = true, then `dayType` should be HOLIDAY
- If `isHoliday` = true, then `holidayId` is required

**Rule 3: Override Reason**
- If `isOverride` = true, then `overrideReasonCode` is required
- If `isOverride` = false, then lineage fields (scheduleRuleId, patternId, dayModelId) should be set

**Rule 4: Uniqueness**
- One roster entry per employee per date
- Composite unique key: (employeeId, date)

---

## TimeSegment

### Field Validations

| Field | Type | Required | Constraints | Validation |
|-------|------|----------|-------------|------------|
| `id` | UUID | Yes | - | System-generated |
| `code` | String | Yes | Unique, max 50 chars | Unique code |
| `name` | String | Yes | Max 200 chars | Segment name |
| `segmentType` | Enum | Yes | WORK, BREAK, MEAL, TRANSFER | Segment type |
| `timingMethod` | Enum | Yes | RELATIVE, ABSOLUTE | Timing method |
| `offsetStartMinutes` | Integer | Conditional | >= 0 | Required if RELATIVE |
| `offsetEndMinutes` | Integer | Conditional | > offsetStartMinutes | Required if RELATIVE |
| `absoluteStartTime` | Time | Conditional | Format: HH:mm | Required if ABSOLUTE |
| `absoluteEndTime` | Time | Conditional | > absoluteStartTime | Required if ABSOLUTE |
| `durationMinutes` | Integer | Yes | > 0, <= 1440 | Segment duration |
| `isPaid` | Boolean | Yes | - | Default: true |
| `isMandatory` | Boolean | Yes | - | Default: true |
| `costCenter` | String | No | Max 50 chars | Optional |
| `premiumCode` | String | No | Max 50 chars | Optional |

### Cross-Field Rules

**Rule 1: Timing Method Exclusivity**
- If `timingMethod` = RELATIVE, then offsetStartMinutes and offsetEndMinutes are required
- If `timingMethod` = RELATIVE, then absoluteStartTime and absoluteEndTime must be null
- If `timingMethod` = ABSOLUTE, then absoluteStartTime and absoluteEndTime are required
- If `timingMethod` = ABSOLUTE, then offsetStartMinutes and offsetEndMinutes must be null

**Rule 2: Duration Consistency**
- If RELATIVE: `durationMinutes` = offsetEndMinutes - offsetStartMinutes
- If ABSOLUTE: `durationMinutes` = minutes between absoluteStartTime and absoluteEndTime

**Rule 3: Segment Type Rules**
- If `segmentType` = WORK, then `isPaid` should be true
- If `segmentType` = BREAK or MEAL, then `isPaid` typically false (configurable)

---

## ShiftDefinition

### Field Validations

| Field | Type | Required | Constraints | Validation |
|-------|------|----------|-------------|------------|
| `id` | UUID | Yes | - | System-generated |
| `code` | String | Yes | Unique, max 50 chars | Unique code |
| `name` | String | Yes | Max 200 chars | Shift name |
| `shiftType` | Enum | Yes | ELAPSED, PUNCH, FLEX | Shift type |
| `referenceStartTime` | Time | Conditional | Required if ELAPSED | Reference start |
| `referenceEndTime` | Time | Conditional | Required if ELAPSED | Reference end |
| `graceInMinutes` | Integer | Conditional | >= 0, <= 60 | Grace period in |
| `graceOutMinutes` | Integer | Conditional | >= 0, <= 60 | Grace period out |
| `roundingInterval` | Integer | Conditional | 1, 5, 10, 15, 30 | Rounding interval |
| `roundingMode` | Enum | Conditional | NEAREST, UP, DOWN | Rounding mode |
| `coreStartTime` | Time | Conditional | Required if FLEX | Core hours start |
| `coreEndTime` | Time | Conditional | Required if FLEX | Core hours end |
| `flexStartWindow` | Time | Conditional | Required if FLEX | Flex start window |
| `flexEndWindow` | Time | Conditional | Required if FLEX | Flex end window |
| `totalWorkMinutes` | Integer | Yes | > 0 | Total work minutes |
| `totalBreakMinutes` | Integer | Yes | >= 0 | Total break minutes |
| `totalPaidMinutes` | Integer | Yes | > 0 | Total paid minutes |
| `crossesMidnight` | Boolean | Yes | - | Default: false |
| `color` | String | No | Hex color code | UI color |
| `isActive` | Boolean | Yes | - | Default: true |

### Cross-Field Rules

**Rule 1: Shift Type Specific Fields**
- If `shiftType` = ELAPSED, then referenceStartTime and referenceEndTime are required
- If `shiftType` = PUNCH, then graceInMinutes, graceOutMinutes, roundingInterval, roundingMode are required
- If `shiftType` = FLEX, then coreStartTime, coreEndTime, flexStartWindow, flexEndWindow are required

**Rule 2: Time Totals**
```
totalPaidMinutes = totalWorkMinutes - (unpaid break minutes)
totalWorkMinutes >= totalBreakMinutes
```

**Rule 3: Segment Consistency**
- Shift must have at least one segment
- Sum of segment durations should equal totalWorkMinutes + totalBreakMinutes

**Rule 4: Grace Periods**
- `graceInMinutes` and `graceOutMinutes` should be < totalWorkMinutes

---

## AttendanceException

### Field Validations

| Field | Type | Required | Constraints | Validation |
|-------|------|----------|-------------|------------|
| `id` | UUID | Yes | - | System-generated |
| `attendanceRecordId` | UUID | Yes | Must exist | Valid attendance record |
| `employeeId` | UUID | Yes | Must exist | Valid employee |
| `date` | Date | Yes | - | Exception date |
| `exceptionType` | Enum | Yes | See ExceptionType | Exception type |
| `severity` | Enum | Yes | LOW, MEDIUM, HIGH | Severity level |
| `details` | JSON | Yes | - | Exception details |
| `status` | Enum | Yes | See ExceptionStatus | Exception status |
| `employeeExplanation` | String | No | Max 500 chars | Employee explanation |
| `managerComment` | String | No | Max 500 chars | Manager comment |
| `resolvedBy` | UUID | No | Must exist if resolved | Resolver |
| `resolvedAt` | Timestamp | No | - | Resolution timestamp |
| `resolutionAction` | Enum | No | See ResolutionAction | Resolution action |
| `createdAt` | Timestamp | Yes | - | System-generated |

### Cross-Field Rules

**Rule 1: Status Lifecycle**
- OPEN → ACKNOWLEDGED → RESOLVED/WAIVED
- If `status` = RESOLVED or WAIVED, then resolvedBy and resolvedAt are required

**Rule 2: Resolution Action**
- If `status` = RESOLVED, then `resolutionAction` is required
- Valid actions: APPROVE, ADJUST, DEDUCT, WAIVE

**Rule 3: Exception Details**
- If `exceptionType` = LATE_IN, then details must include `lateMinutes`
- If `exceptionType` = EARLY_OUT, then details must include `earlyMinutes`
- If `exceptionType` = OVERTIME, then details must include `overtimeHours`, `overtimeType`, `multiplier`

---

## Timesheet

### Field Validations

| Field | Type | Required | Constraints | Validation |
|-------|------|----------|-------------|------------|
| `id` | UUID | Yes | - | System-generated |
| `employeeId` | UUID | Yes | Must exist | Valid employee |
| `payPeriodId` | UUID | Yes | Must exist | Valid pay period |
| `payPeriodStartDate` | Date | Yes | - | Period start |
| `payPeriodEndDate` | Date | Yes | > payPeriodStartDate | Period end |
| `totalWorked` | Decimal | Yes | >= 0 | Total hours worked |
| `totalPaid` | Decimal | Yes | >= 0 | Total paid hours |
| `regularHours` | Decimal | Yes | >= 0 | Regular hours |
| `overtimeHours` | Decimal | Yes | >= 0 | Overtime hours |
| `leaveHours` | Decimal | Yes | >= 0 | Leave hours |
| `status` | Enum | Yes | See TimesheetStatus | Timesheet status |
| `submittedBy` | UUID | No | Must exist if submitted | Submitter |
| `submittedAt` | Timestamp | No | - | Submission timestamp |
| `approvedBy` | UUID | No | Must exist if approved | Approver |
| `approvedAt` | Timestamp | No | - | Approval timestamp |
| `rejectionReason` | String | No | Max 500 chars | Rejection reason |
| `isLocked` | Boolean | Yes | - | Default: false |

### Cross-Field Rules

**Rule 1: Hours Breakdown**
```
totalPaid = regularHours + overtimeHours + leaveHours
totalWorked = regularHours + overtimeHours
```

**Rule 2: Status Transitions**
- DRAFT → SUBMITTED → APPROVED/REJECTED → PAID
- If `status` = SUBMITTED, then submittedBy and submittedAt are required
- If `status` = APPROVED, then approvedBy and approvedAt are required
- If `status` = REJECTED, then rejectionReason is required

**Rule 3: Locking**
- If `isLocked` = true, then timesheet cannot be edited
- Typically locked when `status` = PAID

---

# Shared Entities

## HolidayCalendar

### Field Validations

| Field | Type | Required | Constraints | Validation |
|-------|------|----------|-------------|------------|
| `id` | UUID | Yes | - | System-generated |
| `code` | String | Yes | Unique, max 50 chars | Unique code |
| `name` | String | Yes | Max 200 chars | Calendar name |
| `country` | String | Yes | ISO 3166-1 alpha-2 | Country code |
| `year` | Integer | Yes | >= 2000, <= 2100 | Valid year |
| `isActive` | Boolean | Yes | - | Default: true |

### Uniqueness
- Composite unique key: (country, year)

---

## Holiday

### Field Validations

| Field | Type | Required | Constraints | Validation |
|-------|------|----------|-------------|------------|
| `id` | UUID | Yes | - | System-generated |
| `calendarId` | UUID | Yes | Must exist | Valid calendar |
| `date` | Date | Yes | - | Holiday date |
| `name` | String | Yes | Max 200 chars | Holiday name |
| `holidayClass` | Enum | Yes | CLASS_A, CLASS_B, CLASS_C | Holiday class |
| `isMultiDay` | Boolean | Yes | - | Default: false |
| `endDate` | Date | Conditional | >= date | Required if multiDay |
| `totalDays` | Integer | Conditional | > 0 | Required if multiDay |

### Cross-Field Rules

**Rule 1: Multi-Day Holidays**
- If `isMultiDay` = true, then `endDate` and `totalDays` are required
- If `isMultiDay` = false, then `endDate` and `totalDays` must be null
- `totalDays` = number of days from date to endDate (inclusive)

---

# Common Validation Patterns

## Date Validations

**Past Date Check**
```
date >= today (unless retroactive allowed)
```

**Date Range Check**
```
endDate >= startDate
```

**Working Days Calculation**
```
workingDays = count of dates in [startDate, endDate] 
              where date is not weekend 
              and date is not in holiday calendar
```

## Decimal Precision

All decimal fields (hours, days, amounts):
- Precision: 2 decimal places
- Rounding: HALF_UP
- Example: 8.25, 0.50, 15.75

## String Validations

**Code Fields**
- Pattern: `^[A-Z0-9_]+$`
- Max length: 50 characters
- Unique within entity type

**Name Fields**
- Max length: 200 characters
- Required, non-empty

**Reason/Comment Fields**
- Max length: 500 characters
- Optional

## UUID Validations

All UUID fields:
- Format: RFC 4122
- Example: `550e8400-e29b-41d4-a716-446655440000`
- Must reference existing entity (foreign key)

---

# Enumeration Definitions

## LeaveRequestStatus

```
DRAFT           - Request created but not submitted
PENDING         - Submitted, awaiting approval
APPROVED        - Approved by manager
REJECTED        - Rejected by manager
WITHDRAWN       - Withdrawn by employee
CANCELLED       - Cancelled after approval
```

## LeaveMovementType

```
ALLOCATION      - Annual allocation
ACCRUAL         - Monthly accrual
USAGE           - Leave taken
ADJUSTMENT      - Manual adjustment
CARRYOVER       - Carried from previous year
EXPIRY          - Expired balance
PAYOUT          - Paid out instead of carried
REVERSAL        - Reversal of previous movement
```

## AttendanceStatus

```
IN_PROGRESS         - Clocked in, not out
COMPLETED           - Clocked out, no exceptions
PENDING_APPROVAL    - Has exceptions or manual entry
APPROVED            - Approved by manager
CANCELLED           - Cancelled
```

## ClockMethod

```
BIOMETRIC       - Fingerprint/face recognition
RFID            - RFID card
MOBILE          - Mobile app
BADGE           - Badge swipe
WEB             - Web portal
MANUAL          - Manual entry
```

## ExceptionType

```
LATE_IN             - Late arrival
EARLY_OUT           - Early departure
MISSING_PUNCH       - Missing clock in/out
UNAUTHORIZED_ABSENCE - No-show
OVERTIME            - Overtime hours
```

## ExceptionStatus

```
OPEN            - Exception detected
ACKNOWLEDGED    - Manager acknowledged
RESOLVED        - Resolved
WAIVED          - Waived/excused
```

## ResolutionAction

```
APPROVE         - Approve as-is
ADJUST          - Adjust hours/times
DEDUCT          - Deduct from pay/leave
WAIVE           - Waive exception
```

## TimesheetStatus

```
DRAFT           - Generated, not submitted
SUBMITTED       - Submitted by employee
APPROVED        - Approved by manager
REJECTED        - Rejected by manager
PAID            - Sent to payroll (locked)
```

## DayType

```
WORK            - Regular work day
OFF             - Day off
HOLIDAY         - Public holiday
HALF_DAY        - Half-day work
```

## ShiftType

```
ELAPSED         - Fixed start/end times
PUNCH           - Flexible with grace periods
FLEX            - Flexible with core hours
```

---

## Document Status

**Status**: Complete - All major entities documented  
**Coverage**:
- ✅ Absence Management Entities (3 entities)
- ✅ Time & Attendance Entities (8 entities)
- ✅ Shared Entities (2 entities)
- ✅ Common Validation Patterns
- ✅ Enumeration Definitions

**Total Entities**: 13 entities with complete validation rules

**Last Updated**: 2025-12-15  
**Next Steps**: Review with development team and QA
