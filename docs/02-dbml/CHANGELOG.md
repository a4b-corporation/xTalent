# xTalent Database Design – Changelog


## [14Apr2026] – v4.3 PR: Architectural Audit Implementation (Changes 48–57)

> **Context:** Sau khi thực hiện architectural audit toàn diện trên Payroll V4 (cross-ref Core, TA, TR), phát hiện 10 gaps cần xử lý:
> - 3 gaps về data quality / type safety (source_type enum, proration tracking, circular FK doc)
> - 3 gaps về schema enrichment (element_id on costing_rule, assignment_id on manual_adjust, proration fields on result)
> - 2 gaps về cross-module integration (ta_period_id link, input_source_config mapping_json schema)
> - 1 gap về orphan tables thiếu schema prefix
> - 1 gap về cross-module FK thiếu (documented as TODO cross-module)
>
> **Nguyên tắc:** Các thay đổi liên quan đến module khác (TA, TR) được note thành TODO
> thay vì implement trực tiếp, trừ khi thay đổi nằm hoàn toàn trong Payroll schema.

### 5.Payroll.V4.dbml

**Change 48 — `pay_engine.input_value.source_type`: CANONICAL ENUM DOCUMENTED**

| Action | Field | Detail |
|--------|-------|--------|
| DOCUMENT | `source_type varchar(30)` | Canonical enum values documented in DBML comment. Enforcement: app-layer (không DB CHECK để dễ extend). |
| ADD comment | Canonical values | `TIME_ATTENDANCE \| ABSENCE \| COMPENSATION \| BENEFITS \| MANUAL \| PRODUCTION` |
| ADD Note | Table Note | Document cross-reference với `input_source_config.source_module` — must match |
| WARNING | Anti-pattern | Cấm dùng: `"TA"`, `"TimeAttendance"`, `"ta"`, `"time_attendance"` — phải dùng canonical form |

> **Rationale:** Free-text source_type dẫn đến inconsistency và mất traceability cross-module.
> App-layer enforcement (thay vì DB CHECK) cho phép thêm canonical values mà không cần migration.

**Change 49 — Circular FK Pattern: DOCUMENTED (pay_mgmt.batch ↔ pay_engine.run_request ↔ pay_engine.run_employee)**

| Action | Location | Detail |
|--------|----------|--------|
| DOCUMENT | `run_employee` header | Giải thích tại sao `run_employee.batch_id` là intentional denormalization |
| DOCUMENT | `batch.engine_request_id` | Giải thích tại sao nullable (circular creation order) |
| ADD app-layer constraint | Comment | `run_employee.batch_id MUST EQUAL run_request.batch_id WHERE run_request.id = run_employee.request_id` |

> **Circular reference pattern:**
> ```
> pay_mgmt.batch.engine_request_id → pay_engine.run_request.id  (batch tracks which request is running)
> pay_engine.run_request.batch_id  → pay_mgmt.batch.id          (request knows which batch it belongs to)
> pay_engine.run_employee.batch_id + .request_id  → INTENTIONAL DENORMALIZATION
> ```
> **Creation order:** batch (DRAFT) → run_request created → batch.engine_request_id patched.
> Không thể NOT NULL đồng thời cả 2 chiều → chấp nhận nullable + app-layer enforcement.

**Change 50 — `pay_master.costing_rule`: ADD `element_id` FK**

| Action | Field | Detail |
|--------|-------|--------|
| ADD | `element_id uuid [ref: > pay_master.pay_element.id, null]` | null = default costing cho tất cả elements; not null = override cho element cụ thể |
| ADD index | `(element_id) WHERE IS NOT NULL` | Fast element-scoped lookup |
| UPDATE Note | Resolution priority | Element-scoped rule (NOT NULL) override default rule (NULL) cho cùng employee |

> **Use case:** BASIC_SALARY → 60% Department + 40% Project; BHXH_ER → 100% Department.
> 2 costing_rule records khác nhau, engine chọn đúng theo element_id.

**Change 51 — `pay_mgmt.manual_adjust`: ADD `assignment_id` FK**

| Action | Field | Detail |
|--------|-------|--------|
| ADD | `assignment_id uuid [ref: > employment.assignment.id, null]` | null = primary assignment; not null = adjustment scoped cho assignment cụ thể |
| ADD index | `(assignment_id) WHERE IS NOT NULL` | Fast lookup |
| UPDATE Note | Multi-assignment rationale | Employee 50% Sales + 50% Admin: adjustment cần biết target assignment cho costing đúng |

**Change 52 — `pay_engine.result`: ADD Proration Tracking Fields**

| Action | Field | Detail |
|--------|-------|--------|
| ADD | `full_period_amount decimal(18,2) [null]` | Số tiền đầy đủ TRƯỚC proration (null = không prorate) |
| ADD | `proration_factor decimal(7,5) [null]` | Tỷ lệ thực tế = ngày_làm / tổng_ngày_kỳ (VD: 0.73333 = 22/30) |
| ADD | `proration_method varchar(20) [null]` | `CALENDAR_DAYS \| WORK_DAYS \| NONE` — frozen từ pay_profile tại thời điểm tính |
| UPDATE | classification comment | `EARNING \| DEDUCTION \| TAX \| EMPLOYER_COST` — explicit enum values |
| ADD index | `(proration_factor) WHERE NOT NULL` | Query các records có proration |

> **Công thức:** `result_amount = full_period_amount × proration_factor`
> **Cần thiết cho:** (1) Payslip "Lương ×22/30=X"; (2) Retro recalc; (3) Compliance audit.

**Change 53 — Orphan Tables: ADD Schema Prefix**

| Table | Old | New Schema |
|-------|-----|------------|
| `import_job` | No schema | `pay_gateway.import_job` |
| `generated_file` | No schema | `pay_gateway.generated_file` |
| `bank_template` | No schema | `pay_bank.bank_template` |
| `tax_report_template` | No schema | `pay_gateway.tax_report_template` |

> **Rationale:** Align với toàn bộ schema organization (pay_master, pay_mgmt, pay_engine, pay_bank, pay_gateway, pay_audit).
> Không có logic thay đổi, chỉ thêm schema prefix.

**Change 54 — `pay_engine.input_source_config.mapping_json`: SCHEMA DOCUMENTED**

| Source Module | Source Type | mapping_json Schema |
|---------------|-------------|---------------------|
| TIME_ATTENDANCE | TIMESHEET | `source_table, group_by, filter, value_field, input_code` |
| TIME_ATTENDANCE | OT_HOURS | `source_table, value_field, input_code, require_status` |
| COMPENSATION | COMP_BASIS_CHANGE | `source_table, filter, value_field, input_code, proration, effective_date_field` |
| ABSENCE | LEAVE_DEDUCTION | `source_table, filter, value_field, input_code, component_type` |
| ABSENCE | TERMINATION_LEAVE_BALANCE | `source_table, filter, value_field, input_code, component_type, batch_type_filter` |
| BENEFITS | BENEFIT_PREMIUM | `source_table, value_field, input_code, direction_filter` |

> **Tầm quan trọng:** mapping_json schema là data contract giữa các modules. Nếu không document,
> engineer không biết phải build gì khi implement INPUT_COLLECTION step.

**Change 55 — Cross-Module FK Gaps: DOCUMENTED AS COMMENTS**

| Gap | Location | Detail |
|-----|----------|--------|
| GAP-PR-001 | `comp_core.pay_component_def ↔ pay_master.pay_element` | Không có FK → engine dùng naming convention tạm. Options: add `payroll_element_id` vào TR, hoặc tạo `pay_master.component_element_map` |
| GAP-PR-002 | `ta.payroll_export_package.payroll_system_ref` | varchar soft-ref → cần FK cứng `payroll_run_request_id → pay_engine.run_request.id` |

> **Xem chi tiết:** `08-todo-cross-module-changes.md`

**Change 56 — `pay_mgmt.pay_period`: ADD `ta_period_id` FK**

| Action | Field | Detail |
|--------|-------|--------|
| ADD | `ta_period_id uuid [ref: > ta.period.id, null]` | null = không dùng TA integration cho period này |
| ADD index | `(ta_period_id) WHERE NOT NULL` | Fast lookup |
| ADD Note | Synchronization rule | TA period phải LOCKED trước khi PR bắt đầu INPUT_COLLECTION |
| ADD Note | Pre-flight check | Engine validate ta_period.status_code = 'LOCKED' trước khi start calculating |

> **Business rule:** `ta.period.status_code = 'LOCKED' → pay_mgmt.pay_period có thể PROCESSING`
> Engine block run nếu ta_period_id IS NOT NULL nhưng ta.period chưa LOCKED.

**Change 57 — `pay_engine.input_source_config`: TERMINATION_LEAVE_BALANCE Seed Record**

| Action | Detail |
|--------|--------|
| ADD source_type | `TERMINATION_LEAVE_BALANCE` — new canonical source_type for absence module |
| ADD mapping_json schema | Source: `absence.termination_balance_record.payroll_deduction_amount`; direction: EARNING; batch_type_filter: `[TERMINATION]` |
| ADD to seed list | `ABSENCE + TERMINATION_LEAVE → LEAVE_PAYOUT element` |

> **Data flow:** HR marks termination → TA calculates leave balance → `termination_balance_record.payroll_deduction_amount`
> = số ngày phép còn lại × daily_rate. Engine đọc qua input_source_config và add vào payroll result.

### New Documents Created

| Document | Path | Purpose |
|----------|------|---------|
| Integration Blueprint | `PR/07-integration-blueprint.md` | End-to-end payroll data flow documentation |
| Cross-Module TODO | `PR/08-todo-cross-module-changes.md` | Pending changes requiring TA/TR module updates |

### Summary

| Change | Table/Area | Type | Impact |
|--------|-----------|------|--------|
| 48 | `pay_engine.input_value.source_type` | DOCUMENTED | Data quality, traceability |
| 49 | `batch.engine_request_id` + `run_employee.batch_id` | DOCUMENTED | Developer clarity, no schema change |
| 50 | `pay_master.costing_rule` | ENRICHED | +`element_id FK [null]` |
| 51 | `pay_mgmt.manual_adjust` | ENRICHED | +`assignment_id FK [null]` |
| 52 | `pay_engine.result` | ENRICHED | +`full_period_amount`, +`proration_factor`, +`proration_method` |
| 53 | 4 orphan tables | REORGANIZED | Schema prefixes added (pay_gateway, pay_bank) |
| 54 | `pay_engine.input_source_config.mapping_json` | DOCUMENTED | 6 source type schemas defined |
| 55 | Cross-module FK gaps | DOCUMENTED | GAP-PR-001, GAP-PR-002 as TODO |
| 56 | `pay_mgmt.pay_period` | ENRICHED | +`ta_period_id FK [null, ref: ta.period]` |
| 57 | `input_source_config` | ENRICHED | +TERMINATION_LEAVE_BALANCE source type + seed |

---

## [13Apr2026] – v4.2 PR: pay_master Doc-DBML Gap Resolution (Changes 42–47)


> **Context:** Sau khi review cross-check toàn bộ 22 entity documents (02.1 → 02.22) với `5.Payroll.V4.dbml`,
> phát hiện 7 bảng có GAP giữa thiết kế tài liệu và schema thực tế. Phân tích kết luận:
> - 3 bảng: Document là nguồn hợp lý hơn → UPDATE DBML
> - 4 bảng: Hybrid — cả 2 bên thiếu fields của nhau → UPDATE cả DBML + DOC
> - 2 doc: DBML đúng hơn về naming/type → UPDATE DOC
>
> **Nguyên tắc quyết định:**
> 1. Explicit columns > opaque jsonb (consistent với Change 40 pay_deduction_policy)
> 2. Business domain concepts trong Doc thắng DB-trigger patterns trong DBML
> 3. Hard FK > soft reference về referential integrity

### 5.Payroll.V4.dbml

**Change 42 — `pay_master.validation_rule`: REDESIGN — DB-constraint model → payroll-native validation engine**

| Action | Field | Detail |
|--------|-------|--------|
| REMOVE | `rule_code varchar(50)` | Rename → `code` (naming convention align với toàn schema) |
| REMOVE | `rule_name varchar(255)` | Rename → `name` |
| REMOVE | `target_table varchar(50)` | Xóa — DB trigger pattern, không phù hợp payroll engine |
| REMOVE | `field_name varchar(50)` | Xóa — xem target_table |
| REMOVE | `rule_expression text` | Xóa — replace bằng condition_json jsonb |
| ADD | `rule_type varchar(30) [not null]` | `INPUT_CHECK \| RESULT_CHECK \| CROSS_MODULE \| STATUTORY_CAP` — phân biệt phase execution |
| ADD | `severity varchar(10) [not null]` | `ERROR` (block run) `\| WARNING` (alert only, operator có thể override) |
| ADD | `element_id uuid FK [null]` | Scope validation về specific element; null = toàn run |
| ADD | `condition_json jsonb [null]` | Flexible condition expression (replaces rule_expression) |
| CHANGE SIZE | `error_message varchar(255)` → `varchar(500)` | Business messages cần nhiều space hơn |
| ADD indexes | `(rule_type)`, `(severity, is_active)`, `(element_id) WHERE NOT NULL` | Fast filter theo phase và element scope |

> **Rationale:** DBML cũ dùng target_table+field_name+rule_expression — design của DB trigger, không phù hợp
> cho payroll business rule engine. Doc đã redesign đúng hướng với rule_type và severity.
> severity=ERROR/WARNING là concept bắt buộc phải có để engine quyết định block hay alert only.

**Change 43 — `pay_master.gl_mapping`: ENRICHED — add multi-entity accounting fields**

| Action | Field | Detail |
|--------|-------|--------|
| ADD | `legal_entity_id uuid FK [null]` | Multi-entity scoping (VN vs SG dùng chart of accounts khác nhau). null = global |
| ADD | `country_code char(2) [null]` | Country scoping. null = global; priority: LE > country > global |
| ADD | `gl_account_name varchar(255) [null]` | Tên tài khoản cho reporting/audit |
| ADD | `debit_credit char(1) [not null]` | **CỰC KỲ QUAN TRỌNG** — 'D' Debit / 'C' Credit; engine cần để generate journal entries |
| ADD | `cost_center_code varchar(50) [null]` | Default cost center cho element này |
| ADD | `description text [null]` | Mô tả mapping rule |
| CHANGE SIZE | `gl_account_code varchar(105)` → `varchar(50)` | VN chart of accounts: 3-10 ký tự; 105 là lỗi |
| CHANGE | `element_id` | Thêm `[not null]` — bắt buộc phải có element |
| ADD indexes | `(element_id, debit_credit)`, `(element_id, legal_entity_id, country_code)`, partial LE/country | Hỗ trợ dual-entry lookup và priority resolution |

> **Rationale:** Không có `debit_credit` → engine không thể biết journal entry phía Debit hay Credit.
> Thiếu `legal_entity_id` và `country_code` → không support multi-entity GL mapping.

**Change 44 — `pay_master.costing_rule`: ENRICHED — opaque mapping_json → explicit columns**

| Action | Field | Detail |
|--------|-------|--------|
| RENAME | `level_scope varchar(20)` → `costing_level varchar(30) [not null]` | Enum mới: `EMPLOYEE \| DEPARTMENT \| COST_CENTER \| PROJECT` (thay `LE \| BU \| EMP \| ELEMENT`) |
| ADD | `split_method varchar(20) [not null, default: 'EQUAL']` | `EQUAL \| MANUAL_PCT \| TIME_BASED` — cách chia tỷ lệ chi phí |
| ADD | `gl_account_code varchar(50) [null]` | Default GL account cho costing rule |
| ADD | `cost_center_id uuid [null]` | Cost center chỉ định (null = derive từ employee) |
| ADD | `allocation_pct decimal(5,2) [null]` | % phân bổ cho MANUAL_PCT. App constraint: tổng = 100% |
| ADD | `description text [null]` | Mô tả |
| ADD | `is_active boolean [default: true]` | Operational flag |
| CHANGE | `mapping_json jsonb` | Keep as `[null]` — backward compat / complex multi-CC splits |

> **Rationale:** Tương tự Change 40 (07Apr2026) cho `pay_deduction_policy`. Pattern nhất quán:
> explicit columns > opaque JSON cho queryability và validation. Enum mới align đúng costing domain.
> App constraint: tổng allocation_pct của tất cả records cho cùng employee × period = 100%.

**Change 45 — `pay_master.balance_def`: ENRICHED — add element tracking + operational fields**

| Action | Field | Detail |
|--------|-------|--------|
| ADD | `element_id uuid FK [null]` | Track element nào. null = multi-element computed balance |
| ADD | `description text [null]` | Mô tả balance definition |
| ADD | `is_active boolean [default: true]` | Operational flag |
| CHANGE | `metadata jsonb` | Giữ nguyên `[null]` — không replace bằng description; cả 2 tồn tại |
| ADD | `created_at / updated_at` | Standard audit fields |
| ADD indexes | `(balance_type)`, `(element_id) WHERE NOT NULL`, `(is_active) WHERE TRUE` | Performance |

> **Rationale:** element_id là field quan trọng — balance_def cần biết track element nào.
> YTD_PIT phải link element_id → PIT_WITHHOLD_VN để engine biết cộng dồn đúng.
> metadata jsonb giữ theo user comment — cả 2 cùng tồn tại với description.

**Change 46 — `pay_master.pay_benefit_link`: ENRICHED — add direction + operational fields**

| Action | Field | Detail |
|--------|-------|--------|
| ADD | `direction varchar(20) [not null]` | **CỰC KỲ QUAN TRỌNG** — `ADDS_TO_GROSS \| ADDS_DEDUCTION \| EMPLOYER_ONLY \| INFORMATION_ONLY` |
| ADD | `is_active boolean [default: true]` | Operational flag |
| ADD | `description text [null]` | Mô tả link |
| CHANGE | `benefit_type varchar(50)` | Align enum: `HEALTH_INSURANCE \| LIFE_INSURANCE \| PENSION \| STOCK_OPTION \| CAR_ALLOWANCE \| MEAL_SUBSIDY \| EDUCATION_AID \| COMPENSATION_COMPONENT` |
| ADD index | `(direction) WHERE is_active = true` | Engine filter by direction at runtime |

> **Rationale:** Không có `direction` → engine không biết benefit link này tác động payroll thế nào.
> ADDS_TO_GROSS vs ADDS_DEDUCTION vs EMPLOYER_ONLY là 3 hành vi hoàn toàn khác nhau về tính toán.

### Documents Updated (02.xx-*.md)

**Change 47 — Align field names/types trong 5 documents theo DBML:**

| Document | Change | Detail |
|----------|--------|--------|
| `02.15-gl-mapping.md` | ADD field | `is_active boolean` vào field table |
| `02.17-payslip-template.md` | RENAME + ADD | `locale` → `locale_code`; thêm `template_type`, `logo_url`, `header_text`, `footer_text`, `description`, SCD-2 fields; `name` varchar(100) → varchar(255) |
| `02.10-pay-profile-rate-config.md` | RENAME | `base_rate` → `base_rate_amount decimal(15,4)`; `formula_code varchar(50)` → `formula_id uuid FK`; thêm `currency_code char(3)` |
| `02.18-pay-formula.md` | RENAME | `version smallint` → `version_no int`; `name` varchar(100) → varchar(255) |
| `02.21-termination-pay-config.md` | ADD fields | `is_mandatory boolean NOT NULL`, `description text`, `effective_start/end_date` |
| `02.22-pay-benefit-link.md` | ADD fields | `valid_from/valid_to` note; `direction [NOT NULL]`; `is_active`; `description` — Updated Changed header |

### Summary

| Change | Table/Doc | Type | Fields Added/Changed |
|--------|-----------|------|----------------------|
| 42 | `pay_master.validation_rule` | REDESIGNED | Xóa 3 DB-trigger fields; +`rule_type`, +`severity`, +`element_id`, +`condition_json`; `error_message` varchar(500) |
| 43 | `pay_master.gl_mapping` | ENRICHED | +`legal_entity_id`, +`country_code`, +`gl_account_name`, +`debit_credit`, +`cost_center_code`, +`description`; fix varchar(105)→varchar(50) |
| 44 | `pay_master.costing_rule` | ENRICHED | Rename `level_scope`→`costing_level` (new enum); +`split_method`, +`cost_center_id`, +`allocation_pct`, +`gl_account_code`, +`description`, +`is_active` |
| 45 | `pay_master.balance_def` | ENRICHED | +`element_id FK [null]`, +`description`, +`is_active`; keep `metadata jsonb` |
| 46 | `pay_master.pay_benefit_link` | ENRICHED | +`direction [not null]`, +`is_active`, +`description`; enum update `benefit_type` |
| 47 | 5 documents | DOC ALIGN | Field names/types aligned to DBML; SCD-2 notes added |

---

## [07Apr2026] – v4.1 PR: pay_master Design Gap Resolution (Changes 39–41)

> **Context:** Phân tích kiến trúc `pay_master` sau khi cross-check toàn bộ 3 schema (CO, TR, PR) phát hiện 3 design gaps cần close trước khi viết 22 entity documents:
> 1. `pay_formula.script text` — opaque, không rõ engine language (MVEL vs Groovy vs other)
> 2. `pay_deduction_policy.deduction_json` — toàn bộ logic nhét vào 1 JSONB blob, không queryable, không validatable
> 3. `pay_benefit_link.benefit_policy_code` — soft reference duy nhất, không có FK constraint, referential integrity chỉ ở application level
>
> **Engine decision documented:** Stakeholder reject DROOLS 8 → chọn **Groovy** cho engine layer, **MVEL** cho formula layer (simple expression). Không có DB enum constraint — application layer quyết định runtime.
>
> **2 gaps không cần DBML change:** PIT dependent (`tax.dependent_registration` đã đủ trong CO) → application inject. OT cap enforcement → TA module owns enforcement, PR chỉ light-check qua `validation_rule`.

### 5.Payroll.V4.dbml

**Change 39 — `pay_master.pay_formula`: `script text` → `script_json jsonb`**

| Action | Field | Detail |
|--------|-------|--------|
| CHANGE type | `script text` → `script_json jsonb [not null]` | Thay opaque text bằng structured jsonb. Structure gợi ý: `{"lang":"MVEL","content":"amount*rate","engine_version":"mvel-2.4","params":{}}`. Không có DB enum — application tự route đến executor. |
| ADD field | `scope varchar(20) [null]` | Gợi ý scope dùng: `ELEMENT \| PROFILE \| STATUTORY \| ANY`. Không ràng buộc, optional hint cho admin UI. |
| ADD indexes | `(code)`, `(scope) WHERE NOT NULL` | Index hỗ trợ lookup theo scope. |
| UPDATE Note | Multi-line note | Document MVEL vs Groovy decision + backward compat migration path. |

**Backward compat migration:** `script text` cũ → `{"lang":"MVEL","content":"<old_script>"}` trong `script_json`.

**Change 40 — `pay_master.pay_deduction_policy`: Explicit columns (Option B)**

| Action | Field | Detail |
|--------|-------|--------|
| ADD | `deduction_type varchar(30) [not null]` | Enum: `FIXED \| PERCENTAGE \| INSTALLMENT \| BENEFIT_PREMIUM \| ADVANCE_RECOVERY`. DB-enforced discriminator. |
| ADD | `deduction_amount decimal(18,2) [null]` | Nếu `FIXED`: số tiền tuyệt đối (VND). |
| ADD | `deduction_pct decimal(5,2) [null]` | Nếu `PERCENTAGE`: phần trăm (e.g. `1.00` = 1%). |
| ADD | `recovery_basis varchar(20) [null]` | Basis tính %: `GROSS \| NET \| BASIC_SALARY`. |
| ADD | `max_deduction_pct decimal(5,2) [null]` | Trần tối đa — bảo vệ NLĐ (BLLĐ 2019, không quá 30% net). |
| ADD | `installment_count smallint [null]` | Nếu `INSTALLMENT`: số kỳ mặc định (e.g. 6 tháng). |
| KEEP | `deduction_json jsonb [null]` | Giữ cho extra params / backward compat. |
| ADD indexes | `(code)`, `(deduction_type)`, `(is_active) WHERE TRUE` | Fast filter theo type & active status. |

**Per-worker installment tracking decision:**
- **Không cần** `worker_deduction_enrollment` table riêng.
- INSTALLMENT/ADVANCE_RECOVERY per-worker state → HR tạo series `pay_mgmt.manual_adjust` (status=`PENDING`), 1 record/period.
- Engine picks up PENDING → apply → mark `APPLIED`.
- Application queries `manual_adjust` để track progress/balance.

**Change 41 — `pay_master.pay_benefit_link`: Explicit FK columns (Option B)**

| Action | Field | Detail |
|--------|-------|--------|
| ADD | `benefit_plan_id uuid [ref: > benefit.benefit_plan.id, null]` | FK tường minh khi target = `benefit.benefit_plan`. |
| ADD | `pay_component_id uuid [ref: > comp_core.pay_component_def.id, null]` | FK tường minh khi target = `comp_core.pay_component_def`. |
| ADD | `benefit_source varchar(30) [null]` | Chỉ rõ FK nào đang được dùng: `BENEFIT_PLAN \| PAY_COMPONENT \| CUSTOM`. |
| CHANGE | `benefit_policy_code varchar(50)` → `[null]` (was implicit not null) | Now optional — backward compat cho external/custom policy codes. |
| CHANGE | `pay_element_id` | Thêm `[not null]` — đảm bảo mọi link đều có element. |
| ADD indexes | `(pay_element_id)`, `(benefit_plan_id) WHERE NOT NULL`, `(pay_component_id) WHERE NOT NULL`, `(benefit_type)` | Selective partial indexes cho FK lookups. |

**Application constraint (not DB):** ít nhất 1 trong 3 (`benefit_plan_id`, `pay_component_id`, `benefit_policy_code`) phải NOT NULL.

### Không thay đổi DBML (resolved by convention)

| Gap | Resolution |
|-----|-----------|
| PIT Dependent data contract | Application layer inject `PIT_DEPENDENT_COUNT` từ `tax.dependent_registration` (CO schema). `tax.dependent_registration` đã đầy đủ. |
| OT cap enforcement | TA module owns enforcement tại timesheet validation. PR chỉ second-check nhẹ qua `pay_master.validation_rule`. |

### Summary

| Change | Table | Type | Fields Added/Changed |
|--------|-------|------|----------------------|
| 39 | `pay_master.pay_formula` | MODIFIED | `script` → `script_json jsonb`, +`scope` |
| 40 | `pay_master.pay_deduction_policy` | ENRICHED | +6 explicit columns, keep `deduction_json` |
| 41 | `pay_master.pay_benefit_link` | ENRICHED | +`benefit_plan_id`, +`pay_component_id`, +`benefit_source`, `benefit_policy_code` now nullable |

---

## [06Apr2026] – v5.9: TA Level 6 — GeneratedRoster & ScheduleOverride Field Audit (Change 38)

> **Context:** Phân tích Level 6 từ góc độ **operational data table** (không phải master data) phát hiện: (1) thiếu `day_type` denormalized — field critical nhất mà tất cả downstream modules (OT, Payroll, Attendance) cần; (2) thiếu `generated_at` tracking; (3) `holiday_id` thiếu FK ref constraint; (4) `schedule_override.day_type_override` enum cũ chưa bao gồm các loại ngày mới từ Level 3 Change 35; (5) group expansion logic cho `employee_group_id` chưa được document.

### TA-database-design-v5.dbml

**Change 38 — `ta.generated_roster`: 4 changes**

| Action | Field | Detail |
|--------|-------|--------|
| ADD | `day_type varchar(30) [not null]` | Denormalized từ `day_model.day_type` tại thời điểm generate. Frozen — không update nếu day_model thay đổi sau. Enum: `WORKDAY \| OFF \| HOLIDAY \| COMPENSATORY_OFF \| HALF_DAY \| SPECIAL_WORK_DAY`. Used by OT (rate 150/200/300%), Payroll (day count), Attendance (absence detect). |
| ADD | `generated_at timestamptz [default:now()]` | Operational metadata — khi nào row được generate/re-generate. Dùng cho debugging, batch tracking, audit ("lịch này generate trước hay sau khi assignment thay đổi?"). |
| FIX | `holiday_id uuid [ref: > absence.holiday_calendar_day.id, null]` | Thêm FK ref constraint — trước đây là bare `uuid [null]` không có FK, gây orphaned reference risk. |
| ADD | `(work_date, day_type)` index | Fast query cho Payroll/OT day-type aggregation per period. |
| ADD | `(work_date, status_code)` index | Fast query cho "all SCHEDULED rows pending confirmation". |
| REORDER | Override/Holiday fields | Grouped vào sections rõ ràng với comments. |

**Change 38 — `ta.schedule_override`: 3 changes**

| Action | Field | Detail |
|--------|-------|--------|
| UPDATE | `day_type_override varchar(30)` | Enum mở rộng từ `OFF \| HOLIDAY` → `OFF \| HOLIDAY \| COMPENSATORY_OFF \| HALF_DAY \| SPECIAL_WORK_DAY \| WORKDAY`. Align với Level 3 day_type enum (Change 35). |
| DOCUMENT | `employee_group_id` | Ghi rõ Group Expansion Rule: expand tại apply-time, NOT retroactive khi group member changes sau đó. Constraint: `employee_id XOR employee_group_id`. |
| ADD | `(employee_group_id, work_date)` index | Fast group override lookup. |

**Why `day_type` is the most important addition:**
```
Before Change 38 — OT module cần tính rate:
  SELECT gr.employee_id, dm.day_type  ← phải JOIN
  FROM ta.generated_roster gr
  JOIN ta.day_model dm ON gr.day_model_id = dm.id
  WHERE gr.work_date BETWEEN :start AND :end

After Change 38:
  SELECT employee_id, day_type         ← 1 table, index hit
  FROM ta.generated_roster
  WHERE work_date BETWEEN :start AND :end
```

---


## [06Apr2026] – v5.9: TA Level 5 — ScheduleAssignment Refinement (Change 37)

> **Context:** Phân tích Level 5 sau khi hoàn thiện Level 1–4 phát hiện 3 vấn đề cần giải quyết: (1) `employee_override_id` tạo ra ambiguity semantic — không rõ là "override ngoài group" hay "chỉ dành cho cá nhân này"; (2) `crew_label` bị thiếu khiến nhiều ScheduleAssignment cùng pattern không phân biệt được; (3) Thiếu validation rule ghi nhận ràng buộc `start_reference_date` phải khớp `cycle_anchor_weekday` của Pattern.

### TA-database-design-v5.dbml

**Change 37 – `ta.schedule_assignment`: 4 changes**

| Action | Field/Area | Detail |
|--------|-----------|--------|
| REMOVE | `employee_override_id` | **Decision:** Tất cả trường hợp (group và cá nhân đặc biệt như CEO, expat) đều giải quyết qua `eligibility_profile_id`. CEO/expat → tạo eligibility_profile riêng với `rule_json` scoped đến cá nhân đó (`{"employee_ids":["<uuid>"]}`). Không bypass eligibility engine. |
| ADD | `crew_label varchar(100) [null]` | Human-readable label cho crew/rotation group. Dùng khi nhiều assignments share cùng `pattern_id` (ROTATING). Ví dụ: "Morning Team" (offset=0), "Evening Team" (offset=7), "Night Team" (offset=14). null cho FIXED single-crew. |
| ADD | Validation comment `start_reference_date` | `IF pattern.cycle_anchor_weekday IS NOT NULL THEN WEEKDAY(start_reference_date) MUST EQUAL cycle_anchor_weekday`. Validated by Schedule Engine (không phải DB constraint). |
| DOCUMENT | Temporal model | Confirmed: `effective_start` + `effective_end` only. **NOT SCD Type 2.** Rationale: Level 6 GeneratedRoster là frozen historical record. Dev lead có thể thêm `is_current_flag` tại implementation layer nếu cần — đây là quyết định infra. |
| ADD | `pattern_id nullable` | `pattern_id [null]` thay vì required — cho phép ad-hoc/FLEX scheduling không có pattern cứng. |
| DOCUMENT | `eligibility_profile_id [not null]` | Field này now required (previously nullable). Mọi assignment phải có eligibility profile. |

**Field summary (v5.9):**

| Field | Type | Change |
|-------|------|--------|
| `pattern_id` | uuid [null] | **UPDATED** — now nullable (FLEX support) |
| `start_reference_date` | date | Added validation comment |
| `offset_days` | int [default:0] | Added ROTATING/FIXED/FLEX semantics |
| `crew_label` | varchar(100) [null] | **NEW** |
| `eligibility_profile_id` | uuid [not null] | **UPDATED** — now required (was nullable) |
| `employee_override_id` | — | **REMOVED** |
| `effective_start` + `effective_end` | date + date[null] | Confirmed non-SCD2 |

**Validation rules (Schedule Engine, not DB):**
```
1. WEEKDAY(start_reference_date) == pattern.cycle_anchor_weekday  (if not null)
2. offset_days = 0  when rotation_type IN (FIXED, FLEX)
3. offset_days in [0..cycle_length_days)  when rotation_type = ROTATING
4. IF pattern_id IS NULL → FLEX mode; Level 6 filled manually
```

---

## [06Apr2026] – v5.9: TA Level 4 — PatternTemplate Schema Refinement (Change 36)

> **Context:** Phân tích Level 4 cho 3 ngành + trường hợp dầu khí phát hiện 4 gaps: (1) `pattern_json` JSONB là legacy v4 đang tồn tại song song với `ta.pattern_day` normalized — cần deprecate; (2) `rotation_type` thiếu `FLEX` cho retail/hospitality không có cycle cứng; (3) Không có field biểu thị "Day 1 phải là thứ mấy trong tuần" dẫn đến pattern 5x8 có thể bị set sai anchor day; (4) ROTATING pattern không lưu số crew expected khiến HR admin không biết cần tạo bao nhiêu Level 5 assignments.

### TA-database-design-v5.dbml

**Change 36 – `ta.pattern_template`: 4 schema changes**

| Action | Field | Detail |
|--------|-------|--------|
| DEPRECATE | `pattern_json jsonb` | v4 legacy. Authoritative source là `ta.pattern_day`. Kept for backward compat. **Remove in v6.0.** Migration: Ensure all apps read from `ta.pattern_day` before v6.0 upgrade. |
| ADD enum value | `rotation_type = FLEX` | Pattern không có cycle cứng. HR builds schedule per period. cycle_length_days = planning horizon only. Dùng cho retail, hospitality, casual workforce. |
| ADD field | `cycle_anchor_weekday smallint [null]` | ISO weekday (1=Mon...7=Sun) mà Day 1 phải rơi vào. `null` = floating (không ràng buộc weekday). Level 5 `start_reference_date` phải khớp với weekday này. |
| ADD field | `num_crews smallint [null]` | Số crew dự kiến cho ROTATING pattern. UI hint: offset/crew = cycle_length / num_crews. Không enforce DB constraint. |

**Change 36 – `ta.pattern_day`: 1 field mới**

| Action | Field | Detail |
|--------|-------|--------|
| ADD field | `group_label varchar(50) [null]` | Label hiển thị cho nhóm ngày liên tiếp trong UI calendar. Ví dụ: "Week 1 – Morning Shift", "Off Period (Day 91–120)". Không ảnh hưởng tính toán. Display only. |

**Final `ta.pattern_template` field summary (v5.9):**

| Field | Type | v5.9 Change |
|-------|------|-------------|
| `cycle_length_days` | int [null] | Type changed to nullable (null = FLEX) |
| `cycle_anchor_weekday` | smallint [null] | **NEW** — ISO weekday anchor |
| `rotation_type` | varchar(20) | **UPDATED** — added FLEX |
| `pattern_json` | jsonb [null] | **DEPRECATED** — remove v6.0 |
| `num_crews` | smallint [null] | **NEW** — UI crew hint |

**Cycle calculation algorithm (documented in Table Note):**
```
day_index  = ((target_date − start_reference_date) + offset_days) % cycle_length_days
day_number = day_index + 1  (1-indexed lookup into ta.pattern_day)
```

**Oil & Gas approach (Option B — confirmed):**
- `cycle_length_days = 120`, `rotation_type = ROTATING`, `cycle_anchor_weekday = null`
- `pattern_day`: day 1–90 → WORKDAY, day 91–120 → OFF
- `group_label`: "On Period (Day 1–90)", "Off Period (Day 91–120)"
- HR adjusts `start_reference_date` per contract renewal if schedule shifts

**Migration note:** `pattern_json` will be removed in v6.0. SQL to verify no app dependency: `SELECT id, code FROM ta.pattern_template WHERE pattern_json IS NOT NULL;`

---

## [06Apr2026] – v5.9: TA Level 3 — DayModel day_type Enum Refinement (Change 35)

> **Context:** Phân tích Level 3 DayModel cho 3 use cases ngành (manufacturing, retail, healthcare) phát hiện 2 gaps:
> 1. `day_type = WORK` gây nhầm lẫn với `segment_type = WORK` ở Level 1 (TimeSegment). Mặc dù 2 field khác nhau, trong ngữ cảnh tài liệu và UX training, người đọc dễ confuse giữa "khoảng thời gian làm việc trong ca" vs "loại ngày đi làm".
> 2. Không có type riêng cho ngày nghỉ bù bắt buộc (BLLĐ VN Điều 109/115), dẫn đến không thể phân biệt giữa nghỉ thường trong pattern (có thể recall) và nghỉ bù pháp lý (không thể override). Đặc biệt quan trọng cho healthcare và manufacturing với ca đêm/OT thường xuyên.

### TA-database-design-v5.dbml

**Change 35 – `ta.day_model`: day_type enum refinement**

| Action | Detail |
|--------|--------|
| RENAME enum value | `WORK` → `WORKDAY` in `day_type`. Rationale: disambiguate from `segment_type=WORK` (Level 1). `WORKDAY` reads as "a day when work happens" vs `WORK` which reads as "work activity". |
| ADD enum value | `COMPENSATORY_OFF` — Mandatory compensatory rest day. Triggered after OT/night shift. Protected by BLLĐ VN Art.109 (≥12h rest after night shift) and Art.115 (OT on public holiday must be compensated). `shift_id=null`. Cannot be overridden by scheduler to recall employee. |
| UPDATE field comment | `shift_id` — clarified: required for WORKDAY/HALF_DAY; null for OFF/HOLIDAY/COMPENSATORY_OFF. Added HALF_DAY constraint: shift must be a half-duration ShiftDef. |
| UPDATE field `variant_selection_rule` | Documented JSONB schema: `holiday_class_handling` (OVERRIDE_TO_OFF \| KEEP_AS_WORK \| USE_HOLIDAY_SHIFT), `holiday_shift_id`, `ot_rate_override`. |
| UPDATE Table Note | Rewritten as multi-line note with full enum descriptions and 3 industry usage patterns. |

**Final `day_type` enum (v5.9):**

| Value | Hành vi | shift_id | Recall-able? | Labor law ref |
|-------|---------|:--------:|:------------:|---------------|
| `WORKDAY` | Ngày làm bình thường | Required | N/A | — |
| `OFF` | Nghỉ trong pattern (cuối tuần) | null | ✅ (với OT rate) | — |
| `HOLIDAY` | Ngày lễ quốc gia/công ty | null | ✅ (với holiday rate) | BLL Đ VN Điều 112 |
| `HALF_DAY` | Nửa ngày làm | Required (half-shift) | N/A | — |
| `COMPENSATORY_OFF` | Nghỉ bù pháp lý | null | ❌ protected | BLLĐ VN Điều 109, 115 |

**Industry usage patterns:**
- **Manufacturing 3-shift:** 3 WORKDAY DayModels (MORNING/EVENING/NIGHT) + COMPENSATORY_OFF after consecutive night shifts
- **Healthcare 24/7:** WORKDAY references ONCALL or STANDBY ShiftDef; COMPENSATORY_OFF after duty nights
- **Retail PUNCH:** WORKDAY + PUNCH-type shift; actual hours flex by attendance; no COMPENSATORY_OFF needed by default

**Migration note:** `day_type='WORK'` → `day_type='WORKDAY'` requires a data migration. SQL: `UPDATE ta.day_model SET day_type='WORKDAY' WHERE day_type='WORK';`

---

## [06Apr2026] – v5.8: TA Level 2 — Day Breaker Model + Night Work Bracket (Change 34)

> **Context:** Analysis of cross-midnight shift handling revealed a capability downgrade in v5: `day_breaker_min` (integer) from v4 was replaced by a simple `cross_midnight boolean`. While the flag correctly identifies that a shift spans two calendar dates, it provides **no guidance on how to attribute hours across those dates** — a gap that causes incorrect OT calculation, erroneous attendance reporting, and non-compliance with night-work premium requirements.
>
> **Problem statement:**
> Ca đêm 22:00 (07/04) → 06:00 (08/04): 2h thuộc ngày 07, 6h thuộc ngày 08. Nếu 08/04 là ngày lễ → 6h đó cần tính OT rate ngày lễ khác hoàn toàn. Với `cross_midnight=true` thuần túy, hệ thống không thể phân biệt.
>
> **Solution:** Restore and extend day_breaker concept as a 4-mode flexible model (`day_split_mode`), add `day_breaker_hour` for site-specific boundaries, and introduce `night_work_start/end` for legal night-work premium isolation.

### TA-database-design-v5.dbml

**Change 34 – `ta.shift_def`: Day Breaker Model + Night Work Bracket**

| Action | Field | Detail |
|--------|-------|--------|
| UPDATE | `cross_midnight` comment | Clarified: flags presence of date span, must be combined with `day_split_mode` |
| ADD field | `day_split_mode varchar(20) [default:'ANCHOR_START']` | Controls how hours of a cross-midnight shift are attributed to calendar dates. 4 modes: `ANCHOR_START`, `ANCHOR_END`, `SPLIT_MIDNIGHT`, `SPLIT_AT_HOUR` |
| ADD field | `day_breaker_hour time [null]` | Effective only when `day_split_mode = SPLIT_AT_HOUR`. Sets the custom split point (e.g., `04:00:00` for manufacturing sites). |
| ADD field | `night_work_start time [default:'22:00:00']` | Start of night-work bracket for legal premium pay. Default: 22:00 (VLC 2019 Điều 105). |
| ADD field | `night_work_end time [default:'06:00:00']` | End of night-work bracket. Cross-midnight assumed when `end < start`. |
| UPDATE | Table `Note` | Extended multi-line note documenting all 4 `day_split_mode` values and their use cases. |

**`day_split_mode` decision guide:**

| Mode | Khi nào dùng | Ví dụ |
|------|-------------|-------|
| `ANCHOR_START` | Default. Ca rate không đổi qua đêm. Không cần tách theo ngày. | Ca đêm nhà kho, bảo vệ (flat rate) |
| `ANCHOR_END` | Y tế / điều dưỡng — ca "thuộc" ngày kết thúc (ngày làm về sáng) | Ca trực 19:00→07:00 tính là ca ngày 07+1 |
| `SPLIT_MIDNIGHT` | Cần tính đúng OT rate từng ngày (ngày lễ, ngày thường khác nhau) | Nhà máy cần tách OT ngày lễ |
| `SPLIT_AT_HOUR` | Site quy định ranh giới ngày tại giờ cụ thể (không phải 00:00) | Nhà máy dùng 04:00 làm day boundary |

**Impact trên các modules khi `day_split_mode != ANCHOR_START`:**
- **Attendance engine**: cần tách clock events theo boundary → compute hours-per-date
- **OT engine**: apply OT rate của đúng ngày cho từng portion
- **Payroll export**: split `night_work_hours` (22:00–06:00) để tính phụ cấp ≥30% (BLLĐ VN)
- **Leave engine**: leave request spanning cross-midnight shift cần respect day boundary

**Validation rules:**
- `day_breaker_hour` must be non-null when `day_split_mode = 'SPLIT_AT_HOUR'`
- `day_split_mode` other than `ANCHOR_START` is only meaningful when `cross_midnight = true`; system should warn if configured on a non-cross-midnight shift
- `night_work_end < night_work_start` is valid (implies cross-midnight bracket, e.g., 22:00→06:00)

---

## [06Apr2026] – v5.7: TA Level 1 — Segment Type Expansion + OT/Geofence Control Fields (Change 33)

> Context: Phân tích coverage của 4 segment types hiện tại (WORK, BREAK, MEAL, TRANSFER) cho thấy 2 gaps nghiêm trọng:
> (1) **STANDBY** — Không có type cho trực ca (on-call), phổ biến trong manufacturing, healthcare, security. WORK không thể model đúng vì rate khác biệt, geofence rule khác, không tính OT base.
> (2) **TRAINING** — Không có type cho đào tạo. Nếu dùng WORK: costing sai (charge Production thay vì L&D budget), không extract được compliance report training hours, OT calculation sai.
> Architecture Decision: Nâng từ 4 → 6 types. Thêm 2 control fields `counts_toward_ot` và `geofence_exempt` thay vì hard-code logic trong application layer.

### TA-database-design-v5.dbml

**Change 33 – `ta.time_segment`: Extended segment_type + 2 new control fields**

| Action | Field / Change | Detail |
|--------|---------------|--------|
| ADD enum value | `STANDBY` to `segment_type` | On-call/standby duty. Paid at rate via `premium_code`. `counts_toward_ot=false`, `geofence_exempt=true` by default. |
| ADD enum value | `TRAINING` to `segment_type` | Training/education/onboarding. Paid, count attendance, but `counts_toward_ot=false`. `cost_center_code` → L&D budget. |
| ADD field | `counts_toward_ot boolean [default:true]` | Controls whether segment hours count toward OT threshold. System-forced false for STANDBY/TRAINING. HR-configurable for WORK/TRANSFER. |
| ADD field | `geofence_exempt boolean [default:false]` | When true (STANDBY), ATT-M-002 geofence validation is skipped for this segment. Employee does not need to clock-in biometrically. |
| UPDATE comment | `segment_type` inline documentation | Expanded comment block explaining all 6 values with paid/OT/geofence defaults. |
| UPDATE Note | Table Note block | Rewritten as multi-line note with default matrix per segment_type. |
| UPDATE comment | `cost_center_code` | Added note: TRAINING segments should reference L&D cost center (CC-LND-xxx). |
| UPDATE comment | `premium_code` | Added STANDBY_RATE as example premium code. |

**Updated `segment_type` default behavior matrix:**

| segment_type | is_paid default | counts_toward_ot | geofence_exempt | OT Rate |
|-------------|:---:|:---:|:---:|---------|
| `WORK` | true | true | false | Standard / Premium via premium_code |
| `BREAK` | false | false | false | N/A |
| `MEAL` | false | false | false | N/A |
| `TRANSFER` | true | true | false | Standard (travel time) |
| `STANDBY` | true | **false** | **true** | Flat/reduced — via `premium_code = STANDBY_RATE` |
| `TRAINING` | true | **false** | false | Standard (training time) |

**Why STANDBY needs its own type (cannot use WORK):**
- Rate model: flat/reduced rate (not hourly work rate) — payroll engine treats differently
- Geofence: employee may be at home (remote standby) — geofence check must be skipped
- OT Impact: standby hours excluded from OT threshold in most labor policies (VLC + enterprise)
- Attendance: no biometric clock-in required; start/end logged as a block

**Why TRAINING needs its own type (cannot use WORK):**
- Costing: always charged to Training/L&D budget, not Production cost center
- OT policy: most policies exclude training hours from OT base
- Compliance reporting: training hours must be extractable for audit (safety training, onboarding)
- L&D analytics: `segment_type = TRAINING` enables direct query without requiring `premium_code` pattern matching

**Modeling patterns documented (use WORK + premium_code, no new type needed):**
- Handover: `WORK` + `premium_code = "HANDOVER"`
- Prep/Setup: `WORK` + `premium_code = "PREP"`
- Unpaid travel: `TRANSFER` + `is_paid = false`

**Related documentation updated:**
- `TA/01-scheduling-model.md` — Level 1 Segment Types table expanded to 6 rows + 2 sample data records added (ONCALL_NIGHT, ORIENTATION)
- `SCH-M-001-time-segment-config.spec.md` — Segment Types table, filter chips, form radio group, Section 3 pay & attendance rules, BR-SCH-011, BR-SCH-012, Validation Matrix (2 new rows)

**New business rules triggered:**
- `BR-SCH-011`: STANDBY auto-sets `counts_toward_ot=false` + geofence exempt. Active work during standby = separate WORK segment.
- `BR-SCH-012`: TRAINING auto-sets `counts_toward_ot=false`. Missing `cost_center_code` = non-blocking warning.

---

## [03Apr2026-c] – v5.6: `compensation.basis_line` Structural Fix — Mandatory `pay_component_def_id` (Change 32)


> Context: Phân tích `compensation.basis_line` phát hiện 2 vấn đề: (1) không có FK đến `pay_component_def` → payroll engine không thể đọc `tax_treatment`, `is_subject_to_si`, `calculation_method` của từng phụ cấp → line bị bỏ qua khi tính lương. (2) `component_name varchar` (free-text) + `OTHER` type cho phép ad-hoc allowance không link về config → không tham gia được payroll → vô nghĩa.
> Decision: **Xóa `component_name` và `OTHER` type. Thêm `pay_component_def_id NOT NULL FK`.** Mọi phụ cấp phải được định nghĩa trước trong `pay_component_def` + cho phép trong `salary_basis_component_map`.

### 4.TotalReward.V5.dbml

**Change 32 – `compensation.basis_line`: Structural fix**

| Action | Field | Detail |
|--------|-------|--------|
| ADD | `pay_component_def_id uuid [not null]` | FK → `comp_core.pay_component_def.id`. NOT NULL — bắt buộc để payroll engine có calc rules. |
| REMOVE | `component_name varchar(100)` | Ad-hoc free-text bị xóa. Dùng `pay_component_def.name` thay thế. |
| REMOVE | `OTHER` from `component_type_code` enum | `OTHER` không link về config → không tham gia payroll → vô nghĩa. |
| ADD | App-layer constraint | `pay_component_def_id` phải nằm trong `salary_basis_component_map` cho parent `salary_basis_id`. |
| UPDATE | Indexes | `(basis_id, component_type_code, effective_start_date)` → `(basis_id, pay_component_def_id) [unique]` + `(basis_id, pay_component_def_id, effective_start_date) [unique]` |
| ADD | Note block | Document rationale + constraint + workflow cho phụ cấp mới |

**Lý do xóa `OTHER`:**
- `OTHER` không có `pay_component_def` → không có `tax_treatment` / `is_subject_to_si` / `calculation_method`
- Payroll engine không biết cách tính → line bị skip
- Nếu cần phụ cấp mới: Admin thêm `pay_component_def` record trước → mới được phép dùng

**Valid `component_type_code` sau Change 32:**
`MEAL | HOUSING | TRANSPORTATION | RESPONSIBILITY | SENIORITY | TOXICITY | PHONE`
*(thêm code mới = thêm pay_component_def tương ứng)*

**Constraint validation flow (app-layer):**
```
HR adds basis_line with pay_component_def_id = X
→ App validates:
    EXISTS (SELECT 1 FROM salary_basis_component_map
            WHERE salary_basis_id = compensation.basis.salary_basis_id
            AND component_id = X)
→ REJECT if not found
```

**Quy trình thêm phụ cấp mới:**
```
1. Admin tạo pay_component_def (SPECIAL_DUTY_ALLOWANCE, tax_treatment=FULLY_TAXABLE, is_subject_to_si=false)
2. Admin thêm vào salary_basis_component_map cho salary_basis liên quan
3. HR mới được phép tạo basis_line với component đó
```

---

## [03Apr2026-b] – v5.5: Fix Pay Eligibility Mapping — Salary Basis + Centralized Eligibility (Change 31)

> Context: Phân tích kiến trúc mapping Employee ↔ Fix Pay Config phát hiện `comp_core.salary_basis` THIẾU `eligibility_profile_id` — trái ngược với mọi entity cùng level (`comp_plan`, `bonus_plan`, `benefit_plan`, `pay_element`) đều đã tích hợp Eligibility Central. Ngoài ra `compensation.basis.salary_basis_id` thiếu FK constraint (chỉ là uuid trống, không reference table nào).
> Architecture Decision: Thêm `eligibility_profile_id` vào `salary_basis` (pattern 1:1 direct FK, nhất quán với G5/G6). Scoping fields (country_code, legal_entity_id, config_scope_id) giữ nguyên nhưng làm rõ chỉ để admin UI lọc/gom nhóm — KHÔNG quyết định assignment. Fix FK on `compensation.basis.salary_basis_id`. Không cần bảng mapping mới — `compensation.basis` IS the assignment record.

### 4.TotalReward.V5.dbml

**Change 31a – `comp_core.salary_basis`: Thêm `eligibility_profile_id`**

| Action | Field | Detail |
|--------|-------|--------|
| ADD | `eligibility_profile_id uuid [null]` | FK → `eligibility.eligibility_profile.id`. domain='COMPENSATION'. NULL = globally eligible. |
| ADD | Index | `(eligibility_profile_id)` — eligibility lookup |
| ADD | Note block | Documenting Scoping vs Eligibility separation + Assignment Flow + Auto-expiry rule |
| UPDATE | Comments on `country_code`, `legal_entity_id`, `config_scope_id` | Clarify "For UI filtering only — does NOT determine assignment" |

**Design rationale — Separation of Concerns:**
| Concern | Fields | Purpose |
|---------|--------|---------|
| **Admin grouping / UI filter** | `country_code`, `legal_entity_id`, `config_scope_id` | "Show all VN salary bases" — không phải business rule |
| **Assignment eligibility** | `eligibility_profile_id` | Centralized engine evaluates rule_json → determines WHO is eligible |

**Consistency với toàn bộ TR/PR entities sử dụng Eligibility Central:**

| Module | Entity | `eligibility_profile_id` |
|--------|--------|--------------------------|
| TR | `comp_core.comp_plan` (G6) | ✅ |
| TR | `comp_incentive.bonus_plan` (G6) | ✅ |
| TR | `benefit.benefit_plan` (G5) | ✅ |
| TR | **`comp_core.salary_basis` (Change 31)** | ✅ **NEW** |
| PR | `pay_master.pay_element` (G7) | ✅ |
| TA | `ta.schedule_assignment` (Change 30) | ✅ |
| TA | `absence.leave_class` (existing) | ✅ |

**Change 31b – `compensation.basis.salary_basis_id`: Fixed FK constraint**

| Action | Before | After |
|--------|--------|-------|
| FIX FK | `salary_basis_id uuid [null]` (no ref) | `salary_basis_id uuid [null, ref: > comp_core.salary_basis.id]` |
| ADD | Comments | App-layer validation note: should reference eligible salary_basis |
| ADD | Auto-expiry note | Flow: scope change → contract close → work_relationship mới → auto-expire |

**Auto-expiry Rule (Q2 answer):**
- Trigger: Employee chuyển country/LE → hợp đồng cũ đóng → `work_relationship` mới → `assignment` mới
- Effect: `compensation.basis` cũ expire tự động (`is_current_flag=false`, `effective_end_date = change date`)
- Mechanism: Workflow lifecycle (contract close) → trigger expiry. Scheduler fallback nếu workflow thiếu.
- Post-expiry: HR notify → tạo `compensation.basis` mới với `salary_basis` eligible mới

**Decisions documented:**
- `pay_component_def` KHÔNG cần `eligibility_profile_id` riêng — eligibility chỉ ở `salary_basis` level.
  Employee eligible cho `salary_basis` → automatically eligible cho tất cả components qua `salary_basis_component_map`.

---

## [03Apr2026] – v5.4: Scheduling Level 5 — Hybrid Eligibility Architecture (Change 30)

> Context: Phân tích kiến trúc scheduling 6-level phát hiện Level 5 (`ta.schedule_assignment`) đang dùng manual `employee_id / employee_group_id / position_id` để xác định WHO. Cách này không nhất quán với Core eligibility engine đã được áp dụng cho Absence (`leave_class`), Total Rewards (`comp_plan`, `bonus_plan`, `benefit_plan`), và Payroll (`pay_element`). Đề xuất refactor Level 5 sang Hybrid Architecture.
> Architecture Decision: **Hybrid Model** — WHO via `eligibility_profile_id` (dynamic, auto-updated), WHAT via pattern/calendar/offset (unchanged). Level 6 (`ta.generated_roster`) **vẫn giữ nguyên** — không thể thay bằng dynamic calculation.

### TA-database-design-v5.dbml

**Change 30 – `ta.schedule_assignment`: WHO refactored to Centralized Eligibility Engine**

| Action | Field | Detail |
|--------|-------|--------|
| ADD | `eligibility_profile_id` uuid | FK → `eligibility.eligibility_profile.id`. Replaces manual WHO assignment. domain='SCHEDULING' |
| ADD | `employee_override_id` uuid | FK → `employment.employee.id`. Edge-case override cho CEO/expat/đặc biệt |
| DEPRECATED (commented) | `employee_id` | Thay bằng `eligibility_profile_id`. Giữ backward compat đến v6.0 |
| DEPRECATED (commented) | `employee_group_id` | Thay bằng `eligibility_profile_id`. Giữ backward compat đến v6.0 |
| DEPRECATED (commented) | `position_id` | Thay bằng `eligibility_profile_id`. Giữ backward compat đến v6.0 |
| ADD | Indexes | `(eligibility_profile_id, effective_start)`, `(employee_override_id, effective_start)` |
| UPDATE | Note | Documenting architecture change + rationale |

**Lý do Hybrid (không full-dynamic):**

| Vấn đề nếu bỏ Level 6 | Giải pháp phải giữ Level 6 |
|------------------------|---------------------------|
| Override từng ngày từng người không có chỗ lưu | `schedule_override` + `generated_roster.is_override` |
| Status lifecycle per-day (SCHEDULED→CONFIRMED) không có | `generated_roster.status_code` |
| Holiday đã resolved không được cache | `generated_roster.is_holiday + holiday_id` |
| Config thay đổi mid-month → lịch lịch sử sai | Frozen rows trong `generated_roster` |
| `clock_event` không biết scheduled shift để check trễ | JOIN `generated_roster` O(1) |
| Payroll export end-of-period re-calc không ổn định | Reads frozen `generated_roster` rows |

**Roster Generation Flow (Updated):**
```
eligibility_member.find_active(profile_id)  →  WHO list (O(1) cached)
schedule_assignment.pattern_id              →  WHAT pattern
cycle calculation + holiday check           →  per-day resolution
→ INSERT generated_roster (Level 6)         →  frozen, per employee × per day
```

**Consistency với các module khác:**

| Module | Entity | Sử dụng eligibility_profile_id |
|--------|--------|-------------------------------|
| TA | `ta.schedule_assignment` (Change 30) | ✅ |
| TA | `absence.leave_class` (existing) | ✅ |
| TR | `comp_core.comp_plan` (G6) | ✅ |
| TR | `comp_incentive.bonus_plan` (G6) | ✅ |
| TR | `benefit.benefit_plan` (G5) | ✅ |
| PR | `pay_master.pay_element` (G7) | ✅ |

**Documentation updated:**
- `01-scheduling-model.md` — Level 5 section updated with eligibility integration explanation
- `01.1-scheduling-levels-explained.md` — Updated hybrid architecture section

---

## [01Apr2026-b] – v5.3: Migrate Missing v4 Tables + Replace leave_accrual_run


> Context: Phân tích đối chiếu v4 vs v5 — phát hiện note "8-12. Giữ nguyên các bảng v4 khác" thực ra có 4 tables chưa được migrate. Thực tế chỉ 3 tables còn thiếu thực sự; 1 table (leave_event_run) tồn tại nhưng đã được redesign thành leave_accrual_run (Change 17) — nay thay lại bằng generalized version.

### TA-database-design-v5.dbml

**Change 26 – NEW `absence.leave_class_event` (migrate từ v4 table 8)**
- N:N mapping: `leave_class` ↔ `leave_event_def`
- Columns: `class_id`, `event_def_id`, `qty_formula` (±qty expr), `target_override`, `idempotent`
- PK composite: `(class_id, event_def_id)`
- Tại sao cần: `leave_event_def` không có ngữ nghĩa nếu không có bảng mapping này — không biết class nào trigger event nào

**Change 27 – NEW `absence.leave_period` (migrate từ v4 table 12)**

| Column | Detail |
|---|---|
| `code` | Unique: FY2025, FY2025Q2, FY2025M04 |
| `parent_id` | Self-ref: YEAR → MONTH hierarchy |
| `level_code` | YEAR \| QUARTER \| MONTH \| CUSTOM |
| `status_code` | OPEN → CLOSED → LOCKED |

- Tại sao cần: `leave_movement.period_id` và `leave_event_run.period_id` là FK "lơ lửng" — target table không tồn tại trong v5 trước change này

**Change 28 – NEW `absence.team_leave_limit` (migrate từ v4 table 15)**
- Staffing rule: giới hạn % hoặc số người nghỉ cùng lúc trong org_unit
- `limit_pct` decimal(5,2): % người được phép nghỉ (e.g., 20% team)
- `limit_abs_cnt` smallint: hoặc số người cố định (dùng 1 trong 2)
- `escalation_level`: trigger phê duyệt cao hơn khi chạm limit
- Validated tại submission time của `leave_request`

**Change 29 – REPLACE `leave_accrual_run` → `leave_event_run`**

| Dimension | leave_accrual_run (Change 17) | leave_event_run (Change 29) |
|---|---|---|
| Scope | ACCRUAL only | ALL event types (ACCRUAL, CARRY, EXPIRE, RESET) |
| Trigger identity | `plan_policy_id` (leave_policy) | `event_def_id` (leave_event_def) + `class_id` + `period_id` |
| Status codes | RUNNING\|COMPLETED\|FAILED\|SKIPPED | RUNNING\|COMPLETED\|FAILED\|SKIPPED\|CANCELED |
| Idempotency | `(tenant_id, plan_policy_id, period_start)` | `idempotency_key` unique + `schedule_key` |
| Stats | employee_count, movements_created | +`employees_skipped`, `stats_json` |
| Timestamps | started_at, completed_at, failed_at | same (cherry-picked) |
| created_by | required (uuid not null) | nullable (null = system scheduler) |

Cherry-picks từ `leave_accrual_run` được giữ lại trong `leave_event_run`:
- Granular status codes (COMPLETED/FAILED/SKIPPED vs v4 DONE/ERROR/CANCELED)
- Separate `started_at` / `completed_at` / `failed_at` timestamps (vs v4 `finished_at` kiêm nhiệm)
- `employee_count` + `movements_created` (v4 chỉ có `stats_json`)
- `failure_reason` text field
- Named unique index `uq_event_run_idempotency`

### TableGroup ta_absence — updated

| Action | Table |
|---|---|
| ADD | `absence.leave_class_event` (Change 26) |
| ADD | `absence.leave_period` (Change 27) |
| ADD | `absence.team_leave_limit` (Change 28) |
| REPLACE | `absence.leave_accrual_run` → `absence.leave_event_run` (Change 29) |

### Phân tích tables còn lại (không copy)

| Table v4 | Quyết định |
|---|---|
| `leave_balance_history` | Bỏ — reporting concern; `leave_movement` ledger đủ để reconstruct |
| `leave_wallet` | Bỏ — v4 note "view vật hoá tạm"; `leave_instant` trong v5 thay thế tốt hơn |

---

## [01Apr2026] – v5.2: FK Fixes, absence_rule Deprecated, Payroll Export Package

> Context: Review so sánh TA-database-design-v5.dbml vs archive/db.dbml — phát hiện 5 broken FK references, 2 table/index name mismatches, và các gaps về payroll dispatch tracking.
> Architecture Decision: Giữ business rules trong `leave_policy.config_json` thay vì tách thêm `absence_rule` table. Approval workflow do Temporal engine handle. Notification do Notification Service riêng.

### TA-database-design-v5.dbml

**Change 18 – Fix 5 broken FK references**

| Table | Column (before) | FK (before) | Column (after) | FK (after) |
|---|---|---|---|---|
| `ta.shift_break` | `shift_pattern_id` | `ta.shift_pattern.id` (not defined) | `shift_def_id` | `ta.shift_def.id` ✅ |
| `ta.attendance_record` | `shift_id` | `ta.shift.id` (not defined) | `shift_id` | `ta.shift_def.id` ✅ |
| `ta.shift_swap_request` | `requestor_shift_id` | `ta.shift.id` (not defined) | `requestor_shift_id` | `ta.shift_def.id` ✅ |
| `ta.shift_swap_request` | `target_shift_id` | `ta.shift.id` (not defined) | `target_shift_id` | `ta.shift_def.id` ✅ |
| `ta.shift_bid` | `shift_id` | `ta.shift.id` (not defined) | `open_shift_id` | `ta.open_shift_pool.id` ✅ |

> Root cause: Các table `ta.shift_pattern` và `ta.shift` đã bị comment out là DUPLICATE (27Mar2026) nhưng tables tham chiếu chúng không được update theo.

**Change 19 – DEPRECATED `absence.absence_rule`**
- User decision: Không duy trì `absence_rule` table riêng biệt.
- Business rules tiếp tục sống trong `absence.leave_policy.config_json` với `policy_type` discriminator.
- Table body được xóa; deprecation comment giữ lại để reference lịch sử.
- Approval workflow: Temporal engine handle → không cần `approval_chains` table trong TA DB.
- Notifications: Notification Service độc lập → không cần `notifications` table trong TA DB.

**Change 20 – `leave_accrual_run`: `plan_rule_id` → `plan_policy_id`**

| Action | Field | Detail |
|---|---|---|
| RENAME + RETYPE | `plan_rule_id → plan_policy_id` | FK đổi từ `absence_rule.id` → `absence.leave_policy.id` |
| UPDATE | Index unique | `(tenant_id, plan_rule_id, period_start)` → `(tenant_id, plan_policy_id, period_start)` |

**Change 21 – `absence.class_policy_assignment`: Fix index columns**

| Action | Before | After |
|---|---|---|
| FIX index | `(tenant_id, class_id, rule_id, is_current_flag)` | `(tenant_id, class_id, policy_id, is_current_flag)` |
| FIX index name | `uq_class_rule_assignment` | `uq_class_policy_assignment` |
| FIX index | `(rule_id)` | `(policy_id)` |

> Root cause: Khi rename từ `class_rule_assignment` sang `class_policy_assignment`, column được đổi từ `rule_id` → `policy_id` nhưng index definitions không được cập nhật.

**Change 22 – Fix TableGroup references**

| Action | Before | After |
|---|---|---|
| REMOVE | `absence.absence_rule` | Commented out (deprecated) |
| FIX name | `absence.class_rule_assignment` | `absence.class_policy_assignment` |
| ADD | — | `ta.payroll_export_package` in `ta_attendance` group |

**Change 23 – NEW `ta.payroll_export_package`**
- Sourced from `archive/db.dbml` `payroll_export_packages` pattern.
- Tracks TA → Payroll data dispatch lifecycle: PENDING → DISPATCHED → ACKNOWLEDGED | FAILED.
- Fields: `period_id`, `generated_by`, summary totals (regular/OT/leave/comp hours), `checksum` (SHA-256), `dispatch_status`, `payroll_system_ref`
- Idempotency: `(period_id) [unique]` — one export per period, re-run returns existing
- ADR-TA-001: Append-only table

**Changes 24–25 – NOT NULL + Named indexes (selective)**
- `ta.shift_break`: Added NOT NULL on `shift_def_id`, `name`, `start_offset_hours`, `duration_hours`
- `ta.payroll_export_package`: Full NOT NULL discipline on all required fields + named indexes
- Future work: Systematic NOT NULL pass across all remaining tables (separate task)

### Summary

| Type | Count | Detail |
|---|---|---|
| FK fixed | 5 | shift_break, attendance_record, shift_swap_request (×2), shift_bid |
| Table deprecated | 1 | `absence_rule` |
| Table added | 1 | `ta.payroll_export_package` |
| Index fixed | 3 | class_policy_assignment index columns + name |
| TableGroup updated | 2 | ta_attendance (+1), ta_absence (fix name + remove deprecated) |
| FK renamed | 1 | `leave_accrual_run.plan_rule_id` → `plan_policy_id` |

---

## [30Mar2026] – Option C: Centralized Rule Engine (Absence)

> Context: Normalize all absence business rules from JSONB columns into a centralized `absence_rule` table with `rule_type` discriminator. Decouple rules from leave_policy/class via N:N mapping. Centralize eligibility to `leave_class` only. Remove redundant `policy_assignment`.
> Architecture Decision: Option C — Centralized Rule Engine with independent N:N mapping.
> Cross-reference: [bounded-contexts.md § 11](../01-modules/TA/03.domain/bounded-contexts.md), [glossary.md](../01-modules/TA/03.domain/absence/glossary.md), [BRD](../01-modules/TA/02.reality/brd.md)

### TA-database-design-v5.dbml

**Change 11 – `absence.leave_type`: Eligibility removed + cancellation deadline**

| Action | Field | Detail |
|--------|-------|--------|
| REMOVE | `default_eligibility_profile_id` | Eligibility centralized at `leave_class` level only. Core eligibility engine is single source of truth for WHO. |
| ADD | `cancellation_deadline_days` int [default:1] | Explicit cancellation deadline — BRD BR-ABS-008, H-P0-001. Business days before leave start; self-cancel blocked after. Configurable per type/BU. |

**Change 12 – `absence.leave_policy`: Eligibility removed + class FK + JSONB DEPRECATED**

| Action | Field | Detail |
|--------|-------|--------|
| REMOVE | `default_eligibility_profile_id` | Same rationale as Change 11. |
| ADD | `class_id` uuid [FK → leave_class] | Code hiện tại link class qua policy vẫn hoạt động. |
| DEPRECATE (keep) | `accrual_rule_json` | → migrate sang `absence_rule(ACCRUAL)` |
| DEPRECATE (keep) | `carry_rule_json` | → migrate sang `absence_rule(CARRY)` |
| DEPRECATE (keep) | `limit_rule_json` | → migrate sang `absence_rule(LIMIT)` |
| DEPRECATE (keep) | `validation_json` | → migrate sang `absence_rule(VALIDATION)` |
| DEPRECATE (keep) | `rounding_json` | → migrate sang `absence_rule(ROUNDING)` |
| DEPRECATE (keep) | `proration_json` | → migrate sang `absence_rule(PRORATION)` |

> Note: JSONB columns are KEPT to avoid development errors. Marked DEPRECATED via comments. Code mới đọc từ `absence_rule`, code cũ vẫn đọc JSONB.

**Change 13 – `absence.policy_assignment` DEPRECATED (commented out)**
- Replaced by Core eligibility engine (`eligibility.eligibility_profile`).
- WHO is eligible → determined by `eligibility_profile_id` on `leave_class`.
- Core module provides centralized O(1) eligibility membership checks.

**Change 14 – NEW `absence.absence_rule` (Centralized Rule Engine)**
- Centralized rule repository for ALL absence business rules.
- `rule_type` discriminator maps to 9 Policy Entities from bounded-contexts.md § 11:

| Phase | rule_type | Source Policy Entity | Hot Spot |
|-------|-----------|---------------------|----------|
| Phase 1 | `ACCRUAL` | LeavePolicy | — |
| Phase 1 | `CARRY` | LeavePolicy | — |
| Phase 1 | `LIMIT` | LeavePolicy | — |
| Phase 1 | `VALIDATION` | LeavePolicy | — |
| Phase 1 | `PRORATION` | LeavePolicy | — |
| Phase 1 | `ROUNDING` | LeavePolicy | — |
| Phase 1 | `SENIORITY` | LeavePolicy | VLC Art. 113 |
| Phase 2 | `COMP_TIME` | CompTimePolicy | H-P0-002 |
| Phase 2 | `OVERTIME` | OvertimePolicy | H-P1-006 |
| Phase 2 | `SHIFT_SWAP` | ShiftSwapPolicy | H-P1-002 |
| Phase 2 | `BIOMETRIC` | BiometricPolicy | H-P1-003 |
| Phase 2 | `HOLIDAY` | HolidayPolicy | H-P1-007 |
| Phase 2 | `TERMINATION` | TerminationPolicy | H-P0-004 |
| Phase 2 | `APPROVAL` | ApprovalChain | H-P0-003 |

- `config_json` JSONB payload — schema validated per `rule_type` at application layer
- SCD Type 2 versioning (`is_current_flag`, `version`)
- Scopable: optional `country_code`, `legal_entity_id`
- Unique: `(tenant_id, rule_type, code, is_current_flag)`

**Change 15 – NEW `absence.class_rule_assignment` (N:N Mapping)**
- N:N mapping between `leave_class` and `absence_rule`.
- `leave_class` is NOT modified — rules connected via this independent table.
- Fields: `class_id`, `rule_id`, `priority` (eval order), `is_override`, `effective_start/end`, `is_current_flag`
- Unique: `(tenant_id, class_id, rule_id, is_current_flag)`
- Enables rule reuse (1 rule → N classes) and independent lifecycle management

**Change 16 – NEW `absence.leave_reservation_line` (FEFO Sub-table)**
- FEFO-ordered reservation lines linking to `leave_instant_detail` lots.
- Fields: `reservation_id` (FK → leave_reservation), `source_lot_id` (FK → leave_instant_detail), `reserved_amount`, `expiry_date`
- Enables FK integrity for FEFO tracking + SQL-queryable reservation breakdown

**Change 17 – NEW `absence.leave_accrual_run` (Idempotent Batch)**
- Accrual batch run tracking with idempotency constraint (ADR-TA-002).
- Fields: `plan_rule_id` (FK → absence_rule), `period_start`, `period_end`, `status_code`, `employee_count`, `movements_created`
- Unique: `(tenant_id, plan_rule_id, period_start)` — prevents duplicate runs
- Status: RUNNING | COMPLETED | FAILED | SKIPPED

**TableGroup `ta_absence` updated:**
- Removed: `absence.policy_assignment` (Change 13)
- Added: `absence.leave_reservation_line` (Change 16), `absence.absence_rule` (Change 14), `absence.class_rule_assignment` (Change 15), `absence.leave_accrual_run` (Change 17)

### Summary: Schema Change Impact

| Type | Tables | Impact |
|------|--------|--------|
| NEW tables | `absence_rule`, `class_rule_assignment`, `leave_reservation_line`, `leave_accrual_run` | 4 new tables, no existing code impact |
| MODIFIED tables | `leave_type` (-1/+1 field), `leave_policy` (-1/+1 field, 6 DEPRECATED) | Minimal — eligibility removed, JSONB kept |
| DEPRECATED tables | `policy_assignment` (commented out) | 1 table removed |
| Total new columns | 3 new tables × ~15 cols + 2 added columns | ~50 new columns |

---

## [27Mar2026-i] – TA v5.1: Schema Quality & Compliance Update

> Context: Cherry-pick best practices from brainstormed `db.dbml` into production `TA-database-design-v5.dbml`. Preserves 6-level scheduling hierarchy and all cross-module integrations.

### TA-database-design-v5.dbml

**Change 1 – Comment out 6 DUPLICATE tables**
- `ta.shift_pattern_DUPLICATE`, `ta.shift_DUPLICATE`, `ta.timesheet_entry_DUPLICATE`, `ta.time_exception_DUPLICATE`, `ta.overtime_rule_DUPLICATE`, `ta.overtime_calculation_DUPLICATE`
- These overlap with tables defined in the 6-level hierarchy above

**Change 2 – 15+ Enum definitions (documentation & validation reference)**
- Attendance: `punch_type`, `punch_sync_status`, `worked_period_status`, `overtime_type`, `timesheet_status`
- Absence: `leave_category`, `entitlement_basis`, `leave_unit`, `movement_type`, `leave_request_status`, `reservation_status`, `expiry_action`, `comp_time_expiry_action`, `termination_balance_action`
- Shared: `period_status`, `period_type`
- Note: Columns remain `varchar` for backward compatibility; enums are doc/constraint references

**Change 3 – 5 Bounded Context TableGroups**

| TableGroup | Tables |
|---|---|
| `ta_scheduling` | time_segment, shift_def, shift_segment, day_model, pattern_template, pattern_day, schedule_assignment, generated_roster, schedule_override, open_shift_pool |
| `ta_attendance` | clock_event, timesheet_header, timesheet_line, time_type_element_map, time_exception, eval_rule, eval_result, period |
| `ta_absence` | leave_type, leave_class, leave_policy, policy_assignment, leave_instant, leave_instant_detail, leave_movement, leave_request, leave_reservation, leave_event_def, holiday_calendar, holiday_date, termination_balance_record |
| `ta_operational` | shift_swap_request, shift_bid, overtime_request, attendance_record, shift_break, schedule, comp_time_balance |
| `ta_shared` | shared.schedule, shared.holiday, shared.period_profile |

**Change 4 – VLC Compliance annotations**
- `ta.clock_event`: Append-only (ADR-TA-001)
- `ta.overtime_request`: VLC Art. 107 caps (daily=4h, monthly=40h, annual=300h), VLC Art. 98 rates
- `absence.leave_type`: VLC Art. 113 (annual), Art. 114 (sick), Art. 139 (maternity), Art. 115 (unpaid)

**Change 5 – `ta.clock_event` enhanced** (7 new fields)

| Field | Type | Purpose |
|---|---|---|
| `sync_status` | varchar(20) | Offline-first: PENDING / SYNCED / CONFLICT |
| `synced_at` | timestamptz | Server receipt time |
| `conflict_reason` | text | Sync conflict explanation |
| `geofence_validated` | boolean | Device within designated geofence |
| `is_correction` | boolean | Correction punch marker |
| `corrects_event_id` | uuid (self-ref) | Links to original event |
| `idempotency_key` | varchar(255) | Client dedup key (unique index) |

**Change 6 – NEW `ta.comp_time_balance`**
- Tracks compensatory time off earned from OT (VLC Art. 98)
- Fields: `earned_hours`, `used_hours`, `available_hours`, `expiry_date`, `expiry_action`
- One record per employee (unique index)

**Change 7 – `ta.overtime_request` enhanced** (6 new fields)
- `ot_type`: WEEKDAY/WEEKEND/PUBLIC_HOLIDAY (VLC Art. 98)
- `ot_rate`: 1.5/2.0/3.0
- `comp_time_elected`: boolean — take comp-time instead of pay
- VLC Art. 107 caps: `daily_ot_cap_hours` (4), `monthly_ot_cap_hours` (40), `annual_ot_cap_hours` (300)

**Change 8 – NEW `ta.period`**
- Payroll period lifecycle: OPEN → LOCKED → CLOSED
- `ta.timesheet_header.period_id` FK added for cross-reference

**Change 9 – NEW `absence.termination_balance_record`**
- Leave balance snapshot at employee termination
- `balance_action`: AUTO_DEDUCT / HR_REVIEW / WRITE_OFF / RULE_BASED
- `employee_consent_obtained`: VLC Art. 21 compliance (written consent for auto-deduction)
- Cross-module: Payroll `pay_master.termination_pay_config` handles payment element

**Change 10 – `timestamp` → `timestamptz` (61 fields)**
- All `timestamp` fields in non-commented tables converted to `timestamptz`
- Critical: `clock_event.event_dt`, `attendance_record.clock_in/out_time`, `leave_movement.posted_at`
- PostgreSQL best practice: same storage, prevents timezone ambiguity

---

## [27Mar2026-h] – AQ-14: Pay Scale / Ngạch Bậc Configuration (Option D)

> Context: VN has 2 pay scale models — TABLE_LOOKUP (private) and COEFFICIENT_FORMULA (gov/SOE)

### 4.TotalReward.V5.dbml

**`grade_ladder_step` enriched** — 3 new fields:
- `coefficient` decimal(8,4) — hệ số lương (e.g., 2.34 × lương cơ sở)
- `months_to_next_step` — step progression rule (NULL = manual)
- `auto_advance` — auto-advance when time met

### 5.Payroll.V4.dbml

**`pay_profile` enriched** — 2 new fields:
- `grade_step_mode`: `TABLE_LOOKUP` (salary = step_amount) | `COEFFICIENT_FORMULA` (salary = coefficient × VN_LUONG_CO_SO)
- `pay_scale_table_code`: FK → TR.grade_ladder.code (different profiles can use different scale tables)

**Domain boundary**: coefficient/step_amount = TR projected (Gross); VN_LUONG_CO_SO = PR statutory_rule (actual)

---

## [27Mar2026-g] – AQ-13: Piece-Rate Configuration (Option C)

> Context: Manufacturing/garment workers on lương sản phẩm need configurable rate per product × quality grade

### 5.Payroll.V4.dbml

**NEW `piece_rate_config`** — (product × quality_grade → rate_per_unit)
- Product codes: `SHIRT / SHOE / PCB_BOARD / ASSEMBLY_UNIT_A`
- Quality grades: `STANDARD / GRADE_A / GRADE_B / GRADE_C / REJECT`
- `quality_multiplier` for grade-based rate derivation
- `unit_code`: `PIECE / KG / METER / PAIR / SET`
- Links to `statutory_rule` for min wage floor + OT multiplier
- `pay_profile_id` NULL = global rate; non-null = profile-specific

**Data flow**: Production/TA → quantities via `input_source_config` → `piece_rate_config` lookup → formula calculates pay

---

## [27Mar2026-f] – AQ-12: Hourly Rate Differentiation (Hybrid C+D)

> Context: Hourly workers need differentiated rates by shift type (regular, night, OT); requires profile defaults + worker overrides

### 5.Payroll.V4.dbml

**Architecture**: 3-layer rate lookup
1. **Layer 1** `worker_rate_override` — per-worker exception (optional, ~5% workers)
2. **Layer 2** `pay_profile_rate_config` — profile-level defaults per dimension
3. **Layer 3** `statutory_rule` — OT multipliers per Labor Code

**NEW `pay_profile_rate_config`** — (pay_profile × rate_dimension → base_rate)
- Dimensions: `REGULAR / NIGHT / OT_WEEKDAY / OT_WEEKEND / OT_HOLIDAY / HAZARDOUS / SPECIALIZED`
- Rate types: `FIXED` (absolute VND/h), `MULTIPLIER` (× regular rate), `FORMULA`
- Links to `statutory_rule` for law-driven OT rates

**NEW `worker_rate_override`** — per-worker exception rates
- Absolute override rate per dimension (not multiplier to avoid confusion)
- Governance: `approved_by`, `approved_at`, `reason_code`

**No TA/TR changes needed** — TA already provides hours by `time_type_code`; TR/CO provides base compensation

---

## [27Mar2026-e] – AQ-10: Termination Pay Configuration (Option D)

> Context: Final-pay run needs configurable element scope per termination type

### 5.Payroll.V4.dbml

**NEW `termination_pay_config`** — maps (termination_type × pay_profile) → element list
- Fields: `termination_type` (RESIGNATION/MUTUAL_AGREEMENT/REDUCTION_IN_FORCE/END_OF_CONTRACT/DISMISSAL/RETIREMENT), `element_id`, `execution_order`, `formula_override_json`
- Unique: `(pay_profile_id, termination_type, element_id)`

**`batch_type` updated** — added `TERMINATION` value

---

## [27Mar2026-d] – Temporal Workflow Migration: Deprecate DB Approval Tables

> Context: Workflow orchestration (approval chains, escalation, timeout) will use Temporal workflow engine
> Principle: DB keeps **state tracking** (`status_code`, `approved_by/at`); Temporal handles **orchestration**

### Deprecated Tables (2)

| Table | Module | File |
|-------|--------|------|
| `pay_mgmt.batch_approval` | PR | `5.Payroll.V4.dbml` |
| `absence.approval` | TA | `TA-database-design-v5.dbml` |

### Deprecated Fields (5)

| Field | Table | Module |
|-------|-------|--------|
| `workflow_state` jsonb | `comp_core.comp_cycle` | TR |
| `workflow_state` jsonb | `comp_core.comp_adjustment` | TR |
| `workflow_state` jsonb | `comp_incentive.bonus_cycle` | TR |
| `workflow_state` jsonb | `absence.leave_request` | TA |
| `escalation_level` smallint | `absence.leave_request` | TA |

### Kept (state + audit stamps)
- `status_code` on all entity tables — Temporal updates via activity/signal
- `approved_by`, `approved_at` — final audit stamp
- `requires_approval` flags — config input to Temporal

---

## [27Mar2026-c] – AQ-02: PayProfile Rich Relational Schema (Option C)

> Context: `pay_profile` was a minimal container (code, name only). Needs explicit config columns for BRD story writing.
> Decision: **Option C — Rich Relational Schema** with explicit columns + join tables

### 5.Payroll.V4.dbml

**`pay_profile` ENRICHED** (8 new columns)

| Field | Type | Purpose |
|-------|------|---------|
| `parent_profile_id` | FK self-ref | Profile inheritance hierarchy |
| `pay_method` | varchar(30) | MONTHLY_SALARY, HOURLY, PIECE_RATE, GRADE_STEP, TASK_BASED |
| `proration_method` | varchar(20) | CALENDAR_DAYS, WORK_DAYS, NONE |
| `rounding_method` | varchar(20) | ROUND_HALF_UP, ROUND_DOWN, ROUND_UP, ROUND_NEAREST |
| `payment_method` | varchar(20) | BANK_TRANSFER, CASH, CHECK, WALLET |
| `default_currency` | char(3) | Override currency (NULL = inherit from pay_group) |
| `min_wage_rule_id` | FK → statutory_rule | Minimum wage region compliance |
| `default_calendar_id` | FK → pay_calendar | Default calendar |

**NEW join tables (2 tables)**

| Table | Purpose |
|-------|---------|
| `pay_profile_element` | Bind elements to profile (priority, default_amount, formula override) |
| `pay_profile_rule` | Bind statutory rules to profile (execution_order, override_params) |

---

## [27Mar2026-b] – ADR Option D: Calculation Rule Domain Boundary

> Context: Cross-module conflict between TR `calculation_rule_def` and PR `statutory_rule`
> Decision: **Option D — Dual Ownership with Formal Contract**
> - TR owns HR-policy rules (up to Gross): PRORATION, ROUNDING, FOREX, ANNUALIZATION, COMPENSATION_POLICY
> - PR owns statutory rules (Gross→Net): TAX, SOCIAL_INSURANCE, OVERTIME, GROSS_TO_NET
> - Data contract: TR → PR delivers `compensation.basis` (gross) as data, not executable rules

### 4.TotalReward.V5.dbml

**`calculation_rule_def.rule_category` restricted**
- Removed: TAX, SOCIAL_INSURANCE, OVERTIME (→ PR domain)
- Kept: PRORATION | ROUNDING | FOREX | ANNUALIZATION | COMPENSATION_POLICY

**`component_calculation_rule.rule_scope` restricted**
- Removed: TAX, SI_CALCULATION (→ PR domain)
- Kept: COMPONENT_CALC | PRORATION | VALIDATION | ANNUALIZATION

**`basis_calculation_rule.rule_scope` restricted**
- Removed: TAX, SI_CALCULATION, GROSS_TO_NET (→ PR domain)
- Kept: PRORATION | ROUNDING | ANNUALIZATION

**`tax_calculation_cache` DEPRECATED**
- Entire table commented out — tax calculation is PR engine's responsibility
- If PR needs cache, will create at `pay_engine` schema

### 5.Payroll.V4.dbml

**`statutory_rule` ENRICHED** (Single Authority for statutory rules)
- New fields: `rule_category`, `rule_type`, `country_code`, `jurisdiction`, `legal_reference`
- New indexes: `(rule_category)`, `(rule_category, country_code)`, `(country_code)`
- Scope: TAX | SOCIAL_INSURANCE | OVERTIME | GROSS_TO_NET

---

## [27Mar2026] – Payroll Engine Separation (V3 → V4)

> Review: [review-03-payroll-engine-separation.md](./review-03-payroll-engine-separation.md)
> File: `5.Payroll.V4.dbml` (replaces `5.Payroll.V3.dbml`)

### Architecture Change

**Tách `pay_run` schema thành 2 schema độc lập:**
- `pay_mgmt` — Payroll Management (orchestration, batch lifecycle, approval)
- `pay_engine` — Payroll Calculation Engine (execution, results, balances)

### Migrated Tables (9 tables)

| V3 (`pay_run.*`) | V4 | Schema | Changes |
|---|---|---|---|
| `batch` | `pay_mgmt.batch` | pay_mgmt | +`period_id`, +`pay_group_id` (restored), +`engine_request_id`, expanded `status_code`, +`submitted_at`, +`calc_completed_at` |
| `manual_adjust` | `pay_mgmt.manual_adjust` | pay_mgmt | FK updated: `pay_run.batch` → `pay_mgmt.batch` |
| `employee` | `pay_engine.run_employee` | pay_engine | +`request_id`, +`assignment_id`, +`pay_group_id`, +variance fields, +`error_message` |
| `input_value` | `pay_engine.input_value` | pay_engine | FK updated only |
| `result` | `pay_engine.result` | pay_engine | FK updated only |
| `balance` | `pay_engine.balance` | pay_engine | FK updated only |
| `retro_delta` | `pay_engine.retro_delta` | pay_engine | FK updated only |
| `calc_log` | `pay_engine.calc_log` | pay_engine | FK updated only |
| `costing` | `pay_engine.costing` | pay_engine | FK updated only |

### New Tables (8 tables)

| Table | Schema | Purpose |
|---|---|---|
| `pay_period` | pay_mgmt | Explicit period records (replaces implicit `calendar_json`) |
| `batch_approval` | pay_mgmt | Multi-level approval workflow for batches |
| `run_request` | pay_engine | **Engine interface contract** — request/response between mgmt ↔ engine |
| `calculation_step` | pay_engine | Step configuration (INPUT_COLLECTION, EARNINGS, TAX…) |
| `run_step` | pay_engine | Per-run step execution tracking |
| `cumulative_balance` | pay_engine | YTD/QTD/LTD persistent balance tracking |
| `element_dependency` | pay_engine | DAG dependency graph between elements |
| `input_source_config` | pay_engine | Automated input collection config from TA/Absence/Comp modules |

### FK Updates (existing tables)

| Table | Old FK | New FK |
|---|---|---|
| `pay_bank.payment_batch.run_batch_id` | `pay_run.batch.id` | `pay_mgmt.batch.id` |
| `generated_file.payroll_run_id` | `pay_run.batch.id` | `pay_mgmt.batch.id` |

---

## [26Mar2026] – Cross-Module Structural Review

> Review: [review-01-dbml-cross-module-analysis.md](./review-01-dbml-cross-module-analysis.md)

### 1.Core.V4.dbml

**G1 – `compensation.basis`: Added `assignment_id` FK**
- Added `assignment_id uuid [ref: > employment.assignment.id, null]`
- Supports multi-assignment per employee within same Legal Entity
- Nullable for backward compatibility (primary case: 1 emp = 1 active assignment)

**G2 – `compensation.basis`: Piece-rate / Output-based pay**
- Extended `frequency_code` with `PER_UNIT` value
- Added fields:
  - `output_unit_code varchar(30)` — đơn vị sản phẩm (PIECE, ARTICLE, TEACHING_HOUR, GARMENT)
  - `unit_rate_amount decimal(15,4)` — rate per unit
  - `guaranteed_minimum decimal(15,2)` — lương tối thiểu đảm bảo

---

### TA-database-design-v5.dbml

**G3+G4 – New table `ta.time_type_element_map`**
- Bridge table: `time_type_code` → `pay_element_code`
- Includes rate source config (`rate_source_code`):
  - `COMPONENT_DEF` — global rate from pay_component_def
  - `EMPLOYEE_SNAPSHOT` — personalized rate per employee
  - `FIXED` — use `default_rate` on this record
  - `FORMULA` — dynamic calculation from pay_element
- Replaces implicit mapping via `source_ref`

---

### 4.TotalReward.V5.dbml

**G5 – Unified Benefits eligibility**
- Deprecated `benefit.eligibility_profile` (kept for migration)
- Deprecated `benefit.plan_eligibility`
- Added `eligibility_profile_id uuid [null]` FK to `benefit.benefit_plan`
- Points to centralized `eligibility.eligibility_profile` (domain='BENEFITS')

**G6 – Comp/Bonus Plan eligibility**
- Added `eligibility_profile_id uuid [null]` FK to:
  - `comp_core.comp_plan`
  - `comp_incentive.bonus_plan`
- Deprecated `eligibility_rule jsonb` on both tables

**G8 – New table `total_rewards.employee_reward_summary`**
- Aggregation table: per-employee reward overview
- Fields: `reward_type`, `reward_source`, `reward_entity_id`, `status`, `calculated_value`
- Links to centralized `eligibility_profile_id`
- Materialized summary updated by background eligibility evaluation

---

### 5.Payroll.V3.dbml

**G7 – Pay Element eligibility**
- Added `eligibility_profile_id uuid [null]` to `pay_master.pay_element`
- Links payroll elements to centralized eligibility engine

---

### Skipped

- **G9** – `3.Absence.v4.dbml` sync with TA v5.1: Skipped per decision — v4 kept as legacy reference

## [26Mar2026-b] – Eligibility Review & Fixes

> Review: [eligibility-guide.md](./eligibility-guide.md)
> Findings appended to: [review-01-dbml-cross-module-analysis.md](./review-01-dbml-cross-module-analysis.md)

### TA-database-design-v5.dbml

**F1 – Schema name mismatch**
- Fixed 3 FKs: `core.eligibility_profile.id` → `eligibility.eligibility_profile.id`
- Affected: `leave_type`, `leave_class`, `leave_policy`

### 5.Payroll.V3.dbml

**F2 – Added explicit `ref:` syntax**
- `pay_element.eligibility_profile_id`: Added `ref: > eligibility.eligibility_profile.id`

### 4.TotalReward.V5.dbml

**F2 – Added explicit `ref:` syntax**
- `comp_plan.eligibility_profile_id`: Added `ref: > eligibility.eligibility_profile.id`
- `bonus_plan.eligibility_profile_id`: Added `ref: > eligibility.eligibility_profile.id`
- `benefit_plan.eligibility_profile_id`: Added `ref: > eligibility.eligibility_profile.id`

**F3 – Migration timeline for deprecated tables**
- `benefit.eligibility_profile`: Remove in v6.0 (target Q3 2026)
- `benefit.plan_eligibility`: Remove in v6.0 (target Q3 2026)

### 1.Core.V4.dbml

**F4 – Extended domain enum**
- `eligibility_profile.domain`: Added `PAYROLL` (was: ABSENCE | BENEFITS | COMPENSATION | CORE)

---

## [26Mar2026-c] – Multi-Country/LE Configuration Scoping

> Review: [review-02-tr-country-le-scoping.md](./review-02-tr-country-le-scoping.md)
> Guide: [config-scoping-guide.md](./config-scoping-guide.md)

### 4.TotalReward.V5.dbml

**NEW tables: `comp_core.config_scope` + `config_scope_member` (Option 2)**
- Config Scope Group: named scope abstraction (COUNTRY, LE, BU, HYBRID)
- Supports hierarchy (parent_scope_id) + inheritance (inherit_flag)
- Member bridge table for HYBRID scopes spanning multiple countries/LEs

**Multi-country scoping added to 4 definition tables:**

| Table | `country_code` | `legal_entity_id` | `config_scope_id` |
|-------|:-:|:-:|:-:|
| `salary_basis` | ✅ | ✅ | ✅ |
| `pay_component_def` | ✅ | — | ✅ |
| `comp_plan` | ✅ | ✅ | ✅ |
| `bonus_plan` | ✅ | ✅ | ✅ |

### 5.Payroll.V3.dbml

**Multi-country scoping added:**

| Table | `country_code` | `config_scope_id` |
|-------|:-:|:-:|
| `pay_element` | ✅ | ✅ |

---