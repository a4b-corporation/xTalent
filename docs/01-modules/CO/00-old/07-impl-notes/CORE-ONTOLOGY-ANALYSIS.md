# Core Ontology Analysis & Enhancement Plan

**Date**: 2025-12-03  
**Analyst**: AI Assistant  
**Purpose**: Analyze Core ontology gaps and plan enhancements

---

## 🔍 CRITICAL ISSUES IDENTIFIED

### 1️⃣ **Business Unit Manager Reference** ❌ **INCORRECT**

#### Current State (DBML)
```dbml
Table org_bu.unit {
  manager_worker_id uuid [ref: > person.worker.id, null]  // ❌ WRONG
}
```

#### Issue
**BU manager should reference `Employee`, NOT `Worker`**

#### Rationale
| Aspect | Worker | Employee | Verdict |
|--------|--------|----------|---------|
| **Definition** | Any person (candidate, contractor, employee, alumni) | Active employment relationship | ✅ **Employee** |
| **Status** | May not be employed | Must be actively employed | ✅ **Employee** |
| **Authority** | No organizational authority | Has organizational role/authority | ✅ **Employee** |
| **Assignment** | No assignment | Has assignment(s) | ✅ **Employee** |
| **Accountability** | Cannot be held accountable | Can be held accountable | ✅ **Employee** |

**Business Rules**:
- ✅ BU manager MUST be an active employee
- ✅ BU manager MUST have an active assignment
- ✅ BU manager has organizational authority
- ❌ Contractor (Worker but not Employee) CANNOT be BU manager
- ❌ Candidate (Worker but not Employee) CANNOT be BU manager
- ❌ Alumni (Worker but not Employee) CANNOT be BU manager

#### Recommended Fix
```yaml
Unit:
  attributes:
    manager_employee_id:  # ✅ CORRECT
      type: UUID
      description: "FK to Employee (BU manager)"
      required: false
  relationships:
    manager:
      target: Employee  # ✅ NOT Worker
      cardinality: "N:1"
      description: "Business unit manager (must be active employee)"
  businessRules:
    - "manager_employee_id must reference active Employee"
    - "Manager must have ACTIVE assignment in this BU or parent BU"
    - "Manager cannot be contractor, candidate, or alumni"
```

---

### 2️⃣ **Work Location - Legal Entity Relationship** ✅ **CORRECT IN DBML, MISSING IN ONTOLOGY**

#### Current State

**DBML** ✅ **HAS** the relationship:
```dbml
Table facility.work_location {
  id                 uuid       [pk]
  code               varchar(50) [unique]
  name               varchar(255)
  location_id        uuid        [ref: > facility.location.id]
  work_loc_type_code varchar(50)
  legal_entity_id    uuid        [ref: > org_legal.entity.id, null]  // ✅ CORRECT
  capacity           int         [null]
  metadata           jsonb
  is_active          boolean     [default: true]
}
```

**Ontology** ❌ **MISSING** the relationship:
```yaml
WorkLocation:
  attributes:
    # ... other attributes
    # ❌ MISSING: legal_entity_id
  relationships:
    # ❌ MISSING: legalEntity relationship
```

#### Issue
**Ontology is incomplete** - missing critical `legal_entity_id` relationship

#### Business Case Analysis

**Question**: Should WorkLocation link to LegalEntity?

**Answer**: ✅ **YES - ABSOLUTELY REQUIRED**

#### Use Cases

##### ✅ **Use Case 1: Allowance Calculation**
```yaml
Scenario: "Cross-province work allowance"
Given:
  - Employee contract: Legal Entity = "VNG Corp HCM" (Ho Chi Minh City)
  - Assignment work_location: "Hanoi Office"
  - Hanoi Office legal_entity: "VNG Corp HN" (Hanoi)
Then:
  - System detects: contract LE != work location LE
  - System calculates: Cross-province allowance = 2,000,000 VND/month
  - Rationale: Working away from contract location
```

**Without LE link**: ❌ Cannot determine if allowance applies

##### ✅ **Use Case 2: Tax Jurisdiction**
```yaml
Scenario: "Tax withholding location"
Given:
  - Employee lives in: Ho Chi Minh City
  - Works at: "Da Nang Office"
  - Da Nang Office legal_entity: "VNG Corp DN" (Da Nang)
Then:
  - Tax withheld at: Da Nang tax authority
  - Tax code: Da Nang jurisdiction
  - Rationale: Tax follows work location, not residence
```

**Without LE link**: ❌ Cannot determine correct tax jurisdiction

##### ✅ **Use Case 3: Social Insurance Registration**
```yaml
Scenario: "SI registration location"
Given:
  - Employee hired by: "VNG Corp HCM"
  - Assigned to: "Can Tho Office"
  - Can Tho Office legal_entity: "VNG Corp CT" (Can Tho)
Then:
  - SI registered at: Can Tho Social Insurance Office
  - SI code: Can Tho province code
  - Rationale: SI follows work location
```

**Without LE link**: ❌ Cannot determine SI registration location

##### ✅ **Use Case 4: Legal Entity Work Location Count**
```yaml
Query: "How many work locations does VNG Corp HCM have?"
Expected Result:
  - HCM Head Office
  - HCM District 7 Office
  - HCM Tan Binh Office
  - Total: 3 locations

SQL:
  SELECT COUNT(*) 
  FROM facility.work_location 
  WHERE legal_entity_id = 'VNG_CORP_HCM_UUID'
```

**Without LE link**: ❌ Cannot answer this basic question

##### ✅ **Use Case 5: Compliance Reporting**
```yaml
Report: "Work location audit by legal entity"
Required Fields:
  - Legal Entity Name
  - Work Location Count
  - Employee Count per Location
  - Capacity Utilization %
  - Safety Compliance Status

Purpose:
  - Labor inspection compliance
  - Workplace safety audit
  - Capacity planning
```

**Without LE link**: ❌ Cannot generate this report

#### Recommended Fix
```yaml
WorkLocation:
  description: |
    Physical work location (office, factory, site).
    Links to Legal Entity for tax, SI, and allowance calculations.
  attributes:
    id:
      type: UUID
      required: true
    code:
      type: string
      required: true
      maxLength: 50
    name:
      type: string
      required: true
      maxLength: 255
    location_id:
      type: UUID
      required: true
      description: "FK to Location (geographic location)"
    work_loc_type_code:
      type: string
      maxLength: 50
      description: "Work location type (OFFICE, FACTORY, WAREHOUSE, SITE)"
    legal_entity_id:  # ✅ ADD THIS
      type: UUID
      required: false
      description: |
        FK to LegalEntity (owning/operating entity).
        CRITICAL for:
        - Tax jurisdiction determination
        - Social insurance registration
        - Cross-location allowance calculation
        - Compliance reporting
    capacity:
      type: integer
      description: "Maximum employee capacity"
    metadata:
      type: jsonb
    is_active:
      type: boolean
      default: true
  relationships:
    location:
      target: Location
      cardinality: "N:1"
      description: "Geographic location"
    legalEntity:  # ✅ ADD THIS
      target: LegalEntity
      cardinality: "N:1"
      description: "Owning/operating legal entity"
    positions:
      target: Position
      cardinality: "1:N"
      description: "Positions at this location"
    assignments:
      target: Assignment
      cardinality: "1:N"
      description: "Employee assignments at this location"
  businessRules:
    - "legal_entity_id determines tax jurisdiction"
    - "legal_entity_id determines SI registration location"
    - "If assignment.work_location.legal_entity_id != contract.legal_entity_id, cross-location allowance may apply"
    - "One legal entity can have multiple work locations"
    - "Work location must be in same country as legal entity"
  indexes:
    - name: "idx_work_location_code"
      columns: [code]
      unique: true
    - name: "idx_work_location_legal_entity"  # ✅ ADD THIS
      columns: [legal_entity_id]
    - name: "idx_work_location_active"
      columns: [is_active]
      where: "is_active = true"
  examples:
    - code: "VNG_HCM_HQ"
      name: "VNG Corp HCM Head Office"
      legal_entity_id: "VNG_CORP_HCM_UUID"
      work_loc_type_code: "OFFICE"
      capacity: 500
    - code: "VNG_HN_OFFICE"
      name: "VNG Corp Hanoi Office"
      legal_entity_id: "VNG_CORP_HN_UUID"
      work_loc_type_code: "OFFICE"
      capacity: 200
```

---

### 3️⃣ **Work Location Scope Analysis**

#### Question
"Work location chỉ phục vụ trong Position, Assignment thôi hay sao?"

#### Answer
✅ **YES - Primary usage is Position & Assignment**  
✅ **BUT - Also used in other contexts**

#### Usage Scope

| Entity | Usage | Criticality |
|--------|-------|-------------|
| **Position** | `primary_location_id` | ⭐⭐⭐ **CRITICAL** |
| **Assignment** | `primary_location_id` | ⭐⭐⭐ **CRITICAL** |
| **Contract** | Implicit via Assignment | ⭐⭐ **IMPORTANT** |
| **LegalEntity** | Reverse relationship (LE has many locations) | ⭐⭐⭐ **CRITICAL** |
| **Allowance Calculation** | Cross-location allowance | ⭐⭐⭐ **CRITICAL** |
| **Tax Calculation** | Tax jurisdiction | ⭐⭐⭐ **CRITICAL** |
| **SI Calculation** | SI registration location | ⭐⭐⭐ **CRITICAL** |
| **Reporting** | Headcount by location | ⭐⭐ **IMPORTANT** |
| **Compliance** | Safety, labor inspection | ⭐⭐ **IMPORTANT** |

#### Relationship Flow

```
LegalEntity (1) ──────> (N) WorkLocation
                              │
                              │ (1)
                              ▼
Position (N) ────────────> (1) WorkLocation
    │                          ▲
    │ (1)                      │ (1)
    ▼                          │
Assignment (N) ────────────────┘
    │
    │ (N)
    ▼
Employee (1)
```

#### Data Flow Example

```yaml
Legal Entity: "VNG Corp HCM"
  └─> Work Locations:
      ├─> "HCM Head Office" (capacity: 500)
      ├─> "HCM District 7" (capacity: 200)
      └─> "HCM Tan Binh" (capacity: 150)

Position: "Senior Engineer"
  └─> primary_location: "HCM Head Office"

Assignment: "John Doe - Senior Engineer"
  ├─> position: "Senior Engineer"
  ├─> primary_location: "HCM Head Office"  # Can override position location
  └─> employee: "John Doe"

Contract: "John Doe Employment Contract"
  ├─> legal_entity: "VNG Corp HCM"
  └─> Implicit work_location via Assignment
```

#### Allowance Calculation Logic

```python
def calculate_cross_location_allowance(assignment):
    contract_le = assignment.employee.contract.legal_entity
    work_location_le = assignment.primary_location.legal_entity
    
    if contract_le.id != work_location_le.id:
        # Cross-location work detected
        if contract_le.province != work_location_le.province:
            # Cross-province allowance
            return 2_000_000  # VND/month
        else:
            # Same province, different LE
            return 1_000_000  # VND/month
    else:
        return 0  # No allowance
```

**Without `legal_entity_id` in WorkLocation**: ❌ **CANNOT IMPLEMENT THIS**

---

## 📊 ONTOLOGY COMPLETENESS ANALYSIS

### Current State

| Category | Listed | Fully Defined | Completion % |
|----------|--------|---------------|--------------|
| **Common** | 10 | 3 | 30% |
| **Geographic** | 2 | 2 | 100% |
| **LegalEntity** | 6 | 4 | 67% |
| **BusinessUnit** | 3 | 2 | 67% |
| **OrganizationRelation** | 3 | 3 | 100% |
| **Person** | 10 | 6 | 60% |
| **Employment** | 6 | 5 | 83% |
| **JobPosition** | 15 | 8 | 53% |
| **Facility** | 5 | 2 | 40% |
| **Skill** | 8 | 4 | 50% |
| **Privacy** | 3 | 1 | 33% |
| **TOTAL** | **71** | **40** | **56%** |

### Missing Detail Entities (31 entities)

#### Common (7 entities)
1. CodeList - Minimal detail
2. Currency - Minimal detail
3. TimeZone - Minimal detail
4. Industry - Minimal detail
5. ContactType - Minimal detail
6. RelationshipGroup - Minimal detail
7. RelationshipType - Minimal detail

#### LegalEntity (2 entities)
8. EntityRepresentative - Not defined
9. EntityLicense - Not defined

#### BusinessUnit (1 entity)
10. UnitTag - Minimal detail

#### Person (4 entities)
11. Contact - Minimal detail
12. Address - Minimal detail
13. Document - Minimal detail
14. BankAccount - Minimal detail

#### Employment (1 entity)
15. EmployeeIdentifier - Minimal detail

#### JobPosition (7 entities)
16. TaxonomyTree - Not defined
17. JobTaxonomy - Not defined
18. JobTree - Not defined
19. JobLevel - Minimal detail
20. JobGrade - Minimal detail
21. JobProfile - Partial detail
22. Position - Partial detail

#### Facility (3 entities)
23. Place - Not defined
24. Location - Not defined
25. WorkLocation - **MISSING legal_entity_id** ❌

#### Skill (4 entities)
26. SkillMaster - Minimal detail
27. CompetencyMaster - Minimal detail
28. WorkerSkill - Minimal detail
29. WorkerCompetency - Minimal detail

#### Privacy (2 entities)
30. DataClassification - Not defined
31. ConsentManagement - Not defined

---

## 🎯 ENHANCEMENT PLAN

### Phase 1: Critical Fixes (Week 1)

#### Priority 1A: Fix Incorrect References
- [ ] **Unit.manager_worker_id** → **Unit.manager_employee_id**
  - Update ontology
  - Update DBML
  - Add business rules
  - Add validation

#### Priority 1B: Add Missing Critical Relationships
- [ ] **WorkLocation.legal_entity_id**
  - Add to ontology
  - Already in DBML ✅
  - Add business rules
  - Add examples
  - Add use cases

### Phase 2: Complete Core Entities (Week 2-3)

#### Facility Module (3 entities)
- [ ] **Place** - Full definition with examples
- [ ] **Location** - Full definition with geo data
- [ ] **WorkLocation** - Enhanced with LE relationship

#### Employment Module (1 entity)
- [ ] **EmployeeIdentifier** - Full definition with examples

#### Person Module (4 entities)
- [ ] **Contact** - Full definition with validation
- [ ] **Address** - Full definition with geo validation
- [ ] **Document** - Full definition with types
- [ ] **BankAccount** - Full definition with validation

### Phase 3: Complete Job & Position (Week 4)

#### JobPosition Module (7 entities)
- [ ] **TaxonomyTree** - Full definition
- [ ] **JobTaxonomy** - Full definition
- [ ] **JobTree** - Full definition
- [ ] **JobLevel** - Enhanced definition
- [ ] **JobGrade** - Enhanced definition
- [ ] **JobProfile** - Complete definition
- [ ] **Position** - Complete definition

### Phase 4: Complete Reference Data (Week 5)

#### Common Module (7 entities)
- [ ] **CodeList** - Enhanced with examples
- [ ] **Currency** - Enhanced with examples
- [ ] **TimeZone** - Enhanced with DST rules
- [ ] **Industry** - Enhanced with hierarchy
- [ ] **ContactType** - Enhanced with validation
- [ ] **RelationshipGroup** - Enhanced definition
- [ ] **RelationshipType** - Enhanced definition

### Phase 5: Complete Skill & Privacy (Week 6)

#### Skill Module (4 entities)
- [ ] **SkillMaster** - Full definition
- [ ] **CompetencyMaster** - Full definition
- [ ] **WorkerSkill** - Full definition with proficiency
- [ ] **WorkerCompetency** - Full definition with assessment

#### Privacy Module (2 entities)
- [ ] **DataClassification** - Full GDPR/PDPA compliance
- [ ] **ConsentManagement** - Full consent tracking

### Phase 6: Complete Legal Entity (Week 7)

#### LegalEntity Module (2 entities)
- [ ] **EntityRepresentative** - Full definition
- [ ] **EntityLicense** - Full definition with expiry

---

## 📈 EXPECTED OUTCOMES

### After Enhancement

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Total Lines** | 3,374 | ~6,500 | +93% |
| **Entities Defined** | 40/71 | 71/71 | +78% |
| **Completion %** | 56% | 100% | +44% |
| **Avg Lines/Entity** | 84 | 92 | +10% |
| **Business Rules** | ~150 | ~350 | +133% |
| **Examples** | ~50 | ~150 | +200% |
| **Indexes** | ~200 | ~400 | +100% |

### Quality Improvements

✅ **All entities fully defined**  
✅ **Consistent with TR ontology quality**  
✅ **Production-ready documentation**  
✅ **Complete business rules**  
✅ **Comprehensive examples**  
✅ **Performance indexes**  
✅ **GDPR/PDPA compliance**

---

## 🚨 CRITICAL ACTIONS REQUIRED

### Immediate (Today)

1. ✅ **Fix Unit.manager reference** - Worker → Employee
2. ✅ **Add WorkLocation.legal_entity_id** to ontology
3. ✅ **Document allowance calculation use case**

### This Week

4. ⏳ **Complete Facility module** (Place, Location, WorkLocation)
5. ⏳ **Complete Person module** (Contact, Address, Document, BankAccount)
6. ⏳ **Complete Employment module** (EmployeeIdentifier)

### Next 2 Weeks

7. ⏳ **Complete JobPosition module** (7 entities)
8. ⏳ **Complete Common module** (7 entities)

### Next Month

9. ⏳ **Complete Skill module** (4 entities)
10. ⏳ **Complete Privacy module** (2 entities)
11. ⏳ **Complete LegalEntity module** (2 entities)

---

## ✅ RECOMMENDATIONS

### For Immediate Action

1. **Accept TR ontology as gold standard** ✅
2. **Fix Unit.manager_worker_id → manager_employee_id** ✅
3. **Add WorkLocation.legal_entity_id to ontology** ✅
4. **Start Phase 1 enhancements immediately** ✅

### For Long-term Success

5. **Allocate 7 weeks for complete enhancement** ✅
6. **Follow TR ontology format and detail level** ✅
7. **Add comprehensive business rules** ✅
8. **Add real-world examples** ✅
9. **Document all use cases** ✅
10. **Ensure GDPR/PDPA compliance** ✅

---

**Status**: Analysis complete, ready for implementation  
**Next Step**: Begin Phase 1 critical fixes
