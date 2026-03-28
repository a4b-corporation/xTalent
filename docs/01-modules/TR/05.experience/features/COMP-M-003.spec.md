# COMP-M-003 — Pay Range Management

**Type**: Masterdata | **Priority**: P0 | **BC**: BC-01 Compensation Management
**Country**: [All countries]

---

## Purpose

Pay Ranges define the minimum, midpoint, and maximum salary for each Grade level within a LegalEntity. They serve as the guardrails for merit proposals, salary change validations, and offer creation. Pay Ranges use SCD Type 2 (Slowly Changing Dimension) versioning — there is no in-place edit; changes are made by creating a new effective-dated version. Historical ranges are preserved for retrospective analytics and compliance auditing.

---

## Fields

| Field | Type | Required | Validation | Label (VI) |
|-------|------|----------|------------|-----------|
| `id` | UUID | Auto | Generated | - |
| `grade_id` | FK | Yes | Active Grade from CO module | Cấp bậc |
| `legal_entity_id` | FK | Yes | Active LegalEntity | Pháp nhân |
| `country_code` | String(2) | Auto | From LegalEntity | Quốc gia |
| `currency_code` | String(3) | Yes | ISO 4217 (e.g., VND, SGD) | Đơn vị tiền tệ |
| `range_min` | Decimal | Yes | > 0; must be < range_mid | Tối thiểu |
| `range_mid` | Decimal | Yes | > range_min; < range_max | Midpoint |
| `range_max` | Decimal | Yes | > range_mid | Tối đa |
| `frequency` | Enum | Yes | MONTHLY / ANNUAL — must match typical SalaryBasis for this LE | Tần suất |
| `effective_from` | Date | Yes | Cannot conflict with existing range for same grade+LE | Hiệu lực từ |
| `effective_to` | Date | Auto | Set by system when next version is created (= next effective_from - 1 day) | Hiệu lực đến |
| `is_current` | Boolean | Auto | True for the latest version | Hiện hành |
| `created_by` | FK | Auto | Current user | - |
| `created_at` | Timestamp | Auto | System | - |
| `notes` | Text | No | Max 500 chars — reason for change | Ghi chú |

---

## Operations

### Create (New Version — SCD Type 2)

1. Actor: Compensation Administrator, HR Administrator
2. Navigate to Pay Ranges grid
3. Select Grade row → click "Add New Period"
4. Enter: range_min, range_mid, range_max, effective_from, notes
5. System validates:
   - range_min < range_mid < range_max
   - effective_from does not overlap with any existing open period for same grade+LE
   - range_min >= min wage for the zone (advisory warning, not block)
6. On save:
   - Previous current record: `is_current = false`, `effective_to = effective_from - 1`
   - New record: `is_current = true`, `effective_to = NULL`
7. System publishes: `tr.pay-range-changed.v1` event (consumed by BC-10 Audit)

### Read / List

- Grid view: one row per Grade, columns for range_min / range_mid / range_max (current values)
- "View History" button on row → slides in historical timeline view
- Search: by Grade name/code
- Filter: by LegalEntity, currency, effective date range
- Visualisation: horizontal bar showing worker salaries plotted within band (compa-ratio heatmap)
- Export: CSV with all current ranges

### Update

- No in-place update. To change values, create a new version via "Add New Period"
- `notes` field on the existing record can be updated (non-structural change)

### Delete / Archive

- Cannot delete any version that has SalaryRecords referencing the grade in that period (historical integrity)
- Future-dated versions can be cancelled before they become effective

---

## Validation Rules

| Rule | Condition | Error Message |
|------|-----------|--------------|
| Range order | range_min < range_mid < range_max | "Khoảng lương không hợp lệ: min phải < mid < max." |
| No gap | effective_from must not leave a gap after previous record's effective_to | "Ngày hiệu lực tạo ra khoảng trống trong lịch sử khung lương." |
| Currency match | currency_code must match LegalEntity's default currency | "Đơn vị tiền tệ không khớp với pháp nhân." |
| Overlap | Two records for same grade+LE cannot have overlapping effective periods | "Đã tồn tại khung lương hiệu lực trong khoảng thời gian này." |

---

## Notifications

None — configuration record. Changes captured in Audit Trail.

Advisory alert: If new range_min < current min wage for the zone, system shows: "Cảnh báo: Mức lương tối thiểu của khung lương thấp hơn lương tối thiểu vùng [Zone, Amount]." (Non-blocking.)

---

## Related Features

- COMP-T-001 Merit Review — shows pay range band visualization in proposal form
- COMP-T-002 Salary Change Activation — validates against current pay range
- OFFR-T-001 Offer Creation — shows pay range band for grade + warns if outside range
- COMP-A-001 Compensation Analytics — compa-ratio calculations use pay ranges

---

*COMP-M-003 Spec — Total Rewards / xTalent HCM*
*2026-03-26*
