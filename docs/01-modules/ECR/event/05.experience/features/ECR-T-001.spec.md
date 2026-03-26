# ECR-T-001: Event Lifecycle Management
**Type:** Transaction | **Priority:** P1 | **BC:** BC-01
**Permission:** ecr.event.manage (general transitions), ecr.event.publish (Publish transition)

## Purpose

Manages the full state machine of a Recruitment Event from creation through archival. Each lifecycle transition has guard conditions to prevent premature state changes. TA Coordinators use lifecycle actions to control when candidates can register, when onsite operations begin, and when the event is formally closed. Transitions trigger downstream domain events that activate other features (registration portal, kiosk sessions, dashboard).

---

## States

| State | Description | Entry Conditions | Exit Conditions |
|-------|-------------|-----------------|-----------------|
| Draft | Event created but not published; not visible to candidates | createRecruitmentEvent called | Publish action |
| Published | Event publicly visible; registration not yet open | At least 1 track configured; registration form saved | Open Registration action |
| RegOpen | Candidate registration portal is live; candidates can self-register | Registration open date reached OR manual trigger | Start Event action |
| InProgress | Event is underway; kiosk sessions can start; live dashboard active | Event start date reached OR manual trigger | Close Event action |
| Closed | Event operations complete; scores locked; no new check-ins | Manual Close action by TA | Archive action |
| Archived | Historical record; read-only | Manual Archive action | (terminal state) |
| Cancelled | Event cancelled at any pre-InProgress state | Manual Cancel action (requires confirmation) | (terminal state) |

---

## Flow

### Step 1: Create Event (Draft)
**Screen:** /events/new (wizard Step 4 — Review & Save)
**Actor sees:** "Save as Draft" button on review step
**Actor does:** Clicks [Save as Draft]
**System does:** POST /events → event_id created, status = Draft
**Domain event:** RecruitmentEventCreated
**Validation:** Event name required; at least one future date; at least one track
**Errors:**
- Missing required fields: inline validation on wizard steps
- Duplicate event name (within same date range): warning prompt (not a block)

---

### Step 2: Publish
**Screen:** /events/:id (Overview tab)
**Actor sees:** Status badge "Draft"; [Button] Publish Event
**Actor does:** Clicks [Publish Event]
**System does:** Guard checks:
- At least 1 track with linked job request
- Registration form is saved (not blank)
- Event dates are in the future
If all pass: POST /events/{id}/publish → status = Published
**Domain event:** EventPublished
**Errors:**
- "Cannot publish: registration form not configured" — link to form builder
- "Cannot publish: no tracks configured" — link to tracks
- "Cannot publish: event start date is in the past"

---

### Step 3: Open Registration
**Screen:** /events/:id (Overview tab)
**Actor sees:** Status badge "Published"; [Button] Open Registration
**Actor does:** Clicks [Open Registration]
**System does:** Guard checks:
- Registration open date has been set OR manual override confirmed
- Registration form is in published state
If pass: POST /events/{id}/open-registration → status = RegOpen
**Domain event:** RegistrationOpened → activates candidate registration portal
**Errors:**
- "Registration close date is before today" — requires date adjustment
- Confirmation dialog if registrations already exist (re-opening a previously closed registration)

---

### Step 4: Start Event
**Screen:** /events/:id (Overview tab)
**Actor sees:** Status badge "RegOpen"; [Button] Start Event
**Actor does:** Clicks [Start Event]
**System does:** Guard checks:
- Schedule matrix has been built (at least 1 room, 1 slot)
- At least 1 candidate is Registered
Confirmation: "Starting the event will close registration and activate kiosk sessions. Continue?"
If confirmed: POST /events/{id}/start → status = InProgress
**Domain event:** EventStarted → live dashboard activates; kiosk sessions can now be created
**Errors:**
- "No schedule matrix found — build schedule before starting"
- "No registered candidates — are you sure?" (warning, not a block)

---

### Step 5: Close Event
**Screen:** /events/:id (Overview tab)
**Actor sees:** Status badge "InProgress"; [Button] Close Event
**Actor does:** Clicks [Close Event]
**System does:** Guard checks:
- Warning shown if unsynced kiosk records exist
- Warning shown if open score edit requests exist
Confirmation: "Closing the event will lock check-ins and scores. Unresolved kiosk sync conflicts will require manual review. Continue?"
If confirmed: POST /events/{id}/close → status = Closed
**Domain event:** EventClosed → kiosk sessions terminated; no new check-ins; scores locked
**Errors:**
- If critical unsynced records: "X kiosk records have not been synced. Force-close will mark them as needing review."

---

### Step 6: Archive
**Screen:** /events/:id (Overview tab)
**Actor sees:** Status badge "Closed"; [Button] Archive Event
**Actor does:** Clicks [Archive Event]
**System does:** Confirmation: "Archiving moves this event to read-only history. All reports remain accessible."
POST /events/{id}/archive → status = Archived
**Domain event:** EventArchived
**Errors:** None expected; always available from Closed state

---

### Step 7: Cancel (from Draft, Published, or RegOpen only)
**Screen:** /events/:id (Overview tab, kebab menu)
**Actor sees:** Kebab menu → [Cancel Event]
**Actor does:** Selects [Cancel Event]
**System does:** Confirmation with text input: "Type the event name to confirm cancellation"
If confirmed: POST /events/{id}/cancel → status = Cancelled
**Domain event:** EventCancelled → if RegOpen, sends cancellation notification to all registered candidates
**Errors:**
- Cannot cancel an InProgress or Closed event (action hidden in those states)
- Candidate cancellation email fails: queued for retry; TA notified

---

## Notifications Triggered

| Transition | Domain Event | Recipient | Channel |
|-----------|-------------|-----------|---------|
| Published | EventPublished | None (internal only) | — |
| RegOpen | RegistrationOpened | None automatically (TA sends manually via bulk email) | — |
| EventStarted | EventStarted | Onsite staff (via dashboard notification) | Dashboard alert |
| EventClosed | EventClosed | TA (confirmation toast) | In-app |
| Cancelled (from RegOpen) | EventCancelled | All registered candidates | Email (bulk async) |

---

## Business Rules Enforced

| Rule | Enforced At |
|------|-------------|
| Registration form must be saved before Publish | Step 2 guard condition |
| Event cannot start without a schedule matrix | Step 4 guard condition |
| Scores are locked on event close | Domain layer (API rejects score submissions for Closed events) |
| Cancel only available before InProgress | Action visibility conditional on state |
| All lifecycle transitions logged to audit | Domain event handler writes audit entry |

---

## Empty State

- No events: /events list shows "No events yet. Create your first recruitment event." with [Create Event] CTA.

---

## Edge Cases

| Scenario | Handling |
|----------|----------|
| TA attempts to publish on event start date | Publish allowed; warning: "Event starts today — ensure setup is complete" |
| Two TA coordinators click Publish simultaneously | Second request returns 409 Conflict: "Event is already Published" |
| Closing event with active kiosk sessions (offline kiosks) | Warning lists offline kiosks; TA must acknowledge before close proceeds |
| Event dates changed after publishing | Dates can be updated in Draft and Published states; locked from RegOpen onwards |
