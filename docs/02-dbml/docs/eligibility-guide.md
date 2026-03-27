# Eligibility Engine – Giới thiệu & Giải pháp mô hình hoá

> Ngày tạo: 2026-03-26  
> Phạm vi: Core V4, TotalReward V5, Payroll V3, TA v5.1  
> Schema chủ: `eligibility.*` (trong `1.Core.V4.dbml`)

---

## 1. Vấn đề cần giải quyết

Trong một hệ thống HCM enterprise, câu hỏi **"Nhân viên X có được hưởng quyền lợi Y không?"** xuất hiện ở mọi module:

| Module | Ví dụ câu hỏi |
|--------|---------------|
| **Absence (TA)** | NV có đủ điều kiện nghỉ phép Maternity không? |
| **Benefits (TR)** | NV có hội đủ tiêu chí tham gia gói bảo hiểm Premium? |
| **Compensation (TR)** | NV có nằm trong đợt review lương Merit 2026? |
| **Payroll (PR)** | NV có đủ điều kiện nhận phụ cấp độc hại không? |

### Bài toán trước khi centralize

Mỗi module tự triển khai eligibility riêng:

```
Absence  → eligibility_json (inline JSON trên leave_class)
Benefits → benefit.eligibility_profile + benefit.plan_eligibility (bảng riêng)
Comp     → comp_plan.eligibility_rule (inline JSON)
Payroll  → Không có eligibility concept
```

**Hệ quả:**
- ❌ Logic đánh giá trùng lặp, không nhất quán
- ❌ Không thể query ngược: "NV X được hưởng gì?"
- ❌ Thay đổi tiêu chí phải sửa ở nhiều nơi
- ❌ Không có audit trail thống nhất

---

## 2. Giải pháp: Centralized Eligibility Engine

### 2.1 Kiến trúc tổng quan

```
┌─────────────────────────────────────────────────────────┐
│                  eligibility schema (Core)               │
│                                                         │
│  ┌─────────────────────┐    ┌────────────────────────┐  │
│  │ eligibility_profile │───▶│  eligibility_member    │  │
│  │ (WHO is eligible)   │    │  (cached membership)   │  │
│  └─────────┬───────────┘    └────────────────────────┘  │
│            │                                            │
│            ▼                                            │
│  ┌──────────────────────┐                               │
│  │ eligibility_evaluation│  (immutable audit log)       │
│  └──────────────────────┘                               │
└─────────────────────────────────────────────────────────┘
         │                    │                  │
    ┌────┴────┐         ┌────┴────┐        ┌────┴────┐
    │   TA    │         │   TR    │        │   PR    │
    │ Absence │         │Benefits │        │Payroll  │
    │ Leave   │         │Comp Plan│        │Pay Elem │
    │ Policy  │         │Bonus    │        └─────────┘
    └─────────┘         └─────────┘
```

**Nguyên tắc thiết kế:**

1. **Profile defines WHO** — tập trung mô tả "ai đủ điều kiện" (organizational scope)
2. **Consuming entity defines WHAT** — module downstream xác định "quyền lợi nào" (object scope)
3. **Member caches result** — kết quả đánh giá được cache cho O(1) lookup
4. **Evaluation logs everything** — mọi đánh giá đều ghi immutable audit

### 2.2 Core Tables

#### `eligibility.eligibility_profile`

| Field | Type | Mô tả |
|-------|------|--------|
| `id` | uuid (PK) | ID profile |
| `code` | varchar(50) UNIQUE | Mã profile (VD: `ELIG_SENIOR_STAFF`) |
| `name` | varchar(255) | Tên hiển thị |
| `domain` | varchar(50) | Phân loại: `ABSENCE`, `BENEFITS`, `COMPENSATION`, `CORE` |
| `rule_json` | jsonb | Tiêu chí đánh giá (organizational scope) |
| `priority` | int | Thứ tự ưu tiên khi evaluate |
| `is_active` | boolean | Trạng thái kích hoạt |
| SCD-2 fields | | `effective_start_date`, `effective_end_date`, `is_current_flag` |

**Ví dụ `rule_json`:**

```json
{
  "grades": ["G4", "G5", "G6"],
  "countries": ["VN"],
  "min_tenure_months": 12,
  "employee_types": ["FULLTIME"],
  "business_units": ["BU_TECH", "BU_OPS"]
}
```

#### `eligibility.eligibility_member`

| Field | Type | Mô tả |
|-------|------|--------|
| `profile_id` | uuid (FK → profile) | Profile mà NV thuộc về |
| `employee_id` | uuid (FK → employee) | NV được đánh giá |
| `start_date` | date | Ngày bắt đầu đủ điều kiện |
| `end_date` | date (null) | `NULL` = đang eligible |
| `evaluation_source` | varchar(50) | `AUTO`, `MANUAL`, `OVERRIDE` |
| `evaluation_reason` | text | Lý do thêm/xoá |

> **Design Pattern:** Member table hoạt động như **materialized view** — được cập nhật tự động khi employee data hoặc profile rules thay đổi. Cho phép query O(1) thay vì evaluate rule_json mỗi lần.

#### `eligibility.eligibility_evaluation`

Immutable audit log ghi lại mọi evaluation:

| Field | Type | Mô tả |
|-------|------|--------|
| `evaluation_result` | varchar(20) | `ELIGIBLE` hoặc `NOT_ELIGIBLE` |
| `evaluation_reason` | text | Chi tiết criteria nào match/fail |
| `triggered_by` | varchar(50) | `EMPLOYEE_CHANGE`, `RULE_CHANGE`, `MANUAL`, `SCHEDULED` |

---

## 3. Tích hợp Cross-Module

### 3.1 Time & Absence (TA)

Module TA sử dụng hybrid model: **Default + Override** trên 3 cấp.

| Entity | Field | Pattern |
|--------|-------|---------|
| `absence.leave_type` | `default_eligibility_profile_id` | Default cho toàn bộ leave type |
| `absence.leave_class` | `default_eligibility_profile_id` | Override ở cấp class (cụ thể hơn type) |
| `absence.leave_policy` | `default_eligibility_profile_id` | Override ở cấp policy (cụ thể nhất) |

**Ưu tiên override:** Policy > Class > Type (most specific wins)

```
leave_type: "ANNUAL_LEAVE"
  └─ default_eligibility_profile_id: ELIG_ALL_FULLTIME
       └─ leave_class: "AL_VN_SENIOR"
            └─ default_eligibility_profile_id: ELIG_SENIOR_STAFF  ← override
                 └─ leave_policy: "AL_VN_G5_PLUS"
                      └─ default_eligibility_profile_id: ELIG_G5_PLUS  ← override cụ thể nhất
```

> [!NOTE]
> `eligibility_json` trên `leave_class` đã DEPRECATED — giữ lại để backward compatibility nhưng các implementation mới phải dùng centralized eligibility.

### 3.2 Total Rewards (TR)

TR module đã migration hoàn tất 3 consumer chính:

| Entity | Old | New |
|--------|-----|-----|
| `comp_core.comp_plan` | `eligibility_rule` (jsonb) → DEPRECATED | `eligibility_profile_id` (uuid FK) |
| `comp_incentive.bonus_plan` | `eligibility_rule` (jsonb) → DEPRECATED | `eligibility_profile_id` (uuid FK) |
| `benefit.benefit_plan` | `eligibility_rule_json` (jsonb) → DEPRECATED | `eligibility_profile_id` (uuid FK) |

**Deprecated nhưng chưa xoá:**
- `benefit.eligibility_profile` — bảng eligibility riêng cũ
- `benefit.plan_eligibility` — bridge table cũ

Hai bảng này được giữ lại cho migration period. Mọi implementation mới phải dùng centralized.

**Aggregation table mới:** `total_rewards.employee_reward_summary`
- Materialized summary: "NV X có những reward gì?"
- Mỗi dòng ghi nhận 1 reward (LEAVE, BENEFIT, COMP_PLAN, BONUS, PAYROLL_ELEMENT, PERK)
- Liên kết `eligibility_profile_id` để track profile nào cấp reward

### 3.3 Payroll (PR)

| Entity | Field | Mô tả |
|--------|-------|--------|
| `pay_master.pay_element` | `eligibility_profile_id` | Element chỉ áp dụng cho NV eligible |

**Use case:** Phụ cấp độc hại chỉ cho NV làm việc ở nhà máy, OT allowance chỉ cho NV fulltime, v.v.

---

## 4. Kết quả rà soát & Findings

### 4.1 Những gì đã ổn ✅

| # | Nội dung | Trạng thái |
|---|----------|-----------|
| 1 | Core centralized schema (3 bảng) đầy đủ và consistent | ✅ |
| 2 | TA 3-level hierarchy (type → class → policy) với override cascade | ✅ |
| 3 | TR đã migrate cả comp_plan, bonus_plan, benefit_plan sang FK | ✅ |
| 4 | PR đã thêm eligibility vào pay_element | ✅ |
| 5 | Audit trail đầy đủ qua `eligibility_evaluation` | ✅ |
| 6 | Total rewards aggregation qua `employee_reward_summary` | ✅ |

### 4.2 Findings đã fix ✅ (26Mar2026)

| # | Finding | Module | Fix |
|---|---------|--------|-----|
| **F1** | Schema name mismatch: TA tham chiếu `core.eligibility_profile.id` thay vì `eligibility.eligibility_profile.id` | TA | ✅ Sửa 3 FKs (`leave_type`, `leave_class`, `leave_policy`) |
| **F2** | `eligibility_profile_id` thiếu `ref:` syntax trong DBML | PR, TR | ✅ Thêm explicit `ref:` cho 4 fields (`pay_element`, `comp_plan`, `bonus_plan`, `benefit_plan`) |
| **F3** | Deprecated tables chưa có migration timeline | TR | ✅ Thêm timeline: "Remove in v6.0, target Q3 2026" cho `benefit.eligibility_profile` + `plan_eligibility` |
| **F4** | `eligibility_profile.domain` thiếu `PAYROLL` | Core | ✅ Mở rộng domain enum: `ABSENCE \| BENEFITS \| COMPENSATION \| PAYROLL \| CORE` |

> Chi tiết fix: xem [CHANGELOG.md](./CHANGELOG.md) entry `[26Mar2026-b]`

---

## 5. Luồng hoạt động (Operational Flow)

### 5.1 Tạo mới Eligibility Profile

```
1. Admin tạo eligibility_profile:
   - code: ELIG_VN_FULLTIME_G4
   - domain: COMPENSATION
   - rule_json: { "countries": ["VN"], "employee_types": ["FULLTIME"], "grades": ["G4","G5","G6"] }

2. System chạy batch evaluation:
   - Query tất cả employee active
   - Evaluate rule_json cho từng employee
   - INSERT/UPDATE eligibility_member

3. Admin gán profile vào consumer:
   - comp_plan.eligibility_profile_id = <profile_id>
   - Hoặc: leave_type.default_eligibility_profile_id = <profile_id>
```

### 5.2 Khi Employee data thay đổi

```
1. Employee thay đổi: thăng grade G3 → G4
2. Event trigger: EMPLOYEE_CHANGE
3. System re-evaluate tất cả profile liên quan
4. eligibility_member updated (thêm membership mới nếu eligible)
5. eligibility_evaluation logged (audit trail)
6. Downstream modules nhận được membership mới:
   - TA: NV mới eligible leave policy "G4+ Annual Leave"
   - TR: NV mới eligible comp_plan "Merit 2026 G4+"
   - PR: NV mới eligible pay element "Responsibility Allowance"
```

### 5.3 Query "NV X được hưởng gì?"

```sql
-- Tất cả profile mà NV eligible
SELECT ep.code, ep.name, ep.domain
FROM eligibility.eligibility_member em
JOIN eligibility.eligibility_profile ep ON ep.id = em.profile_id
WHERE em.employee_id = :emp_id
  AND em.end_date IS NULL;

-- Tất cả reward (aggregated view)
SELECT reward_type, reward_entity_code, reward_entity_name, status
FROM total_rewards.employee_reward_summary
WHERE employee_id = :emp_id
  AND status = 'ACTIVE';
```

---

## 6. So sánh với Industry Standards

| Tiêu chí | Oracle HCM | Workday | xTalent |
|-----------|-----------|---------|---------|
| Centralized eligibility | ✅ Eligibility Profile | ✅ Eligibility Rule | ✅ eligibility_profile |
| Cross-module reuse | ✅ | ✅ | ✅ |
| Cached membership | ❌ (evaluate on-demand) | ✅ (derived) | ✅ eligibility_member |
| Audit trail | ✅ | ✅ | ✅ eligibility_evaluation |
| Rule-based criteria | ✅ (HCM Criteria) | ✅ (Condition Rules) | ✅ rule_json (flexible) |
| Override hierarchy | ✅ (Plan → Program) | ✅ (Plan → Template) | ✅ (Type → Class → Policy) |
| Aggregation view | ⚠️ Composite API | ✅ Total Rewards | ✅ employee_reward_summary |

**Điểm mạnh xTalent:**
- `rule_json` flexible hơn hard-coded criteria (không cần migrate schema khi thêm tiêu chí mới)
- `eligibility_member` cache cho O(1) lookup (performance tốt hơn evaluate-on-demand)
- 3-layer hierarchy trong TA (Type → Class → Policy) linh hoạt hơn Oracle 2-layer

---

## 7. Tóm tắt

```
eligibility_profile  ──defines──▶  WHO is eligible (rule_json)
         │                              
         ├──cached in──▶  eligibility_member (O(1) lookup)
         │
         ├──audited by──▶  eligibility_evaluation (immutable log)
         │
         └──consumed by──▶  TA: leave_type/class/policy
                            TR: comp_plan, bonus_plan, benefit_plan
                            PR: pay_element
                            Aggregation: employee_reward_summary
```

| Trạng thái | Kết luận |
|-----------|---------|
| **Thiết kế tổng thể** | ✅ Solid — centralized model đúng pattern industry |
| **Tích hợp TA** | ✅ Tốt — 3-level override cascade hợp lý |
| **Tích hợp TR** | ✅ Tốt — migration hoàn tất, deprecated tables có kế hoạch |
| **Tích hợp PR** | ✅ Tốt — pay_element đã có eligibility_profile_id |
| **Notation issues** | ⚠️ Minor — schema name mismatch (F1), missing ref syntax (F2) |
| **Cần bổ sung** | ⚠️ Domain enum cho PAYROLL (F4), migration timeline cho deprecated tables (F3) |

---

*Tài liệu này là companion guide cho `review-01-dbml-cross-module-analysis.md`. Xem thêm CHANGELOG.md cho lịch sử thay đổi DBML.*
