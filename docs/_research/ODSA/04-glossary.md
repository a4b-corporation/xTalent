# Glossary — Ubiquitous Language (Ngôn ngữ chung)

> **Vị trí trong pipeline:** Bước 3 — Sau khi identify Bounded Context  
> **Mục tiêu:** Đảm bảo tất cả member trong team hiểu GIỐNG NHAU về từng khái niệm trong domain

---

## 1. Tại sao Glossary là artifact quan trọng nhất?

> "80% bug không phải do code sai, mà do người viết code hiểu khác người viết spec."

**Ví dụ thực tế về mơ hồ ngôn ngữ:**

| Người nói | "Order" nghĩa là |
|-----------|-----------------|
| BA | Khi customer bấm "Đặt hàng" trên app |
| Dev Ordering | Object Order trong database, kể cả draft |
| Dev Shipping | Yêu cầu giao hàng đã được confirm |
| Kế toán | Hóa đơn đã thanh toán |

→ Kết quả: 4 người cùng họp, nói "Order" nhưng nghĩ 4 thứ khác nhau.

**Glossary là "từ điển đồng thuận"** — mọi người ký tên (metaphorically) là đã đồng ý dùng term theo nghĩa này.

---

## 2. Nguyên tắc viết Glossary

### 2.1 Scoped theo Bounded Context

> **1 term = 1 meaning TRONG MỖI CONTEXT**  
> Cùng 1 term có thể có nghĩa khác ở context khác — đó là chuyện bình thường.

```markdown
# Glossary — Ordering Context

| Term | Định nghĩa | Khác với |
|------|-----------|---------|
| Order | Đơn hàng đã được customer xác nhận (bấm Confirm). Luôn có ít nhất 1 line item. | Cart (chưa confirm), ShippingOrder (trong Shipping context) |
```

### 2.2 Phân biệt term vs term khác

Với mỗi term, luôn hỏi: "Cái này khác với X như thế nào?"

Ví dụ:
- `Order` ≠ `Cart` (Cart chưa checkout)
- `Order` ≠ `Invoice` (Invoice là document kế toán)
- `Customer` ≠ `User` (User có thể là guest, Customer phải registered)

### 2.3 Ghi trạng thái (status lifecycle)

Với các entity có nhiều trạng thái, ghi rõ lifecycle:

```
Order status:
DRAFT → PENDING → CONFIRMED → SHIPPED → DELIVERED
                 → CANCELLED (từ PENDING hoặc CONFIRMED)
```

---

## 3. Format chuẩn

### 3.1 File Glossary cơ bản

```markdown
# Glossary — [Context Name]

> Scope: [Tên bounded context]  
> Last updated: [Date]  
> Owners: [Team/Names]

---

## Entities (Danh từ)

| Term | Định nghĩa | Khác với | Trạng thái |
|------|-----------|---------|-----------|
| Order | Đơn hàng đã được customer xác nhận... | Cart (chưa confirm) | PENDING, CONFIRMED, CANCELLED, COMPLETED |
| LineItem | Một mặt hàng trong Order, có quantity và unit price | CartItem | — |
| Customer | Người dùng đã đăng ký tài khoản và có thể đặt hàng | Guest User | ACTIVE, SUSPENDED, INACTIVE |

## Events (Động từ — những gì đã xảy ra)

| Event | Khi nào xảy ra | Ai trigger |
|-------|---------------|----------|
| OrderPlaced | Customer bấm "Confirm Order" | Customer |
| OrderCancelled | Customer hoặc admin cancel | Customer / Admin |
| PaymentReceived | Payment service confirm thanh toán thành công | Payment Context |

## Commands (Lệnh — những gì được yêu cầu)

| Command | Nghĩa là | Actor |
|---------|---------|-------|
| PlaceOrder | Yêu cầu tạo và confirm một đơn hàng | Customer |
| CancelOrder | Yêu cầu hủy đơn hàng | Customer / Admin |

## Business Rules (Quy tắc nghiệp vụ quan trọng)

- Order phải có ít nhất 1 LineItem
- Order chỉ có thể cancel khi ở trạng thái PENDING hoặc CONFIRMED
- Customer bị SUSPENDED không thể PlaceOrder
```

---

### 3.2 Ví dụ Glossary hoàn chỉnh — Leave & Absence Context (HCM)

```markdown
# Glossary — Leave & Absence Context

> Scope: Quản lý nghỉ phép và vắng mặt của nhân viên  
> Last updated: 2026-03-20

## Entities

| Term | Định nghĩa | Khác với |
|------|-----------|---------|
| LeaveRequest | Yêu cầu nghỉ phép do nhân viên tạo, chờ duyệt | Leave (trạng thái đã được approve) |
| Leave | Nghỉ phép đã được approve và ghi nhận | LeaveRequest (còn đang xử lý) |
| LeaveType | Loại nghỉ phép: Annual, Sick, Maternity... | — |
| LeaveBalance | Số ngày phép còn lại của nhân viên theo từng LeaveType | — |
| Absence | Ngày nhân viên vắng mặt không có LeaveRequest hợp lệ | Leave (có phép), Unauthorized |

## Events

| Event | Khi nào |
|-------|---------|
| LeaveRequested | Nhân viên submit LeaveRequest |
| LeaveApproved | Manager approve LeaveRequest |
| LeaveRejected | Manager reject LeaveRequest |
| BalanceAdjusted | Admin điều chỉnh số ngày phép thủ công |
| AbsenceDetected | System phát hiện nhân viên vắng không có phép |

## Business Rules

- Nhân viên không thể request Leave nếu LeaveBalance < 0 (trừ một số LeaveType đặc biệt)
- LeaveRequest cần approve trong vòng 3 ngày làm việc
- Annual Leave chỉ tích lũy sau khi qua thử việc
- Sick Leave không cần prove trước, nhưng cần medical certificate nếu > 3 ngày liên tiếp
```

---

## 4. Quy trình viết và review Glossary

### Bước 1: Draft (BA viết)

BA draft Glossary dựa trên BRD và phỏng vấn stakeholder. Mỗi term cần ít nhất:
- Định nghĩa rõ ràng (1-2 câu)
- Phân biệt với term gần giống

### Bước 2: Review chéo (Dev + BA)

Dev đọc và mark những điểm chưa rõ bằng `❓`:

```markdown
| Customer | Người đã đăng ký... | User | ACTIVE, SUSPENDED |
| ❓ Guest | Chưa rõ: Guest có thể đặt hàng không? | Customer | — |
```

### Bước 3: Confirm với Stakeholder

Những điểm `❓` cần confirm với stakeholder hoặc PO.

### Bước 4: Sign-off

Cả BA và Tech Lead đồng ý → remove `❓`, file được coi là "approved".

---

## 5. Duy trì Glossary theo thời gian

**Ai update:**
- BA khi có yêu cầu mới
- Dev khi phát hiện term trong code không khớp glossary
- QA khi viết test case thấy ambiguity

**Khi nào update:**
- Khi requirements thay đổi có ảnh hưởng đến meaning
- Khi brainstorm session produce term mới
- Khi refactoring phát hiện term sai

**Quy tắc:** Nếu term đã thay đổi → check ngay xem LinkML và code còn sync không.

---

## 6. Checklist "Done" cho Glossary

- [ ] Tất cả entity trong domain đã có definition
- [ ] Tất cả event chính trong Event Storming đã được glossary hóa
- [ ] Mỗi term quan trọng có phần "Khác với" rõ ràng
- [ ] Business rule quan trọng đã được ghi
- [ ] Không còn `❓` unresolved
- [ ] BA và Tech Lead đã ký off

---

*→ Bước tiếp theo: [`05-ontology-linkml.md`](./05-ontology-linkml.md) — Schema hóa entities bằng LinkML*
