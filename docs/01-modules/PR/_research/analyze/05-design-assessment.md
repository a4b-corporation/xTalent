# Current Design Assessment & Re-Design Recommendations

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-06  
**Đối tượng**: Solution Architect, Product Owner, CTO  
**Thời gian đọc**: ~25 phút

---

## 1. Đối tượng đánh giá

| Artifact | Version | Lines | Schemas |
|----------|---------|:-----:|---------|
| PR DBML | V3 (Jul 2025) | 545 | `pay_master` (14 tables), `pay_run` (8), `pay_gateway` (4), `pay_bank` (3), `pay_audit` (1), standalone (4) |
| TR DBML | V5 (Nov 2025) | 1,445 | `comp_core` (12), `comp_incentive` (6), `benefit` (8), `recognition` (5), `tr_offer` (5), `tr_taxable` (1), `tr_statement` (4), `tr_audit` (1) |
| PR Overview Docs | 8 documents | ~2,400 | Conceptual architecture, Formula Engine, Integration |
| TR Overview Docs | 7 documents | ~2,000 | Compensation, Benefits, Calculation, Integration |

---

## 2. PR Module — Điểm mạnh

### 2.1 Schema Design ✅

| Strength | Evidence | Score |
|----------|---------|:-----:|
| **Clean schema separation** | 4 schemas rõ ràng: master, run, gateway, bank | 4/5 |
| **Immutable run data** | `pay_run.result`, `pay_run.balance` — append-only | 5/5 |
| **Retro support** | `pay_run.retro_delta` với `orig_batch_id` reference | 4/5 |
| **Calculation tracing** | `pay_run.calc_log` — step-by-step trace | 4/5 |
| **SCD-2 for config** | All master tables have `effective_start/end + is_current_flag` | 5/5 |
| **Gateway abstraction** | `pay_gateway.iface_def` — configurable interfaces | 4/5 |
| **Bank file generation** | `bank_template` + `payment_batch/line` — complete flow | 4/5 |
| **Costing/GL** | `pay_run.costing` + `pay_master.gl_mapping` | 4/5 |

### 2.2 Engine Architecture ✅

| Strength | Evidence | Score |
|----------|---------|:-----:|
| **Drools 8 + MVEL** | Enterprise-grade rule engine, proven at scale | 5/5 |
| **Business DSL Layer** | HR-friendly formula syntax wrapping Drools | 5/5 |
| **5-layer Security** | MVEL dialect restriction → classloader → timeout → whitelist → audit | 5/5 |
| **3 Execution Modes** | DryRun, Simulation, Production — complete lifecycle | 5/5 |
| **5-stage Pipeline** | Pre-validation → Gross → SI → Tax → Net + PostProcess | 5/5 |
| **Dependency Management** | Formula dependency graph, circular detection | 4/5 |

### 2.3 Conceptual Design ✅

| Strength | Evidence | Score |
|----------|---------|:-----:|
| **PayProfile concept** | Bundle policy approach — flexible per LE/market | 4/5 |
| **Event-driven integration** | Documented inbound/outbound event model | 4/5 |
| **Multi-entity support** | pay_calendar → legal_entity + market + frequency | 4/5 |

**Tổng điểm mạnh**: **4.3/5** — PR module có foundation tốt.

---

## 3. PR Module — Điểm yếu

### 3.1 Schema Gaps ❌

| Weakness | Impact | Severity |
|----------|--------|:--------:|
| **pay_element quá đơn giản** | Chỉ có `classification` (3 types), thiếu tax_treatment, proration_method, si_basis | **Critical** |
| **Thiếu country_config** | Không biết standard working hours/days per country | **High** |
| **Thiếu holiday_calendar** | OT multiplier determination không có data source | **High** |
| **Không có employer_contribution classification** | BHXH employer chỉ là DEDUCTION? — semantically wrong | **Medium** |
| **pay_element.name chỉ 100 chars** | TR component name 200 chars — truncation risk | **Low** |
| **Decimal precision (18,2)** | Tất cả amounts chỉ 2 decimal places — forex/crypto may need more | **Medium** |
| **pay_profile schema quá lean** | Chỉ có code/name/LE/market — thiếu component mapping, rule binding | **Critical** |

### 3.2 Architecture Gaps ❌

| Weakness | Impact | Severity |
|----------|--------|:--------:|
| **Không có API contract** | Giao tiếp internal, không formal spec | **Critical** |
| **PR ↔ TR boundary mờ** | Overlap calculation logic — xem Doc 02 & 03 | **Critical** |
| **pay_formula chỉ lưu script text** | Không phân biệt formula type, không version control logic | **High** |
| **statutory_rule generic** | formula_json chứa tất cả — không structured cho tax brackets vs SI rates | **High** |
| **Không có input staging** | Compensation data trực tiếp vào pay_run — không có staging/validation layer | **Medium** |
| **Import job thiếu mapping** | import_job tracks job nhưng không map file columns → elements | **Medium** |

### 3.3 Missing Entities ❌

| Missing Entity | Available in TR? | Should be in PR? | Priority |
|---------------|:---:|:---:|:---:|
| Country configuration | ✅ `comp_core.country_config` | ✅ Yes | P0 |
| Holiday calendar with OT | ✅ `comp_core.holiday_calendar` | ✅ Yes | P0 |
| Element tax treatment | ✅ `pay_component_def.tax_treatment` | ✅ Yes (as field) | P0 |
| Proration method | ✅ `pay_component_def.proration_method` | ✅ Yes (as field) | P0 |
| SI calculation basis | ✅ `pay_component_def.si_calculation_basis` | ✅ Yes (as field) | P1 |
| Tax exempt threshold | ✅ `pay_component_def.tax_exempt_threshold` | ✅ Yes (as field) | P1 |
| Calculation cache | ✅ `comp_core.tax_calculation_cache` | ✅ Yes | P2 |
| Input staging table | ❌ | ✅ Yes (new) | P1 |
| Payroll notification config | ❌ | ✅ Yes (new) | P2 |

---

## 4. TR Module — Assessment (Payroll-relevant parts)

### 4.1 Điểm mạnh của TR cho Payroll

| Strength | Score |
|----------|:-----:|
| Rich component metadata (tax_treatment, proration, SI flags) | 5/5 |
| Employee comp snapshot — current salary by component | 5/5 |
| Taxable bridge (equity/perk → payroll) | 5/5 |
| Multi-scope pay ranges | 4/5 |
| Calculation rule versioning (SCD-2) | 4/5 |
| Benefit premium tracking | 4/5 |

### 4.2 Warning: TR Overreach

| Concern | Details |
|---------|---------|
| **TR has full gross→net pipeline** | `basis_calculation_rule.execution_order` 1→6 covers proration→gross→SI→tax→net |
| **TR has calculation cache** | `tax_calculation_cache` — performance optimization is engine concern |
| **TR defines OT multiplier lookup** | `calculation_rule_def` VN_OT_MULT_2019 — this is payroll calculation |

> **Kết luận**: TR đang **overextend into payroll territory**. 4 tables thêm ngày 25Nov2025 (`calculation_rule_def`, `basis_calculation_rule`, `component_calculation_rule`, `tax_calculation_cache`) nên được re-scope hoặc migrate sang PR.

---

## 5. Cần Re-design PR không?

### 5.1 Đánh giá theo tiêu chí

| Criterion | Current | Target | Gap | Re-design needed? |
|-----------|:-------:|:------:|:---:|:-:|
| Bounded Context | ⚠️ Blurry | Clear | Major | **Yes** |
| API-first | ❌ No | Full API spec | Major | **Yes** |
| Schema completeness | ⚠️ Lean | Rich | Medium | **Partial** |
| Engine architecture | ✅ Good | Same | None | **No** |
| Independence | ❌ Internal module | Standalone service | Major | **Yes** |
| Compliance | ✅ Good | Same | Minor | **No** |

### 5.2 Verdict: **Partial Re-design (Moderate scope)**

Engine architecture (Drools 8 + 5-stage pipeline + Business DSL) is **excellent** — NO re-design needed.

Schema và API need **significant enhancement** — YES re-design needed.

---

## 6. Re-Design Roadmap

### Level 1: Minimal Change (2-3 sprints, ưu tiên cao nhất)

> Mục tiêu: Clear boundary, richer schema, no architecture change

| Change | Action | Effort |
|--------|--------|:------:|
| Enrich `pay_element` | Add: `tax_treatment`, `proration_method`, `si_basis`, `tax_exempt_cap`, `calculation_method` | 1 sprint |
| Add `country_config` to PR | New table: working hours/days per country | 0.5 sprint |
| Add `holiday_calendar` to PR | New table: holidays + OT multipliers | 0.5 sprint |
| Upgrade classifications | EARNING → BASE/ALLOWANCE/BONUS/OVERTIME; add EMPLOYER_CONTRIBUTION + INFORMATIONAL | 1 sprint |
| Re-scope PR → TR boundary | Document + discuss ownership for overlap entities | Discussion |
| Decimal precision upgrade | `decimal(18,2)` → `decimal(18,4)` globally | 0.5 sprint |

### Level 2: Moderate Change (3-4 sprints)

> Mục tiêu: API-first, independent deployment ready

| Change | Action | Effort |
|--------|--------|:------:|
| Define OpenAPI spec | Per Doc 04 — ~28 endpoints | 2 sprints |
| Input staging layer | New `pay_staging.*` schema for compensation/attendance data | 1 sprint |
| Event schema formalization | AsyncAPI spec for 9 published + 7 consumed events | 1 sprint |
| Rich PayProfile schema | Component mapping, rule binding, execution pipeline config | 1 sprint |
| Structured StatutoryRule | Separate schemas for TAX_TABLE, SI_RATE, OT_MULTIPLIER instead of generic formula_json | 1 sprint |

### Level 3: Full Headless (4-6 sprints, future)

> Mục tiêu: Standalone deployable payroll service

| Change | Action | Effort |
|--------|--------|:------:|
| Independent database | Separate DB instance, no shared schema references | 1 sprint |
| Service mesh integration | Health check, circuit breaker, rate limiting | 1 sprint |
| Multi-tenant support | Tenant isolation, configurable per-tenant | 2 sprints |
| API versioning infrastructure | v1/v2 coexistence, deprecation policy | 1 sprint |
| Documentation + SDK | Client SDK generation, developer portal | 1 sprint |

---

## 7. Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|:-----------:|:------:|-----------|
| TR team resistance to losing calculation ownership | High | High | Frame as "re-scope", not "take away". TR keeps component config, PR takes calculation execution |
| Data migration complexity | Medium | High | Start with new deployments, migrate existing in parallel |
| API contract breaking existing integrations | Low | High | Internal-first: define contract, then align existing code |
| Performance regression from API layer | Low | Medium | Bulk APIs, batch processing, calculation caching |
| Increased operational complexity | Medium | Medium | Start with Level 1, prove value before Level 2-3 |

---

## 8. Tóm tắt Đánh giá

| Area | Current Score | After Level 1 | After Level 2 | After Level 3 |
|------|:------------:|:-------------:|:-------------:|:-------------:|
| Schema Design | 3.5/5 | 4.5/5 | 4.8/5 | 5.0/5 |
| Engine Architecture | 4.8/5 | 4.8/5 | 4.8/5 | 4.8/5 |
| Independence | 1.5/5 | 2.5/5 | 4.0/5 | 5.0/5 |
| API Readiness | 1.0/5 | 1.5/5 | 4.5/5 | 5.0/5 |
| **Overall** | **2.7/5** | **3.3/5** | **4.5/5** | **5.0/5** |

> **Bottom line**: PR engine is strong, PR schema/API is weak. Level 1 changes give the most ROI with least risk.

---

*← [04 Payroll API Contract Design](./04-payroll-api-contract-design.md) · [06 Integration Event & Data Flow →](./06-integration-event-data-flow.md)*
