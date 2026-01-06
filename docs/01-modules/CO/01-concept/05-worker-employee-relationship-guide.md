# Worker-Employee Relationship Deep Dive

**Version**: 1.0  
**Created**: 2025-12-19  
**Audience**: Solution Architects, HR System Designers, Developers  
**Reading Time**: 45-60 minutes

---

## 📋 Purpose of This Guide

This guide provides an **in-depth explanation** of the Worker-WorkRelationship-Employee hierarchy, answering critical questions:

1. **Why** do we separate Worker, WorkRelationship, and Employee?
2. **What** are the different relationship types and when to use each?
3. **How** do we manage non-employee workers (contractors, contingent workers)?
4. **What** happens to data structures when there's no Employee record?
5. **How** do onboarding and termination flows differ by worker type?

---

## 🎯 The Core Design Principle

### Separation of Concerns

The xTalent Core Module uses a **4-level hierarchy** that separates different aspects of employment:

```
Level 1: Worker          → WHO is the person? (Identity)
Level 2: WorkRelationship → WHAT is the relationship? (Legal/contractual nature)
Level 3: Employee        → HOW are they employed? (Employment details - ONLY for employees)
Level 4: Assignment      → WHERE do they work? (Job/position assignment)
```

**Key Insight**: Not all workers are employees, but all employees are workers.

---

## 🧩 Level 1: Worker (Person Identity)

### Purpose
**Represents the PERSON**, independent of any employment or contractual relationship.

### Key Characteristics
- **Persistent**: Worker record never deleted, even after all relationships end
- **Unique**: One Worker = One Physical Person (no duplicates)
- **Universal**: Same Worker ID across all relationships with the organization

### Attributes
```yaml
Worker:
  id: WORKER-001
  full_name: "John Doe"
  date_of_birth: 1990-05-15
  national_id: "123456789"
  person_type: EMPLOYEE  # Current primary type
  email: "john.doe@example.com"
  phone: "+84-90-123-4567"
```

### Person Types
| Type | Description | Has Employee Record? |
|------|-------------|---------------------|
| **EMPLOYEE** | Current employee (including paid interns) | Yes (active) |
| **CONTRACTOR** | Independent contractor | No |
| **CONTINGENT** | Temp/agency worker | No |
| **NON_WORKER** | Volunteer, unpaid intern, board member | No |
| **ALUMNUS** | Former employee | No (terminated) |
| **APPLICANT** | Job applicant | No |

**Important**: `person_type` reflects the **current primary relationship type**, not a permanent classification.

> **Note**: Paid interns are type=EMPLOYEE with `employee_class_code=INTERN`. Unpaid interns and volunteers are type=NON_WORKER.

---

## 🔗 Level 2: WorkRelationship (The Relationship Nature)

### Purpose
**Defines the NATURE of the working relationship** between a Worker and a Legal Entity.

### Why This Level Exists

**Problem**: In traditional systems, "Employee" conflates two concepts:
1. The legal/contractual relationship (employee vs contractor)
2. The employment details (hire date, employee number)

**Solution**: WorkRelationship separates the **type of relationship** from the **details of employment**.

### Key Characteristics
- **One Worker, Multiple Relationships**: A worker can have concurrent relationships with different legal entities or in different capacities
- **Relationship-Centric**: Focuses on WHAT the relationship is, not HOW it's executed
- **Type-Driven**: The `relationship_type_code` determines what downstream records are required

### Relationship Types

#### 1. EMPLOYEE
```yaml
WorkRelationship:
  relationship_type_code: EMPLOYEE
  legal_entity_code: VNG-VN
  status_code: ACTIVE
  start_date: 2024-01-15
```

**Characteristics**:
- **Requires Employee record**: YES ✅
- **Has employment contract**: YES
- **Payroll**: Internal
- **Benefits eligible**: YES
- **Tax withholding**: W-2 (US) or equivalent
- **Supervision**: Direct organizational hierarchy

**When to Use**:
- Regular full-time/part-time employees
- Executives
- Probationary employees
- Seasonal employees (if on payroll)

---

#### 2. CONTRACTOR
```yaml
WorkRelationship:
  relationship_type_code: CONTRACTOR
  legal_entity_code: VNG-VN
  status_code: ACTIVE
  start_date: 2024-01-15
  supplier_id: null  # Independent, not through agency
```

**Characteristics**:
- **Requires Employee record**: NO ❌
- **Has service contract**: YES (but not employment contract)
- **Payroll**: External (contractor invoices)
- **Benefits eligible**: NO
- **Tax withholding**: 1099 (US) or equivalent
- **Supervision**: SOW-based, not direct management

**When to Use**:
- Independent consultants
- Freelancers
- Professional services (legal, accounting)
- Specialized expertise for projects

**Why No Employee Record?**:
- Not on company payroll
- No employment benefits
- Different legal relationship (service provider, not employee)
- Tax treatment differs

---

#### 3. CONTINGENT
```yaml
WorkRelationship:
  relationship_type_code: CONTINGENT
  legal_entity_code: VNG-VN
  status_code: ACTIVE
  start_date: 2024-01-15
  supplier_id: AGENCY-001  # Staffing agency
```

**Characteristics**:
- **Requires Employee record**: NO ❌
- **Has contract**: With staffing agency, not company
- **Payroll**: Agency payroll
- **Benefits eligible**: Through agency
- **Tax withholding**: Agency responsibility
- **Supervision**: Company can direct work

**When to Use**:
- Temporary workers from staffing agencies
- Contract-to-hire candidates
- Seasonal surge capacity
- Project-based augmentation

**Why No Employee Record?**:
- Employed by the agency, not the company
- Company pays agency, agency pays worker
- Different legal employer

---

#### 4. NON_WORKER
```yaml
WorkRelationship:
  relationship_type_code: NON_WORKER
  legal_entity_code: VNG-FOUNDATION
  status_code: ACTIVE
  start_date: 2024-01-01
```

**Characteristics**:
- **Requires Employee record**: NO ❌
- **Has contract**: Volunteer agreement or none
- **Payroll**: NO (unpaid)
- **Benefits eligible**: NO
- **Tax withholding**: NO
- **Supervision**: Coordination-based

**When to Use**:
- **Unpaid interns** (educational credit only)
- **Volunteers** (non-profit, community service)
- **Board members** (non-executive directors)
- **Dependents** tracked for benefits purposes

---

### Special Case: Interns

Interns are NOT a separate relationship type. They are handled based on compensation:

| Intern Type | WorkRelationship Type | Employee Record | Employee Class |
|-------------|----------------------|-----------------|----------------|
| **Paid Intern** | EMPLOYEE | ✅ Yes | INTERN |
| **Unpaid Intern** | NON_WORKER | ❌ No | N/A |

**Example: Paid Intern**
```yaml
WorkRelationship:
  relationship_type_code: EMPLOYEE  # Not INTERN
  legal_entity_code: VNG-VN
  
Employee:
  employee_class_code: INTERN  # Classification here
  hire_date: 2024-06-01
```

**Example: Unpaid Intern**
```yaml
WorkRelationship:
  relationship_type_code: NON_WORKER  # No labor relationship
  legal_entity_code: VNG-VN
  
# NO Employee record
```

---

### Multiple Concurrent Relationships

**Scenario**: Same person, different capacities

```yaml
Worker: WORKER-001 (Jane Smith)

# Relationship 1: Full-time employee
WorkRelationship#1:
  id: WR-001
  worker_id: WORKER-001
  legal_entity_code: VNG-VN
  relationship_type_code: EMPLOYEE
  is_primary_relationship: true
  status_code: ACTIVE

Employee#1:
  work_relationship_id: WR-001
  employee_code: "EMP-2024-100"
  hire_date: 2024-01-15

# Relationship 2: Part-time contractor (different entity)
WorkRelationship#2:
  id: WR-002
  worker_id: WORKER-001  # Same person!
  legal_entity_code: VNG-SG
  relationship_type_code: CONTRACTOR
  is_primary_relationship: false
  status_code: ACTIVE

# NO Employee#2 - contractor relationship
```

**Key Points**:
- Same `worker_id` across both relationships
- Only ONE Employee record (for the EMPLOYEE relationship)
- `is_primary_relationship` flag indicates main relationship
- Different legal entities can have different relationship types

---

## 👔 Level 3: Employee (Employment Details)

### Purpose
**Stores employment-specific data** for workers with EMPLOYEE-type relationships.

### When Employee Record Exists

```
WorkRelationship.relationship_type_code = EMPLOYEE
  → Employee record REQUIRED ✅
  
WorkRelationship.relationship_type_code = CONTRACTOR
  → Employee record FORBIDDEN ❌
  
WorkRelationship.relationship_type_code = CONTINGENT
  → Employee record FORBIDDEN ❌
  
WorkRelationship.relationship_type_code = NON_WORKER
  → Employee record FORBIDDEN ❌
```

### Employee-Specific Data

```yaml
Employee:
  work_relationship_id: WR-001
  worker_id: WORKER-001  # Denormalized
  legal_entity_code: UUID  # Denormalized
  employee_code: "EMP-2024-001"  # Unique within legal entity
  employee_class_code: REGULAR  # REGULAR, PROBATION, TEMPORARY, etc.
  status_code: ACTIVE  # ACTIVE, TERMINATED, SUSPENDED
  hire_date: 2024-01-15
  termination_date: null
  probation_end_date: 2024-04-15
  seniority_date: 2024-01-15
```

### Employee Classification Codes

| Code | Description | Typical Use |
|------|-------------|-------------|
| **REGULAR** | Regular employee | Post-probation, standard employment |
| **PROBATION** | Probationary period | New hires, trial period |
| **TEMPORARY** | Temporary employee | Fixed-term, project-based |
| **PART_TIME** | Part-time employee | < Full-time hours |
| **SEASONAL** | Seasonal employee | Recurring seasonal work |
| **TRAINEE** | Training program | Graduate programs, apprenticeships |

**Note**: `employee_class_code` is about the **status/stage** of employment, not the type of worker.

---

## 📋 Level 4: Assignment (Work Assignment)

### Purpose
**Defines WHERE and WHAT work is performed**, regardless of worker type.

### Assignment for Different Worker Types

#### Employees (with Employee Record)
```yaml
Assignment:
  employee_id: EMP-001  # Link to Employee
  work_relationship_id: null  # Not used
  staffing_model_code: POSITION_BASED
  position_id: POS-MGR-001
  job_id: JOB-MANAGER
  business_unit_id: BU-FINANCE
  fte: 1.0
```

#### Contractors (no Employee Record)
```yaml
Assignment:
  employee_id: null  # No Employee record
  work_relationship_id: WR-CONT-001  # Direct link to WorkRelationship
  staffing_model_code: JOB_BASED
  position_id: null  # No budgeted position
  job_id: JOB-CONSULTANT
  business_unit_id: BU-IT
  fte: 0.5
```

#### Contingent Workers (no Employee Record)
```yaml
Assignment:
  employee_id: null
  work_relationship_id: WR-TEMP-001
  staffing_model_code: JOB_BASED
  position_id: null
  job_id: JOB-WAREHOUSE-WORKER
  business_unit_id: BU-LOGISTICS
  fte: 1.0
```

### Key Insight: Assignment Flexibility

**The Assignment entity is designed to work with OR without an Employee record**:

```yaml
# Business Rule
Assignment:
  # EITHER employee_id OR work_relationship_id (not both)
  # IF WorkRelationship.type = EMPLOYEE → use employee_id
  # IF WorkRelationship.type != EMPLOYEE → use work_relationship_id
```

This design allows **uniform work assignment tracking** regardless of worker type.

---

## 🔄 Data Structures for Non-Employee Workers

### The Question
**"If there's no Employee record, how do we manage contractors and contingent workers?"**

### The Answer: Direct WorkRelationship Linkage

#### Traditional Approach (WRONG)
```
Worker → Employee → Assignment
         ↑
         Required for ALL workers
```
**Problem**: Forces creation of "fake" Employee records for contractors.

#### xTalent Approach (CORRECT)
```
Worker → WorkRelationship → Employee → Assignment (for employees)
                         ↓
                         → Assignment (for non-employees, direct link)
```

### Data Structure Comparison

#### For Employees
```yaml
# Full hierarchy
Worker:
  id: WORKER-001
  
WorkRelationship:
  id: WR-001
  worker_id: WORKER-001
  relationship_type_code: EMPLOYEE
  
Employee:
  id: EMP-001
  work_relationship_id: WR-001
  employee_code: "EMP-2024-001"
  
Assignment:
  id: ASG-001
  employee_id: EMP-001  # Links to Employee
  work_relationship_id: null
```

#### For Contractors
```yaml
# Skips Employee level
Worker:
  id: WORKER-002
  
WorkRelationship:
  id: WR-002
  worker_id: WORKER-002
  relationship_type_code: CONTRACTOR
  
# NO Employee record
  
Assignment:
  id: ASG-002
  employee_id: null
  work_relationship_id: WR-002  # Links directly to WorkRelationship
```

### What Data Goes Where?

| Data Type | Employees | Contractors | Contingent Workers |
|-----------|-----------|-------------|-------------------|
| **Identity** (name, DOB) | Worker | Worker | Worker |
| **Relationship** (type, dates) | WorkRelationship | WorkRelationship | WorkRelationship |
| **Employee Code** | Employee | N/A | N/A |
| **Hire Date** | Employee | N/A | N/A |
| **Employment Class** | Employee | N/A | N/A |
| **Contract** | Contract (via Employee) | Contract (via WR) | Contract (via WR) |
| **Assignment** | Assignment (via Employee) | Assignment (via WR) | Assignment (via WR) |
| **Payroll** | Payroll (via Employee) | Invoice (external) | Agency (external) |
| **Benefits** | Benefits (via Employee) | N/A | N/A (or via agency) |
| **Time Tracking** | Timesheet (via Assignment) | Timesheet (via Assignment) | Timesheet (via Assignment) |

### Contract Management

**Contracts can link to EITHER Employee OR WorkRelationship**:

```yaml
# For Employees
Contract:
  employee_id: EMP-001
  work_relationship_id: null
  contract_type_code: PERMANENT
  
# For Contractors
Contract:
  employee_id: null
  work_relationship_id: WR-002
  contract_type_code: SERVICE_AGREEMENT
```

This allows **uniform contract management** regardless of worker type.

---

## 🚀 Onboarding Flows by Worker Type

### Flow 1: Regular Employee Onboarding

```yaml
# Step 1: Create Worker
Worker:
  full_name: "Alice Johnson"
  person_type: EMPLOYEE
  
# Step 2: Create WorkRelationship
WorkRelationship:
  worker_id: WORKER-001
  relationship_type_code: EMPLOYEE
  legal_entity_code: VNG-VN
  start_date: 2024-01-15
  
# Step 3: Create Employee
Employee:
  work_relationship_id: WR-001
  employee_code: "EMP-2024-001"
  employee_class_code: PROBATION
  hire_date: 2024-01-15
  probation_end_date: 2024-04-15
  
# Step 4: Create Contract
Contract:
  employee_id: EMP-001
  contract_type_code: PROBATION
  start_date: 2024-01-15
  end_date: 2024-04-15
  
# Step 5: Create Assignment
Assignment:
  employee_id: EMP-001
  staffing_model_code: POSITION_BASED
  position_id: POS-DEV-001
  start_date: 2024-01-15
```

**Required Records**: Worker, WorkRelationship, Employee, Contract, Assignment

---

### Flow 2: Contractor Onboarding

```yaml
# Step 1: Create Worker
Worker:
  full_name: "Bob Smith"
  person_type: CONTRACTOR
  
# Step 2: Create WorkRelationship
WorkRelationship:
  worker_id: WORKER-002
  relationship_type_code: CONTRACTOR
  legal_entity_code: VNG-VN
  start_date: 2024-02-01
  
# Step 3: Skip Employee (not applicable)

# Step 4: Create Contract (links to WorkRelationship)
Contract:
  work_relationship_id: WR-002
  contract_type_code: SERVICE_AGREEMENT
  start_date: 2024-02-01
  end_date: 2024-08-01
  
# Step 5: Create Assignment
Assignment:
  work_relationship_id: WR-002  # Direct link
  staffing_model_code: JOB_BASED
  job_id: JOB-CONSULTANT
  start_date: 2024-02-01
```

**Required Records**: Worker, WorkRelationship, Contract, Assignment  
**Skipped**: Employee (not applicable for contractors)

---

### Flow 3: Contingent Worker Onboarding

```yaml
# Step 1: Create Worker
Worker:
  full_name: "Carol White"
  person_type: CONTINGENT
  
# Step 2: Create WorkRelationship
WorkRelationship:
  worker_id: WORKER-003
  relationship_type_code: CONTINGENT
  legal_entity_code: VNG-VN
  supplier_id: AGENCY-001  # Staffing agency
  start_date: 2024-03-01
  
# Step 3: Skip Employee (employed by agency)

# Step 4: Create Contract (with agency)
Contract:
  work_relationship_id: WR-003
  contract_type_code: AGENCY_AGREEMENT
  supplier_id: AGENCY-001
  start_date: 2024-03-01
  end_date: 2024-06-01
  
# Step 5: Create Assignment
Assignment:
  work_relationship_id: WR-003
  staffing_model_code: JOB_BASED
  job_id: JOB-TEMP-ADMIN
  start_date: 2024-03-01
```

**Required Records**: Worker, WorkRelationship, Contract, Assignment  
**Skipped**: Employee (employed by agency, not company)

---

## 🔚 Termination Flows by Worker Type

### Flow 1: Employee Termination

```yaml
# Step 1: End Assignment
Assignment:
  effective_end_date: 2024-12-31
  is_current_flag: false
  
# Step 2: Terminate Employee
Employee:
  status_code: TERMINATED
  termination_date: 2024-12-31
  effective_end_date: 2024-12-31
  is_current_flag: false
  
# Step 3: Terminate WorkRelationship
WorkRelationship:
  status_code: TERMINATED
  end_date: 2024-12-31
  termination_reason_code: "RESIGNATION"
  termination_type_code: VOLUNTARY
  
# Step 4: Update Worker
Worker:
  person_type: ALUMNUS  # Former employee
```

**Order**: Assignment → Employee → WorkRelationship → Worker  
**All records preserved** for historical tracking.

---

### Flow 2: Contractor End of Engagement

```yaml
# Step 1: End Assignment
Assignment:
  effective_end_date: 2024-08-01
  is_current_flag: false
  
# Step 2: Skip Employee (doesn't exist)

# Step 3: End WorkRelationship
WorkRelationship:
  status_code: TERMINATED
  end_date: 2024-08-01
  termination_reason_code: "CONTRACT_COMPLETION"
  termination_type_code: END_OF_CONTRACT
  
# Step 4: Update Worker
Worker:
  person_type: CONTRACTOR  # Remains contractor (not alumnus)
```

**Order**: Assignment → WorkRelationship → Worker  
**Simpler flow** (no Employee to terminate)

---

### Flow 3: Contingent Worker Release

```yaml
# Step 1: End Assignment
Assignment:
  effective_end_date: 2024-06-01
  is_current_flag: false
  
# Step 2: Skip Employee (doesn't exist)

# Step 3: End WorkRelationship
WorkRelationship:
  status_code: TERMINATED
  end_date: 2024-06-01
  termination_reason_code: "ASSIGNMENT_COMPLETE"
  termination_type_code: END_OF_CONTRACT
  
# Step 4: Update Worker
Worker:
  person_type: CONTINGENT
```

**Order**: Assignment → WorkRelationship → Worker

---

## 📊 Downstream System Integration

### How Downstream Systems Handle Non-Employees

#### Payroll System
```yaml
# Employees
Payroll:
  employee_id: EMP-001  # Links to Employee
  pay_period: 2024-01
  gross_pay: 50000000
  
# Contractors (NO payroll record)
# Company pays contractor via invoice, not payroll

# Contingent Workers (NO payroll record)
# Company pays agency, agency pays worker
```

#### Benefits System
```yaml
# Employees
BenefitsEnrollment:
  employee_id: EMP-001
  plan_id: HEALTH-PLAN-001
  
# Contractors (NO benefits)
# Not eligible for company benefits

# Contingent Workers (NO company benefits)
# May have benefits through agency
```

#### Time & Attendance
```yaml
# Employees
Timesheet:
  assignment_id: ASG-001  # Links to Assignment
  worker_id: WORKER-001
  
# Contractors
Timesheet:
  assignment_id: ASG-002  # Links to Assignment
  worker_id: WORKER-002
  
# Contingent Workers
Timesheet:
  assignment_id: ASG-003  # Links to Assignment
  worker_id: WORKER-003
```

**Key Point**: Time tracking works **uniformly** via Assignment, regardless of worker type.

#### Performance Management
```yaml
# Employees
PerformanceReview:
  employee_id: EMP-001
  review_period: 2024-Q1
  
# Contractors (Usually NO formal reviews)
# May have project evaluations via Assignment

# Contingent Workers (Usually NO formal reviews)
# Managed by agency
```

---

## 🎯 Design Rationale: Why This Complexity?

### Question: "Why not just use Employee for everyone?"

### Answer: Legal, Tax, and Operational Differences

#### Legal Differences
| Aspect | Employee | Contractor | Contingent Worker |
|--------|----------|------------|-------------------|
| **Employer** | Company | Self | Agency |
| **Control** | Direct supervision | SOW-based | Company directs, agency employs |
| **Benefits** | Required | Not provided | Agency provides |
| **Termination** | Notice required | Contract end | Agency manages |
| **Liability** | Company | Contractor | Agency |

#### Tax Differences
| Aspect | Employee | Contractor | Contingent Worker |
|--------|----------|------------|-------------------|
| **Tax Form (US)** | W-2 | 1099 | W-2 (from agency) |
| **Withholding** | Company | Self | Agency |
| **Payroll Tax** | Company pays | Contractor pays | Agency pays |
| **Benefits Tax** | Taxable | N/A | N/A |

#### Operational Differences
| Aspect | Employee | Contractor | Contingent Worker |
|--------|----------|------------|-------------------|
| **Onboarding** | Full HR process | Vendor management | Agency coordination |
| **Equipment** | Company provides | Self-provided | Varies |
| **Training** | Company mandatory | Optional | Varies |
| **Performance** | Annual reviews | Project-based | Agency manages |

**Conclusion**: These are **fundamentally different relationships** that cannot be accurately modeled with a single "Employee" entity.

---

## ✅ Best Practices

### 1. Always Create Worker First
```yaml
# CORRECT
Worker → WorkRelationship → Employee/Contract → Assignment

# WRONG
Employee → Worker (backward dependency)
```

### 2. Use Correct Relationship Type
```yaml
# CORRECT
Contractor → relationship_type_code: CONTRACTOR

# WRONG
Contractor → relationship_type_code: EMPLOYEE (legal/tax issues)
```

### 3. Don't Create Employee for Non-Employees
```yaml
# CORRECT
Contractor → WorkRelationship → Assignment (no Employee)

# WRONG
Contractor → WorkRelationship → Employee (violates design)
```

### 4. Link Assignments Correctly
```yaml
# For Employees
Assignment:
  employee_id: EMP-001
  work_relationship_id: null

# For Non-Employees
Assignment:
  employee_id: null
  work_relationship_id: WR-002
```

### 5. Preserve History
```yaml
# CORRECT
Terminated WorkRelationship:
  status_code: TERMINATED
  end_date: 2024-12-31
  # Record preserved

# WRONG
# Delete WorkRelationship (loses history)
```

---

## 🔗 Related Documents

- [Employment Lifecycle Guide](file:///Users/nguyenhuyvu/Library/CloudStorage/OneDrive-VNGCorporation/Apps/mygit/a4b-doc-xtalent/product/xTalent/docs/01-modules/CO/01-concept/01-employment-lifecycle-guide.md) - Lifecycle scenarios
- [Glossary (English)](file:///Users/nguyenhuyvu/Library/CloudStorage/OneDrive-VNGCorporation/Apps/mygit/a4b-doc-xtalent/product/xTalent/docs/01-modules/CO/00-ontology/glossary-employment.md) - Entity definitions
- [Glossary (Vietnamese)](file:///Users/nguyenhuyvu/Library/CloudStorage/OneDrive-VNGCorporation/Apps/mygit/a4b-doc-xtalent/product/xTalent/docs/01-modules/CO/00-ontology/glossary-employment-vi.md) - Vietnamese definitions
- [Business Rules](file:///Users/nguyenhuyvu/Library/CloudStorage/OneDrive-VNGCorporation/Apps/mygit/a4b-doc-xtalent/product/xTalent/docs/01-modules/CO/02-spec/04-business-rules.md) - Validation rules

---

**Document Version**: 1.0  
**Created**: 2025-12-19  
**Author**: xTalent Architecture Team
