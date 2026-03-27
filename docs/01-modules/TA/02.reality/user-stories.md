# User Stories: Time & Absence Module

**Module:** Time & Absence (TA)
**Product:** xTalent HCM
**Step:** 2 — Reality / Specify
**Version:** 1.0
**Date:** 2026-03-24
**Status:** DRAFT — Pending Gate G2 Approval

---

## Story Index

### P0 Stories (Must Have — MVP)

| ID | Title | Persona | BRD Reference |
|----|-------|---------|---------------|
| US-ABS-001 | Submit a Leave Request | Employee | BRD-ABS-003 |
| US-ABS-002 | View Leave Balance in Real Time | Employee | BRD-ABS-004 |
| US-ABS-003 | Approve a Leave Request | Manager | BRD-ABS-003, BRD-SHD-003 |
| US-ABS-004 | Reject a Leave Request | Manager | BRD-ABS-003, BRD-SHD-003 |
| US-ABS-005 | Cancel a Leave Request Before Deadline | Employee | BRD-ABS-003 |
| US-ABS-006 | Cancel a Leave Request After Deadline | Employee | BRD-ABS-003 |
| US-ABS-007 | Configure a Leave Type | HR Administrator | BRD-ABS-001 |
| US-ABS-008 | Define a Leave Policy with Accrual Rules | HR Administrator | BRD-ABS-002 |
| US-ABS-009 | Configure Accrual Plan | HR Administrator | BRD-SHD-005 |
| US-ABS-010 | Run Monthly Accrual Batch | System | BRD-SHD-005 |
| US-ABS-011 | Execute Year-End Carryover and Expiry | System / HR Administrator | BRD-SHD-006 |
| US-ABS-012 | Handle Negative Balance at Termination | HR Administrator | BRD-SHD-007 |
| US-ATT-001 | Clock In and Clock Out | Employee | BRD-ATT-001 |
| US-ATT-002 | Request Overtime | Employee | BRD-ATT-002 |
| US-ATT-003 | Approve an Overtime Request | Manager | BRD-ATT-002, BRD-SHD-003 |
| US-ATT-004 | Approve Manager's Own OT via Skip-Level | System / Senior Manager | BRD-SHD-003 |
| US-ATT-005 | Submit Timesheet for Period | Employee | BRD-ATT-003 |
| US-ATT-006 | Approve Timesheet | Manager | BRD-ATT-003 |
| US-SHD-001 | Close a Payroll Period | HR Administrator / Payroll Officer | BRD-SHD-001 |
| US-SHD-002 | Export Payroll Data at Period Close | Payroll Officer | BRD-SHD-011 |
| US-SHD-003 | Route Leave Request Through Multi-Level Approval | System | BRD-SHD-003 |
| US-SHD-004 | Escalate Overdue Approval | System | BRD-SHD-003 |
| US-SHD-005 | Configure Comp Time Expiry Policy | HR Administrator | BRD-ATT-002 |

### P1 Stories (Should Have — V1 Release)

| ID | Title | Persona | BRD Reference |
|----|-------|---------|---------------|
| US-ABS-013 | View Team Leave Calendar | Manager / Employee | BRD-ABS-006 |
| US-ABS-014 | Initiate Leave Request from Calendar | Employee | BRD-ABS-006 |
| US-ABS-015 | View Leave Reservation Status | Employee | BRD-ABS-005 |
| US-ATT-007 | Assign Shift to Employee | HR Administrator | BRD-ATT-004 |
| US-ATT-008 | Request Shift Swap with Colleague | Employee | BRD-ATT-005 |
| US-SHD-006 | Delegate Approval Authority | Manager | Open (H-P1-008) |
| US-SHD-007 | View Pending Approvals Dashboard | Manager | BRD-SHD-009 |
| US-SHD-008 | Generate Leave Balance Report | HR Administrator | FR-ANL-001 |

---

## P0 User Stories

---

## US-ABS-001: Submit a Leave Request

**As an** Employee
**I want to** submit a leave request specifying type, dates, and reason
**So that** I can formally request time off and track its approval status without contacting HR

**Priority:** P0
**Hypothesis:** H1
**BRD Reference:** BRD-ABS-003
**FR Reference:** FR-ABS-003
**Feature:** LM-005

---

### Acceptance Criteria

**Scenario 1: Happy path — successful leave request submission**
```gherkin
GIVEN I am logged in as Employee "Nguyen Van A"
AND I have 8 available Annual Leave days
AND the dates 2026-04-07 to 2026-04-09 (3 days) contain no public holidays
AND I have no existing leave requests overlapping those dates
WHEN I submit a leave request for 3 days Annual Leave from Apr 7 to Apr 9
THEN the system creates a LeaveRequest with status SUBMITTED
AND creates a LeaveReservation of 3 days deducted from my available balance
AND my available balance displays 5 days (8 - 3)
AND I receive a push notification: "Leave request submitted — awaiting manager approval"
AND my manager receives an approval request notification
```

**Scenario 2: Submission blocked — insufficient balance**
```gherkin
GIVEN I am logged in as Employee "Le Thi B"
AND I have 2 available Annual Leave days
WHEN I attempt to submit a request for 5 days Annual Leave
THEN the system displays an error: "Insufficient balance: requested 5 days, available 2 days"
AND no LeaveRequest or LeaveReservation is created
AND my balance remains unchanged
```

**Scenario 3: Submission blocked — overlapping approved leave**
```gherkin
GIVEN I am logged in as Employee "Tran Van C"
AND I have an approved leave request from 2026-04-07 to 2026-04-08
WHEN I submit another request from 2026-04-07 to 2026-04-09
THEN the system displays an error: "A leave request already exists for overlapping dates"
AND the conflict dates are highlighted in the date picker
AND no new request is created
```

**Scenario 4: Request includes a public holiday (leave not deducted for holiday)**
```gherkin
GIVEN I am logged in as Employee "Pham Thi D"
AND I have 10 available Annual Leave days
AND I request leave from 2026-04-28 to 2026-05-04 (7 calendar days)
AND 2026-04-30 (Liberation Day) and 2026-05-01 (Labour Day) are public holidays
WHEN I submit the request
THEN the system calculates the leave duration as 5 working days (7 - 2 holidays)
AND creates a LeaveReservation of 5 days
AND the request summary shows: "5 working days requested (public holidays excluded)"
```

---

## US-ABS-002: View Leave Balance in Real Time

**As an** Employee
**I want to** view my current leave balances by type at any time
**So that** I can make informed decisions about when to take leave without contacting HR

**Priority:** P0
**Hypothesis:** H1
**BRD Reference:** BRD-ABS-004
**FR Reference:** FR-ABS-004
**Feature:** LM-007

---

### Acceptance Criteria

**Scenario 1: Happy path — employee views accurate balance**
```gherkin
GIVEN I am logged in as Employee "Nguyen Van A"
AND my Annual Leave ledger shows:
  - Jan accrual: +7 days
  - Feb accrual: +7 days
  - Leave taken Jan 15–17: -3 days
  - Approved future leave Mar 5–6: -2 days reservation
WHEN I open the Leave Balance screen
THEN I see:
  Annual Leave — Earned: 14 days | Used: 3 days | Reserved: 2 days | Available: 9 days
AND the balance loads in under 1 second
AND carried-over leave (if any) is shown separately with its expiry date
```

**Scenario 2: Manager views a team member's balance**
```gherkin
GIVEN I am logged in as Manager "Tran Thi E"
AND "Nguyen Van A" is a direct report in my team
WHEN I navigate to "Nguyen Van A"'s profile and open the Leave Balance tab
THEN I see the same balance breakdown as the employee would see
AND I can see all pending requests including SUBMITTED ones not yet actioned by me
```

**Scenario 3: Expired carried-over leave is excluded from available balance**
```gherkin
GIVEN I am logged in as Employee "Le Van F"
AND I had 5 days of carried-over leave that expired on 2026-03-01
AND today is 2026-03-24
WHEN I view my leave balance
THEN my available balance does NOT include the 5 expired days
AND my leave history shows: "5 days expired on 2026-03-01"
```

---

## US-ABS-003: Approve a Leave Request

**As a** Manager
**I want to** review and approve a leave request from my team member
**So that** the employee's time off is formally authorized and their balance is confirmed as deducted

**Priority:** P0
**Hypothesis:** H1
**BRD Reference:** BRD-ABS-003, BRD-SHD-003
**FR Reference:** FR-ABS-003, FR-WFL-001

---

### Acceptance Criteria

**Scenario 1: Happy path — manager approves request**
```gherkin
GIVEN I am logged in as Manager "Nguyen Thi G"
AND there is a pending leave request from "Pham Van H" for Apr 7–9 (3 days)
AND "Pham Van H" has sufficient available balance
AND the approval notification has been received
WHEN I open the request and click "Approve"
THEN the LeaveRequest status changes to APPROVED
AND the LeaveReservation is confirmed (to be converted to DEDUCTION on Apr 7)
AND "Pham Van H" receives: "Your leave request Apr 7–9 has been approved"
AND the approval is logged with my ID and timestamp
```

**Scenario 2: Manager sees team coverage before approving**
```gherkin
GIVEN I am logged in as Manager "Nguyen Thi G"
AND I have 2 other team members already approved on leave for Apr 7–9
WHEN I open "Pham Van H"'s leave request
THEN I see a team coverage summary: "3 team members out on Apr 7–9 (including this request)"
AND the names of other team members on leave are shown
AND I can choose to approve or reject with this context visible
```

---

## US-ABS-004: Reject a Leave Request

**As a** Manager
**I want to** reject a leave request with a documented reason
**So that** the employee understands why the request was declined and the reserved balance is released

**Priority:** P0
**Hypothesis:** H1
**BRD Reference:** BRD-ABS-003, BRD-SHD-003
**FR Reference:** FR-ABS-003, FR-WFL-001

---

### Acceptance Criteria

**Scenario 1: Happy path — manager rejects with reason**
```gherkin
GIVEN I am logged in as Manager "Le Van I"
AND there is a pending leave request from "Tran Thi J" for Apr 14–18 (5 days)
WHEN I open the request, enter reason "Critical project deadline week" and click "Reject"
THEN the LeaveRequest status changes to REJECTED
AND the LeaveReservation for 5 days is released
AND "Tran Thi J"'s available balance is restored by 5 days
AND "Tran Thi J" receives: "Your leave request Apr 14–18 has been rejected. Reason: Critical project deadline week"
```

**Scenario 2: Rejection requires a reason**
```gherkin
GIVEN I am logged in as Manager "Le Van I"
WHEN I attempt to reject a leave request without entering a reason
THEN the system displays: "A rejection reason is required"
AND the rejection is not submitted until a reason is provided
```

---

## US-ABS-005: Cancel a Leave Request Before Deadline

**As an** Employee
**I want to** cancel an approved leave request before the cancellation deadline
**So that** my plans can change without requiring manager involvement and my balance is fully restored

**Priority:** P0
**Hypothesis:** H1, H-P0-001 Resolved
**BRD Reference:** BRD-ABS-003
**FR Reference:** FR-ABS-003

---

### Acceptance Criteria

**Scenario 1: Happy path — self-cancel before deadline**
```gherkin
GIVEN I am logged in as Employee "Hoang Van K"
AND I have an approved leave request for 2026-04-10 to 2026-04-14 (5 days)
AND the cancellation deadline is 1 business day before leave start
AND today is 2026-04-07 (2 business days before Apr 10)
WHEN I navigate to the request and click "Cancel Leave"
THEN the system cancels the request without requiring manager approval
AND a reversal LeaveMovement of +5 days is created in my ledger
AND my available balance is restored by 5 days
AND I receive: "Leave cancelled. 5 days have been returned to your balance"
AND my manager receives: "Hoang Van K cancelled leave request Apr 10–14"
```

**Scenario 2: System correctly identifies deadline**
```gherkin
GIVEN the cancellation deadline policy is 1 business day before leave start
AND leave starts on Monday 2026-04-13
AND today is Friday 2026-04-10 (1 business day before)
WHEN I view the leave request
THEN the cancellation button is visible with note: "Last day to cancel without approval: today (2026-04-10)"
AND the self-cancel option is still available until end of business 2026-04-10
```

---

## US-ABS-006: Cancel a Leave Request After Deadline

**As an** Employee
**I want to** request cancellation of an approved leave after the deadline has passed
**So that** I can still cancel in exceptional circumstances with manager approval

**Priority:** P0
**Hypothesis:** H1, H-P0-001 Resolved
**BRD Reference:** BRD-ABS-003
**FR Reference:** FR-ABS-003

---

### Acceptance Criteria

**Scenario 1: Post-deadline cancellation requires manager approval**
```gherkin
GIVEN I am logged in as Employee "Nguyen Thi L"
AND I have an approved leave request for 2026-04-10 to 2026-04-14 (5 days)
AND today is 2026-04-09 (1 business day before — deadline passed)
WHEN I submit a cancellation request with reason "Family emergency resolved"
THEN the LeaveRequest transitions to CANCELLATION_PENDING
AND my balance remains reserved (not yet restored)
AND my manager receives an approval request: "Nguyen Thi L requests post-deadline cancellation — Apr 10–14"
AND I receive: "Your cancellation request has been sent to your manager for approval"
```

**Scenario 2: Manager approves post-deadline cancellation**
```gherkin
GIVEN a leave request for "Nguyen Thi L" is in CANCELLATION_PENDING status
WHEN my manager approves the cancellation
THEN the LeaveRequest transitions to CANCELLED
AND a reversal LeaveMovement of +5 days is created
AND my available balance is restored
AND I receive: "Your cancellation has been approved. 5 days restored to your balance"
```

**Scenario 3: Manager rejects post-deadline cancellation**
```gherkin
GIVEN a leave request for "Nguyen Thi L" is in CANCELLATION_PENDING status
WHEN my manager rejects the cancellation with reason "Cannot release coverage"
THEN the LeaveRequest returns to APPROVED status
AND my balance reservation is maintained
AND I receive: "Your cancellation request was not approved. Reason: Cannot release coverage"
```

---

## US-ABS-007: Configure a Leave Type

**As an** HR Administrator
**I want to** create and configure leave types with their entitlement rules and evidence requirements
**So that** the system accurately reflects our organization's leave categories without engineering changes

**Priority:** P0
**Hypothesis:** H1, H3
**BRD Reference:** BRD-ABS-001
**FR Reference:** FR-ABS-001
**Feature:** LM-001

---

### Acceptance Criteria

**Scenario 1: Happy path — create a custom leave type**
```gherkin
GIVEN I am logged in as HR Administrator "Tran Thi M"
WHEN I create a new leave type "Study Leave" with:
  - code: STUDY
  - unit: DAY
  - entitlement_basis: FIXED (5 days/year)
  - evidence_required: true
  - evidence_grace_period_days: 7
  - country_code: VN
THEN the leave type is created with status ACTIVE
AND it appears in the leave type list
AND it is available for policy assignment
AND a "LeaveTypeCreated" event is logged

Scenario 2: System rejects entitlement below Vietnam minimum for Annual Leave
```gherkin
GIVEN I am creating a leave policy for "Annual Leave"
WHEN I set the entitlement to 12 days
THEN the system rejects the input with:
  "Annual leave entitlement cannot be below 14 days per Vietnam Labor Code 2019, Article 113"
AND I am prompted to enter a compliant value
```

**Scenario 3: Deactivating a leave type warns of active balances**
```gherkin
GIVEN leave type "SICK" has 200 employees with non-zero balances
WHEN I attempt to deactivate "SICK"
THEN the system warns: "200 employees have active Sick Leave balances"
AND requires explicit confirmation
AND after confirmation, SICK is deactivated — new requests are blocked but history is preserved
```

---

## US-ABS-008: Define a Leave Policy with Accrual Rules

**As an** HR Administrator
**I want to** define leave policies that bind employees to leave types with seniority-based entitlements
**So that** the system automatically enforces Vietnam Labor Code minimums and our organization's rules

**Priority:** P0
**Hypothesis:** H1, H2, H3
**BRD Reference:** BRD-ABS-002
**FR Reference:** FR-ABS-002
**Feature:** LM-002

---

### Acceptance Criteria

**Scenario 1: Seniority-based entitlement configured correctly**
```gherkin
GIVEN I am logged in as HR Administrator "Tran Thi M"
WHEN I create an Annual Leave policy with seniority rules:
  - 0–4 years: 14 days
  - 5–9 years: 15 days
  - 10+ years: 16 days
THEN the policy is saved successfully
AND when employee "Nguyen Van N" (6 years service) is assigned this policy
THEN the system applies 15 days as the annual entitlement

Scenario 2: Policy change does not retroactively reduce earned balance
```gherkin
GIVEN employee "Le Thi O" has accrued 10 days under the existing policy
WHEN I reduce the annual entitlement from 14 to 12 days (hypothetically — system allows it above legal minimum)
THEN the existing 10 days in "Le Thi O"'s ledger are NOT reduced
AND only future accrual runs apply the new entitlement rate
AND I see a confirmation: "This change applies to future accruals only. Existing balances are unaffected."
```

---

## US-ABS-009: Configure an Accrual Plan

**As an** HR Administrator
**I want to** define accrual plans specifying how leave is earned (method, frequency, caps)
**So that** the system calculates accruals correctly without manual calculation

**Priority:** P0
**Hypothesis:** H2
**BRD Reference:** BRD-SHD-005
**FR Reference:** FR-ACC-001
**Feature:** AE-001

---

### Acceptance Criteria

**Scenario 1: HR Administrator creates a flat-rate monthly accrual plan**
```gherkin
GIVEN I am logged in as HR Administrator "Tran Thi M"
WHEN I create an accrual plan "Standard Annual Leave Accrual" with:
  - method: FLAT_RATE
  - frequency: MONTHLY
  - rate: 1.25 days per month
  - max_balance_cap: 30 days
  - effective_date: 2026-01-01
THEN the plan is saved and assigned to the Annual Leave policy
AND the system confirms: "Accrual plan will run monthly starting 2026-01-01"

Scenario 2: Balance cap prevents over-accrual
```gherkin
GIVEN employee "Pham Van P" has 29 available Annual Leave days
AND the accrual plan defines max_balance_cap: 30 days
WHEN the monthly accrual batch runs
THEN the system calculates: available (29) + rate (1.25) = 30.25 > cap (30)
AND creates a FLAT_RATE accrual movement of only 1 day (to reach cap exactly)
AND logs: "Accrual capped at 30 days for employee Pham Van P"
```

---

## US-ABS-010: Run Monthly Accrual Batch

**As the** System (automated process)
**I want to** process the monthly accrual batch for all eligible employees
**So that** every employee's leave balance is updated accurately and auditably each month

**Priority:** P0
**Hypothesis:** H1, H2
**BRD Reference:** BRD-SHD-005
**FR Reference:** FR-ACC-002
**Feature:** AE-002

---

### Acceptance Criteria

**Scenario 1: Batch runs successfully for all employees**
```gherkin
GIVEN it is the last day of March 2026 (2026-03-31)
AND 500 active employees are eligible for Annual Leave accrual
AND the accrual plan defines FLAT_RATE: 1.25 days/month
WHEN the scheduled accrual batch job runs at 23:00
THEN 500 LeaveMovement records of type ACCRUAL are created
AND each record has amount = 1.25 and period = "2026-03"
AND a BatchRun record is created with status COMPLETED and employee_count = 500
AND the HR Administrator receives: "March 2026 accrual batch complete: 500 employees processed"
AND the batch completes in < 30 minutes
```

**Scenario 2: Duplicate batch run is prevented (idempotency)**
```gherkin
GIVEN the March 2026 accrual batch was already completed at 23:00
WHEN a second batch run is triggered at 23:05 (recovery attempt)
THEN the system detects an existing COMPLETED BatchRun for period "2026-03"
AND skips execution without creating duplicate movements
AND logs: "Duplicate batch run prevented for period 2026-03"
```

**Scenario 3: Pro-rated accrual for new hire mid-month**
```gherkin
GIVEN employee "Tran Thi Q" was hired on 2026-03-15 (17 days remaining in month)
AND the accrual plan is FLAT_RATE: 1.25 days/month
WHEN the March 2026 accrual batch runs
THEN the system creates a ACCRUAL movement of 0.69 days (1.25 × 17/31)
AND the movement note reads: "Pro-rated accrual: hired 2026-03-15"
```

**Scenario 4: Batch failure triggers alert**
```gherkin
GIVEN the accrual batch encounters a database error after processing 300 of 500 employees
WHEN the failure is detected
THEN the batch is rolled back (no partial movements committed)
AND the BatchRun record is created with status FAILED and error_detail
AND the HR Administrator and Tech Lead receive an urgent alert:
  "March 2026 accrual batch FAILED. No balances were updated. Investigate immediately."
```

---

## US-ABS-011: Execute Year-End Carryover and Expiry

**As an** HR Administrator (with System automation)
**I want to** run the year-end carryover process that rolls over eligible balances and expires the rest
**So that** employees' leave balances accurately reflect the new year's entitlements per our policy

**Priority:** P0
**Hypothesis:** H1, H3
**BRD Reference:** BRD-SHD-006
**FR Reference:** FR-ACC-003
**Feature:** AE-004

---

### Acceptance Criteria

**Scenario 1: Carryover with maximum cap applied**
```gherkin
GIVEN employee "Hoang Thi R" has 8 unused Annual Leave days at year-end 2025
AND the carryover rule allows max 5 days, expiring March 31 of next year
WHEN the year-end carryover batch runs on 2025-12-31
THEN a CARRYOVER movement of +5 days is created with expiry_date = 2026-03-31
AND an EXPIRY movement of -3 days is created for the balance above the cap
AND the employee receives: "5 days carried over to 2026 (expire Mar 31, 2026). 3 days expired."
```

**Scenario 2: Carried-over balance expires on expiry date**
```gherkin
GIVEN employee "Hoang Thi R" has 5 carried-over days expiring 2026-03-31
AND the daily expiry job runs on 2026-04-01
WHEN the system evaluates expired balances
THEN an EXPIRY movement of -5 days is created in the ledger
AND the employee's available balance no longer includes the 5 days
AND the employee receives: "5 carried-over leave days expired on 2026-03-31"
```

---

## US-ABS-012: Handle Negative Balance at Termination

**As an** HR Administrator
**I want to** be alerted when a terminated employee has a negative leave balance and choose how to handle it
**So that** the organization complies with Vietnam Labor Code Article 21 (deduction requires written agreement)

**Priority:** P0
**Hypothesis:** H1, H-P0-004 Resolved
**BRD Reference:** BRD-SHD-007
**FR Reference:** FR-INT-001 (termination event handling)

---

### Acceptance Criteria

**Scenario 1: Default policy (Option B) — negative balance flagged for HR review**
```gherkin
GIVEN the tenant's termination policy is Option B (flag + HR manual approval)
AND employee "Nguyen Van S" is terminated with -3 days Annual Leave balance
WHEN the EmployeeTerminated event is received from Employee Central
THEN the system creates a TerminationBalanceRecord with balances_snapshot
AND flags the negative balance for HR review
AND notifies me (HR Administrator): "Termination balance review required: Nguyen Van S has -3 days Annual Leave"
AND the payroll export does NOT include an automatic deduction for this employee
```

**Scenario 2: HR Administrator approves deduction with written agreement**
```gherkin
GIVEN a TerminationBalanceRecord for "Nguyen Van S" is flagged and awaiting my review
AND I confirm that a written deduction agreement exists (signed by the employee)
WHEN I approve the payroll deduction
THEN a TERMINATION_DEDUCTION LeaveMovement is created
AND the deduction is included in the final payroll export for "Nguyen Van S"
AND my approval is logged with my ID and "written agreement confirmed" attestation
```

**Scenario 3: Rule-based threshold policy (Option D) auto-handles small negatives**
```gherkin
GIVEN the tenant's termination policy is Option D: negative ≤ 3 days → auto write-off
AND employee "Tran Van T" has -2 days Annual Leave at termination (within threshold)
WHEN the EmployeeTerminated event is received
THEN the system auto-applies write-off without HR action
AND creates a WRITE_OFF LeaveMovement of +2 days
AND notifies me: "Negative balance of 2 days written off for Tran Van T (threshold policy)"
AND no payroll deduction is created
```

---

## US-ATT-001: Clock In and Clock Out

**As an** Employee
**I want to** record my clock-in and clock-out from my mobile phone, web browser, or terminal
**So that** my worked hours are accurately tracked for timesheet and payroll purposes

**Priority:** P0
**Hypothesis:** H6
**BRD Reference:** BRD-ATT-001
**FR Reference:** FR-ATT-001
**Feature:** TT-001

---

### Acceptance Criteria

**Scenario 1: Mobile clock-in — happy path**
```gherkin
GIVEN I am logged in as Employee "Pham Thi U" on the mobile app
AND I am within 100 meters of "HQ Office" (geofence enabled)
AND I have no active clock-in for today
WHEN I tap "Clock In"
THEN the system creates a Punch record: type=CLOCK_IN, source=MOBILE
AND records my GPS coordinates at punch time (only at punch — not continuously)
AND confirms: "Clocked in at 08:02 AM"
AND my timesheet shows the punch event
```

**Scenario 2: Worked time calculated correctly**
```gherkin
GIVEN I clocked in at 08:00 and clocked out at 17:30
AND my assigned shift has a 60-minute unpaid lunch break
WHEN the system computes my WorkedPeriod
THEN worked_hours = 8.5 (9.5 - 1.0 break)
AND the WorkedPeriod record is stored with this computed value
```

**Scenario 3: Duplicate clock-in prevented**
```gherkin
GIVEN I am already clocked in (active punch since 08:00)
WHEN I attempt to clock in again
THEN the system shows: "You are already clocked in since 08:00 AM"
AND prompts: "Did you mean to clock out?"
AND no duplicate Punch record is created
```

**Scenario 4: Biometric punch stores token only — no raw data**
```gherkin
GIVEN a biometric device is registered for my office
WHEN I authenticate on the biometric device
THEN the third-party provider validates my fingerprint and returns a token
AND xTalent creates a Punch record with biometric_token_ref = "[token]"
AND the xTalent database contains no fingerprint data, image, or biometric template
```

---

## US-ATT-002: Request Overtime

**As an** Employee
**I want to** submit an overtime request before working extra hours
**So that** my overtime is formally authorized and I am compensated at the correct rate

**Priority:** P0
**Hypothesis:** H3
**BRD Reference:** BRD-ATT-002
**FR Reference:** FR-ATT-002
**Feature:** TT-003

---

### Acceptance Criteria

**Scenario 1: Happy path — OT request submitted for weekday**
```gherkin
GIVEN I am logged in as Employee "Le Van V"
AND my regular shift ends at 17:00 today (weekday)
AND I want to work until 19:00 (2 hours OT)
WHEN I submit an OT request for 2 hours at the weekday rate (150%)
THEN an OvertimeRequest is created with status SUBMITTED
AND my manager receives an approval notification with my YTD OT hours shown
AND I receive: "Overtime request submitted — awaiting approval"
```

**Scenario 2: System shows OT cap proximity on submission**
```gherkin
GIVEN I have 38 hours of approved OT this month (monthly cap: 40 hours)
WHEN I submit a request for 4 hours OT
THEN the system warns: "This request will bring your monthly OT to 42 hours (cap: 40 hours)"
AND my manager will be required to override with documented justification if they approve
```

**Scenario 3: OT on public holiday — correct rate shown**
```gherkin
GIVEN 2026-04-30 is Liberation Day (public holiday)
WHEN I submit an OT request for work on 2026-04-30
THEN the OT rate is shown as 300% (public holiday rate per VLC Article 98)
AND the request is flagged as PUBLIC_HOLIDAY category
```

---

## US-ATT-003: Approve an Overtime Request

**As a** Manager
**I want to** review and approve an employee's overtime request with visibility into their OT cap status
**So that** overtime is properly authorized and Vietnam Labor Code caps are enforced

**Priority:** P0
**Hypothesis:** H3, H-P0-003 Resolved
**BRD Reference:** BRD-ATT-002, BRD-SHD-003
**FR Reference:** FR-ATT-002, FR-WFL-001

---

### Acceptance Criteria

**Scenario 1: Happy path — manager approves OT within cap**
```gherkin
GIVEN I am logged in as Manager "Nguyen Thi W"
AND employee "Tran Van X" has 20 hours OT approved this month (cap: 40h)
AND "Tran Van X" submitted a 4-hour OT request
WHEN I open the request and approve it
THEN the OvertimeRequest status changes to APPROVED
AND "Tran Van X"'s monthly OT total is updated to 24 hours
AND "Tran Van X" receives an approval notification
```

**Scenario 2: System warns on OT cap breach during approval**
```gherkin
GIVEN employee "Pham Van Y" has 38 hours OT this month
AND a 4-hour OT request is pending
WHEN I attempt to approve the request
THEN the system shows a warning: "Approving this will bring Pham Van Y to 42 hours OT this month (cap: 40 hours)"
AND I must enter a documented justification to proceed
AND if I approve with override, the override is logged in the compliance audit trail
```

---

## US-ATT-004: Approve Manager's Own OT via Skip-Level Routing

**As a** Senior Manager (skip-level approver)
**I want to** receive and approve my direct report manager's overtime requests
**So that** managers cannot approve their own OT and costs are properly controlled

**Priority:** P0
**Hypothesis:** H-P0-003 Resolved
**BRD Reference:** BRD-SHD-003
**FR Reference:** FR-WFL-001

---

### Acceptance Criteria

**Scenario 1: Manager's OT auto-routes to skip-level (Mode 1 default)**
```gherkin
GIVEN manager "Nguyen Thi Z" reports to senior manager "Tran Van AA"
AND the OT approval chain is configured for Mode 1 (skip-level default)
WHEN "Nguyen Thi Z" submits an OT request for herself
THEN the system detects that "Nguyen Thi Z" is the Level 1 approver for her own requests
AND routes the request directly to "Tran Van AA" (skip-level line manager)
AND "Nguyen Thi Z" does NOT receive an approval task for her own request
AND "Tran Van AA" receives: "OT request from direct report manager Nguyen Thi Z — requires your approval"
```

**Scenario 2: Self-approval is blocked at system level**
```gherkin
GIVEN any manager submits a leave or OT request for themselves
WHEN the approval routing engine evaluates the request
THEN the system NEVER assigns the ApprovalTask to the submitter themselves
AND always applies skip-level routing (Mode 1) or custom workflow (Mode 2)
```

---

## US-ATT-005: Submit Timesheet for Period

**As an** Employee
**I want to** review my time entries for the period and submit my timesheet for manager approval
**So that** my worked hours are formally recorded and I can be paid correctly

**Priority:** P0
**Hypothesis:** H1
**BRD Reference:** BRD-ATT-003
**FR Reference:** FR-ATT-003
**Feature:** TT-002

---

### Acceptance Criteria

**Scenario 1: Happy path — employee submits timesheet**
```gherkin
GIVEN I am logged in as Employee "Le Thi BB"
AND it is 2026-03-31 (last day of period)
AND all my punches for March are reconciled (no missing clock-outs)
WHEN I review my timesheet and click "Submit"
THEN the timesheet status changes from OPEN to SUBMITTED
AND my manager receives a "Timesheet pending approval" notification
AND I can no longer edit the timesheet
AND I see: "Timesheet submitted on 2026-03-31 17:45"
```

**Scenario 2: Missing punch prevents submission**
```gherkin
GIVEN I have a missing clock-out on 2026-03-15 (no paired punch-out for that clock-in)
WHEN I attempt to submit my timesheet
THEN the system shows: "1 unresolved punch exception: missing clock-out on Mar 15"
AND provides a link to resolve the exception before submitting
AND does not allow submission until all exceptions are resolved
```

---

## US-ATT-006: Approve Timesheet

**As a** Manager
**I want to** review and approve my team members' timesheets before the period close
**So that** their payroll data is accurate and the period can be closed on time

**Priority:** P0
**Hypothesis:** H1
**BRD Reference:** BRD-ATT-003
**FR Reference:** FR-ATT-003

---

### Acceptance Criteria

**Scenario 1: Happy path — manager approves timesheet**
```gherkin
GIVEN I am logged in as Manager "Pham Van CC"
AND employee "Nguyen Thi DD"'s timesheet for March 2026 is in SUBMITTED status
WHEN I review the timesheet and click "Approve"
THEN the timesheet status changes to APPROVED
AND "Nguyen Thi DD" receives: "Timesheet for March 2026 approved"
AND the data is included in the period-close payroll export
```

**Scenario 2: Manager requests correction before approving**
```gherkin
GIVEN the timesheet shows an anomaly (15h worked on a single day)
WHEN I flag the entry and send it back to the employee with note "Please verify 15-hour entry on Mar 20"
THEN the timesheet status returns to OPEN
AND "Nguyen Thi DD" receives the correction request with my note
AND can edit the flagged entry before resubmitting
```

---

## US-SHD-001: Close a Payroll Period

**As an** HR Administrator
**I want to** close the payroll period once all timesheets are approved
**So that** the payroll export is triggered and the Payroll team can process payments on time

**Priority:** P0
**Hypothesis:** H1
**BRD Reference:** BRD-SHD-001
**FR Reference:** FR-INT-002

---

### Acceptance Criteria

**Scenario 1: Happy path — period close with all timesheets approved**
```gherkin
GIVEN I am logged in as HR Administrator "Tran Thi EE"
AND all 150 employee timesheets for March 2026 are in APPROVED status
AND period "March 2026" is in OPEN status
WHEN I initiate period close
THEN the system validates all timesheets are approved
AND generates the PayrollExportPackage for March 2026
AND changes period status to CLOSED
AND the Payroll Specialist receives: "March 2026 period closed — payroll export ready"
AND I receive a close confirmation with export summary
```

**Scenario 2: Period close blocked by unapproved timesheets**
```gherkin
GIVEN 12 timesheets are still in SUBMITTED status (awaiting manager approval)
WHEN I attempt to close the period
THEN the system blocks the close with:
  "12 timesheets are pending manager approval. Period cannot be closed."
AND displays the list of pending employees and their managers
AND I can choose to send reminder notifications to the relevant managers
```

---

## US-SHD-002: Export Payroll Data at Period Close

**As a** Payroll Officer
**I want to** receive a complete and accurate payroll data export when the period is closed
**So that** I can process payroll without manual data gathering or reconciliation

**Priority:** P0
**Hypothesis:** H1
**BRD Reference:** BRD-SHD-011
**FR Reference:** FR-INT-002

---

### Acceptance Criteria

**Scenario 1: Complete payroll export generated**
```gherkin
GIVEN period "March 2026" has been closed by HR Administrator
WHEN the payroll export is delivered to my Payroll module
THEN I receive a structured package containing:
  - Approved leave taken (by employee, by leave type, days/hours)
  - Worked hours (regular and OT, by employee and day)
  - OT hours categorized by rate (150%/200%/300%)
  - Any comp time cash-outs triggered during March
  - Period metadata (period_id, close_timestamp, generated_by)
AND all data matches what HR reviewed and approved
```

**Scenario 2: Re-running export is idempotent**
```gherkin
GIVEN the March 2026 export was delivered at 18:00
WHEN I re-trigger the export at 19:00 (to verify or for system recovery)
THEN the system returns the identical export package (same data, same package_id)
AND no duplicate records appear in the Payroll module
AND the system logs: "Export re-run — idempotent (no duplicate data)"
```

---

## US-SHD-003: Route Leave Request Through Multi-Level Approval

**As the** System
**I want to** automatically route leave and OT requests through the correct approval chain
**So that** every request reaches the right approvers in the right order without manual HR intervention

**Priority:** P0
**Hypothesis:** H1
**BRD Reference:** BRD-SHD-003
**FR Reference:** FR-WFL-001
**Feature:** WA-001

---

### Acceptance Criteria

**Scenario 1: Two-level approval chain — all levels complete**
```gherkin
GIVEN employee "Hoang Van FF" has a leave request requiring:
  Level 1: Direct Manager "Nguyen Thi GG"
  Level 2: HR Administrator
WHEN "Nguyen Thi GG" approves Level 1
THEN a Level 2 ApprovalTask is automatically created for the HR Admin role
AND the request remains UNDER_REVIEW until Level 2 completes
AND "Hoang Van FF" is notified: "Level 1 approved — awaiting HR review"
AND when HR Admin approves Level 2, the request transitions to APPROVED
```

**Scenario 2: Transfer during approval — routing updated dynamically**
```gherkin
GIVEN employee "Le Van HH" has a leave request at Level 1 awaiting old manager "Tran Thi II"
WHEN "Le Van HH" is transferred to new manager "Pham Van JJ" during the approval period
THEN the pending ApprovalTask is reassigned to "Pham Van JJ"
AND "Tran Thi II" receives: "Le Van HH has been transferred — approval reassigned"
AND "Pham Van JJ" receives the approval task notification
```

---

## US-SHD-004: Escalate Overdue Approval

**As the** System
**I want to** automatically escalate approval tasks that are not actioned within the configured timeout
**So that** requests are never permanently blocked by an unresponsive approver

**Priority:** P0
**Hypothesis:** H1
**BRD Reference:** BRD-SHD-003
**FR Reference:** FR-WFL-003

---

### Acceptance Criteria

**Scenario 1: Approval escalated after timeout**
```gherkin
GIVEN manager "Le Van KK" has an ApprovalTask for employee "Nguyen Thi LL"'s leave request
AND the configured approval timeout is 24 hours
AND 24 hours have elapsed without "Le Van KK" acting
WHEN the scheduled escalation job runs
THEN the ApprovalTask is marked ESCALATED
AND a new ApprovalTask is created for the configured escalation target (e.g., HR Admin)
AND "Le Van KK" receives: "Approval overdue — escalated to HR Administrator"
AND the escalation target receives: "Approval escalated: Nguyen Thi LL's leave request"
AND the request history shows: "Escalated at [timestamp] after 24-hour timeout"
```

---

## US-SHD-005: Configure Comp Time Expiry Policy

**As an** HR Administrator
**I want to** configure the organization's comp time expiry behavior (warning, extension, cash-out, or forfeiture)
**So that** employees are treated fairly and the company's financial obligations are managed consistently

**Priority:** P0
**Hypothesis:** H-P0-002 Resolved
**BRD Reference:** BRD-ATT-002
**FR Reference:** FR-ATT-002

---

### Acceptance Criteria

**Scenario 1: Configure comp time expiry to auto cash-out**
```gherkin
GIVEN I am logged in as HR Administrator "Tran Thi MM"
WHEN I navigate to Tenant Configuration > Comp Time Policy
AND I set:
  - expiry_warning_days: 14
  - expiry_action: AUTO_CASHOUT
THEN the configuration is saved
AND when any employee's comp time reaches the expiry date without being used
THEN the system auto-creates a cash-out record for the expired balance
AND includes it in the next payroll export
AND the employee receives: "Your comp time balance of X hours has been cashed out to payroll"
```

**Scenario 2: Configure comp time expiry to forfeiture**
```gherkin
GIVEN I configure expiry_action: FORFEITURE
AND employee "Nguyen Van NN" has 8 hours comp time expiring on 2026-04-07
AND the employee has not used it
WHEN the daily expiry job runs on 2026-04-07
THEN a FORFEITURE LeaveMovement of -8 hours is created
AND the employee's comp time balance is set to zero
AND the employee receives: "Your 8 hours of comp time expired on 2026-04-07"
AND the event is logged in the audit trail
```

---

## P1 User Stories

---

## US-ABS-013: View Team Leave Calendar

**As a** Manager
**I want to** see a visual calendar showing which team members are on leave on each day
**So that** I can assess team coverage when approving leave requests and planning work

**Priority:** P1
**Hypothesis:** H5
**BRD Reference:** BRD-ABS-006
**FR Reference:** FR-ABS-006
**Feature:** LM-006

---

### Acceptance Criteria

**Scenario 1: Manager views monthly team calendar**
```gherkin
GIVEN I am logged in as Manager "Pham Thi OO"
AND my team has 10 members
AND 3 members have approved leave on 2026-04-07 to 2026-04-09
WHEN I open the Team Calendar for April 2026
THEN April 7–9 shows the names of 3 team members on leave
AND days with >30% team absence are visually highlighted
AND I can click any day to see the full list with leave types
```

**Scenario 2: Calendar shows pending requests alongside approved**
```gherkin
GIVEN employee "Nguyen Van PP" has a SUBMITTED (not yet approved) request for Apr 15–16
WHEN I view the team calendar
THEN the pending request is shown with a "pending" indicator
AND it is visually distinct from approved leave
```

---

## US-ABS-014: Initiate Leave Request from Calendar

**As an** Employee
**I want to** start a leave request by selecting dates on the team calendar
**So that** I can see who else is already out before committing to dates

**Priority:** P1
**Hypothesis:** H5
**BRD Reference:** BRD-ABS-006
**FR Reference:** FR-ABS-006

---

### Acceptance Criteria

**Scenario 1: Employee selects dates and sees conflicts**
```gherkin
GIVEN I am logged in as Employee "Le Thi QQ"
AND I open the team calendar for April 2026
AND 4 team members already have approved leave for Apr 21–25
WHEN I click and drag to select Apr 21–25 as my leave dates
THEN the calendar shows: "4 team members are already out this week"
AND the leave request form opens pre-filled with my selected dates
AND I can proceed to submit or choose different dates
```

---

## US-ABS-015: View Leave Reservation Status

**As an** Employee
**I want to** see how my pending leave requests affect my available balance
**So that** I understand exactly how much leave I can still request

**Priority:** P1
**Hypothesis:** H1
**BRD Reference:** BRD-ABS-005
**FR Reference:** FR-ABS-005
**Feature:** LM-008

---

### Acceptance Criteria

**Scenario 1: Balance breakdown shows reservations separately**
```gherkin
GIVEN I am logged in as Employee "Tran Van RR"
AND I have a SUBMITTED leave request (not yet approved) for 3 days
WHEN I view my leave balance
THEN I see:
  Annual Leave — Earned: 14 | Used: 3 | Reserved: 3 | Available: 8
AND the reserved amount is annotated: "3 days reserved (pending approval)"
AND clicking the reserved amount shows the pending request details
```

---

## US-ATT-007: Assign Shift to Employee

**As an** HR Administrator
**I want to** assign work shifts to employees or groups for a date range
**So that** the system can detect attendance exceptions (late arrival, absence) against scheduled shifts

**Priority:** P1
**Hypothesis:** H1
**BRD Reference:** BRD-ATT-004
**FR Reference:** FR-ATT-004
**Feature:** TT-004

---

### Acceptance Criteria

**Scenario 1: HR Administrator assigns shift to a team**
```gherkin
GIVEN I am logged in as HR Administrator "Nguyen Thi SS"
AND the "Morning Shift" is defined: 06:00–14:00, 30 min break, 10 min grace
WHEN I assign Morning Shift to the "Factory Line A" group from 2026-04-01 to 2026-06-30
THEN all 25 employees in Factory Line A are assigned this shift for the date range
AND the system confirms: "Shift assigned to 25 employees: Apr 1 – Jun 30"
AND the attendance engine will compare punches against this schedule from April 1
```

**Scenario 2: Late arrival exception is detected**
```gherkin
GIVEN employee "Pham Van TT" is assigned Morning Shift (start 06:00, grace 10 min)
AND the employee clocks in at 06:18
WHEN the system evaluates the punch
THEN a "LateArrivalDetected" event is created: lateness = 8 minutes
AND the event appears on the manager's exception dashboard
```

---

## US-ATT-008: Request Shift Swap with Colleague

**As an** Employee
**I want to** request a shift swap with a colleague
**So that** I have flexibility in my schedule without needing HR to manually update assignments

**Priority:** P1
**Hypothesis:** H1
**BRD Reference:** BRD-ATT-005
**FR Reference:** FR-ATT-005
**Feature:** TT-005

---

### Acceptance Criteria

**Scenario 1: Happy path — valid swap request**
```gherkin
GIVEN I am logged in as Employee "Nguyen Van UU"
AND I am assigned Morning Shift on 2026-04-07
AND employee "Tran Thi VV" is assigned Afternoon Shift on 2026-04-07
WHEN I request a shift swap with "Tran Thi VV"
AND "Tran Thi VV" accepts the request
THEN the swap request is routed to our manager for approval
AND neither shift assignment is changed until manager approves
AND both of us receive: "Swap request pending manager approval"
```

**Scenario 2: Swap blocked if it violates minimum rest period**
```gherkin
GIVEN I work Afternoon Shift ending at 22:00 on 2026-04-07
AND the proposed swap would assign me Morning Shift starting 06:00 on 2026-04-08
AND the rest period would be 8 hours (minimum per VLC Article 109)
WHEN the swap is evaluated
THEN the system blocks submission with:
  "This swap results in less than the minimum rest period between shifts (Vietnam Labor Code Article 109)"
AND I cannot submit the swap request
```

---

## US-SHD-006: Delegate Approval Authority

**As a** Manager
**I want to** delegate my approval authority to a trusted colleague when I am on leave
**So that** team requests are not blocked during my absence

**Priority:** P1
**Hypothesis:** H1
**BRD Reference:** BRD-SHD-003 (open hot spot H-P1-008)
**FR Reference:** FR-WFL-003
**Note:** Resolution of H-P1-008 required before implementation.

---

### Acceptance Criteria

**Scenario 1: Manager delegates approval authority**
```gherkin
GIVEN I am logged in as Manager "Le Van WW"
AND I am going on leave from 2026-04-14 to 2026-04-18
WHEN I delegate approval authority to "Pham Thi XX" for that date range
THEN all approval tasks assigned to me during Apr 14–18 are also sent to "Pham Thi XX"
AND "Pham Thi XX" can approve on my behalf
AND the delegation is logged in the audit trail with my authorization
```

---

## US-SHD-007: View Pending Approvals Dashboard

**As a** Manager
**I want to** see all my pending approvals (leave, OT, shift swaps, timesheets) in a single view
**So that** I can efficiently manage my team's requests without checking multiple screens

**Priority:** P1
**Hypothesis:** H5
**BRD Reference:** BRD-SHD-009
**FR Reference:** FR-WFL-004
**Feature:** WA-006

---

### Acceptance Criteria

**Scenario 1: Dashboard shows consolidated approvals**
```gherkin
GIVEN I am logged in as Manager "Nguyen Thi YY"
AND I have 3 pending leave requests, 2 OT requests, and 8 timesheets awaiting approval
WHEN I open the Approvals Dashboard
THEN I see all 13 items in a unified list
AND I can filter by type (leave / OT / timesheet)
AND I can sort by submission date or employee name
AND I can bulk-select and approve all timesheets in one action
```

---

## US-SHD-008: Generate Leave Balance Report

**As an** HR Administrator
**I want to** generate a leave balance report by employee, team, or organization for any period
**So that** I can monitor entitlement consumption, plan budget, and provide data for audits

**Priority:** P1
**Hypothesis:** H1
**BRD Reference:** FR-ANL-001
**FR Reference:** FR-ANL-001
**Feature:** AR-001

---

### Acceptance Criteria

**Scenario 1: HR Administrator generates team balance report**
```gherkin
GIVEN I am logged in as HR Administrator "Tran Van ZZ"
WHEN I generate a leave balance report for department "Engineering" for the period Jan–Mar 2026
THEN the report shows for each employee:
  - Earned, Used, Reserved, Available balance by leave type
  - Expiring balances with dates
AND the report is exportable to CSV and Excel
AND it loads within 5 seconds for up to 500 employees
```

---

*End of User Stories Document*

**Coverage Summary:**
- P0 Stories: 23 (US-ABS-001 through US-ABS-012, US-ATT-001 through US-ATT-006, US-SHD-001 through US-SHD-005)
- P1 Stories: 8 (US-ABS-013 through US-ABS-015, US-ATT-007 through US-ATT-008, US-SHD-006 through US-SHD-008)
- Total: 31 user stories
- All 4 resolved P0 hot spots covered: H-P0-001 (US-ABS-005/006), H-P0-002 (US-SHD-005), H-P0-003 (US-ATT-004), H-P0-004 (US-ABS-012)
- All personas represented: Employee, Manager, HR Administrator, Payroll Officer, System
- All stories trace to BRD requirements and hypothesis IDs
