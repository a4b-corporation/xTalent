# Timeline: Statement Generation

**Domain**: Total Rewards (TR)
**Flow Type**: Total Rewards Statement (Monthly/Quarterly/Annual + On-Demand)
**Related Events**: Analytics Cluster events from `00-session-brief.md`
**USP Events**: ⭐ `TotalRewardsStatementGenerated`, ⭐ `TaxOptimizationRecommended`
**Hot Spots Addressed**: H02, H03, H22, H37
**Created**: 2026-03-20
**Status**: DRAFT

---

## Sequence Diagram: Annual Total Rewards Statement

```mermaid
sequenceDiagram
    autonumber
    participant E as 🟡 Employee
    participant S as 🟡 System
    participant T as 🟡 Time Scheduler
    participant FX as 🟡 FX Provider
    participant G as 🟡 PDF Generator
    participant D as 🟡 Delivery Service

    Note over T,S: === Scheduled Trigger (Annual) ===

    T->>S: 🔵 TriggerAnnualStatement
    activate T
    S->>S: 🟠 AnnualStatementTriggered
    deactivate T

    Note over S,FX: === Data Aggregation ===

    S->>S: 🔵 AggregateCompensationData
    S->>S: 🟠 CompensationDataAggregated
    S->>S: 🔵 AggregateBenefitsData
    S->>S: 🟠 BenefitsDataAggregated
    S->>S: 🔵 AggregateRecognitionData
    S->>S: 🟠 RecognitionDataAggregated

    Note over S,FX: === Multi-Currency Conversion (H02) ===

    alt Employee Has Foreign Currency Data
        S->>FX: 🔵 GetAnnualAverageFxRates
        activate FX
        FX-->>S: 🟠 FxRatesProvided
        S->>S: 🔵 ConvertToReportingCurrency
        S->>S: 🟠 CurrencyConverted
        deactivate FX
    else Single Currency
        S->>S: 🟠 NoConversionNeeded
    end

    Note over S,S: === Tax Optimization Insights ⭐ ===

    opt AI Tax Insights
        S->>S: 🔵 AnalyzeTaxOptimization
        S->>S: 🟠 ⭐ TaxOptimizationRecommended ⭐
    end

    Note over S,G: === PDF Generation (H22) ===

    S->>G: 🔵 GenerateStatementPDF
    activate G
    alt Generation Successful
        G->>S: 🟠 TotalRewardsStatementGenerated
        S->>S: 🟠 StatementPdfCreated
    else Generation Failed
        G->>S: 🟠 StatementGenerationFailed
        S->>S: 🔵 RetryStatementGeneration
    end
    deactivate G

    Note over S,D: === Multi-Channel Delivery ===

    S->>D: 🔵 DeliverStatement
    activate D
    alt Email Delivery
        D->>E: 🔵 SendEmailWithPDF
        E->>S: 🟠 StatementDelivered
    else In-App Only
        D->>S: 🔵 UploadToDocumentCenter
        S->>S: 🟠 StatementAvailableInApp
    else SMS Notification
        D->>E: 🔵 SendSMSWithDownloadLink
        E->>S: 🟠 StatementLinkSent
    end
    deactivate D

    Note over S,S: === Audit Trail ===

    S->>S: 🟠 StatementDeliveryRecorded
    S->>S: 🟠 StatementAuditLogCreated
```

---

## Sequence Diagram: On-Demand Statement Request

```mermaid
sequenceDiagram
    autonumber
    participant E as 🟡 Employee
    participant M as 🟡 Manager
    participant S as 🟡 System
    participant G as 🟡 PDF Generator
    participant D as 🟡 Delivery Service

    Note over E,S: === Employee Self-Service Request ===

    E->>S: 🔵 RequestOnDemandStatement
    activate S
    S->>S: 🔵 ValidateRequestFrequency

    alt Within Frequency Limit
        S->>S: 🟠 OnDemandStatementRequested
    else Exceeds Limit (e.g., >3/month)
        S->>E: 🔵 SendFrequencyWarning
        E->>S: 🔵 ConfirmRequest
        S->>S: 🟠 OnDemandStatementRequested
    end
    deactivate S

    Note over S,G: === Real-Time Generation ===

    S->>S: 🔵 FetchLatestCompensationData
    S->>S: 🟠 CompensationDataFetched
    S->>G: 🔵 GenerateStatementPDF
    activate G
    G->>S: 🟠 TotalRewardsStatementGenerated
    deactivate G

    Note over E,D: === Instant Delivery ===

    S->>D: 🔵 DeliverStatement
    activate D
    D->>E: 🔵 ProvideDownloadLink
    E->>S: 🟠 StatementDownloaded
    deactivate D

    Note over S,S: === Optional: Manager Copy ===

    opt Manager Notification
        S->>M: 🔵 NotifyOnDemandStatement
        M->>S: 🟠 ManagerNotified
    end
```

---

## Alternative Path A: Multi-Country Statement (H02, H03)

```mermaid
sequenceDiagram
    autonumber
    participant E as 🟡 Employee
    participant S as 🟡 System
    participant LC as 🟡 Local Country Entity
    participant RC as 🟡 Regional Entity
    participant FX as 🟡 FX Provider

    Note over S,LC: === Country-Specific Statement ===

    S->>LC: 🔵 FetchLocalCompensationData
    activate LC
    LC->>S: 🟠 LocalDataProvided
    S->>S: 🔵 ApplyLocalTaxRules
    S->>S: 🟠 LocalTaxCalculated
    deactivate LC

    Note over S,RC: === Regional Aggregation ===

    S->>RC: 🔵 FetchRegionalData
    activate RC
    RC->>S: 🟠 RegionalDataProvided
    deactivate RC

    Note over S,FX: === Currency Display Options ===

    alt Employee Prefers Local Currency
        S->>S: 🟠 StatementInLocalCurrency
    else Employee Prefers Reporting Currency
        S->>FX: 🔵 GetFxRates
        activate FX
        FX-->>S: 🟠 FxRatesProvided
        S->>S: 🔵 ConvertToReportingCurrency
        S->>S: 🟠 StatementInReportingCurrency
        deactivate FX
    else Dual Currency Display
        S->>FX: 🔵 GetFxRates
        FX-->>S: 🟠 FxRatesProvided
        S->>S: 🟠 StatementInDualCurrency
    end

    Note over S,E: === Data Residency Compliance (H03) ===

    alt Data Residency Restriction
        S->>S: 🔵 ApplyDataResidencyRules
        S->>S: 🟠 CrossBorderDataFiltered
        Note over S: Only aggregated data crosses border
    else No Restriction
        S->>S: 🟠 FullStatementGenerated
    end

    S->>S: 🟠 MultiCountryStatementGenerated
```

---

## Alternative Path B: Delivery Failure Handling

```mermaid
sequenceDiagram
    autonumber
    participant S as 🟡 System
    participant D as 🟡 Delivery Service
    participant E as 🟡 Employee
    participant HR as 🟡 HR Admin

    S->>D: 🔵 DeliverStatement
    activate D

    alt Email Bounced
        D->>S: 🟠 EmailBounced
        S->>S: 🔵 RetryEmailDelivery
        alt Retry 1 Failed
            S->>S: 🔵 RetryEmailDelivery
            alt Retry 2 Failed
                S->>HR: 🔵 AlertDeliveryFailure
                activate HR
                HR->>E: 🔵 ManualDelivery
                S->>S: 🟠 StatementManuallyDelivered
                deactivate HR
            end
        end
    else Employee Inactive
        D->>S: 🟠 EmployeeInactive
        S->>HR: 🔵 AlertInactiveEmployee
        activate HR
        HR->>S: 🔵 HoldStatement
        S->>S: 🟠 StatementHeldForActiveStatus
        deactivate HR
    else Success
        D->>S: 🟠 StatementDelivered
    end
    deactivate D
```

---

## Alternative Path C: Statement Correction

```mermaid
sequenceDiagram
    autonumber
    participant E as 🟡 Employee
    participant S as 🟡 System
    participant HR as 🟡 HR Admin
    participant G as 🟡 PDF Generator

    E->>S: 🔵 ReportStatementError
    activate S
    S->>S: 🟠 StatementErrorReported
    S->>HR: 🔵 NotifyStatementDiscrepancy
    deactivate S

    activate HR
    HR->>S: 🔵 ReviewStatementError
    S->>S: 🟠 StatementUnderReview

    alt Error Confirmed
        HR->>S: 🔵 ApproveStatementCorrection
        S->>G: 🔵 RegenerateStatement
        activate G
        G->>S: 🟠 StatementRegenerated
        S->>E: 🔵 SendCorrectedStatement
        S->>S: 🟠 StatementCorrectionRecorded
        deactivate G
    else No Error Found
        HR->>S: 🔵 RejectStatementCorrection
        S->>E: 🔵 SendNoErrorFoundNotification
    end
    deactivate HR
```

---

## Error Scenarios

| Scenario | Detection | Fallback | Owner |
|----------|-----------|----------|-------|
| **PDF generation failed** | Generation timeout/error | Retry 3×, then alert admin | Tech Lead |
| **Email delivery bounced** | SMTP bounce notification | Retry, then manual delivery | System |
| **FX rate unavailable** | Rate staleness > 24 hours | Use last known rate, flag | Finance |
| **Data residency violation** | Cross-border check failed | Filter data, generate local-only | Legal |
| **Employee inactive** | Employment status check | Hold statement, alert HR | HR Admin |
| **Frequency limit exceeded** | Request count validation | Warn user, allow with confirmation | System |

---

## Statement Delivery Configuration

| Channel | Frequency | Opt-In Required | Fallback |
|---------|-----------|-----------------|----------|
| **Email PDF** | Annual + On-Demand | No | SMS + Download Link |
| **In-App Document Center** | Always Available | No | N/A |
| **SMS Notification** | Optional | Yes | Email |
| **Mobile Push** | Optional | Yes | In-App |
| **Manager Copy** | Annual Only | Configurable | N/A |

---

## Statement Content Sections

| Section | Data Sources | Multi-Country Considerations |
|---------|--------------|------------------------------|
| **Compensation Summary** | Core Compensation, Variable Pay | Currency conversion, FX rates |
| **Benefits Summary** | Benefits enrollment, Carrier data | Country-specific statutory benefits |
| **Recognition Summary** | Recognition points, Redemptions | Point valuation by country |
| **Employer Contributions** | SI, Health, Retirement | BHXH (VN), CPF (SG), EPF (MY), etc. |
| **Tax Summary** | Tax withholding, Taxable bridge | PIT (VN), IRAS (SG), LHDN (MY), etc. |
| **Total Rewards Value** | All of the above | Reporting currency option |

---

## Event Checklist

### Events in Happy Path
- [ ] 🟠 `AnnualStatementTriggered`
- [ ] 🟠 `CompensationDataAggregated`
- [ ] 🟠 `BenefitsDataAggregated`
- [ ] 🟠 `RecognitionDataAggregated`
- [ ] 🟠 `CurrencyConverted`
- [ ] 🟠 ⭐ `TaxOptimizationRecommended` ⭐
- [ ] 🟠 `TotalRewardsStatementGenerated`
- [ ] 🟠 `StatementPdfCreated`
- [ ] 🟠 `StatementDelivered`
- [ ] 🟠 `StatementDeliveryRecorded`
- [ ] 🟠 `OnDemandStatementRequested`
- [ ] 🟠 `StatementDownloaded`

### Commands in Flow
- [ ] 🔵 `TriggerAnnualStatement`
- [ ] 🔵 `AggregateCompensationData`
- [ ] 🔵 `AggregateBenefitsData`
- [ ] 🔵 `AggregateRecognitionData`
- [ ] 🔵 `GetAnnualAverageFxRates`
- [ ] 🔵 `ConvertToReportingCurrency`
- [ ] 🔵 `AnalyzeTaxOptimization`
- [ ] 🔵 `GenerateStatementPDF`
- [ ] 🔵 `DeliverStatement`
- [ ] 🔵 `SendEmailWithPDF`
- [ ] 🔵 `RequestOnDemandStatement`
- [ ] 🔵 `FetchLatestCompensationData`
- [ ] 🔵 `ProvideDownloadLink`

---

## Related Documents

| Document | Purpose |
|----------|---------|
| `00-session-brief.md` | Domain Events catalog |
| `01-commands-actors.md` | Commands and Actors mapping |
| `02-hot-spots.md` | Hot Spots (H02, H03, H22, H37) |
| `../BRD/07-BRD-Total-Rewards-Statement.md` | Statement business rules |
| `../BRD/02-BRD-Calculation-Rules.md` | FX and tax calculation rules |

---

## Event Storming Phase 6: Complete ✅

All 5 timeline diagrams have been created:

1. ✅ [`timeline-compensation.md`](./timeline-compensation.md) — Compensation Cycle
2. ✅ [`timeline-benefits.md`](./timeline-benefits.md) — Benefits Enrollment
3. ✅ [`timeline-variable-pay.md`](./timeline-variable-pay.md) — Variable Pay Calculation
4. ✅ [`timeline-recognition.md`](./timeline-recognition.md) — Recognition Flow
5. ✅ [`timeline-statement.md`](./timeline-statement.md) — Statement Generation

**Next Phase**: Phase 7 — Domain Discovery Questions → See [`discovery-questions.md`](./discovery-questions.md)
