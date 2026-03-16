# Core Module (CO) — Deep Analysis

**File**: `1.Core.V4.dbml` (1,759 lines)  
**Last updated**: Feb 2026  
**Assessed**: 2026-03-16

---

## 1. Schema Inventory

| # | Schema | Tables | Lines | Purpose |
|:-:|--------|:------:|:-----:|---------|
| 1 | `common` | 9 | ~180 | Master data: code_list, currency, timezone, industry, contact_type, relationship, skill, talent_market |
| 2 | `geo` | 3 | ~50 | Geography: country, admin_area, country_locale |
| 3 | `org_legal` | 4 | ~120 | Legal entities: entity, entity_classification, entity_division, entity_parameter |
| 4 | `org_bu` | 3 | ~90 | Business units: unit, unit_xref, unit_tag |
| 5 | `org_relation` | 1 | ~30 | Org relations: org_relation |
| 6 | `org_assignment` | 1 | ~30 | Org assignment: org_matrix_assignment |
| 7 | `org_snapshot` | 1 | ~20 | Org snapshot: org_snapshot |
| 8 | `person` | 5 | ~200 | Person/worker: worker, person, document, contact, worker_relationship |
| 9 | `employment` | 7 | ~350 | Employment: employee, contract_template, contract, assignment, employee_identifier, global_assignment, work_relationship |
| 10 | `jobpos` | 14 | ~450 | Jobs/Positions: taxonomy_tree, job_taxonomy, taxonomy_xmap, job_taxonomy_map, job_tree, job, job_xmap, job_profile, job_profile_skill, job_level, job_level_org_map, job_grade, job_grade_org_map, position, position_tag, position_location, job_level_policy |
| 11 | `career` | 3 | ~60 | Career: career_path, career_step, job_progression |
| 12 | `facility` | 3 | ~60 | Facility: place, location, work_location |
| 13 | `vendor` | 1 | ~25 | Vendor: company |
| 14 | `tax` | 1 | ~25 | Tax: dependent_registration |
| 15 | `eligibility` | 3 | ~80 | Eligibility engine: eligibility_profile, eligibility_member, eligibility_evaluation |
| 16 | `compensation` | 2 | ~90 | Compensation basis: basis, basis_line |

**Tổng**: ~60 tables, 16 schemas, 1,759 lines

---

## 2. Strengths (Điểm mạnh)

### 2.1 Comprehensive Foundation — 5/5

Core bao phủ rất đầy đủ các domain cần thiết cho HCM:
- **Master data**: code_list pattern linh hoạt, multi-purpose
- **Org structure**: Legal entity + Business unit tách biệt rõ ràng
- **Person/Employment**: Worker → Employee → Assignment → Position chain hoàn chỉnh
- **Job/Position**: Multi-layer taxonomy system hỗ trợ override/inherit
- **Geography**: Country + Admin area cho multi-jurisdiction

### 2.2 Multi-Scope Architecture — 5/5

Pattern `owner_scope` (CORP | LE | BU) + `owner_unit_id` xuất hiện khắp nơi:
- `jobpos.taxonomy_tree` — taxonomy trees per scope
- `jobpos.job` — jobs with override/inherit per scope
- `jobpos.job_level_policy` — policies per scope
- `eligibility.eligibility_profile` — profiles per domain

→ Cho phép tập đoàn define global, BU/LE override local. **Đây là pattern rất mạnh** cho multi-entity deployment.

### 2.3 SCD Type-2 Consistency — 4.5/5

Hầu hết config tables đều có:
```
effective_start_date  date
effective_end_date    date [null]
is_current_flag       boolean [default: true]
```

Version tracking via `previous_*_id` self-referencing (ở `compensation.basis`).

> Trừ `common.code_list` không có `created_at/updated_at` — minor inconsistency.

### 2.4 Staffing Model Flexibility — 5/5

`employment.assignment` hỗ trợ 3 models (added Feb 2026):
1. **POSITION_BASED**: position_id required, job_id derived
2. **JOB_BASED**: job_id required, position_id optional
3. **HYBRID**: at least one required

→ Enforcement ở application layer via `LegalEntity.staffing_model_code`. Rất linh hoạt cho đa dạng loại tổ chức.

### 2.5 Eligibility Engine — 4/5

Design solid:
- `eligibility_profile` — rule-based (JSON criteria), domain-aware, priority-based
- `eligibility_member` — cached membership cho O(1) lookup, auto/manual/override
- `eligibility_evaluation` — immutable audit trail

Tuy nhiên thiếu:
- Batch evaluation scheduling table
- Profile grouping/bundling (combine multiple profiles)

### 2.6 Contract Management — 4.5/5

`employment.contract` hỗ trợ:
- Template-based (link to `contract_template`)
- Parent-child relationships (AMENDMENT, ADDENDUM, RENEWAL, SUPERSESSION)
- Supplier/vendor for outsourced workers
- Is_main flag for primary contract

---

## 3. Weaknesses (Điểm yếu)

### 3.1 File Size — Quá lớn ⚠️

1,759 lines trong 1 file DBML là **khó maintain**. 16 schemas đều nằm chung.

**Đề xuất**: Tách thành nhiều files theo logical grouping:
- `core-master-data.dbml` — common, geo
- `core-organization.dbml` — org_legal, org_bu, org_relation, org_assignment, org_snapshot
- `core-person-employment.dbml` — person, employment
- `core-job-position.dbml` — jobpos, career
- `core-facility-vendor.dbml` — facility, vendor
- `core-eligibility.dbml` — eligibility
- `core-compensation.dbml` — compensation, tax

### 3.2 Naming Inconsistencies ⚠️

| Pattern | Ví dụ | Vấn đề |
|---------|-------|--------|
| Date fields | `created_at` vs `created_date` vs `hire_date` | Thiếu convention thống nhất |
| FK naming | `_code` vs `_id` cho cùng loại reference | `employee_type_code` → code_list vs `position_id` → uuid |
| Status fields | `status_code` vs `status` vs `state_code` | Inconsistent suffix |
| Boolean naming | `is_active` vs `is_current_flag` vs `primary_flag` | Mix `is_` prefix với `_flag` suffix |

**Đề xuất**: Standardize:
- Timestamps: `created_at`, `updated_at` (always)
- Date fields: `{name}_date` for business dates
- FK to uuid: `{entity}_id`
- FK to code: `{entity}_code`
- Status: `status_code` (always)
- Boolean: `is_{name}` (drop `_flag`)

### 3.3 Compensation.basis Placement — Cần thảo luận 🔴

`compensation.basis` + `compensation.basis_line` (lines 1637-1757) nằm ở Core module nhưng:

**Thuộc Core** (arguments):
- Compensation basis là operational data gắn với `work_relationship` (Core entity)
- Contract-linked (`contract_id` FK)
- VN-specific fields (`social_insurance_basis`, `regional_min_wage_zone`)
- Represents "what employee is paid" — fundamental employment data

**Thuộc TR** (arguments):
- Links to `comp_core.salary_basis` config (TR entity)
- Has `approval_status` workflow — compensation concern
- Aggregated allowance tracking — compensation concern
- TR module manages compensation lifecycle

**Đánh giá**: Hiện tại ở Core là **hợp lý** vì:
1. Basis amount là operational data (như hire_date) — nằm cạnh employee
2. TR manages **policy/config** (salary_basis, pay_component_def, grade); Core lưu **fact** (actual salary)
3. Pattern tương tự Oracle HCM: Salary basis config ở Compensation, actual salary ở Core HR

> **Recommendation**: Giữ ở Core. Rename schema thành `emp_comp` (employee compensation) cho rõ ràng hơn.

### 3.4 Talent Market — Overlap với Country Config 🟡

`common.talent_market` + `common.talent_market_parameter`:
- `talent_market` lưu market (code, country_code, currency_code) — 1 country có thể nhiều markets
- `talent_market_parameter` lưu max_si_basis, min_wage, etc.

Nhưng TR's `comp_core.country_config` lưu:
- `standard_working_hours_per_day/week/month`
- `tax_system`, `si_system`

→ **2 nơi lưu country-level config**: `talent_market_parameter` (Core) vs `country_config` (TR).

**Đề xuất**: Merge `country_config` fields vào `talent_market_parameter` hoặc tạo `common.country_config` ở Core. Detail tại Doc 06.

### 3.5 Job/Position Schema Complexity 🟡

`jobpos` schema có **14+ tables** với 2 hệ thống tree (taxonomy_tree + job_tree) + cross-tree mapping + multi-level override/inherit.

Pro: Rất flexible cho corporate + BU independence.  
Con: **Cognitive complexity cao** — developer mới sẽ khó hiểu.

**Đề xuất**: Thêm documentation (ADR) giải thích design rationale. Không cần simplify vì business requirement thực sự phức tạp.

### 3.6 Missing Entities/Features 🟡

| Missing | Priority | Reason |
|---------|:--------:|--------|
| `common.notification_template` | P2 | Email/SMS templates for HR events |
| `common.sequence_generator` | P2 | Auto-numbering for employee_code, contract_number |
| `person.emergency_contact` | P1 | Separate from worker_relationship for quick access |
| `employment.probation` | P1 | Currently in metadata JSON — should be explicit |
| `employment.termination` | P1 | Termination details (reason, type, clearance) — currently just dates |
| `org_bu.cost_center` | P1 | Cost centers for financial allocation |

---

## 4. Index Analysis

### Well-indexed tables ✅
- `employment.assignment` — 5 indexes including supervisor, position, job, BU
- `eligibility.eligibility_member` — 4 indexes with filtered indexes
- `jobpos.job` — indexes on tree_id, grade_code, level_code

### Missing indexes ⚠️

| Table | Suggested Index | Reason |
|-------|-----------------|--------|
| `employment.employee` | `(status_code, hire_date)` | Filter active employees by hire date |
| `person.worker` | `(last_name, first_name)` | Name-based search |
| `person.contact` | `(worker_id, contact_type_code)` | Contact lookup by type |
| `employment.contract` | `(employee_id, start_date)` | Contract history |
| `compensation.basis` | `(basis_type_code, is_current_flag)` | Filter by type |

---

## 5. Cross-Module References

### Outbound References (Core → Other modules)

| From (Core) | To (Module) | Via | Hiện trạng |
|-------------|:-----------:|-----|:----------:|
| `employment.assignment.work_pattern_code` | TA | varchar pattern code reference | Comment only |
| `compensation.basis.salary_basis_id` | TR | uuid (no FK constraint) | ⚠️ Loose coupling |
| `eligibility.eligibility_profile.domain` | All | Domain enum: ABSENCE, BENEFITS, COMPENSATION, CORE | ✅ Designed |

### Inbound References (Other modules → Core)

| From (Module) | To (Core) | Via |
|:-------------:|-----------|-----|
| TA | `employment.employee.id` | FK on worker_id fields |
| TR | `employment.employee.id` | FK on employee_id fields |
| PR | `employment.employee.id` | FK on employee_id fields |
| TA | `eligibility.eligibility_profile.id` | FK on default_eligibility_profile_id |
| TR | *(own eligibility)* | ⚠️ Not using Core eligibility |

---

## 6. Improvement Proposals

### P0 — Critical

| # | Improvement | Effort | Impact |
|:-:|-------------|:------:|:------:|
| 1 | **Consolidate eligibility**: Migrate TR `benefit.eligibility_profile` → Core `eligibility.eligibility_profile` | 1 sprint | All modules |
| 2 | **Unify country config**: Merge `talent_market_parameter` + TR `country_config` → single Core source | 1 sprint | TR, PR, TA |
| 3 | **Clarify compensation.basis scope**: Rename schema to `emp_comp`, document ownership boundary | Discussion | CO, TR |

### P1 — Important

| # | Improvement | Effort | Impact |
|:-:|-------------|:------:|:------:|
| 4 | **Add explicit entities**: probation, termination, emergency_contact, cost_center | 2 sprints | CO |
| 5 | **Naming convention audit**: Apply standards across all tables | 1 sprint | All |
| 6 | **Split DBML file**: Từ 1 file → 7 files theo schema group | 0.5 sprint | CO |
| 7 | **Add missing indexes**: Per section 4 analysis | 0.5 sprint | CO |

### P2 — Nice to Have

| # | Improvement | Effort | Impact |
|:-:|-------------|:------:|:------:|
| 8 | Notification template support | 1 sprint | CO |
| 9 | Sequence generator for auto-numbering | 0.5 sprint | CO |
| 10 | ADR documentation for job/position design | Documentation | CO |

---

## 7. Score Summary

| Criterion | Score | Notes |
|-----------|:-----:|-------|
| Schema coverage | 4.5/5 | Comprehensive — covers all HCM foundational domains |
| SCD-2 consistency | 4.5/5 | Well-applied — minor inconsistencies in some tables |
| Multi-scope support | 5.0/5 | Excellent — taxonomy/job tree with override/inherit |
| Naming consistency | 3.0/5 | Significant inconsistencies in date/status/boolean naming |
| Normalization | 4.5/5 | Good separation, code_list pattern effective |
| File organization | 2.5/5 | Single 1759-line file is too large |
| Cross-module readiness | 3.5/5 | Eligibility foundation good but unused by TR; country config fragmented |
| **Overall** | **4.2/5** | Strong foundation needing naming standardization and config consolidation |

---

*← [00 Deep Analysis Plan](./00-deep-analysis-plan.md) · [02 TA Analysis →](./02-ta-analysis.md)*
