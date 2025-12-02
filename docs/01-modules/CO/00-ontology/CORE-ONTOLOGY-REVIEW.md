# Core Ontology Review - Best Practices Comparison

**Date**: 2025-12-01  
**Reviewer**: xTalent Documentation Team  
**Version**: 1.0

---

## Executive Summary

Sau khi nghiên cứu các giải pháp HR hàng đầu (Workday, SAP SuccessFactors, Oracle HCM Cloud), ontology Core hiện tại của chúng ta đã thiết kế **rất tốt** và tuân thủ hầu hết best practices. Tuy nhiên, vẫn có **một số điểm cần cải tiến** để đạt chuẩn enterprise-level.

**Đánh giá tổng quan**: ⭐⭐⭐⭐ (4/5)

- ✅ **Điểm mạnh**: Separation of concerns (Worker-Employee-Assignment), Multi-tree architecture, SCD Type 2, Flexible tagging
- ⚠️ **Cần cải tiến**: Work Relationship concept, Person Types, Supervisory Organization, Staffing Model

---

## So sánh với Leading HR Systems

### 1. **Worker vs Employee vs Person Model**

#### ✅ **Workday Approach** (Best Practice)
```
Person (Universal identity)
  ↓
Worker (Anyone working for org - employees, contractors, contingent)
  ↓
Work Relationship (Employment contract)
  ↓
Position/Job Assignment
```

#### ✅ **SAP SuccessFactors Approach**
```
Person (Bio data)
  ↓
Employment Info (Contract, job history)
  ↓
Assignment (Job, position, location)
```

#### ✅ **Oracle HCM Cloud Approach**
```
Global Person Model
  ↓
Work Relationship (Can have multiple across legal entities)
  ↓
Primary Assignment (One per work relationship)
```

#### ⭐ **Current xTalent Model** (GOOD, but missing Work Relationship)
```
Worker (Person)
  ↓
Employee (Employment with Legal Entity)
  ↓
Assignment (Job assignment in BU)
```

**🔴 GAP IDENTIFIED**:
- Thiếu **Work Relationship** entity riêng biệt
- Hiện tại `Employee` đang gộp cả "work relationship" và "employment contract"

**✅ RECOMMENDATION 1**: Tách `Employee` thành 2 entities:
1. **WorkRelationship**: Quan hệ làm việc (có thể có nhiều relationship cho cùng 1 worker)
2. **EmploymentContract**: Hợp đồng cụ thể (chi tiết pháp lý)

---

### 2. **Person Types & Worker Categories**

#### ✅ **Workday/Oracle Best Practice**
Có system person types:
- Employee
- Contingent Worker
- Non-worker (Not managed by HR)
- Pending Worker
- Former Employee

#### ⭐ **Current xTalent Model**
Có `worker_category_code` và `employee_class_code` nhưng:
- Không có explicit "Person Type" concept
- Không có "Contingent Worker" riêng biệt
- Không phân biệt "Non-worker" (người tham gia activities nhưng không phải nhân viên)

**✅ RECOMMENDATION 2**: Thêm `Person Type` vào `Worker` entity:
```yaml
Worker:
  person_type_code:
    type: enum
    values: [EMPLOYEE, CONTRACTOR, CONTINGENT, NON_WORKER, PENDING, FORMER]
    description: "System person type"
```

---

### 3. **Organizational Structure - Supervisory Organization**

#### ✅ **Workday Best Practice** (Critical Concept)
**Supervisory Organization** là foundation object:
- Defines reporting hierarchy
- Influences workflows, approvals, security
- Separate from cost center/department structure
- Can be different from legal entity structure

#### ⚠️ **Current xTalent Model**
Có `Unit` (Business Unit) nhưng:
- Không có **Supervisory Organization** concept riêng
- `supervisor_assignment_id` ở Assignment level → OK nhưng không đủ
- Thiếu khái niệm "Superior Organization" trong hierarchy

**✅ RECOMMENDATION 3**: Thêm entity hoặc type cho Supervisory Organization:

**Option A**: Thêm mới entity
```yaml
SupervisoryOrganization:
  description: "Supervisory management structure (separate from BU hierarchy)"
  attributes:
    id: UUID
    code: string
    name: string
    manager_position_id: UUID  # Manager of this org
    superior_org_id: UUID      # Parent supervisory org
```

**Option B**: Thêm type vào `UnitType`
```yaml
UnitType:
  code: [DIVISION, DEPARTMENT, TEAM, SUPERVISORY, COST_CENTER, MATRIX]
```

**Khuyến nghị**: Dùng Option B (đơn giản hơn, tận dụng structure hiện có)

---

### 4. **Staffing Model - Position vs Job Management**

#### ✅ **Workday Best Practice**
Hỗ trợ 2 staffing models:
1. **Position Management**: Strict headcount control, budgeted positions
2. **Job Management**: Flexible, multiple people same job without pre-defined position
3. **Hybrid**: Mix cả 2 models

#### ⭐ **Current xTalent Model**
Có cả `Position` và `Job`, nhưng:
- Không explicit về "Staffing Model" choice
- `Position` có `max_incumbents` → Good!
- Nhưng thiếu flexibility cho "Job Management" mode (không qua Position)

**✅ RECOMMENDATION 4**: Thêm support cho flexible staffing:

```yaml
Assignment:
  attributes:
    staffing_model_code:
      type: enum
      values: [POSITION_BASED, JOB_BASED]
      description: "How this assignment is staffed"
    
    position_id:
      type: UUID
      required: false  # Nullable if JOB_BASED
    
    job_id:
      type: UUID
      required: false  # Direct job link for JOB_BASED model
```

---

### 5. **Job Profile & Job Family Taxonomy**

#### ✅ **SAP SuccessFactors Best Practice**
- Job Profile có level (L1, L2, L3...)
- Job Family → Job Group → Job Code (3-tier)
- Clear linkage: Job → Profile → Skills

#### ⭐ **Current xTalent Model** (EXCELLENT!)
- Multi-tree taxonomy ✅
- JobTaxonomy với types (FAMILY, GROUP, TRACK) ✅
- JobProfile separate từ Job ✅
- Cross-tree mapping ✅

**✅ MINOR RECOMMENDATION 5**: Thêm explicit `job_family_id` shortcut:
```yaml
Job:
  job_family_id:
    type: UUID
    description: "Direct link to primary job family (denormalized for performance)"
```

---

### 6. **Global Assignment & Multi-Country Support**

#### ✅ **Oracle HCM Cloud Best Practice**
- Global Person Model
- Multiple work relationships across legal entities
- Payroll country separate from work country
- Shadow payroll support

#### ⭐ **Current xTalent Model** (VERY GOOD!)
- GlobalAssignment entity ✅
- Home vs Host entity ✅
- Payroll country ✅
- COLA, housing allowance ✅

**🎉 NO CHANGES NEEDED** - Thiết kế này đã đạt best practice!

---

### 7. **Historical Tracking & Effective Dating**

#### ✅ **All Leading Systems**
- SCD Type 2 with effective dates
- Audit trail for all changes
- Historical snapshots

#### ⭐ **Current xTalent Model**
- SCD Type 2 on most entities ✅
- `effective_start_date`, `effective_end_date`, `is_current_flag` ✅
- Snapshot tables (org_snapshot) ✅

**🎉 EXCELLENT** - Đạt chuẩn enterprise!

---

### 8. **Skill & Competency Management**

#### ✅ **Workday/SAP Best Practice**
- Skill Catalog (master)
- Proficiency levels
- Skill on Job Profile (required skills)
- Skill on Worker (actual skills)
- Gap analysis support

#### ⭐ **Current xTalent Model** (GOOD!)
- SkillMaster ✅
- CompetencyMaster ✅
- WorkerSkill with proficiency ✅
- JobProfileSkill ✅

**✅ RECOMMENDATION 6**: Thêm computed skill gap:
```yaml
WorkerSkill:
  attributes:
    verified_flag: boolean  # Already exists ✅
    target_level: integer   # NEW - Target proficiency
    gap_months: decimal     # NEW - Time to close gap
```

---

### 9. **Data Security & Access Control**

#### ✅ **Best Practices**
- Row-level security based on org hierarchy
- Field-level encryption for sensitive data
- Unique non-sensitive IDs (not SSN)
- Role-based access control (RBAC)

#### ⚠️ **Current xTalent Ontology**
- Không có explicit security model trong ontology
- Không có data classification (public, confidential, restricted)

**✅ RECOMMENDATION 7**: Thêm data classification metadata:
```yaml
Worker:
  metadata_security:
    type: jsonb
    description: |
      Security classification and access rules:
      {
        "data_class": "CONFIDENTIAL",
        "encryption_required": true,
        "pii_fields": ["national_id", "tax_id"],
        "access_scope": "SELF_AND_HR"
      }
```

---

### 10. **Organizational Flexibility - Matrix & Dotted Line**

#### ✅ **Workday Best Practice**
- Support matrix organizations
- Dotted line reporting
- Multiple supervisory orgs

#### ⭐ **Current xTalent Model**
- `org_relation` schema với dynamic relationships ✅
- Có thể model matrix qua RelationEdge ✅
- Nhưng thiếu explicit "dotted line" concept

**✅ RECOMMENDATION 8**: Thêm relationship types:
```yaml
RelationType:
  code: [
    OWNERSHIP,
    REPORTING_SOLID_LINE,   # NEW explicit
    REPORTING_DOTTED_LINE,  # NEW explicit
    FUNCTIONAL,
    MATRIX,
    DELEGATION
  ]
```

---

## Summary of Recommendations

### 🔴 HIGH PRIORITY (Critical for enterprise-level)

1. **Work Relationship Entity** - Tách Employee thành WorkRelationship + EmploymentContract
2. **Person Type** - Thêm system person types (Employee, Contractor, Contingent, Non-worker)
3. **Supervisory Organization** - Thêm type hoặc entity cho supervisory structure

### 🟡 MEDIUM PRIORITY (Enhance functionality)

4. **Staffing Model Flexibility** - Support cả Position-based và Job-based assignments
5. **Job Family Shortcut** - Denormalized link for performance
6. **Skill Gap Analysis** - Target levels and gap tracking

### 🟢 LOW PRIORITY (Nice to have)

7. **Data Classification** - Security metadata
8. **Explicit Dotted Line** - Clearer matrix organization support

---

## Comparison Matrix

| Feature | Workday | SAP SF | Oracle | xTalent | Status |
|---------|---------|--------|--------|---------|--------|
| Person-Worker-Employee Separation | ✅ | ✅ | ✅ | ⚠️ (Missing Work Relationship) | 🟡 Need Improvement |
| Person Types | ✅ | ✅ | ✅ | ⚠️ (Partial) | 🟡 Need Improvement |
| Supervisory Organization | ✅ | ⚠️ | ✅ | ⚠️ | 🟡 Need Improvement |
| Position vs Job Management | ✅ | ✅ | ✅ | ⚠️ (Partial) | 🟡 Need Improvement |
| Multi-tree Job Taxonomy | ⚠️ | ✅ | ⚠️ | ✅ | 🟢 Best in Class |
| Global Assignment | ✅ | ✅ | ✅ | ✅ | 🟢 Excellent |
| SCD Type 2 Temporal Tracking | ✅ | ✅ | ✅ | ✅ | 🟢 Excellent |
| Skill & Competency | ✅ | ✅ | ✅ | ✅ | 🟢 Good |
| Dynamic Org Relations | ⚠️ | ⚠️ | ⚠️ | ✅ | 🟢 Best in Class |
| Historical Snapshots | ✅ | ✅ | ✅ | ✅ | 🟢 Excellent |

**Legend**: ✅ Excellent | ⚠️ Partial/Needs Work | ❌ Missing

---

## Conclusion

Ontology Core hiện tại đã được thiết kế **rất tốt** với nhiều điểm sáng:
- ✅ Multi-tree architecture (vượt trội hơn cả Workday!)
- ✅ Dynamic organization relations
- ✅ Global assignment support
- ✅ Comprehensive temporal tracking

**Cần cải tiến** để đạt full enterprise-level:
1. Work Relationship concept (học từ Workday/Oracle)
2. Person Types (system-wide categorization)
3. Supervisory Organization (critical for large enterprises)

**Ưu tiên thực hiện**: Recommendations #1, #2, #3 trước, sau đó #4-#8.

---

**Next Steps**:
1. Review recommendations với team
2. Update ontology file với approved changes
3. Update database design tương ứng
4. Document migration path từ current model sang enhanced model

**Approval Required**: Product Owner, Technical Architect, HR Domain Expert
