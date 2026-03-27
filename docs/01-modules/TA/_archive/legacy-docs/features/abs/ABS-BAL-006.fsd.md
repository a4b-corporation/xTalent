---
id: ABS-BAL-006
name: Multi-Class Balance View
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
    - LeaveClass
    - LeaveType
  rules: []
  lifecycle: []
  events: []

dependencies:
  requires:
    - ABS-BAL-001: "View Leave Balance"
  required_by: []
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-BAL-006: Multi-Class Balance View

> Hiển thị số dư nghỉ phép theo LeaveClass (department-specific policies).

---

## 1. Business Context

### Job Story
> **Khi** tôi có nhiều LeaveClasses (Annual, Sick, Bereavement),
> **tôi muốn** xem số dư cho mỗi class,
> **để** biết chính xác số dư cho từng loại.

---

## 2. UI Workflow

### Grouped Balance View
- Group by LeaveType
- Expand để xem chi tiết LeaveClasses
- Tooltip giải thích khác biệt giữa classes

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Aggregation | Same LeaveType, multiple classes | Sum available_qty |

---

## 5. NFRs

| NFR | Target |
|-----|--------|
| Load time | ≤ 1s |

---

## 8. Acceptance Criteria

```gherkin
Scenario: View multi-class balance
  Given employee có 2 LeaveClasses cho Annual Leave
  Khi employee xem balance
  Thì hiển thị:
    | Annual Leave: 15 days total |
    |  ├── Standard: 10 days |
    |  └── Bonus: 5 days |
```

---

## 9. Release Planning

- **Alpha:** Basic grouping
- **Beta:** Expandable details
- **GA:** Full integration
