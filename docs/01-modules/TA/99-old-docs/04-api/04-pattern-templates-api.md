# Pattern Templates API

## Overview

The Pattern Templates API manages recurring shift patterns (work schedules) that define cyclical shift sequences. Patterns can represent weekly schedules, rotation cycles, seasonal patterns, and more.

**Base Path:** `/api/v1/patterns`

---

## Endpoints

### List Pattern Templates

```http
GET /api/v1/patterns
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `code` | string | No | Filter by pattern code |
| `category` | string | No | Filter by category (OFFICE, SHIFT, SEASONAL, ONCALL) |
| `effectiveDate` | date | No | Filter patterns effective on this date |
| `limit` | integer | No | Page size (default: 50) |
| `cursor` | string | No | Pagination cursor |

**Example Response:**
```json
{
  "data": [
    {
      "id": "pat_abc123",
      "code": "5x8",
      "name": "5 Days Work, 2 Days Off",
      "patternJson": {
        "cycle": 7,
        "seq": ["D1", "D1", "D1", "D1", "D1", "OFF", "OFF"]
      },
      "description": "Standard office work pattern",
      "metadata": {
        "category": "OFFICE",
        "weeklyHours": 40,
        "tags": ["full-time", "office"]
      },
      "effectiveStart": "2025-01-01",
      "effectiveEnd": null
    },
    {
      "id": "pat_xyz789",
      "code": "3SHIFT_223",
      "name": "3-Shift 2-2-3 Rotation",
      "patternJson": {
        "cycle": 28,
        "seq": [
          "D1", "D1", "E2", "E2", "OFF", "OFF", "OFF",
          "N3", "N3", "D1", "D1", "OFF", "OFF", "OFF",
          "E2", "E2", "N3", "N3", "OFF", "OFF", "OFF",
          "D1", "D1", "E2", "E2", "N3", "N3", "OFF"
        ]
      },
      "description": "4-crew 3-shift rotation",
      "metadata": {
        "category": "SHIFT",
        "weeklyHours": 42,
        "crewCount": 4
      },
      "effectiveStart": "2025-01-01",
      "effectiveEnd": null
    }
  ],
  "meta": {
    "pagination": {
      "limit": 50,
      "hasMore": false,
      "totalCount": 2
    }
  }
}
```

---

### Get Pattern Template

```http
GET /api/v1/patterns/{patternId}
```

**Example Response:**
```json
{
  "data": {
    "id": "pat_abc123",
    "code": "5x8",
    "name": "5 Days Work, 2 Days Off",
    "patternJson": {
      "cycle": 7,
      "seq": ["D1", "D1", "D1", "D1", "D1", "OFF", "OFF"]
    },
    "description": "Standard office work pattern",
    "metadata": {
      "category": "OFFICE",
      "weeklyHours": 40
    },
    "effectiveStart": "2025-01-01",
    "effectiveEnd": null,
    "createdAt": "2025-01-01T00:00:00Z",
    "updatedAt": "2025-01-01T00:00:00Z"
  }
}
```

---

### Create Pattern Template

```http
POST /api/v1/patterns
```

**Request Body:**

```json
{
  "code": "OILRIG_14_14",
  "name": "Oil Rig 14 Days On / 14 Days Off",
  "patternJson": {
    "cycle": 28,
    "seq": [
      "D1", "D1", "D1", "D1", "D1", "D1", "D1",
      "D1", "D1", "D1", "D1", "D1", "D1", "D1",
      "OFF", "OFF", "OFF", "OFF", "OFF", "OFF", "OFF",
      "OFF", "OFF", "OFF", "OFF", "OFF", "OFF", "OFF"
    ]
  },
  "description": "Offshore oil rig rotation",
  "metadata": {
    "category": "SEASONAL",
    "location": "offshore",
    "weeklyHours": 84
  },
  "effectiveStart": "2025-01-01"
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `code` | string | Yes | Unique pattern code (max 50 chars) |
| `name` | string | Yes | Pattern name (max 100 chars) |
| `patternJson` | object | Yes | Pattern definition (cycle + sequence) |
| `patternJson.cycle` | integer | Yes | Cycle length in days |
| `patternJson.seq` | array | Yes | Shift codes sequence (length = cycle) |
| `description` | string | No | Pattern description |
| `metadata` | object | No | Additional configuration |
| `effectiveStart` | date | Yes | Effective start date |
| `effectiveEnd` | date | No | Effective end date |

---

### Update Pattern Template

```http
PUT /api/v1/patterns/{patternId}
```

**Request Body:** Same as Create, fields are optional.

---

### Delete Pattern Template

```http
DELETE /api/v1/patterns/{patternId}
```

---

### Expand Pattern

Generate a calendar view of the pattern for a specific date range.

```http
GET /api/v1/patterns/{patternId}/expand
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `from` | date | Yes | Start date |
| `days` | integer | Yes | Number of days to expand (max 365) |
| `anchor` | integer | No | Rotation anchor offset (default: 0) |

**Example Request:**
```http
GET /api/v1/patterns/pat_abc123/expand?from=2025-12-01&days=14&anchor=0
```

**Example Response:**
```json
{
  "data": {
    "patternId": "pat_abc123",
    "code": "5x8",
    "from": "2025-12-01",
    "to": "2025-12-14",
    "anchor": 0,
    "schedule": [
      { "date": "2025-12-01", "dayOfCycle": 0, "shiftCode": "D1" },
      { "date": "2025-12-02", "dayOfCycle": 1, "shiftCode": "D1" },
      { "date": "2025-12-03", "dayOfCycle": 2, "shiftCode": "D1" },
      { "date": "2025-12-04", "dayOfCycle": 3, "shiftCode": "D1" },
      { "date": "2025-12-05", "dayOfCycle": 4, "shiftCode": "D1" },
      { "date": "2025-12-06", "dayOfCycle": 5, "shiftCode": "OFF" },
      { "date": "2025-12-07", "dayOfCycle": 6, "shiftCode": "OFF" },
      { "date": "2025-12-08", "dayOfCycle": 0, "shiftCode": "D1" },
      { "date": "2025-12-09", "dayOfCycle": 1, "shiftCode": "D1" },
      { "date": "2025-12-10", "dayOfCycle": 2, "shiftCode": "D1" },
      { "date": "2025-12-11", "dayOfCycle": 3, "shiftCode": "D1" },
      { "date": "2025-12-12", "dayOfCycle": 4, "shiftCode": "D1" },
      { "date": "2025-12-13", "dayOfCycle": 5, "shiftCode": "OFF" },
      { "date": "2025-12-14", "dayOfCycle": 6, "shiftCode": "OFF" }
    ]
  }
}
```

---

## Pattern Types

### Office Pattern (5x8)
Standard 5-day work week.

```json
{
  "code": "5x8",
  "patternJson": {
    "cycle": 7,
    "seq": ["D1", "D1", "D1", "D1", "D1", "OFF", "OFF"]
  },
  "metadata": {
    "category": "OFFICE",
    "weeklyHours": 40
  }
}
```

### 3-Shift 4-Crew (2-2-3)
Continental rotation pattern.

```json
{
  "code": "3SHIFT_223",
  "patternJson": {
    "cycle": 28,
    "seq": [
      "D1", "D1", "E2", "E2", "OFF", "OFF", "OFF",
      "N3", "N3", "D1", "D1", "OFF", "OFF", "OFF",
      "E2", "E2", "N3", "N3", "OFF", "OFF", "OFF",
      "D1", "D1", "E2", "E2", "N3", "N3", "OFF"
    ]
  },
  "metadata": {
    "category": "SHIFT",
    "crewCount": 4
  }
}
```

### 4-on-4-off Pattern
Common in emergency services.

```json
{
  "code": "4ON_4OFF",
  "patternJson": {
    "cycle": 8,
    "seq": ["D1", "D1", "D1", "D1", "OFF", "OFF", "OFF", "OFF"]
  },
  "metadata": {
    "category": "SHIFT"
  }
}
```

### Oil Rig 14/14
Offshore rotation.

```json
{
  "code": "OILRIG_14_14",
  "patternJson": {
    "cycle": 28,
    "seq": [
      "D1", "D1", "D1", "D1", "D1", "D1", "D1",
      "D1", "D1", "D1", "D1", "D1", "D1", "D1",
      "OFF", "OFF", "OFF", "OFF", "OFF", "OFF", "OFF",
      "OFF", "OFF", "OFF", "OFF", "OFF", "OFF", "OFF"
    ]
  },
  "metadata": {
    "category": "SEASONAL",
    "location": "offshore"
  }
}
```

---

## Rotation Anchor

The `anchor` parameter allows multiple crews to use the same pattern but start at different points in the cycle.

**Example:** 4-crew rotation with 28-day cycle

- **Crew A**: anchor = 0 (starts at day 0)
- **Crew B**: anchor = 7 (starts at day 7)
- **Crew C**: anchor = 14 (starts at day 14)
- **Crew D**: anchor = 21 (starts at day 21)

```http
GET /api/v1/patterns/pat_3shift/expand?from=2025-12-01&days=7&anchor=7
```

This shifts the pattern by 7 days for Crew B.

---

## Metadata Fields

```json
{
  "category": "OFFICE|SHIFT|SEASONAL|ONCALL",
  "weeklyHours": 40,
  "crewCount": 4,
  "rotationGroup": "A",
  "description": "Standard 5-day work week",
  "tags": ["full-time", "office"],
  "color": "#4CAF50",
  "location": "offshore|onshore",
  "dayBreak": "04:00:00"
}
```

---

## Error Responses

### Invalid Cycle Length
```json
{
  "error": {
    "code": "INVALID_CYCLE",
    "message": "Sequence length must match cycle length",
    "details": {
      "cycle": 7,
      "sequenceLength": 5
    }
  }
}
```

### Invalid Shift Code
```json
{
  "error": {
    "code": "INVALID_SHIFT_CODE",
    "message": "Shift code 'XYZ' not found",
    "details": {
      "invalidCodes": ["XYZ"]
    }
  }
}
```

---

## Use Cases

### Creating a 3-Shift Rotation for 4 Crews

```bash
curl -X POST https://api.xtalent.vng.com/v1/patterns \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "3SHIFT_223",
    "name": "3-Shift 2-2-3 Rotation",
    "patternJson": {
      "cycle": 28,
      "seq": [
        "D1", "D1", "E2", "E2", "OFF", "OFF", "OFF",
        "N3", "N3", "D1", "D1", "OFF", "OFF", "OFF",
        "E2", "E2", "N3", "N3", "OFF", "OFF", "OFF",
        "D1", "D1", "E2", "E2", "N3", "N3", "OFF"
      ]
    },
    "metadata": {
      "category": "SHIFT",
      "crewCount": 4
    },
    "effectiveStart": "2025-01-01"
  }'
```

---

## Next Steps

- Assign patterns to employees via [Schedule Assignment API](./05-schedule-assignment-api.md)
- Review [Shift Definitions](./03-shift-definitions-api.md) used in patterns
- Explore [Use Cases](./20-use-cases.md) for complete workflows
