# UCF-05: PIT Annual Settlement

**Bounded Context**: Payroll Execution (BC-03) — with output to BC-05 (Statutory Reporting)
**Timeline**: T4 — Annual settlement, executed January–February following the tax year (or at employment termination)
**Actors**: Payroll Admin, Worker (authorizes PIT certificate), System
**Trigger**: Payroll Admin issues `TriggerAnnualPitSettlement` command for a legal entity and tax year, OR worker terminates employment (triggering a final-pay off-cycle settlement per UCF-07)

---

## Preconditions

- Tax year is complete: all 12 monthly PayPeriods for the year are in LOCKED state
- All workers in scope have active PayrollResult records for the tax year (no unprocessed corrections)
- Worker's tax_residency_status is confirmed for the full year (resident or non-resident)
- For resident workers: dependent declarations have been submitted by workers (or default to 0 if not declared)
- Platform Admin has confirmed: PIT StatutoryRules valid for the settlement tax year are ACTIVE
- No in-progress retroactive adjustment for any worker in the settlement batch (HS-7)

---

## Main Flow

| Step | Actor | Action | System Response |
|------|-------|--------|-----------------|
| 1 | Payroll Admin | Issues `TriggerAnnualPitSettlement` for tax year YYYY and pay_group_id | System creates a PayrollRun with run_type = ANNUAL_SETTLEMENT, run_mode = PRODUCTION. State: QUEUED → RUNNING. Emits `AnnualPitSettlementInitiated`. |
| 2 | System | YTD income consolidation per worker | For each worker, system aggregates across all 12 locked PayPeriods: YTD_gross = sum of all monthly gross amounts; YTD_si_employee = sum of all monthly SI employee deductions; YTD_pit_withheld = sum of all monthly PIT withheld; YTD_taxable_income = YTD_gross − YTD_si_employee − annual personal deduction − annual dependent deductions. Emits `YtdIncomeConsolidated`. |
| 3 | System | Annual personal and dependent deductions | Annual personal deduction = 11,000,000 × 12 = 132,000,000 VND (BR-050). Annual dependent deduction = 4,400,000 × dependent_count × months_eligible (BR-051). Dependent months_eligible: if a dependent was registered mid-year, only months from registration date count. |
| 4 | System | Calculate annual PIT liability | Resident workers (tax_residency_status = RESIDENT or ≥ 183 days in Vietnam): ANNUAL_TAXABLE = YTD_gross − YTD_si_employee − annual_personal_deduction − annual_dependent_deductions. Apply 7-bracket progressive PIT on ANNUAL_TAXABLE (scaled to annual amounts, NQ 954/2020): Bracket thresholds are 12× the monthly brackets. Annual PIT liability = sum of bracket calculations. (BR-041, BR-048). Non-resident workers (< 183 days in Vietnam): Annual PIT = YTD_gross × 20% (BR-042). 183-day threshold determination: system checks entry/exit records if available, otherwise uses tax_residency_status from CompensationSnapshot (HS-6). |
| 5 | System | Calculate settlement delta | settlement_delta = annual_pit_liability − YTD_pit_withheld. If settlement_delta > 0: worker underpaid PIT (owes additional PIT). If settlement_delta < 0: worker overpaid PIT (entitled to refund). If settlement_delta = 0: settled — no action needed. Emits `PITSettlementDeltaCalculated`. |
| 6 | System | Exception flagging | Flags workers with: large underpayment (> 5,000,000 VND — may indicate incorrect monthly withholding), residency status change mid-year (HS-6 risk), workers who changed employment mid-year (income from previous employer not known to this payroll system). |
| 7 | Payroll Admin | Reviews settlement results | Admin reviews per-worker settlement delta table. Acknowledges exceptions. For workers with income from other employers: settlement cannot be finalized by the payroll system — worker must self-settle with GDT directly (per Vietnamese PIT Law). |
| 8 | Payroll Admin | Issues `SubmitForApproval` (settlement run) | PayrollRun (ANNUAL_SETTLEMENT) transitions to PENDING_APPROVAL. HR Manager notified. |
| 9 | HR Manager / Finance Manager | Approves settlement run | Same multi-level approval as monthly payroll (UCF-01 Steps 14–17). Emits `PITSettlementApproved`. |
| 10 | System | Apply settlement delta to payslip | For workers with underpayment (delta > 0): creates ANNUAL_PIT_SETTLEMENT_DEDUCTION element in the current open period's payroll. For workers with overpayment (delta < 0): creates ANNUAL_PIT_SETTLEMENT_REFUND element (positive earnings, reduces total PIT). Emits `AnnualPitSettlementCompleted`. |
| 11 | System | Trigger PIT certificate generation | BC-03 emits `AnnualPitSettlementCompleted` event. BC-05 (Statutory Reporting) consumes this event and generates PIT Certificate (Form 05/QTT-TNCN) for each worker. Emits `PITCertificateIssued` (from BC-05). BC-06 (Worker Self-Service) makes certificate available for download. |

---

### Annual PIT Calculation Example

Worker: Tax resident, 2 dependents registered full year, single employer

YTD income (12 monthly PayrollResults):
- YTD_gross: 300,000,000 VND (25M/month average)
- YTD_si_employee: 28,800,000 VND (12 × 2,400,000 — capped at ceiling each month)
- YTD_pit_withheld (monthly): 19,200,000 VND total

Annual PIT calculation:
- ANNUAL_TAXABLE = 300,000,000 − 28,800,000 − 132,000,000 (personal) − 105,600,000 (2 deps × 12 months × 4,400,000) = 33,600,000 VND

Annual PIT brackets (annual thresholds = 12× monthly):
- 0 – 60,000,000 VND: 5%
- 60,000,001 – 120,000,000: 10%
- etc.

Annual PIT on 33,600,000 VND:
- First 60,000,000 bracket: but ANNUAL_TAXABLE = 33,600,000 < 60,000,000
- Annual PIT = 33,600,000 × 5% = 1,680,000 VND

Settlement delta: 1,680,000 − 19,200,000 = −17,520,000 VND (overpayment)
Worker receives ANNUAL_PIT_SETTLEMENT_REFUND of 17,520,000 VND in January payslip.

---

## Alternate Flows

### AF-1: Worker Changed Employers Mid-Year
- At step 2: YTD income only includes months with this employer
- System flags MULTI_EMPLOYER_INCOME_RISK exception
- Per Vietnamese PIT Law: worker must self-authorize settlement if they had income from multiple sources
- System generates a partial settlement for the months in this employment only
- Note in PIT certificate: "Tự quyết toán tại cơ quan thuế" (self-settle at tax authority) flag set

### AF-2: Non-Resident Worker Settlement
- At step 4: if tax_residency_status = NON_RESIDENT for the full year
- Annual PIT = YTD_gross × 20% (flat, no deductions)
- Compare to YTD_pit_withheld — typically already withheld at 20% monthly (BR-042), so delta ≈ 0
- PIT certificate issued for non-resident workers uses a different template

### AF-3: Termination Mid-Year PIT Settlement
- Worker terminated in June; final-pay run (UCF-07) triggers immediate PIT settlement
- YTD months = January to June only
- Annual deductions are pro-rated: personal deduction = 11,000,000 × 6 months = 66,000,000 VND
- System calculates settlement delta at termination date; applies to final payslip
- PIT certificate issued immediately after termination payroll is approved

---

## Exception Flows

### EF-1: 183-Day Residency Threshold Mid-Year (HS-6)
- At step 4: worker's residency status changed during the year (e.g., arrived in Vietnam April 1, reached 183 days in September)
- Impact: months January–September were taxed at non-resident rate (20%); from October onward, worker is resident (progressive PIT)
- Settlement must re-classify entire year's income as resident (if 183 days reached by Dec 31): annual PIT recalculated using progressive schedule on full-year income
- This frequently results in a significant overpayment refund (progressive PIT < 20% flat for most income levels)
- System flags RESIDENCY_STATUS_CHANGE with months_as_resident count
- Payroll Admin must confirm 183-day count from CO's visa/entry records before applying the re-classification
- High risk of error: Payroll Admin must manually verify entry/exit records

### EF-2: Missing Monthly PayrollResult
- At step 2: one or more months' PayrollResults are in DRAFT (period not locked) or do not exist
- System cannot proceed with settlement — `YtdIncomeConsolidated` cannot be completed
- Emits blocking exception: INCOMPLETE_YEAR_PERIODS
- Payroll Admin must close and lock all pending periods before re-triggering settlement

### EF-3: Large Settlement Delta
- At step 5: settlement_delta (positive) > 20,000,000 VND (configurable threshold)
- System flags LARGE_UNDERPAYMENT exception
- May indicate: incorrect monthly withholding formula, dependent deduction applied incorrectly
- Requires Finance Manager review before approval (escalated approval)

---

## Domain Events Emitted

| Event | Emitted At Step | Payload Key Fields |
|-------|-----------------|-------------------|
| AnnualPitSettlementInitiated | 1 | run_id, tax_year, pay_group_id, worker_count, legal_entity_id |
| YtdIncomeConsolidated | 2 | run_id, working_relationship_id, tax_year, ytd_gross, ytd_si_employee, ytd_pit_withheld, months_included |
| PITSettlementDeltaCalculated | 5 | run_id, working_relationship_id, annual_taxable, annual_pit_liability, ytd_pit_withheld, settlement_delta, residency_status |
| PITSettlementApproved | 9 | run_id, approved_by, approved_at |
| AnnualPitSettlementCompleted | 10 | run_id, tax_year, total_refund_amount, total_additional_collection, worker_count |
| PITCertificateIssued | 11 (BC-05) | certificate_id, working_relationship_id, tax_year, annual_taxable, annual_pit_liability, settlement_delta |

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-040 | Annual PIT taxable income formula: ANNUAL_TAXABLE = YTD_gross − YTD_si_employee − personal_deduction − dependent_deductions |
| BR-041 | 7-bracket progressive PIT on annual taxable income (annual thresholds = 12× monthly) |
| BR-042 | Non-resident: 20% flat annual PIT on gross |
| BR-043 | Freelance/service workers: 10% withholding — annual settlement applies only to employment income |
| BR-047 | Monthly PIT computed directly each month; annual settlement reconciles cumulative withholding vs. annual liability |
| BR-048 | Annual PIT settlement process: ANNUAL_TAXABLE computation, delta calculation, application to final period |
| BR-050 | Annual personal deduction: 11,000,000 × 12 = 132,000,000 VND |
| BR-051 | Annual dependent deduction: 4,400,000 × dependent_count × eligible_months |

---

## Hot Spots / Risks

- HS-6: 183-day residency threshold mid-year — The most complex edge case in Vietnamese PIT. If a worker crosses the 183-day threshold within the tax year, their entire annual income may need to be re-classified as resident, triggering a full retroactive recalculation. Requires CO module to maintain accurate entry/exit records. Domain model must support this re-classification workflow explicitly.
- Annual settlement timing — Vietnamese law requires PIT settlement before the tax filing deadline (typically March 31 of the following year for employer-facilitated settlement). The system must enforce this deadline.
