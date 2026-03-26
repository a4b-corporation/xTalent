# Glossary: Schedule & Capacity
## ECR Domain | 2026-03-25

This glossary defines the ubiquitous language for the Schedule & Capacity bounded context. This context owns the schedule matrix, candidate-to-slot allocation, waitlist backfill, and capacity override audit trail.

---

| Term | Definition | Notes / Disambiguations |
|------|-----------|------------------------|
| **EventSchedule** | The aggregate root for this context. Represents the complete schedule matrix for one Event: the set of all rooms, shifts, and tracks combined into allocatable slots. One EventSchedule exists per Event. | Do not confuse with the Event aggregate (owned by Event Management BC). EventSchedule is this context's representation of an event's scheduling structure. |
| **ScheduleSlot** | A specific combination of Room + Shift + Track with a defined capacity. The atomic unit of candidate allocation. A candidate is allocated to exactly one ScheduleSlot per Track. | A ScheduleSlot is not a calendar timeslot in the generic sense — it is always scoped to one Event, one Track, one Room, and one Shift. |
| **Room** | A physical or virtual space where candidates and interviewers convene. Characterized by name, identifier, and physical capacity. | A Room's physical capacity is a hard ceiling — ScheduleSlot capacity cannot exceed it without an explicit CapacityOverride. |
| **Shift** | A time window (start time, end time) within the Event day. Multiple Shifts may exist per event day. All Shifts are scoped to the Event's date range. | A Shift is distinct from an InterviewSession (owned by Interview Management BC). A Shift is a schedule configuration; an InterviewSession is an active operational record. |
| **AllocationRun** | A single execution of the allocation algorithm that assigns confirmed candidates to schedule slots. An AllocationRun is idempotent — re-running it with the same candidate set produces the same result. | An AllocationRun is triggered by a batch of CandidateConfirmed events. It does not process one candidate at a time in normal operation — it batches to optimize slot distribution. |
| **AllocationStrategy** | The algorithm used to distribute candidates across available ScheduleSlots. Two strategies: Round-Robin (even distribution) and Fill-First (fill each slot before moving to the next). | AllocationStrategy is configured per-Track by TA Coordinators before the event starts. It cannot be changed once the Event is In Progress (BR-06). |
| **Round-Robin** | An AllocationStrategy that distributes candidates evenly across all ScheduleSlots for a Track. Slot 1 gets 1 candidate, Slot 2 gets 1, etc., cycling through all slots. | Preferred strategy when even room utilization matters — prevents one room from filling up while others are empty. |
| **Fill-First** | An AllocationStrategy that fills each ScheduleSlot to its capacity before assigning candidates to the next slot. | Preferred strategy when minimizing the number of active rooms matters — useful for events where rooms need to be staffed with interviewers. |
| **CapacityOverride** | An administrative action that changes a ScheduleSlot's allocated capacity beyond its original configured value. Always requires a reason string and is logged as an immutable audit entry. | CapacityOverride does not change the Room's physical capacity — it only changes how many candidates are assigned to that slot. Override capacity still cannot exceed Room physical capacity. |
| **WaitlistBackfill** | The process of promoting the next waitlisted candidate (FCFS order) to a vacated ScheduleSlot when a confirmed candidate's registration is cancelled. Triggered by RegistrationCancelled event. | WaitlistBackfill is automatic and follows FCFS order (BR-10). No manual slot assignment is permitted. The specific slot vacated may or may not be the slot given to the promoted candidate — the allocation algorithm re-evaluates. |
| **ScheduleLock** | The state of an EventSchedule once the Event has transitioned to In Progress (BR-06). When locked, structural schedule changes (adding/removing slots, changing room assignments, changing strategy) are rejected. Operational changes (individual candidate slot swaps by TA Coordinator with audit) remain permitted. | ScheduleLock is engaged by the EventSchedule aggregate on receipt of the EventStarted domain event. It mirrors the structural_locked flag on the Event aggregate. |
| **SlotAllocated** | Domain event emitted when a single candidate is assigned to a ScheduleSlot. Consumed by Candidate Registration BC (to update SlotReference) and Interview Management BC (to link candidate to interview room/time). | SlotAllocated is per-candidate, per-slot. The bulk event CandidatesAllocatedToSlots is emitted after a full AllocationRun completes. |
| **CandidatesAllocatedToSlots** | Domain event emitted after a complete AllocationRun. Carries a summary count; individual SlotAllocated events carry the per-candidate details. | Downstream contexts subscribe to SlotAllocated for individual updates and to CandidatesAllocatedToSlots for bulk run completion signals. |
| **RoomDoubleBooking** | An invariant violation where two ScheduleSlots reference the same Room during overlapping Shift times. Prohibited by the EventSchedule aggregate. | Room double-booking is checked at slot creation time, not at allocation time. An attempt to create an overlapping slot is rejected immediately. |

---

## Business Rules in This Context

| BR-ID | Rule | Implementation |
|-------|------|---------------|
| BR-06 | Structural immutability once In Progress | EventSchedule.structural_locked = true on EventStarted receipt. Structural mutation commands rejected. |
| BR-10 | Waitlist FCFS only — no manual reorder | WaitlistBackfill uses waitlisted_at timestamp as sole ordering key. No API for manual slot reassignment. |

---

## Lifecycle States

### EventSchedule States
```
Undefined → Draft → Active → Locked
```
- **Undefined**: No schedule matrix defined yet for the Event.
- **Draft**: Schedule matrix defined; no candidates allocated yet.
- **Active**: Allocation is running; candidates are assigned to slots.
- **Locked**: Event is In Progress; structural changes blocked (BR-06).

### ScheduleSlot Allocation States
```
Open → Partially Allocated → Full → Overridden
```
- **Open**: Slot exists but has no candidates assigned.
- **Partially Allocated**: Some capacity used; further allocations accepted.
- **Full**: Slot capacity reached; no new allocations.
- **Overridden**: CapacityOverride has changed the slot's effective capacity.

---

## Integration Points

| Upstream Event | Origin BC | Action in This Context |
|---------------|-----------|----------------------|
| `EventStarted` | Event Management | Engage ScheduleLock; block structural changes |
| `CandidateConfirmed` | Candidate Registration | Queue candidate for next AllocationRun |
| `WaitlistActivated` | Candidate Registration | Trigger WaitlistBackfill; allocate slot for promoted candidate |
| `RegistrationCancelled` | Candidate Registration | Vacate slot; trigger WaitlistBackfill if slot was occupied |

| Downstream Event | Consuming BC | Purpose |
|-----------------|--------------|---------|
| `SlotAllocated` | Candidate Registration | Update SlotReference on registration |
| `SlotAllocated` | Interview Management | Link candidate to interview room/time |
| `CandidatesAllocatedToSlots` | Communication | Trigger slot assignment notification emails |
| `CapacityOverridden` | Analytics & Audit | Audit trail for capacity changes |
