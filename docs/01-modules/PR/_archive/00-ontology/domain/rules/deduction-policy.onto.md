---
entity: DeductionPolicy
domain: payroll
version: "1.0.0"
status: draft
owner: payroll-team
tags: [rules, policy]

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated unique identifier (UUID)

  - name: code
    type: string
    required: true
    unique: true
    description: Mã policy
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Tên policy
    constraints:
      max: 100

  - name: description
    type: string
    required: false
    description: Mô tả chi tiết

  - name: deductionType
    type: enum
    required: true
    values: [VOLUNTARY, MANDATORY, COURT_ORDER, BENEFIT, LOAN, OTHER]
    description: Loại khấu trừ

  - name: priorityOrder
    type: number
    required: true
    description: Thứ tự ưu tiên (thấp = cao hơn)

  - name: maxPercentage
    type: number
    required: false
    description: Giới hạn % tối đa của net pay

  - name: maxAmount
    type: number
    required: false
    description: Giới hạn số tiền tối đa

  - name: deductionJson
    type: object
    required: false
    description: Rules chi tiết cho deduction logic

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Policy có active không

  - name: metadata
    type: object
    required: false
    description: Custom metadata

relationships:
  - name: includedInProfiles
    target: PayProfile
    cardinality: many-to-many
    required: false
    through: PayProfilePolicy
    inverse: hasPolicies
    description: Profiles chứa policy này

  - name: appliedToElements
    target: PayElement
    cardinality: one-to-many
    required: false
    inverse: hasDeductionPolicy
    description: Deduction elements sử dụng policy

lifecycle:
  states: [draft, active, inactive]
  initial: draft
  terminal: []
  transitions:
    - from: draft
      to: active
      trigger: activate
    - from: active
      to: inactive
      trigger: deactivate
    - from: inactive
      to: active
      trigger: reactivate

actions:
  - name: create
    description: Tạo mới deduction policy
    requiredFields: [code, name, deductionType, priorityOrder]

  - name: update
    description: Cập nhật policy
    affectsAttributes: [name, description, maxPercentage, maxAmount, deductionJson]

  - name: activate
    description: Kích hoạt policy
    triggersTransition: activate

  - name: deactivate
    description: Tạm ngừng policy
    triggersTransition: deactivate

policies:
  - name: uniqueCode
    type: validation
    rule: "Mã policy phải duy nhất"

  - name: validLimits
    type: validation
    rule: "maxPercentage phải từ 0 đến 100"
    expression: "maxPercentage IS NULL OR (maxPercentage >= 0 AND maxPercentage <= 100)"

  - name: editAccess
    type: access
    rule: "Payroll Admin và Payroll Director có quyền chỉnh sửa"
---

# DeductionPolicy

## Overview

```mermaid
mindmap
  root((DeductionPolicy))
    Types
      VOLUNTARY
      MANDATORY
      COURT_ORDER
      BENEFIT
      LOAN
    Limits
      maxPercentage
      maxAmount
      priorityOrder
```

**DeductionPolicy** (Chính sách khấu trừ) định nghĩa các quy tắc và giới hạn cho việc khấu trừ lương, bao gồm thứ tự ưu tiên, giới hạn tối đa, và các business rules cụ thể.

## Business Context

### Key Stakeholders
- **Payroll Directors**: Define policies theo company và legal requirements
- **Payroll Administrators**: Configure và assign policies
- **HR/Benefits**: Policies cho benefit deductions
- **Legal/Compliance**: Ensure garnishment policies comply with law

### Business Processes
- **Deduction Ordering**: Xác định thứ tự khấu trừ
- **Limit Enforcement**: Đảm bảo không vượt quá legal limits
- **Garnishment Processing**: Handle court-ordered deductions
- **Loan Repayment**: Employee loan deductions

### Business Value
Deduction policies đảm bảo compliant và consistent deduction processing, protect employee minimum wage rights, và proper prioritization of competing deductions.

## Attributes Guide

### Classification
- **deductionType**: 
  - *VOLUNTARY*: Employee elects (401k, charity)
  - *MANDATORY*: Required by policy (union dues, parking)
  - *COURT_ORDER*: Garnishments, child support
  - *BENEFIT*: Benefit plan contributions
  - *LOAN*: Employee loan repayment
  - *OTHER*: Other deductions

### Ordering & Limits
- **priorityOrder**: Lower = higher priority. Statutory deductions typically have lowest numbers.
- **maxPercentage**: Max % of disposable earnings (important for garnishments)
- **maxAmount**: Max absolute amount per pay period

### Calculation Logic
- **deductionJson**: Complex rules
  ```json
  {
    "type": "progressive",
    "tiers": [
      {"upTo": 1000000, "rate": 0},
      {"upTo": 5000000, "rate": 0.10},
      {"above": 5000000, "rate": 0.15}
    ]
  }
  ```

## Relationships Explained

```mermaid
erDiagram
    DEDUCTION_POLICY }o--o{ PAY_PROFILE : "includedInProfiles"
    DEDUCTION_POLICY ||--o{ PAY_ELEMENT : "appliedToElements"
```

### Profile Inclusion
- **includedInProfiles** → [[PayProfile]]: Policies included in payroll profiles

### Element Application
- **appliedToElements** → [[PayElement]]: Deduction elements using this policy for limits/rules

## Examples

### Example 1: Court-Ordered Garnishment
- **code**: GARNISHMENT_COURT
- **name**: Court-Ordered Wage Garnishment
- **deductionType**: COURT_ORDER
- **priorityOrder**: 1 (highest priority)
- **maxPercentage**: 25 (25% of disposable earnings)
- **Note**: Legal limit per federal/state law

### Example 2: Voluntary 401k
- **code**: 401K_VOLUNTARY
- **name**: 401(k) Voluntary Contribution
- **deductionType**: VOLUNTARY
- **priorityOrder**: 50
- **maxPercentage**: 100 (IRS annual limit applies separately)

### Example 3: Employee Loan Repayment
- **code**: LOAN_REPAYMENT
- **name**: Employee Loan Repayment
- **deductionType**: LOAN
- **priorityOrder**: 80
- **maxPercentage**: 15 (company policy limit)

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[PayProfile]] | includedIn (M:N) | Profiles using policy |
| [[PayElement]] | appliedTo (1:N) | Deduction elements |
