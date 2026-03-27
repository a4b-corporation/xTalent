---
id: ABS-BAL-001
name: View Leave Balance
module: TA
sub_module: ABS
category: Leave Balance Management
priority: P0
status: Specified
differentiation: Parity
gap_type: Standard Fit
phase: 1

ontology_refs:
  concepts:
    - LeaveInstant
    - LeaveBalance
    - LeaveType
  rules:
    - rule_instant_available_qty_formula
    - rule_wallet_available_hours_formula
  lifecycle: LeaveInstantLifecycle
  events: []

dependencies:
  requires: []
  required_by:
    - ABS-LR-001: "Create Leave Request - cần hiển thị balance"
    - ABS-APR-001: "Approve Leave Request - cần hiển thị balance"
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-BAL-001: View Leave Balance

> Cho phép nhân viên xem số dư nghỉ phép hiện tại cho từng loại nghỉ.

---

## 1. Business Context

### Job Story
> **Khi** tôi muốn xem số dư nghỉ phép của mình,
> **tôi muốn** xem tổng quan tất cả loại nghỉ,
> **để** biết mình còn bao nhiêu ngày để lên kế hoạch.

### Success Metrics
- Balance accuracy 100%
- Page load time ≤ 1s

---

## 2. UI Workflow & Mockup

### Balance Dashboard
- Cards cho mỗi LeaveType với: Available, Used, Accrued YTD
- Progress bar hiển thị % đã sử dụng
- Toggle: All types / Active only

---

## 3. System Events

N/A (read-only feature)

---

## 4. Business Rules

| Rule ID | Description |
|---------|-------------|
| [`rule_instant_available_qty_formula`](../ontology/rules.yaml#L221) | available_qty = current_qty - hold_qty |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Balance accuracy | 100% real-time |
| Load time | ≤ 1s at P95 |

---

## 6. Dependency Map

| Required By |
|-------------|
| ABS-LR-001, ABS-LR-002, ABS-APR-001 |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Employee chưa có LeaveInstant | Hiển thị "No leave balance available" |
| E2 | Negative balance (overdraft) | Hiển thị với warning badge |

---

## 8. Acceptance Criteria

```gherkin
Scenario: View leave balance
  Given employee có 10 days Annual Leave, 5 days Sick Leave
  Khi employee vào trang Balance
  Thì hiển thị:
    | Annual Leave: 10 days available |
    | Sick Leave: 5 days available |
```

---

## 9. Release Planning

- **Alpha:** Basic balance display
- **Beta:** Progress bars, YTD accrual
- **GA:** Full integration
