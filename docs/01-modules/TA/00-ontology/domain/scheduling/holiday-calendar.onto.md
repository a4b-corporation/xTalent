---
entity: HolidayCalendar
domain: time-attendance
version: "1.0.0"
status: draft
owner: ta-team
tags: [scheduling, holiday, reference]

classification:
  type: REFERENCE_DATA
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
    description: Unique calendar code
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Calendar name
    constraints:
      max: 100

  - name: regionCode
    type: string
    required: false
    description: Region code (VN-N, VN-S, US)
    constraints:
      max: 10

  - name: deductFlag
    type: boolean
    required: true
    default: false
    description: Deduct holidays from leave balance

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Active status

relationships:
  - name: hasHolidays
    target: HolidayDate
    cardinality: one-to-many
    required: false
    description: Holiday dates in this calendar

  - name: usedByRules
    target: ScheduleRule
    cardinality: one-to-many
    required: false
    inverse: usesHolidayCalendar
    description: Schedule rules using this calendar

lifecycle:
  states: [active, inactive]
  initial: active

actions:
  - name: create
    description: Create holiday calendar
    requiredFields: [code, name]

  - name: addHoliday
    description: Add holiday date
    affectsRelationships: [hasHolidays]

policies:
  - name: uniqueCode
    type: validation
    rule: "Calendar code must be unique"
---

# HolidayCalendar

## Overview

```mermaid
mindmap
  root((HolidayCalendar))
    Regions
      VN-N["Vietnam North"]
      VN-S["Vietnam South"]
      SG["Singapore"]
      US["United States"]
    Contains
      HolidayDate
    Used By
      ScheduleRule
      LeavePolicy
```

**HolidayCalendar** định nghĩa lịch nghỉ lễ theo vùng/quốc gia. Shared giữa Time & Attendance và Absence.

## Business Context

### Vietnam Public Holidays (11 days/year)

| Holiday | Date | Days |
|---------|------|------|
| Tết Dương lịch | 01/01 | 1 |
| Tết Nguyên đán | Lunar NY | 5 |
| Giỗ Tổ Hùng Vương | 10/3 Lunar | 1 |
| Giải phóng miền Nam | 30/04 | 1 |
| Quốc tế Lao động | 01/05 | 1 |
| Quốc khánh | 02/09 | 2 |

## Relationships

```mermaid
erDiagram
    HOLIDAY_CALENDAR ||--o{ HOLIDAY_DATE : "hasHolidays"
    HOLIDAY_CALENDAR ||--o{ SCHEDULE_RULE : "usedByRules"
```

## Examples

### Example 1: Vietnam National Calendar
- **code**: VN_HOLIDAYS
- **name**: Vietnam Public Holidays
- **regionCode**: VN
- **deductFlag**: false

### Example 2: Singapore Calendar
- **code**: SG_HOLIDAYS
- **name**: Singapore Public Holidays
- **regionCode**: SG
- **deductFlag**: false

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[ScheduleRule]] | usedByRules | Rules using calendar |
