---
entity: TaxonomyTree
domain: job-position
version: "1.0.0"
status: approved
owner: Core HR Team
tags: [job-taxonomy, classification, multi-scope]

# === ATTRIBUTES ===
attributes:
  # --- Identifiers ---
  - name: id
    type: string
    required: true
    unique: true
    description: "Primary key (UUID)"
  
  - name: treeCode
    type: string
    required: true
    unique: true
    description: "Unique code for the taxonomy tree (e.g., CORP_TREE, BU_GAME_TREE)"
    constraints:
      pattern: "^[A-Z][A-Z0-9_]{2,49}$"
  
  - name: treeName
    type: string
    required: true
    description: "Display name for the taxonomy tree"
    constraints:
      max: 255
  
  # --- Ownership & Scope ---
  - name: ownerScope
    type: enum
    required: true
    description: "Organizational scope that owns this tree"
    values: [CORP, LE, BU]
    # CORP = Corporate-level (shared across all entities)
    # LE = Legal Entity-specific
    # BU = Business Unit-specific
  
  - name: ownerUnitId
    type: string
    required: false
    description: "FK → BusinessUnit.id (required if ownerScope = LE or BU)"
  
  # --- Metadata ---
  - name: description
    type: string
    required: false
    description: "Optional description of the taxonomy tree purpose"
  
  # --- Audit ---
  - name: createdAt
    type: datetime
    required: true
    description: "Creation timestamp"
  
  - name: updatedAt
    type: datetime
    required: false
    description: "Last update timestamp"

# === RELATIONSHIPS ===
relationships:
  - name: ownerUnit
    target: "[[BusinessUnit]]"
    cardinality: many-to-one
    required: false
    description: "Business Unit that owns this tree (for LE/BU scope)"
  
  - name: taxonomyNodes
    target: "[[JobTaxonomy]]"
    cardinality: one-to-many
    required: false
    inverse: belongsToTree
    description: "All taxonomy nodes within this tree"

# === LIFECYCLE ===
lifecycle:
  states: [ACTIVE, INACTIVE, ARCHIVED]
  initial: ACTIVE
  terminal: [ARCHIVED]
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: "No active jobs mapped to this tree's nodes"
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate
    - from: INACTIVE
      to: ARCHIVED
      trigger: archive
      guard: "Tree not referenced by any current mappings"

# === POLICIES ===
policies:
  - name: corpTreeUniqueness
    type: validation
    rule: "Only one CORP-scope tree can exist globally"
    expression: "COUNT(ownerScope = 'CORP') <= 1"
  
  - name: ownerUnitRequired
    type: validation
    rule: "ownerUnitId required when ownerScope is LE or BU"
    expression: "(ownerScope IN ['LE', 'BU']) IMPLIES (ownerUnitId IS NOT NULL)"
  
  - name: treeCodeImmutable
    type: business
    rule: "treeCode cannot be changed after creation"
---

# Entity: TaxonomyTree

## 1. Overview

**TaxonomyTree** is a registry entity that manages independent taxonomy trees within an organization. Each tree can be owned at different organizational scopes (Corporate, Legal Entity, or Business Unit) to support multi-tenant job classifications.

```mermaid
mindmap
  root((TaxonomyTree))
    Scope
      CORP - Corporate level
      LE - Legal Entity
      BU - Business Unit
    Contains
      JobTaxonomy nodes
      N-level hierarchy
    Purpose
      Multi-tenant classification
      Clone & customize
      Reporting consolidation
    Key Features
      Multi-scope ownership
      Tree isolation
      Cross-tree mapping
```

### Use Cases

| Scenario | Pattern |
|----------|---------|
| **Single Corp Tree** | All entities share one taxonomy (ownerScope = CORP) |
| **BU Customization** | BU clones Corp tree, adds specific nodes |
| **Regional Variation** | Different LE trees for different countries |

---

## 2. Attributes

### Identifiers

| Attribute | Type | Req | Description |
|-----------|------|-----|-------------|
| `id` | uuid | Y | Primary key |
| `treeCode` | string(50) | Y | Unique tree code (UPPER_SNAKE_CASE) |
| `treeName` | string(255) | Y | Display name |

### Ownership

| Attribute | Type | Req | Description |
|-----------|------|-----|-------------|
| `ownerScope` | enum | Y | CORP \| LE \| BU |
| `ownerUnitId` | uuid | N | FK → [[BusinessUnit]] (required for LE/BU) |

### Metadata

| Attribute | Type | Req | Description |
|-----------|------|-----|-------------|
| `description` | text | N | Tree purpose description |
| `createdAt` | datetime | Y | Creation timestamp |
| `updatedAt` | datetime | N | Last update |

---

## 3. Relationships

```mermaid
erDiagram
    TaxonomyTree ||--o{ JobTaxonomy : "contains"
    TaxonomyTree }o--o| BusinessUnit : "owned by"
    
    TaxonomyTree {
        uuid id PK
        string treeCode UK
        string treeName
        enum ownerScope
        uuid ownerUnitId FK
    }
    
    JobTaxonomy {
        uuid id PK
        uuid treeId FK
        string taxonomyCode
    }
    
    BusinessUnit {
        uuid id PK
        string code
    }
```

### Relationship Details

| Relationship | Target | Cardinality | Description |
|--------------|--------|-------------|-------------|
| `ownerUnit` | [[BusinessUnit]] | N:1 | Owner (for LE/BU scope) |
| `taxonomyNodes` | [[JobTaxonomy]] | 1:N | All nodes in tree |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> ACTIVE : create
    
    ACTIVE --> INACTIVE : deactivate
    INACTIVE --> ACTIVE : reactivate
    INACTIVE --> ARCHIVED : archive
    
    ARCHIVED --> [*]
    
    note right of INACTIVE
        Guard: No active jobs
        mapped to tree nodes
    end note
```

### State Definitions

| State | Description |
|-------|-------------|
| `ACTIVE` | Tree is in use, nodes can be modified |
| `INACTIVE` | Tree is disabled, no new mappings allowed |
| `ARCHIVED` | Permanent archive, read-only |

---

## 5. Business Rules Reference

| Rule | Type | Description |
|------|------|-------------|
| BR-TT-001 | Validation | Only one CORP-scope tree can exist |
| BR-TT-002 | Validation | ownerUnitId required for LE/BU scope |
| BR-TT-003 | Business | treeCode immutable after creation |
| BR-TT-004 | Business | Cannot archive tree with active mappings |

### Scope Priority (for resolution)

```
1. BU-specific (ownerScope = BU, matching ownerUnitId)
2. LE-specific (ownerScope = LE, matching Legal Entity)
3. CORP-level (ownerScope = CORP)
```

---

*References*: [[JobTaxonomy]], [[BusinessUnit]], [[TaxonomyXMap]]
