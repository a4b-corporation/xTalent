# Core Ontology - Missing Entities Analysis

**Date**: 2025-12-01  
**Analyst**: AI Assistant  
**Issue**: Entities listed in sub-modules but not defined in ontology

---

## 🔍 Summary

The `core-ontology.yaml` file lists **56 entities** across 11 sub-modules, but **NOT ALL** entities have detailed definitions in the `entities:` section.

### Status Overview

| Sub-Module | Total Entities | Defined | Missing | Status |
|------------|----------------|---------|---------|--------|
| Common | 10 | ✅ 10 | 0 | ✅ Complete |
| Geographic | 2 | ✅ 2 | 0 | ✅ Complete |
| LegalEntity | 6 | ✅ 6 | 0 | ✅ Complete |
| BusinessUnit | 3 | ✅ 3 | 0 | ✅ Complete |
| OrganizationRelation | 3 | ✅ 3 | 0 | ✅ Complete |
| Person | 10 | ✅ 10 | 0 | ✅ Complete |
| Employment | 6 | ✅ 6 | 0 | ✅ Complete |
| **JobPosition** | **8** | ✅ **8** | 0 | ✅ **Complete** |
| **Career** | **3** | ⚠️ **0** | ❌ **3** | ❌ **MISSING** |
| **Facility** | **3** | ✅ **3** | 0 | ✅ **Complete** |
| **TalentMarket** | **3** | ⚠️ **0** | ❌ **3** | ❌ **MISSING** |
| **TOTAL** | **56** | **46** | **10** | **82% Complete** |

---

## ❌ Missing Entities Detail

### 1. JobPosition Sub-Module (8 entities) - ✅ RESOLVED

**Status**: ✅ All 8 entities are defined in `core-ontology.yaml` (Job & Position Schema).
1. ❌ `TaxonomyTree` - Job taxonomy tree structure
2. ❌ `JobTaxonomy` - Job taxonomy nodes
3. ❌ `JobTree` - Job hierarchy tree
4. ❌ `Job` - Job definition
5. ❌ `JobProfile` - Job profile with requirements
6. ❌ `JobLevel` - Job level/seniority
7. ❌ `JobGrade` - Job grade/band
8. ❌ `Position` - Position instance

**Impact**: 
- 🔴 **CRITICAL** - Jobs and Positions are CORE to HR system
- Cannot define job requirements, position budgets, or career paths
- Assignment entity references `position_id` and `job_id` but these entities are undefined

**Should these be in Core?**: 
- ✅ **YES** - Jobs and Positions are foundational to Core module
- These are NOT Total Rewards entities (TR handles compensation, not job structure)

---

### 2. Career Sub-Module (3 entities missing)

**Listed but NOT defined**:
1. ❌ `CareerPath` - Career progression paths
2. ❌ `CareerStep` - Steps within career path
3. ❌ `JobProgression` - Job-to-job progression rules

**Impact**:
- 🟡 **MEDIUM** - Career planning features unavailable
- Cannot model career ladders or succession planning

**Should these be in Core?**: 
- ⚠️ **DEBATABLE** - Could be in Core OR Talent Management (TM) module
- **Recommendation**: Keep in Core as it's tightly coupled with Job/Position structure

---

### 3. Facility Sub-Module (3 entities) - ✅ RESOLVED

**Status**: ✅ All 3 entities are defined in `core-ontology.yaml` (Facility Schema).
1. ❌ `Place` - Geographic place/location
2. ❌ `Location` - Facility/building location
3. ❌ `WorkLocation` - Work location for assignments

**Impact**:
- 🟡 **MEDIUM** - Cannot track work locations
- Assignment entity references `primary_location_id` but WorkLocation is undefined

**Should these be in Core?**: 
- ✅ **YES** - Work locations are fundamental to assignments
- Needed for remote work, office locations, global assignments

---

### 4. TalentMarket Sub-Module (3 entities missing)

**Listed but NOT defined**:
1. ❌ `Opportunity` - Internal job opportunities
2. ❌ `OpportunitySkill` - Required skills for opportunity
3. ❌ `OpportunityApplication` - Worker applications

**Impact**:
- 🟢 **LOW** - Internal talent marketplace is a nice-to-have feature
- Not critical for basic HR operations

**Should these be in Core?**: 
- ⚠️ **DEBATABLE** - Could be separate Talent Marketplace module
- **Recommendation**: Move to Talent Management (TM) or separate module

---

## 🎯 Recommendations

### Priority 1: CRITICAL (Must Define)

#### JobPosition Entities (8 entities)
These are **ABSOLUTELY CRITICAL** and must be defined in Core ontology:

```yaml
Priority: 🔴 CRITICAL
Entities:
  - TaxonomyTree
  - JobTaxonomy
  - JobTree
  - Job
  - JobProfile
  - JobLevel
  - JobGrade
  - Position

Rationale:
  - Referenced by Assignment (position_id, job_id)
  - Core to organizational structure
  - Required for staffing models (POSITION_BASED vs JOB_BASED)
  - Foundation for compensation, career paths, talent management

Action: Define ALL 8 entities in core-ontology.yaml immediately
```

#### Facility Entities (3 entities)
These are **IMPORTANT** for work location tracking:

```yaml
Priority: 🟡 HIGH
Entities:
  - Place
  - Location
  - WorkLocation

Rationale:
  - Referenced by Assignment (primary_location_id)
  - Needed for global assignments
  - Remote work tracking
  - Office/facility management

Action: Define all 3 entities in core-ontology.yaml
```

---

### Priority 2: MEDIUM (Should Define)

#### Career Entities (3 entities)
These support career planning:

```yaml
Priority: 🟡 MEDIUM
Entities:
  - CareerPath
  - CareerStep
  - JobProgression

Rationale:
  - Career development planning
  - Succession planning
  - Tightly coupled with Job structure

Options:
  1. Define in Core ontology (recommended)
  2. Move to Talent Management module
  
Recommendation: Keep in Core, define after JobPosition entities
```

---

### Priority 3: LOW (Consider Moving)

#### TalentMarket Entities (3 entities)
These are nice-to-have features:

```yaml
Priority: 🟢 LOW
Entities:
  - Opportunity
  - OpportunitySkill
  - OpportunityApplication

Rationale:
  - Internal talent marketplace
  - Not critical for basic HR
  - Could be separate module

Options:
  1. Define in Core ontology
  2. Move to Talent Management module
  3. Create separate TalentMarketplace module
  
Recommendation: Move to Talent Management (TM) module or defer
```

---

## 📝 Proposed Structure

### Core Module Should Include:

```yaml
Core Module (CO):
  ✅ Common (10 entities) - COMPLETE
  ✅ Geographic (2 entities) - COMPLETE
  ✅ LegalEntity (6 entities) - COMPLETE
  ✅ BusinessUnit (3 entities) - COMPLETE
  ✅ OrganizationRelation (3 entities) - COMPLETE
  ✅ Person (10 entities) - COMPLETE
  ✅ Employment (6 entities) - COMPLETE
  ❌ JobPosition (8 entities) - MUST ADD
  ❌ Facility (3 entities) - SHOULD ADD
  ⚠️ Career (3 entities) - SHOULD ADD (or move to TM)
  ⚠️ TalentMarket (3 entities) - CONSIDER MOVING to TM

Total: 54 entities (if keeping Career, removing TalentMarket)
```

### Talent Management Module (TM) Could Include:

```yaml
Talent Management Module (TM):
  - Performance Management
  - Learning & Development
  - Succession Planning
  - Career Development (moved from Core)
  - Talent Marketplace (moved from Core)
  - 360 Feedback
  - etc.
```

---

## 🚀 Action Plan

### Immediate Actions (This Week)

1. **Define JobPosition Entities** (8 entities)
   - TaxonomyTree, JobTaxonomy, JobTree
   - Job, JobProfile, JobLevel, JobGrade
   - Position
   - **Complexity**: High (multi-tree taxonomy, job profiles)
   - **Estimated Effort**: 4-6 hours

2. **Define Facility Entities** (3 entities)
   - Place, Location, WorkLocation
   - **Complexity**: Medium
   - **Estimated Effort**: 1-2 hours

### Short-term Actions (Next Sprint)

3. **Define Career Entities** (3 entities)
   - CareerPath, CareerStep, JobProgression
   - **Complexity**: Medium
   - **Estimated Effort**: 2-3 hours

4. **Decide on TalentMarket** (3 entities)
   - Option A: Define in Core
   - Option B: Move to TM module
   - **Recommendation**: Move to TM

### Documentation Updates

5. **Update Glossaries**
   - Create glossary-job-position.md
   - Create glossary-facility.md
   - Create glossary-career.md (if keeping in Core)

6. **Update DBML**
   - Sync database design with new entities

---

## 📊 Comparison with Leading Systems

### Workday HCM
- ✅ Has Job Profile, Job Family, Job Level
- ✅ Has Position (budgeted headcount)
- ✅ Has Work Location
- ✅ Has Career Path

### SAP SuccessFactors
- ✅ Has Job Code, Job Profile
- ✅ Has Position Management
- ✅ Has Location
- ✅ Has Career Path Builder

### Oracle HCM Cloud
- ✅ Has Job, Grade, Position
- ✅ Has Location
- ✅ Has Career Development

**Conclusion**: All leading systems have Job/Position/Location entities. These are **NOT optional** for enterprise HR.

---

## ⚠️ Risks of Not Defining

### If JobPosition entities remain undefined:
- ❌ Cannot implement position-based staffing model
- ❌ Cannot define job requirements or profiles
- ❌ Cannot link compensation to jobs/grades
- ❌ Cannot build career paths
- ❌ Assignment.position_id is a dangling reference

### If Facility entities remain undefined:
- ❌ Cannot track work locations
- ❌ Global assignments lack location data
- ❌ Remote work cannot be properly tracked
- ❌ Assignment.primary_location_id is a dangling reference

---

## ✅ Next Steps

1. **Confirm Scope**: 
   - Agree that JobPosition and Facility MUST be in Core
   - Decide on Career (Core or TM?)
   - Decide on TalentMarket (Core or TM?)

2. **Define Entities**:
   - Start with JobPosition (highest priority)
   - Then Facility
   - Then Career (if staying in Core)

3. **Update Documentation**:
   - Glossaries
   - DBML
   - API specs

4. **Review & Validate**:
   - Ensure consistency with v2.0 enhancements
   - Validate relationships
   - Check business rules

---

**Document Version**: 1.0  
**Created**: 2025-12-01  
**Status**: Ready for Review
