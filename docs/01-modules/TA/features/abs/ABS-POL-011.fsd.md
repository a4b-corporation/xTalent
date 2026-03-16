---
id: ABS-POL-011
name: Documentation Requirements
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
    - Attachment
  rules:
    - rule_documentation_must_be_provided_if_required
  lifecycle: LeaveRequestLifecycle
  events: []

dependencies:
  requires:
    - ABS-POL-001: "Eligibility Rules"
    - ABS-LR-001: "Create Leave Request"
    - ABS-LR-007: "Leave Request with Attachments"
  required_by: []
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-POL-011: Documentation Requirements

> Yêu cầu tài liệu bắt buộc cho một số loại nghỉ.

---

## 1. Business Context

### Job Story
> **Khi** tôi cần yêu cầu giấy tờ chứng minh,
> **tôi muốn** cấu hình documentation requirements,
> **để** đảm bảo compliance.

### Success Metrics
- Requirement clarity ≥ 4.5/5
- Compliance rate ≥ 95%

---

## 2. UI Workflow

### Documentation Requirements Configuration (HR/Admin)
```json
{
  "type": "page",
  "title": "Documentation Requirements",
  "children": [
    {
      "type": "section",
      "padding": "lg",
      "children": [
        {
          "type": "table",
          "columns": [
            {"key": "leave_type", "label": "Leave Type"},
            {"key": "document_type", "label": "Required Document"},
            {"key": "threshold_days", "label": "Threshold (Days)"},
            {"key": "required", "label": "Required"},
            {"key": "actions", "label": ""}
          ],
          "data": "doc_requirements",
          "rowActions": ["edit", "delete", "toggle"]
        },
        {
          "type": "modal",
          "id": "doc_editor",
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
                  "type": "select",
                  "name": "document_type",
                  "label": "Document Type",
                  "options": [
                    {"value": "medical_cert", "label": "Medical Certificate"},
                    {"value": "death_cert", "label": "Death Certificate"},
                    {"value": "marriage_cert", "label": "Marriage Certificate"},
                    {"value": "birth_cert", "label": "Birth Certificate"},
                    {"value": "other", "label": "Other"}
                  ]
                },
                {
                  "type": "number",
                  "name": "threshold_days",
                  "label": "Required When Days >= ",
                  "help": "Số ngày nghỉ tối thiểu phải có giấy tờ"
                },
                {
                  "type": "select",
                  "name": "timing",
                  "label": "Submit Timing",
                  "options": [
                    {"value": "with_request", "label": "With Request"},
                    {"value": "within_3_days", "label": "Within 3 Days"},
                    {"value": "before_return", "label": "Before Return to Work"}
                  ]
                },
                {
                  "type": "checkbox",
                  "name": "required",
                  "label": "Mandatory (block submission if missing)"
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
| Threshold check | Leave days >= threshold | Require documentation |
| Submission timing | Per config | Allow later submission if configured |
| Block on missing | Required = true | Block request submission |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Validation time | ≤ 100ms |
| File upload | Support PDF, JPG, PNG (max 10MB) |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Sick leave 1 day | No doc required (below threshold) |
| E2 | Sick leave 5 days | Medical cert required |
| E3 | Doc submitted late | Allow within configured window, reminder notifications |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-POL-011 - Documentation Requirements

  Scenario: Configure doc requirement
    Given HR tạo rule: Sick Leave >= 3 days requires Medical Cert
    And required = true
    Khi HR save
    Thì rule hiển thị trong danh sách

  Scenario: Block submission without doc
    Given Sick Leave >= 3 days requires medical cert
    Khi employee tạo sick leave 5 days
    Và không upload medical cert
    Thì system block với error "Medical certificate required for leave >= 3 days"

  Scenario: Allow submission with doc
    Given requirement above
    Khi employee upload medical cert
    Thì request được submit

  Scenario: Threshold exemption
    Given requirement: Sick >= 3 days
    Khi employee tạo sick leave 2 days
    Thì không yêu cầu documentation
```

---

## 9. Release Planning

- **Alpha:** Basic doc requirement, block enforcement
- **Beta:** Threshold-based, submit timing options
- **GA:** Reminder notifications, late submission handling

### Out of Scope (v1)
- Document verification workflow
- Auto-reject for missing docs
