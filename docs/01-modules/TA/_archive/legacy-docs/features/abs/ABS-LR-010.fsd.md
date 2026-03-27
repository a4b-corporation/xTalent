---
id: ABS-LR-010
name: Modify Pending Request
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
  rules:
    - rule_request_status_transition_valid
  lifecycle: LeaveRequestLifecycle
  events:
    - LeaveRequested

dependencies:
  requires:
    - ABS-LR-001: "Create Leave Request"
    - ABS-LR-002: "Submit Leave Request"
  required_by: []
  external:
    - "Notification Service"

created: 2026-03-13
author: BA Team
---

# ABS-LR-010: Modify Pending Request

> Cho phép nhân viên sửa đổi đơn nghỉ đang chờ phê duyệt.

---

## 1. Business Context

### Job Story
> **Khi** đơn của tôi đang chờ và tôi cần thay đổi thông tin,
> **tôi muốn** sửa đơn pending,
> **để** không cần cancel và tạo mới.

### Success Metrics
- Modify success rate ≥ 98%
- Manager re-notification rate 100%

---

## 2. UI Workflow

### Screen Flow
```
[Request Detail (SUBMITTED/PENDING)]
       ↓
[Edit Button - visible if status = SUBMITTED/PENDING]
       ↓
[Edit Form (pre-filled với current data)]
       ↓
[Save Changes] → [Re-validate] → [Success]
```

### Modify Conditions
- Only allowed if status = SUBMITTED or PENDING
- Re-validation sau khi sửa
- Manager notification sau khi sửa thành công

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveRequested` | Modify successful | request_id, updated_fields, modified_at |

---

## 4. Business Rules

### Feature-specific Rules
| Rule | Condition | Action |
|------|-----------|--------|
| Status check | Modify action | Only SUBMITTED/PENDING allowed |
| Re-validation | Sau khi sửa | Validate như tạo mới |
| Manager notification | Modify successful | Re-notify manager |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Modify response time | ≤ 500ms |
| Re-validation | Full validation |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Manager đã approve trước khi modify | Lock edit, error "Request already approved" |
| E2 | Modify làm balance không đủ | Block save, error |
| E3 | Modify ngày trùng với approved request | Block save, error |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-LR-010 - Modify Pending Request

  Scenario: Modify pending request
    Given request ở status SUBMITTED
    Khi employee click "Edit", thay đổi ngày
    Và save
    Thì request được update
    Và manager nhận notification về thay đổi

  Scenario: Cannot modify approved request
    Given request ở status APPROVED
    Khi employee xem chi tiết
    Thì nút "Edit" bị ẩn
```

---

## 9. Release Planning

- **Alpha:** Modify cơ bản (dates, reason)
- **Beta:** Full field editing, re-validation
- **GA:** Full integration

### Out of Scope (v1)
- Modify leave type (phải cancel + tạo mới)
- Version history cho modifications
