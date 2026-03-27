# Leave Type Configuration — ABS-M-001

**Classification:** Masterdata (M)
**Priority:** P0
**Primary Actor:** HR Administrator
**Secondary Actors:** System Admin (activate/deactivate only)
**API:** `GET /leave-types`, `POST /leave-types`, `PUT /leave-types/{id}`, `PATCH /leave-types/{id}/activate`, `DELETE /leave-types/{id}` (soft-delete)
**User Story:** US-ABS-007
**BRD Reference:** FR-ABS-001
**Hypothesis:** H1, H3

---

## Purpose

Leave Type is the foundational configuration entity for the Absence Management bounded context. Each leave type defines the rules that govern how employees earn, use, and carry over a category of absence (e.g., Annual Leave, Sick Leave, Unpaid Leave). Downstream features — Leave Policies, Accrual Plans, Leave Requests — all depend on at least one active leave type. This screen enables HR Admins to set up and maintain leave types without engineering assistance.

---

## Data Model (Key Fields)

| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| code | string | Yes | Unique per tenant; 2–20 chars; uppercase letters + underscores only | Internal identifier (e.g., `ANNUAL`, `SICK`) |
| name | string | Yes | 2–100 chars | Display name shown to employees |
| name_vi | string | No | 2–100 chars | Vietnamese display name |
| entitlement_basis | enum | Yes | ACCRUAL / FIXED / UNLIMITED | How the balance is granted |
| country_code | string | Yes | ISO 3166-1 alpha-2 (e.g., VN, SG) | Country applicability; multi-select |
| annual_floor_days | integer | Conditional | ≥ 14 if leave_type = ANNUAL and country_code includes VN (VLC Art. 113) | Vietnam minimum entitlement floor |
| allow_advance_leave | boolean | Yes | Default: false | Allow negative balance for this type |
| carryover_allowed | boolean | Yes | Default: false | Whether unused balance carries to next year |
| encashment_eligible | boolean | Yes | Default: false | Allow balance payout |
| evidence_required | boolean | Yes | Default: false | Require supporting document on submission |
| evidence_grace_period_days | integer | Conditional | ≥ 0; required if evidence_required = true | Days to submit evidence after leave starts |
| cancellation_deadline_days | integer | Yes | ≥ 0; 0 = cancellation always allowed; default: 3 | Days before leave start that self-cancellation is blocked |
| status | enum | System-set | ACTIVE / INACTIVE / DRAFT | Lifecycle state |
| paid | boolean | Yes | Default: true | Whether leave is paid |

---

## Screen: List View

**Route:** `/config/leave-types`

**Layout:**
- Page header: "Leave Types" + "New Leave Type" primary button
- Search bar: text search by name or code
- Filter chips: Status (All / Active / Inactive), Country (VN / SG / All)
- Data table with columns: Name | Code | Country | Entitlement Basis | Status | Actions

**Table columns detail:**
- Name: primary text; Vietnamese name in secondary text below (if set)
- Code: monospace badge
- Country: flag icon(s)
- Entitlement Basis: chip (ACCRUAL = blue, FIXED = green, UNLIMITED = purple)
- Status: chip (ACTIVE = green, INACTIVE = grey, DRAFT = orange)
- Actions: "Edit" icon button; "Deactivate" / "Activate" toggle; kebab menu with "View history"

**Empty state:** "No leave types configured. Create your first leave type to start building leave policies."

**Row limit:** Paginated; 25 per page. All types shown — no role-based filtering for HR Admin.

---

## Screen: Create / Edit Form

**Route:** `/config/leave-types/new` and `/config/leave-types/{id}/edit`

**Layout:** Single-page form with logical sections, inline validation.

### Section 1: Basic Information
- Name (text input; required)
- Name — Vietnamese (text input; optional)
- Code (text input; required; auto-converts to uppercase; edit locked after activation)
- Country Applicability (multi-select checkbox; required; at least one country)
- Paid leave (toggle; default on)

### Section 2: Entitlement
- Entitlement Basis (radio group: Accrual / Fixed / Unlimited)
- Annual floor days (number input; shown only if country = VN; auto-populated with 14; HR Admin can increase but not decrease below 14)
  - Inline warning if value < 14: "Vietnam Labor Code 2019 Art. 113 requires minimum 14 days annual leave. Value will be rejected."

### Section 3: Balance Rules
- Allow advance leave (toggle; default off)
  - Warning on enable: "Enabling advance leave allows employees to go into negative balance. Ensure your payroll policy supports this."
- Carry-over allowed (toggle; default off)
  - When enabled: shows link "Configure carry-over rules in Carry-Over Rules section"
- Encashment eligible (toggle; default off)

### Section 4: Evidence Requirements
- Evidence required (toggle; default off)
- Evidence grace period — days (number input; shown when evidence required = on; range 0–30)
- Acceptable evidence types (multi-select: Medical certificate / Employer notice / Self-declaration / Other)

### Section 5: Cancellation Policy
- Cancellation deadline — days before start (number input; default 3; range 0–30)
  - Help text: "0 = employee can cancel at any time up to the leave start date."

**Form actions:**
- "Save as Draft" — saves without activating; status = DRAFT
- "Save and Activate" — saves and sets status = ACTIVE; requires confirmation if first activation
- "Cancel" — prompts if unsaved changes

**Post-save behavior:**
- Create: return to list with success toast "Leave type created"
- Edit: stay on form with success toast "Leave type updated"
- If code is changed on edit after previous requests exist: show warning "Changing the code will not affect existing leave requests but may affect reporting. Confirm?"

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-ABS-001 | Leave type code must be unique per tenant |
| BR-ABS-002 | Annual leave floor must be ≥ 14 days for Vietnam (VLC Art. 113) |
| BR-ABS-003 | Code is immutable after first leave request is created against this type |
| BR-ABS-004 | A leave type cannot be deleted if active leave requests reference it; only INACTIVE is permitted |
| BR-ABS-005 | Deactivating a leave type blocks new requests; does not affect in-flight requests |
