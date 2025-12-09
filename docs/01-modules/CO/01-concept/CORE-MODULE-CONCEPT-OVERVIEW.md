# Core Module (CO) - Concept Overview

**Version**: 2.0  
**Last Updated**: 2025-12-09  
**Module Code**: CO  
**Purpose**: Foundational HR Data Model

---

## 📋 Executive Summary

The **Core Module** provides the foundational data model for the entire xTalent HR system. It defines the essential entities, relationships, and business rules for managing:

- **People** (Workers, Employees, Contractors)
- **Organizational Structure** (Legal Entities, Business Units, Positions)
- **Employment Relationships** (Contracts, Assignments, Work Relationships)
- **Jobs & Positions** (Job Taxonomy, Job Profiles, Position Management)
- **Master Data** (Reference tables, Classifications, Skills & Competencies)

**Key Innovation in v2.0**: Enhanced enterprise-grade capabilities including:
- 4-level employment hierarchy (Worker → WorkRelationship → Employee → Assignment)
- Supervisory Organization concept (separate reporting from operational structure)
- Flexible staffing models (Position-based vs Job-based)
- Explicit solid/dotted line reporting for matrix organizations
- Comprehensive skill gap analysis and data classification

---

## 🎯 Core Concepts

### 1. The 4-Level Employment Hierarchy ✨ NEW

**Problem Solved**: Traditional HR systems conflate person identity, employment contract, and job assignment into a single "Employee" entity. This creates issues for:
- Contractors and contingent workers (not employees but still workers)
- Multiple concurrent employment relationships
- Rehires and employment history tracking

**Solution**: Separate concerns across 4 distinct levels:

```
Level 1: WORKER (Person Identity)
   ↓
Level 2: WORK RELATIONSHIP (Relationship with Organization)
   ↓
Level 3: EMPLOYEE (Employment Contract Details)
   ↓
Level 4: ASSIGNMENT (Job Assignment)
```

**Detailed Breakdown**:

#### Level 1: Worker (Person Identity)
- **What**: Immutable person identity
- **Key Attributes**: Name, date of birth, national ID, biometric data
- **Person Types**: EMPLOYEE, CONTRACTOR, APPLICANT, ALUMNUS, DEPENDENT
- **Lifecycle**: Created once, never deleted (soft delete only)
- **Example**: John Doe, born 1990-05-15, National ID: 123456789

#### Level 2: WorkRelationship (Relationship with Organization)
- **What**: Overall work relationship between worker and organization
- **Types**: EMPLOYEE, CONTRACTOR, CONSULTANT, INTERN, VOLUNTEER
- **Key Attributes**: Start date, end date, relationship type, status
- **Cardinality**: One worker can have multiple work relationships (concurrent or sequential)
- **Example**: John Doe has EMPLOYEE relationship from 2020-01-01 to present

#### Level 3: Employee (Employment Contract)
- **What**: Specific employment contract details (only for EMPLOYEE-type work relationships)
- **Key Attributes**: Hire date, probation end date, seniority date, employee number
- **Cardinality**: One work relationship → One employee record (1:1)
- **Example**: Employee #EMP-001, hired 2020-01-01, probation ended 2020-03-01

#### Level 4: Assignment (Job Assignment)
- **What**: Specific job assignment within the organization
- **Key Attributes**: Position/Job, business unit, manager, location, FTE, assignment reason
- **Cardinality**: One employee → Many assignments (current and historical)
- **Staffing Models**: POSITION_BASED (assigned to budgeted position) or JOB_BASED (assigned directly to job)
- **Example**: Assigned to "Senior Backend Engineer" position in Engineering Division, reporting to Manager A

**Benefits**:
- ✅ Clear separation of person identity vs employment vs job assignment
- ✅ Support for non-employee workers (contractors, consultants)
- ✅ Multiple concurrent assignments (matrix organizations, job sharing)
- ✅ Complete employment history tracking
- ✅ Aligned with Workday, Oracle HCM, SAP SuccessFactors

---

### 2. Supervisory Organization ✨ NEW

**Problem Solved**: In real organizations, **how work is organized** (operational structure) often differs from **who reports to whom** (reporting structure).

**Traditional Approach** (Single Hierarchy):
```
Engineering Division
  ├─ Backend Team (Manager: Alice)
  ├─ Frontend Team (Manager: Bob)
  └─ Mobile Team (Manager: Carol)

Problem: What if Alice manages both Backend AND Frontend teams?
```

**Enhanced Approach** (Dual Structure):

```
OPERATIONAL STRUCTURE (How work is organized):
Engineering Division
  ├─ Backend Team
  ├─ Frontend Team
  └─ Mobile Team

SUPERVISORY STRUCTURE (Who reports to whom):
VP Engineering (Supervisory Org)
  ├─ Engineering Manager APAC (Supervisory Org)
  │   ├─ Backend Team members
  │   └─ Frontend Team members
  └─ Engineering Manager EMEA (Supervisory Org)
      └─ Mobile Team members
```

**Key Characteristics**:

| Aspect | Operational Structure | Supervisory Structure |
|--------|----------------------|----------------------|
| **Purpose** | Organize work | Define reporting/approvals |
| **Stability** | More stable | More dynamic |
| **Used For** | Team organization, projects | Performance reviews, approvals, security |
| **Entity Type** | DIVISION, DEPARTMENT, TEAM | SUPERVISORY |
| **Changes** | Infrequent (reorganizations) | More frequent (manager changes) |

**Use Cases**:
- ✅ Matrix organizations (functional + project reporting)
- ✅ Geographic vs functional organization
- ✅ Approval workflows (follow supervisory hierarchy)
- ✅ Data access control (based on supervisory membership)
- ✅ Performance management (supervisory manager conducts reviews)

---

### 3. Staffing Models: Position-Based vs Job-Based ✨ NEW

**Problem Solved**: Different organizations have different approaches to staffing:
- Some use strict headcount control with budgeted positions
- Others prefer flexible staffing without pre-defined positions

**Solution**: Support both models explicitly in Assignment entity.

#### Position-Based Staffing

**Characteristics**:
- Pre-defined budgeted positions (headcount slots)
- One-to-one position-to-person mapping (typically)
- Strict headcount control
- Position has budget, location, reporting line

**Example**:
```yaml
Position: POS-ENG-BACKEND-001
  job: Senior Backend Engineer
  business_unit: Engineering Division
  reports_to: POS-ENG-MGR-001
  fte: 1.0
  max_incumbents: 1
  current_incumbents: 1
  status: ACTIVE
  is_budgeted: true
  budget_year: 2024

Assignment:
  employee: John Doe
  staffing_model: POSITION_BASED
  position_id: POS-ENG-BACKEND-001  # Assigned to specific position
  job_id: JOB-BACKEND-ENG           # Derived from position
```

**When to Use**:
- Government agencies (strict headcount)
- Large corporations with formal position management
- Organizations requiring budget approval for each position

#### Job-Based Staffing

**Characteristics**:
- No pre-defined positions
- Multiple people can have same job
- Flexible headcount
- Direct assignment to job

**Example**:
```yaml
Assignment:
  employee: Jane Smith
  staffing_model: JOB_BASED
  position_id: null                 # No position
  job_id: JOB-BACKEND-ENG          # Direct job assignment
  business_unit: Engineering Division
```

**When to Use**:
- Startups and fast-growing companies
- Consulting firms (project-based staffing)
- Organizations with flexible workforce planning

**Hybrid Approach**:
Organizations can use BOTH models:
- Position-based for core roles (managers, key positions)
- Job-based for flexible roles (individual contributors, contractors)

---

### 4. Matrix Organizations & Reporting Lines ✨ NEW

**Problem Solved**: Traditional hierarchies don't support matrix organizations where employees report to multiple managers.

**Solution**: Explicit solid line (primary) and dotted line (secondary) reporting.

#### Solid Line Reporting (Primary)

**Characteristics**:
- **One per employee** (primary reporting relationship)
- **Affects approval chains** (leave, expenses, hiring)
- **Performance reviews** conducted by solid line manager
- **Career development** managed by solid line manager
- **Compensation decisions** made by solid line manager

**Example**:
```yaml
Engineer: John
  Solid Line:
    type: REPORTING_SOLID_LINE
    to: Engineering Manager (Functional)
    affects_approvals: true
```

#### Dotted Line Reporting (Secondary)

**Characteristics**:
- **Multiple allowed** per employee
- **Does NOT affect approval chains**
- **Guidance and coordination** only
- **Project or functional expertise**
- **Informational** relationship

**Example**:
```yaml
Engineer: John
  Dotted Line 1:
    type: REPORTING_DOTTED_LINE
    to: Project Lead Alpha
    percentage: 60%  # 60% time on this project
    
  Dotted Line 2:
    type: REPORTING_DOTTED_LINE
    to: Project Lead Beta
    percentage: 40%  # 40% time on this project
```

**Complete Matrix Example**:
```yaml
Engineer: John
  Operational Assignment:
    business_unit: Backend Team
    
  Reporting Structure:
    Solid Line: Engineering Manager (Functional)
      → Performance reviews
      → Leave approvals
      → Compensation decisions
      
    Dotted Line 1: Project Lead Alpha (60% time)
      → Project guidance
      → Technical direction
      → No approval authority
      
    Dotted Line 2: Product Manager Beta (40% time)
      → Product priorities
      → Feature planning
      → No approval authority
```

---

### 5. Job Taxonomy & Position Management

**Multi-Tree Architecture**: Support both corporate-wide and business-unit-specific job structures.

#### Job Taxonomy (Classification)

**3-Level Hierarchy**:
```
Level 1: Job Family
  └─ Level 2: Job Sub-family
      └─ Level 3: Job Function
```

**Example**:
```
Technology (Family)
  ├─ Software Engineering (Sub-family)
  │   ├─ Backend Development (Function)
  │   ├─ Frontend Development (Function)
  │   └─ Mobile Development (Function)
  └─ Data & Analytics (Sub-family)
      ├─ Data Engineering (Function)
      └─ Data Science (Function)
```

#### Job Hierarchy (Inheritance)

**Jobs form parent-child relationships**:
```
Software Engineer (Parent)
  ├─ Backend Engineer (Child)
  │   ├─ Junior Backend Engineer
  │   ├─ Senior Backend Engineer
  │   └─ Principal Backend Engineer
  └─ Frontend Engineer (Child)
      ├─ Junior Frontend Engineer
      └─ Senior Frontend Engineer
```

**Inheritance**: Child jobs inherit attributes from parent (can override).

#### Job Profile (Requirements)

**Components**:
- **Summary**: Job overview
- **Responsibilities**: Key duties
- **Requirements**: Education, experience, certifications
- **Skills**: Required technical skills with proficiency levels
- **Competencies**: Required behavioral competencies
- **Physical Requirements**: Physical demands
- **Work Environment**: Conditions, travel requirements

**Example**:
```yaml
Job: Senior Backend Engineer
JobProfile:
  summary: "Design and build scalable backend systems"
  responsibilities:
    - "Architect microservices"
    - "Mentor junior engineers"
    - "Code review and quality assurance"
  requirements:
    education: "Bachelor in Computer Science or equivalent"
    experience: "5+ years backend development"
    certifications: ["AWS Solutions Architect (preferred)"]
  skills:
    - skill: Python
      required_proficiency: 4
      is_mandatory: true
    - skill: AWS
      required_proficiency: 3
      is_mandatory: true
    - skill: Kubernetes
      required_proficiency: 3
      is_mandatory: false
  competencies:
    - competency: Leadership
      required_level: 4
    - competency: Problem Solving
      required_level: 5
```

#### Job Level & Grade

**Job Level** (Seniority):
- Junior (Level 1): 0-2 years
- Mid (Level 2): 2-5 years
- Senior (Level 3): 5-8 years
- Principal (Level 4): 8+ years
- Management levels
- Executive levels

**Job Grade** (Compensation):
- Grade determines salary range
- Linked to Total Rewards module
- Min/Mid/Max salary per grade
- Benefits and allowances

**Example**:
```yaml
Job: Senior Backend Engineer
  level: Senior (Level 3)
  grade: Grade 7
  
JobGrade: Grade 7
  min_salary: 100,000,000 VND
  mid_salary: 130,000,000 VND
  max_salary: 160,000,000 VND
  currency: VND
```

---

### 6. Skill Gap Analysis ✨ NEW

**Purpose**: Identify skill gaps between what jobs require and what workers possess.

**Components**:

#### 1. Job Requirements (What's Needed)
```yaml
JobProfile: Senior Backend Engineer
  required_skills:
    - Python: Level 4 (mandatory)
    - AWS: Level 3 (mandatory)
    - Kubernetes: Level 3 (nice-to-have)
```

#### 2. Worker Skills (What's Possessed)
```yaml
Worker: John Doe
  skills:
    - Python: Level 5 (Expert)
    - AWS: Level 2 (Beginner)
    - Docker: Level 4 (Advanced)
```

#### 3. Gap Analysis (Comparison)
```yaml
Skill Gap Analysis:
  Python: ✅ EXCEEDS (has 5, needs 4)
  AWS: ❌ GAP (has 2, needs 3) → Training needed
  Kubernetes: ⚠️ MISSING (has 0, needs 3) → Development opportunity
  Docker: ℹ️ EXTRA (has 4, not required) → Bonus skill
```

**Use Cases**:
- ✅ Hiring decisions (candidate qualification)
- ✅ Training needs identification
- ✅ Career development planning
- ✅ Internal mobility (job matching)
- ✅ Succession planning

---

### 7. Data Classification & Security ✨ NEW

**Purpose**: Protect sensitive personal data and comply with regulations (GDPR, PDPA).

**Data Classification Levels**:

| Level | Description | Examples | Access Control |
|-------|-------------|----------|----------------|
| PUBLIC | Public information | Name, job title, work email | All employees |
| INTERNAL | Internal use only | Work phone, office location | Same organization |
| CONFIDENTIAL | Sensitive business data | Salary, performance rating | Manager + HR |
| RESTRICTED | Highly sensitive PII | National ID, health data, biometric | HR only + explicit consent |

**Implementation**:

#### Worker Entity
```yaml
Worker:
  # PUBLIC
  full_name: "John Doe"
  preferred_name: "John"
  
  # INTERNAL
  work_email: "john.doe@company.com"
  
  # CONFIDENTIAL
  date_of_birth: "1990-05-15"
  data_classification: CONFIDENTIAL
  
  # RESTRICTED
  national_id: "123456789"
  biometric_data: {...}
  data_classification: RESTRICTED
```

#### Access Control Rules
```yaml
# Manager can view:
- PUBLIC data: ✅
- INTERNAL data: ✅
- CONFIDENTIAL data: ✅ (for direct reports only)
- RESTRICTED data: ❌

# HR can view:
- PUBLIC data: ✅
- INTERNAL data: ✅
- CONFIDENTIAL data: ✅
- RESTRICTED data: ✅ (with audit trail)

# Employee (self):
- All own data: ✅
```

**Audit Trail**:
- All access to RESTRICTED data is logged
- Who accessed, when, what data, why (purpose)
- Compliance reporting

---

## 🏗️ Module Structure

The Core Module is organized into **11 sub-modules**:

### 1. Common (Master Data)
**Purpose**: System-wide reference data and lookup tables

**Entities (10)**:
- CodeList - Multi-purpose lookup values
- Currency - ISO currency codes
- TimeZone - IANA time zones
- Industry - Industry classification
- ContactType - Contact method types
- RelationshipGroup - Relationship groupings
- RelationshipType - Personal relationship types
- TalentMarket - Multi-market structure
- SkillMaster - Skills catalog
- CompetencyMaster - Competencies catalog

**Key Concepts**:
- Centralized reference data
- Multi-language support (English + Local)
- SCD Type 2 for historical tracking

---

### 2. Geographic (Location Data)
**Purpose**: Geographic master data

**Entities (2)**:
- Country - ISO country codes
- AdminArea - Administrative areas (states, provinces, cities)

**Hierarchy**:
```
Country: Vietnam
  └─ AdminArea: Ho Chi Minh City (Level 1: Province)
      └─ AdminArea: District 1 (Level 2: District)
          └─ AdminArea: Ben Nghe Ward (Level 3: Ward)
```

---

### 3. LegalEntity (Company Structure)
**Purpose**: Legal entity (company) structure

**Entities (6)**:
- EntityType - Types of legal entities
- Entity - Legal entity instances (with country_code for legal jurisdiction)
- EntityProfile - Extended entity information
- EntityRepresentative - Legal representatives
- EntityLicense - Business licenses
- EntityBankAccount - Entity bank accounts

**Hierarchy**:
```
Parent Corporation (SG)
  ├─ Subsidiary Vietnam (VN) - 100% owned
  ├─ Subsidiary Singapore (SG) - 100% owned
  └─ Joint Venture Thailand (TH) - 51% owned
  
Note: Country code represents legal registration country,
      which may differ from physical office location.
```

---

### 4. BusinessUnit (Operational Organization)
**Purpose**: Operational organizational units

**Entities (3)**:
- UnitType - Types of business units
- Unit - Business unit instances
- UnitTag - Flexible unit classification

**Key Concepts**:
- Operational structure (DIVISION, DEPARTMENT, TEAM)
- Supervisory structure (SUPERVISORY type)
- Dual membership (operational + supervisory)
- Materialized path for hierarchy

---

### 5. OrganizationRelation (Dynamic Relationships)
**Purpose**: Complex relationships beyond simple hierarchies

**Entities (3)**:
- RelationSchema - Relationship graph templates
- RelationType - Types of relationships
- RelationEdge - Actual relationship instances

**Relationship Types**:
- REPORTING_SOLID_LINE - Primary reporting
- REPORTING_DOTTED_LINE - Matrix reporting
- OWNERSHIP - Legal ownership
- BUDGET_FLOW - Financial flows
- PROJECT_MEMBERSHIP - Project teams

**Use Cases**:
- Matrix organizations
- Multi-entity companies
- Project teams
- Cost allocation

---

### 6. Person (Worker Data)
**Purpose**: Worker (people) master data

**Entities (10)**:
- Worker - Person identity
- Contact - Contact information
- Address - Physical addresses
- Document - Identity documents
- BankAccount - Personal bank accounts
- WorkerRelationship - Personal relationships
- WorkerQualification - Education & certifications
- WorkerSkill - Technical skills
- WorkerCompetency - Behavioral competencies
- WorkerInterest - Career interests

**Key Concepts**:
- Person types (EMPLOYEE, CONTRACTOR, APPLICANT, etc.)
- Data classification (PUBLIC, INTERNAL, CONFIDENTIAL, RESTRICTED)
- Skill gap analysis
- GDPR/PDPA compliance

---

### 7. Employment (Employment Relationships)
**Purpose**: Employment relationships and assignments

**Entities (7)** ✨ ENHANCED:
- WorkRelationship - Overall work relationship ✨ NEW
- Employee - Employment contract details
- Contract - Contract specifics with hierarchy support
- ContractTemplate - Pre-configured contract terms ✨ NEW
- Assignment - Job assignments
- EmployeeIdentifier - Employee numbers
- GlobalAssignment - International assignments

**Key Concepts**:
- 4-level hierarchy (Worker → WorkRelationship → Employee → Assignment)
- Contract relationships (AMENDMENT, ADDENDUM, RENEWAL, SUPERSESSION)
- Contract templates for standardization and compliance
- Flexible staffing models (POSITION_BASED vs JOB_BASED)
- Solid/dotted line reporting
- Assignment reasons (HIRE, TRANSFER, PROMOTION, etc.)

---

### 8. JobPosition (Job & Position Structures)
**Purpose**: Job definitions and position management

**Entities (10)** ✨ NEW:
- TaxonomyTree - Job taxonomy trees
- JobTaxonomy - Taxonomy nodes
- JobTree - Job hierarchy trees
- Job - Job definitions
- JobProfile - Job profiles with requirements
- JobProfileSkill - Required skills
- JobProfileCompetency - Required competencies
- JobLevel - Job levels (seniority)
- JobGrade - Job grades (compensation)
- Position - Position instances

**Key Concepts**:
- Multi-tree architecture (corporate + BU-specific)
- Job taxonomy (Family → Sub-family → Function)
- Job hierarchy with inheritance
- Position-based vs job-based staffing

---

### 9. Career (Career Paths)
**Purpose**: Career progression and development

**Entities (3)**:
- CareerPath - Career progression paths
- CareerStep - Steps within career path
- JobProgression - Job-to-job progression rules

**Example**:
```
Career Path: Software Engineering IC Track
  Step 1: Junior Engineer → Mid Engineer (2-3 years)
  Step 2: Mid Engineer → Senior Engineer (3-4 years)
  Step 3: Senior Engineer → Principal Engineer (4-5 years)
  Step 4: Principal Engineer → Distinguished Engineer (5+ years)
```

---

### 10. Facility (Locations & Facilities)
**Purpose**: Physical locations and work facilities

**Entities (3)** ✨ NEW:
- Place - Geographic places
- Location - Facility/building locations
- WorkLocation - Work locations for assignments

**Hierarchy**:
```
Place: Ho Chi Minh City
  └─ Location: VNG Campus
      ├─ WorkLocation: Building A - Floor 5
      ├─ WorkLocation: Building B - Floor 3
      └─ WorkLocation: Remote (Virtual)
```

---

### 11. TalentMarket (Internal Talent Marketplace)
**Purpose**: Internal job opportunities and talent mobility

**Entities (3)**:
- Opportunity - Internal job opportunities
- OpportunitySkill - Required skills
- OpportunityApplication - Worker applications

**Use Cases**:
- Internal job postings
- Skill-based job matching
- Career mobility
- Talent retention

---

## 🔄 Key Design Patterns

### 1. Slowly Changing Dimensions (SCD Type 2)

**Purpose**: Track historical changes over time

**Implementation**:
```yaml
Entity:
  effective_start_date: 2024-01-01
  effective_end_date: 2024-06-30
  is_current_flag: false  # Historical record

Entity:
  effective_start_date: 2024-07-01
  effective_end_date: null
  is_current_flag: true   # Current record
```

**Applies To**: Most entities (Worker, Employee, Assignment, Unit, Job, etc.)

**Benefits**:
- Complete audit trail
- Point-in-time reporting
- Compliance requirements

---

### 2. Hierarchical Data (Materialized Path)

**Purpose**: Efficient hierarchy queries

**Implementation**:
```yaml
Unit:
  code: VNG-ENG-BACKEND-API
  parent_id: VNG-ENG-BACKEND
  path: "/VNG-CORP/VNG-ENG/VNG-ENG-BACKEND/VNG-ENG-BACKEND-API"
  level: 4
```

**Benefits**:
- Fast subtree queries
- Ancestor/descendant lookups
- Hierarchy depth calculation

**Applies To**: Industry, AdminArea, Unit, Job, JobTaxonomy

---

### 3. Separation of Concerns

**Purpose**: Clear boundaries between different aspects

**Examples**:
- **Person vs Employment**: Worker (identity) separate from Employee (contract)
- **Operational vs Supervisory**: Work organization separate from reporting structure
- **Job vs Position**: Job definition separate from position instance
- **Legal vs Operational**: Legal entities separate from business units

**Benefits**:
- Flexibility
- Maintainability
- Scalability

---

### 4. Multi-Tree Architecture

**Purpose**: Support multiple independent hierarchies

**Examples**:
- **Job Taxonomy**: Corporate taxonomy + BU-specific taxonomies
- **Job Hierarchy**: Corporate jobs + BU-specific jobs
- **Organization**: Operational structure + Supervisory structure

**Benefits**:
- Flexibility for different organizational needs
- Inheritance from parent trees
- Override capabilities

---

### 5. Graph-Based Relationships

**Purpose**: Model complex, non-hierarchical relationships

**Implementation**:
```yaml
RelationSchema: REPORTING_ORG
RelationType: REPORTING_SOLID_LINE, REPORTING_DOTTED_LINE
RelationEdge: Actual relationship instances
```

**Use Cases**:
- Matrix organizations
- Project teams
- Financial reporting structures
- Cost allocation

---

## 📊 Entity Relationship Summary

### Core Relationships

```
Worker (1) ──→ (0..*) WorkRelationship
WorkRelationship (1) ──→ (0..1) Employee
Employee (1) ──→ (0..*) Assignment

Assignment (1) ──→ (0..1) Position
Assignment (1) ──→ (0..1) Job
Position (1) ──→ (1) Job

Job (1) ──→ (0..1) JobProfile
JobProfile (1) ──→ (0..*) JobProfileSkill
JobProfile (1) ──→ (0..*) JobProfileCompetency

Worker (1) ──→ (0..*) WorkerSkill
Worker (1) ──→ (0..*) WorkerCompetency

Unit (1) ──→ (1) UnitType
Unit (1) ──→ (0..1) Unit (parent)
Unit (1) ──→ (1) Entity (legal entity)

Entity (1) ──→ (1) EntityType
Entity (1) ──→ (0..1) Entity (parent)
```

---

## 🎯 Business Rules Summary

### Employment Rules
1. ✅ Worker can have multiple work relationships (concurrent or sequential)
2. ✅ EMPLOYEE-type work relationship requires Employee record
3. ✅ CONTRACTOR-type work relationship does NOT have Employee record
4. ✅ Employee can have multiple assignments (current and historical)
5. ✅ One primary assignment per employee at any time
6. ✅ POSITION_BASED staffing requires position_id
7. ✅ JOB_BASED staffing requires job_id (no position)

### Reporting Rules
8. ✅ One solid line (primary) reporting relationship per employee
9. ✅ Multiple dotted line (secondary) relationships allowed
10. ✅ Solid line affects approval chains
11. ✅ Dotted line is informational only

### Organization Rules
12. ✅ Every business unit must link to a legal entity
13. ✅ Supervisory organizations separate from operational structure
14. ✅ Employee can be in operational unit AND supervisory organization

### Job & Position Rules
15. ✅ Position is instance of Job in specific business unit
16. ✅ Jobs form hierarchy (parent-child with inheritance)
17. ✅ Job profile defines requirements (skills, competencies)
18. ✅ Job level determines seniority, grade determines compensation

### Data Classification Rules
19. ✅ RESTRICTED data requires explicit access control
20. ✅ All access to RESTRICTED data is audited
21. ✅ Data classification enforced at field level

---

## 🚀 Use Case Examples

### Use Case 1: Hire New Employee

**Steps**:
1. Create Worker record (person identity)
2. Create WorkRelationship (type: EMPLOYEE)
3. Create Employee record (contract details)
4. Create Assignment (job assignment)

**Example**:
```yaml
# Step 1: Worker
Worker:
  id: WORKER-001
  full_name: "John Doe"
  person_type: EMPLOYEE
  
# Step 2: WorkRelationship
WorkRelationship:
  id: WR-001
  worker_id: WORKER-001
  type: EMPLOYEE
  start_date: 2024-01-01
  
# Step 3: Employee
Employee:
  id: EMP-001
  work_relationship_id: WR-001
  employee_number: "EMP-2024-001"
  hire_date: 2024-01-01
  probation_end_date: 2024-03-01
  
# Step 4: Assignment
Assignment:
  id: ASG-001
  employee_id: EMP-001
  staffing_model: POSITION_BASED
  position_id: POS-ENG-001
  assignment_reason: HIRE
  effective_start_date: 2024-01-01
```

---

### Use Case 2: Internal Transfer

**Scenario**: Employee transfers from Backend Team to Frontend Team

**Steps**:
1. End current assignment (set effective_end_date)
2. Create new assignment (new position/job, new business unit)

**Example**:
```yaml
# Old Assignment (ended)
Assignment:
  id: ASG-001
  employee_id: EMP-001
  position_id: POS-BACKEND-001
  business_unit_id: BU-BACKEND
  effective_start_date: 2024-01-01
  effective_end_date: 2024-06-30
  is_current_flag: false
  
# New Assignment (current)
Assignment:
  id: ASG-002
  employee_id: EMP-001
  position_id: POS-FRONTEND-001
  business_unit_id: BU-FRONTEND
  assignment_reason: TRANSFER
  effective_start_date: 2024-07-01
  effective_end_date: null
  is_current_flag: true
```

---

### Use Case 3: Matrix Organization

**Scenario**: Engineer reports to functional manager (solid line) and project lead (dotted line)

**Implementation**:
```yaml
# Assignment (operational)
Assignment:
  employee: John Doe
  business_unit: Backend Team
  supervisor_assignment_id: MGR-BACKEND  # Solid line
  dotted_line_supervisor_id: LEAD-PROJ-A  # Dotted line
  
# Reporting relationships (in RelationEdge)
RelationEdge:
  # Solid line
  - from: John Doe (Position)
    to: Backend Manager (Position)
    type: REPORTING_SOLID_LINE
    affects_approvals: true
    
  # Dotted line
  - from: John Doe (Position)
    to: Project Lead Alpha (Position)
    type: REPORTING_DOTTED_LINE
    percentage: 60%
```

---

### Use Case 4: Skill Gap Analysis

**Scenario**: Assess if worker qualifies for job

**Steps**:
1. Get job requirements from JobProfile
2. Get worker skills from WorkerSkill
3. Compare and identify gaps

**Example**:
```yaml
# Job Requirements
JobProfile: Senior Backend Engineer
  required_skills:
    - Python: Level 4 (mandatory)
    - AWS: Level 3 (mandatory)
    - Kubernetes: Level 3 (nice-to-have)

# Worker Skills
Worker: John Doe
  skills:
    - Python: Level 5
    - AWS: Level 2
    - Docker: Level 4

# Gap Analysis Result
Gaps:
  - AWS: GAP (has 2, needs 3) → Training required
  - Kubernetes: MISSING → Development opportunity
  
Strengths:
  - Python: EXCEEDS (has 5, needs 4)
  - Docker: BONUS (not required but valuable)
  
Recommendation: Provide AWS training before promotion
```

---

## 📈 Comparison with Leading HR Systems

### Workday HCM

| Concept | Workday | xTalent Core v2.0 |
|---------|---------|-------------------|
| Person Identity | Worker | Worker ✅ |
| Work Relationship | Work Relationship | WorkRelationship ✅ |
| Employment | Employee | Employee ✅ |
| Job Assignment | Position | Assignment ✅ |
| Supervisory Org | Supervisory Organization | Supervisory UnitType ✅ |
| Job Profile | Job Profile | JobProfile ✅ |
| Matrix Reporting | Primary/Additional Orgs | Solid/Dotted Line ✅ |

**Alignment**: 95% aligned with Workday concepts ✅

---

### SAP SuccessFactors

| Concept | SuccessFactors | xTalent Core v2.0 |
|---------|----------------|-------------------|
| Person | User | Worker ✅ |
| Employment | Employment Info | Employee ✅ |
| Job | Job Code | Job ✅ |
| Position | Position | Position ✅ |
| Org Structure | Foundation Objects | Unit ✅ |
| Job Profile | Role-Based Permissions | JobProfile ✅ |

**Alignment**: 90% aligned with SuccessFactors ✅

---

### Oracle HCM Cloud

| Concept | Oracle HCM | xTalent Core v2.0 |
|---------|------------|-------------------|
| Person | Person | Worker ✅ |
| Work Relationship | Work Relationship | WorkRelationship ✅ |
| Assignment | Assignment | Assignment ✅ |
| Job | Job | Job ✅ |
| Position | Position | Position ✅ |
| Grade | Grade | JobGrade ✅ |

**Alignment**: 95% aligned with Oracle HCM ✅

---

## 🎓 Learning Path

### For Business Users

**Level 1: Basic Concepts** (1-2 hours)
- Understand 4-level employment hierarchy
- Learn operational vs supervisory organization
- Understand position-based vs job-based staffing

**Level 2: Intermediate** (2-4 hours)
- Master data management (CodeList, Currency, etc.)
- Job taxonomy and job profiles
- Skill gap analysis

**Level 3: Advanced** (4-8 hours)
- Matrix organizations and reporting lines
- Organization relationships and graphs
- Data classification and security

---

### For Technical Users

**Level 1: Data Model** (2-4 hours)
- Study core-ontology.yaml
- Understand entity relationships
- Review SCD Type 2 implementation

**Level 2: Business Rules** (4-6 hours)
- Employment lifecycle rules
- Reporting hierarchy rules
- Data validation rules

**Level 3: Integration** (6-8 hours)
- API design patterns
- Data migration strategies
- Integration with other modules

---

## 📚 Reference Documents

### Core Documentation
- `core-ontology.yaml` - Complete ontology definition
- `ONTOLOGY-V2-ENHANCEMENT-SUMMARY.md` - v2.0 enhancements
- `glossary-index.md` - Master glossary index

### Sub-Module Glossaries
- `glossary-common.md` - Master data
- `glossary-person.md` - Worker data
- `glossary-employment.md` - Employment relationships
- `glossary-business-unit.md` - Organizational units
- `glossary-org-relation.md` - Dynamic relationships
- `glossary-job-position.md` - Jobs and positions (TBD)

### Vietnamese Translations
- `glossary-employment-vi.md`
- `glossary-person-vi.md`
- `glossary-business-unit-vi.md`
- `glossary-common-vi.md`
- `glossary-org-relation-vi.md`

---

## ✅ Next Steps

### For Implementation
1. Review this concept overview
2. Study detailed glossaries for each sub-module
3. Review core-ontology.yaml for technical details
4. Design database schema (DBML)
5. Implement API endpoints
6. Build UI components

### For Documentation
1. Create remaining glossaries (Career, Facility, TalentMarket)
2. Create API specification
3. Create data migration guide
4. Create user training materials

---

**Document Version**: 1.0  
**Created**: 2025-12-02  
**Status**: Complete  
**Audience**: Business Users, Technical Users, Stakeholders
