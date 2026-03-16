---
id: ABS-BAL-008
name: Balance Audit Log
module: TA
sub_module: ABS
category: Leave Balance Management
priority: P2
status: Specified
differentiation: Parity
gap_type: Standard Fit
phase: 1

ontology_refs:
  concepts:
    - LeaveMovement
    - LeaveInstant
  rules: []
  lifecycle: []
  events: []

dependencies:
  requires:
    - ABS-BAL-002: "Leave Balance History"
  required_by: []
  external:
    - "Audit Log Service"

created: 2026-03-13
author: BA Team
---

# ABS-BAL-008: Balance Audit Log

> Hiển thị audit log chi tiết cho tất cả balance changes.

---

## 1. Business Context

### Job Story
> **Khi** tôi cần tra cứu ai đã thay đổi balance,
> **tôi muốn** xem audit log,
> **để** điều tra discrepancies.

---

## 2. UI Workflow

### Audit Log Screen (HR/Admin)
- Filter: Date range, employee, change type
- Mỗi entry: Timestamp, User, Action, Before/After, IP address
- Export option

---

## 5. NFRs

| NFR | Target |
|-----|--------|
| Query time | ≤ 1s |
| Retention | 7 years |

---

## 8. Acceptance Criteria

```gherkin
Scenario: View balance audit log
  Given có 3 adjustments trong tháng
  Khi HR xem audit log
  Thì hiển thị đầy đủ 3 entries với user, timestamp, before/after
```

---

## 9. Release Planning

- **Alpha:** Basic audit display
- **Beta:** Filters, search
- **GA:** Export, full retention
