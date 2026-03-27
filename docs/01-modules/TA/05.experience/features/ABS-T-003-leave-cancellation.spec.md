# Leave Cancellation — ABS-T-003

**Classification:** Transaction (T)
**Priority:** P0
**Primary Actor:** Employee (initiates), Manager (approves post-deadline cancellations)
**Workflow States:** APPROVED → [CANCELLATION_REQUESTED] → CANCELLED
**API:** `POST /leaves/requests/{id}/cancel`, `POST /leaves/requests/{id}/cancel-approve`, `POST /leaves/requests/{id}/cancel-reject`
**User Stories:** US-ABS-005, US-ABS-006
**BRD Reference:** FR-ABS-003
**Hypothesis:** H-P0-001

---

## Purpose

Leave cancellation enables employees to withdraw an approved leave request, restoring the reserved balance. The critical UX requirement (H-P0-001) is the cancellation deadline: if the employee attempts to cancel after the configured deadline, the action routes to the manager for approval rather than executing immediately. The deadline must be prominently displayed so employees are always aware of their cancellation window. This prevents last-minute operational disruptions while still allowing legitimate cancellations with manager oversight.

---

## State Machine

```mermaid
stateDiagram-v2
    [*] --> APPROVED : Leave request has been approved

    APPROVED --> CANCELLED : Employee cancels before deadline\n(self-service; balance restored immediately)

    APPROVED --> CANCELLATION_REQUESTED : Employee requests cancellation after deadline\n(requires manager approval)

    CANCELLATION_REQUESTED --> CANCELLED : Manager approves cancellation\n(balance restored)

    CANCELLATION_REQUESTED --> APPROVED : Manager rejects cancellation\n(leave proceeds as planned)

    CANCELLED --> [*]
    APPROVED --> [*] : Leave period passes; auto-archived
```

---

## Screens and Steps

### Pre-Condition: Cancellation Deadline Display (H-P0-001)

The cancellation deadline is displayed prominently on every approved leave request card and detail screen. It is not hidden or secondary information.

**On leave request list card:**
- Status chip: APPROVED (green)
- Below status chip: "Cancellable until Apr 4, 2026" — always visible for approved requests
- When within 2 days of deadline: highlight with warning color (amber): "Cancel by tomorrow (Apr 4) for self-service cancellation"
- When past deadline: display "Deadline passed — cancellation requires manager approval"

**On leave request detail screen:**
- Dedicated info row: "Cancellation deadline: Apr 4, 2026"
- Past deadline: amber banner at top: "The self-service cancellation deadline has passed. You may still request cancellation, but your manager's approval is required."

---

### Path A: Pre-Deadline Cancellation (Self-Service)

**Entry:** Employee → My Leave Requests → Approved request → "Cancel Leave" button

**Step A1: Confirm Cancellation Dialog**
- Title: "Cancel Leave?"
- Summary: Leave type, dates, working days count
- Impact statement: "[X] days will be restored to your [leave type] balance."
- Warning if leave starts within 24 hours: "Your leave starts very soon. Are you sure you want to cancel?"
- Buttons: "Confirm Cancellation" (primary red) | "Keep Leave" (secondary)

**Step A2: Cancel API Call**
- POST /leaves/requests/{id}/cancel
- Response 200: request transitions to CANCELLED

**Step A3: Confirmation Screen**
- Success banner: "Leave cancelled"
- Balance restored: "[X] days returned to your [leave type] balance. New available balance: [Y] days."
- Request card status updated to CANCELLED with timestamp
- Employee notification sent

---

### Path B: Post-Deadline Cancellation (Manager Approval Required)

**Entry:** Employee → My Leave Requests → Approved request (past deadline) → "Request Cancellation" button

**Step B1: Amber Warning Banner on Request Detail**
- Displayed automatically when viewing any APPROVED request past its cancellation deadline
- Text: "The cancellation deadline for this request was [date]. Cancellation is still possible but requires your manager's approval."
- "Request Cancellation" button remains visible but labeled differently from pre-deadline

**Step B2: Cancellation Request Form**
- Title: "Request Cancellation (Manager Approval Required)"
- Summary of leave being cancelled
- Reason for cancellation (textarea; required; min 10 chars)
  - Help text: "Your manager will review this reason before approving or rejecting your cancellation request."
- "Submit Cancellation Request" button

**Step B3: API Call**
- POST /leaves/requests/{id}/cancel (with body: `requires_approval: true`, `reason: "[text]"`)
- Response 200: request transitions to CANCELLATION_REQUESTED

**Step B4: Pending State Screen**
- Status chip updates to: CANCELLATION REQUESTED (amber)
- Employee message: "Your cancellation request has been sent to [Manager Name] for review. Your leave remains scheduled until your manager responds."
- Option to withdraw the cancellation request (reverts to APPROVED)

---

### Path C: Manager Reviews Cancellation Request

**Entry:** Manager → Approvals → Leave Cancellations (separate sub-tab)

**Step C1: Cancellation Queue**
- Dedicated sub-tab within Approvals: "Cancellations" with count badge
- Request cards show:
  - Employee name + original leave details
  - Cancellation reason submitted by employee
  - "Post-deadline cancellation — requires decision" label
  - Days until leave starts (urgency indicator)

**Step C2: Cancellation Detail**
- Original leave request details
- Employee's cancellation reason
- Team impact: mini-calendar showing team availability on those dates (same H5 component as ABS-T-002)
- "Approve Cancellation" / "Reject Cancellation" buttons

**Step C3a: Manager Approves**
- POST /leaves/requests/{id}/cancel-approve
- Request transitions to CANCELLED
- Employee balance restored
- Both parties notified

**Step C3b: Manager Rejects**
- POST /leaves/requests/{id}/cancel-reject
- Request returns to APPROVED
- Employee notified: "Your cancellation request for [dates] has been rejected by [Manager Name]. Your leave will proceed as planned."

---

## Notification Triggers

| Event | Recipient | Channel | Template |
|-------|-----------|---------|---------|
| Pre-deadline cancel (self-service) | Employee | In-app | "Your [type] leave for [dates] has been cancelled. [X] days restored to your balance." |
| Post-deadline cancel requested | Manager | Push + Email | "Action required: [Employee] requests to cancel approved leave for [dates]. Reason: [reason]." |
| Manager approves cancellation | Employee | Push + In-app | "Your cancellation request for [type] leave [dates] has been approved. [X] days restored." |
| Manager rejects cancellation | Employee | Push + In-app | "Your cancellation request for [type] leave [dates] has been rejected. Leave proceeds as scheduled." |

---

## Error States

| Error | User Message | Recovery Action |
|-------|-------------|-----------------|
| Leave already started | "This leave has already started. Cancellation is not available once leave is in progress. Contact HR Admin if you need to adjust your leave." | Employee contacts HR |
| Cancellation deadline not configured | "Cancellation rules for this leave type are being configured. Contact HR Admin." | HR Admin sets deadline on leave type |
| Network error on cancel | "Unable to process your cancellation. Please try again." | Retry; draft saved locally |

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-ABS-050 | Cancellation deadline is defined on the LeaveType as `cancellation_deadline_days` before leave start date |
| BR-ABS-051 | Pre-deadline cancellation is self-service; balance is restored immediately |
| BR-ABS-052 | Post-deadline cancellation creates a CancellationRequest that routes through manager approval |
| BR-ABS-053 | A leave request cannot be cancelled after the leave has started (leave_start_date <= today) |
| BR-ABS-054 | If the manager does not act on a post-deadline cancellation within the escalation window, it escalates per the approval chain |
| BR-ABS-055 | Balance is only restored upon final CANCELLED status; CANCELLATION_REQUESTED does not affect balance |
