---
entity: WorkSchedule
version: "1.0.0"
status: approved
created: 2026-01-26
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# Schema Standards: Work Schedule

## 1. Summary

The **Work Schedule** entity defines the working pattern for an employee (e.g., "Mon-Fri 8-5", "Shift A"). It is used to calculate expected working hours, overtime, and leave duration. Systems differentiate between "Simple" (Mon-Fri) and "Period/Complex" (Rotating shifts) schedules.

**Confidence**: HIGH - Based on 3 major HCM vendors

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Entity**: `ZHR_WORK_SCHEDULES` (Conceptual) / `Work Schedule`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Schedule Name | String | Y | Name |
| Type | Enum | Y | Time / Elapsed |
| Pattern | Complex | Y | Shifts/Days structure |
| Effective Dates | DateRange | Y | Validity |
| Exception | Reference | N | Public Holidays |

### 2.2 SAP SuccessFactors

**Entity**: `WorkSchedule`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| externalName | String | Y | Name |
| model | Enum | Y | Simple / Period |
| averageHoursPerDay | Decimal | N | Avg hours |
| averageHoursPerWeek| Decimal | N | Avg weekly |
| flexibleRequesting | Boolean | N | Flextime allowed |
| timeRecordingVariant| Enum | Y | Clock Time / Duration |

### 2.3 Workday

**Entity**: `Work Schedule Calendar`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Name | String | Y | Name |
| Summary | Text | N | Description |
| Work Week Start | Day | Y | Sunday/Monday |
| Pattern | Complex | Y | Weekly recurrence |
| Holiday Calendar | Reference | N | Holiday exclusions |

---

## 3. Canonical Schema: WorkSchedule

### Required Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique identifier | Universal |
| code | string(50) | Schedule Code | Universal |
| name | string(200) | Schedule Name | Universal |
| type | enum | FIXED/ROTATING/FLEXIBLE | Best practice |
| hoursPerWeek | decimal | Standard weekly hours | SAP |
| workingDays | integer | Days per week (e.g. 5) | SAP |

### Recommended Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| hoursPerDay | decimal | Avg daily hours | SAP |
| workWeekStart | enum | MONDAY/SUNDAY | Workday |
| holidayCalendar | reference | FK to HolidayCalendar | Workday |
| timeRecordingMethod | enum | CLOCK_TIME/DURATION | SAP |
| shiftPattern | json | Detailed day definition | Complex |
| isValid | boolean | Active status | Universal |

### Optional Attributes
| Attribute | Type | When to Include |
|-----------|------|-----------------|
| lunchBreakDuration | decimal | Standard break time |
| coreHoursStart | time | Flex time core start |
| coreHoursEnd | time | Flex time core end |
| description | text | Usage instructions |

---

## 4. Data Structure: Pattern

Accessing complex rotation patterns often requires a sub-structure:

```json
{
  "cycleLength": 7, // days
  "cycleUnit": "DAY",
  "days": [
    { "day": 1, "type": "WORK", "hours": 8, "start": "08:00", "end": "17:00" },
    { "day": 2, "type": "WORK", "hours": 8, "start": "08:00", "end": "17:00" },
    ...
    { "day": 6, "type": "OFF", "hours": 0 },
    { "day": 7, "type": "OFF", "hours": 0 }
  ]
}
```

---

## 5. Local Adaptations (Vietnam)

- **48-hour limit**: VN Labor Law generally caps standard hours at 48h/week.
- **Shift Work**: Manufacturing often uses 2 or 3 shift patterns (Ca 1, Ca 2, Ca 3).
- **Saturday**: Many offices work Saturday mornings (44h week).

---

*Document Status: APPROVED*
