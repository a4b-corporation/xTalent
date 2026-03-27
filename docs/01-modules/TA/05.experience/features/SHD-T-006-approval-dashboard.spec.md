# Approval Dashboard — SHD-T-006

**Classification:** Transaction (T — Manager home screen aggregating all pending approvals)
**Priority:** P1
**Primary Actor:** Manager
**Secondary Actors:** Senior Manager (escalated items), HR Admin (override view)
**Workflow States:** Read-only aggregate + inline action triggers (delegates to ABS-T-002, ATT-T-003, ATT-T-004)
**API:** `GET /leaves/requests?status=pending&approver=me`, `GET /attendance/overtime/requests?status=pending&approver=me`, `GET /attendance/timesheets?status=pending&approver=me`
**User Story:** US-SHD-007
**BRD Reference:** BRD-SHD-009
**Hypothesis:** H1, H5 (team availability integration)

---

## Purpose

The Approval Dashboard is the manager's primary landing screen in xTalent. It aggregates all pending approval actions across Leave, Overtime, and Timesheets into a single queue, eliminating the need to navigate to three separate modules to check for pending work. The dashboard also surfaces proactive alerts (OT cap warnings, coverage risks) so managers can act before problems escalate. Inline approve/reject without page navigation is a core UX requirement: common approval decisions must be completable in the dashboard without a full-page context switch.

---

## Screens and Steps

### Screen 1: Approval Dashboard (Manager Home)

**Route:** `/dashboard` or `/approvals`

**Entry points:**
- Manager login → default landing screen
- Navigation → Dashboard (pinned in manager nav)
- Push notification → deep-link to relevant section

**Layout (desktop — three-column; mobile — single column stacked):**

**Stats Bar (top):**

```
┌─────────────────┬──────────────────┬────────────────────┐
│  LEAVE           │  OVERTIME         │  TIMESHEETS        │
│  8 pending       │  3 pending        │  12 pending        │
│  2 urgent        │  1 approaching cap│  Period closes Apr 5│
└─────────────────┴──────────────────┴────────────────────┘
```

- Each stat tile is clickable: filters the pending queue below to that type
- "Urgent" count: requests where leave/OT start date is within 3 days
- "Approaching cap": employees with OT > 80% of monthly cap in pending queue
- "Period closes [date]": shown in timesheet tile when period close date is within 7 days

**Pending Approval Queue (primary view — below stats bar):**

```
Pending Approvals (23 total)   [Leave ▼] [Employee ▼] [Date ▼]   [Sort: Oldest First]

☐  [Avatar] Nguyen Van A   Annual Leave   Apr 7–11 (5 days)   Submitted 3 days ago   ⚠ Urgent
                            [Approve]  [Reject]  [View Detail ↗]

☐  [Avatar] Tran Thi B     OT Request    Mar 28, 3h (200%)   Submitted 1 day ago    ⚡ Cap: 85%
                            [Approve]  [Reject]  [View Detail ↗]

☐  [Avatar] Le Van C       Timesheet     March 2026           Submitted 5 days ago
                            [Approve]  [Return]  [View Detail ↗]

☐  [Avatar] Pham Thi D     Annual Leave  Apr 3–4 (2 days)    Submitted today
                            [Approve]  [Reject]  [View Detail ↗]
```

**Queue item fields:**
- Checkbox (for bulk select)
- Employee avatar + name
- Request type badge (color-coded: Leave = green, OT = orange, Timesheet = blue)
- Summary: leave type + date range + working days / OT date + hours / timesheet period
- Submission age: "Submitted [X] hours/days ago" (oldest-first sort by default)
- Alert badges:
  - "⚠ Urgent": start date within 3 days
  - "⚡ Cap: [X]%": OT requests where employee is above 80% monthly OT cap
  - "Escalated": item was escalated to this manager from a lower level
- Inline actions:
  - Leave: [Approve] [Reject]
  - OT: [Approve] [Reject]
  - Timesheet: [Approve] [Return]
  - [View Detail ↗]: opens full detail in a new page (ABS-T-002, ATT-T-003, ATT-T-004 detail screens)

**Inline Approve (Leave / OT — no page navigation):**
- Click "Approve" → confirmation popover anchored to the row:
  ```
  Approve [Type] for [Name]?
  [Date/Period] — [Summary]
  Optional note: [___]
  [ Cancel ]  [ Confirm ]
  ```
- On confirm: API call fires; row updates status to APPROVED; row slides out of queue with green "Approved" flash
- Row remains visible for 2 seconds with "Approved" badge before removal (allows undo sense without actual undo)

**Inline Reject (Leave / OT — no page navigation):**
- Click "Reject" → popover:
  ```
  Reject [Type] for [Name]?
  Reason (required): [_______________]
  [ Cancel ]  [ Confirm Rejection ]
  ```
- On confirm: API call fires; row updates to REJECTED; row slides out with red "Rejected" flash

**Inline Return (Timesheet — no page navigation):**
- Click "Return" → popover:
  ```
  Return timesheet to [Name]?
  Comment (required): [_______________]
  [ Cancel ]  [ Confirm Return ]
  ```

**Bulk Approve:**
- Select checkboxes on multiple rows → floating action bar appears at bottom: "Approve [N] selected"
- Click "Approve [N]": confirmation modal lists all selected items
- Items of different types can be bulk-approved in one action (Leave + OT + Timesheets together)
- Return/Reject cannot be bulk-applied (requires individual reason per item)
- On confirm: batch API calls; summary shown: "Approved [N] of [M]. [X] failed — please retry individually."

---

### Section 2: Team Availability Mini-Calendar (H5 Integration)

**Position:** Right panel on desktop; collapsible section on mobile (collapsed by default)

**Layout:**
- This week's calendar (Mon–Sun) embedded in the dashboard
- Each day shows: "[N] on leave" count colored by threshold
  - Green: 0–1 on leave
  - Amber: approaching coverage threshold (e.g., >2 for a 5-person team)
  - Red: at or over coverage threshold
- Days with pending leave requests shown with dotted border (not yet approved)
- "View full team calendar" link → opens ABS-T-007 Manager Team Calendar

**Purpose in dashboard context:** Enables manager to see at a glance whether approving the pending leave requests in the queue would cause a coverage gap. The pending requests in the queue are shown as "pending" dots on the calendar before approval.

---

### Section 3: OT Cap Alerts Panel

**Position:** Bottom-left panel on desktop; below queue on mobile (collapsed)

**Layout:**

```
OT Cap Alerts — March 2026
──────────────────────────────────────────
Nguyen Van A   Annual Leave   38.5h / 40h  96%  🔴
Tran Thi B     Annual Leave   33.0h / 40h  83%  🟡
──────────────────────────────────────────
2 employees approaching or at monthly OT cap.
[View full OT report]
```

- Shows employees with > 80% monthly OT cap utilization
- Clicking an employee name → opens their timesheet / OT summary
- "View full OT report" → opens ATT-A-001 (Phase 2) or the ATT-T-002 OT calculation screen for the period

---

## Notification Triggers

| Event | Recipient | Channel | Template |
|-------|-----------|---------|---------|
| New pending approval arrives | Manager | Push + In-app badge | "[Employee Name] has submitted a [request type] request for [date/period]. Action required." |
| Approval dashboard pending count > 10 | Manager | In-app badge | Badge count visible on nav icon; no additional notification |
| Item escalated to this manager | Manager | Push + Email | "An approval request from [Employee] has been escalated to you. [N] hours without action from direct manager." |
| OT cap exceeded for team member | Manager | In-app toast | "[Employee Name] has reached the monthly OT cap. New OT approvals for them are blocked." |

---

## Error States

| Error | User Message | Recovery Action |
|-------|-------------|-----------------|
| Inline approval already actioned | "This request has already been actioned by another approver." | Row removes itself from queue on next refresh |
| Bulk approve partial failure | "Approved [N] of [M] selected items. [X] failed — view below for details." | Retry failed items individually |
| Dashboard data load failure | "Unable to load pending approvals. Refresh to try again." | Refresh button; auto-retry after 30s |
| Network failure during inline action | "Unable to save decision. Your action has not been applied. Please retry." | Retry; original state preserved |

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-SHD-020 | Dashboard shows only requests assigned to this manager's approval step; items in a different approver's queue are not visible |
| BR-SHD-021 | Escalated items appear in the dashboard with an "Escalated" badge; they are treated identically to normal pending items for action purposes |
| BR-SHD-022 | Inline approve/reject in the dashboard triggers the same backend action as approve/reject in the full detail screen; both paths are equivalent |
| BR-SHD-023 | Bulk approve is limited to 50 items per batch to prevent timeout; if more than 50 selected, remaining items must be approved in subsequent batches |
| BR-SHD-024 | The OT cap alert threshold is 80% of the configured monthly cap; this threshold is not configurable per manager, only per tenant |

---

## Mobile Considerations

- Stats bar shown as horizontal scrollable cards on mobile (not a 3-column grid)
- Pending queue: full-width list items; inline actions accessible via swipe-left (swipe reveals Approve / Reject/Return buttons)
- Team calendar section: collapsed by default on mobile; expandable tap to reveal
- OT cap alerts: collapsed on mobile; badge count shown in section header
- Bulk select: long-press on any item to enter multi-select mode; floating action bar appears at bottom
