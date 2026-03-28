# Variable Pay

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-05  
**Đối tượng**: HR Administrator, Compensation Manager, Finance  
**Đọc ~20 phút**

---

## Tổng quan

Variable Pay quản lý tất cả các hình thức bù đắp biến động — không cố định như base salary mà thay đổi theo hiệu suất, kết quả kinh doanh, hoặc các sự kiện cụ thể (vesting, quota attainment).

Ba lĩnh vực chính:

```
Variable Pay
├── 1. Bonus Programs   (STI / LTI / Spot / Retention / Sign-On)
├── 2. Equity           (RSU / Stock Options / ESPP + Vesting)
└── 3. Commissions      (Flat / Tiered / Accelerator)
```

**Variable Pay Mix theo cấp bậc** (điển hình):

| Cấp bậc | Fixed | Variable | Breakdown |
|---------|------:|--------:|-----------|
| Entry (G1-G2) | 90% | 10% | STI only |
| Mid (G3-G4) | 85% | 15% | STI + nhỏ LTI |
| Senior (G5-M2) | 75% | 25% | STI + LTI |
| Executive (M3+) | 60% | 40% | STI + LTI + Equity |

---

## 1. Bonus Programs

### 6 loại Bonus được hỗ trợ

| Loại | Mục đích | Kỳ trả | Điển hình |
|------|---------|--------|-----------|
| **STI** (Short-Term Incentive) | Thưởng hiệu suất năm | Hàng năm | 10-20% annual salary |
| **LTI** (Long-Term Incentive) | Giữ chân dài hạn | 2-4 năm | 20-40% của salary |
| **Spot Bonus** | Ghi nhận ad-hoc tức thì | Ngay lập tức | Fixed amount (vd: 5M VND) |
| **Retention Bonus** | Giữ chân nhân tài then chốt | Cliff vesting 1-2 năm | Negotiated |
| **Sign-On Bonus** | Thu hút ứng viên | Khi ký hợp đồng | Negotiated |
| **Sales Commission** | Thưởng doanh số | Hàng tháng/quý | % của revenue |

### Bonus Cycle — 4 giai đoạn

```
PHASE 1: Setup
  HR tạo BonusPlan + BonusCycle
  Phân bổ budget pool theo Legal Entity / Department
  Mở cycle (DRAFT → OPEN)

PHASE 2: Manager Proposals
  Manager xem danh sách nhân viên eligible
  Đề xuất bonus dựa trên formula + discretion
  
PHASE 3: Approvals
  < 10M VND:  Manager tự phê duyệt
  10-20M VND: Director approval
  > 20M VND:  VP approval

PHASE 4: Payout
  HR đóng cycle (OPEN → APPROVED)
  Generate payout file → Payroll
  Thông báo đến nhân viên
  Process payment
```

### Bonus Formula — Tính tự động

```
Bonus = Annual Salary × Target% × Performance Multiplier × Company Multiplier
```

**Performance Multiplier:**

| Rating | Multiplier | % Population |
|--------|:----------:|:------------:|
| Outstanding (5) | 1.5× | 5-10% |
| Exceeds (4) | 1.2× | 20-25% |
| Meets (3) | 1.0× | 60-65% |
| Below (2) | 0.5× | 5-10% |
| Unsatisfactory (1) | 0× | 0-5% |

**Company Multiplier** — dựa trên kết quả kinh doanh:

```yaml
< 80% achievement:   0.8×
80-90%:              0.9×
90-100%:             1.0×
100-110%:            1.1×
> 110%:              1.2×
```

**Ví dụ tính thực tế:**

```
Alice (Outstanding performance, Company đạt 110%):
  Salary: 60,000,000 VND
  Target: 15%
  Performance: 1.5 (Outstanding)
  Company: 1.1
  → Bonus = 60M × 15% × 1.5 × 1.1 = 14,850,000 VND

Bob (Meets performance, cùng Company multiplier):
  Salary: 50,000,000 VND
  Target: 15%
  Performance: 1.0
  Company: 1.1
  → Bonus = 50M × 15% × 1.0 × 1.1 = 8,250,000 VND
```

### Budget Pool Management

```
Vietnam Pool (STI 2025):
  Allocated:   5,000,000,000 VND
  Proposed:    4,800,000,000 VND  🟡 96%
  Approved:    4,500,000,000 VND
  Remaining:     500,000,000 VND

Status indicators:
  🟢 < 90%  — Còn room
  🟡 90-100% — Approaching limit
  🔴 > 100% — Over, cần CFO approval
```

---

## 2. Equity Compensation

### 3 loại Equity Grant

#### RSU (Restricted Stock Units)

```yaml
Là gì: Công ty trao cổ phiếu, vest theo thời gian
Tax event: Khi vest — FMV × số cổ phiếu = taxable income
Risk: Thấp (luôn có giá trị nếu công ty còn giá trị)

Ví dụ:
  Grant: 1,000 RSU, ngày 2025-01-01
  FMV lúc grant: 100,000 VND/unit
  Vesting: 25% mỗi năm trong 4 năm

  Year 1 vest (2026-01-01):
    Units vested: 250
    FMV tại ngày vest: 120,000 VND
    Taxable income: 250 × 120,000 = 30,000,000 VND
    → Tạo TaxableItem → Bridge sang Payroll → Khấu trừ thuế
```

#### Stock Options

```yaml
Là gì: Quyền mua cổ phiếu ở mức giá cố định (strike price)
Tax event: Khi EXERCISE — (FMV - Strike Price) × units = taxable income
Risk: Cao hơn (có thể "underwater" nếu FMV < strike price)

Ví dụ:
  Grant: 5,000 options, strike price: 80,000 VND
  FMV lúc vest: 150,000 VND/unit
  Exercise 1,000 options:
    Exercise cost: 1,000 × 80,000 = 80,000,000 VND
    Market value:  1,000 × 150,000 = 150,000,000 VND
    Taxable gain:  70,000,000 VND
```

#### ESPP (Employee Stock Purchase Plan)

```yaml
Là gì: Nhân viên mua cổ phiếu công ty với giá ưu đãi (thường discount 10-15%)
Phổ biến ở: US companies
```

### Vesting Schedules — 3 kiểu phổ biến

```
4-Year with 1-Year Cliff (phổ biến nhất):
  Year 1 (cliff):    25% vests
  Year 2-4:          Monthly vesting (6.25%/quarter)

Accelerated 3-Year:
  Year 1: 33.33%
  Year 2: 33.33%
  Year 3: 33.33%

Performance-Based:
  Vest khi đạt performance milestone (IPO, acquisition, goal)
```

### Vesting Event Processing — Tự động hoàn toàn

```
Batch job chạy hàng ngày:
  For each EquityVestingEvent where vest_date <= today:
    1. Update status: SCHEDULED → VESTED
    2. Calculate vested quantity
    3. Fetch FMV on vest date
    4. Calculate taxable income (RSU: units × FMV)
    5. Create TaxableItem
    6. Bridge TaxableItem → Payroll module
    7. Notify employee

Payroll nhận TaxableItem:
    - Thêm vào paycheck kỳ tiếp theo
    - Tính withholding (federal + state + FICA)
    - Khấu trừ từ paycheck hoặc sell-to-cover
```

### Accelerated Vesting & Forfeiture

```yaml
Accelerated Vesting (triggers):
  - Company acquisition / IPO: Tất cả unvested → vest ngay
  - Termination (Good Leaver): 50-100% acceleration (per plan rules)
  - Death / Disability: Full acceleration

Forfeiture (Bad Leaver):
  - Vested units: Nhân viên giữ lại (đã owned)
  - Unvested units: FORFEIT về lại pool
  
EquityTransaction types:
  VEST    — shares vested
  EXERCISE — options exercised
  SELL    — shares sold
  TRANSFER — shares transferred
  FORFEIT — unvested shares forfeited
```

---

## 3. Sales Commission Plans

### 3 cấu trúc Commission phổ biến

#### Flat Rate — Đơn giản

```
Rate cố định cho mọi mức doanh số
Example: 5% of all revenue

Revenue 100M VND × 5% = Commission 5M VND

Pros: Dễ hiểu, dễ tính
Cons: Không khuyến khích exceed quota
```

#### Tiered Commission — Phổ biến nhất

```
Rate khác nhau ở mỗi tier doanh số
Example:  0-100% quota:  3%
         100-120% quota: 5%
         120%+ quota:    7%

Revenue 130M VND (Quota = 100M VND, Achievement 130%):
  Tier 1: 100M × 3% = 3,000,000
  Tier 2:  20M × 5% = 1,000,000
  Tier 3:  10M × 7% =   700,000
  Total Commission:   4,700,000 VND

Pros: Strong incentive to exceed
Cons: Phức tạp hơn, cần communicate rõ
```

#### Accelerator — Phổ biến ở Tech/SaaS

```
Rate thấp hơn below quota, cao hơn above quota
Example: Below 100%: 4% | Above 100%: 6%

Revenue 120M VND (Quota = 100M):
  First 100M: 100M × 4% = 4,000,000
  Above 100M:  20M × 6% = 1,200,000
  Total:                   5,200,000 VND
```

### Commission Processing Cycle (Monthly)

```
Step 1: Import sales data (revenue by salesperson, deal dates)
Step 2: Calculate quota achievement (Individual / Team / Territory)
Step 3: Apply commission formula → Commission Transactions
Step 4: Manager review & approval
Step 5: Export to Payroll → Pay next payroll cycle
```

### Commission Transaction Status Flow

```
PENDING → APPROVED → PAID
                ↓
           DISPUTED → ADJUSTED → APPROVED → PAID
```

---

## 4. Performance Integration

Variable Pay tích hợp với **Performance Management (PM)** module để lấy performance ratings:

```
PM Module                     TR Module
─────────                     ─────────
PerformanceRating ──────────→ BonusAllocation.performance_rating
Goal Achievement ──────────→ Performance Multiplier
Review Cycle     ──────────→ Triggers Compensation Cycle

Timeline alignment:
  Q4 Performance Reviews → Complete
  Q1 Comp Cycle Opens    → Manager dùng ratings để đề xuất bonus
  Q1 Comp Cycle Closes   → Payroll processes bonus
```

---

*Nguồn: `04-variable-pay-guide.md` (994 dòng) · `02-conceptual-guide.md` (Workflow 3: Equity Vesting)*  
*← [02 Core Compensation](./02-core-compensation.md) · [04 Benefits Administration →](./04-benefits-administration.md)*
