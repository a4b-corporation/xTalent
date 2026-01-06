---
entity: ContractTemplate
domain: core-hr
version: "1.0.0"
status: draft
owner: core-team
tags: [work-relationship, contract-template, core]

classification:
  type: AGGREGATE_ROOT
  category: work-relationship

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated UUID

  - name: templateCode
    type: string
    required: true
    unique: true
    description: Template code

  - name: templateName
    type: string
    required: true
    description: Template name

  - name: contractTypeCode
    type: enum
    required: true
    values: [INDEFINITE, FIXED_TERM, SEASONAL, PROBATION]
    description: Contract type

  - name: countryCode
    type: string
    required: false
    description: Country scope

  - name: legalEntityCode
    type: string
    required: false
    description: Legal entity scope

  - name: businessUnitId
    type: string
    required: false
    description: BU scope

  - name: isDefault
    type: boolean
    required: true
    default: false
    description: Default for contract type

  - name: statusCode
    type: enum
    required: true
    values: [DRAFT, ACTIVE, INACTIVE]
    description: Template status

  - name: metadata
    type: object
    required: false
    description: Business rules (duration, probation, renewal)

  - name: effectiveStartDate
    type: date
    required: true
    description: Effective start

  - name: effectiveEndDate
    type: date
    required: false
    description: Effective end

relationships:
  - name: usedByContracts
    target: Contract
    cardinality: one-to-many
    required: false
    inverse: usesTemplate
    description: Contracts using template

lifecycle:
  states: [draft, active, inactive]
  initial: draft
  transitions:
    - from: draft
      to: active
      trigger: activate
    - from: active
      to: inactive
      trigger: deactivate
    - from: inactive
      to: active
      trigger: reactivate

actions:
  - name: create
    description: Create contract template
    requiredFields: [templateCode, templateName, contractTypeCode, effectiveStartDate]

  - name: activate
    description: Make template available
    triggersTransition: activate

  - name: setAsDefault
    description: Set as default for scope
    affectsAttributes: [isDefault]

policies:
  - name: uniqueCode
    type: validation
    rule: "Template code must be unique"

  - name: oneDefaultPerScope
    type: business
    rule: "Only one template can be default for each contract type + scope combination"

  - name: scopePriority
    type: business
    rule: "BU > Legal Entity > Country > Global (most specific wins)"
---

# ContractTemplate

## Overview

A **ContractTemplate** standardizes employment contract terms for consistent hiring. Templates define default values, business rules, and compliance requirements for different contract types and scopes (country, entity, BU). When creating a [[Contract]], the template provides defaults that can be customized.

```mermaid
mindmap
  root((ContractTemplate))
    Scope
      Country
      LegalEntity
      BusinessUnit
      Global
    Types
      INDEFINITE
      FIXED_TERM
      SEASONAL
      PROBATION
    Rules
      Duration
      Probation
      Renewal
      Notice
```

## Business Context

### Key Stakeholders
- **Legal/Compliance**: Defines template terms, ensures compliance
- **HR Admin**: Uses templates when creating contracts
- **HR Policy**: Sets default rules per scope
- **Audit**: Reviews template usage

### Business Processes
This entity is central to:
- **Contract Creation**: Provides defaults for new contracts
- **Compliance**: Ensures contracts meet legal requirements
- **Standardization**: Consistent terms across organization
- **Localization**: Different rules per country/entity

### Business Value
Templates reduce contract creation time, ensure compliance with local labor laws, and maintain consistency while allowing scope-specific customization.

## Attributes Guide

### Identification
- **templateCode**: Unique identifier. Format: TMPL-VN-INDEF.
- **templateName**: Display name. e.g., "Vietnam INDEFINITE Contract Template".
- **contractTypeCode**: Which contract type this template applies to.

### Scope Hierarchy (Most Specific Wins)
- **countryCode**: Country this applies to. null = all countries.
- **legalEntityCode**: Entity this applies to. null = all entities in country.
- **businessUnitId**: BU this applies to. null = all BUs in entity.

When creating contract, system finds most specific matching template:
1. BU-specific template (highest priority)
2. Entity-specific template
3. Country-specific template
4. Global template (lowest priority)

### Status
- **statusCode**: DRAFT (being prepared), ACTIVE (usable), INACTIVE (retired).
- **isDefault**: If true, auto-selected for matching scope.

### Business Rules (metadata)
```json
{
  "duration": {"default_months": 12, "min_months": 6, "max_months": 36},
  "probation": {"required": true, "duration_days": 60},
  "renewal": {"allowed": true, "max_count": 2, "notice_days": 30},
  "notice_period": {"default_days": 30, "min_days": 15}
}
```

## Relationships Explained

```mermaid
erDiagram
    CONTRACT_TEMPLATE ||--o{ CONTRACT : "usedByContracts"
```

### Contract Usage
- **usedByContracts** → [[Contract]]: All contracts created using this template. Tracked for audit and impact analysis when template changes.

## Lifecycle & Workflows

### State Definitions

| State | Business Meaning | System Impact |
|-------|------------------|---------------|
| **draft** | Being prepared | Cannot be used for contracts |
| **active** | Available for use | Selectable when creating contracts |
| **inactive** | Retired | Cannot be used for new contracts |

### State Diagram

```mermaid
stateDiagram-v2
    [*] --> draft: create
    
    draft --> active: activate (legal approval)
    
    active --> inactive: deactivate
    inactive --> active: reactivate
```

### Template Selection Flow

```mermaid
flowchart TD
    A[Create Contract] --> B{BU Template?}
    B -->|Yes| C[Use BU Template]
    B -->|No| D{Entity Template?}
    D -->|Yes| E[Use Entity Template]
    D -->|No| F{Country Template?}
    F -->|Yes| G[Use Country Template]
    F -->|No| H[Use Global Template]
```

## Actions & Operations

### create
**Who**: Legal/Compliance, HR Policy  
**When**: New template needed for scope/type  
**Required**: templateCode, templateName, contractTypeCode, effectiveStartDate  
**Process**:
1. Define scope (country/entity/BU or global)
2. Set business rules in metadata
3. Create in draft state
4. Legal review

### activate
**Who**: Legal/Compliance (approval required)  
**When**: Template approved  
**Process**:
1. Verify all required metadata
2. Transition to active
3. Available for contract creation

### setAsDefault
**Who**: HR Policy  
**When**: Designating primary template  
**Process**:
1. Clear isDefault on other templates for same scope+type
2. Set isDefault = true on this template

## Business Rules

### Data Integrity

#### Unique Code (uniqueCode)
**Rule**: Template code globally unique.  
**Reason**: Reference for audits, integrations.  
**Violation**: System prevents save.

### Business Logic

#### One Default Per Scope (oneDefaultPerScope)
**Rule**: One default template per contract type + scope.  
**Reason**: Clear auto-selection logic.  
**Implementation**: System clears other defaults when setting new default.

#### Scope Priority (scopePriority)
**Rule**: More specific scope takes precedence.  
**Reason**: Allows localization while maintaining global standards.  
**Example**: VN-specific overrides Global template.

## Examples

### Example 1: Global INDEFINITE Template
- **templateCode**: TMPL-GLOBAL-INDEF
- **contractTypeCode**: INDEFINITE
- **countryCode**: null (all)
- **legalEntityCode**: null (all)
- **isDefault**: true

### Example 2: Vietnam Fixed-Term Template
- **templateCode**: TMPL-VN-FIXED
- **contractTypeCode**: FIXED_TERM
- **countryCode**: VN
- **metadata**: `{"duration": {"max_months": 36}}`

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[Contract]] | usedByContracts | Contracts using template |
