# Job & Position Glossary

## Overview

This glossary defines the job and position structure entities used in the xTalent HCM system.

**Implementation Approaches**:
- **Simplified Design (Recommended)**: 3-entity structure (JobTaxonomy, Job, JobProfile) suitable for most organizations
- **Advanced Design (Optional)**: Multi-tree architecture for complex organizations requiring independent job catalogs

This document primarily describes the simplified design. Advanced features are marked with **[ADVANCED]** and detailed in the [Advanced Features](#advanced-features) section.

---

## Core Concepts

### Job vs Position

- **Job**: Template defining what work needs to be done (responsibilities, requirements, compensation level)
- **Position**: Specific instance of a job in an organizational context (budgeted headcount slot)

### Job Taxonomy

Hierarchical classification system organizing jobs into:
- **Level 1 - FAMILY**: Broad occupational group (e.g., Engineering, Sales)
- **Level 2 - SUBFAMILY**: Specific function area (e.g., Software Engineering, Enterprise Sales)
- **Level 3 - FUNCTION**: Detailed category (e.g., Backend Development, Account Management)

---

## Entities



### JobTaxonomy

**Definition:** Hierarchical job classification nodes within a taxonomy tree. Provides standardized job categorization (e.g., job family, job function, job category).

**Purpose:**
- Classify jobs into hierarchical categories
- Support job family structures
- Enable taxonomy-based reporting
- Facilitate job market analysis

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `code` | string(50) | Yes | Taxonomy code (unique) |
| `name` | string(150) | Yes | Taxonomy name |
| `taxonomy_type` | enum | Yes | FAMILY, SUBFAMILY, FUNCTION |
| `parent_id` | UUID | No | Parent taxonomy node (null for FAMILY) |
| `level` | integer | No | Hierarchy level (1, 2, 3) |
| `path` | string(255) | No | Materialized path |
| `description` | text | No | Taxonomy description |
| `metadata` | jsonb | No | Additional classification data |
| `effective_start_date` | date | Yes | Effective start date |
| `effective_end_date` | date | No | Effective end date |
| `is_current_flag` | boolean | Yes | Current record indicator |

**Taxonomy Levels:**

| Level | taxonomy_type | Description | Example |
|-------|---------------|-------------|---------|
| 1 | TRACK | Broad occupational track | Engineering, Sales, Operations |
| 2 | FAMILY | Job family within track | Software Engineering, Enterprise Sales |
| 3 | GROUP | Specific job group | Backend Development, Account Management |
| 4 | SUBGROUP | Detailed sub-group | Microservices Backend, Strategic Accounts |

**Metadata Structure:**
```json
{
  "onet_code": "15-1252.00",
  "industry_classification": "Technology",
  "skill_cluster": ["Programming", "System Design"],
  "career_path_group": "Technical Track",
  "market_data_available": true
}
```

**Relationships:**
- **Belongs to** `JobTaxonomy` (parent) - for hierarchy
- **Has many** `JobTaxonomy` (children)
- **Has many** `Job` (jobs classified under this taxonomy)

**Business Rules:**
- Code must be unique
- `taxonomy_type` must match `level` (TRACK=1, FAMILY=2, GROUP=3, SUBGROUP=4)
- Parent required for FAMILY, GROUP, and SUBGROUP levels (TRACK has no parent)
- Path must reflect actual hierarchy
- Maximum 4 levels recommended
- SCD Type 2 for historical tracking
- Jobs should link to GROUP or SUBGROUP level for most specific classification

**Example:**

```yaml
# Level 1: Track
id: tax_eng_001
code: ENG
name: Engineering
taxonomy_type: TRACK
parent_id: null
level: 1
path: /ENG
sort_order: 1

# Level 2: Family
id: tax_sw_eng_001
code: SW_ENG
name: Software Engineering
taxonomy_type: FAMILY
parent_id: tax_eng_001
level: 2
path: /ENG/SW_ENG
sort_order: 1

# Level 3: Group
id: tax_backend_001
code: BACKEND
name: Backend Development
taxonomy_type: GROUP
parent_id: tax_sw_eng_001
level: 3
path: /ENG/SW_ENG/BACKEND
sort_order: 1

# Level 4: Sub-Group
id: tax_microservices_001
code: MICROSERVICES
name: Microservices Backend
taxonomy_type: SUBGROUP
parent_id: tax_backend_001
level: 4
path: /ENG/SW_ENG/BACKEND/MICROSERVICES
sort_order: 1
```

**[ADVANCED] Multi-Tree Support:**

For complex organizations requiring multiple independent taxonomy trees, additional attributes are available:
- `tree_id`: Reference to taxonomy tree container
- `owner_scope`: CORP | LE | BU (ownership scope)
- `owner_unit_id`: Owning business unit ID
- `inherit_flag`: Inheritance control
- `override_name`: BU-specific name override
- `visibility`: PUBLIC | PRIVATE | RESTRICTED

See [Advanced Features](#advanced-features) section for details.

---


### Job

**Definition:** Job definition representing a role or position type within the organization. Defines responsibilities, requirements, and competencies independent of specific incumbents.

**Purpose:**
- Define standard job roles
- Specify job requirements and qualifications
- Support job evaluation and grading
- Enable workforce planning

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| **Core Identification** | | | |
| `id` | UUID | Yes | Unique identifier |
| `code` | string(50) | Yes | Job code (unique within tree) |
| `title` | string(150) | Yes | Job title |
| `parent_id` | UUID | No | Parent job (for hierarchy) |
| **Tree & Ownership** | | | |
| `tree_id` | UUID | No | Job tree reference (optional) |
| `owner_scope` | enum | Yes | CORP | LE | BU (ownership scope) |
| `owner_unit_id` | UUID | No | Owning business unit (required if owner_scope=BU) |
| `inherit_flag` | boolean | Yes | Inheritance control (default: true) |
| `override_title` | string(255) | No | BU-specific title override |
| `visibility` | enum | No | PUBLIC | PRIVATE | RESTRICTED |
| **Classification** | | | |
| `job_type_code` | string(50) | No | code_list(JOB_TYPE) - e.g., INDIVIDUAL_CONTRIBUTOR, MANAGER |
| `ranking_level_code` | string(50) | No | code_list(JOB_RANK) - e.g., ENTRY, JUNIOR, MID, SENIOR, PRINCIPAL |
| **Grade & Level** | | | |
| `level_id` | UUID | No | Job level reference (FK to JobLevel) |
| `grade_id` | UUID | No | Job grade reference (FK to JobGrade) |
| **US Labor Classification** | | | |
| `flsa_status` | enum | No | EXEMPT | NON_EXEMPT |
| `is_manager` | boolean | No | Manager role indicator |
| **Hierarchy & Path** | | | |
| `path` | string(500) | No | Materialized path (ltree format) |
| `sort_order` | integer | No | Display order |
| **Description & Metadata** | | | |
| `description` | text | No | Job description |
| `metadata` | jsonb | No | Additional job attributes |
| **SCD Type-2** | | | |
| `effective_start_date` | date | Yes | Effective start date |
| `effective_end_date` | date | No | Effective end date |
| `is_current_flag` | boolean | Yes | Current record indicator |

**Metadata Structure:**
```json
{
  "responsibilities": [
    "Design and develop backend services",
    "Mentor junior engineers",
    "Participate in architecture decisions"
  ],
  "requirements": {
    "education": "Bachelor's degree in Computer Science or related field",
    "experience_years": 5,
    "certifications": []
  },
  "working_conditions": {
    "remote_eligible": true,
    "travel_required": "Occasional",
    "physical_demands": "Sedentary"
  },
  "market_data": {
    "benchmark_job": "Software Engineer III",
    "market_percentile": 50
  }
```
}
```

**Relationships:**
- **Belongs to** `Job` (parent job) - for hierarchy
- **Links to** `JobTaxonomy` via `JobTaxonomyMap` (many-to-many classification)
- **Belongs to** `JobLevel` (seniority)
- **Belongs to** `JobGrade` (compensation)
- **Belongs to** `JobTree` (optional tree container)
- **Has one** `JobProfile` (detailed profile)
- **Has many** `Position` (position instances)
- **Has many** `Assignment` (direct job assignments in JOB_BASED model)

**Business Rules:**
- Job code must be unique within tree
- Can inherit from parent job (responsibilities, requirements)
- Jobs link to taxonomy via JobTaxonomyMap (many-to-many)
- One taxonomy link must be marked as primary (is_primary=true)
- Primary taxonomy should be at GROUP or SUBGROUP level
- Path field supports ltree for efficient hierarchy queries
- SCD Type 2 for historical tracking
- Job defines WHAT work needs to be done (template)
- Position defines WHERE work is done (organizational placement)
- JobProfile provides detailed description (responsibilities, requirements, skills)

**Example:**

```yaml
id: job_senior_backend_001
code: SR_BACKEND_ENG
title: Senior Backend Engineer
parent_id: job_backend_eng_001
tree_id: tree_corp_jobs  # Optional
owner_scope: CORP
inherit_flag: true
level_id: level_senior
grade_id: grade_p3
job_type_code: INDIVIDUAL_CONTRIBUTOR
ranking_level_code: SENIOR
flsa_status: EXEMPT
is_manager: false
path: /ENG/SW_ENG/BACKEND/SR_BACKEND
description: "Designs and develops scalable backend services..."

# Taxonomy links (via JobTaxonomyMap):
# - taxonomy_id: tax_backend_dev (is_primary: true, level: GROUP)
# - taxonomy_id: tax_cloud_services (is_primary: false, level: GROUP)
```

**Taxonomy Classification:**

Jobs are classified using a many-to-many relationship with JobTaxonomy via the `JobTaxonomyMap` entity.

**Key Points:**
- A job can belong to multiple taxonomy nodes
- One taxonomy link must be marked as primary (`is_primary = true`)
- Primary taxonomy should be at GROUP or SUBGROUP level
- Secondary taxonomies can be used for cross-functional roles

**Example**: A "DevOps Engineer" might have:
- Primary: Technology > Software Engineering > DevOps (GROUP)
- Secondary: Technology > Infrastructure > Cloud Services (GROUP)


---

### JobProfile

**Definition:** Extended profile for jobs including detailed responsibilities, requirements, competencies, and skills.

**Purpose:**
- Document detailed job requirements
- Define required skills and competencies
- Support job evaluation
- Enable talent acquisition and development

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `job_id` | UUID | Yes | Job reference (PK and FK) |
| `summary` | text | No | Job summary |
| `responsibilities` | text | No | Key responsibilities |
| `qualifications` | text | No | Required qualifications |
| `min_education_level` | string(50) | No | Minimum education level |
| `min_experience_years` | decimal(4,1) | No | Minimum years of experience |
| `preferred_certifications` | text | No | Preferred certifications |
| `physical_requirements` | text | No | Physical requirements |
| `working_conditions` | text | No | Working conditions |
| `travel_percentage` | decimal(5,2) | No | Travel percentage (0-100) |
| `remote_eligible` | boolean | No | Remote work eligible |
| `metadata` | jsonb | No | Additional profile data |

**Metadata Structure:**
```json
{
  "skills": [
    {
      "skill_id": "skill_python",
      "proficiency_required": 4,
      "is_mandatory": true
    },
    {
      "skill_id": "skill_aws",
      "proficiency_required": 3,
      "is_mandatory": false
    }
  ],
  "competencies": [
    {
      "competency_id": "comp_problem_solving",
      "level_required": 4
    }
  ],
  "languages": [
    {
      "language": "English",
      "proficiency": "Professional"
    }
  ]
}
```

**Relationships:**
- **Belongs to** `Job` (one-to-one)
- **References** `SkillMaster` (via metadata)
- **References** `CompetencyMaster` (via metadata)

**Business Rules:**
- One profile per job
- Skills and competencies defined in metadata
- Profile inherited from parent job if not specified

---

### JobLevel

**Definition:** Job level classification (e.g., Junior, Mid, Senior, Principal, Executive) defining career progression tiers.

**Purpose:**
- Define career progression levels
- Support leveling frameworks
- Enable level-based compensation
- Facilitate talent management

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `code` | string(50) | Yes | Level code |
| `name` | string(100) | No | Level name |
| `level_order` | integer | No | Hierarchical order (1=lowest) |
| `category` | enum | No | INDIVIDUAL_CONTRIBUTOR, MANAGER, EXECUTIVE |
| `description` | text | No | Level description |
| `metadata` | jsonb | No | Level criteria, expectations |
| `effective_start_date` | date | Yes | Effective start date |
| `effective_end_date` | date | No | Effective end date |
| `is_current_flag` | boolean | Yes | Current record indicator |

**Level Examples:**

| Code | Name | Order | Category |
|------|------|-------|----------|
| `JUNIOR` | Junior | 1 | INDIVIDUAL_CONTRIBUTOR |
| `MID` | Mid-Level | 2 | INDIVIDUAL_CONTRIBUTOR |
| `SENIOR` | Senior | 3 | INDIVIDUAL_CONTRIBUTOR |
| `PRINCIPAL` | Principal | 4 | INDIVIDUAL_CONTRIBUTOR |
| `MANAGER` | Manager | 3 | MANAGER |
| `DIRECTOR` | Director | 5 | MANAGER |
| `VP` | Vice President | 6 | EXECUTIVE |

**Metadata Structure:**
```json
{
  "expectations": {
    "scope": "Team level",
    "impact": "Significant",
    "autonomy": "High",
    "leadership": "Mentor others"
  },
  "typical_experience_years": "5-8",
  "career_progression": {
    "next_level": "PRINCIPAL",
    "typical_time_in_level": "2-3 years"
  }
}
```

**Business Rules:**
- Level code must be unique
- Level order defines progression
- SCD Type 2 for historical tracking

---

### JobGrade

**Definition:** Job grade classification for compensation and job evaluation purposes. Maps jobs to pay grades.

**Purpose:**
- Support compensation structure
- Enable job evaluation
- Define pay ranges
- Facilitate salary administration

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `code` | string(50) | Yes | Grade code |
| `name` | string(100) | No | Grade name |
| `grade_order` | integer | No | Hierarchical order |
| `min_salary` | decimal(14,2) | No | Minimum salary |
| `mid_salary` | decimal(14,2) | No | Midpoint salary |
| `max_salary` | decimal(14,2) | No | Maximum salary |
| `currency_code` | string(3) | No | Currency code |
| `description` | text | No | Grade description |
| `metadata` | jsonb | No | Grade rules, ranges |
| `effective_start_date` | date | Yes | Effective start date |
| `effective_end_date` | date | No | Effective end date |
| `is_current_flag` | boolean | Yes | Current record indicator |

**Metadata Structure:**
```json
{
  "pay_structure": "BROADBAND",
  "compa_ratio_min": 0.80,
  "compa_ratio_max": 1.20,
  "market_reference": "P50",
  "progression_rules": {
    "max_increase_percent": 15,
    "typical_increase_percent": 8
  }
}
```

**Business Rules:**
- Grade code must be unique
- Min ≤ Mid ≤ Max salary
- SCD Type 2 for historical tracking
- Currency code required if salaries specified

---

### Position

**Definition:** Specific instance of a job in a business unit. Represents a budgeted headcount slot that can be filled by an employee.

**Purpose:**
- Support position-based staffing model
- Enable headcount budgeting and control
- Track position incumbents
- Facilitate organizational planning

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `code` | string(50) | Yes | Position code |
| `name` | string(150) | No | Position name |
| `job_id` | UUID | Yes | Job reference |
| `business_unit_id` | UUID | Yes | Business unit reference |
| `reports_to_position_id` | UUID | No | Reporting position |
| `location_id` | UUID | No | Primary location |
| `fte` | decimal(4,2) | No | Full-time equivalent (default: 1.0) |
| `max_incumbents` | integer | No | Maximum incumbents (default: 1) |
| `current_incumbents` | integer | No | Current incumbent count |
| `status_code` | string(50) | No | ACTIVE, FROZEN, ELIMINATED |
| `position_type` | enum | No | REGULAR, TEMPORARY, PROJECT |
| `is_budgeted` | boolean | No | Budgeted position flag |
| `metadata` | jsonb | No | Additional position data |
| `effective_start_date` | date | Yes | Effective start date |
| `effective_end_date` | date | No | Effective end date |
| `is_current_flag` | boolean | Yes | Current record indicator |

**Position Status:**

| Status | Description |
|--------|-------------|
| `ACTIVE` | Active, can be filled |
| `FROZEN` | Frozen, cannot be filled |
| `ELIMINATED` | Eliminated, no longer exists |
| `PENDING_APPROVAL` | Pending budget approval |

**Metadata Structure:**
```json
{
  "budget_code": "DEPT-001-POS-123",
  "cost_center": "CC-1000",
  "approval_date": "2025-01-15",
  "approved_by": "worker_mgr_001",
  "requisition_id": "REQ-2025-001",
  "succession_plan": {
    "has_successor": true,
    "successor_ready": "1-2 years"
  }
}
```

**Relationships:**
- **Belongs to** `Job`
- **Belongs to** `Unit` (business unit)
- **Belongs to** `Position` (reports to)
- **Belongs to** `WorkLocation`
- **Has many** `Assignment` (position incumbents)

**Business Rules:**
- Position code must be unique
- Current incumbents ≤ max incumbents
- SCD Type 2 for historical tracking
- Reporting position must be in same or parent BU
- Position-based staffing: one position, one (or limited) incumbents
- Job-based staffing: no position required, direct job assignment

**Example:**

```yaml
id: pos_backend_lead_001
code: POS-TECH-BE-001
name: Backend Engineering Lead
job_id: job_senior_backend_001
business_unit_id: bu_engineering
reports_to_position_id: pos_eng_manager_001
location_id: loc_hanoi_office
fte: 1.0
max_incumbents: 1
current_incumbents: 1
status_code: ACTIVE
position_type: REGULAR
is_budgeted: true
```

---

## Staffing Models

### Position-Based Staffing

**Description:** Traditional model where employees are assigned to pre-defined, budgeted positions.

**Characteristics:**
- Strict headcount control
- One-to-one (or limited) position-to-person mapping
- Budget approval required for new positions
- Suitable for corporate roles, management positions

**Example:**
```
Position (Backend Lead) → Assignment → Employee
```

### Job-Based Staffing

**Description:** Flexible model where employees are assigned directly to jobs without predefined positions.

**Characteristics:**
- Flexible capacity management
- Multiple people can have same job
- No position budget constraint
- Suitable for hourly workers, contingent staff, project teams

**Example:**
```
Job (Backend Engineer) → Assignment → Employee
```

### Hybrid Model

Organizations can use both models:
- Corporate roles: Position-based
- Hourly/contingent: Job-based
- Project teams: Job-based

---

## Multi-Tree Architecture

### Cross-Tree Mapping

**Purpose:** Enable consolidation and reporting across multiple job trees.

**Implementation:**
- `job_tree_xmap` table maps jobs between trees
- Supports many-to-many relationships
- Enables corporate reporting from BU jobs

**Example:**
```yaml
# BU Job → Corporate Job Mapping
bu_job_id: job_bu_tech_backend_001
corporate_job_id: job_corp_backend_001
mapping_type: EQUIVALENT
confidence_score: 0.95
```

---

## Use Cases

### Workforce Planning
- Define job catalog and position structure
- Plan headcount and budget
- Track position vacancies
- Support succession planning

### Talent Acquisition
- Create job requisitions from positions
- Define job requirements and qualifications
- Match candidates to jobs
- Support offer management

### Career Development
- Define career paths and progression
- Map job levels and grades
- Support internal mobility
- Enable skill development planning

### Compensation Management
- Link jobs to pay grades
- Define salary ranges
- Support job evaluation
- Enable market pricing

### Organizational Design
- Model organizational structure
- Support reorganizations
- Enable scenario planning
- Facilitate M&A integration

---

## Best Practices

1. **Job Design:**
   - Use clear, descriptive job titles
   - Define comprehensive job profiles
   - Keep job catalog current
   - Regular job evaluation

2. **Position Management:**
   - Maintain accurate position hierarchy
   - Track position status
   - Regular headcount reconciliation
   - Budget alignment

3. **Multi-Tree Strategy:**
   - One corporate tree for standards
   - BU trees for local flexibility
   - Regular cross-tree mapping
   - Consolidated reporting

4. **Staffing Model Selection:**
   - Position-based for corporate roles
   - Job-based for flexible workforce
   - Clear governance and approval

---

## Advanced Features

> [!NOTE]
> **Phase 2 Implementation**
> 
> The following features support advanced multi-tree architecture for complex organizations.
> These are optional and should be considered for Phase 2 implementation when organizational complexity requires it.

### When to Use Multi-Tree Architecture

**Recommended for**:
- Multi-national corporations with regional job variations
- Conglomerates with diverse business units (e.g., VNG: Gaming, FinTech, Cloud, E-commerce)
- M&A scenarios requiring integration of different job catalogs
- Highly decentralized organizations with BU autonomy
- Organizations requiring independent BU job management

**Not recommended for**:
- Small to medium enterprises (SMEs)
- Centralized HR organizations
- Organizations with standardized job structures
- Simple organizational hierarchies

### Multi-Tree Entities

#### TaxonomyTree

**Definition:** Container for independent job taxonomy hierarchies. Enables multiple job classification systems to coexist.

**Key Attributes:**

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | UUID | Unique identifier |
| `code` | string(50) | Tree code (e.g., CORP_TAX, BU_GAMING_TAX) |
| `name` | string(150) | Tree name |
| `owner_scope` | enum | CORP, LE, BU |
| `owner_unit_id` | UUID | Owning business unit ID (if owner_scope=BU) |
| `is_active` | boolean | Active status |

**Example:**
```yaml
# Corporate Taxonomy Tree
code: CORP_TAX_2025
name: Corporate Job Taxonomy 2025
owner_scope: CORP
owner_unit_id: null

# BU Taxonomy Tree
code: BU_GAMING_TAX
name: Gaming Division Taxonomy
owner_scope: BU
owner_unit_id: <gaming_bu_id>
```

#### JobTree

**Definition:** Container for independent job hierarchies. Similar to TaxonomyTree but for job structures.

**Key Attributes:**

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | UUID | Unique identifier |
| `code` | string(50) | Job tree code (e.g., CORP_JOBS, BU_GAMING_JOBS) |
| `name` | string(150) | Job tree name |
| `owner_scope` | enum | CORP, LE, BU |
| `owner_unit_id` | UUID | Owning business unit ID (if owner_scope=BU) |
| `parent_tree_id` | UUID | Parent tree for inheritance |

**Example:**
```yaml
# Corporate Job Tree
code: CORP_JOBS_2025
name: Corporate Job Catalog 2025
owner_scope: CORP
owner_unit_id: null
parent_tree_id: null

# BU Job Tree
code: BU_GAMING_JOBS
name: Gaming Division Job Catalog
owner_scope: BU
owner_unit_id: <gaming_bu_id>
parent_tree_id: <CORP_JOBS_UUID>
```

#### TaxonomyXMap

**Definition:** Cross-tree taxonomy node mapping for reporting consolidation.

**Purpose:** Maps BU-specific taxonomy nodes to corporate taxonomy for consolidated reporting.

**Key Attributes:**

| Attribute | Type | Description |
|-----------|------|-------------|
| `src_node_id` | UUID | Source taxonomy node (BU tree) |
| `target_node_id` | UUID | Target taxonomy node (corporate tree) |
| `map_type_code` | enum | REPORT_TO, ALIGN_WITH, DUPLICATE_OF |

**Example:**
```yaml
# BU Gaming taxonomy maps to Corporate Product taxonomy
src_node_id: <BU_GAMING_GAME_DESIGNER_UUID>
target_node_id: <CORP_PRODUCT_DESIGNER_UUID>
map_type_code: ALIGN_WITH
comment: "Game Designer aligns with Product Designer for reporting"
```

#### JobXMap

**Definition:** Cross-tree job mapping for reporting consolidation.

**Purpose:** Maps BU-specific jobs to corporate jobs for headcount and compensation reporting.

**Key Attributes:**

| Attribute | Type | Description |
|-----------|------|-------------|
| `src_job_id` | UUID | Source job (BU tree) |
| `target_job_id` | UUID | Target job (corporate tree) |
| `map_type_code` | enum | ALIGN_WITH, DUPLICATE_OF |

**Example:**
```yaml
# BU Gaming Senior Engineer maps to Corporate Senior Engineer
src_job_id: <BU_GAMING_SR_ENG_UUID>
target_job_id: <CORP_SR_ENG_UUID>
map_type_code: ALIGN_WITH
comment: "Gaming Senior Engineer aligns with Corporate Senior Engineer"
```

#### JobTaxonomyMap

**Definition:** Many-to-many relationship between jobs and taxonomy nodes.

**Purpose:** Allows a job to belong to multiple taxonomy classifications simultaneously (e.g., Technical + Management).

**Key Attributes:**

| Attribute | Type | Description |
|-----------|------|-------------|
| `job_id` | UUID | Job reference |
| `taxonomy_id` | UUID | Taxonomy node reference |
| `is_primary` | boolean | Primary taxonomy flag |

**Example:**
```yaml
# Technical Manager belongs to both Engineering and Management taxonomies
- job_id: <TECH_MGR_UUID>
  taxonomy_id: <ENG_SW_FUNCTION_UUID>
  is_primary: true

- job_id: <TECH_MGR_UUID>
  taxonomy_id: <MGMT_FUNCTION_UUID>
  is_primary: false
```

### Migration Path

Organizations can start with simplified design and migrate to multi-tree when needed:

**Phase 1: Simplified Design (Recommended Start)**
- Implement 3-entity structure (JobTaxonomy, Job, JobProfile)
- Use single corporate taxonomy and job catalog
- Direct FK relationships (job.taxonomy_id)
- Suitable for 80% of organizations

**Phase 2: Enable Multi-Tree (When Needed)**
- Add tree containers (TaxonomyTree, JobTree)
- Migrate existing data to corporate trees
- Enable BU-specific tree creation
- Implement cross-tree mappings (XMap tables)

**Phase 3: Full Multi-Tree (Complex Organizations)**
- Create BU-specific taxonomies and job catalogs
- Implement inheritance and override mechanisms
- Enable many-to-many job-taxonomy relationships (JobTaxonomyMap)
- Full cross-tree reporting consolidation

**Migration Triggers:**
- M&A activity requiring integration of different job structures
- BU autonomy requirements for job management
- Regional variations in job definitions
- Need for independent BU job catalogs while maintaining corporate reporting

### Implementation Guidance

**Simplified Design (Primary)**:
```yaml
# Job with direct taxonomy reference
job:
  code: SR_BACKEND_ENG
  taxonomy_id: <BACKEND_FUNCTION_UUID>  # Direct FK
  level_id: <SENIOR_UUID>
  grade_id: <G7_UUID>
```

**Advanced Design (Multi-Tree)**:
```yaml
# Job in multi-tree with tree reference
job:
  code: SR_BACKEND_ENG
  tree_id: <CORP_JOBS_UUID>  # Tree container
  taxonomy_id: <BACKEND_FUNCTION_UUID>
  owner_scope: CORP
  level_id: <SENIOR_UUID>
  grade_id: <G7_UUID>

# Cross-tree mapping for BU job
job_xmap:
  src_job_id: <BU_GAMING_SR_ENG_UUID>
  target_job_id: <CORP_SR_ENG_UUID>
  map_type_code: ALIGN_WITH
```

For detailed implementation guidance, see [Multi-Tree Architecture Guide](../01-concept/03-job-position-guide.md#advanced-multi-tree-architecture).

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | 2025-12-01 | Added multi-tree support, staffing models |
| 1.0 | 2025-11-01 | Initial job-position ontology |
