# Total Rewards (TR) — Menu Structure

**Module**: Total Rewards (TR)  
**Version**: 1.1 (revised per deep analysis)  
**Ngày**: 2026-03-17

---

## Tổng quan

Module Total Rewards quản lý **WHAT to pay** — định nghĩa thành phần lương, cấp bậc, phúc lợi, ghi nhận, offer. Sau khi áp dụng các đề xuất từ deep analysis, các chức năng sau **không còn thuộc TR**:

| Chức năng | Chuyển sang | Lý do (ref) |
|-----------|:-----------:|-------------|
| Eligibility Engine | **Core** | Single eligibility engine (Doc 05) |
| Country Configuration | **Core** | Unified country_config (Doc 06) |
| Holiday Calendar | **Core** | Consolidated holiday_calendar (Doc 06) |
| Tax/SI Calculation Rules | **PR** | PR owns calculation (Doc 07) |
| Tax Calculation Cache | **PR** | Engine optimization concern (Doc 07) |
| Gross→Net Pipeline | **PR** | Execution pipeline (Doc 07) |

---

## Menu Tree

```
Total Rewards
│
├── 1. Compensation                          ─── Quản lý lương & cấp bậc
│   ├── 1.1 Salary Basis                     ─── Template cách trả lương
│   │   ├── Salary Basis List                Danh sách basis (Monthly VN, Hourly US...)
│   │   └── Create/Edit Salary Basis         Tạo/sửa: frequency, currency, country rules
│   │
│   ├── 1.2 Pay Components                   ─── Thành phần cấu thành lương
│   │   ├── Component Definitions            Danh sách 6 loại: BASE, ALLOWANCE, BONUS, EQUITY, DEDUCTION, OT
│   │   ├── Create/Edit Component            Tạo/sửa: tax treatment, proration method, SI rules
│   │   └── Component ↔ Basis Mapping        Gắn components vào salary basis
│   │
│   ├── 1.3 Grade & Career Ladder            ─── Cấp bậc và đường thăng tiến
│   │   ├── Career Ladders                   Tạo ladders: Technical, Management, Specialist, Sales, Executive
│   │   ├── Grade Management                 Grades (G1-G10) với SCD-2 versioning
│   │   └── Grade History                    Lịch sử thay đổi grade theo thời gian
│   │
│   ├── 1.4 Pay Range                        ─── Dải lương theo cấp bậc
│   │   ├── Pay Range Setup                  Min/mid/max per grade, 4 scope levels (Global→LE→BU→Position)
│   │   ├── Compa-Ratio Analysis             Phân tích salary vs midpoint — below/target/above range
│   │   └── Pay Range Import                 Import dữ liệu từ market salary survey
│   │
│   ├── 1.5 Employee Compensation            ─── Lương thực tế nhân viên
│   │   ├── Compensation Overview            Snapshot lương hiện tại: components + amounts
│   │   ├── Compensation History             Toàn bộ lịch sử thay đổi (SCD-2 trail)
│   │   └── Salary Comparison                So sánh NV vs pay range vs peers
│   │
│   └── 1.6 Compensation Cycle               ─── Vòng đời điều chỉnh lương
│       ├── Cycle Management                 Tạo cycles: Merit, Promotion, Market Adj, Equity Correction
│       ├── Compensation Plan                Merit matrix, approval thresholds (< 5% auto, 5-10% Dir, > 10% VP)
│       ├── Budget Allocation                Phân bổ ngân sách theo department
│       ├── Budget Tracking                  Real-time: allocated vs proposed vs approved (🟢🟡🔴)
│       ├── Manager Workspace                Manager đề xuất tăng lương cho team
│       ├── Approval Queue                   Phê duyệt (auto-routing theo % tăng)
│       └── Cycle Reports                    KPIs: coverage, avg increase %, budget variance
│
├── 2. Variable Pay                          ─── Thưởng biến động & cổ phiếu
│   ├── 2.1 Bonus Plans                      ─── Kế hoạch thưởng
│   │   ├── Bonus Plan Setup                 STI (ngắn hạn), LTI (dài hạn), Spot Bonus
│   │   ├── Target Assignment                Gắn bonus target % cho NV/nhóm/grade
│   │   ├── Bonus Calculation                Formula: Salary × Target% × Perf × Company Multiplier
│   │   └── Bonus Approval & Payout          Phê duyệt và confirm chi trả → trigger PR
│   │
│   ├── 2.2 Equity Management                ─── Quản lý cổ phiếu
│   │   ├── Equity Plans                     RSU, Stock Options, ESPP
│   │   ├── Grant Management                 Tạo/quản lý equity grants cho NV
│   │   ├── Vesting Schedule                 Theo dõi vest: Cliff, Graded, Performance-based
│   │   ├── Vesting Events                   Sự kiện vest: quantity, FMV → auto-create taxable item
│   │   └── Equity Transactions              Lịch sử: vest, exercise, sell, forfeit
│   │
│   └── 2.3 Commission Plans                 ─── Kế hoạch hoa hồng
│       ├── Commission Setup                 Tiered rates, accelerators, quota definition
│       ├── Quota Tracking                   Doanh số vs quota theo tháng/quý
│       └── Commission Calculation           Tính hoa hồng tự động theo cycle
│
├── 3. Benefits                              ─── Quản lý phúc lợi
│   ├── 3.1 Plan Configuration               ─── Cấu hình kế hoạch
│   │   ├── Benefit Plan List                8 loại: Medical, Dental, Vision, Life, Disability, Retirement, Wellness, Perk
│   │   ├── Create/Edit Plan                 Coverage tiers (EE/EE+SP/EE+CH/Family), premium methods
│   │   └── Plan Options                     Options trong plan (Gold/Silver/Bronze tiers)
│   │
│   │   Note: Eligibility rules được quản lý tập trung tại Core module
│   │         TR chỉ gắn eligibility_profile_id (FK → Core) vào plan
│   │
│   ├── 3.2 Enrollment                       ─── Đăng ký phúc lợi
│   │   ├── Open Enrollment Setup            Kỳ đăng ký hàng năm: dates, eligible plans, reminders
│   │   ├── Employee Enrollment Portal       NV self-service: chọn plan, thêm dependents, xem cost
│   │   ├── Enrollment Dashboard             % hoàn thành, pending, overdue
│   │   └── Enrollment History               Lịch sử NV qua các năm
│   │
│   ├── 3.3 Life Events                      ─── Sự kiện cuộc sống
│   │   ├── Report Life Event                NV báo: kết hôn, sinh con, ly hôn, mất coverage
│   │   ├── Document Verification            Upload/xác minh giấy tờ
│   │   └── Mid-Year Enrollment              Window 30 ngày để thay đổi benefits
│   │
│   ├── 3.4 Dependents & Beneficiaries       ─── Người phụ thuộc & thụ hưởng
│   │   ├── Dependent Management             Vợ/chồng, con: thông tin, documents, age-out tracking
│   │   └── Beneficiary Designation          Chỉ định: primary %, contingent %
│   │
│   ├── 3.5 Claims & Reimbursement           ─── Yêu cầu bồi thường
│   │   ├── Submit Claim                     NV submit: medical, dental, vision, mental health
│   │   ├── Claims Review                    HR/Admin review & approve
│   │   └── Expense Reimbursement            Hoàn tiền: wellness, education, commuter, home office
│   │
│   └── 3.6 Carrier Integration              ─── Tích hợp nhà cung cấp BH
│       ├── Carrier Setup                    Cấu hình insurance carriers
│       ├── EDI 834 Export                   Generate enrollment file → carrier tự động
│       └── Premium Reconciliation           Đối soát phí BH giữa system vs carrier
│
├── 4. Recognition & Rewards                 ─── Ghi nhận & phần thưởng
│   ├── 4.1 Program Setup                    ─── Cấu hình (HR Admin)
│   │   ├── Event Types                      Loại ghi nhận: Peer (50-100đ), Manager (100-500đ), Milestone (500-2000đ)
│   │   ├── Point Rules                      Budget/tháng, expiration period, FIFO rules
│   │   └── Program Analytics                Participation rate, top givers/receivers, point utilization
│   │
│   ├── 4.2 Give Recognition                 ─── Trao ghi nhận (Employee/Manager)
│   │   ├── Send Recognition                 Ghi nhận peer/NV + message + điểm
│   │   ├── My Recognition Wall              Feed đã nhận & đã trao
│   │   └── Team Recognition                 Manager: tổng quan recognition trong team
│   │
│   ├── 4.3 Perk Catalog                     ─── Catalog phần thưởng (HR Admin)
│   │   ├── Browse Perks                     Danh mục: Gift cards, Experiences, Merchandise, Charitable
│   │   ├── Manage Catalog                   Thêm/sửa perks: point cost, inventory, taxable value
│   │   └── Perk Categories                  Quản lý danh mục
│   │
│   └── 4.4 Points & Redemption              ─── Điểm & đổi thưởng (Employee)
│       ├── My Points                        Số dư, lịch sử earned/spent/expired (FIFO)
│       ├── Redeem Points                    Đổi điểm lấy perk
│       └── Redemption Tracking              Trạng thái: PENDING → PROCESSING → DELIVERED
│
├── 5. Offer Management                      ─── Quản lý offer ứng viên
│   ├── 5.1 Templates                        ─── Template tái sử dụng
│   │   ├── Offer Template List              Danh sách templates
│   │   └── Create/Edit Template             Sections, branding, default components
│   │
│   ├── 5.2 Offer Packages                   ─── Gói offer cụ thể
│   │   ├── Create Offer Package             Tạo: base + bonus target + equity + benefits preview
│   │   ├── Offer Dashboard                  Danh sách: draft / sent / viewed / accepted / rejected
│   │   ├── Compensation Preview             Xem gross→net estimate (gọi PR DryRun API)
│   │   └── Send Offer                       Gửi link cho candidate
│   │
│   ├── 5.3 Acceptance & Negotiation         ─── Chấp nhận & đàm phán
│   │   ├── Candidate Portal                 Candidate xem offer, e-signature hoặc counter
│   │   ├── Counter-Offer Workflow           HR xem counter, negotiate, revise & resend
│   │   └── Offer Acceptance                 Tracking: timestamp, IP, signed PDF lưu trữ
│   │
│   └── 5.4 Reports                          ─── Báo cáo
│       ├── Acceptance Rate                  Tỷ lệ chấp nhận theo dept/grade/period
│       └── Time-to-Accept                   Thời gian trung bình sent → accepted
│
├── 6. Total Rewards Statement               ─── Báo cáo tổng đãi ngộ
│   ├── 6.1 Statement Configuration          ─── Cấu hình
│   │   ├── Statement Templates              Template: logo, sections, currency, language
│   │   ├── Section Setup                    Chọn sections: Cash, Benefits, Equity, SI, Recognition
│   │   └── Display Options                  Equity vested-only vs all, employer contribution only
│   │
│   ├── 6.2 Generation                       ─── Tạo statement
│   │   ├── Individual Statement             Tạo cho 1 NV (data from PR results + TR config)
│   │   ├── Batch Generation                 Tạo hàng loạt: by dept, grade, all employees
│   │   └── Preview                          Xem trước PDF
│   │
│   └── 6.3 Distribution                     ─── Phân phối
│       ├── Send via Email                   Gửi PDF (secure link)
│       ├── Employee Self-Service            NV xem/download trên portal
│       └── Distribution History             Lịch sử gửi
│
└── 7. Settings                              ─── Cài đặt TR module
    ├── 7.1 Deduction Configuration          ─── Khấu trừ (TR policy)
    │   ├── Deduction Types                  Loan repayment, Garnishment, Union dues...
    │   └── Deduction Priority               Thứ tự ưu tiên: statutory → voluntary
    │
    ├── 7.2 Taxable Bridge                   ─── Cầu nối TR → PR
    │   ├── Taxable Items                    Items cần chuyển sang Payroll (equity vest, perk redeem)
    │   └── Processing Status                PENDING → PROCESSED → PAID (monitoring)
    │
    ├── 7.3 Audit Log                        ─── Kiểm toán
    │   ├── Change History                   Mọi thay đổi compensation: who, when, before/after
    │   └── Pay Equity Report                Phát hiện chênh lệch lương bất hợp lý
    │
    └── 7.4 Integration                      ─── Tích hợp
        ├── PR Integration                   Data flow → Payroll: comp snapshot, bonus, taxable items
        ├── CO Integration                   Mapping: employee, job, grade, legal entity
        └── External Systems                 Stock admin, e-signature, survey providers
```

---

## Items Moved Out of TR (per Deep Analysis)

| Removed Menu Item | Now At | Reference |
|-------------------|:------:|:---------:|
| ~~Eligibility Rules~~ (was 3.1) | Core `eligibility.*` | Doc 05 |
| ~~Country Configuration~~ (was 7.1) | Core `common.country_config` | Doc 06 |
| ~~Holiday Calendar~~ (was 7.1) | Core `common.holiday_calendar` | Doc 06 |
| ~~Tax Withholding Elections~~ (was 7.3) | PR `pay_master` | Doc 07 |
| ~~SI Contribution Rates~~ (was 7.3) | PR `statutory_rule` | Doc 07 |
| ~~Compliance Dashboard~~ (was 7.5) | PR (statutory compliance) | Doc 07 |

---

## Menu by User Role

### HR Administrator
```
1. Compensation > Salary Basis, Pay Components, Grade, Pay Range
1.6 Compensation Cycle > Plan, Budget Allocation
2. Variable Pay > Bonus Plans, Equity Plans, Commission
3. Benefits > Plan Config, Enrollment Setup, Carrier Integration
7. Settings > Deductions, Taxable Bridge, Audit, Integration
```

### Compensation Manager
```
1.4 Pay Range > Setup, Compa-Ratio Analysis
1.6 Compensation Cycle > Plan, Budget Tracking, Reports
2.1 Bonus > Target Assignment, Calculation
6. Statement > Configuration, Batch Generation
```

### Manager / Team Lead
```
1.5 Employee Compensation > Team overview
1.6 Compensation Cycle > Manager Workspace, submit proposals
2.1 Bonus > View team calculations
4.2 Recognition > Send Recognition, Team Recognition
```

### Employee (Self-Service)
```
1.5 My Compensation > Overview, History
3.2 Benefits > My Enrollment, Life Events, Dependents, Claims
4.2 Recognition > Send Recognition, My Wall
4.4 Points > My Points, Redeem, Track
6.3 Statement > My Total Rewards Statement
```

### Recruiter
```
5. Offer Management > Templates, Create Offer, Send, Track
5.3 Acceptance > Candidate Portal, Counter-Offer
5.4 Reports > Acceptance Rate, Time-to-Accept
```

### Benefits Administrator
```
3.1 Plan Config > Plans, Options
3.2 Enrollment > Open Enrollment, Dashboard
3.3 Life Events > Review & verify
3.5 Claims > Review claims, Reimbursement
3.6 Carrier > Setup, EDI 834, Premium Reconciliation
```
