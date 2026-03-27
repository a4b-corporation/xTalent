---
id: ABS-POL-010
name: Advance Notice Rules
module: TA
sub_module: ABS
category: Leave Policy Rules
priority: P0
status: Specified
differentiation: Parity
gap_type: Standard Fit
phase: 1

ontology_refs:
  concepts:
    - LeavePolicy
    - LeaveRequest
  rules:
    - rule_request_must_satisfy_advance_notice
  lifecycle: LeaveRequestLifecycle
  events: []

dependencies:
  requires:
    - ABS-POL-001: "Eligibility Rules"
    - ABS-LR-001: "Create Leave Request"
  required_by: []
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-POL-010: Advance Notice Rules

> Yêu cầu thời gian báo trước khi xin nghỉ.

---

## 1. Business Context

### Job Story
> **Khi** tôi cần đảm bảo nhân viên báo trước đủ thời gian,
> **tôi muốn** cấu hình advance notice rules,
> **để** quản lý có thời gian xử lý.

### Success Metrics
- Validation accuracy 100%
- Configurable per leave type

---

## 2. UI Workflow

### Advance Notice Configuration (HR/Admin)
```json
{
  "type": "page",
  "title": "Advance Notice Rules",
  "children": [
    {
      "type": "section",
      "padding": "lg",
      "children": [
        {
          "type": "table",
          "columns": [
            {"key": "leave_type", "label": "Leave Type"},
            {"key": "min_days", "label": "Min Days Notice"},
            {"key": "enforcement", "label": "Enforcement"},
            {"key": "exceptions", "label": "Exceptions"},
            {"key": "actions", "label": ""}
          ],
          "data": "notice_rules",
          "rowActions": ["edit", "delete"]
        },
        {
          "type": "modal",
          "id": "notice_editor",
          "visible": "editing",
          "children": [
            {
              "type": "form",
              "children": [
                {
                  "type": "select",
                  "name": "leave_type",
                  "label": "Leave Type",
                  "options": []
                },
                {
                  "type": "number",
                  "name": "min_days",
                  "label": "Minimum Days Notice",
                  "min": 0,
                  "help": "Số ngày tối thiểu phải báo trước"
                },
                {
                  "type": "select",
                  "name": "enforcement",
                  "label": "Enforcement",
                  "options": [
                    {"value": "block", "label": "Block (Error)"},
                    {"value": "warn", "label": "Warning"},
                    {"value": "auto_approve", "label": "Auto-approve if not met (manager only)"}
                  ]
                },
                {
                  "type": "checkbox-group",
                  "name": "exceptions",
                  "label": "Exceptions",
                  "options": [
                    {"value": "sick", "label": "Sick Leave (same-day allowed)"},
                    {"value": "emergency", "label": "Emergency Leave"},
                    {"value": "manager_override", "label": "Manager Override"}
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

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| None | Configuration only | N/A |

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Notice calculation | Request date vs start date | Calculate days notice |
| Business days option | Configurable | Count only working days |
| Exception handling | Sick/emergency | Bypass notice requirement |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Validation time | ≤ 100ms |
| Configurable per type | Independent rules |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Sick leave same-day | Allow (exception) |
| E2 | Weekend/holiday in notice period | Count based on config (calendar vs business days) |
| E3 | Partial day notice | Round up to full day |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-POL-010 - Advance Notice Rules

  Scenario: Configure advance notice
    Given HR cấu hình Annual Leave min_days = 7
    And enforcement = "block"
    Khi rule được save
    Thì hiển thị trong danh sách

  Scenario: Block insufficient notice
    Given min_days = 7 cho Annual Leave
    Khi employee tạo request cho 2026-04-05
    Và today = 2026-04-01 (only 4 days notice)
    Thì system block với error "Insufficient notice: 7 days required"

  Scenario: Allow sufficient notice
    Given min_days = 7
    Khi employee tạo request cho 2026-04-15
    Và today = 2026-04-01 (14 days notice)
    Thì request được allow

  Scenario: Sick leave exception
    Given sick leave có exception "same-day allowed"
    Khi employee tạo sick leave request cho hôm nay
    Thì được allow dù không đủ notice
```

---

## 9. Release Planning

- **Alpha:** Basic notice rule, block enforcement
- **Beta:** Business days option, warning mode
- **GA:** Exceptions, manager override

### Out of Scope (v1)
- Escalation for short-notice requests
- Dynamic notice based on duration
