# Event Storming - Payroll Module (PR)

> **Module**: Payroll (PR)
> **Phase**: Reality (Step 2)
> **Date**: 2026-03-31
> **Version**: 1.0

---

## Overview

Event Storming is a collaborative workshop technique to explore domain events, commands, actors, and aggregates. This document captures the domain model discovered through event storming for the Payroll configuration module.

---

## Event Storming Notation

| Color | Element | Meaning |
|-------|---------|---------|
| Orange | Domain Event | Something that happened (past tense) |
| Blue | Command | Intent to do something (imperative) |
| Yellow | Actor/Role | Who initiates commands |
| Pink | Aggregate | Entity boundary for consistency |
| Green | Policy | Reaction to events |
| Purple | External System | Integration point |
| Red | Hot Spot | Problem area needing resolution |

---

## Domain Events

### Configuration Events (Orange)

| Event ID | Event Name | Description | Source Aggregate |
|----------|------------|-------------|------------------|
| E001 | PayElementCreated | A new pay element was created | PayElement |
| E002 | PayElementUpdated | A pay element was modified | PayElement |
| E003 | PayElementDeleted | A pay element was soft-deleted | PayElement |
| E004 | PayElementVersionCreated | A new version of pay element was created | PayElement |
| E005 | PayProfileCreated | A new pay profile was created | PayProfile |
| E006 | PayProfileUpdated | A pay profile was modified | PayProfile |
| E007 | PayProfileDeleted | A pay profile was soft-deleted | PayProfile |
| E008 | PayProfileVersionCreated | A new version of pay profile was created | PayProfile |
| E009 | PayElementAssigned | A pay element was assigned to profile | PayElementAssignment |
| E010 | PayElementUnassigned | A pay element was removed from profile | PayElementAssignment |
| E011 | StatutoryRuleCreated | A statutory rule was created | StatutoryRule |
| E012 | StatutoryRuleUpdated | A statutory rule was modified | StatutoryRule |
| E013 | StatutoryRuleDeleted | A statutory rule was soft-deleted | StatutoryRule |
| E014 | StatutoryRuleVersionCreated | A new version of statutory rule was created | StatutoryRule |
| E015 | PITBracketConfigured | PIT progressive brackets were configured | StatutoryRule |
| E016 | FormulaCreated | A formula was created | PayFormula |
| E017 | FormulaUpdated | A formula was modified | PayFormula |
| E018 | FormulaValidated | A formula validation completed | PayFormula |
| E019 | FormulaValidationFailed | A formula validation failed | PayFormula |
| E020 | PayCalendarCreated | A pay calendar was created | PayCalendar |
| E021 | PayCalendarUpdated | A pay calendar was modified | PayCalendar |
| E022 | PayPeriodGenerated | Pay periods were auto-generated | PayCalendar |
| E023 | PayPeriodAdjusted | A pay period was manually adjusted | PayCalendar |
| E024 | PayGroupCreated | A pay group was created | PayGroup |
| E025 | PayGroupUpdated | A pay group was modified | PayGroup |
| E026 | PayGroupDeleted | A pay group was soft-deleted | PayGroup |
| E027 | EmployeeAssignedToGroup | An employee was assigned to pay group | PayGroupAssignment |
| E028 | EmployeeRemovedFromGroup | An employee was removed from pay group | PayGroupAssignment |
| E029 | GLMappingCreated | A GL account mapping was created | GLMappingPolicy |
| E030 | GLMappingUpdated | A GL account mapping was modified | GLMappingPolicy |
| E031 | BankTemplateCreated | A bank file template was created | BankTemplate |
| E032 | BankTemplateUpdated | A bank file template was modified | BankTemplate |

### Validation Events

| Event ID | Event Name | Description | Source Aggregate |
|----------|------------|-------------|------------------|
| E033 | ConfigurationValidated | Configuration validation passed | ValidationRule |
| E034 | ConfigurationValidationFailed | Configuration validation failed | ValidationRule |
| E035 | ConflictDetected | A configuration conflict was detected | ValidationRule |
| E036 | ConflictResolved | A configuration conflict was resolved | ValidationRule |
| E037 | CircularReferenceDetected | Circular reference in formula detected | PayFormula |
| E038 | VersionConflictDetected | Overlapping version dates detected | PayElement/StatutoryRule |

### Audit Events

| Event ID | Event Name | Description | Source Aggregate |
|----------|------------|-------------|------------------|
| E039 | AuditLogCreated | An audit log entry was created | AuditLog |
| E040 | AuditLogQueried | Audit log was queried by user | AuditLog |
| E041 | AuditReportExported | Audit report was exported | AuditLog |

### Integration Events (Inbound)

| Event ID | Event Name | Description | Source |
|----------|------------|-------------|--------|
| E042 | WorkerDataReceived | Worker data received from Core HR | External: CO |
| E043 | LegalEntityDataReceived | Legal entity data received | External: CO |
| E044 | AssignmentDataReceived | Assignment data received | External: CO |
| E045 | AttendanceDataReceived | Attendance data received from TA | External: TA |
| E046 | OvertimeDataReceived | Overtime data received from TA | External: TA |
| E047 | LeaveDataReceived | Leave data received from TA | External: TA |
| E048 | SalaryDataReceived | Salary data received from TR | External: TR |
| E049 | AllowanceDataReceived | Allowance data received from TR | External: TR |
| E050 | BenefitsDataReceived | Benefits enrollment data received | External: TR |

### Integration Events (Outbound)

| Event ID | Event Name | Description | Target |
|----------|------------|-------------|--------|
| E051 | ConfigurationSnapshotGenerated | Configuration snapshot for calculation engine | External: CalcEngine |
| E052 | GLMappingExportRequested | GL mapping export requested | External: Finance |
| E053 | BankTemplateExportRequested | Bank template export requested | External: Banking |

---

## Commands (Blue)

### Pay Element Commands

| Command ID | Command Name | Description | Actor | Target Aggregate |
|------------|--------------|-------------|-------|------------------|
| C001 | CreatePayElement | Create a new pay element | Payroll Admin | PayElement |
| C002 | UpdatePayElement | Update an existing pay element | Payroll Admin | PayElement |
| C003 | DeletePayElement | Soft delete a pay element | Payroll Admin | PayElement |
| C004 | QueryPayElement | Query pay element by code | Payroll Admin | PayElement |
| C005 | QueryPayElementVersions | Query version history | Payroll Admin | PayElement |
| C006 | ComparePayElementVersions | Compare two versions | Payroll Admin | PayElement |

### Pay Profile Commands

| Command ID | Command Name | Description | Actor | Target Aggregate |
|------------|--------------|-------------|-------|------------------|
| C007 | CreatePayProfile | Create a new pay profile | Payroll Admin | PayProfile |
| C008 | UpdatePayProfile | Update an existing pay profile | Payroll Admin | PayProfile |
| C009 | DeletePayProfile | Soft delete a pay profile | Payroll Admin | PayProfile |
| C010 | AssignPayElement | Assign element to profile | Payroll Admin | PayElementAssignment |
| C011 | UnassignPayElement | Remove element from profile | Payroll Admin | PayElementAssignment |
| C012 | OverrideElementFormula | Override formula for assignment | Payroll Admin | PayElementAssignment |
| C013 | QueryPayProfileVersions | Query version history | Payroll Admin | PayProfile |

### Statutory Rule Commands

| Command ID | Command Name | Description | Actor | Target Aggregate |
|------------|--------------|-------------|-------|------------------|
| C014 | CreateStatutoryRule | Create a new statutory rule | Payroll Admin | StatutoryRule |
| C015 | UpdateStatutoryRule | Update an existing statutory rule | Payroll Admin | StatutoryRule |
| C016 | DeleteStatutoryRule | Soft delete a statutory rule | Payroll Admin | StatutoryRule |
| C017 | ConfigurePITBrackets | Configure progressive tax brackets | Payroll Admin | StatutoryRule |
| C018 | SetPITExemptions | Set personal and dependent exemptions | Payroll Admin | StatutoryRule |
| C019 | QueryStatutoryRuleVersions | Query version history | Payroll Admin | StatutoryRule |
| C020 | QueryStatutoryRuleByDate | Query rule effective on a date | Payroll Admin | StatutoryRule |

### Formula Commands

| Command ID | Command Name | Description | Actor | Target Aggregate |
|------------|--------------|-------------|-------|------------------|
| C021 | CreateFormula | Create a new formula | Payroll Admin | PayFormula |
| C022 | UpdateFormula | Update an existing formula | Payroll Admin | PayFormula |
| C023 | DeleteFormula | Delete a formula | Payroll Admin | PayFormula |
| C024 | ValidateFormula | Validate formula syntax and references | Payroll Admin | PayFormula |
| C025 | PreviewFormula | Preview formula result with sample values | Payroll Admin | PayFormula |

### Pay Calendar Commands

| Command ID | Command Name | Description | Actor | Target Aggregate |
|------------|--------------|-------------|-------|------------------|
| C026 | CreatePayCalendar | Create a new pay calendar | Payroll Admin | PayCalendar |
| C027 | UpdatePayCalendar | Update an existing pay calendar | Payroll Admin | PayCalendar |
| C028 | GeneratePayPeriods | Generate pay periods for calendar | Payroll Admin | PayCalendar |
| C029 | AdjustPayPeriod | Manually adjust a pay period | Payroll Admin | PayCalendar |
| C030 | QueryPayCalendar | Query calendar by legal entity | Payroll Admin | PayCalendar |

### Pay Group Commands

| Command ID | Command Name | Description | Actor | Target Aggregate |
|------------|--------------|-------------|-------|------------------|
| C031 | CreatePayGroup | Create a new pay group | Payroll Admin | PayGroup |
| C032 | UpdatePayGroup | Update an existing pay group | Payroll Admin | PayGroup |
| C033 | DeletePayGroup | Soft delete a pay group | Payroll Admin | PayGroup |
| C034 | AssignEmployeeToGroup | Assign employee to pay group | Payroll Admin | PayGroupAssignment |
| C035 | RemoveEmployeeFromGroup | Remove employee from pay group | Payroll Admin | PayGroupAssignment |
| C036 | QueryPayGroup | Query pay group by code | Payroll Admin | PayGroup |

### Validation Commands

| Command ID | Command Name | Description | Actor | Target Aggregate |
|------------|--------------|-------------|-------|------------------|
| C037 | ValidateConfiguration | Validate configuration before save | Payroll Admin | ValidationRule |
| C038 | DetectConflicts | Detect configuration conflicts | System | ValidationRule |
| C039 | ResolveConflict | Resolve a detected conflict | Payroll Admin | ValidationRule |

### Audit Commands

| Command ID | Command Name | Description | Actor | Target Aggregate |
|------------|--------------|-------------|-------|------------------|
| C040 | QueryAuditLog | Query audit log entries | HR Manager | AuditLog |
| C041 | FilterAuditLogByDate | Filter audit by date range | HR Manager | AuditLog |
| C042 | FilterAuditLogByEntity | Filter audit by entity type | HR Manager | AuditLog |
| C043 | FilterAuditLogByUser | Filter audit by user | HR Manager | AuditLog |
| C044 | ExportAuditLog | Export audit log report | Compliance Officer | AuditLog |

### GL Mapping Commands

| Command ID | Command Name | Description | Actor | Target Aggregate |
|------------|--------------|-------------|-------|------------------|
| C045 | CreateGLMapping | Create GL account mapping | Finance Controller | GLMappingPolicy |
| C046 | UpdateGLMapping | Update GL account mapping | Finance Controller | GLMappingPolicy |
| C047 | DeleteGLMapping | Delete GL account mapping | Finance Controller | GLMappingPolicy |
| C048 | QueryGLMapping | Query mappings for element | Finance Controller | GLMappingPolicy |
| C049 | ExportGLMappings | Export mappings for finance | Finance Controller | GLMappingPolicy |

### Bank Template Commands

| Command ID | Command Name | Description | Actor | Target Aggregate |
|------------|--------------|-------------|-------|------------------|
| C050 | CreateBankTemplate | Create bank file template | Payroll Admin | BankTemplate |
| C051 | UpdateBankTemplate | Update bank file template | Payroll Admin | BankTemplate |
| C052 | DeleteBankTemplate | Delete bank file template | Payroll Admin | BankTemplate |
| C053 | ConfigureFieldMapping | Configure field mapping | Payroll Admin | BankTemplate |
| C054 | PreviewBankTemplate | Preview template output | Payroll Admin | BankTemplate |

---

## Actors (Yellow)

| Actor ID | Actor Name | Description | Commands Initiated |
|----------|------------|-------------|-------------------|
| A001 | Payroll Admin | Primary configuration user | C001-C036, C037-C039, C050-C054 |
| A002 | HR Manager | Reviews configurations, queries audit | C040-C044 |
| A003 | Finance Controller | Configures GL mappings | C045-C049 |
| A004 | Compliance Officer | Validates statutory rules, exports audit | C014-C020, C044 |
| A005 | System | Automated processes, validation | C038 |
| A006 | Core HR (CO) | Sends worker data | (External trigger) |
| A007 | Time & Absence (TA) | Sends time data | (External trigger) |
| A008 | Total Rewards (TR) | Sends compensation data | (External trigger) |
| A009 | Calculation Engine | Requests configuration snapshot | (External trigger) |
| A010 | Finance System | Requests GL mappings | (External trigger) |
| A011 | Banking System | Requests bank templates | (External trigger) |

---

## Aggregates (Pink)

### Aggregate Definition

An aggregate is a cluster of associated objects that we treat as a unit for purpose of data changes. Each aggregate has a root and a boundary.

### Aggregate Roots

| Aggregate ID | Aggregate Name | Description | Entities Inside | Key Commands | Key Events |
|--------------|----------------|-------------|-----------------|--------------|------------|
| AG001 | PayElement | Fundamental payroll component | None (leaf) | C001-C006 | E001-E004 |
| AG002 | PayProfile | Configuration bundle for employee group | PayElementAssignment, StatutoryRuleAssignment | C007-C013 | E005-E010 |
| AG003 | StatutoryRule | Government-mandated rule | TaxBracket (collection) | C014-C020 | E011-E015 |
| AG004 | PayFormula | Calculation formula | None (leaf) | C021-C025 | E016-E019 |
| AG005 | PayCalendar | Pay period definition | PayPeriod (collection) | C026-C030 | E020-E023 |
| AG006 | PayGroup | Employee assignment to payroll | PayGroupAssignment (collection) | C031-C036 | E024-E028 |
| AG007 | GLMappingPolicy | GL account allocation | GLMapping (collection) | C045-C049 | E029-E030 |
| AG008 | BankTemplate | Bank file format configuration | FieldMapping (collection) | C050-C054 | E031-E032 |
| AG009 | ValidationRule | Configuration validation | None (service) | C037-C039 | E033-E038 |
| AG010 | AuditLog | Change audit trail | AuditEntry (collection) | C040-C044 | E039-E041 |

### Aggregate Boundaries

```
PayElement (AG001)
├── [ROOT] PayElement
│   ├── elementCode
│   ├── elementName
│   ├── classification
│   ├── calculationType
│   ├── statutoryFlag
│   ├── taxableFlag
│   ├── formulaId -> PayFormula
│   ├── effectiveStartDate (SCD-2)
│   ├── effectiveEndDate (SCD-2)
│   └── isCurrentFlag
└── [VERSIONING] SCD-2 pattern enforced

PayProfile (AG002)
├── [ROOT] PayProfile
│   ├── profileCode
│   ├── profileName
│   ├── legalEntityId -> LegalEntity (CO)
│   ├── payFrequencyId -> PayFrequency
│   ├── effectiveStartDate (SCD-2)
│   ├── effectiveEndDate (SCD-2)
│   └── isCurrentFlag
└── [ENTITY] PayElementAssignment
│   ├── payElementId -> PayElement
│   ├── priority
│   ├── formulaOverride
│   ├── rateOverride
│   ├── amountOverride
│   ├── effectiveStartDate
│   └── effectiveEndDate
└── [ENTITY] StatutoryRuleAssignment
│   ├── statutoryRuleId -> StatutoryRule
│   ├── effectiveStartDate
│   └── effectiveEndDate

StatutoryRule (AG003)
├── [ROOT] StatutoryRule
│   ├── ruleCode
│   ├── ruleName
│   ├── statutoryType
│   ├── partyType
│   ├── rateType
│   ├── rate
│   ├── ceilingAmount
│   ├── effectiveStartDate (SCD-2)
│   ├── effectiveEndDate (SCD-2)
│   └── isCurrentFlag
└── [VALUE OBJECT] TaxBracket
│   ├── bracketNumber
│   ├── minAmount
│   ├── maxAmount
│   ├── rate

PayCalendar (AG005)
├── [ROOT] PayCalendar
│   ├── calendarCode
│   ├── calendarName
│   ├── legalEntityId -> LegalEntity (CO)
│   ├── payFrequencyId -> PayFrequency
│   ├── fiscalYear
└── [ENTITY] PayPeriod
│   ├── periodNumber
│   ├── periodStartDate
│   ├── periodEndDate
│   ├── cutOffDate
│   ├── payDate

PayGroup (AG006)
├── [ROOT] PayGroup
│   ├── groupCode
│   ├── groupName
│   ├── payProfileId -> PayProfile
│   ├── payCalendarId -> PayCalendar
└── [ENTITY] PayGroupAssignment
│   ├── employeeId -> Worker (CO)
│   ├── assignmentDate
│   ├── removalDate (nullable)

GLMappingPolicy (AG007)
├── [ROOT] GLMappingPolicy
│   ├── policyCode
│   ├── policyName
│   ├── payElementId -> PayElement
└── [ENTITY] GLMapping
│   ├── glAccountCode
│   ├── costCenter
│   ├── debitCredit
│   ├── percentage
│   ├── description

BankTemplate (AG008)
├── [ROOT] BankTemplate
│   ├── templateCode
│   ├── templateName
│   ├── bankCode
│   ├── fileFormat
└── [ENTITY] FieldMapping
│   ├── sourceField
│   ├── targetField
│   ├── position
│   ├── format
```

---

## Policies (Green)

Policies are reactions to events that trigger new commands.

| Policy ID | Policy Name | Trigger Event | Action Command | Description |
|-----------|-------------|---------------|----------------|-------------|
| P001 | CreateAuditOnCreate | PayElementCreated | CreateAuditEntry | Log creation in audit trail |
| P002 | CreateAuditOnUpdate | PayElementUpdated | CreateAuditEntry | Log update in audit trail |
| P003 | CreateVersionOnUpdate | PayElementUpdated | CreateNewVersion | Create new version for SCD-2 |
| P004 | ValidateOnAssignment | PayElementAssigned | ValidateConfiguration | Validate assignment consistency |
| P005 | ValidateElementActive | AssignPayElement | ValidateElementStatus | Check element is active before assignment |
| P006 | CreateVersionOnStatutoryUpdate | StatutoryRuleUpdated | CreateNewVersion | Version statutory rule changes |
| P007 | ValidateFormulaOnSave | FormulaCreated/Updated | ValidateFormula | Validate syntax and references |
| P008 | CheckCircularReference | FormulaCreated/Updated | DetectCircularRef | Detect circular dependencies |
| P009 | GeneratePeriodsOnCalendarCreate | PayCalendarCreated | GeneratePayPeriods | Auto-generate periods based on frequency |
| P010 | ValidateSingleEmployeeAssignment | AssignEmployeeToGroup | ValidateEmployeeAssignment | Check employee not already assigned |
| P011 | NotifyOnConflictDetected | ConflictDetected | AlertAdmin | Notify admin of detected conflict |
| P012 | ValidateIntegrationData | WorkerDataReceived | ValidateReferences | Validate worker references exist |
| P013 | SnapshotOnRequest | ConfigurationSnapshotRequested | GenerateSnapshot | Generate configuration snapshot |
| P014 | ValidateProfileBeforeDelete | DeletePayProfile | ValidateProfileUsage | Check profile not in use |

---

## External Systems (Purple)

| System ID | System Name | Integration Type | Events Received | Events Sent |
|-----------|-------------|------------------|-----------------|-------------|
| ES001 | Core HR (CO) | Inbound API | - | E042-E044 |
| ES002 | Time & Absence (TA) | Inbound Batch | - | E045-E047 |
| ES003 | Total Rewards (TR) | Inbound API | - | E048-E050 |
| ES004 | Calculation Engine | Outbound API | E051 | - |
| ES005 | Finance/GL System | Outbound API/File | E052 | - |
| ES006 | Banking System | Outbound File | E053 | - |

---

## Hot Spots (Red)

Hot spots represent areas of complexity, ambiguity, or risk that need further investigation.

| Hot Spot ID | Hot Spot Name | Description | Category | Resolution Status |
|-------------|---------------|-------------|----------|-------------------|
| H001 | Formula Circular Reference | Complex formulas may reference each other creating circular dependencies | Technical | Needs detection algorithm |
| H002 | Statutory Rate Accuracy | Vietnam statutory rates must match government regulations exactly | Compliance | Needs expert validation |
| H003 | Version Query Performance | SCD-2 queries with many versions may be slow | Performance | Needs query optimization |
| H004 | Multi-Entity Pay Profile | Profile scope across legal entities unclear | Boundary | Resolved: Profile per legal entity |
| H005 | Formula Syntax Complexity | Non-technical users may struggle with formula syntax | UX | Needs formula builder POC |
| H006 | Integration Data Timing | When to cache vs. request fresh integration data | Architecture | Resolved: Cache with refresh |
| H007 | Conflict Resolution Workflow | How users resolve detected conflicts | Process | Needs UX design |
| H008 | Statutory Update Timing | Government rate changes mid-pay-period | Compliance | Needs effective date handling |
| H009 | Retroactive Configuration Change | Changing configuration affecting past periods | Calculation | Out of scope for configuration |
| H010 | Employee Assignment History | Tracking employee movement between pay groups | Audit | Resolved: PayGroupAssignment has dates |

---

## Event Timeline

### Pay Element Configuration Flow

```
Payroll Admin                     PayElement Aggregate              Audit Log
     │                                  │                              │
     ├─ CreatePayElement ───────────────►                              │
     │                                  ├─ validate                    │
     │                                  ├─ create element              │
     │                                  ├─ PayElementCreated           │
     │                                  │                              │
     │                                  ├─────────────────────────────►│
     │                                  │                              ├─ create entry
     │◄─ element created ───────────────┤                              │
     │                                  │                              │
```

### Pay Element Versioning Flow

```
Payroll Admin                     PayElement Aggregate              Audit Log
     │                                  │                              │
     ├─ UpdatePayElement ──────────────►                              │
     │   (with new rate)                ├─ validate                    │
     │                                  ├─ create new version          │
     │                                  ├─ close previous version      │
     │                                  ├─ PayElementUpdated           │
     │                                  ├─ PayElementVersionCreated    │
     │                                  │                              │
     │                                  ├─────────────────────────────►│
     │                                  │                              ├─ create entry
     │◄─ element updated ───────────────┤                              │
     │                                  │                              │
```

### Pay Profile Assignment Flow

```
Payroll Admin       PayProfile Aggregate      PayElementAggregate      ValidationRule
     │                      │                        │                      │
     ├─ AssignPayElement ───►                        │                      │
     │                      ├─ validate element ────►                      │
     │                      │                        ├─ check exists       │
     │                      │                        ├─ check active       │
     │                      │◄─ element valid ───────┤                      │
     │                      ├─ validate no duplicate │                      │
     │                      ├─ create assignment      │                      │
     │                      ├─ PayElementAssigned     │                      │
     │◄─ element assigned ──┤                        │                      │
     │                      │                        │                      │
```

### Statutory Rule Configuration Flow

```
Payroll Admin         StatutoryRule Aggregate        Audit Log
     │                        │                          │
     ├─ CreateStatutoryRule ─►                          │
     │                        ├─ validate rate          │
     │                        ├─ validate ceiling       │
     │                        ├─ create rule            │
     │                        ├─ StatutoryRuleCreated   │
     │                        ├────────────────────────►│
     │                        │                          ├─ create entry
     │◄─ rule created ────────┤                          │
     │                        │                          │
     ├─ ConfigurePITBrackets ─►                          │
     │                        ├─ validate bracket range │
     │                        ├─ create brackets        │
     │                        ├─ PITBracketConfigured   │
     │◄─ brackets configured ─┤                          │
     │                        │                          │
```

### Pay Calendar Generation Flow

```
Payroll Admin         PayCalendar Aggregate          PayPeriod
     │                       │                           │
     ├─ CreatePayCalendar ───►                           │
     │                       ├─ create calendar          │
     │                       ├─ PayCalendarCreated       │
     │◄─ calendar created ───┤                           │
     │                       │                           │
     ├─ GeneratePayPeriods ─►                            │
     │                       ├─ calculate period dates   │
     │                       ├─ create 12/52 periods     │
     │                       ├─ PayPeriodGenerated       │
     │◄─ periods generated ──┤                           │
     │                       │                           │
```

### Employee Assignment Flow

```
Payroll Admin     PayGroup Aggregate     PayGroupAssignment     ValidationRule
     │                   │                      │                      │
     ├─ AssignEmployee ─►                      │                      │
     │                   ├─ check employee ───►                      │
     │                   │                      ├─ check not assigned │
     │                   │◄─ employee valid ───┤                      │
     │                   ├─ create assignment   │                      │
     │                   ├─ EmployeeAssignedToGroup                    │
     │◄─ employee assigned ┤                    │                      │
     │                   │                      │                      │
```

### Formula Validation Flow

```
Payroll Admin         PayFormula Aggregate           ValidationRule
     │                        │                            │
     ├─ CreateFormula ───────►                            │
     │                        ├─ syntax check              │
     │                        ├─ ValidateFormula ─────────►
     │                        │                            ├─ check references
     │                        │                            ├─ detect circular
     │                        │◄─ validation result ───────┤
     │                        ├─ FormulaValidated          │
     │◄─ formula created ─────┤                            │
     │                        │                            │
```

### Integration Data Flow

```
Core HR (CO)         PR Integration Service         Configuration Cache
     │                       │                            │
     ├─ send worker data ───►                            │
     │                       ├─ validate data             │
     │                       ├─ cache worker              │
     │                       ├─ WorkerDataReceived        │
     │◄─ confirmation ───────┤                            │
     │                       │                            │
```

### Configuration Snapshot Flow

```
Calculation Engine   PR Integration Service         All Aggregates
     │                       │                            │
     ├─ request snapshot ───►                            │
     │                       ├─ query current versions    │
     │                       ├─ gather elements           │
     │                       ├─ gather profiles           │
     │                       ├─ gather statutory rules    │
     │                       ├─ ConfigurationSnapshotGenerated
     │◄─ snapshot data ──────┤                            │
     │                       │                            │
```

---

## Aggregate Interactions

### Dependency Graph

```
                    LegalEntity (CO)
                          │
                          │
            ┌─────────────┼─────────────┐
            │             │             │
            ▼             ▼             ▼
      PayCalendar    PayProfile    PayGroup
            │             │             │
            │             │             │
            │             ▼             │
            │      PayElementAssignment│
            │             │             │
            │             ▼             │
            │        PayElement         │
            │             │             │
            │             ▼             │
            │        PayFormula         │
            │             │             │
            │             │             ▼
            │             │      PayGroupAssignment
            │             │             │
            │             │             ▼
            │             │        Worker (CO)
            │             │             │
            └─────────────┼─────────────┘
                          │
                          ▼
                   StatutoryRule
                          │
                          ▼
                   TaxBracket (VO)
```

### Aggregate Relationship Matrix

| From Aggregate | To Aggregate | Relationship | Navigation |
|----------------|--------------|--------------|------------|
| PayProfile | PayElement | Reference (via Assignment) | profile.payElements[].elementId |
| PayProfile | StatutoryRule | Reference (via Assignment) | profile.statutoryRules[].ruleId |
| PayProfile | LegalEntity | Reference | profile.legalEntityId |
| PayProfile | PayFrequency | Reference | profile.payFrequencyId |
| PayGroup | PayProfile | Reference | group.payProfileId |
| PayGroup | PayCalendar | Reference | group.payCalendarId |
| PayGroup | Worker | Reference (via Assignment) | group.assignments[].employeeId |
| PayCalendar | LegalEntity | Reference | calendar.legalEntityId |
| PayCalendar | PayFrequency | Reference | calendar.payFrequencyId |
| PayElement | PayFormula | Reference | element.formulaId |
| GLMappingPolicy | PayElement | Reference | policy.payElementId |

---

## Domain Model Summary

### Event Count by Category

| Category | Count |
|----------|-------|
| Configuration Events | 32 |
| Validation Events | 6 |
| Audit Events | 3 |
| Integration Events (Inbound) | 9 |
| Integration Events (Outbound) | 3 |
| Total | 53 |

### Command Count by Aggregate

| Aggregate | Command Count |
|-----------|---------------|
| PayElement | 6 |
| PayProfile | 7 |
| StatutoryRule | 7 |
| PayFormula | 5 |
| PayCalendar | 5 |
| PayGroup | 6 |
| ValidationRule | 3 |
| AuditLog | 5 |
| GLMappingPolicy | 5 |
| BankTemplate | 5 |
| Total | 54 |

### Actor Responsibility Matrix

| Actor | Commands | Events Interested |
|-------|----------|-------------------|
| Payroll Admin | 45 | All configuration events |
| HR Manager | 5 | Audit events |
| Finance Controller | 5 | GL mapping events |
| Compliance Officer | 7 | Statutory rule events, audit events |
| System | 1 | Validation events |

---

## Recommendations for Domain Architecture

### Bounded Context Identification

Based on event storming, the following bounded contexts are recommended:

| Bounded Context | Aggregates | Description |
|-----------------|------------|-------------|
| Payroll Configuration | PayElement, PayProfile, PayFormula | Core configuration domain |
| Statutory Compliance | StatutoryRule, TaxBracket | Vietnam statutory rules |
| Payroll Calendar | PayCalendar, PayPeriod | Time-based scheduling |
| Payroll Assignment | PayGroup, PayGroupAssignment | Employee assignment |
| Finance Integration | GLMappingPolicy, BankTemplate | External system integration |
| Configuration Validation | ValidationRule | Cross-aggregate validation |
| Audit Trail | AuditLog | Compliance tracking |

### Key Design Decisions

1. **SCD-2 Versioning**: PayElement, PayProfile, StatutoryRule require version history
2. **Aggregate References**: Use IDs for cross-aggregate references, not object references
3. **Validation Service**: Cross-aggregate validation should be a domain service, not in aggregates
4. **Integration Layer**: External systems should communicate through integration services
5. **Event Publishing**: All configuration events should be published for audit and integration

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Business Analyst Agent