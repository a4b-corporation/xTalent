# UCF-03: Piece-Rate Worker Pay Calculation

**Bounded Context**: Payroll Execution (BC-03)
**Timeline**: T2 — Monthly payroll cycle variant (executed within UCF-01 Step 6C)
**Actors**: Payroll Admin, System (Drools engine)
**Trigger**: PayrollRun reaches gross calculation phase (Step 6 of UCF-01) for workers whose PayProfile.pay_method = PIECE_RATE

---

## Preconditions

- Worker's PayProfile.pay_method = PIECE_RATE
- PieceRateTable is populated on the PayProfile with entries for the product codes produced by this worker
- TA module has provided piece quantity data per (product_code, quality_grade, working_relationship_id) via `AttendanceLocked` event
- CompensationSnapshot exists for the worker (created at cut-off)
- StatutoryRule: regional minimum wage and SI rates are ACTIVE for the cut-off date
- Worker's region_code is known (from CompensationSnapshot or PayGroup)
- PayProfile.si_basis_mode is configured (PIECE_RATE_GROSS or PIECE_RATE_BASE_EQUIVALENT)

---

## Main Flow

| Step | Actor | Action | System Response |
|------|-------|--------|-----------------|
| 1 | System | Retrieve piece quantity records | System reads from the CompensationSnapshot / TA data: list of {product_code, quality_grade, quantity_produced} for the period. Groups by (product_code, quality_grade). |
| 2 | System | Look up PieceRateTable | For each (product_code, quality_grade) pair, system looks up PieceRateTable on the PayProfile. Selects the entry with effective_date ≤ cut_off_date (latest applicable rate). Retrieves rate_per_unit_vnd. |
| 3 | System | Apply quality multiplier | System checks if quality_grade carries a multiplier override (e.g., GRADE_A = 1.0, GRADE_B = 0.95, GRADE_C = 0.85). Applies: effective_rate = rate_per_unit_vnd × quality_multiplier. Emits `PieceRateQuantityRecorded` with the input data. |
| 4 | System | Calculate piece-rate gross | For each (product_code, quality_grade) line: line_amount = quantity × effective_rate. Total piece_gross = sum of all line_amounts. Emits `PieceRatePayCalculated`. |
| 5 | System | Apply fixed allowances | If PayProfile has EARNINGS elements with proration_method = NONE (always full pay), add them: total_gross = piece_gross + fixed_allowances. These elements are in addition to piece earnings (e.g., meal allowance, transport allowance). |
| 6 | System | Minimum wage floor check | System retrieves RegionalMinimumWage for the worker's region_code. Checks: total_gross ≥ regional_minimum_wage. If total_gross < regional_minimum_wage: system calculates adjustment = regional_minimum_wage − total_gross. A MINIMUM_WAGE_SUPPLEMENT element is added to make total_gross = regional_minimum_wage. Emits `MinimumWageFloorApplied` with adjustment_amount. |
| 7 | System | Determine SI basis | Reads PayProfile.si_basis_mode. If PIECE_RATE_GROSS: SI basis = total_gross (after minimum wage adjustment). If PIECE_RATE_BASE_EQUIVALENT: SI basis = configured base_equivalent_amount (a fixed reference amount, not actual earnings — used when parties agree SI is on a notional base rather than variable actual). The system uses this SI basis in UCF-01 Step 7 for SI calculation (BR-017). |
| 8 | System | Hand off to SI and PIT calculation | total_gross feeds into UCF-01 Step 7 (SI) and Step 8 (PIT). For PIT: piece-rate income is treated as employment income — progressive PIT applies if contract_type is employment. If FREELANCE or SERVICE_CONTRACT: 10% freelance withholding applies (BR-043), not progressive PIT. |

---

### Piece-Rate Calculation Example

Worker: grade = G2, Region 2, October production

PieceRateTable (PayProfile, effective 2024-01-01):
- (PRODUCT_A, GRADE_A) → 25,000 VND/unit
- (PRODUCT_A, GRADE_B) → 25,000 × 0.95 = 23,750 VND/unit
- (PRODUCT_B, GRADE_A) → 18,000 VND/unit

Production records (TA-provided):
- PRODUCT_A, GRADE_A: 200 units
- PRODUCT_A, GRADE_B: 50 units
- PRODUCT_B, GRADE_A: 100 units

Calculation:
- PRODUCT_A/GRADE_A: 200 × 25,000 = 5,000,000 VND
- PRODUCT_A/GRADE_B: 50 × 23,750 = 1,187,500 VND
- PRODUCT_B/GRADE_A: 100 × 18,000 = 1,800,000 VND
- piece_gross = 7,987,500 VND

Fixed allowances (meal + transport, proration = NONE):
- meal_allowance = 800,000 VND (tax-exempt per VN_LUNCH_EXEMPT_CAP)
- transport_allowance = 500,000 VND

total_gross = 7,987,500 + 800,000 + 500,000 = 9,287,500 VND

Region 2 minimum wage (2024) = 4,160,000 VND/month
- 9,287,500 > 4,160,000 → no floor supplement needed

SI basis (PIECE_RATE_GROSS mode) = 7,987,500 VND (piece earnings only, allowances excluded if si_basis_inclusion = EXCLUDED on those elements)

---

## Alternate Flows

### AF-1: No Production for the Period
- At step 1: TA provides zero quantity records (worker on full unpaid leave, sick leave with no production)
- piece_gross = 0
- Total_gross = fixed_allowances only
- If total_gross < minimum wage: minimum wage supplement applied
- If total_gross after supplement < minimum wage supplement: NEGATIVE_NET will not occur but MIN_WAGE_VIOLATION exception may flag depending on configuration
- CalcLog records ZERO_PRODUCTION line

### AF-2: New Product Code Not in PieceRateTable
- At step 2: TA provides a (product_code, quality_grade) pair not in PieceRateTable
- System flags MISSING_PIECE_RATE exception (blocking)
- Payroll Admin must update PieceRateTable with the new product_code entry and re-run
- This should be caught in pre-validation if product_code validation is implemented

### AF-3: Hybrid Worker — Piece Rate + Hourly OT
- Worker's PayProfile.pay_method = PIECE_RATE but PayProfile also has HOURLY OT elements bound
- piece_gross is computed as in Main Flow steps 1–5
- OT hours are computed as per UCF-02 Steps 5–7 using a reference hourly rate (must be configured in HourlyRateConfig even for PIECE_RATE workers)
- total_gross = piece_gross + ot_earnings + fixed_allowances
- SI basis mode governs whether OT earnings are included in SI basis

---

## Exception Flows

### EF-1: PieceRateTable Entry Expired
- At step 2: all PieceRateTable entries for a product_code have effective_date > cut_off_date (future rates only)
- System flags EXPIRED_RATE_TABLE exception
- Pre-validation should catch this scenario before the run starts
- Resolution: Payroll Admin enters a new PieceRateTable entry with the correct effective_date

### EF-2: Minimum Wage Floor Applied — Worker Acknowledgement Required
- At step 6: system adds MINIMUM_WAGE_SUPPLEMENT element
- Emits `MinimumWageFloorApplied`
- System logs this as an informational event (not a blocking exception) because the supplement resolves the violation automatically
- Payroll Admin sees the supplement in the summary report for that worker

### EF-3: Quality Grade Not Recognized
- At step 3: quality_grade code in TA data does not match any entry in PieceRateTable
- System flags UNKNOWN_QUALITY_GRADE exception (blocking for that worker)
- TA team must correct the quality grade classification and re-lock attendance
- Or Payroll Admin maps the unrecognized grade to a known grade via manual override (requires acknowledgement)

---

## Domain Events Emitted

| Event | Emitted At Step | Payload Key Fields |
|-------|-----------------|-------------------|
| PieceRateQuantityRecorded | 3 | result_id, working_relationship_id, period_id, production_lines[{product_code, quality_grade, quantity, rate_per_unit, quality_multiplier}] |
| PieceRatePayCalculated | 4 | result_id, working_relationship_id, piece_gross, line_count, total_units_produced |
| MinimumWageFloorApplied | 6 | result_id, working_relationship_id, region_code, minimum_wage, piece_gross_before, supplement_amount, total_gross_after |

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-006 | PIECE_RATE pay method: gross = sum of (quantity × rate_per_unit × quality_multiplier) for each (product_code, quality_grade) in the period |
| BR-012 | PieceRateTable configuration: product_code × quality_grade → rate_per_unit_vnd × effective_date |
| BR-017 | Piece-rate hybrid SI basis mode: PIECE_RATE_GROSS vs. PIECE_RATE_BASE_EQUIVALENT |
| BR-070 | Region 1 minimum wage floor: 4,960,000 VND/month (2024, Decree 38/2022) |
| BR-071 | Region 2 minimum wage floor: 4,160,000 VND/month |
| BR-072 | Region 3 minimum wage floor: 3,640,000 VND/month |
| BR-073 | Minimum wage exception: if worker's actual hours < standard month, floor is pro-rated; for piece-rate workers working full month, full floor applies regardless of production volume |

---

## Hot Spots / Risks

- HS-1: TA data completeness — Piece-rate pay is entirely driven by TA-provided production quantities. Accuracy of product_code, quality_grade, and quantity is critical. No production data = zero earnings before minimum wage floor.
- HS-5: Performance — Workers in manufacturing payrolls may have 20–50 distinct (product_code, quality_grade) lines per period. PieceRateTable must be cached in working memory. At 1,000 piece-rate workers × 30 lines = 30,000 table lookups per run.
