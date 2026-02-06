---
entity: WorkerRelationship
domain: core-hr
version: "1.0.0"
status: draft
owner: core-team
tags: [person, relationship, entity]

classification:
  type: ENTITY
  category: person

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated UUID

  - name: workerId
    type: string
    required: true
    description: FK to Worker (subject)

  - name: relatedWorkerId
    type: string
    required: false
    description: Related worker if in system

  - name: fullName
    type: string
    required: false
    description: Name if not linked

  - name: relationCode
    type: enum
    required: true
    values: [FATHER, MOTHER, SPOUSE, CHILD, SIBLING, OTHER]
    description: Relationship type

  - name: isEmergency
    type: boolean
    required: true
    default: false
    description: Emergency contact

  - name: dependencyFlag
    type: boolean
    required: true
    default: false
    description: Financial dependent

  - name: beneficiaryFlag
    type: boolean
    required: true
    default: false
    description: Insurance beneficiary

  - name: phoneNumber
    type: string
    required: false
    description: Contact phone

  - name: effectiveStartDate
    type: date
    required: true
    description: Effective start

  - name: effectiveEndDate
    type: date
    required: false
    description: Effective end

relationships:
  - name: belongsToWorker
    target: Worker
    cardinality: many-to-one
    required: true
    inverse: hasRelationships
    description: The worker

  - name: relatedTo
    target: Worker
    cardinality: many-to-one
    required: false
    description: Related person if in system

lifecycle:
  states: [active, inactive]
  initial: active

actions:
  - name: add
    description: Add relationship
    requiredFields: [workerId, relationCode, effectiveStartDate]

  - name: update
    description: Update relationship details

policies:
  - name: emergencyRequired
    type: business
    rule: "At least one emergency contact required"
---

# WorkerRelationship

## Overview

**WorkerRelationship** records family and personal relationships of a [[Worker]] - spouse, parents, children, emergency contacts, and beneficiaries. Used for tax dependents, emergency contact lists, and insurance beneficiaries.

```mermaid
mindmap
  root((WorkerRelationship))
    Relation Types
      FATHER
      MOTHER
      SPOUSE
      CHILD
      SIBLING
    Flags
      Emergency Contact
      Dependent["Tax Dependent"]
      Beneficiary
```

## Business Context

### Key Stakeholders
- **Employee**: Maintains family info
- **HR**: Emergency contact management
- **Payroll**: Tax dependent calculations
- **Benefits**: Beneficiary management

### Business Processes
- **Emergency Response**: Contact notification
- **Tax Calculation**: Dependent deductions (Vietnam PIT)
- **Benefits Enrollment**: Beneficiary designation
- **Insurance**: Coverage for dependents

### Business Value
Accurate family data enables proper tax treatment, emergency response, and benefits administration.

## Attributes Guide

### Relationship
- **relationCode**: Type of relationship:
  - *FATHER/MOTHER*: Parents
  - *SPOUSE*: Husband/Wife
  - *CHILD*: Son/Daughter
  - *SIBLING*: Brother/Sister
  - *OTHER*: Other relatives

### Related Person
- **relatedWorkerId**: If person is also an employee, link to their Worker record.
- **fullName**: If not in system, store name directly.

### Flags
- **isEmergency**: Include in emergency contact list.
- **dependencyFlag**: Tax dependent (reduces PIT).
- **beneficiaryFlag**: Insurance beneficiary.

## Relationships Explained

```mermaid
erDiagram
    WORKER_RELATIONSHIP }o--|| WORKER : "belongsToWorker"
    WORKER_RELATIONSHIP }o--o| WORKER : "relatedTo"
```

### Subject
- **belongsToWorker** → [[Worker]]: The employee.

### Related Person
- **relatedTo** → [[Worker]]: If related person is also in system.

## Lifecycle & Workflows

| State | Meaning |
|-------|---------|
| **active** | Current relationship |
| **inactive** | Ended (divorce, death) |

## Actions & Operations

### add
**Who**: Employee (self-service), HR  
**Required**: workerId, relationCode, effectiveStartDate

### update
**Who**: Employee, HR  
**When**: Details change

## Business Rules

#### Emergency Required (emergencyRequired)
**Rule**: Employee should have at least one emergency contact.

## Examples

### Example: Spouse
- **workerId**: WRK-00042
- **relationCode**: SPOUSE
- **fullName**: Nguyễn Thị B
- **isEmergency**: true
- **dependencyFlag**: false

### Example: Dependent Child
- **workerId**: WRK-00042
- **relationCode**: CHILD
- **dependencyFlag**: true (for PIT deduction)

## Related Entities

| Entity | Relationship |
|--------|--------------|
| [[Worker]] | belongsToWorker |
