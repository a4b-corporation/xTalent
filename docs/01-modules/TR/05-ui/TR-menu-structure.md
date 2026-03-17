# Total Rewards (TR) — Menu Structure

**Module**: Total Rewards (TR)  
**Version**: 1.0  
**Ngày**: 2026-03-17

---

## Tổng quan

Module Total Rewards gồm **11 sub-modules** được tổ chức thành **6 nhóm chức năng chính**. Menu được thiết kế theo góc nhìn người dùng (HR Admin, Manager, Employee, Recruiter) với phân cấp rõ ràng.

---

## Menu Tree

```
Total Rewards
│
├── 1. Compensation                          ─── Quản lý lương & cấp bậc
│   ├── 1.1 Salary Basis                     ─── Template cách trả lương
│   │   ├── Salary Basis List                Danh sách salary basis (Monthly VN, Hourly US...)
│   │   └── Create/Edit Salary Basis         Tạo/sửa basis: frequency, currency, country rules
│   │
│   ├── 1.2 Pay Components                   ─── Thành phần cấu thành lương
│   │   ├── Component Definitions            Danh sách component: BASE, ALLOWANCE, BONUS, EQUITY, DEDUCTION, OT
│   │   ├── Create/Edit Component            Tạo/sửa: tax treatment, proration, SI rules
│   │   └── Component Assignment             Gắn component vào salary basis
│   │
│   ├── 1.3 Grade & Career Ladder            ─── Cấp bậc và đường thăng tiến
│   │   ├── Career Ladder Setup              Tạo ladders: Technical, Management, Specialist, Sales, Executive
│   │   ├── Grade Management                 Danh sách grades (G1-G10), version history (SCD-2)
│   │   └── Grade History                    Lịch sử thay đổi grade theo thời gian
│   │
│   ├── 1.4 Pay Range                        ─── Dải lương theo cấp bậc
│   │   ├── Pay Range Setup                  Thiết lập min/mid/max theo grade + 4 scope levels
│   │   ├── Compa-Ratio Analysis             Phân tích vị trí lương NV so với midpoint
│   │   └── Pay Range Import                 Import pay range từ market survey
│   │
│   ├── 1.5 Employee Compensation            ─── Lương thực tế nhân viên
│   │   ├── Compensation Overview            Tổng quan lương hiện tại (snapshot)
│   │   ├── Compensation History             Lịch sử tất cả thay đổi lương
│   │   └── Salary Comparison                So sánh lương NV vs pay range vs peers
│   │
│   └── 1.6 Compensation Cycle               ─── Vòng đời điều chỉnh lương
│       ├── Cycle Management                 Tạo/quản lý cycles: Merit, Promotion, Market Adj, Equity Correction
│       ├── Compensation Plan                Thiết lập merit matrix, eligibility, approval thresholds
│       ├── Budget Allocation                Phân bổ ngân sách theo phòng ban
│       ├── Budget Tracking                  Theo dõi real-time: allocated vs proposed vs approved
│       ├── Manager Workspace                Đề xuất tăng lương cho team (Manager view)
│       ├── Approval Queue                   Phê duyệt đề xuất (routing tự động theo %)
│       └── Cycle Reports                    Báo cáo kết quả cycle: coverage, avg increase, budget variance
│
├── 2. Variable Pay                          ─── Thưởng biến động & cổ phiếu
│   ├── 2.1 Bonus Plans                      ─── Kế hoạch thưởng
│   │   ├── Bonus Plan Setup                 Tạo kế hoạch: STI (ngắn hạn), LTI (dài hạn), Spot Bonus
│   │   ├── Target Assignment                Gắn bonus target % cho NV/nhóm
│   │   ├── Bonus Calculation                Tính thưởng: Salary × Target% × Perf × Company Multiplier
│   │   └── Bonus Approval & Payout          Phê duyệt và xác nhận chi trả thưởng
│   │
│   ├── 2.2 Equity Management                ─── Quản lý cổ phiếu/quyền mua
│   │   ├── Equity Plans                     Thiết lập RSU, Stock Options, ESPP
│   │   ├── Grant Management                 Tạo/quản lý equity grants cho NV
│   │   ├── Vesting Schedule                 Theo dõi lịch vest: Cliff, Graded, Performance-based
│   │   ├── Vesting Events                   Xem sự kiện vest: số lượng vest, FMV, taxable amount
│   │   └── Equity Transactions              Lịch sử giao dịch: vest, exercise, sell, forfeit
│   │
│   └── 2.3 Commission Plans                 ─── Kế hoạch hoa hồng
│       ├── Commission Setup                 Thiết lập: tiered rates, accelerators, quota
│       ├── Quota Tracking                   Theo dõi doanh số vs quota theo tháng
│       └── Commission Calculation           Tính hoa hồng tự động theo cycle
│
├── 3. Benefits                              ─── Quản lý phúc lợi
│   ├── 3.1 Plan Configuration               ─── Cấu hình kế hoạch phúc lợi
│   │   ├── Benefit Plan List                Danh sách plans: Medical, Dental, Vision, Life, Disability, Retirement, Wellness, Perk
│   │   ├── Create/Edit Plan                 Tạo/sửa plan: coverage tiers, premium methods, limits
│   │   ├── Plan Options                     Cấu hình options trong plan (Gold/Silver/Bronze)
│   │   └── Eligibility Rules                Gắn eligibility profile cho plan (ai được đăng ký)
│   │
│   ├── 3.2 Enrollment                       ─── Đăng ký phúc lợi
│   │   ├── Open Enrollment Setup            Tạo kỳ đăng ký hàng năm: dates, eligible plans, reminders
│   │   ├── Employee Enrollment Portal       NV tự chọn plan, thêm dependents, xem cost (Self-service)
│   │   ├── Enrollment Dashboard             Theo dõi % hoàn thành enrollment, pending, overdue
│   │   └── Enrollment History               Lịch sử đăng ký của NV qua các năm
│   │
│   ├── 3.3 Life Events                      ─── Sự kiện cuộc sống
│   │   ├── Report Life Event                NV báo cáo: kết hôn, sinh con, ly hôn, mất coverage
│   │   ├── Document Verification            Upload/xác minh giấy tờ (giấy kết hôn, khai sinh...)
│   │   └── Mid-Year Enrollment              Mở window 30 ngày để NV thay đổi benefits
│   │
│   ├── 3.4 Dependents & Beneficiaries       ─── Người phụ thuộc & thụ hưởng
│   │   ├── Dependent Management             Quản lý vợ/chồng, con: thông tin, documents, age-out tracking
│   │   └── Beneficiary Designation          Chỉ định người thụ hưởng: primary %, contingent %
│   │
│   ├── 3.5 Claims & Reimbursement           ─── Yêu cầu bồi thường
│   │   ├── Submit Claim                     NV submit claim: medical, dental, vision, mental health
│   │   ├── Claims Review                    HR review/approve claims
│   │   └── Expense Reimbursement            Hoàn tiền: wellness, education, commuter, home office
│   │
│   └── 3.6 Carrier Integration              ─── Tích hợp nhà cung cấp BH
│       ├── Carrier Setup                    Cấu hình insurance carriers
│       ├── EDI 834 Export                   Generate file enrollment → gửi carrier tự động
│       └── Premium Reconciliation           Đối soát phí BH giữa hệ thống và carrier
│
├── 4. Recognition & Rewards                 ─── Ghi nhận & phần thưởng
│   ├── 4.1 Program Setup                    ─── Cấu hình chương trình
│   │   ├── Event Types                      Định nghĩa loại ghi nhận: Peer, Manager, Milestone + điểm
│   │   ├── Point Rules                      Quy tắc: điểm tối đa/tháng, budget, expiration (FIFO)
│   │   └── Program Analytics                Thống kê: participation rate, top givers/receivers
│   │
│   ├── 4.2 Give Recognition                 ─── Trao ghi nhận (Manager/Employee)
│   │   ├── Send Recognition                 Ghi nhận đồng nghiệp/nhân viên + message + điểm
│   │   ├── My Recognition Wall              Feed ghi nhận đã nhận và đã trao
│   │   └── Team Recognition                 Manager xem tất cả recognition trong team
│   │
│   ├── 4.3 Perk Catalog                     ─── Catalog phần thưởng
│   │   ├── Browse Perks                     Xem danh mục: Gift cards, Experiences, Merchandise, Charitable
│   │   ├── Manage Catalog                   HR thêm/sửa/xóa perks, set inventory, point cost
│   │   └── Perk Categories                  Quản lý danh mục phần thưởng
│   │
│   └── 4.4 Points & Redemption              ─── Điểm & đổi thưởng
│       ├── My Points                        Xem số dư điểm, lịch sử earned/spent/expired (FIFO)
│       ├── Redeem Points                    Đổi điểm lấy perk từ catalog
│       └── Redemption Tracking              Theo dõi trạng thái: PENDING → PROCESSING → DELIVERED
│
├── 5. Offer Management                      ─── Quản lý offer cho ứng viên
│   ├── 5.1 Templates                        ─── Template offer
│   │   ├── Offer Template List              Danh sách templates tái sử dụng
│   │   └── Create/Edit Template             Tạo/sửa: sections, branding, default components
│   │
│   ├── 5.2 Offer Packages                   ─── Gói offer cụ thể
│   │   ├── Create Offer Package             Tạo offer: base + bonus target + equity + benefits preview
│   │   ├── Offer Dashboard                  Danh sách offers: draft, sent, viewed, accepted, rejected
│   │   ├── Preview/DryRun                   Xem trước gross→net calculation (gọi PR engine)
│   │   └── Send Offer                       Gửi offer link cho candidate
│   │
│   ├── 5.3 Acceptance & Negotiation         ─── Chấp nhận & đàm phán
│   │   ├── Candidate Portal                 Candidate xem offer, ký e-signature hoặc counter
│   │   ├── Counter-Offer Workflow           HR xem counter, negotiate, revise & resend
│   │   └── Offer Acceptance                 Tracking chấp nhận: timestamp, IP, signed PDF
│   │
│   └── 5.4 Reports                          ─── Báo cáo offer
│       ├── Acceptance Rate                  Tỷ lệ chấp nhận offer theo department/grade/period
│       └── Time-to-Accept                   Thời gian trung bình từ gửi → chấp nhận
│
├── 6. Total Rewards Statement               ─── Báo cáo tổng đãi ngộ
│   ├── 6.1 Statement Configuration          ─── Cấu hình statement
│   │   ├── Statement Templates              Tạo template: logo, sections, currency, language
│   │   ├── Section Setup                    Chọn sections: Cash, Benefits, Equity, SI, Recognition
│   │   └── Display Options                  Config: equity vested only vs all, employer contrib only
│   │
│   ├── 6.2 Generation                       ─── Tạo statement
│   │   ├── Individual Statement             Tạo statement cho 1 NV
│   │   ├── Batch Generation                 Tạo hàng loạt: by department, grade, all
│   │   └── Preview                          Xem trước PDF trước khi gửi
│   │
│   └── 6.3 Distribution                     ─── Phân phối
│       ├── Send via Email                   Gửi PDF qua email (secure link)
│       ├── Employee Self-Service            NV xem/download statement trên portal
│       └── Distribution History             Lịch sử gửi statement
│
└── 7. Settings & Administration             ─── Cài đặt & quản trị
    ├── 7.1 Country Configuration            ─── Cấu hình quốc gia
    │   ├── Country Rules                    Working hours/days, tax system, SI system per country
    │   └── Holiday Calendar                 Ngày lễ + OT multiplier per country/region
    │
    ├── 7.2 Deduction Configuration          ─── Cấu hình khấu trừ
    │   ├── Deduction Types                  Loan repayment, Garnishment, Union dues...
    │   └── Deduction Priority               Thứ tự ưu tiên khấu trừ (statutory → voluntary)
    │
    ├── 7.3 Tax & SI Configuration           ─── Cấu hình thuế & BHXH
    │   ├── Tax Withholding Elections         NV khai báo số người phụ thuộc, mức giảm trừ
    │   └── SI Contribution Rates            Tỷ lệ BHXH/BHYT/BHTN theo quốc gia + salary cap
    │
    ├── 7.4 Taxable Bridge                   ─── Cầu nối chịu thuế
    │   ├── Taxable Items                    Danh sách items cần chuyển sang Payroll (equity, perk...)
    │   └── Processing Status                Trạng thái xử lý: PENDING → PROCESSED → PAID
    │
    ├── 7.5 Audit & Compliance               ─── Kiểm toán
    │   ├── Audit Log                        Mọi thay đổi compensation: who, when, before/after
    │   ├── Pay Equity Report                Phát hiện chênh lệch lương bất hợp lý
    │   └── Compliance Dashboard             Tuân thủ: ACA, COBRA, HIPAA, VN BHXH/BHYT
    │
    └── 7.6 Integration                      ─── Tích hợp
        ├── PR (Payroll) Integration         Cấu hình data flow → Payroll: comp snapshot, bonus, taxable
        ├── CO (Core HR) Integration         Mapping: employee, job, grade, legal entity
        └── External Integrations            Stock admin, benefits carriers, e-signature platforms
```

---

## Mapping Sub-modules → Menu

| # | Sub-module (Overview) | Menu Section | Vai trò chính |
|:-:|----------------------|:------------:|:-------------:|
| 1 | Core Compensation — Salary Basis | 1.1 | HR Admin |
| 2 | Core Compensation — Pay Components | 1.2 | HR Admin |
| 3 | Core Compensation — Grade & Career | 1.3 | HR Admin |
| 4 | Core Compensation — Pay Range | 1.4 | Comp Manager |
| 5 | Core Compensation — Comp Cycle | 1.6 | Comp Manager, Manager |
| 6 | Variable Pay — Bonus | 2.1 | HR Admin, Finance |
| 7 | Variable Pay — Equity | 2.2 | HR Admin, Finance |
| 8 | Variable Pay — Commission | 2.3 | Sales Ops |
| 9 | Benefits Administration | 3 | Benefits Admin, Employee |
| 10 | Recognition Programs | 4 | Employee, Manager |
| 11 | Offer Management | 5 | Recruiter, HR |
| — | Total Rewards Statement | 6 | HR, Employee |
| — | Deductions & Tax Withholding | 7.2, 7.3 | HR Admin |
| — | Taxable Bridge | 7.4 | HR Admin (auto) |
| — | Calculation Engine | 7 (implicit) | System (internal) |
| — | Audit & Compliance | 7.5 | Compliance, HR |

---

## Menu by User Role

### HR Administrator
```
Compensation > Salary Basis, Pay Components, Grade, Pay Range
Compensation > Compensation Cycle (setup)
Variable Pay > Bonus Plans, Equity Plans, Commission
Benefits > Plan Configuration, Enrollment Setup, Carrier Integration
Settings > Country Config, Tax/SI, Deduction, Taxable Bridge, Audit
```

### Compensation Manager
```
Compensation > Pay Range, Compa-Ratio Analysis
Compensation > Compensation Cycle > Plan, Budget, Reports
Variable Pay > Bonus Plans, Target Assignment
Statement > Configuration, Batch Generation
```

### Manager / Team Lead
```
Compensation > Manager Workspace (review team salary)
Compensation > Compensation Cycle > Manager Workspace (propose increases)
Variable Pay > Bonus Calculation (view team)
Recognition > Give Recognition, Team Recognition
```

### Employee (Self-Service)
```
Compensation > My Compensation Overview, History
Benefits > My Enrollment, Life Events, Dependents, Claims
Recognition > Send Recognition, My Points, Redeem Points
Statement > My Total Rewards Statement
```

### Recruiter
```
Offer Management > Templates, Create Offer, Send, Track
Offer Management > Acceptance Rate, Time-to-Accept
```

### Benefits Administrator
```
Benefits > Plan Config, Options, Eligibility Rules
Benefits > Enrollment Dashboard, Open Enrollment Setup
Benefits > Life Events, Claims Review
Benefits > Carrier Integration, Premium Reconciliation
```

---

## Ghi chú thiết kế

1. **Menu 1-6** là functional menus (người dùng thao tác hàng ngày)
2. **Menu 7** là admin/config menus (thiết lập ban đầu, ít thay đổi)
3. **Calculation Engine** không có menu riêng — là internal service, được gọi từ các chức năng khác
4. **Employee Self-Service** chỉ thấy subset menus liên quan đến bản thân
5. **Taxable Bridge** chạy chủ yếu tự động — HR chỉ cần monitor
