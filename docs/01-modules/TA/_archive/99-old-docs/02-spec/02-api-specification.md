# API Specification - Time & Absence Module

**Version**: 2.0  
**Last Updated**: 2025-12-15  
**Module**: Time & Absence (TA)  
**Status**: Draft

---

## Document Information

- **Purpose**: Define all REST API endpoints for the TA module
- **Audience**: Backend Developers, Frontend Developers, Integration Developers
- **Scope**: Absence Management and Time & Attendance APIs
- **API Style**: RESTful
- **Base URL**: `/api/v1/ta`
- **Authentication**: OAuth 2.0 Bearer Token
- **Content Type**: `application/json`

---

## Table of Contents

1. [Leave Management APIs](#leave-management-apis)
2. [Attendance APIs](#attendance-apis)
3. [Scheduling APIs](#scheduling-apis)
4. [Timesheet APIs](#timesheet-apis)
5. [Overtime APIs](#overtime-apis)
6. [Shared APIs](#shared-apis)
7. [Common Patterns](#common-patterns)
8. [Error Codes](#error-codes)

---

## API Conventions

### Request Headers

All requests must include:
```http
Authorization: Bearer {access_token}
Content-Type: application/json
X-Tenant-ID: {tenant_id}
X-Request-ID: {unique_request_id}
```

### Response Format

Success responses (2xx):
```json
{
  "data": { ... },
  "meta": {
    "requestId": "uuid",
    "timestamp": "2025-12-15T10:00:00Z"
  }
}
```

Error responses (4xx, 5xx):
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": [ ... ],
    "requestId": "uuid",
    "timestamp": "2025-12-15T10:00:00Z"
  }
}
```

### Pagination

List endpoints support pagination:
```
GET /api/v1/ta/resource?page=1&pageSize=20&sort=createdAt:desc
```

Response includes pagination metadata:
```json
{
  "data": [ ... ],
  "meta": {
    "page": 1,
    "pageSize": 20,
    "totalItems": 150,
    "totalPages": 8
  }
}
```

---

# Leave Management APIs

## Create Leave Request

**Endpoint**: `POST /api/v1/ta/leave-requests`  
**Description**: Create a new leave request  
**Authorization**: Employee, Manager, HR  
**Related FR**: FR-ABS-001

### Request Body

```json
{
  "leaveTypeId": "uuid",
  "startDate": "2025-12-20",
  "endDate": "2025-12-22",
  "halfDay": false,
  "halfDayPeriod": null,
  "reason": "Family vacation",
  "attachments": [
    {
      "fileName": "medical-cert.pdf",
      "fileUrl": "https://..."
    }
  ]
}
```

### Response (201 Created)

```json
{
  "data": {
    "id": "uuid",
    "employeeId": "uuid",
    "leaveTypeId": "uuid",
    "leaveTypeName": "Annual Leave",
    "startDate": "2025-12-20",
    "endDate": "2025-12-22",
    "totalDays": 3.0,
    "workingDays": 3.0,
    "status": "DRAFT",
    "reason": "Family vacation",
    "currentBalance": 15.0,
    "balanceAfter": 12.0,
    "createdAt": "2025-12-15T10:00:00Z",
    "updatedAt": "2025-12-15T10:00:00Z"
  }
}
```

### Validation Rules

- `startDate` must not be in the past (unless retroactive allowed)
- `endDate` must be >= `startDate`
- `leaveTypeId` must exist and be active
- Employee must be eligible for leave type
- Sufficient balance must be available
- No overlapping requests

### Error Codes

- `LEAVE_TYPE_NOT_FOUND`: Leave type does not exist
- `INSUFFICIENT_BALANCE`: Not enough leave balance
- `OVERLAPPING_REQUEST`: Dates overlap with existing request
- `NOT_ELIGIBLE`: Employee not eligible for this leave type
- `BLACKOUT_PERIOD`: Dates fall within blackout period

---

## Submit Leave Request

**Endpoint**: `POST /api/v1/ta/leave-requests/{id}/submit`  
**Description**: Submit leave request for approval  
**Authorization**: Employee (owner), HR  
**Related FR**: FR-ABS-005

### Request Body

```json
{
  "comment": "Optional submission comment"
}
```

### Response (200 OK)

```json
{
  "data": {
    "id": "uuid",
    "status": "PENDING",
    "submittedAt": "2025-12-15T10:00:00Z",
    "currentApprover": {
      "id": "uuid",
      "name": "John Manager",
      "email": "john@example.com"
    },
    "approvalChain": [
      {
        "level": 1,
        "approverId": "uuid",
        "approverName": "John Manager",
        "status": "PENDING"
      }
    ]
  }
}
```

### Business Logic

- Creates leave reservation (pending +, available -)
- Sends notification to approver
- Validates all business rules
- Cannot submit if validation fails

---

## Approve Leave Request

**Endpoint**: `POST /api/v1/ta/leave-requests/{id}/approve`  
**Description**: Approve a pending leave request  
**Authorization**: Manager (approver), HR  
**Related FR**: FR-ABS-021

### Request Body

```json
{
  "comment": "Approved - enjoy your vacation",
  "modifiedDays": null
}
```

### Response (200 OK)

```json
{
  "data": {
    "id": "uuid",
    "status": "APPROVED",
    "approvedBy": {
      "id": "uuid",
      "name": "John Manager"
    },
    "approvedAt": "2025-12-15T10:05:00Z",
    "approvalComment": "Approved - enjoy your vacation"
  }
}
```

### Business Logic

- Creates leave movement (USAGE, amount: -days)
- Updates balance (used +, pending -)
- Releases reservation
- Creates calendar entries
- Sends notification to employee
- If multi-level: proceeds to next approver

### Error Codes

- `NOT_AUTHORIZED`: User is not the current approver
- `INVALID_STATUS`: Request is not in PENDING status
- `CANNOT_APPROVE_OWN`: Manager cannot approve own request

---

## Reject Leave Request

**Endpoint**: `POST /api/v1/ta/leave-requests/{id}/reject`  
**Description**: Reject a pending leave request  
**Authorization**: Manager (approver), HR  
**Related FR**: FR-ABS-022

### Request Body

```json
{
  "reason": "Insufficient coverage during this period"
}
```

### Response (200 OK)

```json
{
  "data": {
    "id": "uuid",
    "status": "REJECTED",
    "rejectedBy": {
      "id": "uuid",
      "name": "John Manager"
    },
    "rejectedAt": "2025-12-15T10:05:00Z",
    "rejectionReason": "Insufficient coverage during this period"
  }
}
```

### Business Logic

- Updates balance (pending -, available +)
- Releases reservation
- Sends notification to employee with reason

---

## Withdraw Leave Request

**Endpoint**: `POST /api/v1/ta/leave-requests/{id}/withdraw`  
**Description**: Withdraw a pending leave request  
**Authorization**: Employee (owner), HR  
**Related FR**: FR-ABS-004

### Response (200 OK)

```json
{
  "data": {
    "id": "uuid",
    "status": "WITHDRAWN",
    "withdrawnAt": "2025-12-15T10:05:00Z"
  }
}
```

### Business Logic

- Can only withdraw PENDING requests
- Releases reservation
- Restores available balance
- Sends notification to manager

---

## Get Leave Request

**Endpoint**: `GET /api/v1/ta/leave-requests/{id}`  
**Description**: Get leave request details  
**Authorization**: Employee (owner), Manager, HR

### Response (200 OK)

```json
{
  "data": {
    "id": "uuid",
    "employeeId": "uuid",
    "employeeName": "Jane Doe",
    "leaveTypeId": "uuid",
    "leaveTypeName": "Annual Leave",
    "startDate": "2025-12-20",
    "endDate": "2025-12-22",
    "totalDays": 3.0,
    "workingDays": 3.0,
    "halfDay": false,
    "status": "APPROVED",
    "reason": "Family vacation",
    "balanceSnapshot": {
      "before": 15.0,
      "after": 12.0
    },
    "approvalHistory": [
      {
        "level": 1,
        "approverId": "uuid",
        "approverName": "John Manager",
        "action": "APPROVED",
        "comment": "Approved",
        "timestamp": "2025-12-15T10:05:00Z"
      }
    ],
    "createdAt": "2025-12-15T10:00:00Z",
    "updatedAt": "2025-12-15T10:05:00Z"
  }
}
```

---

## List Leave Requests

**Endpoint**: `GET /api/v1/ta/leave-requests`  
**Description**: List leave requests with filters  
**Authorization**: Employee (own), Manager (team), HR (all)

### Query Parameters

- `employeeId` (uuid): Filter by employee
- `leaveTypeId` (uuid): Filter by leave type
- `status` (enum): DRAFT, PENDING, APPROVED, REJECTED, WITHDRAWN, CANCELLED
- `startDate` (date): Filter by start date >= value
- `endDate` (date): Filter by end date <= value
- `page` (int): Page number (default: 1)
- `pageSize` (int): Items per page (default: 20, max: 100)
- `sort` (string): Sort field and direction (e.g., `createdAt:desc`)

### Response (200 OK)

```json
{
  "data": [
    {
      "id": "uuid",
      "employeeId": "uuid",
      "employeeName": "Jane Doe",
      "leaveTypeName": "Annual Leave",
      "startDate": "2025-12-20",
      "endDate": "2025-12-22",
      "workingDays": 3.0,
      "status": "APPROVED",
      "createdAt": "2025-12-15T10:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "pageSize": 20,
    "totalItems": 45,
    "totalPages": 3
  }
}
```

---

## Get Leave Balance

**Endpoint**: `GET /api/v1/ta/leave-balances`  
**Description**: Get employee leave balances  
**Authorization**: Employee (own), Manager (team), HR (all)  
**Related FR**: FR-ABS-041

### Query Parameters

- `employeeId` (uuid): Employee ID (required for Manager/HR)
- `leaveTypeId` (uuid): Optional filter by leave type
- `asOfDate` (date): Balance as of date (default: today)

### Response (200 OK)

```json
{
  "data": [
    {
      "leaveTypeId": "uuid",
      "leaveTypeName": "Annual Leave",
      "leaveYear": "2025",
      "totalAllocated": 20.0,
      "used": 5.0,
      "pending": 3.0,
      "available": 12.0,
      "carryover": 0.0,
      "adjusted": 0.0,
      "expired": 0.0,
      "asOfDate": "2025-12-15"
    },
    {
      "leaveTypeId": "uuid",
      "leaveTypeName": "Sick Leave",
      "leaveYear": "2025",
      "totalAllocated": 12.0,
      "used": 2.0,
      "pending": 0.0,
      "available": 10.0,
      "carryover": 0.0,
      "adjusted": 0.0,
      "expired": 0.0,
      "asOfDate": "2025-12-15"
    }
  ]
}
```

---

## Adjust Leave Balance

**Endpoint**: `POST /api/v1/ta/leave-balances/adjust`  
**Description**: Manually adjust employee leave balance  
**Authorization**: HR only  
**Related FR**: FR-ABS-044

### Request Body

```json
{
  "employeeId": "uuid",
  "leaveTypeId": "uuid",
  "amount": 2.5,
  "reason": "Compensation for working on holiday",
  "effectiveDate": "2025-12-15"
}
```

### Response (200 OK)

```json
{
  "data": {
    "movementId": "uuid",
    "employeeId": "uuid",
    "leaveTypeId": "uuid",
    "movementType": "ADJUSTMENT",
    "amount": 2.5,
    "reason": "Compensation for working on holiday",
    "effectiveDate": "2025-12-15",
    "createdBy": "uuid",
    "createdAt": "2025-12-15T10:00:00Z",
    "newBalance": {
      "totalAllocated": 22.5,
      "available": 14.5
    }
  }
}
```

---

## Get Balance Movement History

**Endpoint**: `GET /api/v1/ta/leave-balances/movements`  
**Description**: Get leave balance movement history  
**Authorization**: Employee (own), Manager (team), HR (all)  
**Related FR**: FR-ABS-043

### Query Parameters

- `employeeId` (uuid): Employee ID
- `leaveTypeId` (uuid): Optional filter by leave type
- `movementType` (enum): ALLOCATION, ACCRUAL, USAGE, ADJUSTMENT, CARRYOVER, EXPIRY, PAYOUT, REVERSAL
- `startDate` (date): Filter movements >= date
- `endDate` (date): Filter movements <= date

### Response (200 OK)

```json
{
  "data": [
    {
      "id": "uuid",
      "employeeId": "uuid",
      "leaveTypeId": "uuid",
      "leaveTypeName": "Annual Leave",
      "movementType": "ALLOCATION",
      "amount": 20.0,
      "reason": "Annual allocation for 2025",
      "effectiveDate": "2025-01-01",
      "sourceId": null,
      "sourceType": null,
      "createdBy": "SYSTEM",
      "createdAt": "2025-01-01T00:00:00Z"
    },
    {
      "id": "uuid",
      "employeeId": "uuid",
      "leaveTypeId": "uuid",
      "leaveTypeName": "Annual Leave",
      "movementType": "USAGE",
      "amount": -3.0,
      "reason": "Leave request LR-2025-001",
      "effectiveDate": "2025-12-20",
      "sourceId": "uuid",
      "sourceType": "LeaveRequest",
      "createdBy": "uuid",
      "createdAt": "2025-12-15T10:05:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "pageSize": 20,
    "totalItems": 15
  }
}
```

---

# Attendance APIs

## Clock In

**Endpoint**: `POST /api/v1/ta/attendance/clock-in`  
**Description**: Record employee clock in  
**Authorization**: Employee  
**Related FR**: FR-ATT-041

### Request Body

```json
{
  "timestamp": "2025-12-15T08:02:00Z",
  "method": "BIOMETRIC",
  "deviceId": "DEVICE-001",
  "location": {
    "latitude": 10.7769,
    "longitude": 106.7009
  }
}
```

### Response (200 OK)

```json
{
  "data": {
    "attendanceId": "uuid",
    "employeeId": "uuid",
    "date": "2025-12-15",
    "clockInTime": "2025-12-15T08:02:00Z",
    "clockInMethod": "BIOMETRIC",
    "scheduledShift": {
      "shiftId": "uuid",
      "shiftName": "Day Shift",
      "scheduledStart": "2025-12-15T08:00:00Z",
      "scheduledEnd": "2025-12-15T17:00:00Z"
    },
    "status": "IN_PROGRESS",
    "isLate": false,
    "lateMinutes": 0,
    "message": "Clocked in successfully"
  }
}
```

### Business Logic

- Retrieves roster entry for date
- Applies grace period from shift definition
- Applies rounding rules
- Creates LATE_IN exception if late beyond grace
- Prevents duplicate clock in

### Error Codes

- `ALREADY_CLOCKED_IN`: Employee already clocked in today
- `NO_ROSTER_ENTRY`: No scheduled shift for today
- `INVALID_LOCATION`: GPS location outside allowed radius

---

## Clock Out

**Endpoint**: `POST /api/v1/ta/attendance/clock-out`  
**Description**: Record employee clock out  
**Authorization**: Employee  
**Related FR**: FR-ATT-042

### Request Body

```json
{
  "timestamp": "2025-12-15T17:05:00Z",
  "method": "BIOMETRIC",
  "deviceId": "DEVICE-001",
  "location": {
    "latitude": 10.7769,
    "longitude": 106.7009
  }
}
```

### Response (200 OK)

```json
{
  "data": {
    "attendanceId": "uuid",
    "employeeId": "uuid",
    "date": "2025-12-15",
    "clockInTime": "2025-12-15T08:02:00Z",
    "clockOutTime": "2025-12-15T17:05:00Z",
    "actualHours": 9.05,
    "paidHours": 9.0,
    "breakHours": 1.0,
    "status": "COMPLETED",
    "isEarlyOut": false,
    "hasOvertime": true,
    "overtimeHours": 1.0,
    "message": "Clocked out successfully. 1.0 hour overtime detected."
  }
}
```

### Business Logic

- Validates employee has clocked in
- Calculates actual hours worked
- Deducts break hours
- Creates EARLY_OUT exception if early
- Creates OVERTIME exception if overtime
- Updates status to COMPLETED

---

## Submit Manual Time Entry

**Endpoint**: `POST /api/v1/ta/attendance/manual-entry`  
**Description**: Submit manual time entry for missed clock  
**Authorization**: Employee  
**Related FR**: FR-ATT-048

### Request Body

```json
{
  "date": "2025-12-14",
  "startTime": "2025-12-14T08:00:00Z",
  "endTime": "2025-12-14T17:00:00Z",
  "reason": "Forgot to clock in/out"
}
```

### Response (201 Created)

```json
{
  "data": {
    "attendanceId": "uuid",
    "employeeId": "uuid",
    "date": "2025-12-14",
    "clockInTime": "2025-12-14T08:00:00Z",
    "clockOutTime": "2025-12-14T17:00:00Z",
    "actualHours": 9.0,
    "paidHours": 8.0,
    "status": "PENDING_APPROVAL",
    "isManual": true,
    "reason": "Forgot to clock in/out",
    "message": "Manual entry submitted. Awaiting manager approval."
  }
}
```

---

## Get Attendance Records

**Endpoint**: `GET /api/v1/ta/attendance/records`  
**Description**: Get attendance records  
**Authorization**: Employee (own), Manager (team), HR (all)

### Query Parameters

- `employeeId` (uuid): Employee ID
- `startDate` (date): Filter >= date
- `endDate` (date): Filter <= date
- `status` (enum): IN_PROGRESS, COMPLETED, PENDING_APPROVAL, CANCELLED

### Response (200 OK)

```json
{
  "data": [
    {
      "id": "uuid",
      "employeeId": "uuid",
      "date": "2025-12-15",
      "clockInTime": "2025-12-15T08:02:00Z",
      "clockOutTime": "2025-12-15T17:05:00Z",
      "actualHours": 9.05,
      "paidHours": 9.0,
      "status": "COMPLETED",
      "isManual": false,
      "hasExceptions": true,
      "exceptions": [
        {
          "type": "OVERTIME",
          "severity": "LOW",
          "hours": 1.0
        }
      ]
    }
  ]
}
```

---

# Scheduling APIs

## Get Roster

**Endpoint**: `GET /api/v1/ta/roster`  
**Description**: Get employee roster (schedule)  
**Authorization**: Employee (own), Manager (team), HR (all)  
**Related FR**: FR-ATT-007

### Query Parameters

- `employeeId` (uuid): Employee ID
- `startDate` (date): Start of date range
- `endDate` (date): End of date range

### Response (200 OK)

```json
{
  "data": [
    {
      "date": "2025-12-15",
      "dayType": "WORK",
      "shift": {
        "id": "uuid",
        "code": "DAY_SHIFT",
        "name": "Day Shift",
        "startTime": "08:00",
        "endTime": "17:00",
        "workHours": 8.0,
        "breakHours": 1.0
      },
      "isOverride": false,
      "isHoliday": false,
      "lineage": {
        "scheduleRuleId": "uuid",
        "patternId": "uuid",
        "dayModelId": "uuid",
        "shiftId": "uuid"
      }
    },
    {
      "date": "2025-12-16",
      "dayType": "OFF",
      "shift": null,
      "isOverride": false,
      "isHoliday": false
    }
  ]
}
```

---

## Create Schedule Override

**Endpoint**: `POST /api/v1/ta/roster/overrides`  
**Description**: Override generated roster  
**Authorization**: Manager, HR  
**Related FR**: FR-ATT-121

### Request Body

```json
{
  "employeeId": "uuid",
  "date": "2025-12-16",
  "overrideType": "CHANGE_SHIFT",
  "newShiftId": "uuid",
  "reasonCode": "COVERAGE_NEEDED",
  "comment": "Need coverage for sick colleague"
}
```

### Response (200 OK)

```json
{
  "data": {
    "overrideId": "uuid",
    "employeeId": "uuid",
    "date": "2025-12-16",
    "originalShift": {
      "id": "uuid",
      "name": "Off"
    },
    "newShift": {
      "id": "uuid",
      "name": "Day Shift"
    },
    "reasonCode": "COVERAGE_NEEDED",
    "comment": "Need coverage for sick colleague",
    "createdBy": "uuid",
    "createdAt": "2025-12-15T10:00:00Z"
  }
}
```

---

## Request Shift Swap

**Endpoint**: `POST /api/v1/ta/roster/shift-swap`  
**Description**: Request to swap shifts with another employee  
**Authorization**: Employee  
**Related FR**: FR-ATT-122

### Request Body

```json
{
  "myDate": "2025-12-20",
  "theirEmployeeId": "uuid",
  "theirDate": "2025-12-21",
  "reason": "Personal appointment"
}
```

### Response (201 Created)

```json
{
  "data": {
    "swapRequestId": "uuid",
    "requesterId": "uuid",
    "requesterDate": "2025-12-20",
    "requesterShift": "Day Shift",
    "targetEmployeeId": "uuid",
    "targetDate": "2025-12-21",
    "targetShift": "Day Shift",
    "status": "PENDING_PEER",
    "reason": "Personal appointment",
    "createdAt": "2025-12-15T10:00:00Z"
  }
}
```

---

# Timesheet APIs

## Get Timesheet

**Endpoint**: `GET /api/v1/ta/timesheets/{id}`  
**Description**: Get timesheet details  
**Authorization**: Employee (owner), Manager, HR  
**Related FR**: FR-ATT-085

### Response (200 OK)

```json
{
  "data": {
    "id": "uuid",
    "employeeId": "uuid",
    "employeeName": "Jane Doe",
    "payPeriod": {
      "startDate": "2025-12-01",
      "endDate": "2025-12-15",
      "code": "2025-P24"
    },
    "status": "SUBMITTED",
    "summary": {
      "totalWorked": 120.0,
      "totalPaid": 118.0,
      "regularHours": 110.0,
      "overtimeHours": 8.0,
      "leaveHours": 0.0
    },
    "dailyRecords": [
      {
        "date": "2025-12-01",
        "shift": "Day Shift",
        "clockIn": "08:02",
        "clockOut": "17:05",
        "worked": 9.05,
        "paid": 9.0,
        "exceptions": []
      }
    ],
    "exceptions": [
      {
        "type": "OVERTIME",
        "count": 2,
        "totalHours": 8.0,
        "status": "RESOLVED"
      }
    ],
    "submittedAt": "2025-12-16T10:00:00Z",
    "submittedBy": "uuid"
  }
}
```

---

## Submit Timesheet

**Endpoint**: `POST /api/v1/ta/timesheets/{id}/submit`  
**Description**: Submit timesheet for approval  
**Authorization**: Employee (owner)  
**Related FR**: FR-ATT-082

### Response (200 OK)

```json
{
  "data": {
    "id": "uuid",
    "status": "SUBMITTED",
    "submittedAt": "2025-12-16T10:00:00Z",
    "approver": {
      "id": "uuid",
      "name": "John Manager"
    }
  }
}
```

---

## Approve Timesheet

**Endpoint**: `POST /api/v1/ta/timesheets/{id}/approve`  
**Description**: Approve submitted timesheet  
**Authorization**: Manager, HR  
**Related FR**: FR-ATT-083

### Request Body

```json
{
  "comment": "Approved"
}
```

### Response (200 OK)

```json
{
  "data": {
    "id": "uuid",
    "status": "APPROVED",
    "approvedBy": {
      "id": "uuid",
      "name": "John Manager"
    },
    "approvedAt": "2025-12-16T11:00:00Z",
    "comment": "Approved"
  }
}
```

---

# Overtime APIs

## Request Overtime

**Endpoint**: `POST /api/v1/ta/overtime/requests`  
**Description**: Request overtime approval  
**Authorization**: Employee  
**Related FR**: FR-ATT-101

### Request Body

```json
{
  "date": "2025-12-20",
  "expectedHours": 3.0,
  "reason": "Project deadline"
}
```

### Response (201 Created)

```json
{
  "data": {
    "id": "uuid",
    "employeeId": "uuid",
    "date": "2025-12-20",
    "expectedHours": 3.0,
    "reason": "Project deadline",
    "status": "PENDING",
    "createdAt": "2025-12-15T10:00:00Z"
  }
}
```

---

## Approve Overtime Request

**Endpoint**: `POST /api/v1/ta/overtime/requests/{id}/approve`  
**Description**: Approve overtime request  
**Authorization**: Manager, HR  
**Related FR**: FR-ATT-102

### Response (200 OK)

```json
{
  "data": {
    "id": "uuid",
    "status": "APPROVED",
    "approvedBy": {
      "id": "uuid",
      "name": "John Manager"
    },
    "approvedAt": "2025-12-15T10:05:00Z"
  }
}
```

---

# Shared APIs

## Get Holiday Calendar

**Endpoint**: `GET /api/v1/ta/holidays`  
**Description**: Get holiday calendar  
**Authorization**: All authenticated users  
**Related FR**: FR-SHR-021

### Query Parameters

- `country` (string): Country code (e.g., VN, US)
- `year` (int): Year
- `calendarId` (uuid): Specific calendar ID

### Response (200 OK)

```json
{
  "data": {
    "calendarId": "uuid",
    "country": "VN",
    "year": 2025,
    "holidays": [
      {
        "date": "2025-01-01",
        "name": "New Year's Day",
        "class": "CLASS_A",
        "isMultiDay": false
      },
      {
        "date": "2025-02-10",
        "name": "Tết (Lunar New Year)",
        "class": "CLASS_A",
        "isMultiDay": true,
        "endDate": "2025-02-14",
        "totalDays": 5
      }
    ]
  }
}
```

---

# Common Patterns

## Bulk Operations

Some endpoints support bulk operations:

**Example**: Bulk approve leave requests

```
POST /api/v1/ta/leave-requests/bulk-approve
```

Request:
```json
{
  "requestIds": ["uuid1", "uuid2", "uuid3"],
  "comment": "Batch approval"
}
```

Response:
```json
{
  "data": {
    "successful": ["uuid1", "uuid2"],
    "failed": [
      {
        "requestId": "uuid3",
        "error": "INVALID_STATUS"
      }
    ]
  }
}
```

---

## Webhooks

The system can send webhooks for events:

**Webhook Payload**:
```json
{
  "eventType": "leave.request.approved",
  "eventId": "uuid",
  "timestamp": "2025-12-15T10:05:00Z",
  "tenantId": "uuid",
  "data": {
    "requestId": "uuid",
    "employeeId": "uuid",
    "approvedBy": "uuid"
  }
}
```

**Event Types**:
- `leave.request.created`
- `leave.request.submitted`
- `leave.request.approved`
- `leave.request.rejected`
- `attendance.clocked_in`
- `attendance.clocked_out`
- `timesheet.submitted`
- `timesheet.approved`

---

# Error Codes

## Leave Management Errors

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `LEAVE_TYPE_NOT_FOUND` | 404 | Leave type does not exist |
| `INSUFFICIENT_BALANCE` | 400 | Not enough leave balance |
| `OVERLAPPING_REQUEST` | 409 | Dates overlap with existing request |
| `NOT_ELIGIBLE` | 403 | Employee not eligible for leave type |
| `BLACKOUT_PERIOD` | 400 | Dates fall within blackout period |
| `ADVANCE_NOTICE_REQUIRED` | 400 | Request does not meet advance notice requirement |
| `MAX_CONSECUTIVE_DAYS` | 400 | Exceeds maximum consecutive days |
| `INVALID_STATUS` | 400 | Request is not in expected status |
| `NOT_AUTHORIZED` | 403 | User not authorized for this action |

## Attendance Errors

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `ALREADY_CLOCKED_IN` | 409 | Employee already clocked in |
| `NOT_CLOCKED_IN` | 400 | Employee has not clocked in |
| `NO_ROSTER_ENTRY` | 404 | No scheduled shift for date |
| `INVALID_LOCATION` | 400 | GPS location outside allowed radius |
| `DEVICE_NOT_FOUND` | 404 | Clock device not found |
| `BIOMETRIC_FAILED` | 401 | Biometric validation failed |

## Timesheet Errors

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `TIMESHEET_NOT_FOUND` | 404 | Timesheet does not exist |
| `UNRESOLVED_EXCEPTIONS` | 400 | Timesheet has unresolved exceptions |
| `DEADLINE_PASSED` | 400 | Submission deadline has passed |
| `ALREADY_APPROVED` | 409 | Timesheet already approved |
| `ALREADY_PAID` | 409 | Timesheet already paid (locked) |

## Common Errors

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `UNAUTHORIZED` | 401 | Invalid or missing authentication token |
| `FORBIDDEN` | 403 | User lacks required permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `VALIDATION_ERROR` | 400 | Request validation failed |
| `CONFLICT` | 409 | Resource conflict |
| `INTERNAL_ERROR` | 500 | Internal server error |
| `SERVICE_UNAVAILABLE` | 503 | Service temporarily unavailable |

---

## Document Status

**Status**: Complete - All major API endpoints documented  
**Coverage**: 
- ✅ Leave Management APIs (8 endpoints)
- ✅ Attendance APIs (4 endpoints)
- ✅ Scheduling APIs (3 endpoints)
- ✅ Timesheet APIs (3 endpoints)
- ✅ Overtime APIs (2 endpoints)
- ✅ Shared APIs (1 endpoint)

**Total Endpoints**: 21 core endpoints + bulk operations + webhooks

**Last Updated**: 2025-12-15  
**Next Steps**: Review and validate with backend team
