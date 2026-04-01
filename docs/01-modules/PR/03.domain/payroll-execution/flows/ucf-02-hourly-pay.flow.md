# UCF-02: Hourly Worker Pay Calculation

**Bounded Context**: Payroll Execution (BC-03)
**Timeline**: T2 — Monthly payroll cycle variant (executed within UCF-01 Step 6B)
**Actors**: Payroll Admin, System (Drools engine)
**Trigger**: PayrollRun reaches gross calculation phase (Step 6 of UCF-01) for workers whose PayProfile.pay_method = HOURLY

---

## Preconditions

- Worker's PayProfile.pay_method = HOURLY
- HourlyRateConfig is populated on the PayProfile with valid entries for the worker's grade_code
- `AttendanceLocked` event received from TA containing: regular_hours, night_hours, ot_weekday_hours, ot_weekend_hours, ot_holiday_hours, per working_relationship_id
- CompensationSnapshot exists for the worker (created at cut-off)
- StatutoryRule: OT multipliers, minimum wage (by region), SI rates are ACTIVE for the cut-off date
- Worker's region_code is set in CompensationSnapshot or PayGroup

---

## Main Flow

| Step | Actor | Action | System Response |
|------|-------|--------|-----------------|
| 1 | System | Retrieve HourlyRateConfig | System loads PayProfile.HourlyRateConfig for the worker. Looks up entry: shift_type × grade_code → rate_per_hour_vnd using the effective_date ≤ cut_off_date. Fails if no entry found for the worker's grade_code. |
| 2 | System | Retrieve attendance data | System reads from CompensationSnapshot the TA data received via `AttendanceLocked` event: regular_hours, night_hours, ot_weekday_hours, ot_weekend_hours, ot_holiday_hours, shift breakdown. |
| 3 | System | Calculate regular hour pay | regular_pay = HourlyRateConfig[REGULAR][grade_code] × regular_hours |
| 4 | System | Calculate night shift pay | night_supplement_rate = OT multiplier from StatutoryRule VN_NIGHT_SHIFT_SUPPLEMENT (30% of hourly rate). night_pay = HourlyRateConfig[NIGHT][grade_code] × night_hours. Night hours are on top of regular rate + supplement (BR-008). |
| 5 | System | Calculate OT weekday premium | ot_weekday_base_rate = HourlyRateConfig[REGULAR][grade_code]. ot_weekday_premium = ot_weekday_base_rate × (VN_OT_WEEKDAY_MULT − 1.0) × ot_weekday_hours. Total OT weekday = ot_weekday_base_rate × VN_OT_WEEKDAY_MULT × ot_weekday_hours. VN_OT_WEEKDAY_MULT = 1.5 (150%). |
| 6 | System | Calculate OT weekend premium | ot_weekend_rate = HourlyRateConfig[REGULAR][grade_code] × VN_OT_WEEKEND_MULT. VN_OT_WEEKEND_MULT = 2.0 (200%). Total OT weekend pay = ot_weekend_rate × ot_weekend_hours. |
| 7 | System | Calculate OT holiday premium | ot_holiday_rate = HourlyRateConfig[REGULAR][grade_code] × VN_OT_HOLIDAY_MULT. VN_OT_HOLIDAY_MULT = 3.0 (300%). Total OT holiday pay = ot_holiday_rate × ot_holiday_hours. |
| 8 | System | Sum gross hourly pay | hourly_gross = regular_pay + night_pay + ot_weekday_total + ot_weekend_total + ot_holiday_total. Emits `HourlyPayCalculated`. |
| 9 | System | Apply OT premium calculation record | System records OT breakdown as separate PayElement line items in CalcLog for audit transparency. Each shift type is a distinct entry: REGULAR_HOURS_PAY, NIGHT_SHIFT_PAY, OT_WEEKDAY_PAY, OT_WEEKEND_PAY, OT_HOLIDAY_PAY. Emits `OvertimePremiumApplied` if any OT hours > 0. |
| 10 | System | Monthly OT cap check | System checks: total OT hours ≤ PayGroup.ot_monthly_cap (configurable, typically 40 hours/month per Labor Code). If exceeded, flags OT_CAP_EXCEEDED exception (informational — does not halt run). |
| 11 | System | Minimum wage floor check | System retrieves RegionalMinimumWage for the worker's region_code from StatutoryRule. Checks: hourly_gross ≥ regional_minimum_wage. If below: flags MIN_WAGE_VIOLATION exception. Emits `MinimumWageFloorChecked`. |
| 12 | System | Hand off to SI and PIT calculation | hourly_gross feeds into UCF-01 Step 7 (SI calculation) and Step 8 (PIT calculation) without modification. SI basis = sum of hourly pay elements where si_basis_inclusion = INCLUDED (REGULAR_HOURS_PAY typically included; OT elements configurable). |

---

### OT Rate Calculation Example

Worker: Grade = G3, Region 1, Monthly cap = 40 OT hours

HourlyRateConfig for G3:
- REGULAR: 80,000 VND/hr
- NIGHT: 96,000 VND/hr (80,000 × 1.2 base + supplement)

Attendance data (October):
- regular_hours: 176 (standard full month)
- night_hours: 20
- ot_weekday_hours: 10
- ot_weekend_hours: 5
- ot_holiday_hours: 2

Calculations:
- regular_pay = 80,000 × 176 = 14,080,000 VND
- night_pay = 96,000 × 20 = 1,920,000 VND
- ot_weekday = 80,000 × 1.5 × 10 = 1,200,000 VND
- ot_weekend = 80,000 × 2.0 × 5 = 800,000 VND
- ot_holiday = 80,000 × 3.0 × 2 = 480,000 VND
- hourly_gross = 18,480,000 VND
- Total OT hours = 17 (below 40-hour cap — no flag)
- Region 1 minimum wage (2024) = 4,960,000 VND/month → hourly_gross > floor — pass

---

## Alternate Flows

### AF-1: Combined Night + OT
- Worker logs hours that are simultaneously night hours AND OT (e.g., OT worked on a weekday night shift)
- System applies both the OT premium multiplier AND the night supplement
- Combined rate = regular_rate × OT_multiplier + night_supplement
- TA data must classify hours by shift_type accurately before `AttendanceLocked`

### AF-2: Partial Period (Mid-Month Join or Termination)
- If worker joined or left mid-period, CompensationSnapshot.actual_work_days reflects partial attendance
- For HOURLY workers, proration is implicit in the hours data (system does not apply additional proration factor)
- Regular hours are the actual hours worked (not pro-rated from standard hours)
- CalcLog shows no proration line for HOURLY pay method

### AF-3: Grade Promotion Mid-Period
- If worker's grade_code changed mid-period (reflected in CompensationSnapshot)
- System applies rate-split: hours before grade change date × old rate, hours after × new rate
- Requires TA to provide hours breakdown by effective-date segment
- If TA does not provide the split: system applies the grade_code in CompensationSnapshot (cut-off snapshot value) to all hours — no split

---

## Exception Flows

### EF-1: Missing HourlyRateConfig Entry
- At step 1: no HourlyRateConfig entry found for worker's grade_code at cut-off date
- System flags MISSING_RATE_CONFIG blocking exception
- Pre-validation (UCF-01 Step 4) should catch this before run reaches Step 6
- Resolution: Payroll Admin must update PayProfile HourlyRateConfig and re-run pre-validation

### EF-2: Negative OT Hours in TA Data
- At step 2: TA provides negative OT hours (data error)
- System rejects the run with PRE_VALIDATION_FAILED, listing the affected working_relationship_id
- TA team must correct and re-lock attendance

### EF-3: OT Cap Exceeded
- At step 10: total OT hours > PayGroup.ot_monthly_cap
- System flags OT_CAP_EXCEEDED exception (type: WARNING, not BLOCKING)
- Payroll Admin acknowledges with reason (e.g., approved OT extension)
- Pay is computed on actual hours regardless; the cap is an HR compliance flag, not a calculation limiter

---

## Domain Events Emitted

| Event | Emitted At Step | Payload Key Fields |
|-------|-----------------|-------------------|
| HourlyPayCalculated | 8 | result_id, working_relationship_id, regular_pay, night_pay, ot_weekday_pay, ot_weekend_pay, ot_holiday_pay, hourly_gross |
| OvertimePremiumApplied | 9 | result_id, working_relationship_id, ot_weekday_hours, ot_weekend_hours, ot_holiday_hours, ot_premium_total |
| MinimumWageFloorChecked | 11 | result_id, working_relationship_id, hourly_gross, minimum_wage, region_code, floor_met (bool) |

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-005 | HOURLY pay method: compute gross as sum of (hours_per_shift_type × rate_per_hour_per_grade) |
| BR-008 | OT premium configuration: weekday 150%, weekend 200%, holiday 300%; night supplement 30% |
| BR-009 | Hourly rate derivation divisors (configurable per PayGroup — used when hourly rate is derived from monthly salary) |
| BR-013 | HourlyRateConfig: multi-rate table lookup by shift_type × grade_code |
| BR-070 | Regional minimum wage floor enforcement (Region 1: 4,960,000 VND/month as of Decree 38/2022) |
| BR-071 | Region 2 minimum wage |
| BR-072 | Region 3 minimum wage |
| BR-073 | Minimum wage exception: if total hours < standard hours, floor is pro-rated proportionally |

---

## Hot Spots / Risks

- HS-1: TA data completeness — Hourly pay is entirely dependent on accurate hours-per-shift-type from TA. Missing or malformed attendance data is the primary failure mode. Pre-validation must explicitly validate hourly workers' attendance completeness.
- HS-5: Performance — Each hourly worker requires HourlyRateConfig lookup + 5 shift-type calculations. At 1,000 workers, 5,000+ lookups occur. HourlyRateConfig must be pre-loaded into the Drools working memory (not queried per-step).
