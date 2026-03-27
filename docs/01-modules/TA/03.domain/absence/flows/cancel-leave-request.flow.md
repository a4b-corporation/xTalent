# Flow: Cancel Leave Request

**Bounded Context:** ta.absence
**Use Case ID:** UC-ABS-003
**Version:** 1.0 | 2026-03-24

---

## Overview

An employee requests cancellation of a previously submitted or approved leave
request. The flow branches based on H-P0-001: whether the cancellation is before
or after the configured deadline. Pre-deadline cancellations are auto-approved.
Post-deadline cancellations require manager approval.

Cancellation of a leave request that has already started (leave_start_date <= today)
is not permitted.

---

## Actors

| Actor | Role |
|-------|------|
| Employee | Initiates the cancellation request |
| System (ta.absence) | Evaluates deadline, transitions status, restores balance |
| Manager | Acts on post-deadline cancellation requests (Path B only) |
| System (ta.shared) | Sends notifications |

---

## Preconditions

- LeaveRequest exists with status = SUBMITTED, UNDER_REVIEW, or APPROVED
- LeaveRequest.start_date > today (leave has not yet started)
- Employee is the request owner (cancelled_by = employee_id)

---

## Postconditions (Path A — pre-deadline, auto-approved)

- LeaveRequest status = CANCELLED
- LeaveReservation status = RELEASED
- LeaveMovement (type = RELEASE) appended — full balance restored
- LeaveInstant.reserved decremented, available fully restored (BR-ABS-009)
- Employee notified of cancellation confirmation

## Postconditions (Path B — post-deadline, manager approved)

- LeaveRequest status = CANCELLED (after manager approval)
- LeaveReservation status = RELEASED
- LeaveMovement (type = RELEASE) appended — full balance restored
- Employee and manager both notified

## Postconditions (Path B — post-deadline, manager rejected)

- LeaveRequest status = APPROVED (unchanged)
- LeaveReservation remains ACTIVE
- Employee notified that cancellation was denied

---

## Path A: Cancel Before Deadline (Auto-Approved)

```mermaid
sequenceDiagram
    actor Employee
    participant UI as xTalent UI
    participant ABS as ta.absence Service
    participant DB as Leave Ledger
    participant SHD as ta.shared Service

    Employee->>UI: Navigate to My Requests, select leave request
    UI->>ABS: GetLeaveRequest(leave_request_id, employee_id)
    ABS-->>UI: LeaveRequest { status, start_date, cancellation_deadline }

    Employee->>UI: Click "Cancel Request"

    ABS->>ABS: Evaluate: today <= cancellation_deadline? (BR-ABS-007)
    Note over ABS: cancellation_deadline was set at submission time (H-P0-001).<br/>Example: start_date=2026-04-10, deadline_days=1 → deadline=2026-04-08

    ABS->>ABS: today(2026-04-07) <= deadline(2026-04-08) → Path A: Pre-deadline

    UI->>ABS: CancelLeaveRequest(leave_request_id, employee_id, cancellation_reason)

    ABS->>DB: UpdateLeaveRequest(status=CANCELLED, cancelled_by=employee_id, cancelled_at)
    ABS->>DB: UpdateLeaveReservation(status=RELEASED, released_at)
    ABS->>DB: AppendLeaveMovement(type=RELEASE, amount=+reserved_days)
    Note over ABS,DB: BR-ABS-009: Full balance restored.<br/>Immutable RELEASE movement created. No partial restore.

    ABS->>ABS: Recompute LeaveInstant (available = earned - used - reserved)

    ABS->>SHD: SendNotification(event=LeaveRequestCancelled, recipient=employee_id)
    SHD-->>Employee: Notification: "Your leave request has been cancelled. Balance restored."
```

---

## Path B: Cancel After Deadline (Requires Manager Approval)

```mermaid
sequenceDiagram
    actor Employee
    participant UI as xTalent UI
    participant ABS as ta.absence Service
    participant DB as Leave Ledger
    participant SHD as ta.shared Service
    actor Manager

    Employee->>UI: Navigate to My Requests, click "Cancel Request"
    UI->>ABS: GetLeaveRequest(leave_request_id, employee_id)
    ABS-->>UI: LeaveRequest { start_date, cancellation_deadline }

    ABS->>ABS: Evaluate: today > cancellation_deadline? (BR-ABS-006)
    Note over ABS: today(2026-04-09) > deadline(2026-04-08) → Path B: Post-deadline

    UI->>Employee: Warn: "Cancellation after deadline requires manager approval"
    Employee->>UI: Confirm and provide cancellation_reason

    UI->>ABS: RequestCancellationApproval(leave_request_id, employee_id, cancellation_reason)

    ABS->>DB: UpdateLeaveRequest(status=CANCELLATION_PENDING, cancelled_by=employee_id)
    Note over ABS,DB: BR-ABS-008: Reservation remains ACTIVE.<br/>Balance still held pending manager decision.

    ABS->>SHD: SendNotification(event=CancellationApprovalRequired, recipient=manager_id)
    SHD-->>Manager: Notification: "Employee requests leave cancellation (post-deadline). Action required."

    alt Manager Approves Cancellation
        Manager->>UI: View cancellation request, click "Approve Cancellation"
        UI->>ABS: ApproveCancellation(leave_request_id, manager_id)

        ABS->>DB: UpdateLeaveRequest(status=CANCELLED, cancellation_approved_by=manager_id)
        ABS->>DB: UpdateLeaveReservation(status=RELEASED, released_at)
        ABS->>DB: AppendLeaveMovement(type=RELEASE, amount=+reserved_days)
        Note over ABS,DB: BR-ABS-009: Full balance restored on approval.

        ABS->>ABS: Recompute LeaveInstant

        ABS->>SHD: SendNotification(event=LeaveRequestCancelled, recipient=employee_id)
        SHD-->>Employee: Notification: "Your cancellation was approved. Balance restored."

    else Manager Denies Cancellation
        Manager->>UI: View request, click "Deny Cancellation", enter reason
        UI->>ABS: DenyCancellation(leave_request_id, manager_id, denial_reason)

        ABS->>DB: UpdateLeaveRequest(status=APPROVED)
        Note over ABS,DB: Request reverts to APPROVED. Reservation stays ACTIVE.<br/>Leave proceeds as originally scheduled.

        ABS->>SHD: SendNotification(event=CancellationDenied, recipient=employee_id, denial_reason)
        SHD-->>Employee: Notification: "Your cancellation request was denied. Leave remains scheduled."
    end
```

---

## Exception Path: Leave Already Started

```mermaid
sequenceDiagram
    actor Employee
    participant UI as xTalent UI
    participant ABS as ta.absence Service

    Employee->>UI: Attempt to cancel leave request
    UI->>ABS: CancelLeaveRequest(leave_request_id, employee_id)

    ABS->>ABS: Check: start_date <= today?
    Note over ABS: Leave has already started. Cancellation not permitted.

    ABS-->>UI: Error: LeaveAlreadyStarted
    UI->>Employee: "Cancellation is not allowed after leave has started. Contact HR."
    Note over Employee: Employee must contact HR Administrator for manual adjustment.
```

---

## Business Rules

| Rule ID | Description |
|---------|-------------|
| BR-ABS-006 | Cancellation deadline is configurable: set in LeaveType.cancellation_deadline_days (tenant-level default in TenantConfig.cancellation_deadline_days). Computed at request submission time (H-P0-001) |
| BR-ABS-007 | Self-cancel before deadline: employee may cancel without manager approval if today <= cancellation_deadline |
| BR-ABS-008 | Manager approval after deadline: cancellations submitted after the deadline require manager approval; LeaveRequest transitions to CANCELLATION_PENDING; reservation remains active until manager acts |
| BR-ABS-009 | Full balance restore: when a cancellation is completed (either auto or manager-approved), the full reserved balance is restored via a RELEASE LeaveMovement; no partial restoration |
| ADR-TA-001 | Immutable ledger: RELEASE movement is appended; original RESERVE movement is never deleted |
| H-P0-001 | Cancellation deadline policy: deadline computed at submission time and stored on LeaveRequest; default = 1 business day before leave start date; configurable per tenant/BU |

---

## Key Domain Objects Created / Modified

| Object | Action | Key Fields |
|--------|--------|------------|
| LeaveRequest | Updated | status (CANCELLATION_PENDING → CANCELLED or APPROVED), cancelled_by, cancellation_approved_by |
| LeaveReservation | Updated | status = RELEASED (on final cancellation approval) |
| LeaveMovement | Appended | type=RELEASE, amount=+reserved_days (immutable; full restore per BR-ABS-009) |
| LeaveInstant | Updated | reserved--, available++ (on cancellation completion) |
| Notification | Created | CancellationApprovalRequired (to manager), LeaveRequestCancelled or CancellationDenied (to employee) |
