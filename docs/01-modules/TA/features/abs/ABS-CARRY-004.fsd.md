---
id: ABS-CARRY-004
name: Leave Payout
module: TA
sub_module: ABS
category: Leave Carryover
priority: P0
status: Specified
differentiation: Parity
gap_type: Standard Fit
phase: 1

ontology_refs:
  concepts:
    - LeaveMovement
    - LeaveInstant
  rules:
    - rule_payout_must_have_valid_period
  lifecycle: LeavePeriodLifecycle
  events:
    - LeavePayoutExecuted

dependencies:
  requires:
    - ABS-CARRY-001: "Limited Carryover"
    - ABS-BAL-002: "Balance Calculation"
  required_by: []
  external:
    - "Payroll Service"

created: 2026-03-13
author: BA Team
---

# ABS-CARRY-004: Leave Payout

> Thanh toán ngày nghỉ không sử dụng thay vì carryover.

---

## 1. Business Context

### Job Story
> **Khi** employee không sử dụng hết ngày phép,
> **tôi muốn** thanh toán ngày dư,
> **để** employee được quyền lợi.

### Success Metrics
- Payout accuracy 100%
- Payroll integration success ≥ 99%

---

## 2. UI Workflow

### Payout Configuration (HR/Admin)
```json
{
  "type": "page",
  "title": "Leave Payout Configuration",
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
              "name": "payout_mode",
              "label": "Payout Mode",
              "options": [
                {"value": "none", "label": "No Payout"},
                {"value": "full", "label": "Full Payout"},
                {"value": "partial", "label": "Partial Payout (max X days)"}
              ],
              "required": true
            },
            {
              "type": "number",
              "name": "max_payout_days",
              "label": "Max Payout Days",
              "visible": "payout_mode === 'partial'"
            },
            {
              "type": "select",
              "name": "calculation_method",
              "label": "Calculation Method",
              "options": [
                {"value": "base_salary", "label": "Base Salary"},
                {"value": "avg_salary", "label": "Average Salary (3 months)"},
                {"value": "custom_rate", "label": "Custom Rate"}
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

### Payout Execution Screen
- Select period (leave year)
- Preview payout amounts
- Execute payout → Send to payroll

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeavePayoutExecuted` | Payout executed | instant_id, leave_type_id, payout_days, payout_amount, period_id |

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Payout eligibility | Employee active at year-end | Allow payout |
| Payout calculation | Based on configuration | Calculate amount |
| Payroll sync | After payout execution | Send to payroll service |
| No double benefit | Days already carried over | Cannot payout |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Calculation accuracy | 100% |
| Payroll sync time | ≤ 5s |
| Audit trail | Full logging |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Employee terminated mid-year | Pro-rate payout |
| E2 | Negative balance | Block payout, require repayment |
| E3 | Payroll service unavailable | Retry queue, alert admin |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-CARRY-004 - Leave Payout

  Scenario: Full payout execution
    Given employee có 5 days unused
    And payout_mode = "full"
    Khi HR execute payout cho year 2025
    Thì 5 days được thanh toán
    Và LeavePayoutExecuted event emitted
    Và payroll service nhận được request

  Scenario: Partial payout
    Given employee có 10 days unused
    And max_payout_days = 5
    Khi execute payout
    Thì chỉ 5 days được thanh toán
    Và 5 days còn lại carryover (nếu cấu hình)
```

---

## 9. Release Planning

- **Alpha:** Full payout, base salary calculation
- **Beta:** Partial payout, multiple calculation methods
- **GA:** Full payroll integration, pro-rating
