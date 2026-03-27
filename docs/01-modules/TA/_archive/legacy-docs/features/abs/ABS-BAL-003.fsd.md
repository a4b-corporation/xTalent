---
id: ABS-BAL-003
name: Leave Balance Projection
module: TA
sub_module: ABS
category: Leave Balance Management
priority: P1
status: Specified
differentiation: Parity
gap_type: Standard Fit
phase: 1

ontology_refs:
  concepts:
    - LeaveInstant
    - LeavePolicy
  rules: []
  lifecycle: []
  events: []

dependencies:
  requires:
    - ABS-BAL-001: "View Leave Balance"
    - ABS-ACC-001: "Monthly Accrual Run"
  required_by: []
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-BAL-003: Leave Balance Projection

> Dự kiến số dư nghỉ phép trong tương lai dựa trên accrual schedule và pending requests.

---

## 1. Business Context

### Job Story
> **Khi** tôi muốn lên kế hoạch nghỉ trong tương lai,
> **tôi muốn** xem balance projection,
> **để** biết mình sẽ có bao nhiêu ngày vào thời điểm đó.

---

## 2. UI Workflow

### Projection Screen
- Date picker: Chọn future date
- Projection breakdown:
  - Current balance
  + Future accruals (đến ngày chọn)
  - Pending requests (đã submit chưa approve)
  - Approved future requests
  = Projected balance

---

## 4. Business Rules

### Feature-specific Rules
| Rule | Condition | Action |
|------|-----------|--------|
| Accrual projection | Dựa vào policy accrual frequency | Calculate future accruals |
| Pending deduction | Pending requests | Deduct từ projection |

---

## 5. NFRs

| NFR | Target |
|-----|--------|
| Calculation time | ≤ 500ms |
| Accuracy | ±1 day (do accrual timing) |

---

## 8. Acceptance Criteria

```gherkin
Scenario: Project balance 3 tháng tới
  Given current balance = 10 days
  And monthly accrual = 1.5 days
  And no pending requests
  Khi employee xem projection cho 3 tháng sau
  Thì projected balance = 10 + (1.5 × 3) = 13.5 days
```

---

## 9. Release Planning

- **Alpha:** Simple projection (current + accruals)
- **Beta:** Include pending/approved requests
- **GA:** Full accuracy
