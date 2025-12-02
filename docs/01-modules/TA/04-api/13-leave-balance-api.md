# Leave Balance API

## Overview

The Leave Balance API provides real-time access to employee leave balances, accrual tracking, and transaction history. Balances are calculated from the ledger-based `LeaveMovement` system.

**Base Path:** `/api/v1/leave-balances`

---

## Endpoints

### Get Leave Balances

Retrieve leave balances for an employee.

```http
GET /api/v1/leave-balances
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `employeeId` | UUID | Yes | Employee identifier |
| `leaveTypeId` | UUID | No | Filter by specific leave type |
| `periodYear` | integer | No | Filter by period year (default: current year) |
| `asOfDate` | date | No | Balance as of specific date (default: today) |

**Example Response:**
```json
{
  "data": [
    {
      "id": "bal_abc123",
      "employeeId": "emp_123456",
      "leaveTypeId": "lt_annual",
      "leaveTypeCode": "ANL",
      "leaveTypeName": "Annual Leave",
      "periodYear": 2025,
      "periodStartDate": "2025-01-01",
      "periodEndDate": "2025-12-31",
      "totalAllocated": 160.0,
      "accrued": 160.0,
      "used": 80.0,
      "pending": 24.0,
      "reserved": 24.0,
      "carriedOver": 0.0,
      "adjusted": 0.0,
      "expired": 0.0,
      "available": 56.0,
      "lastAccrualDate": "2025-12-01",
      "nextAccrualDate": null,
      "metadata": {
        "accrualRate": "Upfront allocation",
        "maxCarryOver": 40.0
      }
    },
    {
      "id": "bal_xyz789",
      "employeeId": "emp_123456",
      "leaveTypeId": "lt_sick",
      "leaveTypeCode": "SL",
      "leaveTypeName": "Sick Leave",
      "periodYear": 2025,
      "totalAllocated": 80.0,
      "accrued": 80.0,
      "used": 16.0,
      "pending": 0.0,
      "available": 64.0
    }
  ]
}
```

---

### Get Balance Details

Get detailed balance information including movements.

```http
GET /api/v1/leave-balances/{balanceId}
```

**Response:**
```json
{
  "data": {
    "id": "bal_abc123",
    "employeeId": "emp_123456",
    "leaveTypeId": "lt_annual",
    "leaveTypeCode": "ANL",
    "periodYear": 2025,
    "totalAllocated": 160.0,
    "used": 80.0,
    "pending": 24.0,
    "available": 56.0,
    "recentMovements": [
      {
        "id": "mov_001",
        "movementType": "ALLOCATION",
        "amount": 160.0,
        "balanceBefore": 0.0,
        "balanceAfter": 160.0,
        "movementDate": "2025-01-01",
        "reason": "Annual allocation"
      },
      {
        "id": "mov_002",
        "movementType": "USAGE",
        "amount": -24.0,
        "balanceBefore": 160.0,
        "balanceAfter": 136.0,
        "movementDate": "2025-03-15",
        "leaveRequestId": "lr_abc123",
        "reason": "Leave request LR-2025-00123"
      }
    ]
  }
}
```

---

### Get Leave Movements

Retrieve transaction history (ledger) for a balance.

```http
GET /api/v1/leave-balances/{balanceId}/movements
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `movementType` | string | No | Filter by type (ALLOCATION, ACCRUAL, USAGE, etc.) |
| `dateFrom` | date | No | Start date |
| `dateTo` | date | No | End date |
| `limit` | integer | No | Page size (default: 50) |

**Example Response:**
```json
{
  "data": [
    {
      "id": "mov_abc123",
      "leaveBalanceId": "bal_abc123",
      "movementType": "ALLOCATION",
      "amount": 160.0,
      "balanceBefore": 0.0,
      "balanceAfter": 160.0,
      "movementDate": "2025-01-01",
      "effectiveDate": "2025-01-01",
      "reason": "Annual allocation for 2025",
      "referenceType": "POLICY",
      "isReversed": false,
      "createdAt": "2025-01-01T00:00:00Z",
      "createdBy": "system"
    },
    {
      "id": "mov_xyz789",
      "leaveBalanceId": "bal_abc123",
      "movementType": "USAGE",
      "amount": -24.0,
      "balanceBefore": 160.0,
      "balanceAfter": 136.0,
      "movementDate": "2025-03-15",
      "effectiveDate": "2025-03-15",
      "leaveRequestId": "lr_abc123",
      "reason": "Leave request LR-2025-00123 approved",
      "referenceType": "LEAVE_REQUEST",
      "isReversed": false,
      "createdAt": "2025-03-10T10:30:00Z",
      "createdBy": "emp_manager01"
    }
  ]
}
```

---

## Movement Types

| Type | Description | Amount |
|------|-------------|--------|
| `ALLOCATION` | Initial allocation for period | Positive |
| `ACCRUAL` | Periodic accrual (monthly, etc.) | Positive |
| `USAGE` | Leave taken (approved request) | Negative |
| `ADJUSTMENT` | Manual adjustment by HR | Positive or Negative |
| `CARRYOVER` | Carried from previous period | Positive |
| `EXPIRY` | Unused balance expired | Negative |
| `PAYOUT` | Balance paid out | Negative |
| `REVERSAL` | Reversal of previous movement | Opposite sign |

---

## Balance Calculation

Balance is calculated from movements:

```
available = totalAllocated + carriedOver + adjusted - used - pending - expired
```

**Where:**
- `totalAllocated`: Initial allocation + accruals
- `carriedOver`: Balance from previous period
- `adjusted`: Manual adjustments (+ or -)
- `used`: Approved leave taken
- `pending`: Leave requests awaiting approval
- `expired`: Unused balance that expired

---

## Accrual Processing

### Run Accrual Batch

Process monthly/periodic accruals for all employees.

```http
POST /api/v1/leave-balances/accrual/run
```

**Request Body:**
```json
{
  "accrualDate": "2025-12-01",
  "leaveTypeIds": ["lt_annual", "lt_sick"],
  "employeeIds": null,
  "dryRun": false
}
```

**Response:**
```json
{
  "data": {
    "accrualDate": "2025-12-01",
    "employeesProcessed": 150,
    "movementsCreated": 300,
    "totalHoursAccrued": 250.5,
    "errors": []
  }
}
```

---

### Carry-Over Processing

Process year-end carry-over.

```http
POST /api/v1/leave-balances/carry-over
```

**Request Body:**
```json
{
  "fromYear": 2025,
  "toYear": 2026,
  "leaveTypeIds": ["lt_annual"],
  "processDate": "2025-12-31"
}
```

---

## Manual Adjustments

### Create Adjustment

Manually adjust an employee's leave balance (HR only).

```http
POST /api/v1/leave-balances/{balanceId}/adjust
```

**Request Body:**
```json
{
  "adjustmentHours": 8.0,
  "reason": "Compensation for working on public holiday",
  "adjustedBy": "emp_hr01"
}
```

**Response:**
```json
{
  "data": {
    "movementId": "mov_new123",
    "movementType": "ADJUSTMENT",
    "amount": 8.0,
    "balanceBefore": 56.0,
    "balanceAfter": 64.0,
    "reason": "Compensation for working on public holiday"
  }
}
```

---

## Use Cases

### Check Employee Balance

```bash
curl -X GET "https://api.xtalent.vng.com/v1/leave-balances?employeeId=emp_123456" \
  -H "Authorization: Bearer {token}"
```

### View Transaction History

```bash
curl -X GET "https://api.xtalent.vng.com/v1/leave-balances/bal_abc123/movements?dateFrom=2025-01-01&dateTo=2025-12-31" \
  -H "Authorization: Bearer {token}"
```

### Manual Adjustment

```bash
curl -X POST https://api.xtalent.vng.com/v1/leave-balances/bal_abc123/adjust \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "adjustmentHours": 8.0,
    "reason": "Compensation for working on public holiday",
    "adjustedBy": "emp_hr01"
  }'
```

---

## Integration with Leave Requests

When a leave request is:

1. **Submitted**: Balance is reserved (creates `LeaveReservation`)
2. **Approved**: Usage movement is created, reservation is released
3. **Rejected**: Reservation is released, no movement created
4. **Cancelled**: Usage movement is reversed

---

## Next Steps

- Submit [Leave Requests](./12-leave-requests-api.md)
- Configure [Leave Types](./10-leave-types-api.md)
- Review [Leave Accrual API](./14-leave-accrual-api.md)
