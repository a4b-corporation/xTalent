---
entity: JobTaxonomyMap
domain: job-position
version: "1.0.0"
status: approved
owner: Core HR Team
tags: [job-taxonomy, job-mapping, many-to-many]

# === ATTRIBUTES ===
attributes:
  # --- Composite Key ---
  - name: jobId
    type: string
    required: true
    description: "FK → Job.id - the job being mapped"
  
  - name: taxonomyId
    type: string
    required: true
    description: "FK → JobTaxonomy.id - the taxonomy node"
  
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

relationships:
  - name: belongsToJob
    target: Job
    cardinality: many-to-one
    required: true
    inverse: hasTaxonomyMappings
    description: The job being classified. INVERSE - Job.hasTaxonomyMappings.
  
  - name: belongsToTaxonomyNode
    target: JobTaxonomy
    cardinality: many-to-one
    required: true
    inverse: hasJobMappings
    description: The taxonomy node this job belongs to. INVERSE - JobTaxonomy.hasJobMappings.

# === LIFECYCLE ===
lifecycle:
  states: [ACTIVE, INACTIVE]
  initial: ACTIVE
  terminal: []
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: end
    - from: INACTIVE
      to: ACTIVE
      trigger: extend

# === POLICIES ===
policies:
  - name: compositeKey
    type: validation
    rule: "Primary key is (jobId, taxonomyId, effectiveStartDate)"
    expression: "UNIQUE(jobId, taxonomyId, effectiveStartDate)"
  
  - name: oneCurrentPerJobTaxonomy
    type: validation
    rule: "Only one current mapping per job-taxonomy pair"
    expression: "COUNT(isCurrentFlag = true) = 1 PER (jobId, taxonomyId)"
---

# Entity: JobTaxonomyMap

## 1. Overview

**JobTaxonomyMap** is a junction entity that enables many-to-many mapping between [[Job]]s and [[JobTaxonomy]] nodes. A single job can belong to multiple taxonomy classifications (e.g., both a FAMILY and a TRACK).

```mermaid
mindmap
  root((JobTaxonomyMap))
    Purpose
      Many-to-many mapping
      Job ↔ Taxonomy
    Key Features
      Multi-classification
      SCD Type-2 history
      Effective dating
    Use Cases
      Job in multiple families
      Job on career track
      Historical tracking
```

### Key Behaviors

| Behavior | Description |
|----------|-------------|
| **Multi-classification** | One job can map to multiple taxonomy nodes |
| **Historical** | SCD Type-2 tracks mapping changes over time |
| **Tree-agnostic** | Job can map to nodes in different trees |

---

## 2. Attributes

### Primary Key (Composite)

| Attribute | Type | Req | Description |
|-----------|------|-----|-------------|
| `jobId` | uuid | Y | FK → [[Job]] |
| `taxonomyId` | uuid | Y | FK → [[JobTaxonomy]] |
| `effectiveStartDate` | date | Y | Start of mapping |

### SCD Type-2

| Attribute | Type | Req | Description |
|-----------|------|-----|-------------|
| `effectiveEndDate` | date | N | End of mapping (null = current) |
| `isCurrentFlag` | boolean | Y | Current version indicator |

---

## 3. Relationships

```mermaid
erDiagram
    Job ||--o{ JobTaxonomyMap : "classified by"
    JobTaxonomy ||--o{ JobTaxonomyMap : "classifies"
    
    JobTaxonomyMap {
        uuid jobId PK,FK
        uuid taxonomyId PK,FK
        date effectiveStartDate PK
        date effectiveEndDate
        boolean isCurrentFlag
    }
    
    Job {
        uuid id PK
        string jobCode
        string jobTitle
    }
    
    JobTaxonomy {
        uuid id PK
        string taxonomyCode
        enum taxonomyType
    }
```

### Relationship Details

| Relationship | Target | Cardinality | Description |
|--------------|--------|-------------|-------------|
| `job` | [[Job]] | N:1 | The job being classified |
| `taxonomyNode` | [[JobTaxonomy]] | N:1 | The taxonomy classification |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> ACTIVE : create
    
    ACTIVE --> INACTIVE : end (set effectiveEndDate)
    INACTIVE --> ACTIVE : extend (new record)
```

### State Definitions

| State | Description |
|-------|-------------|
| `ACTIVE` | Mapping is current (isCurrentFlag = true) |
| `INACTIVE` | Mapping ended (effectiveEndDate set) |

---

## 5. Business Rules Reference

| Rule | Type | Description |
|------|------|-------------|
| BR-JTM-001 | Validation | Composite PK: (jobId, taxonomyId, effectiveStartDate) |
| BR-JTM-002 | Validation | Only one current mapping per job-taxonomy pair |

### Example: Multi-Classification

```
Job: "Senior Software Engineer" (JOB-001)
├── Maps to: "Software Engineering" (FAMILY)
├── Maps to: "IC Track - Senior" (TRACK)
└── Maps to: "Technology" (FAMILY_GROUP)

All mappings are valid simultaneously, enabling:
- Family-based reporting
- Career track progression
- High-level grouping
```

---

*References*: [[Job]], [[JobTaxonomy]], [[TaxonomyTree]]
