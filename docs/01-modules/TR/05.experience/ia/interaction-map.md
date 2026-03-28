# Total Rewards — Interaction Map

> **Module**: Total Rewards / xTalent HCM
> **Step**: 5 — Product Experience Design
> **Date**: 2026-03-26

Maps each feature to its interaction points, primary user actions, AI-assist opportunities, and real-time data requirements.

---

## BC-01: Compensation Management

### COMP-M-001 — Salary Basis Management

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Admin Console — Configuration screen |
| **Screen Type** | Form + Table list |
| **Primary Interactions** | Create salary basis definition; add/remove pay component references; set frequency (HOURLY/MONTHLY/ANNUAL); activate/deactivate |
| **AI-Assist** | Suggest pay components based on job family conventions |
| **Real-time** | Static — changes take effect on save |
| **Device** | Desktop-first |

### COMP-M-002 — Pay Component Definition Management

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Admin Console — Pay Structure section |
| **Screen Type** | Form + searchable table |
| **Primary Interactions** | Create component (name, type, taxability, proration-eligible flag); version history view; activate/deactivate |
| **AI-Assist** | Flag if component may create double-taxation (e.g., allowance already in taxable bridge) |
| **Real-time** | Static |
| **Device** | Desktop-first |

### COMP-M-003 — Pay Range Management

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Admin Console — Pay Ranges screen |
| **Screen Type** | Grid with grade rows + band visualization bar |
| **Primary Interactions** | Create new effective period (SCD Type 2 — no in-place edit); view current vs. historical ranges; export to CSV |
| **AI-Assist** | Market comparison overlay (P2 — requires external benchmark data) |
| **Real-time** | Static |
| **Device** | Desktop-first |

### COMP-M-004 — Compensation Cycle Configuration

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Admin Console — Cycle Setup wizard |
| **Screen Type** | Multi-step wizard (4 steps: Eligibility → Budget → Approval Routing → Timeline) |
| **Primary Interactions** | Set eligibility rules; set budget %; configure approval thresholds; set open/close dates |
| **AI-Assist** | Suggest budget % based on prior cycle actuals |
| **Real-time** | Static |
| **Device** | Desktop-first |

### COMP-T-001 — Merit Review Cycle Management

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Compensation Admin Dashboard + Manager Proposal Form |
| **Screen Type** | Dashboard (cycle overview) + Data table (worker proposals) + Approval workflow panel |
| **Primary Interactions** | Open cycle; view budget utilization gauge; filter workers by org/status; approve/reject proposals; close cycle; publish results |
| **AI-Assist** | Flag outlier proposals (>2 SD from team average); auto-group by compa-ratio band |
| **Real-time** | Budget utilization gauge: polling/SSE < 30s; submission counts real-time |
| **Device** | Desktop-first (Admin); Tablet/Desktop (Manager) |
| **Notification** | Push notification to managers when cycle opens; to Comp Admin when all proposals submitted |

### COMP-T-002 — Salary Change Activation

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Worker salary record detail page — "Add Salary Change" action |
| **Screen Type** | Side panel / Drawer with change form |
| **Primary Interactions** | Select change type (PROMOTION/MARKET_ADJUSTMENT/CORRECTION); enter new amount; enter effective date; attach justification; submit for approval |
| **AI-Assist** | Show compa-ratio impact preview; warn if falls outside pay range |
| **Real-time** | Static (triggers async event on approval) |
| **Device** | Desktop-first |
| **Notification** | Email + in-app to approver; in-app to worker when effective |

### COMP-T-003 — Deduction Management

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Admin Console — Deductions section; Worker self-service view (read-only) |
| **Screen Type** | Table + detail panel |
| **Primary Interactions** | Create deduction (type, amount/schedule, start date, end date); view installment schedule; mark as paid-off; Finance Approver approval for garnishments |
| **AI-Assist** | Detect if new deduction would reduce net pay below statutory minimum |
| **Real-time** | Static |
| **Device** | Desktop-first |

### COMP-A-001 — Compensation Analytics Dashboard

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | HR Admin / Comp Admin — Analytics section |
| **Screen Type** | Dashboard with chart panels + filter sidebar |
| **Primary Interactions** | Filter by country/org unit/grade/cycle; view compa-ratio histogram; budget utilization; drill into individuals; export |
| **AI-Assist** | Highlight pay equity risk by department (P2 feature) |
| **Real-time** | Batch — refreshed nightly or on-demand |
| **Device** | Desktop-first |

---

## BC-02: Calculation Engine

### CALC-M-001 — Contribution Config Management

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | HR Admin Console — Statutory Config section |
| **Screen Type** | Country-tabbed config form with rate table + effective date picker |
| **Primary Interactions** | View current rates; add new effective period (SCD Type 2); select engine plugin (VietnamSIEngine / SingaporeCPFEngine); activate |
| **AI-Assist** | Alert when government-published rate changes detected (future: web scraping) |
| **Real-time** | Static |
| **Device** | Desktop-first |
| **Country Flag** | [VN-specific: BHXH/BHYT/BHTN tabs] |

### CALC-M-002 — Min Wage Config Management

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | HR Admin Console — Min Wage section |
| **Screen Type** | Zone/region table with effective dates |
| **Primary Interactions** | View zone table; add new row (zone + amount + effective date); validate against existing records |
| **AI-Assist** | Warn when workers' salaries will fall below new min wage before saving |
| **Real-time** | Static |
| **Device** | Desktop-first |
| **Country Flag** | [VN-specific: Vùng 1–4] |

### CALC-M-003 — Calculation Rule Management

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | HR Admin Console — Calculation Rules |
| **Screen Type** | Versioned rule list (insert-only, no edit/delete) |
| **Primary Interactions** | Create new rule version; set formula (JSON); set effective date; view rule history; test formula with sample inputs |
| **AI-Assist** | Formula syntax validation + test runner |
| **Real-time** | Static |
| **Device** | Desktop-first |

### CALC-T-001 — SI Contribution Calculation Run

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | HR Admin Console — Calculation Runs section |
| **Screen Type** | Run initiation form + progress tracker + results table |
| **Primary Interactions** | Select period; initiate run; monitor progress (worker count, errors); view per-worker results; download report |
| **AI-Assist** | Pre-run validation: flag workers with missing zone/min wage config |
| **Real-time** | Progress via SSE while run is executing |
| **Device** | Desktop-first |
| **Country Flag** | [VN-specific] |

### CALC-A-001 — Calculation Audit Report

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | HR Admin — Audit reports subsection |
| **Screen Type** | Filterable table with per-worker drilldown |
| **Primary Interactions** | Filter by period/worker/rule; view calculation breakdown; export CSV |
| **AI-Assist** | Flag anomalies (e.g., 20%+ change vs. prior period) |
| **Real-time** | Batch |
| **Device** | Desktop-first |

---

## BC-03: Variable Pay

### VPAY-M-001 — Bonus Plan Management

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Admin Console — Bonus Plans section |
| **Screen Type** | Plan list + detail form |
| **Primary Interactions** | Create/edit plan; set eligibility rules; configure formula; assign to org units; activate/deactivate |
| **AI-Assist** | Suggest eligibility rules based on similar existing plans |
| **Real-time** | Static |
| **Device** | Desktop-first |

### VPAY-M-002 — Commission Plan Management

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Sales Ops Console — Commission Plans section |
| **Screen Type** | Plan builder wizard (tiers, quotas, accelerators) |
| **Primary Interactions** | Create plan with tier thresholds; set quota period; assign to sales roles; activate; view active vs. historical versions |
| **AI-Assist** | Show projected payout at different attainment levels (simulation) |
| **Real-time** | Static |
| **Device** | Desktop-first |

### VPAY-T-001 — Bonus Calculation Run

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Admin Console — Variable Pay Runs |
| **Screen Type** | Run wizard (select plan + period + eligible workers) + results table |
| **Primary Interactions** | Initiate run; review results per worker; Finance Approver approves pool; publish payouts |
| **AI-Assist** | Flag workers whose bonus deviates >50% from prior year |
| **Real-time** | SSE progress during run |
| **Device** | Desktop-first |

### VPAY-T-002 — Commission Real-Time Dashboard

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Worker self-service + Sales Ops Console |
| **Screen Type** | Real-time dashboard: quota gauge, tier ladder, transaction table |
| **Primary Interactions** | View live quota attainment; drill into transactions; submit dispute; filter by period |
| **AI-Assist** | "At your current pace, you'll reach [tier X] by [date]" forecast |
| **Real-time** | **WebSocket push — < 5s latency** (Kafka → WebSocket bridge); falls back to 30s polling |
| **Device** | Mobile-first (Worker) + Desktop (Sales Ops) |

### VPAY-T-003 — Commission Dispute Resolution

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Worker self-service (raise) + Sales Ops Console (review) |
| **Screen Type** | Dispute form + workflow panel |
| **Primary Interactions** | Worker flags transaction; provides reason; Sales Ops reviews CRM data; adjusts or rejects; worker notified |
| **AI-Assist** | Auto-compare disputed transaction against CRM data for quick resolution |
| **Real-time** | Static (status notification on state change) |
| **Device** | Mobile (Worker) + Desktop (Sales Ops) |

---

## BC-04: Benefits Administration

### BENE-M-001 — Benefit Plan Management

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Admin Console — Benefit Plans section |
| **Screen Type** | Plan catalog + detail form |
| **Primary Interactions** | Create/edit plan; set coverage tiers; set cost (employer/employee split); configure eligibility; link to carrier; activate/deactivate |
| **AI-Assist** | Cost modeling tool (show impact on total comp budget) |
| **Real-time** | Static |
| **Device** | Desktop-first |

### BENE-T-001 — Benefits Open Enrollment

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Worker self-service — Benefits section |
| **Screen Type** | Enrollment wizard: Plan Comparison → Tier Selection → Dependents → Confirmation |
| **Primary Interactions** | Compare plan cards (cost, coverage); select plan + coverage tier; add/edit dependents; confirm elections; view summary |
| **AI-Assist** | "Based on your family profile, [plan X] offers the best value" recommendation |
| **Real-time** | Static (confirmation triggers async carrier sync) |
| **Device** | Mobile-first |
| **Notification** | Email 14 days before window opens; in-app reminder 3 days before close; confirmation email after submission |

### BENE-T-002 — Life Event Enrollment

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Worker self-service — Benefits section > Life Events |
| **Screen Type** | Life event declaration form + enrollment wizard |
| **Primary Interactions** | Select life event type; upload supporting document; re-trigger enrollment window; elect changes |
| **AI-Assist** | Suggest plan changes appropriate for event type (e.g., marriage → add spouse) |
| **Real-time** | Static |
| **Device** | Mobile-first |

---

## BC-05: Recognition & Engagement

### RECG-T-001 — Send Recognition

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Worker/Manager — Recognition Hub |
| **Screen Type** | Recognition composer (similar to social post) |
| **Primary Interactions** | Search recipient; select award category; write message; select point amount; submit |
| **AI-Assist** | Suggest message templates based on award category |
| **Real-time** | Recipient notified in-app within seconds |
| **Device** | Mobile-first |

### RECG-T-002 — Points Redemption

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Worker self-service — Recognition > Redeem |
| **Screen Type** | Reward catalog browse + cart checkout |
| **Primary Interactions** | Browse catalog; filter by category/point cost; add to cart; confirm redemption; view order status |
| **AI-Assist** | Personalized recommendations based on past redemptions |
| **Real-time** | Balance updated in real-time after redemption |
| **Device** | Mobile-first |

---

## BC-06: Offer Management

### OFFR-T-001 — Offer Creation & Approval

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Hiring Manager workspace — Offers section |
| **Screen Type** | 4-step wizard: Template → Compensation → Review → Submit |
| **Primary Interactions** | Select offer template; enter proposed salary; system validates min wage in real-time; attach approval justification; submit; track approval status |
| **AI-Assist** | Suggest salary based on grade, location, market data |
| **Real-time** | Min wage validation: synchronous API call on blur; approval status: polling/SSE |
| **Device** | Desktop-first |

### OFFR-T-002 — Offer E-Signature

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Candidate portal (external link) |
| **Screen Type** | Offer letter viewer + accept/decline + e-signature widget |
| **Primary Interactions** | Read offer letter; request clarification (comment); accept and sign; download signed copy |
| **AI-Assist** | None (candidate-facing, minimize friction) |
| **Real-time** | Hiring Manager notified immediately on signature |
| **Device** | Mobile-first (candidates use phones) |

---

## BC-07: TR Statement

### STMT-A-002 — Salary Pay Slip View

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Worker self-service — My Compensation |
| **Screen Type** | Pay slip card + history timeline |
| **Primary Interactions** | View current month gross breakdown by component; view SI deductions (employer + employee); view history timeline; download PDF |
| **AI-Assist** | "Your salary increased X% since you joined" insight card |
| **Real-time** | Static (refreshed after payroll run publishes) |
| **Device** | Mobile-first |

### STMT-A-001 — Total Rewards Annual Statement

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Worker self-service — My Compensation > Annual Statement |
| **Screen Type** | Visual summary + PDF download |
| **Primary Interactions** | View total compensation by category (cash / benefits / recognition / LTI); compare to prior year; download branded PDF |
| **AI-Assist** | "You received X% more total rewards than last year" narrative |
| **Real-time** | Batch — generated annually or on-demand |
| **Device** | Mobile-first + Desktop |

---

## BC-08: Taxable Bridge

### BRDG-A-001 — Taxable Bridge Dashboard

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | HR Admin Console — Taxable Bridge section |
| **Screen Type** | Operational dashboard |
| **Primary Interactions** | Monitor pending/sent/failed taxable items; retry failed items; view payroll sync status; download reconciliation report |
| **AI-Assist** | Alert when batch failure rate > threshold |
| **Real-time** | SSE for status counters; polling < 60s |
| **Device** | Desktop-first |

---

## BC-09: Tax & Compliance

### TAXC-M-001 — Tax Bracket Configuration

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | Tax Admin Console — Tax Brackets |
| **Screen Type** | Bracket table with SCD Type 2 view |
| **Primary Interactions** | View current brackets; add new effective period; preview impact on withholding amounts |
| **AI-Assist** | Import from government-published bracket table (CSV upload) |
| **Real-time** | Static |
| **Device** | Desktop-first |
| **Country Flag** | [VN-specific: PIT brackets] |

### TAXC-T-001 — Tax Withholding Calculation

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | HR Admin / Tax Admin Console — Tax Runs |
| **Screen Type** | Monthly run trigger + results table |
| **Primary Interactions** | Run monthly withholding; review per-worker amounts; flag exceptions; export for payroll integration |
| **AI-Assist** | Highlight workers where withholding changed >20% vs prior month |
| **Real-time** | SSE progress; static results |
| **Device** | Desktop-first |

---

## BC-10: Audit

### AUDT-A-001 — Audit Trail Viewer

| Attribute | Detail |
|-----------|--------|
| **Interaction Point** | HR Admin Console + External Auditor portal (scoped) |
| **Screen Type** | Filterable immutable log table |
| **Primary Interactions** | Filter by actor/entity/date range/action; view full change diff; export to CSV/PDF |
| **AI-Assist** | Anomaly detection: flag unusual patterns (e.g., mass salary changes at midnight) |
| **Real-time** | Near real-time — new records appear within 60s |
| **Device** | Desktop-first |

---

## AI-Assist Summary

| Feature | AI Opportunity | Phase |
|---------|---------------|-------|
| COMP-T-001 | Flag outlier merit proposals | P1 |
| COMP-M-003 | Market benchmark overlay | P2 |
| COMP-T-002 | Compa-ratio impact preview | P0 |
| CALC-M-002 | Warn about workers falling below new min wage | P0 |
| VPAY-T-002 | Attainment pace forecast | P1 |
| BENE-T-001 | Plan recommendation based on family profile | P1 |
| OFFR-T-001 | Salary suggestion based on grade + market | P1 |
| AUDT-A-001 | Anomaly detection on audit patterns | P2 |
| COMP-A-002 | Pay equity gap detection (AI) | P2 |

---

## Real-Time Data Requirements Summary

| Feature | Pattern | Latency | Technology |
|---------|---------|---------|-----------|
| VPAY-T-002 Commission Dashboard | WebSocket push | < 5s | Kafka → WebSocket bridge |
| COMP-T-001 Budget Gauge | SSE or polling | < 30s | SSE |
| CALC-T-001 Calculation Run Progress | SSE | Live | SSE |
| VPAY-T-001 Bonus Run Progress | SSE | Live | SSE |
| BRDG-A-001 Bridge Status | Polling | < 60s | Polling |
| OFFR-T-001 Min Wage Validation | Synchronous REST | < 500ms | REST GET |
| AUDT-A-001 New Audit Records | Near real-time | < 60s | Polling |
| FX Delta Alert (CALC-M-004) | Push notification | Immediate | WebSocket/Push |

---

*Interaction Map — Total Rewards / xTalent HCM — Step 5 Experience Design*
*2026-03-26*
