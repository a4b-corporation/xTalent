---
entity: WorkPattern
domain: time-attendance
version: "1.0.0"
status: draft
owner: ta-team
tags: [scheduling, pattern, core]

classification:
  type: AGGREGATE_ROOT
  category: scheduling

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
    description: Unique pattern code
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Pattern name
    constraints:
      max: 100

  - name: description
    type: string
    required: false
    description: Pattern description

  - name: cycleLengthDays
    type: number
    required: true
    description: Number of days in pattern cycle

  - name: rotationType
    type: enum
    required: true
    values: [FIXED, ROTATING]
    description: Fixed or rotating schedule

  - name: patternJson
    type: object
    required: false
    description: Sequence of day model IDs

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
  - name: hasDayModels
    target: DayModel
    cardinality: many-to-many
    required: true
    inverse: usedByPatterns
    description: Day models in this pattern

  - name: usedByRules
    target: ScheduleRule
    cardinality: one-to-many
    required: false
    inverse: hasPattern
    description: Schedule rules using this pattern

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
    description: Create work pattern
    requiredFields: [code, name, cycleLengthDays, rotationType, effectiveStartDate]

  - name: defineDays
    description: Define day sequence
    affectsRelationships: [hasDayModels]

policies:
  - name: uniqueCode
    type: validation
    rule: "Pattern code must be unique"

  - name: validCycle
    type: validation
    rule: "cycleLengthDays must match number of day models"
---

# WorkPattern

## Overview

```mermaid
mindmap
  root((WorkPattern))
    Types
      FIXED
      ROTATING
    Cycle
      cycleLengthDays
      patternJson
    Common Patterns
      5x8["5x8 (Mon-Fri)"]
      4on4off["4on-4off"]
      rotating["14/14 rotation"]
```

**WorkPattern** định nghĩa chu kỳ làm việc - tuần 5 ngày, 4on-4off, rotating. Là Level 4 trong 6-level hierarchy.

## Business Context

### Pattern Types

| Type | Mô tả | Ví dụ |
|------|-------|-------|
| **FIXED** | Cố định hàng tuần | Mon-Fri office |
| **ROTATING** | Xoay vòng | 4on-4off factory |

### 6-Level Hierarchy Position
```
TimeSegment (L1) → Shift (L2) → DayModel (L3) → WorkPattern (L4) → ScheduleRule (L5)
```

## Relationships

```mermaid
erDiagram
    WORK_PATTERN ||--o{ DAY_MODEL : "hasDayModels"
    WORK_PATTERN ||--o{ SCHEDULE_RULE : "usedByRules"
```

## Examples

### Example 1: Standard 5x8 Week
- **code**: PATTERN_5X8
- **cycleLengthDays**: 7
- **rotationType**: FIXED
- **patternJson**: [WORK, WORK, WORK, WORK, WORK, OFF, OFF]

### Example 2: 4on-4off Factory
- **code**: PATTERN_4ON4OFF
- **cycleLengthDays**: 8
- **rotationType**: ROTATING
- **patternJson**: [WORK, WORK, WORK, WORK, OFF, OFF, OFF, OFF]

### Example 3: 14/14 Rotation (Offshore)
- **code**: PATTERN_14_14
- **cycleLengthDays**: 28
- **rotationType**: ROTATING
- **patternJson**: [14 WORK days, 14 OFF days]

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[DayModel]] | hasDayModels | Days in pattern |
| [[ScheduleRule]] | usedByRules | Rules using pattern |
