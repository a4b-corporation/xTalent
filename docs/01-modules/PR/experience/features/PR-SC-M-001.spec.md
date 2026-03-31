# Feature Spec: Statutory Rule Management

> **Feature ID**: PR-SC-M-001
> **Classification**: Masterdata (M)
> **Priority**: P0 (MVP)
> **Spec Depth**: Light
> **Date**: 2026-03-31

---

## Overview

Statutory Rule Management defines Vietnam government-mandated contribution rules for BHXH (Social Insurance), BHYT (Health Insurance), BHTN (Unemployment Insurance), and PIT (Personal Income Tax). All statutory rules are SCD-2 versioned to track historical rate changes.

---

## Vietnam Statutory Reference (2026)

| Type | Employee Rate | Employer Rate | Ceiling Amount |
|------|---------------|---------------|----------------|
| BHXH | 8% | 17.5% | 36,000,000 VND |
| BHYT | 1.5% | 3% | 36,000,000 VND |
| BHTN | 1% | 1% | 36,000,000 VND |
| PIT | Progressive | - | 7 brackets (5%-35%) |

**PIT Exemptions**:
- Personal Exemption: 11,000,000 VND/month
- Dependent Exemption: 4,400,000 VND/dependent/month

---

## CRUD Operations

### Create Statutory Rule

| Attribute | Type | Required | Validation | Default |
|-----------|------|----------|------------|---------|
| ruleCode | String | Yes | Unique per type+party, pattern ^[A-Z][A-Z0-9_]{1,49}$ | - |
| ruleName | String | Yes | Max 100 chars | - |
| statutoryType | Enum | Yes | BHXH, BHYT, BHTN, PIT | - |
| partyType | Enum | Yes | EMPLOYEE, EMPLOYER | - |
| rateType | Enum | Yes | FIXED_RATE, PROGRESSIVE, LOOKUP_BASED | - |
| rate | Decimal | Conditional | Required if FIXED_RATE, 0-1 range | null |
| ceilingAmount | Decimal | Conditional | Required if BHXH/BHYT/BHTN, >= 0 | null |
| floorAmount | Decimal | No | >= 0 | null |
| personalExemption | Decimal | Conditional | Required if PIT | null |
| dependentExemption | Decimal | Conditional | Required if PIT | null |
| effectiveStartDate | Date | Yes | >= today | today |

**API**: POST /statutory-rules

---

### Read Statutory Rule

| Operation | Description |
|-----------|-------------|
| List Rules | GET /statutory-rules (filtered by type, party) |
| Get by ID | GET /statutory-rules/{id} |
| Get Brackets | GET /statutory-rules/{id}/brackets |
| Query by Date | GET /statutory-rules/query?effectiveDate=... |

---

### Update Statutory Rule (SCD-2 Versioning)

| Attribute | Type | Required | Validation |
|-----------|------|----------|------------|
| rate | Decimal | Conditional | 0-1 range |
| ceilingAmount | Decimal | Conditional | >= 0 |
| personalExemption | Decimal | Optional | >= 0 |
| dependentExemption | Decimal | Optional | >= 0 |
| effectiveStartDate | Date | Yes | Must follow previous version end date |
| versionReason | String | Yes | Required for audit |

**API**: PUT /statutory-rules/{id}

**Compliance Warning**: If rate differs from government reference rate, show warning modal requiring acknowledgment.

---

### Delete Statutory Rule (Soft Delete)

| Condition | Validation |
|-----------|------------|
| Rule not assigned to active profile | Cannot delete if in use |
| Rule is active | Only active rules can be deleted |

**API**: DELETE /statutory-rules/{id}

---

## PIT Progressive Brackets

### Configure PIT Brackets

| Attribute | Type | Required | Validation |
|-----------|------|----------|------------|
| bracketNumber | Integer | Yes | Sequential 1-N |
| minAmount | Decimal | Yes | >= 0 |
| maxAmount | Decimal | Conditional | null for last bracket |
| rate | Decimal | Yes | 0-1 range |
| taxAmount | Decimal | No | Cumulative tax from previous brackets |

**API**: PUT /statutory-rules/{ruleCode}/configure-pit-brackets

**Vietnam PIT Reference (2026)**:

| Bracket | Min Amount | Max Amount | Rate |
|---------|------------|------------|------|
| 1 | 0 | 5,000,000 | 5% |
| 2 | 5,000,001 | 10,000,000 | 10% |
| 3 | 10,000,001 | 18,000,000 | 15% |
| 4 | 18,000,001 | 32,000,000 | 20% |
| 5 | 32,000,001 | 52,000,000 | 25% |
| 6 | 52,000,001 | 80,000,000 | 30% |
| 7 | 80,000,001 | null | 35% |

---

### Bracket Validation

| Rule | Validation | Message |
|------|------------|---------|
| BR-SR-003 | Full income range covered | "Brackets do not cover full income range" |
| Sequential min/max | minAmount of bracket N+1 = maxAmount+1 of bracket N | "Gap detected between brackets" |
| Last bracket | maxAmount = null | "Last bracket must have no upper limit" |

---

## Validation Rules

### Field Validation (Inline)

| Field | Rule | Error Message |
|-------|------|---------------|
| rate | Range 0-1 | "Rate must be between 0 and 1" |
| ceilingAmount | Required for BHXH/BHYT/BHTN | "Ceiling amount required for social insurance" |
| ruleCode | Unique per type+party | "Rule code must be unique for this statutory type and party" |

### Cross-Entity Validation (On Delete)

| Rule | Condition | Message |
|------|-----------|---------|
| Rule in use | Assigned to profile | "Cannot delete - rule is assigned to profile {profileCode}" |

### Business Rule Validation (On Save)

| Rule | Condition | Action |
|------|-----------|--------|
| BR-SR-005 | Rate differs from government rate | Warning modal: "Rate differs from government rate. Are you sure?" |

---

## Search and Filter

### List View Filters

| Filter | Type | Values |
|--------|------|--------|
| Statutory Type | Dropdown | BHXH, BHYT, BHTN, PIT |
| Party Type | Dropdown | EMPLOYEE, EMPLOYER |
| Status | Dropdown | Active, Inactive |
| Search | Text | Search code or name |

---

## SCD-2 Versioning

Statutory rules are versioned when rates change. This is critical for:
- Retroactive calculations when government rates change mid-year
- Audit trail for compliance
- Historical rate queries

---

## Screen Specifications

### Statutory Rule List Screen

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Statutory Rules" |
| Header | Create Button | Opens Create Screen |
| Filters | Dropdowns | Type, Party, Status |
| Table | Columns | Code, Name, Type, Party, Rate, Ceiling, Version Badge, Actions |
| Table | Actions | View, Edit, Delete, Configure Brackets (PIT only) |
| Footer | Pagination | Page navigation |

### Statutory Rule Create Screen

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Create Statutory Rule" |
| Form | ruleCode | Text input |
| Form | ruleName | Text input |
| Form | statutoryType | Select (BHXH, BHYT, BHTN, PIT) |
| Form | partyType | Select (EMPLOYEE, EMPLOYER) |
| Form | rateType | Select (FIXED_RATE, PROGRESSIVE) |
| Form | rate | Decimal input (conditional) |
| Form | ceilingAmount | Decimal input (conditional) |
| Form | effectiveStartDate | Date picker |
| Panel | PIT Configuration | Visible if statutoryType=PIT |
| Actions | Save Button | POST and navigate |
| Actions | Cancel Button | Return to list |

### PIT Bracket Configuration Screen

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Configure PIT Brackets" |
| Header | Rule Info | Rule code and name |
| Table | Columns | Bracket #, Min Amount, Max Amount, Rate, Actions |
| Table | Actions | Edit Bracket, Remove Bracket |
| Button | Add Bracket | Add new bracket row |
| Panel | Exemptions | Personal Exemption, Dependent Exemption |
| Chart | Visualization | Bar chart showing progressive rates |
| Actions | Save Button | PUT brackets |
| Actions | Cancel Button | Return to rule detail |

### Bracket Visualization Chart

| Component | Description |
|-----------|-------------|
| Chart Type | Stacked bar or step chart |
| X-Axis | Income amount (VND) |
| Y-Axis | Tax rate (%) |
| Hover | Shows bracket details |
| Colors | Gradient from green (low) to red (high rate) |

---

## API Endpoints Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| /statutory-rules | POST | Create rule |
| /statutory-rules | GET | List rules |
| /statutory-rules/{id} | GET | Get rule by ID |
| /statutory-rules/{id} | PUT | Update rule |
| /statutory-rules/{id} | DELETE | Soft delete rule |
| /statutory-rules/{ruleCode}/configure-pit-brackets | PUT | Configure PIT brackets |
| /statutory-rules/{ruleCode}/exemptions | PUT | Set exemptions |
| /statutory-rules/{ruleCode}/versions | GET | List versions |
| /statutory-rules/query | GET | Query by effective date |

---

## Events

| Event | Trigger | Consumer |
|-------|---------|----------|
| StatutoryRuleCreated | POST success | Audit Trail BC, Payroll Configuration BC |
| StatutoryRuleUpdated | PUT success | Audit Trail BC |
| StatutoryRuleVersionCreated | Version created | Audit Trail BC, Payroll Configuration BC |
| StatutoryRuleDeleted | DELETE success | Audit Trail BC |
| PITBracketConfigured | PUT brackets success | Audit Trail BC |

---

## Traceability

| User Story | BRD Requirement | API Endpoint |
|------------|-----------------|--------------|
| US-009: Create Statutory Rule | FR-009 | POST /statutory-rules |
| US-010: Configure PIT Brackets | FR-010 | PUT /statutory-rules/{code}/configure-pit-brackets |
| US-011: Update Statutory Rule | FR-011 | PUT /statutory-rules/{id} |

---

**Spec Version**: 1.0
**Created**: 2026-03-31