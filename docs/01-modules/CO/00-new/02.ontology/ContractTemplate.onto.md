---
entity: ContractTemplate
domain: employment
version: "1.0.0"
status: approved
owner: Employment Domain Team
tags: [contract-template, document-generation, template]

attributes:
  # === IDENTITY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  - name: code
    type: string
    required: true
    unique: true
    description: Template code (unique identifier)
    constraints:
      maxLength: 50
  
  - name: name
    type: string
    required: true
    description: Template name
    constraints:
      maxLength: 200
  
  # === DOCUMENT TYPE ===
  - name: documentTypeCode
    type: enum
    required: true
    description: Type of document this template generates
    values: [OFFER, CONTRACT, ADDENDUM, TERMINATION, AMENDMENT]
  
  # === CATEGORY ===
  - name: categoryCode
    type: enum
    required: false
    description: Contract category
    values: [PROBATION, OFFICIAL, INTERN, SEASONAL]
  
  # === CONTENT ===
  - name: content
    type: string
    required: true
    description: Template body (HTML/RTF with placeholders)
    constraints:
      maxLength: 100000
  
  - name: contentFormat
    type: enum
    required: true
    description: Content format
    values: [HTML, RTF, MARKDOWN]
    default: HTML
  
  # === PLACEHOLDERS ===
  - name: placeholders
    type: json
    required: false
    description: List of required placeholders/tokens (e.g., [{key EMPLOYEE_NAME, source person.fullName}])
  
  # === LANGUAGE ===
  - name: languageCode
    type: string
    required: true
    description: Template language (ISO 639-1 code, e.g., vi, en)
    constraints:
      pattern: "^[a-z]{2}$"
    default: vi
  
  # === VERSION ===
  - name: version
    type: string
    required: true
    description: Template version number
    constraints:
      maxLength: 20
    default: "1.0"
  
  # === EFFECTIVE DATES ===
  - name: effectiveStartDate
    type: date
    required: true
    description: Date template becomes effective
  
  - name: effectiveEndDate
    type: date
    required: false
    description: Date template expires (null = current)
  
  # === STATUS ===
  - name: isActive
    type: boolean
    required: true
    default: true
    description: Is this template currently active?
  
  # === DESCRIPTION ===
  - name: description
    type: string
    required: false
    description: Template description and usage notes
    constraints:
      maxLength: 1000
  
  # === AUDIT ===
  - name: createdAt
    type: datetime
    required: true
    description: Record creation timestamp
  
  - name: updatedAt
    type: datetime
    required: true
    description: Last modification timestamp
  
  - name: createdBy
    type: string
    required: true
    description: User who created the record
  
  - name: updatedBy
    type: string
    required: true
    description: User who last modified the record

relationships:
  - name: usedInContracts
    target: Contract
    cardinality: one-to-many
    required: false
    inverse: generatedFromTemplate
    description: Contracts generated from this template. INVERSE - Contract.generatedFromTemplate must reference this ContractTemplate.

lifecycle:
  states: [DRAFT, ACTIVE, INACTIVE]
  initial: DRAFT
  terminal: [INACTIVE]
  transitions:
    - from: DRAFT
      to: ACTIVE
      trigger: activate
      guard: Template ready for use
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: Template no longer used

policies:
  - name: TemplateCodeUniqueness
    type: validation
    rule: code must be unique across all templates
    expression: "COUNT(ContractTemplate WHERE code = X) = 1"
    severity: ERROR
  
  - name: EffectiveDateConsistency
    type: validation
    rule: effectiveStartDate must be before effectiveEndDate (if set)
    expression: "effectiveEndDate IS NULL OR effectiveStartDate < effectiveEndDate"
  
  - name: OneActiveTemplatePerType
    type: business
    rule: Only one ACTIVE template per documentTypeCode + categoryCode + languageCode combination
    severity: WARNING
  
  - name: PlaceholderValidation
    type: business
    rule: All placeholders in content must be defined in placeholders JSON
    severity: WARNING
---

# Entity: ContractTemplate

## 1. Overview

The **ContractTemplate** entity manages blueprints for generating legal employment contracts. It defines layout, static text, and dynamic placeholders (tokens) replaced by employee data during generation.

**Key Concept**:
```
ContractTemplate + Employee Data → Generated Contract (PDF/HTML)
Placeholders: {{EMPLOYEE_NAME}}, {{START_DATE}}, {{SALARY_AMOUNT}}
```

```mermaid
mindmap
  root((ContractTemplate))
    Identity
      id
      code
      name
    Document Type
      documentTypeCode
      categoryCode
    Content
      content
      contentFormat
      placeholders
    Language
      languageCode
    Version
      version
    Effective Dates
      effectiveStartDate
      effectiveEndDate
    Status
      isActive
    Description
      description
    Relationships
      usedInContracts
    Lifecycle
      DRAFT
      ACTIVE
      INACTIVE
```

**Design Rationale**:
- **Template Versioning**: Track template versions over time
- **Placeholder System**: Dynamic data binding ({{EMPLOYEE_NAME}})
- **Multi-Language**: Support vi-VN, en-US templates
- **Effective Dating**: Templates valid for specific periods

---

## 2. Attributes

### 2.1 Identity Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique internal identifier (UUID) |
| code | string | ✓ | Template code (unique) |
| name | string | ✓ | Template name |

### 2.2 Document Type

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| documentTypeCode | enum | ✓ | OFFER, CONTRACT, ADDENDUM, TERMINATION, AMENDMENT |
| categoryCode | enum | | PROBATION, OFFICIAL, INTERN, SEASONAL |

### 2.3 Content

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| content | string | ✓ | Template body (HTML/RTF with placeholders) |
| contentFormat | enum | ✓ | HTML, RTF, MARKDOWN |
| placeholders | json | | List of required placeholders |

### 2.4 Language

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| languageCode | string | ✓ | Language (vi, en) |

### 2.5 Version

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| version | string | ✓ | Template version number |

### 2.6 Effective Dates

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| effectiveStartDate | date | ✓ | Template becomes effective |
| effectiveEndDate | date | | Template expires |

### 2.7 Status

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| isActive | boolean | ✓ | Currently active? |

### 2.8 Audit Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| createdAt | datetime | ✓ | Record creation timestamp |
| updatedAt | datetime | ✓ | Last modification timestamp |
| createdBy | string | ✓ | User who created record |
| updatedBy | string | ✓ | User who last modified |

---

## 3. Relationships

```mermaid
erDiagram
    ContractTemplate ||--o{ Contract : usedInContracts
    
    ContractTemplate {
        string id PK
        string code UK
        string name
        enum documentTypeCode
        string content
        enum contentFormat
        json placeholders
        string languageCode
        boolean isActive
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[Contract]] | usedInContracts | 1:N | Contracts generated from template |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> DRAFT: Create Template
    DRAFT --> ACTIVE: Activate (ready for use)
    ACTIVE --> INACTIVE: Deactivate (no longer used)
    INACTIVE --> [*]
```

---

## 5. Business Rules Reference

### Validation Rules
- **TemplateCodeUniqueness**: code unique across all templates
- **EffectiveDateConsistency**: effectiveStartDate < effectiveEndDate (if set)

### Business Constraints
- **OneActiveTemplatePerType**: Only one ACTIVE template per type+category+language (WARNING)
- **PlaceholderValidation**: All placeholders in content must be defined (WARNING)

### Placeholder Examples

```json
[
  {"key": "EMPLOYEE_NAME", "source": "employee.fullName"},
  {"key": "START_DATE", "source": "contract.startDate"},
  {"key": "SALARY_AMOUNT", "source": "compensation.baseSalary"},
  {"key": "LEGAL_ENTITY_NAME", "source": "legalEntity.name"},
  {"key": "LEGAL_REP_NAME", "source": "legalRepresentative.name"}
]
```

---

*Document Status: APPROVED - Based on Oracle HCM, SAP SuccessFactors, Workday patterns*
