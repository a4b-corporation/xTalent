# CALC-M-001 — Contribution Config Management (SI/CPF/BPJS Rates)

**Type**: Masterdata | **Priority**: P0 | **BC**: BC-02 Calculation Engine
**Country**: [Country-specific per engine — VN Phase 1, others Phase 2]

---

## Purpose

Contribution Config stores country-specific social insurance contribution rates — BHXH/BHYT/BHTN (Vietnam), CPF (Singapore), EPF (Malaysia), BPJS (Indonesia), SSS/PhilHealth/Pag-IBIG (Philippines). HR Admin and Tax Admin configure employer and employee rates, calculation basis, and cap rules per LegalEntity. Changes create a new effective-dated version (SCD Type 2) so historical calculations remain accurate.

**Platform principle**: Rates are DATA configured by HR SME — no code deployment needed to change them.

---

## Fields

| Field | Type | Required | Validation | Label (VI) |
|-------|------|---------|-----------|-----------|
| `id` | UUID | Auto | Generated | - |
| `country_code` | Enum | Yes | Supported: VN, SG, MY, ID, PH, TH | Quốc gia |
| `legal_entity_id` | FK | No | NULL = applies to all LEs in country | Pháp nhân |
| `contribution_type` | Enum | Yes | BHXH / BHYT / BHTN / CPF / EPF / BPJS_TK / BPJS_KES / SSS / PHILHEALTH / PAGIBIG | Loại bảo hiểm |
| `employer_rate` | Decimal(6,4) | Yes | 0 ≤ rate ≤ 1; e.g., 0.175 = 17.5% | Tỷ lệ NLĐ đóng |
| `employee_rate` | Decimal(6,4) | Yes | 0 ≤ rate ≤ 1; e.g., 0.08 = 8% | Tỷ lệ NTD đóng |
| `calculation_basis` | Enum | Yes | GROSS_SALARY / INSURABLE_SALARY / BASIC_SALARY | Căn cứ tính |
| `cap_multiplier` | Decimal(6,2) | No | VN: 20 (= 20× min wage). NULL = no cap | Hệ số trần (× lương tối thiểu) |
| `regulatory_ref` | String(500) | No | e.g., "Nghị định 135/2020/NĐ-CP" | Căn cứ pháp lý |
| `effective_start_date` | Date | Yes | Cannot overlap with existing active version for same type/LE | Ngày hiệu lực |
| `effective_end_date` | Date | Auto | Set by system when new version created | Ngày hết hiệu lực |
| `is_current` | Boolean | Auto | true for latest version | Hiện hành |
| `notes` | Text | No | Internal notes | Ghi chú |

---

## Operations

### Create (New Rate Version)
1. Actor: Tax Admin, HR Admin
2. Select country + contribution type + optional LegalEntity scope
3. Enter rates, calculation basis, cap multiplier
4. Set effective_start_date (must be future date or start of next payroll period)
5. System: checks no overlapping version exists for same (country, type, LE, period)
6. On save: new ContributionConfig record inserted; previous version closed (effective_end_date = new start - 1)
7. Confirmation: "New BHXH rates effective 2026-07-01 saved. Previous rates closed."

**Cannot edit existing version** — "Rate Change" always creates a new version (SCD Type 2 rule).

### Read / List
- Filter by: country, contribution_type, legal_entity, is_current
- Show history: toggle to see all versions with effective periods
- Default: show only `is_current = true`

### Archive (Soft)
- Rate versions are never deleted — they may be closed by creating a new version
- Emergency archive: requires Compensation Admin + Tax Admin dual approval

---

## Validation Rules

| Rule | When | Error |
|------|------|-------|
| employer_rate + employee_rate must both be ≥ 0 | On create | "Rates cannot be negative" |
| effective_start_date must not overlap existing active version | On create | "Active config already exists for this period. Close it first or set a later start date." |
| cap_multiplier required when country = VN and type = BHXH/BHYT/BHTN | On create | "Cap multiplier required for Vietnam SI contributions" |
| regulatory_ref recommended for compliance | On create | Soft warning only |
| Cannot create backdated versions that affect already-processed payroll periods | On create | "Cannot backdate to a period already processed by payroll" |

---

## Vietnam-Specific Config [VN-specific]

Default rates (configurable):

| Type | Employee | Employer |
|------|----------|----------|
| BHXH | 8% | 17.5% |
| BHYT | 1.5% | 3% |
| BHTN | 1% | 1% |

Cap: 20 × MinWage(workplace_zone). Zone determined by `WorkingRelationship.workplace_location`.

---

## Notifications

| Event | Recipients | Channel |
|-------|-----------|---------|
| New config version created | Tax Admin, HR Admin in same LE scope | In-app + Email |
| Config approaching expiry (30 days) | Tax Admin | In-app alert |

---

*CALC-M-001 — Contribution Config Management*
*2026-03-27*
