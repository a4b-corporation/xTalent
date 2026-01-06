---
entity: LegalEntity
domain: core-hr
version: "1.0.0"
status: draft
owner: core-team
tags: [organization, legal-entity, core]

classification:
  type: AGGREGATE_ROOT
  category: organization

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated UUID

  - name: code
    type: string
    required: true
    unique: true
    description: Unique entity code
    constraints:
      max: 50

  - name: nameVi
    type: string
    required: true
    description: Vietnamese legal name

  - name: nameEn
    type: string
    required: false
    description: English name

  - name: typeId
    type: enum
    required: true
    values: [COMPANY, BRANCH, SUBSIDIARY, REPRESENTATIVE]
    description: Entity type

  - name: parentId
    type: string
    required: false
    description: Parent legal entity

  - name: path
    type: string
    required: true
    description: Hierarchical path

  - name: taxId
    type: string
    required: false
    description: Tax identification number

  - name: countryCode
    type: string
    required: true
    description: Country (ISO 3166-1 alpha-2)

  - name: statusCode
    type: enum
    required: true
    values: [ACTIVE, INACTIVE, DISSOLVED]
    description: Entity status

  - name: effectiveStartDate
    type: date
    required: true
    description: Effective start (SCD-2)

  - name: effectiveEndDate
    type: date
    required: false
    description: Effective end

  - name: isCurrentFlag
    type: boolean
    required: true
    default: true
    description: Current version flag

relationships:
  - name: hasBusinessUnits
    target: BusinessUnit
    cardinality: one-to-many
    required: false
    inverse: belongsToLegalEntity
    description: BUs in this entity

  - name: hasRepresentatives
    target: EntityRepresentative
    cardinality: one-to-many
    required: false
    inverse: representsEntity
    description: Legal representatives

  - name: hasEmployees
    target: Employee
    cardinality: one-to-many
    required: false
    inverse: employedByEntity
    description: Employees

lifecycle:
  states: [draft, active, inactive, dissolved]
  initial: draft
  terminal: [dissolved]
  transitions:
    - from: draft
      to: active
      trigger: activate
    - from: active
      to: inactive
      trigger: suspend
    - from: inactive
      to: active
      trigger: reactivate
    - from: [active, inactive]
      to: dissolved
      trigger: dissolve

actions:
  - name: create
    description: Create legal entity
    requiredFields: [code, nameVi, typeId, countryCode, effectiveStartDate]

  - name: activate
    description: Activate entity
    triggersTransition: activate

  - name: addRepresentative
    description: Add legal representative
    affectsRelationships: [hasRepresentatives]

  - name: dissolve
    description: Dissolve entity
    triggersTransition: dissolve

policies:
  - name: uniqueCode
    type: validation
    rule: "Entity code must be globally unique"

  - name: uniqueTaxId
    type: validation
    rule: "Tax ID must be unique per country"

  - name: representativeRequired
    type: business
    rule: "Active entity must have at least one legal representative"

  - name: dataRetention
    type: retention
    rule: "Entity records retained 10 years after dissolution"
---

# LegalEntity

## Overview

A **LegalEntity** represents a legally registered organization - company, branch, or subsidiary. This is the fundamental unit for statutory compliance, tax reporting, and employment contracts. All [[Employee]]s are employed by exactly one Legal Entity.

```mermaid
mindmap
  root((LegalEntity))
    Types
      COMPANY
      BRANCH
      SUBSIDIARY
      REPRESENTATIVE
    Contains
      BusinessUnit
      Employee
      Representative
    Compliance
      taxId
      countryCode
      Licenses
```

## Business Context

### Key Stakeholders
- **Legal/Compliance**: Manages registrations, licenses
- **Finance**: Uses for statutory reporting, tax filing
- **HR**: Creates employees within entities
- **Executive**: Org structure decisions

### Business Processes
This entity is central to:
- **Employee Contracts**: Every contract tied to Legal Entity
- **Statutory Reporting**: Tax, social insurance by entity
- **Payroll**: Runs per Legal Entity
- **M&A**: Entity creation/dissolution for acquisitions

### Business Value
Legal Entity is the foundational structure for all legal, tax, and compliance requirements. Accurate entity data ensures proper statutory reporting and liability management.

## Attributes Guide

### Identification
- **code**: Internal identifier. Format: VNG_CORP, ZALOPAY. Used in all systems.
- **nameVi / nameEn**: Official registered names. nameVi is per business license.
- **taxId**: Mã số thuế. Critical for tax filings, invoicing.

### Classification
- **typeId**: Legal structure per Vietnam Enterprise Law:
  - *COMPANY*: Công ty mẹ - independent company
  - *BRANCH*: Chi nhánh - branch office
  - *SUBSIDIARY*: Công ty con - separate legal entity
  - *REPRESENTATIVE*: Văn phòng đại diện - no business activity

### Hierarchy
- **parentId**: Parent entity for group structure.
- **path**: Materialized path for efficient hierarchy queries. Format: /VNG/ZALO/ZALOPAY

### Jurisdiction
- **countryCode**: Determines applicable labor law, tax rules, currency.

## Relationships Explained

```mermaid
erDiagram
    LEGAL_ENTITY ||--o{ BUSINESS_UNIT : "hasBusinessUnits"
    LEGAL_ENTITY ||--o{ EMPLOYEE : "hasEmployees"
    LEGAL_ENTITY ||--o{ ENTITY_REPRESENTATIVE : "hasRepresentatives"
    LEGAL_ENTITY }o--o| LEGAL_ENTITY : "parentOf"
```

### Organizational Structure
- **hasBusinessUnits** → [[BusinessUnit]]: Departments, teams within entity. BU = operational structure, Entity = legal structure.

### People
- **hasEmployees** → [[Employee]]: All employment contracts under this entity. Determines tax jurisdiction, labor law applicability.
- **hasRepresentatives** → [[EntityRepresentative]]: Người đại diện theo pháp luật. Required for legal transactions.

## Lifecycle & Workflows

### State Definitions

| State | Business Meaning | System Impact |
|-------|------------------|---------------|
| **draft** | Being established | Cannot employ, no transactions |
| **active** | Fully operational | Normal operations |
| **inactive** | Temporarily suspended | Limited operations |
| **dissolved** | Legally closed | Read-only, archived |

### State Diagram

```mermaid
stateDiagram-v2
    [*] --> draft: create
    
    draft --> active: activate (license issued)
    
    active --> inactive: suspend
    inactive --> active: reactivate
    
    active --> dissolved: dissolve
    inactive --> dissolved: dissolve
    
    dissolved --> [*]
```

### Entity Dissolution Flow

```mermaid
flowchart TD
    A[Decision to Dissolve] --> B[Transfer/Terminate Employees]
    B --> C[Settle Liabilities]
    C --> D[Close Bank Accounts]
    D --> E[Deregister with Authorities]
    E --> F[Set Status = DISSOLVED]
    F --> G[Archive Records - 10 years]
```

## Actions & Operations

### create
**Who**: Legal/Compliance team  
**When**: New company, branch, subsidiary established  
**Required**: code, nameVi, typeId, countryCode, effectiveStartDate  
**Process**:
1. Legal entity registration complete
2. Create record in draft state
3. Add business license, representatives

### activate
**Who**: Legal/Compliance  
**When**: Business license issued, ready for operation  
**Process**:
1. Verify at least one representative
2. Verify business license on file
3. Transition to active

### addRepresentative
**Who**: Legal/Compliance  
**When**: Appointing/changing legal representative  
**Process**:
1. Create [[EntityRepresentative]] record
2. Link to Worker (person)
3. Set effective dates

### dissolve
**Who**: Legal/Compliance with executive approval  
**When**: Entity being closed  
**Process**:
1. Verify all employees terminated/transferred
2. Verify all liabilities settled
3. Transition to dissolved
4. Archive for retention period

## Business Rules

### Data Integrity

#### Unique Code (uniqueCode)
**Rule**: Entity code globally unique.  
**Reason**: Master identifier for integrations.  
**Violation**: System prevents save.

#### Unique Tax ID (uniqueTaxId)
**Rule**: Tax ID unique within country.  
**Reason**: Tax authority requirement.  
**Violation**: System prevents save.

### Compliance

#### Representative Required (representativeRequired)
**Rule**: Active entity must have legal representative.  
**Reason**: Vietnam Enterprise Law requirement.  
**Violation**: Warning shown; cannot sign contracts.

#### Data Retention (dataRetention)
**Rule**: Records retained 10+ years after dissolution.  
**Reason**: Tax audit, legal requirements.  
**Implementation**: Archived, accessible to Legal only.

## Examples

### Example 1: Parent Company
- **code**: VNG_CORP
- **nameVi**: Công ty Cổ phần VNG
- **typeId**: COMPANY
- **countryCode**: VN
- **parentId**: null (top level)

### Example 2: Subsidiary
- **code**: ZALOPAY
- **nameVi**: Công ty TNHH ZaloPay
- **typeId**: SUBSIDIARY
- **parentId**: VNG_CORP

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[BusinessUnit]] | hasBusinessUnits | Operational units |
| [[Employee]] | hasEmployees | Employment records |
| [[EntityRepresentative]] | hasRepresentatives | Legal reps |
