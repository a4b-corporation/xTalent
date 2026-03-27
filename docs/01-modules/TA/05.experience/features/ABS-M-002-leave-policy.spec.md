# Leave Policy Definition — ABS-M-002

**Classification:** Masterdata (M)
**Priority:** P0
**Primary Actor:** HR Administrator
**API:** `GET /leave-policies`, `POST /leave-policies`, `PUT /leave-policies/{id}`, `PATCH /leave-policies/{id}/activate`
**User Story:** US-ABS-008
**BRD Reference:** FR-ABS-002
**Hypothesis:** H1, H2, H3

---

## Purpose

A Leave Policy binds a group of employees to a set of leave types with specific entitlement rules: accrual plans, seniority multipliers, probation periods, and advance leave eligibility. Multiple policies can exist in a tenant to reflect different employment contracts (e.g., office vs. field staff, Vietnamese vs. expatriate employees). This configuration determines what leave entitlements each employee receives and how they accrue.

---

## Data Model (Key Fields)

| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| name | string | Yes | 2–100 chars | Policy display name |
| description | string | No | Max 500 chars | Internal notes |
| employee_group_rule | enum | Yes | ALL / DEPARTMENT / EMPLOYMENT_TYPE / CUSTOM_ATTRIBUTE | Who this policy applies to |
| employee_group_value | string | Conditional | Required if rule != ALL | E.g., department ID, employment type value |
| probation_period_days | integer | Yes | ≥ 0; default 60 | Days from hire before leave entitlement begins |
| effective_from | date | Yes | Cannot be in the past on creation | Policy start date |
| effective_to | date | No | Must be after effective_from if set | Policy end date; null = indefinite |
| status | enum | System-set | ACTIVE / INACTIVE / DRAFT | — |
| policy_lines | array | Yes | At least one line | List of leave type entitlements within this policy |

**Policy Line sub-model:**

| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| leave_type_id | UUID | Yes | Must reference ACTIVE leave type | Which leave type this line configures |
| accrual_plan_id | UUID | Conditional | Required if leave type entitlement_basis = ACCRUAL | Linked accrual plan |
| base_entitlement_days | integer | Conditional | Required if entitlement_basis = FIXED | Days granted at start of year/employment |
| seniority_multiplier | decimal | No | 0.00–2.00; default 1.00 | Multiplier applied after X years of service |
| seniority_trigger_years | integer | Conditional | Required if seniority_multiplier != 1.00 | Years of service threshold |
| advance_leave_max_days | integer | No | ≥ 0; 0 = no advance; only if leave type allows advance | Max advance days for this policy |

---

## Screen: List View

**Route:** `/config/leave-policies`

**Layout:**
- Page header: "Leave Policies" + "New Policy" primary button
- Filter: Status (All / Active / Inactive / Draft)
- Table columns: Name | Applies To | Leave Types Count | Effective From | Status | Actions

**Actions per row:** Edit | Activate/Deactivate | View assigned employees count | Duplicate

**Empty state:** "No leave policies defined. At least one active policy is required before employees can submit leave requests."

---

## Screen: Create / Edit Form

**Route:** `/config/leave-policies/new` and `/config/leave-policies/{id}/edit`

**Layout:** Two-panel form — left panel has policy meta; right panel (or below) has policy lines table.

### Section 1: Policy Identity
- Policy Name (required)
- Description (optional)
- Effective From — date picker (required)
- Effective To — date picker (optional)

### Section 2: Employee Group Targeting
- Applies To (radio: All Employees / By Department / By Employment Type / Custom)
- Conditional field based on selection:
  - Department: multi-select department picker (sourced from Employee Central)
  - Employment Type: multi-select (Full-time, Part-time, Contract, Intern)
  - Custom: attribute name + value text inputs

### Section 3: Probation
- Probation period — days (number input; default 60)
  - Help text: "Employees in probation cannot submit leave requests until this period ends from their hire date."

### Section 4: Leave Type Entitlements (Policy Lines)
- Table with "+ Add Leave Type" button
- Each row: Leave Type (dropdown from active leave types) | Entitlement Method | Accrual Plan (if ACCRUAL) | Base Days (if FIXED) | Seniority Multiplier | Advance Max Days
- Row actions: Edit inline | Remove row
- Minimum 1 row required to save

**Validation on save:**
- If policy applies to ALL employees and another ALL policy is already ACTIVE: warn "An active all-employees policy already exists. This will create a conflict. Assign employee groups to one policy to resolve."
- If any leave type in policy lines is INACTIVE: "Leave type [X] is inactive. Activate it before including it in this policy."

**Form actions:**
- Save as Draft
- Save and Activate (shows confirmation: "Activate this policy? It will apply to [N] employees.")
- Cancel

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-ABS-010 | Annual Leave entitlement in any policy line cannot be set below 14 days for VN employees (VLC Art. 113) |
| BR-ABS-011 | An employee may only be covered by one active policy at a time; overlapping policy groups are flagged |
| BR-ABS-012 | Policy changes are non-retroactive: already-accrued balance is not recalculated |
| BR-ABS-013 | Probation period is evaluated against the employee's hire date from Employee Central |
| BR-ABS-014 | A policy cannot be deactivated if employees with open leave requests are covered by it; deactivation is blocked until requests are resolved |
