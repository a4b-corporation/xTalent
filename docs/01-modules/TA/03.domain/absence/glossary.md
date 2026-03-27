# Glossary: ta.absence — Absence Management

**Bounded Context:** `ta.absence`
**Module:** xTalent HCM — Time & Absence
**Step:** 3 — Domain Architecture
**Date:** 2026-03-24
**Version:** 1.0

This glossary defines the ubiquitous language for the Absence Management bounded context. All engineers, product owners, and business stakeholders must use these terms consistently when discussing `ta.absence`.

---

## LeaveType

**Definition:** A named configuration object that defines the category, entitlement basis, evidence requirements, and policy rules for a specific kind of absence. LeaveType is the configuration root from which all absence behavior derives.

**Also known as:** Leave category, absence type, time-off type (in US HR software)

**Distinguishing from:** LeavePolicy (which binds a LeaveType to an employee group with accrual rules); LeaveClass (which groups multiple LeaveTypes for shared deduction priority)

**Business rules:**
- Code must be unique within a tenant (BRD-ABS-001)
- Annual leave type entitlement floor is 14 days per Vietnam Labor Code 2019, Article 113
- Deactivating a LeaveType does not delete history; existing balance records are preserved
- `cancellation_deadline_days`: configurable per LeaveType — the number of business days before leave start after which self-cancellation is no longer permitted (H-P0-001)
- `expiry_action`: configurable action when balance expires — EXTENSION, CASHOUT, or FORFEITURE (H-P0-002)

**Example:** `ANNUAL` — code: "ANNUAL", entitlement_basis: ACCRUAL, unit: DAY, carryover_eligible: true, country_code: "VN", cancellation_deadline_days: 1

---

## LeaveClass

**Definition:** A grouping of related LeaveTypes that share a common deduction priority policy. When an employee submits a request under a LeaveClass, the system applies the configured deduction order (e.g., Sick Leave before Unpaid Leave) if one balance is exhausted.

**Also known as:** Leave group, absence category grouping

**Distinguishing from:** LeaveType (individual leave category); LeavePolicy (binding to employee group with accrual rules)

**Business rules:**
- A LeaveClass must contain at least one LeaveType
- Deduction priority is a ranked ordered list; lower rank number = consumed first
- When primary balance is exhausted, system draws from secondary LeaveType in the class and must display a confirmation to the employee

**Example:** "Medical Leave" class — priority 1: SICK_LEAVE, priority 2: UNPAID_LEAVE. If sick leave balance is zero, the system draws from unpaid leave with employee acknowledgement.

---

## LeavePolicy

**Definition:** The binding configuration that applies a LeaveType (or set of LeaveTypes) to a specific employee group, defining accrual rules, seniority multipliers, eligibility constraints, carryover limits, and probation handling.

**Also known as:** Entitlement policy, absence policy, leave scheme

**Distinguishing from:** LeaveType (the what); AccrualPlan (the how of earning); LeavePolicy (the who and when)

**Business rules:**
- Policy entitlement cannot be set below the VLC minimum for Annual Leave (14 days for < 5 years service)
- Seniority multipliers must follow VLC Article 113 minimums as a floor
- Policy changes are not retroactive — existing accrued balances are preserved
- One policy per leave type per employee group per effective date period

**Example:** "Standard Annual Leave Policy — Grade 3-5" — leave_type: ANNUAL, base_entitlement: 14 days, seniority_rules: [{min_years: 5, entitlement_days: 15}, {min_years: 10, entitlement_days: 16}], accrual_plan_id: "AP-001"

---

## LeaveInstant

**Definition:** The computed, point-in-time balance state of an employee's leave entitlement for a specific LeaveType. LeaveInstant is a read model — its values are derived from the complete history of LeaveMovement records for that employee and leave type combination.

**Also known as:** Leave balance snapshot, entitlement balance, leave ledger position

**Distinguishing from:** LeaveMovement (the individual immutable events that constitute the ledger); LeaveBalance (a synonym in some HR systems — same concept here)

**Business rules:**
- `available = earned - used - reserved` (BR-ABS-005)
- Available balance may not go negative unless `allow_advance_leave = true` on the LeaveType
- A separate LeaveInstant record exists per employee per LeaveType per policy period
- LeaveInstant is recomputed from the full movement stream on every balance query (ADR-TA-001)

**Example:** Employee "Nguyen Van A" for ANNUAL leave: earned = 14 days, used = 3 days, reserved = 2 days, available = 9 days.

---

## LeaveBalance

**Definition:** The human-readable presentation of a LeaveInstant, broken down into earned, used, reserved, available, and expiring_soon components.

**Also known as:** Balance summary, leave entitlement summary

**Distinguishing from:** LeaveInstant (the aggregate that holds the computation); LeaveBalance is the view/read model projected from LeaveInstant

**Business rules:**
- `expiring_soon` shows balance expiring within 30 days
- Balance query must respond in < 1 second (p95) for up to 1,000 concurrent users (OBJ-ABS-03)

**Example:** Displayed on employee dashboard — Earned: 14d | Used: 3d | Reserved: 2d | Available: 9d | Expiring soon: 3d (by 2026-03-31)

---

## LeaveMovement

**Definition:** An immutable ledger record of a single balance change event. Every credit or debit to a leave balance — whether from accrual, deduction, reservation, release, expiry, adjustment, or cash-out — is recorded as a LeaveMovement. The complete balance at any point in time is computed by summing all LeaveMovement records for the employee and leave type.

**Also known as:** Leave transaction, balance event, ledger entry

**Distinguishing from:** LeaveRequest (the employee's request for time off, which is the business object); LeaveMovement (the financial/ledger event that records the balance impact)

**Business rules:**
- Immutable after creation — no UPDATE or DELETE operations are permitted (ADR-TA-001)
- `movement_type` must be one of: EARN, USE, RESERVE, RELEASE, EXPIRE, ADJUST, CASHOUT
- `amount` must not be zero
- Every balance change has exactly one movement record; gaps in the audit trail are a system fault
- FEFO (First-Expired-First-Out) ordering applied when creating RESERVE and USE movements

**Example:** Type: EARN, amount: +7 days, effective_date: 2026-03-31, reference: "AccrualBatch-2026-03", expiry_date: 2026-12-31

---

## LeaveRequest

**Definition:** An employee-initiated request for time off, capturing the leave type, date range, and reason. LeaveRequest is the primary workflow object in `ta.absence`. It follows a defined state machine from SUBMITTED through to APPROVED, REJECTED, or CANCELLED.

**Also known as:** Leave application, time-off request, absence request

**Distinguishing from:** LeaveMovement (the ledger events that record the balance impact); LeaveReservation (the provisional hold placed on balance when the request is submitted)

**Business rules:**
- State machine: SUBMITTED → UNDER_REVIEW → APPROVED | REJECTED; or APPROVED → CANCELLATION_PENDING → CANCELLED (H-P0-001)
- A LeaveReservation is created at SUBMITTED; it is released on REJECTED or CANCELLED, converted to deduction on APPROVED
- Balance must be available at submission time (after applying existing reservations)
- Cancellation before `cancellation_deadline_days`: self-cancel permitted
- Cancellation after `cancellation_deadline_days`: requires manager approval (H-P0-001)

**Example:** Employee requests 3 days Annual Leave from 2026-04-07 to 2026-04-09; status: UNDER_REVIEW; reservation: 3 days ANNUAL.

---

## LeaveReservation

**Definition:** A provisional, temporary hold placed on a portion of an employee's leave balance when a leave request is submitted. The reservation prevents the same balance from being committed to a second concurrent request (overbooking prevention). It is confirmed or released based on the outcome of the LeaveRequest approval.

**Also known as:** Leave hold, balance lock, pending deduction

**Distinguishing from:** LeaveMovement of type RESERVE (the ledger record of the reservation); LeaveReservation (the business-level tracking object that links a request to its reserved amount)

**Business rules:**
- Cannot exceed the available balance at the time of reservation
- FEFO applied: earliest-expiring balance consumed first (BR-ABS-005-01)
- Released on REJECTED or CANCELLED (pre-deadline)
- Converted to a USE-type LeaveMovement on leave start date when APPROVED
- Maintained during CANCELLATION_PENDING state

**Example:** Request for 3 days reserves: 2 days from carried-over balance (expiry 2026-03-31) + 1 day from current-year accrual (expiry 2026-12-31).

---

## LeaveEntitlement

**Definition:** The total number of leave days an employee is entitled to in a given policy year, as determined by their LeavePolicy, seniority rules, and Vietnam Labor Code minimums.

**Also known as:** Annual entitlement, leave allowance

**Distinguishing from:** LeaveBalance (the current state of what has been earned, used, and reserved); LeaveEntitlement (the target total for the year)

**Business rules:**
- Annual leave entitlement: minimum 14 days for < 5 years service; 15 days at 5 years; increases per VLC Article 113
- Entitlement is set at policy assignment time and recorded as an EARN movement

**Example:** Employee with 6 years of service receives 15 days annual leave entitlement for 2026.

---

## AccrualPlan

**Definition:** The configuration that specifies how leave entitlement is earned over time — the accrual method (monthly, annual, front-loaded), frequency, amount per period, and applicable caps. AccrualPlan governs the behavior of the monthly accrual batch job.

**Also known as:** Accrual schedule, leave earning rule, entitlement schedule

**Distinguishing from:** LeavePolicy (the eligibility and entitlement binding); AccrualPlan (the mechanics of how earning happens over time)

**Business rules:**
- Accrual batch runs are idempotent — duplicate runs for the same period are rejected (ADR-TA-002)
- Partial batch commits are rolled back on failure (no partial accrual)
- One AccrualBatchRun per period per AccrualPlan

**Example:** Monthly accrual — method: MONTHLY_PRO_RATA, amount_per_month: 1.167 days (14 days / 12 months), max_balance: 30 days.

---

## AccrualPeriod

**Definition:** The time window for which an accrual batch run calculates and credits leave earnings. Typically corresponds to a calendar month or payroll period.

**Also known as:** Accrual cycle, earning period

**Distinguishing from:** PayPeriod (shared concept in ta.shared); AccrualPeriod is specific to leave earning calculations

**Business rules:**
- Accrual is calculated up to the last working day of the accrual period
- Partial month employment is pro-rated based on hire date within the period

**Example:** AccrualPeriod: March 2026 (2026-03-01 to 2026-03-31)

---

## FEFO (First-Expired-First-Out)

**Definition:** The reservation and deduction ordering rule that ensures leave balances with the earliest expiry date are consumed first. This prevents employees from losing carried-over leave to expiry while current-year leave remains untouched.

**Also known as:** Expiry-first deduction, FIFO expiry order

**Distinguishing from:** FIFO (First-In-First-Out) — FEFO is based on expiry date, not creation date

**Business rules:**
- Applied at every LeaveReservation creation and USE movement creation
- The system must track which source movement IDs are being consumed by each reservation
- Ensures carried-over leave (shorter expiry) is consumed before current-year leave

**Example:** Employee has 3 days carried-over (expiry 2026-03-31) and 7 days current-year (expiry 2026-12-31). A 4-day request consumes 3 days from carryover first, then 1 day from current-year.

---

## CarryOver

**Definition:** The transfer of unused leave balance from one policy year to the next, subject to the configured CarryoverRule. Carryover is executed by a year-end batch job that creates EARN-type LeaveMovements with the carried-over amount and a new expiry date.

**Also known as:** Balance rollover, leave transfer, year-end rollover

**Distinguishing from:** LeaveEntitlement (the current-year allocation); CarryOver (the amount brought forward from prior year)

**Business rules:**
- `carryover_eligible` must be true on the LeaveType
- Carryover cap configurable per policy (e.g., maximum 5 days can carry over)
- Carried-over balance has a configurable expiry date (typically 3–6 months into the new year)
- CarryoverRule defines the cap and expiry date

**Example:** Employee has 8 unused Annual Leave days at year-end. CarryoverRule caps carryover at 5 days, expiry 2026-03-31. System creates: 5-day EARN movement (carryover, expiry 2026-03-31), and 3 days are forfeited.

---

## LeaveExpiry

**Definition:** The date after which a leave balance (typically carried-over leave) can no longer be used. When a LeaveMovement's expiry date is reached and the balance has not been consumed, the system applies the configured expiry action.

**Also known as:** Balance expiration, leave forfeiture date

**Distinguishing from:** CarryOver expiry (the most common case); LeaveExpiry applies to any movement with an `expiry_date` set

**Business rules:**
- Expiry action is configurable per LeaveType: EXTENSION, CASHOUT, or FORFEITURE (H-P0-002)
- Warning notification sent N days before expiry (N configurable, default: 14 days for comp time; separate configuration for annual leave)
- EXPIRE-type LeaveMovement created on expiry date

**Example:** Carried-over 5 days expire on 2026-03-31. Employee has used 2 days. On 2026-03-31, system creates EXPIRE movement for -3 days.

---

## AdvanceLeave

**Definition:** Leave taken in excess of the currently available balance, permitted only when the LeaveType has `allow_advance_leave = true`. The negative balance is expected to be covered by future accrual.

**Also known as:** Leave advance, negative balance leave, borrowed leave

**Distinguishing from:** NegativeBalance (which refers specifically to the balance at termination — see below)

**Business rules:**
- Only permitted when `allow_advance_leave = true` on LeaveType
- Maximum advance amount configurable per policy
- At termination, advance leave becomes a NegativeBalance and is subject to H-P0-004 policy

**Example:** Employee has 0 days available but is permitted to take 2 days advance leave under the company's advance leave policy.

---

## NegativeBalance

**Definition:** A leave balance that is less than zero, occurring when an employee has taken more leave than they have earned. Most commonly occurs when an employee is terminated before they have accrued sufficient leave to cover approved leave taken.

**Also known as:** Leave deficit, leave debt, balance shortfall

**Distinguishing from:** AdvanceLeave (the approved act of taking leave before earning it); NegativeBalance (the resulting balance state, which must be resolved at termination per H-P0-004)

**Business rules:**
- At termination, negative balance handling is configured per tenant (H-P0-004):
  - Option A: Automatic payroll deduction
  - Option B (default): HR review and manual approval required
  - Option C: Write-off (forgiven)
  - Option D: Rule-based threshold (e.g., ≤ 3 days write-off, > 3 days HR review)
- Payroll deduction for negative balance requires written employee agreement (VLC Article 21)

**Example:** Employee terminated with -3 days annual leave balance. Under Option B (default), HR is alerted. HR reviews and approves deduction. Deduction appears in final payroll export.

---

## CancellationDeadline

**Definition:** The configurable threshold — expressed in business days before the leave start date — before which an employee may self-cancel a leave request without manager approval. After this deadline, the cancellation requires manager approval.

**Also known as:** Self-cancel cutoff, cancellation window, notice period for cancellation

**Distinguishing from:** The leave start date itself; CancellationDeadline is a number of days before that date

**Business rules:**
- Stored as `cancellation_deadline_days` on LeaveType (H-P0-001 resolved)
- Configurable per BU or tenant; system default is 1 business day before leave start
- Before deadline: employee self-cancels; full balance restored immediately
- At or after deadline: CancellationRequest submitted; balance held until manager acts
- Manager rejection of post-deadline cancellation returns LeaveRequest to APPROVED status

**Example:** `cancellation_deadline_days = 1`. Leave starts 2026-04-10 (Thursday). Deadline = 2026-04-09 (Wednesday) end of business. If employee cancels on 2026-04-09 morning, it is self-cancel. If they cancel on 2026-04-09 evening, it requires manager approval.

---

## Integration Points

| Concept | From Context | Data Exchanged |
|---------|-------------|----------------|
| `EmployeeHired` event | Employee Central (via ta.shared) | Employment start date, job grade, org unit → triggers LeavePolicy assignment |
| `HolidayCalendarPublished` event | ta.shared | Public holidays → excluded from leave duration calculation |
| `PeriodClosed` event | ta.shared | Triggers leave deduction finalization and payroll export contribution |
| `PayrollExportPackage` | → Payroll Module | Approved leave by type, negative balance records, encashment records |
