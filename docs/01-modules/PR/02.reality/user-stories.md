# User Stories — Payroll Module (PR)

**Artifact**: user-stories.md
**Module**: Payroll (PR)
**Solution**: xTalent HCM
**Date**: 2026-03-27
**Version**: 1.0

> Terminology: all stories use "worker" (not employee), "working_relationship", "legal_entity", "pay_element", "pay_group", "pay_profile", "statutory_rule" per xTalent canonical terminology.

---

## Epic Summary

| Epic | Theme | Stories | P0 | P1 | P2 |
|------|-------|---------|----|----|-----|
| E1 | Pay Master Configuration | US-001 – US-009 | 7 | 2 | 0 |
| E2 | Production Payroll Run | US-010 – US-024 | 8 | 5 | 2 |
| E3 | Approval and Period Lock | US-025 – US-029 | 4 | 1 | 0 |
| E4 | Payslip and Bank File | US-030 – US-032 | 3 | 1 | 0 |
| E5 | Statutory Reports | US-033 – US-035 | 2 | 1 | 0 |
| E6 | Operational Reports | US-036 – US-039 | 2 | 2 | 0 |
| E7 | Worker Self-Service | US-040 – US-043 | 0 | 3 | 1 |
| E8 | Audit and Security | US-044 – US-048 | 4 | 1 | 0 |

**Total: 48 user stories** | P0: 30 | P1: 15 | P2: 3

---

## E1: Pay Master Configuration

### US-001: Create and Configure a PayGroup

**Epic**: E1 — Pay Master Configuration
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want to create a PayGroup linked to a legal entity, pay calendar, and currency, so that workers can be enrolled and payroll runs can be executed against it.

#### Acceptance Criteria

**Scenario 1 — Happy path: Create PayGroup successfully**

**Given** the Payroll Admin is logged in to Legal Entity "VNG Corp" and has the PAYROLL_ADMIN role
**When** they submit a new PayGroup with: code = "VNG-STAFF-HCM", name = "VNG Staff HCM", legal_entity = "VNG Corp", calendar = "VNG-MONTHLY-2026", currency = "VND"
**Then** a PayGroup record is created with status = ACTIVE
**And** the PayGroup is visible in the PayGroup list filtered by legal_entity = "VNG Corp"
**And** an audit log entry is created: action_type = "PAYGROUP_CREATED", entity = "VNG-STAFF-HCM"

**Scenario 2 — Duplicate code rejection**

**Given** a PayGroup with code "VNG-STAFF-HCM" already exists
**When** the Payroll Admin submits a new PayGroup with the same code
**Then** the system returns an error: "PayGroup code must be unique"
**And** no record is created

**Scenario 3 — Cross-legal-entity isolation**

**Given** the Payroll Admin for Legal Entity A creates a PayGroup
**When** a Payroll Admin for Legal Entity B attempts to view that PayGroup via direct URL
**Then** the system returns HTTP 403

### Business Rules Referenced
- BR-101 (PayGroup to legal entity binding), BR-100 (data isolation)

### Dependencies
- org_legal.entity record must exist; pay_calendar must exist for selected legal entity

---

### US-002: Define a PayElement with Formula and Tax Treatment

**Epic**: E1 — Pay Master Configuration
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want to define a PayElement with a formula, element type, tax treatment, and SI basis inclusion, so that it is available for inclusion in pay profiles.

#### Acceptance Criteria

**Scenario 1 — Happy path: Create taxable earning element**

**Given** the Payroll Admin has PAYROLL_ADMIN role
**When** they create a PayElement with: code = "POSITION_ALLOWANCE", name = "Position Allowance", classification = EARNING, tax_treatment = TAXABLE, si_basis_inclusion = EXCLUDED, proration_method = WORK_DAYS, formula = "POSITION_ALLOWANCE_AMOUNT" (input variable)
**Then** the element is saved with status = DRAFT
**And** the element appears in the element library with country_code = "VN"
**And** an audit log entry is created

**Scenario 2 — Tax-exempt capped element (lunch allowance)**

**Given** the Payroll Admin creates a lunch allowance element
**When** they set: code = "LUNCH_ALLOWANCE", tax_treatment = TAX_EXEMPT_CAPPED, exempt_cap reference = statutory_rule VN_LUNCH_EXEMPT_CAP
**Then** the element stores a reference to statutory_rule VN_LUNCH_EXEMPT_CAP (not a hardcoded amount)
**And** at calculation time, the exempt cap is read from the statutory_rule current value
**And** any amount above the cap is automatically included in TAXABLE_INCOME

**Scenario 3 — Formula references statutory_rule correctly**

**Given** the admin defines a formula for BHXH_EMPLOYEE element
**When** the formula text references "statutory_rule('VN_BHXH_EMP_RATE')" instead of "0.08"
**Then** the formula passes compile-time validation
**And** a formula that uses literal "0.08" is REJECTED with error: "Statutory rates must reference statutory_rule records, not literal values"

### Business Rules Referenced
- BR-027 (SI basis), BR-044/045/046 (tax treatment), BR-041 (no hardcoded rates)

### Dependencies
- statutory_rule records (VN_LUNCH_EXEMPT_CAP, VN_BHXH_EMP_RATE) must exist

---

### US-003: Configure a PayProfile with HOURLY Pay Method

**Epic**: E1 — Pay Master Configuration
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want to configure a PayProfile with pay_method = HOURLY and a multi-dimensional rate table, so that hourly workers are compensated accurately by shift type and grade.

#### Acceptance Criteria

**Scenario 1 — Happy path: Create HOURLY PayProfile with rate table**

**Given** the Payroll Admin creates a new PayProfile: code = "FACTORY-HOURLY", pay_method = HOURLY, proration_method = WORK_DAYS
**When** they configure the pay_profile_rate_config table with entries:
  - shift_type = REGULAR, grade = G3, rate = 35,000 VND/hour
  - shift_type = NIGHT, grade = G3, rate = 45,500 VND/hour (35,000 × 1.30)
  - shift_type = OT_WEEKDAY, grade = G3, rate = 52,500 VND/hour (35,000 × 1.50)
**Then** the profile is saved with all rate entries
**And** no rate values are hardcoded in application code — all stored in pay_profile_rate_config table

**Scenario 2 — Individual worker rate multiplier**

**Given** worker A has compensation_snapshot.hourly_rate_multiplier = 1.10 (10% premium)
**When** the payroll engine calculates gross for worker A on a REGULAR shift
**Then** effective_rate = pay_profile_rate_config(REGULAR, grade) × 1.10
**And** the calculation log records the multiplier application

**Scenario 3 — Missing rate for shift type**

**Given** the rate table has no entry for shift_type = OT_HOLIDAY, grade = G3
**When** TA data includes OT_HOLIDAY hours for a G3 worker in this PayProfile
**Then** pre-validation flags an exception: "Missing rate configuration for shift_type OT_HOLIDAY, grade G3"
**And** the production run is blocked until the rate is configured

### Business Rules Referenced
- BR-013 (hourly multi-rate), BR-007 (night shift supplement)

### Dependencies
- US-001 (PayGroup must exist before PayProfile can be bound)

---

### US-004: Configure a PayProfile with PIECE_RATE Pay Method

**Epic**: E1 — Pay Master Configuration
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want to configure a PayProfile with pay_method = PIECE_RATE and a piece-rate table, so that garment workers are compensated based on output quantity and quality grade.

#### Acceptance Criteria

**Scenario 1 — Happy path: Configure piece-rate table**

**Given** the Payroll Admin creates PayProfile: code = "GARMENT-PIECE", pay_method = PIECE_RATE
**When** they add piece-rate table entries:
  - product_code = "SHIRT-A", quality_grade = "A", rate = 12,000 VND/unit
  - product_code = "SHIRT-A", quality_grade = "B", rate = 9,600 VND/unit (80% quality multiplier)
  - product_code = "PANTS-A", quality_grade = "A", rate = 18,000 VND/unit
**Then** all rates stored as configurable data in piece_rate_table with effective_date
**And** si_basis_mode is configured as SI_BASIS_BASE_ONLY (hybrid mode per BR-017)

**Scenario 2 — SI basis mode configuration**

**Given** the GARMENT-PIECE PayProfile has a BASE_COMPONENT of 3,000,000 VND and si_basis_mode = SI_BASIS_BASE_ONLY
**When** a worker produces 500 units of SHIRT-A Grade A (piece_pay = 6,000,000 VND) plus base = 3,000,000 VND
**Then** GROSS = 9,000,000 VND (base + piece)
**And** SI_BASIS = 3,000,000 VND (base only)
**And** PIT is computed on 9,000,000 VND (full gross always)

**Scenario 3 — Minimum wage floor**

**Given** a piece-rate worker produces very low output this month: piece_pay = 800,000 VND + base = 3,000,000 VND = 3,800,000 VND gross
**And** the applicable minimum wage region is REGION_3 = 3,860,000 VND (from statutory_rule)
**When** the payroll engine completes gross calculation
**Then** the worker is flagged as EXCEPTION: "Gross 3,800,000 < Regional minimum 3,860,000"
**And** the run is blocked for that worker until the admin acknowledges

### Business Rules Referenced
- BR-012 (piece-rate formula), BR-017 (hybrid SI basis), BR-072 (minimum wage floor)

### Dependencies
- US-001 (PayGroup), statutory_rule VN_MIN_WAGE_REGION_3

---

### US-005: Configure a PayProfile with GRADE_STEP Pay Method

**Epic**: E1 — Pay Master Configuration
**Priority**: P1
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want to configure a PayProfile with pay_method = GRADE_STEP in COEFFICIENT_FORMULA mode, so that public-sector or SOE workers on hệ số lương are correctly compensated.

#### Acceptance Criteria

**Scenario 1 — Happy path: Configure COEFFICIENT_FORMULA mode**

**Given** the Payroll Admin creates PayProfile: code = "SOE-GRADE-STEP", pay_method = GRADE_STEP, grade_step_mode = COEFFICIENT_FORMULA
**When** they configure the pay_scale_table with coefficient entries:
  - grade = "CHUYEN_VIEN", step = "1", coefficient = 2.34
  - grade = "CHUYEN_VIEN", step = "2", coefficient = 2.67
**Then** at calculation time: salary = coefficient × VN_LUONG_CO_SO (from statutory_rule)
**And** when VN_LUONG_CO_SO changes (decree update), only the statutory_rule value needs updating — no formula change

**Scenario 2 — TABLE_LOOKUP mode**

**Given** a private-enterprise PayProfile uses grade_step_mode = TABLE_LOOKUP
**When** a worker is at grade = "SENIOR_DEV", step = "3"
**Then** salary = pay_scale_table[SENIOR_DEV][3].salary_amount_vnd = 18,000,000 VND

**Scenario 3 — Automatic step progression**

**Given** step_progression_rule: grade = "CHUYEN_VIEN", step = "1", months_required = 36, next_step = "2"
**And** worker has been at step "1" for 36 months as of the period start date
**When** the payroll engine runs
**Then** the engine automatically uses step = "2" (coefficient = 2.67) for this period
**And** a notification is sent to the Payroll Admin confirming automatic step advancement

### Business Rules Referenced
- BR-014 (TABLE_LOOKUP), BR-015 (COEFFICIENT_FORMULA), BR-016 (step progression)

### Dependencies
- statutory_rule VN_LUONG_CO_SO must exist; pay_scale_table must be configured

---

### US-006: Define StatutoryRule for PIT Brackets

**Epic**: E1 — Pay Master Configuration
**Priority**: P0
**Persona**: Payroll Admin (or Platform Admin for statutory configuration)
**Story**: As a Platform Admin, I want to define and activate a StatutoryRule record for the Vietnam 7-bracket PIT schedule with an effective date, so that the payroll engine always reads current statutory rates from data — never from hardcoded values.

#### Acceptance Criteria

**Scenario 1 — Happy path: Create PIT bracket statutory rule**

**Given** the Platform Admin navigates to Statutory Rules configuration
**When** they create a new statutory_rule with: code = "VN_PIT_BRACKETS_2020", rule_category = TAX, rule_type = PROGRESSIVE, country_code = "VN", valid_from = 2020-07-01, formula_json containing 7 brackets
**Then** the rule is saved with status = ACTIVE (after approval workflow)
**And** the payroll engine uses this rule for all PIT calculations for periods from 2020-07-01 onward

**Scenario 2 — New decree update**

**Given** the government issues a new PIT bracket schedule effective 2027-01-01
**When** the Platform Admin creates a new version of VN_PIT_BRACKETS_2027 with valid_from = 2027-01-01
**Then** the payroll engine uses old brackets for all periods before 2027-01-01
**And** uses new brackets for all periods from 2027-01-01 onward
**And** no code deployment is required — the effective date drives rule selection

**Scenario 3 — Prevent literal rate in formula**

**Given** an admin attempts to create a pay_element formula containing literal "0.05" as a PIT rate
**When** the formula compiler processes the script
**Then** the compiler raises a warning: "Literal numeric rates found. Recommend referencing statutory_rule('VN_PIT_BRACKETS_2020') instead"
**And** the formula cannot be activated without Finance Lead approval acknowledging the literal rate

### Business Rules Referenced
- BR-041 (PIT progressive brackets), NFR-09 (no hardcoded rates)

### Dependencies
- statutory_rule table must exist in pay_master schema

---

### US-007: Define StatutoryRule for SI Rates and Ceiling

**Epic**: E1 — Pay Master Configuration
**Priority**: P0
**Persona**: Platform Admin
**Story**: As a Platform Admin, I want to define StatutoryRule records for BHXH, BHYT, BHTN rates and the SI ceiling, so that rate changes (e.g., NĐ 73/2024) are applied by updating data records rather than code.

#### Acceptance Criteria

**Scenario 1 — Happy path: Create SI rate rules**

**Given** the Platform Admin creates statutory rules:
  - VN_BHXH_EMP_RATE: value = 0.08, valid_from = 2024-07-01
  - VN_BHXH_EMP_RATE_EMPLOYER: value = 0.175, valid_from = 2024-07-01
  - VN_SI_CEILING_MULTIPLIER: value = 20, valid_from = 2024-07-01
  - VN_LUONG_CO_SO: value = 2340000, valid_from = 2024-07-01
**When** the payroll engine calculates SI for a worker earning 60,000,000 VND gross
**Then** SI_CEILING = 20 × 2,340,000 = 46,800,000 VND
**And** BHXH_EMPLOYEE = 46,800,000 × 0.08 = 3,744,000 VND (ceiling applied, not full gross)
**And** all values traced to statutory_rule references in the calculation log

**Scenario 2 — Mid-year SI ceiling change**

**Given** VN_LUONG_CO_SO changes from 1,800,000 to 2,340,000 effective 2024-07-01
**When** a worker's July 2024 payroll is processed (partial month: 15 days at old rate, 16 days at new rate)
**Then** the engine applies split-period calculation per BR-033
**And** the calculation log shows two sub-calculations with dates

### Business Rules Referenced
- BR-020 to BR-026 (SI rules), BR-033 (split-period)

### Dependencies
- statutory_rule table; VN_LUONG_CO_SO record must exist before SI calculation can run

---

### US-008: Configure PayElement Lifecycle — Formula Approval

**Epic**: E1 — Pay Master Configuration
**Priority**: P1
**Persona**: Payroll Admin (submitter), Finance Lead (approver)
**Story**: As a Payroll Admin, I want to submit a new PayElement formula through an approval workflow, so that only Finance Lead-approved formulas are activated in the calculation engine.

#### Acceptance Criteria

**Scenario 1 — Happy path: Formula activation**

**Given** a PayElement formula is in status = DRAFT
**When** the Payroll Admin submits it for approval (status → PENDING_APPROVAL)
**And** the Finance Lead reviews and approves it (status → APPROVED)
**And** the Payroll Admin activates it (status → ACTIVE)
**Then** the formula is available in the calculation engine for the next payroll run
**And** the approval chain is recorded in the audit log with timestamps and user IDs

**Scenario 2 — Approval workflow managed by Temporal**

**Given** the formula approval workflow is configured in Temporal
**When** a formula is submitted for approval
**Then** PR only needs to track the approval state (DRAFT → PENDING_APPROVAL → APPROVED → ACTIVE → DEPRECATED)
**And** Temporal manages notification, timeout, and escalation logic outside of PR

**Scenario 3 — Formula deprecation**

**Given** a formula is ACTIVE and a new version is being activated
**When** the new version transitions to ACTIVE
**Then** the old version transitions to DEPRECATED
**And** Deprecated formulas remain readable for audit purposes but are not used in new calculations

### Business Rules Referenced
- AQ-04 (formula governance via Temporal), FR-07 (lifecycle states)

### Dependencies
- Temporal workflow engine integration; Finance Lead role must be configured

---

### US-009: Configure GL Account Mapping

**Epic**: E1 — Pay Master Configuration
**Priority**: P1
**Persona**: Payroll Admin (Finance)
**Story**: As a Payroll Admin with Finance access, I want to map each PayElement to a VAS GL account code, so that payroll journal entries are posted correctly to the chart of accounts.

#### Acceptance Criteria

**Scenario 1 — Happy path: Configure GL mapping**

**Given** the Finance Admin navigates to GL Mapping configuration
**When** they map: BASE_SALARY → Dr TK 642, Cr TK 334; BHXH_EMPLOYER → Dr TK 642, Cr TK 3383; PIT → Cr TK 3335
**Then** all mappings are stored in pay_master.gl_mapping table with effective dates
**And** after period lock, GL journal lines are generated using these mappings

**Scenario 2 — Missing GL mapping for element**

**Given** a PayElement "FUEL_ALLOWANCE" exists but has no GL mapping configured
**When** a payroll period is locked and GL journal generation runs
**Then** FUEL_ALLOWANCE generates a warning: "No GL mapping for element FUEL_ALLOWANCE — posted to suspense account TK 138"
**And** the Finance Admin is notified to configure the mapping

### Business Rules Referenced
- FR-08, FR-28; GL account codes: 334, 338, 3383, 3335, 642

### Dependencies
- pay_element must exist; chart of accounts (TK codes) must be configured

---

## E2: Production Payroll Run

### US-010: Run Payroll Dry Run for a PayGroup

**Epic**: E2 — Production Payroll Run
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want to execute a dry run for a PayGroup and period, so that I can validate formula results and catch errors before committing to a production run.

#### Acceptance Criteria

**Scenario 1 — Happy path: Dry run completes successfully**

**Given** PayGroup "VNG-STAFF-HCM" has 50 workers with complete CO, TA, and TR data for period 2026-03
**When** the Payroll Admin initiates a Dry Run for this PayGroup and period
**Then** the engine processes all 50 workers through the full gross-to-net pipeline
**And** results are returned in a preview report (worker name, gross, net, PIT, SI breakdown)
**And** NO records are persisted to the database (dry run = no side effects)
**And** the run completes in under 30 seconds for 50 workers
**And** the dry run can be repeated as many times as needed without any limit

**Scenario 2 — Dry run with validation errors**

**Given** 3 workers in the PayGroup have missing attendance data (TA lock not yet received)
**When** a Dry Run is initiated
**Then** the engine processes 47 workers successfully
**And** returns 3 PRE_VALIDATION_FAILED workers with reason: "AttendanceLocked event not received"
**And** the Payroll Admin can review the partial preview before deciding to re-run

**Scenario 3 — Performance acceptance criterion**

**Given** a PayGroup has 1,000 workers
**When** a Dry Run is initiated
**Then** the run completes in under 30 seconds
**And** this criterion is tested in the pre-launch load test and must pass before production deployment

### Business Rules Referenced
- BR-081 (run state machine), FR-09 (dry run mode)

### Dependencies
- PayGroup configured, CO/TA/TR data available (pre-validation stage)

---

### US-011: Execute Production Run — Full Gross-to-Net for Monthly Salary Worker

**Epic**: E2 — Production Payroll Run
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want to execute a production run for a PayGroup containing monthly-salary workers, so that each worker receives an accurate gross-to-net result that becomes the basis for payment.

#### Acceptance Criteria

**Scenario 1 — Happy path: Full gross-to-net for a tax-resident monthly worker**

**Given** worker Nguyen Van A has: base_salary = 20,000,000 VND, LUNCH_ALLOWANCE = 800,000 VND (TAX_EXEMPT_CAPPED 730,000 cap), 1 dependent, contract = UNLIMITED_TERM, pay_method = MONTHLY_SALARY, 22 work days in period (full month)
**When** the production run executes
**Then** GROSS_INCOME = 20,000,000 + 730,000 (exempt cap) + 70,000 (taxable portion) = 20,070,000 VND taxable gross (correctly split)
**And** SI_CEILING = 46,800,000 VND (from statutory_rule)
**And** BHXH_EMPLOYEE = min(20,000,000, 46,800,000) × 0.08 = 1,600,000 VND (basis = base salary only, allowance excluded)
**And** BHYT_EMPLOYEE = 20,000,000 × 0.015 = 300,000 VND
**And** BHTN_EMPLOYEE = 20,000,000 × 0.01 = 200,000 VND
**And** TAXABLE_INCOME = 20,070,000 − 2,100,000 (SI total) − 11,000,000 (personal) − 4,400,000 (1 dependent) = 2,570,000 VND
**And** PIT = 2,570,000 × 5% = 128,500 VND (bracket 1)
**And** NET_SALARY = rounded to nearest 1,000 VND
**And** a payslip is generated for the worker
**And** all statutory rate references in the calculation log point to statutory_rule codes — no literal values

**Scenario 2 — Pre-validation failure blocks run**

**Given** worker Le Thi B has no AttendanceLocked event received from TA for period 2026-03
**When** the production run's pre-validation stage executes
**Then** the run fails at pre-validation for worker B
**And** the run does NOT proceed to gross calculation for any worker until all pre-validation issues are resolved or the worker is explicitly excluded

**Scenario 3 — Run rollback on stage failure**

**Given** the payroll engine encounters a divide-by-zero error during OT calculation for worker C
**When** the error is detected
**Then** all in-progress results are rolled back (no partial persistence)
**And** the run status is set to FAILED with stage = "GROSS_CALCULATION" and error message logged
**And** the Payroll Admin is notified and can correct the formula and re-initiate

### Business Rules Referenced
- BR-040, BR-041, BR-020–026, BR-060–063, FR-10, FR-11

### Dependencies
- US-002 (PayElements), US-006/007 (StatutoryRules), TA attendance locked

---

### US-012: Execute Production Run for Hourly Worker with Multiple Shift Types

**Epic**: E2 — Production Payroll Run
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want the payroll engine to calculate gross pay for hourly workers using the configured multi-rate table, so that workers are correctly compensated for regular, night, and OT shifts.

#### Acceptance Criteria

**Scenario 1 — Happy path: Hourly worker with REGULAR + NIGHT + OT_WEEKEND shifts**

**Given** worker Tran Thi C has PayProfile = FACTORY-HOURLY, grade = G3, rates: REGULAR=35,000, NIGHT=45,500, OT_WEEKEND=70,000 (35,000×2)
**And** TA data: REGULAR=176h, NIGHT=16h, OT_WEEKEND=8h for period 2026-03
**When** the production run calculates gross
**Then** GROSS = (176 × 35,000) + (16 × 45,500) + (8 × 70,000) = 6,160,000 + 728,000 + 560,000 = 7,448,000 VND
**And** rates are read from pay_profile_rate_config table (not hardcoded)

**Scenario 2 — OT monthly cap enforcement**

**Given** worker D has already worked 24 OT hours this month (reaching OT_MONTHLY_CAP from statutory_rule)
**And** TA submits 4 more OT hours
**Then** the engine flags: "OT_MONTHLY_CAP exceeded by 4 hours"
**And** the 4 excess hours are not included in OT premium calculation
**And** the exception is visible in the Exception Report for admin review

### Business Rules Referenced
- BR-013 (hourly multi-rate), BR-008 (OT cap), BR-004–007 (OT premiums)

### Dependencies
- US-003 (HOURLY PayProfile configured), FR-05b

---

### US-013: Execute Production Run for Piece-Rate Worker with Quality Grades

**Epic**: E2 — Production Payroll Run
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want the payroll engine to calculate gross pay for piece-rate workers by multiplying quantities against the configured rate table, so that output-based workers are correctly compensated.

#### Acceptance Criteria

**Scenario 1 — Happy path: Piece-rate calculation with quality grades**

**Given** worker Nguyen Thi D has PayProfile = GARMENT-PIECE; piece_rate_table: SHIRT-A/Grade-A=12,000, SHIRT-A/Grade-B=9,600
**And** TA data: piece_data = [{product=SHIRT-A, grade=A, qty=400}, {product=SHIRT-A, grade=B, qty=50}]
**When** the production run calculates gross
**Then** PIECE_PAY = (400 × 12,000) + (50 × 9,600) = 4,800,000 + 480,000 = 5,280,000 VND
**And** if BASE_COMPONENT = 3,000,000 then GROSS = 8,280,000 VND
**And** SI_BASIS = 3,000,000 VND (si_basis_mode = SI_BASIS_BASE_ONLY)

**Scenario 2 — Zero output (sick leave month)**

**Given** a piece-rate worker has qty = 0 for all products this month
**When** the engine runs
**Then** PIECE_PAY = 0; GROSS = BASE_COMPONENT only
**And** if GROSS < regional minimum wage, exception is flagged

### Business Rules Referenced
- BR-012 (piece-rate), BR-017 (hybrid SI basis), BR-072 (minimum wage floor)

### Dependencies
- US-004 (PIECE_RATE PayProfile), TA piece data in AttendanceLocked event

---

### US-014: Execute Production Run with OT: Weekday, Weekend, Holiday, Night

**Epic**: E2 — Production Payroll Run
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want the payroll engine to apply the correct OT multiplier for each combination of day type and time of day, so that overtime pay is compliant with Labor Code Article 97.

#### Acceptance Criteria

**Scenario 1 — Happy path: All 4 OT dimensions in one period**

**Given** monthly salary worker Phan Van E: base = 15,000,000 VND, standard hours = 208/month
**And** hourly_rate = 15,000,000 / 208 = 72,115 VND/hour (calculated using STANDARD_WORK_DAYS × STANDARD_HOURS_DAY)
**And** OT data from TA: OT_WEEKDAY=4h, OT_WEEKEND=8h, OT_HOLIDAY=0h, NIGHT_SUPPLEMENT=2h (on weekday nights)
**When** the engine calculates OT premiums
**Then** OT_WEEKDAY_PAY = 4 × 72,115 × 1.50 = 432,690 VND (using statutory_rule VN_OT_WEEKDAY_MULT = 1.50)
**And** OT_WEEKEND_PAY = 8 × 72,115 × 2.00 = 1,153,840 VND (using statutory_rule VN_OT_WEEKEND_MULT = 2.00)
**And** NIGHT_SUPPLEMENT_PAY = 2 × 72,115 × 0.30 = 43,269 VND (stacks with weekday rate)
**And** all multipliers reference statutory_rule codes in the calculation log

**Scenario 2 — Holiday calendar lookup**

**Given** September 2, 2026 is a national holiday (Independence Day) per TA holiday calendar
**And** a worker worked 8 hours on that day
**When** the engine processes OT
**Then** those 8 hours are classified as OT_HOLIDAY with multiplier = 3.00 (from statutory_rule VN_OT_HOLIDAY_MULT)
**And** the holiday classification came from the TA-owned holiday calendar (AQ-07 Decision)

### Business Rules Referenced
- BR-004–008 (OT premiums), BR-009 (hourly rate derivation)

### Dependencies
- statutory_rule VN_OT_*_MULT records; TA holiday calendar; US-007

---

### US-015: Execute Production Run with Worker Joining Mid-Month

**Epic**: E2 — Production Payroll Run
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want the payroll engine to correctly pro-rate a joining worker's salary for the partial period, so that the worker receives payment only for the days they worked.

#### Acceptance Criteria

**Scenario 1 — Happy path: Worker joins on the 15th (WORK_DAYS proration)**

**Given** worker joins on 2026-03-15; pay_profile proration_method = WORK_DAYS
**And** base_salary = 18,000,000 VND; total work days in March = 22; work days from 15th = 13
**When** the payroll engine calculates gross
**Then** PRO_RATED_BASE = 18,000,000 × (13/22) = 10,636,364 VND (rounded per rounding_method)
**And** elements with proration_method = NONE (e.g., EQUIPMENT_ALLOWANCE) are paid in full

**Scenario 2 — Worker joins after cut-off date**

**Given** worker joins on 2026-03-28; cut-off date is 2026-03-25
**When** pre-validation runs for the March period
**Then** this worker is NOT included in the March payroll run
**And** they appear in the April payroll run with proration from March 28 (retroactive) OR from April 1

**Scenario 3 — CALENDAR_DAYS proration**

**Given** an element has proration_method = CALENDAR_DAYS
**And** worker joins on 2026-03-15; calendar days in March = 31; calendar days from 15th = 17
**Then** element amount = full_amount × (17/31)

### Business Rules Referenced
- BR-001, BR-002, BR-003 (proration rules), BR-096 (join after cut-off)

### Dependencies
- CO working_relationship.effective_start_date; PayProfile.proration_method configuration

---

### US-016: Handle Negative Net Salary

**Epic**: E2 — Production Payroll Run
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want the system to flag and halt processing for any worker whose net salary would be negative or zero, so that no incorrect payment is made and I can resolve the issue manually.

#### Acceptance Criteria

**Scenario 1 — Negative net detection**

**Given** worker F has: gross = 5,000,000 VND; total deductions (loan + advance recovery) = 6,000,000 VND
**When** the engine computes net salary
**Then** computed net = -1,000,000 VND
**And** the worker is flagged as EXCEPTION: "NEGATIVE_NET_SALARY"
**And** the engine halts processing for that worker
**And** the exception appears in the Exception Report with worker name, gross, deduction breakdown

**Scenario 2 — Admin resolution required**

**Given** worker F is flagged with NEGATIVE_NET_SALARY exception
**When** the Payroll Admin reviews the Exception Report
**Then** the admin can: (a) adjust the loan repayment amount for this period, or (b) exclude the worker and process separately
**And** the run cannot proceed to approval while worker F's exception is unresolved

**Scenario 3 — Zero net edge case**

**Given** worker G's gross exactly equals total deductions (net = 0)
**When** the engine computes net
**Then** zero net is also flagged as an exception requiring admin acknowledgment

### Business Rules Referenced
- BR-062 (net floor), FR-15

### Dependencies
- Exception Report (US-037), approval workflow (US-025)

---

### US-017: Handle Worker Below Minimum Wage

**Epic**: E2 — Production Payroll Run
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want the system to flag any worker whose gross pay falls below the applicable regional minimum wage, so that the company is warned before potential labor law violations occur.

#### Acceptance Criteria

**Scenario 1 — Minimum wage violation for monthly worker**

**Given** worker H's computed gross = 3,500,000 VND; pay_profile min_wage_rule_id → VN_MIN_WAGE_REGION_3 = 3,860,000 VND
**When** post-processing minimum wage check runs
**Then** the worker is flagged as EXCEPTION: "MIN_WAGE_VIOLATION: gross 3,500,000 < regional minimum 3,860,000"
**And** the minimum wage value 3,860,000 is read from statutory_rule VN_MIN_WAGE_REGION_3 — not a hardcoded value
**And** the exception must be acknowledged (with reason code) by the Payroll Admin before the run can proceed

**Scenario 2 — Minimum wage violation for hourly worker**

**Given** hourly worker I worked 130 hours at 20,000 VND/hour = 2,600,000 VND
**And** hourly minimum for REGION_1 = 4,960,000 / (26×8) = 23,846 VND/hour
**When** the check runs
**Then** effective rate 20,000 < minimum 23,846; exception flagged

**Scenario 3 — Minimum wage from statutory_rule (rate update)**

**Given** a government decree increases REGION_3 minimum to 4,000,000 effective next month
**When** the Platform Admin updates statutory_rule VN_MIN_WAGE_REGION_3 with valid_from = new effective date
**Then** from that period onward, the engine uses 4,000,000 as the floor — no code change required

### Business Rules Referenced
- BR-070, BR-071, BR-072, BR-073, FR-18a

### Dependencies
- statutory_rule VN_MIN_WAGE_REGION_1/2/3/4; Exception Report

---

### US-018: Execute Production Run with SI Ceiling Split-Period

**Epic**: E2 — Production Payroll Run
**Priority**: P1
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want the system to automatically apply split-period SI ceiling calculation when lương cơ sở changes mid-month, so that contributions are correct for both the old and new ceiling in a transition period.

#### Acceptance Criteria

**Scenario 1 — Happy path: Split-period calculation**

**Given** VN_LUONG_CO_SO has two records: value=1,800,000 valid_to=2024-06-30; value=2,340,000 valid_from=2024-07-01
**And** a worker is in July 2024 (mid-month change on July 1)
**When** the engine calculates SI for July 2024 (0 days at old rate, 31 days at new rate in this case)
**Then** SI_CEILING = 2,340,000 × 20 = 46,800,000 VND applied for the full July period
**And** the calculation log shows which statutory_rule period applied

**Scenario 2 — True mid-month change (hypothetical decree effective July 15)**

**Given** new base salary effective July 15: days 1-14 (old ceiling 36,000,000), days 15-31 (new ceiling 46,800,000)
**When** engine processes a worker with SI_BASIS = 50,000,000 VND (above both ceilings)
**Then** BHXH_EMPLOYEE = (14/31 × 36,000,000 × 0.08) + (17/31 × 46,800,000 × 0.08) = 131,613 + 205,161 = 336,774 VND

### Business Rules Referenced
- BR-033 (split-period SI), BR-026 (SI ceiling calculation)

### Dependencies
- US-007 (statutory rules), multiple statutory_rule versions with overlapping valid dates

---

### US-019: Execute Production Run for Non-Tax-Resident Worker

**Epic**: E2 — Production Payroll Run
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want the system to apply the flat 20% PIT rate for non-tax-resident workers, so that expatriate workers' tax withholding is compliant with Vietnam PIT law.

#### Acceptance Criteria

**Scenario 1 — Happy path: Non-resident 20% flat PIT**

**Given** worker expatriate J has tax_residency_status = NON_RESIDENT (from compensation_snapshot)
**And** Vietnam_sourced_income = 50,000,000 VND for the period
**When** PIT calculation runs
**Then** PIT = 50,000,000 × NON_RESIDENT_TAX_RATE (from statutory_rule VN_PIT_NON_RESIDENT_RATE = 0.20)
**And** PIT = 10,000,000 VND
**And** NO personal deduction or dependent deduction is applied
**And** the PIT path selected is logged as "NON_RESIDENT" in the calculation log

**Scenario 2 — Resident path still correct**

**Given** worker K has tax_residency_status = RESIDENT
**When** PIT calculation runs
**Then** the engine takes the progressive 7-bracket path (not the flat 20% path)
**And** the selection logic reads tax_residency_status from compensation_snapshot — not hardcoded

### Business Rules Referenced
- BR-042 (non-resident PIT), BR-040 (taxable income), AQ-OQ2

### Dependencies
- compensation_snapshot.tax_residency_status field; statutory_rule VN_PIT_NON_RESIDENT_RATE

---

### US-020: Calculate and Apply Retroactive Adjustment (3-Month Backdated Salary Change)

**Epic**: E2 — Production Payroll Run
**Priority**: P1
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want the system to calculate retroactive deltas when a salary change is backdated up to 12 prior periods, so that workers receive correct compensation for historical underpayments.

#### Acceptance Criteria

**Scenario 1 — Happy path: 3-month retroactive adjustment**

**Given** worker L's base salary was raised from 15,000,000 to 18,000,000 VND effective January 2026
**And** it is now March 2026 (3 months later) and January and February are LOCKED periods
**When** the Payroll Admin initiates a retroactive calculation
**Then** the engine recalculates January and February using 18,000,000 as base
**And** computes RETRO_DELTA for each period: (recalculated_net − original_net) including SI and PIT adjustments
**And** the total RETRO_DELTA is added to the March 2026 payroll as a RETRO_ADJUSTMENT element
**And** the January and February LOCKED records are NOT modified

**Scenario 2 — Retroactive depth > 3 periods requires confirmation**

**Given** the admin initiates a 6-month retroactive adjustment
**When** the engine detects this exceeds RETRO_CONFIRM_THRESHOLD (default = 3)
**Then** a confirmation dialog appears with impact summary: "6 periods affected, ~12 workers, estimated delta 48,000,000 VND total"
**And** the admin must explicitly confirm before recalculation proceeds

**Scenario 3 — Retroactive depth > 12 periods blocked**

**Given** an admin attempts a 15-month retroactive adjustment
**When** the request is submitted
**Then** the system returns error: "Retroactive depth 15 exceeds maximum 12 periods (RETRO_MAX_PERIODS)"
**And** no calculation is performed

### Business Rules Referenced
- BR-090 (retro depth), BR-091 (confirmation gate), BR-092 (delta calculation)

### Dependencies
- Locked periods must exist; RETRO_ADJUST pay_element must be configured

---

### US-021: Execute PIT Annual Settlement Run

**Epic**: E2 — Production Payroll Run
**Priority**: P1
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want to trigger an annual PIT settlement run, so that over/under-withholding is corrected for each worker at year-end.

#### Acceptance Criteria

**Scenario 1 — Happy path: JANUARY_STANDALONE settlement**

**Given** PayGroup has SETTLEMENT_TIMING = JANUARY_STANDALONE
**And** worker M: YTD_GROSS = 300,000,000 VND, YTD_PIT_WITHHELD = 35,000,000 VND, YTD_SI_EMPLOYEE = 25,200,000 VND, 1 dependent
**When** the Payroll Admin initiates the annual settlement run in January 2027
**Then** ANNUAL_TAXABLE = 300,000,000 − 25,200,000 − 132,000,000 − 52,800,000 = 90,000,000 VND
**And** ANNUAL_PIT_DUE = progressive_tax(90,000,000) = calculated using annual bracket thresholds
**And** SETTLEMENT_DELTA = ANNUAL_PIT_DUE − 35,000,000 (+ or -)
**And** the settlement amount appears as a separate line on the January payslip

**Scenario 2 — Admin-triggered only**

**Given** it is January 10, 2027
**When** no admin has triggered the settlement
**Then** NO automatic settlement is executed
**And** the system sends a reminder notification to Payroll Admin

### Business Rules Referenced
- BR-048 (annual settlement), AQ-09 (SETTLEMENT_TIMING config)

### Dependencies
- YTD balances (BR-086), statutory_rule VN_PIT_BRACKETS (annual scale)

---

### US-022: 13th Month Salary Calculation

**Epic**: E2 — Production Payroll Run
**Priority**: P1
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want the payroll engine to calculate and include 13th-month salary for eligible workers, so that year-end bonus is correctly processed and taxed in the payment period.

#### Acceptance Criteria

**Scenario 1 — Full-year worker**

**Given** worker N joined January 1; base = 20,000,000 VND; months_worked = 12
**When** the December payroll run includes THIRTEENTH_MONTH element
**Then** THIRTEENTH_MONTH = 20,000,000 × (12/12) = 20,000,000 VND
**And** this amount is TAXABLE and included in December gross for PIT calculation

**Scenario 2 — Mid-year joiner (pro-rated)**

**Given** worker O joined July 1; base = 20,000,000 VND; months_worked = 6
**When** December payroll runs with THIRTEENTH_MONTH included
**Then** THIRTEENTH_MONTH = 20,000,000 × (6/12) = 10,000,000 VND

### Business Rules Referenced
- BR-011 (13th month formula), FR-19

### Dependencies
- THIRTEENTH_MONTH pay_element configured in PayProfile; months_worked derived from CO working_relationship start date

---

### US-023: Off-Cycle Termination Pay Run

**Epic**: E2 — Production Payroll Run
**Priority**: P1
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want to initiate a termination off-cycle run for a departing worker, so that their final pay (pro-rated salary, accrued leave, severance) is calculated and disbursed correctly.

#### Acceptance Criteria

**Scenario 1 — Happy path: Resignation termination run**

**Given** worker P resigns effective 2026-03-20; termination_type = RESIGNATION
**And** termination_pay_config for (RESIGNATION × MONTHLY-SALARY-PROFILE) includes: [PRO_RATED_SALARY, LEAVE_PAYOUT]
**When** the Payroll Admin initiates a TERMINATION off-cycle run
**Then** PRO_RATED_SALARY = base × (20/31) calendar days worked
**And** LEAVE_PAYOUT = remaining_leave_days × (base / 26) daily rate
**And** PIT, SI calculated on the termination gross
**And** run follows standard approval workflow before payment file is released

**Scenario 2 — Configurable elements by termination type**

**Given** termination_type = REDUCTION_IN_FORCE includes SEVERANCE element
**When** the run initiates
**Then** SEVERANCE = tenure_years × 0.5 × avg_monthly_salary (where 0.5 = statutory_rule VN_SEVERANCE_COEFFICIENT)

### Business Rules Referenced
- BR-093 (off-cycle types), BR-095 (termination pay config), AQ-10

### Dependencies
- termination_pay_config table; CO working_relationship termination event

---

### US-024: Handle Worker on Unpaid Leave for Full Month

**Epic**: E2 — Production Payroll Run
**Priority**: P2
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want the system to flag and handle workers who were on unpaid leave for the full period, so that zero pay records are accurate and SI contributions are correctly set to zero.

#### Acceptance Criteria

**Scenario 1 — Full-month unpaid leave**

**Given** worker Q has actual_work_days = 0 in TA data (all unpaid leave)
**When** the payroll engine processes this worker
**Then** GROSS = 0 (all elements pro-rated to 0 via WORK_DAYS proration)
**And** SI contributions = 0 (no gross basis)
**And** PIT = 0
**And** an Exception Report entry is generated: "ZERO_GROSS_WORKER — verify unpaid leave is intentional"
**And** admin must acknowledge before run proceeds

### Business Rules Referenced
- BR-002 (work days proration), BR-035, FR-15

### Dependencies
- TA attendance data showing zero work days

---

## E3: Approval and Period Lock

### US-025: Submit Payroll Run for Approval

**Epic**: E3 — Approval and Period Lock
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want to submit a completed production run for approval, so that the multi-level approval process can begin and the run cannot be modified while under review.

#### Acceptance Criteria

**Scenario 1 — Happy path: Successful submission**

**Given** production run for PayGroup "VNG-STAFF-HCM" period 2026-03 is in status PENDING_APPROVAL (engine completed)
**And** all exceptions in the Exception Report have been acknowledged
**When** the Payroll Admin clicks "Submit for Approval"
**Then** run status transitions to SUBMITTED
**And** HR Manager receives a notification: "Payroll run VNG-STAFF-HCM / 2026-03 submitted for approval"
**And** the Payroll Admin can no longer modify worker data for this run
**And** an audit log entry records the submission event with timestamp and user_id

**Scenario 2 — Cannot submit with unresolved exceptions**

**Given** 2 workers have unacknowledged MIN_WAGE_VIOLATION exceptions
**When** the Payroll Admin attempts to submit for approval
**Then** the system blocks submission: "2 unresolved exceptions must be acknowledged before submission"
**And** links to the Exception Report are provided

### Business Rules Referenced
- BR-080 (period state machine), BR-082 (multi-level approval), FR-21

### Dependencies
- US-010/011 (production run complete), US-037 (Exception Report reviewed)

---

### US-026: HR Manager Approves Payroll (Level 2)

**Epic**: E3 — Approval and Period Lock
**Priority**: P0
**Persona**: HR Manager
**Story**: As an HR Manager, I want to review the submitted payroll run and approve or reject it, so that the payroll is validated at the HR level before finance review.

#### Acceptance Criteria

**Scenario 1 — Happy path: HR Manager approves**

**Given** payroll run "VNG-STAFF-HCM / 2026-03" is in status SUBMITTED and awaiting Level 2 approval
**When** the HR Manager reviews the Payroll Register, Variance Report, and Exception Report summary
**And** the HR Manager clicks "Approve (Level 2)"
**Then** run status transitions to LEVEL_2_APPROVED
**And** Finance Manager receives a notification for Level 3 final approval
**And** audit log records: action_type = APPROVAL_LEVEL_2_PASSED, approver = HR_Manager_ID

**Scenario 2 — HR Manager rejects**

**Given** the HR Manager identifies a worker with incorrect base salary in the run
**When** the HR Manager clicks "Reject" and enters reason: "Worker ID 12345 base salary incorrect — verify TR snapshot"
**Then** run status transitions to REJECTED
**And** pay period returns to OPEN state
**And** Payroll Admin receives notification with rejection reason
**And** the rejected run is preserved in audit log; a new run must be initiated

### Business Rules Referenced
- BR-082 (approval levels), BR-083 (rejection behavior)

### Dependencies
- US-025 (run submitted); HR Manager role configured in approval_workflow_config

---

### US-027: Finance Manager Final Approval and Payment File Release

**Epic**: E3 — Approval and Period Lock
**Priority**: P0
**Persona**: Finance Manager
**Story**: As a Finance Manager, I want to provide final approval of the payroll run and trigger bank payment file generation, so that disbursement only occurs after financial sign-off.

#### Acceptance Criteria

**Scenario 1 — Happy path: Final approval and file generation**

**Given** payroll run is in status LEVEL_2_APPROVED awaiting Finance Manager
**When** the Finance Manager reviews the total payroll cost summary and approves (Level 3)
**Then** run status transitions to APPROVED
**And** pay period transitions to LOCKED (SHA-256 hashes generated per FR-23)
**And** bank payment file is generated for each bank in the PayGroup's payment_channel configuration
**And** GL journal entries are generated and posted to the accounting system
**And** audit log records: action_type = FINAL_APPROVAL, PERIOD_LOCKED

**Scenario 2 — Finance Manager can view detailed breakdown**

**Given** the Finance Manager is reviewing for final approval
**When** they navigate to the payroll detail
**Then** they can see: total gross, total employer cost, total PIT withheld, total SI employer, and per-department breakdown
**And** they can drill down to individual worker payslip details

### Business Rules Referenced
- BR-082 (Level 3 approval), BR-080 (LOCKED state), FR-21, FR-22

### Dependencies
- US-026 (Level 2 approved); bank payment file config (US-031); GL mapping (US-009)

---

### US-028: Reject Payroll Run with Comments

**Epic**: E3 — Approval and Period Lock
**Priority**: P0
**Persona**: HR Manager / Finance Manager
**Story**: As an approver at any level, I want to reject a payroll run with written comments, so that the Payroll Admin knows exactly what to fix before resubmission.

#### Acceptance Criteria

**Scenario 1 — Rejection at Level 2 with structured reason**

**Given** HR Manager identifies OT calculation error in the run
**When** they reject with reason_code = "CALCULATION_ERROR" and note = "Worker ID 5678 OT hours incorrect — TA data shows 12h but payslip shows 20h"
**Then** the rejection reason is stored and linked to the run in the audit log
**And** the Payroll Admin's notification contains the full rejection reason
**And** the payroll period returns to OPEN state

**Scenario 2 — Rejection does not delete the run**

**Given** a run is rejected
**When** the Payroll Admin views run history
**Then** the rejected run is visible with status = REJECTED, rejection timestamp, and rejector identity
**And** the run results (workers, amounts) are preserved for reference

### Business Rules Referenced
- BR-082, BR-083

### Dependencies
- US-025/026/027 (approval workflow)

---

### US-029: Lock Payroll Period and Verify SHA-256 Integrity Hash

**Epic**: E3 — Approval and Period Lock
**Priority**: P1
**Persona**: Platform Admin (automated)
**Story**: As a Platform Admin, I want the system to automatically compute and store SHA-256 integrity hashes at period lock and verify them nightly, so that any unauthorized modification to payroll records is detected immediately.

#### Acceptance Criteria

**Scenario 1 — Hash generation at lock**

**Given** Finance Manager approves and triggers period lock for "VNG-STAFF-HCM / 2026-03"
**When** the period transitions to LOCKED
**Then** the system computes SHA-256 hash for each worker's result record (covering: worker_id, period, gross, net, PIT, SI amounts)
**And** the hash is stored in the result record as integrity_hash field
**And** the hash computation is logged in the audit log

**Scenario 2 — Nightly integrity verification**

**Given** the nightly integrity job runs
**When** it recalculates hashes from current record values and compares to stored hashes
**Then** if all hashes match: log "INTEGRITY_VERIFIED: VNG-STAFF-HCM / 2026-03"
**And** if any hash mismatches: immediately alert Platform Admin and Finance Manager via configured notification channel

**Scenario 3 — DBA tamper attempt detected**

**Given** a DBA directly modifies a worker's net_amount in the result table
**When** the nightly integrity job runs
**Then** it detects the mismatch and fires INTEGRITY_VIOLATION alert
**And** the alert specifies which worker record was modified

### Business Rules Referenced
- BR-084 (period lock immutability), FR-23, NFR-08

### Dependencies
- SHA-256 hash implementation in pay_engine; nightly verification job; alerting configuration

---

## E4: Payslip and Bank File

### US-030: Generate and Distribute Worker Payslips (PDF)

**Epic**: E4 — Payslip and Bank File
**Priority**: P0
**Persona**: Payroll Admin (initiating), Worker (receiving)
**Story**: As a Payroll Admin, I want the system to automatically generate payslips for all workers in a PayGroup upon period lock, so that workers can access their payslip in the self-service portal within 1 hour.

#### Acceptance Criteria

**Scenario 1 — Happy path: Payslip generation after lock**

**Given** period "VNG-STAFF-HCM / 2026-03" has transitioned to LOCKED
**When** the payslip generation job triggers automatically
**Then** a PDF payslip is generated for each worker in the PayGroup (in Vietnamese)
**And** payslips are stored and accessible via the self-service portal within 1 hour of lock
**And** each payslip contains: worker name, ID, legal entity, pay period, all earnings itemized, all deductions itemized (BHXH, BHYT, BHTN, PIT, other), net salary, payment date

**Scenario 2 — Payslip template is configurable**

**Given** the PayGroup uses payslip_template = "VNG-STANDARD-VI"
**When** payslips are generated
**Then** the template layout, logo, and section ordering are driven by the payslip_template configuration
**And** changing the template changes all subsequent payslip layouts without code changes

**Scenario 3 — Worker receives notification**

**Given** payslip generation is complete
**When** the system sends notifications
**Then** each worker receives a notification (email or in-app) with a link to view their payslip
**And** workers who have not yet logged in receive an email with download instructions

### Business Rules Referenced
- FR-25, FR-26; BR-084 (post-lock)

### Dependencies
- Period LOCKED (US-027/029); payslip_template configured; worker notification config

---

### US-031: Generate Bank Payment File for VCB

**Epic**: E4 — Payslip and Bank File
**Priority**: P0
**Persona**: Finance Manager
**Story**: As a Finance Manager, I want to download the bank payment file for Vietcombank, so that I can upload it to the VCB corporate banking portal for salary disbursement.

#### Acceptance Criteria

**Scenario 1 — Happy path: VCB file generation**

**Given** period is LOCKED and payment_channel = FILE_MANUAL for bank = VCB
**When** the Finance Manager clicks "Generate Bank File" for VCB
**Then** a CSV file is generated in VCB corporate banking format
**And** the file contains: worker name, account_number, amount_vnd, bank_routing_code, transfer_note
**And** transfer_note format follows the configurable template: "[LE_CODE]-LUONG-2026-03-[WORKER_ID]"
**And** file encoding = UTF-8

**Scenario 2 — File format is configurable data**

**Given** VCB changes their bank file column order in Q3 2026
**When** the admin updates the bank_payment_config template for VCB
**Then** new files use the updated column order without any code deployment

**Scenario 3 — Inactive bank account**

**Given** worker R's bank account is marked inactive in CO
**When** bank file generation runs
**Then** worker R is excluded from the payment file with a warning: "INACTIVE_BANK_ACCOUNT: worker excluded from payment file"
**And** admin must resolve bank account and generate a separate off-cycle payment

### Business Rules Referenced
- AQ-05 Decision D (FILE_MANUAL channel), FR-27; bank_payment_config table

### Dependencies
- US-027 (period LOCKED); CO bank account data in compensation_snapshot

---

### US-032: Generate GL Journal Entries After Period Lock

**Epic**: E4 — Payslip and Bank File
**Priority**: P1
**Persona**: Finance/Accounting
**Story**: As a Finance/Accounting staff member, I want the system to automatically generate GL journal entries after payroll period lock, so that the accounting team can post payroll costs to the correct VAS accounts without manual data entry.

#### Acceptance Criteria

**Scenario 1 — Happy path: GL journal generation**

**Given** period "VNG-STAFF-HCM / 2026-03" is LOCKED
**When** GL journal generation triggers
**Then** journal lines are created:
  - Dr TK 642 / Cr TK 334: net salary amount (by cost center)
  - Dr TK 642 / Cr TK 3383: total employer SI (BHXH+BHYT+BHTN employer)
  - Dr TK 642 / Cr TK 3335: total PIT withheld
**And** each journal line includes: account_code, dr_cr, amount_vnd, cost_center_id, description, period_ref

**Scenario 2 — Journal is read-only after generation**

**Given** journal entries have been generated and exported
**When** an accounting user attempts to modify a journal line in the system
**Then** the system returns an error: "GL journal entries are read-only after generation"
**And** corrections must be processed via accounting system adjustments, not payroll modifications

### Business Rules Referenced
- FR-28, BR-035 (employer contribution separation)

### Dependencies
- US-009 (GL mapping configured); period LOCKED; cost_center_id in compensation_snapshot

---

## E5: Statutory Reports

### US-033: Generate BHXH D02-LT Monthly Contribution List

**Epic**: E5 — Statutory Reports
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want to generate the BHXH monthly contribution list (Form D02-LT) in VssID format, so that the company can submit it to the Social Insurance Agency by the statutory deadline.

#### Acceptance Criteria

**Scenario 1 — Happy path: D02-LT generation**

**Given** period "VNG-STAFF-HCM / 2026-03" is LOCKED with 45 SI-eligible workers
**When** the Payroll Admin generates the D02-LT report for this period
**Then** the file includes all 45 SI-eligible workers (contract_type = UNLIMITED_TERM or FIXED_TERM_12_36)
**And** each row contains: BHXH_number, full_name, contribution_basis, BHXH_employee, BHXH_employer, BHYT_employee, BHYT_employer, BHTN_employee, BHTN_employer
**And** the file format conforms to VssID upload specification
**And** workers with probation/service contract are excluded from the list

**Scenario 2 — Missing BHXH number**

**Given** worker S has no BHXH number registered in CO
**When** D02-LT generation runs
**Then** worker S is included in an error list: "MISSING_BHXH_NUMBER: excluded from D02-LT"
**And** the admin is alerted to register the BHXH number in CO before the filing deadline

### Business Rules Referenced
- BR-028–031 (SI eligibility), BR-020–025 (contribution amounts), FR-29

### Dependencies
- Period LOCKED; CO working_relationship.bhxh_number; SI-eligible worker list from production run

---

### US-034: Generate PIT Quarterly Declaration XML (Form 05/KK-TNCN)

**Epic**: E5 — Statutory Reports
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want to generate the PIT quarterly withholding declaration in XML format, so that the company can submit it to the tax authority via the eTax portal.

#### Acceptance Criteria

**Scenario 1 — Happy path: Quarterly PIT XML generation**

**Given** Q1 2026 (periods Jan, Feb, Mar) are all LOCKED for PayGroup "VNG-STAFF-HCM"
**When** the Payroll Admin generates the 05/KK-TNCN XML for Q1 2026
**Then** the XML conforms to Circular 08/2013/TT-BTC schema
**And** includes: each worker's tax_code, YTD_GROSS_FOR_QUARTER, YTD_PIT_WITHHELD_FOR_QUARTER
**And** XML is downloadable as a file for manual upload to eTax portal (GDT.gov.vn)

**Scenario 2 — Non-resident workers appear separately**

**Given** the PayGroup has 2 non-resident workers with 20% flat PIT
**When** the XML is generated
**Then** non-resident workers appear in the correct section of the 05/KK-TNCN form with tax_type = "NON_RESIDENT"

### Business Rules Referenced
- BR-040, BR-042 (PIT calculation), FR-30

### Dependencies
- All periods in the quarter LOCKED; PIT amounts per worker from YTD balances

---

### US-035: Trigger Annual PIT Settlement Run (JANUARY_STANDALONE Mode)

**Epic**: E5 — Statutory Reports
**Priority**: P1
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want to trigger the annual PIT settlement off-cycle run in January, so that each worker's YTD actual tax liability is reconciled against withheld amounts.

#### Acceptance Criteria

**Scenario 1 — Happy path: Annual settlement triggered**

**Given** PayGroup SETTLEMENT_TIMING = JANUARY_STANDALONE
**And** all 12 periods of 2026 are LOCKED
**When** the Payroll Admin triggers the annual PIT settlement in January 2027
**Then** the engine recalculates each worker's annual tax using YTD_GROSS, YTD_SI, actual dependent count for each month
**And** workers with under-withholding see a positive SETTLEMENT_DELTA deducted from January payslip
**And** workers with over-withholding see a negative SETTLEMENT_DELTA (refund) on January payslip
**And** the settlement generates a Form 05/QTT-TNCN XML for download

**Scenario 2 — Settlement requires admin trigger only**

**Given** January 10, 2027 passes with no admin action
**When** the system checks settlement status
**Then** no automatic settlement is performed
**And** a reminder notification is sent to Payroll Admin daily until the settlement is triggered or skipped

### Business Rules Referenced
- BR-048 (annual settlement), AQ-09 (SETTLEMENT_TIMING), FR-31

### Dependencies
- YTD balances for all 12 periods; US-021 approach

---

## E6: Operational Reports

### US-036: View Variance Report with Anomaly Highlights

**Epic**: E6 — Operational Reports
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want to view a variance report comparing current period element values against the prior period, so that I can identify anomalies before approving the run.

#### Acceptance Criteria

**Scenario 1 — Happy path: Variance report with highlighted anomalies**

**Given** the production run for "VNG-STAFF-HCM / 2026-03" has completed
**When** the Payroll Admin opens the Variance Report
**Then** the report shows each worker and each element: current period value, prior period value, absolute difference, percentage change
**And** variances exceeding 20% (configurable VARIANCE_ALERT_THRESHOLD) are highlighted in red
**And** the admin can filter by element, department, or variance size

**Scenario 2 — Configurable variance threshold**

**Given** VARIANCE_ALERT_THRESHOLD is set to 15% for a specific PayGroup
**When** a worker's base salary changes by 18% due to promotion
**Then** the row is highlighted
**And** if VARIANCE_ALERT_THRESHOLD = 25%, the same 18% change is NOT highlighted

### Business Rules Referenced
- FR-34; VARIANCE_ALERT_THRESHOLD configurable per PayGroup

### Dependencies
- Prior period must be LOCKED; current period production run completed

---

### US-037: View Exception Report Before Approving Run

**Epic**: E6 — Operational Reports
**Priority**: P0
**Persona**: Payroll Admin
**Story**: As a Payroll Admin, I want to view and acknowledge all exceptions flagged during a production run before I can submit for approval, so that no erroneous payments pass through to disbursement.

#### Acceptance Criteria

**Scenario 1 — Happy path: Exception report review and acknowledgment**

**Given** production run has 3 exceptions: 1 NEGATIVE_NET, 1 MIN_WAGE_VIOLATION, 1 ZERO_BHXH_SI_ELIGIBLE_WORKER
**When** the Payroll Admin opens the Exception Report
**Then** all 3 exceptions are listed with: worker name, exception type, details, recommended action
**And** each exception has an "Acknowledge" button with a required reason code
**And** until all 3 are acknowledged, the "Submit for Approval" button is disabled

**Scenario 2 — Exception types covered**

**Given** post-processing runs successfully
**When** exceptions are generated
**Then** the system flags: (a) NEGATIVE_NET workers, (b) MIN_WAGE_VIOLATION workers, (c) SI-eligible workers with BHXH = 0, (d) workers with PIT = 0 but gross > 11M (suspicious), (e) OT_CAP_EXCEEDED workers

### Business Rules Referenced
- BR-062 (negative net), BR-073 (minimum wage exception), FR-35

### Dependencies
- Production run completed; exception framework in post-processing stage

---

### US-038: View Payroll Register

**Epic**: E6 — Operational Reports
**Priority**: P0
**Persona**: Payroll Admin / Finance Manager
**Story**: As a Finance Manager, I want to view the Payroll Register for a completed run, so that I can see all workers' element values before providing final approval.

#### Acceptance Criteria

**Scenario 1 — Happy path: Payroll Register view**

**Given** production run for "VNG-STAFF-HCM / 2026-03" is in PENDING_APPROVAL status
**When** the Finance Manager opens the Payroll Register
**Then** all workers are listed, sorted by department and worker ID
**And** columns include: worker name, ID, department, cost center, all element amounts, net salary
**And** the register can be exported as Excel or CSV

### Business Rules Referenced
- FR-33

### Dependencies
- Production run completed

---

### US-039: View Payroll Cost by Department/Cost Center

**Epic**: E6 — Operational Reports
**Priority**: P1
**Persona**: Finance Manager
**Story**: As a Finance Manager, I want to view total employer payroll cost by department and cost center, so that I can compare actual payroll spend against budget.

#### Acceptance Criteria

**Scenario 1 — Happy path: Department cost report**

**Given** period is LOCKED
**When** the Finance Manager opens the Cost by Department report
**Then** each department/cost_center shows: total gross, employer BHXH/BHYT/BHTN, total employer cost (gross + employer SI)
**And** the report can be filtered by department, legal entity, and period range

### Business Rules Referenced
- FR-36, BR-035 (employer contribution separation)

### Dependencies
- cost_center_id in compensation_snapshot; period LOCKED

---

## E7: Worker Self-Service

### US-040: Worker Views and Downloads Payslip

**Epic**: E7 — Worker Self-Service
**Priority**: P1
**Persona**: Worker
**Story**: As a worker, I want to view and download my payslip for any past period in which I was active, so that I can verify my pay without contacting HR.

#### Acceptance Criteria

**Scenario 1 — Happy path: Worker views payslip**

**Given** worker M is logged into the xTalent self-service portal
**When** they navigate to "My Payslips" and select period 2026-03
**Then** they see their payslip with all earnings and deductions itemized
**And** a "Download PDF" button is available
**And** the payslip is in Vietnamese (bilingual V1+ option)

**Scenario 2 — Worker cannot see other workers' payslips**

**Given** worker M is logged in
**When** they attempt to access worker N's payslip via direct URL
**Then** the system returns HTTP 403

**Scenario 3 — Payslip not available before period lock**

**Given** period 2026-04 is still in PROCESSING status
**When** worker M tries to view their April payslip
**Then** the system shows: "Your April 2026 payslip will be available after payroll processing is complete"

### Business Rules Referenced
- FR-37, FR-38; BR-100 (data isolation)

### Dependencies
- Period LOCKED; payslip generated (US-030); worker self-service portal active

---

### US-041: Worker Downloads PIT Withholding Certificate

**Epic**: E7 — Worker Self-Service
**Priority**: P1
**Persona**: Worker
**Story**: As a worker, I want to download my PIT withholding certificate for any year, so that I can use it for my personal tax filing with the tax authority.

#### Acceptance Criteria

**Scenario 1 — Happy path: PIT certificate download**

**Given** worker L had PIT withheld in 2025
**When** they navigate to "Tax Documents" → "2025 PIT Certificate"
**Then** a Form 03/TNCN PDF is generated showing: worker name, tax code, legal entity name, YTD_GROSS_2025, YTD_PIT_WITHHELD_2025
**And** the PDF is downloadable

**Scenario 2 — Certificate not available if no PIT withheld**

**Given** worker J had PIT = 0 for all periods in 2024 (income below personal deduction threshold)
**When** they try to download the 2024 PIT certificate
**Then** the system shows: "No PIT was withheld for you in 2024. A certificate is not required."

### Business Rules Referenced
- FR-32, FR-39

### Dependencies
- YTD balances (BR-086); period LOCKED for all relevant periods; Form 03/TNCN template

---

### US-042: Worker Views YTD Summary

**Epic**: E7 — Worker Self-Service
**Priority**: P1
**Persona**: Worker
**Story**: As a worker, I want to view my year-to-date summary showing gross earnings, SI contributions, PIT withheld, and net paid, so that I can track my cumulative compensation throughout the year.

#### Acceptance Criteria

**Scenario 1 — Happy path: YTD summary view**

**Given** worker N has 3 locked periods in 2026
**When** they navigate to "My YTD Summary"
**Then** they see: YTD_GROSS, YTD_BHXH_EMP, YTD_BHYT_EMP, YTD_BHTN_EMP, YTD_PIT, YTD_NET
**And** a month-by-month breakdown is available
**And** YTD values reset to 0 from January onward

### Business Rules Referenced
- FR-40, BR-086 (YTD balances)

### Dependencies
- YTD balance_def records; at least one LOCKED period in current year

---

### US-043: Worker Requests Manual Payslip (Fallback)

**Epic**: E7 — Worker Self-Service
**Priority**: P2
**Persona**: Worker
**Story**: As a worker who cannot access the self-service portal, I want to request a printed payslip from the Payroll Admin, so that I can receive my pay information through an alternative channel.

#### Acceptance Criteria

**Scenario 1 — Admin downloads payslip for manual delivery**

**Given** worker P cannot access the self-service portal
**When** the Payroll Admin downloads the payslip PDF for worker P and period 2026-03
**Then** the same payslip PDF that would appear in self-service is downloaded
**And** the admin access to payslip is recorded in the audit log

### Business Rules Referenced
- FR-25, FR-26

### Dependencies
- US-030 (payslip generation complete)

---

## E8: Audit and Security

### US-044: Audit Log Entry for Every State Change

**Epic**: E8 — Audit and Security
**Priority**: P0
**Persona**: Platform Admin (consumer of audit log)
**Story**: As a Platform Admin, I want every significant action in the payroll system to generate an immutable audit log entry, so that any question about who did what and when can be answered from the audit trail.

#### Acceptance Criteria

**Scenario 1 — Happy path: Audit log for run initiation**

**Given** Payroll Admin "admin@vng.vn" initiates a production run for "VNG-STAFF-HCM / 2026-03"
**When** the run is created
**Then** audit log entry is created: timestamp, user_id = "admin@vng.vn", action_type = "PAYROLL_RUN_INITIATED", entity_type = "PAY_RUN", entity_id = run.id, payload = {PayGroup, period, mode}

**Scenario 2 — Audit log for formula activation**

**Given** Finance Lead activates a new BHXH formula version
**When** the formula transitions to ACTIVE
**Then** audit log records: action_type = "FORMULA_ACTIVATED", before_value = {old_formula_code, version}, after_value = {new_formula_code, version}

**Scenario 3 — Audit log for statutory rule change**

**Given** Platform Admin updates VN_LUONG_CO_SO from 2,340,000 to a new value
**When** the update is saved
**Then** audit log records: action_type = "STATUTORY_RULE_UPDATED", before_value, after_value, effective_date
**And** the audit log entry is immutable — cannot be deleted or modified by any user including Platform Admin

### Business Rules Referenced
- FR-41; BR-084 (immutability)

### Dependencies
- Audit log table in pay_audit schema; all state transitions emit audit events

---

### US-045: Cross-Entity Data Access Attempt Returns 403

**Epic**: E8 — Audit and Security
**Priority**: P0
**Persona**: Payroll Admin (attempting cross-entity access)
**Story**: As a system security layer, I want any attempt by a user to access payroll data for a legal entity they are not authorized for to return HTTP 403, so that worker salary data is never leaked across entity boundaries.

#### Acceptance Criteria

**Scenario 1 — Cross-entity payroll run access blocked**

**Given** Payroll Admin user U is authorized for Legal Entity A only
**When** user U calls API: GET /payroll/runs?pay_group_id={PayGroup_from_Legal_Entity_B}
**Then** the API returns HTTP 403 (not HTTP 404, not HTTP 200)
**And** no payroll data from Legal Entity B is returned
**And** the access attempt is logged in the audit log as SECURITY_VIOLATION

**Scenario 2 — Row-level security enforced at database level**

**Given** row-level security (RLS) is configured on all payroll tables
**When** any query executes for a session with legal_entity_scope = [A]
**Then** no rows from Legal Entity B are returned — regardless of the API or query path used
**And** this is verified by integration tests covering 100% of payroll data endpoints

### Business Rules Referenced
- BR-100 (data isolation), FR-42

### Dependencies
- Row-level security implementation; legal_entity_id on all tables; role-based access configured

---

### US-046: Data Retention Enforcement

**Epic**: E8 — Audit and Security
**Priority**: P0
**Persona**: Platform Admin
**Story**: As a Platform Admin, I want the system to retain payroll data for a minimum of 7 years (accounting records) and BHXH records for 10 years, and prevent unauthorized deletion, so that the company meets Vietnamese legal obligations.

#### Acceptance Criteria

**Scenario 1 — Payroll result retention enforced**

**Given** a payroll period is more than 7 years old
**When** a Platform Admin attempts to delete payroll result records for that period
**Then** the system allows archival (move to cold storage) but does NOT allow deletion
**And** the records remain accessible via a read-only archive query

**Scenario 2 — BHXH records 10-year retention**

**Given** BHXH D02-LT records are generated for period 2016-03
**When** the system checks retention policy in 2026-03 (10 years)
**Then** the BHXH records are still retained and accessible
**And** automated archival runs keep records compliant with retention schedules

### Business Rules Referenced
- FR-43; Accounting Law 88/2015/QH13 (7 years); BHXH retention (10 years)

### Dependencies
- Archive policy configuration; automated archival job

---

### US-047: Concurrency Lock Prevents Duplicate Runs

**Epic**: E8 — Audit and Security
**Priority**: P0
**Persona**: Payroll Admin (triggering second run)
**Story**: As a Payroll Admin, I want the system to prevent a second production run from being initiated for the same PayGroup and period while one is already running, so that concurrent runs cannot produce duplicate or conflicting payroll results.

#### Acceptance Criteria

**Scenario 1 — Concurrent run blocked**

**Given** production run "VNG-STAFF-HCM / 2026-03 / RUN-001" is in status RUNNING
**When** a second Payroll Admin attempts to initiate another run for the same PayGroup and period
**Then** the system returns error: "Cannot initiate run: PayGroup VNG-STAFF-HCM / period 2026-03 already has an active run (RUN-001)"
**And** no second run is created

**Scenario 2 — Run allowed after first completes**

**Given** RUN-001 completes with status FAILED
**When** the Payroll Admin initiates a new run (after correcting the error)
**Then** the new run is created successfully
**And** the failed RUN-001 remains in audit history

### Business Rules Referenced
- BR-085 (concurrent run prevention), NFR-04

### Dependencies
- Concurrency lock at pay_group + period_id level

---

### US-048: Worker Self-Service — Download PIT Certificate for Past Years

**Epic**: E8 — Audit and Security
**Priority**: P1
**Persona**: Worker
**Story**: As a worker, I want to access and download my PIT withholding certificate for any year in which tax was withheld, so that I can fulfill my personal tax filing obligations independently.

#### Acceptance Criteria

**Scenario 1 — Certificate accessible for past years within retention period**

**Given** worker Q had PIT withheld in years 2022, 2023, 2024, 2025
**When** they navigate to "My Tax Documents"
**Then** certificates for all 4 years are available for download
**And** certificates reflect the YTD data from the respective year's LOCKED periods
**And** records are accessible up to 7 years back (retention policy per FR-43)

### Business Rules Referenced
- FR-39, FR-43; retention policy (7 years)

### Dependencies
- US-041 (certificate generation); YTD balances for past years in balance_def table
