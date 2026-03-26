# Use Case: Clone Event
## Bounded Context: Event Management
## ECR Module | 2026-03-25

**Actor:** TA Coordinator
**Trigger:** TA Coordinator selects "Clone Event" on an existing Event (any state)
**Preconditions:**
- Source Event exists in any state (Draft, Published, Closed, or Archived)
- TA Coordinator has Event Manager role (validated via xTalent RBAC)

**Postconditions:**
- A new Event exists in Draft state with all structural data copied by value from the source
- New Event has a new `event_id` and blank `start_date`, `end_date`, `registration_deadline`
- New Event's `source_event_id` references the source for traceability
- `EventCloned` domain event is emitted with both `event_id` (source) and `new_event_id`
- New Event has no runtime dependency on the source Event

**Business Rules:** OQ-D5 Resolution — clone is always copy-by-value

---

## Happy Path

1. TA Coordinator opens the source Event detail view.
2. TA Coordinator selects "Clone Event."
3. System presents a confirmation dialog: "Create a copy of [Event Title]? The new event will be a Draft with all tracks and form copied. You will need to set new dates before publishing."
4. TA Coordinator confirms.
5. System creates a new Event aggregate with:
   - A new UUID `event_id`
   - `lifecycle_state = DRAFT`
   - `structural_locked = false`
   - `source_event_id` set to the source Event's ID
   - `title` set to "[Source Title] (Copy)"
   - `start_date`, `end_date`, `registration_deadline` = null (must be set before publishing)
   - All Tracks copied by value: each Track gets a new UUID, same name, capacity, pipeline_stages, allocation_strategy. `job_requisition_link` is cleared (new event will need new requisitions).
   - RegistrationForm copied by value: new UUID, same fields schema, `version` reset to 1.
6. System emits `EventCloned` domain event: `eventId` (source), `newEventId`, `actorId`, `clonedAt`.
7. System navigates TA Coordinator to the new Draft event's configuration view.
8. System displays banner: "Event cloned. Please update the event dates before publishing."

---

## Alternate Flows

### A1: Clone a Closed or Archived Event

Behavior is identical to the Happy Path. The source Event's state does not affect the clone operation. The new Event is always created as Draft regardless of the source state.

### A2: Clone with Immediate Title Change

At step 3:
- System presents an optional "New Event Title" input in the confirmation dialog.
- TA Coordinator enters a new title.
- In step 5, `title` is set to the user-provided title instead of "[Source Title] (Copy)."

---

## Error Flows

### E1: Source Event Not Found

At step 2:
- Source event does not exist or has been deleted (edge case).
- System returns: "Event not found."
- No new event is created.

### E2: RBAC Denied

At step 2:
- TA Coordinator does not have Event Manager role.
- System returns 403: "You do not have permission to clone this event."
- No new event is created.

### E3: System Error During Clone

At step 5:
- A system error occurs during the copy operation (e.g., database write failure).
- The operation is rolled back atomically. No partial clone is created.
- System displays: "Clone failed. Please try again."
- No `EventCloned` domain event is emitted.

---

## Domain Events Emitted

- `EventCloned` — when the new Event aggregate is successfully persisted

---

## Notes

- Job Requisition Links are intentionally cleared on clone. Requisitions are event-specific contracts; they cannot be transferred to a new event automatically.
- The cloned Event's RegistrationForm version is reset to 1. Version history from the source form does not carry over.
- SBD blocks, schedule assignments, and all operational data are NOT copied. Clone copies structural configuration only, not operational history.
- If the same TA Coordinator clones the same event multiple times, each clone is independent with its own UUID.
