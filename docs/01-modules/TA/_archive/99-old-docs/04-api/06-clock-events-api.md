# Clock Events API

## Overview

The Clock Events API captures time attendance data from various sources (mobile apps, kiosks, biometric devices). This is the raw punch data that feeds into timesheet compilation.

**Base Path:** `/api/v1/clock-events`

---

## Endpoints

### List Clock Events

```http
GET /api/v1/clock-events
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `employeeId` | UUID | No | Filter by employee |
| `dateFrom` | date | No | Start date for events |
| `dateTo` | date | No | End date for events |
| `eventType` | string | No | Filter by event type (IN, OUT, BREAK_IN, BREAK_OUT) |
| `source` | string | No | Filter by source (MOBILE, KIOSK, API) |
| `limit` | integer | No | Page size (default: 50, max: 200) |
| `cursor` | string | No | Pagination cursor |

**Example Response:**
```json
{
  "data": [
    {
      "id": "evt_abc123",
      "employeeId": "emp_123456",
      "eventDt": "2025-12-01T08:05:23Z",
      "eventType": "IN",
      "source": "MOBILE",
      "deviceId": "mobile_app_v2.1",
      "geoLat": 21.028511,
      "geoLong": 105.804817,
      "metadata": {
        "appVersion": "2.1.5",
        "deviceModel": "iPhone 13",
        "accuracy": 10,
        "photo": "https://storage.xtalent.vng.com/clock/evt_abc123.jpg"
      },
      "createdAt": "2025-12-01T08:05:23Z"
    }
  ]
}
```

---

### Get Clock Event

```http
GET /api/v1/clock-events/{eventId}
```

---

### Create Clock Event

Record a single clock event.

```http
POST /api/v1/clock-events
```

**Request Body:**

```json
{
  "employeeId": "emp_123456",
  "eventDt": "2025-12-01T08:05:23Z",
  "eventType": "IN",
  "source": "MOBILE",
  "deviceId": "mobile_app_v2.1",
  "geoLat": 21.028511,
  "geoLong": 105.804817,
  "metadata": {
    "appVersion": "2.1.5",
    "deviceModel": "iPhone 13",
    "accuracy": 10
  }
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `employeeId` | UUID | Yes | Employee identifier |
| `eventDt` | timestamp | Yes | Event timestamp (ISO 8601) |
| `eventType` | enum | Yes | IN, OUT, BREAK_IN, BREAK_OUT, GEO_IN, GEO_OUT |
| `source` | string | Yes | MOBILE, KIOSK, API, WEB |
| `deviceId` | string | No | Device identifier |
| `geoLat` | decimal | No | Latitude (-90 to 90) |
| `geoLong` | decimal | No | Longitude (-180 to 180) |
| `metadata` | object | No | Additional data (app version, photo, etc.) |

**Response:**
```json
{
  "data": {
    "id": "evt_abc123",
    "employeeId": "emp_123456",
    "eventDt": "2025-12-01T08:05:23Z",
    "eventType": "IN",
    "source": "MOBILE",
    "deviceId": "mobile_app_v2.1",
    "geoLat": 21.028511,
    "geoLong": 105.804817,
    "metadata": {
      "appVersion": "2.1.5",
      "deviceModel": "iPhone 13",
      "accuracy": 10
    },
    "createdAt": "2025-12-01T08:05:23Z"
  }
}
```

---

### Bulk Create Clock Events

Import multiple clock events (e.g., from time clock device export).

```http
POST /api/v1/clock-events/bulk
```

**Request Body:**

```json
{
  "events": [
    {
      "employeeId": "emp_123",
      "eventDt": "2025-12-01T08:00:00Z",
      "eventType": "IN",
      "source": "KIOSK",
      "deviceId": "KIOSK_01"
    },
    {
      "employeeId": "emp_456",
      "eventDt": "2025-12-01T08:05:00Z",
      "eventType": "IN",
      "source": "KIOSK",
      "deviceId": "KIOSK_01"
    }
  ],
  "skipDuplicates": true
}
```

**Response:**
```json
{
  "data": {
    "successful": 2,
    "failed": 0,
    "skipped": 0,
    "results": [
      {
        "index": 0,
        "id": "evt_789",
        "status": "created"
      },
      {
        "index": 1,
        "id": "evt_790",
        "status": "created"
      }
    ]
  }
}
```

---

### Delete Clock Event

```http
DELETE /api/v1/clock-events/{eventId}
```

> [!WARNING]
> Deleting clock events affects timesheet calculations. Only administrators can delete events.

---

## Event Types

| Type | Description | Typical Use |
|------|-------------|-------------|
| `IN` | Clock in (start of work) | Beginning of shift |
| `OUT` | Clock out (end of work) | End of shift |
| `BREAK_IN` | Start of break | Meal/rest break start |
| `BREAK_OUT` | End of break | Return from break |
| `GEO_IN` | Geofence entry | Entering work location |
| `GEO_OUT` | Geofence exit | Leaving work location |

---

## Source Types

| Source | Description |
|--------|-------------|
| `MOBILE` | Mobile app (iOS/Android) |
| `KIOSK` | Fixed kiosk/tablet |
| `WEB` | Web portal |
| `API` | Third-party integration |
| `BIOMETRIC` | Biometric device (fingerprint, face) |
| `RFID` | RFID card reader |

---

## Geolocation Validation

When `geoLat` and `geoLong` are provided, the system can:

1. **Validate location**: Check if employee is within allowed geofence
2. **Track remote work**: Record work-from-home or field locations
3. **Audit trail**: Maintain location history for compliance

**Example with geofence validation:**
```json
{
  "employeeId": "emp_123",
  "eventDt": "2025-12-01T08:05:23Z",
  "eventType": "IN",
  "source": "MOBILE",
  "geoLat": 21.028511,
  "geoLong": 105.804817,
  "metadata": {
    "geofenceId": "office_hanoi",
    "distanceFromCenter": 15.5,
    "withinGeofence": true
  }
}
```

---

## Duplicate Detection

The system automatically detects duplicate clock events based on:
- Same `employeeId`
- Same `eventType`
- Event timestamp within 5 minutes

**Duplicate Response:**
```json
{
  "error": {
    "code": "DUPLICATE_EVENT",
    "message": "Clock event already exists for this employee and time",
    "details": {
      "existingEventId": "evt_abc123",
      "existingEventDt": "2025-12-01T08:05:23Z"
    }
  }
}
```

To skip duplicates in bulk import, set `skipDuplicates: true`.

---

## Metadata Fields

Common metadata fields:

```json
{
  "appVersion": "2.1.5",
  "deviceModel": "iPhone 13",
  "osVersion": "iOS 17.1",
  "accuracy": 10,
  "photo": "https://storage.xtalent.vng.com/clock/evt_abc123.jpg",
  "ipAddress": "192.168.1.100",
  "verified": true,
  "temperature": 36.5,
  "maskDetected": true
}
```

---

## Use Cases

### Mobile App Clock-In

```bash
curl -X POST https://api.xtalent.vng.com/v1/clock-events \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "employeeId": "emp_123456",
    "eventDt": "2025-12-01T08:05:23Z",
    "eventType": "IN",
    "source": "MOBILE",
    "deviceId": "mobile_app_v2.1",
    "geoLat": 21.028511,
    "geoLong": 105.804817,
    "metadata": {
      "appVersion": "2.1.5",
      "photo": "https://storage.xtalent.vng.com/clock/evt_abc123.jpg"
    }
  }'
```

### Kiosk Bulk Import

```bash
curl -X POST https://api.xtalent.vng.com/v1/clock-events/bulk \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "events": [
      {
        "employeeId": "emp_001",
        "eventDt": "2025-12-01T08:00:00Z",
        "eventType": "IN",
        "source": "KIOSK",
        "deviceId": "KIOSK_FLOOR1"
      },
      {
        "employeeId": "emp_002",
        "eventDt": "2025-12-01T08:02:00Z",
        "eventType": "IN",
        "source": "KIOSK",
        "deviceId": "KIOSK_FLOOR1"
      }
    ],
    "skipDuplicates": true
  }'
```

### Query Employee's Daily Events

```bash
curl -X GET "https://api.xtalent.vng.com/v1/clock-events?employeeId=emp_123&dateFrom=2025-12-01&dateTo=2025-12-01" \
  -H "Authorization: Bearer {token}"
```

---

## Integration with Timesheets

Clock events are processed by the timesheet compilation service:

1. **Pairing**: IN/OUT events are paired to calculate work hours
2. **Break Deduction**: BREAK_IN/BREAK_OUT events deduct break time
3. **Rounding**: Times are rounded based on shift rules
4. **Grace Periods**: Late/early clock-ins handled per shift configuration
5. **Exception Detection**: Missing punches, late arrivals flagged

---

## Error Responses

### Invalid Event Type
```json
{
  "error": {
    "code": "INVALID_EVENT_TYPE",
    "message": "Event type must be one of: IN, OUT, BREAK_IN, BREAK_OUT, GEO_IN, GEO_OUT",
    "details": {
      "field": "eventType",
      "value": "INVALID"
    }
  }
}
```

### Future Timestamp
```json
{
  "error": {
    "code": "FUTURE_TIMESTAMP",
    "message": "Event timestamp cannot be in the future",
    "details": {
      "eventDt": "2025-12-31T23:59:59Z",
      "serverTime": "2025-12-01T09:00:00Z"
    }
  }
}
```

---

## Next Steps

- Process events into [Timesheets](./07-timesheet-api.md)
- View [Exceptions](./09-exceptions-api.md) for missing punches
- Configure [Device Integration](./17-device-integration-api.md)
