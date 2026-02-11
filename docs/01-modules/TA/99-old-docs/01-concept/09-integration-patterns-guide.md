# Integration Patterns Guide

**Version**: 1.0  
**Last Updated**: 2025-12-12  
**Audience**: Developers, Integration Specialists, System Architects  
**Reading Time**: 25-30 minutes

---

## 📋 Overview

This guide explains integration patterns for the TA module, covering event-driven architecture, API integration, module dependencies, and external system integration.

### What You'll Learn

- Event-driven architecture patterns
- API integration best practices
- Module dependencies (Core, Payroll, Total Rewards)
- External system integration (time clocks, calendars, HRIS)
- Event patterns and message formats
- API authentication and security
- Troubleshooting integration issues

### Prerequisites

- Understanding of REST APIs and event-driven systems
- Familiarity with [Concept Overview](./01-concept-overview.md)
- Basic knowledge of system integration

---

## 🏗️ Integration Architecture

### Overview

The TA module uses a **hybrid integration approach**:
- **Event-driven**: For real-time notifications and triggers
- **API-based**: For synchronous data exchange
- **Batch**: For bulk data processing

### Architecture Diagram

```
┌─────────────────────────────────────────────────┐
│              TA Module (Time & Absence)          │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │ Absence  │  │   Time   │  │ Approval │     │
│  │Management│  │Attendance│  │ Workflow │     │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘     │
│       │             │              │            │
└───────┼─────────────┼──────────────┼────────────┘
        │             │              │
        ▼             ▼              ▼
┌────────────────────────────────────────────────┐
│           Integration Layer (Events + APIs)     │
└────────────────────────────────────────────────┘
        │             │              │
        ▼             ▼              ▼
┌────────────┐  ┌──────────┐  ┌─────────────┐
│ Core (CO)  │  │Payroll(PR)│  │Total Rewards│
│ Module     │  │  Module   │  │    (TR)     │
└────────────┘  └──────────┘  └─────────────┘
        │             │              │
        ▼             ▼              ▼
┌────────────────────────────────────────────────┐
│        External Systems (Time Clock, HRIS)     │
└────────────────────────────────────────────────┘
```

---

## 🔄 Event-Driven Architecture

### Event Types

| Category | Events | Purpose |
|----------|--------|---------|
| **Leave** | LeaveRequestSubmitted, LeaveApproved, LeaveRejected | Leave workflow |
| **Attendance** | ClockIn, ClockOut, ExceptionDetected | Time tracking |
| **Approval** | ApprovalPending, ApprovalOverdue, ApprovalDelegated | Workflow management |
| **Balance** | BalanceUpdated, BalanceExpired, BalanceCarriedOver | Balance changes |
| **Roster** | RosterGenerated, RosterModified, ShiftSwapped | Schedule changes |

---

### Event Structure

```json
{
  "eventId": "evt_20250115_001",
  "eventType": "LeaveRequestSubmitted",
  "eventVersion": "1.0",
  "timestamp": "2025-01-15T10:30:00Z",
  "source": {
    "module": "TA",
    "subModule": "Absence",
    "component": "LeaveRequest"
  },
  "payload": {
    "requestId": "LR-2025-00123",
    "workerId": "EMP_001",
    "employeeName": "John Doe",
    "leaveType": "Annual Leave",
    "startDate": "2025-01-20",
    "endDate": "2025-01-24",
    "totalDays": 5,
    "reason": "Family vacation",
    "status": "PENDING"
  },
  "metadata": {
    "correlationId": "corr_12345",
    "causationId": "cause_67890",
    "userId": "EMP_001",
    "tenantId": "TENANT_001"
  }
}
```

---

### Event Publishing

**Publisher (TA Module)**:
```javascript
// Publish event when leave request submitted
async function publishLeaveRequestSubmitted(leaveRequest) {
  const event = {
    eventType: "LeaveRequestSubmitted",
    timestamp: new Date().toISOString(),
    source: {
      module: "TA",
      subModule: "Absence"
    },
    payload: {
      requestId: leaveRequest.id,
      workerId: leaveRequest.workerId,
      leaveType: leaveRequest.leaveType.name,
      startDate: leaveRequest.startDate,
      endDate: leaveRequest.endDate,
      totalDays: leaveRequest.totalDays
    }
  };
  
  await eventBus.publish("ta.leave.request.submitted", event);
}
```

---

### Event Subscription

**Subscriber (Payroll Module)**:
```javascript
// Subscribe to leave approved events
eventBus.subscribe("ta.leave.request.approved", async (event) => {
  const { requestId, workerId, startDate, endDate, totalDays } = event.payload;
  
  // Update payroll deductions
  await payrollService.updateLeaveDeduction({
    workerId,
    leaveRequestId: requestId,
    startDate,
    endDate,
    daysToDeduct: totalDays
  });
  
  console.log(`Payroll updated for leave request ${requestId}`);
});
```

---

## 🔌 API Integration Patterns

### REST API Structure

**Base URL**: `https://api.xtalent.com/v1`

**Endpoints**:
```
# Leave Management
GET    /ta/leave-requests
POST   /ta/leave-requests
GET    /ta/leave-requests/{id}
PUT    /ta/leave-requests/{id}
DELETE /ta/leave-requests/{id}
POST   /ta/leave-requests/{id}/approve
POST   /ta/leave-requests/{id}/reject

# Attendance
POST   /ta/attendance/clock-in
POST   /ta/attendance/clock-out
GET    /ta/attendance/records
GET    /ta/attendance/records/{id}

# Roster
GET    /ta/roster
GET    /ta/roster/{workerId}
POST   /ta/roster/generate
```

---

### Authentication

**OAuth 2.0 Client Credentials Flow**:

```javascript
// 1. Obtain access token
const tokenResponse = await fetch('https://auth.xtalent.com/oauth/token', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded'
  },
  body: new URLSearchParams({
    grant_type: 'client_credentials',
    client_id: 'your_client_id',
    client_secret: 'your_client_secret',
    scope: 'ta:read ta:write'
  })
});

const { access_token } = await tokenResponse.json();

// 2. Use access token in API calls
const response = await fetch('https://api.xtalent.com/v1/ta/leave-requests', {
  headers: {
    'Authorization': `Bearer ${access_token}`,
    'Content-Type': 'application/json'
  }
});
```

---

### API Request Example

**Submit Leave Request**:
```javascript
POST /v1/ta/leave-requests
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "workerId": "EMP_001",
  "leaveTypeId": "ANNUAL",
  "startDate": "2025-01-20",
  "endDate": "2025-01-24",
  "totalDays": 5,
  "reason": "Family vacation",
  "attachments": [
    {
      "fileName": "flight_booking.pdf",
      "fileUrl": "https://storage.xtalent.com/attachments/123.pdf"
    }
  ]
}
```

**Response**:
```json
{
  "requestId": "LR-2025-00123",
  "status": "PENDING",
  "workerId": "EMP_001",
  "leaveType": "Annual Leave",
  "startDate": "2025-01-20",
  "endDate": "2025-01-24",
  "totalDays": 5,
  "balanceBefore": 20.0,
  "balanceAfter": 15.0,
  "approvalChain": [
    {
      "level": 1,
      "approverType": "DIRECT_MANAGER",
      "approverId": "MGR_001",
      "status": "PENDING"
    }
  ],
  "createdAt": "2025-01-15T10:30:00Z"
}
```

---

## 🔗 Module Dependencies

### Core Module (CO) Integration

**Dependencies**:
- Worker (Employee) data
- Organization structure
- Job positions
- Business units
- Eligibility profiles

**Integration Points**:

#### 1. Worker Data Sync

```javascript
// TA subscribes to worker events from Core
eventBus.subscribe("co.worker.created", async (event) => {
  const { workerId, hireDate, employmentType } = event.payload;
  
  // Create leave balances for new employee
  await leaveBalanceService.initializeBalances({
    workerId,
    hireDate,
    employmentType
  });
});

eventBus.subscribe("co.worker.terminated", async (event) => {
  const { workerId, terminationDate } = event.payload;
  
  // Process final leave payout
  await leaveBalanceService.processFinalPayout({
    workerId,
    terminationDate
  });
});
```

---

#### 2. Eligibility Profile Integration

```javascript
// Check eligibility using Core module's EligibilityProfile
async function checkLeaveEligibility(workerId, leaveTypeId) {
  // Get eligibility profile from leave type
  const leaveType = await leaveTypeService.getById(leaveTypeId);
  const profileId = leaveType.eligibilityProfileId;
  
  // Call Core module API to check eligibility
  const response = await fetch(
    `https://api.xtalent.com/v1/co/eligibility/check`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        profileId,
        workerId,
        effectiveDate: new Date().toISOString()
      })
    }
  );
  
  const { isEligible, reasons } = await response.json();
  return { isEligible, reasons };
}
```

---

### Payroll Module (PR) Integration

**Dependencies**:
- Leave deductions
- Overtime pay
- Timesheet data

**Integration Points**:

#### 1. Leave Deduction

```javascript
// TA publishes event when leave approved
eventBus.publish("ta.leave.approved", {
  workerId: "EMP_001",
  leaveRequestId: "LR-2025-00123",
  startDate: "2025-01-20",
  endDate: "2025-01-24",
  totalDays: 5,
  isPaid: true
});

// Payroll subscribes and updates deductions
eventBus.subscribe("ta.leave.approved", async (event) => {
  if (!event.payload.isPaid) {
    await payrollService.createDeduction({
      workerId: event.payload.workerId,
      deductionType: "UNPAID_LEAVE",
      amount: calculateLeaveDeduction(event.payload.totalDays),
      effectiveDate: event.payload.startDate
    });
  }
});
```

---

#### 2. Overtime Pay

```javascript
// TA sends timesheet data to Payroll
async function submitTimesheetToPayroll(timesheetId) {
  const timesheet = await timesheetService.getById(timesheetId);
  
  // Calculate overtime
  const overtime = await overtimeService.calculate(timesheetId);
  
  // Send to Payroll
  await fetch('https://api.xtalent.com/v1/pr/overtime', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      workerId: timesheet.workerId,
      periodId: timesheet.periodId,
      regularHours: timesheet.totalWorkedHours - overtime.totalOvertimeHours,
      overtimeHours: overtime.totalOvertimeHours,
      overtimeBreakdown: overtime.breakdown
    })
  });
}
```

---

### Total Rewards Module (TR) Integration

**Dependencies**:
- Leave as benefit
- Attendance bonus
- Recognition for perfect attendance

**Integration Points**:

```javascript
// TA publishes perfect attendance event
eventBus.publish("ta.attendance.perfect_month", {
  workerId: "EMP_001",
  month: "2025-01",
  totalWorkDays: 22,
  attendedDays: 22,
  lateCount: 0,
  absenceCount: 0
});

// TR subscribes and awards bonus
eventBus.subscribe("ta.attendance.perfect_month", async (event) => {
  await rewardsService.awardBonus({
    workerId: event.payload.workerId,
    bonusType: "PERFECT_ATTENDANCE",
    amount: 500000,  // VND
    month: event.payload.month
  });
});
```

---

## 🌐 External System Integration

### Time Clock Integration

**Supported Protocols**:
- REST API
- SOAP Web Services
- TCP/IP Socket
- File-based (CSV/XML)

**Example: Biometric Time Clock**:

```javascript
// Receive clock-in from time clock
app.post('/api/webhook/time-clock/clock-in', async (req, res) => {
  const { deviceId, employeeId, timestamp, biometricData } = req.body;
  
  // Verify biometric
  const isValid = await biometricService.verify(employeeId, biometricData);
  
  if (!isValid) {
    return res.status(401).json({ error: 'Biometric verification failed' });
  }
  
  // Create attendance record
  const attendance = await attendanceService.clockIn({
    workerId: employeeId,
    clockTime: timestamp,
    clockMethod: 'BIOMETRIC',
    deviceId
  });
  
  res.json({ success: true, attendanceId: attendance.id });
});
```

---

### Calendar Sync (Google Calendar, Outlook)

**Example: Sync Leave to Google Calendar**:

```javascript
// When leave approved, add to Google Calendar
eventBus.subscribe("ta.leave.approved", async (event) => {
  const { workerId, startDate, endDate, leaveType } = event.payload;
  
  // Get employee's calendar credentials
  const worker = await workerService.getById(workerId);
  const calendarId = worker.googleCalendarId;
  
  // Create calendar event
  await googleCalendar.events.insert({
    calendarId,
    resource: {
      summary: `${leaveType} Leave`,
      description: 'Approved leave request',
      start: { date: startDate },
      end: { date: endDate },
      colorId: '11'  // Red color for leave
    }
  });
});
```

---

### HRIS Integration

**Example: Sync to External HRIS**:

```javascript
// Batch sync attendance data to HRIS
async function syncAttendanceToHRIS() {
  const yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);
  
  // Get all attendance records from yesterday
  const records = await attendanceService.getByDate(yesterday);
  
  // Transform to HRIS format
  const hrisData = records.map(record => ({
    employee_id: record.workerId,
    date: record.attendanceDate,
    clock_in: record.clockInTime,
    clock_out: record.clockOutTime,
    total_hours: record.totalWorkedHours,
    status: record.status
  }));
  
  // Send to HRIS
  await fetch('https://hris.company.com/api/attendance/bulk', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${hrisAccessToken}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ records: hrisData })
  });
}

// Schedule daily sync
cron.schedule('0 1 * * *', syncAttendanceToHRIS);  // Run at 1 AM daily
```

---

## 🔐 Security Best Practices

### 1. API Authentication

✅ **DO**:
- Use OAuth 2.0 for API authentication
- Rotate access tokens regularly
- Store credentials securely (environment variables, secrets manager)
- Implement rate limiting

❌ **DON'T**:
- Hardcode credentials in code
- Share API keys across systems
- Use basic authentication for production

---

### 2. Event Security

✅ **DO**:
- Validate event signatures
- Encrypt sensitive data in events
- Use secure message queues (TLS)
- Implement idempotency

❌ **DON'T**:
- Send sensitive data in plain text
- Skip event validation
- Process duplicate events

---

### 3. Data Privacy

✅ **DO**:
- Minimize data in events (use IDs, not full objects)
- Implement data masking for logs
- Comply with GDPR/privacy regulations
- Audit all data access

❌ **DON'T**:
- Log sensitive data (passwords, biometrics)
- Share employee data without consent
- Retain data longer than necessary

---

## 🔧 Troubleshooting

### Issue 1: Event Not Received

**Diagnosis**:
```javascript
// Check event bus status
const status = await eventBus.getStatus();
console.log('Event bus connected:', status.connected);

// Check subscription
const subscriptions = await eventBus.getSubscriptions();
console.log('Active subscriptions:', subscriptions);

// Check event logs
const events = await eventBus.getRecentEvents('ta.leave.approved', 10);
console.log('Recent events:', events);
```

**Solution**:
- Verify event bus connection
- Check subscription is active
- Verify event topic name matches
- Check for errors in event processing

---

### Issue 2: API Call Failing

**Diagnosis**:
```javascript
// Enable debug logging
const response = await fetch(apiUrl, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${accessToken}`,
    'Content-Type': 'application/json',
    'X-Debug': 'true'
  },
  body: JSON.stringify(payload)
});

console.log('Status:', response.status);
console.log('Headers:', response.headers);
const body = await response.text();
console.log('Body:', body);
```

**Solution**:
- Check access token is valid
- Verify API endpoint URL
- Check request payload format
- Review API error response

---

### Issue 3: Data Sync Out of Sync

**Diagnosis**:
```sql
-- Check for missing records
SELECT ta.worker_id, ta.attendance_date
FROM ta_attendance_record ta
LEFT JOIN hris_attendance hris 
  ON ta.worker_id = hris.employee_id 
  AND ta.attendance_date = hris.date
WHERE hris.id IS NULL
  AND ta.attendance_date >= CURRENT_DATE - INTERVAL '7 days';
```

**Solution**:
- Run manual sync for missing records
- Check sync job logs for errors
- Verify network connectivity
- Implement retry mechanism

---

## 📚 Related Guides

- [Concept Overview](./01-concept-overview.md) - Module overview
- [Approval Workflows](./07-approval-workflows-guide.md) - Event and trigger system
- [Attendance Tracking](./06-attendance-tracking-guide.md) - Time clock integration
- [Period Profiles](./08-period-profiles-guide.md) - Calendar integration

---

**Document Version**: 1.0  
**Created**: 2025-12-12  
**Last Review**: 2025-12-12  
**Author**: xTalent Documentation Team
