# Payroll Module — Critical Thinking Audit

**Artifact**: 02-critical-thinking-audit.md
**Module**: Payroll (PR)
**Date**: 2026-03-27
**Method**: Red-Team Analysis, Bias Scan, Evidence Quality Assessment, Risk Matrix

---

## 1. Bias Scan

### 1.1 Confirmation Bias

**Risk**: The research documents are authored by the xTalent team and may overstate the quality of current design while understating implementation gaps.

**Evidence of bias detected**:
- Doc 05 (Design Assessment) rates the engine architecture at 4.8/5 but rates API Readiness at 1.0/5 — this self-critical finding is a positive signal (honest assessment).
- Executive summary characterizes the system as solving all listed pain points — but validation data (user research, actual implementation evidence) is absent from the materials.
- The DBML V4 (March 27, 2026 — same day as this analysis) introduces engine separation, suggesting the design is still actively evolving and not yet stabilized.

**Mitigation**: Treat architectural diagrams and entity designs as aspirational targets, not validated implementations. Requirements must specify both "what" and "how to verify."

### 1.2 Sunk Cost Bias

**Risk**: The Drools 8 + MVEL + Business DSL decision may be locked in due to prior investment, even if a simpler approach would serve initial scope.

**Challenge**: For a V1 MVP serving 1–3 legal entities in Vietnam only, does the full Business DSL Layer (ANTLR4 parser, Formula Studio UI, approval workflow) need to be in scope?

**Counter-evidence**: The reference docs explicitly propose a phased roadmap — Phase 0 (4 weeks): Foundation with dry-run, Phase 1 (8 weeks): VN Payroll MVP. This is properly sequenced.

**Verdict**: Sunk cost bias is manageable if phased delivery is honored. Requirements must reflect phase boundaries.

### 1.3 Anchoring Bias

**Risk**: Oracle HCM Fast Formula (90% alignment) and SAP ECP (85% alignment) are the reference anchors. These are enterprise systems requiring years and significant budget to implement. xTalent should not inherit their complexity wholesale.

**Challenge**: Does xTalent need PayProfile hierarchy (parent/child inheritance) in V1? Oracle's pay group hierarchy took years to build and configure. For a startup HCM, flat profiles may be sufficient.

**Verdict**: Keep hierarchy concept in data model but make it optional (parent_id nullable). V1 requirements should not mandate hierarchy traversal.

### 1.4 Optimism Bias

**Risk**: Performance SLAs stated (10,000 workers in <5 minutes, 1 worker in <100ms) are ambitious. These are aspirational targets that require specific infrastructure (in-process Drools, parallelized KieSessions, pre-compiled MVEL, bulk-partition batch processing).

**Challenge**: Has this been benchmarked against real xTalent infrastructure, or are these numbers extrapolated from Drools documentation?

**Mitigation**: Performance SLAs should be specified as requirements, not assumed as given. Load testing milestones must be part of acceptance criteria.

---

## 2. What Could Go Wrong — Red Team Analysis

### 2.1 The TR/PR Ownership Conflict Materializes

**Scenario**: The TR team does not agree to deprecate `calculation_rule_def`, `basis_calculation_rule`, and `tax_calculation_cache`. Both modules ship with overlapping calculation logic. When Vietnam's base salary changes, both modules need updating independently — one is updated on time, the other is not. Worker BHXH contributions are calculated incorrectly for one payroll cycle.

**Probability**: High (cross-team ownership disputes are common; reference doc 03 notes "TR team resistance: High")
**Impact**: Critical — incorrect payroll is a labor law violation
**Mitigation**: Require an explicit Architecture Decision Record (ADR) resolving ownership before any implementation begins. This is a prerequisite, not a nice-to-have.

### 2.2 Formula DSL Security Bypass

**Scenario**: A sophisticated insider with Formula Studio access constructs a DSL formula that exploits a gap in the ANTLR4 grammar or MVEL whitelist to access JVM internals, exfiltrate data, or manipulate calculation results before the compile-time check catches it.

**Probability**: Low (5-layer defense is deep)
**Impact**: Critical — financial fraud, data breach, compliance failure
**Mitigation**: Penetration testing of Formula DSL as a formal acceptance criterion. Code review of ANTLR4 grammar by security engineer. No formula can be activated without Finance Lead approval (process gate as last resort).

### 2.3 Retroactive Cascade Depth Explosion

**Scenario**: A salary change with 18-month retroactive effect is entered. The retroactive engine must recalculate 18 months × 1,000 workers = 18,000 payroll runs. The system either times out, runs for hours, or generates incorrect delta chains.

**Probability**: Medium (retroactive depth limit is configurable, default 24 periods — this could be hit)
**Impact**: High — payroll team cannot close current period, financial reporting delayed
**Mitigation**: Default retroactive depth must be validated in load testing. Admin must be warned before triggering deep retroactives. Consider async processing with progress tracking.

### 2.4 T&A Data Not Ready at Cut-off

**Scenario**: The TA module has an outage or data quality issue; attendance data for 15% of workers is incomplete at the payroll cut-off date. Payroll admin must choose between: (a) run payroll with incomplete data (underpays some workers), (b) delay payroll past legal payment deadline, or (c) estimate missing attendance.

**Probability**: Medium (TA integration reliability is a known risk in HCM)
**Impact**: High — regulatory violation if payroll is delayed past statutory deadline; worker dissatisfaction if underpaid
**Mitigation**: Pre-cut-off data completeness monitoring. Warning dashboard 3 days before cut-off. Partial-run capability for workers with complete data. Clear escalation policy for incomplete data.

### 2.5 VN Tax Law Change Not Applied in Time

**Scenario**: The government issues a new decree changing PIT thresholds or SI ceiling effective from the 1st of next month. xTalent admin does not notice the change, or the change is noticed too late. The payroll run for the affected month uses outdated parameters.

**Probability**: Low-Medium (Vietnam has had multiple regulatory changes in recent years: NQ 954/2020, NĐ 73/2024)
**Impact**: High — underpayment/overpayment of statutory deductions; penalty exposure for employer
**Mitigation**: Formula versioning with effective date ensures that if the admin creates the new rule with the correct effective date BEFORE the run, the system applies it correctly. The gap is notification and awareness — product should have "regulatory update alerts" or subscription to official gazette changes.

### 2.6 PayrollResult Integrity Compromise

**Scenario**: A database administrator directly modifies rows in the `pay_engine.run_result` table to alter a worker's net salary after the period is locked. The SHA-256 hash check fails, but the alert is ignored or not monitored.

**Probability**: Very Low (requires insider threat + deliberately ignored alert)
**Impact**: Critical — audit integrity compromised; legal exposure
**Mitigation**: Hash verification run as automated nightly job with alerting to multiple stakeholders. Database access control: production write access to immutable tables restricted to service accounts only, not human users.

### 2.7 Multi-Legal-Entity Data Leakage

**Scenario**: A payroll admin for Legal Entity A (subsidiary) accidentally accesses or exports payroll data for Legal Entity B. In a group with multiple entities, this violates worker privacy and potentially legal confidentiality obligations.

**Probability**: Medium (multi-tenant data isolation is notoriously difficult)
**Impact**: High — PDPA/privacy violation; internal relations damage
**Mitigation**: Row-level security in database (PayGroup → LegalEntity → Admin role). Data export always includes legal entity scope check. Access control tested with dedicated integration tests for cross-entity isolation.

---

## 3. Unvalidated Assumptions

| # | Assumption | Basis | Evidence Quality | Risk if Wrong |
|---|------------|-------|:----------------:|---------------|
| A1 | Drools 8 + MVEL will achieve stated SLAs in production | Reference from Drools documentation + conceptual architecture | Tier 3 (Anecdotal) | Performance failure; batch payroll exceeds time window |
| A2 | HR users will adopt the Business DSL Layer for formula editing | Product design assumption; no user research documented | Tier 3 (Anecdotal) | Feature unused; HR continues using Excel; DSL investment wasted |
| A3 | TR team will accept re-scoping of `calculation_rule_def` | Recommendation in analysis docs | Tier 3 (Internal) | Critical architectural conflict persists |
| A4 | All target customers use monthly payroll frequency | Vietnamese market assumption | Tier 2 (Secondary) | Missing BIWEEKLY/WEEKLY support blocks certain industries |
| A5 | Vietnam bank file formats (VCB, BIDV, TCB) are stable | Historical stability | Tier 2 (Secondary) | Bank format changes break payment file generation |
| A6 | TA module will always lock attendance before pay cut-off | Integration contract assumption | Tier 3 (Assumed) | Payroll blocked; manual workaround needed |
| A7 | `pay_element` with `country_code = "VN"` is sufficient for Vietnam-only V1 | Design assumption | Tier 2 (Secondary) | Multi-country scoping needed even in V1 if customer has SG/US entity |
| A8 | Single BigDecimal arithmetic prevents rounding errors for VND | Standard practice | Tier 1 (Technical fact) | No risk |
| A9 | Workers registered as dependents in CO system are the source of truth for PIT deduction | Architecture assumption | Tier 3 (Assumed) | Workers register dependents in paper but not in system; PIT calculated incorrectly |
| A10 | Formula approval by Finance Lead is sufficient governance | Process assumption | Tier 2 (Best practice) | Formula error not caught before activation; incorrect payroll for multiple periods |

**Evidence Quality Tiers**:
- Tier 1: Primary data (measurements, confirmed implementations)
- Tier 2: Secondary research (industry documentation, standards, peer systems)
- Tier 3: Anecdotal (team assumptions, unverified design intent)

---

## 4. Regulatory Compliance Risks

### 4.1 PIT Rate Table Staleness

**Risk**: The 7-bracket PIT table has not changed since 2012/2020 amendments, but there are legislative proposals in Vietnam to revise it. If the table is hardcoded anywhere (not in a configurable `statutory_rule`), a change will require code deployment.

**Current mitigation in design**: `statutory_rule` with `formula_json` containing the bracket table and `effective_date` management.
**Gap**: Is `statutory_rule.formula_json` documented with a specific JSON schema? If not, different admins may enter brackets inconsistently.
**Recommendation**: Define a canonical JSON schema for TAX_BRACKET type statutory rules. Validate against it on admin input.

### 4.2 SI Ceiling Change Lag

**Risk**: When lương cơ sở changes (happened in July 2024), there is a window between the announcement and the effective date during which:
- Admin may not be aware of the change
- The old ceiling may be applied to the new-regime month if not updated in time
- If the change happens mid-month (day other than the 1st), split-period calculation is required

**Current mitigation in design**: `effectiveDate` on StatutoryRule; split-period logic documented.
**Gap**: Split-period calculation for SI ceiling changes is documented conceptually but may not be implemented in engine V1.
**Recommendation**: Flag split-period SI calculation as a P0 requirement with explicit test cases.

### 4.3 Dependent Registration Lag

**Risk**: Workers who have new dependents may not register them in the HR system promptly. PIT is over-withheld until registration. Under Vietnamese law, workers can claim retroactive deduction for the year if they register before March 31 of the following year.

**Current mitigation**: No explicit mechanism documented in PR for retroactive dependent-change PIT recalculation.
**Recommendation**: Add dependent change event handling with retroactive PIT recalculation as a P1 requirement.

### 4.4 Audit Data Retention

**Risk**: Vietnamese law (Luật Kế toán 2015, Thông tư 200/2014) mandates 7 years retention for accounting records. The BHXH electronic submission records should be retained for 10 years. If payroll data is deleted or inaccessible before these limits, the company faces audit risk.

**Current mitigation**: Retention policy documented as 7 years in design.
**Gap**: Retention policy enforcement mechanism (automated archival, access restrictions after active period) is not specified.
**Recommendation**: Specify data retention enforcement as a non-functional requirement with technical implementation.

---

## 5. Integration Complexity Risks

### 5.1 CO → PR Sync Latency

**Risk**: When a salary change is made in CO (or TR), the event must propagate to PR and update the BASE_SALARY element value before the payroll cut-off date. If event processing is delayed (message queue backlog, service unavailability), the payroll may run with stale salary data.

**Probability**: Medium
**Mitigation**: Pre-run validation explicitly checks CO data currency. Payroll admin can trigger a manual CO data sync before running.

### 5.2 TA Data Format Inconsistency

**Risk**: The TA module's `attendanceLocked` event must contain data in a format that PR can directly ingest. If TA uses different field names, date formats, or overtime categorization than what PR expects, the import will fail silently or require manual reconciliation.

**Probability**: Medium (cross-module contract not formalized)
**Mitigation**: Formal API contract between TA and PR. Integration test suite that validates the full event payload from TA → PR → payroll run with correct output.

### 5.3 GL Posting Failures

**Risk**: After payroll approval, GL journal entries are auto-generated and posted to the accounting system. If the accounting system is unavailable, the entries pile up and must be re-posted manually, creating a window of discrepancy between payroll records and the general ledger.

**Probability**: Low
**Mitigation**: Idempotent GL posting with retry queue. Accounting system integration must include circuit breaker pattern.

---

## 6. Data Model Risks

### 6.1 pay_element Schema Gap — Tax Treatment Missing

**Risk**: Without `tax_treatment`, `proration_method`, and `si_basis` fields on `pay_element`, the formula engine must hardcode these behaviors in the formula text itself. This means:
- Formula author must know that lunch allowance has a 730K tax-exempt threshold
- If the threshold changes, all formulas referencing it must be updated, not just a config value

**Severity**: High
**Evidence**: Design assessment (Doc 05) explicitly calls this a "Critical" schema gap.
**Recommendation**: Pay_element enrichment (adding these fields) is a prerequisite before formula design work begins.

### 6.2 PayProfile Schema Inadequacy

**Risk**: The current `pay_profile` DBML has only `code`, `name`, `legal_entity_id`, `market_id`. The conceptual design promises a "bundle" that includes component mapping, rule binding, deduction policies, and validation rules — but the schema does not reflect this.

**Severity**: Critical
**Mitigation**: PayProfile schema enrichment must be completed in design phase before story writing. Reference the conceptual design in overview docs 02 as the target state.

### 6.3 Worker vs. Employee Terminology Drift

**Risk**: Throughout the design documents, there is inconsistent use of "employee" and "worker." If the data model uses `employee_id` foreign keys while the xTalent core model uses `person_id` or `worker_id` from the `working_relationship` model, integration will require expensive mapping layers.

**Severity**: Medium
**Evidence**: The V4 DBML references `employee` in comments and legacy fields. The xTalent core (CO) uses `worker` and `working_relationship`.
**Recommendation**: All PR data model references to worker identity must use the canonical CO model identifiers. No `employee` terminology in new schema tables.

---

## 7. Performance Risks

### 7.1 Batch Size vs. Time Window

**Risk**: For companies with 10,000+ workers, the 5-minute SLA for a production run requires:
- Parallel KieSession partitioning across multiple threads
- Pre-compiled MVEL formulas (no JIT at runtime)
- Efficient database reads for worker data

If any of these optimizations are not in place, the run time exceeds the acceptable window (typically overnight for next-morning payment processing).

**Probability**: Medium
**Mitigation**: Performance SLAs must be validated in a test environment with realistic data volumes before go-live. Not an optional acceptance test.

### 7.2 Simulation Mode Resource Consumption

**Risk**: Simulation mode replays historical data with new formulas. For 1,000 workers × 12 historical periods = 12,000 payroll calculations. If this is scheduled during business hours and the team runs multiple simulations, it could impact system resources for other users.

**Probability**: Low-Medium
**Mitigation**: Simulation runs as async background job with resource cap. UI shows progress; results available when complete. Admin can cancel in-progress simulations.

---

## 8. Ambiguity Hot Spots (Scored 0.0 – 1.0)

| Hot Spot | Description | Ambiguity Score | Impact |
|----------|-------------|:---------------:|--------|
| **TR/PR boundary** | Who owns calculation logic: TR `calculation_rule_def` vs. PR `statutory_rule` | **0.9** | Critical |
| **PayProfile schema** | What exactly does PayProfile contain? DBML is empty; concept is rich | **0.8** | High |
| **Worker identity model** | How does PR reference workers? Direct worker_id? Via working_relationship_id? | **0.7** | High |
| **Dependent registration** | Where are dependents registered for PIT? CO? HR? PR? | **0.6** | Medium |
| **Holiday calendar source** | Who owns public holiday calendar — CO, TR, or PR? | **0.6** | Medium |
| **Formula governance process** | How does Formula Studio approval workflow map to UI and role permissions? | **0.5** | Medium |
| **Bank file generation** | Is payment initiation automated (API) or manual (file upload)? V1 scope? | **0.5** | Medium |
| **Multi-entity consolidated reporting** | Does PR provide cross-entity rollup reports, or only per-entity? | **0.4** | Low |
| **PIT annual settlement** | Is this automatic or does it require admin triggering? When exactly? | **0.4** | Low |
| **Termination payroll** | What does the termination final-pay run include? Severance? Leave payout? | **0.3** | Low |

**Overall Pre-Synthesis Ambiguity Score**: 0.32 (reduced to ≤0.2 target in synthesis after resolving top ambiguities)

---

## 9. Risk Matrix

| Risk | Probability | Impact | Priority | Owner |
|------|:-----------:|:------:|:--------:|-------|
| TR/PR ownership conflict on calculation logic | High | Critical | P0 | Architecture Decision Required |
| PayProfile schema underspecified | High | High | P0 | Schema Design Before Story Writing |
| Worker identity model mismatch | Medium | High | P0 | Data Model Alignment with CO |
| Drools 8 SLA not validated | Medium | High | P1 | Performance Test Plan |
| Formula DSL security bypass | Low | Critical | P1 | Security Pentest (acceptance gate) |
| SI split-period calculation missing | Medium | High | P1 | Explicit Requirement + Test Case |
| T&A data not ready at cut-off | Medium | High | P1 | Pre-cut-off monitoring dashboard |
| Deep retroactive cascade timeout | Low-Medium | Medium | P2 | Load test + depth limit configuration |
| GL posting failure | Low | Medium | P2 | Async retry pattern |
| Data retention enforcement | Low | High | P2 | NFR + retention policy enforcement |

---

*Red-team analysis conducted against reference documents 00-08 (overview), 01-06 (analyze), DBML V3/V4, and PR conceptual guides.*
