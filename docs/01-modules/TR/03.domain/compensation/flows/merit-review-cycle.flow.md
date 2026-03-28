# Use Case Flow: Merit Review Cycle

> **Bounded Context**: BC-01 — Compensation Management
> **Use Case**: Annual/Periodic Merit Salary Review
> **Primary Actor**: People Manager, Compensation Admin, Budget Approver
> **Trigger**: Compensation Admin opens a CompensationCycle

---

## Flow Diagram

```
Compensation Admin          People Manager             System                    Budget Approver
       |                          |                       |                            |
  [1] OpenCompensationCycle       |                       |                            |
       |──────────────────────────────────────────────>   |                            |
       |                          |           CompensationCycleOpened published        |
       |                          |<─────────────────────[2] Kafka notify              |
       |                          |                       |                            |
       |                    [3] Review eligible           |                            |
       |                    Workers & current             |                            |
       |                    salary/compa-ratio            |                            |
       |                          |                       |                            |
       |                    [4] SubmitMeritRecommendation |                            |
       |                          |──────────────────────>|                            |
       |                          |               [5] Validate:                        |
       |                          |               - Cycle OPEN?                        |
       |                          |               - MinWage check                      |
       |                          |               - Budget remaining?                  |
       |                          |               [6] budget_remaining -= proposal     |
       |                          |                       |                            |
       |                          |<── MeritRecommendationSubmitted                   |
       |                          |                       |──────────────────────────> |
       |                          |              [7] Route to Approver based on %     |
       |                          |              change_pct < 5%: auto-approve        |
       |                          |              5-10%: Director                      |
       |                          |              >10%: VP                             |
       |                          |                       |                            |
       |                          |                       |              [8] Review    |
       |                          |                       |                   proposal |
       |                          |                       |                            |
       |                          |          [9a] ApproveCompensation ─────────────── |
       |                          |                       |<─────────────── OR         |
       |                          |          [9b] RejectCompensation                  |
       |                          |                       |                            |
       |                          |            [10a] On Approve:                      |
       |                          |            ScheduleSalaryChange (effective date)  |
       |                          |            CompensationApproved published         |
       |                          |                       |                            |
       |                          |            [10b] On Reject:                       |
       |                          |            budget_remaining += proposal amount    |
       |                          |            CompensationRejected published         |
       |                          |                       |                            |
       |                    [11] SalaryEffectiveDateReached (cron)                    |
       |                          |                       |                            |
       |                          |            [12] ActivateSalaryChange              |
       |                          |            - Close previous SalaryRecord          |
       |                          |            - Insert new SalaryRecord (SCD Type 2) |
       |                          |            - SalaryHistoryArchived published       |
       |                          |            - Forward to BC-08 Taxable Bridge      |
       |                          |                       |                            |
  [13] CloseCompensationCycle     |                       |                            |
       |──────────────────────────────────────────────>   |                            |
```

---

## Steps Detail

### [1] OpenCompensationCycle
**Actor**: Compensation Admin
**Command**: `OpenCompensationCycle`
**Inputs**:
- `name`: cycle name (e.g., "Merit Review 2026")
- `cycle_year`: 2026
- `budget_amount`: {amount, currency}
- `eligible_worker_ids`: list of Workers
- `scope_id`: optional LE/BU scope

**Validations**:
- No overlapping open cycle for same scope
- Budget > 0
- At least 1 eligible Worker

**Outputs**: `CompensationCycleOpened` event

---

### [2] Manager Notification
**System**: Kafka publish `CompensationCycleOpened`
**Subscribed by**: PM Manager notification service
**Data available to Manager**:
- Direct reports in eligible list
- Current `SalaryRecord` per Worker
- `CompaRatio` (actual / midpoint of `PayRange`)
- Budget guidance per Worker (if configured)

---

### [3–4] Submit Merit Recommendation
**Actor**: People Manager
**Command**: `SubmitMeritRecommendation`
**Inputs**:
- `cycle_id`
- `worker_id`
- `proposed_salary`: {amount, currency}
- `change_type`: MERIT_INCREASE | PROMOTION | MARKET_ADJUSTMENT
- `justification`
- `effective_date`

**System Validations (hard blocks)**:
- `Cycle.status == OPEN` → error "Cycle not open for submissions"
- `proposed_salary >= MinWage(worker.workplace_zone)` → error "MinimumWageViolated"
- `proposed_salary <= PayRange.max(worker.grade)` (soft warning, not block by default)
- `budget_remaining >= (proposed - current)` (soft warning at < 5% remaining)

**Side effect**: `budget_remaining -= (proposed - current)` (provisional hold)

**Output**: `MeritRecommendationSubmitted`

---

### [7] Approval Routing
**System**: Route based on `change_pct` (configurable thresholds per enterprise):

| change_pct | Approval Required |
|------------|-------------------|
| < 5% | Auto-approve |
| 5% – 10% | Director |
| > 10% | VP |

---

### [9] Approval Decision

**On `ApproveCompensation`**:
- `CompensationProposal.status` → APPROVED
- `ScheduleSalaryChange` with `effective_date`
- Publish `CompensationApproved`

**On `RejectCompensation`**:
- `CompensationProposal.status` → REJECTED
- `budget_remaining` += provisional hold amount (restore)
- Publish `CompensationRejected` with reason

---

### [11–12] Salary Activation (Cron)
**Trigger**: Daily cron — check `SalaryEffectiveDateReached`
**Command**: `ActivateSalaryChange`

**SCD Type 2 operation**:
```
BEGIN TRANSACTION
  UPDATE SalaryRecord SET effective_end_date = effective_date - 1, is_current = false
    WHERE worker_id = ? AND is_current = true

  INSERT SalaryRecord (
    worker_id, working_relationship_id, salary_basis_id,
    gross_amount, components, effective_start_date = effective_date,
    effective_end_date = NULL, is_current = true,
    change_reason, cycle_id, proposal_id, audit_id
  )

  PUBLISH SalaryHistoryArchived
  PUBLISH SalaryChanged → BC-08 Taxable Bridge
COMMIT
```

---

## Alternative Flows

### A1: Manager Withdraws Proposal
- Manager calls `WithdrawProposal` when status = PENDING_APPROVAL
- `budget_remaining` restored
- Publish `CompensationRejected` (system-initiated)

### A2: Cycle Cancelled
- Compensation Admin calls cancel
- All PENDING_APPROVAL proposals → WITHDRAWN
- All provisional budget holds restored
- Cycle → CLOSED

### A3: Pay Equity Analysis
- System scheduled analysis on closed cycles
- Detect `PayEquityGapDetected` when CompaRatio gap > configured threshold
- Non-blocking: alert only, not a block

---

## Business Rules Applied

| Rule | Application |
|------|-------------|
| BR-C01 | MinWage validation at step [4] — hard block |
| BR-C02 | Approval thresholds at step [7] — configurable |
| BR-C03 | SCD Type 2 at step [12] — INSERT + close, never UPDATE |
| BR-C04 | PayRange resolution: BU > LE > Country > Global |
| BR-C05 | budget_remaining real-time at step [4] (deduct) and [9b] (restore) |
| BR-C06 | Cycle must be OPEN to accept proposals at step [4] |

---

*Flow: Merit Review Cycle — BC-01 Compensation Management*
*2026-03-26*
