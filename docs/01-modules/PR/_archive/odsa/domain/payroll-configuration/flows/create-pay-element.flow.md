# Use Case Flow - Create Pay Element

> **Use Case**: UC-PE-001 Create Pay Element
> **Bounded Context**: Payroll Configuration (BC-001)
> **Module**: Payroll (PR)
> **Priority**: P0
> **Story Points**: 5

---

## Overview

This flow documents the process of creating a new pay element with version tracking (SCD-2).

---

## Actors

| Actor | Role |
|-------|------|
| Payroll Admin | Primary actor - initiates creation |
| ValidationRule | Secondary - validates input |
| AuditLog | Secondary - logs creation |

---

## Preconditions

1. Payroll Admin is logged in with create permission
2. LegalEntity exists in Core HR (CO) module
3. No PayElement with same elementCode exists for the LegalEntity

---

## Postconditions

1. PayElement created with version 1
2. SCD-2 fields set correctly (effectiveStartDate, isCurrentFlag = true)
3. Audit entry created
4. PayElement available for assignment to PayProfile

---

## Happy Path

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant PE as PayElement Aggregate
    participant VAL as ValidationRule
    participant DB as Database
    participant AUD as AuditLog
    
    PA->>UI: Navigate to Pay Element Create
    UI->>PA: Display Create Form
    PA->>UI: Enter Pay Element Data
    Note over PA,UI: elementCode, elementName, classification, calculationType, statutoryFlag, taxableFlag
    
    UI->>API: POST /pay-elements
    API->>VAL: ValidateConfiguration(entityType=PayElement)
    VAL->>VAL: Validate field constraints
    VAL->>VAL: Check unique code per legal entity
    VAL->>API: ValidationResult(PASS)
    
    API->>PE: CreatePayElement command
    PE->>PE: Initialize SCD-2 fields
    Note over PE: effectiveStartDate = today<br/>effectiveEndDate = null<br/>isCurrentFlag = true<br/>versionReason = "Initial creation"
    
    PE->>DB: INSERT PayElement
    DB-->>PE: Success (elementId)
    
    PE->>AUD: CreateAuditEntry
    AUD->>DB: INSERT AuditEntry
    Note over AUD: operation = CREATE<br/>oldValue = null<br/>newValue = element data
    
    PE-->>API: PayElementCreated event
    API-->>UI: 201 Created with element data
    UI->>PA: Display success message
```

---

## Error Paths

### EP-001: Duplicate Element Code

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    
    PA->>UI: Enter elementCode "SALARY_BASIC"
    UI->>API: POST /pay-elements
    API->>VAL: ValidateConfiguration
    VAL->>VAL: Check unique code
    VAL->>VAL: Found existing "SALARY_BASIC" for LegalEntity
    VAL-->>API: ValidationResult(FAIL)
    Note over VAL: ruleCode = VAL_PE_UNIQUE_CODE<br/>message = "Element code must be unique per legal entity"
    API-->>UI: 400 Bad Request
    UI->>PA: Display error "Element code already exists"
```

### EP-002: Missing Required Fields

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    
    PA->>UI: Submit without elementName
    UI->>API: POST /pay-elements (missing name)
    API->>VAL: ValidateConfiguration
    VAL->>VAL: Check required fields
    VAL-->>API: ValidationResult(FAIL)
    Note over VAL: ruleCode = VAL_PE_NAME_REQUIRED<br/>message = "Element name is required"
    API-->>UI: 400 Bad Request
    UI->>PA: Display error with field highlight
```

### EP-003: Invalid Rate Value

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    
    PA->>UI: Enter rate = 1.5 (invalid)
    UI->>API: POST /pay-elements
    API->>VAL: ValidateConfiguration
    VAL->>VAL: Check rate range (0-1)
    VAL-->>API: ValidationResult(FAIL)
    Note over VAL: ruleCode = VAL_PE_RATE_RANGE<br/>message = "Rate must be between 0 and 1"
    API-->>UI: 400 Bad Request
    UI->>PA: Display error "Rate must be between 0 and 1"
```

---

## Business Rules Applied

| Rule ID | Rule Name | Enforcement Point |
|---------|-----------|-------------------|
| BR-PE-001 | Unique Element Code | Validation before save |
| BR-PE-002 | Classification Impact | Automatic on selection |
| BR-PE-003 | Soft Delete Only | System enforced |
| BR-VM-001 | SCD-2 Pattern | Aggregate initialization |
| BR-VM-002 | Single Current | Aggregate initialization |
| BR-VM-004 | Audit Trail | Event handler |

---

## API Contract

### Request

```http
POST /api/v1/pay-elements
Content-Type: application/json

{
  "elementCode": "SALARY_BASIC",
  "elementName": "Basic Salary",
  "legalEntityId": "VN_HQ",
  "classification": "EARNING",
  "calculationType": "FIXED",
  "statutoryFlag": false,
  "taxableFlag": true,
  "amount": null,
  "effectiveStartDate": "2026-04-01"
}
```

### Response (Success)

```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "elementCode": "SALARY_BASIC",
  "elementName": "Basic Salary",
  "legalEntityId": "VN_HQ",
  "classification": "EARNING",
  "calculationType": "FIXED",
  "statutoryFlag": false,
  "taxableFlag": true,
  "isActive": true,
  "effectiveStartDate": "2026-04-01",
  "effectiveEndDate": null,
  "isCurrentFlag": true,
  "versionReason": "Initial creation",
  "createdBy": "admin@company.com",
  "createdAt": "2026-03-31T10:30:00Z"
}
```

### Response (Error)

```http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "error": "VALIDATION_FAILED",
  "message": "Element code must be unique per legal entity",
  "validationResults": [
    {
      "ruleCode": "VAL_PE_UNIQUE_CODE",
      "severity": "ERROR",
      "passed": false,
      "fieldPath": "elementCode"
    }
  ]
}
```

---

## State Changes

| Entity | Before | After |
|--------|--------|-------|
| PayElement | Does not exist | Created with version 1 |
| AuditEntry | Does not exist | CREATE entry logged |

---

## Flow Variations

### FV-001: Create with Formula

When calculationType = FORMULA:
1. Additional field: formulaId required
2. Additional validation: formulaId must reference existing PayFormula
3. Formula validation rule: VAL_PE_FORMULA_REF

### FV-002: Create Statutory Element

When statutoryFlag = true:
1. Element represents BHXH, BHYT, BHTN, or PIT
2. Classification automatically set based on statutoryType
3. Additional statutory rule reference may be created

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Domain Architect Agent