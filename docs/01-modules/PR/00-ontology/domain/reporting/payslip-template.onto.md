---
entity: PayslipTemplate
domain: payroll
version: "1.0.0"
status: draft
owner: payroll-team
tags: [reporting, template, scd2]

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
    description: Mã template
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Tên template
    constraints:
      max: 255

  - name: localeCode
    type: string
    required: false
    description: Locale cho template (vi_VN, en_SG)
    constraints:
      max: 10

  - name: templateJson
    type: object
    required: false
    description: JSON định nghĩa layout và sections

  - name: description
    type: string
    required: false
    description: Mô tả template

  - name: isDefault
    type: boolean
    required: true
    default: false
    description: Có phải template mặc định không

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Template có active không

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

relationships: []

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
    description: Tạo mới template
    requiredFields: [code, name, effectiveStartDate]

  - name: update
    description: Cập nhật template
    affectsAttributes: [name, localeCode, templateJson, description]

  - name: activate
    description: Kích hoạt template
    triggersTransition: activate

  - name: setDefault
    description: Đặt làm template mặc định
    affectsAttributes: [isDefault]

  - name: preview
    description: Preview template với sample data
    requiredFields: [sampleData]

policies:
  - name: uniqueCode
    type: validation
    rule: "Mã template phải duy nhất"

  - name: singleDefault
    type: business
    rule: "Chỉ có một template default per locale"

  - name: editAccess
    type: access
    rule: "Payroll Admin có quyền chỉnh sửa templates"
---

# PayslipTemplate

## Overview

```mermaid
mindmap
  root((PayslipTemplate))
    Layout
      templateJson
      localeCode
    Sections
      header
      earnings
      deductions
      summary
      footer
    Options
      isDefault
      isActive
```

**PayslipTemplate** (Mẫu phiếu lương) định nghĩa layout và format cho payslip documents. Hỗ trợ multiple templates cho different locales và employee groups.

## Business Context

### Key Stakeholders
- **Payroll Administrators**: Create và customize templates
- **Employees**: View payslips format
- **HR**: Review templates cho policy compliance
- **Legal**: Ensure required information displayed

### Business Processes
- **Payslip Generation**: Apply template cho payslip PDF/view
- **Multi-language**: Different templates per locale
- **Customization**: Templates cho different employee types

## Attributes Guide

- **localeCode**: Language/region (vi_VN, en_US, zh_SG)
- **templateJson**: Template definition
  ```json
  {
    "header": {
      "showLogo": true,
      "companyInfo": ["name", "address", "taxId"]
    },
    "sections": [
      {"name": "employee_info", "fields": ["code", "name", "department"]},
      {"name": "earnings", "showDetails": true},
      {"name": "deductions", "showDetails": true},
      {"name": "summary", "fields": ["gross", "deductions", "net"]}
    ],
    "footer": {
      "showSignature": true,
      "disclaimer": "Confidential"
    }
  }
  ```

## Examples

### Example 1: Vietnam Standard
- **code**: VN_STANDARD
- **name**: Vietnam Standard Payslip
- **localeCode**: vi_VN
- **isDefault**: true

### Example 2: English Version
- **code**: EN_STANDARD
- **name**: English Standard Payslip
- **localeCode**: en_US
- **isDefault**: false

### Example 3: Executive Confidential
- **code**: EXEC_CONFIDENTIAL
- **name**: Executive Confidential Payslip
- **localeCode**: en_US
- **description**: Template cho executives với additional privacy
