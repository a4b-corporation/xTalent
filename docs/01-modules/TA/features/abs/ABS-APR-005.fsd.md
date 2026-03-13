---
id: ABS-APR-005
name: Batch Approval
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
    - ABS-APR-001: "Approve Leave Request - base approval"
    - ABS-APR-002: "Reject Leave Request - base rejection"
  required_by: []
  external:
    - "Notification Service"

created: 2026-03-13
author: BA Team
---

# ABS-APR-005: Batch Approval

> Cho phép quản lý phê duyệt hoặc từ chối nhiều đơn nghỉ cùng lúc.

---

## 1. Business Context

### Job Story
> **Khi** tôi có nhiều đơn nghỉ cần phê duyệt,
> **tôi muốn** approve/reject hàng loạt,
> **để** tiết kiệm thời gian xử lý.

### Success Metrics
- Batch approval time ≤ 2s per 10 requests
- Manager satisfaction ≥ 4.5/5

---

## 2. UI Workflow & Mockup

### Batch Approval Screen
- Checkbox cho mỗi request
- "Select All" option
- Filter trước khi batch action
- Bulk Approve / Bulk Reject buttons
- Confirmation modal với summary

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveRequestApproved` (multiple) | Batch approve | Array of request_ids |
| `LeaveRequestRejected` (multiple) | Batch reject | Array of request_ids |

---

## 4. Business Rules

### Feature-specific Rules
| Rule | Condition | Action |
|------|-----------|--------|
| Same action | Batch phải cùng action (approve hoặc reject) | Separate buttons |
| Validation per request | Mỗi request validation riêng | Skip invalid requests với warning |
| Partial success | Một số approve được, một số lỗi | Process继续, report kết quả |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Batch size | Support up to 100 requests per batch |
| Processing time | ≤ 5s for 100 requests |

---

## 6. Dependency Map

| Requires | Reason |
|----------|--------|
| ABS-APR-001 | Base approval |
| ABS-APR-002 | Base rejection |

---

## 7. Edge & Corner Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Request đã được approve trước khi batch process | Skip với warning |
| E2 | Batch > 100 requests | Split thành multiple batches |
| E3 | Network failure giữa batch | Rollback hoặc resume từ failed point |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-APR-005 - Batch Approval

  Scenario: Batch approve 5 requests
    Given 5 requests ở status SUBMITTED
    Khi manager chọn cả 5 và click "Batch Approve"
    Và confirm
    Thì cả 5 requests chuyển sang APPROVED
    Và 5 LeaveRequestApproved events emitted

  Scenario: Partial batch success
    Given 5 requests, 2 đã được approve trước đó
    Khi manager batch approve
    Thì 3 requests mới được approve
    Và 2 requests cũ được skip với warning
```

---

## 9. Release Planning

- **Alpha:** Batch approve cơ bản (≤ 20 requests)
- **Beta:** Batch reject, up to 100 requests
- **GA:** Partial success handling, detailed report

### Out of Scope (v1)
- Scheduled batch approval
- Conditional batch rules
