# Event Storming Session Brief: Total Rewards

**Document Type**: Event Storming Session Brief
**Domain**: Total Rewards (TR)
**Geographic Scope**: 6 SEA Countries (VN, TH, ID, SG, MY, PH)
**Innovation Level**: Full Innovation Play
**Timeline**: Fast Track

---

## Business Context

| Attribute | Value |
|-----------|-------|
| **Domain/Module** | Total Rewards (TR) |
| **Geographic Scope** | 6 SEA countries: Vietnam, Thailand, Indonesia, Singapore, Malaysia, Philippines |
| **Total Employees** | 15,000+ employees across 6 countries |
| **Innovation Level** | Full Innovation Play |
| **Session Duration** | Estimated 3-4 days |
| **Countries Breakdown** | VN: 5,000+ | TH: 2,000+ | ID: 3,000+ | SG: 1,500+ | MY: 1,000+ | PH: 2,500+ |

### Key Regulatory Bodies by Country

| Country | Regulatory Body | Key Regulations |
|---------|-----------------|-----------------|
| Vietnam | Ministry of Labor, VNSI | Labor Code 2019, SI Law 2024 (effective July 2025) |
| Thailand | Ministry of Labor | Labor Protection Act, Revenue Code |
| Indonesia | Ministry of Manpower, BPJS | Manpower Act 13/2003, BPJS |
| Singapore | MOM, IRAS, CPF | Employment Act, CPF Act, PDPA |
| Malaysia | SOCSO, EPF, LHDN | Employment Act 1955, PCB |
| Philippines | DOLE, BIR, SSS | Labor Code, PD 851 (13th Month) |

---

## Preliminary Actors (🟡)

### Primary Human Actors

| Actor | Type | Primary/Secondary | Notes |
|-------|------|-------------------|-------|
| Employee | Human | Primary | Self-service user; views compensation, benefits, recognition; manages tax profile |
| Manager (People Manager) | Human | Primary | Team compensation approval; submits proposals; recognizes team members; views team analytics |
| HR Administrator | Human | Primary | System configuration; employee support; compliance; full TR access |
| Compensation Manager | Human | Primary | Budget allocation; plan design; pay equity analysis; compensation strategy |
| Compensation Administrator | Human | Primary | Salary structures; compensation cycles; eligibility management |
| Benefits Administrator | Human | Primary | Enrollment management; carrier liaison; benefits compliance |
| Payroll Administrator | Human | Primary | Payroll execution; tax calculation triggers; reconciliation |
| Tax Administrator | Human | Primary | Tax configuration; filings; compliance; multi-country tax management |
| Recognition Administrator | Human | Secondary | Program configuration; catalog management; recognition analytics |
| HR Director | Human | Primary | Strategic oversight; policy configuration; executive approvals |
| Budget Approver (Director/VP/CFO) | Human | Primary | Approves allocations based on authority thresholds |
| Finance Approver | Human | Secondary | Budget oversight; high-value approval; finance compliance |
| Compliance Officer | Human | Secondary | Generate reports; respond to audits; compliance monitoring |
| External Auditor | Human | Secondary | Compliance review; audit trail access (read-only) |
| Hiring Manager | Human | Secondary | Initiates employment offers; customizes packages |
| Recruiter | Human | Secondary | Coordinates offer process; candidate communication |
| Candidate | Human | Secondary | External user; reviews and accepts/declines offers |

### Secondary/Support Actors

| Actor | Type | Primary/Secondary | Notes |
|-------|------|-------------------|-------|
| Sales Operations Manager | Human | Secondary | Commission plan setup; quota management; dispute resolution |
| HR Business Partner | Human | Secondary | Advisory; eligibility validation; policy guidance |
| System Administrator | Human | Secondary | Audit configuration; retention policies; system health |
| Security Administrator | Human | Secondary | Monitor access patterns; investigate suspicious activity |
| Finance Director | Human | Secondary | Budget guidelines; cost allocation approval |

### System/Automated Actors

| Actor | Type | Primary/Secondary | Notes |
|-------|------|-------------------|-------|
| System (Automated) | System | Primary | Validation; notifications; milestone detection; scheduled jobs |
| ATS/Talent Acquisition | External System | Secondary | Provides candidate data; job requisitions |
| Core HR System | External System | Primary | Employee master data; organizational hierarchy; job/grade data |
| Performance Management | External System | Secondary | Performance ratings; goal achievements |
| Time & Absence System | External System | Secondary | Overtime hours; attendance data |
| Finance/ERP System | External System | Secondary | Budget guidelines; cost centers; FX rates |
| Payroll Module | External System | Primary | Receives compensation data; executes payments |
| Benefits Carriers | External System | Secondary | Enrollment; claims; eligibility (API + File-based) |
| Tax Authorities | External System | Secondary | e-Filing; compliance reporting |
| E-Signature Provider | External System | Secondary | Offer letter signatures (DocuSign/Adobe Sign) |
| Recognition Vendors | External System | Secondary | Perk fulfillment; reward delivery |
| Stock Plan Administrator | External System | Secondary | Equity grant data; vesting information |
| Currency FX Provider | External System | Secondary | Daily exchange rates |
| CRM System | External System | Secondary | Sales transaction data for commissions |

---

## Preliminary Events (🟠)

### Compensation Events

| Event | Cluster | USP? | Confidence | Source BRD |
|-------|---------|------|------------|------------|
| SalaryReviewed | Compensation | No | High | 01-Core Compensation |
| BonusCalculated | Compensation | No | High | 03-Variable Pay |
| GradeUpdated | Compensation | No | High | 01-Core Compensation |
| PayRangeAdjusted | Compensation | No | High | 01-Core Compensation |
| CompensationCycleStarted | Compensation | No | High | 01-Core Compensation |
| CompensationCycleCompleted | Compensation | No | High | 01-Core Compensation |
| MeritIncreaseApproved | Compensation | No | High | 01-Core Compensation |
| PromotionProcessed | Compensation | No | High | 01-Core Compensation |
| MarketAdjustmentApplied | Compensation | No | High | 01-Core Compensation |
| BudgetAllocated | Compensation | No | High | 01-Core Compensation |
| BudgetReallocationRequested | Compensation | No | Medium | 01-Core Compensation |
| CompaRatioCalculated | Compensation | No | High | 01-Core Compensation |
| SalaryAssignmentCreated | Compensation | No | High | 01-Core Compensation |
| MinimumWageValidated | Compensation | No | High | 01-Core Compensation |
| PayEquityAnalysisCompleted | Compensation | No | Medium | 01-Core Compensation |
| GradeLadderUpdated | Compensation | No | High | 01-Core Compensation |
| CompensationProposalSubmitted | Compensation | No | High | 01-Core Compensation |
| CompensationApproved | Compensation | No | High | 01-Core Compensation |
| CompensationRejected | Compensation | No | High | 01-Core Compensation |
| OffCycleBonusApproved | Compensation | No | Medium | 03-Variable Pay |
| CommissionCalculated | Compensation | No | High | 03-Variable Pay |
| CommissionTierApplied | Compensation | No | High | 03-Variable Pay |
| QuotaAssigned | Compensation | No | High | 03-Variable Pay |
| SalesTransactionImported | Compensation | No | High | 03-Variable Pay |
| CommissionDisputeRaised | Compensation | No | Medium | 03-Variable Pay |
| CommissionDisputeResolved | Compensation | No | Medium | 03-Variable Pay |
| BudgetPoolCreated | Compensation | No | High | 03-Variable Pay |
| BudgetUtilizationTracked | Compensation | No | High | 03-Variable Pay |
| STIBonusCalculated | Compensation | No | High | 03-Variable Pay |
| LTIBonusCalculated | Compensation | No | Medium | 03-Variable Pay |
| ThirteenthMonthCalculated | Compensation | No | High | 03-Variable Pay |
| THRCalculated | Compensation | No | High | 03-Variable Pay |
| BonusPlanCreated | Compensation | No | High | 03-Variable Pay |
| BonusCycleOpened | Compensation | No | High | 03-Variable Pay |
| BonusAllocated | Compensation | No | High | 03-Variable Pay |

### Benefits Events

| Event | Cluster | USP? | Confidence | Source BRD |
|-------|---------|------|------------|------------|
| EnrollmentCompleted | Benefits | No | High | 04-Benefits |
| BenefitClaimSubmitted | Benefits | No | High | 04-Benefits |
| ClaimApproved | Benefits | No | High | 04-Benefits |
| ClaimRejected | Benefits | No | High | 04-Benefits |
| LifeEventRecorded | Benefits | No | High | 04-Benefits |
| EligibilityVerified | Benefits | No | High | 04-Benefits |
| PremiumCalculated | Benefits | No | High | 04-Benefits |
| CarrierSyncCompleted | Benefits | No | Medium | 04-Benefits |
| SIContributionCalculated | Benefits | No | High | 02-Calculation Rules |
| BenefitEnrollmentChanged | Benefits | No | High | 04-Benefits |
| OpenEnrollmentStarted | Benefits | No | High | 04-Benefits |
| OpenEnrollmentCompleted | Benefits | No | High | 04-Benefits |
| DependentAdded | Benefits | No | High | 04-Benefits |
| DependentRemoved | Benefits | No | High | 04-Benefits |
| CoverageLevelChanged | Benefits | No | High | 04-Benefits |
| BeneficiaryDesignated | Benefits | No | High | 04-Benefits |
| WaiverSubmitted | Benefits | No | Medium | 04-Benefits |
| COBRAEventTriggered | Benefits | No | Low | 04-Benefits |
| RetirementContributionCalculated | Benefits | No | High | 04-Benefits |
| HSAContributionMade | Benefits | No | Medium | 04-Benefits |

### Recognition Events

| Event | Cluster | USP? | Confidence | Source BRD |
|-------|---------|------|------------|------------|
| PointsAwarded | Recognition | No | High | 05-Recognition |
| RewardRedeemed | Recognition | No | High | 05-Recognition |
| RecognitionGiven | Recognition | No | High | 05-Recognition |
| MilestoneCelebrated | Recognition | No | High | 05-Recognition |
| PeerRecognitionSent | Recognition | No | High | 05-Recognition |
| ManagerAwardGiven | Recognition | No | High | 05-Recognition |
| PerkRedeemed | Recognition | No | High | 05-Recognition |
| PointBalanceExpired | Recognition | No | High | 05-Recognition |
| ⭐ SocialRecognitionPosted | Recognition | **Yes** | Medium | 05-Recognition |
| RecognitionLiked | Recognition | No | Medium | 05-Recognition |
| RecognitionCommented | Recognition | No | Medium | 05-Recognition |
| MonthlyGivingLimitReset | Recognition | No | High | 05-Recognition |
| ManagerBudgetAllocated | Recognition | No | High | 05-Recognition |
| RecognitionNominationSubmitted | Recognition | No | High | 05-Recognition |
| RecognitionNominationApproved | Recognition | No | High | 05-Recognition |
| RecognitionNominationRejected | Recognition | No | High | 05-Recognition |
| CatalogItemAdded | Recognition | No | High | 05-Recognition |
| CatalogItemRedeemed | Recognition | No | High | 05-Recognition |
| PointBalanceCalculated | Recognition | No | High | 05-Recognition |
| RecognitionFeedUpdated | Recognition | No | Medium | 05-Recognition |
| ⭐ AIRecognitionSuggested | Recognition | **Yes** | Low | 05-Recognition |
| WorkAnniversaryDetected | Recognition | No | High | 05-Recognition |
| BirthdayDetected | Recognition | No | Medium | 05-Recognition |
| CertificationRecognized | Recognition | No | Medium | 05-Recognition |

### Tax/Compliance Events

| Event | Cluster | USP? | Confidence | Source BRD |
|-------|---------|------|------------|------------|
| TaxCalculated | Tax/Compliance | No | High | 09-Tax Withholding |
| TaxWithheld | Tax/Compliance | No | High | 09-Tax Withholding |
| TaxDeclarationFiled | Tax/Compliance | No | High | 09-Tax Withholding |
| ComplianceReportGenerated | Tax/Compliance | No | High | 11-Audit |
| TaxProfileUpdated | Tax/Compliance | No | High | 09-Tax Withholding |
| TaxFilingDeadlineApproaching | Tax/Compliance | No | High | 09-Tax Withholding |
| TaxAnomalyDetected | Tax/Compliance | No | Medium | 09-Tax Withholding |
| TaxYearClosed | Tax/Compliance | No | High | 09-Tax Withholding |
| TaxYearReopened | Tax/Compliance | No | Medium | 09-Tax Withholding |
| TaxOverrideApproved | Tax/Compliance | No | Medium | 09-Tax Withholding |
| TaxAuditInitiated | Tax/Compliance | No | Medium | 11-Audit |
| TaxAuditCompleted | Tax/Compliance | No | Medium | 11-Audit |
| PITCalculated | Tax/Compliance | No | High | 09-Tax Withholding |
| PCBRemitted | Tax/Compliance | No | High | 09-Tax Withholding |
| TaxReconciliationCompleted | Tax/Compliance | No | High | 09-Tax Withholding |
| TaxFormGenerated | Tax/Compliance | No | High | 09-Tax Withholding |
| DeductionCalculated | Tax/Compliance | No | High | 08-Deductions |
| GarnishmentOrderReceived | Tax/Compliance | No | High | 08-Deductions |
| LoanDisbursed | Tax/Compliance | No | High | 08-Deductions |
| LoanRepaymentDeducted | Tax/Compliance | No | High | 08-Deductions |
| SalaryAdvanceRequested | Tax/Compliance | No | High | 08-Deductions |
| SalaryAdvanceApproved | Tax/Compliance | No | High | 08-Deductions |
| VoluntaryDeductionEnrolled | Tax/Compliance | No | High | 08-Deductions |
| DeductionCapReached | Tax/Compliance | No | Medium | 08-Deductions |

### Statement Events

| Event | Cluster | USP? | Confidence | Source BRD |
|-------|---------|------|------------|------------|
| StatementGenerated | Statement | No | High | 07-TR Statement |
| StatementViewed | Statement | No | High | 07-TR Statement |
| DisputeRaised | Statement | No | Medium | 07-TR Statement |
| StatementDownloaded | Statement | No | High | 07-TR Statement |
| StatementShared | Statement | No | Medium | 07-TR Statement |
| StatementEmailed | Statement | No | High | 07-TR Statement |
| AnnualStatementGenerated | Statement | No | High | 07-TR Statement |
| OnDemandStatementRequested | Statement | No | High | 07-TR Statement |
| StatementConfigured | Statement | No | High | 07-TR Statement |
| StatementArchived | Statement | No | High | 07-TR Statement |

### Multi-Country Events

| Event | Cluster | USP? | Confidence | Source BRD |
|-------|---------|------|------------|------------|
| CurrencyConverted | Multi-Country | No | High | MASTER-BRD |
| FxRateUpdated | Multi-Country | No | High | MASTER-BRD |
| LegalEntityConfigured | Multi-Country | No | High | MASTER-BRD |
| CrossBorderPaymentInitiated | Multi-Country | No | Medium | MASTER-BRD |
| CountryRuleApplied | Multi-Country | No | High | MASTER-BRD |
| MinimumWageUpdated | Multi-Country | No | High | 01-Core Compensation |
| RegulatoryChangeDetected | Multi-Country | No | Medium | MASTER-BRD |
| LocalComplianceValidated | Multi-Country | No | High | MASTER-BRD |

### Offer Management Events

| Event | Cluster | USP? | Confidence | Source BRD |
|-------|---------|------|------------|------------|
| OfferCreated | Offer Management | No | High | 06-Offer Management |
| OfferSubmitted | Offer Management | No | High | 06-Offer Management |
| OfferApproved | Offer Management | No | High | 06-Offer Management |
| OfferRejected | Offer Management | No | High | 06-Offer Management |
| OfferSent | Offer Management | No | High | 06-Offer Management |
| OfferViewed | Offer Management | No | High | 06-Offer Management |
| OfferAccepted | Offer Management | No | High | 06-Offer Management |
| OfferDeclined | Offer Management | No | High | 06-Offer Management |
| OfferExpired | Offer Management | No | High | 06-Offer Management |
| OfferWithdrawn | Offer Management | No | High | 06-Offer Management |
| CounterOfferRequested | Offer Management | No | High | 06-Offer Management |
| CounterOfferSubmitted | Offer Management | No | High | 06-Offer Management |
| OfferLetterGenerated | Offer Management | No | High | 06-Offer Management |
| ESignatureCompleted | Offer Management | No | High | 06-Offer Management |
| OfferTemplateCreated | Offer Management | No | High | 06-Offer Management |
| OfferTemplateActivated | Offer Management | No | High | 06-Offer Management |
| ⭐ OfferCompetitivenessScored | Offer Management | **Yes** | Medium | 06-Offer Management |

### Audit Events

| Event | Cluster | USP? | Confidence | Source BRD |
|-------|---------|------|------------|------------|
| AuditLogCreated | Audit | No | High | 11-Audit |
| AuditRecordRetained | Audit | No | High | 11-Audit |
| AuditRecordExpired | Audit | No | High | 11-Audit |
| LegalHoldPlaced | Audit | No | High | 11-Audit |
| LegalHoldReleased | Audit | No | Medium | 11-Audit |
| ComplianceReportExported | Audit | No | High | 11-Audit |
| AccessLogged | Audit | No | High | 11-Audit |
| UnauthorizedAccessAttempted | Audit | No | Medium | 11-Audit |
| AnomalyAlertTriggered | Audit | No | Medium | 11-Audit |
| AuditTrailReviewed | Audit | No | High | 11-Audit |
| DataRetentionEnforced | Audit | No | High | 11-Audit |
| TamperDetectionTriggered | Audit | No | Medium | 11-Audit |

### ⭐ USP Innovation Events

| Event | Cluster | USP? | Confidence | Source BRD |
|-------|---------|------|------------|------------|
| ⭐ SocialRecognitionPosted | Recognition | **Yes** | Medium | 05-Recognition |
| ⭐ PayEquityGapDetected | Compensation | **Yes** | Medium | 01-Core Compensation |
| ⭐ AICompensationRecommended | Compensation | **Yes** | Medium | 01-Core Compensation, 03-Variable Pay |
| ⭐ RealTimeCommissionCalculated | Compensation | **Yes** | High | 03-Variable Pay |
| ⭐ FlexCreditAllocated | Benefits | **Yes** | Medium | 04-Benefits |
| ⭐ OfferCompetitivenessScored | Offer Management | **Yes** | Medium | 06-Offer Management |
| ⭐ AIRecognitionSuggested | Recognition | **Yes** | Low | 05-Recognition |
| ⭐ TaxOptimizationRecommended | Tax/Compliance | **Yes** | Medium | 09-Tax Withholding |

---

## Event Summary by Cluster

| Cluster | Total Events | USP Events | High Confidence | Medium Confidence | Low Confidence |
|---------|--------------|------------|-----------------|-------------------|----------------|
| Compensation | 35 | 3 | 28 | 6 | 1 |
| Benefits | 20 | 1 | 15 | 5 | 0 |
| Recognition | 24 | 2 | 17 | 6 | 1 |
| Tax/Compliance | 24 | 1 | 18 | 6 | 0 |
| Statement | 10 | 0 | 8 | 2 | 0 |
| Multi-Country | 8 | 0 | 6 | 2 | 0 |
| Offer Management | 17 | 1 | 14 | 3 | 0 |
| Audit | 12 | 0 | 9 | 3 | 0 |
| **TOTAL** | **150** | **8** | **115** | **33** | **2** |

---

## Event Storming Session Agenda

### Day 1: Foundation (Compensation + Benefits)
- **Morning**: Compensation Events (08:30 - 12:00)
- **Afternoon**: Benefits Events (13:30 - 17:00)
- **Wrap-up**: Cross-cluster dependencies (17:00 - 18:00)

### Day 2: Employee Experience (Recognition + Offer Management)
- **Morning**: Recognition Events (08:30 - 12:00)
- **Afternoon**: Offer Management Events (13:30 - 16:00)
- **Wrap-up**: Actor-Event mapping (16:00 - 18:00)

### Day 3: Compliance & Reporting (Tax + Audit + Statements)
- **Morning**: Tax/Compliance + Audit Events (08:30 - 12:00)
- **Afternoon**: Statement Events + Multi-Country (13:30 - 16:00)
- **Wrap-up**: Hot spots identification (16:00 - 18:00)

### Day 4: Integration & Timeline
- **Morning**: Commands & Policies (08:30 - 12:00)
- **Afternoon**: Bounded Contexts + Timeline (13:30 - 17:00)
- **Wrap-up**: Discovery questions + Next steps (17:00 - 18:00)

---

## Key Discovery Questions

### Compensation
1. What triggers a compensation cycle to start?
2. How are budget pools allocated across legal entities?
3. What happens when a manager exceeds their budget?
4. How do we handle off-cycle adjustments?

### Benefits
1. How are life events detected and processed?
2. What is the enrollment window policy?
3. How do we handle carrier integration failures?
4. What constitutes a qualifying life event?

### Recognition
1. What are the point expiration policies per country?
2. How do we prevent recognition abuse?
3. What is the approval workflow for high-value awards?
4. How are perks fulfilled across different countries?

### Tax/Compliance
1. How do we handle mid-year tax law changes?
2. What is the process for tax filing corrections?
3. How do we manage expatriate tax situations?
4. What are the data retention requirements per country?

### Multi-Country
1. How do we handle currency fluctuations in budgets?
2. What is the process for adding new countries?
3. How do we manage cross-border employees?
4. What are the data localization requirements?

---

## Document Control

| Version | Date | Author | Status |
|---------|------|--------|--------|
| 1.0.0 | 2026-03-20 | Event Storming Facilitator | DRAFT |

**Next Steps:**
1. Review with Product Owner and HR stakeholders
2. Validate event list with country SMEs
3. Schedule Event Storming sessions (3-4 days)
4. Prepare physical/virtual event board
5. Invite participants (all actors representatives)

---

*This Event Storming Session Brief is part of the Total Rewards Module specification. Related documents:*
- *MASTER-BRD: `00-MASTER-BRD.md`*
- *Innovation Sprints: `12-Innovation-Sprints.md`*
- *Functional Requirements: `../02-spec/01-functional-requirements.md`*
