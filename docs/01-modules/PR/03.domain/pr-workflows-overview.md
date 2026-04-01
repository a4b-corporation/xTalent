# Tổng Quan Quy Trình Nghiệp Vụ — Module Payroll (PR)

**Module**: Payroll (PR)
**Phiên bản**: 1.0
**Ngày**: 2026-04-01

> Tài liệu này tổng hợp toàn bộ các quy trình (workflow) thuộc module Payroll, được đọc từ các file `*.flow.md` của từng bounded context. Mỗi quy trình được trình bày bằng tiếng Việt với sơ đồ Mermaid thể hiện cấu trúc các bước theo phong cách A4B Workflow Designer: **các Step là các group LR (horizontal), bên trong mỗi Step là các task chạy từ trên xuống (TD)**.

---

## Tổng Quan Các Bounded Context Có Quy Trình

| Bounded Context | Quy Trình | Bounded Context Code |
|---|---|---|
| Payroll Execution | UCF-01 Tính lương tháng chính thức | BC-03 |
| Payroll Execution | UCF-02 Tính lương theo giờ | BC-03 |
| Payroll Execution | UCF-03 Tính lương theo sản phẩm | BC-03 |
| Payroll Execution | UCF-04 Điều chỉnh lương hồi tố | BC-03 |
| Payroll Execution | UCF-05 Quyết toán thuế TNCN năm | BC-03 |
| Statutory Rules | UCF-06 Cập nhật quy tắc pháp định | BC-02 |
| Payment Output | UCF-07 Thanh toán cuối cùng khi nghỉ việc | BC-04 |

---

## UCF-01: Tính Lương Tháng Chính Thức (Monthly Payroll Execution)

### Ý nghĩa & Mục đích

Đây là quy trình **cốt lõi và quan trọng nhất** của module Payroll. Quy trình này chạy theo chu kỳ hàng tháng, tự động kết hợp dữ liệu chấm công từ module TA, dữ liệu lương từ module TR, và các quy tắc pháp định (BHXH, BHYT, BHTN, PIT) để tính ra **lương thực nhận cho từng nhân viên**.

**Mục đích:**
- Đảm bảo tính lương chính xác, đúng quy định pháp luật Việt Nam
- Cung cấp cơ chế kiểm soát rủi ro thông qua ba lớp duyệt (Payroll Admin → HR Manager → Finance Manager)
- Tạo ra dữ liệu kết quả bất biến (immutable) sau khi khóa kỳ lương

**Tác nhân:** Scheduler / Payroll Admin → Hệ thống (Drools) → HR Manager → Finance Manager

**Kích hoạt:** Đến ngày chốt kỳ (cut-off date) hoặc Payroll Admin thủ công kích hoạt

```mermaid
flowchart LR
    subgraph S1["Step 1 — Chốt kỳ lương"]
        direction TD
        T1_1["⚙️ Hệ thống / Admin\nApply Cut-Off\n(PayPeriod: OPEN → CUT_OFF)"]
        T1_2["⚙️ Hệ thống\nTạo CompensationSnapshot\ncho từng nhân viên\n(lấy dữ liệu từ CO & TR)"]
        T1_1 --> T1_2
    end

    subgraph S2["Step 2 — Khởi tạo & Kiểm tra trước"]
        direction TD
        T2_1["👤 Payroll Admin\nInitiate Payroll Run\n(PRODUCTION / DRY_RUN)"]
        T2_2{{"⚙️ Pre-Validation\nKiểm tra đủ điều kiện\n(chấm công, quy tắc,\ncông thức, snapshot)"}}
        T2_3["❌ FAILED\nThông báo lỗi\n→ Payroll Admin xử lý"]
        T2_4["✅ PASSED\nPayrollRun: RUNNING"]
        T2_1 --> T2_2
        T2_2 -->|"Thất bại"| T2_3
        T2_2 -->|"Thành công"| T2_4
    end

    subgraph S3["Step 3 — Tính lương (Drools Engine)"]
        direction TD
        T3_1["⚙️ BATCH\nTính lương gộp (Gross)\ntheo phương pháp:\nMONTHLY / HOURLY /\nPIECE_RATE / GRADE_STEP /\nTASK_BASED"]
        T3_2["⚙️ Tính BHXH/BHYT/BHTN\n(tỷ lệ NLĐ: 8+1.5+1%)\nKiểm tra trần đóng BHXH"]
        T3_3["⚙️ Tính thuế TNCN\n7 bậc luỹ tiến\n(NQ 954/2020)\nhoặc 20% flat NNN"]
        T3_4["⚙️ Tính lương Net\nNet = Gross − BHXH − PIT\n− Các khoản trừ khác"]
        T3_5["🚩 Gắn cờ ngoại lệ\n(NEGATIVE_NET / OT_CAP /\nMIN_WAGE / ZERO_BHXH)"]
        T3_1 --> T3_2 --> T3_3 --> T3_4 --> T3_5
    end

    subgraph S4["Step 4 — Xử lý ngoại lệ & Nộp duyệt"]
        direction TD
        T4_1["👤 Payroll Admin\nXem xét & Acknowledge\ntừng ngoại lệ"]
        T4_2["👤 Payroll Admin\nSubmit For Approval\n(PayrollRun: PENDING_APPROVAL)"]
        T4_1 --> T4_2
    end

    subgraph S5["Step 5 — Phê duyệt đa cấp"]
        direction TD
        T5_1["👤 HR Manager\nKiểm tra & Phê duyệt\nCấp 2 (Level 2)"]
        T5_2{{"Kết quả L2"}}
        T5_3["❌ Từ chối → Payroll Admin\nchỉnh sửa, nộp lại"]
        T5_4["👤 Finance Manager\nKiểm tra & Phê duyệt\nCấp 3 (Level 3)"]
        T5_5{{"Kết quả L3"}}
        T5_6["✅ PayrollRun: APPROVED"]
        T5_1 --> T5_2
        T5_2 -->|"Từ chối"| T5_3
        T5_2 -->|"Duyệt"| T5_4
        T5_4 --> T5_5
        T5_5 -->|"Từ chối"| T5_3
        T5_5 -->|"Duyệt"| T5_6
    end

    subgraph S6["Step 6 — Khóa kỳ lương"]
        direction TD
        T6_1["⚙️ Hệ thống\nLock Period\nPayPeriod: APPROVED → LOCKED"]
        T6_2["⚙️ Sinh integrity hash\n(SHA-256) cho mỗi kết quả"]
        T6_3["⚙️ Kích hoạt downstream:\n• BC-04: File ngân hàng,\n  GL Journal, Payslip\n• BC-05: Báo cáo BHXH"]
        T6_1 --> T6_2 --> T6_3
    end

    S1 --> S2 --> S3 --> S4 --> S5 --> S6
```

> **💡 Lưu ý thiết kế:** Kết quả lương (PayrollResult) sau khi kỳ bị khóa là **bất biến tuyệt đối** — không được sửa trực tiếp. Mọi điều chỉnh phải đi qua quy trình Hồi tố (UCF-04).

---

## UCF-02: Tính Lương Theo Giờ (Hourly Worker Pay)

### Ý nghĩa & Mục đích

Đây là **quy trình con** chạy bên trong Bước 6 của UCF-01 (Step 6B), dành riêng cho nhân viên có hình thức trả lương theo giờ (`pay_method = HOURLY`). Quy trình này xử lý đặc thù của lao động hưởng lương giờ: phân loại ca làm việc, tính phụ cấp ca đêm, nhân hệ số làm thêm giờ (OT).

**Mục đích:**
- Tính đúng thu nhập theo từng loại ca làm việc (thường, đêm, OT ngày thường, OT cuối tuần, OT ngày lễ)
- Áp dụng đúng hệ số OT theo quy định Bộ Luật Lao động (150% / 200% / 300%)
- Kiểm tra vi phạm lương tối thiểu vùng và giới hạn giờ OT tháng

**Tác nhân:** Hệ thống (Drools Engine)

**Kích hoạt:** Khi PayrollRun đến bước tính lương gộp (Step 6 UCF-01) cho nhân viên HOURLY

```mermaid
flowchart LR
    subgraph S1["Step 1 — Tải dữ liệu"]
        direction TD
        T1_1["⚙️ Load HourlyRateConfig\n(bảng đơn giá theo\nloại ca × bậc lương)"]
        T1_2["⚙️ Load dữ liệu chấm công\ntừ CompensationSnapshot\n(giờ thường, đêm, OT\nngày thường/cuối tuần/lễ)"]
        T1_1 --> T1_2
    end

    subgraph S2["Step 2 — Tính thu nhập từng ca"]
        direction TD
        T2_1["⚙️ Tính lương ca thường\n= rate × giờ thường"]
        T2_2["⚙️ Tính phụ cấp ca đêm\n= rate × giờ đêm\n(+30% night supplement)"]
        T2_3["⚙️ OT Ngày thường\n= rate × 150% × giờ OT"]
        T2_4["⚙️ OT Cuối tuần\n= rate × 200% × giờ OT"]
        T2_5["⚙️ OT Ngày lễ\n= rate × 300% × giờ OT"]
        T2_6["⚙️ Tổng Gross Hourly\n= tổng tất cả ca"]
        T2_1 --> T2_6
        T2_2 --> T2_6
        T2_3 --> T2_6
        T2_4 --> T2_6
        T2_5 --> T2_6
    end

    subgraph S3["Step 3 — Kiểm tra & Bàn giao"]
        direction TD
        T3_1["⚙️ Kiểm tra giới hạn\ngiờ OT tháng\n(mặc định 40h/tháng)"]
        T3_2["⚙️ Kiểm tra lương\ntối thiểu vùng\n(Nghị định 38/2022)"]
        T3_3["⚙️ Bàn giao hourly_gross\ncho UCF-01 Step 7\n(tính BHXH, PIT)"]
        T3_1 --> T3_3
        T3_2 --> T3_3
    end

    S1 --> S2 --> S3
```

---

## UCF-03: Tính Lương Theo Sản Phẩm (Piece-Rate Pay)

### Ý nghĩa & Mục đích

Quy trình con chạy trong Bước 6C của UCF-01, dành cho nhân viên hưởng lương khoán sản phẩm (`pay_method = PIECE_RATE`). Điển hình trong môi trường sản xuất, gia công, may mặc. Điểm đặc biệt là thu nhập phụ thuộc hoàn toàn vào số lượng sản phẩm và chất lượng.

**Mục đích:**
- Tính thu nhập dựa trên bảng đơn giá sản phẩm × số lượng × hệ số chất lượng
- Tự động bù lương tối thiểu vùng nếu sản lượng quá thấp
- Xác định cơ sở đóng BHXH cho lao động khoán (PIECE_RATE_GROSS hoặc BASE_EQUIVALENT)

**Tác nhân:** Hệ thống (Drools Engine)

**Kích hoạt:** Khi PayrollRun đến Step 6 của UCF-01 cho nhân viên PIECE_RATE

```mermaid
flowchart LR
    subgraph S1["Step 1 — Tải dữ liệu sản xuất"]
        direction TD
        T1_1["⚙️ Đọc dữ liệu sản lượng\ntừ TA (AttendanceLocked)\n{mã SP, cấp chất lượng,\nsố lượng}"]
        T1_2["⚙️ Tra cứu PieceRateTable\n→ đơn giá theo\n(mã SP × chất lượng)\nđúng ngày hiệu lực"]
        T1_1 --> T1_2
    end

    subgraph S2["Step 2 — Tính lương khoán"]
        direction TD
        T2_1["⚙️ Áp dụng hệ số\nchất lượng\n(A=1.0 / B=0.95 / C=0.85)"]
        T2_2["⚙️ Tính từng dòng SP\n= số lượng × đơn giá\n× hệ số chất lượng"]
        T2_3["⚙️ Cộng phụ cấp cố định\n(ăn trưa, đi lại\n— proration=NONE)"]
        T2_4["⚙️ piece_gross = tổng\ntất cả dòng sản phẩm\n+ phụ cấp cố định"]
        T2_1 --> T2_2 --> T2_4
        T2_3 --> T2_4
    end

    subgraph S3["Step 3 — Sàn lương & BHXH"]
        direction TD
        T3_1{{"⚙️ piece_gross ≥\nlương tối thiểu vùng?"}}
        T3_2["⚙️ Bổ sung MINIMUM_WAGE\n_SUPPLEMENT\n(tự động, không cần\nphê duyệt)"]
        T3_3["⚙️ Xác định cơ sở BHXH\n(PIECE_RATE_GROSS\nhoặc BASE_EQUIVALENT)"]
        T3_4["⚙️ Bàn giao gross\ncho UCF-01 Step 7"]
        T3_1 -->|"Dưới sàn"| T3_2
        T3_2 --> T3_3
        T3_1 -->|"Đạt"| T3_3
        T3_3 --> T3_4
    end

    S1 --> S2 --> S3
```

---

## UCF-04: Điều Chỉnh Lương Hồi Tố (Retroactive Salary Adjustment)

### Ý nghĩa & Mục đích

Khi HR điều chỉnh lương ngược về quá khứ (ví dụ: tăng lương từ 3 tháng trước mới nhận được phê duyệt), hệ thống phải tính lại các kỳ lương đã khóa để xác định **số tiền còn thiếu hoặc còn thừa**, sau đó bù vào kỳ lương hiện tại.

**Mục đích:**
- Đảm bảo nhân viên nhận đúng số tiền theo thay đổi lương hồi tố, dù đã qua nhiều kỳ lương
- Bảo vệ tính toàn vẹn: **KHÔNG sửa kết quả lương đã khóa**, chỉ tạo bút toán điều chỉnh trong kỳ mở
- Kiểm soát rủi ro thông qua giới hạn hồi tố 12 kỳ và ngưỡng phê duyệt

**Tác nhân:** HR Manager (khởi tạo tại CO/TR) → Hệ thống → Payroll Admin → HR Manager (duyệt)

**Kích hoạt:** Sự kiện `CompensationChangeBackdated` từ module CO/TR

```mermaid
flowchart LR
    subgraph S1["Step 1 — Nhận & Phân tích"]
        direction TD
        T1_1["📨 System nhận event\nCompensationChangeBackdated\n(loại thay đổi, ngày hiệu lực,\ngiá trị cũ/mới)"]
        T1_2["⚙️ Xác định các kỳ\nbị ảnh hưởng\n(tối đa 12 kỳ đã khóa)"]
        T1_3["⚙️ Kiểm tra lock đồng thời\n(HS-7: không xử lý\n2 hồi tố cùng NV\ncùng lúc)"]
        T1_1 --> T1_2 --> T1_3
    end

    subgraph S2["Step 2 — Tính Delta"]
        direction TD
        T2_1["⚙️ BATCH: Tính lại từng kỳ\nvới giá trị lương mới\n(dùng quy tắc pháp định\ncủa từng kỳ gốc)"]
        T2_2["⚙️ delta = revised_net\n− original_net\ncho mỗi kỳ"]
        T2_3["⚙️ total_retro_delta\n= tổng tất cả các delta"]
        T2_1 --> T2_2 --> T2_3
    end

    subgraph S3["Step 3 — Xem xét & Phê duyệt"]
        direction TD
        T3_1["👤 Payroll Admin\nXem bảng delta\ntheo từng kỳ"]
        T3_2{{"Tổng delta >\nnguỡng phê duyệt?"}}
        T3_3["👤 HR Manager\nPhê duyệt điều chỉnh"]
        T3_4["⚙️ Auto-approve\n(dưới ngưỡng 1M VND)"]
        T3_1 --> T3_2
        T3_2 -->|"Có"| T3_3
        T3_2 -->|"Không"| T3_4
    end

    subgraph S4["Step 4 — Áp dụng vào kỳ mở"]
        direction TD
        T4_1{{"delta > 0\n(thiếu) hay < 0\n(thừa)?"}}
        T4_2["⚙️ Tạo phần tử\nRETRO_ADJUSTMENT\n(thu nhập +) trong kỳ mở"]
        T4_3["⚙️ Tạo phần tử\nRETRO_RECOVERY\n(khấu trừ) trong kỳ mở\n(kiểm tra không gây net < 0)"]
        T4_4["⚙️ Giải phóng lock\nxử lý hàng đợi tiếp theo"]
        T4_1 -->|"Thiếu"| T4_2
        T4_1 -->|"Thừa"| T4_3
        T4_2 --> T4_4
        T4_3 --> T4_4
    end

    S1 --> S2 --> S3 --> S4
```

> **💡 Nguyên tắc bất biến:** Kết quả lương các kỳ đã khóa **không được sửa**. Hồi tố chỉ ghi bổ sung vào kỳ hiện tại như một phần tử lương riêng.

---

## UCF-05: Quyết Toán Thuế TNCN Năm (Annual PIT Settlement)

### Ý nghĩa & Mục đích

Cuối năm thuế (hoặc khi nhân viên nghỉ việc), hệ thống phải đối chiếu **tổng thuế TNCN đã khấu trừ hàng tháng** với **số thuế thực tế phải nộp theo biểu luỹ tiến cả năm**. Nếu khấu trừ nhiều hơn → hoàn thuế; ít hơn → thu thêm.

**Mục đích:**
- Thực hiện nghĩa vụ quyết toán thuế theo Luật Thuế TNCN Việt Nam (hạn nộp: 31/3 năm sau)
- Xử lý đúng các trường hợp phức tạp: thay đổi cư trú giữa năm, nhân viên có nhiều nguồn thu nhập
- Tạo chứng từ khấu trừ thuế (Form 05/QTT-TNCN) cho từng nhân viên

**Tác nhân:** Payroll Admin → Hệ thống → HR Manager → Finance Manager

**Kích hoạt:** Payroll Admin ra lệnh `TriggerAnnualPitSettlement` cho năm thuế; hoặc tự động khi nhân viên nghỉ việc (từ UCF-07)

```mermaid
flowchart LR
    subgraph S1["Step 1 — Khởi tạo"]
        direction TD
        T1_1["👤 Payroll Admin\nTriggerAnnualPitSettlement\n(năm thuế, pay_group)"]
        T1_2["⚙️ Tạo PayrollRun\nrun_type=ANNUAL_SETTLEMENT\nState: QUEUED → RUNNING"]
        T1_1 --> T1_2
    end

    subgraph S2["Step 2 — Tổng hợp thu nhập năm"]
        direction TD
        T2_1["⚙️ Tổng hợp từ 12 kỳ\nđã khóa:\nYTD_gross, YTD_SI,\nYTD_PIT đã khấu trừ"]
        T2_2["⚙️ Tính giảm trừ năm:\n• 132M (bản thân)\n• 4.4M × số người phụ thuộc\n× số tháng hợp lệ"]
        T2_3["⚙️ ANNUAL_TAXABLE\n= YTD_gross − YTD_SI\n− giảm trừ bản thân\n− giảm trừ người phụ thuộc"]
        T2_1 --> T2_2 --> T2_3
    end

    subgraph S3["Step 3 — Tính thuế & Delta"]
        direction TD
        T3_1{{"Cư trú?"}}
        T3_2["⚙️ Cư trú: áp biểu luỹ tiến\n7 bậc năm (12× bậc tháng)\ntheo NQ 954/2020"]
        T3_3["⚙️ Không cư trú:\nThuế = YTD_gross × 20%"]
        T3_4["⚙️ settlement_delta\n= annual_pit_liability\n− YTD_pit_withheld"]
        T3_5["🚩 Gắn cờ ngoại lệ\n(chênh lệch lớn,\nthay đổi cư trú,\nnhiều nguồn thu)"]
        T3_1 -->|"Cư trú"| T3_2
        T3_1 -->|"Không cư trú"| T3_3
        T3_2 --> T3_4
        T3_3 --> T3_4
        T3_4 --> T3_5
    end

    subgraph S4["Step 4 — Duyệt & Áp dụng"]
        direction TD
        T4_1["👤 Payroll Admin\nXem xét kết quả\nAcknowledge ngoại lệ"]
        T4_2["👤 HR Manager + Finance\nPhê duyệt đa cấp\n(như UCF-01)"]
        T4_3{{"delta > 0\nhay < 0?"}}
        T4_4["⚙️ Tạo ANNUAL_PIT\n_SETTLEMENT_DEDUCTION\n(thu thêm)"]
        T4_5["⚙️ Tạo ANNUAL_PIT\n_SETTLEMENT_REFUND\n(hoàn thuế)"]
        T4_6["⚙️ BC-05 phát hành\nchứng từ 05/QTT-TNCN\nBC-06 cho NV tải về"]
        T4_1 --> T4_2 --> T4_3
        T4_3 -->|"Thiếu"| T4_4
        T4_3 -->|"Hoàn"| T4_5
        T4_4 --> T4_6
        T4_5 --> T4_6
    end

    S1 --> S2 --> S3 --> S4
```

> **⚠️ Rủi ro quan trọng:** Trường hợp nhân viên nước ngoài đạt ngưỡng cư trú 183 ngày trong năm là edge case phức tạp nhất — toàn bộ thu nhập cả năm cần tính lại theo biểu luỹ tiến (thay vì 20% flat). Cần đối chiếu hồ sơ nhập cảnh từ module CO.

---

## UCF-06: Cập Nhật Quy Tắc Pháp Định (Statutory Rule Update)

### Ý nghĩa & Mục đích

Khi Chính phủ ban hành nghị định mới thay đổi các thông số pháp định (mức lương cơ sở, tỷ lệ BHXH, biểu thuế TNCN, lương tối thiểu vùng), Platform Admin phải nhập và kích hoạt quy tắc mới trong hệ thống **trước khi kỳ lương tiếp theo chạy**.

**Mục đích:**
- Đảm bảo mọi tính toán lương luôn sử dụng đúng thông số pháp định hiện hành
- Kiểm soát lịch sử phiên bản quy tắc — không được xóa, chỉ được supersede
- Tự động thông báo các Payroll Admin khi có quy tắc mới ảnh hưởng đến kỳ lương đang mở

**Tác nhân:** Platform Admin

**Kích hoạt:** Khi Chính phủ ban hành Nghị định / Thông tư mới (ví dụ: NĐ 73/2024, NQ 954/2020)

```mermaid
flowchart LR
    subgraph S1["Step 1 — Tạo quy tắc Draft"]
        direction TD
        T1_1["👤 Platform Admin\nCreateStatutoryRule\n(loại quy tắc, ngày hiệu lực,\ncông thức, mã nghị định)"]
        T1_2["⚙️ Kiểm tra schema\ncông thức hợp lệ\n→ StatutoryRule: DRAFT"]
        T1_3["⚙️ Kiểm tra trùng lặp:\nCó quy tắc cùng loại\nbị chồng ngày không?"]
        T1_1 --> T1_2 --> T1_3
    end

    subgraph S2["Step 2 — Kích hoạt"]
        direction TD
        T2_1["👤 Platform Admin\nKiểm tra lại thông số\ntrong cổng quản trị"]
        T2_2["👤 Platform Admin\nActivateStatutoryRule"]
        T2_3["⚙️ DRAFT → ACTIVE\nQuy tắc cũ → SUPERSEDED\n(đặt valid_to = hiệu lực mới − 1)"]
        T2_4["⚙️ Phát sự kiện:\nStatutoryRuleActivated\n+ sự kiện chuyên biệt\n(PitBracketsUpdated /\nSiCeilingUpdated /\nMinimumWageUpdated)"]
        T2_1 --> T2_2 --> T2_3 --> T2_4
    end

    subgraph S3["Step 3 — Cập nhật hệ thống"]
        direction TD
        T3_1["⚙️ BC-03 (Payroll Engine)\nInvalidate rule cache\n→ dùng quy tắc mới\ncho run tiếp theo"]
        T3_2["⚙️ Kiểm tra lại công thức\ncủa các PayElement\nđang ACTIVE phụ thuộc\nquy tắc vừa cập nhật"]
        T3_3["⚙️ Notify tất cả\nPayroll Admin:\n• Rule mới hiệu lực\n• Cảnh báo nếu kỳ mở\n  sắp đến ngày chốt"]
        T3_1 --> T3_2 --> T3_3
    end

    S1 --> S2 --> S3
```

> **⚠️ Rủi ro vận hành:** Nghị định thường có hiệu lực sớm sau khi ban hành. Platform Admin phải theo dõi Cổng thông tin điện tử Chính phủ và nhập kịp thời trước ngày chốt kỳ lương. Nếu kích hoạt quy tắc khi đang có run đang chạy, run hiện tại dùng cache cũ; chỉ run tiếp theo mới dùng quy tắc mới.

---

## UCF-07: Thanh Toán Cuối Cùng Khi Nghỉ Việc (Termination Final Pay)

### Ý nghĩa & Mục đích

Khi nhân viên nghỉ việc, hệ thống phải tính và thanh toán toàn bộ các khoản còn lại: **lương tháng chưa thanh toán, tiền phép năm còn dư, trợ cấp thôi việc** (nếu có), đồng thời thực hiện quyết toán thuế TNCN cho các tháng trong năm ngay tại thời điểm nghỉ việc.

**Mục đích:**
- Thực hiện đúng nghĩa vụ thanh toán khi chấm dứt hợp đồng lao động (Bộ Luật Lao động)
- Tạo hồ sơ cuối cùng đầy đủ: phiếu lương, file ngân hàng, chứng từ khấu trừ thuế
- Xử lý thu hồi các khoản vay/ứng lương còn tồn đọng trước khi chi trả

**Tác nhân:** Hệ thống (CO) → Payroll Admin → HR Manager → Finance Manager

**Kích hoạt:** Sự kiện `WorkerTerminated` từ module Core HR (CO)

```mermaid
flowchart LR
    subgraph S1["Step 1 — Tiếp nhận từ CO"]
        direction TD
        T1_1["📨 CO phát sự kiện\nWorkerTerminated\n(working_relationship_id,\ntermination_date, loại nghỉ)"]
        T1_2["⚙️ PR tạo PayPeriod\noff-cycle loại TERMINATION\n(từ cuối kỳ đã thanh toán\nđến ngày nghỉ việc)"]
        T1_3["⚙️ Chụp\nCompensationSnapshot\ntại ngày nghỉ việc\n(immutable)"]
        T1_1 --> T1_2 --> T1_3
    end

    subgraph S2["Step 2 — Xác định & Tính các khoản"]
        direction TD
        T2_1["👤 Payroll Admin\nXem xét và chọn\ncác phần tử lương:\n• Lương tháng (pro-rate)\n• Tiền phép năm còn dư\n• Trợ cấp thôi việc\n• Thu hồi ứng lương"]
        T2_2["⚙️ Drools tính Gross:\nPro-rate lương theo ngày\nthực tế đến ngày nghỉ"]
        T2_3["⚙️ Tính BHXH pro-rate\ncho kỳ bán phần\n(BR-033 split-period SI)"]
        T2_4["⚙️ Tính PIT cuối cùng:\nCộng dồn YTD + khoản\nchi trả cuối → quyết toán\ntại thời điểm nghỉ việc"]
        T2_5["⚙️ Net = Gross − BHXH\n− PIT − thu hồi\nKiểm tra net < 0"]
        T2_1 --> T2_2 --> T2_3 --> T2_4 --> T2_5
    end

    subgraph S3["Step 3 — Phê duyệt"]
        direction TD
        T3_1["👤 HR Manager\nPhê duyệt Level 2"]
        T3_2["👤 Finance Manager\nPhê duyệt Level 3"]
        T3_1 --> T3_2
    end

    subgraph S4["Step 4 — Xuất kết quả"]
        direction TD
        T4_1["⚙️ Khóa kỳ lương\n+ sinh integrity hash"]
        T4_2["⚙️ BC-04:\nSinh phiếu lương cuối\n(PDF đầy đủ chi tiết)"]
        T4_3["⚙️ BC-04:\nSinh file thanh toán\nngân hàng (net pay\nchuyển khoản lần cuối)"]
        T4_4["⚙️ BC-05:\nSinh chứng từ khấu trừ\nthuế 05/QTT-TNCN\n(nếu yêu cầu)"]
        T4_5["⚙️ BC-07:\nGhi audit log\ntoàn bộ quá trình"]
        T4_1 --> T4_2 --> T4_3 --> T4_4 --> T4_5
    end

    S1 --> S2 --> S3 --> S4
```

---

## Ma Trận Quan Hệ Giữa Các Quy Trình

```mermaid
flowchart TD
    UCF06["UCF-06\nCập nhật quy tắc\npháp định\n(Platform Admin)"]
    UCF01["UCF-01\nTính lương tháng\nchính thức\n(Payroll Admin)"]
    UCF02["UCF-02\nLương theo giờ\n(sub-flow)"]
    UCF03["UCF-03\nLương theo sản phẩm\n(sub-flow)"]
    UCF04["UCF-04\nĐiều chỉnh\nhồi tố"]
    UCF05["UCF-05\nQuyết toán\nthuế TNCN năm"]
    UCF07["UCF-07\nThanh toán\nkhi nghỉ việc"]

    UCF06 -->|"Quy tắc được áp dụng\ntrong mọi run tính lương"| UCF01
    UCF01 -->|"Step 6B (HOURLY)"| UCF02
    UCF01 -->|"Step 6C (PIECE_RATE)"| UCF03
    UCF01 -->|"Kỳ LOCKED kích hoạt\nphát hiện hồi tố"| UCF04
    UCF01 -->|"12 kỳ LOCKED\nkích hoạt quyết toán"| UCF05
    UCF07 -->|"Tích hợp quyết toán\nPIT ngay khi nghỉ"| UCF05
    CO["Core HR (CO)\nWorkerTerminated event"] -->|"Kích hoạt"| UCF07
    COTR["CO / TR Module\nCompensationChangeBackdated"] -->|"Kích hoạt"| UCF04
```

---

## Chú Thích Loại Task Trong Sơ Đồ

| Ký hiệu | Loại Task | Mô tả |
|---|---|---|
| 👤 | USER_TASK (ApprovalUserTaskTemplate) | Người dùng thực hiện: duyệt, xem xét, nộp |
| ⚙️ | SERVICE_TASK / BATCH_PROCESSING_TASK | Hệ thống tự động xử lý |
| 📨 | EVENT_LISTENER | Lắng nghe sự kiện từ module khác |
| 🚩 | SERVICE_TASK (exception flagging) | Hệ thống gắn cờ ngoại lệ |
| ◇ (hình thoi) | Decision / Gateway | Điểm rẽ nhánh điều kiện |

---

*Tài liệu này được tổng hợp từ các file flow trong bounded contexts: `payroll-execution/flows/`, `statutory-rules/flows/`, `payment-output/flows/`. Để xem chi tiết đầy đủ, tham khảo từng file `ucf-XX-*.flow.md` trong thư mục tương ứng.*
