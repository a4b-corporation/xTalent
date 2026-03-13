---
id: ABS-APR-003
name: Multi-Level Approval
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
    - rule_request_status_transition_valid
  lifecycle: LeaveRequestLifecycle
  events:
    - LeaveRequestApproved
    - LeaveRequestRejected

dependencies:
  requires:
    - ABS-APR-001: "Approve Leave Request - base approval"
    - ABS-APR-002: "Reject Leave Request - base rejection"
  required_by:
    - ABS-APR-006: "Approval Escalation"
  external:
    - "Notification Service"
    - "Org Hierarchy Service"

created: 2026-03-13
author: BA Team
---

# ABS-APR-003: Multi-Level Approval

> Hỗ trợ phê duyệt nhiều cấp (manager → senior manager → HR) dựa trên cấu trúc tổ chức.

---

## 1. Business Context

### Job Story
> **Khi** đơn nghỉ cần phê duyệt từ nhiều cấp quản lý,
> **tôi muốn** tự động route qua từng cấp,
> **để** đảm bảo đúng quy trình phê duyệt.

### Success Metrics
- Multi-level routing accuracy 100%
- Average approval cycle time ≤ 24 hours per level

---

## 2. UI Workflow & Mockup

### Approval Chain Configuration
- Tự động xác định từ org hierarchy
- Hiển thị approval chain trong request detail
- Current approver highlighted

### Screen Flow
```
[Employee submits] → [Level 1: Direct Manager] → [Level 2: Senior Manager] → [Level 3: HR] → [APPROVED]
```

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveRequestApproved` | Any level approves | current_level, next_approver |
| `LeaveRequestRejected` | Any level rejects | rejected_by, rejected_at |

---

## 4. Business Rules

### Feature-specific Rules
| Rule | Condition | Action |
|------|-----------|--------|
| Sequential approval | Level N+1 chỉ thấy request sau khi Level N approve | Auto-route |
| Any-level reject | Bất kỳ level nào reject | Request status = REJECTED |
| Skip level option | Admin config cho phép skip level | Configurable |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Routing time | ≤ 1 minute per level |
| Max levels | Support up to 5 levels |

---

## 6. Dependency Map

| Requires | Reason |
|----------|--------|
| ABS-APR-001 | Base approval |
| ABS-APR-002 | Base rejection |
| Org Hierarchy Service | Xác định approval chain |

---

## 7. Edge & Corner Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Approver không có trong hệ thống | Escalate đến admin |
| E2 | Approver là same person | Auto-approve level tiếp theo |
| E3 | Circular hierarchy | Error log, fallback to single-level |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-APR-003 - Multi-Level Approval

  Scenario: 2-level approval flow
    Given request cần 2-level approval
    Khi Level 1 approve
    Thì request tự động route đến Level 2
    Và Level 2 nhận notification

  Scenario: Reject at any level
    Given request đang ở Level 2
    Khi Level 2 reject
    Thì status = REJECTED
    Và employee nhận notification
```

---

## 9. Release Planning

- **Alpha:** 2-level approval cơ bản
- **Beta:** Configurable levels, org hierarchy integration
- **GA:** Up to 5 levels, skip-level option

### Out of Scope (v1)
- Parallel approval (ABS-APR-010)
- Conditional routing (ABS-APR-009)
