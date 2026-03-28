# TA — Các mục trong ta.md KHÔNG được làm Menu

> **Ký hiệu:**
> - `[FUNCTION]` = Trở thành button / tab / action bên trong màn hình menu cha
> - `[DROPPED]`  = Bỏ hoàn toàn, không có trong Java

---

## 1. Absence Management

### 1.2 Leave Request (gộp hết vào menu `TA_LEAVE_REQUESTS`)

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| Submit Request | `[FUNCTION]` | Là action chính của màn hình, không cần menu riêng |
| My Leave Requests | `[FUNCTION]` | View/tab trong cùng trang Leave Requests |
| Cancel/Modify Request | `[FUNCTION]` | Button hành động trên mỗi row của danh sách |
| Upload Documents | `[FUNCTION]` | Button đính kèm tệp trong form request |

### 1.3 Leave Approval (gộp hết vào menu `TA_LEAVE_APPROVAL`)

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| Approval Queue | `[FUNCTION]` | Chính là danh sách mặc định của màn hình |
| Bulk Actions | `[FUNCTION]` | Checkbox + action bar trên list view |
| Multi-Level Routing | `[FUNCTION]` | Config rule được nhúng vào form cấu hình approval |
| Delegate Approver | `[FUNCTION]` | Button "Delegate" trong màn hình approval |
| Team Calendar | `[FUNCTION]` | Tab xem lịch bên cạnh danh sách chờ duyệt |

### 1.4 Leave Balance (gộp hết vào menu `TA_LEAVE_BALANCE`)

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| My Balance | `[FUNCTION]` | View mặc định khi vào màn hình Balance |
| Balance Projection | `[FUNCTION]` | Tab "Dự báo" trong màn hình Balance |
| Balance Statement | `[FUNCTION]` | Button Export/Print trong màn hình Balance |
| Team Balance Overview | `[FUNCTION]` | Tab "Team" chỉ hiển thị với role Manager |

### 1.5 Accrual & Adjustments (gộp hết vào menu `TA_ACCRUAL_ADJUSTMENTS`)

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| Accrual Processing | `[FUNCTION]` | Batch job trigger / tab trong màn hình |
| Carryover Processing | `[FUNCTION]` | Tab xử lý cuối năm trong cùng màn hình |
| Manual Adjustment | `[FUNCTION]` | Form điều chỉnh thủ công trong màn hình |
| Proration Calculation | `[FUNCTION]` | Logic tự động, không cần UI riêng |
| Negative Balance Control | `[FUNCTION]` | Config setting trong màn hình |

### 1.6 Leave Ledger (gộp hết vào menu `TA_LEAVE_LEDGER`)

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| Movement History | `[FUNCTION]` | Bảng danh sách chính của màn hình Ledger |
| Reservation Tracking | `[FUNCTION]` | Tab hoặc filter "Pending/Reserved" trong Ledger |

### 1.7 Advanced Leave Features

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| Sell/Buy Leave | `[DROPPED]` | Nghiệp vụ phức tạp, tích hợp Payroll — không có màn hình quản lý độc lập trong Sprint hiện tại |
| Vacation Bidding | `[DROPPED]` | Tính năng nâng cao (đấu giá lịch nghỉ theo điểm seniority) — chưa đưa vào scope |

---

## 2. Scheduling & Shifts

### 2.1 Shift Configuration

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| Shift Types (ELAPSED/PUNCH/FLEX) | `[FUNCTION]` | Dropdown config nhúng trong form Shift Definitions, không cần menu riêng |

### 2.2 Schedule Management

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| Rotating Schedule | `[FUNCTION]` | Config setting (rotation offset) trong màn hình Generated Rosters |
| Cross-Midnight Support | `[FUNCTION]` | Feature tự động xử lý logic khi tạo ca, không cần UI riêng |
| Schedule Calendar View | `[FUNCTION]` | Toggle view (List/Calendar) trong màn hình Roster |

---

## 3. Time & Attendance

### 3.1 Clock In/Out (gộp vào menu `TA_CLOCK_IN_OUT`)

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| Web Clock | `[FUNCTION]` | UI component chấm công trên trang Clock In/Out |
| Mobile Clock | `[FUNCTION]` | Mobile app screen — không phải menu web admin |
| Biometric Integration | `[FUNCTION]` → moved to 7.4 | Chuyển về Settings > Device Management |
| GPS/Geofencing | `[FUNCTION]` → moved to 7.5 | Chuyển về Settings > Geofence Management |
| Break Tracking | `[FUNCTION]` | Button "Start Break / End Break" trong trang Clock |

### 3.2 Timesheet & Time Entry

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| Project Time Tracking | `[DROPPED]` | Tích hợp PMS (Project Mgmt System) ngoài scope module TA |
| Timesheet History | `[FUNCTION]` | Tab "Lịch sử" trong màn hình Timesheet |

### 3.4 Advanced Time Features

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| Offline Time Capture | `[DROPPED]` | Mobile-side feature (lưu local + sync) — không phải UI admin |
| Auto Clock-In Detection | `[DROPPED]` | AI suggestion feature — chưa vào scope |

---

## 4. Overtime

### 4.2 Overtime Calculation

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| OT Caps & Alerts | `[FUNCTION]` | Config giới hạn nhúng vào màn hình OT Rates hoặc OT Calculation |

### 4.3 Comp Time

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| OT → Comp Time Conversion | `[FUNCTION]` | Action/tab trong màn hình Comp Time |
| Comp Time Usage | `[FUNCTION]` | View số dư + sử dụng trong cùng màn hình Comp Time |

---

## 5. Calendar

### 5.2 Calendar Integration

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| Export to External (.ics) | `[DROPPED]` | Button export — không cần màn hình riêng |
| Sync with Teams/Slack | `[DROPPED]` | Integration qua webhook/config — nằm ngoài scope menu TA |

---

## 6. Reports & Analytics

### 6.2 Analytics

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| Cost Analysis | `[DROPPED]` | Tính năng nâng cao liên quan Payroll — chưa vào scope |
| Predictive Analytics | `[DROPPED]` | AI/ML feature — chưa vào scope |

---

## 7. Settings

### 7.3 Approval Configuration (gộp vào menu `TA_APPROVAL_CONFIGURATION`)

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| Approval Chains | `[FUNCTION]` | Tab cấu hình chuỗi route bên trong màn hình |
| Escalation Rules | `[FUNCTION]` | Tab cấu hình escalation bên trong màn hình |
| Notification Templates | `[FUNCTION]` | Tab chỉnh nội dung email/push bên trong màn hình |

### 7.4 Device Management (gộp vào menu `TA_DEVICE_MANAGEMENT`)

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| Device Registration | `[FUNCTION]` | Form đăng ký mới trong danh sách thiết bị |
| Device Sync Status | `[FUNCTION]` | Cột trạng thái / realtime indicator trong danh sách |
| Device Vendor Config | `[FUNCTION]` | Tab config per-vendor bên trong trang Device Management |

### 7.5 Geofence Management (gộp vào menu `TA_GEOFENCE_MANAGEMENT`)

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| Geofence Zones | `[FUNCTION]` | CRUD zone trên map trong màn hình Geofence |
| Enforcement Rules | `[FUNCTION]` | Config STRICT/WARN/LOG là setting của từng zone |

### 7.6 Integration

| Mục trong ta.md | Trạng thái | Lý do |
|---|---|---|
| PR Integration | `[DROPPED]` | Không có màn hình monitoring — cần xem xét bổ sung |
| CO Integration | `[DROPPED]` | Không có màn hình monitoring — cần xem xét bổ sung |
| External Devices | `[FUNCTION]` | API config nhúng vào `TA_DEVICE_INTEGRATION` (7.7) |

---

## Tổng kết TA

| Loại | Số lượng mục |
|---|---|
| Được làm menu | ~47 items |
| `[FUNCTION]` — button/tab/action trong menu cha | ~38 mục |
| `[DROPPED]` — bỏ khỏi scope hiện tại | 9 mục |
