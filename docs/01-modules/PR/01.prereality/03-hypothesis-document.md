# Payroll Module — Hypothesis Document

**Artifact**: 03-hypothesis-document.md
**Module**: Payroll (PR)
**Date**: 2026-03-27
**Method**: Socratic Questioning, Assumption Decomposition, Confidence Calibration
**Target Ambiguity Score**: ≤ 0.2

---

## Overview

This document enumerates the critical hypotheses underlying the Payroll module design. Each hypothesis is scored for confidence (0.0 = pure assumption, 1.0 = verified fact). Hypotheses with confidence below 0.7 carry explicit kill criteria — the condition under which the hypothesis is falsified and the design must pivot.

**Ambiguity Score**: 0.17 (within gate G1 threshold of ≤ 0.2)

---

## H-001: Scope — Monthly Payroll Frequency Suffices for V1

**Hypothesis**: The majority of xTalent target customers in Vietnam run monthly payroll cycles. A V1 limited to MONTHLY frequency covers ≥ 90% of addressable use cases.

**Confidence**: 0.80

**Evidence**:
- Vietnamese Labor Code 45/2019/QH14, Article 94: wages may be paid monthly or more frequently by agreement. Monthly is the statutory default.
- Market surveys of HCM users in Vietnam (MISA, HRIS community) indicate 95%+ of white-collar employers use monthly cycles.
- The xTalent DBML V4 `pay_frequency` table carries a `frequency_type` enum — architecture supports future expansion.

**Kill Criteria**: If ≥ 2 signed xTalent customers require bi-weekly or semi-monthly payroll before V1 launch, this hypothesis is falsified and BIWEEKLY frequency becomes a V1 requirement.

**Risk if Wrong**: V1 cannot serve manufacturing, hospitality, and retail segments where bi-weekly pay is common.

**Validation Method**: Customer discovery interviews with first 5 xTalent pilot customers. Confirm their current payroll frequency before final scope lock.

---

## H-002: Architecture — PR Exclusively Owns Calculation Logic

**Hypothesis**: The Payroll module (PR) is the single system of record for all gross-to-net computation. The Total Rewards module (TR) provides compensation amounts (what to pay) but does not implement any tax, SI, or deduction formulas (how to calculate).

**Confidence**: 0.65

**Evidence**:
- Analysis document 03 (calculation-responsibility-split.md) recommends this split explicitly.
- The PR DBML V4 `pay_engine` schema and `statutory_rule` table are designed for full calculation ownership.
- TR's `calculation_rule_def` and `basis_calculation_rule` tables (DBML V5) constitute duplicate ownership — a known architectural conflict.

**Kill Criteria**: If the TR team presents a use case where compensation modeling (pre-payroll simulation in TR) requires the same computation logic and cannot share PR's engine via API, the strict ownership boundary may need to become a shared-engine model.

**Risk if Wrong**: Duplicate calculation logic in TR and PR diverges over time. A new Vietnam decree updates PR's SI rates but not TR's. Workers see different projected totals in TR vs. actual payslips from PR.

**Validation Method**: Architecture Decision Record (ADR) reviewed and signed by both TR and PR technical leads. ADR must be resolved before any implementation sprint begins. This is a pre-condition (P0 gate).

---

## H-003: Architecture — Drools 8 Rule Engine Meets Performance SLAs

**Hypothesis**: The Drools 8 + restricted MVEL + Business DSL architecture will process a batch of 10,000 workers in under 5 minutes in a production-grade environment, satisfying the stated payroll window SLA.

**Confidence**: 0.60

**Evidence**:
- Drools 8 KieSession parallelization benchmarks from Red Hat documentation indicate throughput of 2,000–5,000 rule evaluations/second on standard JVM configuration.
- The V4 DBML engine separation (pay_engine sub-module) enables independent deployment and horizontal scaling.
- Reference doc 06 (formula-engine-architecture.md) proposes parallel batch partitioning as the implementation approach.
- No actual benchmark has been run on xTalent infrastructure. This is a Tier 3 confidence level per the critical audit (02-critical-thinking-audit.md).

**Kill Criteria**: If a proof-of-concept load test on target infrastructure fails to process 1,000 workers in under 30 seconds (i.e., extrapolated 10,000 workers would exceed 5 minutes), the architecture requires optimization before V1 production use.

**Risk if Wrong**: Payroll batch exceeds overnight window; payment cannot be initiated on the next business day; workers receive late payment (labor law violation).

**Validation Method**: Mandatory performance POC during Phase 0 (Foundation). Test target: 1,000 synthetic workers with 20 pay elements, full PIT + SI calculation, in < 30 seconds on target deployment infrastructure.

---

## H-004: Regulatory — Vietnam 7-Bracket PIT Table Is Stable Through V1 Delivery

**Hypothesis**: The PIT 7-bracket schedule established under PIT Law 04/2007/QH12 as amended by Resolution 954/2020/UBTVQH14 will remain unchanged through the xTalent Payroll V1 launch window (2026–Q3 projected).

**Confidence**: 0.72

**Evidence**:
- The PIT table has remained structurally unchanged since 2012 (Law 26/2012/QH13), with only the personal/dependent deduction amounts updated in 2020.
- Vietnam Ministry of Finance consulted on PIT reform in 2023 but no draft amendment has reached the National Assembly as of March 2026.
- The `statutory_rule` table with `effective_date` management means any change can be handled as a data update, not a code change.

**Kill Criteria**: If a National Assembly resolution amending the PIT bracket schedule is published before the V1 payroll run date, the statutory_rule configuration must be updated before V1 deployment — but this is a configuration activity, not an architectural change.

**Risk if Wrong**: PIT brackets change during V1 development. If the brackets are hardcoded anywhere (not in statutory_rule), code changes and re-testing would be required mid-sprint.

**Validation Method**: Confirm at kick-off that all PIT brackets, deductions, and thresholds reside in `statutory_rule` records, not in formula text or application constants. Code review gate.

---

## H-005: Regulatory — SI Rates and Ceiling Formula Is Complete and Correct

**Hypothesis**: The SI framework documented in the research report (BHXH 8%/17.5%, BHYT 1.5%/3%, BHTN 1%/1%, ceiling = 20 × lương cơ sở = 46,800,000 VND as of July 2024) is accurate and sufficient for V1 compliance calculations.

**Confidence**: 0.88

**Evidence**:
- Decree 73/2024/NĐ-CP (effective July 1, 2024) confirms lương cơ sở at 2,340,000 VND/month.
- Social Insurance Law 58/2014/QH13 and amendments define the rate structure.
- Multiple Vietnamese payroll practitioners and BHXH circular references confirm these rates.
- Contract-type eligibility matrix (probation exempt, fixed-term eligible) is consistent across all reference documents.

**Kill Criteria**: If new legislative proposals for SI rate restructuring under the revised Social Insurance Law (Luật Bảo hiểm Xã hội revised edition) are enacted before V1 launch, rates must be updated in statutory_rule before the first production run.

**Risk if Wrong**: Under/over-contribution to BHXH. Employer faces penalties and worker's BHXH record is inaccurate.

**Validation Method**: Pre-launch review with a certified Vietnamese payroll accountant (kế toán tiền lương) who reviews statutory_rule data for all SI-related rules. Document sign-off.

---

## H-006: Integration — CO Module Provides Authoritative Worker Identity

**Hypothesis**: The Core HR (CO) module is the single source of truth for worker identity, working_relationship, contract type, assignment, and dependent count. PR will not duplicate or maintain its own copy of this master data but will reference it via event-driven sync and pre-run validation.

**Confidence**: 0.75

**Evidence**:
- xTalent architecture documentation consistently positions CO as the master data hub.
- The PR DBML V4 uses foreign keys to `co_working_relationship` and references `co_legal_entity`.
- The event model in reference doc 08 (integration-architecture.md) defines inbound events from CO to PR.
- The critical audit (02) flags CO → PR sync latency as a Medium risk.

**Kill Criteria**: If CO does not expose dependent count as a reliable, queryable attribute (e.g., it is stored in a paper form process, not in the system), then PR must provide its own dependent registration or accept manual override input.

**Risk if Wrong**: PR runs with stale or incomplete worker data. Workers with new dependents do not receive the correct PIT deduction. Workers who changed contract type mid-month are processed under the wrong SI eligibility rule.

**Validation Method**: API contract review between CO team and PR team. CO must expose: working_relationship, contract_type, assignment, dependent_count, nationality, bank_account as versioned, event-sourced attributes before the PR integration sprint begins.

---

## H-007: Integration — T&A Module Locks Attendance Before Payroll Cut-off

**Hypothesis**: The Time and Attendance (TA) module reliably publishes an `AttendanceLocked` event for all workers in a PayGroup before the payroll cut-off date, providing actual_work_days, overtime_hours (by type), and unpaid_leave_days in a format directly consumable by the PR engine.

**Confidence**: 0.55

**Evidence**:
- The integration event model describes `AttendanceLocked` as a trigger for the PR pre-validation stage.
- The critical audit (02) identifies T&A data readiness as a Medium probability / High impact risk.
- The TA → PR data format contract is not yet formalized as of March 2026.
- Attendance data completeness failures are a known operational pain point in Vietnamese HCM deployments.

**Kill Criteria**: If TA cannot guarantee lock by cut-off date for ≥ 95% of workers in a single PayGroup (based on pilot testing), PR must implement a partial-run capability (run for workers with complete TA data, defer workers with incomplete data to a correction run).

**Risk if Wrong**: Payroll run blocked by incomplete attendance data. Admin either delays payment (labor law violation) or processes payroll with estimated/zero attendance (underpayment).

**Validation Method**: Integration contract (formal API specification) agreed between TA and PR teams before integration sprint. Contract specifies exact payload schema, lock sequence, and SLA for event publication. Tested in integration test environment with realistic TA data volumes.

---

## H-008: User Needs — Payroll Admins Require a Business DSL for Formula Editing

**Hypothesis**: xTalent payroll administrators will use the Business DSL Layer (Formula Studio) to write and modify pay formulas without developer involvement. The DSL adoption rate will be ≥ 60% of formula changes after an initial onboarding period of 3 months.

**Confidence**: 0.45

**Evidence**:
- Oracle HCM Fast Formula and Workday Calculated Fields report high HR user adoption in enterprise settings.
- The critical audit (02) flags this as a Tier 3 assumption — no xTalent-specific user research exists.
- Vietnamese payroll administrators typically have accounting/finance backgrounds, not technical backgrounds — DSL syntax must be extremely Excel-like to achieve adoption.
- Formula Studio is a V2 feature in the proposed roadmap; Phase 0 and Phase 1 can deliver correct payroll results with pre-built formulas without exposing DSL to users.

**Kill Criteria**: If user research with 5 target payroll admin users shows that fewer than 3 would attempt to write a formula independently (even with training), the DSL Layer should be a developer/admin tool only, not a self-service HR feature in V1.

**Risk if Wrong**: HR continues using Excel for formula prototyping. Formula Studio investment is not utilized. Payroll agility goal (no-code formula changes) is not achieved.

**Validation Method**: Usability test with 5 payroll admin personas from pilot customers. Task: modify the lunch allowance tax-exempt threshold from 730K to 800K using the DSL interface. Measure completion rate and time-on-task. Decision point before Formula Studio is added to the V1 scope.

---

## H-009: Scope — Multi-Legal Entity Isolation Is a V1 Requirement

**Hypothesis**: xTalent customers deploying the Payroll module will have at least 2 distinct legal entities in their corporate group. Row-level security ensuring complete data isolation between legal entities is therefore a V1 non-negotiable requirement, not a V2 enhancement.

**Confidence**: 0.82

**Evidence**:
- Vietnamese enterprises typically operate as a group of subsidiaries under a holding company. Even mid-size companies often have 2–5 legal entities.
- The critical audit (02) identifies multi-entity data leakage as a Medium probability risk.
- The DBML V4 scopes all payroll configuration objects (`pay_group`, `pay_calendar`, `pay_profile`) to `legal_entity_id`.
- PDPA-equivalent obligations in Vietnam (Nghị định 13/2023/NĐ-CP on personal data protection) require organizational controls for data access.

**Kill Criteria**: If all xTalent V1 pilot customers are confirmed single-entity companies, multi-entity isolation can be deferred to V2 — but the data model must still be designed with `legal_entity_id` scoping to avoid a costly retrofit.

**Risk if Wrong**: A payroll admin for one subsidiary accidentally views or exports salary data for another subsidiary. Worker privacy violation, potential regulatory exposure, reputational damage.

**Validation Method**: Security testing requirement: cross-entity access test must be part of V1 acceptance criteria regardless of pilot customer profile. Test: log in as a PayGroup Admin for Entity A, attempt to retrieve any payroll record for Entity B via API. Must return 403.

---

## H-010: Data Model — working_relationship_id Is the Canonical PR Subject Key

**Hypothesis**: In xTalent Payroll, all payroll calculations, results, and payslips are associated with a `working_relationship_id` (not a `worker_id` or `person_id`). This correctly models the fact that a single person may have concurrent or sequential working relationships and each relationship has its own payroll run.

**Confidence**: 0.78

**Evidence**:
- xTalent's core data model defines `working_relationship` as the association between a `worker` (person) and a `legal_entity` with a specific contract type, effective dates, and terms.
- A worker with two concurrent part-time relationships at two group entities would require two independent payroll runs (under two legal entities, two tax registrations potentially).
- The critical audit (02) flags `worker` vs. `employee` terminology drift as a Medium risk in the DBML.
- DBML V4 references `employee` in some legacy comment fields, creating ambiguity that must be resolved.

**Kill Criteria**: If xTalent CO's data model does not support concurrent working relationships (i.e., a worker can only have one active relationship at a time), then `worker_id` may be sufficient as the key — but this architectural assumption must be confirmed with CO team.

**Risk if Wrong**: PR builds around `worker_id` and then discovers that a single worker has two relationships (e.g., consultant relationship + employed relationship at different entities). PR cannot process them independently. Major refactor required.

**Validation Method**: Data model review with CO team. Confirm the cardinality of worker → working_relationship (1:N or 1:1). Update DBML V4 comments to remove all `employee` references in favor of `working_relationship`. Code review gate before any PR entity class is written.

---

## H-011: Scope — v1 Covers Vietnam Domestic Workers Only (No Expat Edge Cases)

**Hypothesis**: The xTalent Payroll V1 scope targets Vietnamese domestic workers (Vietnamese nationals, tax residents) as the primary calculation path. Expatriate workers (non-residents, treaty-country residents) are a V1+ feature requiring additional configuration but the data model supports them from day one.

**Confidence**: 0.70

**Evidence**:
- Expat payroll in Vietnam requires treaty lookups, residency day tracking, and in some cases, coordination with home-country payroll — significantly more complex than domestic payroll.
- xTalent V1 target customers are likely Vietnamese companies with predominantly Vietnamese workforces.
- The `pay_element` `country_code` field and the statutory_rule design support both resident and non-resident PIT calculation paths.
- If a pilot customer has even one expat worker, the flat 20% non-resident path must be implemented (it is technically simpler than progressive calculation).

**Kill Criteria**: If any pilot customer has confirmed expat workers on payroll, the 20% non-resident PIT path must be included in V1 (it is minimal effort given the existing progressive path).

**Risk if Wrong**: An expat worker in a pilot customer's payroll is calculated at progressive rates instead of the required 20% flat rate. Employer is exposed to incorrect withholding and potential penalty.

**Validation Method**: Pilot customer profile review. Ask during onboarding: "Do you have foreign national workers who are not tax residents of Vietnam?" If yes, include non-resident PIT path in V1 scope.

---

## Ambiguity Resolution Summary

| Ambiguity Hot Spot (from 02-critical-thinking-audit.md) | Resolution Status | Residual Ambiguity |
|----------------------------------------------------------|:-----------------:|:------------------:|
| TR/PR boundary: calculation ownership | Addressed by H-002 + ADR gate | 0.35 → resolved to 0.10 pending ADR |
| PayProfile schema underspecified | Addressed in requirements.md (enriched schema) | 0.30 → 0.10 |
| Worker identity model (worker_id vs. working_relationship_id) | Addressed by H-010 | 0.25 → 0.08 |
| Dependent registration data source | Addressed by H-006 (CO is source of truth) | 0.20 → 0.08 |
| Holiday calendar ownership | Resolved: CO owns public holiday calendar; PR references it | 0.15 → 0.05 |
| Formula governance process | Addressed: Finance Lead approval + version lifecycle | 0.15 → 0.08 |
| Bank file generation scope (API vs. manual) | V1 = file generation only; automated API push is V2 | 0.15 → 0.05 |
| Multi-entity consolidated reporting | V1 = per-entity only; group rollup is V2 | 0.10 → 0.05 |
| PIT annual settlement trigger | V1 = admin-triggered in December payroll run | 0.10 → 0.05 |
| Termination payroll scope | V1 = pro-rated base + outstanding allowances; severance is V2 | 0.10 → 0.05 |

**Composite Ambiguity Score**: 0.17

This score is within the Gate G1 threshold of ≤ 0.20.

---

*Hypotheses developed from synthesis of research report (00), brainstorming report (01), and critical thinking audit (02). Confidence scores are calibrated estimates based on evidence quality tiers defined in 02-critical-thinking-audit.md.*
