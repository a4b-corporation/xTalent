# Glossary - Payroll Calendar Bounded Context

> **Bounded Context**: Payroll Calendar (BC-003)
> **Module**: Payroll (PR)
> **Phase**: Domain Architecture (Step 3)
> **Date**: 2026-03-31

---

## Ubiquitous Language

This glossary defines the terms used within the Payroll Calendar bounded context. All team members should use these terms consistently when discussing payroll time-based scheduling.

---

## Entities

### PayCalendar

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **PayCalendar** | Time-based payroll period definition for a legal entity and fiscal year. | Not PayFrequency (reference data). Not PayPeriod (entity within calendar). |
| **calendarCode** | Unique identifier for the pay calendar. Human-readable like "CAL_2026". | Must be unique per legal entity + fiscal year. |
| **calendarName** | Human-readable name like "Calendar 2026 - HQ". | For display and documentation. |
| **legalEntityId** | Reference to LegalEntity from Core HR (CO) module. | Not owned by this module. Reference only. |
| **payFrequencyId** | Reference to PayFrequency (WEEKLY, BI_WEEKLY, SEMI_MONTHLY, MONTHLY). | Determines period count. |
| **fiscalYear** | Calendar year for payroll periods (e.g., 2026). | January to December for Vietnam. |
| **startDate** | First day of fiscal year payroll (usually January 1). | For period generation. |
| **endDate** | Last day of fiscal year payroll (usually December 31). | For period generation. |
| **isActive** | Flag indicating calendar is available for pay group assignment. | False after deletion. |
| **createdAt** | Timestamp when calendar was created. | For audit. |
| **createdBy** | User who created the calendar. | For audit. |

**Lifecycle States**:
- **Active**: isActive = true, can be assigned to PayGroups
- **Inactive**: isActive = false, historical reference only

**Business Rules**:
- BR-PC-001: Period dates must be sequential without gaps
- BR-PC-002: Cut-off date must be before pay date
- BR-PC-003: Period count matches frequency (12 monthly, 52 weekly, 26 bi-weekly, 24 semi-monthly)

---

### PayPeriod

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **PayPeriod** | Individual payroll period within a calendar defining work dates, cut-off, and pay date. | Not PayCalendar (the container). Not fiscal period (accounting). |
| **periodId** | Unique identifier for the pay period. | System-generated UUID. |
| **periodNumber** | Sequential number within calendar (1-12 for monthly). | For ordering and reference. |
| **periodName** | Human-readable name like "January 2026" or "Period 1". | For display. |
| **periodStartDate** | First day of work included in this payroll period. | Work begins on this date. |
| **periodEndDate** | Last day of work included in this payroll period. | Work ends on this date. |
| **cutOffDate** | Deadline for payroll data submission and changes. | Must be before payDate. |
| **payDate** | Date when employees receive payment. | Usually end of period or next period start. |
| **status** | Period status: OPEN, CLOSED, PAID. | Workflow state. |
| **adjustmentReason** | Reason for manual date adjustment. | Required when dates are modified. |

**Period Status Flow**:
```
OPEN -> CLOSED -> PAID
  |         |
  |         v
  v      REOPENED (for corrections)
CLOSED
```

**Lifecycle States**:
- **Open**: Period accepting data changes
- **Closed**: Cut-off passed, no more changes
- **Paid**: Payment processed
- **Reopened**: Exceptionally reopened for corrections

---

## Value Objects

### PayFrequency

| Value | Periods/Year | Description |
|-------|--------------|-------------|
| **WEEKLY** | 52 | Weekly payroll, every week |
| **BI_WEEKLY** | 26 | Every two weeks |
| **SEMI_MONTHLY** | 24 | Twice per month (1st and 16th typically) |
| **MONTHLY** | 12 | Once per month (Vietnam standard) |

### PeriodStatus

| Value | Definition | Allowed Actions |
|-------|------------|-----------------|
| **OPEN** | Period is open for data entry | All CRUD operations |
| **CLOSED** | Cut-off passed, data locked | Query only |
| **PAID** | Payment processed | Query only |
| **REOPENED** | Temporarily reopened | Limited corrections |

---

## Events

### PayCalendar Events

| Event | Definition | Khac voi |
|-------|------------|----------|
| **PayCalendarCreated** | A new pay calendar was created for a legal entity and fiscal year. | Calendar creation, not period. |
| **PayCalendarUpdated** | Calendar attributes were modified. | Calendar metadata, not periods. |
| **PayCalendarDeleted** | Calendar was soft-deleted. | Preserves periods for audit. |

### PayPeriod Events

| Event | Definition | Khac voi |
|-------|------------|----------|
| **PayPeriodGenerated** | Pay periods were auto-generated based on frequency. | Bulk generation. |
| **PayPeriodAdjusted** | Individual period dates were manually adjusted. | Requires adjustmentReason. |
| **PayPeriodClosed** | Period was closed at cut-off. | Status change to CLOSED. |
| **PayPeriodPaid** | Payment was processed for this period. | Status change to PAID. |
| **PayPeriodReopened** | Period was reopened for corrections. | Exception workflow. |

---

## Commands

| Command | Actor | Description |
|---------|-------|-------------|
| **CreatePayCalendar** | Payroll Admin | Create calendar for fiscal year |
| **UpdatePayCalendar** | Payroll Admin | Update calendar metadata |
| **DeletePayCalendar** | Payroll Admin | Soft delete calendar |
| **GeneratePayPeriods** | Payroll Admin | Auto-generate periods from frequency |
| **AdjustPayPeriod** | Payroll Admin | Manually adjust period dates |
| **ClosePayPeriod** | System | Close period at cut-off |
| **MarkPayPeriodPaid** | System | Mark period as paid |
| **ReopenPayPeriod** | Payroll Admin | Reopen for corrections (approval required) |
| **QueryPayCalendar** | Payroll Admin | Get calendar with periods |
| **QueryPayPeriod** | Payroll Admin | Get specific period |

---

## Period Generation Rules

### Monthly Frequency (12 periods)

| Month | Period Start | Period End | Cut-off | Pay Date |
|-------|--------------|------------|---------|----------|
| 1 (Jan) | Jan 1 | Jan 31 | Jan 25 | Jan 31 |
| 2 (Feb) | Feb 1 | Feb 28/29 | Feb 25 | Feb 28/29 |
| ... | ... | ... | ... | ... |
| 12 (Dec) | Dec 1 | Dec 31 | Dec 25 | Dec 31 |

### Weekly Frequency (52 periods)

```
Period 1: Jan 1-7, cut-off Jan 5, pay Jan 7
Period 2: Jan 8-14, cut-off Jan 12, pay Jan 14
...
Period 52: Dec 25-31, cut-off Dec 29, pay Dec 31
```

### Semi-Monthly Frequency (24 periods)

```
Period 1: Jan 1-15, cut-off Jan 13, pay Jan 15
Period 2: Jan 16-31, cut-off Jan 28, pay Jan 31
...
Period 24: Dec 16-31, cut-off Dec 28, pay Dec 31
```

---

## Business Rules Detail

### BR-PC-001: Period Dates Sequential

```
Valid:
  Period 1: Jan 1 - Jan 31
  Period 2: Feb 1 - Feb 28 (starts immediately after Period 1)

Invalid:
  Period 1: Jan 1 - Jan 31
  Period 2: Feb 3 - Feb 28 (gap of Feb 1-2)
```

### BR-PC-002: Cut-off Before Pay Date

```
Valid:
  cutOffDate: Jan 25
  payDate: Jan 31

Invalid:
  cutOffDate: Feb 2
  payDate: Feb 1 (cut-off after pay date)
```

### BR-PC-003: Period Count Matches Frequency

```
MONTHLY -> 12 periods required
WEEKLY -> 52 periods required
BI_WEEKLY -> 26 periods required
SEMI_MONTHLY -> 24 periods required
```

---

## Integration Points

### Inbound Integrations

| Source | Data | Purpose |
|--------|------|---------|
| Core HR (CO) | LegalEntity | Calendar scope reference |
| Reference Data | PayFrequency | Frequency definition |

### Outbound Integrations

| Target | Data | Purpose |
|--------|------|---------|
| Payroll Assignment | PayCalendar | Group calendar reference |
| Calculation Engine | Current Period | Period dates for calculation |

---

## Example Calendar

### Monthly Calendar for 2026

```
PayCalendar {
  calendarCode: "CAL_2026_HQ",
  calendarName: "Calendar 2026 - Headquarters",
  legalEntityId: "VN_HQ",
  payFrequencyId: "MONTHLY",
  fiscalYear: 2026,
  isActive: true
}

PayPeriods (auto-generated):
[
  { periodNumber: 1, periodName: "January 2026",
    periodStartDate: "2026-01-01", periodEndDate: "2026-01-31",
    cutOffDate: "2026-01-25", payDate: "2026-01-31", status: OPEN },
  { periodNumber: 2, periodName: "February 2026",
    periodStartDate: "2026-02-01", periodEndDate: "2026-02-28",
    cutOffDate: "2026-02-25", payDate: "2026-02-28", status: OPEN },
  ...
  { periodNumber: 12, periodName: "December 2026",
    periodStartDate: "2026-12-01", periodEndDate: "2026-12-31",
    cutOffDate: "2026-12-25", payDate: "2026-12-31", status: OPEN }
]
```

---

## Period Adjustment Example

```
Original Period 4 (April):
  periodStartDate: "2026-04-01"
  periodEndDate: "2026-04-30"
  cutOffDate: "2026-04-25"
  payDate: "2026-04-30"

Adjustment for holiday:
  cutOffDate: "2026-04-23" (moved earlier due to holiday)
  payDate: "2026-04-29" (moved earlier)
  adjustmentReason: "Tet holiday falls on pay date"

Validation:
  BR-PC-002 check: cutOffDate (23) < payDate (29) -> PASS
```

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Domain Architect Agent