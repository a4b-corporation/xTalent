Dưới đây là **phân loại ontology cho module Time & Attendance + Absence** theo **đúng logic đã áp dụng cho Core HCM**, không nhìn DBML như “bảng”, mà nhìn nó như **tri thức nghiệp vụ** → sau đó mới map sang DB.

Tôi chia thành 4 phần:

1. Nguyên tắc phân loại (để bạn tự áp dụng về sau)
2. Ontology Core (đúng nghĩa ontology)
3. Supporting / Derived / Operational (KHÔNG là ontology)
4. Sub-module ontology map (để tách module rõ ràng)

---

## 1. Nguyên tắc phân loại (rất quan trọng)

Một khái niệm **đƯỢC LÀ ontology** nếu thỏa **≥ 3 điều kiện**:

| Tiêu chí                        | Ý nghĩa                         |
| ------------------------------- | ------------------------------- |
| **Business meaning độc lập**    | Không phụ thuộc DB hay kỹ thuật |
| **Quan hệ rõ ràng**             | Có link với entity khác         |
| **Lifecycle / rule / behavior** | Không chỉ là record             |
| **Reuse xuyên module**          | Không chỉ dùng trong 1 bảng     |

Một khái niệm **KHÔNG là ontology** nếu:

* Chỉ là **materialized result**
* Chỉ phục vụ **tính toán / audit**
* Chỉ là **workflow instance**
* Chỉ là **ledger / log**

---

## 2. ONTOLOGY CORE – Time & Attendance

### 2.1 Time Modeling Ontology (CORE CORE)

Đây là **xương sống ontology** của toàn bộ Time & Attendance.

### ✅ Ontology Entities

| Ontology Entity  | DB Tables liên quan        |
| ---------------- | -------------------------- |
| **TimeSegment**  | `ta.time_segment`          |
| **Shift**        | `ta.shift_def`             |
| **DayModel**     | `ta.day_model`             |
| **WorkPattern**  | `ta.pattern_template`      |
| **ScheduleRule** | `ta.schedule_assignment`   |
| **WorkCalendar** | `absence.holiday_calendar` |

👉 Đây là **ontology thuần**:

* Không gắn employee
* Không sinh dữ liệu
* Chỉ định nghĩa *how time works*

#### Ontology graph (logic)

```
TimeSegment
   ↓ (composed into)
Shift
   ↓
DayModel
   ↓
WorkPattern
   ↓
ScheduleRule
   ↓
(applied to Employee/Position)
```

---

### 2.2 Assignment & Applicability Ontology

| Ontology Entity        | Giải thích                 |
| ---------------------- | -------------------------- |
| **ScheduleAssignment** | “Ai được áp dụng lịch nào” |
| **ApplicabilityScope** | EMP / BU / POSITION        |

DB:

* `ta.schedule_assignment`

👉 Là ontology vì:

* Có rule
* Có phạm vi
* Không phải dữ liệu sinh ra

---

## 3. KHÔNG PHẢI ONTOLOGY (nhưng rất quan trọng)

### 3.1 Derived / Materialized (KHÔNG ontology)

| Table                  | Vì sao không là ontology  |
| ---------------------- | ------------------------- |
| `ta.generated_roster`  | Output sinh ra            |
| `ta.shift` (renamed)   | Instance cụ thể theo ngày |
| `ta.attendance_record` | Fact đã xử lý             |
| `ta.timesheet_entry`   | Accounting record         |

👉 Những cái này là **FACT / EVENT / LEDGER**, không phải tri thức.

---

### 3.2 Workflow / Transactional (KHÔNG ontology)

| Table                   | Nhận xét                |
| ----------------------- | ----------------------- |
| `ta.shift_swap_request` | Workflow                |
| `ta.shift_bid`          | Marketplace transaction |
| `ta.overtime_request`   | Approval process        |

👉 Có lifecycle nhưng **lifecycle workflow**, không phải business concept nền.

---

## 4. ABSENCE – Ontology phân loại

### 4.1 Absence Policy Ontology (CORE)

### ✅ Ontology Entities

| Ontology Entity        | DB Table                          |
| ---------------------- | --------------------------------- |
| **LeaveType**          | `absence.leave_type`              |
| **LeaveClass**         | `absence.leave_class`             |
| **LeavePolicy**        | `absence.leave_policy`            |
| **EligibilityProfile** | `eligibility.eligibility_profile` |

👉 Đây là **policy ontology**, không phải balance.

---

### 4.2 Leave Balance & Ledger (KHÔNG ontology)

| Table                          | Lý do            |
| ------------------------------ | ---------------- |
| `absence.leave_instant`        | Balance snapshot |
| `absence.leave_instant_detail` | FEFO lot         |
| `absence.leave_movement`       | Immutable ledger |

---

### 4.3 Leave Request (KHÔNG ontology)

| Table                       | Nhận xét       |
| --------------------------- | -------------- |
| `absence.leave_request`     | Transaction    |
| `absence.approval`          | Workflow       |
| `absence.leave_reservation` | Temporary lock |

---

## 5. Sub-Module Ontology Map (RẤT QUAN TRỌNG)

### 🧩 Time & Attendance Ontology Modules

```
time/
 ├─ time-segmentation/
 │   ├─ TimeSegment
 │   ├─ Shift
 │   └─ DayModel
 │
 ├─ scheduling/
 │   ├─ WorkPattern
 │   ├─ ScheduleRule
 │   └─ WorkCalendar
 │
 ├─ attendance/
 │   └─ (NO ontology – facts only)
 │
 └─ overtime/
     ├─ OvertimeRule
     └─ OvertimePolicy
```

---

### 🧩 Absence Ontology Modules

```
absence/
 ├─ leave-definition/
 │   ├─ LeaveType
 │   ├─ LeaveClass
 │   └─ LeavePolicy
 │
 ├─ eligibility/
 │   └─ EligibilityProfile
 │
 └─ execution/
     └─ (NO ontology – requests & ledger)
```

---

## 6. Câu trả lời trực tiếp cho câu hỏi ngầm của bạn

> “Có phải ontology là chọn lọc lại từ ERD không?”

✅ **ĐÚNG – nhưng không phải 1–1**

* ERD = *implementation*
* Ontology = *business truth*

Bạn đã **vô tình làm ontology rất tốt**:

* 6-level Time hierarchy → ontology chuẩn
* Eligibility tách riêng → ontology chuẩn
* Policy vs Ledger tách → đúng ontology thinking

Việc còn lại chỉ là:

> **đặt lại ranh giới khái niệm**

---

## 7. Gợi ý bước tiếp theo (nếu bạn muốn)

Tôi có thể giúp bạn:

1. Xuất **ontology YAML** cho:

   * `TimeSegment`
   * `Shift`
   * `WorkPattern`
   * `LeavePolicy`
2. Vẽ **ontology graph (Mermaid)** cho Time & Absence
3. Viết **mapping table**: Ontology → DB tables
4. Chuẩn hóa naming: *Shift vs Schedule vs Pattern* (hiện đang trùng)

Chỉ cần nói bạn muốn đi bước nào trước.
