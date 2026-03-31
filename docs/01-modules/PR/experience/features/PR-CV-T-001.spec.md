# Feature Spec: Configuration Validation

> **Feature ID**: PR-CV-T-001
> **Classification**: Transaction (T)
> **Priority**: P0 (MVP)
> **Spec Depth**: Deep
> **Date**: 2026-03-31

---

## Overview

Configuration Validation is a transaction feature that validates payroll configuration across multiple levels: field, cross-field, entity, cross-entity, and business rule. It prevents invalid configurations from being saved and provides actionable feedback to users.

---

## Validation Workflow States

```
[Idle] --> [Editing] --> [Validating] --> [Result]
                                    |
                                    +--> [Error] --> [Editing]
                                    +--> [Warning] --> [Acknowledge] --> [Result]
                                    +--> [Pass] --> [Result]
```

| State | Description | User Action |
|-------|-------------|-------------|
| Idle | No validation running | None |
| Editing | User is modifying configuration | Continue editing |
| Validating | Validation in progress | Wait |
| Error | Critical validation error | Fix error, retry |
| Warning | Non-blocking warning | Acknowledge or fix |
| Pass | All validations passed | Proceed to save |
| Result | Save completed | View success/error |

---

## Step-by-Step Validation Flow

### Step 1: Field Validation (Inline)

| Trigger | Validation Type | Timing | UI Feedback |
|---------|-----------------|--------|-------------|
| Input change | Single field format | On blur | Inline error below field |
| Input change | Value range | On blur | Inline error below field |
| Input change | Required field | On blur | Inline error below field |

**Validation Rules**:

| Field | Rule | Type | Error Message |
|-------|------|------|---------------|
| elementCode | Pattern ^[A-Z][A-Z0-9_]{1,49}$ | FORMAT | "Code must start with letter" |
| rate | Range 0-1 | RANGE | "Rate must be between 0 and 1" |
| amount | Non-negative | RANGE | "Amount must be >= 0" |
| effectiveStartDate | Valid date | FORMAT | "Invalid date format" |
| elementCode | Required | REQUIRED | "Element code is required" |

---

### Step 2: Cross-Field Validation (On Save Click)

| Trigger | Validation Type | Timing | UI Feedback |
|---------|-----------------|--------|-------------|
| Save button click | Cross-field consistency | Before API call | Modal or banner |

**Validation Rules**:

| Rule | Fields | Condition | Message |
|------|--------|-----------|---------|
| Effective date order | startDate, endDate | endDate < startDate | "End date must be after start date" |
| Version continuity | effectiveStartDate, previousVersion.endDate | Gap or overlap | "Version effective dates overlap" |
| Formula required | calculationType, formulaId | FORMULA type without formulaId | "Formula required for FORMULA calculation type" |
| Rate required | calculationType, rate | RATE_BASED without rate | "Rate required for RATE_BASED calculation type" |

---

### Step 3: Entity Validation (Before API Call)

| Trigger | Validation Type | Timing | UI Feedback |
|---------|-----------------|--------|-------------|
| Save button click | Entity completeness | Before API call | Banner with acknowledge option |

**Validation Rules**:

| Rule | Entity | Condition | Message | Severity |
|------|--------|-----------|---------|----------|
| Profile completeness | PayProfile | No elements assigned | "Profile has no pay elements assigned" | WARNING |
| Element completeness | PayElement | No rate/amount/formula | "Element missing calculation value" | WARNING |
| Calendar completeness | PayCalendar | No periods generated | "Calendar has no pay periods" | WARNING |

---

### Step 4: Cross-Entity Validation (Before API Call)

| Trigger | Validation Type | Timing | UI Feedback |
|---------|-----------------|--------|-------------|
| Save button click | Reference validity | API call | Modal blocking save |

**Validation Rules**:

| Rule | Entities | Condition | Message | Severity |
|------|----------|-----------|---------|----------|
| BR-PP-004 | PayElement, PayProfile | Assign inactive element | "Cannot assign inactive element" | ERROR |
| BR-PE-004 | PayElement, PayProfile | Delete element in use | "Element is used by profile {profileCode}" | ERROR |
| Profile in use | PayProfile, PayGroup | Delete profile in use | "Profile is used by pay group {groupCode}" | ERROR |
| Legal entity exists | Any, CO | Invalid legalEntityId | "Legal entity not found" | ERROR |

---

### Step 5: Business Rule Validation (Before API Call)

| Trigger | Validation Type | Timing | UI Feedback |
|---------|-----------------|--------|-------------|
| Save button click | Domain-specific rules | API call | Warning modal with override option |

**Validation Rules**:

| Rule | Domain | Condition | Message | Action |
|------|--------|-----------|---------|--------|
| BR-SR-005 | StatutoryRule | Rate differs from government rate | "Rate differs from government rate 8%. Proceed?" | Override with reason |
| Duplicate assignment | PayProfile | Same element already assigned | "Element already assigned to profile" | ERROR |
| Single employee assignment | PayGroupAssignment | Employee already in group | "Employee already in group {groupCode}" | ERROR |

---

## Error Handling

### Error Categories

| Category | Severity | Action | Recovery |
|----------|----------|--------|----------|
| FORMAT | ERROR | Block save | Fix field format |
| RANGE | ERROR | Block save | Adjust value |
| REQUIRED | ERROR | Block save | Fill required field |
| REFERENCE | ERROR | Block save | Fix reference or create missing entity |
| BUSINESS_RULE | WARNING | Allow override | Acknowledge with reason |
| COMPLETENESS | WARNING | Allow save | Acknowledge and save |

### Error Messages

| Error Code | Message | Suggested Fix |
|------------|---------|---------------|
| VAL-001 | "Field is required" | Fill the field |
| VAL-002 | "Invalid format" | Check format requirements |
| VAL-003 | "Value out of range" | Adjust value |
| VAL-004 | "Reference not found" | Check reference ID |
| VAL-005 | "Entity in use" | Remove from dependent entity first |
| VAL-006 | "Business rule violation" | Acknowledge or fix |

---

## Notifications

### Toast Notifications

| Type | Trigger | Message | Duration |
|------|---------|---------|----------|
| Success | Save successful | "{Entity} saved successfully" | 3 seconds |
| Error | Validation failed | "Validation failed: {count} errors" | 5 seconds |
| Warning | Warning acknowledged | "Saved with warnings" | 3 seconds |

### Inline Notifications

| Type | Position | Content |
|------|----------|---------|
| Field Error | Below field | Error message in red |
| Field Warning | Below field | Warning message in yellow |
| Banner Warning | Top of form | Warning message with acknowledge button |

---

## Screen Specifications

### Validation Error Modal

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Validation Errors" |
| Icon | Error Icon | Red exclamation |
| Content | Error List | List of all errors with field paths |
| Each Error | Field Path | Which field has error |
| Each Error | Message | Error description |
| Each Error | Suggested Fix | How to fix the error |
| Actions | Fix Errors Button | Close modal, return to form |
| Actions | Cancel Button | Abort save operation |

### Validation Warning Banner

| Section | Component | Description |
|---------|-----------|-------------|
| Position | Top of form | Yellow banner |
| Icon | Warning Icon | Yellow warning triangle |
| Content | Message | Warning message |
| Actions | Acknowledge Button | Proceed with save |
| Actions | Fix Button | Return to form to fix |

### Inline Field Error

| Component | Description |
|-----------|-------------|
| Position | Below input field |
| Color | Red text |
| Icon | Red exclamation |
| Content | Error message |
| Dismiss | Disappears when field is corrected |

---

## Integration Events

| Event | Trigger | Payload |
|-------|---------|---------|
| ValidationRequested | User clicks save | entityId, entityType |
| ValidationCompleted | All validations pass | entityId, status: PASS |
| ValidationFailed | Any ERROR validation | entityId, errors[] |
| ConfigurationValidated | API returns success | entityId, entityType, status |
| ConfigurationValidationFailed | API returns error | entityId, entityType, errors[] |

---

## API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| /validations/validate | POST | Run full validation |
| /validations/{id} | GET | Get validation result |

**Validation Request**:

```json
{
  "entityType": "PayElement",
  "entityId": "uuid",
  "entityData": { ... }
}
```

**Validation Response**:

```json
{
  "validationId": "VAL-001",
  "status": "FAIL",
  "canProceed": false,
  "ruleResults": [
    {
      "ruleCode": "BR-PE-001",
      "severity": "ERROR",
      "passed": false,
      "message": "Element code must be unique",
      "fieldPath": "elementCode"
    }
  ]
}
```

---

## Traceability

| User Story | BRD Requirement | Validation Type |
|------------|-----------------|-----------------|
| US-014: Field Validation | FR-014 | Field, Cross-field |
| US-014: Entity Validation | FR-014 | Entity |
| US-014: Cross-Entity Validation | FR-014 | Cross-entity |
| US-014: Business Rule Validation | FR-014 | Business rule |

---

**Spec Version**: 1.0
**Created**: 2026-03-31