# Total Rewards — Feature Catalog

> **Module**: Total Rewards / xTalent HCM
> **Step**: 5 — Product Experience Design
> **Date**: 2026-03-26
> **Countries**: VN (Phase 1), TH, ID, SG, MY, PH (Phase 2)

---

## Classification Legend

| Type | Description | Spec Depth |
|------|-------------|------------|
| **M** | Masterdata / Config / Setup — reference data, plan definitions, configuration | Light |
| **T** | Transaction — business operations with workflow, state machines, approvals | Deep |
| **A** | Analytics — reports, dashboards, insights, exports | Medium |

## Priority Legend

| Priority | Criteria |
|----------|----------|
| **P0** | MVP — Vietnam market, core compensation, SI calculation, payroll bridge |
| **P1** | Phase 2 — multi-country, advanced analytics, recognition, LTI, offer flow |
| **P2** | Future — AI/predictive, flex credits, pay equity AI |

---

## BC-01: Compensation Management

| ID | Feature Name | Type | Priority | Description | User Stories |
|----|-------------|------|----------|-------------|-------------|
| COMP-M-001 | Salary Basis Management | M | P0 | Define salary structures: HOURLY / MONTHLY / ANNUAL with associated pay components. Configuration per LegalEntity. [All countries] | - |
| COMP-M-002 | Pay Component Definition Management | M | P0 | Create/manage reusable pay components: BASE, ALLOWANCE, BONUS, DEDUCTION, OVERTIME. Includes taxability flags and proration eligibility. [All countries] | - |
| COMP-M-003 | Pay Range Management | M | P0 | Manage salary bands per Grade with SCD Type 2 versioning. Effective-dated ranges with min/mid/max. [All countries] | US-005 |
| COMP-M-004 | Compensation Cycle Configuration | M | P0 | Configure merit review cycle parameters: eligibility rules, budget %, approval routing thresholds, timeline. [All countries] | US-002 |
| COMP-T-001 | Merit Review Cycle Management | T | P0 | Full lifecycle: open cycle → manager proposes → director approves → publish. Multi-level approval with budget guardrails. [All countries] | US-002, US-003, US-004 |
| COMP-T-002 | Salary Change Activation | T | P0 | Individual salary change outside merit cycle: promotion, market adjustment, correction. Triggers SCD Type 2 record creation + payroll bridge event. [All countries] | US-022 |
| COMP-T-003 | Deduction Management | T | P0 | Create and manage recurring deductions: loan repayment, garnishment, salary advance. Tracks installment schedule and balance. [All countries] | US-010 |
| COMP-A-001 | Compensation Analytics Dashboard | A | P1 | Budget utilization, compa-ratio distribution, headcount by band, merit cycle metrics. Filterable by org unit, grade, country. [All countries] | US-016 |
| COMP-A-002 | Pay Equity Analysis | A | P2 | AI-assisted detection of pay gaps by gender, ethnicity, tenure. Requires 12+ months data. [All countries] | US-016 |

---

## BC-02: Calculation Engine

| ID | Feature Name | Type | Priority | Description | User Stories |
|----|-------------|------|----------|-------------|-------------|
| CALC-M-001 | Contribution Config Management | M | P0 | Configure SI/CPF/EPF rates per country/zone with effective dates. SCD Type 2. Plugin architecture: VietnamSIEngine, SingaporeCPFEngine. [VN-specific for Phase 1] | US-001, US-021 |
| CALC-M-002 | Min Wage Config Management | M | P0 | Zone-based minimum wage tables with effective dates. Vietnam: 4 zones (Vùng 1–4). [VN-specific for Phase 1] | US-005 |
| CALC-M-003 | Calculation Rule Management | M | P0 | Immutable formula rules for proration, overtime, SI cap calculation. Insert-only versioning (BR-K04). [All countries] | US-012, US-020 |
| CALC-M-004 | FX Rate Management | M | P1 | Daily exchange rates with delta threshold alerts. Finance Approver override requires justification. [Multi-country] | - |
| CALC-M-005 | Proration Config Management | M | P0 | Configure proration methods per LegalEntity: CalendarDays, WorkingDays, Fixed30. [All countries] | US-012, US-020 |
| CALC-T-001 | SI Contribution Calculation Run | T | P0 | Automated calculation of BHXH/BHYT/BHTN employer + employee contributions. Zone-based cap (20× min wage). Audit trail. [VN-specific] | US-001 |
| CALC-T-002 | Proration Calculation | T | P0 | Mid-period join/exit/change proration. Configurable method per legal entity. [All countries] | US-012 |
| CALC-A-001 | Calculation Audit Report | A | P0 | Per-worker breakdown of each calculation run: inputs, formulas, outputs, applied rules. [All countries] | US-006 |

---

## BC-03: Variable Pay

| ID | Feature Name | Type | Priority | Description | User Stories |
|----|-------------|------|----------|-------------|-------------|
| VPAY-M-001 | Bonus Plan Management | M | P0 | Configure bonus plans: eligibility, calculation formula, payout schedule, approval routing. [All countries] | US-008 |
| VPAY-M-002 | Commission Plan Management | M | P0 | Configure commission plans: quota, tiers, accelerators, effective dates. [All countries] | US-009 |
| VPAY-M-003 | LTI Grant Management | M | P1 | Configure long-term incentive programs: vesting schedule, grant types (RSU, Options). [All countries] | - |
| VPAY-T-001 | Bonus Calculation Run | T | P0 | Calculate bonus for eligible workers based on plan formula + performance inputs. Idempotency key prevents double payment. [All countries] | US-008 |
| VPAY-T-002 | Commission Real-Time Dashboard | T | P0 | Real-time commission tracking: quota attainment, running total, tier progression. WebSocket push < 5s. [All countries] | US-009, US-017 |
| VPAY-T-003 | Commission Dispute Resolution | T | P1 | Worker raises dispute on transaction; Sales Ops reviews, adjusts, approves. Audit trail throughout. [All countries] | US-023 |
| VPAY-T-004 | LTI Grant Activation | T | P1 | Issue LTI grants to eligible workers. Vesting schedule tracking. [All countries] | - |
| VPAY-A-001 | Variable Pay Analytics | A | P1 | Bonus pool utilization, commission payout trends, plan effectiveness metrics. [All countries] | - |

---

## BC-04: Benefits Administration

| ID | Feature Name | Type | Priority | Description | User Stories |
|----|-------------|------|----------|-------------|-------------|
| BENE-M-001 | Benefit Plan Management | M | P0 | Configure health, dental, vision, life insurance plans. Eligibility rules, coverage tiers, carrier mapping. [All countries] | US-007 |
| BENE-M-002 | Dependent Type Config | M | P0 | Configure eligible dependent types (Spouse, Child, Parent) per country regulations. [All countries] | US-007 |
| BENE-T-001 | Benefits Open Enrollment | T | P0 | Annual enrollment window: worker selects plans, adds dependents, confirms elections. EDI 834 carrier sync. [All countries] | US-007 |
| BENE-T-002 | Life Event Enrollment | T | P1 | Mid-year enrollment triggered by life events: marriage, birth, divorce. Eligibility re-evaluated. [All countries] | US-024 |
| BENE-T-003 | Carrier Sync Management | T | P1 | Monitor EDI 834 carrier sync: status, errors, retry. [All countries] | US-007 |
| BENE-A-001 | Benefits Analytics | A | P1 | Enrollment rates, cost per plan, dependent demographics. [All countries] | - |

---

## BC-05: Recognition & Engagement

| ID | Feature Name | Type | Priority | Description | User Stories |
|----|-------------|------|----------|-------------|-------------|
| RECG-M-001 | Recognition Program Management | M | P1 | Configure recognition programs: point budget, award categories, monetary value, expiry policy. [All countries] | US-018 |
| RECG-M-002 | Reward Catalog Management | M | P1 | Manage redeemable rewards: gift cards, merchandise, experiences. [All countries] | US-018 |
| RECG-T-001 | Send Recognition | T | P1 | Worker/Manager sends recognition with points award. Triggers Taxable Bridge if monetary value. [All countries] | US-018 |
| RECG-T-002 | Points Redemption | T | P1 | Worker redeems points for rewards from catalog. FIFO point consumption. [All countries] | US-018 |
| RECG-A-001 | Recognition Analytics | A | P2 | Recognition activity, engagement rates, top recognizers/recipients. [All countries] | - |

---

## BC-06: Offer Management

| ID | Feature Name | Type | Priority | Description | User Stories |
|----|-------------|------|----------|-------------|-------------|
| OFFR-M-001 | Offer Template Management | M | P1 | Create and manage offer letter templates per job family/country. [All countries] | US-014 |
| OFFR-T-001 | Offer Creation & Approval | T | P0 | Hiring Manager creates offer, system validates min wage, routes for approval, sends to candidate. [All countries] | US-014, US-005 |
| OFFR-T-002 | Offer E-Signature | T | P1 | Candidate reviews offer, accepts/declines with e-signature. Multi-provider: DocuSign/SignNow. [All countries] | US-015 |

---

## BC-07: TR Statement

| ID | Feature Name | Type | Priority | Description | User Stories |
|----|-------------|------|----------|-------------|-------------|
| STMT-A-001 | Total Rewards Annual Statement | A | P1 | Annual snapshot of total compensation value: cash, benefits, recognition, LTI. PDF download. [All countries] | US-019 |
| STMT-A-002 | Salary Pay Slip View | A | P0 | Worker self-service view of current gross breakdown, SI deductions, net pay. Salary history timeline. [All countries] | US-022 |

---

## BC-08: Taxable Bridge

| ID | Feature Name | Type | Priority | Description | User Stories |
|----|-------------|------|----------|-------------|-------------|
| BRDG-T-001 | Taxable Item Processing | T | P0 | Aggregate taxable events from all BCs. Idempotency key dedup. Batch send to Payroll. [All countries] | US-013 |
| BRDG-A-001 | Taxable Bridge Dashboard | A | P0 | Monitor taxable item flow: pending, sent, failed, retry. Payroll sync status. [All countries] | US-013 |

---

## BC-09: Tax & Compliance

| ID | Feature Name | Type | Priority | Description | User Stories |
|----|-------------|------|----------|-------------|-------------|
| TAXC-M-001 | Tax Bracket Configuration | M | P0 | Configure PIT tax brackets per country with SCD Type 2 versioning. [VN-specific for Phase 1] | US-011 |
| TAXC-M-002 | Tax Profile Management | M | P0 | Worker-level tax profile: residency status, exemptions, dependent deductions. [VN-specific] | US-011 |
| TAXC-T-001 | Tax Withholding Calculation | T | P0 | Monthly PIT withholding based on gross income, bracket, and profile. [VN-specific] | US-011 |
| TAXC-T-002 | Year-End Tax Settlement | T | P1 | Annual PIT reconciliation and e-filing. Dual-path: API + file. [VN-specific] | US-011 |
| TAXC-A-001 | Tax Compliance Dashboard | A | P1 | Withholding summary, e-filing status, compliance gap alerts. [VN-specific] | US-011 |

---

## BC-10: Audit & Observability

| ID | Feature Name | Type | Priority | Description | User Stories |
|----|-------------|------|----------|-------------|-------------|
| AUDT-A-001 | Audit Trail Viewer | A | P0 | Immutable, append-only audit log of all TR changes. Filterable by actor, entity, date. Scoped read-only for external auditors. [All countries] | US-006 |
| AUDT-A-002 | Compliance Report Export | A | P1 | Export audit records in regulatory format: CSV/PDF. [All countries] | US-006 |

---

## Feature Count Summary

| BC | Masterdata | Transaction | Analytics | Total |
|----|-----------|------------|----------|-------|
| BC-01 Compensation | 4 | 3 | 2 | 9 |
| BC-02 Calculation | 5 | 2 | 1 | 8 |
| BC-03 Variable Pay | 3 | 4 | 1 | 8 |
| BC-04 Benefits | 2 | 3 | 1 | 6 |
| BC-05 Recognition | 2 | 2 | 1 | 5 |
| BC-06 Offer Mgmt | 1 | 2 | 0 | 3 |
| BC-07 TR Statement | 0 | 0 | 2 | 2 |
| BC-08 Taxable Bridge | 0 | 1 | 1 | 2 |
| BC-09 Tax & Compliance | 2 | 2 | 1 | 5 |
| BC-10 Audit | 0 | 0 | 2 | 2 |
| **TOTAL** | **19** | **19** | **12** | **50** |

## Priority Distribution

| Priority | Count | % |
|----------|-------|---|
| P0 | 21 | 42% |
| P1 | 22 | 44% |
| P2 | 7 | 14% |

---

*Feature Catalog — Total Rewards / xTalent HCM — Step 5 Experience Design*
*2026-03-26*
