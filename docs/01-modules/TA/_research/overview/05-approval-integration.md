# TA Module — Approval Workflows & Tích hợp Hệ thống

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-05  
**Đối tượng**: HR Administrator, System Configurator, Developer

---

## Tổng quan

TA Module vận hành dựa trên hai nền tảng:
1. **Approval Workflows** — cấu hình quy trình phê duyệt linh hoạt cho leave requests, timesheets, overtime, và shift swaps
2. **Event-Driven Integration** — mọi sự kiện quan trọng đều được publish, cho phép các module và hệ thống khác subscribe và xử lý tự động

---

## Approval Workflow Architecture

### 5 Loại Approval Chain

| Chain Type | Mô tả | Khi dùng |
|-----------|-------|---------|
| **Single** | 1 approver duy nhất | Nghỉ phép thông thường |
| **Two-Level** | Manager → Department Head | Leave > 5 ngày |
| **Three-Level** | Manager → Dept Head → HR Director | Nghỉ đặc biệt, nghỉ không lương dài |
| **Conditional** | Route khác nhau dựa trên điều kiện | Tùy loại leave, duration, employee grade |
| **Parallel** | 2+ approvers cùng lúc, cần all approve | Cross-team project time allocation |

### Routing Logic

```
Leave Request created
        │
    Evaluate conditions:
    ├── Duration > 5 days?       → Two-Level
    ├── Leave type = UNPAID?      → Three-Level
    ├── Employee grade ≥ Manager? → Parallel (peer + HR)
    └── Default                  → Single (direct manager)
```

### Auto-Approval Rules

Một số cases có thể được cấu hình để tự động approve:

```yaml
AutoApprovalRule:
  conditions:
    - leaveType: SICK_LEAVE
    - duration: <= 1 day
    - balance: sufficient
  action: APPROVE
  reason: "Short sick leave auto-approved per company policy"
```

---

## Event System

### 7 Event Types

| Event | Trigger | Consumers |
|-------|---------|----------|
| `LEAVE_REQUEST_SUBMITTED` | Nhân viên submit request | Approver notification |
| `LEAVE_REQUEST_APPROVED` | Manager approve | Employee notification, Calendar sync, Balance update |
| `LEAVE_REQUEST_REJECTED` | Manager reject | Employee notification, Balance restore |
| `TIMESHEET_SUBMITTED` | Employee submit timesheet | Manager notification |
| `TIMESHEET_APPROVED` | Manager approve | Payroll data feed |
| `ROSTER_GENERATED` | System generates roster | Employee notification, Calendar publish |
| `ATTENDANCE_EXCEPTION` | Exception detected | Manager notification, HR escalation |

### Event Processing

```
TA Module Event Bus
        │
        ├──[ LEAVE_REQUEST_APPROVED ]──────────────────────────────────┐
        │                                                              │
        │   Subscriber 1: Email/Push Service                           │
        │   → Send "Your leave is approved" to employee                │
        │                                                              │
        │   Subscriber 2: Calendar Integration                         │
        │   → Create Out-of-Office event in Google/Outlook             │
        │                                                              │
        │   Subscriber 3: PR Module                                    │
        │   → Flag unpaid leave for payroll deduction                  │
        │                                                              │
        └── Event logged in audit trail                                │
                                                                       ↓
        ├──[ TIMESHEET_APPROVED ]──────────────→ PR Module
        │                                       → Process wages + OT
        │
        └──[ ROSTER_GENERATED ]────────────────→ Employee Portal
                                               → Mobile App push notifications
```

### Trigger Types

| Trigger | Ví dụ |
|---------|-------|
| **Event-Based** | Khi leave được approved → gửi notification |
| **Schedule-Based** | Cuối tháng → chạy accrual cho tất cả employees |
| **Condition-Based** | Balance < 3 ngày → cảnh báo employee |

---

## Notification Configuration

### Channels

| Channel | Phù hợp với | Cấu hình |
|---------|------------|---------|
| **Email** | Desktop workers | Template HTML, CC/BCC, attachments |
| **SMS** | Field workers, shift workers | Short message, urgent alerts |
| **Push (Mobile)** | Mobile app users | Rich notification, deep-link |
| **In-App** | Web portal users | Badge count, notification center |

### Notification Templates (Ví dụ)

```
[LEAVE_APPROVED] to Employee:
  Subject: "Your leave request has been approved"
  Body: "Dear {employee.name},
         Your {leave.type} from {start_date} to {end_date} ({days} days)
         has been approved by {approver.name}.
         Remaining balance: {balance.available} days."

[ATTENDANCE_EXCEPTION] to Manager:
  Subject: "Attendance Exception: {employee.name}"
  Body: "Employee {name} was {exception.type} by {minutes} minutes
         on {date}. Please review in the attendance dashboard."
```

---

## Integration Architecture

### CO Module (Core HR) — Upstream

TA nhận dữ liệu từ CO:

```
CO Module ──→ TA Module
  Worker           → Employee identity for attendance
  Assignment       → Current position, work location
  Org Hierarchy    → Approval routing (who approves whom)
  EligibilityProfile → Leave type eligibility conditions
```

### Payroll (PR) — Downstream

TA gửi dữ liệu cho Payroll:

```
TA Module ──→ PR Module
  LeaveMovement (USAGE)  → Unpaid leave deduction
  AttendanceRecord       → Actual hours worked per period
  OvertimeCalculation    → OT hours + applicable multipliers
  TimesheetEntry         → Classified hours (billable, project)

Timing: Triggered at period close or on-demand
```

### Total Rewards (TR) — Downstream

```
TA Module ──→ TR Module
  OvertimeCalculation    → Base data for OT compensation
  ShiftDifferential      → Night/weekend shift premiums
  HolidayWork            → Holiday pay eligibility
```

### Time Clock Devices — Upstream

```
Time Clock Hardware/Software──→ TA Module (real-time)
  Clock Event (Type: IN/OUT)
  Timestamp
  Employee ID
  Device ID
  Location (if GPS)

Protocol: REST API push or message queue
Frequency: Real-time (< 5 second delay)
Error handling: Retry queue, manual correction UI
```

### Calendar Systems — Downstream

```
TA Module ──→ Google Calendar / Microsoft Outlook
  Approved Leave           → Out-of-Office event
  Generated Roster         → Shift events
  Holiday Calendar         → Public holiday events

Protocol: CalDAV / Google Calendar API / Outlook REST API
Sync: One-way (TA → Calendar, not the other way)
```

### Mobile Apps — Bidirectional

```
Mobile App ←→ TA Module
  [From App] Clock In/Out events
  [From App] Leave requests
  [From App] Timesheet submissions
  [From App] Shift swap requests

  [To App] Roster schedule
  [To App] Leave balance
  [To App] Approval notifications
  [To App] Attendance exceptions
```

---

## Security & Access Control

### Access Matrix

| Role | Leave Requests | Timesheets | Attendance | Roster | Config |
|------|:-:|:-:|:-:|:-:|:-:|
| Employee | Own only | Own only | Own view | Own view | ❌ |
| Manager | Team | Team | Team | Team | ❌ |
| HR Admin | All | All | All | All | ✅ |
| System | — | — | Write-only | Generate | Internal |

### Audit Trail

Mọi action trong TA đều tạo audit log:
```
AuditEntry:
  timestamp: 2025-03-01T08:15:00Z
  actor: "manager.nguyen"
  action: "APPROVE_LEAVE_REQUEST"
  target: "leave-request-12345"
  previousState: {status: "PENDING"}
  newState: {status: "APPROVED"}
  reason: "Approved for annual leave"
  ipAddress: "192.168.1.100"
```

---

## Troubleshooting Integration Issues

| Triệu chứng | Nguyên nhân có thể | Kiểm tra |
|-------------|-------------------|---------|
| Approval notification không gửi | Email service down / template lỗi | Check notification queue |
| Leave balance không cập nhật | Event processing failed | Check LeaveMovement ledger |
| Calendar không sync | OAuth token expired | Reauthorize calendar integration |
| Clock event không nhận | Network issue / device offline | Check device connection, retry queue |
| Payroll thiếu OT data | Timesheet chưa approved | Verify timesheet approval status |

---

*Nguồn: tổng hợp từ `07-approval-workflows-guide.md` và `09-integration-patterns-guide.md`*  
*← [04 Attendance](./04-attendance-timesheet.md) · [06 Period & Calendar →](./06-period-calendar-config.md)*
