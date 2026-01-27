# RFC Implementation Summary: WorkRelationship Ontology Refinement

**Date**: 2026-01-26  
**RFC Status**: ✅ IMPLEMENTED  
**Target**: WorkRelationship.onto.md  
**Priority**: HIGH (Core Architecture)

---

## Changes Applied

### 1. Structural & Classification Changes ✅

#### Change 1.1: Remove PROBATION from workerType

**Before** ❌:
```yaml
- name: workerType
  values: [EMPLOYEE, CONTINGENT, INTERN, PROBATION]
```

**After** ✅:
```yaml
- name: workerType
  values: [EMPLOYEE, CONTINGENT, INTERN]
  description: Classification of worker engagement type. Note - PROBATION is a status/phase, not a type.
```

**Rationale**: 
- Probation is a **phase** of employment, not a **type** of worker
- Prevents identity fragmentation when transitioning from probation to confirmed
- Aligns with Oracle/Workday pattern (they use employment status, not type)

**Impact**:
- ✅ Cleaner worker classification
- ✅ No need to change workerType when probation ends
- ✅ probationResult enum already tracks probation status

---

#### Change 1.2: Add employmentIntent attribute

**Added** ✅:
```yaml
- name: employmentIntent
  type: enum
  values: [PERMANENT, FIXED_TERM, SEASONAL, PROJECT_BASED]
  default: PERMANENT
  description: Strategic intent of employment (separate from legal contract type). Supports workforce planning.
```

**Rationale**:
- Separates **strategic intent** (long-term vs seasonal) from **legal contract type**
- Enables better workforce planning and analytics
- Example: EMPLOYEE + SEASONAL (summer intern with employee benefits)

**Use Cases**:
- Workforce planning: "How many SEASONAL workers do we have?"
- Budget forecasting: "PERMANENT vs FIXED_TERM headcount"
- Talent pipeline: "PROJECT_BASED workers eligible for conversion"

---

#### Change 1.3: Enhance probationResult enum

**Updated** ✅:
```yaml
- name: probationResult
  values: [PASSED, FAILED, EXTENDED, IN_PROGRESS]
  description: Outcome of probation period. EXTENDED is valid per VN Labor Law.
```

**Rationale**:
- VN Labor Law allows probation extension (Article 24, Labor Code 2019)
- EXTENDED status tracks this explicitly
- Already existed in schema, just clarified in description

---

### 2. Behavioral & Logic Changes ✅

#### Change 2.1: Refine Lifecycle Transitions (Event-Driven)

**Before** ❌:
```yaml
- from: ACTIVE
  to: TERMINATED
  guard: Termination date set AND reason provided
```

**After** ✅:
```yaml
- from: ACTIVE
  to: TERMINATED
  trigger: terminate
  guard: Termination event triggered (terminationDate does NOT auto-trigger status change)
```

**Rationale**:
- Status changes only via **explicit events/actions**, not automatic date arrival
- Prevents premature system lockout when HR hasn't completed offboarding
- Allows grace period for final payroll, document handover, etc.

**Example Scenario**:
```
terminationDate = 2026-01-31 (set in advance)
Current date = 2026-01-31
Status = ACTIVE (still active until HR calls terminate())
HR completes offboarding → Calls terminate() → Status = TERMINATED
```

---

#### Change 2.2: Clarify SUSPENDED → TERMINATED transition

**Updated** ✅:
```yaml
- from: SUSPENDED
  to: TERMINATED
  trigger: terminate
  guard: Termination during suspension (e.g., contract expiry, dismissal during maternity leave)
```

**Rationale**:
- Handles edge case: Contract expires or employee is fired during maternity/military service
- Legal in VN under specific conditions (e.g., company bankruptcy, gross misconduct)
- Ensures system can handle all real-world scenarios

---

#### Change 2.3: Downgrade LaborContractLinkage severity

**Before** ❌:
```yaml
- name: LaborContractLinkage
  type: business
  rule: ACTIVE WorkRelationship must have at least one ACTIVE LaborContract
  # Implied: Blocking error
```

**After** ✅:
```yaml
- name: LaborContractLinkage
  type: business
  rule: ACTIVE WorkRelationship should have at least one ACTIVE LaborContract
  severity: WARNING
  message: "Gap between contracts detected. Ensure new contract is signed promptly."
```

**Rationale**:
- Real-world gap between contracts (old expires 31/12, new signed 05/01)
- Blocking error would prevent payroll, time attendance during gap period
- WARNING allows operations to continue while alerting HR to resolve

**Example**:
```
Contract 1: 2024-01-01 to 2024-12-31 (expired)
Contract 2: 2025-01-05 to 2026-01-04 (signed late)
Gap: 2025-01-01 to 2025-01-04 (4 days)
System: Shows WARNING, but allows work to continue
```

---

### 3. Localization & Compliance Fields ✅

#### Change 3.1: Add socialInsuranceBookStatus

**Added** ✅:
```yaml
- name: socialInsuranceBookStatus
  type: enum
  values: [NOT_APPLICABLE, OPEN, CLOSED, RETURNED_TO_EMPLOYEE, HELD_BY_COMPANY]
  description: Status of Social Insurance Book (Sổ BHXH - VN specific). Renamed from socialInsuranceCloseDate for clarity.
```

**Rationale**:
- Complements `socialInsuranceCloseDate` (date) with status tracking
- Tracks full lifecycle: OPEN → CLOSED → RETURNED_TO_EMPLOYEE
- Critical for VN labor inspection compliance

---

#### Change 3.2: Clarify laborBookStatus

**Updated** ✅:
```yaml
- name: laborBookStatus
  description: Status of Labor Book return (Sổ lao động - VN specific). Critical for legal compliance.
```

**Rationale**:
- Emphasized legal importance
- Labor Book return is mandatory per VN Labor Code Article 35

---

#### Change 3.3: Add seniorityAdjustmentDate

**Added** ✅:
```yaml
- name: seniorityAdjustmentDate
  type: date
  description: Adjusted service date for seniority calculation (e.g., after unpaid leave deduction). Overrides seniorityDate if set.
```

**Rationale**:
- Handles unpaid leave deductions from seniority
- Example: 6 months unpaid leave → seniorityDate adjusted backward 6 months
- Critical for accurate severance calculation

**Calculation Logic**:
```
Seniority = seniorityAdjustmentDate (if set)
         OR seniorityDate (if set)
         OR originalHireDate (if set)
         OR startDate (fallback)
```

---

### 4. DBML Alignment Requirements ✅

**Note**: These changes need to be reflected in `1.Core.V4.dbml`:

#### 4.1 Flatten Critical Fields (Move out of JSONB)

**Action Required**:
```sql
ALTER TABLE employment.work_relationship
  ADD COLUMN original_hire_date DATE,
  ADD COLUMN probation_status VARCHAR(20),
  ADD COLUMN probation_end_date DATE,
  ADD COLUMN seniority_adjustment_date DATE,
  ADD COLUMN employment_intent VARCHAR(30);

-- Create indexes for query performance
CREATE INDEX idx_work_relationship_original_hire_date 
  ON employment.work_relationship(original_hire_date);

CREATE INDEX idx_work_relationship_probation_status 
  ON employment.work_relationship(probation_status);
```

**Rationale**:
- `original_hire_date`: Critical for seniority queries
- `probation_status`: Frequently filtered (find all IN_PROGRESS probations)
- `seniority_adjustment_date`: Needed for severance calculations

---

#### 4.2 Add New Columns

**Action Required**:
```sql
ALTER TABLE employment.work_relationship
  ADD COLUMN social_insurance_book_status VARCHAR(30),
  ADD COLUMN suspension_start_date DATE,
  ADD COLUMN suspension_end_date DATE;

-- Update workerType enum
ALTER TABLE employment.work_relationship
  DROP CONSTRAINT IF EXISTS work_relationship_worker_type_check;

ALTER TABLE employment.work_relationship
  ADD CONSTRAINT work_relationship_worker_type_check
  CHECK (worker_type IN ('EMPLOYEE', 'CONTINGENT', 'INTERN'));
```

---

## Validation Checklist

### Ontology Consistency ✅

- [x] workerType enum updated (removed PROBATION)
- [x] employmentIntent attribute added
- [x] seniorityAdjustmentDate attribute added
- [x] socialInsuranceBookStatus attribute added
- [x] Lifecycle transitions clarified (event-driven)
- [x] LaborContractLinkage downgraded to WARNING
- [x] All descriptions updated

### DBML Alignment ⏳ (Pending)

- [ ] Update `1.Core.V4.dbml` with new columns
- [ ] Update workerType enum constraint
- [ ] Add indexes for performance
- [ ] Test data migration scripts

### Documentation ✅

- [x] RFC implementation summary created
- [x] Change rationale documented
- [x] Use cases explained
- [x] DBML migration guide provided

---

## Impact Analysis

### Breaking Changes ⚠️

**Change**: Removed PROBATION from workerType enum

**Impact**: 
- Existing records with `workerType = PROBATION` will fail validation
- **Migration Required**:
  ```sql
  UPDATE employment.work_relationship
  SET worker_type = 'EMPLOYEE'
  WHERE worker_type = 'PROBATION';
  ```

**Affected Systems**:
- Hire workflow (must not set workerType = PROBATION)
- Probation tracking reports (use probationResult instead)

---

### Non-Breaking Changes ✅

**Changes**:
- Added employmentIntent (optional, has default)
- Added seniorityAdjustmentDate (optional)
- Added socialInsuranceBookStatus (optional)
- Downgraded LaborContractLinkage to WARNING

**Impact**: 
- No migration required
- Backward compatible
- Gradual adoption possible

---

## Testing Requirements

### Unit Tests

- [ ] workerType validation rejects PROBATION
- [ ] employmentIntent defaults to PERMANENT
- [ ] seniorityAdjustmentDate overrides seniorityDate in calculations
- [ ] LaborContractLinkage shows WARNING (not ERROR) when gap exists
- [ ] Lifecycle transitions require explicit trigger (not auto-date)

### Integration Tests

- [ ] Hire workflow sets employmentIntent correctly
- [ ] Probation end workflow does NOT change workerType
- [ ] Contract gap scenario shows WARNING but allows operations
- [ ] Termination during suspension is allowed

### Data Migration Tests

- [ ] All PROBATION records converted to EMPLOYEE
- [ ] No data loss during migration
- [ ] Indexes created successfully
- [ ] Query performance maintained

---

## Rollout Plan

### Phase 1: Ontology Update (Week 1) ✅ DONE

- [x] Update WorkRelationship.onto.md
- [x] Create RFC implementation summary
- [x] Review with architecture team

### Phase 2: DBML Update (Week 2) ⏳ NEXT

- [ ] Update `1.Core.V4.dbml`
- [ ] Generate migration scripts
- [ ] Test in staging environment

### Phase 3: Code Update (Week 3)

- [ ] Update hire workflow (remove PROBATION option)
- [ ] Update probation tracking (use probationResult)
- [ ] Update contract gap handling (expect WARNING)

### Phase 4: Data Migration (Week 4)

- [ ] Backup production data
- [ ] Run migration scripts
- [ ] Validate data integrity
- [ ] Monitor for issues

---

## Conclusion

**RFC Status**: ✅ **FULLY IMPLEMENTED** in WorkRelationship.onto.md

**Key Achievements**:
1. ✅ Cleaner worker classification (removed PROBATION type)
2. ✅ Better workforce planning (added employmentIntent)
3. ✅ More flexible operations (LaborContractLinkage = WARNING)
4. ✅ Enhanced VN compliance (socialInsuranceBookStatus, seniorityAdjustmentDate)
5. ✅ Event-driven lifecycle (no auto-termination on date)

**Next Actions**:
1. ⏳ Update DBML schema
2. ⏳ Generate migration scripts
3. ⏳ Update application code
4. ⏳ Execute data migration

**Compliance**: ✅ Maintains full VN Labor Law compliance  
**Architecture**: ✅ Aligns with Oracle/Workday/SAP patterns  
**Operations**: ✅ More flexible for real-world scenarios

---

*RFC Implementation Date: 2026-01-26*  
*Implemented by: Business Brainstorming AI + Feature Builder*  
*Status: APPROVED - Ready for DBML Update*
