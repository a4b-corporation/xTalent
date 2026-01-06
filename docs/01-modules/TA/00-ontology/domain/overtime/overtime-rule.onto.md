---
entity: OvertimeRule
domain: time-attendance
version: "1.0.0"
status: draft
owner: ta-team
tags: [overtime, rule, core]

classification:
  type: AGGREGATE_ROOT
  category: overtime

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

  - name: ruleType
    type: enum
    required: true
    values: [DAILY, WEEKLY, CONSECUTIVE_DAYS, HOLIDAY, NIGHT_SHIFT]
    description: Type of overtime rule

  - name: thresholdHours
    type: number
    required: true
    description: Hours after which OT applies

  - name: multiplier
    type: number
    required: true
    description: OT multiplier (1.5, 2.0, 3.0)

  - name: requiresApproval
    type: boolean
    required: true
    default: true
    description: Requires pre-approval

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

lifecycle:
  states: [active, inactive]
  initial: active

actions:
  - name: create
    description: Create overtime rule
    requiredFields: [code, name, ruleType, thresholdHours, multiplier, effectiveStartDate]

policies:
  - name: uniqueCode
    type: validation
    rule: "Rule code must be unique"

  - name: validMultiplier
    type: validation
    rule: "Multiplier must be >= 1.0"
---

# OvertimeRule

## Overview

```mermaid
mindmap
  root((OvertimeRule))
    Types
      DAILY
      WEEKLY
      HOLIDAY
      NIGHT_SHIFT
    Configuration
      thresholdHours
      multiplier
      requiresApproval
```

**OvertimeRule** định nghĩa quy tắc tính làm thêm giờ - threshold và multiplier.

## Business Context

### Vietnam OT Regulations (Labor Code 2019)

| Rule Type | Threshold | Multiplier | Note |
|-----------|-----------|------------|------|
| DAILY | 8 hours | 1.5x | Normal day OT |
| WEEKLY | 40 hours | 1.5x | Weekly OT |
| HOLIDAY | 0 hours | 3.0x | Holiday work |
| NIGHT_SHIFT | 22:00-06:00 | +30% | Night premium |

### OT Limits (Article 107)
- Daily: max 4 hours
- Monthly: max 40 hours
- Yearly: max 200 hours (300 for specific industries)

## Examples

### Example 1: Daily OT 150%
- **code**: VN_OT_DAILY_150
- **ruleType**: DAILY
- **thresholdHours**: 8
- **multiplier**: 1.5

### Example 2: Weekend OT 200%
- **code**: VN_OT_WEEKEND_200
- **ruleType**: DAILY
- **thresholdHours**: 0
- **multiplier**: 2.0

### Example 3: Holiday OT 300%
- **code**: VN_OT_HOLIDAY_300
- **ruleType**: HOLIDAY
- **thresholdHours**: 0
- **multiplier**: 3.0

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[Shift]] | appliesTo | Shifts with OT |
