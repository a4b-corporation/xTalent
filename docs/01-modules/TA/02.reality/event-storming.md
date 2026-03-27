# Event Storming Catalog: Time & Absence Module

**Module:** Time & Absence (TA)
**Product:** xTalent HCM
**Step:** 2 — Reality / Specify
**Version:** 1.0
**Date:** 2026-03-24
**Status:** DRAFT — Pending Gate G2 Approval

**Methodology:** Domain Event Storming (Alberto Brandolini, 2013)
**Base catalog:** Extended from research-synthesis.md (47 events, 32 commands)
**This catalog:** 54 domain events, 38 commands, covering all 3 bounded contexts

---

## Domain Event Catalog

### Color Coding Convention (for physical storming sessions)
- Orange: Domain Event
- Blue: Command
- Yellow: Actor
- Purple: Policy / Business Rule
- Pink: Hot Spot / Question
- Green: Read Model / Query

---

## Absence Management Events (ta.absence)

| Event ID | Event Name | Trigger | Actor | Command | Aggregate | Policy | Read Model Updated |
|----------|------------|---------|-------|---------|-----------|--------|--------------------|
| E-ABS-001 | LeaveRequestSubmitted | Employee submits leave request | Employee | SubmitLeaveRequest | LeaveRequest | BR-ABS-005 (reserve balance) | LeaveBalanceSummary, TeamCalendar |
| E-ABS-002 | LeaveRequestValidationFailed | Balance check fails at submission | System | SubmitLeaveRequest | LeaveRequest | BR-ABS-005 | (no update — request rejected) |
| E-ABS-003 | LeaveRequestRouted | Approval chain evaluated and first approver assigned | System | RouteLeaveRequest | ApprovalChain | BR-SHD-003-01, BR-SHD-003-02 | ApprovalQueue |
| E-ABS-004 | LeaveRequestApproved | Manager completes final approval level | Manager | ApproveLeaveRequest | LeaveRequest | (convert reservation to deduction) | LeaveBalanceSummary, TeamCalendar, ApprovalQueue |
| E-ABS-005 | LeaveRequestRejected | Manager rejects request | Manager | RejectLeaveRequest | LeaveRequest | BR-ABS-005 (release reservation) | LeaveBalanceSummary, ApprovalQueue |
| E-ABS-006 | LeaveRequestCancelled | Cancellation completed (pre- or post-deadline approval) | Employee / System | CancelLeaveRequest | LeaveRequest | BR-ABS-006, BR-ABS-007, BR-ABS-009 | LeaveBalanceSummary, TeamCalendar |
| E-ABS-007 | LeaveBalanceReserved | Balance held upon request submission | System | ReserveLeaveBalance | LeaveReservation | BR-ABS-005 (FEFO reservation) | LeaveBalanceSummary |
| E-ABS-008 | LeaveBalanceDeducted | Actual leave deducted on leave start date | System | DeductLeaveBalance | LeaveMovement | BR-ABS-004 (immutable ledger) | LeaveBalanceSummary |
| E-ABS-009 | LeaveAccrualProcessed | Monthly accrual batch creates movement records | System | ProcessLeaveAccrual | LeaveMovement | ADR-TA-001, ADR-TA-002 | LeaveBalanceSummary |
| E-ABS-010 | LeaveCarryoverExecuted | Year-end carryover batch runs | System | ExecuteCarryover | LeaveMovement | CarryoverRule | LeaveBalanceSummary |
| E-ABS-011 | LeaveBalanceExpired | Balance reaches expiry date | System | ExpireLeaveBalance | LeaveMovement | CarryoverRule, BR-ATT-007 | LeaveBalanceSummary |
| E-ABS-012 | LeavePolicyViolationDetected | Leave request violates a business rule | System | ValidateLeaveRequest | LeaveRequest | Multiple BRs | ComplianceLog |
| E-ABS-013 | LeaveBalanceExceeded | Request exceeds available balance | System | ValidateLeaveRequest | LeaveRequest | BR-ABS-005 | (no update — validation error) |
| E-ABS-014 | LeaveTypeCreated | HR Admin creates new leave type | HR Administrator | CreateLeaveType | LeaveType | BR-ABS-001, BR-ABS-002 | LeaveTypeList |
| E-ABS-015 | LeaveTypeDeactivated | HR Admin deactivates leave type | HR Administrator | DeactivateLeaveType | LeaveType | (warn if active balances) | LeaveTypeList |
| E-ABS-016 | LeavePolicyAssigned | Policy assigned to employee (hire/transfer/promotion) | System | AssignLeavePolicy | LeaveInstant | BR-ABS-001 through BR-ABS-003 | EmployeeLeaveProfile |
| E-ABS-017 | LeaveEncashmentProcessed | Unused leave encashed at termination or HR event | HR Administrator / System | ProcessLeaveEncashment | LeaveMovement | FR-ABS-009 (P2) | PayrollExportPackage |
| E-ABS-018 | CancellationRequestSubmitted | Employee submits post-deadline cancellation | Employee | RequestCancellation | LeaveRequest | BR-ABS-007, BR-ABS-008 | ApprovalQueue |
| E-ABS-019 | CancellationApproved | Manager approves post-deadline cancellation | Manager | ApproveCancellation | LeaveRequest | BR-ABS-009 (full balance restore) | LeaveBalanceSummary, TeamCalendar |
| E-ABS-020 | CancellationRejected | Manager rejects post-deadline cancellation | Manager | RejectCancellation | LeaveRequest | (request returns to APPROVED) | ApprovalQueue |
| E-ABS-021 | AccrualBatchStarted | Accrual batch job initiated | System | StartAccrualBatch | AccrualBatchRun | ADR-TA-002 | BatchRunLog |
| E-ABS-022 | AccrualBatchCompleted | Accrual batch finishes successfully | System | CompleteAccrualBatch | AccrualBatchRun | (notify HR Admin) | BatchRunLog, LeaveBalanceSummary |
| E-ABS-023 | AccrualBatchFailed | Accrual batch encounters error; rolled back | System | FailAccrualBatch | AccrualBatchRun | (alert — no partial commits) | BatchRunLog, AlertLog |
| E-ABS-024 | TerminationBalanceSnapshotCreated | Employee terminated; all balances snapshotted | System | CreateTerminationSnapshot | TerminationBalanceRecord | H-P0-004, BR-SHD-007-01 | HRAlertQueue |

---

## Time and Attendance Events (ta.attendance)

| Event ID | Event Name | Trigger | Actor | Command | Aggregate | Policy | Read Model Updated |
|----------|------------|---------|-------|---------|-----------|--------|--------------------|
| E-ATT-001 | EmployeeClockIn | Employee initiates clock-in event | Employee | ClockIn | Punch | BR-ATT-013 (immutable punch) | DailyAttendanceSummary, Timesheet |
| E-ATT-002 | EmployeeClockOut | Employee initiates clock-out event | Employee | ClockOut | Punch | BR-ATT-013 | DailyAttendanceSummary, WorkedPeriod |
| E-ATT-003 | ShiftAssigned | HR Admin assigns shift to employee or group | HR Administrator | AssignShift | ShiftAssignment | BR-ATT-015 (rest period) | ShiftSchedule |
| E-ATT-004 | ShiftPatternUpdated | Existing shift definition modified | HR Administrator | UpdateShift | Shift | (re-evaluate existing assignments) | ShiftSchedule |
| E-ATT-005 | ShiftSwapRequested | Employee initiates shift swap | Employee | RequestShiftSwap | ShiftAssignment | BR-ATT-015 (rest period validation) | ShiftSwapQueue |
| E-ATT-006 | OvertimeRequested | Employee submits OT request | Employee | SubmitOvertimeRequest | OvertimeRequest | BR-ATT-001 through BR-ATT-003 | OTApprovalQueue |
| E-ATT-007 | OvertimeApproved | Approver approves OT request | Manager / Senior Manager | ApproveOvertimeRequest | OvertimeRequest | BR-ATT-009, BR-ATT-010, BR-ATT-011 | OTSummary, PayrollExportPackage |
| E-ATT-008 | OvertimeRejected | Approver rejects OT request | Manager | RejectOvertimeRequest | OvertimeRequest | (release pending OT hours) | OTApprovalQueue |
| E-ATT-009 | OvertimeCapWarning | Employee approaching monthly or annual OT cap | System | EvaluateOTCap | OvertimeRequest | BR-ATT-001, BR-ATT-002, BR-ATT-003 | OTCapDashboard |
| E-ATT-010 | CompTimeAccrued | OT converted to comp time upon approval | System | AccrueCompTime | CompTimeBalance | H-P0-002 resolved | CompTimeBalanceSummary |
| E-ATT-011 | CompTimeUsed | Employee uses comp time as leave | Employee | UseCompTime | CompTimeBalance | (deduct from comp time balance) | CompTimeBalanceSummary |
| E-ATT-012 | LateArrivalDetected | Punch-in after shift start + grace period | System | DetectLateArrival | ShiftAssignment | FR-ATT-004 | AttendanceExceptionDashboard |
| E-ATT-013 | EarlyDepartureDetected | Punch-out before shift end without approval | System | DetectEarlyDeparture | ShiftAssignment | FR-ATT-004 | AttendanceExceptionDashboard |
| E-ATT-014 | AbsenceDetected | No punch recorded for a scheduled shift day | System | DetectAbsence | ShiftAssignment | FR-ATT-004 | AttendanceExceptionDashboard |
| E-ATT-015 | GeofenceViolation | Punch recorded outside geofence radius | System | ValidateGeofence | Punch | FR-ATT-006 | GeofenceViolationLog, ManagerAlertQueue |
| E-ATT-016 | OvertimeLimitExceeded | OT hours exceed legal cap | System | EnforceOTCap | OvertimeRequest | BR-ATT-001 through BR-ATT-003 | ComplianceLog, ManagerAlertQueue |
| E-ATT-017 | TimesheetSubmitted | Employee submits timesheet for period | Employee | SubmitTimesheet | Timesheet | FR-ATT-003 | TimesheetApprovalQueue |
| E-ATT-018 | TimesheetApproved | Manager approves timesheet | Manager | ApproveTimesheet | Timesheet | BR-ATT-014 (lock on approval) | TimesheetApprovalQueue, PayrollExportPackage |
| E-ATT-019 | TimesheetRejected | Manager sends timesheet back for correction | Manager | RejectTimesheet | Timesheet | FR-ATT-003 | TimesheetApprovalQueue |
| E-ATT-020 | TimesheetCorrected | HR Admin applies correction to approved timesheet | HR Administrator | CorrectTimesheet | Timesheet | BR-ATT-014 | PayrollExportPackage, AuditLog |
| E-ATT-021 | BiometricPunchReceived | Biometric device sends authenticated punch event | System (device) | ProcessBiometricPunch | Punch | BR-ATT-012 (no raw biometric) | DailyAttendanceSummary |
| E-ATT-022 | ShiftSwapApproved | Manager approves shift swap between employees | Manager | ApproveShiftSwap | ShiftAssignment | BR-ATT-015 | ShiftSchedule |
| E-ATT-023 | ShiftSwapRejected | Manager rejects shift swap | Manager | RejectShiftSwap | ShiftAssignment | FR-ATT-005 | ShiftSwapQueue |
| E-ATT-024 | CompTimeExpiryWarning | Comp time approaching expiry date | System | SendCompTimeWarning | CompTimeBalance | BR-ATT-007 (N days warning) | NotificationQueue |
| E-ATT-025 | CompTimeExpired | Comp time reaches expiry — action applied | System | ExpireCompTime | CompTimeBalance | BR-ATT-008 (configurable action) | CompTimeBalanceSummary, PayrollExportPackage |
| E-ATT-026 | WorkedPeriodCalculated | System pairs punch-in/out and computes worked hours | System | CalculateWorkedPeriod | WorkedPeriod | FR-ATT-001 (break deduction) | Timesheet, DailyAttendanceSummary |

---

## Shared Services Events (ta.shared)

| Event ID | Event Name | Trigger | Actor | Command | Aggregate | Policy | Read Model Updated |
|----------|------------|---------|-------|---------|-----------|--------|--------------------|
| E-SHD-001 | PeriodOpened | HR Admin opens a new payroll period | HR Administrator | OpenPeriod | Period | FR-INT-002 | PeriodStatusDashboard |
| E-SHD-002 | PeriodClosed | HR Admin closes the payroll period | HR Administrator / Payroll Officer | ClosePeriod | Period | BRD-SHD-001 (all timesheets approved) | PeriodStatusDashboard, PayrollExportPackage |
| E-SHD-003 | PeriodClosureBlocked | Period close attempted but preconditions not met | System | ClosePeriod | Period | BRD-SHD-001 | HRAlertQueue |
| E-SHD-004 | PayrollExportGenerated | Payroll export package created at period close | System | GeneratePayrollExport | PayrollExportPackage | FR-INT-002 (idempotent) | PayrollExportLog |
| E-SHD-005 | PayrollExportDelivered | Export package delivered to Payroll module | System | DeliverPayrollExport | PayrollExportPackage | FR-INT-002 | PayrollExportLog |
| E-SHD-006 | HolidayCalendarPublished | HR Admin publishes updated holiday calendar | HR Administrator | PublishHolidayCalendar | HolidayCalendar | Article 112, VLC 2019 | HolidayCalendarView |
| E-SHD-007 | ApprovalTaskCreated | Workflow engine creates an approval task | System | CreateApprovalTask | ApprovalTask | BRD-SHD-003 | ApprovalQueue |
| E-SHD-008 | ApprovalTaskCompleted | Approver acts on an approval task (approve/reject) | Manager / HR Administrator | CompleteApprovalTask | ApprovalTask | BRD-SHD-003 | ApprovalQueue |
| E-SHD-009 | ApprovalTaskEscalated | Approval task timed out; escalated to next approver | System | EscalateApprovalTask | ApprovalTask | BRD-SHD-008 (timeout + escalation) | ApprovalQueue, EscalationLog |
| E-SHD-010 | NotificationSent | Notification dispatched to recipient | System | SendNotification | Notification | BRD-SHD-004 | NotificationLog |
| E-SHD-011 | NotificationDeliveryFailed | Notification could not be delivered via primary channel | System | RetryNotification | Notification | BRD-SHD-004 (retry via email) | NotificationLog |
| E-SHD-012 | EmployeeHireIntegrated | EmployeeHired event received from Employee Central | System (Employee Central) | ProcessEmployeeHire | LeaveInstant, ShiftAssignment | FR-INT-001 | EmployeeLeaveProfile |
| E-SHD-013 | EmployeeTransferIntegrated | EmployeeTransferred event received | System (Employee Central) | ProcessEmployeeTransfer | LeaveInstant, ApprovalChain | FR-INT-001 | ApprovalQueue, EmployeeLeaveProfile |
| E-SHD-014 | EmployeeTerminationIntegrated | EmployeeTerminated event received | System (Employee Central) | ProcessEmployeeTermination | TerminationBalanceRecord | H-P0-004, BRD-SHD-007 | HRAlertQueue, PayrollExportPackage |
| E-SHD-015 | ApprovalChainConfigured | Admin configures multi-level approval chain | HR Administrator / System Admin | ConfigureApprovalChain | ApprovalChain | BRD-SHD-003 | ApprovalChainRegistry |
| E-SHD-016 | TenantPolicyUpdated | System Admin changes tenant-level policy (comp time, cancellation deadline, termination handling) | System Admin | UpdateTenantPolicy | TenantConfig | H-P0-001, H-P0-002, H-P0-004 | TenantPolicyView |

---

## Command Catalog

### Absence Management Commands

| Command ID | Command Name | Actor | Resulting Events | Aggregate | Notes |
|------------|-------------|-------|-----------------|-----------|-------|
| CMD-ABS-001 | SubmitLeaveRequest | Employee | E-ABS-001 (success) / E-ABS-002 (fail) | LeaveRequest | Triggers balance validation |
| CMD-ABS-002 | ApproveLeaveRequest | Manager | E-ABS-004 | LeaveRequest | Must check if all approval levels complete |
| CMD-ABS-003 | RejectLeaveRequest | Manager | E-ABS-005 | LeaveRequest | Reason required |
| CMD-ABS-004 | CancelLeaveRequest | Employee | E-ABS-006 (pre-deadline) / E-ABS-018 (post-deadline) | LeaveRequest | Deadline check determines route |
| CMD-ABS-005 | ApproveCancellation | Manager | E-ABS-019 | LeaveRequest | Post-deadline cancellation approval |
| CMD-ABS-006 | RejectCancellation | Manager | E-ABS-020 | LeaveRequest | Post-deadline cancellation rejection |
| CMD-ABS-007 | RouteLeaveRequest | System | E-ABS-003 | ApprovalChain | Dynamic org chart evaluation |
| CMD-ABS-008 | ReserveLeaveBalance | System | E-ABS-007 | LeaveReservation | FEFO reservation applied |
| CMD-ABS-009 | DeductLeaveBalance | System | E-ABS-008 | LeaveMovement | On leave start date |
| CMD-ABS-010 | ProcessLeaveAccrual | System (batch) | E-ABS-009 | LeaveMovement | Per AccrualPlan configuration |
| CMD-ABS-011 | ExecuteCarryover | System (batch) | E-ABS-010 | LeaveMovement | Year-end batch |
| CMD-ABS-012 | ExpireLeaveBalance | System (daily) | E-ABS-011 | LeaveMovement | Checks expiry_date on movements |
| CMD-ABS-013 | CreateLeaveType | HR Administrator | E-ABS-014 | LeaveType | Validates uniqueness of code |
| CMD-ABS-014 | DeactivateLeaveType | HR Administrator | E-ABS-015 | LeaveType | Warns if active balances |
| CMD-ABS-015 | AssignLeavePolicy | System (hire/transfer/promotion) | E-ABS-016 | LeaveInstant | Triggered by Employee Central events |
| CMD-ABS-016 | StartAccrualBatch | System (scheduler) | E-ABS-021 | AccrualBatchRun | Idempotency check first |
| CMD-ABS-017 | CreateTerminationSnapshot | System (termination event) | E-ABS-024 | TerminationBalanceRecord | All balances captured |

### Time and Attendance Commands

| Command ID | Command Name | Actor | Resulting Events | Aggregate | Notes |
|------------|-------------|-------|-----------------|-----------|-------|
| CMD-ATT-001 | ClockIn | Employee | E-ATT-001 | Punch | Validates no active clock-in |
| CMD-ATT-002 | ClockOut | Employee | E-ATT-002, E-ATT-026 | Punch, WorkedPeriod | Triggers worked period calculation |
| CMD-ATT-003 | AssignShift | HR Administrator | E-ATT-003 | ShiftAssignment | Validates rest period compliance |
| CMD-ATT-004 | UpdateShift | HR Administrator | E-ATT-004 | Shift | May affect existing assignments |
| CMD-ATT-005 | RequestShiftSwap | Employee | E-ATT-005 | ShiftAssignment | Validates rest period before submitting |
| CMD-ATT-006 | ApproveShiftSwap | Manager | E-ATT-022 | ShiftAssignment | Executes shift reassignment |
| CMD-ATT-007 | RejectShiftSwap | Manager | E-ATT-023 | ShiftAssignment | No change to assignments |
| CMD-ATT-008 | SubmitOvertimeRequest | Employee | E-ATT-006 | OvertimeRequest | Pre-approval default; cap check |
| CMD-ATT-009 | ApproveOvertimeRequest | Manager / Senior Manager | E-ATT-007 | OvertimeRequest | Skip-level for manager's own OT |
| CMD-ATT-010 | RejectOvertimeRequest | Manager | E-ATT-008 | OvertimeRequest | Reason required |
| CMD-ATT-011 | EvaluateOTCap | System (on OT approval) | E-ATT-009 (warning) / E-ATT-016 (exceeded) | OvertimeRequest | Checks monthly and annual caps |
| CMD-ATT-012 | AccrueCompTime | System (on OT approval) | E-ATT-010 | CompTimeBalance | When comp time elected over cash OT |
| CMD-ATT-013 | UseCompTime | Employee | E-ATT-011 | CompTimeBalance | Deducts from comp time balance |
| CMD-ATT-014 | DetectAttendanceExceptions | System (daily job) | E-ATT-012, E-ATT-013, E-ATT-014 | ShiftAssignment | Run after shift end time |
| CMD-ATT-015 | ValidateGeofence | System (on punch) | E-ATT-015 | Punch | Only when geofencing enabled |
| CMD-ATT-016 | SubmitTimesheet | Employee | E-ATT-017 | Timesheet | Validates all exceptions resolved |
| CMD-ATT-017 | ApproveTimesheet | Manager | E-ATT-018 | Timesheet | Locks timesheet |
| CMD-ATT-018 | RejectTimesheet | Manager | E-ATT-019 | Timesheet | Returns to OPEN |
| CMD-ATT-019 | CorrectTimesheet | HR Administrator | E-ATT-020 | Timesheet | Post-approval correction |
| CMD-ATT-020 | ProcessBiometricPunch | System (device event) | E-ATT-021 | Punch | Token ref only; no raw biometric |
| CMD-ATT-021 | SendCompTimeWarning | System (scheduled) | E-ATT-024 | Notification | N days before expiry |
| CMD-ATT-022 | ExpireCompTime | System (daily job) | E-ATT-025 | CompTimeBalance | Applies configured expiry action |

### Shared Services Commands

| Command ID | Command Name | Actor | Resulting Events | Aggregate | Notes |
|------------|-------------|-------|-----------------|-----------|-------|
| CMD-SHD-001 | OpenPeriod | HR Administrator | E-SHD-001 | Period | One open period at a time |
| CMD-SHD-002 | ClosePeriod | HR Administrator / Payroll Officer | E-SHD-002 (success) / E-SHD-003 (blocked) | Period | Precondition: all timesheets approved |
| CMD-SHD-003 | GeneratePayrollExport | System (period close) | E-SHD-004 | PayrollExportPackage | Idempotent |
| CMD-SHD-004 | DeliverPayrollExport | System | E-SHD-005 | PayrollExportPackage | Sends to Payroll module endpoint |
| CMD-SHD-005 | PublishHolidayCalendar | HR Administrator | E-SHD-006 | HolidayCalendar | Applies to leave and OT calculations |
| CMD-SHD-006 | CreateApprovalTask | System | E-SHD-007 | ApprovalTask | Part of approval routing engine |
| CMD-SHD-007 | CompleteApprovalTask | Manager / HR Administrator | E-SHD-008 | ApprovalTask | Triggers next level or final event |
| CMD-SHD-008 | EscalateApprovalTask | System (timeout scheduler) | E-SHD-009 | ApprovalTask | After configured timeout |
| CMD-SHD-009 | SendNotification | System | E-SHD-010 (success) / E-SHD-011 (fail) | Notification | Push + email; retry on failure |
| CMD-SHD-010 | ProcessEmployeeHire | System (Employee Central event) | E-SHD-012 | LeaveInstant | Triggers policy assignment |
| CMD-SHD-011 | ProcessEmployeeTransfer | System (Employee Central event) | E-SHD-013 | LeaveInstant, ApprovalChain | Re-evaluates policy and routing |
| CMD-SHD-012 | ProcessEmployeeTermination | System (Employee Central event) | E-SHD-014 | TerminationBalanceRecord | Triggers termination policy |
| CMD-SHD-013 | ConfigureApprovalChain | HR Administrator / System Admin | E-SHD-015 | ApprovalChain | Defines levels, timeouts, escalation |
| CMD-SHD-014 | UpdateTenantPolicy | System Admin | E-SHD-016 | TenantConfig | Changes comp time, cancellation, termination policies |

---

## Aggregate Summary

### Absence Management Aggregates

| Aggregate | Invariants | Key Events | Commands |
|-----------|------------|-----------|----------|
| **LeaveRequest** | 1. Balance must be available at submission (after reservation) / 2. State machine transitions are one-directional (no backward transitions except CANCELLATION_PENDING → APPROVED on rejection) / 3. Cancellation deadline is enforced by policy | E-ABS-001 through E-ABS-006, E-ABS-018 through E-ABS-020 | CMD-ABS-001 through CMD-ABS-006 |
| **LeaveReservation** | 1. Reservation cannot exceed available balance / 2. FEFO: earliest-expiring balance consumed first / 3. Reservation released on rejection or cancellation | E-ABS-007 | CMD-ABS-008 |
| **LeaveMovement** | 1. Immutable — records can never be updated or deleted / 2. Every balance change has exactly one movement record / 3. Audit trail must be unbroken | E-ABS-008, E-ABS-009, E-ABS-010, E-ABS-011 | CMD-ABS-009 through CMD-ABS-012 |
| **LeaveType** | 1. Code is unique per tenant / 2. Annual leave entitlement floor: 14 days (Vietnam minimum) / 3. Deactivation does not delete history | E-ABS-014, E-ABS-015 | CMD-ABS-013, CMD-ABS-014 |
| **LeaveInstant** | 1. Computed state = sum of all LeaveMovement records for employee + leave type / 2. Available balance = earned - used - reserved | E-ABS-016 | CMD-ABS-015 |
| **AccrualBatchRun** | 1. Only one batch run per period per accrual plan / 2. Idempotency: duplicate runs are rejected / 3. Partial commits are rolled back on failure | E-ABS-021, E-ABS-022, E-ABS-023 | CMD-ABS-016 |
| **TerminationBalanceRecord** | 1. Created exactly once per termination event / 2. Snapshot is immutable once created / 3. Policy action is executed asynchronously after snapshot | E-ABS-024 | CMD-ABS-017 |

### Time and Attendance Aggregates

| Aggregate | Invariants | Key Events | Commands |
|-----------|------------|-----------|----------|
| **Punch** | 1. Immutable — corrections via CorrectionRequest only / 2. At most one active clock-in per employee at any time / 3. No raw biometric data stored | E-ATT-001, E-ATT-002, E-ATT-021 | CMD-ATT-001, CMD-ATT-002, CMD-ATT-020 |
| **WorkedPeriod** | 1. Computed by pairing punch-in with punch-out / 2. Break deductions applied per assigned shift / 3. Overtime calculated as worked hours minus scheduled hours | E-ATT-026 | CMD-ATT-002 (triggers calculation) |
| **OvertimeRequest** | 1. Monthly cap: 40h; annual cap: 200h/300h (VLC Article 107) / 2. Manager cannot approve their own OT / 3. Override allowed with documented justification (logged) | E-ATT-006 through E-ATT-009, E-ATT-016 | CMD-ATT-008 through CMD-ATT-011 |
| **CompTimeBalance** | 1. Balance computed from movement records (earned - used - expired) / 2. Expiry action is configurable per tenant: extension / cash-out / forfeiture / 3. Warning sent N days before expiry (N configurable) | E-ATT-010, E-ATT-011, E-ATT-024, E-ATT-025 | CMD-ATT-012, CMD-ATT-013, CMD-ATT-021, CMD-ATT-022 |
| **ShiftAssignment** | 1. Shift swap must not result in < 8h rest period between shifts (VLC Article 109) / 2. Swap requires manager approval / 3. Assignment is effective only for approved periods | E-ATT-003, E-ATT-005, E-ATT-022, E-ATT-023 | CMD-ATT-003 through CMD-ATT-007 |
| **Timesheet** | 1. Only one timesheet per employee per period / 2. Approved timesheet is locked — corrections require HR authorization / 3. Cannot submit with unresolved exceptions | E-ATT-017 through E-ATT-020 | CMD-ATT-016 through CMD-ATT-019 |

### Shared Services Aggregates

| Aggregate | Invariants | Key Events | Commands |
|-----------|------------|-----------|----------|
| **Period** | 1. Only one OPEN period at a time per tenant / 2. Period can only close when all timesheets in APPROVED status / 3. Closed period generates idempotent payroll export | E-SHD-001 through E-SHD-003 | CMD-SHD-001, CMD-SHD-002 |
| **PayrollExportPackage** | 1. Idempotent: re-run produces identical package / 2. Includes all approved leave, worked hours, OT by category, cash-outs / 3. Period metadata is immutable | E-SHD-004, E-SHD-005 | CMD-SHD-003, CMD-SHD-004 |
| **HolidayCalendar** | 1. Vietnam: 11 statutory public holidays per year / 2. Applied to leave duration calculation and OT rate determination / 3. Country-code on all records for future expansion | E-SHD-006 | CMD-SHD-005 |
| **ApprovalChain** | 1. Evaluated dynamically at request submission time (not config time) / 2. Skip-level applied when submitter equals Level 1 approver / 3. Escalation triggers after configured timeout | E-SHD-007 through E-SHD-009, E-SHD-015 | CMD-SHD-006 through CMD-SHD-008, CMD-SHD-013 |
| **ApprovalTask** | 1. One active task per level per request at any time / 2. Completed task cannot be undone (immutable) / 3. Escalated task creates a new task for the escalation target | E-SHD-007, E-SHD-008, E-SHD-009 | CMD-SHD-006, CMD-SHD-007, CMD-SHD-008 |
| **TenantConfig** | 1. All policy changes are audited / 2. Changes to cancellation deadline, comp time expiry, and termination policy require explicit admin confirmation / 3. Changes take effect for new requests only (not retroactive) | E-SHD-016 | CMD-SHD-014 |

---

## Hot Spots Remaining (P1)

These 8 open questions must be resolved before implementation begins on their respective P1 features. They do not block BRD completion or Step 2.

| ID | Hot Spot | Affected Events/Flows | Proposed Resolution Approach | Step to Resolve |
|----|----------|-----------------------|-----------------------------|----|
| H-P1-001 | How is partial-day leave (0.5 days) calculated against balance? | E-ABS-007, E-ABS-008 (reservation and deduction amounts) | Define unit (HOUR vs. DAY) per leave type; allow fractional day requests; balance stored as decimal | Feature spec for LM-005 (P1 item) |
| H-P1-002 | Can a shift swap result in a labor law violation (< 8h rest)? | E-ATT-005, CMD-ATT-005 | System validates rest period at swap request submission; block if violation; warn manager on approval | Feature spec for TT-005 (already partially addressed in BRD-ATT-005) |
| H-P1-003 | How are biometric punches handled when the device is offline? | E-ATT-021, E-ATT-001 | Offline queue with sync-on-connect; max queue age configurable; conflict resolution: last-write-wins with manual review flag | Architecture (H8) — Step 4 |
| H-P1-004 | What is the exception process when a sick leave certificate is not submitted on time? | E-ABS-001, E-ABS-004, LeavePolicyViolation | Configure grace period (days after leave start); auto-flag on expiry; notify employee and manager; HR resolves exception | Feature spec for LM-001 (evidence_grace_period_days) |
| H-P1-005 | How does geofencing apply to employees working at client sites? | E-ATT-015, CMD-ATT-015 | Allow ad-hoc location registration with manager approval; "approved exception" flag on punch | Feature spec for TT-006 |
| H-P1-006 | Is overtime pre-approval mandatory, or can retroactive OT be logged? | E-ATT-006, CMD-ATT-008 | Make pre-approval default (current BRD); allow retroactive as a tenant configuration option; retroactive OT requires both manager approval and HR acknowledgement | Feature spec for TT-003 |
| H-P1-007 | How is a public holiday that falls on a weekend treated for leave balance? | E-SHD-006, E-ABS-007, E-ABS-008 | Substitute rest day: next Monday (if holiday on Sunday) or preceding Friday (if holiday on Saturday); configurable per tenant | Feature spec for holiday calendar |
| H-P1-008 | Can approval authority be delegated during manager absence? | E-SHD-007, E-SHD-009, CMD-SHD-006 | Manager sets delegation in advance with date range; delegated approvals logged with delegation reference; delegation limited to one level | Feature spec for WA-003 |

---

## Domain Event Timeline

The following sequences illustrate the key event flows for critical scenarios. Times shown are approximate SLA targets.

---

### Flow 1: Employee Submits and Manager Approves a Leave Request

```
Timeline →

T+0s    [Employee]         SubmitLeaveRequest
                           → E-ABS-001: LeaveRequestSubmitted

T+0s    [System]           ValidateLeaveRequest (balance check)
                           → E-ABS-007: LeaveBalanceReserved (balance held)
                           (If validation fails: E-ABS-002: LeaveRequestValidationFailed → STOP)

T+1s    [System]           RouteLeaveRequest (evaluate approval chain)
                           → E-ABS-003: LeaveRequestRouted
                           → E-SHD-007: ApprovalTaskCreated (Level 1: Manager)

T+30s   [System]           SendNotification to Manager
                           → E-SHD-010: NotificationSent

T+Xh    [Manager]          CompleteApprovalTask (approve)
                           → E-SHD-008: ApprovalTaskCompleted

T+Xh    [System]           (If more levels: create next level task → E-SHD-007)
                           (If all levels complete): ApproveLeaveRequest
                           → E-ABS-004: LeaveRequestApproved

T+Xh    [System]           SendNotification to Employee
                           → E-SHD-010: NotificationSent

Leave Start Date:
        [System]           DeductLeaveBalance (reservation → deduction)
                           → E-ABS-008: LeaveBalanceDeducted (immutable ledger entry)
```

---

### Flow 2: Post-Deadline Leave Cancellation

```
Timeline →

T+0s    [Employee]         RequestCancellation (after deadline)
                           → E-ABS-018: CancellationRequestSubmitted

T+0s    [System]           Check deadline: past deadline → route for approval
                           → E-SHD-007: ApprovalTaskCreated (Manager)

T+30s   [System]           SendNotification to Manager
                           → E-SHD-010: NotificationSent

T+Xh    [Manager]          ApproveCancellation
                           → E-ABS-019: CancellationApproved

T+Xh    [System]           CancelLeaveRequest
                           → E-ABS-006: LeaveRequestCancelled
                           → Balance reversal: E-ABS-008 (negative DEDUCTION = restore)
                           → SendNotification to Employee + Manager
```

---

### Flow 3: Employee Clocks In and Out (with OT Detection)

```
Timeline →

T+0s    [Employee]         ClockIn (mobile, within geofence)
                           → E-ATT-001: EmployeeClockIn
                           (geofencing enabled: ValidateGeofence → no violation)

End of shift:
        [Employee]         ClockOut
                           → E-ATT-002: EmployeeClockOut

T+0s    [System]           CalculateWorkedPeriod (pair punches, apply breaks)
                           → E-ATT-026: WorkedPeriodCalculated

T+0s    [System]           EvaluateOTCap (worked hours > scheduled hours)
                           → E-ATT-009: OvertimeCapWarning (if approaching cap)
                           OR E-ATT-016: OvertimeLimitExceeded (if cap breached)
```

---

### Flow 4: Employee Requests and Manager Approves Overtime

```
Timeline →

T+0s    [Employee]         SubmitOvertimeRequest (pre-approval)
                           → E-ATT-006: OvertimeRequested

T+0s    [System]           Evaluate submitter role: is submitter = Level 1 approver?
                           If YES (manager requesting own OT):
                             Apply BR-ATT-010: skip-level routing
                             → E-ABS-003-equivalent: OTRequestRouted to skip-level manager
                           If NO (regular employee):
                             Route to direct manager

T+0s    [System]           CreateApprovalTask
                           → E-SHD-007: ApprovalTaskCreated

T+Xh    [Manager / Sr. Manager] ApproveOvertimeRequest
                           → E-ATT-007: OvertimeApproved
                           → (if comp time elected) E-ATT-010: CompTimeAccrued

T+Xh    [System]           SendNotification to Employee
                           → E-SHD-010: NotificationSent
```

---

### Flow 5: Monthly Accrual Batch

```
Timeline →

T+0s    [System / Scheduler] StartAccrualBatch (last day of month, 23:00)
                             → E-ABS-021: AccrualBatchStarted
                             Idempotency check: if COMPLETED batch exists → skip

For each eligible employee (up to 10,000):
        [System]           ProcessLeaveAccrual (per AccrualPlan method)
                           → E-ABS-009: LeaveAccrualProcessed (one per employee per plan)
                           (LeaveMovement record created: immutable, timestamped)

T+<30m  [System]           CompleteAccrualBatch
                           → E-ABS-022: AccrualBatchCompleted
                           → SendNotification to HR Admin

[On failure at any point]:
        [System]           FailAccrualBatch (rollback all partial movements)
                           → E-ABS-023: AccrualBatchFailed
                           → AlertLog: "CRITICAL — accrual batch failed, no balances updated"
```

---

### Flow 6: Period Close and Payroll Export

```
Timeline →

T+0s    [HR Administrator / Payroll Officer] ClosePeriod
                           → System validates preconditions:
                             - All timesheets APPROVED
                             - No pending leave requests within period
                           If validation fails: → E-SHD-003: PeriodClosureBlocked

T+0s    [System]           GeneratePayrollExport
                           → E-SHD-004: PayrollExportGenerated
                           (Contains: leave by type, worked hours, OT by rate category,
                            comp time cash-outs, termination deductions, period metadata)

T+0s    [System]           DeliverPayrollExport
                           → E-SHD-005: PayrollExportDelivered
                           → E-SHD-002: PeriodClosed (final confirmation)

T+Xm    [System]           SendNotification to Payroll Specialist
                           → E-SHD-010: NotificationSent
```

---

## Event Count Summary

| Context | Domain Events | Commands | Aggregates |
|---------|---------------|----------|------------|
| Absence Management (ta.absence) | 24 | 17 | 7 |
| Time and Attendance (ta.attendance) | 26 | 22 | 6 |
| Shared Services (ta.shared) | 16 | 14 | 6 |
| **TOTAL** | **54** (was 47) | **38** (was 32) | **19** |

**New events vs. base catalog:**
- 7 new events added to capture resolved P0 decisions: E-ABS-018 through E-ABS-020 (cancellation policy), E-ATT-024 and E-ATT-025 (comp time expiry), E-SHD-014 through E-SHD-016 (termination, tenant policy)
- 6 new commands added: CMD-ABS-005, CMD-ABS-006 (cancellation), CMD-ATT-021, CMD-ATT-022 (comp time), CMD-SHD-013, CMD-SHD-014 (config)

---

*End of Event Storming Catalog*

**Traceability:**
- All 4 resolved P0 decisions incorporated into event flows (H-P0-001: E-ABS-018/019/020; H-P0-002: E-ATT-024/025; H-P0-003: CMD-ATT-009 skip-level logic; H-P0-004: E-SHD-014, E-ABS-024)
- All 8 P1 hot spots documented with proposed resolution approach
- All 3 bounded contexts covered with domain events, commands, aggregates, and timeline flows
