# xTalent Total Rewards (TR) — Tổng quan Capabilities

**Phiên bản**: 1.0  
**Cập nhật**: 2026-03-05  
**Module**: Total Rewards (TR)

---

## Giới thiệu

**Total Rewards (TR)** là module quản lý toàn diện bù đắp và phúc lợi nhân viên trong xTalent HCM. Module này hợp nhất **11 sub-module** bổ trợ nhau thành một nền tảng thống nhất — từ lương cơ bản, thưởng biến động, cổ phiếu, phúc lợi sức khỏe, chương trình ghi nhận, đến báo cáo tổng đãi ngộ.

TR là module **tạo ra giá trị hiện hữu lớn nhất** với nhân viên — mọi người đều quan tâm đến thu nhập và quyền lợi của mình.

---

## Kiến trúc tổng thể — 11 Sub-modules

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        TR MODULE (Total Rewards)                         │
│                                                                           │
│  ┌─────────────────────┐  ┌─────────────────────┐  ┌──────────────────┐  │
│  │   CORE COMPENSATION  │  │    VARIABLE PAY      │  │     BENEFITS     │  │
│  │                      │  │                      │  │                  │  │
│  │  SalaryBasis         │  │  BonusPlan (STI/LTI) │  │  BenefitPlan    │  │
│  │  PayComponent        │  │  EquityGrant (RSU)   │  │  BenefitOption  │  │
│  │  GradeVersion (SCD2) │  │  VestingSchedule     │  │  EligibilityPrf │  │
│  │  CareerLadder        │  │  CommissionPlan      │  │  Enrollment     │  │
│  │  PayRange (4 scopes) │  │  BonusCycle + Pool   │  │  LifeEvent      │  │
│  │  CompensationCycle   │  │  EquityTransaction   │  │  Dependent      │  │
│  └─────────────────────┘  └─────────────────────┘  └──────────────────┘  │
│                                                                           │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────────┐    │
│  │   RECOGNITION    │  │  OFFER MGMT      │  │    TR STATEMENT      │    │
│  │                  │  │                  │  │                      │    │
│  │  RecognitionEvt  │  │  OfferTemplate   │  │  StatementTemplate   │    │
│  │  PointAccount    │  │  OfferPackage    │  │  StatementSection    │    │
│  │  PerkCatalog     │  │  OfferEvent      │  │  Batch Generation    │    │
│  │  PerkRedemption  │  │  E-Signature     │  │  PDF + Distribution  │    │
│  └──────────────────┘  └──────────────────┘  └──────────────────────┘    │
│                                                                           │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────┐  ┌───────────┐   │
│  │   DEDUCTIONS   │  │ TAX WITHHOLDING│  │  TAX BRIDGE│  │   AUDIT   │   │
│  │  Loan/Garnish  │  │  Elections     │  │  Taxable   │  │  AuditLog │   │
│  │  Priority order│  │  Declarations  │  │  Items →PR │  │  7yr Ret. │   │
│  └────────────────┘  └────────────────┘  └────────────┘  └───────────┘   │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │              CALCULATION ENGINE (SHARED FOUNDATION)                  │  │
│  │    Tax Engine · SI Calculation · Proration · Overtime · Formula     │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
          ↑                      ↓                         ↓
    CO Module             PR (Payroll)            External Systems
  (Worker, Job,         (TaxableItems,          (Benefits Carriers,
   Grade, Org)          Deductions, Pay)         Stock Admin, Tax Auth)
```

---

## Bộ tài liệu này

| Tài liệu | Nội dung | Đối tượng | Đọc ~phút |
|---------|----------|-----------|----------:|
| **[01 · Executive Summary](./01-executive-summary.md)** | Tầm nhìn, pain points, 7 capabilities cốt lõi, business value, market alignment | Business, CXO | 10 |
| **[02 · Core Compensation](./02-core-compensation.md)** | Salary Basis, Grade/Career Ladder, Pay Range (4 scopes), Merit Cycle, Budget | HR Admin, Comp Mgr | 25 |
| **[03 · Variable Pay](./03-variable-pay.md)** | STI/LTI/Spot Bonus, RSU/Stock Options, Commission, Performance integration | HR Admin, Finance | 20 |
| **[04 · Benefits Administration](./04-benefits-administration.md)** | Plan setup, Eligibility Engine, Open Enrollment, Life Events, Claims | Benefits Admin | 25 |
| **[05 · Recognition, Offer & Statement](./05-recognition-offer-statement.md)** | Point system, Perk catalog, Offer management, TR Statement generation | HR, Manager, Employee | 20 |
| **[06 · Calculation & Compliance](./06-calculation-compliance.md)** | Proration engine, Tax, SI, Deductions, Taxable Bridge, Audit | Finance, Compliance, Dev | 20 |
| **[07 · Integration Architecture](./07-integration-architecture.md)** | CO/PR/TA/External integrations, Event model, Role-based security | Developer, Architect | 15 |

**Tổng thời gian đọc toàn bộ**: ~120 phút

---

## Lộ trình đọc theo vai trò

**Business Stakeholder / C-level**:
→ `01` (Executive Summary) — đủ để ra quyết định

**HR Administrator / Comp Manager**:
→ `01` → `02` (Core Compensation) → `03` (Variable Pay) → `06` (Compliance)

**Benefits Administrator**:
→ `01` → `04` (Benefits Administration) → `06` (Compliance)

**Manager / Team Lead**:
→ `01` → `02` (Core Compensation - nhẹ) → `03` (Variable Pay) → `05` (Recognition)

**Employee / End User**:
→ `01` → `05` (Recognition + Statement) → `04` (Benefits self-service)

**Recruiter**:
→ `01` → `05` (Offer Management section)

**Product Manager / BA**:
→ `01` → `02` → `03` → `04` → `05` → `06` → `07` (tuần tự)

**Developer / Architect**:
→ `01` → `07` (Integration) → `06` (Calculation Engine) → `02` → `03` → `04`

---

## Điểm nổi bật của TR Module

| Innovation | Mô tả ngắn |
|-----------|-----------|
| **Component-Based Pay Architecture** | Lương được xây từ các pay components tái sử dụng (Base + Allowances + Bonuses) — thay vì hardcode cấu trúc lương |
| **4-Scope Pay Range** | Salary range có thể định nghĩa ở Global → Legal Entity → Business Unit → Position, hệ thống dùng scope cụ thể nhất |
| **SCD Type 2 Grade Versioning** | Lịch sử grade được lưu đầy đủ — không mất dữ liệu lịch sử thăng tiến |
| **5 Career Ladder Types** | Technical, Management, Specialist, Sales, Executive — mỗi ladder có pay range độc lập |
| **Equity Taxable Bridge** | Tự động tạo taxable item khi RSU vest hoặc option exercise, bridge sang Payroll để khấu trừ thuế đúng kỳ |
| **8-Type Benefit Plan** | Medical, Dental, Vision, Life, Disability, Retirement, Wellness, Perk — với 4 coverage tier và 4 premium calc methods |
| **Dynamic Eligibility Engine** | EligibilityProfile tái sử dụng được qua nhiều plan — điều kiện đủ điều kiện thay đổi tự động real-time |
| **EDI 834 Carrier Integration** | Enrollment data tự động gửi benefits carrier theo chuẩn EDI 834 |
| **FIFO Point Expiration** | Recognition points expire theo thứ tự FIFO — đảm bảo công bằng và khuyến khích redemption thường xuyên |
| **Multi-Country Tax Engine** | Tax brackets, SI rates, exemptions theo từng quốc gia — hỗ trợ VN, US, SG và có thể mở rộng |
| **7-Year Audit Retention** | Mọi thay đổi compensation được lưu audit log với before/after values, phân vùng theo tháng |

---

*Bộ tài liệu này được tổng hợp từ `01-concept/` (11 guides, ~300KB) và `02-spec/` (FEATURE-LIST.yaml, business rules, data specs).*  
*[01 Executive Summary →](./01-executive-summary.md)*
