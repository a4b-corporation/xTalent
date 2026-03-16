---
id: ABS-POL-008
name: Priority-Based Resolution
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
    - LeaveClass
  rules:
    - rule_priority_resolution_must_be_deterministic
  lifecycle: []
  events: []

dependencies:
  requires:
    - ABS-POL-001: "Eligibility Rules"
    - ABS-POL-007: "Policy Library UI"
  required_by: []
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-POL-008: Priority-Based Resolution

> Giải quyết xung đột policy dựa trên priority.

---

## 1. Business Context

### Job Story
> **Khi** nhiều policies conflict nhau,
> **tôi muốn** resolution dựa trên priority,
> **để** deterministic result.

### Success Metrics
- Resolution consistency 100%
- No ambiguous outcomes

---

## 2. UI Workflow

### Priority Configuration (HR/Admin)
```json
{
  "type": "page",
  "title": "Policy Priority Configuration",
  "children": [
    {
      "type": "section",
      "padding": "lg",
      "children": [
        {
          "type": "info-box",
          "variant": "info",
          "content": "Khi employee thuộc nhiều policies, policy có priority cao nhất (số nhỏ nhất) sẽ được áp dụng."
        },
        {
          "type": "draggable-list",
          "name": "policy_priority",
          "label": "Policy Priority (drag to reorder)",
          "items": [
            {"id": "policy_1", "name": "Senior Management Leave", "priority": 1},
            {"id": "policy_2", "name": "Standard Annual Leave", "priority": 2},
            {"id": "policy_3", "name": "Probation Leave", "priority": 3}
          ],
          "help": "Kéo thả để thay đổi priority. Số nhỏ = priority cao."
        }
      ]
    }
  ]
}
```

### Conflict Resolution Preview
- Select employee
- Show applicable policies
- Show which policy wins and why

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| None | Resolution is internal logic | N/A |

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Priority order | Lower number = higher priority | Apply highest priority policy |
| Specific over general | Employee-specific > Class-based | Employee-specific wins |
| No ties | Same priority | Error: require unique priority |
| Deterministic | Same input | Same output always |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Resolution time | ≤ 10ms |
| Consistency | 100% deterministic |
| Conflict detection | Real-time warning |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Two policies same priority | Block save, require unique priority |
| E2 | No matching policy | Use default policy |
| E3 | Circular dependency | Detect and prevent |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-POL-008 - Priority-Based Resolution

  Scenario: Resolve conflicting policies
    Given employee thuộc cả "Senior Management" (priority 1)
    And "Standard Leave" (priority 2)
    Khi system resolve policy
    Thì "Senior Management" được chọn

  Scenario: Employee-specific over class-based
    Given employee có employee-specific policy
    And class-based policy cũng applicable
    Khi system resolve
    Thì employee-specific policy wins

  Scenario: Prevent duplicate priority
    Given HR try set 2 policies cùng priority = 1
    Khi HR save
    Thì system block với error "Duplicate priority not allowed"

  Scenario: Reorder priorities
    Given HR drag policy từ priority 3 lên 1
    Khi HR save
    Thì priorities được renumber tự động
```

---

## 9. Release Planning

- **Alpha:** Basic priority ordering
- **Beta:** Drag-to-reorder UI, conflict preview
- **GA:** Automatic renumbering, impact analysis

### Out of Scope (v1)
- Weighted scoring
- Conditional priority (dynamic based on context)
