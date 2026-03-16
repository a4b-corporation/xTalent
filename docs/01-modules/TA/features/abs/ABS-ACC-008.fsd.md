---
id: ABS-ACC-008
name: Predictive Accrual Forecasting
module: TA
sub_module: ABS
category: Leave Accrual
priority: P2
status: Specified
differentiation: Innovation
gap_type: Core Gap
phase: 2

ontology_refs:
  concepts:
    - LeaveEventRun
    - LeaveMovement
    - LeaveInstant
  rules:
    - rule_accrual_forecast_must_consider_tenure
  lifecycle: []
  events: []

dependencies:
  requires:
    - ABS-ACC-001: "Monthly Accrual Run"
    - ABS-ACC-004: "Accrual History View"
    - ABS-BAL-003: "Leave Balance Projection"
  required_by: []
  external:
    - "ML/AI Service (optional)"

created: 2026-03-13
author: BA Team
---

# ABS-ACC-008: Predictive Accrual Forecasting

> Dự báo accrual dựa trên historical patterns và tenure projection.

---

## 1. Business Context

### Job Story
> **Khi** tôi muốn lập kế hoạch leave liability,
> **tôi muốn** xem predictive accrual forecast,
> **để** financial planning và budgeting.

### Success Metrics
- Forecast accuracy ≥ 85%
- User trust score ≥ 4.0/5

---

## 2. UI Workflow

### Forecast Dashboard (HR/Admin/Finance)
```json
{
  "type": "page",
  "title": "Accrual Forecast Dashboard",
  "children": [
    {
      "type": "section",
      "padding": "lg",
      "children": [
        {
          "type": "form",
          "children": [
            {
              "type": "date-range",
              "name": "forecast_period",
              "label": "Forecast Period",
              "default": "Next 12 months"
            },
            {
              "type": "select",
              "name": "scope",
              "label": "Scope",
              "options": [
                {"value": "all", "label": "All Employees"},
                {"value": "department", "label": "By Department"},
                {"value": "leave_type", "label": "By Leave Type"}
              ]
            }
          ]
        },
        {
          "type": "chart",
          "chartType": "line",
          "title": "Monthly Accrual Forecast",
          "data": "forecast_data",
          "xAxis": "month",
          "yAxis": "accrual_days"
        },
        {
          "type": "summary-cards",
          "cards": [
            {"label": "Total Forecast Accrual", "value": "1,234 days"},
            {"label": "Avg per Employee", "value": "12.5 days"},
            {"label": "Liability Value", "value": "$456,789"}
          ]
        },
        {
          "type": "table",
          "columns": [
            {"key": "employee", "label": "Employee"},
            {"key": "current_accrual", "label": "Current Monthly"},
            {"key": "forecast_accrual", "label": "Forecast Monthly"},
            {"key": "change_reason", "label": "Change Reason"}
          ],
          "data": "employee_forecasts"
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
| None | Forecast only - no state change | N/A |

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Tenure-based projection | Anniversary approaching | Adjust forecast accrual rate |
| Historical averaging | 12+ months history | Use average for forecast |
| New employee handling | < 6 months tenure | Use policy rate for forecast |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Forecast calculation | ≤ 30s |
| Forecast accuracy | ≥ 85% vs actual |
| Data refresh | Daily batch update |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Employee termination planned | Exclude from forecast |
| E2 | Policy change mid-period | Show scenario comparison |
| E3 | Insufficient history | Use policy defaults, mark as "low confidence" |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-ACC-008 - Predictive Accrual Forecasting

  Scenario: Generate 12-month forecast
    Given HR chọn forecast period = Next 12 months
    Khi HR generate forecast
    Thì hiển thị monthly breakdown
    Và total liability calculation

  Scenario: Department-level forecast
    Given HR chọn scope = "Engineering Department"
    Khi generate forecast
    Thì chỉ hiển thị Engineering employees
    Và department total

  Scenario: Tenure-based adjustment
    Given employee có anniversary trong forecast period
    Và tenure bracket change (5 → 6 years)
    Khi forecast calculate
    Thì reflect higher accrual rate sau anniversary

  Scenario: Low confidence warning
    Given employee có < 6 months tenure
    Khi forecast generate
    Thì hiển thị "low confidence" indicator
```

---

## 9. Release Planning

- **Alpha:** Basic forecast using policy rates
- **Beta:** Historical averaging, tenure adjustments
- **GA:** ML-based predictions, scenario analysis, liability valuation

### Out of Scope (v1)
- Integration with financial systems
- What-if analysis for policy changes
- Employee-level forecast export
