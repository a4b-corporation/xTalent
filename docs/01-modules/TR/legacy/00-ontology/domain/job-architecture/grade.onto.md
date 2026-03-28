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

**Grade** đại diện cho cấp bậc trong tổ chức. Là AGGREGATE_ROOT của job architecture, mỗi grade có [[PayRange]] và có thể thuộc nhiều [[GradeLadder]]. Sử dụng SCD-2 để track history.

```mermaid
mindmap
  root((Grade))
    Identity
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

## Business Context

### Key Stakeholders
- **Compensation Team**: Define grade structure
- **HR Business Partner**: Job evaluation, grading decisions
- **Managers**: Understand team levels
- **Employees**: Career progression visibility

### Job Level Tiers

| Level | Tier | Description | Example Grades |
|-------|------|-------------|----------------|
| 1-3 | Entry/Junior | New hires, learning | G1, G2, G3 |
| 4-6 | Mid/Senior | Experienced, independent | G4, G5, G6 |
| 7-8 | Lead/Principal | Expert, leads work | G7, G8 |
| 9-10 | Director/Executive | Leadership, strategy | M4, M5, E1 |

### Business Value
Grade là foundation của compensation structure - định nghĩa level hierarchy, link với pay ranges, và enable career pathing.

## Attributes Guide

### Core Identity
- **gradeCode**: Mã duy nhất. Format: G1, G2, M1, M2
- **name**: Tên hiển thị. VD: "Senior Engineer"
- **description**: Mô tả chi tiết responsibilities
- **jobLevel**: Số thứ tự hierarchy (1-10)
- **sortOrder**: Thứ tự hiển thị

### SCD-2 Versioning
Grade sử dụng SCD-2 để track history:
- **versionNumber**: Tăng với mỗi version mới
- **effectiveStartDate / effectiveEndDate**: Khoảng thời gian hiệu lực
- **isCurrentVersion**: True cho version active
- **previousVersionId**: Link đến version trước

## Relationships Explained

```mermaid
erDiagram
    GRADE ||--o{ PAY_RANGE : "hasPayRanges"
    GRADE }o--o{ GRADE_LADDER : "inLadders"
    GRADE }o--o| GRADE : "previousVersion"
    POSITION }o--|| GRADE : "hasGrade"
```

### PayRange
- **hasPayRanges** → [[PayRange]]: Khung lương cho grade này, có thể có nhiều ranges theo scope (legal entity, location)

### GradeLadder
- **inLadders** → [[GradeLadder]]: Career ladders chứa grade này (technical, management, etc.)

### Version Chain
- **previousVersion** → Grade: Link đến version trước (SCD-2)

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> draft: create
    draft --> active: publish
    active --> active: createNewVersion
    active --> archived: archive
```

| State | Meaning |
|-------|---------|
| **draft** | Đang setup, chưa sử dụng |
| **active** | Đang sử dụng |
| **archived** | Đã superseded bởi version mới |

### Version Flow

```mermaid
flowchart LR
    A[Grade v1] -->|createNewVersion| B[Grade v2]
    B --> C[v1.isCurrentVersion = false]
    B --> D[v2.isCurrentVersion = true]
```

## Actions & Operations

### create
**Who**: Compensation Team  
**Required**: gradeCode, name, effectiveStartDate

### publish
**Who**: Compensation Team  
**When**: Ready for use

### createNewVersion
**Who**: Compensation Team  
**When**: Pay range changes, restructuring  
**Required**: effectiveStartDate  
**Effect**: Current version archived, new version active

## Business Rules

#### Unique Current Code (uniqueCurrentCode)
**Rule**: Grade code unique among current versions.

#### Version Chain (versionChain)
**Rule**: New version's effectiveStartDate must be after previous version.

## Examples

### Example 1: Software Engineering Grades
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

### Example 3: Grade with Pay Range
```yaml
gradeCode: G3
name: "Senior Engineer"
jobLevel: 4
payRanges:
  - scope: VNG-VN
    currency: VND
    min: 25000000
    mid: 35000000
    max: 45000000
  - scope: VNG-SG
    currency: SGD
    min: 6000
    mid: 8000
    max: 10000
```

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[PayRange]] | hasPayRanges | Salary ranges |
| [[GradeLadder]] | inLadders | Career paths |
| [[Position]] | indirect | Positions at this grade |
