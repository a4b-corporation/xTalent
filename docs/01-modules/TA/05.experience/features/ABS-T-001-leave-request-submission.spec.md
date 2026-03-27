# Leave Request Submission — ABS-T-001

**Classification:** Transaction (T)
**Priority:** P0
**Primary Actor:** Employee
**Secondary Actors:** Manager (notified), HR Admin (proxy submit)
**Workflow States:** DRAFT → SUBMITTED → UNDER_REVIEW → APPROVED / REJECTED → CANCELLED
**API:** `POST /leaves/requests`, `GET /leaves/requests`, `GET /leaves/balances`
**User Story:** US-ABS-001
**BRD Reference:** FR-ABS-003
**Hypothesis:** H1, H5 (calendar entry point — P1)

---

## Purpose

Leave Request Submission is the most frequent daily interaction for employees. It enables an employee to formally request time off by selecting a leave type, date range, and optional reason. The system validates balance availability, reserves the requested days to prevent overbooking, and routes the request through the configured approval chain. This feature replaces email/spreadsheet-based leave requests.

---

## State Machine

```mermaid
stateDiagram-v2
    [*] --> DRAFT : Employee starts form (auto-save)
    DRAFT --> SUBMITTED : Employee submits
    SUBMITTED --> UNDER_REVIEW : First approver opens request
    UNDER_REVIEW --> APPROVED : All approval levels pass
    UNDER_REVIEW --> REJECTED : Any approver rejects
    SUBMITTED --> APPROVED : Auto-approve (if policy = no approval required)
    APPROVED --> CANCELLATION_REQUESTED : Employee requests cancel post-deadline
    APPROVED --> CANCELLED : Employee cancels pre-deadline (self-service)
    CANCELLATION_REQUESTED --> CANCELLED : Manager approves cancellation
    CANCELLATION_REQUESTED --> APPROVED : Manager rejects cancellation request
    REJECTED --> DRAFT : Employee edits and resubmits
    CANCELLED --> [*]
    APPROVED --> [*] : Leave period passes; auto-archived
```

---

## Screens and Steps

### Step 1: Leave Request Form

**Entry points:**
- Employee → Leave → Request Leave (primary)
- Employee Home → "Request Leave" quick action button
- Calendar date click (P1 — ABS-T-007)

**Layout (mobile and web):**
- Leave Type selector (dropdown; shows only leave types in employee's active policy)
  - Each option shows: type name + available balance in days
  - Grayed out options: leave types with 0 balance and `allow_advance_leave = false`
- Date Range picker
  - Start date and end date
  - Calendar component highlights: public holidays (grey, skipped), weekends (grey, skipped), existing leave (orange, blocked), available days (white, selectable)
  - Below date picker: computed "Working days: X" (real-time, excludes holidays and weekends)
- Reason / Notes (textarea; optional unless `evidence_required = true` on leave type)
- Evidence upload (file input; shown only if `evidence_required = true`; grace period note: "You have [N] days after leave starts to upload evidence.")

**Real-time validation (as user interacts):**
- After type + dates selected: show "Balance after approval: [available - requested] days"
- If requested > available and advance not allowed: red banner "Insufficient balance: [X] days requested, [Y] days available"
- If dates overlap existing leave: red banner "Date conflict: you already have a leave request from [date] to [date]"
- If dates span more than 30 days: warning "Extended leave requests may require HR review"

**Actions:**
- "Check Balance" — refreshes real-time balance display
- "Submit" — triggers POST /leaves/requests
- "Save Draft" — saves locally or as DRAFT status
- "Cancel" — returns to request list; discards unsaved changes with confirmation

### Step 2: Submission Confirmation Screen

Shown immediately after successful POST /leaves/requests (HTTP 201):

- Success banner: "Leave request submitted"
- Request summary card:
  - Request ID (formatted: LR-2026-04-007 or similar)
  - Leave Type
  - Date range: Apr 7, 2026 – Apr 9, 2026 (3 working days)
  - Status badge: SUBMITTED
  - "Awaiting approval from: [Manager Name]" (first approver from chain)
- Balance update: "New available balance: [X] days (reservation applied)"
- "View Request" CTA → goes to request detail screen
- "Request Another Leave" CTA

### Step 3: My Leave Requests List

**Route:** `/leave/requests`

**Layout:**
- Filter tabs: All / Pending / Approved / Rejected / Cancelled
- Request cards (sorted by submitted date, newest first):
  - Leave type name + type icon
  - Date range + working days count
  - Status badge
  - Cancellation deadline (shown on APPROVED requests): "Cancellable until [date]" — highlighted if within 2 days
  - Actions: View | Cancel (if cancellable)
- Empty state per filter: e.g., "No pending requests. Submit a leave request when you need time off."

---

## Notification Triggers

| Event | Recipient | Channel | Template |
|-------|-----------|---------|---------|
| Leave request submitted (SUBMITTED) | Employee | Push + In-app | "Your leave request for [type] [dates] has been submitted. Awaiting [Manager Name]'s approval." |
| Leave request submitted | Manager (Level 1 approver) | Push + Email | "Action required: [Employee Name] has requested [N] days [leave type] from [date]. Review and approve in xTalent." |
| Leave request approved | Employee | Push + In-app | "Your [type] leave request for [dates] has been approved." |
| Leave request rejected | Employee | Push + In-app | "Your [type] leave request for [dates] has been rejected. Reason: [reason]. You can edit and resubmit." |

---

## Error States

| Error | User Message | Recovery Action |
|-------|-------------|-----------------|
| Insufficient balance | "Insufficient balance: [X] days requested, [Y] days available for [leave type]." | Reduce date range or choose a different leave type |
| Date overlap with existing request | "Date conflict: you already have a [type] request from [date] to [date]." | Adjust dates to non-overlapping range |
| No active policy | "You are not currently assigned a leave policy. Contact HR to resolve this." | Employee contacts HR Admin |
| Leave type inactive | Leave type is removed from dropdown; no error shown | Select different leave type |
| Submission fails (network / server) | "Unable to submit your request. Please try again. If the problem persists, contact support." | Retry button; draft preserved locally |
| Holiday-only range selected | "The selected date range contains only public holidays and weekends. Select dates that include working days." | Adjust dates |

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-ABS-030 | Balance is validated at submission time; reservation created atomically |
| BR-ABS-031 | Dates are validated against the employee's HolidayCalendar; non-working days are excluded from the day count |
| BR-ABS-032 | Overlapping leave requests are blocked; employee must resolve existing requests first |
| BR-ABS-033 | Draft requests do not reserve balance; reservation occurs only on SUBMITTED status |
| BR-ABS-034 | The approval chain is resolved at submission time based on the current org structure from Employee Central |

---

## Mobile Considerations (H6)

- The Request Leave form must load within 2 seconds on a 4G connection.
- The date picker must support touch gestures: tap to select, tap-drag to extend range.
- File evidence upload supports camera capture directly (no need to pre-save to gallery).
- If submitted while offline: show inline message "Your request is queued and will be submitted when your connection is restored." Queue stored locally; auto-submits on reconnect.
- The confirmation screen and balance update must work via SSE update, not full page reload.
