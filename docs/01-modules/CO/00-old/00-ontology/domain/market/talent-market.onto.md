---
entity: TalentMarket
domain: core-hr
version: "1.0.0"
status: draft
owner: core-team
tags: [market, talent, core]

classification:
  type: AGGREGATE_ROOT
  category: market

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
    description: Market code

  - name: nameVi
    type: string
    required: true
    description: Vietnamese name

  - name: nameEn
    type: string
    required: true
    description: English name

  - name: currencyCode
    type: string
    required: true
    description: Currency (VND, USD)

  - name: parentId
    type: string
    required: false
    description: Parent market

  - name: isCumulativeSeniority
    type: boolean
    required: true
    default: false
    description: Cumulative seniority across entities

  - name: status
    type: enum
    required: true
    values: [ACTIVE, INACTIVE]
    description: Market status

  - name: effectiveStartDate
    type: date
    required: true
    description: Effective start

relationships:
  - name: hasOpportunities
    target: Opportunity
    cardinality: one-to-many
    required: false
    inverse: inMarket
    description: Opportunities in market

  - name: hasSubMarkets
    target: TalentMarket
    cardinality: one-to-many
    required: false
    description: Child markets

lifecycle:
  states: [active, inactive]
  initial: active
  transitions:
    - from: active
      to: inactive
      trigger: deactivate

actions:
  - name: create
    description: Create talent market
    requiredFields: [code, nameVi, nameEn, currencyCode, effectiveStartDate]

policies:
  - name: uniqueCode
    type: validation
    rule: "Market code must be unique"
---

# TalentMarket

## Overview

A **TalentMarket** represents a labor market segment - typically geographic or business-focused - where internal mobility occurs. Markets group [[Opportunity]]s and enable localized talent strategies. They may have hierarchical structure (APAC → Vietnam → HCM).

```mermaid
mindmap
  root((TalentMarket))
    Hierarchy
      Region["APAC"]
      Country["Vietnam"]
      City["HCM/HN"]
    Properties
      Currency
      Seniority Rules
    Contains
      Opportunities
```

## Business Context

### Key Stakeholders
- **Talent Management**: Defines market structure
- **HR Policy**: Sets market-specific rules
- **Employee**: Browses opportunities by market
- **Analytics**: Reports by market

### Business Processes
This entity is central to:
- **Internal Mobility**: Filtering opportunities
- **Compensation**: Market-based pay
- **Seniority**: Cross-entity tenure rules

### Business Value
Market segmentation enables targeted talent strategies while maintaining organizational coherence.

## Attributes Guide

### Identification
- **code**: Unique identifier. Format: MKT-VN, MKT-APAC.
- **nameVi/nameEn**: Bilingual names.
- **currencyCode**: Primary currency for this market.

### Hierarchy
- **parentId**: Parent market for grouping.

### Seniority Rules
- **isCumulativeSeniority**: If true, tenure counts across all entities in market.

## Relationships Explained

```mermaid
erDiagram
    TALENT_MARKET ||--o{ OPPORTUNITY : "hasOpportunities"
    TALENT_MARKET ||--o{ TALENT_MARKET : "hasSubMarkets"
```

### Opportunities
- **hasOpportunities** → [[Opportunity]]: Opportunities posted in this market.

### Hierarchy
- **hasSubMarkets** → [[TalentMarket]]: Child markets.

## Lifecycle & Workflows

| State | Meaning |
|-------|---------|
| **active** | Market operating |
| **inactive** | Market closed |

## Actions & Operations

### create
**Who**: Talent Management  
**Required**: code, nameVi, nameEn, currencyCode, effectiveStartDate

## Business Rules

#### Unique Code (uniqueCode)
**Rule**: Market code unique.

## Examples

### Example 1: Vietnam Market
- **code**: MKT-VN
- **nameVi**: Thị trường Việt Nam
- **nameEn**: Vietnam Market
- **currencyCode**: VND

## Related Entities

| Entity | Relationship |
|--------|--------------|
| [[Opportunity]] | hasOpportunities |
