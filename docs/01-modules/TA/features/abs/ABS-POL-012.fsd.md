---
id: ABS-POL-012
name: Concurrent Leave Rules
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
    - LeaveType
  rules:
    - rule_concurrent_leave_must_be_configured
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

# ABS-POL-012: Concurrent Leave Rules

> Cấu hình allowed combinations cho concurrent absences.

---

## 1. Business Context

### Job Story
> **Khi** nhân viên muốn xin nhiều loại nghỉ cùng lúc,
> **tôi muốn** cấu hình allowed combinations,
> **để** quản lý payroll và balance deduction.

### Success Metrics
- Combination clarity ≥ 4.0/5
- Payroll accuracy 100%

---

## 2. UI Workflow

### Concurrent Leave Configuration (HR/Admin)
```json
{
  "type": "page",
  "title": "Concurrent Leave Rules",
  "children": [
    {
      "type": "section",
      "padding": "lg",
      "children": [
        {
          "type": "info-box",
          "variant": "info",
          "content": "Cấu hình các loại nghỉ có thể xin đồng thời và priority rules cho payroll."
        },
        {
          "type": "matrix",
          "name": "concurrent_matrix",
          "label": "Allowed Combinations",
          "rows": ["Annual", "Sick", "Maternity", "Paternity", "Unpaid"],
          "columns": ["Annual", "Sick", "Maternity", "Paternity", "Unpaid"],
          "cells": {
            "type": "select",
            "options": [
              {"value": "allowed", "label": "Allowed"},
              {"value": "blocked", "label": "Blocked"},
              {"value": "conditional", "label": "Conditional (with approval)"}
            ]
          }
        },
        {
          "type": "form",
          "children": [
            {
              "type": "select",
              "name": "priority_rule",
              "label": "Priority for Payroll",
              "options": [
                {"value": "first_submitted", "label": "First Submitted"},
                {"value": "highest_priority", "label": "Highest Priority Type"},
                {"value": "longest_duration", "label": "Longest Duration"}
              ],
              "help": "Xác định loại nghỉ nào được deduct first khi có overlap"
            },
            {
              "type": "draggable-list",
              "name": "type_priority",
              "label": "Leave Type Priority Order",
              "items": [
                {"id": "maternity", "name": "Maternity", "priority": 1},
                {"id": "annual", "name": "Annual", "priority": 2},
                {"id": "sick", "name": "Sick", "priority": 3},
                {"id": "unpaid", "name": "Unpaid", "priority": 4}
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
| Overlap detection | Two requests overlap | Check concurrent matrix |
| Priority application | Overlapping approved | Apply priority rule for deduction |
| Balance deduction | Per priority | Deduct from highest priority type first |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Overlap detection | ≤ 200ms |
| Matrix size | Max 10 leave types |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | 3+ overlapping requests | Apply priority recursively |
| E2 | Partial overlap | Allow, prorate deduction |
| E3 | Change priority with existing requests | Grandfather existing, apply new for future |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-POL-012 - Concurrent Leave Rules

  Scenario: Configure concurrent matrix
    Given HR set Annual + Sick = "Allowed"
    And Annual + Maternity = "Blocked"
    Khi HR save
    Thì matrix được lưu

  Scenario: Allow concurrent requests
    Given Annual + Sick = "Allowed"
    Khi employee xin Annual Leave 2026-04-01 đến 2026-04-05
    Và xin Sick Leave 2026-04-03 đến 2026-04-07 (overlap 3 days)
    Thì cả hai đều được allow
    Và overlap days được handle per priority rule

  Scenario: Block concurrent requests
    Given Annual + Maternity = "Blocked"
    Khi employee xin Annual Leave overlapping với Maternity
    Thì system block với error "Cannot take Annual Leave during Maternity Leave"

  Scenario: Priority-based deduction
    Given priority: Maternity > Annual > Sick
    And employee có overlapping Maternity và Annual
    Khi calculate balance
    Thì Maternity days được deduct first
```

---

## 9. Release Planning

- **Alpha:** Basic concurrent matrix, block/allow
- **Beta:** Conditional mode, priority rules
- **GA:** Payroll integration, proration

### Out of Scope (v1)
- Auto-convert overlapping requests
- Manager override for blocked combinations
