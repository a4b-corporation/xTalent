---
entity: CalculationRule
domain: total-rewards
version: "1.0.0"
status: draft
owner: compensation-team
tags: [calculation, rule, core]

classification:
  type: AGGREGATE_ROOT
  category: calculation

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
    description: Unique rule code
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Rule name
    constraints:
      max: 200

  - name: ruleCategory
    type: enum
    required: true
    values: [TAX, SOCIAL_INSURANCE, PRORATION, OVERTIME, ROUNDING, FOREX, ANNUALIZATION]
    description: Rule category

  - name: ruleType
    type: enum
    required: true
    values: [FORMULA, LOOKUP_TABLE, CONDITIONAL, RATE_TABLE, PROGRESSIVE]
    description: Calculation logic type

  - name: countryCode
    type: string
    required: false
    description: ISO 3166-1 country code (null = global)
    constraints:
      max: 2

  - name: jurisdiction
    type: string
    required: false
    description: State/Province if applicable
    constraints:
      max: 50

  - name: formulaJson
    type: object
    required: true
    description: Calculation logic/data

  - name: description
    type: string
    required: false
    description: Rule description

  - name: legalReference
    type: string
    required: false
    description: Legal citation (e.g., Article 107, Labor Code 2019)

  - name: effectiveStartDate
    type: date
    required: true
    description: Start date

  - name: effectiveEndDate
    type: date
    required: false
    description: End date

  - name: versionNumber
    type: number
    required: true
    default: 1
    description: SCD-2 version

  - name: isCurrentVersion
    type: boolean
    required: true
    default: true
    description: Current version flag

relationships:
  - name: appliedToComponents
    target: ComponentRuleBinding
    cardinality: one-to-many
    required: false
    inverse: usesRule
    description: Components using this rule

  - name: appliedToBases
    target: BasisRuleBinding
    cardinality: one-to-many
    required: false
    inverse: usesRule
    description: Salary bases using this rule

  - name: belongsToCountry
    target: CountryConfig
    cardinality: many-to-one
    required: false
    inverse: hasRules
    description: Country configuration

lifecycle:
  states: [draft, active, superseded, expired]
  initial: draft
  terminal: [superseded, expired]
  transitions:
    - from: draft
      to: active
      trigger: publish
    - from: active
      to: superseded
      trigger: newVersion
    - from: active
      to: expired
      trigger: expire

actions:
  - name: create
    description: Create calculation rule
    requiredFields: [code, name, ruleCategory, ruleType, formulaJson, effectiveStartDate]

  - name: publish
    description: Publish for use
    triggersTransition: publish

  - name: createNewVersion
    description: Create new version
    requiredFields: [formulaJson, effectiveStartDate]
    triggersTransition: newVersion

policies:
  - name: uniqueCurrentCode
    type: validation
    rule: "Rule code must be unique among current versions"

  - name: validFormula
    type: validation
    rule: "formulaJson must be valid calculation definition"
---

# CalculationRule

## Overview

```mermaid
mindmap
  root((CalculationRule))
    Categories
      TAX
      SOCIAL_INSURANCE
      OVERTIME
      PRORATION
      ROUNDING
    Types
      FORMULA
      PROGRESSIVE
      RATE_TABLE
      LOOKUP_TABLE
    Scope
      Global
      Country
      Jurisdiction
```

**CalculationRule** định nghĩa các quy tắc tính toán - thuế, bảo hiểm xã hội, OT, proration. Versioned theo SCD-2 để track theo thời gian.

## Business Context

### Key Stakeholders
- **Compliance Team**: Define statutory rules
- **Payroll Team**: Apply rules in calculation
- **Legal**: Verify compliance

### Business Processes
- **Statutory Updates**: Update khi law changes
- **Payroll Processing**: Apply rules to calculate
- **Compliance Audit**: Verify correct application

## Attributes Guide

### Rule Categories

| Category | Description | Example |
|----------|-------------|---------|
| TAX | Income tax rules | VN_PIT_2025 |
| SOCIAL_INSURANCE | SI contribution rates | VN_BHXH_2025 |
| OVERTIME | OT multipliers | VN_OT_2019 |
| PRORATION | Partial period calculation | PRORATE_CALENDAR |
| ROUNDING | Amount rounding rules | ROUND_VND_1000 |

### Vietnam Examples

**VN_PIT_2025** (Progressive Tax):
```json
{
  "brackets": [
    {"from": 0, "to": 5000000, "rate": 0.05},
    {"from": 5000000, "to": 10000000, "rate": 0.10},
    {"from": 10000000, "to": 18000000, "rate": 0.15},
    {"from": 18000000, "to": 32000000, "rate": 0.20},
    {"from": 32000000, "to": 52000000, "rate": 0.25},
    {"from": 52000000, "to": 80000000, "rate": 0.30},
    {"from": 80000000, "to": null, "rate": 0.35}
  ],
  "personalDeduction": 11000000,
  "dependentDeduction": 4400000
}
```

**VN_BHXH_2025** (Social Insurance):
```json
{
  "employee": {
    "bhxh": 0.08, "bhyt": 0.015, "bhtn": 0.01
  },
  "employer": {
    "bhxh": 0.175, "bhyt": 0.03, "bhtn": 0.01
  },
  "ceiling": 36000000
}
```

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> draft: create
    draft --> active: publish
    active --> superseded: newVersion
    active --> expired: expire
    superseded --> [*]
    expired --> [*]
```

## Relationships Explained

```mermaid
erDiagram
    CALCULATION_RULE ||--o{ COMPONENT_RULE_BINDING : "appliedToComponents"
    CALCULATION_RULE ||--o{ BASIS_RULE_BINDING : "appliedToBases"
    CALCULATION_RULE }o--|| COUNTRY_CONFIG : "belongsToCountry"
```

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[PayComponent]] | via ComponentRuleBinding | Components using rule |
| [[SalaryBasis]] | via BasisRuleBinding | Bases using rule |
| [[CountryConfig]] | belongsToCountry | Country settings |
