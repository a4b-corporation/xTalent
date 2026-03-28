# Use Case Flow: Benefits Open Enrollment

> **Bounded Context**: BC-04 — Benefits Administration
> **Use Case**: Annual Open Enrollment for Worker Benefit Elections
> **Primary Actor**: Worker (elects benefits), HR Admin (configures & monitors)
> **Trigger**: HR Admin opens enrollment window for a BenefitPlan

---

## Flow Diagram

```
HR Admin              System                     Worker              BC-08 Taxable Bridge
    |                    |                          |                       |
[1] Configure            |                          |                       |
BenefitPlan &            |                          |                       |
open enrollment          |                          |                       |
    |────────────────────>|                          |                       |
    |           [2] EnrollmentWindowOpened          |                       |
    |                    |──── Notify workers ──────>|                       |
    |                    |                          |                       |
    |                    |         [3] Worker reviews available plans       |
    |                    |         and checks eligibility                   |
    |                    |                          |                       |
    |                    |         [4] Worker elects benefits:              |
    |                    |         ElectBenefit command                     |
    |                    |<─────────────────────────|                       |
    |                    |                          |                       |
    |           [5] Validate eligibility:           |                       |
    |           - Grade, employment type,           |                       |
    |             service length rules              |                       |
    |           - Dependent docs if family plan     |                       |
    |                    |                          |                       |
    |           [6] Create BenefitEnrollment        |                       |
    |           status = PENDING                    |                       |
    |                    |──── confirm ─────────────>|                       |
    |                    |                          |                       |
    |           [7] Worker may add Dependents       |                       |
    |           (AddDependent command)              |                       |
    |                    |                          |                       |
[8] HR Admin reviews     |                          |                       |
& closes window          |                          |                       |
    |────────────────────>|                          |                       |
    |           [9] Finalize enrollments:           |                       |
    |           PENDING → ACTIVE                    |                       |
    |           Calculate deduction amounts         |                       |
    |                    |                          |                       |
    |           [10] BenefitEnrolled event          |                       |
    |                    |──────────────────────────────────────────────────>|
    |                    |                          |     [11] If benefit   |
    |                    |                          |     has taxable value |
    |                    |                          |     → TaxableItem     |
    |                    |                          |     created           |
    |                    |                          |                       |
    |           [12] Sync enrollment to Carrier     |                       |
    |           (EDI 834)                           |                       |
```

---

## Steps Detail

### [1] Configure BenefitPlan + Open Enrollment

**Command**: `CreateBenefitPlan` + `OpenEnrollmentWindow`

**BenefitPlan configuration**:
```json
{
  "plan_id": "uuid",
  "plan_name": "Healthcare Gold 2026",
  "plan_type": "HEALTH",
  "carrier_id": "uuid",
  "enrollment_window_start": "2026-03-01",
  "enrollment_window_end": "2026-03-31",
  "effective_date": "2026-04-01",
  "eligibility_rules": {
    "min_service_months": 3,
    "employment_types": ["FULL_TIME", "PART_TIME"],
    "grade_min": "L2"
  },
  "employee_contribution_pct": 0.20,
  "employer_contribution_pct": 0.80,
  "allows_dependents": true,
  "dependent_verification_required": true
}
```

---

### [3] Worker Views Available Plans

Worker sees:
- Plan options they are eligible for (filtered by eligibility rules)
- Cost (employee contribution per month)
- Current enrollment (if any — for changes)
- Dependent slots available

**Eligibility check** (per Worker, per Plan):
```
eligible = (
  service_months >= plan.min_service_months
  AND employment_type IN plan.eligible_employment_types
  AND grade >= plan.min_grade
  AND NOT already_enrolled_in_plan (unless change window)
)
```

---

### [4–5] Elect Benefit

**Command**: `ElectBenefit`
**Inputs**:
```json
{
  "worker_id": "uuid",
  "plan_id": "uuid",
  "election_type": "NEW | CHANGE | WAIVE",
  "coverage_tier": "EMPLOYEE_ONLY | EMPLOYEE_PLUS_SPOUSE | FAMILY",
  "effective_date": "2026-04-01"
}
```

**Validation**:
- Worker is eligible for plan
- Enrollment window is open
- For FAMILY coverage: dependent docs required within 30 days
- One election per plan type per Worker (can change during window)

---

### [7] Add Dependents

**Command**: `AddDependent`
**Inputs**:
```json
{
  "worker_id": "uuid",
  "enrollment_id": "uuid",
  "dependent_name": "...",
  "relationship": "SPOUSE | CHILD | PARENT",
  "date_of_birth": "...",
  "document_type": "BIRTH_CERTIFICATE | MARRIAGE_CERTIFICATE",
  "document_ref": "..."
}
```

**Document verification**: Required for FAMILY plans. 30-day grace period.
If not verified within 30 days → dependent removed, coverage downgraded.

---

### [9–10] Enrollment Finalization

**On window close**:
```
For each PENDING BenefitEnrollment:
  1. Final eligibility re-check
  2. Calculate employee deduction:
       deduction_amount = plan.monthly_premium × employee_contribution_pct
  3. Create DeductionRecord (BC-01) for recurring deduction
  4. enrollment.status: PENDING → ACTIVE
  5. Emit BenefitEnrolled event
```

---

### [11] Taxable Bridge (Benefit in Kind)

**If plan has taxable benefit-in-kind component** (e.g., employer-paid life insurance above threshold):
```
TaxableItem created:
{
  worker_id: uuid,
  source_type: "BENEFIT_IN_KIND",
  source_ref_id: enrollment_id,
  amount: taxable_portion,
  currency: "VND",
  period: "2026-04",
  idempotency_key: "BEK-{enrollment_id}-2026-04"
}
```

---

### [12] Carrier EDI 834 Sync

**Method**: EDI 834 transaction set
**Pattern**: Webhook primary + 15-minute polling fallback (per INT-04)

**EDI 834 loop**:
```
For each ACTIVE enrollment (new/changed/terminated):
  Build EDI 834 transaction
  Submit to carrier webhook
  If success: enrollment.carrier_sync_status = SYNCED
  If failure: retry queue; alert HR Admin after 3 failures
```

---

## Lifecycle States

### BenefitEnrollment States
```
PENDING → ACTIVE → TERMINATED (end of employment or waive)
        └→ CANCELLED (window closed without finalizing)
        └→ DECLINED (eligibility check failed on close)
```

### Dependent Verification States
```
PENDING_VERIFICATION → VERIFIED → (included in coverage)
                    └→ REJECTED → (removed from coverage)
```

---

## Alternative Flows

### A1: Life Event Change (Outside Open Enrollment)
- Worker can elect/change benefits within 30 days of:
  - Marriage, divorce, birth/adoption, loss of other coverage
- Same `ElectBenefit` flow but triggered by `LifeEventChangeRequested`
- HR Admin approves life event first

### A2: Waive All Benefits
- Worker submits `ElectBenefit` with `election_type = WAIVE`
- All existing enrollments terminated at effective_date
- DeductionRecords cancelled

### A3: New Hire Auto-Enrollment
- System auto-enrolls new Worker in default plan (if configured)
- 30-day window to change elections
- If no action taken → auto-enrollment confirmed at end of window

---

## Business Rules Applied

| Rule | Application |
|------|-------------|
| BR-C07 | Deduction priority: BenefitDeduction is managed via DeductionRecord priority ordering |
| (BC-04 specific) | Eligibility rules are configurable per plan — no hardcoded tiers |
| (BC-04 specific) | Carrier sync failure handling is configurable per enterprise |
| (BC-08) | Taxable benefit-in-kind → TaxableItem automatically, no manual step |

---

*Flow: Benefits Open Enrollment — BC-04 Benefits Administration*
*2026-03-26*
