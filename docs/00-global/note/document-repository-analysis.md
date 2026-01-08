# Document Repository Feature Analysis & Recommendation

## Domain Research Summary

### Industry Analysis: Document Management in Enterprise HCM

#### 1. Workday - "Workday Docs"
- **Centralized Storage**: "Workday Drive" - single repository for all HR documents
- **Employee Personnel File**: Electronic file containing offer letters, performance reviews, compliance forms
- **Key Features**:
  - Role-based access control (RBAC)
  - Advanced search with keywords and metadata
  - Version control with history
  - Automated document generation from Workday data
  - eSign integration (DocuSign, Adobe)
  - Audit trails for compliance
- **Partner Solutions**: Kainos EDM, Softdocs for extended capabilities

#### 2. SAP SuccessFactors
- **Personal Documents Segment**: Part of Employee Central Compound API
- **Third-party integrations**: ePFile, Strato Storage
- **Key Features**:
  - Document classification with categories/subcategories
  - Access control by document type and role
  - Search and retrieval
  - Integration with SAP Document Management Service
- **Focus**: Centralized access eliminating multiple DMS systems

#### 3. Oracle HCM Cloud
- **Document of Record (DOR)**: Both employee and employer documents
- **Universal Content Management (UCM)**: Backend file storage
- **Key Features**:
  - Employee uploads: visas, passports, degrees, certificates
  - Employer shares: payslips, tax docs, compensation letters
  - Granular access control by document type and role
  - Workflow automation for approvals
  - Categories and subcategories for classification
  - Comprehensive audit trails

---

## Analysis: Document Repository Feature for xTalent

### Current State
- **Entity exists**: `Document` entity defined in ontology (01-person/document.entity.yaml)
- **Feature exists**: `FEAT-CO-003: Manage Worker Documents` - manages documents at Worker level
- **Pattern**: Documents are attached to specific entities (Worker, Contract, Dependent)

### Proposed Feature: Document Repository (Kho Tài Liệu)
**Concept**: A "flat" view where Document is the primary entity, with metadata linking to related entities (Employee, Contract, Dependent, etc.)

### Use Cases Addressed

| Use Case | Current Approach | With Document Repository |
|----------|------------------|-------------------------|
| Find all expired passports | Navigate to each worker → documents → filter | Search: type=passport, status=expired |
| Audit all contracts signed in Q4 | Query contracts → get document links | Search: category=contract, date=Q4 |
| Find document by number | Unknown which entity has it | Search: document_number=XXX |
| Compliance: documents expiring in 30 days | Daily job on each entity | Dashboard: expiring soon |

---

## Recommendation: ✅ **SHOULD BUILD**

### Reasons FOR this feature:

1. **Industry Standard**: All major HCM vendors (Workday, SAP, Oracle) provide centralized document repositories alongside entity-attached documents

2. **Super User/Admin Efficiency**: HR Admins and Compliance Officers need cross-cutting views:
   - "All documents expiring in 30 days"
   - "All identity documents for legal entity X"
   - "All contracts signed by employee Y across history"

3. **Audit & Compliance**: Centralized view for:
   - Document retention policies
   - Access auditing
   - Expiry tracking
   - Mass document operations

4. **Search & Discovery**: Quick document lookup without knowing source entity

5. **Complementary (not replacement)**: Works WITH existing entity-attached documents, not replacing them

### Architecture Recommendation

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Document Repository Feature                      │
│                   (Flat view, Document as primary)                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    Document Entity                            │  │
│  │  ─────────────────────────────────────────────────────────── │  │
│  │  Core Attributes:                                             │  │
│  │  - documentId (PK)                                            │  │
│  │  - documentType (IDENTITY | CONTRACT | CERTIFICATE | ...)     │  │
│  │  - documentCategory                                           │  │
│  │  - documentNumber                                             │  │
│  │  - title                                                      │  │
│  │  - issueDate, expiryDate                                      │  │
│  │  - issuingAuthority                                           │  │
│  │  - fileUrl (attached file)                                    │  │
│  │  - status (VALID | EXPIRED | PENDING_VERIFICATION)            │  │
│  │                                                               │  │
│  │  Metadata Links (Source References):                          │  │
│  │  - sourceType: WORKER | EMPLOYEE | CONTRACT | DEPENDENT       │  │
│  │  - sourceId: UUID of source entity                            │  │
│  │  - workerId: always link to worker (for cross-reference)      │  │
│  │  - legalEntityId: for multi-LE scenarios                      │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  Access: Super User / HR Admin / Compliance Officer                 │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                │ Links to
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Source Entities (Existing)                        │
├──────────────────┬──────────────────┬──────────────────────────────┤
│     Worker       │    Contract      │        Dependent             │
│   (FEAT-CO-003)  │   (attachments)  │       (attachments)          │
└──────────────────┴──────────────────┴──────────────────────────────┘
```

### Feature Scope

**In Scope**:
- List all documents with search, filter, sort
- View document details + source entity link
- Quick preview (PDF, images)
- Bulk operations (mark as verified, export list)
- Expiry dashboard/alerts
- Access audit trail

**Out of Scope** (handled by source features):
- Document upload (done via Worker, Contract, etc.)
- Document deletion (governed by source entity)
- Document editing (metadata from source)

### Proposed Feature ID & Placement

- **ID**: FEAT-CO-017
- **Sub-module**: 05-master-data (cross-cutting utility)
- **Priority**: MEDIUM
- **Phase**: 2 (after core employment features)

---

## Conclusion

**Document Repository là tính năng NÊN có** vì:
1. Đây là tiêu chuẩn ngành (Workday, SAP, Oracle đều có)
2. Giải quyết nhu cầu thực tế của Super User/HR Admin
3. Bổ sung (không thay thế) tính năng hiện có
4. Hỗ trợ audit, compliance, và retention policies

**Recommendation**: Proceed with building `document-repository.feat.md`
