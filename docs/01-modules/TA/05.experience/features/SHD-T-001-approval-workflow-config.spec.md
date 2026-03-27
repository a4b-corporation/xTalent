# Approval Workflow Configuration — SHD-T-001

**Classification:** Masterdata (M — configures the approval routing engine for Leave, OT, and Timesheet)
**Priority:** P0
**Primary Actor:** HR Admin, System Admin
**Workflow States:** Configuration CRUD — no approval workflow on the config itself
**API:** `GET /approval-chains`, `POST /approval-chains`, `PUT /approval-chains/{id}`, `DELETE /approval-chains/{id}`
**User Story:** US-SHD-003
**BRD Reference:** BRD-SHD-003
**Hypothesis:** H1, H-P0-003 (skip-level routing for manager OT)

---

## Purpose

Approval Workflow Configuration allows HR Admins to define how Leave, OT, and Timesheet requests are routed through the approval hierarchy. This feature is a prerequisite for all approval-based transactions (ABS-T-001, ATT-T-003, ATT-T-004). It supports two routing modes — SKIP_LEVEL (follows the org chart, handles manager self-approval) and CUSTOM (explicitly defined step-by-step approver chain). The "Test Routing" tool lets admins simulate who would approve a specific employee's request before go-live.

---

## Screens and Steps

### Screen 1: Approval Workflow List

**Route:** `/admin/approvals/workflows`

**Entry points:**
- HR Admin → Settings → Approval Workflows
- SHD-T-005 Escalation config → "Manage Workflows" link

**Layout:**

```
Approval Workflows
──────────────────────────────────────────────────────────────────────
Name                   Type         Routing Mode   Escalation   Status  Actions
──────────────────────────────────────────────────────────────────────
Standard Leave Chain   Leave        SKIP_LEVEL     4h           Active  [Edit] [Test]
OT Request Chain       OT           SKIP_LEVEL     8h           Active  [Edit] [Test]
Timesheet Approval     Timesheet    CUSTOM         24h          Active  [Edit] [Test]
Senior Staff Leave     Leave        CUSTOM         2h           Active  [Edit] [Test]
──────────────────────────────────────────────────────────────────────
```

**Column definitions:**
- Name: admin-assigned label for the chain
- Type: Leave / OT / Timesheet
- Routing Mode: SKIP_LEVEL or CUSTOM
- Escalation: time before escalation fires (e.g., "4h" = 4 hours without approver action)
- Status: Active / Inactive
- Actions: Edit, Test Routing, Delete (soft-delete; only if not assigned to any policy)

**"+ New Workflow" button** (top-right)

**Note:** Multiple chains of the same type can exist; the leave policy (ABS-M-002) or shift policy determines which chain is assigned to which employee group.

---

### Screen 2: Create / Edit Approval Workflow

**Route:** `/admin/approvals/workflows/new` or `/admin/approvals/workflows/{id}/edit`

**Layout:**

**Section A — Basic Details:**

- Workflow Name (text, required; max 80 chars)
- Chain Type (dropdown; required):
  - Leave Request
  - Overtime Request
  - Timesheet
- Status toggle: Active / Inactive
- Escalation Timeout (number input, hours; required; min 1; max 168):
  - Helper: "After this many hours without action, the request escalates to the next level or to HR Admin."

**Section B — Routing Mode:**

Radio toggle: SKIP_LEVEL | CUSTOM

**SKIP_LEVEL mode view:**

```
Routing Mode: SKIP_LEVEL

How it works:
  1. Request goes to the employee's direct line manager (from Employee Central).
  2. If the submitter IS the manager: the request skips to the manager's own
     line manager (skip-level rule — H-P0-003).
  3. If no manager is found: routes to HR Admin.

Org Chart Preview:
  [Employee] → [Direct Manager] → [Senior Manager]
                    ↑
              (skip if self)

This chain requires no step configuration. Routing is dynamic
based on the live org chart.
```

- Org chart preview is illustrative; actual routing is computed at request time
- Footnote: "Ensure Employee Central integration is active. Missing reporting lines will route to HR Admin."

**CUSTOM mode view — Step Builder:**

```
Approval Steps

Step 1 ─────────────────────────────────────────
  Approver type:   ● Role  ○ Specific Person
  Role:            [Line Manager ▼]
  [ Remove step ]

Step 2 ─────────────────────────────────────────
  Approver type:   ○ Role  ● Specific Person
  Person:          [Nguyen Thi HR ▼ (search)]
  [ Remove step ]

[ + Add Step ]
─────────────────────────────────────────────────
Final fallback: HR Admin (if all steps unresolved)
```

- Steps can be reordered via drag handle
- Each step: Role selector (Line Manager, Department Head, HR Admin, Senior Manager) OR specific person search
- Max 5 steps enforced (system limit)
- "Add Step" disabled when 5 steps already configured
- Drag-and-drop reordering with keyboard-accessible alt (up/down arrows on step)

**Section C — Self-Approval Handling (Custom mode only; SKIP_LEVEL handles this automatically):**

```
Self-Approval Rule (for CUSTOM chains):
  What happens when the submitter IS the approver at a step?

  ● Skip this step and advance to the next
  ○ Route to HR Admin instead
  ○ Block submission with error
```

**Actions:**
- "Save Workflow" — POST (new) or PUT (edit)
- "Cancel" — returns to workflow list without saving
- Validation: cannot save CUSTOM chain with 0 steps

---

### Screen 3: Test Routing Tool

**Entry points:**
- Workflow list → "Test" button on any workflow row
- Workflow edit screen → "Test Routing" tab

**Layout:**

```
Test Routing for: Standard Leave Chain

Employee: [Search employee by name or ID]

[ Run Simulation ]
```

After simulation:

```
Routing Simulation — Standard Leave Chain
Employee: Nguyen Van A (Junior Engineer, Product Team)

Approval Path:
─────────────────────────────────────────
Step 1:  Tran Thi B (Line Manager, Engineering Lead)
         ← Found via Employee Central org chart

Step 2:  (No further steps — single-level chain)

Escalation after 4h: Le Van C (HR Admin)
─────────────────────────────────────────

What if Nguyen Van A were a manager?
  Step 1 would skip to: Dao Thi D (Senior Engineering Manager)
  Skip-level rule applies (H-P0-003)
─────────────────────────────────────────
```

- Shows the resolved approver names (not just roles) for the specific employee
- Shows skip-level simulation in a secondary block
- Shows escalation fallback
- Error states: "Could not resolve approver — reporting line missing in Employee Central" (with link to employee record)

---

## Notification Triggers

| Event | Recipient | Channel | Template |
|-------|-----------|---------|---------|
| Workflow activated | HR Admin | In-app | "Approval workflow '[name]' is now active and will be used for new [type] requests." |
| Workflow deactivated (while requests pending) | HR Admin | In-app warning | "Warning: Deactivating '[name]' affects [N] pending requests. Assign an alternative before deactivating." |

---

## Error States

| Error | User Message | Recovery Action |
|-------|-------------|-----------------|
| Delete workflow assigned to active policy | "Cannot delete — this workflow is assigned to [N] active leave policies. Remove the assignment first." | Update leave policies to use a different chain |
| Custom chain with 0 steps saved | "A CUSTOM approval chain must have at least 1 step." | Add at least one step |
| Escalation timeout = 0 | "Escalation timeout must be at least 1 hour." | Enter valid timeout |
| Test simulation — employee not found | "Employee not found. Please search by name or ID." | Use valid employee search |
| Test simulation — no reporting line | "Cannot resolve approver for [employee]. Their reporting line is not set in Employee Central." | Update org chart in Employee Central |

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-SHD-003 | Approval chain type determines which requests use this chain; each request type can have multiple chains assigned to different employee groups |
| BR-SHD-003-01 | SKIP_LEVEL: if submitter is a manager, the first approval step automatically skips to the manager's own line manager |
| BR-SHD-003-02 | SKIP_LEVEL: if the computed approver has no manager in the org chart, the request routes to HR Admin |
| BR-SHD-004 | Escalation fires after the configured timeout hours; the escalation target is the next step in the chain or HR Admin if no further steps exist |
| BR-SHD-005 | A workflow must be Active to be used; Inactive workflows cannot be assigned to new policies |
