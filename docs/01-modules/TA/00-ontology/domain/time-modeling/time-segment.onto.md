---
entity: TimeSegment
domain: time-attendance
version: "1.0.0"
status: draft
owner: ta-team
tags: [time-modeling, segment, core]

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
    description: Unique segment code
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Segment name
    constraints:
      max: 100

  - name: segmentType
    type: enum
    required: true
    values: [WORK, BREAK, MEAL, TRANSFER]
    description: Type of time segment

  - name: startOffsetMin
    type: number
    required: false
    description: Minutes from shift start (relative timing)

  - name: endOffsetMin
    type: number
    required: false
    description: Minutes from shift start (relative timing)

  - name: startTime
    type: time
    required: false
    description: Absolute start time (alternative)

  - name: endTime
    type: time
    required: false
    description: Absolute end time (alternative)

  - name: durationMinutes
    type: number
    required: true
    description: Duration in minutes

  - name: isPaid
    type: boolean
    required: true
    default: false
    description: Is this segment paid

  - name: isMandatory
    type: boolean
    required: true
    default: true
    description: Is this segment mandatory

  - name: premiumCode
    type: string
    required: false
    description: Premium code for payroll (night, hazard)
    constraints:
      max: 50

  - name: effectiveStartDate
    type: date
    required: true
    description: Effective start date

  - name: effectiveEndDate
    type: date
    required: false
    description: Effective end date (null = current)

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Active status

relationships:
  - name: usedInShifts
    target: Shift
    cardinality: many-to-many
    required: false
    inverse: hasSegments
    description: Shifts that use this segment

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
    description: Create time segment
    requiredFields: [code, name, segmentType, durationMinutes, effectiveStartDate]

  - name: configure
    description: Configure timing (relative or absolute)
    affectsAttributes: [startOffsetMin, endOffsetMin, startTime, endTime]

policies:
  - name: uniqueCode
    type: validation
    rule: "Segment code must be unique"

  - name: validTiming
    type: validation
    rule: "Must have either offset OR time, not both"
---

# TimeSegment

## Overview

```mermaid
mindmap
  root((TimeSegment))
    Types
      WORK
      BREAK
      MEAL
      TRANSFER
    Timing
      Relative["Relative (offset)"]
      Absolute["Absolute (time)"]
    Attributes
      isPaid
      isMandatory
      premiumCode
```

**TimeSegment** là đơn vị thời gian nguyên tử (atomic) - building block nhỏ nhất của hệ thống Time & Attendance. Là Level 1 trong 6-level hierarchy.

## Business Context

### Key Stakeholders
- **TA Admin**: Define and configure segments
- **Payroll**: Use premium codes for calculation
- **Schedulers**: Compose shifts from segments

### 6-Level Hierarchy Position
```
TimeSegment (L1) → Shift (L2) → DayModel (L3) → WorkPattern (L4) → ScheduleRule (L5)
```

## Attributes Guide

### Timing Options
- **Relative**: Sử dụng `startOffsetMin`/`endOffsetMin` (minutes from shift start)
- **Absolute**: Sử dụng `startTime`/`endTime` (fixed time)

### Segment Types
| Type | Mô tả | isPaid |
|------|-------|--------|
| WORK | Thời gian làm việc | true |
| BREAK | Giờ nghỉ ngắn | false |
| MEAL | Giờ ăn | false |
| TRANSFER | Di chuyển | varies |

## Examples

### Example 1: Morning Work Block
- **code**: WORK_MORNING
- **segmentType**: WORK
- **startTime**: 08:00
- **endTime**: 12:00
- **durationMinutes**: 240
- **isPaid**: true

### Example 2: Lunch Break
- **code**: LUNCH_BREAK
- **segmentType**: MEAL
- **startOffsetMin**: 240 (4 hours)
- **durationMinutes**: 60
- **isPaid**: false

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[Shift]] | usedInShifts | Shifts using this segment |
