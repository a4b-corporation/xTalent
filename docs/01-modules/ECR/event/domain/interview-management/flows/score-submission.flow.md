# Use Case: Score Submission and Edit Request Workflow
## Bounded Context: Interview Management
## ECR Module | 2026-03-25

**Actor:** Interviewer (score submission); TA Coordinator (edit request review)
**Trigger:**
- Score Submission: Interviewer completes evaluation of a candidate and submits the scoring form via KitLink
- Score Edit Request: Interviewer realizes an error in a submitted score and requests amendment
- Edit Review: TA Coordinator reviews and approves or rejects a pending ScoreEditRequest

**Preconditions (Score Submission):**
- Interviewer has a valid, non-expired KitLink for the InterviewSession
- Event is in `IN_PROGRESS` state
- Candidate is in the session's queue with status Confirmed or Provisional (Provisional allowed but flagged)
- The scoring form for this (session, candidate, interviewer) combination has not yet been submitted

**Preconditions (Edit Request):**
- An InterviewScore exists with `score_status = ACTIVE` for this (session, candidate, interviewer)
- KitLink is still valid OR interviewer submits edit request via separate channel (TA Coordinator portal)
- At least one ScoreEditRequest is not already PENDING for this score (system prevents duplicate edit requests)

**Postconditions (Score Submission):**
- An immutable `InterviewScore` record exists with `score_status = ACTIVE`
- `InterviewScoreSubmitted` domain event is emitted
- Analytics & Audit BC records the submission as an audit entry

**Postconditions (Edit Request Approved):**
- A new `InterviewScore` is created with the amended values; `score_status = ACTIVE`
- The original `InterviewScore.score_status` is set to `SUPERSEDED`; `superseded_by_score_id` is populated
- `ScoreEditApproved` domain event is emitted
- Analytics & Audit BC records both the original score supersession and the new score as audit entries (BR-04)

**Business Rules:** BR-04

---

## Happy Path: Score Submission

1. Interviewer opens their KitLink URL in a browser.
2. Server validates KitLink: `url_token` valid, `is_active = true`, `current_time < expiry_at` (BR-05).
3. Interviewer sees the live candidate queue. Candidate [X] is marked as `Confirmed` (CheckInConfirmed received).
4. Interviewer clicks candidate [X] to open the scoring form.
5. The scoring form displays criterion fields defined by the Track's scoring template (e.g., Technical Knowledge 40%, Communication 30%, Problem Solving 30%).
6. Interviewer enters a raw score for each criterion and selects a recommendation (Pass / Fail / Hold).
7. Interviewer adds optional notes per criterion.
8. Interviewer clicks "Submit Score."
9. System validates:
   - All required criterion fields are filled.
   - Raw scores are within the configured range (e.g., 0–10).
   - No existing ACTIVE InterviewScore for this (session, candidate, interviewer) triple (idempotency check).
10. System computes `weighted_score` per criterion (`raw_score × criterion_weight`).
11. System computes `total_score` = sum of weighted scores.
12. System creates `InterviewScore`:
    - `score_status = ACTIVE`
    - `submitted_at = server_now()`
    - All criterion components captured as immutable ScoreComponent value objects
    - `sbd_number` captured at submission time (from candidate's current SBD — stored for audit stability)
13. System emits `InterviewScoreSubmitted`.
14. System displays to interviewer: "Score submitted. This score is now locked." Scoring form transitions to read-only view showing the submitted values.
15. Analytics & Audit BC receives `InterviewScoreSubmitted` and creates an `AuditEntry`.

---

## Happy Path: Score Edit Request

1. Interviewer reviews their submitted score (via KitLink or TA Coordinator portal) and notices an error.
2. Interviewer clicks "Request Score Correction" on the read-only score view.
3. System displays the ScoreEditRequest form:
   - Shows the current submitted score values (read-only reference)
   - Provides editable fields for each criterion's proposed new values and recommendation
   - Requires a mandatory `reason` text field
4. Interviewer enters proposed amended scores, new recommendation, and justification.
5. Interviewer submits the edit request.
6. System validates:
   - No existing PENDING ScoreEditRequest for this score (duplicate prevention).
   - KitLink is still valid OR request is coming from the TA Coordinator portal (post-expiry channel).
7. System creates `ScoreEditRequest`:
   - `edit_request_status = PENDING`
   - `requested_at = server_now()`
   - `original_score_id` reference
   - Proposed score components captured
8. System emits `ScoreEditRequested`.
9. TA Coordinator receives a notification in the operations dashboard: "Score amendment requested for candidate [SBD] in session [X]."
10. Interviewer sees confirmation: "Your amendment request has been submitted and is pending coordinator review."

---

## Happy Path: TA Coordinator Approves Edit Request

1. TA Coordinator opens the pending ScoreEditRequests list in the operations dashboard.
2. TA Coordinator reviews: original score values vs. proposed amended values, and the reason provided.
3. TA Coordinator clicks "Approve."
4. System processes approval:
   a. Creates a NEW `InterviewScore` with:
      - Amended criterion values (from `proposed_score_components`)
      - Amended `total_score` (recomputed from proposed values)
      - Amended `recommendation`
      - `score_status = ACTIVE`
      - `supersedes_score_id = original_score_id`
      - `edit_request_id = edit_request_id`
      - `submitted_at = reviewed_at` (the approval time is the new score's creation time)
   b. Updates original `InterviewScore`:
      - `score_status = SUPERSEDED`
      - `superseded_by_score_id = new_score_id`
   c. Updates `ScoreEditRequest`:
      - `edit_request_status = APPROVED`
      - `reviewed_by = ta_coordinator_user_id`
      - `reviewed_at = server_now()`
5. System emits `ScoreEditApproved` with both `original_score_id` and `new_score_id`.
6. Analytics & Audit BC receives `ScoreEditApproved` and creates an `AuditEntry` capturing: who requested, who approved, original values, new values, reason (BR-04).
7. TA Coordinator sees: "Amendment approved. New score is now active."
8. Interviewer (if still accessing the kit) sees the updated score values in their read-only view.

---

## Alternate Flows

### A1: Candidate Is in Provisional State at Submission Time

At step 3:
- Candidate is in the queue with Provisional status (CheckInCaptured received but CheckInConfirmed not yet received — e.g., kiosk was offline).
- Scoring is allowed on Provisional candidates (operational decision — do not block interviewers).
- Score form displays a warning: "This candidate's check-in is pending server confirmation. You may score now; the score will be retained regardless of sync outcome."
- Score submission proceeds normally.
- If the sync later results in a CONFLICT (CheckInConflict), the InterviewScore is not automatically deleted — TA Coordinator handles the conflict resolution for both the check-in and the score.

### A2: Submission Rejected — Duplicate Score

At step 9:
- An ACTIVE InterviewScore already exists for this (session, candidate, interviewer) triple.
- System displays: "You have already submitted a score for this candidate. To amend it, use the 'Request Score Correction' option."
- No new InterviewScore is created.
- Interviewer is directed to the edit request flow.

### A3: Edit Request Denied

After TA Coordinator reviews the ScoreEditRequest:
- TA Coordinator clicks "Reject" and enters review notes explaining the reason.
- System updates `ScoreEditRequest.edit_request_status = REJECTED`.
- Original `InterviewScore` remains `ACTIVE` — unchanged.
- System emits `ScoreEditRejected`.
- Analytics & Audit BC records the rejected edit request as an AuditEntry.
- Interviewer receives a notification: "Your amendment request was not approved. [Review notes]."

### A4: Post-Expiry Score Access (KitLink Expired)

After the KitLink has expired:
- Interviewer cannot access the scoring form via their KitLink.
- If the interviewer needs to submit a score they forgot or request an amendment, they must contact the TA Coordinator directly.
- TA Coordinator can enter a score on behalf of the interviewer, or submit a ScoreEditRequest via the TA Coordinator portal (which is not gated by KitLink expiry).
- Any TA Coordinator-submitted score is annotated with `requested_by = ta_coordinator_user_id` and creates a full audit trail.

---

## Error Flows

### E1: KitLink Expired at Submission Attempt

At step 2:
- `current_time >= KitLink.expiry_at`.
- Server returns HTTP 403.
- `KitLinkExpired` event is emitted (if not already emitted for this token).
- Interviewer sees: "Your interview kit link has expired (valid until [expiry_at]). Please contact your TA Coordinator."
- No score submission possible via this path. See Alternate A4.

### E2: Score Submission After Session Completed

At step 9:
- The InterviewSession has transitioned to `COMPLETED` or `SKIPPED` state.
- System rejects the submission if the session is COMPLETED and the event has closed.
- During an active event (IN_PROGRESS), session state alone does not block score submission — a session may be marked COMPLETED administratively but scores may still arrive for stragglers.
- Business decision: score acceptance window = KitLink validity window (24h post-event). After that, only TA Coordinator portal access.

### E3: Total Score Exceeds Maximum

At step 9 (computed validation):
- The weighted total exceeds the maximum configured for the scoring template.
- System returns: "Submitted scores exceed the maximum allowed total. Please review your criterion scores."
- No InterviewScore created. Interviewer corrects and resubmits.

### E4: Duplicate Edit Request Submission

At step 6 (edit request path):
- A PENDING ScoreEditRequest already exists for this InterviewScore.
- System displays: "An amendment request is already pending coordinator review. You cannot submit another request until the current one is resolved."
- No new ScoreEditRequest created.

---

## Domain Events Emitted

- `InterviewScoreSubmitted` — when a new InterviewScore is created post-submission
- `ScoreEditRequested` — when an interviewer submits a ScoreEditRequest
- `ScoreEditApproved` — when a TA Coordinator approves; new score created, original superseded
- `ScoreEditRejected` — when a TA Coordinator rejects; original score unchanged
- `KitLinkExpired` — when server-side validation rejects a request due to expiry
- `CandidateSkipped` — when an interviewer marks a candidate as no-show or skipped (separate flow, shares this context)

---

## Sequence Diagram: Score Submission + Edit Request

```
Interviewer    KitLink Svc    Interview Mgmt    Audit BC         TA Coordinator
    │               │               │               │                  │
    │── GET /kit/{token} ───────────►│               │                  │
    │               │── Validate expiry              │                  │
    │◄── Kit View ──────────────────│               │                  │
    │── Submit Score ───────────────►│               │                  │
    │               │── CreateInterviewScore(ACTIVE)  │                  │
    │               │── Emit ScoreSubmitted ──────────►│                  │
    │◄── "Score Locked" ────────────│               │                  │
    │                               │               │                  │
    │── Request Amendment ──────────►│               │                  │
    │               │── CreateScoreEditRequest(PENDING)│                  │
    │               │── Emit ScoreEditRequested      │                  │
    │◄── "Request Submitted" ────────│               │                  │
    │                               │── Notify ──────────────────────►│
    │                               │               │  TA reviews      │
    │                               │◄── Approve ─────────────────────│
    │               │── CreateNewScore(ACTIVE)        │                  │
    │               │── UpdateOriginal(SUPERSEDED)    │                  │
    │               │── Emit ScoreEditApproved ───────►│                  │
    │               │               │── AuditEntry (both scores)        │
    │◄── Updated View ──────────────│               │                  │
```

---

## Notes

- **Immutability is non-negotiable.** BR-04 requires that InterviewScore records are never updated in-place. The ScoreEditRequest mechanism creates a new record and marks the old one as SUPERSEDED. Both records are retained indefinitely in the audit log. This is not merely a technical choice — it is a data integrity requirement to ensure score history is tamper-evident.
- **The approval flow adds latency.** TA Coordinator approval is required for every score amendment. This means an interviewer cannot immediately correct a typo. The business rationale: unilateral score corrections after submission would undermine the integrity of the recruitment process. The approval step adds a human check.
- **AuditEntry for every ScoreEditApproved is mandatory.** The AuditEntry must capture: who made the edit request, who approved it, the original score values, the new score values, and the stated reason. This is a compliance requirement (BR-04), not an optional enhancement.
- **Provisional candidates.** Interviewers should not be blocked from scoring candidates whose check-in is still Provisional. In a fast-paced event environment, waiting for server sync confirmation would create unacceptable delays. The score is valid regardless of the check-in sync outcome — these are independent records in independent bounded contexts.
