# Total Rewards — Permission Matrix

> **Module**: Total Rewards / xTalent HCM
> **Step**: 5 — Product Experience Design
> **Date**: 2026-03-26

## Legend

| Symbol | Meaning |
|--------|---------|
| C | Create |
| R | Read |
| U | Update |
| D | Delete / Archive |
| A | Approve |
| X | Export |
| - | No access |

## Roles

| Code | Role |
|------|------|
| WKR | Worker (Self-Service) |
| MGR | People Manager |
| CAD | Compensation Administrator |
| HAD | HR Administrator |
| FIN | Finance Approver |
| TAX | Tax Administrator |
| SOP | Sales Operations |
| HMG | Hiring Manager |
| CND | Candidate (external) |
| AUD | External Auditor |
| RAD | Recognition Administrator |

---

## BC-01: Compensation Management

### COMP-M-001 — Salary Basis Management

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Create | - | - | C | C | - | - | - | - | - | - | - |
| Read | - | - | R | R | - | - | - | - | - | - | - |
| Update | - | - | U | U | - | - | - | - | - | - | - |
| Archive | - | - | D | D | - | - | - | - | - | - | - |

### COMP-M-002 — Pay Component Definition

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Create | - | - | C | C | - | - | - | - | - | - | - |
| Read | - | R | R | R | R | - | - | R | - | - | - |
| Update | - | - | U | U | - | - | - | - | - | - | - |
| Archive | - | - | D | D | - | - | - | - | - | - | - |

### COMP-M-003 — Pay Range Management

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Create (new version) | - | - | C | C | - | - | - | - | - | - | - |
| Read | - | R | R | R | R | - | - | R | - | R | - |
| Update (SCD Type 2 — create new period) | - | - | C | C | - | - | - | - | - | - | - |
| Archive | - | - | D | D | - | - | - | - | - | - | - |
| Export | - | - | X | X | X | - | - | - | - | X | - |

### COMP-M-004 — Compensation Cycle Configuration

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Create | - | - | C | C | - | - | - | - | - | - | - |
| Read | - | R | R | R | R | - | - | - | - | - | - |
| Update | - | - | U | U | - | - | - | - | - | - | - |

### COMP-T-001 — Merit Review Cycle Management

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Open Cycle | - | - | C | C | - | - | - | - | - | - | - |
| View Cycle (own team) | - | R | R | R | R | - | - | - | - | - | - |
| Submit Proposal (own team) | - | C | - | - | - | - | - | - | - | - | - |
| Approve Proposal | - | - | - | - | A | - | - | - | - | - | - |
| Close Cycle | - | - | C | C | - | - | - | - | - | - | - |
| Publish Results | - | - | C | C | - | - | - | - | - | - | - |
| Export Report | - | - | X | X | X | - | - | - | - | X | - |
| View own salary change result | R | R | - | - | - | - | - | - | - | - | - |

### COMP-T-002 — Salary Change Activation

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Initiate Change | - | - | C | C | - | - | - | - | - | - | - |
| Read (own salary) | R | - | - | - | - | - | - | - | - | - | - |
| Read (team salary) | - | R | R | R | R | - | - | - | - | - | - |
| Read (all salaries) | - | - | R | R | R | - | - | - | - | R | - |
| Approve (within threshold) | - | - | A | A | - | - | - | - | - | - | - |
| Approve (above threshold) | - | - | - | - | A | - | - | - | - | - | - |
| Export | - | - | X | X | X | - | - | - | - | X | - |

### COMP-T-003 — Deduction Management

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Create | - | - | C | C | - | - | - | - | - | - | - |
| Read (own deductions) | R | - | - | - | - | - | - | - | - | - | - |
| Read (all) | - | - | R | R | R | - | - | - | - | R | - |
| Update Schedule | - | - | U | U | - | - | - | - | - | - | - |
| Archive | - | - | D | D | - | - | - | - | - | - | - |
| Approve Garnishment | - | - | - | - | A | - | - | - | - | - | - |
| Export | - | - | X | X | X | - | - | - | - | X | - |

### COMP-A-001 — Compensation Analytics Dashboard

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Read (team view) | - | R | - | - | - | - | - | - | - | - | - |
| Read (all) | - | - | R | R | R | - | - | - | - | - | - |
| Export | - | - | X | X | X | - | - | - | - | - | - |

---

## BC-02: Calculation Engine

### CALC-M-001 — Contribution Config (SI/CPF rates)

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Create (new period) | - | - | - | C | - | C | - | - | - | - | - |
| Read | - | - | R | R | R | R | - | - | - | R | - |
| Export | - | - | - | X | - | X | - | - | - | X | - |

### CALC-M-002 — Min Wage Config

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Create (new zone period) | - | - | - | C | - | - | - | - | - | - | - |
| Read | - | R | R | R | R | R | - | R | - | R | - |
| Export | - | - | - | X | - | - | - | - | - | X | - |

### CALC-M-003 — Calculation Rule Management

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Create (insert-only, no edit) | - | - | - | C | - | - | - | - | - | - | - |
| Read | - | - | R | R | R | R | - | - | - | R | - |
| Export | - | - | - | X | - | X | - | - | - | X | - |

### CALC-M-004 — FX Rate Management

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Read | - | - | R | R | R | - | - | - | - | R | - |
| Override (with justification) | - | - | - | - | A | - | - | - | - | - | - |
| Export | - | - | - | X | X | - | - | - | - | X | - |

### CALC-T-001 — SI Contribution Calculation Run

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Initiate Run | - | - | - | C | - | C | - | - | - | - | - |
| View Progress | - | - | - | R | - | R | - | - | - | - | - |
| View Results | - | - | R | R | R | R | - | - | - | R | - |
| View Own Results | R | - | - | - | - | - | - | - | - | - | - |
| Approve & Publish | - | - | - | A | - | - | - | - | - | - | - |
| Export | - | - | - | X | X | X | - | - | - | X | - |

### CALC-A-001 — Calculation Audit Report

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Read (own breakdown) | R | - | - | - | - | - | - | - | - | - | - |
| Read (all) | - | - | R | R | R | R | - | - | - | R | - |
| Export | - | - | X | X | X | X | - | - | - | X | - |

---

## BC-03: Variable Pay

### VPAY-M-001 — Bonus Plan Management

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Create | - | - | C | C | - | - | - | - | - | - | - |
| Read | - | R | R | R | R | - | - | - | - | R | - |
| Update | - | - | U | U | - | - | - | - | - | - | - |
| Archive | - | - | D | D | - | - | - | - | - | - | - |

### VPAY-M-002 — Commission Plan Management

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Create | - | - | - | C | - | - | C | - | - | - | - |
| Read | R | R | R | R | R | - | R | - | - | R | - |
| Update | - | - | - | U | - | - | U | - | - | - | - |
| Archive | - | - | - | D | - | - | D | - | - | - | - |

### VPAY-T-001 — Bonus Calculation Run

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Initiate Run | - | - | C | C | - | - | - | - | - | - | - |
| View Results (own) | R | - | - | - | - | - | - | - | - | - | - |
| View Results (team) | - | R | - | - | - | - | - | - | - | - | - |
| View Results (all) | - | - | R | R | R | - | - | - | - | R | - |
| Approve Pool | - | - | - | - | A | - | - | - | - | - | - |
| Publish | - | - | C | C | - | - | - | - | - | - | - |
| Export | - | - | X | X | X | - | - | - | - | X | - |

### VPAY-T-002 — Commission Real-Time Dashboard

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| View (own commission) | R | - | - | - | - | - | - | - | - | - | - |
| View (team commission) | - | R | - | - | - | - | - | - | - | - | - |
| View (all reps) | - | - | - | R | - | - | R | - | - | R | - |
| Submit Dispute | C | - | - | - | - | - | - | - | - | - | - |
| Export | - | - | - | X | - | - | X | - | - | X | - |

### VPAY-T-003 — Commission Dispute Resolution

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Raise Dispute | C | - | - | - | - | - | - | - | - | - | - |
| View (own disputes) | R | - | - | - | - | - | - | - | - | - | - |
| Review & Resolve | - | - | - | - | - | - | A | - | - | - | - |
| View All Disputes | - | - | R | R | - | - | R | - | - | R | - |

---

## BC-04: Benefits Administration

### BENE-M-001 — Benefit Plan Management

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Create | - | - | - | C | - | - | - | - | - | - | - |
| Read | R | R | R | R | R | - | - | - | - | R | - |
| Update | - | - | - | U | - | - | - | - | - | - | - |
| Archive | - | - | - | D | - | - | - | - | - | - | - |

### BENE-T-001 — Benefits Open Enrollment

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Open Enrollment Window | - | - | - | C | - | - | - | - | - | - | - |
| Enroll (self) | C | C | C | C | C | - | - | - | - | - | - |
| Add Dependent | C | C | C | C | - | - | - | - | - | - | - |
| View Own Elections | R | R | R | - | - | - | - | - | - | - | - |
| View All Elections | - | - | R | R | R | - | - | - | - | R | - |
| Export | - | - | X | X | X | - | - | - | - | X | - |

### BENE-T-002 — Life Event Enrollment

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Declare Life Event | C | - | - | - | - | - | - | - | - | - | - |
| Enroll after Event | C | - | C | C | - | - | - | - | - | - | - |
| View (own) | R | - | - | - | - | - | - | - | - | - | - |
| View (all) | - | - | R | R | - | - | - | - | - | R | - |

---

## BC-05: Recognition & Engagement

### RECG-M-001 — Recognition Program Management

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Create | - | - | - | C | - | - | - | - | - | - | C |
| Read | R | R | R | R | - | - | - | - | - | - | R |
| Update | - | - | - | U | - | - | - | - | - | - | U |
| Archive | - | - | - | D | - | - | - | - | - | - | D |

### RECG-T-001 — Send Recognition

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Send Recognition | C | C | C | C | - | - | - | - | - | - | - |
| View (own sent/received) | R | R | - | - | - | - | - | - | - | - | - |
| View (team) | - | R | - | R | - | - | - | - | - | - | - |
| View (all) | - | - | R | R | - | - | - | - | - | R | R |

### RECG-T-002 — Points Redemption

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Redeem (own points) | C | C | C | C | - | - | - | - | - | - | - |
| View Balance (own) | R | R | - | - | - | - | - | - | - | - | - |
| View All Balances | - | - | R | R | - | - | - | - | - | R | - |

---

## BC-06: Offer Management

### OFFR-M-001 — Offer Template Management

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Create | - | - | C | C | - | - | - | - | - | - | - |
| Read | - | - | R | R | - | - | - | R | - | - | - |
| Update | - | - | U | U | - | - | - | - | - | - | - |
| Archive | - | - | D | D | - | - | - | - | - | - | - |

### OFFR-T-001 — Offer Creation & Approval

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Create Offer | - | - | C | C | - | - | - | C | - | - | - |
| View (own offers created) | - | - | - | - | - | - | - | R | - | - | - |
| View All Offers | - | - | R | R | R | - | - | - | - | R | - |
| Approve (standard) | - | - | A | A | - | - | - | - | - | - | - |
| Approve (high-value) | - | - | - | - | A | - | - | - | - | - | - |
| Export | - | - | X | X | X | - | - | - | - | X | - |

### OFFR-T-002 — Offer E-Signature

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| View Offer Letter | - | - | - | - | - | - | - | - | R | - | - |
| Accept Offer | - | - | - | - | - | - | - | - | C | - | - |
| Decline Offer | - | - | - | - | - | - | - | - | C | - | - |
| Sign | - | - | - | - | - | - | - | - | C | - | - |
| View Signed Document | - | - | R | R | R | - | - | R | R | - | - |

---

## BC-07: TR Statement

### STMT-A-002 — Salary Pay Slip View

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| View (own pay slip) | R | R | - | - | - | - | - | - | - | - | - |
| View (team pay slips) | - | R | R | - | - | - | - | - | - | - | - |
| View (all) | - | - | R | R | R | - | - | - | - | R | - |
| Download PDF (own) | X | - | - | - | - | - | - | - | - | - | - |
| Export (all) | - | - | X | X | X | - | - | - | - | X | - |

### STMT-A-001 — Total Rewards Annual Statement

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| View (own statement) | R | R | - | - | - | - | - | - | - | - | - |
| Generate (all workers) | - | - | C | C | - | - | - | - | - | - | - |
| View (all) | - | - | R | R | - | - | - | - | - | R | - |
| Download PDF (own) | X | - | - | - | - | - | - | - | - | - | - |
| Export (bulk) | - | - | X | X | - | - | - | - | - | X | - |

---

## BC-08: Taxable Bridge

### BRDG-T-001 — Taxable Item Processing

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| View (own items) | R | - | - | - | - | - | - | - | - | - | - |
| View All Items | - | - | R | R | R | R | - | - | - | R | - |
| Retry Failed | - | - | - | C | - | C | - | - | - | - | - |
| Export | - | - | X | X | X | X | - | - | - | X | - |

### BRDG-A-001 — Taxable Bridge Dashboard

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| View Dashboard | - | - | R | R | R | R | - | - | - | R | - |
| Export | - | - | X | X | X | X | - | - | - | X | - |

---

## BC-09: Tax & Compliance

### TAXC-M-001 — Tax Bracket Configuration

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Create (new period) | - | - | - | C | - | C | - | - | - | - | - |
| Read | - | - | - | R | R | R | - | - | - | R | - |
| Export | - | - | - | X | - | X | - | - | - | X | - |

### TAXC-M-002 — Tax Profile Management

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| View (own profile) | R | - | - | - | - | - | - | - | - | - | - |
| Create / Update | - | - | - | C | - | C | - | - | - | - | - |
| Read All | - | - | - | R | - | R | - | - | - | R | - |

### TAXC-T-001 — Tax Withholding Calculation

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Initiate Run | - | - | - | C | - | C | - | - | - | - | - |
| View Results (own) | R | - | - | - | - | - | - | - | - | - | - |
| View Results (all) | - | - | - | R | R | R | - | - | - | R | - |
| Export | - | - | - | X | X | X | - | - | - | X | - |

---

## BC-10: Audit & Observability

### AUDT-A-001 — Audit Trail Viewer

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| View (own records) | R | - | - | - | - | - | - | - | - | - | - |
| View (scoped to assigned entities) | - | - | - | - | - | - | - | - | - | R | - |
| View (all records) | - | - | - | R | R | R | - | - | - | - | - |
| Export | - | - | - | X | X | X | - | - | - | X | - |
| Delete / Purge | - | - | - | - | - | - | - | - | - | - | - |

> Note: No role can delete or update audit records. This is a hard system rule (BR-A01: append-only storage).

### AUDT-A-002 — Compliance Report Export

| Action | WKR | MGR | CAD | HAD | FIN | TAX | SOP | HMG | CND | AUD | RAD |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Generate Report | - | - | - | C | C | C | - | - | - | C | - |
| View Report | - | - | - | R | R | R | - | - | - | R | - |
| Export | - | - | - | X | X | X | - | - | - | X | - |

---

## Special Access Rules

| Rule | Detail |
|------|--------|
| Own-data scoping | Workers always see only their own data unless the role explicitly grants team/all access |
| External Auditor scoping | AUD scope is defined at login time (assigned LegalEntity or specific audit engagement). Cannot exceed assigned scope. |
| Candidate access | CND access is token-based (no xTalent login). Token expires after 30 days or on offer resolution. |
| Multi-country scoping | All roles are scoped to LegalEntity (country). HAD in Vietnam sees VN data only unless explicitly granted cross-country access. |
| Finance Approver | FIN can approve proposals/pools but cannot create or modify compensation records directly. |
| Tax Admin | TAX can configure brackets and run withholding calculations but cannot approve compensation changes or benefits elections. |
| People Manager | MGR sees team data (direct + indirect reports as configured in org hierarchy). Cannot see peer teams. |

---

*Permission Matrix — Total Rewards / xTalent HCM — Step 5 Experience Design*
*2026-03-26*
