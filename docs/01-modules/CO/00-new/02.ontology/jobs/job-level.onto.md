---
entity: JobLevel
domain: jobpos
version: "1.0.0"
status: approved
owner: Job & Position Management Team
tags: [job-level, seniority, career, position]

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
    description: Level code (e.g., L1, L2, L3 or JUNIOR, MID, SENIOR)
    constraints:
      maxLength: 50
      pattern: "^[A-Z][A-Z0-9_-]*$"
  
  - name: name
    type: string
    required: true
    description: Display name (e.g., Junior, Mid-Level, Senior, Principal)
    constraints:
      maxLength: 100
  
  - name: nameVn
    type: string
    required: false
    description: Vietnamese display name (e.g., Sơ cấp, Trung cấp, Cao cấp)
    constraints:
      maxLength: 100
  
  # === RANKING ===
  - name: rankOrder
    type: integer
    required: true
    description: Numeric order for sorting (1=lowest, higher=more senior)
    constraints:
      min: 1
      max: 100
  
  # === GUIDANCE (Optional) ===
  - name: minExperienceYears
    type: integer
    required: false
    description: Suggested minimum years of experience for this level
    constraints:
      min: 0
      max: 50
  
  - name: typicalGradeRange
    type: string
    required: false
    description: Typical pay grade range (hint only, e.g., "G8-G10")
    constraints:
      maxLength: 50
  
  # === OWNERSHIP ===
  - name: ownerScope
    type: enum
    required: true
    description: Organizational scope that owns this level definition
    values: [CORP, LE, BU]
    default: CORP
  
  - name: ownerUnitId
    type: string
    required: false
    description: FK → BusinessUnit.id (required if ownerScope = LE or BU)
  
  # === STATUS ===
  - name: isActive
    type: boolean
    required: true
    default: true
    description: Is this level currently active?
  
  # === METADATA ===
  - name: description
    type: string
    required: false
    description: Description of this level's expectations
    constraints:
      maxLength: 1000
  
  - name: metadata
    type: json
    required: false
    description: Additional flexible data (competency expectations, etc.)
  
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
  - name: ownerUnit
    target: BusinessUnit
    cardinality: many-to-one
    required: false
    inverse: hasJobLevels
    description: Business unit that owns this level (for LE/BU scope).
  
  - name: hasPositions
    target: Position
    cardinality: one-to-many
    required: false
    inverse: atJobLevel
    description: Positions at this seniority level.

lifecycle:
  states: [ACTIVE, INACTIVE]
  initial: ACTIVE
  terminal: []
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: No active positions use this level
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate

policies:
  - name: UniqueCodeGlobally
    type: validation
    rule: Level code must be unique across all levels
    expression: "UNIQUE(code)"
  
  - name: RankOrderUnique
    type: validation
    rule: Rank order should be unique per scope for proper sorting
    expression: "UNIQUE(rankOrder, ownerScope, ownerUnitId)"
    severity: WARNING
  
  - name: OwnerUnitRequiredForScope
    type: validation
    rule: ownerUnitId required when ownerScope is LE or BU
    expression: "(ownerScope = 'CORP') OR (ownerUnitId IS NOT NULL)"
  
  - name: NoDeleteWithActivePositions
    type: business
    rule: Cannot delete level with active positions
    expression: "COUNT(Position WHERE jobLevelId = this.id AND statusCode = 'ACTIVE') = 0"
---

# Entity: JobLevel

## 1. Overview

**JobLevel** represents the **seniority/expertise level** within a career progression. It is a master data entity that Position references to indicate the level of the role holder.

**Key Concept**:
```
Job (Template) + JobLevel (Seniority) = Position (Instance)

Example:
Job: "Software Developer"
Level: "Senior" (L3)
= Position: "Senior Software Developer - Team A"
```

```mermaid
mindmap
  root((JobLevel))
    Identity
      id
      code
      name
      nameVn
    Ranking
      rankOrder
    Guidance
      minExperienceYears
      typicalGradeRange
    Ownership
      ownerScope
      ownerUnitId
    Status
      isActive
    Relationships
      ownerUnit
      hasPositions
```

### Why Level on Position (Not Job)?

| Approach | Jobs Needed | Positions Created |
|----------|-------------|-------------------|
| ❌ Level in Job | 4 Jobs × 5 Levels = **20 Jobs** | 20 Positions |
| ✅ Level in Position | **4 Jobs** | 20 Positions (flexible) |

**Industry Pattern**: Workday, Oracle HCM, SAP SF all put Level on Position/Assignment, not on Job Profile.

### Standard Levels

| Code | Name | Rank | Typical Experience |
|------|------|------|-------------------|
| L1 | Junior | 1 | 0-2 years |
| L2 | Mid-Level | 2 | 2-4 years |
| L3 | Senior | 3 | 4-7 years |
| L4 | Principal | 4 | 7-10 years |
| L5 | Staff | 5 | 10-15 years |
| L6 | Distinguished | 6 | 15+ years |

---

## 2. Attributes

### 2.1 Identity

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| id | string | ✓ | Unique identifier (UUID) | jobpos.job_level.id |
| code | string | ✓ | Level code (L1, JUNIOR, etc.) | jobpos.job_level.level_code |
| name | string | ✓ | Display name | jobpos.job_level.name |
| nameVn | string | | Vietnamese name | (jobpos.job_level.metadata.name_vn) |

### 2.2 Ranking

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| rankOrder | integer | ✓ | Numeric order for sorting (1=lowest) | jobpos.job_level.rank_order |

### 2.3 Guidance

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| minExperienceYears | integer | | Suggested min experience | (jobpos.job_level.metadata.min_experience_years) |
| typicalGradeRange | string | | Pay grade hint (e.g., "G8-G10") | (jobpos.job_level.metadata.typical_grade_range) |

### 2.4 Ownership

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| ownerScope | enum | ✓ | CORP (global), LE (legal entity), BU (business unit) | (jobpos.job_level.metadata.owner_scope) |
| ownerUnitId | string | | FK → [[BusinessUnit]] if scope is LE/BU | (jobpos.job_level.metadata.owner_unit_id) → org_bu.unit.id |

---

## 3. Relationships

```mermaid
erDiagram
    BusinessUnit ||--o{ JobLevel : hasJobLevels
    JobLevel ||--o{ Position : hasPositions
    
    JobLevel {
        string id PK
        string code UK
        string name
        int rankOrder
        enum ownerScope
        string ownerUnitId FK
    }
    
    Position {
        string id PK
        string jobLevelId FK
        string jobId FK
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[BusinessUnit]] | ownerUnit | N:1 | Owner (for LE/BU scope) |
| [[Position]] | hasPositions | 1:N | Positions at this level |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> ACTIVE: Create Level
    
    ACTIVE --> INACTIVE: Deactivate
    INACTIVE --> ACTIVE: Reactivate
    
    note right of ACTIVE
        Available for position assignment
    end note
    
    note right of INACTIVE
        Disabled, no new positions
    end note
```

---

## 5. Business Rules Reference

### Validation Rules
- **UniqueCodeGlobally**: Code unique across all levels
- **RankOrderUnique**: Rank unique per scope (WARNING)
- **OwnerUnitRequiredForScope**: ownerUnitId required for LE/BU

### Business Constraints
- **NoDeleteWithActivePositions**: Cannot delete level with active positions

### Use Cases

#### 1. Corporate Level Definition

```yaml
JobLevel:
  code: "L3"
  name: "Senior"
  nameVn: "Cao cấp"
  rankOrder: 3
  ownerScope: "CORP"
  minExperienceYears: 4
  typicalGradeRange: "G10-G12"
  isActive: true
```

#### 2. BU-Specific Level

```yaml
JobLevel:
  code: "TECH_LEAD"
  name: "Tech Lead"
  nameVn: "Trưởng nhóm Kỹ thuật"
  rankOrder: 4
  ownerScope: "BU"
  ownerUnitId: "bu-engineering"
  minExperienceYears: 5
  typicalGradeRange: "G11-G13"
```

---

*Document Status: APPROVED*  
*This entity enables Position-based leveling, avoiding Job explosion while maintaining flexibility.*
