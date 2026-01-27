---
entity: Document
version: "1.0.0"
status: approved
created: 2026-01-25
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# Schema Standards: Document

## 1. Summary

The **Document** entity manages file attachments and documents associated with employees, contracts, organizations, and other HR entities. This includes identity documents, contracts, certificates, performance reviews, and other HR-related files. All major vendors support document management with categorization, versioning, and access control.

**Confidence**: HIGH - Based on 3 major HCM vendors

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Entity**: `HR_DOCUMENTS_OF_RECORD` + Attachments

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| DOCUMENT_ID | Number | Y | Unique identifier |
| DOCUMENT_TYPE | Reference | Y | Document category |
| DOCUMENT_NUMBER | String | N | Document number |
| DOCUMENT_NAME | String | Y | Display name |
| PERSON_ID | Number | Y | FK to Person |
| ISSUE_DATE | Date | N | When issued |
| EXPIRY_DATE | Date | N | Expiration date |
| ISSUING_AUTHORITY | String | N | Issuing body |
| ISSUING_COUNTRY | String | N | Country of issue |
| ATTACHMENT_ID | Number | N | File attachment |
| STATUS | Enum | Y | Active/Expired |

---

### 2.2 SAP SuccessFactors

**Entity**: `Attachment` + Document Info (various)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| attachmentId | String | Y | Unique identifier |
| fileName | String | Y | File name |
| fileExtension | String | Y | Extension |
| fileContent | Binary | Y | File content |
| mimeType | String | Y | MIME type |
| moduleCategory | Enum | Y | Category |
| userId | String | N | Owning user |
| externalCode | String | N | External reference |
| createdDate | DateTime | Y | Upload date |

---

### 2.3 Workday

**Entity**: `Worker_Document_Data`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Document_ID | String | Y | Unique identifier |
| Document_Category | Reference | Y | Category |
| Document_Name | String | Y | Display name |
| Worker_Reference | Reference | Y | Owning worker |
| Document_Date | Date | N | Document date |
| Expiration_Date | Date | N | Expiry date |
| Issued_Date | Date | N | Issue date |
| Issuing_Authority | String | N | Issuer |
| Country_Reference | Reference | N | Country |
| Filename | String | Y | Attached file name |
| Comment | String | N | Notes |

---

## 3. Common Pattern Analysis

### Universal Attributes (3/3 vendors)
| Attribute | Oracle | SAP | Workday | Type |
|-----------|--------|-----|---------|------|
| Document ID | ✓ | ✓ | ✓ | uuid |
| Document Name | ✓ | ✓ | ✓ | string |
| Document Type/Category | ✓ | ✓ | ✓ | enum |
| Owner (Person/Entity) | ✓ | ✓ | ✓ | reference |
| File Attachment | ✓ | ✓ | ✓ | binary/ref |
| Created Date | ✓ | ✓ | ✓ | datetime |

---

## 4. Canonical Schema: Document

### Required Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique identifier | Universal |
| documentType | reference | FK to DocumentType | Universal |
| documentName | string(200) | Display name | Universal |
| owner | reference | FK to Person/Org | Universal |
| ownerType | enum | PERSON/ORGANIZATION/CONTRACT | Best practice |
| status | enum | Document status | Universal |

### Recommended Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| documentNumber | string(100) | Document ID/number | Oracle, Workday |
| issueDate | date | When document was issued | 3/3 vendors |
| expiryDate | date | Expiration date | 3/3 vendors |
| issuingAuthority | string(200) | Issuing body | Oracle, Workday |
| issuingCountry | reference | Country of issue | Oracle, Workday |
| description | text | Document description | Best practice |
| fileName | string(255) | Original file name | 3/3 vendors |
| fileUrl | string(500) | Storage URL/path | Best practice |
| fileSize | number | File size in bytes | Best practice |
| mimeType | string(100) | MIME type | SAP |
| version | number | Document version | Best practice |

### Optional Attributes
| Attribute | Type | When to Include |
|-----------|------|-----------------|
| verifiedDate | date | Verification workflows |
| verifiedBy | reference | Verification tracking |
| confidentialityLevel | enum | Access control |
| retentionDate | date | Document retention |
| digitalSignature | string | Signed documents |
| checksum | string | File integrity |

---

## 5. Document Categories

### Identity Documents
| Code | VN Name | Description |
|------|---------|-------------|
| CCCD | Căn cước công dân | Citizen ID (12-digit) |
| CMND | Chứng minh nhân dân | Old ID (9-digit) |
| PASSPORT | Hộ chiếu | Passport |
| BIRTH_CERT | Giấy khai sinh | Birth certificate |
| MARRIAGE_CERT | Giấy đăng ký kết hôn | Marriage certificate |

### Employment Documents
| Code | VN Name | Description |
|------|---------|-------------|
| LABOR_CONTRACT | Hợp đồng lao động | Labor contract |
| APPENDIX | Phụ lục hợp đồng | Contract appendix |
| RESIGNATION | Đơn xin nghỉ việc | Resignation letter |
| TERMINATION | Quyết định nghỉ việc | Termination decision |
| JOB_OFFER | Thư mời làm việc | Offer letter |

### Qualification Documents
| Code | VN Name | Description |
|------|---------|-------------|
| DEGREE | Bằng cấp | Degree/Diploma |
| CERTIFICATE | Chứng chỉ | Certificate |
| LICENSE | Giấy phép hành nghề | Professional license |
| TRAINING | Chứng nhận đào tạo | Training certificate |

### Compliance Documents
| Code | VN Name | Description |
|------|---------|-------------|
| TAX_CODE | Mã số thuế cá nhân | Personal tax code |
| BHXH | Sổ BHXH | Social insurance book |
| BHYT | Thẻ BHYT | Health insurance card |
| WORK_PERMIT | Giấy phép lao động | Work permit (foreigners) |

---

## 6. Lifecycle States

| State | Description |
|-------|-------------|
| DRAFT | Document being prepared |
| ACTIVE | Currently valid |
| PENDING_VERIFICATION | Awaiting verification |
| VERIFIED | Verified as authentic |
| EXPIRED | Past expiry date |
| ARCHIVED | Archived for retention |
| DELETED | Soft deleted |

---

## 7. Relationships

| Relationship | Target | Cardinality | Description |
|--------------|--------|-------------|-------------|
| owner | Person/Org/Contract | N:1 | Document owner |
| documentType | DocumentType | N:1 | Category reference |
| issuingCountry | Country | N:1 | Country of issue |
| verifiedBy | User | N:1 | Verifier |
| previousVersion | Document | N:1 | Version chain |

---

## 8. Local Adaptations (Vietnam)

### Required Documents by Law
| Document | Requirement | Retention |
|----------|-------------|-----------|
| CCCD/CMND | Copy required | Employment duration + 5 years |
| Labor Contract | Original signed | 10 years after termination |
| BHXH Book | Return on termination | N/A |
| Tax Code | Required for payroll | Employment duration |

### Document Verification
- CCCD verification via national database
- Degree verification via education ministry
- Work permit verification for foreigners

### VN-Specific Document Types
| Type | Description |
|------|-------------|
| HO_KHAU | Household registration book |
| SO_LAO_DONG | Labor book |
| GIAY_KHAM_SK | Health examination certificate |
| LY_LICH_TU_PHAP | Judicial record |

---

## 9. Security Considerations

### Access Control
- Personal documents: Owner + HR only
- Contracts: Owner + HR + Legal
- Salary documents: Owner + HR + Finance

### Data Protection
- Encrypt sensitive documents at rest
- Audit trail for all access
- GDPR/VN data privacy compliance

---

*Document Status: APPROVED*
