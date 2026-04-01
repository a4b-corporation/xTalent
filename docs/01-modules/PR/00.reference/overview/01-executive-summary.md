# PR Module — Executive Summary

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-06  
**Đối tượng**: Business Stakeholders, Product Leadership, C-level

---

## Payroll là gì trong xTalent?

**Payroll (PR)** là module đảm bảo mỗi nhân viên nhận đúng số tiền họ được hưởng, vào đúng ngày, theo đúng quy định pháp lý — tự động, minh bạch, và có thể kiểm toán toàn diện.

Payroll không chỉ là "cộng trừ nhân chia". Đây là bài toán phức tạp đa chiều:

```
Payroll = f(Employee Data, Time & Attendance, Benefits, Tax Rules, Policy Rules, Period Config)
```

Trong đó mỗi thành phần lương phụ thuộc vào nhau theo dependency graph, thay đổi theo thời gian (Luật, Nghị định), theo tổ chức (chính sách công ty/phòng ban), và theo từng cá nhân nhân viên.

---

## Vấn đề mà PR giải quyết

| Vấn đề thực tế | Cách truyền thống | PR giải quyết |
|---------------|------------------|--------------|
| Logic tính lương thay đổi khi Nghị định mới → cần IT release | Code cứng thay đổi lương vào hệ thống | Formula engine: HR tự cập nhật công thức trong 1 ngày, không cần lập trình viên |
| HR dùng Excel tính toán → không audit, không tích hợp, dễ sai | Spreadsheet thủ công, reconcile cuối tháng | Payroll engine tự động, deterministic: cùng input → cùng output mọi lúc |
| Không biết ảnh hưởng trước khi áp dụng chính sách mới | Chạy thật rồi sửa | Simulation mode: test trên historical data, xem impact report trước khi go-live |
| Thuế TNCN và BHXH tính sai do cập nhật trần/sàn muộn | Theo dõi thủ công Nghị định | Statutory Rules với effective date: tự động áp dụng đúng rate theo từng thời điểm |
| Audit lần lương tháng 3 năm ngoái tính thế nào → không trả lời được | Không có log chi tiết | Immutable audit trail: mọi run lưu đầy đủ input, công thức, kết quả, hash xác thực |
| Nâng lương hồi tố → não trạng tính bù tay rất phức tạp | Excel delta tính thủ công | Retroactive engine: tự động tính delta, carry nforward sang kỳ tiếp theo |
| Lương cho 2,000 người → mất cả ngày, hay xảy ra sai sót | Chạy từng batch nhỏ, kiểm tra thủ công | Batch processing: 10,000 nhân viên trong vòng 5 phút |

---

## Scale & Độ hoàn chỉnh

| Thống kê | Số liệu |
|---------|--------:|
| Nhóm entity trong domain model | **6** (Structure, Elements, Rules, Accounting, Reporting, Integration) |
| Entities trong ontology | **17** |
| Loại Pay Element | **5** (Earning, Deduction, Tax, Employer Contribution, Informational) |
| Execution modes | **3** (Dry Run, Simulation, Production) |
| Payroll processing stages | **5** (Pre-validation → Gross → Tax → Net → Post-processing) |
| Vietnam tax brackets | **7** (5% → 35%) |
| Loại statutory deduction VN | **4** (BHXH, BHYT, BHTN, TNLĐ) |
| Employee type classifications | **5** (Full-time, Fixed-term, Probation, Freelancer, Expat) |
| Security layers trong formula engine | **5** (Grammar → Whitelist → Offline Compile → ClassLoader → Approval) |
| Formula lifecycle states | **5** (Draft → Reviewed → Approved → Active → Deprecated) |

---

## 5 Capabilities cốt lõi

### 1. Cấu hình Payroll linh hoạt — không hardcode

xTalent Payroll xây dựng trên **PayProfile**: một bundle cấu hình toàn diện gồm pay elements, statutory rules, deduction policies — có thể tái sử dụng và phân tầng theo Legal Entity, Pay Group, Employee.

**Kết quả**: Công ty có 5 quốc gia, 10 loại nhân viên, nhiều chính sách khác nhau → cấu hình từng profile một lần, áp dụng tự động cho hàng nghìn nhân viên.

→ Chi tiết: [02 · Payroll Structure](./02-payroll-structure.md)

### 2. Formula Engine tự phục vụ — HR tự cấu hình công thức

Thay vì yêu cầu lập trình viên mỗi khi thay đổi chính sách lương, xTalent cung cấp **Business DSL Layer**: HR/Finance users viết công thức theo cú pháp gần Excel, hệ thống tự động compile, validate, và dry-run trước khi đưa vào production.

```
# HR viết công thức BHXH theo cú pháp DSL
element BHXH_EMPLOYEE =
  when employeeType == "PROBATION" then 0
  else min(GROSS_SALARY, BHXH_CEILING) * 0.08
```

**Kết quả**: Khi Nghị định mới ban hành, HR cập nhật công thức trong 1 ngày, không cần release IT. Toàn bộ lịch sử phiên bản được lưu đầy đủ.

→ Chi tiết: [03 · Pay Elements & Formula](./03-pay-elements-formula.md)

### 3. Vietnam Compliance được cấu hình sẵn

xTalent PR đi kèm bộ **Statutory Rules** hoàn chỉnh cho thị trường Việt Nam: BHXH 8%/17.5%, BHYT 1.5%/3%, BHTN 1%/1%, trần 46.8 triệu, thuế TNCN lũy tiến 7 bậc, giảm trừ gia cảnh. Khi Nhà nước thay đổi, chỉ cần cập nhật tham số — không cần sửa code.

**Kết quả**: Zero compliance error. Khi Nghị định 73/2024 thay đổi lương cơ sở, hệ thống tự apply đúng thời điểm hiệu lực.

→ Chi tiết: [04 · Statutory Rules & Compliance](./04-statutory-rules-compliance.md)

### 4. Payroll Lifecycle quản lý toàn vòng đời

Ba chế độ thực thi phục vụ ba nhu cầu khác nhau:
- **Dry Run**: Test công thức mới — kết quả đầy đủ, không lưu vào database
- **Simulation**: Replay dữ liệu lịch sử với công thức mới — impact report side-by-side
- **Production Run**: Chạy chính thức với 5 stages, approval workflow, period locking

**Kết quả**: Payroll admin tự tin thay đổi chính sách vì có simulation trước. Không còn "chạy thật rồi sửa".

→ Chi tiết: [05 · Payroll Execution Lifecycle](./05-payroll-execution-lifecycle.md)

### 5. Audit & Immutability toàn diện

Mọi payroll run lưu đầy đủ: ai chạy, lúc nào, công thức version nào, input gì, kết quả gì — kèm SHA-256 hash để xác thực tính toàn vẹn. Kết quả production là **immutable**: không thể sửa, chỉ có thể tạo adjustment record mới với approval.

**Kết quả**: Sẵn sàng cho audit thanh tra lao động, kiểm toán nội bộ bất cứ lúc nào. Có thể trả lời câu hỏi "Tháng 3/2024 tính BHXH cho nhân viên X thế nào?" trong vài giây.

→ Chi tiết: [08 · Integration Architecture](./08-integration-architecture.md)

---

## Business Value & Success Metrics

**Efficiency**:
- HR tự cập nhật công thức lương khi Nghị định mới: **1 ngày** (thay vì 1-2 sprint IT)
- Chạy lương 10,000 nhân viên: **< 5 phút**
- Simulation impact analysis: **< 2 phút** cho 1,000 nhân viên

**Accuracy**:
- **Deterministic**: cùng input + cùng formula version → cùng output mọi lúc
- **Zero rounding error**: sử dụng BigDecimal arithmetic (không phải floating-point)
- Vietnamese PIT 7-bracket progressive tax: tính toán chính xác 100%

**Compliance**:
- Toàn bộ Vietnam statutory rules sẵn sàng: BHXH/BHYT/BHTN, PIT
- Audit trail **100%** operations, immutable, không thể xóa
- Formula governance workflow: không formula nào active khi chưa qua Finance Lead approval

**Employee Experience**:
- Self-service payslip: nhân viên xem payslip từ portal, không cần HR gửi
- Payslip mô tả chi tiết từng element: từng khoản thu nhập, khấu trừ, thuế

| KPI | Target |
|-----|--------|
| Thời gian cập nhật công thức khi Nghị định mới | < 1 ngày |
| Payroll run 10,000 nhân viên | < 5 phút |
| Calculation accuracy (PIT, BHXH) | 100% match vs manual |
| Formula injection attack prevented | 100% ở compile stage |
| Audit trail completeness | 100% operations logged |

---

## Market Alignment

Kiến trúc PR được tham chiếu từ các hệ thống payroll hàng đầu:

| Hệ thống | Khái niệm tương đương | Tương đồng |
|---------|----------------------|:----------:|
| **Oracle HCM Fast Formula** | Business DSL, Formula Studio, Element definition | ~90% |
| **SAP ECP (Employee Central Payroll)** | Wage type config, retroactive calculation pattern | ~85% |
| **Workday Payroll** | Pay element, pay group, calculation rules | ~85% |
| **ADP GlobalView** | Country-specific statutory rules, GL mapping | ~80% |

Sự tương đồng này đảm bảo:
- Data migration từ Oracle/SAP có lộ trình rõ ràng
- Payroll practitioners có kinh nghiệm sẽ dễ onboard
- Industry best practices đã được kiểm chứng tại enterprise scale

---

## Lộ trình đọc theo vai trò

**Business Stakeholder / C-level**:  
→ `01` (Executive Summary) — đủ để ra quyết định

**HR Admin / Payroll Admin**:  
→ `01` → `02` (Structure) → `03` (Elements & Formula) → `05` (Execution Lifecycle)

**Finance / Compliance Officer**:  
→ `01` → `04` (Statutory Rules) → `07` (Accounting & Reporting)

**IT Manager / Project Manager**:  
→ `01` → `08` (Integration Architecture)

**Developer / Architect**:  
→ `01` → `06` (Formula Engine Architecture) → `08` (Integration) → `03` → `04`

**Product Manager / BA**:  
→ Đọc tuần tự `01` → `02` → `03` → `04` → `05` → `06` → `07` → `08`

---

*← [README](./README.md) · [02 Payroll Structure →](./02-payroll-structure.md)*
