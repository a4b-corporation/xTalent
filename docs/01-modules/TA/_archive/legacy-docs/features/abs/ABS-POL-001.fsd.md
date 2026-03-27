---
id: ABS-POL-001
name: Leave Policy Definition
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
    - rule_policy_unique_code
    - rule_policy_must_have_type
  lifecycle: LeavePolicyLifecycle
  events: []

dependencies:
  requires: []
  required_by:
    - ABS-ACC-002: "Accrual Policy Configuration"
    - ABS-CARRY-002: "Carryover Rule Configuration"
    - ABS-POL-005: "Accrual Rules"
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-POL-001: Leave Policy Definition

> Cho phép HR định nghĩa leave policies cho tổ chức.

---

## 1. Business Context

### Job Story
> **Khi** tôi muốn định nghĩa policy nghỉ phép,
> **tôi muốn** tạo và cấu hình policy,
> **để** áp dụng cho employees.

---

## 2. UI Workflow

### Policy Definition Screen
- Policy code, name, description
- Link đến LeaveType
- Accrual rules, carryover rules, overdraft rules
- Effective date, status

---

## 4. Business Rules

| Rule ID | Description |
|---------|-------------|
| [`rule_policy_unique_code`](../ontology/rules.yaml#L124) | Policy code phải duy nhất |
| [`rule_policy_must_have_type`](../ontology/rules.yaml#L137) | Policy phải có LeaveType |

---

## 5. NFRs

| NFR | Target |
|-----|--------|
| Config validation | Real-time |

---

## 8. Acceptance Criteria

```gherkin
Scenario: Create leave policy
  Given HR tạo policy mới
  Khi nhập code, name, leave_type
  Và save
  Thì policy được lưu với status DRAFT
```

---

## 9. Release Planning

- **Alpha:** Basic policy creation
- **Beta:** Full rules configuration
- **GA:** Workflow approval
