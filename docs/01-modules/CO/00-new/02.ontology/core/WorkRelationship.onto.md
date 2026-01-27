---
entity: WorkRelationship
domain: core-hr
version: "1.0.0"
status: approved
owner: HR Domain Team
tags: [employment, contract, relationship, core]

attributes:
  # === IDENTITY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  - name: relationshipNumber
    type: string
    required: false
    unique: true
    description: Human-readable relationship identifier (e.g., WR-2026-001)
  
  - name: statusCode
    type: enum
    required: true
    description: Current status of the work relationship. Renamed to statusCode per xTalent naming convention.
    values: [PENDING, ACTIVE, SUSPENDED, TERMINATED]
  
  # === WORKER & EMPLOYER ===
  - name: workerId
    type: string
    required: true
    description: Reference to Worker entity (the person)
  
  - name: legalEmployerId
    type: string
    required: true
    description: Reference to Legal Entity (the contracting company)
  
  - name: relationshipTypeCode
    type: enum
    required: true
    description: Classification of worker engagement type. Renamed to relationshipTypeCode per xTalent naming convention. PROBATION is a status/phase, not a type.
    values: [EMPLOYEE, CONTINGENT, CONTRACTOR, INTERN, NON_WORKER]
    metadata:
      mapping:
        EMPLOYEE: Internal Payroll + BHXH
        CONTINGENT: Agency Payroll (No internal BHXH)
        CONTRACTOR: B2B/Freelance Invoice
        INTERN: Internship program
        NON_WORKER: Unpaid/Volunteer
  
  - name: employmentIntent
    type: enum
    required: false
    description: Strategic intent of employment (separate from legal contract type). Supports workforce planning. From RFC 1.
    values: [PERMANENT, FIXED_TERM, SEASONAL, PROJECT_BASED]
    default: PERMANENT
  
  - name: isPrimary
    type: boolean
    required: true
    default: true
    description: Is this the primary employment relationship? (for multi-job scenarios)
  
  # === DATES - HIRE & START ===
  - name: startDate
    type: date
    required: true
    description: Date the work relationship began (Hire Date / Ngày bắt đầu làm việc)
  
  - name: originalHireDate
    type: date
    required: false
    description: First hire date with this company (for re-hires). Used for seniority calculation.
  
  - name: seniorityDate
    type: date
    required: false
    description: Date from which seniority is calculated (for leave/severance). May differ from startDate.
  
  - name: seniorityAdjustmentDate
    type: date
    required: false
    description: Adjusted service date for seniority calculation (e.g., after unpaid leave deduction). Overrides seniorityDate if set.
  
  # === PROBATION ===
  - name: probationEndDate
    type: date
    required: false
    description: Expected end date of probation period (VN - 6/30/60/180 days)
  
  - name: probationResult
    type: enum
    required: false
    description: Outcome of probation period. EXTENDED is valid per VN Labor Law.
    values: [PASSED, FAILED, EXTENDED, IN_PROGRESS]
  
  - name: probationExtensionReason
    type: string
    required: false
    description: Reason for probation extension (if applicable)
  
  # === LABOR CONTRACT ===
  - name: currentLaborContractId
    type: string
    required: false
    description: Reference to the currently active Labor Contract (Hợp đồng lao động)
  
  # === SUSPENSION (VN Specific) ===
  - name: suspensionStartDate
    type: date
    required: false
    description: Start date of suspension period (Hoãn thực hiện HĐLĐ)
  
  - name: suspensionEndDate
    type: date
    required: false
    description: Expected end date of suspension period
  
  - name: suspensionReason
    type: string
    required: false
    description: Reason for suspension (Maternity, Military Service, Unpaid Leave, etc.)
    constraints:
      reference: CODELIST_SUSPENSION_REASON
  
  # === TERMINATION ===
  - name: terminationDate
    type: date
    required: false
    description: Official date the work relationship ended (Ngày chấm dứt HĐLĐ)
  
  - name: lastWorkingDate
    type: date
    required: false
    description: Last day the worker actually worked (may differ from terminationDate)
  
  - name: notificationDate
    type: date
    required: false
    description: Date termination was notified to employee (for notice period calculation)
  
  - name: resignationDate
    type: date
    required: false
    description: Date employee submitted resignation (if voluntary termination)
  
  - name: terminationReasonCode
    type: string
    required: false
    description: Reference code to TerminationReason entity (Resignation, Layoff, Fired, Contract End, etc.). Renamed to terminationReasonCode per xTalent naming convention.
  
  - name: terminationInitiatedBy
    type: enum
    required: false
    description: Who initiated the termination
    values: [EMPLOYEE, EMPLOYER, MUTUAL, AUTOMATIC]
  
  - name: noticePeriod
    type: number
    required: false
    description: Required notice period in days (as per contract or law)
    constraints:
      min: 0
      max: 90
  
  # === RE-HIRE ELIGIBILITY ===
  - name: eligibleForRehire
    type: boolean
    required: false
    default: true
    description: Is this person eligible for re-hire? (false if fired for cause)
  
  - name: regretTermination
    type: boolean
    required: false
    description: Does company regret losing this employee? (for talent pipeline)
  
  # === VN LABOR LAW SPECIFIC ===
  - name: terminationDecisionNumber
    type: string
    required: false
    description: Official termination decision number (Số quyết định thôi việc - VN requirement)
  
  - name: terminationDecisionDate
    type: date
    required: false
    description: Date termination decision was signed (Ngày ký quyết định)
  
  - name: laborBookStatus
    type: enum
    required: false
    description: Status of Labor Book return (Sổ lao động - VN specific). Critical for legal compliance.
    values: [NOT_APPLICABLE, PENDING_RETURN, RETURNED_TO_EMPLOYEE, HELD_BY_COMPANY]
  
  - name: socialInsuranceBookStatus
    type: enum
    required: false
    description: Status of Social Insurance Book (Sổ BHXH - VN specific). Renamed from socialInsuranceCloseDate for clarity.
    values: [NOT_APPLICABLE, OPEN, CLOSED, RETURNED_TO_EMPLOYEE, HELD_BY_COMPANY]
  
  - name: socialInsuranceCloseDate
    type: date
    required: false
    description: Date social insurance was closed (Ngày chốt sổ BHXH - VN)
  
  - name: severanceAllowanceStatus
    type: enum
    required: false
    description: Status of severance allowance payment (Trợ cấp thôi việc)
    values: [NOT_ELIGIBLE, PENDING, PAID, WAIVED]
  
  - name: unemploymentInsuranceStatus
    type: enum
    required: false
    description: Status of unemployment insurance book (Sổ BHTN)
    values: [NOT_APPLICABLE, RETURNED_TO_EMPLOYEE, HELD_BY_COMPANY]
  
  # === PROJECTED DATES (for Fixed-Term Contracts) ===
  - name: projectedTerminationDate
    type: date
    required: false
    description: Expected end date for fixed-term contracts (Ngày dự kiến kết thúc HĐLĐ có thời hạn)
  
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
    inverse: hasWorkRelationships
    description: The person engaged in this work relationship. INVERSE - Worker.hasWorkRelationships must reference this WorkRelationship.
  
  - name: belongsToLegalEmployer
    target: LegalEntity
    cardinality: many-to-one
    required: true
    inverse: hasWorkRelationships
    description: The legal entity (company) that employs the worker. INVERSE - LegalEntity.hasWorkRelationships must reference this WorkRelationship.
  
  - name: hasLaborContracts
    target: LaborContract
    cardinality: one-to-many
    required: false
    inverse: belongsToWorkRelationship
    description: Labor contracts associated with this relationship (can have multiple due to renewals). INVERSE - LaborContract.belongsToWorkRelationship must reference this WorkRelationship.
  
  - name: hasAssignments
    target: Assignment
    cardinality: one-to-many
    required: false
    inverse: belongsToWorkRelationship
    description: Job assignments within this work relationship. INVERSE - Assignment.belongsToWorkRelationship must reference this WorkRelationship.
  
  - name: hasPrimaryAssignment
    target: Assignment
    cardinality: many-to-one
    required: false
    inverse: isPrimaryFor
    description: The primary (main) job assignment. INVERSE - Assignment.isPrimaryFor must reference this WorkRelationship.
  
  - name: hasTerminationReason
    target: TerminationReason
    cardinality: many-to-one
    required: false
    inverse: usedByWorkRelationships
    description: The reason for termination (if terminated). INVERSE - TerminationReason.usedByWorkRelationships must reference this WorkRelationship.
  
  - name: hasCompensationBases
    target: CompensationBasis
    cardinality: one-to-many
    required: false
    inverse: belongsToWorkRelationship
    description: Compensation basis records (salary history) for this work relationship. Date-effective SCD Type-2 pattern. INVERSE - CompensationBasis.belongsToWorkRelationship must reference this WorkRelationship.
  
  - name: hasCurrentCompensationBasis
    target: CompensationBasis
    cardinality: many-to-one
    required: false
    inverse: isCurrentFor
    description: Current effective compensation basis (convenience pointer to the record with isCurrent=true). INVERSE - CompensationBasis.isCurrentFor.

lifecycle:
  states: [PENDING, ACTIVE, SUSPENDED, TERMINATED]
  initial: PENDING
  terminal: [TERMINATED]
  transitions:
    - from: PENDING
      to: ACTIVE
      trigger: activate
      guard: Hire date reached AND probation started (if applicable)
    - from: ACTIVE
      to: SUSPENDED
      trigger: suspend
      guard: Valid suspension reason (maternity, military, unpaid leave)
    - from: SUSPENDED
      to: ACTIVE
      trigger: resume
      guard: Suspension period ended
    - from: ACTIVE
      to: TERMINATED
      trigger: terminate
      guard: Termination event triggered (terminationDate does NOT auto-trigger status change)
    - from: SUSPENDED
      to: TERMINATED
      trigger: terminate
      guard: Termination during suspension (e.g., contract expiry, dismissal during maternity leave)
    - from: PENDING
      to: TERMINATED
      trigger: cancelHire
      guard: Hire cancelled before start date

policies:
  - name: UniqueActiveRelationship
    type: validation
    rule: A Worker can have only ONE ACTIVE primary relationship per Legal Employer at any time
    expression: "COUNT(WorkRelationship WHERE workerId = X AND legalEmployerId = Y AND statusCode = ACTIVE AND isPrimary = true) <= 1"
  
  - name: StartDateBeforeEnd
    type: validation
    rule: Start date must be before termination date
    expression: "startDate < terminationDate"
  
  - name: OriginalHireDateTracking
    type: business
    rule: For re-hires, originalHireDate must be set to the first hire date with this company
  
  - name: SeniorityCalculation
    type: business
    rule: If seniorityDate is null, use originalHireDate. If originalHireDate is null, use startDate.
  
  - name: ProbationPeriodValidation
    type: validation
    rule: Probation period must comply with VN Labor Law (6/30/60/180 days based on job complexity)
    expression: "probationEndDate - startDate IN [6, 30, 60, 180] days"
  
  - name: NoticePeriodCompliance
    type: business
    rule: Notice period must comply with contract terms and VN Labor Law minimums
  
  - name: TerminationDocumentation
    type: business
    rule: For VN, terminated relationships must have terminationDecisionNumber and terminationDecisionDate
  
  - name: SuspensionDatesConsistency
    type: validation
    rule: If statusCode is SUSPENDED, suspensionStartDate and suspensionEndDate must be set
    expression: "statusCode = SUSPENDED IMPLIES (suspensionStartDate IS NOT NULL AND suspensionEndDate IS NOT NULL)"
  
  - name: RehireEligibility
    type: business
    rule: Workers terminated for cause (fired) should have eligibleForRehire = false
  
  - name: SeveranceCalculation
    type: business
    rule: Severance allowance eligibility based on VN Labor Law Article 46 (>= 12 months service)
  
  - name: LaborContractLinkage
    type: business
    rule: ACTIVE WorkRelationship should have at least one ACTIVE LaborContract
    severity: WARNING
    message: "Gap between contracts detected. Ensure new contract is signed promptly."
  
  - name: PrimaryAssignmentRequired
    type: validation
    rule: ACTIVE WorkRelationship must have a primary assignment
    expression: "statusCode = ACTIVE IMPLIES hasPrimaryAssignment IS NOT NULL"
---

# Entity: WorkRelationship

## 1. Overview

The **WorkRelationship** entity represents the legal and contractual engagement between a Worker (Person) and a Legal Employer (Company). It is the foundational layer that tracks the duration, type, and status of employment or contingent work arrangements. A single Worker may have multiple WorkRelationships (concurrently for multi-job scenarios, or sequentially for re-hires).

```mermaid
mindmap
  root((WorkRelationship))
    Identity
      id
      relationshipNumber
      statusCode
    Worker & Employer
      workerId
      legalEmployerId
      relationshipTypeCode
      employmentIntent
      isPrimary
    Dates - Hire
      startDate
      originalHireDate
      seniorityDate
      seniorityAdjustmentDate
    Probation
      probationEndDate
      probationResult
      probationExtensionReason
    Labor Contract
      currentLaborContractId
      hasLaborContracts
    Suspension (VN)
      suspensionStartDate
      suspensionEndDate
      suspensionReason
    Termination
      terminationDate
      lastWorkingDate
      notificationDate
      resignationDate
      terminationReasonCode
      terminationInitiatedBy
      noticePeriod
    Re-hire
      eligibleForRehire
      regretTermination
    VN Compliance
      terminationDecisionNumber
      laborBookStatus
      socialInsuranceBookStatus
      socialInsuranceCloseDate
      severanceAllowanceStatus
      unemploymentInsuranceStatus
    Relationships
      belongsToWorker
      belongsToLegalEmployer
      hasLaborContracts
      hasAssignments
      hasPrimaryAssignment
      hasCompensationBases
      hasCurrentCompensationBasis
    Lifecycle
      PENDING
      ACTIVE
      SUSPENDED
      TERMINATED
```

**Key Characteristics**:
- **Person-Independent**: Separates employment relationship from person identity
- **Contract-Agnostic**: Can have multiple labor contracts (renewals) within same relationship
- **Re-hire Friendly**: Tracks original hire date for seniority calculation
- **VN Compliant**: Full support for VN Labor Law requirements (probation, suspension, severance)

**Design Pattern**: WorkRelationship is the anchor for:
- Labor Contracts (1:N) - Contract renewals don't break the relationship
- Assignments (1:N) - Multiple jobs/positions within same employment
- Time & Attendance - Relationship status determines eligibility

---

## 2. Attributes

### 2.1 Identity Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique internal identifier (UUID) |
| relationshipNumber | string | | Human-readable ID (WR-2026-001) |
| statusCode | enum | ✓ | PENDING, ACTIVE, SUSPENDED, TERMINATED |

### 2.2 Worker & Employer Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| workerId | string | ✓ | Reference to Worker entity |
| legalEmployerId | string | ✓ | Reference to Legal Entity |
| relationshipTypeCode | enum | ✓ | EMPLOYEE, CONTINGENT, CONTRACTOR, INTERN, NON_WORKER |
| employmentIntent | enum | | PERMANENT, FIXED_TERM, SEASONAL, PROJECT_BASED |
| isPrimary | boolean | ✓ | Primary employment? (for multi-job) |

### 2.3 Dates - Hire & Start

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| startDate | date | ✓ | Hire date (Ngày bắt đầu làm việc) |
| originalHireDate | date | | First hire date (for re-hires) |
| seniorityDate | date | | Date for seniority calculation |

### 2.4 Probation Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| probationEndDate | date | | Expected end of probation |
| probationResult | enum | | PASSED, FAILED, EXTENDED, IN_PROGRESS |
| probationExtensionReason | string | | Reason for extension |

### 2.5 Labor Contract Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| currentLaborContractId | string | | Currently active contract |

### 2.6 Suspension Attributes (VN Specific)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| suspensionStartDate | date | | Start of suspension (Hoãn HĐLĐ) |
| suspensionEndDate | date | | Expected end of suspension |
| suspensionReason | string | | Maternity, Military, Unpaid Leave |

### 2.7 Termination Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| terminationDate | date | | Official end date (Ngày chấm dứt) |
| lastWorkingDate | date | | Last day actually worked |
| notificationDate | date | | Date termination was notified |
| resignationDate | date | | Date employee resigned (if voluntary) |
| terminationReasonCode | string | | Reference code to TerminationReason |
| terminationInitiatedBy | enum | | EMPLOYEE, EMPLOYER, MUTUAL, AUTOMATIC |
| noticePeriod | number | | Required notice period (days) |

### 2.8 Re-hire Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| eligibleForRehire | boolean | | Can be re-hired? (false if fired) |
| regretTermination | boolean | | Regret losing this employee? |

### 2.9 VN Labor Law Compliance Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| terminationDecisionNumber | string | | Số quyết định thôi việc |
| terminationDecisionDate | date | | Ngày ký quyết định |
| laborBookStatus | enum | | Status of Sổ lao động return |
| socialInsuranceCloseDate | date | | Ngày chốt sổ BHXH |
| severanceAllowanceStatus | enum | | Trợ cấp thôi việc status |
| unemploymentInsuranceStatus | enum | | Sổ BHTN status |

### 2.10 Projected Dates

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| projectedTerminationDate | date | | Expected end (fixed-term contracts) |

### 2.11 Audit Attributes

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
    Worker ||--o{ WorkRelationship : hasWorkRelationships
    LegalEntity ||--o{ WorkRelationship : hasWorkRelationships
    WorkRelationship ||--o{ LaborContract : hasLaborContracts
    WorkRelationship ||--o{ Assignment : hasAssignments
    WorkRelationship }o--|| Assignment : hasPrimaryAssignment
    WorkRelationship }o--o| TerminationReason : hasTerminationReason
    WorkRelationship ||--o{ CompensationBasis : hasCompensationBases
    WorkRelationship }o--o| CompensationBasis : hasCurrentCompensationBasis
    
    WorkRelationship {
        string id PK
        string relationshipNumber UK
        string workerId FK
        string legalEmployerId FK
        enum statusCode
        date startDate
        date terminationDate
        enum relationshipTypeCode
        enum employmentIntent
        boolean isPrimary
    }
    
    Worker {
        string id PK
        string workerNumber UK
        json legalName
        string preferredName
    }
    
    LaborContract {
        string id PK
        string workRelationshipId FK
        date startDate
        date endDate
        enum contractType
    }
    
    Assignment {
        string id PK
        string workRelationshipId FK
        string positionId FK
        date startDate
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[Worker]] | belongsToWorker | N:1 | The person in this relationship |
| [[LegalEntity]] | belongsToLegalEmployer | N:1 | The contracting company |
| [[LaborContract]] | hasLaborContracts | 1:N | Associated labor contracts |
| [[Assignment]] | hasAssignments | 1:N | Job assignments in this relationship |
| [[Assignment]] | hasPrimaryAssignment | N:1 | Primary job assignment |
| [[TerminationReason]] | hasTerminationReason | N:1 | Reason for termination |
| [[CompensationBasis]] | hasCompensationBases | 1:N | Salary history records (SCD Type-2) |
| [[CompensationBasis]] | hasCurrentCompensationBasis | N:1 | Current effective salary basis |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> PENDING: Create Relationship
    
    PENDING --> ACTIVE: Activate (hire date reached)
    
    ACTIVE --> SUSPENDED: Suspend (maternity/military/unpaid)
    SUSPENDED --> ACTIVE: Resume (suspension ended)
    
    ACTIVE --> TERMINATED: Terminate
    SUSPENDED --> TERMINATED: Terminate during suspension
    PENDING --> TERMINATED: Cancel Hire
    
    TERMINATED --> [*]
    
    note right of PENDING
        Hire approved but not yet started
        (future hire date)
    end note
    
    note right of ACTIVE
        Currently employed
        Must have active labor contract
        Must have primary assignment
    end note
    
    note right of SUSPENDED
        Temporarily suspended
        (Hoãn thực hiện HĐLĐ)
        VN: Maternity, Military Service
    end note
    
    note right of TERMINATED
        Employment ended
        Terminal state
        Cannot be reactivated
        (Create new relationship for re-hire)
    end note
```

### State Descriptions

| State | Description | Allowed Operations |
|-------|-------------|-------------------|
| **PENDING** | Hire approved, waiting for start date | Can edit, can cancel |
| **ACTIVE** | Currently employed | All operations, can suspend/terminate |
| **SUSPENDED** | Temporarily suspended (VN: Hoãn HĐLĐ) | Can resume, can terminate |
| **TERMINATED** | Employment ended | Read-only, cannot reactivate |

### Transition Rules

| From | To | Trigger | Guard Condition |
|------|-----|---------|--------------------|
| PENDING | ACTIVE | activate | startDate reached AND probation started |
| ACTIVE | SUSPENDED | suspend | Valid suspension reason |
| SUSPENDED | ACTIVE | resume | Suspension period ended |
| ACTIVE | TERMINATED | terminate | terminationDate set AND reason provided |
| SUSPENDED | TERMINATED | terminate | Termination during suspension |
| PENDING | TERMINATED | cancelHire | Hire cancelled before start |

---

## 5. Business Rules Reference

### Validation Rules
- **UniqueActiveRelationship**: A Worker can have only ONE ACTIVE primary relationship per Legal Employer
- **StartDateBeforeEnd**: Start date must be before termination date
- **ProbationPeriodValidation**: Probation must be 6/30/60/180 days (VN Labor Law)
- **SuspensionDatesConsistency**: SUSPENDED status requires suspensionStartDate and suspensionEndDate
- **PrimaryAssignmentRequired**: ACTIVE relationship must have primary assignment

### Business Constraints
- **OriginalHireDateTracking**: For re-hires, originalHireDate = first hire date
- **SeniorityCalculation**: seniorityDate → originalHireDate → startDate (fallback chain)
- **NoticePeriodCompliance**: Notice period must comply with contract and VN Labor Law
- **TerminationDocumentation**: VN requires terminationDecisionNumber and terminationDecisionDate
- **RehireEligibility**: Fired workers should have eligibleForRehire = false
- **SeveranceCalculation**: Eligibility based on VN Labor Law Article 46 (>= 12 months)
- **LaborContractLinkage**: ACTIVE relationship must have ACTIVE LaborContract

### Vietnam-Specific Rules
- **Probation Periods**: 
  - 6 days: Simple jobs
  - 30 days: Technical jobs requiring vocational training
  - 60 days: Jobs requiring college degree
  - 180 days: Managerial positions
- **Suspension Reasons**: Maternity leave, Military service, Unpaid leave (Hoãn thực hiện HĐLĐ)
- **Termination Documentation**: Quyết định thôi việc (termination decision) is mandatory
- **Labor Book**: Sổ lao động must be returned to employee upon termination
- **Social Insurance**: BHXH must be closed (chốt sổ) upon termination
- **Severance**: Trợ cấp thôi việc = 0.5 month salary per year of service (if >= 12 months)

### Related Business Rules Documents
- See `[[work-relationship-management.brs.md]]` for complete business rules catalog
- See `[[vn-labor-law-compliance.brs.md]]` for Vietnam-specific requirements
- See `[[probation-management.brs.md]]` for probation period rules
- See `[[termination-process.brs.md]]` for termination workflow rules
- See `[[severance-calculation.brs.md]]` for severance allowance calculation

---

*Document Status: APPROVED - Based on Oracle HCM, SAP SuccessFactors, Workday standards*  
*VN Labor Law Compliance: Decree 145/2020/NĐ-CP, Labor Code 2019*
