# TR Module — Executive Summary

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-05  
**Đối tượng**: Business Stakeholders, Product Leadership, C-level

---

## Total Rewards là gì?

**Total Rewards (TR)** là module quản lý toàn bộ các hình thức bù đắp mà doanh nghiệp trao cho nhân viên — không chỉ là lương cơ bản mà bao gồm mọi thứ từ bonus, cổ phiếu, bảo hiểm sức khỏe, chương trình ghi nhận đến lá thư tổng đãi ngộ hàng năm.

TR là module **tạo ra tác động tài chính lớn nhất** trong hệ thống xTalent — chi phí nhân sự thường chiếm 60-70% tổng chi phí vận hành doanh nghiệp.

Mô hình **"Total Rewards"** (đãi ngộ toàn diện) là tiêu chuẩn của các hệ thống HCM hàng đầu thế giới (Workday, Oracle, SAP): thay vì quản lý lương riêng, phúc lợi riêng, thưởng riêng — tất cả được hợp nhất vào một nền tảng để nhân viên thấy rõ toàn bộ giá trị mình nhận được.

---

## Vấn đề mà TR giải quyết

| Vấn đề thực tế | Cách truyền thống | TR giải quyết |
|---------------|------------------|--------------|
| Cấu trúc lương phức tạp theo từng quốc gia, nhóm nhân viên | Excel riêng từng nước, dễ sai, khó kiểm soát | Salary Basis + Pay Components tái sử dụng, country-specific rules |
| Merit review mất 6-8 tuần, thủ công, dễ vi phạm ngân sách | Email trao đổi qua lại, Budget tính tay | Compensation Cycle với budget tracking real-time, approval workflow tự động |
| Thưởng hiệu suất không minh bạch, khó tính đúng | Tính tay theo file Excel, tranh chấp thường xuyên | Formula engine: Bonus = Salary × Target% × Perf × Company Multiplier |
| RSU/Stock options chưa vest → thuế tính sai kỳ payroll | Theo dõi file riêng, tính bù thủ công | Taxable Bridge tự động tạo taxable item → Payroll đúng kỳ |
| Mở đăng ký phúc lợi (open enrollment) tốn nhiều nhân lực HR | Gửi form, thu lại thủ công, sai sót phổ biến | Self-service enrollment portal + EDI 834 carrier integration |
| Nhân viên không biết tổng giá trị đãi ngộ họ nhận được | Không có báo cáo tổng hợp | Total Rewards Statement: PDF tổng hợp lương + phúc lợi + equity + recognition |
| Khó giữ chân nhân tài: không rõ chính sách equity, phúc lợi | Thông tin rải rác, không minh bạch | Offer Management + TR Statement tạo trải nghiệm rõ ràng, hấp dẫn |

---

## Scale & Độ hoàn chỉnh

| Thống kê | Số liệu |
|---------|---------:|
| Sub-modules chính | **11** |
| Entities trong domain model | **70** |
| Concept guides (tài liệu nghiệp vụ) | **11/11** (100%) |
| Feature specification docs | **8/9** (78%) |
| Loại salary frequency | **7** (monthly, hourly, daily, weekly, biweekly, semimonthly, annual) |
| Loại pay component | **6** (Base, Allowance, Bonus, Equity, Deduction, Overtime) |
| Career ladder types | **5** (Technical, Management, Specialist, Sales, Executive) |
| Pay range scope levels | **4** (Global → Legal Entity → BU → Position) |
| Loại benefit plan | **8** (Medical, Dental, Vision, Life, Disability, Retirement, Wellness, Perk) |
| Enrollment period types | **3** (Open Enrollment, New Hire, Qualifying Life Event) |
| Equity grant types | **3** (RSU, Stock Options, ESPP) |
| Vesting schedule types | **3** (Cliff, Graded, Performance-based) |
| Quốc gia có tax rule | **VN, US, SG** (có thể mở rộng) |

---

## 7 Capabilities cốt lõi

### 1. Component-Based Compensation Architecture
Thay vì hardcode cấu trúc lương, xTalent TR xây dựng lương từ các **Pay Components tái sử dụng** (base salary, lunch allowance, housing allowance, overtime...). Mỗi component có tax treatment, proration method và calculation rule riêng.

**Kết quả**: HR chỉ cần định nghĩa component một lần, áp dụng cho hàng nghìn nhân viên. Thay đổi quy tắc thuế hay cách tính chỉ cần sửa ở một nơi.

→ Chi tiết: [02 · Core Compensation](./02-core-compensation.md)

### 2. Grade & Career Ladder với Pay Range đa cấp
Hệ thống **Grade** dùng SCD Type 2 lưu lịch sử đầy đủ — không bao giờ mất dữ liệu thăng tiến. **Pay Range** có thể định nghĩa ở 4 cấp (Global → Legal Entity → Business Unit → Position), hệ thống luôn áp dụng cấp cụ thể nhất.

**Kết quả**: Doanh nghiệp có thể set lương khác nhau cho Engineer VN vs SG vs US, khác nhau cho từng phòng ban, thậm chí từng vị trí quan trọng — mà không cần tạo hàng trăm quy tắc riêng lẻ.

→ Chi tiết: [02 · Core Compensation](./02-core-compensation.md)

### 3. Structured Compensation Cycle với Budget Control  
**Compensation Cycle** hỗ trợ 5 loại (Merit, Promotion, Market Adjustment, New Hire, Equity Correction) với budget tracking real-time và approval workflow tự động theo ngưỡng tăng lương (< 5% → tự phê duyệt, 5-10% → Director, > 10% → VP).

**Kết quả**: Merit review từ 6-8 tuần rút xuống còn 2 tuần. Budget variance < 2%. Không có trường hợp tăng lương vượt ngân sách mà không có phê duyệt.

→ Chi tiết: [02 · Core Compensation](./02-core-compensation.md)

### 4. Variable Pay: Bonus + Equity + Commission
Ba loại biến động lương được quản lý thống nhất:
- **Bonus** (STI/LTI/Spot): Formula tự động với performance multiplier và company multiplier
- **Equity** (RSU/Stock Options/ESPP): Vesting schedule tự động, tax event tạo khi vest, Taxable Bridge sang Payroll
- **Commission**: Tiered/Accelerator rates, quota tracking, monthly cycle

**Kết quả**: Không còn tính thưởng tay. Equity tax không bị bỏ sót. Commission minh bạch và tranh chấp giảm đáng kể.

→ Chi tiết: [03 · Variable Pay](./03-variable-pay.md)

### 5. Dynamic Benefits Administration
**Eligibility Engine** với EligibilityProfile tái sử dụng — định nghĩa một lần, áp dụng cho nhiều plan. Hỗ trợ **Open Enrollment**, **New Hire Enrollment** (30 ngày), và **Qualifying Life Events** (kết hôn, sinh con...) với enrollment window tự động mở.

**Kết quả**: HR không cần xử lý enrollment thủ công. Nhân viên self-service online. Coverage chính xác, không bỏ sót người đủ điều kiện. Carrier nhận EDI 834 tự động.

→ Chi tiết: [04 · Benefits Administration](./04-benefits-administration.md)

### 6. Recognition → Perks → Taxable Bridge
**Point-based Recognition** với FIFO expiration khuyến khích redeem thường xuyên. Nhân viên tích điểm từ peer recognition, manager awards, milestones — rồi đổi lấy perks (gift cards, experiences, merchandise). Perk có giá trị tiền tệ sẽ tự động tạo taxable item sang Payroll.

**Kết quả**: Văn hóa ghi nhận được hệ thống hóa. Compliance thuế tự động. HR tiết kiệm nhiều giờ xử lý thủ công.

→ Chi tiết: [05 · Recognition, Offer & Statement](./05-recognition-offer-statement.md)

### 7. Total Rewards Statement & Offer Management
Nhân viên nhận **TR Statement** hàng năm dạng PDF, hiển thị rõ ràng toàn bộ: lương cơ bản + bonus + equity + phúc lợi + recognition = **tổng giá trị đãi ngộ ước tính**. Ứng viên nhận **Offer Package** với e-signature tích hợp và counter-offer workflow.

**Kết quả**: Nhân viên hiểu giá trị thực của mình (thường cao hơn lương nhận tay 40-60%). Offer acceptance rate cải thiện rõ rệt.

→ Chi tiết: [05 · Recognition, Offer & Statement](./05-recognition-offer-statement.md)

---

## Business Value & Success Metrics

**Efficiency**:
- Rút ngắn **70%** thời gian merit review cycle (6-8 tuần → 2 tuần)
- Loại bỏ hoàn toàn tính lương/thưởng thủ công bằng spreadsheet
- Open enrollment: tự động hóa 95% quy trình HR

**Accuracy**:
- **99.9%** độ chính xác tính lương — zero calculation error với automated formula engine
- **100%** commission accuracy — không còn tranh chấp tính sai
- Zero equity tax bị bỏ sót — Taxable Bridge đảm bảo mọi taxable event được bridge sang Payroll

**Compliance**:
- Multi-country support: VN (BHXH/BHYT/BHTN), US (ACA/COBRA/HIPAA/W-2), SG và mở rộng được
- 7-year audit trail với before/after values — sẵn sàng cho regulatory audit bất cứ lúc nào
- Pay equity monitoring ngăn chặn disparate impact

**Employee Experience**:
- Self-service: xem compensation, enroll benefits, redeem points, track offer status
- TR Statement hàng năm giúp nhân viên thấy full value (không chỉ take-home pay)
- Recognition programs công khai tăng engagement score

| KPI | Target |
|-----|--------|
| Merit review completion time | < 2 tuần |
| Compensation calculation accuracy | 99.9%+ |
| Budget variance (actual vs planned) | < 2% |
| Open enrollment completion rate | > 95% |
| Bonus cycle completion time | < 1 tuần |
| Offer acceptance rate | > 85% |
| Recognition participation rate | > 60% nhân viên |

---

## Market Alignment

TR Module được thiết kế tương đương với các hệ thống HCM hàng đầu:

| Hệ thống | Khái niệm tương đương | Độ tương đồng |
|---------|-----------------------|:------------:|
| **Workday HCM** | Compensation, Benefits, Equity, Absence Pays | ~90% |
| **Oracle HCM Cloud** | Total Compensation, Benefits, Payroll Integration | ~90% |
| **SAP SuccessFactors** | Compensation, Benefits, Equity & Long-Term Incentives | ~85% |
| **Cornerstone** | Compensation Planning, Benefits Administration | ~80% |

Sự tương đồng này có nghĩa là:
- Data migration từ các hệ thống trên có lộ trình rõ ràng
- HR/Admin có kinh nghiệm Workday/Oracle sẽ dễ onboard
- Industry best practices đã được tích hợp vào thiết kế

---

## Integration Map

```
                      TR Module
                         │
      ┌──────────────────┼────────────────────────┐
      ↑                  ↓                         ↓
CO Module          PR (Payroll)            External Systems
(cung cấp)         (nhận từ TR)            (nhận/gửi)
Worker data        TaxableItems            Benefits Carriers (EDI 834)
Job/Position       Deductions              Stock Plan Admin
Grade/Level        PayComponents           Tax Authorities (W-2/1099)
LegalEntity        TaxWithholding          E-Signature platforms
BusinessUnit

      ↑
TA (Time & Absence)
OvertimeHours → Variable Pay
AttendanceData → Proration
LeaveBalance → Benefits coordination
```

---

*Nguồn: tổng hợp từ `01-concept/01-concept-overview.md` (644 dòng) và `README.md`*  
*← [README](./README.md) · [02 Core Compensation →](./02-core-compensation.md)*
