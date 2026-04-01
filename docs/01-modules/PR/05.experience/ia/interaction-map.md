# Interaction Map — Payroll Module (PR)

**Module**: Payroll (PR)
**Step**: 5 — Product Experience Design
**Date**: 2026-03-31

---

## Interaction Type Key

| Type | Description |
|------|-------------|
| **Form** | Create/edit structured data — single or multi-section form |
| **List+Filter** | Searchable, sortable, paginated list with filter panel |
| **Wizard** | Multi-step guided flow with validation gates between steps |
| **Dashboard** | Metrics and KPI overview with drill-down links |
| **Timeline** | Versioned history or lifecycle view with date-ordered entries |
| **Bulk Action** | Operations on multiple selected records at once |
| **Download** | File generation and download trigger (async queue + poll) |
| **Approval Flow** | State-machine driven approval UI with action buttons gated by role and state |
| **Detail+Actions** | Read-primary view with contextual action buttons per state |
| **Calc Viewer** | Paginated log/trace view with structured tabular breakdown |

---

## Feature Interaction Map

| Feature ID | Feature Name | Primary Interaction | Secondary Interactions | Screen Count (est.) |
|------------|-------------|---------------------|------------------------|---------------------|
| PR-M-001 | Pay Group Management | Form | List+Filter, Timeline (deactivation history) | 3 |
| PR-M-002 | Pay Element Management | Form (formula editor) | List+Filter, Timeline (lifecycle states), Approval Flow (formula approval) | 4 |
| PR-M-003 | Pay Profile Management | Form (dynamic variant) | List+Filter, Detail+Actions | 4 |
| PR-M-004 | Worker Pay Assignment | Form | List+Filter, Bulk Action (bulk enroll) | 3 |
| PR-M-005 | Statutory Rule Management | Form | Timeline (version history: active / upcoming / superseded), List+Filter | 4 |
| PR-M-006 | Pay Calendar Management | Form | List+Filter, Timeline (period schedule) | 3 |
| PR-M-007 | GL Account Mapping | Form | List+Filter | 2 |
| PR-T-001 | Monthly Payroll Run | Wizard | Dashboard (progress indicator), List+Filter (run list), Detail+Actions, Calc Viewer | 6 |
| PR-T-002 | Payroll Exception Handling | List+Filter | Detail+Actions, Bulk Action (bulk acknowledge), Form (acknowledgment reason) | 3 |
| PR-T-003 | Payroll Run Approval | Approval Flow | Detail+Actions (register, variance, exceptions view), Form (rejection reason) | 4 |
| PR-T-004 | Period Lock | Detail+Actions | Timeline (lock history), Dashboard (hash status) | 2 |
| PR-T-005 | Termination Payroll | Wizard | Form (termination details), Detail+Actions (preview result) | 4 |
| PR-T-006 | Bank Payment File | Download | List+Filter (file history), Detail+Actions (bank selection) | 2 |
| PR-T-007 | Payslip Generation | Bulk Action | Download, List+Filter (payslip list per period), Detail+Actions (individual payslip) | 3 |
| PR-T-008 | BHXH Report Export | Download | List+Filter (report history), Detail+Actions (error list for missing BHXH numbers) | 2 |
| PR-T-009 | PIT Declaration Export | Download | List+Filter (declaration history), Form (select quarter/year) | 2 |
| PR-T-010 | Audit Log Viewer | List+Filter | Timeline (ordered by timestamp), Detail+Actions (log entry detail with before/after values) | 2 |
| PR-T-011 | Advance Payroll | Wizard | Form (advance amount + recovery config), Detail+Actions | 3 |
| PR-T-012 | Retroactive Adjustment | Wizard | Form (worker + period range), Dashboard (impact summary + confirmation gate), Calc Viewer (delta preview) | 4 |
| PR-T-013 | Annual PIT Settlement | Wizard | Dashboard (settlement summary), Download (Form 05/QTT-TNCN) | 3 |
| PR-T-014 | Bonus Run | Wizard | List+Filter, Detail+Actions | 3 |
| PR-T-015 | Correction Run | Wizard | List+Filter, Detail+Actions | 3 |
| PR-T-016 | Worker Self-Service Payslip | List+Filter | Download, Detail+Actions (payslip view) | 2 |
| PR-T-017 | Worker PIT Certificate | List+Filter | Download | 2 |
| PR-T-018 | PIT Annual Certificate Bulk | Bulk Action | Download, List+Filter | 2 |
| PR-T-019 | GL Journal Viewer | List+Filter | Download (CSV/Excel) | 2 |
| PR-T-020 | 13th Month Salary Run | Wizard | Detail+Actions | 3 |
| PR-T-021 | Unpaid Leave Handling | Detail+Actions | List+Filter (zero-gross workers) | 2 |
| PR-T-022 | SI Split-Period Calculation | Calc Viewer | Detail+Actions (in calc log) | 1 (sub-view) |
| PR-A-001 | Payroll Cost Report | Dashboard | List+Filter (department breakdown), Download (Excel) | 2 |
| PR-A-002 | Payroll Variance Report | Dashboard | List+Filter (filterable by element/department), Detail+Actions (per-worker drill-down) | 2 |
| PR-A-003 | Payroll Register | List+Filter | Download (CSV/Excel), Detail+Actions (per-worker payslip drill-down) | 2 |
| PR-A-004 | Integrity Verification Report | Dashboard | Timeline (per-period verification history), Detail+Actions (alert detail) | 2 |
| PR-A-005 | Worker YTD Portal View | Dashboard | Timeline (month-by-month breakdown) | 1 |
| PR-A-006 | Calc Log Viewer | Calc Viewer | List+Filter (paginated log steps), Detail+Actions (statutory_rule reference links) | 2 |
| PR-A-007 | Worker YTD Summary (Admin) | Dashboard | List+Filter (per worker), Download | 2 |
| PR-A-008 | Data Retention Dashboard | Dashboard | Timeline (retention schedule), List+Filter (at-risk records) | 2 |

---

## Interaction Pattern Notes

### Async Progress Indicator (PR-T-001)
The payroll run is fully asynchronous. After initiation, the UI transitions to a progress screen showing:
- Current stage: QUEUED → PRE_VALIDATING → RUNNING → COMPLETED / FAILED
- Worker count processed / total
- Estimated time remaining (based on historical run times for this pay group size)
- Auto-refresh via WebSocket push; fallback to 5-second polling if WebSocket unavailable
- FAILED state shows error stage, error message, and "Retry" / "Cancel" action buttons

### Dynamic Form Variant (PR-M-003)
Pay Profile form has 4 variants based on pay_method selection:
- **MONTHLY_SALARY**: base salary config + proration method
- **HOURLY**: rate table (shift_type × grade → VND/hour), multiplier config
- **PIECE_RATE**: piece-rate table (product_code × quality_grade → VND/unit), SI basis mode
- **GRADE_STEP**: pay scale table (grade × step → coefficient or amount), step progression config
The form dynamically shows only the section relevant to the selected pay_method.

### Approval Flow Gating (PR-T-003)
Action buttons are rendered based on actor role AND run state:
- [Submit for Approval] — visible to PAYROLL_ADMIN, enabled only when run = COMPLETED and exceptions = 0 OPEN
- [Approve (Level 2)] — visible to HR_MANAGER only, enabled when run = PENDING_APPROVAL
- [Approve (Level 3)] — visible to FINANCE_MANAGER only, enabled when run = LEVEL_2_APPROVED
- [Reject] — visible to HR_MANAGER and FINANCE_MANAGER; requires reason_code + notes
- [Lock Period] — visible to FINANCE_MANAGER, enabled when run = APPROVED

### Legal Entity Context Switcher
All screens respect the active legal entity context. The switcher is a persistent top-bar control. Switching context reloads all scoped data. Users see only legal entities they are authorized for.
