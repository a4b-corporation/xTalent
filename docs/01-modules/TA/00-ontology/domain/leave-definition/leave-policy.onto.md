---
entity: LeavePolicy
domain: time-attendance
version: "1.0.0"
status: draft
owner: absence-team
tags: [leave-definition, policy, core]

classification:
  type: AGGREGATE_ROOT
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
    description: Policy code
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Policy name
    constraints:
      max: 100

  - name: defaultEligibilityProfileId
    type: string
    required: false
    description: Default eligibility profile

  - name: accrualRuleJson
    type: object
    required: false
    description: Accrual rules (rate, frequency)

  - name: carryRuleJson
    type: object
    required: false
    description: Carry-over rules

  - name: overdraftAllowed
    type: boolean
    required: true
    default: false
    description: Allow negative balance

  - name: overdraftLimitHours
    type: number
    required: false
    description: Max overdraft hours

  - name: limitRuleJson
    type: object
    required: false
    description: Limit rules (yearly, monthly)

  - name: checkLimitLine
    type: boolean
    required: true
    default: true
    description: Check limits on request

  - name: effectiveStartDate
    type: date
    required: true
    description: Effective start date

  - name: effectiveEndDate
    type: date
    required: false
    description: Effective end date

relationships:
  - name: belongsToClass
    target: LeaveClass
    cardinality: many-to-one
    required: false
    inverse: hasPolicies
    description: Parent leave class

  - name: usesEligibilityProfile
    target: EligibilityProfile
    cardinality: many-to-one
    required: false
    description: Eligibility criteria

lifecycle:
  states: [active, inactive]
  initial: active

actions:
  - name: create
    description: Create leave policy
    requiredFields: [typeCode, code, name, effectiveStartDate]

  - name: configureAccrual
    description: Configure accrual rules
    affectsAttributes: [accrualRuleJson]

  - name: configureCarry
    description: Configure carry-over rules
    affectsAttributes: [carryRuleJson]

policies:
  - name: uniqueCode
    type: validation
    rule: "Policy code must be unique"
---

# LeavePolicy

## Overview

```mermaid
mindmap
  root((LeavePolicy))
    Rules
      Accrual
      CarryOver
      Limits
      Overdraft
    Eligibility
      EligibilityProfile
```

**LeavePolicy** định nghĩa rules cho nghỉ phép - accrual, carry-over, overdraft.

## Business Context

### Policy Components

| Component | Mô tả |
|-----------|-------|
| **Accrual** | Cách tích lũy (monthly, yearly, front-load) |
| **Carry-over** | Chuyển số dư sang năm sau |
| **Limits** | Giới hạn tối đa (yearly, monthly, per request) |
| **Overdraft** | Cho phép số dư âm |

### Accrual Types

| Type | Mô tả |
|------|-------|
| MONTHLY | Tích lũy hàng tháng (1 day/month) |
| YEARLY | Cấp đầu năm (12 days/year) |
| FRONT_LOAD | Cấp ngay khi đủ điều kiện |
| HIRE_ANNIVERSARY | Cấp theo ngày vào làm |

## Relationships

```mermaid
erDiagram
    LEAVE_POLICY }o--o| LEAVE_CLASS : "belongsToClass"
    LEAVE_POLICY }o--o| ELIGIBILITY_PROFILE : "usesEligibilityProfile"
```

## Examples

### Example 1: VN Annual Leave Policy
```json
{
  "accrualRuleJson": {
    "type": "YEARLY",
    "amount": 12,
    "unit": "DAY",
    "seniorityBonus": {
      "perYears": 5,
      "bonusDays": 1
    }
  },
  "carryRuleJson": {
    "allowed": true,
    "maxDays": 5,
    "expiryMonths": 3
  },
  "overdraftAllowed": false
}
```

### Example 2: Sick Leave Policy
```json
{
  "limitRuleJson": {
    "yearlyMaxDays": 30,
    "perCaseMaxDays": 7,
    "requiresMedicalCert": true
  }
}
```

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[LeaveClass]] | belongsToClass | Parent class |
| [[EligibilityProfile]] | usesEligibilityProfile | Eligibility rules |
