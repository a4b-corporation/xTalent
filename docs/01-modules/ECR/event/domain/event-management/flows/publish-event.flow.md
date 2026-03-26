# Use Case: Publish Event
## Bounded Context: Event Management
## ECR Module | 2026-03-25

**Actor:** TA Coordinator
**Trigger:** TA Coordinator selects "Publish Event" action on a Draft event
**Preconditions:**
- Event is in Draft state
- TA Coordinator has Event Manager role for this event (validated via xTalent RBAC)
- Event has a defined title and date range

**Postconditions:**
- Event is in Published state
- `EventPublished` domain event is emitted
- Event is visible to candidates via the registration portal
- All downstream contexts receive `EventPublished`

**Business Rules:** BR-06 (structural immutability — not yet active, but publishing validates preconditions for it)

---

## Happy Path

1. TA Coordinator opens the Event detail view for a Draft event.
2. System displays the event configuration summary: title, date range, tracks, registration form.
3. TA Coordinator selects "Publish Event."
4. System validates transition guards:
   - Event has at least 1 Track with positive capacity.
   - Event has a defined RegistrationForm with at least 1 required field.
   - Event start date is in the future.
   - Event title is non-empty.
5. All guards pass. System transitions Event state from `DRAFT` to `PUBLISHED`.
6. System emits `EventPublished` domain event with: `eventId`, `title`, `startDate`, `endDate`, `actorId`, `occurredAt`.
7. System displays confirmation: "Event published. Candidates can now see this event."
8. Event appears in the public-facing event listing.

---

## Alternate Flows

### A1: Publish with Registration Window Configured

At step 3, TA Coordinator also sets a `registrationDeadline` before publishing.

- System validates that `registrationDeadline` is before `startDate`.
- Publication proceeds normally.
- `EventPublished` event includes `registrationDeadline` in payload.
- Registration portal displays the deadline to candidates.

### A2: Re-Publish After Returning to Draft

An event may be returned to Draft from Published state if no registrations have been received.

At step 1:
- Event is in Published state with zero registrations.
- TA Coordinator selects "Revert to Draft" — separate use case.
- After returning to Draft, TA Coordinator may re-configure and re-publish.
- Step 4 guards apply identically.

---

## Error Flows

### E1: Insufficient Tracks

At step 4:
- Guard fails: Event has zero Tracks.
- System rejects the command.
- System displays: "Cannot publish event. At least one Track with defined capacity is required."
- Event remains in Draft state.
- Recovery: TA Coordinator adds a Track, then retries.

### E2: Missing Registration Form

At step 4:
- Guard fails: RegistrationForm has no fields defined.
- System rejects the command.
- System displays: "Cannot publish event. Registration form must have at least one field."
- Event remains in Draft state.
- Recovery: TA Coordinator configures RegistrationForm fields.

### E3: Past Event Date

At step 4:
- Guard fails: `startDate` is in the past.
- System rejects the command.
- System displays: "Cannot publish event. Event start date must be in the future."
- Recovery: TA Coordinator updates the event date range.

### E4: Insufficient RBAC

At step 3:
- xTalent RBAC returns: actor does not have Event Manager role for this event.
- System rejects the command with 403 response.
- System displays: "You do not have permission to publish this event."
- No state change occurs. No domain event emitted.

---

## Domain Events Emitted

- `EventPublished` — when all transition guards pass and state transitions to PUBLISHED

---

## Notes

- The `Publish` action is a one-way transition. An event cannot be "unpublished" once candidates have registered (see A2 for the pre-registration exception).
- All guard evaluations are performed by the Event aggregate root, not by application service logic. This ensures the aggregate's invariants are the single source of truth.
- This use case does not trigger any communication to candidates. Communication (announcement emails) is a configurable option handled by BC-07 Communication, which subscribes to `EventPublished`.
