# xTalent Database Design – Changelog



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