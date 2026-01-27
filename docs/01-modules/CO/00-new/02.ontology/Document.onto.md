---
entity: Document
domain: common
version: "1.0.0"
status: approved
owner: Common Domain Team
tags: [document, attachment, file, compliance]

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
    values: [WORKER, EMPLOYEE, CONTRACT, LEGAL_ENTITY, BUSINESS_UNIT]
  
  - name: ownerId
    type: string
    required: true
    description: Reference to owner entity (polymorphic)
  
  # === DOCUMENT TYPE ===
  - name: documentTypeCode
    type: string
    required: true
    description: Document category/type (reference to CODELIST_DOCUMENT_TYPE)
    constraints:
      maxLength: 50
  
  - name: documentName
    type: string
    required: true
    description: Display name of document
    constraints:
      maxLength: 200
  
  - name: documentNumber
    type: string
    required: false
    description: Document ID/number (e.g., passport number, CCCD number)
    constraints:
      maxLength: 100
    metadata:
      pii: true
      sensitivity: high
  
  # === FILE DETAILS ===
  - name: fileName
    type: string
    required: false
    description: Original file name
    constraints:
      maxLength: 255
  
  - name: fileUrl
    type: string
    required: false
    description: Storage URL/path to file
    constraints:
      maxLength: 500
  
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
    description: Date document was issued
  
  - name: expiryDate
    type: date
    required: false
    description: Document expiration date
  
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
  
  - name: verifiedBy
    type: string
    required: false
    description: User who verified document
  
  # === VERSION ===
  - name: version
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
  
  # === SECURITY ===
  - name: confidentialityLevelCode
    type: enum
    required: false
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
  
  # === DESCRIPTION ===
  - name: description
    type: string
    required: false
    description: Document description/notes
    constraints:
      maxLength: 1000
  
  # === STATUS ===
  - name: statusCode
    type: enum
    required: true
    description: Document status. Aligned with xTalent naming convention.
    values: [DRAFT, ACTIVE, PENDING_VERIFICATION, VERIFIED, EXPIRED, ARCHIVED, DELETED]
    default: DRAFT
  
  # === METADATA ===
  - name: metadata
    type: json
    required: false
    description: Additional flexible data
  
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
  - name: issuedInCountry
    target: Country
    cardinality: many-to-one
    required: false
    inverse: hasDocuments
    description: Country of issue. INVERSE - Country.hasDocuments must reference this Document.
  
  - name: verifiedByUser
    target: User
    cardinality: many-to-one
    required: false
    inverse: verifiedDocuments
    description: User who verified document. INVERSE - User.verifiedDocuments must reference this Document.
  
  - name: hasPreviousVersion
    target: Document
    cardinality: many-to-one
    required: false
    inverse: hasNextVersion
    description: Previous version (self-referential). INVERSE - Document.hasNextVersion must reference this Document.
  
  - name: hasNextVersion
    target: Document
    cardinality: one-to-one
    required: false
    inverse: hasPreviousVersion
    description: Next version (self-referential). INVERSE - Document.hasPreviousVersion must reference this Document.

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
    - from: ACTIVE
      to: EXPIRED
      trigger: expire
      guard: Past expiryDate
    - from: VERIFIED
      to: EXPIRED
      trigger: expire
      guard: Past expiryDate
    - from: ACTIVE
      to: ARCHIVED
      trigger: archive
      guard: Retention period ended
    - from: VERIFIED
      to: ARCHIVED
      trigger: archive
      guard: Retention period ended
    - from: EXPIRED
      to: ARCHIVED
      trigger: archive
      guard: Retention period ended
    - from: ACTIVE
      to: DELETED
      trigger: delete
      guard: Soft delete
    - from: EXPIRED
      to: DELETED
      trigger: delete
      guard: Soft delete

policies:
  - name: ExpiryDateConsistency
    type: validation
    rule: expiryDate must be after issueDate (if both set)
    expression: "issueDate IS NULL OR expiryDate IS NULL OR issueDate < expiryDate"
  
  - name: VerifiedDocumentRequirements
    type: business
    rule: VERIFIED document must have verifiedAt and verifiedBy
    expression: "statusCode != VERIFIED OR (verifiedAt IS NOT NULL AND verifiedBy IS NOT NULL)"
    severity: WARNING
  
  - name: ExpiredDocumentCheck
    type: business
    rule: If expiryDate is past, status should be EXPIRED
    trigger: DAILY_CHECK
    severity: WARNING
  
  - name: VNIdentityDocumentRetention
    type: business
    rule: VN law - identity documents (CCCD, CMND) must be retained for employment duration + 5 years
    severity: INFO
  
  - name: VNLaborContractRetention
    type: business
    rule: VN law - labor contracts must be retained for 10 years after termination
    severity: INFO
  
  - name: VersionChainConsistency
    type: validation
    rule: If previousVersionId is set, version should be > 1
    expression: "previousVersionId IS NULL OR version > 1"
  
  - name: ConfidentialDocumentAccess
    type: security
    rule: CONFIDENTIAL/RESTRICTED documents require special access permissions
    severity: ERROR
---

# Entity: Document

## 1. Overview

The **Document** entity manages file attachments and documents associated with employees, contracts, organizations, and other HR entities. It is a **polymorphic entity** supporting identity documents, contracts, certificates, and other HR-related files.

**Key Concept**:
```
Document = Polymorphic (Worker/Employee/Contract/LegalEntity/BusinessUnit)
VN Compliance: CCCD, Labor Contract, BHXH, Tax Code
Retention: Identity docs (employment + 5 years), Contracts (10 years)
```

```mermaid
mindmap
  root((Document))
    Identity
      id
    Owner (Polymorphic)
      ownerType
      ownerId
    Document Type
      documentTypeCode
      documentName
      documentNumber
    File Details
      fileName
      fileUrl
      fileSize
      mimeType
      checksum
    Document Dates
      issueDate
      expiryDate
    Issuing Authority
      issuingAuthority
      issuingCountryCode
    Verification
      isVerified
      verifiedAt
      verifiedBy
    Version
      version
      previousVersionId
    Security
      confidentialityLevelCode
      digitalSignature
    Retention
      retentionDate
    Description
      description
    Status
      statusCode
    Relationships
      issuedInCountry
      verifiedByUser
      hasPreviousVersion
      hasNextVersion
    Lifecycle
      DRAFT
      ACTIVE
      PENDING_VERIFICATION
      VERIFIED
      EXPIRED
      ARCHIVED
      DELETED
```

**Design Rationale**:
- **Polymorphic Owner**: Same entity for Worker, Employee, Contract, LegalEntity, BusinessUnit documents
- **VN Compliance**: Support for VN identity documents (CCCD, CMND, BHXH)
- **Verification Workflow**: PENDING_VERIFICATION → VERIFIED
- **Version Control**: previousVersion → nextVersion chain
- **Retention Policy**: retentionDate for compliance

---

## 2. Attributes

[Attribute tables omitted for brevity - similar structure to previous ontologies]

---

## 3. Relationships

```mermaid
erDiagram
    Country ||--o{ Document : hasDocuments
    User ||--o{ Document : verifiedDocuments
    Document ||--o| Document : hasNextVersion
    Worker ||--o{ Document : "hasDocuments (polymorphic)"
    Employee ||--o{ Document : "hasDocuments (polymorphic)"
    Contract ||--o{ Document : "hasDocuments (polymorphic)"
    LegalEntity ||--o{ Document : "hasDocuments (polymorphic)"
    
    Document {
        string id PK
        enum ownerType
        string ownerId FK
        string documentTypeCode
        string documentName
        string documentNumber
        string fileUrl
        date issueDate
        date expiryDate
        enum statusCode
    }
```

---

## 4. Lifecycle

[Lifecycle diagram omitted for brevity]

---

## 5. Business Rules Reference

### VN Document Types

**Identity Documents**:
| Code | VN Name | Description | Retention |
|------|---------|-------------|-----------|
| CCCD | Căn cước công dân | Citizen ID (12-digit) | Employment + 5 years |
| CMND | Chứng minh nhân dân | Old ID (9-digit) | Employment + 5 years |
| PASSPORT | Hộ chiếu | Passport | Employment duration |
| BIRTH_CERT | Giấy khai sinh | Birth certificate | Employment duration |

**Employment Documents**:
| Code | VN Name | Description | Retention |
|------|---------|-------------|-----------|
| LABOR_CONTRACT | Hợp đồng lao động | Labor contract | 10 years after termination |
| APPENDIX | Phụ lục hợp đồng | Contract appendix | 10 years |
| RESIGNATION | Đơn xin nghỉ việc | Resignation letter | 10 years |
| TERMINATION | Quyết định nghỉ việc | Termination decision | 10 years |

**Compliance Documents**:
| Code | VN Name | Description |
|------|---------|-------------|
| TAX_CODE | Mã số thuế cá nhân | Personal tax code |
| BHXH | Sổ BHXH | Social insurance book |
| BHYT | Thẻ BHYT | Health insurance card |
| WORK_PERMIT | Giấy phép lao động | Work permit (foreigners) |

---

*Document Status: APPROVED - Based on Oracle HCM, SAP SuccessFactors, Workday patterns*  
*VN Compliance: Document retention requirements per VN Labor Code*
