# Core Module (CO) - Data Specification

**Version**: 2.0  
**Last Updated**: 2025-12-03  
**Module**: Core (CO)  
**Status**: Complete - Production-Ready Data Models

---

## 📋 Overview

This document defines the complete data specification for the Core Module, including data models, validation rules, constraints, and data quality standards. All specifications are derived from the Core Ontology and aligned with functional requirements.

### Document Purpose

- **Data Models**: Complete entity definitions with attributes and relationships
- **Validation Rules**: Field-level and entity-level validation
- **Constraints**: Uniqueness, referential integrity, business constraints
- **Data Quality**: Standards for data accuracy, completeness, and consistency
- **SCD Type 2**: Temporal data management for historical tracking

---

## 🏗️ Data Architecture Principles

### 1. Temporal Data Management (SCD Type 2)

**All core entities use SCD Type 2** for historical tracking:

```yaml
Standard SCD Type 2 Fields:
  effective_start_date:
    type: date
    required: true
    description: "When this version becomes effective"
  
  effective_end_date:
    type: date
    required: false
    description: "When this version ends (null = current)"
  
  is_current_flag:
    type: boolean
    default: true
    description: "True for current version, false for historical"
```

**Business Rules**:
- Only ONE version can have `is_current_flag = true` per entity
- `effective_end_date` must be NULL for current version
- `effective_start_date` must be <= `effective_end_date` (if not null)
- New version's `effective_start_date` = previous version's `effective_end_date` + 1 day

---

### 2. Data Classification

All fields are classified for privacy and security:

| Classification | Description | Access Control | Examples |
|----------------|-------------|----------------|----------|
| **PUBLIC** | Publicly accessible | All authenticated users | Full name, job title, department |
| **INTERNAL** | Internal use only | Same organization | Email, phone, office location |
| **CONFIDENTIAL** | Sensitive data | Manager + HR | Date of birth, address, performance ratings |
| **RESTRICTED** | Highly sensitive | HR only with purpose | National ID, passport, salary, bank account |

**Enforcement**: BR-PRI-001 (Data Classification Enforcement)

---

### 3. Audit Trail

All data modifications are logged:

```yaml
Audit Fields (System-Managed):
  created_at:
    type: timestamp
    required: true
    description: "Record creation timestamp"
  
  created_by:
    type: UUID
    required: true
    description: "User who created the record"
  
  updated_at:
    type: timestamp
    required: false
    description: "Last update timestamp"
  
  updated_by:
    type: UUID
    required: false
    description: "User who last updated the record"
```

---

## 📊 Entity Specifications

### Phase 0: Configuration & Code Lists

#### Entity: CodeList

**Purpose**: Multi-purpose lookup table for system-wide code values

**Table**: `code_lists`

**Attributes**:

| Field | Type | Required | Max Length | Default | Classification | Description |
|-------|------|----------|------------|---------|----------------|-------------|
| `id` | UUID | Yes | - | UUID() | PUBLIC | Primary key |
| `group_code` | VARCHAR | Yes | 50 | - | PUBLIC | Code group (e.g., GENDER, MARITAL_STATUS) |
| `code` | VARCHAR | Yes | 50 | - | PUBLIC | Code value (e.g., M, F, SINGLE) |
| `display_en` | VARCHAR | No | 100 | - | PUBLIC | English display text |
| `display_local` | VARCHAR | No | 100 | - | PUBLIC | Local language display text |
| `sort_order` | INTEGER | No | - | 0 | PUBLIC | Display order within group |
| `metadata` | JSONB | No | - | {} | PUBLIC | Additional attributes |
| `effective_start_date` | DATE | Yes | - | - | PUBLIC | SCD Type 2 start date |
| `effective_end_date` | DATE | No | - | NULL | PUBLIC | SCD Type 2 end date |
| `is_current_flag` | BOOLEAN | Yes | - | true | PUBLIC | SCD Type 2 current flag |

**Validation Rules**:

```yaml
VR-CL-001: group_code Format
  rule: "group_code must match pattern: ^[A-Z][A-Z0-9_]*$"
  example: "GENDER, MARITAL_STATUS, EMPLOYEE_TYPE"
  error: "Code group must be UPPERCASE with underscores"

VR-CL-002: code Format
  rule: "code must match pattern: ^[A-Z0-9_-]+$"
  example: "M, F, FULL_TIME, PART_TIME"
  error: "Code must be alphanumeric with underscores/hyphens"

VR-CL-003: display_en Required
  rule: "display_en is required for user-facing code lists"
  condition: "group_code not in SYSTEM_INTERNAL_CODES"
  error: "Display text is required"

VR-CL-004: sort_order Range
  rule: "sort_order must be between 0 and 9999"
  error: "Sort order out of range"

VR-CL-005: Effective Date Logic
  rule: "effective_start_date <= effective_end_date (if not null)"
  error: "Start date must be before or equal to end date"
```

**Constraints**:

```sql
-- Unique constraint
CONSTRAINT uk_code_list_group_code 
  UNIQUE (group_code, code, effective_start_date);

-- Check constraint
CONSTRAINT ck_code_list_dates 
  CHECK (effective_end_date IS NULL OR effective_start_date <= effective_end_date);

-- Check constraint
CONSTRAINT ck_code_list_current_flag 
  CHECK ((is_current_flag = true AND effective_end_date IS NULL) OR 
         (is_current_flag = false AND effective_end_date IS NOT NULL));
```

**Indexes**:

```sql
-- Primary key index (automatic)
CREATE UNIQUE INDEX pk_code_lists ON code_lists(id);

-- Lookup index
CREATE INDEX idx_code_lists_group_code ON code_lists(group_code, is_current_flag);

-- Current records index
CREATE INDEX idx_code_lists_current ON code_lists(is_current_flag) 
  WHERE is_current_flag = true;
```

**Business Rules**: BR-CFG-001, BR-CFG-002, BR-CFG-003, BR-CFG-004, BR-CFG-005

---

### Phase 1: Worker Management

#### Entity: Worker

**Purpose**: Master record for all people (employees, contractors, candidates)

**Table**: `workers`

**Attributes**:

| Field | Type | Required | Max Length | Default | Classification | Description |
|-------|------|----------|------------|---------|----------------|-------------|
| `id` | UUID | Yes | - | UUID() | PUBLIC | Primary key |
| `code` | VARCHAR | Yes | 50 | AUTO | PUBLIC | Auto-generated worker code (WORKER-NNNNNN) |
| `full_name` | VARCHAR | Yes | 200 | - | PUBLIC | Full legal name |
| `preferred_name` | VARCHAR | No | 100 | - | PUBLIC | Preferred/nickname |
| `date_of_birth` | DATE | Yes | - | - | CONFIDENTIAL | Date of birth |
| `gender_code` | VARCHAR | Yes | 20 | - | PUBLIC | Gender code (from CodeList) |
| `person_type` | VARCHAR | Yes | 50 | - | PUBLIC | EMPLOYEE, CONTRACTOR, CONSULTANT, CANDIDATE |
| `national_id` | VARCHAR | No | 50 | - | RESTRICTED | National ID/SSN |
| `passport_number` | VARCHAR | No | 50 | - | RESTRICTED | Passport number |
| `email` | VARCHAR | No | 255 | - | INTERNAL | Primary email |
| `phone` | VARCHAR | No | 50 | - | INTERNAL | Primary phone |
| `marital_status_code` | VARCHAR | No | 20 | - | CONFIDENTIAL | Marital status |
| `nationality_code` | VARCHAR | No | 3 | - | CONFIDENTIAL | ISO country code |
| `metadata` | JSONB | No | - | {} | INTERNAL | Additional attributes |
| `effective_start_date` | DATE | Yes | - | - | PUBLIC | SCD Type 2 start |
| `effective_end_date` | DATE | No | - | NULL | PUBLIC | SCD Type 2 end |
| `is_current_flag` | BOOLEAN | Yes | - | true | PUBLIC | SCD Type 2 current |

**Validation Rules**:

```yaml
VR-WRK-001: Full Name Required
  rule: "full_name must be provided and not empty"
  minLength: 2
  maxLength: 200
  error: "Full name is required (2-200 characters)"

VR-WRK-002: Date of Birth Valid
  rule: "date_of_birth must be a past date"
  condition: "date_of_birth < CURRENT_DATE"
  error: "Date of birth must be in the past"

VR-WRK-003: Date of Birth Reasonable
  rule: "date_of_birth must be within reasonable range"
  condition: "CURRENT_DATE - date_of_birth BETWEEN 16 years AND 100 years"
  error: "Date of birth must be between 16 and 100 years ago"

VR-WRK-004: Email Format
  rule: "email must be valid email format"
  regex: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
  error: "Invalid email format"

VR-WRK-005: Phone Format
  rule: "phone must be valid phone format"
  regex: "^\\+?[0-9]{8,15}$"
  error: "Invalid phone format (8-15 digits, optional +)"

VR-WRK-006: National ID Unique
  rule: "national_id must be unique if provided"
  condition: "national_id IS NOT NULL"
  error: "National ID already exists"

VR-WRK-007: Person Type Valid
  rule: "person_type must be valid code value"
  values: [EMPLOYEE, CONTRACTOR, CONSULTANT, CANDIDATE, INTERN]
  error: "Invalid person type"

VR-WRK-008: Gender Code Valid
  rule: "gender_code must exist in CodeList.GENDER"
  error: "Invalid gender code"
```

**Constraints**:

```sql
-- Unique worker code
CONSTRAINT uk_worker_code 
  UNIQUE (code);

-- Unique national ID (if provided)
CONSTRAINT uk_worker_national_id 
  UNIQUE (national_id) 
  WHERE national_id IS NOT NULL AND is_current_flag = true;

-- Unique email (if provided)
CONSTRAINT uk_worker_email 
  UNIQUE (email) 
  WHERE email IS NOT NULL AND is_current_flag = true;

-- Check date of birth
CONSTRAINT ck_worker_dob 
  CHECK (date_of_birth < CURRENT_DATE);

-- Check person type
CONSTRAINT ck_worker_person_type 
  CHECK (person_type IN ('EMPLOYEE', 'CONTRACTOR', 'CONSULTANT', 'CANDIDATE', 'INTERN'));
```

**Indexes**:

```sql
CREATE UNIQUE INDEX pk_workers ON workers(id);
CREATE UNIQUE INDEX uk_workers_code ON workers(code);
CREATE INDEX idx_workers_name ON workers(full_name);
CREATE INDEX idx_workers_email ON workers(email) WHERE email IS NOT NULL;
CREATE INDEX idx_workers_national_id ON workers(national_id) WHERE national_id IS NOT NULL;
CREATE INDEX idx_workers_current ON workers(is_current_flag) WHERE is_current_flag = true;
```

**Business Rules**: BR-WRK-001, BR-WRK-002, BR-WRK-004, BR-WRK-005, BR-WRK-006

---

#### Entity: WorkRelationship

**Purpose**: Employment relationship between worker and legal entity

**Table**: `work_relationships`

**Attributes**:

| Field | Type | Required | Max Length | Default | Classification | Description |
|-------|------|----------|------------|---------|----------------|-------------|
| `id` | UUID | Yes | - | UUID() | PUBLIC | Primary key |
| `worker_id` | UUID | Yes | - | - | PUBLIC | FK to workers |
| `legal_entity_id` | UUID | Yes | - | - | PUBLIC | FK to entities |
| `relationship_type` | VARCHAR | Yes | 50 | - | PUBLIC | EMPLOYEE, CONTRACTOR, CONSULTANT |
| `employment_type` | VARCHAR | No | 50 | - | PUBLIC | FULL_TIME, PART_TIME, CASUAL |
| `contract_type` | VARCHAR | No | 50 | - | PUBLIC | PERMANENT, FIXED_TERM, CASUAL |
| `start_date` | DATE | Yes | - | - | PUBLIC | Relationship start date |
| `end_date` | DATE | No | - | NULL | PUBLIC | Relationship end date |
| `probation_period_days` | INTEGER | No | - | NULL | INTERNAL | Probation period in days |
| `probation_end_date` | DATE | No | - | NULL | INTERNAL | Calculated probation end |
| `notice_period_days` | INTEGER | No | - | NULL | INTERNAL | Notice period in days |
| `status` | VARCHAR | Yes | 20 | ACTIVE | PUBLIC | ACTIVE, SUSPENDED, TERMINATED |
| `termination_reason_code` | VARCHAR | No | 50 | - | CONFIDENTIAL | Termination reason |
| `termination_type` | VARCHAR | No | 50 | - | CONFIDENTIAL | VOLUNTARY, INVOLUNTARY |
| `fte` | DECIMAL(3,2) | No | - | 1.00 | INTERNAL | Full-time equivalent (0.01-1.00) |
| `metadata` | JSONB | No | - | {} | INTERNAL | Additional attributes |
| `effective_start_date` | DATE | Yes | - | - | PUBLIC | SCD Type 2 start |
| `effective_end_date` | DATE | No | - | NULL | PUBLIC | SCD Type 2 end |
| `is_current_flag` | BOOLEAN | Yes | - | true | PUBLIC | SCD Type 2 current |

**Validation Rules**:

```yaml
VR-WR-001: Start Date Required
  rule: "start_date is required"
  error: "Start date is required"

VR-WR-002: End Date After Start
  rule: "end_date must be after start_date if provided"
  condition: "end_date IS NULL OR end_date > start_date"
  error: "End date must be after start date"

VR-WR-003: Relationship Type Valid
  rule: "relationship_type must be valid"
  values: [EMPLOYEE, CONTRACTOR, CONSULTANT, INTERN]
  error: "Invalid relationship type"

VR-WR-004: Employment Type Valid
  rule: "employment_type must be valid if provided"
  values: [FULL_TIME, PART_TIME, CASUAL]
  error: "Invalid employment type"

VR-WR-005: Contract Type Valid
  rule: "contract_type must be valid if provided"
  values: [PERMANENT, FIXED_TERM, CASUAL, PROBATIONARY]
  error: "Invalid contract type"

VR-WR-006: Fixed Term End Date
  rule: "end_date is required for FIXED_TERM contracts"
  condition: "contract_type = 'FIXED_TERM' THEN end_date IS NOT NULL"
  error: "End date required for fixed-term contracts"

VR-WR-007: Probation Period Range
  rule: "probation_period_days must be between 1 and 180"
  condition: "probation_period_days IS NULL OR (probation_period_days BETWEEN 1 AND 180)"
  error: "Probation period must be 1-180 days"

VR-WR-008: FTE Range
  rule: "fte must be between 0.01 and 1.00"
  condition: "fte IS NULL OR (fte BETWEEN 0.01 AND 1.00)"
  error: "FTE must be between 0.01 and 1.00"

VR-WR-009: Status Valid
  rule: "status must be valid"
  values: [ACTIVE, SUSPENDED, TERMINATED]
  error: "Invalid status"

VR-WR-010: No Overlapping Active Relationships
  rule: "Worker cannot have overlapping ACTIVE relationships of same type"
  error: "Overlapping active relationships detected"
```

**Constraints**:

```sql
-- Check dates
CONSTRAINT ck_work_rel_dates 
  CHECK (end_date IS NULL OR end_date > start_date);

-- Check FTE
CONSTRAINT ck_work_rel_fte 
  CHECK (fte IS NULL OR (fte >= 0.01 AND fte <= 1.00));

-- Check probation period
CONSTRAINT ck_work_rel_probation 
  CHECK (probation_period_days IS NULL OR 
         (probation_period_days BETWEEN 1 AND 180));

-- Foreign keys
CONSTRAINT fk_work_rel_worker 
  FOREIGN KEY (worker_id) REFERENCES workers(id);

CONSTRAINT fk_work_rel_entity 
  FOREIGN KEY (legal_entity_id) REFERENCES entities(id);
```

**Indexes**:

```sql
CREATE UNIQUE INDEX pk_work_relationships ON work_relationships(id);
CREATE INDEX idx_work_rel_worker ON work_relationships(worker_id);
CREATE INDEX idx_work_rel_entity ON work_relationships(legal_entity_id);
CREATE INDEX idx_work_rel_status ON work_relationships(status, is_current_flag);
CREATE INDEX idx_work_rel_dates ON work_relationships(start_date, end_date);
```

**Business Rules**: BR-WR-001, BR-WR-002, BR-WR-010, BR-WR-015, BR-WR-020, BR-WR-022, BR-WR-032

---

#### Entity: Employee

**Purpose**: Employee-specific data (subset of workers with EMPLOYEE relationship)

**Table**: `employees`

**Attributes**:

| Field | Type | Required | Max Length | Default | Classification | Description |
|-------|------|----------|------------|---------|----------------|-------------|
| `id` | UUID | Yes | - | UUID() | PUBLIC | Primary key |
| `worker_id` | UUID | Yes | - | - | PUBLIC | FK to workers |
| `work_relationship_id` | UUID | Yes | - | - | PUBLIC | FK to work_relationships |
| `employee_number` | VARCHAR | Yes | 50 | AUTO | PUBLIC | Auto-generated (EMP-NNNNNN) |
| `hire_date` | DATE | Yes | - | - | PUBLIC | Original hire date |
| `original_hire_date` | DATE | Yes | - | - | PUBLIC | First hire date (for rehires) |
| `seniority_date` | DATE | No | - | NULL | INTERNAL | Seniority calculation date |
| `probation_end_date` | DATE | No | - | NULL | INTERNAL | Probation end date |
| `probation_status` | VARCHAR | No | 20 | - | INTERNAL | ON_PROBATION, CONFIRMED, FAILED |
| `status` | VARCHAR | Yes | 20 | ACTIVE | PUBLIC | ACTIVE, TERMINATED |
| `termination_date` | DATE | No | - | NULL | CONFIDENTIAL | Termination date |
| `termination_reason_code` | VARCHAR | No | 50 | - | CONFIDENTIAL | Termination reason |
| `termination_type` | VARCHAR | No | 50 | - | CONFIDENTIAL | VOLUNTARY, INVOLUNTARY |
| `rehire_eligible` | BOOLEAN | No | - | true | CONFIDENTIAL | Eligible for rehire |
| `metadata` | JSONB | No | - | {} | INTERNAL | Additional attributes |
| `effective_start_date` | DATE | Yes | - | - | PUBLIC | SCD Type 2 start |
| `effective_end_date` | DATE | No | - | NULL | PUBLIC | SCD Type 2 end |
| `is_current_flag` | BOOLEAN | Yes | - | true | PUBLIC | SCD Type 2 current |

**Validation Rules**:

```yaml
VR-EMP-001: Employee Number Unique
  rule: "employee_number must be unique"
  error: "Employee number already exists"

VR-EMP-002: Hire Date Required
  rule: "hire_date is required"
  error: "Hire date is required"

VR-EMP-003: Hire Date Not Future
  rule: "hire_date cannot be future date"
  condition: "hire_date <= CURRENT_DATE"
  error: "Hire date cannot be in the future"

VR-EMP-004: Original Hire Date Before Hire
  rule: "original_hire_date must be <= hire_date"
  error: "Original hire date must be before or equal to hire date"

VR-EMP-005: Termination Date After Hire
  rule: "termination_date must be after hire_date if provided"
  condition: "termination_date IS NULL OR termination_date > hire_date"
  error: "Termination date must be after hire date"

VR-EMP-006: Probation Status Valid
  rule: "probation_status must be valid if provided"
  values: [ON_PROBATION, CONFIRMED, FAILED, EXTENDED]
  error: "Invalid probation status"

VR-EMP-007: Status Valid
  rule: "status must be valid"
  values: [ACTIVE, TERMINATED]
  error: "Invalid employee status"

VR-EMP-008: Termination Data Complete
  rule: "If status = TERMINATED, termination_date and reason required"
  condition: "status = 'TERMINATED' THEN (termination_date IS NOT NULL AND termination_reason_code IS NOT NULL)"
  error: "Termination date and reason required for terminated employees"

VR-EMP-009: One Active Employee Per Worker
  rule: "Worker can have only one ACTIVE employee record"
  error: "Worker already has active employee record"
```

**Constraints**:

```sql
-- Unique employee number
CONSTRAINT uk_employee_number 
  UNIQUE (employee_number);

-- Check hire dates
CONSTRAINT ck_employee_hire_dates 
  CHECK (original_hire_date <= hire_date);

-- Check termination date
CONSTRAINT ck_employee_termination 
  CHECK (termination_date IS NULL OR termination_date > hire_date);

-- Check status and termination
CONSTRAINT ck_employee_status_termination 
  CHECK ((status = 'ACTIVE' AND termination_date IS NULL) OR 
         (status = 'TERMINATED' AND termination_date IS NOT NULL));

-- Foreign keys
CONSTRAINT fk_employee_worker 
  FOREIGN KEY (worker_id) REFERENCES workers(id);

CONSTRAINT fk_employee_work_rel 
  FOREIGN KEY (work_relationship_id) REFERENCES work_relationships(id);
```

**Indexes**:

```sql
CREATE UNIQUE INDEX pk_employees ON employees(id);
CREATE UNIQUE INDEX uk_employees_number ON employees(employee_number);
CREATE INDEX idx_employees_worker ON employees(worker_id);
CREATE INDEX idx_employees_status ON employees(status, is_current_flag);
CREATE INDEX idx_employees_hire_date ON employees(hire_date);
```

**Business Rules**: BR-EMP-001, BR-EMP-002, BR-EMP-010, BR-EMP-015

---

### Phase 1: Assignment Management

#### Entity: Assignment

**Purpose**: Employee assignment to job/position and organizational unit

**Table**: `assignments`

**Attributes**:

| Field | Type | Required | Max Length | Default | Classification | Description |
|-------|------|----------|------------|---------|----------------|-------------|
| `id` | UUID | Yes | - | UUID() | PUBLIC | Primary key |
| `employee_id` | UUID | Yes | - | - | PUBLIC | FK to employees |
| `assignment_type` | VARCHAR | Yes | 20 | - | PUBLIC | PRIMARY, CONCURRENT, TEMPORARY |
| `staffing_model` | VARCHAR | Yes | 20 | - | PUBLIC | POSITION_BASED, JOB_BASED |
| `position_id` | UUID | No | - | NULL | PUBLIC | FK to positions (if POSITION_BASED) |
| `job_id` | UUID | Yes | - | - | PUBLIC | FK to jobs |
| `business_unit_id` | UUID | Yes | - | - | PUBLIC | FK to business units |
| `location_id` | UUID | Yes | - | - | PUBLIC | FK to locations |
| `manager_id` | UUID | No | - | NULL | PUBLIC | FK to employees (solid line manager) |
| `start_date` | DATE | Yes | - | - | PUBLIC | Assignment start date |
| `end_date` | DATE | No | - | NULL | PUBLIC | Assignment end date |
| `fte` | DECIMAL(3,2) | Yes | - | 1.00 | INTERNAL | Full-time equivalent |
| `status` | VARCHAR | Yes | 20 | ACTIVE | PUBLIC | ACTIVE, ENDED |
| `end_reason_code` | VARCHAR | No | 50 | - | INTERNAL | End reason (TRANSFER, PROMOTION, TERMINATION) |
| `metadata` | JSONB | No | - | {} | INTERNAL | Additional attributes |
| `effective_start_date` | DATE | Yes | - | - | PUBLIC | SCD Type 2 start |
| `effective_end_date` | DATE | No | - | NULL | PUBLIC | SCD Type 2 end |
| `is_current_flag` | BOOLEAN | Yes | - | true | PUBLIC | SCD Type 2 current |

**Validation Rules**:

```yaml
VR-ASG-001: Assignment Type Valid
  rule: "assignment_type must be valid"
  values: [PRIMARY, CONCURRENT, TEMPORARY]
  error: "Invalid assignment type"

VR-ASG-002: Staffing Model Valid
  rule: "staffing_model must be valid"
  values: [POSITION_BASED, JOB_BASED]
  error: "Invalid staffing model"

VR-ASG-003: Position Required for Position-Based
  rule: "position_id required if staffing_model = POSITION_BASED"
  condition: "staffing_model = 'POSITION_BASED' THEN position_id IS NOT NULL"
  error: "Position required for position-based staffing"

VR-ASG-004: Position Not Allowed for Job-Based
  rule: "position_id must be NULL if staffing_model = JOB_BASED"
  condition: "staffing_model = 'JOB_BASED' THEN position_id IS NULL"
  error: "Position not allowed for job-based staffing"

VR-ASG-005: FTE Range
  rule: "fte must be between 0.01 and 1.00"
  condition: "fte BETWEEN 0.01 AND 1.00"
  error: "FTE must be between 0.01 and 1.00"

VR-ASG-006: Total FTE Not Exceed 1.0
  rule: "Sum of FTE across all active assignments <= 1.00"
  error: "Total FTE across assignments cannot exceed 1.00"

VR-ASG-007: One Primary Assignment
  rule: "Employee can have only one PRIMARY assignment"
  error: "Employee already has primary assignment"

VR-ASG-008: End Date After Start
  rule: "end_date must be after start_date if provided"
  condition: "end_date IS NULL OR end_date > start_date"
  error: "End date must be after start date"

VR-ASG-009: Manager Not Self
  rule: "manager_id cannot be same as employee_id"
  condition: "manager_id IS NULL OR manager_id != employee_id"
  error: "Employee cannot be their own manager"

VR-ASG-010: Manager Active Employee
  rule: "manager_id must reference active employee"
  error: "Manager must be active employee"
```

**Constraints**:

```sql
-- Check FTE
CONSTRAINT ck_assignment_fte 
  CHECK (fte BETWEEN 0.01 AND 1.00);

-- Check dates
CONSTRAINT ck_assignment_dates 
  CHECK (end_date IS NULL OR end_date > start_date);

-- Check manager not self
CONSTRAINT ck_assignment_manager_not_self 
  CHECK (manager_id IS NULL OR manager_id != employee_id);

-- Check position for position-based
CONSTRAINT ck_assignment_position_based 
  CHECK ((staffing_model = 'POSITION_BASED' AND position_id IS NOT NULL) OR 
         (staffing_model = 'JOB_BASED' AND position_id IS NULL));

-- Foreign keys
CONSTRAINT fk_assignment_employee 
  FOREIGN KEY (employee_id) REFERENCES employees(id);

CONSTRAINT fk_assignment_position 
  FOREIGN KEY (position_id) REFERENCES positions(id);

CONSTRAINT fk_assignment_job 
  FOREIGN KEY (job_id) REFERENCES jobs(id);

CONSTRAINT fk_assignment_business_unit 
  FOREIGN KEY (business_unit_id) REFERENCES business_units(id);

CONSTRAINT fk_assignment_manager 
  FOREIGN KEY (manager_id) REFERENCES employees(id);
```

**Indexes**:

```sql
CREATE UNIQUE INDEX pk_assignments ON assignments(id);
CREATE INDEX idx_assignments_employee ON assignments(employee_id);
CREATE INDEX idx_assignments_position ON assignments(position_id) WHERE position_id IS NOT NULL;
CREATE INDEX idx_assignments_job ON assignments(job_id);
CREATE INDEX idx_assignments_business_unit ON assignments(business_unit_id);
CREATE INDEX idx_assignments_manager ON assignments(manager_id) WHERE manager_id IS NOT NULL;
CREATE INDEX idx_assignments_status ON assignments(status, is_current_flag);
CREATE INDEX idx_assignments_dates ON assignments(start_date, end_date);
```

**Business Rules**: BR-ASG-001, BR-ASG-002, BR-ASG-004, BR-ASG-010, BR-ASG-015, BR-ASG-016

---

## 📏 Data Quality Standards

### 1. Completeness

**Required Fields**: All fields marked as `required: true` must have values

**Conditional Requirements**: Fields required based on business rules (e.g., end_date for FIXED_TERM contracts)

**Completeness Metrics**:
```sql
-- Worker completeness
SELECT 
  COUNT(*) as total_workers,
  COUNT(email) as workers_with_email,
  COUNT(phone) as workers_with_phone,
  ROUND(COUNT(email)::decimal / COUNT(*) * 100, 2) as email_completeness_pct
FROM workers
WHERE is_current_flag = true;
```

---

### 2. Accuracy

**Email Validation**: Must match email regex pattern

**Phone Validation**: Must match phone regex pattern

**Date Validation**: Dates must be logically consistent (start < end)

**Reference Validation**: All foreign keys must reference existing records

---

### 3. Consistency

**Cross-Entity Consistency**:
- Employee.hire_date = WorkRelationship.start_date
- Assignment.start_date >= Employee.hire_date
- Position status = FILLED when assigned

**Temporal Consistency**:
- Only one current version per entity (is_current_flag = true)
- No gaps in effective date ranges
- effective_start_date <= effective_end_date

---

### 4. Uniqueness

**Natural Keys**:
- Worker.code (WORKER-NNNNNN)
- Employee.employee_number (EMP-NNNNNN)
- Worker.national_id (if provided)
- Worker.email (if provided)

**Composite Keys**:
- CodeList: (group_code, code, effective_start_date)
- Assignment: One PRIMARY per employee

---

## 🔒 Data Security & Privacy

### Encryption at Rest

**RESTRICTED fields** must be encrypted:
- Worker.national_id
- Worker.passport_number
- BankAccount.account_number

**Encryption Method**: AES-256

---

### Access Control

**Role-Based Access Control (RBAC)**:

| Role | PUBLIC | INTERNAL | CONFIDENTIAL | RESTRICTED |
|------|--------|----------|--------------|------------|
| **EMPLOYEE** | ✅ Own data | ✅ Own data | ✅ Own data | ✅ Own data |
| **MANAGER** | ✅ Team | ✅ Team | ✅ Direct reports | ❌ |
| **HR_ADMIN** | ✅ All | ✅ All | ✅ All | ✅ With purpose |
| **DPO** | ✅ All | ✅ All | ✅ All | ✅ For compliance |

---

### Audit Logging

**All access to RESTRICTED data** must be logged:

```sql
-- Audit log entry
INSERT INTO audit_logs (
  user_id,
  action,
  entity_type,
  entity_id,
  field_name,
  access_purpose,
  timestamp
) VALUES (
  'user-uuid',
  'READ',
  'Worker',
  'worker-uuid',
  'national_id',
  'DSAR Request DSAR-2025-001',
  CURRENT_TIMESTAMP
);
```

---

## 📊 Data Retention Policies

| Data Category | Retention Period | Action After Retention |
|---------------|------------------|------------------------|
| **Active Employee Data** | Duration of employment | Retain |
| **Terminated Employee Data** | 7 years after termination | Anonymize |
| **Payroll Records** | 10 years | Anonymize |
| **Performance Reviews** | 3 years | Delete |
| **Skill Assessments** | 2 years | Delete |
| **Audit Logs** | 7 years | Archive |
| **DSAR Requests** | 3 years | Archive |

**Business Rule**: BR-PRI-030 (Data Retention Policy)

---

## 🔗 Related Documentation

- [Core Ontology](../00-ontology/core-ontology.yaml) - Source of truth for data models
- [Functional Requirements](./01-functional-requirements.md) - Business requirements
- [Business Rules](./04-business-rules.md) - Validation and business logic
- [API Specification](./02-api-specification.md) - API contracts
- [SCD Type 2 Guide](../../../00-global/standards/SCD2-guide.md) - Temporal data patterns

---

**Document Version**: 2.0  
**Created**: 2025-12-03  
**Entities Documented**: 10+ core entities  
**Validation Rules**: 50+ rules  
**Maintained By**: Data Architecture Team  
**Status**: Complete - Production-Ready
