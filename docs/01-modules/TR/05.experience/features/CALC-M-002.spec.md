# CALC-M-002 — Min Wage Config Management

**Type**: Masterdata | **Priority**: P0 | **BC**: BC-02 Calculation Engine
**Country**: [Country-specific — VN 4 zones; others Phase 2]

---

## Purpose

Min Wage Config stores statutory minimum wages by country and zone with effective dating (SCD Type 2). For Vietnam, 4 zones (I–IV) are determined by `WorkingRelationship.workplace_location`. The config is used for: (1) SI contribution cap calculation (20× min wage), (2) hard-block minimum wage validation on all salary changes and offers. Tax Admin updates this table when the government publishes new minimum wage decrees.

---

## Fields

| Field | Type | Required | Validation | Label (VI) |
|-------|------|---------|-----------|-----------|
| `id` | UUID | Auto | Generated | - |
| `country_code` | Enum | Yes | VN / SG / MY / ID / PH / TH | Quốc gia |
| `zone` | Enum | Yes | VN_ZONE_I / VN_ZONE_II / VN_ZONE_III / VN_ZONE_IV / GENERAL | Vùng lương |
| `monthly_min_wage` | Decimal(18,4) | Yes | > 0 | Lương tối thiểu tháng |
| `currency` | Char(3) | Yes | ISO 4217 | Đơn vị tiền tệ |
| `effective_start_date` | Date | Yes | Future; or current decree effective date | Ngày hiệu lực |
| `effective_end_date` | Date | Auto | Set when new version created | Ngày hết hiệu lực |
| `is_current` | Boolean | Auto | | Hiện hành |
| `regulatory_ref` | String(500) | Yes | Government decree reference | Căn cứ pháp lý (Nghị định) |
| `notes` | Text | No | | Ghi chú |

---

## Operations

### Create (New Wage Version)
1. Actor: Tax Admin, HR Admin
2. Select country + zone
3. Enter new monthly_min_wage + currency
4. Set effective_start_date (mandatory — must match government decree)
5. Enter regulatory_ref (e.g., "Nghị định 74/2024/NĐ-CP, hiệu lực 01/07/2024")
6. On save: new version inserted; previous version closed

**System auto-action**: After new min wage saved, system queries all Workers in affected zone whose current salary < new minimum → generates `MinWageAlert` report for HR Admin review.

### Read / List
- Show current config per zone per country
- Toggle: show all versions with effective history
- Visual timeline: "Zone I: 4,680,000 VND (until 30/06/2024) → 4,960,000 VND (from 01/07/2024)"

### Impact Analysis (on create)
Before confirming save, system shows:
- Count of Workers in this zone
- Count of Workers currently below new minimum
- Estimated cost impact (total salary increase needed)

---

## Vietnam Zone Mapping [VN-specific]

| Zone | Provinces / Districts |
|------|-----------------------|
| Zone I | Hà Nội (12 quận + một số huyện), TP.HCM (quận 1–12, Bình Thạnh, Gò Vấp, Tân Phú, Tân Bình, Phú Nhuận, Bình Tân) |
| Zone II | Các tỉnh/thành phố còn lại có đô thị loại I |
| Zone III | Các tỉnh còn lại |
| Zone IV | Các vùng nông thôn còn lại |

Zone mapping is configurable per `workplace_location` via lookup table (not hardcoded).

---

## Validation Rules

| Rule | When | Error |
|------|------|-------|
| effective_start_date cannot overlap existing version for same country+zone | On create | "Active config exists for this period" |
| monthly_min_wage must be ≥ previous version (cannot reduce statutory minimum) | On create | Warning: "New wage is lower than current. Confirm this is correct." |
| regulatory_ref required | On create | "Regulatory reference required for compliance" |

---

## Notifications

| Event | Recipients | Channel |
|-------|-----------|---------|
| New min wage created | HR Admin, Compensation Admin, Tax Admin | In-app + Email |
| Workers below new minimum detected | Compensation Admin | In-app alert with count + export |

---

*CALC-M-002 — Min Wage Config Management*
*2026-03-27*
