# Glossary: ta.shared — Shared Services

**Bounded Context:** `ta.shared`
**Module:** xTalent HCM — Time & Absence
**Step:** 3 — Domain Architecture
**Date:** 2026-03-24
**Version:** 1.0

This glossary defines the ubiquitous language for the Shared Services bounded context. `ta.shared` owns the concepts that are consumed by both `ta.absence` and `ta.attendance`, and orchestrates cross-context operations.

---

## Period

**Definition:** A defined time window that corresponds to a payroll cycle — typically one calendar month. The Period is the master time-boxing concept for all timesheet activity and payroll export. Every Timesheet is associated with one Period; every PayrollExportPackage is produced from one closed Period.

**Also known as:** Pay period, payroll period, accounting period

**Distinguishing from:** AccrualPeriod (ta.absence concept — used for leave accrual calculations); Period (ta.shared concept — governs payroll and timesheet lifecycle)

**Business rules:**
- Only one Period per tenant may have status OPEN at any time
- Period state machine: OPEN → LOCKED → CLOSED (no reversal)
- Period can only transition to CLOSED when all Timesheets within it are in APPROVED status
- Closing a Period triggers idempotent PayrollExportPackage generation

**Example:** March 2026 Period: status=OPEN from 2026-03-01; transitions to LOCKED on 2026-03-30 (pending approvals); transitions to CLOSED on 2026-03-31 once all timesheets approved; PayrollExport generated.

---

## PayPeriod

**Definition:** A synonym for Period used specifically when referring to the payroll context — the time window for which employees are compensated. In xTalent, PayPeriod and Period are the same concept.

**Also known as:** Pay cycle, compensation period

**Distinguishing from:** AccrualPeriod (leave earning window); PayPeriod (the payroll compensation window — same as Period in this system)

**Business rules:**
- Same invariants as Period
- PayPeriod boundaries are used to determine which WorkedPeriods and LeaveMovements fall within scope of a payroll export

**Example:** March 2026 PayPeriod includes all working days from 2026-03-01 to 2026-03-31.

---

## HolidayCalendar

**Definition:** A country-specific or tenant-specific list of public holidays for a given year. The HolidayCalendar determines which days are non-working for the purposes of leave duration calculation and overtime rate assignment. Vietnam has 11 statutory public holidays per year per Article 112, VLC 2019.

**Also known as:** Public holiday list, national calendar, statutory holiday schedule

**Distinguishing from:** Shift (employee-level work schedule); HolidayCalendar (company/country-level non-working day registry)

**Business rules:**
- Vietnam statutory requirement: 11 public holidays per year (VLC 2019, Article 112)
- Country_code required on all HolidayCalendar records
- When a public holiday falls on a weekend, the substitute rest day rule applies (H-P1-007 — open; default: next Monday if Sunday holiday)
- Published via HR Admin action; once published, the calendar applies to all leave and OT calculations

**Example:** 2026 Vietnam Holiday Calendar: Lunar New Year (5 days: 2026-01-28 to 2026-02-01), Liberation Day (2026-04-30), Labor Day (2026-05-01), etc.

---

## WorkingDay

**Definition:** A calendar day that is neither a public holiday (per HolidayCalendar) nor a non-working day of the week per the employee's assigned Shift or ShiftPattern. Working days are the unit of measurement for leave duration and OT cap enforcement.

**Also known as:** Business day, working business day

**Distinguishing from:** Calendar day (includes weekends and holidays); WorkingDay (excludes non-working days)

**Business rules:**
- Leave duration is calculated in working days by default (configurable to calendar days per LeaveType)
- Cancellation deadline calculation uses business/working days (H-P0-001)
- OT cap (40h/month, 200h/year) is tracked in hours, not working days

**Example:** Leave from 2026-04-09 (Thursday) to 2026-04-13 (Monday) — April 13 is Hung Kings Commemoration Day (Vietnam public holiday). Duration = 4 working days (Thurs, Fri, Mon is holiday so next Tuesday? Per HolidayCalendar rules).

---

## ApprovalChain

**Definition:** A configured multi-level routing rule that defines who must approve a request and in what sequence. ApprovalChain is evaluated dynamically at the time a request is submitted, not at configuration time, to ensure org chart changes take effect immediately for new requests.

**Also known as:** Approval workflow, approval hierarchy, authorization chain

**Distinguishing from:** ApprovalTask (the individual action unit created for each approver level); ApprovalChain (the routing configuration template)

**Business rules:**
- Evaluated dynamically at request submission time
- Skip-level applied automatically when submitter equals Level 1 approver (H-P0-003)
- `routing_mode` is SKIP_LEVEL (default — auto skip-level for self-approval) or CUSTOM (Mode 2 — explicitly configured routing per role/level)
- Escalation triggers after `escalation_timeout_hours` if no action is taken
- Delegation may be configured (H-P1-008 — open); delegated approvals logged with delegation reference

**Example:** Standard leave ApprovalChain — Level 1: direct manager. For OT: if submitter is manager, auto skip-level to department head (Mode 1 / SKIP_LEVEL).

---

## ApprovalStep

**Definition:** One level within an ApprovalChain, defining a specific approver role, the timeout before escalation, and the escalation target. ApprovalSteps are instantiated as ApprovalTasks when a request is routed.

**Also known as:** Approval level, approval stage

**Distinguishing from:** ApprovalTask (the runtime instance created from an ApprovalStep for a specific request); ApprovalStep (the configuration template)

**Business rules:**
- `approver_role` can be: DIRECT_MANAGER, DEPARTMENT_HEAD, HR_MANAGER, CUSTOM_ROLE
- `escalation_timeout_hours` must be set (default: 24 hours for standard requests)
- If approver cannot be resolved from org chart, task escalates to HR for manual routing

**Example:** ApprovalStep — level: 1, approver_role: DIRECT_MANAGER, timeout_hours: 24, escalation_target_role: DEPARTMENT_HEAD.

---

## Escalation

**Definition:** The automatic transfer of an approval task to the next designated approver when the original approver does not act within the configured timeout period. Escalation is triggered by a scheduled job and creates a new ApprovalTask for the escalation target.

**Also known as:** Approval escalation, timeout escalation, auto-delegate

**Distinguishing from:** Delegation (explicit manager-initiated delegation of approval authority); Escalation (system-initiated timeout-based transfer)

**Business rules:**
- Escalation triggers after `escalation_timeout_hours` of inactivity on an ApprovalTask
- Original approver is notified that the task was escalated
- Escalation target receives the same approval task
- Escalation event (E-SHD-009) is logged with original approver, escalation target, and timestamp

**Example:** Manager "Tran Van B" has not acted on a leave request approval for 24 hours. System escalates to Department Head "Le Thi C". E-SHD-009 logged.

---

## SkipLevelApproval

**Definition:** The routing mode where a manager's own OT or leave request bypasses their direct manager (who is themselves) and routes to the next level up in the org hierarchy. SkipLevelApproval prevents a manager from being the sole approver of their own time-off or OT request, which would be a self-approval conflict.

**Also known as:** Skip-level routing, next-level routing, self-approval bypass

**Distinguishing from:** Escalation (timeout-based transfer); SkipLevelApproval (org-based logic applied at submission to prevent self-approval — H-P0-003 resolved)

**Business rules:**
- Applied when the request submitter is identified as the Level 1 approver in the ApprovalChain
- Default `routing_mode` for OT requests is SKIP_LEVEL (Mode 1)
- Mode 2 (CUSTOM) allows org-level configuration of specific routing paths per role/level
- If no skip-level approver can be resolved, the request is routed to HR

**Example:** Manager "Nguyen Van A" (Department Head) submits OT request. Level 1 approver would normally be "Nguyen Van A" (themselves). Skip-level routing assigns task to "Pham Thi B" (VP of Operations) instead.

---

## TerminationBalancePolicy

**Definition:** The tenant-configured rule that governs how negative leave balances are handled when an employee is terminated. This policy determines whether a negative balance is automatically deducted from final pay, flagged for HR approval, written off, or handled by a threshold-based rule.

**Also known as:** Termination leave policy, negative balance policy, exit balance rule

**Distinguishing from:** NegativeBalance (the balance state in ta.absence); TerminationBalancePolicy (the resolution rule for that state at termination — H-P0-004 resolved)

**Business rules:**
- Four options configurable per tenant (H-P0-004):
  - A: AUTO_DEDUCT — automatic deduction from final payroll (requires prior written consent per VLC Article 21)
  - B: HR_REVIEW (default) — negative balance flagged; HR approval required before any action
  - C: WRITE_OFF — negative balance forgiven; no deduction
  - D: RULE_BASED — threshold applied (e.g., ≤ 3 days write-off, > 3 days HR review)
- Policy change requires explicit admin confirmation; applies to new terminations only
- Written employee consent required for payroll deduction (VLC 2019, Article 21)

**Example:** Tenant configured as Option B (default). Employee terminated with -3 days annual leave. HR receives alert. HR reviews, obtains written consent from employee's estate/representative, approves deduction. Final payroll export includes deduction record.

---

## PayrollExportPackage

**Definition:** The structured data package generated at Period close that contains all time and attendance data required by the Payroll module for the closed period. The package is generated once per Period close, is idempotent (re-run produces identical output), and is delivered to the Payroll module endpoint.

**Also known as:** Payroll export, time data extract, period export file

**Distinguishing from:** Period (the time window); PayrollExportPackage (the data artifact generated when the Period closes)

**Business rules:**
- Idempotent: re-running generation for the same closed Period produces byte-identical output
- Contains: approved leave by type, worked hours by category, OT by rate category, comp time cashouts, negative balance records
- `termination_balance_action` field records the action taken for any terminated employees in the period
- Period metadata is immutable after export generation
- Delivered to Payroll module via configured API endpoint (E-SHD-005)

**Example:** March 2026 PayrollExportPackage: 450 employee records, leave_taken: [{type: ANNUAL, days: 1350}, {type: SICK, days: 45}], overtime: [{rate: WEEKDAY_150, hours: 230}, {rate: WEEKEND_200, hours: 45}], comp_time_cashouts: 12 records.

---

## Tenant

**Definition:** An organizational entity (company or subsidiary) using xTalent as a separate isolated instance. Each Tenant has its own configuration of LeaveTypes, Policies, ApprovalChains, and TenantConfig. All data is isolated by `tenant_id`.

**Also known as:** Organization, company, customer instance

**Distinguishing from:** BusinessUnit (a sub-division within a Tenant); Tenant (the top-level isolation boundary)

**Business rules:**
- `tenant_id` is required on every root aggregate across all three bounded contexts
- Row-level tenant isolation enforced in all queries (MVP; H9 deferred to Step 4)
- Tenant-level policy changes (cancellation deadline, comp time expiry, termination policy) require explicit admin confirmation

**Example:** Tenant "VNG Corporation Vietnam" (tenant_id: "VNG-VN-001") with 5,000 employees.

---

## BusinessUnit

**Definition:** A organizational sub-division within a Tenant — such as a department, division, or legal entity — that may have its own leave policies, approval chains, or configuration overrides. BusinessUnit allows policy variation below the Tenant level.

**Also known as:** Department, division, subsidiary, cost center

**Distinguishing from:** Tenant (the top-level isolation boundary); BusinessUnit (a policy subdivision within a Tenant)

**Business rules:**
- CancellationDeadline can be overridden at BusinessUnit level (H-P0-001)
- LeavePolicy can be scoped to specific BusinessUnits
- BusinessUnit hierarchy is maintained by Employee Central and consumed via the ACL adapter in ta.shared

**Example:** BusinessUnit "Engineering" within Tenant "VNG Corporation Vietnam" — overrides cancellation_deadline_days from tenant default of 1 to 2 business days.

---

## Integration Points

| Concept | From/To Context | Data Exchanged |
|---------|----------------|----------------|
| `EmployeeHired/Transferred/Terminated` | From: Employee Central | Employee profile, org structure, line manager → ACL translation → ta.absence and ta.attendance |
| `HolidayCalendarPublished` | To: ta.absence, ta.attendance | Public holidays for leave calculation and OT rate determination |
| `PeriodClosed` | To: ta.absence, ta.attendance | Period lifecycle events; triggers export contribution |
| `PayrollExportPackage` | To: Payroll Module | Full period export |
| `ApprovalChain` (shared kernel) | Read by: ta.absence, ta.attendance | Routing rules for leave and OT approvals |
| Domain event stream (54 events) | To: Analytics Platform | Full event stream for reporting and analytics |
