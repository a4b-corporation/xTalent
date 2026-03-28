# Glossary: Variable Pay (BC-03)

> **Bounded Context**: BC-03 — Variable Pay
> **Module**: Total Rewards / xTalent HCM
> **Ngày**: 2026-03-26

---

## Ubiquitous Language

### Entities & Aggregates

| Term | Definition | Vietnamese | Khác với |
|------|-----------|-----------|----------|
| `BonusPlan` | Kế hoạch thưởng định kỳ — định nghĩa eligible population, formula/tỷ lệ tính thưởng, vesting schedule, và approval workflow. Template tái sử dụng; scoped per country/LE/BU. | Kế hoạch thưởng | Khác `BonusStatement` (kết quả tính thưởng thực tế cho Worker cụ thể) |
| `BonusStatement` | Kết quả tính thưởng của một Worker trong một kỳ — amount, currency, performance modifier, trạng thái phê duyệt, và lịch chi trả. Immutable sau khi PAID. | Bảng tính thưởng | Khác `BonusPlan` (template); BonusStatement là bản ghi thực tế per Worker per period |
| `CommissionPlan` | Kế hoạch hoa hồng — định nghĩa quota, tiers (slab/tiered/flat), accelerator khi vượt quota, và territory mapping. Thường annual hoặc quarterly. | Kế hoạch hoa hồng | Khác `CommissionStatement` (tính toán hàng tháng); CommissionPlan là thiết kế, không phải kết quả |
| `CommissionStatement` | Bản tính hoa hồng tháng của một Worker — doanh số đạt được, tier áp dụng, amount tính được trước và sau accelerator, trạng thái. Real-time cập nhật khi SalesTransaction sync. | Bảng tính hoa hồng | Khác `BonusStatement` (bonus theo kỳ lớn hơn); CommissionStatement là tháng + real-time |
| `SalesTransaction` | Giao dịch bán hàng từ CRM — deal closed, amount, currency, ngày close, Worker (owner). Imported via CRM integration. Immutable sau khi synced. | Giao dịch bán hàng | Nguồn dữ liệu từ CRM; không tạo trong xTalent — chỉ import |
| `LongTermIncentive` | Kế hoạch đãi ngộ dài hạn — ESOP, RSU, phantom stock. Có vesting schedule (cliff + graded). Khi vest → TaxableItem được tạo qua Taxable Bridge. | Đãi ngộ dài hạn | Khác `BonusPlan` (thưởng ngắn hạn); LTI có vesting schedule và equity nature |
| `VestingSchedule` | Lịch vesting của LTI — {total_grant, cliff_months, vesting_period_months, vesting_type: CLIFF/GRADED}. Ví dụ: 48-month graded, 12-month cliff = 25% sau 12 tháng, mỗi tháng sau +1/48. | Lịch vesting | Owned by LongTermIncentive; không tồn tại độc lập |

### Value Objects

| Term | Definition | Vietnamese | Ghi chú |
|------|-----------|-----------|---------|
| `QuotaAttainment` | % đạt quota = ActualSales / QuotaTarget × 100. Xác định tier và accelerator cho CommissionPlan. | Tỷ lệ đạt quota | Real-time recalculate khi SalesTransaction mới sync |
| `CommissionTier` | Một bậc trong commission plan — {from_pct: decimal, to_pct: decimal, rate: decimal, accelerator: decimal}. Ví dụ: 80–100% đạt quota → rate 8%; >100% → rate 12% (accelerator 1.5×) | Bậc hoa hồng | Nhiều tiers tạo thành CommissionPlan.tiers[] |
| `PerformanceModifier` | Hệ số điều chỉnh thưởng dựa trên Performance Rating — configurable mapping: Exceeds=1.5×, Meets=1.0×, Below=0.5×, PIP=0×. HR Admin configure per BonusPlan. | Hệ số điều chỉnh hiệu suất | Mapping configurable per plan, không hardcode |
| `VestingEvent` | Một lần vest trong VestingSchedule — {vested_date, grant_percent, vested_amount, currency, status: PENDING/VESTED/CANCELLED}. Trigger TaxableItem khi status → VESTED. | Sự kiện vesting | Created by system scheduler; drives TaxableItem creation |
| `BonusPeriod` | {year: int, period_type: ANNUAL/SEMI_ANNUAL/QUARTERLY, period_label: str}. Ví dụ: {2026, ANNUAL, "FY2026"} | Kỳ tính thưởng | Scope của BonusStatement |
| `CRMSyncStatus` | Trạng thái sync từ CRM — {last_synced_at, records_imported, errors, status: OK/ERROR/PARTIAL}. Monitoring metric. | Trạng thái đồng bộ CRM | Not a domain entity — operational metadata |

### Commands

| Command | Actor | Definition | Vietnamese |
|---------|-------|-----------|-----------|-
| `CreateBonusPlan` | Compensation Admin | Tạo kế hoạch thưởng mới với eligible population, formula, approval workflow | Tạo kế hoạch thưởng |
| `RunBonusCalculation` | System (Payroll Trigger) / Compensation Admin | Tính thưởng cho toàn bộ eligible Workers trong kỳ | Chạy tính toán thưởng |
| `ApplyPerformanceModifier` | System | Áp dụng PerformanceModifier dựa trên Performance Rating từ PM module | Áp dụng hệ số hiệu suất |
| `ApproveBonusStatement` | Director / VP | Phê duyệt BonusStatement qua approval workflow | Phê duyệt bảng thưởng |
| `CreateCommissionPlan` | Sales Compensation Admin | Tạo kế hoạch hoa hồng với tiers, quota, accelerators | Tạo kế hoạch hoa hồng |
| `ImportSalesTransactions` | System (CRM Sync) | Import giao dịch CRM vào SalesTransaction; idempotent by transaction_id | Import giao dịch bán hàng |
| `RecalculateCommission` | System (real-time trigger) | Tính lại CommissionStatement khi SalesTransaction mới import | Tính lại hoa hồng |
| `GrantLTI` | Compensation Admin / HR Admin | Cấp LTI (ESOP/RSU) cho Worker với VestingSchedule | Cấp đãi ngộ dài hạn |
| `ProcessVestingEvent` | System (Scheduler) | Xử lý VestingEvent đến hạn; tạo TaxableItem; cập nhật balance | Xử lý sự kiện vesting |

### Domain Events

| Event | Definition | Vietnamese | Trigger |
|-------|-----------|-----------|---------|
| `BonusCalculated` | Thưởng đã được tính cho Worker trong kỳ — amount, currency, formula inputs | Đã tính thưởng | RunBonusCalculation command |
| `BonusApproved` | BonusStatement đã qua approval workflow; scheduled for payment | Thưởng đã được phê duyệt | ApproveBonusStatement command |
| `CommissionRecalculated` | Hoa hồng đã tính lại sau khi SalesTransaction mới sync | Hoa hồng đã tính lại | ImportSalesTransactions (real-time) |
| `QuotaAttainmentUpdated` | % đạt quota thay đổi — dashboard cập nhật real-time | Tỷ lệ đạt quota được cập nhật | CommissionRecalculated |
| `SalesTransactionSynced` | Giao dịch CRM đã import thành công; idempotency_key verified | Giao dịch bán hàng đã sync | ImportSalesTransactions |
| `LTIGranted` | LTI được cấp cho Worker với VestingSchedule | Đã cấp đãi ngộ dài hạn | GrantLTI command |
| `EquityVested` | VestingEvent đến hạn; equity vest thành công | Equity đã vest | ProcessVestingEvent command |
| `TaxableRewardCreated` | TaxableItem được tạo từ EquityVested hoặc cash bonus — forward tới Taxable Bridge | Phần thưởng chịu thuế đã được tạo | EquityVested, BonusApproved (nếu taxable) |
| `CommissionCapApplied` | Hoa hồng bị cap theo commission plan max threshold | Trần hoa hồng đã áp dụng | RecalculateCommission khi amount > cap |

### Business Rules

| Rule ID | Rule | Vietnamese | Hard/Soft |
|---------|------|-----------|-----------|
| BR-V01 | Commission recalculation phải real-time (< 5 giây) sau SalesTransaction sync — Kafka streaming required | Hoa hồng real-time < 5 giây | Hard (USP requirement) |
| BR-V02 | SalesTransaction là immutable sau khi synced — không UPDATE, chỉ có thể VOID với manual approval | Giao dịch bán hàng bất biến | Hard |
| BR-V03 | CRM sync là idempotent — duplicate transaction_id bị ignore (not double-counted) | Chống đếm trùng giao dịch CRM | Hard |
| BR-V04 | PerformanceModifier mapping là configurable per BonusPlan — không hardcode rating tiers | Hệ số hiệu suất configurable | Hard (architecture) |
| BR-V05 | LTI vesting trigger tạo TaxableItem NGAY LẬP TỨC — không có manual step | Taxable Bridge tự động khi vest | Hard |
| BR-V06 | BonusStatement chỉ có thể PAID một lần — duplicate payment protection bởi idempotency_key | Chống trả thưởng trùng | Hard |
| BR-V07 | Commission tiers phải non-overlapping và exhaustive — validation khi CreateCommissionPlan | Tiers không chồng lấp | Hard |
| BR-V08 | Khi Worker change territory mid-period, quota/commission split proportionally theo ngày | Phân bổ hoa hồng khi đổi territory | Soft/Configurable |

### Lifecycle States

#### BonusStatement States
```
DRAFT → CALCULATED → PENDING_APPROVAL → APPROVED → SCHEDULED → PAID
                                      └→ REJECTED → RECALCULATED
```

#### CommissionStatement States
```
OPEN (trong kỳ) → PENDING_REVIEW → FINALIZED → PAID
                                 ↑ (real-time updates khi in OPEN)
```

#### LTI / VestingSchedule States
```
GRANTED → VESTING (ongoing) → FULLY_VESTED
        └→ FORFEITED (terminated trước cliff)
           └→ (Partially VESTED nếu cliff đã qua)
```

### Integration Points

| Integration | Direction | Pattern | Ghi chú |
|-------------|-----------|---------|---------|
| CRM Systems (Salesforce, etc.) | Inbound | REST API daily + webhook trigger | Import SalesTransactions; idempotent by transaction_id |
| PM Module (Performance) | Inbound | Kafka subscribe | Consume PerformanceRatingFinalized; drive PerformanceModifier |
| BC-02 Calculation Engine | Outbound call | Sync | FX conversion for multi-currency deals; formula evaluation |
| BC-08 Taxable Bridge | Outbound event | Kafka | Publish TaxableRewardCreated for equity vest, taxable bonus |
| Commission Dashboard | Outbound | Kafka streaming | Real-time QuotaAttainmentUpdated → dashboard < 5s latency |
| Payroll Module | Via BC-08 | Kafka (via Bridge) | Indirect through Taxable Bridge for approved bonus payout |

---

*Glossary: Variable Pay (BC-03) — Total Rewards / xTalent HCM*
*2026-03-26*
