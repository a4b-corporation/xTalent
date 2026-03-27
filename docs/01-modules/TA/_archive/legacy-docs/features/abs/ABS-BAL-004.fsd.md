---
id: ABS-BAL-004
name: Export Balance Report
module: TA
sub_module: ABS
category: Leave Balance Management
priority: P1
status: Specified
differentiation: Parity
gap_type: Standard Fit
phase: 1

ontology_refs:
  concepts:
    - LeaveInstant
    - LeaveMovement
  rules: []
  lifecycle: []
  events: []

dependencies:
  requires:
    - ABS-BAL-001: "View Leave Balance"
    - ABS-BAL-002: "Leave Balance History"
  required_by: []
  external: []

created: 2026-03-13
author: BA Team
---

# ABS-BAL-004: Export Balance Report

> Cho phép export balance report ra CSV/PDF cho employee hoặc manager.

---

## 1. Business Context

### Job Story
> **Khi** tôi cần báo cáo balance cho mục đích cá nhân hoặc quản lý,
> **tôi muốn** export ra file,
> **để** lưu trữ hoặc chia sẻ.

---

## 2. UI Workflow

### Export Options
- Format: CSV hoặc PDF
- Date range selector
- Include options: Balance summary, Movement history
- Generate → Download

---

## 5. NFRs

| NFR | Target |
|-----|--------|
| Export generation | ≤ 5s |
| File size | ≤ 5MB |

---

## 8. Acceptance Criteria

```gherkin
Scenario: Export balance report CSV
  Khi employee chọn export CSV
  Và chọn date range
  Thì file CSV được download với:
    | Leave Type | Opening | Accrued | Used | Closing |
```

---

## 9. Release Planning

- **Alpha:** CSV export cơ bản
- **Beta:** PDF với formatting
- **GA:** Full customization
