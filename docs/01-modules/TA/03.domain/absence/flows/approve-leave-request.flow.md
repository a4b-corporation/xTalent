# Flow: Approve Leave Request

**Bounded Context:** ta.absence
**Use Case ID:** UC-ABS-002
**Version:** 1.0 | 2026-03-24

---

## Overview

A manager reviews a pending leave request and either approves, rejects, or
returns it for modification. Approval transitions the reservation to confirmed
status. Rejection releases the balance. Return for modification keeps the
reservation active while the employee revises dates or reason.

---

## Actors

| Actor | Role |
|-------|------|
| Manager | Reviews and acts on the leave request |
| System (ta.absence) | Processes approval action, updates balance, converts/releases reservation |
| System (ta.shared) | Sends notification to employee |
| Employee | Receives outcome notification |

---

## Preconditions

- LeaveRequest exists with status = SUBMITTED or UNDER_REVIEW
- Manager is the designated approver for the current ApprovalStep
- LeaveReservation is ACTIVE (balance is held)

---

## Postconditions (approval)

- LeaveRequest status = APPROVED
- LeaveReservation status = ACTIVE (will convert to USE movement on leave start date)
- Employee notified of approval

## Postconditions (rejection)

- LeaveRequest status = REJECTED
- LeaveReservation status = RELEASED
- LeaveMovement (type = RELEASE) appended — balance restored
- LeaveInstant.reserved decremented, available restored
- Employee notified of rejection with reason

## Postconditions (return for modification)

- LeaveRequest status = SUBMITTED (reset)
- Reservation maintained; no balance change
- Employee notified to revise and resubmit

---

## Happy Path: Manager Approves

```mermaid
sequenceDiagram
    actor Manager
    participant UI as xTalent UI
    participant ABS as ta.absence Service
    participant DB as Leave Ledger
    participant SHD as ta.shared Service
    actor Employee

    Manager->>UI: View pending leave requests (inbox)
    UI->>ABS: GetPendingRequests(approver_id=manager_id)
    ABS-->>UI: List of LeaveRequests with status = SUBMITTED

    Manager->>UI: Open request detail (employee, dates, balance preview)
    UI->>ABS: GetLeaveRequest(leave_request_id)
    ABS-->>UI: LeaveRequest + LeaveInstant (current balance)

    Manager->>UI: Click "Approve"
    UI->>ABS: ApproveLeaveRequest(leave_request_id, approver_id=manager_id)

    ABS->>ABS: Verify approver is current ApprovalStep owner
    ABS->>ABS: Check if this is the final approval step

    alt Final approval step
        ABS->>DB: UpdateLeaveRequest(status=APPROVED, approved_by, approved_at)
        Note over ABS,DB: BR-ABS-005: Approval triggers reservation confirmation.<br/>Reservation remains ACTIVE until leave start date,<br/>then converts to USE movement.
        ABS-->>UI: LeaveRequest status = APPROVED
    else Multi-step chain (more approvers needed)
        ABS->>DB: UpdateLeaveRequest(status=UNDER_REVIEW)
        ABS->>SHD: RouteApproval(next_step, next_approver_id)
        ABS->>SHD: SendNotification(event=LeaveRequestUnderReview, recipient=next_approver_id)
        ABS-->>UI: Request forwarded to next approver
    end

    ABS->>SHD: SendNotification(event=LeaveRequestApproved, recipient=employee_id)
    SHD-->>Employee: Notification: "Your leave request has been approved"
    UI-->>Manager: Confirmation: "Request approved"
```

---

## Alternative Path A: Manager Rejects

```mermaid
sequenceDiagram
    actor Manager
    participant UI as xTalent UI
    participant ABS as ta.absence Service
    participant DB as Leave Ledger
    participant SHD as ta.shared Service
    actor Employee

    Manager->>UI: Open request detail, click "Reject"
    UI->>Manager: Prompt: Enter rejection reason (required)
    Manager->>UI: Enter rejection_reason, confirm

    UI->>ABS: RejectLeaveRequest(leave_request_id, approver_id, rejection_reason)

    ABS->>DB: UpdateLeaveRequest(status=REJECTED, rejected_by, rejected_at, rejection_reason)

    ABS->>DB: UpdateLeaveReservation(status=RELEASED, released_at)
    ABS->>DB: AppendLeaveMovement(type=RELEASE, amount=+reserved_days)
    Note over ABS,DB: Immutable ledger: RELEASE movement created.<br/>Balance is restored in full.

    ABS->>ABS: Recompute LeaveInstant (available = earned - used - reserved)

    ABS->>SHD: SendNotification(event=LeaveRequestRejected, recipient=employee_id, rejection_reason)
    SHD-->>Employee: Notification: "Your leave request was rejected. Reason: {reason}"
    UI-->>Manager: Confirmation: "Request rejected"
```

---

## Alternative Path B: Manager Returns for Modification

```mermaid
sequenceDiagram
    actor Manager
    participant UI as xTalent UI
    participant ABS as ta.absence Service
    participant DB as Leave Ledger
    participant SHD as ta.shared Service
    actor Employee

    Manager->>UI: Open request, click "Return for Modification"
    UI->>Manager: Prompt: Enter return comment (required)
    Manager->>UI: Enter comment, confirm

    UI->>ABS: ReturnLeaveRequest(leave_request_id, approver_id, return_comment)

    ABS->>DB: UpdateLeaveRequest(status=SUBMITTED, return_comment)
    Note over ABS,DB: Reservation remains ACTIVE.<br/>No balance change. Request re-enters employee's queue.

    ABS->>SHD: SendNotification(event=LeaveRequestReturnedForModification, recipient=employee_id)
    SHD-->>Employee: Notification: "Your leave request was returned. Comment: {comment}"
    UI-->>Manager: Confirmation: "Request returned to employee"

    Note over Employee: Employee may edit dates/reason and resubmit.<br/>This triggers UC-ABS-001 again with updated data.
```

---

## Business Rules

| Rule ID | Description |
|---------|-------------|
| BR-ABS-005 | Approval triggers reservation confirmation: when all approval steps are complete, LeaveReservation remains ACTIVE and converts to a USE LeaveMovement on the leave start date |
| BR-ABS-010 | Rejection requires a mandatory rejection_reason text; empty reason must be blocked by the UI and API |
| ADR-TA-001 | Immutable ledger: RELEASE LeaveMovement is appended on rejection; the original RESERVE movement is never deleted or modified |
| BR-ABS-002 | Multi-step approval: if ApprovalChain has more than one step, request transitions to UNDER_REVIEW after first approval; APPROVED status requires all steps satisfied |

---

## Key Domain Objects Created / Modified

| Object | Action | Key Fields |
|--------|--------|------------|
| LeaveRequest | Updated | status (APPROVED / REJECTED / SUBMITTED), approved_by, rejected_by, rejection_reason |
| LeaveReservation | Updated | status (ACTIVE remains on approve; RELEASED on reject) |
| LeaveMovement | Appended | type=RELEASE, amount=+reserved_days (on rejection; immutable) |
| LeaveInstant | Updated | reserved--, available++ (on rejection only) |
| Notification | Created | event=LeaveRequestApproved or LeaveRequestRejected, recipient=employee |
