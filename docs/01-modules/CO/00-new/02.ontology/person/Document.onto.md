---
entity: Document
domain: common
version: "2.0.0"
status: draft
owner: Common Domain Team
tags: [document, attachment, file, dms, compliance, universal-registry]

# =============================================================================
# DESIGN PRINCIPLE: Universal Document Registry
# 
# Document is the SINGLE entity for ALL document attachments in xTalent:
# - Identity Docs: CCCD, CMND, Passport, Work Permit, Visa, Driver License
# - Contract Docs: Labor Contract, Appendix, Resignation, Termination Decision
# - Compliance Docs: BHXH Book, Tax Code Registration, Work Permit
# - Certificates: Degrees, Professional Licenses, Training Certificates
# - Other: Profile Photo, CV/Resume, References
# 
# Document stores METADATA + LINK to external DMS/File Storage.
# Actual file content is stored in DMS (Document Management System) or S3.
# =============================================================================

attributes:
  # === IDENTITY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  # === OWNER REFERENCE (Polymorphic) ===
  - name: ownerType
    type: enum
    required: true
    description: Type of entity that owns this document
    values: [WORKER, EMPLOYEE, CONTRACT, LEGAL_ENTITY, BUSINESS_UNIT, ASSIGNMENT]
  
  - name: ownerId
    type: string
    required: true
    description: Reference to owner entity (polymorphic FK)
  
  # === DOCUMENT CATEGORY ===
  - name: documentCategoryCode
    type: enum
    required: true
    description: High-level category for filtering and organization
    values: [
      IDENTIFICATION,           # Identity documents (CCCD, Passport, etc.)
      CONTRACT,                 # Employment contracts and appendices
      COMPLIANCE,               # BHXH, Tax, Work Permit compliance docs
      CERTIFICATE,              # Degrees, licenses, certifications
      PERSONAL,                 # Profile photo, CV, references
      ADMINISTRATIVE            # Resignation, Termination, Transfer docs
    ]
  
  # === DOCUMENT TYPE (Specific) ===
  - name: documentTypeCode
    type: string
    required: true
    description: |
      Specific document type. Reference to CODELIST_DOCUMENT_TYPE.
      
      IDENTIFICATION category:
      - CCCD: Căn cước công dân (12 digits)
      - CMND: Chứng minh nhân dân (9 digits, legacy)
      - PASSPORT: Hộ chiếu
      - WORK_PERMIT: Giấy phép lao động
      - VISA: Thị thực
      - DRIVER_LICENSE: Giấy phép lái xe
      - BHXH_BOOK: Sổ BHXH
      
      CONTRACT category:
      - LABOR_CONTRACT: Hợp đồng lao động
      - PROBATION_CONTRACT: Hợp đồng thử việc
      - CONTRACT_APPENDIX: Phụ lục hợp đồng
      - CONTRACT_RENEWAL: Gia hạn hợp đồng
      - TERMINATION_AGREEMENT: Thỏa thuận chấm dứt HĐ
      
      COMPLIANCE category:
      - TAX_CODE_REG: Đăng ký mã số thuế
      - BHXH_REGISTRATION: Đăng ký BHXH
      - WORK_PERMIT_EXEMPTION: Miễn giấy phép lao động
      
      CERTIFICATE category:
      - BACHELOR_DEGREE: Bằng đại học
      - MASTER_DEGREE: Bằng thạc sĩ
      - DOCTORATE_DEGREE: Bằng tiến sĩ
      - PROFESSIONAL_LICENSE: Chứng chỉ hành nghề
      - TRAINING_CERTIFICATE: Chứng chỉ đào tạo
      
      PERSONAL category:
      - PROFILE_PHOTO: Ảnh hồ sơ
      - CV_RESUME: Đơn xin việc/CV
      - REFERENCE_LETTER: Thư giới thiệu
      
      ADMINISTRATIVE category:
      - RESIGNATION_LETTER: Đơn xin nghỉ việc
      - TERMINATION_DECISION: Quyết định nghỉ việc
      - TRANSFER_ORDER: Quyết định điều chuyển
      - PROMOTION_ORDER: Quyết định bổ nhiệm
      - DISCIPLINARY_NOTICE: Quyết định kỷ luật
    constraints:
      maxLength: 50
  
  - name: documentName
    type: string
    required: true
    description: Display name of document (human-readable)
    constraints:
      maxLength: 200
  
  - name: documentDescription
    type: string
    required: false
    description: Detailed description or notes
    constraints:
      maxLength: 1000
  
  # === DOCUMENT NUMBER (for Identification) ===
  - name: documentNumber
    type: string
    required: false
    description: |
      Official document number (Số giấy tờ).
      Required for IDENTIFICATION category.
      PII - Must be encrypted at rest.
      Examples: CCCD 12 digits, Passport B1234567
    constraints:
      maxLength: 100
    pii: true
    sensitivity: high
  
  - name: documentNumberMasked
    type: string
    required: false
    description: Masked version for display (e.g., ****1234)
    constraints:
      maxLength: 50
  
  # === DMS/FILE STORAGE INTEGRATION ===
  - name: storageType
    type: enum
    required: true
    description: Where the actual file is stored
    values: [INTERNAL, DMS, S3, AZURE_BLOB, SHAREPOINT, GOOGLE_DRIVE]
    default: INTERNAL
  
  - name: externalDocId
    type: string
    required: false
    description: |
      External Document ID in DMS system.
      Format depends on storageType:
      - DMS: DMS-DOC-12345
      - S3: s3://bucket/path/to/file
      - SharePoint: https://sharepoint.com/sites/.../doc.pdf
    constraints:
      maxLength: 500
  
  - name: fileUrl
    type: string
    required: false
    description: Direct URL to file (internal or CDN URL)
    constraints:
      maxLength: 500
  
  - name: fileName
    type: string
    required: false
    description: Original file name
    constraints:
      maxLength: 255
  
  - name: fileSize
    type: integer
    required: false
    description: File size in bytes
    constraints:
      min: 0
  
  - name: mimeType
    type: string
    required: false
    description: MIME type (e.g., application/pdf, image/jpeg)
    constraints:
      maxLength: 100
  
  - name: checksum
    type: string
    required: false
    description: File checksum (SHA-256) for integrity verification
    constraints:
      maxLength: 64
  
  # === DOCUMENT DATES ===
  - name: issueDate
    type: date
    required: false
    description: Date document was issued (Ngày cấp)
  
  - name: expiryDate
    type: date
    required: false
    description: Document expiration date (Ngày hết hạn)
  
  - name: documentDate
    type: date
    required: false
    description: Date on the document (for contracts, letters)
  
  # === ISSUING AUTHORITY ===
  - name: issuingAuthority
    type: string
    required: false
    description: Issuing body/organization
    constraints:
      maxLength: 200
  
  - name: issuingCountryCode
    type: string
    required: false
    description: Country of issue (ISO 3166-1 alpha-2)
    constraints:
      pattern: "^[A-Z]{2}$"
  
  - name: issuingProvinceCode
    type: string
    required: false
    description: Province/City of issue (VN-specific)
    constraints:
      maxLength: 50
  
  # === LINKED ENTITY (for entity-specific docs) ===
  - name: linkedEntityType
    type: enum
    required: false
    description: If document is attached to a specific entity (e.g., Contract)
    values: [CONTRACT, ASSIGNMENT, QUALIFICATION, TRAINING]
  
  - name: linkedEntityId
    type: string
    required: false
    description: Reference to linked entity (e.g., contract_id for appendix)
  
  # === VERIFICATION ===
  - name: isVerified
    type: boolean
    required: true
    default: false
    description: Has document been verified as authentic?
  
  - name: verifiedAt
    type: datetime
    required: false
    description: When document was verified
  
  - name: verifiedById
    type: string
    required: false
    description: User who verified document
  
  - name: verificationMethod
    type: enum
    required: false
    description: How document was verified
    values: [MANUAL_CHECK, OCR_SCAN, API_VERIFICATION, NOTARIZED_COPY]
  
  # === VERSION ===
  - name: versionNumber
    type: integer
    required: true
    default: 1
    description: Document version number
    constraints:
      min: 1
  
  - name: previousVersionId
    type: string
    required: false
    description: Reference to previous version (version chain)
  
  - name: isLatestVersion
    type: boolean
    required: true
    default: true
    description: Is this the latest version?
  
  # === SECURITY ===
  - name: confidentialityLevelCode
    type: enum
    required: true
    description: Confidentiality level
    values: [PUBLIC, INTERNAL, CONFIDENTIAL, RESTRICTED]
    default: INTERNAL
  
  - name: digitalSignature
    type: string
    required: false
    description: Digital signature (for signed documents)
    constraints:
      maxLength: 500
  
  # === RETENTION ===
  - name: retentionDate
    type: date
    required: false
    description: Date document can be deleted (retention policy)
  
  - name: retentionPolicyCode
    type: string
    required: false
    description: |
      Reference to retention policy code.
      Examples:
      - VN_IDENTITY_5Y: Employment + 5 years (CCCD)
      - VN_CONTRACT_10Y: 10 years after termination
      - VN_TAX_5Y: 5 years
    constraints:
      maxLength: 50
  
  # === COMPLIANCE FLAGS (replaces Identification entity) ===
  - name: isIdentificationDocument
    type: boolean
    required: true
    default: false
    description: Is this a legal identification document?
  
  - name: isPrimaryId
    type: boolean
    required: false
    default: false
    description: Is this the primary identification of its type?
  
  - name: usedForBhxh
    type: boolean
    required: false
    default: false
    description: Is this ID used for BHXH registration?
  
  - name: usedForTax
    type: boolean
    required: false
    default: false
    description: Is this ID used for tax registration?
  
  - name: usedForPayroll
    type: boolean
    required: false
    default: false
    description: Is this ID used for bank/payroll verification?
  
  # === STATUS ===
  - name: statusCode
    type: enum
    required: true
    description: Document status
    values: [DRAFT, ACTIVE, PENDING_VERIFICATION, VERIFIED, EXPIRED, ARCHIVED, DELETED]
    default: DRAFT
  
  # === METADATA (Type-specific attributes) ===
  - name: metadata
    type: json
    required: false
    description: |
      Type-specific attributes in JSONB. Schema varies by documentCategoryCode:
      
      For IDENTIFICATION:
      {
        "fullNameOnDocument": "NGUYEN VAN A",
        "dateOfBirthOnDocument": "1990-01-15",
        "genderOnDocument": "MALE",
        "nationalityOnDocument": "VN",
        "permanentAddressOnDocument": "123 Nguyen Trai, Q1, TPHCM",
        "workPermit": {
          "typeCode": "TYPE_B",
          "jobTitle": "Software Engineer",
          "employerName": "ABC Company",
          "maxDuration": 2
        }
      }
      
      For CONTRACT:
      {
        "contractNumber": "HD-2026-001234",
        "signedByEmployee": true,
        "signedByEmployer": true,
        "signatureDate": "2026-01-15"
      }
      
      For CERTIFICATE:
      {
        "institutionName": "Harvard University",
        "major": "Computer Science",
        "gpa": 3.8,
        "graduationDate": "2020-05-20"
      }
  
  # === AUDIT ===
  - name: createdAt
    type: datetime
    required: true
    description: Record creation timestamp
  
  - name: updatedAt
    type: datetime
    required: true
    description: Last modification timestamp
  
  - name: createdById
    type: string
    required: true
    description: User who created the record
  
  - name: updatedById
    type: string
    required: true
    description: User who last modified the record

relationships:
  - name: belongsToWorker
    target: Worker
    cardinality: many-to-one
    required: false
    inverse: hasDocuments
    description: Worker who owns this document (when ownerType = WORKER)
  
  - name: belongsToEmployee
    target: Employee
    cardinality: many-to-one
    required: false
    inverse: hasDocuments
    description: Employee who owns this document (when ownerType = EMPLOYEE)
  
  - name: belongsToContract
    target: Contract
    cardinality: many-to-one
    required: false
    inverse: hasDocuments
    description: Contract this document belongs to (when ownerType = CONTRACT)
  
  - name: linkedToContract
    target: Contract
    cardinality: many-to-one
    required: false
    inverse: hasAttachments
    description: Contract this document is attached to (for appendix, addendum)
  
  - name: issuedInCountry
    target: Country
    cardinality: many-to-one
    required: false
    inverse: hasDocuments
    description: Country of issue
  
  - name: verifiedByUser
    target: User
    cardinality: many-to-one
    required: false
    inverse: verifiedDocuments
    description: User who verified document
  
  - name: hasPreviousVersion
    target: Document
    cardinality: many-to-one
    required: false
    inverse: hasNextVersion
    description: Previous version (self-referential)
  
  - name: hasNextVersion
    target: Document
    cardinality: one-to-one
    required: false
    inverse: hasPreviousVersion
    description: Next version (self-referential)

lifecycle:
  states: [DRAFT, ACTIVE, PENDING_VERIFICATION, VERIFIED, EXPIRED, ARCHIVED, DELETED]
  initial: DRAFT
  terminal: [ARCHIVED, DELETED]
  transitions:
    - from: DRAFT
      to: ACTIVE
      trigger: activate
      guard: Document uploaded and ready
    - from: ACTIVE
      to: PENDING_VERIFICATION
      trigger: submit_for_verification
      guard: Verification required
    - from: PENDING_VERIFICATION
      to: VERIFIED
      trigger: verify
      guard: Verification successful
    - from: PENDING_VERIFICATION
      to: ACTIVE
      trigger: reject_verification
      guard: Verification failed
    - from: [ACTIVE, VERIFIED]
      to: EXPIRED
      trigger: expire
      guard: Past expiryDate
    - from: [ACTIVE, VERIFIED, EXPIRED]
      to: ARCHIVED
      trigger: archive
      guard: Retention period ended
    - from: [ACTIVE, EXPIRED]
      to: DELETED
      trigger: delete
      guard: Soft delete

policies:
  # === DATE VALIDATION ===
  - name: ExpiryDateConsistency
    type: validation
    rule: expiryDate must be after issueDate (if both set)
    expression: "issueDate IS NULL OR expiryDate IS NULL OR issueDate < expiryDate"
    severity: ERROR
  
  # === IDENTIFICATION VALIDATION ===
  - name: IdentificationRequiresNumber
    type: validation
    rule: IDENTIFICATION category requires documentNumber
    expression: "documentCategoryCode != 'IDENTIFICATION' OR documentNumber IS NOT NULL"
    severity: ERROR
  
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
  
  - name: OnePrimaryPerIdType
    type: validation
    rule: Only one primary identification per document type per worker
    expression: "isPrimaryId = false OR COUNT(Document WHERE ownerId = X AND documentTypeCode = Y AND isPrimaryId = true AND statusCode != 'DELETED') <= 1"
    severity: ERROR
  
  # === EXPIRY VALIDATION ===
  - name: ExpiryRequiredForSomeTypes
    type: validation
    rule: Expiry date required for PASSPORT, WORK_PERMIT, VISA, DRIVER_LICENSE
    expression: "documentTypeCode NOT IN ('PASSPORT', 'WORK_PERMIT', 'VISA', 'DRIVER_LICENSE') OR expiryDate IS NOT NULL"
    severity: ERROR
  
  - name: ExpiredDocumentCheck
    type: business
    rule: If expiryDate is past, status should be EXPIRED
    trigger: DAILY_CHECK
    severity: WARNING
  
  # === RETENTION POLICIES ===
  - name: VNIdentityDocumentRetention
    type: business
    rule: VN law - identity documents (CCCD, CMND) must be retained for employment duration + 5 years
    severity: INFO
  
  - name: VNLaborContractRetention
    type: business
    rule: VN law - labor contracts must be retained for 10 years after termination
    severity: INFO
  
  # === VERSION CONSISTENCY ===
  - name: VersionChainConsistency
    type: validation
    rule: If previousVersionId is set, versionNumber should be > 1
    expression: "previousVersionId IS NULL OR versionNumber > 1"
    severity: ERROR
  
  # === SECURITY ===
  - name: ConfidentialDocumentAccess
    type: security
    rule: CONFIDENTIAL/RESTRICTED documents require special access permissions
    severity: ERROR
  
  - name: PIIEncryption
    type: security
    rule: documentNumber must be encrypted at rest
    expression: "IS_ENCRYPTED(documentNumber)"
    severity: ERROR
  
  # === DMS INTEGRATION ===
  - name: ExternalDocIdRequired
    type: validation
    rule: If storageType is not INTERNAL, externalDocId is required
    expression: "storageType = 'INTERNAL' OR externalDocId IS NOT NULL"
    severity: ERROR
---

# Entity: Document

## 1. Overview

**Document** is the **Universal Document Registry** for all file attachments in xTalent. It stores document metadata and links to external DMS (Document Management System) or file storage.

**Key Concept:**
```
Document = Metadata Registry + DMS Link

Document DOES NOT store file content directly.
Document stores:
- Metadata (type, dates, verification status)
- Link to external storage (DMS, S3, SharePoint)

This replaces:
- Identification entity (deprecated)
- Separate contract attachment handling
- Certificate/qualification file storage
```

```mermaid
mindmap
  root((Document))
    Identity
      id
    Owner (Polymorphic)
      ownerType
        WORKER
        EMPLOYEE
        CONTRACT
        LEGAL_ENTITY
        BUSINESS_UNIT
        ASSIGNMENT
      ownerId
    Document Category
      documentCategoryCode
        IDENTIFICATION
        CONTRACT
        COMPLIANCE
        CERTIFICATE
        PERSONAL
        ADMINISTRATIVE
    Document Type
      documentTypeCode
        CCCD
        PASSPORT
        LABOR_CONTRACT
        etc...
      documentName
      documentNumber «PII»
    DMS Integration
      storageType
        INTERNAL
        DMS
        S3
        SHAREPOINT
      externalDocId
      fileUrl
      fileName
    Document Dates
      issueDate
      expiryDate
      documentDate
    Issuing Authority
      issuingAuthority
      issuingCountryCode
    Linked Entity
      linkedEntityType
      linkedEntityId
    Verification
      isVerified
      verifiedAt
      verifiedById
      verificationMethod
    Version Control
      versionNumber
      previousVersionId
      isLatestVersion
    Compliance Flags
      isIdentificationDocument
      isPrimaryId
      usedForBhxh
      usedForTax
      usedForPayroll
    Security
      confidentialityLevelCode
      digitalSignature
    Retention
      retentionDate
      retentionPolicyCode
    Metadata (JSONB)
      Type-specific data
    Status
      statusCode
```

**Design Rationale:**
- **Single Source of Truth**: One entity for all documents
- **DMS Integration**: Link to external storage, not embedded files
- **Replaces Identification**: CCCD, Passport, Work Permit are document types
- **Version Control**: Track document versions with previousVersionId chain
- **VN Compliance**: Retention policies, verification workflow

---

## 2. Document Categories & Types

### 2.1 IDENTIFICATION Documents

| Type Code | Vietnamese | Description | Expiry Required |
|-----------|------------|-------------|-----------------|
| CCCD | Căn cước công dân | 12-digit citizen ID | No (permanent) |
| CMND | Chứng minh nhân dân | 9-digit legacy ID | No |
| PASSPORT | Hộ chiếu | Passport | Yes (10 years) |
| WORK_PERMIT | Giấy phép lao động | Work permit (foreigners) | Yes (max 2 years) |
| VISA | Thị thực | Entry visa | Yes |
| DRIVER_LICENSE | Giấy phép lái xe | Driver license | Yes |
| BHXH_BOOK | Sổ BHXH | Social insurance book | No |

### 2.2 CONTRACT Documents

| Type Code | Vietnamese | Description |
|-----------|------------|-------------|
| LABOR_CONTRACT | Hợp đồng lao động | Employment contract |
| PROBATION_CONTRACT | Hợp đồng thử việc | Probation contract |
| CONTRACT_APPENDIX | Phụ lục hợp đồng | Contract appendix |
| CONTRACT_RENEWAL | Gia hạn hợp đồng | Contract renewal |
| TERMINATION_AGREEMENT | Thỏa thuận chấm dứt HĐ | Termination agreement |

### 2.3 COMPLIANCE Documents

| Type Code | Vietnamese | Description |
|-----------|------------|-------------|
| TAX_CODE_REG | Đăng ký mã số thuế | Tax code registration |
| BHXH_REGISTRATION | Đăng ký BHXH | Social insurance registration |
| WORK_PERMIT_EXEMPTION | Miễn giấy phép lao động | Work permit exemption |

### 2.4 CERTIFICATE Documents

| Type Code | Vietnamese | Description |
|-----------|------------|-------------|
| BACHELOR_DEGREE | Bằng đại học | Bachelor's degree |
| MASTER_DEGREE | Bằng thạc sĩ | Master's degree |
| DOCTORATE_DEGREE | Bằng tiến sĩ | Doctorate degree |
| PROFESSIONAL_LICENSE | Chứng chỉ hành nghề | Professional license |
| TRAINING_CERTIFICATE | Chứng chỉ đào tạo | Training certificate |

### 2.5 ADMINISTRATIVE Documents

| Type Code | Vietnamese | Description | Retention |
|-----------|------------|-------------|-----------|
| RESIGNATION_LETTER | Đơn xin nghỉ việc | Resignation letter | 10 years |
| TERMINATION_DECISION | Quyết định nghỉ việc | Termination decision | 10 years |
| TRANSFER_ORDER | Quyết định điều chuyển | Transfer order | 10 years |
| PROMOTION_ORDER | Quyết định bổ nhiệm | Promotion order | 10 years |
| DISCIPLINARY_NOTICE | Quyết định kỷ luật | Disciplinary notice | 10 years |

---

## 3. DMS Integration

Document supports integration with external Document Management Systems:

```mermaid
graph LR
    subgraph xTalent
        DOC[Document Entity]
    end
    
    subgraph "External Storage"
        DMS[Enterprise DMS]
        S3[AWS S3]
        SP[SharePoint]
        GD[Google Drive]
    end
    
    DOC -->|externalDocId| DMS
    DOC -->|externalDocId| S3
    DOC -->|externalDocId| SP
    DOC -->|externalDocId| GD
```

### Storage Types

| storageType | Description | externalDocId Format |
|-------------|-------------|----------------------|
| INTERNAL | xTalent file storage | /files/2026/01/doc-123.pdf |
| DMS | Enterprise DMS | DMS-DOC-12345 |
| S3 | AWS S3 bucket | s3://xtalent-docs/worker/123/cccd.pdf |
| AZURE_BLOB | Azure Blob Storage | https://account.blob.core.windows.net/... |
| SHAREPOINT | SharePoint Online | https://tenant.sharepoint.com/sites/.../doc.pdf |
| GOOGLE_DRIVE | Google Drive | 1234567890abcdef |

---

## 4. Use Cases

### Use Case 1: CCCD (Citizen ID)

```yaml
Document:
  id: "doc-001"
  ownerType: "WORKER"
  ownerId: "worker-001"
  documentCategoryCode: "IDENTIFICATION"
  documentTypeCode: "CCCD"
  documentName: "CCCD - Nguyễn Văn A"
  documentNumber: "012345678901"  # Encrypted
  documentNumberMasked: "****8901"
  issueDate: "2020-05-15"
  expiryDate: null  # CCCD is permanent
  issuingAuthority: "Cục Cảnh sát QLHC về TTXH"
  issuingCountryCode: "VN"
  storageType: "S3"
  externalDocId: "s3://xtalent-docs/worker/001/cccd-front.pdf"
  isVerified: true
  verifiedAt: "2024-01-10T10:00:00Z"
  verificationMethod: "OCR_SCAN"
  isIdentificationDocument: true
  isPrimaryId: true
  usedForBhxh: true
  usedForTax: true
  statusCode: "VERIFIED"
  metadata:
    fullNameOnDocument: "NGUYỄN VĂN A"
    dateOfBirthOnDocument: "1990-01-15"
    genderOnDocument: "MALE"
    permanentAddressOnDocument: "123 Nguyễn Trãi, Q1, TPHCM"
```

### Use Case 2: Labor Contract (Attached to Contract Entity)

```yaml
Document:
  id: "doc-002"
  ownerType: "CONTRACT"
  ownerId: "contract-001"
  documentCategoryCode: "CONTRACT"
  documentTypeCode: "LABOR_CONTRACT"
  documentName: "HĐ Lao động - NV00123 - 2024"
  documentDate: "2024-01-15"
  storageType: "DMS"
  externalDocId: "DMS-HD-2024-00123"
  isVerified: true
  confidentialityLevelCode: "CONFIDENTIAL"
  statusCode: "VERIFIED"
  retentionPolicyCode: "VN_CONTRACT_10Y"
  metadata:
    contractNumber: "HD-2024-00123"
    signedByEmployee: true
    signedByEmployer: true
    signatureDate: "2024-01-15"
```

### Use Case 3: Contract Appendix (Salary Adjustment)

```yaml
Document:
  id: "doc-003"
  ownerType: "CONTRACT"
  ownerId: "contract-001"
  linkedEntityType: "CONTRACT"
  linkedEntityId: "contract-001"  # Links to parent contract
  documentCategoryCode: "CONTRACT"
  documentTypeCode: "CONTRACT_APPENDIX"
  documentName: "Phụ lục HĐ - Điều chỉnh lương - 2025"
  documentDate: "2025-01-01"
  storageType: "DMS"
  externalDocId: "DMS-PL-2025-00001"
  statusCode: "VERIFIED"
  versionNumber: 1
  metadata:
    appendixNumber: "PL-01/2025"
    changeType: "SALARY_ADJUSTMENT"
    previousSalary: 20000000
    newSalary: 25000000
    effectiveDate: "2025-01-01"
```

---

## 5. Relationships

```mermaid
erDiagram
    Worker ||--o{ Document : hasDocuments
    Employee ||--o{ Document : hasDocuments
    Contract ||--o{ Document : hasDocuments
    Contract ||--o{ Document : hasAttachments
    Document ||--o| Document : hasNextVersion
    
    Document {
        uuid id PK
        enum ownerType
        uuid ownerId FK
        enum documentCategoryCode
        string documentTypeCode
        string documentNumber "PII"
        enum storageType
        string externalDocId
        date issueDate
        date expiryDate
        boolean isVerified
        enum statusCode
    }
```

---

## 6. Vietnam Compliance

### Retention Requirements

| Document Type | Retention Period | Legal Reference |
|---------------|------------------|-----------------|
| Identity docs (CCCD) | Employment + 5 years | Bộ Luật Lao động |
| Labor contracts | 10 years after termination | Bộ Luật Lao động Điều 14 |
| Tax documents | 5 years | Luật Thuế TNCN |
| BHXH records | Permanent | Luật BHXH |
| Work permits | Employment duration | NĐ 70/2023 |

---

*Document Status: DRAFT v2.0.0*  
*Refactored as Universal Document Registry*  
*Replaces: Identification.onto.md (deprecated)*
