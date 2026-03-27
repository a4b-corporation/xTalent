---
id: ABS-CARRY-007
name: Forfeiture Report
module: TA
sub_module: ABS
category: Leave Carryover
priority: P1
status: Specified
differentiation: Parity
gap_type: Standard Fit
phase: 1

ontology_refs:
  concepts:
    - LeaveMovement
    - LeaveInstant
  rules: []
  lifecycle: []
  events: []

dependencies:
  requires:
    - ABS-CARRY-003: "Carryover Expiry"
    - ABS-CARRY-005: "Year-End Processing"
  required_by: []
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-CARRY-007: Forfeiture Report

> Báo cáo ngày nghỉ hết hạn (forfeited days).

---

## 1. Business Context

### Job Story
> **Khi** tôi cần theo dõi ngày hết hạn,
> **tôi muốn** xem forfeiture report,
> **để** báo cáo và phân tích.

### Success Metrics
- Report generation time ≤ 5s
- Export success rate 100%

---

## 2. UI Workflow

### Forfeiture Report Screen (HR/Admin)
```json
{
  "type": "page",
  "title": "Forfeiture Report",
  "children": [
    {
      "type": "section",
      "padding": "lg",
      "children": [
        {
          "type": "filters",
          "children": [
            {
              "type": "date-range",
              "name": "expiry_period",
              "label": "Expiry Period"
            },
            {
              "type": "select",
              "name": "department",
              "label": "Department",
              "options": [],
              "multiple": true
            },
            {
              "type": "select",
              "name": "leave_type",
              "label": "Leave Type",
              "options": [],
              "multiple": true
            }
          ]
        },
        {
          "type": "button-group",
          "buttons": [
            {"text": "Generate", "action": "generate", "variant": "primary"},
            {"text": "Export Excel", "action": "export_excel"},
            {"text": "Export PDF", "action": "export_pdf"}
          ]
        },
        {
          "type": "table",
          "visible": "report_generated",
          "columns": [
            {"key": "employee_id", "label": "Employee ID"},
            {"key": "employee_name", "label": "Employee Name"},
            {"key": "department", "label": "Department"},
            {"key": "leave_type", "label": "Leave Type"},
            {"key": "expired_days", "label": "Expired Days"},
            {"key": "expiry_date", "label": "Expiry Date"}
          ],
          "data": "report_data",
          "sortable": true,
          "pagination": true
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
| None | Report only - no state change | N/A |

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Read-only | Report mode | No state changes |
| Data scope | Based on filters | Show matching records only |
| Export format | Excel/PDF | Standard formatting |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Report generation | ≤ 5s |
| Export file size | ≤ 10MB |
| Data accuracy | 100% match with source |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | No data for selected period | Show empty state message |
| E2 | Very large dataset | Paginate, async export |
| E3 | Export timeout | Retry with smaller batch |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-CARRY-007 - Forfeiture Report

  Scenario: Generate forfeiture report
    Given HR chọn expiry period = 2025-Q4
    Khi HR click "Generate"
    Thì hiển thị table với columns:
      | Employee ID | Name | Department | Leave Type | Expired Days | Expiry Date |

  Scenario: Filter by department
    Given report đã generate
    Khi HR filter theo department = "Engineering"
    Thì chỉ hiển thị Engineering employees

  Scenario: Export report
    Given report đã generate
    Khi HR click "Export Excel"
    Thì file Excel được download với đầy đủ data
```

---

## 9. Release Planning

- **Alpha:** Basic report, table display
- **Beta:** Filters, sorting
- **GA:** Export (Excel/PDF), scheduled reports

### Out of Scope (v1)
- Email delivery
- Dashboard widgets
