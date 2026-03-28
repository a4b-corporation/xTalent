# BENE-M-001 — Benefit Plan Management

**Type**: Masterdata | **Priority**: P0 | **BC**: BC-04 Benefits Administration
**Country**: [All countries — plan types vary per country]

---

## Purpose

Benefit Plan defines the structure, eligibility rules, cost sharing, and carrier details for a company benefit offering (health, dental, life, vision, disability, etc.). HR Admin creates and manages plans per LegalEntity. Plans are linked to benefit carriers via EDI 834. Workers see only plans they are eligible for during enrollment windows.

---

## Fields

| Field | Type | Required | Validation | Label (VI) |
|-------|------|---------|-----------|-----------|
| `id` | UUID | Auto | Generated | - |
| `name` | String(200) | Yes | Unique within LE | Tên gói phúc lợi |
| `plan_type` | Enum | Yes | HEALTH / DENTAL / VISION / LIFE / DISABILITY / ACCIDENT / OTHER | Loại phúc lợi |
| `carrier_id` | FK | Yes | Active carrier record | Nhà cung cấp bảo hiểm |
| `legal_entity_id` | FK | Yes | | Pháp nhân |
| `enrollment_window_start` | Date | Yes | | Bắt đầu đăng ký |
| `enrollment_window_end` | Date | Yes | > enrollment_window_start | Kết thúc đăng ký |
| `effective_date` | Date | Yes | ≥ enrollment_window_end | Ngày hiệu lực |
| `coverage_tiers` | Array[Enum] | Yes | EMPLOYEE_ONLY / PLUS_SPOUSE / PLUS_CHILDREN / FAMILY | Mức độ bảo hiểm |
| `monthly_premium` | JSON | Yes | {tier: amount, currency} per coverage_tier | Phí bảo hiểm tháng |
| `employer_contribution_pct` | Decimal(4,2) | Yes | 0–1; e.g., 0.80 = employer pays 80% | Phần NTD đóng |
| `employee_contribution_pct` | Decimal(4,2) | Auto | = 1 − employer_pct | Phần NLĐ đóng |
| `eligibility_rules` | JSON | Yes | min_service_months, employment_types, grade_min | Điều kiện đủ điều kiện |
| `allows_dependents` | Boolean | Yes | | Cho phép đăng ký người phụ thuộc |
| `dependent_verification_required` | Boolean | Yes | | Yêu cầu xác minh người phụ thuộc |
| `is_taxable_benefit_in_kind` | Boolean | Yes | If true → TaxableItem for employer portion above threshold | Phúc lợi bằng hiện vật chịu thuế |
| `is_active` | Boolean | Yes | Default true | Đang hoạt động |

---

## Operations

### Create
1. Actor: HR Admin
2. Select plan_type → pre-fills suggested coverage_tiers for that type
3. Link carrier (from carrier directory)
4. Set enrollment window dates and effective date
5. Configure monthly_premium per coverage tier
6. Set employer/employee contribution split
7. Define eligibility rules using visual rule builder:
   - Minimum service months (slider)
   - Employment types (checkboxes: Full-time, Part-time, Contract)
   - Grade minimum (dropdown)
8. Toggle: allows_dependents, dependent_verification_required
9. Preview: "Workers who would be eligible: 143"
10. Save → plan visible in next enrollment window

### Update
- Can update: `enrollment_window_start/end`, `is_active`, `monthly_premium` (before window opens)
- Cannot change: `plan_type`, `carrier_id`, `effective_date` after enrollment window has opened
- To change mid-year: terminate plan + create new plan

### Deactivate
- Sets `is_active = false`; existing enrollments unaffected until their effective end date

---

## Eligibility Preview

On plan detail page: "Check Eligibility" tool
- Shows count of eligible Workers
- Breakdown: by grade, employment type, service length
- Export list of eligible Workers

---

## Carrier Directory

Before creating plans, HR Admin must configure carriers:
- `carrier_name`, `carrier_code`, `country_code`, `plan_types_supported[]`
- EDI 834 config: `sender_id`, `receiver_id`, `isa_qualifier`, `endpoint`
- Test connection button

---

## Validation Rules

| Rule | When | Error |
|------|------|-------|
| enrollment_window_end < effective_date | On create | "Effective date must be after enrollment window closes" |
| employer_pct + employee_pct = 100% | Auto | employee_pct = 1 − employer_pct (auto-set) |
| monthly_premium must be defined for each coverage_tier | On create | "Premium missing for [tier]" |
| carrier must be active and support plan_type | On create | "Carrier does not support [plan_type]" |

---

*BENE-M-001 — Benefit Plan Management*
*2026-03-27*
