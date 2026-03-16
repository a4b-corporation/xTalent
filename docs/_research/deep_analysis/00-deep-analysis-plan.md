# xTalent Database Design — Deep Analysis Plan

**Ngày**: 2026-03-16  
**Scope**: Đánh giá tổng thể thiết kế DBML cho 4 module: Core (CO), Time & Absence (TA), Total Rewards (TR), Payroll (PR)  
**Output directory**: `docs/_research/deep_analysis/`

---

## 1. Tổng quan hiện trạng

### Files đã phân tích

| Module | File | Version | Lines | Schemas |
|--------|------|---------|:-----:|---------|
| **Core (CO)** | `1.Core.V4.dbml` | V4 (Feb 2026) | 1,759 | `common`, `geo`, `org_legal`, `org_bu`, `org_relation`, `org_assignment`, `org_snapshot`, `person`, `employment`, `jobpos`, `career`, `facility`, `vendor`, `tax`, `eligibility`, `compensation` |
| **Time & Absence** | `TA-database-design-v5.dbml` | V5.1 (Dec 2025) | 1,352 | `ta` (6-level hierarchy + operational), `absence`, `shared` |
| **Absence** | `3.Absence.v4.dbml` | V4 (Oct 2025) | 353 | `absence` (ledger model, leave class/instant/movement) |
| **Total Rewards** | `4.TotalReward.V5.dbml` | V5 (Nov 2025) | 1,445 | `comp_core`, `comp_incentive`, `benefit`, `recognition`, `tr_offer`, `tr_taxable`, `tr_statement`, `tr_audit` |
| **Payroll** | `5.Payroll.V3.dbml` | V3 (Jul 2025) | 545 | `pay_master`, `pay_run`, `pay_gateway`, `pay_bank`, `pay_audit` |

### Research documents (đã đọc)
- 6 tài liệu phân tích headless payroll tại `PR/_research/analyze/`
- Key findings: TR-PR boundary overlap, calculation responsibility split, design assessment scores

---

## 2. Trả lời câu hỏi trực tiếp

### 2.1 Eligibility nên move tập trung về Core?

**Trả lời: CÓ — và thực tế đã được thiết kế ở Core rồi.**

Core DBML V4 đã có schema `eligibility` (lines 1549-1630) với 3 tables:
- `eligibility.eligibility_profile` — định nghĩa rule JSON cho organizational scope
- `eligibility.eligibility_member` — cached membership cho O(1) lookup
- `eligibility.eligibility_evaluation` — immutable audit log

TA DBML V5.1 đã tích hợp bằng cách thêm `default_eligibility_profile_id` vào `leave_type`, `leave_class`, `leave_policy` (trỏ về `core.eligibility_profile`). TR cũng có `benefit.eligibility_profile` riêng.

> **Vấn đề hiện tại**: TR có `benefit.eligibility_profile` riêng (lines 624-640) — đây là **duplicate** với Core's `eligibility.eligibility_profile`. Cần consolidate.

**Đề xuất**:
1. ✅ Core `eligibility.*` đã đúng hướng — giữ nguyên
2. 🔄 TR's `benefit.eligibility_profile` + `benefit.plan_eligibility` → deprecate, chuyển sang dùng Core
3. 🔄 TA's `absence.leave_class.eligibility_json` → đã deprecate (OK)
4. ⚠️ Cần đảm bảo Core eligibility engine hỗ trợ đủ domain: `ABSENCE | BENEFITS | COMPENSATION | CORE`

---

### 2.2 Country configuration trong Total Rewards đã clear chưa?

**Trả lời: CHƯA CLEAR — có multiple sources gây confuse.**

Hiện tại `country` xuất hiện ở **4 nơi khác nhau**:

| Location | Entity | Purpose | Vấn đề |
|----------|--------|---------|--------|
| **Core** | `geo.country` | ISO-3166 master data | ✅ OK — đây là master |
| **Core** | `common.talent_market` | Market/thị trường (broader than country) | ⚠️ Market ≠ Country |
| **TR** | `comp_core.country_config` (lines 1306-1341) | Working hours/days, tax/SI system | ⚠️ Overlap với talent_market_parameter |
| **TR** | `comp_core.holiday_calendar` (lines 1344-1374) | Holidays + OT multiplier | ⚠️ Trùng với absence.holiday_calendar |

**3 vấn đề chính**:
1. **Talent Market vs Country**: Core dùng `talent_market` (có thể là region, không phải country). TR dùng `country_config` với `country_code` (ISO). Hai concept này không mapping 1:1
2. **Holiday Calendar trùng**: TR có `comp_core.holiday_calendar`, Absence có `absence.holiday_calendar`, TA reference cả hai. **3 bản sao**
3. **Working hours/days**: TR's `country_config` lưu `standard_working_hours_per_day/week/month` nhưng PR không có table tương ứng → PR hardcode hoặc phải query TR

**Đề xuất**: Country configuration cần **1 single source of truth** — nên nằm ở **Core** vì mọi module đều cần:
- `geo.country` → master country data (đã có)
- Move `comp_core.country_config` → `common.country_config` (Core)
- Consolidate holiday calendars → 1 bảng duy nhất ở Core hoặc Shared

---

### 2.3 Total Rewards formulas cho Offer/Statement: mini engine hay gọi Payroll?

**Trả lời: NÊN GỌI PAYROLL ENGINE (Preview/DryRun mode).**

**Phân tích**:
- TR cần tính gross→net cho **Offer Statement** (ước tính lương cho ứng viên) và **Total Reward Statement** (báo cáo lương cho employee)
- PR Engine đã có **3 execution modes**: DryRun, Simulation, Production
- Nếu TR build mini engine riêng → trùng lặp logic tax/SI/proration → **desync risk cao**

**Recommendation** (align với Doc 03 - Calculation Responsibility Split):

```
TR (Offer/Statement)                    PR Engine (Preview API)
────────────────────                    ─────────────────────
1. Tạo offer_package                    
   → collect components, amounts
   → gọi PR Preview API ──────────────▶ 2. PR nhận compensation data
                                           → chạy DryRun mode
                                           → trả về: gross, tax, SI, net
                                        ◀───── preview_result
3. Hiển thị trên Statement
   (actual amounts from PR calc)
```

| Approach | Pros | Cons |
|----------|------|------|
| **Mini engine ở TR** | Nhanh, không phụ thuộc PR | Duplicate logic, desync risk, maintenance x2 |
| **Gọi PR DryRun** ✅ | Single source of truth, luôn chính xác | Phụ thuộc PR service availability |
| **Shared calc module** | Tránh duplicate | Thêm 1 component phải maintain |

**Đề xuất**: **Option 2 — PR DryRun API** là best practice. PR cần expose `POST /api/v1/payroll/preview` endpoint.

---

## 3. Đánh giá tổng thể từng module

### 3.1 Core Module (CO) — Score: 4.2/5

| Aspect | Score | Assessment |
|--------|:-----:|------------|
| Schema coverage | 4.5/5 | Rất đầy đủ: org legal, BU, person, employment, job/position, facility, vendor, tax, eligibility, compensation basis |
| SCD-2 consistency | 4.5/5 | Hầu hết tables đều có effective_start/end + is_current_flag |
| Naming consistency | 3.5/5 | Mix giữa `_code` và `_id` cho FK, inconsistent date naming (`created_at` vs `created_date`) |
| Normalization | 4.5/5 | Tốt — code_list cho lookup, separate tables cho relationships |
| Multi-scope support | 4.5/5 | Taxonomy tree, job tree multi-layer, override/inherit pattern |
| Eligibility engine | 4.0/5 | Solid foundation — profile + member + evaluation + audit |

**Điểm mạnh**: Comprehensive, well-structured, good multi-scope support  
**Điểm yếu**: File too large (1759 lines = khó maintain), compensation.basis thuộc Core hay TR cần clarify

### 3.2 Time & Absence (TA) — Score: 3.8/5

| Aspect | Score | Assessment |
|--------|:-----:|------------|
| Architecture | 4.5/5 | 6-level hierarchy (Segment→Shift→Day→Pattern→Schedule→Roster) rất elegant |
| Schema consistency | 3.0/5 | Nhiều `_DUPLICATE` tables trong file, confusing |
| Absence model | 4.5/5 | LeaveClass + LeaveInstant + Movement ledger = accounting-grade |
| Integration | 3.5/5 | Holiday calendar bị duplicate, shared components chưa rõ |
| Eligibility integration | 4.0/5 | Đã tích hợp với Core eligibility |

**Điểm mạnh**: Absence ledger model rất tốt, 6-level hierarchy flexible  
**Điểm yếu**: File chứa cả old design + new design lẫn lộn với `_DUPLICATE` suffix

### 3.3 Total Rewards (TR) — Score: 3.9/5

| Aspect | Score | Assessment |
|--------|:-----:|------------|
| Domain coverage | 5.0/5 | Compensation, incentive, benefit, recognition, offer, statement — toàn diện |
| Calculation rules | 3.0/5 | Overextend vào payroll territory (tax brackets, gross→net pipeline) |
| Audit trail | 5.0/5 | Xuất sắc — `tr_audit.audit_log` + SCD-2 versioning |
| Country config | 2.5/5 | Overlap với Core/PR, chưa clear source of truth |
| Eligibility | 2.5/5 | Duplicate với Core (`benefit.eligibility_profile`) |
| Naming/precision | 4.5/5 | `decimal(18,4)` cho amounts, consistent naming |

**Điểm mạnh**: Rich domain model, excellent versioning  
**Điểm yếu**: Calculation rules overreach, eligibility duplicate, country config unclear

### 3.4 Payroll (PR) — Score: 3.3/5

| Aspect | Score | Assessment |
|--------|:-----:|------------|
| Engine architecture | 4.8/5 | Drools 8 + DSL + 5-stage pipeline = excellent |
| Schema design | 3.5/5 | Clean separation nhưng `pay_element` quá lean |
| Independence | 1.5/5 | Không có API contract, phụ thuộc nội bộ |
| Multi-country | 2.0/5 | Thiếu `country_config`, `holiday_calendar` |
| Run/Batch model | 4.5/5 | Immutable results, retro support, calc tracing |
| Bank/GL/Tax | 4.0/5 | Complete — bank templates, GL mapping, tax report |

**Điểm mạnh**: Engine architecture xuất sắc, run model solid  
**Điểm yếu**: Schema gaps (thiếu 7 entities/fields), no API contract, boundary mờ với TR

---

## 4. Kế hoạch phân tích chi tiết (Phases)

### Phase 1: Module-level Deep Analysis (Tài liệu chi tiết từng module)

| # | Output Document | Nội dung | Ưu tiên |
|:-:|----------------|----------|:-------:|
| 01 | `01-core-analysis.md` | Schema assessment, improvement proposals, naming standardization | P0 |
| 02 | `02-ta-analysis.md` | 6-level hierarchy eval, absence model eval, cleanup `_DUPLICATE` tables | P0 |
| 03 | `03-tr-analysis.md` | Calculation rules re-scope, eligibility consolidation, country config cleanup | P0 |
| 04 | `04-pr-analysis.md` | Schema enrichment plan, API contract requirements, country/holiday additions | P0 |

### Phase 2: Cross-Module Integration Analysis

| # | Output Document | Nội dung | Ưu tiên |
|:-:|----------------|----------|:-------:|
| 05 | `05-eligibility-consolidation.md` | Single eligibility engine — migration plan từ TR → Core | P0 |
| 06 | `06-country-config-unification.md` | Single source: country_config + holiday_calendar — where to live | P0 |
| 07 | `07-tr-pr-boundary-resolution.md` | Final decision: calculation ownership, component mapping, API contract | P0 |
| 08 | `08-cross-module-data-flow.md` | Complete data flow: CO ↔ TA ↔ TR ↔ PR, events, API boundaries | P1 |

### Phase 3: Improvement Recommendations

| # | Output Document | Nội dung | Ưu tiên |
|:-:|----------------|----------|:-------:|
| 09 | `09-naming-convention-standard.md` | Chuẩn hóa naming conventions across modules | P1 |
| 10 | `10-schema-improvement-roadmap.md` | Tổng hợp tất cả improvements, prioritized roadmap | P0 |

---

## 5. Phase 1 — Chi tiết từng tài liệu

### 5.1 Core Analysis (`01-core-analysis.md`)

**Nội dung phân tích**:
- [ ] Schema inventory: đếm tables theo schema, đánh giá coverage
- [ ] Compensation.basis — nên thuộc Core hay TR? (hiện ở Core)
- [ ] Eligibility engine — đủ cho cross-module chưa? Cần thêm gì?
- [ ] Talent Market vs Country — relationship mapping
- [ ] Multi-scope patterns — taxonomy tree, job tree: đánh giá flexibility
- [ ] Naming convention audit — tìm inconsistencies
- [ ] **Đề xuất cải tiến**:
  - Tách file lớn thành nhiều file theo schema
  - Standardize FK patterns (code vs id)
  - Add missing indexes

### 5.2 TA Analysis (`02-ta-analysis.md`)

**Nội dung phân tích**:
- [ ] 6-level hierarchy: có quá phức tạp không? Cần đơn giản hóa?
- [ ] `_DUPLICATE` tables cleanup plan
- [ ] Absence v4 ledger model — strengths & potential improvements
- [ ] Holiday calendar — consolidation với Core/TR
- [ ] TA ↔ PR integration: timesheet → payroll input flow
- [ ] **Đề xuất cải tiến**:
  - Clean up file: remove `_DUPLICATE`, keep only canonical design
  - Merge standalone Absence file vào TA main
  - Better TA→PR data pipeline (attendance data → pay_run.input_value)

### 5.3 TR Analysis (`03-tr-analysis.md`)

**Nội dung phân tích**:
- [ ] Calculation rules overreach — re-scope plan
- [ ] `benefit.eligibility_profile` → migrate to Core
- [ ] Country config ownership — move to Core
- [ ] Grade system — relationship với Core's job_grade
- [ ] Offer/Statement — integration with PR DryRun
- [ ] Compensation review cycle — completeness assessment
- [ ] **Đề xuất cải tiến**:
  - Deprecate `calculation_rule_def`, `basis_calculation_rule`, `component_calculation_rule`, `tax_calculation_cache` → re-scope as "component behavior config"
  - Remove `comp_core.holiday_calendar` (dùng shared/Core)
  - Consolidate eligibility to Core
  - Clarify `comp_core.country_config` scope (move or delegate)

### 5.4 PR Analysis (`04-pr-analysis.md`)

**Nội dung phân tích**:
- [ ] Schema enrichment — 7 missing entities/fields
- [ ] API contract design — leverage existing Doc 04
- [ ] PayProfile structure — flesh out from shell
- [ ] Element classification upgrade (3 → 6 types)
- [ ] Multi-country readiness
- [ ] **Đề xuất cải tiến**:
  - Enrich `pay_element` (add 5 fields)
  - Add `pay_master.country_config`
  - Add `pay_master.holiday_calendar`
  - Upgrade `decimal(18,2)` → `decimal(18,4)`
  - Define formal API contract (OpenAPI + AsyncAPI)
  - Input staging layer

---

## 6. Phase 2 — Cross-Module Integration

### 6.1 Eligibility Consolidation (`05-eligibility-consolidation.md`)
- Core as single eligibility engine
- Migration plan từ TR `benefit.eligibility_profile`
- Domain support: ABSENCE, BENEFITS, COMPENSATION, CORE, TIME_ATTENDANCE
- API contract cho eligibility queries

### 6.2 Country/Holiday Unification (`06-country-config-unification.md`)
- Single source at Core: `common.country_config` + `common.holiday_calendar`
- Mapping: `talent_market` ↔ `country_config` (1:N relationship)
- All modules consume from Core via API/FK
- Remove: `comp_core.country_config`, redundant `holiday_calendar` copies

### 6.3 TR-PR Boundary Resolution (`07-tr-pr-boundary-resolution.md`)
- Final ownership decision per domain concern
- Component → Element mapping contract
- Taxonomy alignment (6 types vs 3 classifications)
- Data flow: TR → PR (compensation snapshot API)
- PR DryRun API for TR Preview/Statement

### 6.4 Cross-Module Data Flow (`08-cross-module-data-flow.md`)
- CO → TA: employee, assignment, work schedule
- CO → TR: employee, grade, position
- CO → PR: employee, assignment, legal entity
- TA → PR: timesheet, attendance, overtime
- TR → PR: compensation snapshot, bonus, taxable items, benefit premiums
- PR → TR: payroll results (for statement)
- All → CO: eligibility evaluation triggers

---

## 7. Tiến độ đề xuất

| Phase | Effort | Deliverables | Timeline |
|:-----:|:------:|:------------:|:--------:|
| **Phase 1** | 4 docs | Module-level deep analysis | Bước 1 |
| **Phase 2** | 4 docs | Cross-module integration analysis | Bước 2 |
| **Phase 3** | 2 docs | Standards + Roadmap | Bước 3 |

> **Đề xuất**: Tiến hành từng Phase. Mỗi Phase output cần review trước khi sang Phase tiếp theo.

---

## 8. Summary — Các quyết định chính cần thảo luận

| # | Quyết định | Đề xuất | Impact |
|:-:|-----------|---------|:------:|
| 1 | Eligibility tập trung về Core? | **CÓ** — đã có foundation, cần migrate TR's benefit.eligibility | All modules |
| 2 | Country config ở đâu? | **Core** — single source, all modules consume | TR, PR, TA |
| 3 | Holiday calendar unified? | **CÓ** — 1 bảng duy nhất ở Core/Shared | TR, PR, TA |
| 4 | TR calculation rules re-scope? | **CÓ** — PR owns calculation, TR is config-only | TR, PR |
| 5 | Offer/Statement dùng mini engine? | **KHÔNG** — gọi PR DryRun API | TR, PR |
| 6 | PR schema enrichment? | **CÓ** — thêm 7 fields/tables (P0-P1) | PR |
| 7 | TR-PR component taxonomy? | **Thống nhất** — PR extend từ 3 → 6 classifications | TR, PR |
| 8 | compensation.basis ở Core hay TR? | **Cần thảo luận** — hiện ở Core, logically có thể thuộc TR | CO, TR |
