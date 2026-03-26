# ECR-T-009: Slot Invitation and Confirmation
**Type:** Transaction | **Priority:** P1 | **BC:** BC-04
**Permission:** ecr.schedule.manage (dispatch invitations), ecr.candidate.view (read confirmation status)

## Purpose

After candidates are allocated to schedule slots (ECR-T-008), TA Coordinators dispatch invitation emails informing each candidate of their assigned room, date, and time. Candidates can confirm their slot, request a reschedule (which places them back on a waitlist for reallocation), or decline. The TA monitors confirmation status and can send reminders to unconfirmed candidates before the event. This feature bridges the allocation-to-kiosk pipeline: only allocated, confirmed candidates are expected at their assigned rooms.

---

## States

| State | Applies To | Description | Valid Next States |
|-------|-----------|-------------|-------------------|
| Allocated | Candidate slot | Assigned to a slot; invitation not yet sent | Invited |
| Invited | Candidate slot | Invitation email sent; awaiting candidate response | Confirmed, RescheduleRequested, Declined, Invited (reminder sent) |
| Confirmed | Candidate slot | Candidate confirmed attendance | (terminal for invitation flow) |
| RescheduleRequested | Candidate slot | Candidate requested a different slot | Reallocated (via ECR-T-008) or Waitlisted |
| Declined | Candidate slot | Candidate declined attendance | (terminal; candidate status → Withdrawn) |
| InvitationExpired | Candidate slot | Invitation link TTL expired without response | Treated as Unconfirmed for dashboard |

---

## Flow

### Step 1: View Invitation Status
**Screen:** /events/:id/schedule/invitations
**Actor sees:**
- Table: Candidate SBD | Name | Track | Room | Shift | Invitation Status | Sent At | Responded At
- Status filter: All / Allocated (not sent) / Invited / Confirmed / Reschedule Requested / Declined
- Bulk selection checkbox on rows
- Confirmation rate summary: "142 / 320 confirmed (44%)"
- [Button] Send Invitations (primary, for selected or all Allocated candidates)
- [Button] Send Reminders (for Invited candidates past X days without response)
**Actor does:** Reviews status; selects recipients for invitation or reminder

---

### Step 2: Send Invitations
**Screen:** /events/:id/schedule/invitations → Send modal
**Actor sees:**
- Modal: "Send slot invitations to [X] allocated candidates"
- Selected template: "Slot Invitation" (auto-selected; can change via dropdown)
- Preview: shows sample invitation email with merge tags resolved for one example candidate
- Token TTL: "Confirmation links expire in [72h / until event start, whichever first]"
- [Button] Confirm Send
**Actor does:** Reviews and confirms
**System does:** POST /events/{id}/schedule/invitations/send
- Generates per-candidate confirmation token
- Dispatches via bulk email job (async, 500/min ceiling)
- Candidate status → Invited; sent_at timestamp recorded
**Domain event:** SlotInvitationSent (per candidate, batched)
**Errors:**
- Email template not configured: "Slot Invitation template not found — configure it in Settings > Email Templates"
- Async job failure: job tracked in ECR-A-001; TA notified of partial failure

---

### Step 3: Candidate Confirmation (Candidate's Action)
**Screen:** /confirm/:confirmationToken (public, no login)
**Candidate sees:**
- Invitation summary: event name, date, room, shift time
- Their SBD displayed
- Options:
  - [Button] Confirm My Attendance (primary)
  - [Button] Request Reschedule
  - [Button] I Cannot Attend (Decline)

**3a — Confirm:**
**System does:** POST /invitations/{token}/confirm → candidate slot status → Confirmed
**Candidate sees:** "Confirmed! See you at [Room] on [Date] at [Time]"
**Domain event:** SlotConfirmed
**Email:** Confirmation receipt sent to candidate

**3b — Reschedule:**
**Candidate sees:** Reschedule modal: preferred date/time (text or dropdown of available slots if visible)
**System does:** POST /invitations/{token}/reschedule → candidate slot status → RescheduleRequested
**Candidate sees:** "Your reschedule request has been received. We will contact you with a new slot."
**Domain event:** RescheduleRequested → appears in TA's invitation management queue

**3c — Decline:**
**Candidate sees:** Decline confirmation: "Are you sure? Declining removes your slot."
**System does:** POST /invitations/{token}/decline → candidate slot status → Declined; candidate overall status → Withdrawn
**Candidate sees:** "Thank you for letting us know. Your slot has been released."
**Domain event:** SlotDeclined → released slot available for reallocation

**3d — Token expired:**
**Candidate sees:** "This confirmation link has expired. Contact the recruitment team if you still wish to attend."
- Link to event contact email/phone displayed

---

### Step 4: Send Reminders
**Screen:** /events/:id/schedule/invitations → Reminder modal
**Actor sees:**
- Filter: Invited candidates with no response after [X] days (configurable, default 48h)
- Reminder count: "Send reminder to [X] unconfirmed candidates"
- [Button] Send Reminders
**Actor does:** Reviews count and sends
**System does:** POST /events/{id}/schedule/invitations/remind
- Uses "Slot Reminder" email template
- Generates new confirmation token (extends TTL)
- Updates sent_at; does not reset original invitation record
**Errors:** Same as Step 2

---

### Step 5: Handle Reschedule Requests
**Screen:** /events/:id/schedule/invitations (Reschedule Requested filter)
**Actor sees:**
- List of candidates with reschedule requests
- Each row: candidate info + their stated preference
- Actions per row: [Reallocate to New Slot] → opens slot picker modal (draws on ECR-T-008 manual override)
**Actor does:** Assigns new slot to requesting candidate
**System does:** Updates slot assignment; sends new invitation to candidate automatically

---

## Notifications Triggered

| Trigger | Domain Event | Recipient | Channel |
|---------|-------------|-----------|---------|
| Invitations dispatched | SlotInvitationSent | Candidates (each) | Email (async batch) |
| Candidate confirms | SlotConfirmed | TA (status table update) | Dashboard refresh |
| Candidate declines | SlotDeclined | TA (status table update) | Dashboard refresh |
| Candidate requests reschedule | RescheduleRequested | TA | In-app notification + status table update |
| Reminder sent | (re-use SlotInvitationSent event) | Candidates (unconfirmed) | Email |

---

## Business Rules Enforced

| Rule | Where Enforced |
|------|----------------|
| Invitations can only be sent to Allocated candidates | Step 2: API rejects invitations for unallocated candidates |
| Confirmation tokens are per-candidate and single-use | Token consumed on first use; subsequent clicks show "already responded" |
| Declined slot is released for reallocation | Domain event handler frees slot capacity |
| Reschedule requests are TA-managed (not self-service slot swap) | Candidate sees "we will contact you"; no self-serve slot picker exposed to candidate |
| Reminder sends new token (extends TTL) | Step 4: new token generated on reminder dispatch |

---

## Empty State

- No allocated candidates: "No candidates have been allocated to slots yet. Run allocation first."
- All candidates confirmed: "All candidates have confirmed. You are ready for event day."
- No unconfirmed candidates for reminder: "All invited candidates have already responded."

---

## Edge Cases

| Scenario | Handling |
|----------|----------|
| Candidate confirms after event has started | Confirmation accepted; check-in still possible; slot confirmation noted in audit |
| Multiple reminders sent to same candidate | System throttles: max 1 reminder per 24h per candidate; excess sends silently dropped |
| Declined candidate re-registers (public portal) | Treated as new registration; previous withdrawal noted in admin view |
| Batch invitation job partially fails | Failed candidates remain in Allocated state; TA sees failure list in job tracker (ECR-A-001) |
