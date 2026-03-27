# Feature Catalog: Time & Absence

**Module:** xTalent HCM — Time & Absence
**Step:** 5 — Product Experience Design
**Date:** 2026-03-25
**Version:** 1.0

---

## Summary Statistics

| Priority | Masterdata (M) | Transaction (T) | Analytics (A) | Total |
|----------|----------------|-----------------|---------------|-------|
| P0       | 4              | 9               | 0             | 13    |
| P1       | 4              | 6               | 2             | 12    |
| P2       | 0              | 7               | 1             | 8     |
| **Total**| **8**          | **22**          | **3**         | **33**|

---

## Feature Classification Legend

- **M (Masterdata / Config):** Configuration entities that define system behavior. Low transaction volume, CRUD-centric, maintained by HR Admin or System Admin. Spec depth: LIGHT.
- **T (Transaction):** Workflows with multi-state lifecycles, approval chains, and business rules. Direct employee or manager touch. Spec depth: DEEP.
- **A (Analytics):** Reporting, dashboards, exports, and scoring. Read-only aggregations. Spec depth: MEDIUM.

---

## Bounded Context: Absence Management (ta.absence)

### P0 Features — MVP

| ID | Feature | Classification | Complexity | Primary Actor | API Endpoint(s) | Hypothesis |
|----|---------|----------------|------------|---------------|-----------------|-----------|
| ABS-M-001 | Leave Type Configuration | M | LOW | HR Admin | `GET /leave-types`, `POST /leave-types`, `PUT /leave-types/{id}` | H1, H3 |
| ABS-M-002 | Leave Policy Definition | M | MEDIUM | HR Admin | `GET /leave-policies`, `POST /leave-policies`, `PUT /leave-policies/{id}` | H1, H2, H3 |
| ABS-M-003 | Accrual Plan Setup | M | HIGH | HR Admin | `GET /accrual-plans`, `POST /accrual-plans`, `PUT /accrual-plans/{id}` | H2 |
| ABS-T-001 | Leave Request Submission | T | LOW | Employee | `POST /leaves/requests`, `GET /leaves/requests` | H1 |
| ABS-T-002 | Leave Approval / Rejection | T | LOW | Manager | `POST /leaves/requests/{id}/approve`, `POST /leaves/requests/{id}/reject` | H1 |
| ABS-T-003 | Leave Cancellation | T | MEDIUM | Employee | `POST /leaves/requests/{id}/cancel`, `POST /leaves/requests/{id}/cancel-approve` | H-P0-001 |
| ABS-T-004 | Leave Balance Inquiry | T | LOW | Employee | `GET /leaves/balances` | H1 |
| ABS-T-005 | Leave Reservation (system) | T | LOW | System | Internal — triggered on approval flow | H1 |
| ABS-T-006 | Accrual Batch Processing | T | HIGH | System | Internal batch job (`POST /accrual-batch-runs`) | H2 |

**Classification rationale:**
- ABS-M-001/002/003 are Masterdata because they configure system behavior without being transaction records; they are set up once and changed infrequently.
- ABS-T-001 through ABS-T-006 are Transactions because they involve state machines, balance changes, and audit trails.
- ABS-T-005 is a system-internal transaction (no direct UX surface) but is included for completeness of the feature catalog.

### P1 Features — V1 Release

| ID | Feature | Classification | Complexity | Primary Actor | API Endpoint(s) | Hypothesis |
|----|---------|----------------|------------|---------------|-----------------|-----------|
| ABS-M-004 | Leave Class Management | M | MEDIUM | HR Admin | `GET /leave-classes`, `POST /leave-classes`, `PUT /leave-classes/{id}` | H3 |
| ABS-M-005 | Carry-Over Rules Configuration | M | MEDIUM | HR Admin | `GET /carryover-rules`, `POST /carryover-rules`, `PUT /carryover-rules/{id}` | H2 |
| ABS-T-007 | Leave Calendar View | T | MEDIUM | Employee, Manager | `GET /leaves/calendar`, `GET /leaves/requests` | H5 |
| ABS-T-008 | Accrual Simulation | T | HIGH | HR Admin | `POST /accrual-plans/{id}/simulate` (what-if calc) | H2 |
| ABS-T-009 | Leave Reservation Status View | T | LOW | Employee | `GET /leaves/reservations` | H1 |

**Classification rationale:**
- ABS-T-007 is a Transaction type, not Analytics, because it includes interactive click-to-request and team overlay features — it is an active interaction surface, not a read-only report.
- ABS-T-008 is a Transaction (CALCULATOR sub-type) because it computes a projection but does not persist a record.

### P2 Features — Future

| ID | Feature | Classification | Complexity | Phase | Notes |
|----|---------|----------------|-----------|-------|-------|
| ABS-T-010 | Maternity / Parental Leave | T | HIGH | Phase 2 | VLC Art. 139; Social Insurance integration hooks |
| ABS-T-011 | Leave Transfer Between Employees | T | MEDIUM | Phase 2 | Rare legal edge case; low ROI for MVP |
| ABS-T-012 | Leave Encashment | T | HIGH | Phase 2 | Requires payroll rule engine integration |
| ABS-T-013 | Leave Type — Sick Leave with Evidence | T | MEDIUM | Phase 2 | VLC Art. 114 evidence upload; HR adjudication |

---

## Bounded Context: Time & Attendance (ta.attendance)

### P0 Features

| ID | Feature | Classification | Complexity | Primary Actor | API Endpoint(s) | Hypothesis |
|----|---------|----------------|------------|---------------|-----------------|-----------|
| ATT-T-001 | Punch In / Clock Out | T | LOW | Employee | `POST /attendance/punches`, `GET /attendance/punches` | H6 |
| ATT-T-002 | Overtime Calculation | T | MEDIUM | System | `GET /attendance/timesheets/{periodId}` | H3 |
| ATT-T-003 | Overtime Request + Approval | T | MEDIUM | Employee, Manager | `POST /attendance/overtime/requests`, `POST /attendance/overtime/requests/{id}/approve`, `POST /attendance/overtime/requests/{id}/reject` | H-P0-003 |
| ATT-T-004 | Timesheet Submission | T | LOW | Employee | `POST /attendance/timesheets/{periodId}/submit` | H1 |

**Classification rationale:**
- ATT-T-001 is a Transaction even though it appears simple: it involves state machine (punched-in / punched-out / conflict), offline sync, and geofence validation.
- ATT-T-002 is a system-computed Transaction: OT lines are derived from punch data, not entered by users.
- ATT-T-003 is a Transaction with multi-level approval and skip-level routing logic (H-P0-003).

### P1 Features

| ID | Feature | Classification | Complexity | Primary Actor | API Endpoint(s) | Hypothesis |
|----|---------|----------------|------------|---------------|-----------------|-----------|
| ATT-M-001 | Shift Management | M | MEDIUM | HR Admin | `GET /shifts`, `POST /shifts`, `GET /shift-assignments`, `POST /shift-assignments` | H1 |
| ATT-M-002 | Geofencing Configuration | M | MEDIUM | System Admin | Geofence config endpoints (tenant config) | H6 |
| ATT-T-005 | Biometric Authentication Flow | T | MEDIUM | Employee | Mobile-native biometric (device SDK) | H4, H6 |
| ATT-T-006 | Comp Time Tracking + Expiry | T | MEDIUM | HR Admin, Employee | `GET /comp-time-balances` | H-P0-002 |
| ATT-T-007 | Shift Swap Request | T | MEDIUM | Employee | `POST /shift-assignments/{id}/swap` | H1 |
| ATT-T-008 | Timesheet Approval | T | LOW | Manager | `POST /attendance/timesheets/{periodId}/approve`, `POST /attendance/timesheets/{periodId}/reject` | H1 |

**Classification rationale:**
- ATT-M-001 and ATT-M-002 are Masterdata: shift patterns and geofence zones are configuration data, not transactional.
- ATT-T-005 is a Transaction because biometric authentication is a step within the clock-in workflow, involving device SDK calls and result handling.

### P2 Features

| ID | Feature | Classification | Complexity | Phase | Notes |
|----|---------|----------------|-----------|-------|-------|
| ATT-T-009 | Remote Work Tracking | T | MEDIUM | Phase 2 | Location-based work type classification |
| ATT-T-010 | Punch Conflict Resolution (HR) | T | MEDIUM | Phase 2 | Manual HR resolution screen for CONFLICT punches (automated MVP; manual P2) |
| ATT-A-001 | OT Compliance Report | A | MEDIUM | Phase 2 | VLC Art. 107 cap utilization per employee |

---

## Bounded Context: Shared Services (ta.shared)

### P0 Features

| ID | Feature | Classification | Complexity | Primary Actor | API Endpoint(s) | Hypothesis |
|----|---------|----------------|------------|---------------|-----------------|-----------|
| SHD-M-001 | Holiday Calendar Configuration | M | LOW | HR Admin | `GET /holidays/{year}/{countryCode}`, `POST /holiday-calendars`, `PUT /holiday-calendars/{id}` | H3 |
| SHD-T-001 | Multi-Level Approval Workflow Config | M | MEDIUM | HR Admin | `GET /approval-chains`, `POST /approval-chains`, `PUT /approval-chains/{id}` | H1 |
| SHD-T-002 | Period Open / Lock / Close | T | MEDIUM | Payroll Officer | `POST /periods/{id}/lock`, `POST /periods/{id}/close` | H1 |
| SHD-T-003 | Payroll Integration Export | T | LOW | System | Triggered on period close event | H1 |
| SHD-T-004 | Employee Central Integration | T | LOW | System | Event-driven (upstream ACL) | H1 |
| SHD-T-005 | Escalation Processing | T | MEDIUM | System | Internal — triggered on approval timeout | H1 |

**Note on SHD-T-001:** Although it configures approval chains (Masterdata-like), it is classified M because the feature is CRUD config. The approval routing itself at runtime is SHD-T-005. The feature ID and spec treat it as a Masterdata config screen.

**Classification rationale:**
- SHD-M-001 is Masterdata: holiday entries are reference data maintained by HR Admin annually.
- SHD-T-001 is Masterdata config despite the name "Multi-Level Approval Workflow Config" — it configures the chain rules, not the execution.
- SHD-T-002 is a Transaction with a strict state machine (OPEN → LOCKED → CLOSED) and validation gates.
- SHD-T-003, SHD-T-004, SHD-T-005 are system-internal transactions with HR Admin monitoring views.

### P1 Features

| ID | Feature | Classification | Complexity | Primary Actor | Notes |
|----|---------|----------------|-----------|---------------|-------|
| SHD-T-006 | Approval Dashboard | T | MEDIUM | Manager | Central queue for all pending approvals |
| SHD-T-007 | Approval Delegation | T | MEDIUM | Manager | Delegate authority during absence |
| SHD-T-008 | Termination Balance Review | T | HIGH | HR Admin | H-P0-004 terminated employee negative balance UX |
| SHD-A-001 | Leave Balance Reports | A | MEDIUM | HR Admin | Export + filter by type, department, date range |
| SHD-A-002 | Bradford Factor Scoring | A | HIGH | HR Admin | Absence pattern analytics; VLC compliance view |

**Classification rationale:**
- SHD-T-006 and SHD-T-007 are Transactions because they involve workflow state changes (delegation with date range, active/inactive states).
- SHD-T-008 is a Transaction because it triggers financial actions (Deduct / Write Off / Escalate) per H-P0-004.
- SHD-A-001 and SHD-A-002 are Analytics: read-only aggregations with export capability.

### P2 Features

| ID | Feature | Classification | Complexity | Phase | Notes |
|----|---------|----------------|-----------|-------|-------|
| SHD-T-009 | Notification Template Management | T | LOW | Phase 2 | HR Admin editable notification templates |
| SHD-A-003 | OT Compliance Dashboard | A | HIGH | Phase 2 | Cross-module OT cap utilization + VLC Art. 107 reporting |
| SHD-T-010 | Tenant Onboarding Configuration | T | MEDIUM | Phase 2 | System Admin initial setup wizard |

---

## Traceability Matrix

| Feature ID | User Story | BRD Ref | Domain Flow | BC |
|-----------|------------|---------|------------|-----|
| ABS-M-001 | US-ABS-007 | FR-ABS-001 | — | ta.absence |
| ABS-M-002 | US-ABS-008 | FR-ABS-002 | — | ta.absence |
| ABS-M-003 | US-ABS-009 | FR-ABS-009 | — | ta.absence |
| ABS-T-001 | US-ABS-001 | FR-ABS-003 | submit-leave-request.flow.md | ta.absence |
| ABS-T-002 | US-ABS-003, US-ABS-004 | FR-ABS-003 | approve-leave-request.flow.md | ta.absence |
| ABS-T-003 | US-ABS-005, US-ABS-006 | FR-ABS-003 | cancel-leave-request.flow.md | ta.absence |
| ABS-T-004 | US-ABS-002 | FR-ABS-004 | — | ta.absence |
| ABS-T-005 | US-ABS-001 (system step) | FR-ABS-005 | submit-leave-request.flow.md | ta.absence |
| ABS-T-006 | US-ABS-010 | FR-ABS-009 | — | ta.absence |
| ABS-T-007 | US-ABS-013, US-ABS-014 | FR-ABS-006 | — | ta.absence |
| ATT-T-001 | US-ATT-001 | BRD-ATT-001 | clock-in-out.flow.md | ta.attendance |
| ATT-T-002 | US-ATT-005 (OT lines) | BRD-ATT-002 | — | ta.attendance |
| ATT-T-003 | US-ATT-002, US-ATT-003, US-ATT-004 | BRD-ATT-002 | request-overtime.flow.md | ta.attendance |
| ATT-T-004 | US-ATT-005 | BRD-ATT-003 | — | ta.attendance |
| SHD-M-001 | — | BRD-SHD-001 | — | ta.shared |
| SHD-T-001 | US-SHD-003 | BRD-SHD-003 | — | ta.shared |
| SHD-T-002 | US-SHD-001 | BRD-SHD-001 | period-close-payroll-export.flow.md | ta.shared |
| SHD-T-003 | US-SHD-002 | BRD-SHD-011 | period-close-payroll-export.flow.md | ta.shared |
| SHD-T-004 | — | BRD-SHD-010 | — | ta.shared |
| SHD-T-005 | US-SHD-004 | BRD-SHD-003 | — | ta.shared |
| SHD-T-006 | US-SHD-007 | BRD-SHD-009 | — | ta.shared |
| SHD-T-008 | US-ABS-012 | BRD-SHD-007 | — | ta.absence + ta.shared |
| SHD-A-001 | US-SHD-008 | FR-ANL-001 | — | ta.shared |
| SHD-A-002 | — | FR-ANL-003 | — | ta.shared |
