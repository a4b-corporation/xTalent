# ECR-T-011: Walk-In Registration
**Type:** Transaction | **Priority:** P2 | **BC:** BC-05
**Permission:** ecr.checkin.manage

## Purpose

Allows onsite kiosk staff to capture a candidate who arrives at the event without a prior registration (walk-in). The walk-in candidate receives a provisional SBD and is flagged as WalkIn type for later review by TA. Works in online and offline modes; offline registrations are queued for sync (ECR-T-012).

---

## States

| State | Description | Entry Condition | Exit Transitions |
|-------|-------------|----------------|-----------------|
| Capturing | Staff entering walk-in data | Initiated via [Walk-In] button on kiosk | → Submitted |
| Submitted (Online) | Registration sent to server | Connectivity available | → CheckedIn (auto) |
| Queued (Offline) | Stored in local SQLite queue | No connectivity | → Synced (on ECR-T-012) |
| CheckedIn | Walk-in confirmed and checked in | Online submit success | Terminal for this feature |
| SyncPending | Awaiting sync review | Offline queue synced to server | → Merged / Rejected (via ECR-T-012) |

---

## Flow

### Step 1: Initiate Walk-In Capture
**Screen:** Kiosk app — /kiosk/:eventId/walkin
**Actor sees:**
- [Walk-In] large button on kiosk home screen alongside [Check-In] button
- Connectivity indicator (Online / Offline)
**Actor does:** Taps [Walk-In]
**System does:** Navigates to walk-in data capture form
**Validation:** None
**Errors:** None

### Step 2: Capture Walk-In Data
**Screen:** Kiosk app — Walk-In form
**Actor sees:** Minimal data entry form:
- Full Name (required)
- Phone Number (required; Vietnamese format)
- Email (optional)
- Track selection (required; dropdown of active event tracks)
- ID Number / CCCD (optional; numeric)
- Notes (optional; freetext max 200 chars; e.g., "referred by career fair booth 5")
**Actor does:** Fills in fields; taps [Register Walk-In]
**System does:** Runs duplicate check against existing registrations (by phone or email if provided) before proceeding
**Validation:**
- Full Name: required, 2–100 chars
- Phone: required, valid Vietnamese format (10–11 digits)
- Email: optional but must be valid format if provided
- Track: required
**Errors:**
- "Phone number is required."
- "Please select a track."
- "A registration with this phone number already exists (SBD: {sbd}). Proceed as walk-in anyway?" [Yes, Continue] [Cancel — Direct to Check-In]

### Step 3a: Online Submission
**Screen:** Kiosk app — processing spinner
**Actor sees:** "Registering..." spinner (< 5s expected)
**Actor does:** Waits
**System does:**
- Calls `POST /kiosk/walk-in` with form data, deviceId, eventId, timestamp
- Server creates WalkIn registration with status CheckedIn (auto-checked-in)
- Assigns provisional SBD (format: "W-{sequence}" or configured prefix + "W" infix)
- Emits: `WalkInRegistered` { candidateId, sbd, track, source: "WALKIN", deviceId }
- Returns SBD and name
**Errors:**
- Network timeout → auto-fallback to offline queue (Step 3b)
- "Server error. Registration saved to offline queue." (auto-fallback)

### Step 3b: Offline Queue
**Screen:** Kiosk app — confirmation screen
**Actor sees:** "Registration saved offline. Will sync when connection is restored." with offline icon and queue count "Queue: N items pending"
**System does:**
- Stores walk-in record in local SQLite with status = QUEUED, source = WALKIN
- Assigns a local provisional SBD (prefixed "TMP-" to indicate temporary)
- Increments offline queue counter on kiosk home screen
**Validation:** None (already validated in Step 2)
**Errors:** None (SQLite write failure is fatal device error, not recoverable in UX)

### Step 4: Confirmation Screen
**Screen:** Kiosk app — success screen
**Actor sees:**
- Large SBD displayed (formatted): "Your SBD: W-0042"
- Candidate name
- Track name
- Status: "Walk-In Registered" or "Offline — Syncing Later"
- Instruction: "Please note your SBD number. Proceed to Track {name} queue."
- [Done] button returns to kiosk home
- If offline: "Offline sync" badge and sync queue depth shown
**Actor does:** Shows screen to candidate; taps [Done]
**System does:** Returns to kiosk home screen; resets form

---

## Notifications Triggered

None from walk-in kiosk (no email infrastructure on-device). Post-sync follow-up emails may be sent by TA via ECR-T-016.

---

## Business Rules Enforced

- **BR-WI-001:** Walk-in registrations are always flagged with `registration_source = WALKIN` for reporting differentiation.
- **BR-WI-002:** Walk-in registrations are auto-checked-in if online (no separate check-in step needed).
- **BR-WI-003:** Provisional SBD prefix "TMP-" is replaced with a permanent SBD on sync (ECR-T-012).
- **BR-WI-004:** Walk-in registrations count against event capacity; if event is full, system warns but does not block (staff override available with confirmation).
- **BR-WI-005:** Walk-in data captured offline is never transmitted without staff-initiated or scheduled sync (ECR-T-012).

---

## Empty State

N/A — the walk-in form is always shown on demand.

---

## Edge Cases

- Staff enters same phone number twice (accidental double entry): Step 2 duplicate check catches this in online mode; offline mode shows duplicate check based on local SQLite cache only.
- Event capacity is full when walk-in arrives: system shows warning "Event is at full capacity (N/N). Register as walk-in anyway?" [Override — Register] [Cancel]. Override is logged to audit with staff device ID.
- Walk-in candidate already has a prior registration (different phone/email provided): resolved in ECR-T-012 review queue post-sync.
- Kiosk device battery dies during form entry: SQLite transaction is atomic; incomplete entries are discarded on next app start.
