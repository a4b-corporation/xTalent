---
entity: PayrollInterface
domain: payroll
version: "1.0.0"
status: draft
owner: payroll-team
tags: [integration, interface]

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
    description: Mã interface
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Tên interface
    constraints:
      max: 100

  - name: description
    type: string
    required: false
    description: Mô tả interface

  - name: direction
    type: enum
    required: true
    values: [INBOUND, OUTBOUND, BIDIRECTIONAL]
    description: Hướng data flow

  - name: sourceSystem
    type: string
    required: false
    description: Hệ thống nguồn (cho inbound)

  - name: targetSystem
    type: string
    required: false
    description: Hệ thống đích (cho outbound)

  - name: format
    type: enum
    required: true
    values: [API, FILE_CSV, FILE_XML, FILE_JSON, DATABASE, OTHER]
    description: Định dạng interface

  - name: mappingJson
    type: object
    required: false
    description: JSON định nghĩa field mappings

  - name: scheduleJson
    type: object
    required: false
    description: JSON định nghĩa schedule (cho batch)

  - name: validationJson
    type: object
    required: false
    description: JSON định nghĩa validation rules

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Interface có active không

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

relationships: []

lifecycle:
  states: [draft, active, inactive, retired]
  initial: draft
  terminal: [retired]
  transitions:
    - from: draft
      to: active
      trigger: deploy
    - from: active
      to: inactive
      trigger: suspend
    - from: inactive
      to: active
      trigger: resume
    - from: [active, inactive]
      to: retired
      trigger: retire

actions:
  - name: create
    description: Tạo mới interface definition
    requiredFields: [code, name, direction, format, effectiveStartDate]

  - name: update
    description: Cập nhật interface
    affectsAttributes: [name, description, mappingJson, scheduleJson, validationJson]

  - name: deploy
    description: Deploy interface để sử dụng
    triggersTransition: deploy

  - name: suspend
    description: Tạm ngừng interface
    triggersTransition: suspend

  - name: resume
    description: Resume interface đã suspend
    triggersTransition: resume

  - name: retire
    description: Retire interface không còn dùng
    triggersTransition: retire

  - name: test
    description: Test interface với sample data
    requiredFields: [testData]

  - name: runManual
    description: Trigger manual run cho batch interface
    requiredFields: []

policies:
  - name: uniqueCode
    type: validation
    rule: "Mã interface phải duy nhất"

  - name: validMapping
    type: validation
    rule: "mappingJson phải có valid structure"

  - name: sourceOrTarget
    type: validation
    rule: "Inbound cần sourceSystem, Outbound cần targetSystem"
    expression: "(direction = 'INBOUND' AND sourceSystem IS NOT NULL) OR (direction = 'OUTBOUND' AND targetSystem IS NOT NULL) OR direction = 'BIDIRECTIONAL'"

  - name: editAccess
    type: access
    rule: "Integration Team và Payroll Admin có quyền chỉnh sửa"
---

# PayrollInterface

## Overview

```mermaid
mindmap
  root((PayrollInterface))
    Direction
      INBOUND
      OUTBOUND
      BIDIRECTIONAL
    Format
      API
      FILE_CSV
      FILE_XML
      DATABASE
    Configuration
      mappingJson
      scheduleJson
      validationJson
```

**PayrollInterface** (Giao diện Payroll) định nghĩa các interface tích hợp giữa Payroll module với các hệ thống khác, bao gồm cả internal modules và external systems.

## Business Context

### Key Stakeholders
- **Integration Team**: Design và develop interfaces
- **Payroll Administrators**: Monitor và manage interfaces
- **IT Operations**: Support interface infrastructure
- **External Vendors**: Integrate with payroll data

### Business Processes
- **Time Data Import**: Nhận dữ liệu từ Time & Attendance
- **HR Data Sync**: Đồng bộ employee data từ Core HR
- **GL Export**: Xuất journal entries sang Finance/ERP
- **Bank Integration**: Gửi payment files
- **Tax Authority Integration**: Submit statutory reports

### Business Value
PayrollInterface chuẩn hóa cách define và manage integrations, đảm bảo data consistency và traceability.

## Attributes Guide

### Interface Type
- **direction**:
  - *INBOUND*: Data vào Payroll (time data, HR changes)
  - *OUTBOUND*: Data ra khỏi Payroll (GL, payments, reports)
  - *BIDIRECTIONAL*: Two-way sync

- **format**:
  - *API*: REST/SOAP API calls
  - *FILE_CSV/XML/JSON*: Batch file transfers
  - *DATABASE*: Direct database connection

### Configuration
- **mappingJson**: Field mappings
  ```json
  {
    "mappings": [
      {"source": "emp_id", "target": "employee_code", "transform": "prefix('EMP')"},
      {"source": "work_hours", "target": "regular_hours", "transform": "none"},
      {"source": "ot_hours", "target": "overtime_hours", "transform": "none"}
    ],
    "defaults": {
      "element_code": "TIMESHEET_HOURS"
    }
  }
  ```

- **scheduleJson**: Batch schedules
  ```json
  {
    "type": "cron",
    "expression": "0 6 * * *",
    "timezone": "Asia/Ho_Chi_Minh",
    "retryPolicy": {"maxRetries": 3, "delayMinutes": 30}
  }
  ```

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> draft: create
    draft --> active: deploy
    active --> inactive: suspend
    inactive --> active: resume
    active --> retired: retire
    inactive --> retired: retire
    retired --> [*]
```

### State Definitions

| State | Business Meaning | System Impact |
|-------|------------------|---------------|
| **draft** | Đang develop | Không processing |
| **active** | Đang hoạt động | Real data processing |
| **inactive** | Tạm ngừng | No processing, retains config |
| **retired** | Đã ngừng vĩnh viễn | Archive, không thể resume |

## Examples

### Example 1: Time & Attendance Import
- **code**: TA_IMPORT_DAILY
- **name**: T&A Daily Time Import
- **direction**: INBOUND
- **sourceSystem**: Time & Attendance
- **format**: API
- **scheduleJson**: Daily at 6 AM

### Example 2: GL Journal Export
- **code**: GL_EXPORT
- **name**: GL Journal Entry Export
- **direction**: OUTBOUND
- **targetSystem**: ERP/SAP
- **format**: FILE_XML
- **scheduleJson**: After payroll run completion

### Example 3: HR Master Sync
- **code**: HR_SYNC
- **name**: HR Master Data Synchronization
- **direction**: INBOUND
- **sourceSystem**: Core HR
- **format**: API
- **scheduleJson**: Real-time event-driven

### Example 4: Bank Payment File
- **code**: BANK_VCB
- **name**: Vietcombank Payment Interface
- **direction**: OUTBOUND
- **targetSystem**: Vietcombank
- **format**: FILE_CSV
- **description**: Uses BankTemplate VCB for formatting

## Edge Cases & Exceptions

### Interface Failure Handling
**Situation**: Interface fails during processing
**Handling**:
- Retry per retryPolicy
- Alert và log errors
- Queue for manual intervention if max retries exceeded

### Partial Data Processing
**Situation**: Some records fail validation
**Handling**:
- Process valid records
- Report failures for correction
- Allow re-processing of failed records

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[BankTemplate]] | uses | For bank file formatting |
| (Various modules) | integrates with | Source/target systems |
