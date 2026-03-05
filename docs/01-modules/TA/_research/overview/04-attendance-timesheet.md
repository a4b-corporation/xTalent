# TA Module — Chấm công & Timesheet

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-05  
**Đối tượng**: Manager, HR Administrator, Employee

---

## Tổng quan

**Time & Attendance** tracking trong xTalent bao gồm 3 lớp hoạt động chính:
1. **Clock Events** — ghi nhận thời gian thực tế nhân viên đến/về
2. **Attendance Records** — kết hợp giờ thực tế với lịch dự kiến, phát hiện exceptions
3. **Timesheet** — phân bổ chi tiết thời gian theo dự án/nhiệm vụ, phục vụ tính lương

---

## Clock In/Out — Multi-Device Support

Hệ thống nhận clock events từ nhiều nguồn, tất cả đều tạo cùng một loại `AttendanceRecord`:

| Cơ chế | Mô tả | Đặc điểm |
|--------|-------|----------|
| **Biometric** | Vân tay, nhận diện khuôn mặt | Không thể thay thế, chính xác nhất |
| **RFID/Badge** | Quẹt thẻ tại máy chấm công | Phổ biến, dễ tích hợp |
| **Mobile App** | Clock in qua smartphone | Hỗ trợ GPS location verification |
| **Web Portal** | Click qua trình duyệt | Phù hợp với WFH/remote |
| **Manual Entry** | HR/Manager nhập thủ công | Dùng khi thiết bị lỗi, retroactive correction |

**GPS Geofencing** (optional): Hệ thống có thể giới hạn chỉ clock in khi nhân viên trong bán kính X mét từ địa điểm làm việc.

---

## Attendance Record Lifecycle

```
Shift scheduled → Employee arrives → Clock In received
                                          │
                               Create AttendanceRecord
                               Link to GeneratedRoster
                                          │
                              ┌───────────┴───────────┐
                              │                       │
                         On time?               Late > grace?
                              │                       │
                         PRESENT               Create TimeException
                                               (LATE_IN, minutes, severity)
                                               Notify Manager
                                                       │
            Employee departs → Clock Out received
                                          │
                               Update AttendanceRecord
                               Calculate actual hours
                                          │
                              ┌─────────────────────────┐
                              │                         │
                         On schedule?             Early/Missing?
                              │                         │
                         COMPLETE              Create TimeException
                                               (EARLY_OUT / MISSING_PUNCH)
```

**Final attendance status**:

| Status | Ý nghĩa |
|--------|---------|
| `PRESENT` | Đến đúng giờ, đủ giờ |
| `LATE` | Đến trễ vượt grace period |
| `EARLY_DEPARTURE` | Về sớm vượt grace period |
| `ABSENT` | Không đến, không có leave approved |
| `ON_LEAVE` | Nghỉ phép được approved |
| `HOLIDAY` | Ngày lễ theo lịch |

---

## 5 Loại Time Exception

| Exception | Khi nào xảy ra | Severity | Action yêu cầu |
|-----------|---------------|:--------:|----------------|
| `LATE_IN` | Clock in trễ hơn (scheduled + grace) | WARNING | Manager review |
| `EARLY_OUT` | Clock out sớm hơn (scheduled − grace) | WARNING | Manager review |
| `MISSING_PUNCH` | Thiếu clock in hoặc clock out cuối ngày | VIOLATION | Employee correction |
| `UNAUTHORIZED_ABSENCE` | Không đến, không có leave | CRITICAL | Manager + HR action |
| `OVERTIME` | Làm vượt giờ không có pre-approval | INFO | Review for approval |

### Grace Period & Rounding Rules

**Grace Period**: Khoảng thời gian cho phép trước khi phát sinh exception.
- Ví dụ: Shift bắt đầu 08:00, grace = 5 phút → đến lúc 08:04 vẫn PRESENT
- Có thể cấu hình khác nhau cho từng shift type

**Rounding Rules**: Làm tròn giờ để tính lương:
- `NEAREST_15`: Làm tròn đến 15 phút gần nhất (08:07 → 08:00, 08:08 → 08:15)
- `ROUND_DOWN`: Luôn làm tròn xuống (có lợi cho công ty)
- `ROUND_UP`: Luôn làm tròn lên (có lợi cho nhân viên)
- `NO_ROUNDING`: Tính chính xác đến phút

---

## Timesheet Management

**Timesheet** khác với Attendance Record:
- **Attendance Record**: AI đã làm gì (thực tế clock in/out)
- **Timesheet Entry**: Thời gian được phân bổ vào đâu (project, task, work type)

### Cấu trúc Timesheet Entry

```yaml
TimesheetEntry:
  employee: "Nguyen Van A"
  date: "2025-03-01"
  hours: 8.0
  workType: "REGULAR"       # REGULAR | OVERTIME | BILLABLE | NON_BILLABLE
  projectCode: "PRJ-001"
  taskCode: "TASK-123"
  description: "Backend development - authentication module"
  status: SUBMITTED          # DRAFT → SUBMITTED → APPROVED/REJECTED
```

**Timesheet Approval Flow**:
```
Employee: Draft → Submit
Manager:  Review → Approve / Reject (with comment)
System:   On approval → send data to Payroll
```

---

## Overtime Calculation

### 4 Loại Overtime Rule

| Rule Type | Threshold | Typical Multiplier |
|-----------|-----------|:------------------:|
| **Daily OT** | > 8 giờ/ngày | 1.5× |
| **Weekly OT** | > 40 giờ/tuần | 1.5× |
| **Rest Day OT** | Làm việc ngày OFF | 2.0× |
| **Holiday OT** | Làm việc ngày lễ | 3.0× |

### Multi-Rule Application (Ví dụ)

```
Tuần với 45 giờ làm việc, bao gồm 8 giờ ngày lễ:

Daily OT (>8h/ngày):
  Mon: 9h → 1h OT @ 1.5× = 1.5
  Tue: 9h → 1h OT @ 1.5× = 1.5
  Wed: 9h → 1h OT @ 1.5× = 1.5
  Total daily OT: 3h @ 1.5×

Weekly OT (>40h total):
  Total: 45h, excess: 5h
  But 3h already counted as daily OT
  Additional weekly OT: 2h @ 1.5×

Holiday OT (holiday work):
  Friday: 8h holiday work @ 3.0×
  (overrides daily OT rate)

FINAL CALCULATION:
  Regular:    32h @ 1.0× (standard)
  Daily OT:    3h @ 1.5×
  Weekly OT:   2h @ 1.5×
  Holiday OT:  8h @ 3.0×
```

**Highest multiplier wins**: Nếu một giờ rơi vào nhiều rules, hệ thống áp dụng multiplier cao nhất (không cộng dồn).

### 3 Phương pháp tính Overtime

| Method | Áp dụng cho | Cách tính |
|--------|------------|---------|
| **DAILY** | Daily threshold | Compare actual vs scheduled per day |
| **WEEKLY** | Weekly threshold | Aggregate weekly, deduct regular hours |
| **PAY_PERIOD** | Payroll period | Aggregate per pay period |

---

## Shift Swap — Employee Self-Service

Nhân viên có thể chủ động đổi ca với đồng nghiệp qua quy trình chuẩn:

```
Nhân viên A                System                Nhân viên B          Manager
     │                       │                        │                  │
     ├──[Initiate swap]──────→│                        │                  │
     │                       ├──Validate shifts────────┤                  │
     │                       ├──Check qualifications───┤                  │
     │                       ├──Send swap request──────→│                  │
     │                       │                        ├──[Accept]──────→ │
     │                       │                        │                  │
     │                       │◄──────────────────────────────[Approve]───┤
     │                       ├──Update roster A & B────────────────────→ │
     │←──[Notify]────────────┤                        │←──[Notify]────── │
```

**Validation khi tạo swap request**:
- Cả hai shifts phải tồn tại và chưa xảy ra
- Nhân viên B phải có đủ qualifications cho shift của A (nếu cấu hình)
- Không tạo schedule conflict

---

## Overtime Request — Pre-Approval Flow

Khi nhân viên cần làm thêm ngoài giờ chính thức:

```
1. Employee: Submit Overtime Request (trước khi làm)
   → Specify: date, expected hours, reason
2. Manager: Review and Approve/Reject
3. Employee: Work the overtime hours
4. Employee: Submit timesheet with actual hours
5. System: Match approved OT request → calculate with multiplier
6. Manager: Approve timesheet
7. System: Send OT data to Payroll
```

**Nếu không có pre-approval**: Hệ thống tạo TimeException (OVERTIME) và yêu cầu retroactive approval.

---

## Luồng dữ liệu đến Payroll

```
Attendance Records ──→ Actual hours worked (regular + OT)
Timesheet Entries  ──→ Classified hours (billable, project codes)
Leave Records      ──→ Unpaid leave deductions, statutory leave
OT Calculations    ──→ OT hours + multipliers per type
                              │
                              ↓
                       PR (Payroll Module)
                       Calculates wages at period close
```

---

*Nguồn: tổng hợp từ `06-attendance-tracking-guide.md` và `02-conceptual-guide.md` (Workflows 2, 4, 5)*  
*← [03 Scheduling](./03-shift-scheduling-architecture.md) · [05 Approval & Integration →](./05-approval-integration.md)*
