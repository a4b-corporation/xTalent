---
entity: LeaveClass
domain: time-attendance
version: "1.0.0"
status: draft
owner: absence-team
tags: [leave-definition, class, entity]

classification:
  type: ENTITY
  category: leave-definition

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated UUID

  - name: typeCode
    type: string
    required: true
    description: FK to LeaveType

  - name: code
    type: string
    required: true
    unique: true
    description: Leave class code
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Leave class name
    constraints:
      max: 100

  - name: statusCode
    type: enum
    required: true
    default: ACTIVE
    values: [ACTIVE, INACTIVE]
    description: Status

  - name: scopeOwner
    type: enum
    required: true
    default: EMP
    values: [EMP, BU, LE]
    description: Scope type

  - name: modeCode
    type: enum
    required: true
    values: [ACCOUNT, LIMIT, UNPAID]
    description: Balance mode

  - name: unitCode
    type: enum
    required: true
    values: [HOUR, DAY]
    description: Leave unit

  - name: periodProfile
    type: object
    required: false
    description: Period configuration (calendar/fiscal year)

  - name: postingMap
    type: object
    required: false
    description: GL posting configuration

  - name: defaultEligibilityProfileId
    type: string
    required: false
    description: Default eligibility profile

  - name: rulesJson
    type: object
    required: false
    description: Additional rules

  - name: effectiveStartDate
    type: date
    required: true
    description: Effective start date

  - name: effectiveEndDate
    type: date
    required: false
    description: Effective end date

relationships:
  - name: belongsToType
    target: LeaveType
    cardinality: many-to-one
    required: true
    inverse: hasClasses
    description: Parent leave type

  - name: hasPolicies
    target: LeavePolicy
    cardinality: one-to-many
    required: false
    inverse: belongsToClass
    description: Policies for this class

lifecycle:
  states: [active, inactive]
  initial: active
  transitions:
    - from: active
      to: inactive
      trigger: deactivate
    - from: inactive
      to: active
      trigger: reactivate

actions:
  - name: create
    description: Create leave class
    requiredFields: [typeCode, code, name, modeCode, unitCode, effectiveStartDate]

  - name: deactivate
    description: Deactivate leave class
    triggersTransition: deactivate

policies:
  - name: uniqueCode
    type: validation
    rule: "Leave class code must be unique"

  - name: modeConsistency
    type: business
    rule: "Mode determines balance tracking behavior"
---

# LeaveClass

## Overview

**LeaveClass** là cấu hình cụ thể của [[LeaveType]] - định nghĩa cách thức quản lý balance, scope và rules. Mỗi LeaveType có thể có nhiều LeaveClass cho các ngữ cảnh khác nhau.

```mermaid
mindmap
  root((LeaveClass))
    Mode
      ACCOUNT["ACCOUNT (có quota)"]
      LIMIT["LIMIT (có giới hạn)"]
      UNPAID["UNPAID (không lương)"]
    Scope
      EMP["Employee-level"]
      BU["Business Unit"]
      LE["Legal Entity"]
    Unit
      DAY
      HOUR
```

## Business Context

### Key Stakeholders
- **HR Policy**: Định nghĩa leave class theo chính sách
- **Payroll**: Xử lý UNPAID leave
- **Employee**: Xem balance theo class

### Mode vs Scope Matrix

| Mode | Balance Tracking | Pay Impact | Ví dụ |
|------|------------------|------------|-------|
| **ACCOUNT** | Track quota | Paid | Annual leave 12 ngày |
| **LIMIT** | Cap only | Paid | Sick leave max 30 ngày |
| **UNPAID** | No tracking | Unpaid | Leave without pay |

| Scope | Meaning | Use Case |
|-------|---------|----------|
| **EMP** | Per employee | Standard leave balance |
| **BU** | Shared within BU | Team floating holidays |
| **LE** | Shared within LE | Company-wide pool |

### Business Value
LeaveClass cho phép cùng một LeaveType (như Annual) có nhiều cấu hình khác nhau theo pháp nhân, theo policy hoặc theo nhóm nhân viên.

## Attributes Guide

### Core Identity
- **code**: Mã duy nhất. Format: VN_ANNUAL_12D, SG_SICK_14D
- **name**: Tên hiển thị. VD: "Phép năm VN - 12 ngày"
- **typeCode**: Link đến [[LeaveType]] parent

### Mode Configuration
- **modeCode**: Cách thức tracking:
  - *ACCOUNT*: Có quota cụ thể, track balance từng nhân viên
  - *LIMIT*: Có giới hạn max nhưng không cộng dồn
  - *UNPAID*: Không giới hạn, không trả lương
- **unitCode**: Đơn vị tính (DAY or HOUR)
- **scopeOwner**: Level của balance (EMP/BU/LE)

### Advanced Configuration
- **periodProfile**: Cấu hình năm (calendar/fiscal)
- **postingMap**: Mapping với GL account (cho payroll)
- **defaultEligibilityProfileId**: Ai được dùng class này

## Relationships Explained

```mermaid
erDiagram
    LEAVE_TYPE ||--o{ LEAVE_CLASS : "hasClasses"
    LEAVE_CLASS ||--o{ LEAVE_POLICY : "hasPolicies"
    LEAVE_CLASS ||--o{ LEAVE_ACCOUNT : "hasAccounts"
```

### LeaveType
- **belongsToType** → [[LeaveType]]: Parent (Annual, Sick, etc.)

### LeavePolicy
- **hasPolicies** → [[LeavePolicy]]: Accrual, carry-over, limit rules

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> active: create
    active --> inactive: deactivate
    inactive --> active: reactivate
```

| State | Meaning |
|-------|---------|
| **active** | Có thể sử dụng |
| **inactive** | Không thể tạo request mới |

## Actions & Operations

### create
**Who**: HR Policy  
**Required**: typeCode, code, name, modeCode, unitCode, effectiveStartDate

### deactivate
**Who**: HR Policy  
**When**: Class không còn sử dụng

## Business Rules

#### Unique Code (uniqueCode)
**Rule**: Leave class code phải duy nhất.

#### Mode Determines Tracking (modeConsistency)
**Rule**: Mode quyết định behavior:
- ACCOUNT → Create LeaveAccount per employee
- LIMIT → Check against limit only
- UNPAID → No balance check

## Examples

### Example 1: VN Annual Leave Class
```yaml
code: VN_ANNUAL_12D
name: "Phép năm VN - 12 ngày"
typeCode: ANNUAL
modeCode: ACCOUNT
scopeOwner: EMP
unitCode: DAY
```

### Example 2: Sick Leave Class
```yaml
code: VN_SICK_BHXH
name: "Nghỉ ốm BHXH"
typeCode: SICK
modeCode: LIMIT
scopeOwner: EMP
```

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[LeaveType]] | belongsToType | Parent type |
| [[LeavePolicy]] | hasPolicies | Accrual/carry rules |
