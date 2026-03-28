# Timeline: Recognition Flow

**Domain**: Total Rewards (TR)
**Flow Type**: Real-Time Recognition Events
**Related Events**: Recognition Cluster events from `00-session-brief.md`
**USP Events**: ⭐ `SocialRecognitionPosted`, ⭐ `AIRecognitionSuggested`, ⭐ `RecognitionFeedUpdated`
**Hot Spots Addressed**: H13, H19, H21, H24
**Created**: 2026-03-20
**Status**: DRAFT

---

## Sequence Diagram: Peer-to-Peer Recognition

```mermaid
sequenceDiagram
    autonumber
    participant E1 as 🟡 Employee (Sender)
    participant E2 as 🟡 Employee (Receiver)
    participant S as 🟡 System
    participant M as 🟡 AI Moderator ⭐
    participant F as 🟡 Feed ⭐

    Note over E1,S: === Recognition Creation ===

    E1->>S: 🔵 CreateRecognition
    activate S
    S->>S: 🟠 RecognitionCreated
    S->>E1: 🔵 SelectRecognitionType
    E1->>S: 🔵 ChoosePeerRecognition

    Note over E1,S: === Content Input ===

    E1->>S: 🔵 EnterRecognitionDetails
    S-->>E1: Form: recipient, message, points, tags
    E1->>S: 🔵 AttachMedia
    opt Attach image/video
        S->>S: 🟠 MediaAttached
    end

    Note over S,M: === AI Content Moderation (H13) ⭐ ===

    S->>M: 🔵 AnalyzeContent
    activate M
    alt Content Appropriate
        M->>S: 🟠 ContentApproved
        M->>S: ⭐ `AIRecognitionSuggested` ⭐
    else Content Flagged
        M->>S: 🟠 ContentFlagged
        S->>E1: 🔵 RequestContentRevision
        E1->>S: 🔵 ReviseContent
        S->>M: 🔵 ReanalyzeContent
        M->>S: 🟠 ContentReapproved
    end
    deactivate M

    Note over S,E1: === Points Deduction ===

    S->>S: 🔵 CheckRecognitionBalance
    alt Sufficient Balance
        S->>S: 🟠 RecognitionPointsDeducted
        S->>E1: 🔵 ConfirmPointDeduction
    else Insufficient Balance
        S->>E1: 🔵 SendInsufficientBalanceError
        destroy S
    end

    Note over S,F: === Social Feed Posting ⭐ ===

    S->>F: 🔵 PostToRecognitionFeed
    activate F
    S->>S: 🟠 ⭐ SocialRecognitionPosted ⭐
    S->>S: 🟠 ⭐ RecognitionFeedUpdated ⭐
    deactivate F

    Note over S,E2: === Notification ===

    S->>E2: 🔵 SendRecognitionNotification
    activate E2
    E2->>S: 🟠 RecognitionNotificationReceived
    E2->>S: 🔵 ViewRecognition
    S-->>E2: Recognition details + points
    E2->>S: 🔵 AcceptRecognition
    S->>S: 🟠 RecognitionAccepted
    S->>S: 🟠 RecognitionPointsAwarded
    deactivate E2

    Note over S,S: === Redemption Option ===

    opt Redeem Points
        E2->>S: 🔵 RedeemPoints
        S->>S: 🟠 RecognitionPointRedeemed
        S->>S: 🟠 PerkFulfilled
    end
```

---

## Sequence Diagram: Manager Award

```mermaid
sequenceDiagram
    autonumber
    participant M as 🟡 Manager
    participant E as 🟡 Employee
    participant S as 🟡 System
    participant FA as 🟡 Finance Approver

    Note over M,S: === Award Initiation ===

    M->>S: 🔵 CreateManagerAward
    activate S
    S->>S: 🟠 ManagerAwardCreated
    S->>M: 🔵 SelectAwardType
    M->>S: 🔵 ChooseSpotAward
    deactivate S

    Note over M,S: === Budget Check ===

    S->>S: 🔵 CheckManagerBudget
    alt Budget Available
        S->>S: 🟠 ManagerBudgetVerified
    else Budget Exceeded
        S->>M: 🔵 SendBudgetExceededError
        M->>S: 🔵 RequestBudgetIncrease
        activate FA
        FA->>S: 🔵 ApproveBudgetIncrease
        S->>S: 🟠 ManagerBudgetIncreased
        deactivate FA
    end

    Note over M,S: === Award Details ===

    M->>S: 🔵 EnterAwardDetails
    S-->>M: Recipient, amount, reason, effective date
    M->>S: 🔵 SubmitAwardForApproval

    opt Approval Required (High Value)
        S->>FA: 🔵 RequestAwardApproval
        activate FA
        alt Approved
            FA->>S: 🔵 ApproveAward
            S->>S: 🟠 ManagerAwardApproved
        else Rejected
            FA->>S: 🔵 RejectAward
            S->>S: 🟠 ManagerAwardRejected
            S->>M: 🔵 SendRejectionFeedback
        end
        deactivate FA
    end

    Note over S,E: === Award Notification ===

    S->>E: 🔵 SendAwardNotification
    activate E
    E->>S: 🟠 AwardNotificationReceived
    E->>S: 🔵 ViewAwardDetails
    E->>S: 🔵 AcceptAward
    S->>S: 🟠 ManagerAwardAccepted
    S->>S: 🟠 AwardPointsCredited
    deactivate E

    Note over S,PG: === Payroll Integration (if cash award) ===

    opt Cash Award
        S->>PG: 🔵 SendCashAwardToPayroll
        activate PG
        PG->>S: 🟠 CashAwardPaid
        deactivate PG
    end
```

---

## Sequence Diagram: Milestone Recognition (Work Anniversary)

```mermaid
sequenceDiagram
    autonumber
    participant S as 🟡 System
    participant E as 🟡 Employee
    participant M as 🟡 Manager
    participant T as 🟡 Time Scheduler

    Note over T,S: === Scheduled Trigger ===

    T->>S: 🔵 CheckUpcomingAnniversaries
    activate T
    S->>S: 🟠 AnniversaryApproaching
    deactivate T

    Note over S,M: === Manager Notification ===

    S->>M: 🔵 NotifyUpcomingAnniversary
    activate M
    M->>S: 🔵 ViewAnniversaryDetails
    S-->>M: Employee, years, suggested recognition
    M->>S: 🔵 PrepareAnniversaryRecognition
    deactivate M

    Note over S,E: === Anniversary Day ===

    S->>S: 🟠 WorkAnniversaryReached
    S->>S: 🔵 GenerateAnniversaryRecognition
    S->>S: 🟠 AnniversaryRecognitionGenerated

    Note over S,F: === Social Feed Post ===

    S->>F: 🔵 PostToFeed
    activate F
    S->>S: 🟠 ⭐ SocialRecognitionPosted ⭐
    S->>S: 🟠 ⭐ RecognitionFeedUpdated ⭐
    deactivate F

    Note over S,E: === Employee Notification ===

    S->>E: 🔵 SendAnniversaryNotification
    activate E
    E->>S: 🟠 AnniversaryNotificationReceived
    E->>S: 🔵 ViewAnniversaryRecognition
    opt Award Points
        S->>E: 🔵 CreditAnniversaryPoints
        S->>S: 🟠 AnniversaryPointsCredited
    end
    deactivate E
```

---

## Alternative Path A: Content Moderation Escalation (H13)

```mermaid
sequenceDiagram
    autonumber
    participant E as 🟡 Employee
    participant S as 🟡 System
    participant AI as 🟡 AI Moderator
    participant HR as 🟡 HR Admin

    E->>S: 🔵 CreateRecognition
    S->>AI: 🔵 AnalyzeContent
    activate AI

    alt AI Uncertain (Confidence 50-80%)
        AI->>S: 🟠 ContentRequiresHumanReview
        S->>HR: 🔵 QueueForManualReview
        activate HR
        HR->>S: 🔵 ReviewContent
        alt Content Approved
            HR->>S: 🔵 ApproveContent
            S->>S: 🟠 ContentManuallyApproved
            S->>S: 🟠 RecognitionPublished
        else Content Rejected
            HR->>S: 🔵 RejectContent
            S->>S: 🟠 ContentRejected
            S->>E: 🔵 SendRejectionReason
        end
        deactivate HR
    else AI Confident (>80%)
        AI->>S: 🟠 ContentAutoApproved
        S->>S: 🟠 RecognitionPublished
    else AI Flags (<50%)
        AI->>S: 🟠 ContentFlagged
        S->>E: 🔵 RequestRevision
    end
    deactivate AI
```

---

## Alternative Path B: Point Expiration (H21)

```mermaid
sequenceDiagram
    autonumber
    participant S as 🟡 System
    participant E as 🟡 Employee
    participant T as 🟡 Time Scheduler

    Note over S,T: === Monthly Expiration Check ===

    T->>S: 🔵 CheckExpiringPoints
    activate T
    S->>S: 🔵 IdentifyExpiringPoints
    S->>S: 🟠 PointsExpiringSoon

    alt Points Expiring in 30 Days
        S->>E: 🔵 SendExpirationWarning
        activate E
        E->>S: 🟠 ExpirationWarningReceived
        opt Redeem Before Expiry
            E->>S: 🔵 RedeemPoints
            S->>S: 🟠 PointsRedeemed
        end
        deactivate E
    else Points Expired
        S->>S: 🟠 RecognitionPointExpired
        S->>E: 🔵 SendExpirationNotification
    end
    deactivate T
```

---

## Alternative Path C: Multi-Language Recognition

```mermaid
sequenceDiagram
    autonumber
    participant E1 as 🟡 Employee (Sender)
    participant E2 as 🟡 Employee (Receiver)
    participant S as 🟡 System
    participant T as 🟡 Translation Service

    E1->>S: 🔵 CreateRecognition
    activate E1
    E1->>S: 🔵 EnterMessageInVietnamese
    S->>S: 🟠 RecognitionCreated

    S->>T: 🔵 TranslateMessage
    activate T
    T->>S: 🟠 MessageTranslated
    deactivate T

    S->>E2: 🔵 SendRecognitionInPreferredLanguage
    activate E2
    E2->>S: 🟠 RecognitionReceivedInEnglish
    E2->>S: 🔵 ViewRecognition
    deactivate E2
    deactivate E1
```

---

## Error Scenarios

| Scenario | Detection | Fallback | Owner |
|----------|-----------|----------|-------|
| **Insufficient points** | Balance check | Prompt to earn more points | System |
| **Content flagged** | AI moderation | Request revision or escalate to HR | Product |
| **Manager budget exceeded** | Pre-submission validation | Request budget increase approval | Finance |
| **Feed posting failed** | Async callback error | Retry, log event | Tech Lead |
| **Notification bounced** | Email/SMS delivery failure | Retry via alternate channel | System |
| **Point expiration dispute** | Employee flag | HR manual adjustment | HR Admin |

---

## Recognition Point Economics

| Action | Points Cost | Notes |
|--------|-------------|-------|
| **Peer-to-Peer (Standard)** | 10-50 pts | Daily limit: 200 pts |
| **Peer-to-Peer (With Media)** | 25-75 pts | Higher engagement |
| **Manager Spot Award** | 100-500 pts | Monthly budget: varies |
| **Milestone (1 year)** | 100 pts | Auto-awarded |
| **Milestone (5+ years)** | 500-1000 pts | Escalating by tenure |
| **Redemption (Gift Card $10)** | 100 pts | Varies by vendor |
| **Redemption (Extra PTO Day)** | 500 pts | Subject to manager approval |

---

## Event Checklist

### Events in Happy Path
- [ ] 🟠 `RecognitionCreated`
- [ ] 🟠 `MediaAttached`
- [ ] 🟠 `ContentApproved`
- [ ] 🟠 `RecognitionPointsDeducted`
- [ ] 🟠 ⭐ `SocialRecognitionPosted` ⭐
- [ ] 🟠 ⭐ `RecognitionFeedUpdated` ⭐
- [ ] 🟠 `RecognitionNotificationReceived`
- [ ] 🟠 `RecognitionAccepted`
- [ ] 🟠 `RecognitionPointsAwarded`
- [ ] 🟠 `ManagerAwardCreated`
- [ ] 🟠 `ManagerAwardApproved`
- [ ] 🟠 `ManagerAwardAccepted`
- [ ] 🟠 `WorkAnniversaryReached`
- [ ] 🟠 `AnniversaryRecognitionGenerated`

### Commands in Flow
- [ ] 🔵 `CreateRecognition`
- [ ] 🔵 `SelectRecognitionType`
- [ ] 🔵 `EnterRecognitionDetails`
- [ ] 🔵 `AttachMedia`
- [ ] 🔵 `AnalyzeContent` (AI)
- [ ] 🔵 `CheckRecognitionBalance`
- [ ] 🔵 `PostToRecognitionFeed`
- [ ] 🔵 `SendRecognitionNotification`
- [ ] 🔵 `AcceptRecognition`
- [ ] 🔵 `RedeemPoints`
- [ ] 🔵 `CreateManagerAward`
- [ ] 🔵 `CheckManagerBudget`
- [ ] 🔵 `SubmitAwardForApproval`
- [ ] 🔵 `CheckUpcomingAnniversaries`

---

## Related Documents

| Document | Purpose |
|----------|---------|
| `00-session-brief.md` | Domain Events catalog |
| `01-commands-actors.md` | Commands and Actors mapping |
| `02-hot-spots.md` | Hot Spots (H13, H19, H21, H24) |
| `../BRD/05-BRD-Recognition.md` | Recognition business rules |
| `../BRD/12-Innovation-Sprints.md` | USP innovation features |

---

**Next Timeline**: [`timeline-statement.md`](./timeline-statement.md) — Total Rewards Statement Generation
