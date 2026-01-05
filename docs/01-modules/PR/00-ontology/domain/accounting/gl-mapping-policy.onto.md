---
entity: GLMappingPolicy
domain: payroll
version: "1.0.0"
status: draft
owner: payroll-team
tags: [accounting, gl]

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated unique identifier (UUID)

  - name: elementId
    type: string
    required: true
    description: FK to PayElement

  - name: glAccountCode
    type: string
    required: true
    description: Mã tài khoản kế toán
    constraints:
      max: 105

  - name: segmentJson
    type: object
    required: false
    description: JSON segments (cost center, project, etc.)

  - name: description
    type: string
    required: false
    description: Mô tả mapping

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Mapping có active không

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
  - name: belongsToElement
    target: PayElement
    cardinality: many-to-one
    required: true
    inverse: hasGLMappings
    description: Element mà mapping thuộc về

lifecycle:
  states: [active, inactive]
  initial: active
  transitions:
    - from: active
      to: inactive
      trigger: deactivate
    - from: inactive
      to: active
      trigger: activate

actions:
  - name: create
    description: Tạo mới GL mapping
    requiredFields: [elementId, glAccountCode, effectiveStartDate]

  - name: update
    description: Cập nhật mapping
    affectsAttributes: [glAccountCode, segmentJson, description]

  - name: deactivate
    description: Tạm ngừng mapping
    triggersTransition: deactivate

policies:
  - name: validGLAccount
    type: validation
    rule: "GL account phải tồn tại trong Chart of Accounts"

  - name: editAccess
    type: access
    rule: "Finance và Payroll Admin có quyền chỉnh sửa"
---

# GLMappingPolicy

## Overview

```mermaid
mindmap
  root((GLMappingPolicy))
    Mapping
      elementId
      glAccountCode
    Segments
      costCenter
      project
      fund
```

**GLMappingPolicy** (Policy Mapping GL) định nghĩa cách map các pay elements vào General Ledger accounts cho accounting purposes.

## Business Context

### Key Stakeholders
- **Finance/Accounting**: Define GL mappings theo chart of accounts
- **Payroll Administrators**: Maintain mappings
- **Auditors**: Review mappings cho compliance

### Business Processes
- **GL Posting**: Generate journal entries từ payroll
- **Financial Reporting**: Proper expense categorization
- **Cost Analysis**: Labor cost by category

## Attributes Guide

- **glAccountCode**: GL account number (ví dụ: "61000", "62100.001")
- **segmentJson**: Additional accounting dimensions
  ```json
  {
    "costCenter": "CC-12345",
    "project": "PRJ-001",
    "fund": "FUND-01"
  }
  ```

## Examples

### Example 1: Basic Salary Expense
- **element**: BASIC_SALARY
- **glAccountCode**: 61000
- **description**: Salary Expense - Direct Labor

### Example 2: Employer BHXH
- **element**: BHXH_ER
- **glAccountCode**: 62100
- **description**: Employer Social Insurance Expense

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[PayElement]] | belongsTo | Element being mapped |
