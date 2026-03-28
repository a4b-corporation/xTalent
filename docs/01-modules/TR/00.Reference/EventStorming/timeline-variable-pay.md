# Timeline: Variable Pay Calculation

**Domain**: Total Rewards (TR)
**Flow Type**: Bonus + Commission + 13th Month Calculation
**Related Events**: Variable Pay Cluster events from `00-session-brief.md`
**USP Events**: ⭐ `RealTimeCommissionCalculated`, ⭐ `CommissionDashboardViewed`
**Hot Spots Addressed**: H07, H08, H09, H10, H16, H26
**Created**: 2026-03-20
**Status**: DRAFT

---

## Sequence Diagram: STI Bonus Calculation (Annual)

```mermaid
sequenceDiagram
    autonumber
    participant HR as 🟡 HR Director
    participant CM as 🟡 Compensation Manager
    participant M as 🟡 Manager
    participant E as 🟡 Employee
    participant S as 🟡 System
    participant PM as 🟡 Performance Mgmt
    participant PG as 🟡 Payroll Gateway

    Note over HR,CM: === Phase 1: Bonus Plan Setup ===

    HR->>S: 🔵 CreateBonusPlan
    activate S
    S->>S: 🟠 BonusPlanCreated
    S->>CM: 🔵 SetBudgetPool
    CM->>S: 🔵 AllocateBudgetPool
    S->>S: 🟠 BudgetPoolCreated
    S->>S: 🟠 BudgetAllocationSubmitted
    deactivate S

    Note over PM,S: === Phase 2: Performance Data Sync ===

    PM->>S: 🔵 SyncPerformanceRatings
    activate PM
    alt Performance Data Available
        PM->>S: 🟠 PerformanceRatingsSynced
    else Performance Data Missing
        PM->>S: 🟠 PerformanceDataMissing
        S->>HR: 🔵 AlertMissingPerformanceData
        Note over S,HR: Block bonus calculation
    end
    deactivate PM

    Note over M,S: === Phase 3: Manager Bonus Allocation ===

    S->>M: 🔵 InviteBonusAllocation
    activate M
    M->>S: 🔵 ViewBonusWorksheet
    S-->>M: Team data + budget remaining
    M->>S: 🔵 ProposeBonusAllocation
    S->>S: 🟠 BonusAllocationSubmitted

    alt Budget Available
        S->>S: 🟠 BonusProposed
    else Budget Exceeded
        S->>M: 🔵 SendBudgetWarning
        M->>S: 🔵 ReviseBonusAllocation
        S->>S: 🟠 BonusAllocationRevised
    end
    deactivate M

    Note over CM,S: === Phase 4: Approval Workflow ===

    M->>S: 🔵 SubmitBonusForApproval
    activate S
    S->>S: 🟠 BonusSubmittedForApproval
    S->>CM: 🔵 RequestBonusApproval

    alt Approval Granted
        CM->>S: 🔵 ApproveBonus
        S->>S: 🟠 BonusApproved
        S->>S: 🔵 CalculateBonusAmount
        S->>S: 🟠 BonusCalculated
        S->>S: 🟠 BonusAccrued
    else Approval Rejected
        CM->>S: 🔵 RejectBonus
        S->>S: 🟠 BonusRejected
        S->>M: 🔵 SendRejectionFeedback
    end
    deactivate S

    Note over S,PG: === Phase 5: Payout ===

    S->>PG: 🔵 SendBonusToPayroll
    activate PG
    alt Payout Success
        PG->>S: 🟠 BonusPayoutProcessed
        S->>S: 🟠 BonusPaid
        S->>E: 🔵 SendBonusNotification
        E->>S: 🟠 BonusNotificationReceived
    else Payout Failed
        PG->>S: 🟠 BonusPayoutFailed
        S->>PG: 🔵 RetryBonusPayout
    end
    deactivate PG
```

---

## Sequence Diagram: Real-Time Commission Calculation ⭐

```mermaid
sequenceDiagram
    autonumber
    participant SR as 🟡 Sales Rep
    participant SM as 🟡 Sales Manager
    participant CRM as 🟡 CRM System
    participant S as 🟡 System
    participant D as 🟡 Commission Dashboard ⭐
    participant PG as 🟡 Payroll Gateway

    Note over CRM,S: === Transaction Recording ===

    CRM->>S: 🔵 SendSalesTransaction
    activate CRM
    S->>S: 🟠 CommissionTransactionRecorded
    S->>S: 🔵 CalculateCommission
    S->>S: 🟠 RealTimeCommissionCalculated ⭐
    S->>D: 🔵 UpdateDashboard
    deactivate CRM

    Note over SR,D: === Real-Time Dashboard View ⭐ ===

    SR->>D: 🔵 ViewCommissionDashboard
    activate D
    D-->>SR: Accrued commission + breakdown
    D-->>SR: ⭐ Real-time updates
    deactivate D

    Note over SM,S: === Manager Review ===

    S->>SM: 🔵 NotifyCommissionAccrual
    activate SM
    SM->>S: 🔵 ReviewCommission
    alt Commission Accurate
        SM->>S: 🔵 ApproveCommission
        S->>S: 🟠 CommissionApproved
    else Discrepancy Found
        SM->>S: 🔵 FlagCommissionDiscrepancy
        S->>S: 🟠 CommissionFlagged
    end
    deactivate SM

    Note over S,PG: === Monthly Payout ===

    S->>PG: 🔵 SendCommissionToPayroll
    activate PG
    PG->>S: 🟠 CommissionPaid
    S->>SR: 🔵 SendCommissionStatement
    deactivate PG

    Note over SR,S: === Dispute Resolution (H09) ===

    opt Commission Dispute
        SR->>S: 🔵 SubmitCommissionDispute
        S->>S: 🟠 CommissionDisputed
        S->>SM: 🔵 NotifyDispute
        SM->>S: 🔵 ReviewDispute
        alt Dispute Valid
            SM->>S: 🔵 ApproveDispute
            S->>S: 🟠 CommissionAdjusted
            S->>PG: 🔵 SendAdjustmentToPayroll
        else Dispute Invalid
            SM->>S: 🔵 RejectDispute
            S->>SR: 🔵 SendDisputeRejection
        end
    end
```

---

## Alternative Path A: 13th Month Calculation (Vietnam + Philippines)

```mermaid
sequenceDiagram
    autonumber
    participant HR as 🟡 HR Admin
    participant S as 🟡 System
    participant E as 🟡 Employee
    participant PG as 🟡 Payroll Gateway

    Note over HR,S: === Eligibility Check ===

    HR->>S: 🔵 Trigger13thMonthCalculation
    activate S
    S->>S: 🔵 Check13thMonthEligibility

    alt Employed Full Year
        S->>S: 🟠 13thMonthEligibilityConfirmed
    else Hired Mid-Year
        S->>S: 🔵 CalculateProRata13thMonth
        S->>S: 🟠 ProRata13thMonthCalculated
    end

    Note over S,E: === Calculation ===

    S->>S: 🔵 Get13thMonthBaseSalary
    S->>S: 🟠 13thMonthCalculated
    S->>S: 🟠 13thMonthAccrued

    Note over S,PG: === Payout (Before Tet in VN) ===

    S->>PG: 🔵 Send13thMonthToPayroll
    activate PG
    PG->>S: 🟠 13thMonthPaid
    S->>E: 🔵 Send13thMonthStatement
    deactivate PG
    deactivate S
```

---

## Alternative Path B: Budget Reallocation (H08)

```mermaid
sequenceDiagram
    autonumber
    participant M as 🟡 Manager
    participant CM as 🟡 Compensation Manager
    participant FA as 🟡 Finance Approver
    participant S as 🟡 System

    M->>S: 🔵 RequestBudgetReallocation
    activate S
    S->>S: 🟠 BudgetReallocationRequested

    alt Same Team Reallocation
        S->>CM: 🔵 NotifyReallocationRequest
        CM->>S: 🔵 ApproveSameTeamReallocation
        S->>S: 🟠 BudgetPoolReallocated
        S->>S: 🟠 BudgetReallocationApproved
    else Cross-Team Reallocation
        S->>FA: 🔵 RequestCrossTeamApproval
        activate FA
        FA->>S: 🔵 ApproveCrossTeamReallocation
        S->>S: 🟠 BudgetPoolReallocated
        deactivate FA
    end

    S->>M: 🔵 ConfirmReallocation
    deactivate S
```

---

## Alternative Path C: LTI Equity Compensation (Phase 2)

```mermaid
sequenceDiagram
    autonumber
    participant E as 🟡 Employee
    participant CM as 🟡 Compensation Manager
    participant S as 🟡 System
    participant EQ as 🟡 Equity Platform

    Note over CM,S: === Grant Creation ===

    CM->>S: 🔵 CreateEquityGrant
    activate S
    S->>S: 🟠 EquityGrantCreated
    S->>E: 🔵 SendGrantNotification
    deactivate S

    Note over S,EQ: === Vesting Tracking ===

    S->>S: 🔵 TrackVestingSchedule
    S->>S: 🟠 VestingMilestoneReached
    S->>S: 🟠 EquityVested

    Note over E,S: === Exercise (Stock Options) ===

    E->>S: 🔵 ExerciseStockOption
    activate E
    S->>S: 🟠 StockOptionExercised
    S->>S: 🔵 CalculateTaxImpact
    S->>S: 🟠 TaxableBridgeCreated
    deactivate E
```

---

## Error Scenarios

| Scenario | Detection | Fallback | Owner |
|----------|-----------|----------|-------|
| **Performance data missing** | Pre-calculation validation | Block bonus calc, alert HR | HR Admin |
| **Budget exceeded** | Real-time validation | Require reallocation approval | Finance |
| **Commission dispute** | Sales rep flag | Freeze disputed amount, pay rest | Sales Ops |
| **Payroll sync failed** | Callback timeout | Retry 3×, manual file | Tech Lead |
| **13th month miscalculation** | Pro-rata validation | Recalculate, adjust next cycle | Payroll Admin |
| **Dashboard latency > 5 min** | Performance monitoring | Show cached data with timestamp | Tech Lead |

---

## Commission Calculation Rules

| Component | Formula | Real-Time Source |
|-----------|---------|------------------|
| **Base Commission** | Deal Amount × Rate % | CRM Closed-Won |
| **Accelerator** | (Quota Attainment > 100%) × Multiplier | Quota tracking |
| **Team Override** | Team Deals × Override % | Team attribution |
| **Clawback** | Cancelled Deals × Commission Rate | CRM Cancelled |
| **Draw Against** | Recoverable Draw Balance | Finance system |

---

## Event Checklist

### Events in Happy Path (Bonus)
- [ ] 🟠 `BonusPlanCreated`
- [ ] 🟠 `BudgetPoolCreated`
- [ ] 🟠 `PerformanceRatingsSynced`
- [ ] 🟠 `BonusAllocationSubmitted`
- [ ] 🟠 `BonusProposed`
- [ ] 🟠 `BonusApproved`
- [ ] 🟠 `BonusCalculated`
- [ ] 🟠 `BonusAccrued`
- [ ] 🟠 `BonusPayoutProcessed`
- [ ] 🟠 `BonusPaid`

### Events in Happy Path (Commission)
- [ ] 🟠 `CommissionTransactionRecorded`
- [ ] 🟠 ⭐ `RealTimeCommissionCalculated`
- [ ] 🟠 `CommissionApproved`
- [ ] 🟠 `CommissionPaid`
- [ ] 🟠 `CommissionStatementSent`

### Commands in Flow
- [ ] 🔵 `CreateBonusPlan`
- [ ] 🔵 `AllocateBudgetPool`
- [ ] 🔵 `SyncPerformanceRatings`
- [ ] 🔵 `InviteBonusAllocation`
- [ ] 🔵 `ProposeBonusAllocation`
- [ ] 🔵 `SubmitBonusForApproval`
- [ ] 🔵 `ApproveBonus`
- [ ] 🔵 `CalculateBonusAmount`
- [ ] 🔵 `SendBonusToPayroll`
- [ ] 🔵 `SendSalesTransaction` (CRM)
- [ ] 🔵 `CalculateCommission`
- [ ] 🔵 `ViewCommissionDashboard`
- [ ] 🔵 `ApproveCommission`
- [ ] 🔵 `Trigger13thMonthCalculation`
- [ ] 🔵 `RequestBudgetReallocation`

---

## Related Documents

| Document | Purpose |
|----------|---------|
| `00-session-brief.md` | Domain Events catalog |
| `01-commands-actors.md` | Commands and Actors mapping |
| `02-hot-spots.md` | Hot Spots (H07, H08, H09, H10, H16, H26) |
| `../BRD/03-BRD-Variable-Pay.md` | Variable Pay business rules |
| `../BRD/02-BRD-Calculation-Rules.md` | Proration and calculation rules |

---

**Next Timeline**: [`timeline-recognition.md`](./timeline-recognition.md) — Recognition Flow
