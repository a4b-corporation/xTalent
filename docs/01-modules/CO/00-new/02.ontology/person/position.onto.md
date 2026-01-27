---
entity: Position
domain: jobpos
version: "1.0.0"
status: approved
owner: Job & Position Management Team
tags: [position, org-structure, headcount, staffing, tr-integration]

attributes:
  # === IDENTITY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  - name: code
    type: string
    required: true
    unique: true
    description: Position code (unique across organization)
    constraints:
      maxLength: 50
  
  - name: title
    type: string
    required: true
    description: Position title (e.g., "Senior Software Engineer - Team Lead")
    constraints:
      maxLength: 255
  
  # === JOB REFERENCE ===
  - name: jobId
    type: string
    required: true
    description: "FK → Job.id. Required - links to Job for grade/level (TR integration: position → job → grade_code → TR.GradeVersion)"
  
  - name: jobProfileId
    type: string
    required: false
    description: "FK → JobProfile.id. Optional - for detailed job description (locale-specific summary, responsibilities)"
  
  # === ORGANIZATIONAL CONTEXT ===
  - name: businessUnitId
    type: string
    required: true
    description: FK → BusinessUnit.id. The department/BU that owns this position.
  
  - name: costCenterId
    type: string
    required: false
    description: FK → CostCenter.id. Financial cost center for budget tracking.
  
  - name: primaryWorkLocationId
    type: string
    required: false
    description: FK → WorkLocation.id. Primary work location for this position.
  
  # === SENIORITY LEVEL ===
  - name: jobLevelId
    type: string
    required: false
    description: FK → JobLevel.id. Seniority/expertise level for this position (Junior, Senior, Principal).
  
  # === HIERARCHY (Org Chart) ===
  - name: supervisorPositionId
    type: string
    required: false
    description: FK → Position.id (self-referential). Reports-to position. Null = top of hierarchy.
  
  # === CLASSIFICATION ===
  - name: positionClassCode
    type: enum
    required: false
    description: Position classification
    values: [REGULAR, MANAGER, EXECUTIVE, SPECIALIST, SUPPORT, CONSULTANT, TRAINEE]
  
  - name: positionTypeCode
    type: enum
    required: true
    description: Employment type for this position
    values: [FULL_TIME, PART_TIME, CONTRACT, TEMPORARY, INTERN, SEASONAL, PROJECT_BASED]
    default: FULL_TIME
  
  # === STAFFING ===
  - name: fte
    type: decimal
    required: false
    description: Full-Time Equivalent (0.0 to 1.0, e.g., 0.5 = half-time)
    constraints:
      min: 0.0
      max: 1.0
  
  - name: maxIncumbents
    type: integer
    required: true
    default: 1
    description: Maximum number of employees who can hold this position (1 = standard, >1 = shared/pooled position)
    constraints:
      min: 1
  
  - name: allowOverlapDays
    type: integer
    required: false
    default: 0
    description: Days of handover overlap allowed when transitioning between incumbents
    constraints:
      min: 0
  
  # === HEADCOUNT TRACKING ===
  - name: plannedHeadcount
    type: integer
    required: true
    default: 1
    description: Target/budgeted headcount for this position
    constraints:
      min: 0
  
  - name: actualHeadcount
    type: integer
    required: false
    default: 0
    description: Current number of active assignments (derived from Assignment count, cached)
    constraints:
      min: 0
  
  # === FLAGS ===
  - name: isCriticalRole
    type: boolean
    required: true
    default: false
    description: Is this a critical/key role for the organization?
  
  - name: isSuccessionPlanned
    type: boolean
    required: true
    default: false
    description: Does this position have a succession plan?
  
  # === STATUS ===
  - name: statusCode
    type: enum
    required: true
    description: Position lifecycle status
    values: [DRAFT, ACTIVE, FROZEN, INACTIVE, CLOSED]
    default: DRAFT
  
  # === SCD TYPE-2 ===
  - name: effectiveStartDate
    type: date
    required: true
    description: Date this position becomes effective
  
  - name: effectiveEndDate
    type: date
    required: false
    description: Date this position expires (null = indefinite)
  
  - name: isCurrent
    type: boolean
    required: true
    default: true
    description: Current version flag for SCD Type-2
  
  # === METADATA ===
  - name: tags
    type: json
    required: false
    description: "Position tags array (e.g., [\"KEY_ROLE\", \"REMOTE_ELIGIBLE\", \"LEADERSHIP\"])"
  
  - name: metadata
    type: json
    required: false
    description: Additional flexible data (requirements, skills, etc.)
  
  # === AUDIT ===
  - name: createdAt
    type: datetime
    required: true
    description: Record creation timestamp
  
  - name: updatedAt
    type: datetime
    required: true
    description: Last modification timestamp

relationships:
  - name: belongsToJob
    target: Job
    cardinality: many-to-one
    required: true
    inverse: hasPositions
    description: The job template this position is based on (for grade/level, TR integration).
  
  - name: hasJobProfile
    target: JobProfile
    cardinality: many-to-one
    required: false
    inverse: usedByPositions
    description: Optional detailed job description (locale-specific).
  
  - name: belongsToBusinessUnit
    target: BusinessUnit
    cardinality: many-to-one
    required: true
    inverse: hasPositions
    description: The department/BU that owns this position.
  
  - name: chargedToCostCenter
    target: CostCenter
    cardinality: many-to-one
    required: false
    inverse: hasPositions
    description: Cost center for financial tracking.
  
  - name: locatedAtWorkLocation
    target: WorkLocation
    cardinality: many-to-one
    required: false
    inverse: hasPositions
    description: Primary work location for this position.
  
  - name: atJobLevel
    target: JobLevel
    cardinality: many-to-one
    required: false
    inverse: hasPositions
    description: Seniority level for this position (Junior, Senior, Principal).
  
  - name: supervisorPosition
    target: Position
    cardinality: many-to-one
    required: false
    inverse: subordinatePositions
    description: Reports-to position (self-referential hierarchy for org chart).
  
  - name: subordinatePositions
    target: Position
    cardinality: one-to-many
    required: false
    inverse: supervisorPosition
    description: Positions that report to this position.
  
  - name: hasAssignments
    target: Assignment
    cardinality: one-to-many
    required: false
    inverse: assignedToPosition
    description: Employee assignments holding this position.

lifecycle:
  states: [DRAFT, ACTIVE, FROZEN, INACTIVE, CLOSED]
  initial: DRAFT
  terminal: [CLOSED]
  transitions:
    - from: DRAFT
      to: ACTIVE
      trigger: activate
      guard: Position fully configured, approved for staffing
    - from: ACTIVE
      to: FROZEN
      trigger: freeze
      guard: Hiring freeze - cannot assign new employees
    - from: FROZEN
      to: ACTIVE
      trigger: unfreeze
      guard: Hiring freeze lifted
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: Temporary suspension (reorganization)
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate
      guard: Resume position
    - from: [ACTIVE, FROZEN, INACTIVE]
      to: CLOSED
      trigger: close
      guard: Position permanently retired (no active assignments)

policies:
  - name: UniqueCodeGlobally
    type: validation
    rule: Position code must be unique across all positions
    expression: "UNIQUE(code)"
  
  - name: JobRequired
    type: validation
    rule: Every position must reference a Job
    expression: "jobId IS NOT NULL"
  
  - name: BusinessUnitRequired
    type: validation
    rule: Every position must belong to a Business Unit
    expression: "businessUnitId IS NOT NULL"
  
  - name: FTERange
    type: validation
    rule: FTE must be between 0.0 and 1.0
    expression: "fte IS NULL OR (fte >= 0.0 AND fte <= 1.0)"
  
  - name: HeadcountConsistency
    type: validation
    rule: Actual headcount cannot exceed planned × maxIncumbents
    expression: "actualHeadcount <= plannedHeadcount * maxIncumbents"
    severity: WARNING
  
  - name: SupervisorNotSelf
    type: validation
    rule: Position cannot report to itself
    expression: "supervisorPositionId IS NULL OR supervisorPositionId != id"
  
  - name: SupervisorMustBeActive
    type: validation
    rule: Supervisor position must be ACTIVE
    expression: "supervisorPositionId IS NULL OR supervisorPosition.statusCode = 'ACTIVE'"
    severity: WARNING
  
  - name: ClosedPositionNoAssignments
    type: business
    rule: CLOSED position cannot have active assignments
    expression: "statusCode != 'CLOSED' OR actualHeadcount = 0"
  
  - name: FrozenPositionNoNewAssignments
    type: business
    rule: FROZEN position cannot receive new assignments
    trigger: ON_CREATE(Assignment)
    severity: ERROR
  
  - name: CriticalRoleSuccession
    type: business
    rule: Critical roles should have succession planning
    expression: "isCriticalRole = false OR isSuccessionPlanned = true"
    severity: INFO
---

# Entity: Position

## 1. Overview

**Position** represents a specific "chair" in the organization that an employee can sit in. It is an instance of a [[Job]], belonging to a specific [[BusinessUnit]], with defined reporting relationships (org chart), and headcount tracking (planned vs actual).

**Key Concept**:
```
Position = "Chair" (instance of Job)
Job → Position = Template → Instance
Position Hierarchy = Org Chart
Assignment = Employee placed in Position
```

```mermaid
mindmap
  root((Position))
    Identity
      id
      code
      title
    Job Reference
      jobId
      jobProfileId
    Organizational Context
      businessUnitId
      costCenterId
      primaryWorkLocationId
    Hierarchy
      supervisorPositionId
      subordinatePositions
    Classification
      positionClassCode
      positionTypeCode
    Staffing
      fte
      maxIncumbents
      allowOverlapDays
    Headcount Tracking
      plannedHeadcount
      actualHeadcount
    Flags
      isCriticalRole
      isSuccessionPlanned
    Status
      statusCode
    SCD Type-2
      effectiveStartDate
      effectiveEndDate
      isCurrent
    Relationships
      belongsToJob
      belongsToBusinessUnit
      chargedToCostCenter
      locatedAtWorkLocation
      supervisorPosition
      subordinatePositions
      hasAssignments
    Lifecycle
      DRAFT
      ACTIVE
      FROZEN
      INACTIVE
      CLOSED
```

### Industry Alignment

| Vendor | Pattern | xTalent Equivalent |
|--------|---------|-------------------|
| Oracle HCM | Position (with Job reference) | Position → Job |
| SAP SuccessFactors | Position (MDF Object) | Position with effectiveDate |
| Workday | Position (links to Job Profile) | Position + JobProfile optional |

### Position vs Job

| Aspect | Job | Position |
|--------|-----|----------|
| **Nature** | Template/Classification | Instance/Chair |
| **Multiplicity** | One Job → Many Positions | One Position → One (or few) Employees |
| **Hierarchy** | Job Family/Group | Org Chart (reports-to) |
| **Headcount** | N/A | Planned vs Actual |
| **Compensation** | Grade/Level (via Job) | Inherited from Job |

---

## 2. Attributes

### 2.1 Identity

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique identifier (UUID) |
| code | string | ✓ | Position code (unique) |
| title | string | ✓ | Position title |

### 2.2 Job Reference

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| **jobId** | string | ✓ | FK → [[Job]]. Required for grade/level (TR integration) |
| jobProfileId | string | | FK → [[JobProfile]]. Optional detailed description |

**TR Integration Path**:
```
Position → Job → job.gradeCode → TR.GradeVersion → PayRange
```

### 2.3 Organizational Context

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| **businessUnitId** | string | ✓ | FK → [[BusinessUnit]]. Owner department |
| costCenterId | string | | FK → [[CostCenter]]. Financial tracking |
| primaryWorkLocationId | string | | FK → [[WorkLocation]]. Primary location |

### 2.4 Hierarchy

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| supervisorPositionId | string | | FK → [[Position]] (self-ref). Reports-to |

### 2.5 Classification

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| positionClassCode | enum | | REGULAR, MANAGER, EXECUTIVE, SPECIALIST, SUPPORT, CONSULTANT, TRAINEE |
| positionTypeCode | enum | ✓ | FULL_TIME, PART_TIME, CONTRACT, TEMPORARY, INTERN |

### 2.6 Staffing

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| fte | decimal | | Full-Time Equivalent (0.0 - 1.0) |
| maxIncumbents | integer | ✓ | Max employees (1 = standard, >1 = shared) |
| allowOverlapDays | integer | | Handover overlap days |

### 2.7 Headcount Tracking

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| plannedHeadcount | integer | ✓ | Target/budgeted headcount |
| actualHeadcount | integer | | Current assignments (derived) |

**Derived Fields**:
- `isVacant = actualHeadcount < plannedHeadcount`
- `vacancyCount = plannedHeadcount - actualHeadcount`

### 2.8 Flags

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| isCriticalRole | boolean | ✓ | Key role for organization? |
| isSuccessionPlanned | boolean | ✓ | Has succession plan? |

### 2.9 Status

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| statusCode | enum | ✓ | DRAFT, ACTIVE, FROZEN, INACTIVE, CLOSED |

### 2.10 SCD Type-2

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| effectiveStartDate | date | ✓ | Position becomes effective |
| effectiveEndDate | date | | Position expires |
| isCurrent | boolean | ✓ | Current version flag |

---

## 3. Relationships

```mermaid
erDiagram
    Job ||--o{ Position : hasPositions
    JobProfile ||--o{ Position : usedByPositions
    BusinessUnit ||--o{ Position : hasPositions
    CostCenter ||--o{ Position : hasPositions
    WorkLocation ||--o{ Position : hasPositions
    Position ||--o{ Position : "supervisor/subordinates"
    Position ||--o{ Assignment : hasAssignments
    
    Position {
        string id PK
        string code UK
        string title
        string jobId FK
        string jobProfileId FK
        string businessUnitId FK
        string costCenterId FK
        string primaryWorkLocationId FK
        string supervisorPositionId FK
        enum statusCode
        int plannedHeadcount
        int actualHeadcount
    }
    
    Job {
        string id PK
        string gradeCode
    }
    
    Assignment {
        string id PK
        string positionId FK
        string employeeId FK
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[Job]] | belongsToJob | N:1 | Job template (required) |
| [[JobProfile]] | hasJobProfile | N:1 | Detailed description (optional) |
| [[BusinessUnit]] | belongsToBusinessUnit | N:1 | Owner department (required) |
| [[CostCenter]] | chargedToCostCenter | N:1 | Financial tracking |
| [[WorkLocation]] | locatedAtWorkLocation | N:1 | Primary work location |
| [[Position]] | supervisorPosition | N:1 | Reports-to (self-ref) |
| [[Position]] | subordinatePositions | 1:N | Direct reports (self-ref) |
| [[Assignment]] | hasAssignments | 1:N | Employee assignments |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> DRAFT: Create Position
    
    DRAFT --> ACTIVE: Activate (approved)
    
    ACTIVE --> FROZEN: Freeze (hiring freeze)
    FROZEN --> ACTIVE: Unfreeze
    
    ACTIVE --> INACTIVE: Deactivate (temp)
    INACTIVE --> ACTIVE: Reactivate
    
    ACTIVE --> CLOSED: Close (permanent)
    FROZEN --> CLOSED: Close (permanent)
    INACTIVE --> CLOSED: Close (permanent)
    
    CLOSED --> [*]
    
    note right of DRAFT
        Being defined
        Not yet approved
    end note
    
    note right of ACTIVE
        Open for staffing
        Can assign employees
    end note
    
    note right of FROZEN
        Hiring freeze
        Cannot add new assignments
        Existing assignments remain
    end note
    
    note right of INACTIVE
        Temporarily suspended
        Reorganization
    end note
    
    note right of CLOSED
        Permanently retired
        No active assignments
    end note
```

### State Descriptions

| State | Description | Can Assign? |
|-------|-------------|-------------|
| **DRAFT** | Being defined, not approved | ❌ |
| **ACTIVE** | Open for staffing | ✅ |
| **FROZEN** | Hiring freeze, no new assignments | ❌ |
| **INACTIVE** | Temporarily suspended | ❌ |
| **CLOSED** | Permanently retired | ❌ |

---

## 5. Business Rules Reference

### Validation Rules
- **UniqueCodeGlobally**: Code unique across all positions
- **JobRequired**: Every position must reference a Job
- **BusinessUnitRequired**: Every position must belong to a BU
- **FTERange**: FTE between 0.0 and 1.0
- **HeadcountConsistency**: actual ≤ planned × maxIncumbents (WARNING)
- **SupervisorNotSelf**: Position cannot report to itself
- **SupervisorMustBeActive**: Supervisor must be ACTIVE (WARNING)

### Business Constraints
- **ClosedPositionNoAssignments**: CLOSED position has no active assignments
- **FrozenPositionNoNewAssignments**: Cannot assign to FROZEN position
- **CriticalRoleSuccession**: Critical roles should have succession plan (INFO)

### Position Types

| Type | Description | FTE Typical |
|------|-------------|-------------|
| FULL_TIME | Standard full-time | 1.0 |
| PART_TIME | Part-time reduced hours | 0.5 |
| CONTRACT | Fixed-term contract | 1.0 |
| TEMPORARY | Temporary/seasonal | 0.5-1.0 |
| INTERN | Internship/trainee | 0.5-1.0 |

### Example: Position Creation

```yaml
Position:
  code: "POS-DEV-001"
  title: "Senior Software Engineer - Backend Team"
  jobId: "job-senior-dev"           # Links to Job
  businessUnitId: "bu-engineering"  # Engineering Department
  costCenterId: "cc-dev"            # Development cost center
  primaryWorkLocationId: "wl-etown-f5"
  supervisorPositionId: "POS-TL-001"  # Reports to Team Lead
  positionClassCode: "SPECIALIST"
  positionTypeCode: "FULL_TIME"
  fte: 1.0
  maxIncumbents: 1
  plannedHeadcount: 1
  statusCode: "ACTIVE"
  isCriticalRole: true
  isSuccessionPlanned: false        # WARNING: should add succession plan
```

---

*Document Status: APPROVED*  
*Based on: Oracle HCM Position, SAP SuccessFactors Position, Workday Position*  
*TR Integration: Position → Job → gradeCode → TR.GradeVersion*
