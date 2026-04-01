# TR-PR Boundary Analysis — Component Mapping & Overlap Detection

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-06  
**Đối tượng**: Solution Architect, Tech Lead, Product Manager  
**Thời gian đọc**: ~30 phút

---

## 1. Tổng quan

Tài liệu này phân tích **ranh giới thực tế** giữa TR (Total Rewards) và PR (Payroll) modules bằng cách mapping entity-by-entity từ 2 DBML schemas:
- **TR**: `4.TotalReward.V5.dbml` (1,445 dòng, 11 schema groups)
- **PR**: `5.Payroll.V3.dbml` (545 dòng, 4 schemas: `pay_master`, `pay_run`, `pay_gateway`, `pay_bank`)

Mục tiêu: Phát hiện overlap, gap, và đề xuất ranh giới rõ ràng.

---

## 2. Entity Mapping — TR Components ↔ PR Elements

### 2.1 Taxonomy So sánh

| Khía cạnh | TR `pay_component_def` | PR `pay_element` |
|-----------|----------------------|------------------|
| **Schema** | `comp_core.pay_component_def` | `pay_master.pay_element` |
| **Primary Key** | `id` (uuid) | `id` (uuid) |
| **Code** | `code` varchar(50) | `code` varchar(50) |
| **Tên** | `name` varchar(200) | `name` varchar(100) |
| **Classification** | `component_type` (6 types) | `classification` (3 types) |

### 2.2 Type Mapping

| TR `component_type` | PR `classification` | Mapping | Ghi chú |
|---------------------|---------------------|---------|---------|
| **BASE** | **EARNING** | 1:1 | Base salary |
| **ALLOWANCE** | **EARNING** | N:1 | Lunch, transport → all mapped to EARNING |
| **BONUS** | **EARNING** | N:1 | STI, LTI → EARNING in PR |
| **EQUITY** | *(not direct)* | via TaxableBridge | RSU/Options → `taxable_item` → PR |
| **DEDUCTION** | **DEDUCTION** | 1:1 | Loan, garnishment |
| **OVERTIME** | **EARNING** | N:1 | OT pay → EARNING in PR |
| *(none)* | **TAX** | 0:1 | PR has TAX type, TR does not |

> **Phát hiện #1**: PR chỉ có 3 classifications (EARNING, DEDUCTION, TAX). TR có 6 types với nhiều semantic hơn. Khi data chảy từ TR sang PR, taxonomy bị flatten — mất thông tin về loại component.

### 2.3 Field-level Mapping

| TR Field | PR Field | Match? | Gap |
|----------|----------|:------:|-----|
| `code` | `code` | ✅ | |
| `name` | `name` | ✅ | TR cho 200 chars, PR chỉ 100 |
| `component_type` | `classification` | ⚠️ | Taxonomy khác, xem bảng trên |
| `frequency` | *(none)* | ❌ | PR element không có frequency |
| `taxable` | `taxable_flag` | ✅ | |
| `prorated` | *(none)* | ❌ | PR element không có proration flag |
| `formula_json` | `formula_json` | ✅ | Cả hai đều dùng jsonb for formula |
| `calculation_method` | *(none)* | ❌ | FIXED/FORMULA/PERCENTAGE/HOURLY — TR có, PR không |
| `proration_method` | *(none)* | ❌ | CALENDAR_DAYS/WORKING_DAYS/NONE — TR có, PR không |
| `tax_treatment` | *(mapped to flags)* | ⚠️ | TR: FULLY_TAXABLE/TAX_EXEMPT/PARTIALLY_EXEMPT; PR: `taxable_flag` + `pre_tax_flag` |
| `tax_exempt_threshold` | *(none)* | ❌ | 730K lunch allowance → TR biết, PR không biết |
| `is_subject_to_si` | *(none)* | ❌ | SI applicability → TR has, PR relies on statutory_rule |
| `si_calculation_basis` | *(none)* | ❌ | FULL_AMOUNT/CAPPED/EXCLUDED → TR has, PR infers from formulas |
| `display_order` | `priority_order` | ✅ | Tên khác, nghĩa tương tự |
| `effective_start/end` | `effective_start_date/end_date` | ✅ | SCD2 |
| `input_required` | *(none at TR)* | ❌ | PR has manual input flag, TR auto-calculated |
| `unit` (AMOUNT/HOURS) | *(none at TR)* | ❌ | PR element knows unit, TR component doesn't |
| `statutory_rule_id` | *(none at TR)* | ❌ | PR links element to statutory rule directly |
| `gl_account_code` | *(none at TR)* | ❌ | PR element knows GL mapping, TR doesn't |

> **Phát hiện #2**: TR `pay_component_def` có **nhiều metadata hơn** về calculation (proration_method, tax_treatment, si_calculation_basis), nhưng thiếu runtime fields (input_required, unit, statutory_rule_id, gl_account_code). PR `pay_element` ngược lại — ít metadata nhưng có runtime linkage.

---

## 3. Structural Mapping — Configuration Layer

### 3.1 Salary Basis ↔ PayProfile

| TR Entity | PR Entity | Relationship |
|-----------|-----------|:----------:|
| `comp_core.salary_basis` | `pay_master.pay_profile` | **Tương đương nhưng khác scope** |
| Salary Basis = "cách trả lương" (frequency, currency) | PayProfile = "bundle policy" (elements + rules + deductions) | |
| `salary_basis_component_map` | *(implicit via profile)* | TR explicit mapping, PR implicit |

**So sánh chi tiết**:

```
TR Salary Basis (MONTHLY_VN):
  ├── frequency: MONTHLY
  ├── currency: VND
  ├── Components (via salary_basis_component_map):
  │   ├── BASE_SALARY (mandatory, proration: calendar_days)
  │   ├── LUNCH_ALLOWANCE (optional, proration: working_days)
  │   └── TRANSPORTATION (optional, proration: working_days)
  └── Calculation Rules (via basis_calculation_rule):
      ├── VN_PIT_2025 (execution_order: 5)
      ├── VN_SI_2025 (execution_order: 4)
      └── VN_PRORATION (execution_order: 1)

PR PayProfile (VN-STANDARD-STAFF):
  ├── legal_entity_id: VNG Corp
  ├── market_id: VN
  ├── Elements (via concept, not in schema):
  │   ├── BASE_SALARY (EARNING)
  │   ├── OVERTIME (EARNING)
  │   └── LUNCH_ALLOWANCE (EARNING)
  ├── Statutory Rules: BHXH, BHYT, BHTN, PIT
  └── Deduction Policies
```

> **Phát hiện #3**: TR `salary_basis` + `salary_basis_component_map` + `basis_calculation_rule` tạo thành một **configuration bundle hoàn chỉnh** cho tính lương. PR `pay_profile` cũng là configuration bundle — nhưng chỉ có concept (overview docs), DBML chỉ có `pay_profile` + `pay_profile_map` với rất ít fields. **TR phong phú hơn đáng kể về cấu hình tính toán.**

### 3.2 Grade System — Hoàn toàn thuộc TR

| Entity | Module | Ghi chú |
|--------|:------:|---------|
| `comp_core.grade_v` | TR | SCD2 versioned grades |
| `comp_core.grade_ladder` | TR | Career ladders |
| `comp_core.grade_ladder_grade` | TR | Ladder-grade mapping |
| `comp_core.grade_ladder_step` | TR | Steps within grade |
| `comp_core.pay_range` | TR | Multi-scope pay ranges |

> PR KHÔNG có bất kỳ grade/ladder entity nào. Grade là input thuần từ TR → PR sử dụng gián tiếp (ví dụ: formula dùng `grade_code` trong conditions).

### 3.3 Calendar & Period — Overlap

| TR Entity | PR Entity | Overlap? |
|-----------|-----------|:--------:|
| *(none)* | `pay_master.pay_frequency` | **PR only** |
| *(none)* | `pay_master.pay_calendar` | **PR only** |
| `comp_core.holiday_calendar` | *(none)* | **TR only** |
| `comp_core.country_config` | *(via `common.talent_market`)* | **Partial overlap** |

> **Phát hiện #4**: TR có `holiday_calendar` + `country_config` (working hours/days settings). PR có `pay_frequency` + `pay_calendar`. Cả hai đều cần biết lịch nghỉ và ngày làm việc chuẩn — nhưng lưu ở chỗ khác nhau. **Nguy cơ desync**: nếu TR update holiday mà PR không biết.

---

## 4. Overlap Analysis — Calculation Logic

### 4.1 TR Calculation Rules System

TR DBML V5 (thêm 25Nov2025) bổ sung 4 tables cho calculation:

| Table | Records | Chức năng |
|-------|---------|-----------|
| `comp_core.calculation_rule_def` | VN_PIT_2025, VN_SI_2025, VN_OT_MULT... | Định nghĩa rules |
| `comp_core.component_calculation_rule` | Component → Rule mapping | Element-level rules |
| `comp_core.basis_calculation_rule` | Basis → Rule mapping | Execution order (1→6) |
| `comp_core.tax_calculation_cache` | Pre-calculated values | Performance cache |

**Execution Order trong TR**:

```
basis_calculation_rule.execution_order:
  1 = Proration rules
  2 = Component calculations (formulas, OT)
  3 = Gross salary sum
  4 = Social insurance deductions
  5 = Tax calculations (PIT)
  6 = Net salary calculation
```

### 4.2 PR Formula Engine System

PR DBML V3 có:

| Table | Chức năng |
|-------|-----------|
| `pay_master.pay_element` | Element + formula_json |
| `pay_master.pay_formula` | Shared formula repository |
| `pay_master.statutory_rule` | Vietnamese statutory rules |
| `pay_master.validation_rule` | Pre-run validation |

PR Overview docs mô tả engine:

```
Drools 8 Rule Units:
  VN_PrePayroll_Unit      → validate
  VN_GrossCalculation_Unit → base + allowances + OT
  VN_InsuranceCalc_Unit    → BHXH/BHYT/BHTN
  VN_TaxCalculation_Unit   → PIT progressive 7-bracket
  VN_NetCalculation_Unit   → net = gross - deductions
  VN_PostProcessing_Unit   → rounding, retroactive
```

### 4.3 Overlap Matrix

| Capability | TR owns (DBML V5) | PR owns (DBML V3 + Overview) | Conflict? |
|-----------|:-:|:-:|:-:|
| Progressive Tax Brackets | ✅ `calculation_rule_def` VN_PIT_2025 | ✅ `statutory_rule` + Drools VN_TaxCalculation_Unit | **YES** |
| SI Rates (BHXH/BHYT/BHTN) | ✅ `calculation_rule_def` VN_SI_2025 | ✅ `statutory_rule` + Drools VN_InsuranceCalc_Unit | **YES** |
| OT Multipliers | ✅ `calculation_rule_def` VN_OT_MULT_2019 | ✅ Drools VN_GrossCalculation_Unit (overtime rules) | **YES** |
| Proration Logic | ✅ `proration_method` per component + rule | ✅ `proRata()` built-in function in DSL | **YES** |
| Gross-to-Net Pipeline | ✅ `basis_calculation_rule` execution_order 1→6 | ✅ Drools Rule Units + 5-stage Production Run | **YES** |
| Component/Element Config | ✅ `pay_component_def` (rich) | ✅ `pay_element` (lean but runtime-ready) | **YES** |
| Tax Exempt Threshold | ✅ `tax_exempt_threshold` field | ❌ Not in schema | **NO (TR only)** |
| GL Mapping | ❌ Not in TR schema | ✅ `pay_master.gl_mapping` | **NO (PR only)** |
| Bank Payment | ❌ Not in TR | ✅ `pay_bank.*` tables | **NO (PR only)** |
| Grade & Pay Range | ✅ Full grade system | ❌ Not in PR | **NO (TR only)** |
| Compensation Cycle | ✅ Full merit/bonus cycle | ❌ Not in PR | **NO (TR only)** |

> **Phát hiện #5 (Critical)**: 6 out of 11 capabilities overlap giữa TR và PR. Đây không phải duplicate code — nhưng là **duplicate intent**: cả TR và PR đều muốn own calculation logic cho cùng một bài toán (gross → tax → SI → net).

---

## 5. Gap Analysis

### 5.1 TR có nhưng PR không có

| Feature | TR Entity/Field | Impact on PR |
|---------|-----------------|-------------|
| Tax exempt threshold | `pay_component_def.tax_exempt_threshold` | PR formulas hardcode — cần parameterize |
| SI calculation basis | `pay_component_def.si_calculation_basis` | PR infers from statutory_rule — less flexible |
| Proration method per component | `pay_component_def.proration_method` | PR dùng built-in `proRata()` — generic |
| Calculation method | `pay_component_def.calculation_method` | FIXED/FORMULA/PERCENTAGE/HOURLY — PR only has formula |
| Country config | `comp_core.country_config` | Standard working hours/days — PR hardcode? |
| Holiday calendar (with OT multiplier) | `comp_core.holiday_calendar` | PR needs this for OT calc |
| Tax calculation cache | `comp_core.tax_calculation_cache` | Performance optimization — PR doesn't have |

### 5.2 PR có nhưng TR không có

| Feature | PR Entity/Field | Impact on TR |
|---------|-----------------|-------------|
| Statutory rule entity | `pay_master.statutory_rule` | TR uses generic `calculation_rule_def` — semantically different |
| GL mapping | `pay_master.gl_mapping` | Accounting concern — correctly in PR |
| Bank accounts & payments | `pay_bank.*` | Payment processing — correctly in PR |
| Payslip template | `pay_master.payslip_template` | Output formatting — correctly in PR |
| Bank template | `bank_template` | Bank file format — correctly in PR |
| Tax report template | `tax_report_template` | Filing template — correctly in PR |
| Validation rules | `pay_master.validation_rule` | Pre-run checks — correctly in PR |
| Costing rules | `pay_master.costing_rule` | Cost allocation — correctly in PR |
| Manual adjustments | `pay_run.manual_adjust` | Runtime adjustments — correctly in PR |
| Retro delta | `pay_run.retro_delta` | Retroactive — correctly in PR |
| Calc log | `pay_run.calc_log` | Calculation trace — correctly in PR |
| Import job | `import_job` | Data import — correctly in PR |

### 5.3 Integration Entities

| Entity | Module | Purpose |
|--------|:------:|---------|
| `tr_taxable.taxable_item` | TR | Bridge equity/perk events → PR |
| `pay_master.pay_benefit_link` | PR | Link element ↔ benefit policy |
| `pay_gateway.iface_def` | PR | Integration interface config |

---

## 6. Data Flow Diagram — TR → PR tại Runtime

```
TR Module (Source of Truth for Compensation Config)
│
├── salary_basis + salary_basis_component_map
│   → Defines WHAT components for WHICH frequency/country
│   → Maps to PR.pay_profile concept
│
├── pay_component_def (with tax_treatment, proration, SI flags)
│   → Component metadata
│   → Needs to sync to PR.pay_element (or PR reads from TR)
│
├── calculation_rule_def + basis_calculation_rule
│   → Defines HOW to calculate (tax brackets, SI rates, OT multipliers)
│   → Overlap with PR.statutory_rule + Drools rules
│
├── employee_comp_snapshot (ACTIVE)
│   → Current salary for each employee by component
│   → PR needs this as input: BASE_SALARY = 30,000,000
│
├── bonus_allocation (APPROVED)
│   → Bonus amount per employee
│   → Creates PayElement input in PR
│
├── taxable_item (PENDING)
│   → RSU vest, perk redemption
│   → PR adds to taxable income
│
├── enrollment.premium_employee  
│   → Benefit premium deduction
│   → PR creates DEDUCTION element
│
└── comp_adjustment (APPROVED, effective this period)
    → Salary change
    → Updates BASE_SALARY in PR, may trigger retro
```

---

## 7. Recommended Boundary

### Nguyên tắc: **Single Source of Truth**

| Concern | Owner | Reason |
|---------|:-----:|--------|
| **Compensation Configuration** (what to pay) | **TR** | TR manages salary basis, components, grades, pay ranges |
| **Calculation Execution** (how to calculate) | **PR** | PR has formula engine, Drools, working memory |
| **Statutory Compliance** (legal rules) | **PR** | PR owns country-specific tax/SI logic — more appropriate for headless |
| **Tax/SI Rate Tables** | **Shared** | TR defines rates (source), PR uses for execution |
| **Proration Logic** | **PR** | Proration is calculation concern — should be in engine |
| **Employee Comp Data** (how much) | **TR** | TR manages snapshots, adjustments, history |
| **Payroll Execution** (when, batch) | **PR** | PR manages calendar, periods, runs |
| **Accounting** (GL, bank, reports) | **PR** | Downstream output — correctly in PR |
| **Audit** | **Both** | Each module audits its own domain |

### Kết quả: TR là **Config Provider**, PR là **Execution Engine**

```
TR (Config Provider)                PR (Execution Engine)
─────────────────                   ──────────────────────
"WHAT to pay"                       "HOW to calculate"
                                    "WHEN to run"
                                    "WHERE to send"

Components + Tax rules              Formula Engine + Drools
Employee salary amounts     ──API──▶ PayElement input values
Bonus allocations           ──API──▶ BONUS element in run
Taxable items               ──API──▶ TAXABLE_INCOME addition
Benefit premiums            ──API──▶ DEDUCTION element
                                    ↓
                            Gross → Tax → SI → Net
                                    ↓
                            Payslip, Bank, GL, Tax Reports
```

---

## 8. Action Items

| # | Action | Priority | Effort |
|---|--------|:--------:|:------:|
| 1 | Quyết định xóa/deprecate `calculation_rule_def` khỏi TR, hoặc re-scope thành "config-only" | **P0** | Discussion |
| 2 | Định nghĩa formal Component → Element mapping (API contract) | **P0** | 1 sprint |
| 3 | Thống nhất taxonomy: hoặc TR adapt PR's 5 types, hoặc PR adapt TR's 6 types | **P0** | Discussion |
| 4 | Country config + Holiday calendar: quyết định single source (CO or TR or PR) | **P1** | Discussion |
| 5 | API contract cho TR → PR data flow (OpenAPI spec) | **P1** | 2 sprints |
| 6 | Loại bỏ tax_calculation_cache khỏi TR (nên nằm trong PR engine) | **P2** | 1 sprint |

---

*← [01 Headless Payroll Concepts](./01-headless-payroll-concepts.md) · [03 Calculation Responsibility Split →](./03-calculation-responsibility-split.md)*
