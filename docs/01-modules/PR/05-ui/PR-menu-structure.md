# Payroll (PR) — Menu Structure

**Module**: Payroll (PR)  
**Version**: 1.0 (aligned with deep analysis)  
**Ngày**: 2026-03-17

---

## Tổng quan

Module Payroll sở hữu **HOW to calculate** — engine tính lương, statutory compliance, execution pipeline, bank/GL output. Sau deep analysis, PR tiếp nhận thêm các chức năng:

| Chức năng mới về PR | Từ module | Lý do (ref) |
|---------------------|:---------:|-------------|
| Calculation execution | TR (re-scope) | PR owns Drools engine + 5-stage pipeline (Doc 07) |
| Statutory rules (tax/SI/OT) | TR (re-scope) | Calculation logic = engine concern (Doc 07) |
| Tax calculation cache | TR (move) | Engine optimization concern (Doc 07) |
| DryRun/Preview API | New | TR gọi PR DryRun cho Offer/Statement (Doc 07) |
| Input staging layer | New | Validation trước khi data vào pay_run (Doc 04) |

PR đọc country config + holiday calendar từ **Core** (`common.country_config`, `common.holiday_calendar`).

---

## Menu Tree

```
Payroll
│
├── 1. Pay Element Setup                     ─── Cấu hình thành phần lương
│   ├── 1.1 Pay Elements                     ─── Định nghĩa element
│   │   ├── Element List                     Danh sách elements (enriched): BASE, ALLOWANCE, BONUS, OT,
│   │   │                                    DEDUCTION, EMPLOYER_CONTRIBUTION, TAX, INFORMATIONAL
│   │   ├── Create/Edit Element              Tạo/sửa: classification, sub_type, tax_treatment,
│   │   │                                    proration_method, si_basis, calculation_method, frequency
│   │   └── Element Import                   Import elements từ template hoặc TR component mapping
│   │
│   ├── 1.2 Pay Formulas                     ─── Công thức tính
│   │   ├── Formula List                     Danh sách formulas (Drools DSL syntax)
│   │   ├── Formula Editor                   Editor: Business DSL — vd: kpiScore * baseAmount * 1.5
│   │   ├── Formula Testing                  Test formula với sample data trước khi apply
│   │   └── Dependency Graph                 Visualize dependency giữa formulas (circular detection)
│   │
│   └── 1.3 Balance Definitions              ─── Định nghĩa balance
│       ├── Balance Types                    YTD, QTD, MTD, PTD, Lifetime
│       └── Balance Rules                    Cấu hình reset period, accumulation rules
│
├── 2. Payroll Configuration                 ─── Thiết lập payroll
│   ├── 2.1 Pay Frequency & Calendar         ─── Tần suất & lịch trả lương
│   │   ├── Pay Frequencies                  Monthly, Bi-Weekly, Weekly, Semi-Monthly
│   │   ├── Pay Calendar                     Lịch kỳ trả lương: period start/end, payment date, cut-off
│   │   └── Period Management                Mở/đóng pay period, lock periods
│   │
│   ├── 2.2 Pay Groups                       ─── Nhóm trả lương
│   │   ├── Pay Group List                   Nhóm NV cùng frequency + calendar + legal entity
│   │   ├── Create/Edit Group                Tạo: frequency, calendar, legal entity, default profile
│   │   └── Employee Assignment              Gắn NV vào pay group
│   │
│   ├── 2.3 Pay Profiles                     ─── Bundle policy
│   │   ├── Profile List                     Danh sách profiles: VN Monthly Standard, US Bi-Weekly...
│   │   ├── Create/Edit Profile              Tạo: gắn elements, execution order, mandatory flags
│   │   ├── Element Mapping                  Map elements vào profile: order, mandatory, default values
│   │   └── Rule Binding                     Gắn statutory rules áp dụng cho profile
│   │
│   └── 2.4 Validation Rules                 ─── Quy tắc kiểm tra
│       ├── Validation Rule List             Danh sách rules: range check, consistency, compliance
│       └── Create/Edit Rule                 Tạo rule: condition, severity (ERROR/WARNING), message
│
├── 3. Statutory & Compliance                ─── Luật định & tuân thủ
│   ├── 3.1 Statutory Rules                  ─── Quy tắc luật định
│   │   ├── Tax Tables                       Bảng thuế TNCN progressive brackets (per country)
│   │   ├── SI Rate Tables                   Tỷ lệ BHXH/BHYT/BHTN (employee + employer, per country)
│   │   ├── OT Multiplier Rules              Hệ số OT: Weekday 150%, Weekend 200%, Holiday 300%
│   │   ├── Rounding Rules                   Quy tắc làm tròn (per country, per element)
│   │   └── Rule Version History             SCD-2 versioning: legal_reference, valid_from/to
│   │
│   │   Note: Country config & holiday calendar đọc từ Core module
│   │         (common.country_config, common.holiday_calendar)
│   │
│   ├── 3.2 Tax Withholding                  ─── Khấu trừ thuế
│   │   ├── Employee Tax Elections           NV khai báo số người phụ thuộc, mức giảm trừ
│   │   └── Tax Calculation Cache            Cache kết quả tax calculation (moved from TR)
│   │
│   └── 3.3 Compliance Reports               ─── Báo cáo tuân thủ
│       ├── Tax Authority Reports            Quyết toán thuế TNCN, W-2, 1099 (per country template)
│       ├── SI Reports                       Báo cáo BHXH/BHYT/BHTN: monthly, quarterly filings
│       └── Compliance Dashboard             Tổng quan tuân thủ: missing tax elections, pending filings
│
├── 4. Input & Staging                       ─── Dữ liệu đầu vào
│   ├── 4.1 Input Staging                    ─── Staging layer (validation)
│   │   ├── Staged Records                   Danh sách records chờ validate: source, status, errors
│   │   ├── Validation Dashboard             Tổng quan: valid, warning, error counts per source
│   │   └── Error Resolution                 Xử lý lỗi: fix data, re-validate, reject
│   │
│   ├── 4.2 Compensation Input               ─── Dữ liệu từ TR
│   │   ├── Compensation Snapshot            Snapshot lương NV: components, amounts (from TR API)
│   │   ├── Bonus Allocations                Thưởng đã duyệt cần chi trả
│   │   └── Taxable Items                    Items chịu thuế: equity vest, perk redeem (from TR bridge)
│   │
│   ├── 4.3 Time Input                       ─── Dữ liệu từ TA
│   │   ├── Attendance Data                  Giờ làm, ngày công, late/early (from TA API)
│   │   ├── OT Hours                         Giờ OT đã duyệt: weekday, weekend, holiday
│   │   └── Leave Data                       Ngày nghỉ: paid, unpaid, sick (deduction impact)
│   │
│   ├── 4.4 Benefit Deductions               ─── Khấu trừ từ TR
│   │   ├── Benefit Premiums                 Phí BH khấu trừ hàng tháng (from enrollment)
│   │   └── Loan/Garnishment                 Khấu trừ vay, execute court order
│   │
│   └── 4.5 Manual Adjustments               ─── Điều chỉnh thủ công
│       ├── One-Time Payments                Chi trả 1 lần: sign-on bonus, severance, ad-hoc
│       ├── One-Time Deductions              Khấu trừ 1 lần: advance recovery, equipment
│       └── Retroactive Adjustments          Điều chỉnh hồi tố: recalc for past periods
│
├── 5. Payroll Processing                    ─── Xử lý bảng lương
│   ├── 5.1 Payroll Run                      ─── Chạy lương
│   │   ├── Start Payroll Run                Tạo batch: chọn pay group, period, run type (Regular/Supplemental/Off-cycle)
│   │   ├── Run Dashboard                    Theo dõi progress: Pre-validation → Gross → SI → Tax → Net
│   │   ├── Run Status                       Status: CREATED → CALCULATING → COMPLETED → APPROVED → FINALIZED
│   │   └── Error Handling                   Xem errors/warnings, fix & retry, skip employees
│   │
│   ├── 5.2 Simulation & Preview             ─── Mô phỏng
│   │   ├── DryRun Mode                      Chạy mô phỏng: full pipeline, không booking, review results
│   │   ├── What-If Analysis                 Thay đổi inputs → xem impact on net (before run)
│   │   └── Preview API (for TR)             API endpoint cho TR Offer/Statement: gross→net estimate
│   │
│   ├── 5.3 Approval & Finalization          ─── Phê duyệt
│   │   ├── Result Review                    HR/Finance review payroll results trước khi approve
│   │   ├── Exception Review                 Xem outliers: salary change > X%, negative net, new hires
│   │   ├── Approve Run                      Phê duyệt payroll batch (multi-level nếu cần)
│   │   └── Finalize & Lock                  Finalize: lock period, no more changes
│   │
│   ├── 5.4 Retroactive Processing           ─── Hồi tố
│   │   ├── Retro Calculation                Tính retro: delta = new result − original result
│   │   ├── Retro Review                     Xem retro deltas: original vs revised vs difference
│   │   └── Retro Payout                     Approve retro → include in next pay run
│   │
│   └── 5.5 Calculation Log                  ─── Trace tính toán
│       ├── Calculation Trace                Step-by-step trace: mỗi element qua từng stage
│       └── Audit Trail                      Who ran, when, inputs → outputs (immutable)
│
├── 6. Payslips & Output                     ─── Phiếu lương & đầu ra
│   ├── 6.1 Payslips                         ─── Phiếu lương
│   │   ├── Payslip Templates                Setup template: layout, sections, branding, language
│   │   ├── Generate Payslips                Tạo payslips: batch hoặc individual
│   │   ├── Employee Payslip Portal          NV xem/download payslip (self-service)
│   │   └── Payslip History                  Lịch sử payslip qua các kỳ
│   │
│   ├── 6.2 Bank Payments                    ─── Thanh toán ngân hàng
│   │   ├── Bank Templates                   Cấu hình file format per bank (ACH, SWIFT, VN bank formats)
│   │   ├── Payment Batch                    Tạo payment batch: group by bank, currency
│   │   ├── Payment Lines                    Chi tiết: employee, account, amount, status
│   │   ├── Generate Bank File               Xuất file gửi bank
│   │   └── Payment Tracking                 Theo dõi: PENDING → SUBMITTED → PROCESSED → CONFIRMED
│   │
│   ├── 6.3 GL & Costing                     ─── Kế toán
│   │   ├── GL Mapping                       Map element → GL account code
│   │   ├── Costing Rules                    Phân bổ cost → cost centers (allocation %)
│   │   ├── GL Journal Entries               Tạo bút toán kế toán từ payroll results
│   │   └── Costing Report                   Báo cáo phân bổ chi phí theo dept/project/cost center
│   │
│   └── 6.4 Tax Reports                      ─── Báo cáo thuế
│       ├── Tax Report Templates             Template per country: W-2, 1099, VN PIT report
│       ├── Generate Tax Reports             Tạo reports: monthly, quarterly, annual
│       └── Filing Status                    Theo dõi: DRAFT → GENERATED → FILED → ACKNOWLEDGED
│
├── 7. Reports & Analytics                   ─── Báo cáo
│   ├── 7.1 Operational Reports              ─── Báo cáo vận hành
│   │   ├── Payroll Summary                  Tổng chi lương: by group, department, legal entity
│   │   ├── Variance Report                  So sánh kỳ này vs kỳ trước: delta analysis
│   │   ├── Headcount & Cost                 Headcount + total cost + avg salary per dept
│   │   └── Year-End Summary                 Tổng kết năm: total paid, total tax, total SI
│   │
│   ├── 7.2 Balance Reports                  ─── Báo cáo balance
│   │   ├── YTD Balances                     Year-to-date: per employee, per element
│   │   ├── MTD Summary                      Month-to-date tổng hợp
│   │   └── Balance Reconciliation           Đối soát balance giữa runs
│   │
│   └── 7.3 Analytics                        ─── Phân tích
│       ├── Labor Cost Analysis              Phân tích chi phí nhân sự: trend, by category
│       ├── Tax Liability Analysis           Phân tích nghĩa vụ thuế: forecast vs actual
│       └── Custom Report Builder            Drag-drop: chọn dimensions, filters, period range
│
└── 8. Settings & Administration             ─── Cài đặt
    ├── 8.1 Import/Export                    ─── Nhập xuất dữ liệu
    │   ├── Import Jobs                      Import data: employees, elements, adjustments (batch)
    │   ├── Export Configuration             Cấu hình export templates
    │   └── Generated Files                  Quản lý files đã tạo: payslips, bank, GL, tax
    │
    ├── 8.2 Interface Configuration          ─── Cấu hình giao tiếp
    │   ├── Interface Definitions            Định nghĩa interfaces: inbound/outbound, format, schedule
    │   └── Interface Mappings               Field mapping: source ↔ target cho mỗi interface
    │
    ├── 8.3 Audit                            ─── Kiểm toán
    │   ├── Audit Log                        Mọi thay đổi config + processing: who, when, what
    │   └── Data Access Log                  Tracking: ai xem payslip/data nhạy cảm
    │
    └── 8.4 Integration                      ─── Tích hợp
        ├── TR Integration                   Nhận từ TR: comp snapshot, bonus, taxable items, benefit premiums
        ├── TA Integration                   Nhận từ TA: attendance, OT hours, leave days
        ├── CO Integration                   Nhận từ Core: employee, assignment, legal entity, country config
        ├── Finance Integration              Gửi tới Finance: GL entries, costing
        └── API Management                   API keys, rate limits, webhook config
```

---

## Items PR Now Owns (post Deep Analysis)

| Responsibility | Before | After | Reference |
|---------------|:------:|:-----:|:---------:|
| Tax brackets, SI rates | Shared TR/PR | **PR only** | Doc 07 §2.1 |
| OT multiplier lookup | TR `calculation_rule_def` | **PR** `statutory_rule` | Doc 07 §2.3 |
| Tax calculation cache | TR `comp_core` | **PR** `pay_master` | Doc 07 §2.4 |
| Execution pipeline config | TR `basis_calculation_rule` | **PR** `pay_profile` | Doc 07 §2.2 |
| DryRun/Preview API | None | **PR** new endpoint | Doc 07 §4.2 |
| Input staging | None | **PR** `pay_staging.*` | Doc 04 §3.8 |
| Tax withholding elections | Unclear | **PR** `pay_master` | Doc 07 |

---

## Menu by User Role

### Payroll Administrator
```
1. Pay Element Setup > Elements, Formulas, Balances
2. Payroll Configuration > Frequencies, Pay Groups, Profiles, Validation
3. Statutory > Tax Tables, SI Rates, OT Rules, Tax Withholding
4. Input > Staging, Manual Adjustments, Review errors
5. Processing > Start Run, Dashboard, Approval, Finalize, Retro
6. Output > Payslips, Bank Payments, GL, Tax Reports
7. Reports > All
8. Settings > All
```

### Finance/Accounting
```
5.3 Processing > Result Review, Exception Review, Approve
6.2 Bank Payments > Payment Batch, Generate File, Tracking
6.3 GL & Costing > GL Mapping, Costing Rules, Journal Entries
6.4 Tax Reports > Generate, Filing Status
7. Reports > Payroll Summary, Variance, Year-End, Cost Analysis
```

### HR Manager
```
4.5 Manual Adjustments > One-Time Payments/Deductions
5.2 Simulation > DryRun, What-If
5.3 Approval > Review & Approve
7.1 Reports > Payroll Summary, Headcount & Cost
```

### Employee (Self-Service)
```
3.2 Tax Withholding > My Tax Elections (dependents, deductions)
6.1 Payslips > My Payslip Portal, History
```

### System Administrator
```
1.2 Formulas > Formula Editor, Testing, Dependency Graph
8. Settings > Import/Export, Interface Config, Audit, API Management
8.4 Integration > TR, TA, CO, Finance connections
```
