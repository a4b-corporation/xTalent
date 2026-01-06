---
entity: GradeLadder
domain: total-rewards
version: "1.0.0"
status: draft
owner: compensation-team
tags: [job-architecture, career, ladder]

classification:
  type: AGGREGATE_ROOT
  category: job-architecture

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
    description: Ladder code
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Ladder name
    constraints:
      max: 200

  - name: description
    type: string
    required: false
    description: Career ladder description

  - name: ladderType
    type: enum
    required: false
    values: [MANAGEMENT, TECHNICAL, SPECIALIST, SALES, EXECUTIVE]
    description: Career track type

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
  - name: hasGrades
    target: Grade
    cardinality: many-to-many
    required: true
    description: Grades in this ladder

  - name: hasSteps
    target: GradeStep
    cardinality: one-to-many
    required: false
    inverse: belongsToLadder
    description: Salary steps within grades

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
    description: Create new ladder
    requiredFields: [code, name, effectiveStartDate]

  - name: addGrade
    description: Add grade to ladder
    requiredFields: [gradeId, sortOrder]
    affectsRelationships: [hasGrades]

  - name: defineSteps
    description: Define salary steps
    affectsRelationships: [hasSteps]

policies:
  - name: uniqueCode
    type: validation
    rule: "Ladder code must be unique"

  - name: hasGrades
    type: validation
    rule: "Ladder must have at least one grade when activated"
---

# GradeLadder

## Overview

```mermaid
mindmap
  root((GradeLadder))
    Types
      MANAGEMENT
      TECHNICAL
      SPECIALIST
      SALES
    Contains
      Grades
      Steps
    Use Cases
      Career Path
      Salary Band
```

**GradeLadder** định nghĩa lộ trình nghề nghiệp - chuỗi các grades mà nhân viên có thể tiến qua. Hỗ trợ nhiều track (management, technical).

## Business Context

### Key Stakeholders
- **HR Business Partner**: Design career paths
- **Compensation Team**: Map salary bands
- **Employees**: Understand progression

### Business Processes
- **Career Planning**: Define progression paths
- **Compensation Bands**: Align pay with levels
- **Performance Management**: Promotion decisions

## Relationships Explained

```mermaid
erDiagram
    GRADE_LADDER ||--o{ GRADE : "hasGrades"
    GRADE_LADDER ||--o{ GRADE_STEP : "hasSteps"
```

## Examples

### Example 1: Engineering Ladder
- **code**: ENG_LADDER
- **name**: Engineering Career Ladder
- **ladderType**: TECHNICAL
- **grades**: G1 → G2 → G3 → G4 → G5

### Example 2: Management Ladder
- **code**: MGT_LADDER
- **name**: Management Career Ladder
- **ladderType**: MANAGEMENT
- **grades**: M1 → M2 → M3 → M4 → M5

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[Grade]] | hasGrades | Levels in ladder |
| [[GradeStep]] | hasSteps | Salary steps |
