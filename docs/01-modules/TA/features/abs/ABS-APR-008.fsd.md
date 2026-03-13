---
id: ABS-APR-008
name: View Approval History
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
    - ABS-LR-003: "View Leave Request Status"
    - ABS-APR-007: "Approval Comments"
  required_by: []
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-APR-008: View Approval History

> Hiển thị lịch sử phê duyệt với timeline đầy đủ cho mỗi đơn nghỉ.

---

## 1. Business Context

### Job Story
> **Khi** tôi muốn xem ai đã approve đơn của mình,
> **tôi muốn** xem timeline phê duyệt,
> **để** biết quy trình đã qua những ai.

---

## 2. UI Workflow

### Approval History Timeline
- Hiển thị trong Request Detail
- Mỗi level approval: Who, When, Comment, Action
- Status badges với màu sắc

---

## 3. System Events

N/A (read-only feature)

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Visibility | Employee xem được tất cả approvals của đơn mình | Full timeline |
| Manager view | Manager chỉ xem được đơn mình approve | Filtered |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Load time | ≤ 500ms |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Multi-level approval | Hiển thị đầy đủ các levels |
| E2 | Delegate approval | Hiển thị "Approved by X (delegate for Y)" |

---

## 8. Acceptance Criteria

```gherkin
Scenario: View approval history
  Given request đã được approve qua 2 levels
  Khi employee xem chi tiết
  Thì hiển thị timeline với:
    | Level 1: Manager A, approved at, comment |
    | Level 2: Manager B, approved at, comment |
```

---

## 9. Release Planning

- **Alpha:** Timeline cơ bản
- **Beta:** Multi-level display, delegate notation
- **GA:** Full integration
