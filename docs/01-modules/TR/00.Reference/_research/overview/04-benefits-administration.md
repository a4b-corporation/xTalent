# Benefits Administration

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-05  
**Đối tượng**: HR Benefits Administrator, Employees  
**Đọc ~25 phút**

---

## Tổng quan

Benefits Administration quản lý toàn bộ chương trình phúc lợi nhân viên — từ cấu hình kế hoạch bảo hiểm, quản lý đăng ký, xử lý sự kiện cuộc sống, đến thanh toán bồi thường.

```
Benefits Architecture
├── 1. Plan Configuration   (BenefitPlan + BenefitOption)
├── 2. Eligibility Engine   (EligibilityProfile)
├── 3. Enrollment Mgmt      (Open Enrollment / New Hire / Life Event)
├── 4. Dependent & Beneficiary  Management
└── 5. Claims & Reimbursements
```

---

## 1. Benefit Plan Architecture

### 8 loại Benefit Plan

| Category | Mô tả | Ví dụ | Typical Coverage |
|----------|-------|-------|-----------------|
| **MEDICAL** | Bảo hiểm sức khỏe | Hospitalization, Outpatient | Employee + Family |
| **DENTAL** | Nha khoa | Preventive, Restorative | Employee + Family |
| **VISION** | Mắt | Exams, Glasses, Contacts | Employee + Family |
| **LIFE** | Bảo hiểm nhân thọ | Term Life, AD&D | Employee only |
| **DISABILITY** | Bảo vệ thu nhập | STD (6 months), LTD | Employee only |
| **RETIREMENT** | Hưu trí | 401(k), Pension | Employee only |
| **WELLNESS** | Sức khỏe tổng thể | Gym, Wellness coaching | Employee + Spouse |
| **PERK** | Lifestyle benefits | Commuter, Meals, Education | Employee only |

### 4 Coverage Tiers

| Tier | Who | Chi phí |
|------|-----|---------|
| **EMPLOYEE_ONLY** | Nhân viên | Thấp nhất |
| **EMPLOYEE_SPOUSE** | NV + Vợ/Chồng | Trung bình |
| **EMPLOYEE_CHILDREN** | NV + Con cái | Trung bình - Cao |
| **EMPLOYEE_FAMILY** | NV + Vợ/Chồng + Con | Cao nhất |

### 3 mô hình Premium Cost Sharing

```yaml
EMPLOYEE:   NV trả 100%, Employer trả 0%
            → Voluntary life insurance

EMPLOYER:   NV trả 0%, Employer trả 100%
            → Basic life insurance, mandatory benefits

SHARED:     Split tỷ lệ (vd: NV 30%, Employer 70%)
            → Medical insurance (điển hình nhất)
```

### 4 phương pháp tính Premium

**Method 1 — Fixed Premium** (đơn giản nhất):
```
Employee Only:  500,000 VND/month (NV)  + 1,500,000 (employer)
Employee+Family: 1,200,000 VND/month (NV) + 3,600,000 (employer)
```

**Method 2 — Per-Dependent Formula**:
```
Total = Base (NV) + Per_Spouse + Per_Child × count_children
Employee+Spouse+2 Children:
  2,000,000 + 1,000,000 + 500,000×2 = 4,000,000 VND total
  NV trả: 4M × 25% = 1,000,000 VND
```

**Method 3 — Age-Banded Premiums** (Life Insurance):
```
Age 18-29: rate 0.0005  → 50M coverage × 0.0005 = 25,000/month
Age 30-39: rate 0.0008  → 50M × 0.0008 = 40,000/month
Age 40-49: rate 0.0015  → 50M × 0.0015 = 75,000/month
Age 50-59: rate 0.0025  → 50M × 0.0025 = 125,000/month
```

**Method 4 — Salary-Based Premiums** (Retirement/401k):
```
Employee contributes: 6% of salary
Employer matches: 50% of employee contribution, capped at 3% of salary

Employee salary 50M/month:
  NV contributes: 50M × 6% = 3,000,000
  Employer matches: 3M × 50% = 1,500,000 (≤ 50M × 3%)
  Total: 4,500,000 VND/month
```

---

## 2. Eligibility Engine

**EligibilityProfile** là một tập rules xác định ai được đăng ký vào mỗi benefit plan. Điểm mạnh: **tái sử dụng được** — định nghĩa một lần, gắn vào nhiều plan.

### Rule Attributes được hỗ trợ

```yaml
EligibilityProfile: ELIG_FULLTIME_VN_3M
  Employment Types: [FULL_TIME]      # loại hợp đồng
  Min Tenure: 3 months               # thâm niên tối thiểu
  Locations: [VN]                    # quốc gia / địa điểm
  Grades: All                        # cấp bậc được tham gia
  Business Units: All                # phòng ban được tham gia
  Exclude Probation: Yes             # không áp dụng khi thử việc
  
Plans sử dụng profile này:
  → Medical Insurance VN 2025
  → Dental Insurance VN 2025
  → Life Insurance VN 2025
```

### Cách hoạt động

```
Khi nhân viên thay đổi thuộc tính (promotion, location change, etc.):
  → Hệ thống tự động re-evaluate eligibility
  → Plan membership cập nhật real-time
  → HR không cần manual update
```

---

## 3. Enrollment Management

### 3 loại Enrollment Period

#### Open Enrollment (Hàng năm)

```yaml
Mục đích: Cơ hội hàng năm để nhân viên thay đổi elections
Timing: Tháng 11 (cho coverage bắt đầu 1/1 năm sau)
Duration: 3-4 tuần

Ví dụ:
  Enrollment Window:  2024-11-01 → 2024-11-30
  Coverage Period:    2025-01-01 → 2025-12-31
  Reminders:          14 ngày, 7 ngày, 1 ngày trước deadline
```

#### New Hire Enrollment

```yaml
Mục đích: Nhân viên mới có window để enroll
Timing: 30 ngày từ ngày hire
Auto-Enroll: Có thể cấu hình default plans cho nhân viên không tự enroll

Coverage starts: Ngày hire hoặc ngày đầu tháng sau (tùy cấu hình)
```

#### Qualifying Life Event (QLE)

```yaml
Mục đích: Cho phép thay đổi mid-year khi có sự kiện cuộc sống
Window: 30 ngày từ ngày xảy ra event
Chỉ được thay đổi: Các plan liên quan đến event

Qualifying Events:
  MARRIAGE        → Thêm vợ/chồng, upgrade coverage tier
  BIRTH/ADOPTION  → Thêm con, upgrade coverage tier
  DIVORCE         → Xóa vợ/chồng, downgrade tier
  DEATH           → Xóa người thân, downgrade tier
  LOSS_OF_COVERAGE → Đăng ký mới (mất coverage từ nguồn khác)
```

### Quy trình Open Enrollment

```
PHASE 1: HR Setup
  Tạo EnrollmentPeriod (dates, effective period, eligible plans)
  Update BenefitPlans (costs cho năm mới)
  Mở enrollment (DRAFT → OPEN)
  System gửi notification đến tất cả eligible employees

PHASE 2: Employee Self-Service
  Nhân viên vào portal:
    1. Xem current coverage
    2. So sánh available plans
    3. Thêm/xóa dependents
    4. Chọn coverage options
    5. Xem cost breakdown (monthly/annual)
    6. Chỉ định beneficiaries
    7. Submit enrollment

PHASE 3: Close & Carrier Integration
  HR đóng enrollment period
  System validate all submissions
  Generate EDI 834 file
  Gửi đến insurance carrier
  Carrier acknowledge receipt
  Coverage effective 1/1 năm mới
```

### Life Event Enrollment Workflow

```yaml
Step 1: Employee báo cáo event
  Ví dụ: BIRTH — Event Date: 2025-03-15

Step 2: System tạo LifeEvent record
  Enrollment deadline: 2025-04-14 (30 ngày)
  Status: PENDING

Step 3: Upload verification documents
  Birth certificate (required)
  Status: PENDING → VERIFIED

Step 4: Enrollment window mở
  Employee có thể:
    - Thêm con mới làm dependent
    - Upgrade EMPLOYEE_ONLY → EMPLOYEE_CHILDREN
    - Enroll thêm dental/vision nếu chưa có

Step 5: Changes effective
  Coverage starts: Event date (2025-03-15) — retroactive
  Premium changes: Kỳ payroll tiếp theo
```

---

## 4. Dependent & Beneficiary Management

### Dependent Management

```yaml
Quan hệ được hỗ trợ:
  - Spouse / Domestic Partner
  - Child (biological, adopted, step)

Validation rules:
  - Children: Age < 26 (hoặc student status đến 26)
  - Phải cung cấp: National ID / SSN, Date of Birth
  - Verification documents tương ứng event type

Age-out handling:
  - Hệ thống track và cảnh báo trước khi child aging out
  - Tự động remove khỏi coverage khi quá tuổi
```

### Beneficiary Designation

```yaml
Rules:
  - Primary beneficiaries: Tổng % PHẢI = 100%
  - Contingent beneficiaries: Optional (nhận benefit nếu primary không còn)
  - Có thể chỉ định: Individual person HOẶC Trust/Estate

Ví dụ:
  Primary beneficiaries:
    - Spouse (60%)
    - Child 1 (20%)
    - Child 2 (20%)
  Contingent:
    - Parent (100% nếu primary không nhận được)
```

---

## 5. Claims & Reimbursements

### Healthcare Claims

```yaml
Workflow:
  1. Employee submit claim (diagnosis, provider, amount)
  2. System validate coverage (plan, dates, eligible services)
  3. Route for approval (if above threshold)
  4. Process payment to employee or provider
  5. Update claim history

Claim types:
  - Medical/Hospital
  - Dental
  - Vision
  - Mental Health

Status flow:
  SUBMITTED → UNDER_REVIEW → APPROVED/REJECTED → PAID
```

### Expense Reimbursements

```yaml
Loại phổ biến:
  - Wellness: Gym membership, yoga classes
  - Education: Tuition reimbursement, courses, certifications
  - Commuter: Public transit, parking
  - Home Office: Equipment, internet (remote workers)

Annual limits (ví dụ):
  Wellness: 5,000,000 VND/năm
  Education: 20,000,000 VND/năm
  Commuter: 2,000,000 VND/tháng

Workflow:
  Employee submit → Upload receipts → Manager approve → HR process → Payroll
```

---

## 6. Compliance theo thị trường

### Vietnam — BHXH/BHYT/BHTN

```
Social Insurance (BHXH):
  Employer: 17.5% | Employee: 8%
  Salary cap: 36,000,000 VND/month

Health Insurance (BHYT):
  Employer: 3% | Employee: 1.5%
  Same salary cap

Unemployment Insurance (BHTN):
  Employer: 1% | Employee: 1%
  Salary cap: 83,200,000 VND/month

  → xTalent tự động tính và track các khoản này
```

### US — ACA/COBRA/HIPAA

```
ACA (Doanh nghiệp 50+ FTE):
  Bắt buộc cover 95% FTE
  Premium ≤ 9.12% household income (affordability)

COBRA:
  18-36 tháng continuation coverage sau termination
  Premium: 102% of total cost

HIPAA:
  Protect health information, portability, special enrollment rights
```

---

*Nguồn: `05-benefits-administration-guide.md` (1,467 dòng) · Workflow 2: Benefits Open Enrollment (`02-conceptual-guide.md`)*  
*← [03 Variable Pay](./03-variable-pay.md) · [05 Recognition, Offer & Statement →](./05-recognition-offer-statement.md)*
