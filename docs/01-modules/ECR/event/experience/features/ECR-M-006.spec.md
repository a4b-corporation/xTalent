# ECR-M-006: Email Template Management
**Type:** Masterdata | **Priority:** P1 | **BC:** BC-07
**Permission:** ecr.template.manage

## Purpose

Manages reusable email templates for all system-generated communications: registration confirmation, slot invitation, session digest, waitlist promotion, and bulk outreach. Templates use merge tags for dynamic content. TA staff create and activate templates; ECR-T-016 (Bulk Email Dispatch) and ECR-T-013 (Session Digest Dispatch) consume them.

---

## Fields

| Field | Type | Required | Validation | Notes |
|-------|------|----------|-----------|-------|
| template_name | String | Yes | 3–100 chars; unique | Internal identifier |
| template_code | String | Auto | Slugified from name; unique; immutable once created | Used in API references |
| template_type | Enum | Yes | RegistrationConfirmation / SlotInvitation / WaitlistPromotion / SessionDigest / BulkOutreach / Custom | Controls which merge tags are available |
| subject | String | Yes | 5–200 chars | Supports merge tags |
| body_html | Rich Text | Yes | Max 50,000 chars | Full HTML; supports merge tags; preview rendered |
| body_text | Plain Text | No | Auto-stripped from HTML if blank | Fallback for non-HTML email clients |
| from_name | String | No | Max 100 chars; default: org name | Sender display name |
| reply_to | Email | No | Valid email | Default: TA contact email |
| is_active | Boolean | Yes | Default: false | Only active templates selectable in dispatch |
| version | Integer | Auto | Incremented on each save | Read-only |
| created_by | Reference | Auto | | |
| updated_at | Timestamp | Auto | | |

### Supported Merge Tags (by template_type)

| Tag | Available In | Resolves To |
|-----|-------------|------------|
| `{{candidate_name}}` | All | Candidate full name |
| `{{event_name}}` | All | Event name |
| `{{event_date}}` | All | Event start date formatted |
| `{{event_location}}` | All | Location name |
| `{{sbd}}` | Registration, Slot Invitation | Candidate SBD |
| `{{track_name}}` | Registration, Slot | Track name |
| `{{slot_date}}` | Slot Invitation | Slot date |
| `{{slot_time}}` | Slot Invitation | Slot start–end time |
| `{{room_name}}` | Slot Invitation | Room name |
| `{{confirm_url}}` | Slot Invitation | Candidate confirmation deep link |
| `{{kit_link}}` | Session Digest | HM interview kit URL |
| `{{interviewer_name}}` | Session Digest | Interviewer full name |
| `{{session_date}}` | Session Digest | Session date/time |
| `{{unsubscribe_url}}` | BulkOutreach | Legal unsubscribe link (auto-appended if not included) |

---

## List View

**Screen:** /settings/email-templates (or /events/:id/templates for event-scoped view)

| Column | Sortable | Notes |
|--------|---------|-------|
| Template Name | Yes | Link to edit |
| Type | No | Badge |
| Status | Yes | Active / Inactive |
| Version | No | |
| Last Updated | Yes | Relative time |
| Used In | No | Count of events/jobs referencing this template |
| Actions | No | Edit / Duplicate / Activate / Deactivate / Preview |

**Search:** By template name (partial match)
**Filters:** Type (multi-select), Status (Active / Inactive)
**Default sort:** Last updated descending
**Page size:** 20 rows

---

## Preview Mode

- [Preview] button opens a modal with rendered HTML using sample merge tag values.
- Sample values are system defaults (e.g., "Nguyen Van A", "Event Day 2026") and are not editable in preview.
- Toggle between HTML view and Plain Text view.
- [Send Test Email] button: sends preview to the current user's email address.

---

## Version History

- Every save creates a new version record (read-only).
- [History] tab on template edit page shows: version number, saved by, saved at, diff summary.
- [Restore] button on any historical version: creates a new version with the restored content (does not overwrite — append only).

---

## Empty State

"No email templates yet. Create templates to enable system communications and bulk email dispatch." with [Create Template] button.

---

## Business Rules

- Only Active templates are selectable in ECR-T-016 (Bulk Email Dispatch) and ECR-T-013 (Session Digest).
- A template in use by a queued or in-progress bulk email job cannot be deactivated until the job completes (system blocks with error message).
- `unsubscribe_url` merge tag is auto-appended to BulkOutreach templates if not explicitly included in body_html (compliance requirement).
- Template body must contain at least one merge tag to be activated (warns but does not block for Custom type).
- Deleting a template is only allowed if it has no usage history; otherwise, Deactivate is the only option.
