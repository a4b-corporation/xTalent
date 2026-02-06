# Job & Position Scenarios - Core Module

**Version**: 2.0  
**Last Updated**: 2025-12-03  
**Module**: Core (CO)  
**Status**: Complete - Job & Position Management Workflows

---

## 📋 Overview

This document defines detailed end-to-end scenarios for job taxonomy, job profiles, and position management in the Core Module. Each scenario provides step-by-step workflows for creating jobs, managing positions, and maintaining job profiles.

### Scenario Categories

1. **Job Taxonomy Scenarios** - Building job classification structures
2. **Job Profile Scenarios** - Defining job requirements and expectations
3. **Position Management Scenarios** - Managing approved headcount
4. **Job Catalog Scenarios** - Maintaining job inventory
5. **Position-Based vs Job-Based Scenarios** - Staffing model operations

---

## 🏗️ Scenario 1: Build Job Taxonomy Structure

### Overview

**Scenario**: Create a complete job taxonomy for Engineering department

**Actors**:
- HR Administrator
- Compensation & Benefits Manager
- Department Head

**Preconditions**:
- Organization structure exists
- Job families identified
- Job levels defined
- Grading structure approved

---

### Main Flow

#### Step 1: Create Taxonomy Tree

**Actor**: HR Administrator

**Action**: Create functional taxonomy tree for Engineering

**Input Data**:
```json
{
  "code": "FUNCTIONAL",
  "name": "Functional Job Taxonomy",
  "description": "Jobs organized by functional area",
  "tree_type": "FUNCTIONAL",
  "is_primary": true
}
```

**API Call**:
```http
POST /api/v1/taxonomy-trees
Authorization: Bearer {token}
Content-Type: application/json
```

**Business Rules Applied**:
- BR-TAX-001: Taxonomy Tree Uniqueness

**Expected Output**:
```json
{
  "id": "tree-uuid-functional",
  "code": "FUNCTIONAL",
  "name": "Functional Job Taxonomy",
  "tree_type": "FUNCTIONAL",
  "created_at": "2025-01-01T09:00:00Z"
}
```

**Data Changes**:
- `taxonomy_trees` table: INSERT 1 row

---

#### Step 2: Create Job Family (Level 1)

**Actor**: HR Administrator

**Action**: Create Engineering job family

**Input Data**:
```json
{
  "taxonomy_tree_id": "tree-uuid-functional",
  "code": "ENG",
  "name": "Engineering",
  "parent_taxonomy_id": null,
  "description": "Engineering and technology roles",
  "sort_order": 1
}
```

**API Call**:
```http
POST /api/v1/job-taxonomies
```

**Business Rules Applied**:
- BR-TAX-002: Job Taxonomy Hierarchy

**Expected Output**:
```json
{
  "id": "tax-uuid-eng",
  "code": "ENG",
  "name": "Engineering",
  "hierarchy_level": 1,
  "hierarchy_path": "/tax-uuid-eng/",
  "created_at": "2025-01-01T09:05:00Z"
}
```

---

#### Step 3: Create Job Sub-Families (Level 2)

**Actor**: HR Administrator

**Action**: Create engineering specializations

**Input Data** (Software Engineering):
```json
{
  "taxonomy_tree_id": "tree-uuid-functional",
  "code": "ENG-SW",
  "name": "Software Engineering",
  "parent_taxonomy_id": "tax-uuid-eng",
  "description": "Software development roles",
  "sort_order": 1
}
```

**API Call**:
```http
POST /api/v1/job-taxonomies
```

**Expected Output**:
```json
{
  "id": "tax-uuid-eng-sw",
  "code": "ENG-SW",
  "name": "Software Engineering",
  "hierarchy_level": 2,
  "hierarchy_path": "/tax-uuid-eng/tax-uuid-eng-sw/",
  "parent": "Engineering"
}
```

**Repeat for other sub-families**:
- ENG-QA: Quality Assurance
- ENG-DATA: Data Engineering
- ENG-DEVOPS: DevOps Engineering
- ENG-SEC: Security Engineering

**Data Changes**:
- `job_taxonomies` table: INSERT 5 rows

---

#### Step 4: Create Jobs (Level 3)

**Actor**: HR Administrator

**Action**: Create specific jobs under Software Engineering

**Input Data** (Senior Software Engineer):
```json
{
  "code": "SWE-SR",
  "title": "Senior Software Engineer",
  "job_taxonomy_id": "tax-uuid-eng-sw",
  "job_level": "SENIOR",
  "job_grade": "G7",
  "job_family": "Software Engineering",
  "flsa_status": "EXEMPT",
  "description": "Senior-level software engineering role"
}
```

**API Call**:
```http
POST /api/v1/jobs
```

**Business Rules Applied**:
- BR-TAX-005: Job Creation Validation

**Expected Output**:
```json
{
  "id": "job-uuid-swe-sr",
  "code": "SWE-SR",
  "title": "Senior Software Engineer",
  "job_level": "SENIOR",
  "job_grade": "G7",
  "job_family": "Software Engineering",
  "created_at": "2025-01-01T09:15:00Z"
}
```

**Create complete job ladder**:
```json
[
  {
    "code": "SWE-JR",
    "title": "Junior Software Engineer",
    "job_level": "JUNIOR",
    "job_grade": "G4"
  },
  {
    "code": "SWE-MID",
    "title": "Software Engineer",
    "job_level": "MID",
    "job_grade": "G5"
  },
  {
    "code": "SWE-SR",
    "title": "Senior Software Engineer",
    "job_level": "SENIOR",
    "job_grade": "G7"
  },
  {
    "code": "SWE-LEAD",
    "title": "Lead Software Engineer",
    "job_level": "LEAD",
    "job_grade": "G8"
  },
  {
    "code": "SWE-STAFF",
    "title": "Staff Software Engineer",
    "job_level": "STAFF",
    "job_grade": "G9"
  }
]
```

**Data Changes**:
- `jobs` table: INSERT 5 rows (complete career ladder)

---

#### Step 5: Verify Taxonomy Structure

**Actor**: HR Administrator

**Action**: Get complete taxonomy tree

**API Call**:
```http
GET /api/v1/taxonomy-trees/tree-uuid-functional/hierarchy
```

**Expected Output**:
```json
{
  "tree": {
    "code": "FUNCTIONAL",
    "name": "Functional Job Taxonomy",
    "families": [
      {
        "code": "ENG",
        "name": "Engineering",
        "sub_families": [
          {
            "code": "ENG-SW",
            "name": "Software Engineering",
            "jobs": [
              {"code": "SWE-JR", "title": "Junior Software Engineer", "grade": "G4"},
              {"code": "SWE-MID", "title": "Software Engineer", "grade": "G5"},
              {"code": "SWE-SR", "title": "Senior Software Engineer", "grade": "G7"},
              {"code": "SWE-LEAD", "title": "Lead Software Engineer", "grade": "G8"},
              {"code": "SWE-STAFF", "title": "Staff Software Engineer", "grade": "G9"}
            ]
          },
          {
            "code": "ENG-QA",
            "name": "Quality Assurance",
            "jobs": [...]
          }
        ]
      }
    ]
  }
}
```

---

### Postconditions

**System State**:
- ✅ Taxonomy tree created (FUNCTIONAL)
- ✅ Job family created (Engineering)
- ✅ 5 sub-families created
- ✅ 25+ jobs created (5 per sub-family)
- ✅ Complete career ladders defined
- ✅ Hierarchy paths calculated
- ✅ Ready for job profiles

**Data Summary**:
- Taxonomy Trees: +1
- Job Taxonomies: +6 (1 family + 5 sub-families)
- Jobs: +25
- Audit Logs: +32

---

## 📝 Scenario 2: Create Comprehensive Job Profile

### Overview

**Scenario**: Create detailed job profile for Senior Software Engineer

**Actors**:
- HR Administrator
- Hiring Manager
- Compensation Specialist

**Preconditions**:
- Job exists in taxonomy
- Skill catalog exists
- Competency framework defined

---

### Main Flow

#### Step 1: Create Base Job Profile

**Actor**: HR Administrator

**Action**: Create job profile with basic information

**Input Data**:
```json
{
  "job_id": "job-uuid-swe-sr",
  "job_description": "Design, develop, and maintain complex software systems. Mentor junior engineers and contribute to technical architecture decisions.",
  "job_purpose": "Deliver high-quality software solutions that meet business requirements while maintaining technical excellence and mentoring team members.",
  "key_responsibilities": [
    "Design and implement complex software features",
    "Write clean, maintainable, and well-tested code",
    "Conduct code reviews and provide technical guidance",
    "Mentor junior and mid-level engineers",
    "Participate in architecture and design discussions",
    "Contribute to technical documentation",
    "Collaborate with product and design teams"
  ],
  "effective_start_date": "2025-01-01"
}
```

**API Call**:
```http
POST /api/v1/job-profiles
```

**Business Rules Applied**:
- BR-PRF-001: Job Profile Creation

**Expected Output**:
```json
{
  "id": "profile-uuid-swe-sr",
  "job_id": "job-uuid-swe-sr",
  "job_code": "SWE-SR",
  "job_title": "Senior Software Engineer",
  "version": 1,
  "is_current": true,
  "created_at": "2025-01-01T10:00:00Z"
}
```

---

#### Step 2: Add Required Skills

**Actor**: HR Administrator

**Action**: Define required technical and soft skills

**Input Data**:
```json
{
  "job_profile_id": "profile-uuid-swe-sr",
  "skills": [
    {
      "skill_id": "skill-uuid-python",
      "skill_name": "Python Programming",
      "proficiency_level": "ADVANCED",
      "is_required": true,
      "skill_category": "TECHNICAL"
    },
    {
      "skill_id": "skill-uuid-sql",
      "skill_name": "SQL & Database Design",
      "proficiency_level": "ADVANCED",
      "is_required": true,
      "skill_category": "TECHNICAL"
    },
    {
      "skill_id": "skill-uuid-system-design",
      "skill_name": "System Design",
      "proficiency_level": "ADVANCED",
      "is_required": true,
      "skill_category": "TECHNICAL"
    },
    {
      "skill_id": "skill-uuid-leadership",
      "skill_name": "Technical Leadership",
      "proficiency_level": "INTERMEDIATE",
      "is_required": true,
      "skill_category": "SOFT_SKILL"
    },
    {
      "skill_id": "skill-uuid-communication",
      "skill_name": "Communication",
      "proficiency_level": "ADVANCED",
      "is_required": true,
      "skill_category": "SOFT_SKILL"
    },
    {
      "skill_id": "skill-uuid-kubernetes",
      "skill_name": "Kubernetes",
      "proficiency_level": "INTERMEDIATE",
      "is_required": false,
      "skill_category": "TECHNICAL"
    }
  ]
}
```

**API Call**:
```http
POST /api/v1/job-profiles/{profileId}/skills
```

**Business Rules Applied**:
- BR-PRF-020: Job Profile Skills

**Expected Output**:
```json
{
  "job_profile_id": "profile-uuid-swe-sr",
  "skills_added": 6,
  "required_skills": 5,
  "preferred_skills": 1,
  "updated_at": "2025-01-01T10:05:00Z"
}
```

---

#### Step 3: Add Education Requirements

**Actor**: HR Administrator

**Action**: Define education and certification requirements

**Input Data**:
```json
{
  "job_profile_id": "profile-uuid-swe-sr",
  "education_requirements": [
    {
      "degree_level": "BACHELOR",
      "field_of_study": "Computer Science, Software Engineering, or related field",
      "is_required": true
    },
    {
      "degree_level": "MASTER",
      "field_of_study": "Computer Science",
      "is_required": false
    }
  ],
  "certifications": [
    {
      "certification_name": "AWS Certified Solutions Architect",
      "is_required": false,
      "is_preferred": true
    }
  ]
}
```

**API Call**:
```http
POST /api/v1/job-profiles/{profileId}/education
```

---

#### Step 4: Add Experience Requirements

**Actor**: HR Administrator

**Action**: Define experience requirements

**Input Data**:
```json
{
  "job_profile_id": "profile-uuid-swe-sr",
  "minimum_years_experience": 5,
  "preferred_years_experience": 7,
  "experience_requirements": [
    "5+ years of professional software development experience",
    "Experience with modern web frameworks and technologies",
    "Experience with cloud platforms (AWS, GCP, or Azure)",
    "Experience mentoring junior engineers",
    "Experience with agile development methodologies"
  ]
}
```

**API Call**:
```http
POST /api/v1/job-profiles/{profileId}/experience
```

---

#### Step 5: Add Competencies

**Actor**: HR Administrator

**Action**: Define behavioral competencies

**Input Data**:
```json
{
  "job_profile_id": "profile-uuid-swe-sr",
  "competencies": [
    {
      "competency_id": "comp-uuid-problem-solving",
      "competency_name": "Problem Solving",
      "proficiency_level": "ADVANCED",
      "is_required": true
    },
    {
      "competency_id": "comp-uuid-collaboration",
      "competency_name": "Collaboration",
      "proficiency_level": "ADVANCED",
      "is_required": true
    },
    {
      "competency_id": "comp-uuid-innovation",
      "competency_name": "Innovation",
      "proficiency_level": "INTERMEDIATE",
      "is_required": true
    }
  ]
}
```

**API Call**:
```http
POST /api/v1/job-profiles/{profileId}/competencies
```

---

#### Step 6: Review and Publish

**Actor**: HR Administrator

**Action**: Review complete profile and publish

**API Call**:
```http
GET /api/v1/job-profiles/{profileId}/complete
```

**Expected Output**:
```json
{
  "job_profile": {
    "id": "profile-uuid-swe-sr",
    "job_code": "SWE-SR",
    "job_title": "Senior Software Engineer",
    "version": 1,
    "status": "PUBLISHED",
    "job_description": "...",
    "key_responsibilities": [...],
    "required_skills": 5,
    "preferred_skills": 1,
    "education_requirements": 1,
    "minimum_experience": 5,
    "competencies": 3,
    "completeness": 100
  }
}
```

**Publish Profile**:
```http
POST /api/v1/job-profiles/{profileId}/publish
```

---

### Postconditions

**System State**:
- ✅ Job profile created and published
- ✅ 6 skills defined (5 required, 1 preferred)
- ✅ Education requirements defined
- ✅ Experience requirements defined
- ✅ 3 competencies defined
- ✅ Profile 100% complete
- ✅ Ready for recruitment and talent matching

**Data Summary**:
- Job Profiles: +1
- Job Profile Skills: +6
- Job Profile Education: +2
- Job Profile Competencies: +3
- Audit Logs: +5

---

## 📍 Scenario 3: Position Management (Position-Based Staffing)

### Overview

**Scenario**: Create and manage positions for headcount control

**Actors**:
- HR Administrator
- Finance Manager
- Department Head

**Preconditions**:
- Budget approved
- Jobs defined
- Business units exist
- Headcount plan approved

---

### Main Flow

#### Step 1: Create Approved Positions

**Actor**: HR Administrator

**Action**: Create positions based on approved headcount

**Input Data** (Position 1):
```json
{
  "code": "POS-ENG-BE-001",
  "title": "Senior Backend Engineer - Payments Team",
  "job_id": "job-uuid-swe-sr",
  "business_unit_id": "bu-uuid-eng-backend",
  "location_id": "loc-uuid-hcm",
  "status": "VACANT",
  "headcount_limit": 1,
  "cost_center": "CC-ENG-BACKEND",
  "effective_start_date": "2025-01-01",
  "budget_approved": true,
  "requisition_id": "REQ-2025-001"
}
```

**API Call**:
```http
POST /api/v1/positions
```

**Business Rules Applied**:
- BR-POS-001: Position Creation
- BR-POS-002: Position Status Validation

**Expected Output**:
```json
{
  "id": "pos-uuid-001",
  "code": "POS-ENG-BE-001",
  "title": "Senior Backend Engineer - Payments Team",
  "job_code": "SWE-SR",
  "business_unit": "Backend Engineering",
  "status": "VACANT",
  "created_at": "2025-01-01T11:00:00Z"
}
```

**Create multiple positions**:
```json
[
  {
    "code": "POS-ENG-BE-001",
    "title": "Senior Backend Engineer - Payments",
    "status": "VACANT"
  },
  {
    "code": "POS-ENG-BE-002",
    "title": "Senior Backend Engineer - Core Platform",
    "status": "VACANT"
  },
  {
    "code": "POS-ENG-FE-001",
    "title": "Senior Frontend Engineer - Web",
    "status": "VACANT"
  }
]
```

**Data Changes**:
- `positions` table: INSERT 3 rows

---

#### Step 2: Fill Position (Hire)

**Actor**: HR Administrator

**Action**: Assign employee to vacant position

**Process**:
1. Employee hired (see Employment Scenarios)
2. Assignment created with position_id
3. Position status updated to FILLED

**API Call**:
```http
POST /api/v1/assignments
{
  "employee_id": "emp-uuid-001",
  "position_id": "pos-uuid-001",
  "staffing_model": "POSITION_BASED",
  ...
}
```

**Expected Result**:
```json
{
  "assignment_id": "asg-uuid-001",
  "position_id": "pos-uuid-001",
  "position_status": "FILLED",
  "filled_date": "2025-01-15"
}
```

**Data Changes**:
- `positions` table: UPDATE 1 row (status → FILLED)
- `assignments` table: INSERT 1 row

---

#### Step 3: Freeze Position (Budget Hold)

**Actor**: HR Administrator

**Action**: Freeze vacant position due to budget constraints

**Input Data**:
```json
{
  "position_id": "pos-uuid-002",
  "freeze_reason": "Budget freeze Q1 2025",
  "freeze_date": "2025-02-01",
  "expected_unfreeze_date": "2025-04-01"
}
```

**API Call**:
```http
POST /api/v1/positions/{posId}/freeze
```

**Business Rules Applied**:
- BR-POS-021: Position Freeze Validation

**Expected Output**:
```json
{
  "position_id": "pos-uuid-002",
  "status": "FROZEN",
  "freeze_date": "2025-02-01",
  "freeze_reason": "Budget freeze Q1 2025",
  "can_be_filled": false
}
```

---

#### Step 4: Unfreeze Position

**Actor**: HR Administrator

**Action**: Unfreeze position when budget available

**API Call**:
```http
POST /api/v1/positions/{posId}/unfreeze
```

**Expected Output**:
```json
{
  "position_id": "pos-uuid-002",
  "status": "VACANT",
  "unfroze_date": "2025-04-01",
  "can_be_filled": true
}
```

---

#### Step 5: Eliminate Position

**Actor**: HR Administrator

**Action**: Permanently eliminate position (no longer needed)

**Input Data**:
```json
{
  "position_id": "pos-uuid-003",
  "elimination_reason": "Role no longer needed after automation",
  "elimination_date": "2025-06-30"
}
```

**API Call**:
```http
POST /api/v1/positions/{posId}/eliminate
```

**Business Rules Applied**:
- Position must be VACANT
- Cannot be reactivated after elimination

**Expected Output**:
```json
{
  "position_id": "pos-uuid-003",
  "status": "ELIMINATED",
  "elimination_date": "2025-06-30",
  "can_be_filled": false,
  "is_final": true
}
```

---

#### Step 6: Position Vacancy Report

**Actor**: HR Administrator

**Action**: Get vacancy report for planning

**API Call**:
```http
GET /api/v1/reports/vacancies?business_unit_id=bu-uuid-eng-backend
```

**Expected Output**:
```json
{
  "business_unit": "Backend Engineering",
  "report_date": "2025-12-03",
  "summary": {
    "total_positions": 10,
    "filled": 7,
    "vacant": 2,
    "frozen": 1,
    "eliminated": 0
  },
  "vacancies": [
    {
      "position_code": "POS-ENG-BE-002",
      "position_title": "Senior Backend Engineer - Core Platform",
      "job_title": "Senior Software Engineer",
      "status": "VACANT",
      "vacant_since": "2025-01-01",
      "vacancy_duration_days": 335,
      "is_critical": true,
      "requisition_id": "REQ-2025-002"
    }
  ]
}
```

---

### Postconditions

**System State**:
- ✅ 3 positions created
- ✅ 1 position filled
- ✅ 1 position frozen
- ✅ 1 position eliminated
- ✅ Vacancy tracking active
- ✅ Headcount controlled

**Data Summary**:
- Positions: +3
- Position Status Changes: 3
- Audit Logs: +6

---

## 🔄 Scenario 4: Job-Based vs Position-Based Comparison

### Overview

**Scenario**: Compare staffing models for different scenarios

---

### Position-Based Staffing

**Use Case**: Strict headcount control, budget management

**Characteristics**:
- ✅ Each position must be approved
- ✅ Budget tied to position
- ✅ Vacancy tracking built-in
- ✅ Headcount limit enforced
- ✅ Position can be frozen/eliminated

**Example**:
```json
{
  "staffing_model": "POSITION_BASED",
  "position_id": "pos-uuid-001",
  "position_code": "POS-ENG-001",
  "position_title": "Senior Software Engineer - Payments",
  "job_id": "job-uuid-swe-sr",
  "status": "VACANT",
  "headcount_limit": 1
}
```

**Assignment Creation**:
```http
POST /api/v1/assignments
{
  "employee_id": "emp-uuid-001",
  "staffing_model": "POSITION_BASED",
  "position_id": "pos-uuid-001",
  "job_id": "job-uuid-swe-sr"
}
```

---

### Job-Based Staffing

**Use Case**: Flexible staffing, rapid growth, consulting firms

**Characteristics**:
- ✅ No position approval needed
- ✅ Flexible headcount
- ✅ Faster hiring
- ✅ No vacancy tracking
- ✅ Budget managed at job level

**Example**:
```json
{
  "staffing_model": "JOB_BASED",
  "position_id": null,
  "job_id": "job-uuid-swe-sr",
  "job_title": "Senior Software Engineer"
}
```

**Assignment Creation**:
```http
POST /api/v1/assignments
{
  "employee_id": "emp-uuid-001",
  "staffing_model": "JOB_BASED",
  "job_id": "job-uuid-swe-sr",
  "business_unit_id": "bu-uuid-eng-backend"
}
```

---

### Comparison Table

| Aspect | Position-Based | Job-Based |
|--------|----------------|-----------|
| **Headcount Control** | Strict (per position) | Flexible (per job/BU) |
| **Budget Control** | Position-level | Job/BU-level |
| **Approval Process** | Position approval required | No position approval |
| **Vacancy Tracking** | Built-in | Manual |
| **Hiring Speed** | Slower (position approval) | Faster |
| **Use Cases** | Large enterprises, government | Startups, consulting, rapid growth |
| **Complexity** | Higher | Lower |

---

## 📊 Scenario 5: Job Catalog Management

### Overview

**Scenario**: Maintain and update job catalog

**Actors**:
- HR Administrator
- Compensation Team

---

### Main Flow

#### Step 1: Job Catalog Export

**Actor**: HR Administrator

**Action**: Export complete job catalog

**API Call**:
```http
GET /api/v1/jobs/catalog/export?format=EXCEL
```

**Expected Output**:
```
Excel file with columns:
- Job Code
- Job Title
- Job Family
- Job Level
- Job Grade
- FLSA Status
- Active Positions
- Current Headcount
- Salary Range
- Last Updated
```

---

#### Step 2: Bulk Job Update

**Actor**: HR Administrator

**Action**: Update multiple jobs (e.g., grade changes)

**Input Data**:
```json
{
  "updates": [
    {
      "job_id": "job-uuid-swe-sr",
      "job_grade": "G8",
      "effective_date": "2025-07-01",
      "reason": "Market adjustment"
    },
    {
      "job_id": "job-uuid-swe-lead",
      "job_grade": "G9",
      "effective_date": "2025-07-01",
      "reason": "Market adjustment"
    }
  ]
}
```

**API Call**:
```http
POST /api/v1/jobs/bulk-update
```

**Business Rules Applied**:
- SCD Type 2: Previous versions retained
- Effective dating applied

---

#### Step 3: Job Deactivation

**Actor**: HR Administrator

**Action**: Deactivate obsolete job

**Input Data**:
```json
{
  "job_id": "job-uuid-old-role",
  "deactivation_date": "2025-12-31",
  "reason": "Role no longer needed",
  "replacement_job_id": "job-uuid-new-role"
}
```

**API Call**:
```http
POST /api/v1/jobs/{jobId}/deactivate
```

**Validation**:
- No active positions
- No active assignments
- Replacement job suggested

---

### Postconditions

**System State**:
- ✅ Job catalog exported
- ✅ Bulk updates applied
- ✅ Obsolete jobs deactivated
- ✅ Historical data preserved

---

## 📊 Scenario Summary

### Scenarios Covered

| Scenario | Complexity | Actors | Steps | Business Rules |
|----------|------------|--------|-------|----------------|
| **Build Job Taxonomy** | High | 3 | 5 | 3 |
| **Create Job Profile** | Medium | 3 | 6 | 2 |
| **Position Management** | Medium | 3 | 6 | 3 |
| **Staffing Model Comparison** | Low | - | - | 2 |
| **Job Catalog Management** | Low | 2 | 3 | 1 |

### Key Operations Covered

**Job Taxonomy**:
- ✅ Create taxonomy tree
- ✅ Build job families (3 levels)
- ✅ Create jobs with career ladders
- ✅ Verify hierarchy structure

**Job Profiles**:
- ✅ Create comprehensive profile
- ✅ Add required skills
- ✅ Define education requirements
- ✅ Specify experience requirements
- ✅ Add competencies
- ✅ Publish profile

**Position Management**:
- ✅ Create positions
- ✅ Fill positions
- ✅ Freeze positions
- ✅ Unfreeze positions
- ✅ Eliminate positions
- ✅ Vacancy reporting

**Staffing Models**:
- ✅ Position-based staffing
- ✅ Job-based staffing
- ✅ Model comparison

**Job Catalog**:
- ✅ Export catalog
- ✅ Bulk updates
- ✅ Job deactivation

---

## 🔗 Related Documentation

- [Functional Requirements](../01-functional-requirements.md) - Job, Position FRs
- [Business Rules](../04-business-rules.md) - BR-TAX, BR-PRF, BR-POS rules
- [API Specification](../02-api-specification.md) - Job & Position APIs
- [Job Architecture Guide](../../01-concept/04-job-architecture-guide.md) - Concepts

---

**Document Version**: 2.0  
**Created**: 2025-12-03  
**Scenarios**: 5 detailed job & position workflows  
**Maintained By**: Product Team + Business Analysts  
**Status**: Complete - Ready for Implementation
