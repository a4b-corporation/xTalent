# Use Case Flow - Create Pay Profile with Element Assignment

> **Use Case**: UC-PP-001 Create Pay Profile with Element Assignment
> **Bounded Context**: Payroll Configuration (BC-001)
> **Module**: Payroll (PR)
> **Priority**: P0
> **Story Points**: 5

---

## Overview

This flow documents the process of creating a pay profile and assigning pay elements to it.

---

## Actors

| Actor | Role |
|-------|------|
| Payroll Admin | Primary actor - initiates creation |
| ValidationRule | Secondary - validates profile and assignments |
| PayElement Aggregate | Referenced for assignment validation |
| AuditLog | Secondary - logs creation and assignments |

---

## Preconditions

1. Payroll Admin is logged in with create permission
2. LegalEntity exists in Core HR (CO) module
3. PayFrequency exists in reference data
4. PayElements to be assigned exist and are active

---

## Postconditions

1. PayProfile created with version 1
2. PayElementAssignments created for assigned elements
3. Each assignment has priority and effective date
4. Audit entries created for profile and assignments
5. Profile available for PayGroup assignment

---

## Happy Path

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant PP as PayProfile Aggregate
    participant PE as PayElement Aggregate
    participant VAL as ValidationRule
    participant DB as Database
    participant AUD as AuditLog
    
    PA->>UI: Navigate to Pay Profile Create
    UI->>API: GET /pay-elements (available elements)
    API->>DB: Query active PayElements
    DB-->>API: Element list
    API-->>UI: Display element selection UI
    
    PA->>UI: Enter Profile Data
    Note over PA,UI: profileCode, profileName, legalEntityId, payFrequencyId
    
    PA->>UI: Select Elements to Assign
    Note over PA,UI: SALARY_BASIC (priority 10)<br/>OT_REGULAR (priority 20)<br/>BHXH_EE (priority 30)
    
    UI->>API: POST /pay-profiles
    API->>VAL: ValidateConfiguration(entityType=PayProfile)
    VAL->>VAL: Validate profile fields
    VAL->>VAL: Check unique profileCode per legalEntity
    VAL-->>API: ValidationResult(PASS)
    
    API->>PP: CreatePayProfile command
    PP->>PP: Initialize SCD-2 fields
    PP->>DB: INSERT PayProfile
    DB-->>PP: Success
    
    PP->>AUD: CreateAuditEntry (CREATE)
    AUD->>DB: INSERT AuditEntry
    
    loop For each assigned element
        API->>VAL: ValidateConfiguration(entityType=PayElementAssignment)
        VAL->>PE: Check element exists and active
        PE-->>VAL: Element valid
        VAL->>VAL: Check no duplicate assignment
        VAL->>VAL: Validate priority range (1-99)
        VAL-->>API: ValidationResult(PASS)
        
        API->>PP: AssignPayElement command
        PP->>PP: Create PayElementAssignment
        Note over PP: payElementId, priority, effectiveStartDate
        PP->>DB: INSERT PayElementAssignment
        
        PP->>AUD: CreateAuditEntry (ASSIGN)
    end
    
    PP-->>API: PayProfileCreated + PayElementAssigned events
    API-->>UI: 201 Created with profile and assignments
    UI->>PA: Display success with profile summary
```

---

## Error Paths

### EP-001: Duplicate Element Assignment

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    
    Note over PA: User selects SALARY_BASIC twice
    
    UI->>API: POST /pay-profiles
    API->>VAL: Validate assignments
    VAL->>VAL: Check duplicate elements in same profile
    VAL-->>API: ValidationResult(FAIL)
    Note over VAL: message = "Element already assigned to profile"
    API-->>UI: 400 Bad Request
    UI->>PA: Display error with duplicate element
```

### EP-002: Assign Inactive Element

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    participant PE as PayElement Aggregate
    
    Note over PA: User selects BONUS_OLD (inactive)
    
    UI->>API: POST /pay-profiles
    API->>VAL: Validate assignments
    VAL->>PE: Check element status
    PE-->>VAL: Element isActive = false
    VAL-->>API: ValidationResult(FAIL)
    Note over VAL: message = "Cannot assign inactive element"
    API-->>UI: 400 Bad Request
    UI->>PA: Display error "Element is inactive"
```

### EP-003: Invalid Priority

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    
    Note over PA: User enters priority = 150 (out of range)
    
    UI->>API: POST /pay-profiles
    API->>VAL: Validate assignments
    VAL->>VAL: Check priority range (1-99)
    VAL-->>API: ValidationResult(FAIL)
    Note over VAL: message = "Priority must be between 1 and 99"
    API-->>UI: 400 Bad Request
    UI->>PA: Display error with field highlight
```

---

## Business Rules Applied

| Rule ID | Rule Name | Enforcement Point |
|---------|-----------|-------------------|
| BR-PP-001 | Unique Profile Code | Validation before save |
| BR-PP-002 | Element Priority | Validation |
| BR-PP-003 | No Duplicate Elements | Validation |
| BR-PP-004 | Active Element Only | Validation |
| BR-PP-005 | Effective Date Required | Mandatory field |

---

## API Contract

### Request

```http
POST /api/v1/pay-profiles
Content-Type: application/json

{
  "profileCode": "PROFILE_STAFF",
  "profileName": "Staff Profile",
  "legalEntityId": "VN_HQ",
  "payFrequencyId": "MONTHLY",
  "elementAssignments": [
    {
      "payElementId": "SALARY_BASIC",
      "priority": 10,
      "effectiveStartDate": "2026-04-01"
    },
    {
      "payElementId": "OT_REGULAR",
      "priority": 20,
      "effectiveStartDate": "2026-04-01"
    },
    {
      "payElementId": "BHXH_EE",
      "priority": 30,
      "effectiveStartDate": "2026-04-01"
    }
  ]
}
```

### Response (Success)

```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "profileCode": "PROFILE_STAFF",
  "profileName": "Staff Profile",
  "legalEntityId": "VN_HQ",
  "payFrequencyId": "MONTHLY",
  "isActive": true,
  "effectiveStartDate": "2026-04-01",
  "effectiveEndDate": null,
  "isCurrentFlag": true,
  "elementAssignments": [
    {
      "payElementId": "SALARY_BASIC",
      "payElementName": "Basic Salary",
      "priority": 10,
      "effectiveStartDate": "2026-04-01"
    },
    {
      "payElementId": "OT_REGULAR",
      "payElementName": "Regular Overtime",
      "priority": 20,
      "effectiveStartDate": "2026-04-01"
    },
    {
      "payElementId": "BHXH_EE",
      "payElementName": "Social Insurance Employee",
      "priority": 30,
      "effectiveStartDate": "2026-04-01"
    }
  ],
  "createdBy": "admin@company.com",
  "createdAt": "2026-03-31T12:00:00Z"
}
```

---

## Flow Variation: Formula Override

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    participant PP as PayProfile Aggregate
    
    Note over PA: User overrides formula for OT_REGULAR
    
    PA->>UI: Enter formulaOverride: "hours * rate * 2.0"
    UI->>API: POST /pay-profiles
    API->>VAL: Validate formulaOverride
    VAL->>VAL: Check formula syntax
    VAL->>VAL: Check element references
    VAL-->>API: ValidationResult(PASS)
    
    API->>PP: AssignPayElement with override
    PP->>PP: Store formulaOverride in assignment
```

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Domain Architect Agent