---
entity: PayRange
domain: total-rewards
version: "1.0.0"
status: draft
owner: compensation-team
tags: [job-architecture, pay-range, market]

classification:
  type: ENTITY
  category: job-architecture

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated UUID

  - name: gradeVersionId
    type: string
    required: true
    description: FK to Grade version

  - name: scopeType
    type: enum
    required: true
    values: [GLOBAL, LEGAL_ENTITY, BUSINESS_UNIT, POSITION]
    description: Scope of applicability

  - name: scopeUuid
    type: string
    required: true
    description: ID of scope entity

  - name: currency
    type: string
    required: true
    description: ISO 4217 currency code
    constraints:
      max: 3

  - name: minAmount
    type: number
    required: true
    description: Minimum salary

  - name: midAmount
    type: number
    required: true
    description: Midpoint salary (market rate)

  - name: maxAmount
    type: number
    required: true
    description: Maximum salary

  - name: rangeSpreadPct
    type: number
    required: false
    description: Range spread percentage = (max-min)/mid*100

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
  - name: belongsToGrade
    target: Grade
    cardinality: many-to-one
    required: true
    inverse: hasPayRanges
    description: Grade this range belongs to

lifecycle:
  states: [draft, active, archived]
  initial: draft
  transitions:
    - from: draft
      to: active
      trigger: activate
    - from: active
      to: archived
      trigger: archive

actions:
  - name: create
    description: Create pay range
    requiredFields: [gradeVersionId, scopeType, scopeUuid, currency, minAmount, midAmount, maxAmount, effectiveStartDate]

  - name: updateAmounts
    description: Update salary amounts
    affectsAttributes: [minAmount, midAmount, maxAmount, rangeSpreadPct]

policies:
  - name: validAmounts
    type: validation
    rule: "min < mid < max"
    expression: "minAmount < midAmount AND midAmount < maxAmount"

  - name: validSpread
    type: business
    rule: "Range spread typically between 40-60%"
---

# PayRange

## Overview

**PayRange** định nghĩa khung lương (min/mid/max) cho mỗi [[Grade]]. Có thể scope theo global, legal entity, business unit, hoặc position cụ thể.

```mermaid
mindmap
  root((PayRange))
    Amounts
      minAmount
      midAmount
      maxAmount
    Scope
      GLOBAL
      LEGAL_ENTITY
      BUSINESS_UNIT
      POSITION
    Metrics
      Compa-ratio
      Range Penetration
      Range Spread
```

## Business Context

### Key Stakeholders
- **Compensation Team**: Define market rates
- **HR Business Partner**: Salary decisions
- **Finance**: Budget planning
- **Managers**: Offer/promotion decisions

### Salary Positions Explained

```
         ┌───────────────────────────────────────┐
Max ─────┤                                       │ 120%
         │          Above Range (Red Circle)     │
         ├───────────────────────────────────────┤ 110%
         │          Top Performer Zone           │
Mid ─────┼───────────────────────────────────────┤ 100% (Market Rate)
         │          Standard Zone                │
         ├───────────────────────────────────────┤ 90%
         │          Development Zone             │
Min ─────┤          New/Learning                 │ 80%
         └───────────────────────────────────────┘
```

### Compa-ratio Formula
```
Compa-ratio = (Actual Salary / Midpoint) × 100%
```

| Compa-ratio | Interpretation |
|-------------|----------------|
| < 80% | Below range (needs increase) |
| 80-90% | Approaching midpoint |
| 90-110% | At market (healthy) |
| 110-120% | Above midpoint (high performer) |
| > 120% | Above range (red circle) |

### Range Spread
```
Range Spread = (Max - Min) / Mid × 100%
```
- Typical: 40-60% for professional roles
- Narrower (30-40%): Entry-level, operational
- Wider (50-80%): Senior, executive

### Business Value
PayRange cho phép market-aligned compensation, consistent salary decisions, và visibility into position within range.

## Attributes Guide

### Core Identity
- **gradeVersionId**: Link đến Grade version (SCD-2 aware)

### Scope Configuration
- **scopeType**: Level áp dụng:
  - *GLOBAL*: All entities, default
  - *LEGAL_ENTITY*: Specific entity (VNG-VN, VNG-SG)
  - *BUSINESS_UNIT*: Specific BU
  - *POSITION*: Specific position override
- **scopeUuid**: ID của scope entity

### Salary Amounts
- **minAmount**: Mức lương tối thiểu (entry, learning)
- **midAmount**: Mức lương trung bình (market rate, target)
- **maxAmount**: Mức lương tối đa (top performer)
- **rangeSpreadPct**: Calculated spread

## Relationships Explained

```mermaid
erDiagram
    GRADE ||--o{ PAY_RANGE : "hasPayRanges"
    PAY_RANGE }o--|| LEGAL_ENTITY : "scopes"
```

### Grade
- **belongsToGrade** → [[Grade]]: Parent grade (links to specific version)

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> draft: create
    draft --> active: activate
    active --> archived: archive
```

### Annual Review Flow

```mermaid
flowchart LR
    A[Market Survey] --> B[Analyze Data]
    B --> C[Propose New Ranges]
    C --> D[Approval]
    D --> E[Create New PayRange]
    E --> F[Archive Old PayRange]
```

## Actions & Operations

### create
**Who**: Compensation Team  
**Required**: gradeVersionId, scopeType, scopeUuid, currency, minAmount, midAmount, maxAmount, effectiveStartDate

### updateAmounts
**Who**: Compensation Team  
**When**: Annual market adjustment  
**Affects**: minAmount, midAmount, maxAmount, rangeSpreadPct

## Business Rules

#### Valid Amounts (validAmounts)
**Rule**: min < mid < max.  
**Reason**: Logical progression.

#### Valid Spread (validSpread)
**Rule**: Range spread typically 40-60%.  
**Warning**: Will flag if outside normal range.

## Examples

### Example 1: G3 Senior Engineer - Vietnam
```yaml
gradeVersionId: "grade-g3-v2"
scopeType: LEGAL_ENTITY
scopeUuid: "vng-vn"
currency: VND
minAmount: 25000000
midAmount: 35000000
maxAmount: 45000000
rangeSpreadPct: 57
effectiveStartDate: "2026-01-01"
```

### Example 2: G3 Senior Engineer - Singapore
```yaml
gradeVersionId: "grade-g3-v2"
scopeType: LEGAL_ENTITY
scopeUuid: "vng-sg"
currency: SGD
minAmount: 6000
midAmount: 8000
maxAmount: 10000
rangeSpreadPct: 50
effectiveStartDate: "2026-01-01"
```

### Example 3: Position-Specific Override
```yaml
gradeVersionId: "grade-g3-v2"
scopeType: POSITION
scopeUuid: "position-tech-lead-abc"
currency: VND
minAmount: 30000000  # Higher than standard
midAmount: 42000000
maxAmount: 54000000
effectiveStartDate: "2026-01-01"
```

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[Grade]] | belongsToGrade | Parent grade |
| [[LegalEntity]] | scope | Scoping entity |
| [[Employee]] | indirect | Salary comparison |
