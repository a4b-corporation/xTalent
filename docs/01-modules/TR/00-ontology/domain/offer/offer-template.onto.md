---
entity: OfferTemplate
domain: total-rewards
version: "1.0.0"
status: draft
owner: compensation-team
tags: [offer, template, recruiting]

classification:
  type: AGGREGATE_ROOT
  category: offer

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
    description: Template code
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Template name
    constraints:
      max: 200

  - name: description
    type: string
    required: false
    description: Template description

  - name: versionNo
    type: number
    required: true
    default: 1
    description: Version number

  - name: componentsJson
    type: object
    required: true
    description: Pay components, benefits, equity in offer

  - name: effectiveStartDate
    type: date
    required: true
    description: Start date

  - name: effectiveEndDate
    type: date
    required: false
    description: End date

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Active status

relationships:
  - name: includesComponents
    target: PayComponent
    cardinality: many-to-many
    required: false
    description: Pay components in template

  - name: includesBenefits
    target: BenefitPlan
    cardinality: many-to-many
    required: false
    description: Benefit plans in template

lifecycle:
  states: [draft, active, deprecated]
  initial: draft
  transitions:
    - from: draft
      to: active
      trigger: activate
    - from: active
      to: deprecated
      trigger: deprecate

actions:
  - name: create
    description: Create offer template
    requiredFields: [code, name, componentsJson, effectiveStartDate]

  - name: createNewVersion
    description: Create new version
    affectsAttributes: [versionNo, componentsJson]

policies:
  - name: uniqueCodeVersion
    type: validation
    rule: "Code + version must be unique"

  - name: hasComponents
    type: validation
    rule: "Template must have at least one component"
---

# OfferTemplate

## Overview

```mermaid
mindmap
  root((OfferTemplate))
    Components
      Base Salary
      Allowances
      Sign-on Bonus
    Benefits
      Medical
      Retirement
    Equity
      RSU
      Stock Options
```

**OfferTemplate** định nghĩa khuôn mẫu cho offer letter - bao gồm salary components, benefits, equity. Dùng cho new hires, promotions, retention.

## Business Context

### Key Stakeholders
- **Recruiting Team**: Create offers
- **Compensation Team**: Define templates
- **Hiring Managers**: Customize offers

### Business Processes
- **Offer Creation**: Generate from template
- **Offer Approval**: Review and approve
- **Offer Acceptance**: Track decisions

## Attributes Guide

### componentsJson Structure
```json
{
  "compensation": [
    {"componentCode": "BASIC_SALARY", "amount": null},
    {"componentCode": "SIGN_ON_BONUS", "amount": 10000000}
  ],
  "benefits": [
    {"planCode": "MED_PREMIUM", "optionCode": "EMPLOYEE_FAMILY"}
  ],
  "equity": {
    "grantType": "RSU",
    "units": null,
    "vestingSchedule": "4Y_1Y_CLIFF"
  }
}
```

## Examples

### Example 1: Senior Engineer Template
- **code**: SR_ENGINEER_VN
- **name**: Senior Engineer Offer - Vietnam
- **components**: Basic, Transport Allowance, Sign-on
- **benefits**: Medical Premium, Wellness

### Example 2: Director Template
- **code**: DIRECTOR_VN
- **name**: Director Offer - Vietnam
- **components**: Basic, Car Allowance, Sign-on, Annual Bonus
- **equity**: RSU grant

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[PayComponent]] | includesComponents | Pay elements |
| [[BenefitPlan]] | includesBenefits | Benefit packages |
