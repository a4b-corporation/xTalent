# 🔍 Ontology Gap Analysis Report

> **Module:** Core HR (CO)  
> **Date:** 2026-01-30 (Updated)  
> **Status:** ✅ RESOLVED  
> **Type:** Entity Comparison Analysis  
> **Method:** Morphological Analysis (Business Brainstorming Skill)

---

## 1. Executive Summary

Báo cáo này so sánh chi tiết giữa:
- **Entity Catalog (Research)**: Danh sách entities từ research benchmark với Oracle, SAP, Workday, MS Dynamics
- **Existing Ontology (Implementation)**: Các `*.onto.md` files đã được định nghĩa

### Status: All Critical Gaps Resolved ✅

| Priority | Entity | Initial Status | Resolution | Date |
|----------|--------|----------------|------------|------|
| **P0** | `Probation` | Missing | ⚠️ **DEPRECATED** - Use Contract fields + EmploymentRecord | 2026-01-30 |
| **P0** | `Identification` | Missing | ⚠️ **DEPRECATED** - Use Document with category IDENTIFICATION | 2026-01-30 |
| **P1** | `EmergencyContact` | Partial | ✅ **RESOLVED** - WorkerRelationship.isEmergency flag | 2026-01-30 |
| **P1** | `Grade` | Module boundary | ✅ **CONFIRMED** - Stays in TR module | 2026-01-30 |

### Key Design Decisions Made

| Decision | Resolution | Rationale |
|----------|------------|-----------|
| **Probation** | Use Contract fields, NOT separate entity | Probation is a PHASE in employee lifecycle, not an entity |
| **Identification** | Use Document with category IDENTIFICATION | Universal Document Registry eliminates duplication |
| **EmergencyContact** | Use WorkerRelationship.isEmergency | Emergency contact is a FLAG on relationship, not a contact type |
| **Document** | Universal Document Registry | Single entity for ALL document attachments with DMS integration |
| **WorkerRelationship** | Pure LINK entity | No PII duplication, all data on related Worker |
| **Contact** | Only PHONE/EMAIL types | No EMERGENCY_CONTACT type; emergency is relationship flag |

---

## 2. Resolution Details

### 2.1 Probation Entity → DEPRECATED ⚠️

**Original Gap:**
```yaml
gap_id: GAP-LIFECYCLE-001
entity: Probation
status: MISSING in Implementation
priority: P0
```

**Resolution: DEPRECATED (2026-01-30)**

Probation is a **PHASE in employee lifecycle**, not a separate entity. 

**New Design:**

| Aspect | Implementation |
|--------|---------------|
| **Probation dates** | `Contract.probationStartDate`, `probationEndDate`, `probationDays` |
| **Salary rule (85%)** | `Contract.probationSalaryPercentage` (min 85, max 100) |
| **Evaluation** | `Contract.probationEvaluationResult`, `probationEvaluationDate`, `probationEvaluatedById` |
| **Events** | `EmploymentRecord.record_type` = PROBATION_START, PROBATION_PASS, PROBATION_FAIL |
| **Separate contract** | `Contract.contractTypeCode = PROBATION_CONTRACT` |

**Contract.onto.md Updated Fields:**
```yaml
# === PROBATION (VN Labor Code 2019 Điều 25-27) ===
- probationStartDate: date
- probationEndDate: date
- probationDays: integer (max 180/60/30/6 by job type)
- probationSalaryPercentage: decimal (min 85, max 100)
- probationEvaluationResult: enum [PASSED, FAILED, EXTENDED, RESIGNED, PENDING]
- probationEvaluationDate: date
- probationEvaluatedById: string (FK Employee)
```

**File Status:**
- `core/Probation.onto.md` → **status: deprecated**
- `core/Contract.onto.md` → **UPDATED with probation fields**

---

### 2.2 Identification Entity → DEPRECATED ⚠️

**Original Gap:**
```yaml
gap_id: GAP-PERSON-001
entity: Identification
status: MISSING in Implementation
priority: P0
```

**Resolution: DEPRECATED (2026-01-30)**

Identification is handled by **Document entity** with `documentCategoryCode = IDENTIFICATION`.

**New Design - Universal Document Registry:**

| Research Attribute | Document Mapping |
|--------------------|------------------|
| document_type (CCCD/PASSPORT) | `Document.documentTypeCode` |
| document_number | `Document.documentNumber` (PII, encrypted) |
| issue_date | `Document.issueDate` |
| expiry_date | `Document.expiryDate` |
| issue_place | `Document.issuingAuthority` |
| verification_status | `Document.statusCode` (VERIFIED state) |
| used_for_bhxh | `Document.usedForBhxh` |
| used_for_tax | `Document.usedForTax` |
| work_permit_details | `Document.metadata` (JSONB) |

**Document.onto.md v2.0.0 - Universal Registry:**
```yaml
documentCategoryCode:
  - IDENTIFICATION     # CCCD, Passport, Work Permit, Visa
  - CONTRACT           # Labor Contract, Appendix, Renewal
  - COMPLIANCE         # BHXH Reg, Tax Code
  - CERTIFICATE        # Degrees, Licenses
  - PERSONAL           # Photo, CV
  - ADMINISTRATIVE     # Resignation, Transfer, Disciplinary

documentTypeCode (for IDENTIFICATION):
  - CCCD              # 12 digits
  - CMND              # 9 digits (legacy)
  - PASSPORT          # VN: B1234567
  - WORK_PERMIT       # For foreigners
  - VISA              # Entry visa
  - DRIVER_LICENSE    # Giấy phép lái xe
  - BHXH_BOOK         # Sổ BHXH
```

**Benefits:**
- Single source of truth for ALL documents
- Unified DMS integration (storageType, externalDocId)
- No attribute duplication
- Consistent verification workflow

**File Status:**
- `person/Identification.onto.md` → **status: deprecated**
- `person/Document.onto.md` → **REWRITTEN as Universal Document Registry v2.0.0**

---

### 2.3 EmergencyContact → RESOLVED ✅

**Original Gap:**
```yaml
gap_id: GAP-PERSON-002
entity: EmergencyContact
status: Partial (in Contact.onto.md)
priority: P1
```

**Resolution: Use WorkerRelationship.isEmergency (2026-01-30)**

Emergency contact is a **FLAG on WorkerRelationship**, not a contact type.

**Old Design (Rejected):**
```yaml
Contact:
  contactTypeCode: [PHONE, EMAIL, EMERGENCY_CONTACT]  # ❌ Wrong
  emergencyContactName: ...
  emergencyRelationship: ...
  emergencyPhone: ...
```

**New Design (Implemented):**
```yaml
WorkerRelationship:
  workerId: "worker-a"           # Employee
  relatedWorkerId: "worker-b"    # Emergency contact person
  relationCode: "SPOUSE"
  isEmergency: true              # ✅ FLAG
  emergencyPriority: 1

# To get emergency contact phone:
# 1. Query WorkerRelationship WHERE workerId = A AND isEmergency = true
# 2. Get relatedWorkerId = B
# 3. Fetch Worker B's Contact records (PHONE type)
```

**Benefits:**
- No PII duplication (related person is a Worker with own Contact)
- Clean relationship model
- Emergency person can be reused (e.g., spouse is also dependent)

**File Status:**
- `person/Contact.onto.md` → **REFACTORED (removed EMERGENCY_CONTACT type) v2.0.0**
- `person/worker-relationship.onto.md` → **REFACTORED (pure LINK, isEmergency flag) v2.0.0**

---

### 2.4 Grade Module Boundary → CONFIRMED ✅

**Original Decision:**
```yaml
decision_id: DEC-GRADE-001
topic: Grade entity ownership
status: NEEDS DISCUSSION
```

**Resolution: Grade stays in Total Rewards (TR) module**

| Vendor | Grade Location |
|--------|---------------|
| Oracle | Core HR |
| SAP | Compensation |
| Workday | Compensation |
| **xTalent** | **Total Rewards (TR)** |

**Rationale:**
- Grade is primarily about salary ranges and compensation
- Core HR references Grade via FK, doesn't own it
- Aligns with SAP/Workday approach

**Action:** Update entity-catalog.md to note Grade is in TR module.

---

## 3. Updated Ontology Structure

### 3.1 Current Implementation (After Refactoring)

```
02.ontology/
├── core/
│   ├── Assignment.onto.md        ✅ Active
│   ├── Contract.onto.md          ✅ UPDATED (probation fields added)
│   ├── ContractTemplate.onto.md  ✅ Active
│   ├── Employee.onto.md          ✅ Active
│   ├── Probation.onto.md         ⚠️ DEPRECATED
│   ├── WorkRelationship.onto.md  ✅ Active
│   └── Worker.onto.md            ✅ Active
│
├── person/
│   ├── BankAccount.onto.md       ✅ Active
│   ├── Contact.onto.md           ✅ REFACTORED v2.0.0 (no EMERGENCY type)
│   ├── Document.onto.md          ✅ REWRITTEN v2.0.0 (Universal Registry)
│   ├── Identification.onto.md    ⚠️ DEPRECATED
│   ├── position.onto.md          ✅ Active
│   ├── worker-qualification.onto.md ✅ Active
│   └── worker-relationship.onto.md  ✅ REFACTORED v2.0.0 (pure LINK)
│
├── jobs/                          ✅ Active (9 files)
├── org/                           ✅ Active (3 files)
├── location/                      ✅ Active (5 files)
├── skill/                         ✅ Active (4 files)
├── compensation-basis.onto.md     ✅ Active
├── worker-competency.link.md      ✅ Active
└── worker-skill.link.md           ✅ Active
```

### 3.2 Entity Counts

| Category | Active | Deprecated | Total |
|----------|--------|------------|-------|
| **Core** | 6 | 1 (Probation) | 7 |
| **Person** | 5 | 1 (Identification) | 6 |
| **Jobs** | 9 | 0 | 9 |
| **Org** | 3 | 0 | 3 |
| **Location** | 5 | 0 | 5 |
| **Skill** | 4 | 0 | 4 |
| **Root Level** | 3 | 0 | 3 |
| **Total** | 35 | 2 | 37 |

---

## 4. Key Design Principles Established

### 4.1 Document as Universal Registry

```
Document = Metadata Registry + DMS Link

Document stores:
- Metadata (type, dates, verification)
- Link to external storage (DMS, S3, SharePoint)

Document replaces:
- Identification entity ❌
- Separate contract attachment handling ❌
- Certificate/qualification file storage ❌
```

### 4.2 WorkerRelationship as Pure LINK

```
WorkerRelationship = Link + Flags (NO PII)

Before: Stored fullName, phone, email inline
After:  Only stores link endpoints + flags

Flags:
- isEmergency (emergency contact)
- isDependentFlag (tax dependent)
- isBeneficiaryFlag (benefits)
- isVisaSponsorFlag (work permit)

All PII lives on related Worker's records
```

### 4.3 Contact for Communication Only

```
Contact = Communication method for Worker

Types:
- PHONE (mobile, home, work, fax)
- EMAIL (personal, work)

NOT a contact type:
- EMERGENCY_CONTACT → Use WorkerRelationship.isEmergency
```

### 4.4 Probation as Contract Phase

```
Probation = Phase in Contract, NOT separate entity

Tracking: Contract.probationStartDate/EndDate/Days
Salary:   Contract.probationSalaryPercentage (min 85%)
Events:   EmploymentRecord.record_type = PROBATION_*
Types:    Contract.contractTypeCode = PROBATION_CONTRACT
```

---

## 5. Remaining Items (Lower Priority)

### 5.1 Design Decisions (Deferred)

| Decision | Status | Target |
|----------|--------|--------|
| Person vs Worker naming | Keep Worker | Document in ADR |
| Organization entity | Defer | H2 (Enterprise) |
| Department vs BusinessUnit | Use BU type | Done |
| CostCenter entity | Review | H2 |
| EmploymentRecord entity | Review | Future |

### 5.2 Documentation Updates

| Document | Status | Notes |
|----------|--------|-------|
| entity-catalog.md | TODO | Add cross-references, note Grade in TR |
| solution-blueprint.md | TODO | Note ontology alignment completed |
| ADR | TODO | Create ADR for design decisions |

---

## 6. Updated Entity Mapping Table

| # | Research Entity | Implementation File | Status | Action | Date |
|---|-----------------|---------------------|--------|--------|------|
| 1 | Person | Worker.onto.md | ✅ | Keep Worker naming | 2026-01-30 |
| 2 | Employee | Employee.onto.md | ✅ | None | - |
| 3 | Dependent | worker-relationship.onto.md | ✅ | isDependentFlag | 2026-01-30 |
| 4 | EmergencyContact | worker-relationship.onto.md | ✅ | isEmergency flag | 2026-01-30 |
| 5 | Organization | - | ⏸️ | Defer to H2 | - |
| 6 | LegalEntity | LegalEntity.onto.md | ✅ | None | - |
| 7 | BusinessUnit | BusinessUnit.onto.md | ✅ | None | - |
| 8 | Department | BusinessUnit (type) | ✅ | Use BU type | - |
| 9 | CostCenter | - | ⏸️ | Review | - |
| 10 | Position | position.onto.md | ✅ | None | - |
| 11 | Job | job.onto.md | ✅ | None | - |
| 12 | JobFamily | JobTaxonomy.onto.md | ✅ | None | - |
| 13 | JobLevel | job-level.onto.md | ✅ | None | - |
| 14 | Grade | (in TR module) | ✅ | Confirmed in TR | 2026-01-30 |
| 15 | WorkAssignment | Assignment.onto.md | ✅ | None | - |
| 16 | EmploymentRecord | - | ⏸️ | Review | - |
| 17 | Contract | Contract.onto.md | ✅ | Probation fields added | 2026-01-30 |
| 18 | Probation | ~~Probation.onto.md~~ | ⚠️ | **DEPRECATED** | 2026-01-30 |
| 19 | Address | Address.onto.md | ✅ | None | - |
| 20 | BankAccount | BankAccount.onto.md | ✅ | None | - |
| 21 | Identification | ~~Identification.onto.md~~ | ⚠️ | **DEPRECATED** (use Document) | 2026-01-30 |
| 22 | Education | worker-qualification.onto.md | ✅ | None | - |
| 23 | Skill | skill.onto.md | ✅ | None | - |
| 24 | EmployeeSkill | worker-skill.link.md | ✅ | None | - |
| 25 | Document | Document.onto.md | ✅ | **Universal Registry v2.0.0** | 2026-01-30 |
| 26 | DocumentType | Document.documentTypeCode | ✅ | Enum in Document | 2026-01-30 |
| 27 | Location | location.onto.md | ✅ | None | - |

### Legend

- ✅ = Resolved / Active
- ⚠️ = Deprecated
- ⏸️ = Deferred / Lower priority

---

## 7. Conclusion

**All P0 critical gaps have been resolved** through design decisions that prioritize:

1. **No duplication** - Data lives in one place only
2. **Conceptual clarity** - Entities represent THINGS, not PHASES or FLAGS
3. **Universal patterns** - Document Registry, Pure LINK relationships
4. **VN Compliance** - Probation rules in Contract, CCCD in Document

The ontology is now consistent and ready for implementation.

---

*Report generated: 2026-01-30*  
*Updated: 2026-01-30 (All critical gaps RESOLVED)*  
*Method: Morphological Analysis (Business Brainstorming)*  
*Status: ✅ COMPLETE*
