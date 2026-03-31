# Flow: Submit & Approve Leave Request (End-to-End)

**Bounded Context:** ta.absence
**Use Case ID:** UC-ABS-001 → UC-ABS-002
**Version:** 2.0 | 2026-03-31

> **Note:** This document merges UC-ABS-001 (Submit Leave Request) and UC-ABS-002 (Approve Leave Request)
> into a single end-to-end flow. The process does not stop at RESERVE balance — it continues through
> the full approval lifecycle until the request reaches a terminal state (APPROVED, REJECTED, or
> returned for employee revision).

---

## Overview

An employee submits a request for time off. The system validates available balance, adjusts for
public holidays and weekends, reserves balance using FEFO ordering, and routes the request to the
appropriate manager for approval. The manager then reviews the request and either approves, rejects,
or returns it for modification — completing the full leave request lifecycle.

---

## Actors

| Actor | Role |
|-------|------|
| Employee | Initiates the leave request; receives outcome notification |
| System (ta.absence) | Validates balance, calculates working days, creates reservation, processes approval action |
| System (ta.shared) | Resolves holiday calendar, triggers notifications, routes approval chain |
| Manager | Reviews and acts on the leave request (approve / reject / return) |

---

## Preconditions

- Employee is active with a valid employment record in Employee Central
- At least one LeavePolicy is active for the employee and leave type
- The Period covering the requested dates is in OPEN status
- HolidayCalendar for the employee's country_code is published for the year
- Manager is designated as the approver for the current ApprovalStep

---

## Postconditions (APPROVED)

- LeaveRequest status = APPROVED
- LeaveReservation status = ACTIVE (will convert to USE movement on leave start date)
- LeaveMovement (type = RESERVE) remains immutable in the ledger
- Employee notified of approval

## Postconditions (REJECTED)

- LeaveRequest status = REJECTED
- LeaveReservation status = RELEASED
- LeaveMovement (type = RELEASE) appended — balance restored
- LeaveInstant.reserved decremented, available restored
- Employee notified with rejection reason

## Postconditions (RETURNED FOR MODIFICATION)

- LeaveRequest status = SUBMITTED (reset)
- LeaveReservation remains ACTIVE; no balance change
- Employee notified to revise and resubmit

---

## Happy Path: Submit → Approve

```mermaid
sequenceDiagram
    actor Employee
    participant UI as xTalent UI
    participant ABS as ta.absence Service
    participant SHD as ta.shared Service
    participant DB as Leave Ledger
    actor Manager

    %% === PHASE 1: EMPLOYEE SUBMITS ===
    Employee->>UI: Select leave type, start date, end date, reason
    UI->>ABS: SubmitLeaveRequest(employee_id, leave_type_id, start_date, end_date)

    ABS->>SHD: GetHolidayCalendar(country_code, year)
    SHD-->>ABS: HolidayCalendar (public holidays list)

    ABS->>ABS: Calculate working_days (exclude weekends + holidays)
    Note over ABS: BR-ABS-003: Working days = requested calendar<br/>days minus weekends and public holidays

    ABS->>DB: GetLeaveInstant(employee_id, leave_type_id)
    DB-->>ABS: LeaveInstant { available, earned, used, reserved }

    ABS->>ABS: Validate available >= requested_days (BR-ABS-001)

    ABS->>DB: GetLeaveMovements(employee_id, leave_type_id, type=EARN, with_expiry)
    DB-->>ABS: Movements ordered by expiry_date ASC (FEFO)

    ABS->>DB: CreateLeaveReservation (FEFO-ordered lines) [BR-ABS-004]
    DB-->>ABS: LeaveReservation { reservation_id, reserved_days }

    ABS->>DB: AppendLeaveMovement(type=RESERVE, amount=-requested_days)
    DB-->>ABS: LeaveMovement { movement_id }

    ABS->>DB: CreateLeaveRequest(status=SUBMITTED, leave_reservation_id, cancellation_deadline_computed)
    Note over ABS: H-P0-001: cancellation_deadline = start_date<br/>minus cancellation_deadline_days (business days)
    DB-->>ABS: LeaveRequest { leave_request_id }

    ABS->>SHD: RouteApproval(leave_request_id, employee_id)
    SHD-->>ABS: ApprovalChain assigned

    ABS->>SHD: SendNotification(event=LeaveRequestSubmitted, recipient=manager_id)
    SHD-->>Employee: Confirmation: "Request submitted, pending approval"

    %% === PHASE 2: MANAGER REVIEWS & APPROVES ===
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
        Note over ABS,DB: BR-ABS-005: Reservation remains ACTIVE until leave start date,<br/>then converts to USE movement automatically.
        ABS-->>UI: LeaveRequest status = APPROVED
    else Multi-step chain - more approvers needed
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

## Alternative Path A: Insufficient Balance

```mermaid
sequenceDiagram
    actor Employee
    participant UI as xTalent UI
    participant ABS as ta.absence Service

    Employee->>UI: Submit leave request
    UI->>ABS: SubmitLeaveRequest(employee_id, leave_type_id, start_date, end_date)
    ABS->>ABS: Validate available >= requested_days
    ABS-->>UI: Error: InsufficientBalance { available, requested }

    alt LeaveType.allow_advance_leave = true
        UI->>Employee: Prompt: "Balance insufficient. Submit as advance leave request?"
        Employee->>UI: Confirm advance leave
        UI->>ABS: SubmitLeaveRequest(advance_leave=true)
        ABS->>ABS: Allow negative balance, flag request as ADVANCE_LEAVE
        ABS-->>UI: Reservation created with advance_leave=true
        Note over ABS,UI: Flow continues to Phase 2 (Manager Review)
    else allow_advance_leave = false
        UI->>Employee: Error: "Insufficient balance. Available: {X} days. Requested: {Y} days."
        Note over Employee: Employee may adjust dates or choose a different leave type
    end
```

---

## Alternative Path B: Manager Rejects

```mermaid
sequenceDiagram
    actor Manager
    participant UI as xTalent UI
    participant ABS as ta.absence Service
    participant DB as Leave Ledger
    participant SHD as ta.shared Service
    actor Employee

    Note over Manager,Employee: Precondition: LeaveRequest status = SUBMITTED,<br/>LeaveReservation is ACTIVE (balance held from Phase 1)

    Manager->>UI: Open request detail, click "Reject"
    UI->>Manager: Prompt: Enter rejection reason (required)
    Manager->>UI: Enter rejection_reason, confirm

    UI->>ABS: RejectLeaveRequest(leave_request_id, approver_id, rejection_reason)

    ABS->>DB: UpdateLeaveRequest(status=REJECTED, rejected_by, rejected_at, rejection_reason)

    ABS->>DB: UpdateLeaveReservation(status=RELEASED, released_at)
    ABS->>DB: AppendLeaveMovement(type=RELEASE, amount=+reserved_days)
    Note over ABS,DB: ADR-TA-001: Immutable ledger — RELEASE movement appended.<br/>Original RESERVE movement is never deleted or modified.

    ABS->>ABS: Recompute LeaveInstant (available = earned - used - reserved)

    ABS->>SHD: SendNotification(event=LeaveRequestRejected, recipient=employee_id, rejection_reason)
    SHD-->>Employee: Notification: "Your leave request was rejected. Reason: {reason}"
    UI-->>Manager: Confirmation: "Request rejected"
```

---

## Alternative Path C: Manager Returns for Modification

```mermaid
sequenceDiagram
    actor Manager
    participant UI as xTalent UI
    participant ABS as ta.absence Service
    participant DB as Leave Ledger
    participant SHD as ta.shared Service
    actor Employee

    Note over Manager,Employee: Precondition: LeaveRequest status = SUBMITTED,<br/>LeaveReservation is ACTIVE (balance held from Phase 1)

    Manager->>UI: Open request, click "Return for Modification"
    UI->>Manager: Prompt: Enter return comment (required)
    Manager->>UI: Enter comment, confirm

    UI->>ABS: ReturnLeaveRequest(leave_request_id, approver_id, return_comment)

    ABS->>DB: UpdateLeaveRequest(status=SUBMITTED, return_comment)
    Note over ABS,DB: Reservation remains ACTIVE.<br/>No balance change. Request re-enters employee's queue.

    ABS->>SHD: SendNotification(event=LeaveRequestReturnedForModification, recipient=employee_id)
    SHD-->>Employee: Notification: "Your leave request was returned. Comment: {comment}"
    UI-->>Manager: Confirmation: "Request returned to employee"

    Note over Employee: Employee may edit dates/reason and resubmit.<br/>This re-triggers Phase 1 (UC-ABS-001) with updated data.
```

---

## Exception Path: Holiday / Weekend Overlap

```mermaid
sequenceDiagram
    actor Employee
    participant UI as xTalent UI
    participant ABS as ta.absence Service
    participant SHD as ta.shared Service

    Employee->>UI: Submit leave request (dates include public holiday)
    UI->>ABS: SubmitLeaveRequest(start_date=2026-04-28, end_date=2026-05-02)

    ABS->>SHD: GetHolidayCalendar(country_code=VN, year=2026)
    SHD-->>ABS: Calendar includes 2026-04-30 (Reunification Day) and 2026-05-01 (Labour Day)

    ABS->>ABS: Calculate working_days = 5 - 2 holidays = 3 working days
    Note over ABS: BR-ABS-003: System auto-excludes holidays and weekends.<br/>Employee is informed of the adjusted count.

    ABS-->>UI: Preview: "Your request covers 3 working days (2 holidays auto-excluded)"
    UI->>Employee: Confirm adjusted request (3 days, not 5)?

    Employee->>UI: Confirm
    UI->>ABS: SubmitLeaveRequest(requested_days=3, confirmed=true)
    ABS->>ABS: Continue with happy path (balance check → reservation → notification)
```

---

## Business Rules

| Rule ID | Description |
|---------|-------------|
| BR-ABS-001 | Balance check: available >= requested_days. Block submission if insufficient, unless allow_advance_leave = true on the LeaveType |
| BR-ABS-002 | Multi-step approval: if ApprovalChain has more than one step, request transitions to UNDER_REVIEW after first approval; APPROVED status requires all steps satisfied |
| BR-ABS-003 | Working day calculation: exclude Saturdays, Sundays, and public holidays from the HolidayCalendar |
| BR-ABS-004 | FEFO reservation: consume leave balance in First-Expired-First-Out order by expiry_date of source LeaveMovements |
| BR-ABS-005 | Approval triggers reservation confirmation: when all approval steps are complete, LeaveReservation remains ACTIVE and converts to a USE LeaveMovement on the leave start date |
| BR-ABS-010 | Rejection requires a mandatory rejection_reason text; empty reason must be blocked by the UI and API |
| ADR-TA-001 | Immutable ledger: RELEASE LeaveMovement is appended on rejection; the original RESERVE movement is never deleted or modified |
| H-P0-001 | Cancellation deadline: computed at submission time as start_date minus cancellation_deadline_days (business days). Stored on LeaveRequest. Enables self-cancel vs. manager-approval path in UC-ABS-003 |

---

## Key Domain Objects Created / Modified

| Object | Action | Key Fields |
|--------|--------|------------|
| LeaveRequest | Created | status=SUBMITTED, leave_reservation_id, cancellation_deadline |
| LeaveRequest | Updated (approve) | status=APPROVED, approved_by, approved_at |
| LeaveRequest | Updated (reject) | status=REJECTED, rejected_by, rejected_at, rejection_reason |
| LeaveRequest | Updated (return) | status=SUBMITTED (reset), return_comment |
| LeaveReservation | Created | status=ACTIVE, FEFO-ordered reservation_lines |
| LeaveReservation | Updated (reject) | status=RELEASED, released_at |
| LeaveMovement | Appended (submit) | type=RESERVE, amount=-requested_days (immutable) |
| LeaveMovement | Appended (reject) | type=RELEASE, amount=+reserved_days (immutable) |
| LeaveInstant | Updated (submit) | reserved += requested_days, available -= requested_days |
| LeaveInstant | Updated (reject) | reserved--, available++ |
| Notification | Created | event=LeaveRequestSubmitted → Approved / Rejected / Returned |

---

## Flow State Transitions Summary

```
[DRAFT] → SUBMITTED (employee submits)
         → UNDER_REVIEW (multi-step: first approver approves, passes to next)
         → APPROVED (final approver approves) ✅ terminal
         → REJECTED (any approver rejects) ✅ terminal
         → SUBMITTED (manager returns for modification → employee resubmits)
```
