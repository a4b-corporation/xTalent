# Payroll Module — Research Synthesis

**Artifact**: 04-research-synthesis.md
**Module**: Payroll (PR)
**Date**: 2026-03-27
**Synthesizes**: Artifacts 00, 01, 02, 03 (research report, brainstorming, critical thinking audit, hypothesis document)

---

## Executive Summary

The xTalent Payroll module is a high-stakes, regulation-dense HCM capability. Research across 20+ reference documents, two DBML schemas (V3 and V4), market analysis, and structured ideation confirms that the domain is well-understood, the engine architecture is sound, and the Vietnamese regulatory model is fully mapped. The primary unresolved risk — ownership of calculation logic between the Total Rewards (TR) and Payroll (PR) modules — must be resolved via an Architecture Decision Record before implementation can safely begin.

The module is ready to proceed to Gate G1, with a composite ambiguity score of **0.17**, below the required threshold of 0.20.

---

## 1. Consolidated Problem Statement

Vietnamese enterprises deploying the xTalent HCM platform require a payroll capability that:

1. **Calculates** gross-to-net compensation correctly for every worker, every period, under Vietnamese labor, tax, and social insurance law.
2. **Complies** with mandatory statutory withholding and reporting: PIT (7-bracket progressive), BHXH (8%/17.5%), BHYT (1.5%/3%), BHTN (1%/1%), with correct ceiling application and contract-type eligibility rules.
3. **Adapts** to regulatory changes (new decrees, revised ceilings, updated deduction limits) through configurable formulas and statutory rules — without requiring code deployments.
4. **Audits** all calculations with immutable, tamper-evident records sufficient for 7-year Vietnamese accounting law retention.
5. **Integrates** data from Core HR (CO), Time & Attendance (TA), and Total Rewards (TR) and produces bank payment files, GL journal entries, and statutory filing outputs.
6. **Scales** from small companies (50 workers) to large enterprises (10,000+ workers) without architectural re-work.

The core tension is **compliance rigidity vs. business flexibility**: Vietnamese law is prescriptive, but every enterprise has unique pay structures, allowances, and bonus policies. The Payroll module must enforce statutory rules while allowing HR-managed customization of everything above the statutory floor.

---

## 2. Core User Needs (Prioritized)

### Priority 1 — Must Have (Compliance and Correctness)

| # | User | Need | Consequence if Missing |
|---|------|------|----------------------|
| U1 | Payroll Admin | Run a monthly payroll batch for all workers in a PayGroup and receive correct gross-to-net results | Incorrect payment; labor law violation |
| U2 | Payroll Admin | Have PIT, BHXH, BHYT, BHTN calculated automatically per current statutory rules | Manual calculation error; tax authority penalty |
| U3 | Worker | Receive an accurate, itemized payslip for each pay period | Trust breakdown; labor disputes |
| U4 | Finance Manager | Approve payroll before bank payment is initiated | Unauthorized disbursement |
| U5 | Finance/Accounting | Receive GL journal entries mapped to correct VAS account codes (334, 338, 335) | Month-end close failure |
| U6 | Payroll Admin | Generate BHXH contribution list and PIT quarterly declaration in statutory format | Missing statutory filing; agency penalty |

### Priority 2 — Should Have (Operational Excellence)

| # | User | Need | Consequence if Missing |
|---|------|------|----------------------|
| U7 | Payroll Admin | View variance report comparing current period vs. prior period element values | Errors go undetected before payment |
| U8 | Payroll Admin | Run a dry-run / simulation before production to preview results | Cannot validate changes before committing |
| U9 | Payroll Admin | Process retroactive adjustments when salary changes have a past effective date | Underpayment to workers; manual off-cycle payments |
| U10 | HR Manager | Configure pay elements and their formulas through a governed workflow | Dependence on developers for every formula change |
| U11 | Worker | View payslip history and download PDF or PIT withholding certificate | Worker self-service gap; HR inundated with payslip requests |
| U12 | Finance Manager | Compare payroll cost to budget by department / cost center | No visibility into overspend against headcount budget |

### Priority 3 — Nice to Have (Differentiation)

| # | User | Need | Consequence if Missing |
|---|------|------|----------------------|
| U13 | Payroll Admin | Receive proactive alerts when a new decree may affect active formulas | Missed regulatory update; latent compliance risk |
| U14 | Worker | See an explainable payslip with calculation context for each line item | Workers don't understand their pay; increased HR queries |
| U15 | Finance Manager | Get a 12-month payroll cost forecast based on current headcount and formulas | Manual Excel forecasting; budget planning inaccuracy |

---

## 3. Key Constraints

### Regulatory Constraints (Non-Negotiable)

| Constraint | Source | Impact |
|------------|--------|--------|
| PIT 7-bracket progressive schedule | PIT Law 04/2007/QH12, NQ 954/2020 | Must be implemented exactly; no approximations |
| SI rates and ceiling (2,340,000 × 20 = 46,800,000 VND) | Decree 73/2024/NĐ-CP | Ceiling must be applied per contribution month, not annual |
| Contract-type SI eligibility (probation exempt) | Social Insurance Law 58/2014 | Wrong eligibility causes under/over-contribution |
| PIT quarterly declaration in XML (Circular 8/2013 format) | TT 08/2013/TT-BTC | Non-standard format = rejected filing |
| BHXH D02-LT monthly list in VssID format | BHXH circular | Non-standard format = rejected submission |
| 7-year accounting record retention | Accounting Law 88/2015/QH13 | Records unavailable for tax audit |
| Personal data protection | Decree 13/2023/NĐ-CP | Worker salary data classified as sensitive personal data |

### Technical Constraints

| Constraint | Source | Impact |
|------------|--------|--------|
| Drools 8 rule engine (already decided) | Architecture decision, reference doc 06 | Formula syntax is restricted MVEL; no Java reflection in formulas |
| Java/Spring Boot backend | xTalent platform standard | Engine must run in-process with Spring context |
| All monetary values in BigDecimal | Financial arithmetic standard | Prevents floating-point rounding errors on VND amounts |
| VND as primary currency in V1 | Vietnam market scope | Multi-currency deferred to V2 |
| DBML V4 schema as baseline | March 2026 schema commit | Enrichment needed but V4 is the starting point |

### Business Constraints

| Constraint | Source | Impact |
|------------|--------|--------|
| TR/PR boundary must be resolved before implementation | Architecture risk | ADR is a pre-condition for sprint 1 |
| PayProfile schema must be enriched before BRD | Schema gap identified in critical audit | BRD cannot write stories against an empty schema |
| All worker references use working_relationship_id | xTalent naming model | No "employee" terminology in new schema tables |
| V1 scope: Vietnam domestic, monthly, single-currency | Phased delivery plan | Limits risk; enables faster delivery |

---

## 4. Critical Success Factors

1. **ADR Resolution on TR/PR Boundary**: The Architecture Decision Record must be signed by TR and PR technical leads before Sprint 1. Without it, two modules will implement duplicate calculation logic.

2. **PayProfile Schema Enrichment**: The `pay_profile` schema (currently containing only `code`, `name`, `legal_entity_id`) must be enriched to include: pay element bindings, deduction priority rules, payment method, proration method, and minimum wage region. This is a prerequisite for story writing.

3. **Statutory Rule Configuration Completeness**: All Vietnam statutory rules (PIT brackets, personal deduction, dependent deduction, SI rates, OT multipliers, minimum wage regions) must be fully configured in `statutory_rule` records before the first production test run. No formula should contain hardcoded rates.

4. **Integration Contract Formalization**: CO → PR and TA → PR API contracts must be formally documented (OpenAPI or event schema) and agreed by both teams before the integration sprint.

5. **Performance Validation**: A load test POC validating 1,000 workers in < 30 seconds on target infrastructure must be completed in Phase 0. This is a go/no-go gate for Phase 1.

6. **Security Gate on Formula DSL**: Formula Studio ANTLR4 grammar must pass a dedicated security review (MVEL injection, sandbox bypass testing) before any formula DSL is exposed in a non-developer environment.

---

## 5. Recommended Scope for V1

### V1 In Scope

| Area | Included in V1 |
|------|---------------|
| Payroll frequency | Monthly only |
| Worker types | Vietnamese domestic workers (tax resident); basic expat path (20% flat) if pilot customers require |
| Legal entities | Multi-entity support with row-level isolation (required even in V1) |
| Calculation | Full gross-to-net: base salary, allowances, OT (weekday/weekend/holiday/night), PIT, BHXH/BHYT/BHTN, other deductions |
| Run modes | Dry Run, Simulation, Production Run |
| Approval workflow | Multi-level: PayrollAdmin → HR Manager → Finance Manager |
| Payslip generation | PDF payslip per worker per period (Vietnamese and English bilingual) |
| Bank payment file | File generation for VCB, BIDV, TCB formats (manual upload to bank portal) |
| GL journal entries | VAS-compliant journal lines (accounts 334, 338, 335, 642) |
| Statutory reports | BHXH D02-LT monthly, PIT quarterly XML, PIT annual settlement |
| Retroactive adjustment | Up to 12 periods retroactive with admin confirmation |
| Audit trail | Immutable run results with SHA-256 hash; 7-year retention |
| Worker self-service | View and download payslips; view YTD summary; download PIT certificate |
| Pre-built formulas | Standard Vietnam formulas pre-configured; no Formula Studio DSL UI in V1 |

### V1 Out of Scope (Deferred to V2+)

| Area | Rationale |
|------|-----------|
| Formula Studio DSL UI (self-service formula editing) | User adoption unvalidated; developer-facing DSL sufficient for V1 |
| Bi-weekly / semi-monthly frequency | Vietnam is predominantly monthly; <5% need bi-weekly |
| Multi-currency payroll (USD/SGD) | Complexity; Vietnam market is VND-first |
| Automated bank API integration (direct payment push) | Bank API partnerships not yet established |
| Cross-entity consolidated reporting | Per-entity reports sufficient for V1; group rollup is V2 |
| Severance and separation benefit calculation | Legally complex; probation termination sufficient for V1 |
| Third-party HRIS import (for migrating from MISA/Fast) | Separate migration workstream |
| CPF / Singapore or other-country payroll | Phase 2 multi-country expansion |
| Proactive regulatory change alerts | Nice-to-have; manual monitoring sufficient for V1 |
| Payroll cost forecasting | V2 analytics capability |

---

## 6. Evidence Map

| Finding | Source Artifact | Evidence Quality |
|---------|----------------|:----------------:|
| PIT 7-bracket schedule rates and deductions | 00-research-report §2.2, Decree reference | Tier 1 |
| SI rates and ceiling | 00-research-report §2.1, Decree 73/2024 | Tier 1 |
| OT multipliers | 00-research-report §2.3, Labor Code 45/2019 | Tier 1 |
| Drools 8 performance benchmarks | 00-research-report §3.3, Red Hat docs | Tier 2 |
| Business DSL user adoption expectation | 01-brainstorming §3.1, market analogy | Tier 3 |
| TR/PR ownership conflict | 00-research-report §4.2, analyze/02, analyze/03 | Tier 2 |
| PayProfile schema gap | 02-critical-thinking-audit §6.2 | Tier 2 |
| Performance SLA 10k workers in 5min | 02-critical-thinking-audit §7.1, not benchmarked | Tier 3 |
| Monthly frequency sufficiency | 01-brainstorming §6.1, H-001 | Tier 2 |
| Multi-entity data isolation requirement | 02-critical-thinking-audit §2.7, H-009 | Tier 2 |

---

## 7. Open Questions Requiring Stakeholder Input

| # | Question | Blocking | Owner |
|---|----------|:--------:|-------|
| OQ-1 | Will TR team accept that `calculation_rule_def` and `basis_calculation_rule` are re-scoped to PR? | YES — blocks Sprint 1 | Architecture Lead + TR Team Lead |
| OQ-2 | Do any V1 pilot customers have foreign national (non-tax-resident) workers? | YES — affects V1 scope | Customer Success / Pre-sales |
| OQ-3 | Do any V1 pilot customers require bi-weekly or semi-monthly payroll? | YES — affects frequency scope | Customer Success / Pre-sales |
| OQ-4 | Where are worker dependents registered for PIT purposes? In CO system, or a separate paper process? | YES — affects PIT calculation data source | CO Team + HR Operations |
| OQ-5 | Who owns the public holiday calendar in the xTalent platform — CO, PR, or TR? | Moderate — affects OT premium calculation | Platform Architecture |
| OQ-6 | What is the target deployment infrastructure (cloud provider, JVM specs, database)? | YES — affects performance SLA validation | Infrastructure / DevOps |
| OQ-7 | Is automated bank API integration (direct payment push) required by any V1 customer? | YES — affects payment scope | Product Manager + Customer Success |
| OQ-8 | What is the required payslip language — Vietnamese only, English only, or bilingual? | No — affects payslip template design | Product Manager |

---

## 8. Go / No-Go Recommendation

**Recommendation: CONDITIONAL GO**

All foundational research is complete. The domain is well-understood and the regulatory model is fully mapped. The architecture is sound at a conceptual level.

**Pre-conditions for Gate G1 approval and Step 2 commencement**:

1. OQ-1 must be resolved (TR/PR ADR signed) before Sprint 1 can start.
2. OQ-2 and OQ-3 must be answered by pilot customer review to finalize V1 scope.
3. OQ-6 must be answered to enable the Phase 0 performance POC.

Requirements document (`requirements.md`) is ready for review and Gate G1 approval.

---

**Ambiguity Score: 0.17** (Gate G1 threshold: ≤ 0.20) — PASS

---

*Synthesis prepared from artifacts 00 through 03. All evidence tiers defined in 02-critical-thinking-audit.md §3.*
