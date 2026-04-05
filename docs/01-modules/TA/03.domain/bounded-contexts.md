# Bounded Context Map: Time & Absence

**Module:** xTalent HCM — Time & Absence
**Step:** 3 — Domain Architecture
**Date:** 2026-03-24
**Version:** 1.0

---

## Context Overview

| ID | Name | Core Responsibility | Key Aggregates | Integration Pattern |
|----|------|---------------------|----------------|---------------------|
| `ta.absence` | Absence Management | Leave lifecycle, balance tracking via immutable ledger, accrual, carryover, termination handling | LeaveType, LeavePolicy, LeaveInstant, LeaveMovement, LeaveRequest, LeaveReservation, AccrualPlan, CarryoverRule, TerminationBalanceRecord, LeaveInstantDetail, LeaveEventDef, LeaveClassEvent, LeaveEventRun, ClassPolicyAssignment, TeamLeaveLimit | Downstream of Employee Central; upstream to Payroll |
| `ta.attendance` | Time & Attendance | Clock in/out, worked time calculation, overtime tracking and cap enforcement, comp time, timesheets, attendance evaluation | Punch, WorkedPeriod, AttendanceRecord, TimeException, OvertimeRequest, CompTimeBalance, Timesheet, EvalRule, EvalResult, ShiftSwapRequest, OpenShiftPool | Downstream of biometric devices and ta.scheduling; upstream to Payroll |
| `ta.scheduling` | Schedule Management | 6-level hierarchical schedule definition and roster generation. Owns: TimeSegment, ShiftDef, DayModel, PatternTemplate, ScheduleAssignment, GeneratedRoster, ScheduleOverride. Centralizes eligibility via eligibility_profile_id (Change 30). | TimeSegment, ShiftDef, DayModel, PatternTemplate, ScheduleAssignment, GeneratedRoster, ScheduleOverride, ShiftBreak, ShiftSegment, PatternDay | Upstream to ta.attendance (provides GeneratedRoster as read-only); consumes HolidayCalendar from ta.shared |
| `ta.shared` | Shared Services | Payroll periods, holiday calendars, multi-level approval workflow engine, notification dispatch, tenant configuration | Period, HolidayCalendar, ApprovalChain, ApprovalTask, Notification, PayrollExportPackage, TenantConfig, PeriodProfile | Orchestrator between ta.absence and ta.attendance at period close; upstream to Analytics |

---

## Context Relationships

```
                         ┌─────────────────────────────────┐
                         │   Employee Central (External)   │
                         │   Upstream System               │
                         └────────────┬────────────────────┘
                                      │ EmployeeHired / Transferred / Terminated
                                      │ (published events, ACL adapter)
                         ┌────────────▼────────────────────┐
                         │        ta.shared                │
                         │   Shared Services               │
                         │  (Period, HolidayCalendar,      │
                         │   ApprovalChain, TenantConfig,  │
                         │   PeriodProfile)                │
                         └────┬───────────────────┬────────┘
                              │                   │
          HolidayCalendar     │                   │  ApprovalChain, Period
          Period events        │                   │  events
                              │                   │
           ┌──────────────────▼──┐    ┌───────────▼──────────────────┐
           │    ta.absence       │    │     ta.scheduling            │
           │  Absence Mgmt       │    │   Schedule Management        │
           │  (LeaveRequest,     │    │  (ShiftDef, PatternTemplate, │
           │   LeaveMovement,    │    │   ScheduleAssignment,        │
           │   LeaveInstant...)  │    │   GeneratedRoster...)        │
           └──────────┬──────────┘    └────────────┬─────────────────┘
                      │                            │ GeneratedRoster (read-only)
                      │                ┌───────────▼──────────────────┐
                      │                │     ta.attendance            │
                      │                │   Time & Attendance          │
                      │                │  (Punch, AttendanceRecord,   │
                      │                │   Timesheet, EvalRule...)    │
                      │                └────────────┬─────────────────┘
              LeaveExport                    TimesheetExport
                      │                            │
                      └──────────┬─────────────────┘
                                 │
                    ┌────────────▼────────────────────┐
                    │   Payroll Module (External)     │
                    │   Downstream System             │
                    │   (PayrollExportPackage)        │
                    └─────────────────────────────────┘

                    ┌─────────────────────────────────┐
                    │   Analytics Platform (External) │
                    │   Domain event stream (all 54)  │
                    └─────────────────────────────────┘
```

### Relationship Types

| Upstream Context | Downstream Context | Pattern | Notes |
|-----------------|-------------------|---------|-------|
| Employee Central | ta.shared | Published Language / ACL | ta.shared adapts external events; owns ACL translation |
| Employee Central | ta.absence | (via ta.shared ACL) | ta.shared re-publishes normalized employee events |
| Employee Central | ta.attendance | (via ta.shared ACL) | ta.shared re-publishes normalized employee events |
| ta.shared | ta.absence | Shared Kernel (HolidayCalendar, Period) | ta.absence consumes published Period and Holiday data |
| ta.shared | ta.attendance | Shared Kernel (HolidayCalendar, Period) | ta.attendance consumes Period for timesheet lifecycle |
| ta.shared | ta.scheduling | Shared Kernel (HolidayCalendar) | ta.scheduling uses HolidayCalendar for holiday substitution in roster generation |
| ta.scheduling | ta.attendance | Published Language (GeneratedRoster) | ta.attendance reads GeneratedRoster as read-only; never modifies it |
| ta.absence | Payroll Module | Open Host Service | PayrollExportPackage published at period close |
| ta.attendance | Payroll Module | Open Host Service | TimesheetExport embedded in PayrollExportPackage |
| ta.shared | Analytics Platform | Published Language | All domain events forwarded as read-only stream |

### Shared Kernel Boundary

The following concepts are SHARED KERNEL (owned by `ta.shared`, consumed read-only by other contexts):
- `Period` — payroll period lifecycle; both absence and attendance observe period state transitions
- `HolidayCalendar` — used for leave duration calculation (ta.absence), OT rate determination (ta.attendance), and holiday substitution in roster generation (ta.scheduling)
- `ApprovalChain` — routing engine invoked by both ta.absence and ta.attendance
- `GeneratedRoster` — owned by `ta.scheduling`; consumed read-only by `ta.attendance` for punch validation and attendance processing. The roster is the authoritative scheduled shift for any given employee-date. ta.attendance MUST NOT re-calculate schedules from PatternTemplate.

---

## Centralized Eligibility Engine (Change 30)

`eligibility_profile_id` replaces direct `employee_id` / `employee_group_id` / `position_id` FK assignments in two places:
- `ta.scheduling.ScheduleAssignment` — determines which employees follow a given PatternTemplate
- `ta.absence.LeaveClass` — determines which employees are entitled to a given leave class

The eligibility profile is owned and resolved by the Core module's Eligibility engine. When an employee transfers departments or changes roles, their eligibility profiles update automatically, and schedule/leave assignments follow without manual HR intervention.

**Rationale (Change 30 — 2026-04-03):** Previously, managers manually assigned `employee_id` or `employee_group_id` to each ScheduleAssignment and LeaveClass. This caused stale assignments after org changes. Centralized eligibility resolves this at runtime.

---

## Leave Event Engine (Change 29)

The old `AccrualPlan` + `AccrualBatchRun` model is replaced by a generalized event engine:
- `LeaveEventDef` — typed event catalog (ACCRUAL, CARRY, EXPIRE, RESET_LIMIT, BOOK_HOLD, START_POST, ADJUST)
- `LeaveClassEvent` — N:N mapping connecting a LeaveClass to its applicable events with `qty_formula`
- `LeaveEventRun` — execution record per event-class-period; idempotent; replaces `AccrualBatchRun`

This generalizes beyond "just accrual" — any leave lifecycle operation (carry-forward, expiry, limit reset) is now a first-class LeaveEventDef. New event types can be added without code changes.

---

## ta.absence — Absence Management

### Core Aggregates

| Aggregate | Responsibility | Invariants |
|-----------|----------------|------------|
| `LeaveType` | Configuration root for each leave category | Code unique per tenant; annual leave floor ≥ 14 days (VLC Art. 113) |
| `LeaveClass` | Groups leave types for shared deduction priority rules; eligibility via eligibility_profile_id (Change 30) | At least one leave type per class |
| `LeavePolicy` | Binds employee groups to leave types with accrual and entitlement rules | Policy cannot set annual leave below VLC minimum |
| `LeaveInstant` | Point-in-time computed balance per employee per leave type | available = earned - used - reserved; available ≥ 0 unless advance permitted |
| `LeaveMovement` | Immutable ledger record of every balance change | Append-only; no UPDATE/DELETE; amount ≠ 0; ADR-TA-001 |
| `LeaveRequest` | Full lifecycle of an employee leave request | State machine is one-directional; cancellation deadline enforced |
| `LeaveReservation` | Provisional hold on balance preventing overbooking | Cannot exceed available balance; FEFO applied |
| `AccrualPlan` | Configuration of how leave is earned (method, frequency, caps) — superseded by LeaveEventDef/LeaveClassEvent (Change 29); retained for backward compatibility | ADR-TA-002 hybrid accrual |
| `CarryoverRule` | Year-end balance treatment configuration | Carryover max and expiry dates configurable per leave type |
| `TerminationBalanceRecord` | Immutable snapshot of all balances at termination | Created exactly once; policy action executed asynchronously |
| `LeaveInstantDetail` | Sub-bucket balance detail per tranche/expiry date for FEFO precision | Linked to LeaveInstant; append-only tranche records |
| `LeaveEventDef` | Typed event catalog for the leave event engine (Change 29) | Event type must be one of: ACCRUAL, CARRY, EXPIRE, RESET_LIMIT, BOOK_HOLD, START_POST, ADJUST |
| `LeaveClassEvent` | N:N mapping connecting LeaveClass to applicable LeaveEventDef with qty_formula (Change 29) | qty_formula must be valid formula expression; evaluated at runtime |
| `LeaveEventRun` | Idempotent execution record per event-class-period; replaces AccrualBatchRun (Change 29) | One record per (event_def_id, leave_class_id, period_id); idempotent re-run |
| `ClassPolicyAssignment` | Binding of LeaveClass to LeavePolicy with priority ordering | Priority ordering must be contiguous; no gaps |
| `TeamLeaveLimit` | Maximum concurrent absence headcount limit per team/leave type | Limit ≥ 1; enforced at reservation time |

### Top 10 Domain Events

| Event ID | Event Name | Significance |
|----------|------------|-------------|
| E-ABS-001 | LeaveRequestSubmitted | Initiates the leave lifecycle; triggers balance reservation |
| E-ABS-004 | LeaveRequestApproved | Final approval; reservation converts to deduction on leave start |
| E-ABS-006 | LeaveRequestCancelled | Full balance restoration; triggered pre- or post-deadline |
| E-ABS-007 | LeaveBalanceReserved | FEFO reservation applied; prevents overbooking |
| E-ABS-008 | LeaveBalanceDeducted | Immutable ledger entry; actual leave taken |
| E-ABS-009 | LeaveAccrualProcessed | Monthly batch; creates EARN movements per AccrualPlan / LeaveEventRun |
| E-ABS-010 | LeaveCarryoverExecuted | Year-end batch; creates carryover movements |
| E-ABS-011 | LeaveBalanceExpired | Expiry action triggered (extension / cashout / forfeiture) |
| E-ABS-018 | CancellationRequestSubmitted | H-P0-001: post-deadline cancellation route initiated |
| E-ABS-024 | TerminationBalanceSnapshotCreated | H-P0-004: all balances snapshotted; triggers termination policy |

### Invariants

1. **Immutable ledger (ADR-TA-001):** `LeaveMovement` records are append-only. Balance is always computed from the movement stream, never from a stored counter.
2. **Balance formula:** `available = earned - used - reserved`. Available balance may not go negative unless `allow_advance_leave = true` on LeaveType.
3. **FEFO reservation:** Reservations and deductions consume earliest-expiring balance first.
4. **Cancellation deadline (H-P0-001):** `LeaveType.cancellation_deadline_days` is tenant-configurable. Self-cancel is permitted before the deadline; manager approval is required after.
5. **VLC floors:** Annual leave policy entitlement cannot be set below 14 days (Vietnam Labor Code 2019, Article 113).

### External Triggers

| Trigger | Source | Action in ta.absence |
|---------|--------|----------------------|
| `EmployeeHired` | Employee Central (via ta.shared) | AssignLeavePolicy; create initial LeaveInstant records |
| `EmployeeTransferred` | Employee Central (via ta.shared) | Re-evaluate LeavePolicy; adjust entitlements |
| `EmployeeTerminated` | Employee Central (via ta.shared) | CreateTerminationSnapshot; execute H-P0-004 policy |
| `HolidayCalendarPublished` | ta.shared | Update working-day exclusions for leave duration calculation |
| `PeriodClosed` | ta.shared | Finalize leave deductions; contribute to PayrollExportPackage |

### Outputs

| Output | Target | Contents |
|--------|--------|----------|
| `PayrollExportPackage` (leave component) | Payroll Module | Approved leave by type, balance encashments, negative balance records |
| Domain events (24 events) | Analytics Platform | Full event stream |

---

## ta.attendance — Time & Attendance

### Core Aggregates

| Aggregate | Responsibility | Invariants |
|-----------|----------------|------------|
| `Punch` | Immutable clock-in or clock-out event | One active clock-in per employee at any time; no raw biometric; immutable after submission |
| `WorkedPeriod` | Computed worked time between paired punches | Pair must exist (IN + OUT); break deductions applied per shift |
| `AttendanceRecord` | Daily attendance summary per employee derived from punches and GeneratedRoster | One per employee per date; reconciled against GeneratedRoster from ta.scheduling |
| `TimeException` | Flagged deviation from scheduled shift (late-in, early-out, absent, unscheduled OT) | Linked to AttendanceRecord; requires manager acknowledgement or auto-resolution rule |
| `OvertimeRequest` | Pre-approval OT authorization | Monthly cap 40h; annual cap 200h/300h; no self-approval (H-P0-003) |
| `CompTimeBalance` | Compensatory time balance via movement records | Expiry action configurable: EXTENSION / AUTO_CASHOUT / FORFEITURE (H-P0-002) |
| `Timesheet` | Period-level aggregation of worked hours | One per employee per period; locked on approval; corrections require HR auth |
| `EvalRule` | Configurable rule defining how raw punch pairs are evaluated into attendance outcomes | Rules are tenant-configurable; evaluated in priority order |
| `EvalResult` | Output of EvalRule application for a specific AttendanceRecord | Immutable once computed; recomputed only on explicit recalculation request |
| `ShiftSwapRequest` | Employee-initiated request to swap scheduled shifts with a peer | Both parties must confirm; swap must not violate VLC Art. 109 rest period |
| `OpenShiftPool` | Manager-published available shifts that employees can volunteer for | Pool shifts have claim deadline; first-claim or manager-select modes |

### Top 10 Domain Events

| Event ID | Event Name | Significance |
|----------|------------|-------------|
| E-ATT-001 | EmployeeClockIn | Initiates punch pair; validates no duplicate active clock-in |
| E-ATT-002 | EmployeeClockOut | Closes punch pair; triggers worked period calculation |
| E-ATT-006 | OvertimeRequested | Pre-approval OT; triggers skip-level routing if manager submitting |
| E-ATT-007 | OvertimeApproved | Approves OT; triggers comp time accrual if elected |
| E-ATT-010 | CompTimeAccrued | Comp time earned; H-P0-002 expiry tracking begins |
| E-ATT-015 | GeofenceViolation | Punch outside registered work location; flags for manager review |
| E-ATT-017 | TimesheetSubmitted | Period-end submission; initiates approval workflow |
| E-ATT-018 | TimesheetApproved | Locks timesheet; contributes data to PayrollExportPackage |
| E-ATT-024 | CompTimeExpiryWarning | H-P0-002: N days warning before comp time expires |
| E-ATT-025 | CompTimeExpired | H-P0-002: expiry action executed (extension/cashout/forfeiture) |

### Invariants

1. **Immutable punch (ADR-TA-001 applied to attendance):** Punch records cannot be updated. Corrections use a separate CorrectionRequest that creates compensating records.
2. **No raw biometric (ADR-TA-004):** `Punch.biometric_token_ref` stores provider token only. No fingerprint image, template, or biometric data stored in xTalent.
3. **OT cap enforcement:** Approval of an OT request that would exceed VLC caps requires an explicit documented override. The override is logged in the compliance audit trail.
4. **No self-approval (H-P0-003):** When the OT submitter is the Level 1 approver, the routing engine automatically applies skip-level routing to the next-level manager.
5. **Timesheet lock:** Once a Timesheet transitions to APPROVED, all edits are blocked. Post-approval corrections require HR-authorized CorrectionRequest.
6. **Roster read-only:** ta.attendance consumes `GeneratedRoster` from ta.scheduling as read-only. Attendance evaluation derives expected shift from the roster; it never modifies or recalculates schedule data.

### External Triggers

| Trigger | Source | Action in ta.attendance |
|---------|--------|-------------------------|
| `PunchEventReceived` | Biometric Device | ProcessBiometricPunch; create Punch with token ref only |
| `RosterPublished` | ta.scheduling | Refresh GeneratedRoster cache; re-evaluate pending AttendanceRecords |
| `HolidayCalendarPublished` | ta.shared | Update OT rate categories for upcoming holidays |
| `PeriodClosed` | ta.shared | Lock all Timesheets in APPROVED; contribute to PayrollExportPackage |

### Outputs

| Output | Target | Contents |
|--------|--------|----------|
| `PayrollExportPackage` (attendance component) | Payroll Module | Worked hours by category, OT by rate category, comp time cash-outs |
| Domain events (26 events) | Analytics Platform | Full event stream |

---

## ta.scheduling — Schedule Management

### Core Aggregates

| Aggregate | Responsibility | Invariants |
|-----------|----------------|------------|
| `TimeSegment` | Atomic time block definition (e.g., Morning Block 06:00–14:00) | start_time < end_time; no overlap within the same DayModel |
| `ShiftDef` | Named shift composed of one or more TimeSegments with break rules | At least one TimeSegment per shift; total break time < total shift duration |
| `DayModel` | Day-level schedule template composed of ShiftDef slots | One DayModel per day-type; slot order must be contiguous |
| `PatternTemplate` | Repeating cycle of DayModels (e.g., 5-day rolling week pattern) | Cycle length ≥ 1 day; covers all days in cycle without gaps |
| `ScheduleAssignment` | Binds a PatternTemplate to an eligibility_profile_id for a date range (Change 30) | No overlapping assignments for the same eligibility profile; assignment date range must be within active period |
| `GeneratedRoster` | Materialized per-employee daily schedule generated from ScheduleAssignment + PatternTemplate | One record per (employee_id, date); immutable once published; override via ScheduleOverride |
| `ScheduleOverride` | One-off deviation from GeneratedRoster for a specific employee-date | References original GeneratedRoster entry; creates audit trail; approved by manager |

### Top Domain Events

| Event ID | Event Name | Significance |
|----------|------------|-------------|
| E-SCH-001 | PatternTemplatePublished | New or updated pattern template activated; triggers roster regeneration for affected assignments |
| E-SCH-002 | ScheduleAssignmentCreated | Eligibility profile bound to pattern; triggers roster generation for coverage period |
| E-SCH-003 | RosterGenerated | GeneratedRoster materialized for a date range; published to ta.attendance |
| E-SCH-004 | RosterPublished | Roster made visible to employees; triggers notifications |
| E-SCH-005 | ScheduleOverrideApproved | One-off deviation recorded; ta.attendance cache invalidated for affected employee-date |
| E-SCH-006 | ShiftSwapApproved | Peer shift swap confirmed; GeneratedRoster records swapped; rest-period validated |

### Invariants

1. **Roster immutability:** A published `GeneratedRoster` entry is immutable. Deviations are recorded as `ScheduleOverride`, which creates a new effective record while preserving the original.
2. **No schedule recalculation in ta.attendance:** ta.attendance reads roster data only. Any schedule change must originate in ta.scheduling and be propagated via `RosterPublished` event.
3. **Rest period compliance:** `ScheduleOverride` and shift swap operations must validate that the resulting schedule does not violate the VLC Article 109 minimum 8-hour rest period between shifts.
4. **Eligibility-driven assignment (Change 30):** `ScheduleAssignment` binds to `eligibility_profile_id`, not to direct employee/group FKs. Eligibility is resolved at roster generation time by the Core Eligibility engine.
5. **Holiday substitution:** When a DayModel falls on a public holiday (per HolidayCalendar), the holiday substitution rule on the PatternTemplate determines whether the day is treated as rest, OT, or substituted to another date.

### External Triggers

| Trigger | Source | Action in ta.scheduling |
|---------|--------|-------------------------|
| `EmployeeHired` | Employee Central (via ta.shared) | Evaluate eligibility profiles; generate initial roster if assignment exists |
| `EmployeeTransferred` | Employee Central (via ta.shared) | Re-evaluate eligibility; regenerate roster for new assignment |
| `HolidayCalendarPublished` | ta.shared | Re-evaluate holiday substitution rules; regenerate affected roster entries |
| `EligibilityProfileUpdated` | Core Module (Eligibility Engine) | Recompute affected ScheduleAssignments; regenerate impacted GeneratedRoster records |

### Outputs

| Output | Target | Contents |
|--------|--------|----------|
| `GeneratedRoster` (read-only published language) | ta.attendance | Per-employee daily scheduled shift for punch validation and attendance evaluation |
| Domain events (6+ events) | Analytics Platform | Roster and schedule change event stream |

---

## ta.shared — Shared Services

### Core Aggregates

| Aggregate | Responsibility | Invariants |
|-----------|----------------|------------|
| `Period` | Payroll period lifecycle and state machine | Only one OPEN period per tenant; OPEN → LOCKED → CLOSED (no reversal); close requires all timesheets APPROVED |
| `HolidayCalendar` | Country-specific public holiday definitions | Vietnam: 11 statutory holidays; country_code required on all records |
| `ApprovalChain` | Dynamic multi-level approval routing engine | Skip-level applied when submitter = Level 1 approver; escalation on timeout |
| `ApprovalTask` | Individual approval unit within a chain | One active task per level per request; completed task is immutable |
| `Notification` | Event-triggered message dispatch | Push + email channels; retry on primary channel failure |
| `PayrollExportPackage` | Period-close export to Payroll module | Idempotent; re-run produces identical package; period metadata immutable |
| `TenantConfig` | Tenant-level policy configuration | Changes to cancellation deadline, comp time expiry, termination policy require explicit admin confirmation; changes not retroactive |
| `PeriodProfile` | Configurable period boundary template (week start, month boundary, custom fiscal period) | One active profile per tenant per period type; changes apply from next period only |

### Top 8 Domain Events

| Event ID | Event Name | Significance |
|----------|------------|-------------|
| E-SHD-001 | PeriodOpened | Starts new payroll period; activates timesheet collection |
| E-SHD-002 | PeriodClosed | Triggers PayrollExport; locks all timesheets |
| E-SHD-004 | PayrollExportGenerated | Idempotent export; delivered to Payroll module |
| E-SHD-006 | HolidayCalendarPublished | Propagated to ta.absence, ta.attendance, and ta.scheduling for calculations |
| E-SHD-009 | ApprovalTaskEscalated | Timeout-based escalation; creates new task for escalation target |
| E-SHD-012 | EmployeeHireIntegrated | ACL translation complete; normalized event re-published to ta.absence |
| E-SHD-014 | EmployeeTerminationIntegrated | H-P0-004: triggers TerminationBalanceSnapshot in ta.absence |
| E-SHD-016 | TenantPolicyUpdated | H-P0-001/002/004 configuration changes audited; effective for new requests only |

### Invariants

1. **Period state machine:** OPEN → LOCKED → CLOSED. Transitions are irreversible. A period can only close when all Timesheets within it are in APPROVED status.
2. **Single open period:** Only one Period per tenant may have status OPEN at any time.
3. **Idempotent export:** PayrollExportPackage generation is idempotent — re-running on the same closed period produces byte-identical output.
4. **Approval routing:** ApprovalChain is evaluated dynamically at request submission time, not at configuration time. This allows org chart changes to take effect immediately for new requests.
5. **Policy change non-retroactivity:** Changes to TenantConfig (cancellation deadline, comp time expiry action, termination policy) apply only to requests created after the change.

### Integration — Orchestration Role

ta.shared orchestrates the cross-context period-close sequence:

```
PeriodCloseRequested
    │
    ├─ Validate: all Timesheets APPROVED (ta.attendance)
    ├─ Validate: no pending LeaveRequests within period (ta.absence)
    │
    ├─ [on validation pass] ClosePeriod → E-SHD-002: PeriodClosed
    │       │
    │       ├─ GeneratePayrollExport → E-SHD-004 (aggregates from both contexts)
    │       └─ DeliverPayrollExport → E-SHD-005
    │
    └─ [on validation fail] → E-SHD-003: PeriodClosureBlocked
```

---

## Cross-Cutting Concerns

### Multi-Tenancy

- `tenant_id` is required on every root aggregate across all three contexts.
- Row-level tenant isolation is the default for MVP (H9 — architecture decision deferred to Step 4).
- All queries include `WHERE tenant_id = :tenant_id` predicates.

### Audit Trail

- All state-changing domain events are immutable and timestamped.
- LeaveMovement and Punch records are append-only (ADR-TA-001).
- TenantConfig changes are audited with before/after values and acting user ID.

### Vietnam Compliance Hooks

| VLC Article | Context | Enforcement Mechanism |
|------------|---------|----------------------|
| Article 107 (OT caps) | ta.attendance | OvertimeRequest hard-blocks at cap; override requires documentation |
| Article 109 (rest period) | ta.scheduling, ta.attendance | ScheduleOverride and ShiftSwap validator; block if < 8h rest |
| Article 113 (annual leave) | ta.absence | LeavePolicy minimum floor = 14 days; system rejects lower values |
| Article 114 (sick leave) | ta.absence | evidence_required flag + grace_period_days on LeaveType |
| Article 139 (maternity) | ta.absence | Pre-configured MATERNITY leave type (Phase 2 detailed rules) |
| Article 21 (termination deduction consent) | ta.absence + ta.shared | H-P0-004: written consent required before payroll deduction |
| Article 98 (OT rates) | ta.attendance | OT rate category enum (WEEKDAY/WEEKEND/HOLIDAY) on OvertimeRequest |

### Architecture Questions Deferred to Step 4

| ID | Question | Impact on Domain Model |
|----|----------|----------------------|
| H8: Offline-First | Mobile punch without connectivity | `Punch.sync_status` (PENDING/SYNCED/CONFLICT) is defined in domain; conflict resolution rules are architecture-level |
| H9: Multi-Tenancy Isolation | Row vs. schema vs. database level | `tenant_id` on all aggregates is the domain contract; physical isolation is deployment architecture |
| H10: Data Residency | Vietnam data physical isolation | `data_region` attribute reserved; cloud region assignment is infrastructure decision |

---

## 8. Commands Catalog

The following catalogs enumerate all domain commands across the bounded contexts, mapping each command to its actor and resulting event. Total: **32 commands** (existing contexts; ta.scheduling commands TBD in detail design).

### 8.1 TA.Absence Commands (12)

| Command | Actor | Result Event |
|---------|-------|-------------|
| `SubmitLeaveRequest` | Employee | `LeaveRequestSubmitted` |
| `ValidateLeaveRequest` | System | `LeaveRequestValidated` |
| `ApproveLeaveRequest` | Manager / HR Admin | `LeaveRequestApproved` |
| `RejectLeaveRequest` | Manager | `LeaveRequestRejected` |
| `CancelLeaveRequest` | Employee (pre-deadline) | `LeaveRequestCancelled` |
| `RequestCancellationApproval` | Employee (post-deadline) | `CancellationRequested` |
| `ApproveCancellation` | Manager | `LeaveRequestCancelled` |
| `ReserveBalance` | System (on approval) | `LeaveBalanceReserved` |
| `DeductBalance` | System (on leave date) | `LeaveBalanceDeducted` |
| `RestoreBalance` | System (on cancellation) | `LeaveBalanceRestored` |
| `ProcessAccrual` | Accrual Engine (batch) | `LeaveAccrualProcessed` |
| `ExecuteCarryover` | System (year-end) | `LeaveCarryoverExecuted` |

### 8.2 TA.Attendance Commands (13)

| Command | Actor | Result Event |
|---------|-------|-------------|
| `ClockIn` | Employee (web/mobile/biometric) | `EmployeeClockedIn` |
| `ClockOut` | Employee (web/mobile/biometric) | `EmployeeClockedOut` |
| `RequestShiftSwap` | Employee | `ShiftSwapRequested` |
| `ApproveShiftSwap` | Manager | `ShiftSwapped` |
| `RequestOvertime` | Employee | `OvertimeRequested` |
| `ApproveOvertime` | Manager | `OvertimeApproved` |
| `RejectOvertime` | Manager | `OvertimeRejected` |
| `SubmitTimesheet` | Employee | `TimesheetSubmitted` |
| `ApproveTimesheet` | Manager | `TimesheetApproved` |
| `CreateGeofence` | HR Admin / System Admin | `GeofenceConfigured` |
| `ValidateLocation` | System (on clock-in) | `GeofenceViolation` / pass |
| `EvaluateAttendance` | System (batch/triggered) | `AttendanceRecordEvaluated` |
| `AcknowledgeException` | Manager | `TimeExceptionAcknowledged` |

### 8.3 TA.Shared Commands (7)

| Command | Actor | Result Event |
|---------|-------|-------------|
| `OpenPeriod` | Payroll Officer / HR Admin | `PeriodOpened` |
| `ClosePeriod` | Payroll Officer / HR Admin | `PeriodClosed` |
| `CreateHoliday` | HR Admin | `HolidayCreated` |
| `CreateApprovalChain` | HR Admin | `ApprovalChainCreated` |
| `EscalateApproval` | System (on timeout) | `EscalationTriggered` |
| `SendNotification` | System | `NotificationSent` |
| `ExportToPayroll` | System (on period close) | `PayrollExported` |

### 8.4 TA.Scheduling Commands (6)

| Command | Actor | Result Event |
|---------|-------|-------------|
| `PublishPatternTemplate` | HR Admin / Schedule Manager | `PatternTemplatePublished` |
| `CreateScheduleAssignment` | HR Admin / Schedule Manager | `ScheduleAssignmentCreated` |
| `GenerateRoster` | System (batch/triggered) | `RosterGenerated` |
| `PublishRoster` | Schedule Manager | `RosterPublished` |
| `RequestScheduleOverride` | Manager | `ScheduleOverrideRequested` |
| `ApproveScheduleOverride` | HR Admin / Manager | `ScheduleOverrideApproved` |

---

## 9. Shared Kernel

### 9.1 Shared Value Objects

| Value Object | Used By | Description |
|--------------|---------|-------------|
| `DateRange` | Absence, Attendance, Shared, Scheduling | Start date + end date with working-day computation |
| `PeriodRange` | Shared, Attendance | Payroll period boundaries with open/close status |
| `BalanceAmount` | Absence | Available, pending-reservation, used, total in days/hours |
| `Timestamp` | Attendance, Shared | Precise time record with timezone; immutable |
| `Location` | Attendance | GPS coordinates + accuracy radius; used for geofence validation |
| `TenantScope` | All contexts | `tenant_id` + `data_region`; on every aggregate root |

### 9.2 Shared Enums

| Enum | Values | Used By |
|------|--------|---------|
| `LeaveRequestStatus` | `DRAFT`, `SUBMITTED`, `UNDER_REVIEW`, `APPROVED`, `REJECTED`, `CANCELLATION_REQUESTED`, `CANCELLED` | TA.Absence |
| `PunchSource` | `WEB`, `MOBILE_APP`, `BIOMETRIC_DEVICE`, `TERMINAL` | TA.Attendance |
| `PunchType` | `IN`, `OUT` | TA.Attendance |
| `PunchSyncStatus` | `PENDING`, `SYNCED`, `CONFLICT` | TA.Attendance (H8) |
| `OTStatus` | `PENDING`, `APPROVED`, `REJECTED`, `CONVERTED_TO_COMP` | TA.Attendance |
| `PeriodStatus` | `OPEN`, `LOCKED`, `CLOSED`, `REOPENED` | TA.Shared |
| `ApprovalDecision` | `APPROVED`, `REJECTED`, `ESCALATED`, `DELEGATED` | TA.Shared |
| `PartialDayMode` | `FULL_DAY_ONLY`, `HALF_DAY`, `HOURLY` | TA.Absence (H-P1-001) |
| `LeaveEventType` | `ACCRUAL`, `CARRY`, `EXPIRE`, `RESET_LIMIT`, `BOOK_HOLD`, `START_POST`, `ADJUST` | TA.Absence (Change 29) |
| `RosterStatus` | `DRAFT`, `PUBLISHED`, `OVERRIDDEN`, `ARCHIVED` | TA.Scheduling |

---

## 10. Anti-Pattern Checks

### 10.1 God Context

| Check | Status | Evidence |
|-------|--------|----------|
| No context exceeds 20 entities | ✅ PASS | Max 20 entities in TA.Absence (expanded with event engine) |
| No context handles multiple unrelated capabilities | ✅ PASS | Each context has single bounded responsibility |
| No context has excessive events (>25) | ✅ PASS | Max 18 events in TA.Absence |

### 10.2 Anemic Domain Model

| Check | Status | Evidence |
|-------|--------|----------|
| Aggregates have defined invariants | ✅ PASS | 21 invariants documented across 4 contexts (Section 3–6) |
| Business logic lives in domain, not services | ✅ PASS | All policies and rules are domain-owned and configurable |
| Entities have behavior, not just data | ✅ PASS | Each context has command catalog mapping behavior to actors |

### 10.3 Context Overlap

| Check | Status | Evidence |
|-------|--------|----------|
| No duplicate aggregates across contexts | ✅ PASS | Unique aggregate roots per context; no shared mutable aggregates |
| Shared concepts isolated in Shared context | ✅ PASS | `Period`, `ApprovalChain`, `HolidayCalendar` owned by TA.Shared only |
| Clear entity ownership | ✅ PASS | Ownership table in sections 3.x.2 |
| Scheduling separated from attendance | ✅ PASS | ta.scheduling owns roster generation; ta.attendance consumes read-only |

---

## 11. Policy Entities Summary

| Policy Entity | Owning Context | Configuration Level | Hot Spots Resolved |
|---------------|---------------|--------------------|--------------------|
| `LeavePolicy` | TA.Absence | Tenant / BU / Legal Entity | H-P0-001 (cancellation), H-P1-001 (partial day) |
| `CompTimePolicy` | TA.Absence | Tenant / BU | H-P0-002 (comp time expiry) |
| `OvertimePolicy` | TA.Attendance | Tenant / BU / Legal Entity | H-P1-006 (OT pre-approval) |
| `ShiftSwapPolicy` | TA.Attendance | Tenant / BU | H-P1-002 (swap violation) |
| `BiometricPolicy` | TA.Attendance | Tenant | H-P1-003 (offline mode) |
| `SickLeavePolicy` | TA.Absence | Tenant / BU | H-P1-004 (certificate exception) |
| `HolidayPolicy` | TA.Shared | Tenant / Legal Entity | H-P1-007 (holiday on weekend) |
| `TerminationPolicy` | TA.Shared | Tenant / Legal Entity | H-P0-004 (negative balance at termination) |
| `ApprovalChain` | TA.Shared | Tenant / Role | H-P0-003 (manager OT approval), H-P1-008 (delegation) |
| `PatternTemplate` | TA.Scheduling | Tenant / Department | Schedule rotation and holiday substitution rules |

All policy entities implement the **Configurable Policy Framework** (see Step 1 Pre-Reality, Section 13.3). Each entity exposes tenant/BU-level overrides via HR Admin UI without code changes.

---

## 12. Domain Metrics Summary

| Metric | TA.Absence | TA.Attendance | TA.Scheduling | TA.Shared | Total |
|--------|------------|---------------|---------------|-----------|-------|
| Aggregates | ~7 | ~6 | 4 | 3 | **~20** |
| Entities (incl. root) | ~20 | ~14 | 10 | 10 | **~54** |
| Domain Events | 18 | 17 | 6 | 12 | **53** |
| Commands | 12 | 13 | 6 | 7 | **38** |
| Business Rules | 8 | 8 | 5 | 6 | **27** |
| Invariants | 5 | 6 | 5 | 5 | **21** |
| Policy Entities | 2 | 3 | 1 | 4 | **10** |

---

## 13. Architecture Decision Records

| ADR ID | Decision | Status | Rationale |
|--------|----------|--------|-----------|
| ADR-TA-001 | Immutable ledger for LeaveMovement and Punch | ACCEPTED | Audit completeness; balance computed from stream, never stored counter |
| ADR-TA-002 | Hybrid accrual model (daily + monthly batch) | ACCEPTED | Balances real-time accuracy needs against batch efficiency |
| ADR-TA-003 | Biometric token reference only (no raw data) | ACCEPTED | Privacy compliance; VLC Article 8 personal data minimization |
| ADR-TA-004 | Row-level multi-tenancy for MVP | DEFERRED | Schema/database isolation deferred to Step 4 (H9) |
| ADR-TA-005 | Centralized eligibility engine for schedule and leave class assignment (Change 30) | ACCEPTED | Replaces direct employee_id/employee_group_id FKs; prevents stale assignments after org changes; eligibility resolved at runtime by Core module |
| ADR-TA-006 | Generalized leave event engine replacing hardcoded accrual (Change 29) | ACCEPTED | LeaveEventDef/LeaveClassEvent/LeaveEventRun model generalizes beyond accrual to any leave lifecycle operation; new event types addable without code changes |
| ADR-TA-007 | Explicit TA→Payroll time type mapping (Change 26) | ACCEPTED | ta.attendance maps evaluated time buckets (regular, OT-weekday, OT-weekend, OT-holiday, comp-earned, comp-cashed) to Payroll pay element codes via configurable mapping table; prevents implicit coupling |

---

**Document Control:**
- **Version:** 1.2
- **Last Updated:** 2026-04-03 (added ta.scheduling bounded context; Centralized Eligibility Engine Change 30; Leave Event Engine Change 29; updated ta.attendance and ta.absence aggregates; expanded ADR table; updated Domain Metrics Summary)
- **Status:** READY FOR GATE G3 REVIEW
