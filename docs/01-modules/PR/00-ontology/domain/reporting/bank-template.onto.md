---
entity: BankTemplate
domain: payroll
version: "1.0.0"
status: draft
owner: payroll-team
tags: [reporting, template, banking]

attributes:
  - name: code
    type: string
    required: true
    unique: true
    description: Mã bank/template
    constraints:
      max: 20

  - name: name
    type: string
    required: true
    description: Tên bank/template
    constraints:
      max: 100

  - name: format
    type: enum
    required: true
    values: [CSV, TXT, XML, MT940, SWIFT, OTHER]
    description: Định dạng file output

  - name: delimiter
    type: string
    required: false
    description: Delimiter cho CSV format
    constraints:
      max: 5

  - name: columnsJson
    type: object
    required: true
    description: JSON mô tả cột và thứ tự

  - name: headerConfig
    type: object
    required: false
    description: Header row configuration

  - name: footerConfig
    type: object
    required: false
    description: Footer/summary row configuration

  - name: effectiveStartDate
    type: date
    required: true
    description: Ngày bắt đầu

  - name: effectiveEndDate
    type: date
    required: false
    description: Ngày kết thúc

  - name: currentFlag
    type: boolean
    required: true
    default: true
    description: Version hiện tại

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
    description: Tạo mới bank template
    requiredFields: [code, name, format, columnsJson, effectiveStartDate]

  - name: update
    description: Cập nhật template
    affectsAttributes: [name, columnsJson, headerConfig, footerConfig]

  - name: preview
    description: Preview file với sample data
    requiredFields: [sampleData]

  - name: validate
    description: Validate template structure
    requiredFields: []

policies:
  - name: uniqueCode
    type: validation
    rule: "Mã bank template phải duy nhất"

  - name: validColumns
    type: validation
    rule: "columnsJson phải có valid structure"

  - name: editAccess
    type: access
    rule: "Payroll Admin và Treasury có quyền chỉnh sửa"
---

# BankTemplate

## Overview

```mermaid
mindmap
  root((BankTemplate))
    Formats
      CSV
      TXT
      XML
      MT940
      SWIFT
    Configuration
      columnsJson
      headerConfig
      footerConfig
```

**BankTemplate** (Mẫu file ngân hàng) định nghĩa format cho payment files gửi đến ngân hàng. Mỗi ngân hàng có thể có format khác nhau.

## Business Context

### Key Stakeholders
- **Treasury/Finance**: Define templates theo bank requirements
- **Payroll Administrators**: Generate payment files
- **Bank Operations**: Process payment files

### Business Processes
- **Payment File Generation**: Create files theo bank format
- **Bank Integration**: Submit files qua banking portal/API
- **Reconciliation**: Match payments với bank confirmations

## Attributes Guide

- **format**: File type
  - *CSV*: Comma-separated
  - *TXT*: Fixed-width text
  - *XML*: XML format
  - *MT940*: SWIFT bank statement
  - *SWIFT*: SWIFT payment messages

- **columnsJson**: Column definitions
  ```json
  {
    "columns": [
      {"name": "account_no", "position": 1, "width": 20, "type": "string"},
      {"name": "amount", "position": 2, "width": 15, "type": "decimal", "format": "0.00"},
      {"name": "currency", "position": 3, "width": 3, "type": "string"},
      {"name": "beneficiary", "position": 4, "width": 50, "type": "string"}
    ]
  }
  ```

## Examples

### Example 1: Vietcombank
- **code**: VCB
- **name**: Vietcombank Payment File
- **format**: CSV
- **delimiter**: ","

### Example 2: DBS Singapore
- **code**: DBS_SG
- **name**: DBS Singapore GIRO
- **format**: TXT

### Example 3: Citibank SWIFT
- **code**: CITI_SWIFT
- **name**: Citibank SWIFT MT103
- **format**: SWIFT
