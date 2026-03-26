# ECR-M-002: Track Configuration
**Type:** Masterdata | **Priority:** P1 | **BC:** BC-01
**Permission:** ecr.track.manage

## Purpose

Defines hiring tracks within a Recruitment Event. Each track maps to one Job Request and carries its own candidate question set, target headcount, and screening criteria. Tracks are configured after the event is created (wizard Step 2) and remain editable until the event enters RegOpen state.

---

## Fields

| Field | Type | Required | Validation | Notes |
|-------|------|----------|-----------|-------|
| track_name | String | Yes | 3–100 chars; unique within event | Displayed to candidates on registration portal |
| job_request_id | Reference | Yes | Must be an active Job Request in the same org | Links to talent demand source |
| description | Rich Text | No | Max 1000 chars | Shown to candidate on portal to describe the role |
| target_headcount | Integer | Yes | 1–500 | Target intake for this track; does not hard-block registration unless combined with event max_capacity |
| screening_criteria | Text | No | Max 500 chars | Internal note for evaluators; not shown to candidates |
| question_set_id | Reference | No | Must be a published Question Set | Track-specific questions appended to the base form |
| is_active | Boolean | Yes | Default: true | Inactive tracks are hidden from the registration portal |
| display_order | Integer | Auto | Auto-incremented; drag to reorder | Controls order shown on registration portal |

---

## List View

**Screen:** /events/:id/tracks

| Column | Sortable | Notes |
|--------|---------|-------|
| Track Name | Yes | Link to track edit drawer |
| Job Request | No | Linked job title + requisition ID |
| Target Headcount | No | |
| Registered | No | Live count of candidates registered to this track |
| Question Set | No | Name or "None" |
| Status | No | Active / Inactive badge |
| Actions | No | Edit / Deactivate / Delete (delete only when zero registrations) |

**Search:** By track name
**Filters:** Active/Inactive toggle
**Default sort:** display_order ascending
**Page size:** All tracks shown (no pagination — typically < 20 tracks per event)

---

## Empty State

"No tracks configured yet. Add at least one track before publishing the event." with [Add Track] button.

---

## Bulk Actions

| Action | Applicable | Notes |
|--------|-----------|-------|
| Deactivate selected | Active tracks | Hides from portal; existing registrations unaffected |
| Delete selected | Tracks with 0 registrations | Confirmation required |

---

## Edit Constraints

- Track cannot be deleted if any candidate is registered to it; deactivate instead.
- question_set_id is locked once event reaches RegOpen (form version is locked).
- target_headcount can be increased at any point; decreasing below current registered count shows a warning but is allowed.
