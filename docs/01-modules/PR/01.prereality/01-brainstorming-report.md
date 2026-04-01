# Payroll Module — Brainstorming Report

**Artifact**: 01-brainstorming-report.md
**Module**: Payroll (PR)
**Date**: 2026-03-27
**Method**: SCAMPER, Six Thinking Hats, 10x Thinking, Problem Inversion

---

## 1. Framing the Problem Space

Before diverging, let us bound the problem:

- **Core job**: Ensure every worker receives exactly the correct net payment on the correct date, compliant with all applicable regulations, with full auditability.
- **Who is harmed when this fails**: Workers (wrong pay), company (regulatory penalty, tax audit), payroll team (manual rework, compliance exposure).
- **What has traditionally caused failure**: Hardcoded rules that can't adapt to new decrees, reliance on Excel with no audit trail, no simulation before policy changes, batch processing that takes hours and errors out mid-run.

---

## 2. Core Payroll Processing — Gross-to-Net

### 2.1 Standard Pipeline

The canonical Vietnamese payroll pipeline:

```
[Input Data] → [Pre-validation] → [Gross] → [SI Deductions] → [PIT] → [Other Deductions] → [Net] → [Post-processing]
```

**Gross components**:
- Base salary (pro-rated if partial month)
- Overtime (weekday 150%, weekend 200%, holiday 300%, night shift +30%)
- Allowances: lunch (800K–730K threshold), phone, transport, region, position, seniority
- Variable pay: performance bonus, commission, project completion bonus
- 13th month salary (when included in period)
- One-time bonuses

**SI deductions**:
- BHXH employee: 8% of min(gross, 46,800,000)
- BHYT employee: 1.5% of min(gross, 46,800,000)
- BHTN employee: 1% of min(gross, 46,800,000)
- Not applicable: probation workers, freelancers/service contractors

**PIT deductions**:
- Taxable income = Gross − SI deductions − Personal deduction (11M) − Dependents × 4.4M − other
- Progressive 7-bracket calculation
- Expat variant: 20% flat (non-resident) or progressive (resident)

**Other deductions** (priority order):
1. Garnishment orders (court-mandated, highest priority)
2. Internal loan repayment
3. Salary advance recovery
4. Voluntary deductions (union dues, welfare fund)
5. Benefit premium deductions (employee share of health insurance premiums)

**Net calculation**:
Net = Gross − BHXH_emp − BHYT_emp − BHTN_emp − PIT − all_other_deductions

**Post-processing**:
- VND rounding (nearest 1,000)
- Minimum wage check per region (4 wage regions in Vietnam)
- Retroactive delta application
- YTD/MTD balance updates

### 2.2 Alternative Entry Points — What if we think from the formula engine angle?

If HR can write formulas in Excel-like syntax, what could they build beyond standard payroll?

- Productivity-linked salary: `BASE + (PRODUCTIVITY_SCORE - 100) * 50000` where score comes from TA module
- Tiered commission: `tierValue(MONTHLY_REVENUE, COMMISSION_TIER_TABLE)`
- Weather allowance: `when PROVINCE == "HN" && MONTH in [12,1,2] then COLD_WEATHER_BONUS else 0`
- Dual-currency workers: allowances in USD, base salary in VND

---

## 3. Payroll Components — Taxonomy Exploration

### 3.1 SCAMPER on PayElement Classification

**Substitute**: Replace the 3-type classification (EARNING / DEDUCTION / TAX) with a richer 6-type model:
- BASE (base wage)
- ALLOWANCE (supplementary income, often with tax-exempt thresholds)
- VARIABLE (performance-linked, commission, bonus)
- DEDUCTION (statutory SI, voluntary)
- TAX (PIT, withholding)
- EMPLOYER_CONTRIBUTION (BHXH_employer, not visible to worker on payslip)
- INFORMATIONAL (work days, YTD totals — display only)

**Combine**: EARNING + INFORMATIONAL into COMPUTATION_ELEMENT; TAX as sub-type of DEDUCTION. Reduces fragmentation at the cost of semantic clarity.

**Eliminate**: Remove INFORMATIONAL classification — store as derived columns on PayrollResult, not as configured elements. Reduces formula dependency complexity.

**Reverse**: What if workers submitted their own expense claims and the payroll engine validated them against policy rather than HR configuring every element? → Self-service expense-to-payroll integration.

### 3.2 Six Thinking Hats on Element Design

- **White (Facts)**: Most enterprises have 15–40 pay elements per profile. Vietnam specifically requires at minimum: BASE_SALARY, BHXH_EMP, BHYT_EMP, BHTN_EMP, PIT, NET_SALARY.
- **Yellow (Optimism)**: A rich element taxonomy enables automatic payslip generation without additional configuration — elements know how to display themselves.
- **Black (Caution)**: Too many element types creates configuration burden. HR admins may misconfigure element type, leading to incorrect gross/net calculations.
- **Red (Emotion)**: Workers care about clarity in their payslip. Every element should have a worker-friendly display name, not a system code.
- **Green (Creativity)**: What if elements could carry "explanation templates"? "BHXH_EMPLOYEE: 8% of your salary up to 46.8M ceiling, per Social Insurance Law" — human-readable context embedded.
- **Blue (Process)**: Must standardize element lifecycle: Draft → Approved → Active → Deprecated. Cannot activate element unless formula is also Approved.

---

## 4. Vietnam-Specific Scenarios

### 4.1 PIT Calculation Edge Cases

| Scenario | Challenge | Solution Approach |
|----------|-----------|-------------------|
| Worker with 3 dependents | Dependency count may change mid-year | Effective-date tracking on dependent count; retroactive if registered late |
| Expat who crosses 183-day threshold mid-year | Tax regime changes from 20% flat to progressive | Trigger PIT recalculation from day 1 of year when threshold crossed |
| Worker with multiple income sources | Only primary employer applies deductions | Worker self-declares; secondary employer withholds flat 10% |
| Annual PIT settlement | Monthly withholding may over/under-estimate annual tax | YTD_GROSS and YTD_PIT balance tracking; settlement in December or January payroll |
| RSU vest creating large one-time income | May push into higher bracket | TaxableItem from TR.TaxableBridge; integrated into taxable income for the vest month |

### 4.2 SI Contribution Edge Cases

| Scenario | Challenge | Solution Approach |
|----------|-----------|-------------------|
| Decree mid-period (e.g., new base salary on 15th) | Pro-rated contribution under two ceilings | Split-period calculation: days under old rule + days under new rule |
| Worker transfers between entities mid-month | Two employers may both contribute | PayGroup assignment tracks effective date; each entity pays for their covered days |
| Probation extended beyond 60 days | Changes SI eligibility | Contract type change event triggers PayGroup reassignment and SI activation |
| Worker on unpaid leave for full month | Zero SI contribution | Validation rule flags; HR confirms before run |
| Worker reaches contribution ceiling for the year | No further SI deduction | YTD_BHXH balance check in formula: when YTD_BHXH >= BHXH_ANNUAL_CEILING then 0 |

### 4.3 13th Month Salary

Vietnam's 13th-month bonus (lương tháng 13) is customary but not legally mandated. Payroll considerations:
- May be paid in December or split across the year
- Is taxable income — included in PIT calculation for the month paid
- Should appear as a distinct PayElement (THIRTEENTH_MONTH or YEAR_END_BONUS) with `type = EARNING`
- Pro-rated for workers who joined mid-year (formula: BASE_SALARY × months_worked / 12)

### 4.4 Overtime Complexity

Vietnamese overtime has 4 dimensions:
1. Day type: regular workday, weekend, public holiday
2. Time of day: daytime vs. night shift (22:00–06:00)
3. Cumulative cap: maximum OT hours per month (24h for monthly workers)
4. Hourly rate basis: varies by worker type and employment terms

This argues strongly for a configurable OT multiplier table in `pay_master`, not hardcoded rates.

### 4.5 Pay Method Diversity by Industry

Vietnamese enterprises span a wide range of industries, each with a dominant pay method. The Payroll module must accommodate all of them through configurable pay method definitions rather than a single monthly-salary model.

| Industry | Dominant Pay Method | Key Payroll Considerations |
|----------|--------------------|-----------------------------|
| Garment / Textile (may mặc) | Piece-rate primary (lương sản phẩm), base salary for SI calculation only | Rate table by product type and quality grade; minimum wage floor guarantee; daily production input from TA or factory floor system |
| Manufacturing / Assembly (sản xuất linh kiện, lắp ráp) | Piece-rate + base salary hybrid | Base provides SI calculation basis; piece-rate is the variable component; team vs. individual output allocation; quality rejection rates affect pay |
| Retail / Hospitality / Healthcare | Hourly pay (lương theo giờ) with shift differentials | Regular / night / weekend / holiday rate differentiation; part-time workers share the same engine as full-time; minimum hours guarantee per pay period |
| Government / State-Owned Enterprises (SOE) | Coefficient-based pay scale (ngạch bậc lương, hệ số × lương cơ sở) | Grade and step assigned in CO; LUONG_CO_SO is a statutory_rule parameter updated by government decree; automatic step progression after tenure milestone |
| Technology / Professional Services / White-collar | Monthly salary (lương tháng) + annual performance bonus + equity compensation | Base monthly salary is the core; bonus and equity are separate PayElements with PIT treatment; 13th month common |
| Construction / Project-based (xây dựng) | Daily rate (nhật công) with weather and downtime provisions | Daily rate × worked days; downtime days (weather, site closure) may be paid at a reduced standby rate; contract workers often on TASK_BASED or daily rate model |

**Implications for PayProfile design**: Each industry row above corresponds to a distinct `PAY_METHOD` configuration on the PayProfile. The formula engine applies the pay-method-specific formula set at gross calculation time. All rates, thresholds, and multipliers are configurable data — the same engine runs all industry types without code differences.

---

## 5. Multi-Company / Multi-Legal Entity Support

### 5.1 Scenarios Brainstormed

| Setup | Payroll Challenge |
|-------|-------------------|
| Holding company with 5 subsidiaries (VN only) | Separate payroll runs per legal entity; consolidated reporting for HR leadership |
| Joint venture (VN + SG entity) | Dual currency; SG workers on CPF rules, VN workers on BHXH |
| Worker seconded from VN entity to SG entity | Pro-rated split across two payroll runs; tax liability split |
| Foreign company with VN branch (separate legal entity) | VN labor law applies to VN entity; parent may have different practices |
| Startup with 50 workers expanding to 5,000 over 3 years | Payroll must scale without reconfiguration |

### 5.2 Configuration Hierarchy

The PayProfile hierarchy (base → extended) enables:
- `VN-BASE`: minimal VN compliance (BHXH, BHYT, BHTN, PIT)
- `VN-STAFF`: extends VN-BASE + lunch + phone allowances
- `VN-EXECUTIVE`: extends VN-BASE + car allowance + representative allowance
- `VN-FREELANCE`: standalone (no SI, flat 10% withholding)
- `SG-STANDARD`: CPF, SG income tax — completely separate rule set

---

## 6. Payroll Cycle Variations

### 6.1 Standard Monthly (Vietnam Default)

- Cut-off: 25th of month
- T&A data must be locked before cut-off
- Payment date: 1st of following month
- Formula versions locked at cut-off

### 6.2 Off-Cycle / Special Runs

| Run Type | Trigger | Challenge |
|----------|---------|-----------|
| Termination pay | Worker contract ends | Final payslip includes remaining earned vacation, severance (if applicable), pro-rated 13th month |
| Advance payment | Worker requests salary advance | Creates ADVANCE_DEDUCTION element for next regular payroll run |
| Correction run | Error found after period locked | Retroactive delta: recalculate affected elements, carry correction to next open period |
| Bonus run | Standalone bonus disbursement | Separate PayGroup run for bonus-only elements; PIT calculated on bonus + regular income context |
| QuickPay | Executive or high-priority case | V4 DBML introduces QUICKPAY batch_type — enables individual worker expedited run |

### 6.3 Year-End Special Processing

- Annual PIT settlement: compare YTD withholding vs. progressive annual calculation
- BHXH annual contribution verification against agency records
- Balance resets (YTD → 0 on January 1)
- Formula version archival and new-year activation

---

## 7. Integration Points — Expanded Thinking

### 7.1 What TA Must Provide

- `actual_work_days`: days physically worked (excludes unpaid leave, excludes approved paid leave from SI perspective differently)
- `overtime_hours`: broken down by type (weekday / weekend / holiday / night)
- `unpaid_leave_days`: deducted from actual_work_days for proration
- `approved_leave_taken`: informational (does not reduce pay)
- `shift_type` per day: for night shift premium calculation

### 7.2 What CO Must Provide

- Worker identity (ID, name, tax ID, BHXH number)
- Working relationship (legal entity, contract type, start date, end date)
- Assignment (position, department, cost center)
- Grade/level (for formula conditions like senior allowance)
- Dependent count (for PIT deduction — may also be managed in HR/Worker profile)
- Bank account details (verified)
- Nationality / residency status (for expat PIT treatment)

### 7.3 What TR Must Provide

- Current compensation snapshot: base salary amount, all allowance amounts by component code
- Bonus allocation (approved): amount per worker for the period
- TaxableItem: RSU vest events, option exercise events with monetary value
- Benefit premium deduction: worker's share of enrolled benefits

### 7.4 What PR Must Send Back

- PayrollRunCompleted event (with summary metrics)
- Payslip availability notification (per worker)
- GL journal batch (to accounting system)
- Bank payment file (to banking portal)
- Tax declaration file (to eTax portal)
- BHXH contribution file (to BHXH portal)

---

## 8. Reporting and Compliance — Full Landscape

### 8.1 Operational Reports (Used Every Run)

- **Payroll Register**: Every worker, every element, current period values
- **Variance Report**: Element-level comparison current period vs. prior period, flagged if >20% change
- **Exception Report**: Workers with anomalies (negative net, zero BHXH on non-exempt worker, PIT = 0 on high income)
- **Bank Payment Summary**: Total disbursement per bank, per account, per worker
- **Pre-Payment Checklist**: All pending approvals, unverified bank accounts, incomplete T&A

### 8.2 Management Reports

- **Payroll Cost by Department / Cost Center**: HR and Finance visibility
- **Budget vs. Actual**: Planned quỹ lương vs. actual run cost
- **Headcount Report**: Workers processed in each run, by employment type
- **YTD Cumulative Report**: Running totals for PIT, SI, gross, net

### 8.3 Statutory Reports

- Quarterly PIT declaration (XML per Circular 8/2013)
- Annual PIT settlement (Form 05/QTT-TNCN)
- Monthly BHXH contribution list (D02-LT)
- BHXH worker registration / update (D01-TS)
- Annual labor report (Form BC-HĐLĐ)

---

## 9. Self-Service Features

### 9.1 Worker Self-Service

- View payslip by period (web + mobile)
- Download payslip PDF
- Download PIT certificate (Chứng từ khấu trừ thuế TNCN — Form 03/TNCN)
- View YTD summary (gross, PIT withheld, SI contributions)
- Register/update dependents (triggers downstream effect on PIT calculation)

### 9.2 Manager Self-Service

- Approve payroll at summary level (not individual line items)
- View team payroll cost trend
- Flag unusual items before approving

---

## 10. Edge Cases and Scenarios to Account For

| Edge Case | Category | Impact if Unhandled |
|-----------|----------|---------------------|
| Worker joins after cut-off date | Pro-ration | Worker included in wrong period, incorrect partial pay |
| Worker terminates before cut-off but after month start | Pro-ration + final pay | Missed termination benefits, underpayment/overpayment |
| Negative net salary (deductions exceed gross) | Net floor | Illegal — net cannot be zero or negative; system must block |
| Bank account inactive or closed | Payment | Payment rejected; requires fallback process |
| Decree effective mid-period | Statutory | Wrong SI ceiling for part of month; requires split calculation |
| Formula circular dependency | Engine | Infinite loop in calculation; must be caught at compile time |
| Payroll run fails at stage 3 of 5 | Atomicity | Partial results; must roll back or resume cleanly |
| Two concurrent payroll runs for same pay group | Concurrency | Data corruption; must prevent via period locking |
| Worker has income from charity/prize (non-labor income) | PIT | Different treatment (10% flat) — requires separate element classification |

---

## 11. 10x Thinking — If Payroll Were 10x Better

1. **Real-time gross-to-net preview**: Worker enters expected overtime hours and immediately sees estimated net for the month — without running payroll.

2. **Proactive compliance alerts**: When a new government decree is published, the system automatically flags which formulas need updating and emails the Payroll Admin — before the effective date.

3. **Self-healing retroactive**: When CO updates a salary change with a past effective date, PR automatically queues a retroactive run without admin intervention.

4. **Explainable payslip**: Every line item on the payslip has an expandable explanation: "Why was BHXH 3,744,000? Because your gross (46,800,000) equals the ceiling, and the rate is 8%."

5. **Budget prediction**: Given headcount plans, grade distributions, and current formulas, PR generates a 12-month payroll cost forecast with confidence intervals.

---

## 12. Pay Method Types — Comprehensive Use Case Exploration

This section explores the full diversity of pay methods that the xTalent Payroll module must support, derived from real Vietnamese enterprise scenarios. All pay methods are modeled as configurable data through the Pay Method Engine — no pay method logic is hardcoded.

---

### 12.1 Monthly Salary Workers (Lương Theo Tháng) — Baseline

**Who**: White-collar employees, office staff, management, technical professionals.

**How pay is calculated**: Fixed monthly salary amount, pro-rated by worked days when the worker does not work the full month.

**Proration logic**:
- `GROSS = MONTHLY_SALARY * (ACTUAL_WORK_DAYS / STANDARD_WORK_DAYS_IN_PERIOD)`
- Standard work days per month: configurable per PayCalendar (typically 26 days for a 6-day week, or 22 days for a 5-day week in Vietnam).
- Proration method is a configurable parameter on the PayProfile: `CALENDAR_DAYS` (divides by total calendar days in month) or `WORK_DAYS` (divides by standard working days) or `NONE` (no proration — full month amount regardless).
- Workers who join mid-month are pro-rated from their start date; workers who terminate mid-month are pro-rated to their last worked day.

**SI basis**: Full monthly salary (capped at SI ceiling: 20 × lương cơ sở = 46,800,000 VND as of Decree 73/2024).

**PIT basis**: Gross monthly salary + all taxable allowances, minus SI employee deductions, personal deduction, and dependent deductions.

**This is the current baseline — all other pay methods are additive or alternative to this foundation.**

---

### 12.2 Hourly Workers (Lương Theo Giờ Công)

**Who**: Manufacturing floor workers, retail staff, hospitality workers, healthcare auxiliaries, part-time workers in any industry.

**Core calculation**: `GROSS = Σ(hours_by_shift_type × rate_for_shift_type)`

**Multi-rate scenarios explored**:

| Scenario | Description | Configuration Approach |
|----------|-------------|----------------------|
| Regular daytime hours | Standard rate for normal business hours | `REGULAR_RATE` in `pay_profile_rate_config` |
| Night shift hours (22:00–06:00) | Higher rate required by Labor Code | `NIGHT_RATE` = `REGULAR_RATE × NIGHT_PREMIUM_MULTIPLIER`; multiplier is configurable statutory_rule |
| Overtime weekday hours | Rate = 150% of regular rate | `OT_WEEKDAY_MULTIPLIER = 1.50` configurable in statutory_rule |
| Overtime weekend hours | Rate = 200% of regular rate | `OT_WEEKEND_MULTIPLIER = 2.00` configurable in statutory_rule |
| Overtime public holiday hours | Rate = 300% of regular rate | `OT_HOLIDAY_MULTIPLIER = 3.00` configurable in statutory_rule |
| Specialist skill premium | Same worker has different rate for specialized task type | `work_category` dimension added to `pay_profile_rate_config` |

**Rate configuration model**: Profile-level default rates with worker-level multiplier overrides. Example: All factory workers share a `REGULAR_RATE = 40,000 VND/hour` at the PayProfile level; a senior technician has `hourly_rate_multiplier = 1.25` in their compensation snapshot, resulting in effective rate of 50,000 VND/hour. Both the profile default and the worker multiplier are configurable data.

**Input data required from TA**: `hours_by_shift_type` breakdown per worker per period (regular hours, night hours, OT weekday hours, OT weekend hours, OT holiday hours). TA integration must provide this structured breakdown — not just a total hours figure.

**SI basis for hourly workers**: SI contributions are based on the worker's monthly wage as declared to BHXH (not necessarily the variable gross amount). For hourly workers, the SI basis is configurable per PayProfile: either `ACTUAL_GROSS` or `SI_BASIS_DECLARED_MONTHLY` (a stable reference wage registered with BHXH). This mirrors real Vietnamese practice where BHXH contributions for hourly workers use a declared minimum reference salary.

**Minimum hour guarantee**: Some collective labor agreements include a minimum guaranteed pay per period. Configurable as a `MIN_HOURS_GUARANTEE` per PayProfile — if total hours worked are below the threshold, the worker is paid the minimum.

**Edge cases**:
- Part-time worker with variable hours each month — handled naturally by the hourly × rate formula.
- Worker crosses from daytime to night shift mid-shift — TA must split hours by shift type; PR receives the split.
- Worker reaches monthly OT cap (configurable, default 24 hours/month per Labor Code) — formula checks `YTD_OT_HOURS_THIS_MONTH` against cap and stops applying OT premium beyond the cap.

---

### 12.3 Piece-Rate Workers (Lương Sản Phẩm / Khoán Sản Phẩm)

**Who**: Garment workers (may chiếc), electronics assembly workers (lắp ráp linh kiện), food processing workers, any production worker where output is measurable in discrete units.

**Core calculation**: `PIECE_PAY = Σ(qty_product_i × rate_product_i × quality_multiplier_i)`

**Data flow**:
```
Production System / Factory Floor
    → TA Module (attendance + production quantities locked)
    → Input Variables pushed to Payroll (PIECE_QTY_PRODUCT_A = 150, PIECE_QTY_PRODUCT_B = 320)
    → Payroll formula evaluates: Σ(qty_i × lookupRate(product_code_i, quality_grade_i))
    → Minimum wage floor check applied
    → Final PIECE_PAY amount
```

**Rate table structure**: A `piece_rate_config` table stores `(product_code, quality_grade, rate_per_unit_vnd, effective_date)`. This is pure configuration data — rates change by updating table records, not by changing code.

Example:
| Product Code | Quality Grade | Rate per Unit (VND) |
|-------------|:-------------:|:-------------------:|
| SHIRT_TYPE_A | GRADE_A | 5,000 |
| SHIRT_TYPE_A | GRADE_B | 4,500 |
| SHIRT_TYPE_A | REJECTED | 0 |
| TROUSER_TYPE_B | GRADE_A | 7,000 |
| TROUSER_TYPE_B | GRADE_B | 6,300 |

**Team-based piece rate**: When a team collectively produces output and individual allocation is proportional, the formula receives the team's total allocation for a worker: `WORKER_PIECE_ALLOCATION = TEAM_TOTAL_PIECE_PAY × (worker_weight / team_total_weight)`. Team allocation weights are configurable parameters.

**Quality-linked rates**: Quality inspectors submit quality grades per batch; TA/production system translates to per-worker quality grade distributions; the `quality_multiplier` column in `piece_rate_config` applies the appropriate adjustment. Grade A = full rate, Grade B = configurable fraction (e.g., 90%), Rejected = 0.

**Minimum wage floor guarantee**: Vietnamese law requires that even piece-rate workers receive at least the regional minimum wage (vùng lương tối thiểu). After computing `PIECE_PAY`, the engine checks: `if PIECE_PAY < MIN_WAGE_REGION then GROSS = MIN_WAGE_REGION + flag_exception(PIECE_BELOW_MIN_WAGE)`. The minimum wage amounts by region are configurable `statutory_rule` records, never hardcoded.

**Hybrid model (base + piece rate)**: Many manufacturing enterprises pay a small base salary (for SI contribution purposes) plus a piece-rate variable component. The base salary covers SI contribution requirements; the piece-rate component is the actual earnings driver.
- `BASE_COMPONENT` (MONTHLY_SALARY type): fixed monthly amount, used as SI calculation basis
- `PIECE_RATE_COMPONENT` (PIECE_RATE type): variable production-linked amount
- `GROSS = BASE_COMPONENT + PIECE_RATE_COMPONENT`
- `SI_BASIS = BASE_COMPONENT` (configurable — some enterprises include piece rate in SI basis, which is a configurable PayProfile parameter)
- `PIT_BASIS = GROSS` (total including piece rate)

**Edge cases**:
- Worker produces nothing in a period (illness, absence) — piece pay = 0; minimum wage floor applies; flagged as exception.
- Multiple product types with different quality grades in the same period — formula iterates over all input variables and sums.
- Rate table changes effective mid-month — effective_date on piece_rate_config resolves which rate applies to which production date (TA integration must include production_date per quantity record).

---

### 12.4 Pay Scale / Grade-Step Workers (Bảng Lương Theo Ngạch Bậc)

**Who**: Government employees, SOE workers, and large private enterprises using formal salary bands with grade and step progression.

**Two distinct Vietnamese models**:

**Model 1 — Government / SOE Coefficient Model (Hệ số lương × Lương cơ sở)**:
- Worker is assigned a grade (ngạch) and step (bậc) in CO
- Pay = `GRADE_COEFFICIENT(ngạch, bậc) × LUONG_CO_SO`
- `LUONG_CO_SO` is a statutory minimum base wage set by government decree (currently 2,340,000 VND/month as of July 2024 per NĐ 73/2024)
- When the government announces a new `LUONG_CO_SO`, the admin updates one `statutory_rule` record and all affected workers automatically get the new salary on next payroll run
- SI basis for government workers = `GRADE_COEFFICIENT × LUONG_CO_SO` (the full pay scale amount, not actual take-home)

**Model 2 — Corporate Grade-Band Model (Bảng lương công ty)**:
- HR defines a pay scale table: `(grade_code, step_code) → salary_amount_vnd`
- Worker is assigned grade and step in CO assignment
- Pay = `lookupPayScale(table_code, grade_code, step_code, effective_date)`
- When the company adjusts salary bands, they update the table records with a new effective date; existing workers get the new salary automatically on the effective date

**Automatic step progression**: Workers advance from step X to step X+1 after N months (configurable per grade code). The system checks `months_at_current_step` against the `step_progression_rule` table and triggers an automatic step increment event, which flows to CO (or is managed within CO with a PR listener). The progression rule (months required per grade × step) is configurable data.

**Multiple active scale tables**: A company with different job families (technical vs. administrative vs. sales) may have separate salary tables for each. `pay_profile.pay_scale_table_code` (FK to `pay_scale_table`) allows each PayProfile to reference a different scale. All tables can be active simultaneously.

**Scale version management**: `pay_scale_table` records include `effective_date`. When a company updates its salary bands annually, they create new records with the new year's effective date. The formula engine uses `effective_date` to pick the correct scale version for each payroll period.

**Edge cases**:
- Government changes `LUONG_CO_SO` effective mid-month: split-period calculation applies (similar to SI ceiling split-period logic)
- Worker promoted from step 3 to step 4 mid-month: proration logic applies — days at step 3 rate + days at step 4 rate
- Worker assigned to a PayProfile whose pay_scale_table_code has no row for their grade/step: system throws validation exception before run; admin must update the scale table

---

### 12.5 Contract / Task-Based Pay (Lương Khoán / Giao Khoán)

**Who**: Freelance workers, contractors paid per project or milestone, commission agents, consultants engaged for a specific scope.

**Core model**: Payment is triggered by completion of a defined task or milestone, not by time worked.

**Task definition**: A `task_definition` record specifies: `task_code`, `description`, `total_contract_amount_vnd`, `milestone_schedule (milestone_code, percentage_of_total)`, `start_date`, `expected_end_date`, `worker_id`.

**Payment trigger**: When a milestone is marked complete (by HR admin or via integration with a project management system), a payment event is created. The payroll run picks up outstanding payment events and creates `TASK_PAYMENT` earnings for the affected workers.

**Tax treatment (critical)**: For freelance/service contract workers in Vietnam, PIT withholding applies differently:
- If payment per contract ≥ 2,000,000 VND in a single payment: withhold 10% flat (`FREELANCE_PIT_RATE` = 10% in `statutory_rule`)
- If payment < 2,000,000 VND: no withholding required
- Worker is responsible for self-filing if they have income from multiple sources
- The 2,000,000 VND threshold and 10% rate are configurable `statutory_rule` parameters — not hardcoded

**SI exemption**: True task-based contractors (hợp đồng khoán việc) are typically not eligible for BHXH/BHYT/BHTN. The eligibility rule is driven by `contract_type` on the working_relationship: `SERVICE_CONTRACT` → SI exempt. This is configurable via the `si_eligibility_rule` table.

**Milestone-based payment schedule example**:
- Contract total: 50,000,000 VND
- Milestone 1 (design complete, 20%): 10,000,000 VND — trigger: admin marks M1 complete
- Milestone 2 (development complete, 50%): 25,000,000 VND — trigger: admin marks M2 complete
- Milestone 3 (UAT sign-off, 30%): 15,000,000 VND — trigger: admin marks M3 complete
- Each milestone payment ≥ 2M: 10% PIT withheld → net payment = milestone amount × 0.90

**Edge cases**:
- Multiple milestones triggered in the same payroll period: summed for PIT threshold check
- Contract cancelled mid-way: partial payment for completed milestones only; remaining milestones set to CANCELLED status
- Worker simultaneously has both a regular employment contract and a freelance contract: the regular employment generates monthly salary (progressive PIT); the freelance contract generates TASK_PAYMENT (10% flat withholding) — these are separate working_relationship records and processed independently

---

### 12.6 Hybrid Pay Models

Real Vietnamese enterprises rarely use a single pure pay method. The most common hybrids and how the configurable engine handles them:

**Base Salary + Piece Rate (most common in manufacturing)**:
- `BASE_COMPONENT` provides stable, SI-compliant monthly salary
- `PIECE_RATE_COMPONENT` adds production-linked variable earnings
- Total GROSS = BASE + PIECE_RATE
- SI basis = configurable (BASE only, or BASE + PIECE_RATE, set on PayProfile)
- PIT basis = total GROSS
- Minimum wage floor = applies to GROSS total, not to each component individually

**Base Salary + Hourly Overtime (most common overall)**:
- All monthly salary workers who work overtime are already a hybrid: fixed base + variable OT
- OT is computed from hourly rate derivation (`BASE_SALARY / STANDARD_WORK_HOURS`) × OT multiplier
- This is handled by the existing OT premium calculation (FR-18) combined with the MONTHLY_SALARY pay method

**Base Salary + Commission (sales teams)**:
- `BASE_COMPONENT` (MONTHLY_SALARY)
- `COMMISSION_COMPONENT` (VARIABLE_PAY type, formula references sales performance metrics from CRM/TA integration)
- Commission formula: configurable (tiered table, flat percentage, or threshold-based)
- SI basis = BASE only (commission is not part of SI calculation basis in common Vietnamese practice)
- PIT basis = BASE + COMMISSION

**Guaranteed Minimum Floor Across All Models**:
The minimum wage floor applies universally regardless of pay method. Every pay method formula — hourly, piece-rate, grade-step, task-based, hybrid — passes through a final check:
```
if GROSS < lookupMinWage(REGION_CODE, PERIOD_DATE) then
  flag_exception("BELOW_MIN_WAGE", worker_id, GROSS, MIN_WAGE)
  // Admin must review and resolve before run can be finalized
```
The minimum wage amounts by region (vùng lương tối thiểu: Region 1 = 4,960,000, Region 2 = 4,410,000, Region 3 = 3,860,000, Region 4 = 3,450,000 VND/month as of 2024) are all stored as configurable `statutory_rule` records with `effective_date` — never hardcoded.

---

*Brainstorming techniques applied: SCAMPER, Six Thinking Hats, 10x Thinking, Problem Inversion. Outputs consolidated into requirements artifact.*
