# Data Dictionary — xTalent Sample Payroll Dataset

> **Phạm vi:** Mô tả chi tiết từng trường dữ liệu trong bộ sample payroll (kỳ 2025-03)  
> **Đối tượng đọc:** Developer triển khai Payroll Engine, QA thiết kế test case, BA review nghiệp vụ  
> **Ngày:** 2025-03-04

---

## 1. `employees.json` — Master Data Nhân Viên

### 1.1 Trường chung (áp dụng cho mọi loại hình)

| Trường | Kiểu | Mô tả | Ví dụ |
|--------|------|-------|-------|
| `employeeId` | String | Mã định danh nhân viên, unique trong hệ thống | `"EMP-001"` |
| `fullName` | String | Họ tên đầy đủ | `"Nguyễn Thị Mai"` |
| `contractType` | Enum | Loại hợp đồng lao động | `INDEFINITE` / `DEFINITE_12M` |
| `employeeType` | Enum | Chế độ làm việc | `FULL_TIME` |
| `status` | Enum | Trạng thái nhân sự | `ACTIVE` / `INACTIVE` |
| `jobGrade` | String | Bậc lương / cấp độ vị trí | `"OFF-S3"`, `"MED-BS2"`, `"WRK-A2"` |
| `department` | String | Phòng ban / khoa | `"FINANCE"`, `"ONCOLOGY"` |
| `position` | String | Tên vị trí | `"Financial Analyst"` |
| `region` | String | Vùng làm việc — xác định min wage | `"HN"` (Vùng 1) |
| `taxResidency` | Enum | Cư trú thuế TNCN | `RESIDENT` / `NON_RESIDENT` |
| `startDate` | Date (ISO) | Ngày bắt đầu làm việc — tính thâm niên | `"2022-06-01"` |

### 1.2 `salary` — Thông tin lương

| Trường | Kiểu | Mô tả | Ghi chú |
|--------|------|-------|---------|
| `baseSalary` | Long (VNĐ) | Lương cơ bản trong hợp đồng | Dùng tính BHXH, OT, thâm niên |
| `contractSalary` | Long | Lương ghi trong hợp đồng (=baseSalary trong sample) | Có thể khác baseSalary ở 1 số DN |
| `salaryType` | Enum | Cơ chế trả lương | `MONTHLY_FIXED` / `PIECE_RATE` |

> **Lưu ý quan trọng:** Với công nhân `PIECE_RATE`, `baseSalary` chỉ dùng để tính BHXH và floor check — **không** dùng làm lương thực trả.

### 1.3 `allowances[]` — Mảng phụ cấp

| Trường | Kiểu | Mô tả | Ví dụ giá trị |
|--------|------|-------|--------------|
| `code` | String | Mã phụ cấp khớp với element-registry | `"TRANSPORT_ALLOWANCE"` |
| `amount` | Long (VNĐ) | Số tiền phụ cấp mỗi tháng | `1500000` |
| `taxable` | Boolean | Có chịu thuế TNCN không | `false` (miễn thuế) |
| `_note` | String | Ghi chú nghiệp vụ (không dùng trong engine) | Giải thích cơ sở tính |

### 1.4 `taxInfo` — Thông tin giảm trừ thuế

| Trường | Kiểu | Mô tả | Giá trị hiện tại |
|--------|------|-------|-----------------|
| `personalDeduction` | Long | Giảm trừ bản thân — cố định | 11,000,000 VNĐ/tháng |
| `dependents` | Int | Số người phụ thuộc đã đăng ký MST | 0, 1, hoặc 2 |
| `dependentDeduction` | Long | = dependents × 4,400,000 | Tính tự động |

### 1.5 `hazardInfo` — Thông tin độc hại (chỉ DOCTOR)

| Trường | Kiểu | Mô tả | EMP-003 | EMP-004 |
|--------|------|-------|---------|---------|
| `hazardLevel` | Enum (`A`/`B`/`C`) | Mức độ độc hại — quyết định tỷ lệ phụ cấp | `B` | `C` |
| `hazardCategory` | String | Loại nguy cơ nghề nghiệp | `INFECTIOUS_DISEASE` | `CANCER_RADIATION` |
| `hazardAllowanceRate` | Decimal | Tỷ lệ % của `baseSalary` | `0.20` (20%) | `0.30` (30%) |
| `statutoryExemptCeiling` | Long | Trần miễn thuế NĐ81/2009 | `3,600,000` | `3,600,000` |

> ⚠️ **Critical:** `statutoryExemptCeiling` = 3,600,000 VNĐ/tháng (cố định theo NĐ81/2009-CP). Mọi phụ cấp độc hại vượt mức này **phải chịu thuế TNCN**.

### 1.6 `shiftInfo` — Thông tin ca làm việc (chỉ WORKER)

| Trường | Kiểu | Mô tả | EMP-005 | EMP-006 |
|--------|------|-------|---------|---------|
| `shiftPattern` | Enum | Kiểu lịch ca | `FIXED_DAY` | `ROTATING_3_SHIFT` |
| `standardWorkDays` | Int | Ngày công chuẩn trong tháng | 26 | 26 |
| `shiftRotationCycle` | Enum | Chu kỳ luân chuyển ca | N/A | `WEEKLY` |

---

## 2. `policy-config.json` — Cấu Hình Chính Sách

### 2.1 `LABOR_STANDARDS` — Chuẩn lao động

| Key | Giá trị | Ý nghĩa | Nguồn pháp lý |
|-----|---------|---------|--------------|
| `BASE_WAGE` | 2,340,000 | Lương cơ sở nhà nước (VNĐ/tháng) | NĐ 73/2024/NĐ-CP |
| `REGIONAL_MIN_WAGE_ZONE1` | 4,960,000 | Lương tối thiểu vùng 1 (Hà Nội, HCM) | NĐ 38/2022 |
| `REGIONAL_MIN_WAGE_ZONE2` | 4,410,000 | Lương tối thiểu vùng 2 | NĐ 38/2022 |
| `STANDARD_WORK_DAYS_MONTH` | 26 | Ngày công chuẩn tháng 3/2025 | BLLĐ 2019 |

### 2.2 `SOCIAL_INSURANCE` — Bảo hiểm xã hội

**Ceiling (trần đóng BHXH):**

| Loại BH | Trần | Công thức |
|---------|------|-----------|
| BHXH | 46,800,000 | 20 × BASE_WAGE |
| BHYT | 46,800,000 | 20 × BASE_WAGE |
| BHTN | 46,800,000 | 20 × BASE_WAGE |

**Tỷ lệ đóng góp:**

| Loại | Nhân viên | Công ty | Tổng |
|------|-----------|---------|------|
| BHXH | 8% | 17.5% | 25.5% |
| BHYT | 1.5% | 3% | 4.5% |
| BHTN | 1% | 1% | 2% |
| TNLĐ-BNN | 0% | 0.5% | 0.5% |
| **Tổng** | **10.5%** | **22%** | **32.5%** |

> ⚠️ Nhân viên thử việc (`PROBATION`) và freelancer (`FREELANCE`) **không đóng** BHXH bắt buộc.

### 2.3 `PIT_TAX.brackets` — Biểu thuế TNCN 7 bậc

| Bậc | Thu nhập chịu thuế/tháng | Thuế suất | Thuế trên phần đến đầu bậc |
|-----|--------------------------|-----------|---------------------------|
| 1 | 0 – 5,000,000 | 5% | 0 |
| 2 | 5,000,001 – 10,000,000 | 10% | 250,000 |
| 3 | 10,000,001 – 18,000,000 | 15% | 750,000 |
| 4 | 18,000,001 – 32,000,000 | 20% | 1,950,000 |
| 5 | 32,000,001 – 52,000,000 | 25% | 4,750,000 |
| 6 | 52,000,001 – 80,000,000 | 30% | 9,750,000 |
| 7 | Trên 80,000,000 | 35% | 18,150,000 |

**Công thức tính PIT (progressiveTax algorithm):**
```
tax = 0
for each bracket (from, to, rate):
    income_in_bracket = min(taxableIncome, to) - from
    if income_in_bracket > 0:
        tax += income_in_bracket × rate
return tax
```

### 2.4 `PIT_TAX.taxExemptItems` — Các khoản miễn thuế TNCN

| Code | Mức miễn | Loại | Nguồn pháp lý |
|------|----------|------|--------------|
| `TRANSPORT_ALLOWANCE` | ≤ 1,500,000/tháng | Partial | TT111/2013 điều 2 |
| `LUNCH_ALLOWANCE` | ≤ 730,000/tháng | Partial | NĐ 24/2020 |
| `PHONE_ALLOWANCE` | ≤ 1,000,000/tháng | Partial | TT111/2013 |
| `MEDICAL_PROF_ALLOWANCE` | **Toàn bộ** | **Full** | Điều 3.1b Luật TNCN |
| `HAZARD_ALLOWANCE` | ≤ 3,600,000/tháng | **Partial** ⚠️ | NĐ81/2009-CP + TT20/2023 |

> ⚠️ **HAZARD_ALLOWANCE** là trường hợp phức tạp nhất: phần ≤ 3.6M miễn thuế, phần vượt **chịu thuế TNCN bình thường**. Xem `D1` trong `complexity-assessment.md`.

### 2.5 `HAZARD_ALLOWANCE_TABLE` — Bảng phụ cấp độc hại

| Level | Tỷ lệ | Mô tả | Áp dụng ngành y tế |
|-------|-------|-------|-------------------|
| A | 10% × baseSalary | Nặng nhọc | Xét nghiệm, giải phẫu bệnh |
| B | 20% × baseSalary | Nguy hiểm, lây nhiễm | Bác sỹ Nội, Ngoại |
| C | 30% × baseSalary | **Đặc biệt nguy hiểm** | Ung bướu, xạ trị ⬅️ mức cao nhất |

### 2.6 `MEDICAL_DUTY_PAY` — Phụ cấp trực bệnh viện

| Loại ca | Mô tả | Flat-rate BS_CHINH | Flat-rate TK/CK2 | OT thêm |
|---------|-------|-------------------|-----------------|---------|
| `DUTY_24H_NORMAL` | Ca thường ngày | 115,000 | 160,000 | Không |
| `DUTY_24H_WEEKEND` | Ca Chủ nhật | 180,000 | 245,000 | OT 200% × 8h |
| `DUTY_24H_HOLIDAY` | Ca ngày lễ | 220,000 | 300,000 | OT 300% × 8h |

> **Cách tính tổng trực:** `DUTY_PAY_FLAT` (tổng các flat-rate) + `DUTY_PAY_OT` (OT phần tính thêm) — 2 elements **tách riêng** trong engine.

### 2.7 `PIECE_RATE_TABLE` — Đơn giá sản phẩm

| Code | Mô tả | Đơn giá | Số SP tối thiểu để đạt min wage |
|------|-------|---------|--------------------------------|
| `ASM-TYPE-A` | Lắp ráp Type A (đơn giản) | 12,000/SP | 414 SP |
| `ASM-TYPE-B` | Lắp ráp Type B (phức tạp) | 18,500/cụm | 268 cụm |

**Quality Incentive tiers:**

| Tier | Tỷ lệ đạt chất lượng | Bonus/Penalty |
|------|---------------------|---------------|
| Tier 1 | ≥ 98% | +5% trên PIECE_RATE |
| Tier 2 | 95–97.9% | +3% trên PIECE_RATE |
| Không bonus | 90–94.9% | 0% |
| **Penalty** | < 90% | **-5%** trên PIECE_RATE |

---

## 3. `attendance-2025-03.json` — Chấm Công

### 3.1 Cấu trúc bản ghi chấm công chung

| Trường | Kiểu | Mô tả | Ghi chú |
|--------|------|-------|---------|
| `employeeId` | String | Mã nhân viên, link với employees.json | FK |
| `salaryType` | Enum | Khớp với employees.salary.salaryType | Validation |
| `standardWorkDays` | Int | Ngày công chuẩn tháng | 26 (tháng 3/2025) |
| `actualWorkDays` | Int | Ngày công thực tế (sau trừ nghỉ) | Dùng tính pro-rata |
| `absenceDays` | Int | Số ngày vắng = standard - actual | `standardWorkDays - actualWorkDays` |
| `proRataRatio` | Decimal | = actualWorkDays / standardWorkDays | Pre-computed cho clarity |

### 3.2 `overtime[]` — Chi tiết OT từng ngày

| Trường | Kiểu | Giá trị hợp lệ | Mô tả |
|--------|------|----------------|-------|
| `date` | Date | ISO 8601 | Ngày làm OT cụ thể |
| `type` | Enum | `OT_NORMAL_DAY` / `OT_WEEKEND` / `OT_HOLIDAY_PUBLIC` | Loại OT quyết định multiplier |
| `hours` | Decimal | > 0 | Số giờ OT |
| `multiplier` | Decimal | 1.5 / 2.0 / 3.0 | Hệ số nhân lương giờ |

**Tổng hợp OT sang `otHours`:**
```json
"otHours": {
  "OT_150_HOURS": 5.5,   ← tổng giờ type=OT_NORMAL_DAY
  "OT_200_HOURS": 8.0,   ← tổng giờ type=OT_WEEKEND
  "OT_300_HOURS": 4.0    ← tổng giờ type=OT_HOLIDAY_PUBLIC
}
```

### 3.3 `dutySchedule[]` — Lịch trực bệnh viện (chỉ DOCTOR)

| Trường | Kiểu | Mô tả | Ví dụ |
|--------|------|-------|-------|
| `dutyId` | String | Mã ca trực, unique | `"DTY-001"` |
| `date` | Date | Ngày bắt đầu ca trực | `"2025-03-08"` |
| `type` | Enum | Loại ca → quyết định flat-rate và OT | `DUTY_24H_HOLIDAY` |
| `startTime` | DateTime | Giờ vào trực (ISO 8601) | `"2025-03-08T07:00:00"` |
| `endTime` | DateTime | Giờ kết thúc trực | `"2025-03-09T07:00:00"` |
| `flatRatePay` | Long | Flat-rate theo QĐ54/BYT (VNĐ) | `220,000` |
| `additionalOT` | Boolean | Có cộng thêm OT không | `true` (weekend/holiday) |
| `additionalOTRate` | Decimal | Hệ số OT phần thêm | `3.0` (ngày lễ) |
| `additionalOTHours` | Decimal | Giờ tính OT phần thêm | `8.0` |

> **Cách đọc:** DTY-003 (ngày 8/3 — lễ): Bác sỹ nhận 220,000 flat + OT 300% × 8h × hourlyRate. Đây là **ca phức tạp nhất** trong bộ sample.

### 3.4 `shifts` — Lịch ca công nhân (chỉ WORKER ROTATING)

Mỗi bản ghi `shiftDetail` trong EMP-006 đại diện cho **1 tuần làm việc**:

| Trường | Kiểu | Mô tả | Quan trọng |
|--------|------|-------|-----------|
| `weekOfMonth` | Int / String | Tuần trong tháng | 1, 2, 3, 4, `"partial_5"` |
| `shiftType` | Enum | `CA_SANG` / `CA_CHIEU` / `CA_DEM` | **Xác định theo GIỜ BẮT ĐẦU ca** |
| `workDays` | Int | Số ngày làm ca này trong tuần | 4–6 |
| `shiftStart` | Time | Giờ bắt đầu ca (`HH:mm`) | `"22:00"` → là CA_DEM |
| `nightShiftCount` | Int | Số ca đêm trong tuần đó | 0 hoặc = workDays nếu CA_DEM |

**Rule xác định CA_DEM:** `shiftStart >= "22:00"` — xác định tại thời điểm ĐẦU CA, không phải giờ kết thúc.

**Summary EMP-006 tháng 3/2025:**
```
CA_SANG : 10 ngày (tuần 1 + tuần 4)
CA_CHIEU: 10 ngày (tuần 2 + partial tuần 5)
CA_DEM  :  6 ngày (tuần 3) ← 6 ca đêm → nightShiftCount = 6
TỔNG    : 26 ngày
```

---

## 4. `element-registry.json` — Registry Payroll Elements

### 4.1 Cấu trúc một Element

```json
{
  "code":          "GROSS_SALARY",        ← Mã định danh duy nhất
  "name":          "Tổng thu nhập trước khấu trừ",
  "type":          "EARNING",             ← EARNING | DEDUCTION | INFORMATION | TAX
  "subtype":       "AGGREGATE",           ← Phân loại chi tiết hơn
  "applicability": ["OFFICE","DOCTOR","WORKER"],  ← Áp dụng loại hình nào
  "formula": {
    "dsl":  "...",   ← Business DSL (người dùng đọc)
    "mvel": "...",   ← MVEL compiled (engine thực thi)
    "description": "..."
  },
  "dependencies":  ["PRORATED_SALARY", ...],  ← Elements phải tính trước
  "taxable":       true | false | "PARTIAL",
  "siContribution":true | false | "PARTIAL",  ← Tính vào quỹ BHXH không
  "executionOrder":6                          ← Thứ tự trong dependency chain
}
```

### 4.2 Phân loại `type` và `subtype`

| type | subtype | Mô tả | Ảnh hưởng Net |
|------|---------|-------|---------------|
| `EARNING` | `FIXED` | Thu nhập cố định (base salary) | Cộng vào Gross |
| `EARNING` | `COMPUTED` | Thu nhập tính toán (pro-rata, OT) | Cộng vào Gross |
| `EARNING` | `ALLOWANCE` | Phụ cấp | Cộng vào Gross |
| `EARNING` | `BONUS` | Thưởng | Cộng vào Gross |
| `EARNING` | `PIECE_RATE` | Lương sản phẩm | Cộng vào Gross |
| `EARNING` | `OUTPUT` | Net salary (final) | = Gross - deductions |
| `DEDUCTION` | `SOCIAL_INSURANCE` | BHXH/BHYT/BHTN NV đóng | Trừ khỏi Net |
| `INFORMATION` | `SI_BASE` | Cơ sở tính BHXH (intermediate) | Không ảnh hưởng trực tiếp |
| `INFORMATION` | `TAX_SPLIT` | Phân tách hazard exempt/taxable | Không ảnh hưởng trực tiếp |
| `INFORMATION` | `TAX_BASE` | Thu nhập chịu thuế (intermediate) | Input cho PIT |
| `TAX` | `PROGRESSIVE_TAX` | Thuế TNCN lũy tiến | Trừ khỏi Net |

### 4.3 Thứ tự thực thi (`executionOrder`)

| Order | Stage | Elements |
|-------|-------|---------|
| 1 | Input | `BASE_SALARY` |
| 2 | Base Earning | `PRORATED_SALARY`, `PIECE_RATE_SALARY` |
| 3 | Allowances | `SENIORITY`, `TRANSPORT`, `LUNCH`, `MEDICAL_PROF`, `NIGHT_SHIFT` |
| 4 | Bonuses & OT | `PERFORMANCE_BONUS`, `OT_150/200/300`, `HAZARD_ALLOWANCE`, `DUTY_PAY_FLAT` |
| 5 | Split/Derived | `HAZARD_TAX_EXEMPT`, `HAZARD_TAXABLE`, `DUTY_PAY_OT` |
| 6 | Gross Aggregate | `GROSS_SALARY` |
| 7 | SI Base | `BHXH_BASE` |
| 8 | SI Deductions | `BHXH/BHYT/BHTN_EMPLOYEE` + employer contributions |
| 9 | Tax Base | `TAXABLE_INCOME` |
| 10 | Tax | `PIT_TAX` |
| 11 | Net Output | `NET_SALARY` |

---

## 5. Drools `.drl` — Quy Ước Viết Rules

### 5.1 Agenda Groups và thứ tự thực thi

```
pre-payroll-worker  ← Pre-processing (nightShiftCount, shift classification)
pre-payroll-doctor  ← Hazard classification
gross-calculation   ← Tất cả EARNING elements (order 1-6)
insurance           ← BHXH/BHYT/BHTN (order 7-8)
tax                 ← TAXABLE_INCOME + PIT (order 9-10)
net-calculation     ← NET_SALARY (order 11)
post-processing     ← Làm tròn, report
```

### 5.2 Salience — Ưu tiên trong cùng agenda-group

| Salience range | Mục đích |
|----------------|---------|
| 300+ | Pre-processing (pre-payroll) |
| 200 | Eligibility check (BHXH eligible?) |
| 90-100 | Element tính đầu tiên trong group |
| 70-89 | Element phụ thuộc element trước |
| 20-30 | Aggregate rules (Gross, Total SI) |
| 10-19 | 2-stage patterns (floor enforcement) |
| < 10 | Final output (Net salary) |

### 5.3 Pattern Guard — Idempotency

Mọi rule đều dùng `not PayrollElement(code == "TARGET_CODE", employeeId == ...)` để đảm bảo:
- Rule chỉ fire **1 lần** dù working memory được kích hoạt nhiều lần
- Không bị duplicate facts trong Drools Session

---

## 6. MVEL Formulas — Quy Ước Viết

### 6.1 BigDecimal everywhere

Mọi phép tính tiền tệ đều dùng `java.math.BigDecimal` để tránh floating point error:

```mvel
// ✅ Đúng
baseSalary.multiply(new java.math.BigDecimal("0.08"))

// ❌ Sai — floating point error
baseSalary * 0.08
```

### 6.2 Division luôn chỉ định RoundingMode

```mvel
// ✅ Đúng — không throw ArithmeticException nếu kết quả vô tận
baseSalary.divide(new BigDecimal(26), 10, RoundingMode.HALF_UP)

// ❌ Sai — sẽ throw nếu chia không hết
baseSalary.divide(new BigDecimal(26))
```

### 6.3 Conditional — ternary thay vì if/else block

```mvel
// ✅ Đúng trong MVEL (ternary operator)
kpiScore >= 1.2 ? baseSalary.multiply(...) : BigDecimal.ZERO

// ❌ Không dùng được khi DSL grammar restrict
if (kpiScore >= 1.2) { ... }
```

### 6.4 Function calls — luôn qua service objects

```mvel
// ✅ Đúng — inject vào EvalContext, nằm trong whitelist
policyService.getBhxhCeiling()
attendanceService.calculateDutyFlatRate(...)

// ❌ Sai — không được phép instantiate arbitrary objects
new SomeService().doSomething()
```
