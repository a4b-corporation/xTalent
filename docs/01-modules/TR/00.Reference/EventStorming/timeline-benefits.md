# Timeline: Benefits Enrollment

**Domain**: Total Rewards (TR)
**Flow Type**: New Hire + Open Enrollment + Life Events
**Related Events**: Benefits Cluster events from `00-session-brief.md`
**USP Events**: ⭐ `FlexCreditAllocated`, ⭐ `WellnessProgramEnrolled`
**Hot Spots Addressed**: H01, H03, H10, H11, H18
**Created**: 2026-03-20
**Status**: DRAFT

---

## Sequence Diagram: New Hire Benefits Enrollment

```mermaid
sequenceDiagram
    autonumber
    participant NH as 🟡 New Hire
    participant HR as 🟡 HR Admin
    participant S as 🟡 System
    participant SI as 🟡 SI System (Vietnam)
    participant C as 🟡 Carrier
    participant T as 🟡 Tax Authority

    Note over NH,S: === Day 1: Employment Start ===

    HR->>S: 🔵 RegisterNewEmployee
    activate S
    S->>S: 🟠 EmployeeRegistered
    S->>S: 🔵 CalculateBenefitsEligibility
    S->>S: 🟠 BenefitsEligibilityDetermined
    deactivate S

    Note over NH,S: === Day 1-30: Initial Enrollment Window ===

    S->>NH: 🔵 SendEnrollmentInvitation
    activate NH
    NH->>S: 🔵 ViewBenefitsOptions
    S-->>NH: Benefits catalog + ⭐ Flex credits
    deactivate NH

    Note over NH,S: === Core Benefits (Statutory) ===

    NH->>S: 🔵 EnrollInStatutorySI
    activate S
    S->>S: 🟠 SIEnrollmentSubmitted

    alt Vietnam Employee
        S->>SI: 🔵 SubmitSIRegistration
        activate SI
        alt Success
            SI->>S: 🟠 SIRegistrationConfirmed
            S->>S: 🟠 SIContributionCalculated
            Note right of SI: BHXH 17.5%+8%<br/>BHYT 3%+1.5%<br/>BHTN 1%+1%<br/>Cap: 20× min wage
        else Failure
            SI->>S: 🟠 SIRegistrationFailed
            S->>HR: 🔵 AlertSIRegistrationFailure
        end
        deactivate SI
    else Non-Vietnam
        S->>S: 🟠 LocalSIEnrollmentProcessed
    end
    deactivate S

    Note over NH,S: === Voluntary Benefits (Carrier) ===

    NH->>S: 🔵 ElectHealthInsurance
    activate S
    S->>S: 🟠 HealthInsuranceElected
    S->>C: 🔵 SubmitCarrierEnrollment
    activate C
    alt Enrollment Accepted
        C->>S: 🟠 EnrollmentAcknowledged
        S->>S: 🟠 CarrierEnrollmentConfirmed
    else Enrollment Rejected
        C->>S: 🟠 EnrollmentRejected
        S->>HR: 🔵 AlertEnrollmentRejection
        Note over S,HR: Manual fallback required
    end
    deactivate C
    deactivate S

    Note over NH,S: === Flex Credits Marketplace ⭐ ===

    S->>NH: 🔵 ShowFlexCreditsMarketplace ⭐
    activate NH
    NH->>S: 🔵 AllocateFlexCredits
    S->>S: 🟠 FlexCreditAllocated ⭐
    S->>S: 🟠 FlexBenefitsEnrolled
    deactivate NH

    Note over S,T: === Tax Registration ===

    S->>T: 🔵 RegisterForTaxBenefit
    activate T
    T->>S: 🟠 TaxBenefitRegistered
    deactivate T

    Note over S,S: === Finalization ===

    S->>S: 🔵 GenerateBenefitsSummary
    S->>S: 🟠 BenefitsSummaryGenerated
    S->>NH: 🔵 SendBenefitsConfirmation
    NH->>S: 🟠 BenefitsEnrollmentCompleted
```

---

## Sequence Diagram: Open Enrollment (Annual)

```mermaid
sequenceDiagram
    autonumber
    participant E as 🟡 Employee
    participant M as 🟡 Manager
    participant S as 🟡 System
    participant C as 🟡 Carrier
    participant HR as 🟡 HR Admin

    Note over E,HR: === Pre-Enrollment Period ===

    HR->>S: 🔵 OpenEnrollmentPeriod
    activate S
    S->>S: 🟠 OpenEnrollmentStarted
    S->>E: 🔵 SendOpenEnrollmentNotification
    deactivate S

    Note over E,S: === Enrollment Window (4 weeks) ===

    E->>S: 🔵 ViewCurrentCoverage
    activate S
    S-->>E: Current benefits + dependents
    deactivate S

    E->>S: 🔵 ComparePlans
    activate S
    S-->>E: Plan comparison + cost impact
    S->>C: 🔵 GetUpdatedPlanRates
    activate C
    C-->>S: 🟠 PlanRatesUpdated
    deactivate C
    deactivate S

    opt Change Benefits
        E->>S: 🔵 ModifyBenefitElections
        activate S
        S->>S: 🟠 BenefitElectionModified
        S->>C: 🔵 SubmitChangesToCarrier
        activate C
        C->>S: 🟠 ChangesAcknowledged
        deactivate C
        S->>S: 🟠 BenefitsUpdated
        deactivate S
    else Keep Current
        E->>S: 🔵 ConfirmCurrentElections
        activate S
        S->>S: 🟠 BenefitElectionConfirmed
        S->>S: 🟠 BenefitsAutoRenewed
        deactivate S
    end

    Note over S,HR: === Post-Enrollment Processing ===

    S->>HR: 🔵 GenerateEnrollmentReport
    activate HR
    HR->>S: 🟠 EnrollmentReportGenerated
    S->>C: 🔵 SendFinalEnrollmentFile
    activate C
    C->>S: 🟠 CarrierFileAccepted
    deactivate C
    deactivate HR

    S->>S: 🟠 OpenEnrollmentCompleted
    S->>E: 🔵 SendUpdatedBenefitsCard
```

---

## Alternative Path A: Life Event Triggered Enrollment

```mermaid
sequenceDiagram
    autonumber
    participant E as 🟡 Employee
    participant S as 🟡 System
    participant HR as 🟡 HR Admin
    participant C as 🟡 Carrier

    E->>S: 🔵 ReportLifeEvent
    activate S
    alt Marriage
        S->>S: 🟠 MarriageRecorded
    else Birth of Child
        S->>S: 🟠 BirthRecorded
    else Divorce
        S->>S: 🟠 DivorceRecorded
    else Loss of Coverage
        S->>S: 🟠 LossOfCoverageRecorded
    end

    S->>S: 🔵 VerifyQualifyingLifeEvent
    S->>S: 🟠 QualifyingLifeEventVerified

    alt Within 30 Days of Event
        S->>S: 🟠 SpecialEnrollmentPeriodTriggered
        S->>E: 🔵 SendSpecialEnrollmentInvitation
        E->>S: 🔵 ModifyBenefitElections
        S->>S: 🟠 BenefitElectionModified
        S->>C: 🔵 SubmitQualifyingEventToCarrier
        activate C
        C->>S: 🟠 QualifyingEventProcessed
        deactivate C
    else Outside 30-Day Window
        S->>S: 🟠 SpecialEnrollmentDenied
        S->>E: 🔵 SendDenialNotification
        Note over E,S: Wait until Open Enrollment
    end
    deactivate S
```

---

## Alternative Path B: Dependent Verification

```mermaid
sequenceDiagram
    autonumber
    participant E as 🟡 Employee
    participant S as 🟡 System
    participant HR as 🟡 HR Admin
    participant C as 🟡 Carrier

    E->>S: 🔵 AddDependent
    activate S
    S->>S: 🟠 DependentAdded
    S->>E: 🔵 RequestEligibilityDocuments

    E->>S: 🔵 UploadEligibilityDocuments
    S->>S: 🟠 EligibilityDocumentUploaded

    alt Auto-Verification Enabled
        S->>S: 🔵 VerifyDocuments
        alt Documents Valid
            S->>S: 🟠 DependentVerified
            S->>C: 🔵 AddDependentToCarrier
            C->>S: 🟠 DependentAddedToCarrier
        else Documents Invalid
            S->>S: 🟠 DependentVerificationFailed
            S->>E: 🔵 RequestAdditionalDocumentation
        end
    else Manual Review Required
        S->>HR: 🔵 QueueForManualReview
        activate HR
        HR->>S: 🔵 ApproveDependent
        S->>S: 🟠 DependentVerified
        S->>C: 🔵 AddDependentToCarrier
        deactivate HR
    end
    deactivate S
```

---

## Alternative Path C: Carrier Sync Failure (H11)

```mermaid
sequenceDiagram
    autonumber
    participant S as 🟡 System
    participant C as 🟡 Carrier
    participant HR as 🟡 HR Admin
    participant E as 🟡 Employee

    S->>C: 🔵 SendEnrollmentFile
    activate C
    alt Format Error
        C->>S: 🟠 EnrollmentFileRejected
        Note over C: Reason: Invalid format
        deactivate C

        S->>S: 🟠 CarrierSyncFailed
        S->>HR: 🔵 AlertCarrierSyncFailure

        alt Retry Possible
            S->>C: 🔵 RetryEnrollmentFile
            activate C
            C->>S: 🟠 EnrollmentAcknowledged
            deactivate C
        else Manual Fallback Required
            S->>HR: 🔵 GenerateManualEnrollmentFile
            activate HR
            HR->>C: 🔵 SendManualFile
            C->>HR: 🟠 ManualFileAccepted
            deactivate HR
        end
    else Duplicate Member
        C->>S: 🟠 EnrollmentRejected
        Note over C: Reason: Duplicate enrollment
        deactivate C

        S->>S: 🟠 DuplicateEnrollmentDetected
        S->>HR: 🔵 AlertDuplicateEnrollment
        HR->>S: 🔵 ResolveDuplicate
        S->>S: 🟠 DuplicateResolved
    else Invalid Member Data
        C->>S: 🟠 EnrollmentRejected
        Note over C: Reason: Invalid member info
        deactivate C

        S->>E: 🔵 RequestDataCorrection
        activate E
        E->>S: 🔵 CorrectMemberData
        S->>C: 🔵 ResendCorrectedEnrollment
        activate C
        C->>S: 🟠 EnrollmentAcknowledged
        deactivate C
        deactivate E
    end
```

---

## Error Scenarios

| Scenario | Detection | Fallback | Owner |
|----------|-----------|----------|-------|
| **SI Registration Failed** | SI system rejection | Manual filing at SI office | HR Admin |
| **Carrier Enrollment rejected** | Carrier API rejection | Manual file submission | Benefits Admin |
| **Duplicate enrollment** | Carrier duplicate check | Resolve in system, resync | HR Admin |
| **Dependent verification failed** | Document validation | Request additional docs | Benefits Admin |
| **Life event outside window** | 30-day check | Defer to Open Enrollment | System |
| **Carrier sync timeout** | No ACK within SLA | Retry 3×, then manual file | Tech Lead |

---

## Multi-Country Benefits Variations

| Country | Statutory SI | Health Insurance | Retirement | Provident Fund |
|---------|--------------|------------------|------------|----------------|
| **Vietnam** | BHXH 17.5%+8%, BHYT 3%+1.5%, BHTN 1%+1% | Mandatory via SI | Social pension via BHXH | Voluntary |
| **Singapore** | CPF (varies 5-20%) | MediSave via CPF | CPF Ordinary + Special | N/A |
| **Malaysia** | EPF 12%+11%, SOCSO, EIS | Mandatory via SOCSO | EPF retirement | N/A |
| **Thailand** | SSF 5%+5% | Mandatory via SSF | Social security pension | N/A |
| **Indonesia** | BPJS TK 3.7%+2%, BPJS 4%+1% | Mandatory via BPJS | Pension via BPJS | Voluntary |
| **Philippines** | SSS 9.5%, PhilHealth 4.5%, Pag-IBIG 2% | Mandatory via PhilHealth | SSS pension | Pag-IBIG MP2 |

---

## Event Checklist

### Events in Happy Path
- [ ] 🟠 `EmployeeRegistered`
- [ ] 🟠 `BenefitsEligibilityDetermined`
- [ ] 🟠 `EnrollmentInvitationSent`
- [ ] 🟠 `SIEnrollmentSubmitted`
- [ ] 🟠 `SIRegistrationConfirmed`
- [ ] 🟠 `SIContributionCalculated`
- [ ] 🟠 `HealthInsuranceElected`
- [ ] 🟠 `EnrollmentAcknowledged`
- [ ] 🟠 `CarrierEnrollmentConfirmed`
- [ ] 🟠 ⭐ `FlexCreditAllocated`
- [ ] 🟠 `FlexBenefitsEnrolled`
- [ ] 🟠 `TaxBenefitRegistered`
- [ ] 🟠 `BenefitsSummaryGenerated`
- [ ] 🟠 `BenefitsEnrollmentCompleted`

### Commands in Flow
- [ ] 🔵 `RegisterNewEmployee`
- [ ] 🔵 `CalculateBenefitsEligibility`
- [ ] 🔵 `SendEnrollmentInvitation`
- [ ] 🔵 `ViewBenefitsOptions`
- [ ] 🔵 `EnrollInStatutorySI`
- [ ] 🔵 `SubmitSIRegistration`
- [ ] 🔵 `ElectHealthInsurance`
- [ ] 🔵 `SubmitCarrierEnrollment`
- [ ] 🔵 `ShowFlexCreditsMarketplace`
- [ ] 🔵 `AllocateFlexCredits`
- [ ] 🔵 `RegisterForTaxBenefit`
- [ ] 🔵 `GenerateBenefitsSummary`
- [ ] 🔵 `SendBenefitsConfirmation`

---

## Related Documents

| Document | Purpose |
|----------|---------|
| `00-session-brief.md` | Domain Events catalog |
| `01-commands-actors.md` | Commands and Actors mapping |
| `02-hot-spots.md` | Hot Spots (H01, H03, H10, H11, H18) |
| `../BRD/04-BRD-Benefits.md` | Benefits business rules |
| `../BRD/02-BRD-Calculation-Rules.md` | SI calculation rules |

---

**Next Timeline**: [`timeline-variable-pay.md`](./timeline-variable-pay.md) — Variable Pay Calculation Flow
