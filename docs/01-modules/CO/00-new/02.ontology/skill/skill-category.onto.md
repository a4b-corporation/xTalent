---
entity: SkillCategory
domain: common
version: "1.0.0"
status: approved
owner: Skills & Competency Team
tags: [skill, category, taxonomy, hierarchy]

# NOTE: SkillCategory provides hierarchical classification for Skills.
# Pattern: Similar to JobTaxonomy but for skills domain.
# Example hierarchy:
#   Technical > Programming Languages > Backend > Java
#   Technical > Cloud & DevOps > Container > Kubernetes
#   Soft Skills > Communication > Presentation

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
    description: Category code (e.g., TECH, PROG, SOFT_SKILLS)
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
    description: FK → SkillCategory.id (self-referential for hierarchy)
  
  - name: level
    type: integer
    required: false
    description: Depth level in hierarchy (1 = root, 2 = child, etc.)
    constraints:
      min: 1
      max: 10
  
  - name: sortOrder
    type: integer
    required: false
    description: Sort order within parent for UI display
    constraints:
      min: 0
  
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
    target: SkillCategory
    cardinality: many-to-one
    required: false
    inverse: children
    description: Parent category (self-referential hierarchy).
  
  - name: children
    target: SkillCategory
    cardinality: one-to-many
    required: false
    inverse: parent
    description: Child categories.
  
  - name: hasSkills
    target: Skill
    cardinality: one-to-many
    required: false
    inverse: belongsToCategory
    description: Skills in this category.

lifecycle:
  states: [ACTIVE, INACTIVE]
  initial: ACTIVE
  terminal: []
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: No active skills in this category
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
  
  - name: MaxDepth
    type: validation
    rule: Hierarchy cannot exceed 10 levels
    expression: "level <= 10"
    severity: WARNING
---

# Entity: SkillCategory

## 1. Overview

**SkillCategory** provides a hierarchical taxonomy for organizing Skills. It enables multi-level classification such as Technical → Programming → Backend → Java.

```mermaid
mindmap
  root((SkillCategory))
    Identity
      id
      code
      name
      nameVn
    Hierarchy
      parentId
      level
      sortOrder
    Status
      isActive
    Relationships
      parent
      children
      hasSkills
```

### Example Hierarchy

```
Technical
├── Programming Languages
│   ├── Backend
│   │   ├── Java
│   │   ├── Python
│   │   └── Go
│   └── Frontend
│       ├── JavaScript
│       ├── TypeScript
│       └── React
├── Cloud & DevOps
│   ├── Cloud Platforms
│   │   ├── AWS
│   │   ├── Azure
│   │   └── GCP
│   └── Containerization
│       ├── Docker
│       └── Kubernetes
└── Database
    ├── SQL
    │   ├── PostgreSQL
    │   └── MySQL
    └── NoSQL
        ├── MongoDB
        └── Redis

Soft Skills
├── Communication
│   ├── Written Communication
│   └── Presentation
├── Leadership
│   ├── Team Building
│   └── Coaching
└── Problem Solving
    ├── Critical Thinking
    └── Decision Making
```

---

## 2. Attributes

### Identity

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique identifier (UUID) |
| code | string | ✓ | Category code (UPPER_SNAKE) |
| name | string | ✓ | Display name |
| nameVn | string | | Vietnamese name |

### Hierarchy

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| parentId | string | | FK → self (parent category) |
| level | integer | | Depth (1 = root) |
| sortOrder | integer | | Sort within parent |

---

## 3. Relationships

```mermaid
erDiagram
    SkillCategory ||--o{ SkillCategory : "parent/children"
    SkillCategory ||--o{ Skill : hasSkills
    
    SkillCategory {
        string id PK
        string code UK
        string name
        string parentId FK
        int level
        boolean isActive
    }
    
    Skill {
        string id PK
        string categoryId FK
    }
```

---

## 4. Use Cases

### 1. Root Category

```yaml
SkillCategory:
  code: "TECHNICAL"
  name: "Technical Skills"
  nameVn: "Kỹ năng Kỹ thuật"
  parentId: null
  level: 1
  isActive: true
```

### 2. Child Category

```yaml
SkillCategory:
  code: "PROG_LANG"
  name: "Programming Languages"
  nameVn: "Ngôn ngữ Lập trình"
  parentId: "category-technical"
  level: 2
  sortOrder: 1
  isActive: true
```

---

*Document Status: APPROVED*  
*References: [[Skill]], [[JobProfile]], [[Worker]]*
