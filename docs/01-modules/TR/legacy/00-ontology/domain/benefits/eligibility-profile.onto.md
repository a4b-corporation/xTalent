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

  - name: appliesToIncentives
    target: IncentivePlan
    cardinality: many-to-many
    required: false
    description: Incentive plans using this profile

lifecycle:
  states: [active, inactive]
  initial: active
  transitions:
    - from: active
      to: inactive
      trigger: deactivate

actions:
  - name: create
    description: Create eligibility profile
    requiredFields: [code, name, ruleJson, effectiveStartDate]

  - name: updateRule
    description: Update eligibility rule
    affectsAttributes: [ruleJson]

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

**EligibilityProfile** định nghĩa điều kiện để nhân viên đủ điều kiện tham gia các chương trình benefits, incentives, recognition. Dùng chung cho nhiều programs.

```mermaid
mindmap
  root((EligibilityProfile))
    Criteria
      Employment["Employment Status"]
      Tenure["Tenure (days)"]
      Grade["Grade Level"]
      Location
      Department
    Applied To
      Benefits
      Incentives
      Recognition
      Leave
```

## Business Context

### Key Stakeholders
- **Benefits Team**: Define eligibility for benefit plans
- **Compensation Team**: Define eligibility for incentives
- **HR Admin**: Check employee eligibility
- **System**: Auto-evaluate eligibility

### Eligibility Criteria Types

| Criteria | Description | Example |
|----------|-------------|---------|
| **Employment Status** | ACTIVE, PROBATION, etc. | = ACTIVE |
| **Tenure** | Days since hire | >= 90 days |
| **Grade Level** | Job grade | in (G3, G4, G5) |
| **Employment Type** | FULLTIME, PARTTIME | = FULLTIME |
| **Location** | Work location | = HCM |
| **Department** | Org unit | = Engineering |

### Business Value
EligibilityProfile cho phép define once, apply many - cùng một profile có thể dùng cho nhiều benefit plans, incentive plans.

## Attributes Guide

### Core Identity
- **code**: Mã duy nhất. Format: FT_90DAYS, MANAGER_LEVEL
- **name**: Tên hiển thị. VD: "Full-time After 90 Days"

### Rule Configuration (ruleJson)

**Rule Structure:**
```json
{
  "type": "AND|OR",
  "conditions": [
    {
      "field": "string",
      "op": "eq|neq|gt|gte|lt|lte|in|contains",
      "value": "any"
    }
  ]
}
```

**Available Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `employmentStatus` | enum | ACTIVE, PROBATION, etc. |
| `employeeType` | enum | FULLTIME, PARTTIME, etc. |
| `tenure` | number | Days since hire |
| `gradeCode` | string | Job grade code |
| `locationCode` | string | Work location |
| `departmentCode` | string | Department code |
| `jobFamilyCode` | string | Job family |

## Relationships Explained

```mermaid
erDiagram
    ELIGIBILITY_PROFILE }o--o{ BENEFIT_PLAN : "appliesTo"
    ELIGIBILITY_PROFILE }o--o{ INCENTIVE_PLAN : "appliesToIncentives"
    ELIGIBILITY_PROFILE }o--o{ LEAVE_POLICY : "appliesToLeave"
```

### Cross-Module Usage
EligibilityProfile is shared across:
- [[BenefitPlan]] - Benefit enrollment
- [[IncentivePlan]] - Bonus eligibility
- [[LeavePolicy]] - Leave entitlement

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> active: create
    active --> inactive: deactivate
    inactive --> active: reactivate
```

### Eligibility Evaluation Flow

```mermaid
flowchart LR
    A[Employee Data] --> B[Load Profile Rules]
    B --> C{Evaluate Conditions}
    C -->|All Pass| D[ELIGIBLE]
    C -->|Any Fail| E[NOT ELIGIBLE]
```

## Actions & Operations

### create
**Who**: HR Policy Team  
**Required**: code, name, ruleJson, effectiveStartDate

### updateRule
**Who**: HR Policy Team  
**Purpose**: Cập nhật điều kiện eligibility  
**Affects**: ruleJson

## Business Rules

#### Unique Code (uniqueCode)
**Rule**: Profile code phải duy nhất.

#### Valid Rule (validRule)
**Rule**: ruleJson phải có format hợp lệ.

## Examples

### Example 1: Full-time After 90 Days
```yaml
code: FT_90DAYS
name: "Full-time After 90 Days"
ruleJson:
  type: AND
  conditions:
    - field: employmentStatus
      op: eq
      value: ACTIVE
    - field: employeeType
      op: eq
      value: FULLTIME
    - field: tenure
      op: gte
      value: 90
```

### Example 2: Manager Level and Above
```yaml
code: MANAGER_LEVEL
name: "Manager Level and Above"
ruleJson:
  type: AND
  conditions:
    - field: gradeCode
      op: in
      value: ["M1", "M2", "M3", "M4"]
    - field: employmentStatus
      op: eq
      value: ACTIVE
```

### Example 3: HCM Office Only
```yaml
code: HCM_OFFICE
name: "HCM Office Employees"
ruleJson:
  type: AND
  conditions:
    - field: locationCode
      op: eq
      value: HCM
    - field: employeeType
      op: in
      value: ["FULLTIME", "PARTTIME"]
```

### Example 4: Complex OR Condition
```yaml
code: TECH_OR_SENIOR
name: "Tech Department or Senior Grade"
ruleJson:
  type: OR
  conditions:
    - field: departmentCode
      op: eq
      value: ENGINEERING
    - field: gradeCode
      op: in
      value: ["S1", "S2", "M1"]
```

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[BenefitPlan]] | appliesTo | Benefit eligibility |
| [[IncentivePlan]] | appliesToIncentives | Incentive eligibility |
| [[LeavePolicy]] | appliesToLeave | Leave eligibility |
