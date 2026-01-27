---
entity: Skill
domain: common
version: "1.0.0"
status: approved
owner: Skills & Competency Team
tags: [skill, master-data, proficiency, matching]

# NOTE: Skill is master data representing technical/functional abilities.
# Skills are referenced by:
#   - JobProfile (required skills)
#   - Worker (actual skills)
#   - Talent modules (gap analysis, matching)
# 
# Skill vs Competency:
#   - Skill = "What you know how to do" (Technical, measurable)
#   - Competency = "How you behave doing it" (Behavioral, subjective)

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
    description: Skill code (e.g., JAVA, PYTHON, AWS, LEADERSHIP)
    constraints:
      maxLength: 50
      pattern: "^[A-Z][A-Z0-9_]*$"
  
  - name: name
    type: string
    required: true
    description: Skill display name (e.g., Java Programming)
    constraints:
      maxLength: 255
  
  - name: nameVn
    type: string
    required: false
    description: Vietnamese display name
    constraints:
      maxLength: 255
  
  # === CLASSIFICATION ===
  - name: categoryId
    type: string
    required: false
    description: FK → SkillCategory.id (primary category)
  
  - name: skillType
    type: enum
    required: false
    description: Type classification
    values: [TECHNICAL, FUNCTIONAL, SOFT, LANGUAGE, CERTIFICATION, TOOL]
    # TECHNICAL = Programming, frameworks, etc.
    # FUNCTIONAL = Domain knowledge (Finance, HR, etc.)
    # SOFT = Interpersonal skills
    # LANGUAGE = Natural languages (English, Japanese)
    # CERTIFICATION = Certified skills (AWS Certified, PMP)
    # TOOL = Software tools (Excel, Figma, JIRA)
  
  # === PROFICIENCY SCALE ===
  - name: proficiencyScaleCode
    type: string
    required: false
    description: Reference to proficiency scale (e.g., SKILL_SCALE_1_5, SKILL_SCALE_BEGINNER_EXPERT)
    constraints:
      maxLength: 50
  
  - name: maxProficiencyLevel
    type: integer
    required: false
    default: 5
    description: Maximum proficiency level (typically 5)
    constraints:
      min: 1
      max: 10
  
  # === DESCRIPTION ===
  - name: description
    type: string
    required: false
    description: Detailed description of the skill
    constraints:
      maxLength: 2000
  
  - name: keywords
    type: json
    required: false
    description: Array of keywords for AI matching (synonyms, related terms)
    example: '["java", "jvm", "spring", "spring boot", "j2ee"]'
  
  # === EXTERNAL REFERENCES ===
  - name: externalId
    type: string
    required: false
    description: External skill ID (LinkedIn, O*NET, ESCO, etc.)
    constraints:
      maxLength: 100
  
  - name: externalSource
    type: string
    required: false
    description: Source of external reference (LINKEDIN, ONET, ESCO, CUSTOM)
    constraints:
      maxLength: 50
  
  # === STATUS ===
  - name: isActive
    type: boolean
    required: true
    default: true
    description: Is this skill currently active?
  
  # === SCD TYPE-2 ===
  - name: effectiveStartDate
    type: date
    required: true
    description: When this skill version becomes effective
  
  - name: effectiveEndDate
    type: date
    required: false
    description: When this skill version ends (null = current)
  
  - name: isCurrent
    type: boolean
    required: true
    default: true
    description: Is this the current version?
  
  # === METADATA ===
  - name: metadata
    type: json
    required: false
    description: Additional flexible data (related skills, learning paths, etc.)
  
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
  - name: belongsToCategory
    target: SkillCategory
    cardinality: many-to-one
    required: false
    inverse: hasSkills
    description: Primary skill category.
  
  - name: requiredByJobProfiles
    target: JobProfile
    cardinality: many-to-many
    required: false
    via: JobProfileSkill
    description: Job profiles that require this skill.
  
  - name: possessedByWorkers
    target: Worker
    cardinality: many-to-many
    required: false
    via: WorkerSkill
    description: Workers who possess this skill.

lifecycle:
  states: [ACTIVE, INACTIVE, DEPRECATED]
  initial: ACTIVE
  terminal: [DEPRECATED]
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: Skill no longer in use
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate
    - from: [ACTIVE, INACTIVE]
      to: DEPRECATED
      trigger: deprecate
      guard: Replaced by new skill, create mapping

policies:
  - name: UniqueCodeGlobally
    type: validation
    rule: Skill code must be unique
    expression: "UNIQUE(code)"
  
  - name: CategoryExists
    type: validation
    rule: If categoryId is set, category must exist
    expression: "categoryId IS NULL OR EXISTS(SkillCategory WHERE id = categoryId)"
    severity: WARNING
  
  - name: ProficiencyScaleValid
    type: validation
    rule: proficiencyScaleCode should reference valid code_list
    severity: WARNING
---

# Entity: Skill

## 1. Overview

**Skill** is a master data entity representing technical or functional abilities that can be required by jobs and possessed by workers. It enables skill-based matching for recruiting, talent management, and career development.

**Key Concept**:
```
Skill = "What you know how to do"
Competency = "How you behave doing it"
```

```mermaid
mindmap
  root((Skill))
    Identity
      id
      code
      name
      nameVn
    Classification
      categoryId
      skillType
    Proficiency
      proficiencyScaleCode
      maxProficiencyLevel
    AI Matching
      keywords
      externalId
    Status
      isActive
      SCD Type-2
    Usage
      JobProfile requirements
      Worker possessions
      Gap Analysis
```

### Multi-Module Usage

```
Skill is referenced by:
├── JobProfile → Required skills for job
├── Worker → Actual skills possessed
├── Talent → Skill gap analysis
├── Training → Learning recommendations
├── Recruiting → Candidate matching
└── Succession → Readiness assessment
```

---

## 2. Attributes

### 2.1 Identity

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique identifier (UUID) |
| code | string | ✓ | Skill code (JAVA, AWS, etc.) |
| name | string | ✓ | Display name |
| nameVn | string | | Vietnamese name |

### 2.2 Classification

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| categoryId | string | | FK → [[SkillCategory]] |
| skillType | enum | | TECHNICAL, FUNCTIONAL, SOFT, LANGUAGE, CERTIFICATION, TOOL |

### 2.3 Proficiency Scale

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| proficiencyScaleCode | string | | Reference to proficiency scale |
| maxProficiencyLevel | integer | | Max level (default: 5) |

**Standard Proficiency Levels**:
| Level | Name | Description |
|-------|------|-------------|
| 1 | Beginner | Basic understanding |
| 2 | Elementary | Can perform simple tasks |
| 3 | Intermediate | Independent work |
| 4 | Advanced | Can mentor others |
| 5 | Expert | Industry authority |

### 2.4 AI Matching

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| keywords | json | | Synonyms for AI matching |
| externalId | string | | External ID (LinkedIn, O*NET) |
| externalSource | string | | Source system |

---

## 3. Relationships

```mermaid
erDiagram
    SkillCategory ||--o{ Skill : hasSkills
    Skill ||--o{ JobProfileSkill : requiredBy
    Skill ||--o{ WorkerSkill : possessedBy
    JobProfile ||--o{ JobProfileSkill : requires
    Worker ||--o{ WorkerSkill : possesses
    
    Skill {
        string id PK
        string code UK
        string name
        string categoryId FK
        enum skillType
        int maxProficiencyLevel
        boolean isActive
    }
    
    JobProfileSkill {
        string jobProfileId FK
        string skillId FK
        int requiredProficiency
    }
    
    WorkerSkill {
        string workerId FK
        string skillId FK
        int proficiencyLevel
        decimal yearsExperience
    }
```

### Relationship Details

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[SkillCategory]] | belongsToCategory | N:1 | Primary category |
| [[JobProfile]] | requiredByJobProfiles | N:N | Jobs requiring this skill |
| [[Worker]] | possessedByWorkers | N:N | Workers with this skill |

---

## 4. Skill Types

| Type | Description | Example |
|------|-------------|---------|
| **TECHNICAL** | Programming, frameworks, systems | Java, Python, React |
| **FUNCTIONAL** | Domain knowledge | Financial Analysis, HR Law |
| **SOFT** | Interpersonal skills | Leadership, Communication |
| **LANGUAGE** | Natural languages | English, Japanese, Vietnamese |
| **CERTIFICATION** | Certified abilities | AWS Certified, PMP, CPA |
| **TOOL** | Software tools | Excel, Figma, JIRA |

---

## 5. Use Cases

### 1. Technical Skill

```yaml
Skill:
  code: "JAVA"
  name: "Java Programming"
  nameVn: "Lập trình Java"
  categoryId: "cat-prog-backend"
  skillType: "TECHNICAL"
  proficiencyScaleCode: "SKILL_1_5"
  maxProficiencyLevel: 5
  keywords: ["java", "jvm", "spring", "spring boot", "j2ee", "maven"]
  externalId: "skill-java-linkedin"
  externalSource: "LINKEDIN"
  isActive: true
```

### 2. Soft Skill

```yaml
Skill:
  code: "LEADERSHIP"
  name: "Leadership"
  nameVn: "Kỹ năng Lãnh đạo"
  categoryId: "cat-soft-leadership"
  skillType: "SOFT"
  proficiencyScaleCode: "SKILL_BEHAVIORAL"
  maxProficiencyLevel: 5
  keywords: ["leader", "team lead", "manager", "people management"]
  isActive: true
```

### 3. Certification

```yaml
Skill:
  code: "AWS_SOLUTIONS_ARCHITECT"
  name: "AWS Solutions Architect"
  nameVn: "AWS Solutions Architect"
  categoryId: "cat-cert-cloud"
  skillType: "CERTIFICATION"
  externalId: "aws-saa-c03"
  externalSource: "AWS"
  isActive: true
```

---

## 6. AI Matching Example

```
JobProfile Required Skills:
├── JAVA (proficiency >= 4)
├── SPRING_BOOT (proficiency >= 3)
├── AWS (proficiency >= 2)
└── LEADERSHIP (proficiency >= 3)

Worker Actual Skills:
├── JAVA (proficiency = 5) ✓
├── SPRING_BOOT (proficiency = 4) ✓
├── AWS (proficiency = 1) ✗ Gap!
└── LEADERSHIP (proficiency = 3) ✓

Skill Gap Analysis:
├── AWS: Required 2, Actual 1, Gap = -1
└── Recommendation: AWS Training Course
```

---

*Document Status: APPROVED*  
*References: [[SkillCategory]], [[JobProfile]], [[Worker]], [[WorkerSkill]], [[JobProfileSkill]]*
