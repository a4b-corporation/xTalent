---
entity: PayElement
domain: payroll
version: "1.0.0"
status: draft
owner: payroll-team
tags: [elements, core, scd2]

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
    description: Mã element
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Tên pay element
    constraints:
      max: 100

  - name: classification
    type: enum
    required: true
    values: [EARNING, DEDUCTION, TAX, EMPLOYER_CONTRIBUTION, INFORMATIONAL]
    description: Phân loại element

  - name: unit
    type: enum
    required: true
    values: [AMOUNT, HOURS, DAYS, PERCENTAGE, UNITS]
    default: AMOUNT
    description: Đơn vị tính của element

  - name: description
    type: string
    required: false
    description: Mô tả chi tiết về pay element

  - name: inputRequired
    type: boolean
    required: true
    default: false
    description: Element cần input value từ bên ngoài (timesheet, manual entry)

  - name: formulaJson
    type: object
    required: false
    description: JSON định nghĩa công thức tính (nếu có)

  - name: priorityOrder
    type: number
    required: false
    description: Thứ tự tính trong payroll run (thấp = tính trước)

  - name: taxableFlag
    type: boolean
    required: true
    default: true
    description: Element có chịu thuế không

  - name: preTaxFlag
    type: boolean
    required: true
    default: true
    description: Element tính trước thuế hay sau thuế

  - name: glAccountCode
    type: string
    required: false
    description: Default GL account code cho accounting
    constraints:
      max: 50

  - name: metadata
    type: object
    required: false
    description: Custom metadata

  # SCD-2 Fields
  - name: effectiveStartDate
    type: date
    required: true
    description: Ngày bắt đầu hiệu lực

  - name: effectiveEndDate
    type: date
    required: false
    description: Ngày kết thúc hiệu lực

  - name: isCurrentFlag
    type: boolean
    required: true
    default: true
    description: Version hiện tại

relationships:
  - name: hasStatutoryRule
    target: StatutoryRule
    cardinality: many-to-one
    required: false
    inverse: appliedToElements
    description: Statutory rule áp dụng cho element này

  - name: usesFormula
    target: PayFormula
    cardinality: many-to-one
    required: false
    inverse: usedByElements
    description: Reference đến shared formula

  - name: hasGLMappings
    target: GLMappingPolicy
    cardinality: one-to-many
    required: false
    inverse: belongsToElement
    description: GL mappings cho element

  - name: includesInBalances
    target: PayBalanceDefinition
    cardinality: many-to-many
    required: false
    through: BalanceElement
    description: Các balance definitions mà element contribute vào

  - name: belongsToProfiles
    target: PayProfile
    cardinality: many-to-many
    required: false
    through: PayProfileElement
    inverse: hasElements
    description: Profiles chứa element này

lifecycle:
  states: [draft, active, deprecated, archived]
  initial: draft
  terminal: [archived]
  transitions:
    - from: draft
      to: active
      trigger: activate
      guard: "Classification and unit configured"
    - from: active
      to: deprecated
      trigger: deprecate
    - from: deprecated
      to: archived
      trigger: archive
    - from: active
      to: archived
      trigger: archive
      guard: "No active payroll runs using this element"

actions:
  - name: create
    description: Tạo mới pay element
    requiredFields: [code, name, classification, unit, effectiveStartDate]

  - name: update
    description: Cập nhật element (SCD2 versioning)
    affectsAttributes: [name, description, formulaJson, priorityOrder, taxableFlag, preTaxFlag, glAccountCode]

  - name: activate
    description: Kích hoạt element
    triggersTransition: activate

  - name: deprecate
    description: Đánh dấu không còn recommend sử dụng
    triggersTransition: deprecate

  - name: archive
    description: Archive element
    triggersTransition: archive

  - name: assignToProfile
    description: Gán element vào profile
    requiredFields: [profileId]
    affectsRelationships: [belongsToProfiles]

  - name: setFormula
    description: Gán công thức tính cho element
    requiredFields: [formulaId]
    affectsRelationships: [usesFormula]
    affectsAttributes: [formulaJson]

policies:
  - name: uniqueCode
    type: validation
    rule: "Mã element phải duy nhất"
    expression: "UNIQUE(code)"

  - name: validClassification
    type: validation
    rule: "Classification phải là giá trị hợp lệ"
    expression: "classification IN ('EARNING', 'DEDUCTION', 'TAX', 'EMPLOYER_CONTRIBUTION', 'INFORMATIONAL')"

  - name: taxLogic
    type: business
    rule: "TAX elements phải có taxableFlag = false (chính nó là tax)"
    expression: "classification != 'TAX' OR taxableFlag = false"

  - name: earningPositive
    type: business
    rule: "EARNING elements contribute positive to gross pay"

  - name: deductionNegative
    type: business
    rule: "DEDUCTION elements reduce net pay"

  - name: editAccess
    type: access
    rule: "Payroll Admin có quyền chỉnh sửa elements"
---

# PayElement

## Overview

```mermaid
mindmap
  root((PayElement))
    Classification
      EARNING
      DEDUCTION
      TAX
      EMPLOYER_CONTRIBUTION
      INFORMATIONAL
    Configuration
      unit
      formulaJson
      priorityOrder
    Tax Treatment
      taxableFlag
      preTaxFlag
    Relationships
      StatutoryRule
      PayFormula
      GLMappingPolicy
      PayBalanceDefinition
      PayProfile
```

**PayElement** (Thành phần lương) là ontology trung tâm của module Payroll, đại diện cho các loại earning (thu nhập), deduction (khấu trừ), tax (thuế), và employer contributions. Mỗi element định nghĩa một concept trả lương cụ thể và cách thức tính toán.

## Business Context

### Key Stakeholders
- **Payroll Directors**: Define elements theo statutory requirements và company policy
- **Payroll Administrators**: Configure elements, assign formulas, set up mappings
- **Finance/Accounting**: Sử dụng GL mappings cho cost allocation và reporting
- **HR/Compensation**: Request new elements cho compensation packages mới

### Business Processes
This entity is central to:
- **Payroll Calculation**: Elements là building blocks của payroll calculation
- **Balance Tracking**: Elements contribute vào các balances (gross, net, YTD)
- **Tax Compliance**: Tax elements đảm bảo statutory compliance
- **Financial Reporting**: GL mappings enable proper cost accounting

### Business Value
PayElement là foundation của payroll system, chuẩn hóa cách thức define và calculate các thành phần lương, đảm bảo consistency và compliance.

## Attributes Guide

### Identification
- **id**: UUID system-generated
- **code**: Business identifier (ví dụ: BASIC_SALARY, OT_150, SOCIAL_INS_EE). Convention: UPPER_SNAKE_CASE.

### Classification & Type
- **classification**: Phân loại chính của element:
  - *EARNING*: Thu nhập (lương, phụ cấp, thưởng)
  - *DEDUCTION*: Khấu trừ từ lương employee (BHXH, thuế, vay)
  - *TAX*: Thuế thu nhập cá nhân
  - *EMPLOYER_CONTRIBUTION*: Đóng góp của employer (BHXH phần công ty)
  - *INFORMATIONAL*: Chỉ để hiển thị, không ảnh hưởng calculation

- **unit**: Đơn vị tính:
  - *AMOUNT*: Số tiền cố định (VND, USD)
  - *HOURS*: Giờ công (cho OT, hourly)
  - *DAYS*: Ngày công
  - *PERCENTAGE*: Phần trăm (của base salary, gross)
  - *UNITS*: Đơn vị arbitrary khác

### Calculation Configuration
- **inputRequired**: True nếu element cần data từ bên ngoài (timesheet hours, manual entry). False nếu tự calculate từ formula.

- **formulaJson**: JSON object định nghĩa công thức:
  ```json
  {
    "type": "percentage",
    "base": "BASIC_SALARY",
    "rate": 0.05
  }
  ```
  Hoặc reference đến [[PayFormula]] cho complex formulas.

- **priorityOrder**: Thứ tự tính (1 = tính đầu tiên). Quan trọng cho dependencies (ví dụ: tính gross trước tax).

### Tax Treatment
- **taxableFlag**: Element này có bị tính vào taxable income không?
  - EARNING: thường = true
  - DEDUCTION: có thể true hoặc false tùy loại
  - TAX: = false (chính nó là tax)

- **preTaxFlag**: Element tính trước hay sau tax?
  - Pre-tax deductions (BHXH, 401k) reduce taxable income
  - Post-tax deductions (union dues, garnishment) không ảnh hưởng taxable

### Accounting
- **glAccountCode**: Default GL account. Có thể override qua [[GLMappingPolicy]] cho complex scenarios.

## Relationships Explained

```mermaid
erDiagram
    PAYELEMENT ||--o| STATUTORY_RULE : "hasStatutoryRule"
    PAYELEMENT }o--o| PAY_FORMULA : "usesFormula"
    PAYELEMENT ||--o{ GL_MAPPING_POLICY : "hasGLMappings"
    PAYELEMENT }o--o{ PAY_BALANCE_DEFINITION : "includesInBalances"
    PAYELEMENT }o--o{ PAY_PROFILE : "belongsToProfiles"
```

### Statutory Compliance
- **hasStatutoryRule** → [[StatutoryRule]]: Liên kết đến statutory rule quy định cách tính. Ví dụ: element "PIT" link đến "Vietnam PIT Rules 2025".

### Calculation Logic
- **usesFormula** → [[PayFormula]]: Reference đến shared formula definition. Cho phép reuse formula giữa nhiều elements.

### Accounting Integration
- **hasGLMappings** → [[GLMappingPolicy]]: GL account mappings cho element. Có thể có nhiều mappings cho different segments (cost center, department).

### Balance Contribution
- **includesInBalances** → [[PayBalanceDefinition]]: Elements contribute vào balances. Ví dụ: BASIC_SALARY, OT_150 đều contribute vào GROSS balance.

### Profile Inclusion
- **belongsToProfiles** → [[PayProfile]]: Profiles chứa element này. Element có thể thuộc nhiều profiles.

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> draft: create
    
    draft --> active: activate
    note right of draft: Classification và unit required
    
    active --> deprecated: deprecate
    active --> archived: archive
    
    deprecated --> archived: archive
    
    archived --> [*]
```

### State Definitions

| State | Business Meaning | System Impact |
|-------|------------------|---------------|
| **draft** | Đang configure | Không thể include trong payroll runs |
| **active** | Hoạt động bình thường | Có thể sử dụng trong calculations |
| **deprecated** | Không recommend sử dụng | Vẫn hoạt động, nhưng không cho assign mới |
| **archived** | Đã đóng | Read-only, historical only |

### Transition Workflows

#### Draft → Active (activate)
**Trigger**: Element configuration hoàn tất
**Who**: Payroll Administrator
**Prerequisites**: 
- Classification và unit được set
- Formula configured (nếu không phải input element)

#### Active → Deprecated (deprecate)
**Trigger**: Element sẽ được thay thế bởi element mới
**Who**: Payroll Director
**Effect**: Existing usages vẫn hoạt động, không cho add vào profiles mới

#### Any → Archived (archive)
**Prerequisites**: Không còn payroll runs đang sử dụng
**Effect**: Element read-only

## Actions & Operations

### Element Creation Flow

```mermaid
flowchart TD
    A["Start: Create Element"] --> B{"Classification?"}
    B --> C["EARNING"]
    B --> D["DEDUCTION"]
    B --> E["TAX"]
    B --> F["EMPLOYER_CONTRIBUTION"]
    
    C --> G{"Input Required?"}
    D --> G
    E --> H["Set taxableFlag = false"]
    F --> G
    
    G -->|Yes| I["Set inputRequired = true"]
    G -->|No| J["Configure Formula"]
    H --> J
    
    I --> K["Set Priority Order"]
    J --> K
    K --> L["Configure GL Mapping"]
    L --> M["Activate Element"]
    M --> N["Assign to Profile"]
```

### create
**Who**: Payroll Administrator
**Required**: code, name, classification, unit, effectiveStartDate
**Example**:
```yaml
code: OT_200
name: "Overtime 200%"
classification: EARNING
unit: HOURS
inputRequired: true
taxableFlag: true
preTaxFlag: true
```

### setFormula
**Who**: Payroll Administrator
**When**: Define calculation logic
**Options**:
1. Inline formulaJson
2. Reference đến shared PayFormula

**Example formulaJson**:
```json
{
  "type": "formula",
  "expression": "hours * (basic_salary / 26 / 8) * 2.0",
  "inputs": ["hours", "basic_salary"]
}
```

### assignToProfile
**Who**: Payroll Administrator
**When**: Add element vào profile để apply cho pay groups
**Effect**: All pay groups using profile sẽ include element

## Business Rules

### Data Integrity

#### Unique Code (uniqueCode)
**Rule**: Mã element phải duy nhất trong hệ thống.
**Reason**: Code là identifier chính cho payroll calculation engine.

#### Valid Classification (validClassification)
**Rule**: Classification phải thuộc danh sách defined.
**Reason**: Calculation engine depends on classification.

### Business Logic

#### Tax Logic (taxLogic)
**Rule**: TAX classification elements phải có taxableFlag = false.
**Reason**: Tax element không bị tính thuế lại trên chính nó.

#### Earning Positive (earningPositive)
**Rule**: EARNING elements add to gross pay.
**Implementation**: Calculation engine treats EARNING as positive.

#### Deduction Negative (deductionNegative)
**Rule**: DEDUCTION elements reduce net pay.
**Implementation**: Calculation engine treats DEDUCTION as negative.

## Examples

### Example 1: Basic Salary (EARNING)
- **code**: BASIC_SALARY
- **name**: Lương cơ bản
- **classification**: EARNING
- **unit**: AMOUNT
- **inputRequired**: true (HR enters value)
- **taxableFlag**: true
- **preTaxFlag**: true
- **priorityOrder**: 1 (tính đầu tiên)

### Example 2: Overtime 150% (EARNING)
- **code**: OT_150
- **name**: Làm thêm giờ 150%
- **classification**: EARNING
- **unit**: HOURS
- **inputRequired**: true (from timesheet)
- **formulaJson**: 
  ```json
  {
    "expression": "hours * hourly_rate * 1.5",
    "inputs": ["hours"]
  }
  ```
- **taxableFlag**: true

### Example 3: Social Insurance Employee (DEDUCTION)
- **code**: BHXH_EE
- **name**: BHXH phần người lao động
- **classification**: DEDUCTION
- **unit**: PERCENTAGE
- **inputRequired**: false (calculated)
- **formulaJson**:
  ```json
  {
    "type": "percentage",
    "base": "GROSS_INSURABLE",
    "rate": 0.08
  }
  ```
- **taxableFlag**: false (pre-tax deduction)
- **preTaxFlag**: true

### Example 4: Personal Income Tax (TAX)
- **code**: PIT
- **name**: Thuế thu nhập cá nhân
- **classification**: TAX
- **unit**: AMOUNT
- **inputRequired**: false
- **hasStatutoryRule**: VN_PIT_RULE_2025
- **taxableFlag**: false

### Example 5: Employer Social Insurance (EMPLOYER_CONTRIBUTION)
- **code**: BHXH_ER
- **name**: BHXH phần công ty
- **classification**: EMPLOYER_CONTRIBUTION
- **unit**: PERCENTAGE
- **inputRequired**: false
- **formulaJson**:
  ```json
  {
    "type": "percentage",
    "base": "GROSS_INSURABLE",
    "rate": 0.175
  }
  ```
- **Note**: Không trừ vào lương employee, chỉ costing

## Edge Cases & Exceptions

### Element với Multiple Formulas
**Situation**: Cùng element nhưng formula khác nhau theo market.
**Handling**: Tạo market-specific elements (BHXH_EE_VN, CPF_EE_SG) hoặc dùng PayProfile để override formula per market.

### Retroactive Element Changes
**Situation**: Element rate thay đổi retroactively.
**Handling**: 
- Tạo SCD2 version mới với effectiveStartDate trong quá khứ
- Payroll retro process sẽ recalculate

### Element Deprecation with Active Usage
**Situation**: Cần deprecate element nhưng còn payroll runs đang chạy.
**Handling**: Wait until runs complete, hoặc deprecate và runs hiện tại vẫn dùng version active.

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[StatutoryRule]] | has | Statutory rule áp dụng |
| [[PayFormula]] | uses | Shared formula definition |
| [[GLMappingPolicy]] | has many | GL account mappings |
| [[PayBalanceDefinition]] | contributes to | Balance definitions |
| [[PayProfile]] | belongs to | Profiles chứa element |
