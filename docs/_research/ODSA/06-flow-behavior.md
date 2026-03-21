# Flow & Behavior — Use Case Flow Document

> **Vị trí trong pipeline:** Bước 5 — Sau LinkML (structure), trước API Contract  
> **Mục tiêu:** Mô tả BEHAVIOR của domain — cái gì xảy ra, theo thứ tự nào, khi nào

---

## 1. Tại sao Flow là "động từ" của domain?

> LinkML = "danh từ" (entity là gì, có gì)  
> Flow = "động từ" (entity làm gì, tương tác thế nào)

| | LinkML | Flow |
|-|--------|------|
| **Mô tả** | Cấu trúc tĩnh | Hành vi động |
| **Ví dụ** | `Order` có trường `status` | "Khi user place order, status chuyển sang PENDING" |
| **Kiểu tài liệu** | Schema file (YAML) | Narrative + diagram |
| **Tool** | YAML editor | Markdown + Mermaid |

---

## 2. Scope: 1 Flow = 1 Use Case

> Mỗi use case quan trọng có 1 flow document riêng.

```
/ordering/flows/
  place-order.md        ← 1 use case = 1 file
  cancel-order.md
  update-order.md
/payment/flows/
  process-payment.md
  refund.md
```

**Khi nào cần viết flow:**
- Happy path của use case chính ✅ (bắt buộc)
- Error paths quan trọng ✅ (bắt buộc)
- Background process / scheduled job ✅ (khi phức tạp)
- Simple CRUD (chỉ create/read/update field đơn giản) ❌ (không cần thiết)

---

## 3. Format chuẩn của Flow Document

### Cấu trúc file

```markdown
# Flow: [Use Case Name]

> Context: [Bounded Context]  
> Actor: [Người khởi động flow]  
> Trigger: [Điều kiện trigger]

## Preconditions
- [Điều kiện phải đúng trước khi flow bắt đầu]
- [...]

## Happy Path

### Steps
1. [Actor] [action]
2. System [response]
3. ...

### Sequence Diagram
[Mermaid sequenceDiagram]

## Error Paths

### Case: [Tên error case]
**Điều kiện:** [Khi nào xảy ra]  
**Xử lý:** [System làm gì]

## Postconditions
- [Trạng thái sau khi flow hoàn thành thành công]
- [Business rule nào được enforce]

## Business Rules áp dụng
- BR-001: [Rule]
- [...]
```

---

## 4. Ví dụ hoàn chỉnh — Place Order Flow

```markdown
# Flow: Place Order

> Context: Ordering  
> Actor: Customer  
> Trigger: Customer bấm "Confirm Order" trên checkout page

## Preconditions
- Customer đã đăng nhập (có valid session)
- Cart có ít nhất 1 item
- Customer không có status SUSPENDED

## Happy Path

### Steps
1. Customer confirm order từ Cart
2. System validate cart (items còn hàng, giá còn đúng)
3. System validate customer (không bị SUSPENDED)
4. System tạo Order với status PENDING
5. System publish event `OrderPlaced`
6. Payment Context nhận event, bắt đầu xử lý payment
7. Payment success → System update Order status → CONFIRMED
8. System publish event `OrderConfirmed`
9. Shipping Context nhận `OrderConfirmed`, tạo ShippingOrder
10. System hiển thị order confirmation cho Customer

### Sequence Diagram

sequenceDiagram
    actor C as Customer
    participant OrchestratorSvc as OrderService
    participant InventorySvc as InventoryService
    participant PaymentCtx as Payment Context
    participant ShippingCtx as Shipping Context

    C->>OrchestratorSvc: PlaceOrder(cartId, customerId)
    OrchestratorSvc->>InventorySvc: checkInventory(items)
    InventorySvc-->>OrchestratorSvc: OK (all items available)
    OrchestratorSvc->>OrchestratorSvc: createOrder(status=PENDING)
    OrchestratorSvc->>PaymentCtx: publish OrderPlaced event
    PaymentCtx->>PaymentCtx: processPayment()
    PaymentCtx-->>OrchestratorSvc: PaymentCompleted event
    OrchestratorSvc->>OrchestratorSvc: updateOrder(status=CONFIRMED)
    OrchestratorSvc->>ShippingCtx: publish OrderConfirmed event
    ShippingCtx->>ShippingCtx: createShippingOrder()
    OrchestratorSvc-->>C: Order Confirmation

## Error Paths

### Case: Inventory insufficient
**Điều kiện:** Một hoặc nhiều item trong cart không đủ tồn kho  
**Xử lý:**
- System trả về danh sách item thiếu hàng
- Order KHÔNG được tạo
- Customer thấy thông báo với tên item cụ thể

### Case: Customer suspended
**Điều kiện:** Customer có status = SUSPENDED  
**Xử lý:**
- System từ chối ngay, không check inventory
- Hiển thị thông báo "Account tạm khóa"
- Log security event

### Case: Payment failed
**Điều kiện:** Payment service trả về failure  
**Xử lý:**
- Order vẫn tồn tại với status PENDING
- System retry theo Retry Policy (xem Payment Context)
- Sau max retry: Order chuyển sang PAYMENT_FAILED
- Customer nhận notification

## Postconditions (Happy Path)
- Order tồn tại với status = CONFIRMED
- Inventory đã được reserved
- ShippingOrder đã được tạo trong Shipping Context
- Customer nhận email confirmation

## Business Rules áp dụng
- BR-ORD-001: Order phải có ít nhất 1 line item
- BR-ORD-002: Customer SUSPENDED không thể đặt hàng
- BR-ORD-003: Inventory phải được check trước khi tạo Order
- BR-ORD-004: Order chỉ CONFIRMED khi payment thành công
```

---

## 5. Tips viết Sequence Diagram tốt

### 5.1 Participants

```
actor U as User (người — dùng actor)
participant S as ServiceName
participant DB as Database
```

### 5.2 Message types

```
->> : request (sync call)
-->> : response
-)  : async/event (fire and forget)
```

### 5.3 Loops và Conditions

```
sequenceDiagram
    loop retry 3 times
        S->>Payment: processPayment()
        Payment-->>S: failed
    end

    alt payment success
        S->>DB: updateOrder(CONFIRMED)
    else payment failed
        S->>DB: updateOrder(PAYMENT_FAILED)
    end
```

### 5.4 Giữ diagram tập trung

- **Không quá 5-7 participants** trong 1 diagram
- Nếu flow phức tạp → tách thành sub-flow documents
- **Diagram = bức tranh tổng, Steps = chi tiết**

---

## 6. Flow tối giản (Pragmatic)

Nếu không muốn vẽ sequence diagram, **bullet steps đã đủ tốt** cho hầu hết use case:

```markdown
# Flow: Approve Leave Request (Tối giản)

**Actor:** Manager  
**Trigger:** Manager review LeaveRequest của nhân viên

### Steps
1. Manager mở danh sách LeaveRequest pending
2. Manager chọn 1 request, xem chi tiết
3. Manager click "Approve"
4. System check: manager có quyền approve cho nhân viên này không
5. System check: LeaveBalance của nhân viên đủ không
6. IF OK: LeaveRequest → status APPROVED, trừ LeaveBalance
7. System gửi notification cho nhân viên
8. IF BAD: hiện error message cụ thể

### Error: Insufficient balance
- Hiển thị: "Nhân viên chỉ còn X ngày phép, request cần Y ngày"
- Không block manager, chỉ cảnh báo (Manager có thể override nếu có quyền)
```

---

## 7. Checklist "Done" cho Flow

- [ ] Happy path đã được document đầy đủ
- [ ] Ít nhất 2-3 error paths quan trọng đã được document
- [ ] Sequence diagram (hoặc bullet steps tối giản) tồn tại
- [ ] Preconditions và Postconditions đã được ghi
- [ ] Business rules áp dụng đã được reference
- [ ] Actor và trigger rõ ràng

---

## 8. Từ Flow → derive API Contract

Flow document là **input trực tiếp** để derive API Contract:

```
Flow step: "Customer confirm order từ Cart"
→ API endpoint: POST /orders/place
→ Request body: { cartId, customerId }
→ Response: { orderId, status: "PENDING" }

Flow step: "Manager approve LeaveRequest"
→ API endpoint: POST /leave-requests/{id}/approve
→ Response: { status: "APPROVED", remainingBalance: X }
```

> Tên endpoint nên phản ánh **use case intent**, không phải CRUD:
> - ✅ `POST /orders/place`
> - ✅ `POST /orders/{id}/cancel`
> - ❌ `POST /orders` (quá generic)
> - ❌ `PUT /orders/{id}` (không rõ intent)

---

*→ Bước tiếp theo: [`07-api-contract.md`](./07-api-contract.md) — Derive API Contract từ Flow + LinkML*
