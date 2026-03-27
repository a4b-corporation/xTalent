# Accrual Plan Setup — ABS-M-003

**Classification:** Masterdata (M)
**Priority:** P0
**Primary Actor:** HR Administrator
**API:** `GET /accrual-plans`, `POST /accrual-plans`, `PUT /accrual-plans/{id}`, `PATCH /accrual-plans/{id}/activate`
**User Story:** US-ABS-009
**BRD Reference:** FR-ABS-009
**Hypothesis:** H2

---

## Purpose

An Accrual Plan defines how leave balance is earned over time — the method (monthly, annual, milestone), frequency, rate, and annual cap. Accrual Plans are referenced by Leave Policy lines; one Accrual Plan can be reused across multiple policies. Correct accrual plan configuration is critical: errors here affect every employee's monthly balance calculation and the downstream payroll export. This is the most complex Masterdata configuration in the Absence Management bounded context.

---

## Data Model (Key Fields)

| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| name | string | Yes | 2–100 chars | Display name (e.g., "Standard Annual — Monthly Accrual") |
| accrual_method | enum | Yes | MONTHLY_FIXED / MONTHLY_WORKED_DAYS / ANNUAL_GRANT / MILESTONE | How balance accrues |
| accrual_frequency | enum | Yes | MONTHLY / QUARTERLY / ANNUALLY | When accrual batch runs for this plan |
| accrual_rate | decimal | Yes | > 0; max 5.00 | Days accrued per frequency cycle |
| annual_cap | decimal | No | ≥ accrual_rate; null = no cap | Maximum balance that can be accrued in a year |
| accrual_start_offset_days | integer | Yes | ≥ 0; default 0 | Days from hire date before first accrual occurs |
| prorate_first_period | boolean | Yes | Default true | Whether first partial period is prorated |
| cap_at_balance_max | decimal | No | null = no ceiling | Maximum total balance (carry-over + accrued); excess is forfeited |
| rounding_rule | enum | Yes | ROUND_UP / ROUND_DOWN / ROUND_HALF / NO_ROUNDING | How fractional days are handled |
| status | enum | System-set | ACTIVE / INACTIVE / DRAFT | — |

**Accrual method descriptions (shown as help text in form):**
- MONTHLY_FIXED: Fixed number of days accrued each calendar month regardless of days worked.
- MONTHLY_WORKED_DAYS: Days accrued proportional to actual days worked in the month.
- ANNUAL_GRANT: Full entitlement granted at the start of the policy year (or hire anniversary).
- MILESTONE: Days accrued when employee reaches service milestones (configurable milestone table).

---

## Screen: List View

**Route:** `/config/accrual-plans`

**Layout:**
- Page header: "Accrual Plans" + "New Accrual Plan" primary button
- Table columns: Name | Method | Frequency | Rate (days/cycle) | Annual Cap | Used In (policies count) | Status | Actions

**Actions per row:** Edit | View linked policies | Activate/Deactivate | Duplicate

**Note in UI:** "Accrual plans linked to active policies cannot be edited. Duplicate the plan to make changes."

**Empty state:** "No accrual plans defined. Accrual plans are required by leave policies with Accrual-based entitlement."

---

## Screen: Create / Edit Form

**Route:** `/config/accrual-plans/new` and `/config/accrual-plans/{id}/edit`

### Section 1: Plan Identity
- Plan Name (required)
- Accrual Method (radio group with descriptions; required)
- Accrual Frequency (dropdown: Monthly / Quarterly / Annually; required)

### Section 2: Accrual Rate
- Accrual Rate — days per cycle (decimal input; 0.01–5.00; required)
  - Context label changes based on frequency: "days per month" / "days per quarter" / "days per year"
  - Calculation preview: "At this rate, an employee will accrue approximately [X] days per year."
- Annual Cap — days (decimal input; optional)
  - Show only if frequency != ANNUALLY
  - Help text: "Maximum days that can be accrued in a calendar year. Excess accruals are not added."

### Section 3: Eligibility Timing
- Days from hire before first accrual (number; default 0)
  - Note: "Leave Policy probation period takes precedence; employee cannot submit requests during probation even if balance has accrued."
- Prorate first partial period (toggle; default on)
  - Help text: "If on, an employee hired mid-month accrues a prorated amount for their first partial month."

### Section 4: Balance Cap (optional)
- Maximum total balance — days (decimal input; optional)
  - Help text: "Includes carried-over balance. If an employee's total balance exceeds this cap, new accruals are suppressed until balance drops below cap."

### Section 5: Rounding
- Rounding rule (radio: Round Up / Round Down / Round to Nearest Half / No Rounding; default Round Down)
  - Preview: "Example: 0.83 days accrued → displays as [computed value] with selected rule"

### Section 6: Milestone Table (shown only for MILESTONE method)
- Table: Service Milestone (years) | Days Accrued at Milestone
- "+ Add Milestone" button
- At least 1 milestone required for MILESTONE method

**Validation:**
- Annual cap must be ≥ accrual rate per cycle × frequency factor
- For MONTHLY method: warn if annual rate < 14 (Vietnam floor) when linked to Annual Leave type

**Form actions:** Save as Draft | Save and Activate | Cancel

**Edit restrictions:** If accrual plan is linked to an ACTIVE policy, form is read-only with message: "This plan is in use by [N] active policies. Duplicate to create a modified version."

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-ABS-020 | Accrual rate × frequency must meet annual leave floor for VN Annual Leave |
| BR-ABS-021 | Accrual plans in use by active policies are immutable; duplication required to modify |
| BR-ABS-022 | Accrual batch runs use the plan configuration at the time of the run; plan changes are prospective |
| BR-ABS-023 | MILESTONE method requires at least one milestone entry before activation |
| BR-ABS-024 | If cap_at_balance_max is set, it cannot be less than annual_cap |
