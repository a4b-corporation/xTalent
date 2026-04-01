# Use Case Flow - Validate Formula

> **Use Case**: UC-FM-001 Validate Formula
> **Bounded Context**: Payroll Configuration (BC-001)
> **Module**: Payroll (PR)
> **Priority**: P1
> **Story Points**: 8

---

## Overview

This flow documents the process of validating a calculation formula for syntax, references, and circular dependencies.

---

## Actors

| Actor | Role |
|-------|------|
| Payroll Admin | Primary actor - creates/validates formula |
| ValidationRule | Primary - validates syntax and references |
| PayFormula Aggregate | Manages formula |
| PayElement Aggregate | Referenced for element validation |

---

## Preconditions

1. Payroll Admin is logged in with formula permission
2. PayElements referenced in formula exist (or user is aware they don't)

---

## Postconditions

1. Formula syntax validated (pass or fail with errors)
2. Element references validated (exist or warnings)
3. Circular reference check performed
4. Division by zero check performed
5. Preview result available for valid formulas

---

## Happy Path

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant FM as PayFormula Aggregate
    participant VAL as ValidationRule
    participant PE as PayElement Aggregate
    participant DB as Database
    
    PA->>UI: Navigate to Formula Editor
    UI->>PA: Display formula input
    
    PA->>UI: Enter formula expression
    Note over PA,UI: "{SALARY_BASIC} * 0.08"
    
    PA->>UI: Click Validate
    UI->>API: POST /formulas/validate
    API->>FM: ValidateFormula command
    FM->>VAL: ValidateConfiguration(entityType=PayFormula)
    
    VAL->>VAL: Syntax validation
    Note over VAL: Parse expression<br/>Check operators<br/>Check function syntax<br/>Check parentheses
    
    VAL-->>FM: Syntax valid
    
    VAL->>PE: Query referenced elements
    PE->>DB: Query PayElement where elementCode in formula
    DB-->>PE: SALARY_BASIC exists and active
    PE-->>VAL: Element valid
    
    VAL->>VAL: Circular reference check
    Note over VAL: Build dependency graph<br/>Detect cycles<br/>Formula does not reference itself
    
    VAL->>VAL: Division by zero check
    Note over VAL: Check for /0 patterns<br/>Check for nullable division
    
    VAL-->>FM: ValidationResult(PASS)
    FM-->>API: FormulaValidated event
    API-->>UI: Validation result
    UI->>PA: Display "Formula valid"
    
    Note over PA: Optional preview
    PA->>UI: Enter sample value SALARY_BASIC = 10,000,000
    PA->>UI: Click Preview
    UI->>API: POST /formulas/preview
    API->>FM: PreviewFormula command
    FM->>FM: Evaluate expression with sample values
    FM-->>API: Result = 800,000
    API-->>UI: Preview result
    UI->>PA: Display "Result: 800,000 VND"
```

---

## Error Paths

### EP-001: Syntax Error

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    
    Note over PA: User enters invalid syntax<br/>"({SALARY_BASIC} * 0.08"
    
    PA->>UI: Click Validate
    UI->>API: POST /formulas/validate
    API->>VAL: Validate syntax
    VAL->>VAL: Parse expression
    VAL-->>API: ValidationResult(FAIL)
    Note over VAL: ruleCode = VAL_FM_SYNTAX<br/>message = "Invalid formula syntax: missing closing parenthesis"<br/>fieldPath = "expression"
    API-->>UI: Validation failed
    UI->>PA: Display error with syntax highlight
```

### EP-002: Missing Element Reference

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    participant PE as PayElement Aggregate
    participant DB as Database
    
    Note over PA: User references nonexistent element<br/>"{SALARY_NONEXISTENT} * 0.08"
    
    PA->>UI: Click Validate
    UI->>API: POST /formulas/validate
    API->>VAL: Validate references
    VAL->>PE: Query element
    PE->>DB: Query SALARY_NONEXISTENT
    DB-->>PE: Not found
    PE-->>VAL: Element not found
    VAL-->>API: ValidationResult(FAIL)
    Note over VAL: ruleCode = VAL_FM_REFERENCE_EXISTS<br/>message = "Referenced element SALARY_NONEXISTENT not found"<br/>severity = ERROR
    API-->>UI: Validation failed
    UI->>PA: Display error with element suggestion
```

### EP-003: Circular Reference

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    
    Note over PA: Formula A: "{BONUS} + 1000"<br/>Formula B: "{TOTAL} - {SALARY}"<br/>User creates formula referencing both
    
    PA->>UI: Enter "{TOTAL_PAY} / 12"
    UI->>API: POST /formulas/validate
    API->>VAL: Validate circular reference
    VAL->>VAL: Build dependency graph
    VAL->>VAL: Detect cycle: A -> B -> A
    VAL-->>API: ValidationResult(FAIL)
    Note over VAL: ruleCode = VAL_FM_CIRCULAR_REF<br/>message = "Circular reference detected: Formula_A -> Formula_B -> Formula_A"<br/>severity = ERROR
    API-->>UI: Validation failed
    UI->>PA: Display circular reference visualization
```

### EP-004: Division by Zero

```mermaid
sequenceDiagram
    actor PA as Payroll Admin
    participant UI as UI Layer
    participant API as API Layer
    participant VAL as ValidationRule
    
    Note over PA: User enters "{SALARY_BASIC} / 0"
    
    PA->>UI: Click Validate
    UI->>API: POST /formulas/validate
    API->>VAL: Validate division
    VAL->>VAL: Check division patterns
    VAL-->>API: ValidationResult(FAIL)
    Note over VAL: ruleCode = VAL_FM_DIVISION_ZERO<br/>message = "Division by zero detected"<br/>severity = ERROR
    API-->>UI: Validation failed
    UI->>PA: Display error "Division by zero not allowed"
```

---

## Business Rules Applied

| Rule ID | Rule Name | Enforcement Point |
|---------|-----------|-------------------|
| BR-FM-001 | Valid Syntax | Validation |
| BR-FM-002 | Reference Exists | Validation |
| BR-FM-003 | No Circular Reference | Validation |
| BR-FM-004 | Division Safety | Validation |

---

## API Contract

### Validation Request

```http
POST /api/v1/formulas/validate
Content-Type: application/json

{
  "expression": "{SALARY_BASIC} * 0.08"
}
```

### Validation Response (Success)

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "status": "PASS",
  "syntaxValid": true,
  "references": [
    { "elementCode": "SALARY_BASIC", "exists": true, "active": true }
  ],
  "circularReference": false,
  "divisionByZero": false,
  "message": "Formula validation passed"
}
```

### Validation Response (Error)

```http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "status": "FAIL",
  "syntaxValid": false,
  "syntaxError": "Missing closing parenthesis at position 20",
  "message": "Formula syntax validation failed"
}
```

### Preview Request

```http
POST /api/v1/formulas/preview
Content-Type: application/json

{
  "expression": "{SALARY_BASIC} * 0.08",
  "sampleValues": {
    "SALARY_BASIC": 10000000
  }
}
```

### Preview Response

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "result": 800000,
  "expression": "{SALARY_BASIC} * 0.08",
  "sampleValues": {
    "SALARY_BASIC": 10000000
  }
}
```

---

## Circular Reference Detection Algorithm

```
Algorithm: DetectCircularReference(formulaId)

1. Build dependency graph:
   - For each formula F, find all element references E
   - For each element E with formula, add F -> E.formula edge
   
2. Run cycle detection:
   - DFS traversal from formulaId
   - Track visited nodes
   - If node revisited during same traversal -> cycle found
   
3. Return cycle path if found, else null
```

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Domain Architect Agent