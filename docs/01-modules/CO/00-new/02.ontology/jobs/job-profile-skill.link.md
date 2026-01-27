---
entity: JobProfileSkill
domain: jobpos
version: "1.0.0"
status: approved
owner: Skills & Competency Team
tags: [job-profile, skill, junction, requirement, matching]
entityType: link

# NOTE: JobProfileSkill is a junction entity linking JobProfile to Skill.
# Represents REQUIRED skills for a job profile.
# Used for: Job posting, AI candidate matching, skill gap analysis

attributes:
  # === COMPOSITE KEY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  - name: jobProfileId
    type: string
    required: true
    description: FK → JobProfile.id
  
  - name: skillId
    type: string
    required: true
    description: FK → Skill.id
  
  # === REQUIREMENT LEVEL ===
  - name: requiredProficiency
    type: integer
    required: false
    description: Minimum proficiency level required (1-5 or per skill's scale)
    constraints:
      min: 1
      max: 10
  
  - name: yearsRequired
    type: decimal
    required: false
    description: Minimum years of experience with this skill
    constraints:
      min: 0
      max: 50
  
  # === IMPORTANCE ===
  - name: importanceLevel
    type: enum
    required: false
    description: How important is this skill for the job?
    values: [MUST_HAVE, NICE_TO_HAVE, PREFERRED]
    default: MUST_HAVE
    # MUST_HAVE = Required, deal-breaker if missing
    # NICE_TO_HAVE = Good to have, not required
    # PREFERRED = Preferred but not strict requirement
  
  - name: weightScore
    type: integer
    required: false
    description: Weight for AI matching algorithm (1-100)
    constraints:
      min: 1
      max: 100
    default: 50
  
  # === METADATA ===
  - name: notes
    type: string
    required: false
    description: Additional context about this skill requirement
    constraints:
      maxLength: 1000
  
  - name: metadata
    type: json
    required: false
    description: Additional data (alternative skills, context, etc.)
  
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
  - name: belongsToJobProfile
    target: JobProfile
    cardinality: many-to-one
    required: true
    inverse: hasSkillRequirements
    description: The job profile requiring this skill.
  
  - name: refersToSkill
    target: Skill
    cardinality: many-to-one
    required: true
    inverse: requiredByJobProfiles
    description: The skill being required.

lifecycle:
  states: [ACTIVE, INACTIVE]
  initial: ACTIVE
  terminal: []
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: remove
    - from: INACTIVE
      to: ACTIVE
      trigger: restore

policies:
  - name: UniqueJobProfileSkill
    type: validation
    rule: Only one record per job profile-skill pair
    expression: "UNIQUE(jobProfileId, skillId)"
  
  - name: ProficiencyWithinScale
    type: validation
    rule: Required proficiency must be within skill's max level
    expression: "requiredProficiency IS NULL OR requiredProficiency <= Skill.maxProficiencyLevel"
    severity: WARNING
  
  - name: MustHaveWeight
    type: business
    rule: MUST_HAVE skills should have higher weight
    expression: "importanceLevel != 'MUST_HAVE' OR weightScore >= 70"
    severity: INFO
---

# Entity: JobProfileSkill

## 1. Overview

**JobProfileSkill** is a junction/link entity connecting [[JobProfile]] to [[Skill]], representing the skills required for a job. It enables skill-based matching for recruiting, gap analysis, and career planning.

```mermaid
mindmap
  root((JobProfileSkill))
    Keys
      jobProfileId
      skillId
    Requirement
      requiredProficiency
      yearsRequired
    Importance
      importanceLevel
      weightScore
    Use Cases
      Job Posting
      AI Candidate Matching
      Skill Gap Analysis
      Career Pathing
```

### Importance Levels

| Level | Description | Matching Impact |
|-------|-------------|-----------------|
| **MUST_HAVE** | Required, deal-breaker | Eliminates if missing |
| **PREFERRED** | Strongly preferred | High score bonus |
| **NICE_TO_HAVE** | Good to have | Small score bonus |

---

## 2. Attributes

### Primary Key

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique identifier |
| jobProfileId | string | ✓ | FK → [[JobProfile]] |
| skillId | string | ✓ | FK → [[Skill]] |

### Requirement Level

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| requiredProficiency | integer | | Min proficiency (1-5) |
| yearsRequired | decimal | | Min years experience |

### Importance

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| importanceLevel | enum | | MUST_HAVE, PREFERRED, NICE_TO_HAVE |
| weightScore | integer | | AI matching weight (1-100) |

---

## 3. Relationships

```mermaid
erDiagram
    JobProfile ||--o{ JobProfileSkill : hasSkillRequirements
    Skill ||--o{ JobProfileSkill : requiredBy
    
    JobProfileSkill {
        string id PK
        string jobProfileId FK
        string skillId FK
        int requiredProficiency
        decimal yearsRequired
        enum importanceLevel
        int weightScore
    }
    
    JobProfile {
        string id PK
        string jobId FK
        string localeCode
    }
    
    Skill {
        string id PK
        string code
        string name
    }
```

---

## 4. Use Cases

### Must-Have Skill

```yaml
JobProfileSkill:
  jobProfileId: "profile-senior-dev-en"
  skillId: "skill-java"
  requiredProficiency: 4
  yearsRequired: 3.0
  importanceLevel: "MUST_HAVE"
  weightScore: 90
  notes: "Core backend language for our platform"
```

### Preferred Skill

```yaml
JobProfileSkill:
  jobProfileId: "profile-senior-dev-en"
  skillId: "skill-kubernetes"
  requiredProficiency: 3
  yearsRequired: 1.0
  importanceLevel: "PREFERRED"
  weightScore: 70
  notes: "We're migrating to K8s, experience is a plus"
```

### Nice-to-Have Skill

```yaml
JobProfileSkill:
  jobProfileId: "profile-senior-dev-en"
  skillId: "skill-go"
  requiredProficiency: 2
  importanceLevel: "NICE_TO_HAVE"
  weightScore: 30
  notes: "Some microservices use Go"
```

---

## 5. AI Matching Example

```
JobProfile: Senior Software Developer

Required Skills:
├── JAVA (MUST_HAVE, proficiency >= 4, weight: 90)
├── SPRING_BOOT (MUST_HAVE, proficiency >= 3, weight: 85)
├── AWS (PREFERRED, proficiency >= 2, weight: 70)
├── KUBERNETES (PREFERRED, proficiency >= 2, weight: 65)
└── GO (NICE_TO_HAVE, proficiency >= 2, weight: 30)

Candidate A Skills:
├── JAVA (proficiency: 5) ✓ +90
├── SPRING_BOOT (proficiency: 4) ✓ +85
├── AWS (proficiency: 3) ✓ +70
├── KUBERNETES (proficiency: 0) ✗ +0
└── GO (proficiency: 0) ✗ +0

Total Score: 245 / 340 = 72%
Status: QUALIFIED (all MUST_HAVE met)

Candidate B Skills:
├── JAVA (proficiency: 3) ✗ Fails MUST_HAVE
├── SPRING_BOOT (proficiency: 4) ✓
├── AWS (proficiency: 4) ✓
├── KUBERNETES (proficiency: 5) ✓
└── GO (proficiency: 3) ✓

Status: DISQUALIFIED (JAVA below required)
```

---

*Document Status: APPROVED*  
*References: [[JobProfile]], [[Skill]], [[Worker]], [[WorkerSkill]]*
