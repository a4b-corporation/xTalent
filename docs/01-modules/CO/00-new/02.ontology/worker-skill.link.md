---
entity: WorkerSkill
domain: person
version: "1.0.0"
status: approved
owner: Skills & Competency Team
tags: [worker, skill, junction, proficiency, experience]
entityType: link

# NOTE: WorkerSkill is a junction entity linking Worker to Skill.
# Represents the ACTUAL skills a worker possesses.
# Includes proficiency level, years of experience, and verification status.

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
  
  - name: skillId
    type: string
    required: true
    description: FK → Skill.id
  
  # === PROFICIENCY ===
  - name: proficiencyLevel
    type: integer
    required: false
    description: Current proficiency level (1-5 or per skill's scale)
    constraints:
      min: 1
      max: 10
  
  - name: yearsExperience
    type: decimal
    required: false
    description: Years of experience with this skill
    constraints:
      min: 0
      max: 50
  
  - name: lastUsedDate
    type: date
    required: false
    description: When this skill was last actively used
  
  # === SOURCE & VERIFICATION ===
  - name: sourceCode
    type: enum
    required: false
    description: How this skill was captured
    values: [SELF, MANAGER, CERTIFICATION, ASSESSMENT, IMPORT, AI_INFERRED]
    # SELF = Self-declared by worker
    # MANAGER = Added by manager
    # CERTIFICATION = From certification record
    # ASSESSMENT = From skill assessment test
    # IMPORT = Imported from resume/LinkedIn
    # AI_INFERRED = Inferred by AI from work history
  
  - name: isVerified
    type: boolean
    required: true
    default: false
    description: Has this skill been verified (by manager, test, or cert)?
  
  - name: verifiedBy
    type: string
    required: false
    description: FK → Worker.id (who verified this skill)
  
  - name: verifiedDate
    type: date
    required: false
    description: When this skill was verified
  
  # === CERTIFICATION ===
  - name: certificationId
    type: string
    required: false
    description: FK → Certification.id (if skill comes from certification)
  
  - name: certificationDate
    type: date
    required: false
    description: Date of related certification
  
  - name: certificationExpiry
    type: date
    required: false
    description: Expiry date of related certification
  
  # === SCD TYPE-2 ===
  - name: effectiveStartDate
    type: date
    required: true
    description: When this skill record becomes effective
  
  - name: effectiveEndDate
    type: date
    required: false
    description: When this skill record ends (null = current)
  
  - name: isCurrent
    type: boolean
    required: true
    default: true
    description: Is this the current version?
  
  # === METADATA ===
  - name: notes
    type: string
    required: false
    description: Additional notes about this skill
    constraints:
      maxLength: 1000
  
  - name: metadata
    type: json
    required: false
    description: Additional flexible data (projects used, context, etc.)
  
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
    inverse: hasSkills
    description: The worker who possesses this skill.
  
  - name: refersToSkill
    target: Skill
    cardinality: many-to-one
    required: true
    inverse: possessedByWorkers
    description: The skill being referenced.
  
  - name: verifiedByWorker
    target: Worker
    cardinality: many-to-one
    required: false
    description: Manager/verifier who verified this skill.

lifecycle:
  states: [ACTIVE, EXPIRED, OBSOLETE]
  initial: ACTIVE
  terminal: [OBSOLETE]
  transitions:
    - from: ACTIVE
      to: EXPIRED
      trigger: expire
      guard: Skill no longer actively used
    - from: EXPIRED
      to: ACTIVE
      trigger: renew
    - from: [ACTIVE, EXPIRED]
      to: OBSOLETE
      trigger: remove
      guard: Skill no longer relevant

policies:
  - name: UniqueWorkerSkillCurrent
    type: validation
    rule: Only one current record per worker-skill pair
    expression: "UNIQUE(workerId, skillId, isCurrent = true)"
  
  - name: ProficiencyWithinScale
    type: validation
    rule: Proficiency must be within skill's max level
    expression: "proficiencyLevel IS NULL OR proficiencyLevel <= Skill.maxProficiencyLevel"
    severity: WARNING
  
  - name: VerifiedRequiresVerifier
    type: validation
    rule: If verified, verifiedBy should be set
    expression: "isVerified = false OR verifiedBy IS NOT NULL"
    severity: WARNING
---

# Entity: WorkerSkill

## 1. Overview

**WorkerSkill** is a junction/link entity that connects [[Worker]] to [[Skill]], representing the actual skills a worker possesses. It includes proficiency level, years of experience, verification status, and certification links.

```mermaid
mindmap
  root((WorkerSkill))
    Keys
      workerId
      skillId
    Proficiency
      proficiencyLevel
      yearsExperience
      lastUsedDate
    Source
      sourceCode
      isVerified
      verifiedBy
    Certification
      certificationId
      certificationDate
      certificationExpiry
    History
      SCD Type-2
    Use Cases
      Skill Gap Analysis
      Career Matching
      Training Recommendations
```

### Skill Sources

| Source | Description | Reliability |
|--------|-------------|-------------|
| **SELF** | Self-declared | Low |
| **MANAGER** | Manager added | Medium |
| **CERTIFICATION** | From cert record | High |
| **ASSESSMENT** | Skill test | High |
| **IMPORT** | Resume/LinkedIn | Low |
| **AI_INFERRED** | AI from history | Medium |

---

## 2. Attributes

### Primary Key

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique identifier |
| workerId | string | ✓ | FK → [[Worker]] |
| skillId | string | ✓ | FK → [[Skill]] |

### Proficiency

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| proficiencyLevel | integer | | 1-5 or per scale |
| yearsExperience | decimal | | Years using skill |
| lastUsedDate | date | | Last active use |

### Verification

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| sourceCode | enum | | How captured |
| isVerified | boolean | ✓ | Verified? |
| verifiedBy | string | | FK → Worker (verifier) |

---

## 3. Relationships

```mermaid
erDiagram
    Worker ||--o{ WorkerSkill : hasSkills
    Skill ||--o{ WorkerSkill : possessedBy
    Worker ||--o{ WorkerSkill : "verified by"
    
    WorkerSkill {
        string id PK
        string workerId FK
        string skillId FK
        int proficiencyLevel
        decimal yearsExperience
        enum sourceCode
        boolean isVerified
        string verifiedBy FK
    }
    
    Worker {
        string id PK
        string fullName
    }
    
    Skill {
        string id PK
        string code
        string name
    }
```

---

## 4. Use Cases

### Self-declared Skill

```yaml
WorkerSkill:
  workerId: "worker-001"
  skillId: "skill-java"
  proficiencyLevel: 4
  yearsExperience: 5.5
  lastUsedDate: "2025-01-15"
  sourceCode: "SELF"
  isVerified: false
  effectiveStartDate: "2020-06-01"
  isCurrent: true
```

### Certified Skill

```yaml
WorkerSkill:
  workerId: "worker-001"
  skillId: "skill-aws-sa"
  proficiencyLevel: 5
  sourceCode: "CERTIFICATION"
  isVerified: true
  verifiedBy: "system"
  verifiedDate: "2024-08-15"
  certificationId: "cert-aws-001"
  certificationDate: "2024-08-15"
  certificationExpiry: "2027-08-15"
  effectiveStartDate: "2024-08-15"
  isCurrent: true
```

---

*Document Status: APPROVED*  
*References: [[Worker]], [[Skill]], [[JobProfile]]*
