---
id: ABS-LR-008
name: Leave Request Comments
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
  rules: []
  lifecycle: LeaveRequestLifecycle
  events:
    - LeaveRequested
    - LeaveRequestApproved

dependencies:
  requires:
    - ABS-LR-001: "Create Leave Request - base functionality"
  required_by:
    - ABS-APR-007: "Approval Comments - manager comments"
  external:
    - "Notification Service"

created: 2026-03-13
author: BA Team
---

# ABS-LR-008: Leave Request Comments

> Cho phép nhân viên thêm ghi chú, lý do chi tiết vào đơn nghỉ và xem comments từ manager.

---

## 1. Business Context

### Job Story
> **Khi** tôi muốn giải thích rõ hơn về lý do nghỉ,
> **tôi muốn** thêm comments vào đơn,
> **để** quản lý hiểu rõ hơn và phê duyệt nhanh hơn.

### Success Metrics
- Comment submission rate ≥ 99%
- User satisfaction ≥ 4.5/5

---

## 2. UI Workflow & Mockup

### UI Specifics
- Textarea trong form tạo đơn (ABS-LR-001)
- Max length: 1000 characters
- Character counter hiển thị
- Comments timeline hiển thị trong Request Detail
- Manager có thể reply comments

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveRequested` | Submit với comments | reason: string (max 1000 chars) |
| `CommentAdded` | Thêm comment mới | request_id, author_id, comment_text, timestamp |

---

## 4. Business Rules

### Feature-specific Rules
| Rule | Condition | Action |
|------|-----------|--------|
| Profanity filter | Thêm comment | Filter từ ngữ không phù hợp |
| Edit window | Sau khi post comment | Edit được trong 5 phút, sau đó read-only |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Comment load time | ≤ 500ms |
| Max length | 1000 characters |

---

## 6. Dependency Map

| Requires | Reason |
|----------|--------|
| ABS-LR-001 | Base create request |

| Required By |
|-------------|
| ABS-APR-007 (Manager approval comments) |

---

## 7. Edge & Corner Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Comment > 1000 chars | Block submit, hiển thị counter |
| E2 | Profanity detected | Auto-filter với warning |
| E3 | Edit sau 5 phút | Disable edit button |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-LR-008 - Leave Request Comments

  Scenario: Add comment when creating request
    Given employee đang tạo leave request
    Khi employee nhập lý do trong textarea
    Và submit
    Thì comment được lưu với request
    Và hiển thị trong request detail

  Scenario: Character limit
    Khi employee nhập > 1000 characters
    Thì không thể nhập thêm
    Và hiển thị "1000/1000 characters"

  Scenario: Manager reply
    Given employee đã thêm comment
    Khi manager reply với approval comment
    Thì employee thấy reply trong timeline
```

---

## 9. Release Planning

- **Alpha:** Comment field trong form tạo đơn
- **Beta:** Comments timeline, manager replies
- **GA:** Edit window, profanity filter

### Out of Scope (v1)
- @mentions trong comments
- File attachments trong comments (riêng ABS-LR-007)
- Email notifications cho comment replies
