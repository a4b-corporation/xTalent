# Domain Discovery Questions: Total Rewards

**Domain**: Total Rewards (TR)
**Scope**: Multi-country Southeast Asia (6 countries: VN, TH, ID, SG, MY, PH)
**Related Documents**:
- `00-session-brief.md` — 150 Domain Events
- `01-commands-actors.md` — 80 Commands, 40+ Actors
- `02-hot-spots.md` — 28 Hot Spots (6 P0, 12 P1, 10 P2)
- `timeline-*.md` — 5 Event Timelines

**Created**: 2026-03-20
**Status**: DRAFT — Pending Stakeholder Interviews

---

## Summary

| Priority | Count | Target Resolution | Timeline Impact |
|----------|-------|-------------------|-----------------|
| **P0**   | 15    | Before Design     | Blocks architecture sign-off |
| **P1**   | 20    | Before Implementation | Blocks development start |
| **P2**   | 10    | During Implementation | Can be decided iteratively |
| **Total** | **45** | | |

**Ambiguity Score**: 0.35 (Target: ≤0.2 to proceed to design)

---

## P0 — Must Resolve Before Design

*These questions must be answered before architecture and design can proceed.*

| Q-ID | Question | Category | Related Hot Spot | Target Stakeholder | Impact if Unresolved | Timeline |
|------|----------|----------|------------------|-------------------|---------------------|----------|
| **Q01** | What is the exact Vietnam SI Law 2024 implementation specification for BHXH (17.5%+8%), BHYT (3%+1.5%), and BHTN (1%+1%) contributions with the 20× regional salary cap? Provide breakdown by 4 regions. | Compliance | H01 | Legal/Compliance + Vietnam HR Head | Non-compliance = VND 50-100M fines; blocks calculation engine design | Benefits |
| **Q02** | Which FX rate source must be used for salary/bonus conversion across all 6 SEA countries? Central bank rates, commercial bank rates, or Reuters/OANDA? What is the update frequency (daily, hourly, intraday)? | Technical | H02 | Finance Director + Architecture Review Board | Blocks multi-currency design; consolidated reporting accuracy at risk | Compensation, Statement |
| **Q03** | What are the specific data residency requirements per country for employee PII and compensation data? Can Vietnamese employee data cross borders for regional reporting under Singapore PDPA and Indonesia PDP Law? | Compliance | H03 | Legal/Compliance + IT Security | Blocks architecture design; potential criminal liability under PDPA | Statement |
| **Q04** | What is the failover strategy when tax authority e-Filing APIs are unavailable during filing deadlines (last day of month)? Is manual filing with offline submission allowed? What SLAs for API restoration? | Technical | H04 | Tax Administrator + Architecture Review Board | Late filing penalties up to 100% of under-withheld tax | Tax |
| **Q05** | What is the fallback mechanism when payroll bridge fails to deliver compensation data during a pay cycle? Is a CSV/file-based fallback acceptable? What is the maximum allowable delay before employee payment is missed? | Technical | H05 | Payroll Administrator + Architecture Review Board | Blocks downstream integration; employee trust at risk | All |
| **Q06** | How should the system validate salary against the correct Vietnam regional minimum wage (4 regions: VND 3.25M - 4.68M) in real-time during offer creation and compensation changes? What determines employee region assignment? | Compliance | H06 | Compliance Officer + Vietnam HR Head | Non-compliance = labor violation; blocks compensation validation | Compensation |
| **Q07** | What are the tax withholding rules and rates for each of the 6 SEA countries? Provide country-specific exemptions, thresholds, and progressive tax structures that must be implemented. | Compliance | H01 | Tax Administrator + Country HR Heads | Non-compliance = tax penalties across 6 jurisdictions | Tax |
| **Q08** | What are the technical specifications for the audit trail retention period of 7 years? What data must be retained, what storage format (immutable ledger, database partitioning), and what is the data archival policy for records older than 7 years? | Technical | H28 | IT Security + Compliance Officer | Blocks compliance design; audit failures | Audit |
| **Q09** | What are the minimum wage validation thresholds for each country beyond Vietnam? How are regional variations (if any) handled for Thailand, Indonesia, Singapore, Malaysia, and Philippines? | Compliance | H06 | Compliance Officer + Country HR Heads | Non-compliance = labor violations across 6 countries | Compensation |
| **Q10** | What is the real-time FX rate update frequency required for accurate multi-currency calculations? Daily at market close, hourly, or intraday? What is the acceptable lag for rate updates (e.g., <15 minutes)? | Technical | H02 | Finance Director + Architecture Review Board | Blocks multi-currency design; accuracy issues | Compensation, Statement |
| **Q11** | What are the data residency requirements for payroll data exports to external systems (payroll gateway, tax authorities, carriers)? Which data fields must remain in-country vs. can be aggregated regionally? | Compliance | H03 | Legal/Compliance + IT Security | Blocks architecture design; potential criminal liability | All |
| **Q12** | What is the payroll bridge API contract specification? What event schema (JSON, XML), idempotency requirements, retry policies, and error handling mechanisms must be supported? | Technical | H05 | Architecture Review Board + Payroll Administrator | Blocks integration design; payment failures | All |
| **Q13** | What are the SI (Social Insurance) contribution rules for each country beyond Vietnam? Provide specifications for Thailand's Provident Fund, Indonesia's BPJS, Singapore's CPF, Malaysia's EPF/SOCSO, and Philippines' SSS/PhilHealth/Pag-IBIG. | Compliance | H01 | Country HR Heads + Tax Administrator | Non-compliance = fines across 6 jurisdictions | Benefits |
| **Q14** | What are the data residency requirements for cross-border reporting? Can regional reports aggregate data from all countries into a single dashboard, or must country-specific reports be generated and stored separately? | Compliance | H03 | Legal/Compliance + Architecture Review Board | Blocks regional reporting design | Reporting |
| **Q15** | What is the acceptable downtime for external tax API integration? What is the maximum retry count (e.g., 3 attempts), backoff strategy (exponential, linear), and manual filing trigger point (e.g., after 24 hours)? | Technical | H04 | Tax Administrator + Architecture Review Board | Blocks compliance design; late filing penalties | Tax |

---

## P1 — Resolve Before Implementation

*These questions should be resolved before development begins to avoid rework.*

| Q-ID | Question | Category | Related Hot Spot | Target Stakeholder | Impact if Unresolved | Timeline |
|------|----------|----------|------------------|-------------------|---------------------|----------|
| **Q16** | What is the content moderation policy for the Social Recognition Feed? Auto-approve with AI moderation, human review, or hybrid? What SLA for reviewing inappropriate content (e.g., <2 hours)? | Business | H13 | Product Owner + Legal | Brand/reputation risk; requires moderation workflow design | Recognition |
| **Q17** | What are the recommendation thresholds for the AI Compensation Advisor? What confidence level (e.g., >80%), data sample size (e.g., >30 comparable employees), and margin of error are acceptable before presenting recommendations? | Business | H15 | Product Owner + Compensation Manager | 50% AI adoption target at risk; poor recommendations damage trust | Compensation |
| **Q18** | What statistical methods should be used for Pay Equity Auto-Detection? What are the acceptable statistical significance levels (p-value), confidence intervals, and demographic groupings (gender, ethnicity, age) for gap analysis? | Business | H14 | Compensation Manager + HRBP | Pay equity transparency; DEI sensitivity; potential legal exposure | Compensation |
| **Q19** | What are the data latency requirements for the Real-time Commission Dashboard? What is the acceptable delay between transaction recording and dashboard update (seconds, minutes, hours)? | Business | H16 | Sales Operations Manager + Architecture Review Board | Sales rep trust; latency = distrust in calculation accuracy | Variable Pay |
| **Q20** | What are the carrier selection criteria for the Flex Credits Marketplace? Which carriers must be supported per country (minimum 3, preferred 5+)? What is the enrollment file format (CSV, XML, EDI 834) and sync frequency (daily, weekly)? | Integration | H11 | Benefits Administrator + Finance | Benefits enrollment failures; carrier coverage gaps | Benefits |
| **Q21** | What is the carrier integration specification? What file format (CSV, XML, JSON, EDI), transfer frequency (daily batch, real-time API), error handling protocol (retry logic, alerting), and acknowledgment mechanism (ACK/NACK)? | Integration | H11 | Benefits Administrator + Architecture Review Board | 2-4 week coverage activation delays per carrier | Benefits |
| **Q22** | What are the Tax Authority API specifications per country? What authentication methods (OAuth 2.0, API keys, digital certificates), rate limits (requests/minute), retry policies, and error codes must be handled? | Integration | H04 | Tax Administrator + Architecture Review Board | Blocks tax filing implementation | Tax |
| **Q23** | What is the Payroll Gateway event schema? What events must be emitted (salary change, bonus, deduction), what payload format (JSON schema version), and what idempotency requirements (idempotency key, deduplication window)? | Integration | H05 | Payroll Administrator + Architecture Review Board | Blocks payroll integration implementation | All |
| **Q24** | What CRM integration is required for commission data? Which CRM system (Salesforce, HubSpot, Microsoft Dynamics), what data fields (opportunity amount, close date, rep assignment), sync frequency (real-time webhook, hourly batch)? | Integration | — | Sales Operations Manager + Architecture Review Board | Blocks commission calculation implementation | Variable Pay |
| **Q25** | What E-signature provider must be used for offer management? DocuSign, Adobe Sign, or other? What are the webhook specifications, status callbacks (sent, viewed, signed, declined), and fallback mechanisms? | Integration | H17 | Talent Acquisition + Architecture Review Board | Blocks offer management implementation | Offer Mgmt |
| **Q26** | What is the pro-rata salary calculation method per country for mid-cycle hires, terminations, and unpaid leave? 30-day basis, actual days, or working days? Provide country-specific rules. | Technical | H07 | Payroll Administrator + Country HR Heads | 20-30% payroll disputes if done incorrectly | Compensation |
| **Q27** | What is the SCD Type 2 versioning implementation complexity for tax bracket changes mid-year? How to handle employees who worked under both old and new brackets (split calculation, higher rate, average rate)? | Technical | H12 | Tax Administrator + Architecture Review Board | Compliance risk; employee tax under/over-withholding | Tax |
| **Q28** | What are the multi-tenant data isolation requirements for global customers? How to ensure data separation between legal entities and countries in a shared database (schema per tenant, row-level security)? | Technical | H03 | IT Security + Architecture Review Board | Blocks multi-tenant architecture design | Platform |
| **Q29** | What is the bonus budget pool reallocation policy? Can managers reallocate unspent budget across teams after cycle opens? What approval hierarchy (peer manager, department head, finance)? | Business | H08 | Product Owner + HR Director | High rework risk if approval workflow changes mid-cycle | Variable Pay |
| **Q30** | What is the commission dispute resolution SLA? Should disputed amounts be frozen until resolution or undisputed portion paid? What is the maximum resolution time (7 days, 14 days, 30 days)? | Business | H09 | Sales Operations Manager + Finance Manager | Sales rep trust; 20% QoQ dispute increase noted in BRD | Variable Pay |
| **Q31** | What is the 13th month pro-rata calculation method for Vietnam (Tet bonus) and Philippines (PD 851)? How to track eligibility for employees hired mid-year (day-count, month-count)? | Compliance | H10 | Compliance Officer + Country HR Heads | Employee expectation before Tet 2026 (Jan 29, 2026) | Variable Pay |
| **Q32** | What are the bonus simulation "what-if" scenarios employees can access? Which variables should be configurable (bonus percentage, performance multiplier, tenure, company performance)? | UX | H20 | Product Owner + UX Designer | Employee experience enhancement; expectation management | Variable Pay |
| **Q33** | What is the point expiration policy for recognition points? FIFO expiration after 12 months, 24 months, or no expiration? What notification lead time before expiration (30 days, 60 days)? | Business | H21 | Product Owner + Finance | Accounting liability for unredeemed points; employee experience | Recognition |
| **Q34** | What is the off-cycle bonus workflow? Should spot bonuses and retention bonuses follow same approval chain as cycle bonuses? What is the faster path for urgent approvals? | Business | H26 | Product Owner + HRBP | Manager experience; retention risk if too slow | Variable Pay |
| **Q35** | What is the tax optimization recommendation opt-in policy? Auto-enable with opt-out, or explicit opt-in? What regulatory considerations for financial advice disclaimers? | Business | H27 | Product Owner + Legal | Employee value-add; regulatory consideration (financial advice licensing) | Statement |

---

## P2 — Nice to Clarify

*These questions can be resolved during implementation based on user feedback and iterative design.*

| Q-ID | Question | Category | Related Hot Spot | Target Stakeholder | Impact if Unresolved | Timeline |
|------|----------|----------|------------------|-------------------|---------------------|----------|
| **Q36** | What tooltip content should managers see during compensation decisions? Market rate data (percentile), compa-ratio guidance (target range), budget remaining, or all three? | UX | H19 | Product Owner + UX Designer | Manager experience; reduces HR inquiries | Compensation |
| **Q37** | What is the Total Rewards Statement generation frequency? Auto-generate annually only, on-demand after each comp event, or real-time PDF generation for every change? | UX | H22 | Product Owner + Architecture Review Board | Employee experience; storage/performance trade-off | Statement |
| **Q38** | What is the multi-language support scope? Should manager worksheets support mixed-language teams (Vietnamese employee, Singaporean manager)? Which languages (EN, VI, TH, ID, MS, TL) and for which UI elements? | UX | H23 | Product Owner + Country HR Heads | Regional collaboration; translation complexity | Platform |
| **Q39** | What are the notification channel preferences per event type? Email, SMS, in-app, mobile push — per-event configuration or global preference center? | UX | H24 | Product Owner + UX Designer | Employee experience enhancement | All |
| **Q40** | What are the mobile-responsive requirements? Which screens must be mobile-optimized (recognition, statement view, bonus simulation)? Which features should be mobile-only (QR recognition, photo upload)? | UX | — | Product Owner + UX Designer | Mobile user experience; 40%+ mobile usage expected | Platform |
| **Q41** | Should external market data (Radford, Mercer, Willis Towers Watson) be integrated for pay range setting? Which provider? Manual upload or API integration? | Integration | H25 | Product Owner + Compensation Manager | Pay competitiveness; data cost ($50K-200K/year) | Compensation |
| **Q42** | What are the audit log retention requirements beyond 7 years for executive compensation and equity grants? Indefinite retention for legal hold, or specific extended period (10 years, 15 years)? | Compliance | H28 | Compliance Officer + Legal | Storage cost; legal hold requirements | Audit |
| **Q43** | What are the dependent eligibility verification requirements? Auto-approve with documentation upload, HR verification within 48 hours, or carrier validation before enrollment? | Compliance | H18 | Benefits Administrator + Compliance Officer | Coverage gap liability; carrier rejection risk | Benefits |
| **Q44** | What is the offer letter e-signature failure handling? Auto-remind candidate after 24 hours, manual fallback to PDF via email, or hold offer until signature verified? | Integration | H17 | Talent Acquisition + Architecture Review Board | Candidate experience; onboarding delay | Offer Mgmt |
| **Q45** | What are the compa-ratio visibility rules? Should managers see team compa-ratio distribution (box plot, histogram)? Could this reveal pay equity gaps prematurely before HR review? | UX | H14 | Product Owner + HRBP | Pay equity transparency vs. premature disclosure; DEI sensitivity | Compensation |

---

## Question Mapping to Timelines

| Timeline | P0 Questions | P1 Questions | P2 Questions |
|----------|--------------|--------------|--------------|
| **Compensation Cycle** | Q01, Q02, Q06, Q09, Q10 | Q17, Q18, Q26, Q29 | Q32, Q36, Q38, Q41, Q45 |
| **Benefits Enrollment** | Q01, Q07, Q13 | Q20, Q21, Q31, Q43 | Q39 |
| **Variable Pay Calculation** | Q02, Q10 | Q19, Q24, Q29, Q30, Q31, Q34 | Q32, Q37 |
| **Recognition Flow** | Q03, Q11 | Q16, Q33 | Q38, Q39, Q40 |
| **Statement Generation** | Q02, Q03, Q08, Q10, Q11, Q14 | Q27, Q28, Q35, Q42 | Q37, Q38, Q39 |
| **Tax Filing** | Q04, Q07, Q14, Q15 | Q22, Q27 | Q35 |
| **Payroll Processing** | Q05, Q08, Q12 | Q23, Q26, Q28 | Q39 |
| **Offer Management** | Q06 | Q25 | Q44 |
| **Audit & Compliance** | Q03, Q08, Q11, Q13, Q14 | Q27, Q28, Q42, Q43 | — |
| **Multi-Country Operations** | Q02, Q03, Q07, Q09, Q10, Q11, Q13, Q14 | Q20, Q26, Q28, Q31, Q38 | Q38, Q40 |

---

## Stakeholder Interview Schedule

### Week 1: Legal & Compliance (P0 Focus)

| Date | Time | Stakeholders | Questions | Duration |
|------|------|--------------|-----------|----------|
| Mon 2026-03-23 | 10:00-11:30 | Legal/Compliance, Vietnam HR Head | Q01, Q06, Q09, Q13, Q31 | 90 min |
| Mon 2026-03-23 | 14:00-15:30 | Legal/Compliance, IT Security | Q03, Q08, Q11, Q14, Q42 | 90 min |
| Tue 2026-03-24 | 10:00-11:30 | Tax Administrator, Country HR Heads | Q04, Q07, Q15, Q22, Q27 | 90 min |

### Week 2: Technical & Architecture (P0 Focus)

| Date | Time | Stakeholders | Questions | Duration |
|------|------|--------------|-----------|----------|
| Wed 2026-03-26 | 10:00-12:00 | Architecture Review Board, Finance Director | Q02, Q05, Q10, Q12, Q28 | 120 min |
| Thu 2026-03-27 | 10:00-11:30 | Payroll Administrator, Tech Lead | Q05, Q12, Q23, Q26 | 90 min |
| Fri 2026-03-28 | 10:00-11:00 | IT Security, Architecture Review Board | Q03, Q08, Q11, Q28 | 60 min |

### Week 3: Business & Product (P1 Focus)

| Date | Time | Stakeholders | Questions | Duration |
|------|------|--------------|-----------|----------|
| Mon 2026-03-30 | 10:00-11:30 | Product Owner, Compensation Manager | Q16, Q17, Q18, Q29, Q32, Q33, Q34, Q35 | 90 min |
| Tue 2026-03-31 | 10:00-11:30 | Product Owner, Sales Operations Manager | Q19, Q24, Q30 | 90 min |
| Wed 2026-04-01 | 10:00-11:30 | Product Owner, Benefits Administrator | Q20, Q21, Q43 | 90 min |
| Thu 2026-04-02 | 10:00-11:30 | Product Owner, Talent Acquisition | Q25, Q44 | 90 min |
| Fri 2026-04-03 | 10:00-11:00 | Product Owner, UX Designer | Q36, Q37, Q38, Q39, Q40, Q41, Q45 | 60 min |

---

## Category Distribution

| Category | P0 | P1 | P2 | Total | Primary Stakeholder |
|----------|----|----|----|-------|---------------------|
| **Compliance** | 7 | 2 | 2 | 11 | Legal/Compliance |
| **Technical** | 6 | 4 | 0 | 10 | Architecture Review Board |
| **Business** | 0 | 9 | 4 | 13 | Product Owner |
| **Integration** | 2 | 5 | 1 | 8 | Architecture Review Board |
| **UX** | 0 | 0 | 5 | 5 | Product Owner + UX Designer |
| **Total** | **15** | **20** | **12** | **47** | |

---

## Hot Spot to Question Mapping

| Hot Spot ID | Hot Spot | Related Question IDs | Resolution Status |
|-------------|----------|---------------------|-------------------|
| **H01** | Vietnam SI Law 2024 | Q01, Q07, Q13 | 🔴 Pending |
| **H02** | Multi-country FX | Q02, Q10 | 🔴 Pending |
| **H03** | Data Residency | Q03, Q11, Q14, Q28 | 🔴 Pending |
| **H04** | Tax API Failure | Q04, Q15, Q22 | 🔴 Pending |
| **H05** | Payroll Bridge Failure | Q05, Q12, Q23 | 🔴 Pending |
| **H06** | Minimum Wage Validation | Q06, Q09 | 🔴 Pending |
| **H07** | Partial Month Proration | Q26 | 🟡 Pending |
| **H08** | Bonus Budget Reallocation | Q29 | 🟡 Pending |
| **H09** | Commission Dispute | Q30 | 🟡 Pending |
| **H10** | 13th Month Pro-rata | Q31 | 🟡 Pending |
| **H11** | Carrier Sync Failure | Q20, Q21 | 🟡 Pending |
| **H12** | Tax Bracket Versioning | Q27 | 🟡 Pending |
| **H13** | Content Moderation | Q16 | 🟡 Pending |
| **H14** | Compa-Ratio Visibility | Q18, Q45 | 🟡 Pending |
| **H15** | AI Cold Start | Q17 | 🟡 Pending |
| **H16** | Dashboard Performance | Q19 | 🟡 Pending |
| **H17** | E-Signature Failure | Q25, Q44 | 🟢 Pending (P2) |
| **H18** | Dependent Verification | Q43 | 🟢 Pending (P2) |
| **H19** | Manager Tooltips | Q36 | 🟢 Pending (P2) |
| **H20** | Bonus Simulation | Q32 | 🟢 Pending (P2) |
| **H21** | Point Expiration | Q33 | 🟢 Pending (P2) |
| **H22** | Statement Frequency | Q37 | 🟢 Pending (P2) |
| **H23** | Multi-Language | Q38 | 🟢 Pending (P2) |
| **H24** | Notification Channels | Q39 | 🟢 Pending (P2) |
| **H25** | Market Data Integration | Q41 | 🟢 Pending (P2) |
| **H26** | Off-Cycle Bonus | Q34 | 🟢 Pending (P2) |
| **H27** | Tax Opt-in Policy | Q35 | 🟢 Pending (P2) |
| **H28** | Audit Retention | Q08, Q42 | 🔴 Pending |

---

## Recommended Next Steps

### Immediate (Week of 2026-03-23)

- [ ] **Schedule stakeholder interviews for P0 questions** (Target: 2026-03-23 to 2026-03-28)
  - [ ] Legal/Compliance workshop (Q01, Q03, Q06, Q07, Q08, Q09, Q11, Q13, Q14)
  - [ ] Architecture review board session (Q02, Q04, Q05, Q10, Q12, Q15, Q28)
  - [ ] Finance and tax administration alignment (Q02, Q04, Q07, Q10, Q15)
  - [ ] Country HR heads council (Q06, Q09, Q13, Q26, Q31)
  - [ ] IT security and data residency review (Q03, Q08, Q11)

- [ ] **Create ooo interview session for ambiguity resolution**
  - [ ] Focus on high-ambiguity questions: Q01 (Vietnam SI Law), Q02 (FX source), Q03 (data residency)
  - [ ] Document assumptions and decisions in `assumptions.md`

### Short-term (Week of 2026-03-30)

- [ ] **Document answers in assumptions.md**
  - [ ] Update hot spots status from "Open" to "Resolved" as questions are answered
  - [ ] Link answers to specific design decisions in architecture documents

- [ ] **Prioritize P1 questions for stakeholder alignment**
  - [ ] Business questions (Q16-Q20, Q29, Q30, Q32-Q35) require product owner input
  - [ ] Integration questions (Q21-Q25) require technical specification workshops
  - [ ] Technical questions (Q26-Q28) require architecture decisions

### Medium-term (April 2026)

- [ ] **Plan P2 questions for iterative clarification**
  - [ ] These can be resolved during implementation based on user feedback
  - [ ] Schedule UX design workshops for Q36-Q40
  - [ ] A/B test notification preferences (Q39) with pilot users

---

## Decision Log Template

*Use this template to document answers as stakeholder interviews complete:*

```markdown
### Decision: Q01 — Vietnam SI Law 2024 Implementation

**Date**: 2026-03-23
**Stakeholders**: Legal/Compliance, Vietnam HR Head
**Decision**:
- BHXH: 17.5% employer + 8% employee, cap 20× regional minimum wage
- BHYT: 3% employer + 1.5% employee, no cap
- BHTN: 1% employer + 1% employee, cap 20× regional minimum wage
- 4 regions: Region 1 (VND 4.68M), Region 2 (VND 4.16M), Region 3 (VND 3.64M), Region 4 (VND 3.25M)
- Region assignment: Based on primary work location in employment contract

**Impact**:
- Calculation engine must support 4 separate wage floors
- Monthly cap recalculation when minimum wage changes (typically January)
- Audit trail must capture applicable region and cap at time of calculation

**Related Hot Spots**: H01, H06
**Related Design**: `../design/calculation-engine.md`
```

---

## Success Metrics

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| P0 Questions Resolved | 15/15 | 0/15 | 🔴 Not Started |
| P1 Questions Resolved | 20/20 | 0/20 | 🔴 Not Started |
| Ambiguity Score | ≤0.2 | 0.35 | 🔴 Needs Improvement |
| Stakeholder Interview Attendance | >90% | — | 🟡 Scheduled |
| Decision Documentation Rate | 100% | — | 🟡 Pending |

---

**Document Version**: 1.0.0
**Status**: DRAFT — Pending Stakeholder Interviews
**Created**: 2026-03-20
**Next Review**: After P0 stakeholder interviews complete (Target: 2026-04-03)
**Owner**: Product Team + Architecture Review Board

---

*This Domain Discovery Questions document is part of the Total Rewards Module Event Storming Phase 7.*

**Related Documents:**
- `00-session-brief.md` — Session Brief with 150 Domain Events
- `01-commands-actors.md` — Commands and Actors mapping
- `02-hot-spots.md` — 28 Hot Spots register
- `timeline-*.md` — 5 Event Timeline diagrams

**Next Steps:**
1. Schedule and conduct P0 stakeholder interviews (2026-03-23 to 2026-03-28)
2. Document decisions in `assumptions.md`
3. Recalculate ambiguity score (target: ≤0.2)
4. Proceed to design phase once P0 questions resolved
