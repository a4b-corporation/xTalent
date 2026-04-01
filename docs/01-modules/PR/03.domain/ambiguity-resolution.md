# Domain Architecture — Ambiguity Resolution

**Module**: Payroll (PR)
**Step**: 3 — Domain Architecture
**Date**: 2026-03-31
**Version**: 1.0

---

## Summary

This document records open questions and decisions made during Step 3 domain modeling. Items marked **Blocking** must be resolved before Step 4 (Solution Architecture) begins.

---

## Open Questions

| ID | Bounded Context | Question | Decision | Status | Priority |
|----|-----------------|----------|----------|--------|----------|
| AQ-D1 | BC-01 Pay Master | When a PayProfile has both `parent_profile_id` inheritance AND explicit element bindings, which takes precedence for the same element_code? | Child profile explicit bindings always override parent bindings. Inheritance is a default-only mechanism. Computed at run-time by BC-03, not stored. | Resolved | P0 |
| AQ-D2 | BC-03 Payroll Execution | How does BC-03 handle concurrent SIMULATION + PRODUCTION runs for the same PayPeriod? | Only one PRODUCTION run can exist in QUEUED/RUNNING state per period per pay_group. SIMULATION runs are unlimited and isolated. Enforced via database-level unique constraint on (period_id, pay_group_id, run_mode=PRODUCTION, status IN [QUEUED, RUNNING]). | Resolved | P0 |
| AQ-D3 | BC-02 Statutory Rules | `StatutoryRule` has `legal_entity_id` for overrides. What is the precedence when both a global rule (legal_entity_id = NULL) and a company-specific override exist for the same rule_type + valid_from? | Company-specific override (legal_entity_id IS NOT NULL) takes precedence over global rule for the same rule_type + effective date. Lookup order: specific → global. | Resolved | P0 |
| AQ-D4 | BC-03 Payroll Execution | How is the 183-day PIT residency threshold tracked mid-year? Who owns the residency status recalculation trigger? | `CompensationSnapshot` stores `tax_residency_status` (RESIDENT/NON_RESIDENT) as of cut-off date. When a worker crosses 183 days, CO updates the working_relationship residency flag; next CompensationSnapshot reflects the new status. Retroactive recalculation for prior periods is triggered as a RETRO_ADJUSTMENT type = RESIDENCY_CHANGE. Step 4 must define the RETRO_ADJUSTMENT chain for this case (HS-6). | Partially Resolved — HS-6 chain design deferred to Step 4 | P0 |
| AQ-D5 | BC-01 Pay Master | `PayCalendar` is listed as a BC-01 aggregate, but TA owns the holiday_calendar. What does PayCalendar own that TA does not? | PayCalendar owns the **payroll schedule**: period_start, period_end, cut_off_date, payment_date for each pay period. TA owns the **working day calendar**: public holidays, special working days affecting OT rates. PR reads TA holiday data via OHS; PayCalendar does NOT replicate it. | Resolved | P1 |
| AQ-D6 | BC-03 Payroll Execution | TASK_BASED pay method appears in pay_method enum but has no corresponding flow (UCF). Is it in V1 scope? | TASK_BASED is enum-declared (not removed) to avoid future migration cost, but UCF is not defined in Step 3. `run_type = TASK_PAYMENT` exists in RunTypeEnum. Payroll Admin cannot initiate TASK_PAYMENT runs in V1 UI. Step 5 (Experience) must gate this from UI. | Resolved — deferred to V2 | P1 |
| AQ-D7 | BC-04 Payment Output | `BankPaymentFile` aggregates per-run or per-worker? If one worker's bank file fails, does the whole file fail? | BankPaymentFile aggregates all net-positive workers in a run into a single file per bank per legal entity. Individual worker failures are recorded as `BankPaymentItemStatus`. V1: file-level reject from bank = all workers in file are UNCONFIRMED. V2: per-item status via API. | Resolved | P1 |
| AQ-D8 | BC-07 Audit Trail | Does AuditLog need to capture all field-level changes (before/after values) or only state transitions? | Both. State transitions (OPEN → CUT_OFF, QUEUED → RUNNING) are captured as `event_type = STATE_CHANGE`. Field-level changes on configuration entities (PayProfile, PayElement, StatutoryRule) are captured as `event_type = FIELD_UPDATE` with before/after JSON. | Resolved | P1 |
| AQ-D9 | BC-05 Statutory Reporting | PIT Form 05/QTT-TNCN (annual settlement) is generated per individual worker or as a batch export? | Batch export per legal entity per year, plus individual certificate download per worker via BC-06 (PitCertificateRequest). Both are generated from the same underlying data in BC-05. | Resolved | P1 |
| AQ-D10 | BC-03 Payroll Execution | When a RetroactiveAdjustment spans multiple past periods, is the delta applied as one lump sum in the target period or split across periods? | Lump sum in the first open period after the retro change is approved. The delta is the sum of all affected-period deltas. Per-period breakdown is stored in RetroactiveAdjustment.period_breakdown_json for audit. | Resolved | P1 |

---

## Decisions Made

### DEC-D1: PayProfile Polymorphism — Separate Config per Pay Method
**Context**: PayProfile supports 5 pay methods. HOURLY requires `hourly_rate_config`, PIECE_RATE requires `piece_rate_table`, GRADE_STEP requires `pay_scale_table`. These configs are structurally different.

**Decision**: PayProfile has a `pay_method` discriminator enum. Variant configurations are stored as separate child entities (`HourlyRateConfig`, `PieceRateTable`, `PayScaleTable`) linked by `pay_profile_id`. Only the relevant config is populated per pay method. MONTHLY_SALARY and TASK_BASED use the base `base_salary_config` on PayProfile itself.

**Rationale**: Avoids nullable polymorphic columns and ensures schema clarity per pay method. Aligns with xTalent's existing DBML pattern of separate config tables.

**Impact**: BC-01 LinkML schema defines 3 additional classes. BC-03 Payroll Execution must select the correct config class based on `pay_method` at calculation time.

---

### DEC-D2: Negative Net Salary — Domain Model Approach
**Context**: HS-3 — net salary can compute negative (large salary advance deduction + PIT on bonus). The resolution workflow was undefined in Step 2.

**Decision**: 
1. Net < 0 triggers `NEGATIVE_NET` exception on `PayrollException` (blocks approval).
2. Payroll Admin acknowledges with one of: `ZERO_NET_WITH_RECOVERY` (set to 0; excess recorded as deduction_carried_forward) or `SET_TO_ZERO` (absorb by company; requires Finance Manager co-approval).
3. `deduction_carried_forward` is stored on `PayrollResult` and becomes an input to the next period's deduction calculation.
4. Domain model: `PayrollResult.deduction_carried_forward` slot added.

**Rationale**: Matches standard Vietnamese payroll practice. Avoids negative bank transfer amounts.

**Impact**: PayrollResult LinkML schema updated with `deduction_carried_forward` slot. UCF-01 flow updated to include negative net handling.

---

### DEC-D3: HS-5 Performance — Domain Model Partitioning Strategy
**Context**: PayrollRun must process 1,000 workers < 30 seconds (SO-03). Drools 8 parallel KieSessions are the planned engine.

**Decision**: PayrollRun domain model supports **partition-aware execution**:
1. `PayrollRun` tracks `batch_partitions_json` — list of partition configs used for this run
2. Each partition processes an independent subset of `working_relationship_id` values
3. `PayrollResult` records are fully independent — no cross-worker dependencies in the domain model
4. The only shared read-only state during execution: `CompensationSnapshot` (per-worker immutable) and `StatutoryRule` (shared read-only by all partitions)

**Rationale**: Eliminates sequential dependencies that would prevent parallelization. CompensationSnapshot immutability is the key design invariant that makes parallelization safe.

**Impact**: BC-03 LinkML schema has `batch_partitions_json` on PayrollRun. Step 4 (Solution Architecture) must design the Drools session partitioning and worker assignment strategy.

---

### DEC-D4: BC-01/BC-02 Strict Boundary — No TR Rules in PR
**Context**: HS-2 — risk that TR's `calculation_rule_def` entities leak into BC-01 via copy-paste or convenience.

**Decision**: 
1. BC-01 (Pay Master) models ONLY the HR-policy formula template: formula_type (enum), formula_expression (string), and configuration parameters. It does NOT store the result of any computation.
2. BC-02 (Statutory Rules) models ONLY regulatory rates, thresholds, brackets. No HR-policy rules.
3. During code review, any PR import of a TR entity type into BC-01 or BC-02 is an automatic reject.
4. Integration test: BC-03 calculation engine must be able to compute gross-to-net using ONLY CompensationSnapshot + BC-01 PayProfile + BC-02 StatutoryRule — no live TR API call during calculation.

**Rationale**: Ensures payroll calculation is reproducible without live TR dependency. Mandatory for period-lock immutability guarantee.

**Impact**: Architecture constraint enforced in team working agreements and PR review checklist.

---

## Blocking Items for Step 4

| Item | Description | Owner |
|------|-------------|-------|
| HS-5 POC | Drools 8 performance POC with 1,000-worker load test is a hard gate before Step 4 finalizes the solution architecture for PayrollRun. | Tech Lead |
| HS-6 Retro Chain | RetroactiveAdjustment chain for 183-day PIT residency crossing requires Step 4 to define the async processing pattern (queue-based vs synchronous). | Domain Architect + Solution Architect |
| AQ-01 (from Step 1) | TR team must formally accept AQ-01 Decision D re-scoping before BC-01/BC-02 boundary is implemented. Confidence 0.75. | Product Owner + TR Team |
