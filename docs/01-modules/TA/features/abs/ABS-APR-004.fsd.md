---
id: ABS-APR-004
name: Delegate Approval
module: TA
sub_module: ABS
category: Leave Approval
priority: P0
status: Specified
differentiation: Parity
gap_type: Config Gap
phase: 1

ontology_refs:
  concepts:
    - LeaveRequest
    - LeaveReservation
  rules: []
  lifecycle: LeaveRequestLifecycle
  events:
    - LeaveRequestApproved
    - LeaveRequestRejected

dependencies:
  requires:
    - ABS-APR-001: "Approve Leave Request - base approval"
  required_by: []
  external:
    - "Notification Service"
    - "Org Hierarchy Service"

created: 2026-03-13
author: BA Team
---

# ABS-APR-004: Delegate Approval

> Cho phép quản lý ủy quyền phê duyệt cho người khác khi vắng mặt.

---

## 1. Business Context

### Job Story
> **Khi** tôi vắng mặt (nghỉ phép, công tác),
> **tôi muốn** ủy quyền phê duyệt đơn cho người khác,
> **để** đơn của nhân viên không bị tồn đọng.

### Success Metrics
- Delegation setup success rate ≥ 98%
- No approval delays due to manager absence

---

## 2. UI Workflow & Mockup

### Delegation Setup Screen
- Select delegate (dropdown từ cùng team hoặc manager khác)
- Date range (start date, end date)
- Scope: All requests hoặc specific types
- Auto-notification cho delegate

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `DelegationCreated` | Manager thiết lập delegation | manager_id, delegate_id, start_date, end_date |
| `LeaveRequestApproved` | Delegate approves | approved_by = delegate_id |

---

## 4. Business Rules

### Feature-specific Rules
| Rule | Condition | Action |
|------|-----------|--------|
| Delegation validity | Delegate phải có cùng hoặc cao hơn quyền hạn | Validate org hierarchy |
| Date range | Delegation chỉ active trong date range | Auto-expire sau end_date |
| Overlap prevention | Không cho thiết lập overlapping delegations | Error |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Delegation activation | Automatic based on date range |
| Notification | Delegate và employee biết về delegation |

---

## 6. Dependency Map

| Requires | Reason |
|----------|--------|
| ABS-APR-001 | Base approval |
| Org Hierarchy Service | Validate delegate |

---

## 7. Edge & Corner Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Delegate nghỉ phép trong delegation period | Chain delegation allowed |
| E2 | Manager quay lại sớm hơn end_date | Manual early termination option |
| E3 | Delegate rời công ty | Auto-invalidate delegation |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-APR-004 - Delegate Approval

  Scenario: Setup delegation
    Given manager sẽ vắng mặt từ 2026-04-01 đến 2026-04-15
    Khi manager chọn delegate là colleague
    Và activate delegation
    Thì delegate có quyền approve thay manager
    Và trong khoảng thời gian thiết lập

  Scenario: Delegate approves request
    Given delegation đang active
    Khi delegate approve single request
    Thì request được approve bình thường
    Và approval history hiển thị "Approved by {delegate} (delegate for {manager})"
```

---

## 9. Release Planning

- **Alpha:** Delegation setup cơ bản
- **Beta:** Auto-activation, notifications
- **GA:** Full integration với org hierarchy

### Out of Scope (v1)
- Auto-delegation based on calendar
- Bulk delegation setup
