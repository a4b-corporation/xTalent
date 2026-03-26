# Use Case: Register Candidate (Online Portal)
## Bounded Context: Candidate Registration
## ECR Module | 2026-03-25

**Actor:** Candidate (self-service) or TA Coordinator (admin entry)
**Trigger:** Candidate submits the registration form on the online portal, or TA Coordinator submits on behalf
**Preconditions:**
- Event is in Registration Open state (verified by checking `EventPublished` / `RegistrationOpened` event)
- Event `registration_deadline` has not passed (if set)
- The targeted Track has available capacity OR waitlist is enabled

**Postconditions:**
- A `CandidateEventRegistration` exists with status Confirmed or Waitlisted
- SBD is assigned and immutable (BR-01)
- DuplicateFlag is raised if multi-factor dedup finds a match (BR-02)
- `CandidateRegistered` domain event emitted
- If Confirmed: `CandidateConfirmed` emitted; triggers slot allocation and confirmation email
- If Waitlisted: `CandidateWaitlisted` emitted; triggers waitlist notification email

**Business Rules:** BR-01, BR-02, BR-03, BR-10

---

## Happy Path (Confirmed)

1. Candidate opens the event registration portal and selects the target Track.
2. Candidate fills in the RegistrationForm fields (name, phone, email, student ID, additional fields).
3. Candidate submits the form.
4. System validates form fields against RegistrationForm schema (required fields, format rules).
5. System checks event and track eligibility: Event is Registration Open; Track capacity has space.
6. System generates SBD from the server-side sequence for this event (BR-01). SBD is assigned immediately, before any email is sent.
7. System runs multi-factor duplicate detection: compares phone number and student ID against all existing registrations for this event.
8. No duplicate found. System creates `CandidateEventRegistration` with:
   - `registration_status = CONFIRMED`
   - `registration_source = ONLINE`
   - `registered_at = now()`
   - `sbd` value object assigned
9. System emits `CandidateRegistered` (SBD assigned, source = ONLINE).
10. System emits `CandidateConfirmed` (triggers slot allocation in Schedule & Capacity BC).
11. System triggers confirmation email dispatch via Communication BC.
12. System displays confirmation page to candidate with their SBD number and slot details (when allocated).

---

## Alternate Flows

### A1: Track at Capacity — Placed on Waitlist

At step 5:
- Track capacity is full (all slots allocated or confirmed count = capacity).
- Waitlist is enabled for this Track.
- System continues to step 6: SBD is still generated at capture (BR-01).
- System creates CandidateEventRegistration with `registration_status = WAITLISTED`.
- System creates WaitlistEntry with `waitlisted_at = now()` (FCFS timestamp).
- System emits `CandidateRegistered`, then `CandidateWaitlisted`.
- Communication BC sends waitlist notification email.
- System displays: "You have been registered and placed on the waitlist at position [N]."

### A2: Duplicate Detected — Flagged, Still Registered

At step 7:
- Duplicate detection finds a phone number or student ID match.
- System still creates the registration (does not reject).
- System creates a `DuplicateFlag` entity linked to this registration and the matched one.
- System emits `DuplicateRegistered`, then `DuplicateFlagRaised`.
- TA Coordinator receives a notification to review the flag.
- Registration status is set to PENDING (not auto-confirmed) pending duplicate resolution.
- Candidate receives a holding notification: "Your registration has been received and is under review."

### A3: Admin Registration by TA Coordinator

Actor is TA Coordinator (not candidate).
- Flow is identical to Happy Path except `registration_source = ONLINE` may be replaced with a TA-entered import marker.
- TA Coordinator may enter data for a candidate who is present but cannot self-register.

---

## Error Flows

### E1: Registration Deadline Passed

At step 5:
- System checks `registration_deadline` and finds it has passed.
- System rejects the submission.
- System displays: "Registration for this event has closed."
- No CandidateEventRegistration created. No SBD assigned.

### E2: Event Not in Registration Open State

At step 5:
- Event state is not `REGISTRATION_OPEN` (e.g., still Published or already In Progress).
- System rejects the submission.
- System displays: "Registration is not currently open for this event."

### E3: Form Validation Failure

At step 4:
- Required fields are missing or format validation fails (e.g., invalid email format).
- System returns validation errors to the candidate.
- No record created. Candidate corrects and resubmits.

### E4: SBD Generation Failure (System Error)

At step 6:
- SBD counter service is unavailable.
- System does not create the registration (atomic: no SBD = no record).
- System displays: "Registration could not be completed. Please try again."
- Alert generated for system administrator.

### E5: Track Capacity Full, No Waitlist

At step 5:
- Track capacity is full AND waitlist is not enabled for this Track.
- System rejects the registration.
- System displays: "This track is no longer accepting registrations."

---

## Domain Events Emitted

- `CandidateRegistered` — when CandidateEventRegistration is created and SBD assigned
- `CandidateConfirmed` — when registration status is set to Confirmed (Happy Path)
- `CandidateWaitlisted` — when registration is placed on the waitlist (Alternate A1)
- `DuplicateFlagRaised` — when multi-factor dedup detects a potential match (Alternate A2)

---

## Sequence Diagram

```
Candidate          Portal          RegistrationBC      DedupService     CommBC
   │                  │                  │                  │               │
   │─── Submit Form ──►│                  │                  │               │
   │                  │─── ValidateForm ─►│                  │               │
   │                  │                  │─── GenerateSBD ──►│               │
   │                  │                  │◄── SBD Assigned ──│               │
   │                  │                  │─── RunDedup ──────►│               │
   │                  │                  │◄── No Match ───────│               │
   │                  │                  │── CreateRegistration()             │
   │                  │                  │── Emit CandidateRegistered         │
   │                  │                  │── Emit CandidateConfirmed ─────────►│
   │                  │◄── Confirmed ────│                  │               │
   │◄── Show SBD ─────│                  │                  │               │
```

---

## Notes

- SBD generation is the most critical step. It must never be deferred to a background process. The SBD must be present in the registration record before the record is persisted.
- Duplicate detection does not block registration — it flags for review. This is a deliberate business decision (BR-02) to avoid false rejections at high volume.
- The transition from PENDING to CONFIRMED is atomic with SBD assignment for non-duplicate cases. For duplicate-flagged cases, PENDING is the holding state until TA Coordinator resolves.
