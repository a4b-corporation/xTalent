# Total Rewards — User Stories

> **Module**: Total Rewards (TR)
> **Giải pháp**: xTalent — HCM
> **Phiên bản**: 1.0.0
> **Ngày**: 2026-03-26
> **Tác giả**: Business Analyst Agent (ODSA Step 2)
> **Lưu ý naming**: "Worker" = nhân viên/người lao động; "Working Relationship" = hợp đồng lao động; "Legal Entity" = pháp nhân

---

## Danh mục User Stories

| ID | Tiêu đề | Priority | Sub-module |
|----|---------|----------|------------|
| US-001 | Tính bảo hiểm xã hội Vietnam | P0 | Calculation Rules |
| US-002 | Mở chu kỳ điều chỉnh lương | P0 | Core Compensation |
| US-003 | Đề xuất tăng lương trong chu kỳ | P0 | Core Compensation |
| US-004 | Phê duyệt đề xuất lương | P0 | Core Compensation |
| US-005 | Validation lương tối thiểu | P0 | Core Compensation |
| US-006 | Audit trail tự động | P0 | Audit |
| US-007 | Đăng ký phúc lợi (Benefits Enrollment) | P0 | Benefits |
| US-008 | Tính bonus cuối năm | P0 | Variable Pay |
| US-009 | Tính hoa hồng (Commission) | P0 | Variable Pay |
| US-010 | Khấu trừ tự động (Deductions) | P0 | Deductions |
| US-011 | Khai báo thuế TNCN | P0 | Tax Withholding |
| US-012 | Proration tự động khi gia nhập giữa kỳ | P0 | Calculation Rules |
| US-013 | Bridge sang Payroll | P0 | Taxable Bridge |
| US-014 | Tạo offer cho candidate | P1 | Offer Management |
| US-015 | Ký offer điện tử | P1 | Offer Management |
| US-016 | Phát hiện khoảng cách công bằng lương | P1 | Core Compensation |
| US-017 | Dashboard commission real-time | P1 | Variable Pay |
| US-018 | Ghi nhận đồng nghiệp | P1 | Recognition |
| US-019 | Total Rewards Statement | P1 | TR Statement |
| US-020 | Configurable proration method | P0 | Calculation Rules |
| US-021 | Cấu hình SI engine cho quốc gia mới | P0 | Calculation Rules |
| US-022 | Xem lịch sử lương | P0 | Core Compensation |
| US-023 | Xử lý tranh chấp hoa hồng | P1 | Variable Pay |
| US-024 | Đăng ký phúc lợi khi có sự kiện cuộc sống | P1 | Benefits |

---

## US-001: Tính bảo hiểm xã hội Vietnam

**Priority**: P0
**Sub-module**: Calculation Rules Engine
**Actor**: System (Automated)

**Với tư cách là** hệ thống tự động
**Tôi muốn** tính đúng số tiền đóng BHXH/BHYT/BHTN cho mỗi Worker
**Để** đảm bảo tuân thủ SI Law 2024 và tránh phạt VND 50–100M/vụ vi phạm

### Acceptance Criteria

```gherkin
Scenario: Tính BHXH worker tại Vùng 1 (Hà Nội)
  Given Worker "Nguyen Van A" có Working Relationship tại Legal Entity "VNG Corp"
  And workplace location của Working Relationship là "Hà Nội" (Vùng 1)
  And lương cơ bản (salary_basis) = VND 20,000,000/tháng
  And minimum wage Vùng 1 = VND 4,680,000/tháng
  And SI cap = 20 × 4,680,000 = VND 93,600,000
  When System chạy calculation engine cho kỳ lương tháng 4/2026
  Then BHXH employer = 20,000,000 × 17.5% = VND 3,500,000
  And BHXH employee = 20,000,000 × 8% = VND 1,600,000
  And BHYT employer = 20,000,000 × 3% = VND 600,000
  And BHYT employee = 20,000,000 × 1.5% = VND 300,000
  And BHTN employer = 20,000,000 × 1% = VND 200,000
  And BHTN employee = 20,000,000 × 1% = VND 200,000
  And audit record được tạo với full calculation breakdown

Scenario: Cap SI khi lương vượt 20× minimum wage
  Given Worker "Tran Thi B" có salary_basis = VND 100,000,000/tháng
  And workplace location = Vùng 1, minimum wage Vùng 1 = VND 4,680,000
  And SI cap = 20 × 4,680,000 = VND 93,600,000
  When System tính SI contribution
  Then BHXH employer được tính trên VND 93,600,000 (không phải 100,000,000)
  And BHXH employer = 93,600,000 × 17.5% = VND 16,380,000
  And calculation log ghi nhận "salary_capped_at: 93,600,000"

Scenario: Vùng SI thay đổi khi Worker chuyển công tác
  Given Worker "Le Van C" đang làm việc tại Vùng 3 (SI cap = 20 × 3,640,000)
  And Working Relationship được cập nhật: workplace location chuyển sang Vùng 1
  And effective date = 2026-04-15
  When System tính SI cho tháng 4/2026
  Then System áp dụng Vùng 3 cap cho tháng 4/2026 (chưa đổi)
  And từ tháng 5/2026 mới áp dụng Vùng 1 cap
  And audit record ghi nhận zone_change_effective = 2026-05-01

Scenario: SI calculation engine không hardcode — configurable rates
  Given HR Admin muốn cập nhật BHXH employer rate từ 17.5% lên 18%
  When HR Admin cập nhật rate trong CountryContributionEngine config cho Vietnam
  And effective date = 2026-07-01
  Then System dùng rate 17.5% cho kỳ trước 2026-07-01
  And System dùng rate 18% từ kỳ 2026-07-01 trở đi
  And không cần code deployment để áp dụng thay đổi
```

**Business Rules**: BR-C01, BR-C03, BR-C04
**Dependencies**: CO module (Worker, Working Relationship, workplace location)

---

## US-002: Mở chu kỳ điều chỉnh lương (Compensation Cycle)

**Priority**: P0
**Sub-module**: Core Compensation
**Actor**: Compensation Administrator

**Với tư cách là** Compensation Administrator
**Tôi muốn** mở một chu kỳ điều chỉnh lương (Merit Review)
**Để** kích hoạt quy trình đề xuất lương có kiểm soát ngân sách cho toàn bộ tổ chức

### Acceptance Criteria

```gherkin
Scenario: Mở Merit Review cycle thành công
  Given Compensation Administrator có quyền trên Legal Entity "VNG Corp"
  And ngân sách Merit Review đã được Finance Approver phê duyệt = VND 5,000,000,000
  And cycle template "Annual Merit 2026" đã được cấu hình
  When Compensation Administrator thực thi OpenCompensationCycle với type = MERIT
  Then CompensationCycleStarted event được tạo
  And cycle trạng thái = OPEN
  And tất cả People Manager trong scope nhận notification
  And budget_remaining = VND 5,000,000,000 (real-time tracking bắt đầu)
  And audit record được tạo: actor, timestamp, cycle_id

Scenario: Mở cycle khi ngân sách chưa được duyệt
  Given Compensation Administrator muốn mở cycle "Q2 Market Adjustment"
  And ngân sách chưa được Finance Approver phê duyệt
  When Compensation Administrator thực thi OpenCompensationCycle
  Then hệ thống từ chối với message "Ngân sách chưa được phê duyệt"
  And cycle không được tạo
  And Finance Approver nhận notification yêu cầu phê duyệt ngân sách

Scenario: Budget remaining cập nhật real-time khi proposal submit
  Given cycle "Annual Merit 2026" đang OPEN với budget_remaining = VND 5,000,000,000
  When People Manager "Manager X" submit proposal tăng lương Worker "A" thêm VND 2,000,000/tháng (annual = 24,000,000)
  Then budget_remaining cập nhật ngay = VND 5,000,000,000 - 24,000,000 = VND 4,976,000,000
  And proposal trạng thái = PENDING_APPROVAL
  And BudgetVarianceAlerted được trigger nếu remaining < 5% total budget
```

**Business Rules**: BR-A01, BR-A02, BR-A03, BR-D02
**Dependencies**: FR-CC-004, FR-CC-005

---

## US-003: Đề xuất tăng lương trong chu kỳ

**Priority**: P0
**Sub-module**: Core Compensation
**Actor**: People Manager

**Với tư cách là** People Manager
**Tôi muốn** đề xuất tăng lương cho Worker trong team
**Để** ghi nhận đóng góp và giữ chân nhân tài trong chu kỳ merit review

### Acceptance Criteria

```gherkin
Scenario: Đề xuất tăng lương < 5% (auto-approve)
  Given cycle "Annual Merit 2026" đang OPEN
  And People Manager "Manager Y" có direct report là Worker "Nguyen Van D"
  And lương hiện tại Worker "D" = VND 15,000,000/tháng
  And performance rating của Worker "D" = "Exceeds Expectations"
  When Manager Y submit proposal tăng 3% (= VND 450,000/tháng)
  Then MeritRecommendationSubmitted event được tạo
  And hệ thống kiểm tra threshold: 3% < 5% → auto-approve
  And CompensationApproved event được tạo ngay
  And Worker "D" nhận notification về kết quả
  And audit record: actor = Manager Y, approved_by = System (auto), reason = "below 5% threshold"

Scenario: Đề xuất tăng lương 5–10% (cần Director approval)
  Given cùng context trên
  When Manager Y submit proposal tăng 7%
  Then proposal được route đến Director của Manager Y
  And Director nhận notification với deadline approval
  And budget_remaining giảm tạm thời (pending)
  And nếu Director không respond trong 5 ngày làm việc → escalate lên VP

Scenario: Đề xuất vượt pay range tối đa
  Given Worker "E" đang ở mức Salary Range Maximum (compa-ratio = 1.20)
  When Manager Z propose tăng thêm 5%
  Then hệ thống cảnh báo "Đề xuất vượt pay range maximum"
  And yêu cầu exception approval bổ sung (configurable: Comp Manager hoặc HR Director)
  And Manager Z phải cung cấp business justification
```

**Business Rules**: BR-A01, BR-A02, BR-A03, BR-A04, BR-K04
**Dependencies**: US-002, FR-CC-003, FR-CC-005

---

## US-004: Phê duyệt đề xuất lương

**Priority**: P0
**Sub-module**: Core Compensation
**Actor**: Budget Approver (Director/VP)

**Với tư cách là** Budget Approver
**Tôi muốn** phê duyệt hoặc từ chối đề xuất tăng lương
**Để** kiểm soát chi phí nhân sự trong ngưỡng ngân sách được ủy quyền

### Acceptance Criteria

```gherkin
Scenario: Director phê duyệt proposal tăng lương 7%
  Given proposal "Tăng lương Worker F thêm 7%" đang chờ Director approval
  And Director "Director A" có authority cho proposal trong ngưỡng 5–10%
  When Director A approve proposal với comment "Strong performance Q1 2026"
  Then CompensationApproved event được tạo
  And lương Worker F được cập nhật hiệu lực từ effective_date
  And SalaryHistoryArchived (SCD Type 2 snapshot) được tạo
  And People Manager nhận confirmation notification
  And Worker F nhận notification (nếu cycle đã closed và published)

Scenario: VP từ chối proposal tăng lương 12% vì thiếu budget
  Given proposal tăng 12% đang chờ VP approval
  And budget_remaining < required increase amount
  When VP reject với reason "Budget exceeded for this quarter"
  Then CompensationRejected event được tạo
  And budget_remaining được hoàn lại (proposal không còn tính)
  And People Manager nhận notification với reason
  And Manager có thể submit revised proposal với % thấp hơn

Scenario: Approval timeout → escalation
  Given proposal đã route đến Director nhưng không có action sau 5 ngày làm việc
  When System phát hiện timeout
  Then System tự động escalate lên VP
  And VP nhận notification với context đầy đủ
  And audit log ghi nhận: "Auto-escalated due to timeout after 5 business days"
```

**Business Rules**: BR-A01, BR-A02, BR-A03, BR-D02
**Dependencies**: US-003, FR-CC-005

---

## US-005: Validation lương tối thiểu vùng

**Priority**: P0
**Sub-module**: Core Compensation
**Actor**: System (Automated) + HR Administrator

**Với tư cách là** hệ thống tự động
**Tôi muốn** validate lương không thấp hơn mức tối thiểu của vùng
**Để** đảm bảo Legal Entity không vi phạm Nghị định 74/2024 về lương tối thiểu

### Acceptance Criteria

```gherkin
Scenario: Hard block khi tạo offer với lương dưới tối thiểu Vùng 2
  Given Hiring Manager tạo offer cho candidate tại Legal Entity "ABC Corp" - Vùng 2
  And minimum wage Vùng 2 = VND 4,160,000/tháng
  And offer salary = VND 4,000,000/tháng
  When Hiring Manager submit offer
  Then hệ thống block với message "Lương đề xuất (4,000,000 VND) thấp hơn mức tối thiểu Vùng 2 (4,160,000 VND)"
  And offer không được lưu
  And Hiring Manager phải sửa lại trước khi submit

Scenario: Hard block khi điều chỉnh lương xuống dưới tối thiểu
  Given HR Admin cố điều chỉnh lương Worker "G" xuống VND 3,500,000 tại Vùng 3
  And minimum wage Vùng 3 = VND 3,640,000/tháng
  When HR Admin save salary change
  Then MinimumWageViolated event được tạo
  And hệ thống block: "Lương mới (3,500,000) vi phạm tối thiểu Vùng 3 (3,640,000)"
  And salary change không được áp dụng

Scenario: Minimum wage table thay đổi — tự động re-validate
  Given Chính phủ công bố tăng lương tối thiểu từ 2027-01-01
  And HR Admin cập nhật minimum wage table mới trong hệ thống
  When effective date 2027-01-01 đến
  Then System tự động scan tất cả active Working Relationship
  And Workers có salary < minimum wage mới được flag
  And HR Admin nhận report: "X workers cần điều chỉnh lương"
  And MinimumWageViolationDetected event được tạo cho mỗi trường hợp vi phạm
```

**Business Rules**: BR-C02, BR-C05
**Dependencies**: CO module (workplace location), FR-CC-007

---

## US-006: Audit trail tự động cho mọi thay đổi TR

**Priority**: P0
**Sub-module**: Audit
**Actor**: System (Automated)

**Với tư cách là** hệ thống tự động
**Tôi muốn** capture 100% thay đổi của mọi TR entity
**Để** đảm bảo có đầy đủ bằng chứng cho kiểm toán, tranh chấp, và IPO readiness

### Acceptance Criteria

```gherkin
Scenario: Audit record được tạo khi lương thay đổi
  Given Worker "H" có salary = VND 20,000,000
  When HR Admin điều chỉnh lương lên VND 22,000,000 với reason "Annual Merit 2026"
  Then AuditRecord được tạo với:
    | field        | value                          |
    | entity_type  | WorkerSalary                   |
    | entity_id    | worker_h_uuid                  |
    | actor_id     | hr_admin_uuid                  |
    | action       | UPDATE                         |
    | before_value | {"amount": 20000000}           |
    | after_value  | {"amount": 22000000}           |
    | timestamp    | 2026-03-26T10:30:00Z           |
    | reason       | "Annual Merit 2026"            |
  And audit record này không thể bị modify hoặc delete

Scenario: External Auditor không thể modify audit records
  Given External Auditor "Auditor X" có read-only access đến Legal Entity "VNG Corp"
  When Auditor X cố gắng update bất kỳ audit record nào
  Then hệ thống từ chối với HTTP 403
  And security log ghi nhận unauthorized modification attempt
  And Compliance Officer nhận alert

Scenario: Audit records tồn tại sau 7 năm
  Given audit record được tạo vào 2026-03-26
  When system maintenance routine chạy vào 2033-03-26 (7 năm sau)
  Then record vẫn còn nguyên vẹn (không bị purge)
  And retention policy không áp dụng xóa cho record này

Scenario: Anomaly detection phát hiện thay đổi bất thường
  Given Worker "I" có salary tăng 45% trong vòng 1 tháng (threshold mặc định = 25%)
  When System chạy anomaly detection job hàng ngày
  Then AnomalyDetected event được tạo
  And Compliance Officer nhận alert: "Bất thường: Salary Worker I tăng 45% trong 30 ngày"
  And chi tiết change được đính kèm trong alert
```

**Business Rules**: BR-A06, BR-D02, BR-D03
**Dependencies**: FR-AUD-001 đến FR-AUD-006

---

## US-007: Đăng ký phúc lợi (Benefits Enrollment)

**Priority**: P0
**Sub-module**: Benefits Administration
**Actor**: Worker (Self-Service)

**Với tư cách là** Worker
**Tôi muốn** tự đăng ký gói phúc lợi trong thời gian Open Enrollment
**Để** chọn gói phù hợp với nhu cầu cá nhân và gia đình tôi

### Acceptance Criteria

```gherkin
Scenario: Worker đăng ký Medical plan trong Open Enrollment
  Given Open Enrollment period đang active (từ 2026-11-01 đến 2026-11-30)
  And Worker "Pham Thi C" đủ điều kiện cho Medical Plan "Premium Health Vietnam"
  When Worker C chọn gói Medical và submit enrollment
  Then BenefitElected event được tạo
  And enrollment được lưu với effective date = 2027-01-01 (đầu plan year)
  And carrier sync được trigger: EDI 834 transaction gửi đến carrier
  And Worker C nhận confirmation email
  And deduction record tự động tạo cho premium tương ứng

Scenario: Worker đăng ký ngoài enrollment window
  Given Open Enrollment đã đóng ngày 2026-11-30
  When Worker "D" cố đăng ký vào ngày 2026-12-05
  Then hệ thống block: "Enrollment period đã đóng. Thay đổi chỉ được phép khi có Qualifying Life Event"
  And Worker D được hướng dẫn về QLE process

Scenario: Carrier sync fail — fallback handling
  Given Worker E vừa complete enrollment
  When EDI 834 sync đến carrier fail (carrier API down)
  Then hệ thống retry sau 15 phút (configurable)
  And nếu vẫn fail sau 3 retries → HR Admin nhận alert
  And enrollment record vẫn được lưu trong hệ thống (không mất data)
  And worker nhận confirmation rằng enrollment đã ghi nhận, carrier đang được xử lý
```

**Business Rules**: BR-C05, BR-I05
**Dependencies**: FR-BA-001, FR-BA-002, FR-BA-004

---

## US-008: Tính bonus cuối năm (Annual Bonus)

**Priority**: P0
**Sub-module**: Variable Pay
**Actor**: Compensation Manager

**Với tư cách là** Compensation Manager
**Tôi muốn** chạy tính toán bonus cuối năm cho toàn bộ eligible workers
**Để** đảm bảo trả thưởng chính xác, minh bạch theo công thức đã được thiết kế

### Acceptance Criteria

```gherkin
Scenario: Tính bonus theo formula engine
  Given Bonus plan "Annual Performance Bonus 2026" đã được cấu hình
  And formula_json = {"formula": "BaseSalary * TargetPct * PerfMultiplier * CompanyMultiplier"}
  And Worker "F" có: BaseSalary = 20,000,000; TargetPct = 15%; PerfMultiplier = 1.2 (Exceeds); CompanyMultiplier = 0.9 (company missed target)
  When Compensation Manager chạy BonusCalculation cho period Q4 2026
  Then Bonus = 20,000,000 × 15% × 1.2 × 0.9 = VND 3,240,000
  And BonusCalculated event được tạo với full breakdown
  And result pending People Manager review (trước khi finalize)

Scenario: Bonus vượt budget pool
  Given Budget pool "Annual Bonus Pool 2026" = VND 500,000,000
  And tổng bonus đã calculated cho tất cả workers = VND 520,000,000
  When Compensation Manager review summary
  Then hệ thống highlight: "Budget exceeded by VND 20,000,000"
  And BudgetVarianceAlerted event được tạo
  And Compensation Manager có thể: (a) request thêm budget, (b) reduce % cho một số workers

Scenario: Worker 13th month pro-rata (VN)
  Given Worker "G" gia nhập ngày 2026-04-01 (sau Tết)
  And 13th month = 1 tháng lương cơ bản (configurable rule)
  When System tính 13th month cho chu kỳ Tết 2026
  Then pro-rata = 9 tháng / 12 tháng × BaseSalary (làm từ tháng 4 đến tháng 12)
  And TaxableItemCreated event: 13th month là taxable income
```

**Business Rules**: BR-K02, BR-C06, BR-A07
**Dependencies**: FR-VP-001, FR-VP-002, FR-VP-005

---

## US-009: Tính hoa hồng (Commission Calculation)

**Priority**: P0
**Sub-module**: Variable Pay — Commission
**Actor**: Sales Operations

**Với tư cách là** Sales Operations
**Tôi muốn** tính hoa hồng chính xác cho Sales team cuối mỗi tháng
**Để** trả đúng, trả đủ và xây dựng niềm tin với Sales reps

### Acceptance Criteria

```gherkin
Scenario: Tính commission tiered với accelerator
  Given Worker "Sales Rep H" có Commission Plan "SEA Sales Q1 2026"
  And plan: Tier 1 (0–80% quota) = 5%, Tier 2 (80–100%) = 8%, Tier 3 (>100%) = 12% accelerator
  And monthly quota = VND 500,000,000
  And actual sales = VND 600,000,000 (= 120% quota)
  When Sales Ops import transactions và run CalculateCommission
  Then Commission = (400M × 5%) + (100M × 8%) + (100M × 12%)
    = 20,000,000 + 8,000,000 + 12,000,000 = VND 40,000,000
  And CommissionCalculated event được tạo với tier breakdown
  And TaxableItemCreated event được bridge sang Payroll

Scenario: Sales Rep xem commission real-time (< 5 giây)
  Given Sales Rep H đang login vào commission dashboard
  And Sales transaction mới được nhập vào CRM
  When transaction sync sang xTalent TR (via Kafka streaming)
  Then dashboard của Sales Rep H cập nhật trong < 5 giây
  And quota progress bar và projected commission được cập nhật

Scenario: Sales Rep dispute một transaction
  Given CommissionCalculated cho tháng 3/2026
  And Sales Rep I không đồng ý với transaction "TXN-2026-0312" (trị giá VND 50M bị exclude)
  When Sales Rep I submit dispute với evidence
  Then DisputeSubmitted event được tạo
  And commission của transaction đó bị freeze (không trả)
  And phần commission không tranh chấp vẫn được trả đúng hạn
  And Sales Ops nhận notification để review dispute
```

**Business Rules**: BR-K03, BR-A08, BR-I01
**Dependencies**: FR-VP-003, FR-VP-006

---

## US-010: Khấu trừ tự động theo chu kỳ payroll

**Priority**: P0
**Sub-module**: Deductions
**Actor**: Payroll Administrator

**Với tư cách là** Payroll Administrator
**Tôi muốn** xử lý tự động tất cả các khoản khấu trừ trong mỗi kỳ lương
**Để** đảm bảo Worker nhận đúng lương thực nhận và các nghĩa vụ tài chính được thực hiện đầy đủ

### Acceptance Criteria

```gherkin
Scenario: Nhiều deductions được xử lý đúng thứ tự ưu tiên
  Given Worker "J" có các deductions trong tháng 4/2026:
    | Type        | Amount      | Priority |
    | Garnishment | 2,000,000   | 1 (highest) |
    | Loan        | 1,500,000   | 2           |
    | Voluntary   | 500,000     | 3           |
  And take-home salary = VND 10,000,000
  When System ProcessDeductions trong payroll run
  Then thứ tự xử lý: Garnishment (2M) → Loan (1.5M) → Voluntary (0.5M)
  And net pay = 10,000,000 - 2,000,000 - 1,500,000 - 500,000 = VND 6,000,000
  And DeductionsProcessed event được tạo với full breakdown

Scenario: Deduction vượt available pay
  Given Worker "K" chỉ còn VND 1,000,000 take-home sau tax
  And loan repayment scheduled = VND 1,500,000
  When System cố gắng process loan deduction
  Then System chỉ deduct VND 1,000,000 (available amount)
  And remaining VND 500,000 được carry forward sang kỳ sau
  And HR Admin nhận alert: "Worker K: Insufficient pay cho loan deduction tháng này"

Scenario: Worker tự đăng ký voluntary deduction
  Given Worker "L" muốn đóng góp VND 500,000/tháng vào quỹ hưu trí tự nguyện
  When Worker L elect voluntary deduction qua self-service portal
  Then VoluntaryDeductionElected event được tạo
  And deduction tự động áp dụng từ kỳ lương kế tiếp
  And Worker L nhận confirmation với effective date
```

**Business Rules**: BR-D02
**Dependencies**: FR-DED-001 đến FR-DED-004

---

## US-011: Khai báo và tính thuế TNCN

**Priority**: P0
**Sub-module**: Tax Withholding
**Actor**: Tax Administrator + Worker (Self-Service)

**Với tư cách là** Worker
**Tôi muốn** khai báo thông tin thuế cá nhân (số người phụ thuộc, giảm trừ gia cảnh)
**Để** hệ thống tính đúng số thuế phải khấu trừ mỗi tháng

### Acceptance Criteria

```gherkin
Scenario: Worker khai báo người phụ thuộc — giảm thuế
  Given Worker "M" đang làm việc tại Legal Entity Vietnam
  And personal allowance = VND 11,000,000/tháng
  And Worker M muốn khai báo 2 người phụ thuộc (dependant allowance = 4,400,000 × 2 = 8,800,000)
  When Worker M submit tax declaration qua self-service portal
  Then TaxDeclarationUpdated event được tạo
  And taxable income = GrossIncome - 11,000,000 - 8,800,000 (từ kỳ khai báo)
  And TaxCalculated event phản ánh số thuế thấp hơn
  And Worker M nhận xác nhận khai báo

Scenario: Tax API down — dual-path fallback
  Given Tax Administrator đang submit e-Filing cuối tháng cho Vietnam Tax Authority
  And Tax Authority API trả về timeout (503)
  When 15 phút sau, System vẫn không nhận được response
  Then System trigger alert: "Tax API không phản hồi — switching to file export"
  And sau 2 giờ tổng cộng: file export path được activate
  And Tax file XML được generate và Tax Admin nhận để nộp thủ công
  And audit log ghi nhận: "Tax filing mode: file_export due to API failure at [timestamp]"

Scenario: Tax bracket thay đổi giữa năm
  Given Vietnam thay đổi tax bracket hiệu lực 2026-07-01
  And Tax Admin cập nhật tax bracket mới với effective_date = 2026-07-01
  When System tính thuế cho kỳ tháng 7/2026
  Then bracket cũ được dùng cho income trước 2026-07-01
  And bracket mới được dùng từ 2026-07-01
  And CalculationRuleVersioned event được tạo
```

**Business Rules**: BR-C01, BR-D01, BR-I03, BR-I04 (Tax SLA)
**Dependencies**: FR-TAX-001 đến FR-TAX-004

---

## US-012: Proration tự động khi gia nhập giữa kỳ

**Priority**: P0
**Sub-module**: Calculation Rules Engine
**Actor**: System (Automated)

**Với tư cách là** hệ thống tự động
**Tôi muốn** tự động prorate lương khi Worker gia nhập hoặc nghỉ việc giữa kỳ
**Để** tính đúng lương thực nhận mà không cần tính thủ công

### Acceptance Criteria

```gherkin
Scenario: Worker gia nhập ngày 15 tháng 4 (calendar days)
  Given Worker "N" gia nhập 2026-04-15 với Monthly Salary = VND 20,000,000
  And Legal Entity "XYZ Corp" cấu hình proration method = CALENDAR_DAYS cho base salary
  And tháng 4/2026 có 30 ngày; Worker làm từ ngày 15 → còn 16 ngày
  When System tính lương tháng 4/2026
  Then ProrationApplied = 16 / 30 × 20,000,000 = VND 10,666,667
  And SalaryProrated event được tạo với breakdown
  And reason = "New hire mid-period: 16/30 days"

Scenario: Proration theo working days (configurable)
  Given Legal Entity "ABC" cấu hình proration method = WORKING_DAYS cho base salary
  And Worker "O" gia nhập 2026-04-15
  And total working days tháng 4 = 22 ngày; từ ngày 15 còn 11 ngày làm
  When System tính proration
  Then ProrationApplied = 11 / 22 × BaseSalary
  And calculation note: "method: WORKING_DAYS"

Scenario: Thay đổi proration method — không ảnh hưởng kỳ cũ
  Given Legal Entity "DEF" đang dùng CALENDAR_DAYS
  And Payroll Admin thay đổi sang WORKING_DAYS effective 2026-05-01
  When System tính kỳ tháng 5/2026 trở đi
  Then dùng WORKING_DAYS method
  And kỳ tháng 4/2026 và trước đó vẫn dùng CALENDAR_DAYS (không retroactive)
  And CalculationRuleVersioned event được tạo
```

**Business Rules**: BR-K01, BR-D01
**Dependencies**: FR-CR-002, FR-CR-003

---

## US-013: Bridge dữ liệu sang Payroll module

**Priority**: P0
**Sub-module**: Taxable Bridge
**Actor**: System (Automated)

**Với tư cách là** hệ thống tự động
**Tôi muốn** đảm bảo mọi thay đổi compensation và taxable event được gửi sang Payroll đúng thời gian
**Để** Payroll module có đủ dữ liệu chính xác để tính payslip không bỏ sót khoản nào

### Acceptance Criteria

```gherkin
Scenario: Salary change được bridge real-time sang Payroll
  Given CompensationApproved event được tạo lúc 14:30
  And Payroll module đang active và kết nối Kafka
  When System trigger ProcessPayrollBridge
  Then Kafka event SalaryChanged được publish < 1 phút sau approval
  And Payroll module nhận event và update worker pay record
  And idempotency key đính kèm để tránh duplicate processing
  And PayrollBridgeProcessed event được tạo trong TR

Scenario: Bridge delay vượt 15 phút — escalation
  Given SalaryChanged event được publish lúc 09:00
  And Payroll module không confirm receipt sau 15 phút
  When 09:15 không có acknowledgment
  Then System trigger PayrollBridgeDelayed alert
  And Payroll Admin + HR Admin nhận notification
  And System retry với exponential backoff (1, 2, 4, 8 phút)
  And nếu vẫn fail sau 2 giờ → manual intervention required alert

Scenario: Taxable Item từ perk redemption được capture
  Given Worker "P" redeem perk "Gift Card VND 500,000"
  When PointsRedeemed event được tạo
  Then TaxableItemCreated event tự động được tạo: amount = 500,000, type = PERK_CASH_EQUIVALENT
  And taxable item được bridge sang Payroll với idempotency key
  And Payroll module include trong kỳ lương gần nhất
  And không bỏ sót dù event xảy ra bất kỳ lúc nào trong tháng

Scenario: Idempotency — không duplicate khi retry
  Given TaxableItemCreated event được gửi sang Payroll với idempotency_key = "TXB-2026-04-P-001"
  And Payroll nhận nhưng acknowledgment bị mất → TR retry
  When System gửi lại cùng event với idempotency_key = "TXB-2026-04-P-001"
  Then Payroll module detect duplicate (same key trong dedup window 24 giờ)
  And Payroll bỏ qua event trùng lặp, không xử lý 2 lần
  And TR nhận success acknowledgment
```

**Business Rules**: BR-I01, BR-I02, BR-I06, BR-D07
**Dependencies**: FR-TXB-001, FR-TXB-002

---

## US-014: Tạo offer cho candidate

**Priority**: P1
**Sub-module**: Offer Management
**Actor**: Hiring Manager

**Với tư cách là** Hiring Manager
**Tôi muốn** tạo offer letter chuyên nghiệp và submit để phê duyệt trước khi gửi candidate
**Để** chuẩn hóa quy trình offer và tăng tỷ lệ chấp nhận

### Acceptance Criteria

```gherkin
Scenario: Tạo offer từ template với minimum wage validation
  Given Hiring Manager "HM-01" đang tuyển dụng cho vị trí "Software Engineer - VN"
  And offer template "Tech Role Vietnam" đã được cấu hình
  And candidate "Candidate Q" đã được chọn
  When HM-01 tạo offer: salary = VND 25,000,000, bonus target = 15%, grade = L3
  Then system validate minimum wage: 25,000,000 > 4,680,000 (Vùng 1) → PASS
  And OfferCreated event được tạo
  And offer letter PDF preview được generate với branding doanh nghiệp
  And offer được route đến approval workflow

Scenario: Offer phải qua approval trước khi gửi candidate
  Given offer "Candidate Q" đã được tạo
  When HM-01 submit offer for approval
  Then OfferSubmittedForApproval event được tạo
  And Director nhận notification để review (configurable approver)
  And offer không thể được gửi đến candidate cho đến khi có approval
  And candidate nhận auto-reply: "Offer đang được xử lý, bạn sẽ nhận được trong vòng 2 ngày làm việc"

Scenario: AI cold start — không đủ market data
  Given Hiring Manager muốn xem AI salary recommendation
  And chưa đủ historical data cho position này (< 10 data points)
  When HM-01 click "Xem AI Recommendation"
  Then hệ thống hiển thị market benchmark từ external data (manual upload)
  And disclaimer: "Dữ liệu nội bộ hạn chế. Kết quả dựa trên market benchmark."
  And không block HM-01 khỏi tạo offer
```

**Business Rules**: BR-C05, BR-A05
**Dependencies**: FR-OM-001, FR-OM-002, CO module (Worker, Working Relationship)

---

## US-015: Ký offer điện tử

**Priority**: P1
**Sub-module**: Offer Management
**Actor**: Candidate

**Với tư cách là** Candidate
**Tôi muốn** ký offer letter điện tử từ bất kỳ thiết bị nào
**Để** chấp nhận offer nhanh chóng mà không cần in và scan giấy tờ

### Acceptance Criteria

```gherkin
Scenario: Candidate ký offer thành công
  Given offer "Candidate R" đã được approved và gửi qua e-signature
  And e-signature provider = DocuSign (configurable)
  When Candidate R ký điện tử qua link trong email
  Then DocuSign webhook gửi callback: status = SIGNED
  And OfferAccepted event được tạo trong xTalent
  And HR Admin nhận notification
  And offer letter với chữ ký được lưu vào Offer record (7-year retention)

Scenario: E-signature webhook timeout — polling fallback
  Given Candidate S đã ký nhưng DocuSign webhook callback bị delay
  And 15 phút sau vẫn chưa có callback
  When System polling timer trigger
  Then System query DocuSign API: status = SIGNED (confirmed)
  And OfferAccepted event được tạo (delayed 15 phút nhưng không mất)
  And audit log: "Confirmed via polling fallback at [timestamp]"

Scenario: Candidate từ chối và request counter-offer
  Given Candidate T nhận offer với salary VND 20,000,000
  When Candidate T click "Request Counter-offer" và đề xuất VND 23,000,000
  Then CounterOfferRequested event được tạo
  And Hiring Manager nhận notification với candidate's counter proposal
  And deadline 2 ngày làm việc để HM phản hồi
  And nếu HR accept counter: OfferRevised → Approved → Sent lại cho ký
```

**Business Rules**: BR-I04 (E-signature dual confirm)
**Dependencies**: US-014, FR-OM-003, FR-OM-004

---

## US-016: Phát hiện khoảng cách công bằng lương (Pay Equity)

**Priority**: P1 (USP)
**Sub-module**: Core Compensation
**Actor**: Compensation Manager

**Với tư cách là** Compensation Manager
**Tôi muốn** phát hiện tự động khoảng cách lương bất công bằng theo giới tính, dân tộc hoặc tuổi
**Để** chủ động giải quyết trước khi trở thành vấn đề pháp lý hoặc ảnh hưởng đến retention

### Acceptance Criteria

```gherkin
Scenario: Hệ thống phát hiện gender pay gap trong Grade L3
  Given Compensation Manager trigger PayEquityAnalysis cho Legal Entity "VNG Corp"
  And analysis method = COMPA_RATIO (configurable: simple / regression / statistical)
  And cohort = Grade L3, cùng location, cùng department
  And avg compa-ratio Female = 0.88, avg compa-ratio Male = 1.02
  When analysis complete
  Then PayEquityGapDetected event được tạo ⭐
  And report hiển thị: "Gap: 14% gender pay disparity in L3 Engineering"
  And list Workers bị affected với proposed adjustment ranges
  And Compliance Officer nhận notification

Scenario: Compa-ratio visible theo config (anonymous distribution)
  Given config per enterprise = "anonymous distribution" (default)
  When People Manager view compensation analytics
  Then Manager thấy distribution chart (không biết salary của từng người)
  And Manager không thể drill down đến individual salary
  And Compensation Manager (có quyền cao hơn) mới thấy individual data

Scenario: AI recommendation bị từ chối — AI adoption tracking
  Given AI recommended salary VND 22,000,000 cho promotion Worker "U"
  When Hiring Manager submit offer với VND 24,000,000 (cao hơn AI recommendation)
  Then AIRecommendationOverridden event được tạo
  And system track: reason = "Manager judgment" (optional field)
  And AI adoption rate metric được cập nhật
```

**Business Rules**: BR-K04, BR-A09
**Dependencies**: FR-CC-006, FR-CC-003

---

## US-017: Commission dashboard real-time (< 5 giây)

**Priority**: P1 (USP)
**Sub-module**: Variable Pay — Commission
**Actor**: Worker (Sales Rep)

**Với tư cách là** Sales Rep (Worker)
**Tôi muốn** xem progress và projected commission của mình trong real-time
**Để** tôi biết chính xác mình đang ở đâu so với quota và cần thêm bao nhiêu để đạt accelerator

### Acceptance Criteria

```gherkin
Scenario: Dashboard cập nhật sau khi CRM sync transaction
  Given Sales Rep "Worker V" đang view commission dashboard
  And quota tháng 4 = VND 500,000,000; đã đạt 350,000,000 (70%)
  When CRM sync transaction mới VND 50,000,000 vào lúc 14:30:00
  Then dashboard của Worker V hiển thị quota progress = 80% trước 14:30:05 (< 5 giây)
  And RealTimeCommissionCalculated event được tạo ⭐
  And projected commission cập nhật theo tiered rates
  And "Distance to next tier" indicator cập nhật: "VND 100M to reach Tier 3 accelerator"

Scenario: Dashboard khi commission bị dispute
  Given một transaction trong tháng đang bị dispute
  When Worker V view dashboard
  Then phần disputed được hiển thị riêng: "Disputed: VND X (frozen pending review)"
  And undisputed commission = total - disputed (vẫn hiển thị rõ ràng)
  And estimated payout = undisputed amount (không bao gồm phần đang dispute)
```

**Business Rules**: BR-K03, BR-A08
**Dependencies**: US-009, FR-VP-003

---

## US-018: Ghi nhận đồng nghiệp (Peer Recognition)

**Priority**: P1
**Sub-module**: Recognition Programs
**Actor**: Worker (Peer)

**Với tư cách là** Worker
**Tôi muốn** ghi nhận đồng nghiệp vì đóng góp xuất sắc
**Để** xây dựng văn hóa ghi nhận và tăng engagement trong team

### Acceptance Criteria

```gherkin
Scenario: Worker gửi peer recognition thành công
  Given Worker "W" muốn ghi nhận Worker "X" vì hoàn thành dự án xuất sắc
  And Worker W còn 50 points trong giving budget tháng này
  And recognition amount = 20 points, message = "Excellent work on Project Phoenix!"
  When Worker W submit peer recognition
  Then PeerRecognitionSent event được tạo
  And Worker X nhận 20 points vào balance
  And nếu visibility = PUBLIC: SocialRecognitionPosted event được tạo ⭐
  And social feed hiển thị recognition (với moderation nếu enterprise config = human review)
  And Worker W còn lại 30 points giving budget tháng này

Scenario: Recognition vượt giving limit/tháng
  Given Worker W đã dùng hết 100 points giving budget tháng này
  When Worker W cố gửi thêm recognition
  Then hệ thống block: "Bạn đã dùng hết giving budget tháng này (100 points)"
  And Worker W được thông báo budget mới sẽ refresh vào đầu tháng sau

Scenario: FIFO expiration — điểm cũ hết hạn trước
  Given Worker Y có point balance:
    | Earned    | Amount | Expiry     |
    | 2025-01-15| 100    | 2026-01-15 |
    | 2025-06-01| 200    | 2026-06-01 |
  And Worker Y redeem 50 points
  Then 50 points được trừ từ lô earn ngày 2025-01-15 (FIFO)
  And balance: [50 points expiry 2026-01-15] + [200 points expiry 2026-06-01]
```

**Business Rules**: BR-K05
**Dependencies**: FR-REC-001, FR-REC-002, FR-REC-003

---

## US-019: Total Rewards Statement

**Priority**: P1
**Sub-module**: TR Statement
**Actor**: Worker (Self-Service)

**Với tư cách là** Worker
**Tôi muốn** xem và tải xuống Total Rewards Statement của mình
**Để** hiểu đầy đủ giá trị đãi ngộ thực sự tôi nhận được từ công ty (không chỉ lương tay)

### Acceptance Criteria

```gherkin
Scenario: Worker xem TR Statement on-demand
  Given Worker "Z" login vào self-service portal
  And statement data cho năm 2025 đã sẵn sàng
  When Worker Z click "Xem Total Rewards Statement 2025"
  Then StatementGenerated event được tạo (nếu chưa có) hoặc truy xuất từ cache
  And statement hiển thị trong < 5 giây với các sections:
    | Section        | Value (example)        |
    | Base Salary    | VND 240,000,000/year  |
    | Annual Bonus   | VND 36,000,000         |
    | Benefits Value | VND 24,000,000         |
    | Recognition    | VND 5,000,000 equiv    |
    | Total Value    | VND 305,000,000        |
  And Worker Z có thể download PDF với enterprise branding
  And StatementViewed event được tạo

Scenario: Statement bị lock sau 7 năm (immutable)
  Given statement năm 2019 đang được lưu
  When HR Admin cố gắng delete hoặc modify statement này
  Then hệ thống từ chối: "Statement records are immutable and cannot be modified"
  And audit log ghi nhận attempt

Scenario: Annual auto-generate cho tất cả Workers
  Given System cron job chạy ngày 2027-01-15 (mid-January)
  When auto-generate job trigger cho statement năm 2026
  Then StatementsGenerated event được tạo cho mỗi Worker active trong 2026
  And Workers nhận email notification với link xem statement
  And HR Admin nhận summary report: "X statements generated successfully"
```

**Business Rules**: BR-D03, BR-A06
**Dependencies**: FR-TRS-001 đến FR-TRS-004

---

## US-020: Configurable proration method per Legal Entity

**Priority**: P0
**Sub-module**: Calculation Rules Engine
**Actor**: HR Administrator

**Với tư cách là** HR Administrator
**Tôi muốn** cấu hình phương pháp proration khác nhau cho từng Legal Entity
**Để** đảm bảo mỗi quốc gia áp dụng đúng quy tắc theo luật lao động địa phương

### Acceptance Criteria

```gherkin
Scenario: HR Admin cấu hình proration method per Legal Entity
  Given HR Admin "Admin A" có quyền cấu hình Legal Entity "Vietnam HQ"
  When Admin A set proration_method = CALENDAR_DAYS cho "Base Salary" component
  And set proration_method = WORKING_DAYS cho "Transportation Allowance" component
  Then cấu hình được lưu với effective_date = 2026-04-01
  And CountryRulesConfigured event được tạo
  And từ 2026-04-01 mọi proration của Legal Entity này theo config mới

Scenario: Config scope inheritance — LE override Country default
  Given Country Vietnam default = CALENDAR_DAYS
  And Legal Entity "VN Branch 2" set WORKING_DAYS (override)
  And Legal Entity "VN HQ" không có override (inherit Country default)
  When System prorate cho Worker ở VN Branch 2
  Then dùng WORKING_DAYS (LE-specific override)
  When System prorate cho Worker ở VN HQ
  Then dùng CALENDAR_DAYS (inherited from Country)
```

**Business Rules**: BR-K01, BR-D01
**Dependencies**: FR-CR-002, FR-CC-008

---

## US-021: Cấu hình SI engine cho quốc gia mới

**Priority**: P0
**Sub-module**: Calculation Rules Engine
**Actor**: HR Administrator

**Với tư cách là** HR Administrator
**Tôi muốn** cấu hình hoàn toàn mới một statutory contribution engine cho quốc gia
**Để** onboard quốc gia mới vào xTalent TR mà không cần developer code deployment

### Acceptance Criteria

```gherkin
Scenario: HR Admin cấu hình CPF Singapore
  Given HR Admin muốn setup CPF engine cho Singapore Legal Entity
  And CPF rates: employee max 20%, employer 17%, cap SGD 6,000/month
  When HR Admin configure via Admin UI:
    | Field              | Value          |
    | Country            | SG             |
    | Contribution Name  | CPF            |
    | Employee Rate      | 20%            |
    | Employer Rate      | 17%            |
    | Monthly Wage Cap   | SGD 6,000      |
    | Effective Date     | 2026-06-01     |
  Then CountryRulesConfigured event được tạo
  And từ 2026-06-01 Workers tại SG Legal Entity có CPF calculation
  And không cần code deployment

Scenario: Rate thay đổi — versioning không mất lịch sử
  Given CPF Singapore đang active với employer rate = 17%
  When MAS công bố thay đổi rate lên 17.5% từ 2027-01-01
  And HR Admin update rate với effective_date = 2027-01-01
  Then CalculationRuleVersioned event được tạo
  And kỳ lương trước 2027-01-01 vẫn dùng 17%
  And từ 2027-01-01 dùng 17.5%
  And history đầy đủ có thể audit
```

**Business Rules**: BR-C07 đến BR-C11, BR-D01
**Dependencies**: FR-CR-004

---

## US-022: Xem lịch sử lương của Worker

**Priority**: P0
**Sub-module**: Core Compensation
**Actor**: Worker (Self-Service) + HR Administrator

**Với tư cách là** Worker
**Tôi muốn** xem lịch sử các lần thay đổi lương của mình
**Để** hiểu rõ quá trình phát triển và kiểm chứng tính chính xác

### Acceptance Criteria

```gherkin
Scenario: Worker xem compensation history của bản thân
  Given Worker "AA" login vào self-service portal
  When Worker AA click "Xem lịch sử lương"
  Then CompensationHistoryViewed event được tạo
  And hiển thị danh sách các lần thay đổi:
    | Date       | Type          | Old Salary | New Salary | Reason          |
    | 2024-01-01 | Annual Merit  | 15,000,000 | 16,500,000 | Merit 2024      |
    | 2025-01-01 | Annual Merit  | 16,500,000 | 18,000,000 | Merit 2025      |
    | 2025-07-01 | Promotion     | 18,000,000 | 22,000,000 | Promoted to L3  |
  And Worker AA KHÔNG thấy salary của colleagues
  And SCD Type 2 records đảm bảo data đầy đủ, không mất lịch sử

Scenario: HR Admin xem lịch sử Worker với full audit context
  Given HR Admin với quyền đọc legal entity "VNG Corp"
  When HR Admin xem compensation history của Worker "BB"
  Then hiển thị đầy đủ hơn Worker view: thêm approver, audit_id
  And mọi truy cập được log vào audit trail (access logging 100%)
```

**Business Rules**: BR-D01, BR-D02, BR-D04
**Dependencies**: FR-CC-002, FR-AUD-001

---

## US-023: Xử lý tranh chấp hoa hồng

**Priority**: P1
**Sub-module**: Variable Pay — Commission
**Actor**: Sales Rep (Worker) + Sales Operations

**Với tư cách là** Sales Rep (Worker)
**Tôi muốn** submit tranh chấp về một transaction trong commission statement
**Để** đảm bảo tôi được trả đúng và có quy trình rõ ràng để giải quyết bất đồng

### Acceptance Criteria

```gherkin
Scenario: Sales Rep dispute một transaction — partial freeze
  Given CommissionCalculated cho Worker "Sales Rep CC" tháng 3/2026
  And total commission = VND 40,000,000
  And Sales Rep CC dispute transaction "TXN-001" (trị giá VND 8,000,000)
  When Sales Rep CC submit dispute với evidence
  Then DisputeSubmitted event được tạo
  And chỉ VND 8,000,000 (transaction liên quan) bị freeze
  And VND 32,000,000 (undisputed) được bridge sang Payroll đúng hạn
  And Sales Ops nhận notification với 5 ngày làm việc để resolve

Scenario: Sales Ops approve dispute — retroactive payment
  Given dispute "TXN-001" được Sales Ops investigate
  And kết luận: transaction hợp lệ, Sales Rep CC đúng
  When Sales Ops approve dispute
  Then CommissionDisputeApproved event được tạo
  And VND 8,000,000 được release và bridge sang Payroll kỳ kế
  And Sales Rep CC nhận notification: "Dispute resolved: VND 8,000,000 added to next payment"

Scenario: Sales Ops reject dispute
  Given investigation cho thấy transaction không hợp lệ
  When Sales Ops reject dispute với reason
  Then DisputeRejected event được tạo
  And VND 8,000,000 không được trả
  And Sales Rep CC nhận notification với explanation
  And Sales Rep CC có thể escalate lên HR Admin nếu không đồng ý
```

**Business Rules**: BR-A08, BR-K03
**Dependencies**: US-009, FR-VP-006

---

## US-024: Đăng ký phúc lợi khi có Qualifying Life Event (QLE)

**Priority**: P1
**Sub-module**: Benefits Administration
**Actor**: Worker (Self-Service)

**Với tư cách là** Worker
**Tôi muốn** cập nhật đăng ký phúc lợi khi có sự kiện cuộc sống quan trọng
**Để** bổ sung người thân mới được bảo hiểm mà không phải chờ đến Open Enrollment

### Acceptance Criteria

```gherkin
Scenario: Worker thêm dependent sau khi sinh con
  Given Worker "DD" vừa sinh con ngày 2026-05-10
  And QLE window = 30 ngày từ ngày sự kiện (2026-05-10 đến 2026-06-09)
  When Worker DD submit QLE request: event = BIRTH_OF_CHILD, date = 2026-05-10
  And thêm dependent "Nguyen Minh Khoi" vào Medical plan
  Then DependentAdded event được tạo
  And dependent verification được trigger (configurable: auto/document/carrier verify)
  And EDI 834 update được gửi đến carrier với coverage effective date = 2026-05-10
  And Worker DD nhận confirmation

Scenario: QLE request sau 30 ngày bị từ chối
  Given Worker "EE" muốn thêm dependent nhưng nộp sau 45 ngày kể từ sự kiện
  When Worker EE submit QLE request
  Then hệ thống từ chối: "QLE window đã đóng (30 ngày từ ngày sự kiện). Vui lòng liên hệ HR Admin."
  And Worker EE được hướng dẫn đến Open Enrollment tiếp theo

Scenario: Dependent verification required — document upload
  Given enterprise config = "Document Required" cho dependent verification
  When Worker FF thêm spouse vào Medical plan
  Then hệ thống yêu cầu upload marriage certificate
  And coverage tạm thời pending document verification
  And HR Admin nhận notification để review document
  And sau khi HR Admin approve → coverage effective
```

**Business Rules**: BR-C05, BR-I05
**Dependencies**: FR-BA-002, FR-BA-006

---

*User Stories Version 1.0.0 — ODSA Step 2 (Reality) Output*
*Business Analyst Agent — 2026-03-26*
*Tổng: 24 user stories | P0: 14 | P1: 10 | Gherkin scenarios: 70+*
