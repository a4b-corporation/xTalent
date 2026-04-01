# Permission Matrix — Payroll Module (PR)

**Module**: Payroll (PR)
**Step**: 5 — Product Experience Design
**Date**: 2026-03-31

---

## Action Key

| Symbol | Meaning |
|--------|---------|
| **C** | Create |
| **R** | Read |
| **U** | Update |
| **D** | Delete / Deactivate |
| **E** | Execute (run, generate, trigger) |
| **A** | Approve (workflow action) |
| **—** | No access |

## Role Codes

| Code | Role |
|------|------|
| PA | PAYROLL_ADMIN |
| HM | HR_MANAGER |
| FM | FINANCE_MANAGER |
| WK | WORKER (self-service) |
| PL | PLATFORM_ADMIN |
| CE | CROSS_ENTITY_REPORT_VIEWER |

---

## Masterdata Features

| Feature ID | Feature | PA | HM | FM | WK | PL | CE |
|------------|---------|:--:|:--:|:--:|:--:|:--:|:--:|
| PR-M-001 | Pay Group Management | CRUD | R | R | — | R | — |
| PR-M-002 | Pay Element Management | CRUD + E(submit) | R | R | — | R | — |
| PR-M-003 | Pay Profile Management | CRUD | R | R | — | R | — |
| PR-M-004 | Worker Pay Assignment | CRUD | CRU | R | — | R | — |
| PR-M-005 | Statutory Rule Management | R | — | — | — | CRUD + E(activate) | — |
| PR-M-006 | Pay Calendar Management | CRUD | R | R | — | R | — |
| PR-M-007 | GL Account Mapping | CRUD | — | R | — | R | — |

---

## Transaction Features

| Feature ID | Feature | PA | HM | FM | WK | PL | CE |
|------------|---------|:--:|:--:|:--:|:--:|:--:|:--:|
| PR-T-001 | Monthly Payroll Run — Initiate | E | — | — | — | — | — |
| PR-T-001 | Monthly Payroll Run — View Results | R | R | R | — | — | — |
| PR-T-001 | Monthly Payroll Run — Cut-Off | E | — | — | — | — | — |
| PR-T-002 | Payroll Exception Handling — View | R | R | — | — | — | — |
| PR-T-002 | Payroll Exception Handling — Acknowledge | E | — | — | — | — | — |
| PR-T-003 | Payroll Run Approval — Submit | E | — | — | — | — | — |
| PR-T-003 | Payroll Run Approval — Level 2 Approve | — | A | — | — | — | — |
| PR-T-003 | Payroll Run Approval — Level 3 Approve | — | — | A | — | — | — |
| PR-T-003 | Payroll Run Approval — Reject (any level) | — | A | A | — | — | — |
| PR-T-004 | Period Lock — Execute | E | — | E | — | — | — |
| PR-T-004 | Period Lock — View Status | R | R | R | — | R | — |
| PR-T-005 | Termination Payroll — Initiate | E | E(initiate only) | — | — | — | — |
| PR-T-005 | Termination Payroll — Configure + Approve | E + A | — | A | — | — | — |
| PR-T-006 | Bank Payment File — Generate | E | — | E | — | — | — |
| PR-T-006 | Bank Payment File — Download | R | — | R | — | — | — |
| PR-T-007 | Payslip Generation — Trigger | E | — | — | — | — | — |
| PR-T-007 | Payslip Generation — View + Download (any worker) | R | R | R | — | — | — |
| PR-T-008 | BHXH Report Export — Generate + Download | E + R | — | — | — | — | — |
| PR-T-009 | PIT Declaration Export — Generate + Download | E + R | — | R | — | — | — |
| PR-T-010 | Audit Log Viewer — View (own entity) | R | — | — | — | R (all) | — |
| PR-T-011 | Advance Payroll — Initiate + Configure | E | — | — | — | — | — |
| PR-T-011 | Advance Payroll — Approve | — | A | A | — | — | — |
| PR-T-012 | Retroactive Adjustment — Create | C | — | — | — | — | — |
| PR-T-012 | Retroactive Adjustment — Approve | — | A | — | — | — | — |
| PR-T-012 | Retroactive Adjustment — View | R | R | R | — | — | — |
| PR-T-013 | Annual PIT Settlement — Trigger | E | — | — | — | — | — |
| PR-T-013 | Annual PIT Settlement — Approve | — | — | A | — | — | — |
| PR-T-014 | Bonus Run — Initiate | E | — | — | — | — | — |
| PR-T-014 | Bonus Run — Approve | — | A | A | — | — | — |
| PR-T-015 | Correction Run — Initiate | E | — | — | — | — | — |
| PR-T-015 | Correction Run — Approve | — | A | A | — | — | — |
| PR-T-016 | Worker Self-Service Payslip — View own | — | — | — | R (own) | — | — |
| PR-T-016 | Worker Self-Service Payslip — Download own | — | — | — | R (own) | — | — |
| PR-T-017 | Worker PIT Certificate — Download own | — | — | — | R (own) | — | — |
| PR-T-018 | PIT Annual Certificate Bulk — Generate | E | — | — | — | — | — |
| PR-T-018 | PIT Annual Certificate Bulk — Download any | R | — | — | — | — | — |
| PR-T-019 | GL Journal Viewer — View + Download | R | — | R | — | — | — |
| PR-T-020 | 13th Month Salary Run | E | — | — | — | — | — |
| PR-T-021 | Unpaid Leave Handling — Acknowledge | E | — | — | — | — | — |
| PR-T-022 | SI Split-Period Calculation — View in Calc Log | R | R | — | — | — | — |

---

## Analytics Features

| Feature ID | Feature | PA | HM | FM | WK | PL | CE |
|------------|---------|:--:|:--:|:--:|:--:|:--:|:--:|
| PR-A-001 | Payroll Cost Report | R | R | R | — | — | R |
| PR-A-002 | Payroll Variance Report | R | R | R | — | — | — |
| PR-A-003 | Payroll Register | R + E(export) | R + E(export) | R + E(export) | — | — | R |
| PR-A-004 | Integrity Verification Report | R | — | — | — | R | — |
| PR-A-005 | Worker YTD Portal View | — | — | — | R (own) | — | — |
| PR-A-006 | Calc Log Viewer | R | — | — | — | — | — |
| PR-A-007 | Worker YTD Summary (Admin) | R + E(export) | R + E(export) | R | — | — | R |
| PR-A-008 | Data Retention Dashboard | — | — | — | — | R | — |

---

## Formula Approval Sub-Flow (PR-M-002)

The pay element formula activation sub-flow has its own permission matrix:

| Action | PAYROLL_ADMIN | FINANCE_LEAD* | PLATFORM_ADMIN |
|--------|:---:|:---:|:---:|
| Create formula (DRAFT) | C | — | — |
| Submit for approval | E | — | — |
| Approve formula (PENDING → APPROVED) | — | A | — |
| Activate formula (APPROVED → ACTIVE) | E | — | — |
| Deprecate formula | E | — | — |
| View formula history | R | R | R |

*FINANCE_LEAD is a sub-role within FINANCE_MANAGER access; may be a separate role assignment in the system.

---

## Data Isolation Rules

These are enforced at the infrastructure level (row-level security), not just in the UI:

1. All payroll data is scoped by `legal_entity_id`. Users with PAYROLL_ADMIN for Entity A cannot read any data for Entity B.
2. WORKER role can only read records where `working_relationship.worker_id = authenticated user`. No exceptions.
3. CROSS_ENTITY_REPORT_VIEWER role bypasses entity scoping for read-only report queries only. Cannot write or execute.
4. PLATFORM_ADMIN role has cross-entity read access for audit log and statutory rules only. Payroll result data remains entity-scoped.
5. Any cross-entity access attempt (direct URL or API call) returns HTTP 403 (not 404) and is logged as SECURITY_VIOLATION in the audit log.
