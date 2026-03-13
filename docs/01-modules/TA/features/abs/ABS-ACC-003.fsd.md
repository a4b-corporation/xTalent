---
id: ABS-ACC-003
name: Manual Grant Leave
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
    - LeaveInstantDetail
    - LeaveMovement
  rules: []
  lifecycle: LeaveInstantDetailLifecycle
  events:
    - LeaveGrantCreated

dependencies:
  requires:
    - ABS-BAL-001: "View Leave Balance"
  required_by:
    - ABS-BAL-007: "Balance Adjustment"
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-ACC-003: Manual Grant Leave

> Cho phép HR cấp nghỉ thủ công (special grant, bonus) cho employee.

---

## 1. Business Context

### Job Story
> **Khi** tôi muốn thưởng ngày phép cho employee,
> **tôi muốn** cấp manual grant,
> **để** employee có thêm ngày nghỉ.

---

## 2. UI Workflow

### Grant Screen
- Select employee, leave type
- Enter qty, reason
- Set有效期 (expire date)
- Submit → Create grant lot

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveGrantCreated` | Grant successful | detail_id, lot_qty, eff_date, expire_date |

---

## 5. NFRs

| NFR | Target |
|-----|--------|
| Grant processing | ≤ 1s |

---

## 8. Acceptance Criteria

```gherkin
Scenario: Manual grant leave
  Given HR chọn employee và leave type
  Khi nhập 5 days bonus với expire_date
  Và submit
  Thì employee có thêm 5 days
  Và LeaveGrantCreated event emitted
```

---

## 9. Release Planning

- **Alpha:** Basic grant
- **Beta:** Expiry, reason tracking
- **GA:** Full audit trail
