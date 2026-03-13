---
id: ABS-APR-001
name: Approve Leave Request
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
    - LeaveInstant
  rules:
    - rule_reservation_unhold_on_start_post
    - rule_request_status_transition_valid
  lifecycle: LeaveRequestLifecycle
  events:
    - LeaveRequestApproved

dependencies:
  requires:
    - ABS-LR-002: "Submit Leave Request - cần đơn đã submit"
    - ABS-LR-003: "View Leave Request Status - hiển thị danh sách"
  required_by:
    - ABS-LR-003: "View status update"
    - ABS-APR-008: "View approval history"
  external:
    - "Notification Service"
    - "Team Calendar Service"

created: 2026-03-13
author: BA Team
---

# ABS-APR-001: Approve Leave Request

> Cho phép quản lý phê duyệt đơn xin nghỉ của nhân viên với đầy đủ thông tin và context.

---

## 1. Business Context

### Problem Statement

Quản lý cần xem xét và phê duyệt đơn nghỉ của nhân viên. Quy trình thủ công qua email thiếu transparency, không có audit trail, và dễ bỏ sót đơn.

### Job Story

> **Khi** nhân viên của tôi gửi đơn xin nghỉ,
> **tôi muốn** xem chi tiết đơn và phê duyệt nhanh chóng,
> **để** nhân viên biết kết quả và lên kế hoạch nghỉ phù hợp.

### Success Metrics

| Metric | Framework | Target |
|--------|----------|--------|
| Approval response time | HEART | ≤ 4 hours average |
| Approval success rate | HEART | ≥ 99% |
| Manager satisfaction | HEART | ≥ 4.5/5 |

---

## 2. UI Workflow & Mockup

### Screen Flow

```text
[Pending Approvals List]
       ↓
[Click Request Row]
       ↓
[Request Detail View]
       ↓
[Review Info + Balance + Team Calendar]
       ↓
[Click Approve] → [Confirm Modal]
       ↓
[Success Confirmation]
```

### Mockup — Request Detail for Approval

```json
{
  "type": "page",
  "theme": "light",
  "children": [
    {
      "type": "navbar",
      "brand": "xTalent",
      "title": "Absence Management"
    },
    {
      "type": "section",
      "padding": "lg",
      "children": [
        {
          "type": "heading",
          "level": 1,
          "text": "Approve Leave Request"
        },
        {
          "type": "row",
          "gap": "xl",
          "children": [
            {
              "type": "column",
              "gap": "lg",
              "children": [
                {
                  "type": "card",
                  "title": "Request Information",
                  "padding": "lg",
                  "children": [
                    {
                      "type": "detail-grid",
                      "items": [
                        {"label": "Employee", "value": "{{employee_name}}", "avatar": true},
                        {"label": "Leave Type", "value": "{{leave_type}}"},
                        {"label": "Duration", "value": "{{start_date}} to {{end_date}}"},
                        {"label": "Total Days", "value": "{{working_days}} working day(s)"},
                        {"label": "Duration Type", "value": "{{duration_type}}"},
                        {"label": "Submitted", "value": "{{submitted_at}}"},
                        {"label": "Status", "value": "SUBMITTED", "badge": "pending"}
                      ]
                    },
                    {
                      "type": "section",
                      "title": "Employee's Reason",
                      "content": "{{reason}}"
                    },
                    {
                      "type": "section",
                      "title": "Attachments",
                      "children": [
                        {"type": "file-list", "files": "{{attachments}}"}
                      ]
                    }
                  ]
                },
                {
                  "type": "card",
                  "title": "Employee's Leave Balance",
                  "padding": "md",
                  "children": [
                    {
                      "type": "stat-list",
                      "stats": [
                        {"label": "Available Before", "value": "{{available_before}} days"},
                        {"label": "Requested", "value": "{{requested_days}} days"},
                        {"label": "Available After (if approved)", "value": "{{available_after}} days", "highlight": true}
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "type": "column",
              "gap": "md",
              "children": [
                {
                  "type": "card",
                  "title": "Team Calendar View",
                  "padding": "md",
                  "children": [
                    {
                      "type": "mini-calendar",
                      "highlightDates": "{{team_absence_dates}}",
                      "legend": "Highlighted dates = other team members on leave"
                    },
                    {
                      "type": "alert",
                      "variant": "warning",
                      "title": "Team Staffing Alert",
                      "content": "{{concurrent_leaves}} other team members already on leave during this period",
                      "visible": "concurrent_leaves > threshold"
                    }
                  ]
                },
                {
                  "type": "card",
                  "title": "Approval History",
                  "padding": "md",
                  "children": [
                    {
                      "type": "timeline",
                      "items": "{{approval_timeline}}"
                    }
                  ]
                }
              ]
            }
          ]
        },
        {
          "type": "sticky-footer",
          "children": [
            {
              "type": "button-group",
              "children": [
                {
                  "type": "button",
                  "name": "approve",
                  "text": "Approve",
                  "variant": "primary",
                  "action": "approve"
                },
                {
                  "type": "button",
                  "name": "reject",
                  "text": "Reject",
                  "variant": "danger",
                  "action": "reject"
                },
                {
                  "type": "button",
                  "name": "back",
                  "text": "Back",
                  "variant": "ghost",
                  "action": "navigate_back"
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

### Micro UI States

**Loading State:**
- Skeleton cho detail view
- Disable approve/reject buttons cho đến khi load complete

**Error State:**
| Error | Message | Recovery |
|-------|---------|----------|
| Request already approved | "This request was already approved by another manager" | Refresh page, show updated status |
| Insufficient permissions | "You don't have permission to approve this request" | Redirect to list |

---

## 3. System Events

| Event | Trigger | Actor | Payload |
|-------|---------|-------|---------|
| `LeaveRequestApproved` | Manager approves | Manager | request_id, employee_id, approved_at, approved_by, approver_comment |
| `LeaveReservationCreated` | (auto) | System | reservation confirmed |
| `ManagerNotified` | (auto) | System | Employee notified |

**Event Flow:**

```text
[Manager]
  → Command: ApproveLeaveRequest(request_id, comment)
    → Validate:
      - request status = SUBMITTED or PENDING
      - manager has approval permission
    → If valid:
      → Update LeaveRequest.status_code = APPROVED
      → Event: LeaveRequestApproved
        → Policy: Confirm reservation
        → Policy: Notify employee
        → Policy: Add to team calendar
```

---

## 4. Business Rules

### Rule References

| Rule ID | Description |
|---------|-------------|
| [`rule_request_status_transition_valid`](../ontology/rules.yaml#L474) | Status phải chuyển từ SUBMITTED → APPROVED |
| [`rule_reservation_unhold_on_start_post`](../ontology/rules.yaml#L557) | Reservation convert sang used khi start |

### Feature-specific Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Approval authority | Manager chỉ approve được direct reports | Validate org hierarchy |
| Concurrent leave check | Nếu concurrent_leaves > threshold | Hiển thị warning nhưng vẫn allow approve |
| Comment required | Reject action | Bắt buộc nhập lý do reject |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Approval response time | ≤ 500ms |
| Concurrent approval handling | Idempotent - không approve 2 lần |
| Mobile support | Approve được trên mobile |

---

## 6. Dependency Map

| Requires | Reason |
|----------|--------|
| ABS-LR-002 | Cần đơn đã submit |
| ABS-LR-003 | Hiển thị danh sách |
| ABS-BAL-001 | Hiển thị balance |

| Required By |
|-------------|
| ABS-LR-003 (Status update) |
| ABS-APR-008 (Approval history) |

---

## 7. Edge & Corner Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Two managers approve cùng lúc | Idempotency - chỉ approve 1 lần |
| E2 | Request đã được approve trước đó | Error: "Already approved" |
| E3 | Manager không còn权限 (org change) | Error: "No permission" |
| E4 | Employee nghỉ việc sau khi submit | Warning cho manager |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-APR-001 - Approve Leave Request

  Scenario: Approve pending request
    Given request ở status SUBMITTED
    And manager có quyền approve
    Khi manager click "Approve" và confirm
    Thì status chuyển sang APPROVED
    Và LeaveRequestApproved event emitted
    Và employee nhận notification
    Và reservation được confirm

  Scenario: Cannot approve already approved request
    Given request đã được approve
    Khi manager cố approve
    Thì hiển thị error "Request already approved"

  Scenario: Approve với comment
    Khi manager nhập comment "Enjoy your vacation!"
    Và approve
    Thì comment được lưu trong approval history
```

---

## 9. Release Planning

- **Alpha:** Approve cơ bản, status update
- **Beta:** Team calendar view, balance display
- **GA:** Full workflow, notifications

### Out of Scope (v1)
- Multi-level approval (ABS-APR-003)
- Conditional routing (ABS-APR-009)
- Delegation (ABS-APR-004)
