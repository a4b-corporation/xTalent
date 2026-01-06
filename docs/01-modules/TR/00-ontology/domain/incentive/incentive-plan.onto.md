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

  - name: hasEligibilityProfile
    target: EligibilityProfile
    cardinality: many-to-one
    required: false
    description: Eligibility profile

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
    - from: suspended
      to: active
      trigger: reactivate
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

  - name: setEligibility
    description: Set eligibility profile
    affectsRelationships: [hasEligibilityProfile]

policies:
  - name: uniqueCode
    type: validation
    rule: "Plan code must be unique"

  - name: validFormula
    type: validation
    rule: "Formula must be valid when plan is active"
---

# IncentivePlan

## Overview

**IncentivePlan** định nghĩa chương trình thưởng - bonus hàng năm (STI), equity grants (LTI), commission. Mỗi plan có formula tính và eligibility rules.

```mermaid
mindmap
  root((IncentivePlan))
    Types
      STI["STI (Short-term Incentive)"]
      LTI["LTI (Long-term Incentive)"]
      COMMISSION
    Equity Types
      RSU
      Stock Options
      SAR
    Contains
      IncentiveCycle
      VestingSchedule
```

## Business Context

### Key Stakeholders
- **Compensation Team**: Design incentive structures
- **Managers**: Allocate bonuses, recommend awards
- **Finance**: Budget and accruals
- **Employees**: Receive incentives

### Incentive Types Explained

| Type | Description | Frequency | Example |
|------|-------------|-----------|---------|
| **STI** | Short-term Incentive | Annual/Quarterly | Performance bonus |
| **LTI** | Long-term Incentive | Multi-year | RSU, Stock options |
| **COMMISSION** | Sales incentive | Per sale/Monthly | Sales commission |

### Equity Instruments (LTI)

| Instrument | Value | Vesting | Use Case |
|------------|-------|---------|----------|
| **RSU** | Actual shares | Time-based | Retention, key hires |
| **Stock Options** | Right to buy | Time + performance | Startups |
| **SAR** | Stock Appreciation Rights | Time-based | Cash alternative |

### Business Value
IncentivePlan cho phép design flexible variable pay programs, link pay to performance, và retain key talent.

## Attributes Guide

### Core Identity
- **code**: Mã duy nhất. Format: ANNUAL_BONUS, RSU_PROGRAM
- **name**: Tên hiển thị. VD: "Annual Performance Bonus"
- **description**: Mô tả chi tiết program

### Plan Type
- **bonusType**: STI, LTI, or COMMISSION
- **equityFlag**: true nếu là equity plan

### Formula Definition (formulaJson)

**Performance Bonus Formula:**
```json
{
  "type": "MULTIPLICATION",
  "factors": [
    {"source": "baseSalary"},
    {"source": "targetPct", "default": 0.15},
    {"source": "performanceMultiplier", "range": [0, 2]}
  ],
  "cap": {"basis": "target", "multiplier": 2}
}
```

**Commission Formula:**
```json
{
  "type": "TIERED",
  "tiers": [
    {"from": 0, "to": 100, "rate": 0.05},
    {"from": 100, "to": 150, "rate": 0.08},
    {"from": 150, "to": null, "rate": 0.12}
  ],
  "basis": "quota_achievement_pct"
}
```

## Relationships Explained

```mermaid
erDiagram
    INCENTIVE_PLAN ||--o{ INCENTIVE_CYCLE : "hasCycles"
    INCENTIVE_PLAN }o--o| ELIGIBILITY_PROFILE : "hasEligibilityProfile"
    INCENTIVE_CYCLE ||--o{ INCENTIVE_AWARD : "hasAwards"
```

### IncentiveCycle
- **hasCycles** → IncentiveCycle: Award cycles (annual, quarterly)

### EligibilityProfile
- **hasEligibilityProfile** → [[EligibilityProfile]]: Who is eligible

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> draft: create
    draft --> active: activate
    active --> suspended: suspend
    suspended --> active: reactivate
    active --> closed: close
    suspended --> closed: close
```

| State | Meaning |
|-------|---------|
| **draft** | Đang design |
| **active** | Đang chạy |
| **suspended** | Tạm ngưng (budget issues) |
| **closed** | Kết thúc program |

### Annual Bonus Flow

```mermaid
flowchart LR
    A[Plan Active] --> B[Create Cycle]
    B --> C[Performance Period]
    C --> D[Rating Collection]
    D --> E[Calculate Awards]
    E --> F[Approval]
    F --> G[Payout]
```

## Actions & Operations

### create
**Who**: Compensation Team  
**Required**: code, name, bonusType, effectiveStartDate

### createCycle
**Who**: Compensation Team  
**When**: Start new performance period  
**Creates**: IncentiveCycle

### setEligibility
**Who**: Compensation Team  
**Purpose**: Link eligibility profile

## Business Rules

#### Unique Code (uniqueCode)
**Rule**: Plan code phải duy nhất.

#### Valid Formula (validFormula)
**Rule**: Formula phải valid khi plan active.

## Examples

### Example 1: Annual Performance Bonus (STI)
```yaml
code: ANNUAL_BONUS
name: "Annual Performance Bonus"
bonusType: STI
equityFlag: false
formulaJson:
  type: MULTIPLICATION
  factors:
    - source: baseSalary
    - source: targetPct
      default: 0.15
    - source: performanceMultiplier
      range: [0, 2]
effectiveStartDate: "2026-01-01"
```

### Example 2: RSU Grant Program (LTI)
```yaml
code: RSU_PROGRAM
name: "RSU Grant Program"
bonusType: LTI
equityFlag: true
formulaJson:
  grantType: RSU
  vestingSchedule: "4Y_1Y_CLIFF"  # 4 years, 1 year cliff
  vestingPct:
    year1: 25
    year2: 25
    year3: 25
    year4: 25
effectiveStartDate: "2026-01-01"
```

### Example 3: Sales Commission
```yaml
code: SALES_COMMISSION
name: "Sales Commission Plan"
bonusType: COMMISSION
equityFlag: false
formulaJson:
  type: TIERED
  tiers:
    - { from: 0, to: 100, rate: 0.05 }
    - { from: 100, to: 150, rate: 0.08 }
    - { from: 150, to: null, rate: 0.12 }
  basis: quota_achievement_pct
effectiveStartDate: "2026-01-01"
```

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| IncentiveCycle | hasCycles | Award cycles |
| [[EligibilityProfile]] | hasEligibilityProfile | Eligibility rules |
| IncentiveAward | indirect | Individual awards |
