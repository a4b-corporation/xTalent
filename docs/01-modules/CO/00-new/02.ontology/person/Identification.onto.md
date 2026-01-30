---
entity: Identification
domain: person
version: "1.0.0"
status: deprecated
deprecatedSince: "2026-01-30"
deprecationReason: |
  DEPRECATED: Use Document entity with specific documentTypeCode instead.
  
  Identification is handled by Document entity:
  - Document.documentTypeCode = CCCD, CMND, PASSPORT, WORK_PERMIT, VISA, BHXH_BOOK, DRIVER_LICENSE
  - Document.documentNumber = The identification number (PII, encrypted)
  - Document.issueDate, Document.expiryDate = Validity dates
  - Document.issuingAuthority, Document.issuingCountryCode = Issuing info
  - Document.statusCode = ACTIVE, EXPIRED, REVOKED (lifecycle)
  - Document.metadata = Type-specific attributes (work permit details, visa type, etc.)
  
  Benefits of consolidation:
  - Single Document table for all attachments (no duplication)
  - Consistent verification workflow (PENDING_VERIFICATION → VERIFIED)
  - Unified file storage (fileUrl, checksum, mimeType)
  - Simpler queries (filter by documentTypeCode)
  
  Migration notes:
  - Identification.documentNumber → Document.documentNumber (PII)
  - Identification.verificationStatusCode → Document.statusCode (VERIFIED state)
  - Identification.usedForBhxh/usedForTax → Document.metadata.complianceFlags
  - Identification.workPermitTypeCode → Document.metadata.workPermit
owner: Person Domain Team
tags: [identification, cccd, passport, work-permit, pii, compliance, deprecated]

attributes:
  # === IDENTITY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  - name: identificationCode
    type: string
    required: true
    unique: true
    description: Internal business code for this identification record
    constraints:
      maxLength: 50
      pattern: "^ID-[A-Z]{2}-[0-9]{12}$"
  
  # === OWNER ===
  - name: employeeId
    type: string
    required: true
    description: Reference to Employee who owns this identification
  
  # === DOCUMENT TYPE ===
  - name: documentTypeCode
    type: enum
    required: true
    description: Type of identification document
    values: [CCCD, CMND, PASSPORT, WORK_PERMIT, VISA, BHXH_BOOK, DRIVER_LICENSE, PROFESSIONAL_LICENSE, OTHER]
  
  - name: documentSubTypeCode
    type: string
    required: false
    description: Sub-type for granular classification (e.g., PASSPORT_DIPLOMATIC, WORK_PERMIT_TYPE_A)
    constraints:
      maxLength: 50
  
  # === DOCUMENT NUMBER (PII - Encrypted) ===
  - name: documentNumber
    type: string
    required: true
    description: |
      Official document number (Số giấy tờ).
      PII - Must be encrypted at rest.
      Format varies by type:
      - CCCD: 12 digits
      - CMND: 9 digits
      - Passport: 1 letter + 7 digits
    constraints:
      maxLength: 50
    pii: true
  
  - name: documentNumberMasked
    type: string
    required: false
    description: Masked version for display (e.g., ****1234)
    constraints:
      maxLength: 50
  
  # === ISSUING AUTHORITY ===
  - name: issuingCountryCode
    type: string
    required: true
    description: Country that issued the document (ISO 3166-1 alpha-2)
    default: "VN"
    constraints:
      pattern: "^[A-Z]{2}$"
  
  - name: issuingAuthority
    type: string
    required: false
    description: |
      Authority that issued the document.
      VN examples: Cục Cảnh sát QLHC về TTXH, Bộ Công an, Cục Quản lý Xuất nhập cảnh
    constraints:
      maxLength: 255
  
  - name: issuingProvince
    type: string
    required: false
    description: Province/State where issued (for VN - Tỉnh/TP cấp)
    constraints:
      maxLength: 100
  
  # === VALIDITY DATES ===
  - name: issueDate
    type: date
    required: true
    description: Date document was issued (Ngày cấp)
  
  - name: expiryDate
    type: date
    required: false
    description: |
      Document expiry date (Ngày hết hạn).
      Required for: PASSPORT, WORK_PERMIT, VISA, DRIVER_LICENSE
      Not applicable for: CCCD (permanent), BHXH_BOOK
  
  - name: isExpired
    type: boolean
    required: true
    default: false
    description: Computed flag - true if expiryDate < today
  
  - name: daysUntilExpiry
    type: integer
    required: false
    description: Computed field - days until expiry (negative if expired)
  
  # === PERSONAL DETAILS (from document) ===
  - name: fullNameOnDocument
    type: string
    required: false
    description: Full name as printed on document (may differ from system name)
    constraints:
      maxLength: 255
    pii: true
  
  - name: dateOfBirthOnDocument
    type: date
    required: false
    description: Date of birth as on document (for verification)
    pii: true
  
  - name: genderOnDocument
    type: enum
    required: false
    description: Gender as on document
    values: [MALE, FEMALE, OTHER, UNKNOWN]
  
  - name: nationalityOnDocument
    type: string
    required: false
    description: Nationality as on document (ISO 3166-1 alpha-2)
    constraints:
      pattern: "^[A-Z]{2}$"
  
  - name: placeOfBirthOnDocument
    type: string
    required: false
    description: Place of birth (Nơi sinh) as on document
    constraints:
      maxLength: 255
    pii: true
  
  # === ADDRESS ON DOCUMENT (for CCCD/CMND) ===
  - name: permanentAddressOnDocument
    type: string
    required: false
    description: Permanent address as on CCCD/CMND (Địa chỉ thường trú)
    constraints:
      maxLength: 500
    pii: true
  
  # === WORK PERMIT SPECIFIC ===
  - name: workPermitTypeCode
    type: enum
    required: false
    description: Type of work permit (for WORK_PERMIT type only)
    values: [TYPE_A, TYPE_B, TYPE_C, TYPE_D]
    # TYPE_A: Quản lý, TYPE_B: Chuyên gia, TYPE_C: Kỹ thuật, TYPE_D: Lao động phổ thông
  
  - name: workPermitJobTitle
    type: string
    required: false
    description: Job title on work permit
    constraints:
      maxLength: 255
  
  - name: workPermitEmployer
    type: string
    required: false
    description: Employer name on work permit (must match current employer)
    constraints:
      maxLength: 255
  
  - name: workPermitLocation
    type: string
    required: false
    description: Authorized work location (if restricted)
    constraints:
      maxLength: 255
  
  # === VISA SPECIFIC ===
  - name: visaTypeCode
    type: string
    required: false
    description: Visa category/type code
    constraints:
      maxLength: 20
  
  - name: visaEntryType
    type: enum
    required: false
    description: Entry type for visa
    values: [SINGLE_ENTRY, MULTIPLE_ENTRY]
  
  # === DOCUMENT FILE ===
  - name: documentFileId
    type: string
    required: false
    description: Reference to Document entity (scanned copy)
  
  - name: documentFileFrontUrl
    type: string
    required: false
    description: URL to front side scan/photo
    constraints:
      maxLength: 500
  
  - name: documentFileBackUrl
    type: string
    required: false
    description: URL to back side scan/photo (for CCCD)
    constraints:
      maxLength: 500
  
  # === VERIFICATION ===
  - name: verificationStatusCode
    type: enum
    required: true
    description: Document verification status
    values: [PENDING, VERIFIED, INVALID, EXPIRED, REVOKED]
    default: PENDING
  
  - name: verifiedAt
    type: datetime
    required: false
    description: Timestamp when document was verified
  
  - name: verifiedById
    type: string
    required: false
    description: User who verified the document
  
  - name: verificationMethod
    type: enum
    required: false
    description: Method used to verify
    values: [MANUAL_CHECK, OCR_SCAN, API_VERIFICATION, NOTARIZED_COPY]
  
  - name: verificationNotes
    type: string
    required: false
    description: Notes from verification process
    constraints:
      maxLength: 500
  
  # === PRIMARY FLAG ===
  - name: isPrimary
    type: boolean
    required: true
    default: false
    description: Is this the primary ID for this document type? (only one per type per employee)
  
  - name: isActive
    type: boolean
    required: true
    default: true
    description: Is this identification currently active?
  
  # === STATUS ===
  - name: statusCode
    type: enum
    required: true
    description: Current record status
    values: [ACTIVE, INACTIVE, PENDING_RENEWAL, EXPIRED, REVOKED]
    default: ACTIVE
  
  # === RENEWAL TRACKING ===
  - name: previousIdentificationId
    type: string
    required: false
    description: Reference to previous identification (for renewals/updates)
  
  - name: renewalReminderSent
    type: boolean
    required: true
    default: false
    description: Has expiry reminder been sent?
  
  - name: renewalReminderDate
    type: date
    required: false
    description: Date when renewal reminder was sent
  
  # === COMPLIANCE ===
  - name: usedForBhxh
    type: boolean
    required: true
    default: false
    description: Is this the ID used for BHXH registration?
  
  - name: usedForTax
    type: boolean
    required: true
    default: false
    description: Is this the ID used for tax registration?
  
  - name: usedForPayroll
    type: boolean
    required: true
    default: false
    description: Is this the ID used for payroll/bank account verification?
  
  # === METADATA ===
  - name: metadata
    type: json
    required: false
    description: Additional flexible data (chip data, biometric reference, etc.)
  
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
    inverse: hasIdentifications
    description: Employee who owns this identification. INVERSE - Employee.hasIdentifications.
  
  - name: hasDocumentFile
    target: Document
    cardinality: one-to-one
    required: false
    inverse: isIdentificationFor
    description: Scanned document file. INVERSE - Document.isIdentificationFor.
  
  - name: verifiedByUser
    target: User
    cardinality: many-to-one
    required: false
    inverse: verifiedIdentifications
    description: User who verified this identification. INVERSE - User.verifiedIdentifications.
  
  - name: renewsFrom
    target: Identification
    cardinality: many-to-one
    required: false
    inverse: renewedBy
    description: Previous identification (if renewal). INVERSE - Identification.renewedBy.
  
  - name: renewedBy
    target: Identification
    cardinality: one-to-one
    required: false
    inverse: renewsFrom
    description: New identification (if renewed). INVERSE - Identification.renewsFrom.
  
  - name: forWorkRelationship
    target: WorkRelationship
    cardinality: many-to-one
    required: false
    inverse: requiresIdentifications
    description: Work relationship this identification supports (for work permits). INVERSE - WorkRelationship.requiresIdentifications.

lifecycle:
  states: [ACTIVE, INACTIVE, PENDING_RENEWAL, EXPIRED, REVOKED]
  initial: ACTIVE
  terminal: [REVOKED]
  transitions:
    - from: ACTIVE
      to: PENDING_RENEWAL
      trigger: approach_expiry
      guard: Within 90 days of expiryDate
    - from: PENDING_RENEWAL
      to: ACTIVE
      trigger: renew
      guard: New identification created, linked
    - from: [ACTIVE, PENDING_RENEWAL]
      to: EXPIRED
      trigger: expire
      guard: Past expiryDate without renewal
    - from: EXPIRED
      to: ACTIVE
      trigger: renew
      guard: Renewed after expiry
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: Replaced by new document
    - from: [ACTIVE, INACTIVE, PENDING_RENEWAL, EXPIRED]
      to: REVOKED
      trigger: revoke
      guard: Document declared invalid (lost, stolen, fraud)

policies:
  # === UNIQUENESS ===
  - name: UniqueDocumentNumber
    type: validation
    rule: Document number must be unique per type and country
    expression: "COUNT(Identification WHERE documentTypeCode = X AND issuingCountryCode = Y AND documentNumber = Z AND statusCode != 'REVOKED') = 1"
    severity: ERROR
  
  - name: OnePrimaryPerType
    type: validation
    rule: Only one primary identification per document type per employee
    expression: "COUNT(Identification WHERE employeeId = X AND documentTypeCode = Y AND isPrimary = true AND isActive = true) <= 1"
    severity: ERROR
  
  # === FORMAT VALIDATION ===
  - name: CCCDFormat
    type: validation
    rule: CCCD must be 12 digits
    expression: "documentTypeCode != 'CCCD' OR REGEXP_MATCH(documentNumber, '^[0-9]{12}$')"
    severity: ERROR
  
  - name: CMNDFormat
    type: validation
    rule: CMND must be 9 digits
    expression: "documentTypeCode != 'CMND' OR REGEXP_MATCH(documentNumber, '^[0-9]{9}$')"
    severity: ERROR
  
  - name: PassportFormat
    type: validation
    rule: VN Passport should be 1 letter + 7 digits
    expression: "documentTypeCode != 'PASSPORT' OR issuingCountryCode != 'VN' OR REGEXP_MATCH(documentNumber, '^[A-Z][0-9]{7}$')"
    severity: WARNING
  
  # === EXPIRY VALIDATION ===
  - name: ExpiryRequiredForSomeTypes
    type: validation
    rule: Expiry date required for PASSPORT, WORK_PERMIT, VISA, DRIVER_LICENSE
    expression: "documentTypeCode NOT IN ('PASSPORT', 'WORK_PERMIT', 'VISA', 'DRIVER_LICENSE') OR expiryDate IS NOT NULL"
    severity: ERROR
  
  - name: IssueDateBeforeExpiry
    type: validation
    rule: Issue date must be before expiry date
    expression: "expiryDate IS NULL OR issueDate < expiryDate"
    severity: ERROR
  
  # === WORK PERMIT SPECIFIC ===
  - name: WorkPermitMaxDuration
    type: business
    rule: VN Work Permit max 2 years per NĐ 70/2023
    expression: "documentTypeCode != 'WORK_PERMIT' OR DATE_DIFF(expiryDate, issueDate) <= 730"
    severity: WARNING
  
  - name: WorkPermitRenewalWindow
    type: business
    rule: VN Work Permit must be renewed 5-45 days before expiry per NĐ 70/2023
    expression: "documentTypeCode != 'WORK_PERMIT' OR renewalReminderDate IS NULL OR DATE_DIFF(expiryDate, renewalReminderDate) BETWEEN 5 AND 45"
    severity: INFO
  
  # === FOREIGN WORKER REQUIREMENTS ===
  - name: ForeignWorkerMustHaveWorkPermit
    type: business
    rule: Foreign employees must have valid work permit (with exceptions)
    expression: "Employees with nationality != VN must have WORK_PERMIT or qualify for exemption"
    severity: WARNING
  
  # === BHXH REGISTRATION ===
  - name: BhxhRequiresCccd
    type: business
    rule: BHXH registration requires valid CCCD/CMND
    expression: "usedForBhxh = true AND documentTypeCode IN ('CCCD', 'CMND') AND verificationStatusCode = 'VERIFIED'"
    severity: ERROR
  
  # === PII PROTECTION ===
  - name: PIIEncryption
    type: access
    rule: documentNumber must be encrypted at rest
    expression: "IS_ENCRYPTED(documentNumber)"
    severity: ERROR
  
  - name: PIIMasking
    type: access
    rule: documentNumberMasked should be generated for display
    expression: "documentNumberMasked = MASK(documentNumber, 4)"
    severity: INFO
---

# Entity: Identification

## 1. Overview

**Identification** entity quản lý các giấy tờ tùy thân của nhân viên, bao gồm CCCD, CMND, Hộ chiếu, Giấy phép lao động, v.v. Đây là entity quan trọng cho:
- **Compliance** - BHXH registration, Tax registration, Work permit tracking
- **PII Protection** - Encrypted storage, Masked display, Access logging
- **Foreign Worker Management** - Work permit validity, Visa tracking

**Key Concept**:
```
Identification = Legal identity document with validity tracking
Employee may have multiple Identifications (CCCD, Passport, Work Permit)
One primary per type for official use
```

```mermaid
mindmap
  root((Identification))
    Identity
      id
      identificationCode
    Owner
      employeeId
    Document Type
      documentTypeCode
        CCCD
        CMND
        PASSPORT
        WORK_PERMIT
        VISA
        BHXH_BOOK
        DRIVER_LICENSE
        PROFESSIONAL_LICENSE
        OTHER
      documentSubTypeCode
    Document Number «PII»
      documentNumber
      documentNumberMasked
    Issuing Authority
      issuingCountryCode
      issuingAuthority
      issuingProvince
    Validity Dates
      issueDate
      expiryDate
      isExpired
      daysUntilExpiry
    Personal Details «PII»
      fullNameOnDocument
      dateOfBirthOnDocument
      genderOnDocument
      nationalityOnDocument
      placeOfBirthOnDocument
      permanentAddressOnDocument
    Work Permit Specific
      workPermitTypeCode
      workPermitJobTitle
      workPermitEmployer
      workPermitLocation
    Visa Specific
      visaTypeCode
      visaEntryType
    Document File
      documentFileId
      documentFileFrontUrl
      documentFileBackUrl
    Verification
      verificationStatusCode
      verifiedAt
      verifiedById
      verificationMethod
      verificationNotes
    Flags
      isPrimary
      isActive
    Status
      statusCode
    Renewal Tracking
      previousIdentificationId
      renewalReminderSent
      renewalReminderDate
    Compliance Usage
      usedForBhxh
      usedForTax
      usedForPayroll
    Lifecycle
      ACTIVE
      INACTIVE
      PENDING_RENEWAL
      EXPIRED
      REVOKED
```

**Design Rationale**:
- **Multiple Types per Employee**: One employee may have CCCD, Passport, Work Permit
- **PII First-Class**: Document numbers encrypted, masked for display
- **Work Permit Focus**: Vietnam foreign worker compliance (NĐ 70/2023)
- **Expiry Tracking**: Proactive renewal reminders
- **Verification Workflow**: Track who verified and how

---

## 2. Attributes

### 2.1 Identity Attributes

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|-----------|
| id | string | ✓ | Unique internal identifier | person.identification.id |
| identificationCode | string | ✓ | Business code (ID-XX-NNNNNNNNNNNN) | person.identification.code |

### 2.2 Owner Reference

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|-----------|
| employeeId | string | ✓ | Employee who owns this ID | person.identification.employee_id → employment.employee.id |

### 2.3 Document Type

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| documentTypeCode | enum | ✓ | CCCD, CMND, PASSPORT, WORK_PERMIT, VISA, BHXH_BOOK, DRIVER_LICENSE, PROFESSIONAL_LICENSE, OTHER |
| documentSubTypeCode | string | | Sub-classification |

**Document Type Reference**:

| Code | Vietnamese | Description | Expiry Required |
|------|------------|-------------|-----------------|
| CCCD | Căn cước công dân | Citizen ID (chip) | No (permanent) |
| CMND | Chứng minh nhân dân | Legacy ID card | No |
| PASSPORT | Hộ chiếu | Passport | Yes (10 years) |
| WORK_PERMIT | Giấy phép lao động | Work permit for foreigners | Yes (max 2 years) |
| VISA | Thị thực | Entry visa | Yes |
| BHXH_BOOK | Sổ BHXH | Social insurance book | No |
| DRIVER_LICENSE | Giấy phép lái xe | Driver license | Yes |
| PROFESSIONAL_LICENSE | Chứng chỉ hành nghề | Professional license | Varies |

### 2.4 Document Number (PII)

| Attribute | Type | Required | Description | PII |
|-----------|------|----------|-------------|-----|
| documentNumber | string | ✓ | Official document number (encrypted) | ✓ |
| documentNumberMasked | string | | Masked for display (****1234) | |

**Format Examples**:
| Type | Format | Example |
|------|--------|---------|
| CCCD | 12 digits | 001234567890 |
| CMND | 9 digits | 123456789 |
| Passport (VN) | 1 letter + 7 digits | B1234567 |
| Work Permit | Variable | WP-2026-001234 |

### 2.5 Issuing Authority

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| issuingCountryCode | string | ✓ | ISO 3166-1 alpha-2 (default: VN) |
| issuingAuthority | string | | Authority name |
| issuingProvince | string | | Province/State |

### 2.6 Validity Dates

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| issueDate | date | ✓ | Date issued |
| expiryDate | date | Conditional | Required for PASSPORT, WORK_PERMIT, VISA, DRIVER_LICENSE |
| isExpired | boolean | ✓ | Computed: expiryDate < today |
| daysUntilExpiry | integer | | Computed: days until expiry |

### 2.7 Personal Details (PII)

| Attribute | Type | Required | Description | PII |
|-----------|------|----------|-------------|-----|
| fullNameOnDocument | string | | Name on document | ✓ |
| dateOfBirthOnDocument | date | | DOB on document | ✓ |
| genderOnDocument | enum | | MALE, FEMALE, OTHER, UNKNOWN | |
| nationalityOnDocument | string | | ISO country code | |
| placeOfBirthOnDocument | string | | Place of birth | ✓ |
| permanentAddressOnDocument | string | | Permanent address (CCCD) | ✓ |

### 2.8 Work Permit Specific

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| workPermitTypeCode | enum | | TYPE_A (Manager), TYPE_B (Expert), TYPE_C (Technical), TYPE_D (Labor) |
| workPermitJobTitle | string | | Job title on permit |
| workPermitEmployer | string | | Employer on permit |
| workPermitLocation | string | | Authorized location |

### 2.9 Verification

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| verificationStatusCode | enum | ✓ | PENDING, VERIFIED, INVALID, EXPIRED, REVOKED |
| verifiedAt | datetime | | Verification timestamp |
| verifiedById | string | | Verifier user ID |
| verificationMethod | enum | | MANUAL_CHECK, OCR_SCAN, API_VERIFICATION, NOTARIZED_COPY |
| verificationNotes | string | | Verification notes |

### 2.10 Flags & Status

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| isPrimary | boolean | ✓ | Primary ID for this type? |
| isActive | boolean | ✓ | Currently active? |
| statusCode | enum | ✓ | ACTIVE, INACTIVE, PENDING_RENEWAL, EXPIRED, REVOKED |

### 2.11 Compliance Usage

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| usedForBhxh | boolean | ✓ | Used for BHXH registration? |
| usedForTax | boolean | ✓ | Used for tax registration? |
| usedForPayroll | boolean | ✓ | Used for payroll/bank verification? |

### 2.12 Audit Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| createdAt | datetime | ✓ | Record creation timestamp |
| updatedAt | datetime | ✓ | Last modification timestamp |
| createdBy | string | ✓ | Creator user ID |
| updatedBy | string | ✓ | Last modifier user ID |

---

## 3. Relationships

```mermaid
erDiagram
    Employee ||--o{ Identification : hasIdentifications
    Document ||--o| Identification : isIdentificationFor
    User ||--o{ Identification : verifiedIdentifications
    Identification ||--o| Identification : renewedBy
    WorkRelationship ||--o{ Identification : requiresIdentifications
    
    Identification {
        string id PK
        string identificationCode UK
        string employeeId FK
        enum documentTypeCode
        string documentNumber "PII encrypted"
        date issueDate
        date expiryDate
        enum verificationStatusCode
        boolean isPrimary
        enum statusCode
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[Employee]] | belongsToEmployee | N:1 | Owner of identification |
| [[Document]] | hasDocumentFile | 1:1 | Scanned copy |
| [[User]] | verifiedByUser | N:1 | Who verified |
| [[Identification]] | renewsFrom / renewedBy | N:1 / 1:1 | Renewal chain |
| [[WorkRelationship]] | forWorkRelationship | N:1 | Work permit for WR |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> ACTIVE: Create Identification
    
    ACTIVE --> PENDING_RENEWAL: approach_expiry (90 days)
    PENDING_RENEWAL --> ACTIVE: renew (link new ID)
    
    ACTIVE --> EXPIRED: expire (past expiryDate)
    PENDING_RENEWAL --> EXPIRED: expire (not renewed in time)
    EXPIRED --> ACTIVE: renew (renewed after expiry)
    
    ACTIVE --> INACTIVE: deactivate (replaced)
    
    ACTIVE --> REVOKED: revoke (invalid/fraud)
    INACTIVE --> REVOKED: revoke
    PENDING_RENEWAL --> REVOKED: revoke
    EXPIRED --> REVOKED: revoke
    
    REVOKED --> [*]
```

| State | Business Meaning | System Impact |
|-------|------------------|---------------|
| **ACTIVE** | Valid and in use | Can be used for compliance |
| **PENDING_RENEWAL** | Near expiry, needs renewal | Sends reminder notifications |
| **EXPIRED** | Past expiry date | Cannot be used (compliance warning) |
| **INACTIVE** | Replaced by newer document | Historical record only |
| **REVOKED** | Invalid (lost, stolen, fraud) | Flagged for security |

---

## 5. Business Rules Reference

### Vietnam Regulations

| Rule | Reference | Description |
|------|-----------|-------------|
| CCCD Mandatory | Civil Law | All VN citizens must have CCCD |
| Work Permit Foreign | NĐ 70/2023 | Foreign workers must have valid permit |
| Renewal Window | NĐ 70/2023 | Work permit renewal 5-45 days before expiry |
| Max Duration | NĐ 70/2023 | Work permit max 2 years |
| BHXH Registration | BHXH Law | CCCD/CMND needed for registration |

### Related Business Rules

- [[Identification.brs.md]] - Document validation rules
- [[ForeignWorker.brs.md]] - Work permit requirements
- [[BHXH.brs.md]] - Social insurance ID requirements

---

## 6. PII Handling

### Data Classification

| Field | Classification | Storage | Display |
|-------|----------------|---------|---------|
| documentNumber | SENSITIVE | AES-256 Encrypted | Masked (****XXXX) |
| fullNameOnDocument | PII | Encrypted | Full (authorized only) |
| dateOfBirthOnDocument | PII | Encrypted | Full (authorized only) |
| permanentAddressOnDocument | PII | Encrypted | Masked |
| documentFileFrontUrl | PII | Access controlled | Authorized only |

### Access Control

| Role | View | Edit | Verify | Revoke |
|------|------|------|--------|--------|
| Employee (self) | ✓ | ✓ (create) | | |
| HR Admin | ✓ | ✓ | ✓ | ✓ |
| Manager | ✓ (team) | | | |
| Payroll Admin | ✓ (partial) | | | |
| Auditor | ✓ | | | |

---

## 7. Vietnam Regulatory Notes

### Nghị định 70/2023/NĐ-CP - Giấy phép lao động

> - Thời hạn giấy phép lao động tối đa 02 năm
> - Gia hạn trước 05-45 ngày trước khi hết hạn
> - Phải phù hợp với hợp đồng lao động và vị trí công việc
> - Các trường hợp miễn giấy phép lao động theo Điều 152 BLLĐ

### Căn cước công dân (CCCD)

> - Thay thế CMND từ 2021
> - Cookie chip chứa thông tin sinh trắc
> - Không có thời hạn (permanent)
> - 12 số theo cấu trúc: XXX-Y-ZZ-NNNNNN
>   - XXX: Mã tỉnh nơi đăng ký khai sinh
>   - Y: Giới tính + thế kỷ sinh
>   - ZZ: Năm sinh (2 số cuối)
>   - NNNNNN: Số ngẫu nhiên
