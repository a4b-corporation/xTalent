# Payroll Module (PR) — Deep Analysis

**File**: `5.Payroll.V3.dbml` (545 lines)  
**Last updated**: Jul 2025  
**Research docs**: 6 docs at `PR/_research/analyze/`  
**Assessed**: 2026-03-16

---

## 1. Schema Inventory

| # | Schema | Tables | Purpose |
|:-:|--------|:------:|---------|
| 1 | `pay_master` | 14 | Config: pay_frequency, pay_calendar, pay_group, pay_element, pay_formula, statutory_rule, validation_rule, payslip_template, pay_benefit_link, costing_rule, gl_mapping, pay_profile, pay_profile_map, balance_def |
| 2 | `pay_run` | 8 | Execution: batch, result, input_value, balance, calc_log, manual_adjust, retro_delta, costing |
| 3 | `pay_gateway` | 4 | Integration: iface_def, iface_mapping, bank_template, tax_report_template |
| 4 | `pay_bank` | 3 | Banking: bank_account, payment_batch, payment_line |
| 5 | `pay_audit` | 1 | Audit: audit_log |
| 6 | (standalone) | 4 | Import: import_job, generated_file + 2 standalone |

**Tổng**: ~34 tables, 6 schemas, 545 lines

---

## 2. Strengths (Điểm mạnh)

### 2.1 Engine Architecture — 4.8/5

Per overview docs (not in DBML), PR engine uses:
- **Drools 8 Rule Units** — enterprise-grade, proven at scale
- **Business DSL Layer** — HR-friendly formula syntax
- **5-layer Security** — MVEL dialect → classloader → timeout → whitelist → audit
- **3 Execution Modes** — DryRun, Simulation, Production
- **5-stage Pipeline** — Pre-validation → Gross → SI → Tax → Net → PostProcess
- **Dependency Management** — formula dependency graph, circular detection

→ **Top-tier engine design** — no changes needed.

### 2.2 Immutable Run Data — 5/5

`pay_run.*` tables follow proper payroll processing patterns:
- `pay_run.batch` — execution control with status workflow
- `pay_run.result` — per-employee results (append-only per batch)
- `pay_run.balance` — running totals (accumulated)
- `pay_run.calc_log` — step-by-step calculation trace (immutable)
- `pay_run.costing` — cost allocation per result

All result tables reference `batch_id` — no data mutation after run completion.

### 2.3 Retro Support — 4.5/5

`pay_run.retro_delta`:
- `orig_batch_id` — reference to original run
- `orig_result_id` — specific employee result being adjusted
- `delta_amount` — positive/negative difference
- `reason_code` — categorized reason

→ Complete retroactive calculation support.

### 2.4 Clean Schema Separation — 4/5

4 schemas with clear concerns:
- `pay_master` = Configuration (WHAT is paid, HOW it's defined)
- `pay_run` = Execution (actual payroll processing data)
- `pay_gateway` = Integration (external system interfaces)
- `pay_bank` = Banking (payment processing)

### 2.5 Costing/GL — 4/5

`pay_run.costing` + `pay_master.gl_mapping` + `pay_master.costing_rule`:
- `gl_mapping` maps element → GL account code
- `costing_rule` defines allocation percentages to cost centers
- `costing` records actual cost distribution per result

→ Financial integration-ready.

---

## 3. Weaknesses (Điểm yếu)

### 3.1 `pay_element` Too Lean — Critical 🔴

Current `pay_element`:
```
id, code, name, classification, taxable_flag, pre_tax_flag,
formula_json, input_required, unit, priority_order,
statutory_rule_id, gl_account_code, is_active,
effective_start_date, effective_end_date, is_current_flag
```

**Missing fields (available in TR's `pay_component_def`)**:

| Missing Field | TR Source | Why PR Needs It |
|--------------|-----------|----------------|
| `tax_treatment` | `FULLY_TAXABLE / TAX_EXEMPT / PARTIALLY_EXEMPT` | Smarter than binary `taxable_flag` |
| `tax_exempt_threshold` | `decimal(18,4)` (e.g., 730K for lunch) | Engine needs this for partial exemption |
| `proration_method` | `CALENDAR_DAYS / WORKING_DAYS / NONE` | Current engine uses generic `proRata()` |
| `calculation_method` | `FIXED / FORMULA / PERCENTAGE / HOURLY` | Currently only `formula_json` — limits simple cases |
| `si_calculation_basis` | `FULL_AMOUNT / CAPPED / EXCLUDED` | PR infers from statutory_rule — less explicit |

**Also missing metadata**:
| Field | Purpose |
|-------|---------|
| `frequency_code` | Element applies to MONTHLY / HOURLY / etc. |
| `component_type` | Richer than `classification`: BASE, ALLOWANCE, BONUS, OVERTIME, EMPLOYER_CONTRIBUTION |
| `country_code` | Element country specificity |
| `legal_reference` | Legal basis for statutory elements |
| `description` | Element description (for HR documentation) |

### 3.2 Classification Too Simple — Critical 🔴

Current: only 3 types
```
classification: EARNING | DEDUCTION | TAX
```

Needed: at least 6 types (aligned with TR)
```
classification: 
  EARNING subtypes: BASE, ALLOWANCE, BONUS, OVERTIME
  DEDUCTION subtypes: EMPLOYEE_DEDUCTION, EMPLOYER_CONTRIBUTION
  TAX (keep)
  INFORMATIONAL (new — display only, no payment)
```

**Why**: 
- BHXH employer contribution is classified as DEDUCTION in current schema but semantically it's EMPLOYER_CONTRIBUTION
- Need to subtotalize by type on payslip
- Analytics needs richer breakdown

### 3.3 No API Contract — Critical 🔴

PR has zero API specification. All integration is internal — no formal contract.

Per Doc 04 (Payroll API Contract Design), PR needs ~28 endpoints:
- Config APIs (~10) — elements, profiles, calendars
- Input APIs (~6) — compensation input, timesheet, adjustments
- Execution APIs (~6) — start, cancel, approve, retry runs
- Output APIs (~6) — payslips, bank files, GL exports, statements

### 3.4 Missing Country/Holiday Config — 🔴

PR does not know:
- How many working days/hours per country per month
- Which dates are holidays (for OT multiplier calculation)
- Country-specific rounding rules

Currently depends on:
- TR's `comp_core.country_config` (if accessible)
- Or hardcoded in Drools rules

### 3.5 `pay_profile` Underspecified — 🔴

DBML has:
```
pay_profile: id, code, name, legal_entity_id, market_id, metadata
pay_profile_map: profile_id, element_id
```

Missing:
- Element execution order within profile
- Element mandatory/optional flags
- Default values per element
- Rule binding (which statutory rules apply)
- Calculation pipeline configuration

→ Overview docs describe PayProfile as "bundle policy" but schema doesn't match.

### 3.6 `statutory_rule` Too Generic — 🟡

```
statutory_rule:
  id, code, name, rule_type, formula_json, valid_from, valid_to, market_id
```

All statutory logic is in single `formula_json` JSONB — no structure:
- TAX brackets and SI rate tables use same schema
- No distinction between progressive tax, flat rate, lookup table
- No version tracking (just `valid_from/to`)

**Đề xuất**: Separate into structured sub-tables or add `rule_category`:
```
statutory_rule:
  + rule_category: TAX_TABLE | SI_RATE | OT_MULTIPLIER | ROUNDING | ...
  + version_number + previous_version_id (SCD-2)
  + country_code (not just market_id)
  + legal_reference: text
```

### 3.7 Decimal Precision — 🟡

All amounts: `decimal(18,2)` — only 2 decimal places.

TR uses `decimal(18,4)`. Multi-currency operations (forex, crypto) need more precision.

### 3.8 No Input Staging — 🟡

Compensation data flows directly into `pay_run.input_value` per batch.

**Problem**: No validation/staging layer before it enters the run. If TR data is incorrect, the entire batch may fail.

**Đề xuất**: Add `pay_staging` schema:
```
pay_staging.input_record:
  source_module, source_batch_id, employee_id, element_code,
  value, validation_status, error_message, imported_at
```

---

## 4. Engine Assessment (from Overview Docs)

### 4.1 Formula Engine — 4.8/5

```
Layer 3:  Business DSL   ← HR writes: kpiScore * baseAmount * 1.5
Layer 2:  Drools 8        ← Rule units, forward chaining, conflict resolution
Layer 1:  Execution Core  ← Java sandbox, security, dependency management
```

**DSL Functions available**:
- `proRata(amount, workDays, standardDays)` — proration
- `taxBracket(income, brackets[])` — progressive tax
- `siCalc(base, rates, cap, floor)` — social insurance
- `round(amount, precision, method)` — rounding

### 4.2 5-Stage Pipeline — 5/5

```
Stage 1: Pre-validation (VN_PrePayroll_Unit)
  → validate input completeness, employee active, period open

Stage 2: Gross Calculation (VN_GrossCalculation_Unit)
  → base + allowances + OT + bonuses = gross

Stage 3: Insurance (VN_InsuranceCalc_Unit)
  → BHXH (8%) + BHYT (1.5%) + BHTN (1%) employee
  → BHXH (14%) + BHYT (3%) + BHTN (1%) + BHTNLD (0.5%) employer

Stage 4: Tax (VN_TaxCalculation_Unit)
  → Taxable income = gross - SI - personal deduction - dependent deduction
  → Progressive 7-bracket PIT

Stage 5: Net + PostProcess (VN_NetCalculation_Unit)
  → Net = gross - SI - PIT - other deductions
  → Rounding, retroactive adjustments
```

→ **No changes needed** — engine design is excellent.

---

## 5. Cross-Module Integration Gaps

### 5.1 Current Inbound Data Flow

| Source | Data | PR Consumer | Status |
|--------|------|-------------|:------:|
| CO | Employee, assignment, legal entity | `pay_run.result.employee_id` | ✅ FK exists |
| TR | Salary amounts, bonus allocations | `pay_run.input_value` | ⚠️ No formal API |
| TR | Taxable items (equity/perk) | `pay_run.input_value` | ⚠️ No formal API |
| TR | Benefit premiums | `pay_run.input_value` | ⚠️ No formal API |
| TA | Attendance hours, OT hours | `pay_run.input_value` | ⚠️ No formal API |

### 5.2 Current Outbound Data Flow

| PR Output | Target | Mechanism | Status |
|-----------|--------|-----------|:------:|
| Payslip | Employee self-service | `payslip_template` + `generated_file` | ✅ Designed |
| Bank file | Banking system | `bank_template` + `payment_batch/line` | ✅ Designed |
| GL entries | Finance/ERP | `gl_mapping` + `costing` | ✅ Designed |
| Tax reports | Tax authority | `tax_report_template` + `generated_file` | ✅ Designed |
| Payroll summary | TR (for statements) | *(none)* | ❌ Missing |

---

## 6. Improvement Proposals

### P0 — Critical (Immediate)

| # | Improvement | Effort | Impact |
|:-:|-------------|:------:|:------:|
| 1 | **Enrich `pay_element`**: Add 5 fields (tax_treatment, proration_method, si_basis, tax_exempt_cap, calculation_method) | 1 sprint | PR engine accuracy |
| 2 | **Upgrade classifications**: 3 → 6+ types (BASE, ALLOWANCE, BONUS, OT, EMPLOYER_CONTRIBUTION, INFORMATIONAL) | 1 sprint | PR reporting |
| 3 | **Add `pay_master.country_config`**: Working hours/days per country | 0.5 sprint | Multi-country |
| 4 | **Add `pay_master.holiday_calendar`**: Holidays + OT multipliers | 0.5 sprint | OT accuracy |

### P1 — Important (Next phase)

| # | Improvement | Effort | Impact |
|:-:|-------------|:------:|:------:|
| 5 | **Enrich `pay_profile`**: Add element ordering, mandatory flags, rule binding | 1 sprint | Config completeness |
| 6 | **Structure `statutory_rule`**: Add rule_category, version tracking, legal_reference | 1 sprint | Compliance |
| 7 | **Define OpenAPI spec**: ~28 endpoints per Doc 04 design | 2 sprints | Independence |
| 8 | **Add input staging**: `pay_staging.*` schema for validation | 1 sprint | Data quality |
| 9 | **Define AsyncAPI spec**: 9 published + 7 consumed events | 1 sprint | Event-driven |
| 10 | **Decimal precision**: `decimal(18,2)` → `decimal(18,4)` | 0.5 sprint | Accuracy |

### P2 — Headless Readiness (Future)

| # | Improvement | Effort | Impact |
|:-:|-------------|:------:|:------:|
| 11 | Independent database instance | 1 sprint | Deployment |
| 12 | Multi-tenant support | 2 sprints | SaaS |
| 13 | API versioning | 1 sprint | Compatibility |
| 14 | Client SDK generation | 1 sprint | Developer experience |
| 15 | Expose DryRun/Preview API for TR consumption | 1 sprint | TR integration |

---

## 7. Re-Design Roadmap (Progressive)

| Level | Scope | Effort | Score After |
|:-----:|-------|:------:|:----------:|
| **Level 1** (Minimal) | Enrich schema + classifications + country/holiday | 2-3 sprints | 3.3 → **4.0/5** |
| **Level 2** (Moderate) | API-first + staging + structured rules + rich profile | 3-4 sprints | 4.0 → **4.5/5** |
| **Level 3** (Full Headless) | Independent DB + multi-tenant + SDK | 4-6 sprints | 4.5 → **5.0/5** |

---

## 8. Score Summary

| Criterion | Score | Notes |
|-----------|:-----:|-------|
| Engine architecture | 4.8/5 | Drools 8 + DSL + 5-stage pipeline = excellent |
| Schema completeness | 2.5/5 | 7 missing entities/fields, lean element, generic statutory_rule |
| Run/batch model | 5.0/5 | Immutable, retro support, calc tracing |
| API readiness | 1.0/5 | No spec, no contract, internal only |
| PR independence | 1.5/5 | Cannot run standalone — depends on internal coupling |
| Multi-country | 2.0/5 | No country_config, no holiday_calendar |
| Bank/GL/Tax output | 4.0/5 | Complete — templates, mapping, file generation |
| **Overall** | **3.3/5** | Excellent engine trapped in a weak schema — Level 1 changes give max ROI |

---

*← [03 TR Analysis](./03-tr-analysis.md) · [05 Eligibility Consolidation →](./05-eligibility-consolidation.md)*
