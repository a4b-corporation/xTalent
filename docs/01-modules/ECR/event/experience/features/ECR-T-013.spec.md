# ECR-T-013: Session Digest Dispatch
**Type:** Transaction | **Priority:** P1 | **BC:** BC-06
**Permission:** ecr.digest.manage

## Purpose

Allows TA staff to notify Hiring Manager (HM) interviewers about their upcoming interview session. For each assigned interviewer, a KitLink (unique deep link, 24h TTL) is generated and dispatched via email. The email includes the interviewer's candidate list summary and their KitLink for ECR-T-014 (HM Interview Kit). This is the trigger event that activates the interview workflow.

---

## States

| State | Description | Entry Condition | Exit Transitions |
|-------|-------------|----------------|-----------------|
| Ready | Session has assignments; no digest sent yet | HM assignments completed in ECR-M-005 | → Dispatched |
| Dispatched | Digest emails sent; KitLinks active | TA confirms dispatch | → Expired (after 24h TTL) / Re-dispatched |
| Expired | KitLinks exceeded 24h TTL | 24h after dispatch | → Re-dispatched (if TA re-sends) |
| Re-dispatched | New KitLinks generated; old links invalidated | TA triggers re-dispatch | Replaces Dispatched |

---

## Flow

### Step 1: Navigate to Session Digest
**Screen:** /events/:id/sessions or /events/:id/panels → [Send Digest] button
**Actor sees:**
- List of interview sessions (room + slot combinations) with their assignment status
- For each session: room name, date/time, track, interviewer count, digest status (Ready / Dispatched / Expired)
- [Send Digest] button per session; [Send All Pending] bulk button
**Actor does:** Clicks [Send Digest] for a specific session or [Send All Pending]
**System does:** Opens dispatch confirmation modal for selected session(s)
**Validation:** Session must have at least 1 Hard-assigned interviewer
**Errors:** "No interviewers assigned to this session. Assign panelists first (Panel & Interviewer Assignment)."

### Step 2: Dispatch Confirmation
**Screen:** Dispatch confirmation modal
**Actor sees:**
- Session summary: room, time slot, track, candidate count
- List of interviewers to be notified with their email addresses
- Confirmation: "A KitLink valid for 24 hours will be generated for each interviewer."
- If session is Dispatched (re-send case): "Previous KitLinks will be invalidated. Interviewers will receive new links."
- Email template preview button: [Preview Email]
**Actor does:** Reviews; clicks [Send Digest]
**System does:** Proceeds to Step 3
**Validation:** All interviewer email addresses must be valid (validated on panel assignment; shown here as read-only)
**Errors:** "One or more interviewers have invalid email addresses. Update them in Panel Assignment."

### Step 3: KitLink Generation and Email Dispatch
**Screen:** Dispatch modal — processing state (spinner with progress)
**Actor sees:** "Generating KitLinks and sending emails..."
**Actor does:** Waits (typically < 5s for < 10 interviewers)
**System does:**
- For each Hard-assigned interviewer in the session:
  - Generates KitLink: unique signed URL with JWT payload { sessionId, interviewerId, eventId }, 24h TTL
  - Builds email: candidate list preview (names, SBDs, tracks — max 5 names shown, "and N more"), session time, room, KitLink button
  - Queues email via ECR-T-016 dispatch pipeline
- API: `POST /events/:id/sessions/:sessionId/dispatch-digest`
- Emits: `SessionDigestDispatched` { sessionId, kitLinks: [{ interviewerId, kitLinkId, expiresAt }] }
- Emits: `KitLinkGenerated` per interviewer
- Updates session digest_status to Dispatched; records dispatched_at, dispatched_by
**Validation:** Server-side validates session state and interviewer assignments
**Errors:**
- "Dispatch failed: email service unavailable. Please try again." (with retry button)
- "KitLink generation failed for {name}. Partial dispatch completed. Retry for failed interviewers."

### Step 4: Dispatch Confirmation
**Screen:** Dispatch modal → success state
**Actor sees:**
- "Digest sent successfully to N interviewers."
- Per-interviewer status: name, email, sent / failed badge
- KitLink expiry shown: "Links expire at {datetime}"
- [Resend Failed] button (if any failed)
- [Done] closes modal
**Actor does:** Reviews; clicks [Done] or [Resend Failed]
**System does:** Modal closes; session row in list updated to Dispatched status with dispatched_at timestamp

---

## Notifications Triggered

| Trigger | Notification | Recipient |
|---------|-------------|----------|
| Step 3: Dispatch success | Session Digest email with KitLink | Each assigned HM interviewer |
| KitLink expiry (T-2h) | "Your interview kit link expires in 2 hours. Click to access your kit." | Each interviewer (if link not yet accessed) |

---

## Business Rules Enforced

- **BR-DIG-001:** KitLinks expire 24h from generation time, not from email send time.
- **BR-DIG-002:** Re-dispatching a session invalidates all previous KitLinks for that session; old links return 403 with "Link expired or replaced — contact TA for a new link."
- **BR-DIG-003:** Only Hard-assigned interviewers receive KitLinks; Soft assignments are not included in digest dispatch.
- **BR-DIG-004:** TA must have dispatched at least one session digest before the event enters InProgress state (soft warning, not a hard block).
- **BR-DIG-005:** KitLink is per-session per-interviewer; an interviewer with two sessions gets two separate KitLinks.
- **BR-DIG-006:** Digest email must use the SessionDigest template type (ECR-M-006); TA can select from available active templates of this type.

---

## Empty State

"No sessions ready for digest dispatch. Complete interviewer assignments (Panel & Interviewer Assignment) first." with [Go to Panel Assignment] link.

---

## Edge Cases

- Interviewer opens KitLink before event starts: kit is accessible (shows candidate list in preview mode) but score submission is disabled until event is InProgress.
- Dispatch while event is not yet InProgress: allowed (digest can be sent in advance); kit access is permitted in read mode.
- More than 50 interviewers in one batch dispatch: runs async; TA sees progress bar updating every 2s; email confirmation on completion.
- Interviewer claims they didn't receive email: TA can [Resend KitLink] for individual interviewer from the session detail page; generates new link (old one invalidated).
