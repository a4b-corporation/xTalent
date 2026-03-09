# Time & Attendance - Behavioural Specification v2.0

> Detailed business logic, validation rules, and behavioral requirements for Time & Attendance sub-module (Hierarchical Model v2.0).

---

## Document Information

- **Feature**: Time & Attendance
- **Module**: Time & Absence (TA)
- **Version**: 2.0
- **Architecture**: 6-Level Hierarchical Model
- **Last Updated**: 2025-12-01
- **Author**: xTalent Documentation Team
- **Status**: Draft

**Version History**:
- v2.0 (2025-12-01): Updated for hierarchical 6-level model with new use cases
- v1.0 (2025-12-01): Initial version with flat model

---

## Overview

### Purpose
Enable shift scheduling, time tracking, attendance recording, and overtime management using a hierarchical 6-level architecture.

### Architecture
Time & Attendance uses a **6-level hierarchical model**:
1. **Time Segment** - Atomic units (WORK, BREAK, MEAL, TRANSFER)
2. **Shift Definition** - Composition of segments (ELAPSED, PUNCH, FLEX)
3. **Day Model** - Daily schedule templates (WORK, OFF, HOLIDAY)
4. **Pattern Template** - Repeating cycles (5x8, 4on-4off, 14/14)
5. **Work Schedule Rule** - Pattern + calendar + rotation
6. **Generated Roster** - Materialized employee assignments

### Scope

**In Scope**:
- ✅ Hierarchical schedule configuration (6 levels)
- ✅ Time segment and shift definition management
- ✅ Pattern template and day model configuration
- ✅ Work schedule rules with rotation support
- ✅ Automated roster generation
- ✅ Time clock integration (biometric, RFID, mobile)
- ✅ Attendance tracking with clock in/out
- ✅ Timesheet entry and approval
- ✅ Attendance exception detection
- ✅ Shift swap and bidding
- ✅ Overtime calculation

**Out of Scope**:
- ❌ Payroll calculation
- ❌ Leave management (separate sub-module)
- ❌ Project management

---

## Use Cases - Hierarchical Configuration

### UC-ATT-H01: HR Configures Time Segments (Level 1)

**Actor**: HR Administrator

**Preconditions**:
- User has HR admin permission
- System is configured

**Trigger**: HR needs to define atomic time units for shifts

**Main Flow**:
1. HR navigates to Time & Attendance → Configuration → Time Segments
2. HR clicks "Create Time Segment"
3. System displays segment creation form
4. HR enters:
   - Code (e.g., "WORK_4H", "LUNCH_1H")
   - Name (e.g., "Work Morning", "Lunch Break")
   - Segment Type: WORK | BREAK | MEAL | TRANSFER
   - Timing method: RELATIVE or ABSOLUTE
   - If RELATIVE:
     - Start Offset Minutes (e.g., 0)
     - End Offset Minutes (e.g., 240)
   - If ABSOLUTE:
     - Start Time (e.g., "12:00")
     - End Time (e.g., "13:00")
   - Duration Minutes (calculated or manual)
   - Is Paid (checkbox)
   - Is Mandatory (checkbox)
   - Cost Center Code (optional)
   - Premium Code (optional, e.g., "NIGHT_SHIFT")
5. System validates:
   - Code is unique
   - Either offset OR absolute time is provided (not both)
   - Duration matches calculated time
6. HR clicks "Save"
7. System creates TimeSegment record
8. System confirms creation
9. Segment appears in list

**Postconditions**:
- TimeSegment created
- Available for use in Shift Definitions

**Business Rules**:
- BR-ATT-H01: Unique Segment Code
- BR-ATT-H02: Timing Method Exclusive (offset XOR absolute)
- BR-ATT-H03: Duration Must Match Calculated

**Example Data**:
```
Segment 1:
  Code: WORK_MORNING
  Type: WORK
  Method: RELATIVE
  Start Offset: 0 min
  End Offset: 240 min
  Duration: 240 min (4 hours)
  Is Paid: true

Segment 2:
  Code: LUNCH
  Type: MEAL
  Method: ABSOLUTE
  Start Time: 12:00
  End Time: 13:00
  Duration: 60 min
  Is Paid: false
```

---

### UC-ATT-H02: HR Configures Shift Definition (Level 2)

**Actor**: HR Administrator

**Preconditions**:
- Time Segments exist
- User has HR admin permission

**Trigger**: HR needs to create shift from segments

**Main Flow**:
1. HR navigates to Configuration → Shift Definitions
2. HR clicks "Create Shift"
3. System displays shift creation form
4. HR enters:
   - Code (e.g., "DAY_SHIFT")
   - Name (e.g., "Day Shift 8-5")
   - Shift Type: ELAPSED | PUNCH | FLEX
   - If ELAPSED:
     - Reference Start Time
     - Reference End Time
   - If PUNCH:
     - Grace In Minutes (e.g., 5)
     - Grace Out Minutes (e.g., 5)
     - Rounding Interval Minutes (e.g., 15)
     - Rounding Mode: NEAREST | UP | DOWN
   - Cross Midnight (checkbox)
   - Color (hex code for UI)
5. HR clicks "Add Segments"
6. System displays segment selection dialog
7. For each segment to add:
   a. HR selects segment from dropdown
   b. HR sets sequence order (1, 2, 3...)
   c. HR optionally overrides duration or isPaid
   d. HR clicks "Add"
8. System calculates totals:
   - Total Work Hours = sum of WORK segments
   - Total Break Hours = sum of BREAK + MEAL segments
   - Total Paid Hours = sum of paid segments
9. HR reviews segment composition
10. HR clicks "Save"
11. System validates:
    - At least one segment
    - Sequence order is sequential (no gaps)
    - Totals are correct
12. System creates ShiftDefinition and ShiftSegment records
13. System confirms creation

**Postconditions**:
- ShiftDefinition created
- ShiftSegment relationships created
- Available for use in Day Models

**Business Rules**:
- BR-ATT-H10: At Least One Segment Required
- BR-ATT-H11: Sequential Ordering Required
- BR-ATT-H12: Totals Must Match Segments

**Example Data**:
```
Shift: DAY_SHIFT
  Type: ELAPSED
  Reference: 08:00 - 17:00
  Segments:
    1. WORK_MORNING (4h)
    2. LUNCH (1h, unpaid)
    3. WORK_AFTERNOON (4h)
  Totals:
    Work: 8h
    Break: 1h
    Paid: 8h
```

---

### UC-ATT-H03: HR Configures Day Model (Level 3)

**Actor**: HR Administrator

**Preconditions**:
- Shift Definitions exist
- User has HR admin permission

**Trigger**: HR needs to define daily schedule templates

**Main Flow**:
1. HR navigates to Configuration → Day Models
2. HR clicks "Create Day Model"
3. System displays day model form
4. HR enters:
   - Code (e.g., "WORK_DAY", "OFF_DAY")
   - Name (e.g., "Standard Work Day", "Weekend")
   - Day Type: WORK | OFF | HOLIDAY | HALF_DAY
   - If WORK or HALF_DAY:
     - Select Shift Definition from dropdown
   - If HALF_DAY:
     - Half Day Period: MORNING | AFTERNOON
   - Variant Selection Rule (JSON, optional)
5. System validates:
   - WORK/HALF_DAY must have shift
   - OFF/HOLIDAY must NOT have shift
6. HR clicks "Save"
7. System creates DayModel record
8. System confirms creation

**Postconditions**:
- DayModel created
- Available for use in Patterns

**Business Rules**:
- BR-ATT-H20: Work Days Require Shift
- BR-ATT-H21: Off Days Cannot Have Shift
- BR-ATT-H22: Half Day Requires Period

**Example Data**:
```
Day Model 1:
  Code: STANDARD_WORK_DAY
  Type: WORK
  Shift: DAY_SHIFT

Day Model 2:
  Code: WEEKEND
  Type: OFF
  Shift: null
```

---

### UC-ATT-H04: HR Configures Pattern Template (Level 4)

**Actor**: HR Administrator

**Preconditions**:
- Day Models exist
- User has HR admin permission

**Trigger**: HR needs to create repeating work pattern

**Main Flow**:
1. HR navigates to Configuration → Pattern Templates
2. HR clicks "Create Pattern"
3. System displays pattern form
4. HR enters:
   - Code (e.g., "5X8", "4ON4OFF")
   - Name (e.g., "Five Day Week", "Four On Four Off")
   - Description
   - Cycle Length Days (e.g., 7, 8, 14, 28)
   - Rotation Type: FIXED | ROTATING
5. HR clicks "Define Pattern Days"
6. System displays calendar grid for cycle
7. For each day in cycle (1 to Cycle Length):
   a. HR selects Day Model from dropdown
   b. System assigns to day number
8. System validates:
   - All days in cycle have day model
   - Day numbers are sequential (1, 2, 3... to cycle length)
9. HR reviews pattern visualization
10. HR clicks "Save"
11. System creates PatternTemplate and PatternDay records
12. System confirms creation

**Postconditions**:
- PatternTemplate created
- PatternDay relationships created
- Available for use in Schedule Rules

**Business Rules**:
- BR-ATT-H30: All Cycle Days Must Be Defined
- BR-ATT-H31: Cycle Length Must Match Days
- BR-ATT-H32: Sequential Day Numbers

**Example Data**:
```
Pattern: 5X8
  Cycle Length: 7 days
  Rotation: FIXED
  Days:
    Day 1: STANDARD_WORK_DAY (Mon)
    Day 2: STANDARD_WORK_DAY (Tue)
    Day 3: STANDARD_WORK_DAY (Wed)
    Day 4: STANDARD_WORK_DAY (Thu)
    Day 5: STANDARD_WORK_DAY (Fri)
    Day 6: WEEKEND (Sat)
    Day 7: WEEKEND (Sun)
```

---

### UC-ATT-H05: Manager Creates Work Schedule Rule (Level 5)

**Actor**: Manager

**Preconditions**:
- Pattern Templates exist
- Holiday Calendars configured
- User has scheduling permission

**Trigger**: Manager needs to assign pattern to team

**Main Flow**:
1. Manager navigates to Scheduling → Schedule Rules
2. Manager clicks "Create Schedule Rule"
3. System displays rule form
4. Manager enters:
   - Code (e.g., "TEAM_A_5X8")
   - Name (e.g., "Team A Standard Schedule")
   - Select Pattern Template from dropdown
   - Select Holiday Calendar from dropdown
   - Start Reference Date (anchor point, e.g., "2025-01-01")
   - Offset Days (for rotation, e.g., 0, 7, 14)
   - Assignment Type: EMPLOYEE | GROUP | POSITION
   - If EMPLOYEE: Select employee
   - If GROUP: Select org unit/team
   - If POSITION: Select position
   - Effective Start Date
   - Effective End Date (optional)
5. System validates:
   - At least one assignment target
   - Start Reference Date is valid
   - No conflicting rules for same employees
6. Manager clicks "Save"
7. System creates ScheduleAssignment record
8. System confirms creation
9. Manager sees rule in list

**Postconditions**:
- ScheduleAssignment created
- Ready for roster generation
- Employees assigned to pattern

**Business Rules**:
- BR-ATT-H40: At Least One Assignment Target
- BR-ATT-H41: No Conflicting Rules
- BR-ATT-H42: Valid Date Range

**Example Data**:
```
Rule: TEAM_A_5X8
  Pattern: 5X8
  Calendar: VN_HOLIDAYS
  Start Reference: 2025-01-01 (Monday)
  Offset: 0 days
  Assigned To: Team A (all members)
  Effective: 2025-01-01 onwards
```

---

### UC-ATT-H06: System Generates Roster (Level 6)

**Actor**: System (automated or triggered by manager)

**Preconditions**:
- Schedule Rules exist
- Employees assigned to rules
- Date range specified

**Trigger**: 
- Scheduled batch job (nightly)
- Manager clicks "Generate Roster"
- New employee assigned to rule

**Main Flow**:
1. System identifies date range to generate (e.g., next 90 days)
2. System retrieves all active ScheduleAssignment records
3. For each Schedule Rule:
   a. System identifies assigned employees
   b. For each employee:
      i. For each date in range:
         - Calculate cycle day:
           ```
           daysSinceReference = (date - startReferenceDate)
           cycleDay = (daysSinceReference + offsetDays) % cycleLengthDays + 1
           ```
         - Get DayModel for cycle day from Pattern
         - Get Shift from DayModel
         - Check if date is in Holiday Calendar
         - If holiday:
           - Override day type to HOLIDAY
           - Set shift to null
         - Check for ScheduleOverride
         - If override exists:
           - Use override shift/day type
           - Set isOverride = true
         - Create/Update GeneratedRoster entry:
           - employeeId
           - workDate
           - scheduleRuleId (lineage)
           - patternId (lineage)
           - dayModelId (lineage)
           - shiftId
           - isOverride
           - isHoliday
           - statusCode = SCHEDULED
4. System commits all roster entries
5. System sends notifications to employees (schedule published)
6. System logs generation summary

**Postconditions**:
- GeneratedRoster entries created for all employees/dates
- Full lineage tracked
- Employees notified
- Roster ready for viewing

**Business Rules**:
- BR-ATT-H50: One Entry Per Employee Per Day
- BR-ATT-H51: Holiday Overrides Work Day
- BR-ATT-H52: Override Takes Precedence
- BR-ATT-H53: Full Lineage Tracking

**Example Output**:
```
Employee: Nguyễn Văn A
Date: 2025-01-06 (Monday)
Calculation:
  Days Since Ref: 5 days
  Cycle Day: (5 + 0) % 7 + 1 = 6
  Wait, let me recalculate:
  Start Ref: 2025-01-01 (Wed)
  Target: 2025-01-06 (Mon)
  Days: 5
  Cycle Day: (5 + 0) % 7 + 1 = 6
  Day Model: Day 6 = WEEKEND
  
Actually for Monday 2025-01-06:
  If 2025-01-01 is Day 1 (Wed)
  Then 2025-01-06 is Day 6 (Mon)
  Pattern day 6 = WEEKEND (Sat in normal week)
  
This shows importance of anchor date alignment!

Correct example:
Start Ref: 2025-01-06 (Monday) = Day 1
Target: 2025-01-06 (Monday)
Days: 0
Cycle Day: (0 + 0) % 7 + 1 = 1
Day Model: STANDARD_WORK_DAY
Shift: DAY_SHIFT
```

---

## Use Cases - Operations

### UC-ATT-001: Employee Clocks In/Out

**Actor**: Employee

**Preconditions**:
- Employee is active
- Time clock device is online
- Employee is registered in system
- **Generated Roster exists for employee/date**

**Trigger**: Employee arrives at/leaves workplace

**Main Flow (Clock In)**:
1. Employee approaches time clock device
2. Employee scans fingerprint/badge or uses mobile app
3. Device captures timestamp, location, device ID
4. Device sends clock-in event to system
5. **System finds GeneratedRoster entry for employee/date**
6. **System gets scheduled shift from roster entry**
7. System creates AttendanceRecord with clockInTime
8. System compares clockInTime with scheduledStartTime (from shift)
9. If late beyond grace period:
   - System creates TimeException (LATE_IN)
   - System calculates lateness in minutes
   - System sends notification to manager
10. System confirms clock-in to employee
11. Employee sees confirmation on device/app

**Main Flow (Clock Out)**:
1. Employee approaches time clock device
2. Employee scans fingerprint/badge or uses mobile app
3. Device captures timestamp
4. Device sends clock-out event to system
5. System finds AttendanceRecord for employee/date
6. System updates AttendanceRecord with clockOutTime
7. System calculates actual hours worked
8. System compares with scheduled hours (from roster)
9. If early departure:
   - System creates TimeException (EARLY_OUT)
10. System applies time rounding rules (from shift definition)
11. System sets attendance status (PRESENT, LATE, etc.)
12. System confirms clock-out to employee

**Postconditions**:
- AttendanceRecord created/updated
- Actual hours calculated
- Exceptions created if needed
- Manager notified of exceptions

**Business Rules**:
- BR-ATT-001: Cannot Clock In Twice
- BR-ATT-002: Grace Period Applied (from shift definition)
- BR-ATT-003: Time Rounding Applied (from shift definition)
- BR-ATT-004: Clock Out After Clock In

---

### UC-ATT-002: Employee Views Schedule

**Actor**: Employee

**Preconditions**:
- Employee is active
- Roster has been generated

**Trigger**: Employee wants to see their schedule

**Main Flow**:
1. Employee opens mobile app or web portal
2. Employee navigates to "My Schedule"
3. System retrieves GeneratedRoster entries for employee
4. System displays calendar view with:
   - Each day showing shift name and times
   - Color-coded by shift type
   - Icons for holidays, off days
   - Full lineage info (on click):
     - Which pattern is being used
     - Which schedule rule assigned it
     - Day model and shift details
5. Employee can:
   - View different date ranges
   - See shift details
   - Request shift swap
   - Bid for open shifts
6. Employee sees any schedule changes highlighted

**Postconditions**:
- Employee informed of schedule
- Can plan accordingly

---

### UC-ATT-003: Manager Creates Ad-hoc Override

**Actor**: Manager

**Preconditions**:
- Roster exists
- Manager has override permission

**Trigger**: Need to change schedule for specific date/employee

**Main Flow**:
1. Manager opens Schedule Management
2. Manager views generated roster
3. Manager selects employee and date to override
4. Manager clicks "Override"
5. System displays override form showing:
   - Current assignment (from pattern)
   - Override options
6. Manager selects:
   - New shift (from available shifts), OR
   - Mark as OFF, OR
   - Mark as HOLIDAY
7. Manager enters reason code
8. Manager adds notes (optional)
9. Manager clicks "Save Override"
10. System creates ScheduleOverride record
11. System updates GeneratedRoster entry:
    - isOverride = true
    - overrideId = new override ID
    - shiftId = new shift (or null)
12. System preserves original roster data (for audit)
13. System notifies employee of change
14. Employee sees updated schedule

**Postconditions**:
- Override created
- Roster updated
- Original data preserved
- Employee notified

**Business Rules**:
- BR-ATT-H60: Override Requires Reason
- BR-ATT-H61: Original Data Preserved
- BR-ATT-H62: Employee Must Be Notified

---

(Continue with existing use cases UC-ATT-003 through UC-ATT-005 from original file...)

---

## Business Rules

### Hierarchical Configuration Rules

#### BR-ATT-H01: Unique Segment Code
**Category**: Validation  
**Description**: Time segment code must be unique  
**Applies To**: TimeSegment creation  
**Error**: "Segment code '{code}' already exists"

#### BR-ATT-H02: Timing Method Exclusive
**Category**: Validation  
**Description**: Must use either offset OR absolute time, not both  
**Applies To**: TimeSegment creation  
**Logic**:
```
if (startOffsetMinutes != null AND startTime != null):
  return error "Cannot use both offset and absolute time"
```

#### BR-ATT-H10: At Least One Segment Required
**Category**: Validation  
**Description**: Shift must have at least one segment  
**Applies To**: ShiftDefinition creation  
**Error**: "Shift must have at least one time segment"

#### BR-ATT-H30: All Cycle Days Must Be Defined
**Category**: Validation  
**Description**: Pattern must have day model for every day in cycle  
**Applies To**: PatternTemplate creation  
**Logic**:
```
if (patternDays.count != cycleLengthDays):
  return error "Must define all {cycleLengthDays} days in cycle"
```

#### BR-ATT-H50: One Entry Per Employee Per Day
**Category**: Validation  
**Description**: Cannot have duplicate roster entries  
**Applies To**: Roster generation  
**Logic**:
```
if exists(employeeId, workDate):
  update existing entry
else:
  create new entry
```

#### BR-ATT-H51: Holiday Overrides Work Day
**Category**: Business Logic  
**Description**: If date is holiday, override day type regardless of pattern  
**Applies To**: Roster generation  
**Logic**:
```
if date in holidayCalendar:
  dayType = HOLIDAY
  shiftId = null
  isHoliday = true
```

### Operational Rules

(Keep existing BR-ATT-001 through BR-ATT-043 from original file...)

---

## Validation Rules

### Hierarchical Configuration Validations

#### Time Segment

| Field | Rule | Error Message |
|-------|------|---------------|
| code | Required, Unique | "Segment code is required and must be unique" |
| segmentType | Required, Enum | "Must be WORK, BREAK, MEAL, or TRANSFER" |
| durationMinutes | Required, > 0 | "Duration must be greater than 0" |
| timing | Offset XOR Absolute | "Use either offset or absolute time, not both" |

#### Shift Definition

| Field | Rule | Error Message |
|-------|------|---------------|
| code | Required, Unique | "Shift code is required and must be unique" |
| shiftType | Required, Enum | "Must be ELAPSED, PUNCH, or FLEX" |
| segments | At least 1 | "Shift must have at least one segment" |
| totalWorkHours | Must match segments | "Total work hours must match segment sum" |

#### Pattern Template

| Field | Rule | Error Message |
|-------|------|---------------|
| code | Required, Unique | "Pattern code is required and must be unique" |
| cycleLengthDays | Required, > 0 | "Cycle length must be greater than 0" |
| patternDays | Count = cycle length | "Must define all days in cycle" |

(Continue with existing validations...)

---

## State Transitions

### GeneratedRoster State Machine

| From State | Event | To State | Actions |
|------------|-------|----------|---------|
| - | generate | SCHEDULED | Create roster entry |
| SCHEDULED | publish | CONFIRMED | Lock for employee view |
| CONFIRMED | complete | COMPLETED | After date passes |
| SCHEDULED | override | SCHEDULED | Update with override |
| SCHEDULED | cancel | CANCELLED | Cancel shift |

(Keep existing state machines...)

---

## Error Codes

### Hierarchical Configuration Errors

| Code | Message | HTTP Status |
|------|---------|-------------|
| TA_ATT_H01 | "Segment code already exists" | 409 |
| TA_ATT_H02 | "Invalid timing method" | 400 |
| TA_ATT_H03 | "Duration mismatch" | 400 |
| TA_ATT_H10 | "Shift must have segments" | 400 |
| TA_ATT_H11 | "Invalid segment sequence" | 400 |
| TA_ATT_H20 | "Work day requires shift" | 400 |
| TA_ATT_H30 | "Incomplete pattern cycle" | 400 |
| TA_ATT_H40 | "No assignment target" | 400 |
| TA_ATT_H50 | "Duplicate roster entry" | 409 |

(Keep existing error codes...)

---

## Related Documents

- [Behaviour Overview](./00-TA-behaviour-overview.md)
- [Concept Overview](../01-concept/01-concept-overview.md)
- [Conceptual Guide](../01-concept/02-conceptual-guide.md)
- [Time & Attendance Ontology](../00-ontology/time-attendance-ontology.yaml) v2.0
- [Time & Attendance Glossary](../00-ontology/time-attendance-glossary.md) v2.0
- [Database Design](../03-design/TA-database-design-v5.dbml)
- [Hierarchical Model Migration Summary](../00-ontology/HIERARCHICAL-MODEL-MIGRATION-SUMMARY.md)

---

**Approval**

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Business Analyst | | | |
| Tech Lead | | | |
| Product Owner | | | |
