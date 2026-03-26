# Review #01 – DBML Cross-Module Analysis

> Ngày tạo: 2026-03-25  
> Phạm vi: Core V4, TotalReward V5, Payroll V3, TA v5.1, Absence v4  
> Mục đích: Đánh giá design gaps trước khi consolidate fix

---

## Conflict: `3.Absence.v4.dbml` vs `TA-database-design-v5.dbml`

> [!WARNING]
> File `TA-database-design-v5.dbml` đã merge Absence v4 + thêm centralized eligibility + half-day + approval fields → **bản canonical**. File `3.Absence.v4.dbml` là **legacy reference**.

| Table | v4 standalone | v5.1 merged | Diff |
|-------|------|------|------|
| `leave_type` | Không eligibility | +`default_eligibility_profile_id`, `allows_half_day` | v5.1 rộng hơn |
| `leave_class` | `eligibility_json` trực tiếp | +`default_eligibility_profile_id`, deprecate json | v5.1 centralized |
| `leave_policy` | Có | +`default_eligibility_profile_id` | v5.1 rộng hơn |
| `leave_request` | Gốc | +`total_days`, `is_half_day`, approval fields | v5.1 rộng hơn |
| `leave_wallet` | Có | Omitted (noted "giữ v4") | Cần sync |

---

## Q1: Compensation Basis cover đủ tình huống lương?

### Hiện trạng

```
compensation.basis (header) — link work_relationship_id
├── basis_amount, frequency_code (MONTHLY|HOURLY|ANNUALLY|DAILY)
├── basis_type_code (LEGAL_BASE|OPERATIONAL_BASE|MARKET_ADJUSTED)
├── has_component_lines → tổng phụ cấp
└── SCD Type-2 (previous_basis_id chain)

compensation.basis_line (detail) — phụ cấp cố định
├── component_type_code (MEAL, HOUSING, TRANSPORTATION, SENIORITY...)
├── amount, source_code (FIXED|OVERRIDE)
└── reference_id + reference_type (JOB, POSITION, LOCATION)
```

### Đánh giá

| Tình huống | Cover? | Ghi chú |
|-----------|--------|---------|
| Lương tháng/giờ/ngày | ✅ | `frequency_code` |
| Phụ cấp cố định | ✅ | `basis_line` |
| Phụ cấp theo chức vụ/thâm niên | ✅ | `basis_line` + `reference_type` |
| Phụ cấp từ plan (dynamic) | ⚠️ | Không ở đây — do comp_core plan xử lý |
| **Lương theo sản phẩm (piece-rate)** | ❌ | Thiếu mechanism track output units |
| Lương KPI/performance | ⚠️ | Nằm ở bonus plan, không ở comp basis |
| VN-specific (BHXH, vùng lương) | ✅ | `social_insurance_basis`, `regional_min_wage_zone` |

> [!IMPORTANT]
> **Gap**: Thiếu piece-rate/output-based pay model.

---

## Q2: Worker → Assignment → Compensation Basis → Salary Basis

### Chuỗi quan hệ

```
person.worker ──1:N──> employment.work_relationship (gắn legal_entity_code)
                          └──> employment.employee (sinh emp_code trong cùng LE)
                                 └──1:N──> employment.assignment (position/job trong cùng LE)
```

### 📝 Clarification: Multi-Assignment và Multi-Payroll trong cùng 1 Legal Entity

> User comment: *"mỗi WR gắn 1 legal entity và sinh 1 emp code, nên 1 emp code chỉ assignment trong cùng LE; nhiều bảng lương vẫn sẽ trong cùng 1 LE"*

**Đúng vậy.** Schema hiện tại:
- `work_relationship.legal_entity_code` → xác định LE
- `employee.legal_entity_code` → cùng LE
- Nhiều LE = nhiều WR = nhiều employee record riêng biệt

**Tình huống thực tế multi-assignment trong cùng LE có phát sinh không?**
- **Có nhưng hiếm**: Giảng viên kiêm nhiệm (0.5 FTE giảng dạy + 0.5 FTE nghiên cứu), nhân viên part-time 2 vị trí
- **Phổ biến hơn**: 1 assignment chính + chuyển assignment (SCD-2, kết thúc cũ → mở mới)
- **Multi-payroll trong cùng LE**: Có thể xảy ra khi emp thuộc nhiều pay group khác nhau (ví dụ: lương tháng + project bonus theo cycle khác)

**Kết luận**: Gap `assignment_id` trên `compensation.basis` vẫn nên cân nhắc thêm, nhưng **priority thấp hơn** ban đầu đánh giá. Trường hợp primary là 1 emp = 1 active assignment.

### 📝 Clarification: Chính xác thiếu gì?

> User comment: *"Hiện tại chỉ thiếu link giữa assignment với compensation basis; và sau đó là compensation basis với salary basis?"*

**Correction — link comp basis → salary basis ĐÃ CÓ:**

| Link | Tồn tại? | Field |
|------|---------|-------|
| `compensation.basis` → `employment.work_relationship` | ✅ | `work_relationship_id` (required) |
| `compensation.basis` → `employment.assignment` | ❌ **Thiếu** | Không có `assignment_id` |
| `compensation.basis` → `comp_core.salary_basis` | ✅ **Có** (nullable) | `salary_basis_id` (nullable) |
| `comp_core.employee_comp_snapshot` → `employment.assignment` | ✅ | `assignment_id` |

**Tóm lại chỉ thiếu 1 link chính:**
- ❌ `compensation.basis.assignment_id` → `employment.assignment.id`

Và `salary_basis_id` trên `compensation.basis` đã nullable — chỉ cần đảm bảo business logic enforce populate khi cần.

### Flow hoàn chỉnh (sau khi fix)

```
Assignment
  └──(cần thêm)──> compensation.basis
                      ├── salary_basis_id ──> comp_core.salary_basis (config template)
                      │                        ├── salary_basis_component_map ──> pay_component_def
                      │                        └── basis_calculation_rule ──> calculation_rule_def
                      └── basis_line[] (fixed allowances per employee)
```

---

## Q3: Multi-Rate Timesheet cho giảng viên

### Thiết kế hiện tại cho phép 1 timesheet + nhiều rate

```
timesheet_header (1 per period)
├── line: time_type_code='TEACHING',   qty_hours=4.0
├── line: time_type_code='RESEARCH',   qty_hours=2.0
└── line: time_type_code='CONFERENCE', qty_hours=2.0
```

**Không cần nhiều timesheet** — `timesheet_line` đã support `time_type_code` khác nhau.
**Không cần nhiều compensation basis** — rate nằm ở `pay_component_def`, không phải comp basis.

### 📝 Clarification: Output của TA sang Payroll sẽ có nhiều thành phần

> User comment: *"output của TA sẽ phải nhiều thành phần? công chia theo nhiều time type code, OT, absence,...?"*

**Đúng vậy.** Output từ TA module sang Payroll sẽ là multi-component. Cấu trúc output:

```
TA Output → pay_run.input_value (nhiều dòng per employee per period)
├── source_type='TimeAttendance', input_code='HOURS', element → TEACHING_PAY     (4h × rate_A)
├── source_type='TimeAttendance', input_code='HOURS', element → RESEARCH_PAY     (2h × rate_B)  
├── source_type='TimeAttendance', input_code='HOURS', element → CONFERENCE_PAY   (2h × rate_C)
├── source_type='TimeAttendance', input_code='HOURS', element → OT_150           (2h OT weekday)
├── source_type='TimeAttendance', input_code='HOURS', element → NIGHT_PREMIUM    (3h ca đêm)
└── source_type='Absence',        input_code='HOURS', element → LEAVE_DEDUCTION  (-8h phép)
```

Đây là **thiết kế đúng** theo pattern chuẩn (Oracle HCM, Workday đều theo mô hình này). TA module không tính tiền — chỉ output **giờ/ngày theo từng time_type_code**. Payroll engine nhận input này → lookup rate từ `pay_element.formula_json` hoặc `pay_component_def` → tính tiền.

### Gap cần fix cho flow TA → Payroll

| Gap | Mô tả | Priority |
|-----|--------|----------|
| **Mapping table** `time_type_code` → `pay_element` | Hiện implicit (dựa vào `source_ref`). Cần explicit bridge table hoặc config | 🔴 High |
| **Rate source** per time_type | Rate nằm đâu? `pay_element.formula_json`? `employee_comp_snapshot`? Cần rõ ràng | 🔴 High |
| **TA aggregation output** | TA cần expose 1 "payroll-ready" view gom timesheet + OT + absence → structured input | 🟡 Medium |

---

## Q4: Eligibility → Total Rewards Package

### Config View (eligibility = dynamic group) — chưa đủ

| Module | Dùng centralized `eligibility.eligibility_profile`? |
|--------|-----|
| Absence (leave_type/class/policy) | ✅ v5.1 đã link |
| Benefits (benefit_plan) | ❌ Dùng riêng `benefit.eligibility_profile` (schema khác) |
| Compensation (comp_plan, bonus_plan) | ❌ Dùng inline `eligibility_rule` jsonb |
| Payroll (pay_element) | ❌ Không có eligibility concept |

### Execution View (emp → nhìn ra packages) — chưa đủ

| Query | Khả thi? |
|-------|---------|
| Emp X thuộc eligibility profiles nào? | ✅ `eligibility.eligibility_member` |
| Emp X được leave type nào? | ✅ qua centralized eligibility |
| Emp X được benefit plan nào? | ⚠️ Phải qua `benefit.eligibility_profile` riêng |
| Emp X thuộc comp plan nào? | ⚠️ Phải eval inline json — không query ngược được |
| Emp X có payroll element nào? | ❌ Chỉ biết từ pay_run result (sau khi chạy) |

### Gaps cần fix

1. **Unify eligibility**: Merge `benefit.eligibility_profile` vào `eligibility.eligibility_profile` (thêm domain)
2. **Comp Plan**: `comp_plan/bonus_plan.eligibility_rule` jsonb → chuyển sang `eligibility_profile_id` FK
3. **Payroll**: Thêm eligibility vào `pay_element` hoặc bridge table
4. **Aggregation view**: Cần `total_rewards.employee_reward_summary` để nhìn toàn cảnh per-employee

---

## Tổng hợp Gaps – Status (26Mar2026)

| # | Gap | Module | Status | DBML Fix (26Mar2026) |
|---|-----|--------|--------|----------------------|
| G1 | Thiếu `assignment_id` trên `compensation.basis` | Core | ✅ Fixed | `1.Core.V4.dbml`: Added `assignment_id` FK nullable |
| G2 | Thiếu piece-rate/output-based pay | Core | ✅ Fixed | `1.Core.V4.dbml`: Extended `compensation.basis` (`output_unit_code`, `unit_rate_amount`, `guaranteed_minimum`, frequency += `PER_UNIT`) |
| G3 | Thiếu mapping `time_type_code` → `pay_element` | TA↔PR | ✅ Fixed | `TA-database-design-v5.dbml`: New table `ta.time_type_element_map` |
| G4 | Thiếu rate source per time_type | TA↔TR | ✅ Fixed | Merged into G3: `rate_source_code` + `default_rate` on bridge table |
| G5 | `benefit.eligibility_profile` tách riêng | TR | ✅ Fixed | `4.TotalReward.V5.dbml`: Deprecated `benefit.eligibility_profile` + `plan_eligibility`; Added `eligibility_profile_id` FK to `benefit_plan` |
| G6 | `comp_plan.eligibility_rule` inline json | TR | ✅ Fixed | `4.TotalReward.V5.dbml`: Added `eligibility_profile_id` FK to `comp_plan` + `bonus_plan`; Deprecated `eligibility_rule` jsonb |
| G7 | Payroll thiếu eligibility | PR | ✅ Fixed | `5.Payroll.V3.dbml`: Added `eligibility_profile_id` FK to `pay_element` |
| G8 | Thiếu total rewards aggregation | Cross | ✅ Fixed | `4.TotalReward.V5.dbml`: New table `total_rewards.employee_reward_summary` |
| G9 | Absence v4 chưa sync TA v5.1 | TA | ⏭️ Skip | Per user decision — v4 kept as legacy reference |

---

*File này sẽ được update thêm khi có câu hỏi mới. Sau khi consolidate xong tất cả review, sẽ tổng hợp thành plan fix cho DBML.*
