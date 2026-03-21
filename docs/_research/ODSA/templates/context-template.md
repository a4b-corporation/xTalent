# Context Definition Template

> **Hướng dẫn:** Copy file này vào `/<context-name>/_context.md`

---

# Context: [Context Name]

> **Owner Team:** [Team Name]  
> **Tech Lead:** [Name]  
> **Status:** DRAFT | APPROVED  
> **Last updated:** YYYY-MM-DD

---

## Trách nhiệm

> Những gì context này CHỊU TRÁCH NHIỆM quản lý và xử lý.

- [Responsibility 1]
- [Responsibility 2]
- [...]

## KHÔNG chịu trách nhiệm

> Rõ ràng những gì thuộc context khác — tránh scope creep.

- [Out of scope 1] → thuộc [Other Context]
- [Out of scope 2] → thuộc [Other Context]

---

## Core Entities trong Context này

| Entity | Định nghĩa trong context này | Khác với context khác |
|--------|----------------------------|-----------------------|
| [EntityName] | [Definition] | [Cùng tên nhưng khác ở context X] |

---

## Integration Points

### Nhận từ context khác

| Từ Context | Event/Data | Mục đích |
|-----------|-----------|---------|
| [Context Name] | [Event: EventName] | [Tại sao cần] |
| [Context Name] | [API call: endpoint] | [Tại sao cần] |

### Gửi đến context khác

| Đến Context | Event/Data | Mô tả |
|------------|-----------|-------|
| [Context Name] | [Event: EventName] | [Mô tả] |

### Anti-Corruption Layer (ACL)

> Nếu context này cần "dịch" model của upstream để tránh "ô nhiễm" domain:

- [ ] Không cần ACL (direct use)
- [ ] Cần ACL khi nhận data từ: [Context X] — vì: [Lý do]

---

## Key Business Rules

> Business rules quan trọng nhất của context này (tóm tắt, chi tiết xem Glossary).

1. [Rule 1]
2. [Rule 2]

---

## Tech Stack (Nếu applicable)

- **Language:** [e.g., Java/Spring, Node.js, Python]
- **Database:** [e.g., PostgreSQL, MongoDB]
- **Message broker:** [e.g., Kafka, RabbitMQ]
- **Deploy:** [e.g., Kubernetes, Docker]

---

## Tài liệu liên quan

- [Glossary](./glossary.md)
- [Schema](./model.linkml.yaml)
- [API Contract](./api.openapi.yaml)
- [Flows](./flows/)
