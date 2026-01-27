---
entity: Competency
domain: common
version: "1.0.0"
status: approved
owner: Skills & Competency Team
tags: [competency, behavioral, assessment, rating, performance]

# NOTE: Competency is master data representing behavioral traits.
# Competency = "How you behave doing it" (Behavioral, subjective)
# Skill = "What you know how to do" (Technical, measurable)
#
# Competencies are assessed via: 360 feedback, manager assessment, self-assessment

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
    description: Competency code (e.g., LEADERSHIP, COMMUNICATION, PROBLEM_SOLVING)
    constraints:
      maxLength: 50
      pattern: "^[A-Z][A-Z0-9_]*$"
  
  - name: name
    type: string
    required: true
    description: Competency display name
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
    description: FK → CompetencyCategory.id (primary category)
  
  - name: competencyType
    type: enum
    required: false
    description: Type classification
    values: [CORE, LEADERSHIP, FUNCTIONAL, TECHNICAL_BEHAVIORAL]
    # CORE = Core values (all employees)
    # LEADERSHIP = Leadership competencies
    # FUNCTIONAL = Role-specific behaviors
    # TECHNICAL_BEHAVIORAL = Technical + behavioral mix
  
  # === RATING SCALE ===
  - name: scaleCode
    type: string
    required: false
    description: Rating scale code (e.g., BEHAVIORAL_1_5, MEETS_EXCEEDS)
    constraints:
      maxLength: 50
  
  - name: maxRatingLevel
    type: integer
    required: false
    default: 5
    description: Maximum rating level
    constraints:
      min: 1
      max: 10
  
  # === DESCRIPTION ===
  - name: description
    type: string
    required: false
    description: What this competency means
    constraints:
      maxLength: 2000
  
  - name: behavioralIndicators
    type: json
    required: false
    description: Array of observable behaviors for each level
    example: '{"1": ["Rarely demonstrates..."], "3": ["Consistently shows..."], "5": ["Role model for..."]}'
  
  # === FRAMEWORK ===
  - name: frameworkCode
    type: string
    required: false
    description: Competency framework this belongs to
    constraints:
      maxLength: 50
  
  - name: isCore
    type: boolean
    required: false
    default: false
    description: Is this a core competency required for all employees?
  
  # === STATUS ===
  - name: isActive
    type: boolean
    required: true
    default: true
    description: Is this competency currently active?
  
  # === METADATA ===
  - name: metadata
    type: json
    required: false
    description: Additional flexible data (development tips, resources, etc.)
  
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
    target: CompetencyCategory
    cardinality: many-to-one
    required: false
    inverse: hasCompetencies
    description: Primary competency category.
  
  - name: assessedForWorkers
    target: Worker
    cardinality: many-to-many
    required: false
    via: WorkerCompetency
    description: Workers assessed on this competency.

lifecycle:
  states: [ACTIVE, INACTIVE, DEPRECATED]
  initial: ACTIVE
  terminal: [DEPRECATED]
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: Competency no longer in use
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate
    - from: [ACTIVE, INACTIVE]
      to: DEPRECATED
      trigger: deprecate
      guard: Replaced by new competency

policies:
  - name: UniqueCodeGlobally
    type: validation
    rule: Competency code must be unique
    expression: "UNIQUE(code)"
  
  - name: BehavioralIndicatorsFormat
    type: validation
    rule: behavioralIndicators should have indicators for each level
    severity: WARNING
  
  - name: CoreCompetencyCategory
    type: business
    rule: Core competencies should be in CORE category
    expression: "isCore = false OR categoryId IN (SELECT id FROM CompetencyCategory WHERE frameworkCode = 'COMPANY_CORE')"
    severity: WARNING
---

# Entity: Competency

## 1. Overview

**Competency** is master data representing behavioral traits and soft skills. Unlike Skills (what you can do), Competencies describe HOW you do things - your behavior, values, and interpersonal abilities.

**Key Distinction**:
```
Skill = "What you know how to do" (Technical, measurable)
Competency = "How you behave doing it" (Behavioral, subjective)
```

```mermaid
mindmap
  root((Competency))
    Identity
      id
      code
      name
    Classification
      categoryId
      competencyType
    Rating
      scaleCode
      maxRatingLevel
    Behavioral
      description
      behavioralIndicators
    Framework
      frameworkCode
      isCore
    Status
      isActive
    Usage
      Performance Review
      360 Feedback
      Leadership Assessment
```

### Assessment Sources

| Source | Method | Objectivity |
|--------|--------|-------------|
| **Self** | Self-assessment | Low |
| **Manager** | Manager rating | Medium |
| **360** | Multi-rater feedback | High |
| **Survey** | Pulse surveys | Medium |

---

## 2. Attributes

### 2.1 Identity

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique identifier (UUID) |
| code | string | ✓ | Competency code |
| name | string | ✓ | Display name |
| nameVn | string | | Vietnamese name |

### 2.2 Classification

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| categoryId | string | | FK → [[CompetencyCategory]] |
| competencyType | enum | | CORE, LEADERSHIP, FUNCTIONAL, TECHNICAL_BEHAVIORAL |

### 2.3 Rating Scale

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| scaleCode | string | | Rating scale reference |
| maxRatingLevel | integer | | Max rating (default: 5) |

**Standard Competency Ratings**:
| Level | Name | Description |
|-------|------|-------------|
| 1 | Needs Development | Rarely demonstrates competency |
| 2 | Developing | Sometimes demonstrates |
| 3 | Proficient | Consistently demonstrates |
| 4 | Advanced | Frequently exceeds expectations |
| 5 | Role Model | Exemplary, coaches others |

### 2.4 Behavioral Indicators

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| description | string | | What this competency means |
| behavioralIndicators | json | | Observable behaviors per level |

**Example Behavioral Indicators**:
```json
{
  "1": ["Rarely takes initiative", "Needs reminders to complete tasks"],
  "2": ["Sometimes shows initiative", "Occasionally needs guidance"],
  "3": ["Consistently proactive", "Independently drives work"],
  "4": ["Anticipates needs", "Helps others be proactive"],
  "5": ["Role model for initiative", "Creates culture of ownership"]
}
```

---

## 3. Competency Types

| Type | Description | Example | Who |
|------|-------------|---------|-----|
| **CORE** | Company values | Integrity, Innovation | All employees |
| **LEADERSHIP** | People management | Coaching, Decision Making | Managers |
| **FUNCTIONAL** | Role-specific behaviors | Client Focus, Technical Depth | By role |
| **TECHNICAL_BEHAVIORAL** | Mixed technical + soft | Solution Thinking | Technical roles |

---

## 4. Relationships

```mermaid
erDiagram
    CompetencyCategory ||--o{ Competency : hasCompetencies
    Competency ||--o{ WorkerCompetency : assessedFor
    Worker ||--o{ WorkerCompetency : hasAssessments
    
    Competency {
        string id PK
        string code UK
        string name
        string categoryId FK
        enum competencyType
        json behavioralIndicators
        boolean isCore
    }
    
    WorkerCompetency {
        string workerId FK
        string competencyId FK
        decimal ratingValue
        string sourceCode
        date assessedDate
    }
```

---

## 5. Use Cases

### 1. Core Value Competency

```yaml
Competency:
  code: "INTEGRITY"
  name: "Integrity"
  nameVn: "Chính trực"
  categoryId: "cat-core-values"
  competencyType: "CORE"
  scaleCode: "BEHAVIORAL_1_5"
  maxRatingLevel: 5
  isCore: true
  description: "Acts with honesty and transparency in all situations"
  behavioralIndicators:
    "1": ["Occasionally misrepresents facts", "Avoids accountability"]
    "3": ["Consistently honest", "Takes responsibility for mistakes"]
    "5": ["Role model for integrity", "Creates culture of transparency"]
  isActive: true
```

### 2. Leadership Competency

```yaml
Competency:
  code: "COACHING"
  name: "Coaching & Development"
  nameVn: "Huấn luyện & Phát triển"
  categoryId: "cat-people-mgmt"
  competencyType: "LEADERSHIP"
  scaleCode: "LEADERSHIP_SCALE"
  maxRatingLevel: 5
  isCore: false
  description: "Develops others through feedback, coaching, and opportunities"
  behavioralIndicators:
    "1": ["Provides little feedback", "Does not invest in team development"]
    "3": ["Regularly gives feedback", "Creates development plans"]
    "5": ["Known as great coach", "Team members promoted/developed"]
  isActive: true
```

---

## 6. Assessment Example

```
Worker: Nguyễn Văn A
Competency: COACHING
Assessment: 360 Feedback

Self:     4/5
Manager:  3/5
Peers:    4/5
Direct:   3/5
---
Average:  3.5/5

Gap Analysis:
- Expected (Manager level): 4/5
- Actual: 3.5/5
- Gap: -0.5
- Recommendation: Leadership coaching program
```

---

*Document Status: APPROVED*  
*References: [[CompetencyCategory]], [[Worker]], [[WorkerCompetency]]*
