# {Feature Name} - Behavioural Specification

> This document defines the detailed business logic, validation rules, and behavioral requirements for implementation.

---

## Document Information

- **Feature**: {Feature Name}
- **Module**: {Module Name}
- **Version**: 1.0
- **Last Updated**: {Date}
- **Author**: {Name}
- **Status**: Draft | Review | Approved

---

## Overview

### Purpose
[What does this feature do?]

### Scope
[What is included and excluded from this specification?]

**In Scope**:
- ✅ {Item 1}
- ✅ {Item 2}

**Out of Scope**:
- ❌ {Item 1}
- ❌ {Item 2}

---

## Use Cases

### UC-001: {Use Case Name}

**Actor**: {Primary actor}

**Preconditions**:
- {Condition 1}
- {Condition 2}

**Trigger**: {What initiates this use case}

**Main Flow**:
1. {Actor} {action}
2. System {response}
3. System validates {what}
4. System {action}
5. {Actor} sees {result}

**Postconditions**:
- {Condition 1}
- {Condition 2}

**Business Rules**:
- BR-001: {Rule description}
- BR-002: {Rule description}

---

### UC-002: {Use Case Name}

[Repeat structure for each use case]

---

## Scenarios

### Scenario 1: {Scenario Name} (Happy Path)

**Given**:
- {Precondition 1}
- {Precondition 2}

**When**:
- {Action 1}
- {Action 2}

**Then**:
- {Expected result 1}
- {Expected result 2}
- {Expected result 3}

**Example**:
```
Given:
  - Employee "John Doe" (ID: E123) has 10 annual leave days available
  - Current date is 2025-01-15
  - John has no pending or approved leave requests

When:
  - John creates a leave request:
    * Leave Type: Annual Leave
    * Start Date: 2025-02-01
    * End Date: 2025-02-05 (5 working days)
    * Reason: "Family vacation"
  - John submits the request

Then:
  - Leave request is created with status PENDING
  - Leave request ID is generated (e.g., LR-2025-00123)
  - John's leave balance is updated:
    * Available: 5 days (10 - 5)
    * Pending: 5 days
    * Used: 0 days
  - Notification sent to John's manager (Jane Smith)
  - John sees confirmation message: "Leave request submitted successfully"
```

---

### Scenario 2: {Scenario Name} (Alternative Flow)

**Given**:
- {Precondition}

**When**:
- {Action}

**Then**:
- {Expected result}

---

### Scenario 3: {Scenario Name} (Edge Case)

**Given**:
- {Precondition}

**When**:
- {Action}

**Then**:
- {Expected result - usually an error or special handling}

**Example**:
```
Scenario: Insufficient Leave Balance

Given:
  - Employee has 3 annual leave days available
  - Employee has no pending requests

When:
  - Employee requests 5 days of annual leave

Then:
  - Request is NOT created
  - System shows error: "Insufficient leave balance. You have 3 days available but requested 5 days."
  - Leave balance remains unchanged
  - No notification sent to manager
```

---

## Business Rules

### BR-001: {Rule Name}

**Category**: {Validation | Calculation | Workflow | Authorization}

**Description**: {Detailed rule description}

**Applies To**: {Entity or process}

**Condition**: {When this rule applies}

**Action**: {What happens when rule is triggered}

**Priority**: {High | Medium | Low}

**Example**:
```
BR-001: No Overlapping Leave Requests

Category: Validation
Description: An employee cannot have overlapping approved or pending leave requests
Applies To: LeaveRequest creation and approval
Condition: When creating or approving a leave request
Action: 
  - Check all existing requests with status APPROVED or PENDING
  - If date ranges overlap, reject the new request
  - Show error: "Date range overlaps with existing leave request #{id}"
Priority: High

Example:
  Existing: 2025-02-10 to 2025-02-15 (APPROVED)
  New Request: 2025-02-12 to 2025-02-17
  Result: REJECTED - Overlaps on Feb 12-15
```

---

### BR-002: {Rule Name}

[Repeat structure for each business rule]

---

## Validation Rules

### Field-Level Validations

#### {Field Name}

| Rule | Description | Error Message |
|------|-------------|---------------|
| Required | Field must not be empty | "{Field} is required" |
| Format | {Format requirement} | "{Field} must be {format}" |
| Range | {Min/Max values} | "{Field} must be between {min} and {max}" |
| Unique | {Uniqueness constraint} | "{Field} already exists" |

**Example**:
```
Field: startDate

| Rule | Description | Error Message |
|------|-------------|---------------|
| Required | Must be provided | "Start date is required" |
| Format | Must be valid date (YYYY-MM-DD) | "Invalid date format" |
| Range | Must be >= today | "Start date cannot be in the past" |
| Range | Must be <= today + 1 year | "Start date cannot be more than 1 year in future" |
```

---

### Cross-Field Validations

#### Validation 1: {Validation Name}

**Fields Involved**: {Field1}, {Field2}

**Rule**: {Description}

**Error Message**: {Message}

**Example**:
```
Validation: End Date After Start Date

Fields: startDate, endDate
Rule: endDate must be >= startDate
Error: "End date must be on or after start date"

Example:
  startDate: 2025-02-01
  endDate: 2025-01-30
  Result: INVALID - "End date must be on or after start date"
```

---

### Entity-Level Validations

#### Validation 1: {Validation Name}

**Description**: {What is being validated}

**Logic**: {Validation logic}

**Error Message**: {Message}

---

## Calculations

### Calculation 1: {Calculation Name}

**Purpose**: {What is being calculated}

**Formula**: 
```
{Mathematical formula or pseudocode}
```

**Inputs**:
- {Input 1}: {Description}
- {Input 2}: {Description}

**Output**: {What is produced}

**Example**:
```
Calculation: Total Leave Days

Purpose: Calculate number of working days in leave request

Formula:
  totalDays = 0
  currentDate = startDate
  while currentDate <= endDate:
    if currentDate is not weekend AND not public holiday:
      totalDays += 1
    currentDate += 1 day
  return totalDays

Inputs:
  - startDate: 2025-02-03 (Monday)
  - endDate: 2025-02-07 (Friday)
  - publicHolidays: []
  - weekends: Saturday, Sunday

Output: 5 days

Breakdown:
  - Feb 3 (Mon): Working day ✓
  - Feb 4 (Tue): Working day ✓
  - Feb 5 (Wed): Working day ✓
  - Feb 6 (Thu): Working day ✓
  - Feb 7 (Fri): Working day ✓
  Total: 5 days
```

---

## State Transitions

### {Entity Name} State Machine

**States**: {List all states}

**Transitions**:

| From State | Event | To State | Conditions | Actions |
|------------|-------|----------|------------|---------|
| DRAFT | submit | PENDING | All validations pass | Create audit log, Send notification |
| PENDING | approve | APPROVED | User has approval permission | Update balance, Send notification |
| PENDING | reject | REJECTED | User has approval permission | Restore balance, Send notification |

**State Descriptions**:

#### State: {STATE_NAME}

**Description**: {What this state means}

**Allowed Actions**:
- {Action 1}: {Who can do it}
- {Action 2}: {Who can do it}

**Exit Conditions**: {What causes transition out of this state}

---

## Permissions and Authorization

### Permission Matrix

| Action | Employee (Self) | Employee (Other) | Manager | HR Admin | System Admin |
|--------|----------------|------------------|---------|----------|--------------|
| Create Leave Request | ✅ | ❌ | ✅ (for team) | ✅ | ✅ |
| View Leave Request | ✅ (own) | ❌ | ✅ (team) | ✅ (all) | ✅ (all) |
| Edit Leave Request | ✅ (DRAFT only) | ❌ | ❌ | ✅ | ✅ |
| Delete Leave Request | ✅ (DRAFT only) | ❌ | ❌ | ✅ | ✅ |
| Approve Leave Request | ❌ | ❌ | ✅ (team) | ✅ | ✅ |
| Reject Leave Request | ❌ | ❌ | ✅ (team) | ✅ | ✅ |

**Special Rules**:
- Managers can only approve for their direct reports
- HR Admin can approve for anyone
- Employees cannot approve their own requests

---

## Error Handling

### Error Scenarios

#### Error 1: {Error Code}

**Code**: `{ERROR_CODE}`

**Message**: "{User-friendly error message}"

**Cause**: {What causes this error}

**HTTP Status**: {400, 404, 409, 500, etc.}

**User Action**: {What user should do}

**System Action**: {What system does}

**Example**:
```
Error: INSUFFICIENT_BALANCE

Code: TA_LEAVE_001
Message: "Insufficient leave balance. You have {available} days available but requested {requested} days."
Cause: Employee requests more leave than available balance
HTTP Status: 400 Bad Request
User Action: Reduce requested days or select different leave type
System Action: Do not create request, return error response

Example Response:
{
  "error": {
    "code": "TA_LEAVE_001",
    "message": "Insufficient leave balance. You have 3 days available but requested 5 days.",
    "details": {
      "available": 3,
      "requested": 5,
      "leaveType": "Annual Leave"
    }
  }
}
```

---

## Integration Points

### Integration 1: {System/Module Name}

**Direction**: {Inbound | Outbound | Bidirectional}

**Trigger**: {What triggers the integration}

**Data Exchanged**:
- {Data item 1}
- {Data item 2}

**Timing**: {Real-time | Batch | Scheduled}

**Error Handling**: {How errors are handled}

---

## Performance Requirements

### Response Time

| Operation | Target | Maximum |
|-----------|--------|---------|
| Create leave request | < 500ms | 1s |
| Approve leave request | < 300ms | 500ms |
| Load leave balance | < 200ms | 500ms |
| Generate report | < 5s | 10s |

### Throughput

| Operation | Target | Peak |
|-----------|--------|------|
| Concurrent users | 100 | 500 |
| Requests per second | 50 | 200 |

---

## Audit Requirements

### What to Audit

| Event | Data to Capture |
|-------|-----------------|
| Leave request created | User, timestamp, all field values |
| Leave request submitted | User, timestamp, status change |
| Leave request approved | Approver, timestamp, comments |
| Leave request rejected | Approver, timestamp, reason |
| Leave balance updated | User, timestamp, old value, new value, reason |

### Audit Log Format

```json
{
  "eventId": "uuid",
  "eventType": "LEAVE_REQUEST_APPROVED",
  "entityType": "LeaveRequest",
  "entityId": "LR-2025-00123",
  "timestamp": "2025-01-15T14:30:00Z",
  "userId": "E456",
  "userName": "Jane Manager",
  "changes": {
    "status": {
      "from": "PENDING",
      "to": "APPROVED"
    }
  },
  "metadata": {
    "comments": "Approved. Have a good vacation!",
    "ipAddress": "192.168.1.100"
  }
}
```

---

## Test Scenarios

### Test Case 1: {Test Name}

**ID**: TC-001

**Priority**: {High | Medium | Low}

**Type**: {Positive | Negative | Edge Case}

**Preconditions**:
- {Condition 1}
- {Condition 2}

**Steps**:
1. {Step 1}
2. {Step 2}
3. {Step 3}

**Expected Result**:
- {Result 1}
- {Result 2}

**Actual Result**: {To be filled during testing}

**Status**: {Pass | Fail | Blocked}

---

## Acceptance Criteria

### Feature is considered complete when:

- [ ] All use cases are implemented
- [ ] All business rules are enforced
- [ ] All validations work correctly
- [ ] All error scenarios are handled
- [ ] All state transitions work as specified
- [ ] Permissions are correctly enforced
- [ ] Audit logging is complete
- [ ] Performance targets are met
- [ ] All test cases pass
- [ ] Documentation is complete

---

## Open Questions

| # | Question | Asked By | Date | Status | Resolution |
|---|----------|----------|------|--------|------------|
| 1 | {Question} | {Name} | {Date} | Open/Resolved | {Answer} |

---

## Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | {Date} | {Name} | Initial version |

---

## Related Documents

- [Concept Overview](../01-concept/01-concept-overview.md)
- [Conceptual Guide](../01-concept/02-conceptual-guide.md)
- [Ontology](../00-ontology/)
- [API Specification](../04-api/)
- [UI Specification](../05-ui/)

---

**Approval**

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Business Analyst | | | |
| Tech Lead | | | |
| Product Owner | | | |
