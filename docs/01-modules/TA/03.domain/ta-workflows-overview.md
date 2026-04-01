# Tổng Quan Quy Trình Nghiệp Vụ — Module Time & Absence (TA)

**Module**: Time & Absence (TA)
**Phiên bản**: 1.0
**Ngày**: 2026-04-01

> Tài liệu này tổng hợp toàn bộ các quy trình (workflow) thuộc module Time & Absence, được đọc từ các file `*.flow.md` của từng bounded context. Mỗi quy trình được trình bày bằng tiếng Việt với sơ đồ Mermaid thể hiện cấu trúc các bước theo phong cách A4B Workflow Designer: **các Step là các group xếp ngang (LR), bên trong mỗi Step là các task chạy từ trên xuống (TD)**.

---

## Tổng Quan Các Bounded Context Và Quy Trình

| Bounded Context | Quy Trình | Use Case ID |
|---|---|---|
| **ta.absence** | Nộp & Phê duyệt đơn nghỉ phép | UC-ABS-001 → UC-ABS-002 |
| **ta.absence** | Điều chỉnh đơn nghỉ phép (Hủy / Về sớm / Bù số dư) | UC-ABS-003, 004, 005 |
| **ta.attendance** | Chấm công vào / ra (Clock In / Out) | UC-ATT-001 |
| **ta.attendance** | Đề xuất làm thêm giờ (OT) | UC-ATT-002 |
| **ta.shared** | Leo thang phê duyệt quá hạn | UC-SHR-002 |
| **ta.shared** | Chốt kỳ & Xuất dữ liệu sang Payroll | UC-SHD-001 |

---

## UC-ABS-001/002: Nộp & Phê Duyệt Đơn Nghỉ Phép (End-to-End)

### Ý nghĩa & Mục đích

Đây là quy trình **self-service cốt lõi** của module TA, cho phép nhân viên chủ động nộp đơn xin nghỉ và theo dõi trạng thái phê duyệt. Quy trình kết hợp hai use case: nhân viên nộp đơn (UC-ABS-001) và quản lý phê duyệt (UC-ABS-002) thành một luồng liên tục.

**Mục đích:**
- Cho phép nhân viên tự đăng ký nghỉ phép một cách minh bạch
- Tự động tính ngày làm việc thực tế (loại trừ cuối tuần và ngày lễ theo lịch nghỉ quốc gia)
- Dự trữ số dư phép theo cơ chế FEFO (hết hạn trước dùng trước) — bảo vệ phép cũ sắp hết hạn
- Thực hiện phê duyệt đa cấp và thông báo tức thời cho các bên liên quan

**Tác nhân:** Nhân viên → Hệ thống (ta.absence + ta.shared) → Quản lý

**Kích hoạt:** Nhân viên chủ động nộp đơn trên ứng dụng

```mermaid
flowchart LR
    subgraph S1["Step 1 — Nhân viên nộp đơn"]
        direction TD
        T1_1["👤 Nhân viên\nChọn loại phép, ngày bắt đầu\nvà ngày kết thúc, lý do"]
        T1_2["⚙️ Tính ngày làm việc\nthực tế\n(loại trừ cuối tuần\nvà ngày lễ từ lịch ngày lễ\nBR-ABS-003)"]
        T1_3{{"⚙️ Số dư phép đủ\nkhông?\n(BR-ABS-001)"}}
        T1_4["❌ Báo lỗi\nInsufficientBalance\n(Nếu loại phép không cho\nnghỉ ứng → dừng)"]
        T1_5["⚙️ Tạo Reservation\ntheo FEFO\n(dùng phép sắp hết hạn\ntrước — BR-ABS-004)"]
        T1_6["⚙️ Tạo LeaveRequest\nstatus = SUBMITTED\n+ Ghi LeaveMovement\nloại RESERVE (bất biến)"]
        T1_7["⚙️ Route đến chuỗi duyệt\n+ Thông báo quản lý"]
        T1_1 --> T1_2 --> T1_3
        T1_3 -->|"Không đủ"| T1_4
        T1_3 -->|"Đủ"| T1_5 --> T1_6 --> T1_7
    end

    subgraph S2["Step 2 — Quản lý phê duyệt"]
        direction TD
        T2_1["👤 Quản lý\nXem danh sách đơn chờ\ntrong hộp thư đến"]
        T2_2["👤 Quản lý\nMở chi tiết đơn\n(xem ngày, số dư,\nthông tin nhân viên)"]
        T2_3{{"Quyết định?"}}
        T2_4["✅ Approve\nAll steps done?\n→ APPROVED\nCòn step → UNDER_REVIEW\n→ chuyển người duyệt tiếp"]
        T2_5["❌ Reject\n(bắt buộc nhập lý do)\nLeaveReservation: RELEASED\nGhi RELEASE movement\nHoàn số dư phép"]
        T2_6["↩️ Return for Modification\nNhân viên nhận thông báo\nchỉnh sửa và nộp lại"]
        T2_1 --> T2_2 --> T2_3
        T2_3 -->|"Duyệt"| T2_4
        T2_3 -->|"Từ chối"| T2_5
        T2_3 -->|"Trả về"| T2_6
    end

    subgraph S3["Step 3 — Kết quả & Thông báo"]
        direction TD
        T3_1["⚙️ Gửi thông báo\nkết quả cho nhân viên\n(APPROVED / REJECTED /\nReturned for Modification)"]
        T3_2["⚙️ Khi đến ngày bắt đầu\nnghỉ:\nReservation → USE\nLeaveMovement loại USE"]
        T3_1 --> T3_2
    end

    S1 --> S2 --> S3
```

> **💡 Nguyên tắc sổ cái bất biến (ADR-TA-001):** Mọi thay đổi số dư được ghi thành movement mới vào ledger, không bao giờ sửa hay xóa movement cũ. RESERVE → RELEASE khi từ chối; RESERVE → USE khi nghỉ thực tế.

---

## UC-ABS-003/004/005: Điều Chỉnh Đơn Nghỉ Phép (Hủy / Về Sớm / Bù Số Dư)

### Ý nghĩa & Mục đích

Sau khi đơn nghỉ đã được nộp hoặc phê duyệt, có ba tình huống điều chỉnh hậu kỳ:

1. **Hủy toàn bộ** (Path 1) — nhân viên không nghỉ nữa
2. **Về sớm / Curtailment** (Path 2) — nhân viên nghỉ ít ngày hơn và muốn lấy lại phần chưa nghỉ
3. **Điều chỉnh số dư thủ công bởi HR** (Path 3) — sửa lỗi tính toán, bù đắp, phạt

**Mục đích:**
- Đảm bảo số dư phép luôn phản ánh đúng thực tế (không nghỉ đủ, không mất phép oan)
- Kiểm soát tính toàn vẹn: không sửa dữ liệu gốc, chỉ ghi bổ sung
- Bảo vệ khỏi gian lận số dư thông qua quy tắc cửa sổ hủy và phê duyệt quản lý

**Tác nhân:** Nhân viên (Path 1, 2); HR Admin + HR Manager (Path 3)

```mermaid
flowchart LR
    subgraph S1["Step 1 — Đánh giá điều kiện"]
        direction TD
        T1_1["👤 Nhân viên / HR Admin\nYêu cầu điều chỉnh"]
        T1_2{{"Loại điều chỉnh?"}}
        T1_3["Path 1: Hủy đơn\n→ Kiểm tra ngày\nvà cửa sổ hủy"]
        T1_4["Path 2: Về sớm\n→ Kiểm tra đơn\nđã APPROVED + đã bắt đầu"]
        T1_5["Path 3: Bù số dư thủ công\n→ Kiểm tra role HR_ADMIN"]
        T1_1 --> T1_2
        T1_2 --> T1_3
        T1_2 --> T1_4
        T1_2 --> T1_5
    end

    subgraph S2["Step 2A — Path 1: Hủy đơn"]
        direction TD
        T2A_1{{"today < start_date?"}}
        T2A_2["✅ Path 1A: Tự hủy\n(không cần duyệt)\nGhi RELEASE movement\nHoàn toàn bộ số dư"]
        T2A_3{{"Trong cửa sổ hủy\nsau khi nghỉ bắt đầu?"}}
        T2A_4["👤 Path 1B: Cần quản lý duyệt\nstatus → CANCELLATION_PENDING\nReservation vẫn giữ"]
        T2A_5["🚫 Path 1C: BLOCKED\nCửa sổ hủy đã đóng\nLiên hệ HR để xử lý thủ công"]
        T2A_1 -->|"Có"| T2A_2
        T2A_1 -->|"Không"| T2A_3
        T2A_3 -->|"Còn trong cửa sổ"| T2A_4
        T2A_3 -->|"Hết cửa sổ"| T2A_5
    end

    subgraph S2B["Step 2B — Path 2: Về sớm (Curtailment)"]
        direction TD
        T2B_1["👤 Nhân viên\nBáo về sớm:\n(actual_days < requested_days)\nnhập lý do bắt buộc"]
        T2B_2["⚙️ Tính delta_days\n= requested - actual\nTạo LeaveAdjustment\nstatus = PENDING_APPROVAL"]
        T2B_3["👤 Quản lý\nXem xét và phê duyệt\n(luôn bắt buộc với\ncurtailment)"]
        T2B_4{{"Kết quả?"}}
        T2B_5["✅ Ghi ADJUSTMENT movement\n(+delta_days)\nCập nhật actual_days\nvào LeaveRequest"]
        T2B_6["❌ Từ chối\nKhông thay đổi số dư\nLeaveAdjustment: REJECTED"]
        T2B_1 --> T2B_2 --> T2B_3 --> T2B_4
        T2B_4 -->|"Duyệt"| T2B_5
        T2B_4 -->|"Từ chối"| T2B_6
    end

    subgraph S2C["Step 2C — Path 3: Bù số dư thủ công (HR Admin)"]
        direction TD
        T2C_1["👤 HR Admin\nTạo Manual Adjustment\n(CREDIT/DEBIT, số ngày,\nghi chú bắt buộc, tài liệu tham chiếu)"]
        T2C_2{{"delta_days > ngưỡng\ndual approval?"}}
        T2C_3["⚙️ Ghi ngay vào ledger\n(single approval)\nGhi AuditLog\nThông báo nhân viên"]
        T2C_4["👤 HR Manager\nPhê duyệt lần 2\n(yêu cầu khi delta > 5 ngày)"]
        T2C_5{{"Kết quả HR Manager?"}}
        T2C_6["✅ Ghi MANUAL_ADJUSTMENT\nmovement vào ledger\nThông báo nhân viên"]
        T2C_7["❌ Từ chối\nLeaveAdjustment: REJECTED\nThông báo HR Admin"]
        T2C_1 --> T2C_2
        T2C_2 -->|"Dưới ngưỡng"| T2C_3
        T2C_2 -->|"Trên ngưỡng"| T2C_4 --> T2C_5
        T2C_5 -->|"Duyệt"| T2C_6
        T2C_5 -->|"Từ chối"| T2C_7
    end

    S1 --> S2
    S1 --> S2B
    S1 --> S2C
```

> **💡 Cửa sổ hủy (post_cancel_window_days):** Là số ngày sau ngày bắt đầu nghỉ mà nhân viên còn được phép hủy (cần duyệt quản lý). Nếu = 0, mọi yêu cầu hủy sau khi nghỉ bắt đầu đều bị chặn hoàn toàn.

---

## UC-ATT-001: Chấm Công Vào / Ra (Clock In / Clock Out)

### Ý nghĩa & Mục đích

Quy trình ghi nhận giờ làm việc hàng ngày của nhân viên thông qua thiết bị di động hoặc máy chấm công. Đây là **nguồn dữ liệu đầu vào** cho tính lương (giờ OT), kiểm soát tuân thủ và quản lý ca làm việc.

**Mục đích:**
- Ghi nhận thời gian làm việc thực tế theo từng ca
- Xác thực vị trí địa lý (geofence) để phòng ngừa gian lận chấm công
- Hỗ trợ chế độ offline — đồng bộ dữ liệu khi có kết nối trở lại
- Tự động tính giờ OT khi vượt ca làm việc tiêu chuẩn

**Tác nhân:** Nhân viên → App / Thiết bị → Hệ thống (ta.attendance) → HR Admin (xử lý ngoại lệ)

**Kích hoạt:** Nhân viên bấm chấm công vào / ra

```mermaid
flowchart LR
    subgraph S1["Step 1 — Chấm công VÀO"]
        direction TD
        T1_1["👤 Nhân viên\nBấm 'Clock In'\ntrên App / Kiosk"]
        T1_2["⚙️ App chụp\nbiometric token\n+ GPS coordinates"]
        T1_3{{"Online?"}}
        T1_4["⚙️ Gửi lên server:\nSubmitPunch(IN)\nXác thực geofence"]
        T1_5["📦 Lưu offline\nQueuePunch PENDING\n→ Đồng bộ khi có mạng"]
        T1_6{{"Geofence\nhợp lệ?"}}
        T1_7["⚙️ Tạo Punch IN\n(SYNCED, immutable)\nXác nhận cho NV"]
        T1_8["⚙️ Tạo Punch IN\ngeofence_validated=false\nCảnh báo NV\nThông báo HR Admin"]
        T1_1 --> T1_2 --> T1_3
        T1_3 -->|"Có mạng"| T1_4 --> T1_6
        T1_3 -->|"Offline"| T1_5
        T1_6 -->|"Trong vùng"| T1_7
        T1_6 -->|"Ngoài vùng"| T1_8
    end

    subgraph S2["Step 2 — Chấm công RA"]
        direction TD
        T2_1["👤 Nhân viên\nBấm 'Clock Out'"]
        T2_2["⚙️ Submit Punch OUT\nKhớp với Punch IN\ntheo ngày + ca"]
        T2_3["⚙️ Tính giờ thực tế:\ngross_hours = OUT − IN\nnet = gross − giờ nghỉ\not_hours = max(0, net − ca)"]
        T2_4["⚙️ Tạo WorkedPeriod\nstatus = CONFIRMED\nCập nhật Timesheet"]
        T2_1 --> T2_2 --> T2_3 --> T2_4
    end

    subgraph S3["Step 3 — Xử lý ngoại lệ"]
        direction TD
        T3_1["⏱️ TIMER\nScheduler chạy\n30 phút sau giờ kết ca"]
        T3_2["⚙️ Phát hiện NV\nquên chấm công ra\n→ Tạo WorkedPeriod PROVISIONAL\n(dùng giờ kết ca làm ước tính)"]
        T3_3["⚙️ Thông báo NV\nnhập giờ ra thực tế"]
        T3_4["👤 NV nộp\nCorrection Punch\n(is_correction=true)"]
        T3_5["⚙️ WorkedPeriod:\nCONFIRMED ← CORRECTED\nCập nhật Timesheet"]
        T3_1 --> T3_2 --> T3_3 --> T3_4 --> T3_5
    end

    subgraph S4["Step 4 — Giải quyết xung đột offline"]
        direction TD
        T4_1["⚙️ Đồng bộ\ncác Punch PENDING\nkhi có mạng"]
        T4_2{{"Có xung đột\n(trùng / chồng thời gian)?"}}
        T4_3["✅ SYNCED\nTạo WorkedPeriod\nbình thường"]
        T4_4["🚩 CONFLICT\nThông báo HR Admin\ncần xử lý thủ công"]
        T4_1 --> T4_2
        T4_2 -->|"Không"| T4_3
        T4_2 -->|"Có"| T4_4
    end

    S1 --> S2 --> S3
    S1 -.->|"Offline path"| S4
```

> **⚠️ Nguyên tắc bất biến (ADR-TA-001):** Punch đã được ghi không được sửa. Correction phải tạo một Punch mới với `is_correction=true`, tham chiếu đến Punch gốc. Dữ liệu sinh trắc học chỉ lưu dạng token mờ, không lưu dữ liệu thô (ADR-TA-004).

---

## UC-ATT-002: Đề Xuất Làm Thêm Giờ (Request Overtime)

### Ý nghĩa & Mục đích

Nhân viên (hoặc quản lý) đăng ký làm thêm giờ trước hoặc sau khi thực hiện. Hệ thống kiểm soát giới hạn OT theo Bộ Luật Lao động 2019 và định tuyến phê duyệt phù hợp. Trường hợp đặc biệt: **quản lý đăng ký OT cho chính mình** — hệ thống phải tự động tránh tình huống tự phê duyệt.

**Mục đích:**
- Kiểm soát tuân thủ giới hạn OT (4h/ngày, 40h/tháng, 300h/năm) theo VLC 2019 Điều 107
- Ghi nhận OT vào timesheet để làm cơ sở tính lương (hệ số 150% / 200% / 300%)
- Hỗ trợ lựa chọn bù bằng ngày nghỉ bù (CompTime) thay vì tiền mặt
- Ngăn chặn self-approval qua định tuyến skip-level hoặc custom approver

**Tác nhân:** Nhân viên / Quản lý → Hệ thống → Quản lý (hoặc Skip-Level / Custom Approver)

**Kích hoạt:** Nhân viên tự đăng ký; hoặc hệ thống phát hiện giờ thực tế vượt ca

```mermaid
flowchart LR
    subgraph S1["Step 1 — Nộp đề xuất OT"]
        direction TD
        T1_1["👤 Nhân viên / Quản lý\nNộp OT Request\n(ngày, số giờ, loại OT,\nlý do, muốn bù tiền / ngày?)"]
        T1_2["⚙️ Kiểm tra giới hạn OT\n(BR-ATT-005):\n• Daily ≤ 4h\n• Monthly ≤ 40h\n• Annual ≤ 300h"]
        T1_3{{"Vượt giới hạn?"}}
        T1_4["❌ Báo lỗi OTCapExceeded\n(hiển thị còn được thêm\ntối đa bao nhiêu giờ)"]
        T1_5{{"Người nộp là\nQuản lý tự đăng ký\nOT cho mình?"}}
        T1_6["⚙️ Định tuyến chuẩn\n→ Direct Manager\n(status = SUBMITTED)"]
        T1_7{{"routing_mode?"}}
        T1_8["⚙️ SKIP_LEVEL\n→ Gửi cho\nManagercủa Manager\n(tránh self-approval)"]
        T1_9["⚙️ CUSTOM\n→ Gửi cho\nCustom Approver\ntheo ma trận quyền"]
        T1_1 --> T1_2 --> T1_3
        T1_3 -->|"Có"| T1_4
        T1_3 -->|"Không"| T1_5
        T1_5 -->|"Không"| T1_6
        T1_5 -->|"Có"| T1_7
        T1_7 -->|"SKIP_LEVEL\n(mặc định)"| T1_8
        T1_7 -->|"CUSTOM"| T1_9
    end

    subgraph S2["Step 2 — Phê duyệt"]
        direction TD
        T2_1["👤 Người phê duyệt\n(Manager / Skip-Level /\nCustom Approver)\nXem và hành động"]
        T2_2{{"Quyết định?"}}
        T2_3["✅ Approve\nstatus = APPROVED\nCập nhật TimesheetLine\n(ot_hours 150/200/300%)"]
        T2_4["❌ Reject\n(bắt buộc nhập lý do)\nstatus = REJECTED\nThông báo nhân viên"]
        T2_1 --> T2_2
        T2_2 -->|"Duyệt"| T2_3
        T2_2 -->|"Từ chối"| T2_4
    end

    subgraph S3["Step 3 — Ghi nhận kết quả"]
        direction TD
        T3_1{{"comp_time_elected\n= true?"}}
        T3_2["⚙️ Cộng vào\nCompTimeBalance.earned_hours\n(ngày nghỉ bù — không tính tiền OT)"]
        T3_3["⚙️ Ghi giờ OT\nvào TimesheetLine\n(dùng để tính lương)"]
        T3_4["⚙️ Thông báo\nkết quả cho\nngười đề xuất"]
        T3_1 -->|"Có — bù ngày"| T3_2
        T3_1 -->|"Không — tính tiền"| T3_3
        T3_2 --> T3_4
        T3_3 --> T3_4
    end

    S1 --> S2 --> S3
```

---

## UC-SHR-002: Leo Thang Phê Duyệt Quá Hạn (Escalate Approval)

### Ý nghĩa & Mục đích

Khi một đơn nghỉ phép hay đề xuất OT không được xử lý trong thời hạn cấu hình (mặc định 48h), hệ thống tự động leo thang lên cấp cao hơn để đảm bảo không có yêu cầu nào bị bỏ quên. Đây là **cơ chế an toàn** giúp HR và nhân viên không phải theo dõi thủ công.

**Mục đích:**
- Đảm bảo SLA phê duyệt được tuân thủ (không để đơn chờ quá lâu gây bức xúc nhân viên)
- Tự động xử lý các trường hợp quản lý vắng mặt hoặc không phản hồi
- Cung cấp safety net cuối cùng: HR Admin có quyền quyết định mọi đơn không có người duyệt

**Tác nhân:** Hệ thống (Scheduler) → EscalationService → Người duyệt tiếp theo / Backup / HR Admin

**Kích hoạt:** TIMER — chạy định kỳ, phát hiện đơn quá hạn

```mermaid
flowchart LR
    subgraph S1["Step 1 — Phát hiện quá hạn"]
        direction TD
        T1_1["⏱️ TIMER\nScheduler chạy\nđịnh kỳ (mỗi N phút)"]
        T1_2["⚙️ EscalationService\nQuery các yêu cầu\nở SUBMITTED / UNDER_REVIEW\n> timeout_hours (mặc định 48h)"]
        T1_3["⚙️ Với mỗi đơn quá hạn:\nLấy cấu hình escalation\ntheo ApprovalChain"]
        T1_1 --> T1_2 --> T1_3
    end

    subgraph S2["Step 2 — Nhắc (50% timeout)"]
        direction TD
        T2_1["⚙️ Đã qua 50%\nthời gian timeout?"]
        T2_2["⚙️ Gửi nhắc nhở\ncho người duyệt hiện tại\n(Push + Email:\n'Sắp đến hạn — action required')"]
        T2_1 --> T2_2
    end

    subgraph S3["Step 3 — Leo thang"]
        direction TD
        T3_1{{"Delegation\nactive?"}}
        T3_2["⚙️ AF-1: Chuyển sang\nBackup Approver\n(đang cover thay)"]
        T3_3{{"Manager OT\n(skip-level)?"}}
        T3_4["⚙️ AF-3: Chuyển thẳng lên\nSkip-Level Manager\n(bỏ qua L1)"]
        T3_5["⚙️ Standard: Chuyển lên\nNext-Level Approver\n(L2 → L3)"]
        T3_6["⚙️ Cập nhật ApprovalChain\nGhi AuditLog:\nEscalationTriggered\nThông báo người duyệt mới"]
        T3_1 -->|"Có"| T3_2 --> T3_6
        T3_1 -->|"Không"| T3_3
        T3_3 -->|"Có"| T3_4 --> T3_6
        T3_3 -->|"Không"| T3_5 --> T3_6
    end

    subgraph S4["Step 4 — Safety Net HR"]
        direction TD
        T4_1{{"Đã leo thang\nmax_escalation_levels\nlần (mặc định 3)?"}}
        T4_2["⚙️ Phát sự kiện\nHRReviewRequired\nAlerts HR Admin\n(High Priority)"]
        T4_3["👤 HR Admin\nQuyết định cuối:\nApprove / Reject / Reassign"]
        T4_1 -->|"Đã đạt max"| T4_2 --> T4_3
        T4_1 -->|"Chưa"| T4_3
    end

    S1 --> S2 --> S3 --> S4
```

> **💡 Thứ tự ưu tiên:** Delegation (backup) > Skip-Level (manager OT) > Standard escalation. Delegation luôn được ưu tiên xử lý trước.

---

## UC-SHD-001: Chốt Kỳ & Xuất Dữ Liệu Sang Payroll (Period Close & Payroll Export)

### Ý nghĩa & Mục đích

Cuối mỗi kỳ lương, Payroll Officer thực hiện "đóng kỳ" Time & Absence: khóa toàn bộ timesheet, xử lý nhân viên nghỉ việc có số dư âm, tổng hợp dữ liệu chấm công + nghỉ phép và gửi sang module Payroll để tính lương. Đây là **cầu nối quan trọng** giữa module TA và module PR.

**Mục đích:**
- Đảm bảo không có dữ liệu chấm công nào bị thay đổi sau khi xuất sang Payroll
- Xử lý đúng quy định pháp luật với số dư phép âm khi nghỉ việc (VLC Điều 21)
- Tạo gói xuất (PayrollExportPackage) bất biến, có checksum xác thực toàn vẹn
- Bảo đảm idempotency — chạy lại không tạo thêm gói xuất thứ hai

**Tác nhân:** Payroll Officer → Hệ thống (ta.shared + ta.absence + ta.attendance) → HR Admin (cho trường hợp đặc biệt) → Module Payroll

**Kích hoạt:** Payroll Officer thủ công kích hoạt cuối kỳ lương

```mermaid
flowchart LR
    subgraph S1["Step 1 — Khóa kỳ"]
        direction TD
        T1_1["👤 Payroll Officer\nNavigate đến Period Mgmt\nClick 'Close Period'"]
        T1_2["⚙️ Kiểm tra guard:\nperiod.status = OPEN?\nKhông có close khác\nđang chạy?"]
        T1_3["⚙️ Period: OPEN → LOCKED\nGhi locked_at, locked_by"]
        T1_1 --> T1_2 --> T1_3
    end

    subgraph S2["Step 2 — Xác nhận Timesheets"]
        direction TD
        T2_1["⚙️ ta.attendance\nValidate tất cả Timesheets\ntrong kỳ"]
        T2_2{{"Có Timesheet\nchưa APPROVED?"}}
        T2_3["⚠️ Cảnh báo Payroll Officer\n(có thể override với\nHR Admin approval)"]
        T2_4["⚙️ Lock tất cả Timesheets\n→ status=LOCKED\nKhông thêm WorkedPeriod\nđược nữa"]
        T2_1 --> T2_2
        T2_2 -->|"Có"| T2_3 --> T2_4
        T2_2 -->|"Không"| T2_4
    end

    subgraph S3["Step 3 — Xử lý số dư âm NV nghỉ việc (H-P0-004)"]
        direction TD
        T3_1["⚙️ ta.absence\nQuery nhân viên nghỉ việc\ncó số dư phép âm\ntrong kỳ"]
        T3_2{{"Chính sách\nTenantConfig?"}}
        T3_3["⚙️ AUTO_DEDUCT\n(cần employee_consent=true\nVLC Điều 21)"]
        T3_4["👤 HR_REVIEW\nHR Admin xem xét\nvà quyết định thủ công\n→ BLOCK export cho đến khi xong"]
        T3_5["⚙️ WRITE_OFF\nXoá nợ — ghi\nLeaveMovement ADJUST\n+ delta dương"]
        T3_6["⚙️ RULE_BASED\nÁp dụng ngưỡng:\n≤ threshold → WRITE_OFF\n> threshold → HR_REVIEW"]
        T3_1 --> T3_2
        T3_2 --> T3_3
        T3_2 --> T3_4
        T3_2 --> T3_5
        T3_2 --> T3_6
    end

    subgraph S4["Step 4 — Tạo gói xuất & Đóng kỳ"]
        direction TD
        T4_1["⚙️ Thu thập từ\nta.attendance:\ntổng giờ thường, OT, bù giờ\ntheo từng nhân viên"]
        T4_2["⚙️ Thu thập từ\nta.absence:\ntổng ngày nghỉ, khoản khấu trừ\nkhi nghỉ việc, cashout"]
        T4_3["⚙️ Tạo\nPayrollExportPackage\n(immutable, idempotent)\nchecksum = SHA256(payload)"]
        T4_4["⚙️ Period: LOCKED → CLOSED\nGhi closed_at, closed_by"]
        T4_5["⚙️ Dispatch event:\nPayrollExportCreated\n→ Module Payroll\nChờ Acknowledged"]
        T4_1 --> T4_3
        T4_2 --> T4_3
        T4_3 --> T4_4 --> T4_5
    end

    S1 --> S2 --> S3 --> S4
```

> **💡 Idempotency:** Nếu kỳ đã CLOSED mà chạy lại, hệ thống trả về gói xuất đã tồn tại, không tạo mới. Period machine chỉ đi một chiều: **OPEN → LOCKED → CLOSED**, không đảo ngược.

---

## Ma Trận Quan Hệ Giữa Các Quy Trình TA

```mermaid
flowchart TD
    ABS001["UC-ABS-001/002\nNộp & Phê duyệt\nnghỉ phép\n(Nhân viên + Quản lý)"]
    ABS003["UC-ABS-003/004/005\nĐiều chỉnh sau nộp\n(Hủy / Về sớm / HR bù số dư)"]
    ATT001["UC-ATT-001\nChấm công\nVào / Ra\n(Daily)"]
    ATT002["UC-ATT-002\nĐề xuất OT\n(Nhân viên / Quản lý)"]
    SHR002["UC-SHR-002\nLeo thang\nphê duyệt quá hạn\n(Auto / Shared)"]
    SHD001["UC-SHD-001\nChốt kỳ &\nXuất sang Payroll\n(Cuối kỳ)"]
    PR["Module PR\n(Payroll)\nNhận PayrollExportPackage\nvà tính lương"]

    ABS001 -->|"Đơn đã duyệt\ncó thể điều chỉnh"| ABS003
    ABS001 -->|"Quá hạn không duyệt\n→ tự động leo thang"| SHR002
    ATT002 -->|"OT Manager self-submit\n→ skip-level routing"| SHR002
    ATT001 -->|"WorkedPeriod →\nTimesheet chuẩn bị\ncho khóa kỳ"| SHD001
    ATT002 -->|"OT giờ → TimesheetLine\nchuẩn bị cho khóa kỳ"| SHD001
    ABS001 -->|"LeaveMovement →\nLeaveInstant snapshot\ncho khóa kỳ"| SHD001
    SHD001 -->|"PayrollExportCreated\n(giờ công + ngày nghỉ)"| PR
```

---

## Chú Thích Loại Task Trong Sơ Đồ

| Ký hiệu | Loại Task | Mô tả |
|---|---|---|
| 👤 | USER_TASK | Người dùng thực hiện: nộp, duyệt, xem xét |
| ⚙️ | SERVICE_TASK | Hệ thống tự động xử lý, tính toán, ghi dữ liệu |
| ⏱️ | TIMER | Scheduler chạy định kỳ hoặc theo điều kiện thời gian |
| 📦 | EVENT_LISTENER | Lắng nghe / chờ sự kiện (ví dụ: offline queue) |
| 🚩 | Exception Flagging | Hệ thống gắn cờ cần xử lý thủ công |
| ◇ (hình thoi) | Decision / Gateway | Điểm rẽ nhánh điều kiện |
| 🚫 | Hard Block | Hành động bị chặn hoàn toàn bởi business rule |

---

## Danh Sách Business Rules Quan Trọng

| Rule ID | Quy tắc | Quy trình áp dụng |
|---|---|---|
| BR-ABS-001 | Kiểm tra số dư trước khi RESERVE phép | UC-ABS-001 |
| BR-ABS-003 | Chỉ tính ngày làm việc thực tế (loại cuối tuần + lễ) | UC-ABS-001 |
| BR-ABS-004 | FEFO reserve: dùng phép sắp hết hạn trước | UC-ABS-001 |
| BR-ABS-006 | Cửa sổ hủy sau ngày bắt đầu (post_cancel_window_days) | UC-ABS-003 |
| BR-ABS-012 | Điều chỉnh thủ công > ngưỡng cần dual approval HR Manager | UC-ABS-005 |
| BR-ABS-013 | Curtailment phải nộp trong vòng N ngày sau khi về sớm | UC-ABS-004 |
| ADR-TA-001 | Sổ cái bất biến — chỉ ghi thêm, không sửa/xóa | Tất cả |
| ADR-TA-004 | Biometric chỉ lưu token, không lưu dữ liệu thô | UC-ATT-001 |
| BR-ATT-001 | Geofence violation không chặn Punch — chỉ cảnh báo HR | UC-ATT-001 |
| BR-ATT-004 | Quên chấm công ra → PROVISIONAL period, NV tự sửa | UC-ATT-001 |
| BR-ATT-005 | OT caps: 4h/ngày, 40h/tháng, 300h/năm (VLC 2019) | UC-ATT-002 |
| H-P0-003 | Manager tự đăng ký OT → skip-level / custom routing | UC-ATT-002 |
| BR-SHR-003 | Timeout duyệt: 48h (cấu hình được) | UC-SHR-002 |
| BR-SHR-004 | Nhắc nhở tại 50% timeout | UC-SHR-002 |
| BR-SHD-001 | Period machine: OPEN → LOCKED → CLOSED, không đảo ngược | UC-SHD-001 |
| BR-SHD-007-02 | AUTO_DEDUCT khi nghỉ việc cần employee_consent=true (VLC Điều 21) | UC-SHD-001 |

---

*Tài liệu này được tổng hợp từ các file flow trong bounded contexts: `absence/flows/`, `attendance/flows/`, `shared/flows/`. Để xem chi tiết đầy đủ, tham khảo từng file `*.flow.md` trong thư mục tương ứng. File `[Depricated].approve-leave-request.flow.md` đã lỗi thời và được bỏ qua.*
