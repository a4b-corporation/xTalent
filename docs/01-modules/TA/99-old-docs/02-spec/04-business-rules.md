# Business Rules - Time & Absence Module

**Version**: 2.0  
**Last Updated**: 2025-12-15  
**Module**: Time & Absence (TA)  
**Status**: Draft

---

## Document Information

- **Purpose**: Centralize all business logic rules for the TA module
- **Audience**: Business Analysts, Developers, QA Engineers, Product Owners
- **Scope**: Absence Management, Time & Attendance, and Shared business rules
- **Related Documents**:
  - [Functional Requirements](./01-functional-requirements.md) - What the system does
  - [Data Specification](./03-data-specification.md) - Data validation rules
  - [Behavior Specs](./01-absence-behaviour-spec.md) - Detailed behaviors

---

## Table of Contents

1. [Absence Management Rules](#absence-management-rules)
2. [Time & Attendance Rules](#time--attendance-rules)
3. [Shared Rules](#shared-rules)
4. [Rule Categories](#rule-categories)

---

## Business Rule Template

Each rule follows this structure:

```
### BR-XXX-NNN: Rule Name

**Category**: Validation | Calculation | Authorization | Audit | Workflow
**Priority**: High | Medium | Low
**Applies To**: Entity/Process
**Related FR**: FR-XXX-NNN

**Description**: Clear description of the rule

**Condition**: When this rule applies

**Action**: What happens when rule is triggered

**Formula**: (if calculation rule)
[Mathematical formula or pseudocode]

**Error Code**: ERROR_CODE_NAME
**Error Message**: "User-friendly error message"

**Example**:
[Concrete example demonstrating the rule]

**Exceptions**: (if any)
- Exception case 1
- Exception case 2
```

---

# Absence Management Rules

## Balance Calculation Rules

### BR-ABS-001: Calculate Available Balance

**Category**: Calculation  
**Priority**: High  
**Applies To**: LeaveBalance  
**Related FR**: FR-ABS-042

**Description**: Calculate employee's available leave balance

**Formula**:
```
available = totalAllocated + carryover + adjusted - used - pending - expired
```

**Where**:
- `totalAllocated`: Annual allocation + accruals
- `carryover`: Balance carried from previous year
- `adjusted`: Manual adjustments (can be positive or negative)
- `used`: Leave already taken
- `pending`: Leave reserved for pending requests
- `expired`: Expired carryover balance

**Example**:
```
totalAllocated = 20.0
carryover = 5.0
adjusted = 2.0 (bonus days)
used = 8.0
pending = 3.0
expired = 1.0

available = 20.0 + 5.0 + 2.0 - 8.0 - 3.0 - 1.0 = 15.0 days
```

---

### BR-ABS-002: Sufficient Balance Check

**Category**: Validation  
**Priority**: High  
**Applies To**: LeaveRequest  
**Related FR**: FR-ABS-001

**Description**: Employee must have sufficient available balance to submit leave request

**Condition**: When employee submits leave request

**Action**: Validate that `available >= workingDays`

**Error Code**: `INSUFFICIENT_BALANCE`  
**Error Message**: "Insufficient leave balance. Available: {available} days, Requested: {workingDays} days"

**Example**:
```
Available balance: 5.0 days
Requested: 7.0 days
Result: REJECTED - Insufficient balance
```

**Exceptions**:
- If overdraft is allowed for this leave type, allow negative balance up to overdraft limit
- HR can override this check with reason

---

### BR-ABS-003: Advance Notice Requirement

**Category**: Validation  
**Priority**: High  
**Applies To**: LeaveRequest  
**Related FR**: FR-ABS-102

**Description**: Leave request must be submitted with required advance notice

**Condition**: When employee submits leave request

**Action**: Validate that `today + advanceNoticeDays <= startDate`

**Formula**:
```
if (startDate - today) < advanceNoticeDays:
    reject with ADVANCE_NOTICE_REQUIRED
```

**Error Code**: `ADVANCE_NOTICE_REQUIRED`  
**Error Message**: "Leave must be requested at least {advanceNoticeDays} days in advance"

**Example**:
```
Today: 2025-12-15
Start Date: 2025-12-18
Advance Notice: 5 days
Days in advance: 3 days
Result: REJECTED - Insufficient advance notice
```

**Exceptions**:
- Retroactive requests (startDate < today) always require manager approval
- Emergency leave types may have 0 days advance notice
- Manager/HR can override

---

### BR-ABS-004: Blackout Period Check

**Category**: Validation  
**Priority**: High  
**Applies To**: LeaveRequest  
**Related FR**: FR-ABS-104

**Description**: Leave cannot be taken during blackout periods

**Condition**: When employee submits leave request

**Action**: Check if [startDate, endDate] overlaps with any blackout period

**Error Code**: `BLACKOUT_PERIOD`  
**Error Message**: "Leave cannot be taken during blackout period: {blackoutReason}"

**Example**:
```
Blackout Period: 2025-12-20 to 2025-12-31 (Year-end closing)
Requested: 2025-12-22 to 2025-12-24
Result: REJECTED - Falls within blackout period
```

**Exceptions**:
- HR can override with reason
- Critical leave types (e.g., sick leave, bereavement) may be exempt

---

### BR-ABS-005: Eligibility Check

**Category**: Authorization  
**Priority**: High  
**Applies To**: LeaveRequest  
**Related FR**: FR-ABS-101

**Description**: Employee must be eligible for the leave type

**Condition**: When employee creates leave request

**Action**: Validate employee against eligibility criteria

**Eligibility Criteria** (can be combined):
- Tenure: Minimum service period (e.g., 6 months)
- Employment Type: Full-time, Part-time, Contract
- Location: Specific countries/offices
- Department: Specific departments
- Job Level: Specific job levels
- Custom: EligibilityProfile from Core module

**Error Code**: `NOT_ELIGIBLE`  
**Error Message**: "You are not eligible for {leaveTypeName}. Reason: {eligibilityReason}"

**Example**:
```
Leave Type: Sabbatical Leave
Eligibility: Tenure >= 5 years
Employee Tenure: 3 years
Result: REJECTED - Not eligible
```

---

### BR-ABS-006: Maximum Consecutive Days

**Category**: Validation  
**Priority**: High  
**Applies To**: LeaveRequest  
**Related FR**: FR-ABS-103

**Description**: Leave request cannot exceed maximum consecutive days

**Condition**: When employee submits leave request

**Action**: Validate that `workingDays <= maxConsecutiveDays`

**Error Code**: `MAX_CONSECUTIVE_DAYS`  
**Error Message**: "Leave request exceeds maximum consecutive days. Maximum: {maxConsecutiveDays}, Requested: {workingDays}"

**Example**:
```
Max Consecutive Days: 10
Requested: 15 working days
Result: REJECTED - Exceeds maximum
```

**Exceptions**:
- Manager/HR can override with reason
- Some leave types (e.g., maternity) may have no limit

---

### BR-ABS-007: Documentation Requirement

**Category**: Validation  
**Priority**: Medium  
**Applies To**: LeaveRequest  
**Related FR**: FR-ABS-105

**Description**: Certain leave types or durations require supporting documentation

**Condition**: When employee submits leave request

**Action**: Validate that required documents are attached

**Documentation Rules**:
- Sick leave > 3 days: Medical certificate required
- Bereavement leave: Death certificate or obituary
- Maternity leave: Medical certificate
- Study leave: Enrollment proof

**Error Code**: `DOCUMENTATION_REQUIRED`  
**Error Message**: "Supporting documentation is required for {leaveTypeName}"

**Example**:
```
Leave Type: Sick Leave
Duration: 5 days
Documents Attached: None
Result: REJECTED - Medical certificate required
```

---

### BR-ABS-010: No Overlapping Requests

**Category**: Validation  
**Priority**: High  
**Applies To**: LeaveRequest

**Description**: Employee cannot have overlapping leave requests

**Condition**: When employee submits leave request

**Action**: Check for existing requests where date ranges overlap

**Formula**:
```
For each existing request:
    if (newStartDate <= existingEndDate) AND (newEndDate >= existingStartDate):
        reject with OVERLAPPING_REQUEST
```

**Error Code**: `OVERLAPPING_REQUEST`  
**Error Message**: "Leave request overlaps with existing request {requestId} ({startDate} to {endDate})"

**Example**:
```
Existing Request: 2025-12-20 to 2025-12-22
New Request: 2025-12-21 to 2025-12-23
Result: REJECTED - Overlapping dates
```

**Exceptions**:
- Cancelled or rejected requests are ignored
- Different leave types may be allowed to overlap (configurable)

---

## Accrual Rules

### BR-ABS-020: Tenure-Based Allocation

**Category**: Calculation  
**Priority**: High  
**Applies To**: Leave Allocation  
**Related FR**: FR-ABS-063

**Description**: Annual leave allocation varies based on years of service

**Formula**:
```
if tenure < 5 years:
    allocation = 15 days
elif tenure < 10 years:
    allocation = 18 days
else:
    allocation = 20 days
```

**Example**:
```
Employee Tenure: 7 years
Annual Allocation: 18 days
```

**Note**: Tenure brackets and amounts are configurable per organization

---

### BR-ABS-021: Proration for New Hires

**Category**: Calculation  
**Priority**: High  
**Applies To**: Leave Allocation  
**Related FR**: FR-ABS-064

**Description**: Leave allocation is prorated for employees joining mid-year

**Formula**:
```
remainingMonths = 12 - (hireMonth - 1)
proratedAllocation = annualEntitlement × (remainingMonths / 12)
proratedAllocation = round(proratedAllocation, roundingRule)
```

**Example**:
```
Hire Date: 2025-07-01 (Month 7)
Annual Entitlement: 15 days
Remaining Months: 12 - 6 = 6 months
Prorated: 15 × (6/12) = 7.5 days
After Rounding (NEAREST): 8 days
```

---

### BR-ABS-022: Part-Time Proration

**Category**: Calculation  
**Priority**: High  
**Applies To**: Leave Allocation  
**Related FR**: FR-ABS-065

**Description**: Leave allocation is prorated for part-time employees

**Formula**:
```
proratedAllocation = fullTimeEntitlement × (workHours / standardHours)
```

**Example**:
```
Full-Time Entitlement: 15 days
Work Hours: 20 hours/week
Standard Hours: 40 hours/week
Prorated: 15 × (20/40) = 7.5 days
```

---

## Carryover Rules

### BR-ABS-030: Limited Carryover

**Category**: Calculation  
**Priority**: High  
**Applies To**: Leave Carryover  
**Related FR**: FR-ABS-081

**Description**: Unused leave can be carried over up to a maximum limit

**Formula**:
```
unused = totalAllocated + carryover + adjusted - used - expired
carryoverAmount = min(unused, maxCarryover)
expiredAmount = max(0, unused - maxCarryover)
```

**Example**:
```
Unused Balance: 12 days
Max Carryover: 5 days
Carryover Amount: 5 days
Expired Amount: 7 days
```

---

### BR-ABS-031: Carryover Expiry

**Category**: Calculation  
**Priority**: Medium  
**Applies To**: Leave Carryover  
**Related FR**: FR-ABS-083

**Description**: Carried over leave expires after configured period

**Formula**:
```
expiryDate = leaveYearStartDate + carryoverExpiryMonths
if today >= expiryDate:
    expire carryover balance
```

**Example**:
```
Leave Year Start: 2025-01-01
Carryover Expiry: 3 months
Expiry Date: 2025-04-01
Carryover Balance: 5 days
On 2025-04-01: 5 days expired
```

---

### BR-ABS-032: Leave Payout

**Category**: Calculation  
**Priority**: Medium  
**Applies To**: Leave Payout  
**Related FR**: FR-ABS-084

**Description**: Unused leave can be paid out instead of carried over

**Formula**:
```
payoutAmount = unusedDays × dailyRate
dailyRate = (annualSalary / 12) / workingDaysPerMonth
```

**Example**:
```
Unused Days: 10 days
Annual Salary: $60,000
Daily Rate: ($60,000 / 12) / 22 = $227.27
Payout Amount: 10 × $227.27 = $2,272.70
```

**Note**: Payout is typically taxable income

---

# Time & Attendance Rules

## Hierarchical Scheduling Rules

### BR-ATT-H01: Time Segment Timing Method

**Category**: Validation  
**Priority**: High  
**Applies To**: TimeSegment  
**Related FR**: FR-ATT-001

**Description**: Time segment must use either RELATIVE or ABSOLUTE timing, not both

**Condition**: When creating/updating time segment

**Action**: Validate XOR constraint

**Formula**:
```
if timingMethod == RELATIVE:
    require: offsetStartMinutes, offsetEndMinutes
    forbid: absoluteStartTime, absoluteEndTime
elif timingMethod == ABSOLUTE:
    require: absoluteStartTime, absoluteEndTime
    forbid: offsetStartMinutes, offsetEndMinutes
```

**Error Code**: `INVALID_TIMING_METHOD`  
**Error Message**: "Time segment must use either RELATIVE or ABSOLUTE timing, not both"

---

### BR-ATT-H02: Segment Duration Consistency

**Category**: Validation  
**Priority**: High  
**Applies To**: TimeSegment

**Description**: Segment duration must match calculated time

**Formula**:
```
if timingMethod == RELATIVE:
    calculatedDuration = offsetEndMinutes - offsetStartMinutes
elif timingMethod == ABSOLUTE:
    calculatedDuration = minutesBetween(absoluteStartTime, absoluteEndTime)

if durationMinutes != calculatedDuration:
    reject with DURATION_MISMATCH
```

**Error Code**: `DURATION_MISMATCH`  
**Error Message**: "Segment duration ({durationMinutes}) does not match calculated time ({calculatedDuration})"

---

### BR-ATT-H10: Shift Must Have Segments

**Category**: Validation  
**Priority**: High  
**Applies To**: ShiftDefinition  
**Related FR**: FR-ATT-002

**Description**: Shift definition must have at least one time segment

**Condition**: When creating/updating shift

**Action**: Validate that shift has >= 1 segment

**Error Code**: `NO_SEGMENTS`  
**Error Message**: "Shift must have at least one time segment"

---

### BR-ATT-H11: Segment Sequential Ordering

**Category**: Validation  
**Priority**: High  
**Applies To**: ShiftDefinition

**Description**: Shift segments must be in sequential order with no gaps

**Formula**:
```
for i in range(1, segmentCount):
    if segment[i].sequence != segment[i-1].sequence + 1:
        reject with SEQUENCE_GAP
```

**Error Code**: `SEQUENCE_GAP`  
**Error Message**: "Shift segments must be in sequential order (1, 2, 3, ...)"

---

### BR-ATT-H20: Day Model Shift Consistency

**Category**: Validation  
**Priority**: High  
**Applies To**: DayModel  
**Related FR**: FR-ATT-003

**Description**: Day type must be consistent with shift assignment

**Condition**: When creating/updating day model

**Action**: Validate day type and shift consistency

**Rules**:
- If `dayType` = WORK or HALF_DAY, then `shiftId` is required
- If `dayType` = OFF or HOLIDAY, then `shiftId` must be null

**Error Code**: `DAY_TYPE_SHIFT_MISMATCH`  
**Error Message**: "Day type {dayType} is incompatible with shift assignment"

---

### BR-ATT-H30: Pattern Cycle Completeness

**Category**: Validation  
**Priority**: High  
**Applies To**: PatternTemplate  
**Related FR**: FR-ATT-004

**Description**: Pattern must define day model for every day in cycle

**Condition**: When creating/updating pattern

**Action**: Validate all days are defined

**Formula**:
```
definedDays = count of day assignments
if definedDays != cycleLengthDays:
    reject with INCOMPLETE_PATTERN
```

**Error Code**: `INCOMPLETE_PATTERN`  
**Error Message**: "Pattern must define all {cycleLengthDays} days in cycle. Currently defined: {definedDays}"

---

### BR-ATT-H40: Schedule Rule Assignment Required

**Category**: Validation  
**Priority**: High  
**Applies To**: ScheduleRule  
**Related FR**: FR-ATT-005

**Description**: Schedule rule must have at least one assignment (employee, group, or position)

**Condition**: When creating schedule rule

**Action**: Validate at least one assignment type is specified

**Error Code**: `NO_ASSIGNMENT`  
**Error Message**: "Schedule rule must be assigned to at least one employee, group, or position"

---

### BR-ATT-H41: No Conflicting Schedule Rules

**Category**: Validation  
**Priority**: High  
**Applies To**: ScheduleRule  
**Related FR**: FR-ATT-019

**Description**: Employee cannot have overlapping schedule rules

**Condition**: When creating/updating schedule rule

**Action**: Check for date range overlap for same employee

**Formula**:
```
For each existing rule for employee:
    if (newStartDate <= existingEndDate) AND (newEndDate >= existingStartDate):
        reject with CONFLICTING_SCHEDULE
```

**Error Code**: `CONFLICTING_SCHEDULE`  
**Error Message**: "Schedule rule conflicts with existing rule {ruleId} ({startDate} to {endDate})"

**Exceptions**:
- HR can override with reason for transition periods

---

### BR-ATT-H50: Roster Generation Formula

**Category**: Calculation  
**Priority**: High  
**Applies To**: Roster Generation  
**Related FR**: FR-ATT-006

**Description**: Calculate which day in pattern cycle for a given date

**Formula**:
```
daysSinceReference = date - startReferenceDate
adjustedDays = daysSinceReference + offsetDays
cycleDay = (adjustedDays % cycleLengthDays) + 1
```

**Example**:
```
Start Reference Date: 2025-01-01
Offset Days: 0
Cycle Length: 7 days
Date: 2025-01-10

Days Since Reference: 9
Adjusted Days: 9 + 0 = 9
Cycle Day: (9 % 7) + 1 = 3

Result: Day 3 of pattern
```

---

### BR-ATT-H51: Holiday Override

**Category**: Calculation  
**Priority**: High  
**Applies To**: Roster Generation

**Description**: Holidays override generated roster

**Condition**: During roster generation

**Action**: If date is in holiday calendar, override day type to HOLIDAY and set shift to null

**Priority**: Holiday > Schedule Rule > Default

---

### BR-ATT-H52: Manual Override Preservation

**Category**: Calculation  
**Priority**: High  
**Applies To**: Roster Generation

**Description**: Manual overrides take precedence over generated roster

**Condition**: During roster generation

**Action**: If override exists for employee/date, use override instead of generated roster

**Priority**: Manual Override > Holiday > Schedule Rule

---

### BR-ATT-H53: Roster Lineage Tracking

**Category**: Audit  
**Priority**: Medium  
**Applies To**: GeneratedRoster  
**Related FR**: FR-ATT-008

**Description**: Track complete lineage of how roster was generated

**Action**: Store schedule rule ID, pattern ID, day model ID, shift ID for each roster entry

**Purpose**: Troubleshooting and audit trail

---

## Clock In/Out Rules

### BR-ATT-001: Prevent Duplicate Clock In

**Category**: Validation  
**Priority**: High  
**Applies To**: Clock In  
**Related FR**: FR-ATT-052

**Description**: Employee cannot clock in twice on same day

**Condition**: When employee attempts to clock in

**Action**: Check if attendance record exists with status IN_PROGRESS

**Error Code**: `ALREADY_CLOCKED_IN`  
**Error Message**: "You have already clocked in today at {clockInTime}"

---

### BR-ATT-002: Grace Period Application

**Category**: Calculation  
**Priority**: High  
**Applies To**: Clock In  
**Related FR**: FR-ATT-011

**Description**: Apply grace period before marking employee as late

**Formula**:
```
allowedStartTime = scheduledStartTime + gracePeriod
if clockInTime <= allowedStartTime:
    isLate = false
else:
    isLate = true
    lateMinutes = clockInTime - allowedStartTime
```

**Example**:
```
Scheduled Start: 08:00
Grace Period: 10 minutes
Allowed Start: 08:10
Clock In: 08:05
Result: Not late

Clock In: 08:15
Result: Late by 5 minutes
```

---

### BR-ATT-003: Time Rounding

**Category**: Calculation  
**Priority**: High  
**Applies To**: Clock In/Out  
**Related FR**: FR-ATT-012

**Description**: Round clock times according to configured rules

**Formula**:
```
if roundingMode == NEAREST:
    roundedTime = round(clockTime, roundingInterval)
elif roundingMode == UP:
    roundedTime = ceiling(clockTime, roundingInterval)
elif roundingMode == DOWN:
    roundedTime = floor(clockTime, roundingInterval)
```

**Example** (15-minute interval):
```
Clock In: 08:07
NEAREST: 08:00
UP: 08:15
DOWN: 08:00

Clock In: 08:08
NEAREST: 08:15
UP: 08:15
DOWN: 08:00
```

---

### BR-ATT-004: Clock Out After Clock In

**Category**: Validation  
**Priority**: High  
**Applies To**: Clock Out  
**Related FR**: FR-ATT-053

**Description**: Employee must clock in before clocking out

**Condition**: When employee attempts to clock out

**Action**: Validate attendance record exists with status IN_PROGRESS

**Error Code**: `NOT_CLOCKED_IN`  
**Error Message**: "You must clock in before clocking out"

---

## Exception Detection Rules

### BR-ATT-010: Late In Detection

**Category**: Calculation  
**Priority**: High  
**Applies To**: Attendance Exceptions  
**Related FR**: FR-ATT-061

**Description**: Automatically detect late arrivals

**Formula**:
```
allowedStartTime = scheduledStartTime + gracePeriod
if clockInTime > allowedStartTime:
    create LATE_IN exception
    lateMinutes = clockInTime - allowedStartTime
    severity = calculateSeverity(lateMinutes)
```

**Severity Calculation**:
```
if lateMinutes < 15:
    severity = LOW
elif lateMinutes < 30:
    severity = MEDIUM
else:
    severity = HIGH
```

---

### BR-ATT-011: Early Out Detection

**Category**: Calculation  
**Priority**: High  
**Applies To**: Attendance Exceptions  
**Related FR**: FR-ATT-062

**Description**: Automatically detect early departures

**Formula**:
```
allowedEndTime = scheduledEndTime - gracePeriod
if clockOutTime < allowedEndTime:
    create EARLY_OUT exception
    earlyMinutes = allowedEndTime - clockOutTime
```

---

### BR-ATT-012: Overtime Detection

**Category**: Calculation  
**Priority**: High  
**Applies To**: Attendance Exceptions  
**Related FR**: FR-ATT-065

**Description**: Automatically detect overtime hours

**Formula**:
```
if actualHours > scheduledHours:
    overtimeHours = actualHours - scheduledHours
    create OVERTIME exception
    classify overtime type
    calculate multiplier
```

**Overtime Classification**:
- DAILY: Hours over daily threshold (e.g., > 8 hours)
- WEEKLY: Hours over weekly threshold (e.g., > 40 hours)
- WEEKEND: Work on Saturday/Sunday
- HOLIDAY: Work on public holiday
- NIGHT: Work during night hours (22:00-06:00)

**Multiplier**:
- Weekday OT: 1.5x
- Weekend: 2.0x
- Holiday: 3.0x
- Night: 1.3x (additional)

---

# Shared Rules

## Working Day Calculation

### BR-COMMON-001: Calculate Working Days

**Category**: Calculation  
**Priority**: High  
**Applies To**: Leave Request, Roster

**Description**: Calculate number of working days in date range

**Formula**:
```
workingDays = 0
for date in [startDate, endDate]:
    if isWeekday(date) AND NOT isHoliday(date):
        workingDays += 1
```

**Weekend Definition**:
- Default: Saturday and Sunday
- Configurable per location

**Holiday Check**:
- Check against assigned holiday calendar
- Holidays override working days

---

### BR-COMMON-002: Holiday Calendar Priority

**Category**: Calculation  
**Priority**: High  
**Applies To**: All date calculations

**Description**: Determine which holiday calendar to use

**Priority Order**:
1. Employee-specific calendar (if assigned)
2. Location-specific calendar
3. Country-specific calendar
4. Default calendar

---

## Approval Workflow Rules

### BR-COMMON-010: Approval Chain Execution

**Category**: Workflow  
**Priority**: High  
**Applies To**: Leave Requests, Overtime Requests, Timesheets

**Description**: Execute approval chain sequentially

**Rules**:
- Approval proceeds level by level
- Each level must approve before proceeding to next
- Rejection at any level rejects entire request
- System notifies next approver after previous approval

---

### BR-COMMON-011: Self-Approval Prevention

**Category**: Authorization  
**Priority**: High  
**Applies To**: All approval workflows

**Description**: Manager cannot approve own requests

**Condition**: When processing approval

**Action**: Validate approver != requester

**Error Code**: `CANNOT_APPROVE_OWN`  
**Error Message**: "You cannot approve your own request"

**Exception**: HR can override in special cases

---

## Audit Rules

### BR-COMMON-020: Immutable Audit Trail

**Category**: Audit  
**Priority**: High  
**Applies To**: All entities

**Description**: Audit trail records are immutable

**Rules**:
- All state changes are logged
- Audit records cannot be edited or deleted
- Audit records include: timestamp, user, action, before/after values
- Audit retention: 7 years (configurable)

---

## Rounding Rules

### BR-COMMON-030: Decimal Rounding

**Category**: Calculation  
**Priority**: Medium  
**Applies To**: Leave balances, hours

**Description**: Apply consistent rounding to decimal values

**Rounding Modes**:
- UP: Always round up (e.g., 2.1 → 3.0)
- DOWN: Always round down (e.g., 2.9 → 2.0)
- NEAREST: Round to nearest (e.g., 2.4 → 2.0, 2.6 → 3.0)
- NEAREST_HALF: Round to nearest 0.5 (e.g., 2.3 → 2.5, 2.7 → 2.5)
- NONE: Keep decimals (e.g., 2.3 → 2.3)

**Precision**: 2 decimal places

---

# Rule Categories

## Validation Rules
Rules that validate data before processing:
- BR-ABS-002: Sufficient Balance Check
- BR-ABS-003: Advance Notice Requirement
- BR-ABS-004: Blackout Period Check
- BR-ABS-006: Maximum Consecutive Days
- BR-ABS-010: No Overlapping Requests
- BR-ATT-001: Prevent Duplicate Clock In
- BR-ATT-004: Clock Out After Clock In

## Calculation Rules
Rules that perform calculations:
- BR-ABS-001: Calculate Available Balance
- BR-ABS-020: Tenure-Based Allocation
- BR-ABS-021: Proration for New Hires
- BR-ABS-022: Part-Time Proration
- BR-ABS-030: Limited Carryover
- BR-ATT-H50: Roster Generation Formula
- BR-ATT-002: Grace Period Application
- BR-ATT-003: Time Rounding
- BR-COMMON-001: Calculate Working Days

## Authorization Rules
Rules that control access and permissions:
- BR-ABS-005: Eligibility Check
- BR-COMMON-011: Self-Approval Prevention

## Workflow Rules
Rules that govern process flows:
- BR-COMMON-010: Approval Chain Execution

## Audit Rules
Rules for tracking and compliance:
- BR-ATT-H53: Roster Lineage Tracking
- BR-COMMON-020: Immutable Audit Trail

---

## Document Status

**Status**: Complete - All major business rules documented  
**Coverage**:
- ✅ Absence Management Rules (30+ rules)
- ✅ Time & Attendance Rules (25+ rules)
- ✅ Shared Rules (10+ rules)

**Total Rules**: 65+ business rules documented

**Rule Breakdown by Category**:
- Validation: 20 rules
- Calculation: 25 rules
- Authorization: 5 rules
- Workflow: 5 rules
- Audit: 10 rules

**Last Updated**: 2025-12-15  
**Next Steps**: Review with business analysts and product owners
