# Absence Module API Intent

## Overview

This document describes the canonical API design intent for the Absence Module, following RESTful principles and the ODDS v1 standard for API documentation.

## API Design Principles

### Canonical Resources

The Absence Module exposes the following canonical resources:

| Resource | Path | Description |
|----------|------|-------------|
| LeaveType | `/leave-types` | Leave type definitions |
| LeaveClass | `/leave-classes` | Operational leave variants |
| LeavePolicy | `/leave-policies` | Reusable policy definitions |
| LeaveInstant | `/leave-instants` | Employee leave accounts |
| LeaveInstantDetail | `/leave-instants/{id}/details` | Grant lots |
| LeaveMovement | `/leave-movements` | Balance transactions |
| LeaveRequest | `/leave-requests` | Leave requests |
| LeaveReservation | `/leave-reservations` | Quota reservations |
| LeavePeriod | `/leave-periods` | Leave periods |
| LeaveEventDef | `/leave-event-definitions` | Event type definitions |
| LeaveEventRun | `/leave-event-runs` | Event execution records |
| LeaveBalanceHistory | `/leave-instants/{id}/balance-history` | Daily snapshots |
| LeaveWallet | `/leave-wallets` | Aggregated balance view |
| HolidayCalendar | `/holiday-calendars` | Holiday definitions |
| TeamLeaveLimit | `/team-leave-limits` | Team staffing limits |

### Standard Operations

Each resource supports standard CRUD operations where applicable:

| Operation | Method | Path | Success Response |
|-----------|--------|------|------------------|
| List | GET | `/resources` | 200 OK (array) |
| Get | GET | `/resources/{id}` | 200 OK (object) |
| Create | POST | `/resources` | 201 Created |
| Update | PUT | `/resources/{id}` | 200 OK |
| Patch | PATCH | `/resources/{id}` | 200 OK |
| Delete | DELETE | `/resources/{id}` | 204 No Content |

---

## Resource APIs

### Leave Types API

#### List Leave Types

```http
GET /api/v1/leave-types
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `is_active` | boolean | Filter by active status |
| `unit_code` | string | Filter by unit (DAY/HOUR) |
| `search` | string | Search by code or name |

**Response:**

```json
{
  "data": [
    {
      "id": "lt_001",
      "code": "ANL",
      "name": "Annual Leave",
      "is_paid": true,
      "is_quota_based": true,
      "unit_code": "DAY",
      "is_active": true,
      "created_at": "2025-01-01T00:00:00Z"
    }
  ],
  "meta": {
    "total": 10,
    "page": 1,
    "per_page": 20
  }
}
```

#### Get Leave Type

```http
GET /api/v1/leave-types/{id}
```

**Response:**

```json
{
  "data": {
    "id": "lt_001",
    "code": "ANL",
    "name": "Annual Leave",
    "description": "Paid annual leave",
    "is_paid": true,
    "is_quota_based": true,
    "requires_approval": true,
    "unit_code": "DAY",
    "core_min_unit": 0.5,
    "holiday_handling": "EXCLUDE_HOLIDAYS",
    "overlap_policy": "DENY",
    "support_scope": "VN:LE,SG:BU",
    "metadata": {
      "encashable": true,
      "color": "#3B82F6"
    },
    "is_active": true,
    "effective_start": "2025-01-01",
    "effective_end": null,
    "created_at": "2025-01-01T00:00:00Z",
    "updated_at": "2025-01-01T00:00:00Z"
  }
}
```

---

### Leave Classes API

#### List Leave Classes

```http
GET /api/v1/leave-classes
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `leave_type_id` | string | Filter by leave type |
| `mode_code` | string | Filter by mode (ACCOUNT/LIMIT) |
| `country_code` | string | Filter by country |
| `status_code` | string | Filter by status |

**Response:**

```json
{
  "data": [
    {
      "id": "lc_001",
      "leave_type_id": "lt_001",
      "code": "ANL_VN_FT",
      "name": "Annual Leave Vietnam Full-time",
      "mode_code": "ACCOUNT",
      "unit_code": "DAY",
      "status_code": "ACTIVE",
      "country_code": "VN"
    }
  ]
}
```

#### Get Leave Class

```http
GET /api/v1/leave-classes/{id}
```

**Response:**

```json
{
  "data": {
    "id": "lc_001",
    "leave_type_id": "lt_001",
    "code": "ANL_VN_FT",
    "name": "Annual Leave Vietnam Full-time",
    "status_code": "ACTIVE",
    "mode_code": "ACCOUNT",
    "unit_code": "DAY",
    "period_profile": {
      "type": "CALENDAR_YEAR",
      "closeBehaviors": ["CARRY_FORWARD", "EXPIRE"],
      "carryCap": 10,
      "expireMonths": 3
    },
    "posting_map": [
      {
        "event": "ACCRUAL",
        "qtyFormula": "+fixedRate",
        "target": "INSTANT"
      },
      {
        "event": "START_POST",
        "qtyFormula": "-requestedQty",
        "target": "INSTANT"
      }
    ],
    "eligibility_json": {
      "gradeIn": ["G10", "G11", "G12"],
      "countryIn": ["VN"]
    },
    "rules_json": {
      "accrual": {
        "freq": "MONTH",
        "hours": 1.75
      },
      "carry": {
        "maxCarry": 10,
        "expireMonths": 3
      }
    },
    "bu_id": null,
    "le_id": null,
    "country_code": "VN",
    "effective_start": "2025-01-01",
    "effective_end": null,
    "metadata": {}
  }
}
```

---

### Leave Requests API

#### List Leave Requests

```http
GET /api/v1/leave-requests
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `employee_id` | string | Filter by employee |
| `class_id` | string | Filter by leave class |
| `status_code` | string | Filter by status |
| `start_date` | date | Filter by start date (gte) |
| `end_date` | date | Filter by end date (lte) |

**Response:**

```json
{
  "data": [
    {
      "id": "lr_001",
      "employee_id": "emp_001",
      "class_id": "lc_001",
      "start_dt": "2025-04-15T08:00:00Z",
      "end_dt": "2025-04-16T17:00:00Z",
      "qty_hours_req": 16.0,
      "status_code": "APPROVED",
      "created_at": "2025-04-10T10:00:00Z"
    }
  ]
}
```

#### Create Leave Request

```http
POST /api/v1/leave-requests
```

**Request Body:**

```json
{
  "data": {
    "employee_id": "emp_001",
    "class_id": "lc_001",
    "start_dt": "2025-04-15T08:00:00Z",
    "end_dt": "2025-04-16T17:00:00Z",
    "reason": "Family vacation",
    "metadata": {
      "attachment_urls": ["https://storage/doc.pdf"]
    }
  }
}
```

**Response:**

```json
{
  "data": {
    "id": "lr_001",
    "employee_id": "emp_001",
    "class_id": "lc_001",
    "instant_id": "li_001",
    "start_dt": "2025-04-15T08:00:00Z",
    "end_dt": "2025-04-16T17:00:00Z",
    "qty_hours_req": 16.0,
    "status_code": "SUBMITTED",
    "reason": "Family vacation",
    "workflow_state": {
      "currentStep": 1,
      "totalSteps": 2,
      "approvers": [
        {
          "step": 1,
          "userId": "mgr_001",
          "status": "PENDING"
        }
      ]
    },
    "created_at": "2025-04-10T10:00:00Z"
  }
}
```

#### Approve Leave Request

```http
POST /api/v1/leave-requests/{id}/approve
```

**Request Body:**

```json
{
  "data": {
    "comment": "Approved - project deadline cleared"
  }
}
```

**Response:**

```json
{
  "data": {
    "id": "lr_001",
    "status_code": "APPROVED",
    "approved_at": "2025-04-11T09:00:00Z",
    "approved_by": "mgr_001"
  }
}
```

#### Reject Leave Request

```http
POST /api/v1/leave-requests/{id}/reject
```

**Request Body:**

```json
{
  "data": {
    "reason": "Project deadline conflict"
  }
}
```

**Response:**

```json
{
  "data": {
    "id": "lr_001",
    "status_code": "REJECTED",
    "rejected_at": "2025-04-11T09:00:00Z",
    "rejected_by": "mgr_001",
    "rejection_reason": "Project deadline conflict"
  }
}
```

#### Cancel Leave Request

```http
POST /api/v1/leave-requests/{id}/cancel
```

**Response:**

```json
{
  "data": {
    "id": "lr_001",
    "status_code": "CANCELLED",
    "cancelled_at": "2025-04-14T10:00:00Z",
    "reservation_released": true
  }
}
```

---

### Leave Instants API

#### List Leave Instants

```http
GET /api/v1/leave-instants
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `employee_id` | string | Filter by employee |
| `class_id` | string | Filter by leave class |
| `state_code` | string | Filter by state |

**Response:**

```json
{
  "data": [
    {
      "id": "li_001",
      "employee_id": "emp_001",
      "class_id": "lc_001",
      "state_code": "ACTIVE",
      "current_qty": 96.0,
      "hold_qty": 8.0,
      "available_qty": 88.0,
      "used_ytd": 16.0
    }
  ]
}
```

#### Get Leave Instant Balance

```http
GET /api/v1/leave-instants/{id}
```

**Response:**

```json
{
  "data": {
    "id": "li_001",
    "employee_id": "emp_001",
    "class_id": "lc_001",
    "state_code": "ACTIVE",
    "current_qty": 96.0,
    "hold_qty": 8.0,
    "available_qty": 88.0,
    "limit_yearly": null,
    "limit_monthly": null,
    "used_ytd": 16.0,
    "used_mtd": 8.0,
    "bu_id": "bu_001",
    "le_id": "le_001",
    "country_code": "VN",
    "effective_start": "2025-01-01",
    "effective_end": null,
    "metadata": {
      "details": [
        {
          "id": "lid_001",
          "lot_kind": "GRANT",
          "lot_qty": 96.0,
          "used_qty": 16.0,
          "eff_date": "2025-01-01",
          "expire_date": "2026-03-31",
          "priority": 100
        }
      ]
    }
  }
}
```

#### Get Leave Wallet

```http
GET /api/v1/employees/{employee_id}/leave-wallet
```

**Response:**

```json
{
  "data": {
    "employee_id": "emp_001",
    "wallets": [
      {
        "leave_type_code": "ANL",
        "available_hours": 704.0,
        "balance_hours": 768.0,
        "hold_hours": 64.0,
        "pending_hours": 0.0,
        "overdraft_limit": 320.0,
        "last_calc_at": "2025-04-15T00:00:00Z"
      },
      {
        "leave_type_code": "SL",
        "available_hours": 232.0,
        "balance_hours": 240.0,
        "hold_hours": 0.0,
        "pending_hours": 8.0,
        "overdraft_limit": 0.0,
        "last_calc_at": "2025-04-15T00:00:00Z"
      }
    ]
  }
}
```

---

### Leave Movements API

#### List Leave Movements

```http
GET /api/v1/leave-movements
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `instant_id` | string | Filter by instant |
| `event_code` | string | Filter by event type |
| `start_date` | date | Filter by effective date (gte) |
| `end_date` | date | Filter by effective date (lte) |

**Response:**

```json
{
  "data": [
    {
      "id": "lm_001",
      "instant_id": "li_001",
      "class_id": "lc_001",
      "event_code": "ACCRUAL",
      "qty": 1.75,
      "unit_code": "HOUR",
      "effective_date": "2025-04-01",
      "posted_at": "2025-04-01T00:00:00Z"
    },
    {
      "id": "lm_002",
      "instant_id": "li_001",
      "class_id": "lc_001",
      "event_code": "USED",
      "qty": -8.0,
      "unit_code": "HOUR",
      "effective_date": "2025-04-15",
      "posted_at": "2025-04-15T00:00:00Z",
      "request_id": "lr_001"
    }
  ]
}
```

---

### Leave Periods API

#### Close Period

```http
POST /api/v1/leave-periods/{id}/close
```

**Request Body:**

```json
{
  "data": {
    "force": false
  }
}
```

**Response:**

```json
{
  "data": {
    "id": "lp_001",
    "status_code": "CLOSED",
    "closed_at": "2025-01-05T00:00:00Z",
    "carry_forward_executed": true,
    "movements_created": 150
  }
}
```

#### Lock Period

```http
POST /api/v1/leave-periods/{id}/lock
```

**Response:**

```json
{
  "data": {
    "id": "lp_001",
    "status_code": "LOCKED",
    "locked_at": "2025-01-10T00:00:00Z"
  }
}
```

---

### Event APIs

#### Trigger Event Manually

```http
POST /api/v1/leave-event-definitions/{id}/trigger
```

**Request Body:**

```json
{
  "data": {
    "class_id": "lc_001",
    "period_id": "lp_001",
    "parameters": {}
  }
}
```

**Response:**

```json
{
  "data": {
    "run_id": "ler_001",
    "event_def_id": "led_001",
    "status": "RUNNING",
    "started_at": "2025-04-01T00:00:00Z"
  }
}
```

#### Get Event Run Status

```http
GET /api/v1/leave-event-runs/{id}
```

**Response:**

```json
{
  "data": {
    "id": "ler_001",
    "event_def_id": "led_001",
    "class_id": "lc_001",
    "period_id": "lp_001",
    "run_status": "DONE",
    "started_at": "2025-04-01T00:00:00Z",
    "finished_at": "2025-04-01T00:05:23Z",
    "stats_json": {
      "processed": 500,
      "posted": 485,
      "skipped": 15,
      "failed": 0
    }
  }
}
```

---

## State Transition APIs

### Leave Request Transitions

```http
POST /api/v1/leave-requests/{id}/submit
POST /api/v1/leave-requests/{id}/approve
POST /api/v1/leave-requests/{id}/reject
POST /api/v1/leave-requests/{id}/cancel
POST /api/v1/leave-requests/{id}/withdraw
```

### Leave Instant Transitions

```http
POST /api/v1/leave-instants/{id}/suspend
POST /api/v1/leave-instants/{id}/resume
POST /api/v1/leave-instants/{id}/close
```

---

## Error Handling

### Standard Error Response

```json
{
  "error": {
    "code": "INSUFFICIENT_BALANCE",
    "message": "Insufficient available balance for this request",
    "details": {
      "requested": 16.0,
      "available": 8.0,
      "shortfall": 8.0
    }
  }
}
```

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 204 | No Content |
| 400 | Bad Request (validation error) |
| 404 | Not Found |
| 409 | Conflict (overlap, constraint violation) |
| 422 | Unprocessable Entity (business rule violation) |
| 500 | Internal Server Error |

---

## Rate Limiting

| Endpoint | Limit |
|----------|-------|
| Read (GET) | 100 requests/minute |
| Write (POST/PUT/PATCH/DELETE) | 20 requests/minute |
| Bulk operations | 5 requests/minute |

---

*This document is part of the ODDS v1 documentation standard for the xTalent Absence Module.*
