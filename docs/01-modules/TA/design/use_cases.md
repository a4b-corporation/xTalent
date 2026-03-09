# Absence Module Use Cases

## Overview

This document describes the primary use cases supported by the Absence Module, organized by actor and business outcome.

---

## Actor Summary

| Actor | Role | Primary Goals |
|-------|------|---------------|
| **HR Admin** | System administrator | Configure leave policies, manage periods, run batch jobs |
| **Employee** | Leave requester | Request time off, view balances, track approvals |
| **Manager** | Leave approver | Review and approve team leave requests |
| **Payroll Specialist** | Payroll processor | Export leave data for payroll processing |
| **System Scheduler** | Automated job runner | Execute scheduled events (accrual, carry, expiry) |

---

## Use Case Catalog

### UC-001: Configure Leave Type

**Actor:** HR Admin

**Goal:** Define a new type of leave (e.g., Annual Leave, Sick Leave)

**Preconditions:**
- None

**Main Flow:**
1. HR Admin navigates to Leave Type configuration
2. HR Admin creates new Leave Type with:
   - Code (unique identifier)
   - Name (display name)
   - Unit of measure (DAY/HOUR)
   - is_paid flag
   - is_quota_based flag
   - holiday_handling policy
   - overlap_policy
3. HR Admin saves and publishes the Leave Type

**Postconditions:**
- Leave Type is available for use in Leave Classes

**Business Rules:**
- Code must be unique among active Leave Types
- Cannot deactivate if there are active Leave Classes or Instants

---

### UC-002: Configure Leave Class

**Actor:** HR Admin

**Goal:** Create an operational variant of a Leave Type for a specific country/business unit

**Preconditions:**
- Leave Type exists
- Holiday Calendar exists (optional)

**Main Flow:**
1. HR Admin navigates to Leave Class configuration
2. HR Admin selects parent Leave Type
3. HR Admin configures:
   - mode_code (ACCOUNT or LIMIT)
   - period_profile (calendar year, rolling year, fiscal year)
   - posting_map (event → qty formula)
   - eligibility_json (auto-creation criteria)
   - rules_json (accrual, carry, limit rules)
4. HR Admin saves and activates the Leave Class

**Postconditions:**
- Leave Class is active and will auto-create LeaveInstants for eligible employees

**Business Rules:**
- Must have valid period_profile for ACCOUNT/LIMIT modes
- Cannot deactivate if there are active LeaveInstants

---

### UC-003: Define Leave Policy

**Actor:** HR Admin

**Goal:** Create reusable policy for accrual, carry-forward, or limits

**Preconditions:**
- Leave Type exists

**Main Flow:**
1. HR Admin navigates to Leave Policy library
2. HR Admin creates new policy with:
   - Policy code and name
   - Policy kind (accrual/carry/limit/overdraft)
   - Rules in JSON format
3. HR Admin associates policy with Leave Type or Leave Class
4. HR Admin publishes the policy

**Postconditions:**
- Policy is available for use in Leave Classes and Event Definitions

**Example Policies:**
```json
// Accrual Policy
{
  "freq": "MONTH",
  "hours": 1.75,
  "basis": "WORKDAYS",
  "prorated": true
}

// Carry Policy
{
  "maxCarry": 10,
  "expireMonths": 3,
  "minBalance": 5
}

// Limit Policy
{
  "yearly": 96,
  "monthlyCap": 8,
  "perCase": 8
}
```

---

### UC-004: Manage Leave Period

**Actor:** HR Admin

**Goal:** Open, close, and lock leave periods

**Preconditions:**
- Leave Period structure defined (year/month)

**Main Flow:**
1. HR Admin views period calendar
2. HR Admin initiates period close:
   - System validates no pending requests
   - System runs pending events (accrual, carry)
   - System sets period status to CLOSED
3. HR Admin locks period:
   - System finalizes balances
   - System sets period status to LOCKED

**Postconditions:**
- Period is locked and no further modifications allowed

**Business Rules:**
- Cannot close if there are pending approved requests
- Cannot reopen if period is LOCKED

---

### UC-005: Employee Requests Leave

**Actor:** Employee

**Goal:** Submit a leave request for approval

**Preconditions:**
- Employee has sufficient available balance
- Leave Class is configured

**Main Flow:**
1. Employee navigates to Leave Request page
2. Employee selects Leave Type/Class
3. Employee enters:
   - Start date/time
   - End date/time
   - Reason (optional)
   - Attachments (if required)
4. System validates:
   - Available balance
   - Overlap with existing requests
   - Team staffing limits
   - Minimum notice period
   - Blackout dates
5. Employee submits request
6. System creates Leave Reservation (hold quota)
7. System routes request to manager for approval

**Postconditions:**
- Request status: SUBMITTED
- Quota is temporarily held (available_qty reduced)

**Alternative Flows:**
- **A1: Insufficient Balance** → System rejects submission with error
- **A2: Overlap Detected** → System shows conflict and blocks submission
- **A3: Team Limit Exceeded** → System escalates or rejects based on policy

---

### UC-006: Manager Approves Leave Request

**Actor:** Manager

**Goal:** Review and approve/reject team member's leave request

**Preconditions:**
- Leave request is in SUBMITTED or PENDING status

**Main Flow:**
1. Manager receives notification of pending approval
2. Manager views request details:
   - Employee name
   - Leave dates and duration
   - Available balance
   - Team calendar (other approved leaves)
3. Manager approves request:
   - System updates request status to APPROVED
   - System confirms reservation (hold continues)
   - System notifies employee

**Postconditions:**
- Request status: APPROVED
- Quota remains held until start date

**Alternative Flows:**
- **A1: Manager Rejects** → Status = REJECTED, reservation released
- **A2: Escalation Required** → Request routed to next approval level

---

### UC-007: Employee Cancels Leave Request

**Actor:** Employee

**Goal:** Cancel a submitted or approved leave request

**Preconditions:**
- Request status is SUBMITTED, PENDING, or APPROVED
- Start date has not yet passed

**Main Flow:**
1. Employee navigates to My Leave Requests
2. Employee selects request to cancel
3. Employee confirms cancellation
4. System validates cancellation is allowed (before start date)
5. System releases reservation (unhold quota)
6. System updates request status to CANCELLED
7. System notifies manager

**Postconditions:**
- Request status: CANCELLED
- Quota is restored (available_qty increased)

**Alternative Flows:**
- **A1: After Start Date** → System blocks cancellation, suggests adjustment request

---

### UC-008: Run Monthly Accrual

**Actor:** System Scheduler (automated)

**Goal:** Accrue leave balance for eligible employees

**Preconditions:**
- Leave Classes with accrual rules exist
- Period is OPEN

**Main Flow:**
1. System triggers ACCRUAL event (scheduled: 1st of month)
2. System creates LeaveEventRun record
3. For each eligible LeaveInstant:
   - System calculates accrual amount per policy
   - System creates LeaveMovement (+qty)
   - System creates LeaveInstantDetail (new lot with expiry)
   - System updates LeaveInstant (current_qty, available_qty)
4. System creates EOD snapshot (LeaveBalanceHistory)
5. System marks LeaveEventRun as DONE

**Postconditions:**
- Employee balances are updated
- New grant lots are created with expiry dates

**Business Rules:**
- Idempotent: re-run does not create duplicates
- Proration applied for mid-period joins

---

### UC-009: Process Leave Usage (Start Posting)

**Actor:** System Scheduler (automated)

**Goal:** Post actual leave usage when employee starts leave

**Preconditions:**
- Leave request is APPROVED
- Start date has arrived

**Main Flow:**
1. System triggers START_POST event (daily)
2. For each approved request with start_date = today:
   - System releases reservation (hold_qty -= used_qty)
   - System creates LeaveMovement (−qty, USED event)
   - System consumes lots via FEFO (First Expire First Out)
   - System updates LeaveInstant (current_qty -= used_qty)
3. System posts to timesheet (if integrated)

**Postconditions:**
- Leave is marked as taken
- Balance is reduced
- Lots are consumed per FEFO

---

### UC-010: Run Year-End Carry Forward

**Actor:** System Scheduler (automated)

**Goal:** Carry forward unused leave balance to next year

**Preconditions:**
- Period end reached
- Carry policy allows carry-forward

**Main Flow:**
1. System triggers CARRY event (scheduled: Jan 1)
2. For each eligible LeaveInstant:
   - System calculates remaining balance
   - System applies carry cap (maxCarry)
   - System creates LeaveMovement (+qty, CARRY event)
   - System creates new LeaveInstantDetail (carry lot with new expiry)
3. System marks prior period lots as expired (silent expiry)
4. System closes prior period

**Postconditions:**
- Unused balance is carried forward
- New lot created with expiry in next period

**Alternative Flows:**
- **A1: No Carry Allowed** → System resets balance (no movement)

---

### UC-011: View Leave Balance

**Actor:** Employee

**Goal:** Check current leave balance and transaction history

**Preconditions:**
- Employee has at least one LeaveInstant

**Main Flow:**
1. Employee navigates to My Leave Balance
2. System displays:
   - Leave Types and available balances
   - Pending requests
   - Upcoming approved leaves
   - Movement history (transactions)
3. Employee clicks into a Leave Type for details:
   - Grant lots (with expiry dates)
   - Monthly accrual history
   - Usage history

**Postconditions:**
- None (read-only operation)

---

### UC-012: Team Leave Calendar

**Actor:** Manager

**Goal:** View team leave calendar to manage staffing

**Preconditions:**
- Manager has direct reports

**Main Flow:**
1. Manager navigates to Team Leave Calendar
2. System displays:
   - Team members on leave (today)
   - Upcoming approved leaves
   - Pending requests
   - Staffing level indicator (vs. team limit)
3. Manager filters by date range, leave type

**Postconditions:**
- None (read-only operation)

---

### UC-013: Export Leave Data for Payroll

**Actor:** Payroll Specialist

**Goal:** Export unpaid leave and other payroll-relevant data

**Preconditions:**
- Payroll period is defined
- Leave data is posted

**Main Flow:**
1. Payroll Specialist navigates to Payroll Export
2. Payroll Specialist selects:
   - Pay period
   - Export format (CSV, XML, API)
3. System exports:
   - Unpaid leave days/hours
   - Leave encashment (if applicable)
   - Leave type breakdown
4. System logs export for audit

**Postconditions:**
- Data is exported to payroll system

---

## Use Case Summary Matrix

| Use Case | Primary Actor | Frequency | Automation Level |
|----------|---------------|-----------|------------------|
| UC-001: Configure Leave Type | HR Admin | Low | Manual |
| UC-002: Configure Leave Class | HR Admin | Low | Manual |
| UC-003: Define Leave Policy | HR Admin | Low | Manual |
| UC-004: Manage Leave Period | HR Admin | Medium | Semi-automated |
| UC-005: Employee Requests Leave | Employee | High | Manual |
| UC-006: Manager Approves Leave | Manager | High | Manual |
| UC-007: Employee Cancels Leave | Employee | Medium | Manual |
| UC-008: Run Monthly Accrual | System | Monthly | Fully automated |
| UC-009: Process Leave Usage | System | Daily | Fully automated |
| UC-010: Run Year-End Carry | System | Yearly | Fully automated |
| UC-011: View Leave Balance | Employee | High | Read-only |
| UC-012: Team Leave Calendar | Manager | High | Read-only |
| UC-013: Export for Payroll | Payroll Specialist | Monthly | Semi-automated |

---

*This document is part of the ODDS v1 documentation standard for the xTalent Absence Module.*
