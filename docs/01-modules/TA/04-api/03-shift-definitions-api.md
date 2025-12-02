# Shift Definitions API

## Overview

The Shift Definitions API allows you to create, manage, and query shift templates that define work schedules. Shifts can be fixed, flexible, split, overnight, or on-call patterns.

**Base Path:** `/api/v1/shifts`

---

## Endpoints

### List Shift Definitions

Retrieve a list of shift definitions with optional filtering.

```http
GET /api/v1/shifts
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `code` | string | No | Filter by shift code |
| `effectiveDate` | date | No | Filter shifts effective on this date |
| `isActive` | boolean | No | Filter by active status |
| `limit` | integer | No | Page size (default: 50, max: 100) |
| `cursor` | string | No | Pagination cursor |

**Example Request:**
```http
GET /api/v1/shifts?effectiveDate=2025-12-01&isActive=true&limit=20
Authorization: Bearer {token}
```

**Example Response:**
```json
{
  "data": [
    {
      "id": "shift_abc123",
      "code": "D1",
      "name": "Day Shift 1",
      "startTime": "08:00:00",
      "endTime": "17:00:00",
      "segmentJson": [
        {
          "type": "WORK",
          "from": "08:00:00",
          "to": "12:00:00"
        },
        {
          "type": "BREAK",
          "from": "12:00:00",
          "to": "13:00:00"
        },
        {
          "type": "WORK",
          "from": "13:00:00",
          "to": "17:00:00"
        }
      ],
      "metadata": {
        "mealBreak": true,
        "premiumZone": false,
        "color": "#4CAF50",
        "graceMinutes": 15
      },
      "effectiveStart": "2025-01-01",
      "effectiveEnd": null
    },
    {
      "id": "shift_xyz789",
      "code": "N3",
      "name": "Night Shift 3",
      "startTime": "23:00:00",
      "endTime": "07:00:00",
      "segmentJson": [
        {
          "type": "WORK",
          "from": "23:00:00",
          "to": "07:00:00"
        }
      ],
      "metadata": {
        "mealBreak": true,
        "premiumZone": true,
        "nightDifferential": 1.3,
        "color": "#3F51B5"
      },
      "effectiveStart": "2025-01-01",
      "effectiveEnd": null
    }
  ],
  "meta": {
    "pagination": {
      "limit": 20,
      "hasMore": false,
      "totalCount": 2
    },
    "timestamp": "2025-12-01T09:09:27Z",
    "requestId": "req_abc123"
  }
}
```

---

### Get Shift Definition

Retrieve a specific shift definition by ID.

```http
GET /api/v1/shifts/{shiftId}
```

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `shiftId` | UUID | Yes | Shift definition ID |

**Example Request:**
```http
GET /api/v1/shifts/shift_abc123
Authorization: Bearer {token}
```

**Example Response:**
```json
{
  "data": {
    "id": "shift_abc123",
    "code": "D1",
    "name": "Day Shift 1",
    "startTime": "08:00:00",
    "endTime": "17:00:00",
    "segmentJson": [
      {
        "type": "WORK",
        "from": "08:00:00",
        "to": "12:00:00"
      },
      {
        "type": "BREAK",
        "from": "12:00:00",
        "to": "13:00:00",
        "paid": false
      },
      {
        "type": "WORK",
        "from": "13:00:00",
        "to": "17:00:00"
      }
    ],
    "metadata": {
      "mealBreak": true,
      "premiumZone": false,
      "color": "#4CAF50",
      "graceMinutes": 15,
      "roundingRule": "QUARTER_HOUR"
    },
    "effectiveStart": "2025-01-01",
    "effectiveEnd": null,
    "createdAt": "2025-01-01T00:00:00Z",
    "updatedAt": "2025-01-01T00:00:00Z"
  },
  "meta": {
    "timestamp": "2025-12-01T09:09:27Z",
    "requestId": "req_abc123"
  }
}
```

---

### Create Shift Definition

Create a new shift definition.

```http
POST /api/v1/shifts
```

**Request Body:**

```json
{
  "code": "SPLIT_PM",
  "name": "Split Shift - Afternoon",
  "startTime": "07:00:00",
  "endTime": "18:00:00",
  "segmentJson": [
    {
      "type": "WORK",
      "from": "07:00:00",
      "to": "12:00:00"
    },
    {
      "type": "BREAK",
      "from": "12:00:00",
      "to": "14:00:00",
      "paid": false
    },
    {
      "type": "WORK",
      "from": "14:00:00",
      "to": "18:00:00"
    }
  ],
  "metadata": {
    "mealBreak": true,
    "splitShift": true,
    "color": "#FF9800",
    "graceMinutes": 10
  },
  "effectiveStart": "2025-01-01"
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `code` | string | Yes | Unique shift code (max 50 chars) |
| `name` | string | Yes | Shift name (max 100 chars) |
| `startTime` | time | Yes | Shift start time (HH:mm:ss) |
| `endTime` | time | Yes | Shift end time (can be < startTime for overnight shifts) |
| `segmentJson` | array | No | Detailed shift segments (WORK, BREAK, etc.) |
| `metadata` | object | No | Additional shift configuration |
| `effectiveStart` | date | Yes | Effective start date |
| `effectiveEnd` | date | No | Effective end date (null = no end) |

**Example Response:**
```json
{
  "data": {
    "id": "shift_new123",
    "code": "SPLIT_PM",
    "name": "Split Shift - Afternoon",
    "startTime": "07:00:00",
    "endTime": "18:00:00",
    "segmentJson": [ /* as in request */ ],
    "metadata": { /* as in request */ },
    "effectiveStart": "2025-01-01",
    "effectiveEnd": null,
    "createdAt": "2025-12-01T09:09:27Z",
    "updatedAt": "2025-12-01T09:09:27Z"
  },
  "meta": {
    "timestamp": "2025-12-01T09:09:27Z",
    "requestId": "req_abc123"
  }
}
```

---

### Update Shift Definition

Update an existing shift definition.

```http
PUT /api/v1/shifts/{shiftId}
```

**Request Body:** Same as Create, all fields optional except those being updated.

**Example Request:**
```http
PUT /api/v1/shifts/shift_abc123
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Day Shift 1 - Updated",
  "metadata": {
    "mealBreak": true,
    "premiumZone": false,
    "color": "#4CAF50",
    "graceMinutes": 20
  }
}
```

---

### Delete Shift Definition

Soft delete a shift definition by setting effective end date.

```http
DELETE /api/v1/shifts/{shiftId}
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `effectiveEnd` | date | No | End date (default: today) |

**Example Request:**
```http
DELETE /api/v1/shifts/shift_abc123?effectiveEnd=2025-12-31
Authorization: Bearer {token}
```

**Example Response:**
```json
{
  "data": {
    "id": "shift_abc123",
    "effectiveEnd": "2025-12-31",
    "deletedAt": "2025-12-01T09:09:27Z"
  },
  "meta": {
    "timestamp": "2025-12-01T09:09:27Z",
    "requestId": "req_abc123"
  }
}
```

---

## Shift Types & Patterns

### Fixed Shift
Standard shift with defined start and end times.

```json
{
  "code": "D1",
  "startTime": "08:00:00",
  "endTime": "17:00:00"
}
```

### Flexible Shift
Shift with core hours and flexible boundaries.

```json
{
  "code": "FLEX",
  "startTime": "06:00:00",
  "endTime": "18:00:00",
  "metadata": {
    "flexible": true,
    "coreHours": {
      "start": "09:00:00",
      "end": "15:00:00"
    },
    "requiredHours": 8
  }
}
```

### Split Shift
Shift with long break in the middle.

```json
{
  "code": "SPLIT",
  "startTime": "07:00:00",
  "endTime": "18:00:00",
  "segmentJson": [
    { "type": "WORK", "from": "07:00:00", "to": "12:00:00" },
    { "type": "BREAK", "from": "12:00:00", "to": "14:00:00", "paid": false },
    { "type": "WORK", "from": "14:00:00", "to": "18:00:00" }
  ]
}
```

### Overnight Shift
Shift crossing midnight.

```json
{
  "code": "N3",
  "startTime": "23:00:00",
  "endTime": "07:00:00",
  "metadata": {
    "overnight": true,
    "dayBreak": "04:00:00",
    "nightDifferential": 1.3
  }
}
```

### On-Call Shift
On-call availability period.

```json
{
  "code": "ONCALL",
  "startTime": "00:00:00",
  "endTime": "23:59:59",
  "metadata": {
    "onCall": true,
    "callOutRate": 2.0,
    "minimumCallHours": 2
  }
}
```

---

## Segment Types

### WORK
Regular working time.

```json
{
  "type": "WORK",
  "from": "08:00:00",
  "to": "12:00:00"
}
```

### BREAK
Unpaid break time.

```json
{
  "type": "BREAK",
  "from": "12:00:00",
  "to": "13:00:00",
  "paid": false
}
```

### MEAL
Paid meal break.

```json
{
  "type": "MEAL",
  "from": "12:00:00",
  "to": "12:30:00",
  "paid": true
}
```

### STANDBY
Standby/on-call time.

```json
{
  "type": "STANDBY",
  "from": "17:00:00",
  "to": "08:00:00",
  "paid": true,
  "rate": 0.5
}
```

---

## Metadata Fields

Common metadata fields for shift definitions:

```json
{
  "mealBreak": true,
  "premiumZone": false,
  "color": "#4CAF50",
  "icon": "day_shift",
  "graceMinutes": 15,
  "roundingRule": "QUARTER_HOUR|NEAREST_5|NEAREST_10|NONE",
  "allowOvertimeAutoApproval": false,
  "nightDifferential": 1.3,
  "weekendDifferential": 1.5,
  "flexible": false,
  "coreHours": { "start": "09:00:00", "end": "15:00:00" },
  "requiredHours": 8,
  "dayBreak": "04:00:00"
}
```

---

## Error Responses

### Duplicate Shift Code
```json
{
  "error": {
    "code": "DUPLICATE_SHIFT_CODE",
    "message": "Shift code 'D1' already exists",
    "details": {
      "existingShiftId": "shift_abc123"
    }
  }
}
```

### Invalid Time Range
```json
{
  "error": {
    "code": "INVALID_TIME_RANGE",
    "message": "Segment times must be sequential",
    "details": {
      "field": "segmentJson[1].from",
      "value": "11:00:00",
      "expected": "Must be >= 12:00:00"
    }
  }
}
```

### Shift In Use
```json
{
  "error": {
    "code": "SHIFT_IN_USE",
    "message": "Cannot delete shift that is assigned to patterns or schedules",
    "details": {
      "assignmentCount": 15
    }
  }
}
```

---

## Use Cases

### Creating a 3-Shift Rotation

```bash
# Create Day Shift
curl -X POST https://api.xtalent.vng.com/v1/shifts \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "D1",
    "name": "Day Shift",
    "startTime": "08:00:00",
    "endTime": "16:00:00",
    "effectiveStart": "2025-01-01"
  }'

# Create Evening Shift
curl -X POST https://api.xtalent.vng.com/v1/shifts \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "E2",
    "name": "Evening Shift",
    "startTime": "16:00:00",
    "endTime": "00:00:00",
    "effectiveStart": "2025-01-01"
  }'

# Create Night Shift
curl -X POST https://api.xtalent.vng.com/v1/shifts \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "N3",
    "name": "Night Shift",
    "startTime": "00:00:00",
    "endTime": "08:00:00",
    "metadata": {
      "nightDifferential": 1.3
    },
    "effectiveStart": "2025-01-01"
  }'
```

---

## Next Steps

- Create [Pattern Templates](./04-pattern-templates-api.md) using these shifts
- Assign shifts via [Schedule Assignment API](./05-schedule-assignment-api.md)
- Review [Common Models](./02-common-models.md) for data structures
