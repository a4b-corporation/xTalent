---
id: ABS-LR-001
name: Create Leave Request
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
    - LeaveType
    - LeaveInstant
    - LeaveBalance
  rules:
    - rule_request_must_have_employee
    - rule_request_must_have_class
    - rule_request_end_must_be_after_start
    - rule_request_cannot_overlap_approved
    - rule_request_must_have_available_balance
  lifecycle: LeaveRequestLifecycle
  events:
    - LeaveRequested

dependencies:
  requires:
    - ABS-BAL-001: "View Leave Balance - cần hiển thị số dư trước khi tạo đơn"
    - ABS-POL-002: "Leave Type Configuration - cần danh sách loại nghỉ"
  required_by:
    - ABS-LR-002: "Submit Leave Request - phải tạo đơn trước khi submit"
    - ABS-LR-005: "Half-Day Leave Request - mở rộng từ create request"
    - ABS-LR-006: "Hourly Leave Request - mở rộng từ create request"
  external:
    - "Holiday Calendar Service - tính working days"
    - "Notification Service - gửi thông báo (optional)"

created: 2026-03-13
updated: 2026-03-13
author: BA Team
---

# ABS-LR-001: Create Leave Request

> Cho phép nhân viên tạo yêu cầu nghỉ phép mới với loại nghỉ, khoảng ngày, và ghi chú lý do.

---

## 1. Business Context

### Problem Statement

Nhân viên hiện cần gửi email hoặc nhắn tin để xin nghỉ, gây mất thời gian cho cả nhân viên và quản lý, không có audit trail rõ ràng, và dễ xảy ra lỗi tính toán số dư. Feature này số hóa quy trình tạo đơn nghỉ với validation tự động.

### Job Story

> **Khi** tôi cần lên kế hoạch nghỉ phép và muốn kiểm tra số dư trước khi gửi,
> **tôi muốn** tạo đơn nghỉ trực tiếp trên hệ thống với đầy đủ thông tin,
> **để** tôi không cần gửi email qua lại và biết ngay đơn có hợp lệ không.

### Success Metrics

| Metric | Framework | Target |
|--------|----------|--------|
| Task Success Rate (tạo đơn thành công / tổng lần thử) | HEART | ≥ 95% |
| Error Rate (validation fail / tổng đơn) | HEART | ≤ 5% |
| Time to Submit (thời gian trung bình từ mở form đến submit) | HEART | ≤ 3 phút |
| User Satisfaction (CSAT sau khi tạo đơn) | HEART | ≥ 4.5/5 |

---

## 2. UI Workflow & Mockup

### Screen Flow

```text
[Leave Request List]
       ↓
[+ New Request Button]
       ↓
[Create Leave Request Form] ←───┐
       ↓                         │
[Validation Check]               │
       ├── Valid ──→ [Preview & Submit] ──→ [ABS-LR-002]
       └── Invalid ─→ [Show Errors] ───────┘
```

### Mockup — Create Leave Request Form

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
          "type": "breadcrumb",
          "items": [
            {"label": "Home", "href": "/"},
            {"label": "My Absences", "href": "/absences"},
            {"label": "New Request", "href": "#"}
          ]
        },
        {
          "type": "heading",
          "level": 1,
          "text": "Create Leave Request"
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
                  "title": "Request Details",
                  "padding": "lg",
                  "children": [
                    {
                      "type": "form",
                      "children": [
                        {
                          "type": "select",
                          "name": "leave_type",
                          "label": "Leave Type *",
                          "options": [
                            {"value": "annual", "label": "Annual Leave"},
                            {"value": "sick", "label": "Sick Leave"},
                            {"value": "maternity", "label": "Maternity Leave"},
                            {"value": "bereavement", "label": "Bereavement Leave"},
                            {"value": "unpaid", "label": "Unpaid Leave"}
                          ],
                          "placeholder": "Select leave type",
                          "required": true,
                          "helpText": "Choose the type of leave you want to take"
                        },
                        {
                          "type": "row",
                          "gap": "md",
                          "children": [
                            {
                              "type": "input",
                              "name": "start_date",
                              "label": "Start Date *",
                              "inputType": "date",
                              "required": true,
                              "min": "today"
                            },
                            {
                              "type": "input",
                              "name": "end_date",
                              "label": "End Date *",
                              "inputType": "date",
                              "required": true,
                              "min": "start_date"
                            }
                          ]
                        },
                        {
                          "type": "row",
                          "gap": "md",
                          "children": [
                            {
                              "type": "select",
                              "name": "duration_type",
                              "label": "Duration Type",
                              "options": [
                                {"value": "full_day", "label": "Full Day"},
                                {"value": "half_am", "label": "Half Day (AM)"},
                                {"value": "half_pm", "label": "Half Day (PM)"},
                                {"value": "hourly", "label": "Hourly"}
                              ],
                              "placeholder": "Select duration",
                              "defaultValue": "full_day",
                              "conditional": {
                                "show": "leave_type allows this duration"
                              }
                            },
                            {
                              "type": "input",
                              "name": "hours",
                              "label": "Hours",
                              "inputType": "number",
                              "min": 1,
                              "max": 8,
                              "step": 0.5,
                              "conditional": {
                                "show": "duration_type === 'hourly'"
                              }
                            }
                          ]
                        },
                        {
                          "type": "alert",
                          "variant": "info",
                          "title": "Working Days Calculation",
                          "content": "Selected: {{working_days}} working day(s) (excludes weekends and holidays)",
                          "visible": "start_date and end_date selected"
                        },
                        {
                          "type": "textarea",
                          "name": "reason",
                          "label": "Reason (Optional)",
                          "placeholder": "Add reason or notes for your leave request...",
                          "rows": 3,
                          "maxLength": 1000,
                          "helpText": "Provide additional context for your manager (optional)"
                        },
                        {
                          "type": "file-upload",
                          "name": "attachments",
                          "label": "Attachments (Optional)",
                          "accept": [".pdf", ".jpg", ".jpeg", ".png"],
                          "maxSize": "10MB",
                          "maxFiles": 5,
                          "helpText": "Upload supporting documents (e.g., medical certificate)"
                        },
                        {
                          "type": "button-group",
                          "children": [
                            {
                              "type": "button",
                              "name": "submit",
                              "text": "Submit for Approval",
                              "variant": "primary",
                              "action": "submit"
                            },
                            {
                              "type": "button",
                              "name": "save_draft",
                              "text": "Save as Draft",
                              "variant": "outline",
                              "action": "save_draft"
                            },
                            {
                              "type": "button",
                              "name": "cancel",
                              "text": "Cancel",
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
            },
            {
              "type": "column",
              "gap": "md",
              "children": [
                {
                  "type": "card",
                  "title": "Balance Summary",
                  "padding": "md",
                  "children": [
                    {
                      "type": "stat-list",
                      "stats": [
                        {
                          "label": "Annual Leave Available",
                          "value": "{{annual_balance}} days",
                          "trend": "{{annual_trend}}"
                        },
                        {
                          "label": "Sick Leave Available",
                          "value": "{{sick_balance}} days",
                          "trend": "{{sick_trend}}"
                        },
                        {
                          "label": "Requested (This Request)",
                          "value": "{{requested_days}} days",
                          "highlight": true
                        },
                        {
                          "label": "Remaining After Submit",
                          "value": "{{remaining_days}} days",
                          "variant": "success"
                        }
                      ]
                    },
                    {
                      "type": "alert",
                      "variant": "warning",
                      "title": "Insufficient Balance",
                      "content": "Your requested days exceed available balance. Please adjust your request or contact HR.",
                      "visible": "requested_days > available_balance"
                    }
                  ]
                },
                {
                  "type": "card",
                  "title": "Leave History",
                  "padding": "md",
                  "children": [
                    {
                      "type": "mini-list",
                      "items": "{{recent_leaves}}",
                      "emptyState": "No recent leave requests",
                      "viewAllLink": "/absences/history"
                    }
                  ]
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

**Empty State (khi chưa có data):**
- Message: "Bạn chưa có đơn nghỉ nào trong tháng này"
- Description: "Tạo đơn nghỉ đầu tiên bằng cách nhấn nút + New Request"
- CTA: Button "+ New Request" → mở form

**Error State:**
| Error Type | Message | Display Location |
|-----------|---------|-----------------|
| Balance insufficient | "Số dư không đủ. Available: {{N}} days, Requested: {{M}} days" | Inline alert dưới field Duration |
| Date overlap | "Bạn đã có đơn nghỉ APPROVED trong khoảng ngày {{date}}. Vui lòng chọn ngày khác" | Inline alert dưới date fields |
| Invalid date range | "End Date phải sau Start Date" | Inline error dưới End Date field |
| Missing leave type | "Vui lòng chọn loại nghỉ" | Inline error dưới Leave Type dropdown |
| Weekend/Holiday warning | "Ngày {{date}} là ngày lễ/làm việc. Xác nhận tạo đơn?" | Warning modal trước submit |

**Loading State:**
- Button "Submit" chuyển sang disabled + spinner icon
- Disable tất cả form fields trong lúc submit
- Timeout sau 30s: hiển thị toast "Đã xảy ra lỗi kết nối. Vui lòng thử lại"
- Auto-save draft mỗi 30 giây khi đang điền form

---

## 3. System Events

| Event | Trigger Command | Actor | Payload |
|-------|----------------|-------|---------|
| `LeaveRequested` | `CreateLeaveRequest` | Employee | request_id, employee_id, class_id, instant_id, start_dt, end_dt, qty_hours_req, leave_type, duration_type, reason, attachments |
| `LeaveReservationCreated` | (auto) | System | reservation_id, request_id, instant_id, employee_id, reserved_qty, hold_start_date, hold_end_date, expires_at |

**Event Flow:**

```text
[Employee]
  → Command: CreateLeaveRequest(payload)
    → Validate:
      - rule_request_must_have_employee
      - rule_request_must_have_class
      - rule_request_end_must_be_after_start
      - rule_request_cannot_overlap_approved
      - rule_request_must_have_available_balance
    → If valid:
      → Event: LeaveRequested
        → Policy: "Khi LeaveRequested"
          → Command: CreateLeaveReservation
            → Event: LeaveReservationCreated
    → If invalid:
      → Return validation errors (không emit event)
```

*Reference Events: [`../system/events.yaml`](../system/events.yaml#L87-L128)*

---

## 4. Business Rules

### Rule References (from Ontology)

| Rule ID | Description | Severity |
|---------|-------------|---------|
| [`rule_request_must_have_employee`](../ontology/rules.yaml#L399) | Employee ID là bắt buộc | ERROR |
| [`rule_request_must_have_class`](../ontology/rules.yaml#L410) | LeaveClass ID là bắt buộc | ERROR |
| [`rule_request_end_must_be_after_start`](../ontology/rules.yaml#L421) | End Date phải sau Start Date | ERROR |
| [`rule_request_cannot_overlap_approved`](../ontology/rules.yaml#L432) | Không được trùng với đơn đã approve | ERROR |
| [`rule_request_must_have_available_balance`](../ontology/rules.yaml#L447) | Số dư phải đủ | ERROR |
| [`rule_instant_hold_cannot_exceed_current`](../ontology/rules.yaml#L247) | Hold không được vượt current | ERROR |

### Feature-specific Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Working Days Calculation | Nếu duration_type = Full Day | Số ngày = working_days(start_date, end_date) - weekends - holidays |
| Half-Day Calculation | Nếu duration_type = Half AM/PM | Số ngày = 0.5 |
| Hourly Calculation | Nếu duration_type = Hourly | Số giờ = hours, converted sang ngày theo unit của LeaveType |
| Attachment Required | Nếu leave_type = Sick AND days > 3 | Bắt buộc upload attachment trước khi submit |

### Decision Table: Duration Type Availability

| LeaveType.allows_half_day | LeaveType.allows_hourly | Available Duration Options |
|--------------------------|------------------------|---------------------------|
| true | true | Full Day, Half AM, Half PM, Hourly |
| true | false | Full Day, Half AM, Half PM |
| false | true | Full Day, Hourly |
| false | false | Full Day only |

---

## 5. NFRs & Constraints

### Non-Functional Requirements

| Chất lượng (ISO 25010) | Yêu cầu | Đo lường |
|----------------------|---------|---------|
| **Performance** | Form load time ≤ 2s at P95 | Load test với 100 concurrent users |
| **Performance** | Balance calculation ≤ 100ms | Unit test + profiling |
| **Security** | Employee chỉ tạo được đơn cho chính mình | Security audit, penetration test |
| **Security** | Attachment scanning cho malware | Integration với antivirus service |
| **Usability** | Keyboard navigation đầy đủ (Tab, Enter, Esc) | WCAG 2.1 AA compliance |
| **Usability** | Mobile-responsive (min 375px width) | Cross-device testing |
| **Reliability** | Form auto-save draft mỗi 30s | Integration test |

### Constraints

| Loại | Constraint |
|------|-----------|
| **Technical** | UI dùng xTalent Design System components |
| **Technical** | Attachment max 10MB per file, 5 files total |
| **Business** | Chỉ áp dụng cho employees có status Active |
| **Business** | Không tạo được đơn cho ngày quá khứ (trừ Sick Leave với approval đặc biệt) |
| **Regulatory** | Audit log bắt buộc: ai tạo, khi nào, từ IP nào |

---

## 6. Dependency Map

### This Feature Requires

| Feature ID | Feature Name | Relationship | Reason |
|-----------|-------------|-------------|--------|
| ABS-BAL-001 | View Leave Balance | FS | Phải hiển thị balance trước khi user tạo đơn |
| ABS-POL-002 | Leave Type Configuration | FS | Cần danh sách loại nghỉ để hiển thị dropdown |

### Features Requiring This Feature

| Feature ID | Feature Name | Relationship |
|-----------|-------------|-------------|
| ABS-LR-002 | Submit Leave Request | FS |
| ABS-LR-005 | Half-Day Leave Request | SS (mở rộng) |
| ABS-LR-006 | Hourly Leave Request | SS (mở rộng) |
| ABS-LR-007 | Leave Request with Attachments | SS (mở rộng) |
| ABS-LR-008 | Leave Request Comments | SS (mở rộng) |

### External Dependencies

| System | Dependency | Risk Level |
|--------|-----------|-----------|
| **Holiday Calendar Service** | Tính working days | MEDIUM — nếu service down, fallback to calendar_days với warning |
| **Notification Service** | Gửi email confirmation | LOW — optional, không block flow chính |
| **File Storage Service** | Lưu attachments | LOW — có thể retry hoặc lưu tạm |

---

## 7. Edge & Corner Cases

### Edge Cases

| # | Case | Điều kiện | Hành vi mong đợi |
|---|------|-----------|-----------------|
| E1 | Balance = 0 | Nhân viên hết số ngày nghỉ | Block submit, show warning alert với message rõ |
| E2 | Balance < requested | Số dư không đủ cho toàn bộ request | Warning + option điều chỉnh ngày |
| E3 | Start date = today | Xin nghỉ cho hôm nay | Allowed với Sick Leave, warning cho Annual Leave |
| E4 | Date range > 30 days | User chọn range quá dài | Error: "Maximum 30 days per request" |
| E5 | Overlap với pending request | Trùng với đơn đang chờ | Warning: "Bạn đã có đơn pending trong khoảng này" |
| E6 | Leave type requires attachment | Sick Leave > 3 days | Show attachment field required, block submit nếu không có |
| E7 | Start/End date là weekend | Ngày cuối tuần | Warning: "Ngày {{date}} là cuối tuần" |
| E8 | Start/End date là holiday | Ngày lễ | Warning: "Ngày {{date}} là ngày lễ" |

### Corner Cases

| # | Case | Điều kiện kết hợp | Handling Strategy |
|---|------|------------------|------------------|
| C1 | Session hết hạn giữa chừng | User điền form → session expire → nhấn Submit | Redirect login, preserve form data trong localStorage 1 giờ |
| C2 | Concurrent submit | User mở 2 tabs, submit cùng lúc | Backend idempotency key; request thứ hai return 409 Conflict |
| C3 | Holiday update khi đang điền form | Admin thêm holiday vào calendar | Recalculate working days khi user focus lại tab |
| C4 | Leave type config change | Admin deactivate leave type khi user đang chọn | Validation khi submit: "Leave type không còn hợp lệ" |
| C5 | Balance change giữa form load và submit | User khác adjust balance | Re-validate balance khi submit, show error nếu thay đổi |

### Edge Case Checklist

- [ ] Input boundary: start_date > end_date handled
- [ ] Empty: balance = 0, balance < requested
- [ ] Special: leave type thay đổi sau khi đã chọn ngày (recalculate)
- [ ] Concurrent: double-submit prevention
- [ ] Session: form data preserved on session expiry
- [ ] Permission: employee không tạo được đơn cho người khác (URL manipulation)
- [ ] Attachment: required file validation
- [ ] Date: weekend/holiday detection and warning

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-LR-001 - Create Leave Request

  Background:
    Given nhân viên đã đăng nhập vào hệ thống
    And nhân viên có employment status là Active
    And nhân viên có ít nhất 1 LeaveInstant với balance > 0

  # Happy Path
  Scenario: Tạo đơn nghỉ hợp lệ với đủ số dư
    Given nhân viên có 10 ngày Annual Leave available
    When nhân viên tạo đơn Annual Leave từ 2026-04-01 đến 2026-04-03 (3 ngày làm việc)
    And nhấn "Save as Draft"
    Then hệ thống tạo LeaveRequest với status DRAFT
    And chuyển hướng đến trang danh sách đơn
    And hiển thị toast "Đã lưu nháp thành công"

  Scenario: Submit đơn nghỉ với đủ số dư
    Given nhân viên có 10 ngày Annual Leave available
    When nhân viên tạo đơn Annual Leave từ 2026-04-01 đến 2026-04-03
    And nhấn "Submit for Approval"
    And xác nhận trong modal
    Then hệ thống tạo LeaveRequest với status SUBMITTED
    And LeaveRequested event được emit với đúng payload
    And LeaveReservationCreated event được emit
    And chuyển hướng đến trang chi tiết đơn
    And hiển thị toast "Đã gửi đơn xin nghỉ thành công"

  # Validation: Balance
  Scenario: Không thể submit khi số dư không đủ
    Given nhân viên có 2 ngày Annual Leave available
    When nhân viên tạo đơn Annual Leave 5 ngày
    Then button "Submit for Approval" bị disable
    Và hiển thị warning "Số dư không đủ. Available: 2 ngày, Requested: 5 ngày"
    Và không emit event nào

  # Validation: Date overlap
  Scenario: Không thể tạo đơn trùng với đơn đã approve
    Given nhân viên có đơn APPROVED cho ngày 2026-04-01 đến 2026-04-02
    Khi nhân viên tạo đơn mới bao gồm ngày 2026-04-02
    Thì hệ thống hiển thị error "Đã có đơn nghỉ APPROVED trong khoảng ngày 2026-04-01 đến 2026-04-02"
    Và button "Submit for Approval" bị disable

  # Validation: Date range
  Scenario: End Date phải sau Start Date
    Given nhân viên chọn Start Date = 2026-04-05
    Khi nhân viên chọn End Date = 2026-04-03
    Thì hiển thị error "End Date phải sau Start Date"
    Và button "Submit for Approval" bị disable

  # Edge Case: Half day với balance = 0.5
  Scenario: Tạo đơn half day với balance vừa đủ
    Given nhân viên có 0.5 ngày Annual Leave available
    Khi nhân viên tạo đơn Half Day AM cho ngày 2026-04-01
    Và nhấn "Submit for Approval"
    Thì hệ thống tạo LeaveRequest thành công
    Và balance hiển thị sau khi tạo = 0.0

  # Edge Case: Attachment required
  Scenario: Sick Leave > 3 days yêu cầu attachment
    Given nhân viên chọn Sick Leave với duration = 5 ngày
    Khi nhân viên không upload attachment
    Thì hiển thị warning "Giấy khám bệnh là bắt buộc cho nghỉ ốm > 3 ngày"
    Và button "Submit for Approval" bị disable

  # Edge Case: Working days calculation
  Scenario: Tự động tính working days loại trừ weekend
    Given nhân viên chọn Start Date = 2026-04-03 (Friday)
    And nhân viên chọn End Date = 2026-04-07 (Tuesday)
    Then hệ thống hiển thị "Selected: 3 working day(s)" (loại trừ T7, CN)

  # Auto-save draft
  Scenario: Form tự động lưu draft mỗi 30 giây
    Given nhân viên đang điền form
    And đã nhập ít nhất 1 field
    When 30 giây trôi qua
    Then hệ thống tự động lưu draft (không thông báo)
    Và hiển thị "Last saved: {{timestamp}}"

  # Session expiry
  Scenario: Session hết hạn khi đang điền form
    Given nhân viên đang điền form
    When session hết hạn
    And nhân viên nhấn "Submit for Approval"
    Then hệ thống redirect đến login page
    Và lưu form data vào localStorage
    And sau khi login lại, form được restore từ localStorage
```

---

## 9. Release Planning

### Phase 1: Alpha (Private Preview)
- **Target:** Internal QA team + 2-3 pilot HR users
- **Scope:**
  - [x] Happy path: Create + Save Draft
  - [x] Balance validation cơ bản
  - [x] Date validation (start < end, overlap check)
  - [ ] Half-day/Hourly support (optional)
  - [ ] Attachment upload (optional)
- **Criteria to exit:** Không có P0 bugs trên happy path

### Phase 2: Beta (Public Preview)
- **Target:** Tất cả nhân viên trong 1 phòng ban pilot
- **Scope:**
  - [x] All AC scenarios passed
  - [x] NFRs đạt (response time ≤ 500ms)
  - [x] Edge cases handled
  - [x] Half-day/Hourly support
  - [x] Attachment upload
- **Criteria to exit:** HEART Task Success Rate ≥ 95% trong 2 tuần

### Phase 3: GA (General Availability)
- **Target:** Toàn bộ tổ chức
- **Scope:** Feature-complete, backward-compatible API frozen
- **Criteria:** 100% Acceptance Criteria passed + 0 P0 bugs

### Out of Scope (v1)
- Tạo đơn cho người khác (HR/Admin only - separate feature ABS-LR-011)
- Recurring leave requests (sẽ add ở v1.1)
- Leave sharing giữa nhân viên (separate feature)
- Calendar integration (Google/Outlook - separate feature ABS-CAL-001)
