# Feature Spec: Pay Element Management

> **Feature ID**: PR-PC-M-001
> **Classification**: Masterdata (M)
> **Priority**: P0 (MVP)
> **Spec Depth**: Light
> **Date**: 2026-03-31

---

## Overview

Pay Element Management is the core configuration feature for defining payroll components. Pay elements are the building blocks of payroll calculations, representing earnings, deductions, taxes, and employer contributions.

---

## CRUD Operations

### Create Pay Element

| Attribute | Type | Required | Validation | Default |
|-----------|------|----------|------------|---------|
| elementCode | String | Yes | Unique per legal entity, pattern ^[A-Z][A-Z0-9_]{1,49}$ | - |
| elementName | String | Yes | Max 100 chars | - |
| legalEntityId | String | Yes | Must exist in CO module | - |
| classification | Enum | Yes | EARNING, DEDUCTION, TAX, EMPLOYER_CONTRIBUTION | - |
| calculationType | Enum | Yes | FIXED, FORMULA, RATE_BASED, HOURS_BASED | - |
| statutoryFlag | Boolean | No | - | false |
| taxableFlag | Boolean | No | - | true |
| formulaId | UUID | Conditional | Required if calculationType=FORMULA | null |
| rate | Decimal | Conditional | Required if calculationType=RATE_BASED, 0-1 range | null |
| amount | Decimal | Conditional | Required if calculationType=FIXED, >= 0 | null |
| effectiveStartDate | Date | Yes | >= today | today |

**API**: POST /pay-elements

**Response**: 201 Created with PayElementResponse

---

### Read Pay Element

| Operation | Description |
|-----------|-------------|
| List Elements | GET /pay-elements (paginated, filtered) |
| Get by ID | GET /pay-elements/{id} |
| Get by Code | GET /pay-elements/by-code/{elementCode} |
| Query by Date | GET /pay-elements/query?effectiveDate=... |

**Filters**:
- legalEntityId
- classification
- isCurrent (default: true)
- isActive (default: true)
- effectiveDate

---

### Update Pay Element (SCD-2 Versioning)

Updates create a new version. The previous version is closed by setting effectiveEndDate.

| Attribute | Type | Required | Validation |
|-----------|------|----------|------------|
| rate | Decimal | Conditional | 0-1 range |
| amount | Decimal | Conditional | >= 0 |
| formulaId | UUID | Conditional | Must exist |
| classification | Enum | Optional | Valid enum value |
| effectiveStartDate | Date | Yes | Must follow previous version end date |
| versionReason | String | Yes | Required for audit, max 500 chars |

**API**: POST /pay-elements/{elementCode}/versions

**SCD-2 Process**:
1. Close previous version: set effectiveEndDate = effectiveStartDate - 1 day
2. Create new version: isCurrentFlag = true, version++
3. Old version: isCurrentFlag = false
4. Create audit entry

---

### Delete Pay Element (Soft Delete)

| Condition | Validation |
|-----------|------------|
| Element not assigned to active profile | BR-PE-004: Cannot delete if in use |
| Element is active | Only active elements can be deleted |

**API**: DELETE /pay-elements/{id}

**Result**: is_active = false, audit entry created

---

## Validation Rules

### Field Validation (Inline)

| Field | Rule | Error Message |
|-------|------|---------------|
| elementCode | Unique per legal entity | "Element code must be unique per legal entity" |
| elementCode | Pattern validation | "Code must start with letter, alphanumeric underscore" |
| rate | Range 0-1 | "Rate must be between 0 and 1" |
| amount | Non-negative | "Amount must be non-negative" |
| effectiveStartDate | Valid date | "Invalid date format" |

### Cross-Field Validation (On Save)

| Rule | Condition | Message |
|------|-----------|---------|
| BR-PE-001 | Duplicate code within legal entity | "Element code already exists in this legal entity" |
| BR-PE-005 | Version continuity | "Effective date must follow previous version end date" |

### Cross-Entity Validation (On Delete)

| Rule | Condition | Message |
|------|-----------|---------|
| BR-PE-004 | Element in use | "Cannot delete - element is assigned to profile {profileCode}" |

---

## Classification Impact

| Classification | Gross Pay Impact | Net Pay Impact | Description |
|----------------|------------------|----------------|-------------|
| EARNING | + | + | Increases both gross and net pay |
| DEDUCTION | - | - | Decreases both gross and net pay |
| TAX | 0 | - | No gross impact, decreases net pay |
| EMPLOYER_CONTRIBUTION | 0 | 0 | Employer cost only, no employee impact |

**UI**: Classification selection shows inline impact description.

---

## Search and Filter

### List View Filters

| Filter | Type | Values |
|--------|------|--------|
| Legal Entity | Dropdown | From CO module |
| Classification | Dropdown | EARNING, DEDUCTION, TAX, EMPLOYER_CONTRIBUTION |
| Calculation Type | Dropdown | FIXED, FORMULA, RATE_BASED, HOURS_BASED |
| Status | Dropdown | Active, Inactive |
| Search | Text | Search code or name |

### Pagination

- Default: 20 items per page
- Maximum: 100 items per page
- Sort: elementCode ASC by default

---

## SCD-2 Versioning UI

### Version Timeline

| Component | Description |
|-----------|-------------|
| Timeline Visual | Horizontal timeline showing versions as markers |
| Version Badge | Shows count of versions on element list |
| Current Version Highlight | Green marker for isCurrentFlag=true |
| Historical Versions | Gray markers for closed versions |

### Version Comparison

| Feature | Description |
|---------|-------------|
| Side-by-Side | Two column layout: Version A | Version B |
| Highlighted Changes | Yellow highlight for changed fields |
| Comparison Modal | Accessible from timeline |

### Version Query

| Use Case | Description |
|----------|-------------|
| Retroactive Calculation | Query element version for a past effective date |
| Audit Investigation | View what the rate was on a specific date |
| Configuration Snapshot | Export all elements effective on a date |

---

## Screen Specifications

### Pay Element List Screen

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Pay Elements" |
| Header | Create Button | Opens Create Screen |
| Filters | Dropdowns | Legal Entity, Classification, Status |
| Filters | Search | Text input for code/name search |
| Table | Columns | Code, Name, Classification, Calculation Type, Version Badge, Actions |
| Table | Actions | View, Edit, Delete (per row) |
| Footer | Pagination | Page navigation |

### Pay Element Create Screen

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Create Pay Element" |
| Form | elementCode | Text input |
| Form | elementName | Text input |
| Form | legalEntityId | Dropdown (from CO) |
| Form | classification | Select with impact description |
| Form | calculationType | Select |
| Form | formulaId | Lookup (conditional) |
| Form | rate | Decimal input (conditional) |
| Form | amount | Decimal input (conditional) |
| Form | statutoryFlag | Toggle |
| Form | taxableFlag | Toggle |
| Form | effectiveStartDate | Date picker |
| Actions | Save Button | POST and navigate to detail |
| Actions | Cancel Button | Return to list |

### Pay Element Edit Screen

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Update Pay Element - {elementCode}" |
| Form | Same as Create | Pre-filled with current values |
| Form | versionReason | Textarea (required) |
| Form | effectiveStartDate | Date picker (default: today) |
| Actions | Preview Button | Open comparison modal |
| Actions | Commit Button | Create new version |
| Actions | Cancel Button | Return to detail |

---

## API Endpoints Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| /pay-elements | POST | Create element (version 1) |
| /pay-elements | GET | List elements (filtered) |
| /pay-elements/{id} | GET | Get element by ID |
| /pay-elements/{id} | PUT | Update element (create version) |
| /pay-elements/{id} | DELETE | Soft delete element |
| /pay-elements/by-code/{code} | GET | Get by business key |
| /pay-elements/{code}/versions | POST | Create new version |
| /pay-elements/{code}/versions | GET | List all versions |
| /pay-elements/{code}/versions/{id} | GET | Get specific version |
| /pay-elements/query | GET | Query by effective date |

---

## Events

| Event | Trigger | Consumer |
|-------|---------|----------|
| PayElementCreated | POST /pay-elements success | Audit Trail BC, Validation BC |
| PayElementUpdated | PUT /pay-elements success | Audit Trail BC |
| PayElementVersionCreated | POST /pay-elements/{code}/versions | Audit Trail BC |
| PayElementDeleted | DELETE /pay-elements success | Audit Trail BC |

---

## Traceability

| User Story | BRD Requirement | API Endpoint |
|------------|-----------------|--------------|
| US-001: Create Pay Element | FR-001 | POST /pay-elements |
| US-002: Update Pay Element | FR-002 | POST /pay-elements/{code}/versions |
| US-003: Soft Delete Pay Element | FR-003 | DELETE /pay-elements/{id} |
| US-004: View Classification Impact | FR-004 | Classification field in entity |
| US-016: View Version History | FR-016 | GET /pay-elements/{code}/versions |
| US-017: Query Version by Date | FR-017 | GET /pay-elements/query |

---

**Spec Version**: 1.0
**Created**: 2026-03-31