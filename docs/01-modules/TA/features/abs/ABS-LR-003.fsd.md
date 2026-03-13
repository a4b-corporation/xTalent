---
id: ABS-LR-003
name: View Leave Request Status
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
  rules:
    - rule_request_status_transition_valid
  lifecycle: LeaveRequestLifecycle
  events:
    - LeaveRequested
    - LeaveRequestApproved
    - LeaveRequestRejected

dependencies:
  requires:
    - ABS-LR-001: "Create Leave Request - nguồn dữ liệu requests"
    - ABS-LR-002: "Submit Leave Request - nguồn data status"
  required_by:
    - ABS-LR-004: "Withdraw Leave Request - cần xem status trước khi withdraw"
    - ABS-APR-008: "View Approval History - mở rộng chi tiết approval"
  external: []

created: 2026-03-13
updated: 2026-03-13
author: BA Team
---

# ABS-LR-003: View Leave Request Status

> Cho phép nhân viên xem danh sách và trạng thái tất cả đơn xin nghỉ đã tạo, với filter và search.

---

## 1. Business Context

### Problem Statement

Nhân viên cần theo dõi trạng thái các đơn xin nghỉ đã gửi để biết đơn nào đã approve, pending, hay rejected. Không có visibility này dẫn đến confusion và follow-up không cần thiết với manager.

### Job Story

> **Khi** tôi muốn biết trạng thái đơn xin nghỉ đã gửi,
> **tôi muốn** xem danh sách tất cả đơn với status rõ ràng,
> **để** tôi biết đơn nào đã được approve và lên kế hoạch nghỉ phù hợp.

### Success Metrics

| Metric | Framework | Target |
|--------|----------|--------|
| Page Load Time | HEART | ≤ 1s at P95 |
| Search Success Rate | HEART | ≥ 95% |
| User Satisfaction | HEART | ≥ 4.5/5 |

---

## 2. UI Workflow & Mockup

### Screen Flow

```text
[My Absences Dashboard]
       ↓
[View All Requests]
       ↓
[Leave Request List]
       ├── Click row → [Request Detail]
       ├── Filter → [Filtered List]
       └── Search → [Search Results]
```

### Mockup — Leave Request List

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
          "text": "My Leave Requests"
        },
        {
          "type": "card",
          "padding": "md",
          "children": [
            {
              "type": "toolbar",
              "children": [
                {
                  "type": "search",
                  "placeholder": "Search by leave type, dates...",
                  "name": "search"
                },
                {
                  "type": "select",
                  "name": "status_filter",
                  "options": [
                    {"value": "all", "label": "All Status"},
                    {"value": "DRAFT", "label": "Draft"},
                    {"value": "SUBMITTED", "label": "Pending"},
                    {"value": "APPROVED", "label": "Approved"},
                    {"value": "REJECTED", "label": "Rejected"},
                    {"value": "CANCELLED", "label": "Cancelled"}
                  ]
                },
                {
                  "type": "select",
                  "name": "leave_type_filter",
                  "options": [
                    {"value": "all", "label": "All Types"},
                    {"value": "annual", "label": "Annual Leave"},
                    {"value": "sick", "label": "Sick Leave"},
                    {"value": "maternity", "label": "Maternity Leave"}
                  ]
                },
                {
                  "type": "date-range",
                  "name": "date_filter",
                  "placeholder": "Date Range"
                }
              ]
            },
            {
              "type": "table",
              "columns": [
                {"key": "request_id", "label": "Request ID", "width": "100px"},
                {"key": "leave_type", "label": "Type", "width": "120px"},
                {"key": "start_date", "label": "Start Date", "width": "100px"},
                {"key": "end_date", "label": "End Date", "width": "100px"},
                {"key": "days", "label": "Days", "width": "60px"},
                {"key": "status", "label": "Status", "width": "100px"},
                {"key": "submitted_at", "label": "Submitted", "width": "120px"},
                {"key": "actions", "label": "", "width": "80px"}
              ],
              "rows": "{{leave_requests}}",
              "emptyState": {
                "message": "No leave requests found",
                "cta": {"text": "Create Your First Request", "action": "navigate_to_create"}
              },
              "rowAction": "navigate_to_detail"
            },
            {
              "type": "pagination",
              "total": "{{total_requests}}",
              "pageSize": 20
            }
          ]
        }
      ]
    }
  ]
}
```

### Micro UI States

**Empty State:**
- Message: "You haven't created any leave requests yet"
- CTA: Button "+ Create Leave Request"

**Loading State:**
- Skeleton rows trong table
- Spinner cho filter/search

---

## 3. System Events

| Event | Trigger | Actor |
|-------|---------|-------|
| N/A (read-only feature) | — | — |

---

## 4. Business Rules

### Rule References

| Rule ID | Description |
|---------|-------------|
| [`rule_request_status_transition_valid`](../ontology/rules.yaml#L474) | Status transition phải hợp lệ |

### Feature-specific Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Data Scope | Employee chỉ xem được đơn của chính mình | Filter WHERE employee_id = current_user |
| Sort Order | Default sort by submitted_at DESC | Newest first |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Page Load Time | ≤ 1s at P95 |
| Concurrent Users | Support 500 concurrent viewers |
| Mobile Responsive | Yes, min 375px |

---

## 6. Dependency Map

| Requires | Relationship | Reason |
|----------|-------------|--------|
| ABS-LR-001 | FS | Nguồn data requests |
| ABS-LR-002 | FS | Nguồn status updates |

| Required By | Relationship |
|-------------|-------------|
| ABS-LR-004 | FS |
| ABS-APR-008 | SS |

---

## 7. Edge & Corner Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Employee có > 100 requests | Pagination, server-side filtering |
| E2 | Search không có result | Hiển thị "No results" với option clear filters |
| E3 | Request data đang load | Skeleton loading state |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-LR-003 - View Leave Request Status

  Scenario: Xem danh sách requests
    Given nhân viên có 5 leave requests
    Khi nhân viên vào trang "My Leave Requests"
    Thì hiển thị danh sách 5 requests sorted by submitted_at DESC
    Và mỗi row hiển thị: Request ID, Type, Dates, Days, Status, Submitted date

  Scenario: Filter theo status
    Khi nhân viên chọn filter "APPROVED"
    Thì chỉ hiển thị các requests với status APPROVED

  Scenario: Search requests
    Khi nhân viên search "Annual"
    Thì chỉ hiển thị requests với leave_type chứa "Annual"

  Scenario: Empty state
    Given nhân viên chưa có request nào
    Khi nhân viên vào trang
    Thì hiển thị "No leave requests found"
    Và button "Create Your First Request"
```

---

## 9. Release Planning

### Phase 1: Alpha
- List cơ bản với tất cả requests
- Sort by date

### Phase 2: Beta
- Filters (status, type, date range)
- Search functionality
- Pagination

### Phase 3: GA
- Export to CSV
- Advanced filters

### Out of Scope (v1)
- Custom date range filter (v1.1)
- Export functionality (v1.2)
