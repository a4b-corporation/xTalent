---
entity: PayAdjustReason
domain: payroll
version: "1.0.0"
status: draft
owner: payroll-team
tags: [accounting, reference-data]

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
    description: Mã lý do
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Tên lý do
    constraints:
      max: 100

  - name: description
    type: string
    required: false
    description: Mô tả chi tiết

  - name: adjustmentType
    type: enum
    required: true
    values: [INCREASE, DECREASE, CORRECTION, REVERSAL, OTHER]
    description: Loại điều chỉnh

  - name: requiresApproval
    type: boolean
    required: true
    default: true
    description: Cần approval không

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Có active không

relationships: []

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
    description: Tạo mới reason
    requiredFields: [code, name, adjustmentType]

  - name: update
    description: Cập nhật reason
    affectsAttributes: [name, description, requiresApproval]

  - name: deactivate
    description: Tạm ngừng reason
    triggersTransition: deactivate

policies:
  - name: uniqueCode
    type: validation
    rule: "Mã lý do phải duy nhất"

  - name: editAccess
    type: access
    rule: "Payroll Admin có quyền chỉnh sửa"
---

# PayAdjustReason

## Overview

```mermaid
mindmap
  root((PayAdjustReason))
    Types
      INCREASE
      DECREASE
      CORRECTION
      REVERSAL
    Options
      requiresApproval
      isActive
```

**PayAdjustReason** (Lý do điều chỉnh lương) là reference data chứa danh sách các lý do điều chỉnh lương, dùng khi tạo manual adjustments.

## Business Context

### Key Stakeholders
- **Payroll Administrators**: Select reason khi tạo adjustment
- **Payroll Managers**: Review adjustments by reason
- **Audit**: Track adjustments theo categories

### Business Processes
- **Manual Adjustments**: Required reason for each adjustment
- **Audit Trail**: Categorize adjustments for review
- **Reporting**: Analyze adjustments by reason

## Attributes Guide

- **adjustmentType**:
  - *INCREASE*: Tăng (back pay, bonus missed)
  - *DECREASE*: Giảm (overpayment correction)
  - *CORRECTION*: Sửa lỗi calculation
  - *REVERSAL*: Đảo ngược entry sai
  - *OTHER*: Khác

- **requiresApproval**: Adjustments với reason này cần approval flow

## Examples

### Example 1: Back Pay
- **code**: BACK_PAY
- **name**: Back Pay - Trả lương truy lĩnh
- **adjustmentType**: INCREASE
- **requiresApproval**: true

### Example 2: Data Entry Error
- **code**: DATA_ERROR
- **name**: Data Entry Error Correction
- **adjustmentType**: CORRECTION
- **requiresApproval**: true

### Example 3: Overpayment Recovery
- **code**: OVERPAY_RECOVER
- **name**: Overpayment Recovery
- **adjustmentType**: DECREASE
- **requiresApproval**: true

## Related Entities

This is standalone reference data, used by Manual Adjustment records.
