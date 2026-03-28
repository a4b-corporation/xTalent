# CALC-T-001 — SI Contribution Calculation Run

**Type**: Transaction | **Priority**: P0 | **BC**: BC-02 Calculation Engine
**Country**: [VN Phase 1 — other countries Phase 2]

---

## Purpose

Executes the social insurance contribution calculation for all Workers in a payroll period. Invoked by Payroll Module (or directly by HR Admin for preview). Uses the pluggable `CountryContributionEngine` — VietnamSIEngine for Phase 1. Results feed payroll deductions. HR Admin can view per-Worker breakdown; anomalies are flagged for review.

---

## Trigger

1. **Automatic**: Payroll run initiated for period YYYY-MM
2. **Manual preview**: HR Admin runs "Calculate SI Preview" for a period before payroll lock

---

## Actors

| Actor | Role |
|-------|------|
| Payroll Module | Primary trigger (sync API call) |
| HR Admin | Can trigger preview; reviews results |
| System (VietnamSIEngine) | Executes calculation |
| Tax Admin | Reviews discrepancies |

---

## State Machine

```
INITIATED → IN_PROGRESS → COMPLETED → REVIEWED
                       └→ FAILED (engine error)
                       └→PARTIAL (some Workers failed)
```

---

## Step-by-Step Flow

### Automatic (Payroll Run)
1. Payroll Module calls `POST /calculation/si-contributions/calculate` with `{period, legal_entity_id}`
2. System resolves eligible Workers (WorkingRelationship active in period, country=VN)
3. For each Worker:
   a. Resolve `workplace_zone` from `WorkingRelationship.workplace_location`
   b. Look up active `ContributionConfig` (country=VN, type=BHXH/BHYT/BHTN, effective in period)
   c. Look up `MinWageConfig` for zone (effective in period)
   d. Compute `insurable_salary = min(gross_salary, 20 × min_wage)`
   e. Calculate: BHXH employee = insurable × 8%, employer = insurable × 17.5%; BHYT/BHTN similarly
   f. If `insurable_salary < gross_salary` → `is_capped = true`; emit `SICapApplied`
   g. Store `SIContributionResult` per Worker per type
4. Emit `SIContributionCalculated` per Worker
5. Emit `CalculationCompleted` when all Workers done
6. Return summary to Payroll Module

### Manual Preview (HR Admin)
1. HR Admin navigates to: Compensation → Calculation → SI Contribution Preview
2. Selects period + LegalEntity
3. Clicks "Run Preview"
4. Results shown in table (not committed to payroll)
5. Can export to Excel for review

---

## Results View (HR Admin)

| Column | Description |
|--------|-------------|
| Worker Name | Worker full name |
| Employee ID | xTalent Worker ID |
| Workplace Zone | VN Zone I/II/III/IV |
| Gross Salary | Monthly gross |
| Insurable Salary | After cap (= gross if not capped) |
| Capped? | Yes/No — badge |
| BHXH Employee | Amount |
| BHXH Employer | Amount |
| BHYT Employee | Amount |
| BHYT Employer | Amount |
| BHTN Employee | Amount |
| BHTN Employer | Amount |
| Total Employee | Sum |
| Total Employer | Sum |

**Filters**: Zone, LegalEntity, Capped only, Sort by amount.
**Export**: Excel / CSV

---

## Anomaly Detection

System flags:
- Workers with `is_capped = true` (salary > 20× min wage) — shown with orange badge
- Workers with contribution significantly different from previous period (> 20% change) — yellow flag
- Workers missing `workplace_location` — error badge, calculation skipped

---

## Historical Recalculation

When recalculating a past period (e.g., after ContributionConfig correction):
- System uses `CalculationRule` version effective **during that period** (BR-K06)
- Never uses current rates for historical periods
- Recalculation creates new results, previous results archived

---

## Validations

| Rule | When | Error |
|------|------|-------|
| Period must not be future | On trigger | "Cannot calculate SI for future period" |
| ContributionConfig must exist for period | On calculate | "No contribution config found for VN BHXH in period 2026-03. Contact Tax Admin." |
| MinWageConfig must exist for zone | On calculate | "No min wage config for VN Zone I effective 2026-03. Contact Tax Admin." |
| Worker must have active WorkingRelationship in period | Per Worker | Worker skipped; logged as warning |

---

## Notifications

| Event | Recipients | Channel |
|-------|-----------|---------|
| CalculationCompleted | HR Admin, Payroll Admin | In-app |
| Worker calculation failed | HR Admin | In-app alert with Worker list |
| SICapApplied count > threshold | HR Admin | In-app summary |

---

*CALC-T-001 — SI Contribution Calculation Run*
*2026-03-27*
