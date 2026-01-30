---
entity: Probation
domain: employment
version: "1.0.0"
status: deprecated
deprecatedSince: "2026-01-30"
deprecationReason: |
  DEPRECATED: Probation is a PHASE in Employee lifecycle, NOT a separate entity.
  
  Use instead:
  - Contract.probationStartDate, probationEndDate, probationDays (tracking dates)
  - Contract.probationSalaryPercentage (min 85% per VN law)
  - EmploymentRecord.record_type = PROBATION_START, PROBATION_PASS, PROBATION_FAIL (events)
  - Employee.status derivation (IN_PROBATION based on current date vs probation dates)
  
  If business needs separate probation contract:
  - Use Contract.contractTypeCode = PROBATION_CONTRACT
  
  Evaluation workflow:
  - Use Performance Management module for probation evaluations
  
  VN Compliance (Điều 25-27):
  - Max duration rules → Contract.probationDays validation
  - 85% salary rule → Contract.probationSalaryPercentage validation
  - 3-day notice → Contract termination notice validation
owner: Employment Domain Team
tags: [probation, trial-period, vn-labor-code, compliance, onboarding, deprecated]

attributes:
  # === IDENTITY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  - name: probationCode
    type: string
    required: true
    unique: true
    description: Business probation identifier (Mã thử việc)
    constraints:
      maxLength: 50
      pattern: "^PROB-[0-9]{4}-[0-9]{6}$"
  
  # === RELATIONSHIPS ===
  - name: employeeId
    type: string
    required: true
    description: Reference to Employee on probation
  
  - name: contractId
    type: string
    required: true
    description: Reference to Contract (trial contract or main contract with probation clause)
  
  - name: assignmentId
    type: string
    required: true
    description: Reference to Assignment (organizational placement during probation)
  
  # === JOB CLASSIFICATION (VN Labor Code 2019 Điều 25) ===
  - name: jobCategoryCode
    type: enum
    required: true
    description: |
      Job category determines max probation duration (VN Labor Code 2019 Điều 25):
      - EXECUTIVE: Max 180 days (Quản lý DN theo Luật Doanh nghiệp)
      - SENIOR_SPECIALIST: Max 60 days (Cao đẳng trở lên, chuyên môn-kỹ thuật cao)
      - SKILLED: Max 30 days (Trung cấp chuyên nghiệp, nghề)
      - SEMI_SKILLED: Max 6 days (Công việc khác)
    values: [EXECUTIVE, SENIOR_SPECIALIST, SKILLED, SEMI_SKILLED]
  
  # === DATES ===
  - name: startDate
    type: date
    required: true
    description: Probation start date (Ngày bắt đầu thử việc)
  
  - name: expectedEndDate
    type: date
    required: true
    description: Expected probation end date (Ngày dự kiến kết thúc thử việc, calculated from duration)
  
  - name: actualEndDate
    type: date
    required: false
    description: Actual end date (if different from expected - early termination or extension)
  
  - name: durationDays
    type: integer
    required: true
    description: Probation duration in days (VN law max by job category)
    constraints:
      min: 1
      max: 180
  
  # === COMPENSATION (VN Labor Code 2019 Điều 26) ===
  - name: probationSalary
    type: decimal
    required: true
    description: Probation salary amount (≥ 85% of position grade salary per VN law)
    constraints:
      min: 0
  
  - name: salaryCurrencyCode
    type: string
    required: true
    description: Currency code (ISO 4217)
    default: "VND"
    constraints:
      pattern: "^[A-Z]{3}$"
  
  - name: salaryPercentage
    type: decimal
    required: true
    description: Percentage of formal salary (VN law minimum 85%)
    default: 85
    constraints:
      min: 85
      max: 100
  
  - name: formalSalary
    type: decimal
    required: true
    description: Reference formal salary after probation (for percentage calculation)
    constraints:
      min: 0
  
  # === EVALUATION ===
  - name: evaluationDate
    type: date
    required: false
    description: Date of final probation evaluation (before expectedEndDate)
  
  - name: evaluatedById
    type: string
    required: false
    description: Reference to Employee (manager/supervisor) who evaluated
  
  - name: evaluationScore
    type: decimal
    required: false
    description: Numerical evaluation score (if applicable)
    constraints:
      min: 0
      max: 100
  
  - name: evaluationResultCode
    type: enum
    required: false
    description: Probation evaluation result
    values: [EXCELLENT, GOOD, SATISFACTORY, NEEDS_IMPROVEMENT, UNSATISFACTORY]
  
  - name: evaluationNotes
    type: string
    required: false
    description: Evaluation comments and observations
    constraints:
      maxLength: 2000
  
  # === OUTCOME ===
  - name: outcomeCode
    type: enum
    required: false
    description: Final probation outcome (determines next action)
    values: [PASSED, FAILED, EXTENDED, EARLY_TERMINATED, RESIGNED]
  
  - name: outcomeDate
    type: date
    required: false
    description: Date outcome was determined
  
  - name: outcomeReasonCode
    type: string
    required: false
    description: Reference to CODELIST_PROBATION_OUTCOME_REASON for detailed reason
  
  - name: outcomeNotes
    type: string
    required: false
    description: Notes about the outcome decision
    constraints:
      maxLength: 1000
  
  # === EXTENSION (if applicable) ===
  - name: extensionCount
    type: integer
    required: true
    default: 0
    description: Number of times probation has been extended (should be 0 normally)
    constraints:
      min: 0
      max: 1
  
  - name: extensionDays
    type: integer
    required: false
    description: Additional days if extended (should not exceed job category max)
    constraints:
      min: 1
  
  - name: extensionReasonCode
    type: string
    required: false
    description: Reason for extension (if applicable)
  
  # === FORMAL CONTRACT ===
  - name: formalContractId
    type: string
    required: false
    description: Reference to formal Contract created after successful probation
  
  # === STATUS ===
  - name: statusCode
    type: enum
    required: true
    description: Current probation status
    values: [PENDING, IN_PROGRESS, EVALUATION_PENDING, COMPLETED, CANCELLED]
    default: PENDING
  
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
  - name: forEmployee
    target: Employee
    cardinality: many-to-one
    required: true
    inverse: hasProbations
    description: Employee undergoing probation. INVERSE - Employee.hasProbations must reference this Probation.
  
  - name: underContract
    target: Contract
    cardinality: many-to-one
    required: true
    inverse: hasProbation
    description: Trial contract or main contract with probation clause. INVERSE - Contract.hasProbation.
  
  - name: duringAssignment
    target: Assignment
    cardinality: many-to-one
    required: true
    inverse: hasProbation
    description: Work assignment during probation. INVERSE - Assignment.hasProbation.
  
  - name: evaluatedBy
    target: Employee
    cardinality: many-to-one
    required: false
    inverse: evaluatedProbations
    description: Manager/supervisor who evaluated. INVERSE - Employee.evaluatedProbations.
  
  - name: createdFormalContract
    target: Contract
    cardinality: one-to-one
    required: false
    inverse: fromProbation
    description: Formal contract created after passing probation. INVERSE - Contract.fromProbation.
  
  - name: hasEvaluations
    target: ProbationEvaluation
    cardinality: one-to-many
    required: false
    inverse: forProbation
    description: Mid-term and final evaluations. INVERSE - ProbationEvaluation.forProbation.
  
  - name: hasDocuments
    target: Document
    cardinality: one-to-many
    required: false
    inverse: attachedToProbation
    description: Supporting documents (evaluation forms, notices). INVERSE - Document.attachedToProbation.

lifecycle:
  states: [PENDING, IN_PROGRESS, EVALUATION_PENDING, COMPLETED, CANCELLED]
  initial: PENDING
  terminal: [COMPLETED, CANCELLED]
  transitions:
    - from: PENDING
      to: IN_PROGRESS
      trigger: start_probation
      guard: startDate reached, contract active
    - from: IN_PROGRESS
      to: EVALUATION_PENDING
      trigger: request_evaluation
      guard: Near expectedEndDate (within 7 days)
    - from: EVALUATION_PENDING
      to: COMPLETED
      trigger: complete_evaluation
      guard: Outcome determined (PASSED, FAILED, etc.)
    - from: IN_PROGRESS
      to: COMPLETED
      trigger: early_terminate
      guard: Early termination (RESIGNED, EARLY_TERMINATED)
    - from: [PENDING, IN_PROGRESS]
      to: CANCELLED
      trigger: cancel
      guard: Cancelled before completion (contract cancelled, etc.)

policies:
  # === DURATION VALIDATION ===
  - name: MaxDurationByJobCategory
    type: validation
    rule: Duration must not exceed job category maximum per VN Labor Code Điều 25
    expression: |
      (jobCategoryCode = 'EXECUTIVE' AND durationDays <= 180) OR
      (jobCategoryCode = 'SENIOR_SPECIALIST' AND durationDays <= 60) OR
      (jobCategoryCode = 'SKILLED' AND durationDays <= 30) OR
      (jobCategoryCode = 'SEMI_SKILLED' AND durationDays <= 6)
    severity: ERROR
  
  - name: MinSalaryPercentage
    type: business
    rule: VN Labor Code Điều 26 - Probation salary must be ≥ 85% of position salary
    expression: "salaryPercentage >= 85"
    severity: ERROR
  
  - name: SalaryCalculationConsistency
    type: validation
    rule: probationSalary must equal formalSalary × (salaryPercentage / 100)
    expression: "ABS(probationSalary - (formalSalary * salaryPercentage / 100)) < 1"
    severity: WARNING
  
  # === DATE VALIDATION ===
  - name: ExpectedEndDateCalculation
    type: validation
    rule: expectedEndDate must equal startDate + durationDays
    expression: "expectedEndDate = DATE_ADD(startDate, durationDays)"
    severity: WARNING
  
  - name: EvaluationBeforeEnd
    type: business
    rule: Evaluation should be completed before expectedEndDate
    expression: "evaluationDate IS NULL OR evaluationDate <= expectedEndDate"
    severity: WARNING
  
  # === OUTCOME VALIDATION ===
  - name: OutcomeRequiredForCompleted
    type: validation
    rule: COMPLETED status requires outcomeCode
    expression: "statusCode != 'COMPLETED' OR outcomeCode IS NOT NULL"
    severity: ERROR
  
  - name: FormalContractOnPass
    type: business
    rule: If outcomeCode = PASSED, formalContractId should be set
    expression: "outcomeCode != 'PASSED' OR formalContractId IS NOT NULL"
    severity: WARNING
  
  # === VN SPECIFIC ===
  - name: EarlyTerminationNotice
    type: business
    rule: VN Labor Code - Early termination requires 3-day advance notice
    expression: "Early termination must have 3-day notice"
    severity: INFO
  
  - name: NoExtensionNormally
    type: business
    rule: Probation should not be extended under normal circumstances (VN law)
    expression: "extensionCount = 0"
    severity: WARNING
  
  - name: ProbationOncePerRole
    type: business
    rule: Employee should have only one probation per job/position (VN law)
    expression: "COUNT(Probation WHERE employeeId = X AND assignmentId.positionId = Y AND statusCode = 'COMPLETED') <= 1"
    severity: WARNING
---

# Entity: Probation

## 1. Overview

**Probation** (Thử việc) entity quản lý thời gian thử việc của nhân viên theo quy định Bộ Luật Lao động Việt Nam 2019. Đây là entity quan trọng để đảm bảo tuân thủ pháp luật về:
- **Thời hạn thử việc** tối đa theo từng loại công việc (Điều 25)
- **Mức lương thử việc** tối thiểu 85% (Điều 26)
- **Quy trình đánh giá** và chuyển đổi sang hợp đồng chính thức

**Key Concept**:
```
Probation = Trial period with evaluation workflow
Contract = Legal agreement (may contain probation clause)
Probation ≠ Contract (separate entity for lifecycle tracking)
```

```mermaid
mindmap
  root((Probation))
    Identity
      id
      probationCode
    Relationships
      employeeId
      contractId
      assignmentId
    Job Classification
      jobCategoryCode
        EXECUTIVE «max 180d»
        SENIOR_SPECIALIST «max 60d»
        SKILLED «max 30d»
        SEMI_SKILLED «max 6d»
    Dates
      startDate
      expectedEndDate
      actualEndDate
      durationDays
    Compensation
      probationSalary
      salaryCurrencyCode
      salaryPercentage «min 85%»
      formalSalary
    Evaluation
      evaluationDate
      evaluatedById
      evaluationScore
      evaluationResultCode
      evaluationNotes
    Outcome
      outcomeCode
        PASSED
        FAILED
        EXTENDED
        EARLY_TERMINATED
        RESIGNED
      outcomeDate
      outcomeReasonCode
      outcomeNotes
    Extension
      extensionCount
      extensionDays
      extensionReasonCode
    Formal Contract
      formalContractId
    Status
      statusCode
    Lifecycle
      PENDING
      IN_PROGRESS
      EVALUATION_PENDING
      COMPLETED
      CANCELLED
```

**Design Rationale**:
- **Separate from Contract**: Probation is a lifecycle entity, not just a contract attribute
- **VN Compliance**: Full support for Labor Code 2019 Điều 25-27
- **Evaluation Workflow**: Support multi-step evaluation process
- **Audit Trail**: Complete tracking of probation decisions

---

## 2. Attributes

### 2.1 Identity Attributes

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|-----------|
| id | string | ✓ | Unique internal identifier (UUID) | employment.probation.id |
| probationCode | string | ✓ | Business identifier (PROB-YYYY-NNNNNN) | employment.probation.code |

### 2.2 Relationship References

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|-----------|
| employeeId | string | ✓ | Employee on probation | employment.probation.employee_id → employment.employee.id |
| contractId | string | ✓ | Trial/main contract | employment.probation.contract_id → employment.contract.id |
| assignmentId | string | ✓ | Work assignment | employment.probation.assignment_id → employment.assignment.id |

### 2.3 Job Classification (VN Labor Code Điều 25)

| Attribute | Type | Required | Description | Max Days |
|-----------|------|----------|-------------|----------|
| jobCategoryCode | enum | ✓ | Job category for max duration | - |

**Job Category Reference**:

| Code | Vietnamese | Description | Max Duration |
|------|------------|-------------|--------------|
| EXECUTIVE | Quản lý DN | Managers per Enterprise Law | 180 days |
| SENIOR_SPECIALIST | Chuyên môn cao | College+, technical/professional | 60 days |
| SKILLED | Được đào tạo | Intermediate vocational | 30 days |
| SEMI_SKILLED | Công việc khác | Other work | 6 days |

### 2.4 Dates

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| startDate | date | ✓ | Probation start date |
| expectedEndDate | date | ✓ | Calculated end date (startDate + durationDays) |
| actualEndDate | date | | Actual end (if different) |
| durationDays | integer | ✓ | Duration in days (max by jobCategoryCode) |

### 2.5 Compensation (VN Labor Code Điều 26)

| Attribute | Type | Required | Description | VN Law |
|-----------|------|----------|-------------|--------|
| probationSalary | decimal | ✓ | Probation salary amount | ≥ 85% of formal |
| salaryCurrencyCode | string | ✓ | Currency (default VND) | |
| salaryPercentage | decimal | ✓ | % of formal salary | Min 85% |
| formalSalary | decimal | ✓ | Reference formal salary | |

### 2.6 Evaluation

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| evaluationDate | date | | Final evaluation date |
| evaluatedById | string | | Evaluator (manager) |
| evaluationScore | decimal | | Numeric score (0-100) |
| evaluationResultCode | enum | | EXCELLENT, GOOD, SATISFACTORY, NEEDS_IMPROVEMENT, UNSATISFACTORY |
| evaluationNotes | string | | Evaluation comments |

### 2.7 Outcome

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| outcomeCode | enum | | PASSED, FAILED, EXTENDED, EARLY_TERMINATED, RESIGNED |
| outcomeDate | date | | Outcome determination date |
| outcomeReasonCode | string | | Detailed reason code |
| outcomeNotes | string | | Outcome decision notes |

### 2.8 Extension

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| extensionCount | integer | ✓ | Number of extensions (default 0) |
| extensionDays | integer | | Additional days if extended |
| extensionReasonCode | string | | Reason for extension |

### 2.9 Formal Contract

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| formalContractId | string | | Formal contract created on PASSED |

### 2.10 Status & Audit

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| statusCode | enum | ✓ | PENDING, IN_PROGRESS, EVALUATION_PENDING, COMPLETED, CANCELLED |
| createdAt | datetime | ✓ | Record creation timestamp |
| updatedAt | datetime | ✓ | Last modification timestamp |
| createdBy | string | ✓ | Creator user ID |
| updatedBy | string | ✓ | Last modifier user ID |

---

## 3. Relationships

```mermaid
erDiagram
    Employee ||--o{ Probation : hasProbations
    Contract ||--o| Probation : hasProbation
    Assignment ||--o| Probation : hasProbation
    Employee ||--o{ Probation : evaluatedProbations
    Probation ||--o| Contract : createdFormalContract
    Probation ||--o{ ProbationEvaluation : hasEvaluations
    Probation ||--o{ Document : hasDocuments
    
    Probation {
        string id PK
        string probationCode UK
        string employeeId FK
        string contractId FK
        string assignmentId FK
        enum jobCategoryCode
        date startDate
        date expectedEndDate
        integer durationDays
        decimal probationSalary
        decimal salaryPercentage
        enum outcomeCode
        enum statusCode
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[Employee]] | forEmployee | N:1 | Employee on probation |
| [[Contract]] | underContract | N:1 | Trial or main contract |
| [[Assignment]] | duringAssignment | N:1 | Work assignment |
| [[Employee]] | evaluatedBy | N:1 | Evaluator (manager) |
| [[Contract]] | createdFormalContract | 1:1 | Formal contract on pass |
| [[ProbationEvaluation]] | hasEvaluations | 1:N | Mid-term/final evaluations |
| [[Document]] | hasDocuments | 1:N | Supporting documents |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> PENDING: Create Probation
    
    PENDING --> IN_PROGRESS: start_probation (startDate reached)
    IN_PROGRESS --> EVALUATION_PENDING: request_evaluation (near end)
    EVALUATION_PENDING --> COMPLETED: complete_evaluation
    
    IN_PROGRESS --> COMPLETED: early_terminate (resignation/failure)
    
    PENDING --> CANCELLED: cancel (contract cancelled)
    IN_PROGRESS --> CANCELLED: cancel (contract cancelled)
    
    COMPLETED --> [*]
    CANCELLED --> [*]
    
    note right of COMPLETED
        Outcomes:
        - PASSED → create formal contract
        - FAILED → terminate employment
        - RESIGNED → employee resigned
        - EARLY_TERMINATED → other early end
    end note
```

| State | Business Meaning | System Impact |
|-------|------------------|---------------|
| **PENDING** | Probation created, not yet started | No salary processing |
| **IN_PROGRESS** | Probation active, under evaluation | Probation salary payable |
| **EVALUATION_PENDING** | Near end, awaiting final evaluation | Reminder notifications |
| **COMPLETED** | Probation ended (any outcome) | Outcome-based actions |
| **CANCELLED** | Cancelled before completion | No further action |

---

## 5. Business Rules Reference

### VN Labor Code 2019 Compliance

| Rule | Reference | Description |
|------|-----------|-------------|
| Max duration | Điều 25 | 180/60/30/6 days by job type |
| Min salary | Điều 26 | ≥ 85% of position salary |
| Notice period | Điều 27 | 3 days for early termination |
| Single probation | Điều 25 | Only one probation per job |

### Related Business Rules

- [[Probation.brs.md]] - Probation duration and salary rules
- [[Contract.brs.md]] - Contract creation after probation pass
- [[Termination.brs.md]] - Termination on probation failure

---

## 6. Process Flows

> **Note**: Detailed flows are in `*.flow.md` files.

| Flow | Description |
|------|-------------|
| [[probation-start.flow.md]] | Start probation workflow |
| [[probation-evaluation.flow.md]] | Evaluation process flow |
| [[probation-completion.flow.md]] | Completion and outcome handling |

---

## 7. Vietnam Regulatory Notes

### Điều 25 - Thời gian thử việc

> Thời gian thử việc căn cứ vào tính chất và mức độ phức tạp của công việc nhưng chỉ được thử việc một lần đối với một công việc và bảo đảm điều kiện sau đây:
> - Không quá 180 ngày đối với công việc của người quản lý doanh nghiệp theo quy định của Luật Doanh nghiệp
> - Không quá 60 ngày đối với công việc có chức danh nghề nghiệp cần trình độ chuyên môn, kỹ thuật từ cao đẳng trở lên
> - Không quá 30 ngày đối với công việc có chức danh nghề nghiệp cần trình độ chuyên môn, kỹ thuật trung cấp nghề, trung cấp chuyên nghiệp, công nhân kỹ thuật, nhân viên nghiệp vụ
> - Không quá 6 ngày đối với công việc khác

### Điều 26 - Tiền lương thử việc

> Tiền lương của người lao động trong thời gian thử việc do hai bên thỏa thuận nhưng ít nhất phải bằng 85% mức lương của công việc đó.

### Điều 27 - Kết thúc thời gian thử việc

> - Khi việc làm thử đạt yêu cầu thì người sử dụng lao động phải giao kết hợp đồng lao động với người lao động.
> - Trong thời gian thử việc, mỗi bên có quyền hủy bỏ hợp đồng thử việc hoặc hợp đồng lao động đã giao kết mà không cần báo trước và không phải bồi thường.
