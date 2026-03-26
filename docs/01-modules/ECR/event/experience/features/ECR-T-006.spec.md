# ECR-T-006: Waitlist Management
**Type:** Transaction | **Priority:** P2 | **BC:** BC-02
**Permission:** ecr.waitlist.manage

## Purpose

When an event or track reaches capacity, new registrations are placed on the waitlist. TA staff can manually promote waitlisted candidates to registered, or configure auto-promotion when a registered slot opens (due to cancellation or capacity increase). Candidates receive a notification when promoted.

---

## States

| State | Description | Entry Condition | Exit Transitions |
|-------|-------------|----------------|-----------------|
| Waitlisted | Candidate queued; no confirmed slot | Registered when capacity full | → Registered (on promotion) / Cancelled (on withdrawal) |
| Registered | Candidate confirmed; slot available | Promoted from Waitlist | Terminal for this feature |
| Cancelled | Candidate withdrew from waitlist | Candidate request or TA action | Terminal |

---

## Flow

### Step 1: View Waitlist
**Screen:** /events/:id/waitlist
**Actor sees:**
- Waitlist queue ordered by joined_at (FIFO default)
- Columns: Position, SBD, Candidate Name, Track, Joined At, Contact Email, Status (Waitlisted / Promoted / Cancelled)
- Summary bar: "N candidates on waitlist | M available slots"
- Toggle: [Auto-Promotion: ON / OFF] with current mode displayed
- [Promote] button per row; [Bulk Promote] button for selected rows
**Actor does:** Reviews queue; takes action
**System does:** Loads waitlist with current available slot count
**Validation:** None
**Errors:** None

### Step 2a: Manual Promote
**Screen:** /events/:id/waitlist
**Actor sees:** [Promote] button on candidate row
**Actor does:** Clicks [Promote] on a specific candidate
**System does:** Opens confirmation modal: "Promote {name} from waitlist to Registered? This will send a confirmation email."
**Validation:** At least 1 available slot must exist in the event (or track if sbd_scope=PerTrack)
**Errors:**
- "No available slots to promote this candidate. Increase event capacity first." (if capacity full)

**After confirm:**
**System does:**
- Calls domain API: `POST /events/:id/waitlist/:candidateId/promote` with type = "MANUAL"
- Updates candidate status: Waitlisted → Registered
- Decrements available_slots counter
- Issues SBD if not yet assigned
- Sends promotion email (uses WaitlistPromotion template)
- Emits: `WaitlistPromoted` { candidateId, eventId, promotedBy, type: "MANUAL" }
- Writes audit log entry
- Re-sequences waitlist positions
**Errors:** "Promotion failed: {reason}. Please try again."

### Step 2b: Auto-Promotion Configuration
**Screen:** /events/:id/waitlist → [Configure Auto-Promotion] button
**Actor sees:** Settings panel:
- Toggle: Enable Auto-Promotion (ON/OFF)
- When ON: "When a registered candidate cancels or a capacity slot opens, the next waitlisted candidate is automatically promoted (FIFO order)."
- Option: Notify TA when auto-promotion occurs (toggle; default ON)
- Scope: Per Event / Per Track (matches sbd_scope setting)
**Actor does:** Configures and saves
**System does:** Stores auto-promotion config; future cancellation events trigger automatic promotion
**Validation:** None
**Errors:** None

### Step 2c: Auto-Promotion Trigger (System-Initiated)
**Actor:** System (no TA interaction required)
**Trigger:** A registered candidate cancels, or TA increases event capacity
**System does:**
- Queries first Waitlisted candidate in FIFO order for the relevant track/event
- Promotes candidate (same as Step 2a but type = "AUTO")
- Sends promotion email
- Emits: `WaitlistPromoted` { type: "AUTO" }
- If TA notification enabled: sends in-app notification to TA: "{name} was auto-promoted from the waitlist."

### Step 3: Candidate Withdrawal
**Screen:** N/A (candidate-facing portal action or TA-initiated)
**Actor:** Candidate (via registration portal cancellation link) or TA
**System does:**
- Updates candidate status: Waitlisted → Cancelled
- Re-sequences waitlist positions
- If auto-promotion enabled: triggers Step 2c for released logical capacity
- Emits: `WaitlistCancelled`

---

## Notifications Triggered

| Trigger | Notification | Recipient |
|---------|-------------|----------|
| Step 2a/2c: Promotion | "Great news! You've been moved from the waitlist for {event_name}. Your SBD is {sbd}." | Promoted candidate email |
| Step 2c: Auto-promotion | In-app: "{name} auto-promoted from waitlist" | TA users (if notify setting ON) |

---

## Business Rules Enforced

- **BR-WL-001:** Waitlist is FIFO by default; TA can override position for a specific candidate via drag-and-drop reordering (requires reason log).
- **BR-WL-002:** Auto-promotion only runs when available_slots > 0 for the relevant scope.
- **BR-WL-003:** A candidate on the waitlist does not have an allocated schedule slot; slot allocation (ECR-T-008) runs after promotion.
- **BR-WL-004:** Waitlist closes when event enters InProgress state; no new promotions after that point.
- **BR-WL-005:** TA can manually promote out-of-FIFO order but must provide a reason (logged to audit).

---

## Empty State

"No candidates are currently on the waitlist for this event." with info: "Candidates are added to the waitlist automatically when the event reaches full capacity."

---

## Edge Cases

- If promoted candidate's email bounces: promotion is not reversed; TA is notified via A-001 (Communication Job Tracking).
- If event capacity is reduced below current registered count: waitlist is unaffected; existing registered candidates retain status.
- Concurrent auto-promotions (two cancellations at once): system uses database transaction to prevent double-promotion of the same waitlist slot.
