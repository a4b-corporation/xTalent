---
entity: Shift
domain: time-attendance
version: "1.0.0"
status: draft
owner: ta-team
tags: [time-modeling, shift, core]

classification:
  type: AGGREGATE_ROOT
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
    description: Unique shift code
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Shift name
    constraints:
      max: 100

  - name: shiftType
    type: enum
    required: true
    values: [ELAPSED, PUNCH, FLEX]
    description: Shift calculation type

  - name: referenceStartTime
    type: time
    required: false
    description: Reference start time (for ELAPSED type)

  - name: referenceEndTime
    type: time
    required: false
    description: Reference end time (for ELAPSED type)

  - name: totalWorkHours
    type: number
    required: true
    description: Total work hours in shift

  - name: totalBreakHours
    type: number
    required: true
    default: 0
    description: Total break hours

  - name: totalPaidHours
    type: number
    required: true
    description: Total paid hours

  - name: crossMidnight
    type: boolean
    required: true
    default: false
    description: Does shift cross midnight

  - name: graceInMinutes
    type: number
    required: true
    default: 0
    description: Grace period for clock-in

  - name: graceOutMinutes
    type: number
    required: true
    default: 0
    description: Grace period for clock-out

  - name: roundingIntervalMin
    type: number
    required: true
    default: 15
    description: Rounding interval in minutes

  - name: roundingMode
    type: enum
    required: true
    default: NEAREST
    values: [NEAREST, UP, DOWN]
    description: Rounding mode for punch times

  - name: color
    type: string
    required: false
    description: Display color (#RRGGBB)
    constraints:
      max: 7

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
  - name: hasSegments
    target: TimeSegment
    cardinality: many-to-many
    required: false
    inverse: usedInShifts
    description: Segments composing this shift

  - name: usedByDayModels
    target: DayModel
    cardinality: one-to-many
    required: false
    inverse: hasShift
    description: Day models using this shift

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

actions:
  - name: create
    description: Create shift definition
    requiredFields: [code, name, shiftType, totalWorkHours, effectiveStartDate]

  - name: addSegment
    description: Add segment to shift
    requiredFields: [segmentId, sequenceOrder]
    affectsRelationships: [hasSegments]

  - name: configureGrace
    description: Configure grace periods
    affectsAttributes: [graceInMinutes, graceOutMinutes]

policies:
  - name: uniqueCode
    type: validation
    rule: "Shift code must be unique"

  - name: validHours
    type: validation
    rule: "totalPaidHours <= totalWorkHours"
---

# Shift

## Overview

```mermaid
mindmap
  root((Shift))
    Types
      ELAPSED["ELAPSED (fixed)"]
      PUNCH["PUNCH (flexible)"]
      FLEX["FLEX (hybrid)"]
    Timing
      referenceStartTime
      referenceEndTime
      crossMidnight
    Configuration
      graceInMinutes
      graceOutMinutes
      roundingMode
```

**Shift** là composition của các TimeSegments, định nghĩa ca làm việc. Là Level 2 trong 6-level hierarchy.

## Business Context

### Shift Types Explained

| Type | Mô tả | Use Case |
|------|-------|----------|
| **ELAPSED** | Giờ cố định, không cần punch | Office 9-5 |
| **PUNCH** | Cần clock in/out, tính theo punch | Factory workers |
| **FLEX** | Core hours + flex | Tech companies |

### 6-Level Hierarchy Position
```
TimeSegment (L1) → Shift (L2) → DayModel (L3) → WorkPattern (L4) → ScheduleRule (L5)
```

## Attributes Guide

### Grace Periods
- **graceInMinutes**: Cho phép đến trễ bao nhiêu phút không bị tính late
- **graceOutMinutes**: Cho phép về sớm bao nhiêu phút không bị tính early departure

### Rounding
- **NEAREST**: Làm tròn đến interval gần nhất
- **UP**: Làm tròn lên (có lợi cho công ty)
- **DOWN**: Làm tròn xuống (có lợi cho nhân viên)

## Relationships

```mermaid
erDiagram
    SHIFT ||--o{ TIME_SEGMENT : "hasSegments"
    SHIFT ||--o{ DAY_MODEL : "usedByDayModels"
```

## Examples

### Example 1: Day Shift (Office)
- **code**: DAY_SHIFT_8H
- **shiftType**: ELAPSED
- **referenceStartTime**: 08:00
- **referenceEndTime**: 17:00
- **totalWorkHours**: 8
- **totalBreakHours**: 1
- **totalPaidHours**: 8

### Example 2: Night Shift (Factory)
- **code**: NIGHT_SHIFT
- **shiftType**: PUNCH
- **referenceStartTime**: 22:00
- **referenceEndTime**: 06:00
- **crossMidnight**: true
- **graceInMinutes**: 15
- **roundingMode**: NEAREST

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[TimeSegment]] | hasSegments | Segments in shift |
| [[DayModel]] | usedByDayModels | Day models using shift |
