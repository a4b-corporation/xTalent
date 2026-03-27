# Glossary: ta.attendance — Time & Attendance

**Bounded Context:** `ta.attendance`
**Module:** xTalent HCM — Time & Absence
**Step:** 3 — Domain Architecture
**Date:** 2026-03-24
**Version:** 1.0

This glossary defines the ubiquitous language for the Time and Attendance bounded context. All engineers, product owners, and business stakeholders must use these terms consistently when discussing `ta.attendance`.

---

## Punch

**Definition:** An immutable record of a single clock-in or clock-out event submitted by an employee. A Punch captures the event timestamp, input channel, device identity, location coordinates (when geofencing is enabled), and biometric reference token (when biometric authentication is used). Punches are the raw data from which WorkedPeriods are computed.

**Also known as:** Clock event, time entry, attendance event, badge swipe (in hardware terminal contexts)

**Distinguishing from:** WorkedPeriod (the computed result of pairing a ClockIn with a ClockOut); a single Punch is one half of a WorkedPeriod

**Business rules:**
- Immutable after submission — no UPDATE or DELETE operations are permitted (ADR-TA-001, BR-ATT-001-01)
- At most one active clock-in per employee at any time; duplicate clock-in is rejected
- No raw biometric data is stored — only `biometric_token_ref` (ADR-TA-004, BR-ATT-001-02)
- `sync_status` tracks offline-queued punches: PENDING → SYNCED or CONFLICT (H8)
- Corrections are made via a separate CorrectionRequest entity; the original Punch record is preserved

**Example:** {punch_type: CLOCK_IN, punched_at: "2026-04-07T08:02:00Z", source: MOBILE, geofence_validated: true, sync_status: SYNCED}

---

## ClockIn

**Definition:** A Punch event of type CLOCK_IN that marks the start of an employee's work session. A ClockIn must be paired with a corresponding ClockOut to form a valid WorkedPeriod.

**Also known as:** Check-in, time-in, punch-in

**Distinguishing from:** ClockOut; the Punch aggregate stores both types — ClockIn and ClockOut are values of the `punch_type` enum, not separate entities

**Business rules:**
- An employee may not have two concurrent active ClockIn records
- ClockIn timestamp is recorded in UTC
- Geofence validation runs at ClockIn time if geofencing is enabled for the work location

**Example:** Employee clocks in at 08:02 via mobile app at HQ Office (within geofence radius).

---

## ClockOut

**Definition:** A Punch event of type CLOCK_OUT that marks the end of an employee's work session. When paired with the preceding ClockIn, it triggers the WorkedPeriod calculation.

**Also known as:** Check-out, time-out, punch-out

**Distinguishing from:** ClockIn; ClockOut is the closing event that completes a punch pair

**Business rules:**
- ClockOut must correspond to an active ClockIn for the same employee
- ClockOut triggers the `CalculateWorkedPeriod` command
- Missing ClockOut (no ClockOut by end of shift + grace period) is an attendance exception requiring resolution

**Example:** Employee clocks out at 17:30 via mobile app. System pairs with 08:02 ClockIn, triggering WorkedPeriod calculation.

---

## WorkedPeriod

**Definition:** A computed record representing the duration of work between a paired ClockIn and ClockOut, after applying break deductions defined in the employee's assigned Shift. WorkedPeriod is the source data for Timesheet population and overtime calculation.

**Also known as:** Attendance record, work segment, time block

**Distinguishing from:** Punch (the raw events); Timesheet (the period-level aggregation); WorkedPeriod is a single work session

**Business rules:**
- Computed by: `worked_hours = (clock_out_time - clock_in_time) - total_break_minutes`
- Overtime component = `worked_hours - scheduled_shift_hours` (if positive)
- WorkedPeriod is created by the system; it is not directly submitted by employees
- Break deductions apply per the assigned Shift definition

**Example:** ClockIn: 08:00, ClockOut: 17:30, Shift break: 60 min → worked_hours = 8.5, overtime = 0.5 hours (vs 8h scheduled shift).

---

## Shift

**Definition:** A configuration object that defines a standard work schedule — start time, end time, unpaid break periods, and grace tolerance for late arrivals. Shifts are assigned to employees for specific date ranges via ShiftAssignments.

**Also known as:** Work pattern, work schedule, shift definition, roster entry (in some manufacturing contexts)

**Distinguishing from:** ShiftAssignment (the application of a Shift to a specific employee on specific dates); Shift is the template, ShiftAssignment is the instantiation

**Business rules:**
- Shift start time must be before shift end time
- Break periods must fall within the shift window
- Grace period for late arrival is configurable per shift (default: 0 minutes)
- Modifying a Shift definition triggers re-evaluation of existing ShiftAssignments for compliance

**Example:** "Morning Factory Shift" — start: 06:00, end: 14:00, break: 30 min unpaid at 10:00, late_arrival_grace_minutes: 10

---

## ShiftAssignment

**Definition:** The binding of a Shift definition to a specific employee for a defined date or date range. ShiftAssignment determines which shift rules apply to an employee's punches, attendance exception detection, and overtime calculation on a given day.

**Also known as:** Schedule assignment, roster entry, shift schedule

**Distinguishing from:** Shift (the template/definition); ShiftAssignment (the specific assignment to a specific employee for specific dates)

**Business rules:**
- A ShiftAssignment swap must not result in less than 8 hours rest period between consecutive shifts for either employee (VLC 2019, Article 109)
- Swap requires manager approval before execution
- Assignment is effective only within its approved date range

**Example:** Employee "Nguyen Van A" assigned "Morning Factory Shift" from 2026-04-01 to 2026-04-30 (Mon–Fri).

---

## ShiftPattern

**Definition:** A recurring weekly or multi-week rotation schedule that defines which Shifts an employee works on which days of the week or rotation cycle. ShiftPatterns simplify bulk ShiftAssignment for employees with consistent rotating schedules.

**Also known as:** Work rotation, rotating shift, shift cycle

**Distinguishing from:** Shift (a single shift template); ShiftAssignment (a single date-range binding); ShiftPattern (the multi-week rotation template)

**Business rules:**
- ShiftPattern changes require manager approval before taking effect
- Pattern must cover all working days in the rotation cycle
- Exceptions to the pattern are managed as individual ShiftAssignment overrides

**Example:** 2-week rotation pattern: Week 1 — Mon-Fri: Morning Shift; Week 2 — Mon-Fri: Afternoon Shift.

---

## OvertimeRequest

**Definition:** An employee-initiated (or manager-initiated) request for authorization to work beyond scheduled shift hours. Overtime must be pre-approved before work begins (default). The request captures the expected OT hours, OT type (pay or comp time), and routes through the ApprovalChain with skip-level logic for managers requesting their own OT.

**Also known as:** OT request, overtime authorization, extra hours request

**Distinguishing from:** WorkedPeriod (which records actual hours worked); OvertimeRequest is the pre-approval authorization for planned OT

**Business rules:**
- Monthly OT cap: 40 hours per VLC 2019, Article 107
- Annual OT cap: 200 hours (standard) or 300 hours (special industries)
- Manager cannot approve their own OT request — skip-level routing applied (H-P0-003)
- Approval blocked if it would cause employee to exceed caps (documented override with audit log required)
- `approval_routing_mode` is SKIP_LEVEL (default) or CUSTOM (Mode 2 configuration)

**Example:** Employee submits OT request for 2 hours on 2026-04-07 (Tuesday, rate: WEEKDAY 150%). System checks: current monthly OT = 18h (below 40h cap). Routes to direct manager.

---

## OvertimeBank

**Definition:** The cumulative tracking of approved overtime hours an employee has worked within the current month and year, used for cap enforcement. The OvertimeBank is a computed view, not a stored entity — it is derived from approved OvertimeRequests and WorkedPeriod records.

**Also known as:** OT ledger, overtime accumulator, OT balance

**Distinguishing from:** CompTimeBalance (the balance of compensatory time earned); OvertimeBank (the running total of OT hours for cap enforcement)

**Business rules:**
- Monthly OvertimeBank must not exceed 40 hours without documented override
- Annual OvertimeBank must not exceed 200 hours (standard) or 300 hours (special industries)
- Cap warning alert at 80% of monthly/annual cap
- OvertimeBank is visible to approvers at the point of OT approval

**Example:** Employee has 38h OT in March. New 4h OT request would reach 42h — system warns approver; override requires justification.

---

## CompTime (Compensatory Time)

**Definition:** Paid time off earned in lieu of cash overtime payment. When an employee's OT request is approved and the employee elects (or the tenant policy specifies) comp time instead of OT pay, a CompTimeBalance credit is created. CompTime must be used within the configured expiry window.

**Also known as:** Time off in lieu (TOIL), compensatory leave, comp day

**Distinguishing from:** OvertimeRequest (the authorization); CompTimeBalance (the running balance of comp time); CompTime (the concept — TOIL earned instead of cash)

**Business rules:**
- CompTime accrual triggers on OvertimeApproved when comp_time_elected = true
- Balance tracked via movement records (same append-only ledger pattern as leave)
- Expiry action configurable per tenant: EXTENSION, AUTO_CASHOUT, or FORFEITURE (H-P0-002)
- Warning notification sent N days before expiry (configurable, default: 14 days)

**Example:** Employee works 4h OT on Saturday. Elects comp time. CompTimeBalance credited: +4 hours, expiry: 2026-06-30.

---

## CompTimeExpiry

**Definition:** The date after which unused CompTime balance can no longer be used. When the expiry date is reached, the system applies the configured expiry action: EXTENSION (manager-approved extension), AUTO_CASHOUT (automatic payment via payroll export), or FORFEITURE (balance set to zero, logged).

**Also known as:** TOIL expiry, comp time forfeit date, compensatory time deadline

**Distinguishing from:** LeaveExpiry (same concept applied to leave balance); CompTimeExpiry applies specifically to compensatory time earned from OT

**Business rules:**
- Warning sent N days before expiry (H-P0-002; N configurable per tenant, default: 14 days)
- Expiry action is configurable per tenant/BU: EXTENSION, AUTO_CASHOUT, FORFEITURE
- FORFEITURE creates an EXPIRE-type movement; balance reset to zero
- AUTO_CASHOUT creates a cash-out record in the next PayrollExportPackage

**Example:** 6 hours of comp time expires on 2026-04-07. Tenant policy: AUTO_CASHOUT. System creates cashout record for 6 hours on 2026-04-07; appears in next payroll export.

---

## Timesheet

**Definition:** A period-level summary of an employee's attendance data — worked hours, leave taken, overtime, and exceptions — for a single payroll Period. Employees must review and submit their Timesheet at period end. Manager approval locks the Timesheet and includes it in the PayrollExportPackage.

**Also known as:** Time record, attendance report, period summary, time card

**Distinguishing from:** WorkedPeriod (individual work session records that feed into the Timesheet); Timesheet (the period-level aggregate requiring approval)

**Business rules:**
- One Timesheet per employee per Period
- States: OPEN → SUBMITTED → APPROVED → LOCKED
- Cannot be submitted if unresolved attendance exceptions exist
- APPROVED Timesheet is locked — corrections require HR-authorized CorrectionRequest (BR-ATT-014)
- Period cannot close until all Timesheets in the Period are APPROVED

**Example:** Employee submits Timesheet for March 2026 on 2026-03-31 — worked_days: 22, regular_hours: 176, overtime_hours: 4, leave_days: 2 (Annual).

---

## TimesheetLine

**Definition:** An individual day-level entry within a Timesheet, recording the worked hours, leave type (if applicable), and attendance status (present, absent, leave, public holiday) for a specific calendar date.

**Also known as:** Timesheet row, daily attendance entry, attendance line

**Distinguishing from:** Timesheet (the period-level container); TimesheetLine (the individual day entry within it)

**Business rules:**
- One TimesheetLine per calendar day within the period
- Exceptions (late arrival, early departure, geofence violation) are linked to the relevant TimesheetLine
- Public holidays are populated automatically from the HolidayCalendar

**Example:** 2026-04-07: status=PRESENT, regular_hours=8.0, overtime_hours=2.0, source=PUNCH_PAIR, punch_in=08:02, punch_out=18:05.

---

## Geofence

**Definition:** A virtual geographic boundary defined around a registered work location. When mobile clock-in is attempted, the system validates whether the employee's GPS coordinates fall within the configured radius of a registered work location. A punch outside the geofence is recorded but flagged as a GeofenceViolation for manager review.

**Also known as:** Location boundary, virtual perimeter, site boundary

**Distinguishing from:** Work location (the physical address record); Geofence (the virtual boundary around it, defined by radius in meters)

**Business rules:**
- Geofencing is enabled per work location (not globally mandatory)
- Punch outside geofence is NOT blocked by default — it is flagged as GeofenceViolation for manager review
- Location is captured at punch event only — no continuous GPS tracking (privacy by design, H4)
- Managers can mark violations as "Approved Exception" (e.g., approved client site visit)

**Example:** Work location "HQ Office" has geofence radius of 100 meters. Employee punches from 500 meters away — GeofenceViolation event logged; manager alerted.

---

## BiometricToken

**Definition:** A reference token issued by a third-party biometric provider that identifies a successful biometric authentication event. xTalent stores this token to establish a chain of custody for the punch event without storing any raw biometric data.

**Also known as:** Biometric reference, authentication token, device token

**Distinguishing from:** Biometric data (fingerprint image, template, facial scan — NEVER stored by xTalent); BiometricToken (the opaque reference that proves authentication occurred)

**Business rules:**
- xTalent stores ONLY the `biometric_token_ref` string value from the third-party provider (ADR-TA-004)
- No fingerprint image, template, facial scan, or raw biometric data is stored in xTalent systems
- The token is used for audit trail purposes only — xTalent cannot perform biometric authentication
- Compliance: GDPR Article 9, Vietnam Decree 13/2023 on Personal Data Protection

**Example:** BiometricDevice authenticates employee via fingerprint → third-party provider validates → returns token "T-12345" → xTalent stores Punch.biometric_token_ref = "T-12345" only.

---

## Integration Points

| Concept | From/To Context | Data Exchanged |
|---------|----------------|----------------|
| `PunchEventReceived` | From: Biometric Device | Biometric token, employee ID, timestamp → creates Punch |
| `HolidayCalendarPublished` | From: ta.shared | Public holidays → used for OT rate category (WEEKDAY/WEEKEND/HOLIDAY) |
| `PeriodClosed` | From: ta.shared | Triggers Timesheet lock and PayrollExport contribution |
| `PayrollExportPackage` (attendance) | To: Payroll Module | Worked hours by category, OT by rate, comp time cashouts |
| `ApprovalChain` | From: ta.shared | Routing rules for OT request and shift swap approval |
