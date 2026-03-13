---
id: ABS-ACC-001
name: Monthly Accrual Run
module: TA
sub_module: ABS
category: Leave Accrual
priority: P0
status: Specified
differentiation: Parity
gap_type: Standard Fit
phase: 1

ontology_refs:
  concepts:
    - LeaveEventRun
    - LeaveMovement
    - LeavePolicy
  rules:
    - rule_accrual_requires_freq_and_amount
    - rule_event_run_idempotency
  lifecycle: LeaveEventRunLifecycle
  events:
    - LeaveAccrued
    - LeaveGrantCreated

dependencies:
  requires:
    - ABS-POL-005: "Accrual Rules - cấu hình accrual"
  required_by:
    - ABS-BAL-002: "Balance History - nguồn accrual movements"
  external:
    - "Scheduler Service"

created: 2026-03-13
author: BA Team
---

# ABS-ACC-001: Monthly Accrual Run

> Tự động tích lũy nghỉ phép hàng tháng dựa trên chính sách accrual.

---

## 1. Business Context

### Job Story
> **Khi** đến kỳ accrual hàng tháng,
> **tôi muốn** hệ thống tự động tính và cộng số dư,
> **để** nhân viên có leave balance chính xác.

### Success Metrics
- Accrual accuracy 100%
- Processing time ≤ 5 minutes for 1000 employees

---

## 2. UI Workflow

### Admin Screen
- Trigger manual accrual run
- View accrual history
- Monitor progress: Pending/Processing/Done/Error

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveAccrued` | Accrual run successful | instant_id, employee_id, accrued_qty, period_id |
| `LeaveGrantCreated` | Special grant | detail_id, lot_qty, eff_date |

---

## 4. Business Rules

| Rule ID | Description |
|---------|-------------|
| [`rule_accrual_requires_freq_and_amount`](../ontology/rules.yaml#L161) | Accrual phải có freq và amount |
| [`rule_event_run_idempotency`](../ontology/rules.yaml#L728) | Không chạy 2 lần cùng period |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Processing time | ≤ 5 min/1000 employees |
| Idempotency | Không duplicate accruals |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Employee join giữa kỳ | Prorate accrual |
| E2 | Accrual run fail giữa chừng | Retry từ failed point |

---

## 8. Acceptance Criteria

```gherkin
Scenario: Monthly accrual run
  Given employee có accrual policy: 1.5 days/month
  Khi chạy accrual run cho tháng 3
  Thì employee được cộng 1.5 days
  Và LeaveAccrued event emitted
```

---

## 9. Release Planning

- **Alpha:** Manual trigger, basic accrual
- **Beta:** Scheduled runs, proration
- **GA:** Full error handling, retry
