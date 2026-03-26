# ECR-T-003: Event Cloning
**Type:** Transaction | **Priority:** P2 | **BC:** BC-01
**Permission:** ecr.event.manage

## Purpose

Enables TA staff to create a new Draft event by copying an existing event or saved event template. Reduces setup time for recurring events (e.g., quarterly campus drives). The clone is fully editable before publishing.

---

## States

| State | Description | Entry Condition | Exit Transitions |
|-------|-------------|----------------|-----------------|
| Selecting Source | User choosing source event or template | Initiated via [Clone] action | → Configuring |
| Configuring | Choosing sections to carry over, setting new dates | Source selected | → Cloning |
| Cloning | System copying data | User confirms | → Complete |
| Complete | New Draft event created | Copy finished | → ECR-T-001 Draft state |

---

## Flow

### Step 1: Initiate Clone
**Screen:** /events (list view) or /events/:id (detail)
**Actor sees:** [Clone] button/context menu item on event row or event detail header
**Actor does:** Clicks [Clone]
**System does:** Opens Clone Configuration modal; pre-populates source event name as "Copy of {source_name}"
**Validation:** Source event must be in Published, RegOpen, InProgress, Closed, or Archived state (not Draft-only restriction lifted — Draft events can also be cloned)
**Errors:** None (all states supported)

### Step 2: Configure Clone Options
**Screen:** Clone Configuration modal (full-page modal)
**Actor sees:**
- New event name field (pre-filled "Copy of {source_name}")
- New event start date / end date pickers
- New registration open/close date pickers
- Section checkboxes for what to carry over:
  - [x] Event metadata (type, location, description) — default ON
  - [x] Track configuration (track names, job requests, headcounts) — default ON
  - [x] Registration form (base form + track question sets) — default ON
  - [ ] Schedule matrix (rooms, slots, capacities) — default OFF
  - [ ] Panel assignments — default OFF
  - [ ] Email templates association — default OFF
- Warning callout: "Candidate registrations, SBDs, and slot allocations are never carried over."
**Actor does:** Adjusts name, sets new dates, selects sections, clicks [Clone Event]
**System does:** Validates inputs before proceeding
**Validation:**
- new event_name: required, 3–150 chars
- new event_start_date: must be future date
- new registration_open_date: must be < new event_start_date
- new registration_close_date: must be <= new event_start_date
**Errors:**
- "Event name is required."
- "Start date must be in the future."
- "Registration open date must be before the event start date."

### Step 3: Confirm and Execute Clone
**Screen:** Clone Configuration modal → confirmation step
**Actor sees:** Summary of what will be copied: "Event metadata, Tracks (N), Form (M fields), Sections selected." Spinner after confirm.
**Actor does:** Clicks [Confirm Clone]
**System does:**
- Creates new event record in Draft state
- Copies selected sections; generates new IDs for all copied records
- Sets event_name, dates from user input
- Sets created_by = current user; cloned_from = source event ID
- Responds with new event ID
- API: `POST /events/:id/clone`
- Event emitted: `EventCloned` { sourceEventId, newEventId }
**Validation:** Server-side re-validates all dates and name uniqueness
**Errors:**
- "Clone failed: {reason}. Please try again." (generic server error)
- If name conflict detected server-side: "An event with this name and overlapping dates already exists. Please change the name."

### Step 4: Redirect to New Event
**Screen:** Redirect to /events/:newEventId/edit
**Actor sees:** New event in Draft state; wizard opens at Step 1 (Event Configuration) with a blue banner: "Cloned from {source_event_name}. Review and update before publishing."
**Actor does:** Continues setup as normal
**System does:** No further action
**Validation:** None
**Errors:** None

---

## Notifications Triggered

None. Cloning is an internal TA action.

---

## Business Rules Enforced

- **BR-CL-001:** Candidate data (registrations, SBDs, allocations, scores) is never cloned.
- **BR-CL-002:** If Schedule Matrix is included in clone, all room and slot records are copied but with zero fill counts and unlocked cells.
- **BR-CL-003:** Panel assignments are only cloneable if Schedule Matrix is also selected (dependency).
- **BR-CL-004:** Cloned form is in Draft state even if source was Published; it can be fully edited.
- **BR-CL-005:** cloned_from reference is recorded on the new event for audit trail.

---

## Empty State

N/A — clone is triggered from an existing event.

---

## Edge Cases

- If source event is deleted before clone completes: server returns 404; modal shows "Source event no longer exists."
- If Panel Assignments selected without Schedule Matrix: system auto-checks Schedule Matrix and shows info: "Panel assignments require the schedule matrix. It has been automatically included."
- Very large events (> 5000 form fields or > 100 tracks): clone job runs async; user is redirected immediately with a banner "Clone in progress — this may take up to 30 seconds. Refresh to see the new event."
