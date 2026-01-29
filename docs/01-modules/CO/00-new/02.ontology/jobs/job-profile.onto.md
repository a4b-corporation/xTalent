---
entity: JobProfile
domain: jobpos
version: "1.0.0"
status: approved
owner: Job & Position Management Team
tags: [job-profile, job-description, locale, skills, ai-ready]

# NOTE: JobProfile is the CONTENT layer of a Job.
# Job = WHAT (classification, identity, grade)
# JobProfile = HOW (description, responsibilities, qualifications, skills)
# 
# Key Features:
# - Locale-variant: One Job can have profiles in multiple languages (en-US, vi-VN)
# - SCD Type-2: Track changes over time
# - AI-ready: Structured skills for matching algorithms

attributes:
  # === IDENTITY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  - name: jobId
    type: string
    required: true
    description: FK → Job.id. The job this profile describes.
  
  - name: localeCode
    type: string
    required: true
    description: Locale/language code (e.g., en-US, vi-VN, ja-JP)
    constraints:
      maxLength: 10
      pattern: "^[a-z]{2}(-[A-Z]{2})?$"
    default: en-US
  
  # === LOCALIZED CONTENT ===
  - name: jobTitle
    type: string
    required: true
    description: Localized job title for this language
    constraints:
      maxLength: 255
  
  - name: summary
    type: string
    required: false
    description: Brief summary/overview of the job (localized)
    constraints:
      maxLength: 1000
  
  - name: responsibilities
    type: json
    required: false
    description: Array of key responsibilities (localized, AI-ready)
    example: '["Design and develop software solutions", "Review code quality", "Mentor junior developers"]'
  
  - name: qualifications
    type: json
    required: false
    description: Array of qualification requirements (localized, AI-ready)
    example: '["Bachelor degree in CS or related", "3+ years professional experience", "Strong problem-solving skills"]'
  
  - name: preferredQualifications
    type: json
    required: false
    description: Array of nice-to-have qualifications (localized, AI-ready)
    example: '["Experience with Kubernetes", "AWS certification", "Leadership experience"]'
  
  # === CLASSIFICATION (Localized) ===
  - name: rankingLevelCode
    type: string
    required: false
    description: Ranking level code for this profile (if different from Job defaults)
    constraints:
      maxLength: 50
  
  - name: jobTypeCode
    type: string
    required: false
    description: Job type classification code for this locale
    constraints:
      maxLength: 50
  
  # === SKILLS & COMPETENCIES ===
  - name: skillsJson
    type: json
    required: false
    description: Structured skills with proficiency levels for AI matching
    example: '[{"skillId": "skill-java", "name": "Java", "proficiency": 4, "yearsRequired": 3}, {"skillId": "skill-sql", "name": "SQL", "proficiency": 3}]'
  
  - name: competenciesJson
    type: json
    required: false
    description: Behavioral/functional competencies for assessment
    example: '[{"competencyCode": "PROBLEM_SOLVING", "level": "ADVANCED"}, {"competencyCode": "COMMUNICATION", "level": "INTERMEDIATE"}]'
  
  # === SCD TYPE-2 ===
  - name: effectiveStartDate
    type: date
    required: true
    description: When this profile version becomes effective
  
  - name: effectiveEndDate
    type: date
    required: false
    description: When this profile version ends (null = current)
  
  - name: isCurrent
    type: boolean
    required: true
    default: true
    description: Is this the current version?
  
  # === METADATA ===
  - name: metadata
    type: json
    required: false
    description: Additional flexible data (hiring notes, internal comments, etc.)
  
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
    inverse: hasProfiles
    description: The job this profile describes.
  
  - name: hasSkillRequirements
    target: Skill
    cardinality: many-to-many
    required: false
    via: JobProfileSkill
    inverse: requiredByJobProfiles
    description: |
      Skills required for this job profile, managed via [[JobProfileSkill]] junction entity.
      PREFERRED approach for enterprise tenants with skill master data.
      FALLBACK: Use skillsJson attribute for tenants who don't maintain skill catalog.

lifecycle:
  states: [DRAFT, ACTIVE, ARCHIVED]
  initial: DRAFT
  terminal: [ARCHIVED]
  transitions:
    - from: DRAFT
      to: ACTIVE
      trigger: publish
      guard: All required fields populated
    - from: ACTIVE
      to: ARCHIVED
      trigger: archive
      guard: New version exists or job is inactive

policies:
  - name: UniqueJobLocale
    type: validation
    rule: Only one current profile per job-locale combination
    expression: "UNIQUE(jobId, localeCode, isCurrent = true)"
  
  - name: JobRequired
    type: validation
    rule: Every profile must reference a Job
    expression: "jobId IS NOT NULL"
  
  - name: LocaleFormat
    type: validation
    rule: Locale must follow BCP-47 format (e.g., en-US, vi-VN)
    expression: "MATCHES(localeCode, '^[a-z]{2}(-[A-Z]{2})?$')"
    severity: WARNING
  
  - name: SkillsStructured
    type: business
    rule: skillsJson should be valid JSON array with skillId and proficiency
    severity: WARNING
---

# Entity: JobProfile

## 1. Overview

**JobProfile** is the **content layer** of a Job, containing localized job descriptions, responsibilities, qualifications, and skills. While Job defines WHAT the role is, JobProfile describes HOW it should be filled.

**Key Concept**:
```
Job (Identity/Classification)
├── JobProfile (en-US) - English description
├── JobProfile (vi-VN) - Vietnamese description
└── JobProfile (ja-JP) - Japanese description
```

```mermaid
mindmap
  root((JobProfile))
    Identity
      id
      jobId
      localeCode
    Localized Content
      jobTitle
      summary
      responsibilities
      qualifications
      preferredQualifications
    Classification
      rankingLevelCode
      jobTypeCode
    Skills & Competencies
      skillsJson
      competenciesJson
    SCD Type-2
      effectiveStartDate
      effectiveEndDate
      isCurrent
    Relationships
      belongsToJob
      hasSkillRequirements
```

### Why JobProfile?

| Aspect | Job | JobProfile |
|--------|-----|------------|
| **Purpose** | WHAT (Identity) | HOW (Description) |
| **Locale** | Single | Multi-language |
| **Content** | Code, Title, Grade | Description, Skills |
| **Change** | Rare | Frequent |
| **AI Use** | Classification | Matching/Generation |

### Industry Pattern

| Vendor | Approach |
|--------|----------|
| Workday | Job Profile (locale-variant) |
| Oracle HCM | Job (with locale fields) |
| SAP SF | JobRequisition (mixed) |
| **xTalent** | Job + JobProfile (clean separation) |

---

## 2. Attributes

### 2.1 Identity

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| id | string | ✓ | Unique identifier (UUID) | jobpos.job_profile.id |
| jobId | string | ✓ | FK → [[Job]] | jobpos.job_profile.job_id → jobpos.job.id |
| localeCode | string | ✓ | Locale code (en-US, vi-VN) | jobpos.job_profile.locale_code |

### 2.2 Localized Content

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| jobTitle | string | ✓ | Localized job title | jobpos.job_profile.job_title |
| summary | string | | Brief overview | jobpos.job_profile.summary |
| responsibilities | json | | Array of duties (AI-ready) | (jobpos.job_profile.metadata.responsibilities) |
| qualifications | json | | Array of requirements (AI-ready) | (jobpos.job_profile.metadata.qualifications) |
| preferredQualifications | json | | Nice-to-have skills | (jobpos.job_profile.metadata.preferred_qualifications) |

### 2.3 Skills & Competencies

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| skillsJson | json | | Structured skills with proficiency | (jobpos.job_profile.metadata.skills_json) |
| competenciesJson | json | | Behavioral competencies | (jobpos.job_profile.metadata.competencies_json) |

**Skills Format**:
```json
[
  {"skillId": "skill-java", "name": "Java", "proficiency": 4, "yearsRequired": 3},
  {"skillId": "skill-sql", "name": "SQL", "proficiency": 3}
]
```

---

## 3. Relationships

```mermaid
erDiagram
    Job ||--o{ JobProfile : hasProfiles
    JobProfile ||--o{ Skill : hasSkillRequirements
    
    JobProfile {
        string id PK
        string jobId FK
        string localeCode
        string jobTitle
        json responsibilities
        json qualifications
        json skillsJson
    }
    
    Job {
        string id PK
        string code
        string title
    }
    
    Skill {
        string id PK
        string name
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[Job]] | belongsToJob | N:1 | Parent job |
| [[Skill]] | hasSkillRequirements | N:N | Required skills |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> DRAFT: Create Profile
    
    DRAFT --> ACTIVE: Publish
    ACTIVE --> ARCHIVED: Archive (new version)
    
    ARCHIVED --> [*]
    
    note right of DRAFT
        Being edited
        Not visible in job postings
    end note
    
    note right of ACTIVE
        Published, visible
        Used for AI matching
    end note
    
    note right of ARCHIVED
        Historical record
        Superseded by new version
    end note
```

---

## 5. Business Rules Reference

### Validation Rules
- **UniqueJobLocale**: One current profile per job-locale
- **JobRequired**: Must reference a Job
- **LocaleFormat**: BCP-47 format (WARNING)

### Use Cases

#### 1. English Job Profile

```yaml
JobProfile:
  jobId: "job-software-dev"
  localeCode: "en-US"
  jobTitle: "Software Developer"
  summary: "Design and implement software solutions"
  responsibilities:
    - "Design and develop software applications"
    - "Review code and ensure quality standards"
    - "Collaborate with cross-functional teams"
  qualifications:
    - "Bachelor's degree in Computer Science"
    - "3+ years of professional experience"
    - "Strong knowledge of Java or Python"
  skillsJson:
    - skillId: "skill-java"
      name: "Java"
      proficiency: 4
      yearsRequired: 3
    - skillId: "skill-agile"
      name: "Agile Methodology"
      proficiency: 3
  isCurrent: true
```

#### 2. Vietnamese Job Profile (same Job)

```yaml
JobProfile:
  jobId: "job-software-dev"
  localeCode: "vi-VN"
  jobTitle: "Lập trình viên Phần mềm"
  summary: "Thiết kế và phát triển các giải pháp phần mềm"
  responsibilities:
    - "Thiết kế và phát triển ứng dụng phần mềm"
    - "Review code và đảm bảo chất lượng"
    - "Phối hợp với các team đa chức năng"
  qualifications:
    - "Bằng Cử nhân Khoa học Máy tính"
    - "3+ năm kinh nghiệm làm việc"
    - "Thành thạo Java hoặc Python"
  isCurrent: true
```

---

*Document Status: APPROVED*  
*This entity enables multi-language job descriptions and AI-ready skill matching.*
