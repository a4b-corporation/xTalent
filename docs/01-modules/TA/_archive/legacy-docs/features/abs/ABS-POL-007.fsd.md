---
id: ABS-POL-007
name: Policy Library UI
module: TA
sub_module: ABS
category: Leave Policy Rules
priority: P1
status: Specified
differentiation: Parity
gap_type: Standard Fit
phase: 1

ontology_refs:
  concepts:
    - LeavePolicy
    - LeaveType
    - LeaveClass
  rules: []
  lifecycle: []
  events: []

dependencies:
  requires:
    - ABS-POL-001: "Eligibility Rules"
    - ABS-POL-002: "Validation Rules"
  required_by: []
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-POL-007: Policy Library UI

> UI để quản lý policies và rules cho leave types.

---

## 1. Business Context

### Job Story
> **Khi** tôi cần quản lý leave policies,
> **tôi muốn** UI trực quan,
> **để** tạo/sửa/xóa và xem impact.

### Success Metrics
- Policy creation time ≤ 5 min
- User satisfaction ≥ 4.0/5

---

## 2. UI Workflow

### Policy Library Screen (HR/Admin)
```json
{
  "type": "page",
  "title": "Policy Library",
  "children": [
    {
      "type": "navbar",
      "brand": "xTalent",
      "title": "Leave Policy Management"
    },
    {
      "type": "section",
      "padding": "lg",
      "children": [
        {
          "type": "toolbar",
          "actions": [
            {"text": "Create Policy", "action": "create", "variant": "primary"},
            {"text": "Import", "action": "import"},
            {"text": "Export", "action": "export"}
          ]
        },
        {
          "type": "table",
          "columns": [
            {"key": "policy_name", "label": "Policy Name"},
            {"key": "leave_type", "label": "Leave Type"},
            {"key": "leave_class", "label": "Leave Class"},
            {"key": "rules_count", "label": "Rules"},
            {"key": "status", "label": "Status"},
            {"key": "actions", "label": ""}
          ],
          "data": "policies",
          "rowActions": ["edit", "copy", "delete", "preview_impact"]
        }
      ]
    },
    {
      "type": "modal",
      "id": "policy_editor",
      "visible": "editing",
      "children": [
        {
          "type": "form",
          "children": [
            {
              "type": "input",
              "name": "policy_name",
              "label": "Policy Name"
            },
            {
              "type": "select",
              "name": "leave_type",
              "label": "Leave Type",
              "options": []
            },
            {
              "type": "select",
              "name": "leave_class",
              "label": "Leave Class",
              "options": []
            },
            {
              "type": "rule-builder",
              "name": "rules",
              "label": "Policy Rules",
              "ruleTypes": ["eligibility", "validation", "limit", "overdraft", "proration", "rounding"]
            }
          ]
        }
      ]
    }
  ]
}
```

### Policy Detail View
- Policy metadata
- Attached rules (organized by type)
- Effective dates
- Associated employees/classes

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| None | UI only - state changes via other events | N/A |

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Unique policy name | Per leave type | Enforce uniqueness |
| At least one rule | Policy creation | Require min 1 rule |
| Cannot delete if in use | Policy bound to employees | Block với warning |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Page load time | ≤ 2s |
| Policy save time | ≤ 1s |
| Concurrent edits | Lock mechanism |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Delete policy with active bindings | Block, show "in use by X employees" |
| E2 | Duplicate policy name | Error "Name already exists" |
| E3 | Concurrent edit conflict | Lock policy, notify other user |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-POL-007 - Policy Library UI

  Scenario: Create new policy
    Given HR click "Create Policy"
    Khi HR nhập policy name, select leave type
    Và add eligibility rule
    Và save
    Thì policy được tạo
    Và hiển thị trong danh sách

  Scenario: Edit existing policy
    Given policy "Annual Leave Standard" tồn tại
    Khi HR click edit, modify rule
    Và save
    Thì policy được cập nhật
    Và version history được lưu

  Scenario: Delete policy in use
    Given policy đang áp dụng cho 100 employees
    Khi HR click delete
    Thì system block với error "Policy in use by 100 employees"

  Scenario: Preview policy impact
    Given HR chọn policy
    Khi HR click "Preview Impact"
    Thì hiển thị danh sách employees affected
```

---

## 9. Release Planning

- **Alpha:** Basic CRUD, policy list
- **Beta:** Rule builder, preview impact
- **GA:** Import/export, version history, bulk operations

### Out of Scope (v1)
- Policy templates
- Approval workflow for policy changes
