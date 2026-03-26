# Use Case: Resolve Duplicate Flag
## Bounded Context: Candidate Registration
## ECR Module | 2026-03-25

**Actor:** TA Coordinator
**Trigger:** TA Coordinator opens the Duplicate Review queue and selects a flagged pair
**Preconditions:**
- A DuplicateFlag with `resolution_state = UNRESOLVED` exists
- TA Coordinator has the Duplicate Reviewer role for this Event (xTalent RBAC)
- Event is in Registration Open or In Progress state (resolution is permitted)

**Postconditions:**
- DuplicateFlag `resolution_state` is no longer UNRESOLVED
- One or both registrations have updated status based on resolution action
- `DuplicateResolved` domain event emitted
- AuditEntry created in Analytics & Audit BC
- If a registration was cancelled: `RegistrationCancelled` emitted

**Business Rules:** BR-02 (human resolution only), BR-03 (unresolved blocks bulk ops)

---

## Happy Path (Keep Both)

1. TA Coordinator opens the Duplicate Review queue for the Event.
2. System displays list of unresolved DuplicateFlags with match details (which dimensions matched: phone, student ID, or both).
3. TA Coordinator selects a flag to review.
4. System displays side-by-side comparison: Registration A and Registration B with all PersonalInfo fields highlighted to show which fields matched.
5. TA Coordinator reviews the data and determines both registrations represent distinct candidates (e.g., same phone number used by a parent and child).
6. TA Coordinator selects "Keep Both."
7. System updates DuplicateFlag:
   - `resolution_state = RESOLVED_KEEP_BOTH`
   - `resolved_by = actorId`
   - `resolved_at = now()`
   - `resolution_action = KEEP_BOTH`
8. System emits `DuplicateResolved` domain event.
9. Both registrations remain in CONFIRMED (or PENDING) status and proceed normally.
10. System displays: "Flag resolved. Both registrations retained."

---

## Alternate Flows

### A1: Keep Primary, Cancel Matched

At step 6, TA Coordinator selects "Keep This Registration (Cancel the other)."
- System sets `resolution_state = RESOLVED_KEEP_PRIMARY`.
- The matched registration's `registration_status` is set to `CANCELLED`.
- System emits `DuplicateResolved` and `RegistrationCancelled` (for the cancelled record).
- If the matched registration had a WaitlistEntry, it is deactivated.
- If the matched registration had a SlotReference, the slot is vacated (triggers backfill in Schedule & Capacity BC).

### A2: Keep Matched, Cancel Primary

At step 6, TA Coordinator selects "Cancel This Registration (Keep the other)."
- Same as A1 but the current registration (primary) is cancelled.
- System sets `resolution_state = RESOLVED_KEEP_MATCHED`.
- The current registration's `registration_status` is set to `CANCELLED`.
- If the current registration had a SlotReference, the slot is vacated.

### A3: Bulk Resolve Multiple Flags

TA Coordinator selects multiple flags and applies the same action.
- System applies the selected resolution action to each flag individually.
- Each flag generates its own `DuplicateResolved` event.
- Audit entries are created per resolution.

---

## Error Flows

### E1: Flag Already Resolved

At step 3:
- Another TA Coordinator has resolved the flag between the time the list was loaded and the selection was made.
- System detects optimistic concurrency conflict.
- System displays: "This flag has already been resolved by [Coordinator Name]."
- System refreshes the list.

### E2: RBAC Denied

At step 3:
- TA Coordinator does not have Duplicate Reviewer role.
- System returns 403.
- No state change.

### E3: Event Closed — Resolution Attempt

At step 7:
- Event has moved to Closed state.
- Cancellations are no longer permitted.
- System permits resolution of KEEP_BOTH but blocks cancellation actions.
- System displays: "This event is closed. You can mark both as valid, but cancellations are no longer permitted."

---

## Domain Events Emitted

- `DuplicateResolved` — when resolution action is saved
- `RegistrationCancelled` — if a registration is cancelled as a result of resolution (A1 or A2)

---

## Notes

- No automated resolution is ever performed. This use case exists solely to provide the human interface for BR-02.
- The resolution decision creates an immutable AuditEntry (via the Analytics & Audit BC subscribing to `DuplicateResolved`). TA Coordinators cannot change a resolution without creating a new override AuditEntry.
- After resolution, the previously blocked bulk advancement operations become available for the retained registration(s).
