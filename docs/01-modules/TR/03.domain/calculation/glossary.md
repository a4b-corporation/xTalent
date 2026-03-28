# Glossary: Calculation Engine (BC-02)

> **Bounded Context**: BC-02 — Calculation Engine
> **Module**: Total Rewards / xTalent HCM
> **Ngày**: 2026-03-26

---

## Ubiquitous Language

### Entities & Aggregates

| Term | Definition | Vietnamese | Khác với |
|------|-----------|-----------|----------|
| `CalculationRule` | Quy tắc tính toán có versioning và effective dating — lưu formula/tỷ lệ dưới dạng formula_json. Mỗi thay đổi tạo version mới; version cũ preserved để tính lại kỳ lịch sử. | Quy tắc tính toán (có phiên bản) | Khác `ContributionConfig` (cấu hình SI/CPF cụ thể): CalculationRule là engine-level formula, ContributionConfig là country-level config |
| `ContributionConfig` | Cấu hình đóng góp bảo hiểm xã hội per country/LE — tỷ lệ employer/employee, căn cứ tính, cap. SCD Type 2. Ví dụ: VN BHXH employer=17.5%, employee=8%, cap=20× min wage zone | Cấu hình đóng góp bảo hiểm | Khác `CalculationRule` (formula chung): ContributionConfig là data-driven config, không phải formula |
| `ProrationConfig` | Cấu hình phương pháp tính lương theo ngày làm việc thực tế — per component per scope. Phương pháp: CALENDAR_DAYS (chia ngày dương lịch), WORKING_DAYS (chia ngày làm việc thực), FIXED_30 (luôn chia 30) | Cấu hình tính lương theo ngày | Khác `CalculationRule`: ProrationConfig là meta-config chọn phương pháp, không phải formula |
| `MinWageConfig` | Bảng lương tối thiểu theo vùng/quốc gia với effective dating (SCD Type 2). Vietnam: 4 vùng lương (I–IV) xác định bởi `workplace_location` của WorkingRelationship. | Bảng lương tối thiểu | Khác `SalaryBasis`: MinWageConfig là regulatory floor, SalaryBasis là enterprise structure |
| `FxRateRecord` | Tỷ giá hàng ngày từ external provider (OANDA, Reuters, hoặc manual override). Archived — không update, chỉ insert. Alert nếu biến động > 5%. | Bản ghi tỷ giá | Khác `currency` table (chỉ là metadata); FxRateRecord là operational rate với history |

### Value Objects

| Term | Definition | Vietnamese | Ghi chú |
|------|-----------|-----------|---------|
| `FormulaJson` | Cấu trúc JSON mô tả công thức tính toán — ví dụ: `{"type": "PERCENTAGE", "base": "GROSS_SALARY", "rate": 0.08}`. Engine parse và execute tại runtime. | Công thức dạng JSON | Platform không hardcode công thức — mọi logic đều qua FormulaJson |
| `CalculationPeriod` | Kỳ tính toán = {year: int, month: int} — ví dụ: "2026-03". Mọi tính toán đều scope theo period. | Kỳ tính toán | Luôn kèm period — không có "tính ngoài kỳ" |
| `ProrationFactor` | Kết quả tính proration = ActualDays / TotalDays. Ví dụ: hired ngày 15/3 → 17/31 = 0.548 | Hệ số tính theo ngày | Phụ thuộc ProrationConfig để biết TotalDays là gì |
| `ContributionAmount` | {employee_share: decimal, employer_share: decimal, currency: ISO4217, period: string, is_capped: bool} | Số tiền đóng bảo hiểm | is_capped = true khi salary > cap threshold |
| `RuleVersion` | {version_number: int, effective_start: date, effective_end: date, is_current: bool} — metadata của một calculation rule version | Phiên bản quy tắc | Khi cần tính lại kỳ lịch sử, dùng version có effective_period overlap với period đó |
| `FxDelta` | Phần trăm thay đổi tỷ giá so ngày hôm trước. > 5% trigger FxDeltaAlerted và configurable workflow | Biến động tỷ giá | Configurable threshold; default = 5% |

### Commands

| Command | Actor | Definition | Vietnamese |
|---------|-------|-----------|-----------|
| `CreateCalculationRule` | HR Admin / Tax Admin | Tạo quy tắc mới với formula_json và effective date | Tạo quy tắc tính toán |
| `VersionCalculationRule` | HR Admin | Cập nhật quy tắc — tạo version mới, giữ version cũ | Phiên bản hóa quy tắc |
| `ConfigureContribution` | HR Admin / Payroll Admin | Cấu hình tỷ lệ SI/CPF/BPJS cho country/LE | Cấu hình đóng góp bảo hiểm |
| `SetProrationMethod` | HR Admin | Chọn phương pháp proration per component per scope | Đặt phương pháp tính ngày |
| `UpdateMinWage` | Tax Admin / HR Admin | Cập nhật bảng lương tối thiểu khi nhà nước thay đổi | Cập nhật lương tối thiểu |
| `UpdateFxRate` | System (daily) / Finance | Cập nhật tỷ giá mới; lưu archive | Cập nhật tỷ giá |
| `OverrideFxRate` | Finance Approver | Ghi đè tỷ giá tự động với manual rate + justification | Ghi đè tỷ giá thủ công |
| `ExecuteProration` | System | Tính proration factor cho Worker trong period (called by BC-01) | Thực thi tính lương theo ngày |
| `ExecuteSICalculation` | System | Tính BHXH/BHYT/BHTN cho Worker trong period | Thực thi tính bảo hiểm xã hội |

### Domain Events

| Event | Definition | Vietnamese | Trigger |
|-------|-----------|-----------|---------|
| `CalculationRuleVersioned` | Version mới của calculation rule được tạo, version cũ đóng lại | Quy tắc tính toán được phiên bản hóa | VersionCalculationRule command |
| `SIContributionCalculated` | BHXH/BHYT/BHTN amounts tính xong cho Worker trong period | Đã tính đóng góp bảo hiểm xã hội | Payroll run trigger |
| `SICapApplied` | Salary vượt cap (20× min wage zone) → contribution capped | Đã áp dụng trần đóng bảo hiểm | SIContributionCalculated khi salary > cap |
| `SalaryProrated` | Lương được tính theo ngày làm việc thực tế | Lương đã được tính theo ngày | Mid-period hire/termination/change |
| `FxRateUpdated` | Tỷ giá mới được lưu (daily); previous rate archived | Tỷ giá được cập nhật | Daily sync hoặc manual override |
| `FxDeltaAlerted` | Biến động tỷ giá vượt ngưỡng cấu hình | Cảnh báo biến động tỷ giá | FxRateUpdated với delta > threshold |
| `CalculationCompleted` | Tất cả components cho Worker trong period đã tính xong | Tính toán hoàn tất | All component engines report done |

### Business Rules

| Rule ID | Rule | Vietnamese | Hard/Soft |
|---------|------|-----------|-----------|
| BR-K01 | Proration formula: ProrationFactor = ActualDays / TotalDays; TotalDays xác định bởi ProrationConfig | Công thức tính lương theo ngày | Configurable method, fixed formula |
| BR-K02 | SI cap Vietnam: contribution = min(salary, 20× MinWage(workplace_zone)) | Trần đóng BHXH Vietnam | Hard (statutory) |
| BR-K03 | SI cap timing change: khi WorkingRelationship.workplace_location thay đổi, cap mới áp dụng từ tháng TIẾP THEO | Thời điểm áp dụng cap mới | Hard (statutory, confirmed) |
| BR-K04 | CalculationRule versioning: không được UPDATE version hiện tại — chỉ INSERT version mới với effective_start_date | Bất biến version quy tắc | Hard |
| BR-K05 | FX rate override phải có Finance Approver và ghi lý do — không thể silent override | Kiểm soát ghi đè tỷ giá | Hard |
| BR-K06 | Khi tính lại kỳ lịch sử, PHẢI dùng CalculationRule version có effective_period overlap với kỳ đó — không dùng rule hiện tại | Tính toán lịch sử phải đúng rule của thời điểm đó | Hard |
| BR-K07 | Plugin interface phải implement `CountryContributionEngine` với contract cố định — HR SME configure data, không deploy code | Plugin không deploy code | Hard (architecture) |

### Plugin Architecture

```
CountryContributionEngine (Interface)
├── VietnamSIEngine (Plugin — implements for VN)
│   ├── Reads ContributionConfig for VN
│   ├── Applies 4-zone MinWageConfig
│   └── Emits SIContributionCalculated
├── SingaporeCPFEngine (Plugin — Phase 2)
├── MalaysiaEPFEngine (Plugin — Phase 2)
├── IndonesiaBPJSEngine (Plugin — Phase 2)
└── PhilippinesSSSEngine (Plugin — Phase 2)

ProrationEngine (Interface)
├── CalendarDaysProration
├── WorkingDaysProration
└── Fixed30DaysProration

FormulaEngine (Interface)
└── JsonFormulaEvaluator (interprets formula_json at runtime)
```

**Nguyên tắc**: HR SME cấu hình tỷ lệ, thời điểm hiệu lực qua Admin UI. Không cần code deployment để thay đổi business rule.

### Config Scope Resolution (cho Calculation Engine)

```
Khi lookup CalculationRule cho Worker:
1. Tìm rule có config_scope_id khớp với BU của Worker (priority=30)
2. Nếu không có → tìm theo LE (priority=20)
3. Nếu không có → tìm theo Country (priority=10)
4. Nếu không có → dùng GLOBAL rule (priority=0)
5. Nếu không có → lỗi: "No calculation rule found for scope"
```

### Integration Points

| Integration | Direction | Pattern | Ghi chú |
|-------------|-----------|---------|---------|
| BC-01 Compensation | Inbound call | Sync (CalculationEnginePort) | Invoke proration, min wage check |
| BC-03 Variable Pay | Inbound call | Sync | Invoke formula engine, FX conversion |
| BC-04 Benefits | Inbound call | Sync | Deduction amount calculation |
| BC-06 Offer Mgmt | Inbound call | Sync | Min wage validation |
| FX Rate Providers | Outbound (external) | REST API (OANDA/Reuters) | Daily sync; manual fallback |
| All BCs | Outbound event | Kafka | Publish CalculationCompleted per period |

---

*Glossary: Calculation Engine (BC-02) — Total Rewards / xTalent HCM*
*2026-03-26*
