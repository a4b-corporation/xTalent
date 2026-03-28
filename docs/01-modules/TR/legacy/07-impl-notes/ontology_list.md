Dưới đây là **kết quả “lọc ontology” cho module Total Rewards**, làm **đúng cùng phương pháp đã áp dụng cho Core HCM & Time/Absence**:
→ **tách business truth (ontology)** khỏi **transaction / workflow / ledger / materialized data**.

Tôi trình bày theo 5 phần:

1. Nguyên tắc áp dụng riêng cho Total Rewards
2. **Ontology Core – Total Rewards (CHÍNH THỨC)**
3. Supporting / Derived / Transactional (KHÔNG ontology)
4. Ontology theo **sub-module**
5. Mapping nhanh: Ontology ↔ DB tables (để bạn dùng sau)

---

## 1. Nguyên tắc áp dụng cho Total Rewards

Trong Total Rewards, **rất nhiều bảng “trông giống domain” nhưng KHÔNG là ontology** vì:

* Gắn trực tiếp với **employee instance**
* Là **snapshot / ledger / workflow**
* Chỉ tồn tại để **tính toán – trả lương – kiểm toán**

👉 Ontology ở đây tập trung vào:

* **Cấu trúc đãi ngộ**
* **Chính sách & rule**
* **Khung so sánh – định giá**
* **Khả năng reuse & reasoning**

---

## 2. ONTOLOGY CORE – Total Rewards

### 2.1 Compensation Structure Ontology (CORE CORE)

| Ontology Entity           | Ý nghĩa                                   | DB Table                      |
| ------------------------- | ----------------------------------------- | ----------------------------- |
| **SalaryBasis**           | Cách trả lương (monthly, hourly, annual…) | `comp_core.salary_basis`      |
| **PayComponent**          | Khái niệm thành phần thu nhập             | `comp_core.pay_component_def` |
| **CompensationStructure** | Quan hệ Basis ↔ Component                 | `salary_basis_component_map`  |

👉 Đây là **ontology thuần**:

* Không gắn employee
* Có rule, lifecycle, applicability
* Reuse xuyên payroll / offer / reward

---

### 2.2 Job Architecture & Market Ontology

| Ontology Entity | Ý nghĩa                         | DB Table            |
| --------------- | ------------------------------- | ------------------- |
| **Grade**       | Cấp bậc nghề nghiệp (versioned) | `grade_v`           |
| **GradeLadder** | Lộ trình nghề nghiệp            | `grade_ladder`      |
| **GradeStep**   | Bước trong ladder               | `grade_ladder_step` |
| **PayRange**    | Khung lương thị trường          | `pay_range`         |

👉 Đây là **market ontology**, không phải payroll.

---

### 2.3 Compensation Policy Ontology

| Ontology Entity       | Ý nghĩa                     | DB Table            |
| --------------------- | --------------------------- | ------------------- |
| **CompensationPlan**  | Chính sách điều chỉnh lương | `comp_plan`         |
| **CompensationCycle** | Chu kỳ áp dụng policy       | `comp_cycle`        |
| **BudgetPolicy**      | Phân bổ ngân sách           | `budget_allocation` |

👉 Policy-level ontology
👉 Không chứa dữ liệu trả lương thực tế

---

### 2.4 Incentive & Equity Ontology

| Ontology Entity     | Ý nghĩa                             | DB Table                          |
| ------------------- | ----------------------------------- | --------------------------------- |
| **IncentivePlan**   | Bonus / Commission / LTI definition | `bonus_plan`                      |
| **IncentiveCycle**  | Chu kỳ thưởng                       | `bonus_cycle`                     |
| **EquityPlan**      | Chính sách equity                   | `bonus_plan (equity_flag)`        |
| **VestingSchedule** | Logic vesting                       | `equity_grant.vesting_sched_json` |

👉 **EquityGrant KHÔNG là ontology** (instance cho 1 người)

---

### 2.5 Benefits Ontology

| Ontology Entity        | Ý nghĩa           | DB Table                      |
| ---------------------- | ----------------- | ----------------------------- |
| **BenefitPlan**        | Gói phúc lợi      | `benefit_plan`                |
| **BenefitOption**      | Option trong plan | `benefit_option`              |
| **BenefitEligibility** | Điều kiện hưởng   | `benefit.eligibility_profile` |

👉 `enrollment`, `claim`, `reimbursement` → **KHÔNG ontology**

---

### 2.6 Recognition & Perks Ontology

| Ontology Entity          | Ý nghĩa       | DB Table                 |
| ------------------------ | ------------- | ------------------------ |
| **RecognitionEventType** | Loại ghi nhận | `recognition_event_type` |
| **PerkCategory**         | Nhóm phúc lợi | `perk_category`          |
| **PerkCatalog**          | Danh mục perk | `perk_catalog`           |

👉 `recognition_event`, `perk_redeem` → transaction

---

### 2.7 Offer & Total Reward Package Ontology

| Ontology Entity             | Ý nghĩa              | DB Table                         |
| --------------------------- | -------------------- | -------------------------------- |
| **OfferTemplate**           | Khuôn offer          | `offer_template`                 |
| **TotalRewardPackageModel** | Cấu trúc gói đãi ngộ | `offer_template.components_json` |

👉 `offer_package` = instance → **KHÔNG ontology**

---

### 2.8 Calculation & Rule Ontology (RẤT QUAN TRỌNG)

| Ontology Entity          | Ý nghĩa                 | DB Table                     |
| ------------------------ | ----------------------- | ---------------------------- |
| **CalculationRule**      | Rule tính toán toàn cục | `calculation_rule_def`       |
| **ComponentRuleBinding** | Rule cho component      | `component_calculation_rule` |
| **BasisRuleBinding**     | Rule cho salary basis   | `basis_calculation_rule`     |

👉 Đây là **ontology logic / reasoning layer**, không phải payroll.

---

### 2.9 Country & Jurisdiction Ontology

| Ontology Entity       | Ý nghĩa                 | DB Table           |
| --------------------- | ----------------------- | ------------------ |
| **CountryCompConfig** | Chuẩn lao động quốc gia | `country_config`   |
| **HolidayRule**       | Ngày nghỉ & OT          | `holiday_calendar` |

---

## 3. KHÔNG PHẢI ONTOLOGY (nhưng cần giữ)

### 3.1 Employee-bound / Snapshot

| Table                    | Lý do                    |
| ------------------------ | ------------------------ |
| `employee_comp_snapshot` | Trạng thái tại thời điểm |
| `equity_grant`           | Grant cá nhân            |
| `point_account`          | Balance                  |

---

### 3.2 Workflow / Transaction

| Table                   |
| ----------------------- |
| `comp_adjustment`       |
| `bonus_allocation`      |
| `reimbursement_request` |
| `recognition_event`     |
| `offer_package`         |
| `offer_acceptance`      |

---

### 3.3 Ledger / Audit / Cache

| Table                   |
| ----------------------- |
| `audit_log`             |
| `taxable_item`          |
| `tax_calculation_cache` |
| `statement_job / line`  |

---

## 4. Ontology theo Sub-Module

```
total-rewards/
 ├─ compensation-structure/
 │   ├─ SalaryBasis
 │   ├─ PayComponent
 │   └─ CompensationStructure
 │
 ├─ job-architecture/
 │   ├─ Grade
 │   ├─ GradeLadder
 │   ├─ GradeStep
 │   └─ PayRange
 │
 ├─ policy/
 │   ├─ CompensationPlan
 │   ├─ CompensationCycle
 │   └─ BudgetPolicy
 │
 ├─ incentive/
 │   ├─ IncentivePlan
 │   ├─ IncentiveCycle
 │   └─ VestingSchedule
 │
 ├─ benefits/
 │   ├─ BenefitPlan
 │   ├─ BenefitOption
 │   └─ BenefitEligibility
 │
 ├─ recognition/
 │   ├─ RecognitionEventType
 │   └─ PerkCatalog
 │
 ├─ offer/
 │   ├─ OfferTemplate
 │   └─ TotalRewardPackageModel
 │
 └─ calculation/
     ├─ CalculationRule
     ├─ ComponentRuleBinding
     └─ BasisRuleBinding
```

---

## 5. Kết luận rất quan trọng

* **Bạn đã thiết kế DB đúng hướng ontology từ đầu**
* Vấn đề chỉ là:
  👉 *chưa đặt ranh giới khái niệm rõ ràng*

Sau bước này, bạn có thể:

* Viết **ontology YAML** cho từng entity trên
* Sinh:

  * Concept docs
  * Policy specs
  * Rule DSL
  * UI capability matrix
  * Permission model

Nếu bạn muốn, bước tiếp theo tôi đề xuất là:

> **Viết ontology YAML cho 5 entity nền nhất của Total Rewards**
> (SalaryBasis, PayComponent, Grade, CalculationRule, BenefitPlan)

Chỉ cần nói tôi bắt đầu từ entity nào.
