---
entity: ScheduleRule
domain: time-attendance
version: "1.0.0"
status: draft
owner: ta-team
tags: [scheduling, rule, core]

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
    description: Unique rule code
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Rule name
    constraints:
      max: 100

  - name: patternId
    type: string
    required: true
    description: FK to WorkPattern

  - name: holidayCalendarId
    type: string
    required: false
    description: FK to HolidayCalendar

  - name: startReferenceDate
    type: date
    required: true
    description: Rotation anchor date

  - name: offsetDays
    type: number
    required: true
    default: 0
    description: Offset from pattern start

  - name: employeeId
    type: string
    required: false
    description: Specific employee (null = group)

  - name: employeeGroupId
    type: string
    required: false
    description: Employee group/unit

  - name: positionId
    type: string
    required: false
    description: Position assignment

  - name: effectiveStartDate
    type: date
    required: true
    description: Effective start date

  - name: effectiveEndDate
    type: date
    required: false
    description: Effective end date

relationships:
  - name: hasPattern
    target: WorkPattern
    cardinality: many-to-one
    required: true
    inverse: usedByRules
    description: Pattern for this rule

  - name: usesHolidayCalendar
    target: HolidayCalendar
    cardinality: many-to-one
    required: false
    inverse: usedByRules
    description: Holiday calendar

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
    description: Create schedule rule
    requiredFields: [code, name, patternId, startReferenceDate, effectiveStartDate]

  - name: assignToEmployee
    description: Assign to specific employee
    affectsAttributes: [employeeId]

  - name: assignToGroup
    description: Assign to employee group
    affectsAttributes: [employeeGroupId]

policies:
  - name: uniqueCode
    type: validation
    rule: "Rule code must be unique"

  - name: validAssignment
    type: validation
    rule: "Must have at least one of: employeeId, employeeGroupId, positionId"
---

# ScheduleRule

## Overview

```mermaid
mindmap
  root((ScheduleRule))
    Combines
      WorkPattern
      HolidayCalendar
      RotationOffset
    Applies To
      Employee
      Group
      Position
```

**ScheduleRule** kết hợp pattern + calendar và gán cho nhân viên/group. Là Level 5 trong 6-level hierarchy.

## Business Context

### Assignment Types

| Type | Mô tả |
|------|-------|
| Employee | Gán cho 1 nhân viên cụ thể |
| Group | Gán cho đơn vị/phòng ban |
| Position | Gán theo vị trí công việc |

### 6-Level Hierarchy Position
```
TimeSegment (L1) → Shift (L2) → DayModel (L3) → WorkPattern (L4) → ScheduleRule (L5) → Roster (L6)
```

## Relationships

```mermaid
erDiagram
    SCHEDULE_RULE }o--|| WORK_PATTERN : "hasPattern"
    SCHEDULE_RULE }o--o| HOLIDAY_CALENDAR : "usesHolidayCalendar"
    SCHEDULE_RULE }o--o| EMPLOYEE : "appliesTo"
    SCHEDULE_RULE }o--o| ORG_UNIT : "appliesTo"
```

## Examples

### Example 1: Engineering Team Schedule
- **code**: ENG_SCHEDULE
- **patternId**: PATTERN_5X8
- **holidayCalendarId**: VN_HOLIDAYS
- **employeeGroupId**: ENGINEERING_DEPT
- **startReferenceDate**: 2026-01-06 (Monday)

### Example 2: Factory Rotating Schedule
- **code**: FACTORY_ROTATION
- **patternId**: PATTERN_4ON4OFF
- **holidayCalendarId**: VN_HOLIDAYS
- **employeeGroupId**: FACTORY_TEAM_A
- **offsetDays**: 0 (Team B has offsetDays: 4)

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[WorkPattern]] | hasPattern | Pattern for rule |
| [[HolidayCalendar]] | usesHolidayCalendar | Holidays |
