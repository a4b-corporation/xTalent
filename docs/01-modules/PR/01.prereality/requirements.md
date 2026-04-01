# Payroll Module — Requirements Document

**Artifact**: requirements.md
**Module**: Payroll (PR)
**Date**: 2026-03-27
**Version**: 1.0 (Pre-Reality — Gate G1)
**Status**: Awaiting Gate G1 Approval

---

## 1. Problem Statement

Vietnamese enterprises operating within the xTalent HCM platform require a payroll computation and disbursement capability that is:

- **Correct**: Every worker receives the exact net pay calculated from their compensation components, actual attendance, and statutory deductions.
- **Compliant**: All mandatory Vietnamese regulations are applied — PIT (7-bracket progressive), BHXH/BHYT/BHTN (SI rates and ceilings), Labor Code OT multipliers.
- **Configurable**: Pay formulas and statutory rules are managed as versioned data configurations, not hardcoded constants, allowing regulatory changes to be applied via admin configuration without code deployment.
- **Auditable**: All payroll results are immutable and tamper-evident, retained for a minimum of 7 years as required by Vietnamese accounting law.
- **Integrated**: Payroll consumes worker, attendance, and compensation data from upstream modules (CO, TA, TR) and produces downstream outputs (bank files, GL entries, statutory filings).

The current-state pain: Most Vietnamese HCM customers use Excel-based payroll or legacy desktop software (MISA AMIS, Fast Payroll) that lacks a proper audit trail, cannot handle retroactive adjustments automatically, and breaks when regulatory rules change.

---

## 2. Goals

| Goal | Description |
|------|-------------|
| G1 | Deliver correct, automated monthly payroll for Vietnamese domestic workers under current labor, SI, and PIT law |
| G2 | Produce legally compliant statutory reports: BHXH D02-LT, PIT quarterly declaration, PIT annual settlement |
| G3 | Provide an immutable audit trail for every payroll run, period, and adjustment |
| G4 | Enable multi-level approval workflow before any bank payment is initiated |
| G5 | Support multi-legal-entity groups with complete data isolation between entities |
| G6 | Enable worker self-service access to payslips and PIT withholding certificates |
| G7 | Generate GL journal entries mapped to VAS-compliant chart of accounts |

## Non-Goals (V1)

| Non-Goal | Deferred To |
|----------|-------------|
| Formula Studio DSL self-service UI for HR administrators | V2 |
| Bi-weekly, semi-monthly, or weekly payroll frequency | V2 |
| Multi-currency payroll (USD, SGD components) | V2 |
| Automated bank API integration (direct payment push via API) | V2 |
| Cross-entity consolidated payroll reporting (group rollup) | V2 |
| Severance calculation and separation benefit modeling | V2 |
| Singapore CPF or other non-VN statutory frameworks | Phase 2 |
| Payroll cost forecasting and budget prediction | V2 analytics |
| Third-party HRIS data migration tools | Separate workstream |

---

## 3. Functional Requirements

### 3.1 Payroll Configuration (Pay Master)

| ID | Priority | Requirement |
|----|:--------:|-------------|
| FR-01 | P0 | The system shall allow creation and management of PayGroups. A PayGroup links workers to a legal entity, pay calendar, pay frequency, and pay profiles. Each legal entity may have multiple PayGroups. |
| FR-02 | P0 | The system shall support a PayCalendar that defines pay periods: start date, end date, cut-off date, and payment date for each period. Monthly frequency is required for V1. |
| FR-03 | P0 | The system shall support PayElement definitions with at minimum: element code, display name, element type (EARNING / DEDUCTION / EMPLOYER_CONTRIBUTION / INFORMATIONAL), tax treatment (TAXABLE / TAX_EXEMPT / TAX_EXEMPT_CAPPED), SI basis inclusion (INCLUDED / EXCLUDED), proration method (CALENDAR_DAYS / WORK_DAYS / NONE), and effective date range. |
| FR-04 | P0 | The system shall support StatutoryRule definitions for Vietnam: PIT brackets (7-bracket schedule, personal deduction 11M, dependent deduction 4.4M/person), SI rates (BHXH 8%/17.5%, BHYT 1.5%/3%, BHTN 1%/1%), SI ceiling (20 × lương cơ sở), OT multipliers (150% weekday, 200% weekend, 300% holiday, +30% night shift). All rates must be stored as data with effective dates, not hardcoded in application logic. |
| FR-05 | P0 | The system shall support a PayProfile that bundles: the set of PayElements applicable to a group of workers, deduction priority order, and payment method (bank transfer). A PayProfile is assigned to workers via their PayGroup. |
| FR-05a | P0 | The system shall support a configurable `PAY_METHOD` field on PayProfile with values: `MONTHLY_SALARY`, `HOURLY`, `PIECE_RATE`, `GRADE_STEP`, `TASK_BASED`. The `PAY_METHOD` determines which formula set is applied to calculate gross pay for workers assigned to that profile. Formula sets are defined as configurable data in a `pay_method_def` table mapping each pay method code to its gross formula, SI basis formula, PIT basis formula, and proration formula. No pay method logic shall be hardcoded in the application engine. |
| FR-05b | P0 | For `HOURLY` pay method, the system shall support a multi-dimensional hourly rate configuration: rate may vary by (a) shift type (`REGULAR` / `NIGHT` / `OT_WEEKDAY` / `OT_WEEKEND` / `OT_HOLIDAY`), (b) worker grade or level, and (c) effective date range. The applicable rate for a given hour is determined by matching `shift_type` and worker grade at the time of work. Default rates are configured at the PayProfile level in a `pay_profile_rate_config` table; individual workers may have a `hourly_rate_multiplier` (BigDecimal, default 1.00) in their compensation snapshot to override the profile default. All rates are stored as configuration data — no rate values shall be hardcoded in application logic. |
| FR-05c | P0 | For `PIECE_RATE` pay method, the system shall support a piece-rate table configuration: a mapping of (`product_code`, `quality_grade`) → `rate_per_unit_vnd` × `effective_date`. The payroll engine shall accept numeric input variables (e.g., `PIECE_QTY_PRODUCT_A` pushed from TA or production system integration) and compute: `Piece_Pay = Σ(qty_i × lookupRate(product_code_i, quality_grade_i))`. A configurable minimum wage floor (see FR-18a) shall be enforced even when computed piece pay falls below the regional minimum. Quality grade multipliers shall be stored as configurable data in the piece-rate table. |
| FR-05d | P1 | For `GRADE_STEP` pay method, the system shall support a pay scale table: a matrix of (`grade_code`, `step_code`) → `salary_amount_vnd` × `effective_date` or `coefficient` × `effective_date`. The system shall support two configurable sub-modes per PayProfile: (a) `TABLE_LOOKUP` — salary is looked up directly from the `pay_scale_table` by grade and step (for private enterprise salary bands); (b) `COEFFICIENT_FORMULA` — salary is calculated as `GRADE_COEFFICIENT(grade, step) × VN_LUONG_CO_SO`, where `VN_LUONG_CO_SO` is a `statutory_rule` parameter (for government/SOE workers on hệ số lương). Multiple active pay scale tables may coexist, each linked to a specific PayProfile via a configurable `pay_scale_table_code` foreign key. Automatic step progression rules (months at step before advancement) shall be defined as configurable data in a `step_progression_rule` table. |
| FR-05e | P2 | For `TASK_BASED` pay method, the system shall support milestone-triggered payment: a task definition comprising (`task_code`, `total_amount_vnd`, `milestone_schedule`). Payment is triggered when a milestone is marked complete by an authorized admin. Tax withholding for freelance contracts (lương khoán / giao khoán) shall be applied automatically: 10% flat withholding if a single payment is ≥ 2,000,000 VND, exempt if below threshold. The flat withholding rate (10%) and the threshold amount (2,000,000 VND) shall be stored as configurable `statutory_rule` parameters — not hardcoded. SI contributions are not applied to TASK_BASED workers whose `contract_type` maps to a `SERVICE_CONTRACT` SI exemption rule. |
| FR-06 | P1 | The system shall support PayElement formula definition using a rule-based engine (Drools 8 / restricted MVEL). Formulas must: reference other element values by code, reference statutory rule parameters by name, support conditional logic (if/when/else), and pass compile-time validation before activation. |
| FR-07 | P1 | The system shall enforce a PayElement lifecycle: DRAFT → PENDING_APPROVAL → APPROVED → ACTIVE → DEPRECATED. Only APPROVED formulas may be activated. Activation requires Finance Lead role approval. |
| FR-08 | P1 | The system shall support GL mapping configuration: each PayElement maps to one or more VAS accounting account codes (e.g., BHXH_EMPLOYER → TK 3383, BASE_SALARY → TK 642 + TK 334). |

### 3.2 Payroll Execution

| ID | Priority | Requirement |
|----|:--------:|-------------|
| FR-09 | P0 | The system shall execute a payroll run in three modes: (a) Dry Run — no persistence, for formula validation; (b) Simulation — full calculation against historical period with new formula version, side-by-side comparison; (c) Production Run — official run with full persistence and approval gate. |
| FR-10 | P0 | A Production Run shall execute the following sequential stages: (1) Pre-validation — verify data completeness (CO worker data, TA attendance lock, TR compensation snapshot); (2) Gross Calculation — accumulate all earnings per PayProfile; (3) Statutory Deductions — calculate BHXH/BHYT/BHTN employee contributions; (4) PIT Calculation — apply 7-bracket progressive schedule to taxable income; (5) Net Calculation — gross minus all deductions; (6) Post-processing — rounding to nearest 1,000 VND, minimum wage check, retroactive delta, YTD balance update, payslip generation. |
| FR-11 | P0 | If any stage of a Production Run fails, the system shall roll back all changes for that run. No partial results shall be persisted. The run shall be marked as FAILED with the error stage and message recorded. |
| FR-12 | P0 | SI contribution eligibility shall be determined by contract type on the worker's working_relationship: unlimited-term and fixed-term (12–36 months) are eligible for BHXH, BHYT, and BHTN. Probation workers (≤ 60 days) and service contract/freelance workers are exempt from all SI contributions. |
| FR-13 | P0 | PIT calculation shall support: (a) Resident path — progressive 7-bracket schedule after personal deduction (11M), dependent deductions (4.4M × registered dependents), and SI employee deductions; (b) Non-resident path — flat 20% on Vietnam-sourced income; (c) Freelancer path — flat 10% withholding if payment ≥ 2,000,000 VND, exempt below threshold. |
| FR-14 | P0 | The system shall apply VND rounding to net salary results: round to nearest 1,000 VND. Rounding method shall be configurable (ROUND_HALF_UP default). All intermediate calculations shall use BigDecimal arithmetic. |
| FR-15 | P0 | The system shall check that no worker's net salary is negative or zero after all deductions. If this condition would result, the run shall flag the worker as an exception and halt that worker's processing. The admin must manually resolve before the run can be finalized. |
| FR-16 | P1 | The system shall support retroactive adjustment calculation when a salary change with a past effective date is entered. Retroactive deltas shall be calculated for up to 12 prior closed periods. The delta amount shall be added to the next open payroll period as a separate RETRO_ADJUSTMENT element. Retroactive runs beyond 3 periods shall require explicit admin confirmation with a displayed impact summary. |
| FR-17 | P1 | The system shall support off-cycle payroll run types: TERMINATION (final pay for a departing worker), ADVANCE (salary advance with deduction recovery in next cycle), CORRECTION (error correction run after period close). Off-cycle runs follow the same approval workflow as regular runs. |
| FR-18 | P1 | The system shall support OT premium calculation for workers on `MONTHLY_SALARY` and `HOURLY` pay methods, with four dimensions: day type (weekday / weekend / public holiday), time of day (day / night shift 22:00–06:00), cumulative monthly OT cap check (24 hours/month default, configurable), and hourly rate derivation from the worker's base salary and standard work hours (for `MONTHLY_SALARY` workers) or from their configured hourly rate table (for `HOURLY` workers, per FR-05b). All OT multipliers are stored as configurable `statutory_rule` parameters with effective dates — not hardcoded. |
| FR-18a | P0 | For all pay methods, the system shall guarantee that a worker's computed gross pay in any period meets the applicable regional minimum wage (vùng lương tối thiểu). The minimum wage floor is configured as a `statutory_rule` by region code (`REGION_1`, `REGION_2`, `REGION_3`, `REGION_4`). If computed gross is below the regional floor, the system shall flag it as an exception in the Exception Report before finalizing the run; the admin must acknowledge the exception before approving. The system shall support both: (a) absolute minimum per month for monthly and piece-rate workers, and (b) minimum per hour for hourly workers. Current statutory values (Region 1 = 4,960,000 VND/month, Region 2 = 4,410,000 VND/month, Region 3 = 3,860,000 VND/month, Region 4 = 3,450,000 VND/month, per NĐ 38/2022/NĐ-CP and subsequent updates) shall be stored exclusively as `statutory_rule` data records and shall not be hardcoded anywhere in application source code. |
| FR-18b | P1 | For `PIECE_RATE` workers on a hybrid pay model (base component + piece-rate component), the system shall support a configurable SI basis mode on the PayProfile: (a) `SI_BASIS_BASE_ONLY` — SI contributions are computed on the `BASE_COMPONENT` monthly salary only, not on the variable piece-rate earnings; (b) `SI_BASIS_FULL_GROSS` — SI contributions are computed on the total gross (`BASE_COMPONENT + PIECE_RATE_COMPONENT`). The SI basis mode is a configurable parameter on the PayProfile (`si_basis_mode` enum). PIT shall always be computed on the total gross regardless of SI basis mode selection. |
| FR-19 | P1 | The system shall support 13th-month salary calculation as a configurable PayElement (THIRTEENTH_MONTH, type = EARNING, taxable). Formula may reference: BASE_SALARY × (months_worked_in_year / 12). When included in a payroll period, it is added to gross income for PIT purposes in that month. |
| FR-20 | P1 | The system shall handle SI ceiling split-period calculation when a lương cơ sở change takes effect mid-month. For the month of transition, SI contribution shall be: (days under old ceiling × old daily rate) + (days under new ceiling × new daily rate). |

### 3.3 Approval Workflow and Period Management

| ID | Priority | Requirement |
|----|:--------:|-------------|
| FR-21 | P0 | A Production Run shall require multi-level approval before bank payment files are released: Level 1 — Payroll Admin (submit for approval); Level 2 — HR Manager (first review); Level 3 — Finance Manager (final approval and payment release). Each level may approve, reject with comments, or request changes. |
| FR-22 | P0 | Once a payroll period is approved and locked, payroll results for that period shall become immutable. No direct modification is permitted. Any correction must be processed as a retroactive adjustment in a subsequent open period. |
| FR-23 | P0 | The system shall compute and store a SHA-256 hash of each worker's payroll result record at the time of period lock. Automated integrity verification shall run nightly, comparing stored hashes against current record values and alerting administrators of any discrepancy. |
| FR-24 | P1 | The system shall maintain Year-to-Date (YTD) and Month-to-Date (MTD) balance accumulators for each worker for key elements: YTD_GROSS, YTD_PIT, YTD_BHXH_EMP, YTD_BHYT_EMP, YTD_BHTN_EMP, YTD_NET. Balances shall reset to zero on January 1 each year. |

### 3.4 Outputs — Payslip and Payment

| ID | Priority | Requirement |
|----|:--------:|-------------|
| FR-25 | P0 | The system shall generate a payslip for each worker for each pay period. The payslip shall include: worker name, ID, legal entity, pay period, all earnings with amounts, all deductions itemized (BHXH, BHYT, BHTN, PIT, other), net salary, and payment date. |
| FR-26 | P0 | Payslips shall be available as PDF download in Vietnamese. Bilingual (Vietnamese/English) payslips are a V1+ option. |
| FR-27 | P0 | The system shall generate bank payment files in the formats required by target banks: Vietcombank, BIDV, and Techcombank for V1. The file shall contain: worker name, bank account number, bank code, amount in VND, payment description. Files are generated for manual upload to the bank portal (automated API push is V2). |
| FR-28 | P1 | The system shall generate GL journal entries after payroll period approval. Journal entries shall map pay elements to VAS account codes: salary expense (TK 642), salary payable (TK 334), BHXH payable (TK 3383), PIT payable (TK 3335). Each journal line shall include: account code, debit/credit amount, cost center, description, and payroll period reference. |

### 3.5 Statutory Reports and Filings

| ID | Priority | Requirement |
|----|:--------:|-------------|
| FR-29 | P0 | The system shall generate the BHXH monthly contribution list (Form D02-LT) for submission to the Social Insurance Agency via VssID. The report shall include all SI-eligible workers with their BHXH number, contribution basis, and employee/employer contribution amounts. |
| FR-30 | P0 | The system shall generate the PIT quarterly withholding declaration (Form 05/KK-TNCN) in XML format per Circular 8/2013/TT-BTC, for submission to the tax authority via eTax portal. |
| FR-31 | P1 | The system shall generate the annual PIT settlement report (Form 05/QTT-TNCN) in XML format. Annual settlement compares YTD_PIT_WITHHELD against the recalculated progressive annual tax. Workers with under-withholding pay the difference; workers with over-withholding receive a refund (or offset against next year). Settlement is admin-triggered as part of December payroll or a January standalone run. |
| FR-32 | P1 | The system shall generate a PIT withholding certificate (Chứng từ khấu trừ thuế TNCN, Form 03/TNCN) for each worker upon request or at year-end. The certificate shows YTD gross, YTD PIT withheld, and the worker's tax code. |

### 3.6 Operational Reports

| ID | Priority | Requirement |
|----|:--------:|-------------|
| FR-33 | P0 | The system shall produce a Payroll Register report: all workers in the PayGroup, all element values for the current period, sorted by department and worker ID. |
| FR-34 | P0 | The system shall produce a Variance Report: element-level comparison between current period and the immediately prior period. Variances exceeding 20% (configurable) are highlighted for admin review. |
| FR-35 | P0 | The system shall produce an Exception Report: workers with anomalous calculated values (negative net, zero BHXH on SI-eligible worker, PIT = 0 on gross > 11M). Exceptions must be reviewed and acknowledged before the run can proceed to approval. |
| FR-36 | P1 | The system shall produce a Payroll Cost by Department / Cost Center report showing total employer cost (gross + employer BHXH/BHYT/BHTN contributions) for each cost center in the period. |

### 3.7 Worker Self-Service

| ID | Priority | Requirement |
|----|:--------:|-------------|
| FR-37 | P1 | Workers shall be able to view their payslips for all periods in which they were active, through the xTalent self-service portal. |
| FR-38 | P1 | Workers shall be able to download their payslip as a PDF for any period. |
| FR-39 | P1 | Workers shall be able to download their PIT withholding certificate (Form 03/TNCN) for any year in which tax was withheld. |
| FR-40 | P2 | Workers shall be able to view a YTD summary showing: gross earnings to date, BHXH contributions to date, PIT withheld to date, and net paid to date for the current calendar year. |

### 3.8 Audit and Security

| ID | Priority | Requirement |
|----|:--------:|-------------|
| FR-41 | P0 | The system shall record an audit log entry for every state change: payroll run creation, stage transitions, approval actions (approve/reject), formula activation, statutory rule changes, and configuration modifications. Each log entry shall include: timestamp, user ID, action type, affected entity, before/after values. |
| FR-42 | P0 | The system shall enforce row-level security ensuring that a user with access to Legal Entity A cannot retrieve, list, or export any payroll data belonging to Legal Entity B. Cross-entity access must return HTTP 403. |
| FR-43 | P0 | Payroll data shall be retained for a minimum of 7 years from the period close date, compliant with Accounting Law 88/2015/QH13. BHXH electronic records shall be retained for 10 years. Automated archival and access controls shall enforce these limits. |

---

## 4. Non-Functional Requirements

| ID | Category | Requirement |
|----|----------|-------------|
| NFR-01 | Performance | A Production Run for 1,000 workers with 20 pay elements must complete in under 30 seconds. A Production Run for 10,000 workers must complete in under 5 minutes. Validated by load test POC in Phase 0. |
| NFR-02 | Performance | An individual worker's payroll calculation (single-worker dry run) must return in under 100 milliseconds, enabling real-time preview use cases. |
| NFR-03 | Reliability | The payroll batch engine must be atomic: a run either completes all stages successfully or rolls back completely. Partial results must never be persisted. |
| NFR-04 | Reliability | The system must prevent concurrent production runs for the same PayGroup and period. Any attempt to start a second run while one is in progress must be rejected with a clear error. |
| NFR-05 | Availability | The payroll service must achieve 99.5% uptime during scheduled payroll processing windows (typically 2nd–5th of each month in Vietnam). |
| NFR-06 | Security | Formula Studio DSL must pass a dedicated security penetration test covering MVEL injection, sandbox bypass, and JVM reflection access before any DSL feature is exposed to non-developer users. |
| NFR-07 | Security | All worker payroll data in transit must use TLS 1.2+. Payroll data at rest must be encrypted using AES-256. |
| NFR-08 | Audit | All payroll run results must include a SHA-256 content hash generated at period lock. Automated nightly integrity verification must compare stored hashes and alert on any mismatch. |
| NFR-09 | Compliance | Statutory rates (PIT brackets, SI rates, SI ceiling) must be stored as configurable data in `statutory_rule` records with effective date management. No statutory rates shall be hardcoded in application source code. |
| NFR-10 | Data | All monetary values must use BigDecimal arithmetic throughout the calculation pipeline. Floating-point types (float, double) are prohibited for monetary calculations. |
| NFR-11 | Scalability | The architecture must support scaling from 50 workers to 50,000 workers without schema changes, using batch partitioning and parallel KieSession execution. |
| NFR-12 | Observability | Every production payroll run must emit structured logs with: run ID, batch size, duration per stage, element calculation count, error count. Alerts must fire when stage duration exceeds 2× the p95 baseline. |

---

## 5. Constraints

### Regulatory Constraints

- All PIT calculation must conform to PIT Law 04/2007/QH12 as amended by NQ 954/2020/UBTVQH14.
- All SI contributions must conform to Social Insurance Law 58/2014/QH13 and Decree 73/2024/NĐ-CP rates.
- Overtime premiums must conform to Labor Code 45/2019/QH14 Article 97.
- Statutory reports must conform to approved filing formats: XML per TT 08/2013/TT-BTC (PIT), VssID D02-LT format (BHXH).
- Data retention must comply with Accounting Law 88/2015/QH13 (7 years) and BHXH regulations (10 years for submission records).

### Technical Constraints

- Rule engine: Drools 8 (KIE API). MVEL restricted to whitelist (no reflection, no file I/O, no network calls from within formulas).
- Platform: Java 17+, Spring Boot 3.x, PostgreSQL 15+.
- Monetary arithmetic: BigDecimal only. No float or double for monetary values.
- VND as primary currency in V1. All stored amounts in VND.

### Business Constraints

- Architecture Decision Record (ADR) on TR/PR calculation ownership must be completed and signed before Sprint 1.
- PayProfile schema must be enriched (component bindings, deduction priority, proration method) before BRD story writing begins.
- All schema table and field names for worker references must use `working_relationship` and `worker` terminology. No `employee` in new schema objects.

---

## 6. Assumptions

| ID | Assumption | Confidence | Owner to Validate |
|----|------------|:----------:|-------------------|
| A1 | V1 pilot customers use monthly payroll frequency | 0.80 | Product Manager |
| A2 | TR team will accept re-scoping of `calculation_rule_def` to PR ownership | 0.65 | Architecture Lead |
| A3 | CO module exposes working_relationship and dependent_count as queryable, versioned attributes | 0.75 | CO Team Lead |
| A4 | TA module can guarantee attendance lock before payroll cut-off for ≥ 95% of workers | 0.55 | TA Team Lead |
| A5 | No V1 pilot customers require automated bank API payment push | 0.70 | Product Manager |
| A6 | Vietnam PIT 7-bracket schedule and SI rates are stable through V1 launch | 0.80 | Regulatory Counsel |
| A7 | Drools 8 on target infrastructure achieves required performance SLAs | 0.60 | Engineering Lead |
| A8 | V1 pilot customers have a maximum of 5 legal entities per group | 0.75 | Customer Success |

---

## 7. Dependencies on Other xTalent Modules

| Dependency | Module | Data Required | Criticality |
|------------|--------|---------------|:-----------:|
| Worker identity and contract type | CO (Core HR) | working_relationship_id, contract_type, worker name, tax ID, BHXH number, nationality, effective dates | P0 |
| Compensation amounts | TR (Total Rewards) | Base salary amount, allowance amounts by component code, approved bonus allocations | P0 |
| Attendance data | TA (Time & Attendance) | actual_work_days, overtime_hours by type, unpaid_leave_days, AttendanceLocked event | P0 |
| Bank account details | CO (Core HR) | Worker bank account number, bank code, account holder name (verified) | P0 |
| Dependent count for PIT | CO (Core HR) | registered_dependent_count per working_relationship (effective-dated) | P0 |
| Taxable bridge items | TR (Total Rewards) | RSU vest amounts, option exercise income, benefit premium deductions | P1 |
| Cost center assignment | CO (Core HR) | cost_center_id per assignment (for GL posting) | P1 |
| Public holiday calendar | CO (Core HR) | Holiday dates per legal entity jurisdiction (for OT day-type classification) | P1 |
| Production / task completion data | TA or external production system | `piece_qty` by `product_code` and `quality_grade` per worker per period; `hours_by_shift_type` breakdown (regular / night / OT weekday / OT weekend / OT holiday); task milestone completion events with `task_code` and `completion_date` | P0 for PIECE_RATE and HOURLY pay methods; P2 for TASK_BASED |

---

## 8. Out of Scope (V1)

These items are explicitly excluded from V1 and will not be designed, built, or tested in the initial delivery cycle:

1. Formula Studio DSL self-service UI for HR/Payroll admins
2. Bi-weekly, semi-monthly, weekly payroll frequencies
3. Multi-currency payroll (USD, SGD, EUR components)
4. Automated bank API payment push (direct API integration with VCB, BIDV, TCB)
5. Cross-entity consolidated payroll reports (group-level rollup)
6. Severance and separation benefit statutory calculation (TT47/2021, Labor Code Article 46)
7. CPF or other non-Vietnam statutory frameworks
8. Payroll cost forecasting and headcount budget prediction
9. Real-time gross-to-net calculator (worker-facing live preview)
10. Third-party HRIS data import / migration tooling
11. Mobile app payslip access (web-responsive only in V1)
12. BHXH online submission API integration (file generation only; portal upload is manual in V1)
13. eTax XML auto-submission (file generation only; manual portal upload in V1)

---

## 9. Success Metrics

| Metric | V1 Target | Measurement Method |
|--------|:---------:|-------------------|
| Payroll calculation accuracy | 100% (zero computation errors vs. manual audit) | Parallel run comparison with existing payroll data from 3 pilot customers for 2 months |
| Regulatory compliance | 100% of BHXH and PIT filings accepted by agencies | Count of accepted vs. rejected statutory submissions in first 3 months |
| Payroll run completion time (1,000 workers) | < 30 seconds | Load test in staging environment, pre-launch |
| Payroll run completion time (10,000 workers) | < 5 minutes | Load test in staging environment |
| Worker payslip availability | < 1 hour after period lock | Monitoring on payslip generation event timestamp vs. period lock timestamp |
| Audit trail integrity | Zero hash mismatches in nightly verification | Nightly integrity job alert count |
| Admin adoption rate | ≥ 3 customers processing full monthly payroll in the system within 2 months of go-live | Customer usage tracking |
| Worker self-service adoption | ≥ 60% of workers accessing payslip via portal within 30 days of go-live | Portal login and download event count |
| Payroll admin error rate | < 5% of payroll runs require a correction run in the same period | Correction run ratio per legal entity per month |

---

## 10. Research Artifact References

All findings in this requirements document are traceable to the following pre-reality research artifacts:

| Artifact | Location |
|----------|----------|
| Research Report (domain, regulations, market) | `prereality/00-research-report.md` |
| Brainstorming Report (scenarios, edge cases, ideation) | `prereality/01-brainstorming-report.md` |
| Critical Thinking Audit (risks, bias scan, evidence quality) | `prereality/02-critical-thinking-audit.md` |
| Hypothesis Document (confidence scores, kill criteria) | `prereality/03-hypothesis-document.md` |
| Research Synthesis (consolidated findings, go/no-go) | `prereality/04-research-synthesis.md` |
| Ambiguity Resolution Document (AQ-01 through AQ-14, OQ-1 through OQ-8) | `prereality/05-ambiguity-resolution.md` |
| Reference Documents | `reference/overview/`, `reference/analyze/` |
| DBML Schema V4 | `reference/5.Payroll.V4.dbml` |

---

**Gate G1 Criteria Check**

| Criteria | Target | Achieved |
|----------|:------:|:--------:|
| Problem statement — clear and specific | Yes | Yes |
| Functional requirements | ≥ 10 | 52 (FR-01 through FR-43, plus FR-05a–05e, FR-18a–18b) |
| Hypotheses with confidence scores | ≥ 1 | 11 (H-001 through H-011) |
| Ambiguity score | ≤ 0.2 | 0.17 |
| Research sources cited | ≥ 2 | 20+ (reference docs + decrees + DBML) |

**Gate G1 Status: READY FOR REVIEW**
