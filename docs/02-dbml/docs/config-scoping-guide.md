# Configuration Scoping Guide – Multi-Country/Legal Entity

> Ngày: 26Mar2026  
> Áp dụng: TR V5, PR V3  
> Changelog: [CHANGELOG.md](./CHANGELOG.md) entry `[26Mar2026-c]`

---

## 1. Tổng quan

xTalent hỗ trợ **2 phương án config scoping** cho multi-country/multi-LE deployment, **có thể áp dụng độc lập hoặc kết hợp**:

| Phase | Phương án | Khi nào dùng | Độ phức tạp |
|-------|-----------|-------------|-------------|
| **Phase 1** | Light Touch — inline `country_code` + `legal_entity_id` | 1-3 countries, setup nhanh | Thấp |
| **Phase 2** | Config Scope Group — `config_scope_id` FK | 5+ countries, scope hierarchy phức tạp | Trung bình |

```
┌──────────────────────────────────────────────────────┐
│  Phase 1: Inline Fields (Light Touch)                │
│  ┌──────────────┐  ┌──────────────┐                  │
│  │ salary_basis  │  │ comp_plan    │                  │
│  │ country: VN   │  │ country: SG  │                  │
│  │ le: Entity_A  │  │ le: NULL     │  ← NULL = all   │
│  └──────────────┘  └──────────────┘                  │
├──────────────────────────────────────────────────────┤
│  Phase 2: Config Scope Group (Advanced)              │
│  ┌─────────┐                                         │
│  │ GLOBAL  │ priority=0                              │
│  │  └─ VN  │ priority=10                             │
│  │    └─ VN_ENTITY_A │ priority=20                   │
│  │      └─ VN_TECH   │ priority=30                   │
│  │  └─ SG  │ priority=10                             │
│  │  └─ APAC (HYBRID) │ → members: VN, SG, TH        │
│  └─────────┘                                         │
└──────────────────────────────────────────────────────┘
```

---

## 2. Phase 1: Light Touch (Inline Fields)

### 2.1 Cơ chế

Thêm trực tiếp `country_code` và/hoặc `legal_entity_id` vào definition tables:

```sql
-- VN-specific salary basis
INSERT INTO comp_core.salary_basis (code, name, country_code, legal_entity_id, ...)
VALUES ('VN_LUONG_CO_BAN', 'Lương cơ bản', 'VN', NULL, ...);

-- SG-specific salary basis
INSERT INTO comp_core.salary_basis (code, name, country_code, legal_entity_id, ...)
VALUES ('SG_BASIC', 'Basic Salary', 'SG', NULL, ...);

-- Global salary basis (all countries)
INSERT INTO comp_core.salary_basis (code, name, country_code, legal_entity_id, ...)
VALUES ('GLOBAL_BASE', 'Global Base Salary', NULL, NULL, ...);
```

### 2.2 Quy tắc

| Giá trị | Ý nghĩa |
|---------|---------|
| `country_code = NULL, legal_entity_id = NULL` | **Global** — áp dụng tất cả countries/LEs |
| `country_code = 'VN', legal_entity_id = NULL` | **Country-level** — áp dụng tất cả LEs trong VN |
| `country_code = 'VN', legal_entity_id = uuid` | **LE-specific** — chỉ áp dụng cho LE cụ thể ở VN |

### 2.3 Application query pattern

```sql
-- Lấy salary_basis cho employee thuộc VN, Entity_A
SELECT * FROM comp_core.salary_basis
WHERE (country_code = 'VN' OR country_code IS NULL)
  AND (legal_entity_id = :le_id OR legal_entity_id IS NULL)
  AND effective_start <= :date
  AND (effective_end IS NULL OR effective_end >= :date)
ORDER BY 
  CASE WHEN legal_entity_id IS NOT NULL THEN 2
       WHEN country_code IS NOT NULL THEN 1
       ELSE 0 END DESC;  -- most specific first
```

### 2.4 Các bảng áp dụng

| Table | `country_code` | `legal_entity_id` | Lý do LE |
|-------|:-:|:-:|----------|
| `comp_core.salary_basis` | ✅ | ✅ | Salary basis có thể khác nhau giữa LEs trong cùng country |
| `comp_core.pay_component_def` | ✅ | — | Component level = country (VN allowances ≠ SG), LE-specifics qua salary_basis |
| `comp_core.comp_plan` | ✅ | ✅ | Plan có thể scoped theo LE (budget, org khác nhau) |
| `comp_incentive.bonus_plan` | ✅ | ✅ | Bonus scoped theo LE (budget allocation per LE đã có) |
| `pay_master.pay_element` | ✅ | — | Element level = country, LE-specifics qua pay_group |

---

## 3. Phase 2: Config Scope Group (Advanced)

### 3.1 Cơ chế

Tạo **named scope** trong `comp_core.config_scope`, sau đó tham chiếu từ definition tables qua `config_scope_id`:

```sql
-- Tạo scope hierarchy
INSERT INTO comp_core.config_scope (scope_code, scope_name, scope_type, country_code, priority)
VALUES ('GLOBAL', 'Global Scope', 'COUNTRY', NULL, 0);

INSERT INTO comp_core.config_scope (scope_code, scope_name, scope_type, country_code, priority, parent_scope_id)
VALUES ('VN_DEFAULT', 'Vietnam Default', 'COUNTRY', 'VN', 10, :global_id);

INSERT INTO comp_core.config_scope (scope_code, scope_name, scope_type, country_code, legal_entity_id, priority, parent_scope_id)
VALUES ('VN_ENTITY_A', 'VN - Entity A', 'LEGAL_ENTITY', 'VN', :le_a_id, 20, :vn_id);

-- Assign scope to salary basis
UPDATE comp_core.salary_basis 
SET config_scope_id = :vn_entity_a_id
WHERE code = 'VN_LUONG_CO_BAN';
```

### 3.2 Scope Hierarchy & Inheritance

```
GLOBAL (priority=0, inherit=true)
 ├── VN_DEFAULT (priority=10, country_code='VN')
 │    ├── VN_ENTITY_A (priority=20, legal_entity_id=xxx)
 │    │    └── VN_TECH_BU (priority=30, business_unit_id=yyy)
 │    └── VN_ENTITY_B (priority=20, legal_entity_id=zzz)
 ├── SG_DEFAULT (priority=10, country_code='SG')
 └── APAC_REGION (scope_type='HYBRID')
      └── config_scope_member: VN, SG, TH, MY
```

- **`priority`**: Giá trị cao hơn = cụ thể hơn. Resolution: max priority wins.
- **`inherit_flag`**: `true` = kế thừa config từ parent scope nếu bản thân không có.
- **`parent_scope_id`**: Chain for scope traversal (BU → LE → Country → Global).

### 3.3 HYBRID scopes

Dùng `config_scope_member` cho scopes spans nhiều countries/LEs:

```sql
-- APAC region scope
INSERT INTO comp_core.config_scope (scope_code, scope_name, scope_type, priority)
VALUES ('APAC_REGION', 'APAC Region', 'HYBRID', 5);

-- Add members
INSERT INTO comp_core.config_scope_member (scope_id, member_type, country_code)
VALUES (:apac_id, 'COUNTRY', 'VN'),
       (:apac_id, 'COUNTRY', 'SG'),
       (:apac_id, 'COUNTRY', 'TH'),
       (:apac_id, 'COUNTRY', 'MY');
```

### 3.4 Resolution Order

Khi cả 2 options đều có giá trị trên 1 record:

```
1. config_scope_id (nếu populated) → dùng scope group resolution
2. Inline country_code + legal_entity_id (nếu populated) → dùng inline filter
3. Cả 2 NULL → global (áp dụng everywhere)
```

> **Rule**: `config_scope_id` takes precedence over inline fields.

---

## 4. Lộ trình áp dụng

### Giai đoạn 1 — Single Country (hiện tại)

```
✅ Dùng: Phase 1 (inline fields)
⬜ Bỏ qua: Phase 2 (config_scope)

Cách làm:
- Tất cả definition tables có country_code = NULL (global behavior, giữ nguyên hiện trạng)
- config_scope_id = NULL trên tất cả records
- Zero migration effort
```

### Giai đoạn 2 — Multi-Country (2-3 countries)

```
✅ Dùng: Phase 1 (inline fields)
⬜ Tuỳ chọn: Phase 2 (config_scope)

Cách làm:
- Populate country_code cho từng definition record
- legal_entity_id cho records cần LE-specific (nếu có)
- Application layer filter theo country_code + legal_entity_id
- Config Scope có thể setup nhưng chưa bắt buộc
```

### Giai đoạn 3 — Enterprise Multi-Country (5+ countries)

```
✅ Dùng: Phase 1 + Phase 2

Cách làm:
- Setup config_scope hierarchy (Global → Country → LE → BU)
- Migrate definition records: set config_scope_id
- HYBRID scopes cho regional groupings (APAC, EMEA...)
- Application layer dùng scope resolution cho filtering + inheritance
```

### Giai đoạn 4 — Multi-Tenant SaaS (mỗi client = config riêng)

```
✅ Dùng: Phase 2 (primary mechanism)

Cách làm:
- Mỗi client có 1 top-level config_scope
- Client-specific scopes kế thừa từ global defaults
- Inline fields vẫn hoạt động như fallback
```

---

## 5. So sánh với Industry Standards

| Tiêu chí | Oracle HCM (LDG) | SAP SF | Workday | **xTalent (Phase 1+2)** |
|----------|:-:|:-:|:-:|:-:|
| **Scope abstraction** | Legislative Data Group | Country Pack | Company | Config Scope Group |
| **Inline scoping** | ❌ (phải qua LDG) | ❌ | ❌ | ✅ (Phase 1) |
| **Advanced hierarchy** | ✅ | ✅ | ✅ | ✅ (Phase 2) |
| **Phased adoption** | ❌ (all-or-nothing) | ❌ | ❌ | ✅ (unique advantage) |
| **Multi-tenant ready** | ✅ | ✅ | ✅ | ✅ (Phase 2) |
| **Hybrid/regional scope** | ❌ | ⚠️ Limited | ❌ | ✅ (scope_member) |
| **Setup complexity** | Cao | Rất cao | Trung bình | **Thấp → Trung bình** |

### Ưu điểm xTalent

1. **Phased adoption**: Team chỉ adopt Phase 1 khi bắt đầu, nâng lên Phase 2 khi cần — không bắt buộc big-bang setup như Oracle/SAP
2. **Backward compatible**: NULL = global = hiện trạng. Zero breaking change.
3. **Dual mechanism**: Inline fields (đơn giản, dễ query) + Scope Group (mạnh, hỗ trợ hierarchy) — không phải either/or
4. **HYBRID scopes**: Hỗ trợ regional grouping mà Oracle/Workday không có sẵn

### Lưu ý

1. **Governance**: Cần convention rõ ràng để team biết khi nào dùng inline vs config_scope
2. **Unique constraints**: `code` đã là unique — khi multi-country cần naming convention (`VN_`, `SG_`) hoặc relaxed unique constraint `(code, country_code)`
3. **Application layer**: Cần implement scope resolution logic (query patterns ở section 2.3)

---

*Guide này là tài liệu sống. Cập nhật khi có thay đổi scope hoặc khi thêm module mới.*
