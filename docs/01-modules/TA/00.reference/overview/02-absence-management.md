# TA Module — Quản lý Nghỉ phép (Absence Management)

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-05  
**Đối tượng**: HR Administrator, Business Stakeholder, Manager

---

## Tổng quan

**Absence Management** là sub-module quản lý toàn bộ vòng đời nghỉ phép của nhân viên: từ việc HR cấu hình leave policy, đến nhân viên xin nghỉ, manager phê duyệt, và hệ thống tự động cập nhật balance.

Thiết kế của Absence Management trong xTalent dựa trên 3 nguyên tắc cốt lõi:
1. **Policy linh hoạt** — cấu hình bằng rule binding, không hardcode
2. **Balance minh bạch** — immutable ledger, mọi thay đổi đều có dấu vết
3. **Eligibility tập trung** — điều kiện hưởng phép được quản lý ở CO module, không duplicate

---

## Kiến trúc Leave Policy: 3-Level Hierarchy

```
Level 1: LeaveClass
  (Paid Time Off · Unpaid Leave · Statutory Leave)
         │
         ├── Level 2: LeaveType
         │     (Annual Leave · Sick Leave · Maternity Leave · Bereavement...)
         │            │
         │            └── Level 3: LeaveRule (bound via Priority)
         │                  ┌─────────────────────────┐
         │                  │ EligibilityRule          │
         │                  │ ValidationRule           │
         │                  │ AccrualRule              │
         │                  │ CarryoverRule            │
         │                  │ LimitRule                │
         │                  │ OverdraftRule            │
         │                  │ ProrationRule            │
         │                  │ RoundingRule             │
         │                  └─────────────────────────┘
```

**Priority-based resolution**: Khi có nhiều rule cùng loại, rule có priority cao hơn sẽ override. Cho phép:
- Rule ở cấp **Class** áp dụng cho tất cả leave types trong class đó
- Rule ở cấp **Type** override rule của class cho type cụ thể
- Rule ở cấp **Request** (runtime) override tất cả

---

## 8 Loại Leave Rule

| Rule | Mục đích | Ví dụ |
|------|---------|-------|
| **EligibilityRule** | Ai được dùng leave type này? | Chỉ nhân viên đã làm ≥ 6 tháng mới được Annual Leave |
| **ValidationRule** | Ràng buộc khi tạo request | Phải báo trước 3 ngày; Không quá 14 ngày liên tiếp |
| **AccrualRule** | Leave được tích lũy như thế nào? | 1.67 ngày/tháng; Tăng theo thâm niên |
| **CarryoverRule** | Xử lý balance thừa cuối kỳ | Tối đa carry 5 ngày sang năm sau; Phần còn lại expire |
| **LimitRule** | Giới hạn sử dụng | Tối đa 3 ngày nghỉ ốm/tháng không cần giấy tờ |
| **OverdraftRule** | Cho phép balance âm không? | Cho phép overdraft tối đa 5 ngày (trừ vào kỳ phép sau) |
| **ProrationRule** | Tính phần lẻ khi nhân viên mới join/rời | Nhân viên join ngày 15/1 → nhận 50% leave tháng 1 |
| **RoundingRule** | Làm tròn số ngày lẻ | Làm tròn lên 0.5 ngày gần nhất |

> **Hybrid Eligibility Model**: `EligibilityRule` trong TA được tích hợp với **CO Eligibility Engine** — điều kiện được định nghĩa một lần trong Core module và tái sử dụng cho Leave, Benefits, Bonus mà không duplicate logic.

---

## Leave Balance Ledger — Immutable Pattern

### Balance Formula

```
Available = Allocated + CarriedOver + Adjusted − Used − Pending − Expired
```

### Kiến trúc Ledger

```
LeaveBalance (snapshot hiện tại)
      │
      ├── Trường: total_allocated, carried_over, accrued
      ├── Trường: used, pending, expired
      └── Trường: available (computed)
           │
           ↑ Cập nhật bởi
           │
LeaveMovement (bất biến — never deleted)
      │
      ├── ALLOCATION   → +balance (cấp phép đầu kỳ)
      ├── ACCRUAL      → +balance (tích lũy định kỳ)
      ├── USAGE        → −balance (sau khi request approved)
      ├── ADJUSTMENT   → ±balance (HR điều chỉnh thủ công)
      ├── CARRYOVER    → +balance (chuyển từ kỳ trước)
      ├── EXPIRY       → −balance (balance hết hạn)
      ├── PAYOUT       → −balance (thanh toán tiền phép)
      └── REVERSAL     → ±balance (đính chính movement trước)
```

**Tại sao immutable?**
- Mọi correction đều phải tạo REVERSAL movement — không bao giờ sửa trực tiếp
- Luôn có thể reconstruct lại balance tại bất kỳ thời điểm nào từ ledger
- Tuân thủ audit requirements và financial compliance

### LeaveReservation — Reservation System

Khi nhân viên tạo request (chưa approved), hệ thống tạo **LeaveReservation** ngay lập tức:

```
Request Created → LeaveReservation (hold balance)
                → LeaveBalance: pending += X, available -= X

Request Approved → LeaveMovement (USAGE, -X)
                 → LeaveBalance: used += X, pending -= X
                 → LeaveReservation: released

Request Rejected → LeaveBalance: pending -= X, available += X  (restored)
                 → LeaveReservation: released
                 → NO LeaveMovement created
```

**Lợi ích**: Ngăn chặn double-booking — nhân viên không thể request 2 leave cùng lúc cho cùng ngày, dù manager chưa approve cái nào.

---

## Vòng đời Leave Request

```
DRAFT ──→ PENDING ──→ APPROVED ──→ (auto-complete sau ngày nghỉ)
                 └──→ REJECTED
                 └──→ WITHDRAWN (nhân viên rút lại)
                 └──→ CANCELLED (HR/Manager hủy sau approved)
```

### Sequence diagram tóm tắt

```
Employee          System              Manager
   │                │                    │
   ├──[Submit]─────→│                    │
   │                ├──Check Balance──→  │
   │                ├──Validate Rules──→ │
   │                ├──Create Reservation│
   │                ├──Send Notification─┤
   │                │                    │
   │                │           ←─[Approve]─┤
   │                ├──Create Movement   │
   │                ├──Release Reservation│
   │←─[Notify]──────┤                    │
   │                │                    │
```

### Các variation quan trọng

**Auto-Approval**: Sick leave ≤ 1 ngày + đủ balance → hệ thống tự approve, không cần manager.

**Multi-Level Approval**: Nghỉ > 5 ngày → cần cả Direct Manager VÀ Department Head phê duyệt.

**Blackout Periods**: HR có thể cấu hình khoảng thời gian không được nghỉ (cuối tháng, mùa cao điểm).

---

## Period Profiles — Cơ sở tính leave year

Leave balance được tính theo **Period Profile** — không hardcode theo calendar year:

| Period Type | Mô tả | Ví dụ dùng |
|-------------|-------|-----------|
| `CALENDAR_YEAR` | 1/1 đến 31/12 | Hầu hết doanh nghiệp |
| `FISCAL_YEAR` | Theo năm tài chính | Công ty có FY khác calendar year |
| `HIRE_ANNIVERSARY` | Từ ngày gia nhập | Nhân viên A: 15/3 → 14/3 năm sau |
| `CUSTOM` | Bất kỳ ngày cố định | Ví dụ: 1/6 → 31/5 |

---

## Kịch bản minh họa

**Kịch bản**: Nhân viên mới join ngày 1/7, xin 5 ngày Annual Leave vào tháng 9.

```
1. JOIN (1/7): ProrationRule → Allocated = 10 ngày (50% của 20 ngày)
   Movement: ALLOCATION +10 days → Balance: Available = 10

2. ACCRUAL (31/7): AccrualRule → 1.67 ngày
   Movement: ACCRUAL +1.67 → Balance: Available = 11.67

3. REQUEST (15/9): Xin 5 ngày (25/9 - 29/9)
   Reservation created → Balance: Available = 6.67, Pending = 5

4. APPROVED (16/9): Manager phê duyệt
   Movement: USAGE -5 → Balance: Available = 6.67, Used = 5, Pending = 0

5. CARRYOVER (31/12): CarryoverRule → max 3 ngày carry sang năm sau
   Movement: CARRYOVER +3 (new period), EXPIRY -3.67 (current period)
```

---

## Entities chính

| Entity | Vai trò |
|--------|---------|
| **LeaveClass** | Nhóm leave types cùng loại (Paid / Unpaid / Statutory) |
| **LeaveType** | Loại phép cụ thể (Annual, Sick, Maternity...) |
| **LeaveRule** | Rule độc lập, reusable, bind theo priority |
| **LeaveRequest** | Yêu cầu nghỉ phép của nhân viên |
| **LeaveBalance** | Snapshot balance hiện tại (per employee, per leave type) |
| **LeaveMovement** | Immutable ledger entry — never deleted |
| **LeaveReservation** | Tạm hold balance khi request pending |

---

*Nguồn: tổng hợp từ `03-leave-policy-configuration-guide.md` và `04-leave-balance-ledger-guide.md`*  
*← [README](./README.md) · [01 Executive Summary](./01-executive-summary.md) · [03 Scheduling →](./03-shift-scheduling-architecture.md)*
