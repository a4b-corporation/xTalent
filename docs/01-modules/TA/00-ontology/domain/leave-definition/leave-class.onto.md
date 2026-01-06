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

actions:
  - name: create
    description: Create leave class
    requiredFields: [typeCode, code, name, modeCode, unitCode, effectiveStartDate]

policies:
  - name: uniqueCode
    type: validation
    rule: "Leave class code must be unique"
---

# LeaveClass

## Overview

```mermaid
mindmap
  root((LeaveClass))
    Mode
      ACCOUNT["ACCOUNT (quota)"]
      LIMIT["LIMIT (capped)"]
      UNPAID
    Scope
      EMP
      BU
      LE
```

**LeaveClass** là cấu hình cụ thể của LeaveType - định nghĩa mode, scope, và rules.

## Business Context

### Mode Types

| Mode | Mô tả | Ví dụ |
|------|-------|-------|
| **ACCOUNT** | Có quota, track balance | Annual leave |
| **LIMIT** | Có giới hạn nhưng không track | Sick leave |
| **UNPAID** | Không trả lương | LWOP |

### Scope Types

| Scope | Mô tả |
|-------|-------|
| EMP | Employee-level balance |
| BU | Business unit shared |
| LE | Legal entity shared |

## Relationships

```mermaid
erDiagram
    LEAVE_CLASS }o--|| LEAVE_TYPE : "belongsToType"
    LEAVE_CLASS ||--o{ LEAVE_POLICY : "hasPolicies"
```

## Examples

### Example 1: VN Annual Leave Class
- **typeCode**: ANNUAL
- **code**: VN_ANNUAL_12D
- **modeCode**: ACCOUNT
- **scopeOwner**: EMP
- **unitCode**: DAY

### Example 2: Sick Leave Class
- **typeCode**: SICK
- **code**: VN_SICK_BHXH
- **modeCode**: LIMIT
- **scopeOwner**: EMP

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[LeaveType]] | belongsToType | Parent type |
| [[LeavePolicy]] | hasPolicies | Accrual/carry rules |
