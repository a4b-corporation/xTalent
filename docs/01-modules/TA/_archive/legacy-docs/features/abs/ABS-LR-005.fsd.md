---
id: ABS-LR-005
name: Half-Day Leave Request
module: TA
sub_module: ABS
category: Leave Request Management
priority: P0
status: Specified
differentiation: Parity
gap_type: Standard Fit
phase: 1

ontology_refs:
  concepts:
    - LeaveRequest
    - LeaveType
  rules:
    - rule_half_day_requires_day_unit
  lifecycle: LeaveRequestLifecycle
  events:
    - LeaveRequested

dependencies:
  requires:
    - ABS-LR-001: "Create Leave Request - base functionality"
  required_by: []
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-LR-005: Half-Day Leave Request

> Cho phép nhân viên xin nghỉ nửa ngày (AM hoặc PM) với loại nghỉ hỗ trợ half-day.

---

## 1. Business Context

### Job Story
> **Khi** tôi có việc cá nhân chỉ cần nghỉ nửa ngày,
> **tôi muốn** tạo đơn nghỉ half-day (AM hoặc PM),
> **để** chỉ sử dụng 0.5 ngày phép và làm việc nửa ngày còn lại.

### Success Metrics
- Half-day request success rate ≥ 98%
- Balance calculation accuracy 100%

---

## 2. UI Workflow & Mockup

### Screen Flow
```
[Create Request Form]
       ↓
[Duration Type = Half Day]
       ↓
[Select AM or PM]
       ↓
[0.5 day deduction calculation]
```

### UI Specifics
- Duration Type dropdown: "Half Day (AM)", "Half Day (PM)"
- Date picker: Single date only (không cho range)
- Balance calculation: 0.5 ngày cho bất kỳ loại nghỉ nào

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveRequested` | Submit half-day request | duration_type=HALF_AM or HALF_PM, qty_hours_req=0.5 |

---

## 4. Business Rules

| Rule ID | Description |
|---------|-------------|
| [`rule_half_day_requires_day_unit`](../ontology/rules.yaml#L51) | Half-day only available if LeaveType.unit_code = DAY |

### Feature-specific Rules
| Rule | Condition | Action |
|------|-----------|--------|
| Single date only | duration_type = HALF_AM hoặc HALF_PM | Only allow single date selection |
| Balance deduction | Half-day request | Deduct 0.5 days từ balance |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Calculation accuracy | 100% chính xác |
| UI clarity | AM/PM selection rõ ràng |

---

## 6. Dependency Map

| Requires | Reason |
|----------|--------|
| ABS-LR-001 | Base create request |

| Required By |
|-------------|
| ABS-LR-006 (Hourly Leave - mở rộng) |

---

## 7. Edge & Corner Cases

| # | Case | Handling |
|---|------|----------|
| E1 | LeaveType không cho phép half-day | Hide half-day option trong dropdown |
| E2 | User chọn half-day cho ngày cuối tuần | Warning: "Ngày này là cuối tuần" |
| E3 | Balance < 0.5 | Block submit với error |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-LR-005 - Half-Day Leave Request

  Scenario: Create AM half-day request
    Given LeaveType cho phép half-day
    Khi employee chọn "Half Day (AM)" cho ngày 2026-04-01
    Và submit
    Thì request được tạo với duration_type = HALF_AM
    Và balance bị trừ 0.5 ngày

  Scenario: Create PM half-day request
    Given LeaveType cho phép half-day
    Khi employee chọn "Half Day (PM)" cho ngày 2026-04-01
    Và submit
    Thì request được tạo với duration_type = HALF_PM
    Và balance bị trừ 0.5 ngày

  Scenario: Cannot select date range for half-day
    Khi employee chọn half-day
    Thì chỉ cho phép chọn 1 ngày (disable multi-date)
```

---

## 9. Release Planning

- **Alpha:** Half-day AM/PM cơ bản
- **Beta:** Validation, balance calculation
- **GA:** Full integration với calendar

### Out of Scope (v1)
- Hourly leave (ABS-LR-006)
- Custom hour duration cho half-day
