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
4. **Assignment**
5. **EmployeeIdentifier**
6. **GlobalAssignment**

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
- ⚠️ Cannot create Employee for non-EMPLOYEE work relationships

**Example**:
```yaml
Employee:
  work_relationship_id: WR-001
  employee_code: "EMP-2024-001"
  legal_entity_code: "VNG-CORP"
  hire_date: 2024-01-15
  probation_end_date: 2024-04-15
  status: ACTIVE
```

**Relationship to WorkRelationship**:
```
Worker → WorkRelationship (type=EMPLOYEE) → Employee
         WorkRelationship (type=CONTRACTOR) → (no Employee record)
```

---

### Contract

**Definition**: Legal employment or service contract document and terms.

**Purpose**:
- Track contract types, durations, renewals
- Link to contract documents
- Support contract hierarchies (renewals)

**Key Attributes**:
- `employee_id` or `work_relationship_id` - Contract holder
- `contract_type_code`:
  - `PERMANENT` - Indefinite term
  - `FIXED_TERM` - Fixed duration (e.g., 12 months)
  - `PROBATION` - Probationary period
  - `SEASONAL` - Seasonal work
- `work_schedule_type_code`:
  - `FULL_TIME` - 40 hours/week
  - `PART_TIME` - < 40 hours/week
  - `FLEXIBLE` - Flexible hours
- `parent_contract_id` - For renewals, links to previous contract
- `contract_number` - Official contract number
- `start_date` / `end_date` - Contract validity period
- `supplier_id` - Vendor (for outsourced workers)

**Business Rules**:
- ✅ Only one primary contract per employee at a time
- ✅ Fixed-term contracts must have end_date
- ✅ Renewal contracts link via parent_contract_id
- ⚠️ Contract dates must be within work relationship dates

**Contract Hierarchy Example**:
```
Initial Contract (2023-01-01 to 2023-12-31)
  ↓ parent_contract_id
Renewal #1 (2024-01-01 to 2024-12-31)
  ↓ parent_contract_id  
Renewal #2 / Permanent (2025-01-01 onwards)
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
