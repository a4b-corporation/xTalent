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

**SalaryBasis** định nghĩa cách tính lương cơ bản cho nhân viên - theo giờ, tháng, hoặc năm. Là AGGREGATE_ROOT của compensation structure, mỗi basis chứa các [[PayComponent]] và calculation rules.

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
    Contains
      PayComponents
      CalculationRules
```

## Business Context

### Key Stakeholders
- **Compensation Team**: Define và maintain salary structures
- **HR Admin**: Assign basis to employees
- **Payroll**: Use for calculation
- **Finance**: Budget planning

### Pay Frequency Explained

| Frequency | Description | Use Case |
|-----------|-------------|----------|
| **HOURLY** | Tính theo giờ | Factory workers, part-time |
| **DAILY** | Tính theo ngày | Contractors, seasonal |
| **WEEKLY** | Trả hàng tuần | Some US companies |
| **BIWEEKLY** | Trả 2 tuần/lần | US standard |
| **SEMIMONTHLY** | Trả 2 lần/tháng | 15th và 30th |
| **MONTHLY** | Trả hàng tháng | VN standard |
| **ANNUAL** | Lương năm | Executive packages |

### Business Value
SalaryBasis cho phép định nghĩa cấu trúc lương chuẩn, reuse cho nhiều employees, và maintain version history.

## Attributes Guide

### Core Identity
- **code**: Mã duy nhất. Format: LUONG_THANG_VN, HOURLY_US
- **name**: Tên hiển thị. VD: "Lương tháng chuẩn Việt Nam"

### Pay Configuration
- **frequency**: Chu kỳ trả lương
- **currency**: Mã tiền tệ (VND, USD, SGD)
- **allowComponents**: Có cho phép thêm components không?

### Metadata (JSON)
Extended configuration:
```json
{
  "prorationMethod": "CALENDAR_DAYS",
  "workingDaysPerMonth": 22,
  "standardHoursPerDay": 8,
  "overtimeEnabled": true
}
```

## Relationships Explained

```mermaid
erDiagram
    SALARY_BASIS ||--o{ COMPENSATION_STRUCTURE : "hasComponents"
    COMPENSATION_STRUCTURE }o--|| PAY_COMPONENT : "references"
    SALARY_BASIS ||--o{ BASIS_RULE_BINDING : "hasBasisRules"
    BASIS_RULE_BINDING }o--|| CALCULATION_RULE : "uses"
```

### CompensationStructure
- **hasComponents** → CompensationStructure: Links to pay components. VD: Lương cơ bản + Phụ cấp

### BasisRuleBinding
- **hasBasisRules** → BasisRuleBinding: Calculation rules (tax, SI, proration)

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> draft: create
    draft --> active: activate
    active --> deprecated: deprecate
    deprecated --> [*]
```

| State | Meaning |
|-------|---------|
| **draft** | Đang setup, chưa assign được |
| **active** | Có thể assign cho employees |
| **deprecated** | Không dùng cho new assignments |

### Assignment Flow

```mermaid
flowchart LR
    A[Create Basis] --> B[Add Components]
    B --> C[Add Rules]
    C --> D[Activate]
    D --> E[Assign to Employees]
```

## Actions & Operations

### create
**Who**: Compensation Team  
**Required**: code, name, frequency, currency, effectiveStartDate

### activate
**Who**: Compensation Team  
**When**: Ready for use

### addComponent
**Who**: Compensation Team  
**Purpose**: Thêm pay component vào basis  
**Required**: componentId

## Business Rules

#### Unique Code (uniqueCode)
**Rule**: Salary basis code phải duy nhất.

#### Valid Currency (validCurrency)
**Rule**: Currency phải là ISO 4217 code hợp lệ.

#### Edit Access (editAccess)
**Rule**: Chỉ Compensation Admin được edit.

## Examples

### Example 1: Vietnam Monthly Salary
```yaml
code: LUONG_THANG_VN
name: "Lương tháng chuẩn Việt Nam"
frequency: MONTHLY
currency: VND
allowComponents: true
metadata:
  prorationMethod: WORKING_DAYS
  workingDaysPerMonth: 22
  standardHoursPerDay: 8
```

### Example 2: US Hourly Rate
```yaml
code: HOURLY_US
name: "US Hourly Rate"
frequency: HOURLY
currency: USD
allowComponents: false  # Simple hourly, no extras
metadata:
  overtimeEnabled: true
  overtimeThreshold: 40  # hours/week
```

### Example 3: Singapore Monthly
```yaml
code: MONTHLY_SG
name: "Singapore Monthly Salary"
frequency: MONTHLY
currency: SGD
allowComponents: true
```

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[PayComponent]] | via CompensationStructure | Components in this basis |
| [[CalculationRule]] | via BasisRuleBinding | Global rules applied |
| [[Employee]] | indirect | Employees using this basis |
