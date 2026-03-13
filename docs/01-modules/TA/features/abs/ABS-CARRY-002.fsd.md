---
id: ABS-CARRY-002
name: Carryover Rule Configuration
module: TA
sub_module: ABS
category: Leave Carryover
priority: P0
status: Specified
differentiation: Parity
gap_type: Config Gap
phase: 1

ontology_refs:
  concepts:
    - LeavePolicy
  rules:
    - rule_carry_requires_max_or_expire
  lifecycle: LeavePolicyLifecycle
  events: []

dependencies:
  requires:
    - ABS-POL-001: "Leave Policy Definition"
  required_by:
    - ABS-CARRY-001: "Period End Carryover"
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-CARRY-002: Carryover Rule Configuration

> Cho phép HR cấu hình chính sách carryover (max carry, expiry).

---

## 1. Business Context

### Job Story
> **Khi** tôi muốn cấu hình carryover policy,
> **tôi muốn** set maxCarry và expiryMonths,
> **để** hệ thống tự động xử lý cuối kỳ.

---

## 2. UI Workflow

### Config Screen
- Max carry: Fixed days hoặc % of accrued
- Expiry: Months after period end
- Carryover frequency: Annual/Period-based

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| [`rule_carry_requires_max_or_expire`](../ontology/rules.yaml#L175) | Policy phải có maxCarry hoặc expireMonths | Validation |

---

## 8. Acceptance Criteria

```gherkin
Scenario: Create carryover policy
  Given HR tạo policy mới
  Khi set maxCarry=5 days, expireMonths=3
  Và save
  Thì policy được lưu và áp dụng cho carryover run
```

---

## 9. Release Planning

- **Alpha:** Basic config
- **Beta:** % based carryover
- **GA:** Full integration
