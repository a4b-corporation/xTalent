---
entity: CompensationPlan
domain: total-rewards
version: "1.0.0"
status: draft
owner: compensation-team
tags: [policy, compensation, review]

classification:
  type: AGGREGATE_ROOT
  category: policy

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
      max: 200

  - name: description
    type: string
    required: false
    description: Plan description

  - name: planType
    type: enum
    required: true
    values: [MERIT, PROMOTION, MARKET_ADJUSTMENT, NEW_HIRE, EQUITY_CORRECTION, AD_HOC]
    description: Type of compensation review

  - name: eligibilityRuleJson
    type: object
    required: false
    description: Who is eligible

  - name: guidelineJson
    type: object
    required: false
    description: Merit matrices, guidelines, approval thresholds

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
  - name: hasCycles
    target: CompensationCycle
    cardinality: one-to-many
    required: false
    inverse: belongsToPlan
    description: Review cycles

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

actions:
  - name: create
    description: Create compensation plan
    requiredFields: [code, name, planType, effectiveStartDate]

  - name: createCycle
    description: Create new review cycle
    affectsRelationships: [hasCycles]

policies:
  - name: uniqueCode
    type: validation
    rule: "Plan code must be unique"

  - name: hasGuidelines
    type: business
    rule: "MERIT and PROMOTION plans should have guidelines"
---

# CompensationPlan

## Overview

```mermaid
mindmap
  root((CompensationPlan))
    Types
      MERIT
      PROMOTION
      MARKET_ADJUSTMENT
      NEW_HIRE
      EQUITY_CORRECTION
      AD_HOC
    Contains
      Cycles
      Guidelines
      Eligibility
```

**CompensationPlan** định nghĩa chính sách điều chỉnh lương - merit review, promotion, market adjustment. Có guidelines và eligibility rules.

## Business Context

### Key Stakeholders
- **Compensation Team**: Design review policies
- **Managers**: Submit recommendations
- **HR Business Partners**: Approve adjustments

### Business Processes
- **Annual Review**: Yearly merit increases
- **Promotion Processing**: Salary adjustments for promotions
- **Market Correction**: Address pay gaps

## Attributes Guide

### Plan Types
| Type | Description | Frequency |
|------|-------------|-----------|
| **MERIT** | Performance-based increase | Annual |
| **PROMOTION** | Level/grade change | As needed |
| **MARKET_ADJUSTMENT** | Market alignment | Annual/Bi-annual |
| **NEW_HIRE** | New employee offer | On hire |
| **EQUITY_CORRECTION** | Fix pay inequities | As needed |
| **AD_HOC** | One-off adjustments | As needed |

## Examples

### Example 1: Annual Merit Review
- **code**: MERIT_REVIEW
- **name**: Annual Merit Review
- **planType**: MERIT
- **guidelineJson**: Merit matrix with performance ratings

### Example 2: Promotion Policy
- **code**: PROMOTION_POLICY
- **name**: Promotion Salary Adjustment
- **planType**: PROMOTION

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[CompensationCycle]] | hasCycles | Review periods |
