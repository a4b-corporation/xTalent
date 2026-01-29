---
entity: JobTaxonomy
domain: job-position
version: "1.0.0"
status: approved
owner: Core HR Team
tags: [job-taxonomy, job-family, job-track, classification, hierarchy]

# === ATTRIBUTES ===
attributes:
  # --- Identifiers ---
  - name: id
    type: string
    required: true
    unique: true
    description: "Primary key (UUID)"
  
  - name: treeId
    type: string
    required: true
    description: "FK → TaxonomyTree.id - which tree this node belongs to"
  
  - name: taxonomyCode
    type: string
    required: true
    description: "Unique code within tree+type combination"
    constraints:
      pattern: "^[A-Z][A-Z0-9_-]{1,49}$"
  
  - name: taxonomyName
    type: string
    required: true
    description: "Display name for the taxonomy node"
    constraints:
      max: 255
  
  # --- Hierarchy ---
  - name: taxonomyType
    type: enum
    required: true
    description: "Classification type of this node"
    values: [FAMILY_GROUP, FAMILY, TRACK, GROUP]
    # FAMILY_GROUP = Highest level (e.g., "Technology")
    # FAMILY = Functional grouping (e.g., "Software Engineering")
    # TRACK = Career path (e.g., "Individual Contributor", "Management")
    # GROUP = Other logical grouping (extensible)
  
  - name: taxonomyDimension
    type: enum
    required: false
    description: "Classification dimension purpose (helps AI/rule engines understand semantic meaning)"
    values: [FUNCTIONAL, CAREER, REPORTING, OTHER]
    # FUNCTIONAL = What the job does (Engineering, Finance, HR)
    # CAREER = Career progression path (IC Track, Management Track)
    # REPORTING = Organizational reporting structure
    # OTHER = Custom/tenant-specific dimension
  
  - name: parentId
    type: string
    required: false
    description: "FK → self (JobTaxonomy.id) for parent-child hierarchy"
  
  - name: levelOrder
    type: integer
    required: false
    description: "Sort order within parent node (for UI rendering and dropdowns)"
    constraints:
      min: 0
  
  # --- Ownership & Inheritance ---
  - name: ownerScope
    type: enum
    required: true
    description: "Organizational scope that owns this node"
    values: [CORP, LE, BU]
  
  - name: ownerUnitId
    type: string
    required: false
    description: "FK → BusinessUnit.id (required if ownerScope = LE or BU)"
  
  - name: inheritFlag
    type: boolean
    required: true
    description: "true = inherit from parent tree node, false = complete override"
  
  - name: overrideName
    type: string
    required: false
    description: "Local name override when inheritFlag = true"
  
  - name: visibility
    type: enum
    required: false
    description: "Access visibility for this node"
    values: [PUBLIC, PRIVATE, RESTRICTED]
  
  # --- Status ---
  - name: isActive
    type: boolean
    required: true
    description: "Active status (true = available for use)"
  
  # --- Metadata ---
  - name: description
    type: string
    required: false
    description: "Description of this taxonomy node"
  
  - name: metadata
    type: object
    required: false
    description: "Extended attributes (competencies, skills hints, etc.)"
  
  # --- OPTIONAL: Job Reference Node (JobDef Pattern) ---
  # NOTE: This is an ALTERNATIVE pattern for tenants who prefer NOT to use JobTaxonomyMap.
  # RECOMMENDED approach is to use JobTaxonomyMap for Job <-> Taxonomy mapping.
  # JobDef pattern allows creating "virtual nodes" that link directly to Job entities.
  - name: nodeType
    type: enum
    required: false
    description: "Node type - CATEGORY (default) or JOB_REFERENCE (virtual node pointing to Job)"
    values: [CATEGORY, JOB_REFERENCE]
    default: CATEGORY
    # CATEGORY = Normal classification node (default)
    # JOB_REFERENCE = Virtual node that links to a Job entity (alternative to JobTaxonomyMap)
  
  - name: linkedJobId
    type: string
    required: false
    description: "FK → Job.id. ONLY used when nodeType = JOB_REFERENCE. Alternative to JobTaxonomyMap."
  
  # --- SCD Type-2 (History) ---
  - name: effectiveStartDate
    type: date
    required: true
    description: "Start of validity period"
  
  - name: effectiveEndDate
    type: date
    required: false
    description: "End of validity period (null = current)"
  
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

relationships:
  - name: belongsToTree
    target: TaxonomyTree
    cardinality: many-to-one
    required: true
    inverse: taxonomyNodes
    description: The taxonomy tree this node belongs to.
  
  - name: parent
    target: JobTaxonomy
    cardinality: many-to-one
    required: false
    inverse: children
    description: Parent node in hierarchy (self-referential).
  
  - name: children
    target: JobTaxonomy
    cardinality: one-to-many
    required: false
    inverse: parent
    description: Child nodes in hierarchy.
  
  - name: ownerUnit
    target: BusinessUnit
    cardinality: many-to-one
    required: false
    description: Business Unit that owns this node (for LE/BU scope).
  
  - name: hasJobMappings
    target: JobTaxonomyMap
    cardinality: one-to-many
    required: false
    inverse: belongsToTaxonomyNode
    description: Job taxonomy mapping records for this node.
  
  - name: hasPrimaryJobs
    target: Job
    cardinality: one-to-many
    required: false
    inverse: primaryTaxonomyNode
    description: Jobs that have this as their primary taxonomy classification.
  
  - name: crossTreeMappings
    target: TaxonomyXMap
    cardinality: one-to-many
    required: false
    description: Cross-tree mappings where this node is source or target.

# === LIFECYCLE ===
lifecycle:
  states: [DRAFT, ACTIVE, INACTIVE, DEPRECATED]
  initial: DRAFT
  terminal: [DEPRECATED]
  transitions:
    - from: DRAFT
      to: ACTIVE
      trigger: activate
      guard: "Required fields populated, tree is active"
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: "No active jobs mapped"
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate
    - from: [ACTIVE, INACTIVE]
      to: DEPRECATED
      trigger: deprecate
      guard: "Replacement node identified or no dependencies"

# === POLICIES ===
policies:
  - name: uniqueCodeInTree
    type: validation
    rule: "taxonomyCode must be unique within tree+type combination"
    expression: "UNIQUE(treeId, taxonomyType, taxonomyCode)"
  
  - name: ownerUnitRequired
    type: validation
    rule: "ownerUnitId required when ownerScope is LE or BU"
    expression: "(ownerScope IN ['LE', 'BU']) IMPLIES (ownerUnitId IS NOT NULL)"
  
  - name: parentSameTree
    type: validation
    rule: "Parent node must be in same tree"
    expression: "parentId IS NULL OR parent.treeId = this.treeId"
  
  - name: hierarchyDepth
    type: business
    rule: "Recommended max hierarchy depth is 5 levels"
    expression: "depth(this) <= 5"
  
  - name: scdConsistency
    type: validation
    rule: "Only one current version per taxonomy code in tree"
    expression: "COUNT(isCurrentFlag = true) = 1 PER (treeId, taxonomyCode)"
---

# Entity: JobTaxonomy

## 1. Overview

**JobTaxonomy** is a unified, N-level, self-referential entity for classifying jobs. It consolidates concepts like Job Family, Job Family Group, Job Group, and Job Track into a flexible hierarchy within a [[TaxonomyTree]].

```mermaid
mindmap
  root((JobTaxonomy))
    Types
      FAMILY_GROUP - Highest level
      FAMILY - Functional area
      TRACK - Career path
      GROUP - Other grouping
    Hierarchy
      Self-referential parent/child
      N-level depth
      Same tree constraint
    Inheritance
      inheritFlag = true
      overrideName for local labels
      visibility control
    History
      SCD Type-2
      effectiveStartDate/EndDate
      isCurrentFlag
```

### Taxonomy Type Examples

| Type | Description | Examples |
|------|-------------|----------|
| **FAMILY_GROUP** | Highest grouping | Technology, Operations, Corporate |
| **FAMILY** | Functional area | Software Engineering, Data Science, QA |
| **TRACK** | Career progression | IC Track, Management Track, Technical Expert |
| **GROUP** | Other grouping | Revenue-generating, Support, Compliance |

---

## 2. Attributes

### Identifiers

| Attribute | Type | Req | Description | DB Column |
|-----------|------|-----|-------------|----------|
| `id` | uuid | Y | Primary key | jobpos.taxonomy_node.id |
| `treeId` | uuid | Y | FK → [[TaxonomyTree]] | jobpos.taxonomy_node.tree_id → jobpos.taxonomy_tree.id |
| `taxonomyCode` | string(50) | Y | Unique code within tree+type | jobpos.taxonomy_node.node_code |
| `taxonomyName` | string(255) | Y | Display name | jobpos.taxonomy_node.node_name |

### Classification

| Attribute | Type | Req | Values | Description | DB Column |
|-----------|------|-----|--------|-------------|----------|
| `taxonomyType` | enum | Y | FAMILY_GROUP, FAMILY, TRACK, GROUP | Node type | jobpos.taxonomy_node.node_type → common.code_list(TAX_NODE_TYPE) |
| `parentId` | uuid | N | - | FK → self for hierarchy | jobpos.taxonomy_node.parent_id → jobpos.taxonomy_node.id |

### Ownership & Inheritance

| Attribute | Type | Req | Description | DB Column |
|-----------|------|-----|-------------|----------|
| `ownerScope` | enum | Y | CORP \| LE \| BU | (jobpos.taxonomy_node.metadata.owner_scope) |
| `ownerUnitId` | uuid | N | FK → [[BusinessUnit]] | (jobpos.taxonomy_node.metadata.owner_unit_id) → org_bu.unit.id |
| `inheritFlag` | boolean | Y | true = inherit from parent tree | (jobpos.taxonomy_node.metadata.inherit_flag) |
| `overrideName` | string | N | Local name override | (jobpos.taxonomy_node.metadata.override_name) |
| `visibility` | enum | N | PUBLIC \| PRIVATE \| RESTRICTED | (jobpos.taxonomy_node.metadata.visibility) |

### Status

| Attribute | Type | Req | Description | DB Column |
|-----------|------|-----|-------------|----------|
| `isActive` | boolean | Y | Active status | (jobpos.taxonomy_node.metadata.is_active) |

### Metadata

| Attribute | Type | Req | Description | DB Column |
|-----------|------|-----|-------------|----------|
| `description` | text | N | Node description | jobpos.taxonomy_node.description |
| `metadata` | jsonb | N | Extended attributes (competencies, skills) | jobpos.taxonomy_node.metadata |

### SCD Type-2 (History)

| Attribute | Type | Req | Description | DB Column |
|-----------|------|-----|-------------|----------|
| `effectiveStartDate` | date | Y | Start of validity | jobpos.taxonomy_node.effective_start_date |
| `effectiveEndDate` | date | N | End of validity (null = current) | jobpos.taxonomy_node.effective_end_date |
| `isCurrentFlag` | boolean | Y | Current version indicator | jobpos.taxonomy_node.is_current_flag |

### Audit

| Attribute | Type | Req | Description | DB Column |
|-----------|------|-----|-------------|----------|
| `createdAt` | datetime | Y | Creation timestamp | jobpos.taxonomy_node.created_at |
| `updatedAt` | datetime | N | Last update | jobpos.taxonomy_node.updated_at |

---

## 3. Relationships

```mermaid
erDiagram
    TaxonomyTree ||--o{ JobTaxonomy : "contains"
    JobTaxonomy ||--o{ JobTaxonomy : "parent/child"
    JobTaxonomy }o--o{ Job : "mapped via JobTaxonomyMap"
    JobTaxonomy }o--o| BusinessUnit : "owned by"
    JobTaxonomy ||--o{ TaxonomyXMap : "cross-tree mapping"
    
    JobTaxonomy {
        uuid id PK
        uuid treeId FK
        string taxonomyCode
        string taxonomyName
        enum taxonomyType
        uuid parentId FK
        enum ownerScope
        boolean inheritFlag
        boolean isActive
    }
    
    TaxonomyTree {
        uuid id PK
        string treeCode
    }
    
    Job {
        uuid id PK
        string jobCode
    }
    
    TaxonomyXMap {
        uuid id PK
        uuid srcNodeId FK
        uuid targetNodeId FK
    }
```

### Relationship Details

| Relationship | Target | Cardinality | Description |
|--------------|--------|-------------|-------------|
| `belongsToTree` | [[TaxonomyTree]] | N:1 | Parent tree |
| `parent` | self | N:1 | Parent node in hierarchy |
| `children` | self | 1:N | Child nodes |
| `ownerUnit` | [[BusinessUnit]] | N:1 | Owner for LE/BU scope |
| `mappedJobs` | [[Job]] | N:M | Jobs via JobTaxonomyMap |
| `crossTreeMappings` | [[TaxonomyXMap]] | 1:N | Cross-tree links |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> DRAFT : create
    
    DRAFT --> ACTIVE : activate
    ACTIVE --> INACTIVE : deactivate
    INACTIVE --> ACTIVE : reactivate
    ACTIVE --> DEPRECATED : deprecate
    INACTIVE --> DEPRECATED : deprecate
    
    DEPRECATED --> [*]
    
    note right of ACTIVE
        Guard: No active jobs mapped
        before deactivate/deprecate
    end note
```

### State Definitions

| State | Description |
|-------|-------------|
| `DRAFT` | Node created but not yet available for use |
| `ACTIVE` | Available for job mapping and reporting |
| `INACTIVE` | Temporarily disabled (no new mappings) |
| `DEPRECATED` | Permanently retired, read-only |

---

## 5. Business Rules Reference

| Rule | Type | Description |
|------|------|-------------|
| BR-JT-001 | Validation | taxonomyCode unique within tree+type |
| BR-JT-002 | Validation | ownerUnitId required for LE/BU scope |
| BR-JT-003 | Validation | Parent must be in same tree |
| BR-JT-004 | Business | Max recommended depth = 5 levels |
| BR-JT-005 | Validation | Only one current version (isCurrentFlag) per code |

### Inheritance Pattern

| inheritFlag | overrideName | Behavior |
|-------------|--------------|----------|
| `true` | `null` | Full inheritance from parent tree |
| `true` | `"Local Name"` | Inherit structure, override name |
| `false` | `"Custom"` | Complete override (no inheritance) |

### Example Hierarchy

```
CORP_TREE
├── Technology (FAMILY_GROUP)
│   ├── Software Engineering (FAMILY)
│   │   ├── Backend Development (FAMILY)
│   │   └── Frontend Development (FAMILY)
│   ├── Data Science (FAMILY)
│   └── DevOps (FAMILY)
├── IC Track (TRACK)
│   ├── Junior
│   ├── Mid-level
│   └── Senior
└── Management Track (TRACK)
    ├── Team Lead
    ├── Manager
    └── Director
```

---

*References*: [[TaxonomyTree]], [[Job]], [[TaxonomyXMap]], [[BusinessUnit]]
