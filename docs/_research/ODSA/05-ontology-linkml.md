# Ontology & LinkML — Schema hóa Domain Model

> **Vị trí trong pipeline:** Bước 4 — Sau Glossary, trước Flow  
> **Mục tiêu:** Biến Glossary (ngôn ngữ tự nhiên) thành schema có cấu trúc, machine-readable, có thể validate

---

## 1. Tại sao cần schema hóa?

Glossary giải quyết vấn đề **meaning** (nghĩa là gì).  
LinkML giải quyết vấn đề **structure** (cấu trúc dữ liệu là gì).

| | Glossary | LinkML |
|-|---------|--------|
| **Ngôn ngữ** | Tiếng Việt, tự nhiên | YAML, formal |
| **Giải quyết** | Ambiguity of meaning | Structure constraints |
| **Có thể validate?** | Không | Có (linkml-validate) |
| **Generate code?** | Không | JSON Schema, Python class, RDF |

---

## 2. Ontology Semi-formal vs OWL/RDF

**Thực tế pipeline chuẩn cho 80% dự án:**

```
Reality
  ↓
Semi-formal ontology (team hiểu, machine-friendly)
  ↓
(OPTIONAL) OWL/RDF nếu cần AI reasoning/knowledge graph
  ↓
Code
```

> **OWL/RDF không phải lúc nào cũng cần.**  
> **LinkML là lựa chọn thực dụng hơn cho dev team.**

---

## 3. LinkML là gì?

**LinkML (Linked data Modeling Language)** = schema language nằm giữa ontology và code

```
Ontology (truth)
    ↓
LinkML (structured schema — dev friendly)
    ↓
DDD/OOP (code organization + behavior)
```

**LinkML làm được gì:**
- Define Class, Attribute, Relationship, Constraint
- Generate: JSON Schema, Python class, RDF/OWL
- Validate data theo schema
- Bridge giữa data + ontology + code

**LinkML KHÔNG làm được:**
- Aggregate boundary (DDD specific)
- Domain service, Domain event (DDD specific)
- Business behavior (behavior → xem Flow docs)

---

## 4. Scope của LinkML file

> **1 file LinkML = 1 Bounded Context**  
> Không chia theo từng entity riêng lẻ.

```yaml
# ordering/model.linkml.yaml
id: ordering_domain
name: Ordering Domain

classes:
  Order:
    ...
  LineItem:
    ...
  Customer:
    ...
```

---

## 5. Syntax LinkML chuẩn

### 5.1 Cấu trúc file cơ bản

```yaml
id: https://example.com/schemas/ordering
name: ordering-domain
description: Schema cho Ordering Bounded Context

# Import types cơ bản
imports:
  - linkml:types

prefixes:
  linkml: https://w3id.org/linkml/
  ordering: https://example.com/schemas/ordering/

default_prefix: ordering
default_range: string

# Định nghĩa classes
classes:
  # ...

# Định nghĩa enums
enums:
  # ...
```

---

### 5.2 Class cơ bản

```yaml
classes:
  Order:
    description: >-
      Đơn hàng đã được customer xác nhận. Luôn có ít nhất 1 line item.
    attributes:
      id:
        range: string
        identifier: true
        description: Unique ID của order
      status:
        range: OrderStatus
        required: true
        description: Trạng thái hiện tại của order
      customer_id:
        range: string
        required: true
        description: ID của customer đặt hàng
      line_items:
        range: LineItem
        multivalued: true
        minimum_cardinality: 1   # ← constraint: phải có ít nhất 1
        description: Danh sách items trong order
      created_at:
        range: datetime
        required: true
      total_amount:
        range: decimal
        description: Tổng giá trị đơn hàng
```

### 5.3 Enum (trạng thái)

```yaml
enums:
  OrderStatus:
    description: Các trạng thái của Order
    permissible_values:
      PENDING:
        description: Đơn hàng vừa được tạo, chờ xử lý
      CONFIRMED:
        description: Đơn hàng đã được confirm, đang xử lý
      CANCELLED:
        description: Đơn hàng đã bị hủy
      COMPLETED:
        description: Đơn hàng đã hoàn thành (giao hàng thành công)
```

### 5.4 Inheritance (kế thừa)

```yaml
classes:
  BaseEntity:
    abstract: true
    attributes:
      id:
        range: string
        identifier: true
      created_at:
        range: datetime
        required: true
      updated_at:
        range: datetime

  Order:
    is_a: BaseEntity    # ← inherit từ BaseEntity
    attributes:
      # chỉ thêm attributes đặc thù của Order
      status:
        range: OrderStatus
        required: true
```

### 5.5 Relationship

```yaml
classes:
  Order:
    attributes:
      line_items:
        range: LineItem        # ← refer đến class khác
        multivalued: true      # ← có nhiều LineItem
        inlined: true          # ← LineItem không có ID riêng, embedded trong Order
      customer_id:
        range: string          # ← chỉ store ID, không inlined
        description: FK to Customer context
```

---

## 6. Mapping DDD concept → LinkML

| DDD Concept | LinkML | Ghi chú |
|------------|--------|---------|
| Entity | `class` với `identifier: true` | Có ID riêng |
| Value Object | `class` với `inlined: true` | Không có ID, embedded trong entity |
| Attribute | `attribute` | Dùng `required: true` nếu bắt buộc |
| Constraint | `minimum_cardinality`, `maximum_cardinality`, `required` | |
| Enum | `enum` | Dùng cho status, type |
| Aggregate boundary | ❌ Không có trong LinkML | Ghi chú trong comments |
| Domain service | ❌ Không có | Mô tả trong Flow docs |
| Domain event | ❌ Không có trực tiếp | Define trong Glossary events section |

---

## 7. Ví dụ hoàn chỉnh — Leave Context (HCM)

```yaml
# leave/model.linkml.yaml
id: https://example.com/schemas/leave
name: leave-context
description: Schema cho Leave & Absence Bounded Context

imports:
  - linkml:types

default_range: string

classes:
  LeaveRequest:
    description: >-
      Yêu cầu nghỉ phép do nhân viên tạo, chưa được duyệt.
      Khác với Leave (đã được approve).
    attributes:
      id:
        identifier: true
      employee_id:
        required: true
        description: ID của nhân viên (từ Employee Context)
      leave_type:
        range: LeaveType
        required: true
      start_date:
        range: date
        required: true
      end_date:
        range: date
        required: true
      status:
        range: LeaveRequestStatus
        required: true
      reason:
        range: string
      created_at:
        range: datetime
        required: true

  LeaveBalance:
    description: Số ngày phép còn lại của nhân viên
    attributes:
      id:
        identifier: true
      employee_id:
        required: true
      leave_type:
        range: LeaveType
        required: true
      year:
        range: integer
        required: true
      total_days:
        range: decimal
        required: true
      used_days:
        range: decimal
        required: true
      remaining_days:
        range: decimal
        description: "Computed: total_days - used_days"

enums:
  LeaveType:
    permissible_values:
      ANNUAL:
        description: Nghỉ phép năm
      SICK:
        description: Nghỉ bệnh
      MATERNITY:
        description: Nghỉ thai sản
      UNPAID:
        description: Nghỉ không lương

  LeaveRequestStatus:
    permissible_values:
      PENDING:
        description: Chờ manager duyệt
      APPROVED:
        description: Đã được duyệt
      REJECTED:
        description: Bị từ chối
      CANCELLED:
        description: Nhân viên tự hủy
```

---

## 8. Validate với linkml CLI

```bash
# Install
pip install linkml

# Validate schema
linkml-validate --schema leave/model.linkml.yaml

# Validate data file theo schema
linkml-validate --schema leave/model.linkml.yaml --target-class LeaveRequest data.json

# Generate JSON Schema
gen-json-schema leave/model.linkml.yaml > leave-schema.json

# Generate Python classes
gen-python leave/model.linkml.yaml > leave_model.py
```

---

## 9. Checklist "Done" cho LinkML

- [ ] Tất cả entity trong Glossary đã có class trong LinkML
- [ ] Tất cả attribute có `required: true` khi bắt buộc
- [ ] Relationship giữa entity đã được express rõ (multivalued, cardinality)
- [ ] Status enum đã có permissible_values đầy đủ
- [ ] `linkml-validate` chạy không có lỗi
- [ ] Không define `Aggregate boundary`, `service`, `event` trong LinkML (để dành cho Flow docs)

---

*→ Bước tiếp theo: [`06-flow-behavior.md`](./06-flow-behavior.md) — Mô tả behavior qua Use Case Flow*
