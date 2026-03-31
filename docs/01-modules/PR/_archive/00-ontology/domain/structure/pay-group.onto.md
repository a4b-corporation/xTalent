---
entity: PayGroup
domain: payroll
version: "1.0.0"
status: draft
owner: payroll-team
tags: [structure, scd2]

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
    description: Mã nhóm trả lương
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Tên nhóm trả lương
    constraints:
      max: 100

  - name: currencyCode
    type: string
    required: true
    description: Tiền tệ trả lương (ISO 4217)
    constraints:
      pattern: "^[A-Z]{3}$"

  - name: metadata
    type: object
    required: false
    description: Custom metadata JSON

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
  - name: belongsToLegalEntity
    target: LegalEntity
    cardinality: many-to-one
    required: true
    inverse: hasPayGroups
    description: Legal entity sở hữu

  - name: belongsToMarket
    target: TalentMarket
    cardinality: many-to-one
    required: false
    inverse: hasPayGroups
    description: Market áp dụng

  - name: belongsToCalendar
    target: PayCalendar
    cardinality: many-to-one
    required: true
    inverse: hasPayGroups
    description: Lịch trả lương áp dụng

  - name: hasBankAccount
    target: BankAccount
    cardinality: many-to-one
    required: false
    inverse: usedByPayGroups
    description: Bank account mặc định cho payments

  - name: hasEmployees
    target: Employee
    cardinality: one-to-many
    required: false
    inverse: belongsToPayGroup
    description: Nhân viên thuộc pay group

lifecycle:
  states: [draft, active, inactive, archived]
  initial: draft
  terminal: [archived]
  transitions:
    - from: draft
      to: active
      trigger: activate
    - from: active
      to: inactive
      trigger: suspend
    - from: inactive
      to: active
      trigger: reactivate
    - from: [active, inactive]
      to: archived
      trigger: archive
      guard: "No employees assigned"

actions:
  - name: create
    description: Tạo mới pay group
    requiredFields: [code, name, legalEntityId, calendarId, currencyCode, effectiveStartDate]

  - name: update
    description: Cập nhật thông tin (SCD2 versioning)
    affectsAttributes: [name, currencyCode, bankAccountId, metadata]

  - name: activate
    description: Kích hoạt pay group
    triggersTransition: activate

  - name: suspend
    description: Tạm ngưng pay group
    triggersTransition: suspend

  - name: archive
    description: Archive pay group
    triggersTransition: archive

  - name: assignEmployee
    description: Gán nhân viên vào pay group
    requiredFields: [employeeId]
    affectsRelationships: [hasEmployees]

  - name: removeEmployee
    description: Gỡ nhân viên khỏi pay group
    requiredFields: [employeeId]
    affectsRelationships: [hasEmployees]

policies:
  - name: uniqueCode
    type: validation
    rule: "Mã pay group phải duy nhất"
    expression: "UNIQUE(code)"

  - name: validCalendar
    type: validation
    rule: "Calendar phải active"
    expression: "calendar.status = 'active'"

  - name: currencyMatch
    type: business
    rule: "Currency nên match với calendar.defaultCurrency"

  - name: archiveGuard
    type: business
    rule: "Không thể archive nếu còn employees assigned"

  - name: editAccess
    type: access
    rule: "Payroll Admin có quyền chỉnh sửa"
---

# PayGroup

## Overview

```mermaid
mindmap
  root((PayGroup))
    Configuration
      code
      name
      currencyCode
    Relationships
      LegalEntity
      TalentMarket
      PayCalendar
      BankAccount
    Members
      Employees
    SCD-2
      effectiveStartDate
      isCurrentFlag
```

**PayGroup** (Nhóm trả lương) nhóm các nhân viên có cùng đặc điểm payroll: cùng calendar, cùng currency, cùng bank account trả lương. Đây là đơn vị cơ bản để thực hiện payroll runs và quản lý payment processing.

## Business Context

### Key Stakeholders
- **Payroll Administrators**: Tạo và quản lý pay groups, assign employees
- **Payroll Processors**: Chạy payroll theo pay group
- **Finance**: Monitor payments theo pay group
- **HR**: Gán nhân viên vào pay group khi onboarding

### Business Processes
This entity is central to:
- **Payroll Processing**: Payroll runs được thực hiện theo pay group
- **Employee Assignment**: Nhân viên được gán vào pay group khi hire/transfer
- **Payment Batching**: Payment files được generate theo pay group và bank account
- **Multi-currency Operations**: Hỗ trợ trả lương theo nhiều loại tiền

### Business Value
PayGroup tối ưu hóa payroll processing bằng cách nhóm employees có cùng đặc điểm, giúp streamline payments và đơn giản hóa reconciliation.

## Attributes Guide

### Identification
- **id**: UUID system-generated
- **code**: Business identifier (ví dụ: VN-HQ-OFFICE, SG-FACTORY). Thường combine market + location + employee type.

### Configuration
- **name**: Tên hiển thị (ví dụ: "Vietnam Head Office Staff")
- **currencyCode**: Tiền tệ trả lương (VND, USD, SGD). Phải consistent với calendar và employees trong group.

### SCD-2 History
- **effectiveStartDate/EndDate**: Versioning cho configuration changes
- **isCurrentFlag**: Active version indicator

## Relationships Explained

```mermaid
erDiagram
    PAY_GROUP }o--|| LEGAL_ENTITY : "belongsTo"
    PAY_GROUP }o--o| TALENT_MARKET : "belongsTo"
    PAY_GROUP }o--|| PAY_CALENDAR : "belongsTo"
    PAY_GROUP }o--o| BANK_ACCOUNT : "hasBankAccount"
    PAY_GROUP ||--o{ EMPLOYEE : "hasEmployees"
```

### Organizational Context
- **belongsToLegalEntity** → [[LegalEntity]]: Mỗi pay group thuộc một legal entity. Quan trọng cho legal compliance và financial reporting.

- **belongsToMarket** → [[TalentMarket]]: Market xác định statutory rules áp dụng (tax rates, social insurance, etc.)

### Payroll Configuration
- **belongsToCalendar** → [[PayCalendar]]: Xác định pay schedule (khi nào cut-off, khi nào pay). Tất cả employees trong group follow cùng schedule.

- **hasBankAccount** → [[BankAccount]]: Default bank account cho việc tạo payment files. Có thể override ở employee level.

### Employee Assignment
- **hasEmployees** → [[Employee]]: Nhân viên thuộc pay group này. Một employee chỉ thuộc một pay group tại một thời điểm.

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> draft: create
    draft --> active: activate
    active --> inactive: suspend
    inactive --> active: reactivate
    active --> archived: archive
    inactive --> archived: archive
    archived --> [*]
```

### State Definitions

| State | Business Meaning | System Impact |
|-------|------------------|---------------|
| **draft** | Đang setup, chưa sử dụng | Không thể assign employees |
| **active** | Hoạt động, có thể process payroll | Có thể assign/run payroll |
| **inactive** | Tạm ngưng | Giữ employees nhưng không run mới |
| **archived** | Đã đóng | Read-only, historical |

### Transition Workflows

#### Draft → Active (activate)
**Trigger**: Pay group sẵn sàng sử dụng
**Who**: Payroll Administrator
**Prerequisites**:
- Calendar được assign và active
- Bank account configured (optional)

#### Active → Archived (archive)
**Trigger**: Pay group không còn sử dụng
**Who**: Payroll Manager
**Prerequisites**: Không còn employees assigned
**Process**:
1. Verify no employees
2. Set status = archived
3. Pay group trở thành read-only

## Actions & Operations

### create
**Who**: Payroll Administrator
**Required**: code, name, legalEntityId, calendarId, currencyCode, effectiveStartDate

### assignEmployee
**Who**: HR Administrator, Payroll Admin
**When**: Onboarding hoặc transfer
**Process**:
1. Verify employee chưa thuộc pay group khác (trong cùng period)
2. Create assignment record
3. Employee sẽ được include trong payroll runs của group này

### removeEmployee
**Who**: HR Administrator, Payroll Admin
**When**: Termination, transfer sang group khác
**Note**: Nên assign vào group mới trước khi remove khỏi group cũ (nếu transfer)

## Business Rules

### Data Integrity

#### Unique Code (uniqueCode)
**Rule**: Mã pay group phải duy nhất.
**Reason**: Identifier cho payroll runs và reporting.

#### Valid Calendar (validCalendar)
**Rule**: Calendar được reference phải ở trạng thái active.
**Reason**: Đảm bảo pay schedule hợp lệ.

### Business Constraints

#### Currency Match (currencyMatch)
**Rule**: Currency của pay group nên match với calendar.defaultCurrency.
**Reason**: Consistency trong processing và reporting.
**Note**: Warning only, có thể override cho special cases.

#### Archive Guard (archiveGuard)
**Rule**: Không thể archive nếu còn employees assigned.
**Reason**: Tránh orphan employees.
**Handling**: Transfer employees trước khi archive.

## Examples

### Example 1: Vietnam Head Office
- **code**: VN-HQ-STAFF
- **name**: Vietnam Head Office Staff
- **legalEntity**: VNG Corporation
- **market**: Vietnam
- **calendar**: VN-MONTHLY-2025
- **currencyCode**: VND
- **bankAccount**: Vietcombank Main Account
- **employees**: ~500

### Example 2: Singapore Contractors
- **code**: SG-CONTRACTORS
- **name**: Singapore Contractors
- **legalEntity**: VNG Singapore Pte Ltd
- **market**: Singapore
- **calendar**: SG-BIWEEKLY-2025
- **currencyCode**: SGD
- **bankAccount**: DBS Singapore
- **employees**: ~20

## Edge Cases & Exceptions

### Employee Transfer Between Groups
**Situation**: Nhân viên chuyển từ VN-HQ-STAFF sang VN-FACTORY.
**Handling**:
1. Hoàn thành payroll current period với group cũ
2. Effective từ period tiếp theo, assign vào group mới
3. Giữ history ở cả hai groups

### Multiple Pay Groups per Entity
**Situation**: Một legal entity có nhiều pay groups (Office, Factory, Expats).
**Handling**: Bình thường. Mỗi group có calendar riêng hoặc share calendar.

### Currency Mismatch
**Situation**: Employee international cần pay bằng currency khác với group.
**Handling**: Xử lý ở employee level, không phải group level. Hoặc tạo dedicated pay group cho expats.

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[PayCalendar]] | belongsTo | Lịch trả lương áp dụng |
| [[LegalEntity]] | belongsTo | Legal entity sở hữu |
| [[TalentMarket]] | belongsTo | Market áp dụng |
| [[BankAccount]] | has | Bank account mặc định |
| [[Employee]] | has many | Nhân viên trong group |
