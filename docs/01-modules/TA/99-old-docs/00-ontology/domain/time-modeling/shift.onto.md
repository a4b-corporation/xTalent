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
    - from: inactive
      to: active
      trigger: reactivate

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

**Shift** là composition của các [[TimeSegment]], định nghĩa ca làm việc hoàn chỉnh. Là Level 2 trong 6-level Time Hierarchy, nằm giữa [[TimeSegment]] (L1) và [[DayModel]] (L3).

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
    Grace
      graceInMinutes
      graceOutMinutes
      roundingMode
```

## Business Context

### 6-Level Time Hierarchy

Shift là Level 2 trong hierarchy:

```
┌─────────────────────────────────────────────────────────────────┐
│ L1: TimeSegment   │ Work period within a day (07:00-12:00)      │
├───────────────────┼─────────────────────────────────────────────┤
│ L2: Shift         │ Full shift = collection of TimeSegments ◄───│
├───────────────────┼─────────────────────────────────────────────┤
│ L3: DayModel      │ Model for a day (WORK/OFF/HOLIDAY)          │
├───────────────────┼─────────────────────────────────────────────┤
│ L4: WorkPattern   │ Weekly pattern = 7 DayModels                │
├───────────────────┼─────────────────────────────────────────────┤
│ L5: ScheduleRule  │ Assignment rules (rotation, eligibility)    │
├───────────────────┼─────────────────────────────────────────────┤
│ L6: WorkSchedule  │ Actual schedule assigned to employee        │
└───────────────────┴─────────────────────────────────────────────┘
```

### Key Stakeholders
- **TA Admin**: Define and configure shifts
- **Manager**: Assign shifts to team
- **Employee**: View assigned shift
- **Payroll**: Calculate pay based on shift hours

### Shift Types Explained

| Type | Mô tả | Calculation | Use Case |
|------|-------|-------------|----------|
| **ELAPSED** | Giờ cố định | Expected = totalWorkHours | Office 9-5 |
| **PUNCH** | Tính theo punch | Actual = clock-out - clock-in - breaks | Factory |
| **FLEX** | Core hours + flex | Core hours mandatory, flex around | Tech companies |

### Business Value
Shift tách riêng "ca làm việc là gì" khỏi TimeSegment details, cho phép compose linh hoạt và reuse.

## Attributes Guide

### Core Identity
- **code**: Mã duy nhất. Format: DAY_SHIFT_8H, NIGHT_SHIFT, MORNING_4H
- **name**: Tên hiển thị. VD: "Ca ngày 8h"
- **shiftType**: Loại shift (xem Shift Types table)

### Time Configuration
- **referenceStartTime / referenceEndTime**: Giờ tham chiếu
- **crossMidnight**: true nếu shift qua nửa đêm (22:00-06:00)
- **totalWorkHours / totalBreakHours / totalPaidHours**: Summary hours

### Grace & Rounding
- **graceInMinutes**: Cho phép đến trễ mà không bị tính late
- **graceOutMinutes**: Cho phép về sớm mà không bị tính early
- **roundingIntervalMin**: Khoảng làm tròn (thường 15 phút)
- **roundingMode**:
  - *NEAREST*: Làm tròn đến giá trị gần nhất
  - *UP*: Làm tròn lên (có lợi cho công ty)
  - *DOWN*: Làm tròn xuống (có lợi cho NV)

## Relationships Explained

```mermaid
erDiagram
    TIME_SEGMENT }o--o{ SHIFT : "hasSegments"
    SHIFT ||--o{ DAY_MODEL : "usedByDayModels"
```

### TimeSegment
- **hasSegments** → [[TimeSegment]]: Các segment trong shift. VD: Morning work (4h) + Lunch (1h) + Afternoon work (4h)

### DayModel
- **usedByDayModels** → [[DayModel]]: Day models sử dụng shift này

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> draft: create
    draft --> active: activate
    active --> inactive: deactivate
    inactive --> active: reactivate
```

| State | Meaning |
|-------|---------|
| **draft** | Đang setup, chưa sử dụng |
| **active** | Có thể assign cho employee |
| **inactive** | Không dùng nữa |

## Actions & Operations

### create
**Who**: TA Admin  
**Required**: code, name, shiftType, totalWorkHours, effectiveStartDate

### addSegment
**Who**: TA Admin  
**Required**: segmentId, sequenceOrder  
**Process**: Add TimeSegment to shift composition

### configureGrace
**Who**: TA Admin  
**Affects**: graceInMinutes, graceOutMinutes

## Business Rules

#### Unique Code (uniqueCode)
**Rule**: Shift code phải duy nhất.

#### Valid Hours (validHours)
**Rule**: totalPaidHours ≤ totalWorkHours.  
**Reason**: Paid hours có thể nhỏ hơn (ví dụ unpaid lunch) nhưng không thể lớn hơn work hours.

## Examples

### Example 1: Day Shift (Office)
```yaml
code: DAY_SHIFT_8H
name: "Ca ngày 8h"
shiftType: ELAPSED
referenceStartTime: "08:00"
referenceEndTime: "17:00"
totalWorkHours: 8
totalBreakHours: 1
totalPaidHours: 8
graceInMinutes: 15
roundingMode: NEAREST
```

### Example 2: Night Shift (Factory)
```yaml
code: NIGHT_SHIFT
name: "Ca đêm"
shiftType: PUNCH
referenceStartTime: "22:00"
referenceEndTime: "06:00"
crossMidnight: true
totalWorkHours: 8
totalPaidHours: 8
graceInMinutes: 15
roundingIntervalMin: 15
```

### Example 3: Flex Shift (Tech)
```yaml
code: FLEX_8H
name: "Ca linh hoạt"
shiftType: FLEX
referenceStartTime: "10:00"  # Core hours start
referenceEndTime: "16:00"    # Core hours end
totalWorkHours: 8
# Có thể đến/về linh hoạt miễn là đủ 8h và có mặt 10-16
```

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[TimeSegment]] | hasSegments | Segments in shift |
| [[DayModel]] | usedByDayModels | Day models using shift |
