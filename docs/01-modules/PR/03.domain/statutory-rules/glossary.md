# Glossary — BC-02: Statutory Rules

**Bounded Context**: Statutory Rules
**Module**: Payroll (PR)
**Step**: 3 — Domain Architecture
**Date**: 2026-03-31

---

## Purpose

This glossary defines the ubiquitous language for the Statutory Rules bounded context. BC-02 is the single source of truth for all regulatory rates, thresholds, brackets, multipliers, and eligibility matrices that the payroll engine must apply. All values are versioned with effective dates and are never hardcoded in application logic.

---

## Aggregate Roots

### StatutoryRule

| Field | Value |
|-------|-------|
| **Name** | StatutoryRule |
| **xTalent Term** | `statutory_rule` |
| **Type** | Aggregate Root |
| **Definition** | A versioned regulatory parameter or rule set. Every statutory rate, threshold, multiplier, bracket schedule, or eligibility matrix is stored as a StatutoryRule record with a `rule_category`, `rule_type`, `valid_from`, `valid_to`, `formula_json` (the rule data in a typed JSON structure), `country_code`, and `is_active` flag. When a new decree changes a rate, a new StatutoryRule record is created with the new `valid_from` date — the old record's `valid_to` is set to `valid_from - 1 day`. The payroll engine always looks up the rule valid at the payroll period's cut-off date. |
| **Khac voi** | Not the same as a PayElement formula (which is a custom business formula). StatutoryRule contains regulatory data — rates mandated by law. A statutory_rule cannot be "overridden" by a payroll admin for a specific worker. It can only be updated by Platform Admin when a new decree is issued. |
| **States** | DRAFT, ACTIVE, SUPERSEDED |
| **Lifecycle Events** | StatutoryRuleCreated, StatutoryRuleActivated, StatutoryRuleDeactivated, PitBracketsUpdated, SiCeilingUpdated, MinimumWageUpdated |

---

### SiEligibilityMatrix

| Field | Value |
|-------|-------|
| **Name** | SiEligibilityMatrix |
| **xTalent Term** | `si_eligibility_rule` |
| **Type** | Aggregate Root (configuration table, managed as a group within BC-02) |
| **Definition** | A configurable lookup table that maps `contract_type` × `insurance_type` → `is_eligible` (boolean). This matrix governs which contract types qualify for which social insurance contribution types (BHXH, BHYT, BHTN). The matrix is stored as data — not coded in application logic. It is updated by Platform Admin when regulatory eligibility rules change. |
| **Khac voi** | Not part of PayProfile or PayElement. The SI eligibility matrix applies globally across all workers by contract type. Worker-specific overrides are not supported (regulatory requirement). |

---

## Entities

### StatutoryRuleValue (Entity within StatutoryRule)

| Field | Value |
|-------|-------|
| **Name** | StatutoryRuleValue |
| **Type** | Entity |
| **Definition** | For rules with a simple scalar value (e.g., a rate or threshold): the `value_numeric` and `unit` (RATE_PERCENT, VND_AMOUNT, MULTIPLIER, DAYS). For complex rules (progressive brackets, eligibility matrices), the data is in `formula_json`. |

---

## Value Objects

### PitBracket

| Field | Value |
|-------|-------|
| **Name** | PitBracket |
| **Type** | Value Object (within StatutoryRule of rule_category = PIT, rule_type = PROGRESSIVE) |
| **Definition** | A single bracket in the progressive PIT schedule. Contains: `bracket_index` (1–7), `lower_bound_vnd`, `upper_bound_vnd` (null for the top bracket), `rate_percent`. The complete bracket schedule is stored as a JSON array within `formula_json` on the StatutoryRule. |

---

### SiContributionRate

| Field | Value |
|-------|-------|
| **Name** | SiContributionRate |
| **Type** | Value Object (within StatutoryRule of rule_category = SOCIAL_INSURANCE) |
| **Definition** | A social insurance contribution rate record. Contains: `insurance_type` (BHXH, BHYT, BHTN), `party` (EMPLOYEE, EMPLOYER), `rate_percent`. These rates are stored as separate StatutoryRule records, each with its own `valid_from` date. |

---

### RegionalMinimumWage

| Field | Value |
|-------|-------|
| **Name** | RegionalMinimumWage |
| **Type** | Value Object (within StatutoryRule of rule_category = MINIMUM_WAGE) |
| **Definition** | A minimum wage floor for a specific `region_code` (REGION_1, REGION_2, REGION_3, REGION_4) effective from `valid_from`. The absolute minimum monthly wage that any pay calculation must meet. Applied to all pay methods (including piece-rate per BR-070 to BR-073). |

---

## Domain Events

| Event Name | Aggregate | Description |
|------------|-----------|-------------|
| StatutoryRuleCreated | StatutoryRule | A new regulatory rule or updated version was entered (DRAFT state) |
| StatutoryRuleActivated | StatutoryRule | Rule activated (`is_active = true`); calculation engine cache invalidated |
| StatutoryRuleDeactivated | StatutoryRule | Rule deactivated (superseded or suspended) |
| PitBracketsUpdated | StatutoryRule | New PIT bracket schedule created (new decree) — payroll admin alerted |
| SiCeilingUpdated | StatutoryRule | New SI ceiling or base salary (lương cơ sở) value created |
| MinimumWageUpdated | StatutoryRule | New regional minimum wage created |

---

## Commands

| Command Name | Actor | Description |
|--------------|-------|-------------|
| CreateStatutoryRule | Platform Admin | Enter a new regulatory rule or updated version with `valid_from` date |
| ActivateStatutoryRule | Platform Admin | Set a statutory rule to active; triggers cache invalidation in payroll engine |
| DeactivateStatutoryRule | Platform Admin | Deactivate a rule (e.g., decree superseded mid-year) |
| UpdateSiEligibilityMatrix | Platform Admin | Update the contract_type × insurance_type eligibility mapping |

---

## Statutory Rule Categories

| rule_category | Examples |
|--------------|----------|
| PIT | VN_PIT_BRACKETS_2020, VN_PIT_PERSONAL_DEDUCTION, VN_PIT_DEPENDENT_DEDUCTION, VN_PIT_NON_RESIDENT_RATE |
| SOCIAL_INSURANCE | VN_BHXH_EMP_RATE, VN_BHXH_EMP_RATE_EMPLOYER, VN_BHYT_EMP_RATE, VN_BHYT_EMP_RATE_EMPLOYER, VN_BHTN_EMP_RATE, VN_BHTN_EMP_RATE_EMPLOYER, VN_SI_CEILING_MULTIPLIER, VN_LUONG_CO_SO |
| OVERTIME | VN_OT_WEEKDAY_MULT, VN_OT_WEEKEND_MULT, VN_OT_HOLIDAY_MULT, VN_NIGHT_SHIFT_SUPPLEMENT |
| MINIMUM_WAGE | VN_MIN_WAGE_REGION_1, VN_MIN_WAGE_REGION_2, VN_MIN_WAGE_REGION_3, VN_MIN_WAGE_REGION_4 |
| TAX | VN_LUNCH_EXEMPT_CAP, VN_FREELANCE_WITHHOLDING_THRESHOLD, VN_FREELANCE_TAX_RATE |
| UNEMPLOYMENT_INSURANCE | VN_BHTN_ANNUAL_CAP |

---

## SI Eligibility Matrix (Current Vietnam, per BR-032)

| contract_type | BHXH | BHYT | BHTN | Notes |
|--------------|------|------|------|-------|
| UNLIMITED_TERM | YES | YES | YES | Hợp đồng không xác định thời hạn |
| FIXED_TERM_12_36 | YES | YES | YES | Hợp đồng có thời hạn 12–36 tháng |
| FIXED_TERM_LT_12 | YES | YES | NO | Hợp đồng dưới 12 tháng — BHTN exempt |
| PROBATION | NO | NO | NO | Thử việc ≤ 60 ngày |
| SERVICE_CONTRACT | NO | NO | NO | Hợp đồng dịch vụ / khoán việc |
| FREELANCE | NO | NO | NO | Freelance / CTV |
| INTERN | NO | YES | NO | BHYT only, per intern policy |

This matrix is the authoritative mapping for HS-4 (SI eligibility edge cases). It is stored in `si_eligibility_rule` configuration, not in code.

---

## Business Rules (in scope for BC-02)

| Rule ID | Summary |
|---------|---------|
| BR-020 | BHXH employee rate (8%) |
| BR-021 | BHXH employer rate (17.5%) |
| BR-022 | BHYT employee rate (1.5%) |
| BR-023 | BHYT employer rate (3%) |
| BR-024 | BHTN employee rate (1%) |
| BR-025 | BHTN employer rate (1%) |
| BR-026 | SI ceiling = SI_CEILING_MULTIPLIER × VN_LUONG_CO_SO |
| BR-027 | SI basis definition (configurable per pay_element.si_basis_inclusion) |
| BR-028 to BR-032 | SI eligibility by contract type (stored in SiEligibilityMatrix) |
| BR-033 | Split-period SI calculation when ceiling changes mid-month |
| BR-034 | Annual BHTN ceiling |
| BR-040 | PIT taxable income formula (resident) |
| BR-041 | PIT 7-bracket progressive schedule |
| BR-042 | PIT non-resident flat rate (20%) |
| BR-043 | Freelance/service contract withholding (10%) |
| BR-050 | PIT personal deduction (11,000,000 VND/month) |
| BR-051 | PIT dependent deduction (4,400,000 VND/person/month) |
| BR-070 to BR-073 | Regional minimum wage floors |

---

## Terms Used from External Bounded Contexts

| Term | Source BC | How Used in BC-02 |
|------|-----------|------------------|
| `legal_entity_id` | CO (EXT-01) | Optional override scope on StatutoryRule — global rules have NULL; entity-specific overrides carry the ID |
| `contract_type` | CO (EXT-01) | Key column in SiEligibilityMatrix — maps from CO contract classification to SI eligibility |
| `working_relationship_id` | CO (EXT-01) | Not directly used in BC-02; referenced indirectly when BC-03 looks up eligibility for a specific worker |
