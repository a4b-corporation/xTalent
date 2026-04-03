# Payroll V4 DBML — Bộ Tài liệu Model Design

**Version**: 5.Payroll.V4.dbml  
**Last Updated**: 27Mar2026  
**Source**: `/02-dbml/PR/5.Payroll.V4.dbml`  
**Author**: Architecture Team

---

## Giới thiệu

Bộ tài liệu này giải thích chi tiết thiết kế database model Payroll V4 của xTalent HCM. Mục tiêu: giúp developers, architects, BAs hiểu cặn kẽ:

- **Kiến trúc 7 schemas** và bounded contexts
- **38 tables** với roles, responsibilities, relationships
- **Key design patterns**: SCD-2, multi-country, engine separation, profile hierarchy
- **Data flow**: từ configuration → execution → output → audit

---

## Cấu trúc Bộ Tài liệu

| # | Tài liệu | Nội dung | Đối tượng | Thời gian |
|---|----------|----------|-----------|-----------|
| 01 | [Model Overview](./01-model-overview.md) | Kiến trúc tổng thể, 7 schemas, bounded contexts, key patterns | Architect, Lead Dev | 15 min |
| 02 | [Pay Master Schema](./02-pay-master-schema.md) | Configuration layer: PayProfile, PayElement, StatutoryRule, rate configs | Dev, BA | 25 min |
| 03 | [Pay Mgmt Schema](./03-pay-mgmt-schema.md) | Orchestration layer: PayPeriod, Batch, lifecycle states | Dev, BA | 15 min |
| 04 | [Pay Engine Schema](./04-pay-engine-schema.md) | Calculation layer: RunRequest, InputValue, Result, Balance | Dev | 20 min |
| 05 | [Support Schemas](./05-support-schemas.md) | Gateway, Bank, Audit + supplemental tables | Dev | 15 min |
| 06 | [Data Flow Diagrams](./06-data-flow-diagrams.md) | Payroll execution flow, retro, termination | All | 20 min |

**Tổng thời gian đọc**: ~120 phút

---

## Lộ trình Đọc theo Vai trò

### Developer/Architect
→ 01 (Overview) → 02 (Pay Master) → 03 (Pay Mgmt) → 04 (Pay Engine) → 06 (Data Flow)

### Business Analyst/Product Manager
→ 01 (Overview) → 02 (Pay Master) → 06 (Data Flow) → 05 (Support)

### Database Administrator
→ 01 (Overview) → 02-05 (All schemas) → Indexes & constraints details

### New Team Member
→ Đọc tuần tự 01 → 02 → 03 → 04 → 05 → 06

---

## Quick Reference

### 7 Schemas Overview

| Schema | Role | Tables | Key Entities |
|--------|------|--------|--------------|
| **pay_master** | Configuration | 17 | PayProfile, PayElement, StatutoryRule, PayCalendar |
| **pay_mgmt** | Orchestration | 3 | PayPeriod, Batch, ManualAdjust |
| **pay_engine** | Calculation | 12 | RunRequest, RunEmployee, Result, Balance |
| **pay_gateway** | Integration | 4 | InterfaceDef, InterfaceJob, InterfaceFile |
| **pay_bank** | Payment | 3 | BankAccount, PaymentBatch, PaymentLine |
| **pay_audit** | Audit | 1 | AuditLog |
| **(root)** | Supplemental | 4 | ImportJob, GeneratedFile, BankTemplate, TaxReportTemplate |

### Key Design Patterns

1. **SCD-2 (Slowly Changing Dimension Type 2)**  
   - Tables: pay_calendar, pay_element, balance_def, costing_rule, statutory_rule, pay_profile, gl_mapping, validation_rule, payslip_template
   - Fields: `effective_start_date`, `effective_end_date`, `is_current_flag`
   - Purpose: Track configuration version history, support retroactive adjustments

2. **Multi-Country Scoping**  
   - Fields: `country_code` (ISO 2-char), `config_scope_id` (FK to comp_core.config_scope)
   - Tables: pay_element, statutory_rule
   - Purpose: Same element/rule definition, different country-specific instances

3. **Engine Separation (V4 Key Innovation)**  
   - **pay_mgmt**: Batch orchestration, approval workflow, period lifecycle
   - **pay_engine**: Calculation execution, results, balances, logs
   - Interface: `pay_mgmt.batch.engine_request_id → pay_engine.run_request.id`
   - Benefit: Decoupled orchestration from calculation, independent scaling

4. **PayProfile Hierarchy & Bindings**  
   - `pay_profile.parent_profile_id` → inheritance hierarchy
   - `pay_profile_element` → bind PayElement to PayProfile with overrides
   - `pay_profile_rule` → bind StatutoryRule to PayProfile with execution_order
   - Benefit: Reusable configuration, profile-specific overrides

5. **Rate Configuration Layers (AQ-12)**  
   - Layer 1 (Worker): `worker_rate_override` → exceptional workers
   - Layer 2 (Profile): `pay_profile_rate_config` → group default rates
   - Layer 3 (Statutory): `statutory_rule` → OT multipliers per law
   - Benefit: 50 override records vs 5000 (Option B), optimal for exceptions

---

## Source Files

| File | Role | Note |
|------|------|------|
| `5.Payroll.V4.dbml` | **Primary source** | Official model, authority for all documentation |
| `01-modules/PR/00.reference/overview/*.md` | Supplementary | Business context, concept explanations |
| `01-modules/PR/03.domain/bounded-contexts.md` | Supplementary | BC boundaries, responsibilities |
| `01-modules/PR/03.domain/*/glossary.md` | Supplementary | Ubiquitous language per BC |

**Principle**: If supplementary docs have GAPS with primary source → **always use primary source (DBML)**

---

## ERD Legend

Diagrams trong bộ tài liệu sử dụng notation:

- **Bold boxes**: Aggregate Roots (core entities)
- **Regular boxes**: Entities, Value Objects
- **Dashed boxes**: Deprecated/Archived tables
- **Blue arrows**: Foreign Key relationships
- **Orange arrows**: Domain events/integration
- **Labels on arrows**: Relationship type (1:1, 1:N, N:M)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| V4 | 27Mar2026 | Engine separation: pay_run → pay_mgmt + pay_engine |
| V4 | 26Mar2026 | PayElement multi-country scoping (country_code, config_scope_id) |
| V4 | 26Mar2026 | Eligibility centralized (eligibility.eligibility_profile FK) |
| V3 | Jul 2025 | PayProfile enriched (Option C explicit columns) |
| V3 | Jul 2025 | StatutoryRule enriched (rule_category, rule_type) |
| V3 | Jul 2025 | Added 17 tables: termination_pay_config, rate configs, piece_rate_config |

---

## Liên hệ

- **Architecture Lead**: [Architecture Team]
- **Questions**: Create issue in `/01-modules/PR/ambiguity-resolution.md`
- **Updates**: Track in `review-03-payroll-engine-separation.md`

---

*[Next: Model Overview →](./01-model-overview.md)*