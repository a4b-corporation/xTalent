# Employment Sub-Module - Glossary

**Version**: 2.0  
**Last Updated**: 2025-12-01  
**Sub-Module**: Employment Relationships & Assignments

---

## 📋 Overview

The Employment sub-module manages the **4-level hierarchy** from work relationships to specific job assignments. This is the **core** of HR data management.

**New in v2.0**: WorkRelationship entity separates overall relationship from employment contract details (best practice from Workday/Oracle).

### Entities (6)
1. ✨ **WorkRelationship** (NEW)
2. **Employee**
3. **Contract**
4. **ContractTemplate** ✨ (NEW) - Contract Configuration Templates
5. **Assignment**
6. **EmployeeIdentifier**
7. **GlobalAssignment**

---

## 🔑 Key Entities

### WorkRelationship ✨ NEW

**Definition**: The overall working relationship between a Worker and the Organization, independent of specific employment contract details.

**Purpose**: 
- Separates high-level relationship from contract details
- Supports non-employee workers (contractors, contingent)
- Enables one worker to have multiple concurrent relationships

**Key Attributes**:
- `worker_id` - Reference to Worker
- `legal_entity_code` - Legal entity with relationship
- `relationship_type_code` - Type of relationship
  - `EMPLOYEE` - Regular employment
  - `CONTRACTOR` - Independent contractor
  - `CONTINGENT_WORKER` - Temporary/agency worker
  - `INTERN` - Internship program
  - `VOLUNTEER` - Unpaid volunteer work
- `is_primary_relationship` - Primary if multiple concurrent
- `status_code` - ACTIVE, INACTIVE, TERMINATED, SUSPENDED
- `start_date` / `end_date` - Duration of relationship

**Business Rules**:
- ✅ One worker can have multiple work relationships (different entities or types)
- ✅ Only one primary work relationship at a time
- ✅ EMPLOYEE type must have corresponding Employee record
- ✅ CONTRACTOR/CONTINGENT may skip Employee record
- ⚠️ Cannot delete if active assignments exist

**Example**:
```yaml
# John Doe works as employee in Company A and contractor in Company B
WorkRelationship#1:
  worker_id: WORKER-001 (John Doe)
  legal_entity_code: COMPANY-A
  relationship_type: EMPLOYEE
  is_primary: true
  
WorkRelationship#2:
  worker_id: WORKER-001 (John Doe)
  legal_entity_code: COMPANY-B
  relationship_type: CONTRACTOR
  is_primary: false
```

**Why Important**: 
- Aligns with Workday/Oracle HCM best practices
- Clear separation of concerns
- Supports complex scenarios (dual employment, contractors)

---

### Employee

**Definition**: Detailed employment contract information for workers with EMPLOYEE-type work relationships.

**Purpose**: 
- Stores employment-specific data (employee code, hire date, probation)
- Links to contracts and payroll
- One-to-one with WorkRelationship (for EMPLOYEE type)

**Key Attributes**:
- `work_relationship_id` 🔄 - Parent work relationship (NEW in v2.0)
- `worker_id` - Denormalized for performance
- `legal_entity_code` - Employing legal entity
- `employee_code` - Employee number (unique within entity)
- `employee_class_code` - Classification (REGULAR, PROBATION, etc.)
- `hire_date` - Official hire date
- `termination_date` - If terminated
- `probation_end_date` 🔄 - End of probation period (NEW)
- `seniority_date` 🔄 - For seniority calculation (NEW)

**Business Rules**:
- ✅ Must reference WorkRelationship with type = EMPLOYEE
- ✅ Employee code unique within legal entity
- ✅ Hire date <= first assignment start date
- ✅ worker_id must match work_relationship.worker_id
- ✅ legal_entity_code must match work_relationship.legal_entity_code ✨ NEW
- ⚠️ Cannot create Employee for non-EMPLOYEE work relationships

**Changes in v2.0** ✨:
- `legal_entity_code`: Changed from `string(50)` → `UUID` for consistency with WorkRelationship
- `status_code`: Changed from `string` → `enum [ACTIVE, TERMINATED, SUSPENDED]` for type safety
- Added business rule: legal_entity_code must match WorkRelationship

**Example**:
```yaml
Employee:
  work_relationship_id: WR-001
  employee_code: "EMP-2024-001"
  legal_entity_code: UUID("VNG-VN")  # UUID, not string
  hire_date: 2024-01-15
  probation_end_date: 2024-04-15
  status_code: ACTIVE  # Enum value
```

**Relationship to WorkRelationship**:
```
Worker → WorkRelationship (type=EMPLOYEE) → Employee
         WorkRelationship (type=CONTRACTOR) → (no Employee record)
```

---

### 💡 Legal Entity Relationships ✨ NEW

#### Denormalization Design

Employee has `legal_entity_code` **denormalized** from WorkRelationship:

```yaml
WorkRelationship:
  legal_entity_code: UUID  # Source of truth
  
Employee:
  legal_entity_code: UUID  # Denormalized copy
```

**Why Denormalize?**:
1. **Performance**: Avoid join through WorkRelationship for queries
2. **Uniqueness**: `employee_code` unique within `legal_entity_code` scope
3. **Query Efficiency**: Frequently filter/group by legal entity

**Validation Rules**:
- Employee.legal_entity_code **MUST** equal WorkRelationship.legal_entity_code
- Employee.worker_id **MUST** equal WorkRelationship.worker_id
- Cannot change after creation

#### Multiple Legal Entities Scenario

```yaml
# Worker working at 2 legal entities
Worker: WORKER-001

WorkRelationship#1:
  legal_entity_code: VNG-VN
  relationship_type: EMPLOYEE
  
Employee#1:
  legal_entity_code: VNG-VN  # Matches WR#1
  employee_code: "EMP-VN-001"

WorkRelationship#2:
  legal_entity_code: VNG-SG
  relationship_type: CONTRACTOR
  
# NO Employee#2 - contractor relationship
```

---

### 🔄 Termination Flow ✨ NEW

#### Termination Sequence

When an employee terminates, **3 levels must be updated in order**:

```
Step 1: Assignment (Level 4)
  ├─ effective_end_date = termination_date
  └─ is_current_flag = false

Step 2: Employee (Level 3)
  ├─ status_code = TERMINATED
  ├─ termination_date = termination date
  └─ effective_end_date = termination_date

Step 3: WorkRelationship (Level 2)
  ├─ status_code = TERMINATED
  ├─ end_date = termination_date
  ├─ termination_reason_code = reason
  └─ termination_type_code = type ✨ NEW
```

#### Termination Type Codes ✨ NEW

WorkRelationship has new field `termination_type_code`:

| Code | Description | When to Use |
|------|-------------|-------------|
| **VOLUNTARY** | Voluntary resignation | Employee resigns |
| **INVOLUNTARY** | Involuntary termination | Company terminates |
| **MUTUAL** | Mutual agreement | Both parties agree |
| **END_OF_CONTRACT** | Contract expiration | Fixed-term contract ends |

#### Termination Flow Example

```yaml
# BEFORE TERMINATION
WorkRelationship:
  status_code: ACTIVE
  end_date: null

Employee:
  status_code: ACTIVE
  termination_date: null

Assignment:
  effective_end_date: null
  is_current_flag: true

# AFTER TERMINATION (2024-12-31)
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
  termination_type_code: VOLUNTARY  # NEW
  rehire_eligible_flag: true
```

#### Validation Rules

- ✅ Must terminate Assignments before Employee
- ✅ Must terminate Employee before WorkRelationship
- ✅ All must succeed or rollback (atomic transaction)
- ✅ Cannot have partial termination state
- ⚠️ Termination dates must be consistent across levels

---

### 📊 Concept Comparison ✨ NEW

#### relationship_type_code vs employee_class_code vs contract_type_code

| Aspect | relationship_type_code | employee_class_code | contract_type_code |
|--------|------------------------|---------------------|-------------------|
| **Entity** | WorkRelationship | Employee | Contract |
| **Level** | Level 2 | Level 3 | Level 3 |
| **Purpose** | Nature of work relationship | Employee status/stage | Legal contract type |
| **Scope** | All workers | EMPLOYEE type only | All contracts |
| **Values** | EMPLOYEE, CONTRACTOR, INTERN | REGULAR, PROBATION, TEMPORARY | PERMANENT, FIXED_TERM, PROBATION |
| **Type** | enum | string (will change to enum) | string |

#### Common Combinations Matrix

| Relationship Type | Employee Class | Contract Type | Example |
|-------------------|----------------|---------------|---------|
| EMPLOYEE | PROBATION | PROBATION | New hire on probation |
| EMPLOYEE | REGULAR | PERMANENT | Regular employee, indefinite term |
| EMPLOYEE | REGULAR | FIXED_TERM | Regular employee, fixed term |
| EMPLOYEE | PART_TIME | PERMANENT | Part-time employee, indefinite |
| EMPLOYEE | TEMPORARY | FIXED_TERM | Temporary employee, short term |
| CONTRACTOR | N/A | N/A | Contractor (no Employee record) |
| INTERN | TRAINEE | FIXED_TERM | Paid intern with contract |

---


### Contract

**Definition**: Legal employment or service contract document and terms.

**Purpose**:
- Track contract types, durations, renewals
- Link to contract documents
- Support contract hierarchies (renewals)

**Key Attributes**:
- `employee_id` - Contract holder
- `template_id` ✨ - Reference to `ContractTemplate` (inherits default configuration).
- `contract_type_code`:
  - `PERMANENT` - Indefinite term
  - `FIXED_TERM` - Fixed duration (e.g., 12 months)
  - `PROBATION` - Probationary period
  - `SEASONAL` - Seasonal work
- `work_schedule_type_code`:
  - `FULL_TIME` - 40 hours/week
  - `PART_TIME` - < 40 hours/week
  - `FLEXIBLE` - Flexible hours
- `parent_contract_id` - Links to previous contract
- `parent_relationship_type` ✨:
  - `AMENDMENT` - Modifies existing terms.
  - `ADDENDUM` - Adds new terms.
  - `RENEWAL` - Re-sign / Extension.
  - `SUPERSESSION` - Complete replacement (e.g., Probation → Permanent).
- `contract_number` - Official contract number
- `start_date` / `end_date` - Contract validity period
- `duration_value` / `duration_unit` ✨ - Duration (e.g., 12 MONTH, 60 DAY).
- `document_id` - Contract document (signed PDF file).
- `probation_end_date` ✨ - Probation end date.
- `notice_period_days` ✨ - Notice period for termination.
- `base_salary` / `salary_currency_code` / `salary_frequency_code` ✨ - Basic compensation reference.
- `working_hours_per_week` ✨ - Working hours per week.
- `supplier_id` - Vendor (for outsourced workers)

**Business Rules**:
- ✅ Only one primary contract (`primary_flag=true`) per employee at a time
- ✅ Fixed-term contracts (`FIXED_TERM`) must have `end_date`
- ✅ If `parent_contract_id` is not null → `parent_relationship_type` is required
- ✅ If `template_id` is selected → inherits default configuration, allows override
- ✅ If `duration_value` is provided → `end_date` = `start_date` + duration
- ⚠️ Contract dates must be within work relationship dates

**Contract Hierarchy Example**:
```yaml
# Initial probation contract
Contract#1:
  type: PROBATION
  parent_id: null
  parent_relationship_type: null
  start: 2023-01-01
  end: 2023-03-01

# Salary amendment (Amendment)
Contract#2:
  type: PROBATION
  parent_id: Contract#1
  parent_relationship_type: AMENDMENT
  start: 2023-02-01  # Effective date of amendment
  base_salary: 60000000  # Increased from 50M

# Permanent contract (Supersession)
Contract#3:
  type: PERMANENT
  parent_id: Contract#1
  parent_relationship_type: SUPERSESSION
  start: 2023-03-01
  end: null

# Renewal after 1 year (Renewal)
Contract#4:
  type: PERMANENT
  parent_id: Contract#3
  parent_relationship_type: RENEWAL
  start: 2024-03-01
```

---

### ContractTemplate ✨ NEW

**Definition**: Configuration template for contract types, defining default parameters and compliance rules.

**Purpose**:
- Standardize contract terms by type, country, and unit.
- Automate calculation of duration, probation, and notice periods.
- Ensure compliance with labor regulations (e.g., VN max 36 months for fixed-term).
- Reduce manual data entry errors.

**Key Attributes**:
- `code` - Template code (e.g., "VN_TECH_FIXED_12M").
- `name` - Template name.
- `contract_type_code` - Applicable contract type.
- `country_code` - Country (null = global).
- `legal_entity_code` - Specific legal entity (optional).
- `business_unit_id` - Specific business unit (optional).
- **Duration Configuration**:
  - `default_duration_value` / `default_duration_unit` - Default duration.
  - `min_duration_value` / `min_duration_unit` - Minimum duration.
  - `max_duration_value` / `max_duration_unit` - Maximum duration.
- **Probation Configuration**:
  - `probation_required` - Is probation required?
  - `probation_duration_value` / `probation_duration_unit` - Probation period.
- **Renewal Configuration**:
  - `allows_renewal` - Allow renewal?
  - `max_renewals` - Maximum number of renewals.
  - `renewal_notice_days` - Notice days before renewal.
- **Termination Configuration**:
  - `default_notice_period_days` - Default notice period.
- **Legal Compliance**:
  - `legal_requirements` (jsonb) - Specific legal requirements.

**Business Rules**:
- ✅ Each template must have unique `code`.
- ✅ If `contract_type_code = PERMANENT` → `max_duration_value` must be null.
- ✅ If `contract_type_code = FIXED_TERM` → `max_duration_value` is required (compliance).
- ✅ Supports hierarchy: Global → Country → Legal Entity → Business Unit.

**Examples**:
```yaml
# Vietnam Tech - Fixed Term 12 Months
ContractTemplate#1:
  code: "VN_TECH_FIXED_12M"
  name: "Vietnam Tech - Fixed Term 12 Months"
  contract_type: FIXED_TERM
  country: VN
  business_unit_id: <Tech_BU>
  
  default_duration_value: 12
  default_duration_unit: MONTH
  max_duration_value: 36
  max_duration_unit: MONTH  # VN labor law
  
  probation_required: true
  probation_duration_value: 60
  probation_duration_unit: DAY
  
  allows_renewal: true
  max_renewals: 2
  renewal_notice_days: 30
  
  default_notice_period_days: 30
  
  legal_requirements:
    max_consecutive_fixed_terms: 2
    mandatory_clauses: ["social_insurance", "termination_notice"]
    labor_code_reference: "VN_LC_2019_Article_22"

# Singapore Sales - Probation 3 Months
ContractTemplate#2:
  code: "SG_SALES_PROBATION_3M"
  name: "Singapore Sales - Probation 3 Months"
  contract_type: PROBATION
  country: SG
  business_unit_id: <Sales_BU>
  
  default_duration_value: 3
  default_duration_unit: MONTH
  max_duration_value: 6
  max_duration_unit: MONTH
  
  default_notice_period_days: 7
```

---

### Assignment 🔄 ENHANCED

**Definition**: Assignment of a worker to perform work in a specific business unit and job/position.

**Purpose**:
- Track actual work assignments
- Support flexible staffing models
- Manage reporting relationships (solid + dotted line)

**Key Attributes**:
- `work_relationship_id` - Direct WR link (for non-employees) ✨
- `employee_id` - Employee link (for employees) 
- `staffing_model_code` ✨ - POSITION_BASED or JOB_BASED
- `position_id` - Budgeted position (if POSITION_BASED)
- `job_id` ✨ - Direct job link (if JOB_BASED)
- `business_unit_id` - Where work is performed
- `primary_location_id` - Physical work location
- `is_primary_assignment` ✨ - Primary if multiple concurrent
- `assignment_category_code` ✨ - REGULAR, TEMPORARY, PROJECT
- `fte` - Full-time equivalent (1.0 = full-time)
- `supervisor_assignment_id` - Solid line supervisor
- `dotted_line_supervisor_id` ✨ - Matrix supervisor
- `status_code` - ACTIVE, SUSPENDED, ENDED
- `start_date` / `end_date` - Assignment period

**Staffing Models** ✨ NEW:

#### POSITION_BASED
```yaml
# Use when: Strict headcount control, corporate roles
Assignment:
  staffing_model: POSITION_BASED
  position_id: POS-FIN-MGR-001  # Required
  job_id: JOB-FIN-MGR           # Derived from position
  business_unit: Finance Dept
```
- Pre-defined budgeted position
- One position typically = one person
- FTE tracked at position level
- Vacancy management

#### JOB_BASED
```yaml
# Use when: Flexible capacity, hourly workers, contractors
Assignment:
  staffing_model: JOB_BASED
  position_id: null             # No position
  job_id: JOB-WAREHOUSE-WORKER  # Direct job link
  business_unit: Warehouse
```
- No predefined position required
- Multiple people → same job
- Flexible headcount
- Dynamic capacity

**Matrix Reporting** ✨ ENHANCED:
```yaml
Assignment:
  supervisor_assignment_id: MGR-001        # Solid line (Finance Manager)
  dotted_line_supervisor_id: MGR-002      # Dotted line (Project Lead)
```

**Business Rules**:
- ✅ Either work_relationship_id OR employee_id required (not both)
- ✅ POSITION_BASED requires position_id (not null)
- ✅ JOB_BASED requires position_id = null, job_id can be specified
- ✅ Only one primary assignment per worker at a time
- ✅ Supervisor must have active assignment in same/parent unit
- ✅ Dotted line is informational only (doesn't affect approval chain)

**Examples**:

```yaml
# Example 1: Corporate role (position-based)
Assignment:
  employee_id: EMP-001
  staffing_model: POSITION_BASED
  position_id: POS-CFO-001
  job_id: JOB-CHIEF-FINANCIAL-OFFICER
  fte: 1.0
  is_primary: true

# Example 2: Contractor (job-based, no position)
Assignment:
  work_relationship_id: WR-CONT-001
  staffing_model: JOB_BASED
  position_id: null
  job_id: JOB-SOFTWARE-CONSULTANT
  fte: 0.5
  is_primary: true

# Example 3: Hourly worker (job-based)
Assignment:
  employee_id: EMP-500
  staffing_model: JOB_BASED
  position_id: null
  job_id: JOB-RETAIL-ASSOCIATE
  fte: 1.0
```

---

### EmployeeIdentifier

**Definition**: Alternative identifier codes for employees (beyond primary employee_code).

**Purpose**:
- Link to external systems (legacy HRIS, payroll)
- Badge numbers, card IDs
- Government IDs for payroll

**Common Identifier Types**:
- `PAYROLL_ID` - Payroll system employee number
- `BADGE_ID` - Physical access badge number
- `LEGACY_SYSTEM_ID` - Old HRIS employee code
- `BIOMETRIC_ID` - Fingerprint/face scan ID
- `UNION_MEMBER_ID` - Union membership number

**Business Rules**:
- ✅ Multiple identifiers per employee allowed
- ✅ Each (employee_id, id_type) combination unique
- ✅ One primary identifier per type

**Example**:
```yaml
Employee: EMP-2024-001
Identifiers:
  - PAYROLL_ID: "PR-12345"
  - BADGE_ID: "BADGE-0001"
  - LEGACY_SYSTEM_ID: "OLD-HRIS-999"
```

---

### GlobalAssignment

**Definition**: International assignment for employees working across countries/legal entities.

**Purpose**:
- Track expatriate assignments
- Manage cross-border payroll
- Cost of living adjustments (COLA)
- Shadow payroll

**Key Attributes**:
- `employee_id` - Expatriate employee
- `home_entity_id` - Original employer
- `host_entity_id` - Host country employer
- `assignment_type_code`:
  - `LONG_TERM` - 1+ years
  - `SHORT_TERM` - < 1 year
  - `ROTATION` - Regular rotation schedule
- `home_country_code` / `host_country_code` - Countries
- `payroll_country_code` - Where payroll processed
- `shadow_payroll_flag` - Dual payroll (both countries)
- `housing_allowance_amt` - Housing supplement
- `cola_factor` - Cost of living multiplier (e.g., 1.25 = 25% increase)
- `mobility_policy_code` - Company mobility program

**Business Rules**:
- ✅ Home and host entities must be different
- ✅ If shadow_payroll = true, payroll in both countries
- ✅ COLA factor typically 0.8 to 2.0 range

**Example**:
```yaml
GlobalAssignment:
  employee_id: EMP-001
  home_entity: VNG-VIETNAM
  host_entity: VNG-SINGAPORE
  assignment_type: LONG_TERM
  payroll_country: SG
  shadow_payroll: true          # Also Vietnam payroll
  cola_factor: 1.35             # 35% COLA
  housing_allowance: 3000 USD/month
  start_date: 2024-01-01
  end_date: 2026-12-31
```

---

## 🔄 4-Level Hierarchy Flow

### Complete Worker Journey

```
1. WORKER CREATED
   ↓
   Worker#001 (John Doe)
   - person_type: EMPLOYEE
   - date_of_birth: 1990-05-15
   
2. WORK RELATIONSHIP ESTABLISHED
   ↓
   WorkRelationship#001
   - worker_id: Worker#001
   - legal_entity: VNG Corp
   - type: EMPLOYEE
   - start_date: 2024-01-15
   
3. EMPLOYMENT CONTRACT SIGNED
   ↓
   Employee#001
   - work_relationship_id: WR#001
   - employee_code: "EMP-2024-001"
   - hire_date: 2024-01-15
   
   Contract#001
   - employee_id: Employee#001
   - type: PROBATION
   - start: 2024-01-15
   - end: 2024-04-15
   
4. JOB ASSIGNMENT
   ↓
   Assignment#001
   - employee_id: Employee#001
   - staffing_model: POSITION_BASED
   - position: Senior Developer
   - business_unit: Engineering
   - start_date: 2024-01-15
```

---

## 💡 Common Scenarios

### Scenario 1: Regular Employee Hire
```yaml
1. Create Worker (person_type = EMPLOYEE)
2. Create WorkRelationship (type = EMPLOYEE)
3. Create Employee (links to WR)
4. Create Contract (PROBATION → PERMANENT)
5. Create Assignment (POSITION_BASED)
```

### Scenario 2: Contractor Engagement
```yaml
1. Create Worker (person_type = CONTRACTOR)
2. Create WorkRelationship (type = CONTRACTOR)
3. Skip Employee record
4. Create Contract (links directly to WR)
5. Create Assignment (JOB_BASED, no position)
```

### Scenario 3: Dual Employment
```yaml
Worker#001 (same person)
  ↓
WorkRelationship#1 (Company A, EMPLOYEE, primary)
  ↓
  Employee#1 → Assignment#1 (Full-time)
  
WorkRelationship#2 (Company B, CONTRACTOR, secondary)
  ↓
  (No Employee record)
  Assignment#2 (Part-time consulting)
```

### Scenario 4: Internal Transfer
```yaml
# Same Employee, new Assignment
Employee#001 (unchanged)
  ↓
Assignment#1 (end_date = 2024-06-30)
  - position: Junior Developer
  - business_unit: Team A
  
Assignment#2 (start_date = 2024-07-01)
  - position: Senior Developer
  - business_unit: Team B
  - reason_code: PROMOTION
```

---

## ⚠️ Important Notes

### Breaking Changes in v2.0
1. **Employee now requires work_relationship_id**
   - Migration: Create WorkRelationship for each existing Employee
   
2. **Assignment can reference work_relationship_id OR employee_id**
   - Employees: Use employee_id
   - Contractors/Contingent: Use work_relationship_id directly

3. **Staffing model now explicit**
   - Must specify POSITION_BASED or JOB_BASED
   - Migration: Set based on position_id presence

### When to Use Which Model?

| Worker Type | Work Relationship | Employee Record | Staffing Model |
|-------------|-------------------|-----------------|----------------|
| Regular Employee | EMPLOYEE | Yes | POSITION_BASED |
| Executive | EMPLOYEE | Yes | POSITION_BASED |
| Hourly Worker | EMPLOYEE | Yes | JOB_BASED |
| Independent Contractor | CONTRACTOR | No | JOB_BASED |
| Temp Agency Worker | CONTINGENT_WORKER | No | JOB_BASED |
| Intern | INTERN | Optional | JOB_BASED |
| Board Member | NON_WORKER | No | No assignment |

---

## 🔗 Related Glossaries

- **Person** - Worker entity and personal data
- **JobPosition** - Job and Position structures
- **BusinessUnit** - Organization units
- **LegalEntity** - Company structure

---

## 📚 References

- Workday HCM: Work Relationship concept
- Oracle HCM Cloud: Global Person Model
- SAP SuccessFactors: Employee Central data model

---

**Document Version**: 2.0  
**Last Review**: 2025-12-01  
**Next Review**: Q2 2025
