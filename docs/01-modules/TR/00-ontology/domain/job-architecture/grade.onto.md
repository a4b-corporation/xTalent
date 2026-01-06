---
entity: Grade
domain: total-rewards
version: "1.0.0"
status: draft
owner: compensation-team
tags: [job-architecture, grade, core]

classification:
  type: AGGREGATE_ROOT
  category: job-architecture

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated UUID

  - name: gradeCode
    type: string
    required: true
    description: Grade code (unique per current version)
    constraints:
      max: 20

  - name: name
    type: string
    required: true
    description: Grade name
    constraints:
      max: 100

  - name: description
    type: string
    required: false
    description: Grade description

  - name: jobLevel
    type: number
    required: false
    description: Hierarchy level (1=entry, 10=executive)

  - name: sortOrder
    type: number
    required: true
    default: 0
    description: Display order

  - name: effectiveStartDate
    type: date
    required: true
    description: Version start date

  - name: effectiveEndDate
    type: date
    required: false
    description: Version end date

  - name: versionNumber
    type: number
    required: true
    default: 1
    description: SCD-2 version number

  - name: isCurrentVersion
    type: boolean
    required: true
    default: true
    description: Current version flag

relationships:
  - name: hasPayRanges
    target: PayRange
    cardinality: one-to-many
    required: false
    inverse: belongsToGrade
    description: Pay ranges for this grade

  - name: inLadders
    target: GradeLadder
    cardinality: many-to-many
    required: false
    description: Career ladders containing this grade

  - name: previousVersion
    target: Grade
    cardinality: many-to-one
    required: false
    description: Previous version (SCD-2 chain)

lifecycle:
  states: [draft, active, archived]
  initial: draft
  transitions:
    - from: draft
      to: active
      trigger: publish
    - from: active
      to: archived
      trigger: archive

actions:
  - name: create
    description: Create new grade
    requiredFields: [gradeCode, name, effectiveStartDate]

  - name: publish
    description: Publish the grade
    triggersTransition: publish

  - name: createNewVersion
    description: Create new version (supersedes current)
    requiredFields: [effectiveStartDate]

policies:
  - name: uniqueCurrentCode
    type: validation
    rule: "Grade code must be unique among current versions"

  - name: versionChain
    type: business
    rule: "New version's effective date must be after previous version"
---

# Grade

## Overview

```mermaid
mindmap
  root((Grade))
    Identification
      gradeCode
      name
      jobLevel
    Versioning
      versionNumber
      effectiveStartDate
      isCurrentVersion
    Relationships
      PayRange
      GradeLadder
```

**Grade** đại diện cho cấp bậc trong tổ chức. Mỗi grade có pay range và có thể thuộc nhiều career ladders. Sử dụng SCD-2 để track history.

## Business Context

### Key Stakeholders
- **Compensation Team**: Define grade structure
- **HR Business Partner**: Job evaluation, grading decisions
- **Managers**: Understand team levels

### Business Processes
- **Job Evaluation**: Assign grade to positions
- **Compensation Planning**: Define pay ranges per grade
- **Career Pathing**: Map progression through grades

## Attributes Guide

### Job Level
- Level 1-3: Entry/Junior
- Level 4-6: Mid-level/Senior
- Level 7-8: Lead/Principal
- Level 9-10: Director/Executive

### SCD-2 Versioning
- **versionNumber**: Increments với mỗi version mới
- **previousVersionId**: Link đến version trước
- **isCurrentVersion**: True cho version active

## Relationships Explained

```mermaid
erDiagram
    GRADE ||--o{ PAY_RANGE : "hasPayRanges"
    GRADE }o--o{ GRADE_LADDER : "inLadders"
    GRADE }o--o| GRADE : "previousVersion"
```

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> draft: create
    draft --> active: publish
    active --> active: createNewVersion
    active --> archived: archive
```

## Examples

### Example 1: Software Engineer Grades
| Grade | Name | Job Level |
|-------|------|-----------|
| G1 | Junior Engineer | 1 |
| G2 | Engineer | 2 |
| G3 | Senior Engineer | 4 |
| G4 | Staff Engineer | 6 |
| G5 | Principal Engineer | 8 |

### Example 2: Management Grades
| Grade | Name | Job Level |
|-------|------|-----------|
| M1 | Team Lead | 5 |
| M2 | Manager | 7 |
| M3 | Senior Manager | 8 |
| M4 | Director | 9 |

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[PayRange]] | hasPayRanges | Salary ranges |
| [[GradeLadder]] | inLadders | Career paths |
| [[GradeStep]] | via ladder | Steps within grade |
