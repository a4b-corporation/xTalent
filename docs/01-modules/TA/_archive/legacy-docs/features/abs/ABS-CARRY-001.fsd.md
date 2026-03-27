---
id: ABS-CARRY-001
name: Period End Carryover
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
    - LeavePeriod
    - LeaveMovement
  rules:
    - rule_carry_requires_max_or_expire
    - rule_period_cannot_close_with_pending_requests
  lifecycle: LeavePeriodLifecycle
  events:
    - CarryForwardExecuted
    - PeriodClosed

dependencies:
  requires:
    - ABS-POL-006: "Carryover Rules"
  required_by:
    - ABS-BAL-002: "Balance History"
  external:
    - "Scheduler Service"

created: 2026-03-13
author: BA Team
---

# ABS-CARRY-001: Period End Carryover

> Tự động chuyển số dư nghỉ phép cuối kỳ sang kỳ mới theo chính sách carryover.

---

## 1. Business Context

### Job Story
> **Khi** kết thúc kỳ leave year,
> **tôi muốn** tự động carryover số dư chưa dùng,
> **để** employee không mất ngày phép.

### Success Metrics
- Carryover accuracy 100%
- Processing time ≤ 5 minutes for 1000 employees

---

## 2. UI Workflow

### Admin Screen
- Trigger manual carryover run
- View carryover history
- Monitor progress

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `CarryForwardExecuted` | Carryover successful | instant_id, carried_qty, new_lot_id |
| `PeriodClosed` | Period đóng | period_id, closed_at |

---

## 4. Business Rules

| Rule ID | Description |
|---------|-------------|
| [`rule_carry_requires_max_or_expire`](../ontology/rules.yaml#L175) | Carry rule phải có maxCarry hoặc expireMonths |
| [`rule_period_cannot_close_with_pending_requests`](../ontology/rules.yaml#L685) | Không đóng period nếu có pending requests |

---

## 5. NFRs

| NFR | Target |
|-----|--------|
| Processing time | ≤ 5 min/1000 employees |
| Accuracy | 100% |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Carryover > maxCarry | Cap at maxCarry,剩余 expired |
| E2 | Employee terminated | No carryover, payout instead |

---

## 8. Acceptance Criteria

```gherkin
Scenario: Period end carryover
  Given employee có 5 days unused, maxCarry = 3 days
  Khi chạy carryover run
  Thì employee được carryover 3 days
  Và 2 days expired
  Và CarryForwardExecuted event emitted
```

---

## 9. Release Planning

- **Alpha:** Manual carryover run
- **Beta:** Scheduled runs, maxCarry enforcement
- **GA:** Full expiry handling
