# Use Case Flow - Assign Employee to Pay Group

> **Use Case**: UC-PG-001 Assign Employee to Pay Group
> **Bounded Context**: Payroll Assignment (BC-004)
> **Module**: Payroll (PR)
> **Priority**: P0
> **Story Points**: 5

---

## Overview

This flow documents the process of assigning an employee to a pay group, linking them to a pay profile and pay calendar.

---

## Actors

| Actor | Role |
|-------|------|
| Payroll Admin | Primary actor - initiates assignment |
| Core HR (CO) | External - provides employee data |
| ValidationRule | Secondary - validates assignment |
| PayGroup Aggregate | Manages assignments |
| AuditLog | Secondary - logs assignment |

---

## Preconditions

1. Payroll Admin is logged in with assignment permission
2. Employee (Worker) exists in Core HR (CO) module
3. PayGroup exists with active PayProfile and PayCalendar
4. Employee is not currently assigned to another PayGroup

---

## Postconditions

1. PayGroupAssignment created linking employee to PayGroup
2. Employee inherits PayProfile elements and PayCalendar periods
3. Assignment history recorded
4. Audit entry created
5. Employee available for payroll processing

---

## Happy Path

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant PG as PayGroup Aggregate
    participant CO as Core HR (CO)
    participant VAL as ValidationRule
    participant DB as Database
    participant AUD as AuditLog
    
    PA->>UI: Navigate to Pay Group Assignment
    UI->>API: GET /pay-groups
    API->>DB: Query active PayGroups
    DB-->>API: PayGroup list
    API-->>UI: Display PayGroup selection
    
    PA->>UI: Select PayGroup "GRP_STAFF_HQ"
    UI->>PA: Display assignment form
    
    PA->>UI: Enter employeeId "EMP001"
    UI->>API: GET /workers/{employeeId} (CO reference)
    API->>CO: Query employee data
    CO-->>API: Employee exists with details
    API-->>UI: Display employee info
    
    PA->>UI: Enter assignment details
    Note over PA,UI: assignmentDate = "2026-04-01"<br/>assignmentReason = "NEW_HIRE"
    
    UI->>API: POST /pay-groups/{code}/employees
    API->>VAL: ValidateConfiguration(entityType=PayGroupAssignment)
    VAL->>VAL: Check employee not already assigned
    VAL->>VAL: Check PayGroup active
    VAL->>VAL: Check PayProfile active
    VAL->>VAL: Check PayCalendar active
    VAL-->>API: ValidationResult(PASS)
    
    API->>PG: AssignEmployeeToGroup command
    PG->>PG: Create PayGroupAssignment
    Note over PG: employeeId, assignmentDate, assignmentReason<br/>isCurrent = true
    
    PG->>DB: INSERT PayGroupAssignment
    
    PG->>AUD: CreateAuditEntry (ASSIGN)
    Note over AUD: operation = ASSIGN<br/>entityType = PayGroupAssignment<br/>newValue = assignment details
    
    PG-->>API: EmployeeAssignedToGroup event
    API-->>UI: 201 Created with assignment
    UI->>PA: Display success with employee summary
```

---

## Error Paths

### EP-001: Employee Already Assigned

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    participant DB as Database
    
    Note over PA: EMP001 already in GRP_STAFF_HQ
    
    PA->>UI: Enter employeeId "EMP001"
    UI->>API: POST /pay-groups/{code}/employees
    API->>VAL: Validate assignment
    VAL->>DB: Query current assignment for EMP001
    DB-->>VAL: Found assignment to GRP_STAFF_HQ
    VAL-->>API: ValidationResult(FAIL)
    Note over VAL: message = "Employee already assigned to pay group GRP_STAFF_HQ"
    API-->>UI: 400 Bad Request
    UI->>PA: Display error with current assignment details
```

### EP-002: Employee Not Found

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant CO as Core HR (CO)
    
    Note over PA: EmployeeId "EMP999" does not exist
    
    PA->>UI: Enter employeeId "EMP999"
    UI->>API: GET /workers/{employeeId}
    API->>CO: Query employee
    CO-->>API: Employee not found
    API-->>UI: 404 Not Found
    UI->>PA: Display error "Employee not found in Core HR"
```

### EP-003: PayGroup Inactive

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    participant PG as PayGroup Aggregate
    
    Note over PA: PayGroup "GRP_OLD" is inactive
    
    PA->>UI: Select PayGroup "GRP_OLD"
    UI->>API: POST /pay-groups/GRP_OLD/employees
    API->>VAL: Validate assignment
    VAL->>PG: Check PayGroup status
    PG-->>VAL: isActive = false
    VAL-->>API: ValidationResult(FAIL)
    Note over VAL: message = "Pay group must be active for assignment"
    API-->>UI: 400 Bad Request
    UI->>PA: Display error "Pay group is inactive"
```

---

## Transfer Flow (Variation)

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant PG1 as PayGroup (Current)
    participant PG2 as PayGroup (New)
    participant DB as Database
    participant AUD as AuditLog
    
    Note over PA: Transfer EMP001 from GRP_STAFF to GRP_EXEC
    
    PA->>UI: Select employee for transfer
    UI->>API: GET employee current assignment
    API->>DB: Query current assignment
    DB-->>API: EMP001 in GRP_STAFF_HQ
    API-->>UI: Display current assignment
    
    PA->>UI: Select new PayGroup "GRP_EXEC_HQ"
    PA->>UI: Enter transfer details
    Note over PA,UI: removalReason = "PROMOTION"<br/>assignmentReason = "PROMOTION"
    
    UI->>API: POST /pay-groups/GRP_EXEC_HQ/employees (transfer)
    
    API->>PG1: RemoveEmployeeFromGroup
    PG1->>DB: UPDATE PayGroupAssignment
    Note over PG1: removalDate = today<br/>removalReason = "PROMOTION"<br/>isCurrent = false
    PG1->>AUD: CreateAuditEntry (UNASSIGN)
    
    API->>PG2: AssignEmployeeToGroup
    PG2->>DB: INSERT PayGroupAssignment
    Note over PG2: assignmentDate = today<br/>assignmentReason = "PROMOTION"<br/>isCurrent = true
    PG2->>AUD: CreateAuditEntry (ASSIGN)
    
    API-->>UI: Transfer complete
    UI->>PA: Display success with transfer history
```

---

## Business Rules Applied

| Rule ID | Rule Name | Enforcement Point |
|---------|-----------|-------------------|
| BR-PG-001 | Single Employee Assignment | Validation |
| BR-PG-002 | Active Profile Required | Validation |
| BR-PG-003 | Active Calendar Required | Validation |

---

## API Contract

### Request

```http
POST /api/v1/pay-groups/GRP_STAFF_HQ/employees
Content-Type: application/json

{
  "employeeId": "EMP001",
  "assignmentDate": "2026-04-01",
  "assignmentReason": "NEW_HIRE"
}
```

### Response (Success)

```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "assignmentId": "asg-001",
  "employeeId": "EMP001",
  "employeeName": "Nguyen Van A",
  "payGroupId": "GRP_STAFF_HQ",
  "payGroupName": "Staff Group - Headquarters",
  "payProfileId": "PROFILE_STAFF",
  "payCalendarId": "CAL_2026_HQ",
  "assignmentDate": "2026-04-01",
  "assignmentReason": "NEW_HIRE",
  "isCurrent": true,
  "createdBy": "admin@company.com",
  "createdAt": "2026-03-31T14:00:00Z"
}
```

---

## Assignment History Query

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant DB as Database
    
    PA->>UI: View Employee Assignment History
    UI->>API: GET /employees/{id}/assignments/history
    API->>DB: Query all assignments for employee
    DB-->>API: Assignment history
    API-->>UI: Timeline data
    UI->>PA: Display assignment timeline
    
    Note over UI: Shows:<br/>- All historical assignments<br/>- Assignment and removal dates<br/>- PayGroups, Profiles, Calendars<br/>- Reasons for changes
```

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Domain Architect Agent