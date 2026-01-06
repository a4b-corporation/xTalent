---
entity: WorkerCompetency
domain: core-hr
version: "1.0.0"
status: draft
owner: core-team
tags: [person, competency, entity]

classification:
  type: ENTITY
  category: person

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated UUID

  - name: workerId
    type: string
    required: true
    description: FK to Worker

  - name: competencyId
    type: string
    required: true
    description: FK to CompetencyMaster

  - name: ratingValue
    type: number
    required: false
    description: Rating score (1-5)
    constraints:
      min: 1
      max: 5

  - name: assessedDate
    type: date
    required: false
    description: Assessment date

  - name: assessedByWorkerId
    type: string
    required: false
    description: Assessor

  - name: sourceCode
    type: enum
    required: false
    values: [SELF, MANAGER, 360, SURVEY]
    description: Assessment source

  - name: effectiveStartDate
    type: date
    required: true
    description: Effective start

relationships:
  - name: belongsToWorker
    target: Worker
    cardinality: many-to-one
    required: true
    inverse: hasCompetencies
    description: Worker assessed

  - name: competency
    target: CompetencyMaster
    cardinality: many-to-one
    required: true
    description: The competency

lifecycle:
  states: [active, inactive]
  initial: active

actions:
  - name: assess
    description: Create competency assessment
    requiredFields: [workerId, competencyId, effectiveStartDate]

policies:
  - name: uniquePerWorker
    type: validation
    rule: "One active record per competency per worker"
---

# WorkerCompetency

## Overview

**WorkerCompetency** records a worker's behavioral competency assessment from [[CompetencyMaster]] - leadership, communication, problem-solving. Unlike [[WorkerSkill]] (technical abilities), competencies focus on behavioral traits and soft skills assessed through performance reviews and 360 feedback.

```mermaid
mindmap
  root((WorkerCompetency))
    Competency
      CompetencyMaster
    Assessment
      Rating
      Source
      Assessor
```

## Business Context

### Key Stakeholders
- **Manager**: Performance assessment
- **HR/L&D**: Competency analytics
- **Employee**: Development planning

### Business Processes
- **Performance Reviews**: Competency ratings
- **360 Feedback**: Multi-source assessment
- **Leadership Development**: Gap identification

### Business Value
Competency tracking enables targeted leadership development and performance improvement.

## Attributes Guide

### Assessment
- **competencyId**: Links to [[CompetencyMaster]].
- **ratingValue**: 1-5 scale per competency framework.
- **sourceCode**: Assessment origin:
  - *SELF*: Self-assessment
  - *MANAGER*: Manager review
  - *360*: 360-degree feedback
  - *SURVEY*: Organization survey

## Relationships Explained

```mermaid
erDiagram
    WORKER_COMPETENCY }o--|| WORKER : "belongsToWorker"
    WORKER_COMPETENCY }o--|| COMPETENCY_MASTER : "competency"
```

## Lifecycle & Workflows

| State | Meaning |
|-------|---------|
| **active** | Current assessment |
| **inactive** | Historical |

## Examples

### Example: Leadership Rating
- **competencyId**: COMP-LEADERSHIP
- **ratingValue**: 4
- **sourceCode**: MANAGER
- **assessedDate**: 2024-06-15

## Related Entities

| Entity | Relationship |
|--------|--------------|
| [[Worker]] | belongsToWorker |
| [[CompetencyMaster]] | competency |
