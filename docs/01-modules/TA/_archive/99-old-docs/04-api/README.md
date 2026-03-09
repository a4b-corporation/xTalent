# Time & Absence API - README

## Overview

This directory contains comprehensive API documentation for the **Time & Absence** module of xTalent HCM. The APIs follow REST principles and support headless architecture for maximum flexibility.

## Architecture

The Time & Absence module is built on a **6-level hierarchical model**:

```
Level 1: Time Segment (Atomic unit - WORK, BREAK, MEAL, TRANSFER)
    ↓
Level 2: Shift (Composition of segments - ELAPSED, PUNCH, FLEX)
    ↓
Level 3: Day Model (Daily work schedule - WORK, OFF, HOLIDAY)
    ↓
Level 4: Pattern (Period work schedule - cycle of day models)
    ↓
Level 5: Work Schedule Rule (Pattern + calendar + rotation)
    ↓
Level 6: Roster (Assignment to employees/groups)
```

## API Documentation Structure

### Core Documentation
- **[00-overview.md](./00-overview.md)** - API introduction, base URLs, common patterns
- **[01-authentication.md](./01-authentication.md)** - OAuth 2.0, JWT, RBAC
- **[02-common-models.md](./02-common-models.md)** - Data models, error formats, pagination

### Time Attendance APIs
- **[03-shift-definitions-api.md](./03-shift-definitions-api.md)** - Shift templates (ELAPSED, PUNCH, FLEX)
- **[04-pattern-templates-api.md](./04-pattern-templates-api.md)** - Work patterns (5x8, 4on-4off, rotations)
- **[05-schedule-assignment-api.md](./05-schedule-assignment-api.md)** - Schedule rules with rotation offsets
- **[06-clock-events-api.md](./06-clock-events-api.md)** - Time capture from devices/apps
- **[07-timesheet-api.md](./07-timesheet-api.md)** - Timesheet compilation and approval
- **[08-time-evaluation-api.md](./08-time-evaluation-api.md)** - Overtime and premium calculations
- **[09-exceptions-api.md](./09-exceptions-api.md)** - Time exceptions and violations

### Absence Management APIs
- **[10-leave-types-api.md](./10-leave-types-api.md)** - Leave type master data
- **[11-leave-policies-api.md](./11-leave-policies-api.md)** - Leave policies and rules
- **[12-leave-requests-api.md](./12-leave-requests-api.md)** - Leave request submission and approval
- **[13-leave-balance-api.md](./13-leave-balance-api.md)** - Balance queries and ledger
- **[14-leave-accrual-api.md](./14-leave-accrual-api.md)** - Accrual processing and carry-over

### Supporting Services
- **[15-holiday-calendar-api.md](./15-holiday-calendar-api.md)** - Holiday calendar management
- **[16-approval-workflow-api.md](./16-approval-workflow-api.md)** - Approval tasks and workflows
- **[17-device-integration-api.md](./17-device-integration-api.md)** - Device management and import
- **[18-reporting-api.md](./18-reporting-api.md)** - Reports and analytics

### Integration & Use Cases
- **[19-integration-guide.md](./19-integration-guide.md)** - Integration patterns and examples
- **[20-use-cases.md](./20-use-cases.md)** - End-to-end scenarios

## Quick Start

### 1. Authentication

Obtain an access token:

```bash
curl -X POST https://auth.xtalent.vng.com/oauth/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=YOUR_CLIENT_ID&client_secret=YOUR_CLIENT_SECRET&scope=time:read time:write absence:read absence:write"
```

### 2. Create a Shift

```bash
curl -X POST https://api.xtalent.vng.com/v1/shifts \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "D1",
    "name": "Day Shift",
    "shiftType": "ELAPSED",
    "referenceStartTime": "08:00:00",
    "referenceEndTime": "17:00:00",
    "effectiveStart": "2025-01-01"
  }'
```

### 3. Record Clock Event

```bash
curl -X POST https://api.xtalent.vng.com/v1/clock-events \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "employeeId": "emp_123456",
    "eventDt": "2025-12-01T08:05:23Z",
    "eventType": "IN",
    "source": "MOBILE"
  }'
```

### 4. Submit Leave Request

```bash
curl -X POST https://api.xtalent.vng.com/v1/leave-requests \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "employeeId": "emp_123456",
    "leaveTypeId": "lt_annual",
    "startDate": "2025-12-15",
    "endDate": "2025-12-17",
    "reason": "Family vacation"
  }'
```

## Key Concepts

### Thin Persistence, Smart Services

- **Minimal database schema**: Core entities with flexible JSON metadata
- **Rule-based logic**: Business rules stored as JSON, processed by rule engines
- **Dynamic behavior**: No schema changes needed for new patterns or policies

### Event-Driven Architecture

Key events published:
- `clock.event.created`
- `timesheet.submitted`
- `timesheet.approved`
- `absence.leave.approved`
- `absence.accrual.posted`

### Headless API Design

- **Decoupled frontend**: Build UI with any framework
- **Multi-channel**: Web, mobile, kiosk, third-party integrations
- **Flexible**: Customize workflows without backend changes

## Common Workflows

### Time Attendance Flow

```
1. Define Shifts → 2. Create Patterns → 3. Assign Schedules
    ↓
4. Generate Roster → 5. Clock In/Out → 6. Compile Timesheet
    ↓
7. Submit for Approval → 8. Export to Payroll
```

### Absence Management Flow

```
1. Configure Leave Types → 2. Set Policies → 3. Allocate Balances
    ↓
4. Submit Leave Request → 5. Approval Workflow → 6. Deduct Balance
    ↓
7. Update Timesheet → 8. Export to Payroll
```

## API Conventions

### Base URL
```
https://api.xtalent.vng.com/v1
```

### Date/Time Formats
- **Date**: `YYYY-MM-DD` (e.g., `2025-12-01`)
- **Timestamp**: `YYYY-MM-DDTHH:mm:ssZ` (e.g., `2025-12-01T09:09:27Z`)
- **Time**: `HH:mm:ss` (e.g., `08:30:00`)

### Standard Response
```json
{
  "data": { /* response payload */ },
  "meta": {
    "timestamp": "2025-12-01T09:09:27Z",
    "requestId": "req_abc123xyz"
  }
}
```

### Error Response
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": { /* additional context */ }
  }
}
```

## Rate Limits

- **Standard**: 1000 requests/minute
- **Premium**: 5000 requests/minute
- **Burst**: 2x limit for up to 10 seconds

## Support

- **API Status**: https://status.xtalent.vng.com
- **Developer Portal**: https://developers.xtalent.vng.com
- **Support Email**: api-support@xtalent.vng.com

## Related Documentation

- **Ontology**: `../00-ontology/` - Domain model and entity definitions
- **Concepts**: `../01-concept/` - Conceptual guides
- **Specifications**: `../02-spec/` - Behavior specifications
- **Database Design**: `../03-design/` - DBML schemas
- **UI Documentation**: `../05-ui/` - UI specifications

## Version History

- **v1.0** (2025-12-01): Initial release with 6-level hierarchical model
