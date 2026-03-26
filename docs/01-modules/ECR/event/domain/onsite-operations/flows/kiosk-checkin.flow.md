# Use Case: Kiosk Check-In
## Bounded Context: Onsite Operations
## ECR Module | 2026-03-25

**Actor:** Candidate (self-service at kiosk) or Kiosk Operator (assisted)
**Trigger:** Candidate arrives at the event venue and approaches a kiosk station
**Preconditions:**
- Event is in `IN_PROGRESS` state (`EventStarted` has been received)
- KioskSession is in `ACTIVE` or `SUSPENDED` state (SUSPENDED = offline capture allowed)
- KioskSession holds an assigned SBDBlock with at least 1 number remaining (for walk-in path)
- Local candidate cache is loaded (from last successful sync or initial session start)

**Postconditions:**
- A `CheckInRecord` exists with `sync_status = PROVISIONAL`
- `CheckInCaptured` domain event is emitted (triggers provisional queue display in Interview Management BC)
- If kiosk is online: sync begins immediately; on success, `sync_status` transitions to `SYNCED` and `CheckInConfirmed` is emitted
- If kiosk is offline: CheckInRecord is added to `OfflineSyncQueue`; sync deferred to next reconnection
- In all cases, candidate receives a printed badge (or on-screen confirmation) before leaving the kiosk

**Business Rules:** BR-01, BR-08, OQ-D2, OQ-D3

---

## Happy Path: QR Scan (Online Mode)

1. Candidate opens their confirmation email or mobile app and presents the QR code to the kiosk scanner.
2. Kiosk scanner reads the QR code. The code encodes the `registration_id` or a secure token.
3. Kiosk resolves the token against the local candidate cache.
   - Match found: candidate name, SBD, and slot assignment are displayed on screen.
4. Kiosk creates a `CheckInRecord` with:
   - `check_in_method = QR_SCAN`
   - `sync_status = PROVISIONAL`
   - `sbd_number` from the existing registration (not from SBDBlock — this is a pre-registered candidate)
   - `captured_at = device_clock_now()`
   - `kiosk_session_id` of the current session
5. Kiosk emits `CheckInCaptured` (Provisional) — Interview Management BC receives this and adds candidate to the interviewer queue with a "Provisional" indicator.
6. Kiosk initiates face capture (if configured for this event): camera opens, captures a face image, attaches `FaceCapture` reference to the CheckInRecord.
7. Kiosk prints badge (if badge printing is configured): prints SBD, candidate name, track, room/time slot.
8. Kiosk submits the CheckInRecord to the server immediately (online mode).
9. Server validates:
   - SBD belongs to this event
   - No existing non-cancelled CheckInRecord for this candidate at this event
   - Slot assignment is consistent with schedule
10. Server acknowledges. Kiosk updates `sync_status = SYNCED`, records `synced_at = server_clock_now()`.
11. Kiosk emits `CheckInConfirmed` — Interview Management BC promotes the queue entry to Confirmed state.
12. Candidate is directed to their assigned room.

---

## Alternate Flows

### A1: SBD Lookup (QR Code Unavailable)

At step 1–3:
- Candidate does not have a QR code (lost confirmation, walk-in without prior registration).
- Kiosk operator switches to SBD Lookup mode.
- Candidate or operator types the SBD number.
- Kiosk resolves against local candidate cache.
- If found: flow continues from step 4 with `check_in_method = SBD_LOOKUP`.
- If not found in cache: see Error Flow E2 (SBD not in cache).

### A2: Manual Entry (No QR, No SBD)

At step 1–3:
- No QR code, no known SBD (genuine walk-in or lost confirmation completely).
- Kiosk operator selects Manual Entry mode.
- Operator enters candidate name and student ID (or phone number).
- Kiosk searches local cache by name/student ID. If unambiguous match found, treats as SBD Lookup (A1).
- If no match: kiosk assigns a new SBD from the KioskSession's `SBDBlock` (BR-01 — SBD at capture).
- Kiosk creates CheckInRecord with `check_in_method = MANUAL_ENTRY` and `sync_status = PROVISIONAL`.
- Kiosk also creates a `ManualReviewItem` with `conflict_type = RECORD_MISMATCH` (or appropriate type).
- TA Coordinator is alerted to review the manual entry post-event or in real-time.
- Flow continues from step 5 (badge prints with new SBD).
- Server sync of Manual Entry records always routes to `REVIEW_REQUIRED` sync status first.

### A3: Offline Mode — QR Scan or SBD Lookup

At step 8:
- Kiosk is offline (no server connectivity).
- Steps 1–7 proceed identically (local cache lookup, CheckInRecord creation, badge print).
- Instead of submitting to server: CheckInRecord is added to `OfflineSyncQueue` as an `OfflineSyncQueueItem`.
- `queue_position` is assigned based on insertion order.
- `CheckInCaptured` is still emitted locally (for offline queue display if local UI supports it).
- No `CheckInConfirmed` event until the kiosk reconnects and sync succeeds.
- Candidate receives the same badge print; the offline state is transparent to the candidate.

### A4: Time Window Validation (Slot Not Yet Active)

At step 9 (server validation) or step 3 (local cache check):
- The candidate's allocated slot has not yet started (check-in too early).
- If early check-in is within a configurable tolerance window (e.g., 30 minutes before slot): **allowed** — record proceeds to SYNCED.
- If outside tolerance: server returns a warning (not a rejection). Kiosk displays: "Your slot starts at [time]. You may wait in the holding area."
- Check-in is still recorded; the time window is advisory, not a hard gate (candidates are not turned away).

### A5: Room Validation

At step 9 (server):
- The candidate's slot references a room that has since been changed (capacity override, room swap).
- Server detects the mismatch.
- Server updates the slot reference and returns the corrected room in the acknowledgment.
- Kiosk reprints the badge (if badge printing is available) with the updated room.
- No conflict is raised; this is an auto-resolvable discrepancy.

### A6: SBDBlock Near Exhaustion

At step 4 (when assigning from SBDBlock for walk-ins):
- `next_available` approaches `end_sbd` with fewer than 10 numbers remaining.
- Kiosk sets `SBDBlock.block_state = NEAR_EXHAUSTED`.
- On next sync (or immediately if online), kiosk requests a new SBDBlock from the server.
- Server allocates a new contiguous block and returns it.
- Kiosk updates its `sbd_block` reference. Old block remains valid until exhausted.

---

## Error Flows

### E1: QR Code Invalid or Expired Token

At step 3:
- QR code does not resolve to any record in the local cache (token unrecognized or corrupted).
- Kiosk displays: "QR code not recognized. Please try SBD lookup or ask an operator for assistance."
- Kiosk operator switches to SBD Lookup (Alternate A1) or Manual Entry (Alternate A2).
- No CheckInRecord created at this point.

### E2: SBD Not Found in Local Cache

At step 3 (SBD Lookup path):
- SBD typed by operator is not in the local candidate cache.
- Kiosk displays: "SBD not found. This may be a very recent registration not yet synced."
- If kiosk is online: kiosk performs a live server lookup for the SBD.
  - If found on server: local cache is updated; flow continues from step 4.
  - If not found on server: see E3.
- If kiosk is offline: operator falls back to Manual Entry (A2).

### E3: Candidate Not Registered for This Event

At step 9 (server validation) or after live lookup:
- The SBD is not associated with any confirmed registration for this event.
- Server returns: validation failure, reason = `SBD_NOT_FOUND`.
- CheckInRecord transitions to `sync_status = CONFLICT`, `conflict_type = SBD_NOT_FOUND`.
- `CheckInConflict` event emitted. ManualReviewItem created.
- Kiosk displays: "Check-in could not be confirmed. A coordinator has been notified."
- Candidate is directed to a TA Coordinator station for resolution.

### E4: Duplicate Check-In Detected

At step 9 (server validation):
- A non-cancelled CheckInRecord already exists for this candidate at this event.
- Server returns: validation failure, reason = `DUPLICATE_CHECKIN`.
- CheckInRecord transitions to `sync_status = CONFLICT`, `conflict_type = DUPLICATE_CHECKIN`.
- `CheckInConflict` event emitted. ManualReviewItem created.
- Kiosk displays: "This candidate has already checked in. Please see a coordinator."

### E5: SBDBlock Exhausted (Walk-In Path)

At step 4 (Manual Entry, no SBD available):
- `SBDBlock.block_state = EXHAUSTED` — no numbers remaining.
- If kiosk is online: kiosk immediately requests a new block from the server.
  - On success: proceed with new block.
  - On failure: kiosk cannot create new walk-in registrations. Operator directs walk-in to a TA Coordinator station.
- If kiosk is offline: kiosk cannot assign a new SBD. Walk-in directed to coordinator.

### E6: Face Capture Failure

At step 6:
- Camera fails to capture a clear face image (poor lighting, camera malfunction, candidate declines).
- Face capture is skipped (non-blocking).
- CheckInRecord is created without a `FaceCapture` reference.
- Event proceeds. A note is added to the record: "Face capture skipped."

### E7: Badge Printer Failure

At step 7:
- Badge printer is offline or out of paper.
- Kiosk displays: "Badge printing unavailable. Please note your SBD: [number]."
- Check-in proceeds. Badge print failure does not block the check-in.
- Kiosk logs the print failure for operator attention.

---

## Domain Events Emitted

- `CheckInCaptured` — emitted immediately when CheckInRecord is created in Provisional state
- `CheckInConfirmed` — emitted when server confirms the sync (online mode: within seconds; offline: deferred)
- `CheckInConflict` — emitted when server-side validation finds an unresolvable conflict
- `KioskSessionSynced` — emitted at end of each sync run (summary event)

---

## Sequence Diagram

```
Candidate   Kiosk App      Local Cache     Server          Interview Mgmt
   │             │               │              │                  │
   │─── QR ─────►│               │              │                  │
   │             │── Lookup ─────►│              │                  │
   │             │◄── Hit ────────│              │                  │
   │             │── CreateCheckInRecord(PROVISIONAL)               │
   │             │── Emit CheckInCaptured ──────────────────────────►│
   │             │                              │        (Provisional queue entry)
   │             │── FaceCapture (optional)      │                  │
   │             │── PrintBadge                  │                  │
   │◄── Badge ───│               │              │                  │
   │             │── SyncRecord ─────────────────►│                  │
   │             │               │◄── ACK ────────│                  │
   │             │── Update SYNCED               │                  │
   │             │── Emit CheckInConfirmed ───────────────────────────►│
   │             │               │              │        (Confirmed queue entry)
```

---

## Notes

- The time window and room validation at step 9 are advisory checks — they produce warnings and auto-corrections, not hard rejections. The operational principle is: never turn a candidate away at the kiosk due to a scheduling data inconsistency. Human coordinators handle edge cases.
- Face capture and badge printing are configurable per event. If neither is configured, the flow ends after step 5 (Provisional capture and emit).
- Offline mode is designed to be operationally transparent to candidates. The kiosk should not display "offline" warnings to candidates; it should display the same confirmation screen. Offline indicators are for operators only.
- The 5-second SLA (NFR-03) for queue update in Interview Management is measured from `CheckInCaptured` emission (provisional path), not from `CheckInConfirmed`. The provisional path is sub-second under normal conditions.
