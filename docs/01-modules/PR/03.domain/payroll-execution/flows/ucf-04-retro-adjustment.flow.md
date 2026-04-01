# UCF-04: Retroactive Salary Adjustment

**Bounded Context**: Payroll Execution (BC-03)
**Timeline**: T2/T3 — Triggered in any open period after a backdated compensation change
**Actors**: HR Manager (initiates in CO/TR module), Payroll Admin, System
**Trigger**: HR Manager applies a backdated compensation change in CO or TR (e.g., a salary increase effective 3 months ago), which causes a `CompensationChangeBackdated` event to be received by BC-03

---

## Preconditions

- At least one closed (LOCKED) PayPeriod exists for the worker in the retroactive window
- A current OPEN PayPeriod exists to receive the adjustment delta
- The backdated change does not exceed 12 closed periods back (BR-084)
- The PayrollRun for the target open period has not yet reached PENDING_APPROVAL state
- No concurrent retro run is in progress for the same worker (HS-7 lock check)
- Payroll Admin has the `RETRO_ADJUSTMENT_INITIATOR` permission

---

## Main Flow

| Step | Actor | Action | System Response |
|------|-------|--------|-----------------|
| 1 | HR Manager | Applies backdated compensation change in TR module | TR emits `CompensationChangeBackdated` event with: working_relationship_id, change_type (SALARY_CHANGE / ALLOWANCE_CHANGE / etc.), effective_from_date, old_value, new_value. BC-03 receives this event via event subscription. Emits `RetroAdjustmentRequested`. |
| 2 | System | Identify affected periods | System determines the set of locked PayPeriods affected: those with period_end ≥ effective_from_date that are in LOCKED state. Checks: count of affected periods ≤ 12 (BR-084). If > 12 periods, system caps at 12 and flags a warning for Payroll Admin to review manually. Emits `AffectedPeriodsIdentified` with period_id list. |
| 3 | System | Acquire concurrent run lock | System checks: is there already an in-progress retro adjustment for this working_relationship_id? (HS-7). If yes: new retro is queued until the current one completes. If no: system acquires the lock and proceeds. |
| 4 | System | Recalculate each affected period | For each affected locked period (in chronological order): system loads the original CompensationSnapshot for that period, applies the new compensation value, re-computes gross (per the pay_method), SI, PIT, and net using the StatutoryRule versions that were valid for that period's cut-off date. Produces revised_net for that period. delta = revised_net − original_net. Records delta per period. |
| 5 | System | Aggregate total delta | total_retro_delta = sum of per-period deltas. If total_retro_delta = 0 (no financial impact), system closes the adjustment as NO_IMPACT and no further action is needed. If total_retro_delta > 0 (underpayment): worker is owed money. If total_retro_delta < 0 (overpayment): worker owes money back. Emits `RetroAdjustmentCalculated` with delta breakdown. |
| 6 | System | Create RetroactiveAdjustment records | System creates one RetroactiveAdjustment entity per affected period, recording: original_net, revised_net, delta, period_id, statutory_rule_versions_used. These records are immutable and reference the original locked PayrollResult (which is NOT modified). |
| 7 | Payroll Admin | Reviews retro calculation in portal | Admin sees a retro adjustment summary: per-period delta table, total delta, proposed application period (next open period). Admin may accept the calculation or flag for HR Manager review. |
| 8 | HR Manager | Approves or rejects retroactive adjustment (BR-086) | If total_retro_delta > configurable threshold (e.g., 5,000,000 VND), HR Manager approval is required. HR Manager reviews and approves or rejects. |
| 9a | System (approved) | Applies retro delta to open period | System creates a RETRO_ADJUSTMENT PayElement entry in the next open period's PayrollRun (or the current open period if the run has not yet been initiated). The RETRO_ADJUSTMENT element carries: total_retro_delta, reference_adjustment_ids. Emits `RetroAdjustmentApplied`. Emits `AdjustmentAppliedToNextPeriod`. |
| 9b | System (negative delta / overpayment) | Creates deduction entry | If total_retro_delta < 0 (overpayment), a RETRO_RECOVERY deduction element is created in the open period. System checks: RETRO_RECOVERY amount must not cause NEGATIVE_NET in the target period (BR-063). If it would: splits recovery across multiple future periods or requires Finance Manager approval. |
| 10 | System | Release concurrent run lock | System releases the lock for this working_relationship_id. Queued retro adjustments (if any) are now processed. |

---

### Retro Delta Calculation Example

Worker: MONTHLY_SALARY, Region 1, 3 dependents, tax resident

Salary increase: from 20,000,000 VND to 22,000,000 VND
Effective from: 2025-08-01 (applied now in November 2025)

Affected closed periods: Aug 2025, Sep 2025, Oct 2025 (3 periods)

Per-period delta calculation (simplified, using Aug as example):
- Original Aug CompensationSnapshot: base_salary = 20,000,000
- Revised Aug gross: 22,000,000
- Original gross: 20,000,000
- Gross delta: +2,000,000

- SI basis delta: +2,000,000 (assuming no ceiling exceeded)
  - Employee SI delta: 2,000,000 × (8% + 1.5% + 1%) = 2,000,000 × 10.5% = +210,000
- PIT delta: (2,000,000 − 210,000) × applicable marginal rate (assume 10% bracket)
  = 1,790,000 × 10% = +179,000
- Net delta Aug: 2,000,000 − 210,000 − 179,000 = +1,611,000 VND

Same calculation for Sep and Oct: +1,611,000 each (assuming same statutory rules)
Total retro delta: 3 × 1,611,000 = +4,833,000 VND applied to Nov 2025 payroll as RETRO_ADJUSTMENT element.

---

## Alternate Flows

### AF-1: Adjustment Below Threshold — No Approval Required
- At step 8: total_retro_delta ≤ configured threshold (default 1,000,000 VND)
- System auto-approves; skips HR Manager approval step
- Payroll Admin's review in step 7 is still required (cannot be skipped)

### AF-2: Overpayment — Multi-Period Recovery
- At step 9b: RETRO_RECOVERY deduction would cause NEGATIVE_NET in target period
- System splits recovery: applies partial recovery each month until total is recovered
- Recovery schedule: max_recovery_per_period = min(configurable_cap, available_net)
- Finance Manager must approve the recovery schedule

### AF-3: Adjustment Spans a Statutory Rate Change
- At step 4: one or more affected periods have different StatutoryRule versions (e.g., SI ceiling changed during the window)
- System applies the StatutoryRule version that was valid at the original period's cut-off date for each period
- This means different effective rates per period in the delta calculation
- CalcLog records the specific StatutoryRule version_id used for each period

---

## Exception Flows

### EF-1: Retro Window Exceeds 12 Periods (BR-084)
- At step 2: effective_from_date is more than 12 closed periods ago
- System rejects the automatic retro calculation
- Flags: RETRO_WINDOW_EXCEEDED exception
- Payroll Admin is notified; manual calculation and correction run (CORRECTION type) required for periods beyond the window

### EF-2: Concurrent Retro Lock (HS-7)
- At step 3: another RetroactiveAdjustment is already in progress for the same working_relationship_id
- System queues the new request; does NOT process in parallel
- Queued requests are processed in FIFO order after the lock is released
- If the queue grows beyond 5 pending retros for one worker: alert Payroll Admin (probable data integrity issue)

### EF-3: Open Period PayrollRun Already in PENDING_APPROVAL
- At step 9a: the next open period's PayrollRun is already in PENDING_APPROVAL or APPROVED state
- System cannot inject the RETRO_ADJUSTMENT element into a run already submitted
- Two options: (a) reject the retro until the period locks and the subsequent period opens, or (b) HR Manager can pull back the approval (reject at Level 2), allow the injection, and resubmit
- System alerts Payroll Admin with both options

---

## Domain Events Emitted

| Event | Emitted At Step | Payload Key Fields |
|-------|-----------------|-------------------|
| RetroAdjustmentRequested | 1 | working_relationship_id, change_type, effective_from_date, old_value, new_value, source_event_id |
| AffectedPeriodsIdentified | 2 | working_relationship_id, affected_period_ids[], period_count, capped_at_12 (bool) |
| RetroAdjustmentCalculated | 5 | adjustment_id, working_relationship_id, period_deltas[{period_id, original_net, revised_net, delta}], total_retro_delta |
| RetroAdjustmentApproved | 8 | adjustment_id, approved_by, approved_at, approval_type (AUTO or MANUAL) |
| RetroAdjustmentApplied | 9a | adjustment_id, target_period_id, element_code, amount, applied_at |
| AdjustmentAppliedToNextPeriod | 9a | working_relationship_id, target_period_id, total_retro_delta, source_periods_count |

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-084 | Retroactive adjustment window: maximum 12 closed periods back |
| BR-085 | Original locked PayrollResult records are NOT modified; delta is applied as a new RETRO_ADJUSTMENT element in the open period |
| BR-086 | Retro adjustments above configured threshold require HR Manager approval |
| BR-087 | Period state check: retro delta can only be applied to a PayPeriod in OPEN or RUNNING state (not LOCKED or PENDING_APPROVAL) |

---

## Hot Spots / Risks

- HS-7: Concurrent run lock — Two simultaneous retro adjustments for the same worker (e.g., parallel salary and allowance changes backdated to the same period) must be serialized. The lock mechanism must be at the working_relationship_id level, not the period level.
- Statutory rule version accuracy — Retro calculations must use the StatutoryRule versions in effect at each original period's cut-off date. If StatutoryRule versions have been purged or the version history is incomplete, the retro calculation will be incorrect. StatutoryRule versioning must be immutable (no deletes).
