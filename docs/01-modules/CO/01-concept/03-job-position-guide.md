# Job & Position Management Guide

**Version**: 2.1  
**Last Updated**: 2025-12-17  
**Audience**: HR Administrators, Hiring Managers, Talent Acquisition  
**Reading Time**: 45-60 minutes

**Changelog v2.1**: Added Position Override Rules section and clarification on Position-Job relationship

---

## 📋 Overview

This guide explains how jobs and positions are structured in xTalent Core Module, covering job taxonomy, job profiles, position management, and the critical distinction between position-based and job-based staffing models.

### What You'll Learn
- The difference between Job and Position
- How to build job taxonomies and hierarchies
- Creating comprehensive job profiles
- Position-based vs job-based staffing models
- Job levels and grades for compensation

### Prerequisites
- Understanding of organizational structure
- Basic HR terminology (job description, position, etc.)
- Familiarity with recruitment processes

---

## 🎯 Core Concepts: Job vs Position

### The Fundamental Distinction

```
┌─────────────────────────────────────────────────┐
│ JOB (Template/Definition)                       │
│ "What work needs to be done?"                   │
│                                                  │
│ • Generic role definition                       │
│ • Responsibilities & requirements               │
│ • Skills & competencies needed                  │
│ • Level & grade                                 │
│ • Can be reused across organization             │
│                                                  │
│ Example: "Senior Backend Engineer"              │
└─────────────────────────────────────────────────┘
                    ↓ instantiated as
┌─────────────────────────────────────────────────┐
│ POSITION (Instance/Slot)                        │
│ "A specific headcount slot"                     │
│                                                  │
│ • Specific budgeted position                    │
│ • In a specific department                      │
│ • Reports to specific manager                   │
│ • Has specific location                         │
│ • Can be vacant or filled                       │
│                                                  │
│ Example: "POS-ENG-BACKEND-001"                  │
│ (Senior Backend Engineer in Engineering Dept)   │
└─────────────────────────────────────────────────┘
```

### Analogy: Class vs Object

**For Technical People**:
```java
// Job is like a CLASS
class SeniorBackendEngineer {
    String responsibilities;
    List<Skill> requiredSkills;
    int level;
    int grade;
}

// Position is like an OBJECT (instance)
Position pos1 = new SeniorBackendEngineer();
pos1.department = "Engineering";
pos1.manager = "Alice";
pos1.location = "HCM Office";
pos1.status = "VACANT";

Position pos2 = new SeniorBackendEngineer();
pos2.department = "Platform";
pos2.manager = "Bob";
pos2.location = "Singapore Office";
pos2.status = "FILLED";
```

**For Non-Technical People**:
- **Job** = Recipe (how to make a cake)
- **Position** = Actual cake (specific instance in your kitchen)

---

## 📊 Job Taxonomy: Organizing Jobs

### What is Job Taxonomy?

**Definition**: A hierarchical classification system for organizing jobs by family, sub-family, and function.

**Purpose**:
- ✅ Standardize job classifications
- ✅ Support career pathing
- ✅ Enable job matching and search
- ✅ Facilitate benchmarking
- ✅ Organize job catalog

### 3-Level Taxonomy Structure

```
Level 1: JOB FAMILY
  └─ Level 2: JOB SUB-FAMILY
      └─ Level 3: JOB FUNCTION
```

### Example: Technology Job Taxonomy

```
Technology (Family)
  ├─ Software Engineering (Sub-family)
  │   ├─ Backend Development (Function)
  │   ├─ Frontend Development (Function)
  │   ├─ Mobile Development (Function)
  │   └─ Full-stack Development (Function)
  │
  ├─ Data & Analytics (Sub-family)
  │   ├─ Data Engineering (Function)
  │   ├─ Data Science (Function)
  │   └─ Business Intelligence (Function)
  │
  ├─ DevOps & Infrastructure (Sub-family)
  │   ├─ DevOps Engineering (Function)
  │   ├─ Site Reliability (Function)
  │   └─ Cloud Architecture (Function)
  │
  └─ Quality Assurance (Sub-family)
      ├─ QA Engineering (Function)
      ├─ Test Automation (Function)
      └─ Performance Testing (Function)
```

### Complete Taxonomy Example

```yaml
# Level 1: Job Families
Families:
  - Technology
  - Sales & Marketing
  - Operations
  - Finance & Accounting
  - Human Resources
  - Legal & Compliance

# Level 2: Technology Sub-families
Technology:
  - Software Engineering
  - Data & Analytics
  - DevOps & Infrastructure
  - Quality Assurance
  - Product Management
  - UX/UI Design

# Level 3: Software Engineering Functions
Software Engineering:
  - Backend Development
  - Frontend Development
  - Mobile Development
  - Full-stack Development
  - Embedded Systems
  - Game Development
```

### Multi-Tree Architecture

**Key Feature**: Support both corporate-wide and BU-specific taxonomies.

```yaml
# Corporate Taxonomy (default for all BUs)
TaxonomyTree:
  code: CORP_TAX
  name: "Corporate Job Taxonomy"
  owner_type: CORPORATE
  
  # Used by all business units by default

# BU-Specific Taxonomy (overrides corporate)
TaxonomyTree:
  code: BU_ENG_TAX
  name: "Engineering Division Taxonomy"
  owner_type: BUSINESS_UNIT
  owner_id: BU-ENGINEERING
  
  # Engineering can have custom taxonomy
  # E.g., more granular engineering roles
```

**When to Use BU-Specific Taxonomy**:
- ✅ BU has unique job structures
- ✅ Industry-specific roles (e.g., Financial Services)
- ✅ Geographic variations (e.g., different countries)
- ✅ Acquired companies with different job frameworks

---

## 📊 Job Hierarchy: Job Relationships

### What is Job Hierarchy?

**Definition**: Parent-child relationships between jobs, enabling inheritance of attributes.

**Purpose**:
- ✅ Reduce duplication (inherit from parent)
- ✅ Maintain consistency
- ✅ Support career progression
- ✅ Simplify job management

### Example: Engineering Job Hierarchy

```
Software Engineer (Parent)
  ├─ Backend Engineer (Child)
  │   ├─ Junior Backend Engineer (Grandchild)
  │   ├─ Mid Backend Engineer (Grandchild)
  │   ├─ Senior Backend Engineer (Grandchild)
  │   └─ Principal Backend Engineer (Grandchild)
  │
  ├─ Frontend Engineer (Child)
  │   ├─ Junior Frontend Engineer
  │   ├─ Mid Frontend Engineer
  │   ├─ Senior Frontend Engineer
  │   └─ Principal Frontend Engineer
  │
  └─ Mobile Engineer (Child)
      ├─ Junior Mobile Engineer
      ├─ Senior Mobile Engineer
      └─ Principal Mobile Engineer
```

### Inheritance Example

```yaml
# Parent Job
Job: Software Engineer
  taxonomy: Software Engineering (Function)
  job_type: INDIVIDUAL_CONTRIBUTOR
  flsa_status: EXEMPT
  base_responsibilities:
    - "Write clean, maintainable code"
    - "Participate in code reviews"
    - "Collaborate with team members"
  base_skills:
    - Programming fundamentals
    - Version control (Git)
    - Agile methodologies

# Child Job (inherits from parent)
Job: Backend Engineer
  parent_job: Software Engineer
  # Inherits all base_responsibilities and base_skills
  additional_responsibilities:
    - "Design and implement APIs"
    - "Optimize database queries"
    - "Ensure system scalability"
  additional_skills:
    - RESTful API design
    - Database design
    - Microservices architecture

# Grandchild Job (inherits from Backend Engineer)
Job: Senior Backend Engineer
  parent_job: Backend Engineer
  level: Senior (Level 3)
  grade: Grade 7
  # Inherits everything from Backend Engineer + Software Engineer
  additional_responsibilities:
    - "Mentor junior engineers"
    - "Lead technical design discussions"
    - "Drive architectural decisions"
  additional_skills:
    - System design
    - Performance optimization
    - Leadership
```

**Benefits of Inheritance**:
- ✅ Define common attributes once (DRY principle)
- ✅ Easy to update (change parent, all children updated)
- ✅ Consistent job definitions
- ✅ Clear career progression paths

---

## 📊 Job Profile: Detailed Requirements

### What is a Job Profile?

**Definition**: Comprehensive description of job requirements, responsibilities, and expectations.

> [!IMPORTANT]
> **Job vs JobProfile Distinction**
> 
> - **Job** defines WHAT work needs to be done and its **compensation level** (grade, level)
> - **JobProfile** describes HOW to do the work (requirements, responsibilities, skills)
> - **Grade and Level are Job attributes**, not JobProfile attributes

**Components**:
1. **Summary** - Brief overview
2. **Responsibilities** - Key duties
3. **Requirements** - Education, experience, certifications
4. **Skills** - Technical skills with proficiency levels
5. **Competencies** - Behavioral competencies
6. **Physical Requirements** - Physical demands
7. **Work Environment** - Conditions, travel, etc.

**What JobProfile Does NOT Include**:
- ❌ Grade (this is on Job)
- ❌ Level (this is on Job)
- ❌ Compensation information (this is in TR module)

### Complete Job Profile Example

```yaml
Job: Senior Backend Engineer
  code: JOB-BACKEND-SENIOR
  grade_code: "G7"  # ✅ Grade is on Job
  level_code: "L3"  # ✅ Level is on Job
  
JobProfile:
  # JobProfile focuses on description, NOT compensation
  # 1. Summary
  summary: |
    Design, develop, and maintain scalable backend systems and APIs.
    Lead technical initiatives and mentor junior engineers.
    Drive architectural decisions for critical systems.
  
  # 2. Responsibilities
  responsibilities:
    primary:
      - "Design and implement RESTful APIs and microservices"
      - "Optimize database queries and system performance"
      - "Ensure code quality through reviews and testing"
      - "Mentor junior and mid-level engineers"
      - "Participate in architectural design discussions"
    
    secondary:
      - "Contribute to technical documentation"
      - "Participate in on-call rotation"
      - "Support production incidents"
  
  # 3. Requirements
  requirements:
    education:
      minimum: "Bachelor's degree in Computer Science or related field"
      preferred: "Master's degree in Computer Science"
    
    experience:
      minimum: "5+ years of backend development experience"
      preferred: "7+ years with 2+ years in senior role"
    
    certifications:
      required: []
      preferred:
        - "AWS Solutions Architect"
        - "Certified Kubernetes Administrator"
  
  # 4. Skills (with proficiency levels)
  required_skills:
    - skill: Python
      proficiency_level: 4  # Advanced (1-5 scale)
      is_mandatory: true
      
    - skill: RESTful API Design
      proficiency_level: 4
      is_mandatory: true
      
    - skill: PostgreSQL
      proficiency_level: 3  # Intermediate
      is_mandatory: true
      
    - skill: AWS
      proficiency_level: 3
      is_mandatory: true
      
    - skill: Docker
      proficiency_level: 3
      is_mandatory: true
      
    - skill: Kubernetes
      proficiency_level: 3
      is_mandatory: false  # Nice to have
      
    - skill: Redis
      proficiency_level: 2  # Basic
      is_mandatory: false
  
  # 5. Competencies (behavioral)
  required_competencies:
    - competency: Leadership
      required_level: 4
      is_mandatory: true
      
    - competency: Problem Solving
      required_level: 5  # Expert
      is_mandatory: true
      
    - competency: Communication
      required_level: 4
      is_mandatory: true
      
    - competency: Teamwork
      required_level: 4
      is_mandatory: true
  
  # 6. Physical Requirements
  physical_requirements:
    - "Ability to sit for extended periods"
    - "Ability to work on computer for 8+ hours"
    - "Minimal physical demands"
  
  # 7. Work Environment
  work_environment:
    location_type: "Hybrid (3 days office, 2 days remote)"
    travel_required: "< 10% (occasional conferences)"
    work_hours: "Flexible within core hours (10am-4pm)"
    on_call: "Participate in on-call rotation (1 week per month)"
```

### Proficiency Scales

#### Technical Skills (1-5 Scale)

| Level | Name | Description | Example |
|-------|------|-------------|---------|
| **1** | Beginner | Basic understanding, needs guidance | Can write simple Python scripts with help |
| **2** | Basic | Can work independently on simple tasks | Can implement basic CRUD APIs |
| **3** | Intermediate | Proficient, handles complex tasks | Can design microservices architecture |
| **4** | Advanced | Expert, can mentor others | Can optimize system performance, lead design |
| **5** | Expert | Authority, sets standards | Industry expert, speaks at conferences |

#### Behavioral Competencies (1-5 Scale)

| Level | Description |
|-------|-------------|
| **1** | Developing - Shows basic awareness |
| **2** | Competent - Demonstrates competency consistently |
| **3** | Proficient - Applies competency effectively |
| **4** | Advanced - Role model, mentors others |
| **5** | Expert - Thought leader, drives organizational change |

---

## 📊 Job Levels & Grades

### Job Levels (Seniority)

**Purpose**: Define career progression and seniority.

```yaml
JobLevels:
  - code: L1
    name: "Junior"
    level_order: 1
    typical_years_experience: 0-2
    is_management: false
    
  - code: L2
    name: "Mid-level"
    level_order: 2
    typical_years_experience: 2-5
    is_management: false
    
  - code: L3
    name: "Senior"
    level_order: 3
    typical_years_experience: 5-8
    is_management: false
    
  - code: L4
    name: "Principal"
    level_order: 4
    typical_years_experience: 8-12
    is_management: false
    
  - code: L5
    name: "Distinguished"
    level_order: 5
    typical_years_experience: 12+
    is_management: false
    
  # Management Track
  - code: M1
    name: "Engineering Manager"
    level_order: 3
    typical_years_experience: 5-8
    is_management: true
    
  - code: M2
    name: "Senior Engineering Manager"
    level_order: 4
    typical_years_experience: 8-12
    is_management: true
    
  - code: M3
    name: "Director of Engineering"
    level_order: 5
    typical_years_experience: 12+
    is_management: true
    is_executive: false
    
  - code: E1
    name: "VP Engineering"
    level_order: 6
    typical_years_experience: 15+
    is_management: true
    is_executive: true
```

### Job Grades (Compensation)

**Purpose**: Link jobs to salary ranges and benefits.

```yaml
JobGrades:
  - code: G5
    name: "Grade 5"
    grade_order: 5
    min_salary: 50000000  # VND
    mid_salary: 65000000
    max_salary: 80000000
    currency: VND
    
  - code: G6
    name: "Grade 6"
    grade_order: 6
    min_salary: 70000000
    mid_salary: 90000000
    max_salary: 110000000
    currency: VND
    
  - code: G7
    name: "Grade 7"
    grade_order: 7
    min_salary: 100000000
    mid_salary: 130000000
    max_salary: 160000000
    currency: VND
    
  - code: G8
    name: "Grade 8"
    grade_order: 8
    min_salary: 140000000
    mid_salary: 180000000
    max_salary: 220000000
    currency: VND
```

### Level vs Grade Mapping

```yaml
# Individual Contributor Track
Job: Junior Backend Engineer
  level: L1 (Junior)
  grade: G5
  salary_range: 50M - 80M VND

Job: Mid Backend Engineer
  level: L2 (Mid)
  grade: G6
  salary_range: 70M - 110M VND

Job: Senior Backend Engineer
  level: L3 (Senior)
  grade: G7
  salary_range: 100M - 160M VND

Job: Principal Backend Engineer
  level: L4 (Principal)
  grade: G8
  salary_range: 140M - 220M VND

# Management Track
Job: Engineering Manager
  level: M1
  grade: G7  # Same grade as Senior IC
  salary_range: 100M - 160M VND
```

**Key Insight**: Same grade can apply to different levels (IC vs Manager).

---

## 📊 Position Management

### What is a Position?

**Definition**: A specific, budgeted headcount slot for a job in a particular department.

**Key Characteristics**:
- ✅ Instance of a Job
- ✅ In a specific Business Unit
- ✅ Reports to specific manager (position)
- ✅ Has specific location
- ✅ Can be VACANT or FILLED
- ✅ Has budget approval

### Position Attributes

```yaml
Position:
  id: POS-ENG-BACKEND-001
  code: "POS-ENG-BACKEND-001"
  name: "Senior Backend Engineer - API Team"
  
  # Job reference
  job_id: JOB-BACKEND-SENIOR
  
  # Organization
  business_unit_id: BU-ENG-BACKEND
  legal_entity_code: VNG-VN
  
  # Reporting
  reports_to_position_id: POS-ENG-MGR-001
  
  # Location
  location_id: LOC-HCM-OFFICE
  
  # Headcount
  fte: 1.0  # Full-time equivalent
  max_incumbents: 1  # Typically 1
  current_incumbents: 1  # Currently filled
  
  # Status
  status: ACTIVE  # ACTIVE, FROZEN, ELIMINATED
  position_type: REGULAR  # REGULAR, TEMPORARY, CONTRACT
  
  # Budget
  is_budgeted: true
  budget_year: 2024
  cost_center_code: "CC-ENG-1000"
  
  # Hierarchy
  path: "/POS-VP-ENG/POS-DIR-ENG/POS-MGR-BACKEND/POS-ENG-BACKEND-001"
  level: 4
```

### Position Status

| Status | Description | Can Hire? |
|--------|-------------|-----------|
| **ACTIVE** | Active position, can be filled | ✅ Yes |
| **FROZEN** | Hiring freeze, cannot fill | ❌ No |
| **ELIMINATED** | Position eliminated, historical only | ❌ No |

### Position Lifecycle

```yaml
# 1. Position Created (Budget Approval)
Position: POS-ENG-001
  status: ACTIVE
  current_incumbents: 0  # Vacant
  
# 2. Position Filled (Hire)
Position: POS-ENG-001
  current_incumbents: 1  # Filled
  
Assignment:
  employee_id: EMP-001
  position_id: POS-ENG-001

# 3. Employee Leaves (Resignation)
Position: POS-ENG-001
  current_incumbents: 0  # Vacant again
  
# 4. Hiring Freeze
Position: POS-ENG-001
  status: FROZEN  # Cannot hire
  
# 5. Position Eliminated (Reorganization)
Position: POS-ENG-001
  status: ELIMINATED
  effective_end_date: 2024-12-31
  is_current: false
```

---

### Position as Job Instance: Override Rules

> [!IMPORTANT]
> **Position-Job Relationship**
> 
> - **Position = Instance of Job** in a specific organizational context
> - **Compensation attributes (grade, level) CANNOT be overridden**
> - **Organizational attributes (title, reporting) CAN be overridden**

#### What Position Inherits from Job

```yaml
Job: "Senior Software Engineer"
  grade_code: "G7"        # ✅ Position MUST inherit
  level_code: "L3"        # ✅ Position MUST inherit
  job_type: "TECH"        # ✅ Position MUST inherit
  job_title: "Senior Software Engineer"

Position: "Senior SW Engineer - AI Platform"
  job_id: JOB-001
  # Inherited (cannot override):
  grade_code: → "G7" (from job)
  level_code: → "L3" (from job)
  job_type: → "TECH" (from job)
  
  # Can override:
  title: "Senior Software Engineer - AI Platform Team"  # ✅ More specific
  reports_to_id: MGR-AI-PLATFORM  # ✅ Org-specific
  business_unit_id: BU-AI         # ✅ Org-specific
  full_time_equiv: 1.0            # ✅ Position-specific
```

#### Override Rules Quick Reference

| Attribute | Can Override? | Reason |
|-----------|---------------|--------|
| **grade_code** | ❌ NO | Compensation must be consistent |
| **level_code** | ❌ NO | Seniority is job-defined |
| **job_type** | ❌ NO | Job classification is inherent |
| **title** | ✅ YES | Can add context (team, location) |
| **reports_to_id** | ✅ YES | Org structure is position-specific |
| **business_unit_id** | ✅ YES | Position is placed in specific BU |
| **full_time_equiv** | ✅ YES | FTE can vary (0.5, 1.0, etc.) |

**For detailed override rules**, see [Position Override Rules Guide](./11-position-override-rules.md).


---

## 🔄 Staffing Models: Position-Based vs Job-Based

### The Critical Decision

**Question**: Do you manage headcount through pre-defined positions or flexible job assignments?

### Position-Based Staffing

**Definition**: Employees are assigned to specific, pre-approved budgeted positions.

**Characteristics**:
- ✅ Strict headcount control
- ✅ Budget approval required for each position
- ✅ One-to-one position-to-person mapping (typically)
- ✅ Positions form reporting hierarchy
- ✅ Vacancy tracking (open positions)

**Example**:
```yaml
# Step 1: Create Position (Budget Approval)
Position: POS-ENG-BACKEND-001
  job_id: JOB-BACKEND-SENIOR
  business_unit_id: BU-ENGINEERING
  status: ACTIVE
  is_budgeted: true
  budget_year: 2024
  current_incumbents: 0  # Vacant

# Step 2: Hire Employee to Position
Assignment:
  employee_id: EMP-001
  staffing_model: POSITION_BASED
  position_id: POS-ENG-BACKEND-001  # Assigned to position
  job_id: JOB-BACKEND-SENIOR  # Derived from position

# Position now filled
Position: POS-ENG-BACKEND-001
  current_incumbents: 1
```

**When to Use**:
- ✅ Government agencies (strict headcount)
- ✅ Large corporations with formal position management
- ✅ Organizations requiring budget approval per position
- ✅ Highly regulated industries

**Benefits**:
- ✅ Tight budget control
- ✅ Clear vacancy tracking
- ✅ Formal approval process
- ✅ Reporting hierarchy through positions

**Drawbacks**:
- ⚠️ Less flexible
- ⚠️ Administrative overhead
- ⚠️ Slower to adapt to changes

---

### Job-Based Staffing

**Definition**: Employees are assigned directly to jobs without pre-defined positions.

**Characteristics**:
- ✅ Flexible headcount
- ✅ No pre-defined positions
- ✅ Multiple people can have same job
- ✅ Faster hiring process
- ✅ Easier reorganization

**Example**:
```yaml
# No position creation needed!

# Hire Employee directly to Job
Assignment:
  employee_id: EMP-001
  staffing_model: JOB_BASED
  position_id: null  # No position
  job_id: JOB-BACKEND-SENIOR  # Direct job assignment
  business_unit_id: BU-ENGINEERING
```

**When to Use**:
- ✅ Startups and fast-growing companies
- ✅ Consulting firms (project-based staffing)
- ✅ Organizations with flexible workforce planning
- ✅ Agile organizations

**Benefits**:
- ✅ Highly flexible
- ✅ Faster hiring
- ✅ Less administrative overhead
- ✅ Easy to scale up/down

**Drawbacks**:
- ⚠️ Less budget control
- ⚠️ Harder to track vacancies
- ⚠️ May lead to uncontrolled headcount growth

---

### Hybrid Approach (Recommended)

**Best Practice**: Use BOTH models for different parts of the organization.

```yaml
# Position-Based for Core Roles
Assignment:
  employee: Senior Engineer
  staffing_model: POSITION_BASED
  position_id: POS-ENG-001
  # Strict control, budgeted position

# Job-Based for Flexible Roles
Assignment:
  employee: Contractor
  staffing_model: JOB_BASED
  job_id: JOB-CONSULTANT
  # Flexible, no position needed
```

**Hybrid Strategy**:

| Role Type | Staffing Model | Reason |
|-----------|----------------|--------|
| Managers | Position-Based | Need strict control, reporting hierarchy |
| Key positions | Position-Based | Budget approval required |
| Individual Contributors | Job-Based | Flexibility in team size |
| Contractors | Job-Based | Temporary, no position needed |
| Interns | Job-Based | Short-term, flexible |

---

## 🔄 Real-World Scenarios

### Scenario 1: Creating a New Job

**Steps**:

```yaml
# Step 1: Determine Taxonomy
Taxonomy:
  family: Technology
  sub_family: Software Engineering
  function: Backend Development

# Step 2: Create Job
Job:
  code: JOB-BACKEND-SENIOR
  name: "Senior Backend Engineer"
  taxonomy_id: TAX-BACKEND-DEV
  level_id: L3  # Senior
  grade_id: G7
  job_type: INDIVIDUAL_CONTRIBUTOR
  flsa_status: EXEMPT

# Step 3: Create Job Profile
JobProfile:
  job_id: JOB-BACKEND-SENIOR
  summary: "Design and build scalable backend systems..."
  responsibilities: [...]
  requirements: [...]
  
# Step 4: Define Required Skills
JobProfileSkills:
  - skill: Python, proficiency: 4, mandatory: true
  - skill: AWS, proficiency: 3, mandatory: true
  - skill: PostgreSQL, proficiency: 3, mandatory: true

# Step 5: Define Required Competencies
JobProfileCompetencies:
  - competency: Leadership, level: 4
  - competency: Problem Solving, level: 5
```

---

### Scenario 2: Creating a Position (Position-Based)

**Steps**:

```yaml
# Step 1: Get Budget Approval
# (External process)

# Step 2: Create Position
Position:
  code: POS-ENG-BACKEND-001
  name: "Senior Backend Engineer - API Team"
  job_id: JOB-BACKEND-SENIOR
  business_unit_id: BU-ENG-BACKEND
  reports_to_position_id: POS-ENG-MGR-001
  location_id: LOC-HCM-OFFICE
  status: ACTIVE
  is_budgeted: true
  budget_year: 2024
  current_incumbents: 0  # Vacant

# Step 3: Post Job Opening
# (Recruitment module)

# Step 4: Hire to Position
Assignment:
  employee_id: EMP-001
  staffing_model: POSITION_BASED
  position_id: POS-ENG-BACKEND-001
  assignment_reason: HIRE
  effective_start_date: 2024-01-15

# Step 5: Update Position
Position:
  current_incumbents: 1  # Filled
```

---

### Scenario 3: Job Progression (Career Path)

**Example**: Junior → Mid → Senior → Principal

```yaml
# Career Path
CareerPath:
  name: "Backend Engineering IC Track"
  
  steps:
    - from_job: JOB-BACKEND-JUNIOR (L1, G5)
      to_job: JOB-BACKEND-MID (L2, G6)
      typical_duration: "2-3 years"
      requirements:
        - "Demonstrate proficiency in Python (Level 3+)"
        - "Complete 2+ major projects"
        - "Mentor junior engineers"
    
    - from_job: JOB-BACKEND-MID (L2, G6)
      to_job: JOB-BACKEND-SENIOR (L3, G7)
      typical_duration: "3-4 years"
      requirements:
        - "Lead technical design"
        - "Mentor mid-level engineers"
        - "Drive architectural decisions"
    
    - from_job: JOB-BACKEND-SENIOR (L3, G7)
      to_job: JOB-BACKEND-PRINCIPAL (L4, G8)
      typical_duration: "4-5 years"
      requirements:
        - "Demonstrate technical leadership"
        - "Drive org-wide initiatives"
        - "Mentor senior engineers"
```

---

### Scenario 4: Reorganization

**Scenario**: Merge Backend and Frontend teams into Platform team

**Position-Based Approach**:
```yaml
# Step 1: Eliminate old positions
Positions:
  - POS-BACKEND-001: status = ELIMINATED
  - POS-BACKEND-002: status = ELIMINATED
  - POS-FRONTEND-001: status = ELIMINATED
  - POS-FRONTEND-002: status = ELIMINATED

# Step 2: Create new positions
Positions:
  - POS-PLATFORM-001: new position
  - POS-PLATFORM-002: new position
  - POS-PLATFORM-003: new position
  - POS-PLATFORM-004: new position

# Step 3: Transfer employees to new positions
Assignments:
  - End old assignments
  - Create new assignments to new positions
  
# Complex, time-consuming!
```

**Job-Based Approach**:
```yaml
# Step 1: Update business unit only
Assignments:
  - Update business_unit_id to BU-PLATFORM
  
# That's it! Much simpler.
```

**Insight**: Job-based staffing is more flexible for reorganizations.

---

## ✅ Best Practices

### 1. Job Design

✅ **DO**:
- Create generic, reusable job definitions
- Use clear, descriptive job titles
- Define comprehensive job profiles
- Link jobs to taxonomy
- Set appropriate levels and grades
- Use job hierarchy for inheritance

❌ **DON'T**:
- Create overly specific jobs (one per person)
- Use vague job titles
- Skip job profiles
- Ignore taxonomy classification
- Mix levels and grades inconsistently

---

### 2. Job Profile Creation

✅ **DO**:
```yaml
JobProfile:
  summary: "Clear, concise summary (2-3 sentences)"
  
  responsibilities:
    - "Action verb + specific outcome"
    - "Design and implement RESTful APIs"
    - "Optimize database performance"
  
  skills:
    - skill: Python
      proficiency: 4  # Specific level
      mandatory: true  # Clear requirement
```

❌ **DON'T**:
```yaml
JobProfile:
  summary: "Does stuff"  # Too vague
  
  responsibilities:
    - "Coding"  # Not specific
    - "Help team"  # Too generic
  
  skills:
    - skill: Python
      # No proficiency level!
      # Not clear if mandatory!
```

---

### 3. Position Management

✅ **DO**:
- Get budget approval before creating positions
- Set clear reporting relationships
- Track vacancy status
- Use meaningful position codes
- Update position status promptly

❌ **DON'T**:
- Create positions without budget approval
- Leave reporting relationships undefined
- Forget to update incumbents count
- Use generic position codes (POS-001, POS-002)

---

### 4. Staffing Model Selection

✅ **DO**:
```yaml
# Use position-based for:
- Managers and executives
- Key strategic roles
- Roles requiring budget approval

# Use job-based for:
- Individual contributors (flexible teams)
- Contractors and consultants
- Temporary roles
```

❌ **DON'T**:
- Use only one model for entire organization
- Switch models frequently
- Mix models within same team (confusing)

---

## ⚠️ Common Pitfalls

### Pitfall 1: Too Many Jobs

❌ **Wrong**:
```yaml
# Creating separate job for each person
Job: Senior Backend Engineer - John
Job: Senior Backend Engineer - Jane
Job: Senior Backend Engineer - Bob
# 100+ jobs for same role!
```

✅ **Correct**:
```yaml
# One generic job, multiple positions/assignments
Job: Senior Backend Engineer

Positions:
  - POS-001 (filled by John)
  - POS-002 (filled by Jane)
  - POS-003 (filled by Bob)
```

---

### Pitfall 2: Incomplete Job Profiles

❌ **Wrong**:
```yaml
JobProfile:
  summary: "Backend engineer"
  # No responsibilities!
  # No skills!
  # No requirements!
```

✅ **Correct**:
```yaml
JobProfile:
  summary: "Detailed summary..."
  responsibilities: [...]
  requirements: [...]
  skills: [...]
  competencies: [...]
```

---

### Pitfall 3: Inconsistent Levels and Grades

❌ **Wrong**:
```yaml
Job: Senior Engineer
  level: L2  # Mid-level
  grade: G7  # Senior grade
  # Mismatch!

Job: Junior Engineer
  level: L1
  grade: G8  # Too high!
```

✅ **Correct**:
```yaml
Job: Senior Engineer
  level: L3  # Senior
  grade: G7  # Senior grade
  # Consistent!

Job: Junior Engineer
  level: L1
  grade: G5  # Junior grade
```

---

### Pitfall 4: Not Using Taxonomy

❌ **Wrong**:
```yaml
Job: Backend Engineer
  taxonomy_id: null  # No taxonomy!
  
# Hard to search, classify, benchmark
```

✅ **Correct**:
```yaml
Job: Backend Engineer
  taxonomy_id: TAX-BACKEND-DEV
  # Family: Technology
  # Sub-family: Software Engineering
  # Function: Backend Development
```

---

## 📊 Decision Trees

### Should I Create a New Job or Position?

```
Need to define a new role?
  ├─ Is this a new type of work?
  │   └─ YES → Create new JOB
  │
  └─ Is this a new headcount slot for existing role?
      └─ YES → Create new POSITION (if position-based)
```

### Which Staffing Model Should I Use?

```
Choosing staffing model:
  ├─ Need strict budget control?
  │   └─ YES → Position-Based
  │
  ├─ Need flexibility to scale team?
  │   └─ YES → Job-Based
  │
  ├─ Managers and executives?
  │   └─ YES → Position-Based
  │
  └─ Individual contributors?
      └─ Consider Job-Based (or Hybrid)
```

---

## 🎓 Quick Reference

### Checklist: Creating a New Job

- [ ] Determine taxonomy classification
- [ ] Define job hierarchy (parent job)
- [ ] Set job level and grade
- [ ] Write job summary
- [ ] List key responsibilities
- [ ] Define requirements (education, experience)
- [ ] Specify required skills with proficiency levels
- [ ] Specify required competencies
- [ ] Review and approve job definition

### Checklist: Creating a Position

- [ ] Get budget approval
- [ ] Select job for position
- [ ] Assign to business unit
- [ ] Set reporting relationship (reports to position)
- [ ] Set location
- [ ] Set FTE and max incumbents
- [ ] Set budget year and cost center
- [ ] Activate position
- [ ] Post job opening (if hiring)

---

## 🔗 Integration with Total Rewards Module

### Overview

Jobs and positions in the Core module are tightly integrated with the **Total Rewards (TR) module** for compensation management. Understanding this integration is essential for proper compensation setup and career progression.

### Grade System Integration

> [!IMPORTANT]
> **Core.JobGrade is Deprecated**
> 
> The `Core.JobGrade` entity is deprecated in favor of `TR.GradeVersion`.
> All grade references now use `grade_code` which maps to TR.GradeVersion.

**How Jobs Reference Grades**:

```yaml
Job: Senior Backend Engineer
  code: "SENIOR_BACKEND_ENG"
  grade_code: "G7"  # References TR.GradeVersion
  level_id: "L3_UUID"  # References Core.JobLevel
```

**What This Provides**:
- ✅ **Versioned Grades**: Complete history of grade changes (SCD Type 2)
- ✅ **Career Ladders**: Integration with career progression paths
- ✅ **Scoped Pay Ranges**: Position, BU, LE, or Global pay ranges
- ✅ **Single Source of Truth**: TR module owns all grade definitions

### Grade and Compensation

When a job has a `grade_code`, it determines:

1. **Pay Range**: Salary min/mid/max for the grade
2. **Career Ladder**: Which progression path (Technical, Management, Specialist, Executive)
3. **Compensation Eligibility**: Merit reviews, bonuses, equity

**Example**:
```yaml
Job: Senior Backend Engineer
  grade_code: "G7"

# TR Module provides:
Grade G7:
  name: "Grade 7"
  job_level: 3
  pay_range (Vietnam):
    min: 100,000,000 VND
    mid: 130,000,000 VND
    max: 160,000,000 VND
  ladder: Technical Ladder
  progression: G6 → G7 → G8
```

### Career Ladders

Jobs can be part of **career ladders** defined in the Total Rewards module:

| Ladder Type | Purpose | Example Grades |
|-------------|---------|----------------|
| **Technical** | Individual contributor progression | G1 → G2 → G3 → G4 → G5 |
| **Management** | People management track | M1 → M2 → M3 → M4 |
| **Specialist** | Expert/specialist track | S1 → S2 → S3 → S4 |
| **Executive** | C-level progression | E1 → E2 → E3 |

**Career Progression Example**:
```
Technical Ladder:
  G1: Junior Engineer
  G2: Engineer
  G3: Senior Engineer ← Current job
  G4: Principal Engineer ← Next step
  G5: Distinguished Engineer
```

### Job Hierarchy vs Career Ladder

**They serve different purposes**:

| Aspect | Job Hierarchy (Core) | Career Ladder (TR) |
|--------|---------------------|-------------------|
| **Purpose** | Organize job catalog | Define career progression |
| **Structure** | Parent-child tree | Ordered grade sequence |
| **Example** | Software Engineer → Backend Engineer → Senior Backend Engineer | G1 → G2 → G3 → G4 → G5 |
| **Use Case** | Job definition management | Compensation planning, promotions |

**They are complementary**:
- **Job hierarchy** helps organize and manage job definitions
- **Career ladder** guides compensation and career progression

### Position-Based vs Job-Based Compensation

The staffing model affects how compensation is determined:

**Position-Based**:
```
Employee → Position → Job → grade_code → TR.GradeVersion → PayRange
```
- Pay range can be position-specific
- Tighter budget control

**Job-Based**:
```
Employee → Job → grade_code → TR.GradeVersion → PayRange
```
- Pay range typically BU or LE scoped
- More flexible

### Common Workflows

**New Hire Setup**:
1. Select Job (or Position with Job)
2. Get grade_code from Job
3. Retrieve applicable pay range from TR
4. Determine offer amount
5. Create assignment and compensation

**Promotion**:
1. Change to higher-grade job
2. Calculate new salary (typically 10-15% increase)
3. Ensure at least minimum of new grade
4. Create compensation adjustment

**Merit Review**:
1. Get employee's current grade
2. Calculate compa-ratio (salary vs grade midpoint)
3. Apply merit matrix
4. Propose adjustment within grade range

### Cross-References

**For More Details**:
- [CO-TR Integration Guide (Conceptual)](../../00-integration/CO-TR-integration/01-conceptual-guide.md) - Business user perspective
- [CO-TR Integration Guide (Technical)](../../00-integration/CO-TR-integration/02-technical-guide.md) - Developer perspective
- [New Hire Compensation Setup](../../00-integration/CO-TR-integration/03-new-hire-setup.md) - Step-by-step workflow
- [Promotion Process](../../00-integration/CO-TR-integration/04-promotion-process.md) - Promotion with grade changes
- [TR Compensation Management Guide](../../TR/01-concept/03-compensation-management-guide.md) - TR module details

---

## 📚 Related Guides

- [Position Override Rules](./11-position-override-rules.md) - **NEW**: Detailed rules for Position-Job relationship
- [Employment Lifecycle Guide](./01-employment-lifecycle-guide.md) - Understanding assignments
- [Organization Structure Guide](./02-organization-structure-guide.md) - Business units
- [Skill Management Guide](./06-skill-management-guide.md) - Skills and competencies
- [Staffing Models Guide](./08-staffing-models-guide.md) - Deep dive on staffing

---

**Document Version**: 1.0  
**Created**: 2025-12-02  
**Last Review**: 2025-12-02
