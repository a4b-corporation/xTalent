# Total Rewards Module (TR) — Deep Analysis

**File**: `4.TotalReward.V5.dbml` (1,445 lines)  
**Last updated**: Nov 2025  
**Assessed**: 2026-03-16

---

## 1. Schema Inventory

| # | Schema | Tables | Purpose |
|:-:|--------|:------:|---------|
| 1 | `comp_core` | 15 | Compensation: salary_basis, pay_component, grade, pay_range, employee_comp_snapshot, calculation_rules, country_config, holiday_calendar |
| 2 | `comp_incentive` | 6 | Incentives: comp_plan, comp_cycle, comp_adjustment, budget, bonus_plan, bonus_allocation |
| 3 | `benefit` | 8 | Benefits: plan, plan_option, eligibility_profile, plan_eligibility, enrollment_period, enrollment, premium, premium_employee |
| 4 | `recognition` | 5 | Recognition: event_type, perk_catalog, point_account, recognition_event, reward_point_txn, perk_redeem |
| 5 | `tr_offer` | 5 | Offer management: offer_template, offer_template_event, offer_package, offer_event, offer_acceptance |
| 6 | `tr_taxable` | 1 | Taxable bridge: taxable_item |
| 7 | `tr_statement` | 4 | Statement: statement_config, statement_section, statement_job, statement_line |
| 8 | `tr_audit` | 1 | Audit: audit_log |
| 9 | `comp_core` (calc) | 4 | Calculation rules (added Nov 25): calculation_rule_def, component_calculation_rule, basis_calculation_rule, tax_calculation_cache |

**Tổng**: ~49 tables, 8 schema groups, 1,445 lines

---

## 2. Strengths (Điểm mạnh)

### 2.1 Domain Coverage — 5/5

TR module covers **5 pillars** of Total Rewards:
1. **Fixed Compensation** — salary basis, components, grade, pay range
2. **Variable Compensation** — bonus plans, equity grants, compensation cycles
3. **Benefits** — plan lifecycle, enrollment, premiums
4. **Recognition** — points economy, peer recognition, perk catalog
5. **Offer Management** — templates, packages, acceptance tracking

→ Toàn diện nhất trong 4 modules.

### 2.2 SCD-2 + Versioning — 5/5

Multiple versioning patterns applied correctly:
- `comp_core.grade_v`: `version_number` + `previous_version_id` + `is_current_version`
- `comp_core.calculation_rule_def`: same pattern
- `comp_core.employee_comp_snapshot`: `effective_start/end` date ranges
- `tr_offer.offer_template`: `version_no` field

### 2.3 Audit Trail — 5/5

`tr_audit.audit_log` is exemplary:
- `event_type` — categorized events
- `entity_type` + `entity_id` — polymorphic reference
- `action` — CRUD + APPROVE/REJECT/VIEW
- `old_values` + `new_values` — before/after snapshots
- `change_summary` — human-readable description
- `reason` — business justification
- `user_id`, `ip_address`, `user_agent` — full security context

→ **Best practice audit table** — recommended as pattern for other modules.

### 2.4 Compensation Component Design — 4.5/5

`comp_core.pay_component_def` has rich metadata:
- `calculation_method`: FIXED, FORMULA, PERCENTAGE, HOURLY
- `tax_treatment`: FULLY_TAXABLE, TAX_EXEMPT, PARTIALLY_EXEMPT
- `tax_exempt_threshold`: numeric limit (e.g., 730K VND for lunch)
- `proration_method`: CALENDAR_DAYS, WORKING_DAYS, NONE
- `is_subject_to_si` + `si_calculation_basis`: FULL_AMOUNT, CAPPED, EXCLUDED

→ Richer than PR's `pay_element` which only has `classification` (3 types). This metadata is essential for payroll calculation.

### 2.5 Taxable Bridge — 5/5

`tr_taxable.taxable_item` bridges non-payroll compensation to payroll:
```
BENEFIT → taxable_item → PR
EQUITY  → taxable_item → PR
PERK    → taxable_item → PR
RECOGNITION → taxable_item → PR
```

- Tracks `source_module`, `source_table`, `source_id` for full traceability
- `processed_flag` + `payroll_batch_id` for sync status

→ Clean integration pattern.

### 2.6 Recognition Points Economy — 4/5

Complete point-based recognition system:
- `point_account` — wallet per employee
- `recognition_event` — peer-to-peer recognition
- `reward_point_txn` — ledger (EARNED/SPENT/ADJUSTED/EXPIRED)
- `perk_catalog` + `perk_redeem` — redemption marketplace

---

## 3. Weaknesses (Điểm yếu)

### 3.1 Calculation Rules Overreach — Critical 🔴

4 tables thêm ngày 25Nov2025 thuộc `comp_core`:
- `calculation_rule_def` — stores full tax brackets, SI rates, OT multipliers
- `basis_calculation_rule` — defines execution order (1=proration → 6=net)
- `component_calculation_rule` — element-level rule mapping
- `tax_calculation_cache` — performance optimization

**Vấn đề**: Đây là **payroll engine concerns**, không phải compensation configuration:

| What TR defines | Should belong to |
|----------------|:----------------:|
| VN_PIT_2025 progressive tax brackets | **PR** statutory_rule |
| VN_SI_2025 social insurance rates | **PR** statutory_rule |
| VN_OT_MULT_2019 overtime multipliers | **PR** formula engine |
| Execution order 1→6 (gross→net pipeline) | **PR** engine pipeline |
| Tax calculation cache | **PR** computation cache |

**Evidence from research** (Doc 03 - Calculation Responsibility Split):
- Weighted score: Option B (PR owns) = **4.20/5** vs Option A (TR defines) = 2.55/5
- 6 out of 11 capabilities overlap between TR and PR

**Đề xuất**:
1. **Re-scope** `calculation_rule_def` → store only "component behavior config" (tax_treatment preference, proration preference) — NOT actual tax brackets
2. **Deprecate** `basis_calculation_rule` — PR owns execution pipeline
3. **Re-scope** `component_calculation_rule` → component behavior mapping only
4. **Move** `tax_calculation_cache` → PR engine
5. Keep `country_config` fields as read-only reference (or move to Core)

### 3.2 Eligibility Duplicate — 🔴

TR has its own eligibility:
- `benefit.eligibility_profile` (code, rule_json, domain)
- `benefit.plan_eligibility` (bridge: plan → eligibility_profile)

Meanwhile Core already has:
- `eligibility.eligibility_profile` (same structure, cross-module)
- `eligibility.eligibility_member` (cached membership)
- `eligibility.eligibility_evaluation` (audit trail)

**Impact**: 
- 2 implementations of same concept
- TR benefits not using Core's caching + audit features
- TA already migrated to Core eligibility — TR hasn't

**Đề xuất**: 
1. Migrate `benefit.eligibility_profile` → use Core `eligibility.eligibility_profile` with `domain = 'BENEFITS'`
2. Replace `benefit.plan_eligibility` → direct FK from `benefit.plan` to Core `eligibility.eligibility_profile`
3. TR gains: cached membership (O(1) lookup), evaluation audit trail

### 3.3 Country Config Fragmentation — 🟡

`comp_core.country_config` stores:
- `standard_working_hours_per_day/week/month`
- `tax_system`, `si_system`

Already in Core:
- `common.talent_market` — market-level config (broader)
- `common.talent_market_parameter` — SI basis, min wage, etc.

Not in PR (but needed):
- Country working hours/days for proration

**Đề xuất**: See Doc 06 for unified solution.

### 3.4 Holiday Calendar Overlap — 🟡

`comp_core.holiday_calendar` duplicates:
- `absence.holiday_calendar` / `absence.holiday_date` (TA module)
- `shared.holiday` (TA shared)

PR also needs holiday data for OT multiplier determination.

**3 copies, 0 single source of truth.**

### 3.5 Grade System — Minor Issues 🟡

`comp_core.grade_v` + `comp_core.grade_ladder` design is good, but:
- Core's `jobpos.job_grade` is separate from TR's `comp_core.grade_v`
- `job.grade_code` (Core) references TR's `GradeVersion.grade_code` (cross-module FK)
- No formal linking table between `jobpos.job_grade` and `comp_core.grade_v`

**Đề xuất**: 
- Clarify: `jobpos.job_grade` = grade definitions, `comp_core.grade_v` = grade versions with compensation data
- Add explicit FK or documentation about which is authoritative

### 3.6 Offer Statement — No Calc Integration 🟡

`tr_offer.offer_package` stores pre-calculated amounts:
- `total_fixed_cash`, `total_variable`, `total_benefits`, `total_cash`, `total_value`

But **no integration** with PR engine for accurate calculation:
- No DryRun API call
- No preview mechanism
- Values likely manually entered or simplified calculation

**Đề xuất**: 
- Add `is_estimate` flag to `offer_package`
- Create PR DryRun API endpoint
- Offer workflow: create draft → call PR DryRun → populate accurate amounts

### 3.7 Benefit Enrollment — Missing Dependent Coverage 🟡

`benefit.enrollment` links employee → plan → option, but:
- No `enrollment_dependent` table for family coverage
- No `coverage_level` concept (EE Only, EE+Spouse, Family)
- No dependent verification workflow

**Đề xuất**: Add:
```
benefit.enrollment_dependent:
  enrollment_id → enrollment
  dependent_id → person.worker_relationship
  coverage_start, coverage_end
  verification_status
```

---

## 4. Schema Quality Assessment

### Index Coverage Analysis

**Well-indexed** ✅:
- `employee_comp_snapshot` — 6 indexes including composite and filtered
- `offer_package` — 4 indexes on worker, employee, status, type
- `audit_log` — 5 indexes for all query patterns

**Under-indexed** ⚠️:

| Table | Missing Index | Reason |
|-------|--------------|--------|
| `comp_core.salary_basis_component_map` | `(salary_basis_id, component_id)` | Component lookup per basis |
| `benefit.premium_employee` | `(enrollment_id, period_start)` | Premium history |
| `recognition.recognition_event` | `(employee_to_id, created_at)` | "My recognitions" query |
| `comp_incentive.comp_adjustment` | `(cycle_id, status, employee_id)` | Cycle review |

### Precision Analysis

TR: `decimal(18,4)` ✅ — updated on Nov 21, 2025  
PR: `decimal(18,2)` ⚠️ — needs upgrade  
Core: `decimal(15,2)` ⚠️ — needs upgrade

**Đề xuất**: Standardize to `decimal(18,4)` across all modules.

---

## 5. Cross-Module Data Flow

### TR → PR (Compensation to Payroll)

```
TR (Source)                           PR (Consumer)
──────────                           ───────────
employee_comp_snapshot ────────────▶  pay_run.input_value (BASE_SALARY)
bonus_allocation (APPROVED) ──────▶  pay_run.input_value (BONUS)
taxable_item (PENDING) ──────────▶   pay_run.input_value (TAXABLE additions)
enrollment.premium_employee ─────▶   pay_run.input_value (BENEFIT_DEDUCTION)
comp_adjustment (APPROVED) ──────▶   retro trigger + updated input
```

### TR → CO (Configuration refs)

```
TR (Source)                           CO (Provider)
──────────                           ───────────
grade_v.grade_code ◀─────────────── job.grade_code (Core)
employee_comp_snapshot ◀──────────── employment.employee (Core)
offer_package.worker_id ◀────────── person.worker (Core)
```

### Proposed TR → PR Preview

```
TR (Offer/Statement)                  PR (DryRun API)
────────────────────                  ──────────────
POST /api/v1/payroll/preview
  employee_id (or mock data)
  components: [...amounts...]          → DryRun calculation
                                       → response: { gross, si, tax, net }
offer_package.total_* ◀──────────────  preview result
statement_line.statement_json ◀───────  preview result
```

---

## 6. Improvement Proposals

### P0 — Critical

| # | Improvement | Effort | Impact |
|:-:|-------------|:------:|:------:|
| 1 | **Re-scope calculation rules**: `calculation_rule_def` → component behavior config only, NOT actual tax brackets | 1 sprint | TR, PR |
| 2 | **Deprecate `basis_calculation_rule`**: PR owns execution pipeline | Discussion | TR, PR |
| 3 | **Migrate eligibility to Core**: `benefit.eligibility_profile` → Core engine | 1 sprint | TR, CO |
| 4 | **Move `tax_calculation_cache` to PR**: Computation caching = engine concern | 0.5 sprint | TR, PR |

### P1 — Important

| # | Improvement | Effort | Impact |
|:-:|-------------|:------:|:------:|
| 5 | **Country config unification**: Move or delegate to Core | Discussion | TR, CO, PR |
| 6 | **Holiday calendar consolidation**: Single source | Discussion | TR, TA, CO |
| 7 | **Grade system clarification**: Document `job_grade` vs `grade_v` relationship | Documentation | TR, CO |
| 8 | **Add enrollment_dependent**: Family/dependent benefit coverage | 1 sprint | TR |
| 9 | **PR DryRun integration**: For Offer/Statement accurate calculations | 1 sprint | TR, PR |

### P2 — Nice to Have

| # | Improvement | Effort | Impact |
|:-:|-------------|:------:|:------:|
| 10 | Add missing indexes (4 tables) | 0.5 sprint | TR |
| 11 | Standardize precision to `decimal(18,4)` globally | 0.5 sprint | All |
| 12 | Add `comp_core.compensation_review_template` for cycle templates | 1 sprint | TR |

---

## 7. Score Summary

| Criterion | Score | Notes |
|-----------|:-----:|-------|
| Domain coverage | 5.0/5 | All 5 pillars of Total Rewards covered |
| SCD-2/Versioning | 5.0/5 | Multiple versioning patterns, well-applied |
| Audit trail | 5.0/5 | Exemplary — recommended as pattern for all modules |
| Calculation rules | 2.0/5 | Overreach into payroll territory — needs re-scoping |
| Eligibility | 2.0/5 | Duplicate with Core — needs migration |
| Country/holiday config | 2.5/5 | Fragmented — multiple sources, no single truth |
| Benefit enrollment | 3.5/5 | Missing dependent coverage |
| Component metadata | 4.5/5 | Rich metadata — better than PR's lean elements |
| **Overall** | **3.9/5** | Excellent domain model, needs boundary correction and deduplication |

---

*← [02 TA Analysis](./02-ta-analysis.md) · [04 PR Analysis →](./04-pr-analysis.md)*
