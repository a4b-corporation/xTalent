# Feature List: Time & Absence Module (v2.0)

> Danh sách chi tiết các tính năng của module Time & Absence (TA) — Phiên bản 2.0
> Tổ chức theo Sub-module → Category → Feature Group → Feature

## Thông tin tài liệu

| Field | Value |
|-------|-------|
| **Module** | Time & Absence (TA) |
| **Version** | 2.0 |
| **Tổng số features** | 110 |
| **Số sub-modules** | 2 |
| **Số categories** | 17 |
| **Ngày tạo** | 2026-03-10 |
| **Trạng thái** | Draft |

---

## Tổng quan kiến trúc module

```
Time & Absence (TA)
├── Absence Management (ABS)
│   ├── Leave Request Management
│   ├── Leave Approval
│   ├── Leave Balance Management
│   ├── Leave Accrual
│   ├── Leave Carryover
│   └── Leave Policy Rules
├── Time & Attendance (ATT)
│   ├── Shift Scheduling (6-Level Hierarchy)
│   ├── Time Tracking
│   ├── Attendance Exceptions
│   ├── Timesheet Management
│   ├── Overtime Management
│   └── Schedule Overrides
└── Shared Components
    ├── Period Profiles
    ├── Holiday Calendar
    └── Approval Workflows
```

---

## Sub-module 1: Absence Management (ABS)

**Mục đích**: Quản lý toàn bộ vòng đời nghỉ phép của nhân viên — từ định nghĩa chính sách, tích lũy số dư, yêu cầu nghỉ, phê duyệt, đến theo dõi sử dụng và xử lý cuối kỳ.

**Số lượng features**: 50

### Category ABS-01: Leave Request Management

**Mục đích**: Quản lý việc tạo, gửi, và theo dõi đơn xin nghỉ phép.

| ID | Feature Name | Priority | Status | Description |
|----|-------------|----------|--------|-------------|
| ABS-LR-001 | Create Leave Request | P0 | Specified | Nhân viên tạo yêu cầu nghỉ phép cho ngày cụ thể |
| ABS-LR-002 | Submit Leave Request for Approval | P0 | Specified | Nhân viên gửi đơn xin nghỉ để quản lý phê duyệt |
| ABS-LR-003 | View Leave Request Status | P0 | Specified | Nhân viên xem trạng thái các đơn đã gửi |
| ABS-LR-004 | Withdraw Leave Request | P0 | Specified | Nhân viên rút lại đơn đang chờ phê duyệt |
| ABS-LR-005 | Half-Day Leave Request | P0 | Specified | Hỗ trợ xin nghỉ nửa ngày (sáng/chiều) |
| ABS-LR-006 | Hourly Leave Request | P0 | Specified | Hỗ trợ xin nghỉ theo giờ |
| ABS-LR-007 | Leave Request with Attachments | P0 | Specified | Đính kèm tài liệu (giấy khám bệnh, etc.) |
| ABS-LR-008 | Leave Request Comments | P0 | Specified | Thêm ghi chú/lý do vào đơn nghỉ |
| ABS-LR-009 | Cancel Approved Request | P1 | Specified | Hủy đơn đã được phê duyệt (với workflow) |
| ABS-LR-010 | Modify Pending Request | P1 | Specified | Sửa đổi đơn đang chờ phê duyệt |

**Chi tiết features**:

#### ABS-LR-001: Create Leave Request

```yaml
id: ABS-LR-001
name: Create Leave Request
group: Leave Request Management
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn tạo yêu cầu nghỉ phép
  để có thể xin nghỉ cho kế hoạch cá nhân.

acceptance_criteria:
  - Chọn loại nghỉ từ catalog (Annual, Sick, Maternity, etc.)
  - Hiển thị số dư hiện tại của loại nghỉ
  - Chọn khoảng ngày (start date, end date)
  - Tự động tính số ngày làm việc (loại trừ cuối tuần, lễ)
  - Validate số dư đủ trước khi cho phép submit
  - Tạo reservation tạm giữ số dư

dependencies:
  - ABS-BAL-001 (View Leave Balance)
  - ABS-VAL-001 (Validation Rules)

related_business_rules:
  - BR-ABS-001: Leave request must have valid leave type
  - BR-ABS-002: Leave request cannot exceed available balance
  - BR-ABS-010: Leave request cannot overlap with existing approved requests
```

#### ABS-LR-002: Submit Leave Request for Approval

```yaml
id: ABS-LR-002
name: Submit Leave Request for Approval
group: Leave Request Management
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn gửi đơn xin nghỉ
  để quản lý có thể xem xét và phê duyệt.

acceptance_criteria:
  - Trạng thái đơn chuyển sang PENDING
  - Quản lý trực tiếp nhận notification
  - Số dư được reserve cho đến khi approve/reject
  - Email xác nhận gửi cho nhân viên

dependencies:
  - ABS-LR-001 (Create Leave Request)
  - ABS-APR-001 (Approve Leave Request)
```

#### ABS-LR-003: View Leave Request Status

```yaml
id: ABS-LR-003
name: View Leave Request Status
group: Leave Request Management
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn xem trạng thái đơn
  để biết đơn đã được phê duyệt hay chưa.

acceptance_criteria:
  - Hiển thị danh sách tất cả đơn theo thời gian
  - Trạng thái rõ ràng (DRAFT, PENDING, APPROVED, REJECTED, CANCELLED)
  - Lịch sử phê duyệt cho mỗi đơn
  - Filter theo trạng thái, loại nghỉ, khoảng ngày
```

#### ABS-LR-004: Withdraw Leave Request

```yaml
id: ABS-LR-004
name: Withdraw Leave Request
group: Leave Request Management
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn rút lại đơn nghỉ
  nếu kế hoạch thay đổi.

acceptance_criteria:
  - Chỉ withdraw được đơn ở trạng thái PENDING
  - Reserve được release ngay lập tức
  - Quản lý được notification
  - Ghi nhận lý do withdraw (optional)
```

#### ABS-LR-005: Half-Day Leave Request

```yaml
id: ABS-LR-005
name: Half-Day Leave Request
group: Leave Request Management
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn xin nghỉ nửa ngày
  để linh hoạt hơn trong công việc.

acceptance_criteria:
  - Chọn buổi sáng (AM) hoặc buổi chiều (PM)
  - Trừ 0.5 ngày từ số dư
  - Hiển thị half-day trên calendar
  - Cấu hình được cho mỗi loại nghỉ (có cho phép hay không)
```

#### ABS-LR-006: Hourly Leave Request

```yaml
id: ABS-LR-006
name: Hourly Leave Request
group: Leave Request Management
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn xin nghỉ theo giờ
  cho các việc cá nhân ngắn.

acceptance_criteria:
  - Chọn thời gian bắt đầu và kết thúc
  - Số dư tính bằng giờ (convert từ ngày)
  - Minimum duration (e.g., 1 giờ)
  - Tích hợp với attendance tracking
```

#### ABS-LR-007: Leave Request with Attachments

```yaml
id: ABS-LR-007
name: Leave Request with Attachments
group: Leave Request Management
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn đính kèm tài liệu
  để chứng minh lý do nghỉ.

acceptance_criteria:
  - Upload file (PDF, image, max 10MB)
  - Hiển thị danh sách file đính kèm
  - Yêu cầu bắt buộc với một số loại nghỉ (Sick > 3 days)
  - Quản lý xem được attachments khi phê duyệt
```

#### ABS-LR-008: Leave Request Comments

```yaml
id: ABS-LR-008
name: Leave Request Comments
group: Leave Request Management
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn thêm ghi chú
  để giải thích lý do nghỉ chi tiết hơn.

acceptance_criteria:
  - Thêm lý do khi tạo đơn (max 1000 chars)
  - Lịch sử comments cho mỗi đơn
  - Quản lý có thể thêm comments khi phê duyệt
```

#### ABS-LR-009: Cancel Approved Request

```yaml
id: ABS-LR-009
name: Cancel Approved Request
group: Leave Request Management
priority: P1
status: Specified
user_story: |
  Là nhân viên, tôi muốn hủy đơn đã approve
  nếu có việc đột xuất.

acceptance_criteria:
  - Hủy được đơn đã approve (trước ngày nghỉ)
  - Restore số dư
  - Notification cho quản lý
  - Cần workflow phê duyệt để cancel approved request
```

#### ABS-LR-010: Modify Pending Request

```yaml
id: ABS-LR-010
name: Modify Pending Request
group: Leave Request Management
priority: P1
status: Specified
user_story: |
  Là nhân viên, tôi muốn sửa đơn đang chờ
  để điều chỉnh ngày nghỉ.

acceptance_criteria:
  - Sửa được ngày, loại nghỉ khi đang PENDING
  - Re-validate sau khi sửa
  - Notification cho quản lý về thay đổi
```

---

### Category ABS-02: Leave Approval

**Mục đích**: Quản lý quy trình phê duyệt đơn nghỉ phép với hỗ trợ đa cấp và ủy quyền.

| ID | Feature Name | Priority | Status | Description |
|----|-------------|----------|--------|-------------|
| ABS-APR-001 | Approve Leave Request | P0 | Specified | Quản lý phê duyệt đơn nghỉ |
| ABS-APR-002 | Reject Leave Request | P0 | Specified | Quản lý từ chối đơn nghỉ |
| ABS-APR-003 | Multi-Level Approval | P0 | Specified | Phê duyệt nhiều cấp |
| ABS-APR-004 | Delegate Approval | P0 | Specified | Ủy quyền phê duyệt khi vắng mặt |
| ABS-APR-005 | Batch Approval | P0 | Specified | Phê duyệt hàng loạt |
| ABS-APR-006 | Approval Escalation | P1 | Specified | Tự động leo thang khi quá hạn |
| ABS-APR-007 | Approval Comments | P0 | Specified | Thêm nhận xét khi phê duyệt |
| ABS-APR-008 | View Approval History | P0 | Specified | Xem lịch sử phê duyệt |
| ABS-APR-009 | Conditional Approval Routing | P1 | Specified | Route đơn theo điều kiện |
| ABS-APR-010 | Parallel Approval | P1 | Specified | Phê duyệt song song |

**Chi tiết features**:

#### ABS-APR-001: Approve Leave Request

```yaml
id: ABS-APR-001
name: Approve Leave Request
group: Leave Approval
priority: P0
status: Specified
user_story: |
  Là quản lý, tôi muốn phê duyệt đơn nghỉ
  để nhân viên có thể nghỉ phép.

acceptance_criteria:
  - Xem lịch team trước khi phê duyệt
  - Xem số dư của nhân viên
  - Approval tạo movement trong ledger
  - Nhân viên được notification
  - Audit trail đầy đủ
```

#### ABS-APR-002: Reject Leave Request

```yaml
id: ABS-APR-002
name: Reject Leave Request
group: Leave Approval
priority: P0
status: Specified
user_story: |
  Là quản lý, tôi muốn từ chối đơn nghỉ
  nếu không đủ coverage.

acceptance_criteria:
  - Bắt buộc nhập lý do từ chối
  - Reserve được release
  - Nhân viên được notification với lý do
```

#### ABS-APR-003: Multi-Level Approval

```yaml
id: ABS-APR-003
name: Multi-Level Approval
group: Approval Workflow
priority: P0
status: Specified
user_story: |
  Là HR, tôi muốn cấu hình chuỗi phê duyệt nhiều cấp
  cho các đơn nghỉ dài.

acceptance_criteria:
  - Cấu hình approval chain theo loại nghỉ
  - Cấu hình theo threshold số ngày
  - Sequential approval (level 1 → level 2 → level 3)
  - Mỗi level có thể approve/reject
```

#### ABS-APR-004: Delegate Approval

```yaml
id: ABS-APR-004
name: Delegate Approval
group: Approval Workflow
priority: P0
status: Specified
user_story: |
  Là quản lý, tôi muốn ủy quyền phê duyệt
  khi tôi vắng mặt.

acceptance_criteria:
  - Ủy quyền cho người cụ thể trong khoảng thời gian
  - Delegate nhận notifications
  - Ủy quyền có thời hạn
  - Delegate có thể từ chối delegation
```

#### ABS-APR-005: Batch Approval

```yaml
id: ABS-APR-005
name: Batch Approval
group: Approval Workflow
priority: P0
status: Specified
user_story: |
  Là quản lý, tôi muốn phê duyệt nhiều đơn cùng lúc
  để tiết kiệm thời gian.

acceptance_criteria:
  - Chọn nhiều đơn pending
  - Phê duyệt/từ chối cùng lúc
  - Filter đơn theo criteria
  - Undo trong time window
```

#### ABS-APR-006: Approval Escalation

```yaml
id: ABS-APR-006
name: Approval Escalation
group: Approval Workflow
priority: P1
status: Specified
user_story: |
  Là hệ thống, tôi tự động leo thang đơn quá hạn
  để đảm bảo xử lý kịp thời.

acceptance_criteria:
  - Cấu hình SLA (e.g., 3 days pending)
  - Reminder notification trước khi escalate
  - Auto-escalate lên level cao hơn
  - Skip manager nếu cần
```

#### ABS-APR-007: Approval Comments

```yaml
id: ABS-APR-007
name: Approval Comments
group: Approval Workflow
priority: P0
status: Specified
user_story: |
  Là quản lý, tôi muốn thêm nhận xét
  khi phê duyệt/từ chối.

acceptance_criteria:
  - Thêm comments khi approve/reject
  - Comments hiển thị trong lịch sử
  - Nhân viên xem được comments
```

#### ABS-APR-008: View Approval History

```yaml
id: ABS-APR-008
name: View Approval History
group: Approval Workflow
priority: P0
status: Specified
user_story: |
  Là quản lý/nhân viên, tôi muốn xem lịch sử phê duyệt
  để biết tiến trình.

acceptance_criteria:
  - Hiển thị timeline approval
  - Ai approve, thời gian nào
  - Comments từ mỗi approver
```

#### ABS-APR-009: Conditional Approval Routing

```yaml
id: ABS-APR-009
name: Conditional Approval Routing
group: Approval Workflow
priority: P1
status: Specified
user_story: |
  Là HR, tôi muốn route đơn theo điều kiện
  để đúng người xử lý.

acceptance_criteria:
  - Route theo số ngày (>7 days → HR Director)
  - Route theo loại nghỉ (Maternity → HR Director)
  - Route theo cấp bậc nhân viên
```

#### ABS-APR-010: Parallel Approval

```yaml
id: ABS-APR-010
name: Parallel Approval
group: Approval Workflow
priority: P1
status: Specified
user_story: |
  Là HR, tôi muốn cấu hình phê duyệt song song
  để tăng tốc độ xử lý.

acceptance_criteria:
  - Nhiều approver cùng level nhận đơn
  - Tất cả phải approve hoặc majority
  - Hiển thị progress parallel approval
```

---

### Category ABS-03: Leave Balance Management

**Mục đích**: Quản lý số dư nghỉ phép theo thời gian thực với immutable ledger.

| ID | Feature Name | Priority | Status | Description |
|----|-------------|----------|--------|-------------|
| ABS-BAL-001 | View Leave Balance | P0 | Specified | Xem số dư nghỉ phép |
| ABS-BAL-002 | Balance Calculation | P0 | Specified | Tính toán số dư real-time |
| ABS-BAL-003 | Balance Movement History | P0 | Specified | Lịch sử biến động số dư |
| ABS-BAL-004 | Manual Balance Adjustment | P0 | Specified | Điều chỉnh số dư thủ công |
| ABS-BAL-005 | Future Balance Projection | P1 | Specified | Dự báo số dư tương lai |
| ABS-BAL-006 | Balance by Period | P0 | Specified | Số dư theo kỳ (year/period) |
| ABS-BAL-007 | Export Balance Statement | P1 | Specified | Xuất bảng kê số dư |
| ABS-BAL-008 | Team Balance Overview | P1 | Specified | Xem số dư team (manager view) |

**Chi tiết features**:

#### ABS-BAL-001: View Leave Balance

```yaml
id: ABS-BAL-001
name: View Leave Balance
group: Leave Balance Management
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn xem số dư nghỉ phép
  để biết có thể nghỉ bao nhiêu ngày.

acceptance_criteria:
  - Hiển thị tổng số dư theo loại nghỉ
  - Breakdown: Opening + Earned - Used - Pending = Available
  - Hiển thị số dư đã carryover từ năm trước
  - As-of-date balance (xem số dư tại ngày cụ thể)
```

#### ABS-BAL-002: Balance Calculation

```yaml
id: ABS-BAL-002
name: Balance Calculation
group: Leave Balance Management
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi tính số dư available theo công thức
  để đảm bảo chính xác.

acceptance_criteria:
  - Formula: available = total + carryover + adjusted - used - pending - expired
  - Real-time calculation
  - Chính xác đến 2 chữ số thập phân
  - Recalculate sau mỗi movement
```

#### ABS-BAL-003: Balance Movement History

```yaml
id: ABS-BAL-003
name: Balance Movement History
group: Leave Balance Management
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn xem lịch sử biến động số dư
  để hiểu rõ source of changes.

acceptance_criteria:
  - Hiển thị tất cả movements (allocation, accrual, usage, adjustment)
  - Hiển thị ngày, loại, số lượng, lý do
  - Filter theo khoảng ngày
  - Không thể sửa/xóa movement (immutable ledger)
```

#### ABS-BAL-004: Manual Balance Adjustment

```yaml
id: ABS-BAL-004
name: Manual Balance Adjustment
group: Leave Balance Management
priority: P0
status: Specified
user_story: |
  Là HR, tôi muốn điều chỉnh số dư
  để sửa lỗi hoặc特殊情况.

acceptance_criteria:
  - HR có thể thêm hoặc trừ ngày
  - Bắt buộc nhập lý do
  - Tạo ADJUSTMENT movement
  - Nhân viên được notification
```

#### ABS-BAL-005: Future Balance Projection

```yaml
id: ABS-BAL-005
name: Future Balance Projection
group: Leave Balance Management
priority: P1
status: Specified
user_story: |
  Là nhân viên, tôi muốn xem số dư dự kiến
  để lên kế hoạch nghỉ.

acceptance_criteria:
  - Projection với future accruals
  - Hiển thị số dư tại ngày tương lai
  - Include pending requests
```

#### ABS-BAL-006: Balance by Period

```yaml
id: ABS-BAL-006
name: Balance by Period
group: Leave Balance Management
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn xem số dư theo kỳ
  để tracking theo năm.

acceptance_criteria:
  - Hiển thị số dư theo leave year
  - So sánh số dư giữa các năm
  - Hiển thị carryover từ năm trước sang năm sau
```

#### ABS-BAL-007: Export Balance Statement

```yaml
id: ABS-BAL-007
name: Export Balance Statement
group: Leave Balance Management
priority: P1
status: Specified
user_story: |
  Là nhân viên, tôi muốn xuất bảng kê số dư
  để lưu trữ hoặc in.

acceptance_criteria:
  - Export PDF/Excel
  - Include full breakdown và movement history
  - Date range customizable
```

#### ABS-BAL-008: Team Balance Overview

```yaml
id: ABS-BAL-008
name: Team Balance Overview
group: Leave Balance Management
priority: P1
status: Specified
user_story: |
  Là quản lý, tôi muốn xem số dư của team
  để planning coverage.

acceptance_criteria:
  - Xem số dư tất cả thành viên trong team
  - Filter theo loại nghỉ
  - Alert cho balance thấp (dưới threshold)
```

---

### Category ABS-04: Leave Accrual

**Mục đích**: Quản lý tích lũy nghỉ phép tự động theo kỳ.

| ID | Feature Name | Priority | Status | Description |
|----|-------------|----------|--------|-------------|
| ABS-ACR-001 | Upfront Allocation | P0 | Specified | Cấp phát toàn bộ entitlement đầu năm |
| ABS-ACR-002 | Monthly Accrual | P0 | Specified | Tích lũy hàng tháng (e.g., 1.67 days/month) |
| ABS-ACR-003 | Tenure-Based Accrual | P0 | Specified | Tích lũy theo thâm niên |
| ABS-ACR-004 | Accrual Batch Job | P0 | Specified | Batch job xử lý accrual hàng loạt |
| ABS-ACR-005 | Accrual History | P0 | Specified | Lịch sử accrual |
| ABS-ACR-006 | Manual Accrual Run | P1 | Specified | Chạy accrual thủ công |

**Chi tiết features**:

#### ABS-ACR-001: Upfront Allocation

```yaml
id: ABS-ACR-001
name: Upfront Allocation
group: Leave Accrual
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi cấp phát toàn bộ entitlement
  vào đầu năm để nhân viên biết số dư.

acceptance_criteria:
  - Chạy vào ngày đầu của leave year
  - Allocate dựa trên tenure và employment type
  - Prorate cho nhân viên vào giữa năm
  - Tạo ALLOCATION movement
```

#### ABS-ACR-002: Monthly Accrual

```yaml
id: ABS-ACR-002
name: Monthly Accrual
group: Leave Accrual
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi tích lũy nghỉ hàng tháng
  để nhân viên earned leave gradually.

acceptance_criteria:
  - Chạy vào ngày 1 mỗi tháng
  - Accrue số lượng cấu hình (e.g., 1.67 days)
  - Respect accrual cap nếu có
  - Tạo ACCRUAL movement
```

#### ABS-ACR-003: Tenure-Based Accrual

```yaml
id: ABS-ACR-003
name: Tenure-Based Accrual
group: Leave Accrual
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi tăng allocation theo thâm niên
  để reward nhân viên lâu năm.

acceptance_criteria:
  - Different rates cho tenure brackets (0-5 years, 5-10 years, 10+ years)
  - Tự động adjust vào anniversary
  - Cấu hình được tenure brackets
```

#### ABS-ACR-004: Accrual Batch Job

```yaml
id: ABS-ACR-004
name: Accrual Batch Job
group: Leave Accrual
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi chạy batch job để xử lý accrual
  cho tất cả nhân viên.

acceptance_criteria:
  - Scheduled job (cron expression)
  - Process all eligible employees
  - Error handling và retry logic
  - Logging đầy đủ
```

#### ABS-ACR-005: Accrual History

```yaml
id: ABS-ACR-005
name: Accrual History
group: Leave Accrual
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn xem lịch sử accrual
  để tracking earned leave.

acceptance_criteria:
  - Hiển thị tất cả accrual runs
  - Ngày, số lượng, loại accrual
  - Filter theo kỳ
```

#### ABS-ACR-006: Manual Accrual Run

```yaml
id: ABS-ACR-006
name: Manual Accrual Run
group: Leave Accrual
priority: P1
status: Specified
user_story: |
  Là HR, tôi muốn chạy accrual thủ công
  để fix issues hoặc reprocess.

acceptance_criteria:
  - Trigger manual accrual run
  - Select employee hoặc all
  - Preview trước khi run
```

---

### Category ABS-05: Leave Carryover

**Mục đích**: Quản lý chuyển số dư và hết hạn cuối kỳ.

| ID | Feature Name | Priority | Status | Description |
|----|-------------|----------|--------|-------------|
| ABS-CAR-001 | Limited Carryover | P0 | Specified | Carryover có giới hạn |
| ABS-CAR-002 | Unlimited Carryover | P0 | Specified | Carryover không giới hạn |
| ABS-CAR-003 | Carryover Expiry | P0 | Specified | Số dư carryover hết hạn sau X tháng |
| ABS-CAR-004 | Leave Payout | P0 | Specified | Thanh toán ngày nghỉ không sử dụng |
| ABS-CAR-005 | Year-End Processing | P0 | Specified | Xử lý cuối năm tự động |
| ABS-CAR-006 | Carryover Preview | P1 | Specified | Preview trước khi process carryover |
| ABS-CAR-007 | Forfeiture Report | P1 | Specified | Báo cáo ngày hết hạn |
| ABS-CAR-008 | Rollover Rules | P0 | Specified | Quy tắc rollover theo loại nghỉ |

**Chi tiết features**:

#### ABS-CAR-001: Limited Carryover

```yaml
id: ABS-CAR-001
name: Limited Carryover
group: Leave Carryover
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi carryover tối đa X ngày
  sang năm mới.

acceptance_criteria:
  - Carries min(unused, max_carryover)
  - Expire số dư vượt quá
  - Tạo CARRYOVER và EXPIRY movements
```

#### ABS-CAR-002: Unlimited Carryover

```yaml
id: ABS-CAR-002
name: Unlimited Carryover
group: Leave Carryover
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi carryover tất cả ngày không sử dụng
  sang năm mới.

acceptance_criteria:
  - Không giới hạn carryover
  - Tất cả unused days được carry
```

#### ABS-CAR-003: Carryover Expiry

```yaml
id: ABS-CAR-003
name: Carryover Expiry
group: Leave Carryover
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi expire số dư carryover
  sau X tháng.

acceptance_criteria:
  - Track expiry date cho carried days
  - Expire vào ngày cấu hình
  - Tạo EXPIRY movement
  - Notification trước khi expire
```

#### ABS-CAR-004: Leave Payout

```yaml
id: ABS-CAR-004
name: Leave Payout
group: Leave Carryover
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi thanh toán ngày không sử dụng
  thay vì carryover.

acceptance_criteria:
  - Tính payout amount
  - Tạo PAYOUT movement
  - Gửi thông tin sang payroll
```

#### ABS-CAR-005: Year-End Processing

```yaml
id: ABS-CAR-005
name: Year-End Processing
group: Leave Carryover
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi xử lý cuối năm
  để carryover và expire.

acceptance_criteria:
  - Scheduled job vào cuối năm
  - Process carryover và expiry
  - Generate movements
  - Close period
```

#### ABS-CAR-006: Carryover Preview

```yaml
id: ABS-CAR-006
name: Carryover Preview
group: Leave Carryover
priority: P1
status: Specified
user_story: |
  Là HR, tôi muốn preview kết quả carryover
  trước khi process.

acceptance_criteria:
  - Preview bao nhiêu ngày sẽ carryover
  - Bao nhiêu ngày expire
  - Per employee breakdown
```

#### ABS-CAR-007: Forfeiture Report

```yaml
id: ABS-CAR-007
name: Forfeiture Report
group: Leave Carryover
priority: P1
status: Specified
user_story: |
  Là HR, tôi muốn xem báo cáo ngày hết hạn
  để tracking.

acceptance_criteria:
  - Report showing forfeited days
  - Per employee, per leave type
  - Export Excel/PDF
```

#### ABS-CAR-008: Rollover Rules

```yaml
id: ABS-CAR-008
name: Rollover Rules
group: Leave Carryover
priority: P0
status: Specified
user_story: |
  Là HR, tôi muốn cấu hình quy tắc rollover
  theo loại nghỉ.

acceptance_criteria:
  - Cấu hình per leave type
  - Allow/block carryover
  - Max carryover days
  - Expiry months
```

---

### Category ABS-06: Leave Policy Rules

**Mục đích**: Quản lý chính sách và quy tắc nghỉ phép linh hoạt.

| ID | Feature Name | Priority | Status | Description |
|----|-------------|----------|--------|-------------|
| ABS-POL-001 | Eligibility Rules | P0 | Specified | Quy tắc đủ điều kiện nghỉ |
| ABS-POL-002 | Validation Rules | P0 | Specified | Validate leave requests |
| ABS-POL-003 | Limit Rules | P0 | Specified | Giới hạn sử dụng nghỉ |
| ABS-POL-004 | Overdraft Rules | P0 | Specified | Cho phép số dư âm |
| ABS-POL-005 | Proration Rules | P0 | Specified | Tính pro-rata |
| ABS-POL-006 | Rounding Rules | P0 | Specified | Quy tắc làm tròn |
| ABS-POL-007 | Policy Library UI | P1 | Specified | UI quản lý policy |
| ABS-POL-008 | Priority-Based Resolution | P1 | Specified | Giải quyết xung đột policy |
| ABS-POL-009 | Blackout Periods | P0 | Specified | Thời gian không được nghỉ |
| ABS-POL-010 | Advance Notice Rules | P0 | Specified | Quy tắc báo trước |
| ABS-POL-011 | Documentation Requirements | P0 | Specified | Yêu cầu tài liệu |
| ABS-POL-012 | Concurrent Leave Rules | P0 | Specified | Quy tắc nghỉ cùng lúc |

**Chi tiết features**:

#### ABS-POL-001: Eligibility Rules

```yaml
id: ABS-POL-001
name: Eligibility Rules
group: Leave Policy Rules
priority: P0
status: Specified
user_story: |
  Là HR, tôi muốn cấu hình eligibility rules
  để xác định ai được sử dụng loại nghỉ.

acceptance_criteria:
  - Sử dụng EligibilityProfile từ Core module
  - Inline criteria option
  - Support tenure, employment type, location, department, job level
  - Rule priority handling
```

#### ABS-POL-002: Validation Rules

```yaml
id: ABS-POL-002
name: Validation Rules
group: Leave Policy Rules
priority: P0
status: Specified
user_story: |
  Là HR, tôi muốn enforce advance notice và blackout periods.

acceptance_criteria:
  - Advance notice validation (e.g., 7 days trước khi nghỉ)
  - Max consecutive days
  - Blackout period validation
  - Documentation requirements
```

#### ABS-POL-003: Limit Rules

```yaml
id: ABS-POL-003
name: Limit Rules
group: Leave Policy Rules
priority: P0
status: Specified
user_story: |
  Là HR, tôi muốn đặt max days per year và per request.

acceptance_criteria:
  - Max per year
  - Max per request
  - Min per request
  - Max requests per period
```

#### ABS-POL-004: Overdraft Rules

```yaml
id: ABS-POL-004
name: Overdraft Rules
group: Leave Policy Rules
priority: P0
status: Specified
user_story: |
  Là HR, tôi muốn cho phép advance leave với overdraft.

acceptance_criteria:
  - Cấu hình overdraft limit
  - Requires approval
  - Auto-repayment từ future accruals
```

#### ABS-POL-005: Proration Rules

```yaml
id: ABS-POL-005
name: Proration Rules
group: Leave Policy Rules
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi prorate allocation
  dựa trên start date và schedule.

acceptance_criteria:
  - Start date proration (mid-year joiners)
  - Schedule proration (part-time)
  - Configurable proration method (Calendar/Work Days/Monthly)
```

#### ABS-POL-006: Rounding Rules

```yaml
id: ABS-POL-006
name: Rounding Rules
group: Leave Policy Rules
priority: P0
status: Specified
user_story: |
  Là HR, tôi muốn cấu hình rounding rules
  cho fractional amounts.

acceptance_criteria:
  - Round up, down, hoặc nearest
  - Round to nearest half hoặc quarter
  - No rounding option
```

#### ABS-POL-007: Policy Library UI

```yaml
id: ABS-POL-007
name: Policy Library UI
group: Leave Policy Rules
priority: P1
status: Specified
user_story: |
  Là HR, tôi muốn UI để quản lý policies.

acceptance_criteria:
  - Danh sách policies theo leave type/class
  - Tạo/sửa/xóa policy
  - Bind rules vào policy
  - Preview policy impact
```

#### ABS-POL-008: Priority-Based Resolution

```yaml
id: ABS-POL-008
name: Priority-Based Resolution
group: Leave Policy Rules
priority: P1
status: Specified
user_story: |
  Là hệ thống, tôi resolve xung đột policy
  theo priority.

acceptance_criteria:
  - Rule priority handling
  - Class-level vs Type-level resolution
  - Override logic
```

#### ABS-POL-009: Blackout Periods

```yaml
id: ABS-POL-009
name: Blackout Periods
group: Leave Policy Rules
priority: P0
status: Specified
user_story: |
  Là HR, tôi muốn định nghĩa blackout periods
  khi nhân viên không thể nghỉ.

acceptance_criteria:
  - Define blackout date ranges
  - Per leave type hoặc global
  - Error/warning khi request trong blackout
  - Recurring blackout periods
```

#### ABS-POL-010: Advance Notice Rules

```yaml
id: ABS-POL-010
name: Advance Notice Rules
group: Leave Policy Rules
priority: P0
status: Specified
user_story: |
  Là HR, tôi muốn yêu cầu báo trước
  khi xin nghỉ.

acceptance_criteria:
  - Min days trước khi start leave
  - Per leave type
  - Warning/error nếu không đủ notice
```

#### ABS-POL-011: Documentation Requirements

```yaml
id: ABS-POL-011
name: Documentation Requirements
group: Leave Policy Rules
priority: P0
status: Specified
user_story: |
  Là HR, tôi muốn yêu cầu tài liệu
  cho một số loại nghỉ.

acceptance_criteria:
  - Required docs per leave type
  - Threshold days (e.g., Sick > 3 days cần medical cert)
  - Block submit nếu thiếu docs
```

#### ABS-POL-012: Concurrent Leave Rules

```yaml
id: ABS-POL-012
name: Concurrent Leave Rules
group: Leave Policy Rules
priority: P0
status: Specified
user_story: |
  Là HR, tôi muốn cấu hình allowed combinations
  cho concurrent absences.

acceptance_criteria:
  - Allowed combinations matrix
  - Priority rules cho payroll
  - Balance deduction per type
```

---

## Sub-module 2: Time & Attendance (ATT)

**Mục đích**: Quản lý chấm công, lịch làm việc, timesheet, và overtime.

**Số lượng features**: 60

### Category ATT-01: Shift Scheduling (6-Level Hierarchy)

**Mục đích**: Quản lý xếp ca làm việc theo kiến trúc phân cấp 6 mức.

| ID | Feature Name | Priority | Status | Description |
|----|-------------|----------|--------|-------------|
| ATT-SCH-001 | Configure Time Segments (Level 1) | P1 | Specified | Định nghĩa time segments (WORK, BREAK, MEAL) |
| ATT-SCH-002 | Configure Shift Definitions (Level 2) | P1 | Specified | Tạo ca từ segments |
| ATT-SCH-003 | Configure Day Models (Level 3) | P1 | Specified | Template ngày làm việc |
| ATT-SCH-004 | Configure Pattern Templates (Level 4) | P1 | Specified | Pattern lặp lại (5x8, 4on-4off) |
| ATT-SCH-005 | Create Schedule Rules (Level 5) | P1 | Specified | Assign pattern cho nhân viên |
| ATT-SCH-006 | Generate Roster (Level 6) | P1 | Specified | Materialize lịch làm việc |
| ATT-SCH-007 | Shift Pattern Library | P1 | Specified | Thư viện pattern mẫu |
| ATT-SCH-008 | Schedule Calendar View | P1 | Specified | Xem lịch ca trên calendar |
| ATT-SCH-009 | Schedule Conflict Detection | P1 | Specified | Phát hiện xung đột lịch |
| ATT-SCH-010 | Schedule Publishing | P1 | Specified | Publish lịch cho nhân viên |
| ATT-SCH-011 | Night Shift Support | P1 | Specified | Hỗ trợ ca đêm (qua nửa đêm) |
| ATT-SCH-012 | Rotating Crew Management | P1 | Specified | Quản lý crew xoay ca |

**Chi tiết features**:

#### ATT-SCH-001: Configure Time Segments (Level 1)

```yaml
id: ATT-SCH-001
name: Configure Time Segments (Level 1)
group: Shift Scheduling
priority: P1
status: Specified
user_story: |
  Là HR, tôi muốn định nghĩa time segments
  để xây dựng ca làm việc.

acceptance_criteria:
  - Tạo WORK, BREAK, MEAL, TRANSFER segments
  - Hỗ trợ relative timing (offset từ start ca) hoặc absolute timing (giờ cố định)
  - Định nghĩa duration, isPaid, isMandatory
  - Segment ordering trong ca
```

#### ATT-SCH-002: Configure Shift Definitions (Level 2)

```yaml
id: ATT-SCH-002
name: Configure Shift Definitions (Level 2)
group: Shift Scheduling
priority: P1
status: Specified
user_story: |
  Là HR, tôi muốn tạo ca từ segments
  để định nghĩa shift patterns.

acceptance_criteria:
  - Thêm nhiều segments theo sequence
  - Hỗ trợ ELAPSED, PUNCH, FLEX shift types
  - Tính total work hours, break hours, paid hours
  - Reusable shift definitions
```

#### ATT-SCH-003: Configure Day Models (Level 3)

```yaml
id: ATT-SCH-003
name: Configure Day Models (Level 3)
group: Shift Scheduling
priority: P1
status: Specified
user_story: |
  Là HR, tôi muốn tạo day models
  cho work days, off days, holidays.

acceptance_criteria:
  - Tạo WORK, OFF, HOLIDAY, HALF_DAY models
  - Work days link to shift definitions
  - Hỗ trợ variant selection cho holidays
```

#### ATT-SCH-004: Configure Pattern Templates (Level 4)

```yaml
id: ATT-SCH-004
name: Configure Pattern Templates (Level 4)
group: Shift Scheduling
priority: P1
status: Specified
user_story: |
  Là HR, tôi muốn tạo patterns như 5x8, 4on-4off, 14/14
  để áp dụng cho team.

acceptance_criteria:
  - Define cycle length (7, 8, 14, 28 days)
  - Assign day model cho mỗi ngày trong cycle
  - Hỗ trợ FIXED hoặc ROTATING patterns
  - Pattern preview
```

#### ATT-SCH-005: Create Schedule Rules (Level 5)

```yaml
id: ATT-SCH-005
name: Create Schedule Rules (Level 5)
group: Shift Scheduling
priority: P1
status: Specified
user_story: |
  Là quản lý, tôi muốn assign patterns
  cho team của mình.

acceptance_criteria:
  - Select pattern template
  - Select holiday calendar
  - Assign cho EMPLOYEE, GROUP, hoặc POSITION
  - Set effective date range
  - Rotation offset cho crews
```

#### ATT-SCH-006: Generate Roster (Level 6)

```yaml
id: ATT-SCH-006
name: Generate Roster (Level 6)
group: Shift Scheduling
priority: P1
status: Specified
user_story: |
  Là hệ thống, tôi generate rosters
  từ schedule rules.

acceptance_criteria:
  - Tính cycle day cho mỗi date
  - Áp dụng holiday overrides
  - Áp dụng schedule overrides
  - Track full lineage (pattern → day model → shift)
  - One row per employee per day
```

#### ATT-SCH-007: Shift Pattern Library

```yaml
id: ATT-SCH-007
name: Shift Pattern Library
group: Shift Scheduling
priority: P1
status: Specified
user_story: |
  Là HR, tôi muốn thư viện patterns mẫu
  để sử dụng nhanh.

acceptance_criteria:
  - Pre-built patterns (5x8, 4on-4off, 3-shift rotation)
  - Industry-specific patterns
  - Clone và customize
```

#### ATT-SCH-008: Schedule Calendar View

```yaml
id: ATT-SCH-008
name: Schedule Calendar View
group: Shift Scheduling
priority: P1
status: Specified
user_story: |
  Là quản lý/nhân viên, tôi muốn xem lịch
  trên calendar.

acceptance_criteria:
  - Monthly/weekly/daily view
  - Color-coded by shift type
  - Hiển thị shift times và details
  - Team view và individual view
```

#### ATT-SCH-009: Schedule Conflict Detection

```yaml
id: ATT-SCH-009
name: Schedule Conflict Detection
group: Shift Scheduling
priority: P1
status: Specified
user_story: |
  Là hệ thống, tôi phát hiện xung đột lịch
  để cảnh báo.

acceptance_criteria:
  - Detect overlapping shifts
  - Detect insufficient rest between shifts
  - Detect holiday conflicts
  - Warning trước khi assign
```

#### ATT-SCH-010: Schedule Publishing

```yaml
id: ATT-SCH-010
name: Schedule Publishing
group: Shift Scheduling
priority: P1
status: Specified
user_story: |
  Là quản lý, tôi muốn publish lịch
  để nhân viên biết ca làm.

acceptance_criteria:
  - Publish schedule cho team
  - Notification cho nhân viên
  - Version control (draft vs published)
  - Lead time requirement (publish X days trước)
```

#### ATT-SCH-011: Night Shift Support

```yaml
id: ATT-SCH-011
name: Night Shift Support
group: Shift Scheduling
priority: P1
status: Specified
user_story: |
  Là hệ thống, tôi hỗ trợ ca đêm
  qua nửa đêm.

acceptance_criteria:
  - Shift spans midnight
  - Correct day assignment
  - Holiday handling cho night shifts
  - Overtime calculation cho night hours
```

#### ATT-SCH-012: Rotating Crew Management

```yaml
id: ATT-SCH-012
name: Rotating Crew Management
group: Shift Scheduling
priority: P1
status: Specified
user_story: |
  Là quản lý, tôi muốn quản lý crews xoay ca
  với offset khác nhau.

acceptance_criteria:
  - Define crews (Crew A, B, C)
  - Rotation offset per crew
  - Auto-advance qua cycles
  - Crew swap handling
```

---

### Category ATT-02: Time Tracking

**Mục đích**: Quản lý chấm công và theo dõi giờ làm.

| ID | Feature Name | Priority | Status | Description |
|----|-------------|----------|--------|-------------|
| ATT-TRK-001 | Clock In | P0 | Specified | Chấm công vào |
| ATT-TRK-002 | Clock Out | P0 | Specified | Chấm công ra |
| ATT-TRK-003 | View My Schedule | P0 | Specified | Xem lịch làm cá nhân |
| ATT-TRK-004 | Manual Time Entry | P0 | Specified | Nhập giờ thủ công |
| ATT-TRK-005 | Break Start/End | P1 | Specified | Chấm công nghỉ giữa ca |
| ATT-TRK-006 | Multi-Location Support | P1 | Specified | Chấm công tại nhiều địa điểm |
| ATT-TRK-007 | Time Rounding Rules | P0 | Specified | Quy tắc làm tròn giờ |
| ATT-TRK-008 | Grace Period | P0 | Specified | Thời gian ân hạn |

**Chi tiết features**:

#### ATT-TRK-001: Clock In

```yaml
id: ATT-TRK-001
name: Clock In
group: Time Tracking
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn chấm công vào
  để ghi nhận giờ đến.

acceptance_criteria:
  - Hỗ trợ biometric, RFID, mobile, web
  - Capture timestamp và location
  - Tạo attendance record
  - Detect late arrival
```

#### ATT-TRK-002: Clock Out

```yaml
id: ATT-TRK-002
name: Clock Out
group: Time Tracking
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn chấm công ra
  để ghi nhận giờ về.

acceptance_criteria:
  - Cập nhật attendance record
  - Tính actual hours worked
  - Áp dụng rounding rules
  - Detect early departure
```

#### ATT-TRK-003: View My Schedule

```yaml
id: ATT-TRK-003
name: View My Schedule
group: Time Tracking
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn xem lịch làm
  để lên kế hoạch.

acceptance_criteria:
  - Calendar view
  - Color-coded by shift type
  - Hiển thị shift times và details
  - Xem different date ranges
```

#### ATT-TRK-004: Manual Time Entry

```yaml
id: ATT-TRK-004
name: Manual Time Entry
group: Time Tracking
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn nhập giờ thủ công
  nếu quên chấm công.

acceptance_criteria:
  - Nhập start và end time
  - Cần manager approval
  - Marked as manual entry
  - Audit trail
```

#### ATT-TRK-005: Break Start/End

```yaml
id: ATT-TRK-005
name: Break Start/End
group: Time Tracking
priority: P1
status: Specified
user_story: |
  Là nhân viên, tôi muốn chấm công nghỉ giữa ca
  để tracking break time.

acceptance_criteria:
  - Clock out cho break
  - Clock in khi quay lại
  - unpaid break handling
```

#### ATT-TRK-006: Multi-Location Support

```yaml
id: ATT-TRK-006
name: Multi-Location Support
group: Time Tracking
priority: P1
status: Specified
user_story: |
  Là nhân viên, tôi muốn chấm công tại nhiều địa điểm
  khi đi công tác.

acceptance_criteria:
  - Select work location
  - GPS validation
  - Location history
```

#### ATT-TRK-007: Time Rounding Rules

```yaml
id: ATT-TRK-007
name: Time Rounding Rules
group: Time Tracking
priority: P0
status: Specified
user_story: |
  Là HR, tôi muốn cấu hình rounding rules
  cho thời gian chấm công.

acceptance_criteria:
  - Round to nearest 15/30 minutes
  - Round up/down policies
  - Per shift type configuration
```

#### ATT-TRK-008: Grace Period

```yaml
id: ATT-TRK-008
name: Grace Period
group: Time Tracking
priority: P0
status: Specified
user_story: |
  Là HR, tôi muốn cấu hình grace period
  cho late arrivals.

acceptance_criteria:
  - Configurable minutes (e.g., 5 minutes)
  - Late detection sau grace period
  - Per shift type
```

---

### Category ATT-03: Attendance Exceptions

**Mục đích**: Quản lý các trường hợp ngoại lệ về chấm công.

| ID | Feature Name | Priority | Status | Description |
|----|-------------|----------|--------|-------------|
| ATT-EXC-001 | Late In Detection | P0 | Specified | Phát hiện đến muộn |
| ATT-EXC-002 | Early Out Detection | P0 | Specified | Phát hiện về sớm |
| ATT-EXC-003 | Missing Punch Detection | P0 | Specified | Phát hiện thiếu chấm công |
| ATT-EXC-004 | Unauthorized Absence Detection | P0 | Specified | Phát hiện vắng mặt không phép |
| ATT-EXC-005 | Overtime Detection | P0 | Specified | Phát hiện làm overtime |
| ATT-EXC-006 | Exception Resolution Workflow | P1 | Specified | Workflow xử lý exception |
| ATT-EXC-007 | Excuse/Explanation Submission | P1 | Specified | Nhân viên giải trình exception |
| ATT-EXC-008 | Exception Reporting | P1 | Specified | Báo cáo exceptions |

**Chi tiết features**:

#### ATT-EXC-001: Late In Detection

```yaml
id: ATT-EXC-001
name: Late In Detection
group: Attendance Exceptions
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi phát hiện đến muộn
  vượt quá grace period.

acceptance_criteria:
  - So sánh clock in time với scheduled start
  - Áp dụng grace period
  - Tạo LATE_IN exception
  - Notification cho manager
```

#### ATT-EXC-002: Early Out Detection

```yaml
id: ATT-EXC-002
name: Early Out Detection
group: Attendance Exceptions
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi phát hiện về sớm
  trước scheduled end.

acceptance_criteria:
  - So sánh clock out time với scheduled end
  - Áp dụng grace period
  - Tạo EARLY_OUT exception
```

#### ATT-EXC-003: Missing Punch Detection

```yaml
id: ATT-EXC-003
name: Missing Punch Detection
group: Attendance Exceptions
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi phát hiện thiếu chấm công.

acceptance_criteria:
  - Detect missing clock in
  - Detect missing clock out
  - Tạo MISSING_PUNCH exception
  - Require correction
```

#### ATT-EXC-004: Unauthorized Absence Detection

```yaml
id: ATT-EXC-004
name: Unauthorized Absence Detection
group: Attendance Exceptions
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi phát hiện no-shows.

acceptance_criteria:
  - No clock in cho scheduled work day
  - Tạo UNAUTHORIZED_ABSENCE exception
  - High severity
  - Escalation
```

#### ATT-EXC-005: Overtime Detection

```yaml
id: ATT-EXC-005
name: Overtime Detection
group: Attendance Exceptions
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi phát hiện overtime hours.

acceptance_criteria:
  - So sánh actual hours với scheduled
  - Tạo OVERTIME exception
  - Tính overtime hours
  - Require approval
```

#### ATT-EXC-006: Exception Resolution Workflow

```yaml
id: ATT-EXC-006
name: Exception Resolution Workflow
group: Attendance Exceptions
priority: P1
status: Specified
user_story: |
  Là quản lý, tôi muốn xem và xử lý exceptions.

acceptance_criteria:
  - Exception dashboard
  - Accept/reject exception
  - Add comments
  - Track resolution status
```

#### ATT-EXC-007: Excuse/Explanation Submission

```yaml
id: ATT-EXC-007
name: Excuse/Explanation Submission
group: Attendance Exceptions
priority: P1
status: Specified
user_story: |
  Là nhân viên, tôi muốn giải trình exception.

acceptance_criteria:
  - Submit explanation
  - Attach documents nếu cần
  - Track status
```

#### ATT-EXC-008: Exception Reporting

```yaml
id: ATT-EXC-008
name: Exception Reporting
group: Attendance Exceptions
priority: P1
status: Specified
user_story: |
  Là quản lý, tôi muốn xem báo cáo exceptions.

acceptance_criteria:
  - Report by employee, team, period
  - Trend analysis
  - Export Excel/PDF
```

---

### Category ATT-04: Timesheet Management

**Mục đích**: Quản lý bảng kê khai giờ làm và phê duyệt.

| ID | Feature Name | Priority | Status | Description |
|----|-------------|----------|--------|-------------|
| ATT-TS-001 | Generate Timesheet | P0 | Specified | Generate timesheet cho kỳ |
| ATT-TS-002 | Submit Timesheet | P0 | Specified | Nhân viên submit timesheet |
| ATT-TS-003 | Approve Timesheet | P0 | Specified | Quản lý phê duyệt timesheet |
| ATT-TS-004 | Timesheet Correction | P1 | Specified | Sửa timesheet đã submit |
| ATT-TS-005 | Project/Task Time Allocation | P1 | Specified | Phân bổ thời gian theo project |
| ATT-TS-006 | Timesheet Export | P1 | Specified | Export timesheet |
| ATT-TS-007 | Recurring Timesheet | P1 | Specified | Timesheet định kỳ tự động |
| ATT-TS-008 | Timesheet Approval History | P0 | Specified | Lịch sử phê duyệt |

**Chi tiết features**:

#### ATT-TS-001: Generate Timesheet

```yaml
id: ATT-TS-001
name: Generate Timesheet
group: Timesheet Management
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi generate timesheets
  vào cuối kỳ.

acceptance_criteria:
  - Aggregate attendance records
  - Calculate total hours
  - Identify exceptions
  - Status: DRAFT
```

#### ATT-TS-002: Submit Timesheet

```yaml
id: ATT-TS-002
name: Submit Timesheet
group: Timesheet Management
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn submit timesheet
  để được duyệt.

acceptance_criteria:
  - Review hours trước khi submit
  - Status changes to SUBMITTED
  - Manager notified
```

#### ATT-TS-003: Approve Timesheet

```yaml
id: ATT-TS-003
name: Approve Timesheet
group: Timesheet Management
priority: P0
status: Specified
user_story: |
  Là quản lý, tôi muốn phê duyệt timesheets.

acceptance_criteria:
  - Review hours và exceptions
  - Approve hoặc reject
  - Status changes to APPROVED
  - Sent to payroll
```

#### ATT-TS-004: Timesheet Correction

```yaml
id: ATT-TS-004
name: Timesheet Correction
group: Timesheet Management
priority: P1
status: Specified
user_story: |
  Là nhân viên, tôi muốn sửa timesheet
  nếu có sai sót.

acceptance_criteria:
  - Recall submitted timesheet
  - Make corrections
  - Re-submit
```

#### ATT-TS-005: Project/Task Time Allocation

```yaml
id: ATT-TS-005
name: Project/Task Time Allocation
group: Timesheet Management
priority: P1
status: Specified
user_story: |
  Là nhân viên, tôi muốn allocate time
  cho projects/tasks.

acceptance_criteria:
  - Split time across projects
  - Billable/non-billable categorization
  - Validate với project budget
```

#### ATT-TS-006: Timesheet Export

```yaml
id: ATT-TS-006
name: Timesheet Export
group: Timesheet Management
priority: P1
status: Specified
user_story: |
  Là nhân viên, tôi muốn export timesheet.

acceptance_criteria:
  - Export PDF/Excel
  - Selected period
  - Include project breakdown
```

#### ATT-TS-007: Recurring Timesheet

```yaml
id: ATT-TS-007
name: Recurring Timesheet
group: Timesheet Management
priority: P1
status: Specified
user_story: |
  Là hệ thống, tôi auto-generate timesheets
  cho mỗi kỳ.

acceptance_criteria:
  - Auto-create timesheet templates
  - Copy từ previous period
  - Reminder để submit
```

#### ATT-TS-008: Timesheet Approval History

```yaml
id: ATT-TS-008
name: Timesheet Approval History
group: Timesheet Management
priority: P0
status: Specified
user_story: |
  Là nhân viên/quản lý, tôi muốn xem lịch sử phê duyệt.

acceptance_criteria:
  - All historical timesheets
  - Status và approval info
  - Searchable
```

---

### Category ATT-05: Overtime Management

**Mục đích**: Quản lý overtime request, calculation, và approval.

| ID | Feature Name | Priority | Status | Description |
|----|-------------|----------|--------|-------------|
| ATT-OT-001 | Calculate Overtime | P0 | Specified | Tính overtime hours |
| ATT-OT-002 | Request Overtime | P0 | Specified | Xin overtime approval |
| ATT-OT-003 | Approve Overtime | P0 | Specified | Phê duyệt overtime |
| ATT-OT-004 | Overtime Rate Calculation | P0 | Specified | Tính multiplier (150/200/300%) |
| ATT-OT-005 | Comp Time Conversion | P0 | Specified | Convert OT thành comp time |
| ATT-OT-006 | Overtime Caps/Alerts | P0 | Specified | Giới hạn và cảnh báo OT |
| ATT-OT-007 | Pre-Approval Workflow | P0 | Specified | Pre-approval trước khi làm OT |
| ATT-OT-008 | OT by Type (Weekday/Weekend/Holiday) | P0 | Specified | Phân loại OT |
| ATT-OT-009 | OT Reporting | P1 | Specified | Báo cáo overtime |
| ATT-OT-010 | OT Balance Tracking | P1 | Specified | Theo dõi số dư comp time |

**Chi tiết features**:

#### ATT-OT-001: Calculate Overtime

```yaml
id: ATT-OT-001
name: Calculate Overtime
group: Overtime Management
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi tính overtime
  dựa trên rules.

acceptance_criteria:
  - Hỗ trợ daily, weekly, biweekly methods
  - Identify OT type (regular, weekend, holiday, night)
  - Calculate multiplier
```

#### ATT-OT-002: Request Overtime

```yaml
id: ATT-OT-002
name: Request Overtime
group: Overtime Management
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn xin overtime approval.

acceptance_criteria:
  - Request trước hoặc sau khi làm
  - Specify expected hours
  - Provide reason
```

#### ATT-OT-003: Approve Overtime

```yaml
id: ATT-OT-003
name: Approve Overtime
group: Overtime Management
priority: P0
status: Specified
user_story: |
  Là quản lý, tôi muốn phê duyệt overtime.

acceptance_criteria:
  - Approve hoặc reject
  - Modify hours nếu cần
  - Employee notified
```

#### ATT-OT-004: Overtime Rate Calculation

```yaml
id: ATT-OT-004
name: Overtime Rate Calculation
group: Overtime Management
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi tính overtime rate
  theo LLV.

acceptance_criteria:
  - 150% weekday OT
  - 200% weekend OT
  - 300% holiday OT
  - Configurable rates
```

#### ATT-OT-005: Comp Time Conversion

```yaml
id: ATT-OT-005
name: Comp Time Conversion
group: Overtime Management
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn convert OT
  thành comp time.

acceptance_criteria:
  - Configurable conversion rate (1:1, 1:1.5, 1:2)
  - Comp time balance tracking
  - Use comp time for leave
```

#### ATT-OT-006: Overtime Caps/Alerts

```yaml
id: ATT-OT-006
name: Overtime Caps/Alerts
group: Overtime Management
priority: P0
status: Specified
user_story: |
  Là HR, tôi muốn set OT caps
  để compliance.

acceptance_criteria:
  - Max OT per day/week/month/year
  - Alert khi gần giới hạn
  - Block vượt quá (configurable)
```

#### ATT-OT-007: Pre-Approval Workflow

```yaml
id: ATT-OT-007
name: Pre-Approval Workflow
group: Overtime Management
priority: P0
status: Specified
user_story: |
  Là quản lý, tôi muốn pre-approve OT
  trước khi nhân viên làm.

acceptance_criteria:
  - Request trước khi làm OT
  - Approval trước khi clock in
  - Audit trail
```

#### ATT-OT-008: OT by Type

```yaml
id: ATT-OT-008
name: OT by Type (Weekday/Weekend/Holiday)
group: Overtime Management
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi phân loại OT
  theo type.

acceptance_criteria:
  - Weekday OT
  - Weekend OT
  - Holiday OT
  - Night shift OT
  - Different rates per type
```

#### ATT-OT-009: OT Reporting

```yaml
id: ATT-OT-009
name: OT Reporting
group: Overtime Management
priority: P1
status: Specified
user_story: |
  Là quản lý, tôi muốn xem báo cáo OT.

acceptance_criteria:
  - OT by employee, team, period
  - OT cost analysis
  - Trend analysis
```

#### ATT-OT-010: OT Balance Tracking

```yaml
id: ATT-OT-010
name: Comp Time Balance Tracking
group: Overtime Management
priority: P1
status: Specified
user_story: |
  Là nhân viên, tôi muốn xem số dư comp time.

acceptance_criteria:
  - View comp time balance
  - Earned vs used
  - Expiry tracking
```

---

### Category ATT-06: Schedule Overrides

**Mục đích**: Quản lý override và thay đổi lịch làm.

| ID | Feature Name | Priority | Status | Description |
|----|-------------|----------|--------|-------------|
| ATT-OVR-001 | Create Schedule Override | P0 | Specified | Override lịch làm |
| ATT-OVR-002 | Shift Swap Request | P0 | Specified | Đổi ca với đồng nghiệp |
| ATT-OVR-003 | Shift Bidding | P1 | Specified | Đấu giá ca trống |
| ATT-OVR-004 | Open Shift Posting | P1 | Specified | Đăng ca trống |
| ATT-OVR-005 | Override Approval | P0 | Specified | Phê duyệt override |
| ATT-OVR-006 | Temporary Assignment | P1 | Specified | Gán ca tạm thời |
| ATT-OVR-007 | Override History | P0 | Specified | Lịch sử overrides |
| ATT-OVR-008 | Bulk Override | P1 | Specified | Override hàng loạt |

**Chi tiết features**:

#### ATT-OVR-001: Create Schedule Override

```yaml
id: ATT-OVR-001
name: Create Schedule Override
group: Schedule Overrides
priority: P0
status: Specified
user_story: |
  Là quản lý, tôi muốn override lịch làm
  cho tình huống đặc biệt.

acceptance_criteria:
  - Change shift cho specific dates
  - Mark as OFF hoặc HOLIDAY
  - Provide reason
  - Employee notified
```

#### ATT-OVR-002: Shift Swap Request

```yaml
id: ATT-OVR-002
name: Shift Swap Request
group: Schedule Overrides
priority: P0
status: Specified
user_story: |
  Là nhân viên, tôi muốn đổi ca
  với đồng nghiệp.

acceptance_criteria:
  - Request swap với specific employee
  - Other employee phải accept
  - Manager phải approve
  - Both rosters updated
```

#### ATT-OVR-003: Shift Bidding

```yaml
id: ATT-OVR-003
name: Shift Bidding
group: Schedule Overrides
priority: P1
status: Specified
user_story: |
  Là nhân viên, tôi muốn bid
  cho ca trống.

acceptance_criteria:
  - Manager posts open shift
  - Employees có thể bid
  - Manager selects winner
  - Roster updated
```

#### ATT-OVR-004: Open Shift Posting

```yaml
id: ATT-OVR-004
name: Open Shift Posting
group: Schedule Overrides
priority: P1
status: Specified
user_story: |
  Là quản lý, tôi muốn đăng ca trống
  để nhân viên bid.

acceptance_criteria:
  - Post available shifts
  - Eligibility rules
  - Auto-assign nếu cần
```

#### ATT-OVR-005: Override Approval

```yaml
id: ATT-OVR-005
name: Override Approval
group: Schedule Overrides
priority: P0
status: Specified
user_story: |
  Là hệ thống, tôi route override
  để approve.

acceptance_criteria:
  - Approval workflow cho overrides
  - Notification
  - Audit trail
```

#### ATT-OVR-006: Temporary Assignment

```yaml
id: ATT-OVR-006
name: Temporary Assignment
group: Schedule Overrides
priority: P1
status: Specified
user_story: |
  Là quản lý, tôi muốn assign ca tạm thời.

acceptance_criteria:
  - Temporary shift assignment
  - Date range
  - Auto-revert sau khi hết hạn
```

#### ATT-OVR-007: Override History

```yaml
id: ATT-OVR-007
name: Override History
group: Schedule Overrides
priority: P0
status: Specified
user_story: |
  Là quản lý, tôi muốn xem lịch sử overrides.

acceptance_criteria:
  - All historical overrides
  - Who, when, why
  - Searchable
```

#### ATT-OVR-008: Bulk Override

```yaml
id: ATT-OVR-008
name: Bulk Override
group: Schedule Overrides
priority: P1
status: Specified
user_story: |
  Là quản lý, tôi muốn override hàng loạt.

acceptance_criteria:
  - Select multiple employees/dates
  - Apply same override
  - Efficiency
```

---

## Shared Components

### Category SHR-01: Period Profiles

| ID | Feature Name | Priority | Status | Description |
|----|-------------|----------|--------|-------------|
| SHR-PRD-001 | Configure Leave Year | P0 | Specified | Cấu hình leave year boundaries |
| SHR-PRD-002 | Configure Pay Period | P0 | Specified | Cấu hình pay period frequency |
| SHR-PRD-003 | Custom Period | P1 | Specified | Custom period definition |

### Category SHR-02: Holiday Calendar

| ID | Feature Name | Priority | Status | Description |
|----|-------------|----------|--------|-------------|
| SHR-HOL-001 | Manage Holiday Calendar | P0 | Specified | Quản lý lịch nghỉ lễ |
| SHR-HOL-002 | Multi-Day Holidays | P0 | Specified | Nghỉ lễ nhiều ngày (Tết) |
| SHR-HOL-003 | Regional Holidays | P0 | Specified | Nghỉ lễ theo vùng |
| SHR-HOL-004 | Holiday Substitution | P1 | Specified | Bù ngày nghỉ cuối tuần |
| SHR-HOL-005 | Recurring Holidays | P0 | Specified | Nghỉ lễ recurring hàng năm |

### Category SHR-03: Approval Workflows

| ID | Feature Name | Priority | Status | Description |
|----|-------------|----------|--------|-------------|
| SHR-APR-001 | Configure Approval Chains | P0 | Specified | Cấu hình chuỗi phê duyệt |
| SHR-APR-002 | Event-Driven Notifications | P0 | Specified | Notification theo sự kiện |
| SHR-APR-003 | Approval Escalation | P0 | Specified | Escalation quá hạn |
| SHR-APR-004 | Notification Templates | P1 | Specified | Template notification |
| SHR-APR-005 | Multi-Channel Notifications | P1 | Specified | Email, SMS, Push |

---

## Summary

### Total Features by Sub-module

| Sub-module | Features | % |
|------------|----------|---|
| Absence Management (ABS) | 50 | 45% |
| Time & Attendance (ATT) | 60 | 55% |
| **TOTAL** | **110** | **100%** |

### Total Features by Category

| Category | Features | Sub-module |
|----------|----------|------------|
| Leave Request Management | 10 | ABS |
| Leave Approval | 10 | ABS |
| Leave Balance Management | 8 | ABS |
| Leave Accrual | 6 | ABS |
| Leave Carryover | 8 | ABS |
| Leave Policy Rules | 12 | ABS |
| Shift Scheduling | 12 | ATT |
| Time Tracking | 8 | ATT |
| Attendance Exceptions | 8 | ATT |
| Timesheet Management | 8 | ATT |
| Overtime Management | 10 | ATT |
| Schedule Overrides | 8 | ATT |
| Period Profiles | 3 | SHR |
| Holiday Calendar | 5 | SHR |
| Approval Workflows | 5 | SHR |
| **TOTAL** | **110** | |

### Features by Priority

| Priority | Count | % |
|----------|-------|---|
| P0 (Must Have) | 70 | 64% |
| P1 (Should Have) | 40 | 36% |
| P2 (Nice to Have) | 0 | 0% |

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-12 | xTalent Team | Initial version (65 features, 10 categories) |
| 2.0 | 2026-03-10 | xTalent Team | Restructured version (110 features, 17 categories, 2 sub-modules) |

---

*Tài liệu này là phiên bản 2.0 của Feature List cho module Time & Absence (TA).*
*Đặt tại: `/docs/01-modules/TA/design/feature-list-v2.md`*
*Không overwrite phiên bản cũ (`feature-list.md`).*
