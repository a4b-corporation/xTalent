# Business Requirements Document — Payroll Module (PR)

**Artifact**: brd.md
**Module**: Payroll (PR)
**Solution**: xTalent HCM
**Date**: 2026-03-27
**Version**: 1.0
**Status**: Step 2 — Reality Layer

---

## 1. Executive Summary

### 1.1 Business Context

Vietnamese enterprises deploying the xTalent HCM platform require a payroll computation and disbursement capability that is correct, compliant with Vietnamese labor law, auditable, and configurable. The current state: most customers use Excel-based payroll or legacy desktop applications (MISA AMIS, Fast Payroll) that lack a proper audit trail, cannot handle retroactive adjustments automatically, and break when regulatory rules change (most recently NĐ 73/2024/NĐ-CP for SI ceiling and NQ 954/2020/UBTVQH14 for PIT personal deduction).

The Payroll (PR) module is the final computation and disbursement layer in the xTalent value chain, consuming upstream data from Core HR (CO), Time & Attendance (TA), and Total Rewards (TR), and producing downstream outputs for banking, accounting, and statutory filing.

### 1.2 Strategic Objectives (SMART)

| ID | Objective | Metric | Target | Timeframe |
|----|-----------|--------|--------|-----------|
| SO-01 | Achieve payroll calculation accuracy across all worker types | Zero computation errors vs. manual parallel audit | 100% correct results for 3 pilot customers over 2 payroll cycles | Within 60 days of go-live |
| SO-02 | Achieve statutory compliance for all filings | Statutory acceptance rate (BHXH D02-LT, PIT 05/KK-TNCN) | 100% submissions accepted by BHXH and tax authority in first 3 months | Within 90 days of go-live |
| SO-03 | Deliver sub-30-second payroll run performance | Batch run duration for 1,000 workers | < 30 seconds on target infrastructure | Pre-launch load test validation |
| SO-04 | Enable worker self-service payslip access | Worker portal adoption rate | ≥ 60% of workers accessing payslip via portal within 30 days of go-live | Within 30 days of go-live |
| SO-05 | Reduce payroll correction rate | Correction run ratio per legal entity | < 5% of payroll runs require a correction run in the same period | Within 90 days of go-live |

### 1.3 Scope Statement

**In Scope (V1)**:
- Monthly payroll for Vietnamese domestic workers (tax-resident and non-tax-resident)
- Full gross-to-net pipeline: base salary, allowances, OT, PIT, BHXH/BHYT/BHTN, deductions, net
- All pay methods: MONTHLY_SALARY, HOURLY, PIECE_RATE, GRADE_STEP, TASK_BASED (configurable)
- Multi-level approval workflow (Payroll Admin → HR Manager → Finance Manager)
- Bank payment file generation for VCB, BIDV, TCB (manual upload)
- Statutory reports: BHXH D02-LT, PIT quarterly declaration, PIT annual settlement
- GL journal entries (VAS-compliant)
- Worker self-service: payslip view/download, PIT withholding certificate
- Retroactive adjustment (up to 12 closed periods)
- Off-cycle runs: TERMINATION, ADVANCE, CORRECTION, BONUS_RUN
- Multi-legal-entity with complete data isolation

**Out of Scope (V1)**: See Section 1.7.

---

## 2. Stakeholders

| Stakeholder | Role | Responsibilities | Decision Authority |
|-------------|------|-----------------|-------------------|
| Payroll Admin | Primary operator | Configure pay master, run payroll, resolve exceptions, submit for approval | Run initiation, exception resolution |
| HR Manager | Level 2 approver | Review payroll results, approve or reject at HR level | Level 2 approval/rejection |
| Finance Manager | Level 3 approver + payment release | Final financial review, approve payment file release | Final approval, bank file release |
| Worker | Self-service consumer | View payslips, download PIT certificates, view YTD summary | None (read-only) |
| Platform Admin | System configuration | Manage legal entities, roles, feature flags, system config | System-level configuration |
| TR Team | Upstream data provider | Provide compensation snapshots: base salary, allowances, approved bonuses, taxable bridge items | TR/PR data contract ownership |
| CO Team | Upstream data provider | Provide working relationships, contract types, dependents, bank accounts, nationality, cost center | CO/PR integration contract ownership |
| TA Team | Upstream data provider | Provide attendance lock: actual work days, OT hours by type, shift data | AttendanceLocked event contract ownership |
| Finance/Accounting | Downstream consumer | Receive GL journal entries, bank files, cost reports | GL account code mapping decisions |
| Tax Authority (GDT) | External compliance body | Receive PIT quarterly XML, PIT annual settlement | Regulatory format requirements |
| BHXH Agency | External compliance body | Receive BHXH D02-LT monthly contribution list | Regulatory format requirements |

---

## 3. Business Context and Problem

### 3.1 Current-State Pain

| Pain | Consequence |
|------|-------------|
| Excel-based payroll (MISA AMIS, Fast Payroll) — no audit trail | Cannot reconstruct historical calculation; tax audit exposure |
| Statutory rates hardcoded in spreadsheet formulas | Every decree change requires manual formula edits; error-prone |
| No automated retroactive adjustment | Backdated salary changes require manual re-run and off-cycle payment; multiple errors |
| No formal approval workflow | Finance team cannot block unauthorized disbursement |
| No integration with attendance data | OT premiums manually calculated; incorrect for complex shift schedules |
| No worker self-service | HR inundated with payslip requests; PIT certificate requires HR to generate manually |

### 3.2 Regulatory Environment (Vietnam)

| Regulation | Scope | Impact on PR |
|-----------|-------|-------------|
| PIT Law 04/2007/QH12 as amended by NQ 954/2020/UBTVQH14 | Personal Income Tax | 7-bracket progressive schedule; personal deduction 11M; dependent deduction 4.4M; non-resident 20% flat |
| Social Insurance Law 58/2014/QH13 + Decree 73/2024/NĐ-CP | BHXH/BHYT/BHTN | Rates, ceilings, contract-type eligibility matrix |
| Labor Code 45/2019/QH14 Article 97 | Overtime premiums | 150%/200%/300% + 30% night shift multipliers |
| Decree 38/2022/NĐ-CP (and updates) | Regional minimum wage | 4 wage regions; absolute floor for all pay methods |
| Circular 08/2013/TT-BTC | PIT reporting format | XML format for 05/KK-TNCN and 05/QTT-TNCN |
| Accounting Law 88/2015/QH13 | Record retention | 7-year minimum; payroll records classified as accounting documents |
| BHXH circulars | SI reporting format | D02-LT format for VssID submission |
| Decree 13/2023/NĐ-CP | Personal data protection | Worker salary data = sensitive personal data |

### 3.3 Integration Landscape

```
CO (Core HR)         TA (Time & Attendance)     TR (Total Rewards)
   |                         |                          |
   | working_relationship    | AttendanceLocked         | compensation_snapshot
   | contract_type           | actual_work_days         | base_salary
   | dependent_count         | OT hours by type         | allowances by code
   | bank_account            | shift_type data          | approved_bonuses
   | nationality             | unpaid_leave_days        | taxable_bridge_items
   | cost_center             |                          |
   |_________________________|__________________________|
                             |
                    PR (Payroll Engine)
                             |
         _____________________|_____________________
        |              |           |               |
    Bank Files     GL Journal   Tax XML        BHXH D02-LT
   (VCB/BIDV/TCB)  (TK 334/338/  (05/KK-TNCN   (VssID format)
   [manual upload]  3383/3335/    05/QTT-TNCN)
                    642)
```

**TR/PR Boundary (AQ-01 Decision D)**: TR owns HR-policy rules (compensation bands, bonus eligibility, `calculation_rule_def`). PR owns all statutory calculation rules (`statutory_rule`: PIT brackets, SI rates/ceilings, OT multipliers). TR delivers compensation data to PR as a data snapshot — not as executable rules. The boundary is enforced by a signed Architecture Decision Record (ADR).

---

## 4. Business Rules

> META CONDITION: Every rate, threshold, multiplier, and eligibility criterion below is stored as a `statutory_rule` or configurable parameter — never hardcoded in application source code.

---

### Group BR-001 to BR-019: Gross Calculation Rules

**BR-001: Base Salary Pro-ration (Calendar Days)**
```
Rule: When a worker joins or leaves mid-period and proration_method = CALENDAR_DAYS:
      Pro_rated_amount = element_amount × (days_in_period_worked / calendar_days_in_period)
Configurable via: pay_profile.proration_method = CALENDAR_DAYS
```

**BR-002: Base Salary Pro-ration (Work Days)**
```
Rule: When proration_method = WORK_DAYS:
      Pro_rated_amount = element_amount × (actual_work_days / standard_work_days_in_period)
      standard_work_days is derived from the pay_calendar and holiday_calendar (sourced from TA module)
Configurable via: pay_profile.proration_method = WORK_DAYS
```

**BR-003: Element-Level Pro-ration Override**
```
Rule: Each pay_element carries its own proration_method (CALENDAR_DAYS / WORK_DAYS / NONE).
      The element-level setting overrides the pay_profile default.
      Elements with proration_method = NONE are always paid in full regardless of join/leave date.
Configurable via: pay_element.proration_method per element definition
```

**BR-004: OT Premium — Weekday Rate**
```
Rule: OT_Weekday_Pay = OT_hours_weekday × hourly_rate × OT_MULTIPLIER_WEEKDAY
      OT_MULTIPLIER_WEEKDAY default = 1.50 (150%)
Regulation: Labor Code 45/2019/QH14, Article 97, Clause 1a
Configurable via: statutory_rule VN_OT_WEEKDAY_MULT (rule_category = OVERTIME)
```

**BR-005: OT Premium — Weekend Rate**
```
Rule: OT_Weekend_Pay = OT_hours_weekend × hourly_rate × OT_MULTIPLIER_WEEKEND
      OT_MULTIPLIER_WEEKEND default = 2.00 (200%)
Regulation: Labor Code 45/2019/QH14, Article 97, Clause 1b
Configurable via: statutory_rule VN_OT_WEEKEND_MULT
```

**BR-006: OT Premium — Public Holiday Rate**
```
Rule: OT_Holiday_Pay = OT_hours_holiday × hourly_rate × OT_MULTIPLIER_HOLIDAY
      OT_MULTIPLIER_HOLIDAY default = 3.00 (300%)
Regulation: Labor Code 45/2019/QH14, Article 97, Clause 1c
Configurable via: statutory_rule VN_OT_HOLIDAY_MULT
```

**BR-007: OT Premium — Night Shift Supplement**
```
Rule: When work hours fall within 22:00–06:00 (configurable window), an additional night supplement applies:
      Night_Supplement = base_hourly_rate × NIGHT_SHIFT_SUPPLEMENT (default = 0.30, i.e. +30%)
      Night supplement stacks with day-type multiplier: total OT rate for night holiday = 300% + 30% = 330%
Regulation: Labor Code 45/2019/QH14, Article 97, Clause 2
Configurable via: statutory_rule VN_NIGHT_SHIFT_SUPPLEMENT; night_window_start and night_window_end are configurable parameters on PayGroup
```

**BR-008: Cumulative Monthly OT Cap**
```
Rule: Maximum OT hours per worker per calendar month = OT_MONTHLY_CAP (default = 24 hours)
      When accumulated OT hours in the period reach the cap, further hours are not eligible for OT premium.
      Admin is alerted when a worker's submitted OT data exceeds the cap.
Regulation: Labor Code 45/2019/QH14, Article 107
Configurable via: pay_group parameter OT_MONTHLY_CAP; can be set per PayGroup
```

**BR-009: Hourly Rate Derivation for MONTHLY_SALARY Workers**
```
Rule: Hourly_Rate = Base_Monthly_Salary / (standard_work_days_per_month × standard_hours_per_day)
      Default divisors: 26 work days × 8 hours = 208 hours/month
      These divisors are configurable per PayGroup.
Configurable via: pay_group parameters STANDARD_WORK_DAYS_MONTH (default=26), STANDARD_HOURS_DAY (default=8)
```

**BR-010: Lunch Allowance Tax-Exempt Threshold**
```
Rule: Lunch allowance paid in cash is TAX_EXEMPT up to LUNCH_EXEMPT_CAP per month.
      Amount above the cap is TAXABLE.
      LUNCH_EXEMPT_CAP default = 730,000 VND/month
Regulation: Circular 96/2015/TT-BTC; updated by subsequent Ministry of Finance guidance
Configurable via: statutory_rule VN_LUNCH_EXEMPT_CAP (rule_category = TAX); pay_element.element_type = TAX_EXEMPT_CAPPED
```

**BR-011: 13th Month Salary Pro-ration**
```
Rule: THIRTEENTH_MONTH = BASE_SALARY × (months_worked_in_year / 12)
      months_worked_in_year = count of full months worked from January 1 (or hire date) to December 31
      Partial months: configurable rounding (default: round to nearest 0.5 month)
      Tax treatment: TAXABLE; included in gross for PIT in the month paid
Configurable via: pay_element THIRTEENTH_MONTH with formula referencing months_worked_in_year variable; pay_profile_element binding determines which profile receives this element
```

**BR-012: Piece-Rate Calculation**
```
Rule: PIECE_PAY = Σ(qty_i × lookupRate(product_code_i, quality_grade_i))
      where lookupRate reads from the piece_rate_table configuration for the worker's pay_profile
      Quality grade multipliers are stored as rate multipliers in the piece_rate_table — not hardcoded
      Minimum wage floor (BR-071) applies: if PIECE_PAY < REGIONAL_MINIMUM_WAGE then flag exception
Configurable via: piece_rate_table configuration (product_code × quality_grade → rate_vnd × effective_date); pay_profile.pay_method = PIECE_RATE
```

**BR-013: Hourly Pay — Multi-Rate Table**
```
Rule: For HOURLY workers, gross = Σ(hours_by_shift_type × rate(shift_type, grade, effective_date))
      shift_type values: REGULAR, NIGHT, OT_WEEKDAY, OT_WEEKEND, OT_HOLIDAY
      Rate lookup: pay_profile_rate_config table (shift_type × grade → rate_per_hour_vnd)
      Individual worker override: hourly_rate_multiplier in compensation_snapshot (default = 1.00)
Configurable via: pay_profile_rate_config table; compensation_snapshot.hourly_rate_multiplier
```

**BR-014: Grade-Step Pay — TABLE_LOOKUP Mode**
```
Rule: When pay_profile.grade_step_mode = TABLE_LOOKUP:
      GRADE_STEP_SALARY = pay_scale_table[grade_code][step_code].salary_amount_vnd
      for the effective_date at the start of the pay period
Configurable via: pay_scale_table (grade_code × step_code → salary_amount_vnd × effective_date); pay_profile.pay_scale_table_code
```

**BR-015: Grade-Step Pay — COEFFICIENT_FORMULA Mode**
```
Rule: When pay_profile.grade_step_mode = COEFFICIENT_FORMULA:
      GRADE_STEP_SALARY = grade_coefficient(grade_code, step_code) × VN_LUONG_CO_SO
      VN_LUONG_CO_SO = statutory_rule(VN_BASE_SALARY_2024).value (currently 2,340,000 VND/month)
Regulation: Government Decree on base salary (most recently NĐ 73/2024/NĐ-CP)
Configurable via: statutory_rule VN_LUONG_CO_SO; grade_coefficient is a configurable lookup table in pay_scale_table
```

**BR-016: Step Progression**
```
Rule: Automatic step progression: after tenure_months_at_step >= STEP_PROGRESSION_MONTHS (configurable),
      worker advances to the next step code in the pay_scale_table.
      Progression is triggered by a scheduled job, not manually.
Configurable via: step_progression_rule table (grade_code × step_code → months_required, next_step_code)
```

**BR-017: Hybrid Piece-Rate — SI Basis Mode**
```
Rule: For PIECE_RATE workers with a hybrid model (BASE_COMPONENT + PIECE_RATE_COMPONENT):
      If si_basis_mode = SI_BASIS_BASE_ONLY: SI_basis = BASE_COMPONENT only
      If si_basis_mode = SI_BASIS_FULL_GROSS: SI_basis = BASE_COMPONENT + PIECE_RATE_COMPONENT
      PIT is always computed on total gross (BASE + PIECE_RATE) regardless of si_basis_mode
Configurable via: pay_profile.si_basis_mode (SI_BASIS_BASE_ONLY | SI_BASIS_FULL_GROSS)
```

**BR-018: Task-Based Pay — Freelance Withholding**
```
Rule: For TASK_BASED workers (contract_type maps to SERVICE_CONTRACT SI exemption):
      If single_payment_amount >= FREELANCE_WITHHOLDING_THRESHOLD then withhold FREELANCE_TAX_RATE
      FREELANCE_WITHHOLDING_THRESHOLD default = 2,000,000 VND
      FREELANCE_TAX_RATE default = 10%
      If single_payment_amount < threshold: no withholding
      SI contributions are NOT applied (service contract is SI-exempt per BR-034)
Regulation: Circular 111/2013/TT-BTC
Configurable via: statutory_rule VN_FREELANCE_WITHHOLDING_THRESHOLD; statutory_rule VN_FREELANCE_TAX_RATE
```

**BR-019: Task-Based Pay — Milestone Trigger**
```
Rule: Payment for TASK_BASED is triggered when a milestone is marked complete by an authorized admin.
      Payment amount is defined in the task_definition (task_code, total_amount_vnd, milestone_schedule).
      Partial milestone payments are supported if milestone_schedule defines multiple tranches.
Configurable via: task_definition configuration; milestone completion event triggers a payroll run of type TASK_PAYMENT
```

---

### Group BR-020 to BR-039: Social Insurance Contribution Rules

**BR-020: BHXH Employee Contribution**
```
Rule: BHXH_EMPLOYEE = min(SI_BASIS, SI_CEILING) × BHXH_EMPLOYEE_RATE
      BHXH_EMPLOYEE_RATE default = 0.08 (8%)
Regulation: Social Insurance Law 58/2014/QH13; Decree 73/2024/NĐ-CP
Configurable via: statutory_rule VN_BHXH_EMP_RATE
```

**BR-021: BHXH Employer Contribution**
```
Rule: BHXH_EMPLOYER = min(SI_BASIS, SI_CEILING) × BHXH_EMPLOYER_RATE
      BHXH_EMPLOYER_RATE default = 0.175 (17.5%)
      Employer contributions are NOT deducted from worker pay; they are employer cost elements (EMPLOYER_CONTRIBUTION type)
Regulation: Social Insurance Law 58/2014/QH13; Decree 73/2024/NĐ-CP
Configurable via: statutory_rule VN_BHXH_EMP_RATE_EMPLOYER
```

**BR-022: BHYT Employee Contribution**
```
Rule: BHYT_EMPLOYEE = min(SI_BASIS, SI_CEILING) × BHYT_EMPLOYEE_RATE
      BHYT_EMPLOYEE_RATE default = 0.015 (1.5%)
Regulation: Health Insurance Law 25/2008/QH12 (as amended)
Configurable via: statutory_rule VN_BHYT_EMP_RATE
```

**BR-023: BHYT Employer Contribution**
```
Rule: BHYT_EMPLOYER = min(SI_BASIS, SI_CEILING) × BHYT_EMPLOYER_RATE
      BHYT_EMPLOYER_RATE default = 0.03 (3%)
Configurable via: statutory_rule VN_BHYT_EMP_RATE_EMPLOYER
```

**BR-024: BHTN Employee Contribution**
```
Rule: BHTN_EMPLOYEE = min(SI_BASIS, SI_CEILING) × BHTN_EMPLOYEE_RATE
      BHTN_EMPLOYEE_RATE default = 0.01 (1%)
Regulation: Employment Law 38/2013/QH13
Configurable via: statutory_rule VN_BHTN_EMP_RATE
```

**BR-025: BHTN Employer Contribution**
```
Rule: BHTN_EMPLOYER = min(SI_BASIS, SI_CEILING) × BHTN_EMPLOYER_RATE
      BHTN_EMPLOYER_RATE default = 0.01 (1%)
Configurable via: statutory_rule VN_BHTN_EMP_RATE_EMPLOYER
```

**BR-026: SI Contribution Ceiling**
```
Rule: SI_CEILING = SI_CEILING_MULTIPLIER × VN_LUONG_CO_SO
      SI_CEILING_MULTIPLIER default = 20
      VN_LUONG_CO_SO current = 2,340,000 VND/month
      SI_CEILING current = 20 × 2,340,000 = 46,800,000 VND/month
      This ceiling applies to BHXH, BHYT, and BHTN equally (single ceiling for all SI types in Vietnam)
Regulation: Decree 73/2024/NĐ-CP
Configurable via: statutory_rule VN_SI_CEILING_MULTIPLIER; statutory_rule VN_LUONG_CO_SO
```

**BR-027: SI Basis Definition**
```
Rule: SI_BASIS = contractual_monthly_salary (as defined in the labor contract)
      For MONTHLY_SALARY: SI_BASIS = BASE_SALARY + position_allowance (if included in contract wage)
      For PIECE_RATE hybrid: governed by BR-017 (si_basis_mode config)
      Variable bonuses, performance pay, and expense reimbursements are EXCLUDED from SI_BASIS
      The exact composition of SI_BASIS is configurable per pay_element (si_basis_flag = INCLUDED / EXCLUDED)
Regulation: Social Insurance Law 58/2014/QH13, Article 89; Decree 115/2015/NĐ-CP
Configurable via: pay_element.si_basis_inclusion per element
```

**BR-028: SI Eligibility — Unlimited-Term Contract**
```
Rule: Workers on UNLIMITED_TERM contract (hợp đồng không xác định thời hạn) are eligible for all SI:
      BHXH = YES, BHYT = YES, BHTN = YES
Regulation: Social Insurance Law 58/2014/QH13, Article 2
Configurable via: si_eligibility_rule (contract_type → [BHXH, BHYT, BHTN] eligibility flags)
```

**BR-029: SI Eligibility — Fixed-Term Contract (12–36 months)**
```
Rule: Workers on FIXED_TERM_12_36 contract are eligible for all SI:
      BHXH = YES, BHYT = YES, BHTN = YES
Regulation: Social Insurance Law 58/2014/QH13, Article 2
Configurable via: si_eligibility_rule
```

**BR-030: SI Eligibility — Probation (≤ 60 days)**
```
Rule: Workers in PROBATION status (≤ 60 days) are NOT eligible for any SI contributions:
      BHXH = NO, BHYT = NO, BHTN = NO
      When probation period exceeds 60 days (illegal per Labor Code but may occur), a validation warning fires.
Regulation: Labor Code 45/2019/QH14, Article 25; Social Insurance Law 58/2014/QH13
Configurable via: si_eligibility_rule (contract_type = PROBATION → all NO)
```

**BR-031: SI Eligibility — Service Contract / Freelance**
```
Rule: Workers on SERVICE_CONTRACT or FREELANCE contract type are NOT eligible for any SI contributions:
      BHXH = NO, BHYT = NO, BHTN = NO
      Flat withholding (BR-018) applies instead of progressive PIT for TASK_BASED payment type.
Regulation: Social Insurance Law 58/2014/QH13, Article 2
Configurable via: si_eligibility_rule (contract_type = SERVICE_CONTRACT → all NO)
```

**BR-032: SI Eligibility Matrix (Summary)**
```
contract_type                 BHXH  BHYT  BHTN
UNLIMITED_TERM                YES   YES   YES
FIXED_TERM_12_36              YES   YES   YES
FIXED_TERM_LT_12              YES   YES   NO    (BHTN exempt for contracts < 12 months)
PROBATION                     NO    NO    NO
SERVICE_CONTRACT              NO    NO    NO
FREELANCE                     NO    NO    NO
INTERN                        NO    YES   NO    (BHYT only for interns per policy)

Note: This matrix is stored as si_eligibility_rule configuration — not as code logic.
Columns in the matrix and values are fully configurable.
Configurable via: si_eligibility_rule table mapping contract_type × insurance_type → is_eligible boolean
```

**BR-033: Split-Period SI Calculation (Mid-Month Ceiling Change)**
```
Rule: When VN_LUONG_CO_SO changes effective mid-month:
      BHXH_EMP = (days_old_ceiling / total_days) × min(SI_BASIS, OLD_CEILING) × BHXH_RATE
               + (days_new_ceiling / total_days) × min(SI_BASIS, NEW_CEILING) × BHXH_RATE
      Same formula applies to BHYT and BHTN.
      The split is calculated for any statutory_rule that has an effective_date within the pay period.
Configurable via: statutory_rule.valid_from triggering split-period logic in the payroll engine
```

**BR-034: Annual BHTN Ceiling (Unemployment Insurance Annual Cap)**
```
Rule: BHTN has an annual contribution cap. Once YTD_BHTN_EMPLOYEE >= BHTN_ANNUAL_CAP, no further BHTN is deducted.
      BHTN_ANNUAL_CAP = SI_CEILING × 12 × BHTN_EMPLOYEE_RATE (effectively capped by annual ceiling)
      YTD_BHTN_EMPLOYEE balance is checked before each monthly calculation.
Configurable via: balance_def YTD_BHTN_EMP; statutory_rule VN_BHTN_ANNUAL_CAP
```

**BR-035: Employer Contribution Separation**
```
Rule: Employer SI contributions (BHXH_EMPLOYER, BHYT_EMPLOYER, BHTN_EMPLOYER) are computed as
      separate EMPLOYER_CONTRIBUTION type elements. They are NOT deducted from worker net salary.
      They are included in employer cost reports and GL journal entries (TK 3383 for BHXH/BHYT/BHTN employer).
Configurable via: pay_element.classification = EMPLOYER_CONTRIBUTION
```

---

### Group BR-040 to BR-059: PIT Calculation Rules

**BR-040: PIT Taxable Income Formula (Tax Resident)**
```
Rule: TAXABLE_INCOME = GROSS_INCOME − SI_EMPLOYEE_TOTAL − PERSONAL_DEDUCTION
                     − (DEPENDENT_COUNT × DEPENDENT_DEDUCTION) − OTHER_DEDUCTIBLE_ITEMS
      where:
        SI_EMPLOYEE_TOTAL = BHXH_EMPLOYEE + BHYT_EMPLOYEE + BHTN_EMPLOYEE
        PERSONAL_DEDUCTION = 11,000,000 VND/month
        DEPENDENT_DEDUCTION = 4,400,000 VND/person/month
        OTHER_DEDUCTIBLE_ITEMS = charitable contributions + voluntary pension (if applicable)
      If TAXABLE_INCOME <= 0: PIT = 0
Regulation: NQ 954/2020/UBTVQH14 (personal deduction), PIT Law 04/2007/QH12
Configurable via: statutory_rule VN_PIT_PERSONAL_DEDUCTION; statutory_rule VN_PIT_DEPENDENT_DEDUCTION
```

**BR-041: PIT Progressive Brackets (Tax Resident)**
```
Rule: Monthly PIT calculated on monthly TAXABLE_INCOME using 7 progressive brackets:
      Bracket 1: 0 – 5,000,000 VND         → 5%
      Bracket 2: 5,000,001 – 10,000,000 VND → 10%
      Bracket 3: 10,000,001 – 18,000,000 VND → 15%
      Bracket 4: 18,000,001 – 32,000,000 VND → 20%
      Bracket 5: 32,000,001 – 52,000,000 VND → 25%
      Bracket 6: 52,000,001 – 80,000,000 VND → 30%
      Bracket 7: > 80,000,000 VND             → 35%
      All bracket thresholds and rates stored as statutory_rule VN_PIT_BRACKETS_2020
      with valid_from = 2020-07-01 (effective date of NQ 954).
Regulation: PIT Law 04/2007/QH12, Schedule 1; NQ 954/2020/UBTVQH14
Configurable via: statutory_rule VN_PIT_BRACKETS_2020 (rule_type = PROGRESSIVE, formula_json contains brackets array)
```

**BR-042: PIT — Non-Tax-Resident Path**
```
Rule: For workers with tax_residency_status = NON_RESIDENT:
      PIT = VIETNAM_SOURCED_INCOME × NON_RESIDENT_TAX_RATE
      NON_RESIDENT_TAX_RATE default = 20%
      No personal deduction or dependent deduction applies.
      No progressive brackets — flat rate only.
Regulation: PIT Law 04/2007/QH12, Article 18
Configurable via: statutory_rule VN_PIT_NON_RESIDENT_RATE; tax_residency_status on compensation_snapshot
```

**BR-043: PIT — Freelance / Service Contract Path**
```
Rule: For TASK_BASED workers (SERVICE_CONTRACT):
      If payment_amount >= FREELANCE_WITHHOLDING_THRESHOLD (2,000,000 VND): PIT = payment_amount × 10%
      If payment_amount < threshold: PIT = 0
      No progressive brackets, no personal/dependent deduction.
Regulation: Circular 111/2013/TT-BTC, Article 25
Configurable via: statutory_rule VN_FREELANCE_WITHHOLDING_THRESHOLD; statutory_rule VN_FREELANCE_TAX_RATE
```

**BR-044: Allowance Tax Treatment — TAXABLE**
```
Rule: Allowances with tax_treatment = TAXABLE are fully included in GROSS_INCOME for PIT calculation.
      Examples: position allowance, seniority allowance, region allowance (if above statutory)
Configurable via: pay_element.tax_treatment = TAXABLE
```

**BR-045: Allowance Tax Treatment — TAX_EXEMPT**
```
Rule: Allowances with tax_treatment = TAX_EXEMPT are excluded from GROSS_INCOME entirely.
      Examples: relocation allowance (one-time), uniform allowance (within limits)
Configurable via: pay_element.tax_treatment = TAX_EXEMPT
```

**BR-046: Allowance Tax Treatment — TAX_EXEMPT_CAPPED**
```
Rule: Allowances with tax_treatment = TAX_EXEMPT_CAPPED:
      Exempt portion = min(actual_amount, exemption_cap)
      Taxable portion = max(0, actual_amount - exemption_cap)
      Only the taxable portion is included in GROSS_INCOME for PIT.
      The cap is stored as a parameter on the pay_element or as a statutory_rule reference.
Configurable via: pay_element.tax_treatment = TAX_EXEMPT_CAPPED; pay_element.exempt_cap_vnd or statutory_rule reference
```

**BR-047: Monthly PIT Computation (Not Annualized)**
```
Rule: Monthly PIT is computed on the monthly TAXABLE_INCOME directly (not annualized).
      PIT = progressive_tax(TAXABLE_INCOME, VN_PIT_BRACKETS_2020)
      YTD_PIT accumulates monthly PIT for annual settlement comparison.
      Exception: Annual settlement (BR-048) compares annualized actual vs. annualized withheld.
Configurable via: pay_formula PIT_MONTHLY; no annualization in regular monthly run
```

**BR-048: Annual PIT Settlement**
```
Rule: Annual settlement triggered by admin (SETTLEMENT_TIMING per PayGroup: DECEMBER_PAYROLL or JANUARY_STANDALONE):
      ANNUAL_TAXABLE = YTD_GROSS − YTD_SI_EMPLOYEE − (PERSONAL_DEDUCTION × 12) − (AVG_DEPENDENT_COUNT × DEPENDENT_DEDUCTION × 12)
      ANNUAL_PIT_DUE = progressive_tax(ANNUAL_TAXABLE, VN_PIT_BRACKETS_2020 scaled to annual)
      SETTLEMENT_DELTA = ANNUAL_PIT_DUE − YTD_PIT_WITHHELD
      If SETTLEMENT_DELTA > 0: worker owes additional PIT (add to December or January payslip)
      If SETTLEMENT_DELTA < 0: worker overpaid PIT (refund via payslip deduction reversal or carry to next year)
Regulation: PIT Law 04/2007/QH12, Article 28
Configurable via: pay_group.SETTLEMENT_TIMING (DECEMBER_PAYROLL | JANUARY_STANDALONE)
```

**BR-049: Dependent Count Source**
```
Rule: DEPENDENT_COUNT is read from CO as registered_dependent_count (effective-dated integer).
      Value is captured in compensation_snapshot at cut-off date.
      Configurable fallback: if DEPENDENT_SOURCE = PR_OVERRIDE, Payroll Admin can enter count manually.
Configurable via: pay_profile.DEPENDENT_SOURCE parameter (CO_API default | PR_OVERRIDE for standalone deployments)
```

**BR-050: PIT Personal Deduction Amount**
```
Rule: PERSONAL_DEDUCTION = statutory_rule VN_PIT_PERSONAL_DEDUCTION.value = 11,000,000 VND/month
      This value changes only by National Assembly resolution.
Regulation: NQ 954/2020/UBTVQH14
Configurable via: statutory_rule VN_PIT_PERSONAL_DEDUCTION
```

**BR-051: PIT Dependent Deduction Amount**
```
Rule: DEPENDENT_DEDUCTION_PER_PERSON = statutory_rule VN_PIT_DEPENDENT_DEDUCTION.value = 4,400,000 VND/person/month
Regulation: NQ 954/2020/UBTVQH14
Configurable via: statutory_rule VN_PIT_DEPENDENT_DEDUCTION
```

---

### Group BR-060 to BR-069: Deduction Priority and Net Calculation

**BR-060: Deduction Priority Order**
```
Rule: Deductions are applied in strict priority order (highest to lowest):
      Priority 1 (highest): Court-ordered garnishment (GARNISHMENT type element)
      Priority 2: SI employee contributions (BHXH_EMPLOYEE, BHYT_EMPLOYEE, BHTN_EMPLOYEE)
      Priority 3: PIT
      Priority 4: Internal loan repayment (LOAN_REPAYMENT type element)
      Priority 5: Salary advance recovery (ADVANCE_RECOVERY type element)
      Priority 6: Voluntary deductions (union dues, welfare fund)
      Priority 7: Benefit premiums (worker share of enrolled benefit plans)
      Priority order is stored as pay_element.priority_order; overridden per profile in pay_profile_element.priority_order
Configurable via: pay_element.priority_order; pay_profile_element.priority_order override
```

**BR-061: Net Salary Calculation**
```
Rule: NET_SALARY = GROSS_INCOME
                 − BHXH_EMPLOYEE − BHYT_EMPLOYEE − BHTN_EMPLOYEE
                 − PIT
                 − LOAN_REPAYMENT (sum of all active loans)
                 − ADVANCE_RECOVERY (if any advance was paid this period)
                 − VOLUNTARY_DEDUCTIONS (sum)
                 − BENEFIT_PREMIUMS (sum)
                 − GARNISHMENT (sum of court orders)
Configurable via: pay_element.classification and priority_order drive the calculation pipeline
```

**BR-062: Net Salary Cannot Be Negative**
```
Rule: If computed NET_SALARY < 0 (or = 0), the worker is flagged as an exception.
      The system halts processing for that worker.
      The Payroll Admin must resolve the exception manually (adjust deduction amounts or confirm override).
      The run cannot proceed to approval while unresolved exceptions exist.
Configurable via: validation_rule NET_FLOOR_CHECK; no override without admin acknowledgment
```

**BR-063: VND Rounding**
```
Rule: Final NET_SALARY is rounded to the nearest 1,000 VND using the configured rounding method.
      Default: ROUND_HALF_UP (0–499 round down, 500–999 round up)
      Intermediate calculation values use BigDecimal arithmetic — no rounding until final step.
Configurable via: pay_profile.rounding_method (ROUND_HALF_UP | ROUND_DOWN | ROUND_UP | ROUND_NEAREST)
```

**BR-064: Monetary Arithmetic Precision**
```
Rule: All monetary calculations use BigDecimal with scale = 2 throughout the pipeline.
      Floating-point types (float, double) are prohibited for any monetary value.
      Final VND rounding to nearest 1,000 is applied only at the NET_SALARY post-processing step.
Configurable via: Technical constraint — enforced in engine code; not configurable
```

---

### Group BR-070 to BR-079: Minimum Wage Rules

**BR-070: Regional Minimum Wage — Monthly**
```
Rule: Worker's computed GROSS must meet the applicable regional minimum wage:
      Region 1 (Hà Nội, HCM City, Bình Dương...): 4,960,000 VND/month
      Region 2 (other provincial cities and towns): 4,410,000 VND/month
      Region 3 (remaining provincial districts): 3,860,000 VND/month
      Region 4 (rural communes): 3,450,000 VND/month
      If GROSS < REGIONAL_MINIMUM_WAGE: exception flagged; admin must acknowledge before approval.
Regulation: Decree 38/2022/NĐ-CP (and subsequent updates)
Configurable via: statutory_rule VN_MIN_WAGE_REGION_1/2/3/4 (rule_category = SOCIAL_INSURANCE); pay_profile.min_wage_rule_id FK
```

**BR-071: Regional Minimum Wage — Hourly**
```
Rule: Hourly minimum = REGIONAL_MINIMUM_WAGE_MONTHLY / (STANDARD_WORK_DAYS_MONTH × STANDARD_HOURS_DAY)
      Default: 4,960,000 / (26 × 8) = 23,846 VND/hour (Region 1)
      Hourly workers' effective hourly rate must be >= hourly minimum for all regular hours.
Configurable via: pay_profile parameters STANDARD_WORK_DAYS_MONTH, STANDARD_HOURS_DAY; statutory_rule VN_MIN_WAGE_REGION_x
```

**BR-072: Piece-Rate Minimum Wage Floor**
```
Rule: Even when computed PIECE_PAY falls below REGIONAL_MINIMUM_WAGE, the worker must receive
      at least the regional minimum. The shortfall is flagged as a minimum wage exception.
      The admin must acknowledge before the run can be approved.
      (Exception: the system does not automatically top up — admin decision is required)
Configurable via: validation_rule MIN_WAGE_FLOOR_CHECK in post-processing stage
```

**BR-073: Minimum Wage Exception Acknowledgment**
```
Rule: If any worker's gross falls below the regional minimum wage, the worker appears in the Exception Report.
      The exception must be acknowledged by the Payroll Admin with a written reason code before the run proceeds.
      Acknowledgment is recorded in the audit log.
Configurable via: exception_type = MIN_WAGE_VIOLATION; requires admin_acknowledgment = true before run proceeds
```

---

### Group BR-080 to BR-089: Approval and Period Management Rules

**BR-080: Pay Period State Machine**
```
Rule: Pay periods follow this state machine (irreversible transitions only where noted):
      OPEN → PROCESSING (when a production run is initiated)
      PROCESSING → PENDING_APPROVAL (when all workers processed successfully)
      PENDING_APPROVAL → APPROVED (when all approval levels pass)
      APPROVED → LOCKED (when Finance Manager releases payment; IRREVERSIBLE)
      LOCKED periods can only be corrected via a CORRECTION off-cycle run in the next open period.
Configurable via: pay_mgmt.pay_period.status_code state machine; period_lock triggers SHA-256 hash generation
```

**BR-081: Payroll Run State Machine**
```
Rule: Individual payroll runs follow this state machine:
      QUEUED → RUNNING (when engine picks up the run)
      RUNNING → DRY_RUN_COMPLETE (if mode = DRY_RUN; no persistence)
      RUNNING → SIMULATION_COMPLETE (if mode = SIMULATION; side-by-side comparison stored)
      RUNNING → PENDING_APPROVAL (if mode = PRODUCTION; all stages passed)
      RUNNING → FAILED (if any stage fails; full rollback)
      PENDING_APPROVAL → APPROVED (after all approval levels)
      FAILED → QUEUED (admin can re-queue after error correction)
Configurable via: pay_mgmt.batch.status_code; pay_engine.run_request.status_code
```

**BR-082: Multi-Level Approval**
```
Rule: Production runs require 3 approval levels before payment file release:
      Level 1: Payroll Admin submits for approval (submitter role)
      Level 2: HR Manager reviews and approves/rejects
      Level 3: Finance Manager final approval and bank file release
      Each approver can: APPROVE (proceed), REJECT (return to OPEN with comments), REQUEST_CHANGES (return to submitter)
      Rejection at any level returns the period to OPEN state; the run must be corrected and re-submitted.
Configurable via: approval_workflow_config per PayGroup (level, required_role, timeout_hours); managed by Temporal workflow engine
```

**BR-083: Rejection Behavior**
```
Rule: When a run is rejected at any approval level:
      - The run status is set to REJECTED with the rejector's comments
      - The pay period returns to OPEN state
      - The Payroll Admin receives notification with rejection reason
      - A new run must be initiated after corrections are made
      - The previous rejected run is preserved in audit log (not deleted)
Configurable via: rejection_action configured in approval_workflow; audit_log captures rejection event
```

**BR-084: Period Lock and Immutability**
```
Rule: Once a period transitions to LOCKED:
      - All payroll_result records for that period become immutable (no direct UPDATE/DELETE permitted)
      - A SHA-256 hash is computed from each worker's result record at lock time (stored as integrity_hash)
      - Automated nightly verification compares stored hashes against current record values
      - Any mismatch triggers immediate alert to Platform Admin and Finance Manager
      - No direct correction to a LOCKED period; corrections via CORRECTION off-cycle run only
Configurable via: FR-23; integrity_hash stored in pay_engine.run_result; nightly verification job is system-level
```

**BR-085: Concurrent Run Prevention**
```
Rule: The system must prevent concurrent production runs for the same PayGroup and period.
      Any attempt to initiate a second run while one is RUNNING or PENDING_APPROVAL returns an error.
      Concurrency lock implemented at the PayGroup + period_id level.
Configurable via: Technical constraint — enforced by concurrency lock in pay_mgmt.batch; not configurable
```

**BR-086: YTD Balance Accumulators**
```
Rule: System maintains YTD and MTD balances per worker per calendar year:
      YTD_GROSS, YTD_PIT, YTD_BHXH_EMP, YTD_BHYT_EMP, YTD_BHTN_EMP, YTD_NET
      Balances reset to 0 on January 1 of each year (automated reset job)
      MTD balances reset on the first day of each period.
Configurable via: balance_def definitions; reset_freq_code configuration
```

---

### Group BR-090 to BR-099: Retroactive and Off-Cycle Rules

**BR-090: Retroactive Adjustment Depth**
```
Rule: Retroactive adjustments can be calculated for up to RETRO_MAX_PERIODS closed periods.
      RETRO_MAX_PERIODS default = 12 (configurable per PayGroup)
      Retroactive delta is added to the NEXT OPEN payroll period as a RETRO_ADJUSTMENT element.
Configurable via: pay_group parameter RETRO_MAX_PERIODS
```

**BR-091: Retroactive Confirmation Gate**
```
Rule: When a retroactive adjustment spans more than RETRO_CONFIRM_THRESHOLD periods:
      RETRO_CONFIRM_THRESHOLD default = 3
      The system requires explicit admin confirmation with a displayed impact summary before proceeding.
      Impact summary shows: number of affected workers, estimated total delta amount, affected periods.
Configurable via: pay_group parameter RETRO_CONFIRM_THRESHOLD
```

**BR-092: Retroactive Delta Calculation**
```
Rule: RETRO_DELTA_for_period = recalculated_element_amount − original_paid_amount
      Recalculation uses the new compensation data (e.g., backdated salary change) but applies
      the statutory rules that were in effect for the original closed period (not current rules).
      If original period was LOCKED, the recalculation creates a new RETRO run, not a modification.
Configurable via: pay_engine retroactive calculation uses statutory_rule.valid_from for historical period lookups
```

**BR-093: Off-Cycle Run Types**
```
Rule: Off-cycle runs are supported for the following types:
      TERMINATION: Final pay run for a departing worker
      ADVANCE: Salary advance payment (creates ADVANCE_RECOVERY in next regular cycle)
      CORRECTION: Error correction after period close (creates delta elements in next open period)
      BONUS_RUN: Standalone bonus disbursement (PIT calculated with context of regular income YTD)
      Off-cycle runs follow the same approval workflow as regular runs.
Configurable via: pay_mgmt.batch.batch_type enum
```

**BR-094: Advance Recovery**
```
Rule: When an ADVANCE run is approved and paid:
      An ADVANCE_RECOVERY element is automatically created for the next regular payroll period.
      ADVANCE_RECOVERY amount = advance amount paid (in full unless partial recovery is configured)
      ADVANCE_RECOVERY is a DEDUCTION type element with priority_order = 5 (per BR-060)
Configurable via: advance_recovery_config per PayGroup; partial recovery (installment count) is configurable
```

**BR-095: Termination Pay Configuration**
```
Rule: TERMINATION run elements are determined by termination_pay_config table:
      termination_pay_config maps (termination_type × pay_profile_id) → [list of PayElement codes]
      termination_type values: RESIGNATION, MUTUAL_AGREEMENT, REDUCTION_IN_FORCE, CONTRACT_EXPIRY
      Each element in the list is included in the TERMINATION run for that worker.
      Severance formula: SEVERANCE_AMOUNT = tenure_years × 0.5 × AVG_MONTHLY_SALARY
      The 0.5 coefficient is statutory_rule VN_SEVERANCE_COEFFICIENT
Regulation: Labor Code 45/2019/QH14, Article 46
Configurable via: termination_pay_config table; statutory_rule VN_SEVERANCE_COEFFICIENT
```

**BR-096: Worker Joins After Cut-Off**
```
Rule: If a worker's effective_start_date in their working_relationship falls AFTER the period cut-off date,
      that worker is NOT included in the current period's payroll run.
      They are enrolled for the NEXT period, with pro-ration calculated from their start date.
Configurable via: pre-validation stage checks working_relationship.effective_start_date against period cut-off
```

---

### Group BR-100 to BR-109: Multi-Entity and Data Isolation Rules

**BR-100: Legal Entity Data Isolation**
```
Rule: All payroll data is isolated by legal_entity_id.
      A user with access to Legal Entity A cannot retrieve, list, modify, or export payroll data
      belonging to Legal Entity B.
      Attempting cross-entity access returns HTTP 403 (not 404 — to prevent entity enumeration).
Configurable via: Row-level security (RLS) on all payroll tables indexed by legal_entity_id via pay_group FK
```

**BR-101: PayGroup to Legal Entity Binding**
```
Rule: A PayGroup belongs to exactly one legal_entity_id.
      A legal entity may have multiple PayGroups (e.g., by department, pay method, or cost center).
      A worker's working_relationship is tied to a legal_entity; they can only be assigned to
      PayGroups belonging to that same legal_entity.
Configurable via: pay_master.pay_group.legal_entity_id FK (mandatory, non-nullable)
```

**BR-102: Multi-Working-Relationship Workers**
```
Rule: A worker may have multiple working_relationships across different legal entities.
      Each working_relationship is processed independently in its respective entity's PayGroup.
      There is no automatic cross-entity gross aggregation for PIT purposes (primary employer rules apply
      per Vietnamese PIT law for the primary working_relationship only).
Configurable via: compensation_snapshot is created per working_relationship_id, not per worker_id
```

**BR-103: Cross-Entity Report Access**
```
Rule: Single-entity reports are the default in V1. Cross-entity rollup report access requires
      CROSS_ENTITY_REPORT_VIEWER role, feature flag MULTI_ENTITY_REPORTING = ENABLED.
      Report queries parameterized by legal_entity_ids[] — V1 always passes single-element array.
Configurable via: feature flag MULTI_ENTITY_REPORTING; role CROSS_ENTITY_REPORT_VIEWER
```

**BR-104: Snapshot at Cut-Off**
```
Rule: A compensation_snapshot is taken for each working_relationship at the PayCalendar cut-off date.
      The snapshot captures: contract_type, legal_entity_id, cost_center_id, grade_code,
      registered_dependent_count, tax_residency_status, base_salary, all active allowance amounts,
      bank_account_id, BHXH number, tax ID.
      Once the production run completes, the snapshot is immutable.
      SNAPSHOT_POINT is configurable on PayCalendar (CUT_OFF_DATE | PERIOD_END_DATE).
Configurable via: pay_calendar.SNAPSHOT_POINT parameter; compensation_snapshot table
```

---

## 5. Integration Specifications

### 5.1 CO → PR Integration

| Field | Type | Timing | Fallback if Unavailable |
|-------|------|--------|------------------------|
| working_relationship_id | UUID | Live query + snapshot | Pre-validation fails; run blocked |
| contract_type | Enum | Snapshot at cut-off | Pre-validation fails; run blocked |
| worker name, tax_id | String | Snapshot at cut-off | Pre-validation fails; run blocked |
| bhxh_number | String | Snapshot at cut-off | Pre-validation warning; worker excluded from SI report |
| nationality_code | ISO 3166-1 alpha-2 | Snapshot at cut-off | Default to RESIDENT PIT path; admin warned |
| registered_dependent_count | Integer | Snapshot at cut-off | Default to 0; admin warned |
| bank_account_id | UUID | Snapshot at cut-off | Worker excluded from bank file; admin warned |
| cost_center_id | UUID | Snapshot at cut-off | GL posted to default cost center; admin warned |
| effective_start_date | Date | Live query | Determines period enrollment eligibility |

**Event/API Contract**: CO exposes a versioned REST API (`GET /working-relationships/{id}/snapshot?as_of={date}`) that returns the compensation_snapshot payload. PR calls this at cut-off. CO also publishes `WorkingRelationshipChanged` event that invalidates cached snapshots.

**Data freshness SLA**: CO data must be finalized at least 24 hours before payroll cut-off time.

### 5.2 TA → PR Integration

| Field | Type | Timing | Fallback if Unavailable |
|-------|------|--------|------------------------|
| working_relationship_id | UUID | AttendanceLocked event | Pre-validation fails for that worker |
| period_start, period_end | Date | AttendanceLocked event | From PayCalendar |
| actual_work_days | Integer | AttendanceLocked event | Pre-validation fails; admin must resolve |
| overtime_hours_by_type | Map(shift_type→hours) | AttendanceLocked event | OT = 0; admin warned |
| unpaid_leave_days | Integer | AttendanceLocked event | 0 assumed; admin warned |
| piece_qty_by_product_grade | Map | AttendanceLocked event | Pre-validation fails for PIECE_RATE workers |
| hours_by_shift_type | Map | AttendanceLocked event | Pre-validation fails for HOURLY workers |

**Event Schema**: `AttendanceLocked` event published by TA to PR via message queue (Kafka topic: `ta.attendance.locked`).
```json
{
  "event_type": "AttendanceLocked",
  "working_relationship_id": "uuid",
  "period_start": "YYYY-MM-DD",
  "period_end": "YYYY-MM-DD",
  "locked_at": "ISO8601",
  "actual_work_days": 22,
  "overtime_hours": {
    "OT_WEEKDAY": 4.5,
    "OT_WEEKEND": 8.0,
    "OT_HOLIDAY": 0.0,
    "NIGHT": 16.0
  },
  "unpaid_leave_days": 0,
  "piece_data": [
    {"product_code": "P001", "quality_grade": "A", "qty": 150}
  ],
  "hours_by_shift_type": {
    "REGULAR": 176,
    "NIGHT": 16
  }
}
```

**Lock SLA**: TA must publish AttendanceLocked events for ≥ 95% of workers in a PayGroup at least 24 hours before payroll cut-off. Pre-cut-off completeness dashboard shows lock % in real time.

**Holiday Calendar Source**: TA module owns the holiday calendar (AQ-07 Decision). PR reads via `GET /ta/holiday-calendars/{jurisdiction_code}?year={year}`. PR caches locally at period start. Cache invalidated by `HolidayCalendarUpdated` event from TA.

### 5.3 TR → PR Integration

| Field | Type | Timing | Fallback if Unavailable |
|-------|------|--------|------------------------|
| base_salary | BigDecimal VND | Snapshot at cut-off | Pre-validation fails; run blocked |
| allowances_by_code | Map(code→amount) | Snapshot at cut-off | Missing allowances treated as 0; admin warned |
| approved_bonus | BigDecimal VND | Snapshot at cut-off | 0; no bonus in current period |
| taxable_bridge_items | List(code, amount, tax_type) | Snapshot at cut-off | 0; admin warned for RSU/option exercise |
| benefit_premium_deductions | Map(code→amount) | Snapshot at cut-off | 0 deductions; admin warned |

**Data Contract**: TR publishes `CompensationSnapshotReady` event when compensation data is finalized for a period. PR reads snapshot via `GET /tr/compensation-snapshots/{working_relationship_id}?as_of={cut_off_date}`.

**TR/PR Boundary**: TR provides raw compensation amounts (what to pay). PR applies all statutory rules (how to deduct). TR does NOT execute PIT, SI, or OT calculations.

### 5.4 PR → Bank

**Payment Channels** (AQ-05 Decision D):
- `FILE_MANUAL`: system generates formatted file; finance team uploads manually to bank portal
- `API_PUSH`: system calls bank API directly (V2 implementation; interface designed in V1)

**File Formats by Bank**:

| Bank | Format | Encoding | Key Fields |
|------|--------|----------|-----------|
| Vietcombank (VCB) | CSV per VCB corporate banking spec | UTF-8 | account_no, amount, description, beneficiary_name |
| BIDV | CSV per BIDV Internet Banking Pro spec | UTF-8 | account_no, amount, transfer_content, full_name |
| Techcombank (TCB) | CSV per TCB SmartBanking spec | UTF-8 | account_number, transfer_amount, transfer_note |

File format templates are configurable data (`bank_payment_config` table) — not hardcoded column mappings. When a bank changes format, only the template data needs updating.

**Payment description format**: "[Company Code]-LUONG-[Period]-[Worker ID]" (configurable template)

### 5.5 PR → Accounting (GL Journal)

**GL Account Mapping**:

| Element | Dr/Cr | Account | Description |
|---------|-------|---------|-------------|
| BASE_SALARY, allowances | Dr | TK 642 (Chi phí quản lý) or TK 641 (Chi phí bán hàng) per cost_center | Salary expense |
| NET_SALARY payable | Cr | TK 334 (Phải trả người lao động) | Net pay liability |
| BHXH_EMPLOYER | Dr | TK 642 (or 641) | Employer SI expense |
| BHXH_EMPLOYER payable | Cr | TK 3383 (BHXH phải nộp) | SI payable |
| PIT payable | Cr | TK 3335 (Thuế TNCN phải nộp) | PIT liability |
| BHYT_EMPLOYER payable | Cr | TK 3383 | Combined with BHXH |
| BHTN_EMPLOYER payable | Cr | TK 3383 | Combined with BHXH |

Each journal line includes: account_code, dr_cr, amount_vnd, cost_center_id, description, pay_period_reference.
GL mapping is configurable per pay_element via `pay_master.gl_mapping` table.

### 5.6 PR → Tax Authority

**PIT Quarterly Declaration (Form 05/KK-TNCN)**:
- Format: XML per Circular 08/2013/TT-BTC
- Frequency: Quarterly (Q1–Q4) or monthly if PIT withheld > 50M VND/month
- Content: All workers with PIT withheld; YTD_GROSS, YTD_PIT_WITHHELD per worker
- Submission: File generated by PR; manual upload to eTax portal (GDT.gov.vn) in V1

**PIT Annual Settlement (Form 05/QTT-TNCN)**:
- Format: XML per Circular 08/2013/TT-BTC
- Timing: Configurable (DECEMBER_PAYROLL or JANUARY_STANDALONE per BR-048)
- Content: Annual settlement result per worker; over/under-withholding amounts

**BHXH Monthly Contribution List (Form D02-LT)**:
- Format: Per VssID upload specification
- Frequency: Monthly
- Content: All SI-eligible workers; BHXH number, contribution basis, worker and employer amounts
- Submission: File generated by PR; manual upload to VssID portal in V1

---

## 6. Assumptions and Dependencies

| ID | Assumption | Confidence | Validation Owner | Impact if False |
|----|------------|:----------:|-----------------|----------------|
| A1 | V1 pilot customers use monthly payroll frequency | 0.80 | Product Manager | Multi-frequency support required sooner |
| A2 | TR team accepts re-scoping of calculation_rule_def (AQ-01 resolved as Option D) | 0.75 | Architecture Lead | Duplicate calculation logic persists; sprint 1 blocked |
| A3 | CO module exposes working_relationship and dependent_count as versioned queryable attributes | 0.75 | CO Team Lead | PR must maintain local copy of worker data |
| A4 | TA module guarantees attendance lock for ≥ 95% of workers before cut-off | 0.55 | TA Team Lead | Payroll delayed or partial run required |
| A5 | No V1 pilot customers require automated bank API payment push | 0.70 | Product Manager | FILE_MANUAL insufficient; API_PUSH required in V1 |
| A6 | Vietnam PIT 7-bracket schedule and SI rates stable through V1 launch | 0.80 | Regulatory Counsel | System update required; configurable via statutory_rule |
| A7 | Drools 8 on target infrastructure achieves 1,000 workers in < 30 seconds | 0.60 | Engineering Lead | Load test POC required in Phase 0 as go/no-go gate |
| A8 | V1 pilot customers have a maximum of 5 legal entities per group | 0.75 | Customer Success | Multi-entity architecture sufficient but tested edge cases expand |
| A9 | Workers' dependent registrations are finalized in CO before payroll cut-off | 0.65 | CO Team + HR Ops | PIT calculated with incorrect dependent count; correction required |
| A10 | Bank file formats (VCB, BIDV, TCB) are stable for V1 delivery period | 0.80 | Finance Lead | Template update required; low code risk if bank_payment_config is data-driven |

---

## 7. Out of Scope (V1)

These items are explicitly excluded from V1 design, build, and testing:

| # | Item | Deferred To |
|---|------|-------------|
| 1 | Formula Studio DSL self-service UI for HR/Payroll admins | V2 |
| 2 | Bi-weekly, semi-monthly, weekly payroll frequencies (feature flag exists; not activated) | V2 |
| 3 | Multi-currency payroll (USD, SGD, EUR components) | V2 |
| 4 | Automated bank API payment push (API_PUSH channel interface designed; implementation deferred) | V2 |
| 5 | Cross-entity consolidated payroll reports (group-level rollup) | V2 |
| 6 | Severance calculation UI (termination_pay_config supports it; formula only; no UI wizard) | V2 |
| 7 | CPF or non-Vietnam statutory frameworks | Phase 2 |
| 8 | Payroll cost forecasting and budget prediction | V2 analytics |
| 9 | Real-time gross-to-net live preview (worker-facing) | V2 |
| 10 | Third-party HRIS data import / migration tooling | Separate workstream |
| 11 | Mobile app payslip access (web-responsive only in V1) | V2 |
| 12 | BHXH online submission API integration (file generation only; portal upload is manual) | V2 |
| 13 | eTax XML auto-submission (file generation only; manual portal upload) | V2 |
