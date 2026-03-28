# Glossary: Compensation Management (BC-01)

> **Bounded Context**: BC-01 — Compensation Management
> **Module**: Total Rewards / xTalent HCM
> **Ngày**: 2026-03-26

---

## Ubiquitous Language

### Entities & Aggregates

| Term | Definition | Vietnamese | Khác với |
|------|-----------|-----------|----------|
| `SalaryBasis` | Template định nghĩa cấu trúc lương cho một loại Working Relationship — bao gồm tần suất trả lương (HOURLY/MONTHLY/ANNUAL), tiền tệ mặc định, và danh sách pay components được phép. Scoped per country/LE hoặc global. | Cơ sở tính lương | Khác "PayStructure" (generic): SalaryBasis là template tái sử dụng, không gắn với Worker cụ thể |
| `PayComponentDef` | Định nghĩa một loại thành phần lương có thể tái sử dụng — ví dụ: "Lương cơ bản", "Phụ cấp điện thoại", "Phụ cấp xăng xe". Chứa quy tắc tính thuế, proration method, và có thể có formula_json đơn giản. | Định nghĩa thành phần lương | Khác `PayComponentValue` (giá trị thực tế của component trên SalaryRecord) |
| `SalaryRecord` | Bản ghi lương của một Worker tại một khoảng thời gian cụ thể — SCD Type 2: mỗi thay đổi tạo bản ghi mới, bản ghi cũ đóng lại (effective_end_date). Là nguồn sự thật duy nhất về lương của Worker. | Bản ghi lương | Khác `Payslip` (tài liệu trả lương thực tế sau khi deductions); SalaryRecord là gross amount |
| `PayRange` | Khung lương (min/mid/max) cho một Grade tại một scope cụ thể (Country/LE/BU). SCD Type 2 — thay đổi theo thị trường hoặc quyết định chiến lược. Dùng để tính compa-ratio. | Khung lương | Khác `GradeStep` (bước lương trong thang lương có cấu trúc) |
| `CompensationCycle` | Chu kỳ xem xét và điều chỉnh lương có vòng đời rõ ràng: DRAFT → OPEN → REVIEW → APPROVED → CLOSED. Gắn với một ngân sách và danh sách Workers eligible. | Chu kỳ điều chỉnh lương | Khác `PayrollCycle` (chu kỳ trả lương); CompensationCycle là chu kỳ review thay đổi, không phải trả lương |
| `CompensationProposal` | Đề xuất thay đổi lương của một Worker trong một CompensationCycle — bao gồm mức đề xuất, loại thay đổi (merit/promotion/market adj), và lý do. Qua approval workflow trước khi effective. | Đề xuất thay đổi lương | Khác `OfferRecord` (dùng cho candidate, không phải Worker hiện tại) |
| `DeductionRecord` | Khoản khấu trừ định kỳ của một Worker — loan, garnishment (lệnh tòa), salary advance, voluntary contributions. Có lịch khấu trừ, số tiền, và priority ordering. | Bản ghi khấu trừ | Khác `BenefitDeduction` (khấu trừ từ BenefitEnrollment, managed by BC-04) |

### Value Objects

| Term | Definition | Vietnamese | Ghi chú |
|------|-----------|-----------|---------|
| `SalaryAmount` | Giá trị lương = {amount: decimal, currency: ISO4217}. Immutable once set; thay đổi tạo SalaryRecord mới | Mức lương | Luôn đi kèm currency — không tồn tại standalone amount |
| `EffectivePeriod` | {effective_start_date, effective_end_date} — khoảng thời gian hiệu lực. effective_end_date = NULL khi là bản ghi current | Kỳ hiệu lực | Dùng trong SCD Type 2 pattern |
| `CompaRatio` | ActualSalary / MidpointSalary × 100. < 80 = dưới tầm, 80–120 = trong range, > 120 = trên tầm | Tỷ lệ compa | Tính tại thời điểm salary change hoặc pay range update |
| `BudgetUtilization` | Phần trăm ngân sách cycle đã dùng = ProposedTotal / CycleBudget × 100 | Mức sử dụng ngân sách | Real-time update khi proposal submit/approve/reject |
| `WageZone` | Một trong 4 vùng lương Vietnam (Zone I–IV) hoặc country-specific zone. Xác định từ `workplace_location` của WorkingRelationship | Vùng lương | Đây là lookup, không phải entity — owned by BC-02 (MinWageConfig) |

### Commands

| Command | Actor | Definition | Vietnamese |
|---------|-------|-----------|-----------|
| `CreateSalaryBasis` | Compensation Admin | Tạo mới salary basis template | Tạo cơ sở lương |
| `OpenCompensationCycle` | Compensation Admin | Mở cycle với budget và danh sách eligible workers | Mở chu kỳ điều chỉnh lương |
| `SubmitMeritRecommendation` | People Manager | Đề xuất mức lương mới trong cycle đang OPEN | Đệ trình đề xuất điều chỉnh |
| `ApproveCompensation` | Budget Approver / Director / VP | Phê duyệt đề xuất theo ngưỡng quyền hạn | Phê duyệt thay đổi lương |
| `RejectCompensation` | Approver | Từ chối đề xuất với lý do | Từ chối thay đổi lương |
| `CloseCompensationCycle` | Compensation Admin | Kết thúc cycle; lock tất cả proposals | Đóng chu kỳ điều chỉnh |
| `ScheduleSalaryChange` | System | Tạo pending salary change với effective date tương lai | Lên lịch thay đổi lương |
| `ActivateSalaryChange` | System (Cron) | Kích hoạt thay đổi khi effective_date = today | Kích hoạt thay đổi lương |
| `SetupDeduction` | HR Admin | Tạo deduction record với lịch trả | Thiết lập khấu trừ |
| `ElectVoluntaryDeduction` | Worker | Tự khai báo khấu trừ tự nguyện | Đăng ký khấu trừ tự nguyện |

### Domain Events

| Event | Definition | Vietnamese | Trigger |
|-------|-----------|-----------|---------|
| `CompensationCycleOpened` | Cycle đã được mở, managers có thể submit proposals | Chu kỳ điều chỉnh đã mở | OpenCompensationCycle command |
| `MeritRecommendationSubmitted` | Proposal đã được submit; budget_remaining tạm giảm | Đề xuất đã được đệ trình | SubmitMeritRecommendation command |
| `CompensationApproved` | Salary change được approve; scheduled for effective date | Thay đổi lương đã được phê duyệt | ApproveCompensation command |
| `CompensationRejected` | Proposal bị reject; budget_remaining hoàn lại | Thay đổi lương bị từ chối | RejectCompensation command |
| `SalaryEffectiveDateReached` | Salary change kích hoạt; payroll bridge triggered | Ngày hiệu lực lương đã đến | System cron job |
| `SalaryHistoryArchived` | SCD Type 2 snapshot được ghi nhận | Lịch sử lương đã lưu trữ | SalaryEffectiveDateReached |
| `MinimumWageViolated` | Mức lương đề xuất thấp hơn minimum wage của vùng | Vi phạm lương tối thiểu | Hard validation tại create/update |
| `PayEquityGapDetected` | Phân tích pay equity phát hiện gap > threshold | Phát hiện khoảng cách lương (USP) | Scheduled analysis |
| `BudgetVarianceAlerted` | Budget remaining < 5% hoặc projected exceed | Cảnh báo vượt ngân sách | Real-time monitoring |

### Business Rules

| Rule ID | Rule | Vietnamese | Hard/Soft |
|---------|------|-----------|-----------|
| BR-C01 | Minimum wage validation là hard block — không có exception without explicit workflow | Lương không được thấp hơn mức tối thiểu vùng | Hard |
| BR-C02 | Approval thresholds: <5% tự động; 5–10% cần Director; >10% cần VP — configurable per enterprise | Ngưỡng phê duyệt theo % tăng lương | Soft/Configurable |
| BR-C03 | SalaryRecord phải có SCD Type 2 — không được UPDATE, chỉ được INSERT + close previous | Lịch sử lương bất biến (SCD Type 2) | Hard |
| BR-C04 | PayRange resolution: most-specific scope wins (BU > LE > Country > Global) | Phạm vi áp dụng cụ thể nhất | Hard |
| BR-C05 | budget_remaining được cập nhật real-time khi proposal submit (tạm trừ) và restore nếu reject | Quản lý ngân sách real-time | Hard |
| BR-C06 | CompensationProposal chỉ có thể submit khi Cycle ở trạng thái OPEN | Ràng buộc lifecycle cycle | Hard |
| BR-C07 | DeductionRecord priority ordering: Garnishment (1) > Loan (2) > SalaryAdvance (3) > Voluntary (4) — configurable per enterprise | Thứ tự ưu tiên khấu trừ | Soft/Configurable |

### Lifecycle States

#### CompensationCycle States
```
DRAFT → OPEN → REVIEW → APPROVED → CLOSED
         │                           │
         └──── (Admin cancel) ───────┘
```

#### CompensationProposal States
```
DRAFT → PENDING_APPROVAL → APPROVED → SCHEDULED → EFFECTIVE
                        └→ REJECTED
                        └→ WITHDRAWN (by Manager)
```

#### DeductionRecord States
```
ACTIVE → PAUSED → COMPLETED
      └→ CANCELLED
```

### Integration Points

| Integration | Direction | Pattern | Ghi chú |
|-------------|-----------|---------|---------|
| CO Module — Worker | Inbound | Kafka subscribe | Consume WorkerCreated, WorkingRelationshipChanged |
| CO Module — Grade | Inbound | Kafka subscribe | Consume GradeChanged; update PayRange reference |
| BC-02 Calculation | Outbound call | Sync API (CalculationEnginePort) | Invoke proration, FX conversion |
| BC-08 Taxable Bridge | Outbound event | Kafka publish | SalaryChanged, DeductionCreated |
| Payroll Module | Via BC-08 | Kafka (via Bridge) | Indirect through Taxable Bridge |

---

*Glossary: Compensation Management (BC-01) — Total Rewards / xTalent HCM*
*2026-03-26*
