# ECR-T-015: Score Edit Request
**Type:** Transaction | **Priority:** P2 | **BC:** BC-06
**Permission:** ecr.interview.score.edit.request (HM via KitLink), ecr.interview.score.edit.approve (TA)

## Purpose

Allows a Hiring Manager to request a correction to a score they have already submitted. Because score submission is irreversible by design (ECR-T-014), a governed unlock workflow is required: HM submits a reason-backed request, TA reviews and approves or rejects, and if approved the HM is re-issued a time-limited edit window. A full audit chain is maintained: original score, request reason, approver identity, new score, and timestamp are all recorded. This ensures data integrity while providing a controlled escape hatch for genuine data-entry errors.

---

## States

| State | Description | Entry | Exit Transitions |
|-------|-------------|-------|-----------------|
| Scored | Score has been submitted; read-only | POST /interviews/score succeeds | ScoreEditRequested (on HM request) |
| ScoreEditRequested | HM has submitted an edit request; awaiting TA review | HM submits reason text | ScoreEditApproved, ScoreEditRejected |
| ScoreEditApproved | TA approved the request; HM has a time-limited edit window open | TA approves | ScoreResubmitted (on new submission) |
| ScoreEditRejected | TA rejected the request; original score stands | TA rejects with reason | (terminal; further request possible) |
| ScoreResubmitted | HM has submitted corrected score within the edit window | HM submits new score | (terminal; Scored again with audit chain) |
| EditWindowExpired | HM did not resubmit within the edit window (30 min) | Timer elapses after approval | (terminal; original score stands) |

---

## Flow

### Step 1: HM Initiates Edit Request
**Screen:** /kit/:token/candidate/:candidateId (Scored state — from ECR-T-014 Step 4 or Step 7)
**Actor sees:**
- Candidate row or detail panel showing score as read-only (score value + submitted timestamp)
- [Button] Request Score Edit
**Actor does:** Taps [Request Score Edit]
**System does:** Opens the Score Edit Request modal
**Validation:** Button is only active when candidate status = Scored and no pending ScoreEditRequest already open for this candidate + HM pair
**Errors:**
- Already pending request: button shows "Edit request pending — awaiting TA review" (disabled)
- Edit window already expired: button shows "Edit window closed — contact TA coordinator"

---

### Step 2: HM Submits Edit Reason
**Screen:** Score Edit Request modal (overlay)
**Actor sees:**
- Modal header: "Request Score Edit for [Candidate Name]"
- Read-only display of current score (score value, submission timestamp)
- Required field: Reason for edit request (text area, max 500 chars)
- Placeholder hint: "Describe what needs to be corrected and why (e.g., entered wrong dimension score)"
- [Button] Submit Request (primary)
- [Button] Cancel (secondary)
**Actor does:** Types reason text, taps [Submit Request]
**System does:** POST /interviews/score-edit-requests with {kitToken, candidateId, originalScoreId, reason}
- Domain event: ScoreEditRequested
- TA Coordinator receives in-app notification and email
- Modal closes; candidate row shows "Edit Requested" amber badge
**Validation:**
- Reason text is required; minimum 10 characters; maximum 500 characters
- Submit button disabled until validation passes
**Errors:**
- Reason empty or < 10 chars: inline error "Please describe the reason for the edit request (min 10 characters)"
- Network error: "Request failed — please try again. Your score has not been changed."
- Token expired: "Your session link has expired. Contact your TA coordinator to submit an edit request."

---

### Step 3: TA Reviews Edit Request
**Screen:** Event Management > Interviews > Score Edit Requests tab
**Actor sees:**
- Paginated list of pending ScoreEditRequests for the current event
- Each row:
  - Candidate: SBD, full name, track
  - Session: room, shift time
  - HM: name + job title
  - Original score summary (overall score; dimension scores if applicable)
  - Request reason (truncated; expandable)
  - Requested at timestamp
  - Action buttons: [Approve] [Reject]
- Filter: [All Requests] [Pending] [Resolved]
**Actor does:** Reviews request details; may click row to expand full reason text
**System does:** GET /interviews/score-edit-requests?eventId={id}&status=pending
**Errors:**
- Empty list: "No pending score edit requests." (informational; not an error)

---

### Step 4: TA Approves or Rejects
**Screen:** Inline confirmation within the Score Edit Requests table row (no page navigation)

#### Approve Path
**Actor sees:** Approval confirmation popover: "Approve edit request for [Candidate Name]? HM will receive a 30-minute edit window."
**Actor does:** Taps [Confirm Approve]
**System does:** POST /interviews/score-edit-requests/{requestId}/approve
- Domain event: ScoreEditApproved
- Candidate status transitions to ScoreEditApproved
- Edit window timer starts (30 minutes from approval timestamp)
- HM receives email notification: "Your score edit request has been approved. You have 30 minutes to submit a corrected score."
- Email contains same KitLink (if still valid) or a new single-use edit link
**Errors:**
- Request already resolved (race condition with another TA): "This request was already [approved/rejected] by [other TA name]"
- Network error: "Action failed — please try again"

#### Reject Path
**Actor sees:** Rejection confirmation popover with required reason field
**Actor does:** Types rejection reason (required, max 200 chars), taps [Confirm Reject]
**System does:** POST /interviews/score-edit-requests/{requestId}/reject with {reason}
- Domain event: ScoreEditRejected
- Candidate status stays Scored; request shows Rejected with TA reason
- HM receives email notification: "Your score edit request was not approved. Reason: [reason]. Contact your TA coordinator if you need further assistance."
**Validation:** Rejection reason required before confirming
**Errors:**
- Reason empty: "Please provide a reason for rejecting the request"

---

### Step 5: HM Resubmits Corrected Score
**Screen:** /kit/:token/candidate/:candidateId (ScoreEditApproved state)
**Actor sees:**
- Amber banner at top: "Score Edit Approved — you have [Xm] remaining to submit a corrected score"
- Edit window countdown timer (updates every 60 seconds)
- Original score displayed as read-only reference block: "Original score: [values] — submitted [timestamp]"
- Score entry form (same rubric as original submission in ECR-T-014 Step 5)
- [Button] Submit Corrected Score → same confirmation dialog as original
- Warning: "Once submitted, this corrected score replaces the original and cannot be changed again"
**Actor does:** Adjusts scores, enters corrected values, taps [Submit Corrected Score]
**System does:** POST /interviews/score-edit-requests/{requestId}/resubmit with {newScores, comments}
- Original score preserved in audit log (score_history table)
- Candidate status returns to Scored with new score values
- Domain event: ScoreResubmitted
- request status → ScoreResubmitted
- Edit window timer closes
**Validation:**
- Same score range validation as original submission
- All required dimensions must have values
**Errors:**
- Edit window expired during HM review: "Your edit window has expired. Your original score stands. Contact TA to request a new edit window."
- Submission after expiry attempted (server-side guard): 409 Conflict → "Edit window expired — score not updated"
- Network error: retry up to 3 times before showing error with [Try Again] button

---

### Step 6: Edit Window Expiry (No Resubmission)
**Screen:** /kit/:token/candidate/:candidateId (EditWindowExpired state)
**Actor sees:**
- Red banner: "Your edit window has expired. The original score remains on record."
- Original score shown as read-only
- [Button] Request New Edit Window (re-initiates Step 1 → Step 2 flow)
**System does:** No score change; audit log records that edit window expired without resubmission

---

## Notifications Triggered

| Trigger | Domain Event | Recipient | Channel |
|---------|-------------|-----------|---------|
| HM submits edit request | ScoreEditRequested | TA Coordinator | Email + In-app notification |
| TA approves request | ScoreEditApproved | HM | Email (with edit link) |
| TA rejects request | ScoreEditRejected | HM | Email |
| Edit window expires (no resubmit) | EditWindowExpired | TA (audit only) | Audit log |
| HM resubmits corrected score | ScoreResubmitted | TA Coordinator | In-app notification |

---

## Business Rules Enforced

| Rule | Where Enforced |
|------|----------------|
| Only Scored candidates can have edit requests raised | Step 1: button inactive unless status = Scored |
| Reason text is mandatory for all requests | Step 2: required field; submit blocked |
| Only one open edit request per candidate per HM per session | Step 1: duplicate request blocked |
| Edit window is 30 minutes from TA approval | System-generated timer; server-side expiry check on resubmit |
| Original score is preserved in audit log | POST /resubmit: inserts score_history record before updating active score |
| TA rejection reason is required | Step 4 rejection path: required field |
| A second edit request can be raised after rejection | Step 6: [Request New Edit Window] re-enters flow from Step 1 |
| TA cannot edit scores directly — only approves/rejects unlock | TA has no POST /interviews/score endpoint; only unlock approval |

---

## Empty State

- Score Edit Requests tab with no requests: "No score edit requests for this event."
- Candidate with no prior score submitted: [Request Score Edit] button is not rendered (only appears in Scored state)

---

## Edge Cases

| Scenario | Handling |
|----------|----------|
| HM's KitLink expires before edit window | TA issues a single-use edit link tied to the approved request ID (not the original KitLink) |
| Two TAs simultaneously approve/reject the same request | First action wins; second receives: "This request was already resolved by [name]" |
| HM submits corrected score identical to original | System accepts; records are updated with new submission timestamp; audit log notes no numeric change |
| Edit window timer elapses between HM loading the form and submitting | Server-side expiry check on POST rejects submission with 409; client displays expiry error |
| HM raises multiple edit requests for different candidates in same session | Permitted; each is an independent request with its own approval flow |
| Session archived before TA reviews request | Pending requests remain visible in TA queue; approval still possible; HM receives single-use edit link |
