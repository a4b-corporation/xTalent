---
entity: PayComponent
domain: total-rewards
version: "1.0.0"
status: draft
owner: compensation-team
tags: [compensation, component, core]

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
    description: Unique component code
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Display name
    constraints:
      max: 200

  - name: componentType
    type: enum
    required: true
    values: [BASE, ALLOWANCE, BONUS, EQUITY, DEDUCTION, OVERTIME, COMMISSION]
    description: Classification của component

  - name: frequency
    type: enum
    required: true
    values: [HOURLY, DAILY, MONTHLY, QUARTERLY, ANNUAL, ONE_TIME]
    description: Payment frequency

  - name: taxable
    type: boolean
    required: true
    default: true
    description: Có chịu thuế không

  - name: prorated
    type: boolean
    required: true
    default: true
    description: Có proration không

  - name: defaultCurrency
    type: string
    required: false
    description: ISO 4217 currency code
    constraints:
      max: 3

  - name: calculationMethod
    type: enum
    required: false
    values: [FIXED, FORMULA, PERCENTAGE, HOURLY, DAILY, RATE_TABLE]
    description: Cách tính toán

  - name: taxTreatment
    type: enum
    required: false
    values: [FULLY_TAXABLE, TAX_EXEMPT, PARTIALLY_EXEMPT]
    description: Tax treatment

  - name: taxExemptThreshold
    type: number
    required: false
    description: Ngưỡng miễn thuế (e.g., 730,000 for lunch allowance)

  - name: isSubjectToSI
    type: boolean
    required: true
    default: false
    description: Có tính BHXH không

  - name: displayOrder
    type: number
    required: false
    description: Thứ tự hiển thị trên payslip

  - name: effectiveStartDate
    type: date
    required: true
    description: Ngày bắt đầu

  - name: effectiveEndDate
    type: date
    required: false
    description: Ngày kết thúc

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Trạng thái hoạt động

relationships:
  - name: includedInBases
    target: CompensationStructure
    cardinality: one-to-many
    required: false
    inverse: containsComponent
    description: Salary bases that include this component

  - name: hasComponentRules
    target: ComponentRuleBinding
    cardinality: one-to-many
    required: false
    inverse: appliedToComponent
    description: Calculation rules for this component

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
    description: Create new pay component
    requiredFields: [code, name, componentType, frequency, effectiveStartDate]

  - name: activate
    description: Activate for use
    triggersTransition: activate

  - name: configure
    description: Configure calculation settings
    affectsAttributes: [calculationMethod, taxTreatment, isSubjectToSI]

policies:
  - name: uniqueCode
    type: validation
    rule: "Pay component code must be unique"

  - name: taxThreshold
    type: validation
    rule: "Tax exempt threshold only for PARTIALLY_EXEMPT treatment"
---

# PayComponent

## Overview

```mermaid
mindmap
  root((PayComponent))
    Types
      BASE
      ALLOWANCE
      BONUS
      DEDUCTION
      OVERTIME
    Tax Treatment
      FULLY_TAXABLE
      TAX_EXEMPT
      PARTIALLY_EXEMPT
    Calculation
      FIXED
      FORMULA
      PERCENTAGE
```

**PayComponent** định nghĩa các thành phần của gói lương - lương cơ bản, phụ cấp, thưởng, khấu trừ. Mỗi component có rules về thuế và bảo hiểm.

## Business Context

### Key Stakeholders
- **Compensation Team**: Define components
- **Payroll**: Use for calculation
- **Finance**: GL mapping

### Business Processes
- **Compensation Planning**: Design pay structures
- **Offer Management**: Include in offer packages
- **Payroll Processing**: Calculate amounts

## Attributes Guide

### Component Types
| Type | Description | Impact | Example |
|------|-------------|--------|---------|
| **BASE** | Base salary | + Gross | Basic Salary |
| **ALLOWANCE** | Additions | + Gross | Lunch, Transport |
| **BONUS** | Variable pay | + Gross | Performance Bonus |
| **OVERTIME** | OT payments | + Gross | OT 150%, OT 200% |
| **DEDUCTION** | Subtractions | - Net | BHXH, Loans |

### Tax Treatment
- **FULLY_TAXABLE**: Toàn bộ chịu thuế TNCN
- **TAX_EXEMPT**: Miễn thuế hoàn toàn (e.g., meal allowance ≤ 730,000đ)
- **PARTIALLY_EXEMPT**: Miễn thuế đến ngưỡng

## Relationships Explained

```mermaid
erDiagram
    PAY_COMPONENT ||--o{ COMPENSATION_STRUCTURE : "includedInBases"
    PAY_COMPONENT ||--o{ COMPONENT_RULE_BINDING : "hasComponentRules"
    COMPONENT_RULE_BINDING }o--|| CALCULATION_RULE : "uses"
```

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> draft: create
    draft --> active: activate
    active --> deprecated: deprecate
```

## Examples

### Example 1: Basic Salary
- **code**: LUONG_CO_BAN
- **name**: Lương cơ bản
- **componentType**: BASE
- **frequency**: MONTHLY
- **taxable**: true
- **isSubjectToSI**: true

### Example 2: Lunch Allowance (Partially Exempt)
- **code**: PHU_CAP_AN_TRUA
- **name**: Phụ cấp ăn trưa
- **componentType**: ALLOWANCE
- **taxTreatment**: PARTIALLY_EXEMPT
- **taxExemptThreshold**: 730000

### Example 3: Overtime 150%
- **code**: LAM_THEM_150
- **name**: Làm thêm giờ 150%
- **componentType**: OVERTIME
- **calculationMethod**: FORMULA

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[SalaryBasis]] | via CompensationStructure | Bases using this component |
| [[CalculationRule]] | via ComponentRuleBinding | Calculation formulas |
| [[OfferTemplate]] | includes | Used in offer packages |
