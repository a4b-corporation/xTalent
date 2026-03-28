# VPAY-M-002 — Commission Plan Management

**Type**: Masterdata | **Priority**: P0 | **BC**: BC-03 Variable Pay
**Country**: [All countries]

---

## Purpose

Commission Plan defines quota, tier structure (rate per attainment band), accelerators for over-quota, and territory mapping for sales roles. Sales Compensation Admin creates and manages plans — typically annual or quarterly. Plans are validated to ensure tiers are non-overlapping and exhaustive. The plan drives real-time CommissionStatement recalculation as SalesTransactions import from CRM.

---

## Fields

| Field | Type | Required | Validation | Label (VI) |
|-------|------|---------|-----------|-----------|
| `id` | UUID | Auto | Generated | - |
| `name` | String(200) | Yes | Unique within scope | Tên kế hoạch hoa hồng |
| `code` | String(50) | Yes | Uppercase unique | Mã kế hoạch |
| `plan_year` | Integer | Yes | e.g., 2026 | Năm kế hoạch |
| `plan_period` | Enum | Yes | ANNUAL / QUARTERLY | Kỳ kế hoạch |
| `tier_type` | Enum | Yes | FLAT / TIERED / SLAB | Kiểu bậc hoa hồng |
| `quota_amount` | Decimal(18,4) | Yes | > 0 | Mục tiêu doanh số |
| `quota_currency` | Char(3) | Yes | ISO 4217 | Tiền tệ |
| `tiers` | Array | Yes | Non-overlapping; exhaustive (see below) | Bậc hoa hồng |
| `max_commission_amount` | Decimal(18,4) | No | NULL = no cap | Trần hoa hồng tối đa |
| `eligible_job_family_ids` | Array[FK] | No | NULL = all | Nhóm ngành nghề |
| `country_code` | Char(2) | No | | Quốc gia |
| `is_active` | Boolean | Yes | Default true | Đang hoạt động |

### Commission Tier Sub-table

| Field | Type | Required | Description | Label (VI) |
|-------|------|---------|-------------|-----------|
| `from_pct` | Decimal(6,2) | Yes | Lower attainment bound (inclusive); e.g., 0 | Từ % quota |
| `to_pct` | Decimal(6,2) | No | Upper attainment bound (exclusive); NULL = unbounded | Đến % quota |
| `rate` | Decimal(6,4) | Yes | Commission rate; e.g., 0.08 = 8% of sales | Tỷ lệ hoa hồng |
| `accelerator` | Decimal(5,2) | No | Multiplier for over-quota; e.g., 1.5 | Hệ số tăng tốc |

---

## Operations

### Create
1. Actor: Sales Compensation Admin, HR Admin
2. Select plan type and quota
3. Add tiers using "Commission Tier Builder" UI:
   - Visual band builder: drag to set attainment ranges
   - Rate input per band
   - Accelerator toggle for over-quota band
4. System validates: tiers non-overlapping, no gaps, last tier unbounded
5. Preview: sample calculation at 50%, 80%, 100%, 120% attainment
6. Save and activate

### Tier Validation (BR-V07)
On save, system checks:
- No overlapping ranges (e.g., two tiers both covering 80–100% is invalid)
- No gaps (e.g., 0–50% and 60–100% leaves 50–60% unhandled)
- Last tier has `to_pct = NULL` (unbounded top)
- All rates ≥ 0

If invalid: show visual error on tier builder with conflict highlighted.

### Update
- Active plan with running CommissionStatements: only `notes`, `max_commission_amount` can be updated
- To change tiers: deactivate plan, create new plan for next period

---

## Commission Calculator Preview UI

Interactive tool on plan detail page:
- Input: attainment % slider (0–200%)
- Shows: tier applied, amount calculated, whether cap applies
- Helps Sales Comp Admin verify plan design before activating

---

## Validation Rules

| Rule | When | Error |
|------|------|-------|
| Tiers must be non-overlapping | On create/update | "Tiers overlap at [range]" |
| Tiers must be exhaustive (no gaps) | On create/update | "Gap in tiers between [x]% and [y]%" |
| Last tier must be unbounded | On create/update | "Last tier must have no upper bound" |
| quota_amount > 0 | On create | "Quota must be positive" |

---

## Notifications

| Event | Recipients | Channel |
|-------|-----------|---------|
| Plan activated | Sales reps in eligible job families | In-app |
| Plan approaching end of period | Sales Comp Admin | In-app reminder |

---

*VPAY-M-002 — Commission Plan Management*
*2026-03-27*
