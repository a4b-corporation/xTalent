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

  - name: hasEligibilityProfile
    target: EligibilityProfile
    cardinality: many-to-one
    required: false
    description: Eligibility profile

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

  - name: updateGuidelines
    description: Update merit matrix/guidelines
    affectsAttributes: [guidelineJson]

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

**CompensationPlan** định nghĩa chính sách điều chỉnh lương - merit review, promotion, market adjustment. Là AGGREGATE_ROOT của compensation policy, có guidelines và eligibility rules.

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
    Outputs
      Salary Changes
      Budget Tracking
```

## Business Context

### Key Stakeholders
- **Compensation Team**: Design review policies
- **Managers**: Submit recommendations
- **HR Business Partners**: Review and approve
- **Finance**: Budget control

### Plan Types Explained

| Type | Description | Frequency | Trigger |
|------|-------------|-----------|---------|
| **MERIT** | Performance-based increase | Annual | Performance cycle |
| **PROMOTION** | Level/grade change | As needed | Promotion decision |
| **MARKET_ADJUSTMENT** | Market alignment | Annual/Bi-annual | Market survey |
| **NEW_HIRE** | New employee offer | Per hire | Offer creation |
| **EQUITY_CORRECTION** | Fix pay inequities | As needed | Pay equity audit |
| **AD_HOC** | One-off adjustments | As needed | Special circumstances |

### Merit Review Process

```mermaid
flowchart LR
    A[Create Cycle] --> B[Allocate Budget]
    B --> C[Manager Proposals]
    C --> D[HRBP Review]
    D --> E[Approval Chain]
    E --> F[Apply Changes]
```

### Business Value
CompensationPlan ensures consistent review processes, guides salary decisions within budget, và provides audit trail.

## Attributes Guide

### Core Identity
- **code**: Mã duy nhất. Format: MERIT_REVIEW_2026, PROMOTION_POLICY
- **name**: Tên hiển thị. VD: "Annual Merit Review 2026"
- **planType**: Type of review (MERIT, PROMOTION, etc.)

### Guidelines (guidelineJson)

**Merit Matrix:**
```json
{
  "matrix": {
    "E": {"below": 0, "at": 2, "above": 4, "far_above": 6},
    "M": {"below": 0, "at": 4, "above": 6, "far_above": 8},
    "N": {"below": 0, "at": 6, "above": 8, "far_above": 10}
  },
  "budgetPct": 5.0,
  "maxIncreasePct": 15,
  "minRatingEligible": "M"
}
```

Legend:
- E = Exceeds compa-ratio (>110%)
- M = At midpoint (90-110%)
- N = Below midpoint (<90%)

**Promotion Guidelines:**
```json
{
  "minRange": 5,
  "maxRange": 15,
  "targetAtMid": true,
  "requiresApproval": "HRBP"
}
```

### Eligibility (eligibilityRuleJson)
```json
{
  "type": "AND",
  "conditions": [
    {"field": "employmentStatus", "op": "eq", "value": "ACTIVE"},
    {"field": "tenure", "op": "gte", "value": 90},
    {"field": "hasPerformanceRating", "op": "eq", "value": true}
  ]
}
```

## Relationships Explained

```mermaid
erDiagram
    COMPENSATION_PLAN ||--o{ COMPENSATION_CYCLE : "hasCycles"
    COMPENSATION_PLAN }o--o| ELIGIBILITY_PROFILE : "hasEligibilityProfile"
    COMPENSATION_CYCLE ||--o{ SALARY_PROPOSAL : "hasProposals"
```

### CompensationCycle
- **hasCycles** → CompensationCycle: Specific review periods (2026 Q1, etc.)

### EligibilityProfile
- **hasEligibilityProfile** → [[EligibilityProfile]]: Who is eligible

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> draft: create
    draft --> active: activate
    active --> inactive: deactivate
```

| State | Meaning |
|-------|---------|
| **draft** | Đang design |
| **active** | Có thể create cycles |
| **inactive** | Không dùng nữa |

### Cycle States

```mermaid
stateDiagram-v2
    [*] --> planning: createCycle
    planning --> open: openForProposals
    open --> review: closeProposals
    review --> approved: approveAll
    approved --> completed: apply
```

## Actions & Operations

### create
**Who**: Compensation Team  
**Required**: code, name, planType, effectiveStartDate

### createCycle
**Who**: Compensation Team  
**When**: Start new review period  
**Creates**: CompensationCycle

### updateGuidelines
**Who**: Compensation Team  
**When**: Policy changes  
**Affects**: guidelineJson

## Business Rules

#### Unique Code (uniqueCode)
**Rule**: Plan code phải duy nhất.

#### Has Guidelines (hasGuidelines)
**Rule**: MERIT và PROMOTION plans cần guidelines.  
**Reason**: Đảm bảo consistent decisions.

## Examples

### Example 1: Annual Merit Review 2026
```yaml
code: MERIT_REVIEW_2026
name: "Annual Merit Review 2026"
planType: MERIT
guidelineJson:
  matrix:
    E: { below: 0, at: 2, above: 4, far_above: 6 }
    M: { below: 0, at: 4, above: 6, far_above: 8 }
    N: { below: 0, at: 6, above: 8, far_above: 10 }
  budgetPct: 5.0
  maxIncreasePct: 15
  minRatingEligible: M
eligibilityRuleJson:
  type: AND
  conditions:
    - field: tenure
      op: gte
      value: 90
effectiveStartDate: "2026-01-01"
```

### Example 2: Promotion Policy
```yaml
code: PROMOTION_POLICY
name: "Promotion Salary Adjustment"
planType: PROMOTION
guidelineJson:
  oneGradeIncrease:
    minPct: 8
    maxPct: 15
    targetPosition: midpoint
  twoGradeIncrease:
    minPct: 15
    maxPct: 25
  requiresApproval: HRBP
effectiveStartDate: "2026-01-01"
```

### Example 3: Market Adjustment
```yaml
code: MARKET_ADJ_2026
name: "2026 Market Adjustment"
planType: MARKET_ADJUSTMENT
guidelineJson:
  targetCompaRatio: 100
  maxAdjustmentPct: 10
  priorityByGap: true
eligibilityRuleJson:
  conditions:
    - field: compaRatio
      op: lt
      value: 90
effectiveStartDate: "2026-04-01"
```

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| CompensationCycle | hasCycles | Review periods |
| [[EligibilityProfile]] | hasEligibilityProfile | Eligibility rules |
| SalaryProposal | indirect | Manager proposals |
