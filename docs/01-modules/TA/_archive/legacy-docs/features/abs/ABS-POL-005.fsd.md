---
id: ABS-POL-005
name: Accrual Rules
module: TA
sub_module: ABS
category: Leave Policy Rules
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

# ABS-POL-005: Accrual Rules

> Cho phép HR cấu hình accrual rules trong leave policies.

---

## 1. Business Context

### Job Story
> **Khi** tôi muốn cấu hình rule tích lũy,
> **tôi muốn** set frequency và amount,
> **để** hệ thống auto accrual.

---

## 2. UI Workflow

### Accrual Rule Config Screen
- Frequency: Monthly/Quarterly/Yearly
- Amount: Fixed days/hours hoặc formula
- Tier rules based on tenure
- Proration rules

---

## 4. Business Rules

| Rule ID | Description |
|---------|-------------|
| [`rule_accrual_requires_freq_and_amount`](../ontology/rules.yaml#L161) | Phải có freq và amount |

---

## 8. Acceptance Criteria

```gherkin
Scenario: Create accrual rule
  Given HR tạo accrual rule
  Khi set frequency=Monthly, amount=1.5 days
  Và save
  Thì rule được lưu và áp dụng
```

---

## 9. Release Planning

- **Alpha:** Fixed amount accrual
- **Beta:** Formula-based, tier rules
- **GA:** Full proration
