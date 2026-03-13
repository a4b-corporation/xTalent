---
id: ABS-LR-002
name: Submit Leave Request for Approval
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
    - LeaveReservation
    - LeaveInstant
  rules:
    - rule_reservation_cannot_exceed_available
    - rule_reservation_auto_release_on_reject
    - rule_reservation_auto_release_on_cancel
  lifecycle: LeaveRequestLifecycle
  events:
    - LeaveRequested
    - LeaveReservationCreated

dependencies:
  requires:
    - ABS-LR-001: "Create Leave Request - phải tạo đơn trước khi submit"
    - ABS-BAL-005: "Real-time Balance Update - cần reserve balance"
  required_by:
    - ABS-APR-001: "Approve Leave Request - cần đơn submitted để approve"
    - ABS-APR-002: "Reject Leave Request - cần đơn submitted để reject"
    - ABS-LR-003: "View Leave Request Status - hiển thị trạng thái submitted"
  external:
    - "Notification Service - gửi email thông báo cho manager"
    - "Approval Workflow Service - route đơn đến người duyệt"

created: 2026-03-13
updated: 2026-03-13
author: BA Team
---

# ABS-LR-002: Submit Leave Request for Approval

> Cho phép nhân viên gửi đơn nghỉ đã tạo để quản lý phê duyệt, kích hoạt workflow và reserve số dư.

---

## 1. Business Context

### Problem Statement

Sau khi tạo đơn nghỉ, nhân viên cần gửi đơn để được phê duyệt. Quy trình thủ công qua email mất thời gian, không có tracking rõ ràng, và dễ bỏ sót. Feature này tự động hóa việc submit đơn, trigger approval workflow, và reserve số dư để tránh overbooking.

### Job Story

> **Khi** tôi đã điền xong đơn nghỉ và muốn gửi để quản lý phê duyệt,
> **tôi muốn** nhấn nút Submit và nhận xác nhận ngay lập tức,
> **để** tôi yên tâm rằng đơn đã được gửi và số dư được giữ cho ngày nghỉ của mình.

### Success Metrics

| Metric | Framework | Target |
|--------|----------|--------|
| Submission Success Rate | HEART | ≥ 99% |
| Time to Submit (click to confirmation) | HEART | ≤ 2s |
| Notification Delivery Rate | HEART | ≥ 98% |
| User Confidence (survey) | HEART | ≥ 4.7/5 |

---

## 2. UI Workflow & Mockup

### Screen Flow

```text
[Create Leave Request Form - ABS-LR-001]
              ↓
[Click "Submit for Approval"]
              ↓
[Pre-submit Validation]
    ├── Fail → [Show Errors] ──→ quay lại form
    └── Pass → [Confirmation Modal]
                    ↓
            [User confirms]
                    ↓
            [Submit Processing]
                    ↓
    ┌───────────────┴───────────────┐
    ↓                               ↓
[Success]                    [Error]
    ↓                               ↓
[Confirmation Screen]         [Error Message]
    ↓                               ↓
[View Request Status]         [Retry/Cancel]
```

### Mockup — Confirmation Modal

```json
{
  "type": "modal",
  "size": "medium",
  "closable": true,
  "children": [
    {
      "type": "modal-header",
      "title": "Confirm Leave Request Submission",
      "onClose": "cancel"
    },
    {
      "type": "modal-body",
      "children": [
        {
          "type": "alert",
          "variant": "info",
          "title": "Review Your Request",
          "content": "Please verify the details before submitting"
        },
        {
          "type": "summary-card",
          "items": [
            {
              "label": "Leave Type",
              "value": "{{leave_type}}"
            },
            {
              "label": "Duration",
              "value": "{{start_date}} to {{end_date}}"
            },
            {
              "label": "Total Days",
              "value": "{{working_days}} working day(s)"
            },
            {
              "label": "Balance Before",
              "value": "{{balance_before}} days"
            },
            {
              "label": "Balance After (if approved)",
              "value": "{{balance_after}} days",
              "highlight": true
            },
            {
              "label": "Approver",
              "value": "{{manager_name}}"
            },
            {
              "label": "Expected Response By",
              "value": "{{sla_deadline}}",
              "helpText": "Based on your company's 48-hour SLA"
            }
          ]
        },
        {
          "type": "checkbox",
          "name": "acknowledge",
          "label": "I understand that submitting this request will reserve my leave balance",
          "required": true
        }
      ]
    },
    {
      "type": "modal-footer",
      "children": [
        {
          "type": "button",
          "text": "Cancel",
          "variant": "ghost",
          "action": "cancel"
        },
        {
          "type": "button",
          "name": "confirm_submit",
          "text": "Confirm Submit",
          "variant": "primary",
          "action": "submit",
          "disabled": "!acknowledge"
        }
      ]
    }
  ]
}
```

### Mockup — Success Confirmation Screen

```json
{
  "type": "page",
  "theme": "light",
  "children": [
    {
      "type": "section",
      "padding": "lg",
      "children": [
        {
          "type": "success-banner",
          "title": "Leave Request Submitted Successfully!",
          "message": "Your request has been sent to {{manager_name}} for approval",
          "icon": "check-circle"
        },
        {
          "type": "card",
          "padding": "md",
          "children": [
            {
              "type": "heading",
              "level": 2,
              "text": "Request Summary"
            },
            {
              "type": "detail-list",
              "items": [
                {"label": "Request ID", "value": "{{request_id}}"},
                {"label": "Leave Type", "value": "{{leave_type}}"},
                {"label": "Dates", "value": "{{start_date}} - {{end_date}}"},
                {"label": "Status", "value": "SUBMITTED", "badge": "pending"},
                {"label": "Submitted At", "value": "{{timestamp}}"}
              ]
            },
            {
              "type": "alert",
              "variant": "warning",
              "title": "Balance Reserved",
              "content": "{{reserved_days}} days have been reserved from your balance. These will be deducted once your request is approved."
            },
            {
              "type": "button-group",
              "children": [
                {
                  "type": "button",
                  "text": "View Request Details",
                  "variant": "primary",
                  "action": "navigate_to_request"
                },
                {
                  "type": "button",
                  "text": "Back to My Absences",
                  "variant": "outline",
                  "action": "navigate_to_list"
                }
              ]
            }
          ]
        },
        {
          "type": "card",
          "padding": "md",
          "title": "What's Next?",
          "children": [
            {
              "type": "timeline",
              "items": [
                {
                  "status": "completed",
                  "label": "Request Submitted",
                  "time": "{{timestamp}}"
                },
                {
                  "status": "pending",
                  "label": "Manager Review",
                  "time": "Within 48 hours",
                  "assignee": "{{manager_name}}"
                },
                {
                  "status": "pending",
                  "label": "Approval Decision",
                  "time": "TBD"
                }
              ]
            },
            {
              "type": "info-text",
              "content": "You will receive an email notification once your manager makes a decision."
            }
          ]
        }
      ]
    }
  ]
}
```

### Micro UI States

**Loading State (sau khi confirm submit):**
- Button "Confirm Submit" disabled + spinner
- Hiển thị progress bar: "Submitting your request..."
- Timeout sau 15s: hiển thị error "Request is taking longer than expected"

**Error State:**
| Error | Message | Recovery |
|-------|---------|----------|
| Balance changed | "Balance has changed since you started. Please review and try again" | Refresh form với balance mới |
| Overlap detected | "A conflicting leave request was just approved. Please adjust your dates" | Quay lại form với error highlight |
| Network error | "Connection lost. Your request may have been submitted. Check My Absences" | Button "Check Status" + "Retry" |
| Workflow error | "Unable to route to approver. Contact HR if issue persists" | Button "Contact HR" + "Save as Draft" |

**Empty State:** N/A (feature này luôn có data từ ABS-LR-001)

---

## 3. System Events

| Event | Trigger Command | Actor | Payload |
|-------|----------------|-------|---------|
| `LeaveRequested` | `SubmitLeaveRequest` | Employee | request_id, employee_id, class_id, instant_id, start_dt, end_dt, qty_hours_req, status_code=SUBMITTED, submitted_at |
| `LeaveReservationCreated` | (auto) | System | reservation_id, request_id, instant_id, employee_id, reserved_qty, hold_start_date, hold_end_date, expires_at |
| `ManagerNotified` | (auto) | System | notification_id, request_id, manager_id, notification_type=email, sent_at |

**Event Flow:**

```text
[Employee]
  → Command: SubmitLeaveRequest(request_id)
    → Validate:
      - rule_request_must_have_available_balance (re-check)
      - rule_reservation_cannot_exceed_available
      - rule_request_cannot_overlap_approved (re-check)
    → If valid:
      → Update LeaveRequest.status_code = SUBMITTED
      → Event: LeaveRequested (với status=SUBMITTED)
        → Policy: "Khi LeaveRequested với status=SUBMITTED"
          → Command: CreateLeaveReservation
            → Event: LeaveReservationCreated
          → Command: NotifyManager
            → Event: ManagerNotified
    → If invalid:
      → Return error (không emit event)
```

*Reference Events: [`../system/events.yaml`](../system/events.yaml#L87-L128)*

---

## 4. Business Rules

### Rule References (from Ontology)

| Rule ID | Description | Severity |
|---------|-------------|---------|
| [`rule_reservation_cannot_exceed_available`](../ontology/rules.yaml#L499) | Reserved qty không được vượt available balance | ERROR |
| [`rule_reservation_auto_release_on_reject`](../ontology/rules.yaml#L512) | Tự động release reservation khi reject | INFO |
| [`rule_reservation_auto_release_on_cancel`](../ontology/rules.yaml#L526) | Tự động release reservation khi cancel | INFO |
| [`rule_request_status_transition_valid`](../ontology/rules.yaml#L474) | Status transition phải hợp lệ | ERROR |

### Feature-specific Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Status Transition | Từ DRAFT → SUBMITTED | Only allowed if all validations pass |
| Reservation Hold | Khi submit thành công | Immediately create reservation với expires_at = submitted_at + 48h |
| Notification | Khi submit thành công | Send email notification đến manager trong vòng 1 phút |
| SLA Timer | Khi submit thành công | Start 48-hour SLA countdown cho manager response |

---

## 5. NFRs & Constraints

### Non-Functional Requirements

| Chất lượng (ISO 25010) | Yêu cầu | Đo lường |
|----------------------|---------|---------|
| **Performance** | Submit response time ≤ 2s at P95 | Load test với 100 concurrent submissions |
| **Reliability** | Idempotent submit (không tạo double request) | Test với duplicate API calls |
| **Security** | Chỉ employee có thể submit đơn của chính mình | Authorization test |
| **Usability** | Confirmation modal rõ ràng, không confusing | User testing |

### Constraints

| Loại | Constraint |
|------|-----------|
| **Technical** | API phải idempotent với idempotency key |
| **Business** | Không submit được đơn đã ở status SUBMITTED hoặc APPROVED |
| **Business** | Reservation expires sau 48h nếu không được approve |

---

## 6. Dependency Map

### This Feature Requires

| Feature ID | Feature Name | Relationship | Reason |
|-----------|-------------|-------------|--------|
| ABS-LR-001 | Create Leave Request | FS | Phải có đơn ở status DRAFT trước |
| ABS-BAL-005 | Real-time Balance Update | FS | Cần reserve balance ngay khi submit |

### Features Requiring This Feature

| Feature ID | Feature Name | Relationship |
|-----------|-------------|-------------|
| ABS-APR-001 | Approve Leave Request | FS |
| ABS-APR-002 | Reject Leave Request | FS |
| ABS-LR-003 | View Leave Request Status | SS |
| ABS-LR-004 | Withdraw Leave Request | FS |

---

## 7. Edge & Corner Cases

### Edge Cases

| # | Case | Điều kiện | Hành vi mong đợi |
|---|------|-----------|-----------------|
| E1 | Balance thay đổi giữa lúc fill form và submit | User khác adjust balance | Re-validate, hiển thị error nếu không đủ |
| E2 | Submit 2 lần (double-click) | User click Confirm 2 lần | Idempotency: chỉ tạo 1 request |
| E3 | Manager là chính employee | Self-approval scenario | Auto-approve hoặc route đến skip-level |
| E4 | Manager không có trong hệ thống | Employee's manager = null | Error: "Please contact HR to set your manager" |
| E5 | Submit ngày cuối tuần/lễ | Start date là weekend/holiday | Warning trước khi confirm |

### Corner Cases

| # | Case | Điều kiện kết hợp | Handling Strategy |
|---|------|------------------|------------------|
| C1 | Network loss giữa submit và confirmation | Submit thành công nhưng client không nhận response | Button "Check Status" query server để confirm |
| C2 | Manager nhận notification nhưng link expired | Email link sau 48h | Redirect đến list với message "Request đã expired" |
| C3 | Employee terminate sau khi submit | Employment status = Terminated | Auto-reject workflow trigger |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-LR-002 - Submit Leave Request for Approval

  Background:
    Given nhân viên đã tạo leave request ở status DRAFT
    And request có valid data

  Scenario: Submit thành công với đủ balance
    Given request có balance đủ
    Khi nhân viên click "Submit for Approval"
    And confirm trong modal
    Thì request status chuyển sang SUBMITTED
    Và LeaveRequested event được emit
    Và LeaveReservationCreated event được emit
    Và manager nhận được email notification
    Và hiển thị success confirmation screen
    Và reservation expires_at = submitted_at + 48 giờ

  Scenario: Submit với balance không đủ
    Given balance thay đổi thành không đủ sau khi tạo draft
    Khi nhân viên click "Submit for Approval"
    Thì hiển thị error "Balance không đủ"
    Và không emit event nào
    Và modal không đóng

  Scenario: Double submit prevention
    Given nhân viên click "Confirm Submit" 2 lần liên tiếp
    Khi cả 2 clicks được xử lý
    Thì chỉ 1 leave request được tạo
    Và chỉ 1 reservation được tạo

  Scenario: Manager notification
    Given request đã submit thành công
    Khi submit complete
    Thì manager nhận email với nội dung:
      | Field | Value |
      | Employee Name | {{employee_name}} |
      | Leave Type | {{leave_type}} |
      | Dates | {{start_date}} - {{end_date}} |
      | Total Days | {{days}} |
      | Action Link | Direct link to approve/reject |
```

---

## 9. Release Planning

### Phase 1: Alpha
- **Scope:** Submit flow cơ bản, reservation creation
- **Criteria:** Happy path working, events emitted correctly

### Phase 2: Beta
- **Scope:** Full validation, notification, error handling
- **Criteria:** 100% AC passed, notification delivery ≥ 98%

### Phase 3: GA
- **Scope:** All edge cases, idempotency, SLA timer
- **Criteria:** 0 P0 bugs, performance targets met

### Out of Scope (v1)
- Multi-level approval routing (ABS-APR-003)
- Escalation workflows (ABS-APR-006)
- Conditional routing rules (ABS-APR-009)
