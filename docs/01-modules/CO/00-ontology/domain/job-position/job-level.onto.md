---
entity: JobLevel
domain: core-hr
version: "1.0.0"
status: draft
owner: core-team
tags: [job-position, level, reference]

classification:
  type: REFERENCE_DATA
  category: job-position

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated UUID

  - name: levelCode
    type: string
    required: true
    description: Level code

  - name: levelName
    type: string
    required: false
    description: Level name

  - name: levelTypeCode
    type: enum
    required: false
    values: [IC, MGR, EXEC]
    description: Level type

  - name: rankOrder
    type: number
    required: false
    description: Sorting order

  - name: ownerUnitId
    type: string
    required: false
    description: Owner BU

  - name: effectiveStartDate
    type: date
    required: true
    description: Effective start

  - name: effectiveEndDate
    type: date
    required: false
    description: Effective end

relationships:
  - name: usedByJobs
    target: Job
    cardinality: one-to-many
    required: false
    description: Jobs at this level

lifecycle:
  states: [active, inactive]
  initial: active

actions:
  - name: create
    description: Create job level
    requiredFields: [levelCode, effectiveStartDate]

policies:
  - name: uniqueCodePerScope
    type: validation
    rule: "Level code unique within scope"
---

# JobLevel

## Overview

**JobLevel** defines seniority tiers in the job hierarchy - from entry-level to executive. Levels are referenced by [[Job]] to indicate seniority and influence compensation banding. Supports separate Individual Contributor (IC) and Management (MGR) tracks.

```mermaid
mindmap
  root((JobLevel))
    Tracks
      IC["Individual Contributor"]
      MGR["Management"]
      EXEC["Executive"]
    Properties
      Code
      Name
      Rank
```

## Business Context

### Key Stakeholders
- **HR Compensation**: Defines levels
- **Manager**: Career conversations
- **Employee**: Understands progression

### Business Processes
- **Job Design**: Level assignment
- **Compensation**: Grade mapping
- **Career Pathing**: Level progression

### Business Value
Clear level definitions enable consistent career conversations and transparent progression paths.

## Attributes Guide

### Identification
- **levelCode**: Identifier. Format: IC1, IC2, M1, D1.
- **levelName**: Display name. e.g., "Junior", "Senior", "Lead".

### Classification
- **levelTypeCode**: Track type:
  - *IC*: Individual Contributor
  - *MGR*: Manager/People leader
  - *EXEC*: Executive/C-suite

### Ordering
- **rankOrder**: Numeric order for sorting/comparison.

## Relationships Explained

### Jobs
- **usedByJobs** → [[Job]]: Jobs at this seniority level.

## Lifecycle & Workflows

| State | Meaning |
|-------|---------|
| **active** | In use |
| **inactive** | Deprecated |

## Examples

### Example: IC Developer Track
| levelCode | levelName | rankOrder |
|-----------|-----------|-----------|
| IC1 | Junior | 1 |
| IC2 | Mid-level | 2 |
| IC3 | Senior | 3 |
| IC4 | Staff | 4 |
| IC5 | Principal | 5 |

### Example: Management Track
| levelCode | levelName | rankOrder |
|-----------|-----------|-----------|
| M1 | Team Lead | 10 |
| M2 | Manager | 11 |
| M3 | Senior Manager | 12 |
| D1 | Director | 20 |

## Related Entities

| Entity | Relationship |
|--------|--------------|
| [[Job]] | usedByJobs |
