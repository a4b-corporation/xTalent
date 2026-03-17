# Time & Absence (TA) — Menu Structure

**Module**: Time & Absence (TA)  
**Version**: 1.0 (aligned with deep analysis)  
**Ngày**: 2026-03-17

---

## Tổng quan

Module TA gồm **2 sub-module chính** (Absence Management + Time & Attendance) với **65 features** trải đều 10 categories. Sau deep analysis, các chức năng sau **không còn thuộc TA**:

| Chức năng | Chuyển sang | Lý do (ref) |
|-----------|:-----------:|-------------|
| Holiday Calendar | **Core** | Consolidated `common.holiday_calendar` (Doc 06) |
| Eligibility Engine | **Core** | Single engine at `eligibility.*` (Doc 05) |

TA sử dụng Core eligibility qua FK (`eligibility_profile_id`) và đọc holiday data từ Core.

---

## Menu Tree

```
Time & Absence
│
├── 1. Absence Management                   ─── Quản lý nghỉ phép
│   ├── 1.1 Leave Configuration              ─── Thiết lập chính sách (HR Admin)
│   │   ├── Leave Types                      Danh mục loại nghỉ: Annual, Sick, Maternity, Bereavement...
│   │   ├── Leave Classes                    Nhóm leave types: Paid, Unpaid, Statutory, Company
│   │   ├── Leave Policies                   Chính sách: accrual, carryover, expiry, proration per country
│   │   ├── Leave Rules                      8 loại rule: Eligibility, Validation, Accrual, Carryover,
│   │   │                                    Limit, Overdraft, Proration, Rounding
│   │   └── Concurrent Leave Rules           Cấu hình loại nghỉ được phép overlap
│   │
│   │   Note: Eligibility rules tập trung tại Core module
│   │         TA reference qua eligibility_profile_id → Core
│   │
│   ├── 1.2 Leave Request                    ─── Tạo & quản lý đơn nghỉ (Employee)
│   │   ├── Submit Request                   Tạo đơn: chọn loại, ngày, full/half/hourly, xem balance trước
│   │   ├── My Leave Requests                Danh sách đơn đã gửi: draft, pending, approved, rejected
│   │   ├── Cancel/Modify Request            Hủy hoặc sửa đơn (pending: tự do, approved: cần approval)
│   │   └── Upload Documents                 Đính kèm giấy tờ: medical cert, khai sinh, giấy kết hôn...
│   │
│   ├── 1.3 Leave Approval                   ─── Phê duyệt đơn (Manager)
│   │   ├── Approval Queue                   Danh sách đơn chờ duyệt (filter by team, urgency)
│   │   ├── Bulk Actions                     Approve/reject nhiều đơn cùng lúc
│   │   ├── Multi-Level Routing              Config routing theo duration (≤3d→Mgr, 4-7d→HR, >7d→Dir)
│   │   ├── Delegate Approver                Ủy quyền phê duyệt khi manager vắng
│   │   └── Team Calendar                    Xem lịch nghỉ team trước khi duyệt
│   │
│   ├── 1.4 Leave Balance                    ─── Số dư nghỉ phép
│   │   ├── My Balance                       Xem balance theo từng loại: Opening + Earned − Used − Pending = Available
│   │   ├── Balance Projection               Xem balance tại ngày tương lai (forecast)
│   │   ├── Balance Statement                Export/print balance statement
│   │   └── Team Balance Overview            Manager xem balance tổng team
│   │
│   ├── 1.5 Accrual & Adjustments            ─── Tích lũy & điều chỉnh (HR Admin)
│   │   ├── Accrual Processing               Batch job: tính accrual theo kỳ (Monthly/Quarterly/Annual)
│   │   ├── Carryover Processing             Xử lý chuyển balance sang năm mới (max days, expiry)
│   │   ├── Manual Adjustment                HR điều chỉnh balance thủ công (với lý do + audit)
│   │   ├── Proration Calculation            Pro-rata cho NV mới/nghỉ việc/thay đổi status
│   │   └── Negative Balance Control         Cấu hình cho phép balance âm + max negative days
│   │
│   ├── 1.6 Leave Ledger                     ─── Sổ cái bất biến (Immutable)
│   │   ├── Movement History                 Mọi biến động balance: ACCRUAL, USED, CANCEL, ADJUST, CARRYOVER, EXPIRE
│   │   └── Reservation Tracking             Balance giữ chỗ ngay khi request tạo → tránh double-booking
│   │
│   └── 1.7 Advanced Leave Features          ─── Tính năng nâng cao
│       ├── Sell/Buy Leave                   NV bán/mua ngày phép (tích hợp Payroll)
│       ├── Compensatory Time                Convert OT hours → comp time balance (1:1, 1:1.5, 1:2)
│       └── Vacation Bidding                 Đấu giá lịch nghỉ cao điểm (Tết, hè) theo seniority/points
│
├── 2. Scheduling & Shifts                   ─── Lịch làm việc & ca
│   ├── 2.1 Shift Configuration              ─── Thiết lập ca (HR Admin)
│   │   ├── Time Segments (L1)               Atomic blocks: Working, Break, Meal, OT — start/end/type
│   │   ├── Shift Definitions (L2)           Ghép segments thành ca: Morning 8-17, Night 22-06...
│   │   ├── Day Models (L3)                  Mẫu ngày: Working Day, Off Day, Holiday, Half Day
│   │   ├── Pattern Templates (L4)           Mẫu lặp: 5on-2off, 4on-3off, 3-shift rotation
│   │   └── Shift Types                      3 loại: ELAPSED (cố định), PUNCH (theo giờ vào/ra), FLEX (core + flexible)
│   │
│   ├── 2.2 Schedule Management              ─── Quản lý lịch làm việc
│   │   ├── Work Schedule Rules (L5)         Gắn pattern → nhóm NV: by department, grade, location
│   │   ├── Generated Rosters (L6)           Auto-generate roster cho period (tuần/tháng)
│   │   ├── Rotating Schedule                Rotation offset cho ca xoay: 2-team, 3-team, 4-team 24/7
│   │   ├── Cross-Midnight Support           Hỗ trợ ca qua ngày (22:00-06:00)
│   │   └── Schedule Calendar View           Hiển thị lịch: Individual / Team / Department
│   │
│   └── 2.3 Shift Operations                 ─── Vận hành ca (Employee/Manager)
│       ├── My Schedule                      NV xem lịch ca của mình
│       ├── Shift Swap Request               NV đề xuất đổi ca với đồng nghiệp → approval
│       └── Schedule Override                Manager override roster cho NV cụ thể (ad-hoc)
│
├── 3. Time & Attendance                     ─── Chấm công & giờ làm
│   ├── 3.1 Clock In/Out                     ─── Chấm công (Employee)
│   │   ├── Web Clock                        Chấm công qua browser
│   │   ├── Mobile Clock                     Chấm công qua app (GPS capture, offline support)
│   │   ├── Biometric Integration            Kết nối fingerprint/face recognition (ZKTeco, Suprema, Hikvision)
│   │   ├── GPS/Geofencing                   Validate vị trí chấm công trong geofence (STRICT/WARN/LOG)
│   │   └── Break Tracking                   Clock in/out cho break, meal
│   │
│   ├── 3.2 Timesheet & Time Entry           ─── Bảng chấm công
│   │   ├── Daily/Weekly Timesheet           Calendar-based entry, copy from previous, split by cost center
│   │   ├── Project Time Tracking            Allocate giờ theo project/task
│   │   ├── Timesheet Approval               Manager approve timesheet (weekly/bi-weekly cycle)
│   │   └── Timesheet History                Lịch sử timesheet đã submit
│   │
│   ├── 3.3 Attendance Management            ─── Quản lý chấm công (HR Admin/Manager)
│   │   ├── Attendance Dashboard             Tổng quan: present, absent, late, early departure
│   │   ├── Exception Management             Xử lý ngoại lệ: missing punch, late clock, OT unplanned
│   │   ├── Attendance Correction            HR sửa attendance record (với lý do + audit trail)
│   │   └── Attendance Summary               Bảng tổng hợp chấm công theo kỳ
│   │
│   └── 3.4 Advanced Time Features           ─── Tính năng nâng cao
│       ├── Offline Time Capture             Lưu local → sync khi có mạng (7 ngày offline)
│       └── Auto Clock-In Detection          AI gợi ý chấm công dựa trên WiFi/location patterns
│
├── 4. Overtime                              ─── Giờ làm thêm
│   ├── 4.1 Overtime Request & Approval      ─── Đăng ký & phê duyệt
│   │   ├── OT Request                       NV/Manager đăng ký OT: date, hours, reason
│   │   └── OT Approval                      Phê duyệt OT (route theo policy)
│   │
│   ├── 4.2 Overtime Calculation             ─── Tính OT
│   │   ├── OT Rates                         Weekday 150%, Weekend 200%, Holiday 300% (per country)
│   │   ├── OT Calculation Engine            Auto-tính OT hours × rate → gửi Payroll
│   │   └── OT Caps & Alerts                 Giới hạn OT: monthly/annual cap, alert khi gần limit
│   │
│   └── 4.3 Comp Time                        ─── Nghỉ bù
│       ├── OT → Comp Time Conversion        Convert OT hours → comp time balance (rate configurable)
│       └── Comp Time Usage                  Dùng comp time thay vì annual leave
│
├── 5. Calendar                              ─── Lịch & ngày lễ
│   │
│   │   Note: Holiday Calendar data được quản lý tại Core module
│   │         (common.holiday_calendar — single source of truth)
│   │         TA đọc holiday data từ Core, không duplicate
│   │
│   ├── 5.1 Calendar Views                   ─── Xem lịch
│   │   ├── Team Absence Calendar            Lịch nghỉ team: xem ai nghỉ, ai trực
│   │   ├── Department Calendar              Lịch nghỉ phòng ban overview
│   │   └── My Calendar                      NV: lịch cá nhân — ca, nghỉ, OT, holidays
│   │
│   └── 5.2 Calendar Integration             ─── Tích hợp lịch
│       ├── Export to External               Export .ics cho Google Calendar / Outlook
│       └── Sync with Teams/Slack            Tự động cập nhật status khi nghỉ phép
│
├── 6. Reports & Analytics                   ─── Báo cáo
│   ├── 6.1 Operational Reports              ─── Báo cáo vận hành
│   │   ├── Absence Dashboard                Tổng quan nghỉ phép: by type, trend, department
│   │   ├── Attendance Report                Bảng chấm công theo kỳ (daily/weekly/monthly)
│   │   ├── OT Report                        Giờ OT theo NV, team, department, tháng
│   │   └── Compliance Report                Kiểm tra tuân thủ labor law (VN Điều 112-115, Điều 98)
│   │
│   ├── 6.2 Analytics                        ─── Phân tích
│   │   ├── Trend Analysis                   Xu hướng nghỉ phép: seasonal, by leave type, year-over-year
│   │   ├── Cost Analysis                    Chi phí liên quan: paid leave cost, OT cost
│   │   ├── Predictive Analytics             AI dự đoán: absence patterns, peak periods, staffing needs
│   │   └── Absenteeism Rate                 Tỷ lệ vắng mặt theo team/dept — benchmark
│   │
│   └── 6.3 Custom Reports                   ─── Báo cáo tùy chỉnh
│       └── Report Builder                   Drag-drop builder: chọn dimensions, filters, output format
│
└── 7. Settings                              ─── Cài đặt module
    ├── 7.1 Period Configuration             ─── Kỳ chấm công
    │   ├── Period Profiles                  Loại kỳ: Monthly, Bi-Weekly, Weekly + cut-off dates
    │   └── Accrual Periods                  Kỳ tích lũy phép: Monthly, Quarterly, Annual
    │
    ├── 7.2 Labor Law Templates              ─── Template luật lao động
    │   ├── Vietnam (BLLD 2019)              Pre-built: 12/14/16d annual, sick = f(SI years), OT rates
    │   ├── US (FMLA/State)                  Pre-built: FMLA 12 weeks, state-specific rules
    │   └── Singapore (EA)                   Pre-built: EA leave entitlements
    │
    ├── 7.3 Approval Configuration           ─── Cấu hình phê duyệt
    │   ├── Approval Chains                  Define routing: by leave type, duration, org level
    │   ├── Escalation Rules                 Auto-escalate sau X ngày chờ
    │   └── Notification Templates           Email/push notification templates
    │
    ├── 7.4 Device Management                ─── Quản lý thiết bị chấm công
    │   ├── Device Registration              Đăng ký: fingerprint, face recognition, card reader
    │   ├── Device Sync Status               Monitoring: online/offline, last sync, error log
    │   └── Device Vendor Config             Cấu hình vendor: ZKTeco, Suprema, HID, Hikvision
    │
    ├── 7.5 Geofence Management              ─── Quản lý vùng chấm công
    │   ├── Geofence Zones                   Định nghĩa zones: office, site, warehouse + radius
    │   └── Enforcement Rules                Policy: STRICT (block), WARN (alert), LOG (record only)
    │
    └── 7.6 Integration                      ─── Tích hợp
        ├── PR Integration                   Data flow → Payroll: attendance, OT hours, leave days
        ├── CO Integration                   Nhận từ Core: employee, assignment, work schedule, eligibility
        └── External Devices                 API config cho biometric devices, badge readers
```

---

## Mapping Feature Categories → Menu

| # | Feature Category (65 features) | Menu Section | Vai trò chính |
|:-:|-------------------------------|:------------:|:-------------:|
| 1 | Time Tracking (8) | 3. Time & Attendance | Employee, Manager |
| 2 | Absence Management (12) | 1.2, 1.3 Leave Request/Approval | Employee, Manager |
| 3 | Leave Balance & Accrual (8) | 1.4, 1.5 Balance/Accrual | Employee, HR Admin |
| 4 | Leave Policy & Compliance (6) | 1.1, 7.2 Configuration/Templates | HR Admin |
| 5 | Scheduling (7) | 2. Scheduling & Shifts | HR Admin, Manager |
| 6 | Calendar & Holiday (4) | 5. Calendar | Employee, Manager |
| 7 | Overtime & Compensatory (4) | 4. Overtime | Employee, Manager |
| 8 | Reporting & Analytics (6) | 6. Reports | Manager, HR Admin |
| 9 | Self-Service & UX (5) | Embedded across sections | Employee |
| 10 | Integration (5) | 7.6 Integration | System Admin |

---

## Menu by User Role

### HR Administrator
```
1.1 Leave Configuration > Types, Classes, Policies, Rules
1.5 Accrual > Processing, Carryover, Manual Adjustment
2.1 Shift Configuration > Segments, Shifts, Day Models, Patterns
2.2 Schedule Management > Rules, Roster Generation
3.3 Attendance > Dashboard, Exceptions, Corrections
6. Reports > All
7. Settings > All
```

### Manager / Team Lead
```
1.3 Leave Approval > Queue, Bulk Actions, Team Calendar
1.4 Leave Balance > Team Balance Overview
2.2 Schedule > Calendar View, Override
2.3 Shift Operations > Approve Shift Swap
3.2 Timesheet > Approve
3.3 Attendance > Dashboard, Exception Management
4. Overtime > Approve OT
6.1 Reports > Attendance, OT, Absence Dashboard
```

### Employee (Self-Service)
```
1.2 Leave Request > Submit, My Requests, Cancel/Modify
1.4 Leave Balance > My Balance, Projection
1.6 Ledger > My Movement History
2.3 Shift Operations > My Schedule, Shift Swap Request
3.1 Clock In/Out > Web/Mobile Clock
3.2 Timesheet > Daily/Weekly Entry, Project Time
4.1 OT > Request
5.1 Calendar > My Calendar
```

### Workforce Planner
```
2.1 Shift Configuration > All 6 levels
2.2 Schedule Management > Roster Generation, Rotating Schedules
5.1 Calendar > Department Calendar
6.2 Analytics > Predictive, Trend, Cost
```
