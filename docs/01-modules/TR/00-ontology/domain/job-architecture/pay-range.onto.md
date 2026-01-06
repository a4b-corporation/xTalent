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
    Usage
      Market Pricing
      Compa-ratio
      Salary Review
```

**PayRange** định nghĩa khung lương (min/mid/max) cho mỗi grade. Có thể scope theo global, legal entity, hoặc position cụ thể.

## Business Context

### Key Stakeholders
- **Compensation Team**: Define market rates
- **HR Business Partner**: Salary decisions
- **Finance**: Budget planning

### Business Processes
- **Market Pricing**: Align với market data
- **Salary Review**: Determine increase amounts
- **Offer Management**: Set offer levels

## Attributes Guide

### Salary Positions
- **Min**: Entry-level or below market
- **Mid**: Market rate (target)
- **Max**: Top performer or above market

### Compa-ratio
```
Compa-ratio = Actual Salary / Midpoint × 100%
```
- < 80%: Below range
- 80-90%: Approaching midpoint
- 90-110%: At midpoint
- 110-120%: Above midpoint
- > 120%: Above range

## Examples

### Example 1: G3 Senior Engineer - Vietnam
- **grade**: G3
- **scopeType**: LEGAL_ENTITY
- **scope**: VNG Corporation
- **currency**: VND
- **minAmount**: 25,000,000
- **midAmount**: 35,000,000
- **maxAmount**: 45,000,000
- **rangeSpreadPct**: 57%

### Example 2: G3 Senior Engineer - Singapore
- **grade**: G3
- **scopeType**: LEGAL_ENTITY
- **scope**: VNG Singapore
- **currency**: SGD
- **minAmount**: 6,000
- **midAmount**: 8,000
- **maxAmount**: 10,000

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[Grade]] | belongsToGrade | Parent grade |
