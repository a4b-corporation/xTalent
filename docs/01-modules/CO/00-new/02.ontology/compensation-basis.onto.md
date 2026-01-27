---
entity: CompensationBasis
domain: core-hr
version: "1.0.0"
status: approved
owner: HR Domain Team
tags: [compensation, salary, payroll, bhxh, core]

attributes:
  # === IDENTITY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  # === CORE RELATIONSHIP ===
  - name: workRelationshipId
    type: string
    required: true
    description: Link to WorkRelationship - employment context. This is the primary link, NOT Employee.
  
  # === EFFECTIVE DATING (SCD Type-2) ===
  - name: effectiveStartDate
    type: date
    required: true
    description: When this basis becomes effective
  
  - name: effectiveEndDate
    type: date
    required: false
    description: When this basis ends (null = current/no end)
  
  - name: isCurrent
    type: boolean
    required: true
    description: Is this the current effective record for this WorkRelationship? (Performance flag)
    default: false
  
  # === SALARY BASIS ===
  - name: basisAmount
    type: decimal
    required: true
    description: |
      Mức lương hiệu lực (operational salary) dùng cho:
      - Payroll calculation
      - BHXH/BHYT/BHTN contribution basis
      - Analytics and reporting
    constraints:
      min: 0
  
  - name: currencyCode
    type: string
    required: true
    description: Currency code (ISO 4217)
    default: "VND"
    constraints:
      pattern: "^[A-Z]{3}$"
  
  - name: frequencyCode
    type: enum
    required: true
    description: Pay frequency - how often this amount is paid
    values: [ANNUALLY, MONTHLY, BI_WEEKLY, WEEKLY, DAILY, HOURLY]
    default: MONTHLY
    metadata:
      annualizationFactors:
        ANNUALLY: 1
        MONTHLY: 12
        BI_WEEKLY: 26
        WEEKLY: 52
        DAILY: 260
        HOURLY: 2080
  
  - name: annualizationFactor
    type: decimal
    required: false
    description: Factor to calculate annual equivalent. Default based on frequencyCode.
    constraints:
      min: 1
  
  - name: annualEquivalent
    type: decimal
    required: false
    description: Calculated annual salary = basisAmount × annualizationFactor
    constraints:
      min: 0
  
  # === CLASSIFICATION ===
  - name: basisTypeCode
    type: enum
    required: true
    description: Type of basis - distinguishes legal vs operational
    values: [LEGAL_BASE, OPERATIONAL_BASE, MARKET_ADJUSTED]
    default: OPERATIONAL_BASE
    metadata:
      values_detail:
        LEGAL_BASE: Copied from Contract.baseSalary for audit purposes
        OPERATIONAL_BASE: Current effective salary for payroll
        MARKET_ADJUSTED: After market analysis or equity correction
  
  - name: sourceCode
    type: enum
    required: true
    description: Source of this basis - how it was created
    values: [CONTRACT, MANUAL_ADJUST, FORMULA_RESULT, PROMOTION, COMP_CYCLE, MASS_UPLOAD]
    default: CONTRACT
  
  - name: reasonCode
    type: enum
    required: false
    description: Reason for this salary - why it was set/changed
    values: [HIRE, PROBATION_END, ANNUAL_REVIEW, PROMOTION, LATERAL_MOVE, MARKET_ADJUSTMENT, EQUITY_CORRECTION, COST_OF_LIVING, DEMOTION, CONTRACT_RENEWAL]
  
  # === ADJUSTMENT TRACKING ===
  - name: adjustmentAmount
    type: decimal
    required: false
    description: Delta from previous basis (basisAmount - previousBasis.basisAmount)
    constraints:
      min: -999999999
  
  - name: adjustmentPercentage
    type: decimal
    required: false
    description: Percentage change from previous basis
    constraints:
      min: -100
  
  - name: previousBasisId
    type: string
    required: false
    description: Link to previous CompensationBasis record (SCD chain)
  
  # === CONTRACT REFERENCE ===
  - name: contractId
    type: string
    required: false
    description: Source contract (required if basisTypeCode = LEGAL_BASE)
  
  # === SALARY BASIS CONFIG REFERENCE ===
  - name: salaryBasisId
    type: string
    required: false
    description: Link to SalaryBasis configuration (comp_core.salary_basis)
  
  # === APPROVAL WORKFLOW ===
  - name: approvalStatus
    type: enum
    required: false
    description: Approval status for salary changes
    values: [PENDING, APPROVED, REJECTED]
  
  - name: approvedBy
    type: string
    required: false
    description: Worker ID who approved this salary change
  
  - name: approvalDate
    type: datetime
    required: false
    description: When approval was granted
  
  # === REVIEW SCHEDULING ===
  - name: nextReviewDate
    type: date
    required: false
    description: Next scheduled salary review date
  
  # === VN SPECIFIC ===
  - name: socialInsuranceBasis
    type: decimal
    required: false
    description: SI contribution basis if different from basisAmount (VN BHXH)
    constraints:
      min: 0
  
  - name: regionalMinWageZone
    type: enum
    required: false
    description: Regional minimum wage zone for BHXH calculation (VN specific)
    values: [ZONE_I, ZONE_II, ZONE_III, ZONE_IV]
  
  # === NOTES ===
  - name: notes
    type: string
    required: false
    description: Comments or justification for this salary basis
    constraints:
      maxLength: 2000
  
  # === LIFECYCLE ===
  - name: statusCode
    type: enum
    required: true
    description: Current lifecycle status
    values: [DRAFT, PENDING_APPROVAL, ACTIVE, FUTURE, SUPERSEDED, CANCELLED]
    default: DRAFT
  
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
  - name: belongsToWorkRelationship
    target: WorkRelationship
    cardinality: many-to-one
    required: true
    inverse: hasCompensationBases
    description: The work relationship this basis belongs to. INVERSE - WorkRelationship.hasCompensationBases must reference this entity.
  
  - name: sourceContract
    target: Contract
    cardinality: many-to-one
    required: false
    inverse: generatesCompensationBases
    description: Source contract for LEGAL_BASE type. INVERSE - Contract.generatesCompensationBases.
  
  - name: previousBasis
    target: CompensationBasis
    cardinality: many-to-one
    required: false
    inverse: supersededBy
    description: Previous basis record in SCD chain (self-referential).
  
  - name: supersededBy
    target: CompensationBasis
    cardinality: one-to-many
    required: false
    inverse: previousBasis
    description: Basis records that superseded this one (SCD chain inverse).
  
  - name: approver
    target: Worker
    cardinality: many-to-one
    required: false
    inverse: approvedCompensationBases
    description: Worker who approved this salary change.
  
  - name: salaryBasisConfig
    target: SalaryBasis
    cardinality: many-to-one
    required: false
    inverse: usedByCompensationBases
    description: Salary basis configuration template (comp_core.salary_basis).
  
  - name: triggeredByAdjustment
    target: CompAdjustment
    cardinality: many-to-one
    required: false
    inverse: createsCompensationBasis
    description: Compensation adjustment that triggered this basis creation.

lifecycle:
  states: [DRAFT, PENDING_APPROVAL, ACTIVE, FUTURE, SUPERSEDED, CANCELLED]
  initial: DRAFT
  terminal: [SUPERSEDED, CANCELLED]
  transitions:
    - from: DRAFT
      to: PENDING_APPROVAL
      trigger: submit
      guard: All required fields populated
    - from: DRAFT
      to: CANCELLED
      trigger: cancel
      guard: User has cancel permission
    - from: PENDING_APPROVAL
      to: ACTIVE
      trigger: approve
      guard: Approver has authority AND effectiveStartDate <= today
    - from: PENDING_APPROVAL
      to: FUTURE
      trigger: approve
      guard: Approver has authority AND effectiveStartDate > today
    - from: PENDING_APPROVAL
      to: DRAFT
      trigger: reject
      guard: Approver provides rejection reason
    - from: PENDING_APPROVAL
      to: CANCELLED
      trigger: cancel
      guard: User has cancel permission
    - from: FUTURE
      to: ACTIVE
      trigger: effectiveDateReached
      guard: System auto-transition when effectiveStartDate <= today
    - from: FUTURE
      to: CANCELLED
      trigger: cancel
      guard: User has cancel permission before effective date
    - from: ACTIVE
      to: SUPERSEDED
      trigger: supersede
      guard: New basis becomes ACTIVE for same WorkRelationship

policies:
  - name: BasisAmountRequired
    type: validation
    rule: basisAmount must be a positive number
    expression: "basisAmount IS NOT NULL AND basisAmount >= 0"
    severity: ERROR
  
  - name: EffectiveDateRequired
    type: validation
    rule: effectiveStartDate is mandatory
    expression: "effectiveStartDate IS NOT NULL"
    severity: ERROR
  
  - name: WorkRelationshipRequired
    type: validation
    rule: Must link to a WorkRelationship
    expression: "workRelationshipId IS NOT NULL"
    severity: ERROR
  
  - name: LegalBaseMustHaveContract
    type: validation
    rule: LEGAL_BASE type must have contractId reference
    expression: "basisTypeCode != 'LEGAL_BASE' OR contractId IS NOT NULL"
    severity: ERROR
  
  - name: NoOverlappingPeriods
    type: validation
    rule: No two ACTIVE records with overlapping dates for same WorkRelationship
    expression: "NOT EXISTS(other WHERE other.workRelationshipId = this.workRelationshipId AND other.statusCode = 'ACTIVE' AND other.id != this.id AND dates_overlap(this, other))"
    severity: ERROR
  
  - name: BaseSalaryMinWage
    type: business
    rule: basisAmount must be >= Regional Minimum Wage for BHXH purposes (VN law)
    expression: "basisAmount >= REGIONAL_MIN_WAGE[regionalMinWageZone]"
    severity: WARNING
  
  - name: ApprovalRequired
    type: business
    rule: Salary changes above threshold require manager approval
    expression: "adjustmentPercentage <= APPROVAL_THRESHOLD OR approvalStatus = 'APPROVED'"
    severity: WARNING
  
  - name: PreviousBasisSuperseded
    type: business
    rule: When new basis becomes ACTIVE, previous ACTIVE must become SUPERSEDED
    trigger: "ON statusCode = 'ACTIVE'"
    expression: "UPDATE previous SET statusCode = 'SUPERSEDED' WHERE previousBasisId = previous.id"
    severity: INFO
  
  - name: ICurrentFlagSync
    type: business
    rule: Only one isCurrent = true per WorkRelationship
    trigger: "ON isCurrent = true"
    expression: "UPDATE others SET isCurrent = false WHERE workRelationshipId = this.workRelationshipId AND id != this.id"
    severity: INFO
  
  - name: AnnualEquivalentCalculation
    type: business
    rule: annualEquivalent = basisAmount × annualizationFactor
    trigger: "ON basisAmount OR annualizationFactor CHANGE"
    expression: "annualEquivalent = basisAmount * COALESCE(annualizationFactor, DEFAULT_FACTOR[frequencyCode])"
    severity: INFO
---

# Entity: CompensationBasis

## 1. Overview

The **CompensationBasis** (Mức Lương Hiệu Lực) entity represents the **operational salary** of an employee within a work relationship. It is the salary amount used for:

- **Payroll calculation** (base for pay processing)
- **BHXH/BHYT/BHTN** (social insurance contribution basis)
- **Analytics** (salary trends, compa-ratio, market positioning)

**Key Design Principle** (Golden Rule):
```
Contract         = Legal Minimum / Agreement (static, for audit)
CompensationBasis = Operational Effective Value (dynamic, for payroll)
TotalRewards      = Formula & Logic (configuration)

Ba lớp KHÔNG ĐƯỢC trùng vai.
```

```mermaid
mindmap
  root((CompensationBasis))
    Identity
      id
      workRelationshipId
    Effective Dating
      effectiveStartDate
      effectiveEndDate
      isCurrent
    Salary Basis
      basisAmount
      currencyCode
      frequencyCode
      annualizationFactor
      annualEquivalent
    Classification
      basisTypeCode
      sourceCode
      reasonCode
    Adjustment Tracking
      adjustmentAmount
      adjustmentPercentage
      previousBasisId
    References
      contractId
      salaryBasisId
    Approval Workflow
      approvalStatus
      approvedBy
      approvalDate
    VN Specific
      socialInsuranceBasis
      regionalMinWageZone
    Status
      statusCode
    Relationships
      belongsToWorkRelationship
      sourceContract
      previousBasis/supersededBy
      approver
      salaryBasisConfig
      triggeredByAdjustment
```

**Design Rationale**:
- **Link to WorkRelationship** (not Employee): Salary changes within same employment context
- **SCD Type-2**: Date-effective with previousBasisId chain for full history
- **Separation from Contract**: Contract = legal, CompensationBasis = operational
- **VN Compliance**: Supports BHXH minimum wage validation

---

## 2. Attributes

### 2.1 Identity

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique internal identifier (UUID) |
| workRelationshipId | string | ✓ | Link to WorkRelationship |

### 2.2 Effective Dating (SCD Type-2)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| effectiveStartDate | date | ✓ | When this basis becomes effective |
| effectiveEndDate | date | | When this basis ends (null = current) |
| isCurrent | boolean | ✓ | Is this the current effective record |

### 2.3 Salary Basis

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| basisAmount | decimal | ✓ | Operational salary amount |
| currencyCode | string | ✓ | Currency (ISO 4217, default: VND) |
| frequencyCode | enum | ✓ | MONTHLY/HOURLY/ANNUALLY/etc. |
| annualizationFactor | decimal | | Factor for annual calculation |
| annualEquivalent | decimal | | Calculated annual salary |

### 2.4 Classification

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| basisTypeCode | enum | ✓ | LEGAL_BASE / OPERATIONAL_BASE / MARKET_ADJUSTED |
| sourceCode | enum | ✓ | CONTRACT / MANUAL / FORMULA / PROMOTION |
| reasonCode | enum | | HIRE / PROBATION_END / ANNUAL_REVIEW / etc. |

**Basis Type Codes**:
| Code | VN Name | Description |
|------|---------|-------------|
| LEGAL_BASE | Mức lương pháp lý | Copied from Contract for audit |
| OPERATIONAL_BASE | Mức lương vận hành | Current effective for payroll |
| MARKET_ADJUSTED | Điều chỉnh thị trường | After market analysis |

**Reason Codes**:
| Code | VN Name | Description |
|------|---------|-------------|
| HIRE | Tuyển dụng | New hire salary |
| PROBATION_END | Hết thử việc | After probation completion |
| ANNUAL_REVIEW | Xét lương hàng năm | Annual merit increase |
| PROMOTION | Thăng chức | Promotion increase |
| MARKET_ADJUSTMENT | Điều chỉnh thị trường | Market rate adjustment |

### 2.5 Adjustment Tracking

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| adjustmentAmount | decimal | | Delta from previous basis |
| adjustmentPercentage | decimal | | % change from previous |
| previousBasisId | string | | Link to previous record (SCD chain) |

### 2.6 References

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| contractId | string | | Source contract (for LEGAL_BASE) |
| salaryBasisId | string | | Link to SalaryBasis config |

### 2.7 Approval Workflow

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| approvalStatus | enum | | PENDING / APPROVED / REJECTED |
| approvedBy | string | | Approver Worker ID |
| approvalDate | datetime | | Approval timestamp |
| nextReviewDate | date | | Next salary review |

### 2.8 VN Specific

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| socialInsuranceBasis | decimal | | SI basis if different from basisAmount |
| regionalMinWageZone | enum | | ZONE_I / II / III / IV |

### 2.9 Status

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| statusCode | enum | ✓ | DRAFT / PENDING_APPROVAL / ACTIVE / FUTURE / SUPERSEDED / CANCELLED |

### 2.10 Audit

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| createdAt | datetime | ✓ | Creation timestamp |
| updatedAt | datetime | ✓ | Last modification |
| createdBy | string | ✓ | Creator |
| updatedBy | string | ✓ | Last modifier |

---

## 3. Relationships

```mermaid
erDiagram
    CompensationBasis ||--o{ WorkRelationship : "belongsTo"
    CompensationBasis }o--|| Contract : "sourceContract"
    CompensationBasis }o--|| CompensationBasis : "previousBasis"
    CompensationBasis }o--|| Worker : "approver"
    CompensationBasis }o--|| SalaryBasis : "salaryBasisConfig"
    CompensationBasis }o--|| CompAdjustment : "triggeredBy"
    
    CompensationBasis {
        string id PK
        string workRelationshipId FK
        date effectiveStartDate
        date effectiveEndDate
        boolean isCurrent
        decimal basisAmount
        string currencyCode
        enum frequencyCode
        enum basisTypeCode
        enum sourceCode
        enum reasonCode
        string previousBasisId FK
        string contractId FK
        enum statusCode
    }
    
    WorkRelationship {
        string id PK
        string workerId FK
        string legalEntityCode FK
    }
    
    Contract {
        string id PK
        decimal baseSalary
    }
    
    Worker {
        string id PK
        string fullName
    }
```

### Related Entities

| Relationship | Target | Cardinality | Description |
|--------------|--------|-------------|-------------|
| belongsToWorkRelationship | [[WorkRelationship]] | N:1 | Core link - employment context |
| sourceContract | [[Contract]] | N:1 | For LEGAL_BASE tracing |
| previousBasis | [[CompensationBasis]] | N:1 | SCD chain (self-ref) |
| supersededBy | [[CompensationBasis]] | 1:N | SCD inverse |
| approver | [[Worker]] | N:1 | Approval workflow |
| salaryBasisConfig | [[SalaryBasis]] | N:1 | Configuration reference |
| triggeredByAdjustment | [[CompAdjustment]] | N:1 | Source from comp cycle |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> DRAFT: create
    DRAFT --> PENDING_APPROVAL: submit
    DRAFT --> CANCELLED: cancel
    PENDING_APPROVAL --> ACTIVE: approve (effectiveDate <= today)
    PENDING_APPROVAL --> FUTURE: approve (effectiveDate > today)
    PENDING_APPROVAL --> DRAFT: reject
    PENDING_APPROVAL --> CANCELLED: cancel
    FUTURE --> ACTIVE: effectiveDateReached (auto)
    FUTURE --> CANCELLED: cancel (before effective)
    ACTIVE --> SUPERSEDED: new basis activated
    SUPERSEDED --> [*]
    CANCELLED --> [*]
```

### State Descriptions

| State | Description |
|-------|-------------|
| DRAFT | Created, not yet submitted for approval |
| PENDING_APPROVAL | Submitted, awaiting manager approval |
| ACTIVE | Currently in effect, isCurrent = true |
| FUTURE | Approved but effective date is in future |
| SUPERSEDED | Replaced by newer record |
| CANCELLED | Voided before activation |

### Transitions

| From | To | Trigger | Guard |
|------|----|---------|----- |
| DRAFT | PENDING_APPROVAL | submit | All required fields populated |
| DRAFT | CANCELLED | cancel | User has permission |
| PENDING_APPROVAL | ACTIVE | approve | effectiveStartDate <= today |
| PENDING_APPROVAL | FUTURE | approve | effectiveStartDate > today |
| PENDING_APPROVAL | DRAFT | reject | Rejection reason provided |
| FUTURE | ACTIVE | effectiveDateReached | Auto-transition by system |
| ACTIVE | SUPERSEDED | supersede | New basis becomes ACTIVE |

---

## 5. Business Rules Reference

### Validation Rules

| Rule | Description | Severity |
|------|-------------|----------|
| BasisAmountRequired | basisAmount must be positive | ERROR |
| EffectiveDateRequired | effectiveStartDate is mandatory | ERROR |
| WorkRelationshipRequired | Must link to WorkRelationship | ERROR |
| LegalBaseMustHaveContract | LEGAL_BASE requires contractId | ERROR |
| NoOverlappingPeriods | No overlapping ACTIVE records | ERROR |

### Business Rules

| Rule | Description | Severity |
|------|-------------|----------|
| BaseSalaryMinWage | basisAmount ≥ Regional Min Wage (VN BHXH) | WARNING |
| ApprovalRequired | Large increases need approval | WARNING |
| PreviousBasisSuperseded | Auto-supersede previous on ACTIVE | INFO |
| ICurrentFlagSync | Only one isCurrent per WorkRelationship | INFO |
| AnnualEquivalentCalculation | Auto-calculate annual equivalent | INFO |

### Related Business Rules Documents
- See `[[compensation-management.brs.md]]` for complete business rules
- See `[[vn-bhxh-compliance.brs.md]]` for VN social insurance rules
- See `[[salary-change-workflow.flow.md]]` for approval process

---

## 6. Use Cases

### Use Case 1: Tuyển dụng mới (New Hire - LEGAL_BASE)

```yaml
CompensationBasis:
  id: "cb-001"
  workRelationshipId: "wr-001"
  contractId: "contract-001"
  basisTypeCode: LEGAL_BASE
  sourceCode: CONTRACT
  reasonCode: HIRE
  basisAmount: 15000000
  currencyCode: VND
  frequencyCode: MONTHLY
  annualizationFactor: 12
  annualEquivalent: 180000000
  effectiveStartDate: "2024-02-01"
  isCurrent: true
  statusCode: ACTIVE
  notes: "Initial salary from labor contract"
```

### Use Case 2: Hết thử việc (Probation End)

```yaml
CompensationBasis:
  id: "cb-002"
  workRelationshipId: "wr-001"
  previousBasisId: "cb-001"  # Link to hire basis
  basisTypeCode: OPERATIONAL_BASE
  sourceCode: MANUAL_ADJUST
  reasonCode: PROBATION_END
  basisAmount: 20000000  # Increased from 15M
  adjustmentAmount: 5000000
  adjustmentPercentage: 33.33
  currencyCode: VND
  frequencyCode: MONTHLY
  effectiveStartDate: "2024-04-01"
  approvalStatus: APPROVED
  approvedBy: "manager-001"
  approvalDate: "2024-03-25T10:00:00"
  isCurrent: true
  statusCode: ACTIVE
```

### Use Case 3: Xét lương hàng năm (Annual Review via Comp Cycle)

```yaml
CompensationBasis:
  id: "cb-003"
  workRelationshipId: "wr-001"
  previousBasisId: "cb-002"
  basisTypeCode: OPERATIONAL_BASE
  sourceCode: COMP_CYCLE
  reasonCode: ANNUAL_REVIEW
  basisAmount: 22000000  # 10% increase
  adjustmentAmount: 2000000
  adjustmentPercentage: 10.00
  currencyCode: VND
  frequencyCode: MONTHLY
  effectiveStartDate: "2025-01-01"
  nextReviewDate: "2026-01-01"
  approvalStatus: APPROVED
  isCurrent: true
  statusCode: ACTIVE
  notes: "Comp Review Cycle 2025, Performance Rating: Exceeds Expectations"
```

### Use Case 4: Thăng chức (Promotion)

```yaml
CompensationBasis:
  id: "cb-004"
  workRelationshipId: "wr-001"
  previousBasisId: "cb-003"
  basisTypeCode: OPERATIONAL_BASE
  sourceCode: PROMOTION
  reasonCode: PROMOTION
  basisAmount: 30000000  # Significant increase
  adjustmentAmount: 8000000
  adjustmentPercentage: 36.36
  currencyCode: VND
  frequencyCode: MONTHLY
  effectiveStartDate: "2025-07-01"
  approvalStatus: APPROVED
  isCurrent: true
  statusCode: ACTIVE
  notes: "Promoted to Senior Engineer"
```

---

## 7. Architecture Position

```
┌─────────────────────────────────────────────────────────────────┐
│  Contract (Legal Layer)                                         │
│  └── baseSalary (LEGAL, static, signed amount)                 │
│      │                                                         │
│      └── [CREATE] → CompensationBasis (basisTypeCode=LEGAL)    │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  WorkRelationship (Employment Context)                          │
│  └── CompensationBasis (OPERATIONAL, date-effective)           │
│      ├── basisAmount (current effective salary)                │
│      ├── frequencyCode (MONTHLY/HOURLY/...)                    │
│      ├── reasonCode (HIRE/PROBATION_END/ANNUAL_REVIEW)         │
│      └── sourceCode (CONTRACT/MANUAL/FORMULA/PROMOTION)        │
│          │                                                     │
│          ├── → Payroll Input                                   │
│          ├── → BHXH Calculation                                │
│          └── → Analytics                                       │
└─────────────────────────────────────────────────────────────────┘
                                ▲
                                │
┌─────────────────────────────────────────────────────────────────┐
│  TotalRewards (Formula Layer)                                   │
│  └── CompensationPlan + Eligibility Rule + Formula Engine      │
│      └── [OUTPUT] → CompensationBasis (sourceCode=FORMULA)     │
└─────────────────────────────────────────────────────────────────┘
```

---

*Document Status: APPROVED - Based on Oracle HCM, SAP SuccessFactors, Workday + VN Labor Law*  
*VN Compliance: Bộ Luật Lao Động 2019 (Điều 21, 96), Nghị định 141/2017/NĐ-CP (Regional Min Wage)*

