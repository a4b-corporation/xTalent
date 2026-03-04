# Calculation Walkthrough — Trace Chi Tiết 2 Case Phức Tạp Nhất

> **Mục đích:** Trace từng bước tính toán theo đúng thứ tự thực thi của Drools Engine, giúp developer và QA hiểu luồng dữ liệu và kiểm tra kết quả.  
> **Case 1:** EMP-004 (Trưởng khoa Ung bướu) — phức tạp nhất nhóm Bác sỹ  
> **Case 2:** EMP-006 (Công nhân Luân ca 3 ca) — phức tạp nhất nhóm Công nhân  
> **Ngày:** 2025-03-04

---

## CASE 1: EMP-004 — Phạm Đức Minh (Trưởng Khoa Ung Bướu)

### Input Data

```
employeeId:   EMP-004
group:        DOCTOR
period:       2025-03
baseSalary:   32,000,000
hazardLevel:  C          ← Level cao nhất
medicalGrade: MED-TK1 (Trưởng Khoa, Chuyên Khoa 2)
seniorityYears: 15 năm
dependents:   2
actualWorkDays: 26 (full month)

DutySchedule:
  DTY-004: 12/03 — NORMAL  → flat=160,000, no OT
  DTY-005: 23/03 — WEEKEND → flat=245,000, OT 200%×8h
```

---

### Step-by-Step Execution

#### ▶ Stage 1 | executionOrder: 1 — Base Input

```
BASE_SALARY = 32,000,000 VNĐ
  ← Lấy trực tiếp từ employee.salary.baseSalary
  ← Rule: không có rule Drools — đây là fact input ban đầu
```

#### ▶ Stage 2 | executionOrder: 2 — Pro-rated Salary

```
RULE: DOC_006 "Pro-rated Salary Doctor"

  INPUT:  baseSalary = 32,000,000
          actualWorkDays = 26
          standardWorkDays = 26

  FORMULA: 32,000,000 × (26 / 26) = 32,000,000

  PRORATED_SALARY = 32,000,000  ← Full month, không bị cắt
```

#### ▶ Stage 3 | executionOrder: 3 — Allowances

```
RULE: COMMON "Seniority Allowance"

  FORMULA: min(15 × 0.01, 0.15) × 32,000,000
         = min(0.15, 0.15) × 32,000,000
         = 0.15 × 32,000,000

  SENIORITY_ALLOWANCE = 4,800,000  ← Đã đạt tối đa 15% sau 15 năm

──────────────────────────────────────────────────

RULE: DOC_001 "Medical Professional Allowance"

  INPUT:  gradeCode = "CHUYEN_KHOA_2"
          lookup MEDICAL_ALLOWANCE_TABLE → 35% × BASE_WAGE × hệsố

  MEDICAL_PROF_ALLOWANCE = 3,369,960
  ← taxExempt = true (FULL) theo Điều 3.1b Luật TNCN
  ← Không tính BHXH
```

#### ▶ Stage 4 | executionOrder: 4 — Hazard & Duty Flat

```
RULE: DOC_002 "Hazard Allowance Total"

  INPUT:  hazardLevel = "C"
          baseSalary = 32,000,000

  LOOKUP: rate["C"] = 0.30

  FORMULA: 32,000,000 × 0.30 = 9,600,000

  HAZARD_ALLOWANCE = 9,600,000
  ← Chưa phân tách — intermediate value

──────────────────────────────────────────────────

RULE: DOC_004 "Duty Pay Flat Rate"

  INPUT:  DTY-004 (NORMAL, grade TK) → 160,000
          DTY-005 (WEEKEND, grade TK) → 245,000

  FORMULA: 160,000 + 245,000 = 405,000

  DUTY_PAY_FLAT = 405,000
  ← Cả 2 ca trực gộp lại

──────────────────────────────────────────────────

RULE: DOC_005 "Duty Pay OT Weekend Supplement"

  INPUT:  DTY-005 (WEEKEND, additionalOT=true)
          hourlyRate = 32,000,000 ÷ 26 ÷ 8 = 153,846.15 VNĐ/giờ

  FORMULA: 153,846.15 × 8h × 2.0 = 2,461,538

  DUTY_PAY_OT = 2,461,538
  ← Tách riêng khỏi DUTY_PAY_FLAT (audit trail)

──────────────────────────────────────────────────

POSITION_ALLOWANCE = 8,000,000  ← Config lookup theo grade TK
```

#### ▶ Stage 5 | executionOrder: 5 — ⭐ Hazard Tax Split (ĐIỂM PHỨC TẠP NHẤT) ⭐

```
RULE: DOC_003 "Hazard Tax Split (Exempt vs Taxable)"

  INPUT:  hazardAllowance = 9,600,000
          hazardExemptCeiling = 3,600,000  (NĐ81/2009-CP)

  ┌─────────────────────────────────────────────────────┐
  │  HAZARD_TAX_EXEMPT = min(9,600,000, 3,600,000)      │
  │                    = 3,600,000                       │
  │  ← taxExempt = true → SẼ BỊ TRỪ khỏi TAXABLE       │
  │                                                      │
  │  HAZARD_TAXABLE = max(0, 9,600,000 - 3,600,000)     │
  │                 = 6,000,000                          │
  │  ← taxExempt = false → KHÔNG TRỪ → còn trong gross │
  └─────────────────────────────────────────────────────┘

  → INSERT 2 facts vào Working Memory
  → Console: [HAZARD_SPLIT] EMP-004: Total=9,600,000,
             Exempt=3,600,000, Taxable=6,000,000 ← PHẢI CHỊU THUẾ!
```

#### ▶ Stage 6 | executionOrder: 6 — Gross Salary

```
RULE: DOC_007 "Aggregate Gross Salary Doctor"

  FORMULA: PRORATED_SALARY + SENIORITY + MEDICAL_PROF
         + HAZARD_TAX_EXEMPT + HAZARD_TAXABLE  ← TOÀN BỘ hazard!
         + POSITION + DUTY_FLAT + DUTY_OT
         + OT_150 + OT_200 + OT_300

         = 32,000,000          (prorated, full month)
         +  4,800,000          (seniority, 15 năm)
         +  3,369,960          (medical prof, CK2)
         +  3,600,000          (hazard exempt part)
         +  6,000,000          (hazard taxable part) ← 6M đây!
         +  8,000,000          (position, Trưởng khoa)
         +    405,000          (duty flat, 2 ca)
         +  2,461,538          (duty OT, ca CN)
         +          0          (OT_150 = 0)
         +          0          (OT_200 = 0, không OT thường)
         +          0          (OT_300 = 0)

GROSS_SALARY = 60,636,498 VNĐ
```

#### ▶ Stage 7 | executionOrder: 7 — BHXH Base

```
RULE: VN_SI_002 "Calculate BHXH Base"

  FORMULA: min(60,636,498, 46,800,000)

  ╔══════════════════════════════════════════════╗
  ║  BHXH_BASE = 46,800,000  ← BỊ CAP!         ║
  ║  GROSS (60.6M) > BHXH ceiling (46.8M)       ║
  ║  → Dù lương cao, BHXH chỉ tính trên 46.8M  ║
  ╚══════════════════════════════════════════════╝
```

#### ▶ Stage 8 | executionOrder: 8 — Social Insurance

```
RULE: VN_SI_003-009

  BHXH_EMPLOYEE = 46,800,000 × 8%    = 3,744,000
  BHYT_EMPLOYEE = 46,800,000 × 1.5%  =   702,000
  BHTN_EMPLOYEE = 46,800,000 × 1%    =   468,000
                                        ─────────
  TOTAL NV ĐÓNG                       = 4,914,000

  BHXH_EMPLOYER = 46,800,000 × 17.5% = 8,190,000  (thông tin)
  BHYT_EMPLOYER = 46,800,000 × 3%    = 1,404,000  (thông tin)
  BHTN_EMPLOYER = 46,800,000 × 1%    =   468,000  (thông tin)
  TNLD_EMPLOYER = 46,800,000 × 0.5%  =   234,000  (thông tin)
```

#### ▶ Stage 9 | executionOrder: 9 — ⭐ Taxable Income (3 lớp miễn thuế) ⭐

```
RULE: VN_PIT_002 "Taxable Income Doctor (3-layer Tax Exempt)"

  ┌──────────────────────────────────────────────────────────────┐
  │ TAXABLE_INCOME = GROSS                                       │
  │   − MEDICAL_PROF_ALLOWANCE  (Layer 1: miễn TOÀN BỘ)        │
  │   − HAZARD_TAX_EXEMPT       (Layer 2: miễn phần ≤ 3.6M)    │
  │   [HAZARD_TAXABLE = 6M KHÔNG trừ → ĐÃ nằm trong GROSS]     │
  │   − BHXH_EMPLOYEE                                           │
  │   − BHYT_EMPLOYEE                                           │
  │   − BHTN_EMPLOYEE                                           │
  │   − PERSONAL_DEDUCTION (11,000,000)                         │
  │   − DEPENDENT_DEDUCTION (2 × 4,400,000 = 8,800,000)        │
  └──────────────────────────────────────────────────────────────┘

  Tính:
    60,636,498
  −  3,369,960  [medProf: full exempt]
  −  3,600,000  [hazardExempt: phần miễn]
  ◀  6,000,000  [hazardTaxable: KHÔNG trừ, đã trong gross]
  −  3,744,000  [bhxh]
  −    702,000  [bhyt]
  −    468,000  [bhtn]
  − 11,000,000  [personal deduction]
  −  8,800,000  [dependent: 2 người]
  ─────────────
  = 28,952,538

  TAXABLE_INCOME = 28,952,538 VNĐ  ← Bậc 4 (18M–32M)
```

#### ▶ Stage 10 | executionOrder: 10 — PIT Tax

```
RULE: VN_PIT_004 "Calculate PIT Tax (7-bracket Progressive)"

  TAXABLE_INCOME = 28,952,538

  progressiveTax(28,952,538, VN_7_BRACKETS):
  ┌────────────────────────────────────────────────────┐
  │ Bậc 1: min(28.95M, 5M) − 0   = 5,000,000 × 5%   │
  │                                = 250,000           │
  │ Bậc 2: min(28.95M,10M) − 5M  = 5,000,000 × 10%  │
  │                                = 500,000           │
  │ Bậc 3: min(28.95M,18M) − 10M = 8,000,000 × 15%  │
  │                                = 1,200,000         │
  │ Bậc 4: 28,952,538 − 18M      = 10,952,538 × 20%  │
  │                                = 2,190,508         │
  │ Bậc 5: 28.95M < 32M → = 0                         │
  └────────────────────────────────────────────────────┘
  TỔNG PIT = 250,000 + 500,000 + 1,200,000 + 2,190,508
           = 4,140,508 VNĐ

  PIT_TAX = 4,140,508
```

#### ▶ Stage 11 | executionOrder: 11 — Net Salary

```
RULE: VN_NET_001 "Calculate Net Salary"

  NET_SALARY = 60,636,498
             −  3,744,000  [BHXH]
             −    702,000  [BHYT]
             −    468,000  [BHTN]
             −  4,140,508  [PIT]
             ─────────────
             = 51,581,990 VNĐ
```

### Tóm Tắt EMP-004

| Element | Giá trị | Ghi chú |
|---------|---------|---------|
| GROSS | 60,636,498 | Bao gồm 6M hazard chịu thuế |
| BHXH_BASE | **46,800,000** | **CAP — gross vượt ceiling** |
| BHXH+BHYT+BHTN | 4,914,000 | Tính trên ceiling, không trên gross full |
| TAXABLE | 28,952,538 | Sau 3 lớp miễn + giảm trừ |
| PIT | 4,140,508 | Bậc 4, thuế suất max 20% |
| **NET** | **51,581,990** | Lương thực nhận |

---

## CASE 2: EMP-006 — Vũ Thị Lan (Công Nhân Luân Ca 3 Ca)

### Input Data

```
employeeId:   EMP-006
group:        WORKER
period:       2025-03
baseSalary:   6,500,000   ← Dùng cho BHXH + floor check + night allowance
shiftPattern: ROTATING_3_SHIFT
productCode:  ASM-TYPE-B
seniorityYears: 4.5 năm
dependents:   1

ProductionRecord:
  totalProduced:  390 cụm
  qualityPassed:  383 cụm
  qualityFailed:  7 cụm
  qualityRate:    383/390 = 98.21%

ShiftSchedule (tuần):
  Tuần 1: CA_SANG (06-14h) × 5 ngày  → nightShiftCount: 0
  Tuần 2: CA_CHIEU (14-22h) × 6 ngày → nightShiftCount: 0
  Tuần 3: CA_DEM (22-06h) × 6 ngày   → nightShiftCount: 6  ← Đầu ca ≥22h
  Tuần 4: CA_SANG × 5 ngày           → nightShiftCount: 0
  Tu5 partial: CA_CHIEU × 4 ngày     → nightShiftCount: 0

Overtime:
  16/03 (Chủ nhật) — CA_DEM — 8h OT — multiplier 2.0
```

---

### Step-by-Step Execution

#### ▶ Pre-Stage | salience: 300 — Pre-processing Ca Đêm

```
RULE: WRK_PRE_001 "Pre-process Night Shift Count"
  (agenda-group "pre-payroll-worker", salience=300)

  ALGORITHM:
    for each week in shiftSchedule:
      if shiftType == "CA_DEM": count += workDays

    Tuần 1 (CA_SANG): 0
    Tuần 2 (CA_CHIEU): 0
    Tuần 3 (CA_DEM): +6  ← shiftStart="22:00" ≥ "22:00" → CA_DEM
    Tuần 4 (CA_SANG): 0
    Tuần 5 (CA_CHIEU): 0

  INSERT NightShiftFact(employeeId="EMP-006", nightShiftCount=6)

  Console: [PRE] EMP-006 nightShiftCount = 6
  ← Fact này sẽ được WRK_003 đọc sau
```

#### ▶ Stage 2 | executionOrder: 2 — Piece-Rate Salary

```
RULE: WRK_001 "Piece Rate Salary"

  INPUT:  qualityPassedQuantity = 383
          unitPrice(ASM-TYPE-B) = 18,500 VNĐ/cụm

  FORMULA: 383 × 18,500

  PIECE_RATE_SALARY = 7,085,500 VNĐ
  ← Chỉ tính cụm ĐẠT chất lượng (7 cụm lỗi bị loại)
```

#### ▶ Stage 3 | executionOrder: 3 — Quality Bonus + Night Allowance + Seniority

```
RULE: WRK_002 "Quality Bonus (Tier + Penalty)"

  INPUT:  qualityRate = 383/390 = 0.9821 (98.21%)

  LOOKUP tier:
    0.9821 ≥ 0.98 → Tier 1: +5%

  FORMULA: 7,085,500 × 0.05 = 354,275

  QUALITY_BONUS = +354,275 VNĐ  ← BONUS (không phải penalty)

──────────────────────────────────────────────────

RULE: WRK_003 "Night Shift Allowance (30%)"

  INPUT:  NightShiftFact(employeeId="EMP-006", count=6) ← từ pre-processing
          baseSalary = 6,500,000
          standardWorkDays = 26

  dailyRate = 6,500,000 ÷ 26 = 250,000 VNĐ/ngày

  FORMULA: 6 × 250,000 × 0.30
         = 6 × 75,000

  NIGHT_SHIFT_ALLOWANCE = 450,000 VNĐ
  ← 30% lương ngày × 6 ca đêm (theo BLLĐ 2019 Điều 98)

──────────────────────────────────────────────────

RULE: COMMON "Seniority Allowance"

  FORMULA: min(4.5 × 0.01, 0.15) × 6,500,000
         = 0.045 × 6,500,000

  SENIORITY_ALLOWANCE = 292,500 VNĐ
```

#### ▶ Stage 4 | executionOrder: 4 — OT Ca Đêm Cuối Tuần (2 khoản)

```
OT Chủ nhật 16/03 — CA_DEM — 8 giờ
  → 2 rules kích hoạt độc lập:

RULE: WRK_004 "OT 200% Weekend/Holiday"

  hourlyRate = 6,500,000 ÷ 26 ÷ 8 = 31,250 VNĐ/giờ

  FORMULA: 31,250 × 8h × 2.0

  OT_200 = 500,000 VNĐ
  ← OT ngày nghỉ tuần (BLLĐ 2019 Điều 98: ≥200%)

──────────────────────────────────────────────────

RULE: WRK_005 "Night OT Premium (30% extra for night OT shift)"

  INPUT:  hasNightOT = true (Chủ nhật ca đêm trong attendance)

  FORMULA: 31,250 × 8h × 0.30

  NIGHT_OT_PREMIUM = 75,000 VNĐ
  ← 30% bổ sung cho giờ OT ca đêm
  ← Tách riêng OT_200 → audit trail rõ: "được bao nhiêu OT + được bao nhiêu ca đêm"

  ╔═══════════════════════════════════════════════════╗
  ║  OT ca đêm Chủ nhật = OT_200 + NIGHT_OT_PREMIUM ║
  ║  = 500,000 + 75,000 = 575,000 VNĐ               ║
  ║  (2 elements riêng, không phải 1)                 ║
  ╚═══════════════════════════════════════════════════╝
```

#### ▶ Stage 6 | executionOrder: 6 — Gross + Floor Enforcement

```
RULE: WRK_006 "Raw Gross Calculation (pre-floor)"

  RAW = PIECE_RATE + QUALITY_BONUS + SENIORITY
      + NIGHT_SHIFT_ALLOWANCE + OT_200 + NIGHT_OT_PREMIUM
      = 7,085,500 + 354,275 + 292,500 + 450,000 + 500,000 + 75,000
      = 8,757,275

  INSERT TemporaryFact("RAW_GROSS", 8,757,275)

──────────────────────────────────────────────────

RULE: WRK_007 "Worker Gross Floor Enforcement (Min Wage Zone 1)"

  INPUT:  rawGross = 8,757,275
          REGIONAL_MIN_WAGE_ZONE1 = 4,960,000

  FORMULA: max(8,757,275, 4,960,000)

  ╔══════════════════════════════════════════════════╗
  ║  GROSS_SALARY = 8,757,275                        ║
  ║  Floor NOT applied (8.76M > 4.96M min wage ✓)   ║
  ╚══════════════════════════════════════════════════╝

  GROSS_SALARY = 8,757,275 VNĐ

  [TEST CASE — nếu SP giảm mạnh]:
  Giả sử: qualityPassed=200 → PIECE_RATE=3,700,000
  rawGross ≈ 3,700,000 + ... ≈ 4,200,000 < 4,960,000
  → GROSS_SALARY = 4,960,000 (floor applied, flag inserted)
```

#### ▶ Stage 7-8 | executionOrder: 7-8 — BHXH

```
BHXH_BASE = min(8,757,275, 46,800,000) = 8,757,275
  ← Không bị cap (dưới ceiling)
  ← NOTE: Nếu floor được áp → BHXH_BASE tính trên 4,960,000 (không phải raw 4.2M)

BHXH_EMPLOYEE = 8,757,275 × 8%    = 700,582
BHYT_EMPLOYEE = 8,757,275 × 1.5%  = 131,359
BHTN_EMPLOYEE = 8,757,275 × 1%    =  87,573
─────────────────────────────────────────────
TOTAL SI NV   =                     919,514
```

#### ▶ Stage 9-10 | executionOrder: 9-10 — Taxable Income & PIT

```
RULE: VN_PIT_003 "Taxable Income Worker"

  TAXABLE = max(0,
    8,757,275
  −   919,514   [SI tổng]
  − 11,000,000  [personal deduction]
  −  4,400,000  [1 người phụ thuộc]
  )
  = max(0, −7,562,239)
  = 0

  TAXABLE_INCOME = 0 VNĐ

  PIT_TAX = 0 VNĐ
  ← Dù có ca đêm, OT, piece-rate… vẫn không đến ngưỡng đóng thuế
  ← Lý do: Giảm trừ gia cảnh 15.4M > thu nhập ròng 7.8M
```

#### ▶ Stage 11 — Net Salary

```
NET_SALARY = 8,757,275 − 919,514 − 0
           = 7,837,761 VNĐ
```

### Tóm Tắt EMP-006

| Element | Giá trị | Ghi chú |
|---------|---------|---------|
| PIECE_RATE | 7,085,500 | 383 cụm × 18,500 |
| QUALITY_BONUS | +354,275 | +5% Tier 1 (≥98%) |
| SENIORITY | 292,500 | 4.5 năm |
| NIGHT_SHIFT | 450,000 | 6 ca đêm × 75,000/ca |
| OT_200 | 500,000 | Chủ nhật ca đêm × 200% |
| NIGHT_OT_PREMIUM | 75,000 | +30% phần OT ca đêm |
| **GROSS** | **8,757,275** | **Floor check: > min wage ✓** |
| BHXH_BASE | 8,757,275 | Không bị cap |
| SI deductions | 919,514 | 10.5% × BHXH_BASE |
| TAXABLE | 0 | Thấp hơn ngưỡng đóng thuế |
| PIT | 0 | Không chịu thuế TNCN |
| **NET** | **7,837,761** | |

---

## So Sánh 2 Cases

| Tiêu chí | EMP-004 (Bác sỹ) | EMP-006 (Công nhân) |
|---------|-----------------|---------------------|
| **GROSS rule type** | Fixed-base aggregate | Piece-rate + floor check |
| **Intermediate facts** | 2 (hazard split) | 2 (rawGross temp + nightShiftFact) |
| **Tax-exempt layers** | 3 | 0 |
| **Pre-processing rules** | 0 | 1 (ca đêm count) |
| **2-khoản OT** | DUTY_FLAT + DUTY_OT | OT_200 + NIGHT_OT_PREMIUM |
| **BHXH capped?** | ✅ YÊS (60.6M > 46.8M) | ❌ No |
| **PIT** | 4,140,508 (bậc 4) | 0 (dưới ngưỡng) |
| **NET / GROSS ratio** | 85.1% | 89.5% |
| **Rules triggered** | 10 rules | 13 rules (+1 pre-processing) |

---

## Verification Checklist (cho QA/Engineer)

Khi implement engine, kiểm tra các điểm này với data EMP-004 và EMP-006:

```
□ EMP-004: HAZARD_ALLOWANCE = 9,600,000 (30% × 32M)
□ EMP-004: HAZARD_TAX_EXEMPT = 3,600,000 (capped at ceiling)
□ EMP-004: HAZARD_TAXABLE = 6,000,000 (NOT zero!)
□ EMP-004: GROSS bao gồm cả 3.6M + 6M hazard
□ EMP-004: TAXABLE_INCOME không trừ 6M hazard_taxable (vẫn trong gross)
□ EMP-004: BHXH_BASE = 46,800,000 (cap, không phải 60.6M)
□ EMP-004: PIT = 4,140,508 (bậc 4 tối đa → 28.95M < 32M không sang bậc 5)

□ EMP-006: nightShiftCount = 6 (đếm CA_DEM theo đầu ca, không phải giờ kết thúc)
□ EMP-006: NIGHT_SHIFT_ALLOWANCE = 450,000 (6 × 75,000)
□ EMP-006: OT_200 = 500,000 (8h × 31,250 × 2.0)
□ EMP-006: NIGHT_OT_PREMIUM = 75,000 (8h × 31,250 × 0.30) — tồn tại là element riêng
□ EMP-006: GROSS = 8,757,275 (floor check: > 4,960,000 → không bị floor)
□ EMP-006: TAXABLE = 0 (không đến ngưỡng)
□ EMP-006: NET = 7,837,761
```
