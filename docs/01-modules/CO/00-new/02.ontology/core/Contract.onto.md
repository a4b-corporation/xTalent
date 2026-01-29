---
entity: Contract
domain: employment
version: "1.0.0"
status: approved
owner: Employment Domain Team
tags: [contract, labor-contract, vn-labor-code, compliance]

attributes:
  # === IDENTITY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  - name: contractNumber
    type: string
    required: true
    unique: true
    description: Business contract number (Số hợp đồng - unique, required by VN law)
    constraints:
      maxLength: 50
  
  # === PARTIES ===
  - name: employeeId
    type: string
    required: true
    description: Reference to Employee (the contracted employee)
  
  - name: legalEntityCode
    type: string
    required: true
    description: Reference to Legal Entity (the employer)
  
  - name: legalRepresentativeId
    type: string
    required: false
    description: Reference to Legal Representative who signed on behalf of employer
  
  # === CONTRACT TYPE ===
  - name: contractTypeCode
    type: enum
    required: true
    description: Type of labor contract (VN Labor Code 2019 types)
    values: [INDEFINITE, DEFINITE, SEASONAL, TRIAL]
  
  # === DATES ===
  - name: signDate
    type: date
    required: true
    description: Date contract was signed (Ngày ký - required by VN law)
  
  - name: startDate
    type: date
    required: true
    description: Contract effective start date (Ngày hiệu lực)
  
  - name: endDate
    type: date
    required: false
    description: Contract end date (Ngày kết thúc - required for DEFINITE/SEASONAL, null for INDEFINITE)
  
  - name: duration
    type: integer
    required: false
    description: Contract duration (number of units)
    constraints:
      min: 1
  
  - name: durationUnitCode
    type: enum
    required: false
    description: Duration unit (DAYS, MONTHS, YEARS)
    values: [DAYS, MONTHS, YEARS]
  
  # === PROBATION ===
  - name: probationStartDate
    type: date
    required: false
    description: Probation period start date
  
  - name: probationEndDate
    type: date
    required: false
    description: Probation period end date (Ngày kết thúc thử việc)
  
  - name: probationDays
    type: integer
    required: false
    description: Probation length in days (max 180 for managers, 60 for specialists, 30 for skilled, 6 for general)
    constraints:
      min: 1
      max: 180
  
  # === NOTICE PERIOD ===
  - name: noticePeriod
    type: integer
    required: false
    description: Notice period length (employee notice)
    constraints:
      min: 1
  
  - name: noticePeriodUnitCode
    type: enum
    required: false
    description: Notice period unit
    values: [DAYS, WEEKS, MONTHS]
  
  - name: employerNoticePeriod
    type: integer
    required: false
    description: Employer notice period (if different from employee)
    constraints:
      min: 1
  
  # === COMPENSATION METHOD (VN Labor Code 2019 Điều 96) ===
  - name: payMethodCode
    type: enum
    required: true
    description: Hình thức trả lương (VN Labor Code 2019 Điều 96)
    values: [TIME_BASED, PRODUCT_BASED, TASK_BASED, HYBRID]
    default: TIME_BASED
    # TIME_BASED = Trả theo thời gian (Tháng/Ngày/Giờ)
    # PRODUCT_BASED = Trả 100% theo đơn giá sản phẩm
    # TASK_BASED = Trả theo khoán việc (Lump sum)
    # HYBRID = Lương cứng + Lương sản phẩm/hoa hồng
  
  - name: baseSalary
    type: decimal
    required: true
    description: |
      Mức lương làm căn cứ pháp lý và đóng BHXH:
      - TIME_BASED: Lương Gross/kỳ
      - PRODUCT_BASED: Mức sàn BHXH (≥ lương tối thiểu vùng)
      - TASK_BASED: Tổng giá trị khoán
      - HYBRID: Phần lương cứng (Fixed Base)
    constraints:
      min: 0
  
  - name: baseSalaryCurrencyCode
    type: string
    required: true
    description: Currency code (ISO 4217)
    default: "VND"
    constraints:
      pattern: "^[A-Z]{3}$"
  
  - name: salaryPayFrequencyCode
    type: enum
    required: true
    description: Tần suất trả lương (Kỳ lương)
    values: [MONTHLY, BI_WEEKLY, WEEKLY, DAILY, HOURLY]
    default: MONTHLY
  
  # === PIECE RATE (for PRODUCT_BASED/HYBRID) ===
  - name: pieceRateAmount
    type: decimal
    required: false
    description: "Đơn giá sản phẩm cố định trong HĐ (VD: 5000 VND/sản phẩm)"
    constraints:
      min: 0
  
  - name: pieceRateUnitCode
    type: string
    required: false
    description: Đơn vị tính lương sản phẩm (Cái, Kg, Mét, Giờ công, Hợp đồng)
    constraints:
      maxLength: 50
  
  - name: pieceRateReference
    type: string
    required: false
    description: "Dẫn chiếu đến bảng đơn giá nếu không fix cứng giá (VD: Theo Quyết định số 05/2024/QĐ-CTY)"
    constraints:
      maxLength: 255
  
  # === WORK DETAILS (VN Labor Law Requirements) ===
  - name: workContent
    type: string
    required: false
    description: Work content/job description (Nội dung công việc - required by VN law)
    constraints:
      maxLength: 2000
  
  - name: workLocationId
    type: string
    required: false
    description: Primary work location (Địa điểm làm việc - required by VN law)
  
  - name: positionId
    type: string
    required: false
    description: Reference to Position (contracted position)
  
  # === RENEWAL TRACKING ===
  - name: renewalCount
    type: integer
    required: true
    default: 0
    description: Number of times contract has been renewed (VN law - after 2nd renewal → indefinite)
    constraints:
      min: 0
  
  - name: previousContractId
    type: string
    required: false
    description: Reference to previous contract (renewal chain)
  
  # === SENIORITY ===
  - name: seniorityDate
    type: date
    required: false
    description: Date for seniority calculation (Ngày tính thâm niên)
  
  # === TERMINATION ===
  - name: terminationDate
    type: date
    required: false
    description: Actual last working day (if terminated early)
  
  - name: terminationReasonCode
    type: string
    required: false
    description: Reason for termination (reference to CODELIST_TERMINATION_REASON)
  
  - name: okToRehire
    type: boolean
    required: false
    description: Is employee eligible for rehire?
  
  # === DOCUMENT REFERENCES ===
  - name: templateId
    type: string
    required: false
    description: Reference to ContractTemplate used to generate this contract
  
  - name: documentUrl
    type: string
    required: false
    description: URL to signed contract document (PDF)
    constraints:
      maxLength: 500
  
  - name: signatureDate
    type: date
    required: false
    description: Employee signature date
  
  # === VN SPECIFIC ===
  - name: laborBookNumber
    type: string
    required: false
    description: Labor book number (Số sổ lao động - VN specific)
    constraints:
      maxLength: 50
  
  - name: socialInsuranceStartDate
    type: date
    required: false
    description: Social insurance participation start date (Ngày tham gia BHXH)
  
  - name: unionContribution
    type: boolean
    required: false
    description: Contributes to union fees? (Đóng phí công đoàn)
  
  # === STATUS ===
  - name: statusCode
    type: enum
    required: true
    description: Current contract status. Aligned with xTalent naming convention.
    values: [DRAFT, PENDING_SIGNATURE, ACTIVE, EXPIRED, TERMINATED, RENEWED, CANCELLED]
    default: DRAFT
  
  # === METADATA ===
  - name: metadata
    type: json
    required: false
    description: Additional flexible data (equipment provided, collective agreement ref, etc.)
  
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
  - name: contractsEmployee
    target: Employee
    cardinality: many-to-one
    required: true
    inverse: hasContracts
    description: The contracted employee. INVERSE - Employee.hasContracts must reference this Contract.
  
  - name: employedByLegalEntity
    target: LegalEntity
    cardinality: many-to-one
    required: true
    inverse: employsViaContracts
    description: Legal entity (employer). INVERSE - LegalEntity.employsViaContracts must reference this Contract.
  
  - name: signedByRepresentative
    target: LegalRepresentative
    cardinality: many-to-one
    required: false
    inverse: signedContracts
    description: Legal representative who signed. INVERSE - LegalRepresentative.signedContracts must reference this Contract.
  
  - name: basedAtLocation
    target: Location
    cardinality: many-to-one
    required: false
    inverse: hostsContracts
    description: Primary work location. INVERSE - Location.hostsContracts must reference this Contract.
  
  - name: forPosition
    target: Position
    cardinality: many-to-one
    required: false
    inverse: hasContracts
    description: Contracted position. INVERSE - Position.hasContracts must reference this Contract.
  
  - name: renewsFromPreviousContract
    target: Contract
    cardinality: many-to-one
    required: false
    inverse: renewedByNextContract
    description: Previous contract in renewal chain (self-referential). INVERSE - Contract.renewedByNextContract must reference this Contract.
  
  - name: renewedByNextContract
    target: Contract
    cardinality: one-to-one
    required: false
    inverse: renewsFromPreviousContract
    description: Next contract (if renewed) - self-referential. INVERSE - Contract.renewsFromPreviousContract must reference this Contract.
  
  - name: generatedFromTemplate
    target: ContractTemplate
    cardinality: many-to-one
    required: false
    inverse: usedInContracts
    description: Template used to generate contract. INVERSE - ContractTemplate.usedInContracts must reference this Contract.
  
  - name: hasAmendments
    target: ContractAmendment
    cardinality: one-to-many
    required: false
    inverse: amendsContract
    description: Contract amendments. INVERSE - ContractAmendment.amendsContract must reference this Contract.
  
  - name: hasDocuments
    target: Document
    cardinality: one-to-many
    required: false
    inverse: attachedToContract
    description: Attached documents. INVERSE - Document.attachedToContract must reference this Contract.
  
  - name: linkedToAssignment
    target: Assignment
    cardinality: one-to-one
    required: false
    inverse: governedByContract
    description: Linked assignment (organizational placement). INVERSE - Assignment.governedByContract must reference this Contract.
  
  - name: generatesCompensationBases
    target: CompensationBasis
    cardinality: one-to-many
    required: false
    inverse: sourceContract
    description: Compensation basis records generated from this contract (for LEGAL_BASE type). INVERSE - CompensationBasis.sourceContract.

lifecycle:
  states: [DRAFT, PENDING_SIGNATURE, ACTIVE, EXPIRED, TERMINATED, RENEWED, CANCELLED]
  initial: DRAFT
  terminal: [EXPIRED, TERMINATED, RENEWED, CANCELLED]
  transitions:
    - from: DRAFT
      to: PENDING_SIGNATURE
      trigger: submit_for_signature
      guard: Contract ready for signature
    - from: PENDING_SIGNATURE
      to: ACTIVE
      trigger: activate
      guard: All signatures collected, startDate reached
    - from: PENDING_SIGNATURE
      to: CANCELLED
      trigger: cancel
      guard: Cancelled before signing
    - from: ACTIVE
      to: EXPIRED
      trigger: expire
      guard: Past endDate (for DEFINITE/SEASONAL contracts)
    - from: ACTIVE
      to: TERMINATED
      trigger: terminate
      guard: Early termination (resignation, dismissal, etc.)
    - from: ACTIVE
      to: RENEWED
      trigger: renew
      guard: Replaced by new contract (renewal)

policies:
  - name: ContractNumberUniqueness
    type: validation
    rule: contractNumber must be unique across all contracts
    expression: "COUNT(Contract WHERE contractNumber = X) = 1"
    severity: ERROR
  
  - name: EndDateRequiredForDefinite
    type: validation
    rule: DEFINITE and SEASONAL contracts must have endDate
    expression: "contractTypeCode IN (INDEFINITE, TRIAL) OR endDate IS NOT NULL"
    severity: ERROR
  
  - name: IndefiniteNoEndDate
    type: validation
    rule: INDEFINITE contracts should not have endDate
    expression: "contractTypeCode != INDEFINITE OR endDate IS NULL"
    severity: WARNING
  
  - name: StartDateBeforeEndDate
    type: validation
    rule: startDate must be before endDate (if set)
    expression: "endDate IS NULL OR startDate < endDate"
  
  - name: ProbationEndDateConsistency
    type: validation
    rule: probationEndDate must be between startDate and endDate
    expression: "probationEndDate IS NULL OR (startDate <= probationEndDate AND (endDate IS NULL OR probationEndDate <= endDate))"
  
  - name: VNProbationMaxDuration
    type: business
    rule: VN law - probation max 180 days (managers), 60 (specialists), 30 (skilled), 6 (general)
    expression: "probationDays IS NULL OR probationDays <= 180"
    severity: WARNING
  
  - name: VNDefiniteContractDuration
    type: business
    rule: VN law - DEFINITE contracts should be 12-36 months
    expression: "contractTypeCode != DEFINITE OR (duration >= 12 AND duration <= 36 AND durationUnitCode = MONTHS)"
    severity: WARNING
  
  - name: VNRenewalRule
    type: business
    rule: VN law - after 2nd renewal (renewalCount = 2), contract must become INDEFINITE
    expression: "renewalCount < 2 OR contractTypeCode = INDEFINITE"
    severity: ERROR
  
  - name: VNNoticePerio dRules
    type: business
    rule: VN law - notice period depends on contract type (INDEFINITE=45d, DEFINITE 12-36m=30d, <12m=3d)
    severity: INFO
  
  - name: SignDateBeforeStartDate
    type: validation
    rule: signDate should be before or equal to startDate
    expression: "signDate IS NULL OR signDate <= startDate"
    severity: WARNING
  
  - name: ActiveContractRequirements
    type: business
    rule: ACTIVE contract must have signDate, legalRepresentativeId, and documentUrl
    expression: "statusCode != ACTIVE OR (signDate IS NOT NULL AND legalRepresentativeId IS NOT NULL)"
    severity: WARNING
  
  - name: RenewalChainConsistency
    type: validation
    rule: If previousContractId is set, renewalCount should be > 0
    expression: "previousContractId IS NULL OR renewalCount > 0"
  
  - name: PieceRateRequiredForProduct
    type: validation
    rule: PRODUCT_BASED or HYBRID must have pieceRateAmount OR pieceRateReference
    expression: "payMethodCode NOT IN (PRODUCT_BASED, HYBRID) OR pieceRateAmount IS NOT NULL OR pieceRateReference IS NOT NULL"
    severity: WARNING
  
  - name: BaseSalaryMinWage
    type: business
    rule: baseSalary must be ≥ Regional Minimum Wage for BHXH purposes (VN law)
    expression: "baseSalary >= REGIONAL_MIN_WAGE"
    severity: WARNING
  
  - name: PieceRateUnitRequired
    type: validation
    rule: If pieceRateAmount is set, pieceRateUnitCode is required
    expression: "pieceRateAmount IS NULL OR pieceRateUnitCode IS NOT NULL"
    severity: ERROR
---

# Entity: Contract

## 1. Overview

The **Contract** (Labor Contract) entity represents the formal legal agreement between an employer (Legal Entity) and an employee. It is **critical for Vietnam compliance** where labor contracts have strict legal requirements under Bộ Luật Lao Động 2019.

**Key Concept**:
```
Contract = Legal document (terms, compliance, audit trail)
Assignment = Organizational placement (job, department, location)
Contract ≠ Assignment (separate but linked)
```

```mermaid
mindmap
  root((Contract))
    Identity
      id
      contractNumber
    Parties
      employeeId
      legalEntityCode
      legalRepresentativeId
    Contract Type
      contractTypeCode
    Dates
      signDate
      startDate
      endDate
      duration
      durationUnitCode
    Probation
      probationStartDate
      probationEndDate
      probationDays
    Notice Period
      noticePeriod
      noticePeriodUnitCode
      employerNoticePeriod
    Compensation (VN Điều 96)
      payMethodCode
      baseSalary
      baseSalaryCurrencyCode
      salaryPayFrequencyCode
      pieceRateAmount
      pieceRateUnitCode
      pieceRateReference
    Work Details (VN Law)
      workContent
      workLocationId
      positionId
    Renewal Tracking
      renewalCount
      previousContractId
    Seniority
      seniorityDate
    Termination
      terminationDate
      terminationReasonCode
      okToRehire
    Document References
      templateId
      documentUrl
      signatureDate
    VN Specific
      laborBookNumber
      socialInsuranceStartDate
      unionContribution
    Status
      statusCode
    Relationships
      contractsEmployee
      employedByLegalEntity
      signedByRepresentative
      basedAtLocation
      forPosition
      renewsFromPreviousContract
      renewedByNextContract
      generatedFromTemplate
      hasAmendments
      hasDocuments
      linkedToAssignment
    Lifecycle
      DRAFT
      PENDING_SIGNATURE
      ACTIVE
      EXPIRED
      TERMINATED
      RENEWED
      CANCELLED
```

**Design Rationale**:
- **VN Labor Law Compliance**: Full support for VN Labor Code 2019 requirements
- **Renewal Tracking**: previousContract → nextContract chain for renewal history
- **Separation from Assignment**: Contract (legal) ≠ Assignment (organizational)
- **Document Management**: Links to signed PDF, amendments, appendices

---

## 2. Attributes

### 2.1 Identity Attributes

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| id | string | ✓ | Unique internal identifier (UUID) | employment.contract.id |
| contractNumber | string | ✓ | Business contract number (Số hợp đồng) | employment.contract.contract_number |

### 2.2 Parties

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| employeeId | string | ✓ | Contracted employee | employment.contract.employee_id → employment.employee.id |
| legalEntityCode | string | ✓ | Legal entity (employer) | employment.contract.legal_entity_code → org_legal.entity.code |
| legalRepresentativeId | string | | Legal representative who signed | <<employment.contract.legal_representative_id>> |

### 2.3 Contract Type

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| contractTypeCode | enum | ✓ | INDEFINITE, DEFINITE, SEASONAL, TRIAL | employment.contract.contract_type_code → common.code_list(CONTRACT_TYPE) |

### 2.4 Dates

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| signDate | date | ✓ | Date contract signed | employment.contract.signed_date |
| startDate | date | ✓ | Contract effective start | employment.contract.start_date |
| endDate | date | | Contract end (required for DEFINITE/SEASONAL) | employment.contract.end_date |
| duration | integer | | Duration (number of units) | (employment.contract.metadata.duration) |
| durationUnitCode | enum | | DAYS, MONTHS, YEARS | (employment.contract.metadata.duration_unit_code) |

### 2.5 Probation

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| probationStartDate | date | | Probation start | (employment.contract.metadata.probation_start_date) |
| probationEndDate | date | | Probation end | (employment.contract.metadata.probation_end_date) |
| probationDays | integer | | Probation length (max 180) | (employment.contract.metadata.probation_days) |

### 2.6 Notice Period

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| noticePeriod | integer | | Employee notice period | (employment.contract.metadata.notice_period) |
| noticePeriodUnitCode | enum | | DAYS, WEEKS, MONTHS | (employment.contract.metadata.notice_period_unit_code) |
| employerNoticePeriod | integer | | Employer notice (if different) | (employment.contract.metadata.employer_notice_period) |

### 2.7 Compensation Method (VN Labor Code Điều 96)

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| payMethodCode | enum | ✓ | TIME_BASED, PRODUCT_BASED, TASK_BASED, HYBRID | <<employment.contract.pay_method_code>> |
| baseSalary | decimal | ✓ | Mức lương căn cứ BHXH | employment.contract.salary_amount |
| baseSalaryCurrencyCode | string | ✓ | Currency (ISO 4217, default: VND) | employment.contract.salary_currency → common.currency.code |
| salaryPayFrequencyCode | enum | ✓ | MONTHLY, BI_WEEKLY, WEEKLY, DAILY, HOURLY | <<employment.contract.salary_pay_frequency_code>> |
| pieceRateAmount | decimal | | Đơn giá sản phẩm cố định | (employment.contract.metadata.piece_rate_amount) |
| pieceRateUnitCode | string | | Đơn vị tính (Cái, Kg, Mét, HĐ) | (employment.contract.metadata.piece_rate_unit_code) |
| pieceRateReference | string | | Dẫn chiếu bảng đơn giá | (employment.contract.metadata.piece_rate_reference) |

**Pay Method Types**:
| Code | VN Name | Description | Use Case |
|------|---------|-------------|----------|
| TIME_BASED | Lương thời gian | Trả theo tháng/ngày/giờ | Văn phòng, hành chính |
| PRODUCT_BASED | Lương sản phẩm | Trả 100% theo đơn giá | Công nhân may, sản xuất |
| TASK_BASED | Lương khoán | Trả theo công việc/dự án | Freelancer, contractor |
| HYBRID | Lương hỗn hợp | Lương cứng + Hoa hồng/Sản phẩm | Sales, ký thuật viên |

### 2.8 Work Details (VN Law Requirements)

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| workContent | string | | Work content/job description | (employment.contract.metadata.work_content) |
| workLocationId | string | | Primary work location | <<employment.contract.work_location_id>> → facility.work_location.id |
| positionId | string | | Contracted position | (employment.contract.metadata.position_id) → jobpos.position.id |

### 2.9 Renewal Tracking

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| renewalCount | integer | ✓ | Number of renewals (0 = original) | <<employment.contract.renewal_count>> |
| previousContractId | string | | Previous contract (renewal chain) | <<employment.contract.previous_contract_id>> → employment.contract.id |

### 2.10 Seniority

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| seniorityDate | date | | Date for seniority calculation | (employment.contract.metadata.seniority_date) |

### 2.11 Termination

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| terminationDate | date | | Actual last working day | <<employment.contract.termination_date>> |
| terminationReasonCode | string | | Termination reason | <<employment.contract.termination_reason_code>> |
| okToRehire | boolean | | Eligible for rehire? | (employment.contract.metadata.ok_to_rehire) |

### 2.12 Document References

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| templateId | string | | ContractTemplate used | employment.contract.template_id → employment.contract_template.id |
| documentUrl | string | | URL to signed PDF | (employment.contract.metadata.document_url) |
| signatureDate | date | | Employee signature date | (employment.contract.metadata.signature_date) |

### 2.13 VN Specific

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| laborBookNumber | string | | Số sổ lao động | (employment.contract.metadata.labor_book_number) |
| socialInsuranceStartDate | date | | BHXH start date | (employment.contract.metadata.social_insurance_start_date) |
| unionContribution | boolean | | Union fees? | (employment.contract.metadata.union_contribution) |

### 2.14 Status

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| statusCode | enum | ✓ | DRAFT, PENDING_SIGNATURE, ACTIVE, EXPIRED, TERMINATED, RENEWED, CANCELLED | employment.contract.status_code → common.code_list(CONTRACT_STATUS) |

### 2.15 Audit Attributes

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| createdAt | datetime | ✓ | Record creation timestamp | employment.contract.created_at |
| updatedAt | datetime | ✓ | Last modification timestamp | employment.contract.updated_at |
| createdBy | string | ✓ | User who created record | <<employment.contract.created_by>> |
| updatedBy | string | ✓ | User who last modified | <<employment.contract.updated_by>> |

---

## 3. Relationships

```mermaid
erDiagram
    Employee ||--o{ Contract : hasContracts
    LegalEntity ||--o{ Contract : employsViaContracts
    LegalRepresentative ||--o{ Contract : signedContracts
    Location ||--o{ Contract : hostsContracts
    Position ||--o{ Contract : hasContracts
    Contract ||--o{ Contract : renewedByNextContract
    ContractTemplate ||--o{ Contract : usedInContracts
    Contract ||--o{ ContractAmendment : hasAmendments
    Contract ||--o{ Document : hasDocuments
    Contract ||--|| Assignment : linkedToAssignment
    Contract ||--o{ CompensationBasis : generatesCompensationBases
    
    Contract {
        string id PK
        string contractNumber UK
        string employeeId FK
        string legalEntityCode FK
        string legalRepresentativeId FK
        enum contractTypeCode
        date signDate
        date startDate
        date endDate
        integer renewalCount
        string previousContractId FK
        enum statusCode
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[Employee]] | contractsEmployee | N:1 | Contracted employee |
| [[LegalEntity]] | employedByLegalEntity | N:1 | Legal employer |
| [[LegalRepresentative]] | signedByRepresentative | N:1 | Signer on behalf of employer |
| [[Location]] | basedAtLocation | N:1 | Primary work location |
| [[Position]] | forPosition | N:1 | Contracted position |
| [[Contract]] | renewsFromPreviousContract | N:1 | Previous contract (self-ref) |
| [[Contract]] | renewedByNextContract | 1:1 | Next contract (self-ref) |
| [[ContractTemplate]] | generatedFromTemplate | N:1 | Template used |
| [[ContractAmendment]] | hasAmendments | 1:N | Contract amendments |
| [[Document]] | hasDocuments | 1:N | Attached documents |
| [[Assignment]] | linkedToAssignment | 1:1 | Linked assignment |
| [[CompensationBasis]] | generatesCompensationBases | 1:N | Generated salary basis records (LEGAL_BASE) |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> DRAFT: Create Contract
    
    DRAFT --> PENDING_SIGNATURE: Submit for signature
    PENDING_SIGNATURE --> ACTIVE: Activate (signatures collected)
    PENDING_SIGNATURE --> CANCELLED: Cancel before signing
    
    ACTIVE --> EXPIRED: Expire (past endDate)
    ACTIVE --> TERMINATED: Terminate (early termination)
    ACTIVE --> RENEWED: Renew (replaced by new contract)
    
    EXPIRED --> [*]
    TERMINATED --> [*]
    RENEWED --> [*]
    CANCELLED --> [*]
    
    note right of DRAFT
        Contract being prepared
        Not yet ready for signature
    end note
    
    note right of PENDING_SIGNATURE
        Awaiting signatures
        Employee + Legal Representative
    end note
    
    note right of ACTIVE
        Currently in effect
        Employee working under this contract
    end note
    
    note right of EXPIRED
        Past endDate
        Natural expiry (DEFINITE/SEASONAL)
    end note
    
    note right of TERMINATED
        Early termination
        Resignation, dismissal, etc.
    end note
    
    note right of RENEWED
        Replaced by new contract
        Renewal chain continues
    end note
    
    note right of CANCELLED
        Cancelled before start
        Never became active
    end note
```

### State Descriptions

| State | Description | Allowed Operations |
|-------|-------------|-------------------|
| **DRAFT** | Contract being prepared | Can submit for signature |
| **PENDING_SIGNATURE** | Awaiting signatures | Can activate, can cancel |
| **ACTIVE** | Currently in effect | Can expire, terminate, renew |
| **EXPIRED** | Past endDate | Read-only, historical |
| **TERMINATED** | Early termination | Read-only, historical |
| **RENEWED** | Replaced by new contract | Read-only, historical |
| **CANCELLED** | Cancelled before start | Read-only, historical |

### Transition Rules

| From | To | Trigger | Guard Condition |
|------|-----|---------|--------------------|
| DRAFT | PENDING_SIGNATURE | submit_for_signature | Contract ready |
| PENDING_SIGNATURE | ACTIVE | activate | Signatures collected, startDate reached |
| PENDING_SIGNATURE | CANCELLED | cancel | Cancelled before signing |
| ACTIVE | EXPIRED | expire | Past endDate (DEFINITE/SEASONAL) |
| ACTIVE | TERMINATED | terminate | Early termination |
| ACTIVE | RENEWED | renew | Replaced by new contract |

---

## 5. Business Rules Reference

### Validation Rules
- **ContractNumberUniqueness**: contractNumber unique across all contracts
- **EndDateRequiredForDefinite**: DEFINITE/SEASONAL must have endDate
- **IndefiniteNoEndDate**: INDEFINITE should not have endDate (WARNING)
- **StartDateBeforeEndDate**: startDate < endDate (if set)
- **ProbationEndDateConsistency**: probationEndDate between startDate and endDate
- **SignDateBeforeStartDate**: signDate <= startDate (WARNING)
- **RenewalChainConsistency**: If previousContractId set, renewalCount > 0

### Business Constraints
- **VNProbationMaxDuration**: Max 180 days (managers), 60 (specialists), 30 (skilled), 6 (general) (WARNING)
- **VNDefiniteContractDuration**: DEFINITE should be 12-36 months (WARNING)
- **VNRenewalRule**: After 2nd renewal (renewalCount = 2), must become INDEFINITE
- **VNNoticePeriodRules**: Notice period depends on contract type (INFO)
- **ActiveContractRequirements**: ACTIVE must have signDate, legalRepresentativeId (WARNING)

### VN Labor Code 2019 Compliance

**Contract Types** (Loại Hợp Đồng):
| Type | VN Name | Duration | Description |
|------|---------|----------|-------------|
| INDEFINITE | Hợp đồng không xác định thời hạn | No end date | Permanent contract |
| DEFINITE | Hợp đồng xác định thời hạn | 12-36 months | Fixed-term contract |
| SEASONAL | Hợp đồng theo mùa vụ | < 12 months | Seasonal work (deprecated in 2019) |
| TRIAL | Hợp đồng thử việc | Max 180 days | Probation only |

**Probation Rules** (Thử Việc):
| Role Level | Max Probation | Min Salary % |
|------------|---------------|--------------|
| Enterprise Manager | 180 days | ≥ 85% |
| Manager/Specialist | 60 days | ≥ 85% |
| Technical/Skilled | 30 days | ≥ 85% |
| General Worker | 6 days | ≥ 85% |

**Notice Period Rules**:
| Contract Type | Employee Notice | Employer Notice |
|---------------|-----------------|-----------------|
| INDEFINITE | 45 days | 45 days |
| DEFINITE (12-36m) | 30 days | 30 days |
| DEFINITE (<12m) | 3 days | 3 days |
| SEASONAL | 3 days | 3 days |

**Renewal Rules**:
- After **1st renewal**: Still DEFINITE
- After **2nd renewal**: Must become INDEFINITE (automatic conversion by law)
- Example: DEFINITE (12m) → DEFINITE (12m) → INDEFINITE

### Contract vs Assignment

| Entity | Purpose | Example |
|--------|---------|---------|
| **Contract** | Legal document, terms, compliance | 12-month DEFINITE contract |
| **Assignment** | Organizational placement | Backend Engineer, Engineering Dept |

**Separation Rationale**:
- Contract can be renewed (new contract, same assignment)
- Assignment can change (promotion, transfer) without new contract
- Legal audit trail vs organizational structure

### Related Business Rules Documents
- See `[[contract-management.brs.md]]` for complete business rules catalog
- See `[[vn-labor-code-compliance.brs.md]]` for VN law requirements
- See `[[contract-renewal.brs.md]]` for renewal process rules
- See `[[probation-management.brs.md]]` for probation rules

---

## 6. Use Cases

### Use Case 1: New Hire - DEFINITE Contract (VN)

```yaml
Contract:
  id: "contract-001"
  contractNumber: "HĐLĐ-2024-001"
  employeeId: "emp-001"
  legalEntityCode: "VNG-HCM"
  legalRepresentativeId: "rep-001"
  contractTypeCode: "DEFINITE"
  signDate: "2024-01-15"
  startDate: "2024-02-01"
  endDate: "2025-01-31"  # 12 months
  duration: 12
  durationUnitCode: "MONTHS"
  probationEndDate: "2024-04-01"  # 60 days for specialist
  probationDays: 60
  noticePeriod: 30
  noticePeriodUnitCode: "DAYS"
  workContent: "Backend Engineer - Phát triển hệ thống backend"
  workLocationId: "loc-hcm"
  positionId: "pos-backend-eng"
  renewalCount: 0
  seniorityDate: "2024-02-01"
  socialInsuranceStartDate: "2024-02-01"
  statusCode: "ACTIVE"
```

### Use Case 2: Contract Renewal (1st Renewal)

```yaml
# Original Contract (DEFINITE, 12 months)
Contract_Original:
  id: "contract-001"
  contractNumber: "HĐLĐ-2024-001"
  contractTypeCode: "DEFINITE"
  startDate: "2024-02-01"
  endDate: "2025-01-31"
  renewalCount: 0
  statusCode: "RENEWED"  # Replaced by renewal

# 1st Renewal (DEFINITE, 12 months)
Contract_Renewal1:
  id: "contract-002"
  contractNumber: "HĐLĐ-2025-001"
  contractTypeCode: "DEFINITE"
  startDate: "2025-02-01"
  endDate: "2026-01-31"
  renewalCount: 1
  previousContractId: "contract-001"
  statusCode: "ACTIVE"
```

### Use Case 3: 2nd Renewal → Auto-Convert to INDEFINITE (VN Law)

```yaml
# 2nd Renewal (MUST become INDEFINITE by VN law)
Contract_Renewal2:
  id: "contract-003"
  contractNumber: "HĐLĐ-2026-001"
  contractTypeCode: "INDEFINITE"  # Auto-convert
  startDate: "2026-02-01"
  endDate: null  # No end date for INDEFINITE
  renewalCount: 2
  previousContractId: "contract-002"
  noticePeriod: 45  # INDEFINITE = 45 days
  statusCode: "ACTIVE"
```

### Use Case 4: Probation Contract (TRIAL)

```yaml
Contract:
  contractNumber: "HĐTV-2024-001"
  contractTypeCode: "TRIAL"
  startDate: "2024-01-15"
  endDate: "2024-04-14"  # 90 days
  probationDays: 90
  workContent: "Thử việc vị trí Backend Engineer"
  statusCode: "ACTIVE"
  
# Note: If successful, create new DEFINITE/INDEFINITE contract
```

### Use Case 5: Lương thời gian (TIME_BASED) - Văn phòng

```yaml
Contract:
  contractNumber: "HĐLĐ-2024-100"
  contractTypeCode: "INDEFINITE"
  # --- Compensation ---
  payMethodCode: "TIME_BASED"
  baseSalary: 20000000  # 20 triệu/tháng
  baseSalaryCurrencyCode: "VND"
  salaryPayFrequencyCode: "MONTHLY"
  pieceRateAmount: null
  pieceRateUnitCode: null
  pieceRateReference: null
  # ---
  workContent: "Nhân viên kế toán"
  statusCode: "ACTIVE"
```

### Use Case 6: Lương sản phẩm (PRODUCT_BASED) - Công nhân may

```yaml
Contract:
  contractNumber: "HĐLĐ-2024-200"
  contractTypeCode: "DEFINITE"
  duration: 12
  durationUnitCode: "MONTHS"
  # --- Compensation ---
  payMethodCode: "PRODUCT_BASED"
  baseSalary: 4680000  # Mức sàn BHXH (≥ lương tối thiểu vùng I)
  baseSalaryCurrencyCode: "VND"
  salaryPayFrequencyCode: "MONTHLY"
  pieceRateAmount: null  # Giá mỗi mã hàng khác nhau
  pieceRateUnitCode: null
  pieceRateReference: "Theo bảng đơn giá công đoạn may số 05/2024/QĐ-CTY"
  # ---
  workContent: "Công nhân may công đoạn hoàn thiện"
  statusCode: "ACTIVE"
  
# Note: Chi tiết đơn giá sản phẩm lưu tại PieceRateTable (TR module)
```

### Use Case 7: Lương hỗn hợp (HYBRID) - Sales

```yaml
Contract:
  contractNumber: "HĐLĐ-2024-300"
  contractTypeCode: "INDEFINITE"
  # --- Compensation ---
  payMethodCode: "HYBRID"
  baseSalary: 5000000  # Lương cứng hỗ trợ 5 triệu
  baseSalaryCurrencyCode: "VND"
  salaryPayFrequencyCode: "MONTHLY"
  pieceRateAmount: 500000  # 500k/hợp đồng ký được
  pieceRateUnitCode: "HĐ_SIGNED"  # Hợp đồng ký
  pieceRateReference: null  # Giá cố định trong HĐ
  # ---
  workContent: "Nhân viên kinh doanh - Khu vực miền Nam"
  statusCode: "ACTIVE"
  
# Note: Total income = baseSalary + (pieceRateAmount × số HĐ ký)
```

### Use Case 8: Lương khoán (TASK_BASED) - Contractor

```yaml
Contract:
  contractNumber: "HĐLĐ-2024-400"
  contractTypeCode: "SEASONAL"  # Hoặc hợp đồng dịch vụ
  duration: 3
  durationUnitCode: "MONTHS"
  # --- Compensation ---
  payMethodCode: "TASK_BASED"
  baseSalary: 50000000  # Tổng giá trị khoán cho dự án
  baseSalaryCurrencyCode: "VND"
  salaryPayFrequencyCode: "MONTHLY"  # Thanh toán theo tiến độ
  pieceRateAmount: null
  pieceRateUnitCode: null
  pieceRateReference: null
  # ---
  workContent: "Phát triển module báo cáo theo phạm vi TOR đính kèm"
  statusCode: "ACTIVE"
```

---

*Document Status: APPROVED - Based on Oracle HCM, SAP SuccessFactors, Workday + VN Labor Code 2019*  
*VN Compliance: Bộ Luật Lao Động 2019 (Điều 96 - Hình thức trả lương), Nghị định 145/2020/NĐ-CP*

