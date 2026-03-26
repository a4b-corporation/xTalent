# ECR-T-014: HM Interview Kit
**Type:** Transaction | **Priority:** P0 | **BC:** BC-06
**Permission:** KitLink token (no RBAC role required; token-gated access only)

## Purpose

Provides Hiring Managers with a bounded, no-login interface to conduct interviews on event day. HM receives an email with a KitLink (time-limited signed URL, 24h TTL). On clicking the link, HM lands directly on their candidate queue for the assigned session. They can view candidate profiles, submit scores with a mandatory confirmation step, or skip candidates with a reason. Score submission is irreversible by design. HM cannot access any other part of the system. Target: < 5s P95 dashboard load (Redis-backed).

---

## States

| State | Applies To | Description | Valid Next States |
|-------|-----------|-------------|-------------------|
| TokenValid | KitLink | Token exists, not expired, not revoked | (allows access) |
| TokenExpired | KitLink | Past 24h TTL | (blocks access; HM can request new link) |
| TokenInvalid | KitLink | Malformed or revoked | (blocks access) |
| Pending | Candidate (in session) | Candidate not yet acted on by this HM | Scored, Skipped |
| Scored | Candidate (in session) | Score submitted; irreversible | (terminal; Score Edit Request possible via ECR-T-015) |
| Skipped | Candidate (in session) | HM skipped with reason | (terminal within this session) |
| SessionComplete | Session | All candidates in session are Scored or Skipped | (terminal; view-only mode) |

---

## Flow

### Step 1: KitLink Resolution
**Screen:** /kit/:token
**Actor sees:** Loading spinner (< 1s expected)
**Actor does:** Clicks email link
**System does:** GET /kit/{token} → validates token signature, TTL, and session association
**Validation:** Token must be cryptographically valid, not expired, not revoked
**Errors:**
- Token expired: → Step 1b (Expiry screen)
- Token invalid/malformed: → Error screen "Invalid link — contact your TA coordinator"
- Token already fully consumed (all candidates scored): shows SessionComplete view (read-only)

---

### Step 1b: Expiry Screen
**Screen:** /kit/:token (expired state)
**Actor sees:**
- "This interview link has expired"
- Expired at: [timestamp]
- [Button] Request New Link
**Actor does:** Taps [Request New Link]
**System does:** POST /kit/{token}/request-renewal → sends email to TA Coordinator with HM identity and session info
**System response to HM:** "Your request has been sent to the TA team. You will receive a new link by email shortly."
**Errors:** If token is so old the session is archived: "This event has ended. No new link is available."

---

### Step 2: Session Header + Expiry Indicator
**Screen:** /kit/:token (loaded state)
**Actor sees:**
- Session info banner: Event name | Date | Room | Shift time (e.g., "10:00 AM – 12:00 PM")
- Interviewer identity: "You are: [HM Name] | [Job Title]"
- Expiry indicator:
  - > 4h remaining: green — "Link valid until [datetime]"
  - 1–4h remaining: amber — "Link expires in [Xh Ym] — consider requesting a new one"
  - < 1h remaining: red banner — "Link expires in [Xm] — request a new link now"
  - [CTA] Request New Link (visible when < 1h remaining)
- Completion progress: "X of Y candidates reviewed"
**Actor does:** Reviews session context before proceeding to queue
**System does:** No additional API call; data pre-loaded from token resolution

---

### Step 3: Candidate Queue
**Screen:** /kit/:token (main view, below session header)
**Actor sees:**
- Ordered list of candidates assigned to this session
- Each row:
  - SBD | Full Name | Track
  - Status badge: Pending (grey) / Scored (green) / Skipped (amber)
  - [Button] View (opens candidate detail)
- Candidates with status Pending listed first; Scored and Skipped listed below
- Filter toggle: [All] [Pending] [Scored] [Skipped]
**Actor does:** Taps/clicks a candidate row
**System does:** Navigates to Step 4

---

### Step 4: Candidate Detail
**Screen:** /kit/:token/candidate/:candidateId
**Actor sees:**
- Candidate info block: SBD, full name, track, registration timestamp
- Registration answers: track-specific screening question responses
- CV: inline PDF preview with download option (PDF rendering, no PII leakage)
- Status badge (current state)
- Navigation bar: [← Previous Pending] [Next Pending →] (skip Scored/Skipped if all reviewed)
- Action buttons (conditional):
  - If status = Pending: [Submit Score] [Skip]
  - If status = Scored: score and comments shown as read-only; [Request Score Edit]
  - If status = Skipped: skip reason shown as read-only; no further action
**Actor does:** Reviews profile then chooses action
**System does:** GET /kit/{token}/candidate/{candidateId} (pre-loaded; cached)
**Errors:**
- Candidate not in this session: 404 → returns to queue

---

### Step 5: Score Submission
**Screen:** Score modal (overlay on candidate detail)
**Actor sees:**
- Modal header: "Submit Score for [Candidate Name]"
- Score rubric:
  - If track configured with dimension scoring: 3–5 dimension sliders or numeric inputs (e.g., Technical: 1–5, Communication: 1–5, Problem Solving: 1–5)
  - If track configured with overall score only: single score input (e.g., 1–10 or 0–100)
- Overall comments: text area (optional, max 500 chars)
- Warning notice: "Score submission is permanent and cannot be undone"
- [Button] Submit Score → triggers confirmation dialog
- [Button] Cancel → closes modal, no state change
**Actor does:** Enters score(s), optional comments, taps [Submit Score]
**Validation:**
- All configured dimension scores required if dimension scoring mode
- Overall score required; must be within configured range
- Comments: optional but max 500 characters

**Confirmation Dialog:**
- "Are you sure? Once submitted, scores cannot be changed."
- [Button] Yes, Submit Score (primary)
- [Button] Go Back (secondary)

**On confirm:**
**System does:** POST /interviews/score with {kitToken, candidateId, scores, comments}
- Candidate status → Scored
- Domain event: InterviewScoreSubmitted
- Modal closes
- Candidate row in queue updates to Scored badge
- Completion counter increments
**Errors:**
- Network error: "Submission failed — check your connection and try again" (retry safe as long as token still valid)
- Token expired mid-action: "Your session has expired. Please request a new link." (score not saved)
- Duplicate submission (race condition): "Score already submitted for this candidate"

---

### Step 6: Skip Candidate
**Screen:** Skip modal (overlay on candidate detail)
**Actor sees:**
- Modal header: "Skip [Candidate Name]"
- Required: Skip reason dropdown
  - Options: No show / Candidate withdrew / Technical issue / Other
- Optional: Additional notes (text area, max 200 chars)
- [Button] Confirm Skip
- [Button] Cancel
**Actor does:** Selects reason, optional notes, taps [Confirm Skip]
**System does:** POST /interviews/skip with {kitToken, candidateId, reason, notes}
- Candidate status → Skipped
- Domain event: CandidateSkipped
**Errors:**
- Skip reason not selected: "Please select a reason for skipping"
- Network error: same retry behavior as score submission

---

### Step 7: Session Complete
**Screen:** /kit/:token (all candidates Scored or Skipped)
**Actor sees:**
- Banner: "Session complete — all candidates reviewed"
- Summary: X scored, Y skipped out of total Z
- All candidate rows shown in read-only state
- [Button] Request Score Edit (on any Scored row) — routes to ECR-T-015
**Actor does:** Reviews summary; may request score edits if needed
**System does:** No further actions; view-only mode

---

## Notifications Triggered

| Trigger | Domain Event | Recipient | Channel |
|---------|-------------|-----------|---------|
| KitLink accessed | KitLinkAccessed | TA (audit log only) | Audit |
| Score submitted | InterviewScoreSubmitted | TA (dashboard count update) | Real-time dashboard |
| Candidate skipped | CandidateSkipped | TA (dashboard count update) | Real-time dashboard |
| Link expiry requested | KitLinkRenewalRequested | TA Coordinator | Email |
| All session candidates reviewed | SessionComplete | TA (dashboard indicator) | Real-time dashboard |

---

## Business Rules Enforced

| Rule | Where Enforced |
|------|----------------|
| Score submission is irreversible | Step 5: mandatory confirmation dialog; POST is idempotent-guarded |
| KitLink scoped to single session only | Token contains session_id; any attempt to access other sessions rejected |
| KitLink TTL = 24 hours | Step 1 validation; expiry warning shown from 4h remaining |
| HM sees only SBD, name, track, answers — no raw ID number or phone | Candidate detail screen: PII fields excluded from API response at data layer |
| Score range validated server-side | POST /interviews/score rejects out-of-range scores |
| Skip reason is mandatory | Step 6: required field; submit disabled without selection |
| One score per candidate per session per HM | Duplicate submission rejected with error |

---

## Empty State

- Session with zero candidates assigned: "No candidates assigned to your session. Contact your TA coordinator."
- All candidates already scored (returning to link): Session Complete view (read-only)

---

## Edge Cases

| Scenario | Handling |
|----------|----------|
| HM opens same KitLink on two devices | Both devices show same state; second score submission returns "already submitted" |
| HM submits score just as token expires | Server validates token on POST; if expired, rejects with 401; HM sees "Session expired" error and cannot submit |
| Candidate checked-in late (after HM already reviewed queue) | Candidate appears in queue if they check in before HM completes session; status shows as Pending |
| Network drops during score submission (POST in flight) | Client retries up to 3 times; if all fail, error shown with "Try Again" button |
| Candidate has no CV uploaded | CV section shows "No CV uploaded" placeholder; scoring still available |
| Multiple HMs share a session (co-interviewers) | Each HM has their own KitLink; each submits their own score; scores aggregated at report level |
