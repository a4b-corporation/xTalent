# COMP-M-002 — Pay Component Definition Management

**Type**: Masterdata | **Priority**: P0 | **BC**: BC-01 Compensation Management
**Country**: [All countries]

---

## Purpose

Pay Component Definitions are the reusable building blocks of compensation. Each component represents a distinct element of pay — BASE salary, an ALLOWANCE, a BONUS, a DEDUCTION, or OVERTIME premium. These definitions carry metadata critical to downstream processing: whether the component is taxable (routes through Taxable Bridge), whether it is proration-eligible (considered in mid-period calculations), and how it is classified for statutory reporting. Components are defined once at the LegalEntity or platform level and referenced in Salary Basis definitions and individual SalaryRecords.

---

## Fields

| Field | Type | Required | Validation | Label (VI) |
|-------|------|----------|------------|-----------|
| `id` | UUID | Auto | Generated | - |
| `name` | String(100) | Yes | Unique within LegalEntity | Tên cấu phần lương |
| `code` | String(30) | Yes | Uppercase, unique within LE | Mã |
| `type` | Enum | Yes | BASE / ALLOWANCE / BONUS / DEDUCTION / OVERTIME | Loại |
| `legal_entity_id` | FK | Yes | Active LegalEntity | Pháp nhân |
| `country_code` | String(2) | Auto | From LegalEntity | Quốc gia |
| `is_taxable` | Boolean | Yes | Default true | Chịu thuế |
| `taxable_bridge_category` | Enum | Conditional | Required if is_taxable = true. Values: CASH / BENEFIT_IN_KIND / BONUS | Danh mục thuế |
| `is_proration_eligible` | Boolean | Yes | Default true | Tính lương tháng lẻ |
| `is_si_subject` | Boolean | Yes | Default depends on type (BASE = true, others configurable) | Tính BHXH [VN] |
| `gl_account_code` | String(30) | No | Finance GL reference | Mã tài khoản kế toán |
| `description` | Text | No | Max 500 chars | Mô tả |
| `is_active` | Boolean | Yes | Default true | Đang hoạt động |
| `created_by` | FK | Auto | Current user | - |
| `created_at` | Timestamp | Auto | System | - |

---

## Operations

### Create

1. Actor: Compensation Administrator, HR Administrator
2. Fill form fields
3. `type` selection auto-sets recommended defaults:
   - BASE: is_taxable=true, is_si_subject=true, is_proration_eligible=true
   - ALLOWANCE: is_taxable=true, is_si_subject=false (configurable), is_proration_eligible=true
   - BONUS: is_taxable=true, is_si_subject=false, is_proration_eligible=false
   - DEDUCTION: is_taxable=false, is_si_subject=false, is_proration_eligible=true
   - OVERTIME: is_taxable=true, is_si_subject=true, is_proration_eligible=false
4. All defaults overridable by user
5. Save → record created

### Read / List

- List: filterable by type, is_taxable, is_proration_eligible, is_active, country
- Search: by name, code
- Sort: by name, type, created_at
- Detail view shows: all fields + list of Salary Basis definitions that reference this component + active worker count

### Update

- All fields editable except `type` and `code` (changing type would break historical calculations)
- Changing `is_taxable` or `is_si_subject` shows warning: "This change affects N active salary records. Downstream calculations will use new setting from next payroll period."

### Delete / Archive

- Soft delete: `is_active = false`
- Hard delete blocked if any SalaryRecord or SalaryBasis references this component
- Archive shows "Archived" badge on list view

---

## Validation Rules

| Rule | Condition | Error Message |
|------|-----------|--------------|
| Unique code per LE | Duplicate code within LegalEntity | "Mã cấu phần lương đã tồn tại." |
| Taxable bridge required | `is_taxable = true` requires `taxable_bridge_category` | "Vui lòng chọn danh mục thuế cho cấu phần chịu thuế." |
| Type immutable | Type cannot be changed after workers have salary records using it | "Không thể thay đổi loại cấu phần khi đã có bản ghi lương đang hoạt động." |

---

## Notifications

None — configuration record. All changes captured in Audit Trail.

---

## Related Features

- COMP-M-001 Salary Basis — references PayComponentDef
- CALC-T-001 SI Contribution Run — uses is_si_subject flag
- BRDG-T-001 Taxable Item Processing — uses is_taxable + taxable_bridge_category
- CALC-T-002 Proration — uses is_proration_eligible flag

---

*COMP-M-002 Spec — Total Rewards / xTalent HCM*
*2026-03-26*
