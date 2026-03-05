# Core Compensation

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-05  
**Đối tượng**: HR Administrator, Compensation Manager  
**Đọc ~25 phút**

---

## Tổng quan

Core Compensation là sub-module nền tảng của TR — định nghĩa **cách tổ chức trả lương**: từ tần suất, tiền tệ, các thành phần cấu thành, cấu trúc cấp bậc, đến việc quản lý toàn bộ vòng đời điều chỉnh lương của từng nhân viên.

Triết lý thiết kế: **Component-Based Architecture** — lương không phải một con số, mà là tổng hợp của các thành phần có thể cấu hình linh hoạt.

```
Salary Basis  →  Pay Components  →  Employee Compensation
     +                                       ↑
Grade System  →  Pay Ranges      ────────────┘
     +
Comp Cycle    →  Adjustments    →  Snapshots (History)
```

---

## 1. Salary Basis — Template cách trả lương

**Salary Basis** là template định nghĩa HOW nhân viên được trả lương: tần suất, tiền tệ, quy tắc tính toán toàn quốc gia.

### Các tần suất được hỗ trợ
| Frequency | Code | Điển hình |
|-----------|------|-----------|
| Monthly | MONTHLY | VN, SG (phổ biến nhất) |
| Hourly | HOURLY | US part-time, contract |
| Daily | DAILY | Daily workers, casual |
| Weekly | WEEKLY | US hourly workers |
| Biweekly | BIWEEKLY | US standard |
| Semi-monthly | SEMIMONTHLY | US mid-month/end-month |
| Annual | ANNUAL | Executive packages |

### Cấu hình ví dụ

```yaml
Vietnam Monthly Salary Basis (MONTHLY_VN):
  Frequency: Monthly
  Currency: VND
  Working Days/Month: 26
  Standard Hours/Month: 208
  Overtime Multiplier: 1.5
  Proration Method: Calendar Days
  Country Rules:
    - SI contribution caps apply
    - Lunch allowance partial tax exemption: 730,000 VND/month
```

### Nguyên tắc thiết kế
- Tạo **Salary Basis riêng cho từng quốc gia** — mỗi country có quy tắc thuế/SI khác nhau
- Tạo **basis riêng cho từng loại nhân viên** (full-time vs hourly vs contractor)
- Version basis theo năm khi có thay đổi cấu trúc (không sửa basis đang active)

---

## 2. Pay Components — Building blocks của lương

**Pay Components** là các thành phần cấu thành lương — mỗi component có loại, cách tính thuế và quy tắc proration riêng.

### 6 loại Pay Component

| Loại | Mô tả | Ví dụ | Thuế |
|------|-------|-------|------|
| **BASE** | Lương cơ bản | Base Salary, Hourly Wage | Toàn bộ |
| **ALLOWANCE** | Phụ cấp thường xuyên | Lunch, Transportation, Housing | Tùy loại |
| **BONUS** | Thưởng hiệu suất | Annual Bonus, Spot Bonus | Toàn bộ |
| **EQUITY** | Thu nhập từ cổ phiếu | RSU, Stock Options | Khi vest |
| **DEDUCTION** | Khấu trừ | Loan repayment, Garnishment | Không |
| **OVERTIME** | Giờ làm thêm | OT 1.5x, Weekend 2x | Toàn bộ |

### Tax Treatment

```yaml
Fully Taxable (BASE):
  Tax Treatment: FULLY_TAXABLE
  Subject to SI: Yes
  Ví dụ: Base Salary, Transportation Allowance

Partially Exempt (VN Lunch Allowance):
  Tax Treatment: PARTIALLY_EXEMPT
  Tax Exempt Threshold: 730,000 VND/month
  Subject to SI: No
  → Phần vượt 730K mới tính thuế

Fully Exempt:
  Tax Treatment: TAX_EXEMPT
  Subject to SI: No
  Ví dụ: Employer SI contribution
```

### Ví dụ bộ Pay Components Vietnam tiêu chuẩn

| Component | Loại | Thuế | SI | Proration |
|-----------|------|------|----|-----------|
| Base Salary | BASE | Fully taxable | Yes (capped 36M) | Calendar days |
| Lunch Allowance | ALLOWANCE | Partially exempt (730K) | No | Working days |
| Transportation | ALLOWANCE | Fully taxable | No | Working days |
| Housing Allowance | ALLOWANCE | Fully taxable | No | **Không prorate** |
| Annual Bonus | BONUS | Fully taxable | No | N/A |

> **Lưu ý**: Housing Allowance thường không prorate — full month hoặc không có. Điều này thể hiện tính linh hoạt: mỗi component có quy tắc proration độc lập.

---

## 3. Grade System — Cấu trúc cấp bậc và Career Ladder

### Khái niệm cơ bản

```
Career Ladder (đường thăng tiến)
    │
    ├── Grade G1 (Junior)   →  Pay Range: Min - Mid - Max
    ├── Grade G2 (Mid)      →  Pay Range: Min - Mid - Max
    ├── Grade G3 (Senior)   →  Pay Range: Min - Mid - Max
    ├── Grade G4 (Principal) → Pay Range: Min - Mid - Max
    └── Grade G5 (Staff)    →  Pay Range: Min - Mid - Max
```

### 5 loại Career Ladder được hỗ trợ

| Ladder | Mục đích | Điển hình |
|--------|---------|-----------|
| **Technical** | IC track — kỹ thuật thuần | G1→G2→G3→G4→G5 (Junior→Staff Engineer) |
| **Management** | Mgmt track | M1→M2→M3→M4→M5 (Team Lead→CTO) |
| **Specialist** | Expert không quản lý | Data Scientist, UX Designer |
| **Sales** | Sales & Business Dev | BDR→AE→Senior AE→Sales Manager |
| **Executive** | C-level | Director→VP→SVP→C-Suite |

> Nhân viên có thể **chuyển ngang** giữa các ladder (ví dụ: Senior Engineer G3 → Engineering Manager M1) mà không mất lịch sử career.

### SCD Type 2 — Lịch sử Grade bất biến

Grade dùng **Slowly Changing Dimension Type 2**: mỗi khi grade thay đổi, record cũ được đóng (end_date) và record mới được tạo — không bao giờ overwrite.

```yaml
# Alice — lịch sử grade
GradeVersion #1: G2, start: 2022-01-01, end: 2023-06-30  [đã đóng]
GradeVersion #2: G3, start: 2023-07-01, end: null         [hiện tại]
```

**Kết quả**: Hệ thống luôn biết Alice ở Grade G2 vào ngày 2022-03-15, ở G3 vào hôm nay — phục vụ audit, retroactive calculation, và reporting chính xác.

---

## 4. Pay Range — Dải lương theo 4 cấp scope

**Pay Range** định nghĩa min–mid–max salary cho một grade. Điểm then chốt: có thể định nghĩa nhiều range cho cùng một grade ở các scope khác nhau — hệ thống luôn dùng **scope cụ thể nhất có sẵn**.

### 4 Scope Levels (ưu tiên giảm dần)

```
Priority 1: POSITION   (vị trí cụ thể — cụ thể nhất)
Priority 2: BUSINESS_UNIT   (phòng ban)
Priority 3: LEGAL_ENTITY    (công ty thành viên / quốc gia)
Priority 4: GLOBAL          (mặc định toàn cầu)
```

### Ví dụ thực tế — Grade G7

```yaml
Global (fallback):
  G7 Global: Min $80K - Mid $100K - Max $120K USD

Vietnam (VNG Corp):
  G7 VN: Min 100M - Mid 130M - Max 160M VND

Engineering BU (market rate cao hơn):
  G7 Engineering: Min 110M - Mid 140M - Max 170M VND

Critical Position (Architect role):
  G7 Architect-001: Min 140M - Mid 170M - Max 200M VND
```

**Resolution cho Alice** (vị trí Architect, BU Engineering, Legal Entity VN):
→ Tìm scope POSITION cho Architect-001 → Tìm thấy! → Dùng **140M - 170M - 200M**

**Resolution cho Bob** (Job-based, BU Engineering, không có position cụ thể):
→ Không có POSITION scope → Tìm BU Engineering → Tìm thấy! → Dùng **110M - 140M - 170M**

### Compa-Ratio

```
Compa-Ratio = Employee Salary / Grade Midpoint × 100

< 80%: Below market  — cần review ngay
80-90%: Learning zone  — mới vào grade
90-110%: Target zone  — hoàn toàn competent
> 120%: Above range  — top performer, ít room tăng
```

**Ứng dụng**: Compa-ratio là đầu vào quan trọng cho Merit Matrix — nhân viên dưới midpoint được khuyến nghị tăng nhiều hơn.

---

## 5. Compensation Cycle — Vòng đời điều chỉnh lương

### 5 loại Compensation Cycle

| Loại | Mục đích | Tần suất |
|------|---------|---------|
| **Merit Review** | Tăng lương hiệu suất | Hàng năm (Q1 hoặc Q4) |
| **Promotion** | Thăng cấp grade | Khi phát sinh |
| **Market Adjustment** | Điều chỉnh theo thị trường | Hàng năm mid-year |
| **New Hire** | Lương cho nhân viên mới | Khi tuyển dụng |
| **Equity Correction** | Sửa bất bình đẳng lương | Ad-hoc |

### Merit Review Cycle — 4 giai đoạn

```
PHASE 1: Planning
  HR tạo CompensationPlan (Merit Matrix + eligibility rules)
  HR tạo CompensationCycle (period, effective date, budget)
  HR phân bổ budget theo phòng ban
  HR mở cycle (DRAFT → OPEN)

PHASE 2: Proposals
  Manager xem danh sách nhân viên eligible
  Manager đề xuất tăng lương (phải trong merit matrix)
  Hệ thống validate budget real-time:
    Annual Impact = (New - Current) × 12
    Valid nếu Annual Impact ≤ Remaining Budget

PHASE 3: Approvals (tự động routing)
  Tăng 0-5%:   Manager tự phê duyệt (auto)
  Tăng 5-10%:  Route → Director
  Tăng > 10%:  Route → VP
  Off-cycle:   Luôn cần → CHRO

PHASE 4: Finalization
  HR đóng cycle (OPEN → CLOSED)
  Hệ thống tạo EmployeeCompensationSnapshot cho từng approval
  Cập nhật compensation nhân viên (effective date)
  Ghi SalaryHistory entry
  Gửi notification đến nhân viên
```

### Budget Tracking Real-time

```
Engineering Dept:
  Allocated:  2,000,000,000 VND
  Proposed:   1,850,000,000 VND  (92.5%) 🟡 Approaching
  Approved:     900,000,000 VND  (45%)
  Remaining:  1,100,000,000 VND

Alerts:
  🟢 < 90% utilization  → Healthy
  🟡 90-100%            → Approaching limit, review carefully
  🔴 > 100%             → Over budget, blocked
```

### Merit Matrix Guidelines

| Performance | Compa-Ratio < 90% | Compa-Ratio 90-110% | Compa-Ratio > 110% |
|------------|:-----------------:|:-------------------:|:-------------------:|
| Outstanding | 8-12% | 6-10% | 4-6% |
| Exceeds | 6-10% | 5-8% | 3-5% |
| Meets | 4-7% | 3-6% | 2-4% |
| Below | 0-2% | 0% | 0% |

*Merit Matrix là gợi ý — Manager có thể đề xuất ngoài range nhưng cần approval cao hơn.*

---

## 6. CO Module Integration

Core Compensation tích hợp chặt với **CO (Core HR)** module để lấy thông tin về nhân viên, job, và grade.

```
CO Module                              TR Module
─────────                              ─────────
Assignment → Position → Job ─────────→ GradeVersion (by grade_code)
                              grade       └──→ PayRange (scope resolution)
                              code           └──→ EmployeeCompensation
```

### Quy tắc quan trọng

> **TR.GradeVersion là nguồn dữ liệu chính xác về grade** — không phải Core.JobGrade (deprecated). Core module dùng `grade_code` để tham chiếu sang TR.GradeVersion.

### Position-Based vs Job-Based Staffing

| Khía cạnh | Position-Based | Job-Based |
|-----------|:-------------:|:---------:|
| Pay range scope tốt nhất | POSITION (cụ thể nhất) | BUSINESS_UNIT |
| Budget control | Tốt hơn (position-level) | Ít chặt hơn |
| Pay equity | Dễ quản lý | Cần thêm effort |
| Linh hoạt tuyển dụng | Ít hơn | Nhiều hơn |
| Tốc độ tuyển dụng | Chậm hơn (phê duyệt vị trí) | Nhanh hơn |

---

*Nguồn: `03-compensation-management-guide.md` (1,288 dòng) · `02-conceptual-guide.md`*  
*← [01 Executive Summary](./01-executive-summary.md) · [03 Variable Pay →](./03-variable-pay.md)*
