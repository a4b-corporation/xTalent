# COMP-M-001 — Salary Basis Management

**Type**: Masterdata | **Priority**: P0 | **BC**: BC-01 Compensation Management
**Country**: [All countries]

---

## Purpose

Salary Basis defines the structural framework for how a worker's compensation is expressed and calculated — HOURLY, MONTHLY, or ANNUAL — along with which pay components are included in that basis. Each LegalEntity configures one or more Salary Basis definitions that are then assigned to workers via their WorkingRelationship. This configuration is foundational: downstream calculation (SI contribution, proration, payroll bridge) all depend on the salary_basis value associated with a worker.

---

## Fields

| Field | Type | Required | Validation | Label (VI) |
|-------|------|----------|------------|-----------|
| `id` | UUID | Auto | Generated | - |
| `name` | String(100) | Yes | Unique within LegalEntity | Tên cơ cấu lương |
| `code` | String(30) | Yes | Uppercase, no spaces, unique within LE | Mã |
| `frequency` | Enum | Yes | HOURLY / MONTHLY / ANNUAL | Tần suất thanh toán |
| `legal_entity_id` | FK | Yes | Must be valid active LegalEntity | Pháp nhân |
| `country_code` | String(2) | Yes | ISO 3166-1 alpha-2 | Quốc gia |
| `pay_component_refs` | Array[FK] | Yes | Min 1 component; must include component of type BASE | Cấu phần lương |
| `is_active` | Boolean | Yes | Default true | Đang hoạt động |
| `effective_from` | Date | Yes | Cannot be in the past when creating | Hiệu lực từ |
| `description` | Text | No | Max 500 chars | Mô tả |
| `created_by` | FK | Auto | Current user | - |
| `created_at` | Timestamp | Auto | System | - |
| `updated_at` | Timestamp | Auto | System | - |

---

## Operations

### Create

1. Actor: Compensation Administrator, HR Administrator
2. Opens "New Salary Basis" form
3. Selects `frequency` from dropdown (HOURLY / MONTHLY / ANNUAL)
4. Selects `legal_entity_id` (scoped to user's accessible legal entities)
5. `country_code` auto-populated from LegalEntity
6. Adds pay components from multi-select (filtered to active PayComponentDef records)
7. Sets `effective_from` date
8. Clicks "Save"
9. System validates (see Validation Rules)
10. Record created with `is_active = true`

### Read / List

- List view: filterable by LegalEntity, country, frequency, is_active
- Sortable by: name, code, effective_from, frequency
- Search: by name or code
- Detail view: shows all fields + linked pay components (with their types and taxability)

### Update

- Name, description, pay_component_refs, and is_active can be updated in-place
- `frequency`, `country_code`, and `legal_entity_id` cannot be changed after creation (hard constraint — would break historical salary records)
- If a worker has an active SalaryRecord using this basis, removing a pay component shows a warning

### Delete / Archive

- Soft delete: `is_active = false`
- Hard delete blocked if any SalaryRecord references this basis (even historical)
- Archive allowed; archived records visible in history with filter toggle

---

## Validation Rules

| Rule | Condition | Error Message |
|------|-----------|--------------|
| Unique code per LE | `code` must be unique within `legal_entity_id` | "Mã cơ cấu lương đã tồn tại trong pháp nhân này." |
| BASE component required | Must have at least one component with type = BASE | "Cơ cấu lương phải có ít nhất một cấu phần lương loại 'Lương Cơ Bản'." |
| Effective date | `effective_from` must be today or future | "Ngày hiệu lực phải là hôm nay hoặc trong tương lai." |
| Active components only | All referenced PayComponentDef must be active | "Cấu phần lương '[name]' đã bị vô hiệu hóa." |

---

## Notifications

None — this is a configuration record. Changes are captured in Audit Trail (BC-10) automatically.

---

## Related Features

- COMP-M-002 Pay Component Definition — source of pay_component_refs
- COMP-T-002 Salary Change Activation — uses Salary Basis
- CALC-T-001 SI Contribution Run — derives calculation base from Salary Basis
- CALC-A-001 Calculation Audit Report — references Salary Basis in breakdown

---

*COMP-M-001 Spec — Total Rewards / xTalent HCM*
*2026-03-26*
