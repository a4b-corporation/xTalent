# Leave Calendar View — ABS-T-007

**Classification:** Transaction (T — Calendar-first interactive UX; H5)
**Priority:** P1
**Primary Actor:** Employee (own calendar), Manager (team calendar)
**Secondary Actors:** HR Admin (company-wide view)
**Workflow States:** Read-only view with click-to-create entry point; no independent state machine
**API:** `GET /leaves/calendar?from=&to=&scope=team`, `GET /leaves/requests`, `GET /holidays/{year}/{countryCode}`
**User Stories:** US-ABS-013, US-ABS-014
**BRD Reference:** FR-ABS-006
**Hypothesis:** H5 (calendar-first UX — central navigation anchor)

---

## Purpose

The Leave Calendar is the central navigation anchor for both employees and managers in the Absence module. For employees, it provides a visual overview of their leave history and upcoming time off. For managers, it is the primary tool for assessing team availability and making informed approval decisions. The critical UX pattern from H5 is: clicking an empty date on the calendar immediately opens a pre-filled leave request form — the calendar is not just a viewer, it is a submission entry point.

---

## Screens and Steps

### Screen 1: Employee Leave Calendar

**Route:** `/leave/calendar`

**Entry points:**
- Employee → Leave → Calendar (primary nav item)
- ABS-T-001 Leave Request confirmation → "View in Calendar" CTA
- ABS-T-002 Approval notification → "View team calendar" link

**Layout — Month Grid:**

```
◀ February 2026          [Month ▼] [Year ▼]          March 2026 ▶

         Mon   Tue   Wed   Thu   Fri   Sat   Sun
Week 1    2     3     4     5     6     7     8
Week 2    9    10    11    12    13    14    15
Week 3   16    17    18    19    20    21    22
Week 4   23    24    25    26    27    28    29
Week 5   30    31     1     2     3     4     5
```

**Day cell content:**
- Date number (top-left of cell)
- Leave type color bar (if employee has leave on that day): full-width colored stripe at bottom of cell with leave type initials (e.g., "AL", "CT", "SL")
- Public holiday: yellow background with holiday name truncated (full name on hover/tap)
- Today: bold date, blue outline on cell
- Outside current month: greyed day number

**Click behaviors:**
- Click on a day with a leave request → open leave request detail (inline drawer or modal)
- Click on an empty working day → open ABS-T-001 Leave Request Form pre-filled with that date as start date (H5 core pattern)
- Click on a public holiday → tooltip showing holiday name; no leave form opens
- Click on weekend → no action (weekends are non-working per default policy)

**Toggle: Show Team Members' Leaves (Employee view):**
- Checkbox: "Show team leaves"
- When enabled: small colored dots appear below each day number representing team members on leave
- Clicking a dot reveals: "[Name] — [Leave Type] — [Date Range]"
- Default: OFF (to protect colleagues' privacy until employee opts in)

**Legend (fixed bottom of calendar):**
- Color swatches for each leave type the employee has access to
- Plus: Public Holiday (yellow), Today (blue outline)

**Navigation:**
- "Today" button: jump to current month
- Prev/Next month arrows
- Month + Year dropdowns for jump navigation

---

### Screen 2: Manager Team Leave Calendar

**Route:** `/leave/calendar/team`

**Entry points:**
- Manager → Leave → Team Calendar (primary nav item for managers)
- SHD-T-006 Approval Dashboard → "Team availability" mini-calendar → expand
- Manager home screen widget

**Layout — Month Grid (same base as Employee view, plus overlays):**

**Day cells (manager-specific view):**
- Date number
- "N on leave" pill: shows count of team members on leave that day (e.g., "3 on leave")
  - Click the pill → slide-out panel listing who is on leave that day with their leave type
  - Each name in the list is clickable → opens the individual leave request detail
- Public holiday: yellow background
- Coverage warning: if N on leave / total team size > configured threshold (default: 30%):
  - Cell gets amber border + warning icon
  - Tooltip: "[N] of [team size] team members on leave — check coverage"

**Individual employee row view (optional toggle):**
- Toggle: "Show individual rows"
- When enabled: calendar changes to a Gantt-style layout:
  - Rows = team members (sorted by name)
  - Columns = days of month
  - Colored bars = approved leave per employee per day

**Team filter:**
- "My direct reports" (default)
- "All reports (incl. indirect)" (for senior managers)
- Search by employee name within team

---

### Screen 3: Leave Detail Drawer (from calendar click)

Slides in from the right (desktop) or bottom sheet (mobile) when clicking an existing leave entry.

```
[Leave Type Icon]  Annual Leave

Nguyen Van A (own leave, or employee name if manager)
March 7, 2026 – March 11, 2026  •  5 working days
Status: APPROVED ✅
Approved by: Tran Thi B (Mar 3)
Note: —

[Edit Request]   [Cancel Request]   [Close]
```

- Edit/Cancel buttons: shown only if request is in a cancellable state (per ABS-T-003 rules)
- For manager view: "Approve" / "Reject" buttons shown if request is SUBMITTED

---

### Screen 4: Mobile — Weekly Scroll View

**Route:** `/leave/calendar` (mobile breakpoint)

**Layout:**
- Vertically scrollable list of weeks (instead of fixed month grid)
- Each week row: Mon–Sun columns, compact day cells
- Swipe left/right to navigate to adjacent week
- Swipe up/down to scroll forward/backward in the calendar
- "Jump to today" FAB (floating action button) bottom-right

**Touch interactions:**
- Tap on leave day: opens leave detail bottom sheet
- Tap on empty day: opens leave request form (H5 pattern — same as desktop)
- Long-press on any day: context menu with "Request Leave for this day"

---

## Notification Triggers

No notifications are generated by the calendar view itself. It reflects the state of existing leave requests and surfaces notification-worthy data (expiring comp time, upcoming approved leaves) that are triggered by ABS-T-004.

---

## Error States

| Error | User Message | Recovery Action |
|-------|-------------|-----------------|
| Calendar data unavailable | "Unable to load calendar data. Check your connection and refresh." | Refresh button |
| Team calendar — no reports found | "No direct reports found. Ensure your org chart is up to date in Employee Central." | HR Admin updates org chart |
| Coverage threshold not configured | Coverage warning feature disabled; no amber cells shown | HR Admin configures threshold in leave policy (ABS-M-002) |
| Leave request form fails to open (pre-fill error) | Form opens without pre-filled date; error toast "Could not pre-fill date — please select manually" | Employee selects date manually |

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-ABS-060 | Calendar shows leave requests in status: SUBMITTED, UNDER_REVIEW, APPROVED; DRAFT and CANCELLED are hidden |
| BR-ABS-061 | Public holidays are sourced from the SHD-M-001 Holiday Calendar assigned to the employee's work location |
| BR-ABS-062 | Coverage threshold for the manager warning is configurable per leave policy; defaults to 30% of headcount |
| BR-ABS-063 | When clicking an empty date to submit a leave request, the start date is pre-filled; the employee must select end date and leave type |
| BR-ABS-064 | Team leaves visible to an employee (when "Show team" is enabled) show leave type and duration only; personal details (reason) are not shown |

---

## Mobile Considerations (H5)

- Calendar-first is equally important on mobile; the weekly scroll view must feel native and fast
- Tap-to-submit (H5 click-to-create pattern) must be the primary leave entry point on mobile — as prominent as the "Request Leave" button in the nav menu
- Leave type colors must have sufficient contrast for accessibility (WCAG AA; support color-blind users with pattern differentiation in addition to color)
- Team calendar is desktop-optimized; on mobile it defaults to employee's own view; manager can switch to team view via a toggle
