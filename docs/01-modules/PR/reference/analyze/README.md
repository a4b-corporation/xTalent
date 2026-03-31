# Payroll Module Independence & Integration Analysis

**Ngày tạo**: 2026-03-06  
**Bộ phận**: Solution Architecture  
**Scope**: Phân tích khả năng triển khai PR module như service độc lập

---

## Mục đích

Bộ tài liệu này phân tích thiết kế hiện tại của module Payroll (PR) trong xTalent HCM, đánh giá khả năng triển khai độc lập theo mô hình Headless Payroll / Payroll-as-a-Service, và đề xuất lộ trình cải tiến.

---

## Tài liệu

| # | Document | Nội dung chính |
|:-:|----------|---------------|
| 01 | [Headless Payroll Concepts](./01-headless-payroll-concepts.md) | 3 mô hình (Monolithic → Modular → Headless), case studies (Check, Zeal, Gusto), architecture patterns, gap analysis |
| 02 | [TR-PR Boundary Analysis](./02-tr-pr-boundary-analysis.md) | Entity mapping `pay_component_def` ↔ `pay_element`, taxonomy mismatch, overlap detection, recommended boundary |
| 03 | [Calculation Responsibility Split](./03-calculation-responsibility-split.md) | 3 options cho calculation ownership, trade-off matrix, recommendation: PR owns calculation |
| 04 | [Payroll API Contract Design](./04-payroll-api-contract-design.md) | ~28 API endpoints (Config, Input, Execution, Output), event contract (16 events), security, idempotency |
| 05 | [Design Assessment](./05-design-assessment.md) | Scoring: Engine 4.8/5, Schema 3.5/5, Independence 1.5/5. 3-level re-design roadmap |
| 06 | [Integration Event & Data Flow](./06-integration-event-data-flow.md) | All data flows (CO/TR/TA→PR→Bank/GL/Tax), sequence diagrams, error handling, volume estimates |

---

## Key Findings

### 🔴 Critical
1. **Calculation Logic Overlap**: TR `calculation_rule_def` + `basis_calculation_rule` (execution_order 1→6) trùng với PR Formula Engine (Drools 8)
2. **No API Contract**: PR giao tiếp internal — không có formal spec cho independent deployment
3. **Taxonomy Mismatch**: TR `pay_component_def` (6 types) vs PR `pay_element` (3 classifications)

### 🟡 Important
4. **PR schema quá lean**: thiếu `tax_treatment`, `proration_method`, `si_basis`, `country_config`, `holiday_calendar`
5. **PayProfile underspecified**: DBML chỉ có shell, thiếu component mapping + rule binding

### 🟢 Strength
6. **PR Engine excellent**: Drools 8 + MVEL + Business DSL + 5-stage pipeline + 3 execution modes = 4.8/5

---

## Recommendations

| Priority | Action | Effort |
|:--------:|--------|:------:|
| **P0** | Quyết định calculation ownership: PR owns (recommended) | Discussion |
| **P0** | Enrich `pay_element` schema (add 5 fields from TR) | 1 sprint |
| **P1** | Add `country_config` + `holiday_calendar` to PR | 1 sprint |
| **P1** | Define OpenAPI + AsyncAPI specs | 2 sprints |
| **P2** | Full Headless deployment readiness | 4-6 sprints |

---

## Đọc theo thứ tự

```
01 (Concepts) → 02 (Boundary) → 03 (Calc Split) → 04 (API) → 05 (Assessment) → 06 (Integration)
```

Nếu chỉ đọc 1 tài liệu: **Doc 05 (Design Assessment)** — tóm tắt toàn bộ.  
Nếu đọc 2: thêm **Doc 03 (Calculation Responsibility Split)** — quyết định quan trọng nhất.
