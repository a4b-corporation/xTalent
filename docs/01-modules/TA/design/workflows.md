# Absence Module Workflows

## Overview

This document describes the key workflows in the Absence Module, including flow diagrams, state transitions, and integration points.

---

## Workflow 1: Leave Configuration Flow

### Purpose
Define and activate leave configuration (Type → Class → Policy)

### Actors
- HR Admin
- System

### Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    LEAVE CONFIGURATION FLOW                      │
└─────────────────────────────────────────────────────────────────┘

  HR Admin                          System
     │                                │
     │──[1] Create LeaveType ───────►│ Validate uniqueness
     │                                │ Save Type
     │                                │
     │◄──[2] Type Created ───────────│
     │                                │
     │──[3] Create LeaveClass ──────►│ Validate Type exists
     │                                │ Validate period_profile
     │                                │ Save Class
     │                                │
     │◄──[4] Class Activated ────────│ Auto-create Instants
     │                                │ (for eligible employees)
     │                                │
     │──[5] Define LeavePolicy ─────►│ Validate rules_json
     │                                │ Save Policy
     │                                │
     │◄──[6] Policy Published ───────│ Link to Class
     │                                │
```

### States

| Entity | States | Transitions |
|--------|--------|-------------|
| LeaveType | DRAFT → ACTIVE → INACTIVE | Publish, Deactivate |
| LeaveClass | DRAFT → ACTIVE → INACTIVE | Activate, Deactivate |
| LeavePolicy | DRAFT → ACTIVE → INACTIVE | Publish, Deprecate |

### Business Rules

- LeaveType must exist before creating LeaveClass
- LeaveClass cannot activate without valid period_profile
- Policy must have valid rules_json

---

## Workflow 2: Employee Leave Request Flow

### Purpose
End-to-end flow from employee request to manager approval

### Actors
- Employee
- Manager
- System

### Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                   LEAVE REQUEST FLOW                             │
└─────────────────────────────────────────────────────────────────┘

  Employee         System            Manager
     │                │                  │
     │──[1] Submit   │                  │
     │   Request     │                  │
     │               │                  │
     │               │──[2] Validate ──►│
     │               │   - Balance      │
     │               │   - Overlap      │
     │               │   - Team Limit   │
     │               │                  │
     │               │──[3] Create ─────│
     │               │   Reservation    │
     │               │   (hold quota)   │
     │               │                  │
     │               │──[4] Notify ────►│ Pending Approval
     │               │                  │
     │               │                  │◄─[5] Review Request
     │               │                  │    - Check calendar
     │               │                  │    - Check staffing
     │               │                  │
     │               │                  │──[6a] APPROVE ────┐
     │               │                  │                   │
     │               │                  │──[6b] REJECT ─────┤
     │               │                  │                   │
     │◄──[7] Notified│◄─────────────────┘
     │   Approved/   │
     │   Rejected    │
     │               │
     │──[8] Cancel? ─│ (before start date)
     │               │
     │               │──[9] Release ─────│
     │                   Reservation     │
     │                                   │
```

### Request States

```
DRAFT ──submit──> SUBMITTED ──escalate──> PENDING
                       │                       │
                       │                       │ approve
                       │                       │
                       │                       v
                       │                  APPROVED
                       │                       │
                       │                       │ cancel/start
                       │                       │
                       v                       v
                    REJECTED              CANCELLED/USED
                       │
                       │
                       v
                   WITHDRAWN
```

### Validation Rules

| Check | Description | Error |
|-------|-------------|-------|
| Balance | available_qty >= requested | "Insufficient balance" |
| Overlap | No overlapping approved requests | "Cannot overlap existing leave" |
| Team Limit | Concurrent leaves within limit | "Team staffing limit exceeded" |
| Min Notice | submitted before deadline | "Insufficient notice period" |
| Blackout | Not on blackout dates | "Blackout date restriction" |

---

## Workflow 3: Monthly Accrual Flow

### Purpose
Automated monthly accrual of leave balance

### Actors
- System Scheduler

### Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     MONTHLY ACCRUAL FLOW                         │
└─────────────────────────────────────────────────────────────────┘

  Scheduler        Event Engine        Ledger          Account
     │                 │                  │               │
     │──[1] Trigger ──►│                  │               │
     │   ACCRUAL       │                  │               │
     │   (1st of month)│                  │               │
     │                 │                  │               │
     │                 │──[2] Create ────►│               │
     │                 │   EventRun       │               │
     │                 │   (RUNNING)      │               │
     │                 │                  │               │
     │                 │──[3] For each ──►│               │
     │                 │   eligible       │               │
     │                 │   Instant:       │               │
     │                 │                  │               │
     │                 │──[4] Calculate ──│               │
     │                 │   accrual amount │               │
     │                 │   (per policy)   │               │
     │                 │                  │               │
     │                 │──[5] Create ────►│               │
     │                 │   Movement       │               │
     │                 │   (+qty, ACCRUAL)│               │
     │                 │                  │               │
     │                 │──[6] Create ────►│──[7] Update ──►
     │                 │   Detail (lot)   │   current_qty │
     │                 │   with expiry    │   available   │
     │                 │                  │   qty         │
     │                 │                  │               │
     │                 │──[8] Mark ──────►│
     │                     EventRun DONE  │
     │                                    │
     │──[9] EOD ──────►│                  │
     │   Snapshot      │                  │
     │                 │                  │
```

### Accrual Calculation

```
accrual_amount = base_rate × proration_factor

proration_factor =
  - 1.0 (full month employed)
  - days_employed / working_days_in_month (partial month)
  - 0 (if not eligible per policy)
```

### Idempotency

- Idempotency key: `ACCRUAL|{instant_id}|{effective_date}|{seq}`
- Re-run skips already-processed instants
- Stats tracked in EventRun (processed, posted, skipped, failed)

---

## Workflow 4: Period Close & Carry Forward

### Purpose
Close leave period and carry forward unused balance

### Actors
- HR Admin
- System

### Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                  PERIOD CLOSE & CARRY FORWARD                    │
└─────────────────────────────────────────────────────────────────┘

  HR Admin        System Scheduler    Event Engine      Account
     │                  │                 │                │
     │──[1] Initiate   │                 │                │
     │   Period Close ─►│                 │                │
     │                  │                 │                │
     │                  │──[2] Validate ─►│                │
     │                  │   - No pending  │                │
     │                  │     requests    │                │
     │                  │   - All events  │                │
     │                  │     completed   │                │
     │                  │                 │                │
     │                  │──[3] Run ──────►│                │
     │                  │   CARRY event   │                │
     │                  │                 │                │
     │                  │                 │──[4] For each │
     │                  │                 │   Instant:    │
     │                  │                 │               │
     │                  │                 │──[5] Calc    │
     │                  │                 │   remaining   │
     │                  │                 │   balance     │
     │                  │                 │               │
     │                  │                 │──[6] Apply   │
     │                  │                 │   carry cap   │
     │                  │                 │               │
     │                  │                 │──[7] Create  │
     │                  │                 │   Movement    │
     │                  │                 │   (+qty,      │
     │                  │                 │    CARRY)     │
     │                  │                 │               │
     │                  │                 │──[8] Create  │
     │                  │                 │   Detail      │
     │                  │                 │   (new lot)   │
     │                  │                 │               │
     │                  │                 │──[9] Mark    │
     │                  │                 │   old lots    │
     │                  │                 │   EXPIRED     │
     │                  │                 │               │
     │◄─[10] Period ────│                 │               │
     │    CLOSED        │                 │               │
     │                  │                 │               │
     │──[11] Lock ─────►│                 │               │
     │    Period        │                 │               │
     │                  │                 │               │
     │                  │──[12] Set ─────►│               │
     │                  │   LOCKED        │               │
     │                  │                 │               │
```

### Period States

```
OPEN ──close──> CLOSED ──lock──> LOCKED
  │                                  │
  │◄─reopen──────────────────────────│
  │   (only if not LOCKED)           │
```

### Carry Forward Formula

```
carry_amount = MIN(
  remaining_balance,
  maxCarry,
  remaining_balance - minBalance  (if minBalance rule exists)
)

remaining_balance = current_qty - hold_qty
```

---

## Workflow 5: FEFO Lot Consumption

### Purpose
Consume grant lots in First Expire First Out order

### Actors
- System

### Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    FEFO CONSUMPTION FLOW                         │
└─────────────────────────────────────────────────────────────────┘

  When START_POST triggers for approved request:

  Event Engine      LeaveInstant       LeaveInstantDetail
     │                   │                    │
     │──[1] Get ────────►│                    │
     │   Instant         │                    │
     │                   │                    │
     │──[2] Query ──────────────────────────►│
     │   ACTIVE lots     │                    │
     │   ORDER BY        │                    │
     │   expire_date ASC │                    │
     │                   │                    │
     │                   │◄───────────────────│
     │                   │  [lot1: 10 qty,    │
     │                   │   exp 2025-03-31]  │
     │                   │  [lot2: 20 qty,    │
     │                   │   exp 2026-03-31]  │
     │                   │                    │
     │──[3] Consume ─────────────────────────►│
     │   requested_qty   │                    │
     │   (e.g., 15 hrs)  │                    │
     │                   │                    │
     │                   │──[4] Update ──────►│ lot1.used_qty = 10
     │                   │                    │ lot2.used_qty = 5
     │                   │                    │
     │                   │──[5] Create ──────►│ lot1: EXHAUSTED
     │                   │    Movement        │ lot2: PARTIALLY_USED
     │                   │    (−qty, USED)    │
     │                   │                    │
     │                   │──[6] Update ──────►│
     │                        current_qty     │
     │                        hold_qty        │
     │                        available_qty   │
     │                                        │
```

### FEFO Priority

| Priority | Criteria |
|----------|----------|
| 1 | expire_date ASC (earliest first) |
| 2 | eff_date ASC (oldest grant first) |
| 3 | priority ASC (lower number = higher priority) |

### Silent Expiry

- Default: Lots expire silently (no movement)
- Optional: Set `emit_expire_turnover = true` to create EXPIRE movement for reporting

---

## Workflow 6: Team Limit Validation

### Purpose
Validate team staffing limits during leave request

### Actors
- Employee
- System

### Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                 TEAM LIMIT VALIDATION FLOW                       │
└─────────────────────────────────────────────────────────────────┘

  Employee         System            Team Limit Config
     │                │                    │
     │──[1] Submit   │                    │
     │   Request     │                    │
     │   (dates:     │                    │
     │    D1-D5)     │                    │
     │               │                    │
     │               │──[2] Lookup ──────►│ Get limit config
     │               │   TeamLimit        │ (e.g., 20% or 3 ppl)
     │               │                    │
     │               │──[3] Count ────────│
     │               │   concurrent       │
     │               │   leaves           │
     │               │                    │
     │               │◄───────────────────│
     │               │  Approved/Pending: │
     │               │  - EMP001: D1-D3   │
     │               │  - EMP002: D3-D5   │
     │               │                    │
     │               │──[4] Calculate ────│
     │               │   max_allowed      │
     │               │   = FLOOR(team_size × limit_pct)
     │               │   = FLOOR(15 × 0.20) = 3
     │               │                    │
     │               │──[5] Check ────────│
     │               │   overlap days:    │
     │               │   D1: 0 existing   │
     │               │   D2: 0 existing   │
     │               │   D3: 1 existing   │ (EMP001 or EMP002)
     │               │   D4: 1 existing   │
     │               │   D5: 1 existing   │
     │               │                    │
     │               │──[6] Validate ─────│
     │               │   max_concurrent   │
     │               │   (1) < max_allowed│
     │               │   (3) = PASS       │
     │               │                    │
     │◄──[7] OK ─────│                    │
     │   Proceed     │                    │
     │               │                    │
```

### Escalation

| Scenario | Action |
|----------|--------|
| Within limit | Auto-approve (if manager approval not required) |
| Exceeds by 1 | Escalate to Level 1 (Manager) |
| Exceeds by 2+ | Escalate to Level 2 (Senior Manager) |
| Critical role | Escalate to Level 3 (VP/Director) |

---

## Exception Handling

### Common Exceptions

| Exception | Cause | Resolution |
|-----------|-------|------------|
| Insufficient Balance | Request > available_qty | Reduce request or wait for accrual |
| Overlap Detected | Conflicting approved request | Adjust dates |
| Team Limit Exceeded | Too many concurrent leaves | Escalate or reschedule |
| Period Closed | Posting to closed period | Reopen period or adjust date |
| Idempotency Violation | Duplicate event run | System skips duplicate |

### Error Recovery

- **Failed Accrual Run**: Fix data issue, re-run with same idempotency key
- **Partial Movement Post**: Rollback failed movements, retry individually
- **Reservation Stuck**: Admin intervention to release/expire

---

## Integration Workflows

### Payroll Integration

```
Absence Module ──[Export]──> Payroll Module
  - Unpaid leave days         - Deduct from salary
  - Leave encashment          - Add to taxable income
  - Overtime offset           - Adjust overtime pay
```

### Timesheet Integration

```
Absence Module ──[Post]──> Timesheet Module
  - Approved leave           - Mark as "On Leave"
  - Actual dates             - Compare planned vs. actual
  - Hours consumed           - Update attendance
```

---

*This document is part of the ODDS v1 documentation standard for the xTalent Absence Module.*
