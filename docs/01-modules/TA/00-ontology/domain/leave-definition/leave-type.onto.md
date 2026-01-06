---
entity: LeaveType
domain: time-attendance
version: "1.0.0"
status: draft
owner: absence-team
tags: [leave-definition, type, core]

classification:
  type: AGGREGATE_ROOT
  category: leave-definition

attributes:
  - name: code
    type: string
    required: true
    unique: true
    description: Leave type code
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Leave type name
    constraints:
      max: 100

  - name: isPaid
    type: boolean
    required: true
    default: true
    description: Is paid leave

  - name: isQuotaBased
    type: boolean
    required: true
    default: true
    description: Has quota/entitlement

  - name: requiresApproval
    type: boolean
    required: true
    default: true
    description: Requires manager approval

  - name: unitCode
    type: enum
    required: true
    values: [HOUR, DAY]
    description: Leave unit

  - name: coreMinUnit
    type: number
    required: true
    default: 1.00
    description: Minimum leave unit (0.5 for half-day)

  - name: allowsHalfDay
    type: boolean
    required: true
    default: false
    description: Allows half-day leave

  - name: holidayHandling
    type: enum
    required: false
    values: [EXCLUDE_HOLIDAYS, INCLUDE_HOLIDAYS]
    description: How to handle holidays

  - name: overlapPolicy
    type: enum
    required: false
    values: [ALLOW, DENY]
    description: Overlap with other leave

  - name: defaultEligibilityProfileId
    type: string
    required: false
    description: Default eligibility profile

  - name: effectiveStartDate
    type: date
    required: true
    description: Effective start date

  - name: effectiveEndDate
    type: date
    required: false
    description: Effective end date

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Active status

relationships:
  - name: hasClasses
    target: LeaveClass
    cardinality: one-to-many
    required: false
    inverse: belongsToType
    description: Leave classes of this type

lifecycle:
  states: [active, inactive]
  initial: active

actions:
  - name: create
    description: Create leave type
    requiredFields: [code, name, unitCode, effectiveStartDate]

policies:
  - name: uniqueCode
    type: validation
    rule: "Leave type code must be unique"
---

# LeaveType

## Overview

```mermaid
mindmap
  root((LeaveType))
    Categories
      ANNUAL
      SICK
      MATERNITY
      PATERNITY
      BEREAVEMENT
      UNPAID
    Configuration
      isPaid
      isQuotaBased
      requiresApproval
      allowsHalfDay
```

**LeaveType** định nghĩa loại nghỉ phép - annual, sick, maternity. Là parent của LeaveClass.

## Business Context

### Vietnam Leave Entitlements

| Type | Days/Year | Paid | Note |
|------|-----------|------|------|
| Annual Leave | 12 | Yes | +1 per 5 years |
| Sick Leave | 30 | 75% | BHXH pays |
| Maternity | 180 | Yes | BHXH pays |
| Paternity | 5-7 | Yes | Normal/C-section |
| Bereavement | 3 | Yes | Family death |
| Marriage | 3 | Yes | Own marriage |

## Relationships

```mermaid
erDiagram
    LEAVE_TYPE ||--o{ LEAVE_CLASS : "hasClasses"
```

## Examples

### Example 1: Annual Leave
- **code**: ANNUAL
- **isPaid**: true
- **isQuotaBased**: true
- **unitCode**: DAY
- **allowsHalfDay**: true
- **holidayHandling**: EXCLUDE_HOLIDAYS

### Example 2: Sick Leave
- **code**: SICK
- **isPaid**: true
- **isQuotaBased**: false
- **unitCode**: DAY
- **requiresApproval**: true

### Example 3: Maternity Leave
- **code**: MATERNITY
- **isPaid**: true
- **isQuotaBased**: true
- **unitCode**: DAY
- **coreMinUnit**: 1.00

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[LeaveClass]] | hasClasses | Specific configurations |
