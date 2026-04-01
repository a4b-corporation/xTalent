# Feature Spec: Pay Calendar Management

> **Feature ID**: PR-PC-M-004
> **Classification**: Masterdata (M)
> **Priority**: P0 (MVP)
> **Spec Depth**: Light
> **Date**: 2026-03-31

---

## Overview

Pay Calendar Management defines the payroll time schedule for a legal entity and fiscal year. Calendars contain pay periods with cut-off dates and pay dates, controlling when payroll data is locked and when employees are paid.

---

## CRUD Operations

### Create Pay Calendar

| Attribute | Type | Required | Validation | Default |
|-----------|------|----------|------------|---------|
| calendarCode | String | Yes | Unique per legal entity, pattern ^[A-Z][A-Z0-9_]{1,49}$ | - |
| calendarName | String | Yes | Max 100 chars | - |
| legalEntityId | String | Yes | Must exist in CO module | - |
| payFrequencyId | String | Yes | Must exist in CO module (MONTHLY, SEMI_MONTHLY, etc.) | - |
| fiscalYear | Integer | Yes | Valid year (e.g., 2026) | - |
| startDate | Date | Yes | First day of fiscal year | - |
| endDate | Date | Yes | Last day of fiscal year, >= startDate | - |

**API**: POST /pay-calendars

---

### Generate Pay Periods

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| startDate | Date | Yes | First period start date |
| endDate | Date | Yes | Last period end date |
| defaultCutOffDays | Integer | No | Days before period end for cut-off (default: -5) |
| defaultPayDays | Integer | No | Days after period end for pay (default: 5) |

**API**: POST /pay-calendars/{calendarCode}/generate-periods

**Period Generation**:

| Frequency | Period Count | Period Duration |
|-----------|--------------|-----------------|
| MONTHLY | 12 | 1 month |
| SEMI_MONTHLY | 24 | 15 days |
| BI_WEEKLY | 26 | 14 days |
| WEEKLY | 52 | 7 days |

---

### Adjust Pay Period

| Attribute | Type | Required | Validation |
|-----------|------|----------|------------|
| cutOffDate | Date | Yes | < payDate, >= periodStartDate |
| payDate | Date | Yes | > cutOffDate, <= periodEndDate + 30 days |
| adjustmentReason | String | Yes | Required for audit, max 200 chars |

**API**: PUT /pay-calendars/{calendarCode}/periods/{periodId}

---

### Period Status Management

| Status | Description | Allowed Transitions |
|--------|-------------|---------------------|
| OPEN | Period open for data entry | OPEN -> CLOSED |
| CLOSED | Cut-off passed, data locked | CLOSED -> REOPENED, CLOSED -> PAID |
| REOPENED | Temporarily reopened for corrections | REOPENED -> CLOSED |
| PAID | Payment processed | Terminal state |

---

## Validation Rules

### Field Validation (Inline)

| Field | Rule | Error Message |
|-------|------|---------------|
| calendarCode | Unique per legal entity | "Calendar code must be unique per legal entity" |
| fiscalYear | Valid year | "Invalid fiscal year" |
| endDate | >= startDate | "End date must be after start date" |
| cutOffDate | < payDate | "Cut-off date must be before pay date" |

### Period Sequential Validation

| Rule | Condition | Message |
|------|-----------|---------|
| BR-PC-001 | Period dates sequential without gaps | "Period dates are not sequential" |
| BR-PC-002 | Cut-off before pay date | "Cut-off date must be before pay date" |
| BR-PC-003 | Period count matches frequency | Warning if mismatch |

---

## Search and Filter

### List View Filters

| Filter | Type | Values |
|--------|------|--------|
| Legal Entity | Dropdown | From CO module |
| Fiscal Year | Dropdown | 2024, 2025, 2026, etc. |
| Pay Frequency | Dropdown | MONTHLY, SEMI_MONTHLY, etc. |
| Status | Dropdown | Active, Inactive |
| Search | Text | Search code or name |

---

## Screen Specifications

### Pay Calendar List Screen

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Pay Calendars" |
| Header | Create Button | Opens Create Screen |
| Filters | Dropdowns | Legal Entity, Fiscal Year, Frequency |
| Table | Columns | Code, Name, Legal Entity, Fiscal Year, Frequency, Period Count, Actions |
| Table | Actions | View, Edit, Delete, Generate Periods |
| Footer | Pagination | Page navigation |

### Pay Calendar Create Screen

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Create Pay Calendar" |
| Form | calendarCode | Text input |
| Form | calendarName | Text input |
| Form | legalEntityId | Dropdown (from CO) |
| Form | payFrequencyId | Dropdown (from CO) |
| Form | fiscalYear | Year picker |
| Form | startDate | Date picker |
| Form | endDate | Date picker |
| Preview | Period Preview Button | Opens Preview Modal |
| Actions | Save Button | POST calendar, auto-generate periods |
| Actions | Cancel Button | Return to list |

### Pay Calendar Detail Screen

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Pay Calendar: {calendarName}" |
| Header | Edit Button | Opens Edit Screen |
| Tabs | Calendar Info | Basic calendar attributes |
| Tabs | Pay Periods | Table of periods with status |
| Sidebar | Usage | Shows pay groups using this calendar |

### Pay Period List Screen (within Calendar)

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Pay Periods - {calendarName}" |
| Table | Columns | Period #, Name, Start Date, End Date, Cut-off, Pay Date, Status, Actions |
| Table | Status | Badge: OPEN (green), CLOSED (yellow), PAID (blue), REOPENED (orange) |
| Table | Actions | Adjust Period, Close, Reopen, Mark Paid |
| Footer | Pagination | Page navigation |

### Period Generation Preview Modal

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Preview Generated Periods" |
| Table | Preview | Shows 12/24/26/52 generated periods |
| Inputs | defaultCutOffDays | Days before period end |
| Inputs | defaultPayDays | Days after period end |
| Validation | Sequential Check | Warning if gaps detected |
| Actions | Generate Button | Create periods |
| Actions | Cancel Button | Close modal |

### Period Adjustment Modal

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Adjust Period {periodNumber}" |
| Inputs | cutOffDate | Date picker |
| Inputs | payDate | Date picker |
| Inputs | adjustmentReason | Textarea (required) |
| Validation | cutOff < payDate | Inline error |
| Actions | Save Adjustment | PUT period |
| Actions | Cancel | Close modal |

---

## API Endpoints Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| /pay-calendars | POST | Create calendar |
| /pay-calendars | GET | List calendars |
| /pay-calendars/{id} | GET | Get calendar by ID |
| /pay-calendars/{id} | PUT | Update calendar |
| /pay-calendars/{id} | DELETE | Soft delete calendar |
| /pay-calendars/{calendarCode}/generate-periods | POST | Generate periods |
| /pay-calendars/{calendarCode}/periods | GET | List periods |
| /pay-calendars/{calendarCode}/periods/{periodId} | PUT | Adjust period |
| /pay-calendars/{calendarCode}/periods/{periodId}/close | PUT | Close period |
| /pay-calendars/{calendarCode}/periods/{periodId}/reopen | PUT | Reopen period |
| /pay-calendars/{calendarCode}/periods/{periodId}/mark-paid | PUT | Mark as paid |

---

## Events

| Event | Trigger | Consumer |
|-------|---------|----------|
| PayCalendarCreated | POST success | Audit Trail BC, Payroll Assignment BC |
| PayCalendarUpdated | PUT success | Audit Trail BC |
| PayPeriodGenerated | POST generate-periods | Audit Trail BC |
| PayPeriodAdjusted | PUT period | Audit Trail BC |
| PayPeriodClosed | PUT close | Audit Trail BC |
| PayPeriodReopened | PUT reopen | Audit Trail BC |
| PayPeriodPaid | PUT mark-paid | Audit Trail BC |

---

## Traceability

| User Story | BRD Requirement | API Endpoint |
|------------|-----------------|--------------|
| US-007: Create Pay Calendar | FR-007 | POST /pay-calendars |
| US-007: Adjust Period Dates | FR-007 | PUT /pay-calendars/{code}/periods/{id} |

---

**Spec Version**: 1.0
**Created**: 2026-03-31