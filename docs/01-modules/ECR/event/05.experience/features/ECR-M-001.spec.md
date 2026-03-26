# ECR-M-001: Event Configuration
**Type:** Masterdata | **Priority:** P1 | **BC:** BC-01
**Permission:** ecr.event.manage

## Purpose

Core metadata record for a Recruitment Event. Configured during event creation (wizard Step 1) and editable until the event reaches RegOpen state. Fields define the event's identity, logistics, and operational window. This data is referenced across all other BCs.

---

## Fields

| Field | Type | Required | Validation | Notes |
|-------|------|----------|-----------|-------|
| event_name | String | Yes | 3–150 chars; unique within same date range (warning, not block) | Display name shown on portal and all emails |
| event_type | Enum | Yes | Values: JobFair / CampusRecruitment / WalkInDay / Custom | Affects default template selection |
| description | Rich Text | No | Max 2000 chars | Shown on candidate registration portal |
| event_start_date | Date | Yes | Must be future date at publish time | Combined with time for InProgress trigger |
| event_start_time | Time | No | Default: 08:00 | |
| event_end_date | Date | Yes | Must be >= event_start_date | |
| event_end_time | Time | No | Default: 18:00 | |
| registration_open_date | Date | Yes | Must be < event_start_date | Portal becomes live at this datetime |
| registration_close_date | Date | Yes | Must be <= event_start_date | Portal closes at this datetime |
| location_name | String | Yes | 3–200 chars | Venue name; shown on portal and emails |
| location_address | String | No | Max 500 chars | Full address; shown on portal |
| max_capacity | Integer | Yes | 1–10,000 | Total across all tracks; enforced at registration |
| event_logo_url | File/URL | No | JPG/PNG; max 2MB | Shown on registration portal header |
| contact_email | Email | No | Valid email format | Shown to candidates for questions |
| contact_phone | String | No | Vietnamese format | Shown to candidates for questions |
| slug | String | Auto-generated | URL-safe; unique; derived from event_name | Used in /register/:eventSlug portal URL; editable until Published |
| internal_code | String | No | Alphanumeric, max 20 chars | Internal reference code; not shown to candidates |

---

## List View

**Screen:** /events

| Column | Sortable | Notes |
|--------|---------|-------|
| Event Name | Yes | Link to /events/:id |
| Type | No | Chip badge |
| Status | Yes | Draft / Published / RegOpen / InProgress / Closed / Archived |
| Start Date | Yes | |
| Registered | No | Live count |
| Location | No | |
| Created By | No | |
| Actions | No | Edit / Clone / Cancel (context-sensitive per status) |

**Search:** By event name (partial match, case-insensitive)
**Filters:** Status (multi-select), Date range (start date), Event type, Created by
**Default sort:** Start date descending
**Page size:** 20 rows; pagination

---

## Empty State

"No recruitment events yet. Create your first event to get started." with [Create Event] button.

---

## Bulk Actions

| Action | Applicable States | Notes |
|--------|-----------------|-------|
| Clone selected | Any | Creates Draft copies with "(Copy)" suffix |
| Archive selected | Closed only | Batch archive |
| Export list | Any | CSV with all visible fields |
