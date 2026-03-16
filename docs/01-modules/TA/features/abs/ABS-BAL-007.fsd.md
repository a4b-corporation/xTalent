---
id: ABS-BAL-007
name: Balance Adjustment
module: TA
sub_module: ABS
category: Leave Balance Management
priority: P1
status: Specified
differentiation: Parity
gap_type: Config Gap
phase: 1

ontology_refs:
  concepts:
    - LeaveInstant
    - LeaveMovement
  rules:
    - rule_movement_must_have_event_code
  lifecycle: LeaveMovementLifecycle
  events:
    - LeaveBalanceAdjusted

dependencies:
  requires:
    - ABS-BAL-001: "View Leave Balance"
    - ABS-ACC-003: "Manual Grant Leave"
  required_by: []
  external:
    - "Audit Log Service"

created: 2026-03-13
author: BA Team
---

# ABS-BAL-007: Balance Adjustment

> Cho phép HR điều chỉnh số dư nghỉ phép (cộng/trừ) với lý do và audit trail.

---

## 1. Business Context

### Job Story
> **Khi** cần sửa số dư do sai sót hoặc special case,
> **tôi muốn** điều chỉnh balance,
> **để** employee có số dư chính xác.

### Success Metrics
- Adjustment accuracy 100%
- Audit trail completeness 100%

---

## 2. UI Workflow

### Adjustment Screen (HR only)
- Select employee, leave type
- Adjustment type: Add/Deduct
- Enter qty, reason (required)
- Effective date
- Submit → Create adjustment movement

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveBalanceAdjusted` | Adjustment successful | instant_id, adjustment_qty, adjustment_reason, adjusted_by |

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Reason required | Adjustment | Min 20 chars |
| Negative balance check | Deduct adjustment | Warning nếu balance < 0 |
| Audit trail | All adjustments | Log user, timestamp, IP |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Adjustment processing | ≤ 1s |
| Audit retention | 7 years |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Adjustment làm balance âm | Warning require confirmation |
| E2 | Duplicate adjustment | Idempotency key |
| E3 | Adjustment cho employee đã nghỉ việc | Block với error |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-BAL-007 - Balance Adjustment

  Scenario: HR add balance
    Given HR chọn employee và leave type
    Khi chọn Add, nhập 5 days, reason "System error correction"
    Và submit
    Thì balance tăng 5 days
    Và LeaveBalanceAdjusted event emitted

  Scenario: Deduct balance với audit
    Given HR deduct 3 days
    Thì audit log được tạo với: user, timestamp, IP, reason
```

---

## 9. Release Planning

- **Alpha:** Manual adjustment cơ bản
- **Beta:** Approval workflow cho adjustments
- **GA:** Full audit integration

### Out of Scope (v1)
- Bulk adjustments
- Scheduled adjustments
