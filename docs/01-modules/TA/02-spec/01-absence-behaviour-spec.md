# Absence Management - Behavioural Specification

> Detailed business logic, validation rules, and behavioral requirements for Absence Management sub-module.

---

## Document Information

- **Feature**: Absence Management
- **Module**: Time & Absence (TA)
- **Version**: 1.0
- **Last Updated**: 2025-12-01
- **Author**: xTalent Documentation Team
- **Status**: Draft

---

## Overview

### Purpose
Enable employees to request time off, managers to approve requests, and HR to manage leave policies and balances.

### Scope

**In Scope**:
- ✅ Leave request creation and approval
- ✅ Leave balance tracking with immutable ledger
- ✅ Flexible rule system (8 rule types)
- ✅ Multi-level approval workflows
- ✅ Automatic accrual and carryover
- ✅ Period profile management

**Out of Scope**:
- ❌ Payroll calculation
- ❌ Time tracking (separate sub-module)
- ❌ Benefits administration

---

## Use Cases

### UC-ABS-001: Employee Requests Leave

**Actor**: Employee

**Preconditions**:
- Employee is active
- Leave type is configured and active
- Employee has access to leave management system

**Trigger**: Employee wants to take time off

**Main Flow**:
1. Employee navigates to Leave Management
2. Employee clicks "Request Leave"
3. System displays leave request form with available leave types
4. Employee selects leave type
5. System displays current balance for selected type
6. Employee enters start date and end date
7. System calculates working days (excluding weekends and holidays)
8. Employee optionally enters reason
9. Employee clicks "Submit"
10. System validates request (see BR-ABS-001 to BR-ABS-010)
11. System creates LeaveReservation (holds balance)
12. System updates LeaveBalance (pending +, available -)
13. System creates LeaveRequest with status PENDING
14. System sends notification to manager
15. Employee sees confirmation with request ID

**Postconditions**:
- LeaveRequest created with status PENDING
- LeaveReservation created
- LeaveBalance updated
- Manager notified

**Business Rules**:
- BR-ABS-001: Sufficient Balance Required
- BR-ABS-002: No Overlapping Requests
- BR-ABS-003: Advance Notice Required
- BR-ABS-004: No Blackout Period Violation
- BR-ABS-005: Eligibility Check
- BR-ABS-006: Max Consecutive Days Limit

**Alternative Flows**:

**AF-001: Insufficient Balance**
- At step 10, if available balance < requested days
- System shows error: "Insufficient balance. Available: X days, Requested: Y days"
- Request not created

**AF-002: Overlapping Dates**
- At step 10, if dates overlap with existing request
- System shows error: "Date range overlaps with existing request #ID"
- Request not created

**AF-003: Half-Day Request**
- At step 6, employee selects "Half Day" option
- System shows period selection (Morning/Afternoon)
- Employee selects period
- System calculates as 0.5 days

---

### UC-ABS-002: Manager Approves Leave Request

**Actor**: Manager

**Preconditions**:
- Leave request exists with status PENDING
- Manager has approval permission for requester
- Manager is not the requester (cannot approve own request)

**Trigger**: Manager receives notification of pending request

**Main Flow**:
1. Manager opens notification or navigates to Approvals
2. System displays list of pending requests for manager's team
3. Manager selects a request to review
4. System displays request details:
   - Employee name and position
   - Leave type and dates
   - Total days requested
   - Current balance
   - Reason
   - Team calendar (showing other absences)
5. Manager reviews information
6. Manager clicks "Approve"
7. Manager optionally enters comments
8. Manager confirms approval
9. System validates approval permission
10. System creates LeaveMovement (type: USAGE, amount: -days)
11. System updates LeaveBalance (used +, pending -)
12. System releases LeaveReservation
13. System updates LeaveRequest status to APPROVED
14. System creates calendar entries
15. System sends notification to employee
16. Manager sees confirmation

**Postconditions**:
- LeaveRequest status = APPROVED
- LeaveMovement created
- LeaveBalance updated
- LeaveReservation released
- Employee notified
- Calendar entries created

**Business Rules**:
- BR-ABS-011: Manager Cannot Approve Own Request
- BR-ABS-012: Manager Can Only Approve Team Members
- BR-ABS-013: Multi-Level Approval for Long Leave

**Alternative Flow: Manager Rejects**
1-8. Same as main flow
9. Manager clicks "Reject"
10. Manager enters rejection reason (required)
11. Manager confirms rejection
12. System updates LeaveBalance (pending -, available +)
13. System releases LeaveReservation
14. System updates LeaveRequest status to REJECTED
15. System sends notification to employee with reason

---

### UC-ABS-003: System Allocates Annual Leave

**Actor**: System (scheduled job)

**Preconditions**:
- Leave year start date reached
- Employees are active
- Leave types configured with allocation rules

**Trigger**: Leave year start date (e.g., January 1st, 00:00)

**Main Flow**:
1. System identifies all active employees
2. For each employee:
   a. System finds applicable leave types
   b. System retrieves AccrualRule for each leave type
   c. System calculates entitlement based on:
      - Tenure (years of service)
      - Employment type (full-time, part-time)
      - ProrationRule (if mid-year start)
   d. System creates LeaveMovement (type: ALLOCATION)
   e. System updates LeaveBalance (totalAllocated +)
   f. System applies RoundingRule if needed
3. System sends notification to employees
4. System generates allocation report for HR

**Postconditions**:
- LeaveMovement created for each employee/leave type
- LeaveBalance updated
- Employees notified
- Audit log created

**Business Rules**:
- BR-ABS-020: Tenure-Based Allocation
- BR-ABS-021: Proration for New Hires
- BR-ABS-022: Part-Time Proration

---

### UC-ABS-004: System Processes Carryover

**Actor**: System (scheduled job)

**Preconditions**:
- Leave year end date reached
- Employees have unused leave balance
- CarryoverRule configured for leave types

**Trigger**: Leave year end date (e.g., December 31st, 23:59)

**Main Flow**:
1. System identifies all active employees
2. For each employee:
   a. System retrieves current LeaveBalance
   b. System retrieves CarryoverRule for leave type
   c. System calculates unused balance
   d. Based on CarryoverRule type:
      - UNLIMITED: Carry all unused
      - LIMITED: Carry min(unused, maxCarryover)
      - NONE: Expire all unused
      - PAYOUT: Calculate payout amount
   e. If expiring:
      - System creates LeaveMovement (type: EXPIRY, amount: -expired)
   f. If carrying over:
      - System creates LeaveMovement (type: CARRYOVER, amount: +carried)
   g. If payout:
      - System creates LeaveMovement (type: PAYOUT)
      - System sends data to Payroll
   h. System updates LeaveBalance for new year
3. System sends summary notification to employees
4. System generates carryover report for HR

**Business Rules**:
- BR-ABS-030: Carryover Limits
- BR-ABS-031: Carryover Expiry Date
- BR-ABS-032: Payout Calculation

---

## Business Rules

### BR-ABS-001: Sufficient Balance Required

**Category**: Validation  
**Description**: Employee must have sufficient available balance  
**Applies To**: LeaveRequest creation  
**Condition**: When creating leave request  
**Action**: Check `available >= requested days`, reject if insufficient  
**Priority**: High  
**Error**: "Insufficient balance. Available: {X} days, Requested: {Y} days"

---

### BR-ABS-002: No Overlapping Requests

**Category**: Validation  
**Description**: Cannot have overlapping approved or pending requests  
**Applies To**: LeaveRequest creation and approval  
**Condition**: When creating or approving request  
**Action**: Check all APPROVED and PENDING requests for date overlap  
**Priority**: High  
**Error**: "Date range overlaps with existing request #{id} ({dates})"

**Logic**:
```
function hasOverlap(newRequest, existingRequests):
  for each request in existingRequests:
    if request.status in [APPROVED, PENDING]:
      if newRequest.startDate <= request.endDate AND
         newRequest.endDate >= request.startDate:
        return true
  return false
```

---

### BR-ABS-003: Advance Notice Required

**Category**: Validation  
**Description**: Leave must be requested X days in advance  
**Applies To**: LeaveRequest creation  
**Condition**: ValidationRule with type ADVANCE_NOTICE exists  
**Action**: Check `today + advanceNoticeDays <= startDate`  
**Priority**: Medium  
**Error**: "Leave must be requested at least {X} days in advance"

---

### BR-ABS-010: Working Days Calculation

**Category**: Calculation  
**Description**: Calculate working days excluding weekends and holidays  
**Applies To**: LeaveRequest  
**Formula**:
```
workingDays = 0
currentDate = startDate
while currentDate <= endDate:
  if isWorkingDay(currentDate, schedule) AND
     not isHoliday(currentDate, holidays):
    workingDays += 1
  currentDate += 1 day
return workingDays
```

---

### BR-ABS-020: Tenure-Based Allocation

**Category**: Calculation  
**Description**: Leave allocation varies by years of service  
**Applies To**: Annual leave allocation  
**Logic**:
```
if tenure < 5 years: allocation = 15 days
else if tenure < 10 years: allocation = 20 days
else: allocation = 25 days
```

---

## Validation Rules

### Field-Level Validations

#### startDate

| Rule | Description | Error Message |
|------|-------------|---------------|
| Required | Must be provided | "Start date is required" |
| Format | Must be YYYY-MM-DD | "Invalid date format" |
| Range | Must be >= today (new requests) | "Start date cannot be in the past" |
| Range | Must be <= today + 365 days | "Start date cannot be more than 1 year in future" |

#### endDate

| Rule | Description | Error Message |
|------|-------------|---------------|
| Required | Must be provided | "End date is required" |
| Format | Must be YYYY-MM-DD | "Invalid date format" |
| Range | Must be >= startDate | "End date must be on or after start date" |

---

## State Transitions

### LeaveRequest State Machine

| From State | Event | To State | Conditions | Actions |
|------------|-------|----------|------------|---------|
| - | create | DRAFT | - | Create entity |
| DRAFT | submit | PENDING | All validations pass | Create reservation, Update balance, Notify manager |
| PENDING | approve | APPROVED | User has permission | Create movement, Update balance, Release reservation |
| PENDING | reject | REJECTED | User has permission | Restore balance, Release reservation |
| PENDING | withdraw | WITHDRAWN | Requester action | Restore balance, Release reservation |
| APPROVED | cancel | CANCELLED | HR only, exceptional | Reverse movement, Restore balance |

---

## Error Codes

| Code | Message | HTTP Status |
|------|---------|-------------|
| TA_ABS_001 | "Insufficient leave balance" | 400 |
| TA_ABS_002 | "Overlapping leave request" | 409 |
| TA_ABS_003 | "Advance notice requirement not met" | 400 |
| TA_ABS_004 | "Leave type not found" | 404 |
| TA_ABS_005 | "Employee not eligible for this leave type" | 403 |
| TA_ABS_006 | "Cannot approve own request" | 403 |
| TA_ABS_007 | "Blackout period violation" | 400 |
| TA_ABS_008 | "Exceeds maximum consecutive days" | 400 |

---

## Related Documents

- [Behaviour Overview](./00-TA-behaviour-overview.md)
- [Concept Overview](../01-concept/01-concept-overview.md)
- [Absence Ontology](../00-ontology/absence-ontology.yaml)
- [Absence Glossary](../00-ontology/absence-glossary.md)

---

**Approval**

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Business Analyst | | | |
| Tech Lead | | | |
| Product Owner | | | |
