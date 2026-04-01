# UCF-06: Statutory Rule Update

**Bounded Context**: Statutory Rules (BC-02)
**Timeline**: T6 — Triggered when a new government decree or circular changes statutory rates, thresholds, or brackets
**Actors**: Platform Admin, System
**Trigger**: New Vietnamese decree or circular published that changes SI rates, PIT brackets, minimum wage, OT multipliers, or other statutory parameters (e.g., NĐ 73/2024/NĐ-CP raising SI ceiling, NQ 954/2020/UBTVQH14 raising PIT deductions)

---

## Preconditions

- Platform Admin has `STATUTORY_RULE_ADMINISTRATOR` permission
- The new decree text and effective date are available
- If a prior StatutoryRule of the same rule_type exists: its valid_to date has not yet been set (open-ended)
- No PayrollRun is currently in RUNNING state that depends on the rule being updated (system checks before activation)

---

## Main Flow

| Step | Actor | Action | System Response |
|------|-------|--------|-----------------|
| 1 | Platform Admin | Issues `CreateStatutoryRule` command with: rule_category, rule_type, valid_from (decree effective date), formula_json (rate/bracket data), country_code, decree_reference | System creates new StatutoryRule in DRAFT state. Assigns rule_id. Validates: valid_from > today (must be future-dated; cannot create backdated active rules without override flag). Validates formula_json schema for the given rule_category. Emits `StatutoryRuleCreated`. |
| 2 | System | Validate no overlap | System checks: is there already a StatutoryRule of the same rule_type with overlapping valid_from/valid_to? If overlap found: system blocks activation with OVERLAPPING_RULE conflict error. Admin must set valid_to on the existing rule first (or system can auto-close if admin confirms). |
| 3 | Platform Admin | Reviews DRAFT rule in portal | Admin verifies: rate values, valid_from date, decree reference text, formula_json structure. May edit the DRAFT rule before activation. |
| 4 | Platform Admin | Issues `ActivateStatutoryRule` command | System transitions StatutoryRule from DRAFT → ACTIVE. Sets is_active = true. If a previous StatutoryRule of the same rule_type is currently ACTIVE: system sets its valid_to = valid_from − 1 day, transitions it to SUPERSEDED. Emits `StatutoryRuleActivated`. Emits category-specific events: `PitBracketsUpdated`, `SiCeilingUpdated`, or `MinimumWageUpdated` depending on rule_category. |
| 5 | System | Invalidate calculation engine cache | Payroll Engine (BC-03) receives `StatutoryRuleActivated` event and invalidates its in-process StatutoryRule cache. Next PayrollRun will fetch the new rule from BC-02. |
| 6 | System | Validate dependent formulas | System checks all PayElement formulas in ACTIVE state that reference this rule_type (via PayProfileRule bindings). Runs a formula validation pass: does the new rule_type's formula_json schema still satisfy the formula's expected input types? If validation passes: emits `FormulasRevalidated`. If any formula fails schema validation: emits `FormulaValidationFailed` and alerts Payroll Admin. The new rule remains ACTIVE; the affected PayElement formula must be updated. |
| 7 | System | Downstream notifications | System sends notifications to all active Payroll Admins for all legal entities: "Statutory rule [rule_type] updated, effective [valid_from]. Review pending payrolls." If valid_from is within the current open PayPeriod for any PayGroup: urgent notification: "Cut-off date [date] falls after new rule effective date — payroll will use new rates." |

---

### Real-World Example: NĐ 73/2024/NĐ-CP — SI Ceiling Update

Scenario: Decree 73/2024 raises the SI ceiling multiplier effective July 1, 2024.
New rule: VN_SI_CEILING_MULTIPLIER = 20 × VN_LUONG_CO_SO (was 20 × old_luong_co_so; lương cơ sở raised from 1,800,000 to 2,340,000 VND)

Platform Admin creates:
```
rule_category: SOCIAL_INSURANCE
rule_type: VN_LUONG_CO_SO
valid_from: 2024-07-01
formula_json: { "value_numeric": 2340000, "unit": "VND_AMOUNT" }
country_code: VN
decree_reference: "NĐ 73/2024/NĐ-CP Điều 3"
```

Effect on payroll: All July 2024 payrolls (cut-off date ≥ July 1, 2024) will use the new lương cơ sở value.
New SI ceiling = 20 × 2,340,000 = 46,800,000 VND/month (was 20 × 1,800,000 = 36,000,000 VND/month).

If the June 2024 period has a cut-off date of June 28: June payroll uses old ceiling.
If July 2024 period has cut-off date of July 25: July payroll uses new ceiling.

If a period's cut-off is July 15 but lương cơ sở change is July 1: BR-033 (split-period SI) applies for workers whose contracts were active both before and after July 1.

---

### Real-World Example: NQ 954/2020 — PIT Deduction Update

Scenario: NQ 954/2020/UBTVQH14 raised personal deduction to 11,000,000 VND (was 9,000,000 VND) effective January 1, 2020.

Platform Admin creates:
```
rule_category: PIT
rule_type: VN_PIT_PERSONAL_DEDUCTION
valid_from: 2020-01-01
formula_json: { "value_numeric": 11000000, "unit": "VND_AMOUNT" }
country_code: VN
decree_reference: "NQ 954/2020/UBTVQH14 Điều 1"
```

PIT bracket schedule update (separate StatutoryRule of rule_type = VN_PIT_BRACKETS_2020):
```
formula_json: {
  "brackets": [
    { "index": 1, "lower": 0, "upper": 5000000, "rate": 0.05 },
    { "index": 2, "lower": 5000001, "upper": 10000000, "rate": 0.10 },
    { "index": 3, "lower": 10000001, "upper": 18000000, "rate": 0.15 },
    { "index": 4, "lower": 18000001, "upper": 32000000, "rate": 0.20 },
    { "index": 5, "lower": 32000001, "upper": 52000000, "rate": 0.25 },
    { "index": 6, "lower": 52000001, "upper": 80000000, "rate": 0.30 },
    { "index": 7, "lower": 80000001, "upper": null, "rate": 0.35 }
  ]
}
```

---

## Alternate Flows

### AF-1: Backdated Rule (Emergency Correction)
- At step 1: Admin needs to create a rule with valid_from in the past (e.g., a decree was published but not entered on time)
- Standard flow blocks past-dated rules without override
- Admin must use the `BACKDATED_RULE_OVERRIDE` flag — requires a second Platform Admin to confirm
- System creates the rule in DRAFT; activating it with a past valid_from triggers an alert: "Payrolls processed between [original_effective_date] and today used incorrect rates. Retroactive correction runs may be required."
- BC-03 must be manually triggered to run retro adjustments for affected workers

### AF-2: Rule Deactivation Without Replacement (Regulatory Suspension)
- A statutory rate is temporarily suspended by a government circular (e.g., COVID-era SI reduction)
- Platform Admin issues `DeactivateStatutoryRule` command
- System transitions the rule from ACTIVE to SUPERSEDED
- If no replacement rule with a new valid_from exists: the engine will fail pre-validation when it tries to look up the rule for the next payroll
- Platform Admin must either create a new rule immediately or configure a default fallback

### AF-3: Minor Rate Adjustment (Same Rule Category, Same Schema)
- E.g., BHTN employer rate changes from 1% to 1.5% in a new decree
- Admin creates new StatutoryRule with same rule_type but new valid_from and updated formula_json
- Same flow as Main Flow — the old rule is superseded by the new one
- PayProfile.PayProfileRule bindings do not need to be updated (they reference rule_type, not a specific rule version)

---

## Exception Flows

### EF-1: Overlapping Rule Versions
- At step 2: new rule's valid_from overlaps with an existing ACTIVE rule's valid_from/valid_to window
- System blocks activation with OVERLAPPING_RULE error
- Admin must either: (a) update the existing rule's valid_to to one day before new rule's valid_from, or (b) confirm the overlap and system auto-resolves (closes the older rule)
- System never allows two ACTIVE rules of the same rule_type with overlapping date ranges

### EF-2: Schema Validation Failure
- At step 1 or step 6: formula_json does not match the expected JSON schema for the rule_category
- Step 1: `CreateStatutoryRule` fails with INVALID_FORMULA_SCHEMA error; rule is not created
- Step 6: rule is ACTIVE but dependent formula fails validation; `FormulaValidationFailed` event emitted
- Admin must correct formula_json before the rule becomes effective in a live payroll run

### EF-3: Active PayrollRun Dependency
- At step 4: a PayrollRun for the current period is already in RUNNING state
- The new rule's valid_from is within the current period's cut-off date
- System warns: "A live payroll run is in progress. Activating this rule now may cause an inconsistency for the current run."
- Options: (a) Wait until current run completes, then activate; (b) Force activation — current run continues with the cached (old) rule version; next run will use the new rule
- System records the activation timestamp and which run was in-flight at activation

---

## Domain Events Emitted

| Event | Emitted At Step | Payload Key Fields |
|-------|-----------------|-------------------|
| StatutoryRuleCreated | 1 | rule_id, rule_category, rule_type, valid_from, decree_reference, created_by |
| StatutoryRuleActivated | 4 | rule_id, rule_type, valid_from, superseded_rule_id, activated_by, activated_at |
| StatutoryRuleDeprecated | 4 (old rule) | rule_id, rule_type, valid_to, superseded_by_rule_id |
| PitBracketsUpdated | 4 (conditional) | rule_id, effective_from, bracket_count, personal_deduction, dependent_deduction |
| SiCeilingUpdated | 4 (conditional) | rule_id, effective_from, luong_co_so, si_ceiling_multiplier, new_si_ceiling_vnd |
| MinimumWageUpdated | 4 (conditional) | rule_id, effective_from, region_code, new_minimum_wage_vnd |
| FormulasRevalidated | 6 | rule_id, dependent_formula_count, validation_passed_count, failed_count |

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-020 | BHXH employee rate: 8% (per Decree 73/2024, Law 58/2014) |
| BR-021 | BHXH employer rate: 17.5% |
| BR-022 | BHYT employee rate: 1.5% |
| BR-023 | BHYT employer rate: 3% |
| BR-024 | BHTN employee rate: 1% |
| BR-025 | BHTN employer rate: 1% |
| BR-026 | SI ceiling = 20 × VN_LUONG_CO_SO |
| BR-033 | Split-period SI applies when SI ceiling changes mid-period |
| BR-040 to BR-051 | PIT brackets, personal deduction, dependent deduction (NQ 954/2020) |
| BR-070 to BR-073 | Regional minimum wage floors per Decree 38/2022 |

---

## Hot Spots / Risks

- Regulatory lag — Decrees are published with short lead times (sometimes effective on publication date). Platform Admins must be alerted to monitor official gazette (Cổng thông tin điện tử Chính phủ) and enter new rules promptly.
- Formula schema versioning — If a new decree introduces a new structure (e.g., a new SI contribution type), the formula_json schema must be updated in the platform before a new rule can be created. This is a platform deployment dependency.
- In-flight payroll runs — Activating a new rule while a run is in progress can cause inconsistency if workers in the same batch are calculated with different effective rates. The system must enforce: rule activation changes only take effect on runs that start after the activation event.
