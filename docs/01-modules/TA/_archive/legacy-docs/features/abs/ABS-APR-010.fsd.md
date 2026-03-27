---
id: ABS-APR-010
name: Parallel Approval
module: TA
sub_module: ABS
category: Leave Approval
priority: P1
status: Specified
differentiation: Innovation
gap_type: Extension Gap
phase: 1

ontology_refs:
  concepts:
    - LeaveRequest
  rules: []
  lifecycle: LeaveRequestLifecycle
  events:
    - LeaveRequestApproved
    - LeaveRequestRejected

dependencies:
  requires:
    - ABS-APR-003: "Multi-Level Approval"
  required_by: []
  external:
    - "Notification Service"

created: 2026-03-13
author: BA Team
---

# ABS-APR-010: Parallel Approval

> Cho phép phê duyệt song song (nhiều approvers cùng lúc) thay vì sequential.

---

## 1. Business Context

### Job Story
> **Khi** đơn cần nhiều người duyệt độc lập,
> **tôi muốn** gửi đến tất cả cùng lúc,
> **để** giảm thời gian chờ đợi.

### Success Metrics
- Approval cycle time reduction ≥ 50%
- Approver satisfaction ≥ 4.0/5

---

## 2. UI Workflow

### Parallel Approval Config
- Select multiple approvers
- Approval mode: All must approve / Any can approve
- Notification template

### Approver View
- Hiển thị "Parallel approval with X others"
- See who else is approving

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveRequestApproved` | Any approver approves | approver_id, pending_count |

---

## 4. Business Rules

### Feature-specific Rules
| Rule | Condition | Action |
|------|-----------|--------|
| All-approve mode | All approvers phải approve | Request approved khi tất cả approve |
| Any-approve mode | Any approver có thể approve | Request approved khi 1 người approve |
| Reject any | Any approver reject | Request rejected |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Notification | Gửi đến tất cả approvers cùng lúc |
| Status sync | Real-time update cho tất cả |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | One approver approves, one rejects | First action wins, notify others |
| E2 | Approver không phản hồi | Escalation sau timeout (optional) |
| E3 | Duplicate approvers | Deduplicate tự động |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-APR-010 - Parallel Approval

  Scenario: Parallel approval - all must approve
    Given 2 approvers, mode = all-approve
    Khi Approver A approves
    Thì request vẫn pending chờ Approver B
    Khi Approver B approves
    Thì request = APPROVED

  Scenario: Parallel approval - any can approve
    Given 2 approvers, mode = any-approve
    Khi Approver A approves
    Thì request = APPROVED (không cần B)
    Và B nhận notification "Already approved by A"
```

---

## 9. Release Planning

- **Alpha:** All-approve mode cơ bản
- **Beta:** Any-approve mode, config UI
- **GA:** Full integration với escalation

### Out of Scope (v1)
- Weighted approval (manager có quyền cao hơn)
- Conditional parallel routing
