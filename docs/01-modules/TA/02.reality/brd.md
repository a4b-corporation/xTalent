# Business Requirements Document: Time & Absence Module

**Module:** Time & Absence (TA)
**Product:** xTalent HCM
**Step:** 2 — Reality / Specify
**Version:** 1.0
**Date:** 2026-03-24
**Status:** DRAFT — Pending Gate G2 Approval
**Authors:** Business Analyst Agent (Step 2)
**Reviewers:** Product Owner, Legal Counsel, Tech Lead

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-03-24 | BA Agent Step 2 | Initial BRD — all 4 P0 hot spots incorporated as business rules |

---

## Table of Contents

- [Part 1: Absence Management (ta.absence)](#part-1-absence-management-taabsence)
  - [1.1 Business Objectives](#11-business-objectives)
  - [1.2 Scope and Bounded Context](#12-scope-and-bounded-context)
  - [1.3 Stakeholders and Personas](#13-stakeholders-and-personas)
  - [1.4 Functional Requirements](#14-functional-requirements)
  - [1.5 Business Rules](#15-business-rules)
  - [1.6 Integration Contracts](#16-integration-contracts)
- [Part 2: Time and Attendance (ta.attendance)](#part-2-time-and-attendance-taattendance)
  - [2.1 Business Objectives](#21-business-objectives)
  - [2.2 Scope and Bounded Context](#22-scope-and-bounded-context)
  - [2.3 Stakeholders and Personas](#23-stakeholders-and-personas)
  - [2.4 Functional Requirements](#24-functional-requirements)
  - [2.5 Business Rules](#25-business-rules)
  - [2.6 Integration Contracts](#26-integration-contracts)
- [Part 3: Shared Services (ta.shared)](#part-3-shared-services-tashared)
  - [3.1 Business Objectives](#31-business-objectives)
  - [3.2 Scope and Bounded Context](#32-scope-and-bounded-context)
  - [3.3 Stakeholders and Personas](#33-stakeholders-and-personas)
  - [3.4 Functional Requirements](#34-functional-requirements)
  - [3.5 Non-Functional Requirements](#35-non-functional-requirements)
  - [3.6 Compliance Requirements](#36-compliance-requirements)
  - [3.7 Open Questions (Architecture — Step 4)](#37-open-questions-architecture--step-4)

---

# Part 1: Absence Management (ta.absence)

## 1.1 Business Objectives

| ID | Objective | Metric | Target | Timeline | Baseline |
|----|-----------|--------|--------|----------|----------|
| OBJ-ABS-01 | Eliminate manual leave balance reconciliation | % HR time spent on manual balance reconciliation | Reduce from ~60% to <10% | By MVP launch | Estimated from problem statement interviews |
| OBJ-ABS-02 | Achieve 100% Vietnam Labor Code 2019 compliance for leave entitlements | Compliance audit pass rate | 100% (zero findings) | MVP | Current: estimated 70% (manual process) |
| OBJ-ABS-03 | Provide real-time employee leave balance visibility | Balance query response time (p95) | < 1 second for up to 1,000 concurrent users | MVP | N/A (no self-service today) |
| OBJ-ABS-04 | Enable end-to-end digital leave approval | % leave requests processed without manual HR intervention | > 90% | 6 months post-launch | Current: ~30% digital |
| OBJ-ABS-05 | Achieve high system usability for employee self-service | SUS score for employee leave request flow | > 75 | 3 months post-launch | N/A |

## 1.2 Scope and Bounded Context

**Bounded Context:** `ta.absence`

**In Scope:**
- Leave type and policy configuration
- Leave request lifecycle (submit, approve, reject, cancel)
- Leave balance management via event-driven ledger (ADR-TA-001)
- Leave reservation (overbooking prevention)
- Accrual plan setup and batch processing
- Year-end carryover and expiry
- Leave cancellation policy (H-P0-001 resolved)
- Leave balance at termination (H-P0-004 resolved)

**Out of Scope (refer to module boundaries in requirements.md Section 8):**
- Payroll calculation (only export structured data)
- Social Insurance Fund direct integration (Maternity Leave — Phase 2)
- Predictive absence analytics (Phase 2)
- US FMLA / EU Working Time Directive (Phase 3)

**Core Entities:**

| Entity | Stability | Description |
|--------|-----------|-------------|
| LeaveType | HIGH | Configuration of leave categories (Annual, Sick, Maternity, Unpaid, Custom) |
| LeaveClass | MEDIUM | Grouping of leave types for shared policy rules |
| LeavePolicy | MEDIUM | Binding of employee groups to leave types with accrual rules |
| LeaveInstant | HIGH | Point-in-time snapshot of an employee's balance by leave type |
| LeaveMovement | HIGH | Immutable ledger record of every balance change event |
| LeaveRequest | MEDIUM | Employee request for time off (full lifecycle) |
| LeaveReservation | MEDIUM | Provisional hold on balance pending approval outcome |
| AccrualPlan | MEDIUM | Configuration of how leave is earned (method, frequency, caps) |
| CarryoverRule | MEDIUM | Configuration of year-end balance treatment |

## 1.3 Stakeholders and Personas

| Persona | Role in ta.absence | Primary Needs |
|---------|-------------------|---------------|
| HR Administrator | Configures leave types, policies, accrual plans; runs batch processes; resolves exceptions | Self-service configuration; audit trail; compliance reports |
| Manager | Approves/rejects leave requests; views team availability | Team calendar; pending approvals; balance visibility per team member |
| Employee | Submits leave requests; checks balances; views own history | Mobile-friendly self-service; real-time balance; status notifications |
| Payroll Specialist | Consumes period-close leave export | Accurate, structured, idempotent export at period close |
| System (automated) | Runs accrual batch; enforces expiry; sends notifications | Scheduled execution; audit logs; failure alerts |

## 1.4 Functional Requirements

---

### BRD-ABS-001 — Leave Type Configuration

**Priority:** P0
**FR Reference:** FR-ABS-001
**Feature:** LM-001
**Hypothesis Traceability:** H1, H3

**Business Requirement:**
HR Administrators must be able to create and configure leave types without engineering assistance. Each leave type encapsulates its own rules for entitlement, evidence requirements, and policy applicability. At MVP, the system must support the four leave types mandated by Vietnam Labor Code 2019, plus the ability to create custom types.

**Standard Vietnam Leave Types (pre-configured at tenant setup):**

| Leave Type Code | VN Name | Entitlement Basis | VLC Reference |
|----------------|---------|-------------------|---------------|
| ANNUAL | Nghỉ phép năm | Tenure-based seniority accrual | Article 113, VLC 2019 |
| SICK | Nghỉ ốm đau | Paid; doctor certificate required after 2 consecutive days | Article 114, VLC 2019 |
| MATERNITY | Nghỉ thai sản | 6 months; Social Insurance funded | Article 139, VLC 2019 |
| UNPAID | Nghỉ không lương | Agreed between employee and employer | Article 115, VLC 2019 |

**Configurable Attributes per Leave Type:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `code` | String (unique) | Yes | System identifier |
| `name_vn` / `name_en` | String | Yes | Display name |
| `entitlement_basis` | Enum: FIXED, ACCRUAL, UNLIMITED | Yes | How leave is earned |
| `unit` | Enum: DAY, HOUR | Yes | Balance tracking unit |
| `allow_half_day` | Boolean | No | Whether 0.5-day requests are valid |
| `carryover_eligible` | Boolean | Yes | Whether unused balance can roll over |
| `encashment_eligible` | Boolean | Yes | Whether unused balance can be paid out |
| `evidence_required` | Boolean | No | Whether supporting document is required |
| `evidence_grace_period_days` | Integer | No | Days after leave start to submit evidence |
| `country_code` | String (ISO) | Yes | Compliance jurisdiction (default: VN) |
| `active` | Boolean | Yes | Soft delete support |

**Acceptance Criteria:**

```gherkin
Scenario 1: HR Administrator creates a new leave type
GIVEN the HR Administrator is logged in with the HR_ADMIN role
AND the tenant has fewer than 50 active leave types
WHEN the HR Administrator submits a new leave type with all required fields
THEN the system creates the leave type with status ACTIVE
AND assigns a unique system-generated code if not provided
AND logs a "LeaveTypeCreated" event in the audit log
AND the leave type is immediately available for policy assignment

Scenario 2: System enforces unique leave type code
GIVEN a leave type with code "ANNUAL" already exists
WHEN an HR Administrator attempts to create another leave type with code "ANNUAL"
THEN the system rejects the request with error "Leave type code must be unique within the tenant"
AND no leave type is created

Scenario 3: Deactivating a leave type with active balances
GIVEN leave type "SICK" has 50 employees with non-zero balances
WHEN an HR Administrator deactivates leave type "SICK"
THEN the system warns: "50 employees have active balances for this leave type"
AND requires explicit confirmation before proceeding
AND after confirmation, sets status to INACTIVE
AND prevents new requests but preserves existing balance history
```

---

### BRD-ABS-002 — Leave Policy Definition

**Priority:** P0
**FR Reference:** FR-ABS-002
**Feature:** LM-002
**Hypothesis Traceability:** H1, H2, H3

**Business Requirement:**
Leave policies bind employee groups to leave types with specific accrual rules, seniority multipliers, and eligibility constraints. Vietnam Labor Code 2019 mandates specific minimum entitlements — policies must enforce these as floors, not ceilings.

**Vietnam Minimum Entitlements (Article 113, VLC 2019):**

| Years of Service | Annual Leave Entitlement | BRD Rule |
|-----------------|--------------------------|----------|
| < 5 years | 14 working days | MINIMUM — policy may not go below this |
| 5–9 years | 15 working days | MINIMUM |
| 10–14 years | 16 working days | MINIMUM |
| 15+ years | Additional 1 day per 5 years above 15 | MINIMUM |

**Policy Attributes:**

| Attribute | Description |
|-----------|-------------|
| `policy_name` | Human-readable identifier |
| `leave_type_id` | Which leave type this policy governs |
| `eligibility_scope` | All employees / by job grade / by department / by employment type |
| `probation_eligible` | Whether leave can be taken during probation |
| `probation_period_days` | Days before leave rights activate |
| `accrual_plan_id` | Reference to AccrualPlan configuration |
| `seniority_rules` | Array of (min_years, max_years, entitlement_days) |
| `carryover_rule_id` | Reference to CarryoverRule configuration |
| `effective_date` | When this policy takes effect |
| `expiry_date` | Optional; policy superseded after this date |

**Acceptance Criteria:**

```gherkin
Scenario 1: Policy enforces Vietnam minimum annual leave entitlement
GIVEN an HR Administrator is creating an Annual Leave policy
WHEN they set the base entitlement to 12 days (below Vietnam minimum of 14)
THEN the system rejects the entry with error:
  "Annual leave entitlement cannot be below 14 days per Vietnam Labor Code 2019, Article 113"
AND suggests the minimum compliant value of 14 days

Scenario 2: Seniority multiplier applies correctly
GIVEN employee "Nguyen Van A" has 6 years of service
AND the Annual Leave policy defines:
  - 0–4 years: 14 days
  - 5–9 years: 15 days
WHEN the system evaluates this employee's entitlement at policy assignment
THEN the employee's annual entitlement is set to 15 days
AND a "LeavePolicyAssigned" movement record is created in the ledger

Scenario 3: Policy change does not retroactively reduce accrued balance
GIVEN employee "Tran Thi B" has accrued 10 days under the current policy
WHEN an HR Administrator reduces the entitlement in the policy (for future accruals)
THEN the existing 10 days in the ledger are not reduced
AND only future accrual runs apply the new policy entitlement
AND HR Administrator is shown a "Future impact only" confirmation message
```

---

### BRD-ABS-003 — Leave Request Lifecycle

**Priority:** P0
**FR Reference:** FR-ABS-003
**Feature:** LM-005
**Hypothesis Traceability:** H1

**Business Requirement:**
Employees must be able to submit leave requests digitally. The system must validate balance availability, place a reservation on submission, and route the request through the configured approval workflow. The full lifecycle is: SUBMITTED → UNDER_REVIEW → APPROVED | REJECTED → (if cancelled) CANCELLATION_PENDING → CANCELLED.

**Leave Request States:**

| State | Description | Balance Effect |
|-------|-------------|----------------|
| SUBMITTED | Employee submitted; balance validation passed | Reservation placed |
| UNDER_REVIEW | Awaiting at least one approver | Reservation maintained |
| APPROVED | All approval levels completed | Reservation converted to deduction on leave start date |
| REJECTED | Any approver rejected | Reservation released |
| CANCELLATION_PENDING | Employee requested cancellation; awaiting manager approval (post-deadline cases) | Reservation maintained |
| CANCELLED | Cancellation completed | Deduction reversed; balance restored |

**Cancellation Policy (H-P0-001 — RESOLVED 2026-03-24):**

| Scenario | Rule | Balance Effect |
|----------|------|----------------|
| Cancellation before configurable deadline (default: 1 business day before leave start) | Employee may self-cancel without approval | Reservation released; balance fully restored |
| Cancellation at or after deadline | Cancellation request requires manager approval | Balance held until approval; released on approval, maintained on rejection |
| Cancellation deadline | Configurable per BU/tenant | N business days before leave start date |

**Business Rule BR-ABS-003-01:** Cancellation deadline is a tenant-level configuration, overridable at BU level. The system default is 1 business day before leave start. This configuration lives in the LeavePolicy entity.

**Acceptance Criteria:**

```gherkin
Scenario 1: Employee submits a valid leave request
GIVEN employee "Pham Minh C" has 8 available Annual Leave days
AND the requested leave is 3 days from 2026-04-07 to 2026-04-09
AND no conflicting approved leave exists for this employee
WHEN the employee submits the request
THEN the system creates a LeaveRequest with status SUBMITTED
AND creates a LeaveReservation for 3 days against the ANNUAL balance
AND the employee's available balance shows 5 days (8 - 3 reserved)
AND the request is routed to the employee's configured approver
AND the employee receives a "Request submitted" push notification

Scenario 2: Submission rejected due to insufficient balance
GIVEN employee "Le Thi D" has 2 available Annual Leave days
AND the requested leave is 5 days
WHEN the employee submits the request
THEN the system rejects the submission with error:
  "Insufficient leave balance: requested 5 days, available 2 days"
AND no reservation is created
AND no workflow is triggered

Scenario 3: Employee cancels before deadline (self-cancel)
GIVEN a leave request with status APPROVED for leave starting 2026-04-10
AND the cancellation deadline is 1 business day before (i.e., 2026-04-09)
AND today is 2026-04-07
WHEN the employee submits a cancellation request
THEN the system cancels the request without requiring manager approval
AND creates a reversal LeaveMovement restoring the balance
AND the employee's available balance is fully restored
AND the employee and manager both receive a "Leave cancelled" notification

Scenario 4: Employee cancels after deadline (requires manager approval)
GIVEN a leave request with status APPROVED for leave starting 2026-04-10
AND the cancellation deadline is 1 business day before (i.e., 2026-04-09)
AND today is 2026-04-09 (deadline day, after business hours)
WHEN the employee submits a cancellation request
THEN the request transitions to CANCELLATION_PENDING
AND the manager receives an approval request notification
AND balance is maintained as reserved until the manager acts

Scenario 5: Manager approves post-deadline cancellation
GIVEN a leave request in status CANCELLATION_PENDING
WHEN the manager approves the cancellation
THEN the LeaveRequest transitions to CANCELLED
AND a reversal LeaveMovement is created restoring the full balance
AND both employee and manager receive confirmation notifications
```

---

### BRD-ABS-004 — Leave Balance Inquiry

**Priority:** P0
**FR Reference:** FR-ABS-004
**Feature:** LM-007
**Hypothesis Traceability:** H1

**Business Requirement:**
Employees and managers must have real-time visibility into leave balances. The balance must be computed from the immutable LeaveMovement ledger and must distinguish between earned, used, reserved, and available amounts. Balance queries must meet the p95 < 1 second performance target.

**Balance Components:**

| Component | Definition | Ledger Computation |
|-----------|------------|-------------------|
| `earned` | Total leave credited via accrual + policy assignment | Sum of positive ACCRUAL and ENTITLEMENT movements |
| `used` | Leave taken (approved and completed) | Sum of negative DEDUCTION movements |
| `reserved` | Approved but future-dated leave not yet deducted | Sum of active RESERVATION movements |
| `available` | Currently usable balance | `earned - used - reserved` |
| `expiring_soon` | Balance expiring within 30 days | Filtered ACCRUAL movements by expiry_date |

**Acceptance Criteria:**

```gherkin
Scenario 1: Employee views real-time balance
GIVEN employee "Hoang Van E" has the following ledger state:
  - Accrual Jan: +7 days (ACCRUAL)
  - Accrual Feb: +7 days (ACCRUAL)
  - Taken Jan 15–17: -3 days (DEDUCTION)
  - Approved future leave Mar 5–6: -2 days (RESERVATION)
WHEN the employee opens the leave balance view
THEN the system displays:
  - Earned: 14 days
  - Used: 3 days
  - Reserved: 2 days
  - Available: 9 days
AND the balance query completes in < 1 second (p95)

Scenario 2: Manager views team member balance
GIVEN a manager has the "Manager" role and "Hoang Van E" is a direct report
WHEN the manager views "Hoang Van E"'s leave balance
THEN the manager sees the same balance breakdown as the employee
AND the view includes any pending requests not yet approved

Scenario 3: Balance correctly excludes expired leave
GIVEN an employee had 5 days of carried-over leave that expired on 2026-03-01
AND today is 2026-03-24
WHEN the employee views their balance
THEN the expired balance is NOT included in "earned" or "available"
AND an "Expired: 5 days on 2026-03-01" entry is shown in the history
```

---

### BRD-ABS-005 — Leave Reservation (Overbooking Prevention)

**Priority:** P0
**FR Reference:** FR-ABS-005
**Feature:** LM-008
**Hypothesis Traceability:** H1

**Business Requirement:**
When a leave request is submitted (not approved), the system must immediately reserve the requested balance to prevent concurrent requests from overdrawing the same entitlement. This is the FEFO (First-Expired-First-Out) reservation model inherited from ADR-TA-001.

**Reservation Lifecycle:**

| Event | Reservation Action |
|-------|-------------------|
| Leave request submitted | RESERVATION created (deducted from available) |
| Leave request approved | RESERVATION confirmed; DEDUCTION created on leave start date |
| Leave request rejected | RESERVATION released (balance restored) |
| Leave request cancelled (pre-deadline) | RESERVATION released |
| Leave request cancelled (post-deadline, approved) | RESERVATION released; balance restored |
| Leave request cancelled (post-deadline, rejected) | RESERVATION maintained |
| Accrual batch runs | RESERVATION balances re-evaluated against new earned total |

**Business Rule BR-ABS-005-01 (FEFO):** When multiple leave movements exist with different expiry dates, deductions and reservations consume the earliest-expiring balance first. This ensures carried-over leave is consumed before current-year leave.

**Acceptance Criteria:**

```gherkin
Scenario 1: Concurrent requests respect reservation
GIVEN employee "Nguyen Thi F" has 5 available days
WHEN the employee submits Request A for 3 days (SUBMITTED — reservation placed)
AND immediately submits Request B for 4 days
THEN Request B is rejected at submission with error:
  "Insufficient balance: requested 4 days, available after reservations: 2 days"
AND Request A reservation remains intact

Scenario 2: FEFO reservation consumes earliest-expiring balance
GIVEN employee "Tran Van G" has:
  - 3 days of carried-over leave (expiry: 2026-03-31)
  - 7 days of current-year accrual (expiry: 2026-12-31)
WHEN the employee submits a 4-day leave request
THEN the reservation consumes 3 days from carried-over balance first
AND 1 day from current-year accrual
AND the reservation record shows the correct source movement IDs

Scenario 3: Reservation released on rejection
GIVEN a leave request for 3 days is in status UNDER_REVIEW
AND a reservation of 3 days is active
WHEN the manager rejects the request
THEN the LeaveReservation is deleted (or marked RELEASED)
AND a reversal LeaveMovement is created
AND the employee's available balance is restored by 3 days
AND the employee is notified of the rejection
```

---

### BRD-ABS-006 — Leave Calendar View

**Priority:** P1
**FR Reference:** FR-ABS-006
**Feature:** LM-006
**Hypothesis Traceability:** H5

**Business Requirement:**
Provide a visual calendar interface showing team leave at a glance. Managers need to understand team coverage when approving leave. Employees need to see who is already out before requesting leave.

**Views Required:**

| View | Audience | Data Shown |
|------|----------|------------|
| Monthly Team Calendar | Manager, Employee | All approved and pending team leave |
| Weekly Team Calendar | Manager | Same, week granularity |
| My Leave Calendar | Employee | Own leave history and future requests |
| Approval Calendar | Manager | Pending requests with coverage context |

**Acceptance Criteria:**

```gherkin
Scenario 1: Manager views team calendar with coverage context
GIVEN a manager has a team of 8 employees
AND 3 employees have approved leave on 2026-04-07
WHEN the manager opens the monthly team calendar for April 2026
THEN April 7 shows 3 team members out with their names
AND the day is visually highlighted (e.g., orange) indicating reduced coverage
AND clicking the day shows the list of employees and their leave types

Scenario 2: Employee initiates leave request from calendar
GIVEN an employee is viewing the team calendar
WHEN the employee clicks on a date range to select leave dates
THEN the leave request form pre-fills the selected dates
AND the calendar shows conflicts (other team members already on leave that week)
```

---

### BRD-ABS-007 — Leave Class Management

**Priority:** P1
**FR Reference:** FR-ABS-007
**Feature:** LM-003
**Hypothesis Traceability:** H3

**Business Requirement:**
Leave classes aggregate multiple leave types for shared policy rules — particularly deduction order when an employee has multiple leave type balances available. Example: "Protected Leave" class covering Maternity, Paternity, and Sick Leave with priority deduction from Sick before Unpaid.

**Acceptance Criteria:**

```gherkin
Scenario 1: Leave class defines deduction priority
GIVEN a "Medical Leave" class containing Sick Leave (priority 1) and Unpaid Leave (priority 2)
AND employee "Le Van H" submits a sick leave request but has 0 Sick Leave balance
WHEN the system evaluates the request
THEN the system automatically draws from Unpaid Leave per the class deduction priority
AND displays: "Sick Leave balance exhausted; 2 days will be deducted from Unpaid Leave"
AND requires employee acknowledgement before submission
```

---

### BRD-ABS-008 — Maternity and Parental Leave

**Priority:** P2
**FR Reference:** FR-ABS-008
**Feature:** LM-010
**Hypothesis Traceability:** H3

**Business Requirement:**
Support Maternity Leave aligned with Vietnam Labor Code 2019 Article 139 (6 months for mothers). Includes job protection flag and Social Insurance integration hook. Paternity Leave per Article 34, Law on Social Insurance 2014 (5 days). Implementation deferred to Phase 2.

*Note: Detailed Gherkin acceptance criteria to be written in Phase 2 feature specification.*

---

### BRD-ABS-009 — Leave Encashment

**Priority:** P2
**FR Reference:** FR-ABS-009
**Feature:** LM-014
**Hypothesis Traceability:** H3

**Business Requirement:**
Support encashment of unused annual leave at termination or as an HR-initiated event. Output structured payroll record. Deferred to Phase 2.

*Note: Detailed Gherkin acceptance criteria to be written in Phase 2 feature specification.*

---

## 1.5 Business Rules

| Rule ID | Category | Rule | VLC Reference | Impact if Violated |
|---------|----------|------|---------------|-------------------|
| BR-ABS-001 | Entitlement | Annual leave minimum 14 days for employees with < 5 years service | Article 113, VLC 2019 | Compliance violation; legal liability |
| BR-ABS-002 | Entitlement | Annual leave increases to 15 days at 5 years, +1 day per 5 years thereafter | Article 113, VLC 2019 | Compliance violation |
| BR-ABS-003 | Entitlement | Maternity leave: 6 months for mothers (Phase 2) | Article 139, VLC 2019 | Major compliance risk |
| BR-ABS-004 | Balance | All balance changes must be recorded as immutable LeaveMovement records | ADR-TA-001 | Audit trail broken; restatement risk |
| BR-ABS-005 | Balance | Available balance = earned - used - reserved | ADR-TA-001 | Overbooking possible |
| BR-ABS-006 | Cancellation | Leave may be cancelled before the configurable deadline without approval | H-P0-001 Resolved | Employee dissatisfaction; HR workload |
| BR-ABS-007 | Cancellation | Post-deadline cancellation requires manager approval | H-P0-001 Resolved | Policy inconsistency |
| BR-ABS-008 | Cancellation | Cancellation deadline configurable per BU/tenant; default 1 business day before leave start | H-P0-001 Resolved | Configuration gap |
| BR-ABS-009 | Cancellation | Balance fully restored on successful cancellation | H-P0-001 Resolved | Balance inaccuracy |
| BR-ABS-010 | Termination | Negative leave balance handling is configurable per tenant | H-P0-004 Resolved | Legal and financial exposure |
| BR-ABS-011 | Termination | Default policy at termination: flag negative balance for HR manual approval (Option B) | H-P0-004 Resolved | Vietnam Labor Code Article 21 compliance |
| BR-ABS-012 | Termination | Payroll deduction for negative balance requires written agreement per Vietnam Labor Code | Article 21, VLC 2019 | Illegal deduction without written consent |
| BR-ABS-013 | Termination | Admin may configure threshold-based rules (e.g., ≤3 days → write-off; >3 days → HR approval) | H-P0-004 Resolved | |
| BR-ABS-014 | Carryover | Carryover maximum and expiry configurable per leave type and policy | FR-ACC-003 | Policy enforcement gap |
| BR-ABS-015 | Evidence | Sick leave > 2 consecutive days must have doctor certificate within configured grace period | Article 114, VLC 2019 | Compliance risk |

## 1.6 Integration Contracts

### Upstream Dependencies

| System | Event Consumed | Data Used in ta.absence | FR Reference |
|--------|---------------|------------------------|-------------|
| Employee Central | EmployeeHired, EmployeeTransferred, EmployeeTerminated | Employment start date, job grade, org unit, location | FR-INT-001 |
| Holiday Calendar (ta.shared) | HolidayCalendarPublished | Excludes public holidays from leave duration calculation | FR-INT-003 |

### Downstream Dependencies

| System | Event Produced | Data Exported | FR Reference |
|--------|---------------|---------------|-------------|
| Payroll Module | PeriodClosed | Approved leave by type, balance encashments, negative balance records | FR-INT-002 |

---

# Part 2: Time and Attendance (ta.attendance)

## 2.1 Business Objectives

| ID | Objective | Metric | Target | Timeline |
|----|-----------|--------|--------|----------|
| OBJ-ATT-01 | Automate overtime tracking and cap enforcement | % OT cap violations detected before they occur | > 95% warned in advance | MVP |
| OBJ-ATT-02 | Provide mobile clock-in/out for field and manufacturing employees | % of daily punches via mobile app | > 60% within 3 months of launch | MVP |
| OBJ-ATT-03 | Achieve accurate timesheet data for payroll | Timesheet error rate (requires reprocessing) | < 0.5% per period | MVP |
| OBJ-ATT-04 | Enforce Vietnam overtime caps automatically | OT cap compliance rate | 100% (zero violations unchecked) | MVP |
| OBJ-ATT-05 | Enable manager OT approval with correct skip-level routing | % OT requests routed to wrong approver | 0% | MVP |

## 2.2 Scope and Bounded Context

**Bounded Context:** `ta.attendance`

**In Scope:**
- Punch in/out (web, mobile, terminal)
- Overtime calculation against Vietnam caps
- Comp time accrual, tracking, and expiry (H-P0-002 resolved)
- Timesheet submission and approval
- Manager OT approval routing with skip-level (H-P0-003 resolved)
- Shift definition (P1)
- Shift swap with labor law validation (P1)
- Geofencing (P1)
- Biometric integration — token only (P1)

**Out of Scope:**
- Schedule optimization and auto-generation (Workforce Planning module)
- Continuous GPS tracking (privacy by design; only at punch event)
- Raw biometric data storage (ADR-TA-004)
- Payroll calculation (only export hours and OT data)

**Core Entities:**

| Entity | Stability | Description |
|--------|-----------|-------------|
| Punch | HIGH | Immutable clock-in or clock-out event record |
| WorkedPeriod | MEDIUM | Computed record of worked time between paired punches |
| Shift | MEDIUM | Work pattern definition (start time, end time, break rules) |
| ShiftAssignment | MEDIUM | Assignment of a shift to an employee for a date or date range |
| OvertimeRequest | MEDIUM | Employee or manager initiated OT authorization |
| CompTimeBalance | MEDIUM | Running balance of compensatory time earned vs. used |
| Timesheet | MEDIUM | Period-level summary of worked hours, requiring approval |
| BiometricToken | MEDIUM | Reference token from third-party provider; no raw biometric data |

## 2.3 Stakeholders and Personas

| Persona | Role in ta.attendance | Primary Needs |
|---------|----------------------|---------------|
| Employee | Clocks in/out; views own timesheet; requests OT | Mobile clock-in; OT submission; timesheet review |
| Manager | Approves OT requests; approves timesheets; views team attendance | OT approval with cap visibility; exception alerts |
| HR Administrator | Configures shifts; manages work patterns; resolves attendance exceptions | Shift configuration; exception reports; attendance audit |
| Payroll Specialist | Receives period-close timesheet export | Accurate worked hours by category; no reprocessing required |
| System (automated) | Calculates worked time; detects OT; enforces comp time expiry | Scheduled triggers; failure alerts; audit logs |

## 2.4 Functional Requirements

---

### BRD-ATT-001 — Punch In/Out

**Priority:** P0
**FR Reference:** FR-ATT-001
**Feature:** TT-001
**Hypothesis Traceability:** H6

**Business Requirement:**
The system must record punch events from multiple source types: web browser, mobile app (iOS and Android), and hardware terminals. Each punch is an immutable record. Worked time is computed by pairing punch-in and punch-out events. Break deductions apply per the assigned work pattern.

**Punch Event Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `punch_id` | UUID | Yes | Immutable identifier |
| `employee_id` | UUID | Yes | Reference to Employee Central |
| `punch_type` | Enum: CLOCK_IN, CLOCK_OUT | Yes | Direction of punch |
| `punched_at` | Timestamp (UTC) | Yes | Event timestamp |
| `source` | Enum: WEB, MOBILE, TERMINAL | Yes | Input channel |
| `device_id` | String | Conditional | Required for TERMINAL and MOBILE sources |
| `location_lat` / `location_lon` | Decimal | Conditional | Required when geofencing is enabled |
| `biometric_token_ref` | String | No | Reference to third-party biometric provider token |
| `offline_queued` | Boolean | No | True if punch was queued offline and synced later |
| `synced_at` | Timestamp | Conditional | Required when `offline_queued = true` |

**Business Rule BR-ATT-001-01:** A punch record is immutable once created. Corrections are made via a separate CorrectionRequest entity, which creates a compensating punch pair.

**Business Rule BR-ATT-001-02:** No raw biometric data is stored. Only `biometric_token_ref` from the third-party provider is persisted (ADR-TA-004).

**Acceptance Criteria:**

```gherkin
Scenario 1: Employee clocks in via mobile app
GIVEN employee "Nguyen Van A" is within the geofence radius of "HQ Office"
AND the employee has no active clock-in for today
WHEN the employee taps "Clock In" on the mobile app
THEN the system creates a Punch record with type CLOCK_IN and source MOBILE
AND records the timestamp in UTC
AND records the GPS coordinates at punch time
AND displays confirmation: "Clocked in at 08:02 AM"

Scenario 2: Duplicate clock-in prevented
GIVEN employee "Nguyen Van A" already has an active clock-in at 08:02 AM
WHEN the employee attempts to clock in again
THEN the system returns an error: "You are already clocked in since 08:02 AM"
AND prompts: "Did you mean to clock out?"

Scenario 3: Worked time calculated with break deduction
GIVEN employee "Tran Thi B" clocks in at 08:00 and clocks out at 17:30
AND the assigned shift defines a 60-minute unpaid lunch break
WHEN the system computes the WorkedPeriod
THEN worked time = 8.5 hours (17:30 - 08:00 - 1:00 break)
AND the WorkedPeriod record is created with computed_hours = 8.5

Scenario 4: Biometric punch creates no raw data in xTalent
GIVEN a biometric device authenticates employee "Le Van C"
AND the device authenticates successfully against the third-party provider
WHEN the biometric event is received by xTalent
THEN xTalent creates a Punch record with biometric_token_ref = "[provider_token]"
AND no fingerprint image, template, or raw biometric data is stored
AND the audit log records "BiometricPunchReceived" with token reference only
```

---

### BRD-ATT-002 — Overtime Calculation and Enforcement

**Priority:** P0
**FR Reference:** FR-ATT-002
**Feature:** TT-003
**Hypothesis Traceability:** H3

**Business Requirement:**
Overtime is calculated from worked time exceeding scheduled shift hours. Vietnam Labor Code 2019 sets mandatory caps. The system must track OT against caps in real time and alert when thresholds are approached or breached.

**Vietnam OT Caps (Article 107, VLC 2019):**

| Period | Maximum OT Hours | Alert Threshold (configurable, default) |
|--------|-----------------|----------------------------------------|
| Per day | 4 hours | 3 hours (75%) |
| Per month | 40 hours | 32 hours (80%) |
| Per year | 200 hours (standard) / 300 hours (special industries) | 160 hours / 240 hours (80%) |

**OT Rate Categories:**

| Day Type | Minimum OT Pay Rate | VLC Reference |
|----------|--------------------|-|
| Normal working day | 150% of regular rate | Article 98, VLC 2019 |
| Weekend (Saturday/Sunday) | 200% of regular rate | Article 98, VLC 2019 |
| Public holiday / Compensatory rest day | 300% of regular rate | Article 98, VLC 2019 |

**Comp Time (Compensatory Time — H-P0-002 RESOLVED 2026-03-24):**

Instead of OT pay, employees may accrue comp time with manager and HR approval. Comp time expiry policy is configurable per tenant/BU:

| Configuration | Description |
|---------------|-------------|
| Expiry warning notification | N days before expiry (N configurable, default: 14 days) |
| Action on expiry — Option 1 | Manager-approved extension |
| Action on expiry — Option 2 | Auto cash-out to Payroll module export |
| Action on expiry — Option 3 | Forfeiture (balance set to zero; event logged) |
| Default action | Configured by admin per tenant/BU; no system-wide default enforced |

**Business Rule BR-ATT-002-01:** OT request must be approved before work begins (pre-approval default). Retroactive OT logging is a P1 configuration option (H-P1-006 — open).

**Business Rule BR-ATT-002-02:** The system must prevent OT approval if it would cause the employee to exceed the monthly (40h) or annual (200h/300h) cap. The approver must be shown the cumulative OT hours at the time of approval.

**Acceptance Criteria:**

```gherkin
Scenario 1: OT calculated correctly for weekday
GIVEN employee "Pham Van D" is assigned an 8-hour shift (08:00–17:00, 1h break)
AND the employee works until 19:00 (10 hours with break = 9 worked hours)
WHEN the system calculates OT for the day
THEN OT hours = 1 (worked 9h vs scheduled 8h)
AND OT rate category = WEEKDAY (150%)
AND a "OvertimeDetected" event is logged

Scenario 2: System blocks OT approval at monthly cap
GIVEN employee "Le Thi E" has 38 hours of approved OT in the current month
AND a new OT request for 4 hours is submitted
WHEN the manager attempts to approve the 4-hour OT request
THEN the system warns: "Approving this request will exceed the monthly OT cap (38 + 4 = 42 hours, cap: 40 hours)"
AND requires the manager to explicitly override with documented justification
AND logs the override in the compliance audit trail

Scenario 3: Comp time expiry warning sent
GIVEN employee "Nguyen Thi F" has 8 hours of comp time expiring on 2026-04-07
AND the tenant's comp time expiry warning is set to 14 days before expiry
AND today is 2026-03-24 (14 days before expiry)
WHEN the scheduled notification job runs
THEN the system sends a notification to the employee:
  "Your comp time balance of 8 hours will expire on 2026-04-07. Please use it before then."
AND sends a notification to the employee's manager

Scenario 4: Comp time auto-forfeiture on expiry
GIVEN employee "Tran Van G" has 4 hours of comp time expiring on 2026-03-24
AND the tenant's comp time expiry policy is set to "FORFEITURE"
AND the employee has not used the comp time
WHEN the daily expiry processing job runs on 2026-03-24
THEN the system creates a LeaveMovement of type EXPIRY for -4 hours
AND the comp time balance is set to zero
AND a "CompTimeExpired" event is logged in the audit trail
AND the employee receives a "Comp time expired" notification

Scenario 5: Comp time auto cash-out on expiry
GIVEN employee "Hoang Thi H" has 6 hours of comp time expiring on 2026-03-24
AND the tenant's comp time expiry policy is set to "AUTO_CASHOUT"
WHEN the daily expiry processing job runs on 2026-03-24
THEN the system creates a CompTimeCashout record for 6 hours
AND the record is included in the next payroll export
AND the employee receives a "Comp time cashed out — will appear in payroll" notification
```

---

### BRD-ATT-003 — Timesheet Submission and Approval

**Priority:** P0
**FR Reference:** FR-ATT-003
**Feature:** TT-002
**Hypothesis Traceability:** H1

**Business Requirement:**
Employees must review and submit their timesheet at end of each period. Managers must approve before period close. Approved timesheets are locked — corrections require an HR-authorized correction workflow.

**Timesheet States:**

| State | Description | Who Can Act |
|-------|-------------|-------------|
| OPEN | Active period; employee can view/edit punch discrepancies | Employee |
| SUBMITTED | Employee submitted for approval | Manager |
| APPROVED | Manager approved; ready for payroll export | HR Administrator (corrections only) |
| LOCKED | Period closed; payroll export triggered | HR Administrator (exceptional corrections only) |

**Acceptance Criteria:**

```gherkin
Scenario 1: Employee submits timesheet
GIVEN it is the last day of the period (2026-03-31)
AND employee "Nguyen Van A" has reviewed their timesheet and all punches are reconciled
WHEN the employee submits the timesheet
THEN the timesheet status changes from OPEN to SUBMITTED
AND the manager receives a "Timesheet pending approval" notification
AND the employee can no longer edit the timesheet

Scenario 2: Manager approves timesheet
GIVEN employee "Nguyen Van A"'s timesheet is in SUBMITTED status
WHEN the manager clicks "Approve" on the timesheet
THEN the timesheet status changes from SUBMITTED to APPROVED
AND the employee receives an "Timesheet approved" notification
AND the timesheet data is included in the period-close payroll export package

Scenario 3: Retroactive correction after approval
GIVEN employee "Tran Thi B"'s timesheet is in APPROVED status
AND a punch error is discovered (missed clock-out on 2026-03-15)
WHEN the HR Administrator initiates a correction request
THEN a CorrectionRequest record is created with reason and auditor ID
AND after correction is applied, a "TimesheetCorrected" event is logged
AND the updated timesheet data is included in a corrected payroll export
AND the original approved timesheet is preserved for audit reference
```

---

### BRD-ATT-004 — Shift Management

**Priority:** P1
**FR Reference:** FR-ATT-004
**Feature:** TT-004
**Hypothesis Traceability:** H1

**Business Requirement:**
HR Administrators must be able to define work shifts with schedules, break rules, and work patterns. Shifts are assigned to employees. The system detects deviations (late arrivals, early departures, absences).

**Acceptance Criteria:**

```gherkin
Scenario 1: HR Administrator defines a shift
GIVEN the HR Administrator creates shift "Morning Factory Shift" with:
  - Start: 06:00, End: 14:00
  - Break: 30 min unpaid at 10:00
  - Grace period: 10 min late arrival tolerance
WHEN the shift is saved
THEN it is available for assignment to employees or groups

Scenario 2: Late arrival detected
GIVEN employee "Le Van C" is assigned the "Morning Factory Shift" (06:00–14:00, grace: 10 min)
AND the employee clocks in at 06:18
WHEN the system evaluates the punch against the shift
THEN a "LateArrivalDetected" event is created with lateness_minutes = 8
AND the event is visible on the manager's exception dashboard

Scenario 3: Absence detected
GIVEN employee "Pham Thi D" is assigned a shift for 2026-04-07
AND the employee has no approved leave for that day
AND no punch is recorded for 2026-04-07 by end of shift
WHEN the daily absence detection job runs
THEN an "AbsenceDetected" event is created
AND the manager receives an exception alert
```

---

### BRD-ATT-005 — Shift Swap

**Priority:** P1
**FR Reference:** FR-ATT-005
**Feature:** TT-005
**Hypothesis Traceability:** H1

**Business Requirement:**
Employees can swap shifts with colleagues. Swaps require manager approval and must not violate labor law rest period requirements.

**Hot Spot H-P1-002 (Open):** If a swap results in an employee working two consecutive shifts with less than the minimum 8-hour rest period (Vietnam Labor Code Article 109), the system must either block or warn. Resolution needed before P1 implementation.

**Acceptance Criteria:**

```gherkin
Scenario 1: Employee initiates shift swap
GIVEN employee "Nguyen Van A" is assigned Morning Shift on 2026-04-07
AND employee "Tran Thi B" is assigned Afternoon Shift on 2026-04-07
WHEN employee "Nguyen Van A" requests to swap with "Tran Thi B"
AND "Tran Thi B" accepts the swap request
THEN the manager receives an approval notification
AND the swap is not executed until manager approves

Scenario 2: System blocks swap violating rest period
GIVEN employee "Le Van C" works Afternoon Shift ending at 22:00 on 2026-04-07
AND the proposed swap would assign Morning Shift starting at 06:00 on 2026-04-08 (8h rest only)
WHEN the swap is evaluated
THEN the system blocks the swap with warning:
  "This swap results in less than the minimum 8-hour rest period between shifts (VLC 2019, Article 109)"
AND the swap request cannot be submitted
```

---

### BRD-ATT-006 — Geofencing

**Priority:** P1
**FR Reference:** FR-ATT-006
**Feature:** TT-006
**Hypothesis Traceability:** H6

**Business Requirement:**
Mobile punch-in enforces geofencing. Employees may only punch in when within the configurable radius of a registered work location. Multiple locations supported. Geofence captures location only at punch event — not continuously (privacy by design, H4).

**Hot Spot H-P1-005 (Open):** How to handle employees at client sites not pre-registered in the system. Resolution needed before P1 implementation.

**Acceptance Criteria:**

```gherkin
Scenario 1: Punch in within geofence succeeds
GIVEN employee "Nguyen Thi E" is 50 meters from "HQ Office" (geofence radius: 100m)
WHEN the employee taps "Clock In" on the mobile app
THEN the system records the punch with location verified
AND the punch is not flagged as a geofence violation

Scenario 2: Punch in outside geofence is flagged
GIVEN employee "Tran Van F" is 500 meters from the nearest registered work location
WHEN the employee attempts to clock in
THEN the system logs the punch as a GEOFENCE_VIOLATION
AND the manager receives a "Geofence violation alert" notification
AND the employee sees a warning but the punch is recorded (not blocked) by default

Scenario 3: Geofence violation triggers manager review
GIVEN employee "Le Thi G" has 3 geofence violations in the current period
WHEN the manager opens the attendance exception dashboard
THEN the employee's profile shows 3 geofence violations with timestamps and coordinates
AND the manager can mark each as "Approved Exception" or "Policy Violation"
```

---

### BRD-ATT-007 — Biometric Authentication Integration

**Priority:** P1
**FR Reference:** FR-ATT-007
**Feature:** TT-007
**Hypothesis Traceability:** H4, H6

**Business Requirement:**
Biometric devices authenticate employees via a third-party biometric provider. xTalent stores only the provider-issued reference token — never raw biometric data (ADR-TA-004; GDPR Article 9; Vietnam Decree 13/2023).

**Acceptance Criteria:**

```gherkin
Scenario 1: Biometric token stored, raw data never received
GIVEN a biometric device is registered with xTalent and connected to Provider "BioVendorX"
WHEN employee "Nguyen Van A" authenticates on the biometric device
THEN the third-party provider validates the fingerprint and returns a token "T-12345"
AND xTalent receives only the token reference "T-12345" and employee ID
AND xTalent creates a Punch record with biometric_token_ref = "T-12345"
AND the xTalent database contains no fingerprint data, image, or template
```

---

## 2.5 Business Rules

| Rule ID | Category | Rule | VLC Reference | Impact if Violated |
|---------|----------|------|---------------|-------------------|
| BR-ATT-001 | OT Cap | Monthly OT must not exceed 40 hours | Article 107, VLC 2019 | Legal liability; fine |
| BR-ATT-002 | OT Cap | Annual OT must not exceed 200h (standard) / 300h (special industries) | Article 107, VLC 2019 | Legal liability |
| BR-ATT-003 | OT Cap | Daily OT must not exceed 4 hours | Article 107, VLC 2019 | Legal liability |
| BR-ATT-004 | OT Rate | Weekday OT paid at minimum 150% | Article 98, VLC 2019 | Underpayment liability |
| BR-ATT-005 | OT Rate | Weekend OT paid at minimum 200% | Article 98, VLC 2019 | Underpayment liability |
| BR-ATT-006 | OT Rate | Public holiday OT paid at minimum 300% | Article 98, VLC 2019 | Underpayment liability |
| BR-ATT-007 | Comp Time | Comp time expiry warning N days in advance (N configurable per tenant/BU; default: 14) | H-P0-002 Resolved | Unexpected balance loss |
| BR-ATT-008 | Comp Time | On comp time expiry, action is configurable: extension / auto cash-out / forfeiture | H-P0-002 Resolved | Incorrect payroll or balance |
| BR-ATT-009 | Manager OT | Manager's own OT requests must not be approved by the manager themselves | H-P0-003 Resolved | Conflict of interest; cost control |
| BR-ATT-010 | Manager OT | Default routing for manager OT: auto skip-level to Line Manager above submitter | H-P0-003 Resolved | Improper authorization |
| BR-ATT-011 | Manager OT | Admin may configure custom workflow: approver by role/level | H-P0-003 Resolved | Routing misconfiguration |
| BR-ATT-012 | Biometric | No raw biometric data stored; third-party token only | ADR-TA-004; GDPR Art 9 | Major compliance breach |
| BR-ATT-013 | Punch | Punch records are immutable; corrections via CorrectionRequest | ADR-TA-001 | Audit trail compromise |
| BR-ATT-014 | Timesheet | Approved timesheets locked; corrections require HR authorization | FR-ATT-003 | Payroll data integrity |
| BR-ATT-015 | Rest Period | Minimum 8 hours between shifts (shift swap validation) | Article 109, VLC 2019 | Health and safety violation |

## 2.6 Integration Contracts

### Upstream Dependencies

| System | Event Consumed | Data Used in ta.attendance | FR Reference |
|--------|---------------|--------------------------|-------------|
| Employee Central | EmployeeHired, EmployeeTransferred, EmployeeTerminated | Employee schedule assignment, org hierarchy for OT routing | FR-INT-001 |
| Holiday Calendar (ta.shared) | HolidayCalendarPublished | OT rate category determination (holiday vs. weekday) | FR-INT-003 |
| Biometric Provider | BiometricAuthEvent | Token reference for punch events | FR-ATT-007 |

### Downstream Dependencies

| System | Event Produced | Data Exported | FR Reference |
|--------|---------------|---------------|-------------|
| Payroll Module | PeriodClosed | Worked hours by category, OT hours by rate, comp time cash-outs | FR-INT-002 |

---

# Part 3: Shared Services (ta.shared)

## 3.1 Business Objectives

| ID | Objective | Metric | Target | Timeline |
|----|-----------|--------|--------|----------|
| OBJ-SHD-01 | Automate period open/close triggering payroll export | Manual steps in period close process | Reduce from ~8 steps to 1 | MVP |
| OBJ-SHD-02 | Enable configurable multi-level approval for all request types | % approval requests routed correctly first time | > 99% | MVP |
| OBJ-SHD-03 | Deliver approval decisions within SLA | % approvals actioned within configured timeout | > 95% (with escalation) | MVP |
| OBJ-SHD-04 | Maintain 100% audit trail for compliance | Audit coverage — balance changes, approvals, config changes | 100% | MVP |

## 3.2 Scope and Bounded Context

**Bounded Context:** `ta.shared`

**In Scope:**
- Period management: open, close, payroll export trigger
- Holiday calendar: Vietnam public holidays (11 days/year); extensible for APAC
- Multi-level approval workflow with configurable chains and escalation
- Notification service (push and email)
- Integration hub: Employee Central (upstream), Payroll (downstream)
- Accrual batch processing and year-end carryover
- Negative balance handling at termination (H-P0-004 resolved)

**Core Entities:**

| Entity | Stability | Description |
|--------|-----------|-------------|
| Period | HIGH | Defined time interval for payroll; has open/close lifecycle |
| HolidayCalendar | HIGH | Country-specific public holiday schedule |
| ApprovalChain | MEDIUM | Ordered list of approvers for a request type; configurable per org |
| ApprovalTask | MEDIUM | Single-approver action within a chain (pending/approved/rejected/escalated) |
| Notification | MEDIUM | System-generated message (push, email) to an actor |
| AccrualBatchRun | MEDIUM | Record of a scheduled accrual execution with audit log |
| PayrollExportPackage | MEDIUM | Structured data package sent to Payroll at period close |
| TerminationBalanceRecord | MEDIUM | Snapshot of all leave balances at termination, with configured action |

## 3.3 Stakeholders and Personas

| Persona | Role in ta.shared | Primary Needs |
|---------|------------------|---------------|
| HR Administrator | Configures approval chains, holiday calendars, periods; triggers exports | Self-service configuration; audit log access; export confirmation |
| Manager | Responds to approval tasks within SLA | Clear notification; context in approval screen |
| Payroll Specialist | Triggers period close and receives export confirmation | Reliable export; idempotent re-run; error reporting |
| System Admin | Configures tenant-level policies (comp time expiry, cancellation deadline, termination handling) | Secure admin interface; change audit trail |
| System (automated) | Runs accrual batch; sends notifications; triggers escalation | Reliable scheduling; alerting on failure |

## 3.4 Functional Requirements

---

### BRD-SHD-001 — Period Management

**Priority:** P0
**FR Reference:** FR-INT-002
**Hypothesis Traceability:** H1

**Business Requirement:**
HR Administrators or Payroll Specialists must be able to open and close periods. Period close triggers the payroll export. Once closed, the period is locked — retroactive changes require an HR correction workflow.

**Period States:**

| State | Description |
|-------|-------------|
| OPEN | Active period; time entries and leave requests accepted |
| SUBMITTED | Period submitted for close; awaiting final approval |
| CLOSED | Period locked; payroll export generated |
| CORRECTED | A correction was applied post-close; generates supplemental export |

**Acceptance Criteria:**

```gherkin
Scenario 1: HR Administrator closes a period
GIVEN period "March 2026" is in OPEN status
AND all employee timesheets for the period are in APPROVED status
WHEN the HR Administrator initiates period close
THEN the system validates: all timesheets approved, no pending leave requests within the period
AND upon validation pass, generates the PayrollExportPackage
AND changes period status to CLOSED
AND notifies the Payroll Specialist: "March 2026 period closed; payroll export ready"

Scenario 2: Period close blocked by unapproved timesheets
GIVEN period "March 2026" is in OPEN status
AND 12 employee timesheets are still in SUBMITTED status (not yet approved)
WHEN the HR Administrator attempts to close the period
THEN the system blocks the close with:
  "12 timesheets are pending manager approval. Period cannot be closed."
AND shows the list of pending timesheets with employee names and manager names

Scenario 3: Payroll export is idempotent
GIVEN period "March 2026" is in CLOSED status
AND the payroll export was successfully generated
WHEN the Payroll Specialist re-triggers the export
THEN the system returns the same export package as the first run
AND does not create duplicate records in the Payroll module
AND logs: "PayrollExportRegenerated — idempotent re-run at [timestamp]"
```

---

### BRD-SHD-002 — Holiday Calendar

**Priority:** P0
**FR Reference:** FR-INT-003
**Hypothesis Traceability:** H3

**Business Requirement:**
The system must maintain country-specific holiday calendars and apply them in leave duration calculations and OT rate determinations. Vietnam has 11 statutory public holidays per year (Article 112, VLC 2019). The architecture must support additional country calendars without schema changes.

**Vietnam Statutory Public Holidays (Article 112, VLC 2019):**

| Holiday | Days |
|---------|------|
| New Year's Day (Tết Dương Lịch) | 1 day (Jan 1) |
| Lunar New Year (Tết Nguyên Đán) | 5 days |
| Hung Kings Commemoration (Giỗ Tổ Hùng Vương) | 1 day (10th of 3rd lunar month) |
| Liberation Day / Reunification Day | 1 day (Apr 30) |
| International Labour Day | 1 day (May 1) |
| National Day | 2 days (Sep 2; +1 adjacent) |
| **Total** | **11 days** |

**Business Rule BR-SHD-002-01:** If a public holiday falls on a Saturday or Sunday, the substitute rest day is the immediately preceding Friday or the following Monday. (Hot Spot H-P1-007 — resolution to be formalized in P1 feature spec.)

**Acceptance Criteria:**

```gherkin
Scenario 1: Leave duration excludes public holidays
GIVEN employee "Nguyen Van A" submits Annual Leave from 2026-04-28 to 2026-05-04
AND 2026-04-30 (Liberation Day) and 2026-05-01 (Labour Day) are public holidays
WHEN the system calculates the leave duration
THEN the leave consumes 5 working days (excludes Apr 30 and May 1)
AND the employee's balance is deducted by 5 days, not 7

Scenario 2: OT on public holiday applies 300% rate
GIVEN an employee works overtime on 2026-04-30 (Liberation Day)
WHEN the system calculates the OT pay rate
THEN the OT rate is applied as 300% of the regular rate
AND the OT record is categorized as "PUBLIC_HOLIDAY"
```

---

### BRD-SHD-003 — Multi-Level Approval Workflow

**Priority:** P0
**FR Reference:** FR-WFL-001
**Feature:** WA-001
**Hypothesis Traceability:** H1

**Business Requirement:**
All leave requests and OT requests flow through configurable approval chains. The approval chain determines who must act, in what order, and what happens on timeout. The system must correctly handle the case where the submitter is a manager (H-P0-003 resolved).

**Approval Chain Configuration:**

| Attribute | Description |
|-----------|-------------|
| `request_type` | LEAVE_REQUEST, OVERTIME_REQUEST, SHIFT_SWAP, TIMESHEET |
| `levels` | Ordered array of approval levels |
| `level.approver_type` | ROLE, INDIVIDUAL, SKIP_LEVEL_LINE_MANAGER |
| `level.timeout_hours` | Hours before escalation triggers |
| `level.escalation_target` | Role or individual to escalate to |
| `level.is_configurable` | Whether admin can override per org unit |

**Manager OT Approval Routing (H-P0-003 — RESOLVED 2026-03-24):**

| Mode | Description | Configuration |
|------|-------------|---------------|
| Mode 1 (Default) | Auto skip-level: routes to Line Manager above the submitter in org chart | Enabled by default; no admin action required |
| Mode 2 (Custom) | Admin defines approver by role/level for each manager grade | Requires explicit admin configuration per role |

**Business Rule BR-SHD-003-01:** When a manager submits a leave request or OT request for themselves, the system MUST NOT route the approval to the submitting manager themselves. The system must detect self-approval scenarios and apply the configured skip-level rule.

**Business Rule BR-SHD-003-02:** The approval chain must be evaluated dynamically at request submission time, not at chain configuration time, to account for org chart changes.

**Acceptance Criteria:**

```gherkin
Scenario 1: Standard leave request routes to direct manager
GIVEN employee "Pham Van D" reports to manager "Nguyen Thi E"
AND the leave approval chain for "Pham Van D"'s org unit is Level 1: Direct Manager
WHEN "Pham Van D" submits a leave request
THEN the system creates an ApprovalTask assigned to "Nguyen Thi E"
AND "Nguyen Thi E" receives a notification within 30 seconds

Scenario 2: Manager's own leave routes to skip-level (Mode 1 default)
GIVEN manager "Nguyen Thi E" reports to senior manager "Tran Van F"
AND the approval chain is configured for Mode 1 (skip-level default)
WHEN "Nguyen Thi E" submits a leave request for herself
THEN the system detects that the submitter equals the Level 1 approver
AND auto-routes the request to "Tran Van F" (skip-level line manager)
AND "Nguyen Thi E" does NOT receive an approval task for her own request

Scenario 3: Approval chain escalates on timeout
GIVEN an ApprovalTask is assigned to manager "Le Van G" with timeout 24 hours
AND 24 hours have elapsed without action
WHEN the escalation scheduler runs
THEN the ApprovalTask is marked ESCALATED
AND a new ApprovalTask is created for the configured escalation target
AND both the original approver and escalation target receive notifications
AND the escalation is recorded in the approval history

Scenario 4: Multi-level approval — second level triggered after first approval
GIVEN a leave request requires two approval levels:
  Level 1: Direct Manager
  Level 2: HR Administrator
AND Level 1 manager "Nguyen Thi E" approves the request
WHEN Level 1 approval is completed
THEN the system creates a Level 2 ApprovalTask for HR Administrator role
AND notifies the HR Administrator
AND the request status remains UNDER_REVIEW until Level 2 acts
```

---

### BRD-SHD-004 — Approval Notifications

**Priority:** P0
**FR Reference:** FR-WFL-002
**Feature:** WA-002
**Hypothesis Traceability:** H1

**Business Requirement:**
The notification service delivers push and email notifications for all approval lifecycle events. Notification templates are configurable per organization. Delivery must be confirmed and retried on failure.

**Notification Trigger Matrix:**

| Event | Recipient | Channel |
|-------|-----------|---------|
| Leave request submitted | Approver | Push + Email |
| Leave approved | Employee | Push + Email |
| Leave rejected | Employee | Push + Email |
| Approval timeout | Escalation target | Push + Email |
| Comp time expiry warning | Employee + Manager | Push + Email |
| Comp time expired | Employee + Manager | Push + Email |
| Period closed | Payroll Specialist | Email |
| Accrual batch complete | HR Administrator | Email |
| Leave cancelled | Employee + Manager | Push + Email |

**Acceptance Criteria:**

```gherkin
Scenario 1: Notification delivered within SLA
GIVEN employee "Nguyen Van A" submits a leave request at 09:00
WHEN the approval routing is completed
THEN the manager receives a push notification within 30 seconds
AND an email notification within 2 minutes

Scenario 2: Failed notification is retried
GIVEN a push notification fails to deliver (push token expired)
WHEN the notification service detects delivery failure
THEN the system retries delivery via email channel
AND logs the delivery failure and retry in the audit log
```

---

### BRD-SHD-005 — Accrual Batch Processing

**Priority:** P0
**FR Reference:** FR-ACC-001, FR-ACC-002
**Feature:** AE-001, AE-002
**Hypothesis Traceability:** H1, H2

**Business Requirement:**
The system must run a scheduled accrual batch that calculates earned leave for all active employees and creates immutable LeaveMovement records. The batch is the authoritative source of accrual — the real-time tracking is for in-period balance estimation only (ADR-TA-002: Hybrid Accrual Engine).

**Accrual Methods Supported:**

| Method | Description | Example |
|--------|-------------|---------|
| FLAT_RATE | Fixed days per period, regardless of hours worked | 1.5 days/month for Annual Leave (14 days/year ÷ 12) |
| PER_HOUR_WORKED | Accrual rate proportional to hours worked | 0.0769 hours per hour worked |
| PER_PAYROLL_PERIOD | Fixed days per payroll cycle | 7 days per semi-annual period |

**Acceptance Criteria:**

```gherkin
Scenario 1: Monthly accrual batch creates correct movement records
GIVEN it is the last day of March 2026 (2026-03-31)
AND 500 active employees are eligible for Annual Leave accrual
AND the accrual plan defines FLAT_RATE: 1.25 days/month
WHEN the scheduled accrual batch runs
THEN the system creates 500 LeaveMovement records of type ACCRUAL
AND each record has amount = 1.25, period = "2026-03"
AND each record is immutable and timestamped
AND a BatchRun record is created with status COMPLETED, employee_count = 500
AND HR Administrator receives: "Accrual batch March 2026 completed: 500 employees processed"

Scenario 2: Accrual batch is idempotent (no duplicate runs)
GIVEN the accrual batch for March 2026 was already completed
WHEN a second batch run is triggered (e.g., by system error recovery)
THEN the system detects the existing completed BatchRun for "March 2026"
AND skips execution
AND logs: "Duplicate batch run prevented for period 2026-03"

Scenario 3: Pro-rated accrual for new hire mid-month
GIVEN employee "Tran Thi G" was hired on 2026-03-15
AND the accrual plan defines FLAT_RATE: 1.25 days/month
WHEN the March 2026 accrual batch runs
THEN the system pro-rates: 1.25 × (17/31) = 0.69 days
AND creates a LeaveMovement of 0.69 days with note "Pro-rated: hired 2026-03-15"
```

---

### BRD-SHD-006 — Year-End Carryover and Expiry

**Priority:** P0
**FR Reference:** FR-ACC-003
**Feature:** AE-004
**Hypothesis Traceability:** H1, H3

**Business Requirement:**
At year-end, the system executes carryover rules and expires unused balance per policy configuration. Expiry events are logged and trigger notifications.

**Carryover Rule Attributes:**

| Attribute | Description |
|-----------|-------------|
| `max_carryover_days` | Maximum days that can roll into next year |
| `carryover_expiry_months` | Months after year-end before carried-over balance expires |
| `auto_expire_unused` | Whether balance above carryover cap is automatically expired |

**Acceptance Criteria:**

```gherkin
Scenario 1: Carryover executed with maximum cap
GIVEN employee "Le Van H" has 8 unused Annual Leave days at year-end 2025
AND the carryover rule allows max 5 days, expiring March 31 of next year
WHEN the year-end carryover batch runs
THEN a CARRYOVER movement of +5 days is created with expiry_date = 2026-03-31
AND an EXPIRY movement of -3 days is created (days above cap)
AND the employee's balance shows 5 carried-over days with expiry note
AND the employee receives: "5 days carried over to 2026 (expire Mar 31). 3 days expired."

Scenario 2: Expired carried-over leave is removed from available balance
GIVEN employee "Le Van H" has 5 carried-over days with expiry 2026-03-31
AND today is 2026-04-01
AND the daily expiry job runs
WHEN the system evaluates the expiry
THEN a EXPIRY movement of -5 days is created in the ledger
AND the employee's available balance no longer includes the expired days
AND the employee receives: "5 carried-over leave days expired on 2026-03-31"
```

---

### BRD-SHD-007 — Negative Balance at Termination

**Priority:** P0
**FR Reference:** FR-ABS-009 (termination handling)
**Feature:** Related to LM-014
**Hypothesis Traceability:** H-P0-004 Resolved

**Business Requirement:**
When an employee is terminated, the system must snapshot all leave balances and apply the tenant-configured policy for negative balances. Vietnam Labor Code Article 21 requires written agreement for salary deductions, making automatic deduction the non-default option.

**Configurable Policies (H-P0-004 — RESOLVED 2026-03-24):**

| Option | Policy | Legal Basis |
|--------|--------|-------------|
| A | Auto payroll deduction | Requires written consent agreement |
| B (Default) | Flag + HR manual approval | Complies with VLC Article 21 without requiring prior consent |
| C | Auto write-off (forfeiture) | Company absorbs the liability |
| D | Rule-based threshold | e.g., negative ≤ 3 days → write-off; > 3 days → HR approval |

**Business Rule BR-SHD-007-01:** Option B is the system default. A tenant may override to A, C, or D via System Admin configuration. The override requires documented confirmation.

**Business Rule BR-SHD-007-02:** Payroll deduction (Option A) is only legal under Vietnam Labor Code 2019 Article 21 if the employee has signed a written agreement specifying the deduction terms. The system must flag this requirement and require HR attestation before exporting a deduction record.

**Acceptance Criteria:**

```gherkin
Scenario 1: Termination event triggers balance snapshot (default Option B)
GIVEN the tenant's termination policy is Option B (flag + HR approval)
WHEN EmployeeTerminated event is received for "Nguyen Van A"
AND "Nguyen Van A" has -3 days Annual Leave balance
THEN the system creates a TerminationBalanceRecord with balances_snapshot
AND flags the negative balance for HR review
AND notifies the HR Administrator: "Termination balance review required: Nguyen Van A has -3 days Annual Leave"
AND the payroll export does NOT include an automatic deduction

Scenario 2: HR approves deduction after reviewing termination balance
GIVEN a TerminationBalanceRecord for "Nguyen Van A" is flagged and awaiting HR review
AND the HR Administrator confirms a written deduction agreement exists
WHEN the HR Administrator approves the deduction
THEN a LeaveMovement of type TERMINATION_DEDUCTION is created
AND the deduction record is included in the final payroll export for "Nguyen Van A"
AND the approval is logged with HR Administrator ID and timestamp

Scenario 3: Rule-based threshold policy (Option D) auto-writes off small negatives
GIVEN the tenant's termination policy is Option D: negative ≤ 3 days → write-off
AND employee "Tran Thi B" has -2 days Annual Leave at termination
WHEN the EmployeeTerminated event is received
THEN the system auto-applies write-off (below threshold)
AND creates a WRITE_OFF LeaveMovement for +2 days
AND notifies HR Administrator: "Negative balance of 2 days written off for Tran Thi B (threshold policy)"
AND the payroll export does not include a deduction
```

---

### BRD-SHD-008 — Escalation Management

**Priority:** P1
**FR Reference:** FR-WFL-003
**Feature:** WA-003
**Hypothesis Traceability:** H1

**Business Requirement:**
When an approval task is not acted on within the configured timeout, the system must automatically escalate. Escalation history must be visible on the request detail view.

**Acceptance Criteria:**

```gherkin
Scenario 1: Approval escalated after timeout
GIVEN manager "Le Van G" has had a pending ApprovalTask for 25 hours
AND the configured timeout is 24 hours
WHEN the escalation scheduler runs
THEN the task is escalated to the configured escalation target
AND both the original approver and escalation target are notified
AND the request detail view shows: "Escalated at [time] after 24-hour timeout"
```

---

### BRD-SHD-009 — Approval Dashboard

**Priority:** P1
**FR Reference:** FR-WFL-004
**Feature:** WA-006
**Hypothesis Traceability:** H5

**Business Requirement:**
Managers need a consolidated view of all pending approvals (leave, OT, shift swaps, timesheets), team calendar, and team balance summary. Bulk approve/reject is required for efficiency.

**Acceptance Criteria:**

```gherkin
Scenario 1: Manager bulk approves timesheets
GIVEN manager "Nguyen Thi E" has 15 timesheets pending approval
WHEN the manager selects all 15 and clicks "Bulk Approve"
THEN all 15 timesheets move to APPROVED status
AND 15 employees receive approval notifications
AND the action is logged with the manager's ID and timestamp
```

---

### BRD-SHD-010 — Employee Central Integration

**Priority:** P0
**FR Reference:** FR-INT-001
**Hypothesis Traceability:** H1

**Business Requirement:**
The system must consume employee lifecycle events from Employee Central to keep policy assignments and org structure current. Integration is event-driven — TA module subscribes to Employee Central events.

**Events Consumed:**

| Event | Action in ta.shared/ta.absence/ta.attendance |
|-------|---------------------------------------------|
| EmployeeHired | Assign leave policies; create initial LeaveInstant; activate accrual |
| EmployeeTransferred | Re-evaluate leave policy based on new org unit/job grade; update approval routing |
| EmployeePromoted | Re-evaluate seniority-based entitlements; update approval chain level |
| EmployeeTerminated | Trigger TerminationBalanceRecord; freeze accrual; export final balances |

**Acceptance Criteria:**

```gherkin
Scenario 1: New hire assigned leave policy automatically
GIVEN EmployeeHired event received for "Pham Thi I" with:
  - job_grade: L3
  - org_unit: Marketing
  - hire_date: 2026-04-01
WHEN the event is processed
THEN the system assigns the Annual Leave policy for L3-Marketing employees
AND creates an initial LeaveInstant with zero balance
AND schedules first accrual for end of April 2026 (pro-rated for hire on April 1)
AND logs: "LeavePolicyAssigned for employee Pham Thi I"

Scenario 2: Transfer re-routes pending approval
GIVEN employee "Le Van J" has a leave request in UNDER_REVIEW status
AND Level 1 approver is old manager "Nguyen Thi K"
WHEN EmployeeTransferred event is received, moving "Le Van J" to new manager "Tran Van L"
THEN pending ApprovalTask is re-assigned to "Tran Van L"
AND "Nguyen Thi K" receives: "Leave request for Le Van J re-assigned to new manager"
AND "Tran Van L" receives the approval task notification
```

---

### BRD-SHD-011 — Payroll Data Export

**Priority:** P0
**FR Reference:** FR-INT-002
**Hypothesis Traceability:** H1

**Business Requirement:**
At period close, the system generates a structured, idempotent payroll export package. The export includes all data the Payroll module needs to calculate pay — TA does not calculate gross pay.

**Export Contents:**

| Data Category | Detail |
|---------------|--------|
| Approved leave taken | By employee, by leave type, hours/days, dates |
| Worked hours | By employee, regular vs. OT, by day |
| OT hours | By employee, by rate category (150%/200%/300%) |
| Comp time cash-outs | Employee, hours, expiry-triggered cash-out flag |
| Balance encashments | Employee, leave type, hours/days encashed |
| Termination deductions | Employee, negative balance amount, HR approval reference |
| Period metadata | Period ID, close timestamp, generated by |

**Acceptance Criteria:**

```gherkin
Scenario 1: Payroll export generated at period close
GIVEN period "March 2026" is closed
WHEN the payroll export is generated
THEN the system produces a PayrollExportPackage with:
  - All approved leave for March 2026 (by employee, by type)
  - All worked hours and OT hours (by category)
  - Any comp time cash-outs triggered during March
  - Period metadata: period_id, generated_at, generated_by
AND the export is delivered to the Payroll module endpoint
AND an export confirmation record is created (for idempotency check)

Scenario 2: Re-triggered export is idempotent
GIVEN the March 2026 payroll export was already generated at 18:00
WHEN the Payroll Specialist re-triggers the export at 19:00
THEN the system returns the identical export package (same data, same period_id)
AND does NOT create duplicate movement records in the Payroll module
AND logs: "Export re-run requested at 19:00 — returning cached package (idempotent)"
```

---

## 3.5 Non-Functional Requirements

### Performance

| Requirement | Target | Measurement |
|-------------|--------|-------------|
| Leave balance query | < 1 second (p95) | Load test: 1,000 concurrent users |
| Accrual batch (10,000 employees) | < 30 minutes | Batch performance test |
| Punch event ingestion | < 500ms (p99) | Mobile + terminal combined |
| Approval routing | < 2 seconds end-to-end | Workflow throughput test |
| Payroll export generation | < 5 minutes for 10,000 employees | Period-close load test |

### Scalability

| Requirement | Target |
|-------------|--------|
| Employee capacity per tenant | 50,000 employees |
| LeaveMovement records per tenant/year | 1,000,000 events |
| Concurrent users | 5,000 per tenant (peak: period open/close) |
| Multi-tenancy | Full data isolation between tenants |

### Security

| Requirement | Specification |
|-------------|---------------|
| Authentication | OAuth 2.0 + JWT; MFA required for HR Administrator and System Admin roles |
| Authorization | RBAC: Employee, Manager, HR Admin, Payroll Officer, System Admin |
| Biometric data | No raw storage; third-party token only (ADR-TA-004) |
| Audit logging | Immutable audit trail for all balance changes, approval decisions, config changes |
| Encryption | AES-256 at rest; TLS 1.3 in transit |
| PII handling | Leave records classified as PII; access logged per Vietnam Decree 13/2023 |

### Availability

| Requirement | Target |
|-------------|--------|
| Uptime SLA | 99.9% (8.7 hours downtime/year) |
| Accrual batch reliability | 99.99% (dual-control verification) |
| DR RPO | 1 hour |
| DR RTO | 4 hours |

### Usability

| Requirement | Target |
|-------------|--------|
| SUS Score | > 75 for employee and manager flows |
| Mobile responsiveness | Full P0 feature parity on mobile |
| Accessibility | WCAG 2.1 Level AA for web interfaces |
| Languages | Vietnamese (primary), English (secondary) at MVP |

## 3.6 Compliance Requirements

### Vietnam Labor Code 2019

| Article | Requirement | BRD Requirement |
|---------|-------------|-----------------|
| Article 98 | OT pay rates: 150%/200%/300% | BR-ATT-004, BR-ATT-005, BR-ATT-006 |
| Article 107 | OT caps: 4h/day, 40h/month, 200-300h/year | BR-ATT-001, BR-ATT-002, BR-ATT-003 |
| Article 109 | Minimum 8h rest between shifts | BR-ATT-015 |
| Article 112 | Public holidays: 11 days | BRD-SHD-002 |
| Article 113 | Annual leave: 14-16+ days by seniority | BR-ABS-001, BR-ABS-002 |
| Article 114 | Sick leave with doctor certificate | BRD-ABS-001 (evidence_required) |
| Article 115 | Unpaid leave by agreement | BRD-ABS-001 (UNPAID type) |
| Article 21 | Salary deduction requires written agreement | BR-SHD-007-02 |
| Article 139 | Maternity leave 6 months (Phase 2) | BR-ABS-003 |

### Vietnam Decree 13/2023/ND-CP

| Requirement | Design Impact |
|-------------|---------------|
| Health, biometric, and location data classified as sensitive PII | No raw biometric storage; location only at punch event |
| Explicit consent required for sensitive PII processing | Consent flow in mobile app before geofencing activation |
| Data localization for Vietnamese citizens | Infrastructure requirement (Step 4 — H10) |

## 3.7 Open Questions (Architecture — Step 4)

These questions are flagged for Step 3/4 resolution. They do NOT affect BRD completeness.

| ID | Question | Hypothesis | Step |
|----|----------|------------|------|
| H8 | Offline-first mobile architecture: offline queue duration; conflict resolution | H8 | Step 4 |
| H9 | Multi-tenancy isolation strategy: row-level vs. schema vs. database | H9 | Step 4 |
| H10 | Data residency enforcement: which fields; infrastructure segregation for multi-country tenants | H10 | Step 4 |

---

*End of Business Requirements Document*

**Document Status:** DRAFT — Pending Gate G2 review by Product Owner, Legal Counsel, and Tech Lead.

**Traceability Summary:**
- 32 FRs from requirements.md → formalized into BRD-ABS-001 through BRD-SHD-011
- 4 P0 hot spots (H-P0-001 through H-P0-004) → incorporated as business rules BR-ABS-006 through BR-ABS-014, BR-ATT-007 through BR-ATT-011, BR-SHD-003-01, BR-SHD-007-01/02
- 5 Vietnam Labor Code articles → mapped to specific BRD requirements
- All BRD requirements trace to hypothesis set (H1–H7)
