---
id: ABS-APR-007
name: Approval Comments
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
  rules: []
  lifecycle: LeaveRequestLifecycle
  events:
    - LeaveRequestApproved
    - LeaveRequestRejected

dependencies:
  requires:
    - ABS-APR-001: "Approve Leave Request"
    - ABS-APR-002: "Reject Leave Request"
  required_by:
    - ABS-APR-008: "View Approval History"
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-APR-007: Approval Comments

> Cho phép quản lý thêm nhận xét khi phê duyệt hoặc từ chối đơn nghỉ.

---

## 1. Business Context

### Job Story
> **Khi** tôi approve hoặc reject đơn,
> **tôi muốn** thêm comments,
> **để** nhân viên hiểu rõ quyết định của mình.

### Success Metrics
- Comment attachment rate ≥ 90%

---

## 2. UI Workflow

### Approval Comment
- Optional textarea trong approve modal
- Placeholder: "Add your approval comments (optional)"

### Rejection Comment
- Required textarea trong reject modal
- Min 10 characters

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveRequestApproved` | Approve | approver_comment |
| `LeaveRequestRejected` | Reject | rejection_reason |

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Reject comment required | Reject action | Min 10 chars |
| Approve comment optional | Approve action | Max 500 chars |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Comment length | Max 500 chars |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Comment > 500 chars | Block submit |

---

## 8. Acceptance Criteria

```gherkin
Scenario: Approve với comment
  Khi manager approve với comment "Enjoy your vacation!"
  Thì comment được lưu trong approval history

Scenario: Reject không có comment
  Khi manager reject không nhập lý do
  Thì hiển thị error "Reason is required"
```

---

## 9. Release Planning

- **Alpha:** Comments cơ bản
- **Beta:** Required for reject, optional for approve
- **GA:** Full integration
