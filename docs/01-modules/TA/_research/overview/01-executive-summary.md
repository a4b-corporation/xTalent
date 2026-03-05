# TA Module — Executive Summary

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-05  
**Đối tượng**: Business Stakeholders, Product Leadership

---

## Time & Absence là gì?

**Time & Absence (TA)** là module quản lý toàn bộ quan hệ giữa nhân viên và thời gian làm việc — từ việc nhân viên xin nghỉ phép, chấm công hàng ngày, đến việc tính toán overtime và cung cấp dữ liệu chính xác cho Payroll.

Đây là module **tương tác cao nhất** trong hệ thống xTalent — hầu như mọi nhân viên đều dùng TA mỗi ngày, trong khi Core HR hay Payroll chỉ được cấu hình định kỳ.

---

## Vấn đề mà TA giải quyết

Hầu hết doanh nghiệp vừa-lớn đang vật lộn với những vấn đề sau:

| Vấn đề thực tế | Hệ thống truyền thống | TA giải quyết |
|---------------|----------------------|---------------|
| Tính balance nghỉ phép thủ công, dễ sai | Excel, cộng trừ tay — sai số cao | Immutable ledger, tự động tính tức thì |
| Policy nghỉ phép khác nhau cho từng nhóm nhân viên | Copy rule, sửa nhiều chỗ, hay quên | Rule binding 3-level với priority-based resolution |
| Lịch ca phức tạp (24/7, xoay ca, offshore) | Xây tay trong Excel mỗi tuần | 6-level automatic roster generation với rotation offset |
| Không biết nhân viên đi làm muộn bao lâu | Check camera hoặc thủ công | Grace period + automatic exception detection |
| Overtime tính sai → payroll sai | Cộng thủ công, bỏ sót trường hợp phức tạp | Multi-rule overtime engine (daily + weekly + holiday) |
| Nhân viên xin đổi ca không có quy trình chuẩn | WhatsApp, tự thỏa thuận | Shift swap workflow với manager approval |
| Dữ liệu chấm công không vào được payroll đúng hạn | Export CSV thủ công | Event-driven integration với Payroll module |

---

## Scale và độ hoàn chỉnh

| Thống kê | Số liệu |
|---------|---------:|
| Sub-modules chính | **2** (Absence + Time & Attendance) |
| Entities trong domain model | **18+** |
| Loại Leave Rule | **8** (Eligibility, Validation, Accrual, Carryover, Limit, Overdraft, Proration, Rounding) |
| Levels trong scheduling hierarchy | **6** (Segment → Shift → Day → Pattern → Rule → Roster) |
| Loại Time Exception | **5** (LATE_IN, EARLY_OUT, MISSING_PUNCH, UNAUTHORIZED_ABSENCE, OVERTIME) |
| Clock-in mechanisms | **5+** (Biometric, RFID, Mobile, Web, Badge) |
| Overtime rule types | **4** (Daily, Weekly, Rest Day, Holiday) |
| Shift types | **3** (ELAPSED, PUNCH, FLEX) |

---

## 6 Capabilities cốt lõi

### 1. Leave Policy Engine linh hoạt
Hệ thống rule 3-level (Class → Type → Rule) với 8 loại rule độc lập, có thể combine tự do. HR chỉ cần định nghĩa rule một lần và bind vào nhiều leave type, thay vì copy-paste policy cho từng nhóm nhân viên.

→ Chi tiết: [02 · Quản lý Nghỉ phép](./02-absence-management.md)

### 2. Immutable Leave Balance Ledger
Mọi thay đổi balance (allocation, accrual, usage, carryover, expiry) đều được ghi vào ledger bất biến. Không có gì bị xóa hay sửa trực tiếp — mọi correction đều là REVERSAL movement. Đảm bảo audit trail hoàn hảo và tuân thủ compliance.

→ Chi tiết: [02 · Quản lý Nghỉ phép](./02-absence-management.md)

### 3. 6-Level Hierarchical Scheduling
Thay vì tạo lịch thủ công, TA cho phép xây dựng schedule từ các building blocks tái sử dụng được. Có thể cấu hình một lần và tự động generate roster cho hàng nghìn nhân viên, bao gồm cả 24/7 rotating crews với nhiều đội xoay vòng.

→ Chi tiết: [03 · Kiến trúc Lịch làm việc](./03-shift-scheduling-architecture.md)

### 4. Automatic Attendance Exception Detection
Ngay khi nhân viên clock in/out, hệ thống so sánh với lịch dự kiến và phát hiện exception (trễ, về sớm, quên chấm). Grace period và rounding rules được cấu hình linh hoạt. Manager nhận notification tức thì.

→ Chi tiết: [04 · Chấm công & Timesheet](./04-attendance-timesheet.md)

### 5. Multi-Rule Overtime Calculation
Tính overtime tự động theo nhiều rule đồng thời: Daily OT (>8h/ngày), Weekly OT (>40h/tuần), Holiday OT — với multiplier khác nhau. Hệ thống áp dụng đúng rule, tránh tính trùng, và gửi kết quả trực tiếp cho Payroll.

→ Chi tiết: [04 · Chấm công & Timesheet](./04-attendance-timesheet.md)

### 6. Event-Driven Integration
TA phát sự kiện (events) mỗi khi có thay đổi quan trọng (leave approved, timesheet submitted, roster generated). Các module khác (Payroll, Calendar, Notification) subscribe và xử lý tự động — không cần sync thủ công.

→ Chi tiết: [05 · Approval & Tích hợp](./05-approval-integration.md)

---

## Business Value & Success Metrics

**Efficiency**:
- Giảm **80%** thời gian HR xử lý leave requests thủ công
- Loại bỏ hoàn toàn timesheets giấy và chấm công bằng sổ tay
- Manager tạo lịch ca tuần mới trong **dưới 15 phút** thay vì vài giờ

**Accuracy**:
- **99%** độ chính xác tracking chấm công (vs ~85% thủ công)
- **95%** giảm lỗi tính balance nghỉ phép
- **95%** giảm lỗi liên quan đến dữ liệu thời gian trong payroll

**Compliance**:
- 100% tuân thủ leave policy — không có exception cố ý
- Audit trail đầy đủ cho mọi giao dịch balance
- Tracking giờ làm việc tuân thủ luật lao động

**Cost Control**:
- Giảm **30%** chi phí overtime qua lập kế hoạch ca tốt hơn
- Phát hiện sớm attendance issues trước khi thành vi phạm nghiêm trọng
- Giảm overstaffing/understaffing qua coverage visibility

**Employee Experience**:
- Self-service: nhân viên tự xem balance, request leave, xem lịch ca
- Transparency: status request real-time, không cần hỏi HR
- Flexibility: shift swap và bid mở shift trống

---

## Alignment với thị trường

TA Module được thiết kế tương đương với các hệ thống HCM hàng đầu:

| Hệ thống | Khái niệm tương đương | Độ tương đồng |
|---------|-----------------------|:------------:|
| **Workday HCM** | Time Off, Absence Management, Scheduling | ~90% |
| **Oracle HCM Cloud** | Absence Management, Time & Labor | ~90% |
| **SAP SuccessFactors** | Time Off, Time Tracking, Scheduling | ~85% |
| **Kronos/UKG** | Absence, Workforce Scheduler | ~80% |

Sự tương đồng này có nghĩa là:
- Dữ liệu migration từ các hệ thống trên khả thi và có lộ trình rõ ràng
- Best practices của thị trường đã được tích hợp vào thiết kế
- HR/Admin có kinh nghiệm Workday/Oracle sẽ dễ làm quen

---

## Integration Map

```
                    TA Module
                       │
        ┌──────────────┼──────────────────┐
        ↑              ↓                  ↓
  CO Module       PR (Payroll)      TR (Total Rewards)
  (cung cấp)      (nhận từ TA)       (nhận từ TA)
  Worker data     Leave deductions   Overtime pay
  Org hierarchy   Time & OT data     Shift differentials
  Eligibility     Pay period close   Premium pay

  ← Time Clock devices (real-time clock events)
  ← Mobile Apps (clock-in, requests)
  → Calendar systems (Google, Outlook sync)
  → Notification (Email, SMS, Push)
```

---

*Nguồn: tổng hợp từ `01-concept-overview.md`*  
*← [README](./README.md) · [02 Quản lý Nghỉ phép →](./02-absence-management.md)*
