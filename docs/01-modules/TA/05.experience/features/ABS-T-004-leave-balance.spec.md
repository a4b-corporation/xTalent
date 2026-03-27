# Leave Balance Inquiry — ABS-T-004

**Classification:** Transaction (T — Dashboard-style read with real-time data)
**Priority:** P0
**Primary Actor:** Employee (own balance view)
**Secondary Actors:** Manager (team member balance view during approval context)
**Workflow States:** Read-only — no state transitions
**API:** `GET /leaves/balances`, `GET /leaves/requests` (upcoming/reserved)
**User Story:** US-ABS-002
**BRD Reference:** FR-ABS-004
**Hypothesis:** H1, H-P0-002 (comp time expiry warning)

---

## Purpose

Leave Balance Inquiry is the self-service screen where employees verify their current leave entitlements before submitting a request. It provides a consolidated view of all leave types assigned to the employee, showing available, used, reserved, and earned balances alongside accrual progress. The screen also surfaces proactive alerts — particularly comp time expiry warnings (H-P0-002) — so employees do not lose entitlements unexpectedly.

---

## State Machine

This feature is read-only. There are no state transitions owned by this feature. The balances displayed are computed from LeaveBalance and LeaveMovement records maintained by the Absence Management and Accrual Engine bounded contexts.

---

## Screens and Steps

### Screen 1: My Leave Balance Dashboard

**Route:** `/leave/balances`

**Entry points:**
- Employee navigation menu → Leave → My Balance
- Employee Home → Balance widget / quick view card
- Post-submission confirmation screen → "View Updated Balance" CTA
- Comp time expiry notification → deep-link to balance detail

**Layout — Balance Card Grid:**

Each active leave type in the employee's current policy is shown as a card:

```
┌─────────────────────────────────────────┐
│ [Leave Type Icon]  Annual Leave         │
│ ─────────────────────────────────────── │
│  Available    Used    Reserved  Earned  │
│  12.0 days   5.0 days  3.0 days 20.0d  │
│                                         │
│  Accrual Progress ──────────────░░  60% │
│  Current: 20.0 / Projected year-end: 24│
│                                         │
│  Unit: Days  │  Accrual: Monthly        │
└─────────────────────────────────────────┘
```

**Card fields:**
- Leave type name + icon (color matches ABS-T-007 calendar color coding)
- Available balance (available = earned - used - reserved)
- Used balance (days taken so far in the period)
- Reserved balance (days in SUBMITTED or UNDER_REVIEW requests; not yet deducted)
- Earned balance (total accrued to date under current accrual plan)
- Accrual progress bar: current earned / projected year-end entitlement
- Unit label: Days or Hours (per leave type configuration)
- Accrual method label: Monthly / Annual / Per-Payroll

**Comp Time Expiry Warning Badge (H-P0-002):**
- Shown on the Comp Time / Time Off in Lieu card only
- Triggers when: comp time balance > 0 AND any units expire within `warning_days` (per ABS-M-002 policy config)
- Warning badge: orange pill "X.X days expiring in N days"
- Clicking the badge scrolls to the Balance History Timeline filtered to comp time movements

**Negative balance indicator:**
- If available < 0 (advance leave consumed): card background tinted red, available shown in red with "(advance)" label
- Tooltip: "You are using advance leave. Your future accruals will offset this negative balance."

**Layout — Upcoming Leaves Section (below the cards):**

Pulled from `GET /leaves/requests?status=APPROVED&startDate=today&limit=10`:

```
Upcoming Leaves
────────────────────────────────────────────
[Icon] Annual Leave     Apr 7 – Apr 9  3 days
       Will reduce balance by 3 days on Apr 7.

[Icon] Comp Time        May 2           1 day
       ⚠ Exp: May 15 — expires soon
────────────────────────────────────────────
```

- Shows next 10 approved upcoming leaves sorted by start date
- Each row: leave type, date range, working day count
- If the leave type has expiring comp time balance, show expiry warning inline

**Layout — Accrual Progress Detail (expandable section):**

Collapsed by default. Expand to show a mini chart:
- X-axis: months of the current leave year
- Y-axis: days earned
- Line: actual accrual to date
- Dotted line: projected accrual to year-end (based on accrual plan)
- Dots: individual monthly accrual events

---

### Screen 2: Balance History Timeline

**Route:** `/leave/balances/{leaveTypeId}/history`

**Entry points:**
- Balance card → "View History" link
- Comp time expiry warning badge → direct link (pre-filtered to comp time)

**Layout:**
- Filter by: Year (default: current leave year), Movement type (Accrual / Deduction / Adjustment / Expiry)
- Timeline list, newest first:

```
────────────────────────────────────────────
Mar 1, 2026   Accrual (March)     +1.67 days   Balance: 18.33
Feb 28, 2026  Deduction           -3.00 days   Balance: 16.67  [LR-2026-02-011]
Feb 1, 2026   Accrual (February)  +1.67 days   Balance: 19.67
Jan 15, 2026  Adjustment (HR)     +2.00 days   Balance: 18.00  Note: Carry-over added
────────────────────────────────────────────
```

- Movement row: date, type label, amount (+/-), running balance, reference ID (click to view leave request)
- Export button: "Export to CSV"

---

## Notification Triggers

| Event | Recipient | Channel | Template |
|-------|-----------|---------|---------|
| Comp time expiring within `warning_days` (H-P0-002) | Employee | Push + Email + In-app badge | "You have [X] days of comp time expiring on [date]. Use it before it's gone." |
| LeaveBalanceUpdated (SSE) | Employee (if on balance screen) | SSE in-app widget refresh | Balance cards auto-refresh without page reload |
| Advance leave consumed | Employee | In-app notification | "You now have a negative [type] balance of -[X] days. Future accruals will offset this." |

---

## Error States

| Error | User Message | Recovery Action |
|-------|-------------|-----------------|
| No active policy assigned | "No leave policy is currently assigned to your profile. Contact HR to resolve this." | Employee contacts HR Admin |
| Balance data unavailable (service error) | "Unable to load balance data. Please refresh or try again later." | Retry button; cached last-known values shown with "As of [timestamp]" label |
| Accrual plan not configured | Leave type card shows "Accrual: Not configured" in grey | HR Admin configures accrual plan (ABS-M-003) |
| Zero-balance leave type | Card shown with 0.0 available, greyed "Request" CTA with tooltip "No balance available" | — |

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-ABS-010 | Available = Earned − Used − Reserved; reservation applied on SUBMITTED status |
| BR-ABS-011 | Comp time expiry warning window controlled by `warning_days` field in leave policy config |
| BR-ABS-012 | Balance is displayed in the unit (days or hours) configured on the leave type |
| BR-ABS-013 | Projected year-end balance is the current earned balance plus remaining accrual events at the plan rate |
| BR-ABS-014 | Advance leave (negative balance) is allowed only when `allow_advance_leave = true` on the leave type |

---

## Mobile Considerations

- Balance cards must render as a vertically scrollable list on mobile (not a grid)
- Comp time expiry warning badge must be visible without scrolling (sticky alert at top of screen if expiry within 3 days)
- Accrual progress detail collapses by default on mobile to preserve screen space
- Balance data cached locally for 5 minutes; "Last updated [time]" shown when using cached data
- SSE balance updates apply to the cached value and refresh the display without user action
