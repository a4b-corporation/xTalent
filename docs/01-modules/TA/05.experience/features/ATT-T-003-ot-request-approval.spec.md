# Overtime Request + Approval — ATT-T-003

**Classification:** Transaction (T — Multi-level approval with skip-level routing)
**Priority:** P0
**Primary Actor:** Employee (submit); Manager (approve — or skip-level if self)
**Secondary Actors:** Senior Manager / HR Admin (skip-level target); Payroll Officer (view in timesheet)
**Workflow States:** DRAFT → SUBMITTED → APPROVED / REJECTED → CANCELLED
**API:** `POST /attendance/overtime/requests`, `POST /attendance/overtime/requests/{id}/approve`, `POST /attendance/overtime/requests/{id}/reject`, `GET /attendance/overtime/requests`
**User Stories:** US-ATT-002, US-ATT-003, US-ATT-004
**BRD Reference:** BRD-ATT-002
**Hypothesis:** H-P0-003 (skip-level routing for manager self-submission)

---

## Purpose

OT Request + Approval manages the formal pre-authorization of overtime hours. Employees (including managers) must request OT before working beyond standard shift hours. The system enforces monthly and annual OT caps (VLC Art. 107), routes approvals through the configured chain, and handles the skip-level case where a manager's own OT request must go to their superior rather than themselves (H-P0-003). Transparent routing — the submitter always sees who will review their request — is a core UX principle.

---

## State Machine

```mermaid
stateDiagram-v2
    [*] --> DRAFT : Employee opens OT request form
    DRAFT --> SUBMITTED : Employee submits request
    SUBMITTED --> UNDER_REVIEW : Approver opens request
    UNDER_REVIEW --> APPROVED : Approver approves
    UNDER_REVIEW --> REJECTED : Approver rejects
    SUBMITTED --> APPROVED : Auto-approve (if policy = no approval required)
    APPROVED --> CANCELLED : Employee cancels before OT date
    REJECTED --> DRAFT : Employee edits and resubmits
    SUBMITTED --> ESCALATED : Approval timeout reached
    ESCALATED --> APPROVED : Escalation target approves
    ESCALATED --> REJECTED : Escalation target rejects
    CANCELLED --> [*]
    APPROVED --> [*] : OT date passes; OT lines auto-created in timesheet
```

---

## Screens and Steps

### Screen 1: OT Request Form

**Route:** `/attendance/overtime/new`

**Entry points:**
- Employee → Attendance → Overtime → Request OT
- Timesheet view → "Add OT" button on a specific day
- Manager → Attendance → "Request My OT" (routes to same form; skip-level logic activates)

**Layout:**

**Date field:**
- Date picker (single date for the OT work date)
- Highlights: public holidays (yellow background — 300% rate), weekends (light grey — 200% rate), weekdays (white — 150% rate)
- Rate preview appears after date selection: "Applicable rate: 150% (weekday)"

**Planned Hours field:**
- Number input (0.5–12.0 hours; increment 0.5)
- Minimum: 0.5h; Maximum: 12.0h per day

**Reason field:**
- Textarea (required; min 10 characters)
- Helper text: "Describe why overtime is necessary on this date"

**OT Cap Summary (live, updates as user enters hours):**

```
┌──────────────────────────────────────────────────┐
│ Your OT cap status:                              │
│ Monthly: 12.5h used / 40h cap  (31% used)        │
│ Requesting: 3.0h                                  │
│ After this request: 15.5h / 40h  (39%)  ✅       │
│                                                    │
│ Annual: 127.5h used / 200h cap  (64% used)  ✅   │
└──────────────────────────────────────────────────┘
```

- Green checkmark if request is within cap
- Amber warning if request would bring total above 80% of cap: "After this request you will be at [X]% of your monthly cap"
- Red error + disabled Submit if request would exceed cap: "Cannot submit — this request would exceed your monthly OT cap ([cap]h). You have [remaining]h remaining."

**Skip-Level Routing Banner (H-P0-003 — shown only when submitter is a Manager):**

```
┌──────────────────────────────────────────────────┐
│  ⚠ Skip-level routing applies                   │
│  Because you are a manager, this OT request     │
│  will be sent to [Senior Manager Name]           │
│  ([Senior Manager Title]) for approval.          │
│  Your own direct reports cannot approve your     │
│  requests.                                       │
└──────────────────────────────────────────────────┘
```

- Shown as an informational amber banner, not an error
- Resolves who the skip-level approver is from the approval chain config (SHD-T-001)
- If skip-level approver cannot be determined (chain not configured): banner shows "Routing to HR Admin for approval" and flags for manual assignment

**Actions:**
- "Submit" — POST /attendance/overtime/requests
- "Save Draft" — saves locally
- "Cancel" — returns to OT list

---

### Screen 2: OT Request Submitted Confirmation

Shown immediately after successful POST:

```
┌──────────────────────────────────────────────────┐
│  ✅ OT Request Submitted                        │
│                                                    │
│  Request:  OT-2026-03-018                         │
│  Date:     Saturday, March 28, 2026               │
│  Hours:    3.0h  (200% rate — rest day)          │
│  Reason:   Product launch preparation             │
│  Status:   SUBMITTED                              │
│                                                    │
│  Pending approval from: [Manager Name]            │
│  (or [Senior Manager] if skip-level)             │
│                                                    │
│  [View Request]   [Back to Attendance]            │
└──────────────────────────────────────────────────┘
```

---

### Screen 3: My OT Requests List

**Route:** `/attendance/overtime`

**Layout:**
- Filter tabs: All / Pending / Approved / Rejected / Cancelled
- List items (newest first):
  - OT Request ID
  - Date + day type (weekday/weekend/holiday badge)
  - Hours + rate (150% / 200% / 300%)
  - Status badge
  - Approval routing: "Awaiting: [Name]" or "Approved by: [Name]"
  - Actions: View | Cancel (if date not yet passed and status = SUBMITTED/APPROVED)

---

### Screen 4: Approval View (for Approver — Manager or Skip-Level)

**Entry points:**
- Approver notification → deep-link to this screen
- SHD-T-006 Approval Dashboard → drill-down to OT request
- Manager → Approvals → Overtime tab

**Layout (split-panel desktop; stacked mobile):**

**Left/Top — Request Details:**
- Employee name + avatar + position
- Date + rate indicator (150% / 200% / 300% badge in appropriate color)
- Planned hours
- Reason
- Request submitted [X] hours ago
- OT Request ID

**Right/Bottom — Context Panel:**

```
[Employee Name]'s OT Usage — March 2026
─────────────────────────────────────────
Monthly:  12.5h used  ████████░░░░░░  31% of 40h cap
Annual:   127.5h used ████████████░░  64% of 200h cap
─────────────────────────────────────────
This request: +3.0h
After approval: 15.5h monthly (39%)  ✅
```

**Skip-level context notice (shown on approver's view when reviewing a manager's request):**
```
┌──────────────────────────────────────────────────┐
│  Note: You are approving this request on behalf  │
│  of [Submitter Name]'s reporting line.           │
│  [Submitter Name] is a manager; skip-level       │
│  routing applies per policy.                     │
└──────────────────────────────────────────────────┘
```

**Action bar (sticky bottom):**
- "Approve" button (primary, green)
- "Reject" button (secondary, outlined red)

---

### Step 5a: Approve OT — Confirmation Modal

```
Approve OT Request?

Approve [N]h overtime on [date] for [Employee Name]?
Rate: [150% / 200% / 300%]

Optional note for employee:
[                          ]

[ Cancel ]   [ Confirm Approval ]
```

On confirm: POST /attendance/overtime/requests/{id}/approve
On success: status badge updates to APPROVED; employee notified; OT hours queued for timesheet

---

### Step 5b: Reject OT — Dialog

```
Reject OT Request

Reason for rejection (required):
[                                        ]
[                                        ]

[ Cancel ]   [ Confirm Rejection ]
```

- Reason required, min 10 characters
- On confirm: POST /attendance/overtime/requests/{id}/reject
- Employee notified with rejection reason
- Employee can edit and resubmit (REJECTED → DRAFT)

---

## Notification Triggers

| Event | Recipient | Channel | Template |
|-------|-----------|---------|---------|
| OT request submitted | Employee | In-app | "Your OT request for [date] ([N]h) has been submitted. Awaiting [Approver Name]'s decision." |
| OT request submitted | Approver | Push + Email | "Action required: [Employee Name] has requested [N]h overtime on [date]. Review and approve." |
| OT request submitted (skip-level) | Skip-level Approver | Push + Email | "Action required: [Manager Name] has requested [N]h overtime on [date]. Review and approve. (Skip-level routing)" |
| OT approved | Employee | Push + In-app | "Your OT request for [date] ([N]h) has been approved by [Approver Name]." |
| OT rejected | Employee | Push + In-app | "Your OT request for [date] ([N]h) has been rejected. Reason: [reason]. You can edit and resubmit." |
| OT cap approaching 80% | Employee | In-app toast | "You have used [N]h of your [cap]h monthly OT cap. [remaining]h remaining this month." |
| Approval overdue escalation | Skip-level / HR Admin | Push + Email | "OT approval overdue: [Employee]'s OT request for [date] has been escalated after [N] hours." |

---

## Error States

| Error | User Message | Recovery Action |
|-------|-------------|-----------------|
| Monthly OT cap exceeded | "Cannot submit — this would exceed your monthly OT cap ([cap]h used, [remaining]h remaining)." | Reduce hours or wait for next month |
| Annual OT cap exceeded | "Cannot submit — you have reached the annual OT cap of [cap]h. Contact HR for an exemption." | HR Admin reviews + policy exception |
| OT date in the past (>7 days) | "OT requests for dates more than 7 days in the past require HR Admin submission." | HR Admin submits on behalf via admin panel |
| Date already has approved OT | "An approved OT request already exists for [date] ([N]h). Cancel it before submitting a new request." | Cancel existing OT request first |
| Skip-level approver not found | "Skip-level approver could not be determined. Request routed to HR Admin for approval." | HR Admin reviews chain config (SHD-T-001) |
| Submission fails (network) | "Unable to submit OT request. Draft saved. Please try again when connected." | Retry with saved draft |

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-ATT-030 | Monthly OT cap defaults to 40h; system blocks request submission when adding requested hours would exceed cap |
| BR-ATT-031 | Annual OT cap defaults to 200h (VLC Art. 107); cap violation blocks submission |
| BR-ATT-032 | When a manager submits their own OT request, approval routing skips their direct reports and goes to their own line manager (skip-level per H-P0-003) |
| BR-ATT-033 | If no skip-level approver is configured, the request is routed to HR Admin |
| BR-ATT-034 | On approval, OT hours are written into the employee's timesheet for the relevant period; timesheet recalculates OT breakdown |
| BR-ATT-035 | OT rate is determined by the date type at request submission time (weekday/weekend/holiday per the holiday calendar); rate is locked at approval and cannot change retroactively |
