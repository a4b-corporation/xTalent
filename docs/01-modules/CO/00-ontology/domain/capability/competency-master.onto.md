---
entity: CompetencyMaster
domain: core-hr
version: "1.0.0"
status: draft
owner: core-team
tags: [capability, competency, reference]

classification:
  type: REFERENCE_DATA
  category: capability

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated UUID

  - name: competencyCode
    type: string
    required: true
    unique: true
    description: Unique competency code

  - name: competencyName
    type: string
    required: true
    description: Competency name

  - name: categoryCode
    type: enum
    required: false
    values: [CORE, LEADERSHIP, FUNCTIONAL, TECHNICAL]
    description: Competency category

  - name: description
    type: string
    required: false
    description: Competency description

  - name: behavioralIndicators
    type: object
    required: false
    description: Indicators by level

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Active status

relationships:
  - name: possessedByWorkers
    target: WorkerCompetency
    cardinality: one-to-many
    required: false
    inverse: competency
    description: Workers assessed

lifecycle:
  states: [active, inactive]
  initial: active

actions:
  - name: create
    description: Create competency
    requiredFields: [competencyCode, competencyName]

policies:
  - name: uniqueCode
    type: validation
    rule: "Competency code must be unique"
---

# CompetencyMaster

## Overview

**CompetencyMaster** is the catalog of behavioral competencies - leadership, communication, problem-solving, and other soft skills. Unlike [[SkillMaster]] which tracks technical abilities, competencies focus on behavioral traits assessed through performance reviews.

```mermaid
mindmap
  root((CompetencyMaster))
    Categories
      CORE["Core Values"]
      LEADERSHIP
      FUNCTIONAL
      TECHNICAL
```

## Business Context

### Key Stakeholders
- **HR/L&D**: Defines competency framework
- **Manager**: Uses for performance assessment
- **Employee**: Self-assessment

### Business Processes
- **Performance Management**: Competency ratings
- **Leadership Development**: Core competencies
- **Hiring**: Competency-based interviews

### Business Value
A core competency framework enables consistent behavioral assessment across the organization.

## Attributes Guide

### Identification
- **competencyCode**: Identifier. Format: COMP-LEAD, COMP-COMM.
- **competencyName**: e.g., "Leadership", "Communication".

### Classification
- **categoryCode**: Competency type:
  - *CORE*: Company values everyone needs
  - *LEADERSHIP*: For people managers
  - *FUNCTIONAL*: Role-specific behaviors
  - *TECHNICAL*: Technical leadership

### Assessment
- **behavioralIndicators**: Example behaviors by level:
```json
{
  "1": "Rarely demonstrates leadership",
  "3": "Demonstrates leadership in team settings",
  "5": "Inspires others, recognized leader"
}
```

## Relationships Explained

```mermaid
erDiagram
    COMPETENCY_MASTER ||--o{ WORKER_COMPETENCY : "possessedByWorkers"
```

### Workers
- **possessedByWorkers** → [[WorkerCompetency]]: Assessment records.

## Lifecycle & Workflows

| State | Meaning |
|-------|---------|
| **active** | Available for assessment |
| **inactive** | Retired |

## Examples

### Example: Leadership Competency
- **competencyCode**: COMP-LEAD
- **competencyName**: Leadership
- **categoryCode**: LEADERSHIP
- **description**: Ability to inspire and guide others

## Related Entities

| Entity | Relationship |
|--------|--------------|
| [[WorkerCompetency]] | possessedByWorkers |
