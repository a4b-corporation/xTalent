---
entity: BenefitPlan
domain: total-rewards
version: "1.0.0"
status: draft
owner: benefits-team
tags: [benefits, plan, core]

classification:
  type: AGGREGATE_ROOT
  category: benefits

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
    description: Plan code
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Plan name
    constraints:
      max: 255

  - name: description
    type: string
    required: false
    description: Plan description

  - name: planCategory
    type: enum
    required: true
    values: [MEDICAL, DENTAL, VISION, LIFE, DISABILITY, RETIREMENT, PERK, WELLNESS]
    description: Benefit category

  - name: providerName
    type: string
    required: false
    description: Insurance/benefit provider
    constraints:
      max: 255

  - name: premiumType
    type: enum
    required: false
    values: [EMPLOYEE, EMPLOYER, SHARED]
    description: Who pays the premium

  - name: currency
    type: string
    required: false
    description: ISO 4217 currency
    constraints:
      max: 3

  - name: effectiveStartDate
    type: date
    required: true
    description: Plan start date

  - name: effectiveEndDate
    type: date
    required: false
    description: Plan end date

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Active status

relationships:
  - name: hasOptions
    target: BenefitOption
    cardinality: one-to-many
    required: false
    inverse: belongsToPlan
    description: Coverage options in this plan

  - name: hasEligibilityProfiles
    target: EligibilityProfile
    cardinality: many-to-many
    required: false
    description: Eligibility rules for this plan

  - name: sponsoredBy
    target: LegalEntity
    cardinality: many-to-one
    required: false
    description: Sponsoring legal entity

lifecycle:
  states: [draft, active, suspended, terminated]
  initial: draft
  terminal: [terminated]
  transitions:
    - from: draft
      to: active
      trigger: activate
    - from: active
      to: suspended
      trigger: suspend
    - from: suspended
      to: active
      trigger: reactivate
    - from: [active, suspended]
      to: terminated
      trigger: terminate

actions:
  - name: create
    description: Create benefit plan
    requiredFields: [code, name, planCategory, effectiveStartDate]

  - name: addOption
    description: Add coverage option
    affectsRelationships: [hasOptions]

  - name: setEligibility
    description: Set eligibility profiles
    affectsRelationships: [hasEligibilityProfiles]

policies:
  - name: uniqueCode
    type: validation
    rule: "Plan code must be unique"

  - name: hasOptionsWhenActive
    type: validation
    rule: "Active plan must have at least one option"
---

# BenefitPlan

## Overview

```mermaid
mindmap
  root((BenefitPlan))
    Categories
      MEDICAL
      DENTAL
      VISION
      LIFE
      RETIREMENT
      WELLNESS
    Premium
      EMPLOYEE
      EMPLOYER
      SHARED
    Contains
      BenefitOptions
      EligibilityProfiles
```

**BenefitPlan** định nghĩa gói phúc lợi cho nhân viên - bảo hiểm y tế, nha khoa, hưu trí. Mỗi plan có nhiều options và eligibility rules.

## Business Context

### Key Stakeholders
- **Benefits Team**: Design and manage plans
- **HR Admin**: Enrollment management
- **Employees**: Enroll and use benefits

### Business Processes
- **Open Enrollment**: Annual enrollment period
- **Life Events**: Mid-year changes
- **Claims Processing**: Review và process claims

## Relationships Explained

```mermaid
erDiagram
    BENEFIT_PLAN ||--o{ BENEFIT_OPTION : "hasOptions"
    BENEFIT_PLAN }o--o{ ELIGIBILITY_PROFILE : "hasEligibilityProfiles"
    BENEFIT_PLAN }o--|| LEGAL_ENTITY : "sponsoredBy"
```

## Examples

### Example 1: Medical Insurance
- **code**: MED_PREMIUM
- **name**: Premium Medical Plan
- **planCategory**: MEDICAL
- **providerName**: Bảo Việt
- **premiumType**: SHARED

### Example 2: Wellness Program
- **code**: WELLNESS_VNG
- **name**: VNG Wellness Program
- **planCategory**: WELLNESS
- **premiumType**: EMPLOYER

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[BenefitOption]] | hasOptions | Coverage choices |
| [[EligibilityProfile]] | hasEligibilityProfiles | Who can enroll |
