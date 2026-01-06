---
entity: EntityRepresentative
domain: core-hr
version: "1.0.0"
status: draft
owner: core-team
tags: [organization, representative, entity]

classification:
  type: ENTITY
  category: organization

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated UUID

  - name: legalEntityId
    type: string
    required: true
    description: FK to LegalEntity

  - name: repTypeCode
    type: enum
    required: true
    values: [LEGAL_REP, AUTH_REP, CEO, CFO]
    description: Representative type

  - name: workerId
    type: string
    required: true
    description: FK to Worker

  - name: documentId
    type: string
    required: false
    description: Authorization document

  - name: effectiveStartDate
    type: date
    required: true
    description: Effective start

  - name: effectiveEndDate
    type: date
    required: false
    description: Effective end

relationships:
  - name: representsEntity
    target: LegalEntity
    cardinality: many-to-one
    required: true
    inverse: hasRepresentatives
    description: Entity represented

  - name: isWorker
    target: Worker
    cardinality: many-to-one
    required: true
    description: The person

lifecycle:
  states: [active, inactive]
  initial: active
  transitions:
    - from: active
      to: inactive
      trigger: revoke

actions:
  - name: appoint
    description: Appoint representative
    requiredFields: [legalEntityId, repTypeCode, workerId, effectiveStartDate]

  - name: revoke
    description: Revoke representation
    triggersTransition: revoke

policies:
  - name: uniqueRepPerType
    type: validation
    rule: "One active rep per type per entity"

  - name: documentRequired
    type: business
    rule: "LEGAL_REP requires authorization document"
---

# EntityRepresentative

## Overview

An **EntityRepresentative** represents a person authorized to represent a [[LegalEntity]] - legal representative (Người đại diện theo pháp luật), authorized signatory, or executive role. Critical for contract signing authority and regulatory compliance.

```mermaid
mindmap
  root((EntityRepresentative))
    Types
      LEGAL_REP["Người đại diện pháp luật"]
      AUTH_REP["Người được ủy quyền"]
      CEO
      CFO
    Links
      LegalEntity
      Worker
```

## Business Context

### Key Stakeholders
- **Legal/Compliance**: Manages representatives
- **Executive**: Signing authority
- **Procurement**: Contract approval

### Business Processes
- **Contract Signing**: Authority verification
- **Regulatory Filings**: Representative disclosure
- **Corporate Governance**: Role assignments

### Business Value
Accurate representative tracking ensures valid contracts and regulatory compliance.

## Attributes Guide

### Identification
- **repTypeCode**: Representative role:
  - *LEGAL_REP*: Legal representative per Enterprise Law
  - *AUTH_REP*: Authorized signatory (delegated)
  - *CEO*: Chief Executive
  - *CFO*: Chief Financial

### Documentation
- **documentId**: Authorization/appointment document.
- **effectiveStartDate/EndDate**: Validity period.

## Relationships Explained

```mermaid
erDiagram
    ENTITY_REPRESENTATIVE }o--|| LEGAL_ENTITY : "representsEntity"
    ENTITY_REPRESENTATIVE }o--|| WORKER : "isWorker"
```

### Entity
- **representsEntity** → [[LegalEntity]]: The company represented.

### Person
- **isWorker** → [[Worker]]: The person acting as representative.

## Lifecycle & Workflows

| State | Meaning |
|-------|---------|
| **active** | Currently authorized |
| **inactive** | Authorization ended |

## Actions & Operations

### appoint
**Who**: Legal/Compliance with Board  
**Required**: legalEntityId, repTypeCode, workerId, effectiveStartDate

### revoke
**Who**: Legal/Compliance  
**When**: End of term, resignation, change

## Business Rules

#### One Per Type (uniqueRepPerType)
**Rule**: One active representative per type.

#### Document Required (documentRequired)
**Rule**: LEGAL_REP requires official document.

## Examples

### Example: Legal Representative
- **repTypeCode**: LEGAL_REP
- **legalEntityId**: VNG_CORP
- **workerId**: WRK-CEO
- **effectiveStartDate**: 2020-01-01

## Related Entities

| Entity | Relationship |
|--------|--------------|
| [[LegalEntity]] | representsEntity |
| [[Worker]] | isWorker |
