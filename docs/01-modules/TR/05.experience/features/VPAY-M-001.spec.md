# VPAY-M-001 — Bonus Plan Management

**Type**: Masterdata | **Priority**: P0 | **BC**: BC-03 Variable Pay
**Country**: [All countries]

---

## Purpose

Bonus Plan defines the template for periodic bonus calculation — eligible population (by Grade, Job Family, or LE), target percentage of salary, performance modifier mapping, and approval thresholds. Plans are reusable across periods. HR Admin or Compensation Admin creates and manages plans. No code deployment required to change bonus percentages or performance modifier mappings.

---

## Fields

| Field | Type | Required | Validation | Label (VI) |
|-------|------|---------|-----------|-----------|
| `id` | UUID | Auto | Generated | - |
| `name` | String(200) | Yes | Unique within LE scope | Tên kế hoạch thưởng |
| `code` | String(50) | Yes | Uppercase, unique | Mã kế hoạch |
| `period_type` | Enum | Yes | ANNUAL / SEMI_ANNUAL / QUARTERLY / SPOT | Kỳ thưởng |
| `target_pct_of_salary` | Decimal(5,4) | Yes | 0 ≤ pct ≤ 5 (max 500% of salary); e.g., 0.15 = 15% | Mục tiêu % lương |
| `formula_json` | JSON | Yes | Valid FormulaJson structure | Công thức tính |
| `performance_modifiers` | Array | Yes | Min 1 modifier; must cover default rating | Hệ số hiệu suất |
| `eligible_grade_ids` | Array[FK] | No | NULL = all grades | Grade đủ điều kiện |
| `eligible_job_family_ids` | Array[FK] | No | NULL = all job families | Nhóm ngành nghề |
| `country_code` | Char(2) | No | NULL = all countries | Quốc gia |
| `config_scope_id` | UUID | No | Phase 2 | Phạm vi cấu hình |
| `max_bonus_pct` | Decimal(5,4) | No | Hard cap; NULL = no cap | Trần thưởng tối đa |
| `approval_threshold_pct` | Decimal(5,4) | No | Bonus above this % triggers extra approval | Ngưỡng phê duyệt bổ sung |
| `is_taxable` | Boolean | Yes | If true → TaxableItem created on payment | Chịu thuế |
| `is_active` | Boolean | Yes | Default true | Đang hoạt động |

### Performance Modifiers Sub-table

| Field | Type | Required | Description | Label (VI) |
|-------|------|---------|-------------|-----------|
| `rating_code` | String | Yes | Performance rating code from PM module | Mã đánh giá |
| `rating_label` | String | Yes | Human label (e.g., "Exceeds Expectations") | Nhãn |
| `multiplier` | Decimal(4,2) | Yes | 0 = no bonus; 1.0 = target; 1.5 = 150% of target | Hệ số |

---

## Operations

### Create
1. Actor: Compensation Admin, HR Admin
2. Fill plan details + period type + target %
3. Add performance modifier rows (one per rating level in PM module)
4. Define eligible population (grade/job family selectors, or leave blank for all)
5. Set max_bonus_pct and approval_threshold_pct if needed
6. Save as DRAFT → Activate when ready

### Update
- Active plans: can only update `is_active`, `notes`, `approval_threshold_pct`
- To change rates: create new plan version (deactivate old, create new)
- Cannot change formula_json on active plan with pending BonusStatements

### Deactivate
- Soft deactivate: sets `is_active = false`
- Cannot deactivate if active BonusStatements exist for current period (warn and block)

---

## Validation Rules

| Rule | When | Error |
|------|------|-------|
| Performance modifiers must cover all PM rating codes | On create | "Missing modifier for rating: [code]" |
| Modifiers must be non-negative | On create | "Multiplier cannot be negative" |
| target_pct_of_salary > 0 | On create | "Target percentage required" |
| eligible_grade_ids must be valid active grades | On create | "Invalid grade: [id]" |

---

## Notifications

| Event | Recipients | Channel |
|-------|-----------|---------|
| Plan created | Compensation Admin in scope | In-app |
| Plan deactivated | Workers potentially affected | In-app (optional, configurable) |

---

*VPAY-M-001 — Bonus Plan Management*
*2026-03-27*
