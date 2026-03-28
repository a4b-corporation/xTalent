# Commands and Actors: Total Rewards Event Storming

**Phase**: 3-4 (Capture Commands + Map Actors)
**Domain**: Total Rewards (TR)
**Scope**: Multi-country Southeast Asia (6 countries: VN, TH, ID, SG, MY, PH)
**Innovation Level**: Full Innovation Play
**Date**: 2026-03-20

---

## Commands (🔵)

### Command → Event Mapping

| ID | Command | Actor | Preconditions | Resulting Event | USP? |
|----|---------|-------|---------------|-----------------|------|
| **C001** | ElectBenefit | Employee | Open enrollment active, Eligible employee | BenefitElected | No |
| **C002** | SubmitClaim | Employee | Active benefit enrollment, Incurred expense | ClaimSubmitted | No |
| **C003** | ViewStatement | Employee | Statement generated and available | StatementViewed | No |
| **C004** | UpdateTaxDeclaration | Employee | Tax filing period open | TaxDeclarationUpdated | No |
| **C005** | RedeemPoints | Employee | Sufficient point balance, Item in stock | PointsRedeemed | No |
| **C006** | SendPeerRecognition | Employee | Within monthly giving limit | PeerRecognitionSent | No |
| **C007** | ⭐ PostToSocialFeed | Employee | Recognition sent, Public visibility enabled | SocialRecognitionPosted | Yes |
| **C008** | ViewCompensationHistory | Employee | Active employment | CompensationHistoryViewed | No |
| **C009** | SubmitDispute | Employee | Commission calculated, Disagreement exists | DisputeSubmitted | No |
| **C010** | ApproveBonus | Manager | Bonus allocation pending, Within approval authority | BonusApproved | No |
| **C011** | ReviewSalary | Manager | Compensation cycle open, Direct reports exist | SalaryReviewed | No |
| **C012** | GrantEquity | Manager | Equity plan available, Approval obtained | EquityGranted | No |
| **C013** | ApprovePromotion | Manager | Promotion recommended, Budget available | PromotionApproved | No |
| **C014** | SubmitMeritRecommendation | Manager | Performance rating available, Cycle open | MeritRecommendationSubmitted | No |
| **C015** | AllocateBudget | Manager | Budget pool available, Authority threshold met | BudgetAllocated | No |
| **C016** | ApproveClaim | Manager | Claim submitted by report, Documentation complete | ClaimApproved | No |
| **C017** | SendTeamRecognition | Manager | Manager budget available, Team member identified | TeamRecognitionSent | No |
| **C018** | ⭐ AllocateFlexCredits | Manager | Flex credit pool available, Policy allows | FlexCreditsAllocated | Yes |
| **C019** | ConfigurePlan | HR Admin | Plan design approved, System access granted | PlanConfigured | No |
| **C020** | RunCompCycle | HR Admin | Budget allocated, Cycle template ready | CompensationCycleStarted | No |
| **C021** | AdjustTax | HR Admin | Tax configuration change required, Approval obtained | TaxAdjusted | No |
| **C022** | SetupBenefitPlan | HR Admin | Carrier contract executed, Open enrollment approaching | BenefitPlanSetup | No |
| **C023** | ConfigureRecognitionProgram | HR Admin | Program design approved, Points budget defined | RecognitionProgramConfigured | No |
| **C024** | CreateOfferTemplate | HR Admin | Legal review complete, Country compliance validated | OfferTemplateCreated | No |
| **C025** | GenerateStatements | HR Admin | Data collection complete, Statement period closed | StatementsGenerated | No |
| **C026** | ExportComplianceReport | HR Admin | Reporting period closed, Data validated | ComplianceReportExported | No |
| **C027** | ⭐ RequestAICompRecommendation | HR Admin | AI/ML model trained, Historical data available | AIRecommendationReceived | Yes |
| **C028** | CalculateTax | System | Payroll run initiated, Employee tax profiles complete | TaxCalculated | No |
| **C029** | ProcessPayrollBridge | System | Compensation finalized, Payroll integration active | PayrollBridgeProcessed | No |
| **C030** | RecalculateSI | System | SI law change effective, Employee data updated | SIRecalculated | No |
| **C031** | ApplyFxDelta | System | Multi-currency assignment, FX rate updated | FxDeltaApplied | No |
| **C032** | SyncCarrierData | System | Carrier API available, Enrollment changes pending | CarrierDataSynced | No |
| **C033** | DetectMilestone | System | Employee anniversary/birthday today, Milestone config active | MilestoneDetected | No |
| **C034** | SendNotification | System | Event triggered, User preference allows | NotificationSent | No |
| **C035** | ExpirePoints | System | Point expiration date reached, FIFO logic applied | PointsExpired | No |
| **C036** | ApproveBudgetAllocation | Finance | Budget request submitted, Within authority | BudgetAllocationApproved | No |
| **C037** | ReleaseBonusPool | Finance | Bonus cycle approved, Company performance confirmed | BonusPoolReleased | No |
| **C038** | AuthorizeGarnishment | Finance | Court order received, Legal review complete | GarnishmentAuthorized | No |
| **C039** | ApproveHighValueAward | Finance | Award exceeds manager limit, Business justification provided | HighValueAwardApproved | No |
| **C040** | UpdateFxRate | System | FX provider API available, Daily rate fetch triggered | FxRateUpdated | No |
| **C041** | ConfigureCountryRules | HR Admin | Country expansion planned, Legal review complete | CountryRulesConfigured | No |
| **C042** | ApplyLocalCompliance | System | Employee in jurisdiction, Rule effective date reached | LocalComplianceApplied | No |
| **C043** | ConsolidateRegionalReport | System | All country data collected, Reporting period closed | RegionalReportConsolidated | No |
| **C044** | ⭐ TriggerPayEquityAnalysis | Comp Analyst | Data collection complete, Analysis authorized | PayEquityAnalysisTriggered | Yes |
| **C045** | CreateOffer | Hiring Manager | Requisition approved, Candidate selected | OfferCreated | No |
| **C046** | SubmitOfferApproval | Hiring Manager | Offer complete, All fields validated | OfferSubmittedForApproval | No |
| **C047** | ApproveOffer | Director/VP | Offer routed, Within approval authority | OfferApproved | No |
| **C048** | SendOffer | HR Admin | Offer approved, Candidate contact verified | OfferSent | No |
| **C049** | AcceptOffer | Candidate | Offer received, Before expiry deadline | OfferAccepted | No |
| **C050** | DeclineOffer | Candidate | Offer received, Decision made | OfferDeclined | No |
| **C051** | RequestCounterOffer | Candidate | Offer received, Negotiation desired | CounterOfferRequested | No |
| **C052** | SubmitCounterOffer | Hiring Manager | Counter-offer requested, Revised terms ready | CounterOfferSubmitted | No |
| **C053** | ExtendOfferDeadline | HR Admin | Before original expiry, Candidate requested extension | OfferDeadlineExtended | No |
| **C054** | WithdrawOffer | HR Director | Offer not accepted, Business reason documented | OfferWithdrawn | No |
| **C055** | GenerateOfferLetter | System | Offer approved, Template selected | OfferLetterGenerated | No |
| **C056** | SetupCommissionPlan | Sales Ops | Sales role identified, Compensation design approved | CommissionPlanSetup | No |
| **C057** | ImportSalesTransactions | Sales Ops | CRM/sales data available, Month-end close complete | SalesTransactionsImported | No |
| **C058** | CalculateCommission | System | Transactions imported, Commission plan active | CommissionCalculated | No |
| **C059** | ApproveCommissionDispute | Sales Ops | Dispute submitted, Investigation complete | CommissionDisputeApproved | No |
| **C060** | SetupDeduction | HR Admin | Deduction type configured, Employee consent obtained | DeductionSetup | No |
| **C061** | RequestLoan | Employee | Loan program available, Eligibility confirmed | LoanRequested | No |
| **C062** | ApproveLoan | Finance | Loan request submitted, Credit check complete | LoanApproved | No |
| **C063** | ProcessLoanRepayment | System | Payroll run active, Amortization schedule exists | LoanRepaymentProcessed | No |
| **C064** | SetupGarnishment | HR Admin | Court order received, Employee identified | GarnishmentSetup | No |
| **C065** | ProcessGarnishmentRemittance | System | Garnishment active, Payroll run initiated | GarnishmentRemitted | No |
| **C066** | ElectVoluntaryDeduction | Employee | Deduction type available, Enrollment window open | VoluntaryDeductionElected | No |
| **C067** | GeneratePayrollFile | System | Compensation finalized, Payroll integration configured | PayrollFileGenerated | No |
| **C068** | ConfigureTaxBracket | Tax Admin | Tax law change effective, Rate table approved | TaxBracketConfigured | No |
| **C069** | FileTaxReturn | Tax Admin | Tax period closed, Calculations reconciled | TaxReturnFiled | No |
| **C070** | ReconcileTaxWithholding | Payroll Admin | Payroll period closed, Tax authority statement received | TaxWithholdingReconciled | No |
| **C071** | RequestTaxOptimization | Employee | AI/ML available, Profile data complete | TaxOptimizationRequested | No |
| **C072** | ConfigureApprovalThreshold | HR Admin | Delegation of authority updated, System config needed | ApprovalThresholdConfigured | No |
| **C073** | SetupPayRange | Comp Admin | Market data available, Grade structure approved | PayRangeSetup | No |
| **C074** | AssignSalary | HR Admin | Employee hired/changed, Grade assigned | SalaryAssigned | No |
| **C075** | AdjustSalary | Manager | Compensation cycle open, Budget available | SalaryAdjusted | No |
| **C076** | OpenEnrollment | HR Admin | Plan year approaching, Communication ready | OpenEnrollmentStarted | No |
| **C077** | CloseEnrollment | HR Admin | Enrollment period ended, Carrier submission deadline | OpenEnrollmentClosed | No |
| **C078** | AddDependent | Employee | Qualifying life event, Dependent eligibility confirmed | DependentAdded | No |
| **C079** | RemoveDependent | Employee | Dependent no longer eligible, Life event occurred | DependentRemoved | No |
| **C080** | VerifyBenefitEligibility | System | Employee status change, Rule evaluation triggered | BenefitEligibilityVerified | No |

---

## Actors (🟡)

### Human Actors

| Actor | Type | Commands Issued | Events Responded To | Countries |
|-------|------|-----------------|---------------------|-----------|
| **Employee** | Primary User | ElectBenefit, SubmitClaim, ViewStatement, UpdateTaxDeclaration, RedeemPoints, SendPeerRecognition, ViewCompensationHistory, SubmitDispute, RequestLoan, ElectVoluntaryDeduction, AddDependent, RemoveDependent | StatementGenerated, BonusCalculated, CommissionCalculated, ClaimProcessed, RecognitionReceived, MilestoneCelebrated, LoanApproved, PointsDeposited | All (6) |
| **People Manager** | Primary User | ApproveBonus, ReviewSalary, GrantEquity, ApprovePromotion, SubmitMeritRecommendation, AllocateBudget, ApproveClaim, SendTeamRecognition, AllocateFlexCredits | BudgetAllocated, CycleStarted, ApprovalRequested, TeamMemberAdded | All (6) |
| **HR Administrator** | Power User | ConfigurePlan, RunCompCycle, AdjustTax, SetupBenefitPlan, ConfigureRecognitionProgram, CreateOfferTemplate, GenerateStatements, ExportComplianceReport, SetupDeduction, SetupGarnishment, ConfigureApprovalThreshold, OpenEnrollment, CloseEnrollment | PlanConfigured, CycleCompleted, ComplianceDeadlineApproaching, EnrollmentDeadlineReached | All (6) |
| **Compensation Analyst** | Specialist | TriggerPayEquityAnalysis, SetupPayRange, RequestAICompRecommendation | PayEquityReportGenerated, MarketDataUpdated, BudgetUtilizationAlert | All (6) |
| **Benefits Administrator** | Specialist | SetupBenefitPlan, ApproveClaim, SyncCarrierData | EnrollmentComplete, CarrierReconciliationDue, ClaimDisputed | All (6) |
| **Tax Administrator** | Specialist | ConfigureTaxBracket, AdjustTax, FileTaxReturn, ReconcileTaxWithholding | TaxLawChanged, FilingDeadlineApproaching, ReconciliationVariance | All (6) |
| **Payroll Administrator** | Operational | ProcessPayrollBridge, ReconcileTaxWithholding, GeneratePayrollFile | PayrollReconciliationComplete, CalculationErrorDetected, RemittanceDue | All (6) |
| **Finance Manager** | Decision Maker | ApproveBudgetAllocation, ReleaseBonusPool, AuthorizeGarnishment, ApproveHighValueAward, ApproveLoan | BudgetRequestPending, BonusCycleComplete, GarnishmentOrderReceived | All (6) |
| **Budget Approver** (Director/VP) | Decision Maker | ApproveBonus, ApproveOffer, ApproveHighValueAward | ApprovalRequestReceived, BudgetThresholdExceeded | All (6) |
| **Hiring Manager** | Requester | CreateOffer, SubmitOfferApproval, SubmitCounterOffer | OfferApproved, OfferAccepted, CounterOfferRequested | All (6) |
| **Sales Operations Manager** | Specialist | SetupCommissionPlan, ImportSalesTransactions, ApproveCommissionDispute | CommissionCalculationComplete, DisputeSubmitted, QuotaChanged | All (6) |
| **Offer Administrator** | Specialist | CreateOfferTemplate, SendOffer, ExtendOfferDeadline, WithdrawOffer | OfferCreated, ApprovalComplete, OfferExpiring | All (6) |
| **Recognition Administrator** | Specialist | ConfigureRecognitionProgram, ManagePerkCatalog | ProgramUtilizationLow, PointExpirationDue, CatalogLowStock | All (6) |
| **Compliance Officer** | Oversight | ExportComplianceReport, VerifyBenefitEligibility | ComplianceDeadlineApproaching, AuditRequestReceived, RegulatoryChange | All (6) |
| **External Auditor** | External | (Read-only audit access) | AuditEngagementInitiated, RecordsRequested | All (6) |
| **Beneficiary** | External | (Receives garnishment payments) | GarnishmentRemitted | All (6) |
| **Dependent** | External | (Covered under benefits) | BenefitEligibilityChanged | All (6) |
| **Candidate** | External | AcceptOffer, DeclineOffer, RequestCounterOffer | OfferSent, OfferExpiring | All (6) |

### Multi-Country Actor Considerations

| Actor | Country-Specific Variations | Notes |
|-------|----------------------------|-------|
| **Local Compliance Officer** | Per country (VN, TH, ID, SG, MY, PH) | Each country may have dedicated compliance officer for local regulations |
| **Tax Administrator** | Country-specific tax knowledge | Vietnam PIT, Singapore PCB, Malaysia PCB, Thailand PND, Philippines BIR, Indonesia PPh |
| **Benefits Administrator** | Country-specific carrier relationships | VN: BHXH/BHYT/BHTN, SG: CPF, MY: EPF/SOCSO, PH: SSS/PhilHealth, ID: BPJS, TH: Provident Fund |
| **HR Administrator** | Country-level and Regional-level roles | Some orgs have country HR + regional HR for cross-border coordination |
| **Budget Approver** | Legal entity-specific authority | Approval thresholds may vary by legal entity size and country |

---

### System Actors

| Actor | Type | Integration Pattern | SLA | Commands Handled |
|-------|------|---------------------|-----|------------------|
| **Payroll Gateway** | External | Real-time API + Batch File | < 5 min for API, < 1 hour for batch | ProcessPayrollBridge, GeneratePayrollFile |
| **Tax Authority API** | External | API / File Upload | Per regulation (varies by country) | FileTaxReturn, ReconcileTaxWithholding |
| **Insurance Provider** | External | API + EDI File | < 24 hours for enrollment sync | SyncCarrierData, SubmitClaim |
| **Benefits Carrier** | External | Batch File (Daily) | End of day processing | SyncCarrierData, ElectBenefit |
| **Stock Plan Administrator** | External | Real-time API | < 1 hour for grant sync | GrantEquity |
| **E-Signature Provider** (DocuSign) | External | OAuth + REST API | < 15 min for signature status | SendOffer, AcceptOffer |
| **Payment Gateway** | External | Real-time API | < 5 min for transaction | RedeemPoints, ProcessGarnishmentRemittance |
| **Bank** | External | Batch File (Daily) | End of day for remittance | ProcessGarnishmentRemittance, ReleaseBonusPool |
| **CRM System** (Salesforce, HubSpot) | External | API + Webhook | < 1 hour for transaction sync | ImportSalesTransactions |
| **Email Service** (SendGrid, SES) | External | REST API | < 1 min for delivery | SendNotification, SendOffer |
| **SMS Service** | External | REST API | < 30 seconds for delivery | SendNotification |
| **Currency FX Provider** (OANDA, XE) | External | Daily Batch API | Daily at market close | UpdateFxRate |
| **Recognition Vendor** | External | API | < 48 hours for fulfillment | RedeemPoints |
| **Core HR System** | Internal | REST API | < 5 min for data sync | (Provides employee master data) |
| **Performance Management** | Internal | REST API | < 1 hour for rating sync | (Provides performance ratings) |
| **Time & Absence System** | Internal | REST API + Batch | Daily for hours data | (Provides overtime, attendance) |
| **Finance/ERP System** | Internal | REST API + Batch | Daily for budget, GL | (Provides budget guidelines) |
| **Audit Log Service** | Internal | Event-Driven | Real-time | (Records all transactions) |
| **Notification Service** | Internal | Event-Driven + Queue | < 1 min for delivery | SendNotification |
| **Calculation Engine** | Internal | In-Memory Calculation | < 1 second | CalculateTax, CalculateCommission, RecalculateSI |
| **AI/ML Recommendation Engine** | Internal | Batch + Real-time API | < 5 min for recommendation | RequestAICompRecommendation, RequestTaxOptimization |
| **Document Storage** (S3, Blob) | Internal | REST API | < 1 second | GenerateOfferLetter, GenerateStatements |

---

### Time Actors

| Actor | Trigger | Events Triggered | Frequency | Country Variations |
|-------|---------|------------------|-----------|-------------------|
| **MonthEnd** | Last day of month | SIContributionUpdated, TaxCalculated, CommissionCalculated, BudgetUtilizationReport | Monthly | All countries |
| **QuarterEnd** | Last day of quarter | RegionalReportConsolidated, PayEquityAnalysis, BudgetReview | Quarterly | All countries |
| **FiscalYearClose** | Company fiscal year end (varies) | AnnualStatementsGenerated, TaxYearClosed, BonusCycleClosed, CarryoverProcessed | Annually | All (date varies) |
| **OpenEnrollmentPeriod** | 60 days before plan year | EnrollmentDeadlineApproaching, PlanYearRollover, CarrierSubmission | Annually | All (timing varies) |
| **PayPeriodEnd** | Per payroll schedule (bi-weekly, monthly) | PayrollFileGenerated, TaxWithheld, DeductionsProcessed | Per pay period | All |
| **TaxFilingDeadline** | Per country regulation | TaxReturnFiled, PenaltiesAssessed (if late) | Monthly/Annually | VN: 20th of month, SG: 15th, MY: 15th, TH: 7th, PH: 10th, ID: 10th |
| **SIContributionDue** | Per country SI regulation | SIContributionRemitted, PenaltyCalculated (if late) | Monthly | VN: Last day of month, others vary |
| **BonusCycleStart** | Per company policy (typically Q4) | BonusCycleOpened, ManagerNotificationsSent, BudgetPoolsActivated | Annually | All |
| **PerformanceReviewCycle** | Per company policy (typically Q1/Q4) | PerformanceRatingsDue, MeritCycleTriggered | Annually or Semi-annually | All |
| **13thMonthPayable** | Before Tet (VN) / Dec 24 (PH) | ThirteenthMonthCalculated, PaymentScheduled | Annually | VN: Before Tet, PH: Dec 24, ID: Before religious holiday |
| **THRPayable** (Indonesia) | Before religious holiday | THRCalculated, PaymentScheduled | Annually | ID only |
| **PointExpiration** | 12 months from earning (FIFO) | PointsExpired, ExpirationReminderSent | Daily (FIFO) | All |
| **ProbationEnd** | 60-180 days from hire (country-specific) | ProbationMilestoneDetected, BenefitEligibilityChanged | Per employee | VN: 60 days max, TH: 119 days, MY/PH: 180 days |
| **OfferExpiry** | Per offer deadline (typically 5-14 days) | OfferExpired, ReminderSent | Per offer | All |
| **LoanRepaymentDue** | Per amortization schedule | LoanRepaymentProcessed, LateFeeAssessed (if insufficient) | Per pay period | All |
| **GarnishmentRemittanceDue** | Per court order / regulation | GarnishmentRemitted, ComplianceReportGenerated | Per pay period | All |
| **CarrierReconciliation** | Monthly / per carrier agreement | CarrierDataSynced, VarianceReportGenerated | Monthly | All |
| **FXRateRefresh** | Daily at market close | FxRateUpdated, FxDeltaApplied | Daily | All |

---

## USP Innovation Commands (⭐)

The following commands represent **competitive differentiators** for xTalent Total Rewards:

| ID | USP Command | Actor | Business Value | Phase |
|----|-------------|-------|----------------|-------|
| **USP-01** | ⭐ PostToSocialFeed | Employee | LinkedIn-style internal recognition feed increases engagement by 40% | Phase 2 |
| **USP-02** | ⭐ RequestAICompRecommendation | HR Admin, Manager | AI-powered compensation recommendations reduce bias, improve equity | Phase 2 |
| **USP-03** | ⭐ AllocateFlexCredits | Manager | Flexible credit allocation for personalized rewards | Phase 2 |
| **USP-04** | ⭐ TriggerPayEquityAnalysis | Comp Analyst | Real-time pay equity gap detection across demographics | Phase 2 |
| **USP-05** | ⭐ CalculateRealTimeCommission | System | Real-time commission calculation vs. 30-60 day lag (industry standard) | Phase 2 |

---

## Actor Command Authorization Matrix

| Actor | Employee | Manager | HR Admin | Comp Analyst | Finance | Tax Admin | System |
|-------|----------|---------|----------|--------------|---------|-----------|--------|
| ElectBenefit | ✅ Own | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| SubmitClaim | ✅ Own | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| ApproveBonus | ❌ | ✅ Team | ✅ All | ❌ | ✅ High-value | ❌ | ❌ |
| ConfigurePlan | ❌ | ❌ | ✅ | ✅ Design | ✅ Budget | ❌ | ❌ |
| CalculateTax | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ Config | ✅ Execute |
| GenerateStatements | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ✅ Auto |
| AllocateBudget | ❌ | ✅ Team | ✅ All | ✅ Recommend | ✅ Approve | ❌ | ❌ |
| PostToSocialFeed | ✅ Own | ✅ Own | ✅ Official | ❌ | ❌ | ❌ | ❌ |

---

## Event Summary by Category

### Compensation Events
- SalaryAssigned, SalaryAdjusted, BonusCalculated, BonusApproved, BonusPaid, CommissionCalculated, CommissionPaid, EquityGranted, EquityVested, MeritIncreaseApplied, PromotionProcessed

### Benefits Events
- BenefitElected, BenefitEnrollmentCompleted, ClaimSubmitted, ClaimApproved, ClaimPaid, PremiumRemitted, SIContributionCalculated, SIContributionRemitted

### Recognition Events
- PeerRecognitionSent, ManagerAwardGiven, MilestoneCelebrated, PointsDeposited, PointsRedeemed, PointsExpired, SocialRecognitionPosted

### Offer Events
- OfferCreated, OfferSent, OfferAccepted, OfferDeclined, OfferWithdrawn, OfferExpired, CounterOfferSubmitted, EmployeeRecordCreated

### Tax Events
- TaxCalculated, TaxWithheld, TaxReturnFiled, TaxRefundDue, TaxPenaltyAssessed, TaxDeclarationUpdated

### Deduction Events
- LoanRequested, LoanApproved, LoanRepaid, GarnishmentSetup, GarnishmentRemitted, VoluntaryDeductionElected

### Compliance Events
- ComplianceReportGenerated, AuditTrailRecorded, RegulatoryChangeApplied, FilingDeadlineMet, FilingOverdue

---

## Multi-Country Event Variations

| Event | Vietnam | Thailand | Indonesia | Singapore | Malaysia | Philippines |
|-------|---------|----------|-----------|-----------|----------|-------------|
| **SIContributionCalculated** | BHXH 17.5%+8%, BHYT 3%+1.5%, BHTN 1%+1% | Social Security 5%+5% | BPJS 4%+2% | CPF 17%+20% | EPF 12%+13%, SOCSO | SSS, PhilHealth, Pag-IBIG |
| **TaxCalculated** | Progressive 5-35%, Personal 11M deduction | Progressive 5-35% | Progressive 5-35% | Progressive 0-22% | PCB Progressive 0-30% | Progressive 0-35% |
| **ThirteenthMonthCalculated** | Before Tet (customary) | N/A | THR (before religious holiday) | N/A | N/A | By Dec 24 (PD 851) |
| **BenefitElected** | VND minimum wage compliance | Provident Fund optional | BPJS mandatory | CPF mandatory | EPF/SOCSO mandatory | SSS/PhilHealth mandatory |

---

**Document Version**: 1.0.0
**Status**: DRAFT
**Created**: 2026-03-20
**Next Phase**: Phase 5 (Hot Spots), Phase 6 (Timelines), Phase 7 (Discovery Questions)
