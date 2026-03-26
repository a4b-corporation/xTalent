# Use Case: Session Digest Dispatch
## Bounded Context: Interview Management
## ECR Module | 2026-03-25

**Actor:** TA Coordinator
**Trigger:** TA Coordinator clicks "Send Session Digest" for one or more InterviewSessions
**Preconditions:**
- Event is in `REGISTRATION_OPEN` or `IN_PROGRESS` state
- InterviewSession has at least 1 `HardAssigned` InterviewerAssignment
- No SessionDigest has been dispatched for this session in the last 60 minutes (rate limit to prevent accidental double-sends; configurable per event)
- TA Coordinator has the required RBAC permission (`ecr.interview.dispatch_digest`)

**Postconditions:**
- A `SessionDigest` entity is created and linked to the InterviewSession
- One `KitLink` is generated per HardAssigned interviewer (`expiry_at = event_date + 24h`)
- `SessionDigestDispatched` domain event is emitted
- Communication BC receives the event and creates a `CommunicationJob` to send the kit email to each interviewer
- Per-interviewer delivery status is tracked in Communication BC's `DeliveryRecord`

**Business Rules:** BR-05

---

## Happy Path

1. TA Coordinator opens the Interview Management dashboard and navigates to the Sessions view.
2. TA Coordinator selects one or more InterviewSessions in `SCHEDULED` or `ACTIVE` state.
3. TA Coordinator clicks "Send Session Digest."
4. System validates preconditions:
   - Each selected session has at least 1 HardAssigned interviewer.
   - Event is in REGISTRATION_OPEN or IN_PROGRESS state.
   - No recent duplicate dispatch within rate-limit window.
5. For each selected session, system generates the SessionDigest content:
   - Event name, date, venue
   - Room name and scheduled time window for this session
   - Track name
   - Candidate list: SBD, name, and slot time for each confirmed candidate currently assigned to this session
   - Scoring template reference (criterion names and weights)
6. For each HardAssigned interviewer in the session, system creates a `KitLink`:
   - `url_token` = cryptographically random opaque token (not guessable)
   - `expiry_at = event_date + 24 hours` (e.g., if event is on 2026-04-10, expiry = 2026-04-11T23:59:59+07:00)
   - `is_active = true`
7. System creates a `SessionDigest` entity:
   - `candidate_count_at_dispatch` = number of confirmed candidates at this moment
   - `dispatched_at = now()`
   - `dispatched_by = ta_coordinator_user_id`
   - Links all generated KitLinks
8. System emits `SessionDigestDispatched` with `digest_id`, `session_id`, and `interviewer_count`.
9. Communication BC receives `SessionDigestDispatched` and creates a `CommunicationJob` with one recipient per HardAssigned interviewer.
10. Communication BC dispatches the kit email to each interviewer. Email contains:
    - Event and session details
    - The interviewer's unique KitLink URL
    - Expiry reminder: "Your interview kit link is valid until [expiry_at]."
    - Instructions for accessing the scoring form
11. TA Coordinator sees a confirmation: "Session Digest sent to [N] interviewer(s)."
12. Each interviewer receives their kit email and can click the KitLink to access their interview kit.

---

## KitLink Access Flow (Interviewer Using the Link)

When an interviewer clicks their KitLink:
1. Browser requests `GET /interview-kit/{url_token}`.
2. Server validates:
   - `url_token` exists in the KitLink table.
   - `KitLink.is_active = true`.
   - `current_server_time < KitLink.expiry_at` (BR-05 — server-side check on every request).
3. On success: server renders the Interview Kit view showing:
   - Live candidate queue for this session (updated in real-time as check-ins arrive)
   - Scoring form per candidate
   - Candidate status indicators (Provisional / Confirmed / Skipped)
4. On expiry (`current_server_time >= expiry_at`):
   - Server returns HTTP 403.
   - Server emits `KitLinkExpired` event (if not already emitted for this token).
   - Response body: "This interview kit link has expired. Please contact your TA Coordinator to access scores."
   - No automatic refresh or re-issue mechanism. Post-expiry score access is via the TA Coordinator portal only.

---

## Alternate Flows

### A1: Re-Dispatch After Candidate List Changes

After the initial dispatch, new candidates check in or are added to the session:
- TA Coordinator may dispatch a second SessionDigest to update interviewers.
- System creates a new `SessionDigest` entity (the previous one is not overwritten — it is retained).
- New KitLinks are NOT generated if existing KitLinks are still active. The same KitLink URL provides a live view of the current queue; interviewers using the original link will see the updated candidate list.
- A re-dispatch email is sent with a note: "Updated candidate list — please refresh your interview kit."
- `candidate_count_at_dispatch` in the new SessionDigest reflects the updated count.

### A2: Dispatch to a Newly Added Interviewer Only

After initial dispatch, a new interviewer is HardAssigned to the session:
- TA Coordinator can trigger a targeted dispatch: "Send to new interviewers only."
- System generates a KitLink for the new interviewer.
- A SessionDigest is created for this targeted send (linked to the session, with `interviewer_count = 1`).
- `SessionDigestDispatched` emitted. Communication BC sends the email to only the new interviewer.
- Existing interviewers are not re-emailed.

### A3: Session Has No Confirmed Candidates at Dispatch Time

At step 5:
- The session has zero confirmed candidates (no check-ins received yet, or all registrations are still Provisional).
- System proceeds with dispatch but sets `candidate_count_at_dispatch = 0`.
- Digest email includes a note: "No candidates have checked in yet. Your live queue will update when candidates arrive."
- KitLinks are generated normally. The live queue view will show candidates as they check in.

---

## Error Flows

### E1: Session Has No HardAssigned Interviewers

At step 4:
- Selected session has zero HardAssigned assignments (all are Soft or none exist).
- System displays: "Cannot send Session Digest: no confirmed interviewers assigned to this session. Please convert at least one assignment to Hard before dispatching."
- No SessionDigest created. No KitLinks generated.

### E2: Event Not in Valid State

At step 4:
- Event is in DRAFT or PUBLISHED state (not yet REGISTRATION_OPEN or IN_PROGRESS).
- System displays: "Session Digest can only be sent once registration is open or the event is in progress."
- No dispatch proceeds.

### E3: Rate Limit — Duplicate Dispatch Detected

At step 4:
- A SessionDigest was dispatched for this session within the last 60 minutes.
- System displays a warning: "A Session Digest was sent [N] minutes ago. Are you sure you want to send again?"
- TA Coordinator must explicitly confirm to override.
- On confirmation: dispatch proceeds (creates a new SessionDigest).
- This prevents accidental double-sends to interviewers.

### E4: Communication BC Delivery Failure

After step 8, Communication BC encounters delivery failures:
- Communication BC retries per its retry policy (exponential backoff).
- If all retries fail: `EmailFailed` event is published by Communication BC.
- Interview Management BC is not responsible for email delivery — it has emitted `SessionDigestDispatched` successfully.
- TA Coordinator is notified via the Communication BC's failure alert mechanism.
- Affected interviewers may be re-dispatched by triggering a new dispatch targeted at them (Alternate A2).

---

## Domain Events Emitted

- `SessionDigestDispatched` — when a SessionDigest is created and ready for communication dispatch
- `KitLinkExpired` — when server-side validation rejects a request due to expiry (first occurrence per token)
- `InterviewerAssigned` — (precursor event, not in this flow, but required for dispatch to have recipients)

---

## Sequence Diagram

```
TA Coordinator    Interview Mgmt    KitLink Store    Communication BC    Interviewer
      │                  │                │                 │                │
      │─── Send Digest ──►│                │                 │                │
      │                  │── Validate ────►│                 │                │
      │                  │── GenKitLinks() │                 │                │
      │                  │◄── Tokens ──────│                 │                │
      │                  │── CreateSessionDigest()            │                │
      │                  │── Emit SessionDigestDispatched ────►│                │
      │◄── Confirmed ────│                │                 │                │
      │                  │                │── CreateJob ────►│                │
      │                  │                │── SendEmail ─────────────────────►│
      │                  │                │                 │◄── DeliveryACK ─│
      │                  │                │                 │                │
      │                  │  (later: interviewer clicks KitLink)               │
      │                  │                │◄──── GET /kit/{token} ────────────│
      │                  │── ValidateToken()── Check expiry                   │
      │                  │── Return Kit View ───────────────────────────────►│
```

---

## Notes

- **KitLink expiry is a business rule, not a convenience feature.** The 24-hour post-event expiry (BR-05) exists to ensure that interviewers cannot access or modify score data indefinitely after the event. This window is intentionally short to protect candidate data and audit integrity. Post-expiry access is controlled, requiring TA Coordinator intervention.
- **The candidate list in the kit is live, not a static snapshot.** The SessionDigest email shows the candidate count at dispatch time as context, but the KitLink view always renders from the current queue state. This means interviewers see real-time check-in status when they open the kit during the event.
- **SoftAssigned interviewers do not receive the kit.** SoftAssignment is a planning artifact. Only HardAssigned interviewers receive KitLinks. If a SoftAssignment needs to be operationally active, it must be promoted to HardAssignment before dispatch.
- **Dispatch is idempotent from the TA Coordinator's perspective.** Clicking "Send Digest" multiple times creates multiple SessionDigest records and may send multiple emails (subject to rate limit). This is intentional — re-dispatch is a valid operation for updating interviewers after changes.
