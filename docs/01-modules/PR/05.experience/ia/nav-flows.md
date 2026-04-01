# Navigation Flows — Payroll Module (PR)

**Module**: Payroll (PR)
**Step**: 5 — Product Experience Design
**Date**: 2026-03-31

---

## NF-01: Monthly Production Payroll Run (US-010 to US-017, US-019)

**Actors**: Payroll Admin, HR Manager, Finance Manager
**Entry**: Payroll → Payroll Runs → [+ New Run]

### Pre-conditions
- Pay Group exists and is ACTIVE
- Pay Period exists in OPEN status for the target month
- Pay calendar cut-off date has been reached (or admin triggers manually)

### Flow

**Step 1: Apply Cut-Off**
- Path: Payroll → Pay Periods → [Period Detail] → [Apply Cut-Off]
- System freezes compensation snapshots (CO pull + TR pull per working_relationship)
- Period transitions: OPEN → CUT_OFF
- Payroll Admin can also trigger manually before scheduled cut-off date (reason required)

**Step 2: Initiate Run**
- Path: Payroll Runs → [+ New Run]
- Wizard Step 1: Select Pay Group + Period (only CUT_OFF periods eligible)
- Wizard Step 2: Select run mode
  - DRY_RUN: validate only, no records persisted
  - SIMULATION: full calculation, results visible but not approvable
  - PRODUCTION: official run
- Confirm → API: POST /payroll/runs (returns 202, run_id)
- UI transitions to run progress screen

**Step 3: Monitor Async Run Progress**
- Progress screen shows: run stage, workers processed / total, elapsed time
- Stages: QUEUED → PRE_VALIDATING → RUNNING → COMPLETED / FAILED
- WebSocket push updates; fallback to 5-second polling
- If FAILED: error details shown with actionable next step ("Correct formula and retry")
- If pre-validation fails: shows list of workers with PRE_VALIDATION_FAILED reasons

**Step 4: Review Exceptions**
- Run reaches COMPLETED status with N open exceptions
- Exception count badge visible on run detail header
- Path: Run Detail → Exceptions tab
- Exceptions listed: type, worker name, details, recommended action
- Admin can acknowledge individually (one at a time) or bulk acknowledge by type
- Each acknowledgment requires: reason_code (dropdown) + notes (free text)
- Exception count decrements on each acknowledgment
- API: POST /payroll/runs/{runId}/exceptions/{exceptionId}/acknowledge

**Step 5: Review Variance Report (optional but recommended)**
- Path: Run Detail → Variance Report tab
- Shows element-level comparison: current vs prior period values
- Rows highlighted in red if variance exceeds threshold (default 20%)
- Admin can filter by element type, department, or worker

**Step 6: Submit for Approval**
- Path: Run Detail → [Submit for Approval] (enabled when exceptions = 0 OPEN)
- Confirmation dialog: "Submit VNG-STAFF-HCM / 2026-03 for approval? 450 workers."
- API: POST /payroll/runs/{runId}/submit-for-approval
- Run transitions: COMPLETED → PENDING_APPROVAL
- HR Manager receives in-app + email notification

**Exit Points at Any Step**
- Cancel run → run transitions to FAILED (no records committed for PRODUCTION mode)
- Data error found → return to Pay Master to fix, then re-run from Step 2

---

## NF-02: Approval Flow (US-025 to US-028)

**Actors**: HR Manager (Level 2), Finance Manager (Level 3)
**Entry**: Approval Queue (HR Manager or Finance Manager view)

### Level 2 Approval (HR Manager)

**Step 1: Receive Notification**
- HR Manager receives notification: "Payroll run VNG-STAFF-HCM / 2026-03 submitted for approval"
- In-app notification badge on Approval Queue menu item

**Step 2: Review Run**
- Path: Approval Queue → Run Detail
- Views available: Payroll Register, Exception Report summary, Variance Report
- Can drill down to individual worker payslip detail

**Step 3: Approve or Reject**
- [Approve (Level 2)]: run transitions → LEVEL_2_APPROVED
  - Finance Manager receives notification
- [Reject]: mandatory reason_code + notes
  - Run transitions → REJECTED
  - Pay period returns to OPEN
  - Payroll Admin notified with rejection reason
  - Rejected run preserved in history (not deleted)
- API: POST /payroll/runs/{runId}/approve or /reject

### Level 3 Approval (Finance Manager)

**Step 1: Receive Notification**
- Finance Manager receives: "Payroll run VNG-STAFF-HCM / 2026-03 awaiting final approval"

**Step 2: Review Run**
- Path: Approval Queue → Run Detail
- Finance-specific view: total gross, total employer cost, total PIT, total SI employer, per-department breakdown
- Can drill down to individual worker payslip

**Step 3: Final Approve or Reject**
- [Approve (Level 3)]: run transitions → APPROVED, pay period → APPROVED
  - SHA-256 integrity hashes generated for all worker result records
  - Payroll Admin notified: "Period approved. Ready for lock."
- [Reject]: same as Level 2 rejection path

**Step 4: Lock Period**
- After Level 3 approval, Finance Manager (or Payroll Admin per config) clicks [Lock Period]
- API: POST /payroll/periods/{periodId}/lock
- Period transitions → LOCKED
- Integrity hash generation confirmed
- Payslip generation job triggered automatically
- Bank payment file generation made available

---

## NF-03: Exception Handling (US-016, US-017, US-037)

**Actor**: Payroll Admin
**Entry**: Payroll Runs → Run Detail → Exceptions tab (after run COMPLETED with exceptions)

**Step 1: View Exception Summary**
- Exceptions grouped by type: NEGATIVE_NET, MIN_WAGE_VIOLATION, ZERO_GROSS, OT_CAP_EXCEEDED, ZERO_BHXH_SI_ELIGIBLE, PIT_ZERO_HIGH_GROSS
- Total count shown in run detail header badge
- Filter by type, status (OPEN / ACKNOWLEDGED), worker

**Step 2: Investigate Exception**
- Click exception row → exception detail modal or side panel
- Shows: worker name, worker ID, exception type, violation details (e.g., gross = 3,500,000 < minimum 3,860,000), recommended action

**Step 3: Acknowledge Exception**
- [Acknowledge] button → reason_code picker (APPROVED_OVERRIDE / DATA_CORRECTION_SCHEDULED / RETRO_WILL_CORRECT / BUSINESS_EXCEPTION_APPROVED)
- Notes field (free text, mandatory)
- Submit → exception status → ACKNOWLEDGED

**Step 4: Bulk Acknowledge (optional)**
- Select multiple exceptions of the same type → [Bulk Acknowledge]
- Choose common reason_code + shared notes
- All selected exceptions acknowledged in one operation

**Step 5: Verify All Acknowledged**
- Exception list shows 0 OPEN exceptions
- [Submit for Approval] button becomes enabled in run detail

**Error Path: Cannot Acknowledge**
- If exception already acknowledged: system shows "Already acknowledged by [user] at [timestamp]"
- If worker data needs correction: admin navigates to TR / TA module, corrects data, re-runs payroll

---

## NF-04: Termination Payroll (US-023)

**Actor**: Payroll Admin
**Entry**: Off-Cycle Runs → Termination Pay → [+ New Termination Run]

**Step 1: Search Worker**
- Search by name or worker ID
- System fetches working_relationship termination event from CO

**Step 2: Confirm Termination Details**
- Termination date, termination_type (RESIGNATION / REDUCTION_IN_FORCE / CONTRACT_EXPIRY)
- Pay period context (is a regular period open or will this be standalone?)

**Step 3: Configure Pay Elements**
- System auto-selects elements based on termination_type × pay_method config
- For RESIGNATION: PRO_RATED_SALARY, LEAVE_PAYOUT
- For REDUCTION_IN_FORCE: PRO_RATED_SALARY, LEAVE_PAYOUT, SEVERANCE
- Admin can review and override element list

**Step 4: Initiate Run**
- API: POST /payroll/workers/{workingRelationshipId}/termination-run
- Run queued (202 response)
- Progress screen (same async pattern as monthly run)

**Step 5: Review Result**
- Run completes → result shows: pro-rated salary, leave payout, severance, PIT, SI, net
- Exception handling if any (same pattern as NF-03)

**Step 6: Approval + Payment**
- Same two-level approval workflow as monthly run
- Bank payment file generated for final net payment

---

## NF-05: Statutory Rule Update (US-006, US-007)

**Actor**: Platform Admin
**Entry**: Platform → Statutory Rules

**Step 1: View Current Rules**
- Path: Statutory Rules → List
- Filter by category (TAX / SOCIAL_INSURANCE / OVERTIME / MINIMUM_WAGE)
- Timeline view for each rule code shows: currently ACTIVE version, upcoming SCHEDULED versions (future valid_from), historical SUPERSEDED versions

**Step 2: Create New Rule Version**
- [+ New Rule Version] → Form
- Fields: rule_code (e.g., VN_BHXH_EMP_RATE), rule_category, value or formula_json, valid_from, country_code
- Validation: valid_from must not overlap with another ACTIVE version for same rule_code
- API: POST /statutory-rules
- Rule created in DRAFT status

**Step 3: Review and Activate**
- Rule detail shows: DRAFT status, all configured values
- [Activate] button → confirmation: "Activate VN_BHXH_EMP_RATE effective 2024-07-01? This will supersede the previous active rule."
- API: POST /statutory-rules/{ruleId}/activate
- Previous active rule for same code → SUPERSEDED
- Calculation engine cache invalidated
- StatutoryRuleActivated event published

**Step 4: Verify on Timeline**
- Return to rule timeline view
- New rule shows as ACTIVE from effective date
- Old rule shows as SUPERSEDED (still readable for audit)

**Error Path: Conflicting Dates**
- If new rule's valid_from overlaps with existing ACTIVE rule: API returns 409
- System shows: "Conflicting active rule: VN_BHXH_EMP_RATE valid 2024-07-01 to 2025-12-31. Set valid_from after that date or supersede first."

---

## NF-06: Worker Self-Service Payslip (US-040, US-041)

**Actor**: Worker
**Entry**: My Pay → My Payslips

**Step 1: View Payslip List**
- Paginated list of periods with payslips available
- Each row: period name (e.g., "March 2026"), gross, net, status
- Only periods in LOCKED status have payslips available
- Periods not yet locked show: "Your March 2026 payslip will be available after payroll processing"

**Step 2: View Payslip Detail**
- Click period → payslip rendered online (HTML view, not inline PDF)
- Sections: worker info, pay period, earnings breakdown, deductions breakdown (BHXH, BHYT, BHTN, PIT, others), net salary
- [Download PDF] button → PDF generated server-side, downloaded

**Step 3: PIT Certificate (Tax Documents tab)**
- My Pay → Tax Documents → PIT Certificates
- Year picker → list of available certificates
- If no PIT withheld for year: message "No PIT was withheld for you in 2024. A certificate is not required."
- [Download Form 03/TNCN] → PDF download

**Step 4: YTD Summary**
- My Pay → My YTD Summary
- Shows YTD totals: GROSS, BHXH, BHYT, BHTN, PIT, NET
- Month-by-month breakdown table (only locked periods shown)
- YTD values reset to 0 from January of each year

**Security Boundary**
- All API calls for worker self-service are scoped to the authenticated worker's working_relationship_id
- No URL parameter allows cross-worker data access
- Direct URL to another worker's payslip → HTTP 403

---

## NF-07: Retroactive Adjustment (US-020)

**Actor**: Payroll Admin
**Entry**: Retroactive Adjustments → [+ New Adjustment]

**Step 1: Select Worker and Reason**
- Search worker → auto-fetch working_relationship
- Select adjustment_type (SALARY_CHANGE / ALLOWANCE_CHANGE / RESIDENCY_CHANGE)
- Enter effective_from date (must be in a LOCKED period)

**Step 2: Define New Compensation Values**
- Enter corrected element values that should have applied from effective_from date
- System computes which periods are affected (effective_from to current open period)

**Step 3: Preview Delta**
- System displays period-by-period delta preview:
  | Period | Original Net | Recalculated Net | Delta |
  If delta depth > 3 periods: confirmation gate shown (BR-091)
  If delta depth > 12 periods: blocked with error message (BR-090)

**Step 4: Confirm and Queue**
- Admin confirms → API: POST /payroll/retro-adjustments (202)
- RETRO_ADJUSTMENT element added to next open period's payroll for the worker

**Step 5: Verify in Next Run**
- When the next production run executes, RETRO_ADJUSTMENT element appears in worker result
- Visible in payslip as separate line item: "Retroactive Adjustment — Jan–Feb 2026"

---

## NF-08: BHXH Report Generation (US-033)

**Actor**: Payroll Admin
**Entry**: Compliance → BHXH Reports → [Generate D02-LT]

**Step 1: Select Parameters**
- Legal entity, pay period (must be LOCKED)
- System shows: eligible worker count for this period

**Step 2: Generate Report**
- [Generate] → API: POST /statutory-reporting/bhxh-report (202)
- Progress indicator (async)

**Step 3: Download or Review Errors**
- On completion: download link for D02-LT file (VssID format)
- If any workers have MISSING_BHXH_NUMBER: error list shown with worker names
- Admin must register BHXH numbers in CO module and regenerate

---

## NF-09: PIT Declaration Export (US-034)

**Actor**: Payroll Admin
**Entry**: Compliance → PIT Declarations → [Generate 05/KK-TNCN]

**Step 1: Select Parameters**
- Legal entity, declaration_type (QUARTERLY), year, quarter
- System validates: all 3 periods in the quarter must be LOCKED

**Step 2: Generate XML**
- [Generate] → API: POST /statutory-reporting/pit-declaration (202)
- Async progress

**Step 3: Download**
- Download XML file for manual upload to GDT eTax portal
- Report history shows all previously generated declarations (by year/quarter)
- Non-resident workers appear in correct form section automatically

---

## NF-10: Calc Log Drill-Down (Audit of Calculation)

**Actor**: Payroll Admin
**Entry**: Payroll Runs → Run Detail → Worker Results → [View Calc Log] for a specific worker

**Step 1: Select Worker in Run**
- Worker Results list (paginated) → click [View Calc Log] action

**Step 2: View Log Steps**
- Paginated list of calculation steps (100+ entries possible)
- Each entry: step_sequence, step_type, element_code, input_values, output_value, statutory_rule_reference (with rule code and effective date)
- Filter by: step_type (GROSS / SI / PIT / DEDUCTION), element_code

**Step 3: Verify Statutory Rule References**
- Each row shows statutory_rule_code (e.g., "VN_BHXH_EMP_RATE") with effective date
- Click rule reference → navigates to Statutory Rules detail for that rule version
- No literal numeric values in log; all rates trace to named statutory rules

