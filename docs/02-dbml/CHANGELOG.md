# xTalent Database Design – Changelog


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