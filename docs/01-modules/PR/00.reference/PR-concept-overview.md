# Payroll Module - Concept Overview

> **Module**: Payroll (PR)  
> **Version**: 1.0  
> **Last Updated**: 2026-01-05

---

## 1. Giới thiệu

Payroll Module cung cấp khả năng quản lý toàn diện quy trình trả lương, từ việc cấu hình các thành phần lương, quy tắc tính toán, đến việc tích hợp với hệ thống kế toán và ngân hàng.

### 1.1 Mục tiêu Module

```mermaid
mindmap
  root((Payroll Module))
    Configuration
      Pay Structure
      Pay Elements
      Statutory Rules
    Processing
      Calculation
      Validation
      Balance Tracking
    Output
      Payslips
      Bank Payments
      Tax Reports
    Integration
      HR/Core
      Finance/GL
      Banking
```

### 1.2 Phạm vi

**Trong phạm vi (In Scope):**
- Cấu hình cấu trúc payroll (Calendar, Group, Profile)
- Định nghĩa Pay Elements (earnings, deductions, taxes)
- Quản lý Statutory Rules theo từng quốc gia
- Tích hợp với hệ thống kế toán (GL Mapping)
- Tạo payslip và payment files

**Ngoài phạm vi (Out of Scope):**
- Payroll calculation engine (runtime)
- Payment execution
- Transaction data (pay runs, adjustments)

---

## 2. Kiến trúc Tổng quan

### 2.1 Domain Model

```mermaid
flowchart TB
    subgraph Structure["📁 Structure Layer"]
        PF[PayFrequency]
        PC[PayCalendar]
        PG[PayGroup]
        PP[PayProfile]
    end
    
    subgraph Elements["💰 Elements Layer"]
        PE[PayElement]
        PFo[PayFormula]
        PBD[PayBalanceDefinition]
    end
    
    subgraph Rules["📋 Rules Layer"]
        SR[StatutoryRule]
        DP[DeductionPolicy]
        VR[ValidationRule]
        CR[CostingRule]
    end
    
    subgraph Accounting["🏦 Accounting Layer"]
        GL[GLMappingPolicy]
        AR[PayAdjustReason]
    end
    
    subgraph Reporting["📊 Reporting Layer"]
        PT[PayslipTemplate]
        BT[BankTemplate]
        TT[TaxReportTemplate]
    end
    
    subgraph Integration["🔗 Integration Layer"]
        PI[PayrollInterface]
    end
    
    PF --> PC
    PC --> PG
    PP --> PE
    PP --> SR
    PP --> DP
    PE --> PFo
    PE --> GL
    SR --> PE

    %% Color by Classification
    %% AGGREGATE_ROOT - Green
    style PC fill:#2ecc71,stroke:#27ae60,color:#fff
    style PP fill:#2ecc71,stroke:#27ae60,color:#fff
    style PE fill:#2ecc71,stroke:#27ae60,color:#fff
    style SR fill:#2ecc71,stroke:#27ae60,color:#fff
    style PI fill:#2ecc71,stroke:#27ae60,color:#fff
    
    %% ENTITY - Blue
    style PG fill:#3498db,stroke:#2980b9,color:#fff
    style PFo fill:#3498db,stroke:#2980b9,color:#fff
    style PBD fill:#3498db,stroke:#2980b9,color:#fff
    style DP fill:#3498db,stroke:#2980b9,color:#fff
    style VR fill:#3498db,stroke:#2980b9,color:#fff
    style CR fill:#3498db,stroke:#2980b9,color:#fff
    style GL fill:#3498db,stroke:#2980b9,color:#fff
    style PT fill:#3498db,stroke:#2980b9,color:#fff
    style TT fill:#3498db,stroke:#2980b9,color:#fff
    
    %% REFERENCE_DATA - Orange
    style PF fill:#e67e22,stroke:#d35400,color:#fff
    style AR fill:#e67e22,stroke:#d35400,color:#fff
    style BT fill:#e67e22,stroke:#d35400,color:#fff
```

**Chú thích màu sắc:**
- 🟢 **AGGREGATE_ROOT**: PayCalendar, PayProfile, PayElement, StatutoryRule, PayrollInterface
- 🔵 **ENTITY**: PayGroup, PayFormula, PayBalanceDefinition, DeductionPolicy, ValidationRule, CostingRule, GLMappingPolicy, PayslipTemplate, TaxReportTemplate
- 🟠 **REFERENCE_DATA**: PayFrequency, PayAdjustReason, BankTemplate

### 2.2 Entity Classification

| Classification | Entities | Mô tả |
|---------------|----------|-------|
| **AGGREGATE_ROOT** | PayCalendar, PayProfile, PayElement, StatutoryRule, PayrollInterface | Entities chính, có lifecycle riêng |
| **ENTITY** | PayGroup, PayFormula, PayBalanceDefinition, DeductionPolicy, ValidationRule, CostingRule, GLMappingPolicy, PayslipTemplate, TaxReportTemplate | Entities phụ thuộc |
| **REFERENCE_DATA** | PayFrequency, PayAdjustReason, BankTemplate | Dữ liệu tham chiếu |

---

## 3. Các Khái niệm Chính

### 3.1 Pay Structure

```mermaid
erDiagram
    PAY_FREQUENCY ||--o{ PAY_CALENDAR : "usedBy"
    PAY_CALENDAR ||--o{ PAY_GROUP : "has"
    PAY_CALENDAR }o--|| LEGAL_ENTITY : "belongsTo"
    PAY_GROUP }o--|| PAY_CALENDAR : "belongsTo"
    PAY_GROUP ||--o{ EMPLOYEE : "has"
```

| Concept | Định nghĩa | Ví dụ |
|---------|-----------|-------|
| **Pay Frequency** | Tần suất trả lương chuẩn | MONTHLY, BIWEEKLY |
| **Pay Calendar** | Lịch trả lương với cut-off dates | VN-MONTHLY-2025 |
| **Pay Group** | Nhóm employees có cùng đặc điểm payroll | VN-HQ-STAFF |
| **Pay Profile** | Bundle của elements, rules, policies | VN-STANDARD |

### 3.2 Pay Elements

```mermaid
erDiagram
    PAY_ELEMENT ||--o| PAY_FORMULA : "usesFormula"
    PAY_ELEMENT ||--o| STATUTORY_RULE : "hasStatutoryRule"
    PAY_ELEMENT ||--o{ GL_MAPPING_POLICY : "hasGLMappings"
    PAY_ELEMENT }o--o{ PAY_BALANCE_DEF : "contributesToBalances"
```

**Element Classifications:**

| Type | Mô tả | Ví dụ |
|------|-------|-------|
| **EARNING** | Thu nhập (cộng vào gross) | Basic Salary, OT Allowance |
| **DEDUCTION** | Khấu trừ (trừ khỏi net) | BHXH Employee, Loan Repayment |
| **TAX** | Thuế thu nhập | PIT |
| **EMPLOYER_CONTRIBUTION** | Đóng góp công ty | BHXH Employer |
| **INFORMATIONAL** | Chỉ hiển thị | Working Days |

### 3.3 Statutory Rules

```mermaid
stateDiagram-v2
    [*] --> draft: Create
    draft --> active: Publish
    active --> superseded: New Version
    active --> expired: ValidTo Passed
    superseded --> [*]
    expired --> [*]
```

**Rule Categories:**

| Category | Mô tả | Ví dụ Vietnam |
|----------|-------|---------------|
| TAX | Thuế thu nhập cá nhân | VN_PIT_2025 |
| SOCIAL_INSURANCE | Bảo hiểm xã hội | VN_BHXH_2025 |
| HEALTHCARE | Bảo hiểm y tế | VN_BHYT_2025 |
| UNEMPLOYMENT | Bảo hiểm thất nghiệp | VN_BHTN_2025 |

---

## 4. Data Flow

### 4.1 Configuration Flow

```mermaid
flowchart LR
    A[Define Frequency] --> B[Create Calendar]
    B --> C[Create Pay Groups]
    D[Define Elements] --> E[Configure Formulas]
    F[Setup Statutory Rules] --> D
    D --> G[Create Profile]
    E --> G
    G --> C
    C --> H[Assign Employees]
```

### 4.2 Integration Flow

```mermaid
flowchart TB
    subgraph Inbound
        TA[Time & Attendance] --> PR[Payroll]
        HR[Core HR] --> PR
    end
    
    subgraph Processing
        PR --> |Calculate| CALC[Payroll Engine]
        CALC --> |Validate| VAL[Validation Rules]
        VAL --> |Track| BAL[Balances]
    end
    
    subgraph Outbound
        BAL --> PS[Payslips]
        BAL --> BK[Bank Files]
        BAL --> GL[GL Entries]
        BAL --> TX[Tax Reports]
    end
```

---

## 5. Vietnam-Specific Rules

### 5.1 Statutory Deductions

| Loại | Employee | Employer | Ceiling |
|------|----------|----------|---------|
| BHXH | 8% | 17.5% | 36,000,000 VND |
| BHYT | 1.5% | 3% | 36,000,000 VND |
| BHTN | 1% | 1% | 36,000,000 VND |
| **Tổng** | **10.5%** | **21.5%** | - |

### 5.2 Personal Income Tax (PIT)

| Bậc | Thu nhập chịu thuế | Thuế suất |
|-----|-------------------|-----------|
| 1 | 0 - 5 triệu | 5% |
| 2 | 5 - 10 triệu | 10% |
| 3 | 10 - 18 triệu | 15% |
| 4 | 18 - 32 triệu | 20% |
| 5 | 32 - 52 triệu | 25% |
| 6 | 52 - 80 triệu | 30% |
| 7 | Trên 80 triệu | 35% |

**Exemptions:**
- Personal: 11,000,000 VND/tháng
- Dependent: 4,400,000 VND/người/tháng

---

## 6. Entities Reference

Xem chi tiết tại:
- [Ontology Index](../00-ontology/_index.onto.md)
- [Glossary](../00-ontology/_glossary.onto.md)
- [Conceptual Guide](./PR-conceptual-guide.md)
