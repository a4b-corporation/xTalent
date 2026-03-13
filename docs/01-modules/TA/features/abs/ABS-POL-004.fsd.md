---
id: ABS-POL-004
name: Eligibility Rules
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
    - LeavePolicy
  rules: []
  lifecycle: []
  events: []

dependencies:
  requires:
    - ABS-POL-003: "Leave Class Configuration"
  required_by:
    - ABS-LR-001: "Create Leave Request - eligibility check"
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-POL-004: Eligibility Rules

> Cho phép HR cấu hình eligibility rules cho leave classes.

---

## 1. Business Context

### Job Story
> **Khi** tôi muốn định nghĩa ai được eligible cho leave,
> **tôi muốn** cấu hình eligibility rules,
> **để** hệ thống tự động xác định employee eligibility.

---

## 2. UI Workflow

### Eligibility Config Screen
- Tenure requirement (months)
- Employment type requirement (Full-time/Part-time)
- Grade/Level requirement
- Probation status requirement

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Eligibility check | Employee tạo request | Validate eligibility trước khi allow |

---

## 8. Acceptance Criteria

```gherkin
Scenario: Create eligibility rule
  Given HR tạo rule cho Annual Leave
  Khi set tenure >= 12 months, employment_type = Full-time
  Và save
  Thì rule được áp dụng cho eligibility check
```

---

## 9. Release Planning

- **Alpha:** Basic tenure rule
- **Beta:** Multiple criteria
- **GA:** Full integration
