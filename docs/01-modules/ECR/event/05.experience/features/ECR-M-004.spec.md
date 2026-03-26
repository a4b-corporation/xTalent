# ECR-M-004: Schedule Matrix Builder
**Type:** Masterdata | **Priority:** P1 | **BC:** BC-04
**Permission:** ecr.schedule.manage

## Purpose

Defines the physical interview schedule: rooms, time slots (shifts), capacity per slot, and track-to-room assignments. The output is the allocation grid used by ECR-T-008 (Candidate Slot Allocation). Built by TA staff before the event; editable until slot invitations are dispatched (ECR-T-009).

---

## Fields

### Room Definition

| Field | Type | Required | Validation | Notes |
|-------|------|----------|-----------|-------|
| room_name | String | Yes | 2–80 chars; unique within event | E.g., "Room A", "Hall 3" |
| room_capacity | Integer | Yes | 1–200 | Max simultaneous candidates in room |
| assigned_track_id | Reference | No | Must be a track in this event | Restricts which track's candidates are allocated here; null = all tracks |
| floor / location_note | String | No | Max 100 chars | Wayfinding note shown to interviewers |

### Time Slot (Shift) Definition

| Field | Type | Required | Validation | Notes |
|-------|------|----------|-----------|-------|
| slot_label | String | Yes | 2–50 chars; unique within event | E.g., "Shift 1 — 08:00–09:30" |
| slot_start_time | Time | Yes | Must be within event date range | |
| slot_end_time | Time | Yes | Must be > slot_start_time; max 4h duration | |
| slot_date | Date | Yes | Must be within event_start_date–event_end_date | Multi-day events have slots per day |
| max_candidates_per_slot | Integer | Yes | 1–500 | Across all rooms in this slot |

### Room × Slot Cell (Grid Cell)

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| capacity_override | Integer | No | Overrides room_capacity for this specific cell; blank = use room default |
| is_blocked | Boolean | No | Marks cell as unavailable (room maintenance, etc.); shown as greyed-out in grid |
| notes | String | No | Max 100 chars | Internal operational note |

---

## Schedule Grid View

**Screen:** /events/:id/schedule

The schedule is presented as a 2-dimensional grid:
- **Rows:** Rooms
- **Columns:** Time Slots (grouped by date for multi-day events)
- **Cells:** Show allocated capacity and current fill count once allocation begins

**Interactions:**
- Click cell → inline edit: capacity_override, is_blocked toggle, notes
- Drag time slot header to reorder columns
- Drag room row to reorder rows
- [Add Room] button → slide-out form
- [Add Slot] button → slide-out form
- [Block Cell] right-click context action

**Visual states:**
- Empty cell (no allocation): white
- Partial fill (> 0, < capacity): light blue with count badge
- Full cell: amber with "Full" badge
- Blocked cell: diagonal hatch pattern, "Blocked" label
- Locked cell (invitations sent): padlock icon; no edits allowed

---

## Export Options

| Export | Format | Content |
|--------|--------|---------|
| Schedule Grid | PDF | Print-ready room/slot grid with capacities |
| Schedule CSV | CSV | room, slot, date, start_time, end_time, capacity, fill_count |
| Interviewer Schedule | PDF | Per-interviewer timetable (requires ECR-M-005 data) |

---

## Empty State

"No rooms or time slots defined yet. Start by adding rooms and time slots to build your interview schedule." with [Add Room] and [Add Slot] buttons side by side.

---

## Bulk Actions

| Action | Scope | Notes |
|--------|-------|-------|
| Duplicate day | Slot group | Copy all slots from one event day to another day |
| Block all cells in slot | Column | Block entire time slot across all rooms |
| Delete slot | Column | Only if no candidates allocated to any cell in that slot |
| Delete room | Row | Only if no candidates allocated to any cell for that room |

---

## Business Rules

- A slot cannot start before event_start_date or end after event_end_date.
- Total schedule capacity (sum of all cell capacities) can exceed event max_capacity — this is allowed with an informational warning, not a block.
- Once ECR-T-009 dispatch begins for any slot, those cells are locked and cannot be edited.
- Blocked cells count as zero capacity in ECR-T-008 allocation algorithms.
