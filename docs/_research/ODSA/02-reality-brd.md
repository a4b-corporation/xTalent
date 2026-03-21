# Tầng Reality — BRD, User Stories & Event Storming

> **Vị trí trong pipeline:** Bước 1 — Điểm khởi đầu của mọi thứ  
> **Mục tiêu:** Nắm bắt "thế giới thực" một cách đầy đủ trước khi bắt đầu bất kỳ model hay code nào

---

## 1. Tại sao tầng Reality quan trọng?

> Reality tồn tại **trước** khi có code, database hay hệ thống.  
> Mọi sai lầm ở tầng này sẽ được khuếch đại qua toàn bộ pipeline.

**Sai lầm số 1 của team phần mềm:**

```
"Business nói thế này" → dev hiểu thế kia → code thế khác
```

Tầng Reality cố gắng đảm bảo "thế giới thật" được capture chính xác và không có ambiguity trước khi chuyển sang mô hình hóa.

---

## 2. Ba loại artifact ở tầng Reality

### 2.1 Business Requirement Document (BRD)

**Khi nào dùng:** Dự án có stakeholder business rõ ràng, cần alignment cấp cao trước khi đi vào chi tiết.

**Cấu trúc chuẩn:**

```markdown
# BRD — [Tên module/project]

## 1. Business Context
- Tổ chức/phòng ban liên quan
- Vấn đề hiện tại đang gặp phải
- Lý do cần giải quyết NOW

## 2. Business Objectives
- Mục tiêu định lượng được: "Giảm thời gian xử lý đơn hàng từ 2h xuống 15 phút"
- Tránh mục tiêu mơ hồ: "Cải thiện trải nghiệm"

## 3. Business Actors
| Actor | Vai trò | Tần suất |
|-------|---------|---------|
| Nhân viên kho | Xử lý đơn xuất hàng | Hàng ngày |
| Quản lý | Duyệt đơn > 10tr | Khi có |

## 4. Business Rules (cấp cao)
- Đơn hàng > 10 triệu cần 2 cấp duyệt
- Thanh toán phải xảy ra trước giao hàng
- Mỗi khách hàng tối đa 5 đơn pending

## 5. Out of Scope
- Những gì KHÔNG thuộc phạm vi dự án này

## 6. Assumptions & Dependencies
- Giả định nào đang được dùng
- Phụ thuộc vào hệ thống/team nào khác
```

---

### 2.2 User Stories

**Khi nào dùng:** Phù hợp với Agile team, khi cần chia nhỏ yêu cầu thành unit có thể estimate và deliver.

**Format chuẩn:**

```
As a [actor],
I want to [action],
So that [business value].

Acceptance Criteria:
- GIVEN [bối cảnh]
  WHEN [hành động]
  THEN [kết quả mong đợi]
```

**Ví dụ tốt:**

```
As a warehouse operator,
I want to confirm an outbound order with inventory check,
So that I can prevent shipping items that are out of stock.

Acceptance Criteria:
- GIVEN an order is in PENDING status
  WHEN operator clicks "Confirm"
  THEN system checks current inventory for each item
  AND IF any item is insufficient, show error with details
  AND IF all items sufficient, order moves to CONFIRMED status
```

**Ví dụ cần cải thiện:**

```
❌ As a user, I want a better experience when ordering.
(Quá mơ hồ, không có Acceptance Criteria, không testable)
```

---

### 2.3 Event Storming Notes

**Khi nào dùng:** Session tập thể (workshop) để khám phá domain phức tạp, đặc biệt hiệu quả khi domain chưa rõ ràng.

**Output của Event Storming:**

Ghi lại các **Domain Events** theo timeline:

```markdown
# Event Storming — [Domain/Module]
## Timeline Events (màu cam = event, màu xanh = command, màu vàng = actor)

1. [Actor: Customer] → PlaceOrder → [Event: OrderPlaced]
2. [Actor: System] → ValidateInventory → [Event: InventoryChecked]
3. [Event: InventoryChecked] → IF sufficient → [Event: OrderConfirmed]
                             → IF insufficient → [Event: OrderRejected]
4. [Event: OrderConfirmed] → TriggerPayment → [Event: PaymentRequested]
5. [Event: PaymentCompleted] → [Event: OrderReadyToShip]

## Hot Spots (❗ = điểm chưa rõ, cần confirm)
- ❗ Khi nào order có thể cancel sau khi đã confirm?
- ❗ Logic tính giá ship như thế nào nếu chia shipment?
- ❗ Refund policy khi payment đã được xử lý?
```

---

## 3. Câu hỏi khai thác domain (Domain Discovery Questions)

Dùng trong buổi phỏng vấn stakeholder hoặc workshop:

### Về Actor và Process
- Ai là người dùng chính? Phân biệt "người dùng" và "người ra quyết định"?
- Hiện tại, quy trình này đang được thực hiện như thế nào (trước khi có hệ thống)?
- Những bước nào đang làm manual mà muốn tự động hóa?

### Về Business Rules
- Khi nào [X] được phép? Khi nào không?
- Điều kiện nào cần thỏa mãn để [action] xảy ra?
- Ai có quyền approve/reject? Ngưỡng là gì?
- Ngoại lệ nào thường gặp? Xử lý thế nào?

### Về Data
- Thông tin nào là bắt buộc? Thông tin nào là optional?
- Dữ liệu đến từ đâu? Ai là owner?
- Dữ liệu lịch sử cần giữ bao lâu?

### Về Failure Scenarios
- Điều gì xảy ra khi [X] thất bại?
- Có SLA nào không? Timeout là bao lâu?
- Cần audit trail cho những hành động nào?

---

## 4. Checklist "Done" cho tầng Reality

Bước này coi là hoàn thành khi:

- [ ] Tất cả **business actor** đã được identify và mô tả
- [ ] Tất cả **business event chính** đã được list ra
- [ ] Tất cả **business rule cấp cao** đã được ghi, không còn "chúng tôi sẽ quyết định sau"
- [ ] **Out of scope** đã được xác định rõ
- [ ] Stakeholder đã **sign-off** (đồng ý) trên tài liệu
- [ ] **Hot spots** (điểm chưa rõ) đã được ghi nhận và assigned để giải quyết

---

## 5. Anti-patterns ở tầng Reality

| Anti-pattern | Dấu hiệu | Fix |
|-------------|---------|-----|
| **Giải pháp trong yêu cầu** | "Cần thêm nút X ở màn hình Y" thay vì mô tả business need | Hỏi: "Tại sao cần nút đó? Business problem là gì?" |
| **Undefined term** | Dùng từ như "order", "customer" mà không định nghĩa | Ghi ngay vào Glossary draft |
| **Missing actor** | Chỉ mô tả happy path, quên các actor thứ cấp | Hỏi: "Ai còn cần tương tác với quy trình này?" |
| **No failure path** | Chỉ mô tả "khi thành công" | Hỏi: "Điều gì xảy ra khi X thất bại?" |
| **Assumptions as facts** | Nói "đơn hàng phải có địa chỉ giao hàng" mà chưa confirm | Mark là assumption, confirm với stakeholder |

---

## 6. Handoff sang bước tiếp theo

Sau khi tầng Reality hoàn thành, **input** cho bước tiếp theo:

```
BRD + User Stories + Event Storming Notes
        ↓
→ 03-bounded-context.md (Identify Bounded Contexts)
```

**Những gì team Architect/Tech Lead cần từ tầng này:**
- Danh sách domain events → dùng để identify bounded context
- Danh sách business rule → dùng để viết constraint trong LinkML
- Danh sách actor → dùng để xác định role trong API Contract

---

*→ Bước tiếp theo: [`03-bounded-context.md`](./03-bounded-context.md)*
