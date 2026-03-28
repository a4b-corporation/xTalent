# Menu Map: Time & Absence

**Module:** xTalent HCM — Time & Absence
**Step:** 5 — Product Experience Design
**Date:** 2026-03-25
**Version:** 1.0

---

## Design Principles

1. **Task-first grouping:** Navigation groups reflect what users need to accomplish, not the domain entity model.
2. **H5 Calendar-first:** The team leave calendar is the primary navigation anchor for Managers; it is the first item in their main view.
3. **H6 Mobile-first:** Employee navigation is optimized for a 5-inch screen; Clock In/Out is always one tap from the home screen.
4. **Role-based visibility:** Menu items not relevant to a role are hidden entirely, not disabled.
5. **P1 items labeled:** Features delivered in V1 (not MVP) are marked `(P1)` for implementation sequencing.

---

## Employee Navigation

```
Home Dashboard
├── My Leave Balances [ABS-T-004]          ← Balance widget, all leave types
├── Upcoming Leaves [ABS-T-001]            ← Next 30 days leave list
├── Pending Approvals (count badge)        ← Only cancellation requests needing mgr
└── Comp Time Expiry Alert [ATT-T-006] (P1) ← H-P0-002: badge if expiring soon

Leave
├── Request Leave [ABS-T-001]              ← Primary employee action
├── My Leave Requests [ABS-T-001]          ← Full history with status
├── My Balances [ABS-T-004]                ← Detailed per-type breakdown
├── Leave Calendar [ABS-T-007] (P1)        ← H5: my leaves + team overlay view
└── Leave Reservations [ABS-T-009] (P1)    ← Pending approval holds view

Attendance
├── Clock In / Clock Out [ATT-T-001]       ← H6: Mobile primary action (hero button)
├── My Punch History [ATT-T-001]           ← Daily punch log
├── My Timesheets [ATT-T-004]              ← Current + past period timesheets
├── Overtime Requests [ATT-T-003]          ← My OT requests + status
└── Comp Time Balance [ATT-T-006] (P1)     ← H-P0-002: balance + expiry dates

My Profile (read-only)
└── My Shift Assignment [ATT-M-001] (P1)   ← View only; changes made by HR Admin
```

---

## Manager Navigation

```
Dashboard                                  ← H5: Calendar-first default landing
├── Team Availability Calendar [ABS-T-007] ← Team leave overlay — central anchor (H5)
├── Pending Approvals Queue                ← Leave + OT + Timesheet counts
├── OT Cap Alerts (badge) [ATT-T-003]      ← Employees near monthly/annual cap
└── Team Absence Today                     ← Quick count of who is out today

Approvals
├── Leave Requests [ABS-T-002]             ← Approve / Reject list with employee context
├── Leave Cancellations [ABS-T-003]        ← H-P0-001: post-deadline cancels requiring approval
├── Overtime Requests [ATT-T-003]          ← H-P0-003: includes skip-level routed items
└── Timesheets [ATT-T-008]                 ← Period-end timesheet review queue

Team
├── Team Leave Calendar [ABS-T-007] (P1)   ← Full team calendar, filter by member
├── Team Attendance [ATT-T-001]            ← Today's punch status per team member
├── Bradford Factor [SHD-A-002] (P1)       ← Absence pattern scoring
└── Delegate Approvals [SHD-T-007] (P1)    ← Set delegation during own absence

My Requests (Manager as Employee)
├── Request Leave [ABS-T-001]              ← Manager can also submit leave
├── Request Overtime [ATT-T-003]           ← H-P0-003: routes to skip-level automatically
└── My Timesheet [ATT-T-004]               ← Manager submits own timesheet
```

---

## HR Administrator Navigation

```
Configuration
├── Leave Types [ABS-M-001]                ← P0 config
├── Leave Policies [ABS-M-002]             ← P0 config; links to accrual plans
├── Accrual Plans [ABS-M-003]              ← P0 config; complex but critical
├── Leave Classes [ABS-M-004] (P1)         ← Group leave types for reporting
├── Carry-Over Rules [ABS-M-005] (P1)      ← Year-end treatment per leave type
├── Holiday Calendar [SHD-M-001]           ← Country × year config
├── Shifts [ATT-M-001] (P1)               ← Work pattern templates
├── Geofence Zones [ATT-M-002] (P1)       ← Work location polygons
└── Approval Workflows [SHD-T-001]         ← Chain config: levels, escalation, skip-level

Operations
├── Accrual Batch Run [ABS-T-006]          ← Monthly trigger + status monitor
├── Period Management [SHD-T-002]          ← Open / Lock / Close payroll periods
├── Comp Time Expiry Management [ATT-T-006] (P1) ← H-P0-002: review upcoming expirations
└── Termination Balance Review [SHD-T-008] (P1) ← H-P0-004: negative balance actions

Employees
├── Employee Leave Summary                 ← Quick lookup per employee
└── Shift Assignments [ATT-M-001] (P1)    ← Assign shifts to employees

Reports
├── Leave Balance Report [SHD-A-001] (P1)  ← Export by type, dept, date range
└── Bradford Factor [SHD-A-002] (P1)       ← Absence pattern analytics
```

---

## Payroll Officer Navigation

```
Payroll Processing
├── Period Close [SHD-T-002]               ← Lock → Validate → Close workflow
├── Payroll Export [SHD-T-003]             ← Download / re-trigger export package
├── Terminated Employees — Balance Review [SHD-T-008] ← H-P0-004: negative balance
└── Export History                         ← Audit trail of past exports

Reports
└── Leave Balance Report [SHD-A-001] (P1)  ← Read-only view for payroll reconciliation
```

---

## System Admin Navigation

```
Settings
├── Tenant Configuration                   ← Global settings; data region (read-only post-setup)
├── Holiday Calendar [SHD-M-001]           ← Country-year master; can delegate to HR Admin
├── Geofence Configuration [ATT-M-002] (P1) ← Work location setup
├── Notification Templates [SHD-T-009] (P2) ← Email/push message templates
└── Integration Settings [SHD-T-004]       ← Employee Central connection health

User Management (cross-module)
└── Role Assignments                        ← Assign Employee / Manager / HR Admin roles
```

---

## Mobile-Specific Navigation (Employee App)

The mobile app presents a simplified tab bar optimized for the Employee persona:

```
Bottom Tab Bar:
[Home] [Leave] [Clock] [Timesheet] [Profile]
         ↑ active = Center tap = Clock In/Out (H6 primary action)

Home tab:
  - Leave balance cards (swipeable by type)
  - Today's schedule / shift
  - Comp time expiry alert (H-P0-002)

Clock tab (primary CTA):
  - Large Clock In / Clock Out button
  - Current punch status (IN / OUT)
  - Sync status indicator: SYNCED (green) / PENDING (clock) / CONFLICT (warning)
  - Last punch time + location

Leave tab:
  - Quick balance view
  - Request Leave (floating action button)
  - Request history

Timesheet tab:
  - Current period summary
  - Submit button (at period end)

Profile tab:
  - My details (read-only)
  - Notifications settings
  - App version / logout
```

---

## Full Menu Structure: Time & Absence Module

This section consolidates all menu items into a single reference structure, organized by functional category rather than role. This view is useful for implementation planning and permission matrix mapping.

### CONFIGS (Masterdata — HR Admin / BA)

Configuration features set up during tenant onboarding or policy changes. These define system behavior and are maintained infrequently.

```
Configs
│
├── Absence Configuration
│   ├── Leave Types [ABS-M-001]              ← P0: Core leave category setup
│   ├── Leave Policies [ABS-M-002]           ← P0: Policy rules per country/dept
│   ├── Accrual Plans [ABS-M-003]            ← P0: How balance accrues over time
│   ├── Leave Classes [ABS-M-004] (P1)       ← Group leave types for reporting
│   └── Carry-Over Rules [ABS-M-005] (P1)    ← Year-end balance treatment
│
├── Time Configuration
│   ├── Shift Definitions [ATT-M-001] (P1)   ← Work pattern templates
│   └── Geofence Zones [ATT-M-002] (P1)      ← Work location polygons
│
└── Shared Configuration
    ├── Holiday Calendar [SHD-M-001]         ← Country × year master data
    └── Approval Workflow Chains [SHD-T-001] ← Multi-level routing rules
```

### SETTINGS (System Admin)

System-wide settings managed by IT/System Admin. These are tenant-level configurations that rarely change after initial setup.

```
Settings
│
├── Tenant Configuration
│   ├── Data Region / Tenant Info            ← Read-only post-setup
│   └── Integration Settings [SHD-T-004]     ← Employee Central connection health
│
├── Device Management [TA_DEVICE_MGMT] (P1)
│   ├── Device Registration
│   ├── Device Sync Status
│   └── Device Vendor Configuration
│
├── Geofence Enforcement [ATT-M-002] (P1)
│   ├── Zone Mapping
│   └── Enforcement Rules (STRICT/WARN/LOG)
│
└── Notification Templates [SHD-T-009] (P2)
    └── Email/Push message templates
```

### REPORTS & ANALYTICS

Read-only dashboards and export features for compliance and insights.

```
Reports & Analytics
│
├── Absence Reports
│   ├── Leave Balance Report [SHD-A-001] (P1)    ← Export by type, dept, date range
│   └── Bradford Factor [SHD-A-002] (P1)         ← Absence pattern scoring
│
├── Time Reports
│   ├── OT Compliance Report [ATT-A-001] (P2)    ← VLC Art. 107 cap utilization
│   └── Timesheet History Report (P1)            ← Period archival view
│
└── System Reports
    ├── Accrual Batch Run History [ABS-T-006]    ← Batch execution audit
    └── Export History [SHD-T-003]               ← Payroll export audit trail
```

### TRANSACTIONS — Absence (ta.absence)

Employee and manager-facing leave workflows.

```
Absence
│
├── My Leave (Employee)
│   ├── Request Leave [ABS-T-001]              ← Submit new leave request
│   ├── My Leave Requests [ABS-T-001]          ← View + cancel pending
│   ├── My Balances [ABS-T-004]                ← Balance dashboard + history
│   ├── Leave Calendar [ABS-T-007] (P1)        ← Personal + team overlay
│   └── Leave Reservations [ABS-T-009] (P1)    ← Pending approval holds
│
├── Team Leave (Manager)
│   ├── Team Availability Calendar [ABS-T-007] ← Dashboard default (H5)
│   ├── Leave Approvals [ABS-T-002]            ← Approve / Reject queue
│   ├── Leave Cancellations [ABS-T-003]        ← Post-deadline approval (H-P0-001)
│   └── Team Leave Calendar [ABS-T-007] (P1)   ← Filterable team view
│
└── System Processes
    ├── Accrual Batch Run [ABS-T-006]          ← Monthly trigger + monitoring
    └── Accrual Simulation [ABS-T-008] (P1)    ← What-if projection tool
```

### TRANSACTIONS — Time (ta.attendance)

Punch, overtime, and timesheet workflows.

```
Time
│
├── My Time (Employee)
│   ├── Clock In / Out [ATT-T-001]             ← Primary action (H6)
│   ├── My Punch History [ATT-T-001]           ← Daily log
│   ├── My Timesheets [ATT-T-004]              ← Submit + view history
│   ├── Overtime Requests [ATT-T-003]          ← Submit + track status
│   └── Comp Time Balance [ATT-T-006] (P1)     ← Balance + expiry dates
│
├── Team Time (Manager)
│   ├── Team Attendance [ATT-T-001]            ← Today's punch status
│   ├── OT Cap Alerts [ATT-T-003]              ← Employees near cap (badge)
│   ├── Overtime Approvals [ATT-T-003]         ← Approve / Reject queue
│   ├── Timesheet Approvals [ATT-T-008] (P1)   ← Period-end review
│   └── Delegate Approvals [SHD-T-007] (P1)    ← Set delegation during absence
│
└── HR Operations
    ├── Shift Assignments [ATT-M-001] (P1)     ← Assign shifts to employees
    ├── Comp Time Expiry Management [ATT-T-006] (P1) ← Review upcoming expirations
    └── OT Adjustment [ATT-T-002]              ← Manual HR adjustments
```

### TRANSACTIONS — Shared (ta.shared)

Cross-cutting workflows for period management and approvals.

```
Shared
│
├── Period Management
│   ├── Period Open / Lock / Close [SHD-T-002] ← Payroll period lifecycle
│   └── Payroll Export [SHD-T-003]             ← Download / re-trigger package
│
├── Approval Management
│   ├── My Pending Approvals [SHD-T-006] (P1)  ← Unified queue (Leave + OT + Timesheet)
│   └── Approval Delegation [SHD-T-007] (P1)   ← Temporary delegate setup
│
└── Termination Handling
    └── Balance Review [SHD-T-008] (P1)        ← Negative balance actions (Deduct/Write-off)
```

---

### Menu-to-Feature Traceability

| Menu Category | Feature Count | Priority Split |
|---------------|---------------|----------------|
| Configs | 9 | P0: 5, P1: 4 |
| Settings | 6 | P1: 4, P2: 2 |
| Reports & Analytics | 5 | P1: 4, P2: 1 |
| Transactions — Absence | 9 | P0: 5, P1: 4 |
| Transactions — Time | 11 | P0: 5, P1: 6 |
| Transactions — Shared | 5 | P0: 3, P1: 2 |
| **Total** | **45** | **P0: 18, P1: 22, P2: 5** |
```
