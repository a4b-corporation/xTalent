---
entity: IncentivePlan
domain: total-rewards
version: "1.0.0"
status: draft
owner: compensation-team
tags: [incentive, bonus, variable-pay]

classification:
  type: AGGREGATE_ROOT
  category: incentive

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

  - name: bonusType
    type: enum
    required: true
    values: [STI, LTI, COMMISSION]
    description: Short-term, Long-term, or Commission

  - name: equityFlag
    type: boolean
    required: true
    default: false
    description: Is this an equity plan

  - name: formulaJson
    type: object
    required: false
    description: Calculation formula

  - name: eligibilityRuleJson
    type: object
    required: false
    description: Eligibility criteria

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
    target: IncentiveCycle
    cardinality: one-to-many
    required: false
    inverse: belongsToPlan
    description: Incentive cycles

lifecycle:
  states: [draft, active, suspended, closed]
  initial: draft
  terminal: [closed]
  transitions:
    - from: draft
      to: active
      trigger: activate
    - from: active
      to: suspended
      trigger: suspend
    - from: [active, suspended]
      to: closed
      trigger: close

actions:
  - name: create
    description: Create incentive plan
    requiredFields: [code, name, bonusType, effectiveStartDate]

  - name: createCycle
    description: Create new cycle for plan
    affectsRelationships: [hasCycles]

policies:
  - name: uniqueCode
    type: validation
    rule: "Plan code must be unique"
---

# IncentivePlan

## Overview

```mermaid
mindmap
  root((IncentivePlan))
    Types
      STI["STI (Short-term)"]
      LTI["LTI (Long-term)"]
      COMMISSION
    Equity
      RSU
      Stock Options
      SAR
    Contains
      IncentiveCycle
      VestingSchedule
```

**IncentivePlan** định nghĩa chương trình thưởng - bonus hàng năm, commission, equity grants. Mỗi plan có formula tính và eligibility rules.

## Business Context

### Key Stakeholders
- **Compensation Team**: Design incentive structures
- **Managers**: Allocate bonuses
- **Employees**: Receive incentives

### Business Processes
- **Goal Setting**: Define targets
- **Performance Review**: Evaluate achievement
- **Payout Processing**: Calculate and pay

## Examples

### Example 1: Annual Performance Bonus
- **code**: ANNUAL_BONUS
- **name**: Annual Performance Bonus
- **bonusType**: STI
- **equityFlag**: false
- **formula**: `baseSalary * targetPct * performanceMultiplier`

### Example 2: RSU Grant Program
- **code**: RSU_PROGRAM
- **name**: RSU Grant Program
- **bonusType**: LTI
- **equityFlag**: true

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[IncentiveCycle]] | hasCycles | Award cycles |
