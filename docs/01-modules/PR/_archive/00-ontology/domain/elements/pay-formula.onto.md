---
entity: PayFormula
domain: payroll
version: "1.0.0"
status: draft
owner: payroll-team
tags: [elements, calculation]

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
    description: Mã công thức
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Tên công thức
    constraints:
      max: 255

  - name: script
    type: string
    required: true
    description: Script/expression định nghĩa công thức (DSL hoặc SQL-like)

  - name: description
    type: string
    required: false
    description: Mô tả chi tiết về công thức và cách sử dụng

  - name: versionNo
    type: number
    required: true
    default: 1
    description: Version number của công thức

  - name: inputParameters
    type: array
    required: false
    description: Danh sách input parameters cần thiết

  - name: outputType
    type: enum
    required: true
    values: [AMOUNT, PERCENTAGE, HOURS, DAYS, BOOLEAN]
    default: AMOUNT
    description: Kiểu dữ liệu trả về

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Công thức có đang active không

  - name: metadata
    type: object
    required: false
    description: Custom metadata

relationships:
  - name: usedByElements
    target: PayElement
    cardinality: one-to-many
    required: false
    inverse: usesFormula
    description: Các pay elements sử dụng công thức này

  - name: dependsOnFormulas
    target: PayFormula
    cardinality: many-to-many
    required: false
    description: Các formulas khác mà formula này depend on

lifecycle:
  states: [draft, active, deprecated]
  initial: draft
  terminal: [deprecated]
  transitions:
    - from: draft
      to: active
      trigger: publish
      guard: "Script syntax is valid"
    - from: active
      to: deprecated
      trigger: deprecate
      guard: "New version available or no elements using"

actions:
  - name: create
    description: Tạo mới công thức
    requiredFields: [code, name, script, outputType]

  - name: update
    description: Cập nhật công thức (tạo version mới)
    affectsAttributes: [script, description, inputParameters]

  - name: publish
    description: Publish công thức để sử dụng
    triggersTransition: publish

  - name: deprecate
    description: Deprecate công thức cũ
    triggersTransition: deprecate

  - name: validate
    description: Validate syntax của script
    requiredFields: []

  - name: test
    description: Test công thức với sample data
    requiredFields: [testInputs]

  - name: createNewVersion
    description: Tạo version mới từ formula hiện tại
    requiredFields: []

policies:
  - name: uniqueCode
    type: validation
    rule: "Mã công thức phải duy nhất"
    expression: "UNIQUE(code)"

  - name: validScript
    type: validation
    rule: "Script phải có syntax hợp lệ và parseable"

  - name: noCircularDependency
    type: validation
    rule: "Không được có circular dependencies giữa formulas"

  - name: versionControl
    type: business
    rule: "Mỗi lần thay đổi script phải tạo version mới"

  - name: editAccess
    type: access
    rule: "Chỉ Payroll Technical Lead có quyền chỉnh sửa formulas"
---

# PayFormula

## Overview

```mermaid
mindmap
  root((PayFormula))
    Definition
      code
      name
      script
    Parameters
      inputParameters
      outputType
    Versioning
      versionNo
      isActive
    Types
      AMOUNT
      PERCENTAGE
      HOURS
```

**PayFormula** (Công thức tính lương) là entity chứa các công thức tính toán dùng chung trong payroll. Formulas được viết bằng DSL (Domain Specific Language) hoặc expression language, có thể reuse giữa nhiều pay elements.

## Business Context

### Key Stakeholders
- **Payroll Technical Lead**: Define và maintain formulas
- **Payroll Administrators**: Assign formulas cho pay elements
- **Compliance Team**: Review formulas đảm bảo đúng statutory requirements
- **QA Team**: Test formulas với various scenarios

### Business Processes
This entity is central to:
- **Calculation Standardization**: Centralize calculation logic cho reuse
- **Formula Versioning**: Track changes và maintain history
- **Compliance Updates**: Quick update khi statutory rates thay đổi
- **Testing & Validation**: Validate formulas trước khi deploy

### Business Value
PayFormula tách biệt calculation logic khỏi pay element definitions, cho phép thay đổi calculations mà không modify element structure, và đảm bảo consistency giữa các elements dùng cùng logic.

## Attributes Guide

### Identification
- **id**: UUID system-generated
- **code**: Business identifier (ví dụ: OT_CALC_150, BHXH_RATE_VN, PIT_PROGRESSIVE)

### Formula Definition
- **name**: Tên mô tả (ví dụ: "Overtime Calculation 150%")
- **script**: Expression/script chứa logic tính toán
  ```
  // Simple percentage
  base_amount * rate
  
  // Conditional
  IF(hours > 8, (hours - 8) * hourly_rate * 1.5, 0)
  
  // Progressive tax
  PROGRESSIVE_TAX(taxable_income, [[0, 5000000, 0.05], [5000000, 10000000, 0.10], ...])
  ```

- **inputParameters**: Array các parameters cần thiết:
  ```json
  [
    {"name": "base_amount", "type": "AMOUNT", "required": true},
    {"name": "rate", "type": "PERCENTAGE", "required": true}
  ]
  ```

- **outputType**: Kiểu giá trị trả về (AMOUNT, PERCENTAGE, etc.)

### Version Control
- **versionNo**: Số version, increment khi có changes
- **isActive**: True cho version đang được sử dụng

## Relationships Explained

```mermaid
erDiagram
    PAY_FORMULA ||--o{ PAY_ELEMENT : "usedByElements"
    PAY_FORMULA }o--o{ PAY_FORMULA : "dependsOnFormulas"
```

### Usage Tracking
- **usedByElements** → [[PayElement]]: Các pay elements sử dụng formula này. Quan trọng để track impact khi modify formula.

### Dependencies
- **dependsOnFormulas** → [[PayFormula]]: Formula dependencies. Ví dụ: PIT_CALC depends on TAXABLE_INCOME formula.

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> draft: create
    draft --> active: publish
    note right of draft: Script validated
    active --> deprecated: deprecate
    deprecated --> [*]
```

### State Definitions

| State | Business Meaning | System Impact |
|-------|------------------|---------------|
| **draft** | Đang develop/test | Không thể assign cho elements |
| **active** | Production-ready | Có thể sử dụng trong calculations |
| **deprecated** | Đã thay thế bởi version mới | Vẫn hoạt động cho assignments cũ |

### Transition Workflows

#### Draft → Active (publish)
**Trigger**: Formula đã test và approved
**Who**: Payroll Technical Lead
**Prerequisites**:
- Script syntax validated
- Test cases passed
**Process**:
1. Run syntax validation
2. Execute test cases
3. Get approval
4. Set isActive = true

#### Active → Deprecated (deprecate)
**Trigger**: Có version mới hoặc formula không còn dùng
**Who**: Payroll Technical Lead
**Effect**: Existing element assignments vẫn work, không cho assign mới

## Actions & Operations

### create
**Who**: Payroll Technical Lead
**Required**: code, name, script, outputType

### validate
**Who**: Payroll Technical Lead
**When**: Trước khi publish
**Process**:
1. Parse script syntax
2. Check input parameters resolved
3. Check no circular dependencies
4. Return validation result

### test
**Who**: Payroll Technical Lead, QA
**When**: Verify formula correctness
**Input**: testInputs object với sample values
**Output**: Calculated result để verify

### createNewVersion
**Who**: Payroll Technical Lead
**When**: Cần modify formula đang active
**Process**:
1. Clone current formula
2. Increment versionNo
3. New version ở draft status
4. Make changes to new version
5. Publish new version
6. Deprecate old version

## Business Rules

### Data Integrity

#### Unique Code (uniqueCode)
**Rule**: Mã formula phải duy nhất.
**Reason**: Identifier cho references.

#### Valid Script (validScript)
**Rule**: Script phải parseable và không có syntax errors.
**Implementation**: Syntax validation trước khi save.

### Business Constraints

#### No Circular Dependency (noCircularDependency)
**Rule**: Formula A không thể depend on formula B nếu B đã depend on A.
**Reason**: Avoid infinite loops trong calculation.
**Implementation**: Dependency graph validation.

#### Version Control (versionControl)
**Rule**: Script changes phải tạo version mới.
**Reason**: Maintain audit trail và không break existing calculations.
**Implementation**: Update tạo new version thay vì modify in-place.

## Examples

### Example 1: Simple Percentage Formula
- **code**: PERCENTAGE_OF_BASE
- **name**: Percentage of Base Amount
- **script**: `base_amount * rate`
- **inputParameters**: 
  ```json
  [
    {"name": "base_amount", "type": "AMOUNT"},
    {"name": "rate", "type": "PERCENTAGE"}
  ]
  ```
- **outputType**: AMOUNT
- **Usage**: Allowances as percentage of salary

### Example 2: Overtime Calculation
- **code**: OT_CALC
- **name**: Overtime Hours Calculation
- **script**: 
  ```
  hours * (basic_salary / working_days_per_month / 8) * multiplier
  ```
- **inputParameters**:
  ```json
  [
    {"name": "hours", "type": "HOURS"},
    {"name": "basic_salary", "type": "AMOUNT"},
    {"name": "working_days_per_month", "type": "DAYS", "default": 26},
    {"name": "multiplier", "type": "PERCENTAGE"}
  ]
  ```
- **outputType**: AMOUNT

### Example 3: Vietnam Social Insurance
- **code**: BHXH_CALC_VN
- **name**: Vietnam Social Insurance Calculation
- **script**:
  ```
  MIN(gross_insurable, ceiling_amount) * rate
  ```
- **inputParameters**:
  ```json
  [
    {"name": "gross_insurable", "type": "AMOUNT"},
    {"name": "ceiling_amount", "type": "AMOUNT", "default": 36000000},
    {"name": "rate", "type": "PERCENTAGE"}
  ]
  ```
- **outputType**: AMOUNT
- **Note**: ceiling_amount update hàng năm theo statutory

### Example 4: Progressive Tax (Complex)
- **code**: PIT_PROGRESSIVE_VN
- **name**: Vietnam PIT Progressive Calculation
- **script**:
  ```
  PROGRESSIVE_TAX(
    taxable_income,
    [
      [0, 5000000, 0.05],
      [5000000, 10000000, 0.10],
      [10000000, 18000000, 0.15],
      [18000000, 32000000, 0.20],
      [32000000, 52000000, 0.25],
      [52000000, 80000000, 0.30],
      [80000000, null, 0.35]
    ]
  )
  ```
- **inputParameters**:
  ```json
  [{"name": "taxable_income", "type": "AMOUNT"}]
  ```
- **outputType**: AMOUNT
- **dependsOn**: TAXABLE_INCOME_CALC

## Edge Cases & Exceptions

### Formula Update Impact
**Situation**: Formula được update, cần assess impact lên elements đang sử dụng.
**Handling**: 
1. Query usedByElements
2. Review affected elements
3. Create new version
4. Test với sample data
5. Gradually migrate elements

### Statutory Rate Changes
**Situation**: Luật thay đổi rates (ví dụ: BHXH ceiling tăng).
**Handling**:
1. Create new formula version với updated values
2. Set effective date
3. Publish new version
4. Elements tự động sử dụng version mới từ effective date

### Complex Multi-step Calculations
**Situation**: Calculation cần nhiều steps intermediate.
**Handling**: 
- Tách thành multiple formulas
- Định nghĩa dependencies
- Calculation engine execute theo order

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[PayElement]] | usedBy (1:N) | Elements sử dụng formula |
| [[PayFormula]] | dependsOn (M:N) | Formula dependencies |
