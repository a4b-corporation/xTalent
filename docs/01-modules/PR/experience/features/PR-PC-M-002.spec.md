# Feature Spec: Pay Profile Management

> **Feature ID**: PR-PC-M-002
> **Classification**: Masterdata (M)
> **Priority**: P0 (MVP)
> **Spec Depth**: Light
> **Date**: 2026-03-31

---

## Overview

Pay Profile Management defines configuration bundles for employee groups. A pay profile aggregates pay elements, statutory rules, and policies, enabling consistent payroll configuration for groups of employees.

---

## CRUD Operations

### Create Pay Profile

| Attribute | Type | Required | Validation | Default |
|-----------|------|----------|------------|---------|
| profileCode | String | Yes | Unique per legal entity, pattern ^[A-Z][A-Z0-9_]{1,49}$ | - |
| profileName | String | Yes | Max 100 chars | - |
| legalEntityId | String | Yes | Must exist in CO module | - |
| payFrequencyId | String | Yes | Must exist in CO module | - |
| description | String | No | Max 500 chars | null |
| effectiveStartDate | Date | Yes | >= today | today |

**API**: POST /pay-profiles

**Response**: 201 Created with PayProfileResponse

---

### Read Pay Profile

| Operation | Description |
|-----------|-------------|
| List Profiles | GET /pay-profiles (paginated, filtered) |
| Get by ID | GET /pay-profiles/{id} |
| Get Element Assignments | GET /pay-profiles/{id}/element-assignments |
| Get Statutory Rule Assignments | GET /pay-profiles/{id}/statutory-rule-assignments |
| Query by Date | GET /pay-profiles/query?effectiveDate=... |

---

### Update Pay Profile (SCD-2 Versioning)

| Attribute | Type | Required | Validation |
|-----------|------|----------|------------|
| profileName | String | Optional | Max 100 chars |
| description | String | Optional | Max 500 chars |
| payFrequencyId | String | Optional | Must exist |
| effectiveStartDate | Date | Yes | Must follow previous version end date |
| versionReason | String | Yes | Required for audit, max 500 chars |

**API**: PUT /pay-profiles/{id}

---

### Delete Pay Profile (Soft Delete)

| Condition | Validation |
|-----------|------------|
| Profile not assigned to active pay group | Cannot delete if in use |
| Profile is active | Only active profiles can be deleted |

**API**: DELETE /pay-profiles/{id}

---

## Element Assignment

### Assign Pay Element to Profile

| Attribute | Type | Required | Validation | Default |
|-----------|------|----------|------------|---------|
| payElementId | UUID | Yes | Must exist and be active | - |
| priority | Integer | Yes | 1-99 range | - |
| formulaOverride | String | No | Valid formula syntax, max 1000 chars | null |
| rateOverride | Decimal | No | 0-1 range | null |
| amountOverride | Decimal | No | >= 0 | null |
| effectiveStartDate | Date | Yes | Within profile effective dates | today |

**API**: POST /pay-profiles/{id}/element-assignments

**Business Rules**:
- BR-PP-002: Priority determines calculation sequence (1-99)
- BR-PP-003: No duplicate elements in profile
- BR-PP-004: Only active elements assignable

---

### Remove Pay Element from Profile

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| assignmentId | UUID | Yes | Assignment to remove |
| removalReason | String | No | Reason for removal |

**API**: DELETE /pay-profiles/{id}/element-assignments/{assignmentId}

---

## Statutory Rule Assignment

### Assign Statutory Rule to Profile

| Attribute | Type | Required | Validation |
|-----------|------|----------|------------|
| statutoryRuleId | UUID | Yes | Must exist and be active |
| effectiveStartDate | Date | Yes | Within profile effective dates |

**API**: POST /pay-profiles/{id}/statutory-rule-assignments

---

## Validation Rules

### Field Validation (Inline)

| Field | Rule | Error Message |
|-------|------|---------------|
| profileCode | Unique per legal entity | "Profile code must be unique per legal entity" |
| priority | Range 1-99 | "Priority must be between 1 and 99" |
| legalEntityId | Must exist | "Legal entity not found" |
| payFrequencyId | Must exist | "Pay frequency not found" |

### Cross-Field Validation (On Save)

| Rule | Condition | Message |
|------|-----------|---------|
| BR-PP-001 | Duplicate code within legal entity | "Profile code already exists" |
| BR-PP-003 | Duplicate element assignment | "Element already assigned to profile" |
| BR-PP-004 | Inactive element | "Cannot assign inactive element" |

### Entity Validation (On Save)

| Rule | Condition | Message |
|------|-----------|---------|
| Profile completeness | No elements assigned | Warning: "Profile has no pay elements assigned" |

### Cross-Entity Validation (On Delete)

| Rule | Condition | Message |
|------|-----------|---------|
| Profile in use | Assigned to pay group | "Cannot delete - profile is used by pay group {groupCode}" |

---

## Search and Filter

### List View Filters

| Filter | Type | Values |
|--------|------|--------|
| Legal Entity | Dropdown | From CO module |
| Pay Frequency | Dropdown | From CO module |
| Status | Dropdown | Active, Inactive |
| Search | Text | Search code or name |

---

## SCD-2 Versioning

Same pattern as Pay Element (PR-PC-M-001):
- Updates create new version
- Previous version closed
- Version history queryable
- Version comparison available

---

## Screen Specifications

### Pay Profile List Screen

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Pay Profiles" |
| Header | Create Button | Opens Create Screen |
| Filters | Dropdowns | Legal Entity, Pay Frequency, Status |
| Filters | Search | Text input for code/name search |
| Table | Columns | Code, Name, Legal Entity, Pay Frequency, Element Count, Version Badge, Actions |
| Table | Actions | View, Edit, Delete, Assign Elements |
| Footer | Pagination | Page navigation |

### Pay Profile Create Screen

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Create Pay Profile" |
| Form | profileCode | Text input |
| Form | profileName | Text input |
| Form | legalEntityId | Dropdown (from CO) |
| Form | payFrequencyId | Dropdown (from CO) |
| Form | description | Textarea |
| Form | effectiveStartDate | Date picker |
| Panel | Element Assignments | Collapsible panel |
| Panel | Statutory Rules | Collapsible panel |
| Actions | Save Button | POST and navigate to detail |
| Actions | Cancel Button | Return to list |

### Pay Profile Detail Screen

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Pay Profile: {profileName}" |
| Header | Edit Button | Opens Edit Screen |
| Header | Create Pay Group Button | Quick create from profile |
| Tabs | Profile Info | Basic profile attributes |
| Tabs | Element Assignments | Table with priority, overrides |
| Tabs | Statutory Rules | Table with rule assignments |
| Tabs | Version History | Timeline of versions |
| Sidebar | Usage | Shows pay groups using this profile |

### Element Assignment Panel

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Add Element Button | Opens Assign Element Modal |
| Table | Columns | Element Code, Name, Priority, Override Indicator, Actions |
| Table | Actions | Edit Override, Remove, Reorder |
| Reorder | Drag Handle | Drag to change priority |

---

## Override Configuration

### Formula Override

| Use Case | Description |
|----------|-------------|
| OT Calculation | Override formula for specific profile (e.g., 1.5x rate) |
| Bonus Formula | Custom formula for bonus calculation |

### Rate Override

| Use Case | Description |
|----------|-------------|
| BHXH Rate Override | Different rate for specific employee group |
| Commission Rate | Override percentage for commission |

### Amount Override

| Use Case | Description |
|----------|-------------|
| Fixed Allowance | Override fixed amount for specific group |
| Parking Allowance | Different amount per profile |

---

## API Endpoints Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| /pay-profiles | POST | Create profile |
| /pay-profiles | GET | List profiles |
| /pay-profiles/{id} | GET | Get profile by ID |
| /pay-profiles/{id} | PUT | Update profile |
| /pay-profiles/{id} | DELETE | Soft delete profile |
| /pay-profiles/{id}/element-assignments | GET | List assignments |
| /pay-profiles/{id}/element-assignments | POST | Add element assignment |
| /pay-profiles/{id}/element-assignments/{assignmentId} | DELETE | Remove assignment |
| /pay-profiles/{id}/statutory-rule-assignments | GET | List rule assignments |
| /pay-profiles/{id}/statutory-rule-assignments | POST | Add rule assignment |
| /pay-profiles/{id}/versions | GET | List versions |

---

## Events

| Event | Trigger | Consumer |
|-------|---------|----------|
| PayProfileCreated | POST /pay-profiles success | Audit Trail BC, Payroll Assignment BC |
| PayProfileUpdated | PUT /pay-profiles success | Audit Trail BC |
| PayProfileDeleted | DELETE /pay-profiles success | Audit Trail BC |
| PayProfileVersionCreated | Version created | Audit Trail BC |
| PayElementAssigned | POST element-assignments success | Validation BC |
| PayElementUnassigned | DELETE element-assignments success | Audit Trail BC |

---

## Traceability

| User Story | BRD Requirement | API Endpoint |
|------------|-----------------|--------------|
| US-005: Create Pay Profile | FR-005 | POST /pay-profiles |
| US-006: Assign Pay Element | FR-006 | POST /pay-profiles/{id}/element-assignments |

---

**Spec Version**: 1.0
**Created**: 2026-03-31