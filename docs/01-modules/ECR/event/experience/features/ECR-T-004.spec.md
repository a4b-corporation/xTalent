# ECR-T-004: Candidate Self-Registration Portal
**Type:** Transaction | **Priority:** P1 | **BC:** BC-02
**Permission:** Public — no authentication required. Event must be in RegOpen state.

## Purpose

Allows candidates to register for a recruitment event through a public, no-login web portal. The portal is accessed via a shared URL (job postings, social media, email campaigns). Candidates complete a multi-step form, select a track, answer track-specific screening questions, and upload their CV. On successful submission, an SBD (Số Báo Danh) is issued and a confirmation email is sent. If capacity is full, the candidate is placed on a waitlist. The system performs real-time duplicate detection on email and ID number.

---

## States

| State | Description | Entry Conditions | Exit Conditions |
|-------|-------------|-----------------|-----------------|
| (Form in progress) | Candidate is filling the form | Portal loaded | Submit or abandon |
| Registered | Submission successful; SBD issued | Capacity available; no unresolvable duplicate | (terminal for self-registration) |
| Waitlisted | Submission successful; capacity full | Capacity reached at submission time | Promoted to Registered (ECR-T-006) |
| PendingReview | Duplicate flag raised; under TA review | Duplicate detected on email or ID | Registered or Rejected (ECR-T-005) |
| Rejected | TA rejected as true duplicate or ineligible | ECR-T-005 resolution | (terminal) |

---

## Flow

### Step 0: Landing Page
**Screen:** /register/:eventSlug
**Actor sees:**
- Event banner: name, date(s), location, company logo
- Registration deadline: countdown timer if < 72h remaining
- Available tracks: list with descriptions, remaining capacity indicator
- [Button] Register Now
**Actor does:** Reviews event info; clicks [Register Now]
**System does:** GET /events/{slug}/info → validates event is in RegOpen state
**Errors:**
- Event not in RegOpen: "Registration is not currently open"
- Event deadline passed: "Registration closed on [date]" — no register button
- Event at capacity: "All spots are filled. You can join the waitlist." — [Join Waitlist] CTA remains active

---

### Step 1: Personal Information
**Screen:** /register/:eventSlug/step/1
**Actor sees:** Form with fields:
- Full name (required)
- Email address (required)
- Phone number (required, Vietnamese format: 10 digits, starts with 0)
- Date of birth (required, date picker, must be ≥ 16 years old)
- ID number / CCCD (required, 9 or 12 digits)
- Gender (dropdown: Male / Female / Other / Prefer not to say — optional)
**Actor does:** Fills fields; tabs between fields
**System does:**
- Email: real-time duplicate check on blur (debounced 500ms) — GET /register/check-duplicate?email=X&event_id=Y
- ID number: real-time duplicate check on blur — GET /register/check-duplicate?id=X&event_id=Y
**Validation:**
- Name: 2–100 characters, no special characters except spaces and Vietnamese diacritics
- Email: valid email format
- Phone: Vietnamese mobile format (regex: /^(0[3|5|7|8|9])+([0-9]{8})$/)
- DOB: must be at least 16 years prior to event date
- ID number: 9 or 12 numeric digits
**Errors:**
- Duplicate email: inline warning "This email is already registered for this event. Check your inbox or contact us."
- Duplicate ID: inline warning same message
- On duplicate warning: [Button] Continue anyway (candidate may be re-entering; system flags as PendingReview)
- Invalid phone format: "Please enter a valid Vietnamese mobile number"

---

### Step 2: Track Selection
**Screen:** /register/:eventSlug/step/2
**Actor sees:**
- List of tracks for this event
- Each track card: name, description, target job role, remaining capacity (X spots left / Waitlist only)
- Radio button selection (one track per registration)
**Actor does:** Selects one track
**System does:** Records track selection in session state; loads track-specific questions for Step 3
**Validation:** Track selection required to proceed
**Errors:**
- All tracks at capacity: "All tracks are full. You can join the waitlist for your preferred track."

---

### Step 3: Track-Specific Questions
**Screen:** /register/:eventSlug/step/3
**Actor sees:**
- Dynamic question fields based on selected track (configured in ECR-T-002)
- Question types: text, multi-select, single-select, file upload, date
- Required/optional indicators per field
**Actor does:** Answers questions; uploads files if required
**System does:** Validates file uploads (type, size limits)
**Validation:**
- All required questions must be answered
- File uploads: PDF/DOCX/JPG only; max 5MB per file; max 3 files total
- Text fields: max 1000 characters each
**Errors:**
- "Please answer all required questions"
- "File too large — maximum 5MB allowed"
- "Unsupported file type — please upload PDF, DOCX, or JPG"

---

### Step 4: Review & Submit
**Screen:** /register/:eventSlug/step/4
**Actor sees:**
- Summary of all entered data grouped by section
- [Edit] link per section (navigates back to that step)
- Privacy notice: "Your data is processed in accordance with Vietnamese law on personal data protection (Decree 13/2023/ND-CP)"
- Consent checkbox: "I agree to the processing of my personal data for recruitment purposes" (required)
- [Button] Submit Registration
**Actor does:** Reviews data, checks consent box, clicks [Submit]
**System does:** POST /candidates/register with full payload
- Duplicate detection (final check at submission)
- Capacity check at moment of submission
- SBD generation if capacity available
**Errors:**
- Consent not checked: "Please agree to the data processing terms to continue"
- Submission timeout (> 10s): "Submission is taking longer than expected — please wait"
- Network error: "Submission failed — check your connection and try again" (form data preserved)
- Server error: "An error occurred — please try again in a few minutes"

---

### Step 5a: Success — Registered
**Screen:** /register/:eventSlug/confirmation
**Actor sees:**
- Green success banner: "Registration Confirmed!"
- SBD: large display — e.g., "00342"
- QR code containing SBD (downloadable as image)
- Event summary: name, date, location, track, room (if already allocated)
- "Save your SBD and QR code — you will need them for check-in"
- "A confirmation email has been sent to [email]"
**Actor does:** Downloads QR, screenshots page, or waits for email
**System does:**
- Emits CandidateRegistered domain event
- Triggers confirmation email (async, < 2 min delivery target)
- Emits SBDIssued domain event

---

### Step 5b: Waitlisted
**Screen:** /register/:eventSlug/confirmation (waitlist variant)
**Actor sees:**
- Amber banner: "You have been added to the waitlist"
- Waitlist position: e.g., "Position #12 on the [Software Engineer] track waitlist"
- "No SBD has been issued yet. You will receive an email if a spot becomes available."
- "A confirmation email has been sent to [email]"
**System does:**
- Emits CandidateWaitlisted domain event
- Sends waitlist confirmation email
- No SBD issued

---

### Step 5c: Pending Review (Duplicate Flagged)
**Screen:** /register/:eventSlug/confirmation (review variant)
**Actor sees:**
- Neutral banner: "Your registration is under review"
- "Our team will verify your submission and contact you within 1 business day"
- "A confirmation email has been sent to [email]"
**System does:**
- Emits DuplicateFlagged domain event
- Creates duplicate review task in TA queue (ECR-T-005)
- No SBD issued until resolved

---

## Registration Status Check (supplementary)

**Screen:** /register/:eventSlug/status
**Actor does:** Enters their email or SBD
**System does:** GET /candidates/status?email=X&event=Y
**Actor sees:** Registration status, SBD (if issued), slot assignment (if allocated), track

---

## Notifications Triggered

| Trigger | Domain Event | Recipient | Channel |
|---------|-------------|-----------|---------|
| Registration confirmed | CandidateRegistered + SBDIssued | Candidate | Email (async, template: Registration Confirmed) |
| Waitlisted | CandidateWaitlisted | Candidate | Email (async, template: You're on the Waitlist) |
| Duplicate flagged | DuplicateFlagged | TA Coordinator | In-app task notification |
| Slot allocated later | CandidateAllocated | Candidate | Email (sent by ECR-T-009) |

---

## Business Rules Enforced

| Rule | Where Enforced |
|------|----------------|
| Portal only active when event is RegOpen | Step 0 gate |
| Capacity check at submission (not at form load) | Step 4 server-side; race condition handled: last request wins, losers get waitlisted |
| Duplicate detection on email AND ID number | Steps 1 (inline) and 4 (final server check) |
| Privacy consent required | Step 4: non-bypassable checkbox |
| SBD not issued for waitlisted or pending-review candidates | Domain service: SBD issuance conditional on Registered state |
| Candidate PII never rendered outside Vietnam infrastructure | Infrastructure-level constraint; form renders only on Vietnam-hosted domain |
| One registration per candidate per event | Enforced by duplicate check; second attempt flagged |

---

## Empty State

- Event not found (invalid slug): "This event link appears to be invalid or expired. Please check the original link."
- Event not yet in RegOpen: "Registration for this event has not opened yet. Check back later."

---

## Edge Cases

| Scenario | Handling |
|----------|----------|
| Candidate submits form twice (double-click) | Backend idempotency: second submission within 30s returns same result, no duplicate created |
| Capacity fills between step 2 and step 4 | At submission, candidate is waitlisted; receives waitlist confirmation instead of SBD |
| Candidate uses unsupported browser (IE11) | Banner: "Please use a modern browser (Chrome, Edge, Firefox, Safari) for best experience" |
| File upload fails mid-way | Error per file; other fields preserved; candidate can retry just the file upload |
| Candidate registers with Vietnamese name containing diacritics | UTF-8 enforced throughout; no normalization that strips accents |
| Event slug changes after registration | Existing registrations are unaffected; portal URL change is an admin action logged to audit |
