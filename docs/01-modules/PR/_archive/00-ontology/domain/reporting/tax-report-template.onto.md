---
entity: TaxReportTemplate
domain: payroll
version: "1.0.0"
status: draft
owner: payroll-team
tags: [reporting, template, tax]

attributes:
  - name: code
    type: string
    required: true
    unique: true
    description: Mã báo cáo
    constraints:
      max: 20

  - name: name
    type: string
    required: true
    description: Tên báo cáo
    constraints:
      max: 100

  - name: countryCode
    type: string
    required: true
    description: Mã quốc gia (VN, SG, US)
    constraints:
      max: 3

  - name: reportType
    type: enum
    required: true
    values: [MONTHLY, QUARTERLY, ANNUAL, AD_HOC]
    description: Loại báo cáo theo tần suất

  - name: format
    type: enum
    required: true
    values: [PDF, XML, EXCEL, TXT, OTHER]
    description: Định dạng file output

  - name: templateBlob
    type: string
    required: false
    description: Binary template file (for PDF)

  - name: templateJson
    type: object
    required: false
    description: JSON template definition

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
    description: Tạo mới tax report template
    requiredFields: [code, name, countryCode, reportType, format, effectiveStartDate]

  - name: update
    description: Cập nhật template
    affectsAttributes: [name, templateBlob, templateJson]

  - name: activate
    description: Kích hoạt template
    triggersTransition: activate

  - name: generate
    description: Generate report từ template
    requiredFields: [periodStart, periodEnd]

policies:
  - name: uniqueCode
    type: validation
    rule: "Mã template phải duy nhất"

  - name: validCountry
    type: validation
    rule: "countryCode phải là ISO 3166-1 alpha-2 hoặc alpha-3"

  - name: editAccess
    type: access
    rule: "Compliance và Payroll Admin có quyền chỉnh sửa"
---

# TaxReportTemplate

## Overview

```mermaid
mindmap
  root((TaxReportTemplate))
    Report Types
      MONTHLY
      QUARTERLY
      ANNUAL
      AD_HOC
    Formats
      PDF
      XML
      EXCEL
      TXT
    By Country
      VN
      SG
      US
```

**TaxReportTemplate** (Mẫu báo cáo thuế) định nghĩa format cho các báo cáo thuế theo statutory requirements của từng quốc gia.

## Business Context

### Key Stakeholders
- **Compliance Team**: Define report formats theo tax authority requirements
- **Payroll Administrators**: Generate reports
- **Tax/Legal**: Review và submit reports
- **Tax Authorities**: Receive and process reports

### Business Processes
- **Monthly/Quarterly Filing**: Regular tax submissions
- **Annual Tax Forms**: Year-end employee tax documents
- **Withholding Reports**: Tax withheld reporting
- **Audit Reports**: Supporting documentation

## Attributes Guide

- **reportType**:
  - *MONTHLY*: Monthly statutory reports
  - *QUARTERLY*: Quarterly submissions
  - *ANNUAL*: Year-end forms (W-2, 1099, etc.)
  - *AD_HOC*: On-demand reports

- **format**: Output format matching tax authority requirements

## Examples

### Example 1: Vietnam Monthly PIT Declaration
- **code**: 05QTT_TNCN
- **name**: Tờ khai PIT tháng (05/QTT-TNCN)
- **countryCode**: VN
- **reportType**: MONTHLY
- **format**: PDF

### Example 2: Vietnam Annual Tax Finalization
- **code**: 02KK_TNCN
- **name**: Quyết toán thuế TNCN năm
- **countryCode**: VN
- **reportType**: ANNUAL
- **format**: XML

### Example 3: Singapore IR8A
- **code**: IR8A
- **name**: Singapore IR8A Annual Return
- **countryCode**: SG
- **reportType**: ANNUAL
- **format**: TXT

### Example 4: US W-2
- **code**: W2
- **name**: US W-2 Wage and Tax Statement
- **countryCode**: US
- **reportType**: ANNUAL
- **format**: PDF
