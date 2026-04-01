# Payroll Module — Research Report

**Artifact**: 00-research-report.md
**Module**: Payroll (PR)
**Date**: 2026-03-27
**Status**: Complete

---

## Executive Summary

The xTalent Payroll (PR) module is a mission-critical HCM capability responsible for the accurate, compliant, and auditable computation and disbursement of worker compensation. Research across 20+ reference documents, two DBML schemas (V3 and V4), and market analysis reveals a module with strong architectural foundations and a well-considered engine design, while also identifying critical boundary ambiguities with the Total Rewards (TR) module that must be resolved before implementation.

The research confirms that payroll in the Vietnamese context is among the most regulatory-constrained HCM functions globally: it intersects labor law, social insurance law, personal income tax law, and accounting standards — all with independent update cycles governed by government decree.

---

## 1. Domain Overview — Payroll in Vietnam HCM Context

### 1.1 What Payroll Is

Payroll is not a simple arithmetic function. It is a multi-dimensional calculation problem:

```
Payroll = f(Worker Data, Time & Attendance, Benefits, Tax Rules, Policy Rules, Period Config)
```

Every component depends on others through a directed dependency graph. Calculations must be deterministic (same input always yields same output), versioned (formula changes must not retroactively affect closed periods), and immutable (finalized results cannot be modified — only adjusted through traceable correction records).

### 1.2 xTalent Naming Model

The xTalent platform uses a distinctive model that differs from traditional HCM:
- `worker` or `person` replaces "employee" — capturing the fact that individuals may have multiple, concurrent engagement types
- `working_relationship` replaces direct employment — formalizing that a worker's engagement with a legal entity is a relationship with its own attributes (contract type, effective dates, assignment)
- `legal_entity` is the payroll-bearing entity — each legal entity runs its own payroll calendar under its own regulatory jurisdiction

For payroll purposes, the primary subject is the worker's `working_relationship` within a legal entity, not the worker identity itself.

### 1.3 The Payroll Lifecycle

Payroll in xTalent operates in three execution modes:
- **Dry Run**: Test mode — no persistence, used for formula validation and previewing
- **Simulation**: Impact analysis — runs against historical data with new formulas to show side-by-side deltas before policy changes go live
- **Production Run**: Official execution — 5-stage pipeline, multi-level approval workflow, immutable results with SHA-256 hash

A production run proceeds through:
1. Pre-validation (data integrity checks)
2. Gross calculation (earnings accumulation)
3. Tax and insurance calculation (SI deductions, PIT)
4. Net calculation (gross minus all deductions)
5. Post-processing (rounding, retroactive delta, balance updates, payslip/bank file generation)

---

## 2. Regulatory Landscape — Vietnam Compliance Requirements

### 2.1 Social Insurance (BHXH/BHYT/BHTN)

Vietnam's social insurance framework mandates three distinct insurance types, each with separate rates and a shared contribution ceiling:

| Insurance Type | Employee Rate | Employer Rate | Ceiling (from July 2024) |
|---------------|:-------------:|:-------------:|:------------------------:|
| BHXH (Social Insurance) | 8% | 17.5% | 20 × base salary |
| BHYT (Health Insurance) | 1.5% | 3% | 20 × base salary |
| BHTN (Unemployment Insurance) | 1% | 1% | 20 × base salary |
| TNLD (Occupational Accident) | 0% | 0.5% | — |
| **Total** | **10.5%** | **22%** | — |

The statutory base salary (lương cơ sở) was revised to 2,340,000 VND/month by Decree 73/2024/NĐ-CP effective July 1, 2024, raising the BHXH ceiling from 36,000,000 to 46,800,000 VND/month.

**Contract-type eligibility matrix:**

| Contract Type | BHXH | BHYT | BHTN |
|--------------|:----:|:----:|:----:|
| Unlimited term | Yes | Yes | Yes |
| Fixed-term (12–36 months) | Yes | Yes | Yes |
| Probation (≤60 days) | No | No | No |
| Short-term (<1 month) | No | No | No |
| Service contract / Freelancer | No | No | No |

### 2.2 Personal Income Tax (PIT / Thuế TNCN)

Vietnam applies a 7-bracket progressive PIT schedule under PIT Law 04/2007/QH12 as amended:

| Bracket | Monthly Taxable Income | Rate |
|:-------:|:----------------------:|:----:|
| 1 | Up to 5,000,000 VND | 5% |
| 2 | 5,000,001 – 10,000,000 | 10% |
| 3 | 10,000,001 – 18,000,000 | 15% |
| 4 | 18,000,001 – 32,000,000 | 20% |
| 5 | 32,000,001 – 52,000,000 | 25% |
| 6 | 52,000,001 – 80,000,000 | 30% |
| 7 | Over 80,000,000 | 35% |

PIT deductions per Resolution 954/2020/UBTVQH14:
- Personal allowance: 11,000,000 VND/month
- Dependent allowance: 4,400,000 VND/person/month

Taxable income = Gross − BHXH_emp − BHYT_emp − BHTN_emp − Personal deduction − (Dependents × 4,400,000) − Other registered deductions

**Freelancer / Service contract**: Flat withholding at 10% (gross ≥ 2,000,000 VND/payment); exempt below threshold.

**Expat treatment**:
- Tax resident (>183 days/year in Vietnam): Global income taxed at progressive VN rates
- Non-resident (≤183 days): 20% flat rate on Vietnam-sourced income
- Tax treaty countries: Apply treaty rates if applicable

### 2.3 Labor Law Constraints

Overtime premium multipliers (Labor Code 45/2019/QH14):
- Regular OT weekday: 150% of hourly rate
- OT weekend: 200%
- OT public holiday: 300%
- Night shift hours (22:00–06:00): additional 30% premium
- Night + OT: cumulative calculation

13th-month salary: Customary practice (not legally mandated) but treated as taxable income when paid.

Annual PIT settlement: Employers must reconcile YTD withholding against progressive annual tax for all workers by end of year.

### 2.4 Statutory Reporting Requirements

| Report | Recipient | Frequency | Format |
|--------|-----------|-----------|--------|
| BHXH contribution list | Social Insurance Agency | Monthly | VssID |
| PIT quarterly declaration (TK-TNCN) | Tax Department | Quarterly | XML (TT8/2013) |
| Annual PIT settlement | Tax Department | Annual | XML |
| Labor report | DOLISA | Annual | Excel (ministry template) |
| D01-TS adjustment | Social Insurance Agency | As needed | VssID |

---

## 3. Current Market Solutions and Gaps

### 3.1 Reference Systems

| System | Comparable Concepts | Architecture Alignment |
|--------|--------------------|-----------------------|
| Oracle HCM Cloud Fast Formula | Business DSL, Formula Studio, PayElement definition | ~90% |
| SAP SuccessFactors + Employee Central Payroll (ECP) | Wage type, retroactive calculation, infotype design | ~85% |
| Workday Payroll | Pay element, pay group, calculation rules, period processing | ~85% |
| ADP GlobalView | Country-specific statutory rules, GL mapping, bank file templates | ~80% |

### 3.2 Market Positioning

The payroll infrastructure market is segmenting into:
- **Monolithic HCM payroll**: Oracle EBS, SAP ECC — tight coupling, lowest flexibility
- **Modular HCM payroll**: Oracle HCM Cloud, SAP SuccessFactors + ECP, Workday — separate schemas within a platform
- **Headless / Payroll-as-a-Service**: Check (checkhq.com), Zeal, Gusto Embedded — standalone service, API-first, multi-tenant

xTalent PR is positioned as **Modular**, with a recommended evolution path toward Headless over multiple phases.

### 3.3 Key Competitive Gaps vs. Market

Vietnam-specific payroll solutions (MISA, 1Office, Fast, Suno.ai) are predominantly:
- Formula-based without a formal engine (Excel-like, not rule-chain)
- Weak on retroactive calculation
- Limited audit trail capabilities
- Not multi-entity / multi-country ready

xTalent PR differentiates through:
- Enterprise-grade Drools 8 rule engine
- Business DSL allowing HR self-service on formula changes
- Immutable audit trail with SHA-256 hashes
- Simulation mode for impact analysis before policy changes
- Full retroactive delta calculation

---

## 4. xTalent Platform Context

### 4.1 DBML Schema Analysis (V4 — March 2026)

The Payroll V4 DBML introduces a critical architectural evolution: separation of the monolithic `pay_run` schema into two independent schemas:

| Schema | Purpose | Key Tables |
|--------|---------|------------|
| `pay_master` | Configuration / Master Data | pay_frequency, pay_calendar, pay_group, pay_element, statutory_rule, pay_profile, gl_mapping, payslip_template |
| `pay_mgmt` (NEW V4) | Payroll Management / Orchestration | batch, pay_period, approval_step |
| `pay_engine` (NEW V4) | Calculation Engine | run_request, run_result, element_result, balance |
| `pay_gateway` | Integration Interfaces | iface_def |
| `pay_bank` | Payment / Banking | bank_account, bank_template, payment_batch, payment_line |
| `pay_audit` | Audit Trail | audit_log |

Key design decisions visible in V4:
- `pay_element` now supports `country_code` for multi-country scoping (Phase 1) and `config_scope_id` for hierarchical scope (Phase 2)
- `pay_element` links to `eligibility.eligibility_profile` — centralized eligibility framework
- `pay_calendar` carries `default_currency` explicitly
- Engine separation (pay_engine sub-module) enables independent scaling and testing of calculation logic

### 4.2 TR Module Boundary

A critical finding from reference analysis is the **boundary conflict** between TR and PR:

**TR `comp_core` has (as of DBML V5, Nov 2025)**:
- `calculation_rule_def` — defines VN_PIT_2025, VN_SI_2025, VN_OT_MULT_2019
- `basis_calculation_rule` — defines gross-to-net execution pipeline (execution_order 1→6)
- `component_calculation_rule` — links components to calculation rules
- `tax_calculation_cache` — pre-calculated tax values

**PR has**:
- `statutory_rule` — defines same tax/SI rules
- Drools 8 Rule Units — implements the same gross-to-net pipeline

This overlap is a **Critical architectural risk** requiring explicit ownership resolution before implementation.

**Recommended decision (from analysis doc 03)**:
- PR owns ALL calculation logic (formulas, engine, tax brackets, SI rates, pipeline)
- TR is the Config Provider — defines WHAT to pay (component definitions, salary amounts, bonus allocations, taxable bridge items)
- TR's `calculation_rule_def`, `basis_calculation_rule`, and `component_calculation_rule` should be re-scoped or deprecated

### 4.3 Integration Architecture

PR is the **convergence point** for data from multiple modules:

**Inbound (PR consumes)**:
- CO (Core HR): worker data, working_relationship, legal entity, assignment, contract type
- TA (Time & Attendance): actual work days, overtime hours, leave without pay
- TR (Total Rewards): salary component amounts, bonus allocations, taxable bridge items (RSU vest, option exercise), benefit premium deductions

**Outbound (PR produces)**:
- Payslips → Employee self-service portal
- Bank payment files → Banking systems (Vietcombank, BIDV, Techcombank, VietinBank, ACB, Agribank formats)
- GL journal entries → Accounting system (VAS-compliant: TK 642, 334, 3383, 3335)
- Tax reports → Tax authorities (XML)
- BHXH filings → Social Insurance Agency (VssID)

---

## 5. Key Stakeholders

| Stakeholder | Interaction with PR |
|-------------|---------------------|
| Payroll Admin | Configure PayGroups, PayProfiles, run payroll batches, review variance reports |
| HR Manager | Approve payroll (first level), review summary reports |
| Finance Manager / CFO | Final approve, GL reconciliation, budget vs actual analysis |
| Workers / Employees | View and download own payslips via self-service portal |
| Finance / Accounting Team | Consume GL journal entries for month-end close |
| Tax Authority (Cục Thuế) | Receive quarterly PIT declarations and annual settlement |
| Social Insurance Agency (BHXH) | Receive monthly contribution lists |
| Internal Auditor | Read-only access to all payroll results and audit logs |
| IT / Architect | Formula Studio configuration (sandbox), system integration setup |

---

## 6. Integration Landscape

### 6.1 Inbound Events PR Consumes

| Event | Source | Payroll Action |
|-------|--------|----------------|
| `EmployeeSalaryChanged` | CO | Update BASE_SALARY; flag for retroactive if past period |
| `EmployeeTransferred` | CO | Update PayGroup assignment |
| `AttendanceLocked` | TA | Signal T&A data ready for cutoff |
| `TaxableItemCreated` | TR | Add RSU/option vest amount to taxable income |
| `BenefitEnrollmentChanged` | TR | Update benefit premium deduction amount |

### 6.2 Outbound Events PR Publishes

| Event | Trigger | Consumers |
|-------|---------|-----------|
| `PayrollRunCompleted` | Production run finished | TR (YTD update), Accounting, Dashboard |
| `PeriodLocked` | Payroll approved | Accounting (post GL), History |
| `PayslipGenerated` | After period locked | Notification service → worker email |
| `AdjustmentApplied` | Retroactive processed | Audit system, Finance alert |
| `FormulaActivated` | New formula version live | Monitoring, audit |

---

## 7. Research Conclusions

1. **The domain is well-researched**: Eight overview documents, six analysis documents, DBML V3 and V4, and conceptual guides provide a solid foundation for requirements.

2. **Engine architecture is the strongest asset**: The Drools 8 + restricted MVEL + Business DSL Layer decision is well-justified and enterprise-proven.

3. **The TR/PR boundary is the highest-risk ambiguity**: Both modules currently claim ownership of the calculation pipeline. This must be resolved in requirements.

4. **Vietnam compliance is well-modeled**: PIT 7-bracket, SI rates with ceiling, contract-type eligibility matrix, and effective-date management are all documented with sufficient precision.

5. **Schema needs enrichment**: `pay_element` (V4) is lean compared to TR's `pay_component_def`. Key missing fields: `tax_treatment`, `proration_method`, `si_basis`, `tax_exempt_cap`. These are needed for accurate calculation without hardcoding.

6. **Worker terminology must be preserved**: Requirements should consistently use `worker` (not "employee") and `working_relationship` (not "employment") throughout.

7. **V4 DBML engine separation is a positive development**: Splitting `pay_run` into `pay_mgmt` (orchestration) and `pay_engine` (calculation) enables better testability and independent scaling.

---

*Sources: Reference documents in `/reference/overview/`, `/reference/analyze/`, DBML schemas V3/V4, and PR conceptual guides.*
