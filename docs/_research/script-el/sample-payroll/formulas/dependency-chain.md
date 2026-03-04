# Dependency Chain — Payroll Element Graph (3 Loại Hình)

> **Tài liệu:** Phân tích dependency graph và mức độ phức tạp  
> **Module:** Sample Payroll — MVEL + Drools Engine  
> **Ngày:** 2025-03-04  

---

## 1. Nhân Viên Văn Phòng — 12 Nodes

```
[Stage 1 — Input Facts]
  ATTENDANCE_DAYS          (từ Time & Attendance system)
  KPI_SCORE                (từ Performance module)
  EMPLOYEE_CONTRACT        (BASE_SALARY, allowances, dependents)

[Stage 2 — Base Calculation] executionOrder: 1-4
  BASE_SALARY ──────────────────────────────────────┐
    ├──► PRORATED_SALARY = BASE × (actual/std)      │ (phụ thuộc ATTENDANCE_DAYS)
    ├──► SENIORITY_ALLOWANCE = BASE × years × 1%   │
    ├──► PERFORMANCE_BONUS = BASE × kpiTier         │ (phụ thuộc KPI_SCORE)
    ├──► OT_150 = hourlyRate × 1.5 × otH150         │
    ├──► OT_200 = hourlyRate × 2.0 × otH200         │
    └──► OT_300 = hourlyRate × 3.0 × otH300         │
  TRANSPORT_ALLOWANCE (config) ──────────────────────┤
  LUNCH_ALLOWANCE (config) ──────────────────────────┤

[Stage 3 — Gross Aggregation] executionOrder: 6
  GROSS_SALARY = PRORATED + SENIORITY + TRANSPORT + LUNCH
               + POSITION + PERFORMANCE + OT_150 + OT_200 + OT_300

[Stage 4 — Insurance] executionOrder: 7-8
  BHXH_BASE = min(GROSS, 46.8M)
    ├──► BHXH_EMPLOYEE = BHXH_BASE × 8%
    ├──► BHYT_EMPLOYEE = BHXH_BASE × 1.5%
    └──► BHTN_EMPLOYEE = BHXH_BASE × 1%

[Stage 5 — Tax] executionOrder: 9-10
  TAXABLE_INCOME = GROSS - (exempt_allowances) - BHXH - BHYT - BHTN
                 - PERSONAL_DEDUCTION - DEPENDENT_DEDUCTION
    └──► PIT_TAX = progressiveTax(TAXABLE_INCOME, VN_7_BRACKETS)

[Stage 6 — Output] executionOrder: 11
  NET_SALARY = GROSS - BHXH_EMPLOYEE - BHYT_EMPLOYEE - BHTN_EMPLOYEE - PIT_TAX
```

**Complexity Score:** ⭐⭐⭐ (3/5)  
**Node count:** 12 elements, 5 stages  
**Branching points:** 1 (KPI tier calculation)  
**Tax-exempt split:** 2 elements (TRANSPORT, LUNCH → non-taxable portions)

---

## 2. Bác Sỹ Trực Bệnh Viện — 17 Nodes

```
[Stage 1 — Input Facts]
  DUTY_SCHEDULE            (lịch trực — loại ca, ngày, giờ)
  ATTENDANCE_DAYS          (ngày công thường)
  EMPLOYEE_CONTRACT        (BASE_SALARY, hazardLevel, medicalGrade)

[Stage 2 — Base + Duty Classification] executionOrder: 2-4
  BASE_SALARY ─────────────────────────────────────┐
    ├──► PRORATED_SALARY = BASE × (actual/std)     │ (nghỉ bệnh → proRata < 1)
    ├──► SENIORITY_ALLOWANCE = BASE × years × 1%  │
    ├──► OT_150 / OT_200 / OT_300                 │
    │                                               │
    ├──► HAZARD_ALLOWANCE                          │  ← Phức tạp: phân tích hazardLevel
    │        (A:10%, B:20%, C:30% × BASE)          │
    │                                               │
    └──► DUTY_PAY_FLAT ─── từ DUTY_SCHEDULE       │  ← Flat-rate per ca × loại (3 loại)
         DUTY_PAY_OT  ─── BASE/days/8 × OTrate    │  ← OT thêm ch ca Weekend/Holiday

  MEDICAL_PROF_ALLOWANCE ──────────────────────────┘  ← Config table by medicalGrade
  POSITION_ALLOWANCE ─── Config

[Stage 3 — Hazard Tax Split] executionOrder: 5   ★★ ĐIỂM PHỨC TẠP ★★
  HAZARD_ALLOWANCE (total)
    ├──► HAZARD_TAX_EXEMPT = min(HAZARD, 3,600,000)      ← Miễn thuế (≤ trần NĐ81)
    └──► HAZARD_TAXABLE    = max(0, HAZARD - 3,600,000)  ← Chịu thuế phần vượt

  VD EMP-004 (Loại C, base=32M):
    HAZARD = 32M × 30% = 9,600,000
    HAZARD_TAX_EXEMPT = min(9.6M, 3.6M) = 3,600,000
    HAZARD_TAXABLE    = 9.6M - 3.6M    = 6,000,000

[Stage 4 — Gross Aggregation] executionOrder: 6
  GROSS_SALARY = PRORATED + SENIORITY + MEDICAL_PROF_ALLOWANCE
               + HAZARD_TAX_EXEMPT + HAZARD_TAXABLE   ← Cả 2 phần (tổng hazard vào GROSS)
               + POSITION_ALLOWANCE
               + DUTY_PAY_FLAT + DUTY_PAY_OT
               + OT_150 + OT_200 + OT_300

[Stage 5 — Insurance] executionOrder: 7-8
  BHXH_BASE = min(GROSS, 46.8M)     ← NOTE: EMP-004 GROSS > ceiling → cap tại 46.8M
    ├──► BHXH_EMPLOYEE = 8%
    ├──► BHYT_EMPLOYEE = 1.5%
    └──► BHTN_EMPLOYEE = 1%

[Stage 6 — Tax] executionOrder: 9-10   ★★ ĐIỂM PHỨC TẠP ★★
  TAXABLE_INCOME = GROSS
    - MEDICAL_PROF_ALLOWANCE     (miễn toàn bộ)
    - HAZARD_TAX_EXEMPT          (miễn phần ≤ 3.6M)
    ← HAZARD_TAXABLE vẫn nằm trong GROSS, không được trừ
    - BHXH_EMPLOYEE - BHYT_EMPLOYEE - BHTN_EMPLOYEE
    - PERSONAL_DEDUCTION
    - DEPENDENT_DEDUCTION
    └──► PIT_TAX = progressiveTax(max(0, TAXABLE_INCOME))

[Stage 7 — Output] executionOrder: 11
  NET_SALARY = GROSS - BHXH - BHYT - BHTN - PIT_TAX
```

**Complexity Score:** ⭐⭐⭐⭐ (4/5)  
**Node count:** 17 elements, 7 stages  
**Branching points:** 3 (hazard level, duty type, ca type ×3)  
**Tax-exempt split:** 3 layers (MEDICAL_PROF full, HAZARD_TAX_EXEMPT partial, HAZARD_TAXABLE partial)  
**Key complexity driver:** 2-element tax split cho hazard + duty pay 2 khoản + multiple OT types

---

## 3. Công Nhân Luân Ca Lương Sản Phẩm — 18 Nodes

```
[Stage 1 — Input Facts]
  PRODUCTION_RECORD        (productCode, totalQty, qualityPassedQty, qualityRate)
  SHIFT_SCHEDULE           (loại ca theo tuần, nightShiftCount — xác định ĐẦU CA)
  OVERTIME_RECORD          (CA_DEM + OT weekend → complex combination)
  EMPLOYEE_CONTRACT        (BASE_SALARY — dùng cho floor + BHXH)

[Stage 2 — Production Calculation] executionOrder: 2-3
  PIECE_RATE_SALARY = qualityPassedQty × unitPrice(productCode)
    │
    └──► QUALITY_BONUS
           when qualityRate ≥ 0.98 → +5%
           when qualityRate ≥ 0.95 → +3%
           when qualityRate < 0.90 → -5% (penalty)
           else → 0

  BASE_SALARY ───────────────────────────────────────┐
    └──► SENIORITY_ALLOWANCE = BASE × years × 1%    │
    └──► NIGHT_SHIFT_ALLOWANCE                       │  ← Phức tạp: xác định ca đêm
           = nightShiftCount × (BASE/stdDays) × 30% │    theo đầu ca trong lịch tháng
                                                     │
  SHIFT_OT: OT_200 (ca đêm weekend)                 │
         = (BASE/stdDays/8) × otHours × 2.0         │
         = hourlyRate + phụ cấp đêm 30%             │  ← Cộng dồn 2 phụ cấp!

[Stage 3 — Gross with Floor Check] executionOrder: 6   ★★ ĐIỂM PHỨC TẠP ★★
  RAW_GROSS = PIECE_RATE_SALARY + QUALITY_BONUS
            + NIGHT_SHIFT_ALLOWANCE
            + SENIORITY_ALLOWANCE
            + OT_200

  GROSS_SALARY = max(RAW_GROSS, REGIONAL_MIN_WAGE_ZONE1)
                 ↑ Floor enforcement tại Gross (4,960,000)

  VD EMP-005 (ca ngày, 558 SP):
    PIECE_RATE = 558 × 12,000 = 6,696,000 > min wage ✓ → không cần floor
  
  Scenario NếuGross < MinWage (test case):
    GROSS = REGIONAL_MIN_WAGE = 4,960,000 (engine phải enforce)
    → BHXH tính trên 4,960,000 (không phải raw gross thấp hơn)

[Stage 4 — Insurance] executionOrder: 7-8
  BHXH_BASE = min(GROSS_SALARY, 46.8M)
    ├──► BHXH_EMPLOYEE = 8%
    ├──► BHYT_EMPLOYEE = 1.5%
    └──► BHTN_EMPLOYEE = 1%

[Stage 5 — Tax] executionOrder: 9-10
  TAXABLE_INCOME = max(0, GROSS - BHXH - BHYT - BHTN
                        - PERSONAL_DEDUCTION - DEPENDENT_DEDUCTION)
  PIT_TAX = progressiveTax(TAXABLE_INCOME, VN_7_BRACKETS)

  VD EMP-005 (no dependent):
    GROSS = 6,904,000 (approx)
    TAXABLE = 6.9M - 724K(BHXH+BHYT+BHTN) - 11M < 0 → PIT = 0
    → Không đến ngưỡng chịu thuế

  VD EMP-006 (luân ca 3 ca, higher gross):
    GROSS ≈ 11.5M (piece 7M + quality 350K + night 1.5M + seniority 285K + OT 1.4M)
    TAXABLE = 11.5M - 1.2M(SI) - 11M - 4.4M < 0 → PIT = 0
    → Vẫn không đến ngưỡng (thu nhập thấp)

[Stage 6 — Output] executionOrder: 11
  NET_SALARY = GROSS - BHXH - BHYT - BHTN - PIT_TAX
```

**Complexity Score:** ⭐⭐⭐⭐⭐ (5/5)  
**Node count:** 18 elements, 6 stages  
**Branching points:** 4 (quality tier, ca loại ×3 tuần, floor check, OT ca đêm weekend)  
**Key complexity drivers:**
1. Piece-rate base thay vì fixed salary (non-deterministic input)
2. Ca đêm xác định theo lịch tháng (không thể tính đơn giản)
3. Floor enforcement tại GROSS (GROSS ≠ sum of components nếu bị floor)
4. OT ca đêm weekend: cộng dồn 2 phụ cấp (OT 200% + night 30%)
5. Quality penalty âm có thể giảm PIECE_RATE (cần guard clause)

---

## 4. Summary — Complexity Comparison

| Tiêu chí | Văn Phòng | Bác Sỹ | Công Nhân |
|---------|-----------|--------|-----------|
| **Node count** | 12 | 17 | 18 |
| **Stage count** | 5 | 7 | 6 |
| **Branching rules** | 1 | 3 | 4 |
| **Tax-exempt layers** | 2 | 3 | 0 |
| **Base salary type** | Fixed | Fixed | Piece-rate (dynamic) |
| **Floor enforcement** | ❌ | ❌ | ✅ GROSS floor |
| **Regulatory references** | 2 | 5 | 3 |
| **Complexity score** | 3/5 | 4/5 | **5/5** |

**Drools rule count (ước tính):**
- Văn phòng: ~6 rules (3 common + 3 specific)
- Bác sỹ: ~10 rules (3 common + 4 hazard chain + 3 duty)
- Công nhân: ~13 rules (3 common + 4 piece-rate + 3 shift + 3 floor/OT)

**MVEL formula complexity:**
- Văn phòng: Đơn giản — arithmetic + conditional tier
- Bác sỹ: Trung bình-cao — tax split (2 intermediate nodes), lookup table
- Công nhân: Cao nhất — max() floor, dynamic ca detection, quality penalty

---

## 5. Key Design Decisions Ảnh Hưởng Engine

### D1 — Hazard Tax Split (Doctor)
Cần tạo **2 intermediate INFORMATION elements** (`HAZARD_TAX_EXEMPT` + `HAZARD_TAXABLE`) để Drools working memory lưu đúng giá trị cho:
- GROSS aggregation (dùng total hazard)  
- TAXABLE_INCOME (chỉ trừ phần exempt)

→ **Yêu cầu engine:** Intermediate fact insertion giữa rules

### D2 — GROSS Floor (Worker)  
GROSS không phải aggregate đơn thuần mà có `max(sum, minWage)` → **formula type: CONDITIONAL_AGGREGATE**  
Drools rule phải check sau khi insert GROSS fact, và có thể override nếu < floor.

→ **Yêu cầu engine:** Post-aggregate override rule với `salience` cao

### D3 — Ca Đêm (Worker)  
`nightShiftCount` không phải input thô từ HR — cần **pre-processing rule** đọc shift schedule, đếm ca có `shiftStart ≥ 22:00`, insert `nightShiftCount` fact trước khi NIGHT_SHIFT_ALLOWANCE rule chạy.

→ **Yêu cầu engine:** Multi-stage fact computation (preprocessing)

### D4 — OT Ca Đêm Weekend (Worker EMP-006)  
OT ngày cuối tuần + ca đêm = **2 phụ cấp cộng gộp:**  
`OT_200 = hourlyRate × 2.0 × hours` (Điều 98 BLLĐ)  
`NIGHT_SHIFT_ALLOWANCE` += 30% × lương ngày × ca đêm đó  
→ **Không thể merge thành 1 element** — phải tách để đảm bảo audit trail

### D5 — progressiveTax() Implementation  
Hàm `progressiveTax(income, brackets)` cần implement như **BuiltinFunction** trong MVEL whitelist:
```java
// Algorithm: bracketed accumulation
BigDecimal tax = ZERO;
for (Bracket b : brackets) {
    BigDecimal bracketIncome = min(income, b.to) - b.from;
    if (bracketIncome > 0) tax += bracketIncome * b.rate;
}
return tax;
```
→ Không thể viết inline trong MVEL vì cần loop (cấm theo DSL grammar restriction) — **PHẢI là built-in function**
