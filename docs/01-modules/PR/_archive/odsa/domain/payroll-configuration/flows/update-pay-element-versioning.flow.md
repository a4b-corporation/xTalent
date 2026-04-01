# Use Case Flow - Update Pay Element with Versioning

> **Use Case**: UC-PE-002 Update Pay Element with Versioning
> **Bounded Context**: Payroll Configuration (BC-001)
> **Module**: Payroll (PR)
> **Priority**: P0
> **Story Points**: 8

---

## Overview

This flow documents the process of updating a pay element with SCD-2 version tracking. Updating creates a new version while preserving the previous version.

---

## Actors

| Actor | Role |
|-------|------|
| Payroll Admin | Primary actor - initiates update |
| ValidationRule | Secondary - validates changes |
| PayElement Aggregate | Manages versioning |
| AuditLog | Secondary - logs update |

---

## Preconditions

1. Payroll Admin is logged in with update permission
2. PayElement exists with at least one version
3. Current version is identified (isCurrentFlag = true)

---

## Postconditions

1. New version created with updated values
2. Previous version has effectiveEndDate set
3. Previous version has isCurrentFlag = false
4. Only one version has isCurrentFlag = true
5. Audit entries created for version creation

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
    
    PA->>UI: Navigate to Pay Element Edit
    UI->>API: GET /pay-elements/{code}
    API->>DB: Query current version
    DB-->>API: PayElement data (version 1)
    API-->>UI: Display Edit Form with current values
    
    PA->>UI: Modify elementName to "Basic Monthly Salary"
    PA->>UI: Enter changeReason "Name clarification"
    UI->>UI: Preview changes (optional)
    
    PA->>UI: Click Save
    UI->>API: PUT /pay-elements/{code}
    Note over PA,API: Request includes changeReason
    
    API->>VAL: ValidateConfiguration(entityType=PayElement, operation=UPDATE)
    VAL->>VAL: Validate modified fields
    VAL->>VAL: Check version continuity
    VAL-->>API: ValidationResult(PASS)
    
    API->>PE: UpdatePayElement command
    PE->>DB: Query current version (version 1)
    DB-->>PE: Current version data
    
    PE->>PE: Close previous version
    Note over PE: Set effectiveEndDate = today<br/>Set isCurrentFlag = false
    
    PE->>DB: UPDATE PayElement (version 1)
    
    PE->>PE: Create new version
    Note over PE: Copy base attributes<br/>Apply modifications<br/>Set effectiveStartDate = today<br/>Set effectiveEndDate = null<br/>Set isCurrentFlag = true<br/>Set versionReason
    
    PE->>DB: INSERT PayElement (version 2)
    DB-->>PE: Success
    
    PE->>AUD: CreateAuditEntry (operation = VERSION_CREATE)
    AUD->>DB: INSERT AuditEntry
    Note over AUD: oldValue = version 1 attributes<br/>newValue = version 2 attributes<br/>changedFields = [elementName]<br/>versionId = version 2
    
    PE-->>API: PayElementUpdated + PayElementVersionCreated events
    API-->>UI: 200 OK with new version
    UI->>PA: Display success with version history
```

---

## Error Paths

### EP-001: Version Date Overlap

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    
    Note over PA: User sets effectiveStartDate = "2026-06-15"<br/>But version 1 ends on "2026-06-30"
    
    PA->>UI: Enter effectiveStartDate before current version ends
    UI->>API: PUT /pay-elements/{code}
    API->>VAL: ValidateConfiguration
    VAL->>VAL: Check version date continuity
    VAL->>VAL: Detect overlap with existing version
    VAL-->>API: ValidationResult(FAIL)
    Note over VAL: ruleCode = VAL_PE_VERSION_CONTINUITY<br/>message = "New version overlaps with existing version"
    API-->>UI: 400 Bad Request
    UI->>PA: Display error with date conflict details
```

### EP-002: Missing Change Reason

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    
    PA->>UI: Save without changeReason
    UI->>API: PUT /pay-elements/{code}
    Note over PA,API: versionReason = null or empty
    API->>VAL: ValidateConfiguration
    VAL->>VAL: Check required version reason
    VAL-->>API: ValidationResult(FAIL)
    Note over VAL: message = "Change reason required for versioned entities"
    API-->>UI: 400 Bad Request
    UI->>PA: Display error "Change reason is required"
```

---

## Preview Flow (Optional)

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant PE as PayElement Aggregate
    
    PA->>UI: Click Preview
    UI->>PE: ComparePayElementVersions(current, proposed)
    PE-->>UI: ComparisonResult
    UI->>PA: Display side-by-side comparison
    Note over UI: Shows:<br/>- Changed fields highlighted<br/>- Old vs new values<br/>- Effective date changes<br/>- Impact summary
    
    PA->>UI: Review and confirm changes
    PA->>UI: Click Save to commit
```

---

## Business Rules Applied

| Rule ID | Rule Name | Enforcement Point |
|---------|-----------|-------------------|
| BR-PE-005 | Version Continuity | Validation before save |
| BR-VM-001 | SCD-2 Pattern | Aggregate versioning logic |
| BR-VM-002 | Single Current | Aggregate state management |
| BR-VM-003 | Change Reason Required | Validation |
| BR-VM-004 | Audit Trail | Event handler |

---

## API Contract

### Request

```http
PUT /api/v1/pay-elements/SALARY_BASIC
Content-Type: application/json

{
  "elementName": "Basic Monthly Salary",
  "effectiveStartDate": "2026-04-01",
  "versionReason": "Name clarification for better understanding"
}
```

### Response (Success)

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "elementCode": "SALARY_BASIC",
  "elementName": "Basic Monthly Salary",
  "legalEntityId": "VN_HQ",
  "classification": "EARNING",
  "calculationType": "FIXED",
  "statutoryFlag": false,
  "taxableFlag": true,
  "isActive": true,
  "effectiveStartDate": "2026-04-01",
  "effectiveEndDate": null,
  "isCurrentFlag": true,
  "versionReason": "Name clarification for better understanding",
  "createdBy": "admin@company.com",
  "createdAt": "2026-03-31T11:00:00Z",
  "version": 2
}
```

---

## State Changes

| Entity | Before | After |
|--------|--------|-------|
| PayElement (v1) | isCurrentFlag=true, endDate=null | isCurrentFlag=false, endDate=today |
| PayElement (v2) | Does not exist | Created with current=true |
| AuditEntry | - | VERSION_CREATE entry logged |

---

## Version History Query

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant DB as Database
    
    PA->>UI: View Version History
    UI->>API: GET /pay-elements/{code}/versions
    API->>DB: Query all versions for elementCode
    DB-->>API: Version list (v1, v2)
    API-->>UI: Version history data
    UI->>PA: Display version timeline
```

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Domain Architect Agent