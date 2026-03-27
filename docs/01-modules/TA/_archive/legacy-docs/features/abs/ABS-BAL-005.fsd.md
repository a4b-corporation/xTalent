---
id: ABS-BAL-005
name: Real-time Balance Update
module: TA
sub_module: ABS
category: Leave Balance Management
priority: P0
status: Specified
differentiation: Parity
gap_type: Standard Fit
phase: 1

ontology_refs:
  concepts:
    - LeaveInstant
    - LeaveMovement
  rules:
    - rule_instant_available_qty_formula
  lifecycle: LeaveInstantLifecycle
  events:
    - LeaveRequested
    - LeaveStarted
    - LeaveReservationReleased

dependencies:
  requires:
    - ABS-BAL-001: "View Leave Balance"
  required_by:
    - ABS-LR-001: "Create Leave Request"
  external:
    - "Event Bus"

created: 2026-03-13
author: BA Team
---

# ABS-BAL-005: Real-time Balance Update

> Cập nhật số dư nghỉ phép real-time khi có events (submit, approve, cancel).

---

## 1. Business Context

### Job Story
> **Khi** có thay đổi trong leave requests,
> **tôi muốn** số dư cập nhật ngay lập tức,
> **để** luôn thấy số dư chính xác.

---

## 2. UI Workflow

### Auto-refresh
- WebSocket hoặc polling mỗi 5s
- Hiển thị "Just updated" toast khi có thay đổi

---

## 3. System Events

| Event | Impact |
|-------|--------|
| `LeaveRequested` | Reserve balance (hold) |
| `LeaveRequestApproved` | Confirm reservation |
| `LeaveStarted` | Deduct balance (used) |
| `LeaveReservationReleased` | Release hold |

---

## 5. NFRs

| NFR | Target |
|-----|--------|
| Update latency | ≤ 1s từ event đến UI |
| Accuracy | 100% |

---

## 8. Acceptance Criteria

```gherkin
Scenario: Balance update khi submit request
  Given employee có 10 days balance
  Khi employee submit 3 days request
  Thì balance hiển thị "7 days available (3 on hold)" trong 1s
```

---

## 9. Release Planning

- **Alpha:** Polling-based update
- **Beta:** WebSocket real-time
- **GA:** Full event integration
