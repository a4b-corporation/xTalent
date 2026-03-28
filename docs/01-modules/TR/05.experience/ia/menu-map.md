# Total Rewards — Menu Map

> **Module**: Total Rewards / xTalent HCM
> **Step**: 5 — Product Experience Design
> **Date**: 2026-03-26

Menu hierarchy is organized by user task (not by domain entity). Items in brackets indicate the Feature ID from the feature catalog. Role visibility rules apply per permission matrix.

---

## Role: Worker (Self-Service)

```
Total Rewards (Self-Service)
├── My Compensation
│   ├── My Pay Slip                    [STMT-A-002]
│   ├── My Salary History              [COMP-T-002]
│   └── My Total Rewards Statement     [STMT-A-001]
├── My Benefits
│   ├── Enroll / Change Benefits       [BENE-T-001, BENE-T-002]
│   ├── My Benefit Elections           [BENE-T-001]
│   └── My Dependents                  [BENE-M-002]
├── My Variable Pay
│   ├── My Commission Dashboard        [VPAY-T-002]
│   └── My Bonus History               [VPAY-T-001]
└── My Recognition
    ├── Send Recognition               [RECG-T-001]
    ├── My Points & Balance            [RECG-T-002]
    └── Redeem Rewards                 [RECG-T-002]
```

---

## Role: People Manager

```
Total Rewards (Manager Workspace)
├── My Team
│   ├── Team Compensation Overview     [COMP-T-001]
│   ├── Merit Proposals                [COMP-T-001]
│   └── Team Pay Slip View             [STMT-A-002]
├── Variable Pay
│   ├── Bonus Recommendations          [VPAY-T-001]
│   └── Team Commission Overview       [VPAY-T-002]
├── Recognition
│   ├── Send Recognition               [RECG-T-001]
│   └── Team Recognition Activity      [RECG-A-001]
└── My Pay (self-service same as Worker)
    └── [Same as Worker menu]
```

---

## Role: Compensation Administrator

```
Total Rewards > Compensation Admin
├── Compensation Cycles
│   ├── Cycle Dashboard                [COMP-T-001]
│   ├── Create New Cycle               [COMP-M-004]
│   ├── Manage Proposals               [COMP-T-001]
│   └── Close & Publish Cycle          [COMP-T-001]
├── Salary Records
│   ├── Worker Salary Search           [COMP-T-002]
│   ├── Individual Salary Change       [COMP-T-002]
│   └── Salary History                 [COMP-T-002]
├── Pay Structure
│   ├── Pay Component Definitions      [COMP-M-002]
│   ├── Salary Basis Management        [COMP-M-001]
│   └── Pay Ranges                     [COMP-M-003]
├── Deductions
│   ├── Deduction Records              [COMP-T-003]
│   └── Deduction Schedules            [COMP-T-003]
└── Analytics
    └── Compensation Analytics         [COMP-A-001]
```

---

## Role: HR Administrator

```
Total Rewards > Administration
├── Configuration
│   ├── Contribution Config (SI/CPF)   [CALC-M-001]
│   ├── Min Wage Tables                [CALC-M-002]
│   ├── Calculation Rules              [CALC-M-003]
│   ├── Proration Config               [CALC-M-005]
│   └── Tax Brackets                   [TAXC-M-001]
├── Compensation
│   ├── [All Compensation Admin items]
│   └── Pay Equity Analysis            [COMP-A-002]
├── Benefits
│   ├── Benefit Plan Management        [BENE-M-001]
│   ├── Dependent Type Config          [BENE-M-002]
│   ├── Enrollment Management          [BENE-T-001]
│   └── Carrier Sync Status            [BENE-T-003]
├── Calculation Runs
│   ├── SI Contribution Run            [CALC-T-001]
│   ├── Tax Withholding Run            [TAXC-T-001]
│   └── Calculation Audit Report       [CALC-A-001]
├── Taxable Bridge
│   ├── Bridge Dashboard               [BRDG-A-001]
│   └── Taxable Items                  [BRDG-T-001]
├── Audit
│   ├── Audit Trail Viewer             [AUDT-A-001]
│   └── Compliance Reports             [AUDT-A-002]
└── TR Statements
    └── Statement Management           [STMT-A-001]
```

---

## Role: Finance Approver

```
Total Rewards > Finance
├── Budget & Approvals
│   ├── Cycle Budget Overview          [COMP-T-001]
│   ├── Pending Approvals              [COMP-T-001, VPAY-T-001]
│   └── Bonus Pool Approval            [VPAY-T-001]
├── FX Rates
│   ├── FX Rate Dashboard              [CALC-M-004]
│   └── FX Rate Override               [CALC-M-004]
└── Deductions
    └── Garnishment Approval           [COMP-T-003]
```

---

## Role: Tax Administrator

```
Total Rewards > Tax Management
├── Configuration
│   ├── Tax Bracket Editor             [TAXC-M-001]
│   └── Worker Tax Profiles            [TAXC-M-002]
├── Calculations
│   ├── Withholding Run                [TAXC-T-001]
│   └── Year-End Settlement            [TAXC-T-002]
└── Compliance
    ├── Tax Compliance Dashboard       [TAXC-A-001]
    └── E-Filing Status                [TAXC-T-002]
```

---

## Role: Sales Operations

```
Total Rewards > Variable Pay (Sales)
├── Commission Plans
│   ├── Commission Plan Management     [VPAY-M-002]
│   └── Plan Assignments               [VPAY-M-002]
├── CRM Sync
│   ├── Transaction Import Status      [VPAY-T-002]
│   └── Dispute Management             [VPAY-T-003]
└── Commission Analytics
    └── Variable Pay Analytics         [VPAY-A-001]
```

---

## Role: Hiring Manager

```
Total Rewards > Offers
├── My Offers
│   ├── Create New Offer               [OFFR-T-001]
│   ├── Pending Offers                 [OFFR-T-001]
│   └── Offer History                  [OFFR-T-001]
└── Templates
    └── Offer Templates (read-only)    [OFFR-M-001]
```

---

## Role: Candidate (External)

```
[Candidate Portal — external facing, no navigation chrome]
└── My Offer
    ├── Offer Letter Review            [OFFR-T-001]
    ├── Accept / Decline               [OFFR-T-002]
    └── E-Signature                    [OFFR-T-002]
```

---

## Role: External Auditor

```
Total Rewards > Audit (Read-Only, Scoped)
└── Audit Trail
    ├── Audit Log Viewer               [AUDT-A-001]
    └── Export Audit Report            [AUDT-A-002]
```

---

## Role: Recognition Administrator

```
Total Rewards > Recognition Admin
├── Programs
│   ├── Recognition Programs           [RECG-M-001]
│   └── Point Budget Management        [RECG-M-001]
├── Catalog
│   └── Reward Catalog                 [RECG-M-002]
└── Analytics
    └── Recognition Analytics          [RECG-A-001]
```

---

## Navigation Notes

1. Worker self-service is mobile-first; menu collapses to bottom tab bar on mobile (My Pay / My Benefits / My Recognition / My Commission).
2. HR Admin and Compensation Admin menus are desktop-first with sidebar navigation.
3. Finance Approver receives push notification for pending approvals; notification deep-links directly to approval screen.
4. External Auditor sees scoped menu only — no config, no transactions, no personal data of other workers.
5. Candidate portal is fully external (no xTalent login required for the offer review step — link-based access with token).
6. Country-specific menu items (e.g., SI Contribution Run [VN], E-Filing [VN]) are shown only when the user's context (Legal Entity) matches the applicable country.

---

*Menu Map — Total Rewards / xTalent HCM — Step 5 Experience Design*
*2026-03-26*

---

## Full Menu Structure: Total Rewards Module

This section consolidates all menu items into a single reference structure, organized by functional category rather than role. This view is useful for implementation planning and permission matrix mapping.

### CONFIGS (Masterdata — HR Admin / BA)

Configuration features set up during tenant onboarding or policy changes. These define system behavior and are maintained infrequently.

```
Configs
│
├── Compensation Configuration
│   ├── Salary Basis Management [COMP-M-001]        ← P0: HOURLY/MONTHLY/ANNUAL structures
│   ├── Pay Component Definitions [COMP-M-002]      ← P0: BASE, ALLOWANCE, BONUS, DEDUCTION
│   ├── Pay Range / Salary Bands [COMP-M-003]       ← P0: Grade-based min/mid/max
│   └── Compensation Cycle Config [COMP-M-004]      ← P0: Merit review parameters
│
├── Calculation Configuration
│   ├── Contribution Config (SI/CPF) [CALC-M-001]   ← P0: Country-specific rates
│   ├── Minimum Wage Tables [CALC-M-002]            ← P0: Zone-based floors (VN: 4 zones)
│   ├── Calculation Rules [CALC-M-003]              ← P0: Immutable formulas
│   ├── Proration Config [CALC-M-005]               ← P0: CalendarDays/WorkingDays/Fixed30
│   └── FX Rate Management [CALC-M-004] (P1)        ← Multi-country exchange rates
│
├── Benefits Configuration
│   ├── Benefit Plan Management [BENE-M-001]        ← P0: Health, dental, vision plans
│   └── Dependent Type Config [BENE-M-002]          ← P0: Spouse/Child/Parent eligibility
│
├── Variable Pay Configuration
│   ├── Bonus Plan Management [VPAY-M-001]          ← P0: Formula, payout schedule
│   ├── Commission Plan Management [VPAY-M-002]     ← P0: Quota, tiers, accelerators
│   └── LTI Grant Management [VPAY-M-003] (P1)      ← RSU, Options, vesting schedules
│
├── Tax Configuration
│   ├── Tax Bracket Configuration [TAXC-M-001]      ← P0: PIT brackets per country
│   └── Offer Templates [OFFR-M-001] (P1)           ← Job family/country templates
│
├── Recognition Configuration
│   ├── Recognition Programs [RECG-M-001] (P1)      ← Point budget, categories
│   └── Reward Catalog [RECG-M-002] (P1)            ← Redeemable rewards
│
└── Shared Configuration
    └── Approval Workflow Routing [COMP-M-004]      ← Merit approval thresholds
```

### SETTINGS (System Admin)

System-wide settings managed by IT/System Admin. These are tenant-level configurations that rarely change after initial setup.

```
Settings
│
├── Tenant Configuration
│   ├── Data Region / Legal Entities               ← Read-only post-setup
│   └── Country/Market Activation                  ← Enable/disable markets
│
├── Integration Settings
│   ├── Carrier EDI 834 Sync [BENE-T-003] (P1)     ← Benefits carrier connection
│   ├── CRM Transaction Import [VPAY-T-002] (P1)   ← Sales data pipeline
│   └── E-Filing Provider [TAXC-T-002] (P1)        ← Tax filing API config
│
├── E-Signature Provider
│   └── DocuSign/SignNow Config [OFFR-T-002] (P1)  ← Offer signature provider
│
└── Audit & Security
    ├── External Auditor Access [AUDT-A-001]       ← Scoped read-only role
    └── Audit Log Retention Policy                 ← Data retention settings
```

### REPORTS & ANALYTICS

Read-only dashboards and export features for compliance and insights.

```
Reports & Analytics
│
├── Compensation Reports
│   ├── Compensation Analytics [COMP-A-001] (P1)   ← Budget, compa-ratio, headcount
│   ├── Pay Equity Analysis [COMP-A-002] (P2)      ← AI pay gap detection
│   └── Merit Cycle Metrics (P1)                   ← Cycle progress, approval status
│
├── Variable Pay Reports
│   ├── Variable Pay Analytics [VPAY-A-001] (P1)   ← Bonus pool, commission trends
│   └── Commission Performance Dashboard (P1)      ← Quota attainment by rep
│
├── Benefits Reports
│   └── Benefits Analytics [BENE-A-001] (P1)       ← Enrollment rates, cost per plan
│
├── Tax & Compliance Reports
│   ├── Calculation Audit Report [CALC-A-001]      ← Per-worker calculation breakdown
│   ├── Tax Compliance Dashboard [TAXC-A-001] (P1) ← Withholding summary, e-filing
│   └── Taxable Bridge Dashboard [BRDG-A-001]      ← Taxable item flow status
│
├── Recognition Reports
│   └── Recognition Analytics [RECG-A-001] (P2)    ← Engagement rates, activity
│
├── Audit Reports
│   ├── Audit Trail Viewer [AUDT-A-001]            ← Immutable change log
│   └── Compliance Report Export [AUDT-A-002] (P1) ← Regulatory format export
│
└── Employee Statements
    ├── Salary Pay Slip [STMT-A-002]               ← Gross breakdown, SI, net
    └── Total Rewards Annual Statement [STMT-A-001] (P1) ← Full comp snapshot
```

### TRANSACTIONS — Compensation (tr.compensation)

Salary, merit cycle, and deduction workflows.

```
Compensation
│
├── My Compensation (Employee)
│   ├── My Pay Slip [STMT-A-002]                   ← Current + history
│   ├── My Salary History [COMP-T-002]             ← Timeline of changes
│   └── My Total Rewards Statement [STMT-A-001]    ← Annual snapshot
│
├── Merit Review Cycle (Manager)
│   ├── Cycle Dashboard [COMP-T-001]               ← Team progress tracker
│   ├── Merit Proposals [COMP-T-001]               ← Propose increases
│   └── Budget Utilization [COMP-T-001]            ← Track vs. allocated
│
├── Salary Management (HR Admin)
│   ├── Worker Salary Search [COMP-T-002]          ← Find + view records
│   ├── Individual Salary Change [COMP-T-002]      ← Promotion/adjustment
│   └── Deduction Management [COMP-T-003]          ← Loans, garnishments
│
└── Offer Management (Hiring Manager)
    ├── Create New Offer [OFFR-T-001]              ← Draft offer letter
    ├── Pending Offers [OFFR-T-001]                ← Awaiting approval
    └── Offer History [OFFR-T-001]                 ← Past offers
```

### TRANSACTIONS — Benefits (tr.benefits)

Enrollment and life event workflows.

```
Benefits
│
├── My Benefits (Employee)
│   ├── Enroll / Change Benefits [BENE-T-001]      ← Open enrollment
│   ├── My Benefit Elections [BENE-T-001]          ← Current coverage
│   └── My Dependents [BENE-M-002]                 ← Add/remove dependents
│
├── Life Events (Employee)
│   └── Life Event Enrollment [BENE-T-002] (P1)    ← Marriage/birth/divorce
│
├── Enrollment Management (HR Admin)
│   ├── Enrollment Dashboard [BENE-T-001]          ← Track participation
│   └── Carrier Sync Status [BENE-T-003] (P1)      ← EDI 834 health monitor
│
└── Dependent Management (HR Admin)
    └── Dependent Records Search                   ← Verify eligibility
```

### TRANSACTIONS — Variable Pay (tr.variablepay)

Bonus and commission workflows.

```
Variable Pay
│
├── My Variable Pay (Employee)
│   ├── My Commission Dashboard [VPAY-T-002]       ← Real-time attainment
│   ├── My Bonus History [VPAY-T-001]              ← Past payouts
│   └── My Points & Balance [RECG-T-002] (P1)      ← Recognition points
│
├── Commission Management (Sales Ops)
│   ├── Commission Plan Assignments [VPAY-M-002]   ← Assign plans to reps
│   ├── Transaction Import Status [VPAY-T-002]     ← CRM sync monitor
│   └── Dispute Management [VPAY-T-003] (P1)       ← Review + adjust
│
├── Bonus Management (HR Admin / Manager)
│   ├── Bonus Recommendations [VPAY-T-001]         ← Manager proposals
│   ├── Team Commission Overview [VPAY-T-002]      ← Manager view
│   └── Bonus Pool Approval [VPAY-T-001]           ← Finance approval
│
├── Recognition (All Users)
│   ├── Send Recognition [RECG-T-001] (P1)         ← Award points
│   └── Team Recognition Activity [RECG-A-001]     ← Manager dashboard
│
└── LTI Management (HR Admin) (P1)
    └── LTI Grant Activation [VPAY-T-004]          ← Issue + track vesting
```

### TRANSACTIONS — Calculation (tr.calculation)

SI, tax, and proration calculation workflows.

```
Calculation
│
├── Calculation Runs (HR Admin)
│   ├── SI Contribution Run [CALC-T-001]           ← Monthly BHXH/BHYT/BHTN
│   ├── Proration Calculation [CALC-T-002]         ← Mid-period adjustments
│   └── Tax Withholding Run [TAXC-T-001]           ← Monthly PIT
│
├── Tax Management (Tax Admin)
│   ├── Tax Bracket Editor [TAXC-M-001]            ← Update brackets
│   ├── Worker Tax Profiles [TAXC-M-002]           ← Residency, exemptions
│   └── Year-End Settlement [TAXC-T-002] (P1)      ← Annual reconciliation
│
├── FX Management (Finance) (P1)
│   ├── FX Rate Dashboard [CALC-M-004]             ← View rates
│   └── FX Rate Override [CALC-M-004]              ← Manual adjustment
│
└── Taxable Bridge (System)
    └── Bridge Dashboard [BRDG-A-001]              ← Pending/sent/failed items
```

### TRANSACTIONS — Shared (tr.shared)

Cross-cutting workflows for period management, approvals, and audit.

```
Shared
│
├── Period & Cycle Management
│   ├── Compensation Cycles [COMP-T-001]           ← Open → Propose → Publish
│   └── Close & Publish Cycle [COMP-T-001]         ← Finalize merit results
│
├── Approval Management
│   ├── Pending Approvals [COMP-T-001, VPAY-T-001] ← Unified queue
│   ├── Cycle Budget Overview [COMP-T-001]         ← Finance view
│   └── Garnishment Approval [COMP-T-003]          ← Legal review
│
├── Pay Equity & Compliance
│   └── Pay Equity Analysis [COMP-A-002] (P2)      ← AI gap detection
│
└── Termination Handling
    └── Final Settlement Processing                ← Offboarding calc
```

---

### Menu-to-Feature Traceability

| Menu Category | Feature Count | Priority Split |
|---------------|---------------|----------------|
| Configs | 19 | P0: 14, P1: 5 |
| Settings | 7 | P1: 6, P0: 1 |
| Reports & Analytics | 12 | P0: 3, P1: 7, P2: 2 |
| Transactions — Compensation | 9 | P0: 6, P1: 3 |
| Transactions — Benefits | 6 | P0: 4, P1: 2 |
| Transactions — Variable Pay | 11 | P0: 5, P1: 6 |
| Transactions — Calculation | 7 | P0: 4, P1: 3 |
| Transactions — Shared | 5 | P0: 3, P1: 1, P2: 1 |
| **Total** | **77** | **P0: 37, P1: 33, P2: 7** |
