# Glossary - Configuration Validation Bounded Context

> **Bounded Context**: Configuration Validation (BC-006)
> **Module**: Payroll (PR)
> **Phase**: Domain Architecture (Step 3)
> **Date**: 2026-03-31

---

## Ubiquitous Language

This glossary defines the terms used within the Configuration Validation bounded context. All team members should use these terms consistently when discussing validation and conflict detection.

---

## Entities

### ValidationRule

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **ValidationRule** | Rule definition for validating configuration consistency. Service-oriented, not aggregate root in traditional sense. | Not PayElement/Profile (which are validated). Not business rule (domain concept). |
| **ruleCode** | Unique identifier for the validation rule. Human-readable like "VAL_UNIQUE_ELEMENT". | For reference and logging. |
| **ruleName** | Human-readable name like "Unique Element Code Validation". | For display. |
| **validationType** | Type of validation: FIELD, CROSS_FIELD, ENTITY, CROSS_ENTITY, BUSINESS_RULE. | Determines scope. |
| **targetEntity** | Entity being validated: PayElement, PayProfile, StatutoryRule, etc. | For rule scope. |
| **targetField** | Field being validated (for FIELD type). | Specific attribute. |
| **severity** | Severity level: ERROR, WARNING, INFO. | Determines blocking behavior. |
| **messageTemplate** | Message template with placeholders like "Element code {code} already exists". | For user feedback. |
| **isActive** | Flag indicating rule is active for validation. | Can be disabled. |

---

### ValidationResult

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **ValidationResult** | Result of a validation operation containing pass/fail status and details. | Not ValidationRule (definition). Not exception. |
| **validationId** | Unique identifier for the validation run. | For tracking. |
| **validatedAt** | Timestamp when validation was performed. | For audit. |
| **entityType** | Type of entity validated. | For context. |
| **entityId** | Identifier of entity validated. | For context. |
| **status** | Overall status: PASS, FAIL, PARTIAL. | Summary result. |
| **ruleResults** | List of individual rule results. | Detailed breakdown. |
| **canProceed** | Flag indicating if operation can proceed (no ERROR level failures). | For workflow control. |

---

### RuleResult

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **RuleResult** | Result of a single validation rule check. | Part of ValidationResult. Not standalone entity. |
| **ruleCode** | Reference to ValidationRule that was checked. | For identification. |
| **ruleName** | Name of the rule. | For display. |
| **severity** | Severity level of the rule. | For priority. |
| **passed** | Flag indicating rule passed. | Boolean result. |
| **message** | Actual message with values substituted. | User feedback. |
| **fieldPath** | Field path that failed (if applicable). | For UI highlighting. |
| **suggestedFix** | Suggested fix for the issue. | Optional guidance. |

---

### Conflict

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **Conflict** | Detected configuration conflict between entities or versions. | Not ValidationResult (general validation). Specific conflict type. |
| **conflictId** | Unique identifier for the conflict. | For tracking and resolution. |
| **conflictType** | Type: VERSION_OVERLAP, DUPLICATE_ENTITY, CIRCULAR_REFERENCE, REFERENCE_MISSING. | For categorization. |
| **entityType1** | First entity involved in conflict. | For context. |
| **entityId1** | Identifier of first entity. | For context. |
| **entityType2** | Second entity involved (if applicable). | For context. |
| **entityId2** | Identifier of second entity. | For context. |
| **description** | Human-readable conflict description. | For user understanding. |
| **severity** | Severity: CRITICAL, HIGH, MEDIUM, LOW. | For priority. |
| **status** | Conflict status: DETECTED, ACKNOWLEDGED, RESOLVED, IGNORED. | For workflow. |
| **detectedAt** | Timestamp when conflict was detected. | For audit. |
| **resolvedAt** | Timestamp when conflict was resolved. | For audit. |
| **resolutionType** | How resolved: AUTO, MANUAL_OVERRIDE, CORRECTION. | For audit. |
| **resolutionBy** | User who resolved the conflict. | For audit. |
| **resolutionNote** | Note explaining resolution. | For audit. |

---

## Value Objects

### ValidationType

| Value | Definition | Scope |
|-------|------------|-------|
| **FIELD** | Single field constraint | Single attribute |
| **CROSS_FIELD** | Multiple field consistency | Same entity, multiple fields |
| **ENTITY** | Entity completeness | Whole entity |
| **CROSS_ENTITY** | Reference validity | Multiple entities |
| **BUSINESS_RULE** | Domain-specific rules | Domain logic |

### Severity

| Value | Definition | Behavior |
|-------|------------|----------|
| **ERROR** | Critical validation failure | Blocks save operation |
| **WARNING** | Non-blocking issue | Shows warning, allows save |
| **INFO** | Informational message | Displays to user |

### ConflictType

| Value | Definition | Example |
|-------|------------|---------|
| **VERSION_OVERLAP** | Overlapping SCD-2 effective dates | Two PayElement versions overlap |
| **DUPLICATE_ENTITY** | Duplicate entity in same scope | Two BHXH_EE rules for same period |
| **CIRCULAR_REFERENCE** | Formula circular dependency | Formula A references B, B references A |
| **REFERENCE_MISSING** | Referenced entity not found | PayProfile references deleted PayElement |
| **IN_USE_CONFLICT** | Entity in use preventing delete | PayElement assigned to active profile |

### ConflictStatus

| Value | Definition |
|-------|------------|
| **DETECTED** | Conflict newly detected |
| **ACKNOWLEDGED** | User acknowledged conflict |
| **RESOLVED** | Conflict resolved |
| **IGNORED** | User chose to ignore (with override) |

---

## Events

### Validation Events

| Event | Definition | Khac voi |
|-------|------------|----------|
| **ConfigurationValidated** | Configuration validation passed. | All rules passed. |
| **ConfigurationValidationFailed** | Configuration validation failed. | At least one ERROR rule failed. |
| **ValidationWarningRaised** | Warning level validation issue. | Non-blocking issue. |

### Conflict Events

| Event | Definition | Khac voi |
|-------|------------|----------|
| **ConflictDetected** | A configuration conflict was detected. | New conflict. |
| **ConflictAcknowledged** | User acknowledged the conflict. | Awareness recorded. |
| **ConflictResolved** | Conflict was resolved. | Resolution logged. |
| **CircularReferenceDetected** | Circular formula reference detected. | Specific conflict type. |
| **VersionConflictDetected** | Overlapping version dates detected. | Specific conflict type. |

---

## Commands

| Command | Actor | Description |
|---------|-------|-------------|
| **ValidateConfiguration** | Payroll Admin, System | Validate entity before save |
| **ValidateAll** | Payroll Admin | Validate all entities in scope |
| **DetectConflicts** | System | Scan for configuration conflicts |
| **AcknowledgeConflict** | Payroll Admin | Acknowledge detected conflict |
| **ResolveConflict** | Payroll Admin | Resolve conflict manually |
| **OverrideConflict** | Payroll Admin | Override conflict with acknowledgment |
| **QueryValidationHistory** | Payroll Admin | Query validation results history |
| **QueryConflicts** | Payroll Admin | Query unresolved conflicts |

---

## Validation Rules Catalog

### PayElement Validation Rules

| Rule Code | Type | Severity | Description |
|-----------|------|----------|-------------|
| VAL_PE_UNIQUE_CODE | CROSS_ENTITY | ERROR | Element code must be unique per legal entity |
| VAL_PE_CODE_FORMAT | FIELD | ERROR | Element code format validation (alphanumeric, max 50 chars) |
| VAL_PE_NAME_REQUIRED | FIELD | ERROR | Element name is required |
| VAL_PE_CLASSIFICATION | FIELD | ERROR | Classification must be valid enum value |
| VAL_PE_CALC_TYPE | FIELD | ERROR | Calculation type must be valid enum value |
| VAL_PE_FORMULA_REF | CROSS_ENTITY | WARNING | Formula reference must exist if calculationType = FORMULA |
| VAL_PE_RATE_RANGE | FIELD | ERROR | Rate must be between 0 and 1 |
| VAL_PE_AMOUNT_POSITIVE | FIELD | ERROR | Amount must be non-negative |
| VAL_PE_IN_USE | CROSS_ENTITY | ERROR | Cannot delete element in use by active profile |

### PayProfile Validation Rules

| Rule Code | Type | Severity | Description |
|-----------|------|----------|-------------|
| VAL_PP_UNIQUE_CODE | CROSS_ENTITY | ERROR | Profile code must be unique per legal entity |
| VAL_PP_LE_REF | CROSS_ENTITY | ERROR | Legal entity must exist |
| VAL_PP_FREQ_REF | CROSS_ENTITY | ERROR | Pay frequency must exist |
| VAL_PP_NO_ELEMENTS | ENTITY | WARNING | Profile has no pay elements assigned |
| VAL_PP_DUPLICATE_ELEMENT | CROSS_ENTITY | ERROR | Same element cannot be assigned twice |
| VAL_PP_ELEMENT_ACTIVE | CROSS_ENTITY | ERROR | Assigned element must be active |
| VAL_PP_PRIORITY_RANGE | FIELD | ERROR | Priority must be 1-99 |
| VAL_PP_STATUTORY_ACTIVE | CROSS_ENTITY | ERROR | Assigned statutory rule must be active |

### StatutoryRule Validation Rules

| Rule Code | Type | Severity | Description |
|-----------|------|----------|-------------|
| VAL_SR_UNIQUE_TYPE | CROSS_ENTITY | ERROR | Only one rule per statutoryType+partyType per period |
| VAL_SR_RATE_RANGE | FIELD | ERROR | Rate must be between 0 and 1 |
| VAL_SR_CEILING_REQUIRED | FIELD | ERROR | Ceiling required for BHXH, BHYT, BHTN |
| VAL_SR_BRACKET_COVERAGE | ENTITY | ERROR | PIT brackets must cover full income range |
| VAL_SR_VERSION_OVERLAP | CROSS_ENTITY | ERROR | Version effective dates cannot overlap |
| VAL_SR_GOVT_RATE_CHECK | BUSINESS_RULE | WARNING | Rate differs from government rate |

### Formula Validation Rules

| Rule Code | Type | Severity | Description |
|-----------|------|----------|-------------|
| VAL_FM_SYNTAX | FIELD | ERROR | Formula syntax must be valid |
| VAL_FM_REFERENCE_EXISTS | CROSS_ENTITY | ERROR | Referenced elements must exist |
| VAL_FM_CIRCULAR_REF | CROSS_ENTITY | ERROR | No circular reference allowed |
| VAL_FM_DIVISION_ZERO | FIELD | ERROR | Division by zero must be handled |
| VAL_FM_FUNCTION_VALID | FIELD | ERROR | Function must be valid (IF, MIN, MAX, etc.) |

---

## Conflict Detection Examples

### Version Overlap Conflict

```
Conflict Detection:

PayElement "BHXH_EE" versions:
  Version 1: effective 2026-01-01 to 2026-06-30
  Version 2: effective 2026-07-01 to null (current)

New version creation attempt:
  effectiveStartDate: 2026-06-15

Detected Conflict:
{
  conflictType: VERSION_OVERLAP,
  entityType1: PayElement,
  entityId1: BHXH_EE,
  entityType2: PayElementVersion,
  entityId2: BHXH_EE_V1,
  description: "New version effective date overlaps with existing version 1",
  severity: CRITICAL,
  status: DETECTED
}

Resolution:
  Option 1: Adjust effectiveStartDate to 2026-07-01
  Option 2: Override with acknowledgment and documentation
```

### Circular Reference Conflict

```
Conflict Detection:

Formula A: "{SALARY_BASIC} + {BONUS}"
Formula B: "{TOTAL_PAY} - {SALARY_BASIC}"

PayElement TOTAL_PAY references Formula A
PayElement BONUS references Formula B

Dependency chain:
  TOTAL_PAY -> Formula A -> BONUS -> Formula B -> TOTAL_PAY

Detected Conflict:
{
  conflictType: CIRCULAR_REFERENCE,
  entityType1: PayFormula,
  entityId1: Formula_A,
  entityType2: PayFormula,
  entityId2: Formula_B,
  description: "Circular reference: Formula_A -> Formula_B -> Formula_A",
  severity: CRITICAL,
  status: DETECTED
}

Resolution:
  Break the cycle by modifying one formula to not reference the other
```

---

## Integration Points

### Inbound Integrations

| Source | Data | Purpose |
|--------|------|---------|
| All BCs | Entity data | Validation requests |
| Payroll Configuration | Formula references | Circular reference detection |

### Outbound Integrations

| Target | Data | Purpose |
|--------|------|---------|
| All BCs | Validation results | Save approval/blocking |
| Audit Trail | Validation events | Audit logging |
| UI | Validation messages | User feedback |

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Domain Architect Agent