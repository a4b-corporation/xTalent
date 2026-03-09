# Common Data Models & Schemas

## Overview

This document defines common data structures, response formats, and reusable schemas used across the Time & Absence API.

---

## Standard Response Envelope

### Success Response

All successful API responses follow this structure:

```json
{
  "data": { /* response payload */ },
  "meta": {
    "timestamp": "2025-12-01T09:09:27Z",
    "requestId": "req_abc123xyz"
  }
}
```

**Fields:**
- `data`: The actual response payload (object or array)
- `meta`: Metadata about the response
  - `timestamp`: ISO 8601 timestamp when response was generated
  - `requestId`: Unique request identifier for debugging

### List Response with Pagination

```json
{
  "data": [
    { /* item 1 */ },
    { /* item 2 */ }
  ],
  "meta": {
    "timestamp": "2025-12-01T09:09:27Z",
    "requestId": "req_abc123xyz",
    "pagination": {
      "limit": 50,
      "hasMore": true,
      "nextCursor": "eyJpZCI6IjE3MyJ9",
      "totalCount": 1250
    }
  }
}
```

---

## Error Response Format

### Standard Error Structure

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": { /* optional additional context */ },
    "timestamp": "2025-12-01T09:09:27Z",
    "requestId": "req_abc123xyz"
  }
}
```

### Common Error Codes

| HTTP Status | Error Code | Description |
|-------------|------------|-------------|
| 400 | `INVALID_REQUEST` | Request validation failed |
| 400 | `INVALID_PARAMETER` | Invalid parameter value |
| 400 | `MISSING_REQUIRED_FIELD` | Required field missing |
| 401 | `UNAUTHORIZED` | Authentication failed |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Resource not found |
| 409 | `CONFLICT` | Resource conflict (e.g., duplicate) |
| 409 | `DUPLICATE_EVENT` | Duplicate clock event |
| 422 | `VALIDATION_ERROR` | Business rule validation failed |
| 422 | `INSUFFICIENT_BALANCE` | Insufficient leave balance |
| 429 | `RATE_LIMIT_EXCEEDED` | Too many requests |
| 500 | `INTERNAL_ERROR` | Server error |
| 503 | `SERVICE_UNAVAILABLE` | Service temporarily unavailable |

### Validation Error Example

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": {
      "fields": [
        {
          "field": "startDate",
          "message": "Start date must be before end date",
          "value": "2025-12-31"
        },
        {
          "field": "leaveType",
          "message": "Invalid leave type code",
          "value": "INVALID"
        }
      ]
    },
    "timestamp": "2025-12-01T09:09:27Z",
    "requestId": "req_abc123xyz"
  }
}
```

---

## Common Data Types

### UUID Format
```
emp_123e4567e89b12d3a456426614174000
ts_987fcdeb51a2b3c4d5e6f78901234567
```

**Pattern:** `{prefix}_{uuid_v4}`

**Common Prefixes:**
- `emp_` - Employee
- `ts_` - Timesheet
- `shift_` - Shift Definition
- `pat_` - Pattern Template
- `evt_` - Clock Event
- `lr_` - Leave Request
- `lt_` - Leave Type

### Date & Time Formats

| Type | Format | Example |
|------|--------|---------|
| Date | `YYYY-MM-DD` | `2025-12-01` |
| Timestamp | `YYYY-MM-DDTHH:mm:ssZ` | `2025-12-01T09:09:27Z` |
| Time | `HH:mm:ss` | `08:30:00` |
| Duration | ISO 8601 Duration | `PT8H30M` (8 hours 30 minutes) |

### Status Codes

#### Timesheet Status
```typescript
enum TimesheetStatus {
  OPEN = "OPEN",
  SUBMITTED = "SUBMITTED",
  APPROVED = "APPROVED",
  REJECTED = "REJECTED",
  LOCKED = "LOCKED"
}
```

#### Leave Request Status
```typescript
enum LeaveRequestStatus {
  DRAFT = "DRAFT",
  SUBMITTED = "SUBMITTED",
  APPROVED = "APPROVED",
  REJECTED = "REJECTED",
  CANCELLED = "CANCELLED",
  POSTED = "POSTED"
}
```

#### Clock Event Type
```typescript
enum ClockEventType {
  IN = "IN",
  OUT = "OUT",
  BREAK_IN = "BREAK_IN",
  BREAK_OUT = "BREAK_OUT",
  GEO_IN = "GEO_IN",
  GEO_OUT = "GEO_OUT"
}
```

---

## Core Entity Schemas

### Employee Reference

```json
{
  "employeeId": "emp_123456",
  "employeeCode": "EMP001",
  "fullName": "Nguyen Van A",
  "email": "nguyenvana@company.com",
  "legalEntityId": "le_vn_001",
  "businessUnitId": "bu_sales"
}
```

### Shift Definition

```json
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
    "color": "#4CAF50"
  },
  "effectiveStart": "2025-01-01",
  "effectiveEnd": null
}
```

### Pattern Template

```json
{
  "id": "pat_xyz789",
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
  "effectiveEnd": null
}
```

### Clock Event

```json
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
    "accuracy": 10
  }
}
```

### Timesheet Header

```json
{
  "id": "ts_abc123",
  "employeeId": "emp_123456",
  "periodStart": "2025-11-01",
  "periodEnd": "2025-11-30",
  "statusCode": "SUBMITTED",
  "totalHours": 176.00,
  "workflowState": {
    "submittedAt": "2025-12-01T09:00:00Z",
    "submittedBy": "emp_123456",
    "currentApprover": "emp_manager01"
  },
  "metadata": {
    "notes": "Regular month, no exceptions"
  }
}
```

### Timesheet Line

```json
{
  "id": "tsl_abc123",
  "headerId": "ts_abc123",
  "workDate": "2025-11-15",
  "timeTypeCode": "REG",
  "qtyHours": 8.00,
  "sourceClockId": "evt_xyz789",
  "relatedLeaveId": null,
  "metadata": {
    "shiftCode": "D1",
    "calculatedBy": "AUTO"
  }
}
```

### Leave Request

```json
{
  "id": "lr_abc123",
  "employeeId": "emp_123456",
  "typeCode": "ANL",
  "startDt": "2025-12-15T00:00:00Z",
  "endDt": "2025-12-17T23:59:59Z",
  "qtyHours": 24.00,
  "statusCode": "APPROVED",
  "workflowState": {
    "submittedAt": "2025-12-01T09:00:00Z",
    "approvedAt": "2025-12-01T10:30:00Z",
    "approvedBy": "emp_manager01"
  },
  "reason": "Family vacation",
  "metadata": {
    "attachments": [
      {
        "url": "https://storage.xtalent.vng.com/docs/lr_abc123_doc1.pdf",
        "name": "travel_booking.pdf"
      }
    ]
  }
}
```

### Leave Balance

```json
{
  "employeeId": "emp_123456",
  "typeCode": "ANL",
  "balanceHours": 80.00,
  "blockedHours": 24.00,
  "availableHours": 56.00,
  "asOfDate": "2025-12-01",
  "metadata": {
    "accrualRate": "8 hours/month",
    "maxCarryOver": 40.00
  }
}
```

---

## Metadata JSON Patterns

### Shift Metadata

```json
{
  "mealBreak": true,
  "premiumZone": false,
  "color": "#4CAF50",
  "icon": "day_shift",
  "allowOvertimeAutoApproval": false,
  "graceMinutes": 15,
  "roundingRule": "QUARTER_HOUR"
}
```

### Pattern Metadata

```json
{
  "category": "OFFICE|SHIFT|SEASONAL|ONCALL",
  "weeklyHours": 40,
  "rotationGroup": "A",
  "description": "Standard 5-day work week",
  "tags": ["full-time", "office"]
}
```

### Clock Event Metadata

```json
{
  "appVersion": "2.1.5",
  "deviceModel": "iPhone 13",
  "accuracy": 10,
  "ipAddress": "192.168.1.100",
  "photo": "https://storage.xtalent.vng.com/clock/evt_abc123.jpg",
  "verified": true
}
```

### Timesheet Metadata

```json
{
  "notes": "Regular month",
  "exceptions": [
    {
      "date": "2025-11-10",
      "type": "LATE",
      "resolved": true
    }
  ],
  "payrollExported": true,
  "exportedAt": "2025-12-01T10:00:00Z"
}
```

### Leave Request Metadata

```json
{
  "attachments": [
    {
      "url": "https://storage.xtalent.vng.com/docs/lr_abc123_doc1.pdf",
      "name": "medical_certificate.pdf",
      "uploadedAt": "2025-12-01T09:00:00Z"
    }
  ],
  "emergencyContact": "+84 901 234 567",
  "returnToWorkDate": "2025-12-18"
}
```

---

## Pagination Models

### Cursor-Based Pagination

**Request:**
```
GET /api/v1/timesheets?limit=50&cursor=eyJpZCI6IjEyMyJ9&sort=created_at:desc
```

**Response:**
```json
{
  "data": [ /* items */ ],
  "meta": {
    "pagination": {
      "limit": 50,
      "hasMore": true,
      "nextCursor": "eyJpZCI6IjE3MyJ9",
      "prevCursor": "eyJpZCI6IjczIn0",
      "totalCount": 1250
    }
  }
}
```

### Offset-Based Pagination (Legacy)

**Request:**
```
GET /api/v1/timesheets?limit=50&offset=100
```

**Response:**
```json
{
  "data": [ /* items */ ],
  "meta": {
    "pagination": {
      "limit": 50,
      "offset": 100,
      "totalCount": 1250,
      "totalPages": 25,
      "currentPage": 3
    }
  }
}
```

---

## Filtering & Sorting

### Filter Operators

```
GET /api/v1/timesheets?employeeId=emp_123&status=SUBMITTED,APPROVED&periodStart[gte]=2025-11-01
```

**Supported operators:**
- `[eq]` - Equal (default if no operator)
- `[ne]` - Not equal
- `[gt]` - Greater than
- `[gte]` - Greater than or equal
- `[lt]` - Less than
- `[lte]` - Less than or equal
- `[in]` - In list (comma-separated)
- `[like]` - Pattern match (use `%` as wildcard)

### Sort Parameters

```
GET /api/v1/timesheets?sort=periodStart:desc,employeeCode:asc
```

**Format:** `field:direction` (comma-separated for multiple)
- Direction: `asc` or `desc`

---

## Bulk Operation Response

```json
{
  "data": {
    "successful": 8,
    "failed": 2,
    "results": [
      {
        "index": 0,
        "id": "evt_abc123",
        "status": "created"
      },
      {
        "index": 1,
        "error": "DUPLICATE_EVENT",
        "message": "Clock event already exists for this timestamp"
      }
    ]
  },
  "meta": {
    "timestamp": "2025-12-01T09:09:27Z",
    "requestId": "req_abc123xyz"
  }
}
```

---

## Next Steps

- Explore [Shift Definitions API](./03-shift-definitions-api.md)
- Review [Timesheet API](./07-timesheet-api.md)
- Check [Leave Requests API](./12-leave-requests-api.md)
