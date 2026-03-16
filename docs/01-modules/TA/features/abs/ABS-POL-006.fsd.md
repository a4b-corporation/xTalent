---
id: ABS-POL-006
name: Rounding Rules
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
    - LeaveType
  rules:
    - rule_rounding_must_be_configured_per_policy
  lifecycle: []
  events: []

dependencies:
  requires:
    - ABS-POL-001: "Eligibility Rules"
    - ABS-BAL-002: "Balance Calculation"
  required_by: []
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-POL-006: Rounding Rules

> Cấu hình quy tắc làm tròn cho fractional leave amounts.

---

## 1. Business Context

### Job Story
> **Khi** có số lẻ (fractional days),
> **tôi muốn** cấu hình rounding rules,
> **để** đảm bảo consistent handling.

### Success Metrics
- Rounding consistency 100%
- Configuration flexibility ≥ 4 options

---

## 2. UI Workflow

### Rounding Configuration (HR/Admin)
```json
{
  "type": "page",
  "title": "Rounding Rules Configuration",
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
              "name": "rounding_mode",
              "label": "Rounding Mode",
              "options": [
                {"value": "none", "label": "No Rounding (exact)"},
                {"value": "up", "label": "Round Up"},
                {"value": "down", "label": "Round Down"},
                {"value": "nearest", "label": "Round Nearest"}
              ],
              "required": true
            },
            {
              "type": "select",
              "name": "rounding_precision",
              "label": "Round To Nearest",
              "options": [
                {"value": "0.25", "label": "Quarter (0.25)"},
                {"value": "0.5", "label": "Half (0.5)"},
                {"value": "1", "label": "Whole (1.0)"},
                {"value": "0.01", "label": "Two Decimals (0.01)"}
              ],
              "visible": "rounding_mode !== 'none'"
            },
            {
              "type": "info-box",
              "variant": "info",
              "content": "Examples: 3.3 days with Round Up to 1 = 4 days; 3.3 with Round Down to 0.5 = 3.0 days"
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
| Rounding applies | Leave calculation | Apply configured rounding |
| Per policy | Each leave policy | Independent rounding config |
| Consistency | All calculations | Same rounding for same policy |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Calculation accuracy | Exact rounding per config |
| Performance | ≤ 1ms per rounding operation |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Exactly at boundary (e.g., 3.5 with round to 0.5) | No change needed |
| E2 | Midpoint (e.g., 3.25 with round to 0.5) | Round to nearest even or up (configurable) |
| E3 | Negative values | Same rounding rules apply |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-POL-006 - Rounding Rules

  Scenario: Round up to whole day
    Given rounding_mode = "up", precision = "1"
    And calculated leave = 3.2 days
    Khi apply rounding
    Thì result = 4 days

  Scenario: Round down to half day
    Given rounding_mode = "down", precision = "0.5"
    And calculated leave = 3.3 days
    Khi apply rounding
    Thì result = 3.0 days

  Scenario: Round nearest to quarter
    Given rounding_mode = "nearest", precision = "0.25"
    And calculated leave = 3.37 days
    Khi apply rounding
    Thì result = 3.5 days (nearest quarter)

  Scenario: No rounding
    Given rounding_mode = "none"
    And calculated leave = 3.333 days
    Khi apply rounding
    Thì result = 3.333 days (unchanged)
```

---

## 9. Release Planning

- **Alpha:** Basic rounding modes (up/down/none)
- **Beta:** Nearest rounding, multiple precisions
- **GA:** Midpoint handling, per-policy config
