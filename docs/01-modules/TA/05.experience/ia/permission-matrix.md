# Permission Matrix: Time & Absence

**Module:** xTalent HCM — Time & Absence
**Step:** 5 — Product Experience Design
**Date:** 2026-03-25
**Version:** 1.0

---

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Full access (Create, Read, Update, Delete / Execute all actions) |
| 👁 | Read only |
| ➕ | Create only (no edit after submission) |
| ✏️ | Create + Edit own records |
| ❌ | No access (feature hidden from navigation) |
| 🔧 | Configure only (system-level settings, not business data) |
| 🔒 | Read own records only |

**Scope qualifiers** in cells provide context where access is scope-limited:
- `(own)` = own records only
- `(team)` = subordinate employees' records
- `(all)` = all employees in tenant
- `(period)` = within open period only

---

## Masterdata Configuration Features

| Feature | Employee | Manager | HR Admin | Payroll Officer | System Admin |
|---------|----------|---------|----------|-----------------|--------------|
| ABS-M-001 Leave Type Config | ❌ | ❌ | ✅ | ❌ | 🔧 (activate/deactivate only) |
| ABS-M-002 Leave Policy Definition | ❌ | ❌ | ✅ | ❌ | ❌ |
| ABS-M-003 Accrual Plan Setup | ❌ | ❌ | ✅ | ❌ | ❌ |
| ABS-M-004 Leave Class Management (P1) | ❌ | ❌ | ✅ | ❌ | ❌ |
| ABS-M-005 Carry-Over Rules Config (P1) | ❌ | ❌ | ✅ | ❌ | ❌ |
| ATT-M-001 Shift Management (P1) | 🔒 (view own assignment) | 👁 (view team) | ✅ | ❌ | ❌ |
| ATT-M-002 Geofencing Config (P1) | ❌ | ❌ | ❌ | ❌ | ✅ |
| SHD-M-001 Holiday Calendar Config | ❌ | 👁 | ✅ | 👁 | 🔧 (import templates) |
| SHD-T-001 Approval Workflow Config | ❌ | ❌ | ✅ | ❌ | 🔧 (system chain templates) |

---

## Transaction Features — Absence Management

| Feature | Employee | Manager | HR Admin | Payroll Officer | System Admin |
|---------|----------|---------|----------|-----------------|--------------|
| ABS-T-001 Leave Request Submission | ✏️ (own) | ✏️ (own as employee) | ✅ (own + proxy submit for employees) | ❌ | ❌ |
| ABS-T-002 Leave Approval / Rejection | ❌ | ✅ (team) | ✅ (all, override) | ❌ | ❌ |
| ABS-T-003 Leave Cancellation — pre-deadline | ✏️ (own approved) | ✏️ (own approved) | ✅ | ❌ | ❌ |
| ABS-T-003 Leave Cancellation — post-deadline | ➕ (request only, own) | ✅ (approve/reject team's cancellation requests) | ✅ | ❌ | ❌ |
| ABS-T-004 Leave Balance Inquiry | 🔒 (own) | 👁 (own + team) | ✅ (all) | 👁 (all, period end) | ❌ |
| ABS-T-005 Leave Reservation (system) | 👁 (own — visible as 'Reserved' in balance) | 👁 (team) | 👁 (all) | ❌ | ❌ |
| ABS-T-006 Accrual Batch Processing | ❌ | ❌ | ✅ (trigger + monitor) | ❌ | ❌ |
| ABS-T-007 Leave Calendar View (P1) | 🔒 (own leaves + public holidays) | ✅ (own + team overlay, configurable) | ✅ (all) | ❌ | ❌ |
| ABS-T-008 Accrual Simulation (P1) | ❌ | ❌ | ✅ | ❌ | ❌ |
| ABS-T-009 Leave Reservation Status (P1) | 🔒 (own) | 👁 (team) | ✅ | ❌ | ❌ |

---

## Transaction Features — Attendance

| Feature | Employee | Manager | HR Admin | Payroll Officer | System Admin |
|---------|----------|---------|----------|-----------------|--------------|
| ATT-T-001 Punch In / Clock Out | ✏️ (own — mobile primary) | ✏️ (own as employee) | ✅ (own + view all + manual correction) | ❌ | ❌ |
| ATT-T-002 Overtime Calculation (view) | 🔒 (own timesheet OT lines) | 👁 (own + team) | ✅ (all) | 👁 (all) | ❌ |
| ATT-T-003 OT Request Submission | ✏️ (own) | ✏️ (own — H-P0-003 routes to skip-level) | ✅ (own + override) | ❌ | ❌ |
| ATT-T-003 OT Approval | ❌ | ✅ (team + skip-level requests) | ✅ (override approval) | ❌ | ❌ |
| ATT-T-004 Timesheet Submission | ✏️ (own, current period) | ✏️ (own) | ✅ (proxy + correction auth) | 👁 | ❌ |
| ATT-T-005 Biometric Auth Flow (P1) | ✅ (own device) | ✅ (own device) | ❌ (config in ATT-M-002) | ❌ | 🔧 |
| ATT-T-006 Comp Time Balance (P1) | 🔒 (own) | 👁 (own + team) | ✅ (all + trigger expiry actions) | 👁 | ❌ |
| ATT-T-007 Shift Swap Request (P1) | ✏️ (own — initiate swap) | ✅ (approve/reject team swaps) | ✅ | ❌ | ❌ |
| ATT-T-008 Timesheet Approval (P1) | ❌ | ✅ (team) | ✅ (override) | 👁 | ❌ |

---

## Transaction Features — Shared Services

| Feature | Employee | Manager | HR Admin | Payroll Officer | System Admin |
|---------|----------|---------|----------|-----------------|--------------|
| SHD-T-002 Period Open / Lock / Close | ❌ | ❌ | 👁 (monitor) | ✅ (execute) | ❌ |
| SHD-T-003 Payroll Export | ❌ | ❌ | 👁 (view export status) | ✅ (download + re-trigger) | ❌ |
| SHD-T-004 Employee Central Integration | ❌ | ❌ | 👁 (view sync events) | ❌ | 🔧 (configure connection) |
| SHD-T-005 Escalation Processing | 👁 (receive escalation notification if affected) | ✅ (receive + act on escalated requests) | ✅ (view + resolve all) | ❌ | ❌ |
| SHD-T-006 Approval Dashboard (P1) | ❌ | ✅ (own approval queue) | ✅ (all queues, monitoring) | ❌ | ❌ |
| SHD-T-007 Approval Delegation (P1) | ❌ | ✏️ (own — set delegate) | ✅ (set + override for any manager) | ❌ | ❌ |
| SHD-T-008 Termination Balance Review (P1) | ❌ | ❌ | ✅ (action required) | 👁 (view status) | ❌ |

---

## Analytics Features

| Feature | Employee | Manager | HR Admin | Payroll Officer | System Admin |
|---------|----------|---------|----------|-----------------|--------------|
| SHD-A-001 Leave Balance Reports (P1) | ❌ | 👁 (team report) | ✅ (all, export) | 👁 (all, export — period-end) | ❌ |
| SHD-A-002 Bradford Factor Scoring (P1) | ❌ | 👁 (own team) | ✅ (all, export) | ❌ | ❌ |
| ATT-A-001 OT Compliance Report (P2) | ❌ | 👁 (team) | ✅ (all, export) | 👁 (all) | ❌ |

---

## Notification Receipts by Role

| Notification Event | Employee (own) | Manager (team) | HR Admin | Payroll Officer | System Admin |
|-------------------|----------------|----------------|----------|-----------------|--------------|
| Leave request submitted | ✅ confirmation | ✅ approval request | 👁 audit log | ❌ | ❌ |
| Leave approved / rejected | ✅ result | ✅ sent confirmation | 👁 | ❌ | ❌ |
| Leave cancellation (post-deadline) | ✅ request sent | ✅ approval request | 👁 | ❌ | ❌ |
| OT request submitted | ✅ confirmation | ✅ approval request | 👁 | ❌ | ❌ |
| OT cap 80% warning | ✅ | ✅ | 👁 | ❌ | ❌ |
| Comp time expiry warning (H-P0-002) | ✅ push + email | 👁 (team member's) | ✅ | ❌ | ❌ |
| Approval escalated | ❌ | ✅ if new escalation recipient | ✅ | ❌ | ❌ |
| Period locked | ❌ | ❌ | ✅ | ✅ | ❌ |
| Period closed + export ready | ❌ | ❌ | 👁 | ✅ | ❌ |
| Punch conflict detected | ✅ | 👁 | ✅ resolution required | ❌ | ❌ |

---

## Notes on Scope Constraints

1. **Employee "own" scope:** All employee-facing features apply to the authenticated employee's records only. Cross-employee lookup is not available to employees in any feature.
2. **Manager "team" scope:** Manager access is bounded by the reporting line defined in Employee Central. A manager cannot access records of employees not in their reporting structure.
3. **HR Admin "all" scope:** HR Admin has tenant-wide visibility. In a multi-tenant deployment, HR Admin is scoped to their tenant only (Row-Level Security enforces this at database level).
4. **Payroll Officer read scope:** Payroll Officers have read access to all employee records for reporting and reconciliation but cannot initiate, approve, or modify any leave or attendance transactions.
5. **System Admin config scope:** System Admin access is restricted to configuration and integration settings. System Admin cannot read individual employee leave or attendance records.
