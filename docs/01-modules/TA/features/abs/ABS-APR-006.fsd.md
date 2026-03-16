---
id: ABS-APR-006
name: Approval Escalation
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
    - "Notification Service"
    - "Scheduler Service"

created: 2026-03-13
author: BA Team
---

# ABS-APR-006: Approval Escalation

> Tự động leo thang đơn nghỉ khi quá hạn phê duyệt theo SLA.

---

## 1. Business Context

### Job Story
> **Khi** manager không phê duyệt đơn trong SLA,
> **tôi muốn** tự động escalate lên cấp trên,
> **để** đơn không bị tồn đọng.

### Success Metrics
- Escalation trigger accuracy 100%
- SLA breach reduction ≥ 80%

---

## 2. UI Workflow

### Escalation Config Screen (Admin)
- SLA timeout: 24h/48h/72h
- Escalation path: Next level manager
- Notification templates

### Escalation Status Display
- Hiển thị "Escalated to {next_approver}" trong timeline
- Countdown timer cho SLA

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveRequestApproved` | Escalated approver approves | escalated: true |

---

## 4. Business Rules

### Feature-specific Rules
| Rule | Condition | Action |
|------|-----------|--------|
| SLA timer | Start khi submit | Count hours (exclude weekends/holidays) |
| Auto-escalate | SLA expired | Route đến next level |
| Notification | Before escalate (optional) | Reminder cho current approver |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| SLA monitoring | Continuous (polling mỗi giờ) |
| Escalation time | ≤ 5 minutes sau SLA expiry |

---

## 7. Edge Cases

| # | Case | Handling |
|---|------|----------|
| E1 | Approver vừa approve trước khi escalate | Cancel escalation, mark as approved |
| E2 | Next approver không có trong hệ thống | Escalate đến admin |
| E3 | Weekend/holiday trong SLA period | Exclude khỏi tính toán |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-APR-006 - Approval Escalation

  Scenario: Auto-escalate sau SLA expiry
    Given SLA = 48 hours
    And request submitted at 2026-04-01 09:00
    And current_time = 2026-04-03 09:01 (48h passed)
    And request vẫn ở status SUBMITTED
    Khi escalation job chạy
    Thì request được route đến next approver
    Và current approver nhận notification về escalation

  Scenario: Cancel escalation khi approved
    Given request pending escalation
    Khi current approver approve trước khi escalate
    Thì escalation được cancel
```

---

## 9. Release Planning

- **Alpha:** Manual escalation trigger
- **Beta:** Auto-escalation với SLA config
- **GA:** Reminder notifications, full integration

### Out of Scope (v1)
- Custom escalation paths
- Parallel escalation
