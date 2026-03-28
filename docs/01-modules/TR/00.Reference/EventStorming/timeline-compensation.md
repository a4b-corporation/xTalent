# Timeline: Compensation Cycle

**Domain**: Total Rewards (TR)
**Flow Type**: Annual/Semi-Annual Compensation Review Cycle
**Related Events**: 150 Domain Events from `00-session-brief.md`
**USP Events**: ⭐ `PayEquityGapDetected`, ⭐ `AICompensationRecommended`
**Hot Spots Addressed**: H01, H02, H06, H08, H14, H15
**Created**: 2026-03-20
**Status**: DRAFT

---

## Sequence Diagram: Annual Compensation Review Cycle

```mermaid
sequenceDiagram
    autonumber
    participant CM as 🟡 Compensation Manager
    participant CA as 🟡 Comp Analyst
    participant FA as 🟡 Finance Approver
    participant M as 🟡 Manager
    participant E as 🟡 Employee
    participant S as 🟡 System
    participant FX as 🟡 FX Provider
    participant PG as 🟡 Payroll Gateway
    participant A as 🟡 AI Advisor ⭐

    Note over CM,PG: === Phase 1: Compensation Cycle Setup ===

    CM->>S: 🔵 CreateCompensationCycle
    activate S
    S->>S: 🟠 CompensationCycleCreated
    S->>FX: 🔵 GetFxRates
    activate FX
    FX-->>S: 🟠 FxRateUpdated
    deactivate FX
    S->>FA: 🔵 RequestBudgetApproval
    deactivate S

    activate FA
    FA->>S: 🔵 ApproveBudgetAllocation
    S->>S: 🟠 BudgetAllocated
    S->>S: 🟠 BudgetPoolCreated
    deactivate FA

    Note over M,S: === Phase 2: Manager Salary Review ===

    M->>S: 🔵 ViewCompensationWorksheet
    activate S
    S->>S: 🟠 CompensationWorksheetViewed
    S-->>M: Worksheet with team data + ⭐ Compa-ratio
    deactivate S

    opt Pay Equity Check ⭐
        S->>A: 🔵 AnalyzePayEquity
        activate A
        A->>S: 🟠 PayEquityGapDetected ⭐
        A-->>M: Equity recommendations
        deactivate A
    end

    M->>S: 🔵 ProposeSalaryIncrease
    activate S
    S->>S: 🟠 SalaryIncreaseProposed
    S->>S: 🔵 ValidateMinimumWage
    alt Salary >= Regional Minimum Wage
        S->>S: 🟠 MinimumWageValidated
    else Salary < Regional Minimum Wage
        S->>S: 🟠 MinimumWageViolationDetected
        S-->>M: 🔵 SendValidationFailed
        destroy S
    end
    deactivate S

    Note over S,FA: === Phase 3: Approval Workflow ===

    S->>FA: 🔵 RequestApproval
    activate FA
    alt Budget Available
        FA->>S: 🔵 ApproveSalaryIncrease
        S->>S: 🟠 SalaryReviewed
        S->>S: 🟠 SalaryAdjustmentCalculated
    else Budget Exceeded
        FA->>S: 🔵 RejectSalaryIncrease
        S->>S: 🟠 IncreaseRejected
        S->>M: 🔵 SendRejectionNotification
    end
    deactivate FA

    opt AI Recommendation ⭐
        S->>A: 🔵 GenerateAIRecommendation
        activate A
        A->>S: 🟠 AICompensationRecommended ⭐
        S->>M: 🔵 SendAIRecommendation
        deactivate A
    end

    Note over S,PG: === Phase 4: Payroll Sync ===

    S->>PG: 🔵 SyncSalaryChange
    activate PG
    alt Payroll Gateway Available
        PG->>S: 🟠 SalarySynced
        S->>S: 🟠 CompensationSynced
    else Payroll Gateway Unavailable
        PG->>S: 🟠 SalarySyncFailed
        S->>S: 🟠 PayrollSyncFailed
        Note over S,PG: Fallback: Queue for retry<br/>Alert Payroll Admin
    end
    deactivate PG

    Note over S,E: === Phase 5: Employee Notification ===

    S->>E: 🔵 SendCompensationNotification
    E->>S: 🟠 CompensationNotificationReceived
    S->>S: 🟠 TotalRewardsStatementUpdated

    Note over S,S: === Multi-Country Considerations ===
    Note right of S: **Vietnam**: Validate against 4 regional<br/>minimum wages (VND 3.25M - 4.68M)<br/><br/>**Singapore**: SGD currency, CPF contributions<br/><br/>**Malaysia**: MYR currency, EPF/SOCSO<br/><br/>**Thailand**: THB currency, SSF<br/><br/>**Indonesia**: IDR currency, BPJS<br/><br/>**Philippines**: PHP currency, SSS/PhilHealth
```

---

## Alternative Path A: Budget Reallocation

```mermaid
sequenceDiagram
    autonumber
    participant M as 🟡 Manager
    participant S as 🟡 System
    participant FA as 🟡 Finance Approver
    participant HR as 🟡 HR Admin

    M->>S: 🔵 RequestBudgetReallocation
    activate S
    S->>S: 🟠 BudgetReallocationRequested
    S->>FA: 🔵 NotifyBudgetOwner

    alt Same Department
        FA->>S: 🔵 ApproveBudgetReallocation
        S->>S: 🟠 BudgetPoolReallocated
        S->>M: 🔵 ConfirmReallocation
    else Cross-Department
        FA->>HR: 🔵 RequestCrossDeptApproval
        activate HR
        HR->>S: 🔵 ApproveCrossDeptReallocation
        S->>S: 🟠 BudgetPoolReallocated
        deactivate HR
    end
    deactivate S
```

---

## Alternative Path B: Compensation Dispute

```mermaid
sequenceDiagram
    autonumber
    participant E as 🟡 Employee
    participant M as 🟡 Manager
    participant HR as 🟡 HR Admin
    participant S as 🟡 System

    E->>S: 🔵 SubmitCompensationDispute
    activate S
    S->>S: 🟠 CompensationDisputed
    S->>HR: 🔵 NotifyDispute

    HR->>S: 🔵 ReviewCompensationDispute
    S->>S: 🟠 DisputeUnderReview

    alt Dispute Valid
        HR->>S: 🔵 ApproveDispute
        S->>S: 🟠 DisputeResolved
        S->>S: 🔵 RecalculateCompensation
        S->>S: 🟠 CompensationAdjusted
        S->>E: 🔵 SendAdjustmentNotification
    else Dispute Invalid
        HR->>S: 🔵 RejectDispute
        S->>S: 🟠 DisputeRejected
        S->>E: 🔵 SendRejectionWithExplanation
    end
    deactivate S
```

---

## Alternative Path C: Multi-Currency Consolidation

```mermaid
sequenceDiagram
    autonumber
    participant S as 🟡 System
    participant FX as 🟡 FX Provider
    participant FA as 🟡 Finance Approver
    participant R as 🟡 Regional HR

    Note over S,FX: === Monthly Currency Revaluation ===

    S->>FX: 🔵 GetFxRates
    activate FX
    FX-->>S: 🟠 FxRateUpdated
    deactivate FX

    S->>S: 🔵 ConvertLocalToReportingCurrency
    S->>S: 🟠 CurrencyConverted

    alt FX Rate Change > 5%
        S->>S: 🟠 SignificantFxMovementDetected
        S->>FA: 🔵 NotifyFxImpact
        FA->>S: 🔵 RequestFxHedgeAnalysis
        S->>FA: 🟠 FxHedgeAnalysisGenerated
    else Normal FX Movement
        S->>S: 🟠 ConsolidatedCompensationReported
    end

    S->>R: 🔵 SendRegionalReport
    R->>S: 🟠 RegionalReportGenerated
```

---

## Error Scenarios

| Scenario | Detection | Fallback | Owner |
|----------|-----------|----------|-------|
| **Budget Exceeded** | Real-time validation during proposal | Request budget reallocation (Path A) | Finance Approver |
| **Minimum Wage Violation** | Pre-submission validation | Block submission, show error | System |
| **Payroll Gateway Failure** | Async callback timeout | Queue for retry, alert admin | Tech Lead |
| **FX Rate Unavailable** | Rate staleness > 24 hours | Use last known rate, flag for review | Finance |
| **AI Recommendation Failure** | Model confidence < threshold | Fall back to rule-based recommendations | Product |
| **Data Residency Violation** | Cross-border data check | Block export, log compliance event | Legal |

---

## Multi-Country Variations

| Country | Currency | Minimum Wage | SI Components | Tax Authority | Cycle Timing |
|---------|----------|--------------|---------------|---------------|--------------|
| **Vietnam** | VND | 4 regions (3.25M-4.68M) | BHXH 17.5%+8%, BHYT 3%+1.5%, BHTN 1%+1% | GDT | Annual (Q4) |
| **Singapore** | SGD | No statutory | CPF (varies by age) | IRAS | Annual (Q1) |
| **Malaysia** | MYR | No statutory | EPF 12%+11%, SOCSO, EIS | LHDN | Annual (Q1) |
| **Thailand** | THB | ฿354/day | SSF 5%+5% | Revenue Dept | Annual (Q1) |
| **Indonesia** | IDR | Provincial | BPJS TK 3.7%+2%, BPJS 4%+1% | DGT | Annual (Q4) |
| **Philippines** | PHP | ₱481-₱610/day | SSS 9.5%, PhilHealth 4.5%, Pag-IBIG 2% | BIR | Annual (Q4) |

---

## Event Checklist

### Events in Happy Path
- [ ] 🟠 `CompensationCycleCreated`
- [ ] 🟠 `FxRateUpdated`
- [ ] 🟠 `BudgetAllocated`
- [ ] 🟠 `BudgetPoolCreated`
- [ ] 🟠 `CompensationWorksheetViewed`
- [ ] 🟠 ⭐ `PayEquityGapDetected`
- [ ] 🟠 `SalaryIncreaseProposed`
- [ ] 🟠 `MinimumWageValidated`
- [ ] 🟠 `SalaryReviewed`
- [ ] 🟠 `SalaryAdjustmentCalculated`
- [ ] 🟠 ⭐ `AICompensationRecommended`
- [ ] 🟠 `SalarySynced`
- [ ] 🟠 `CompensationSynced`
- [ ] 🟠 `CompensationNotificationReceived`
- [ ] 🟠 `TotalRewardsStatementUpdated`

### Commands in Flow
- [ ] 🔵 `CreateCompensationCycle`
- [ ] 🔵 `GetFxRates`
- [ ] 🔵 `RequestBudgetApproval`
- [ ] 🔵 `ApproveBudgetAllocation`
- [ ] 🔵 `ViewCompensationWorksheet`
- [ ] 🔵 `ProposeSalaryIncrease`
- [ ] 🔵 `ValidateMinimumWage`
- [ ] 🔵 `RequestApproval`
- [ ] 🔵 `ApproveSalaryIncrease`
- [ ] 🔵 `GenerateAIRecommendation`
- [ ] 🔵 `SyncSalaryChange`
- [ ] 🔵 `SendCompensationNotification`

---

## Related Documents

| Document | Purpose |
|----------|---------|
| `00-session-brief.md` | Domain Events catalog |
| `01-commands-actors.md` | Commands and Actors mapping |
| `02-hot-spots.md` | Hot Spots (H01, H02, H06, H08, H14, H15) |
| `../BRD/01-BRD-Core-Compensation.md` | Compensation business rules |
| `../BRD/02-BRD-Calculation-Rules.md` | SI and tax calculation rules |

---

**Next Timeline**: [`timeline-benefits.md`](./timeline-benefits.md) — Benefits Enrollment Flow
