# Compensation Basis — Design & Architecture

> Related DBML: `4.TotalReward.V5.dbml` — schema `compensation`  
> Last updated: 23Apr2026

---

## 1. Tổng quan

`compensation.basis` là **header record** lưu mức lương hiệu lực của một nhân viên tại một thời điểm. Nó không đứng độc lập — được liên kết chặt với hệ thống centralized eligibility và salary_basis template để đảm bảo tính nhất quán.

```
eligibility.eligibility_profile  (rule_json: define WHO is eligible)
         ↓ evaluate → populate
eligibility.eligibility_member   (employee_id, profile_id, end_date IS NULL = active)
         ↓ JOIN
comp_core.salary_basis           (eligibility_profile_id, template cho bộ lương)
         ↓ map
comp_core.salary_basis_component_map  (salary_basis_id ↔ pay_component_def_id, mandatory_flag)
         ↓ HR selects basis → creates
compensation.basis               (salary_basis_id FK, basis_amount, header, SCD2)
         ↓ detail lines
compensation.basis_line          (pay_component_def_id NOT NULL, amount — fixed allowances)
```

---

## 2. Scoping vs Eligibility — Tách biệt rõ ràng

`salary_basis` có **hai cơ chế scope** phục vụ hai mục đích khác nhau:

| Field | Mục đích | Ai dùng |
|---|---|---|
| `country_code / legal_entity_id / config_scope_id` | **Admin UI filtering** — HR lọc "salary bases của VN" | UI/Admin |
| `eligibility_profile_id` | **Business rule** — Engine quyết định employee nào được dùng salary_basis này | Eligibility Engine |

**Hai concerns này độc lập hoàn toàn.** Ví dụ: một `salary_basis` có `country_code = VN` nhưng rule_json của eligibility_profile có thể restrict thêm: chỉ full-time, tenure ≥ 1 năm.

---

## 3. Luồng Onboard (Hire) — Thiết lập Compensation Basis đầu tiên

```
1. Tạo worker + employee + work_relationship + contract
        ↓
2. Eligibility engine evaluate employee dựa theo rule_json
   → tạo/cập nhật eligibility.eligibility_member records
        ↓
3. HR vào "Thiết lập lương" (Set Salary)
   → System query:
       SELECT sb.*
       FROM comp_core.salary_basis sb
       JOIN eligibility.eligibility_member em
         ON em.profile_id = sb.eligibility_profile_id
       WHERE em.employee_id = :employee_id
         AND em.end_date IS NULL
         AND sb.effective_end IS NULL
   → HR thấy danh sách salary_bases mà employee đủ điều kiện
        ↓
4. HR chọn salary_basis (e.g., STANDARD_VN_FULLTIME)
   → System auto-create basis_line records cho tất cả components có mandatory_flag = true
     (amount = 0, chờ HR nhập — không thể ACTIVE khi còn mandatory line amount = 0)
        ↓
5. HR nhập basis_amount + amounts cho các mandatory/optional lines
   → status_code: DRAFT → submit → PENDING_APPROVAL
        ↓
6. Approver review → APPROVED
   → status_code = ACTIVE, is_current_flag = true
        ↓
7. Payroll run: đọc compensation.basis WHERE is_current_flag = true
   Gross payable = basis_amount + total_allowance_amount (tính tại app layer)
```

**Lưu ý:** `salary_basis_id` MUST NOT NULL cho records tạo từ UI. Chỉ legacy/migration records mới cho phép NULL (cần flag với `status_code = 'NEEDS_REVIEW'`).

---

## 4. Hai loại Compensation Basis đồng thời — LEGAL_BASE vs OPERATIONAL_BASE

Ở VN (và nhiều thị trường), lương hợp đồng (đóng BHXH) ≠ lương thực trả hàng tháng. Hệ thống hỗ trợ **2 concurrent active basis** cho cùng một employee:

| `basis_type_code` | Ý nghĩa | Dùng cho |
|---|---|---|
| `LEGAL_BASE` | Lương ghi trong hợp đồng lao động | Đóng BHXH, báo cáo pháp lý |
| `OPERATIONAL_BASE` | Lương thực chi hàng tháng | Payroll tính toán, payslip |
| `MARKET_ADJUSTED` | Lương theo market benchmark | Comp planning, benchmarking |

**Cả hai có thể `is_current_flag = true` đồng thời** — chúng là 2 records độc lập với `basis_type_code` khác nhau. Unique constraint là `(work_relationship_id, basis_type_code, effective_start_date)`.

**Khi tạo LEGAL_BASE:** `contract_id` MUST NOT NULL (app-layer) — phải link về hợp đồng nguồn.  
**Khi tạo OPERATIONAL_BASE:** `contract_id` optional.

Query current active basis:
```sql
SELECT * FROM compensation.basis
WHERE work_relationship_id = :wr_id
  AND basis_type_code = 'OPERATIONAL_BASE'  -- hoặc LEGAL_BASE
  AND is_current_flag = true
```

---

## 5. Luồng Thay Đổi Lương (Salary Change — SCD2)

```
1. Trigger: ANNUAL_REVIEW, PROMOTION, MARKET_ADJUST, TRANSFER, v.v.
        ↓
2. System/HR tạo compensation.basis record mới (SCD2):
   - effective_start_date = ngày có hiệu lực mới
   - previous_basis_id = id của record đang ACTIVE
   - source_code = TRIGGER (CONTRACT | COMP_CYCLE | MANUAL_ADJUST | SYSTEM_AUTO)
   - reason_code = WHY (ANNUAL_REVIEW | PROMOTION | TRANSFER | CORRECTION | MARKET_ADJUST)
   - change_event_id = FK đến comp cycle event (nếu thuộc batch change)
        ↓
3. App layer quyết định có copy basis_lines từ record cũ không:
   - Default behavior: COPY tất cả basis_lines hiện tại → giảm lỗi nhập lại
   - HR chỉ cần sửa line amount nào thay đổi
   - Nếu salary_basis thay đổi (employee chuyển sang basis khác): không copy, tạo lại từ đầu
        ↓
4. HR nhập amounts mới → PENDING_APPROVAL → APPROVED
        ↓
5. Khi record mới ACTIVE:
   - Record cũ tự động expire: is_current_flag = false, effective_end_date = new_start - 1 day
   - total_allowance_amount recalculate từ basis_lines mới
```

---

## 6. Auto-Expiry khi Employee Chuyển Scope

Khi employee chuyển scope (country/LE transfer):
```
Employee ký hợp đồng mới → work_relationship mới → assignment mới
        ↓
Workflow lifecycle CLOSE hợp đồng cũ → trigger expiry:
  - compensation.basis cũ: is_current_flag = false, effective_end_date = transfer date
  - Eligibility engine re-evaluate employee → update eligibility_member
        ↓
HR được notify → tạo compensation.basis mới cho work_relationship mới
  - Chọn salary_basis phù hợp với scope mới (VD: SG salary basis thay VN)
```

**Fallback:** Nếu workflow thiếu → scheduled job phát hiện work_relationship mới mà không có active basis → expire record cũ + alert HR.

---

## 7. Aggregation Fields — Sync Mechanism

`compensation.basis` có 2 aggregated fields:

| Field | Ý nghĩa | Sync |
|---|---|---|
| `total_allowance_amount` | SUM(basis_line.amount) WHERE is_current_flag = true | App-layer transaction: mỗi INSERT/UPDATE/DELETE basis_line → UPDATE basis header trong cùng transaction |
| `component_line_count` | COUNT(basis_line) WHERE is_current_flag = true | Tương tự |

**`total_gross_amount` KHÔNG được store** — app layer tính on-the-fly:  
`total_gross_amount = basis_amount + total_allowance_amount`

**Sync approach: App-layer transaction (Option B)**  
Mỗi thao tác trên `basis_line` đều phải UPDATE `compensation.basis` header trong cùng DB transaction. Không dùng DB trigger để tránh hidden side-effects.

---

## 8. Mandatory Component Enforcement

`salary_basis_component_map.mandatory_flag = true` có nghĩa component BẮT BUỘC phải có trong basis.

**Enforcement flow:**
```
Khi HR chọn salary_basis X để tạo compensation.basis mới:
  → System auto-create basis_line records cho tất cả components WHERE mandatory_flag = true
    (amount = 0 — chờ HR nhập)
  
Validation trước PENDING_APPROVAL:
  → Kiểm tra: có basis_line nào mandatory mà amount = 0 không?
  → Nếu CÓ: block submit, show warning "Chưa nhập amount cho [component_name]"
  
Validation trước ACTIVE:
  → Approver không thể approve nếu còn mandatory line nào amount = 0
```

---

## 9. basis_line Constraint — Component phải nằm trong salary_basis_component_map

```
basis_line.pay_component_def_id PHẢI tồn tại trong:
  comp_core.salary_basis_component_map
  WHERE salary_basis_id = (SELECT salary_basis_id FROM compensation.basis WHERE id = basis_line.basis_id)
```

**Enforcement points:**
1. **CompensationBasisService.addLine()** — validate trước INSERT.
2. **Payroll pre-run validation** — scan toàn bộ active basis_lines, flag INVALID nếu vi phạm, alert HR.

**Quy trình khi cần phụ cấp mới:**
1. Admin tạo `pay_component_def` mới
2. Admin thêm vào `salary_basis_component_map` cho salary_basis liên quan
3. HR mới được phép thêm `basis_line` với component đó

---

## 10. source_code vs reason_code — Semantic rõ ràng

| Field | Câu hỏi trả lời | Valid values |
|---|---|---|
| `source_code` | **WHO/WHAT** triggered việc tạo record này? | `CONTRACT` \| `MANUAL_ADJUST` \| `COMP_CYCLE` \| `SYSTEM_AUTO` |
| `reason_code` | **WHY** lương thay đổi (business reason)? | `HIRE` \| `PROBATION_END` \| `ANNUAL_REVIEW` \| `PROMOTION` \| `TRANSFER` \| `MARKET_ADJUST` \| `CORRECTION` |

Ví dụ: Nhân viên được promote → `source_code = COMP_CYCLE` (qua compensation cycle), `reason_code = PROMOTION`.

---

## 11. Tham chiếu

- DBML: `4.TotalReward.V5.dbml` — schema `comp_core`, `compensation`
- Eligibility engine: `1.Core.V4.dbml` — schema `eligibility`
- CHANGELOG: `CHANGELOG.md` — Change 59
