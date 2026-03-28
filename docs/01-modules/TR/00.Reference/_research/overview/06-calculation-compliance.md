# Calculation Engine & Compliance

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-05  
**Đối tượng**: Finance, Compliance, HR Admin, Developers  
**Đọc ~20 phút**

---

## Tổng quan

TR module có một **Calculation Engine** nền tảng xử lý tất cả các tính toán tài chính quan trọng: proration, tax, social insurance, overtime — áp dụng nhất quán trên toàn hệ thống. Cùng với đó là bộ sub-modules hỗ trợ compliance: Deductions, Tax Withholding, Taxable Bridge, và Audit.

```
Calculation Engine (Shared Foundation)
├── Proration Calculation
├── Tax Calculation Engine (country-specific)
├── Social Insurance Calculation
├── Overtime Multipliers
└── Component Dependencies & Calculation Order

Compliance Sub-modules
├── Deductions        (Loan, Garnishment, Advance)
├── Tax Withholding   (Elections, Declarations)
├── Taxable Bridge    (→ Payroll)
└── Audit Trail       (7-year retention)
```

---

## 1. Proration Calculation Engine

**Proration** — tính tỷ lệ lương/phúc lợi cho kỳ không đủ tháng.

### Khi nào proration xảy ra?
- Nhân viên mới vào giữa tháng
- Nhân viên nghỉ việc giữa tháng
- Unpaid leave trong kỳ lương
- Thay đổi lương giữa kỳ

### 2 phương pháp Proration

**Calendar Days Method:**
```
Proration Factor = Days Worked / Total Days in Month

Ví dụ: Vào làm 15/3, tháng 3 có 31 ngày
  Days Worked: 17 ngày (15/3 → 31/3)
  Proration Factor: 17/31 = 0.5484

  Base Salary (30M × 0.5484): 16,451,613 VND
```

**Working Days Method:**
```
Proration Factor = Working Days / Standard Working Days

Ví dụ: Vào làm 15/3, tháng 3 có 26 ngày công (chuẩn)
  Working Days: 11 ngày (từ 15/3)
  Proration Factor: 11/26 = 0.4231

  Lunch Allowance (2M × 0.4231): 846,154 VND
```

### Proration per Component — Quan trọng

Mỗi Pay Component có thể có **phương pháp proration khác nhau**:

| Component | Method | Lý do |
|-----------|--------|-------|
| Base Salary | Calendar Days | Tương ứng với ngày làm việc thực tế |
| Lunch Allowance | Working Days | Chỉ trả khi thực sự đi làm |
| Transportation | Working Days | Chỉ trả khi thực sự di chuyển |
| Housing Allowance | **Không prorate** | Full month hoặc không có |
| Annual Bonus | **Không prorate** | Thường dựa trên tenure riêng |

**Ví dụ tổng hợp (Nhân viên vào 15/3)**:

| Component | Amount | Method | Factor | Prorated |
|-----------|-------:|--------|:------:|--------:|
| Base Salary | 30M | Calendar | 17/31 | 16,451,613 |
| Lunch Allowance | 2M | Working | 11/26 | 846,154 |
| Housing Allowance | 5M | None | 1.0 | 5,000,000 |
| **Total** | | | | **22,297,767** |

---

## 2. Tax Calculation Engine

### Kiến trúc

```
Input: Gross Income + Employee Tax Profile
  ↓
Tax Engine:
  1. Identify Country Rules (by Legal Entity)
  2. Calculate Taxable Income
     (Gross - Deductions - Exemptions - SI Employee)
  3. Apply Tax Brackets (progressive)
  4. Apply Tax Credits
  5. Calculate Withholding
  ↓
Output: Tax Amount + Net Income
```

### Vietnam — PIT (Personal Income Tax)

```yaml
Progressive Tax Brackets (2024):
  0 - 5,000,000 VND/month:        5%
  5M - 10,000,000 VND/month:     10%
  10M - 18,000,000 VND/month:    15%
  18M - 32,000,000 VND/month:    20%
  32M - 52,000,000 VND/month:    25%
  52M - 80,000,000 VND/month:    30%
  > 80,000,000 VND/month:        35%

Deductions before tax:
  Personal deduction:    11,000,000 VND/month
  Per dependent:          4,400,000 VND/month each
  SI employee contribution (10.5% of salary, capped)
  Charity contributions (documented)

Resident vs Non-Resident:
  Resident: Progressive brackets (above)
  Non-Resident: Flat 20%
```

### US — Federal Income Tax Withholding

```yaml
W-4 Elections:
  Filing Status: Single / Married / Head of Household
  Allowances / Additional Withholding
  Exempt (nếu đủ điều kiện)

Supplement Income (Bonus, RSU vest):
  Flat 22% federal withholding (supplemental rate)
  + State rate

FICA:
  Social Security: 6.2% (up to $168,600 wage base - 2024)
  Medicare: 1.45% (no cap) + 0.9% additional (>$200K)
```

### Social Insurance Calculation

```yaml
Vietnam:
  Employee SI:   8% (cap: 36M VND/month → max 2,880,000/month)
  Employee HI:   1.5% (same cap → max 540,000/month)
  Employee UI:   1% (cap: 83.2M → max 832,000/month)
  Total EE:      10.5%

  Employer SI:   17.5% (same capped basis)
  Employer HI:   3%
  Employer UI:   1%
  Employer AF:   0.5% (accident fund)
  Total ER:      22%

Key: SI contributions calculated on capped salary, not full salary
```

### Tax for Equity Events (Taxable Bridge)

```yaml
RSU Vest:
  Taxable Income = Vested Quantity × FMV on Vest Date
  Withholding Method: SUPPLEMENTAL (22% federal + state for US)
  Vietnamese: PIT at applicable bracket rate

Stock Option Exercise:
  Taxable Income = (FMV on Exercise - Strike Price) × Quantity
  Same withholding treatment

Perk Redemption (above threshold):
  Taxable Income = Market Value of Perk
  → TaxableItem → Payroll
```

---

## 3. Deductions

### 3 loại Deduction

| Loại | Mô tả | Ví dụ |
|------|-------|-------|
| **LOAN** | Ứng lương, vay công ty trả góp | Vay mua điện thoại, trả 12 kỳ |
| **GARNISHMENT** | Khấu trừ theo lệnh tòa án | Child support, alimony |
| **ADVANCE** | Tạm ứng lương tháng | Ứng 50% lương tháng |

### Deduction Schedules

```yaml
ONE_TIME:      Khấu trừ 1 lần duy nhất
RECURRING:     Khấu trừ mỗi kỳ lương cho đến close
INSTALLMENT:   Khấu trừ số tiền cố định theo kỳ (vd: 12 kỳ)
```

### Priority-Based Deduction Order

Khi nhiều deductions cùng lúc và insufficient funds:

```
Priority thực thi (cao → thấp):
  1. GARNISHMENT   (bắt buộc pháp lý)
  2. STATUTORY     (SI, tax withholding)
  3. LOAN          (theo thỏa thuận)
  4. ADVANCE       (thứ tự cuối)

Insufficient Funds Handling:
  - Nếu không đủ tiền cho tất cả: ưu tiên theo order trên
  - Carryover phần không khấu trừ được sang kỳ sau
  - Alert HR để review
```

---

## 4. Tax Withholding (Khai báo thuế)

### Tax Withholding Elections

```yaml
US — W-4 Form:
  Filing Status: Single / Married Filing Jointly / Head of Household
  Dependents: Số người phụ thuộc
  Additional Withholding: Số tiền bổ sung
  Exempt: Đủ điều kiện miễn khấu trừ (ít gặp)

Vietnam — Tax Declaration:
  Resident status declaration
  Dependent registration (đăng ký người phụ thuộc)
  Number of dependents → personal deduction
```

### Tax Declaration for Dependents (VN)

```yaml
Nhân viên đăng ký người phụ thuộc:
  - Khai báo thông tin (tên, CCCD/MST)
  - Submit hồ sơ (birth cert / marriage cert)
  - HR verify và approve

Sau khi approve:
  Personal deduction tăng: +4,400,000 VND/month per dependent
  → Tax base giảm → thuế ít hơn
  Hệ thống tự động áp dụng vào tháng tiếp theo
```

---

## 5. Taxable Bridge — Kết nối sang Payroll

**Taxable Bridge** là cơ chế đảm bảo mọi **taxable event từ TR** đều được xử lý thuế đúng trong kỳ Payroll.

### Các nguồn tạo TaxableItem

```yaml
EQUITY_VESTING:      RSU vested → Taxable income
EQUITY_EXERCISE:     Option exercised → Taxable gain
PERK_REDEMPTION:     Perk có giá trị tiền tệ > threshold
BENEFIT_PREMIUM:     Certain benefit premiums (imputed income)
BONUS_PAYMENT:       Bonus payments for payroll processing
```

### Flow

```
TR Event                TaxableItem              Payroll
─────────               ───────────              ───────
RSU Vest (250 units)  →  Amount: 30M VND      →  Add to paycheck
FMV: 120K × 250            Source: EQUITY_VESTING   Calculate withholding
                           Item Type: SUPPLEMENTAL   Deduct taxes
                           Employee: [id]            Net impact to employee
                           Tax Year: 2025
```

### Tại sao quan trọng?

Nếu không có Taxable Bridge:
- Equity vesting không được withhold thuế → nhân viên bị surprise tax bill cuối năm
- Perk redemption taxable không bị track → compliance risk
- HR phải manually tính và báo cáo với Payroll

---

## 6. Audit Trail

### 7-Year Retention Policy

```yaml
Mọi thay đổi trong TR được ghi vào AuditLog:
  - Entity type + entity ID
  - Field changed
  - Old value → New value
  - User who made change
  - Timestamp (with timezone)
  - IP address
  - Reason/justification (nếu có)

Retention: 7 năm từ ngày ghi
Storage: Phân vùng theo tháng (monthly partitioning)
```

### Các sự kiện bắt buộc audit

```
Compensation changes:    Salary, grade, component changes
Benefits changes:        Plan enrollment, coverage changes
Equity changes:          Grant, vest, exercise events
Tax elections:           W-4 changes, declaration updates
Deduction changes:       Setup, modification, closure
Approval actions:        Approve/reject với reason
```

### Compliance Reporting

```yaml
Supported Reports:
  - Compensation Audit Trail    (by employee, by period)
  - Pay Equity Analysis         (by grade, by gender, by job family)
  - Benefits Enrollment Audit   (changes, life events)
  - Tax Withholding Summary     (by employee, by period)
  - Equity Grant Audit          (vesting events, tax events)
  - SOX Compliance Report       (key control evidence)
```

---

*Nguồn: `02-conceptual-guide.md` (Behaviors 1-3) · `09-tax-compliance-guide.md` · `10-multi-country-compensation-guide.md` · `03.07-DS-deductions.md`*  
*← [05 Recognition, Offer & Statement](./05-recognition-offer-statement.md) · [07 Integration Architecture →](./07-integration-architecture.md)*
