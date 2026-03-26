# Menu Map: ECR Module
## xTalent HCM Solution | 2026-03-26

Navigation hierarchy per role. Items marked with [permission] indicate the RBAC permission required beyond basic login.

---

## Role: TA Event Coordinator

Primary user. Full access to all event management functions.

### Primary Navigation

```
/events                           Events
├── /events                       Event List (default landing)
│   ├── Filter: status, date, location
│   ├── Search by event name
│   └── [Button] Create New Event
│
├── /events/new                   Create Event (wizard, ECR-T-001 step 1)
│
└── /events/:id                   Event Detail
    ├── Overview tab              Event metadata, status badge, lifecycle actions
    │   ├── [Action] Publish      (status = Draft) [ecr.event.publish]
    │   ├── [Action] Open Registration (status = Published) [ecr.event.manage]
    │   ├── [Action] Start Event  (status = RegOpen) [ecr.event.manage]
    │   ├── [Action] Close Event  (status = InProgress) [ecr.event.manage]
    │   └── [Action] Archive      (status = Closed) [ecr.event.manage]
    │
    ├── Tracks & Form tab         ECR-M-002, ECR-T-002
    │   ├── Track list
    │   ├── /events/:id/tracks/new
    │   ├── /events/:id/tracks/:trackId
    │   └── /events/:id/form      Form builder
    │
    ├── Candidates tab            ECR-T-004, ECR-T-005, ECR-T-006, ECR-M-003
    │   ├── Registered list       (filter: track, status, SBD)
    │   ├── Duplicate Flags       [ecr.candidate.manage] — pending review count badge
    │   ├── Waitlist              [ecr.candidate.manage]
    │   └── SBD Management        [ecr.candidate.manage]
    │
    ├── Schedule tab              ECR-M-004, ECR-T-008, ECR-T-009
    │   ├── Schedule Matrix       (room × shift grid)
    │   ├── Allocation            (candidate → slot assignment)
    │   └── Invitations           (send invites, confirmation status)
    │
    ├── Onsite Operations tab     ECR-T-011, ECR-T-012 (monitoring only for TA)
    │   ├── Check-In Monitor      (read-only live view)
    │   ├── Walk-In Queue         (review walk-ins)
    │   └── Sync Status           (offline sync review queue)
    │
    ├── Interviews tab            ECR-T-013, ECR-T-015, ECR-M-005
    │   ├── Panel Assignment      (assign interviewers to sessions)
    │   ├── Session Digest        (dispatch KitLinks)
    │   └── Score Edit Requests   [ecr.interview.manage] — pending count badge
    │
    ├── Communications tab        ECR-T-016, ECR-A-001
    │   ├── Send Email            (bulk email dispatch wizard)
    │   └── Job History           (communication job tracking)
    │
    ├── Analytics tab             ECR-A-002, ECR-A-003, ECR-A-005
    │   ├── Live Dashboard        (event day real-time)
    │   ├── Performance Report    (post-event KPIs)
    │   └── Custom Reports        [ecr.report.generate]
    │
    └── Audit Log tab             ECR-A-004 [ecr.audit.view]
        └── Paginated event audit trail

/templates                        Templates
├── /templates                    Template List (saved event templates)
├── /templates/new                Create template (same wizard as event, saved as template)
└── /templates/:id                Template detail + edit

/settings                         Module Settings [ecr.admin]
├── /settings/email-templates     ECR-M-006 — Email Template Management
└── /settings/sbd-config          SBD prefix and format configuration
```

---

## Role: Hiring Manager

No login. Access is exclusively via KitLink (time-limited deep link). No persistent session.

### KitLink Landing

```
/kit/:token                       HM Interview Kit (ECR-T-014)
├── Validates token on load (24h TTL)
├── If VALID:
│   ├── Session header: event name, date, room, time slot
│   ├── Candidate queue (ordered list for session)
│   │   ├── Candidate card: SBD, name, track, profile summary
│   │   ├── [Action] Score Candidate → score modal with confirmation
│   │   ├── [Action] Skip Candidate → skip reason modal
│   │   └── [Status] Already Scored (immutable display)
│   └── [CTA] Request New Link (if approaching expiry warning — < 1h remaining)
│
└── If INVALID / EXPIRED:
    └── Expiry screen: "This link has expired" + "Request new link" CTA
        └── → Email sent to TA Coordinator to re-dispatch

/kit/:token/candidate/:candidateId  Candidate Detail (within kit)
├── Full profile view
├── Track-specific screening answers
└── [Action] Submit Score / Skip (same as queue actions)
```

No menu, no navigation sidebar. Single-purpose deep link experience.

---

## Role: Onsite Staff (Kiosk)

Dedicated kiosk app — tablet or touchscreen device. Always-available offline-first PWA. No standard navigation sidebar.

### Kiosk App Screens

```
/ (Kiosk Home)                    Kiosk Session
├── [Requires] Active kiosk session (startKioskSession)
├── Session header: event name, date, shift, room
├── Connectivity indicator: Online / Offline
└── Sync queue depth indicator (count badge, red if > 50)

/checkin                          Check-In Screen (ECR-T-010) — DEFAULT TAB
├── [Tab] Scan QR
│   └── Camera viewfinder + cancel
├── [Tab] Enter SBD
│   └── Numeric keyboard input + Submit
├── Result card (after scan/submit):
│   ├── SUCCESS: candidate name, track, room confirmation → Confirm Check-In button
│   ├── ALREADY CHECKED IN: warning card with timestamp
│   ├── NOT FOUND: error card + retry
│   └── WRONG SESSION: warning + correct room shown
└── Offline banner (when offline): "Saving locally — will sync when connected"

/walkin                           Walk-In Registration (ECR-T-011)
├── Step 1: Personal info form (name, phone, ID number, track selection)
├── Step 2: Document photo capture (optional)
├── Step 3: Provisional SBD display + confirmation
└── Offline: queued locally until sync

/sync                             Sync Status (read-only for staff) (ECR-T-012)
├── Queue depth counter
├── Last sync timestamp
├── [List] Pending items
└── [Button] Force Sync (when online)

/session                          Session Management
├── View current session details
├── [Button] End Session (confirmation required)
└── [Button] Start New Session (if no active session)
```

---

## Role: Candidate (Self-Registration Portal)

Public-facing, no authentication. Single-use registration flow. Not an app user.

### Candidate Portal

```
/register/:eventSlug              Candidate Registration Portal (ECR-T-004)
├── Step 1: Event info banner (name, date, location, deadline)
│   └── [Button] Start Registration
├── Step 2: Personal Information
│   ├── Fields: full name, email, phone, date of birth, ID number
│   └── Duplicate detection on email + ID number
├── Step 3: Track Selection
│   └── Available tracks for this event (with descriptions)
├── Step 4: Track-Specific Questions
│   └── Dynamic fields based on selected track
├── Step 5: Document Upload
│   └── CV (PDF/DOCX), supporting docs per track config
├── Step 6: Review & Submit
│   └── Summary of all entered data, edit links per section
└── Confirmation Screen
    ├── Success: SBD issued, summary, email confirmation sent
    ├── Waitlisted: waitlist position, notification promise
    └── Duplicate detected: "Our team will contact you" message

/register/:eventSlug/status       Registration Status Check
├── Input: email or SBD
└── Displays: registration status, SBD, slot assignment (if allocated)
```

---

## Role: Admin / HR Admin

Same as TA Event Coordinator navigation plus:

```
/settings                         Full module settings access
├── /settings/email-templates     Email Template Management (full CRUD)
├── /settings/sbd-config          SBD configuration
├── /settings/users               User and permission management (HR Admin only)
└── /settings/audit               Global audit log (cross-event)
```

---

## Menu Visibility Summary

| Nav Section | TA Coordinator | Admin | HM | Onsite Staff | Candidate |
|-------------|:-:|:-:|:-:|:-:|:-:|
| Events List | Visible | Visible | — | — | — |
| Create Event | Visible | Visible | — | — | — |
| Event Detail tabs | Visible (all) | Visible (all) | — | — | — |
| Templates | Visible | Visible | — | — | — |
| Settings > Email Templates | Visible | Visible | — | — | — |
| Settings > SBD Config | Visible | Visible | — | — | — |
| Settings > Users | — | Visible | — | — | — |
| KitLink (/kit/:token) | — | — | Visible (token-gated) | — | — |
| Kiosk App | — | — | — | Visible (device-bound) | — |
| Candidate Portal (/register/:slug) | — | — | — | — | Visible (public) |
