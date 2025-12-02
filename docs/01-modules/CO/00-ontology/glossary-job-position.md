# Job & Position Glossary

## Overview

This glossary defines the job and position structure entities used in the xTalent HCM system. The job-position model supports flexible organizational design with multi-tree taxonomy, job hierarchies, and both position-based and job-based staffing models.

---

## Architecture

The Job & Position module uses a **multi-tree architecture** that supports:

1. **Corporate Job Tree:** Enterprise-wide job catalog
2. **Business Unit Job Trees:** BU-specific job structures
3. **Cross-tree Mapping:** Consolidation and reporting across trees

This design enables:
- Centralized job standards with local flexibility
- Independent BU job management
- Consolidated enterprise reporting
- Support for M&A integration

---

## Entities

### TaxonomyTree

**Definition:** Container for independent job taxonomy hierarchies. Enables multiple job classification systems to coexist (corporate vs. business unit specific).

**Purpose:**
- Support multiple independent job taxonomies
- Enable corporate and BU-specific classifications
- Facilitate M&A integration
- Provide flexibility for different organizational models

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `code` | string(50) | Yes | Tree code (e.g., CORP, BU_SALES, BU_TECH) |
| `name` | string(150) | No | Tree name |
| `tree_type` | enum | Yes | CORPORATE, BUSINESS_UNIT, LEGACY |
| `owner_entity_id` | UUID | No | Owning legal entity or BU |
| `description` | text | No | Tree description |
| `is_active` | boolean | Yes | Active status (default: true) |
| `metadata` | jsonb | No | Tree configuration, rules |
| `effective_start_date` | date | Yes | Effective start date |
| `effective_end_date` | date | No | Effective end date |
| `is_current_flag` | boolean | Yes | Current record indicator |

**Tree Types:**

| Type | Description | Use Case |
|------|-------------|----------|
| `CORPORATE` | Enterprise-wide taxonomy | Global job standards |
| `BUSINESS_UNIT` | BU-specific taxonomy | Local job structures |
| `LEGACY` | Legacy system taxonomy | M&A integration |
| `CUSTOM` | Custom taxonomy | Special purposes |

**Metadata Structure:**
```json
{
  "classification_system": "O*NET",
  "version": "2.0",
  "max_depth": 5,
  "allow_cross_tree_mapping": true,
  "consolidation_rules": {
    "map_to_corporate": true,
    "reporting_tree": "CORP"
  },
  "approval_required": true
}
```

**Relationships:**
- **Has many** `JobTaxonomy` (taxonomy nodes)
- **Has many** `JobTree` (job trees)

**Business Rules:**
- Tree code must be unique
- One corporate tree recommended
- Multiple BU trees allowed
- Cross-tree mapping via xmap tables

**Example:**

```yaml
# Corporate Taxonomy Tree
id: tree_corp_001
code: CORP
name: Corporate Job Taxonomy
tree_type: CORPORATE
owner_entity_id: entity_holding
is_active: true
metadata:
  classification_system: "O*NET"
  max_depth: 5

# Business Unit Taxonomy Tree
id: tree_bu_tech_001
code: BU_TECH
name: Technology Division Job Taxonomy
tree_type: BUSINESS_UNIT
owner_entity_id: bu_technology
is_active: true
```

---

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
| `tree_id` | UUID | Yes | Taxonomy tree reference |
| `parent_id` | UUID | No | Parent taxonomy node |
| `code` | string(50) | Yes | Taxonomy code |
| `name` | string(150) | No | Taxonomy name |
| `level` | integer | No | Hierarchy level (1=top, 2=mid, 3=bottom) |
| `path` | string(255) | No | Materialized path |
| `description` | text | No | Taxonomy description |
| `metadata` | jsonb | No | Additional classification data |
| `effective_start_date` | date | Yes | Effective start date |
| `effective_end_date` | date | No | Effective end date |
| `is_current_flag` | boolean | Yes | Current record indicator |

**Taxonomy Levels:**

| Level | Name | Description | Example |
|-------|------|-------------|---------|
| 1 | Job Family | Broad occupational group | Engineering |
| 2 | Job Function | Specific function area | Software Engineering |
| 3 | Job Category | Detailed category | Backend Development |

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
- **Belongs to** `TaxonomyTree`
- **Belongs to** `JobTaxonomy` (parent)
- **Has many** `JobTaxonomy` (children)
- **Has many** `Job` (jobs in this taxonomy)

**Business Rules:**
- Code must be unique within tree
- Path must reflect hierarchy
- Maximum 5 levels recommended
- SCD Type 2 for historical tracking

**Example:**

```yaml
# Level 1: Job Family
id: tax_eng_001
tree_id: tree_corp_001
parent_id: null
code: ENG
name: Engineering
level: 1
path: /ENG

# Level 2: Job Function
id: tax_sw_eng_001
tree_id: tree_corp_001
parent_id: tax_eng_001
code: SW_ENG
name: Software Engineering
level: 2
path: /ENG/SW_ENG

# Level 3: Job Category
id: tax_backend_001
tree_id: tree_corp_001
parent_id: tax_sw_eng_001
code: BACKEND
name: Backend Development
level: 3
path: /ENG/SW_ENG/BACKEND
```

---

### JobTree

**Definition:** Container for independent job hierarchies. Similar to TaxonomyTree but specifically for job structures.

**Purpose:**
- Support multiple independent job hierarchies
- Enable corporate and BU-specific job catalogs
- Facilitate decentralized job management
- Support M&A integration

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `code` | string(50) | Yes | Job tree code |
| `name` | string(150) | No | Job tree name |
| `tree_type` | enum | Yes | CORPORATE, BUSINESS_UNIT, LEGACY |
| `owner_entity_id` | UUID | No | Owning legal entity or BU |
| `taxonomy_tree_id` | UUID | No | Associated taxonomy tree |
| `is_active` | boolean | Yes | Active status |
| `metadata` | jsonb | No | Tree configuration |
| `effective_start_date` | date | Yes | Effective start date |
| `effective_end_date` | date | No | Effective end date |
| `is_current_flag` | boolean | Yes | Current record indicator |

**Relationships:**
- **References** `TaxonomyTree` (optional)
- **Has many** `Job` (jobs in this tree)

**Business Rules:**
- Job tree code must be unique
- Jobs can inherit from parent jobs
- Cross-tree mapping supported via xmap tables

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
| `id` | UUID | Yes | Unique identifier |
| `tree_id` | UUID | Yes | Job tree reference |
| `parent_id` | UUID | No | Parent job (for hierarchy) |
| `taxonomy_id` | UUID | No | Job taxonomy classification |
| `code` | string(50) | Yes | Job code |
| `title` | string(150) | No | Job title |
| `level_id` | UUID | No | Job level reference |
| `grade_id` | UUID | No | Job grade reference |
| `job_family_code` | string(50) | No | Job family code |
| `job_function_code` | string(50) | No | Job function code |
| `flsa_status` | enum | No | EXEMPT, NON_EXEMPT (US classification) |
| `is_manager` | boolean | No | Manager role indicator |
| `description` | text | No | Job description |
| `metadata` | jsonb | No | Additional job attributes |
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
}
```

**Relationships:**
- **Belongs to** `JobTree`
- **Belongs to** `Job` (parent job)
- **Belongs to** `JobTaxonomy`
- **Belongs to** `JobLevel`
- **Belongs to** `JobGrade`
- **Has one** `JobProfile` (detailed profile)
- **Has many** `Position` (position instances)
- **Has many** `Assignment` (direct job assignments in JOB_BASED model)

**Business Rules:**
- Job code must be unique within tree
- Can inherit from parent job
- SCD Type 2 for historical tracking
- Job profile provides extended details

**Example:**

```yaml
id: job_senior_backend_001
tree_id: tree_corp_001
parent_id: job_backend_eng_001
taxonomy_id: tax_backend_001
code: SR_BACKEND_ENG
title: Senior Backend Engineer
level_id: level_senior
grade_id: grade_p3
job_family_code: ENG
job_function_code: SW_ENG
flsa_status: EXEMPT
is_manager: false
description: "Designs and develops scalable backend services..."
```

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

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | 2025-12-01 | Added multi-tree support, staffing models |
| 1.0 | 2025-11-01 | Initial job-position ontology |
