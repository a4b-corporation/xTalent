# Flow: Clock In / Clock Out

**Bounded Context:** ta.attendance
**Use Case ID:** UC-ATT-001
**Version:** 1.0 | 2026-03-24

---

## Overview

An employee clocks in at the start of a shift and clocks out at the end.
The system records immutable Punch events, validates geofence, and calculates
a WorkedPeriod. Offline mode (H8) queues punches locally and syncs on reconnect
with conflict detection. Missing clock-out triggers a system prompt.

---

## Actors

| Actor | Role |
|-------|------|
| Employee | Performs clock-in and clock-out via mobile app or kiosk |
| Biometric Device / Mobile App | Captures punch event and biometric token |
| System (ta.attendance) | Records Punch, validates geofence, computes WorkedPeriod |
| System (ta.shared) | Sends exception notifications |
| HR Administrator | Reviews geofence violations and CONFLICT punches |

---

## Preconditions

- Employee has an active ShiftAssignment for today
- The Period covering today is in OPEN status

---

## Postconditions (Happy Path)

- Punch IN and Punch OUT created (sync_status = SYNCED, immutable)
- WorkedPeriod created with status = CONFIRMED
- net_hours_worked calculated: (punch_out - punch_in) - break_hours
- WorkedPeriod linked to the active Timesheet for the Period
- OT hours flagged if net_hours_worked > scheduled shift hours

---

## Happy Path: Clock In and Clock Out (Online, Geofence Valid)

```mermaid
sequenceDiagram
    actor Employee
    participant App as Mobile App / Kiosk
    participant ATT as ta.attendance Service
    participant DB as Attendance Store
    participant SHD as ta.shared Service

    Note over Employee,App: --- Clock In ---

    Employee->>App: Tap "Clock In"
    App->>App: Capture biometric match → biometric_ref token (ADR-TA-004)
    App->>App: Capture GPS coordinates (latitude, longitude)
    App->>ATT: SubmitPunch(employee_id, punch_type=IN, punched_at, biometric_ref, lat, lon)

    ATT->>ATT: Validate geofence (employee work location boundary)
    Note over ATT: geofence_validated = true if coordinates within boundary

    ATT->>DB: CreatePunch(punch_type=IN, geofence_validated=true, sync_status=SYNCED)
    Note over ATT,DB: ADR-TA-001: Punch is immutable after creation.<br/>biometric_ref = token only, no raw data (ADR-TA-004).
    DB-->>ATT: Punch { punch_id }

    ATT-->>App: Clock-in confirmed { punch_id, punched_at }
    App-->>Employee: "Clocked in at 08:02"

    Note over Employee,App: --- Clock Out ---

    Employee->>App: Tap "Clock Out"
    App->>App: Capture biometric_ref, GPS
    App->>ATT: SubmitPunch(employee_id, punch_type=OUT, punched_at, biometric_ref, lat, lon)

    ATT->>ATT: Validate geofence
    ATT->>DB: CreatePunch(punch_type=OUT, geofence_validated=true, sync_status=SYNCED)
    DB-->>ATT: Punch { punch_id=OUT }

    ATT->>DB: GetMatchedPunchIn(employee_id, shift_assignment_id, work_date)
    DB-->>ATT: Punch IN record

    ATT->>ATT: Calculate gross_hours = punch_out - punch_in
    ATT->>ATT: Calculate break_hours from ShiftAssignment.Shift.break_duration_minutes
    ATT->>ATT: net_hours_worked = gross_hours - break_hours
    ATT->>ATT: ot_hours = max(0, net_hours_worked - scheduled_shift_hours)

    ATT->>DB: CreateWorkedPeriod(status=CONFIRMED, net_hours_worked, ot_hours, punch_in_id, punch_out_id)
    DB-->>ATT: WorkedPeriod { worked_period_id }

    ATT->>DB: UpdateTimesheet (add/update TimesheetLine for work_date)
    DB-->>ATT: Timesheet updated

    ATT-->>App: Clock-out confirmed { worked_period_id, net_hours_worked }
    App-->>Employee: "Clocked out at 17:05. Worked: 8.75 hours."
```

---

## Alternative Path: Offline Mode (H8 — No Connectivity)

```mermaid
sequenceDiagram
    actor Employee
    participant App as Mobile App (Offline)
    participant Queue as Local Punch Queue
    participant ATT as ta.attendance Service
    participant DB as Attendance Store
    participant SHD as ta.shared Service
    actor HR as HR Administrator

    Note over Employee,App: Device has no network connectivity

    Employee->>App: Tap "Clock In"
    App->>App: Capture biometric_ref, GPS, local timestamp
    App->>Queue: QueuePunch(punch_type=IN, punched_at=local_time, sync_status=PENDING)
    App-->>Employee: "Clocked in (offline). Will sync when connected."

    Employee->>App: Tap "Clock Out" (still offline)
    App->>Queue: QueuePunch(punch_type=OUT, punched_at=local_time, sync_status=PENDING)
    App-->>Employee: "Clocked out (offline). Will sync when connected."

    Note over App,Queue: Network restored

    App->>ATT: SyncPunches([punch_IN_pending, punch_OUT_pending])

    loop For each pending punch
        ATT->>ATT: Check for conflicts (duplicate punch_id, overlapping timestamps)

        alt No conflict
            ATT->>DB: CreatePunch(sync_status=SYNCED, synced_at=now)
            ATT-->>App: Punch accepted { punch_id }

        else Conflict detected
            ATT->>DB: CreatePunch(sync_status=CONFLICT, conflict_reason="Duplicate punch / overlap detected")
            ATT->>SHD: SendNotification(event=PunchConflictDetected, recipient=hr_admin_id)
            SHD-->>HR: Alert: "Punch conflict for {employee}. Manual resolution required."
        end
    end

    Note over ATT,DB: After all punches synced (no conflicts),<br/>WorkedPeriod is computed as in happy path.

    opt Conflicts present
        HR->>ATT: ResolveConflict(punch_id, resolution=ACCEPT | REJECT, correction_punch?)
        ATT->>DB: UpdatePunch(sync_status=SYNCED) or CreateCorrectionPunch(is_correction=true)
    end
```

---

## Exception Path A: Geofence Violation

```mermaid
sequenceDiagram
    actor Employee
    participant App as Mobile App
    participant ATT as ta.attendance Service
    participant DB as Attendance Store
    participant SHD as ta.shared Service
    actor HR as HR Administrator

    Employee->>App: Tap "Clock In" (outside geofence boundary)
    App->>ATT: SubmitPunch(employee_id, punch_type=IN, lat, lon)

    ATT->>ATT: Validate geofence → geofence_validated = false
    Note over ATT: Geofence violation does NOT block the punch.<br/>Punch is recorded with geofence_validated=false.

    ATT->>DB: CreatePunch(geofence_validated=false, sync_status=SYNCED)
    ATT->>SHD: SendNotification(event=GeofenceViolation, recipient=hr_admin_id, employee_id)

    ATT-->>App: Clock-in recorded with warning: "Location outside work area — flagged for review"
    App-->>Employee: "Clocked in. Note: Location not recognized. HR has been notified."
    SHD-->>HR: Alert: "Geofence violation for {employee} at {time}. Please review."
```

---

## Exception Path B: Forgot to Clock Out

```mermaid
sequenceDiagram
    participant SYS as System Scheduler
    actor Employee
    participant App as Mobile App
    participant ATT as ta.attendance Service
    participant DB as Attendance Store
    participant SHD as ta.shared Service

    Note over SYS: Scheduled job runs 30 minutes after shift end time

    SYS->>ATT: CheckMissingClockOut(work_date, shift_end_time)
    ATT->>DB: GetOpenPunchIN(employees_with_no_matching_OUT, work_date)
    DB-->>ATT: List of employees with unmatched Punch IN

    ATT->>DB: CreateWorkedPeriod(status=PROVISIONAL, punch_in_id, punch_out_id=null)
    Note over ATT,DB: PROVISIONAL period uses shift end_time as estimated clock-out.<br/>Excluded from final payroll until employee confirms or corrects.

    ATT->>SHD: SendNotification(event=MissingClockOut, recipient=employee_id)
    SHD-->>Employee: "Did you forget to clock out? Please submit your actual clock-out time."

    Employee->>App: Submit correction clock-out time
    App->>ATT: SubmitCorrectionPunch(punch_type=OUT, punched_at=actual_time, is_correction=true, corrects_punch_id=original_punch_in)

    ATT->>DB: CreatePunch(is_correction=true, corrects_punch_id, sync_status=SYNCED)
    ATT->>DB: UpdateWorkedPeriod(status=CORRECTED, punch_out_id=correction_punch_id)
    ATT->>ATT: Recalculate net_hours_worked with corrected clock-out
    ATT->>DB: UpdateTimesheet line for work_date

    ATT-->>App: "Clock-out correction accepted. Worked hours updated."
```

---

## Business Rules

| Rule ID | Description |
|---------|-------------|
| ADR-TA-001 | Punch records are immutable after creation. Corrections require a new Punch with is_correction=true and corrects_punch_id referencing the original |
| ADR-TA-004 | biometric_ref must be an opaque token only; raw biometric data must never be stored in the Punch record |
| BR-ATT-001 | Geofence violations do not block punch recording; they set geofence_validated=false and trigger an HR notification |
| BR-ATT-002 | Offline punches (sync_status=PENDING) use local device timestamp; server records synced_at separately |
| BR-ATT-003 | Punch conflicts (H8): when a sync is received that overlaps with an existing punch, sync_status=CONFLICT and HR is notified for manual resolution |
| BR-ATT-004 | Missing clock-out: system creates a PROVISIONAL WorkedPeriod using shift end time as an estimate; employee must confirm or correct within the period |
