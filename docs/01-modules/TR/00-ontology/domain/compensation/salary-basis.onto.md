---
entity: SalaryBasis
domain: total-rewards
version: "1.0.0"
status: draft
owner: compensation-team
tags: [compensation, structure, core]

classification:
  type: AGGREGATE_ROOT
  category: structure

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
    description: Unique salary basis code
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Display name
    constraints:
      max: 200

  - name: frequency
    type: enum
    required: true
    values: [HOURLY, DAILY, WEEKLY, BIWEEKLY, SEMIMONTHLY, MONTHLY, ANNUAL]
    description: Pay frequency

  - name: currency
    type: string
    required: true
    description: ISO 4217 currency code
    constraints:
      max: 3

  - name: allowComponents
    type: boolean
    required: true
    default: true
    description: Whether additional components can be added

  - name: metadata
    type: object
    required: false
    description: Additional configuration JSON

  - name: effectiveStartDate
    type: date
    required: true
    description: Version start date

  - name: effectiveEndDate
    type: date
    required: false
    description: Version end date (null = current)

relationships:
  - name: hasComponents
    target: CompensationStructure
    cardinality: one-to-many
    required: false
    inverse: belongsToBasis
    description: Pay components included in this basis

  - name: hasBasisRules
    target: BasisRuleBinding
    cardinality: one-to-many
    required: false
    inverse: appliedToBasis
    description: Calculation rules applied to this basis

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
    description: Create new salary basis
    requiredFields: [code, name, frequency, currency, effectiveStartDate]

  - name: activate
    description: Activate for use
    triggersTransition: activate

  - name: addComponent
    description: Add pay component to basis
    requiredFields: [componentId]
    affectsRelationships: [hasComponents]

policies:
  - name: uniqueCode
    type: validation
    rule: "Salary basis code must be unique"

  - name: validCurrency
    type: validation
    rule: "Currency must be valid ISO 4217 code"

  - name: editAccess
    type: access
    rule: "Compensation Admin can edit"
---

# SalaryBasis

## Overview

```mermaid
mindmap
  root((SalaryBasis))
    Frequency
      HOURLY
      MONTHLY
      ANNUAL
    Currency
      VND
      USD
      SGD
    Components
      PayComponents
      CalculationRules
```

**SalaryBasis** định nghĩa cách tính lương cơ bản cho nhân viên - theo giờ, tháng, hoặc năm. Mỗi basis chứa các pay components và rules tính toán.

## Business Context

### Key Stakeholders
- **Compensation Team**: Define và maintain salary structures
- **HR Admin**: Assign basis to employees
- **Payroll**: Use for calculation

### Business Processes
- **New Hire Setup**: Assign salary basis
- **Compensation Planning**: Define structures
- **Payroll Processing**: Calculate based on basis

## Attributes Guide

### Frequency
- **HOURLY**: Tính lương theo giờ làm việc
- **MONTHLY**: Lương cố định hàng tháng (phổ biến tại VN)
- **ANNUAL**: Lương theo năm (thường chia 12)

## Relationships Explained

- **hasComponents** → [[CompensationStructure]]: Links to pay components included in this basis
- **hasBasisRules** → [[BasisRuleBinding]]: Calculation rules (tax, SI, proration)

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> draft: create
    draft --> active: activate
    active --> deprecated: deprecate
    deprecated --> [*]
```

## Examples

### Example 1: Vietnam Monthly Salary
- **code**: LUONG_THANG_VN
- **name**: Lương tháng chuẩn Việt Nam
- **frequency**: MONTHLY
- **currency**: VND
- **allowComponents**: true

### Example 2: US Hourly
- **code**: HOURLY_US
- **name**: US Hourly Rate
- **frequency**: HOURLY
- **currency**: USD

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[PayComponent]] | via CompensationStructure | Components in this basis |
| [[BasisRuleBinding]] | hasBasisRules | Calculation rules |
| [[CalculationRule]] | via BasisRuleBinding | Global rules applied |
