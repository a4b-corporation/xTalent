# Use Case Flow: SI Contribution Calculation

> **Bounded Context**: BC-02 — Calculation Engine
> **Use Case**: Vietnam Social Insurance (BHXH/BHYT/BHTN) Calculation for Payroll Period
> **Primary Actor**: System (Payroll Run trigger)
> **Trigger**: Payroll run initiated for period YYYY-MM

---

## Flow Diagram

```
Payroll Module          BC-01 Compensation          BC-02 Calculation Engine (VietnamSIEngine)
      |                        |                              |
 [1] Payroll run               |                              |
      |                        |                              |
      |────────────────────────>                              |
      |              [2] Invoke CalculationEnginePort         |
      |              for each eligible Worker                 |
      |                        |──────────────────────────>   |
      |                        |            [3] Resolve:      |
      |                        |            - Worker's        |
      |                        |              workplace_zone  |
      |                        |            - Effective SI    |
      |                        |              ContributionConfig|
      |                        |            - MinWageConfig   |
      |                        |              for zone        |
      |                        |                              |
      |                        |            [4] Cap check:   |
      |                        |            insurable_salary = |
      |                        |            min(salary, 20×  |
      |                        |            MinWage(zone))    |
      |                        |                              |
      |                        |            [5] Calculate:   |
      |                        |            BHXH employee =  |
      |                        |            insurable × 8%   |
      |                        |            BHXH employer =  |
      |                        |            insurable × 17.5%|
      |                        |            BHYT employee =  |
      |                        |            insurable × 1.5% |
      |                        |            BHYT employer =  |
      |                        |            insurable × 3%   |
      |                        |            BHTN employee =  |
      |                        |            insurable × 1%   |
      |                        |            BHTN employer =  |
      |                        |            insurable × 1%   |
      |                        |                              |
      |                        |            [6] Emit events  |
      |                        |            SIContributionCalculated|
      |                        |<─── Return ContributionAmount|
      |<── Return payroll data  |                              |
      |                        |                              |
      |            [7] If is_capped → SICapApplied event      |
      |                        |                              |
      |            [8] CalculationCompleted (all components)  |
      |                        |                              |
```

---

## Steps Detail

### [1] Trigger
**Source**: Payroll Module or BC-01 Compensation
**Pattern**: Sync call via `CalculationEnginePort`
**Input per Worker**:
```json
{
  "worker_id": "uuid",
  "working_relationship_id": "uuid",
  "period": "2026-03",
  "salary_amount": 30000000,
  "currency": "VND",
  "workplace_location": "Ho Chi Minh City"
}
```

---

### [3] Config Resolution

**3a. Resolve WageZone from workplace_location**
- `Ho Chi Minh City` → `VN_ZONE_I`
- Zone mapping configurable in MinWageConfig

**3b. Resolve active ContributionConfig**
```
SELECT * FROM contribution_config
WHERE country_code = 'VN'
  AND contribution_type IN ('BHXH', 'BHYT', 'BHTN')
  AND is_current = true
  AND (legal_entity_id = worker.le_id OR legal_entity_id IS NULL)
ORDER BY legal_entity_id NULLS LAST   -- LE-specific wins
LIMIT 1 per contribution_type
```

**3c. Resolve MinWageConfig for zone**
```
SELECT monthly_min_wage FROM min_wage_config
WHERE country_code = 'VN'
  AND zone = 'VN_ZONE_I'
  AND is_current = true
```

---

### [4] SI Cap Application (BR-K02 + BR-K03)

```
cap_amount = 20 × MinWage(VN_ZONE_I)
           = 20 × 4,960,000 VND  (example 2026 Zone I rate)
           = 99,200,000 VND

insurable_salary = min(salary, cap_amount)
                 = min(30,000,000, 99,200,000)
                 = 30,000,000 VND  (not capped in this example)

is_capped = (salary > cap_amount)  → false in this example
```

**Zone change timing rule (BR-K03)**:
- If `WorkingRelationship.workplace_location` changed this month
- New cap applies from **NEXT MONTH** — use previous zone cap for current period

---

### [5] Contribution Calculation

Using rates from `ContributionConfig` (configurable, not hardcoded):

| Component | Employee | Employer |
|-----------|----------|----------|
| BHXH | 8% | 17.5% |
| BHYT | 1.5% | 3% |
| BHTN | 1% | 1% |
| **Total** | **10.5%** | **21.5%** |

```
For each contribution_type:
  employee_amount = insurable_salary × employee_rate
  employer_amount = insurable_salary × employer_rate
```

**Result per type**:
```json
{
  "BHXH": {
    "employee_share": 2400000,
    "employer_share": 5250000,
    "is_capped": false
  },
  "BHYT": {
    "employee_share": 450000,
    "employer_share": 900000,
    "is_capped": false
  },
  "BHTN": {
    "employee_share": 300000,
    "employer_share": 300000,
    "is_capped": false
  }
}
```

---

### [6] Events Emitted

**`SIContributionCalculated`**:
```json
{
  "worker_id": "uuid",
  "period": "2026-03",
  "country": "VN",
  "contributions": [...],
  "insurable_salary": 30000000,
  "cap_applied": false,
  "rule_version_used": 3,
  "calculation_rule_id": "uuid"
}
```

**`SICapApplied`** (only if `is_capped = true`):
```json
{
  "worker_id": "uuid",
  "period": "2026-03",
  "actual_salary": 120000000,
  "cap_amount": 99200000,
  "zone": "VN_ZONE_I"
}
```

---

### [8] Historical Recalculation (BR-K06)

When recalculating past periods:
```
SELECT * FROM calculation_rule
WHERE rule_type = 'SI_CONTRIBUTION'
  AND effective_start_date <= period_start
  AND (effective_end_date IS NULL OR effective_end_date >= period_end)
  AND country_code = 'VN'
ORDER BY version_number DESC
LIMIT 1
```
**Must NOT use current rule** — use rule version that was effective during the historical period.

---

## Plugin Architecture

```
CalculationEnginePort.calculateSI(request)
  → VietnamSIEngine (Phase 1 — implemented)
      reads: ContributionConfig (VN)
      reads: MinWageConfig (VN, zone)
      applies: 4-zone cap logic
      emits: SIContributionCalculated

  → SingaporeCPFEngine (Phase 2)
  → MalaysiaEPFEngine (Phase 2)
  → IndonesiaBPJSEngine (Phase 2)
  → PhilippinesSSSEngine (Phase 2)
```

Each engine implements `CountryContributionEngine` interface:
```
interface CountryContributionEngine {
  supports(country_code: string): boolean
  calculate(request: SIRequest): ContributionAmount[]
}
```

**HR SME configures data (rates, caps, dates) via Admin UI — no code deployment needed.**

---

## Business Rules Applied

| Rule | Application |
|------|-------------|
| BR-K02 | SI cap = min(salary, 20× MinWage(zone)) at step [4] |
| BR-K03 | Zone change → new cap from NEXT MONTH at step [4] |
| BR-K06 | Historical recalculation uses rule version effective at that time at step [8] |
| BR-K07 | Plugin interface enforced — HR SME config only, no code deploy |

---

*Flow: SI Contribution Calculation — BC-02 Calculation Engine*
*2026-03-26*
