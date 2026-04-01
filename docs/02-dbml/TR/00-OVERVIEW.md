# Total Rewards Module — Model Overview

**Version**: 5.0  
**Last Updated**: 2026-03-30  
**Source**: `4.TotalReward.V5.dbml`  
**Scope**: Multi-country (VN, TH, ID, SG, MY, PH)

---

## Executive Summary

**Total Rewards (TR)** là module quản lý toàn bộ các hình thức bù đắp mà doanh nghiệp trao cho nhân viên — bao gồm lương cơ bản, thưởng, cổ phiếu (equity), phúc lợi, ghi nhận (recognition) và các ưu đãi (perks).

TR được thiết kế theo mô hình **WorldatWork 5-Pillar Total Rewards Framework**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    TOTAL REWARDS FRAMEWORK                       │
├─────────────┬─────────────┬─────────────┬─────────────┬─────────┤
│ Compensation│   Benefits  │  Work-Life  │ Performance │ Career  │
│   (Fixed +  │  (Insurance │   & Flex    │ & Recognition│Development│
│  Variable)  │  + Wellness)│             │             │         │
└─────────────┴─────────────┴─────────────┴─────────────┴─────────┘
```

---

## 7 Core Capabilities

| # | Capability | Mô tả | Schema |
|---|------------|-------|--------|
| **1** | Component-Based Compensation | Lương được xây dựng từ Pay Components tái sử dụng với tax treatment, proration method riêng | `comp_core` |
| **2** | Grade & Career Ladder with Multi-Level Pay Ranges | Grade SCD-2, Pay Range ở 4 cấp (Global → LE → BU → Position) | `comp_core` |
| **3** | Structured Compensation Cycle | Merit/Promotion/Market Adjustment với budget tracking real-time | `comp_core` |
| **4** | Variable Pay: Bonus + Equity + Commission | STI/LTI/Commission với formula engine, vesting schedules | `comp_incentive` |
| **5** | Dynamic Benefits Administration | Enrollment portal, carrier integration (EDI 834), eligibility engine | `benefit` |
| **6** | Recognition → Perks → Taxable Bridge | Points-based recognition, FIFO expiration, auto-taxable bridge | `recognition` |
| **7** | Total Rewards Statement & Offer Management | Consolidated TR statement, offer lifecycle với e-signature | `tr_offer`, `tr_statement` |

---

## Schema Organization

TR Module được tổ chức thành **10 schemas** (database namespaces), mỗi schema đại diện cho một **Bounded Context** theo DDD:

```mermaid
graph TB
    subgraph "Core Compensation Domain"
        CC[comp_core<br/>Salary Basis, Components,<br/>Grades, Pay Ranges, Cycles]
    end
    
    subgraph "Variable Pay Domain"
        CI[comp_incentive<br/>Bonus, Equity, Commission]
    end
    
    subgraph "Benefits Domain"
        BN[benefit<br/>Plans, Enrollment, Claims]
    end
    
    subgraph "Recognition Domain"
        RC[recognition<br/>Points, Perks, Events]
    end
    
    subgraph "Offer Management Domain"
        TO[tr_offer<br/>Templates, Packages]
    end
    
    subgraph "Statement Domain"
        TS[tr_statement<br/>Config, Jobs, Lines]
    end
    
    subgraph "Cross-Cutting Concerns"
        TT[tr_taxable<br/>Taxable Items Bridge]
        TA[tr_audit<br/>Audit Log]
        TR[total_rewards<br/>Employee Reward Summary]
    end
    
    subgraph "Employee Compensation Records"
        CM[compensation<br/>Basis, Basis Lines<br/>SCD-2 Salary History]
    end
    
    CC --> CM
    CI --> TT
    BN --> TT
    RC --> TT
    CC --> TS
    CI --> TS
    BN --> TS
    RC --> TS
    TO --> CM
    CC --> TA
    CI --> TA
    BN --> TA
    RC --> TA
    TO --> TA
    TT --> TA
```

### Schema Summary

| Schema | Bounded Context | Entity Count | Primary Purpose |
|--------|-----------------|--------------|-----------------|
| `comp_core` | Core Compensation | 15 | Salary structures, pay components, grades, pay ranges, comp cycles, budget |
| `comp_incentive` | Variable Pay | 7 | Bonus plans/cycles/pools, equity grants, vesting events |
| `benefit` | Benefits Administration | 10 | Benefit plans, options, enrollment, claims, reimbursement |
| `recognition` | Recognition & Perks | 8 | Recognition events, point accounts, perks catalog, redemption |
| `tr_offer` | Offer Management | 5 | Offer templates, packages, events, acceptance |
| `tr_statement` | Total Rewards Statement | 4 | Statement config, jobs, sections, lines |
| `tr_taxable` | Taxable Bridge | 1 | Cross-BC taxable item aggregation for Payroll |
| `tr_audit` | Audit & Compliance | 1 | Immutable audit trail (7-year retention) |
| `total_rewards` | Employee Reward Summary | 1 | Aggregated view of all rewards per employee |
| `compensation` | Employee Compensation Records | 2 | SCD-2 salary basis with flexible component lines |

---

## Bounded Context Map (DDD Level 2)

```mermaid
C4Container
    title Bounded Context Map — Total Rewards Module

    Person(hrAdmin, "HR Admin / Comp Manager")
    Person(manager, "Manager")
    Person(employee, "Employee")

    System_Boundary(tr, "Total Rewards Module") {
        Container(bc01, "Core Compensation", "comp_core", "Salary structures, grades, cycles")
        Container(bc02, "Calculation Engine", "comp_core", "Versioned calculation rules")
        Container(bc03, "Variable Pay", "comp_incentive", "Bonus, equity, commission")
        Container(bc04, "Benefits Admin", "benefit", "Enrollment, claims")
        Container(bc05, "Recognition", "recognition", "Points, perks")
        Container(bc06, "Offer Mgmt", "tr_offer", "Candidate offers")
        Container(bc07, "TR Statement", "tr_statement", "Annual statements")
        Container(bc08, "Taxable Bridge", "tr_taxable", "Taxable events → Payroll")
        Container(bc09, "Audit", "tr_audit", "Immutable audit trail")
        Container(bc10, "Comp Records", "compensation", "SCD-2 salary history")
    }

    System_Ext(co, "Core HR (CO)", "Worker, Grade, LegalEntity")
    System_Ext(pr, "Payroll (PR)", "Payroll execution")
    System_Ext(pm, "Performance (PM)", "Ratings")

    Rel(co, bc01, "WorkerCreated, GradeChanged")
    Rel(co, bc03, "WorkerCreated")
    Rel(co, bc04, "WorkerCreated")
    Rel(co, bc06, "LegalEntity data")
    
    Rel(bc01, bc02, "CalculationEnginePort")
    Rel(bc03, bc02, "Formula execution")
    
    Rel(bc01, bc08, "SalaryChanged")
    Rel(bc03, bc08, "BonusApproved, EquityVested")
    Rel(bc04, bc08, "BenefitInKind")
    Rel(bc05, bc08, "TaxableRecognition")
    
    Rel(bc08, pr, "TaxableItems")
    
    Rel(pm, bc03, "PerformanceRating")
    
    Rel(bc01, bc09, "Audit events")
    Rel(bc03, bc09, "Audit events")
    Rel(bc08, bc09, "Audit events")
    
    Rel(bc01, bc10, "Salary records")
    Rel(bc06, bc10, "Offer accepted → Basis")

    Rel(hrAdmin, bc01, "Configure structures")
    Rel(manager, bc01, "Submit proposals")
    Rel(employee, bc07, "View statement")
```

---

## Key Design Decisions

### 1. Multi-Country / Multi-Legal Entity Scoping

**Problem**: Cấu hình compensation/benefits cần phân biệt theo quốc gia và pháp nhân.

**Solution**: Dual-mode scoping mechanism:

```mermaid
graph LR
    subgraph "Phase 1: Light Touch"
        A[Definition Table] --> B[country_code]
        A --> C[legal_entity_id]
    end
    
    subgraph "Phase 2: Config Scope Group"
        D[Definition Table] --> E[config_scope_id]
        E --> F[config_scope]
        F --> G[Hierarchical Scopes<br/>Global → Country → LE → BU]
    end
    
    B --> H[Simple, 1-3 countries]
    E --> I[Complex, 5+ countries<br/>with inheritance]
```

**Resolution Order** (most specific wins):
1. `config_scope_id` (if populated) → resolved scope
2. Inline `country_code` + `legal_entity_id` (if populated)
3. NULL = global (applies everywhere)

**Example Hierarchy**:
```
GLOBAL (priority=0)
 └─ VN_DEFAULT (priority=10, country_code=VN)
     └─ VN_ENTITY_A (priority=20, legal_entity_id=xxx)
         └─ VN_TECH_BU (priority=30, business_unit_id=yyy)
```

---

### 2. SCD Type 2 Versioning

**Problem**: Cần lưu lịch sử thay đổi để audit, analysis và compliance.

**Solution**: Slowly Changing Dimension Type 2 pattern:

| Entity | SCD-2 Fields |
|--------|--------------|
| `grade_v` | `effective_start`, `effective_end`, `version_number`, `previous_version_id`, `is_current_version` |
| `calculation_rule_def` | Same as above |
| `compensation.basis` | `effective_start_date`, `effective_end_date`, `is_current_flag`, `previous_basis_id` |
| `pay_range` | `effective_start`, `effective_end` (no version chain) |
| `employee_comp_snapshot` | `effective_start`, `effective_end` |

**Pattern**:
```sql
-- When updating, never modify existing record
-- Instead: close old record, create new record
UPDATE grade_v 
SET effective_end = CURRENT_DATE, is_current_version = false
WHERE id = old_id;

INSERT INTO grade_v (grade_code, name, ..., effective_start, previous_version_id, is_current_version)
VALUES (code, name, ..., CURRENT_DATE, old_id, true);
```

---

### 3. Domain Boundary: TR vs PR (Gross vs Net)

**Critical Design Decision** (ADR 27Mar2026 Option D):

```
┌─────────────────────────────────────────────────────────────────┐
│                    DOMAIN BOUNDARY                               │
├─────────────────────────────────────────────────────────────────┤
│  TR DOMAIN (Total Rewards)          │  PR DOMAIN (Payroll)      │
│  "What to pay" (Decision Layer)     │  "How to pay" (Execution) │
├─────────────────────────────────────┼───────────────────────────┤
│  ✓ Projected/Gross calculations     │  ✓ Net calculations       │
│  ✓ HR-policy rules                  │  ✓ Statutory rules        │
│  ✓ Proration, FX, Annualization     │  ✓ TAX, SI, OT calculation│
│  ✓ Compensation policy rules        │  ✓ Gross → Net engine     │
│                                     │                           │
│  calculation_rule_def:              │  pay_master.statutory_rule│
│  - PRORATION                        │  - VN_PIT_2025            │
│  - ROUNDING                         │  - VN_SI_2025             │
│  - FOREX                            │  - VN_OT_MULT_2019        │
│  - ANNUALIZATION                    │  - SG_CPF_2025            │
│  - COMPENSATION_POLICY              │                           │
└─────────────────────────────────────┴───────────────────────────┘
```

**Data Flow**:
```
TR (Gross) ──TaxableItems──► PR (Net Calculation)
                         ──► Payroll Execution
```

---

### 4. Centralized Eligibility Pattern

**Problem**: Eligibility rules bị duplicate across Compensation Plans, Bonus Plans, Benefit Plans.

**Solution**: Centralized `eligibility.eligibility_profile` (G6 change 26Mar2026):

```mermaid
graph LR
    subgraph "Centralized Eligibility Module"
        EP[eligibility_profile]
    end
    
    subgraph "TR Consumers"
        CP[comp_plan]
        BP[bonus_plan]
        BNP[benefit_plan]
    end
    
    CP -->|eligibility_profile_id| EP
    BP -->|eligibility_profile_id| EP
    BNP -->|eligibility_profile_id| EP
    
    style EP fill:#e1f5fe
```

**Migration Path**:
- `comp_plan.eligibility_rule` → DEPRECATED → use `eligibility_profile_id`
- `bonus_plan.eligibility_rule` → DEPRECATED → use `eligibility_profile_id`
- `benefit_plan.eligibility_rule_json` → DEPRECATED → use `eligibility_profile_id`
- `benefit.eligibility_profile` → DEPRECATED v6.0 → migrate to centralized

---

### 5. Dual Pay Scale Mode (Vietnam Coefficient System)

**Problem**: Vietnam statutory salary uses coefficient-based calculation:
```
salary = coefficient × VN_LUONG_CO_SO (statutory base)
```

**Solution**: Dual mode in `grade_ladder_step`:

| Field | TABLE_LOOKUP Mode | COEFFICIENT_FORMULA Mode |
|-------|-------------------|--------------------------|
| `step_amount` | Direct salary value | NULL or reference |
| `coefficient` | NULL | e.g., 2.34, 3.66, 6.20 |

**Example**:
```
Ngạch Chuyên viên, Bậc 1:
  coefficient = 2.34
  VN_LUONG_CO_SO = 2,340,000 VND (2025)
  salary = 2.34 × 2,340,000 = 5,475,600 VND
```

**Domain Split**:
- `coefficient` + `step_amount` = TR domain (projected/Gross)
- `VN_LUONG_CO_SO` = PR domain (statutory_rule) — TR reads via data contract

---

### 6. Taxable Bridge Pattern (Cross-BC Integration)

**Problem**: Taxable events arise from multiple bounded contexts (Salary, Bonus, Equity, Benefits, Recognition).

**Solution**: `tr_taxable.taxable_item` as **Anti-Corruption Layer**:

```mermaid
graph TB
    subgraph "Source BCs"
        S1[Core Compensation<br/>SalaryChanged]
        S2[Variable Pay<br/>BonusApproved, EquityVested]
        S3[Benefits<br/>BenefitInKind]
        S4[Recognition<br/>TaxableRecognition]
    end
    
    subgraph "Bridge"
        TB[taxable_item<br/>source_module<br/>source_table<br/>source_id]
    end
    
    subgraph "Consumer"
        PR[Payroll Module<br/>Tax Calculation]
    end
    
    S1 -->|Kafka| TB
    S2 -->|Kafka| TB
    S3 -->|Kafka| TB
    S4 -->|Kafka| TB
    
    TB -->|Kafka + Daily Batch| PR
    
    style TB fill:#fff3e0
```

**Idempotency**: `(source_module, source_table, source_id)` ensures exactly-once processing.

---

## Entity Count by Schema

| Schema | Tables | Key Entities |
|--------|--------|--------------|
| `comp_core` | 15 | `salary_basis`, `pay_component_def`, `grade_v`, `grade_ladder`, `pay_range`, `comp_plan`, `comp_cycle`, `comp_adjustment`, `budget_allocation`, `calculation_rule_def`, `config_scope`, `country_config` |
| `comp_incentive` | 7 | `bonus_plan`, `bonus_cycle`, `bonus_pool`, `bonus_allocation`, `equity_grant`, `equity_vesting_event`, `equity_txn` |
| `benefit` | 10 | `benefit_plan`, `benefit_option`, `enrollment`, `reimbursement_request`, `healthcare_claim_header` |
| `recognition` | 8 | `recognition_event`, `point_account`, `perk_catalog`, `perk_redeem`, `reward_point_txn` |
| `tr_offer` | 5 | `offer_template`, `offer_package`, `offer_event`, `offer_acceptance` |
| `tr_statement` | 4 | `statement_config`, `statement_job`, `statement_line`, `statement_section` |
| `tr_taxable` | 1 | `taxable_item` |
| `tr_audit` | 1 | `audit_log` |
| `total_rewards` | 1 | `employee_reward_summary` |
| `compensation` | 2 | `basis`, `basis_line` |

**Total**: ~54 tables across 10 schemas

---

## Integration Architecture

```mermaid
graph LR
    subgraph "Upstream Systems"
        CO[Core HR<br/>Worker, Grade, LE]
        PM[Performance<br/>Ratings]
        TA[Time & Absence<br/>Overtime Hours]
        FIN[Finance<br/>Budget Guidelines]
    end
    
    subgraph "Total Rewards Module"
        TR[10 Bounded Contexts<br/>54 Tables]
    end
    
    subgraph "Downstream Systems"
        PR[Payroll<br/>Execution]
        RPT[Analytics<br/>Dashboards]
    end
    
    subgraph "External Systems"
        CARR[Benefits Carriers<br/>EDI 834]
        TAX[Tax Authorities<br/>e-Filing]
        ESIGN[E-Signature<br/>Providers]
        FX[FX Rate<br/>Providers]
    end
    
    CO -->|Kafka Events| TR
    PM -->|REST/Kafka| TR
    TA -->|REST| TR
    FIN -->|REST| TR
    
    TR -->|TaxableItems| PR
    TR -->|Metrics| RPT
    
    TR <-->|EDI 834| CARR
    TR -->|e-Filing| TAX
    TR <-->|Signatures| ESIGN
    FX -->|Daily Rates| TR
```

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [01-CORE-COMPENSATION.md](./01-CORE-COMPENSATION.md) | Detailed design of Core Compensation BC |
| [02-VARIABLE-PAY.md](./02-VARIABLE-PAY.md) | Detailed design of Variable Pay BC |
| [03-BENEFITS.md](./03-BENEFITS.md) | Detailed design of Benefits Administration BC |
| [04-RECOGNITION-OFFER.md](./04-RECOGNITION-OFFER.md) | Detailed design of Recognition & Offer BCs |
| [05-CALCULATION-COMPLIANCE.md](./05-CALCULATION-COMPLIANCE.md) | Detailed design of Calculation Rules & Compliance |
| [06-EMPLOYEE-COMPENSATION.md](./06-EMPLOYEE-COMPENSATION.md) | Detailed design of Employee Compensation Records |

---

## Change Log

| Date | Version | Changes |
|------|---------|---------|
| 2026-03-30 | 1.0 | Initial overview document |
| 2026-03-27 | V5 | Added dual pay scale mode, domain boundary TR/PR |
| 2026-03-26 | V5 | Added config_scope multi-country/LE scoping |
| 2025-11-25 | V4 | Added calculation_rules module |
| 2025-11-21 | V4 | Enhanced audit trail, precision changes |

---

*Document generated from `4.TotalReward.V5.dbml`*