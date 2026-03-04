# PS-03: As-Is System Landscape — Hệ Sinh Thái HR Mà Doanh Nghiệp Đang Vận Hành

> *Tài liệu này mô tả trạng thái thực tế của hệ sinh thái phần mềm nhân sự tại các doanh nghiệp Việt Nam quy mô 5.000-10.000 nhân sự. Đây không phải kiến trúc lý tưởng — đây là bức tranh thực tế với đầy đủ vết nứt, mảng vá, và giải pháp tạm thời đã trở thành cố hữu.*

---

## I. BA LOẠI HỆ THỐNG ĐANG TỒN TẠI

### 1.1. Loại A — "Phần Mềm Nội Địa Đã Vượt Qua Giới Hạn Thiết Kế"

**Phần mềm điển hình:** Base HRM, MISA AMIS HRM, 1Office, Fast HR, SureHCS, VnResource, bTaskee HR

**Hành trình điển hình:**
> Mua khi công ty có 300-500 nhân sự. Phần mềm đủ dùng. Theo thời gian, công ty lên 3.000, 5.000, 7.000 người — nhưng phần mềm vẫn như cũ, hoặc version mới hơn nhưng kiến trúc không thay đổi cơ bản.

**Điểm mạnh trong hoàn cảnh hiện tại:**
- Giao diện tiếng Việt hoàn toàn
- Hỗ trợ cục bộ, vendor hiểu luật Việt Nam
- Chi phí thấp (VND 1-5 triệu/user/năm)
- Đã "đủ quen" để đội HR không muốn đổi

**Điểm yếu khi scale lên 5.000+:**
- **Multi-entity:** Không có kiến trúc holding/subsidiary thực sự. Pháp nhân = trường dropdown, không phải boundary dữ liệu độc lập
- **Payroll engine:** Thiết kế cho 100-500 nhân sự. Scale lên 5.000 = timeout, crash
- **Analytics:** Báo cáo tĩnh, export Excel. Không có BI layer, không có drill-down
- **API:** Hạn chế hoặc không có. Integration với hệ thống khác = phải viết custom connector
- **Global mobility:** Không hỗ trợ. Expat và cross-border = xử lý ngoài hệ thống
- **Customization ceiling:** Đã chạm giới hạn. Mỗi yêu cầu mới = chờ vendor roadmap 6-18 tháng

**Technical reality:**
```
Kiến trúc: Monolithic (thường là .NET or PHP truyền thống)
Database: MySQL hoặc MSSQL, không partition-ready
Multi-tenancy: Shared schema, company_id là foreign key
API: REST API phần nào, thường thiếu dokumentation
Deployment: On-premise phổ biến nhất, cloud đang chuyển dần
Data model: Thiết kế cho transactional, không cho analytics
```

**Quote từ thực tế:**
> *"Chúng tôi gọi điện cho vendor mỗi khi BHXH thay đổi. Họ nói 'đang update, chờ 2 tháng.' Trong 2 tháng đó, chúng tôi tính tay. Rồi họ update thì chúng tôi phải nhập lại hết."*
— HR Manager, công ty FMCG 4.500 nhân sự

---

### 1.2. Loại B — "Customize Open Source: Tự Do Đến Khi Bị Bẫy"

**Nền tảng điển hình:** Odoo Community 12/14/16, OrangeHRM, OpenHRMS

**Hành trình điển hình:**
> Tư vấn công nghệ đề xuất "giải pháp mở, linh hoạt, chi phí thấp." Ký hợp đồng với đơn vị triển khai. 6 tháng đầu đầy hứa hẹn. Sau 2-3 năm, hàng trăm tính năng đã được customize — nhưng team dev đã thay đổi, không ai dám nâng version.

**Điểm mạnh ban đầu:**
- Linh hoạt: có thể customize gần như mọi thứ
- Open source: không bị lock vào vendor cụ thể
- Ecosystem lớn: nhiều module cộng đồng sẵn có
- Chi phí license thấp ban đầu

**Điểm yếu theo thời gian:**

| Vấn đề | Mô tả | Hậu quả |
|:---|:---|:---|
| **Version Lock Hell** | Customize quá sâu → không thể upgrade | Đang dùng Odoo 12 (released 2018) vào 2025 |
| **Knowledge Silos** | Developer "hiểu hệ thống" đã nghỉ | Không ai dám sửa code core |
| **Technical Debt Spiral** | Mỗi lần vá = thêm nợ kỹ thuật | Chi phí maintenance tăng theo năm |
| **Performance Degradation** | Không optimize cho scale lớn | Payroll 5.000 nhân sự: 24-72 giờ |
| **Security Holes** | Custom code không được security review | Rủi ro data breach |
| **No Single Vendor** | Vấn đề = blame game giữa Odoo community, vendor triển khai, và IT nội bộ | Không ai chịu trách nhiệm |

**Odoo Community HR Stack thực tế tại doanh nghiệp Việt Nam:**

```
Odoo Community 12/14 (2018-2020 vintage)
├── hr module (core) - được customize nặng
├── hr_attendance - thường được thay bằng module 3rd party
├── hr_payroll - CRITICAL: 3.5s/payslip = ~5h cho 5.000 nhân viên
│   └── Custom salary rules: 60+ rules, lồng nhau phức tạp
├── hr_recruitment - thường thiếu ATS đích thực
├── hr_contract - customize cho luật VN
├── hr_leaves - tương đối ổn
└── Custom modules:
    ├── vn_bhxh (custom BHXH calculation) - thường lỗi khi luật thay đổi
    ├── vn_pit (custom thuế TNCN) - 7 bậc, giảm trừ gia cảnh
    ├── vn_shift (ca kíp - thường được xây thêm)
    └── vn_multi_entity (thường là patch không đầy đủ)
```

**Odoo 12 Multi-Company Architecture Problem:**

Đây là vấn đề kiến trúc nghiêm trọng nhất, ảnh hưởng trực tiếp đến doanh nghiệp tập đoàn:

```python
# Cách Odoo 12 handle multi-company
# company_id là property field, không phải hard boundary

class HrEmployee(models.Model):
    company_id = fields.Many2one(
        'res.company', 
        company_dependent=True  # Đây là vấn đề!
        # Dữ liệu hiển thị dựa trên session context
        # Không phải physical data separation
    )
```

Hậu quả: Khi user có quyền truy cập nhiều company, họ có thể vô tình:
- Tạo hợp đồng cho employee A nhưng assign sang company B
- Xem lương của employee từ company khác nếu security rule không đúng
- Generate payroll batch trộn lẫn records từ nhiều entities

**Thực tế đã xảy ra:**
> *"Chúng tôi phát hiện nhân viên X (công ty con) được nhìn thấy trong payroll của công ty mẹ vì user permission không được set đúng. Không ai biết điều này đã xảy ra bao lâu."*
— IT Director, tập đoàn bán lẻ

---

### 1.3. Loại C — "Tự Phát Triển: Sản Phẩm Của Thời Kỳ Không Có Lựa Chọn"

**Hành trình điển hình:**
> Năm 2015-2018, không có phần mềm HR Việt Nam nào phù hợp cho scale lớn. Doanh nghiệp quyết định thuê team xây riêng. Budget: VND 2-8 tỷ. Timeline: 18-36 tháng. Mục tiêu: hệ thống hoàn toàn phù hợp với đặc thù doanh nghiệp.

**Điểm mạnh ban đầu:**
- Hoàn toàn tuỳ chỉnh theo nghiệp vụ nội bộ
- Không phụ thuộc vendor
- Giao diện và workflow đúng ý muốn

**Điểm yếu theo thời gian — "The In-house Trap":**

| Dimension | Thực trạng |
|:---|:---|
| **Scope creep** | Từ "hệ thống HR đơn giản" → thành 200k dòng code, feature liên tục thêm |
| **No roadmap** | Không có product owner thực sự. Feature = request từ phòng ban |
| **Bus factor = 1-2** | 1-2 developer "biết toàn bộ hệ thống." Khi họ nghỉ → crisis |
| **No QA** | Bug chỉ phát hiện khi production breaks |
| **Security debt** | Không có security review chu kỳ |
| **Legal lag** | Mỗi thay đổi luật = emergency patch sprint |
| **No community** | Không có user community, forum, documentation ngoài |
| **Tech stack cũ** | Code từ 2016 vẫn chạy framework 2012 vì không ai dám refactor |

**Pattern phổ biến của hệ thống tự phát triển:**

```
Năm 1 (build): Hào hứng, phù hợp nghiệp vụ
Năm 2 (expand): Thêm nhiều feature, performance bắt đầu giảm
Năm 3 (maintain): Đội dev ban đầu 30% đã nghỉ
Năm 4 (struggle): Bug tăng, tốc độ develop tính năng mới giảm
Năm 5+ (survive): Mode survival — "chỉ vá, không build mới"
```

---

## II. KIẾN TRÚC THỰC TẾ: "SpaGHETTI ARCHITECTURE"

Điều khiến bức tranh phức tạp hơn: hầu hết doanh nghiệp không sử dụng pure Type A, B, hoặc C. Họ sử dụng **hybrid** — nhiều hệ thống ghép lại qua thời gian.

### Kiến Trúc Điển Hình của DN 6.000 Nhân Sự

```
┌─────────────────────────────────────────────────────────────┐
│                    THỰC TRẠNG HỆ THỐNG                      │
│                                                             │
│  Hồ sơ nhân sự    Chấm công     Payroll       Tuyển dụng   │
│  ┌──────────┐    ┌───────────┐  ┌─────────┐  ┌──────────┐  │
│  │ Base HRM │    │ Machine A │  │ Excel   │  │ Email +  │  │
│  │ (v2.1)  │    │ + Zkteco  │  │ Macro   │  │ VietWrks │  │
│  │         │    │           │  │         │  │          │  │
│  └────┬─────┘    └─────┬─────┘  └────┬────┘  └──────────┘  │
│       │                │             │                      │
│       ▼ export CSV      ▼ export      ▼ manual input        │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           EXCEL KINGDOM                             │    │
│  │  master_employee.xlsx  |  payroll_Apr2025.xlsx      │    │
│  │  attendance_raw.xlsx   |  bhxh_Q1.xlsx              │    │
│  │  recruitment_tracker.xlsx (HR Manager's desktop)    │    │
│  └─────────────────────────────────────────────────────┘    │
│       ▼ manual                                              │
│  ┌──────────┐    KPI & Training   BHXH Portal              │
│  │ Kế toán  │    ┌─────────────┐  ┌────────────────┐       │
│  │  (ERP)   │    │ Word/Excel  │  │ bhxh.gov.vn    │       │
│  └──────────┘    │ templates   │  │ (manual input) │       │
│                  └─────────────┘  └────────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

**Luồng dữ liệu thực tế:**
1. Nhân viên chấm công → máy Zkteco → export CSV mỗi tuần
2. Thủ công import CSV vào Excel attendance template
3. C&B apply formula tính công → Excel payroll
4. Copy-paste data vào Base HRM (hoặc ngược lại)
5. Export từ Base HRM → kế toán
6. Kế toán import vào ERP tài chính
7. Cuối tháng: tổng hợp báo cáo → pull từ 4-5 file khác nhau

**Tổng số điểm manual touchpoint:** **8-12 lần** dữ liệu được con người chạm vào và xử lý thủ công trong 1 payroll cycle. Mỗi touchpoint = điểm có thể sai sót.

---

## III. TECHNICAL DEBT INVENTORY

### 3.1. Classification of Technical Debt

| Loại nợ kỹ thuật | Mô tả | Doanh nghiệp Loại A | Doanh nghiệp Loại B | Doanh nghiệp Loại C |
|:---|:---|:---:|:---:|:---:|
| **Code Debt** | Custom code không document | Thấp | 🔴 Rất cao | 🔴 Rất cao |
| **Design Debt** | Kiến trúc không scalable | 🔴 Cao | 🔴 Cao | 🟠 Trung bình |
| **Config Debt** | Settings phức tạp không document | 🟠 Trung bình | 🔴 Cao | 🟡 Thấp |
| **Test Debt** | Không có automated testing | 🟡 Thấp | 🔴 Rất cao | 🔴 Rất cao |
| **Data Debt** | Dữ liệu lịch sử bẩn/không nhất quán | 🔴 Cao | 🔴 Cao | 🟠 Trung bình |
| **Process Debt** | Quy trình thủ công bù đắp cho hệ thống | 🔴 Cao | 🔴 Cao | 🔴 Cao |
| **Integration Debt** | Connector tạm thời trở thành permanent | 🟠 Trung bình | 🟠 Trung bình | 🔴 Cao |
| **Security Debt** | Vulnerability chưa được patch | 🟡 Thấp | 🔴 Cao | 🔴 Cao |

### 3.2. Chi Phí Technical Debt Hàng Năm (Ước Tính, DN 6.000 Nhân Sự)

| Hạng mục | VND/năm |
|:---|:---:|
| Developer/IT tốn giờ maintain (maintain không thêm feature) | 2-4 tỷ |
| Emergency patches khi luật thay đổi | 1-3 tỷ |
| External consultant/vendor cho bug critical | 500M-1.5 tỷ |
| Downtime và re-run payroll cost | 500M-1 tỷ |
| "Nhân sự vận hành hệ thống" (người biết cách dùng hệ thống, không thể thay thế) | 1-2 tỷ |
| **Tổng** | **~5-12 tỷ/năm** |

### 3.3. "Không Thể Nâng Cấp" — Bẫy Vĩnh Viễn

Lý do doanh nghiệp không nâng cấp hệ thống, dù biết nó đang là vấn đề:

1. **"Chúng tôi đã tùy chỉnh quá nhiều"** — Upgrade nghĩa là mất toàn bộ custom code, phải rebuild lại
2. **"Không ai dám"** — Khi chỉ 1-2 người hiểu hệ thống, rủi ro upgrade quá cao
3. **"Đang ổn, đủ dùng"** — Bias của status quo: cái đang chạy (dù không tốt) ít đáng sợ hơn cái mới (dù tốt hơn)
4. **"Không biết migrate data như thế nào"** — Dữ liệu lịch sử nhiều năm, không có schema documentation
5. **"Chi phí project lớn"** — Sợ disruption, sợ cost overrun, sợ fail
6. **"Không biết chọn gì"** — Thị trường quá nhiều vendor, không có framework để đánh giá

**Kết quả:** Hệ thống ngày càng lạc hậu nhưng không có ai muốn là người "chịu trách nhiệm" quyết định đổi.

---

## IV. INTEGRATION LANDSCAPE — CÁC ĐIỂM KẾT NỐI THỰC TẾ

### 4.1. Integration Matrix: Cái Gì Nối Với Cái Gì

| Nguồn | Đích | Phương thức | Tần suất | Độ tin cậy |
|:---|:---|:---|:---|:---:|
| Timekeeping → HR System | CSV import | Tuần/tháng | 🟡 Trung bình |
| HR System → Payroll | Manual copy/export | Tháng | 🔴 Thấp |
| Payroll → ERP/Accounting | Excel upload | Tháng | 🔴 Thấp |
| HR System → BHXH Portal | Manual entry | Tháng | 🔴 Thấp (entry sai thường xuyên) |
| Recruitment (email) → HR System | Manual entry | Ad hoc | 🔴 Rất thấp |
| HR Entity A → HR Entity B | Email file | Tháng | 🔴 Rất thấp |
| HR System → Bank (salary) | File format | Tháng | 🟠 Trung bình |

**Kết luận:** Không có integration nào là realtime. Tất cả đều là batch + manual. **Tổng số distinct integration points:** 6-10. **Số integration thực sự tự động:** 0-1.

### 4.2. Data Silos Map

```
                    Recruitment Data
                    (Email/Zalo/Excel/VietnamWorks)
                           ↓ (manual, monthly)
Personnel Records ←→  HR Core System  ←→  Payroll Data
(Base HRM/custom)              ↑           (Excel/custom)
        ↓                      │                 ↓
   Leave Data            BHXH Portal        ERP/Finance
(HR system hoặc          (manual entry)    (import file)
  paper forms)

Training Data                         Timekeeping Data
(Excel/paper)                    (biometric + manual exception)
        ↓                                    ↓
   L&D Reports              Attendance Calculation
   (Word/Excel)               (Excel macro 4-6h/kỳ)
```

**Không có data flow nào là bidirectional và realtime.**  
**Không có system nào là "master"** — mỗi system nghĩ nó là source of truth.

---

## V. FAILURE MODES — KHI HỆ THỐNG SỤP ĐỔ

### 5.1. Các Kiểu Sự Cố Thường Gặp

**Failure Mode 1: Payroll Batch Timeout**
- **Trigger:** Xử lý lô payroll lớn (3.000+ nhân sự)
- **Triệu chứng:** Odoo/hệ thống báo "Processing..." và không kết thúc, hoặc HTTP 502/504
- **Root cause:** Single-threaded synchronous processing, database lock, insufficient RAM
- **Business impact:** C&B team "đóng băng" 24-48h, lương chậm, nhân viên phàn nàn
- **Workaround hiện tại:** Chia batch nhỏ (500/lần), xử lý ban đêm, retrigger manual

**Failure Mode 2: Upgrade Break Everything**
- **Trigger:** Vendor push update hoặc OS upgrade
- **Triệu chứng:** Custom module conflict, salary rules break, reports lỗi
- **Root cause:** Custom code không compatible với version mới
- **Business impact:** System down 1-5 ngày, team không thể làm gì
- **Workaround hiện tại:** Freeze updates "mãi mãi," chịu rủi ro security

**Failure Mode 3: Key Person Departure**
- **Trigger:** Developer/IT người biết hệ thống nghỉ việc
- **Triệu chứng:** Không ai biết cách sửa khi có vấn đề, không có documentation
- **Root cause:** Knowledge chỉ in đầu người, không được document
- **Business impact:** System effectively "frozen" — không thể thay đổi gì
- **Workaround hiện tại:** Tăng lương giữ họ, hoặc hire người cũ làm consultant

**Failure Mode 4: Legal Change Emergency**
- **Trigger:** Chính phủ ban hành luật/nghị định mới về BHXH, thuế, lương
- **Triệu chứng:** Business logic hiện tại tính sai theo quy định mới
- **Root cause:** Hard-coded business rules không update được nhanh
- **Business impact:** Rủi ro compliance, phải tính thủ công trong thời gian vá
- **Workaround hiện tại:** Manual override trong Excel song song với hệ thống

**Failure Mode 5: Multi-Entity Data Cross-Contamination**
- **Trigger:** User với multi-company access thực hiện action trong wrong context
- **Triệu chứng:** Payroll record của entity A xuất hiện trong entity B, sai cost center
- **Root cause:** Company_dependent field không phải hard boundary
- **Business impact:** Báo cáo tài chính sai, rủi ro audit, PDPD violation
- **Workaround hiện tại:** Manual reconciliation hàng tháng, thêm review step

---

## VI. DOANH NGHIỆP ĐANG TRẢ CHI PHÍ GÌ ĐỂ "DUY TRÌ NGUYÊN TRẠNG"

### 6.1. Chi Phí Trực Tiếp

| Hạng mục | DN Loại A | DN Loại B | DN Loại C |
|:---|:---:|:---:|:---:|
| License/subscription phần mềm HR | VND 500M-2 tỷ/năm | License $0 + infrastructure | Không có license |
| IT team maintain (FTE) | 1-2 FTE | 2-4 FTE | 3-6 FTE |
| External consultant | Thấp-Trung bình | Cao | Cao |
| Upgrade/patch projects | Thỉnh thoảng | Thường xuyên | Ít nhưng lớn khi cần |
| **Tổng IT cost for HR system** | ~1-4 tỷ/năm | ~3-8 tỷ/năm | ~4-10 tỷ/năm |

### 6.2. Chi Phí Gián Tiếp (Ẩn)

| Hạng mục | Ước tính |
|:---|:---:|
| Overhead HR thủ công thay cho automation | VND 9-15 tỷ/năm |
| Manager time wasted on HR admin tasks | VND 3-6 tỷ/năm |
| C&B overtime for payroll processing | VND 500M-1.5 tỷ/năm |
| **Tổng chi phí gián tiếp** | ~13-23 tỷ/năm |

---

## VII. SO SÁNH VỚI BENCHMARK THỰC TẾ

### Ratios Nhân Sự — Doanh Nghiệp VN Đang Ở Đâu?

| Metric | DN VN điển hình | Global Best Practice |
|:---|:---:|:---:|
| HR FTE : Employee | 1 : 50-70 | 1 : 120-150 |
| Payroll processing time (5.000 nhân sự) | 24-72 giờ | <2 giờ |
| Time-to-hire | 45-60 ngày | 25-30 ngày |
| Onboarding time đến productive | 3-4 tuần | 1 tuần |
| HR budget as % of payroll | 2-4% | 0.8-1.5% |
| % HR tasks automated | 20-30% | 60-80% |
| Turnover rate | 20-24% | 10-12% |
| Turnover prediction accuracy | 0% (reactive only) | >85% (predictive AI) |

**Kết luận:** Doanh nghiệp Việt Nam đang tiêu tốn **gấp 2-3 lần** nguồn lực HR so với benchmark toàn cầu, nhưng nhận được **ít hơn một nửa** chất lượng output.

---

## VIII. KẾT LUẬN: TẠI SAO "THÊM NGƯỜI" AND "THÊM CÔNG CỤ" KHÔNG GIẢI QUYẾT ĐƯỢC

Từ góc nhìn lãnh đạo, có 3 bài học từ hệ sinh thái HR hiện tại:

**Bài học 1: "May vá" tạo ra complexity, không giảm complexity**
Mỗi tool thêm vào = thêm 1-2 integration point cần maintain, thêm 1 giao diện người dùng phải học, thêm 1 nguồn có thể có dữ liệu sai lệch. Càng thêm nhiều tool, system càng khó kiểm soát.

**Bài học 2: Technical debt lãi suất không ngừng tăng**
Technical debt không đứng yên. Mỗi ngày không trả = thêm interest. Hệ thống customize của 2018 đang "trả lãi" VND 5-12 tỷ/năm để duy trì, và **số này tăng mỗi năm** khi system ngày càng khó maintain hơn.

**Bài học 3: Vấn đề không phải là công nghệ — vấn đề là kiến trúc**
Nhiều doanh nghiệp chạy theo "upgrade phần mềm" nhưng mang theo toàn bộ cách làm việc cũ lên platform mới. Kết quả: vẫn dùng Excel song song, vẫn tổng hợp thủ công, vẫn data silos. **Kiến trúc dữ liệu nhân sự, không phải phần mềm, mới là thứ cần thay đổi.**

---

*Tài liệu PS-03 là phần 3 trong bộ 3 báo cáo Problem Statement HR/HCM cho doanh nghiệp 5.000-10.000 nhân sự tại thị trường Việt Nam và Đông Nam Á.*

*Phân tích kỹ thuật dựa trên: Odoo Community documentation, MISA/Base HRM technical review, EY HR process cost research ($4.86/manual task), field interviews với HR Directors và IT managers tại doanh nghiệp sản xuất và bán lẻ Việt Nam.*
