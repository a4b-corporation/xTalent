# Navigation Flows: ECR Module
## xTalent HCM Solution | 2026-03-26

Detailed step-by-step navigation flows for all P0 and P1 workflows.

---

## P0 Flows (Event Day — Cannot Fail)

---

### Flow P0-1: Kiosk Check-In (Online Mode)

**Actor:** Onsite Staff
**Feature:** ECR-T-010
**Entry:** Kiosk App launches → /checkin (default tab)
**Pre-condition:** Active kiosk session exists (startKioskSession called); device is online

```
1. KIOSK HOME SCREEN (/checkin)
   - Session header: "Event Name | Date | Room 3A | Shift 2: 09:00–12:00"
   - Connectivity indicator: GREEN dot — "Online"
   - Sync queue badge: "0 pending" (green)
   - Two input tabs: [Scan QR] [Enter SBD]
   - Default: Scan QR tab active

2. SCAN QR path:
   → Tap "Scan QR"
   → Camera viewfinder activates
   → Staff points camera at candidate's QR code or invitation email QR
   → System reads QR → API call: POST /checkin/scan

   2a. QR VALID, candidate matches session:
       → Candidate card appears:
          - SBD: 00123 | Name: Nguyen Van A | Track: Software Engineer
          - Room: 3A (correct) | Status: Registered
          → [Button] Confirm Check-In  [Button] Cancel
       → Staff taps "Confirm Check-In"
       → API writes CheckedIn state
       → SUCCESS screen (2 seconds):
          - Green checkmark animation
          - "Checked in: Nguyen Van A — 09:14"
          - Optional badge print trigger (if printer connected)
       → Auto-advance to /checkin (ready for next candidate)

   2b. QR VALID but WRONG SESSION (candidate assigned to different room):
       → Warning card (amber):
          - "Candidate assigned to Room 5B"
          - SBD and name displayed
          → [Button] Check In Here Anyway (requires TA override PIN)
          → [Button] Direct to Correct Room
       → Staff selects appropriate action

   2c. QR INVALID or unrecognized:
       → Error card (red):
          - "QR code not recognized — try manual SBD entry"
          → [Button] Try Again  [Button] Enter SBD

   2d. CANDIDATE ALREADY CHECKED IN:
       → Info card (blue):
          - "Nguyen Van A already checked in at 08:52"
          → [Button] OK (returns to scan screen)

3. ENTER SBD path:
   → Tap "Enter SBD" tab
   → Large numeric keypad + text field
   → Staff types SBD number → tap Submit
   → Same outcome logic as 2a–2d above

4. END STATE: /checkin screen reset, ready for next scan
```

---

### Flow P0-1b: Kiosk Check-In (Offline Mode)

**Actor:** Onsite Staff
**Feature:** ECR-T-010
**Pre-condition:** Active kiosk session loaded; device has LOST connectivity

```
1. KIOSK HOME SCREEN (/checkin)
   - Session header unchanged
   - Connectivity indicator: RED dot — "Offline — Saving locally"
   - Sync queue badge: count of unsynced records (e.g., "12 pending") — ORANGE
   - ALERT BANNER: "Working offline. Check-ins will sync when connection is restored."

2. SCAN / ENTER SBD (same UI flow as online)
   → On scan/submit:
   → System checks LOCAL SQLite cache (pre-loaded at session start)

   2a. SBD FOUND in local cache:
       → Candidate card shown (name, track, room) with "OFFLINE" indicator
       → [Button] Confirm Check-In (Provisional)
       → Writes to local SQLite: state = PROVISIONAL
       → Sync queue count increments
       → SUCCESS screen:
          - "Saved locally (offline) — Nguyen Van A"
          - "Will sync when connection is restored"
          - PROVISIONAL badge shown

   2b. SBD NOT FOUND in local cache:
       → Error card: "Candidate not found in offline data"
       → Option: [Button] Register as Walk-In → navigates to /walkin

   2c. SBD ALREADY PROVISIONALLY CHECKED IN (local):
       → Info card: "Already saved locally at 09:22 (offline)"

3. SYNC queue depth alert:
   → If sync queue > 50 items AND still offline:
      → Orange banner: "50+ unsynced records — reconnect soon"
   → If sync queue > 100 items:
      → Red alert: "Critical: 100+ unsynced records — seek connectivity immediately"

4. RECONNECTION:
   → Connectivity indicator flips GREEN
   → Banner: "Back online — syncing X records..."
   → Auto-sync triggers: POST /kiosk/sync
   → Queue depth counts down
   → Conflicts (if any) → appear in TA's Sync Review queue
```

---

### Flow P0-2: HM Interview Kit (KitLink Access)

**Actor:** Hiring Manager
**Feature:** ECR-T-014
**Entry:** Email link: https://app.xtalent.vn/kit/{token}
**Pre-condition:** TA has dispatched session digest; KitLink generated with 24h TTL

```
1. LINK CLICK → /kit/:token
   → System validates token:

   1a. TOKEN VALID:
       → Loads HM Interview Kit screen
       → Header: "Interview Session | Event Name | Room 3A | 10:00–12:00 | 2026-03-15"
       → Expiry indicator: "Link valid until 10:00 AM tomorrow" (green if > 4h, amber if < 4h, red if < 1h)
       → Panel info: "You are: Tran Thi B (Interviewer)"

   1b. TOKEN EXPIRED (past 24h):
       → Expiry screen:
          - "This interview link has expired"
          - Time expired: "Expired 2026-03-16 10:00 AM"
          → [Button] Request New Link → triggers email to TA Coordinator
          → Confirmation: "Your request has been sent to the TA team"
       → No further access

   1c. TOKEN INVALID (malformed, revoked):
       → Error screen: "Invalid link — contact your TA coordinator"

2. CANDIDATE QUEUE (/kit/:token)
   - Ordered list of candidates assigned to HM's session
   - Each row: SBD | Full Name | Track | Status (Pending / Scored / Skipped)
   - Completion counter: "3 of 8 scored"
   → [Tap/Click any candidate row] → Candidate Detail view

3. CANDIDATE DETAIL (/kit/:token/candidate/:candidateId)
   - Candidate profile: name, SBD, track, registration answers
   - CV preview (PDF inline or download link)
   - Track-specific screening question answers
   - Current status badge: Pending / Scored / Skipped
   - Navigation: [← Previous] [Next →]

   3a. SCORE SUBMISSION:
       → [Button] Submit Score (only active if status = Pending)
       → Score modal:
          - Score criteria rubric (configured per track)
          - Individual dimension scores OR overall score (depends on track config)
          - [Text] Overall comments (optional)
          → [Button] Confirm — "This action cannot be undone"
          → Confirmation dialog: "Are you sure? Scores cannot be edited after submission."
          → [Button] Yes, Submit  [Button] Cancel
       → On confirm: POST /interviews/score
       → Candidate status → Scored
       → Returns to queue; next Pending candidate auto-highlighted

   3b. SKIP CANDIDATE:
       → [Button] Skip (only active if status = Pending)
       → Skip modal:
          - Required: Skip reason (dropdown: No show / Candidate withdrew / Other)
          - Optional: note text
          → [Button] Confirm Skip
       → Candidate status → Skipped
       → Returns to queue

   3c. CANDIDATE ALREADY SCORED:
       → Score and comments shown as read-only
       → No edit action available
       → [Button] Request Score Edit → opens Score Edit Request form
          - Required: reason for edit request
          - Submits to TA review queue (ECR-T-015)

4. EXPIRY WARNING (ambient):
   → When token has < 1h remaining:
      → Banner: "This link expires in 45 minutes. Request a new link if needed."
      → [CTA] Request New Link (inline in banner)

5. SESSION COMPLETE:
   → All candidates Scored or Skipped
   → Banner: "Session complete — all candidates reviewed"
   → View-only mode; no further actions
```

---

### Flow P0-3: Live Event Dashboard

**Actor:** TA Event Coordinator
**Feature:** ECR-A-002
**Entry:** /events/:id/analytics → Live Dashboard tab
**Pre-condition:** Event is InProgress; Redis-backed real-time data available

```
1. NAVIGATE TO LIVE DASHBOARD
   → /events/:id → Analytics tab → Live Dashboard sub-tab
   → Page loads with last-known data immediately (Redis cache hit)
   → Auto-refresh: every 30 seconds (configurable)
   → Refresh indicator: "Last updated: 09:15:32" with spinner on refresh

2. DASHBOARD LAYOUT

   TOP ROW — Key Metrics (4 cards):
   ┌──────────────────┬──────────────────┬──────────────────┬──────────────────┐
   │ Checked In       │ Check-In Rate    │ Interviewed      │ Remaining        │
   │ 342 / 500        │ 68%              │ 218 / 342        │ 158 not checked  │
   └──────────────────┴──────────────────┴──────────────────┴──────────────────┘

   MIDDLE ROW — Charts:
   ┌──────────────────────────────┬───────────────────────────────────────────┐
   │ Check-In Over Time           │ Check-In by Room (bar chart)              │
   │ (line chart, 15-min buckets) │ Room 3A: 85/100 | Room 3B: 72/100 | ...  │
   └──────────────────────────────┴───────────────────────────────────────────┘

   BOTTOM ROW:
   ┌──────────────────────────────┬───────────────────────────────────────────┐
   │ Track Funnel (per track)     │ Sync Status (kiosk)                       │
   │ Reg → Checked → Interviewed  │ Kiosk 1: 2 pending | Kiosk 2: Online      │
   └──────────────────────────────┴───────────────────────────────────────────┘

3. ALERT STATES:
   → Room approaching capacity (>90% checked in): amber badge on room card
   → Stalled check-in (rate drops below 5/min for 15min): alert banner
   → Offline kiosk with > 50 unsynced records: warning card in Sync Status panel
   → Score submission rate very low vs expected: advisory notice

4. NO DATA STATE:
   → Event has not started yet: "Event has not started. Dashboard will activate at event start."
   → No check-ins yet: empty state with 0 counts, charts show no data message

5. EXPORT / SHARE:
   → [Button] Export Snapshot (PDF) — current dashboard state as report
   → [Button] Full Screen mode (presentation mode for display on large screen)
```

---

## P1 Flows (Pre-Event Setup)

---

### Flow P1-1: Event Creation Wizard

**Actor:** TA Event Coordinator
**Feature:** ECR-T-001, ECR-M-001, ECR-M-002, ECR-T-002
**Entry:** /events → [Button] Create New Event

```
STEP 1: Basic Information (/events/new → step 1)
- Event name (required)
- Event type (Job Fair / Campus Recruitment / Walk-In Day / Custom)
- Location (free text + address fields)
- Event dates (start date, end date; must be future)
- Registration window (open date, close date)
- Max capacity (total)
- Description (rich text, optional)
- [Button] Next → Step 2

STEP 2: Tracks (/events/new → step 2)
- [Button] Add Track
  - Track name (required)
  - Target headcount (required)
  - Linked job request (search/select from open requisitions)
  - Screening criteria (optional tags)
- Minimum 1 track required
- [Button] Next → Step 3

STEP 3: Registration Form (/events/new → step 3)
- Default fields pre-loaded (name, email, phone, DOB, ID number)
- [Button] Add Field (opens field type picker)
  - Field types: Text, Number, Date, Dropdown, Checkbox, File Upload
  - Per-field: label, required toggle, help text
- Track-specific question blocks per track
- [Button] Preview Form (opens preview modal)
- [Button] Next → Step 4

STEP 4: Review & Save (/events/new → step 4)
- Summary of all configured data
- Edit links for each section (jump back to step)
- [Button] Save as Draft → creates event in Draft state
  → Redirect to /events/:id (Overview tab)
  → Success toast: "Event created — next step: Publish when ready"

ALTERNATIVE FLOW — Clone from Template:
- On /events list, [Button] Clone from Template
- Select template from list
- Step 1: Override dates (required)
- Step 2: Review inherited tracks/form
- Step 3: Confirm and save as Draft
```

---

### Flow P1-2: Schedule Matrix Builder

**Actor:** TA Event Coordinator
**Feature:** ECR-M-004
**Entry:** /events/:id → Schedule tab → Schedule Matrix sub-tab

```
1. MATRIX BUILDER (/events/:id/schedule/matrix)
   - Initial state: empty grid
   - [Button] Add Room → modal: room name, floor/building, capacity
   - [Button] Add Time Slot → modal: shift name, start time, end time, date
   - Grid renders: rows = time slots, columns = rooms
   - Each cell: capacity number (editable inline)
   - Cell context menu: Set capacity | Assign track | Mark unavailable

2. TRACK ASSIGNMENT:
   → Click cell or room header → [Assign Track] dropdown
   → Select which track is interviewed in this room/slot
   → Room-track assignments shown as color-coded cells

3. VALIDATION:
   → Over-subscription warning: if SUM(room capacities) < registered candidates for track
   → Gaps warning: if some shifts have no room assignments

4. SAVE:
   → [Button] Save Matrix
   → Confirmation: "Schedule matrix saved. You can now allocate candidates."
   → Matrix locked if event is InProgress (no edits allowed)
```

---

### Flow P1-3: Candidate Slot Allocation

**Actor:** TA Event Coordinator
**Feature:** ECR-T-008
**Entry:** /events/:id → Schedule tab → Allocation sub-tab

```
1. ALLOCATION SETUP (/events/:id/schedule/allocation)
   - Pre-condition: Schedule matrix must be saved
   - Candidate count vs slot capacity summary shown
   - Algorithm selection:
     [Radio] Round-Robin — distributes evenly across rooms
     [Radio] Fill-First  — fills first room before moving to next
   - [Toggle] Respect track-room assignments (on by default)
   - [Toggle] Exclude waitlisted candidates (on by default)

2. RUN ALLOCATION:
   → [Button] Preview Allocation
   → System runs dry-run allocation
   → Shows allocation table: candidate → slot → room
   → Conflicts listed (if any):
      - Over-capacity rooms
      - Candidates with no available slot (if capacity insufficient)
   → [Button] Commit Allocation (active only if no blocking conflicts)

3. MANUAL OVERRIDE (after preview or commit):
   → Drag-and-drop candidate row to different slot (if matrix allows)
   → Or: click candidate row → [Reassign] → select slot dropdown
   → Override logged in audit

4. COMMIT:
   → [Button] Commit Allocation
   → Confirmation: "Allocate X candidates to Y slots?"
   → On confirm: POST /schedule/allocate
   → Domain event: CandidatesAllocated
   → Success: "Allocation complete — proceed to send invitations"
   → [Button] Go to Invitations →
```

---

### Flow P1-4: Bulk Email Dispatch

**Actor:** TA Event Coordinator
**Feature:** ECR-T-016
**Entry:** /events/:id → Communications tab → [Button] Send Email

```
STEP 1: Select Template
- Template list (from ECR-M-006)
- [Button] Preview selected template (modal with merge tag sample data)
- [Button] Next → Step 2

STEP 2: Define Recipients
- Filter options:
  - Event: (auto-filled, current event)
  - Track(s): multi-select checkboxes
  - Registration status: Registered / Waitlisted / Checked In / etc.
  - Slot status: Allocated / Unallocated / Confirmed / Unconfirmed
- Live count: "X candidates match this filter"
- Warning: if count = 0, "No recipients match — adjust filters"
- [Button] Next → Step 3

STEP 3: Review & Send
- Summary: template name, recipient count, estimated delivery time
- "Sending to 247 candidates via async job (500/min ceiling)"
- [Checkbox] Send test email to myself first (optional)
- [Button] Confirm & Send
→ POST /communications/bulk
→ Returns job_id
→ Toast: "Email job started (Job #JOB-00234)"
→ Auto-navigates to Job History tab with this job highlighted

MONITOR (passive, not a blocking step):
→ /events/:id/communications (Job History)
→ Job card: status badge (Running / Complete / Failed), progress bar, sent/failed counts
→ [Button] Retry failed (if job completed with failures)
```

---

### Flow P1-5: Candidate Self-Registration Portal

**Actor:** Candidate (no login)
**Feature:** ECR-T-004
**Entry:** Public URL /register/:eventSlug (shared by TA via job posting or social media)

```
0. LANDING PAGE (/register/:eventSlug)
   - Event banner: name, date, location, logo
   - Registration deadline countdown (if < 3 days remaining)
   - Available tracks listed with descriptions and target headcount
   - [Button] Register Now

   0a. DEADLINE PASSED:
       → Banner: "Registration closed on [date]"
       → No registration button shown

   0b. EVENT AT CAPACITY:
       → Banner: "All spots filled. You can join the waitlist."
       → [Button] Join Waitlist (same form, routes to waitlist)

STEP 1: Personal Information
- Full name (required)
- Email (required) — duplicate check on blur
- Phone number (required, Vietnamese format validation)
- Date of birth (required)
- ID number / CCCD (required) — duplicate check on blur
- Gender (dropdown, optional)
- [Button] Continue

   Duplicate detection:
   → Email OR ID number already in system for this event:
      → Inline warning: "This email already has a registration — check your inbox or contact us"
      → [Button] Continue anyway (if candidate insists, system flags as potential duplicate)

STEP 2: Track Selection
- List of tracks with descriptions and remaining capacity indicator
- Radio selection (one track per registration)
- [Button] Continue

STEP 3: Track-Specific Questions
- Dynamic fields loaded based on selected track
- File upload: CV (PDF/DOCX, max 5MB)
- Other document uploads per track config
- [Button] Continue

STEP 4: Review & Submit
- Summary of all entered data
- [Edit] links per section
- Privacy notice acknowledgement checkbox (required for Vietnamese data law compliance)
- [Button] Submit Registration

STEP 5: CONFIRMATION SCREEN
   5a. SUCCESS (capacity available):
       → "Registration confirmed!"
       → SBD: 00342
       → "Save your SBD for event day check-in"
       → Email confirmation sent to [email]
       → Track and event summary
       → [Button] Download QR Code (for check-in)

   5b. WAITLISTED (capacity full at submission time):
       → "You have been added to the waitlist"
       → Waitlist position: #12
       → "You will be notified by email if a spot opens"
       → No SBD issued yet (issued on promotion)

   5c. DUPLICATE FLAGGED (system detected potential duplicate):
       → "Your registration has been received and is under review"
       → "Our team will contact you within 1 business day"
       → No SBD issued until duplicate resolved
```

---

## Cross-Feature Navigation Connections

| From Feature | Navigation Trigger | To Feature |
|-------------|-------------------|------------|
| ECR-T-001 (Event Published) | Next: Open Registration | ECR-T-004 (Portal becomes live) |
| ECR-T-004 (Registration Complete) | TA reviews registrations | ECR-T-005 (Duplicate flags) |
| ECR-T-005 (Duplicates resolved) | TA proceeds to schedule | ECR-M-004 (Schedule matrix) |
| ECR-M-004 (Matrix saved) | TA allocates candidates | ECR-T-008 (Slot allocation) |
| ECR-T-008 (Allocation committed) | TA sends invites | ECR-T-009 (Slot invitations) |
| ECR-T-009 (Invites sent) | TA assigns panels | ECR-M-005 (Panel assignment) |
| ECR-M-005 (Panels assigned) | TA dispatches digests | ECR-T-013 (Session digest) |
| ECR-T-013 (Digest dispatched) | HM receives KitLink | ECR-T-014 (HM Interview Kit) |
| ECR-T-001 (Event Started) | Onsite staff activates kiosk | ECR-T-010 (Kiosk check-in) |
| ECR-T-010 (Check-ins streaming) | TA monitors | ECR-A-002 (Live dashboard) |
| ECR-T-014 (All scores submitted) | Event closed | ECR-T-001 (Close event) |
| ECR-T-001 (Event Closed) | TA reviews performance | ECR-A-005 (Performance analytics) |
