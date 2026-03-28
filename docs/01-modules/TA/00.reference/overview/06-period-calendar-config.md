# TA Module — Cấu hình Period & Holiday Calendar

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-05  
**Đối tượng**: HR Administrator, System Configurator

---

## Tổng quan

**Period Profiles** và **Holiday Calendar** là nền tảng hạ tầng của cả hai sub-modules trong TA. Trước khi cấu hình leave policy hay tạo shift schedule, HR cần thiết lập:
1. **Kỳ tính phép (Period Profile)** — xác định "năm phép" của tổ chức
2. **Lịch nghỉ lễ (Holiday Calendar)** — xác định ngày nào là ngày lễ/nghỉ
3. **Lịch làm việc (Working Schedule)** — xác định ngày nào là ngày làm việc chuẩn

---

## Period Profiles — 4 Loại Kỳ Tính Phép

| Period Type | Mô tả | Khi dùng |
|-------------|-------|---------|
| `CALENDAR_YEAR` | 01/01 đến 31/12 | Hầu hết doanh nghiệp Việt Nam |
| `FISCAL_YEAR` | Theo năm tài chính công ty | Công ty FY khác calendar (VD: 01/04–31/03) |
| `HIRE_ANNIVERSARY` | Từ ngày gia nhập → tròn 1 năm | Policy "leave resets on work anniversary" |
| `CUSTOM` | Bất kỳ ngày bắt đầu cố định | VD: 01/06 → 31/05 (năm học) |

### Ví dụ cấu hình

```yaml
PeriodProfile:
  name: "Năm phép 2025"
  type: CALENDAR_YEAR
  startDate: "2025-01-01"
  endDate: "2025-12-31"
  carryoverDeadline: "2026-03-31"  # Deadline dùng phép carry từ 2024
  applicableLeaveTypes: [ANNUAL_LEAVE, SICK_LEAVE]
```

```yaml
PeriodProfile:
  name: "Anniversary-based Leave"
  type: HIRE_ANNIVERSARY
  # Each employee gets their own period calculated from hire date
  carryoverMaxDays: 5
  applicableLeaveTypes: [ANNUAL_LEAVE]
```

---

## Pay Period Configuration

Pay periods xác định chu kỳ tính lương — khác với leave period:

| Pay Frequency | Chu kỳ | Số kỳ/năm | Phù hợp với |
|--------------|:------:|:---------:|------------|
| **Weekly** | 7 ngày | 52 | Công nhân nhà máy, hourly workers |
| **Biweekly** | 14 ngày | 26 | Phổ biến tại Mỹ/Canada |
| **Semi-Monthly** | 1–15 và 16–cuối tháng | 24 | Phổ biến tại VN (lương 2 kỳ/tháng) |
| **Monthly** | 1–cuối tháng | 12 | Nhân viên văn phòng, quản lý |

**Tách biệt Leave Period và Pay Period**: Một tổ chức có thể dùng Leave Period = Calendar Year nhưng Pay Period = Monthly — hai cấu hình hoàn toàn độc lập.

---

## Holiday Calendar Management

### Hai loại Holiday

| Loại | Mô tả | Quản lý bởi |
|------|-------|------------|
| **Public Holidays** | Nghỉ lễ theo luật lao động | Chính phủ quy định, HR cập nhật hàng năm |
| **Company Holidays** | Nghỉ do công ty tự quyết | HR Admin (VD: ngày thành lập công ty) |

### Cấu trúc Holiday Calendar

```yaml
HolidayCalendar:
  name: "Vietnam Public Holidays 2025"
  country: "VN"
  year: 2025
  holidays:
    - date: "2025-01-01"
      name: "New Year's Day"
      type: PUBLIC
    - date: "2025-04-30"
      name: "Reunification Day"
      type: PUBLIC
    - date: "2025-05-01"
      name: "Labor Day"
      type: PUBLIC
    - date: "2025-09-02"
      name: "National Day"
      type: PUBLIC
    # Tết Nguyên Đán 2025 (theo âm lịch)
    - date: "2025-01-27"
      name: "Tết Nguyên Đán (Eve)"
      type: PUBLIC
    - dates: ["2025-01-28", "2025-01-29", "2025-01-30",
              "2025-01-31", "2025-02-01", "2025-02-02"]
      name: "Tết Nguyên Đán"
      type: PUBLIC
```

### Multi-Calendar Support

Một tổ chức có thể có nhiều holiday calendars:

```
Vietnam Office         → VN Public Holidays + Company Holidays
Singapore Office       → SG Public Holidays + Company Holidays
US Remote Team         → US Federal Holidays + Company Holidays
Factory (Continuous)   → Only statutory holidays, no company holidays
```

Mỗi **WorkScheduleRule** (L5 trong scheduling hierarchy) và mỗi **LeaveType** đều link đến một HolidayCalendar cụ thể.

---

## Working Schedule Definition

**WorkingSchedule** định nghĩa pattern ngày làm việc chuẩn — khác với ShiftDefinition (định nghĩa giờ làm):

```yaml
WorkingSchedule:
  name: "Standard Office Schedule"
  workdays: [MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY]
  standardHoursPerDay: 8
  standardHoursPerWeek: 40
```

**Tại sao cần WorkingSchedule?**

Working Schedule được dùng bởi **cả hai sub-modules**:

| Sub-module | Sử dụng WorkingSchedule để |
|---------|--------------------------|
| Absence Management | Tính số ngày làm việc trong leave request (bỏ qua weekends) |
| Time & Attendance | Xác định ngày nào là "expected work day" cho exception detection |

**Ví dụ**: Nhân viên xin nghỉ từ Thứ Hai 24/3 đến Thứ Sáu 28/3:
- Nếu `workdays = Mon-Fri` → tính là **5 ngày làm việc**
- Nếu `workdays = Mon-Sat` → tính là **6 ngày làm việc**

---

## Impact Matrix — Cấu hình ảnh hưởng đến đâu

```
PeriodProfile ──────→ LeaveBalance (resets each period)
                  └──→ LeaveMovement CARRYOVER (triggered at period end)
                  └──→ LeaveMovement EXPIRY (triggered at period end)

HolidayCalendar ────→ GeneratedRoster (holidays override work days)
                  └──→ LeaveRequest (holiays not counted as leave days)
                  └──→ OvertimeCalculation (holiday OT multiplier)

WorkingSchedule ────→ LeaveRequest (count working days in range)
                  └──→ AttendanceRecord (expected vs actual comparison)
                  └──→ StandardHours for timesheet validation
```

---

## 3 Kịch bản cấu hình điển hình

### Kịch bản 1: Văn phòng hành chính tiêu chuẩn

```
PeriodProfile:   Calendar Year (Jan–Dec)
PayPeriod:       Monthly (1–last day)
HolidayCalendar: VN Public Holidays 2025 + Company holidays
WorkingSchedule: Mon–Fri, 8h/day, 40h/week
ShiftPattern:    Day Shift 08:00–17:00 (with lunch break)
```

### Kịch bản 2: Retail / Bán lẻ (7 ngày/tuần)

```
PeriodProfile:   Calendar Year OR Hire Anniversary
PayPeriod:       Semi-Monthly (1–15, 16–last)
HolidayCalendar: VN Public Holidays + Mall holidays
WorkingSchedule: Mon–Sun (5 any days), 8h/day
ShiftPattern:    Multiple shifts (Morning, Afternoon, Full)
                 Rotation: 2-2-3 pattern
OT Rules:        Rest day OT at 2.0x (varies by roster)
```

### Kịch bản 3: Nhà máy sản xuất 24/7

```
PeriodProfile:   Calendar Year
PayPeriod:       Monthly
HolidayCalendar: VN Public Holidays (minimal company holidays)
WorkingSchedule: All 7 days (no "standard" weekday concept)
ShiftPattern:    3 shifts: Day / Evening / Night (8h each)
PatternTemplate: 21-day rotating cycle
RotationOffset:  Crew A:0, Crew B:7, Crew C:14
OT Rules:        Daily >8h: 1.5x; Holiday: 3.0x
```

---

## Checklist trước khi go-live

**Bắt buộc phải cấu hình trước khi dùng bất kỳ feature nào khác**:

- [ ] Tạo ít nhất 1 **PeriodProfile** cho năm hiện tại
- [ ] Import **HolidayCalendar** cho năm hiện tại (public holidays)
- [ ] Định nghĩa **WorkingSchedule** cho mỗi loại workforce
- [ ] Verify: Holiday Calendar linked đến ShiftScheduleRules và LeaveTypes
- [ ] Verify: PeriodProfile linked đến LeaveTypes

**Hàng năm** (recurring maintenance):
- [ ] Tạo PeriodProfile cho năm mới (clone và update dates)
- [ ] Import HolidayCalendar năm mới (thường có khi chính phủ công bố)
- [ ] Review và xử lý carryover deadline từ năm trước

---

*Nguồn: tổng hợp từ `08-period-profiles-guide.md`*  
*← [05 Approval & Integration](./05-approval-integration.md) · [README (tổng quan)](./README.md)*
