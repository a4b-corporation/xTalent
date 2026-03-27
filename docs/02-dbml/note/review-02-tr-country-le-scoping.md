# Review #02 – Total Rewards: Country & Legal Entity Configuration Scoping

> Ngày: 26Mar2026  
> Phạm vi: TR V5, PR V3, CO V4  
> Câu hỏi: Các component TR có thể config độc lập theo country/LE không? So sánh với industry leaders?

---

## 1. Hiện trạng: Ma trận Country/LE Scoping

### 1.1 Definition Layer (cấu hình gốc – master data)

| Table | Country | Legal Entity | Nhận xét |
|-------|---------|-------------|----------|
| `comp_core.salary_basis` | ❌ | ❌ | **Global singleton** — không phân biệt quốc gia |
| `comp_core.pay_component_def` | ❌ | ❌ | **Global singleton** — dùng chung mọi LE |
| `comp_core.comp_plan` | ❌ | ❌ | **Global singleton** — eligibility bù đắp 1 phần |
| `comp_incentive.bonus_plan` | ❌ | ❌ | **Global singleton** |
| `benefit.benefit_plan` | ❌ | ✅ `sponsor_legal_entity_id` | LE-scoped (**tốt**) |
| `pay_master.pay_element` | ❌ | ❌ | **Global singleton** |

### 1.2 Operational Layer (dữ liệu vận hành)

| Table | Country | Legal Entity | Nhận xét |
|-------|---------|-------------|----------|
| `comp_core.pay_range` | ❌ | ✅ `scope_type` (GLOBAL\|LE\|BU\|POSITION) | **Dynamic scope — tốt** |
| `comp_core.budget_allocation` | ❌ | ✅ `scope_type` (LE\|BU\|DEPT\|TEAM) | **Dynamic scope — tốt** |
| `comp_incentive.bonus_pool` | ❌ | ✅ `legal_entity_id` FK | **LE-scoped — tốt** |
| `pay_master.pay_calendar` | ❌ | ✅ `legal_entity_id` FK | **LE-scoped — tốt** |
| `pay_master.pay_group` | ❌ | ✅ `legal_entity_id` FK | **LE-scoped — tốt** |

### 1.3 Reference/Rules Layer

| Table | Country | Legal Entity | Nhận xét |
|-------|---------|-------------|----------|
| `comp_core.country_config` | ✅ `country_code` PK | — | **Country reference — tốt** |
| `comp_core.calculation_rule_def` | ✅ `country_code` + `jurisdiction` | ❌ | **Country-scoped calc rules — tốt** |
| `comp_core.holiday_calendar` | ✅ `country_code` + `jurisdiction` | ❌ | **Country-scoped — tốt** |

### 1.4 Tóm tắt

```
┌─────────────────────────────────────────────────────────────┐
│  REFERENCE LAYER          ✅ Country scoping tốt            │
│  (country_config, calc_rule_def, holiday_calendar)          │
├─────────────────────────────────────────────────────────────┤
│  OPERATIONAL LAYER        ✅ LE scoping tốt                 │
│  (pay_range, budget, bonus_pool, pay_calendar/group)        │
├─────────────────────────────────────────────────────────────┤
│  DEFINITION LAYER         ❌ GAP: Global singletons          │
│  (salary_basis, pay_component_def, comp_plan, bonus_plan,   │
│   pay_element)                                              │
└─────────────────────────────────────────────────────────────┘
```

> **Kết luận:** Operational layer và Reference layer đã xử lý country/LE tốt. **Vấn đề nằm ở Definition layer — các bảng master config là global singleton**, không thể config độc lập theo country hoặc LE.

---

## 2. Vấn đề thực tế khi multi-country

### Scenario: Công ty có LE Việt Nam + LE Singapore

**Salary Basis:**
- VN cần: LUONG_CO_BAN (monthly, VND), LUONG_THEO_SP (per_unit)
- SG cần: BASIC_SALARY (monthly, SGD)
- Hiện tại: cả 2 cùng nằm trong `salary_basis` ✅ nhưng **không phân biệt country** → UI phải hiển thị tất cả; admin SG sẽ thấy cả salary basis VN

**Pay Component:**
- VN: PHỤ CẤP ĐỘC HẠI, PHỤ CẤP ĂN CA (tax exempt ≤730K VND)
- SG: CPF_EMPLOYER, CPF_EMPLOYEE, SDL
- Hiện tại: tất cả cùng table, **không filter được theo country** trong app

**Comp Plan:**
- VN: Merit Review 2026 (budget VND, Vietnam employees only)
- SG: Merit Review 2026 (budget SGD, Singapore employees only)  
- Hiện tại: phải tạo 2 comp_plan riêng, dùng `eligibility_profile` để filter → **workaround hoạt động** nhưng không có country field trên plan bản thân

---

## 3. So sánh với Industry Leaders

| Tiêu chí | Oracle HCM | SAP SuccessFactors | Workday | **xTalent** |
|----------|-----------|-------------------|---------|-------------|
| **Scope abstraction** | Legislative Data Group (LDG) | Country/Region + Legal Entity | Company (≈LE) | ❌ Không có |
| **Element scoping** | ✅ Element → LDG (mandatory) | ✅ Pay component group per country | ✅ Earning code per Company | ❌ Global singleton |
| **Plan scoping** | ✅ Plan → LDG/LE | ✅ Plan → Country/LE | ✅ Plan → Company(s) | ⚠️ Via eligibility only |
| **Calc rules per country** | ✅ Formula per LDG | ✅ Country pack | ✅ Country-specific | ✅ `calc_rule_def` |
| **Pay range per LE** | ✅ Comp survey scope | ✅ Pay structure per LE | ✅ | ✅ `pay_range.scope_type` |
| **Benefits per LE** | ✅ Plan per LE | ✅ Plan per LE | ✅ Plan per Company | ✅ `sponsor_legal_entity_id` |
| **Payroll per LE** | ✅ Payroll per LDG | ✅ Per Legal Entity | ✅ Per Company | ✅ `pay_calendar/group → LE` |

### Ưu nhược điểm

**xTalent hiện tại:**
| | Nội dung |
|---|---------|
| ✅ Ưu | `pay_range.scope_type` dynamic — linh hoạt hơn hard-coded LE approach |
| ✅ Ưu | `calc_rule_def` country-scoped — clean, versioned |
| ✅ Ưu | Eligibility bù đắp phần nào gap ở definition layer |
| ✅ Ưu | Schema đơn giản, deploy nhanh cho single-country |
| ❌ Nhược | Definition tables global → multi-country phải dùng naming convention |
| ❌ Nhược | Không enforce country/LE separation ở DB level → risk data leak giữa countries |
| ❌ Nhược | Admin UI phải filter thủ công, không có built-in country isolation |

**Oracle HCM:** Rất chặt chẽ (LDG enforce phân tách), nhưng phức tạp khi share element cross-country  
**Workday:** Cân bằng — Company-level scope + chia sẻ plan qua assignment, nhưng phức tạp governance  
**SAP SF:** Rất mạnh multi-country (country pack), nhưng heavy và cần nhiều config

---

## 4. Đề xuất cải tiến

### Option 1: Light Touch — Thêm optional scope fields (⭐ Khuyến nghị)

Thêm `country_code char(2) [null]` và/hoặc `legal_entity_id uuid [null]` vào definition tables:

```diff
 Table comp_core.salary_basis {
   id              uuid [pk]
   code            varchar(50) [unique]
   name            varchar(200)
+  country_code    char(2) [null]           // NULL = global, VN/SG = country-specific
+  legal_entity_id uuid [null]              // NULL = all LE, populated = LE-specific
   frequency       varchar(20)
   ...
 }
```

Áp dụng cho: `salary_basis`, `pay_component_def`, `comp_plan`, `bonus_plan`, `pay_element`

| Ưu | Nhược |
|-----|-------|
| Backward compatible (NULL = current behavior) | Cần update unique constraints (code → code + country_code) |
| Nhất quán với `calc_rule_def` pattern | Thêm filter logic ở application layer |
| Đơn giản, triển khai nhanh | |

### Option 2: Config Scope Group (Alternative)

Tạo abstraction layer `comp_core.config_scope`:

```
comp_core.config_scope {
  id              uuid [pk]
  scope_code      varchar(50) [unique]     // VN_DEFAULT, SG_DEFAULT, GLOBAL
  country_code    char(2) [null]
  legal_entity_id uuid [null]
  business_unit_id uuid [null]
  priority        int [default: 0]         // higher = more specific
}
```

Sau đó dùng `scope_id` FK trên các definition tables. Tương tự Oracle's LDG nhưng nhẹ hơn.

| Ưu | Nhược |
|-----|-------|
| 1 indirection layer, dễ quản lý scope hierarchy | Thêm join, phức tạp hơn Option 1 |
| Support multi-level scope (country → LE → BU) | Over-engineering cho phase hiện tại |

### Option 3: Status Quo + Governance (Không thay đổi schema)

Giữ nguyên, dùng:
- Naming convention: `VN_LUONG_CO_BAN`, `SG_BASIC_SALARY`
- Eligibility profile: filter country/LE trong `rule_json`
- Application layer: enforce visibility per country/LE

| Ưu | Nhược |
|-----|-------|
| Zero migration effort | Không enforce ở DB level |
| Hoạt động cho 1-2 countries | Không scale khi mở rộng 5+ countries |

---

## 5. Khuyến nghị

> [!IMPORTANT]
> **Khuyến nghị: Option 1 (Light Touch)** — thêm `country_code` + `legal_entity_id` optional vào 5 definition tables.

**Lý do:**
1. Nhất quán với `calc_rule_def` đã có `country_code`
2. Nhất quán với `pay_range.scope_type` dynamic scoping pattern
3. Backward compatible (NULL = global = hiện trạng)
4. Công việc cần làm nhỏ (thêm 2 columns + update unique constraint)
5. Chuẩn bị cho multi-country mà không over-engineering

**Bảng cần thay đổi:**

| Table | Thêm `country_code` | Thêm `legal_entity_id` | Unique constraint update |
|-------|---------------------|----------------------|--------------------------|
| `comp_core.salary_basis` | ✅ | ✅ nullable | `(code, country_code)` |
| `comp_core.pay_component_def` | ✅ | ❌ (country đủ) | `(code, country_code)` |
| `comp_core.comp_plan` | ✅ | ✅ nullable | `(code, country_code)` |
| `comp_incentive.bonus_plan` | ✅ | ✅ nullable | `(code, country_code)` |
| `pay_master.pay_element` | ✅ | ❌ (inherit via pay_group) | `(code, country_code)` |

---

*Đề xuất này cần user approval trước khi thực hiện. Nếu đồng ý, sẽ update DBML + CHANGELOG + review-01.*
