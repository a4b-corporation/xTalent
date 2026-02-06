---
# === METADATA ===
id: FRS-CO-JOB-POSITION
module: CO
sub_module: job-position
title: "Job & Position Management Requirements"
version: "1.0.0"
status: DRAFT
owner: "Core HR Team"
last_updated: "2026-01-08"
tags:
  - job
  - position
  - taxonomy
  - profile
  - organization

# === REQUIREMENTS DATA ===
# NOTE: Phase 1 includes Job Taxonomy (10 FRs)
# Phase 2 will add Job Profile (20 FRs)
# Phase 3 will add Position Management (17 FRs)

requirements:
  # ===== JOB TAXONOMY (10 FRs) =====
  
  - id: FR-TAX-001
    title: "Create Job Taxonomy Tree"
    description: "System shall allow creating job taxonomy trees to organize jobs hierarchically by family, function, and specialty."
    priority: MUST
    type: Functional
    risk: high
    status: Defined
    acceptance_criteria:
      - "Taxonomy tree has unique code and name"
      - "Tree supports multi-level hierarchy"
      - "Root node represents organization-wide taxonomy"
      - "Child nodes can be families, functions, or tracks"
      - "Tree effective dates set for versioning"
      - "Multiple taxonomy trees can coexist"
      - "SCD Type 2 history retained"
    dependencies:
      - "[[JobTaxonomy]]"
      - "[[TaxonomyTree]]"
    implemented_by: []

  - id: FR-TAX-002
    title: "Job Taxonomy Node Management"
    description: "System shall support CRUD operations on taxonomy nodes with proper parent-child relationships and validation."
    priority: MUST
    type: Functional
    risk: medium
    status: Defined
    acceptance_criteria:
      - "Node has code, name, description"
      - "Node type specified: FAMILY, FUNCTION, TRACK, SPECIALTY"
      - "Parent node can be set for hierarchy"
      - "Level in hierarchy tracked (depth)"
      - "Sequence number for ordering siblings"
      - "Circular references prevented"
      - "Cannot delete node with children"
      - "Node deactivation supported"
    dependencies:
      - "[[JobTaxonomy]]"
      - "[[TaxonomyTree]]"
    implemented_by: []

  - id: FR-TAX-003
    title: "Job Family Definition"
    description: "System shall allow defining job families to group related jobs with similar characteristics and career paths."
    priority: MUST
    type: Functional
    risk: medium
    status: Defined
    acceptance_criteria:
      - "Job family has unique code and name"
      - "Family description documents scope and purpose"
      - "Family can have parent family for sub-grouping"
      - "Jobs linked to family via job profile"
      - "Family effective dates support versioning"
      - "Family can be activated/deactivated"
      - "Example families: Engineering, Sales, HR, Finance"
    dependencies:
      - "[[JobFamily]]"
      - "[[JobTaxonomy]]"
    implemented_by: []

  - id: FR-TAX-004
    title: "Job Function Definition"
    description: "System shall allow defining job functions to categorize jobs by operational area or discipline."
    priority: MUST
    type: Functional
    risk: medium
    status: Defined
    acceptance_criteria:
      - "Job function has unique code and name"
      - "Function description documents scope"
      - "Function can have parent function for sub-categorization"
      - "Jobs linked to function via job profile"
      - "Function effective dates support versioning"
      - "Function can be activated/deactivated"
      - "Example functions: Software Development, Quality Assurance, Product Management"
    dependencies:
      - "[[JobFunction]]"
      - "[[JobTaxonomy]]"
    implemented_by: []

  - id: FR-TAX-005
    title: "Job Taxonomy Hierarchy Validation"
    description: "System shall enforce hierarchy rules and prevent invalid taxonomy structures."
    priority: MUST
    type: Validation
    risk: high
    status: Defined
    acceptance_criteria:
      - "Maximum hierarchy depth configurable (default: 5 levels)"
      - "Circular references prevented"
      - "Parent node must exist before child creation"
      - "Cannot set node as its own parent"
      - "Cannot delete node with active children"
      - "Hierarchy path validated on save"
      - "Orphaned nodes not allowed"
    dependencies:
      - "[[JobTaxonomy]]"
      - "[[TaxonomyTree]]"
    implemented_by: []

  - id: FR-TAX-010
    title: "Job Level Management"
    description: "System shall manage job levels to define seniority and career progression stages."
    priority: MUST
    type: Configuration
    risk: medium
    status: Defined
    acceptance_criteria:
      - "Job level has unique code and name"
      - "Level has numeric rank for ordering (1=entry, higher=senior)"
      - "Level description documents seniority expectations"
      - "Level applies across job families"
      - "Multiple levels supported (e.g., Junior, Mid, Senior, Lead, Principal)"
      - "Level effective dates for versioning"
      - "Levels can be activated/deactivated"
    dependencies:
      - "[[JobLevel]]"
    implemented_by: []

  - id: FR-TAX-011
    title: "Job Grade Management"
    description: "System shall manage job grades to group jobs of similar value and compensation ranges."
    priority: MUST
    type: Configuration
    risk: medium
    status: Defined
    acceptance_criteria:
      - "Job grade has unique code and name"
      - "Grade has numeric rank for ordering"
      - "Grade description documents job value and scope"
      - "Grade applies across job families"
      - "Grade links to compensation bands (optional)"
      - "Multiple grades supported (e.g., G1-G15)"
      - "Grade effective dates for versioning"
      - "Grades can be activated/deactivated"
    dependencies:
      - "[[JobGrade]]"
    implemented_by: []

  - id: FR-TAX-012
    title: "Level-Grade Mapping"
    description: "System shall support mapping job levels to job grades for consistent leveling across organization."
    priority: SHOULD
    type: Configuration
    risk: low
    status: Defined
    acceptance_criteria:
      - "Level can map to one or more grades"
      - "Grade can map to one or more levels"
      - "Mapping can vary by job family (optional)"
      - "Mapping effective dates for versioning"
      - "Example: Senior level might map to grades G7-G9"
      - "Mapping helps with standardization"
    dependencies:
      - "[[JobLevel]]"
      - "[[JobGrade]]"
      - "[[JobLevelPolicy]]"
    implemented_by: []

  - id: FR-TAX-020
    title: "Job Taxonomy Search & Filter"
    description: "System shall provide search and filter capabilities for taxonomy navigation and job discovery."
    priority: MUST
    type: Functional
    risk: low
    status: Defined
    acceptance_criteria:
      - "Search by taxonomy code, name, description"
      - "Filter by taxonomy type (Family, Function, Track)"
      - "Filter by active/inactive status"
      - "Filter by effective date range"
      - "Browse hierarchy tree"
      - "Show all jobs within taxonomy node"
      - "Quick search with autocomplete"
      - "Advanced search with multiple criteria"
    dependencies:
      - "[[JobTaxonomy]]"
      - "[[Job]]"
    implemented_by: []

  - id: FR-TAX-021
    title: "Taxonomy Tree Visualization"
    description: "System shall provide visual representation of job taxonomy hierarchy for easy navigation and understanding."
    priority: SHOULD
    type: UI/UX
    risk: low
    status: Planned
    acceptance_criteria:
      - "Interactive tree view with expand/collapse"
      - "Visual indicators for node types"
      - "Show job count per taxonomy node"
      - "Drag-and-drop for reorganization (with approval)"
      - "Export tree structure to image or PDF"
      - "Highlight active path for selected job"
      - "Zoom and pan for large trees"
    dependencies:
      - "[[JobTaxonomy]]"
      - "[[TaxonomyTree]]"
    implemented_by: []

# === ONTOLOGY REFERENCES ===
# NOTE: Full list will be complete after Phase 3
related_ontology:
  - "[[Job]]"
  - "[[JobProfile]]"
  - "[[Position]]"
  - "[[JobTaxonomy]]"
  - "[[TaxonomyTree]]"
  - "[[JobFamily]]"
  - "[[JobFunction]]"
  - "[[JobLevel]]"
  - "[[JobGrade]]"
  - "[[JobLevelPolicy]]"
  - "[[Skill]]"
  - "[[Competency]]"
  - "[[BusinessUnit]]"
  - "[[Location]]"
---

# Job & Position Management Requirements

> **Module**: CO (Core HCM)  
> **Sub-module**: Job & Position Management  
> **Total Requirements**: 47 (Phase 1: 10 taxonomy, Phase 2: +20 profiles, Phase 3: +17 positions)  
> **Current Phase**: Phase 1 - Job Taxonomy ✅

---

## 1. Functional Scope

```mermaid
mindmap
  root((Job & Position<br/>Management))
    Job Taxonomy
      Taxonomy Structure
        FR-TAX-001 Create Tree
        FR-TAX-002 Node Management
        FR-TAX-005 Hierarchy Validation
      Taxonomy Categories
        FR-TAX-003 Job Family
        FR-TAX-004 Job Function
      Level & Grade
        FR-TAX-010 Level Management
        FR-TAX-011 Grade Management
        FR-TAX-012 Level-Grade Mapping
      Search & Visualization
        FR-TAX-020 Search & Filter
        FR-TAX-021 Tree Visualization
    Job Profile
      "(Phase 2: 20 FRs)"
    Position Management
      "(Phase 3: 17 FRs)"
```

---

## 2. Requirement Catalog

### Phase 1: Job Taxonomy (10 FRs) ✅

| ID | Requirement Detail | Priority | Type |
|----|-------------------|----------|------|
| `[[FR-TAX-001]]` | **Create Job Taxonomy Tree**<br>Organize jobs hierarchically by family, function, and specialty | MUST | Functional |
| `[[FR-TAX-002]]` | **Job Taxonomy Node Management**<br>CRUD operations on taxonomy nodes with parent-child relationships | MUST | Functional |
| `[[FR-TAX-003]]` | **Job Family Definition**<br>Define job families to group related jobs | MUST | Functional |
| `[[FR-TAX-004]]` | **Job Function Definition**<br>Define job functions to categorize jobs by operational area | MUST | Functional |
| `[[FR-TAX-005]]` | **Job Taxonomy Hierarchy Validation**<br>Enforce hierarchy rules and prevent invalid structures | MUST | Validation |
| `[[FR-TAX-010]]` | **Job Level Management**<br>Manage job levels for seniority and career progression | MUST | Configuration |
| `[[FR-TAX-011]]` | **Job Grade Management**<br>Manage job grades for compensation and job value grouping | MUST | Configuration |
| `[[FR-TAX-012]]` | **Level-Grade Mapping**<br>Map job levels to grades for consistent leveling | SHOULD | Configuration |
| `[[FR-TAX-020]]` | **Job Taxonomy Search & Filter**<br>Search and filter capabilities for taxonomy navigation | MUST | Functional |
| `[[FR-TAX-021]]` | **Taxonomy Tree Visualization**<br>Visual representation of job taxonomy hierarchy | SHOULD | UI/UX |

### Phase 2: Job Profile (20 FRs) 🔜
*To be added in Phase 2*

### Phase 3: Position Management (17 FRs) 🔜
*To be added in Phase 3*

---

## 3. Detailed Specifications

### Phase 1: Job Taxonomy

#### [[FR-TAX-001]] Create Job Taxonomy Tree

*   **Description**: System shall allow creating job taxonomy trees to organize jobs hierarchically by family, function, and specialty.
*   **Acceptance Criteria**:
    *   Taxonomy tree has unique code and name
    *   Tree supports multi-level hierarchy
    *   Root node represents organization-wide taxonomy
    *   Child nodes can be families, functions, or tracks
    *   Tree effective dates set for versioning
    *   Multiple taxonomy trees can coexist
    *   SCD Type 2 history retained
*   **Dependencies**:
    *   Depends on: `[[JobTaxonomy]]`, `[[TaxonomyTree]]`
    *   Enforces: `[[BR-TAX-001]]`
*   **Mapped Features**: Implemented by: `[[FEAT-TAX-001]]`

---

#### [[FR-TAX-002]] Job Taxonomy Node Management

*   **Description**: System shall support CRUD operations on taxonomy nodes with proper parent-child relationships and validation.
*   **Acceptance Criteria**:
    *   Node has code, name, description
    *   Node type specified: FAMILY, FUNCTION, TRACK, SPECIALTY
    *   Parent node can be set for hierarchy
    *   Level in hierarchy tracked (depth)
    *   Sequence number for ordering siblings
    *   Circular references prevented
    *   Cannot delete node with children
    *   Node deactivation supported
*   **Dependencies**:
    *   Depends on: `[[JobTaxonomy]]`, `[[TaxonomyTree]]`
    *   Enforces: `[[BR-TAX-002]]`
*   **Mapped Features**: Implemented by: `[[FEAT-TAX-002]]`

---

#### [[FR-TAX-003]] Job Family Definition

*   **Description**: System shall allow defining job families to group related jobs with similar characteristics and career paths.
*   **Acceptance Criteria**:
    *   Job family has unique code and name
    *   Family description documents scope and purpose
    *   Family can have parent family for sub-grouping
    *   Jobs linked to family via job profile
    *   Family effective dates support versioning
    *   Family can be activated/deactivated
    *   Example families: Engineering, Sales, HR, Finance
*   **Dependencies**:
    *   Depends on: `[[JobFamily]]`, `[[JobTaxonomy]]`
    *   Enforces: `[[BR-TAX-003]]`
*   **Mapped Features**: Implemented by: `[[FEAT-TAX-003]]`

---

#### [[FR-TAX-004]] Job Function Definition

*   **Description**: System shall allow defining job functions to categorize jobs by operational area or discipline.
*   **Acceptance Criteria**:
    *   Job function has unique code and name
    *   Function description documents scope
    *   Function can have parent function for sub-categorization
    *   Jobs linked to function via job profile
    *   Function effective dates support versioning
    *   Function can be activated/deactivated
    *   Example functions: Software Development, Quality Assurance, Product Management
*   **Dependencies**:
    *   Depends on: `[[JobFunction]]`, `[[JobTaxonomy]]`
    *   Enforces: `[[BR-TAX-004]]`
*   **Mapped Features**: Implemented by: `[[FEAT-TAX-004]]`

---

#### [[FR-TAX-005]] Job Taxonomy Hierarchy Validation

*   **Description**: System shall enforce hierarchy rules and prevent invalid taxonomy structures.
*   **Acceptance Criteria**:
    *   Maximum hierarchy depth configurable (default: 5 levels)
    *   Circular references prevented
    *   Parent node must exist before child creation
    *   Cannot set node as its own parent
    *   Cannot delete node with active children
    *   Hierarchy path validated on save
    *   Orphaned nodes not allowed
*   **Dependencies**:
    *   Depends on: `[[JobTaxonomy]]`, `[[TaxonomyTree]]`
    *   Enforces: `[[BR-TAX-005]]`
*   **Mapped Features**: Implemented by: `[[FEAT-TAX-005]]`

---

#### [[FR-TAX-010]] Job Level Management

*   **Description**: System shall manage job levels to define seniority and career progression stages.
*   **Acceptance Criteria**:
    *   Job level has unique code and name
    *   Level has numeric rank for ordering (1=entry, higher=senior)
    *   Level description documents seniority expectations
    *   Level applies across job families
    *   Multiple levels supported (e.g., Junior, Mid, Senior, Lead, Principal)
    *   Level effective dates for versioning
    *   Levels can be activated/deactivated
*   **Dependencies**:
    *   Depends on: `[[JobLevel]]`
    *   Enforces: `[[BR-TAX-010]]`
*   **Mapped Features**: Implemented by: `[[FEAT-TAX-010]]`

---

#### [[FR-TAX-011]] Job Grade Management

*   **Description**: System shall manage job grades to group jobs of similar value and compensation ranges.
*   **Acceptance Criteria**:
    *   Job grade has unique code and name
    *   Grade has numeric rank for ordering
    *   Grade description documents job value and scope
    *   Grade applies across job families
    *   Grade links to compensation bands (optional)
    *   Multiple grades supported (e.g., G1-G15)
    *   Grade effective dates for versioning
    *   Grades can be activated/deactivated
*   **Dependencies**:
    *   Depends on: `[[JobGrade]]`
    *   Enforces: `[[BR-TAX-011]]`
*   **Mapped Features**: Implemented by: `[[FEAT-TAX-011]]`

---

#### [[FR-TAX-012]] Level-Grade Mapping

*   **Description**: System shall support mapping job levels to job grades for consistent leveling across organization.
*   **Acceptance Criteria**:
    *   Level can map to one or more grades
    *   Grade can map to one or more levels
    *   Mapping can vary by job family (optional)
    *   Mapping effective dates for versioning
    *   Example: Senior level might map to grades G7-G9
    *   Mapping helps with standardization
*   **Dependencies**:
    *   Depends on: `[[JobLevel]]`, `[[JobGrade]]`, `[[JobLevelPolicy]]`
    *   Enforces: `[[BR-TAX-012]]`
*   **Mapped Features**: Implemented by: `[[FEAT-TAX-012]]`

---

#### [[FR-TAX-020]] Job Taxonomy Search & Filter

*   **Description**: System shall provide search and filter capabilities for taxonomy navigation and job discovery.
*   **Acceptance Criteria**:
    *   Search by taxonomy code, name, description
    *   Filter by taxonomy type (Family, Function, Track)
    *   Filter by active/inactive status
    *   Filter by effective date range
    *   Browse hierarchy tree
    *   Show all jobs within taxonomy node
    *   Quick search with autocomplete
    *   Advanced search with multiple criteria
*   **Dependencies**:
    *   Depends on: `[[JobTaxonomy]]`, `[[Job]]`
*   **Mapped Features**: Implemented by: `[[FEAT-TAX-020]]`

---

#### [[FR-TAX-021]] Taxonomy Tree Visualization

*   **Description**: System shall provide visual representation of job taxonomy hierarchy for easy navigation and understanding.
*   **Acceptance Criteria**:
    *   Interactive tree view with expand/collapse
    *   Visual indicators for node types
    *   Show job count per taxonomy node
    *   Drag-and-drop for reorganization (with approval)
    *   Export tree structure to image or PDF
    *   Highlight active path for selected job
    *   Zoom and pan for large trees
*   **Dependencies**:
    *   Depends on: `[[JobTaxonomy]]`, `[[TaxonomyTree]]`
*   **Mapped Features**: Implemented by: `[[FEAT-TAX-021]]`

---

## 4. Requirement Hierarchy

> **Note**: Complete requirement hierarchy diagram will be added in Phase 3 after all requirements are documented.

---

## 5. Phase 1 Summary

This phase documents **10 job taxonomy requirements** covering:

- **Taxonomy Structure** (5 FRs): Tree creation, node management, families, functions, hierarchy validation
- **Level & Grade Configuration** (3 FRs): Job levels, job grades, level-grade mapping
- **Search & Visualization** (2 FRs): Search/filter capabilities and tree visualization

**Next Phase**: Phase 2 will add 20 job profile requirements (profile CRUD, descriptions, skills, competencies, education, experience, work environment).

---

**Phase 1 Status**: ✅ Complete  
**File Size**: ~480 lines  
**Ready for**: User review before proceeding to Phase 2
