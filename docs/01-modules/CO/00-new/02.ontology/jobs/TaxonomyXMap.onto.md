---
entity: TaxonomyXMap
domain: job-position
version: "1.0.0"
status: approved
owner: Core HR Team
tags: [job-taxonomy, cross-tree-mapping, consolidation]

# === ATTRIBUTES ===
attributes:
  # --- Identifiers ---
  - name: id
    type: string
    required: true
    unique: true
    description: "Primary key (UUID)"
  
  - name: srcNodeId
    type: string
    required: true
    description: "FK → JobTaxonomy.id - source node (typically in BU tree)"
  
  - name: targetNodeId
    type: string
    required: true
    description: "FK → JobTaxonomy.id - target node (typically in CORP tree)"
  
  # --- Mapping Type ---
  - name: mapTypeCode
    type: enum
    required: true
    description: "Type of cross-tree relationship"
    values: [REPORT_TO, ALIGN_WITH, DUPLICATE_OF]
    # REPORT_TO = BU node reports to Corp node for analytics
    # ALIGN_WITH = BU node aligns semantically with Corp node
    # DUPLICATE_OF = BU node is copy of Corp node (full inheritance)
  
  # --- Metadata ---
  - name: comment
    type: string
    required: false
    description: "Rationale for this mapping"
  
  # --- SCD Type-2 (History) ---
  - name: effectiveStartDate
    type: date
    required: true
    description: "Start of mapping validity"
  
  - name: effectiveEndDate
    type: date
    required: false
    description: "End of mapping validity (null = current)"
  
  - name: isCurrentFlag
    type: boolean
    required: true
    description: "true = current version, false = historical"
  
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
  - name: sourceNode
    target: "[[JobTaxonomy]]"
    cardinality: many-to-one
    required: true
    description: "Source taxonomy node (from BU/LE tree)"
  
  - name: targetNode
    target: "[[JobTaxonomy]]"
    cardinality: many-to-one
    required: true
    description: "Target taxonomy node (typically in CORP tree)"

# === LIFECYCLE ===
lifecycle:
  states: [ACTIVE, INACTIVE]
  initial: ACTIVE
  terminal: []
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate

# === POLICIES ===
policies:
  - name: differentTrees
    type: validation
    rule: "Source and target nodes must be in different trees"
    expression: "sourceNode.treeId != targetNode.treeId"
  
  - name: noSelfMapping
    type: validation
    rule: "Cannot map a node to itself"
    expression: "srcNodeId != targetNodeId"
  
  - name: uniqueActiveMapping
    type: validation
    rule: "Only one active mapping per source-target-type combination"
    expression: "UNIQUE(srcNodeId, targetNodeId, mapTypeCode) WHERE isCurrentFlag = true"
---

# Entity: TaxonomyXMap

## 1. Overview

**TaxonomyXMap** (Cross-Tree Mapping) enables linking taxonomy nodes between different [[TaxonomyTree]]s for reporting consolidation. This is essential when Business Units have custom taxonomies but need to roll up to corporate standards.

```mermaid
mindmap
  root((TaxonomyXMap))
    Purpose
      Reporting consolidation
      BU → Corp rollup
      Semantic alignment
    Map Types
      REPORT_TO - Analytics hierarchy
      ALIGN_WITH - Semantic match
      DUPLICATE_OF - Full copy
    Features
      Cross-tree linking
      SCD Type-2 history
      Bidirectional lookup
```

### Use Cases

| Scenario | Map Type | Description |
|----------|----------|-------------|
| **Analytics Rollup** | REPORT_TO | BU node rolls up to Corp for reports |
| **Semantic Match** | ALIGN_WITH | BU uses different name but same meaning |
| **Cloned Node** | DUPLICATE_OF | BU copies Corp node exactly |

---

## 2. Attributes

### Identifiers & Links

| Attribute | Type | Req | Description | DB Column |
|-----------|------|-----|-------------|----------|
| `id` | uuid | Y | Primary key | jobpos.taxonomy_xmap.id |
| `srcNodeId` | uuid | Y | FK → [[JobTaxonomy]] (source, typically BU) | jobpos.taxonomy_xmap.src_node_id → jobpos.job_taxonomy.id |
| `targetNodeId` | uuid | Y | FK → [[JobTaxonomy]] (target, typically Corp) | jobpos.taxonomy_xmap.target_node_id → jobpos.job_taxonomy.id |

### Mapping Type

| Attribute | Type | Req | Values | Description | DB Column |
|-----------|------|-----|--------|-------------|----------|
| `mapTypeCode` | enum | Y | REPORT_TO, ALIGN_WITH, DUPLICATE_OF | Relationship type | jobpos.taxonomy_xmap.map_type_code → common.code_list(XMAP_TYPE) |

### Metadata

| Attribute | Type | Req | Description | DB Column |
|-----------|------|-----|-------------|----------|
| `comment` | text | N | Mapping rationale | jobpos.taxonomy_xmap.comment |

### SCD Type-2

| Attribute | Type | Req | Description | DB Column |
|-----------|------|-----|-------------|----------|
| `effectiveStartDate` | date | Y | Start of validity | jobpos.taxonomy_xmap.effective_start_date |
| `effectiveEndDate` | date | N | End of validity | jobpos.taxonomy_xmap.effective_end_date |
| `isCurrentFlag` | boolean | Y | Current version | jobpos.taxonomy_xmap.is_current_flag |

### Audit

| Attribute | Type | Req | Description | DB Column |
|-----------|------|-----|-------------|----------|
| `createdAt` | datetime | Y | Creation timestamp | jobpos.taxonomy_xmap.created_at |
| `updatedAt` | datetime | N | Last update | jobpos.taxonomy_xmap.updated_at |

---

## 3. Relationships

```mermaid
erDiagram
    TaxonomyXMap }o--|| JobTaxonomy : "source"
    TaxonomyXMap }o--|| JobTaxonomy : "target"
    
    TaxonomyXMap {
        uuid id PK
        uuid srcNodeId FK
        uuid targetNodeId FK
        enum mapTypeCode
        date effectiveStartDate
        boolean isCurrentFlag
    }
    
    JobTaxonomy {
        uuid id PK
        uuid treeId FK
        string taxonomyCode
    }
```

### Relationship Details

| Relationship | Target | Cardinality | Description |
|--------------|--------|-------------|-------------|
| `sourceNode` | [[JobTaxonomy]] | N:1 | Source node (from BU/LE tree) |
| `targetNode` | [[JobTaxonomy]] | N:1 | Target node (typically CORP tree) |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> ACTIVE : create
    
    ACTIVE --> INACTIVE : deactivate
    INACTIVE --> ACTIVE : reactivate
```

### State Definitions

| State | Description |
|-------|-------------|
| `ACTIVE` | Mapping is in effect for reporting |
| `INACTIVE` | Mapping suspended but preserved |

---

## 5. Business Rules Reference

| Rule | Type | Description |
|------|------|-------------|
| BR-XM-001 | Validation | Source and target must be in different trees |
| BR-XM-002 | Validation | Cannot map a node to itself |
| BR-XM-003 | Validation | Only one active mapping per src-target-type |

### Map Type Semantics

| Type | Behavior |
|------|----------|
| **REPORT_TO** | Source node values aggregate to target in reports |
| **ALIGN_WITH** | Source semantically matches target (for lookups) |
| **DUPLICATE_OF** | Source is exact copy, inherits all target changes |

### Example: BU to Corp Mapping

```
CORP_TREE                     BU_GAME_TREE
├── Technology ◄──────────── ├── Technology (DUPLICATE_OF)
│   ├── Software Eng ◄───── │   ├── Software Eng (ALIGN_WITH)
│   └── (no match)           │   ├── Game Development (REPORT_TO → Technology)
                             │   └── Game Art (REPORT_TO → Technology)
```

In this example:
- "BU.Technology" is a `DUPLICATE_OF` "CORP.Technology" (full copy)
- "BU.Software Eng" `ALIGN_WITH` "CORP.Software Eng" (same meaning)
- "BU.Game Development" `REPORT_TO` "CORP.Technology" (rolls up for reporting)

---

*References*: [[JobTaxonomy]], [[TaxonomyTree]]
