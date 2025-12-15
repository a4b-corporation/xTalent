# Integration Specification - Time & Absence Module

**Version**: 2.0  
**Last Updated**: 2025-12-15  
**Module**: Time & Absence (TA)  
**Status**: Draft

---

## Document Information

- **Purpose**: Define all integration points for the TA module
- **Audience**: Integration Developers, System Architects, DevOps
- **Scope**: Module integrations, external integrations, event patterns
- **Related Documents**:
  - [API Specification](./02-api-specification.md) - API contracts
  - [Integration Guide](./INTEGRATION-GUIDE.md) - Implementation guide

---

## Table of Contents

1. [Module Integrations](#module-integrations)
2. [External Integrations](#external-integrations)
3. [Integration Patterns](#integration-patterns)
4. [Event Catalog](#event-catalog)
5. [Data Synchronization](#data-synchronization)

---

# Module Integrations

## Core Module (CO)

### Worker Integration

**Purpose**: Get employee information

**Integration Type**: API Call (Synchronous)

**Endpoints Used**:
- `GET /api/v1/core/workers/{id}` - Get worker details
- `GET /api/v1/core/workers` - List workers

**Data Consumed**:
- Employee ID, Name, Email
- Hire Date, Termination Date
- Employment Type, Status
- Organization Unit, Manager
- Work Schedule

**Frequency**: Real-time (on-demand)

**Error Handling**: Cache worker data locally, retry on failure

---

### Eligibility Profile Integration

**Purpose**: Check employee eligibility for leave types

**Integration Type**: API Call (Synchronous)

**Endpoints Used**:
- `POST /api/v1/core/eligibility/check` - Check eligibility

**Request**:
```json
{
  "employeeId": "uuid",
  "profileId": "uuid",
  "asOfDate": "2025-12-15"
}
```

**Response**:
```json
{
  "isEligible": true,
  "reason": "Employee meets all criteria"
}
```

**Frequency**: Real-time (on leave request creation)

---

## Payroll Module (PR)

### Leave Deduction Integration

**Purpose**: Send leave usage data to payroll

**Integration Type**: Event-Driven (Asynchronous)

**Event**: `leave.request.approved`

**Payload**:
```json
{
  "eventType": "leave.request.approved",
  "employeeId": "uuid",
  "leaveTypeId": "uuid",
  "startDate": "2025-12-20",
  "endDate": "2025-12-22",
  "workingDays": 3.0,
  "isPaid": true
}
```

**Processing**: Payroll deducts unpaid leave from salary

---

### Overtime Pay Integration

**Purpose**: Send overtime hours to payroll

**Integration Type**: Event-Driven (Asynchronous)

**Event**: `timesheet.approved`

**Payload**:
```json
{
  "eventType": "timesheet.approved",
  "employeeId": "uuid",
  "payPeriodId": "uuid",
  "overtimeHours": [
    {
      "type": "DAILY",
      "hours": 5.0,
      "multiplier": 1.5
    },
    {
      "type": "WEEKEND",
      "hours": 8.0,
      "multiplier": 2.0
    }
  ]
}
```

**Processing**: Payroll calculates overtime pay

---

## Total Rewards Module (TR)

### Attendance Bonus Integration

**Purpose**: Send attendance data for bonus calculation

**Integration Type**: Batch (Monthly)

**Schedule**: 1st of each month

**Data Sent**:
- Employee ID
- Total days worked
- Total days late
- Total absences
- Attendance percentage

**Processing**: TR calculates attendance bonus

---

# External Integrations

## Time Clock Devices

### Biometric Clock Integration

**Purpose**: Receive clock in/out events from biometric devices

**Integration Type**: Webhook (Push)

**Protocol**: HTTPS POST

**Endpoint**: `POST /api/v1/ta/webhooks/clock-events`

**Payload**:
```json
{
  "deviceId": "DEVICE-001",
  "employeeId": "uuid",
  "biometricId": "12345",
  "timestamp": "2025-12-15T08:02:00Z",
  "eventType": "CLOCK_IN",
  "biometricType": "FINGERPRINT",
  "matchScore": 98.5,
  "location": {
    "latitude": 10.7769,
    "longitude": 106.7009
  }
}
```

**Authentication**: API Key in header

**Error Handling**: Device queues events if offline, retries on failure

---

### RFID Badge Integration

**Purpose**: Receive badge swipe events

**Integration Type**: Webhook (Push)

**Payload**:
```json
{
  "deviceId": "READER-001",
  "badgeId": "BADGE-12345",
  "timestamp": "2025-12-15T08:02:00Z",
  "eventType": "SWIPE_IN"
}
```

**Processing**: System maps badgeId to employeeId

---

## Calendar Systems

### Google Calendar Integration

**Purpose**: Sync approved leave to Google Calendar

**Integration Type**: API Call (Synchronous)

**API**: Google Calendar API v3

**Operations**:
- Create calendar event for approved leave
- Update event if leave is modified
- Delete event if leave is cancelled

**Event Format**:
```json
{
  "summary": "Annual Leave - Jane Doe",
  "description": "Approved leave request",
  "start": {
    "date": "2025-12-20"
  },
  "end": {
    "date": "2025-12-23"
  },
  "colorId": "10"
}
```

**Authentication**: OAuth 2.0

---

### Outlook Calendar Integration

**Purpose**: Sync approved leave to Outlook Calendar

**Integration Type**: API Call (Synchronous)

**API**: Microsoft Graph API

**Operations**: Same as Google Calendar

**Authentication**: OAuth 2.0 with Microsoft

---

## HRIS Systems

### SAP SuccessFactors Integration

**Purpose**: Sync employee data and leave balances

**Integration Type**: Batch (Daily)

**Protocol**: SFTP or API

**Data Sync**:
- Employee master data (daily)
- Leave balances (daily)
- Leave requests (real-time)

**File Format**: CSV or XML

---

### Workday Integration

**Purpose**: Sync employee data and time tracking

**Integration Type**: API (Real-time)

**API**: Workday REST API

**Operations**:
- Get employee data
- Send time entries
- Sync leave requests

**Authentication**: OAuth 2.0

---

# Integration Patterns

## Event-Driven Pattern

**Use Cases**:
- Leave request approved → Notify Payroll
- Timesheet approved → Send to Payroll
- Attendance exception → Notify Manager

**Technology**: Event Bus (e.g., Kafka, RabbitMQ)

**Event Structure**:
```json
{
  "eventId": "uuid",
  "eventType": "domain.entity.action",
  "timestamp": "2025-12-15T10:00:00Z",
  "tenantId": "uuid",
  "source": "TA",
  "data": { ... }
}
```

**Retry Policy**:
- Max retries: 3
- Backoff: Exponential (1s, 2s, 4s)
- Dead letter queue for failed events

---

## API-Based Pattern

**Use Cases**:
- Get employee data from Core
- Check eligibility
- Validate against business rules

**Technology**: REST API over HTTPS

**Authentication**: OAuth 2.0 Bearer Token

**Rate Limiting**: 1000 requests/minute per tenant

**Circuit Breaker**: Open after 5 consecutive failures

---

## Batch Processing Pattern

**Use Cases**:
- Daily employee sync
- Monthly attendance reports
- Annual leave allocation

**Technology**: Scheduled jobs (Cron)

**File Format**: CSV, JSON, or XML

**Transfer**: SFTP or S3

**Schedule Examples**:
- Employee sync: Daily at 02:00 AM
- Leave allocation: Annually on Jan 1
- Attendance reports: Monthly on 1st

---

## Webhook Pattern

**Use Cases**:
- Time clock events
- External system notifications

**Technology**: HTTPS POST

**Authentication**: API Key or HMAC signature

**Retry**: Sender retries on 5xx errors

**Idempotency**: Use event ID to prevent duplicates

---

# Event Catalog

## Leave Management Events

| Event Type | Description | Payload |
|------------|-------------|---------|
| `leave.request.created` | Leave request created | LeaveRequest |
| `leave.request.submitted` | Leave request submitted | LeaveRequest |
| `leave.request.approved` | Leave request approved | LeaveRequest |
| `leave.request.rejected` | Leave request rejected | LeaveRequest |
| `leave.request.withdrawn` | Leave request withdrawn | LeaveRequest |
| `leave.request.cancelled` | Leave request cancelled | LeaveRequest |
| `leave.balance.updated` | Leave balance changed | LeaveBalance |
| `leave.allocation.completed` | Annual allocation done | AllocationSummary |

## Attendance Events

| Event Type | Description | Payload |
|------------|-------------|---------|
| `attendance.clocked_in` | Employee clocked in | AttendanceRecord |
| `attendance.clocked_out` | Employee clocked out | AttendanceRecord |
| `attendance.exception.created` | Exception detected | AttendanceException |
| `attendance.exception.resolved` | Exception resolved | AttendanceException |

## Timesheet Events

| Event Type | Description | Payload |
|------------|-------------|---------|
| `timesheet.generated` | Timesheet generated | Timesheet |
| `timesheet.submitted` | Timesheet submitted | Timesheet |
| `timesheet.approved` | Timesheet approved | Timesheet |
| `timesheet.rejected` | Timesheet rejected | Timesheet |

---

# Data Synchronization

## Employee Master Data

**Source**: Core Module

**Sync Frequency**: Real-time + Daily batch

**Sync Method**:
- Real-time: Event-driven for critical changes (hire, terminate)
- Batch: Daily full sync at 02:00 AM

**Data Fields**:
- Employee ID, Name, Email
- Hire Date, Termination Date
- Employment Type, Status
- Organization Unit, Manager
- Work Schedule, Location

**Conflict Resolution**: Core module is source of truth

---

## Leave Balance Sync

**Target**: HRIS Systems (SAP, Workday)

**Sync Frequency**: Daily

**Sync Method**: Batch export

**File Format**: CSV

**Sample**:
```csv
EmployeeID,LeaveType,TotalAllocated,Used,Available,AsOfDate
EMP001,Annual Leave,20.0,5.0,15.0,2025-12-15
EMP001,Sick Leave,12.0,2.0,10.0,2025-12-15
```

---

## Attendance Data Sync

**Target**: Payroll Module

**Sync Frequency**: End of pay period

**Sync Method**: Event-driven (timesheet approved)

**Data**: Approved timesheets with hours breakdown

---

## Document Status

**Status**: Complete  
**Coverage**:
- ✅ Module Integrations (3 modules)
- ✅ External Integrations (4 systems)
- ✅ Integration Patterns (4 patterns)
- ✅ Event Catalog (15+ events)
- ✅ Data Synchronization (3 sync flows)

**Last Updated**: 2025-12-15
