# Feature Catalog — Payroll (PR)

**Module**: Payroll (PR)
**Solution**: xTalent HCM
**Step**: 5 — Product Experience Design
**Date**: 2026-03-31
**Version**: 1.0

---

## Classification Key

- **M** = Masterdata: CRUD configuration entities — light spec depth
- **T** = Transaction: multi-step workflows with state machines — deep spec depth
- **A** = Analytics: reports, dashboards, metrics — medium spec depth

---

## Feature List

| ID | Feature Name | Type | Priority | BC | Actor(s) | Linked Stories | Description |
|----|-------------|------|----------|-----|----------|----------------|-------------|
| PR-M-001 | Pay Group Management | M | P0 | BC-01 | PAYROLL_ADMIN | US-001 | Create, edit, and deactivate PayGroups with legal entity binding, pay calendar, and currency |
| PR-M-002 | Pay Element Management | M | P0 | BC-01 | PAYROLL_ADMIN | US-002, US-008 | Define pay elements with formula lifecycle (DRAFT → PENDING_APPROVAL → APPROVED → ACTIVE → DEPRECATED), tax treatment, SI basis inclusion, and proration method |
| PR-M-003 | Pay Profile Management | M | P0 | BC-01 | PAYROLL_ADMIN | US-003, US-004, US-005 | Configure pay profiles per pay method (MONTHLY_SALARY / HOURLY / PIECE_RATE / GRADE_STEP); dynamic form variant per method |
| PR-M-004 | Worker Pay Assignment | M | P0 | BC-01 | PAYROLL_ADMIN, HR_MANAGER | US-006, US-007 | Assign workers to pay groups and bind pay profiles; manage enrollment lifecycle |
| PR-M-005 | Statutory Rule Management | M | P0 | BC-02 | PLATFORM_ADMIN | US-006, US-007 | Create and activate versioned statutory rules (PIT brackets, SI rates/ceilings, OT multipliers, minimum wage, VN_LUONG_CO_SO) with timeline view |
| PR-M-006 | Pay Calendar Management | M | P1 | BC-01 | PAYROLL_ADMIN | US-001 | Define and manage pay calendars with period schedules and cut-off dates |
| PR-M-007 | GL Account Mapping | M | P1 | BC-01 | PAYROLL_ADMIN | US-009 | Map pay elements to VAS GL account codes for journal generation |
| PR-T-001 | Monthly Payroll Run | T | P0 | BC-03 | PAYROLL_ADMIN | US-010, US-011, US-012, US-013, US-014, US-015, US-016, US-017, US-019 | Full payroll run lifecycle: cut-off → DRY_RUN → PRODUCTION → exceptions → submit → approve → lock. Async progress indicator. Supports all pay methods. |
| PR-T-002 | Payroll Exception Handling | T | P0 | BC-03 | PAYROLL_ADMIN | US-016, US-017, US-037 | View, acknowledge (with reason code), and resolve payroll exceptions (NEGATIVE_NET, MIN_WAGE_VIOLATION, ZERO_GROSS, OT_CAP_EXCEEDED, etc.) |
| PR-T-003 | Payroll Run Approval | T | P0 | BC-03 | HR_MANAGER, FINANCE_MANAGER | US-025, US-026, US-027, US-028 | Two-level approval workflow: Level 2 (HR Manager) → Level 3 (Finance Manager). Reject with mandatory reason code. Audit trail. |
| PR-T-004 | Period Lock | T | P0 | BC-03 | FINANCE_MANAGER, PAYROLL_ADMIN | US-027, US-029 | Lock pay period after final approval; generate SHA-256 integrity hashes per worker result record |
| PR-T-005 | Termination Payroll | T | P0 | BC-04 | PAYROLL_ADMIN | US-023 | Off-cycle final pay for terminated workers (pro-rated salary, leave payout, severance per termination type) |
| PR-T-006 | Bank Payment File | T | P0 | BC-04 | FINANCE_MANAGER, PAYROLL_ADMIN | US-031 | Generate and download bank payment file (VCB / BIDV / TCB format) after period lock |
| PR-T-007 | Payslip Generation | T | P0 | BC-04 | PAYROLL_ADMIN | US-030 | Auto-generate PDF payslips after period lock; configurable template; distribute to workers via portal notification |
| PR-T-008 | BHXH Report Export | T | P0 | BC-05 | PAYROLL_ADMIN | US-033 | Generate BHXH D02-LT contribution report in VssID format for Social Insurance Agency submission |
| PR-T-009 | PIT Declaration Export | T | P0 | BC-05 | PAYROLL_ADMIN | US-034 | Generate PIT Form 05/KK-TNCN XML quarterly per Circular 08/2013/TT-BTC for GDT eTax portal |
| PR-T-010 | Audit Log Viewer | T | P0 | BC-07 | PAYROLL_ADMIN, PLATFORM_ADMIN | US-044, US-045 | View immutable audit trail for all payroll actions with filters by action type, user, entity, and date range |
| PR-T-011 | Advance Payroll | T | P1 | BC-03 | PAYROLL_ADMIN | US-020 | Off-cycle salary advance disbursement with recovery tracking in subsequent periods |
| PR-T-012 | Retroactive Adjustment | T | P1 | BC-03 | PAYROLL_ADMIN | US-020 | Create retroactive salary adjustments up to 12 prior closed periods; delta computed in next open period |
| PR-T-013 | Annual PIT Settlement | T | P1 | BC-03 | PAYROLL_ADMIN | US-021, US-035 | Year-end PIT settlement calculation (JANUARY_STANDALONE or DECEMBER_PAYROLL mode); generates Form 05/QTT-TNCN |
| PR-T-014 | Bonus Run | T | P1 | BC-03 | PAYROLL_ADMIN | US-022 | Off-cycle bonus payment run with configurable bonus element and approval workflow |
| PR-T-015 | Correction Run | T | P1 | BC-03 | PAYROLL_ADMIN | US-022 | Correction run for prior period errors; separate run type tracked independently |
| PR-T-016 | Worker Self-Service Payslip | T | P1 | BC-06 | WORKER | US-040 | Worker views and downloads own payslips per period from self-service portal |
| PR-T-017 | Worker PIT Certificate | T | P1 | BC-06 | WORKER | US-041 | Worker requests and downloads PIT withholding certificate (Form 03/TNCN) |
| PR-T-018 | PIT Annual Certificate Bulk | T | P1 | BC-05 | PAYROLL_ADMIN | US-035 | Bulk generate PIT withholding certificates (Form 03/TNCN) for all workers at year-end |
| PR-T-019 | GL Journal Viewer | T | P1 | BC-04 | FINANCE_MANAGER | US-032 | View and download generated GL journal entries after period lock |
| PR-T-020 | 13th Month Salary Run | T | P1 | BC-03 | PAYROLL_ADMIN | US-022 | Year-end bonus run including 13th month salary calculation with pro-ration for partial-year workers |
| PR-T-021 | Unpaid Leave Full-Month Handling | T | P2 | BC-03 | PAYROLL_ADMIN | US-024 | Zero-gross worker handling for full-month unpaid leave; exception acknowledgment required |
| PR-T-022 | SI Split-Period Calculation | T | P1 | BC-03 | PAYROLL_ADMIN | US-018 | Mid-period SI ceiling change handling; split-period calculation visible in calc log |
| PR-A-001 | Payroll Cost Report | A | P0 | BC-03 | FINANCE_MANAGER, HR_MANAGER | US-039 | Total payroll cost by department and cost center: gross, employer SI, total employer cost |
| PR-A-002 | Payroll Variance Report | A | P0 | BC-03 | PAYROLL_ADMIN, FINANCE_MANAGER | US-036 | Period-over-period element variance analysis with configurable threshold highlighting |
| PR-A-003 | Payroll Register | A | P0 | BC-03 | PAYROLL_ADMIN, FINANCE_MANAGER, HR_MANAGER | US-038 | Full payroll register view for a completed run: all workers × all elements × net salary; exportable |
| PR-A-004 | Integrity Verification Report | A | P0 | BC-07 | PLATFORM_ADMIN | US-047 (implied), US-029 | SHA-256 hash verification results for locked periods; nightly check status dashboard |
| PR-A-005 | Worker YTD Portal View | A | P1 | BC-06 | WORKER | US-042 | Worker views own YTD earnings, SI, PIT, and net paid; month-by-month breakdown |
| PR-A-006 | Calc Log Viewer | A | P0 | BC-03 | PAYROLL_ADMIN | US-046 (implied) | View step-by-step calculation log for a specific worker result; paginated; links to statutory_rule references |
| PR-A-007 | Worker YTD Summary (Admin) | A | P1 | BC-06 | PAYROLL_ADMIN, HR_MANAGER | US-038 | Year-to-date earnings and deductions per worker for admin view |
| PR-A-008 | Data Retention Dashboard | A | P1 | BC-07 | PLATFORM_ADMIN | US-046 | Retention status for payroll records (7-year and 10-year BHXH rules) |

---

## Summary

| Metric | Count |
|--------|-------|
| **Total features** | 38 |
| **Masterdata (M)** | 7 |
| **Transaction (T)** | 22 |
| **Analytics (A)** | 8 |
| | |
| **P0 features** | 19 |
| **P1 features** | 16 |
| **P2 features** | 3 |

### P0 Features (must ship in V1)

| ID | Feature | Type |
|----|---------|------|
| PR-M-001 | Pay Group Management | M |
| PR-M-002 | Pay Element Management | M |
| PR-M-003 | Pay Profile Management | M |
| PR-M-004 | Worker Pay Assignment | M |
| PR-M-005 | Statutory Rule Management | M |
| PR-T-001 | Monthly Payroll Run | T |
| PR-T-002 | Payroll Exception Handling | T |
| PR-T-003 | Payroll Run Approval | T |
| PR-T-004 | Period Lock | T |
| PR-T-005 | Termination Payroll | T |
| PR-T-006 | Bank Payment File | T |
| PR-T-007 | Payslip Generation | T |
| PR-T-008 | BHXH Report Export | T |
| PR-T-009 | PIT Declaration Export | T |
| PR-T-010 | Audit Log Viewer | T |
| PR-A-001 | Payroll Cost Report | A |
| PR-A-002 | Payroll Variance Report | A |
| PR-A-003 | Payroll Register | A |
| PR-A-004 | Integrity Verification Report | A |
| PR-A-006 | Calc Log Viewer | A |

### Traceability Notes

- US-010 through US-019 map to PR-T-001 (Monthly Payroll Run) as run modes within the same feature
- US-016, US-017, US-037 all feed into PR-T-002 (Exception Handling) — they are UI sub-views not separate features
- US-025 through US-028 map to PR-T-003 (Approval) as approval flow states
- US-038 (Payroll Register) is classified as Analytics (PR-A-003) because it is a read-only report, not a transaction
- US-044 (Audit Log entry creation) is automatic; PR-T-010 is the viewer feature for admins
- US-045, US-046, US-047 are security/compliance behaviors that manifest as audit trail and retention features
