# ECR-T-005: Duplicate Flag Resolution
**Type:** Transaction | **Priority:** P2 | **BC:** BC-02
**Permission:** ecr.duplicate.resolve

## Purpose

When a candidate submits a registration and the system detects a possible duplicate (matching name + email, or email + phone, or fuzzy name match with same email domain), the registration is flagged. TA staff review flagged records side-by-side and decide to merge, reject the duplicate, or override the flag. All decisions are logged to the audit trail.

---

## States

| State | Description | Entry Condition | Exit Transitions |
|-------|-------------|----------------|-----------------|
| Flagged | Possible duplicate detected at registration | System duplicate-detection on `registerCandidate` | → UnderReview → Merged / Rejected / Overridden |
| UnderReview | TA has opened the record for review | TA opens flag | → Merged / Rejected / Overridden |
| Merged | Duplicate confirmed; records merged | TA selects Merge | Terminal |
| Rejected | Duplicate registration rejected; candidate notified | TA selects Reject | Terminal |
| Overridden | Flag dismissed; both registrations are valid | TA selects Override | Terminal (both registrations proceed) |

---

## Flow

### Step 1: View Duplicate Queue
**Screen:** /events/:id/duplicates
**Actor sees:**
- List of flagged registration pairs grouped by detection rule (email match, name+phone match, fuzzy)
- Columns: Candidate A (SBD + name), Candidate B (SBD + name), Match Reason, Flagged At, Status (Flagged / UnderReview)
- Count badge on navigation item: "Duplicates (N)"
**Actor does:** Clicks a row to open side-by-side comparison
**System does:** Marks flag as UnderReview; locks record from concurrent editing by another TA
**Validation:** None
**Errors:** "This record is currently being reviewed by {user}. Please try again later." (optimistic lock)

### Step 2: Side-by-Side Comparison
**Screen:** /events/:id/duplicates/:flagId
**Actor sees:**
- Two-column layout: Candidate A (left) and Candidate B (right)
- All registration fields shown in aligned rows; differing values highlighted in amber
- Metadata: submitted_at, IP address, form version, track selected
- Similarity score (0–100%) shown at top
- Match reason badge: "Email Match", "Name + Phone Match", "Fuzzy Name (87%)"
- Three action buttons: [Merge → Keep A] [Merge → Keep B] [Reject B] [Override Flag]
**Actor does:** Reviews fields; selects action
**System does:** None until action taken
**Validation:** None
**Errors:** None

### Step 3a: Merge Records
**Screen:** Side-by-side modal → Merge confirmation
**Actor sees:** Confirmation dialog: "You are merging these two records. Select which record to keep as the primary. The other will be archived."
- Radio: Keep Candidate A / Keep Candidate B
- Merge notes field (optional, max 500 chars)
**Actor does:** Selects primary, optionally adds note, clicks [Confirm Merge]
**System does:**
- Calls domain API: `POST /registrations/:flagId/resolve` with action = "MERGE", primaryId, notes
- Archives the secondary registration (status: Archived; SBD voided)
- Primary registration remains active; SBD unchanged
- Updates flag status to Merged
- Emits: `DuplicateResolved` { flagId, action: "MERGE", primaryId, archivedId, resolvedBy }
- Writes audit log entry
**Validation:** primaryId must be one of the two flagged registrations
**Errors:** "Merge failed: {reason}. Please try again."

### Step 3b: Reject Duplicate
**Screen:** Side-by-side modal → Reject confirmation
**Actor sees:** "Reject Candidate B's registration? This will cancel their registration and send a rejection notification."
- Reject reason (required dropdown): Duplicate submission / Already registered via another channel / Other
- Notes field (optional)
**Actor does:** Selects reason, clicks [Confirm Reject]
**System does:**
- Calls domain API: `POST /registrations/:flagId/resolve` with action = "REJECT", rejectedId, reason, notes
- Sets rejected registration status to Cancelled
- Sends rejection email to rejected candidate (uses system template)
- Updates flag status to Rejected
- Emits: `DuplicateResolved` { flagId, action: "REJECT" }
- Writes audit log entry
**Validation:** Reject reason is required
**Errors:**
- "Reject reason is required."
- "Reject failed: {reason}. Please try again."

### Step 3c: Override Flag (Both Valid)
**Screen:** Side-by-side modal → Override confirmation
**Actor sees:** "Mark both registrations as valid? The duplicate flag will be dismissed."
- Override reason (required free text, max 200 chars)
**Actor does:** Enters reason, clicks [Confirm Override]
**System does:**
- Calls domain API: `POST /registrations/:flagId/resolve` with action = "OVERRIDE", reason
- Both registrations remain active
- Flag status updated to Overridden
- Emits: `DuplicateResolved` { flagId, action: "OVERRIDE" }
- Writes audit log entry
**Validation:** Override reason required
**Errors:** "Override reason is required."

---

## Notifications Triggered

| Trigger | Notification | Recipient |
|---------|-------------|----------|
| Step 3b: Reject | "Your registration for {event_name} could not be confirmed. Reason: Duplicate submission." | Rejected candidate email |
| New flag detected | In-app notification badge increment | TA users with ecr.duplicate.resolve permission |

---

## Business Rules Enforced

- **BR-DUP-001:** Duplicate detection runs automatically on every `registerCandidate` submission using: exact email match, name + phone match, or fuzzy name (Levenshtein distance < 3) with same email domain.
- **BR-DUP-002:** Only one TA can review a specific flag at a time (optimistic locking, 10-minute lock TTL).
- **BR-DUP-003:** All resolution actions (Merge / Reject / Override) are recorded in the audit log and cannot be undone.
- **BR-DUP-004:** A merged/rejected/overridden flag cannot be reopened; TA must contact a system admin for corrections.
- **BR-DUP-005:** Auto-resolution is not supported; all flags require manual TA action.

---

## Empty State

"No duplicate flags for this event. All registrations have been verified." with a checkmark icon.

---

## Edge Cases

- If one of the two flagged candidates has already checked in (ECR-T-010): Reject and Merge are blocked; only Override is available. Banner: "Candidate B has already checked in. Only Override is available."
- If both candidates are on the waitlist: Merge proceeds normally; merged (archived) candidate's waitlist slot is released.
- High volume (> 100 flags): list supports bulk review only for Override (bulk dismiss of low-confidence flags, confidence score < 50%).
