---
id: ABS-LR-009
name: Cancel Approved Request
module: TA
sub_module: ABS
category: Leave Request Management
priority: P1
status: Specified
differentiation: Parity
gap_type: Standard Fit
phase: 1

ontology_refs:
  concepts:
    - LeaveRequest
    - LeaveReservation
  rules:
    - rule_request_cannot_cancel_after_start
  lifecycle: LeaveRequestLifecycle
  events:
    - LeaveRequestCancelled
    - LeaveReservationReleased

dependencies:
  requires:
    - ABS-LR-002: "Submit Leave Request"
    - ABS-APR-001: "Approve Leave Request"
  required_by: []
  external:
    - "Notification Service"
    - "Payroll Service (optional)"

created: 2026-03-13
author: BA Team
---

# ABS-LR-009: Cancel Approved Request

> Cho phép nhân viên hủy đơn nghỉ đã được phê duyệt trước khi start date.

---

## 1. Business Context

### Job Story
> **Khi** kế hoạch thay đổi và tôi cần hủy đơn đã được approve,
> **tôi muốn** cancel approved request,
> **để** số dư được restore và manager biết.

### Success Metrics
- Cancel success rate ≥ 98%
- Balance restore accuracy 100%

---

## 2. UI Workflow

### Screen Flow
```
[Request Detail (APPROVED)]
       ↓
[Cancel Button - visible if start_date > today]
       ↓
[Cancel Modal (reason required)]
       ↓
[Confirm] → [Success]
```

### Cancel Conditions
- Only allowed if start_date > today
- Not allowed if start_date đã qua (phải dùng adjustment)
- Reason bắt buộc

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveRequestCancelled` | Employee cancels | request_id, cancelled_at, cancellation_reason |
| `LeaveReservationReleased` | (auto) | reservation_id, released_qty |

---

## 4. Business Rules

| Rule ID | Description |
|---------|-------------|
| [`rule_request_cannot_cancel_after_start`](../ontology/rules.yaml#L461) | Cannot cancel after start date |

### Feature-specific Rules
| Rule | Condition | Action |
|------|-----------|--------|
| Reason required | Cancel action | Min 10 chars |
| Balance restore | Cancel successful | Auto-restore reserved balance |
| Manager notification | Cancel successful | Notify manager |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Cancel response time | ≤ 500ms |
| Balance restore | Immediate |

---

## 6. Dependency Map

| Requires | Reason |
|----------|--------|
| ABS-LR-002 | Cần đơn đã submit |
| ABS-APR-001 | Cần đơn đã approve |

| Required By |
|-------------|
| ABS-BAL-005 (Balance update) |

---

## 7. Edge & Corner Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Start date = tomorrow | Allowed với warning |
| E2 | Team already staffed replacement | Warning: "Team đã sắp xếp người thay thế" |
| E3 | Cancel sau start date | Hidden button, error nếu cố cancel |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-LR-009 - Cancel Approved Request

  Scenario: Cancel approved request trước start date
    Given request ở status APPROVED
    And start_date = 2026-04-15 (future)
    Khi employee click "Cancel" và nhập lý do
    Và confirm
    Thì status chuyển sang CANCELLED
    Và balance được restore
    Và LeaveRequestCancelled event emitted

  Scenario: Cannot cancel sau start date
    Given request ở status APPROVED
    And start_date = 2026-04-01 (past)
    Khi employee xem chi tiết
    Thì nút "Cancel" bị ẩn hoặc disabled
```

---

## 9. Release Planning

- **Alpha:** Cancel cơ bản trước start date
- **Beta:** Warning for late cancellation, notifications
- **GA:** Payroll integration (nếu đã payout)

### Out of Scope (v1)
- Cancel với approval workflow
- Partial cancellation (cancel một phần ngày)
