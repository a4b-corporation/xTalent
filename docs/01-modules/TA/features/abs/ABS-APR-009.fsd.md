---
id: ABS-APR-009
name: Conditional Approval Routing
module: TA
sub_module: ABS
category: Leave Approval
priority: P1
status: Specified
differentiation: Parity
gap_type: Config Gap
phase: 1

ontology_refs:
  concepts:
    - LeaveRequest
  rules: []
  lifecycle: LeaveRequestLifecycle
  events:
    - LeaveRequestApproved
    - LeaveRequestRejected

dependencies:
  requires:
    - ABS-APR-003: "Multi-Level Approval"
  required_by: []
  external:
    - "Org Hierarchy Service"

created: 2026-03-13
author: BA Team
---

# ABS-APR-009: Conditional Approval Routing

> Tự động route đơn nghỉ đến approver dựa trên điều kiện (duration, type, timing).

---

## 1. Business Context

### Job Story
> **Khi** đơn nghỉ có đặc điểm đặc biệt (nghỉ dài, nghỉ lễ),
> **tôi muốn** tự động route đến đúng người duyệt,
> **để** đảm bảo compliance với policy.

---

## 2. UI Workflow

### Routing Rules Config (Admin)
- Condition builder: duration, type, timing
- Target approver mapping
- Priority order

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveRequestApproved` | Any approver approves | routed_by: rule_id |

---

## 4. Business Rules

### Feature-specific Rules
| Rule | Condition | Action |
|------|-----------|--------|
| Long leave routing | duration > 5 days | Route đến senior manager |
| Holiday period routing | Overlap với public holiday | Route đến HR |
| Probation employee | Employee đang probation | Route đến HR + manager |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Routing decision time | ≤ 100ms |
| Rule evaluation | Real-time |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Multiple rules match | Use highest priority rule |
| E2 | No rule matches | Use default routing (direct manager) |
| E3 | Rule target approver không có | Fallback đến admin |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-APR-009 - Conditional Approval Routing

  Scenario: Route đơn dài ngày đến senior manager
    Given rule: duration > 5 days → senior manager
    Khi employee submit 7 days request
    Thì request được route đến senior manager (không phải direct manager)

  Scenario: Default routing khi không match rule
    Given không có rule nào match
    Khi employee submit normal request
    Thì request được route đến direct manager (default)
```

---

## 9. Release Planning

- **Alpha:** Hard-coded rules
- **Beta:** Configurable rule builder
- **GA:** Full integration với org hierarchy

### Out of Scope (v1)
- Dynamic rule creation bằng UI
- A/B testing routing rules
