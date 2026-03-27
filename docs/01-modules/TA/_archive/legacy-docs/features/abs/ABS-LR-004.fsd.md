---
id: ABS-LR-004
name: Withdraw Leave Request
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
    - LeaveReservation
  rules:
    - rule_request_cannot_cancel_after_start
    - rule_reservation_auto_release_on_cancel
  lifecycle: LeaveRequestLifecycle
  events:
    - LeaveRequestWithdrawn
    - LeaveReservationReleased

dependencies:
  requires:
    - ABS-LR-002: "Submit Leave Request - cần đơn đã submit"
  required_by: []
  external:
    - "Notification Service"

created: 2026-03-13
author: BA Team
---

# ABS-LR-004: Withdraw Leave Request

> Cho phép nhân viên rút lại đơn nghỉ đang chờ phê duyệt trước khi được approve.

---

## 1. Business Context

### Job Story
> **Khi** kế hoạch nghỉ của tôi thay đổi và đơn chưa được approve,
> **tôi muốn** rút lại đơn đang chờ,
> **để** số dư được release và manager không cần xử lý nữa.

### Success Metrics
- Withdraw success rate ≥ 98%
- Reservation release time ≤ 1s

---

## 2. UI Workflow & Mockup

### Screen Flow
```
[Request Detail] → [Withdraw Button] → [Confirm Modal] → [Success]
                          ↓
                    [Only shown if status = SUBMITTED/PENDING]
```

### Withdraw Conditions
- Only allowed if status = SUBMITTED or PENDING
- Not allowed if status = APPROVED (phải dùng ABS-LR-009 Cancel)
- Not allowed if start date đã qua

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveRequestWithdrawn` | Employee withdraws | request_id, employee_id, withdrawn_at |
| `LeaveReservationReleased` | (auto) | reservation_id, request_id, released_qty, released_reason=WITHDRAWN |

---

## 4. Business Rules

| Rule ID | Description |
|---------|-------------|
| [`rule_request_cannot_cancel_after_start`](../ontology/rules.yaml#L461) | Cannot withdraw after start date |
| [`rule_reservation_auto_release_on_cancel`](../ontology/rules.yaml#L526) | Auto-release reservation on withdraw |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Withdraw response time | ≤ 500ms |
| Reservation release | Immediate (within 1s) |

---

## 6. Dependency Map

| Requires | Reason |
|----------|--------|
| ABS-LR-002 | Cần đơn đã submit |

| Required By |
|-------------|
| ABS-LR-003 (View Status update) |

---

## 7. Edge & Corner Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Status thay đổi từ SUBMITTED → APPROVED khi user đang xem confirm modal | Re-validate khi confirm, error nếu đã approve |
| E2 | Withdraw ngày trước start date 1 ngày | Allowed với warning |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-LR-004 - Withdraw Leave Request

  Scenario: Withdraw pending request
    Given request ở status SUBMITTED
    Khi employee click "Withdraw" và confirm
    Thì status chuyển sang WITHDRAWN
    Và reservation được release
    Và LeaveRequestWithdrawn event emitted

  Scenario: Cannot withdraw approved request
    Given request ở status APPROVED
    Khi employee xem chi tiết
    Thì nút "Withdraw" bị ẩn hoặc disabled
```

---

## 9. Release Planning

- **Alpha:** Withdraw cơ bản cho status SUBMITTED
- **Beta:** Full validation, notifications
- **GA:** All edge cases

### Out of Scope (v1)
- Withdraw với reason bắt buộc
- Withdraw approval workflow (cho manager withdraw)
