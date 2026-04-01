# Menu Map — Payroll Module (PR)

**Module**: Payroll (PR)
**Step**: 5 — Product Experience Design
**Date**: 2026-03-31

---

## Navigation Context

All payroll screens are scoped to the **active legal entity**. A legal entity context switcher appears in the top navigation bar. Users with multiple legal entity roles switch context before operating. Cross-entity data is never shown without the `CROSS_ENTITY_REPORT_VIEWER` role.

---

## Payroll Admin View

Primary role: PAYROLL_ADMIN. Sees all payroll operational menus.

```
Payroll (module root)
├── Dashboard
│   └── Current period status, pending actions, exception count, recent runs
│
├── Payroll Runs
│   ├── All Runs (list, filter by status/period/pay group)
│   ├── [+ New Run] — wizard to initiate DRY_RUN / SIMULATION / PRODUCTION
│   └── Run Detail
│       ├── Run Status (progress indicator for async runs)
│       ├── Worker Results (paginated, all workers in run)
│       ├── Exceptions (OPEN and ACKNOWLEDGED)
│       ├── Variance Report (element-level period comparison)
│       ├── Calculation Log (per-worker drill-down)
│       └── [Submit for Approval] (enabled only when all exceptions acknowledged)
│
├── Pay Periods
│   ├── All Periods (list, filter by pay group / year)
│   ├── [+ New Period] — create period from calendar
│   └── Period Detail
│       ├── Period status + cut-off date
│       ├── Linked Runs
│       ├── Lock status + integrity hash status
│       └── [Apply Cut-Off] / [Lock Period]
│
├── Off-Cycle Runs
│   ├── Termination Pay (search worker → initiate termination run)
│   ├── Advance Payment
│   ├── Bonus Run
│   ├── Correction Run
│   └── Annual PIT Settlement
│
├── Retroactive Adjustments
│   ├── All Adjustments (list)
│   └── [+ New Adjustment] — worker search → period range → delta preview → confirm
│
├── Pay Master
│   ├── Pay Groups
│   │   ├── List (filter by legal entity)
│   │   ├── [+ New Pay Group]
│   │   └── Pay Group Detail (edit, deactivate)
│   │
│   ├── Pay Elements
│   │   ├── Library (all elements, filter by type/status/country)
│   │   ├── [+ New Element]
│   │   └── Element Detail (formula editor, lifecycle actions: submit/activate/deprecate)
│   │
│   ├── Pay Profiles
│   │   ├── List (filter by pay method)
│   │   ├── [+ New Profile]
│   │   └── Profile Detail (dynamic form: MONTHLY / HOURLY / PIECE_RATE / GRADE_STEP variants)
│   │
│   ├── Worker Assignments
│   │   ├── Enrolled Workers (list, filter by pay group / status)
│   │   ├── [Enroll Worker] — search → assign pay group + profile
│   │   └── Worker Enrollment Detail (edit assignment, transfer pay group)
│   │
│   ├── Pay Calendars
│   │   ├── List
│   │   ├── [+ New Calendar]
│   │   └── Calendar Detail (periods, cut-off rules)
│   │
│   └── GL Account Mapping
│       ├── Mapping Table (element → GL accounts)
│       └── [+ New Mapping]
│
├── Outputs
│   ├── Payslips
│   │   ├── Generate Payslips (by period + pay group)
│   │   ├── Payslip List (search by worker / period)
│   │   └── Individual Payslip (preview + download PDF)
│   │
│   ├── Bank Payment Files
│   │   ├── Generate File (select bank: VCB / BIDV / TCB)
│   │   └── File History (list of generated files + download links)
│   │
│   └── GL Journals
│       ├── Generate Journal (by period)
│       └── Journal List (read-only view + export)
│
├── Compliance
│   ├── BHXH Reports
│   │   ├── Generate D02-LT (select period + legal entity)
│   │   └── Report History (download)
│   │
│   ├── PIT Declarations
│   │   ├── Generate 05/KK-TNCN (quarterly)
│   │   ├── Generate 05/QTT-TNCN (annual settlement)
│   │   └── Declaration History
│   │
│   └── PIT Certificates
│       ├── Bulk Generate (Form 03/TNCN for all workers, year selection)
│       └── Certificate List (download per worker)
│
├── Reports
│   ├── Payroll Register (run-level: all workers × elements)
│   ├── Payroll Variance (period comparison, threshold filter)
│   ├── Payroll Cost (by department / cost center)
│   └── Worker YTD Summary
│
└── Audit
    ├── Audit Log (filter by action type / user / date range / entity)
    └── Integrity Verification (hash check results per locked period)
```

---

## HR Manager View

Role: HR_MANAGER. Sees approval queue, enrollment, read-only reports.

```
Payroll
├── Dashboard
│   └── Pending approvals, recent activity
│
├── Approval Queue
│   └── Runs Awaiting Level 2 Approval (list → detail → Approve / Reject)
│
├── Payroll Runs
│   └── All Runs (read-only: view status, view register, view exceptions — no initiate)
│
├── Worker Assignments
│   ├── Enrolled Workers (view + enroll new workers)
│   └── Worker Enrollment Detail
│
├── Reports
│   ├── Payroll Register (read-only)
│   ├── Payroll Variance (read-only)
│   ├── Payroll Cost (read-only)
│   └── Worker YTD Summary (read-only)
│
└── Off-Cycle
    └── Termination Pay (initiate only — calculation done by PAYROLL_ADMIN)
```

---

## Finance Manager View

Role: FINANCE_MANAGER. Sees final approval queue, GL, outputs, cost reports.

```
Payroll
├── Dashboard
│   └── Pending final approvals, total payroll cost this period
│
├── Approval Queue
│   └── Runs Awaiting Level 3 Approval (list → detail → Approve / Reject)
│
├── Period Lock
│   └── Locked Periods + [Lock Period] action (post final approval)
│
├── Outputs
│   ├── Bank Payment Files (generate + download after lock)
│   └── GL Journals (generate + view after lock)
│
├── Reports
│   ├── Payroll Register (read-only)
│   ├── Payroll Cost (by department / cost center)
│   └── Payroll Variance (read-only)
│
└── Compliance
    └── PIT Declarations (read-only, download)
```

---

## Worker Self-Service View

Role: WORKER. Isolated to own data only. Cannot access any other worker's data.

```
My Pay
├── My Payslips
│   ├── Payslip History (list by period, current and past years)
│   └── Payslip Detail (view online + download PDF)
│
├── My YTD Summary
│   └── YTD totals: gross, BHXH, BHYT, BHTN, PIT, net — month-by-month
│
└── Tax Documents
    └── PIT Withholding Certificates
        ├── Certificate List (by year)
        └── Download Form 03/TNCN
```

---

## Platform Admin View

Role: PLATFORM_ADMIN. Manages statutory rules and system-level configuration.

```
Platform
├── Statutory Rules
│   ├── Rule List (filter by category: TAX / SOCIAL_INSURANCE / OVERTIME / MINIMUM_WAGE)
│   ├── [+ New Rule Version]
│   ├── Rule Detail (timeline view: active / upcoming / historical versions)
│   └── [Activate] / [Supersede]
│
├── Legal Entities
│   ├── Entity List
│   └── Entity Configuration (payroll settings per legal entity)
│
└── Audit
    ├── Audit Log (full system view, cross-entity)
    └── Integrity Verification Dashboard
```

---

## Cross-Entity Viewer (CE_VIEWER)

Role: CROSS_ENTITY_REPORT_VIEWER. Read-only, cross-entity reports only.

```
Reports
├── Cross-Entity Payroll Cost
├── Cross-Entity YTD Summary
└── Cross-Entity Register (all legal entities)
```

---

## Role Visibility Summary

| Menu Section | PAYROLL_ADMIN | HR_MANAGER | FINANCE_MANAGER | WORKER | PLATFORM_ADMIN | CE_VIEWER |
|--------------|:---:|:---:|:---:|:---:|:---:|:---:|
| Dashboard | Yes | Yes (limited) | Yes (limited) | No | No | No |
| Payroll Runs | Full | Read-only | Read-only | No | No | No |
| Pay Periods | Full | No | Lock action | No | No | No |
| Off-Cycle Runs | Full | Initiate only | No | No | No | No |
| Retro Adjustments | Full | No | No | No | No | No |
| Pay Master | Full | Enroll only | No | No | No | No |
| Outputs | Full | No | Bank+GL | No | No | No |
| Compliance | Full | No | Read-only | No | No | No |
| Reports | Full | Read-only | Read-only | No | No | Read (cross-entity) |
| Approval Queue | No | Level 2 | Level 3 | No | No | No |
| My Pay | No | No | No | Own data only | No | No |
| Statutory Rules | No | No | No | No | Full | No |
| Audit | Read-own-entity | No | No | No | Full | No |
| Integrity Report | Read-own-entity | No | No | No | Full | No |

---

## Restructured Unified Menu — PR Module

> **Nguyên tắc phân vùng:**
> - **Settings** — cấu hình kỹ thuật / hệ thống, dành cho Platform Admin, IT triển khai
> - **Configs** — cấu hình nghiệp vụ do HR/IT nghiệp vụ thiết lập (master data, elements, rules…)
> - **Operations** — tác nghiệp HR hàng ngày; chia sub-group theo vai trò
> - **Reports** — báo cáo & phân tích
> - **Self Services** — portal tự phục vụ, chia 2 view: Worker & Manager

```
Payroll (module root)
│
├── [SETTINGS]  ← Platform Admin / IT Triển khai
│   ├── Legal Entities
│   │   ├── Entity List
│   │   └── Entity Configuration (payroll settings per legal entity)
│   │
│   ├── Statutory Rules
│   │   ├── Rule List  (filter: TAX / SOCIAL_INSURANCE / OVERTIME / MINIMUM_WAGE)
│   │   ├── Rule Detail  (timeline: active / upcoming / historical versions)
│   │   └── [+ New Rule Version] / [Activate] / [Supersede]
│   │
│   └── Audit & Integrity
│       ├── Audit Log  (full system, cross-entity — PLATFORM_ADMIN)
│       │   └── [sub] Own-entity Log  (PAYROLL_ADMIN: scoped to own entity)
│       └── Integrity Verification Dashboard
│           └── Hash check results per locked period
│
├── [CONFIGS]  ← HR Nghiệp vụ / IT Nghiệp vụ (PAYROLL_ADMIN setup role)
│   │
│   ├── Pay Groups
│   │   ├── Pay Group List  (filter by legal entity)
│   │   ├── Pay Group Detail  (edit, deactivate)
│   │   └── [+ New Pay Group]
│   │
│   ├── Pay Calendars
│   │   ├── Calendar List
│   │   ├── Calendar Detail  (periods, cut-off rules)
│   │   └── [+ New Calendar]
│   │
│   ├── Pay Elements
│   │   ├── Element Library  (filter by type / status / country)
│   │   ├── Element Detail  (formula editor; lifecycle: Draft → Active → Deprecated)
│   │   └── [+ New Element]
│   │
│   ├── Pay Profiles
│   │   ├── Profile List  (filter by pay method)
│   │   ├── Profile Detail  (MONTHLY / HOURLY / PIECE_RATE / GRADE_STEP variants)
│   │   └── [+ New Profile]
│   │
│   └── GL Account Mapping
│       ├── Mapping Table  (element → GL accounts)
│       └── [+ New Mapping]
│
├── [OPERATIONS]  ← HR tác nghiệp hàng ngày
│   │
│   ├── Dashboard  ← Payroll Admin / HR Manager / Finance Manager
│   │   ├── Current period status, pending actions, exception count, recent runs
│   │   │   (PAYROLL_ADMIN: full; HR_MANAGER: approvals + activity; FINANCE_MANAGER: cost + final approvals)
│   │   └── Approval Queue  (pending items by role; direct action: Approve / Reject)
│   │
│   ├── — Payroll Admin Group —
│   │   │
│   │   ├── Pay Periods
│   │   │   ├── Period List  (filter by pay group / year)
│   │   │   ├── Period Detail
│   │   │   │   ├── Status + cut-off date
│   │   │   │   ├── Linked Runs
│   │   │   │   ├── Lock status + integrity hash status
│   │   │   │   └── [Apply Cut-Off] / [Lock Period]
│   │   │   └── [+ New Period]
│   │   │
│   │   ├── Payroll Runs
│   │   │   ├── Run List  (filter by status / period / pay group)
│   │   │   ├── Run Detail
│   │   │   │   ├── Run Status  (progress indicator for async runs)
│   │   │   │   ├── Worker Results  (paginated)
│   │   │   │   ├── Exceptions  (OPEN / ACKNOWLEDGED)
│   │   │   │   ├── Variance Report  (element-level period comparison)
│   │   │   │   ├── Calculation Log  (per-worker drill-down)
│   │   │   │   └── [Submit for Approval]  (enabled when all exceptions acknowledged)
│   │   │   └── [+ New Run]  ← wizard: DRY_RUN / SIMULATION / PRODUCTION
│   │   │
│   │   ├── Off-Cycle Runs
│   │   │   ├── Termination Pay  (search worker → initiate run)
│   │   │   ├── Advance Payment
│   │   │   ├── Bonus Run
│   │   │   ├── Correction Run
│   │   │   └── Annual PIT Settlement
│   │   │
│   │   └── Retroactive Adjustments
│   │       ├── Adjustment List
│   │       └── [+ New Adjustment]  ← worker search → period range → delta preview → confirm
│   │
│   ├── — HR Manager Group —
│   │   │
│   │   ├── Worker Assignments
│   │   │   ├── Enrolled Workers  (view + filter; HR_MANAGER: can enroll)
│   │   │   ├── Worker Enrollment Detail  (edit assignment, transfer pay group)
│   │   │   └── [Enroll Worker]  ← search → assign pay group + profile
│   │   │
│   │   └── Off-Cycle (initiation only)
│   │       └── Termination Pay  ← initiate; calculation performed by Payroll Admin
│   │
│   └── — Finance Manager Group —
│       │
│       ├── Period Lock
│       │   └── Locked Periods  + [Lock Period] action  (post final approval)
│       │
│       └── Outputs
│           ├── Payslips
│           │   ├── Generate Payslips  (by period + pay group)
│           │   ├── Payslip List  (search by worker / period)
│           │   └── Individual Payslip  (preview + download PDF)
│           │
│           ├── Bank Payment Files
│           │   ├── Generate File  (select bank: VCB / BIDV / TCB)
│           │   └── File History  (list of generated files + download)
│           │
│           ├── GL Journals
│           │   ├── Generate Journal  (by period)
│           │   └── Journal List  (read-only + export)
│           │
│           └── Compliance Outputs
│               ├── BHXH Reports
│               │   ├── Generate D02-LT  (select period + legal entity)
│               │   └── Report History  (download)
│               │
│               ├── PIT Declarations
│               │   ├── Generate 05/KK-TNCN  (quarterly)
│               │   ├── Generate 05/QTT-TNCN  (annual settlement)
│               │   └── Declaration History
│               │
│               └── PIT Certificates
│                   ├── Bulk Generate  (Form 03/TNCN, by year)
│                   └── Certificate List  (download per worker)
│
├── [REPORTS]  ← Payroll Admin (full) / HR Manager / Finance Manager / CE Viewer
│   ├── Payroll Register  (run-level: all workers × elements)
│   ├── Payroll Variance  (period comparison, threshold filter)
│   ├── Payroll Cost  (by department / cost center)
│   ├── Worker YTD Summary
│   └── Cross-Entity Reports  ← CE_VIEWER only
│       ├── Cross-Entity Payroll Cost
│       ├── Cross-Entity YTD Summary
│       └── Cross-Entity Register  (all legal entities)
│
└── [SELF SERVICES]  ← Worker & Manager self-service portal
    │
    ├── — Worker View —  (scoped to own data only; role: WORKER)
    │   ├── My Payslips
    │   │   ├── Payslip History  (list by period, current + past years)
    │   │   └── Payslip Detail  (view online + download PDF)
    │   │
    │   ├── My YTD Summary
    │   │   └── YTD totals: Gross / BHXH / BHYT / BHTN / PIT / Net — month-by-month
    │   │
    │   └── My Tax Documents
    │       └── PIT Withholding Certificates
    │           ├── Certificate List  (by year)
    │           └── Download Form 03/TNCN
    │
    └── — Manager View —  (line manager / HR Manager; scoped to direct reports)
        ├── Team Payroll Overview  (read-only run status for direct reports)
        ├── Pending Approvals  (runs awaiting Level 2 review → Approve / Reject)
        └── Team Reports
            ├── Team Payroll Register  (read-only)
            ├── Team Payroll Cost  (by department)
            └── Team YTD Summary
```

### Role → Menu Section Mapping (Consolidated)

| Menu Section | PAYROLL_ADMIN | HR_MANAGER | FINANCE_MANAGER | WORKER | PLATFORM_ADMIN | CE_VIEWER |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **Settings** → Legal Entities | No | No | No | No | Full | No |
| **Settings** → Statutory Rules | No | No | No | No | Full | No |
| **Settings** → Audit (cross-entity) | No | No | No | No | Full | No |
| **Settings** → Audit (own-entity) | Read | No | No | No | Full | No |
| **Configs** → Pay Groups | Full | No | No | No | No | No |
| **Configs** → Pay Calendars | Full | No | No | No | No | No |
| **Configs** → Pay Elements | Full | No | No | No | No | No |
| **Configs** → Pay Profiles | Full | No | No | No | No | No |
| **Configs** → GL Mapping | Full | No | No | No | No | No |
| **Operations** → Dashboard | Full | Limited | Limited | No | No | No |
| **Operations** → Approval Queue | No | Level 2 | Level 3 | No | No | No |
| **Operations** → Pay Periods | Full | No | Lock only | No | No | No |
| **Operations** → Payroll Runs | Full | Read-only | Read-only | No | No | No |
| **Operations** → Off-Cycle Runs | Full | Initiate only | No | No | No | No |
| **Operations** → Retro Adjustments | Full | No | No | No | No | No |
| **Operations** → Worker Assignments | Full | Full | No | No | No | No |
| **Operations** → Outputs & Compliance | Full | No | Full | No | No | No |
| **Reports** → Standard Reports | Full | Read | Read | No | No | No |
| **Reports** → Cross-Entity Reports | No | No | No | No | No | Full |
| **Self Services** → Worker View | No | No | No | Own data | No | No |
| **Self Services** → Manager View | No | Full | No | No | No | No |

