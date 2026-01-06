---
entity: EligibilityProfile
domain: total-rewards
version: "1.0.0"
status: draft
owner: benefits-team
tags: [benefits, eligibility, rule]

classification:
  type: ENTITY
  category: benefits

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
    description: Profile code
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Profile name
    constraints:
      max: 200

  - name: ruleJson
    type: object
    required: true
    description: Eligibility criteria (tenure, grade, location, etc.)

  - name: effectiveStartDate
    type: date
    required: true
    description: Start date

  - name: effectiveEndDate
    type: date
    required: false
    description: End date

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Active status

relationships:
  - name: appliesTo
    target: BenefitPlan
    cardinality: many-to-many
    required: false
    inverse: hasEligibilityProfiles
    description: Plans using this profile

lifecycle:
  states: [active, inactive]
  initial: active

actions:
  - name: create
    description: Create eligibility profile
    requiredFields: [code, name, ruleJson, effectiveStartDate]

policies:
  - name: uniqueCode
    type: validation
    rule: "Profile code must be unique"

  - name: validRule
    type: validation
    rule: "ruleJson must be valid eligibility criteria"
---

# EligibilityProfile

## Overview

```mermaid
mindmap
  root((EligibilityProfile))
    Criteria
      Employment Status
      Tenure
      Grade Level
      Location
      Department
    Applied To
      Benefits
      Incentives
      Recognition
```

**EligibilityProfile** định nghĩa điều kiện để nhân viên đủ điều kiện tham gia các chương trình benefits, incentives.

## Attributes Guide

### ruleJson Examples

**Tenure-based:**
```json
{
  "type": "AND",
  "conditions": [
    {"field": "employmentStatus", "op": "eq", "value": "ACTIVE"},
    {"field": "tenure", "op": "gte", "value": 90}
  ]
}
```

**Grade-based:**
```json
{
  "type": "AND", 
  "conditions": [
    {"field": "gradeCode", "op": "in", "value": ["G3", "G4", "G5"]},
    {"field": "employeeType", "op": "eq", "value": "FULLTIME"}
  ]
}
```

## Examples

### Example 1: Full-time 90 Days
- **code**: FT_90DAYS
- **name**: Full-time After 90 Days
- **rule**: Employment = ACTIVE AND Tenure >= 90 days

### Example 2: Manager Level
- **code**: MANAGER_LEVEL
- **name**: Manager Level and Above
- **rule**: Grade in (M1, M2, M3, M4)

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[BenefitPlan]] | appliesTo | Plans using profile |
