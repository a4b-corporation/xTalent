---
id: ABS-CARRY-006
name: Carryover Preview
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
    - LeavePeriod
    - LeaveMovement
    - LeaveInstant
  rules: []
  lifecycle: LeavePeriodLifecycle
  events: []

dependencies:
  requires:
    - ABS-CARRY-001: "Limited Carryover"
    - ABS-CARRY-005: "Year-End Processing"
  required_by: []
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-CARRY-006: Carryover Preview

> Preview kết quả carryover trước khi process chính thức.

---

## 1. Business Context

### Job Story
> **Khi** chuẩn bị process carryover,
> **tôi muốn** preview kết quả,
> **để** verify trước khi execute.

### Success Metrics
- Preview accuracy ≥ 99%
- HR confidence score ≥ 4.5/5

---

## 2. UI Workflow

### Preview Screen (HR/Admin)
```json
{
  "type": "page",
  "title": "Carryover Preview",
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
              "name": "source_period",
              "label": "Source Period (Year)",
              "options": [{"value": "2025", "label": "2025"}]
            },
            {
              "type": "select",
              "name": "target_period",
              "label": "Target Period (Year)",
              "options": [{"value": "2026", "label": "2026"}]
            },
            {
              "type": "button",
              "text": "Generate Preview",
              "action": "generate_preview"
            }
          ]
        },
        {
          "type": "summary-cards",
          "visible": "preview_generated",
          "cards": [
            {"label": "Total Employees", "value": "1,234"},
            {"label": "Total Days to Carry", "value": "3,456"},
            {"label": "Total Days to Expire", "value": "123"}
          ]
        },
        {
          "type": "table",
          "visible": "preview_generated",
          "columns": [
            {"key": "employee", "label": "Employee"},
            {"key": "leave_type", "label": "Leave Type"},
            {"key": "unused_days", "label": "Unused Days"},
            {"key": "carry_days", "label": "Carry Days"},
            {"key": "expire_days", "label": "Expire Days"}
          ],
          "data": "preview_data",
          "pagination": true,
          "export": true
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
| None | Preview only - no state change | N/A |

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Read-only operation | Preview mode | No state changes |
| Real-time calculation | On generate | Calculate based on current data |
| Data snapshot | Preview generated | Store temporary snapshot for comparison |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Preview generation | ≤ 10s |
| Data accuracy | Match actual execution ≥ 99% |
| Export | Support Excel/PDF export |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Large dataset (>10000 employees) | Paginate results, async generation |
| E2 | Period already processed | Show error "Already processed" |
| E3 | Data changes after preview | Warn "Data may have changed" |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-CARRY-006 - Carryover Preview

  Scenario: Generate carryover preview
    Given HR chọn source period = 2025, target = 2026
    Khi HR click "Generate Preview"
    Thì hiển thị summary cards
    Và table hiển thị employee breakdown
    Và không có state changes

  Scenario: Preview accuracy
    Given preview hiển thị 100 days sẽ carryover
    Khi execute actual carryover
    Thì actual result = 100 days (±1 day do data changes)

  Scenario: Export preview
    Given preview đã generate
    Khi HR click "Export Excel"
    Thì file Excel được download với full data
```

---

## 9. Release Planning

- **Alpha:** Basic preview, table display
- **Beta:** Summary cards, filtering
- **GA:** Export, comparison with actual, async generation

### Out of Scope (v1)
- What-if analysis
- Multiple scenario comparison
