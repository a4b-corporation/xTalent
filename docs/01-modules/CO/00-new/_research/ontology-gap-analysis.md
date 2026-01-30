# 🔍 Ontology Gap Analysis Report

> **Module:** Core HR (CO)  
> **Date:** 2026-01-30  
> **Type:** Entity Comparison Analysis  
> **Method:** Morphological Analysis (Business Brainstorming Skill)

---

## 1. Executive Summary

Báo cáo này so sánh chi tiết giữa:
- **Entity Catalog (Research)**: Danh sách entities từ research benchmark với Oracle, SAP, Workday, MS Dynamics
- **Existing Ontology (Implementation)**: Các `*.onto.md` files đã được định nghĩa

### Key Findings

| Dimension | Research | Implementation | Gap |
|-----------|----------|----------------|-----|
| **Total Entities** | 27 | 38 | +11 (Impl richer) |
| **Core Entities** | 15 | 25 | +10 |
| **Missing in Impl** | 3 | - | 3 gaps to add |
| **Missing in Research** | - | 14 | 14 to reconcile |
| **Module Boundary Differences** | 2 | - | 2 decisions |

### Critical Gaps (Action Required)

| Priority | Entity | Status | Recommendation |
|----------|--------|--------|----------------|
| **P0** | `Probation` | Missing in Impl | ADD - Vietnam compliance |
| **P0** | `Identification` | Missing in Impl | ADD - CCCD/CMND/Passport |
| **P1** | `Grade` | In TR, not CO | DISCUSS - Module boundary |
| **P1** | `EmergencyContact` | Missing in Impl | ADD or merge with `Contact` |

---

## 2. Methodology

### 2.1 Analysis Approach

Sử dụng **Morphological Analysis** để map entities theo các dimensions:

| Dimension | Categories |
|-----------|------------|
| **Domain** | Person, Organization, Position, Lifecycle, Document |
| **Source** | Research Only, Impl Only, Both |
| **Granularity** | Atomic, Composite, Link |
| **Module Owner** | Core HR, Total Rewards, Payroll, Cross-cutting |

### 2.2 Data Sources

**Research Entity Catalog:**
- `/Users/.../CO/00-new/_research/entity-catalog.md`
- 27 entities theo benchmark vendors

**Implementation Ontology:**
- `/Users/.../CO/00-new/02.ontology/` (6 subdirectories)
- 38 ontology files (*.onto.md + *.link.md)

---

## 3. Detailed Comparison

### 3.1 Implementation Ontology Inventory

```
02.ontology/
├── core/
│   ├── Assignment.onto.md          → WorkAssignment equivalent
│   ├── Contract.onto.md            ✓ Match
│   ├── ContractTemplate.onto.md    + Extra (not in research)
│   ├── Employee.onto.md            ✓ Match (partial)
│   ├── WorkRelationship.onto.md    + Extra (not in research)
│   └── Worker.onto.md              → Combines Person+Employee?
│
├── jobs/
│   ├── JobTaxonomy.onto.md         + Extra (taxonomy mgmt)
│   ├── JobTaxonomyMap.onto.md      + Extra
│   ├── TaxonomyTree.onto.md        + Extra
│   ├── TaxonomyXMap.onto.md        + Extra
│   ├── job-level.onto.md           ✓ Match → JobLevel
│   ├── job-profile.onto.md         + Extra (combines Job+Position?)
│   ├── job-profile-skill.link.md   + Extra (link type)
│   └── job.onto.md                 ✓ Match
│
├── location/
│   ├── Address.onto.md             ✓ Match
│   ├── admin-area.onto.md          + Extra (Vietnam admin hierarchy)
│   ├── location.onto.md            ✓ Match
│   ├── place.onto.md               + Extra (physical place)
│   └── work-location.onto.md       + Extra (work assignment loc)
│
├── org/
│   ├── BusinessUnit.onto.md        ✓ Match
│   ├── LegalEntity.onto.md         ✓ Match
│   └── LegalRepresentative.onto.md + Extra (person type)
│
├── person/
│   ├── BankAccount.onto.md         ✓ Match
│   ├── Contact.onto.md             ✓ Match (partial)
│   ├── Document.onto.md            ✓ Match
│   ├── position.onto.md            ✓ Match
│   ├── worker-qualification.onto.md + Extra → Education?
│   └── worker-relationship.onto.md  + Extra → Dependent?
│
├── skill/
│   ├── competency-category.onto.md  + Extra (H2 feature)
│   ├── competency.onto.md           + Extra (H2 feature)
│   ├── skill-category.onto.md       + Extra (H2 feature)
│   └── skill.onto.md                ✓ Match (H2)
│
├── compensation-basis.onto.md       → Should be in TR module
├── worker-competency.link.md        + Extra (link type)
└── worker-skill.link.md             + Extra (link type)
```

### 3.2 Side-by-Side Entity Comparison

#### 3.2.1 Person Domain

| Research Entity | Implementation File | Status | Notes |
|-----------------|---------------------|--------|-------|
| `Person` | `Worker.onto.md` | ⚠️ DIFFERENT | Impl uses "Worker" as umbrella term |
| `Employee` | `Employee.onto.md` | ✓ MATCH | |
| `Dependent` | `worker-relationship.onto.md` | ⚠️ PARTIAL | Impl has broader relationship types |
| `EmergencyContact` | `Contact.onto.md` | ⚠️ PARTIAL | Impl combines all contact types |
| `Address` | `Address.onto.md` | ✓ MATCH | |
| `BankAccount` | `BankAccount.onto.md` | ✓ MATCH | |
| `Identification` | ❌ MISSING | 🔴 GAP | CCCD, Passport, Work Permit |
| `Education` | `worker-qualification.onto.md` | ⚠️ PARTIAL | Impl has broader qualifications |

**Gap Analysis:**

```yaml
gap_id: GAP-PERSON-001
entity: Identification
status: MISSING in Implementation
priority: P0
impact: HIGH

rationale: |
  - CCCD/CMND là bắt buộc cho compliance
  - Work Permit tracking cho foreign workers
  - BHXH registration cần số CCCD
  
recommendation: |
  CREATE new file: person/Identification.onto.md
  OR EXTEND: Document.onto.md với document_type = IDENTIFICATION
  
dependencies:
  - Employee (has many Identifications)
  - Document (Identification is-a Document?)
```

#### 3.2.2 Organization Domain

| Research Entity | Implementation File | Status | Notes |
|-----------------|---------------------|--------|-------|
| `Organization` | ❌ MISSING | ⚠️ DESIGN | Impl starts at LegalEntity |
| `LegalEntity` | `LegalEntity.onto.md` | ✓ MATCH | |
| `BusinessUnit` | `BusinessUnit.onto.md` | ✓ MATCH | |
| `Department` | ❌ MISSING | ⚠️ DESIGN | May be in BusinessUnit? |
| `CostCenter` | ❌ MISSING | ⚠️ DESIGN | May be separate module |
| `Location` | `location.onto.md` | ✓ MATCH | Plus extra granularity |

**Design Decision Required:**

```yaml
decision_id: DEC-ORG-001
topic: Organization Hierarchy Levels
status: NEEDS DISCUSSION

research_model:
  Organization → LegalEntity → BusinessUnit → Department

implementation_model:
  LegalEntity → BusinessUnit (implicit Department?)

options:
  A: Add explicit Department.onto.md
  B: Department is-a BusinessUnit (type field)
  C: Department is configuration, not entity

recommendation: Option B
  - BusinessUnit with type enum: DIVISION | DEPARTMENT | TEAM
  - Reduces entity proliferation
  - Matches SAP approach
```

#### 3.2.3 Position/Job Domain

| Research Entity | Implementation File | Status | Notes |
|-----------------|---------------------|--------|-------|
| `Position` | `position.onto.md` | ✓ MATCH | |
| `Job` | `job.onto.md` | ✓ MATCH | |
| `JobFamily` | `JobTaxonomy.onto.md` | ⚠️ RICHER | Impl has full taxonomy tree |
| `JobLevel` | `job-level.onto.md` | ✓ MATCH | |
| `Grade` | ❌ IN TR | 🟡 BOUNDARY | Research puts in CO, Impl in TR |

**Implementation Extras (Not in Research):**

| Implementation Entity | Purpose | Verdict |
|-----------------------|---------|---------|
| `JobTaxonomy` | Multi-level job classification | ✅ KEEP - Good for large orgs |
| `JobTaxonomyMap` | Mapping between taxonomies | ✅ KEEP - Supports migrations |
| `TaxonomyTree` | Generic tree structure | ⚠️ REVIEW - May be infra, not domain |
| `TaxonomyXMap` | Cross-taxonomy mapping | ✅ KEEP - Good for integrations |
| `job-profile.onto.md` | Combines Job + Position aspects | ⚠️ REVIEW - May overlap |

**Module Boundary Decision:**

```yaml
decision_id: DEC-GRADE-001
topic: Grade entity ownership
status: NEEDS DISCUSSION

research_position:
  - Grade belongs to Core HR
  - Links Position to Salary Range
  - Basic HR structure

implementation_position:
  - Grade belongs to Total Rewards
  - Links to Compensation Plans
  - Salary admin ownership

analysis:
  - Oracle: Grade in Core HR
  - SAP: Grade in Compensation
  - Workday: Grade in Compensation
  
recommendation: 
  - Keep Grade in Total Rewards (aligns with SAP/Workday)
  - Core HR references Grade (FK), doesn't own it
  - Update entity-catalog.md to remove Grade from CO
```

#### 3.2.4 Worker Lifecycle Domain

| Research Entity | Implementation File | Status | Notes |
|-----------------|---------------------|--------|-------|
| `WorkAssignment` | `Assignment.onto.md` | ✓ MATCH | Different naming |
| `EmploymentRecord` | ❌ MISSING | ⚠️ DESIGN | May be event log |
| `Contract` | `Contract.onto.md` | ✓ MATCH | |
| `Probation` | ❌ MISSING | 🔴 GAP | Vietnam compliance |

**Critical Gap:**

```yaml
gap_id: GAP-LIFECYCLE-001
entity: Probation
status: MISSING in Implementation
priority: P0
impact: HIGH

rationale: |
  Vietnam Labor Law requires:
  - Max probation: 6/30/60/180 days by job type
  - Min salary: 85% of formal
  - Evaluation before confirmation
  - 3-day termination notice
  
  This is NOT just a Contract attribute - needs:
  - Evaluation workflow
  - Auto-confirmation logic
  - Salary adjustment on pass

recommendation: |
  CREATE new file: core/Probation.onto.md
  
  Attributes:
  - employee_id (FK)
  - contract_id (FK) 
  - start_date
  - end_date
  - salary_percentage (min 85%)
  - status (IN_PROGRESS | PASSED | FAILED | EXTENDED)
  - evaluation_date
  - evaluation_result

dependencies:
  - Contract (probation is part of)
  - Employee (who is on probation)
  - Workflow (evaluation process)
```

**Implementation Extras:**

| Implementation Entity | Purpose | Verdict |
|-----------------------|---------|---------|
| `WorkRelationship.onto.md` | Employment relationship type | ✅ KEEP - Supports contractor/intern |
| `ContractTemplate.onto.md` | Reusable contract templates | ✅ KEEP - Good for automation |

#### 3.2.5 Document Domain

| Research Entity | Implementation File | Status | Notes |
|-----------------|---------------------|--------|-------|
| `Document` | `Document.onto.md` | ✓ MATCH | |
| `DocumentType` | ❌ MISSING | ⚠️ DESIGN | May be enum in Document |

#### 3.2.6 Skill Domain (H2 Features)

| Research Entity | Implementation File | Status | Notes |
|-----------------|---------------------|--------|-------|
| `Skill` | `skill.onto.md` | ✓ MATCH | |
| `EmployeeSkill` | `worker-skill.link.md` | ✓ MATCH | Link type |

**Implementation Extras (H2 Scope):**

| Implementation Entity | Purpose | Verdict |
|-----------------------|---------|---------|
| `skill-category.onto.md` | Skill hierarchy | ✅ KEEP - Good structure |
| `competency.onto.md` | Competency framework | ✅ KEEP - HR best practice |
| `competency-category.onto.md` | Competency hierarchy | ✅ KEEP |
| `worker-competency.link.md` | Competency assignment | ✅ KEEP |

---

## 4. Recommendations

### 4.1 Immediate Actions (P0)

#### 4.1.1 Create `Identification.onto.md`

```yaml
action: CREATE
file: 02.ontology/person/Identification.onto.md
priority: P0
effort: 1 day

reason: |
  Required for Vietnam compliance:
  - CCCD/CMND validation
  - Work Permit tracking
  - BHXH registration

structure:
  attributes:
    - identification_id: UUID
    - employee_id: FK(Employee)
    - document_type: CCCD | CMND | PASSPORT | WORK_PERMIT | BHXH_BOOK
    - document_number: String (encrypted)
    - issue_date: Date
    - expiry_date: Date (nullable for CCCD)
    - issue_place: String
    - verification_status: PENDING | VERIFIED | EXPIRED
    - document_file_id: FK(Document)
```

#### 4.1.2 Create `Probation.onto.md`

```yaml
action: CREATE
file: 02.ontology/core/Probation.onto.md
priority: P0
effort: 1 day

reason: |
  Vietnam Labor Law compliance:
  - Distinct entity with lifecycle
  - Evaluation workflow
  - Auto-confirmation business logic

structure:
  attributes:
    - probation_id: UUID
    - employee_id: FK(Employee)
    - contract_id: FK(Contract)
    - start_date: Date
    - end_date: Date
    - salary_percentage: Decimal (min 85)
    - status: IN_PROGRESS | PASSED | FAILED | EXTENDED
    - evaluation_date: Date
    - evaluation_result: EXCELLENT | GOOD | SATISFACTORY | UNSATISFACTORY
    - evaluated_by: FK(Employee)
```

### 4.2 Short-term Actions (P1)

#### 4.2.1 Clarify EmergencyContact vs Contact

```yaml
action: EXTEND or CREATE
current: Contact.onto.md
priority: P1
effort: 0.5 day

options:
  A: Add contact_category: EMERGENCY | WORK | PERSONAL to Contact
  B: Create separate EmergencyContact.onto.md

recommendation: Option A
  - Contact.onto.md already supports multiple types
  - Add priority_order for emergency contacts
  - Add is_primary flag
```

#### 4.2.2 Update entity-catalog.md

```yaml
action: UPDATE
file: _research/entity-catalog.md
priority: P1
effort: 0.5 day

changes:
  - Remove Grade from Core HR (belongs to TR)
  - Add cross-reference to TR Grade
  - Note that implementation has richer taxonomy model
```

### 4.3 Design Decisions Required

#### 4.3.1 Person vs Worker Naming

```yaml
decision: NAMING Convention
current_state: Research uses "Person", Impl uses "Worker"

analysis:
  - "Person" is more standard (Oracle, Workday use it)
  - "Worker" implies employment relationship
  - Current impl: Worker = Person + some Employee aspects

options:
  A: Rename Worker.onto.md → Person.onto.md (align with research)
  B: Keep Worker (Vietnam market, simpler mental model)
  C: Create Person, Worker extends Person (OO approach)

impact:
  - Option A: DB migration, API breaking change
  - Option B: Documentation only
  - Option C: Cleanest, but complexity

recommendation: Option B (keep current, document the decision)
  - Low priority change
  - Avoid breaking changes early
  - Document in ADR
```

#### 4.3.2 Organization vs LegalEntity Root

```yaml
decision: Org Hierarchy Root
current_state: Research has Organization → LegalEntity, Impl starts at LegalEntity

analysis:
  - Oracle: Organization is root (multi-company)
  - SAP: No explicit Organization (LegalEntity is root)
  - Workday: Organization is root
  - Vietnam reality: Most customers single LegalEntity

options:
  A: Add Organization.onto.md above LegalEntity
  B: Keep LegalEntity as root (simpler)
  C: Make Organization optional/virtual

recommendation: Option B (keep current)
  - Vietnam SME focus doesn't need multi-org
  - Can add Organization later (H2) for enterprise
  - LegalEntity already has parent_id for groups
```

---

## 5. Implementation Richness Analysis

### 5.1 Areas Where Implementation is Richer

| Area | Implementation Extra | Value | Keep? |
|------|---------------------|-------|-------|
| **Job Taxonomy** | 4 extra files | Supports complex classifications | ✅ Yes |
| **Location Hierarchy** | admin-area, place, work-location | Vietnam admin structure | ✅ Yes |
| **Skills/Competency** | Full framework (4 files) | Enterprise HR feature | ✅ Yes (H2) |
| **Contract Templates** | ContractTemplate.onto.md | Automation support | ✅ Yes |
| **Work Relationship** | WorkRelationship.onto.md | Contractor/intern types | ✅ Yes |
| **Legal Representative** | LegalRepresentative.onto.md | Vietnam compliance | ✅ Yes |
| **Worker Qualification** | worker-qualification.onto.md | Broader than Education | ✅ Yes |
| **Link Types** | 3 link files | Relationship modeling | ✅ Yes |

### 5.2 Areas Where Research is More Complete

| Area | Research Extra | Value | Add to Impl? |
|------|---------------|-------|--------------|
| **Identification** | Dedicated entity | Vietnam compliance | 🔴 Yes - P0 |
| **Probation** | Lifecycle entity | Vietnam compliance | 🔴 Yes - P0 |
| **EmergencyContact** | Dedicated entity | Safety/HR | 🟡 Extend Contact |
| **EmploymentRecord** | History entity | Audit trail | ⚠️ Review |
| **DocumentType** | Dedicated entity | Categorization | 🟡 Add as enum |

---

## 6. Summary & Action Items

### 6.1 Immediate Actions

| # | Action | File | Owner | Effort |
|---|--------|------|-------|--------|
| 1 | Create Identification.onto.md | person/ | Dev | 1 day |
| 2 | Create Probation.onto.md | core/ | Dev | 1 day |
| 3 | Extend Contact with emergency fields | person/ | Dev | 0.5 day |
| 4 | Update entity-catalog (remove Grade) | _research/ | Analyst | 0.5 day |

### 6.2 Design Decisions

| # | Decision | Options | Deadline |
|---|----------|---------|----------|
| 1 | Person vs Worker naming | Keep Worker | Sprint 1 |
| 2 | Organization entity | Defer to H2 | Sprint 1 |
| 3 | Grade module ownership | Confirm TR | Sprint 1 |
| 4 | EmploymentRecord vs events | Discuss | Sprint 2 |

### 6.3 Documentation Updates

| # | Document | Update |
|---|----------|--------|
| 1 | entity-catalog.md | Add cross-references to existing ontology |
| 2 | solution-blueprint.md | Note ontology alignment completed |
| 3 | ADR | Create ADR for Worker vs Person decision |

---

## 7. Appendix: Entity Mapping Table

### Complete Entity Mapping

| # | Research Entity | Implementation File | Status | Action |
|---|-----------------|---------------------|--------|--------|
| 1 | Person | Worker.onto.md | ⚠️ | Document naming |
| 2 | Employee | Employee.onto.md | ✓ | None |
| 3 | Dependent | worker-relationship.onto.md | ⚠️ | Verify mapping |
| 4 | EmergencyContact | Contact.onto.md | ⚠️ | Extend |
| 5 | Organization | - | ⚠️ | Defer H2 |
| 6 | LegalEntity | LegalEntity.onto.md | ✓ | None |
| 7 | BusinessUnit | BusinessUnit.onto.md | ✓ | None |
| 8 | Department | - | ⚠️ | Use BU type |
| 9 | CostCenter | - | ⚠️ | Review |
| 10 | Position | position.onto.md | ✓ | None |
| 11 | Job | job.onto.md | ✓ | None |
| 12 | JobFamily | JobTaxonomy.onto.md | ✓ | None |
| 13 | JobLevel | job-level.onto.md | ✓ | None |
| 14 | Grade | (in TR module) | 🟡 | Update catalog |
| 15 | WorkAssignment | Assignment.onto.md | ✓ | None |
| 16 | EmploymentRecord | - | ⚠️ | Review |
| 17 | Contract | Contract.onto.md | ✓ | None |
| 18 | Probation | - | 🔴 | CREATE |
| 19 | Address | Address.onto.md | ✓ | None |
| 20 | BankAccount | BankAccount.onto.md | ✓ | None |
| 21 | Identification | - | 🔴 | CREATE |
| 22 | Education | worker-qualification.onto.md | ✓ | None |
| 23 | Skill | skill.onto.md | ✓ | None |
| 24 | EmployeeSkill | worker-skill.link.md | ✓ | None |
| 25 | Document | Document.onto.md | ✓ | None |
| 26 | DocumentType | - | 🟡 | Add enum |
| 27 | Location | location.onto.md | ✓ | None |

### Legend

- ✓ = Direct match
- ⚠️ = Partial match / Design decision
- 🔴 = Critical gap - CREATE
- 🟡 = Minor gap - Action needed

---

*Report generated: 2026-01-30*
*Method: Morphological Analysis (Business Brainstorming)*
*Next review: Sprint 1 Planning*
