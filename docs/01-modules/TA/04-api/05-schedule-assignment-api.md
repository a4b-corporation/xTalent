# Schedule Assignment API

## Overview

The Schedule Assignment API manages work schedule rules that combine patterns with calendars and rotation offsets. This is **Level 5** in the hierarchical model, defining WHO gets WHICH pattern.

**Base Path:** `/api/v1/schedules/assignments`

---

## Endpoints

### List Schedule Assignments

```http
GET /api/v1/schedules/assignments
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `employeeId` | UUID | No | Filter by employee |
| `employeeGroupId` | UUID | No | Filter by group/team |
| `patternId` | UUID | No | Filter by pattern |
| `effectiveDate` | date | No | Filter assignments effective on this date |
| `limit` | integer | No | Page size (default: 50) |
| `cursor` | string | No | Pagination cursor |

**Example Response:**
```json
{
  "data": [
    {
      "id": "sched_abc123",
      "code": "TEAM_A_5X8",
      "name": "Team A - 5 Day Work Week",
      "patternId": "pat_5x8",
      "holidayCalendarId": "cal_vn_north",
      "startReferenceDate": "2025-01-01",
      "offsetDays": 0,
      "employeeGroupId": "bu_sales_team_a",
      "effectiveStart": "2025-01-01",
      "effectiveEnd": null,
      "metadata": {
        "timezone": "Asia/Ho_Chi_Minh",
        "autoGenerate": true
      }
    }
  ]
}
```

---

### Get Schedule Assignment

```http
GET /api/v1/schedules/assignments/{assignmentId}
```

---

### Create Schedule Assignment

```http
POST /api/v1/schedules/assignments
```

**Request Body:**

```json
{
  "code": "CREW_B_ROTATION",
  "name": "Crew B - 3-Shift Rotation",
  "patternId": "pat_3shift_223",
  "holidayCalendarId": "cal_vn_south",
  "startReferenceDate": "2025-01-01",
  "offsetDays": 7,
  "employeeGroupId": "bu_ops_crew_b",
  "effectiveStart": "2025-01-01",
  "metadata": {
    "rotationGroup": "B",
    "autoGenerate": true,
    "generateAheadDays": 90
  }
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `code` | string | Yes | Unique assignment code |
| `name` | string | Yes | Assignment name |
| `patternId` | UUID | Yes | Pattern template to apply |
| `holidayCalendarId` | UUID | No | Holiday calendar for this rule |
| `startReferenceDate` | date | Yes | Anchor point for pattern start |
| `offsetDays` | integer | No | Offset for rotation groups (default: 0) |
| `employeeId` | UUID | No | Specific employee (individual assignment) |
| `employeeGroupId` | UUID | No | Employee group/team/crew |
| `positionId` | UUID | No | Position/role |
| `effectiveStart` | date | Yes | Effective start date |
| `effectiveEnd` | date | No | Effective end date |

> [!IMPORTANT]
> At least one of `employeeId`, `employeeGroupId`, or `positionId` must be specified.

---

### Update Schedule Assignment

```http
PUT /api/v1/schedules/assignments/{assignmentId}
```

---

### Delete Schedule Assignment

```http
DELETE /api/v1/schedules/assignments/{assignmentId}
```

---

### Generate Roster

Generate roster entries from schedule assignment for a date range.

```http
POST /api/v1/schedules/assignments/{assignmentId}/generate-roster
```

**Request Body:**

```json
{
  "startDate": "2025-12-01",
  "endDate": "2025-12-31",
  "employeeIds": ["emp_123", "emp_456"],
  "overwriteExisting": false
}
```

**Response:**
```json
{
  "data": {
    "assignmentId": "sched_abc123",
    "startDate": "2025-12-01",
    "endDate": "2025-12-31",
    "employeesProcessed": 2,
    "rostersGenerated": 62,
    "rostersSkipped": 0,
    "errors": []
  }
}
```

---

## Rotation Offset Logic

The `offsetDays` parameter enables crew rotation. Multiple crews can use the same pattern but start at different points in the cycle.

**Example: 4-Crew Rotation with 28-day cycle**

```json
[
  {
    "code": "CREW_A",
    "patternId": "pat_3shift_28day",
    "startReferenceDate": "2025-01-01",
    "offsetDays": 0
  },
  {
    "code": "CREW_B",
    "patternId": "pat_3shift_28day",
    "startReferenceDate": "2025-01-01",
    "offsetDays": 7
  },
  {
    "code": "CREW_C",
    "patternId": "pat_3shift_28day",
    "startReferenceDate": "2025-01-01",
    "offsetDays": 14
  },
  {
    "code": "CREW_D",
    "patternId": "pat_3shift_28day",
    "startReferenceDate": "2025-01-01",
    "offsetDays": 21
  }
]
```

Each crew starts at a different day in the pattern cycle, ensuring continuous coverage.

---

## Holiday Calendar Integration

When a `holidayCalendarId` is specified, the system automatically:

1. Checks if the scheduled day is a holiday
2. Applies holiday substitution rules from the day model
3. Marks the roster entry with `isHoliday = true`

**Example:**
```json
{
  "patternId": "pat_5x8",
  "holidayCalendarId": "cal_vn_north",
  "metadata": {
    "holidaySubstitution": "OFF"
  }
}
```

---

## Use Cases

### Assigning Pattern to a Team

```bash
curl -X POST https://api.xtalent.vng.com/v1/schedules/assignments \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "SALES_TEAM_5X8",
    "name": "Sales Team - Standard Week",
    "patternId": "pat_5x8",
    "holidayCalendarId": "cal_vn_hanoi",
    "startReferenceDate": "2025-01-01",
    "employeeGroupId": "bu_sales",
    "effectiveStart": "2025-01-01"
  }'
```

### Individual Assignment Override

```bash
curl -X POST https://api.xtalent.vng.com/v1/schedules/assignments \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "EMP123_CUSTOM",
    "name": "Employee 123 - Custom Schedule",
    "patternId": "pat_4x10",
    "employeeId": "emp_123",
    "effectiveStart": "2025-01-15",
    "effectiveEnd": "2025-03-31"
  }'
```

---

## Next Steps

- View generated roster via [Roster API](./06-roster-api.md)
- Override specific dates via [Schedule Override API](./07-schedule-override-api.md)
- Review [Pattern Templates](./04-pattern-templates-api.md)
