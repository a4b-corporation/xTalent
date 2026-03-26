# ECR-T-008: Candidate Slot Allocation
**Type:** Transaction | **Priority:** P1 | **BC:** BC-04
**Permission:** ecr.schedule.manage

## Purpose

Assigns registered candidates to specific schedule slots (room + time shift combinations) in the event schedule matrix. Supports two automated allocation algorithms (Round-Robin for balanced distribution, Fill-First for sequential room filling) plus manual drag-and-drop overrides. Allocation must be previewed and confirmed before it is committed. Once committed, candidates can be invited to their slots (ECR-T-009). The feature prevents over-allocation and flags conflicts before commit.

---

## States

| State | Description |
|-------|-------------|
| Unallocated | Candidate is Registered but not yet assigned to any slot |
| Allocated | Candidate has been assigned to a room + shift slot |
| AllocationConflict | Auto-allocation could not place candidate (no available slot) |
| Reallocated | Previously allocated candidate moved to a different slot by manual override |

---

## Flow

### Step 1: Pre-Allocation Check
**Screen:** /events/:id/schedule/allocation
**Actor sees:**
- Capacity summary table: per track — Registered count vs Total slot capacity
- Visual indicator: green if capacity sufficient, amber if tight (< 10% buffer), red if insufficient
- [Button] Run Allocation (primary)
- Prerequisite check: if schedule matrix not built, shows blocker: "Build schedule matrix first" with link
**Actor does:** Reviews capacity summary; selects algorithm
**System does:** GET /events/{id}/schedule/allocation/summary
**Validation:** At least 1 slot must exist in the schedule matrix
**Errors:**
- "Schedule matrix is empty — define rooms and time slots first"
- "No registered candidates to allocate"

---

### Step 2: Algorithm Selection
**Screen:** /events/:id/schedule/allocation (algorithm panel)
**Actor sees:**
- Algorithm options (radio):
  - **Round-Robin:** Distributes candidates as evenly as possible across rooms within each track. Best for balanced room utilization.
  - **Fill-First:** Fills the first available room to capacity before moving to the next. Best when sequential room activation is preferred.
- Toggle: "Respect track-room assignments" (default: ON) — if ON, candidates are only allocated to rooms assigned to their track
- Toggle: "Exclude waitlisted candidates" (default: ON)
- Toggle: "Preserve existing allocations" (default: ON if any allocations exist) — if ON, only unallocated candidates are processed
**Actor does:** Selects algorithm and toggles; clicks [Preview Allocation]

---

### Step 3: Allocation Preview
**Screen:** /events/:id/schedule/allocation (preview panel)
**Actor sees:**
- Table: Candidate SBD | Name | Track | Assigned Room | Assigned Shift | Status
- Status column: Allocated (green) / Conflict (red — no slot available)
- Conflict summary at top: "X candidates could not be allocated — insufficient capacity"
- Capacity utilization grid: Room × Shift → assigned/capacity counts
- [Button] Commit Allocation (disabled if any blocking conflicts exist)
- [Button] Re-run with different algorithm
- [Button] Download preview CSV
**Actor does:** Reviews conflicts; resolves them (expand capacity or accept partial allocation); or proceeds to commit
**System does:** POST /events/{id}/schedule/allocation/preview (dry run, no state change)
**Validation:** None blocking; conflicts shown as advisory
**Errors:**
- Preview computation timeout (> 10s for large events): "This may take a moment for large candidate lists"

---

### Step 4: Manual Override (optional, pre- or post-commit)
**Screen:** /events/:id/schedule/allocation (allocation table, edit mode)
**Actor sees:**
- Each Allocated row has a [Reassign] action
- Conflict rows have [Assign Manually] action
**Actor does:**
- Clicks [Reassign] on a candidate row
- Slot picker modal shows available slots (room + shift) with remaining capacity
- Selects new slot; clicks [Confirm]
**System does:** Updates candidate's slot assignment locally (preview) OR via API if already committed
- Manual overrides logged: {actor, candidate_id, from_slot, to_slot, timestamp}
**Validation:**
- Target slot must have remaining capacity
- Track-room constraint: warns if assigning to a room not designated for candidate's track
**Errors:**
- "Slot is full — cannot assign this candidate here"
- "This room is not designated for [Track Name] — assign anyway?" (warning, not a block)

---

### Step 5: Commit Allocation
**Screen:** /events/:id/schedule/allocation (preview panel)
**Actor sees:**
- Commit button is active only if zero blocking conflicts
- Confirmation: "Allocate [X] candidates to [Y] slots? This will update all candidate slot assignments."
- If existing allocations exist: "This will overwrite existing allocations for unallocated candidates. Previously confirmed candidates will be unaffected unless you check 'overwrite all'."
**Actor does:** Clicks [Commit Allocation] → confirms dialog
**System does:** POST /events/{id}/schedule/allocation → writes slot assignments to database
- Domain event: CandidatesAllocated (carries count and track breakdown)
- Status of each candidate: Unallocated → Allocated
- Conflict candidates remain Unallocated with conflict reason recorded
**Errors:**
- Capacity violation at commit time (race: another TA added more candidates since preview): "X candidates could no longer be allocated — review conflicts"
- Network error: retry safe (idempotent if same preview token used)

---

### Step 6: Post-Commit View
**Screen:** /events/:id/schedule/allocation (committed view)
**Actor sees:**
- Allocation summary: total allocated, total conflicts, allocation by room
- [Button] Re-allocate (starts new allocation round; preserves already-invited candidates by default)
- [Button] Go to Invitations → navigates to ECR-T-009
- Conflict candidates listed with resolution options: [Assign Manually] or [Add to Waitlist]
**Actor does:** Resolves remaining conflicts or proceeds to invitations

---

## Notifications Triggered

| Trigger | Domain Event | Recipient | Channel |
|---------|-------------|-----------|---------|
| Allocation committed | CandidatesAllocated | TA (success toast + dashboard update) | In-app |
| Conflict candidates remain | (none; advisory only) | TA (conflict table shown) | In-app |

---

## Business Rules Enforced

| Rule | Where Enforced |
|------|----------------|
| Cannot commit with over-capacity assignments | Commit button disabled; must resolve conflicts first |
| Track-room assignments respected by default | Algorithm toggle; override possible with warning |
| Waitlisted candidates excluded from allocation by default | Toggle (default ON) |
| Manual overrides logged to audit | Step 4: audit entry per reassignment |
| Previously confirmed slot candidates not re-allocated (unless override) | "Preserve existing" toggle (default ON) |

---

## Empty State

- Schedule matrix not built: "Define your schedule matrix before running allocation."
- No registered candidates: "No candidates to allocate yet. Wait for registrations."
- Allocation not yet run: "Run allocation to assign candidates to slots."

---

## Edge Cases

| Scenario | Handling |
|----------|----------|
| Candidate is in multiple tracks (if multi-track registration enabled) | Each track registration handled independently; candidate may have multiple allocations |
| TA changes schedule matrix after allocation | Warning: "Schedule has changed since last allocation. Re-run to update assignments." |
| Large event (>1000 candidates) | Preview computation async job; loading indicator shown; result delivered within 30s |
| Two TAs run allocation simultaneously | Second commit returns 409; first commit wins; second TA prompted to refresh and review |
