---
entity: JobTaxonomy
version: "2.0.0"
status: approved
created: 2026-01-26
supersedes: job-family-schema-standards.md
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
  - xtalent-dbml-v4
module: Core HR
---

# Schema Standards: Job Taxonomy

## 1. Summary

The **Job Taxonomy** is a unified, multi-level, multi-scope classification system for organizing jobs within an organization. It consolidates concepts like Job Family, Job Family Group, Job Group, and Job Track into a flexible, self-referential hierarchy.

**Key Concepts**:
- **TaxonomyTree**: Registry of independent taxonomy trees (Corp, LE, or BU-owned)
- **JobTaxonomy**: N-level nodes within a tree (FAMILY_GROUP, FAMILY, TRACK, GROUP, etc.)
- **TaxonomyXMap**: Cross-tree mappings for reporting consolidation
- **JobTaxonomyMap**: Many-to-many mapping of Jobs to Taxonomy nodes

**Replaces**: Simple 2-level JobFamilyGroup → JobFamily design

**Confidence**: HIGH - Based on 3 major HCM vendors + xTalent DBML v4

---

## 2. Vendor Comparison Matrix

### 2.1 Workday

**Hierarchy**: Job Family Group → Job Family → Job Profile

| Level | Entity | Description |
|-------|--------|-------------|
| 1 | Job Family Group | Broad categorization (e.g., "Technology") |
| 2 | Job Family | Similar work types (e.g., "Software Development") |
| 3 | Job Profile | Classification summary with grade, exempt status |

**Key Features**:
- Fixed 3-level hierarchy
- Job Profile contains compensation grade
- Supports staffing models: Position Management or Job Management

### 2.2 Oracle HCM Cloud

**Hierarchy**: Job Family → Job → Position

| Level | Entity | Description |
|-------|--------|-------------|
| 1 | Job Family | Grouping by function (e.g., "Finance") |
| 2 | Job | Generic title with salary grades |
| 3 | Position | Specific role in department |

**Key Features**:
- **Progression Jobs**: Career ladder feature (Junior → Senior → Lead)
- Position Hierarchy for reporting structure
- Flexible attributes via descriptive flexfields

### 2.3 SAP SuccessFactors

**Hierarchy**: Job Family → Job Role → Job Code

| Level | Entity | Description |
|-------|--------|-------------|
| 1 | Job Family | Broad categories (e.g., "Human Resources") |
| 2 | Job Role | Specific job types with competencies |
| 3 | Job Code (JOBCLASSIFICATION) | Identifier for assignments |

**Key Features**:
- Job Profile Builder (JPB) for modern management
- Competency/skill associations at Job Role level
- Integration with performance and succession modules

---

## 3. Canonical Schema

### 3.1 TaxonomyTree (Registry)

Allows multiple independent taxonomy trees per organization scope.

| Attribute | Type | Required | Description | Source |
|-----------|------|----------|-------------|--------|
| id | uuid | Y | Primary key | Universal |
| treeCode | string(50) | Y | Unique code (e.g., "CORP_TREE", "BU_G01") | xTalent |
| treeName | string(255) | Y | Display name | Universal |
| ownerScope | enum | Y | CORP \| LE \| BU | xTalent |
| ownerUnitId | uuid | N | Reference to Business Unit (for LE/BU scope) | xTalent |
| description | text | N | Tree description | Universal |
| createdAt | timestamp | Y | Creation timestamp | Universal |
| updatedAt | timestamp | N | Last update | Universal |

**Usage Patterns**:
- `CORP` scope: Corporate-level tree (shared across all entities)
- `LE` scope: Legal Entity-specific tree (overrides Corp)
- `BU` scope: Business Unit-specific tree (can clone from Corp/LE)

### 3.2 JobTaxonomy (Node)

Self-referential hierarchy for N-level classification.

#### 3.2.1 Required Attributes

| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Primary key | Universal |
| treeId | uuid | FK → TaxonomyTree | xTalent |
| taxonomyCode | string(50) | Unique code within tree+type | Universal |
| taxonomyName | string(255) | Display name | Universal |
| taxonomyType | enum | FAMILY_GROUP \| FAMILY \| TRACK \| GROUP | xTalent |
| parentId | uuid | FK → self (hierarchy) | Universal |
| isActive | boolean | Active status | Universal |

#### 3.2.2 Inheritance & Override Attributes

| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| ownerScope | enum | CORP \| LE \| BU | xTalent |
| ownerUnitId | uuid | Business Unit owner | xTalent |
| inheritFlag | boolean | true = inherit from parent tree | xTalent |
| overrideName | string(255) | Local name override | xTalent |
| visibility | enum | PUBLIC \| PRIVATE \| RESTRICTED | xTalent |

#### 3.2.3 SCD Type-2 Attributes (History Tracking)

| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| effectiveStartDate | date | Start of validity | Best Practice |
| effectiveEndDate | date | End of validity (null = current) | Best Practice |
| isCurrentFlag | boolean | Current version indicator | Best Practice |

#### 3.2.4 Optional Attributes

| Attribute | Type | When to Include |
|-----------|------|-----------------|
| description | text | Summary of taxonomy node |
| metadata | jsonb | Extended attributes (competencies, skills) |

### 3.3 TaxonomyXMap (Cross-Tree Mapping)

Links nodes between different trees for reporting consolidation.

| Attribute | Type | Required | Description | Source |
|-----------|------|----------|-------------|--------|
| id | uuid | Y | Primary key | xTalent |
| srcNodeId | uuid | Y | FK → JobTaxonomy (BU tree node) | xTalent |
| targetNodeId | uuid | Y | FK → JobTaxonomy (Corp tree node) | xTalent |
| mapTypeCode | enum | Y | REPORT_TO \| ALIGN_WITH \| DUPLICATE_OF | xTalent |
| comment | text | N | Mapping rationale | xTalent |
| effectiveStartDate | date | Y | Start of mapping | xTalent |
| effectiveEndDate | date | N | End of mapping | xTalent |
| isCurrentFlag | boolean | Y | Current version | xTalent |

**Map Types**:
- `REPORT_TO`: BU node reports to Corp node for analytics
- `ALIGN_WITH`: BU node aligns semantically with Corp node
- `DUPLICATE_OF`: BU node is copy of Corp node (full inheritance)

### 3.4 JobTaxonomyMap (Job-to-Taxonomy)

Many-to-many mapping between Jobs and Taxonomy nodes.

| Attribute | Type | Required | Description | Source |
|-----------|------|----------|-------------|--------|
| jobId | uuid | Y | FK → Job | Universal |
| taxonomyId | uuid | Y | FK → JobTaxonomy | Universal |
| effectiveStartDate | date | Y | Start of mapping | Best Practice |
| effectiveEndDate | date | N | End of mapping | Best Practice |
| isCurrentFlag | boolean | Y | Current version | Best Practice |

**Key Behavior**: A Job can belong to multiple taxonomy nodes (e.g., both a FAMILY and a TRACK).

---

## 4. Taxonomy Types

| Type | Purpose | Examples |
|------|---------|----------|
| FAMILY_GROUP | Highest grouping level | Technology, Operations, Corporate |
| FAMILY | Functional grouping | Software Engineering, Data Science, DevOps |
| TRACK | Career progression path | Individual Contributor, Management, Technical Expert |
| GROUP | Other logical grouping | Revenue-generating, Support, Compliance |

**Note**: Types are extensible via `code_list(TAXONOMY_TYPE)`.

---

## 5. Key Relationships

```
TaxonomyTree 1───N JobTaxonomy
JobTaxonomy  N───1 JobTaxonomy (parent/child hierarchy)
JobTaxonomy  N───M Job (via JobTaxonomyMap)
JobTaxonomy  N───M JobTaxonomy (via TaxonomyXMap for cross-tree)
```

---

## 6. Inheritance & Override Rules

### 6.1 Scope Priority (Most Specific Wins)

1. **BU-specific** (ownerScope = BU, ownerUnitId = matching BU)
2. **LE-specific** (ownerScope = LE, ownerUnitId = matching LE)
3. **Corp-level** (ownerScope = CORP, ownerUnitId = null)

### 6.2 Inheritance Behavior

| inheritFlag | overrideName | Behavior |
|-------------|--------------|----------|
| true | null | Full inheritance from parent tree node |
| true | "Local Name" | Inherit structure, override display name |
| false | "Custom Name" | Complete override (no inheritance) |

### 6.3 Clone Tree Pattern

When a BU needs a custom taxonomy:
1. Create new TaxonomyTree (ownerScope = BU)
2. Clone nodes with inheritFlag = true
3. Add/modify nodes as needed
4. Create TaxonomyXMap to Corp tree for reporting

---

## 7. Multi-Scope Usage Patterns

### 7.1 Corporate-Only (Simple)

```
CORP_TREE
├── Technology (FAMILY_GROUP)
│   ├── Software Engineering (FAMILY)
│   └── Data Science (FAMILY)
└── Operations (FAMILY_GROUP)
    └── HR Operations (FAMILY)
```

### 7.2 Multi-Scope (Advanced)

```
CORP_TREE (Corporate standard)
├── Technology
│   ├── Software Engineering
│   └── Data Science

BU_GAME_TREE (Game BU customization)
├── Technology [inherits from CORP_TREE.Technology]
│   ├── Software Engineering [inherits]
│   ├── Game Development [BU-specific addition]
│   └── Game Art [BU-specific addition]

TaxonomyXMap:
- BU_GAME_TREE.Game Development → REPORT_TO → CORP_TREE.Technology
- BU_GAME_TREE.Game Art → REPORT_TO → CORP_TREE.Technology
```

---

## 8. Comparison with Previous Design

| Aspect | Old (job-family) | New (job-taxonomy) |
|--------|------------------|-------------------|
| Hierarchy Levels | Fixed 2-level | N-level (unlimited) |
| Multi-scope | No | Yes (CORP/LE/BU) |
| Inheritance | No | Yes (inherit/override) |
| Cross-tree Mapping | No | Yes (TaxonomyXMap) |
| Job Mapping | 1:1 | N:M (via JobTaxonomyMap) |
| History Tracking | No | Yes (SCD Type-2) |

---

## 9. Migration Notes

### From job-family-schema-standards.md v1.0.0

| Old Entity | New Entity | Notes |
|------------|------------|-------|
| JobFamilyGroup | JobTaxonomy (type=FAMILY_GROUP) | Add to CORP_TREE |
| JobFamily | JobTaxonomy (type=FAMILY) | Set parentId to FAMILY_GROUP |
| JobFamily.jobs | JobTaxonomyMap | Create mapping records |

---

*Document Status: APPROVED*
*Supersedes: job-family-schema-standards.md v1.0.0*
