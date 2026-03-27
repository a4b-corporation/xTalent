---
id: ABS-APR-002
name: Reject Leave Request
module: TA
sub_module: ABS
category: Leave Approval
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
    - rule_reservation_auto_release_on_reject
  lifecycle: LeaveRequestLifecycle
  events:
    - LeaveRequestRejected
    - LeaveReservationReleased

dependencies:
  requires:
    - ABS-LR-002: "Submit Leave Request"
    - ABS-APR-001: "Approve flow - same detail view"
  required_by:
    - ABS-LR-003: "View status update"
  external:
    - "Notification Service"

created: 2026-03-13
author: BA Team
---

# ABS-APR-002: Reject Leave Request

> Cho phép quản lý từ chối đơn xin nghỉ của nhân viên với lý do.

---

## 1. Business Context

### Job Story
> **Khi** đơn xin nghỉ của nhân viên không phù hợp,
> **tôi muốn** từ chối với lý do rõ ràng,
> **để** nhân viên hiểu và có kế hoạch khác.

### Success Metrics
- Reject success rate ≥ 99%
- Rejection reason provided ≥ 95%

---

## 2. UI Workflow & Mockup

### Screen Flow
```
[Request Detail] → [Click Reject] → [Reject Modal (reason required)] → [Confirm] → [Success]
```

### Reject Modal Requirements
- Reason textarea (required, min 10 characters)
- Pre-defined reasons dropdown (optional):
  - "Insufficient staffing during this period"
  - "Insufficient leave balance"
  - "Project deadline conflict"
  - "Other (please specify)"

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveRequestRejected` | Manager rejects | request_id, rejected_at, rejected_by, rejection_reason |
| `LeaveReservationReleased` | (auto) | reservation_id, released_qty, released_reason=REJECTED |

---

## 4. Business Rules

| Rule ID | Description |
|---------|-------------|
| [`rule_reservation_auto_release_on_reject`](../ontology/rules.yaml#L512) | Auto-release reservation on reject |

### Feature-specific Rules
| Rule | Condition | Action |
|------|-----------|--------|
| Reason required | Reject action | Bắt buộc nhập lý do (min 10 chars) |
| Status transition | SUBMITTED/PENDING → REJECTED | Valid transition only |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Reject response time | ≤ 500ms |
| Reason min length | 10 characters |

---

## 6. Dependency Map

| Requires | Reason |
|----------|--------|
| ABS-LR-002 | Cần đơn đã submit |
| ABS-APR-001 | Same detail view |

---

## 7. Edge & Corner Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Request already approved | Error: "Cannot reject approved request" |
| E2 | Reason < 10 chars | Block submit, show error |
| E3 | Two managers reject cùng lúc | Idempotent - chỉ reject 1 lần |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-APR-002 - Reject Leave Request

  Scenario: Reject with reason
    Given request ở status SUBMITTED
    Khi manager nhập lý do "Insufficient staffing"
    Và click "Reject" và confirm
    Thì status chuyển sang REJECTED
    Và reservation được release
    Và employee nhận notification với lý do

  Scenario: Cannot reject without reason
    Khi manager click "Reject" không nhập lý do
    Thì button "Confirm" bị disable
    Và hiển thị error "Reason is required"
```

---

## 9. Release Planning

- **Alpha:** Reject cơ bản với reason required
- **Beta:** Pre-defined reasons, notifications
- **GA:** Full integration

### Out of Scope (v1)
- Reject với alternative date suggestion
- Appeal workflow
