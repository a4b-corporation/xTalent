# xTalent Time & Absence (TA) — Tổng quan Capabilities

**Phiên bản**: 1.0  
**Cập nhật**: 2026-03-05  
**Module**: Time & Absence (TA)

---

## Giới thiệu

**Time & Absence (TA)** là module quản lý toàn bộ vòng đời thời gian làm việc và nghỉ phép của nhân viên trong xTalent HCM. Module này kết hợp hai sub-module bổ trợ nhau:

- **Absence Management** — Quản lý nghỉ phép: cấu hình policy, balance tracking, approval workflow
- **Time & Attendance** — Chấm công & thời gian: lập lịch ca, ghi nhận giờ làm, tính overtime

TA không hoạt động độc lập — nó nhận dữ liệu nền tảng từ **CO (Core HR)** và cung cấp dữ liệu thời gian cho **Payroll (PR)** và **Total Rewards (TR)**.

---

## Kiến trúc tổng thể

```
┌──────────────────────────────────────────────────────────────────┐
│                      TA MODULE                                   │
│                                                                   │
│  ┌─────────────────────────┐  ┌──────────────────────────────┐   │
│  │   ABSENCE MANAGEMENT    │  │   TIME & ATTENDANCE          │   │
│  │                         │  │                              │   │
│  │  LeaveClass             │  │  TimeSegment (L1)            │   │
│  │  LeaveType              │  │  ShiftDefinition (L2)        │   │
│  │  LeaveRule (8 types)    │  │  DayModel (L3)               │   │
│  │  LeaveRequest           │  │  PatternTemplate (L4)        │   │
│  │  LeaveBalance           │  │  WorkScheduleRule (L5)       │   │
│  │  LeaveMovement (ledger) │  │  GeneratedRoster (L6)        │   │
│  │  LeaveReservation       │  │  AttendanceRecord            │   │
│  │                         │  │  TimesheetEntry              │   │
│  └─────────────────────────┘  │  TimeException               │   │
│                               │  OvertimeCalculation         │   │
│  ┌─────────────────────────────────────────────────────────┐  │   │
│  │            SHARED FOUNDATION                            │  │   │
│  │   PeriodProfile · Holiday · WorkingSchedule · Events   │  │   │
│  └─────────────────────────────────────────────────────────┘  │   │
│                               └──────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
          ↑                              ↓                ↓
    CO Module                      PR (Payroll)     TR (Total Rewards)
  (Worker, Org,                  (Leave data,      (Overtime, Shift
   Eligibility)                  Time data,         Differential)
                                  Overtime)
```

---

## Bộ tài liệu này

| Tài liệu | Nội dung | Đối tượng | Đọc ~phút |
|---------|----------|-----------|-----------:|
| **[01 · Executive Summary](./01-executive-summary.md)** | Tầm nhìn, pain points, business value, market alignment | Business, CXO | 10 |
| **[02 · Quản lý Nghỉ phép](./02-absence-management.md)** | Leave policy 3-level, immutable ledger, 8 rule types, balance lifecycle | Business, HR Admin | 20 |
| **[03 · Kiến trúc Lịch làm việc](./03-shift-scheduling-architecture.md)** | 6-Level hierarchical model, roster generation, shift patterns | HR Admin, Workforce Planner | 20 |
| **[04 · Chấm công & Timesheet](./04-attendance-timesheet.md)** | Clock events, exceptions, overtime, shift swap | Manager, HR, Employee | 20 |
| **[05 · Approval & Tích hợp](./05-approval-integration.md)** | Approval chains, event system, integration với CO/PR/TR | HR Admin, Developer | 15 |
| **[06 · Period & Holiday Config](./06-period-calendar-config.md)** | Period types, holiday calendar, working schedule | HR Admin, System Config | 15 |

**Tổng thời gian đọc toàn bộ**: ~100 phút

---

## Lộ trình đọc theo vai trò

**Business Stakeholder / C-level**:
→ `01` (Executive Summary) — đủ để ra quyết định

**HR Administrator**:
→ `01` → `02` (Absence) → `03` (Scheduling) → `06` (Period/Calendar)

**Manager / Team Lead**:
→ `01` → `02` (Absence) → `04` (Attendance)

**Product Manager / BA**:
→ `01` → `02` → `03` → `04` → `05` → `06` (tuần tự)

**Developer / Architect**:
→ `01` → `03` (Architecture) → `05` (Integration) → `04` → `02`

---

## Điểm nổi bật của TA Module

| Innovation | Mô tả ngắn |
|-----------|-----------|
| **6-Level Scheduling** | Xây lịch từ atomic Time Segment → Shift → Day Model → Pattern → Rule → Generated Roster |
| **Rotating Crew Support** | Rotation offset cho phép quản lý 24/7 với nhiều ca xoay không giới hạn |
| **Immutable Leave Ledger** | Mọi thay đổi balance được ghi vào ledger bất biến — không mất dữ liệu, audit hoàn hảo |
| **8-Type Rule Engine** | Eligibility, Validation, Accrual, Carryover, Limit, Overdraft, Proration, Rounding |
| **Hybrid Shift Types** | ELAPSED (cố định), PUNCH (linh hoạt theo giờ vào/ra), FLEX (core hours + flexible) |
| **Reservation System** | Tránh double-booking: balance bị "giữ" ngay khi request được tạo |
| **Multi-Device Clock** | Biometric, RFID, Mobile GPS, Web, Badge — tất cả về một Attendance Record |
| **CO Eligibility Integration** | Điều kiện đủ điều kiện nghỉ phép được quản lý tập trung ở Core module, không duplicate |

---

*Bộ tài liệu này được tổng hợp từ `99-old-docs/01-concept/` (9 guides, ~7,800 dòng nội dung technical).*  
*[01 Executive Summary →](./01-executive-summary.md)*
