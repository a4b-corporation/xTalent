# xTalent Payroll (PR) — Tổng quan Capabilities

**Phiên bản**: 1.0  
**Cập nhật**: 2026-03-06  
**Module**: Payroll (PR)

---

## Giới thiệu

**Payroll (PR)** là module đảm bảo mỗi nhân viên nhận đúng số tiền họ được hưởng, vào đúng ngày, theo đúng quy định pháp lý — tự động, minh bạch, và có thể kiểm toán toàn diện.

Điểm đặc trưng của xTalent Payroll so với các hệ thống truyền thống:
- **Formula Engine tự phục vụ**: HR/Finance tự cấu hình công thức lương, không cần IT release
- **3 Execution Modes**: Dry Run → Simulation → Production, với impact analysis trước khi go-live
- **Vietnam Compliance sẵn sàng**: BHXH, BHYT, BHTN, PIT 7 bậc, đầy đủ theo Nghị định
- **Immutable Audit Trail**: Mọi calculation được hash và lưu vĩnh viễn, không thể sửa

---

## Kiến trúc tổng thể

```
┌──────────────────────────────────────────────────────────────────┐
│                        PR MODULE (Payroll)                        │
│                                                                    │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────┐  │
│  │    STRUCTURE     │  │     ELEMENTS     │  │     RULES      │  │
│  │                  │  │                  │  │                │  │
│  │  PayFrequency    │  │  PayElement      │  │ StatutoryRule  │  │
│  │  PayCalendar     │  │  PayFormula      │  │ DeductionPolicy│  │
│  │  PayGroup        │  │  PayBalanceDef   │  │ ValidationRule │  │
│  │  PayProfile      │  │                  │  │ CostingRule    │  │
│  └──────────────────┘  └──────────────────┘  └────────────────┘  │
│                                                                    │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────┐  │
│  │   ACCOUNTING     │  │    REPORTING     │  │  INTEGRATION   │  │
│  │                  │  │                  │  │                │  │
│  │  GLMappingPolicy │  │ PayslipTemplate  │  │PayrollInterface│  │
│  │  PayAdjustReason │  │ BankTemplate     │  │                │  │
│  │                  │  │ TaxReportTemplate│  │                │  │
│  └──────────────────┘  └──────────────────┘  └────────────────┘  │
│                                                                    │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │         FORMULA ENGINE (Drools 8 + MVEL + Business DSL)      │ │
│  │  Dry Run · Simulation · Production Run · Retroactive         │ │
│  └──────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
        ↑                    ↓                      ↓
   CO + TA + TR        Banking Systems         Tax Authorities
  (input data)        (payment files)         (PIT, BHXH reports)
```

---

## Bộ tài liệu này

| Tài liệu | Nội dung | Đối tượng | Đọc ~phút |
|---------|----------|-----------|----------:|
| **[01 · Executive Summary](./01-executive-summary.md)** | Tầm nhìn, pain points được giải quyết, 5 capabilities cốt lõi, business value, market alignment | Business, CXO | 10 |
| **[02 · Payroll Structure](./02-payroll-structure.md)** | PayFrequency, PayCalendar, PayGroup, PayProfile — khung cấu trúc lịch và nhóm lương | HR Admin, Payroll Admin | 20 |
| **[03 · Pay Elements & Formula](./03-pay-elements-formula.md)** | PayElement taxonomy, Formula lifecycle, Business DSL syntax, built-in functions, PayBalanceDefinition, ValidationRule | HR Admin, Payroll Admin, Finance | 25 |
| **[04 · Statutory Rules & Compliance](./04-statutory-rules-compliance.md)** | BHXH/BHYT/BHTN, PIT 7 bậc, DeductionPolicy, xử lý theo loại nhân viên, effective date management | Finance, Compliance | 20 |
| **[05 · Payroll Execution Lifecycle](./05-payroll-execution-lifecycle.md)** | Dry Run, Simulation mode, Production Run 5 stages, Retroactive adjustment, Period locking, SLA | Payroll Admin, Finance | 20 |
| **[06 · Formula Engine Architecture](./06-formula-engine-architecture.md)** | Kiến trúc H4 (Drools 8 + MVEL + Business DSL), 3-tier architecture, Security model 5 lớp, Global extensibility | Developer, Architect | 25 |
| **[07 · Accounting & Reporting](./07-accounting-reporting.md)** | GLMappingPolicy, journal entries, PayslipTemplate, BankTemplate, TaxReportTemplate, báo cáo nội bộ | Finance, Accounting | 20 |
| **[08 · Integration Architecture](./08-integration-architecture.md)** | CO/TA/TR inbound, Banking/GL/Tax outbound, Event model, RBAC security, API patterns | Developer, Architect | 15 |

**Tổng thời gian đọc toàn bộ**: ~155 phút

---

## Lộ trình đọc theo vai trò

**Business Stakeholder / C-level**:  
→ `01` (Executive Summary) — đủ để ra quyết định

**HR Admin / Payroll Admin**:  
→ `01` → `02` (Structure) → `03` (Elements & Formula) → `05` (Execution Lifecycle)

**Finance / Compliance Officer**:  
→ `01` → `04` (Statutory Rules) → `07` (Accounting & Reporting)

**IT Manager / Project Manager**:  
→ `01` → `08` (Integration Architecture)

**Developer / Architect**:  
→ `01` → `06` (Formula Engine) → `08` (Integration) → `03` (Elements)

**Product Manager / BA**:  
→ Đọc tuần tự `01` → `02` → `03` → `04` → `05` → `06` → `07` → `08`

---

## Điểm nổi bật của PR Module

| Innovation | Mô tả ngắn |
|-----------|-----------|
| **Business DSL Layer** | HR/Finance tự viết công thức theo cú pháp Excel-like, không cần lập trình viên |
| **3 Execution Modes** | Dry Run (test) → Simulation (impact analysis) → Production (chính thức) — kiểm soát rủi ro |
| **Drools 8 Rule Engine** | Working memory + Phreak algorithm đảm bảo dependency chain 18 nodes, không sai thứ tự tính |
| **Vietnam Compliance Built-in** | BHXH, BHYT, BHTN, PIT 7 bậc, trần/sàn tự động theo Nghị định |
| **Effective Date Management** | Statutory Rules tự động apply đúng version theo ngày — không cần admin thao tác thủ công |
| **Retroactive Engine** | Delta calculation tự động cascade — không overwrite kỳ cũ, tạo adjustment record mới |
| **5-Layer Security** | ANTLR Grammar → MVEL Whitelist → Offline Compile → ClassLoader → Approval — zero injection risk |
| **Immutable Audit Trail** | SHA-256 hash mỗi payroll result, append-only log 7 năm — sẵn sàng audit bất kỳ lúc nào |
| **GL Auto-posting** | GLMappingPolicy tự động tạo journal entries VAS/IFRS sau mỗi production run |
| **Multi-country Ready** | Drools Rule Units per country — thêm SG/US không ảnh hưởng VN engine |

---

*Bộ tài liệu này được tổng hợp từ `PR/00-ontology/`, `PR/01-concept/`, và `_research/script-el/` (problem statement, architecture analysis, ADR).*  
*[01 Executive Summary →](./01-executive-summary.md)*
