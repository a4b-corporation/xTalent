# ECR-T-002: Registration Form Builder
**Type:** Transaction | **Priority:** P1 | **BC:** BC-01
**Permission:** ecr.form.manage

## Purpose

Allows TA staff to design the candidate registration form for an event. Supports a base form (common to all tracks) and optional track-specific question blocks. Form is versioned and locked when the event reaches RegOpen state. The published form is consumed by ECR-T-004 (Candidate Self-Registration Portal).

---

## States

| State | Description | Entry Condition | Exit Transitions |
|-------|-------------|----------------|-----------------|
| Draft | Form is being designed; not visible to candidates | Initial state on form creation | → Published (on event publish) |
| Published | Form is locked; candidates can register | Event transitions to RegOpen | — (immutable) |

---

## Flow

### Step 1: Open Form Builder
**Screen:** /events/:id/form
**Actor sees:** Form canvas with existing fields (if any), field palette sidebar, track selector dropdown
**Actor does:** Selects "Base Form" or a specific track from the track selector
**System does:** Loads current field configuration for selected scope
**Validation:** None
**Errors:** None

### Step 2: Add / Edit Fields
**Screen:** /events/:id/form (inline editing)
**Actor sees:** Drag-and-drop field canvas; field types in left palette: Short Text, Long Text, Dropdown, Multi-select, Date, File Upload, Phone, Email, Number, Section Header, Divider
**Actor does:**
- Drags field type from palette onto canvas
- Clicks field to open right-side configuration panel
- Configures: label, placeholder text, help text, required/optional toggle, field key (auto-generated), validation rules per type
- Drags fields to reorder
- Clicks X to delete a field
**System does:** Saves form state to draft (auto-save every 30s; manual [Save] button available)
**Validation:**
- label: required, 2–200 chars
- field_key: unique within form scope; alphanumeric + underscore; auto-generated but editable
- File Upload: allowed types (PDF/JPG/PNG), max size (1–10MB, default 5MB)
- Dropdown/Multi-select: at least 2 options required
**Errors:**
- Duplicate field_key → inline error: "Field key must be unique within this form"
- Dropdown with < 2 options → "Add at least 2 options before saving"

### Step 3: Configure Track-Specific Questions
**Screen:** /events/:id/form (track selector = specific track)
**Actor sees:** Base fields shown as locked/greyed (inherited, not editable here); editable track-specific question block below
**Actor does:** Adds fields that apply only to this track; these appear after base fields on the candidate portal
**System does:** Stores track questions as a separate question_set linked to the track
**Validation:** Same field-level rules as Step 2
**Errors:** Same as Step 2

### Step 4: Preview Form
**Screen:** /events/:id/form → [Preview] button
**Actor sees:** Full-page modal showing rendered form as candidate would see it; track selector to preview per-track variant
**Actor does:** Reviews form; may close and continue editing
**System does:** Renders form using current draft state; does not modify any state
**Validation:** None
**Errors:** None

### Step 5: Save and Lock (on Event Publish)
**Screen:** Triggered automatically when TA publishes event (ECR-T-001 Step 3)
**Actor sees:** Publish confirmation modal includes line: "Registration form will be locked and cannot be edited once published."
**Actor does:** Confirms publish
**System does:**
- Transitions form to Published state
- Stamps form_version on the event record
- All subsequent registration submissions reference this locked version
- API: `POST /events/:id/publish` (includes form snapshot)
**Validation:**
- Base form must have at least 3 fields (name, email, phone are auto-required; cannot be removed)
- No field may have empty label
**Errors:**
- "Form has incomplete fields. Please review fields marked with errors before publishing."
- "Base form must include candidate name, email, and phone fields."

---

## Notifications Triggered

None from the form builder itself. Form lock is a side effect of ECR-T-001 publish flow.

---

## Business Rules Enforced

- **BR-F-001:** candidate_name, candidate_email, candidate_phone are system-required fields on the base form; they are pre-added and cannot be removed or made optional.
- **BR-F-002:** Once Published (RegOpen), no field additions, removals, or reordering are permitted.
- **BR-F-003:** Track-specific questions are appended after base fields; base field order cannot be changed from the track view.
- **BR-F-004:** File Upload fields accept PDF/DOC/JPG/PNG by default; TA may restrict to PDF only.
- **BR-F-005:** Form version is recorded with each registration submission so historical forms can be reconstructed for audit.

---

## Empty State

"No fields added yet. Drag fields from the palette to start building your registration form." with arrow pointing to field palette.

---

## Edge Cases

- If all tracks are deleted after form is built: base form is preserved; track question sets are soft-deleted but retained in version history.
- If event is cloned (ECR-T-003): form is copied to Draft state on the new event, fully editable.
- Multi-day event: form is single (not per-day); slot assignment is separate (ECR-T-008).
