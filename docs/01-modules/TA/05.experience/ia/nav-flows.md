# Navigation Flows: Time & Absence

**Module:** xTalent HCM — Time & Absence
**Step:** 5 — Product Experience Design
**Date:** 2026-03-25
**Version:** 1.0

---

## Overview

Six primary navigation flows corresponding to the six core use-case flows from Step 3. Each flow uses a Mermaid `flowchart TD` diagram. Screen nodes use rectangles; decision points use diamonds; terminal states use rounded rectangles.

---

## Flow F1: Employee Submits Leave Request

**Persona:** Employee (mobile + web)
**Features:** ABS-T-001, ABS-T-004
**H5 note:** Calendar entry point available in P1

```mermaid
flowchart TD
    A([Employee opens app]) --> B[Home Dashboard\nLeave Balance widget]
    B --> C{Entry point?}
    C -->|Menu: Request Leave| D[Leave Request Form\nSelect leave type]
    C -->|Calendar date click P1| D
    D --> E[Select date range\nDate picker with\nholiday highlights]
    E --> F{Balance sufficient?}
    F -->|No| G[Error: Insufficient balance\nShow available vs requested\nSuggest shorter range]
    G --> E
    F -->|Yes| H[Enter optional reason\nAttach evidence if required]
    H --> I[Preview summary\nType / Dates / Days / Balance after]
    I --> J{Confirm?}
    J -->|Edit| D
    J -->|Submit| K[POST /leaves/requests]
    K --> L{API response}
    L -->|201 Created| M([Confirmation screen\nRequest ID + status: SUBMITTED\nPush notification sent])
    L -->|4xx error| N[Error state\nShow message\nRetry or save draft]
    M --> O[My Leave Requests list\nRequest visible with SUBMITTED status]
    O --> P([Manager notified via push])
```

---

## Flow F2: Manager Approves / Rejects Leave Request

**Persona:** Manager (web primary, mobile secondary)
**Features:** ABS-T-002, ABS-T-004, ABS-T-007
**H5 note:** Calendar overlay shows team availability in approval context

```mermaid
flowchart TD
    A([Manager receives push notification\nApproval request]) --> B{Opens from?}
    B -->|Notification CTA| C[Leave Request Detail\nEmployee info + dates + balance]
    B -->|Dashboard queue| D[Approvals → Leave Requests list]
    D --> C
    C --> E[View Team Calendar overlay\nH5: see who else is out on same dates]
    E --> F[Review employee context\nLeave type / Remaining balance / History]
    F --> G{Decision?}
    G -->|Approve| H[Confirmation dialog\n'Approve 3 days Annual Leave for Nguyen Van A?']
    G -->|Reject| I[Reject dialog\nRequired: reason field\nOptional: suggest alternative dates]
    G -->|Request more info| J[Comment and request info\nEmployee notified]
    H --> K[POST /leaves/requests/id/approve]
    I --> L[POST /leaves/requests/id/reject]
    K --> M{API response}
    L --> M
    M -->|Success| N([Status updated on request card\nEmployee notified via push\nBalance updated via SSE])
    M -->|Error| O[Error state\nRetry option]
    N --> P([Return to Approvals queue])
```

---

## Flow F3: Employee Cancels Approved Leave (H-P0-001 Deadline Branching)

**Persona:** Employee
**Features:** ABS-T-003
**H-P0-001:** Cancellation deadline check is the core branching logic in this flow

```mermaid
flowchart TD
    A([Employee → My Leave Requests]) --> B[Leave Request list\nFilter: Approved]
    B --> C[Select approved leave request]
    C --> D[Leave Request Detail\nShows: cancellation deadline prominently\nExample: 'Cancellable until 2026-04-04']
    D --> E{Before cancellation deadline?}

    E -->|Yes — self-cancel available| F[Cancel button enabled\nLabel: 'Cancel Leave']
    F --> G[Confirmation dialog\n'Cancel 3 days Annual Leave\nApr 7–9? Balance will be restored.']
    G --> H{Confirm?}
    H -->|Confirm| I[POST /leaves/requests/id/cancel]
    I --> J{API response}
    J -->|Success| K([Request status: CANCELLED\nBalance restored\nPush: 'Leave cancelled — 3 days restored'])
    J -->|Error| L[Error state\nRetry option]

    E -->|After deadline — manager approval required| M[Cancel button still visible\nLabel: 'Request Cancellation'\nWarning banner: 'Deadline has passed — manager approval required']
    M --> N[Enter cancellation reason\nRequired field]
    N --> O[POST /leaves/requests/id/cancel with approval_required flag]
    O --> P{API response}
    P -->|Success| Q([Status: CANCELLATION_REQUESTED\nManager notified\nEmployee: 'Cancellation request sent — awaiting manager approval'])
    P -->|Error| L

    Q --> R([Manager receives approval request\nApproves or Rejects cancellation\nEmployee notified of outcome])
```

---

## Flow F4: Employee Clocks In / Out (Mobile, H6 Offline Mode)

**Persona:** Employee (mobile)
**Features:** ATT-T-001, ATT-T-005
**H6:** Offline mode, sync status indicator, geofence handling

```mermaid
flowchart TD
    A([Employee opens mobile app\nClock tab]) --> B[Clock screen\nLarge hero button\nCurrent status: CLOCKED OUT]
    B --> C{Network available?}

    C -->|Online| D[Check geofence\nGPS coordinates vs configured zones]
    D --> E{Within geofence?}
    E -->|Yes — no warning| F[Biometric prompt P1 / PIN fallback]
    E -->|No — violation| G[Geofence warning banner\n'You are outside registered work location'\nPolicy: allow with flag or block]
    G --> H{Policy allows punch outside?}
    H -->|Block| I([Error: Cannot clock in outside work location\nContact your manager])
    H -->|Allow with flag| F

    F --> J{Biometric / PIN success?}
    J -->|Failure| K[Retry prompt / Use PIN fallback]
    K --> F
    J -->|Success| L[POST /attendance/punches\nOnline submission]
    L --> M{API response}
    M -->|201 Created| N([Clock screen updates\nStatus: CLOCKED IN\nTime: 09:03 AM\nSync indicator: SYNCED green check])
    M -->|Conflict detected| O([CONFLICT warning\nTwo overlapping punches\nHR will review])

    C -->|Offline| P[Offline mode detected\nIndicator: PENDING clock icon\nMessage: 'No connection — punch queued locally']
    P --> Q[Biometric / PIN prompt shown offline]
    Q --> R{Auth success?}
    R -->|Failure| K
    R -->|Success| S[Punch saved to local SQLite queue\nIdempotency key generated]
    S --> T([Clock screen updates\nStatus: CLOCKED IN\nSync indicator: PENDING clock icon])
    T --> U{Connection restored?}
    U -->|Yes| V[Auto-sync: POST /attendance/punches/sync-offline\nBackground process]
    V --> W{Sync result}
    W -->|Success| X([Sync indicator: SYNCED green check\nPunch record confirmed])
    W -->|Conflict| O
    U -->|Still offline| T
```

---

## Flow F5: Employee / Manager Requests and Approves Overtime (H-P0-003 Skip-Level Routing)

**Persona:** Employee submitting, Manager approving
**Features:** ATT-T-003
**H-P0-003:** When manager submits own OT, system routes to their manager (skip-level)

```mermaid
flowchart TD
    A([Employee / Manager → Overtime Requests → New]) --> B[OT Request Form\nDate / Duration / Purpose / Rate category]
    B --> C{Submitter is a Manager?}

    C -->|Yes — manager submitting own OT| D[System checks approval chain\nLevel 1 approver = same person as submitter]
    D --> E[Skip-level routing applied automatically\nInfo banner: 'This request will be reviewed by\n[Skip-level Manager Name]']
    E --> F[Submit OT Request]

    C -->|No — employee submitting| G[System checks approval chain\nLevel 1 approver = direct manager]
    G --> H{OT cap status?}
    H -->|Below 80% monthly cap| F
    H -->|Between 80–100% cap| I[Warning toast: 'You are at 82% of monthly OT cap'\nNon-blocking — can proceed]
    I --> F
    H -->|At 100% cap| J([Block: 'Monthly OT cap reached (40h)'\nRequest blocked until next period\nOR HR override required])

    F --> K[POST /attendance/overtime/requests]
    K --> L{API response}
    L -->|201 Created| M([OT request status: SUBMITTED\nApprover notified via push\nEmployee: 'OT request submitted'])
    L -->|Error| N[Error state\nRetry]

    M --> O([Approver opens notification → OT Request Detail])
    O --> P[View OT request details\nEmployee name / Date / Hours / Purpose\nEmployee monthly OT total to date]
    P --> Q{Decision?}
    Q -->|Approve| R[POST /attendance/overtime/requests/id/approve]
    Q -->|Reject| S[POST /attendance/overtime/requests/id/reject\nReason required]
    R --> T([Status: APPROVED\nEmployee notified\nComp time accrual triggered if elected])
    S --> U([Status: REJECTED\nEmployee notified with reason])
```

---

## Flow F6: Payroll Officer Closes Period and Handles Negative Balance (H-P0-004)

**Persona:** Payroll Officer
**Features:** SHD-T-002, SHD-T-003, SHD-T-008
**H-P0-004:** Terminated employees with negative balance require action before close

```mermaid
flowchart TD
    A([Payroll Officer → Period Management]) --> B[Period list\nCurrent period: OPEN\nClose button available]
    B --> C[Click 'Lock Period'\nPrevents new submissions]
    C --> D[POST /periods/id/lock]
    D --> E{Lock result}
    E -->|Success| F([Period status: LOCKED\nHR Admin + Employees notified\nNo new leave/OT requests accepted])
    E -->|Blocked| G[Lock blocked\nList of reasons: pending approvals\nResolve before continuing]
    G --> H([Payroll Officer / HR Admin resolves blockers\nRetry lock])

    F --> I[Period Validation screen\nSystem checks all timesheets APPROVED\nSystem checks no pending leave requests in period]
    I --> J{Validation passed?}
    J -->|All timesheets not approved| K[Pending timesheets list\nNotify managers to approve\nRecheck validation]
    K --> I
    J -->|Pending leave requests exist| L[Pending leave requests list\nHR Admin / Manager resolves\nRecheck validation]
    L --> I
    J -->|Terminated employees with negative balance| M[H-P0-004: Termination Balance Review screen\nList: employee / leave type / negative amount / policy action options]
    M --> N{Action per terminated employee?}
    N -->|Deduct from Final Pay| O[Mark: DEDUCT_FROM_FINAL_PAY\nRequires written consent confirmation]
    N -->|Write Off| P[Mark: WRITE_OFF\nLogs HR Admin confirmation + timestamp]
    N -->|Escalate to HR| Q[Mark: ESCALATE\nHR Admin task created\nPeriod close blocked until resolved]
    O --> R{All terminated employees actioned?}
    P --> R
    Q --> R
    R -->|No| M
    R -->|Yes| S{All validations passed?}

    J -->|Validation passed| S
    S -->|Yes| T[Click 'Close Period'\nFinal confirmation dialog]
    T --> U[POST /periods/id/close]
    U --> V{Close result}
    V -->|Success| W([Period status: CLOSED\nPayroll export generated automatically\nE-SHD-002: PeriodClosed event published])
    V -->|Error| X[Error state\nSupport contact info\nRetry option]
    W --> Y[Payroll Export screen\nExport package available for download]
    Y --> Z([Download export file\nNotification sent to Payroll system\nAudit trail entry created])
```
