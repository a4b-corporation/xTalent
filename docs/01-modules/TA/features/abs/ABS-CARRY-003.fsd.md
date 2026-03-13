---
id: ABS-CARRY-003
name: Expired Leave Handling
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
    - LeaveInstantDetail
    - LeaveMovement
  rules:
    - rule_detail_silent_expiry_default
  lifecycle: LeaveInstantDetailLifecycle
  events:
    - LeaveMovement

dependencies:
  requires:
    - ABS-CARRY-001: "Period End Carryover"
  required_by:
    - ABS-BAL-002: "Balance History"
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-CARRY-003: Expired Leave Handling

> Xử lý nghỉ hết hạn sau carryover và tạo movement expiry.

---

## 1. Business Context

### Job Story
> **Khi** leave lots hết hạn,
> **tôi muốn** tự động mark expired và tạo movement,
> **để** balance được chính xác.

---

## 2. UI Workflow

### Expiry Screen
- View expired lots
- Expiry notification cho employee
- Manual expiry trigger (admin)

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveMovement` | Expiry | event_code=EXPIRE, qty |

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| [`rule_detail_silent_expiry_default`](../ontology/rules.yaml#L310) | Silent expiry by default | Auto-update state_code |

---

## 5. NFRs

| NFR | Target |
|-----|--------|
| Expiry processing | Daily batch |

---

## 8. Acceptance Criteria

```gherkin
Scenario: Expired leave handling
  Given lot có expire_date = 2026-03-31
  Khi current_date = 2026-04-01
  Thì lot state_code = EXPIRED
  Và LeaveMovement EXPIRE được tạo
```

---

## 9. Release Planning

- **Alpha:** Auto-expiry
- **Beta:** Notifications
- **GA:** Full audit trail
