# C4 Level 1: System Context — Time & Absence

**Module:** xTalent HCM — Time & Absence
**Step:** 4 — Solution Architecture
**Date:** 2026-03-24
**Version:** 1.0

---

## System: xTalent Time & Absence Module

The xTalent Time & Absence module is a SaaS HCM component that manages employee leave
lifecycles, attendance tracking, shift scheduling, overtime management, and payroll period
close for Vietnam-first multi-tenant deployments.

```mermaid
C4Context
  title System Context — xTalent Time & Absence Module

  Person(employee, "Employee", "Submits leave requests, clocks in/out, views balances, submits timesheets, requests overtime")
  Person(manager, "Manager", "Approves leave/OT/timesheets, views team calendar, manages shift swaps")
  Person(hr_admin, "HR Administrator", "Configures leave policies, runs accrual batch, manages holiday calendars, handles termination balances")
  Person(payroll_officer, "Payroll Officer", "Locks and closes payroll periods, retrieves payroll export packages")
  Person(sys_admin, "System Admin", "Configures tenant settings, manages approval chains, sets data region and compliance policies")

  System(ta_system, "xTalent Time & Absence", "Manages leave lifecycle, attendance, shifts, overtime, comp time, and payroll period close. Vietnam Labor Code 2019 compliant.")

  System_Ext(employee_central, "Employee Central", "Upstream master of employee records, org structure, and employment lifecycle events (hire / transfer / terminate)")
  System_Ext(payroll_system, "Payroll System", "Downstream consumer of PayrollExportPackage. Processes salary, deductions, and OT payments")
  System_Ext(biometric_network, "Biometric Device Network", "Upstream hardware source of authenticated clock-in/out punch events. Provides biometric reference tokens only (ADR-TA-004)")
  System_Ext(notification_service, "Notification Service", "Downstream delivery of email and push notifications triggered by domain events")
  System_Ext(schedule_module, "Schedule Module", "Future upstream: shift template assignments and roster publishing (Phase 2)")
  System_Ext(analytics_platform, "Analytics Platform", "Downstream event stream consumer. Receives all 54+ domain events as read-only stream")

  Rel(employee, ta_system, "Submits leave, clocks in/out, views balance, submits timesheet", "HTTPS/REST + Mobile App")
  Rel(manager, ta_system, "Approves requests, views team calendar, manages shifts", "HTTPS/REST + Web SPA")
  Rel(hr_admin, ta_system, "Configures policies, runs batches, manages holidays", "HTTPS/REST + Web SPA")
  Rel(payroll_officer, ta_system, "Locks/closes period, retrieves export", "HTTPS/REST + Web SPA")
  Rel(sys_admin, ta_system, "Configures tenant, approval chains, data region", "HTTPS/REST + Web SPA")

  Rel(employee_central, ta_system, "Publishes EmployeeHired / Transferred / Terminated events", "Event Bus / Webhook ACL")
  Rel(biometric_network, ta_system, "Sends authenticated punch events with biometric token ref", "Device SDK / HTTPS")
  Rel(ta_system, payroll_system, "Delivers PayrollExportPackage at period close", "Event Bus (PayrollExportCreated)")
  Rel(ta_system, notification_service, "Dispatches notification payloads (email/push)", "HTTPS/REST or Event Bus")
  Rel(ta_system, analytics_platform, "Streams all domain events (54+)", "Event Bus — read-only")
  Rel(schedule_module, ta_system, "Publishes shift assignments (future Phase 2)", "Event Bus (planned)")
```

---

## Actors

| Actor | Role | Primary Interactions |
|-------|------|----------------------|
| Employee | End user: individual contributor | Submit leave, clock in/out, request OT, view balance, submit timesheet |
| Manager | Approver: team lead or department head | Approve/reject leave/OT/timesheet, view team calendar, manage shift swaps |
| HR Administrator | Configurator: HR operations team | Configure leave policies, run accrual batch, manage holiday calendars, process termination balances |
| Payroll Officer | Operator: finance/payroll team | Lock payroll period, close period, retrieve and validate export package |
| System Admin | Tenant administrator | Configure tenant policies (H-P0-001/002/003/004), set data region (H10), manage approval chains |

---

## External Systems

| System | Direction | Integration Pattern | Data Exchanged | Trigger |
|--------|-----------|---------------------|----------------|---------|
| Employee Central | Upstream | Published Language / ACL | EmployeeHired, EmployeeTransferred, EmployeeTerminated events; employee master data | Employment lifecycle events |
| Payroll System | Downstream | Open Host Service | PayrollExportPackage (worked hours, OT by rate, leave days, comp time cash-outs, termination deductions) | Period close (PeriodClosed event) |
| Biometric Device Network | Upstream | Device SDK / HTTPS push | Authenticated punch events with biometric_ref token only (ADR-TA-004: no raw biometric) | Real-time punch; also offline batch sync (H8) |
| Notification Service | Downstream | Event-driven / HTTPS REST | Notification payloads (recipient_id, channel, template_key, subject, body_preview) | Domain events (approval, balance, expiry) |
| Analytics Platform | Downstream | Published Language — event stream | All domain events (54+) read-only forward | All state-changing domain events |
| Schedule Module | Upstream (Phase 2) | Event Bus (planned) | Shift roster and assignment events | Roster publish (future) |

---

## Architecture Decisions Reflected in L1

| Decision | Impact on System Context |
|----------|--------------------------|
| ADR-TA-001: Immutable ledger | LeaveMovement and Punch are append-only; no DELETE flows from external systems |
| ADR-TA-003: Vietnam-first | All VLC 2019 compliance (caps, rates, consent) enforced inside the system boundary |
| ADR-TA-004: No raw biometric | Biometric network sends token only; raw data never enters xTalent |
| H8: Offline-first | Biometric network and mobile app may batch-sync punches; conflict resolution inside system |
| H9: Multi-tenancy | Row-level isolation; tenant_id on all data; single cluster MVP |
| H10: Data residency | TenantConfig.data_region controls physical deployment region per tenant |
