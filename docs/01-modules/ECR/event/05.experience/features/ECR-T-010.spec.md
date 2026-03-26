# ECR-T-010: Kiosk Check-In
**Type:** Transaction | **Priority:** P0 | **BC:** BC-05
**Permission:** ecr.kiosk.operate (device-bound session required)

## Purpose

Enables onsite staff to check in registered candidates at the event venue using QR code scan or manual SBD (Số Báo Danh) entry. This is the primary event-day interaction point and cannot fail. The feature operates in two modes: online (writes to server immediately) and offline (writes to local SQLite with Provisional state, syncs on reconnect). Target: < 5s P95 for all local kiosk operations.

---

## States

| State | Description | Who Sets It | Valid Next States |
|-------|-------------|-------------|-------------------|
| Registered | Candidate registered and allocated to a slot | System (BC-02/BC-04) | CheckedIn, Provisional |
| Provisional | Offline check-in written to local SQLite; not yet synced to server | Kiosk (offline mode) | CheckedIn (on sync), ConflictFlagged (on sync conflict) |
| CheckedIn | Check-in confirmed on server; timestamp recorded | System (online) or Sync process (offline→online) | (terminal for this feature) |
| ConflictFlagged | Sync detected a conflict (e.g., duplicate check-in from two kiosks) | Sync process | CheckedIn (TA resolves) |
| WrongSession | Candidate scanned at incorrect room/session | Kiosk UI state (transient) | Registered (no action taken) or CheckedIn (TA override) |

---

## Flow

### Step 1: Session Start
**Screen:** /session (kiosk app)
**Actor sees:** Session start screen; input for event date/shift/room
**Actor does:** Selects active session (or session auto-loaded from device assignment)
**System does:** POST /kiosk/session/start → returns session_id, pre-loads candidate cache to local SQLite
**Validation:** Session must be in InProgress state; device must be assigned to this event
**Errors:**
- "No active session for this device" → contact TA Coordinator
- "Session already ended" → start new session required

---

### Step 2: Check-In Screen (Idle)
**Screen:** /checkin
**Actor sees:**
- Session header: event name, date, room, shift time
- Connectivity indicator (green = online, red = offline)
- Sync queue depth counter
- Two tabs: [Scan QR] [Enter SBD]
**Actor does:** Chooses input method
**System does:** Passive; no API call
**Errors:** None at idle state

---

### Step 3a: Scan QR Path
**Screen:** /checkin → Scan QR tab
**Actor sees:** Camera viewfinder (full-width) with QR targeting overlay
**Actor does:** Points device camera at candidate's QR code (from confirmation email or printed invitation)
**System does:** Decodes QR → extracts SBD → executes lookup (online: GET /candidates/sbd/{sbd}; offline: SQLite query)
**Validation:** QR must decode to a valid SBD string
**Errors:**
- Camera permission denied: "Camera access required — check device settings"
- QR unreadable: "QR not recognized — try manual SBD entry"

---

### Step 3b: Enter SBD Path
**Screen:** /checkin → Enter SBD tab
**Actor sees:** Large SBD text field + numeric virtual keyboard
**Actor does:** Types SBD number → taps Submit
**System does:** Lookup same as 3a
**Validation:** SBD must be numeric, 1–8 digits, leading zeros preserved
**Errors:**
- Empty field: "Please enter an SBD"
- Non-numeric: "SBD must be numbers only"

---

### Step 4: Lookup Result Handling
**Screen:** /checkin (result card overlay)

**4a — VALID, correct session (online):**
**Actor sees:** Candidate card — SBD, name, track, assigned room, status badge (Registered)
**Actor does:** Taps [Confirm Check-In]
**System does:** POST /checkin/confirm → sets status to CheckedIn, records timestamp and kiosk_id
**Validation:** Candidate must be in Registered state; assigned to this session
**Errors:** Network timeout → fallback to offline write (Step 4c)

**4b — ALREADY CHECKED IN:**
**Actor sees:** Info card (blue) — "Nguyen Van A already checked in at 09:14"
**Actor does:** Taps [OK] → returns to scan screen
**System does:** No state change; logs duplicate scan attempt

**4c — VALID, correct session (offline):**
**Actor sees:** Candidate card with "OFFLINE" indicator badge
**Actor does:** Taps [Confirm Check-In (Provisional)]
**System does:** Writes to local SQLite: {sbd, timestamp, kiosk_id, state: PROVISIONAL}; increments sync queue counter
**Business rule:** Provisional state is visually distinct (amber badge, not green)
**Errors:** SQLite write failure (device storage full): "Local storage full — cannot save check-in"

**4d — WRONG SESSION (candidate assigned to different room):**
**Actor sees:** Warning card (amber) — "Candidate assigned to Room 5B, not Room 3A"
**Actor does:** [Button] Direct to Correct Room (dismisses, no check-in) OR [Button] Check In Here Anyway (requires TA override PIN)
**System does:** If override: logs override action to audit with TA PIN actor

**4e — NOT FOUND:**
**Actor sees:** Error card (red) — "SBD not found in this event"
**Actor does:** [Button] Try Again OR [Button] Register as Walk-In → /walkin
**System does:** Logs failed lookup attempt

**4f — CANDIDATE WAITLISTED (not yet promoted):**
**Actor sees:** Warning card (amber) — "Candidate is on waitlist and has not been confirmed"
**Actor does:** [Button] Notify TA OR [Button] Check In Anyway (override PIN)

---

### Step 5: Success Confirmation
**Screen:** /checkin (success overlay, 2 seconds auto-advance)
**Actor sees:** Green checkmark, "Checked in: Nguyen Van A — 09:14:23", optional badge print prompt
**Actor does:** Nothing required (auto-advances) OR taps [Print Badge] if printer connected
**System does:** Optional: triggers badge print via local printer integration
**Auto-advance:** After 2 seconds, returns to Step 2 (idle scan screen)

---

### Step 6: Sync Queue Monitoring (ambient)
**Screen:** Sync counter badge on all kiosk screens
**Thresholds:**
- 0–10 pending: green badge (normal)
- 11–50 pending: orange badge (caution)
- 51–99 pending: orange banner: "Sync queue high — reconnect soon"
- 100+ pending: red alert banner: "Critical: reconnect immediately"
- Seats Blocking Dispatch (SBD) block threshold: if SBD allocation cannot proceed for unsynced records, red alert

**On reconnect:**
- Connectivity flips to green
- Auto-sync triggers: POST /kiosk/sync (handled by ECR-T-012)
- Queue count decrements as sync progresses

---

## Notifications Triggered

| Trigger | Event | Recipient | Channel |
|---------|-------|-----------|---------|
| Online check-in confirmed | CandidateCheckedIn | TA (live dashboard update) | Real-time push (WebSocket) |
| Offline check-in queued | KioskCheckInQueued (local) | None (local only until sync) | — |
| Sync completed (batch) | KioskSyncCompleted | TA (sync status panel) | Dashboard refresh |

---

## Business Rules Enforced

| Rule | Where Enforced |
|------|----------------|
| Candidate must have Registered status to check in | Step 4a validation; waitlisted candidates require override |
| Offline provisional check-ins are visually distinct from confirmed | Step 4c UI: amber badge vs. green |
| Sync queue depth always visible | Ambient badge on all kiosk screens (Step 6) |
| Override actions (wrong room, waitlisted) require TA PIN | Step 4d, 4f — PIN modal before override |
| Kiosk operations must complete < 5s P95 | Performance constraint; SQLite used for offline to guarantee this |
| Face capture is a placeholder; no biometric processing | Camera icon visible but disabled with "Pending activation" tooltip |

---

## Empty State

- No active session: "No active session. Ask your TA coordinator to start a session for this device."
- Local cache empty (never synced): "Candidate data is loading. Ensure device is connected."

---

## Edge Cases

| Scenario | Handling |
|----------|----------|
| Two kiosks check in same candidate simultaneously (offline) | Both write Provisional; sync detects conflict → TA review queue (ECR-T-012) |
| Device battery dies mid-session | SQLite preserves all provisional records; on restart, session resumes from saved state |
| Network flickers (connects and disconnects rapidly) | Debounce: treat as offline if connection lost > 5s |
| Candidate QR has been regenerated (old QR) | Old QR decodes to same SBD; lookup succeeds; no issue |
| Candidate checks in at wrong event entirely (SBD collision across events) | SBD lookup scoped to current event; "SBD not found" returned |
| More candidates arrive than room capacity | Check-in proceeds; over-capacity displayed as warning in TA dashboard |
