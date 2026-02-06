# Job Taxonomy Data Specification

**Version**: 1.0  
**Last Updated**: 2025-12-23  
**Status**: Draft

---

## Overview

This document provides data specifications for the Job Taxonomy system in xTalent Core Module.

**Implementation Approaches**:
- **Simplified Design (Recommended)**: 3-entity structure (JobTaxonomy, Job, JobProfile)
- **Advanced Design (Optional)**: Multi-tree architecture (see Advanced Features section)

For detailed entity definitions, see:
- [Core Ontology YAML](../00-ontology/core-ontology.yaml) - Complete entity specifications
- [Job & Position Glossary](../00-ontology/glossary-job-position.md) - Field descriptions and examples

---

## JobTaxonomy Specification

### Field Specifications

| Field | Type | Required | Validation | Example |
|-------|------|----------|------------|---------|
| `code` | string(50) | Yes | Unique, alphanumeric, uppercase | `ENG`, `SW_ENG`, `BACKEND`, `MICROSERVICES` |
| `name` | string(150) | Yes | 1-150 characters | `Engineering`, `Backend Development` |
| `taxonomy_type` | enum | Yes | TRACK \| FAMILY \| GROUP \| SUBGROUP | `TRACK` |
| `parent_id` | UUID | Conditional | Required for FAMILY/GROUP/SUBGROUP | `<parent_uuid>` |
| `level` | integer | Yes | 1, 2, 3, or 4 | `1` |
| `path` | string(500) | No | Format: `/PARENT/CHILD` | `/ENG/SW_ENG/BACKEND` |
| `sort_order` | integer | No | Positive integer | `1` |
| `is_active` | boolean | Yes | true \| false | `true` |

### Business Rules

**BR-TAX-001**: Code Uniqueness
- Taxonomy code must be unique across the organization
- Format: Uppercase alphanumeric with underscores
- Example: `ENG`, `SW_ENG`, `BACKEND`

**BR-TAX-002**: Taxonomy Type-Level Consistency
- `taxonomy_type = TRACK` must have `level = 1`
- `taxonomy_type = FAMILY` must have `level = 2`
- `taxonomy_type = GROUP` must have `level = 3`
- `taxonomy_type = SUBGROUP` must have `level = 4`

**BR-TAX-003**: Parent Requirements
- TRACK nodes: `parent_id` must be NULL
- FAMILY nodes: `parent_id` must reference a TRACK node
- GROUP nodes: `parent_id` must reference a FAMILY node
- SUBGROUP nodes: `parent_id` must reference a GROUP node

**BR-TAX-004**: Path Consistency
- Path must reflect actual hierarchy
- Format: `/FAMILY/SUBFAMILY/FUNCTION`
- Example: `/ENG/SW_ENG/BACKEND`

**BR-TAX-005**: Maximum Depth
- Recommended maximum 4 levels
- Level 1 (TRACK) → Level 2 (FAMILY) → Level 3 (GROUP) → Level 4 (SUBGROUP)

---

## Job Specification

### Field Specifications

| Field | Type | Required | Validation | Example |
|-------|------|----------|------------|---------|
| `code` | string(50) | Yes | Unique, alphanumeric | `SR_BACKEND_ENG` |
| `title` | string(200) | Yes | 1-200 characters | `Senior Backend Engineer` |
| `taxonomy_id` | UUID | No | Must reference FUNCTION level | `<taxonomy_uuid>` |
| `parent_job_id` | UUID | No | Must reference valid job | `<parent_job_uuid>` |
| `tree_id` | UUID | No | [FUTURE-READY] Reserved for job_tree support | NULL (current) |
| `level_id` | UUID | No | Valid job level | `<level_uuid>` |
| `grade_id` | UUID | No | Valid job grade | `<grade_uuid>` |
| `job_type_code` | enum | No | INDIVIDUAL_CONTRIBUTOR \| MANAGER \| EXECUTIVE | `INDIVIDUAL_CONTRIBUTOR` |
| `is_manager` | boolean | No | true \| false | `false` |

### Business Rules

**BR-JOB-001**: Code Uniqueness
- Job code must be unique across the organization
- Format: Uppercase alphanumeric with underscores

**BR-JOB-002**: Taxonomy Classification
- Jobs should link to GROUP or SUBGROUP level (Level 3 or 4) for most specific classification
- If `taxonomy_id` is provided, must reference a taxonomy node with `taxonomy_type` = GROUP or SUBGROUP

**BR-JOB-003**: Job Hierarchy
- Jobs can inherit from parent jobs
- `parent_job_id` creates parent-child relationship
- Child jobs inherit responsibilities and requirements from parent

**BR-JOB-004**: Job-Position Relationship
- Job defines WHAT work needs to be done (template)
- Position defines WHERE work is done (organizational placement)
- One job can have multiple positions across different BUs

**BR-JOB-005**: Grade-Level Consistency
- If both `grade_id` and `level_id` are provided, they should be compatible
- Grade determines compensation range
- Level determines seniority

---

## JobProfile Specification

### Field Specifications

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| `job_id` | UUID | Yes | Must reference valid job |
| `locale_code` | string(10) | Yes | Valid locale (e.g., en-US, vi-VN) |
| `summary` | text | No | Max 2000 characters |
| `responsibilities` | text | No | Max 5000 characters |
| `qualifications` | text | No | Max 5000 characters |

### Business Rules

**BR-PROF-001**: One Profile Per Job-Locale
- Each job can have one profile per locale
- Unique constraint: (`job_id`, `locale_code`)

**BR-PROF-002**: Profile Content
- Profile provides detailed description (responsibilities, requirements, skills)
- Profile is separate from job definition for localization support

---

## Validation Rules

### Data Quality

**VR-001**: Required Fields
- All required fields must be populated
- No NULL values for required fields

**VR-002**: Data Types
- All fields must match specified data types
- Enums must use exact values (case-sensitive)

**VR-003**: Referential Integrity
- All foreign keys must reference existing records
- Orphaned records not allowed

### Business Logic

**VR-004**: Taxonomy Hierarchy
- No circular references in taxonomy hierarchy
- Parent must exist before child
- Cannot delete parent with active children

**VR-005**: Job Hierarchy
- No circular references in job hierarchy
- Parent job must exist before child job
- Cannot delete parent job with active child jobs

---

## Integration Points

### With Total Rewards (TR) Module

**Grade Integration**:
- `job.grade_id` links to TR Grade for compensation
- Grade determines pay range
- Position inherits grade from job

**Level Integration**:
- `job.level_id` defines seniority
- Used for career progression
- May influence compensation adjustments

### With Talent Acquisition (TA) Module

**Job Requisition**:
- Requisitions reference job for requirements
- Job profile provides detailed description
- Taxonomy enables job matching

---

## Advanced Features

> [!NOTE]
> **Phase 2 Implementation**
> 
> The following features support multi-tree architecture for complex organizations.
> Most organizations should use the simplified design described above.

### Additional Entities

For multi-tree architecture, additional entities are available:

**TaxonomyTree**: Container for independent taxonomy hierarchies
- Enables multiple taxonomy trees (corporate + BU-specific)
- Fields: `code`, `owner_scope`, `owner_unit_id`

**JobTree**: Container for independent job hierarchies
- Enables multiple job catalogs (corporate + BU-specific)
- Fields: `code`, `owner_scope`, `owner_unit_id`, `parent_tree_id`

**TaxonomyXMap**: Cross-tree taxonomy mapping
- Maps BU taxonomy → Corporate taxonomy for reporting
- Fields: `src_node_id`, `target_node_id`, `map_type_code`

**JobXMap**: Cross-tree job mapping
- Maps BU jobs → Corporate jobs for reporting
- Fields: `src_job_id`, `target_job_id`, `map_type_code`

**JobTaxonomyMap**: Many-to-many job-taxonomy
- Allows job to belong to multiple taxonomy nodes
- Fields: `job_id`, `taxonomy_id`, `is_primary`

### Advanced Business Rules

**BR-ADV-001**: Tree Ownership
- If `owner_scope = BU`, then `owner_unit_id` is required
- Corporate trees have `owner_scope = CORP` and `owner_unit_id = NULL`

**BR-ADV-002**: Cross-Tree Mapping
- Source and target must be in different trees
- Mapping enables consolidated reporting
- One source can map to one target

For complete specifications, see [Glossary - Advanced Features](../00-ontology/glossary-job-position.md#advanced-features).

---

## References

- [Core Ontology](../00-ontology/core-ontology.yaml) - Entity definitions
- [Job & Position Glossary](../00-ontology/glossary-job-position.md) - Field descriptions
- [Job & Position Guide](./03-job-position-guide.md) - Concept guide
- [Module Documentation Standards](../../MODULE-DOCUMENTATION-STANDARDS.md) - Documentation standards

---

**Document Version**: 1.0  
**Created**: 2025-12-23  
**Last Review**: 2025-12-23
