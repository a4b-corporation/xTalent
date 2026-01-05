---
entity: CostingRule
domain: payroll
version: "1.0.0"
status: draft
owner: payroll-team
tags: [rules, costing, accounting, scd2]

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
    description: Mã rule
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Tên rule
    constraints:
      max: 100

  - name: levelScope
    type: enum
    required: true
    values: [LEGAL_ENTITY, BUSINESS_UNIT, DEPARTMENT, COST_CENTER, EMPLOYEE, ELEMENT]
    description: Level áp dụng rule

  - name: mappingJson
    type: object
    required: true
    description: JSON định nghĩa allocation logic

  - name: metadata
    type: object
    required: false
    description: Custom metadata

  # SCD-2 Fields
  - name: effectiveStartDate
    type: date
    required: true
    description: Ngày bắt đầu

  - name: effectiveEndDate
    type: date
    required: false
    description: Ngày kết thúc

  - name: isCurrentFlag
    type: boolean
    required: true
    default: true
    description: Version hiện tại

relationships:
  - name: appliedToElements
    target: PayElement
    cardinality: one-to-many
    required: false
    inverse: hasCostingRule
    description: Elements sử dụng costing rule này

lifecycle:
  states: [draft, active, inactive]
  initial: draft
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
    description: Tạo mới costing rule
    requiredFields: [code, name, levelScope, mappingJson, effectiveStartDate]

  - name: update
    description: Cập nhật rule
    affectsAttributes: [name, mappingJson, metadata]

  - name: activate
    description: Kích hoạt rule
    triggersTransition: activate

  - name: deactivate
    description: Tạm ngừng rule
    triggersTransition: deactivate

policies:
  - name: uniqueCode
    type: validation
    rule: "Mã rule phải duy nhất"

  - name: validMapping
    type: validation
    rule: "mappingJson phải có valid structure"

  - name: editAccess
    type: access
    rule: "Finance và Payroll Admin có quyền chỉnh sửa"
---

# CostingRule

## Overview

```mermaid
mindmap
  root((CostingRule))
    Scope
      LEGAL_ENTITY
      BUSINESS_UNIT
      DEPARTMENT
      COST_CENTER
      EMPLOYEE
      ELEMENT
    Mapping Types
      direct
      split
      derived
```

**CostingRule** (Quy tắc phân bổ chi phí) định nghĩa cách allocate payroll costs vào các cost centers, departments, projects, và GL accounts. Essential cho financial reporting và budgeting.

## Business Context

### Key Stakeholders
- **Finance/Accounting**: Define costing rules theo chart of accounts
- **Payroll Administrators**: Configure và maintain rules
- **Cost Center Managers**: Review allocated costs
- **Budget Owners**: Monitor labor costs against budget

### Business Processes
- **Cost Allocation**: Distribute payroll costs to proper segments
- **GL Posting**: Generate accounting entries
- **Project Costing**: Allocate costs to projects
- **Budget Tracking**: Labor cost vs budget analysis

### Business Value
Accurate cost allocation enables proper financial reporting, budget control, và project profitability analysis.

## Attributes Guide

### Scope
- **levelScope**: Level at which rule applies:
  - *LEGAL_ENTITY*: All employees in LE use same rule
  - *BUSINESS_UNIT*: BU-specific allocation
  - *DEPARTMENT*: Department-level
  - *COST_CENTER*: Cost center override
  - *EMPLOYEE*: Individual employee exceptions
  - *ELEMENT*: Element-specific costing

### Allocation Logic
- **mappingJson**: Defines allocation rules
  
  **Simple mapping**:
  ```json
  {
    "type": "direct",
    "costCenter": "CC-12345",
    "glAccount": "60100"
  }
  ```
  
  **Split allocation**:
  ```json
  {
    "type": "split",
    "allocations": [
      {"costCenter": "CC-001", "percentage": 60},
      {"costCenter": "CC-002", "percentage": 40}
    ]
  }
  ```
  
  **Derived from employee**:
  ```json
  {
    "type": "derived",
    "costCenterFrom": "employee.department.costCenter",
    "projectFrom": "employee.primaryAssignment.project"
  }
  ```

## Relationships Explained

```mermaid
erDiagram
    COSTING_RULE ||--o{ PAY_ELEMENT : "appliedToElements"
```

### Element Application
- **appliedToElements** → [[PayElement]]: Elements using this costing rule.
  - Different elements may have different costing (salary to one account, benefits to another)

## Examples

### Example 1: Default Department Costing
- **code**: COST_BY_DEPT
- **name**: Cost to Employee Department
- **levelScope**: LEGAL_ENTITY
- **mappingJson**:
  ```json
  {
    "type": "derived",
    "costCenterFrom": "employee.department.costCenter",
    "glAccount": "61000"
  }
  ```

### Example 2: Project Split Allocation
- **code**: COST_PROJECT_SPLIT
- **name**: Multi-Project Cost Split
- **levelScope**: EMPLOYEE
- **mappingJson**:
  ```json
  {
    "type": "split",
    "splitSource": "employee.projectAllocations",
    "glAccount": "61000"
  }
  ```
- **Note**: Uses employee's project allocation percentages

### Example 3: Element-Specific Costing
- **code**: COST_BHXH_ER
- **name**: Employer BHXH Cost Account
- **levelScope**: ELEMENT
- **mappingJson**:
  ```json
  {
    "type": "direct",
    "glAccount": "62100",
    "costCenterFrom": "employee.department.costCenter"
  }
  ```
- **appliedTo**: BHXH_ER element

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[PayElement]] | appliedTo (1:N) | Elements using this rule |
