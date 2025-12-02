# Time & Absence (TA) Module

> Comprehensive time and absence management including leave, attendance, and scheduling

## 📋 Overview

The Time & Absence module manages all aspects of employee time:
- **Leave Management**: Leave requests, approvals, and balance tracking
- **Attendance**: Time in/out tracking and attendance records
- **Time Tracking**: Work hours, overtime, and time sheets
- **Scheduling**: Shift planning and schedule management

## 📁 Documentation Structure

```
TA/
├── 00-ontology/       # Domain entities (TimeType, TimeEvent, TimeBalance, etc.)
├── 01-concept/        # What Time & Absence does and why
├── 02-spec/           # Detailed specifications
├── 03-design/         # Data model and system design
├── 04-api/            # API specifications
├── 05-ui/             # UI specs and mockups
├── 06-tests/          # Test scenarios
└── 07-impl-notes/     # Technical decisions
```

## 🎯 Key Features

### Leave Management
- Leave type configuration (Annual, Sick, Unpaid, etc.)
- Leave request submission and approval workflow
- Leave balance tracking and accrual
- Carryover management
- Leave calendar and team visibility

### Attendance Tracking
- Clock in/out functionality
- Attendance records
- Late/early tracking
- Absence recording

### Time Tracking
- Time sheet management
- Work hours tracking
- Overtime calculation
- Project/task time allocation

### Scheduling
- Shift definition and management
- Schedule creation and assignment
- Shift swaps and changes
- Schedule conflicts detection

## 🔗 Integration Points

- **CO (Core HR)**: Uses worker and organization data
- **TR (Total Rewards)**: Provides overtime data for compensation
- **PR (Payroll)**: Provides time and attendance data for payroll
- **Calendar Systems**: Syncs leave and schedules to external calendars

## 📚 Key Entities

### Absence Management
| Entity | Description |
|--------|-------------|
| **LeaveClass** | High-level classification (Paid, Unpaid, Statutory) |
| **LeaveType** | Specific leave type (Annual, Sick, Maternity) |
| **LeaveRule** | Reusable rules (Eligibility, Accrual, Validation) |
| **LeaveRequest** | Employee request for time off |
| **LeaveBalance** | Current balance tracking for a user/type |
| **LeaveMovement** | Immutable ledger entry for balance changes |

### Time & Attendance
| Entity | Description |
|--------|-------------|
| **ShiftPattern** | Reusable shift template (Day, Night, Rotating) |
| **Shift** | Actual shift assignment for a worker |
| **Schedule** | Master schedule for team/department |
| **AttendanceRecord** | Daily attendance with clock in/out |
| **TimesheetEntry** | Detailed time entry for work/projects |
| **TimeException** | Attendance exceptions (late, missing punch) |
| **ShiftSwapRequest** | Request to swap shifts between workers |
| **OvertimeRequest** | Request for pre-approved overtime |

### Shared
| Entity | Description |
|--------|-------------|
| **PeriodProfile** | Time period definition (pay period, leave year) |
| **Holiday** | Public or company holidays |

## 🎨 Sub-modules

### Absence
- Leave type library
- Leave class configuration
- Rule management (Policy Library)
- Leave request workflow
- Balance tracking

### Time & Attendance
- Shift pattern management
- Schedule creation and publishing
- Time clock integration
- Attendance tracking and exceptions
- Timesheet entry and approval
- Shift swap and bidding
- Overtime management

### Scheduling
- Shift patterns
- Schedule templates
- Schedule assignment
- Shift bidding
- Coverage management

### Reporting
- Attendance reports
- Timesheet summaries
- Exception reports
- Overtime analysis
- Compliance reporting

## 🚀 Getting Started

1. **Understand the Domain**: Read `00-ontology/` and `01-concept/`
2. **Review Specifications**: Check `02-spec/` for detailed requirements
3. **Explore API**: See `04-api/` for API documentation
4. **View UI**: Check `05-ui/` for UI specifications

## 📖 Related Documents

- [Global Ontology](../../00-global/ontology/time-absence-core.yaml)
- [Domain Glossary](../../00-global/glossary/domain-glossary.md)
- [SpecKit Guide](../../00-global/speckit/spec-structure.md)

## 💡 Common Scenarios

### Employee Requests Leave
1. Employee views available balance
2. Submits leave request with dates
3. System validates balance and conflicts
4. Manager receives notification
5. Manager approves/rejects
6. Balance updated automatically

### Manager Views Team Absences
1. Manager opens team calendar
2. Sees all approved and pending leave
3. Can filter by date range, leave type
4. Can approve pending requests

### HR Configures Leave Type
1. HR creates new leave type
2. Defines rules (paid, max days, carryover)
3. Assigns to worker groups
4. System creates balances automatically

### Worker Clocks In/Out
1. Worker arrives at workplace
2. Clocks in via time clock/mobile app
3. System records time and location
4. Worker clocks out at end of shift
5. System calculates actual hours worked
6. Attendance record created automatically

### Manager Reviews Attendance Exceptions
1. Manager opens attendance dashboard
2. Views exceptions (late, early departure, missing punch)
3. Reviews worker explanations
4. Excuses valid exceptions
5. Flags violations for follow-up

### Worker Submits Timesheet
1. Worker logs time for projects/tasks
2. Categorizes time (regular, overtime, billable)
3. Adds descriptions and notes
4. Submits timesheet for approval
5. Manager reviews and approves
6. Data flows to payroll

### Worker Requests Shift Swap
1. Worker finds colleague to swap with
2. Creates swap request in system
3. Target worker accepts swap
4. Manager receives notification
5. Manager approves swap
6. Schedule automatically updated

### Manager Creates Weekly Schedule
1. Manager selects shift patterns
2. Assigns workers to shifts
3. System checks for conflicts
4. Publishes schedule
5. Workers receive notifications
6. Workers can bid for open shifts

---

**Module Owner**: [Team/Person]  
**Last Updated**: 2025-11-28
