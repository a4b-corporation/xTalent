---
id: ABS-POL-002
name: Leave Type Configuration
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
    - LeaveType
  rules:
    - rule_leave_type_unique_code
    - rule_half_day_requires_day_unit
    - rule_hourly_requires_hour_unit
  lifecycle: LeaveTypeLifecycle
  events: []

dependencies:
  requires: []
  required_by:
    - ABS-POL-001: "Leave Policy Definition"
    - ABS-POL-003: "Leave Class Configuration"
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-POL-002: Leave Type Configuration

> Cho phép HR cấu hình các loại nghỉ (Annual, Sick, Maternity, etc.).

---

## 1. Business Context

### Job Story
> **Khi** tôi muốn định nghĩa loại nghỉ,
> **tôi muốn** tạo và cấu hình LeaveType,
> **để** employees có thể xin nghỉ theo loại.

---

## 2. UI Workflow

### Leave Type Config Screen
- Code, name, description
- Unit code: DAY/HOUR
- Allows half-day: Yes/No
- Allows hourly: Yes/No
- Active/Inactive status

---

## 4. Business Rules

| Rule ID | Description |
|---------|-------------|
| [`rule_leave_type_unique_code`](../ontology/rules.yaml#L19) | Code phải duy nhất |
| [`rule_half_day_requires_day_unit`](../ontology/rules.yaml#L51) | Half-day requires DAY unit |
| [`rule_hourly_requires_hour_unit`](../ontology/rules.yaml#L62) | Hourly requires HOUR unit |

---

## 8. Acceptance Criteria

```gherkin
Scenario: Create leave type
  Given HR tạo Annual Leave
  Khi nhập code=ANNUAL, unit=DAY, allows_half_day=true
  Và save
  Thì LeaveType được tạo với status ACTIVE
```

---

## 9. Release Planning

- **Alpha:** Basic leave type creation
- **Beta:** Half-day, hourly config
- **GA:** Full lifecycle
