# ECR-T-016: Bulk Email Dispatch
**Type:** Transaction | **Priority:** P1 | **BC:** BC-07
**Permission:** ecr.communication.send

## Purpose

Enables TA Coordinators to send targeted email communications to candidate groups at key points in the recruitment lifecycle — registration confirmation, slot invitations, event reminders, result notifications. The dispatch is a 3-step wizard: select template, define recipient filter, confirm send. Execution is asynchronous (async job, 500 emails/min ceiling). A job ID is returned immediately for tracking via ECR-A-001. This feature is distinct from system-triggered transactional emails (those are automatic); this feature is for TA-initiated bulk communications.

---

## States

| State | Applies To | Description |
|-------|-----------|-------------|
| Draft | Dispatch configuration | Being configured in wizard; not yet sent |
| Queued | Email job | Job submitted; waiting to start processing |
| Running | Email job | Actively sending; progress tracked |
| Completed | Email job | All recipients processed (some may have failed) |
| Failed | Email job | Job failed before completion; retry available |
| PartiallyCompleted | Email job | Job finished with some delivery failures |

---

## Flow

### Step 1: Select Template
**Screen:** /events/:id/communications → [Button] Send Email → Wizard Step 1
**Actor sees:**
- Template library: list of active email templates from ECR-M-006
- Each template card: name, subject preview, last updated, active/inactive badge
- [Button] Preview (opens modal with full rendered template + merge tag sample data)
- Search/filter by template name or tag
**Actor does:** Selects one template; clicks [Next]
**System does:** GET /email-templates → loads active templates
**Validation:** One template must be selected
**Errors:**
- No active templates exist: "No email templates configured. Create one in Settings > Email Templates." with link

---

### Step 2: Define Recipients
**Screen:** Wizard Step 2
**Actor sees:**
- Filter panel:
  - Event: auto-filled to current event (locked)
  - Track(s): multi-select checkbox list
  - Registration status: multi-select (Registered / Waitlisted / Checked In / Withdrawn / PendingReview)
  - Slot confirmation status: multi-select (Allocated / Unallocated / Confirmed / Declined / Reschedule Requested)
  - Invitation sent: Yes / No / Any
- Live recipient count: updates as filters change (debounced 500ms) — "X candidates match this filter"
- [Button] Preview recipient list (shows first 20 candidates; download full list option)
**Actor does:** Adjusts filters until recipient count is correct; clicks [Next]
**System does:** GET /events/{id}/candidates?filters=... → returns count (not full list for performance)
**Validation:**
- Recipient count must be > 0: "No candidates match your current filters — adjust filters to proceed"
- Warning if count is unexpectedly small (< 10): "Only [X] recipients — is this correct?"
- Warning if count is very large (> 500): "Sending to [X] recipients — this job may take [estimated time]"
**Errors:**
- Filter results in zero recipients: inline warning, [Next] disabled

---

### Step 3: Review & Confirm
**Screen:** Wizard Step 3
**Actor sees:**
- Summary card:
  - Template: [template name] | Subject: "[subject line]"
  - Recipients: [X] candidates
  - Estimated delivery: [X] minutes (based on 500/min ceiling)
  - Event: [event name]
- [Checkbox] Send a test email to me first (sends to logged-in TA's email before bulk job)
- [Button] Confirm & Send (primary)
- [Button] Back (returns to step 2 without losing filters)
**Actor does:** Reviews summary; optionally sends test; clicks [Confirm & Send]
**System does:**
1. If test requested: sends single test email immediately; TA sees "Test email sent to [your email]"
2. POST /communications/bulk → creates async job
3. Returns job_id immediately (< 1s response)
4. Toast notification: "Email job started — Job #[JOB-ID]"
5. Wizard closes; auto-navigates to Job History tab with new job highlighted
**Errors:**
- Template deactivated between steps 1 and 3: "Selected template is no longer active — please re-select"
- Job creation fails: "Failed to start email job — please try again"

---

### Post-Send: Job Monitoring (ECR-A-001)
**Screen:** /events/:id/communications (Job History tab)
**Actor sees:**
- Job card: Job ID, template name, recipient count, status badge, progress bar (sent/total), created at
- Expandable: per-recipient status list (email, status, timestamp)
- [Button] Retry Failed (active if status = PartiallyCompleted or Failed; sends only to failed recipients)
- [Button] Cancel (active if status = Queued; cancels before processing starts)
**Actor does:** Monitors progress; retries failures as needed

---

## Notifications Triggered

| Trigger | Recipient | Channel |
|---------|-----------|---------|
| Bulk email job completes successfully | TA Coordinator | In-app toast + email notification |
| Bulk email job completes with failures | TA Coordinator | In-app warning + email notification |
| Bulk email job fails entirely | TA Coordinator | In-app error alert + email notification |

---

## Business Rules Enforced

| Rule | Where Enforced |
|------|----------------|
| Sending rate capped at 500 emails/min | Async job worker enforces via rate limiter |
| Only active templates can be selected | Step 1: inactive templates greyed out |
| Recipient filter must return > 0 results | Step 2: [Next] disabled if count = 0 |
| Unsubscribed / opted-out candidates are excluded automatically | Server-side: filter applied at job execution, not at filter preview |
| Job ID returned immediately; dispatch is async | Architecture constraint; UI reflects this with job tracking |
| Test email can be sent before bulk dispatch | Optional step 3 checkbox |

---

## Empty State

- No previous jobs: "No email campaigns sent yet. Send your first campaign above."
- Job History tab with no completed jobs: empty state illustration with above message

---

## Edge Cases

| Scenario | Handling |
|----------|----------|
| Candidate unsubscribes between filter preview and job execution | Excluded automatically at job execution time; count in job result may differ from preview count |
| Email provider rate limit hit during job | Worker backs off and retries; job remains in Running state; estimated time extends |
| Same candidate matches filter for two concurrent jobs | Both jobs attempt delivery; recipient receives both emails; this is expected behavior |
| TA cancels a queued job | POST /communications/jobs/{job_id}/cancel; Queued → Cancelled; no emails sent |
| Template has broken merge tags | Test email step surfaces the issue before bulk dispatch; broken tags render as [MISSING:field_name] |
