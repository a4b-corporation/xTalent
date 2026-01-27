---
entity: Job
domain: core-hr
version: "1.0.0"
status: approved
owner: HR Domain Team
tags: [job, job-profile, position-template, core]

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
    description: Unique Job Code (e.g., JOB-DEV-001)
    constraints:
      maxLength: 50
      pattern: "^[A-Z0-9\\-]+$"
  
  - name: title
    type: string
    required: true
    description: Job Title in English (e.g., Senior Software Engineer)
    constraints:
      maxLength: 200
  
  - name: titleVn
    type: string
    required: false
    description: Official Vietnamese title for labor contracts (VN adaptation)
    constraints:
      maxLength: 200
  
  # === JOB HIERARCHY (Role Specialization) ===
  - name: parentJobId
    type: string
    required: false
    description: FK → Job.id for role specialization hierarchy (e.g., "Frontend Developer" is child of "Software Developer")
  
  # === EFFECTIVE DATING (SCD Type-2) ===
  - name: effectiveStartDate
    type: date
    required: true
    description: When this job version becomes effective
  
  - name: effectiveEndDate
    type: date
    required: false
    description: When this job version ends (null = current)
  
  - name: isCurrent
    type: boolean
    required: true
    default: true
    description: Is this the current version of the job
  
  - name: previousVersionId
    type: string
    required: false
    description: Link to previous version (SCD chain)
  
  # === CLASSIFICATION ===
  - name: primaryTaxonomyNodeId
    type: string
    required: false
    description: Primary taxonomy node (convenience pointer)
  
  - name: managementLevelCode
    type: enum
    required: false
    description: Management level classification
    values: [IC, LEAD, MANAGER, SENIOR_MANAGER, DIRECTOR, VP, SVP, C_LEVEL]
    metadata:
      values_detail:
        IC: Individual Contributor
        LEAD: Team Lead
        MANAGER: First-line Manager
        SENIOR_MANAGER: Senior Manager
        DIRECTOR: Director
        VP: Vice President
        SVP: Senior Vice President
        C_LEVEL: C-Suite Executive
  
  - name: jobFunction
    type: string
    required: false
    description: Functional area (legacy, prefer taxonomy)
    constraints:
      maxLength: 100
  
  # === VN COMPLIANCE ===
  - name: occupationalCodeVn
    type: string
    required: false
    description: "VN Occupational Classification Code (Danh mục nghề nghiệp - Thông tư 17/2018/TT-BLĐTBXH)"
    constraints:
      maxLength: 10
  
  - name: laborCategoryVn
    type: enum
    required: false
    description: VN Labor Code classification
    values: [MANAGEMENT, TECHNICAL, CLERICAL, SERVICE, PRODUCTION, OTHER]
    metadata:
      values_detail:
        MANAGEMENT: Quản lý
        TECHNICAL: Kỹ thuật/Chuyên môn
        CLERICAL: Hành chính/Văn phòng
        SERVICE: Dịch vụ
        PRODUCTION: Sản xuất
        OTHER: Khác
  
  # === DESCRIPTION (AI-Ready Structured) ===
  - name: summaryDescription
    type: string
    required: false
    description: Short summary of the job
    constraints:
      maxLength: 500
  
  - name: detailedDescription
    type: string
    required: false
    description: Full job description (rich text)
    constraints:
      maxLength: 10000
  
  - name: responsibilities
    type: json
    required: false
    description: Array of key responsibilities (AI-ready structured format)
    example: '["Design and implement software", "Review code", "Mentor junior developers"]'
  
  - name: qualifications
    type: json
    required: false
    description: Array of qualification requirements (AI-ready structured format)
    example: '["Bachelor in CS or related", "3+ years experience", "Strong Java skills"]'
  
  - name: minEducationLevelCode
    type: enum
    required: false
    description: Minimum education level required
    values: [HIGH_SCHOOL, ASSOCIATE, BACHELOR, MASTER, DOCTORATE, PROFESSIONAL]
  
  - name: minYearsExperience
    type: integer
    required: false
    description: Minimum years of experience required
    constraints:
      min: 0
      max: 50
  
  # === QUICK FLAGS ===
  - name: isManagerial
    type: boolean
    required: false
    default: false
    description: Quick flag - does this job manage people? (Useful for filtering)
  
  # === COMPENSATION DEFAULTS ===
  - name: payRateTypeCode
    type: enum
    required: false
    description: Pay rate type (how compensation is calculated)
    values: [SALARY, HOURLY, DAILY]
    default: SALARY
  
  - name: defaultGradeId
    type: string
    required: false
    description: Default pay grade for this job
  
  - name: standardHoursPerWeek
    type: number
    required: false
    description: Standard working hours per week
    constraints:
      min: 0
      max: 168
  
  - name: flsaStatusCode
    type: enum
    required: false
    description: "FLSA status (US only): Exempt or Non-Exempt"
    values: [EXEMPT, NON_EXEMPT]
  
  # === BENCHMARKING ===
  - name: isBenchmark
    type: boolean
    required: false
    description: Is this a market pricing benchmark job
    default: false
  
  - name: benchmarkCode
    type: string
    required: false
    description: External benchmark reference code
    constraints:
      maxLength: 50
  
  # === OWNERSHIP ===
  - name: ownerBusinessUnitId
    type: string
    required: false
    description: Business unit that owns this job definition
  
  - name: isGlobalJob
    type: boolean
    required: false
    description: Is this a global job definition (vs local)
    default: true
  
  # === STATUS ===
  - name: statusCode
    type: enum
    required: true
    description: Current lifecycle status
    values: [DRAFT, ACTIVE, INACTIVE, ARCHIVED]
    default: DRAFT
  
  # === AUDIT ===
  - name: createdAt
    type: datetime
    required: true
    description: Record creation timestamp
  
  - name: updatedAt
    type: datetime
    required: true
    description: Last modification timestamp
  
  - name: createdBy
    type: string
    required: true
    description: User who created the record
  
  - name: updatedBy
    type: string
    required: true
    description: User who last modified the record

relationships:
  - name: hasTaxonomyMappings
    target: JobTaxonomyMap
    cardinality: one-to-many
    required: false
    inverse: belongsToJob
    description: Taxonomy classifications for this job. A job can belong to multiple taxonomies (family, track, level).
  
  - name: primaryTaxonomyNode
    target: JobTaxonomy
    cardinality: many-to-one
    required: false
    inverse: hasPrimaryJobs
    description: Primary taxonomy classification (convenience pointer).
  
  - name: defaultGrade
    target: Grade
    cardinality: many-to-one
    required: false
    inverse: defaultForJobs
    description: Default pay grade for this job. EXTERNAL - Grade is in Total Rewards module.
  
  - name: ownerBusinessUnit
    target: BusinessUnit
    cardinality: many-to-one
    required: false
    inverse: ownsJobs
    description: Business unit that owns this job definition.
  
  - name: hasPositions
    target: Position
    cardinality: one-to-many
    required: false
    inverse: belongsToJob
    description: Position instances of this job template. INVERSE - Position.belongsToJob.
  
  - name: hasProfiles
    target: JobProfile
    cardinality: one-to-many
    required: false
    inverse: belongsToJob
    description: Locale-variant job profiles (descriptions, skills). INVERSE - JobProfile.belongsToJob.
  
  - name: parentJob
    target: Job
    cardinality: many-to-one
    required: false
    inverse: childJobs
    description: Parent job for role specialization (e.g., "Software Developer" is parent of "Frontend Developer").
  
  - name: childJobs
    target: Job
    cardinality: one-to-many
    required: false
    inverse: parentJob
    description: Child jobs that specialize this job (e.g., "Frontend Dev", "Backend Dev" are children of "Software Developer").
  
  - name: previousVersion
    target: Job
    cardinality: many-to-one
    required: false
    inverse: supersededBy
    description: Previous version of this job (SCD Type-2 chain).
  
  - name: supersededBy
    target: Job
    cardinality: one-to-many
    required: false
    inverse: previousVersion
    description: Newer versions that superseded this job.

lifecycle:
  states: [DRAFT, ACTIVE, INACTIVE, ARCHIVED]
  initial: DRAFT
  terminal: [ARCHIVED]
  transitions:
    - from: DRAFT
      to: ACTIVE
      trigger: activate
      guard: All required fields populated and at least one taxonomy mapping
    - from: DRAFT
      to: ARCHIVED
      trigger: archive
      guard: Job was never activated, user has permission
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: No active positions currently use this job or positions migrated
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate
      guard: User has permission to reactivate
    - from: INACTIVE
      to: ARCHIVED
      trigger: archive
      guard: All dependent positions have been migrated or archived

policies:
  - name: CodeUniqueness
    type: validation
    rule: code must be unique across all jobs (per tenant)
    expression: "COUNT(Job WHERE code = X AND id != this.id) = 0"
    severity: ERROR
  
  - name: TitleRequired
    type: validation
    rule: title must not be empty
    expression: "title IS NOT NULL AND LENGTH(TRIM(title)) > 0"
    severity: ERROR
  
  - name: EffectiveDateRequired
    type: validation
    rule: effectiveStartDate is mandatory
    expression: "effectiveStartDate IS NOT NULL"
    severity: ERROR
  
  - name: ActiveJobShouldHaveTaxonomy
    type: business
    rule: Active jobs should be classified in at least one taxonomy node
    expression: "statusCode != 'ACTIVE' OR COUNT(JobTaxonomyMap WHERE jobId = this.id) > 0"
    severity: WARNING
  
  - name: VnOccupationalCodeFormat
    type: validation
    rule: occupationalCodeVn should match VN format if provided (4 digits)
    expression: "occupationalCodeVn IS NULL OR MATCHES(occupationalCodeVn, '^[0-9]{4}$')"
    severity: WARNING
  
  - name: NoActivePositionsOnDeactivate
    type: business
    rule: Cannot deactivate job if active positions reference it
    trigger: "ON statusCode CHANGE TO 'INACTIVE'"
    expression: "COUNT(Position WHERE jobId = this.id AND statusCode = 'ACTIVE') = 0"
    severity: ERROR
  
  - name: SingleCurrentVersion
    type: business
    rule: Only one isCurrent = true per job code
    trigger: "ON isCurrent = true"
    expression: "UPDATE others SET isCurrent = false WHERE code = this.code AND id != this.id"
    severity: INFO
---

# Job

## 1. Overview

The **Job** (or **Job Profile**) entity defines the generic "WHAT" of a role - the responsibilities, qualifications, and standard attributes shared by everyone with that title. It serves as a **template** for creating specific Positions.

```mermaid
mindmap
  root((Job))
    Identity
      id
      code
      title
      titleVn
    Effective Dating
      effectiveStartDate
      effectiveEndDate
      isCurrent
      previousVersionId
    Classification
      primaryTaxonomyNodeId
      managementLevelCode
      jobFunction
    VN Compliance
      occupationalCodeVn
      laborCategoryVn
    Description
      summaryDescription
      detailedDescription
      dutiesResponsibilities
      qualificationRequirements
      minEducationLevelCode
      minYearsExperience
    Compensation Defaults
      payRateTypeCode
      defaultGradeId
      standardHoursPerWeek
      flsaStatusCode
    Benchmarking
      isBenchmark
      benchmarkCode
    Ownership
      ownerBusinessUnitId
      isGlobalJob
    Status
      statusCode
    Relationships
      hasTaxonomyMappings
      primaryTaxonomyNode
      defaultGrade
      ownerBusinessUnit
      hasPositions
      previousVersion
      supersededBy
```

**Key Distinctions**:

| Concept | Description | Example |
|---------|-------------|---------|
| **Job** | Generic template - the role definition | "Senior Software Engineer" |
| **Position** | Specific instance in org structure | "SSE in Engineering Team - Slot #3" |
| **Assignment** | Employee-Position link | "Nguyễn Văn A is assigned to Slot #3" |

**Design Patterns Applied** (SCAMPER Analysis):
- **Substitute**: Multi-taxonomy via JobTaxonomyMap instead of single jobFamily
- **Adapt**: VN fields (titleVn, occupationalCodeVn, laborCategoryVn)
- **Modify**: SCD Type-2 versioning for job history tracking

---

## 2. Attributes

### 2.1 Identity

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique identifier (UUID) |
| code | string | ✓ | Unique Job Code (e.g., JOB-DEV-001) |
| title | string | ✓ | Job Title in English |
| titleVn | string | | Official Vietnamese title for labor contracts |

### 2.2 Effective Dating (SCD Type-2)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| effectiveStartDate | date | ✓ | When this job version becomes effective |
| effectiveEndDate | date | | When this job version ends |
| isCurrent | boolean | ✓ | Is this the current version |
| previousVersionId | string | | Link to previous version |

### 2.3 Classification

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| primaryTaxonomyNodeId | string | | Primary taxonomy node pointer |
| managementLevelCode | enum | | IC / LEAD / MANAGER / DIRECTOR / VP / C_LEVEL |
| jobFunction | string | | Functional area (legacy) |

**Management Level Codes**:
| Code | Name | Description |
|------|------|-------------|
| IC | Individual Contributor | No direct reports |
| LEAD | Team Lead | Informal leadership |
| MANAGER | Manager | First-line manager |
| SENIOR_MANAGER | Senior Manager | Multiple teams |
| DIRECTOR | Director | Function/department head |
| VP | Vice President | Business unit leader |
| SVP | Senior VP | Multiple business units |
| C_LEVEL | C-Suite | CEO, CFO, CTO, etc. |

### 2.4 VN Compliance

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| occupationalCodeVn | string | | VN Occupational Classification (Thông tư 17/2018/TT-BLĐTBXH) |
| laborCategoryVn | enum | | MANAGEMENT / TECHNICAL / CLERICAL / SERVICE / PRODUCTION |

### 2.5 Description

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| summaryDescription | string | | Short summary (≤500 chars) |
| detailedDescription | string | | Full job description |
| dutiesResponsibilities | string | | Key duties |
| qualificationRequirements | string | | Education/Experience requirements |
| minEducationLevelCode | enum | | HIGH_SCHOOL / BACHELOR / MASTER / DOCTORATE |
| minYearsExperience | integer | | Minimum years required |

### 2.6 Compensation Defaults

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| payRateTypeCode | enum | | SALARY / HOURLY / DAILY |
| defaultGradeId | string | | Default pay grade reference |
| standardHoursPerWeek | number | | Standard working hours |
| flsaStatusCode | enum | | EXEMPT / NON_EXEMPT (US only) |

### 2.7 Benchmarking

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| isBenchmark | boolean | | Market pricing benchmark job |
| benchmarkCode | string | | External benchmark reference |

### 2.8 Ownership

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| ownerBusinessUnitId | string | | Business unit owner |
| isGlobalJob | boolean | | Global vs local job definition |

### 2.9 Status & Audit

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| statusCode | enum | ✓ | DRAFT / ACTIVE / INACTIVE / ARCHIVED |
| createdAt | datetime | ✓ | Creation timestamp |
| updatedAt | datetime | ✓ | Last modification |
| createdBy | string | ✓ | Creator |
| updatedBy | string | ✓ | Last modifier |

---

## 3. Relationships

```mermaid
erDiagram
    Job ||--o{ JobTaxonomyMap : hasTaxonomyMappings
    Job }o--|| JobTaxonomy : primaryTaxonomyNode
    Job }o--|| Grade : defaultGrade
    Job }o--|| BusinessUnit : ownerBusinessUnit
    Job ||--o{ Position : hasPositions
    Job }o--|| Job : previousVersion
    Job ||--o{ Job : supersededBy
    
    Job {
        string id PK
        string code UK
        string title
        string titleVn
        date effectiveStartDate
        date effectiveEndDate
        boolean isCurrent
        enum managementLevelCode
        string occupationalCodeVn
        enum statusCode
    }
    
    JobTaxonomyMap {
        string id PK
        string jobId FK
        string taxonomyNodeId FK
        boolean isPrimary
    }
    
    JobTaxonomy {
        string id PK
        string code
        string name
        enum typeCode
    }
    
    Position {
        string id PK
        string jobId FK
        string businessUnitId FK
        integer headcount
    }
    
    BusinessUnit {
        string id PK
        string code
        string name
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[JobTaxonomyMap]] | hasTaxonomyMappings | 1:N | Taxonomy classifications |
| [[JobTaxonomy]] | primaryTaxonomyNode | N:1 | Primary classification |
| [[Grade]] | defaultGrade | N:1 | Default pay grade (TR module) |
| [[BusinessUnit]] | ownerBusinessUnit | N:1 | Owner business unit |
| [[Position]] | hasPositions | 1:N | Position instances |
| [[Job]] | previousVersion | N:1 | SCD chain (self-ref) |
| [[Job]] | supersededBy | 1:N | SCD inverse |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> DRAFT: create
    DRAFT --> ACTIVE: activate
    DRAFT --> ARCHIVED: archive (never used)
    ACTIVE --> INACTIVE: deactivate
    INACTIVE --> ACTIVE: reactivate
    INACTIVE --> ARCHIVED: archive
    ARCHIVED --> [*]
    
    note right of DRAFT
        Job being defined
        Not yet available for positions
    end note
    
    note right of ACTIVE
        Available for position creation
        Visible in job catalog
    end note
    
    note right of INACTIVE
        No longer used for new positions
        Existing positions still valid
    end note
    
    note right of ARCHIVED
        Permanently archived
        Historical record only
    end note
```

### State Descriptions

| State | Description | Allowed Actions |
|-------|-------------|-----------------|
| DRAFT | Job being defined | Edit, Activate, Archive |
| ACTIVE | In use, available for positions | Edit, Deactivate |
| INACTIVE | Deprecated, no new positions | Reactivate, Archive |
| ARCHIVED | Permanently archived | View only |

### Transition Guards

| Transition | Guard Condition |
|------------|-----------------|
| DRAFT → ACTIVE | All required fields populated, at least one taxonomy |
| ACTIVE → INACTIVE | No active positions OR positions migrated |
| INACTIVE → ARCHIVED | All dependent positions migrated/archived |

---

## 5. Business Rules Reference

### Validation Rules

| Rule | Description | Severity |
|------|-------------|----------|
| CodeUniqueness | code must be unique per tenant | ERROR |
| TitleRequired | title is mandatory | ERROR |
| EffectiveDateRequired | effectiveStartDate is mandatory | ERROR |
| VnOccupationalCodeFormat | occupationalCodeVn = 4 digits | WARNING |

### Business Rules

| Rule | Description | Severity |
|------|-------------|----------|
| ActiveJobShouldHaveTaxonomy | Active jobs need taxonomy classification | WARNING |
| NoActivePositionsOnDeactivate | Cannot deactivate if positions active | ERROR |
| SingleCurrentVersion | Only one isCurrent per code | INFO |

### Related Documents
- See `[[job-management.brs.md]]` for complete job business rules
- See `[[job-catalog.flow.md]]` for job catalog workflow
- See `[[position-management.flow.md]]` for position creation workflow

---

## 6. Use Cases

### Use Case 1: Create New Job (Simple)

```yaml
Job:
  id: "job-001"
  code: "JOB-SSE-001"
  title: "Senior Software Engineer"
  titleVn: "Kỹ sư Phần mềm Cao cấp"
  effectiveStartDate: "2024-01-01"
  isCurrent: true
  managementLevelCode: IC
  occupationalCodeVn: "2512"
  laborCategoryVn: TECHNICAL
  summaryDescription: "Designs and implements complex software systems"
  payRateTypeCode: SALARY
  standardHoursPerWeek: 40
  isGlobalJob: true
  statusCode: ACTIVE
```

### Use Case 2: Job with Taxonomy Mapping

```yaml
Job:
  id: "job-002"
  code: "JOB-EM-001"
  title: "Engineering Manager"
  titleVn: "Quản lý Kỹ thuật"
  effectiveStartDate: "2024-01-01"
  isCurrent: true
  managementLevelCode: MANAGER
  primaryTaxonomyNodeId: "tax-tech-mgmt-001"
  occupationalCodeVn: "1330"
  laborCategoryVn: MANAGEMENT
  minEducationLevelCode: BACHELOR
  minYearsExperience: 5
  payRateTypeCode: SALARY
  statusCode: ACTIVE

# Taxonomy Mappings via JobTaxonomyMap
JobTaxonomyMap:
  - jobId: "job-002"
    taxonomyNodeId: "tax-family-engineering"  # Job Family
    isPrimary: true
  - jobId: "job-002"
    taxonomyNodeId: "tax-track-management"    # Career Track
    isPrimary: false
  - jobId: "job-002"
    taxonomyNodeId: "tax-level-m1"            # Level: Manager 1
    isPrimary: false
```

### Use Case 3: Job Version Update (SCD Type-2)

```yaml
# Original job (now superseded)
Job:
  id: "job-001-v1"
  code: "JOB-SSE-001"
  title: "Senior Software Engineer"
  effectiveStartDate: "2024-01-01"
  effectiveEndDate: "2024-12-31"
  isCurrent: false
  statusCode: INACTIVE

# New version
Job:
  id: "job-001-v2"
  code: "JOB-SSE-001"
  title: "Senior Software Engineer"
  effectiveStartDate: "2025-01-01"
  isCurrent: true
  previousVersionId: "job-001-v1"
  minYearsExperience: 4  # Updated requirement
  statusCode: ACTIVE
```

---

## 7. Architecture Position

```
┌─────────────────────────────────────────────────────────────────┐
│  TaxonomyTree (Registry)                                        │
│  └── Multiple trees: Job Family, Career Track, Job Level        │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  JobTaxonomy (N-level hierarchy)                                │
│  └── FAMILY_GROUP / FAMILY / TRACK / GROUP / LEVEL nodes       │
└────────────────────────┬────────────────────────────────────────┘
                         │ (via JobTaxonomyMap)
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  Job (Template)                                                 │
│  ├── title, code, description                                  │
│  ├── managementLevelCode                                       │
│  ├── VN: titleVn, occupationalCodeVn, laborCategoryVn          │
│  └── defaultGradeId → Grade (TR module)                        │
│      │                                                         │
│      └── [1:N] → Position (Instances)                          │
│                   └── [1:N] → Assignment (Employee link)        │
│                                └── → WorkRelationship           │
└─────────────────────────────────────────────────────────────────┘
```

---

*Document Status: APPROVED - Based on Oracle HCM, SAP SuccessFactors, Workday + VN Labor Law*  
*SCAMPER Analysis applied for enhanced design*
