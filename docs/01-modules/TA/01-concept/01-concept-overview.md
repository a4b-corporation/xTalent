# Time & Absence Management - Concept Overview

## What is this module?

> The Time & Absence Management module is a comprehensive solution for managing employee leave, attendance tracking, shift scheduling, and time recording. It enables employees to request time off and log work hours, managers to approve requests and manage schedules, and HR to configure policies and ensure compliance.

The module consists of two integrated sub-modules:
- **Absence Management**: Leave requests, balance tracking, and policy enforcement
- **Time & Attendance**: Shift scheduling, time tracking, attendance recording, and overtime management

---

## Problem Statement

### What problem does this solve?

**Absence Management Challenges**:
- Employees need a simple way to request time off and track their leave balance
- Managers need visibility into team absences for resource planning
- HR needs to enforce leave policies consistently across the organization
- The organization needs accurate leave data for payroll and compliance reporting

**Time & Attendance Challenges**:
- Organizations need to track when employees work and ensure accurate time recording
- Managers need to create and manage shift schedules efficiently
- Employees need flexibility to swap shifts or bid for available shifts
- Payroll needs accurate time data to calculate wages, especially overtime
- Compliance requires proper tracking of work hours and rest periods

### Who are the users?

**Employees**:
- Request leave and view balance
- Clock in/out for attendance
- Submit timesheets for project work
- Request shift swaps
- Bid for open shifts
- Request overtime approval

**Managers**:
- Approve/reject leave requests
- Review attendance exceptions
- Create and publish shift schedules
- Approve timesheets and overtime
- View team calendars and coverage

**HR Administrators**:
- Configure leave types and policies
- Set up shift patterns and schedules
- Define overtime rules
- Manage exceptions and violations
- Generate compliance reports

**Payroll**:
- Access leave data for unpaid leave deductions
- Retrieve time and attendance data for wage calculation
- Process overtime payments

---

## High-Level Solution

### How does this module solve the problem?

**Absence Management Solution**:

The system provides a self-service portal where employees can:
1. View their available leave balance across different leave types
2. Submit leave requests with dates, duration, and reason
3. Track approval status in real-time
4. View their leave history and upcoming absences

Managers receive notifications and can:
1. Review requests with full context (team calendar, leave balance, policy rules)
2. Approve or reject requests with comments
3. View team absence patterns and coverage gaps
4. Manage blackout periods

HR can:
1. Configure leave types (Annual, Sick, Maternity, etc.) with specific rules
2. Set up flexible policy rules (eligibility, accrual, carryover, limits)
3. Define approval workflows
4. Generate reports and analytics

**Time & Attendance Solution**:

The system enables efficient workforce management through:

Employees can:
1. Clock in/out via time clock devices or mobile app
2. Submit detailed timesheets for project work
3. Request shift swaps with colleagues
4. Bid for available shifts
5. Request overtime pre-approval

Managers can:
1. Create shift patterns and schedules
2. Publish schedules to teams
3. Review and excuse attendance exceptions
4. Approve shift swaps and overtime requests
5. Monitor attendance compliance

HR can:
1. Define shift patterns (Day, Night, Rotating)
2. Configure overtime rules and multipliers
3. Set up time rounding and grace periods
4. Track exceptions and violations
5. Generate attendance and overtime reports

---

## Scope

### What's included?

**Absence Management** ✅:
- Leave type and class configuration
- Flexible rule system (Eligibility, Validation, Accrual, Carryover, Limits, Overdraft, Proration, Rounding)
- Leave request creation and submission
- Multi-level approval workflow
- Leave balance tracking with ledger
- Reservation system (prevents double-booking)
- Period profiles (Calendar year, Fiscal year, Hire anniversary)
- Holiday calendar management
- Email notifications
- Reporting and analytics

**Time & Attendance** ✅:
- Shift pattern configuration
- Schedule creation and publishing
- Time clock integration (biometric, RFID, mobile)
- Attendance tracking with clock in/out
- Timesheet entry and approval
- Project/task time allocation
- Attendance exception management
- Shift swap and bidding
- Overtime rules and calculation
- Grace period and rounding rules
- Reporting and compliance tracking

**Shared Components** ✅:
- Working schedule definition
- Holiday calendar
- Period profiles
- Event-driven notifications
- Audit trail

### What's NOT included?

❌ Payroll calculation (handled by Payroll module)
❌ Performance reviews
❌ Benefits administration
❌ Recruitment and onboarding
❌ Learning and development
❌ Project management (though time can be allocated to projects)
❌ Expense management

---

## Key Concepts

### Absence Management Concepts

#### Leave Class
High-level categorization of leave types (e.g., Paid Time Off, Unpaid Leave, Statutory Leave) used to group similar leave types for applying common policies.

#### Leave Type
Specific categories of leave (Annual, Sick, Maternity, etc.), each with its own rules, balance tracking, and approval requirements.

#### Leave Rules
Independent, reusable rules that govern leave behavior:
- **Eligibility**: Who can use this leave type
- **Validation**: Request validation (advance notice, max days, blackout periods)
- **Accrual**: How leave is earned over time
- **Carryover**: Handling unused leave at period end
- **Limits**: Usage restrictions
- **Overdraft**: Negative balance allowance
- **Proration**: Partial period calculations
- **Rounding**: Fractional day handling

#### Leave Balance
The amount of leave available to an employee for each leave type, calculated as:
```
Available = Total Allocated + Carried Over - Used - Pending - Expired
```

#### Leave Movement
Immutable ledger entries recording all balance changes (allocation, accrual, usage, adjustment, carryover, expiry).

#### Policy Library
UI concept (not a database entity) for managing and binding rules to leave types or classes with priority-based resolution.

### Time & Attendance Concepts

Time & Attendance uses a **6-level hierarchical architecture** that builds complex schedules from simple atomic components:

```
Level 1: Time Segment (atomic unit)
    ↓
Level 2: Shift Definition (composition of segments)
    ↓
Level 3: Day Model (daily schedule)
    ↓
Level 4: Pattern Template (cycle of days)
    ↓
Level 5: Work Schedule Rule (pattern + calendar + rotation)
    ↓
Level 6: Generated Roster (materialized assignment)
```

#### Level 1: Time Segment
**Atomic building block** of work time. Represents the smallest schedulable unit:
- **WORK** - Productive work time (paid)
- **BREAK** - Short rest periods (typically unpaid)
- **MEAL** - Meal breaks (unpaid)
- **TRANSFER** - Time moving between work locations

Can be defined with **relative timing** (offset from shift start) or **absolute timing** (fixed clock time).

**Example**: "Work Morning: 0-240 minutes from shift start" or "Lunch: 12:00-13:00"

#### Level 2: Shift Definition
**Composition of time segments** forming a complete shift. Three types:
- **ELAPSED** - Fixed schedule (segments define exact timing)
- **PUNCH** - Flexible clock-based (grace periods, rounding rules)
- **FLEX** - Hybrid (core hours + flexible start/end)

**Example**: Day Shift = Work(4h) + Lunch(1h) + Work(4h)

#### Level 3: Day Model
**Daily work schedule** template. Defines what happens on one day:
- **WORK** - Work day (links to a shift)
- **OFF** - Rest day
- **HOLIDAY** - Public holiday
- **HALF_DAY** - Partial work day

**Example**: "Standard Work Day" uses "Day Shift", "Weekend" uses null (OFF)

#### Level 4: Pattern Template
**Repeating cycle** of day models. Represents work patterns:
- **5x8** - 5 days work, 2 days off (7-day cycle)
- **4on-4off** - 4 days work, 4 days off (8-day cycle)
- **14/14 rotation** - 14 days work, 14 days off (28-day cycle)

**Example**: [WorkDay, WorkDay, WorkDay, WorkDay, WorkDay, OffDay, OffDay] repeats weekly

#### Level 5: Work Schedule Rule
**Combines pattern with calendar and rotation** to define WHO gets WHICH pattern:
- Links pattern to holiday calendar
- Sets rotation offset for crews (Crew A: offset=0, Crew B: offset=7)
- Assigns to employee, group, or position
- Defines effective dates

**Example**: "Team A gets 5x8 pattern starting Jan 1, using VN calendar, no offset"

#### Level 6: Generated Roster
**Materialized result** - one row per employee per day. Shows:
- Which shift employee works on specific date
- Full lineage (rule → pattern → day model → shift)
- Override handling
- Holiday handling
- Status (SCHEDULED, CONFIRMED, COMPLETED)

**Example**: "Employee A works Day Shift on 2025-01-06 (Monday) per Team A rule"

---

**Additional Concepts**:

#### Attendance Record
Daily record of **actual time worked**, including clock in/out times, calculated hours, and status (Present, Late, Absent).

#### Time Exception
Deviations from expected attendance (late arrival, early departure, missing punch, unauthorized absence).

#### Timesheet Entry
Detailed time allocation to projects, tasks, or work types, supporting billable/non-billable categorization.

#### Overtime
Work hours exceeding standard thresholds, calculated based on multiple rule types (daily, weekly, holiday) with different pay multipliers.

#### Shift Swap
Process allowing two employees to exchange their assigned shifts with manager approval.

### Shared Concepts

#### Period Profile
Defines time periods for leave years or pay periods (Calendar year, Fiscal year, Hire anniversary, Custom).

#### Holiday
Public or company holidays that don't count as working days for leave calculations or attendance.

#### Working Schedule
Defines which days are working days and standard hours, used for calculating working days in leave requests and attendance.

---

## Business Value

### Benefits

**Efficiency**:
- Reduces time spent on manual leave processing by 80%
- Automates attendance tracking and eliminates paper timesheets
- Streamlines shift scheduling and reduces scheduling conflicts
- Enables employee self-service for leave and time management

**Accuracy**:
- Eliminates errors in leave balance calculations through automated ledger
- Ensures accurate time tracking with integrated time clocks
- Prevents double-booking through reservation system
- Calculates overtime automatically based on configured rules

**Compliance**:
- Enforces leave policies consistently across the organization
- Tracks work hours for labor law compliance
- Maintains complete audit trail for all transactions
- Generates compliance reports for regulatory requirements

**Visibility**:
- Provides real-time insights into team absences and coverage
- Displays attendance patterns and exception trends
- Shows overtime costs and utilization
- Enables data-driven workforce planning

**Employee Satisfaction**:
- Empowers employees with self-service capabilities
- Provides transparency in leave balances and approvals
- Offers flexibility through shift swaps and bidding
- Reduces administrative burden

**Cost Control**:
- Monitors and controls overtime expenses
- Optimizes shift coverage to reduce overstaffing
- Identifies attendance issues early
- Reduces payroll errors and corrections

### Success Metrics

**Absence Management**:
- 90% of leave requests processed within 24 hours
- 95% reduction in leave balance calculation errors
- 100% policy compliance
- 85% employee satisfaction score for leave management
- 50% reduction in HR time spent on leave administration

**Time & Attendance**:
- 99% attendance tracking accuracy
- 80% reduction in timesheet processing time
- 90% schedule adherence rate
- 30% reduction in overtime costs through better planning
- 95% reduction in payroll errors related to time data

---

## Integration Points

**Core HR (CO)**:
- Uses worker, assignment, and organization data
- Validates employee status and reporting relationships
- Provides organizational hierarchy for approvals

**Payroll (PR)**:
- Provides leave data for unpaid leave deductions
- Sends time and attendance data for wage calculation
- Transfers overtime hours for premium pay processing

**Total Rewards (TR)**:
- Receives overtime data for compensation calculation
- Applies shift differentials and premiums

**Calendar Systems**:
- Syncs approved leave to employee calendars (Google, Outlook)
- Publishes shift schedules to calendars

**Time Clock Devices**:
- Integrates with biometric and RFID time clocks
- Receives clock in/out events in real-time

**Mobile Apps**:
- Provides mobile time tracking and attendance
- Enables mobile leave requests and approvals
- Supports mobile shift viewing and swapping

**Project Management**:
- Receives timesheet data for project costing
- Validates project/task codes for time allocation

**Email/Notification Systems**:
- Sends notifications for requests, approvals, exceptions
- Delivers schedule changes and reminders

---

## Assumptions & Dependencies

### Assumptions

**Absence Management**:
- Workers have email addresses for notifications
- Managers have authority to approve leave for their direct reports
- Leave policies are defined at legal entity or organizational level
- Leave year structure is configurable (not hardcoded to calendar year)
- Employees understand their leave entitlements

**Time & Attendance**:
- Employees have access to time clock devices or mobile apps
- Shift schedules are published in advance (configurable lead time)
- Managers review and approve timesheets regularly
- Overtime requires pre-approval (configurable)
- Time clock devices are properly synchronized

**Shared**:
- Working schedules and holidays are configured before use
- System time is accurate and synchronized
- Network connectivity is available for real-time updates

### Dependencies

**Required**:
- Core HR module for worker and organization data
- Authentication/authorization system
- Email service for notifications
- Database for data persistence

**Optional**:
- Time clock hardware/software
- Mobile app platform
- Calendar integration services
- Project management system
- Payroll system

---

## Future Enhancements

**Absence Management**:
- AI-powered leave prediction and planning
- Advanced analytics and forecasting
- Automated leave accrual optimization
- Integration with wellness programs
- Leave donation/sharing programs

**Time & Attendance**:
- AI-based schedule optimization
- Predictive attendance analytics
- Facial recognition for time clocks
- Geofencing for mobile clock-in
- Real-time labor cost tracking
- Fatigue management and rest period enforcement
- Integration with building access systems

**Shared**:
- Advanced mobile capabilities
- Voice-activated requests and queries
- Chatbot for common questions
- Advanced workforce analytics
- Predictive staffing recommendations

---

## Glossary

| Term | Definition |
|------|------------|
| **Accrual** | The process of earning leave over time (e.g., 1.67 days per month) |
| **Carryover** | Unused leave transferred from one period to the next |
| **Pending** | Leave requested but not yet approved, reducing available balance |
| **Available** | Leave that can be requested right now |
| **Reservation** | Temporary hold on balance while request is pending |
| **Movement** | Ledger entry recording a balance change |
| **Time Segment** | Atomic unit of work time (WORK, BREAK, MEAL, TRANSFER) |
| **Shift Definition** | Composition of time segments forming a complete shift |
| **Day Model** | Daily work schedule template (WORK, OFF, HOLIDAY, HALF_DAY) |
| **Pattern Template** | Repeating cycle of day models (e.g., 5x8, 4on-4off) |
| **Work Schedule Rule** | Pattern + calendar + rotation offset defining WHO gets WHICH pattern |
| **Generated Roster** | Materialized schedule showing employee assignments per day |
| **ELAPSED Shift** | Fixed schedule shift with exact segment timing |
| **PUNCH Shift** | Flexible clock-based shift with grace periods |
| **FLEX Shift** | Hybrid shift with core hours + flexible start/end |
| **Clock In/Out** | Recording start and end of work time |
| **Grace Period** | Allowed lateness without penalty |
| **Shift Swap** | Exchange of shifts between two employees |
| **Overtime** | Work hours exceeding standard thresholds |
| **Time Exception** | Deviation from expected attendance |
| **Timesheet** | Detailed record of time worked on projects/tasks |
| **Shift Differential** | Premium pay for specific shifts (e.g., night shift) |
| **Rotation Offset** | Days offset for rotating crews (Crew A=0, B=7, C=14) |
| **Cycle Length** | Number of days in pattern before it repeats |

---

## Related Documents

- [Conceptual Guide](./02-conceptual-guide.md) - How the system works
- [Absence Ontology](../00-ontology/absence-ontology.yaml) - Absence domain model
- [Time & Attendance Ontology](../00-ontology/time-attendance-ontology.yaml) - T&A domain model
- [Absence Glossary](../00-ontology/absence-glossary.md) - Absence terminology
- [Time & Attendance Glossary](../00-ontology/time-attendance-glossary.md) - T&A terminology
- [Module Summary](../00-ontology/TA-MODULE-SUMMARY.yaml) - Complete module overview
- [Specifications](../02-spec/) - Detailed requirements

---

**Document Version**: 2.0  
**Last Updated**: 2025-12-01  
**Author**: xTalent Documentation Team  
**Reviewers**: [To be assigned]  
**Architecture**: 6-Level Hierarchical Model (Time & Attendance)

**Version History**:
- v2.0 (2025-12-01): Updated Time & Attendance to 6-level hierarchical architecture
- v1.0 (2025-12-01): Initial version with flat model
