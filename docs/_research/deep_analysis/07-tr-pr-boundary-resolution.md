# TR-PR Boundary Resolution — Final Recommendations

**Scope**: Resolve calculation ownership overlap between Total Rewards and Payroll  
**Based on**: Doc 02 (Boundary Analysis), Doc 03 (Calc Split), Doc 05 (Assessment)  
**Assessed**: 2026-03-16

---

## 1. Decision: PR Owns Calculation

**Option B selected** (weighted score 4.20/5 — highest):

| Concern | Owner | Rationale |
|---------|:-----:|-----------|
| **Component definitions** (what to pay) | **TR** | TR manages salary basis, components, grades, pay ranges |
| **Employee salary amounts** (how much) | **Core** | `compensation.basis` stores operational salary facts |
| **Calculation execution** (how to calculate) | **PR** | PR has Drools engine, formula DSL, 5-stage pipeline |
| **Statutory compliance** (legal rules) | **PR** | Tax brackets, SI rates, OT multipliers = engine concern |
| **Proration logic** | **PR** | Proration is calculation concern |
| **Payroll execution** (when, batch) | **PR** | Calendar, periods, runs |
| **Accounting output** (GL, bank) | **PR** | Downstream processing |
| **Audit** | **Both** | Each module audits its own domain |

---

## 2. TR Tables — Re-scope Actions

### 2.1 `comp_core.calculation_rule_def` → RE-SCOPE

**From**: Full calculation rules (tax brackets, SI rate tables, OT multipliers)  
**To**: Component behavior configuration only

```diff
  comp_core.calculation_rule_def:
-   rule_category: TAX | SOCIAL_INSURANCE | PRORATION | OVERTIME | ROUNDING | FOREX
+   rule_category: TAX_BEHAVIOR | SI_BEHAVIOR | PRORATION_BEHAVIOR | OT_BEHAVIOR
-   formula_json: { brackets: [...], rates: [...] }  // actual calculation data
+   behavior_json: { tax_treatment: "FULLY_TAXABLE", proration_method: "WORKING_DAYS" }
    
    Note: 'RE-SCOPED: No longer stores actual tax/SI calculation data.
          Stores component behavior preferences only.
          Actual calculation logic → PR.statutory_rule + PR.pay_formula'
```

**What stays in TR**: Behavior preferences (is this component taxable? how to prorate?)  
**What moves to PR**: Actual tax brackets, SI rates, OT multiplier lookup tables

### 2.2 `comp_core.basis_calculation_rule` → DEPRECATE

```diff
- comp_core.basis_calculation_rule:
-   execution_order: 1→6 (proration → gross → SI → tax → net)
+ // DEPRECATED: PR engine owns execution pipeline.
+ // Pipeline configuration → PR.pay_profile execution rules
```

**Reason**: Execution pipeline is engine architecture — not compensation configuration.

### 2.3 `comp_core.component_calculation_rule` → RE-SCOPE

```diff
  comp_core.component_calculation_rule:
-   rule_scope: COMPONENT_CALC | TAX | PRORATION | VALIDATION | SI_CALCULATION
+   rule_scope: TAX_BEHAVIOR | SI_BEHAVIOR | PRORATION_BEHAVIOR
    // Maps component to its behavior preferences, NOT to actual calculations
```

### 2.4 `comp_core.tax_calculation_cache` → MOVE TO PR

```diff
- comp_core.tax_calculation_cache  // in TR schema
+ pay_master.calculation_cache     // moved to PR schema
```

**Reason**: Computation caching is engine optimization — belongs with the engine.

---

## 3. Component → Element Taxonomy Alignment

### 3.1 Current Mismatch

| TR `pay_component_def.component_type` | PR `pay_element.classification` |
|---------------------------------------|--------------------------------|
| BASE | EARNING |
| ALLOWANCE | EARNING |
| BONUS | EARNING |
| OVERTIME | EARNING |
| DEDUCTION | DEDUCTION |
| EQUITY | *(via taxable bridge)* |
| *(none)* | TAX |

→ 6 types flatten to 3 when crossing to PR. **Information loss**.

### 3.2 Proposed Alignment

**PR upgrades classifications** to match TR + add PR-specific:

```
pay_element.classification (upgraded):
  ├── EARNING
  │    ├── sub_type: BASE         (← TR BASE)
  │    ├── sub_type: ALLOWANCE    (← TR ALLOWANCE)
  │    ├── sub_type: BONUS        (← TR BONUS)  
  │    └── sub_type: OVERTIME     (← TR OVERTIME)
  ├── DEDUCTION
  │    ├── sub_type: EMPLOYEE     (← TR DEDUCTION)
  │    └── sub_type: EMPLOYER     (NEW — BHXH employer portion)
  ├── TAX                         (PR-specific)
  └── INFORMATIONAL               (NEW — display only)
```

**Implementation**: Add `sub_type` field to `pay_element`:
```dbml
pay_element:
  classification   varchar(20)  // EARNING, DEDUCTION, TAX, INFORMATIONAL
  sub_type         varchar(30)  // BASE, ALLOWANCE, BONUS, OVERTIME, EMPLOYEE, EMPLOYER
```

### 3.3 Mapping Contract

```yaml
# TR → PR Element Mapping
component_type_mapping:
  TR_BASE:       { classification: EARNING, sub_type: BASE }
  TR_ALLOWANCE:  { classification: EARNING, sub_type: ALLOWANCE }
  TR_BONUS:      { classification: EARNING, sub_type: BONUS }
  TR_OVERTIME:   { classification: EARNING, sub_type: OVERTIME }
  TR_DEDUCTION:  { classification: DEDUCTION, sub_type: EMPLOYEE }
  TR_EQUITY:     { via: taxable_bridge, classification: EARNING, sub_type: BONUS }
```

---

## 4. Data Flow Contract: TR → PR

### 4.1 Compensation Snapshot API

```yaml
POST /api/v1/payroll/input/compensation-snapshot
Authorization: Bearer {service_token}
Content-Type: application/json

{
  "source": "TR",
  "period": {
    "start_date": "2026-03-01",
    "end_date": "2026-03-31"
  },
  "employees": [
    {
      "employee_id": "uuid",
      "effective_date": "2026-03-01",
      "salary_basis_code": "MONTHLY_VN",
      "components": [
        {
          "code": "BASE_SALARY",
          "amount": 30000000,
          "currency": "VND",
          "frequency": "MONTHLY",
          "proration_method": "CALENDAR_DAYS",
          "tax_treatment": "FULLY_TAXABLE",
          "is_subject_to_si": true
        },
        {
          "code": "LUNCH_ALLOWANCE",
          "amount": 730000,
          "currency": "VND",
          "frequency": "MONTHLY",
          "proration_method": "WORKING_DAYS",
          "tax_treatment": "PARTIALLY_EXEMPT",
          "tax_exempt_cap": 730000
        }
      ],
      "bonus_items": [
        {
          "code": "PERFORMANCE_BONUS",
          "amount": 10000000,
          "bonus_plan_id": "uuid",
          "tax_treatment": "FULLY_TAXABLE"
        }
      ],
      "taxable_items": [
        {
          "source": "EQUITY",
          "amount": 50000000,
          "description": "RSU vest - 100 shares"
        }
      ],
      "benefit_deductions": [
        {
          "code": "HEALTH_PREMIUM",
          "amount": 500000,
          "enrollment_id": "uuid"
        }
      ]
    }
  ]
}
```

### 4.2 PR DryRun/Preview API (for TR Offer/Statement)

```yaml
POST /api/v1/payroll/preview
Authorization: Bearer {service_token}

{
  "mode": "DRY_RUN",
  "country_code": "VN",
  "components": [
    { "code": "BASE_SALARY", "amount": 30000000 },
    { "code": "LUNCH_ALLOWANCE", "amount": 730000 }
  ],
  "dependents_count": 2,
  "period": { "start": "2026-03-01", "end": "2026-03-31" }
}

Response:
{
  "status": "SUCCESS",
  "gross_salary": 30730000,
  "deductions": {
    "si_employee": { "bhxh": 2400000, "bhyt": 450000, "bhtn": 300000, "total": 3150000 },
    "pit": 3600000,
    "total_deductions": 6750000
  },
  "employer_costs": {
    "bhxh": 4200000, "bhyt": 900000, "bhtn": 300000, "bhtnld": 150000,
    "total": 5550000
  },
  "net_salary": 23980000,
  "total_cost_to_company": 36280000,
  "calculation_trace": [...]
}
```

---

## 5. Migration Roadmap

| Phase | Action | Effort | Owner |
|:-----:|--------|:------:|:-----:|
| 1 | Discussion: Confirm Option B (PR owns calc) | 1 day | SA + PO |
| 2 | Re-scope TR `calculation_rule_def` → behavior config | 1 sprint | TR team |
| 3 | Enrich PR `pay_element` (5 fields) + taxonomy upgrade | 1 sprint | PR team |
| 4 | Define OpenAPI contract (TR→PR data flow) | 1 sprint | Both teams |
| 5 | Implement compensation snapshot API | 1 sprint | PR team |
| 6 | Implement DryRun/Preview API | 1 sprint | PR team |
| 7 | Deprecate TR execution pipeline tables | 0.5 sprint | TR team |

**Total**: ~5-6 sprints (phased, some parallelizable)

---

## 6. Final Boundary Diagram

```
┌──────────────────────────────────────────────────────────┐
│                  CORE MODULE                              │
│  geo.country → common.country_config                     │
│  person.worker → employment.employee → compensation.basis │
│  eligibility.eligibility_profile (cross-module)          │
└─────────┬────────────┬──────────────────┬────────────────┘
          │            │                  │
          ▼            ▼                  ▼
┌─────────────┐ ┌──────────────┐ ┌───────────────┐ ┌──────────┐
│ TA MODULE   │ │ TR MODULE    │ │ PR MODULE     │ │ Other    │
│             │ │              │ │               │ │ modules  │
│ Schedules   │ │ WHAT to pay: │ │ HOW to calc:  │ │          │
│ Attendance  │ │ Components   │ │ Drools engine │ │          │
│ Absence     │ │ Grades       │ │ Formulas      │ │          │
│ Timesheets  │ │ Pay ranges   │ │ Statutory     │ │          │
│             │ │ Comp cycles  │ │ Tax/SI rules  │ │          │
│ Output:     │ │ Offers       │ │               │ │          │
│ Hours data  │ │ Benefits     │ │ WHEN to run:  │ │          │
│ OT hours    │ │ Recognition  │ │ Calendar      │ │          │
│             │ │              │ │ Pay groups    │ │          │
│     ──API──▶│ │      ──API──▶│ │               │ │          │
│ attendance  │ │ comp snapshot│ │ WHERE output: │ │          │
│ OT data     │ │ bonus alloc  │ │ Bank payment  │ │          │
│             │ │ taxable item │ │ GL entries    │ │          │
│             │ │ benefit prem │ │ Tax reports   │ │          │
│             │ │              │ │ Payslips      │ │          │
└─────────────┘ └──────────────┘ └───────────────┘ └──────────┘
```

---

*← [06 Country Config Unification](./06-country-config-unification.md) · [08 Cross-Module Data Flow →](./08-cross-module-data-flow.md)*
