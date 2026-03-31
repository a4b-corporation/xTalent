# Use Case Flow - Configure PIT Progressive Brackets

> **Use Case**: UC-SR-001 Configure PIT Progressive Brackets
> **Bounded Context**: Statutory Compliance (BC-002)
> **Module**: Payroll (PR)
> **Priority**: P0
> **Story Points**: 8

---

## Overview

This flow documents the process of creating a Personal Income Tax (PIT) statutory rule with progressive tax brackets for Vietnam.

---

## Actors

| Actor | Role |
|-------|------|
| Payroll Admin | Primary actor - initiates configuration |
| Compliance Officer | Secondary - validates statutory accuracy |
| ValidationRule | Secondary - validates brackets |
| AuditLog | Secondary - logs configuration |

---

## Preconditions

1. Payroll Admin is logged in with statutory rule permission
2. No existing PIT rule with overlapping effective dates
3. Vietnam government regulations reference available

---

## Postconditions

1. StatutoryRule created for PIT with version 1
2. 7 TaxBracket records created with progressive rates
3. Personal exemption (11M VND) and dependent exemption (4.4M VND) configured
4. Audit entries created for rule and brackets
5. PIT rule available for assignment to PayProfile

---

## Happy Path

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant SR as StatutoryRule Aggregate
    participant VAL as ValidationRule
    participant DB as Database
    participant AUD as AuditLog
    
    PA->>UI: Navigate to Statutory Rule Create
    UI->>PA: Display statutory type selection
    PA->>UI: Select statutoryType = PIT
    UI->>PA: Display PIT configuration form
    
    PA->>UI: Enter rule details
    Note over PA,UI: ruleCode = PIT_VN<br/>ruleName = "Personal Income Tax Vietnam"<br/>statutoryType = PIT<br/>rateType = PROGRESSIVE
    
    PA->>UI: Configure exemption amounts
    Note over PA,UI: personalExemption = 11,000,000<br/>dependentExemption = 4,400,000
    
    PA->>UI: Configure 7 progressive brackets
    Note over PA,UI: Bracket 1: 0-5M, 5%<br/>Bracket 2: 5M-10M, 10%<br/>Bracket 3: 10M-18M, 15%<br/>Bracket 4: 18M-32M, 20%<br/>Bracket 5: 32M-52M, 25%<br/>Bracket 6: 52M-80M, 30%<br/>Bracket 7: 80M+, 35%
    
    UI->>API: POST /statutory-rules
    API->>VAL: ValidateConfiguration(entityType=StatutoryRule)
    VAL->>VAL: Validate rule fields
    VAL->>VAL: Validate bracket coverage (full range)
    VAL->>VAL: Validate bracket sequence (no gaps)
    VAL->>VAL: Validate rate values (0-1)
    VAL-->>API: ValidationResult(PASS)
    
    API->>SR: CreateStatutoryRule command
    SR->>PP: Initialize SCD-2 fields
    Note over SR: effectiveStartDate = today<br/>effectiveEndDate = null<br/>isCurrentFlag = true
    
    SR->>DB: INSERT StatutoryRule
    
    loop For each bracket (1-7)
        SR->>SR: Create TaxBracket
        SR->>DB: INSERT TaxBracket
    end
    
    SR->>AUD: CreateAuditEntry (CREATE)
    Note over AUD: Includes all brackets in newValue
    
    SR-->>API: StatutoryRuleCreated + PITBracketConfigured events
    API-->>UI: 201 Created with rule and brackets
    UI->>PA: Display success with bracket summary
```

---

## Error Paths

### EP-001: Bracket Coverage Gap

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    
    Note over PA: User creates brackets with gap<br/>Bracket 1: 0-5M<br/>Bracket 2: 10M-18M (gap: 5M-10M)
    
    UI->>API: POST /statutory-rules
    API->>VAL: Validate brackets
    VAL->>VAL: Check bracket coverage
    VAL->>VAL: Detect gap between brackets
    VAL-->>API: ValidationResult(FAIL)
    Note over VAL: message = "Brackets do not cover full income range. Gap detected between 5M and 10M"
    API-->>UI: 400 Bad Request
    UI->>PA: Display error with gap visualization
```

### EP-002: Invalid Rate Value

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    
    Note over PA: User enters bracket rate = 0.50 (50%)
    
    UI->>API: POST /statutory-rules
    API->>VAL: Validate brackets
    VAL->>VAL: Check rate values
    VAL-->>API: ValidationResult(FAIL)
    Note over VAL: message = "Bracket rate 50% exceeds maximum PIT rate 35%"
    API-->>UI: 400 Bad Request
    UI->>PA: Display error with rate validation
```

### EP-003: Government Rate Warning

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    
    Note over PA: User enters rates different from government standard
    
    UI->>API: POST /statutory-rules
    API->>VAL: Validate brackets
    VAL->>VAL: Compare with government rates
    VAL-->>API: ValidationResult(WARNING)
    Note over VAL: severity = WARNING<br/>message = "Bracket rates differ from current government regulations. Continue?"
    
    API-->>UI: Warning response
    UI->>PA: Display warning dialog
    PA->>UI: Acknowledge and proceed
    UI->>API: POST with override flag
```

---

## Business Rules Applied

| Rule ID | Rule Name | Enforcement Point |
|---------|-----------|-------------------|
| BR-SR-003 | Progressive Brackets Coverage | Validation |
| BR-SR-001 | Rate Validation | Validation |
| BR-SR-004 | Version Non-Overlap | Validation |
| BR-SR-005 | Government Rates Warning | Validation (warning) |

---

## API Contract

### Request

```http
POST /api/v1/statutory-rules
Content-Type: application/json

{
  "ruleCode": "PIT_VN",
  "ruleName": "Personal Income Tax Vietnam",
  "statutoryType": "PIT",
  "partyType": "EMPLOYEE",
  "rateType": "PROGRESSIVE",
  "personalExemption": 11000000,
  "dependentExemption": 4400000,
  "effectiveStartDate": "2026-01-01",
  "taxBrackets": [
    { "bracketNumber": 1, "minAmount": 0, "maxAmount": 5000000, "rate": 0.05 },
    { "bracketNumber": 2, "minAmount": 5000001, "maxAmount": 10000000, "rate": 0.10 },
    { "bracketNumber": 3, "minAmount": 10000001, "maxAmount": 18000000, "rate": 0.15 },
    { "bracketNumber": 4, "minAmount": 18000001, "maxAmount": 32000000, "rate": 0.20 },
    { "bracketNumber": 5, "minAmount": 32000001, "maxAmount": 52000000, "rate": 0.25 },
    { "bracketNumber": 6, "minAmount": 52000001, "maxAmount": 80000000, "rate": 0.30 },
    { "bracketNumber": 7, "minAmount": 80000001, "maxAmount": null, "rate": 0.35 }
  ]
}
```

### Response (Success)

```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "ruleCode": "PIT_VN",
  "ruleName": "Personal Income Tax Vietnam",
  "statutoryType": "PIT",
  "partyType": "EMPLOYEE",
  "rateType": "PROGRESSIVE",
  "personalExemption": 11000000,
  "dependentExemption": 4400000,
  "isActive": true,
  "effectiveStartDate": "2026-01-01",
  "effectiveEndDate": null,
  "isCurrentFlag": true,
  "taxBrackets": [
    { "bracketNumber": 1, "minAmount": 0, "maxAmount": 5000000, "rate": 0.05 },
    { "bracketNumber": 2, "minAmount": 5000001, "maxAmount": 10000000, "rate": 0.10 },
    { "bracketNumber": 3, "minAmount": 10000001, "maxAmount": 18000000, "rate": 0.15 },
    { "bracketNumber": 4, "minAmount": 18000001, "maxAmount": 32000000, "rate": 0.20 },
    { "bracketNumber": 5, "minAmount": 32000001, "maxAmount": 52000000, "rate": 0.25 },
    { "bracketNumber": 6, "minAmount": 52000001, "maxAmount": 80000000, "rate": 0.30 },
    { "bracketNumber": 7, "minAmount": 80000001, "maxAmount": null, "rate": 0.35 }
  ],
  "createdBy": "admin@company.com",
  "createdAt": "2026-01-01T10:00:00Z"
}
```

---

## PIT Calculation Example

For taxable income of 25,000,000 VND:

| Bracket | Income Range | Taxable in Bracket | Rate | Tax |
|---------|--------------|-------------------|------|-----|
| 1 | 0-5M | 5,000,000 | 5% | 250,000 |
| 2 | 5M-10M | 5,000,000 | 10% | 500,000 |
| 3 | 10M-18M | 8,000,000 | 15% | 1,200,000 |
| 4 | 18M-32M | 7,000,000 | 20% | 1,400,000 |
| **Total** | | **25,000,000** | | **3,350,000** |

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Domain Architect Agent