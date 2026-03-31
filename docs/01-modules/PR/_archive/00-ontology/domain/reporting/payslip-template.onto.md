---
entity: PayslipTemplate
domain: payroll
version: "1.0.0"
status: draft
owner: payroll-team
tags: [reporting, template, scd2]

classification:
  type: ENTITY
  category: reporting

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

relationships:
  - name: usedByPayGroups
    target: PayGroup
    cardinality: one-to-many
    required: false
    inverse: hasPayslipTemplate
    description: Pay groups using this template

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

**PayslipTemplate** (Mẫu phiếu lương) định nghĩa layout và format cho payslip documents. Hỗ trợ multiple templates cho different locales và employee groups.

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

## Business Context

### Key Stakeholders
- **Payroll Administrators**: Create và customize templates
- **Employees**: View payslips format
- **HR**: Review templates cho policy compliance
- **Legal**: Ensure required information displayed

### Payslip Sections

| Section | Description | Required Fields |
|---------|-------------|-----------------|
| **Header** | Company info, logo | Company name, address, tax ID |
| **Employee Info** | Employee details | Code, name, department |
| **Earnings** | Income breakdown | Element, amount, YTD |
| **Deductions** | Deduction breakdown | Element, amount |
| **Summary** | Totals | Gross, deductions, net |
| **Footer** | Signature, disclaimer | Date, signature line |

### Business Value
PayslipTemplate ensures consistent, professional payslip presentation, supports multi-language requirements, và meets legal disclosure requirements.

## Attributes Guide

### Core Identity
- **code**: Mã duy nhất. Format: VN_STANDARD, EN_STANDARD
- **name**: Tên hiển thị. VD: "Vietnam Standard Payslip"
- **localeCode**: Language/region (vi_VN, en_US, zh_SG)

### Template Definition (templateJson)
```json
{
  "header": {
    "showLogo": true,
    "logoPath": "/assets/logo.png",
    "companyInfo": ["name", "address", "taxId"]
  },
  "sections": [
    {
      "name": "employee_info",
      "fields": ["code", "name", "department", "position"]
    },
    {
      "name": "earnings",
      "showDetails": true,
      "showYTD": true
    },
    {
      "name": "deductions",
      "showDetails": true
    },
    {
      "name": "summary",
      "fields": ["gross", "totalDeductions", "net"]
    }
  ],
  "footer": {
    "showSignature": true,
    "disclaimer": "This is a confidential document"
  }
}
```

## Relationships Explained

```mermaid
erDiagram
    PAYSLIP_TEMPLATE ||--o{ PAY_GROUP : "usedByPayGroups"
```

### PayGroup
- **usedByPayGroups** → [[PayGroup]]: Pay groups using this template

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> draft: create
    draft --> active: activate
    active --> inactive: deactivate
    inactive --> active: reactivate
```

| State | Meaning |
|-------|---------|
| **draft** | Đang design |
| **active** | Có thể sử dụng |
| **inactive** | Tạm ngừng |

### Payslip Generation Flow

```mermaid
flowchart LR
    A[Payroll Run Complete] --> B[Load Employee Data]
    B --> C[Select Template]
    C --> D[Apply Template Layout]
    D --> E[Generate PDF/View]
```

## Actions & Operations

### create
**Who**: Payroll Administrator  
**Required**: code, name, effectiveStartDate

### setDefault
**Who**: Payroll Administrator  
**Effect**: Only one default per locale

### preview
**Who**: Payroll Administrator  
**Input**: sampleData object  
**Output**: Rendered payslip preview

## Business Rules

#### Unique Code (uniqueCode)
**Rule**: Mã template phải duy nhất.

#### Single Default (singleDefault)
**Rule**: Chỉ có một template default per locale.

## Examples

### Example 1: Vietnam Standard
```yaml
code: VN_STANDARD
name: "Vietnam Standard Payslip"
localeCode: vi_VN
isDefault: true
templateJson:
  header:
    showLogo: true
    companyInfo: ["name", "address", "taxId"]
  sections:
    - name: employee_info
      fields: ["code", "name", "department"]
    - name: earnings
      showDetails: true
    - name: deductions
      showDetails: true
    - name: summary
      fields: ["gross", "deductions", "net"]
```

### Example 2: English Version
```yaml
code: EN_STANDARD
name: "English Standard Payslip"
localeCode: en_US
isDefault: false
```

### Example 3: Executive Confidential
```yaml
code: EXEC_CONFIDENTIAL
name: "Executive Confidential Payslip"
localeCode: en_US
description: "Template for executives with additional privacy"
templateJson:
  header:
    showLogo: true
  sections:
    - name: employee_info
      fields: ["code", "name"]  # Minimal info
    - name: summary
      fields: ["net"]  # Only net pay
```

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[PayGroup]] | usedBy | Pay groups using template |
