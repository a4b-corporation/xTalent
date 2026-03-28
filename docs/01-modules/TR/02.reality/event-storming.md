# Total Rewards — Event Storming Catalog

> **Module**: Total Rewards (TR)
> **Giải pháp**: xTalent — HCM
> **Phiên bản**: 1.0.0
> **Ngày**: 2026-03-26
> **Tác giả**: Business Analyst Agent (ODSA Step 2)
> **Phạm vi**: 6 quốc gia SEA (VN, TH, ID, SG, MY, PH)

---

## Thống kê tổng quan

| Loại | Số lượng | Ghi chú |
|------|----------|---------|
| Domain Events (Orange) | 55 | Past tense, business-meaningful |
| Commands (Blue) | 30 | Imperative, intent-driven |
| Actors (Yellow) | 17 | xTalent naming convention |
| Hot Spots (Pink) | 8 | Còn mở (P2 deferred) |
| USP Events (Star) | 8 | Innovation differentiators |
| Domain Timelines | 5 | Compensation, Benefits, Variable Pay, Commission, Audit |

---

## Domain Events (Orange)

### Cluster 1: Core Compensation

| Event ID | Event Name | Sub-module | Trigger | Outcome | USP? |
|----------|------------|------------|---------|---------|------|
| E-CC-001 | `SalaryStructureCreated` | Core Compensation | HR Admin tạo Salary Basis + Pay Components | Cấu trúc lương ready để gán | — |
| E-CC-002 | `GradeVersionCreated` | Core Compensation | Grade bị thay đổi (promotion, demotion) | SCD Type 2 version mới; lịch sử giữ nguyên | — |
| E-CC-003 | `PayRangeUpdated` | Core Compensation | Market data mới, Compensation Admin update | Pay range mới effective từ date | — |
| E-CC-004 | `CompensationCycleOpened` | Core Compensation | Compensation Admin chạy OpenCompensationCycle | Cycle OPEN; Managers có thể submit proposal | — |
| E-CC-005 | `MeritRecommendationSubmitted` | Core Compensation | People Manager submit proposal | Proposal pending approval; budget_remaining giảm tạm | — |
| E-CC-006 | `CompensationApproved` | Core Compensation | Approver approve proposal (auto hoặc manual) | Salary change scheduled; Worker notification | — |
| E-CC-007 | `CompensationRejected` | Core Compensation | Approver reject proposal | Budget_remaining hoàn lại; Manager notified | — |
| E-CC-008 | `SalaryEffectiveDateReached` | Core Compensation | Cron job detect effective_date = today | Salary activated; Payroll bridge triggered | — |
| E-CC-009 | `CompensationCycleClosed` | Core Compensation | Cycle end date hoặc Admin manual close | Proposals locked; final summary published | — |
| E-CC-010 | `SalaryHistoryArchived` | Core Compensation | CompensationApproved + effective_date | SCD Type 2 snapshot ghi nhận before/after | — |
| E-CC-011 | `BudgetVarianceAlerted` | Core Compensation | budget_remaining < 5% total hoặc projected exceed | Finance Approver + Comp Admin notified | — |
| E-CC-012 | `MinimumWageViolated` | Core Compensation | Salary < MinWage(workplace_zone) khi create/update | Hard block; change rejected; violation logged | — |
| E-CC-013 | `MinimumWageViolationDetected` | Core Compensation | System scan khi min wage table updated | Workers with violation flagged; HR Admin report | — |
| E-CC-014 | `PayEquityGapDetected` | Core Compensation | PayEquityAnalysis complete với gap > threshold | DEI report generated; Compliance Officer notified | ⭐ USP |
| E-CC-015 | `AICompensationRecommended` | Core Compensation | AI/ML model complete; HR Admin request | Recommendation delivered; adoption tracked | ⭐ USP |
| E-CC-016 | `AIRecommendationOverridden` | Core Compensation | Decision differs from AI suggestion | Reason logged; AI model feedback | ⭐ |
| E-CC-017 | `CompaRatioCalculated` | Core Compensation | Salary change hoặc pay range update | Compa-ratio updated per Worker | — |

### Cluster 2: Calculation Rules Engine

| Event ID | Event Name | Sub-module | Trigger | Outcome | USP? |
|----------|------------|------------|---------|---------|------|
| E-CR-001 | `SIContributionCalculated` | Calculation Rules | Payroll run trigger per period | BHXH/BHYT/BHTN amounts per Worker | — |
| E-CR-002 | `SICapApplied` | Calculation Rules | Salary > 20× min wage(zone) | Contribution capped; log ghi nhận cap reason | — |
| E-CR-003 | `SalaryProrated` | Calculation Rules | Mid-period hire/termination/change | Pro-rated amount calculated; method logged | — |
| E-CR-004 | `CalculationRuleVersioned` | Calculation Rules | HR Admin update rate/formula với effective_date | New version created; old version preserved | — |
| E-CR-005 | `OvertimeCalculated` | Calculation Rules | T&A module provides OT hours | OT pay calculated; taxable item created | — |
| E-CR-006 | `FxRateUpdated` | Calculation Rules | Daily FX provider sync hoặc manual override | New rate effective; previous rate archived | — |
| E-CR-007 | `FxDeltaAlerted` | Calculation Rules | FX rate change >5% trong cycle | Finance workflow triggered (configurable) | — |
| E-CR-008 | `CalculationCompleted` | Calculation Rules | All components calculated for period | Summary ready; Payroll bridge triggered | — |

### Cluster 3: Variable Pay

| Event ID | Event Name | Sub-module | Trigger | Outcome | USP? |
|----------|------------|------------|---------|---------|------|
| E-VP-001 | `BonusPlanConfigured` | Variable Pay | Compensation Admin setup plan | Plan ready; eligible workers defined | — |
| E-VP-002 | `BonusPoolReleased` | Variable Pay | Finance Approver approve company performance | Budget pool open for allocation | — |
| E-VP-003 | `BonusCalculated` | Variable Pay | System calculate per formula_json | Individual bonus amounts; pending Manager review | — |
| E-VP-004 | `BonusApproved` | Variable Pay | Manager/Director approve allocation | Bonus finalized; TaxableItemCreated | — |
| E-VP-005 | `CommissionPlanConfigured` | Variable Pay | Sales Ops setup plan with tiers + quota | Plan active for Sales Workers | — |
| E-VP-006 | `SalesTransactionsImported` | Variable Pay | Sales Ops import CRM data | Transactions ready for commission calc | — |
| E-VP-007 | `CommissionCalculated` | Variable Pay | System process transactions vs plan | Commission amounts per Worker; pending | — |
| E-VP-008 | `RealTimeCommissionCalculated` | Variable Pay | Kafka event from CRM transaction | Dashboard updated < 5 giây | ⭐ USP |
| E-VP-009 | `DisputeSubmitted` | Variable Pay | Sales Rep submit dispute with evidence | Disputed amount frozen; Sales Ops notified | — |
| E-VP-010 | `CommissionDisputeResolved` | Variable Pay | Sales Ops resolve dispute | Frozen amount released or rejected; Worker notified | — |
| E-VP-011 | `EquityGranted` | Variable Pay | Manager grant RSU/Options with approval | Vesting schedule created; Worker notified | — |
| E-VP-012 | `EquityVested` | Variable Pay | Vesting date reached | Taxable event created; TaxableItemCreated | — |

### Cluster 4: Benefits Administration

| Event ID | Event Name | Sub-module | Trigger | Outcome | USP? |
|----------|------------|------------|---------|---------|------|
| E-BA-001 | `BenefitPlanConfigured` | Benefits | HR Admin setup plan with eligibility + carrier | Plan ready for enrollment | — |
| E-BA-002 | `OpenEnrollmentStarted` | Benefits | HR Admin open enrollment period | Workers notified; enrollment portal active | — |
| E-BA-003 | `BenefitElected` | Benefits | Worker complete enrollment selection | Election saved; deduction created | — |
| E-BA-004 | `CarrierDataSynced` | Benefits | EDI 834 sync complete | Carrier has current enrollment data | — |
| E-BA-005 | `CarrierSyncFailed` | Benefits | EDI 834 sync fail (API down, validation error) | HR Admin alerted; configurable retry | — |
| E-BA-006 | `DependentAdded` | Benefits | Worker add dependent via QLE | Dependent pending verification; carrier update triggered | — |
| E-BA-007 | `BenefitEligibilityVerified` | Benefits | Worker status change; eligibility re-evaluated | Worker gains or loses benefit eligibility | — |
| E-BA-008 | `OpenEnrollmentClosed` | Benefits | Period end date reached; HR Admin close | Elections finalized; carrier batch sync | — |
| E-BA-009 | `FlexCreditsAllocated` | Benefits | Worker distribute flex credits | Credits assigned to selected benefits | ⭐ USP |

### Cluster 5: Recognition Programs

| Event ID | Event Name | Sub-module | Trigger | Outcome | USP? |
|----------|------------|------------|---------|---------|------|
| E-REC-001 | `RecognitionProgramConfigured` | Recognition | HR Admin setup program | Program active; Workers notified | — |
| E-REC-002 | `PeerRecognitionSent` | Recognition | Worker send peer recognition | Points transferred; recipient notified | — |
| E-REC-003 | `SocialRecognitionPosted` | Recognition | Worker post to social feed (public) | Post visible on social feed | ⭐ USP |
| E-REC-004 | `PointsRedeemed` | Recognition | Worker redeem points for perk | Points deducted (FIFO); perk fulfilled | — |
| E-REC-005 | `PointsExpired` | Recognition | System detect expired points (FIFO, 12 months) | Expired points removed; Worker notified | — |
| E-REC-006 | `MilestoneDetected` | Recognition | System detect work anniversary, birthday | Auto-recognition triggered (configurable) | — |
| E-REC-007 | `AIRecognitionSuggested` | Recognition | AI detect recognition opportunity | Manager notified with suggestion | ⭐ USP |
| E-REC-008 | `TaxableRecognitionCreated` | Recognition | Perk redemption with monetary value | TaxableItemCreated; bridge to Payroll | — |

### Cluster 6: Offer Management

| Event ID | Event Name | Sub-module | Trigger | Outcome | USP? |
|----------|------------|------------|---------|---------|------|
| E-OM-001 | `OfferCreated` | Offer Mgmt | Hiring Manager create offer with salary/benefits | Offer draft saved; min wage validated | — |
| E-OM-002 | `OfferSubmittedForApproval` | Offer Mgmt | Hiring Manager submit for review | Routed to approver(s) | — |
| E-OM-003 | `OfferApproved` | Offer Mgmt | Director/VP approve offer | Offer ready to send to candidate | — |
| E-OM-004 | `OfferLetterGenerated` | Offer Mgmt | System generate PDF from template + data | PDF ready with branding and merge fields | — |
| E-OM-005 | `OfferSentToCandidate` | Offer Mgmt | HR Admin send via e-signature platform | Candidate notified; deadline set | — |
| E-OM-006 | `OfferAccepted` | Offer Mgmt | Candidate e-sign OR polling confirm | Onboarding trigger; CO module notified | — |
| E-OM-007 | `OfferDeclined` | Offer Mgmt | Candidate click Decline OR deadline expired | Analytics updated (decline reason); TA notified | — |
| E-OM-008 | `CounterOfferRequested` | Offer Mgmt | Candidate request counter terms | Hiring Manager notified; negotiation window opens | — |
| E-OM-009 | `OfferCompetitivenessScored` | Offer Mgmt | AI score offer vs market data | Competitiveness % displayed to Hiring Manager | ⭐ USP |

### Cluster 7: Tax Withholding & Taxable Bridge

| Event ID | Event Name | Sub-module | Trigger | Outcome | USP? |
|----------|------------|------------|---------|---------|------|
| E-TX-001 | `TaxBracketConfigured` | Tax | Tax Admin configure bracket with effective date | New bracket version created (SCD Type 2) | — |
| E-TX-002 | `TaxCalculated` | Tax | Payroll run; taxable income finalized | Withholding amount per Worker | — |
| E-TX-003 | `TaxDeclarationUpdated` | Tax | Worker update self-service tax profile | Tax calculation adjusted next period | — |
| E-TX-004 | `TaxReturnFiled` | Tax | Tax Admin submit to authority | Filing reference number received | — |
| E-TX-005 | `TaxAPIFailed` | Tax | Tax Authority API timeout/error | Alert at 15min; escalate at 1h; file fallback at 2h | — |
| E-TX-006 | `TaxableItemCreated` | Taxable Bridge | Equity vest / perk redemption / benefit in-kind | Item queued for Payroll bridge with idempotency key | — |
| E-TX-007 | `PayrollBridgeProcessed` | Taxable Bridge | TaxableItem + PayComponent + Deduction finalized | Kafka event published to Payroll module | — |
| E-TX-008 | `PayrollBridgeDelayed` | Taxable Bridge | No Payroll ack after 15 minutes | Alert to Payroll Admin + HR Admin; retry | — |
| E-TX-009 | `TaxOptimizationRecommended` | Tax | AI analysis + Worker explicit opt-in | Recommendation displayed with disclaimer | ⭐ USP |

### Cluster 8: Deductions

| Event ID | Event Name | Sub-module | Trigger | Outcome | USP? |
|----------|------------|------------|---------|---------|------|
| E-DED-001 | `DeductionSetup` | Deductions | HR Admin create deduction (loan, garnishment) | Deduction scheduled per payroll cycle | — |
| E-DED-002 | `VoluntaryDeductionElected` | Deductions | Worker self-service election | Deduction active from next cycle | — |
| E-DED-003 | `DeductionsProcessed` | Deductions | Payroll run; priority ordering applied | Net pay finalized; breakdown logged | — |
| E-DED-004 | `InsufficientPayAlerted` | Deductions | Deduction > available pay | Carry-forward applied; HR Admin notified | — |

### Cluster 9: Audit & Compliance

| Event ID | Event Name | Sub-module | Trigger | Outcome | USP? |
|----------|------------|------------|---------|---------|------|
| E-AUD-001 | `AuditRecordCreated` | Audit | Any TR entity change | Immutable record: actor, before, after, timestamp | — |
| E-AUD-002 | `AnomalyDetected` | Audit | Daily scan; change exceeds threshold | Compliance Officer alerted with details | — |
| E-AUD-003 | `ComplianceReportGenerated` | Audit | On-demand or scheduled | Report ready for download or delivery | — |
| E-AUD-004 | `UnauthorizedAccessAttempted` | Audit | User try to modify audit record / exceed permissions | Security log; Compliance Officer alerted | — |
| E-AUD-005 | `LocalComplianceApplied` | Audit | Rule effective date reached; System apply | Country-specific rule activated for scope | — |

---

## Commands (Blue)

### Core Compensation Commands

| Command ID | Command Name | Actor | Triggered By | Events Produced |
|------------|-------------|-------|-------------|-----------------|
| C-CC-001 | `CreateSalaryBasis` | Compensation Administrator | Setup new pay structure | `SalaryStructureCreated` |
| C-CC-002 | `OpenCompensationCycle` | Compensation Administrator | Budget approved; cycle template ready | `CompensationCycleOpened` |
| C-CC-003 | `SubmitMeritRecommendation` | People Manager | Cycle OPEN; performance data available | `MeritRecommendationSubmitted` |
| C-CC-004 | `ApproveCompensation` | Budget Approver (Director/VP) | Proposal routed to approver | `CompensationApproved`, `SalaryHistoryArchived` |
| C-CC-005 | `RejectCompensation` | Budget Approver | Proposal pending; budget/policy constraint | `CompensationRejected` |
| C-CC-006 | `CloseCompensationCycle` | Compensation Administrator | End date reached or manual | `CompensationCycleClosed` |
| C-CC-007 | `SetupPayRange` | Compensation Administrator | Market data available; grade structure ready | `PayRangeUpdated` |
| C-CC-008 | `ValidateMinimumWage` | System | Salary create/update triggered | `MinimumWageViolated` (if breach) |
| C-CC-009 | `TriggerPayEquityAnalysis` | Compensation Manager | Data collection complete; authorized | `PayEquityGapDetected` |
| C-CC-010 | `RequestAICompRecommendation` | HR Administrator | Market data sufficient (or benchmark fallback) | `AICompensationRecommended` |

### Calculation Rules Commands

| Command ID | Command Name | Actor | Triggered By | Events Produced |
|------------|-------------|-------|-------------|-----------------|
| C-CR-001 | `ConfigureCountryRules` | HR Administrator | Country expansion; legal review complete | `CalculationRuleVersioned`, `CountryRulesConfigured` |
| C-CR-002 | `CalculateSIContribution` | System | Payroll run initiated | `SIContributionCalculated`, `SICapApplied` (if cap) |
| C-CR-003 | `ProrateSalary` | System | Mid-period join/leave/change detected | `SalaryProrated` |
| C-CR-004 | `UpdateFxRate` | System | Daily provider sync or manual override | `FxRateUpdated`, `FxDeltaAlerted` (if >5%) |
| C-CR-005 | `VersionCalculationRule` | HR Administrator | Rate/formula change with new effective date | `CalculationRuleVersioned` |

### Variable Pay Commands

| Command ID | Command Name | Actor | Triggered By | Events Produced |
|------------|-------------|-------|-------------|-----------------|
| C-VP-001 | `ConfigureBonusPlan` | Compensation Administrator | Plan design approved | `BonusPlanConfigured` |
| C-VP-002 | `ReleaseBonusPool` | Finance Approver | Company performance confirmed | `BonusPoolReleased` |
| C-VP-003 | `RunBonusCalculation` | Compensation Manager | Pool released; formula configured | `BonusCalculated`, `TaxableItemCreated` |
| C-VP-004 | `ApproveBonus` | People Manager / Budget Approver | Calculation pending review | `BonusApproved` |
| C-VP-005 | `SetupCommissionPlan` | Sales Operations | Sales role identified; design approved | `CommissionPlanConfigured` |
| C-VP-006 | `ImportSalesTransactions` | Sales Operations | CRM month-end close complete | `SalesTransactionsImported` |
| C-VP-007 | `CalculateCommission` | System | Transactions imported; plan active | `CommissionCalculated`, `RealTimeCommissionCalculated` |
| C-VP-008 | `SubmitCommissionDispute` | Worker (Sales Rep) | Disagreement with calculation | `DisputeSubmitted` |
| C-VP-009 | `ResolveCommissionDispute` | Sales Operations | Investigation complete | `CommissionDisputeResolved` |

### Benefits Commands

| Command ID | Command Name | Actor | Triggered By | Events Produced |
|------------|-------------|-------|-------------|-----------------|
| C-BA-001 | `OpenEnrollment` | HR Administrator | Plan year approaching | `OpenEnrollmentStarted` |
| C-BA-002 | `ElectBenefit` | Worker | Enrollment period active; eligible | `BenefitElected`, `DeductionSetup` |
| C-BA-003 | `CloseEnrollment` | HR Administrator | Period end date | `OpenEnrollmentClosed`, `CarrierDataSynced` |
| C-BA-004 | `AddDependent` | Worker | QLE occurred; within 30-day window | `DependentAdded` |
| C-BA-005 | `SyncCarrierData` | System | Enrollment changes pending; API available | `CarrierDataSynced`, `CarrierSyncFailed` |

### Offer Management Commands

| Command ID | Command Name | Actor | Triggered By | Events Produced |
|------------|-------------|-------|-------------|-----------------|
| C-OM-001 | `CreateOffer` | Hiring Manager | Candidate selected; requisition approved | `OfferCreated`, `MinimumWageViolated` (if breach) |
| C-OM-002 | `SubmitOfferApproval` | Hiring Manager | Offer complete; fields validated | `OfferSubmittedForApproval` |
| C-OM-003 | `ApproveOffer` | Budget Approver (Director) | Offer routed; within authority | `OfferApproved`, `OfferLetterGenerated` |
| C-OM-004 | `SendOffer` | HR Administrator | Offer approved; candidate contact ready | `OfferSentToCandidate` |
| C-OM-005 | `AcceptOffer` | Candidate | Offer received; e-signature complete | `OfferAccepted` |
| C-OM-006 | `RequestCounterOffer` | Candidate | Offer received; negotiation desired | `CounterOfferRequested` |

### Tax & Audit Commands

| Command ID | Command Name | Actor | Triggered By | Events Produced |
|------------|-------------|-------|-------------|-----------------|
| C-TX-001 | `ConfigureTaxBracket` | Tax Administrator | Law change; new rates effective | `TaxBracketConfigured`, `CalculationRuleVersioned` |
| C-TX-002 | `CalculateTax` | System | Payroll run; taxable income finalized | `TaxCalculated` |
| C-TX-003 | `FileTaxReturn` | Tax Administrator | Period closed; calculations reconciled | `TaxReturnFiled`, `TaxAPIFailed` (if API down) |
| C-TX-004 | `ProcessPayrollBridge` | System | Calculation completed; Payroll integration active | `PayrollBridgeProcessed`, `PayrollBridgeDelayed` |
| C-TX-005 | `GenerateComplianceReport` | Compliance Officer | On-demand or scheduled | `ComplianceReportGenerated` |

---

## Actors (Yellow)

| Actor | Role trong xTalent | Quyền chính | Sub-modules chính |
|-------|-------------------|-------------|-------------------|
| **HR Administrator** | Quản trị toàn bộ hệ thống TR | CRUD tất cả config; view tất cả data | Tất cả |
| **Compensation Manager** | Thiết kế pay strategy, phân tích equity | Design plans; analyze equity; approve budget | Core Comp, Variable Pay |
| **Compensation Administrator** | Vận hành cycle, cấu hình structure | Run cycles; setup pay ranges | Core Comp, Variable Pay |
| **Benefits Administrator** | Quản lý enrollment, carrier liaison | Setup plans; manage enrollment; carrier contact | Benefits, TR Statement |
| **Payroll Administrator** | Thực thi payroll, reconciliation | Process payroll; manage deductions | Calculation, Tax, Deductions |
| **Tax Administrator** | Cấu hình thuế, khai báo | Configure brackets; file returns | Tax Withholding, Taxable Bridge |
| **Recognition Administrator** | Cấu hình recognition programs | Setup programs; manage catalog | Recognition |
| **People Manager** | Đề xuất tăng lương, ghi nhận team | Propose salary changes; approve bonus; send recognition | Core Comp, Variable Pay, Recognition |
| **Budget Approver (Director/VP)** | Phê duyệt compensation theo ngưỡng | Approve/reject within authority; release budget | Core Comp, Variable Pay, Offer Mgmt |
| **Finance Approver** | Phê duyệt ngân sách và garnishment | Approve budget; authorize garnishments | Core Comp, Benefits, Deductions |
| **Worker (Self-Service)** | Xem và quản lý thông tin cá nhân | View own data; enroll benefits; redeem points; dispute commission | Tất cả |
| **Hiring Manager** | Tuyển dụng và tạo offer | Create offers; submit for approval | Offer Management |
| **Candidate** | Ứng viên nhận offer | Accept/decline/counter offer | Offer Management |
| **Sales Operations** | Quản lý commission plans | Setup plans; import transactions; resolve disputes | Variable Pay (Commission) |
| **Compliance Officer** | Báo cáo compliance, ứng phó audit | Read all; generate compliance reports | Audit, Tax, Benefits |
| **External Auditor** | Kiểm toán độc lập | Read-only within scoped Legal Entity | Audit |
| **System (Automated)** | Automated calculations, validations, notifications | All technical operations | Tất cả |

---

## Hot Spots (Pink) — Còn mở (P2 — Deferred to Implementation)

| ID | Hot Spot | Mức độ mơ hồ | Gợi ý mặc định | Chủ sở hữu |
|----|---------|:------------:|----------------|------------|
| HS-P2-01 | Manager tooltips: hiển thị market rate và compa-ratio chi tiết đến mức nào? | 0.20 | Show compa-ratio + percentile (không absolute numbers trừ khi có quyền) | UX Designer + Comp Manager |
| HS-P2-02 | Worker bonus simulation: cho phép Worker tự simulate bonus trước khi cycle close? | 0.20 | Cho phép simulation (read-only, disclaimer "estimate only") | Product Owner |
| HS-P2-03 | Recognition point expiration: 12 tháng có đúng cho tất cả enterprise? | 0.20 | 12 tháng FIFO default; configurable per enterprise | Recognition Admin |
| HS-P2-04 | Multi-language scope: khi nào support thêm ngôn ngữ (TH, ID, v.v.)? | 0.15 | EN + VI Phase 1; TH + ID Phase 3 | Product Owner |
| HS-P2-05 | Market benchmarking data source: khi nào tích hợp Mercer/Willis? | 0.15 | Manual upload Phase 1; API Phase 2 | Product Owner + IT |
| HS-P2-06 | Notification channels: push notification mobile khi nào? | 0.15 | Email + In-app Phase 1; Mobile push Phase 2 | Product Owner |
| HS-P2-07 | Tax optimization AI opt-in flow: UX cụ thể như thế nào để tránh "financial advice" risk? | 0.20 | Explicit checkbox + disclaimer; legal review required | Tax Admin + Legal |
| HS-P2-08 | Off-cycle bonus approval: simplified fast-track path vs full workflow? | 0.15 | Fast-track path (1 approver) for spot bonus < threshold | Comp Manager |

---

## Domain Timelines

### Timeline 1: Compensation Cycle (Merit Review)

```
Actor: Compensation Administrator
──────────────────────────────────────────────────────────────────────────────

1. [C-CC-007] SetupPayRange
   → E-CC-003: PayRangeUpdated

2. [C-CC-002] OpenCompensationCycle (Budget approved)
   → E-CC-004: CompensationCycleOpened
   → System: notify all People Managers in scope

3. [C-CC-003] SubmitMeritRecommendation (People Manager)
   → E-CC-005: MeritRecommendationSubmitted
   → budget_remaining decreases (tentative)

4a. [C-CC-004] ApproveCompensation (auto if < 5%) OR manual approval
    → E-CC-006: CompensationApproved
    → E-CC-010: SalaryHistoryArchived (SCD Type 2)
    → E-AUD-001: AuditRecordCreated

4b. [C-CC-005] RejectCompensation
    → E-CC-007: CompensationRejected
    → budget_remaining restored

5. SalaryEffectiveDateReached (Cron)
   → E-CC-008: SalaryEffectiveDateReached
   → C-TX-004: ProcessPayrollBridge triggered

6. [C-CC-006] CloseCompensationCycle
   → E-CC-009: CompensationCycleClosed
   → Publish final results to Workers

[Parallel — USP path]
   → C-CC-009: TriggerPayEquityAnalysis
   → E-CC-014: PayEquityGapDetected ⭐
   → C-CC-010: RequestAICompRecommendation
   → E-CC-015: AICompensationRecommended ⭐
```

### Timeline 2: Benefits Enrollment (Open Enrollment)

```
Actor: Benefits Administrator
──────────────────────────────────────────────────────────────────────────────

1. [C-BA-001] OpenEnrollment (HR Admin)
   → E-BA-002: OpenEnrollmentStarted
   → Workers notified via email + in-app

2. [C-BA-002] ElectBenefit (Worker self-service)
   → E-BA-003: BenefitElected
   → DeductionSetup created for premium

3. Verify dependent eligibility (if dependent added)
   → E-BA-006: DependentAdded
   → Verification workflow (configurable: auto/doc/carrier)

4. [C-BA-003] CloseEnrollment (HR Admin or auto on end date)
   → E-BA-008: OpenEnrollmentClosed
   → [C-BA-005] SyncCarrierData triggered

5. [C-BA-005] SyncCarrierData (System)
   → E-BA-004: CarrierDataSynced (success) OR
   → E-BA-005: CarrierSyncFailed (retry/alert)
   → E-AUD-001: AuditRecordCreated

[QLE path — anytime]
   Worker trigger QLE (birth, marriage)
   → E-BA-006: DependentAdded
   → E-BA-004: CarrierDataSynced (effective date = QLE date)
```

### Timeline 3: Variable Pay — Bonus Cycle

```
Actor: Compensation Manager + Finance Approver
──────────────────────────────────────────────────────────────────────────────

1. [C-VP-001] ConfigureBonusPlan (Comp Admin)
   → E-VP-001: BonusPlanConfigured

2. [C-VP-002] ReleaseBonusPool (Finance Approver)
   → E-VP-002: BonusPoolReleased
   → Budget pool open

3. [C-VP-003] RunBonusCalculation (Comp Manager)
   → E-VP-003: BonusCalculated (per Worker, using formula_json)
   → pending People Manager review

4. [C-VP-004] ApproveBonus (People Manager / Director)
   → E-VP-004: BonusApproved
   → E-TX-006: TaxableItemCreated
   → E-AUD-001: AuditRecordCreated

5. C-TX-004: ProcessPayrollBridge (System)
   → E-TX-007: PayrollBridgeProcessed
   → Payroll module receives taxable items
```

### Timeline 4: Commission Calculation (Monthly)

```
Actor: Sales Operations + System
──────────────────────────────────────────────────────────────────────────────

1. [C-VP-005] SetupCommissionPlan (Sales Ops)
   → E-VP-005: CommissionPlanConfigured

2. [C-VP-006] ImportSalesTransactions (Sales Ops, month-end)
   → E-VP-006: SalesTransactionsImported

3. [C-VP-007] CalculateCommission (System)
   → E-VP-007: CommissionCalculated (per Worker, tiered + accelerator)

   [Real-time parallel path — USP]
   CRM transaction → Kafka → System
   → E-VP-008: RealTimeCommissionCalculated ⭐ (< 5 giây)
   → Dashboard updated

4a. No dispute → PayrollBridgeProcessed
    → Worker receives commission in next payroll

4b. [C-VP-008] SubmitCommissionDispute (Worker)
    → E-VP-009: DisputeSubmitted
    → Disputed amount frozen; undisputed amount bridges normally

5. [C-VP-009] ResolveCommissionDispute (Sales Ops)
   → E-VP-010: CommissionDisputeResolved
   → Resolved amount bridges to next payroll
```

### Timeline 5: Audit & Compliance

```
Actor: System (continuous) + Compliance Officer (on-demand)
──────────────────────────────────────────────────────────────────────────────

Continuous capture (every TR entity change):
   Any change → E-AUD-001: AuditRecordCreated
   (Immutable; cannot be modified or deleted)

Daily anomaly scan:
   System → Compare salary changes vs threshold
   → E-AUD-002: AnomalyDetected (if exceeds threshold)
   → Compliance Officer alerted

On-demand compliance report:
   [C-TX-005] GenerateComplianceReport (Compliance Officer)
   → E-AUD-003: ComplianceReportGenerated

External auditor access:
   External Auditor request scoped read-only access
   → HR Admin grants (Legal Entity scoped)
   → Every access logged to E-AUD-001
   → Cannot write, modify, or delete anything

Security violation:
   Any unauthorized modification attempt
   → E-AUD-004: UnauthorizedAccessAttempted
   → Compliance Officer immediate alert
   → Security team notified
```

---

## Domain Event — Sub-module Cross-Reference

| Sub-module | Event Count | Command Count | Key Aggregate |
|------------|------------|---------------|---------------|
| Core Compensation | 17 | 10 | CompensationProposal, SalaryRecord |
| Calculation Rules | 8 | 5 | CalculationRule, ProrationRecord |
| Variable Pay | 12 | 9 | BonusPlan, CommissionPlan, DisputeRecord |
| Benefits | 9 | 5 | BenefitEnrollment, DependentRecord |
| Recognition | 8 | (covered above) | RecognitionProgram, PointBalance |
| Offer Management | 9 | 6 | OfferRecord, OfferTemplate |
| Tax & Taxable Bridge | 9 | 5 | TaxProfile, TaxableItem |
| Deductions | 4 | (covered above) | DeductionSchedule |
| Audit | 5 | 1 | AuditRecord |
| **Total** | **55** | **30** | **9 aggregates** |

---

*Event Storming Catalog Version 1.0.0 — ODSA Step 2 (Reality) Output*
*Business Analyst Agent — 2026-03-26*
