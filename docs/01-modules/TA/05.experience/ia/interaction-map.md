# Interaction Map: Time & Absence

**Module:** xTalent HCM — Time & Absence
**Step:** 5 — Product Experience Design
**Date:** 2026-03-25
**Version:** 1.0

---

## Interaction Types

| Type | Description | UX Pattern |
|------|-------------|-----------|
| **CRUD** | Create, Read, Update, Delete a configuration record | List view + form modal/page |
| **WORKFLOW** | Multi-step state machine with approvals or conditions | Stepper / status timeline |
| **DASHBOARD** | Read-only aggregated view of current state | Cards, charts, summary widgets |
| **CALCULATOR** | Input → computed output, no persistence | Form with live computed result |
| **BATCH** | System-triggered job, HR Admin monitoring view only | Status monitor + log |
| **NOTIFICATION** | System push event; user reads and optionally acknowledges | In-app notification + badge |
| **CALENDAR** | Date-grid view with overlay data; interactive entry points | Calendar component with slot actions |

---

## P0 Feature Interaction Map

| Feature ID | Feature Name | Interaction Type | Primary Entry Points | States / Modes | Key Actions |
|-----------|-------------|-----------------|----------------------|----------------|-------------|
| ABS-M-001 | Leave Type Configuration | CRUD | HR Admin → Configuration → Leave Types | active / inactive / draft | Create, Edit, Activate, Deactivate, View details |
| ABS-M-002 | Leave Policy Definition | CRUD | HR Admin → Configuration → Leave Policies | active / inactive | Create, Edit, Link to Accrual Plan, Activate, Deactivate |
| ABS-M-003 | Accrual Plan Setup | CRUD | HR Admin → Configuration → Accrual Plans | active / inactive | Create, Edit, Preview simulation, Link to Policy |
| ABS-T-001 | Leave Request Submission | WORKFLOW | Employee → Leave → Request Leave; Calendar date-click (P1) | draft → submitted → under_review → approved / rejected → cancelled | Submit, Save Draft, Cancel |
| ABS-T-002 | Leave Approval / Rejection | WORKFLOW | Manager → Approvals → Leave Requests; Push notification CTA | pending → approved / rejected | Approve, Reject (with reason), View history, View team calendar |
| ABS-T-003 | Leave Cancellation | WORKFLOW | Employee → My Leave Requests → Cancel; H-P0-001 deadline check | approved → cancellation_requested / cancelled | Cancel (pre-deadline), Request Cancellation (post-deadline), Manager: Approve/Reject cancellation |
| ABS-T-004 | Leave Balance Inquiry | DASHBOARD | Employee Home widget; Employee → Leave → My Balances | read-only live data | View by type, View movement history, Expand/collapse type detail |
| ABS-T-005 | Leave Reservation (system) | BATCH | No direct UX — system internal; visible in ABS-T-004 balance as "Reserved" amount | reserved → converted / released | No user action; visible as status in balance view |
| ABS-T-006 | Accrual Batch Processing | BATCH | HR Admin → Operations → Accrual Batch Run | idle → running → completed / failed | Trigger manual run, View last run log, View scheduled run status |
| ATT-T-001 | Punch In / Clock Out | WORKFLOW | Mobile → Clock tab (primary CTA); Web fallback | punched_out → punched_in → punched_out; conflict state | Clock In, Clock Out, View punch history, Sync status indicator |
| ATT-T-002 | Overtime Calculation | DASHBOARD | Employee → Timesheet (embedded OT lines); Manager → Team Timesheet | read-only computed | View OT breakdown by category (WEEKDAY/WEEKEND/HOLIDAY), View cap utilization |
| ATT-T-003 | Overtime Request + Approval | WORKFLOW | Employee → Attendance → Overtime Requests; H-P0-003 skip-level indicator | draft → submitted → pending_approval → approved / rejected | Submit OT request, Approve, Reject, View routing (who will approve) |
| ATT-T-004 | Timesheet Submission | WORKFLOW | Employee → Attendance → My Timesheets → Submit | draft → submitted → approved / rejected | Submit, View detail lines, Resubmit (if rejected) |
| SHD-M-001 | Holiday Calendar Configuration | CRUD | HR Admin → Configuration → Holiday Calendar | published / draft | Add holiday, Edit, Publish calendar, Import from country template |
| SHD-T-001 | Multi-Level Approval Workflow Config | CRUD | HR Admin → Configuration → Approval Workflows | active / inactive | Create chain, Add levels, Set escalation timeout, Test routing |
| SHD-T-002 | Period Open / Lock / Close | WORKFLOW | Payroll Officer → Payroll Processing → Period Close; HR Admin → Operations → Period Management | open → locked → closed | Lock period, Validate, Close period, View blocked items |
| SHD-T-003 | Payroll Integration Export | BATCH | Payroll Officer → Payroll Processing → Payroll Export | pending → generating → available / failed | Download export, Re-trigger export, View export log |
| SHD-T-004 | Employee Central Integration | NOTIFICATION | System Admin → Settings → Integration Settings | connected / error / syncing | View sync health, View last event received, Re-trigger sync |
| SHD-T-005 | Escalation Processing | NOTIFICATION | Manager receives escalation notification; HR Admin → Operations dashboard badge | auto-triggered by timeout | Manager: acknowledge escalated request; HR Admin: view escalation log |

---

## P1 Feature Interaction Map

| Feature ID | Feature Name | Interaction Type | Primary Entry Points | States / Modes | Key Actions |
|-----------|-------------|-----------------|----------------------|----------------|-------------|
| ABS-M-004 | Leave Class Management | CRUD | HR Admin → Configuration → Leave Classes | active / inactive | Create, Edit, Add/Remove leave types to class |
| ABS-M-005 | Carry-Over Rules Configuration | CRUD | HR Admin → Configuration → Carry-Over Rules | active / inactive | Create, Edit, Link to leave type, Set max days + expiry |
| ABS-T-007 | Leave Calendar View | CALENDAR | Manager → Dashboard (default); Employee → Leave → Leave Calendar | month / week / team-overlay | Click date to request leave, Filter by team member, Toggle team overlay, Navigate months |
| ABS-T-008 | Accrual Simulation | CALCULATOR | HR Admin → Accrual Plans → Simulate | input-only | Enter employee params, Run simulation, Compare scenarios, Export projection |
| ABS-T-009 | Leave Reservation Status View | DASHBOARD | Employee → Leave → Leave Reservations | read-only | View reservation by request, See expiry date, Link to request detail |
| ATT-M-001 | Shift Management | CRUD | HR Admin → Configuration → Shifts | active / inactive | Create shift template, Edit, Assign to employees, View assignments grid |
| ATT-M-002 | Geofencing Configuration | CRUD | System Admin → Settings → Geofence Zones | active / inactive | Draw polygon on map, Set work location name, Set tolerance radius, Activate |
| ATT-T-005 | Biometric Authentication Flow | WORKFLOW | Mobile → Clock tab → Clock In (biometric prompt) | prompt → success / failure / fallback | Biometric scan, Fallback to PIN, Handle biometric not available |
| ATT-T-006 | Comp Time Tracking + Expiry | DASHBOARD | Employee → Attendance → Comp Time Balance; HR Admin → Operations → Comp Time Expiry | read-only | View balance, View expiry dates, HR Admin: trigger extension/cashout/forfeiture |
| ATT-T-007 | Shift Swap Request | WORKFLOW | Employee → My Shift Assignment → Request Swap | draft → pending_colleague → pending_manager → approved / rejected | Select colleague, Request swap, Colleague: Accept/Decline, Manager: Approve |
| ATT-T-008 | Timesheet Approval | WORKFLOW | Manager → Approvals → Timesheets | pending → approved / rejected | View submitted timesheet, Approve, Reject with comments |
| SHD-T-006 | Approval Dashboard | DASHBOARD | Manager → Dashboard (Approvals panel); Manager → Approvals (full view) | real-time live data | View all pending items by type, Bulk approve (no-exception items), Deep-link to item |
| SHD-T-007 | Approval Delegation | WORKFLOW | Manager → Team → Delegate Approvals | inactive → active → expired | Set delegate employee, Set date range, Activate, Revoke early |
| SHD-T-008 | Termination Balance Review | WORKFLOW | HR Admin → Operations → Termination Balance Review; Payroll Officer → Terminated Employees | pending_action → action_taken | View terminated employee balances, Select action per policy: Deduct / Write Off / Escalate |
| SHD-A-001 | Leave Balance Reports | DASHBOARD | HR Admin → Reports → Leave Balance Report; Payroll Officer → Reports | filter-driven read-only | Filter by employee / department / leave type / date range, Export to CSV/Excel |
| SHD-A-002 | Bradford Factor Scoring | DASHBOARD | HR Admin → Reports → Bradford Factor; Manager → Team → Bradford Factor | filter-driven read-only | View score per employee, Sort by score, View absence episode breakdown, Export |

---

## Real-Time Event Interaction Triggers

| Event | Interaction Triggered | UX Channel |
|-------|-----------------------|-----------|
| `LeaveRequestApproved` | Employee sees status update on request card; balance widget refreshes | Push notification + SSE balance update |
| `LeaveRequestRejected` | Employee sees rejection reason on request card | Push notification |
| `ApprovalPending` | Manager approval queue badge increments | Push notification + badge |
| `PunchSynced` | Mobile sync indicator changes from PENDING to SYNCED | SSE on mobile clock screen |
| `PunchConflictDetected` | Mobile shows CONFLICT warning; HR Admin sees exception | SSE + in-app notification |
| `OvertimeLimitApproaching` (80% cap) | Toast or badge on OT request submission screen | In-app toast (non-blocking) |
| `CompTimeExpiryWarning` | Employee home screen shows expiry alert badge | Push notification + email |
| `PeriodLocked` | HR Admin + Payroll Officer see period status change | In-app notification |
| `PeriodClosed` | Payroll export becomes available for download | In-app notification + email |
| `ApprovalTaskEscalated` | Escalation recipient sees new item in queue | Push notification |
