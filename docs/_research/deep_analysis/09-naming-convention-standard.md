# Naming Convention Standard

**Scope**: Standardize naming conventions across all xTalent DBML modules  
**Assessed**: 2026-03-16

---

## 1. Current Inconsistencies Found

### 1.1 Timestamp Fields

| Module | Pattern 1 | Pattern 2 | Recommendation |
|--------|-----------|-----------|:-------------:|
| Core | `created_at` | — | ✅ Use `created_at` |
| TR | `created_date` | `created_at` (mixed) | ⚠️ Inconsistent |
| PR | `created_at` | — | ✅ Consistent |
| TA | `created_at` | — | ✅ Consistent |

### 1.2 Business Date Fields

| Module | Pattern | Examples | Recommendation |
|--------|---------|---------|:-------------:|
| Core | `{name}_date` | `hire_date`, `termination_date` | ✅ Use `{name}_date` |
| TA | `{name}` only | `effective_start` (no `_date`) | ⚠️ Missing suffix |
| TR | `{name}` mixed | `effective_start` + `sent_date` | ⚠️ Mixed |

### 1.3 Status Fields

| Pattern | Used in | Count |
|---------|---------|:-----:|
| `status_code` | Core, PR | Most tables |
| `status` | TR recognition, offer | Several tables |
| `state_code` | TA absence | 1 table |

### 1.4 Boolean Fields

| Pattern | Examples | Module |
|---------|---------|--------|
| `is_{name}` | `is_active`, `is_current_flag`, `is_paid` | All |
| `{name}_flag` | `taxable_flag`, `pre_tax_flag`, `primary_flag` | PR, Core |
| `{name}` only | `approved`, `accepted` | TR offer |

### 1.5 FK Naming

| Pattern | When to Use | Examples |
|---------|------------|---------|
| `{entity}_id` | FK to uuid PK | `employee_id`, `position_id` |
| `{entity}_code` | FK to varchar code | `country_code`, `status_code` |
| Mixed | Same entity, different naming | `worker_id` vs `employee_id` for same concept |

---

## 2. Standard Conventions

### 2.1 Table Naming

```
Table {schema}.{entity_name} {
  // entity_name: singular, snake_case
  // Examples: employee, pay_element, leave_type
}
```

### 2.2 Column Naming

| Category | Convention | Examples |
|----------|-----------|---------|
| **Primary Key** | `id uuid [pk]` | `id` |
| **Foreign Key (uuid)** | `{target_entity}_id` | `employee_id`, `batch_id` |
| **Foreign Key (code)** | `{target_entity}_code` | `country_code`, `currency_code` |
| **Status** | `status_code varchar(50)` | `status_code` (always, never `status` or `state_code`) |
| **Boolean** | `is_{name} boolean` | `is_active`, `is_paid`, `is_primary` (drop `_flag`) |
| **Business date** | `{name}_date date` | `hire_date`, `start_date`, `end_date` |
| **Effective dates** | `effective_start_date`, `effective_end_date` | SCD-2 always with `_date` suffix |
| **Audit timestamps** | `created_at timestamp` | `created_at`, `updated_at` (always `_at`) |
| **Amount** | `{name}_amount decimal(18,4)` | `basis_amount`, `gross_amount` |
| **Code (lookup)** | `{name}_code varchar(50)` | `type_code`, `reason_code` |
| **JSON** | `{name}_json jsonb` | `rule_json`, `metadata` (exception: just `metadata`) |
| **Counter** | `{name}_count int` | `line_count`, `approval_count` |

### 2.3 SCD Type-2 Fields (Standard Block)

Every date-effective config table MUST have:
```dbml
  // SCD Type-2
  effective_start_date date [not null]
  effective_end_date   date [null]
  is_current          boolean [default: true]
  
  // Audit
  created_at           timestamp [default: `now()`]
  updated_at           timestamp [null]
```

> Note: Use `is_current` (not `is_current_flag`).

### 2.4 Version Tracking (when applicable)

```dbml
  version_number       int [default: 1]
  previous_version_id  uuid [ref: > self.id, null]
  is_current_version   boolean [default: true]
```

### 2.5 Index Naming

```
  Indexes {
    (col1, col2) [unique]                    // composite unique
    (col1) [name: 'idx_{table}_{purpose}']   // named index
  }
```

---

## 3. Specific Fixes Needed

### Core Module

| Current | Fix to | Table |
|---------|--------|-------|
| `is_current_flag` | `is_current` | All tables |
| `primary_flag` | `is_primary` | `employment.contract` |
| Missing `created_at`/`updated_at` | Add | `common.code_list` |

### TA Module

| Current | Fix to | Table |
|---------|--------|-------|
| `effective_start` | `effective_start_date` | All TA tables |
| `effective_end` | `effective_end_date` | All TA tables |
| `state_code` | `status_code` | `absence.leave_instant` |
| `clock_in`/`clock_out` | Keep (domain-specific) | `ta.clock_event` |

### TR Module

| Current | Fix to | Table |
|---------|--------|-------|
| `created_date` | `created_at` | All TR tables using `created_date` |
| `status` (no suffix) | `status_code` | `recognition_event`, `perk_redeem`, `offer_package` |
| `accepted` | `is_accepted` | `offer_acceptance` |
| `taxable` | `is_taxable` | `pay_component_def` |
| `prorated` | `is_prorated` | `pay_component_def` |

### PR Module

| Current | Fix to | Table |
|---------|--------|-------|
| `taxable_flag` | `is_taxable` | `pay_element` |
| `pre_tax_flag` | `is_pre_tax` | `pay_element` |
| `processed_flag` | `is_processed` | Applicable tables |

---

## 4. Decimal Precision Standard

| Category | Precision | Examples |
|----------|:---------:|---------|
| Monetary amounts | `decimal(18,4)` | salary, bonus, tax, premium |
| Percentages/Rates | `decimal(6,4)` | tax_rate, si_rate, multiplier |
| Hours/Days | `decimal(6,2)` | worked_hours, leave_days |
| FTE | `decimal(4,2)` | fte, allocation_pct |
| Coordinates | `decimal(9,6)` | latitude, longitude |

---

*← [08 Cross-Module Data Flow](./08-cross-module-data-flow.md) · [10 Schema Improvement Roadmap →](./10-schema-improvement-roadmap.md)*
