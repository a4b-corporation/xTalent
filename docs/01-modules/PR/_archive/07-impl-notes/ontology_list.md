Dưới đây là **phân loại & nhận diện ontology cho module Payroll**, làm **đúng cùng phương pháp bạn đã dùng cho Core / Time / Total Rewards**:
→ tách **Payroll Ontology (business truth)** khỏi **Payroll Engine / Run / Integration / Ledger**.

Tôi trình bày theo 6 phần, để bạn dùng trực tiếp làm nền cho ontology YAML sau này.

---

## 1. Nguyên tắc áp dụng riêng cho Payroll

Payroll có đặc thù:

* **Rất nhiều bảng “master” nhưng không phải ontology**
* Engine sinh ra **fact, result, balance, costing**
* Ontology của payroll **không nằm ở run**, mà nằm ở:

  * Cấu trúc trả lương
  * Quy tắc pháp lý
  * Chính sách áp dụng
  * Khung cấu hình quốc gia / thị trường

👉 Quy tắc lọc:

* Nếu **gắn employee / batch / period cụ thể** → ❌ ontology
* Nếu **định nghĩa cách tính / cách áp dụng / khung pháp lý** → ✅ ontology

---

## 2. PAYROLL ONTOLOGY – CORE (CHÍNH THỨC)

### 2.1 Payroll Structure Ontology (CORE CORE)

| Ontology Entity  | Ý nghĩa                   | DB Table        |
| ---------------- | ------------------------- | --------------- |
| **PayFrequency** | Chu kỳ trả lương          | `pay_frequency` |
| **PayCalendar**  | Lịch trả lương            | `pay_calendar`  |
| **PayGroup**     | Nhóm trả lương            | `pay_group`     |
| **PayProfile**   | Bundle chính sách payroll | `pay_profile`   |

👉 Đây là **khung tổ chức payroll**, không sinh tiền.

---

### 2.2 Payroll Element Ontology

| Ontology Entity          | Ý nghĩa                             | DB Table      |
| ------------------------ | ----------------------------------- | ------------- |
| **PayElement**           | Khái niệm earning / deduction / tax | `pay_element` |
| **PayFormula**           | Công thức dùng chung                | `pay_formula` |
| **PayBalanceDefinition** | Định nghĩa balance                  | `balance_def` |

👉 `PayElement` là **ontology trung tâm của payroll**

---

### 2.3 Payroll Rule & Policy Ontology (RẤT QUAN TRỌNG)

| Ontology Entity     | Ý nghĩa                 | DB Table               |
| ------------------- | ----------------------- | ---------------------- |
| **StatutoryRule**   | Quy định pháp lý        | `statutory_rule`       |
| **DeductionPolicy** | Chính sách deduction    | `pay_deduction_policy` |
| **ValidationRule**  | Rule kiểm tra dữ liệu   | `validation_rule`      |
| **CostingRule**     | Quy tắc phân bổ chi phí | `costing_rule`         |

👉 Đây là **rule ontology**, không phải engine.

---

### 2.4 Accounting & Reporting Ontology

| Ontology Entity       | Ý nghĩa            | DB Table              |
| --------------------- | ------------------ | --------------------- |
| **GLMappingPolicy**   | Mapping kế toán    | `gl_mapping`          |
| **PayslipTemplate**   | Mẫu phiếu lương    | `payslip_template`    |
| **BankTemplate**      | Mẫu file ngân hàng | `bank_template`       |
| **TaxReportTemplate** | Mẫu báo cáo thuế   | `tax_report_template` |

---

### 2.5 Integration Ontology

| Ontology Entity      | Ý nghĩa             | DB Table    |
| -------------------- | ------------------- | ----------- |
| **PayrollInterface** | Định nghĩa tích hợp | `iface_def` |

👉 `iface_job`, `iface_file`, `iface_line` → **runtime**

---

## 3. KHÔNG PHẢI ONTOLOGY (ENGINE / RUNTIME)

### 3.1 Payroll Run & Calculation (ENGINE)

| Table                 |
| --------------------- |
| `pay_run.batch`       |
| `pay_run.employee`    |
| `pay_run.input_value` |
| `pay_run.result`      |
| `pay_run.balance`     |
| `pay_run.retro_delta` |
| `pay_run.calc_log`    |
| `pay_run.costing`     |

👉 Đây là **materialized facts**, không phải tri thức.

---

### 3.2 Adjustment & Manual Ops (TRANSACTION)

| Table            |
| ---------------- |
| `manual_adjust`  |
| `import_job`     |
| `generated_file` |

---

### 3.3 Payment Execution (DOWNSTREAM)

| Table           |
| --------------- |
| `payment_batch` |
| `payment_line`  |
| `bank_account`  |

---

### 3.4 Audit / Logging (META)

| Table                 |
| --------------------- |
| `pay_audit.audit_log` |

---

## 4. Payroll Ontology theo Sub-Module

```
payroll/
 ├─ structure/
 │   ├─ PayFrequency
 │   ├─ PayCalendar
 │   ├─ PayGroup
 │   └─ PayProfile
 │
 ├─ elements/
 │   ├─ PayElement
 │   ├─ PayFormula
 │   └─ PayBalanceDefinition
 │
 ├─ rules/
 │   ├─ StatutoryRule
 │   ├─ DeductionPolicy
 │   ├─ ValidationRule
 │   └─ CostingRule
 │
 ├─ accounting/
 │   ├─ GLMappingPolicy
 │   └─ CostingRule
 │
 ├─ reporting/
 │   ├─ PayslipTemplate
 │   └─ TaxReportTemplate
 │
 ├─ integration/
 │   └─ PayrollInterface
 │
 └─ runtime/
     └─ (NO ontology – engine only)
```

---

## 5. Một số nhận định quan trọng (để bạn yên tâm)

### ✅ Thiết kế của bạn **đã là ontology-friendly**

* SCD-2 cho master → đúng ontology thinking
* Tách rule / formula / template → đúng abstraction
* Engine tách riêng → rất chuẩn

### ⚠️ Một số bảng **trông giống ontology nhưng thực ra là runtime**

* `pay_run.*`
* `payment_*`
* `generated_file`

👉 Không nên đưa vào ontology layer.

---

## 6. Gợi ý bước tiếp theo (rất nên làm)

Nếu đi tiếp theo pipeline ontology-driven mà bạn đang theo:

1. Viết **ontology YAML** cho 6 entity nền nhất của Payroll:

   * `PayElement`
   * `PayCalendar`
   * `PayProfile`
   * `StatutoryRule`
   * `DeductionPolicy`
   * `PayBalanceDefinition`

2. Sinh:

   * Payroll Concept Guide
   * Payroll Calculation Spec
   * Payroll Permission Matrix
   * Rule Execution Graph (gross → deduction → tax → net)

Nếu bạn muốn, hãy nói:

> “Bắt đầu viết ontology YAML cho PayElement”
> hoặc
> “Vẽ ontology graph cho Payroll”

Tôi sẽ tiếp ngay theo đúng style bạn đang dùng cho Core.
