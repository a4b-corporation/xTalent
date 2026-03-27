# Timesheet Submission — ATT-T-004

**Classification:** Transaction (T — Period-based workflow with multi-role approval)
**Priority:** P0
**Primary Actor:** Employee (submit); Manager (approve); Payroll Officer (view + period lock)
**Secondary Actors:** HR Admin (override), System (auto-lock on period close)
**Workflow States:** DRAFT → SUBMITTED → APPROVED / RETURNED → LOCKED
**API:** `GET /attendance/timesheets/{periodId}`, `POST /attendance/timesheets/{periodId}/submit`, `POST /attendance/timesheets/{periodId}/approve`, `POST /attendance/timesheets/{periodId}/reject`
**User Story:** US-ATT-005
**BRD Reference:** BRD-ATT-003
**Hypothesis:** H1, H3

---

## Purpose

Timesheet Submission closes the loop between daily clock-in/out data and the official record of hours worked each pay period. Employees review and confirm their timesheet, which is a consolidated view of regular hours, OT, and leave for the month. Managers review team timesheets and approve before the period locks. Payroll Officer depends on approved timesheets to run payroll. The feature must clearly communicate deadlines and block submission of incomplete timesheets.

---

## State Machine

```mermaid
stateDiagram-v2
    [*] --> DRAFT : Period opens; timesheet auto-created from punch data
    DRAFT --> SUBMITTED : Employee submits timesheet
    SUBMITTED --> UNDER_REVIEW : Manager opens timesheet
    UNDER_REVIEW --> APPROVED : Manager approves
    UNDER_REVIEW --> RETURNED : Manager returns for correction
    RETURNED --> DRAFT : Employee corrects and resubmits
    DRAFT --> LOCKED : Period close date reached; auto-lock (unsubmitted)
    SUBMITTED --> LOCKED : Period close date reached; auto-lock (submitted, not approved)
    APPROVED --> LOCKED : Period close triggered by Payroll Officer (SHD-T-002)
    LOCKED --> [*] : Timesheet immutable; payroll export generated
```

---

## Screens and Steps

### Screen 1: My Timesheets — Period List

**Route:** `/attendance/timesheets`

**Entry points:**
- Employee → Attendance → Timesheets
- Manager → Attendance → Team Timesheets
- Payroll Officer → Period Management

**Layout:**

```
My Timesheets
─────────────────────────────────────────────────────────────────
Period          Regular Hrs  OT Hrs  Leave Hrs  Status      Action
─────────────────────────────────────────────────────────────────
March 2026      160h         12.5h   16h        DRAFT       [Submit]
                                                ⏰ Closes Apr 5
February 2026   152h         5.0h    24h        APPROVED    [View]
January 2026    160h         0h      8h         LOCKED      [View]
─────────────────────────────────────────────────────────────────
```

- Period rows sorted newest first
- Status badge colors: DRAFT (grey), SUBMITTED (blue), APPROVED (green), RETURNED (amber), LOCKED (dark grey)
- "Closes [date]" warning: shown for DRAFT/RETURNED periods; turns red if closing within 3 days
- Action: "Submit" (DRAFT/RETURNED), "View" (SUBMITTED/APPROVED/LOCKED)

---

### Screen 2: Timesheet Detail View (Employee)

**Route:** `/attendance/timesheets/{periodId}`

**Entry points:**
- Period list → click any period or "Submit" action

**Status Banner (sticky top):**

```
[DRAFT] Period: March 2026
⏰ Submit by April 5, 2026 (11 days remaining)
```
- Changes to red when ≤ 3 days remain: "⚠ Submit by April 5 — 2 days remaining!"
- LOCKED state: "🔒 This period is locked. No changes are possible."
- RETURNED state: "⚠ Returned by [Manager Name]: '[return comment]' — Please review and resubmit."

**Layout — Weekly Calendar Grid:**

Week tabs across top (e.g., "Mar 1-7", "Mar 8-14", etc.)
Each day in the active week shown as a column:

```
         Mon 3    Tue 4    Wed 5    Thu 6    Fri 7    Sat 8    Sun 9
Regular  8.0h     8.0h     8.0h     8.0h     8.0h     —        —
OT       1.5h     0.0h     2.5h     0.0h     0.0h     4.0h(2x) —
Leave    0.0h     0.0h     0.0h     0.0h     0.0h     —        —
Holiday  —        —        —        —        —        —        —
─────────────────────────────────────────────────────────────────
Daily    9.5h     8.0h     10.5h    8.0h     8.0h     4.0h     —
```

**Color coding (per cell background):**
- Regular hours: blue tint
- OT hours: orange tint
- Leave hours: green tint
- Public holiday: yellow tint
- Missing data (no clock-in): red tint with "Missing" label

**Period totals row (shown below the weekly grid, always visible):**

```
Period Summary — March 2026
─────────────────────────────────────────
Regular hours:     160.0 h
OT hours:           27.5 h  (150%: 12h, 200%: 8h, 300%: 7.5h)
Leave hours:        16.0 h  (Annual Leave: 16h)
Total hours:       203.5 h
─────────────────────────────────────────
Days with missing data:  0  ✅
All days accounted for:  ✅ Ready to submit
─────────────────────────────────────────
```

**Submit Button:**
- Enabled only when: period is DRAFT or RETURNED AND "Days with missing data: 0"
- Disabled + tooltip: "X days have missing clock data. Contact HR to resolve before submitting."
- Disabled + tooltip: "Period is [SUBMITTED/LOCKED]. No further action needed."

---

### Step 3: Submit Confirmation Modal

Triggered by clicking "Submit":

```
Submit Timesheet for March 2026?

Summary:
  Regular Hours:  160.0 h
  OT Hours:        27.5 h
  Leave Hours:     16.0 h
  Total:          203.5 h

Once submitted, your timesheet will be sent to
[Manager Name] for approval.

[ Cancel ]   [ Submit Timesheet ]
```

On confirm: POST /attendance/timesheets/{periodId}/submit
On success: status updates to SUBMITTED; Manager notified

---

### Screen 4: Manager — Team Timesheets View

**Route:** `/attendance/timesheets/team`

**Entry points:**
- Manager → Attendance → Team Timesheets
- SHD-T-006 Approval Dashboard → Timesheets tab

**Layout:**

Header: "Team Timesheets — [Current Period]" + period selector

```
Employee          Regular  OT     Leave  Submitted   Status       Action
────────────────────────────────────────────────────────────────────────
Nguyen Van A      160h     12.5h  16h    Mar 28      SUBMITTED    [Review]
Tran Thi B        160h     0h     24h    Mar 25      SUBMITTED    [Review]
Le Van C          152h     5h     8h     —           DRAFT        —
Pham Thi D        160h     0h     0h     Mar 20      APPROVED     [View]
────────────────────────────────────────────────────────────────────────
  Pending approval: 2    Approved: 1    Draft: 1
```

**Bulk Approve:**
- Checkboxes on each SUBMITTED row
- "Approve Selected ([N])" button at top: triggers bulk approval with single confirmation modal
- Confirmation: "Approve timesheets for [N] employees for [period]? This action cannot be undone."

---

### Screen 5: Manager — Timesheet Approval / Return

**Route:** `/attendance/timesheets/{periodId}/review?employee={employeeId}`

**Entry points:**
- Team timesheets list → "Review" action

**Layout:**
- Same calendar grid view as Screen 2 (Employee view), but read-only
- Employee summary panel on right/top: name, position, department, total hours, OT usage vs cap
- Approval chain: shows current approver (this manager), shows if further levels exist

**Action bar:**
- "Approve" button (primary, green) → confirmation modal
- "Return" button (secondary, outlined amber) → return dialog

**Return Dialog:**

```
Return Timesheet to Employee

Comment for employee (required):
[                                        ]
[                                        ]

The employee will be notified and can
resubmit after making corrections.

[ Cancel ]   [ Return Timesheet ]
```

---

## Notification Triggers

| Event | Recipient | Channel | Template |
|-------|-----------|---------|---------|
| Timesheet submitted | Employee | In-app | "Your timesheet for [period] has been submitted. Awaiting [Manager Name]'s approval." |
| Timesheet submitted | Manager | Push + Email | "Action required: [Employee Name]'s timesheet for [period] is ready for approval." |
| Timesheet approved | Employee | Push + In-app | "Your timesheet for [period] has been approved by [Manager Name]." |
| Timesheet returned | Employee | Push + In-app | "Your timesheet for [period] has been returned by [Manager Name]. Reason: [comment]. Please review and resubmit." |
| Period closing in 3 days | Employee (DRAFT) | Push + Email | "Your timesheet for [period] is due in 3 days (by [date]). Submit now to avoid auto-lock." |
| Period closing in 3 days | Employee (DRAFT) | Manager | Push + Email | "[N] of your team members have not submitted their timesheets for [period]. Period closes [date]." |
| Period auto-locked | Employee (DRAFT/SUBMITTED) | In-app | "The [period] period has been locked. Your timesheet has been locked in [DRAFT/SUBMITTED] status." |

---

## Error States

| Error | User Message | Recovery Action |
|-------|-------------|-----------------|
| Missing punch data for day(s) | "X day(s) have missing clock records. Submit is blocked until resolved." | HR Admin adds manual punch or HR exempts the day |
| Period already locked | "This period is locked and cannot be modified." | Payroll Officer or HR Admin can unlock in SHD-T-002 (with audit log) |
| Submission network failure | "Unable to submit timesheet. Draft preserved. Please try again." | Retry |
| Approval network failure | "Unable to save your decision. Please try again." | Retry; decision not lost |
| Bulk approve partial failure | "Approved [N] of [M] selected timesheets. [X] approvals failed — please retry those individually." | Retry failed items |

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-ATT-040 | Timesheet submission is blocked if any working day in the period has no punch record (no clock-in/out and no leave record) |
| BR-ATT-041 | Timesheets in DRAFT or SUBMITTED state are auto-locked when the period is closed via SHD-T-002; auto-lock does not require employee or manager action |
| BR-ATT-042 | Once LOCKED, timesheet data is immutable; any corrections must go through an HR Admin adjustment process (audit trail required) |
| BR-ATT-043 | OT hours in the timesheet are read from the OT calculation results (ATT-T-002); they are not directly editable by the employee |
| BR-ATT-044 | Leave hours in the timesheet are read from approved leave requests (ABS-T-001); they are not directly editable by the employee |

---

## Mobile Considerations

- On mobile: show month summary totals by default; weekly grid accessible via horizontal swipe tabs
- Submit button anchored to the bottom of the mobile screen (above navigation bar)
- Period closing warning banner is pinned at the top of the screen (not scrollable away) when ≤ 3 days remain
- Manager bulk approve is mobile-accessible: long-press to enter multi-select mode
