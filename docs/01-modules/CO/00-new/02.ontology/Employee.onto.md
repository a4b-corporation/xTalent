---
entity: Employee
domain: core-hr
version: "1.0.0"
status: approved
owner: HR Domain Team
tags: [employment, hr-operations, payroll, core]

attributes:
  # === IDENTITY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  - name: employeeCode
    type: string
    required: true
    unique: false
    description: Business identifier for employee (unique within legal entity). Generated when Worker becomes Employee.
    constraints:
      pattern: "^[A-Z0-9]{6,12}$"
  
  - name: statusCode
    type: enum
    required: true
    description: Current employment status. Aligned with xTalent naming convention.
    values: [ACTIVE, ON_LEAVE, SUSPENDED, TERMINATED, RETIRED]
    default: ACTIVE
  
  # === WORKER & WORK RELATIONSHIP REFERENCES ===
  - name: workerId
    type: string
    required: true
    description: Reference to Worker entity (the person). Employee is derived from Worker.
  
  - name: workRelationshipId
    type: string
    required: true
    description: Reference to WorkRelationship entity. Employee exists only when relationshipTypeCode = EMPLOYEE.
  
  - name: legalEntityCode
    type: string
    required: true
    description: Code of Legal Entity that employs this person (org_legal.entity.code)
  
  # === CLASSIFICATION (3-Layer) ===
  - name: workerCategoryCode
    type: string
    required: false
    description: Worker category for workforce planning (e.g., CORE, SUPPORT, LEADERSHIP). Reference to CODELIST_WORKER_CATEGORY.
    constraints:
      reference: CODELIST_WORKER_CATEGORY
  
  - name: employeeClassCode
    type: string
    required: false
    description: Employee classification for HR policies (e.g., REGULAR, PROBATION, INTERN). Reference to CODELIST_EMPLOYEE_CLASS.
    constraints:
      reference: CODELIST_EMPLOYEE_CLASS
  
  # === EMPLOYMENT DATES ===
  - name: hireDate
    type: date
    required: true
    description: Date employee started with this legal entity (Ngày bắt đầu làm việc). Copied from WorkRelationship.startDate.
  
  - name: originalHireDate
    type: date
    required: false
    description: First hire date with company (for re-hires). Used for seniority calculation. Copied from WorkRelationship.originalHireDate.
  
  - name: seniorityDate
    type: date
    required: false
    description: Date from which seniority is calculated. May differ from hireDate due to breaks in service.
  
  - name: seniorityAdjustmentDate
    type: date
    required: false
    description: Adjusted seniority date after unpaid leave deductions. Overrides seniorityDate if set.
  
  - name: terminationDate
    type: date
    required: false
    description: Date employment ended (Ngày chấm dứt). Synced with WorkRelationship.terminationDate.
  
  - name: lastWorkingDate
    type: date
    required: false
    description: Last day employee actually worked (may differ from terminationDate)
  
  # === PROBATION ===
  - name: probationEndDate
    type: date
    required: false
    description: Expected end date of probation period (VN - 6/30/60/180 days)
  
  - name: probationResult
    type: enum
    required: false
    description: Outcome of probation period
    values: [PASSED, FAILED, EXTENDED, IN_PROGRESS]
  
  # === EMPLOYMENT INTENT (from WorkRelationship) ===
  - name: employmentIntent
    type: enum
    required: false
    description: Strategic intent of employment. Inherited from WorkRelationship.
    values: [PERMANENT, FIXED_TERM, SEASONAL, PROJECT_BASED]
    default: PERMANENT
  
  # === VN LABOR LAW COMPLIANCE ===
  - name: laborContractId
    type: string
    required: false
    description: Reference to current active Labor Contract (Hợp đồng lao động)
  
  - name: socialInsuranceNumber
    type: string
    required: false
    description: Social insurance number (Mã số BHXH - VN specific)
    constraints:
      pattern: "^[0-9]{10}$"
    metadata:
      pii: true
      sensitivity: high
  
  - name: taxCode
    type: string
    required: false
    description: Personal tax code (Mã số thuế cá nhân - VN specific)
    constraints:
      pattern: "^[0-9]{10}(-[0-9]{3})?$"
    metadata:
      pii: true
      sensitivity: high
  
  - name: laborBookNumber
    type: string
    required: false
    description: Labor book number (Số sổ lao động - VN specific)
    metadata:
      pii: true
      sensitivity: medium
  
  - name: healthInsuranceNumber
    type: string
    required: false
    description: Health insurance number (Mã số BHYT - VN specific)
    constraints:
      pattern: "^[A-Z]{2}[0-9]{13}$"
    metadata:
      pii: true
      sensitivity: high
  
  - name: unionMember
    type: boolean
    required: false
    default: false
    description: Is employee a union member? (Đoàn viên công đoàn - VN specific)
  
  # === METADATA ===
  - name: metadata
    type: json
    required: false
    description: Additional flexible data (probation details, seniority level, etc.)
  
  # === AUDIT ===
  - name: createdAt
    type: datetime
    required: true
    description: Record creation timestamp
  
  - name: updatedAt
    type: datetime
    required: true
    description: Last modification timestamp
  
  - name: createdBy
    type: string
    required: true
    description: User who created the record
  
  - name: updatedBy
    type: string
    required: true
    description: User who last modified the record

relationships:
  - name: belongsToWorker
    target: Worker
    cardinality: many-to-one
    required: true
    inverse: hasEmployees
    description: The person behind this employee record. INVERSE - Worker.hasEmployees must reference this Employee.
  
  - name: belongsToWorkRelationship
    target: WorkRelationship
    cardinality: one-to-one
    required: true
    inverse: hasEmployee
    description: The work relationship that created this employee. INVERSE - WorkRelationship.hasEmployee must reference this Employee.
  
  - name: belongsToLegalEntity
    target: LegalEntity
    cardinality: many-to-one
    required: true
    inverse: hasEmployees
    description: The legal entity that employs this person. INVERSE - LegalEntity.hasEmployees must reference this Employee.
  
  - name: hasAssignments
    target: Assignment
    cardinality: one-to-many
    required: false
    inverse: belongsToEmployee
    description: Job assignments for this employee. INVERSE - Assignment.belongsToEmployee must reference this Employee.
  
  - name: hasPrimaryAssignment
    target: Assignment
    cardinality: many-to-one
    required: false
    inverse: isPrimaryFor
    description: Current primary job assignment. INVERSE - Assignment.isPrimaryFor must reference this Employee.
  
  - name: hasLaborContract
    target: LaborContract
    cardinality: many-to-one
    required: false
    inverse: coversEmployee
    description: Current active labor contract. INVERSE - LaborContract.coversEmployee must reference this Employee.
  
  - name: reportsTo
    target: Employee
    cardinality: many-to-one
    required: false
    inverse: hasDirectReports
    description: Primary/Line Manager (self-referential). Can be auto-aggregated from Assignment.reportsTo based on FTE or tenant config. INVERSE - Employee.hasDirectReports must reference this Employee.
    metadata:
      aggregation_rule: "Assignment with highest FTE, or earliest startDate if FTE equal"
      tenant_configurable: true
      note: "If tenant uses Assignment-level managers, this can be null or auto-calculated"
  
  - name: hasDirectReports
    target: Employee
    cardinality: one-to-many
    required: false
    inverse: reportsTo
    description: Employees reporting to this person as primary manager (self-referential). INVERSE - Employee.reportsTo must reference this Employee.

lifecycle:
  states: [ACTIVE, ON_LEAVE, SUSPENDED, TERMINATED, RETIRED]
  initial: ACTIVE
  terminal: [TERMINATED, RETIRED]
  transitions:
    - from: ACTIVE
      to: ON_LEAVE
      trigger: startLeave
      guard: Approved LONG-TERM leave request (sabbatical, maternity, long-term sick >= 30 days). Short leave (annual, sick < 30 days) keeps ACTIVE status.
    - from: ON_LEAVE
      to: ACTIVE
      trigger: returnFromLeave
      guard: Long-term leave period ended
    - from: ACTIVE
      to: SUSPENDED
      trigger: suspend
      guard: Suspension action triggered (disciplinary or VN Hoãn HĐLĐ)
    - from: SUSPENDED
      to: ACTIVE
      trigger: reinstate
      guard: Suspension lifted
    - from: ACTIVE
      to: TERMINATED
      trigger: terminate
      guard: Termination event triggered (synced with WorkRelationship)
    - from: ON_LEAVE
      to: TERMINATED
      trigger: terminate
      guard: Termination during leave (e.g., contract expiry)
    - from: SUSPENDED
      to: TERMINATED
      trigger: terminate
      guard: Termination during suspension
    - from: ACTIVE
      to: RETIRED
      trigger: retire
      guard: Retirement processed (age eligibility met)

policies:
  - name: EmployeeCodeUniqueness
    type: validation
    rule: employeeCode must be unique within legalEntityCode
    expression: "COUNT(Employee WHERE legalEntityCode = X AND employeeCode = Y) = 1"
  
  - name: WorkerToEmployeeMapping
    type: business
    rule: Employee can only be created when Worker has WorkRelationship with relationshipTypeCode = EMPLOYEE
    expression: "EXISTS(WorkRelationship WHERE workerId = X AND relationshipTypeCode = EMPLOYEE AND statusCode = ACTIVE)"
  
  - name: OneEmployeePerWorkRelationship
    type: validation
    rule: Each WorkRelationship can have at most ONE Employee
    expression: "COUNT(Employee WHERE workRelationshipId = X) <= 1"
  
  - name: StatusSyncWithWorkRelationship
    type: business
    rule: Employee.statusCode must sync with WorkRelationship.statusCode
    trigger: ON_UPDATE(WorkRelationship.statusCode)
  
  - name: HireDateFromWorkRelationship
    type: business
    rule: Employee.hireDate must equal WorkRelationship.startDate
  
  - name: TerminationDateSync
    type: business
    rule: When Employee is TERMINATED, WorkRelationship must also be TERMINATED
    trigger: ON_UPDATE(Employee.statusCode)
  
  - name: PrimaryAssignmentRequired
    type: validation
    rule: ACTIVE Employee must have a primary assignment
    expression: "statusCode = ACTIVE IMPLIES hasPrimaryAssignment IS NOT NULL"
  
  - name: SocialInsuranceRequired
    type: business
    rule: For VN employees, socialInsuranceNumber is required for ACTIVE status
    severity: WARNING
  
  - name: TaxCodeRequired
    type: business
    rule: For VN employees, taxCode is required for payroll processing
    severity: WARNING
  
  - name: ProbationPeriodValidation
    type: validation
    rule: Probation period must comply with VN Labor Law (6/30/60/180 days)
    expression: "probationEndDate - hireDate IN [6, 30, 60, 180] days"
  
  - name: SeniorityCalculation
    type: business
    rule: Seniority = seniorityAdjustmentDate OR seniorityDate OR originalHireDate OR hireDate (fallback chain)
  
  - name: ManagerMustBeActiveEmployee
    type: validation
    rule: reportsTo must reference an ACTIVE Employee (not Worker), and must be in same LegalEntity or cross-entity reporting allowed
    expression: "reportsTo.statusCode = ACTIVE AND (reportsTo.legalEntityCode = legalEntityCode OR tenant.allowCrossEntityReporting = TRUE)"
    severity: ERROR
  
  - name: ManagerAggregationFromAssignment
    type: business
    rule: If tenant uses Assignment-level managers, Employee.reportsTo can be auto-calculated from Assignment with highest FTE (or earliest if FTE equal)
    trigger: ON_UPDATE(Assignment.reportsTo, Assignment.fte)
    severity: INFO
---

# Entity: Employee

## 1. Overview

The **Employee** entity represents an individual who has an **active employment relationship** with a Legal Entity. It is a **derived entity** created when a Worker establishes a WorkRelationship with `relationshipTypeCode = EMPLOYEE`. 

**Key Concept**: 
```
Worker (Person) + WorkRelationship (EMPLOYEE) → Employee (with employee_code)
```

Once an Employee record is created, **all HR operations** (payroll, benefits, performance, time tracking) interact through the Employee entity, not directly with Worker.

```mermaid
mindmap
  root((Employee))
    Identity
      id
      employeeCode
      statusCode
    References
      workerId
      workRelationshipId
      legalEntityCode
    Classification
      workerCategoryCode
      employeeClassCode
      employmentIntent
    Employment Dates
      hireDate
      originalHireDate
      seniorityDate
      seniorityAdjustmentDate
      terminationDate
    Probation
      probationEndDate
      probationResult
    VN Compliance
      socialInsuranceNumber
      taxCode
      laborBookNumber
      healthInsuranceNumber
      unionMember
    Relationships
      belongsToWorker
      belongsToWorkRelationship
      belongsToLegalEntity
      hasAssignments
      hasPrimaryAssignment
      hasLaborContract
      reportsTo
      hasDirectReports
    Lifecycle
      ACTIVE
      ON_LEAVE
      SUSPENDED
      TERMINATED
      RETIRED
```

**Design Rationale**:
- **Separation of Concerns**: Worker = Person identity, Employee = Employment context
- **Multi-employment Support**: One Worker can be Employee at multiple Legal Entities (concurrently or sequentially)
- **HR Operations Boundary**: Employee is the entry point for all HR transactions
- **Compliance**: VN-specific fields (BHXH, tax code) live on Employee, not Worker

---

## 2. Attributes

### 2.1 Identity Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique internal identifier (UUID) |
| employeeCode | string | ✓ | Business identifier (unique within legal entity) |
| statusCode | enum | ✓ | ACTIVE, ON_LEAVE, SUSPENDED, TERMINATED, RETIRED |

### 2.2 Reference Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| workerId | string | ✓ | Reference to Worker (person) |
| workRelationshipId | string | ✓ | Reference to WorkRelationship |
| legalEntityCode | string | ✓ | Legal entity code (org_legal.entity.code) |

### 2.3 Classification Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| workerCategoryCode | string | | Workforce category (CORE, SUPPORT, LEADERSHIP) |
| employeeClassCode | string | | HR classification (REGULAR, PROBATION, INTERN) |
| employmentIntent | enum | | PERMANENT, FIXED_TERM, SEASONAL, PROJECT_BASED |

### 2.4 Employment Date Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| hireDate | date | ✓ | Start date with legal entity |
| originalHireDate | date | | First hire date (for re-hires) |
| seniorityDate | date | | Date for seniority calculation |
| seniorityAdjustmentDate | date | | Adjusted seniority (after unpaid leave) |
| terminationDate | date | | Employment end date |
| lastWorkingDate | date | | Last day actually worked |

### 2.5 Probation Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| probationEndDate | date | | Expected end of probation |
| probationResult | enum | | PASSED, FAILED, EXTENDED, IN_PROGRESS |

### 2.6 VN Labor Law Compliance Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| laborContractId | string | | Reference to active Labor Contract |
| socialInsuranceNumber | string | | Mã số BHXH (10 digits) |
| taxCode | string | | Mã số thuế cá nhân |
| laborBookNumber | string | | Số sổ lao động |
| healthInsuranceNumber | string | | Mã số BHYT |
| unionMember | boolean | | Đoàn viên công đoàn? |

### 2.7 Audit Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| createdAt | datetime | ✓ | Record creation timestamp |
| updatedAt | datetime | ✓ | Last modification timestamp |
| createdBy | string | ✓ | User who created record |
| updatedBy | string | ✓ | User who last modified |

---

## 3. Relationships

```mermaid
erDiagram
    Worker ||--o{ Employee : hasEmployees
    WorkRelationship ||--o| Employee : hasEmployee
    LegalEntity ||--o{ Employee : hasEmployees
    Employee ||--o{ Assignment : hasAssignments
    Employee }o--|| Assignment : hasPrimaryAssignment
    Employee }o--o| LaborContract : hasLaborContract
    Employee }o--o| Employee : reportsTo
    
    Employee {
        string id PK
        string employeeCode UK
        string workerId FK
        string workRelationshipId FK
        string legalEntityCode FK
        enum statusCode
        date hireDate
        date terminationDate
    }
    
    Worker {
        string id PK
        string firstName
        string lastName
        date dateOfBirth
    }
    
    WorkRelationship {
        string id PK
        string workerId FK
        enum relationshipTypeCode
        enum statusCode
    }
    
    Assignment {
        string id PK
        string employeeId FK
        string positionId FK
        date startDate
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[Worker]] | belongsToWorker | N:1 | The person behind this employee |
| [[WorkRelationship]] | belongsToWorkRelationship | 1:1 | The work relationship that created this employee |
| [[LegalEntity]] | belongsToLegalEntity | N:1 | The employing legal entity |
| [[Assignment]] | hasAssignments | 1:N | Job assignments |
| [[Assignment]] | hasPrimaryAssignment | N:1 | Current primary assignment |
| [[LaborContract]] | hasLaborContract | N:1 | Current active contract |
| [[Employee]] | reportsTo | N:1 | Direct manager (self-ref) |
| [[Employee]] | hasDirectReports | 1:N | Direct reports (self-ref) |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> ACTIVE: Create Employee (from WorkRelationship)
    
    ACTIVE --> ON_LEAVE: Start Leave
    ON_LEAVE --> ACTIVE: Return from Leave
    
    ACTIVE --> SUSPENDED: Suspend
    SUSPENDED --> ACTIVE: Reinstate
    
    ACTIVE --> TERMINATED: Terminate
    ON_LEAVE --> TERMINATED: Terminate during leave
    SUSPENDED --> TERMINATED: Terminate during suspension
    
    ACTIVE --> RETIRED: Retire
    
    TERMINATED --> [*]
    RETIRED --> [*]
    
    note right of ACTIVE
        Currently employed
        Must have primary assignment
        All HR operations active
    end note
    
    note right of ON_LEAVE
        On approved LONG-TERM leave
        (Sabbatical, Maternity, Sick >= 30 days)
        Short leave (Annual, Sick < 30 days) keeps ACTIVE
        Payroll may continue
    end note
    
    note right of SUSPENDED
        Temporarily suspended
        (Disciplinary or VN Hoãn HĐLĐ)
        Payroll typically stopped
    end note
    
    note right of TERMINATED
        Employment ended
        Terminal state
        Cannot be reactivated
        (Create new Employee for re-hire)
    end note
    
    note right of RETIRED
        Retired from company
        Terminal state
        May be eligible for pension
    end note
```

### State Descriptions

| State | Description | Allowed Operations |
|-------|-------------|-------------------|
| **ACTIVE** | Currently employed, working | All operations, can take leave/suspend/terminate |
| **ON_LEAVE** | On approved LONG-TERM leave (sabbatical, maternity, sick >= 30 days). Short leave (annual, sick < 30 days) keeps ACTIVE status. | Can return, can terminate |
| **SUSPENDED** | Temporarily suspended (disciplinary or VN Hoãn HĐLĐ) | Can reinstate, can terminate |
| **TERMINATED** | Employment ended | Read-only, cannot reactivate |
| **RETIRED** | Retired from company | Read-only, pension eligible |

### Transition Rules

| From | To | Trigger | Guard Condition |
|------|-----|---------|--------------------|
| ACTIVE | ON_LEAVE | startLeave | Approved LONG-TERM leave (sabbatical, maternity, sick >= 30 days) |
| ON_LEAVE | ACTIVE | returnFromLeave | Long-term leave period ended |
| ACTIVE | SUSPENDED | suspend | Suspension action triggered |
| SUSPENDED | ACTIVE | reinstate | Suspension lifted |
| ACTIVE | TERMINATED | terminate | Termination event (synced with WorkRelationship) |
| ON_LEAVE | TERMINATED | terminate | Termination during leave |
| SUSPENDED | TERMINATED | terminate | Termination during suspension |
| ACTIVE | RETIRED | retire | Retirement processed (age eligibility) |

---

## 5. Business Rules Reference

### Validation Rules
- **EmployeeCodeUniqueness**: employeeCode unique within legalEntityCode
- **WorkerToEmployeeMapping**: Employee only created when WorkRelationship.relationshipTypeCode = EMPLOYEE
- **OneEmployeePerWorkRelationship**: Each WorkRelationship has at most ONE Employee
- **PrimaryAssignmentRequired**: ACTIVE Employee must have primary assignment
- **ManagerMustBeActiveEmployee**: reportsTo must reference ACTIVE Employee in same LegalEntity (or cross-entity if allowed)
- **ProbationPeriodValidation**: Probation must be 6/30/60/180 days (VN Labor Law)

### Business Constraints
- **StatusSyncWithWorkRelationship**: Employee.statusCode syncs with WorkRelationship.statusCode
- **HireDateFromWorkRelationship**: Employee.hireDate = WorkRelationship.startDate
- **TerminationDateSync**: Employee TERMINATED → WorkRelationship TERMINATED
- **ManagerAggregationFromAssignment**: Employee.reportsTo can be auto-calculated from Assignment with highest FTE
- **SocialInsuranceRequired**: VN employees need socialInsuranceNumber (WARNING)
- **TaxCodeRequired**: VN employees need taxCode for payroll (WARNING)
- **SeniorityCalculation**: seniorityAdjustmentDate → seniorityDate → originalHireDate → hireDate

### Manager Relationship (Dual-Level)
- **Employee-Level**: Primary/Line Manager (reportsTo) - can be null if tenant uses Assignment-level only
- **Assignment-Level**: Assignment.reportsTo for matrix organization support
- **Aggregation Rule**: If tenant configurable, Employee.reportsTo = Assignment with highest FTE (or earliest if equal)
- **Cross-Entity Reporting**: Allowed if tenant.allowCrossEntityReporting = TRUE (for matrix orgs)

### VN Labor Law Compliance
- **Social Insurance**: Mã số BHXH required for BHXH contributions
- **Tax Code**: Mã số thuế required for personal income tax
- **Labor Book**: Sổ lao động tracking (laborBookNumber)
- **Health Insurance**: Mã số BHYT for healthcare coverage
- **Union Membership**: Track union member status for union dues

### Related Business Rules Documents
- See `[[employee-management.brs.md]]` for complete business rules catalog
- See `[[vn-labor-law-compliance.brs.md]]` for Vietnam-specific requirements
- See `[[probation-management.brs.md]]` for probation period rules
- See `[[seniority-calculation.brs.md]]` for seniority and service calculation

---

## 6. Creation Pattern

### How Employee is Created

```
1. Worker exists (person.worker table)
   ↓
2. WorkRelationship created with relationshipTypeCode = EMPLOYEE
   ↓
3. Employee record auto-created:
   - employeeCode generated (e.g., EMP-2026-001)
   - workerId copied from WorkRelationship
   - legalEntityCode copied from WorkRelationship
   - hireDate = WorkRelationship.startDate
   - statusCode = ACTIVE
   ↓
4. All HR operations now use Employee entity
```

### Example Scenario

```yaml
# Step 1: Worker exists
Worker:
  id: "550e8400-e29b-41d4-a716-446655440000"
  firstName: "Nguyen"
  lastName: "Van A"
  dateOfBirth: "1990-01-15"

# Step 2: WorkRelationship created
WorkRelationship:
  id: "660e8400-e29b-41d4-a716-446655440000"
  workerId: "550e8400-e29b-41d4-a716-446655440000"
  relationshipTypeCode: "EMPLOYEE"
  legalEntityCode: "VNG-HCM"
  startDate: "2026-01-15"
  statusCode: "ACTIVE"

# Step 3: Employee auto-created
Employee:
  id: "770e8400-e29b-41d4-a716-446655440000"
  employeeCode: "EMP-2026-001"
  workerId: "550e8400-e29b-41d4-a716-446655440000"
  workRelationshipId: "660e8400-e29b-41d4-a716-446655440000"
  legalEntityCode: "VNG-HCM"
  hireDate: "2026-01-15"
  statusCode: "ACTIVE"
```

---

*Document Status: APPROVED - Based on DBML design and Oracle HCM patterns*  
*VN Labor Law Compliance: Labor Code 2019, Decree 145/2020/NĐ-CP*
