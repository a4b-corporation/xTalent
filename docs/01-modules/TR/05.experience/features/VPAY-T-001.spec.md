# VPAY-T-001 — Bonus Calculation Run & Approval

**Type**: Transaction | **Priority**: P0 | **BC**: BC-03 Variable Pay
**Country**: [All countries]

---

## Purpose

Executes bonus calculation for all eligible Workers under a BonusPlan for a given period, applies performance modifiers from the PM module, routes results through an approval workflow, and upon approval creates a BonusStatement marked SCHEDULED for payment. Taxable bonuses automatically create TaxableItems via Taxable Bridge — no manual step.

---

## Trigger

1. Payroll Admin or Compensation Admin manually initiates "Run Bonus Calculation"
2. Or scheduled trigger at end of performance cycle

---

## Actors

| Actor | Role |
|-------|------|
| Compensation Admin | Initiates calculation run; monitors results |
| System | Fetches performance ratings; applies modifiers; calculates amounts |
| Director / VP (Finance Approver) | Reviews and approves BonusStatements |
| Worker | Passive — notified on approval |
| BC-08 Taxable Bridge | Creates TaxableItem for taxable bonuses |

---

## State Machine

```
BonusStatement:
DRAFT → CALCULATED → PENDING_APPROVAL → APPROVED → SCHEDULED → PAID
                                      └→ REJECTED → RECALCULATED
```

---

## Step-by-Step Flow

### Phase 1: Initiate & Calculate
1. Compensation Admin: navigate to Variable Pay → Bonus → select BonusPlan → "Run Calculation"
2. Select period (e.g., FY2026), confirm eligible Worker count
3. System fetches eligible Workers (matching grade/job_family, active WorkingRelationship)
4. For each Worker:
   a. Get `annual_base_salary` from current SalaryRecord
   b. Fetch `PerformanceRating` from PM module (by worker_id + performance_cycle)
   c. Look up `PerformanceModifier.multiplier` from BonusPlan mapping
   d. `target_bonus = annual_base_salary × target_pct_of_salary`
   e. `final_amount = target_bonus × performance_modifier`
   f. If `final_amount > max_bonus`: cap at max; set `is_capped = true`
   g. Create `BonusStatement` (status = CALCULATED)
5. Display results table; Admin reviews

### Phase 2: Approval
6. Admin submits for approval
7. System routes to approver based on `approval_threshold_pct`:
   - Below threshold: Director approval
   - Above threshold: VP / Finance Approver
8. Approver reviews table (all statements); can approve all or individual
9. On ApproveAll → all statements → APPROVED → SCHEDULED
10. On Reject(Worker) → statement → REJECTED; Admin can recalculate that Worker

### Phase 3: Payment Trigger
11. On APPROVED + payment date reached: status → PAID
12. `BonusApproved` event → BC-08 Taxable Bridge → `TaxableItem` created (if `is_taxable = true`)
13. Payroll bridge picks up TaxableItem for net pay calculation
14. Idempotency key: `worker_id + plan_id + period` — prevents double payment

---

## Results View

| Column | Description |
|--------|-------------|
| Worker | Name + ID |
| Grade | Current grade |
| Base Salary | Annual gross |
| Target Bonus | base × target_pct |
| Performance Rating | From PM module |
| Modifier | Applied multiplier |
| Final Bonus | target × modifier |
| Capped? | Yes if hit max |
| Status | CALCULATED / APPROVED / REJECTED |

Actions per row: View detail, Override (with justification + approval), Reject

**Bulk actions**: Approve all, Export to Excel

---

## Missing Performance Rating Handling

If Worker has no PerformanceRating in PM module:
- Options (configurable per BonusPlan):
  1. `SKIP` — exclude Worker from run (default)
  2. `USE_DEFAULT` — apply modifier for "MEETS_EXPECTATIONS" rating
  3. `HOLD` — include with status PENDING_RATING; process after rating available
- Setting shown in BonusPlan configuration

---

## Validation Rules

| Rule | When | Error |
|------|------|-------|
| BonusPlan must be ACTIVE | On run | "Plan is inactive" |
| Period must not have existing APPROVED statements for same plan | On run | "Statements already approved for this period. Recalculate?" |
| Worker must have active WorkingRelationship in period | Per Worker | Worker skipped |

---

## Notifications

| Event | Recipients | Channel |
|-------|-----------|---------|
| Calculation run complete | Compensation Admin | In-app |
| Pending approval | Approver(s) | In-app + Email |
| BonusApproved | Worker | In-app + Email |
| BonusRejected | Compensation Admin | In-app |

---

*VPAY-T-001 — Bonus Calculation Run & Approval*
*2026-03-27*
