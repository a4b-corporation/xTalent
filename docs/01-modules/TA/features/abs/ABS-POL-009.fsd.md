---
id: ABS-POL-009
name: Blackout Periods
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
    - rule_request_cannot_fall_in_blackout_period
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

# ABS-POL-009: Blackout Periods

> Định nghĩa khoảng thời gian không được phép nghỉ.

---

## 1. Business Context

### Job Story
> **Khi** tôi cần restrict nghỉ trong thời gian cao điểm,
> **tôi muốn** định nghĩa blackout periods,
> **để** đảm bảo đủ nhân sự.

### Success Metrics
- Validation accuracy 100%
- Configuration flexibility ≥ 4 options

---

## 2. UI Workflow

### Blackout Period Configuration (HR/Admin)
```json
{
  "type": "page",
  "title": "Blackout Periods",
  "children": [
    {
      "type": "section",
      "padding": "lg",
      "children": [
        {
          "type": "toolbar",
          "actions": [
            {"text": "Add Blackout Period", "action": "add", "variant": "primary"}
          ]
        },
        {
          "type": "table",
          "columns": [
            {"key": "name", "label": "Name"},
            {"key": "start_date", "label": "Start Date"},
            {"key": "end_date", "label": "End Date"},
            {"key": "leave_types", "label": "Leave Types"},
            {"key": "scope", "label": "Scope"},
            {"key": "recurring", "label": "Recurring"},
            {"key": "actions", "label": ""}
          ],
          "data": "blackout_periods",
          "rowActions": ["edit", "delete", "toggle"]
        }
      ]
    },
    {
      "type": "modal",
      "id": "blackout_editor",
      "visible": "editing",
      "children": [
        {
          "type": "form",
          "children": [
            {
              "type": "input",
              "name": "name",
              "label": "Blackout Name",
              "placeholder": "e.g., Year-End Close, Tet Holiday"
            },
            {
              "type": "date-range",
              "name": "date_range",
              "label": "Date Range"
            },
            {
              "type": "select",
              "name": "leave_types",
              "label": "Leave Types",
              "options": [],
              "multiple": true
            },
            {
              "type": "select",
              "name": "scope",
              "label": "Scope",
              "options": [
                {"value": "all", "label": "All Employees"},
                {"value": "department", "label": "By Department"},
                {"value": "location", "label": "By Location"}
              ]
            },
            {
              "type": "checkbox",
              "name": "recurring",
              "label": "Recurring (every year)"
            },
            {
              "type": "select",
              "name": "enforcement",
              "label": "Enforcement",
              "options": [
                {"value": "block", "label": "Block Request (Error)"},
                {"value": "warn", "label": "Warning Only"}
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
| Blackout validation | Request falls in blackout | Block or warn per config |
| Partial overlap | Request partially overlaps | Block entire request or allow partial |
| Recurring periods | Every year | Auto-apply without re-entry |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Validation time | ≤ 100ms per request |
| Max blackout periods | 100 per year |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Existing request, new blackout | Grandfather existing, block new |
| E2 | Overlapping blackout periods | Merge, show combined period |
| E3 | Holiday falls in blackout | Display both, enforce stricter |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-POL-009 - Blackout Periods

  Scenario: Create blackout period
    Given HR tạo blackout "Year-End Close"
    And date range = 2025-12-25 to 2026-01-05
    And scope = "All Employees"
    Khi HR save
    Thì blackout period được tạo
    Và hiển thị trong danh sách

  Scenario: Block request during blackout
    Given blackout period 2025-12-25 to 2026-01-05
    And enforcement = "block"
    Khi employee tạo request cho 2025-12-28
    Thì system block với error "Cannot request leave during blackout period"

  Scenario: Warning for blackout
    Given enforcement = "warn"
    Khi employee tạo request trong blackout
    Thì hiển thị warning
    Và employee vẫn có thể submit

  Scenario: Recurring blackout
    Given blackout là recurring (every year)
    Khi tạo cho 2025
    Thì tự động áp dụng cho 2026, 2027, etc.
```

---

## 9. Release Planning

- **Alpha:** Basic blackout creation, block enforcement
- **Beta:** Recurring periods, warning mode
- **GA:** Partial overlap handling, department scope

### Out of Scope (v1)
- Override approval for blackout
- Temporary suspension of blackout
