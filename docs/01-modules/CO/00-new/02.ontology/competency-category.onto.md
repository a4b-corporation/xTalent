---
entity: CompetencyCategory
domain: common
version: "1.0.0"
status: approved
owner: Skills & Competency Team
tags: [competency, category, taxonomy, hierarchy, behavioral]

# NOTE: CompetencyCategory provides hierarchical classification for Competencies.
# Competencies are behavioral/soft traits (HOW you work), vs Skills (WHAT you do).
# Example hierarchy:
#   Core Values > Integrity > Ethical Behavior
#   Leadership > People Management > Coaching
#   Execution > Results Orientation > Accountability

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
    description: Category code (e.g., CORE_VALUES, LEADERSHIP, EXECUTION)
    constraints:
      maxLength: 50
      pattern: "^[A-Z][A-Z0-9_]*$"
  
  - name: name
    type: string
    required: true
    description: Category display name
    constraints:
      maxLength: 255
  
  - name: nameVn
    type: string
    required: false
    description: Vietnamese display name
    constraints:
      maxLength: 255
  
  # === HIERARCHY ===
  - name: parentId
    type: string
    required: false
    description: FK → CompetencyCategory.id (self-referential for hierarchy)
  
  - name: level
    type: integer
    required: false
    description: Depth level in hierarchy (1 = root)
    constraints:
      min: 1
      max: 10
  
  - name: sortOrder
    type: integer
    required: false
    description: Sort order within parent for UI display
    constraints:
      min: 0
  
  # === FRAMEWORK ===
  - name: frameworkCode
    type: string
    required: false
    description: Competency framework this category belongs to (e.g., COMPANY_CORE, LEADERSHIP_PIPELINE)
    constraints:
      maxLength: 50
  
  # === METADATA ===
  - name: description
    type: string
    required: false
    description: Detailed description of this category
    constraints:
      maxLength: 1000
  
  - name: metadata
    type: json
    required: false
    description: Additional flexible data (icons, colors, etc.)
  
  # === STATUS ===
  - name: isActive
    type: boolean
    required: true
    default: true
    description: Is this category currently active?
  
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
  - name: parent
    target: CompetencyCategory
    cardinality: many-to-one
    required: false
    inverse: children
    description: Parent category (self-referential hierarchy).
  
  - name: children
    target: CompetencyCategory
    cardinality: one-to-many
    required: false
    inverse: parent
    description: Child categories.
  
  - name: hasCompetencies
    target: Competency
    cardinality: one-to-many
    required: false
    inverse: belongsToCategory
    description: Competencies in this category.

lifecycle:
  states: [ACTIVE, INACTIVE]
  initial: ACTIVE
  terminal: []
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: No active competencies in this category
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate

policies:
  - name: UniqueCodeGlobally
    type: validation
    rule: Category code must be unique
    expression: "UNIQUE(code)"
  
  - name: ParentNotSelf
    type: validation
    rule: Category cannot be its own parent
    expression: "parentId IS NULL OR parentId != id"
---

# Entity: CompetencyCategory

## 1. Overview

**CompetencyCategory** provides a hierarchical taxonomy for organizing Competencies. Competencies represent behavioral traits and soft skills (HOW you work), as opposed to Skills (WHAT you do).

```mermaid
mindmap
  root((CompetencyCategory))
    Identity
      id
      code
      name
    Hierarchy
      parentId
      level
      sortOrder
    Framework
      frameworkCode
    Status
      isActive
    Relationships
      parent
      children
      hasCompetencies
```

### Competency vs Skill

| Aspect | Skill | Competency |
|--------|-------|------------|
| **Nature** | Technical ability | Behavioral trait |
| **Question** | "What can you do?" | "How do you do it?" |
| **Measurement** | Objective (tests, certs) | Subjective (ratings, 360) |
| **Example** | Java, Excel, SQL | Leadership, Communication |

### Example Hierarchy

```
Core Values (Framework: COMPANY_CORE)
├── Integrity
│   ├── Ethical Behavior
│   └── Transparency
├── Innovation
│   ├── Creativity
│   └── Risk Taking
└── Customer Focus
    ├── Client Orientation
    └── Service Excellence

Leadership (Framework: LEADERSHIP_PIPELINE)
├── People Management
│   ├── Coaching
│   ├── Delegation
│   └── Team Building
├── Strategic Thinking
│   ├── Vision Setting
│   └── Long-term Planning
└── Decision Making
    ├── Critical Thinking
    └── Problem Solving

Execution (Framework: COMPANY_CORE)
├── Results Orientation
│   ├── Accountability
│   └── Goal Achievement
├── Time Management
│   └── Prioritization
└── Quality Focus
    └── Attention to Detail
```

---

## 2. Attributes

### Identity

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique identifier (UUID) |
| code | string | ✓ | Category code |
| name | string | ✓ | Display name |
| nameVn | string | | Vietnamese name |

### Hierarchy & Framework

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| parentId | string | | FK → self |
| level | integer | | Depth (1 = root) |
| frameworkCode | string | | Competency framework |

---

## 3. Relationships

```mermaid
erDiagram
    CompetencyCategory ||--o{ CompetencyCategory : "parent/children"
    CompetencyCategory ||--o{ Competency : hasCompetencies
    
    CompetencyCategory {
        string id PK
        string code UK
        string name
        string parentId FK
        string frameworkCode
        boolean isActive
    }
    
    Competency {
        string id PK
        string categoryId FK
    }
```

---

## 4. Use Cases

### Core Values Category

```yaml
CompetencyCategory:
  code: "CORE_VALUES"
  name: "Core Values"
  nameVn: "Giá trị Cốt lõi"
  parentId: null
  level: 1
  frameworkCode: "COMPANY_CORE"
  isActive: true
```

### Leadership Category

```yaml
CompetencyCategory:
  code: "PEOPLE_MGMT"
  name: "People Management"
  nameVn: "Quản lý Con người"
  parentId: "cat-leadership"
  level: 2
  frameworkCode: "LEADERSHIP_PIPELINE"
  sortOrder: 1
  isActive: true
```

---

*Document Status: APPROVED*  
*References: [[Competency]], [[Worker]], [[JobProfile]]*
