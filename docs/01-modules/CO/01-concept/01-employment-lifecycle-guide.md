# Employment Lifecycle Guide

**Version**: 2.0  
**Last Updated**: 2025-12-09  
**Audience**: Business Users, HR Administrators  
**Reading Time**: 30-45 minutes

---

## 📋 Overview

This guide explains how employment relationships are modeled in the xTalent Core Module using the **4-level employment hierarchy**. Understanding this structure is fundamental to working with the system.

### What You'll Learn
- The 4 levels of employment hierarchy
- Why we separate Worker, WorkRelationship, Employee, and Assignment
- How to handle different employment scenarios
- Best practices for managing employment data

### Prerequisites
- Basic understanding of HR concepts
- Familiarity with employment types (employees, contractors, etc.)

---

## 🎯 The Problem with Traditional HR Systems

### Traditional Approach (Single "Employee" Entity)

Most legacy HR systems use a single "Employee" entity that combines:
- Person identity (name, date of birth)
- Employment contract (hire date, employee number)
- Job assignment (position, department, manager)

**Problems with this approach**:

❌ **Cannot handle contractors** - They're not "employees" but still need to be in the system  
❌ **Rehires are messy** - Same person, new employee record → duplicate data  
❌ **Multiple jobs unclear** - How to handle someone with 2 concurrent positions?  
❌ **History tracking poor** - Hard to distinguish person changes vs employment changes  
❌ **Inflexible** - Doesn't match how real organizations work

**Example Problem**:
```
John Doe works as:
- Full-time Employee (Backend Engineer)
- Part-time Contractor (Technical Advisor)

Traditional system: Create 2 "Employee" records? 
→ Duplicate person data, confusing identity
```

---

## ✨ The xTalent Solution: 4-Level Hierarchy

### The 4 Levels Explained

```
┌─────────────────────────────────────────────────┐
│ Level 1: WORKER (Person Identity)              │
│ "Who is this person?"                           │
│ • Name, DOB, National ID                        │
│ • Immutable identity                            │
│ • Created once, never deleted                   │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│ Level 2: WORK RELATIONSHIP                      │
│ "What's their relationship with the org?"       │
│ • EMPLOYEE, CONTRACTOR, CONSULTANT, INTERN      │
│ • Start/end dates                               │
│ • Can have multiple (concurrent or sequential)  │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│ Level 3: EMPLOYEE (Contract Details)            │
│ "What are the employment contract terms?"       │
│ • Only for EMPLOYEE-type relationships          │
│ • Hire date, probation, employee number         │
│ • One per work relationship (1:1)               │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│ Level 4: ASSIGNMENT (Job Assignment)            │
│ "What job are they doing?"                      │
│ • Position/Job, Department, Manager             │
│ • Can have multiple (current + historical)      │
│ • Tracks all job changes                        │
└─────────────────────────────────────────────────┘
```

---

## 📊 Level 1: Worker (Person Identity)

### Purpose
**Immutable person identity** - represents the actual human being, independent of their employment status.

### Key Characteristics

| Aspect | Details |
|--------|---------|
| **Created When** | First interaction with organization (apply, hire, onboard) |
| **Deleted When** | NEVER (soft delete only for GDPR) |
| **Changes When** | Legal name change, personal data updates |
| **Uniqueness** | One worker = one person (forever) |

### Key Attributes

```yaml
Worker:
  id: WORKER-12345
  full_name: "Nguyễn Văn An"
  preferred_name: "An"
  date_of_birth: 1990-05-15
  national_id: "001234567890"
  person_type: EMPLOYEE  # or CONTRACTOR, APPLICANT, ALUMNUS
  gender_code: M
  marital_status_code: MARRIED
  
  # Data classification
  data_classification: CONFIDENTIAL
  
  # Audit
  created_at: 2024-01-01T10:00:00Z
  updated_at: 2024-06-15T14:30:00Z
```

### Person Types

| Type | Description | Has Employee Record? |
|------|-------------|---------------------|
| **EMPLOYEE** | Full-time/part-time employee | ✅ Yes |
| **CONTRACTOR** | Independent contractor | ❌ No |
| **CONSULTANT** | External consultant | ❌ No |
| **INTERN** | Intern/trainee | ⚠️ Optional |
| **APPLICANT** | Job applicant | ❌ No |
| **ALUMNUS** | Former employee | ❌ No (anymore) |
| **DEPENDENT** | Family member/dependent | ❌ No |

### Real-World Scenarios

#### Scenario 1: New Hire
```yaml
# Step 1: Create Worker (during application)
Worker:
  full_name: "Trần Thị Bình"
  person_type: APPLICANT
  
# Step 2: Update person_type when hired
Worker:
  full_name: "Trần Thị Bình"
  person_type: EMPLOYEE  # Changed from APPLICANT
```

#### Scenario 2: Contractor to Employee
```yaml
# Worker record stays the same!
Worker:
  id: WORKER-99999
  full_name: "Lê Văn Cường"
  # Person type will be updated based on active work relationships
```

#### Scenario 3: Rehire
```yaml
# Same worker record is reused
Worker:
  id: WORKER-11111
  full_name: "Phạm Thị Dung"
  
# New work relationship created (see Level 2)
```

---

## 📊 Level 2: WorkRelationship

### Purpose
**Overall relationship between worker and organization** - defines the nature of the working arrangement.

### Key Characteristics

| Aspect | Details |
|--------|---------|
| **Created When** | Worker starts working with organization |
| **Ended When** | Relationship terminates (resignation, contract end) |
| **Cardinality** | One worker can have MULTIPLE work relationships |
| **Types** | EMPLOYEE, CONTRACTOR, CONSULTANT, INTERN, VOLUNTEER |

### Key Attributes

```yaml
WorkRelationship:
  id: WR-2024-001
  worker_id: WORKER-12345
  
  # Relationship type
  type_code: EMPLOYEE  # or CONTRACTOR, CONSULTANT, etc.
  
  # Dates
  start_date: 2024-01-15
  end_date: null  # null = currently active
  termination_reason_code: null
  
  # Status
  status_code: ACTIVE  # ACTIVE, TERMINATED, SUSPENDED
  
  # Legal entity
  legal_entity_code: VNG-VN
  
  # SCD Type 2
  effective_start_date: 2024-01-15
  effective_end_date: null
  is_current_flag: true
```

### Relationship Types

#### EMPLOYEE
```yaml
WorkRelationship:
  type_code: EMPLOYEE
  
  # Characteristics:
  # - Has Employee record (Level 3)
  # - Subject to labor law
  # - Entitled to benefits
  # - Payroll taxes withheld
```

#### CONTRACTOR
```yaml
WorkRelationship:
  type_code: CONTRACTOR
  
  # Characteristics:
  # - NO Employee record
  # - Invoice-based payment
  # - No benefits
  # - Independent tax filing
```

#### CONSULTANT
```yaml
WorkRelationship:
  type_code: CONSULTANT
  
  # Characteristics:
  # - NO Employee record
  # - Project-based engagement
  # - Specialized expertise
  # - Typically short-term
```

### Real-World Scenarios

#### Scenario 1: Simple Employment
```yaml
Worker: An (WORKER-001)
  └─ WorkRelationship: WR-001
      type: EMPLOYEE
      start: 2024-01-01
      end: null (active)
```

#### Scenario 2: Contractor Converted to Employee
```yaml
Worker: Bình (WORKER-002)
  ├─ WorkRelationship: WR-010
  │   type: CONTRACTOR
  │   start: 2023-06-01
  │   end: 2023-12-31 (ended)
  │
  └─ WorkRelationship: WR-011
      type: EMPLOYEE
      start: 2024-01-01
      end: null (active)
```

#### Scenario 3: Concurrent Relationships
```yaml
Worker: Cường (WORKER-003)
  ├─ WorkRelationship: WR-020
  │   type: EMPLOYEE (full-time)
  │   start: 2024-01-01
  │   end: null
  │
  └─ WorkRelationship: WR-021
      type: CONTRACTOR (part-time advisor)
      start: 2024-06-01
      end: null
      
# Same person, 2 concurrent relationships!
```

#### Scenario 4: Rehire
```yaml
Worker: Dung (WORKER-004)
  ├─ WorkRelationship: WR-030
  │   type: EMPLOYEE
  │   start: 2020-01-01
  │   end: 2022-12-31 (resigned)
  │
  └─ WorkRelationship: WR-031
      type: EMPLOYEE
      start: 2024-01-01
      end: null (rehired!)
      
# Complete history preserved
# Seniority calculation uses both periods
```

---

## 📊 Level 3: Employee (Contract Details)

### Purpose
**Employment contract specifics** - only for EMPLOYEE-type work relationships.

### Key Characteristics

| Aspect | Details |
|--------|---------|
| **Created When** | WorkRelationship type = EMPLOYEE |
| **Cardinality** | One WorkRelationship → One Employee (1:1) |
| **Applies To** | EMPLOYEE type only (not contractors) |

### Key Attributes

```yaml
Employee:
  id: EMP-2024-001
  work_relationship_id: WR-2024-001
  worker_id: WORKER-12345  # Denormalized for performance
  
  # Employment details
  employee_number: "EMP-2024-001"
  hire_date: 2024-01-15
  original_hire_date: 2024-01-15  # For rehires, this is first hire
  
  # Probation
  probation_end_date: 2024-03-15  # 2 months
  
  # Seniority
  seniority_date: 2024-01-15
  
  # Status
  employment_status_code: ACTIVE
  
  # SCD Type 2
  effective_start_date: 2024-01-15
  effective_end_date: null
  is_current_flag: true
```

### Important Fields Explained

#### Employee Number
```yaml
employee_number: "EMP-2024-001"

# Format can be:
# - Sequential: EMP-0001, EMP-0002, ...
# - Year-based: EMP-2024-001, EMP-2024-002, ...
# - Department-based: ENG-001, SALES-001, ...
# - Custom: Based on organization rules
```

#### Hire Date vs Original Hire Date
```yaml
# First hire
Employee:
  hire_date: 2020-01-01
  original_hire_date: 2020-01-01
  
# Resigned 2022-12-31

# Rehired
Employee:
  hire_date: 2024-01-01  # Current hire date
  original_hire_date: 2020-01-01  # First hire (preserved)
  
# Seniority calculation uses original_hire_date
```

#### Probation Period
```yaml
Employee:
  hire_date: 2024-01-01
  probation_end_date: 2024-03-01  # 2 months probation
  
# After probation ends:
# - Full benefits kick in
# - Notice period changes
# - Performance review eligibility
```

### Real-World Scenarios

#### Scenario 1: Standard Employee
```yaml
Worker: An
  └─ WorkRelationship: WR-001 (EMPLOYEE)
      └─ Employee: EMP-001
          employee_number: "EMP-2024-001"
          hire_date: 2024-01-15
          probation_end_date: 2024-03-15
```

#### Scenario 2: Contractor (No Employee Record)
```yaml
Worker: Bình
  └─ WorkRelationship: WR-002 (CONTRACTOR)
      # NO Employee record!
      # Payment via invoices, not payroll
```

#### Scenario 3: Rehire with Seniority
```yaml
Worker: Cường
  ├─ WorkRelationship: WR-010 (EMPLOYEE) [ENDED]
  │   └─ Employee: EMP-010 [HISTORICAL]
  │       hire_date: 2020-01-01
  │       original_hire_date: 2020-01-01
  │       effective_end_date: 2022-12-31
  │
  └─ WorkRelationship: WR-011 (EMPLOYEE) [ACTIVE]
      └─ Employee: EMP-011 [CURRENT]
          hire_date: 2024-01-01
          original_hire_date: 2020-01-01  # Preserved!
          seniority_date: 2020-01-01  # Continuous service
```

### 💡 Deep Dive: Contract Management

> **📘 For comprehensive contract management documentation, see [Contract Management Guide](./10-contract-management-guide.md)**

Employment contracts define the terms and conditions of employment. The xTalent system supports:

**Contract Types**:
- **PERMANENT**: Indefinite duration, no end date
- **FIXED_TERM**: Specific duration with end date (max 36 months in Vietnam)
- **PROBATION**: Trial period (60-180 days)
- **SEASONAL**: Recurring seasonal work

**Contract Hierarchy**: Contracts can have parent-child relationships to track changes:
- **AMENDMENT**: Modify existing terms (e.g., salary increase)
- **ADDENDUM**: Add new clauses (e.g., add bonus structure)
- **RENEWAL**: Extend contract period (e.g., re-sign for another year)
- **SUPERSESSION**: Replace contract type (e.g., Probation → Permanent)

**Contract Templates**: Pre-configured templates ensure standardization and compliance:
```yaml
# Example: Vietnam Tech Fixed-Term Template
template:
  code: VN_TECH_FIXED_12M
  country_code: VN
  default_duration: 12 MONTH
  max_duration: 36 MONTH  # Vietnam labor law
  max_renewals: 1  # Vietnam: max 2 consecutive contracts
  probation_required: true
  probation_duration: 60 DAY
```

**Quick Example - Probation to Permanent**:
```yaml
# 1. Initial Probation Contract
contract_1:
  contract_type: PROBATION
  start_date: 2025-01-01
  end_date: 2025-03-01
  base_salary: 50000000

# 2. Supersession to Permanent (after probation passes)
contract_2:
  parent_contract_id: contract_1.id
  parent_relationship_type: SUPERSESSION
  contract_type: PERMANENT
  start_date: 2025-03-01
  end_date: null  # Permanent has no end date
  base_salary: 60000000  # Often includes raise
```

**For detailed information**, see:
- [Contract Management Guide](./10-contract-management-guide.md) - Complete contract lifecycle, templates, hierarchy, renewals, and compliance
- [Data Model Guide](./04-data-model-guide.md#contract-entities) - Contract entity relationships
- [Business Rules](../02-spec/04-business-rules.md#contract-management) - Contract validation rules

---

## Level 4: Assignment (Job & Organization)

### Purpose
**Specific job assignment** - what job/position the person is doing, in which department, reporting to whom.

### Key Characteristics

| Aspect | Details |
|--------|---------|
| **Created When** | Employee starts a job |
| **Cardinality** | One Employee → MULTIPLE Assignments (current + historical) |
| **Tracks** | All job changes, transfers, promotions |

### Key Attributes

```yaml
Assignment:
  id: ASG-2024-001
  employee_id: EMP-2024-001
  work_relationship_id: WR-2024-001  # For non-employees
  
  # Staffing model
  staffing_model_code: POSITION_BASED  # or JOB_BASED
  
  # Job assignment
  position_id: POS-ENG-BACKEND-001  # If POSITION_BASED
  job_id: JOB-BACKEND-ENG  # If JOB_BASED or denormalized
  
  # Organization
  business_unit_id: BU-ENGINEERING
  legal_entity_code: VNG-VN
  
  # Reporting
  supervisor_assignment_id: ASG-MGR-001  # Solid line
  dotted_line_supervisor_id: ASG-LEAD-PROJ-A  # Dotted line (optional)
  
  # Work details
  primary_location_id: LOC-HCM-OFFICE
  fte: 1.0  # Full-time equivalent
  assignment_reason_code: HIRE  # HIRE, TRANSFER, PROMOTION, etc.
  
  # Dates
  effective_start_date: 2024-01-15
  effective_end_date: null
  is_current_flag: true
  is_primary_flag: true
```

### Assignment Reasons

| Code | Description | When Used |
|------|-------------|-----------|
| **HIRE** | New hire | First assignment for new employee |
| **TRANSFER** | Internal transfer | Move to different department/location |
| **PROMOTION** | Promotion | Move to higher-level position |
| **DEMOTION** | Demotion | Move to lower-level position |
| **RETURN** | Return from leave | Back from maternity/sabbatical |
| **RESTRUCTURE** | Reorganization | Due to company restructuring |
| **LATERAL_MOVE** | Lateral move | Same level, different role |

### Staffing Models

#### Position-Based Staffing
```yaml
Assignment:
  staffing_model_code: POSITION_BASED
  position_id: POS-ENG-001  # Specific budgeted position
  job_id: JOB-BACKEND-ENG  # Derived from position
  
# Characteristics:
# - Strict headcount control
# - Pre-approved budget
# - One person per position (typically)
```

#### Job-Based Staffing
```yaml
Assignment:
  staffing_model_code: JOB_BASED
  position_id: null  # No position
  job_id: JOB-BACKEND-ENG  # Direct job assignment
  
# Characteristics:
# - Flexible headcount
# - No pre-defined positions
# - Multiple people same job
```

### Real-World Scenarios

#### Scenario 1: New Hire
```yaml
# Day 1: Hired as Junior Engineer
Assignment: ASG-001
  employee_id: EMP-001
  job_id: JOB-JUNIOR-ENG
  business_unit_id: BU-BACKEND
  assignment_reason: HIRE
  effective_start: 2024-01-15
  effective_end: null
  is_current: true
```

#### Scenario 2: Promotion
```yaml
# After 2 years: Promoted to Senior Engineer
Assignment: ASG-001
  effective_end: 2026-01-14  # End previous assignment
  is_current: false

Assignment: ASG-002
  employee_id: EMP-001
  job_id: JOB-SENIOR-ENG  # Promoted!
  business_unit_id: BU-BACKEND
  assignment_reason: PROMOTION
  effective_start: 2026-01-15
  effective_end: null
  is_current: true
```

#### Scenario 3: Internal Transfer
```yaml
# Transfer from Backend to Frontend team
Assignment: ASG-002
  effective_end: 2026-06-30
  is_current: false

Assignment: ASG-003
  employee_id: EMP-001
  job_id: JOB-SENIOR-ENG
  business_unit_id: BU-FRONTEND  # Different team!
  assignment_reason: TRANSFER
  effective_start: 2026-07-01
  effective_end: null
  is_current: true
```

#### Scenario 4: Multiple Concurrent Assignments
```yaml
# Primary assignment (80% time)
Assignment: ASG-004
  employee_id: EMP-001
  job_id: JOB-SENIOR-ENG
  fte: 0.8
  is_primary: true
  
# Secondary assignment (20% time)
Assignment: ASG-005
  employee_id: EMP-001
  job_id: JOB-TECH-LEAD
  fte: 0.2
  is_primary: false
```

---

## 🔄 Complete Employment Lifecycle Examples

### Example 1: Standard Employee Journey

```yaml
# Step 1: Application (Worker created)
Worker: WORKER-001
  full_name: "Nguyễn Văn An"
  person_type: APPLICANT
  created: 2024-01-01

# Step 2: Hired (WorkRelationship + Employee + Assignment)
Worker: WORKER-001
  person_type: EMPLOYEE  # Updated

WorkRelationship: WR-001
  worker_id: WORKER-001
  type: EMPLOYEE
  start_date: 2024-01-15

Employee: EMP-001
  work_relationship_id: WR-001
  employee_number: "EMP-2024-001"
  hire_date: 2024-01-15
  probation_end_date: 2024-03-15

Assignment: ASG-001
  employee_id: EMP-001
  job_id: JOB-JUNIOR-BACKEND
  business_unit_id: BU-ENGINEERING
  assignment_reason: HIRE
  effective_start: 2024-01-15

# Step 3: Promoted (New Assignment)
Assignment: ASG-001
  effective_end: 2026-01-14
  is_current: false

Assignment: ASG-002
  employee_id: EMP-001
  job_id: JOB-SENIOR-BACKEND
  assignment_reason: PROMOTION
  effective_start: 2026-01-15

# Step 4: Transferred (New Assignment)
Assignment: ASG-002
  effective_end: 2027-06-30
  is_current: false

Assignment: ASG-003
  employee_id: EMP-001
  job_id: JOB-SENIOR-BACKEND
  business_unit_id: BU-PLATFORM  # New team!
  assignment_reason: TRANSFER
  effective_start: 2027-07-01

# Step 5: Resigned (End WorkRelationship)
WorkRelationship: WR-001
  end_date: 2028-12-31
  termination_reason: RESIGNATION
  status: TERMINATED

Employee: EMP-001
  employment_status: TERMINATED
  effective_end: 2028-12-31
  is_current: false

Assignment: ASG-003
  effective_end: 2028-12-31
  is_current: false

Worker: WORKER-001
  person_type: ALUMNUS  # Former employee
```

---

### Example 2: Contractor to Employee Conversion

```yaml
# Phase 1: Contractor (6 months)
Worker: WORKER-002
  full_name: "Trần Thị Bình"
  person_type: CONTRACTOR

WorkRelationship: WR-010
  worker_id: WORKER-002
  type: CONTRACTOR
  start_date: 2024-01-01
  end_date: 2024-06-30

# NO Employee record for contractors!

Assignment: ASG-010
  work_relationship_id: WR-010  # Links directly to WorkRelationship
  job_id: JOB-CONSULTANT
  effective_start: 2024-01-01
  effective_end: 2024-06-30

# Phase 2: Converted to Employee
Worker: WORKER-002
  person_type: EMPLOYEE  # Updated

WorkRelationship: WR-011
  worker_id: WORKER-002
  type: EMPLOYEE  # New relationship type!
  start_date: 2024-07-01

Employee: EMP-011  # NOW we have Employee record
  work_relationship_id: WR-011
  employee_number: "EMP-2024-011"
  hire_date: 2024-07-01
  original_hire_date: 2024-07-01

Assignment: ASG-011
  employee_id: EMP-011
  job_id: JOB-SENIOR-BACKEND
  assignment_reason: HIRE
  effective_start: 2024-07-01
```

---

### Example 3: Rehire with Seniority

```yaml
# First Employment Period (2020-2022)
Worker: WORKER-003
  full_name: "Lê Văn Cường"
  person_type: EMPLOYEE

WorkRelationship: WR-020
  worker_id: WORKER-003
  type: EMPLOYEE
  start_date: 2020-01-01
  end_date: 2022-12-31  # Resigned

Employee: EMP-020
  work_relationship_id: WR-020
  hire_date: 2020-01-01
  original_hire_date: 2020-01-01
  effective_end: 2022-12-31
  is_current: false

# Gap Period (2023)
Worker: WORKER-003
  person_type: ALUMNUS  # Former employee

# Rehired (2024)
Worker: WORKER-003
  person_type: EMPLOYEE  # Back to employee

WorkRelationship: WR-021
  worker_id: WORKER-003
  type: EMPLOYEE
  start_date: 2024-01-01

Employee: EMP-021
  work_relationship_id: WR-021
  hire_date: 2024-01-01
  original_hire_date: 2020-01-01  # PRESERVED from first hire!
  seniority_date: 2020-01-01  # Continuous service recognized

Assignment: ASG-021
  employee_id: EMP-021
  job_id: JOB-PRINCIPAL-ENG  # Came back at higher level
  assignment_reason: HIRE
  effective_start: 2024-01-01

# Benefits:
# - Complete history preserved
# - Seniority calculation includes both periods
# - No duplicate person data
```

---

## ✅ Best Practices

### 1. Worker Management
- ✅ Create Worker record as early as possible (application stage)
- ✅ Never delete Worker records (use soft delete for GDPR)
- ✅ Update person_type based on active relationships
- ✅ Maintain data classification properly

### 2. WorkRelationship Management
- ✅ Always set end_date when relationship terminates
- ✅ Use correct termination_reason_code
- ✅ Support concurrent relationships when needed
- ✅ Link to correct legal entity

### 3. Employee Management
- ✅ Only create for EMPLOYEE-type relationships
- ✅ Preserve original_hire_date for rehires
- ✅ Calculate seniority correctly
- ✅ Track probation periods

### 4. Assignment Management
- ✅ Always set assignment_reason correctly
- ✅ End previous assignment before creating new one
- ✅ Maintain is_primary_flag for multiple assignments
- ✅ Use correct staffing model

---

## ⚠️ Common Pitfalls

### Pitfall 1: Creating Multiple Workers for Same Person
❌ **Wrong**:
```yaml
# Contractor period
Worker: WORKER-001 (Contractor)

# Employee period
Worker: WORKER-002 (Employee)  # DUPLICATE!
```

✅ **Correct**:
```yaml
# Same worker, different relationships
Worker: WORKER-001
  WorkRelationship: WR-001 (CONTRACTOR)
  WorkRelationship: WR-002 (EMPLOYEE)
```

### Pitfall 2: Creating Employee Record for Contractors
❌ **Wrong**:
```yaml
WorkRelationship: WR-001
  type: CONTRACTOR

Employee: EMP-001  # WRONG! Contractors don't have Employee records
```

✅ **Correct**:
```yaml
WorkRelationship: WR-001
  type: CONTRACTOR
  
# NO Employee record
# Assignment links directly to WorkRelationship
```

### Pitfall 3: Not Ending Previous Assignment
❌ **Wrong**:
```yaml
# Old assignment still active
Assignment: ASG-001
  effective_end: null
  is_current: true

# New assignment also active
Assignment: ASG-002
  effective_end: null
  is_current: true  # CONFLICT!
```

✅ **Correct**:
```yaml
# End old assignment
Assignment: ASG-001
  effective_end: 2024-06-30
  is_current: false

# Start new assignment
Assignment: ASG-002
  effective_start: 2024-07-01
  effective_end: null
  is_current: true
```

---

## 📚 Related Guides

- [Organization Structure Guide](./02-organization-structure-guide.md) - Understanding business units and reporting
- [Job & Position Management Guide](./03-job-position-guide.md) - Jobs, positions, and staffing models
- [Data Model Guide](./04-data-model-guide.md) - Technical entity relationships

---

## 🎓 Quick Reference

### Decision Tree: Which Level to Update?

```
Need to update person's name?
  → Level 1: Worker

Need to change employment type (employee ↔ contractor)?
  → Level 2: WorkRelationship (create new)

Need to update hire date or employee number?
  → Level 3: Employee

Need to change job, department, or manager?
  → Level 4: Assignment (create new)
```

### Checklist: New Hire

- [ ] Create Worker record (if not exists)
- [ ] Update person_type to EMPLOYEE
- [ ] Create WorkRelationship (type: EMPLOYEE)
- [ ] Create Employee record
- [ ] Set hire_date and probation_end_date
- [ ] Create Assignment
- [ ] Set assignment_reason to HIRE
- [ ] Link to position/job, business unit, manager

### Checklist: Termination

- [ ] Set WorkRelationship.end_date
- [ ] Set termination_reason_code
- [ ] Update WorkRelationship.status to TERMINATED
- [ ] End Employee record (set effective_end_date)
- [ ] End all active Assignments
- [ ] Update Worker.person_type to ALUMNUS

---

**Document Version**: 1.0  
**Created**: 2025-12-02  
**Last Review**: 2025-12-02
