---
entity: WorkerCompetency
domain: person
version: "1.0.0"
status: approved
owner: Skills & Competency Team
tags: [worker, competency, junction, assessment, rating]
entityType: link

# NOTE: WorkerCompetency is a junction entity linking Worker to Competency.
# Represents ASSESSMENTS of competencies for a worker.
# Sources: 360 feedback, manager assessment, self-assessment, surveys

attributes:
  # === COMPOSITE KEY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  - name: workerId
    type: string
    required: true
    description: FK → Worker.id
  
  - name: competencyId
    type: string
    required: true
    description: FK → Competency.id
  
  # === RATING ===
  - name: ratingValue
    type: decimal
    required: false
    description: Rating score (e.g., 3.5 out of 5)
    constraints:
      min: 0
      max: 10
  
  - name: ratingScaleCode
    type: string
    required: false
    description: Rating scale used (e.g., BEHAVIORAL_1_5)
    constraints:
      maxLength: 50
  
  # === ASSESSMENT CONTEXT ===
  - name: assessedDate
    type: date
    required: false
    description: When this assessment was made
  
  - name: assessedByWorkerId
    type: string
    required: false
    description: FK → Worker.id (who assessed - null for self/360 aggregate)
  
  - name: sourceCode
    type: enum
    required: false
    description: Assessment source
    values: [SELF, MANAGER, PEER, DIRECT_REPORT, EXTERNAL, AGGREGATE_360, SURVEY]
    # SELF = Self-assessment
    # MANAGER = Manager assessment
    # PEER = Peer feedback
    # DIRECT_REPORT = Subordinate feedback
    # EXTERNAL = External assessor
    # AGGREGATE_360 = Aggregated 360 result
    # SURVEY = Pulse survey result
  
  - name: reviewCycleId
    type: string
    required: false
    description: FK → ReviewCycle.id (performance review this belongs to)
  
  # === SCD TYPE-2 ===
  - name: effectiveStartDate
    type: date
    required: true
    description: When this assessment becomes effective
  
  - name: effectiveEndDate
    type: date
    required: false
    description: When this assessment ends (null = current)
  
  - name: isCurrent
    type: boolean
    required: true
    default: true
    description: Is this the current assessment?
  
  # === METADATA ===
  - name: comments
    type: string
    required: false
    description: Qualitative feedback/comments
    constraints:
      maxLength: 2000
  
  - name: metadata
    type: json
    required: false
    description: Additional data (360 breakdown, trend, etc.)
  
  # === AUDIT ===
  - name: createdAt
    type: datetime
    required: true
    description: Record creation timestamp
  
  - name: updatedAt
    type: datetime
    required: false
    description: Last modification timestamp

relationships:
  - name: belongsToWorker
    target: Worker
    cardinality: many-to-one
    required: true
    inverse: hasCompetencyAssessments
    description: The worker being assessed.
  
  - name: refersToCompetency
    target: Competency
    cardinality: many-to-one
    required: true
    inverse: assessedForWorkers
    description: The competency being assessed.
  
  - name: assessedByWorker
    target: Worker
    cardinality: many-to-one
    required: false
    description: The assessor (null for aggregate).
  
  - name: belongsToReviewCycle
    target: ReviewCycle
    cardinality: many-to-one
    required: false
    description: The review cycle this assessment belongs to.

lifecycle:
  states: [DRAFT, SUBMITTED, VALIDATED, ARCHIVED]
  initial: DRAFT
  terminal: [ARCHIVED]
  transitions:
    - from: DRAFT
      to: SUBMITTED
      trigger: submit
      guard: Rating provided
    - from: SUBMITTED
      to: VALIDATED
      trigger: validate
      guard: Reviewed by HR/Manager
    - from: VALIDATED
      to: ARCHIVED
      trigger: archive
      guard: New assessment supersedes

policies:
  - name: UniqueWorkerCompetencySourceCurrent
    type: validation
    rule: Only one current record per worker-competency-source
    expression: "UNIQUE(workerId, competencyId, sourceCode, isCurrent = true)"
  
  - name: RatingWithinScale
    type: validation
    rule: Rating must be within competency's max level
    expression: "ratingValue IS NULL OR ratingValue <= Competency.maxRatingLevel"
    severity: WARNING
  
  - name: ManagerAssessmentHasAssessor
    type: validation
    rule: Manager assessment must have assessedByWorkerId
    expression: "sourceCode != 'MANAGER' OR assessedByWorkerId IS NOT NULL"
    severity: WARNING
---

# Entity: WorkerCompetency

## 1. Overview

**WorkerCompetency** is a junction/link entity connecting [[Worker]] to [[Competency]], representing assessments of behavioral competencies. Unlike WorkerSkill (what you can do), WorkerCompetency tracks HOW you do things.

```mermaid
mindmap
  root((WorkerCompetency))
    Keys
      workerId
      competencyId
    Rating
      ratingValue
      ratingScaleCode
    Assessment
      assessedDate
      assessedByWorkerId
      sourceCode
    Context
      reviewCycleId
      comments
    History
      SCD Type-2
    Sources
      Self
      Manager
      360 Feedback
      Survey
```

### Assessment Sources

| Source | Description | Weight (typical) |
|--------|-------------|------------------|
| **SELF** | Self-assessment | 10% |
| **MANAGER** | Direct manager | 40% |
| **PEER** | Colleagues | 20% |
| **DIRECT_REPORT** | Subordinates | 20% |
| **EXTERNAL** | External assessor | 10% |
| **AGGREGATE_360** | Combined 360 | - |

---

## 2. Attributes

### Primary Key

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique identifier |
| workerId | string | ✓ | FK → [[Worker]] |
| competencyId | string | ✓ | FK → [[Competency]] |

### Rating

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| ratingValue | decimal | | Rating score (e.g., 3.5) |
| ratingScaleCode | string | | Scale used |

### Assessment Context

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| assessedDate | date | | When assessed |
| assessedByWorkerId | string | | FK → Worker (assessor) |
| sourceCode | enum | | SELF, MANAGER, PEER, etc. |
| reviewCycleId | string | | FK → ReviewCycle |

---

## 3. Relationships

```mermaid
erDiagram
    Worker ||--o{ WorkerCompetency : hasAssessments
    Competency ||--o{ WorkerCompetency : assessedFor
    Worker ||--o{ WorkerCompetency : "assessed by"
    ReviewCycle ||--o{ WorkerCompetency : includes
    
    WorkerCompetency {
        string id PK
        string workerId FK
        string competencyId FK
        decimal ratingValue
        enum sourceCode
        string assessedByWorkerId FK
        string reviewCycleId FK
    }
```

---

## 4. Use Cases

### Self-Assessment

```yaml
WorkerCompetency:
  workerId: "worker-001"
  competencyId: "comp-leadership"
  ratingValue: 4.0
  ratingScaleCode: "BEHAVIORAL_1_5"
  assessedDate: "2025-06-15"
  sourceCode: "SELF"
  reviewCycleId: "review-2025-h1"
  comments: "I have led multiple successful projects this year"
  effectiveStartDate: "2025-06-15"
  isCurrent: true
```

### Manager Assessment

```yaml
WorkerCompetency:
  workerId: "worker-001"
  competencyId: "comp-leadership"
  ratingValue: 3.5
  ratingScaleCode: "BEHAVIORAL_1_5"
  assessedDate: "2025-06-20"
  assessedByWorkerId: "worker-manager-001"
  sourceCode: "MANAGER"
  reviewCycleId: "review-2025-h1"
  comments: "Good leadership potential, needs more strategic thinking"
  effectiveStartDate: "2025-06-20"
  isCurrent: true
```

### 360 Aggregate

```yaml
WorkerCompetency:
  workerId: "worker-001"
  competencyId: "comp-leadership"
  ratingValue: 3.7  # Weighted average
  ratingScaleCode: "BEHAVIORAL_1_5"
  assessedDate: "2025-06-25"
  sourceCode: "AGGREGATE_360"
  reviewCycleId: "review-2025-h1"
  metadata:
    breakdown:
      self: 4.0
      manager: 3.5
      peers_avg: 3.8
      directs_avg: 3.5
    weights:
      self: 0.1
      manager: 0.4
      peers: 0.25
      directs: 0.25
  effectiveStartDate: "2025-06-25"
  isCurrent: true
```

---

*Document Status: APPROVED*  
*References: [[Worker]], [[Competency]], [[ReviewCycle]]*
