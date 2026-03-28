# Hot Spots Register: Total Rewards Event Storming

**Domain**: Total Rewards (TR)
**Scope**: Multi-country Southeast Asia (6 countries: VN, TH, ID, SG, MY, PH)
**Innovation Level**: Full Innovation Play
**Timeline**: Fast Track
**Created**: 2026-03-20
**Status**: DRAFT

---

## P0 — Must Resolve Before Design

| ID | Hot Spot | Category | Related Event/Command | Impact | Owner | Status |
|----|----------|----------|----------------------|--------|-------|--------|
| H01 | ❓ **Vietnam SI Law 2024**: How to handle 17.5%+8% BHXH, 3%+1.5% BHYT, 1%+1% BHTN calculation with 20× salary cap that changes per region? | Compliance | `SIContributionCalculated`, `SIContributionUpdated` | Blocks calculation engine design; non-compliance = VND 50-100M fines | BA + Compliance | Open |
| H02 | ❓ **Multi-country FX**: Which FX rate source for salary/bonus conversion? Central bank, commercial bank, or Reuters? How to handle mid-cycle rate changes >5%? | Currency | `CurrencyConverted`, `ExchangeRateUpdated` | Blocks multi-currency design; consolidated reporting accuracy at risk | Tech Lead + Finance | Open |
| H03 | ❓ **Data Residency**: Can Vietnamese employee data (PII, salary) cross borders for regional reporting? What about Singapore PDPA, Indonesia PDP Law? | Data Privacy | `EmployeeDataExported`, `RegionalReportGenerated` | Blocks architecture design; potential criminal liability under PDPA | Legal + Tech Lead | Open |
| H04 | ❓ **Tax Authority Integration**: What if e-Filing API is down during filing deadline (last day of month)? Fallback to manual filing? | Integration | `TaxFilingSubmitted`, `TaxFilingFailed` | Blocks compliance design; late filing penalties up to 100% of under-withheld tax | Tech Lead + Tax Admin | Open |
| H05 | ❓ **Payroll Bridge Failure**: What if payroll bridge fails to deliver compensation data during pay cycle? How to ensure employees are paid on time? | Integration | `PayrollDataExported`, `PayoutFileGenerated` | Blocks downstream integration design; employee trust at risk | Tech Lead + Payroll Admin | Open |
| H06 | ❓ **4 Regional Minimum Wage Levels**: Vietnam has 4 regions (VND 3.25M - 4.68M). How to validate salary against correct region in real-time during offer/compensation change? | Compliance | `SalaryReviewed`, `OfferCreated`, `MinimumWageValidated` | Blocks compensation validation; non-compliance = labor violation | BA + Tech Lead | Open |

---

## P1 — Resolve Before Implementation

| ID | Hot Spot | Category | Related Event/Command | Impact | Owner | Status |
|----|----------|----------|----------------------|--------|-------|--------|
| H07 | ❓ **Partial Month Salary**: How to handle pro-rata salary for mid-cycle hires, terminations, unpaid leave? 30-day vs. actual days basis per country? | Calculation | `SalaryProrated`, `EmploymentTerminated`, `UnpaidLeaveApproved` | Complex proration logic; 20-30% payroll disputes if done incorrectly | BA + Payroll Admin | Open |
| H08 | ❓ **Bonus Budget Pool Reallocation**: Can managers reallocate unspent budget across teams after cycle opens? What approval hierarchy? | Authorization | `BudgetPoolReallocated`, `BonusAllocationSubmitted` | High rework risk if approval workflow changes mid-cycle | Product + BA | Open |
| H09 | ❓ **Commission Dispute Resolution**: Sales rep disputes commission calculation. Freeze disputed amount? Pay undisputed portion? SLA for resolution? | Calculation | `CommissionDisputed`, `CommissionAdjusted`, `CommissionPaid` | Sales rep trust at risk; 20% QoQ dispute increase noted in BRD | Product + Sales Ops | Open |
| H10 | ❓ **13th Month Pro-rata**: Vietnam (Tet bonus) and Philippines (PD 851) require pro-rata 13th month. How to track eligibility for employees hired mid-year? | Compliance | `ThirteenthMonthCalculated`, `EmploymentAnniversaryReached` | Statutory-adjacent; employee expectation before Tet 2026 (Jan 29, 2026) | BA + Compliance | Open |
| H11 | ❓ **Carrier Sync Failure**: Benefits carrier enrollment file rejected (format error, duplicate, invalid member). Retry? Manual fallback? Coverage gap liability? | Integration | `EnrollmentFileGenerated`, `CarrierSyncFailed`, `EnrollmentAcknowledged` | 2-4 week coverage activation delays; compliance exposure | Tech Lead + Benefits Admin | Open |
| H12 | ❓ **Tax Bracket Versioning**: Tax brackets change mid-year (effective dating). How to handle employees who worked under both old and new brackets? | Calculation | `TaxBracketUpdated`, `TaxWithholdingCalculated`, `TaxYearVersioned` | Compliance risk; employee tax under/over-withholding | BA + Tax Admin | Open |
| H13 | ❓ **Social Recognition Feed Content Moderation**: Peer-to-peer recognition posts publicly. Auto-approve? Human moderation? SLA? Inappropriate content liability? | UX / Compliance | `RecognitionPosted`, `RecognitionModerated`, `RecognitionPublished` | Brand/reputation risk; requires content policy + moderation workflow | Product + Legal | Open |
| H14 | ❓ **Compa-Ratio Visibility**: Should managers see team compa-ratio distribution in compensation worksheet? Could reveal pay equity gaps prematurely. | UX / Policy | `CompensationWorksheetViewed`, `CompaRatioDisplayed` | Pay equity transparency vs. premature disclosure; DEI sensitivity | Product + HRBP | Open |
| H15 | ❓ **AI Compensation Advisor Cold Start**: AI recommends compensation adjustments. How to handle new employees with no historical data? New managers with no team history? | AI/ML Feasibility | `AIRecommendationGenerated`, `CompensationAdjustmentProposed` | 50% AI adoption target at risk if recommendations poor for edge cases | Tech Lead + Product | Open |
| H16 | ❓ **Real-time Commission Dashboard Performance**: High-volume sales (200+ reps, 10K+ transactions/month). Can dashboard show real-time commission accruals without latency? | Performance | `CommissionTransactionRecorded`, `CommissionAccrued`, `DashboardViewed` | Sales rep trust at risk; latency = distrust in calculation accuracy | Tech Lead + Sales Ops | Open |
| H17 | ❓ **Offer Letter E-Signature Failure**: Candidate signs offer but DocuSign/esignature callback fails. Offer status? Auto-remind? Manual fallback? | Integration | `OfferSent`, `OfferSigned`, `ESignatureCallbackReceived` | Blocks onboarding; candidate experience at risk | Tech Lead + Talent | Open |
| H18 | ❓ **Dependent Eligibility Verification**: Health insurance dependents (spouse, children) require documentation. Auto-approve? HR verification? Audit trail for ineligible dependents? | Compliance | `DependentAdded`, `DependentVerified`, `EligibilityDocumentUploaded` | Carrier may reject ineligible dependents; coverage gap liability | BA + Benefits Admin | Open |

---

## P2 — Nice to Clarify

| ID | Hot Spot | Category | Related Event/Command | Impact | Owner | Status |
|----|----------|----------|----------------------|--------|-------|--------|
| H19 | ❓ **Manager Compensation Literacy**: Should system provide guideline tooltips (e.g., "Market rate for this role is X") during compensation proposals? | UX | `CompensationProposalCreated`, `GuidelineDisplayed` | Nice to have for manager experience; reduces HR inquiries | Product + UX | Open |
| H20 | ❓ **Employee Bonus Simulation**: Allow employees to simulate "what-if" bonus scenarios before cycle closes? Transparency vs. expectation management. | UX | `BonusSimulated`, `WhatIfAnalysisViewed` | Employee experience enhancement; potential for unrealistic expectations | Product | Open |
| H21 | ❓ **Recognition Point Expiration**: Should unused recognition points expire (FIFO)? If yes, what期限 (12 months, 24 months)? | Policy | `RecognitionPointExpired`, `RecognitionPointRedeemed` | Accounting liability for unredeemed points; employee experience | Product + Finance | Open |
| H22 | ❓ **Total Rewards Statement Frequency**: Auto-generate annually? On-demand? After each comp event? Real-time PDF generation vs. cached? | UX / Performance | `TotalRewardsStatementGenerated`, `CompensationEventPublished` | Employee experience; storage and performance trade-off | Product + Tech Lead | Open |
| H23 | ❓ **Multi-Language Support**: Should manager worksheets support mixed-language teams (e.g., Vietnamese manager, Singapore HRBP reviewing same proposal)? | UX | `CompensationWorksheetViewed`, `LanguagePreferenceSet` | Nice to have for regional collaboration; adds translation complexity | Product + UX | Open |
| H24 | ❓ **Notification Channel Preference**: Email, SMS, in-app, mobile push for compensation events? Per-event configuration or global preference? | UX | `NotificationSent`, `NotificationPreferenceUpdated` | Employee experience enhancement; adds notification infrastructure | Product + UX | Open |
| H25 | ❓ **Compensation Benchmarking Data**: Integrate external market data (Radford, Mercer) for pay range setting? Which provider? Manual upload or API? | Integration | `MarketBenchmarkUploaded`, `PayRangeReviewed` | Pay competitiveness; external data cost and integration effort | Product + BA | Open |
| H26 | ❓ **Off-Cycle Bonus Workflow**: Should off-cycle bonuses (spot bonuses, retention) follow same approval chain as cycle bonuses? Faster path? | Authorization | `OffCycleBonusRequested`, `OffCycleBonusApproved` | Manager experience; policy decision on approval rigor | Product + HRBP | Open |
| H27 | ❓ **Tax Optimization Recommendation Opt-In**: AI tax recommendations (e.g., "Increase SI contribution to reduce taxable income"). Auto-enable or explicit opt-in? | Policy / AI/ML | `TaxOptimizationRecommended`, `TaxProfileUpdated` | Employee value-add; regulatory consideration for financial advice | Product + Legal | Open |
| H28 | ❓ **Audit Log Retention Beyond 7 Years**: BRD specifies 7-year retention. Should certain entities (executive comp, equity) have indefinite retention? | Compliance | `AuditRecordRetained`, `AuditRecordArchived` | Storage cost; legal hold requirements for executive compensation | Compliance + Tech Lead | Open |

---

## Hot Spot Priority Summary

| Priority | Count | Description |
|----------|-------|-------------|
| **P0** | 6 | Blocks multi-country design — MUST resolve before architecture sign-off |
| **P1** | 12 | High risk of rework — Resolve before implementation begins |
| **P2** | 10 | Nice to clarify — Can be decided during implementation |
| **Total** | **28** | |

---

## Category Breakdown

| Category | P0 | P1 | P2 | Total |
|----------|----|----|----|-------|
| **Compliance** | 3 | 3 | 1 | 7 |
| **Integration** | 2 | 2 | 2 | 6 |
| **Calculation** | 1 | 3 | 0 | 4 |
| **Data Privacy** | 1 | 0 | 0 | 1 |
| **Currency/FX** | 1 | 0 | 0 | 1 |
| **Authorization** | 0 | 1 | 1 | 2 |
| **UX** | 0 | 2 | 5 | 7 |
| **AI/ML Feasibility** | 0 | 1 | 1 | 2 |
| **Performance** | 0 | 1 | 0 | 1 |
| **Policy** | 0 | 0 | 3 | 3 |
| **Total** | **6** | **12** | **10** | **28** |

---

## Next Steps

### Immediate Actions (P0 Hot Spots)

1. **H01 - Vietnam SI Calculation**: Schedule workshop with VNSI compliance expert + BA to finalize calculation rules
2. **H02 - FX Rate Source**: Finance to confirm preferred FX provider (XE, OANDA, central bank)
3. **H03 - Data Residency**: Legal counsel to provide data transfer guidance per country
4. **H04 - Tax API Fallback**: Tech Lead to design offline filing workflow
5. **H05 - Payroll Bridge Fallback**: Define CSV/file-based fallback for payroll integration
6. **H06 - Minimum Wage Validation**: BA to compile regional minimum wage table for Vietnam

### Resolution Timeline

| Milestone | Target Date | Hot Spots to Resolve |
|-----------|-------------|---------------------|
| **P0 Resolution Complete** | 2026-04-15 | H01-H06 |
| **P1 Resolution Complete** | 2026-05-15 | H07-H18 |
| **P2 Resolution Complete** | 2026-06-15 | H19-H28 |

---

## Related Documents

| Document | Location |
|----------|----------|
| Session Brief (Phase 1-2) | `01-session-brief.md` |
| Domain Events (Phase 3) | `03-domain-events.md` |
| Commands & Actors (Phase 4) | `04-commands-actors.md` |
| Timelines (Phase 6) | `06-timelines.md` |
| Discovery Questions (Phase 7) | `07-discovery-questions.md` |

---

**Document Control:**

- **Version**: 1.0.0
- **Status**: DRAFT
- **Created**: 2026-03-20
- **Next Review**: After Phase 6 (Timelines) completion
- **Owner**: Product Team + Architecture Review Board

---

*Hot Spots identified through Event Storming Phase 5. This is a living document — update as risks are resolved or new Hot Spots are discovered.*
