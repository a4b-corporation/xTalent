# Experience Architecture — Ambiguity Resolution

**Module**: Payroll (PR)
**Step**: 5 — Product Experience Design
**Date**: 2026-04-01
**Version**: 1.0

---

## Summary

Open questions and decisions made during Step 5 experience design. No Blocking items remain.

---

## Decisions Made

| ID | Feature | Question | Decision | Status | Priority |
|----|---------|---------|---------|--------|----------|
| AQ-E1 | PR-T-001 | Async run progress: polling or WebSocket? | WebSocket push for real-time; 5s polling fallback when WebSocket unavailable | Resolved | P0 |
| AQ-E2 | PR-M-003 | Pay Profile pay_method variant config — single form with dynamic sections or separate screens per method? | Single form with dynamic sections — admin stays in context; sections collapse/expand based on selected pay_method | Resolved | P0 |
| AQ-E3 | PR-T-002 | Exception acknowledgement — inline in run detail or dedicated screen? | Both: exception count badge in run detail header; dedicated exceptions screen accessible from badge for bulk management | Resolved | P0 |
| AQ-E4 | PR-T-004 | Period lock confirmation — typed confirmation or checkbox? | Typed "LOCK" + period code (e.g., "LOCK 2025-01") required — prevents accidental irreversible action | Resolved | P0 |
| AQ-E5 | PR-T-007 | Payslip distribution — email auto-send or manual download? | V1: manual download ZIP + manual distribute. V2: auto-email via worker email in CO. Reserve email template field in V1 for forward-compatibility. | Resolved | P1 |
| AQ-E6 | PR-T-001 | Run progress: can admin navigate away and come back? | Yes — run state persisted in PayrollRun record; admin can navigate away and return; progress screen auto-reconnects via run_id polling on re-entry | Resolved | P0 |
| AQ-E7 | PR-M-005 | Statutory rule payload structure — freeform JSON or structured form per rule_type? | Structured form per rule_type: SI_RATE = rate fields + ceiling inputs; PIT_BRACKET = bracket editor table; MINIMUM_WAGE = amount + region select; OT_MULTIPLIER = multiplier per OT type | Resolved | P0 |
| AQ-E8 | General | Legal entity context switcher — global header or per-screen? | Global header context switcher (top-right of app shell); all data scoped to selected entity; visible on every screen | Resolved | P0 |
| AQ-E9 | PR-T-001 | DRY_RUN vs SIMULATION vs PRODUCTION — should all three be available from the same "New Run" screen? | Yes — single Run Setup screen with run_mode radio selector; PRODUCTION mode shows additional warning banner before proceeding | Resolved | P0 |
| AQ-E10 | PR-A-001 | Employer SI in cost report — computed dynamically or from stored values? | From stored derived columns on payroll_result (computed at calculation time); avoids statutory_rule lookups at report time and ensures historical accuracy | Resolved | P0 |
| AQ-E11 | PR-T-003 | Approval notification — in-app only or email? | V1: in-app notification badge + notification bell. V2: email notification. Both should be designed together; email subject/body template defined in V1 even if not sent. | Resolved | P1 |
| AQ-E12 | PR-M-004 | Bulk worker assignment — CSV import format? | CSV with columns: working_relationship_id, pay_group_code, pay_profile_code, effective_date, grade_code (optional), step_code (optional). Validation errors shown inline before import commit. | Resolved | P1 |
| AQ-E13 | PR-A-002 | Variance threshold — company-wide setting or per-pay-group? | Company-wide default (20%) configurable in legal entity settings; no per-pay-group override in V1 | Resolved | P1 |
| AQ-E14 | PR-T-006 | Bank file: one file per bank or one combined file? | One file per bank (VCB / BIDV / TCB) — each bank has its own format. "Generate All" creates multiple files as ZIP. | Resolved | P0 |

---

## Non-Blocking Open Items (carry to development handoff)

| ID | Feature | Open Item | Impact | Owner |
|----|---------|-----------|--------|-------|
| UX-NB-01 | PR-T-001 | Loading skeleton design for async calculation progress screen needed | Visual design only; no functional impact | UI/UX Designer |
| UX-NB-02 | PR-M-003 | Pay scale table editor (GRADE_STEP) may need specialised grid component if scale has >50 rows | Component library check needed | Frontend Tech Lead |
| UX-NB-03 | General | Mobile responsive design scope undefined — is the admin interface mobile-first or desktop-only? | Affects CSS framework choice | Product Owner |
| UX-NB-04 | PR-T-007 | Payslip template design (logo, branding, layout) not in scope for ODSA — needs separate design sprint | Feature spec assumes template is provided; blank template in V1 | HR/Brand Team |
