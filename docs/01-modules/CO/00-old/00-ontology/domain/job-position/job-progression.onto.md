---
entity: JobProgression
domain: core-hr
version: "1.0.0"
status: draft
owner: core-team
tags: [job-position, progression, entity]

classification:
  type: ENTITY
  category: job-position

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated UUID

  - name: fromJobId
    type: string
    required: true
    description: Source job

  - name: toJobId
    type: string
    required: true
    description: Target job

  - name: progressionTypeCode
    type: enum
    required: true
    values: [PROMOTION, LATERAL, CROSS_FUNC, DEMOTION]
    description: Progression type

  - name: minTenureMonths
    type: number
    required: false
    description: Minimum tenure required

  - name: requiredSkills
    type: array
    required: false
    description: Skills required for progression

  - name: autoRecommendedFlag
    type: boolean
    required: true
    default: false
    description: Show in recommendations

  - name: effectiveStartDate
    type: date
    required: true
    description: Effective start

relationships:
  - name: fromJob
    target: Job
    cardinality: many-to-one
    required: true
    description: Source job

  - name: toJob
    target: Job
    cardinality: many-to-one
    required: true
    description: Target job

lifecycle:
  states: [active, inactive]
  initial: active

actions:
  - name: create
    description: Create job progression
    requiredFields: [fromJobId, toJobId, progressionTypeCode, effectiveStartDate]

policies:
  - name: uniquePath
    type: validation
    rule: "One active progression per from-to pair"

  - name: noSelfProgression
    type: validation
    rule: "Source and target job must be different"
---

# JobProgression

## Overview

**JobProgression** defines allowed transitions between [[Job]]s - promotion paths, lateral moves, and cross-functional opportunities. Used by career tools to show employees where they can go next and what requirements exist for advancement.

```mermaid
mindmap
  root((JobProgression))
    Types
      PROMOTION
      LATERAL
      CROSS_FUNC
      DEMOTION
    Requirements
      Tenure
      Skills
```

## Business Context

### Key Stakeholders
- **HR Compensation**: Defines career paths
- **Manager**: Career guidance
- **Employee**: Sees progression options

### Business Processes
- **Career Planning**: Next role recommendations
- **Succession Planning**: Pipeline visibility
- **Development**: Gap identification

### Business Value
Clear progression rules enable transparent career development and targeted skill building.

## Attributes Guide

### Path Definition
- **fromJobId**: Current job (source).
- **toJobId**: Target job (destination).
- **progressionTypeCode**: Type of move:
  - *PROMOTION*: Upward (higher level)
  - *LATERAL*: Same level, different area
  - *CROSS_FUNC*: Different function
  - *DEMOTION*: Downward

### Requirements
- **minTenureMonths**: Minimum time in current role.
- **requiredSkills**: Skills needed for target.

## Relationships Explained

```mermaid
erDiagram
    JOB_PROGRESSION }o--|| JOB : "fromJob"
    JOB_PROGRESSION }o--|| JOB : "toJob"
```

### Jobs
- **fromJob/toJob** → [[Job]]: Source and target of progression.

## Lifecycle & Workflows

| State | Meaning |
|-------|---------|
| **active** | Path available |
| **inactive** | Path closed |

## Examples

### Example: Developer Career Path
```
Junior Dev → Developer (PROMOTION, 12 months)
Developer → Senior Dev (PROMOTION, 24 months)
Developer → DevOps (LATERAL)
```

## Related Entities

| Entity | Relationship |
|--------|--------------|
| [[Job]] | fromJob, toJob |
| [[CareerPath]] | usedBy |
