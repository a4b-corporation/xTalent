# Glossary — BC-01: Pay Master

**Bounded Context**: Pay Master
**Module**: Payroll (PR)
**Step**: 3 — Domain Architecture
**Date**: 2026-03-31

---

## Purpose

This glossary defines the ubiquitous language for the Pay Master bounded context. All terms here have precise meanings within BC-01 and may differ from how the same word is used elsewhere in xTalent or in general HR parlance.

---

## Aggregate Roots

### PayGroup

| Field | Value |
|-------|-------|
| **Name** | PayGroup |
| **xTalent Term** | `pay_group` |
| **Type** | Aggregate Root |
| **Definition** | A named collection of workers processed together in each payroll cycle. A PayGroup is bound to a single `legal_entity_id`, a `PayCalendar`, a `currency_code`, and configurable operational parameters (standard work days, standard hours per day, OT monthly cap, night window). Workers belong to exactly one PayGroup at a time per working relationship. |
| **Khac voi (disambiguation)** | Not to be confused with a cost center or department. A PayGroup is purely a payroll processing unit — it defines when and how pay is calculated, not organizational hierarchy. |
| **States** | ACTIVE, INACTIVE |
| **Lifecycle Events** | PayGroupCreated, PayGroupUpdated, WorkerAssignedToPayGroup, WorkerRemovedFromPayGroup |

---

### PayElement

| Field | Value |
|-------|-------|
| **Name** | PayElement |
| **xTalent Term** | `pay_element` |
| **Type** | Aggregate Root |
| **Definition** | A single named component of a worker's pay or deduction. Each PayElement has a `classification` (EARNINGS, DEDUCTION, EMPLOYER_CONTRIBUTION, INFORMATION), a `tax_treatment` (TAXABLE, TAX_EXEMPT, TAX_EXEMPT_CAPPED), an `si_basis_inclusion` flag (INCLUDED, EXCLUDED), a `proration_method` (CALENDAR_DAYS, WORK_DAYS, NONE), a `priority_order` for deduction sequencing, and a formula definition with version history. A PayElement formula follows the lifecycle: DRAFT → PENDING_APPROVAL → APPROVED → ACTIVE → DEPRECATED. |
| **Khac voi** | Not equivalent to a "payroll item" in legacy systems. PayElement is a configuration object with a governed formula lifecycle — it is not a per-worker amount. Per-worker amounts are in PayrollResult. |
| **States** | DRAFT, PENDING_APPROVAL, APPROVED, ACTIVE, DEPRECATED |
| **Lifecycle Events** | PayElementCreated, PayElementFormulaSubmitted, PayElementFormulaApproved, PayElementActivated, PayElementDeprecated |

---

### PayProfile

| Field | Value |
|-------|-------|
| **Name** | PayProfile |
| **xTalent Term** | `pay_profile` |
| **Type** | Aggregate Root |
| **Definition** | A complete payment configuration template assigned to one or more workers. PayProfile defines: `pay_method` (how gross pay is computed), `proration_method` (how partial periods are handled), `rounding_method` (rounding rule for calculated amounts), `payment_method` (payment channel), `min_wage_rule_id` (reference to minimum wage statutory rule), `parent_profile_id` (for element inheritance from parent), and `si_basis_mode` (for piece-rate hybrid workers). PayProfile also owns its element bindings (PayProfileElement) and statutory rule bindings (PayProfileRule). |
| **Khac voi** | Not a "salary grade" or "compensation band." PayProfile is a calculation configuration template — it specifies the formula set and parameter set for pay computation. Compensation amounts come from CompensationSnapshot (BC-03). |
| **States** | ACTIVE, INACTIVE, ARCHIVED |
| **Lifecycle Events** | PayProfileCreated, PayProfileUpdated, PayProfileElementBound, PayProfileRuleBound |

---

### PayCalendar

| Field | Value |
|-------|-------|
| **Name** | PayCalendar |
| **xTalent Term** | `pay_calendar` |
| **Type** | Aggregate Root |
| **Definition** | A configured schedule of pay periods for a PayGroup within a legal entity. PayCalendar defines: frequency (MONTHLY, BI_WEEKLY, WEEKLY), period start/end dates, cut-off date (when snapshots are taken and attendance is locked), and payment date (disbursement date). Each PayPeriod (BC-03) is generated from the PayCalendar schedule. |
| **Khac voi** | Not the same as the holiday calendar (owned by TA module). PayCalendar defines when payroll processing occurs; holiday calendar defines non-working days for proration. |
| **States** | ACTIVE, INACTIVE |

---

## Entities

### PayProfileElement (Entity within PayProfile)

| Field | Value |
|-------|-------|
| **Name** | PayProfileElement |
| **Type** | Entity |
| **Definition** | A binding record linking a PayElement to a PayProfile. Specifies: `is_mandatory` (cannot be excluded for workers on this profile), `priority_order` (overrides element-level default), `effective_date` (when this binding takes effect). |

---

### PayProfileRule (Entity within PayProfile)

| Field | Value |
|-------|-------|
| **Name** | PayProfileRule |
| **Type** | Entity |
| **Definition** | A binding record linking a StatutoryRule (BC-02) to a PayProfile. Specifies: `rule_scope` (which element types this rule applies to), `execution_order` (order in the calculation pipeline). |

---

### WorkerPayGroupAssignment (Entity within PayGroup)

| Field | Value |
|-------|-------|
| **Name** | WorkerPayGroupAssignment |
| **Type** | Entity |
| **Definition** | An effective-dated record linking a `working_relationship_id` (from CO) to a PayGroup. Contains `effective_date` (start of assignment), `end_date` (optional, set on termination or transfer), and `assigned_by`. A worker can have only one active PayGroup assignment per working_relationship at any time. |

---

### FormulaVersion (Entity within PayElement)

| Field | Value |
|-------|-------|
| **Name** | FormulaVersion |
| **Type** | Entity |
| **Definition** | A versioned formula definition within a PayElement. Contains: `version_number`, `formula_script` (Drools DRL expression or parameter reference), `formula_script_hash` (SHA-256), `active_from` (effective date), `status` (DRAFT/PENDING_APPROVAL/APPROVED/ACTIVE/DEPRECATED), `approved_by`, `approved_at`. |

---

## Value Objects

### PieceRateTable

| Field | Value |
|-------|-------|
| **Name** | PieceRateTable |
| **Type** | Value Object (on PayProfile, when pay_method = PIECE_RATE) |
| **Definition** | A lookup table: `product_code` × `quality_grade` → `rate_per_unit_vnd` × `effective_date`. Used by BR-012 for piece-rate pay calculation. Immutable once published — new rates create a new table entry with a new `effective_date`. |

---

### HourlyRateConfig

| Field | Value |
|-------|-------|
| **Name** | HourlyRateConfig |
| **Type** | Value Object (on PayProfile, when pay_method = HOURLY) |
| **Definition** | A lookup table: `shift_type` × `grade_code` → `rate_per_hour_vnd` × `effective_date`. shift_type values: REGULAR, NIGHT, OT_WEEKDAY, OT_WEEKEND, OT_HOLIDAY. Used by BR-013. |

---

### PayScaleTable

| Field | Value |
|-------|-------|
| **Name** | PayScaleTable |
| **Type** | Value Object (on PayProfile, when pay_method = GRADE_STEP) |
| **Definition** | A lookup table: `grade_code` × `step_code` → `salary_amount_vnd` or `coefficient` × `effective_date`. Supports two modes (BR-014, BR-015): TABLE_LOOKUP (returns salary_amount_vnd directly) and COEFFICIENT_FORMULA (multiplies coefficient by VN_LUONG_CO_SO statutory rule value). |

---

### TaskDefinition

| Field | Value |
|-------|-------|
| **Name** | TaskDefinition |
| **Type** | Value Object (on PayProfile, when pay_method = TASK_BASED) |
| **Definition** | Defines task-based payment structure: `task_code`, `total_amount_vnd`, `milestone_schedule` (list of milestone tranches with amounts and payment triggers). Used by BR-018 and BR-019. |

---

## Domain Events

| Event Name | Aggregate | Description |
|------------|-----------|-------------|
| PayGroupCreated | PayGroup | A new PayGroup was configured |
| PayGroupUpdated | PayGroup | PayGroup configuration changed |
| WorkerAssignedToPayGroup | PayGroup | A working_relationship was enrolled in a PayGroup |
| WorkerRemovedFromPayGroup | PayGroup | A working_relationship was removed from a PayGroup |
| PayElementCreated | PayElement | A new PayElement was defined |
| PayElementFormulaSubmitted | PayElement | Formula submitted for approval (DRAFT → PENDING_APPROVAL) |
| PayElementFormulaApproved | PayElement | Formula approved (PENDING_APPROVAL → APPROVED) |
| PayElementActivated | PayElement | Formula activated (APPROVED → ACTIVE), previous version deprecated |
| PayElementDeprecated | PayElement | Formula superseded by newer version (ACTIVE → DEPRECATED) |
| PayProfileCreated | PayProfile | A new PayProfile was configured |
| PayProfileUpdated | PayProfile | PayProfile configuration changed |
| PayProfileElementBound | PayProfile | A PayElement was bound to a PayProfile |
| PayProfileRuleBound | PayProfile | A StatutoryRule was bound to a PayProfile |

---

## Commands

| Command Name | Actor | Description |
|--------------|-------|-------------|
| CreatePayGroup | Payroll Admin | Create a new PayGroup for a legal entity |
| UpdatePayGroup | Payroll Admin | Modify PayGroup configuration |
| AssignWorkerToPayGroup | Payroll Admin / CO Integration | Enroll a working_relationship in a PayGroup |
| RemoveWorkerFromPayGroup | Payroll Admin / CO Integration | Remove a working_relationship from a PayGroup |
| CreatePayElement | Payroll Admin | Define a new PayElement with classification and tax treatment |
| SubmitFormulaForApproval | Payroll Admin | Submit a formula draft for Finance Lead approval |
| ApproveFormula | Finance Lead | Approve a submitted formula |
| ActivateFormula | Payroll Admin | Activate an approved formula, deprecating the previous version |
| CreatePayProfile | Payroll Admin | Define a new PayProfile with pay method and configuration |
| UpdatePayProfile | Payroll Admin | Modify an existing PayProfile |
| BindElementToProfile | Payroll Admin | Attach a PayElement to a PayProfile with effective date |
| BindStatutoryRuleToProfile | Payroll Admin | Attach a StatutoryRule reference to a PayProfile |

---

## Business Rules (in scope for BC-01)

| Rule ID | Summary |
|---------|---------|
| BR-001 | Base salary pro-ration by calendar days |
| BR-002 | Base salary pro-ration by work days |
| BR-003 | Element-level proration override (NONE = always full pay) |
| BR-004 to BR-008 | OT premium configuration (multipliers stored as StatutoryRule references in PayProfile) |
| BR-009 | Hourly rate derivation divisors (configurable per PayGroup) |
| BR-011 | 13th month salary formula configuration |
| BR-012 | Piece-rate table configuration |
| BR-013 | Hourly rate config (multi-rate table) |
| BR-014 | Grade-Step TABLE_LOOKUP mode |
| BR-015 | Grade-Step COEFFICIENT_FORMULA mode |
| BR-016 | Step progression rule configuration |
| BR-017 | Piece-rate hybrid SI basis mode config |
| BR-018 | Task-based pay: milestone definition, freelance withholding configuration |
| BR-019 | Task-based: milestone trigger |
| BR-027 | SI basis inclusion flag per PayElement |
| BR-060 | Deduction priority order per PayElement and PayProfileElement |

---

## Terms Used from External Bounded Contexts

| Term | Source BC | How Used in BC-01 |
|------|-----------|-------------------|
| `working_relationship_id` | CO (EXT-01) | Foreign key on WorkerPayGroupAssignment — identifies which worker-employment context is assigned to a PayGroup |
| `legal_entity_id` | CO (EXT-01) | Multi-tenancy key on PayGroup, PayProfile, PayElement |
| `StatutoryRule` | BC-02 | Referenced by PayProfileRule to bind calculation rules to a PayProfile; PayProfile.min_wage_rule_id references a StatutoryRule |

---

## Pay Method Enum

| Value | Description |
|-------|-------------|
| MONTHLY_SALARY | Fixed monthly salary, pro-rated by calendar or work days for partial periods |
| HOURLY | Hourly rate × hours worked, rates from HourlyRateConfig table |
| PIECE_RATE | Rate per production unit from PieceRateTable |
| GRADE_STEP | Salary from PayScaleTable by grade and step (TABLE_LOOKUP or COEFFICIENT_FORMULA) |
| TASK_BASED | Payment triggered by milestone completion per TaskDefinition |
