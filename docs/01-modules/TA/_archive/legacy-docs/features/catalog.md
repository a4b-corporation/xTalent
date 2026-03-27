# Feature Catalog: Time & Absence Module

> Catalog tổng quan toàn bộ features của module Time & Absence — tuân thủ chuẩn OFDS v1

## Document Information

| Field | Value |
|-------|-------|
| **Module** | Time & Absence (TA) |
| **Version** | 1.0 |
| **Tổng số features** | 110 |
| **Số sub-modules** | 2 |
| **Số categories** | 17 |
| **Ngày cập nhật** | 2026-03-13 |
| **Status** | Active |

---

## Tổng quan kiến trúc feature

```
Time & Absence (TA)
├── Absence Management (ABS) — 50 features
│   ├── Leave Request Management (ABS-LR) — 10 features
│   ├── Leave Approval (ABS-APR) — 10 features
│   ├── Leave Balance Management (ABS-BAL) — 8 features
│   ├── Leave Accrual (ABS-ACC) — 8 features
│   ├── Leave Carryover (ABS-CARRY) — 6 features
│   └── Leave Policy Rules (ABS-POL) — 8 features
├── Time & Attendance (ATT) — 60 features
│   ├── Shift Scheduling (ATT-SHIFT) — 12 features
│   ├── Time Tracking (ATT-TT) — 10 features
│   ├── Attendance Exceptions (ATT-EXC) — 8 features
│   ├── Timesheet Management (ATT-TS) — 10 features
│   ├── Overtime Management (ATT-OT) — 10 features
│   └── Schedule Overrides (ATT-OVR) — 10 features
└── Shared Components
    ├── Period Profiles (SH-PER) — 4 features
    ├── Holiday Calendar (SH-HOL) — 4 features
    └── Approval Workflows (SH-WF) — 6 features
```

---

## Feature Distribution

### Absence Management (ABS) — 50 features

| Sub-module | Category | Count | P0 | P1 | P2 |
|-----------|---------|-------|----|----|-----|
| ABS | Leave Request Management | 10 | 8 | 2 | 0 |
| ABS | Leave Approval | 10 | 6 | 3 | 1 |
| ABS | Leave Balance Management | 8 | 5 | 2 | 1 |
| ABS | Leave Accrual | 8 | 4 | 3 | 1 |
| ABS | Leave Carryover | 6 | 3 | 2 | 1 |
| ABS | Leave Policy Rules | 8 | 4 | 3 | 1 |
| **ABS TOTAL** | — | **50** | **30** | **15** | **5** |

### Time & Attendance (ATT) — 60 features

| Sub-module | Category | Count | P0 | P1 | P2 |
|-----------|---------|-------|----|----|-----|
| ATT | Shift Scheduling | 12 | 7 | 3 | 2 |
| ATT | Time Tracking | 10 | 6 | 3 | 1 |
| ATT | Attendance Exceptions | 8 | 4 | 3 | 1 |
| ATT | Timesheet Management | 10 | 5 | 3 | 2 |
| ATT | Overtime Management | 10 | 5 | 3 | 2 |
| ATT | Schedule Overrides | 10 | 4 | 4 | 2 |
| **ATT TOTAL** | — | **60** | **31** | **19** | **10** |

### Shared Components — 14 features

| Sub-module | Category | Count | P0 | P1 | P2 |
|-----------|---------|-------|----|----|-----|
| SH | Period Profiles | 4 | 2 | 1 | 1 |
| SH | Holiday Calendar | 4 | 2 | 1 | 1 |
| SH | Approval Workflows | 6 | 3 | 2 | 1 |
| **SH TOTAL** | — | **14** | **7** | **4** | **3** |

---

## Total Priority Summary

| Priority | Count | Percentage |
|----------|-------|------------|
| **P0 (Critical)** | 68 | 62% |
| **P1 (High)** | 38 | 34% |
| **P2 (Medium)** | 4 | 4% |
| **TOTAL** | **110** | **100%** |

---

## Gap Analysis Summary

| Gap Type | Count | Strategy |
|----------|-------|----------|
| Standard Fit | 85 | Configure only |
| Config Gap | 15 | Customize config |
| Extension Gap | 8 | Build extension |
| **Core Gap** | **2** | **ARB approval required** |

### Core Gap Details

| Feature ID | Feature Name | Reason | Impact |
|-----------|-------------|--------|--------|
| ATT-SHIFT-007 | AI-Powered Shift Optimization | Requires ML integration | Competitive differentiation |
| ABS-ACC-008 | Predictive Accrual Forecasting | Requires analytics engine | Workforce planning |

---

## Ontology Concepts Mapping

| Feature Category | Primary Concepts | Rules |
|-----------------|-----------------|-------|
| Leave Request Management | LeaveRequest, LeaveType, LeaveInstant | rule_request_must_have_employee, rule_request_cannot_overlap_approved |
| Leave Approval | LeaveRequest, LeaveReservation | rule_reservation_auto_release_on_reject |
| Leave Balance Management | LeaveInstant, LeaveInstantDetail, LeaveMovement | rule_instant_available_qty_formula |
| Leave Accrual | LeavePolicy, LeaveEventRun, LeaveMovement | rule_accrual_requires_freq_and_amount |
| Leave Carryover | LeavePeriod, LeaveMovement | rule_carry_requires_max_or_expire |
| Leave Policy Rules | LeavePolicy, LeaveClass | rule_policy_must_have_type |
| Shift Scheduling | Shift, ShiftPattern, Schedule | — |
| Time Tracking | AttendanceRecord, TimesheetEntry | — |
| Holiday Calendar | HolidayCalendar, HolidayDate | rule_date_unique_within_calendar |

---

## Feature Index toàn module

### Absence Management (ABS)

| ID | Feature Name | Category | Priority | Status | Gap Type |
|----|-------------|---------|---------|--------|---------|
| ABS-LR-001 | Create Leave Request | Leave Request | P0 | Specified | Standard Fit |
| ABS-LR-002 | Submit Leave Request for Approval | Leave Request | P0 | Specified | Standard Fit |
| ABS-LR-003 | View Leave Request Status | Leave Request | P0 | Specified | Standard Fit |
| ABS-LR-004 | Withdraw Leave Request | Leave Request | P0 | Specified | Standard Fit |
| ABS-LR-005 | Half-Day Leave Request | Leave Request | P0 | Specified | Standard Fit |
| ABS-LR-006 | Hourly Leave Request | Leave Request | P0 | Specified | Standard Fit |
| ABS-LR-007 | Leave Request with Attachments | Leave Request | P0 | Specified | Standard Fit |
| ABS-LR-008 | Leave Request Comments | Leave Request | P0 | Specified | Standard Fit |
| ABS-LR-009 | Cancel Approved Request | Leave Request | P1 | Identified | Standard Fit |
| ABS-LR-010 | Modify Pending Request | Leave Request | P1 | Identified | Standard Fit |
| ABS-APR-001 | Approve Leave Request | Leave Approval | P0 | Specified | Standard Fit |
| ABS-APR-002 | Reject Leave Request | Leave Approval | P0 | Specified | Standard Fit |
| ABS-APR-003 | Multi-Level Approval | Leave Approval | P0 | Specified | Standard Fit |
| ABS-APR-004 | Delegate Approval | Leave Approval | P0 | Specified | Config Gap |
| ABS-APR-005 | Batch Approval | Leave Approval | P0 | Specified | Standard Fit |
| ABS-APR-006 | Approval Escalation | Leave Approval | P1 | Identified | Config Gap |
| ABS-APR-007 | Approval Comments | Leave Approval | P0 | Specified | Standard Fit |
| ABS-APR-008 | View Approval History | Leave Approval | P0 | Specified | Standard Fit |
| ABS-APR-009 | Conditional Approval Routing | Leave Approval | P1 | Identified | Config Gap |
| ABS-APR-010 | Parallel Approval | Leave Approval | P1 | Identified | Extension Gap |
| ABS-BAL-001 | View Leave Balance | Balance Mgmt | P0 | Specified | Standard Fit |
| ABS-BAL-002 | Leave Balance History | Balance Mgmt | P0 | Specified | Standard Fit |
| ABS-BAL-003 | Leave Balance Projection | Balance Mgmt | P1 | Identified | Standard Fit |
| ABS-BAL-004 | Export Balance Report | Balance Mgmt | P1 | Identified | Standard Fit |
| ABS-BAL-005 | Real-time Balance Update | Balance Mgmt | P0 | Specified | Standard Fit |
| ABS-BAL-006 | Multi-Class Balance View | Balance Mgmt | P0 | Specified | Standard Fit |
| ABS-BAL-007 | Balance Adjustment | Balance Mgmt | P1 | Identified | Config Gap |
| ABS-BAL-008 | Balance Audit Log | Balance Mgmt | P2 | Identified | Standard Fit |
| ABS-ACC-001 | Monthly Accrual Run | Accrual | P0 | Specified | Standard Fit |
| ABS-ACC-002 | Accrual Policy Configuration | Accrual | P0 | Specified | Config Gap |
| ABS-ACC-003 | Manual Grant Leave | Accrual | P0 | Specified | Standard Fit |
| ABS-ACC-004 | Accrual History View | Accrual | P0 | Specified | Standard Fit |
| ABS-ACC-005 | Accrual Recalculation | Accrual | P1 | Identified | Config Gap |
| ABS-ACC-006 | Accrual Notification | Accrual | P1 | Identified | Standard Fit |
| ABS-ACC-007 | Accrual Adjustment | Accrual | P1 | Identified | Config Gap |
| ABS-ACC-008 | Predictive Accrual Forecasting | Accrual | P2 | Identified | Core Gap |
| ABS-CARRY-001 | Period End Carryover | Carryover | P0 | Specified | Standard Fit |
| ABS-CARRY-002 | Carryover Rule Configuration | Carryover | P0 | Specified | Config Gap |
| ABS-CARRY-003 | Expired Leave Handling | Carryover | P0 | Specified | Standard Fit |
| ABS-CARRY-004 | Carryover History | Carryover | P1 | Identified | Standard Fit |
| ABS-CARRY-005 | Manual Carryover | Carryover | P1 | Identified | Config Gap |
| ABS-CARRY-006 | Carryover Notification | Carryover | P2 | Identified | Standard Fit |
| ABS-POL-001 | Leave Policy Definition | Policy | P0 | Specified | Config Gap |
| ABS-POL-002 | Leave Type Configuration | Policy | P0 | Specified | Config Gap |
| ABS-POL-003 | Leave Class Configuration | Policy | P0 | Specified | Config Gap |
| ABS-POL-004 | Eligibility Rules | Policy | P0 | Specified | Config Gap |
| ABS-POL-005 | Accrual Rules | Policy | P0 | Specified | Config Gap |
| ABS-POL-006 | Carryover Rules | Policy | P1 | Identified | Config Gap |
| ABS-POL-007 | Overdraft Rules | Policy | P1 | Identified | Config Gap |
| ABS-POL-008 | Proration Rules | Policy | P2 | Identified | Config Gap |

### Time & Attendance (ATT) — Summary

| ID Range | Category | Count | Status |
|----------|---------|-------|--------|
| ATT-SHIFT-001 to 012 | Shift Scheduling | 12 | Draft |
| ATT-TT-001 to 010 | Time Tracking | 10 | Draft |
| ATT-EXC-001 to 008 | Attendance Exceptions | 8 | Draft |
| ATT-TS-001 to 010 | Timesheet Management | 10 | Draft |
| ATT-OT-001 to 010 | Overtime Management | 10 | Draft |
| ATT-OVR-001 to 010 | Schedule Overrides | 10 | Draft |

### Shared Components — Summary

| ID Range | Category | Count | Status |
|----------|---------|-------|--------|
| SH-PER-001 to 004 | Period Profiles | 4 | Draft |
| SH-HOL-001 to 004 | Holiday Calendar | 4 | Draft |
| SH-WF-001 to 006 | Approval Workflows | 6 | Draft |

---

## Cross-references

- **Ontology Layer:** [`../ontology/`](../ontology/)
  - Concepts: [`../ontology/concepts/`](../ontology/concepts/)
  - Lifecycle: [`../ontology/lifecycle.yaml`](../ontology/lifecycle.yaml)
  - Rules: [`../ontology/rules.yaml`](../ontology/rules.yaml)
- **System Layer:** [`../system/`](../system/)
  - Events: [`../system/events.yaml`](../system/events.yaml)
  - API: [`../system/canonical_api.openapi.yaml`](../system/canonical_api.openapi.yaml)
- **Sub-module Indexes:**
  - [Absence Management Index](./abs/index.md)
  - [Time & Attendance Index](./att/index.md) (TODO)
  - [Shared Components Index](./shared/index.md) (TODO)

---

## Status Legend

| Status | Description |
|--------|-------------|
| **Specified** | Đủ 9 thành phần OFDS, sẵn sàng review |
| **Identified** | Đã liệt kê, chưa có spec chi tiết |
| **Reviewed** | Đã qua Domain + Architecture Review |
| **Ready** | Sẵn sàng để dev implement |
| **In Dev** | Đang phát triển |
| **Done** | Đã xong, merge vào main |

---

## Release Roadmap

### Phase 1 (Q2 2026) — Absence Management Core
- All P0 features (30 features)
- Focus: Leave Request, Approval, Balance Management

### Phase 2 (Q3 2026) — Time & Attendance Core
- All P0 features (31 features)
- Focus: Shift Scheduling, Time Tracking

### Phase 3 (Q4 2026) — Advanced Features
- All P1 features (38 features)
- Focus: Escalation, Forecasting, Extensions

### Phase 4 (Q1 2027) — Complete
- All P2 features (4 features)
- Core Gap resolution (2 features)
