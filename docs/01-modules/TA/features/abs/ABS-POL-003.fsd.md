---
id: ABS-POL-003
name: Leave Class Configuration
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
    - LeaveClass
  rules:
    - rule_leave_class_unique_code
    - rule_leave_class_must_have_type
    - rule_leave_class_mode_requires_period_profile
  lifecycle: LeaveClassLifecycle
  events: []

dependencies:
  requires:
    - ABS-POL-002: "Leave Type Configuration"
  required_by:
    - ABS-POL-004: "Eligibility Rules"
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-POL-003: Leave Class Configuration

> Cho phép HR cấu hình LeaveClasses (department-specific leave categories).

---

## 1. Business Context

### Job Story
> **Khi** tôi muốn tạo class nghỉ cho department,
> **tôi muốn** cấu hình LeaveClass,
> **để** áp dụng policy cho nhóm employees.

---

## 2. UI Workflow

### Leave Class Config Screen
- Code, name, description
- Link đến LeaveType
- Mode: ACCOUNT/LIMIT/UNLIMITED
- Period profile
- Eligibility criteria

---

## 4. Business Rules

| Rule ID | Description |
|---------|-------------|
| [`rule_leave_class_unique_code`](../ontology/rules.yaml#L74) | Code phải duy nhất |
| [`rule_leave_class_must_have_type`](../ontology/rules.yaml#L87) | Must have LeaveType |
| [`rule_leave_class_mode_requires_period_profile`](../ontology/rules.yaml#L99) | ACCOUNT/LIMIT mode requires period profile |

---

## 8. Acceptance Criteria

```gherkin
Scenario: Create leave class
  Given HR tạo class cho Annual Leave
  Khi nhập code=ANNUAL-VN, mode=ACCOUNT, period_profile=Yearly
  Và save
  Thì LeaveClass được tạo
```

---

## 9. Release Planning

- **Alpha:** Basic class creation
- **Beta:** Mode configuration
- **GA:** Full integration
