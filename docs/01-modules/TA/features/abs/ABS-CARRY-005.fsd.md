---
id: ABS-CARRY-005
name: Year-End Processing
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
    - LeaveInstant
  rules:
    - rule_period_must_be_closed_before_rollover
  lifecycle: LeavePeriodLifecycle
  events:
    - LeavePeriodClosed
    - LeaveCarriedOver
    - LeaveExpired

dependencies:
  requires:
    - ABS-CARRY-001: "Limited Carryover"
    - ABS-CARRY-002: "Unlimited Carryover"
    - ABS-CARRY-003: "Carryover Expiry"
  required_by: []
  external:
    - "Batch Job Service"

created: 2026-03-13
author: BA Team
---

# ABS-CARRY-005: Year-End Processing

> Tự động xử lý carryover và expiry vào cuối năm.

---

## 1. Business Context

### Job Story
> **Khi** kết thúc leave year,
> **tôi muốn** tự động process carryover và expiry,
> **để** chuyển số dư sang năm mới.

### Success Metrics
- Year-end processing success rate ≥ 99%
- Processing time ≤ 1 hour for 10000 employees

---

## 2. UI Workflow

### Year-End Configuration (HR/Admin)
```json
{
  "type": "page",
  "title": "Year-End Processing Configuration",
  "children": [
    {
      "type": "section",
      "padding": "lg",
      "children": [
        {
          "type": "form",
          "children": [
            {
              "type": "date-picker",
              "name": "processing_date",
              "label": "Processing Date",
              "default": "Last day of leave year"
            },
            {
              "type": "time-picker",
              "name": "processing_time",
              "label": "Processing Time",
              "default": "23:00"
            },
            {
              "type": "checkbox",
              "name": "auto_close_period",
              "label": "Auto-close period after processing"
            },
            {
              "type": "checkbox",
              "name": "send_notifications",
              "label": "Send completion notifications"
            }
          ]
        }
      ]
    }
  ]
}
```

### Year-End Execution Screen
- Schedule job button
- Run now button
- Progress indicator
- Results summary

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeavePeriodClosed` | Period closed | period_id, leave_year |
| `LeaveCarriedOver` | Carryover executed | instant_id, leave_type_id, carried_days, new_period_id |
| `LeaveExpired` | Expiry executed | instant_id, leave_type_id, expired_days, period_id |

---

## 4. Business Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Period closure | Before carryover | Close source period |
| Carryover order | After period close | Execute carryover |
| Expiry order | After carryover | Execute expiry |
| Audit trail | All operations | Log batch_id, user, timestamp |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Processing time | ≤ 1 hour for 10000 employees |
| Idempotency | Prevent duplicate processing |
| Rollback | Support rollback on error |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Processing failure mid-batch | Rollback, retry from checkpoint |
| E2 | Employee added during processing | Include in next run, alert admin |
| E3 | Duplicate schedule | Detect and prevent |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-CARRY-005 - Year-End Processing

  Scenario: Schedule year-end processing
    Given HR cấu hình processing date = 2025-12-31 23:00
    Khi HR click "Schedule"
    Thì batch job được lên lịch
    Và confirmation hiển thị

  Scenario: Execute year-end processing
    Given batch job chạy
    Khi processing hoàn tất
    Thì LeavePeriodClosed event emitted
    Và LeaveCarriedOver events emitted cho tất cả employees
    Và LeaveExpired events emitted cho expired days
    Và period chuyển sang LOCKED

  Scenario: Rollback on error
    Given error xảy ra trong processing
    Khi rollback triggered
    Thì tất cả changes được hoàn tác
    Và error log được tạo
```

---

## 9. Release Planning

- **Alpha:** Manual year-end execution
- **Beta:** Scheduled processing, basic rollback
- **GA:** Full automation, checkpoint recovery, notifications
