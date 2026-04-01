# Headless Payroll — Industry Concepts & Architecture Patterns

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-06  
**Đối tượng**: Solution Architect, Product Leadership, CTO  
**Thời gian đọc**: ~25 phút

---

## 1. Tổng quan — Payroll có gì đặc biệt?

Payroll là module **có tính quy định pháp lý cao nhất** trong HCM — mỗi lỗi đều có thể dẫn đến vi phạm thuế, kiện tụng lao động, hoặc mất uy tín với nhân viên. Đó là lý do payroll truyền thống thường là module **tightly coupled**, nằm sâu trong core ERP/HCM.

Tuy nhiên, xu hướng toàn cầu đang thay đổi: payroll đang dịch chuyển từ *internal module* sang *independent service*, theo 3 mô hình chính.

---

## 2. Ba Mô hình Triển khai Payroll

### 2.1 Monolithic Payroll (Truyền thống)

```
┌────────────────────────────────────────────────┐
│                   HCM Suite                     │
│                                                 │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌───────────┐  │
│  │  CO  │──│  TR  │──│  TA  │──│  PAYROLL   │  │
│  └──────┘  └──────┘  └──────┘  └───────────┘  │
│        Shared Database, Shared Codebase         │
└────────────────────────────────────────────────┘
```

| Đặc điểm | Chi tiết |
|-----------|----------|
| Database | Shared schema, direct table joins |
| Coupling | Tight — payroll truy cập trực tiếp employee, compensation tables |
| Deployment | Monolith — release toàn bộ system |
| Ví dụ | Oracle E-Business Suite (trước Cloud), SAP ECC |

**Ưu**: Đơn giản, data consistency tối ưu, transaction đảm bảo.  
**Nhược**: Không thể triển khai riêng, scale riêng, hay thay thế riêng. Mỗi thay đổi payroll phải test toàn bộ system.

### 2.2 Modular Payroll (Current Best Practice)

```
┌───────────────────────────────────────────────────┐
│                     HCM Platform                   │
│                                                     │
│  ┌──────┐  ┌──────┐  ┌──────┐                     │
│  │  CO  │  │  TR  │  │  TA  │                     │
│  └──┬───┘  └──┬───┘  └──┬───┘                     │
│     │ Event    │ Event    │ Event                   │
│     ▼          ▼          ▼                         │
│  ┌─────────────────────────────┐                   │
│  │     PAYROLL MODULE          │                   │
│  │  (separate bounded context) │                   │
│  └─────────────────────────────┘                   │
│        Same Platform, Separate Schemas              │
└───────────────────────────────────────────────────┘
```

| Đặc điểm | Chi tiết |
|-----------|----------|
| Database | Separate schema per module, no direct joins |
| Coupling | Loose — event-driven + API calls |
| Deployment | Independent deploy possible nhưng cùng platform |
| Ví dụ | Oracle HCM Cloud, SAP SuccessFactors + ECP, Workday (internal modules) |

**Ưu**: Payroll có bounded context riêng, có thể develop/test independent.  
**Nhược**: Vẫn trong cùng platform, khó offer cho bên thứ ba.

### 2.3 Headless Payroll / Payroll-as-a-Service

```
┌──────────────────┐   ┌──────────────────┐
│  HCM Platform    │   │  ERP System      │
│  (xTalent)       │   │  (3rd party)     │
│  ┌────┐ ┌────┐   │   │                  │
│  │ CO │ │ TR │   │   │                  │
│  └──┬─┘ └──┬─┘   │   │                  │
│     │       │     │   │                  │
└─────┼───────┼─────┘   └────────┬─────────┘
      │ API   │ API              │ API
      ▼       ▼                  ▼
   ┌─────────────────────────────────────┐
   │     PAYROLL SERVICE (Standalone)     │
   │                                      │
   │  REST/gRPC APIs                      │
   │  Own Database                        │
   │  Independent Deployment              │
   │  Multi-tenant capable                │
   └─────────────────────────────────────┘
         │           │           │
         ▼           ▼           ▼
    Banking      Tax Auth     GL Systems
```

| Đặc điểm | Chi tiết |
|-----------|----------|
| Database | Completely separate, owned by payroll service |
| Coupling | Zero — API contract only |
| Deployment | Standalone service, independent lifecycle |
| Ví dụ | Check, Zeal, Gusto Embedded, ADP RUN API |

**Ưu**: Triển khai hoàn toàn độc lập, phục vụ nhiều HCM/ERP platforms, scale riêng biệt.  
**Nhược**: Phức tạp hơn (API versioning, eventual consistency, data sync).

---

## 3. Các khái niệm cốt lõi

### 3.1 Headless Payroll

**Định nghĩa**: Payroll engine tách biệt hoàn toàn khỏi UI và business logic của HCM. Payroll chỉ expose APIs — không có giao diện riêng. UI do consuming platform (xTalent, ERP, custom app) cung cấp.

**Tương tự**: Headless CMS (Contentful) — CMS chỉ quản lý content, frontend do client tự xây.

**Kiến trúc**:
- Core engine nhận input data qua API
- Thực thi tính toán (formula, tax, SI, deductions)
- Trả kết quả qua API
- Không assume bất kỳ UI, workflow, hay approval logic nào

### 3.2 Embedded Payroll

**Định nghĩa**: Payroll capabilities được nhúng trực tiếp vào một platform khác, trở thành tính năng native của platform đó — user không biết payroll đang chạy từ service riêng.

**Use case**: SaaS platform muốn thêm tính năng payroll mà không tự build. Ví dụ: một HR SaaS platform nhúng Gusto/Check payroll API vào product của mình.

**Khác biệt với Headless**:
- Headless = Payroll không có UI, client tự build
- Embedded = Payroll API được wrap vào UI có sẵn, trông như feature native

### 3.3 Payroll-as-a-Service (PaaS)

**Định nghĩa**: Payroll được cung cấp như một service — toàn bộ infrastructure (tax compliance, filing, money movement) do provider quản lý. Consumer chỉ cần gọi API.

**Components điển hình**:

| Component | Trách nhiệm |
|-----------|-------------|
| **Calculation Engine** | Gross, tax, SI, deductions, net |
| **Compliance Engine** | Tax tables, regulatory updates, statutory rules |
| **Payment Engine** | Bank file generation, money movement |
| **Filing Engine** | Tax filing, SI filing với cơ quan nhà nước |
| **Audit Engine** | Immutable log, calculation trace, compliance proof |

### 3.4 Payroll Infrastructure

**Định nghĩa**: Tầng thấp nhất — API primitives cho payroll processing. Không phải payroll product hoàn chỉnh, mà là building blocks để xây payroll.

**Ví dụ**: Check cung cấp primitives: `create_payroll()`, `add_earning()`, `calculate()`, `approve()`, `file_taxes()`.

---

## 4. Case Studies — Payroll Infrastructure Companies

### 4.1 Check (checkhq.com) — Payroll-as-a-Service API

**Mô hình**: PaaS API — developer build payroll product on top of Check

**Core API Flow**:
```
1. Create Company → onboard employer
2. Create Employee → employee data
3. Create Payroll → define pay period
4. Add Payees → select employees
5. Add Earnings → amounts per employee
6. Preview → calculate taxes, deductions
7. Approve → trigger payment + tax filing
```

**Trách nhiệm Check owns**:
- Tax calculation (federal + state + local)
- Tax filing (quarterly, annual)
- Money movement (ACH)
- Compliance updates (tax table changes)

**Trách nhiệm Client owns**:
- UI/UX
- Employee onboarding flow
- Approval workflow
- Reporting/analytics

### 4.2 Zeal (zeal.com) — Full-Stack Embedded Payroll

**Mô hình**: Embedded payroll cho workforce management platforms

**Đặc biệt**:
- Hỗ trợ cả W-2 (employees) và 1099 (contractors)
- Zeal **giữ payroll liability** — khách hàng không phải lo compliance
- White-label — branded as client's own product

### 4.3 Gusto Embedded Payroll

**Mô hình**: Developer API cho embedded payroll

**API Surface**:
- Employee data APIs (demographics, compensation, tax elections)
- Payroll processing APIs (run payroll, preview, approve)
- Tax compliance APIs (tax filings, year-end forms)
- Benefits APIs (enrollment, deductions)

**Infrastructure abstracted**:
- Tax tables cho 50+ US states + thousands of local jurisdictions
- Payment lifecycle: calculation → distribution
- Regulatory updates: tự động apply khi tax law thay đổi

---

## 5. Architecture Patterns cho Headless Payroll

### 5.1 API-First Design

```
Contract First → Implementation Later

OpenAPI/AsyncAPI Spec
    ↓
Server Stub + Client SDK auto-generated
    ↓
Implementation follows contract
    ↓
Contract versioning (v1, v2...) ensures backward compatibility
```

**Nguyên tắc**:
- API Contract là source of truth — không phải code
- Breaking changes → new API version (v1 → v2)
- Deprecation policy: old version supported N months sau khi new version release

### 5.2 Stateless Calculation Engine

```
Request: {
  employee_data: { salary: 30M, type: "FULL_TIME" },
  period: { start: "2025-03-01", end: "2025-03-31" },
  attendance: { work_days: 22, ot_hours: 18 },
  config: { country: "VN", statutory_rules: "VN_2025" },
  taxable_items: [{ source: "RSU_VEST", amount: 50M }]
}

Engine: Calculate (pure function — no side effects)

Response: {
  gross: 34.5M,
  deductions: { bhxh: 2.76M, bhyt: 517K, bhtn: 345K, pit: 1.224M },
  net: 29.653M,
  employer_cost: { bhxh_er: 6.037M, bhyt_er: 1.035M },
  calculation_trace: [...]
}
```

**Đặc điểm**: Engine không lưu state — cùng input luôn cho cùng output. State (employee data, history, balances) nằm ở calling system.

### 5.3 Event-Driven Integration

```
Events IN (consumed by Payroll):
  EmployeeSalaryChanged → update base salary input
  AttendanceLocked       → T&A data ready
  TaxableItemCreated     → add to taxable income
  BenefitEnrollmentChanged → update premium deduction

Events OUT (published by Payroll):
  PayrollRunCompleted    → results available
  PeriodLocked           → immutable, post GL
  PayslipGenerated       → notify employee
```

### 5.4 Bounded Context Pattern

```
Payroll Bounded Context (owns):
  ├── PayCalendar     (khi nào trả lương)
  ├── PayGroup        (ai được xử lý cùng nhau)
  ├── PayProfile      (chính sách nào áp dụng)
  ├── PayElement      (thành phần lương)
  ├── PayFormula      (công thức tính)
  ├── StatutoryRule   (quy định pháp lý)
  ├── PayrollRun      (kết quả tính lương)
  └── AuditLog        (vết kiểm toán)

Payroll DOES NOT own:
  ├── Employee data    → consumed from CO via API/Event
  ├── Salary amounts   → consumed from TR via API/Event
  ├── Attendance data  → consumed from TA via API/Event
  └── Org structure    → consumed from CO via API/Event
```

---

## 6. Mapping xTalent PR hiện tại vào Spectrum

### Hiện trạng: Modular (leaning Monolithic)

| Tiêu chí | Headless/PaaS | xTalent PR hiện tại | Gap |
|-----------|:---:|:---:|:---:|
| Database separation | ✅ Own database | ⚠️ Separate schema, same DB | **Minor** |
| API-first design | ✅ Contract-first APIs | ❌ Internal module calls | **Major** |
| Independent deployment | ✅ Standalone service | ❌ Deploy cùng platform | **Major** |
| Stateless engine | ✅ Pure calculation | ⚠️ Drools + Working Memory = stateful per session | **Moderate** |
| Multi-tenant | ✅ Serve multiple platforms | ❌ Single platform only | **Major** |
| Own element/formula | ✅ PR owns calculation | ⚠️ TR cũng có `calculation_rule_def` | **Critical** |
| Event contract | ✅ Published event schema | ⚠️ Conceptual, not formalized | **Moderate** |

### Khoảng cách chính (Top 3 Gaps)

1. **Calculation Ownership Conflict**: TR DBML V5 có `calculation_rule_def` + `basis_calculation_rule` với execution order `1→6` covering toàn bộ gross→net flow. PR cũng có formula engine (Drools 8 + MVEL). → **Ai owns calculation?**

2. **No API Contract**: PR giao tiếp với TR/CO/TA qua internal events — không có formal API contract. Nếu muốn deploy independent, cần định nghĩa OpenAPI spec.

3. **PayElement ≠ PayComponent**: TR `pay_component_def` (6 types) và PR `pay_element` (5 classifications) là hai representations khác nhau cho cùng khái niệm. Cần mapping layer hoặc hợp nhất.

---

## 7. Khuyến nghị Hướng đi cho xTalent

### Phương án đề xuất: **Modular-to-Headless Evolution**

Không cần build headless từ đầu. Roadmap:

```
Phase 1: Clean Bounded Context (2-3 sprints)
  → Xác định rõ ranh giới PR/TR
  → Tách calculation ownership
  → Định nghĩa internal API contract

Phase 2: API-First Refactor (3-4 sprints)
  → Formal OpenAPI spec cho PR
  → Event schema chuẩn hóa (AsyncAPI)
  → Database schema isolation hoàn toàn

Phase 3: Independent Deployment (2-3 sprints)
  → PR deployable as standalone service
  → Health check, monitoring, circuit breaker
  → Backward-compatible API versioning

Phase 4: Multi-tenant (future)
  → Serve multiple platforms
  → Tenant isolation
  → White-label capability
```

**Tại sao không full Headless ngay?**
- xTalent hiện chỉ phục vụ 1 platform — chưa cần multi-tenant
- Overhead của full headless quá lớn cho team size hiện tại
- Nhưng **clean bounded context** là PHẢI LÀM ngay — đây là foundation cho mọi evolution path

---

## Tóm tắt

| Mô hình | Khi nào dùng | Phù hợp xTalent? |
|---------|-------------|:-:|
| **Monolithic** | Startup, MVP, team nhỏ | ❌ Đã vượt qua |
| **Modular** | Enterprise HCM, internal platform | ✅ **Target gần** |
| **Headless/PaaS** | Payroll-as-product, multi-platform | 🎯 **Target xa** |

---

*← [README](./README.md) · [02 TR-PR Boundary Analysis →](./02-tr-pr-boundary-analysis.md)*
