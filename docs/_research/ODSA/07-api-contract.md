# API Contract — Từ Domain đến Interface

> **Vị trí trong pipeline:** Bước 6 — Sau Flow, trước Code  
> **Mục tiêu:** Define contract rõ ràng giữa Backend và Frontend/Consumer, derived từ domain

---

## 1. Vị trí API Contract trong pipeline

```
Domain (Glossary + LinkML + Flow)
           ↓
    API Contract (OpenAPI)  ← ĐÂY
           ↓
    ┌──────┴──────┐
Backend impl    Frontend (FSD)
```

### Tại sao KHÔNG define API quá sớm?

```
❌ BRD → API → Code
```
→ API bị "CRUD hóa": endpoint theo table name, không có business meaning  
→ API sai domain, FE và BE phải "dịch" nhiều

### Tại sao KHÔNG để API sau code?

```
❌ Domain → Code → API
```
→ API = phản ánh implementation, không phải design  
→ Khó align FE/BE, khó change sau này

### Vị trí đúng:

```
✅ Domain → API Contract → Code
```

> **API = projection của domain + behavior ra bên ngoài**

---

## 2. Nguyên tắc thiết kế API từ domain

### 2.1 Endpoint theo Use Case, không theo CRUD

| ❌ CRUD (không rõ intent) | ✅ Use Case (rõ intent) |
|--------------------------|------------------------|
| `POST /orders` | `POST /orders/place` |
| `PUT /orders/{id}` | `POST /orders/{id}/cancel` |
| `PUT /leave-requests/{id}` | `POST /leave-requests/{id}/approve` |
| `PUT /leave-requests/{id}` | `POST /leave-requests/{id}/reject` |

### 2.2 Naming từ Ubiquitous Language

Không tự đặt tên kỹ thuật — lấy thẳng từ Glossary:

```
Glossary term: "LeaveRequest"
API resource: /leave-requests (không phải /absences hay /time-off)

Glossary event: "PlaceOrder"
API endpoint: POST /orders/place (không phải /create-order hay /submit-order)
```

### 2.3 Request/Response structure từ LinkML

LinkML schema → JSON Schema → request/response body:

```yaml
# LinkML
classes:
  Order:
    attributes:
      customer_id:
        required: true
      line_items:
        multivalued: true
        minimum_cardinality: 1
```

```yaml
# OpenAPI request body
PlaceOrderRequest:
  type: object
  required:
    - customer_id
    - line_items
  properties:
    customer_id:
      type: string
    line_items:
      type: array
      minItems: 1
      items:
        $ref: '#/components/schemas/LineItemRequest'
```

---

## 3. Format chuẩn — OpenAPI 3.0

### 3.1 File structure

```
/ordering
  api.openapi.yaml      ← OpenAPI spec
```

### 3.2 Template OpenAPI cơ bản

```yaml
openapi: "3.0.3"

info:
  title: Ordering API
  description: |
    API cho Ordering Bounded Context.
    Derived từ: glossary.md, model.linkml.yaml, flows/
  version: "1.0.0"
  contact:
    name: Ordering Team
    email: ordering-team@example.com

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://api-staging.example.com/v1
    description: Staging

tags:
  - name: orders
    description: Order management operations

paths:
  /orders/place:
    post:
      summary: Place a new order
      description: |
        Customer confirm order từ Cart. 
        Derived từ flow: flows/place-order.md
      operationId: placeOrder
      tags: [orders]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/PlaceOrderRequest'
            example:
              customer_id: "cust-123"
              line_items:
                - product_id: "prod-456"
                  quantity: 2
                  unit_price: 150000
      responses:
        "201":
          description: Order created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/OrderResponse'
        "400":
          description: Invalid request (e.g., empty cart)
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
        "403":
          description: Customer is SUSPENDED
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
        "409":
          description: Inventory insufficient
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/InsufficientInventoryError'

  /orders/{orderId}/cancel:
    post:
      summary: Cancel an existing order
      operationId: cancelOrder
      tags: [orders]
      parameters:
        - name: orderId
          in: path
          required: true
          schema:
            type: string
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CancelOrderRequest'
      responses:
        "200":
          description: Order cancelled
        "404":
          description: Order not found
        "409":
          description: Order cannot be cancelled (wrong status)

components:
  schemas:
    PlaceOrderRequest:
      type: object
      required:
        - customer_id
        - line_items
      properties:
        customer_id:
          type: string
        line_items:
          type: array
          minItems: 1
          items:
            $ref: '#/components/schemas/LineItemRequest'

    LineItemRequest:
      type: object
      required:
        - product_id
        - quantity
        - unit_price
      properties:
        product_id:
          type: string
        quantity:
          type: integer
          minimum: 1
        unit_price:
          type: number
          format: decimal

    OrderResponse:
      type: object
      properties:
        id:
          type: string
        status:
          type: string
          enum: [PENDING, CONFIRMED, CANCELLED, COMPLETED]
        customer_id:
          type: string
        total_amount:
          type: number
        created_at:
          type: string
          format: date-time

    ErrorResponse:
      type: object
      required:
        - code
        - message
      properties:
        code:
          type: string
          description: Machine-readable error code (e.g., CUSTOMER_SUSPENDED)
        message:
          type: string
          description: Human-readable message
        details:
          type: object

    InsufficientInventoryError:
      allOf:
        - $ref: '#/components/schemas/ErrorResponse'
        - type: object
          properties:
            insufficient_items:
              type: array
              items:
                type: object
                properties:
                  product_id:
                    type: string
                  requested:
                    type: integer
                  available:
                    type: integer
```

---

## 4. Từ Flow → API Mapping

Cách derive endpoint từ flow document:

| Flow element | API element |
|-------------|------------|
| Use case name | `operationId` |
| Actor action | HTTP method + path |
| Precondition fail | 4xx error response |
| Happy path output | 2xx response schema (từ LinkML) |
| Error path | Specific error response schema |
| Domain event emitted | không trong API, nhưng ghi note |

---

## 5. Convention chuẩn

### HTTP Methods

| Action | Method | Ví dụ |
|--------|--------|-------|
| Create resource | POST | `POST /orders` |
| Execute use case | POST | `POST /orders/{id}/cancel` |
| Read resource | GET | `GET /orders/{id}` |
| List resources | GET | `GET /orders?status=PENDING` |
| Replace resource | PUT | `PUT /orders/{id}` (ít dùng) |
| Partial update | PATCH | `PATCH /orders/{id}` (ít dùng) |
| Delete | DELETE | `DELETE /orders/{id}` |

### Status Codes

| Situation | Code |
|-----------|------|
| Created | 201 |
| Success (no body) | 204 |
| Success (with body) | 200 |
| Bad request | 400 |
| Unauthorized | 401 |
| Forbidden (no permission) | 403 |
| Not found | 404 |
| Business rule conflict | 409 |
| Server error | 500 |

### Error Code convention

Dùng machine-readable code (uppercase snake_case):

```json
{
  "code": "CUSTOMER_SUSPENDED",
  "message": "Tài khoản của bạn đang bị tạm khóa",
  "details": { ... }
}
```

---

## 6. Checklist "Done" cho API Contract

- [ ] Mỗi use case trong Flow docs đều có ít nhất 1 endpoint
- [ ] Tên endpoint reflect use case intent (không CRUD thuần)
- [ ] Request body schema derived từ LinkML
- [ ] Error responses cover các error paths trong Flow
- [ ] `operationId` unique và descriptive
- [ ] Có ít nhất 1 example per endpoint
- [ ] FE tech lead đã review và confirm đủ dùng để mock
- [ ] BE tech lead đã confirm schema khả thi implement

---

*→ Bước tiếp theo: [`08-collaboration-guide.md`](./08-collaboration-guide.md) — Quy trình phối hợp team*
