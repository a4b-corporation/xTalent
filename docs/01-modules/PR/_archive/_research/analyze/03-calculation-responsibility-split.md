# TR Calculation Rules vs PR Formula Engine — Responsibility Split

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-06  
**Đối tượng**: Solution Architect, Tech Lead  
**Thời gian đọc**: ~25 phút

---

## 1. Vấn đề cốt lõi

Hiện tại cả TR và PR đều **claim ownership** over the same calculation logic:

| Module | Mechanism | Scope |
|--------|-----------|-------|
| **TR** | `calculation_rule_def` + `basis_calculation_rule` (execution_order 1→6) | Tax brackets, SI rates, OT multipliers, proration, gross→net pipeline |
| **PR** | Drools 8 Rule Units + `pay_formula` + `statutory_rule` + Business DSL | Tax rules, SI rules, OT, proration, gross→net |

**Câu hỏi quyết định**: Ai own **calculation logic** — phần "brain" của payroll?

---

## 2. Hiện trạng chi tiết

### 2.1 TR Calculation Rules (DBML V5)

**Thêm ngày 25Nov2025** — 4 tables mới trong `comp_core` schema.

#### `calculation_rule_def` — Rule Master

```sql
-- Ví dụ VN_PIT_2025
{
  code: "VN_PIT_2025",
  rule_category: "TAX",
  rule_type: "PROGRESSIVE",
  country_code: "VN",
  formula_json: {
    brackets: [
      { from: 0, to: 5_000_000, rate: 0.05 },
      { from: 5_000_001, to: 10_000_000, rate: 0.10 },
      ...
      { from: 80_000_001, to: null, rate: 0.35 }
    ],
    personal_deduction: 11_000_000,
    dependent_deduction: 4_400_000
  },
  legal_reference: "Article 22, PIT Law 04/2007/QH12"
}
```

**Categories & Types**:

| Rule Category | Examples | Rule Type |
|--------------|---------|-----------|
| TAX | VN_PIT_2025, SG_TAX_2025 | PROGRESSIVE |
| SOCIAL_INSURANCE | VN_SI_2025, SG_CPF_2025 | RATE_TABLE |
| PRORATION | VN_PRORATION_CALENDAR | FORMULA |
| OVERTIME | VN_OT_MULT_2019 | LOOKUP_TABLE |
| ROUNDING | VN_ROUNDING_50 | FORMULA |
| FOREX | USD_VND_SPOT | LOOKUP_TABLE |
| ANNUALIZATION | SG_ANNUALIZED_BONUS | FORMULA |

#### `basis_calculation_rule` — Execution Pipeline

```
LUONG_THANG_VN salary_basis:
  execution_order 1: VN_PRORATION → proration rules
  execution_order 2: Component calculations (formulas, OT)
  execution_order 3: Gross salary sum
  execution_order 4: VN_SI_2025 → social insurance deductions
  execution_order 5: VN_PIT_2025 → tax calculations
  execution_order 6: Net salary calculation
```

> Đây là **complete gross-to-net pipeline** — tất cả steps cần để tính lương.

### 2.2 PR Formula Engine (Overview + DBML V3)

**Kiến trúc 3 tầng** (mô tả trong overview docs):

```
Layer 3:  Business DSL Layer    ← HR professionals viết công thức
Layer 2:  Drools 8 Engine       ← Rule evaluation + chaining
Layer 1:  Execution Core        ← Java runtime, security sandbox
```

**Drools Rule Units cho Vietnam**:

```java
// VN_GrossCalculation_Unit
unit VN_GrossCalculation_Unit;
rule "Calculate Overtime"
  when $e : /employees[overtimeHours > 0]
  then $e.setOvertimePay($e.overtimeHours * $e.hourlyRate * 1.5);
end

// VN_InsuranceCalc_Unit  
unit VN_InsuranceCalc_Unit;
rule "BHXH Employee"
  when $e : /employees[grossSalary > 0]
  then $e.setBhxh(Math.min($e.base, 36_000_000) * 0.08);
end

// VN_TaxCalculation_Unit
unit VN_TaxCalculation_Unit;
rule "PIT Bracket Calculation"
  // Progressive 7-bracket logic
end
```

**PR DBML entities**:

| Table | Purpose |
|-------|---------|
| `pay_master.pay_formula` | Formula repository (code, script, version) |
| `pay_master.statutory_rule` | Legal rules (formula_json, valid_from/to, market_id) |
| `pay_master.pay_element` | Element + formula_json link |

---

## 3. Phân tích 3 Options

### Option A: TR Defines Rules, PR Only Executes

```
TR Module                              PR Module
─────────                              ─────────
salary_basis ────────────────────────▶ PayProfile config
pay_component_def ───────────────────▶ PayElement registry
calculation_rule_def ────────────────▶ Rule parameters
basis_calculation_rule ──────────────▶ Execution order
component_calculation_rule ──────────▶ Element-level rules
                                       │
                                       ▼
                                  PR Engine reads TR config
                                  and executes calculations
                                  using Drools + formulas
```

**PR Engine trở thành "dumb executor"** — nhận config từ TR, apply formulas, trả kết quả.

| Criterion | Assessment |
|-----------|-----------|
| **Separation of Concerns** | ⚠️ Blurry — TR defines "how to calculate", but that's engine concern |
| **Independence** | ❌ Poor — PR depends heavily on TR for all configs |
| **Headless Ready** | ❌ No — PR cannot function without TR's calculation_rule_def |
| **Multi-country** | ✅ Good — TR defines rules per country_code |
| **HR Flexibility** | ✅ Excellent — TR owns component metadata (tax_treatment, proration_method) |
| **Data Consistency** | ✅ Good — single source from TR |
| **Complexity** | ⚠️ High — two systems must stay perfectly in sync |

### Option B: PR Owns All Calculation (Headless/PaaS Style)

```
TR Module                              PR Module
─────────                              ─────────
salary_basis ─────(simplified)───────▶ PR reads salary amounts only
pay_component_def ──(no calc fields)─▶ PR defines own elements + calc logic
                                       │
    [TR removes:]                      ▼
    - calculation_rule_def          PR owns:
    - basis_calculation_rule        - StatutoryRule (tax brackets, SI rates)
    - component_calculation_rule    - PayFormula (all formulas)
    - tax_calculation_cache         - PayElement (all element config)
                                    - Drools Engine (execution)
                                    - Calculation tracing
```

**PR trở thành "full payroll engine"** — TR chỉ gửi salary amounts.

| Criterion | Assessment |
|-----------|-----------|
| **Separation of Concerns** | ✅ Clear — TR = "what to pay", PR = "how to calculate" |
| **Independence** | ✅ Excellent — PR runs standalone with minimal input |
| **Headless Ready** | ✅ Yes — PR has everything needed for standalone deployment |
| **Multi-country** | ⚠️ Needs work — PR's statutory_rule needs upgrading to match TR's country_config detail |
| **HR Flexibility** | ⚠️ Moderate — HR must configure in PR, not TR |
| **Data Consistency** | ⚠️ Separate configs in TR and PR — potentially inconsistent |
| **Complexity** | ✅ Low — single system owns calculation |

### Option C: Shared Calculation Module (Middleware)

```
TR Module           Calc Module            PR Module
─────────           ───────────            ─────────
pay_component_def─▶ calculation_rule_def   PR Engine reads from Calc
salary_basis ────▶ basis_calc_rule         Drools configured by Calc
                    component_calc_rule
                    country_config
                    holiday_calendar

    (extracted from TR, shared by TR and PR)
```

**Calculation rules extracted into a third module** — shared by TR (for previews/estimation) and PR (for execution).

| Criterion | Assessment |
|-----------|-----------|
| **Separation of Concerns** | ✅ Excellent — clear three-way split |
| **Independence** | ⚠️ Moderate — both TR and PR depend on Calc module |
| **Headless Ready** | ⚠️ Partially — PR + Calc module would be deployable together |
| **Multi-country** | ✅ Good — Calc module centralizes country-specific rules |
| **HR Flexibility** | ✅ Good — single config point for HR |
| **Data Consistency** | ✅ Excellent — single source of truth |
| **Complexity** | ❌ High — 3 modules instead of 2, more integration points |

---

## 4. Trade-off Matrix

| Criterion | Weight | Option A (TR defines) | Option B (PR owns) | Option C (Shared) |
|-----------|:------:|:-----:|:-----:|:-----:|
| Separation of Concerns | 25% | 2/5 | 5/5 | 4/5 |
| PR Independence | 25% | 1/5 | 5/5 | 3/5 |
| Implementation Effort | 15% | 4/5 (least change) | 3/5 | 2/5 |
| Data Consistency | 15% | 4/5 | 3/5 | 5/5 |
| HR Flexibility | 10% | 5/5 | 3/5 | 4/5 |
| Future Headless | 10% | 1/5 | 5/5 | 3/5 |
| **Weighted Score** | | **2.55** | **4.20** | **3.35** |

---

## 5. Recommendation: Option B với Bridge Pattern

### Đề xuất: **PR owns all calculation logic**, nhưng TR cung cấp **Config-as-Data** thông qua API

```
┌──────────────────────────────────────────┐
│ TR Module (Compensation Configuration)    │
│                                           │
│ salary_basis + components → "WHAT to pay" │
│ employee_comp_snapshot → salary amounts   │
│ bonus_allocation → bonus amounts          │
│ taxable_item → equity/perk events         │
│                                           │
│ [DEPRECATED/RE-SCOPED]:                   │
│ calculation_rule_def → moved to PR        │
│ basis_calculation_rule → removed          │
│ component_calculation_rule → removed      │
│ tax_calculation_cache → moved to PR       │
└──────────────┬───────────────────────────┘
               │ Compensation Data API
               │ (amounts, components, events)
               ▼
┌──────────────────────────────────────────┐
│ PR Module (Payroll Engine)                │
│                                           │
│ OWNS:                                     │
│ ├── PayElement + classification + config  │
│ ├── PayFormula (Drools + Business DSL)    │
│ ├── StatutoryRule (tax, SI, OT)           │  
│ ├── Calculation Pipeline (gross→net)      │
│ ├── Country Config (working days/hours)   │
│ ├── Holiday Calendar                      │
│ ├── Tax Rate Tables                       │
│ ├── Proration Engine                      │
│ └── Calculation Cache                     │
│                                           │
│ CONSUMES (via API):                       │
│ ├── Employee salary amounts (from TR)     │
│ ├── Bonus allocations (from TR)           │
│ ├── Taxable items (from TR)               │
│ ├── Benefit premiums (from TR)            │
│ ├── Attendance data (from TA)             │
│ └── Employee/Assignment data (from CO)    │
└──────────────────────────────────────────┘
```

### Migration từ hiện trạng

#### Phase 1: Re-scope TR Calculation Tables (Discussion)

```diff
  comp_core.calculation_rule_def:
-   Stores full formula_json with tax brackets, SI rates
+   Re-scoped: stores "compensation policy config" only
+   Example: component's tax_treatment, proration preference
+   NOT: actual tax brackets or calculation logic

  comp_core.basis_calculation_rule:
-   Defines execution_order for gross→net
+   DEPRECATED: PR owns execution pipeline

  comp_core.component_calculation_rule:
-   Links components to calculation rules
+   RE-SCOPED: links components to "how component behaves"
+   (taxable? prorated? which method?) — config, not calc

  comp_core.tax_calculation_cache:
-   Pre-calculated tax/SI values
+   MOVED to PR: calculation caching belongs to engine
```

#### Phase 2: Enrich PR Schema

PR `pay_master` cần bổ sung:

| New Table/Field | Source (from TR) | Purpose |
|----------------|-----------------|---------|
| `pay_master.country_config` | TR `comp_core.country_config` | Standard working hours/days |
| `pay_master.holiday_calendar` | TR `comp_core.holiday_calendar` | OT multipliers, proration exclusions |
| `pay_element.tax_treatment` | TR `pay_component_def.tax_treatment` | FULLY_TAXABLE / EXEMPT / PARTIAL |
| `pay_element.proration_method` | TR `pay_component_def.proration_method` | CALENDAR / WORKING / NONE |
| `pay_element.si_basis` | TR `pay_component_def.si_calculation_basis` | FULL / CAPPED / EXCLUDED |
| `pay_element.tax_exempt_cap` | TR `pay_component_def.tax_exempt_threshold` | e.g., 730K for lunch |
| `pay_master.calc_cache` | TR `comp_core.tax_calculation_cache` | Performance optimization |

#### Phase 3: Define TR → PR API Contract

```yaml
# /api/v1/payroll/compensation-input
POST /compensation-snapshot
Body:
  employee_id: uuid
  period: { start: date, end: date }
  components:
    - code: "BASE_SALARY"
      amount: 30000000
      currency: "VND"
      frequency: "MONTHLY"
    - code: "LUNCH_ALLOWANCE"
      amount: 730000
      is_prorated: true
  taxable_items:
    - source: "RSU_VEST"
      amount: 50000000
  benefit_deductions:
    - code: "HEALTH_PREMIUM"
      amount: 500000
```

---

## 6. Rủi ro và Mitigation

| Risk | Impact | Mitigation |
|------|:------:|-----------|
| TR team đã invest vào calculation_rule_def | High | Re-scope, don't delete — turn into "component behavior config" |
| PR statutory_rule thiếu rich metadata | Medium | Enrich with fields from TR's pay_component_def |
| Double-update khi tax law changes | High | PR is single source for tax tables — clear ownership |
| TR preview/estimation cần calc logic | Medium | TR calls PR API for estimation (Preview mode) |
| Migration effort | Medium | Phased approach — start with re-scoping, not deletion |

---

## 7. Tóm tắt Quyết định

| Quyết định | Nội dung |
|-----------|---------|
| **Calculation Ownership** | PR owns all calculation logic (tax, SI, OT, proration, gross→net) |
| **TR Role** | Config Provider — defines WHAT (components, amounts), not HOW (formulas, pipelines) |
| **TR calc tables** | Re-scope to "component behavior config", deprecate execution pipeline |
| **Country/Holiday config** | Move to PR (or shared module like CO) |
| **API Contract** | TR sends compensation snapshot → PR processes |
| **Timeline** | Phase 1 (discussion) → Phase 2 (enrich PR) → Phase 3 (API contract) |

---

*← [02 TR-PR Boundary Analysis](./02-tr-pr-boundary-analysis.md) · [04 Payroll API Contract Design →](./04-payroll-api-contract-design.md)*
