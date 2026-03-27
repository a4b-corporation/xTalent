# xTalent Database Design – Changelog


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