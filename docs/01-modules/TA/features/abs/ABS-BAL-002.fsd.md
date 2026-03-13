---
id: ABS-BAL-002
name: Leave Balance History
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
    - LeaveMovement
    - LeaveInstant
  rules: []
  lifecycle: LeaveMovementLifecycle
  events: []

dependencies:
  requires:
    - ABS-BAL-001: "View Leave Balance"
  required_by: []
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-BAL-002: Leave Balance History

> Hiển thị lịch sử biến động số dư nghỉ phép với chi tiết movements.

---

## 1. Business Context

### Job Story
> **Khi** tôi muốn xem lịch sử thay đổi số dư,
> **tôi muốn** xem timeline movements,
> **để** hiểu số dư thay đổi như thế nào.

---

## 2. UI Workflow

### History Timeline
- Filter by date range, leave type, event type
- Group by month
- Mỗi movement: Date, Type (ACCRUAL/USED/CARRY/etc.), Qty, Running Balance

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Running balance | Sau mỗi movement | Recalculate running balance |

---

## 5. NFRs

| NFR | Target |
|-----|--------|
| Load time | ≤ 1s |
| History retention | 7 years |

---

## 8. Acceptance Criteria

```gherkin
Scenario: View balance history
  Given employee có 3 movements trong tháng
  Khi employee xem history
  Thì hiển thị timeline với running balance sau mỗi movement
```

---

## 9. Release Planning

- **Alpha:** Basic timeline
- **Beta:** Filters, running balance
- **GA:** Export, full retention
