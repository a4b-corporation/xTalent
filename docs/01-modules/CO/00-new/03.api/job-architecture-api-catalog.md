# Job Architecture API Catalog

> **Module**: Core HR - Job & Position Management  
> **Version**: 1.0.0  
> **Status**: Draft  
> **Last Updated**: 2026-01-29  
> **Reference**: Oracle HCM, SAP SuccessFactors, Workday patterns

---

## Overview

This document catalogs all necessary APIs for the **Job Architecture** entities. It follows **RESTful** conventions with dedicated **action endpoints** for business operations.

### Entities Covered

| Entity | Description | Files |
|--------|-------------|-------|
| **Job** | Role template with classification | job.onto.md |
| **JobProfile** | Localized job content (descriptions, skills) | job-profile.onto.md |
| **JobLevel** | Seniority level (Junior, Senior, Lead) | job-level.onto.md |
| **JobTaxonomy** | Classification node (Family, Track, Group) | JobTaxonomy.onto.md |
| **TaxonomyTree** | Taxonomy container (multi-scope) | TaxonomyTree.onto.md |
| **JobTaxonomyMap** | Job-to-Taxonomy junction | JobTaxonomyMap.onto.md |
| **TaxonomyXMap** | Cross-tree mapping | TaxonomyXMap.onto.md |
| **JobProfileSkill** | Profile-to-Skill requirements | job-profile-skill.link.md |

### API Design Patterns

| Pattern | Format | Example |
|---------|--------|---------|
| **CRUD** | `METHOD /entities/{id}` | `GET /jobs/123` |
| **Action** | `POST /entities/{id}/actions/{name}` | `POST /jobs/123/actions/activate` |
| **Query** | `GET /entities/query/{name}` | `GET /jobs/query/by-taxonomy/456` |
| **Batch** | `POST /entities/batch` | Bulk operations |
| **Tree** | `GET /entities/{id}/children` | Hierarchical navigation |

---

## 1. Job APIs

> **Entity**: `Job`  
> **Domain**: Role Template  
> **Base Path**: `/api/v1/jobs`

### 1.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/jobs` | Create new job | HR Admin |
| `GET` | `/jobs/{id}` | Get job by ID | Read |
| `GET` | `/jobs` | List jobs (paginated) | Read |
| `PATCH` | `/jobs/{id}` | Update job | HR Admin |
| `DELETE` | `/jobs/{id}` | Soft delete job | HR Admin |

### 1.2 Business Actions - Lifecycle

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/jobs/{id}/actions/activate` | Activate draft job | Admin |
| `POST` | `/jobs/{id}/actions/inactivate` | Inactivate job | Admin |
| `POST` | `/jobs/{id}/actions/archive` | Archive job permanently | Admin |
| `POST` | `/jobs/{id}/actions/validate` | Validate job completeness | Pre-activation |

### 1.3 Business Actions - Versioning

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/jobs/{id}/actions/clone` | Clone job with new code | Admin |
| `POST` | `/jobs/{id}/actions/createVersion` | Create SCD Type-2 version | Major update |
| `POST` | `/jobs/{id}/actions/deprecate` | Mark as deprecated | Lifecycle |

### 1.4 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/jobs/search` | Full-text search | `q`, `fields[]` |
| `GET` | `/jobs/{id}/positions` | Get positions for this job | - |
| `GET` | `/jobs/{id}/profiles` | Get profiles (all locales) | `locale` |
| `GET` | `/jobs/{id}/history` | Get version history | - |
| `GET` | `/jobs/query/by-taxonomy/{nodeId}` | Jobs in taxonomy node | `includeChildren` |
| `GET` | `/jobs/query/by-level/{levelId}` | Jobs at specific level | - |
| `GET` | `/jobs/query/benchmarks` | Get benchmark jobs only | - |

---

## 2. JobProfile APIs

> **Entity**: `JobProfile`  
> **Domain**: Localized Job Content  
> **Base Path**: `/api/v1/job-profiles`

### 2.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/job-profiles` | Create job profile | HR Admin |
| `GET` | `/job-profiles/{id}` | Get by ID | Read |
| `GET` | `/job-profiles` | List (paginated) | Read |
| `PATCH` | `/job-profiles/{id}` | Update | HR Admin |
| `DELETE` | `/job-profiles/{id}` | Soft delete | HR Admin |

### 2.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/job-profiles/{id}/actions/publish` | Publish draft profile | Admin |
| `POST` | `/job-profiles/{id}/actions/archive` | Archive profile | Admin |
| `POST` | `/job-profiles/{id}/actions/clone` | Clone to new locale | Localization |
| `POST` | `/job-profiles/{id}/actions/createVersion` | Create SCD Type-2 version | Major update |
| `POST` | `/job-profiles/{id}/actions/translateTo` | Auto-translate to locale | AI Translation |

### 2.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/job-profiles/query/by-job/{jobId}` | Profiles for a job | `locale` |
| `GET` | `/job-profiles/query/by-locale/{locale}` | Profiles by locale | - |
| `GET` | `/job-profiles/{id}/skills` | Get skill requirements | `importance` |

---

## 3. JobLevel APIs

> **Entity**: `JobLevel`  
> **Domain**: Seniority Hierarchy  
> **Base Path**: `/api/v1/job-levels`

### 3.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/job-levels` | Create job level | HR Admin |
| `GET` | `/job-levels/{id}` | Get by ID | Read |
| `GET` | `/job-levels` | List (sorted by rank) | Read |
| `PATCH` | `/job-levels/{id}` | Update | HR Admin |
| `DELETE` | `/job-levels/{id}` | Soft delete | HR Admin |

### 3.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/job-levels/{id}/actions/activate` | Activate level | Admin |
| `POST` | `/job-levels/{id}/actions/deactivate` | Deactivate level | Admin |
| `POST` | `/job-levels/actions/reorder` | Reorder multiple levels | Admin |

### 3.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/job-levels/query/by-scope/{scope}` | Get by scope (CORP/LE/BU) | `ownerUnitId` |
| `GET` | `/job-levels/{id}/positions` | Positions at this level | - |

---

## 4. JobTaxonomy APIs

> **Entity**: `JobTaxonomy`  
> **Domain**: Classification Hierarchy  
> **Base Path**: `/api/v1/job-taxonomies`

### 4.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/job-taxonomies` | Create taxonomy node | HR Admin |
| `GET` | `/job-taxonomies/{id}` | Get by ID | Read |
| `GET` | `/job-taxonomies` | List (paginated) | Read |
| `PATCH` | `/job-taxonomies/{id}` | Update | HR Admin |
| `DELETE` | `/job-taxonomies/{id}` | Soft delete | HR Admin |

### 4.2 Business Actions - Lifecycle

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/job-taxonomies/{id}/actions/activate` | Activate node | Admin |
| `POST` | `/job-taxonomies/{id}/actions/inactivate` | Inactivate node | Admin |
| `POST` | `/job-taxonomies/{id}/actions/deprecate` | Deprecate node | Replacement |

### 4.3 Business Actions - Hierarchy Management

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/job-taxonomies/{id}/actions/moveToParent` | Reparent node | Reorganization |
| `POST` | `/job-taxonomies/{id}/actions/merge` | Merge into another node | Consolidation |
| `POST` | `/job-taxonomies/{id}/actions/split` | Split into child nodes | Reorganization |

### 4.4 Business Actions - Job Mapping

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/job-taxonomies/{id}/actions/mapJob` | Add job to node | Admin |
| `POST` | `/job-taxonomies/{id}/actions/unmapJob` | Remove job from node | Admin |
| `POST` | `/job-taxonomies/{id}/actions/setPrimaryJob` | Set primary job mapping | Admin |

### 4.5 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/job-taxonomies/{id}/children` | Get child nodes | `recursive` |
| `GET` | `/job-taxonomies/{id}/ancestors` | Get ancestor path to root | - |
| `GET` | `/job-taxonomies/{id}/descendants` | Get all descendants | `maxDepth` |
| `GET` | `/job-taxonomies/{id}/jobs` | Get mapped jobs | `isPrimary` |
| `GET` | `/job-taxonomies/tree/{treeId}` | Get full tree structure | `depth` |
| `GET` | `/job-taxonomies/query/by-type/{type}` | Get by type (FAMILY, TRACK) | `treeId` |

---

## 5. TaxonomyTree APIs

> **Entity**: `TaxonomyTree`  
> **Domain**: Classification Container  
> **Base Path**: `/api/v1/taxonomy-trees`

### 5.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/taxonomy-trees` | Create tree | HR Admin |
| `GET` | `/taxonomy-trees/{id}` | Get by ID | Read |
| `GET` | `/taxonomy-trees` | List (paginated) | Read |
| `PATCH` | `/taxonomy-trees/{id}` | Update | HR Admin |
| `DELETE` | `/taxonomy-trees/{id}` | Soft delete | HR Admin |

### 5.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/taxonomy-trees/{id}/actions/activate` | Activate tree | Admin |
| `POST` | `/taxonomy-trees/{id}/actions/deactivate` | Deactivate tree | Admin |
| `POST` | `/taxonomy-trees/{id}/actions/archive` | Archive tree | Admin |
| `POST` | `/taxonomy-trees/{id}/actions/clone` | Clone tree to new owner | BU Setup |
| `POST` | `/taxonomy-trees/{id}/actions/export` | Export tree structure (JSON) | Integration |
| `POST` | `/taxonomy-trees/{id}/actions/import` | Import tree structure | Integration |

### 5.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/taxonomy-trees/{id}/nodes` | Get all nodes in tree | `type` |
| `GET` | `/taxonomy-trees/{id}/structure` | Get hierarchical structure | `depth` |
| `GET` | `/taxonomy-trees/query/by-scope/{scope}` | Get trees by scope | `ownerUnitId` |
| `GET` | `/taxonomy-trees/query/effective` | Get effective tree for context | `scope`, `unitId` |

---

## 6. JobTaxonomyMap APIs

> **Entity**: `JobTaxonomyMap`  
> **Domain**: Job-Taxonomy Junction  
> **Base Path**: `/api/v1/job-taxonomy-maps`

### 6.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/job-taxonomy-maps` | Create mapping | HR Admin |
| `GET` | `/job-taxonomy-maps/{id}` | Get by ID | Read |
| `GET` | `/job-taxonomy-maps` | List (paginated) | Read |
| `PATCH` | `/job-taxonomy-maps/{id}` | Update | HR Admin |
| `DELETE` | `/job-taxonomy-maps/{id}` | Soft delete | HR Admin |

### 6.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/job-taxonomy-maps/{id}/actions/setPrimary` | Set as primary mapping | Admin |
| `POST` | `/job-taxonomy-maps/{id}/actions/end` | End mapping (set endDate) | Admin |
| `POST` | `/job-taxonomy-maps/{id}/actions/extend` | Extend ended mapping | Admin |
| `POST` | `/job-taxonomy-maps/batch` | Batch create/update mappings | Admin |

### 6.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/job-taxonomy-maps/query/by-job/{jobId}` | Mappings for a job | `type`, `isCurrent` |
| `GET` | `/job-taxonomy-maps/query/by-node/{nodeId}` | Mappings for a node | `isCurrent` |

---

## 7. TaxonomyXMap APIs

> **Entity**: `TaxonomyXMap`  
> **Domain**: Cross-Tree Mapping  
> **Base Path**: `/api/v1/taxonomy-x-maps`

### 7.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/taxonomy-x-maps` | Create cross-tree mapping | HR Admin |
| `GET` | `/taxonomy-x-maps/{id}` | Get by ID | Read |
| `GET` | `/taxonomy-x-maps` | List (paginated) | Read |
| `PATCH` | `/taxonomy-x-maps/{id}` | Update | HR Admin |
| `DELETE` | `/taxonomy-x-maps/{id}` | Soft delete | HR Admin |

### 7.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/taxonomy-x-maps/{id}/actions/activate` | Activate mapping | Admin |
| `POST` | `/taxonomy-x-maps/{id}/actions/deactivate` | Deactivate mapping | Admin |

### 7.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/taxonomy-x-maps/query/by-source/{nodeId}` | Mappings from source node | `mapType` |
| `GET` | `/taxonomy-x-maps/query/by-target/{nodeId}` | Mappings to target node | `mapType` |
| `GET` | `/taxonomy-x-maps/query/rollup/{nodeId}` | Get rollup path to CORP | - |

---

## 8. JobProfileSkill APIs

> **Entity**: `JobProfileSkill`  
> **Domain**: Profile-Skill Requirements  
> **Base Path**: `/api/v1/job-profile-skills`

### 8.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/job-profile-skills` | Create skill requirement | HR Admin |
| `GET` | `/job-profile-skills/{id}` | Get by ID | Read |
| `GET` | `/job-profile-skills` | List (paginated) | Read |
| `PATCH` | `/job-profile-skills/{id}` | Update | HR Admin |
| `DELETE` | `/job-profile-skills/{id}` | Remove requirement | HR Admin |

### 8.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/job-profile-skills/{id}/actions/remove` | Remove (soft delete) | Admin |
| `POST` | `/job-profile-skills/{id}/actions/restore` | Restore removed | Admin |
| `POST` | `/job-profile-skills/batch` | Batch add/update skills | Admin |

### 8.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/job-profile-skills/query/by-profile/{profileId}` | Skills for profile | `importance` |
| `GET` | `/job-profile-skills/query/by-skill/{skillId}` | Profiles needing skill | - |
| `GET` | `/job-profile-skills/query/must-haves/{profileId}` | Must-have skills only | - |

---

## Summary

### API Count by Entity

| Entity | CRUD | Actions | Query | Total |
|--------|------|---------|-------|-------|
| Job | 5 | 7 | 7 | **19** |
| JobProfile | 5 | 5 | 3 | **13** |
| JobLevel | 5 | 3 | 2 | **10** |
| JobTaxonomy | 5 | 9 | 6 | **20** |
| TaxonomyTree | 5 | 6 | 4 | **15** |
| JobTaxonomyMap | 5 | 4 | 2 | **11** |
| TaxonomyXMap | 5 | 2 | 3 | **10** |
| JobProfileSkill | 5 | 3 | 3 | **11** |
| **Total** | **40** | **39** | **30** | **109** |

### Priority Matrix

| Priority | APIs | Description |
|----------|------|-------------|
| **P0** | 40 | CRUD - MVP |
| **P1** | 20 | Core Lifecycle (activate, inactivate, archive) |
| **P2** | 10 | Taxonomy Operations (move, merge, split) |
| **P3** | 9 | Versioning (clone, createVersion) |
| **P4** | 30 | Query & Navigation |

### Key Use Cases

| Use Case | APIs Involved |
|----------|---------------|
| **Create New Job** | POST /jobs → POST /job-profiles → POST /job-profile-skills |
| **Classify Job** | POST /job-taxonomy-maps |
| **Setup BU Taxonomy** | POST /taxonomy-trees/clone → POST /job-taxonomies |
| **Skill Matching** | GET /job-profile-skills/query/must-haves |
| **Reporting Rollup** | GET /taxonomy-x-maps/query/rollup |

---

## Next Steps

1. Create individual `*.api.md` files for each entity
2. Define request/response schemas (OpenAPI)
3. Document error scenarios
4. Define authorization rules per endpoint
5. Create OpenAPI/Swagger specification

---

*Document Status: DRAFT*  
*References: [[Job]], [[JobProfile]], [[JobLevel]], [[JobTaxonomy]], [[TaxonomyTree]], [[JobTaxonomyMap]], [[TaxonomyXMap]], [[JobProfileSkill]]*
