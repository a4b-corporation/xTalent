# Use Case Flow: Minimum Wage Validation

> **Bounded Context**: BC-01 — Compensation Management (validation) / BC-02 — Calculation Engine (data)
> **Use Case**: Hard-Block Validation of Salary Against Statutory Minimum Wage
> **Primary Actor**: System (validation gate on salary create/update)
> **Trigger**: Any salary create, update, or proposal that sets a new salary amount

---

## Flow Diagram

```
Actor (Manager/Admin/System)     BC-01 Compensation          BC-02 Calculation Engine
            |                           |                              |
 [1] Submit salary command              |                              |
 (CreateSalaryRecord /                  |                              |
  SubmitMeritRecommendation /           |                              |
  OfferRecord validation)              |                              |
            |──────────────────────────>|                              |
            |                  [2] Extract validation inputs:         |
            |                  - proposed_amount                      |
            |                  - currency                             |
            |                  - worker_id                            |
            |                  - effective_date                       |
            |                          |                              |
            |                  [3] Resolve Worker's                   |
            |                  workplace_zone                         |
            |                  via WorkingRelationship                |
            |                          |                              |
            |                  [4] CallMinWagePort ──────────────────>|
            |                          |              [5] Lookup:     |
            |                          |              MinWageConfig   |
            |                          |              (country, zone, |
            |                          |              effective_date) |
            |                          |<─────────────────────────────|
            |                          |              return min_wage |
            |                  [6] Convert to same currency           |
            |                  if needed (FX via BC-02)               |
            |                          |                              |
            |                  [7] Compare:                           |
            |                  proposed >= min_wage?                  |
            |                          |                              |
       [8a] PASS: continue flow        |                              |
            |<─────────────────────────|                              |
            |                          |                              |
       [8b] FAIL: MinimumWageViolated  |                              |
       event emitted; command rejected |                              |
       with error message              |                              |
            |<─────────────────────────|                              |
```

---

## Steps Detail

### [2] Extract Validation Context

This validation is triggered by:
| Command | Context |
|---------|---------|
| `SubmitMeritRecommendation` | `proposed_salary` |
| `CreateSalaryRecord` (direct) | `gross_amount` |
| `ActivateSalaryChange` | `new_amount` at effective_date |
| `CreateOfferRecord` (BC-06) | `offered_salary` |

---

### [3] Zone Resolution

```
worker → WorkingRelationship → workplace_location → WageZone

Mapping (Vietnam example):
  Ho Chi Minh City (Quận 1–12, Bình Thạnh...) → VN_ZONE_I
  Hà Nội (Hoàn Kiếm, Đống Đa, Ba Đình...)    → VN_ZONE_I
  Đà Nẵng                                     → VN_ZONE_II
  Tỉnh Bình Dương                             → VN_ZONE_II
  ...
```

**Effective date awareness**: Use `workplace_location` as of `effective_date`, not today.
If Worker moves zone after effective_date, use new zone for future months.

---

### [5] MinWageConfig Lookup

```sql
SELECT monthly_min_wage, currency
FROM min_wage_config
WHERE country_code = 'VN'
  AND zone = 'VN_ZONE_I'
  AND effective_start_date <= :effective_date
  AND (effective_end_date IS NULL OR effective_end_date >= :effective_date)
  AND is_current = true
ORDER BY effective_start_date DESC
LIMIT 1
```

**If no record found**: System error — MinWageConfig not configured for zone.

---

### [6] Currency Normalization

```
If proposed_salary.currency != min_wage.currency:
  min_wage_in_proposal_currency = min_wage × FxRate(min_wage.currency → proposal.currency, effective_date)

Example:
  Offer for expat in VND: min_wage = 4,960,000 VND → no conversion needed
  Offer in USD: min_wage_usd = 4,960,000 / FxRate(VND/USD)
```

---

### [7] Comparison

```
IF proposed_amount >= min_wage_normalized:
  → PASS: proceed with command

IF proposed_amount < min_wage_normalized:
  → FAIL: emit MinimumWageViolated
  → Return error:
    {
      "code": "MINIMUM_WAGE_VIOLATED",
      "proposed": {amount, currency},
      "minimum_required": {amount, currency},
      "zone": "VN_ZONE_I",
      "regulatory_ref": "Nghị định 74/2024/NĐ-CP"
    }
```

**This is a HARD BLOCK (BR-C01)** — no override workflow, no exception path.
No salary can be set below minimum wage without an explicit exception workflow
(which is NOT implemented in Phase 1 — by design).

---

## Event: MinimumWageViolated

```json
{
  "event_type": "MinimumWageViolated",
  "worker_id": "uuid",
  "proposed_amount": 3000000,
  "proposed_currency": "VND",
  "minimum_required": 4960000,
  "minimum_currency": "VND",
  "zone": "VN_ZONE_I",
  "effective_date": "2026-04-01",
  "triggered_by_command": "SubmitMeritRecommendation",
  "actor_id": "uuid",
  "timestamp": "2026-03-26T10:00:00Z"
}
```

Published to:
- Audit log (BC-10)
- Notification to actor

---

## Alternative Flows

### A1: Minimum Wage Update (Government Decree)
**Trigger**: Tax Admin updates MinWageConfig

```
[1] Tax Admin: UpdateMinWage command
[2] Insert new MinWageConfig row (SCD Type 2) with new effective_date
[3] Previous row: effective_end_date = new_effective_date - 1, is_current = false
[4] System: MinWageUpdated event emitted
[5] Alert: all workers in that zone with salary < new minimum
[6] Compensation Admin: runs analysis report
[7] Remediation: submit CompensationProposal for affected Workers before effective date
```

### A2: Pre-Hire Validation in Offer Management
- BC-06 Offer Management calls BC-01 MinWage validation before offer letter generation
- Same validation logic reused — no duplication

---

## Business Rules Applied

| Rule | Application |
|------|-------------|
| BR-C01 | Hard block at step [7] — no exception without explicit workflow |
| BR-K02 | SI cap uses same zone from same MinWageConfig (different consumer, same data) |
| BR-K03 | Zone change timing: new zone applies next month for SI cap; min wage validation uses effective_date zone |

---

*Flow: Minimum Wage Validation — BC-01/BC-02 Compensation & Calculation Engine*
*2026-03-26*
