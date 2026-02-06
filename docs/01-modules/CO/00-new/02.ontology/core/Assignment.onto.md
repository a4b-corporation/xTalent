---
entity: Assignment
domain: core-hr
version: "1.0.0"
status: approved
owner: HR Domain Team
tags: [assignment, job-information, organization, core]

attributes:
  # === IDENTITY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  - name: assignmentNumber
    type: string
    required: false
    unique: true
    description: Human-readable assignment identifier (e.g., ASG-2026-001)
  
  - name: statusCode
    type: enum
    required: true
    description: Current assignment status. Aligned with xTalent naming convention.
    values: [ACTIVE, SUSPENDED, TERMINATED]
    default: ACTIVE
  
  # === EMPLOYEE REFERENCE ===
  - name: employeeId
    type: string
    required: true
    description: Reference to Employee entity. Assignment belongs to Employee, not Worker directly.
  
  - name: isPrimary
    type: boolean
    required: true
    default: true
    description: Is this the primary assignment for the employee? (for multi-job scenarios)
  
  # === DATE EFFECTIVENESS ===
  - name: effectiveStartDate
    type: date
    required: true
    description: Date this assignment record becomes effective (date-effective tracking)
  
  - name: effectiveEndDate
    type: date
    required: false
    description: Date this assignment record expires (null = current, 9999-12-31 = indefinite future)
  
  - name: isCurrent
    type: boolean
    required: true
    default: true
    description: Is this the current effective record? (optimization flag)
  
  # === ORGANIZATIONAL STRUCTURE ===
  - name: positionId
    type: string
    required: false
    description: Reference to Position entity (the "chair" being occupied)
  
  - name: jobId
    type: string
    required: false
    description: Reference to Job entity (role definition/job profile)
  
  - name: departmentId
    type: string
    required: true
    description: Reference to Department/Business Unit entity
  
  - name: legalEntityCode
    type: string
    required: true
    description: Legal entity code (must match Employee.legalEntityCode)
  
  - name: locationId
    type: string
    required: false
    description: Reference to Work Location entity
  
  - name: costCenterId
    type: string
    required: false
    description: Reference to Cost Center (if different from department default)
  
  # === EMPLOYMENT CLASSIFICATION ===
  - name: employeeClassCode
    type: string
    required: false
    description: Employee classification for this assignment (e.g., WHITE_COLLAR, BLUE_COLLAR, EXECUTIVE). Reference to CODELIST_EMPLOYEE_CLASS.
    constraints:
      reference: CODELIST_EMPLOYEE_CLASS
  
  - name: employmentTypeCode
    type: string
    required: false
    description: Employment type for this assignment (e.g., REGULAR, INTERN, CONTRACTOR). Reference to CODELIST_EMPLOYMENT_TYPE.
    constraints:
      reference: CODELIST_EMPLOYMENT_TYPE
  
  - name: fte
    type: decimal
    required: false
    default: 1.0
    description: Full-Time Equivalent (0.0 to 1.0). 1.0 = full-time, 0.5 = half-time, etc.
    constraints:
      min: 0.0
      max: 1.0
  
  # === MANAGER RELATIONSHIP (Matrix Org Support) ===
  - name: reportsToEmployeeId
    type: string
    required: false
    description: Reference to Manager's Employee record (for matrix organization). This is Assignment-level manager, separate from Employee.reportsTo.
  
  - name: reportsToAssignmentId
    type: string
    required: false
    description: Reference to Manager's Assignment record (for precise reporting line tracking)
  
  # === ASSIGNMENT EVENT ===
  - name: assignmentReasonCode
    type: string
    required: false
    description: Reason for this assignment change (HIRE, PROMOTION, TRANSFER, DATA_CHANGE, etc.). Reference to CODELIST_ASSIGNMENT_REASON.
    constraints:
      reference: CODELIST_ASSIGNMENT_REASON
  
  - name: assignmentEventDate
    type: date
    required: false
    description: Date the assignment event occurred (may differ from effectiveStartDate)
  
  # === PROBATION (Assignment-Level) ===
  - name: probationEndDate
    type: date
    required: false
    description: Probation end date for this assignment (if applicable)
  
  # === WORK SCHEDULE ===
  - name: workScheduleId
    type: string
    required: false
    description: Reference to Work Schedule/Pattern entity
  
  - name: noticePeriodDays
    type: integer
    required: false
    description: Notice period in days for this assignment (may differ by position/level)
    constraints:
      min: 0
      max: 90
  
  # === METADATA ===
  - name: metadata
    type: json
    required: false
    description: Additional flexible data (grade, level, office number, etc.)
  
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
  - name: belongsToEmployee
    target: Employee
    cardinality: many-to-one
    required: true
    inverse: hasAssignments
    description: The employee this assignment belongs to. INVERSE - Employee.hasAssignments must reference this Assignment.
  
  - name: isPrimaryFor
    target: Employee
    cardinality: one-to-many
    required: false
    inverse: hasPrimaryAssignment
    description: If this is primary assignment, reference to Employee. INVERSE - Employee.hasPrimaryAssignment must reference this Assignment.
  
  - name: occupiesPosition
    target: Position
    cardinality: many-to-one
    required: false
    inverse: hasAssignments
    description: The position (chair) being occupied. INVERSE - Position.hasAssignments must reference this Assignment.
  
  - name: performsJob
    target: Job
    cardinality: many-to-one
    required: false
    inverse: hasAssignments
    description: The job profile/role being performed. INVERSE - Job.hasAssignments must reference this Assignment.
  
  - name: belongsToDepartment
    target: Department
    cardinality: many-to-one
    required: true
    inverse: hasAssignments
    description: The department/business unit. INVERSE - Department.hasAssignments must reference this Assignment.
  
  - name: basedAtLocation
    target: Location
    cardinality: many-to-one
    required: false
    inverse: hasAssignments
    description: The work location. INVERSE - Location.hasAssignments must reference this Assignment.
  
  - name: chargedToCostCenter
    target: CostCenter
    cardinality: many-to-one
    required: false
    inverse: hasAssignments
    description: The cost center for financial tracking. INVERSE - CostCenter.hasAssignments must reference this Assignment.
  
  - name: reportsToEmployee
    target: Employee
    cardinality: many-to-one
    required: false
    inverse: hasDirectReportAssignments
    description: Manager's Employee record (for matrix org). INVERSE - Employee.hasDirectReportAssignments must reference this Assignment.
  
  - name: reportsToAssignment
    target: Assignment
    cardinality: many-to-one
    required: false
    inverse: hasDirectReports
    description: Manager's Assignment record (self-referential for precise reporting line). INVERSE - Assignment.hasDirectReports must reference this Assignment.
  
  - name: hasDirectReports
    target: Assignment
    cardinality: one-to-many
    required: false
    inverse: reportsToAssignment
    description: Assignments reporting to this assignment (self-referential). INVERSE - Assignment.reportsToAssignment must reference this Assignment.
  
  - name: followsWorkSchedule
    target: WorkSchedule
    cardinality: many-to-one
    required: false
    inverse: hasAssignments
    description: The work schedule/pattern. INVERSE - WorkSchedule.hasAssignments must reference this Assignment.

lifecycle:
  states: [ACTIVE, SUSPENDED, TERMINATED]
  initial: ACTIVE
  terminal: [TERMINATED]
  transitions:
    - from: ACTIVE
      to: SUSPENDED
      trigger: suspend
      guard: Suspension action triggered (follows Employee suspension or assignment-specific)
    - from: SUSPENDED
      to: ACTIVE
      trigger: reinstate
      guard: Suspension lifted
    - from: ACTIVE
      to: TERMINATED
      trigger: terminate
      guard: Assignment ended (transfer, termination, or end date reached)
    - from: SUSPENDED
      to: TERMINATED
      trigger: terminate
      guard: Termination during suspension

policies:
  - name: AssignmentNumberUniqueness
    type: validation
    rule: assignmentNumber must be unique across all assignments
    expression: "COUNT(Assignment WHERE assignmentNumber = X) = 1"
  
  - name: EmployeeLegalEntityMatch
    type: validation
    rule: Assignment.legalEntityCode must match Employee.legalEntityCode
    expression: "Assignment.legalEntityCode = Employee.legalEntityCode"
    severity: ERROR
  
  - name: OnePrimaryAssignmentPerEmployee
    type: validation
    rule: Employee can have at most ONE primary assignment at any time
    expression: "COUNT(Assignment WHERE employeeId = X AND isPrimary = true AND isCurrent = true) <= 1"
    severity: ERROR
  
  - name: DateEffectivenessConsistency
    type: validation
    rule: effectiveStartDate must be before effectiveEndDate (if set)
    expression: "effectiveEndDate IS NULL OR effectiveStartDate < effectiveEndDate"
  
  - name: CurrentRecordFlag
    type: business
    rule: isCurrent = true only for records where effectiveStartDate <= TODAY <= effectiveEndDate (or effectiveEndDate is null)
    trigger: ON_UPDATE(effectiveStartDate, effectiveEndDate)
  
  - name: FTEValidation
    type: validation
    rule: FTE must be between 0.0 and 1.0
    expression: "fte >= 0.0 AND fte <= 1.0"
  
  - name: StatusSyncWithEmployee
    type: business
    rule: When Employee is TERMINATED or SUSPENDED, all ACTIVE assignments should be TERMINATED or SUSPENDED
    trigger: ON_UPDATE(Employee.statusCode)
    severity: WARNING
  
  - name: ManagerValidation
    type: validation
    rule: reportsToEmployee must reference an ACTIVE Employee (if set)
    expression: "reportsToEmployee IS NULL OR reportsToEmployee.statusCode = ACTIVE"
  
  - name: ManagerAssignmentConsistency
    type: business
    rule: If reportsToAssignmentId is set, reportsToEmployeeId must match the assignment's employeeId
    expression: "reportsToAssignmentId IS NULL OR reportsToAssignment.employeeId = reportsToEmployeeId"
  
  - name: PrimaryAssignmentRequired
    type: business
    rule: ACTIVE Employee must have at least one ACTIVE primary assignment
    severity: WARNING
  
  - name: PositionOrJobRequired
    type: business
    rule: Assignment should have either Position or Job (or both) defined
    expression: "positionId IS NOT NULL OR jobId IS NOT NULL"
    severity: WARNING
  
  - name: AssignmentEventTracking
    type: business
    rule: Major assignment changes (HIRE, PROMOTION, TRANSFER) should have assignmentReasonCode set
    severity: INFO
  
  # === STAFFING MODEL CONDITIONAL CONSTRAINTS ===
  - name: PositionRequiredWhenPositionBased
    type: validation
    rule: When Legal Entity uses POSITION_BASED staffing model, positionId is required
    expression: "LegalEntity.staffingModelCode != 'POSITION_BASED' OR positionId IS NOT NULL"
    severity: ERROR
    condition: "LegalEntity.staffingModelCode = 'POSITION_BASED'"
  
  - name: JobRequiredWhenJobBased
    type: validation
    rule: When Legal Entity uses JOB_BASED staffing model and positionId is null, jobId is required
    expression: "LegalEntity.staffingModelCode != 'JOB_BASED' OR positionId IS NOT NULL OR jobId IS NOT NULL"
    severity: ERROR
    condition: "LegalEntity.staffingModelCode = 'JOB_BASED' AND positionId IS NULL"
  
  - name: EitherPositionOrJobWhenHybrid
    type: validation
    rule: When Legal Entity uses HYBRID staffing model, either positionId or jobId must be provided
    expression: "LegalEntity.staffingModelCode != 'HYBRID' OR positionId IS NOT NULL OR jobId IS NOT NULL"
    severity: ERROR
    condition: "LegalEntity.staffingModelCode = 'HYBRID'"
  
  - name: JobAutoDerivation
    type: business
    rule: If positionId is provided and jobId is null, system auto-fills jobId from Position.jobId
    expression: "positionId IS NULL OR jobId IS NOT NULL OR jobId = Position.jobId"
    trigger: ON_CREATE, ON_UPDATE(positionId)
    severity: INFO
---

# Entity: Assignment

## 1. Overview

The **Assignment** entity represents the link between an **Employee** and their **organizational context** (Position, Job, Department, Location). It is the **date-effective** record that tracks all changes to an employee's job information over time.

**Key Concept**:
```
Employee + Assignment → Position/Job/Department/Location (at a point in time)
```

Every change (promotion, transfer, raise) creates a **new Assignment record** with a new effectiveStartDate, preserving complete history.

```mermaid
mindmap
  root((Assignment))
    Identity
      id
      assignmentNumber
      statusCode
    Employee Reference
      employeeId
      isPrimary
    Date Effectiveness
      effectiveStartDate
      effectiveEndDate
      isCurrent
    Organization
      positionId
      jobId
      departmentId
      legalEntityCode
      locationId
      costCenterId
    Classification
      employeeClassCode
      employmentTypeCode
      fte
    Manager (Matrix Org)
      reportsToEmployeeId
      reportsToAssignmentId
    Assignment Event
      assignmentReasonCode
      assignmentEventDate
    Work Details
      probationEndDate
      workScheduleId
      noticePeriodDays
    Relationships
      belongsToEmployee
      isPrimaryFor
      occupiesPosition
      performsJob
      belongsToDepartment
      basedAtLocation
      reportsToEmployee
      reportsToAssignment
    Lifecycle
      ACTIVE
      SUSPENDED
      TERMINATED
```

**Design Rationale**:
- **Date-Effective Tracking**: Complete history of all job changes
- **Matrix Organization Support**: Assignment-level manager (reportsTo) separate from Employee-level
- **Multi-Job Support**: Employee can have multiple concurrent assignments (with FTE split)
- **Organizational Flexibility**: Position-based OR Job-based (or both)

---

## 2. Attributes

### 2.1 Identity Attributes

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| id | string | ✓ | Unique internal identifier (UUID) | employment.assignment.id |
| assignmentNumber | string | | Human-readable ID (ASG-2026-001) | <<employment.assignment.assignment_number>> |
| statusCode | enum | ✓ | ACTIVE, SUSPENDED, TERMINATED | employment.assignment.status_code → common.code_list(ASSIGNMENT_STATUS) |

### 2.2 Employee Reference Attributes

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| employeeId | string | ✓ | Reference to Employee | employment.assignment.employee_id → employment.employee.id |
| isPrimary | boolean | ✓ | Primary assignment flag (for multi-job) | <<employment.assignment.is_primary>> |

### 2.3 Date Effectiveness Attributes

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| effectiveStartDate | date | ✓ | Record becomes effective | employment.assignment.start_date |
| effectiveEndDate | date | | Record expires (null = current) | employment.assignment.end_date |
| isCurrent | boolean | ✓ | Current effective record flag | <<employment.assignment.is_current_flag>> |

### 2.4 Organizational Structure Attributes

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| positionId | string | | Position being occupied | employment.assignment.position_id → jobpos.position.id |
| jobId | string | | Job profile/role | <<employment.assignment.job_id>> → jobpos.job.id |
| departmentId | string | ✓ | Department/Business Unit | employment.assignment.business_unit_id → org_bu.unit.id |
| legalEntityCode | string | ✓ | Legal entity (must match Employee) | <<employment.assignment.legal_entity_code>> → org_legal.entity.code |
| locationId | string | | Work location | employment.assignment.primary_location_id → facility.work_location.id |
| costCenterId | string | | Cost center (if different from dept) | (employment.assignment.metadata.cost_center_id) |

### 2.5 Employment Classification Attributes

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| employeeClassCode | string | | WHITE_COLLAR, BLUE_COLLAR, EXECUTIVE | (employment.assignment.metadata.employee_class_code) |
| employmentTypeCode | string | | REGULAR, INTERN, CONTRACTOR | (employment.assignment.metadata.employment_type_code) |
| fte | decimal | | Full-Time Equivalent (0.0-1.0) | employment.assignment.fte |

### 2.6 Manager Relationship Attributes (Matrix Org)

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| reportsToEmployeeId | string | | Manager's Employee record | <<employment.assignment.supervisor_employee_id>> → employment.employee.id |
| reportsToAssignmentId | string | | Manager's Assignment record | employment.assignment.supervisor_assignment_id → employment.assignment.id |

### 2.7 Assignment Event Attributes

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| assignmentReasonCode | string | | HIRE, PROMOTION, TRANSFER, DATA_CHANGE | employment.assignment.reason_code → common.code_list(ASSIGN_CHANGE_REASON) |
| assignmentEventDate | date | | Date event occurred | (employment.assignment.metadata.assignment_event_date) |

### 2.8 Work Details Attributes

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| probationEndDate | date | | Probation end for this assignment | (employment.assignment.metadata.probation_end_date) |
| workScheduleId | string | | Work schedule/pattern | employment.assignment.work_pattern_code → time_attendance.work_pattern.code |
| noticePeriodDays | integer | | Notice period (days) | (employment.assignment.metadata.notice_period_days) |

### 2.9 Audit Attributes

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| createdAt | datetime | ✓ | Record creation timestamp | employment.assignment.created_at |
| updatedAt | datetime | ✓ | Last modification timestamp | employment.assignment.updated_at |
| createdBy | string | ✓ | User who created record | <<employment.assignment.created_by>> |
| updatedBy | string | ✓ | User who last modified | <<employment.assignment.updated_by>> |

---

## 3. Relationships

```mermaid
erDiagram
    Employee ||--o{ Assignment : hasAssignments
    Employee ||--o| Assignment : hasPrimaryAssignment
    Assignment }o--o| Position : occupiesPosition
    Assignment }o--o| Job : performsJob
    Assignment }o--|| Department : belongsToDepartment
    Assignment }o--o| Location : basedAtLocation
    Assignment }o--o| CostCenter : chargedToCostCenter
    Assignment }o--o| Employee : reportsToEmployee
    Assignment }o--o| Assignment : reportsToAssignment
    Assignment }o--o| WorkSchedule : followsWorkSchedule
    
    Assignment {
        string id PK
        string assignmentNumber UK
        string employeeId FK
        enum statusCode
        date effectiveStartDate
        date effectiveEndDate
        boolean isPrimary
        boolean isCurrent
        decimal fte
    }
    
    Employee {
        string id PK
        string employeeCode UK
        enum statusCode
    }
    
    Position {
        string id PK
        string positionCode UK
    }
    
    Job {
        string id PK
        string jobCode UK
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[Employee]] | belongsToEmployee | N:1 | The employee this assignment belongs to |
| [[Employee]] | isPrimaryFor | N:1 | If primary, reference to employee |
| [[Position]] | occupiesPosition | N:1 | Position being occupied |
| [[Job]] | performsJob | N:1 | Job profile/role |
| [[Department]] | belongsToDepartment | N:1 | Department/Business Unit |
| [[Location]] | basedAtLocation | N:1 | Work location |
| [[CostCenter]] | chargedToCostCenter | N:1 | Cost center |
| [[Employee]] | reportsToEmployee | N:1 | Manager's Employee (matrix org) |
| [[Assignment]] | reportsToAssignment | N:1 | Manager's Assignment (self-ref) |
| [[Assignment]] | hasDirectReports | 1:N | Direct reports (self-ref) |
| [[WorkSchedule]] | followsWorkSchedule | N:1 | Work schedule/pattern |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> ACTIVE: Create Assignment
    
    ACTIVE --> SUSPENDED: Suspend
    SUSPENDED --> ACTIVE: Reinstate
    
    ACTIVE --> TERMINATED: Terminate
    SUSPENDED --> TERMINATED: Terminate during suspension
    
    TERMINATED --> [*]
    
    note right of ACTIVE
        Currently active assignment
        Employee is working in this role
        Date-effective record is current
    end note
    
    note right of SUSPENDED
        Temporarily suspended
        Follows Employee suspension
        or assignment-specific suspension
    end note
    
    note right of TERMINATED
        Assignment ended
        Terminal state
        Historical record preserved
        (New assignment for changes)
    end note
```

### State Descriptions

| State | Description | Allowed Operations |
|-------|-------------|-------------------|
| **ACTIVE** | Currently active assignment | Can suspend, can terminate, can update |
| **SUSPENDED** | Temporarily suspended | Can reinstate, can terminate |
| **TERMINATED** | Assignment ended | Read-only, historical record |

### Transition Rules

| From | To | Trigger | Guard Condition |
|------|-----|---------|--------------------|
| ACTIVE | SUSPENDED | suspend | Suspension action triggered |
| SUSPENDED | ACTIVE | reinstate | Suspension lifted |
| ACTIVE | TERMINATED | terminate | Assignment ended (transfer/termination/end date) |
| SUSPENDED | TERMINATED | terminate | Termination during suspension |

---

## 5. Business Rules Reference

### Validation Rules
- **AssignmentNumberUniqueness**: assignmentNumber unique across all assignments
- **EmployeeLegalEntityMatch**: Assignment.legalEntityCode must match Employee.legalEntityCode
- **OnePrimaryAssignmentPerEmployee**: Employee can have at most ONE primary assignment
- **DateEffectivenessConsistency**: effectiveStartDate < effectiveEndDate (if set)
- **FTEValidation**: FTE must be between 0.0 and 1.0
- **ManagerValidation**: reportsToEmployee must reference ACTIVE Employee

### Business Constraints
- **CurrentRecordFlag**: isCurrent = true only for current effective records
- **StatusSyncWithEmployee**: Assignment status syncs with Employee status (WARNING)
- **ManagerAssignmentConsistency**: reportsToAssignment.employeeId must match reportsToEmployeeId
- **PrimaryAssignmentRequired**: ACTIVE Employee must have ACTIVE primary assignment (WARNING)
- **PositionOrJobRequired**: Assignment should have Position or Job defined (WARNING)
- **AssignmentEventTracking**: Major changes should have assignmentReasonCode (INFO)

### Staffing Model Conditional Constraints

These constraints are conditional based on `LegalEntity.staffingModelCode`. See [[LegalEntity]] for staffing model configuration.

| Rule ID | Condition | Constraint | Severity |
|---------|-----------|------------|----------|
| **PositionRequiredWhenPositionBased** | LegalEntity.staffingModelCode = 'POSITION_BASED' | positionId IS NOT NULL | ERROR |
| **JobRequiredWhenJobBased** | LegalEntity.staffingModelCode = 'JOB_BASED' AND positionId IS NULL | jobId IS NOT NULL | ERROR |
| **EitherPositionOrJobWhenHybrid** | LegalEntity.staffingModelCode = 'HYBRID' | positionId OR jobId IS NOT NULL | ERROR |
| **JobAutoDerivation** | positionId IS NOT NULL AND jobId IS NULL | Auto-fill: jobId = Position.jobId | INFO |

#### Staffing Model Examples

**Position-based Organization (default)**:
```yaml
# ✅ Valid - has positionId, jobId auto-derived from Position.jobId
Assignment:
  legalEntityCode: "VNG-HCM"  # staffingModelCode = POSITION_BASED
  positionId: "pos-dev-001"
  jobId: null  # System auto-fills from Position.jobId

# ❌ Invalid - missing positionId
Assignment:
  legalEntityCode: "VNG-HCM"  # staffingModelCode = POSITION_BASED
  positionId: null  # ERROR: Position required for position-based staffing
  jobId: "job-dev"
```

**Job-based Organization**:
```yaml
# ✅ Valid - has jobId only (no position required)
Assignment:
  legalEntityCode: "VNG-RETAIL"  # staffingModelCode = JOB_BASED
  positionId: null
  jobId: "job-sales-associate"

# ✅ Also valid - has both (position is optional for tracking)
Assignment:
  legalEntityCode: "VNG-RETAIL"  # staffingModelCode = JOB_BASED
  positionId: "pos-store-001"  # Optional tracking
  jobId: "job-sales-associate"
```

**Hybrid Organization**:
```yaml
# ✅ Valid - has positionId (jobId auto-derived)
Assignment:
  legalEntityCode: "VNG-FLEX"  # staffingModelCode = HYBRID
  positionId: "pos-mgr-001"
  jobId: null  # Auto-derived

# ✅ Valid - has jobId only
Assignment:
  legalEntityCode: "VNG-FLEX"  # staffingModelCode = HYBRID
  positionId: null
  jobId: "job-contractor"

# ❌ Invalid - neither positionId nor jobId
Assignment:
  legalEntityCode: "VNG-FLEX"  # staffingModelCode = HYBRID
  positionId: null  # ERROR: At least one required
  jobId: null       # ERROR: At least one required
```

### Date-Effective Pattern
- **New Assignment**: Every job change creates new record with new effectiveStartDate
- **Historical Records**: Old records have effectiveEndDate = new record's effectiveStartDate - 1 day
- **Current Record**: isCurrent = true, effectiveEndDate = null or future date
- **Query Pattern**: `WHERE isCurrent = true` for current assignments, `WHERE effectiveStartDate <= :date AND (effectiveEndDate IS NULL OR effectiveEndDate >= :date)` for point-in-time

### Matrix Organization Support
- **Dual-Level Manager**:
  - **Employee.reportsTo**: Primary/Line Manager (aggregated or manual)
  - **Assignment.reportsTo**: Assignment-specific manager (for matrix org)
- **Use Case**: Employee has 2 assignments (50% Dev Lead, 50% Tech Architect) with different managers
- **Aggregation**: Employee.reportsTo can be auto-calculated from Assignment with highest FTE

### Multi-Job Scenarios
- **Concurrent Assignments**: Employee can have multiple ACTIVE assignments
- **FTE Split**: Sum of FTE across all assignments should <= 1.0 (WARNING)
- **Primary Assignment**: Exactly one assignment must have isPrimary = true
- **Example**: 0.6 FTE as Developer + 0.4 FTE as Trainer = 1.0 FTE total

### Related Business Rules Documents
- See `[[assignment-management.brs.md]]` for complete business rules catalog
- See `[[date-effective-tracking.brs.md]]` for date-effective pattern rules
- See `[[matrix-organization.brs.md]]` for matrix org reporting rules
- See `[[multi-job-management.brs.md]]` for multi-job scenario rules

---

## 6. Date-Effective Example

### Scenario: Promotion

```yaml
# Initial Assignment (Hire as Junior Developer)
Assignment_1:
  id: "asg-001"
  employeeId: "emp-001"
  effectiveStartDate: "2024-01-15"
  effectiveEndDate: "2025-06-30"  # Set when promotion happens
  isCurrent: false  # No longer current
  jobId: "job-junior-dev"
  departmentId: "dept-engineering"
  fte: 1.0
  assignmentReasonCode: "HIRE"

# New Assignment (Promoted to Senior Developer)
Assignment_2:
  id: "asg-002"
  employeeId: "emp-001"
  effectiveStartDate: "2025-07-01"
  effectiveEndDate: null  # Current assignment
  isCurrent: true
  jobId: "job-senior-dev"
  departmentId: "dept-engineering"
  fte: 1.0
  assignmentReasonCode: "PROMOTION"
```

### Scenario: Multi-Job (Matrix Org)

```yaml
# Primary Assignment (60% as Developer)
Assignment_A:
  id: "asg-003"
  employeeId: "emp-002"
  effectiveStartDate: "2026-01-01"
  effectiveEndDate: null
  isCurrent: true
  isPrimary: true
  jobId: "job-developer"
  departmentId: "dept-product-a"
  fte: 0.6
  reportsToEmployeeId: "emp-manager-a"
  assignmentReasonCode: "HIRE"

# Secondary Assignment (40% as Tech Trainer)
Assignment_B:
  id: "asg-004"
  employeeId: "emp-002"
  effectiveStartDate: "2026-01-01"
  effectiveEndDate: null
  isCurrent: true
  isPrimary: false
  jobId: "job-trainer"
  departmentId: "dept-training"
  fte: 0.4
  reportsToEmployeeId: "emp-manager-b"
  assignmentReasonCode: "DATA_CHANGE"
```

---

*Document Status: APPROVED - Based on Oracle HCM, SAP SuccessFactors, Workday patterns*  
*Date-Effective Pattern: Industry standard for historical tracking*
