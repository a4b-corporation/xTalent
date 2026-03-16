---
id: ABS-ACC-005
name: Manual Accrual Run
module: TA
sub_module: ABS
category: Leave Accrual
priority: P1
status: Specified
differentiation: Parity
gap_type: Standard Fit
phase: 1

ontology_refs:
  concepts:
    - LeaveEventRun
    - LeaveMovement
    - LeaveInstant
  rules:
    - rule_accrual_must_have_valid_period
  lifecycle: LeavePeriodLifecycle
  events:
    - LeaveAccrued

dependencies:
  requires:
    - ABS-ACC-001: "Monthly Accrual Run"
    - ABS-ACC-002: "Accrual Configuration"
  required_by: []
  external:
    - "Batch Job Service"

created: 2026-03-13
author: BA Team
---

# ABS-ACC-005: Manual Accrual Run

> Cho phép HR chạy accrual thủ công cho employee hoặc nhóm employee.

---

## 1. Business Context

### Job Story
> **Khi** cần fix issues hoặc reprocess accrual,
> **tôi muốn** chạy manual accrual run,
> **để** đảm bảo employee có correct balance.

### Success Metrics
- Manual run success rate ≥ 98%
- Processing time ≤ 30s per employee

---

## 2. UI Workflow

### Manual Run Screen (HR/Admin)
```json
{
  "type": "page",
  "title": "Manual Accrual Run",
  "children": [
    {
      "type": "section",
      "padding": "lg",
      "children": [
        {
          "type": "form",
          "children": [
            {
              "type": "select",
              "name": "scope",
              "label": "Run Scope",
              "options": [
                {"value": "all", "label": "All Employees"},
                {"value": "department", "label": "By Department"},
                {"value": "individual", "label": "Individual Employee"}
              ],
              "required": true
            },
            {
              "type": "select",
              "name": "department",
              "label": "Department",
              "options": [],
              "visible": "scope === 'department'"
            },
            {
              "type": "employee-search",
              "name": "employee_id",
              "label": "Employee",
              "visible": "scope === 'individual'"
            },
            {
              "type": "date-picker",
              "name": "accrual_date",
              "label": "Accrual Date",
              "required": true
            },
            {
              "type": "checkbox",
              "name": "preview_only",
              "label": "Preview Only (do not execute)"
            }
          ]
        },
        {
          "type": "button-group",
          "buttons": [
            {"text": "Preview", "action": "preview"},
            {"text": "Run", "action": "execute", "variant": "primary"}
          ]
        }
      ]
    },
    {
      "type": "preview-panel",
      "visible": "preview_generated",
      "children": [
        {
          "type": "table",
          "columns": ["Employee", "Leave Type", "Accrual Qty", "New Balance"],
          "data": "preview_data"
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
| `LeaveAccrued` | Manual accrual executed | instant_id, leave_type_id, accrual_qty, period_id, run_type: "MANUAL" |

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| No duplicate accrual | Same employee, same period, same leave type | Block với error "Already accrued" |
| Preview required | First time user | Show preview before execute |
| Audit trail | All manual runs | Log user, timestamp, reason |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Processing time | ≤ 30s per employee |
| Max batch size | 1000 employees per run |
| Idempotency | Prevent duplicate accruals |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Employee terminated | Exclude từ manual run |
| E2 | Period already closed | Block với error |
| E3 | Duplicate manual run | Idempotency check, skip nếu đã tồn tại |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-ACC-005 - Manual Accrual Run

  Scenario: Preview manual accrual
    Given HR chọn scope = "individual"
    And chọn employee NV001
    Và chọn accrual date = 2026-03-01
    Khi HR click "Preview"
    Thì hiển thị preview với:
      | Employee | Leave Type | Accrual Qty | New Balance |
      | NV001    | Annual     | 1.5         | 12.5        |

  Scenario: Execute manual accrual
    Given preview hiển thị chính xác
    Khi HR click "Run"
    Thì LeaveAccrued event emitted
    Và accrual movement được tạo
    Và balance tăng 1.5 days

  Scenario: Duplicate prevention
    Given accrual đã tồn tại cho NV001, period 2026-03
    Khi HR thử chạy manual accrual
    Thì system block với error "Already accrued for this period"
```

---

## 9. Release Planning

- **Alpha:** Manual run for individual employee
- **Beta:** Department scope, preview functionality
- **GA:** All scopes, full audit integration

### Out of Scope (v1)
- Scheduled manual runs
- Bulk import for manual accrual
