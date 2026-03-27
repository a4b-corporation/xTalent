---
id: ABS-ACC-002
name: Accrual Policy Configuration
module: TA
sub_module: ABS
category: Leave Accrual
priority: P0
status: Specified
differentiation: Parity
gap_type: Config Gap
phase: 1

ontology_refs:
  concepts:
    - LeavePolicy
  rules:
    - rule_accrual_requires_freq_and_amount
  lifecycle: LeavePolicyLifecycle
  events: []

dependencies:
  requires:
    - ABS-POL-001: "Leave Policy Definition"
  required_by:
    - ABS-ACC-001: "Monthly Accrual Run"
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-ACC-002: Accrual Policy Configuration

> Cho phép HR cấu hình chính sách tích lũy nghỉ phép (frequency, amount, tier).

---

## 1. Business Context

### Job Story
> **Khi** tôi muốn cấu hình accrual policy,
> **tôi muốn** set frequency, amount, và tiers,
> **để** hệ thống tự động tính accrual.

---

## 2. UI Workflow

### Policy Config Screen
- Accrual frequency: Monthly/Quarterly/Yearly
- Accrual amount: Fixed hours/days hoặc formula
- Tier rules: Based on tenure, grade
- Effective date

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| [`rule_accrual_requires_freq_and_amount`](../ontology/rules.yaml#L161) | Policy phải có freq và amount | Validation |

---

## 5. NFRs

| NFR | Target |
|-----|--------|
| Config validation | Real-time |

---

## 8. Acceptance Criteria

```gherkin
Scenario: Create accrual policy
  Given HR tạo policy mới
  Khi set frequency=Monthly, amount=1.5 days
  Và save
  Thì policy được lưu và áp dụng cho employees
```

---

## 9. Release Planning

- **Alpha:** Basic config (fixed amount)
- **Beta:** Tier rules, formulas
- **GA:** Full integration
