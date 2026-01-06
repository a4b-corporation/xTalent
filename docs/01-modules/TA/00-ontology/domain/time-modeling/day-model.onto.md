---
entity: DayModel
domain: time-attendance
version: "1.0.0"
status: draft
owner: ta-team
tags: [time-modeling, day-model, core]

classification:
  type: ENTITY
  category: time-modeling

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated UUID

  - name: code
    type: string
    required: true
    unique: true
    description: Unique day model code
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Day model name
    constraints:
      max: 100

  - name: dayType
    type: enum
    required: true
    values: [WORK, OFF, HOLIDAY, HALF_DAY]
    description: Type of day

  - name: shiftId
    type: string
    required: false
    description: FK to Shift (null for OFF/HOLIDAY)

  - name: isHalfDay
    type: boolean
    required: true
    default: false
    description: Is this a half day

  - name: halfDayPeriod
    type: enum
    required: false
    values: [MORNING, AFTERNOON]
    description: Which half if half day

  - name: variantSelectionRuleJson
    type: object
    required: false
    description: Rules for holiday class handling

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
  - name: hasShift
    target: Shift
    cardinality: many-to-one
    required: false
    inverse: usedByDayModels
    description: Shift for this day model

  - name: usedByPatterns
    target: WorkPattern
    cardinality: many-to-many
    required: false
    inverse: hasDayModels
    description: Patterns using this day model

lifecycle:
  states: [active, inactive]
  initial: active

actions:
  - name: create
    description: Create day model
    requiredFields: [code, name, dayType, effectiveStartDate]

policies:
  - name: uniqueCode
    type: validation
    rule: "Day model code must be unique"

  - name: shiftRequired
    type: validation
    rule: "Shift required for WORK and HALF_DAY types"
---

# DayModel

## Overview

```mermaid
mindmap
  root((DayModel))
    Types
      WORK
      OFF
      HOLIDAY
      HALF_DAY
    Links
      Shift
      WorkPattern
```

**DayModel** định nghĩa mô hình cho một ngày - ngày làm việc, nghỉ, lễ. Là Level 3 trong 6-level hierarchy.

## Business Context

### Day Types

| Type | Shift Required | Mô tả |
|------|----------------|-------|
| **WORK** | Yes | Ngày làm việc bình thường |
| **OFF** | No | Ngày nghỉ theo lịch |
| **HOLIDAY** | No | Ngày lễ |
| **HALF_DAY** | Yes | Nửa ngày (morning/afternoon) |

### 6-Level Hierarchy Position
```
TimeSegment (L1) → Shift (L2) → DayModel (L3) → WorkPattern (L4) → ScheduleRule (L5)
```

## Relationships

```mermaid
erDiagram
    DAY_MODEL }o--|| SHIFT : "hasShift"
    DAY_MODEL }o--o{ WORK_PATTERN : "usedByPatterns"
```

## Examples

### Example 1: Standard Work Day
- **code**: WORK_DAY_8H
- **dayType**: WORK
- **shiftId**: DAY_SHIFT_8H

### Example 2: Weekend Off
- **code**: OFF_DAY
- **dayType**: OFF
- **shiftId**: null

### Example 3: Half Day Saturday
- **code**: SATURDAY_AM
- **dayType**: HALF_DAY
- **isHalfDay**: true
- **halfDayPeriod**: MORNING
- **shiftId**: MORNING_4H

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[Shift]] | hasShift | Shift for work days |
| [[WorkPattern]] | usedByPatterns | Patterns using this |
