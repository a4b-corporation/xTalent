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
