# Time & Absence API - Overview

## Introduction

The **Time & Absence API** provides a comprehensive, headless REST API for managing employee time tracking, scheduling, and absence/leave management. This API follows modern REST principles and is designed for seamless integration with HR systems, payroll services, mobile applications, and time clock devices.

## Architecture Principles

### Headless API Design
- **Decoupled frontend**: UI can be built independently using any framework
- **Multi-channel access**: Support for web, mobile, kiosk, and third-party integrations
- **Event-driven**: Asynchronous processing via message queues for scalability

### Thin Persistence, Smart Services
- **Minimal database schema**: Core entities with flexible JSON metadata fields
- **Rule-based logic**: Business rules stored as JSON configurations, processed by rule engines
- **Dynamic behavior**: No schema changes needed for new shift patterns or leave policies

### Microservice Architecture

The Time & Absence module is composed of the following bounded contexts:

| Service | Responsibility | Schema |
|---------|---------------|--------|
| **Schedule Service** | Shift definitions, patterns, assignments | `ta.shift_def`, `ta.pattern_template`, `ta.schedule_assignment` |
| **Clock Service** | Time capture from devices/apps | `ta.clock_event` |
| **Timesheet Service** | Compile and manage timesheets | `ta.timesheet_header`, `ta.timesheet_line` |
| **Absence Service** | Leave requests, balances, accruals | `absence.leave_type`, `absence.leave_request`, `absence.leave_account` |
| **Evaluation Service** | Time rules, overtime, premiums | `ta.eval_rule`, `ta.eval_result` |
| **Approval Service** | Workflow tasks and approvals | `workflow_task` |
| **Device Integration** | Device management and data import | `time_device` |

---

## Base URL & Versioning

### Base URL
```
https://api.xtalent.vng.com/v1
```

### Versioning Strategy
- **URL-based versioning**: `/v1`, `/v2`, etc.
- **Backward compatibility**: Maintained for at least 12 months after new version release
- **Deprecation notices**: Provided via response headers (`X-API-Deprecated`, `X-API-Sunset`)

### Environment URLs

| Environment | Base URL |
|-------------|----------|
| Production | `https://api.xtalent.vng.com/v1` |
| Staging | `https://api-staging.xtalent.vng.com/v1` |
| Development | `https://api-dev.xtalent.vng.com/v1` |

---

## Common Patterns

### Request Format
- **Content-Type**: `application/json`
- **Character encoding**: UTF-8
- **Date format**: ISO 8601 (`YYYY-MM-DD` for dates, `YYYY-MM-DDTHH:mm:ssZ` for timestamps)
- **UUID format**: RFC 4122 compliant

### Response Format
All successful responses follow this structure:

```json
{
  "data": { /* response payload */ },
  "meta": {
    "timestamp": "2025-12-01T09:09:27Z",
    "requestId": "req_abc123xyz"
  }
}
```

### Pagination
For list endpoints, pagination follows the cursor-based pattern:

**Request:**
```
GET /api/v1/timesheets?limit=50&cursor=eyJpZCI6IjEyMyJ9
```

**Response:**
```json
{
  "data": [ /* array of items */ ],
  "meta": {
    "hasMore": true,
    "nextCursor": "eyJpZCI6IjE3MyJ9",
    "totalCount": 1250
  }
}
```

**Parameters:**
- `limit`: Number of items per page (default: 50, max: 100)
- `cursor`: Opaque cursor string for next page
- `sort`: Sort field and direction (e.g., `created_at:desc`)

### Filtering & Searching

**Query Parameters:**
```
GET /api/v1/timesheets?employeeId=emp_123&status=SUBMITTED&periodStart=2025-11-01&periodEnd=2025-11-30
```

**Common filters:**
- `employeeId`: Filter by employee UUID
- `status`: Filter by status code
- `dateFrom` / `dateTo`: Date range filters
- `search`: Full-text search (where applicable)

### Bulk Operations

Bulk endpoints accept arrays and return batch results:

**Request:**
```json
POST /api/v1/clock-events/bulk
{
  "events": [
    { "employeeId": "emp_123", "eventDt": "2025-12-01T08:00:00Z", "eventType": "IN" },
    { "employeeId": "emp_456", "eventDt": "2025-12-01T08:05:00Z", "eventType": "IN" }
  ]
}
```

**Response:**
```json
{
  "data": {
    "successful": 1,
    "failed": 1,
    "results": [
      { "index": 0, "id": "evt_789", "status": "created" },
      { "index": 1, "error": "DUPLICATE_EVENT", "message": "Event already exists" }
    ]
  }
}
```

---

## Rate Limiting

### Limits
- **Standard tier**: 1000 requests per minute per API key
- **Premium tier**: 5000 requests per minute per API key
- **Burst allowance**: 2x limit for up to 10 seconds

### Headers
Response headers indicate current rate limit status:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 847
X-RateLimit-Reset: 1638360000
```

### Exceeded Limit Response
```json
HTTP/1.1 429 Too Many Requests
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Retry after 45 seconds.",
    "retryAfter": 45
  }
}
```

---

## Idempotency

### Idempotency Keys
For `POST`, `PUT`, `PATCH` operations, clients can provide an idempotency key:

```
POST /api/v1/leave-requests
Idempotency-Key: req_abc123xyz
```

- **Key format**: Any string up to 255 characters
- **Retention**: Keys stored for 24 hours
- **Behavior**: Duplicate requests with same key return the original response

---

## Webhooks & Events

### Event-Driven Architecture

The Time & Absence API publishes events for asynchronous processing:

| Event | Description |
|-------|-------------|
| `clock.event.created` | New clock event recorded |
| `timesheet.submitted` | Timesheet submitted for approval |
| `timesheet.approved` | Timesheet approved |
| `absence.leave.approved` | Leave request approved |
| `absence.accrual.posted` | Leave accrual processed |
| `exception.detected` | Time exception detected |

### Webhook Configuration
Configure webhooks via the API or admin portal:

```json
POST /api/v1/webhooks
{
  "url": "https://your-app.com/webhooks/time-absence",
  "events": ["timesheet.approved", "absence.leave.approved"],
  "secret": "whsec_abc123xyz"
}
```

### Event Payload
```json
{
  "eventId": "evt_abc123",
  "eventType": "timesheet.approved",
  "timestamp": "2025-12-01T09:09:27Z",
  "data": {
    "timesheetId": "ts_789",
    "employeeId": "emp_123",
    "periodStart": "2025-11-01",
    "periodEnd": "2025-11-30"
  }
}
```

---

## API Endpoints Overview

### Time Attendance APIs
- [Shift Definitions](./03-shift-definitions-api.md) - `/api/v1/shifts`
- [Pattern Templates](./04-pattern-templates-api.md) - `/api/v1/patterns`
- [Schedule Assignments](./05-schedule-assignment-api.md) - `/api/v1/schedules/assignments`
- [Clock Events](./06-clock-events-api.md) - `/api/v1/clock-events`
- [Timesheets](./07-timesheet-api.md) - `/api/v1/timesheets`
- [Time Evaluation](./08-time-evaluation-api.md) - `/api/v1/time-eval`
- [Exceptions](./09-exceptions-api.md) - `/api/v1/exceptions`

### Absence Management APIs
- [Leave Types](./10-leave-types-api.md) - `/api/v1/leave-types`
- [Leave Policies](./11-leave-policies-api.md) - `/api/v1/leave-policies`
- [Leave Requests](./12-leave-requests-api.md) - `/api/v1/leave-requests`
- [Leave Balances](./13-leave-balance-api.md) - `/api/v1/leave-balances`
- [Leave Accruals](./14-leave-accrual-api.md) - `/api/v1/leave-accruals`

### Supporting Services
- [Holiday Calendars](./15-holiday-calendar-api.md) - `/api/v1/holiday-calendars`
- [Approval Workflows](./16-approval-workflow-api.md) - `/api/v1/approvals`
- [Device Integration](./17-device-integration-api.md) - `/api/v1/devices`
- [Reporting](./18-reporting-api.md) - `/api/v1/reports`

---

## Getting Started

1. **Authentication**: Review [Authentication & Authorization](./01-authentication.md)
2. **Common Models**: Understand [Common Data Models](./02-common-models.md)
3. **Integration Guide**: Follow [Integration Guide](./19-integration-guide.md)
4. **Use Cases**: Explore [Common Use Cases](./20-use-cases.md)

---

## Support & Resources

- **API Status**: https://status.xtalent.vng.com
- **Developer Portal**: https://developers.xtalent.vng.com
- **Support Email**: api-support@xtalent.vng.com
- **Slack Community**: #xtalent-api-support
