# Event Storming — Payroll Module (PR)

**Artifact**: event-storming.md
**Module**: Payroll (PR)
**Solution**: xTalent HCM
**Date**: 2026-03-27
**Version**: 1.0

---

## 3.1 Timeline Overview

| Timeline | Name | Description |
|----------|------|-------------|
| T1 | Pay Master Setup | Initial configuration of PayGroups, PayElements, PayProfiles, StatutoryRules |
| T2 | Monthly Payroll Lifecycle | Full monthly cycle from period open to lock: cut-off → run → approve → lock |
| T3 | Off-Cycle Payroll | Termination, advance, correction, bonus run outside regular cycle |
| T4 | Year-End Processing | Annual PIT settlement, YTD balance reset, formula archival |
| T5 | Worker Self-Service | Worker accesses payslip, YTD summary, PIT certificate |
| T6 | Regulatory Rule Management | Statutory rule creation, update, and activation for decree changes |

---

## 3.2 Event Catalog

> Events use PascalCase past-tense naming. Minimum 50 events covered.

---

### T1: Pay Master Setup Events

---

**EVENT: PayGroupCreated**
```
Aggregate: PayGroup
Trigger: CreatePayGroup command by Payroll Admin
Payload: pay_group_id, code, name, legal_entity_id, calendar_id, currency_code, created_by, created_at
Consumers: Payroll Admin (confirmation), Audit Log
Timeline: T1
```

**EVENT: PayGroupUpdated**
```
Aggregate: PayGroup
Trigger: UpdatePayGroup command
Payload: pay_group_id, changed_fields, previous_values, updated_by, updated_at
Consumers: Audit Log; any cached PayGroup consumers must invalidate cache
Timeline: T1
```

**EVENT: WorkerAssignedToPayGroup**
```
Aggregate: PayGroup
Trigger: AssignWorkerToPayGroup command; or CO WorkingRelationshipCreated event
Payload: pay_group_id, working_relationship_id, effective_date, assigned_by
Consumers: Payroll Admin (enrollment confirmation); CO integration acknowledgment
Timeline: T1
```

**EVENT: WorkerRemovedFromPayGroup**
```
Aggregate: PayGroup
Trigger: RemoveWorkerFromPayGroup command; or CO WorkingRelationshipTerminated event
Payload: pay_group_id, working_relationship_id, effective_date, removal_reason, removed_by
Consumers: Audit Log; next payroll run pre-validation
Timeline: T1
```

**EVENT: PayElementCreated**
```
Aggregate: PayElement
Trigger: CreatePayElement command by Payroll Admin
Payload: element_id, code, classification, tax_treatment, si_basis_inclusion, proration_method, country_code, created_by
Consumers: Audit Log; PayProfile binding workflow
Timeline: T1
```

**EVENT: PayElementFormulaSubmitted**
```
Aggregate: PayElement
Trigger: SubmitFormulaForApproval command; status DRAFT → PENDING_APPROVAL
Payload: element_id, formula_version, formula_script_hash, submitted_by, submitted_at
Consumers: Finance Lead (approval notification via Temporal); Audit Log
Timeline: T1
```

**EVENT: PayElementFormulaApproved**
```
Aggregate: PayElement
Trigger: ApproveFormula command by Finance Lead; status PENDING_APPROVAL → APPROVED
Payload: element_id, formula_version, approved_by, approved_at
Consumers: Payroll Admin (activation available); Audit Log
Timeline: T1
```

**EVENT: PayElementActivated**
```
Aggregate: PayElement
Trigger: ActivateFormula command; status APPROVED → ACTIVE
Payload: element_id, formula_version, activated_by, activated_at, previous_version_deprecated_at
Consumers: Calculation Engine (formula registry refresh); Audit Log
Timeline: T1
```

**EVENT: PayElementDeprecated**
```
Aggregate: PayElement
Trigger: Automatic when new version activates; status ACTIVE → DEPRECATED
Payload: element_id, deprecated_version, deprecated_at, superseded_by_version
Consumers: Audit Log; admin notification
Timeline: T1
```

**EVENT: PayProfileCreated**
```
Aggregate: PayProfile
Trigger: CreatePayProfile command
Payload: profile_id, code, pay_method, proration_method, rounding_method, payment_method, min_wage_rule_id, created_by
Consumers: Audit Log; worker assignment workflow
Timeline: T1
```

**EVENT: PayProfileUpdated**
```
Aggregate: PayProfile
Trigger: UpdatePayProfile command
Payload: profile_id, changed_fields, previous_values, updated_by, updated_at
Consumers: Audit Log; any running payroll runs that reference this profile must be flagged
Timeline: T1
```

**EVENT: PayProfileElementBound**
```
Aggregate: PayProfile
Trigger: BindElementToProfile command
Payload: profile_id, element_id, is_mandatory, priority_order, effective_date, bound_by
Consumers: Audit Log
Timeline: T1
```

**EVENT: PayProfileRuleBound**
```
Aggregate: PayProfile
Trigger: BindStatutoryRuleToProfile command
Payload: profile_id, rule_id, rule_scope, execution_order, bound_by
Consumers: Audit Log; calculation engine rule registry
Timeline: T1
```

---

### T6: Regulatory Rule Management Events

---

**EVENT: StatutoryRuleCreated**
```
Aggregate: StatutoryRule
Trigger: CreateStatutoryRule command by Platform Admin
Payload: rule_id, code, rule_category, rule_type, country_code, valid_from, valid_to, formula_json, created_by
Consumers: Calculation Engine (rule registry); Audit Log
Timeline: T6
```

**EVENT: StatutoryRuleActivated**
```
Aggregate: StatutoryRule
Trigger: ActivateStatutoryRule command; is_active set to true
Payload: rule_id, code, valid_from, activated_by, activated_at
Consumers: Calculation Engine (cache invalidation); Audit Log; Payroll Admin notification
Timeline: T6
```

**EVENT: StatutoryRuleDeactivated**
```
Aggregate: StatutoryRule
Trigger: DeactivateStatutoryRule command; is_active set to false
Payload: rule_id, code, deactivated_by, deactivated_at, reason
Consumers: Calculation Engine (cache invalidation); Audit Log
Timeline: T6
```

**EVENT: PitBracketsUpdated**
```
Aggregate: StatutoryRule (VN_PIT_BRACKETS_*)
Trigger: CreateStatutoryRule for a new VN_PIT_BRACKETS version (new decree)
Payload: old_rule_id, new_rule_id, new_valid_from, new_brackets, updated_by
Consumers: Calculation Engine; Payroll Admin (alert: "PIT brackets updated — verify formula alignment"); Audit Log
Timeline: T6
```

**EVENT: SiCeilingUpdated**
```
Aggregate: StatutoryRule (VN_LUONG_CO_SO or VN_SI_CEILING_MULTIPLIER)
Trigger: CreateStatutoryRule for new lương cơ sở value
Payload: old_rule_id, new_rule_id, old_value, new_value, new_valid_from, updated_by
Consumers: Calculation Engine; Audit Log; Payroll Admin alert
Timeline: T6
```

**EVENT: MinimumWageUpdated**
```
Aggregate: StatutoryRule (VN_MIN_WAGE_REGION_*)
Trigger: CreateStatutoryRule for new regional minimum wage
Payload: region_code, old_value, new_value, new_valid_from, decree_reference
Consumers: Calculation Engine; Payroll Admin alert; Audit Log
Timeline: T6
```

---

### T2: Monthly Payroll Lifecycle Events

---

**EVENT: PayPeriodOpened**
```
Aggregate: PayPeriod
Trigger: OpenPayPeriod command; or automatic on period_start date
Payload: period_id, pay_group_id, period_start, period_end, cut_off_date, payment_date, opened_by
Consumers: Payroll Admin notification; TA module (prepare attendance for this period)
Timeline: T2
```

**EVENT: CutOffReached**
```
Aggregate: PayPeriod
Trigger: Scheduled job on cut_off_date; or manual trigger by Payroll Admin
Payload: period_id, pay_group_id, cut_off_timestamp
Consumers: CO (trigger compensation_snapshot creation); TA (trigger AttendanceLocked for all workers); Payroll Admin notification
Timeline: T2
```

**EVENT: CompensationSnapshotTaken**
```
Aggregate: CompensationSnapshot
Trigger: CutOffReached event; PR calls CO API to create snapshot per working_relationship
Payload: snapshot_id, working_relationship_id, period_id, base_salary, allowances_json, contract_type, dependent_count, tax_residency_status, snapshot_at
Consumers: Payroll Engine (pre-validation); Audit Log
Timeline: T2
```

**EVENT: AttendanceDataReceived**
```
Aggregate: PayrollRun (pre-validation)
Trigger: AttendanceLocked event from TA module consumed by PR
Payload: working_relationship_id, period_id, actual_work_days, overtime_hours_json, piece_data, received_at
Consumers: Pre-validation stage; completeness tracking dashboard
Timeline: T2
```

**EVENT: PayrollRunInitiated**
```
Aggregate: PayrollRun
Trigger: InitiatePayrollRun command by Payroll Admin
Payload: run_id, pay_group_id, period_id, run_mode (DRY_RUN | SIMULATION | PRODUCTION), initiated_by, initiated_at
Consumers: Calculation Engine queue; Audit Log
Timeline: T2
```

**EVENT: PreValidationPassed**
```
Aggregate: PayrollRun
Trigger: Pre-validation stage of PayrollRun completing without errors
Payload: run_id, worker_count_passed, worker_count_excluded, validation_summary
Consumers: Calculation Engine (proceed to gross calculation); Payroll Admin (notification)
Timeline: T2
```

**EVENT: PreValidationFailed**
```
Aggregate: PayrollRun
Trigger: Pre-validation stage detecting critical missing data
Payload: run_id, failed_workers: [{working_relationship_id, failure_reason}], validation_summary
Consumers: Payroll Admin (blocking notification); run status → FAILED
Timeline: T2
```

**EVENT: GrossCalculationCompleted**
```
Aggregate: PayrollRun
Trigger: Gross calculation stage completing for all workers
Payload: run_id, workers_processed, total_gross_amount, duration_ms, stage = "GROSS"
Consumers: SI deductions stage; Calculation Log; Audit Log
Timeline: T2
```

**EVENT: StatutoryDeductionsCalculated**
```
Aggregate: PayrollRun
Trigger: SI contribution calculation stage completing
Payload: run_id, total_bhxh_employee, total_bhyt_employee, total_bhtn_employee, total_employer_contributions, duration_ms
Consumers: PIT calculation stage; Audit Log
Timeline: T2
```

**EVENT: PitCalculated**
```
Aggregate: PayrollRun
Trigger: PIT calculation stage completing for all workers
Payload: run_id, total_pit_withheld, resident_worker_count, non_resident_worker_count, duration_ms
Consumers: Net calculation stage; Audit Log
Timeline: T2
```

**EVENT: NetCalculationCompleted**
```
Aggregate: PayrollRun
Trigger: Net calculation (gross minus all deductions) stage completing
Payload: run_id, total_net_amount, workers_with_exceptions, duration_ms
Consumers: Post-processing stage; Audit Log
Timeline: T2
```

**EVENT: ExceptionFlagged**
```
Aggregate: PayrollResult (per worker)
Trigger: Post-processing stage detecting a rule violation for a specific worker
Payload: run_id, working_relationship_id, exception_type (NEGATIVE_NET | MIN_WAGE_VIOLATION | ZERO_BHXH_SI_ELIGIBLE | OT_CAP_EXCEEDED), details, flagged_at
Consumers: Exception Report; Payroll Admin notification; run cannot proceed to approval until resolved
Timeline: T2
```

**EVENT: ExceptionAcknowledged**
```
Aggregate: PayrollResult (per worker exception)
Trigger: AcknowledgeException command by Payroll Admin
Payload: run_id, working_relationship_id, exception_type, reason_code, acknowledged_by, acknowledged_at
Consumers: Exception tracking; Audit Log; unblocks run progression when all exceptions resolved
Timeline: T2
```

**EVENT: PayrollRunCompleted**
```
Aggregate: PayrollRun
Trigger: All post-processing stages passing; all exceptions acknowledged
Payload: run_id, pay_group_id, period_id, run_mode, workers_processed, total_gross, total_net, total_pit, completed_at, duration_ms
Consumers: Payroll Admin (submit for approval); Simulation report (if DRY_RUN/SIMULATION)
Timeline: T2
```

**EVENT: PayrollRunFailed**
```
Aggregate: PayrollRun
Trigger: Any engine stage throwing an uncaught exception; full rollback triggered
Payload: run_id, failed_stage (PRE_VALIDATION | GROSS | SI | PIT | NET | POST_PROCESSING), error_message, failed_at
Consumers: Payroll Admin (error notification); run status → FAILED; rollback confirmation
Timeline: T2
```

**EVENT: PayrollRunSubmittedForApproval**
```
Aggregate: PayrollRun
Trigger: SubmitForApproval command by Payroll Admin (all exceptions acknowledged)
Payload: run_id, period_id, submitted_by, submitted_at, approval_level_required = 2 (HR Manager next)
Consumers: HR Manager (notification); Temporal approval workflow; Audit Log
Timeline: T2
```

**EVENT: ApprovalLevelPassed**
```
Aggregate: PayrollRun
Trigger: ApprovePaylrollRun command at a given level
Payload: run_id, approval_level (2 | 3), approved_by, approved_at, notes
Consumers: Next approver (notification); Temporal workflow; Audit Log
Timeline: T2
```

**EVENT: PayrollRunRejected**
```
Aggregate: PayrollRun
Trigger: RejectPayrollRun command by any approver
Payload: run_id, rejected_at_level (2 | 3), rejected_by, reason_code, notes, rejected_at
Consumers: Payroll Admin (rejection notification with reason); pay_period returns to OPEN; Audit Log
Timeline: T2
```

**EVENT: PayrollRunApproved**
```
Aggregate: PayrollRun
Trigger: ApprovePayrollRun command at Level 3 (Finance Manager final approval)
Payload: run_id, final_approver, approved_at, total_payment_amount
Consumers: Period lock trigger; Bank file generation; GL journal generation; Audit Log
Timeline: T2
```

**EVENT: PayPeriodLocked**
```
Aggregate: PayPeriod
Trigger: PayrollRunApproved event triggers period lock
Payload: period_id, locked_at, locked_by (Finance Manager), run_id, total_net_payment
Consumers: Integrity hash generation job; Payslip generation; Audit Log
Timeline: T2
```

**EVENT: IntegrityHashGenerated**
```
Aggregate: PayrollResult (per worker)
Trigger: PayPeriodLocked event; SHA-256 hash computed for each worker result
Payload: period_id, worker_result_hashes: [{working_relationship_id, integrity_hash}], generated_at
Consumers: Nightly integrity verification job; Audit Log
Timeline: T2
```

**EVENT: IntegrityVerificationPassed**
```
Aggregate: PayPeriod
Trigger: Nightly integrity verification job finding all hashes match
Payload: period_id, verified_at, worker_count_verified
Consumers: Audit Log (INFO level)
Timeline: T2
```

**EVENT: IntegrityViolationDetected**
```
Aggregate: PayPeriod
Trigger: Nightly integrity verification job finding a hash mismatch
Payload: period_id, affected_worker_ids, mismatch_details, detected_at
Consumers: Platform Admin + Finance Manager (CRITICAL alert via notification channel); Audit Log (CRITICAL level); incident management
Timeline: T2
```

---

### Output Events (Generated after period lock)

---

**EVENT: PayslipsGenerated**
```
Aggregate: PayPeriod
Trigger: PayPeriodLocked event triggers payslip batch generation
Payload: period_id, pay_group_id, payslip_count, generation_started_at, generation_completed_at, template_code
Consumers: Worker notification service (send payslip availability notification); Audit Log
Timeline: T2
```

**EVENT: BankPaymentFileGenerated**
```
Aggregate: PayPeriod
Trigger: PayrollRunApproved event; Finance Manager triggers bank file generation
Payload: period_id, bank_code (VCB | BIDV | TCB), file_name, file_url, payment_channel, record_count, total_amount_vnd, generated_at, generated_by
Consumers: Finance Manager (file download notification); Audit Log; pay_bank.payment_batch record
Timeline: T2
```

**EVENT: GlJournalGenerated**
```
Aggregate: PayPeriod
Trigger: PayPeriodLocked event triggers GL journal batch generation
Payload: period_id, journal_line_count, total_debit, total_credit, generated_at
Consumers: Accounting system integration; Finance Manager notification; Audit Log
Timeline: T2
```

**EVENT: BhxhReportGenerated**
```
Aggregate: PayPeriod
Trigger: GenerateBhxhReport command by Payroll Admin (after period lock)
Payload: period_id, report_type = D02_LT, file_name, eligible_worker_count, total_bhxh_employee, total_bhxh_employer, generated_at
Consumers: Payroll Admin (file download); BHXH submission tracking; Audit Log
Timeline: T2
```

**EVENT: PitDeclarationGenerated**
```
Aggregate: PayPeriod (quarterly)
Trigger: GeneratePitDeclaration command by Payroll Admin
Payload: quarter, year, pay_group_id, declaration_type (QUARTERLY | ANNUAL), xml_file_name, worker_count, total_pit_withheld, generated_at
Consumers: Payroll Admin (file download); Tax submission tracking; Audit Log
Timeline: T2 / T4
```

---

### T3: Off-Cycle Payroll Events

---

**EVENT: OffCycleRunInitiated**
```
Aggregate: PayrollRun
Trigger: InitiateOffCycleRun command; run_type = TERMINATION | ADVANCE | CORRECTION | BONUS_RUN
Payload: run_id, run_type, pay_group_id, working_relationship_ids, trigger_reason, initiated_by, initiated_at
Consumers: Calculation Engine; Audit Log
Timeline: T3
```

**EVENT: TerminationPayCalculated**
```
Aggregate: PayrollRun (TERMINATION type)
Trigger: Calculation engine completing a TERMINATION off-cycle run
Payload: run_id, working_relationship_id, termination_type, elements_included, gross_amount, net_amount, calculated_at
Consumers: Approval workflow (same as regular run); Payslip generation; Audit Log
Timeline: T3
```

**EVENT: SalaryAdvancePaid**
```
Aggregate: PayrollRun (ADVANCE type)
Trigger: ApprovalFinalPassed for an ADVANCE run
Payload: run_id, working_relationship_id, advance_amount, recovery_period_id, recovery_amount, advance_paid_at
Consumers: Next regular payroll run (insert ADVANCE_RECOVERY element); Bank file generation; Audit Log
Timeline: T3
```

**EVENT: AdvanceRecoveryScheduled**
```
Aggregate: PayrollRun (upcoming regular run)
Trigger: SalaryAdvancePaid event
Payload: working_relationship_id, advance_run_id, recovery_element_id, recovery_amount, scheduled_for_period_id
Consumers: Next regular payroll pre-processing (ADVANCE_RECOVERY element inserted automatically); Audit Log
Timeline: T3
```

---

### T4: Year-End Processing Events

---

**EVENT: RetroactiveAdjustmentQueued**
```
Aggregate: PayrollRun
Trigger: QueueRetroactiveAdjustment command; triggered by salary change with past effective date
Payload: adjustment_id, working_relationship_id, source_change_type, retroactive_from_period, retroactive_to_period, queued_by, queued_at
Consumers: Retroactive calculation engine; Audit Log
Timeline: T4 / T2
```

**EVENT: RetroactiveAdjustmentApplied**
```
Aggregate: PayrollResult
Trigger: Retroactive calculation completing and delta applied to next open period
Payload: adjustment_id, target_period_id, working_relationship_id, retro_delta_amount, original_periods_recalculated, applied_at
Consumers: Next regular payroll run (RETRO_ADJUSTMENT element); Payslip for next period; Audit Log
Timeline: T4 / T2
```

**EVENT: AnnualPitSettlementInitiated**
```
Aggregate: PayrollRun (ANNUAL_SETTLEMENT type)
Trigger: TriggerAnnualPitSettlement command by Payroll Admin
Payload: run_id, year, pay_group_id, settlement_timing (DECEMBER_PAYROLL | JANUARY_STANDALONE), initiated_by
Consumers: Calculation Engine; Audit Log
Timeline: T4
```

**EVENT: AnnualPitSettlementCompleted**
```
Aggregate: PayrollRun (ANNUAL_SETTLEMENT)
Trigger: Settlement engine completing annual PIT reconciliation
Payload: run_id, year, worker_count, underpaid_count, overpaid_count, total_underpayment, total_overpayment, completed_at
Consumers: Approval workflow; Form 05/QTT-TNCN generation; Worker notifications; Audit Log
Timeline: T4
```

**EVENT: YtdBalancesReset**
```
Aggregate: Balance (all YTD balance records)
Trigger: Scheduled job on January 1 each year (00:00:01)
Payload: reset_year, balance_types_reset, worker_count_affected, reset_at
Consumers: Audit Log; Payroll Admin notification (YTD reset confirmation)
Timeline: T4
```

**EVENT: PitWithholdingCertificateGenerated**
```
Aggregate: Worker (self-service)
Trigger: GeneratePitCertificate command by Worker (self-service) or Payroll Admin
Payload: certificate_id, working_relationship_id, year, ytd_gross, ytd_pit_withheld, tax_code, generated_at
Consumers: Worker self-service portal (download); Audit Log
Timeline: T5
```

---

### T5: Worker Self-Service Events

---

**EVENT: PayslipViewed**
```
Aggregate: Worker (self-service)
Trigger: Worker navigates to payslip in self-service portal
Payload: working_relationship_id, period_id, viewed_by (worker_id), viewed_at
Consumers: Audit Log (access tracking); Worker engagement metrics
Timeline: T5
```

**EVENT: PayslipDownloaded**
```
Aggregate: Worker (self-service)
Trigger: Worker clicks "Download PDF" on payslip page
Payload: working_relationship_id, period_id, downloaded_by (worker_id), downloaded_at
Consumers: Audit Log; Worker engagement metrics
Timeline: T5
```

**EVENT: PitCertificateDownloaded**
```
Aggregate: Worker (self-service)
Trigger: Worker downloads PIT certificate
Payload: certificate_id, working_relationship_id, year, downloaded_by, downloaded_at
Consumers: Audit Log
Timeline: T5
```

---

## 3.3 Commands Catalog

> Minimum 25 commands. Commands are imperative actions that produce events.

---

**COMMAND: CreatePayGroup**
```
Actor: Payroll Admin
Pre-condition: Legal entity exists; pay_calendar exists for the entity
Produces event: PayGroupCreated
```

**COMMAND: AssignWorkerToPayGroup**
```
Actor: Payroll Admin / CO integration (automated)
Pre-condition: PayGroup exists; working_relationship exists in CO
Produces event: WorkerAssignedToPayGroup
```

**COMMAND: CreatePayElement**
```
Actor: Payroll Admin
Pre-condition: Payroll Admin has PAYROLL_ADMIN role; country_code is valid
Produces event: PayElementCreated
```

**COMMAND: SubmitFormulaForApproval**
```
Actor: Payroll Admin
Pre-condition: formula is in DRAFT state; formula passes compile-time validation
Produces event: PayElementFormulaSubmitted
```

**COMMAND: ApproveFormula**
```
Actor: Finance Lead
Pre-condition: formula is in PENDING_APPROVAL state; Finance Lead has FORMULA_APPROVER role
Produces event: PayElementFormulaApproved
```

**COMMAND: ActivateFormula**
```
Actor: Payroll Admin (after approval)
Pre-condition: formula is in APPROVED state
Produces event: PayElementActivated; PayElementDeprecated (previous active version)
```

**COMMAND: CreatePayProfile**
```
Actor: Payroll Admin
Pre-condition: pay_method is valid enum; min_wage_rule_id references existing statutory_rule
Produces event: PayProfileCreated
```

**COMMAND: BindElementToProfile**
```
Actor: Payroll Admin
Pre-condition: pay_element is ACTIVE; pay_profile exists
Produces event: PayProfileElementBound
```

**COMMAND: CreateStatutoryRule**
```
Actor: Platform Admin
Pre-condition: Platform Admin has STATUTORY_RULE_ADMIN role; rule_category is valid; valid_from is a valid date
Produces event: StatutoryRuleCreated
```

**COMMAND: ActivateStatutoryRule**
```
Actor: Platform Admin
Pre-condition: statutory_rule is created; no conflicting rule with overlapping valid_from/valid_to for same code
Produces event: StatutoryRuleActivated
```

**COMMAND: OpenPayPeriod**
```
Actor: Payroll Admin / Scheduled job
Pre-condition: No overlapping open period for same PayGroup; previous period is LOCKED or CLOSED
Produces event: PayPeriodOpened
```

**COMMAND: TriggerCutOff**
```
Actor: Scheduled job (automated at cut_off_date) / Payroll Admin (manual trigger)
Pre-condition: Period is OPEN; current date >= cut_off_date
Produces event: CutOffReached
```

**COMMAND: InitiatePayrollRun**
```
Actor: Payroll Admin
Pre-condition: Period is OPEN; no other RUNNING or PENDING_APPROVAL run for same PayGroup+period; run_mode is valid
Produces event: PayrollRunInitiated
```

**COMMAND: AcknowledgeException**
```
Actor: Payroll Admin
Pre-condition: Exception record exists for the run; admin provides reason_code; admin has EXCEPTION_RESOLVER role
Produces event: ExceptionAcknowledged
```

**COMMAND: SubmitForApproval**
```
Actor: Payroll Admin
Pre-condition: Run status = PENDING_APPROVAL (engine completed); ALL exceptions acknowledged
Produces event: PayrollRunSubmittedForApproval
```

**COMMAND: ApprovePayrollRunLevel2**
```
Actor: HR Manager
Pre-condition: Run is submitted; HR Manager has PAYROLL_APPROVER_L2 role; run is pending Level 2
Produces event: ApprovalLevelPassed (level=2)
```

**COMMAND: ApprovePayrollRunLevel3**
```
Actor: Finance Manager
Pre-condition: Level 2 approval passed; Finance Manager has PAYROLL_APPROVER_L3 role
Produces event: PayrollRunApproved; PayPeriodLocked
```

**COMMAND: RejectPayrollRun**
```
Actor: HR Manager / Finance Manager (any approval level)
Pre-condition: Run is in approval workflow; approver has the required role for their level
Produces event: PayrollRunRejected
```

**COMMAND: GenerateBankPaymentFile**
```
Actor: Finance Manager
Pre-condition: Period is LOCKED; payment_channel = FILE_MANUAL; bank_payment_config exists for bank_code
Produces event: BankPaymentFileGenerated
```

**COMMAND: GenerateGlJournal**
```
Actor: Automated (triggered by PayPeriodLocked event)
Pre-condition: Period is LOCKED; gl_mapping exists for all elements in the run
Produces event: GlJournalGenerated
```

**COMMAND: GenerateBhxhReport**
```
Actor: Payroll Admin
Pre-condition: Period is LOCKED; D02-LT format template configured
Produces event: BhxhReportGenerated
```

**COMMAND: GeneratePitDeclaration**
```
Actor: Payroll Admin
Pre-condition: All periods in the quarter/year are LOCKED
Produces event: PitDeclarationGenerated
```

**COMMAND: InitiateOffCycleRun**
```
Actor: Payroll Admin
Pre-condition: Off-cycle run type is valid; for TERMINATION: working_relationship has termination date; termination_pay_config exists
Produces event: OffCycleRunInitiated
```

**COMMAND: TriggerAnnualPitSettlement**
```
Actor: Payroll Admin
Pre-condition: All 12 periods of the settlement year are LOCKED; PayGroup.SETTLEMENT_TIMING is configured
Produces event: AnnualPitSettlementInitiated
```

**COMMAND: QueueRetroactiveAdjustment**
```
Actor: Payroll Admin
Pre-condition: Salary change with past effective date detected; affected periods count <= RETRO_MAX_PERIODS; if > RETRO_CONFIRM_THRESHOLD then admin has confirmed
Produces event: RetroactiveAdjustmentQueued
```

**COMMAND: DownloadPayslip**
```
Actor: Worker (self-service) / Payroll Admin
Pre-condition: Period is LOCKED; payslip generated; actor has access to the working_relationship
Produces event: PayslipDownloaded
```

**COMMAND: GeneratePitCertificate**
```
Actor: Worker (self-service) / Payroll Admin
Pre-condition: Worker had PIT withheld in the requested year; all periods of that year are LOCKED
Produces event: PitWithholdingCertificateGenerated
```

---

## 3.4 Hot Spots

> Hot spots are areas of risk, ambiguity, or complexity that need explicit attention.

---

**HOT SPOT: TA Data Completeness at Cut-Off**
```
Location in flow: T2 — Between CutOffReached and PayrollRunInitiated
Risk: TA module fails to deliver AttendanceLocked events for 10–30% of workers before cut-off.
      This blocks the production run or forces a partial run.
      Consequence: payroll delayed past Vietnamese statutory payment deadline (worker rights violation).
Open question: What is the exact SLA for TA → PR AttendanceLocked delivery?
               What is the agreed fallback: partial run allowed? estimated attendance fallback?
               Who bears the risk when TA is late?
Priority: P0
Impact if unresolved: Cannot produce correct payroll; regulatory penalty risk
```

**HOT SPOT: TR/PR Calculation Boundary in Practice**
```
Location in flow: T1 — StatutoryRuleCreated; T2 — CompensationSnapshotTaken
Risk: Even with ADR signed, TR and PR teams may interpret the boundary differently at implementation time.
      Symptom: TR stores a rate for a calculation that PR believes it owns (or vice versa).
      SI ceiling split-period calculation is particularly at risk — who recalculates the basis when
      lương cơ sở changes mid-month?
Open question: Does the ADR explicitly list every table and field that belongs to PR vs. TR?
               Is there a governance process for resolving boundary disputes in sprint?
Priority: P0
Impact if unresolved: Duplicate calculation logic; inconsistent results when decree changes
```

**HOT SPOT: Negative Net Salary Resolution Workflow**
```
Location in flow: T2 — ExceptionFlagged (NEGATIVE_NET) through SubmitForApproval
Risk: Admin must "acknowledge" a negative net exception. But what does that mean in practice?
      Does acknowledgment mean: (a) exclude the worker from this period, (b) reduce deductions,
      (c) accept zero-net payment? Different actions have different financial implications.
Open question: What is the exact list of resolution options available to the admin for NEGATIVE_NET?
               Can the admin force a 0-net payment? Can they defer loan recovery to next period?
               Who approves the resolution decision (Payroll Admin alone or requires HR Manager)?
Priority: P0
Impact if unresolved: Incorrect payments or disputes; admin cannot close run cleanly
```

**HOT SPOT: SI Eligibility Matrix for Edge Contract Types**
```
Location in flow: T2 — StatutoryDeductionsCalculated
Risk: The si_eligibility_rule table must accurately map every contract_type to BHXH/BHYT/BHTN flags.
      Edge cases: (a) intern contracts — BHYT yes, BHXH no, (b) short-term < 1 month contracts,
      (c) part-time workers with multiple concurrent contracts across legal entities,
      (d) probation period extended beyond 60 days.
Open question: Does the CO module expose contract_type in a standardized enum that matches PR's si_eligibility_rule?
               Who is responsible for keeping the eligibility matrix updated when new contract types are introduced?
Priority: P0
Impact if unresolved: Under or over-SI-contribution; BHXH penalty risk
```

**HOT SPOT: Annual PIT Settlement Timing and Worker Residency**
```
Location in flow: T4 — AnnualPitSettlementInitiated
Risk: Annual settlement for a worker who crossed the 183-day tax residency threshold mid-year requires
      recalculating ALL prior months under the new (resident) progressive rate.
      The worker may have been withheld at 20% flat for 6 months and then progressively for 6 months.
      Settlement must recompute the full year at the correct rate for each sub-period.
Open question: Is there a tracking mechanism for the 183-day count per worker?
               Who manages this in CO? Does CO publish a ResidencyStatusChanged event?
               How does PR know WHEN the threshold was crossed?
Priority: P1
Impact if unresolved: Incorrect annual PIT settlement; tax authority penalty for employer
```

**HOT SPOT: Retroactive Adjustment Chain Dependencies**
```
Location in flow: T4 — RetroactiveAdjustmentQueued
Risk: A retroactive salary change may cascade: changing gross changes SI basis, which changes PIT taxable income,
      which changes PIT. If a second retroactive adjustment follows the first, the deltas compound.
      Deep retroactive chains (12 periods × multiple changes × 1,000 workers) could take hours to process
      or exhaust the async queue.
Open question: Is retroactive calculation synchronous (blocks the admin) or asynchronous (runs in background)?
               How does the admin know when it is complete?
               Can two retroactive adjustments run concurrently for the same worker?
Priority: P1
Impact if unresolved: Incorrect compounded deltas; long-running jobs with no visibility; potential deadlock
```

**HOT SPOT: Bank File Rejection by Bank Portal**
```
Location in flow: T2 — BankPaymentFileGenerated (aftermath — not modeled in PR)
Risk: Finance team uploads the generated bank file to VCB/BIDV/TCB portal.
      The bank portal rejects the file due to format errors, inactive accounts, or duplicate payment references.
      The finance team must manually correct and re-upload — a process entirely outside PR.
      PR has no feedback loop to know whether the payment was actually made.
Open question: Should PR track payment confirmation status (FILE_PENDING → BANK_SUBMITTED → CONFIRMED)?
               Who updates the payment status in PR when the bank confirms?
               If a bank rejects the file, can PR generate a corrected file without re-locking the period?
Priority: P1
Impact if unresolved: Partial salary disbursement; workers not paid on time; finance team has no visibility into payment status in PR
```

**HOT SPOT: Multi-Working-Relationship Worker PIT Aggregation**
```
Location in flow: T2 — PitCalculated
Risk: A worker has two working_relationships across two legal entities (both in xTalent).
      Each entity runs payroll independently and applies the full personal deduction (11M).
      The worker effectively gets double personal deduction — resulting in underpayment of PIT to the government.
      Vietnamese law requires the primary employer to apply all deductions; secondary employer withholds flat 10%.
Open question: How does PR know which working_relationship is the "primary" employer?
               Is this flag set in CO? Does it drive a different PIT calculation path?
               Who is responsible for enforcing the single-personal-deduction rule in a multi-entity scenario?
Priority: P1
Impact if unresolved: Worker underpays PIT across entities; employer may be liable for under-withholding
```

**HOT SPOT: Holiday Calendar Ownership and Latency**
```
Location in flow: T2 — Before PayrollRunInitiated (holiday calendar cache refresh)
Risk: TA owns the holiday calendar (AQ-07). PR caches it at period start.
      If TA updates the calendar after period start (e.g., government announces an unexpected holiday),
      PR's cached calendar is stale and will misclassify work days for OT premium calculation.
Open question: Does TA publish a HolidayCalendarUpdated event that invalidates PR's cache mid-period?
               If PR's cache is invalidated AFTER workers have already been pre-processed for OT,
               does PR need to re-run those workers?
Priority: P2
Impact if unresolved: Incorrect OT premium for workers who worked on an unrecognized holiday
```

**HOT SPOT: Drools 8 Performance at Scale**
```
Location in flow: T2 — PayrollRunInitiated through PayrollRunCompleted
Risk: Performance SLA (1,000 workers in 30 seconds; 10,000 in 5 minutes) has confidence = 0.60.
      No load test POC has been completed on target infrastructure.
      If Drools 8 cannot meet the SLA, the architecture requires fundamental change (parallel partitioning,
      external rule engine, or pre-compiled MVEL bytecode).
Open question: Has a Phase 0 load test POC been scheduled?
               What is the escalation path if the load test fails?
               Is there a fallback engine option (e.g., inline formula evaluation without Drools)?
Priority: P0
Impact if unresolved: Payroll runs exceed time windows; payroll delayed; SLA breached
```

---

## 3.5 Aggregates and Boundaries

### PayGroup Aggregate

**Owns**:
- pay_master.pay_group
- pay_master.pay_group → pay_master.pay_calendar link
- pay_master.pay_group → org_legal.entity link

**Key Events**: PayGroupCreated, PayGroupUpdated, WorkerAssignedToPayGroup, WorkerRemovedFromPayGroup

**Commands In**: CreatePayGroup, UpdatePayGroup, AssignWorkerToPayGroup, RemoveWorkerFromPayGroup

**Invariants**:
- A PayGroup belongs to exactly one legal_entity_id (non-nullable)
- A PayGroup references exactly one pay_calendar
- Workers assigned to a PayGroup must have working_relationship in the same legal_entity

---

### PayElement Aggregate

**Owns**:
- pay_master.pay_element
- pay_master.pay_formula (linked via formula_json)
- Lifecycle state machine (DRAFT → PENDING_APPROVAL → APPROVED → ACTIVE → DEPRECATED)

**Key Events**: PayElementCreated, PayElementFormulaSubmitted, PayElementFormulaApproved, PayElementActivated, PayElementDeprecated

**Commands In**: CreatePayElement, SubmitFormulaForApproval, ApproveFormula, ActivateFormula

**Invariants**:
- Only ACTIVE formulas may be used in payroll calculations
- Formula must pass compile-time validation before PENDING_APPROVAL transition
- Literal statutory rates in formulas produce a compile-time warning; activation requires Finance Lead acknowledgment

---

### PayProfile Aggregate

**Owns**:
- pay_master.pay_profile
- pay_master.pay_profile_element (element bindings)
- pay_master.pay_profile_rule (statutory rule bindings)
- pay_master.pay_profile_map (worker assignments)

**Key Events**: PayProfileCreated, PayProfileUpdated, PayProfileElementBound, PayProfileRuleBound

**Commands In**: CreatePayProfile, UpdatePayProfile, BindElementToProfile, BindStatutoryRuleToProfile

**Invariants**:
- pay_method must be a valid enum: MONTHLY_SALARY | HOURLY | PIECE_RATE | GRADE_STEP | TASK_BASED
- min_wage_rule_id must reference a valid statutory_rule
- At least one element binding must be MANDATORY for the profile to be usable in a run

---

### StatutoryRule Aggregate

**Owns**:
- pay_master.statutory_rule
- Versioning via valid_from / valid_to date ranges

**Key Events**: StatutoryRuleCreated, StatutoryRuleActivated, StatutoryRuleDeactivated, PitBracketsUpdated, SiCeilingUpdated, MinimumWageUpdated

**Commands In**: CreateStatutoryRule, ActivateStatutoryRule, DeactivateStatutoryRule

**Invariants**:
- No two active statutory_rule records for the same code can have overlapping valid date ranges
- Statutory rates must be stored here — not in application code
- All payroll calculation formulas must reference statutory_rule codes, not literal values

---

### PayPeriod Aggregate

**Owns**:
- pay_mgmt.pay_period
- Period state machine: OPEN → PROCESSING → PENDING_APPROVAL → APPROVED → LOCKED

**Key Events**: PayPeriodOpened, CutOffReached, PayPeriodLocked, IntegrityHashGenerated, IntegrityVerificationPassed, IntegrityViolationDetected

**Commands In**: OpenPayPeriod, TriggerCutOff, LockPeriod (triggered by PayrollRunApproved)

**Invariants**:
- LOCKED is irreversible — only CORRECTION off-cycle runs can address errors
- A period can only have one production run in PENDING_APPROVAL or APPROVED state at a time (concurrency lock)
- SHA-256 hashes must be generated before the period is considered fully locked

---

### PayrollRun Aggregate

**Owns**:
- pay_mgmt.batch
- pay_engine.run_request
- Run state machine: QUEUED → RUNNING → [DRY_RUN_COMPLETE | SIMULATION_COMPLETE | PENDING_APPROVAL | FAILED]
- Exception tracking: pay_engine.exception_record

**Key Events**: PayrollRunInitiated, PreValidationPassed, PreValidationFailed, GrossCalculationCompleted, StatutoryDeductionsCalculated, PitCalculated, NetCalculationCompleted, ExceptionFlagged, ExceptionAcknowledged, PayrollRunCompleted, PayrollRunFailed, PayrollRunSubmittedForApproval, ApprovalLevelPassed, PayrollRunRejected, PayrollRunApproved

**Commands In**: InitiatePayrollRun, AcknowledgeException, SubmitForApproval, ApprovePayrollRunLevel2, ApprovePayrollRunLevel3, RejectPayrollRun

**Invariants**:
- A production run is atomic: either all workers succeed or the entire run rolls back
- Exceptions must be 100% acknowledged before SubmitForApproval is permitted
- Maximum one RUNNING or PENDING_APPROVAL run per PayGroup+period at any time

---

### PayrollResult Aggregate (per-worker per-period)

**Owns**:
- pay_engine.run_result (per-worker result record)
- pay_engine.result (per-element result lines)
- pay_engine.balance (YTD/MTD accumulator values updated by this run)
- pay_engine.calc_log (per-worker calculation trace)
- integrity_hash (SHA-256, immutable after period lock)

**Key Events**: (part of PayrollRun events — results are written during the run, not as separate events)

**Invariants**:
- Once period is LOCKED, result records are immutable (no UPDATE/DELETE)
- integrity_hash is computed from a canonical set of fields and must match on every nightly verification
- calc_log must contain a full calculation trace — all formula inputs, intermediate values, and statutory_rule references

---

### CompensationSnapshot Aggregate

**Owns**:
- PR-local snapshot of working_relationship data taken at cut-off
- Fields: contract_type, legal_entity_id, cost_center_id, grade_code, registered_dependent_count, tax_residency_status, base_salary, allowances_map, bank_account_id, bhxh_number, tax_id

**Key Events**: CompensationSnapshotTaken

**Commands In**: TakeCompensationSnapshot (triggered by CutOffReached)

**Invariants**:
- Snapshot is immutable once taken — it represents the state of truth at cut-off
- The snapshot ID is referenced in all PayrollResult records to ensure reproducibility
- If CO data is unavailable at cut-off, pre-validation fails for that worker (no fallback value)

---

## Event Flow Diagram (Narrative)

**Monthly Payroll Happy Path (T2 Summary)**:

```
[T-30 days]  PayPeriodOpened
[T-25 days]  Workers assigned to PayGroup (ongoing via WorkerAssignedToPayGroup)
[T-5 days]   CutOffReached
             → CompensationSnapshotTaken (per worker, via CO API)
             → AttendanceLocked events arrive from TA (ongoing)
[T-3 days]   Payroll Admin: InitiatePayrollRun (DRY_RUN)
             → PreValidationPassed / Failed
             → GrossCalculationCompleted
             → [DRY_RUN_COMPLETE — no persistence]
[T-2 days]   Payroll Admin: InitiatePayrollRun (PRODUCTION)
             → PreValidationPassed
             → GrossCalculationCompleted
             → StatutoryDeductionsCalculated
             → PitCalculated
             → NetCalculationCompleted
             → ExceptionFlagged (0–N workers)
             → ExceptionAcknowledged (admin resolves each)
             → PayrollRunCompleted
             → Payroll Admin: SubmitForApproval
             → PayrollRunSubmittedForApproval
[T-1 day]    HR Manager: ApprovePayrollRunLevel2
             → ApprovalLevelPassed (level=2)
             Finance Manager: ApprovePayrollRunLevel3
             → PayrollRunApproved
             → PayPeriodLocked
             → IntegrityHashGenerated (per worker)
             → PayslipsGenerated (batch)
             → BankPaymentFileGenerated (Finance Manager downloads)
             → GlJournalGenerated (posted to accounting)
[T+0]        Finance Manager uploads bank file to VCB/BIDV/TCB portal
             Workers receive payslip notification
             Payroll Admin generates BhxhReportGenerated (upload to VssID)
[Nightly]    IntegrityVerificationPassed / IntegrityViolationDetected
```
