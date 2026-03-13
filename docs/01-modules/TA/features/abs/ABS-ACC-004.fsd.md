---
id: ABS-ACC-004
name: Accrual History View
module: TA
sub_module: ABS
category: Leave Accrual
priority: P0
status: Specified
differentiation: Parity
gap_type: Standard Fit
phase: 1

ontology_refs:
  concepts:
    - LeaveEventRun
    - LeaveMovement
  rules: []
  lifecycle: []
  events: []

dependencies:
  requires:
    - ABS-ACC-001: "Monthly Accrual Run"
  required_by: []
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-ACC-004: Accrual History View

> Hiển thị lịch sử tích lũy nghỉ phép cho employee.

---

## 1. Business Context

### Job Story
> **Khi** tôi muốn xem lịch sử accrual,
> **tôi muốn** xem timeline accruals,
> **để** biết mình được accrual như thế nào.

---

## 2. UI Workflow

### History Timeline
- Filter by date range, leave type
- Mỗi accrual: Date, Type, Qty, Running Balance
- Link đến accrual run details

---

## 5. NFRs

| NFR | Target |
|-----|--------|
| Load time | ≤ 1s |

---

## 8. Acceptance Criteria

```gherkin
Scenario: View accrual history
  Given employee có 3 accruals trong năm
  Khi employee xem history
  Thì hiển thị timeline với chi tiết mỗi accrual
```

---

## 9. Release Planning

- **Alpha:** Basic timeline
- **Beta:** Filters, details
- **GA:** Export
