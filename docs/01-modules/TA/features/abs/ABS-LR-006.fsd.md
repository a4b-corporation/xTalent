---
id: ABS-LR-006
name: Hourly Leave Request
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
    - rule_hourly_requires_hour_unit
  lifecycle: LeaveRequestLifecycle
  events:
    - LeaveRequested

dependencies:
  requires:
    - ABS-LR-001: "Create Leave Request - base functionality"
  required_by: []
  external:
    - "Timesheet Service - integration với timesheet"

created: 2026-03-13
author: BA Team
---

# ABS-LR-006: Hourly Leave Request

> Cho phép nhân viên xin nghỉ theo giờ cho các việc cá nhân ngắn hạn.

---

## 1. Business Context

### Job Story
> **Khi** tôi có việc cá nhân chỉ cần nghỉ vài giờ,
> **tôi muốn** tạo đơn nghỉ theo giờ,
> **để** chỉ sử dụng số giờ thực tế cần nghỉ.

### Success Metrics
- Hourly request success rate ≥ 98%
- Hour calculation accuracy 100%

---

## 2. UI Workflow & Mockup

### UI Specifics
- Duration Type: "Hourly"
- Time selection: Start time + End time hoặc Hours input
- Minimum: 1 giờ, Maximum: 8 giờ (1 ngày)
- Step: 0.5 giờ

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveRequested` | Submit hourly request | duration_type=HOURLY, hours=N |

---

## 4. Business Rules

| Rule ID | Description |
|---------|-------------|
| [`rule_hourly_requires_hour_unit`](../ontology/rules.yaml#L62) | Hourly only available if LeaveType.unit_code = HOUR |

### Feature-specific Rules
| Rule | Condition | Action |
|------|-----------|--------|
| Minimum duration | hourly request | Minimum 1 giờ |
| Maximum duration | hourly request | Maximum 8 giờ (1 ngày làm việc) |
| Conversion | Hourly to days | hours / 8 (với 8-hour workday) |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Calculation accuracy | 100% |
| Time picker precision | 30-minute increments |

---

## 6. Dependency Map

| Requires | Reason |
|----------|--------|
| ABS-LR-001 | Base create request |

---

## 7. Edge & Corner Cases

| # | Case | Handling |
|---|------|----------|
| E1 | LeaveType không cho phép hourly | Hide hourly option |
| E2 | Hours > 8 | Error: "Maximum 8 hours per request" |
| E3 | Hours < 1 | Error: "Minimum 1 hour" |
| E4 | Balance < requested hours | Block submit |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-LR-006 - Hourly Leave Request

  Scenario: Create hourly request
    Given LeaveType cho phép hourly
    Khi employee chọn 2 giờ cho ngày 2026-04-01
    Và submit
    Thì request được tạo với hours = 2
    Và balance bị trừ 0.25 ngày (2/8)

  Scenario: Minimum validation
    Khi employee nhập 0.5 giờ
    Thì hiển thị error "Minimum 1 hour"

  Scenario: Maximum validation
    Khi employee nhập 10 giờ
    Thì hiển thị error "Maximum 8 hours per request"
```

---

## 9. Release Planning

- **Alpha:** Hourly input cơ bản
- **Beta:** Validation, conversion
- **GA:** Timesheet integration

### Out of Scope (v1)
- Multi-day hourly requests
- Recurring hourly leave
