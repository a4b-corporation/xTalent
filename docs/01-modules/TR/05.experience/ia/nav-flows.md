# Total Rewards — Navigation Flows

> **Module**: Total Rewards / xTalent HCM
> **Step**: 5 — Product Experience Design
> **Date**: 2026-03-26

Top 5 P0 user journeys with step-by-step navigation flows, actor handoffs, and system touchpoints.

---

## Flow 1: Merit Review Cycle — End-to-End

**Features**: COMP-M-004, COMP-T-001
**Actors**: Compensation Admin (opener), People Manager (proposer), Finance Approver (approver), Compensation Admin (publisher)
**User Story**: US-002, US-003, US-004
**Target Duration**: ≤ 2 weeks (OBJ-01)

```
PHASE 1 — SETUP (Compensation Admin)
─────────────────────────────────────
[1] Login → Total Rewards > Compensation Cycles
[2] Click "Create New Cycle"
[3] Step 1 — Eligibility: select org units, grade levels, employment type
[4] Step 2 — Budget: enter % of payroll; system shows estimated amount
[5] Step 3 — Approval Routing: set threshold (e.g., >10% requires VP approval)
[6] Step 4 — Timeline: set submission deadline, close date
[7] Save as DRAFT → preview → click "Open Cycle"
[8] System sends push notification + email to all eligible People Managers

PHASE 2 — PROPOSAL (People Manager)
─────────────────────────────────────
[9]  People Manager receives: "Merit cycle open — 14 days to submit"
[10] Login → Total Rewards > My Team > Merit Proposals
[11] View team table: Worker | Current Salary | Pay Band | CompaRatio | Status
[12] Click worker row → Merit Proposal Form opens (right panel / drawer)
[13] Form shows:
      - Worker card: name, grade, current salary, pay range bar visualization
      - Proposed salary input
      - System live-calculates: new compa-ratio, % change, budget impact
      - Change type selector (MERIT / PROMOTION / EQUITY_ADJUSTMENT)
      - Justification text field
      - Approval path preview (auto-determined by % change threshold)
[14] If proposed salary < min wage → red warning block (cannot submit)
[15] If proposed % > threshold → routing shows VP approval required
[16] Click "Submit Proposal" → proposal status: PENDING
[17] Repeat [12]–[16] for each team member
[18] All proposals submitted → People Manager sees confirmation "All submitted"

PHASE 3 — APPROVAL (Finance Approver / Director)
─────────────────────────────────────────────────
[19] Finance Approver receives: in-app notification "N proposals pending approval"
[20] Login → Total Rewards > Finance > Pending Approvals
[21] View proposals list with budget impact summary
[22] Click proposal → detail view with justification
[23] Actions: Approve | Reject (with comment) | Send back for revision
[24] If approved → proposal status: APPROVED
[25] Budget gauge on Comp Admin dashboard updates in real-time

PHASE 4 — PUBLISH (Compensation Admin)
───────────────────────────────────────
[26] Compensation Admin sees cycle status: "X/Y proposals approved"
[27] Click "Close Cycle" → confirmation modal with summary stats
[28] System creates SalaryRecord (SCD Type 2) for each approved proposal
[29] System publishes events: tr.salary-changed.v1 → Payroll, BC-08 Taxable Bridge
[30] Workers receive in-app notification: "Your salary has been updated effective [date]"
[31] Compensation Admin clicks "Export Cycle Report" → CSV download

ERROR PATHS
───────────
- [14] Min wage violation → block submission; show zone-specific min wage
- [13] Worker missing salary record → show "No active salary record" warning
- [21] Budget exceeded → show warning (not block) with overage amount
- [28] SalaryRecord creation fails → rollback; notify Admin; retry button
```

---

## Flow 2: SI Contribution Calculation Run

**Features**: CALC-T-001, CALC-M-001, CALC-M-002
**Actors**: HR Admin (initiator), System (calculator)
**User Story**: US-001
**Country**: [VN-specific]

```
PRE-CONDITIONS
──────────────
- ContributionConfig has valid rates for current period [CALC-M-001]
- MinWageConfig has zone rates for all zones [CALC-M-002]
- Workers have active WorkingRelationship with zone assigned

FLOW
────
[1]  HR Admin → Login → Total Rewards > Calculation Runs
[2]  Click "New SI Contribution Run"
[3]  Select: Period (month/year) + Legal Entity + Country = Vietnam
[4]  System pre-validates:
      - "12 workers have no zone assigned" → list shown → Admin can fix or proceed
      - "2 workers have salary > SI cap (will be capped automatically)"
[5]  Click "Start Run"
[6]  Progress screen shows live counter (SSE):
      - Workers processed: 87/100
      - Errors: 2
[7]  Run completes → Results table:
      | Worker | Salary Basis | SI Base | BHXH Emp | BHXH Empl | BHYT Emp | BHTN Empl | Status |
[8]  Admin reviews results; clicks worker row for full calculation breakdown:
      - Input: salary_basis, zone, min_wage, cap
      - Applied rule: CALC-RULE-VN-SI-001 (effective 2026-01-01)
      - Output: each contribution amount
      - Audit record ID
[9]  Click "Approve & Publish" → contributions sent to:
      - BC-08 Taxable Bridge (for Payroll)
      - BC-10 Audit Trail
[10] Download full report (CSV / PDF)

ERROR PATHS
───────────
- Worker has no active zone → skip worker; flag in error list
- Salary record missing → skip; flag; Admin must resolve before re-run
- Min wage config missing for zone → block run; show configuration link
- Calculation engine plugin unavailable → run fails; retry button; alert sent
```

---

## Flow 3: Benefits Open Enrollment

**Features**: BENE-T-001, BENE-M-001
**Actors**: HR Admin (opens window), Worker (enrolls)
**User Story**: US-007

```
PHASE 1 — ADMIN OPENS ENROLLMENT WINDOW
────────────────────────────────────────
[1] HR Admin → Benefits > Enrollment Management
[2] Click "Open Enrollment Window"
[3] Select: period (e.g., 2026-04-01 to 2026-04-30), eligible plans, eligible org units
[4] System sends email notification to all eligible Workers:
    "Benefits enrollment is open. Deadline: April 30, 2026."

PHASE 2 — WORKER ENROLLS (Mobile-first)
────────────────────────────────────────
[5]  Worker receives email → clicks link → opens xTalent app / mobile web
[6]  Total Rewards > My Benefits > Enroll / Change Benefits
[7]  Step 1 — Plan Comparison:
      - Cards showing each plan: monthly cost (employee share), coverage highlights, carrier name
      - Current election highlighted (if re-enrollment)
      - "Compare" toggle for side-by-side view
[8]  Worker selects plan → Step 2 — Coverage Tier:
      - Options: Employee Only | Employee + Spouse | Employee + Children | Family
      - System shows: your cost per month + employer contribution
[9]  Step 3 — Dependents:
      - List of existing dependents
      - Add new dependent: name, relationship, DOB, national ID
      - System validates: dependent type allowed per plan + country config
[10] Step 4 — Review & Confirm:
      - Summary: selected plan, tier, dependents, effective date, monthly cost
      - Checkbox: "I confirm these elections"
      - Click "Submit Elections"
[11] System creates BenefitEnrollment record
[12] System triggers async Kafka event → EDI 834 carrier sync queue
[13] Worker receives confirmation email with election summary

PHASE 3 — CARRIER SYNC (Async)
───────────────────────────────
[14] System generates EDI 834 file
[15] Sends to carrier
[16] Carrier acknowledges → enrollment status: SYNCED
[17] HR Admin can monitor: Benefits > Carrier Sync Status [BENE-T-003]

ERROR PATHS
───────────
- Dependent type not allowed for this plan → show warning; block that dependent
- Enrollment window closed → show deadline; allow re-open request
- Carrier sync fails → retry up to 3x; HR Admin alerted; manual CSV export fallback
- Worker misses deadline → HR Admin can manually process per policy
```

---

## Flow 4: Offer Creation & Approval

**Features**: OFFR-T-001, OFFR-T-002, COMP-M-003, CALC-M-002
**Actors**: Hiring Manager (creates), Compensation Admin (optional review), Finance Approver (approves high-value), Candidate (accepts)
**User Story**: US-014, US-015, US-005

```
PHASE 1 — OFFER CREATION (Hiring Manager)
──────────────────────────────────────────
[1]  Hiring Manager → Login → Total Rewards > Offers > Create New Offer
[2]  Step 1 — Template:
      - Select template by job family / country
      - Template pre-fills: job title, grade, legal entity, country
[3]  Step 2 — Compensation:
      - Salary amount input (in local currency)
      - System validates on blur:
        a. MIN WAGE CHECK: proposed salary vs. min wage for zone (synchronous API)
           → If fail: red block "Proposed salary VND X below minimum wage VND Y for zone Z"
        b. PAY RANGE CHECK: show bar visualization of where salary falls in grade range
           → If outside range: amber warning (not block) + justification required
      - Additional components: select from pay component library
      - Bonus target % (if applicable)
      - Start date input
[4]  Step 3 — Approval Review:
      - System shows approval routing based on salary amount + grade
      - Attach justification (required if outside pay range or >20% above midpoint)
      - Preview offer letter text
[5]  Step 4 — Submit:
      - Click "Submit for Approval"
      - Offer status: PENDING_APPROVAL
[6]  Approver (Finance Approver or Comp Admin) receives in-app notification

PHASE 2 — APPROVAL
───────────────────
[7]  Approver → Total Rewards > Finance > Pending Approvals
[8]  Reviews offer: candidate name, grade, proposed salary, pay range position
[9]  Approve → status: APPROVED
     OR Reject with comment → Hiring Manager notified

PHASE 3 — CANDIDATE DELIVERY & SIGNING
───────────────────────────────────────
[10] System generates offer letter PDF from template + data
[11] System sends email to candidate with secure link (token-based, no login required)
[12] Candidate opens link → reads offer letter (mobile-friendly rendering)
[13] Candidate actions:
      a. Accept → proceeds to e-signature widget (DocuSign/SignNow)
      b. Decline → confirmation modal; Hiring Manager notified
      c. Request clarification → comment sent to Hiring Manager
[14] Candidate signs → document sealed
[15] System notifies Hiring Manager: "Offer accepted and signed"
[16] Signed PDF stored; offer status: ACCEPTED
[17] Hiring Manager links to ATS / CO module for onboarding

ERROR PATHS
───────────
- Min wage check fails → block submission until corrected
- Approval routing misconfigured → fallback to HR Admin approval
- Offer link expired (>30 days) → Hiring Manager can resend
- E-signature provider unavailable → fallback provider; alert; manual signing option
- Candidate declines → offer status: DECLINED; Hiring Manager notified
```

---

## Flow 5: Commission Dashboard — Real-Time

**Features**: VPAY-T-002, VPAY-M-002
**Actors**: Worker (views own), Sales Ops (views all / manages)
**User Story**: US-009, US-017
**Real-time SLA**: < 5 seconds

```
DATA PIPELINE (Background — always running)
────────────────────────────────────────────
[BG-1] CRM system → Kafka topic: tr.crm-transaction-imported.v1
[BG-2] BC-03 Variable Pay consumes event → processes SalesTransaction
[BG-3] Commission recalculated → Kafka: tr.commission-recalculated.v1
[BG-4] WebSocket bridge service receives event → pushes to connected clients
Total pipeline latency target: < 5s (BR-V01)

WORKER VIEW (Mobile-first)
──────────────────────────
[1]  Worker → Login → Total Rewards > My Variable Pay > My Commission Dashboard
[2]  Dashboard loads with current-period data (last known state + WebSocket connection established)
[3]  Dashboard panels:
      a. QUOTA ATTAINMENT GAUGE: circular gauge 0–150%+
         - Current: 67% of quota
         - Remaining to reach next tier: VND X
      b. RUNNING COMMISSION: current month earned amount
         - Breakdown: base commission + tier accelerator
      c. TIER PROGRESS BAR: current tier highlighted; next tier threshold shown
      d. RECENT TRANSACTIONS: last 10 CRM-synced deals with amount + commission
      e. AI INSIGHT CARD: "At your current pace, you'll reach Silver Tier by March 20"
[4]  Real-time update: when CRM pushes a new deal:
      - WebSocket message received
      - Gauge animates to new value
      - Transaction appears at top of list
      - Toast notification: "New sale recorded: VND 50M"
[5]  Worker taps transaction → detail: deal name, amount, commission rate, calculated commission
[6]  Worker taps "Dispute" on a transaction → VPAY-T-003 flow

SALES OPS VIEW (Desktop)
─────────────────────────
[7]  Sales Ops → Login → Total Rewards > Variable Pay (Sales) > Commission Dashboard
[8]  Team view: filterable table of all reps with quota %, earned, period
[9]  Click rep → individual dashboard (same panels as Worker view)
[10] Search + filter: by plan, period, team, attainment range
[11] Export: CSV of all rep attainments for period

FALLBACK BEHAVIOR
─────────────────
- If WebSocket connection lost → client falls back to 30s polling
- If Kafka lag > 30s → alert shown: "Commission data may be delayed"
- If CRM sync stalled > 1 hour → Sales Ops alerted via push notification

ERROR PATHS
───────────
- Worker has no active commission plan → show "No active commission plan for this period"
- Period not yet started → show "Commission tracking starts [date]"
- CRM import fails duplicate detection → transaction flagged, not double-counted
```

---

## Cross-Flow Navigation Shortcuts

| From | To | Trigger |
|------|----|---------|
| Merit Proposal Form | Pay Range Management | "View pay range" link in form |
| Merit Proposal Form | Compensation Analytics | "View team analytics" link |
| SI Calculation Run | Audit Trail Viewer | "View audit records" button on results |
| Benefits Enrollment | Dependent Management | "Add dependent" triggers inline form |
| Offer Creation | Min Wage Config | "Min wage info" tooltip links to config |
| Commission Dashboard | Dispute Flow | "Dispute" button on transaction row |
| Commission Dashboard | Commission Plan | "My Plan" link in header |
| Any approval action | Notification Center | Deep-link from push notification |

---

*Navigation Flows — Total Rewards / xTalent HCM — Step 5 Experience Design*
*2026-03-26*
