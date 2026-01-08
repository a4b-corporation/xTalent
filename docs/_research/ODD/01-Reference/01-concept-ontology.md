# 01. Ontology Concept (THE WHAT)

> [!NOTE]
> **Goal**: Explain the basic concepts of Ontology in the context of Data Science and Software Engineering, independent of specific implementations.

This document explains the fundamental concepts of **Ontology** within the context of Data Science and Software Engineering, separated from specific implementations (such as Palantir).

## 1. What is Ontology?

In computer and information science, an **Ontology** is a formal way to represent knowledge as a set of concepts within a domain and the relationships between them.

Unlike a **Database Schema**, which focuses on efficient data storage (rows, columns, foreign keys, indexes), an **Ontology** focuses on the **Meaning** (Semantics) and **Context** of that data relative to the real world.

### Core Differences

| Feature | Database Schema (RDBMS) | Ontology (Semantic Layer) |
| :--- | :--- | :--- |
| **Base Unit** | Table, Row, Column | Object (Entity), Property, Link |
| **Goal** | Optimize storage, data integrity (ACID) | Optimize human and machine understanding |
| **Relationship** | Foreign Key (JOIN) - technical | Relationship/Link - semantic |
| **Perspective** | "What does the data look like on disk?" | "What is this entity in the real world?" |

## 2. Core Components of Ontology

An Ontology system is typically built on three main pillars (often called the **Object-Property-Link** triad):

### 2.1 Objects (Entities)
These are the "Nouns" of the system. An Object represents a physical object, person, or concept in the real world.
*   **Examples:** `Employee`, `Flight`, `Ticket`, `Incident`.
*   **Note:** An Object can be aggregated from multiple different data tables. For example, an `Employee` Object might pull basic info from an `HR_PROFILE` table and salary info from a `PAYROLL` table.

### 2.2 Properties (Attributes)
These are characteristics that describe an Object.
*   **Examples:** The `Employee` Object has properties: `Name`, `Employee ID`, `Start Date`, `Role`.
*   Properties are not just text/number values but can also include metadata about status or data reliability.

### 2.3 Links (Relationships)
These are meaningful connections between Objects. In an Ontology, a Link is a "First-class citizen," equal in importance to an Object.
*   **Examples:**
    *   `Employee` *works for* `Department`.
    *   `Plane` *flights on* `Route`.
    *   `Customer` *filed* `Complaint`.
*   Unlike a `JOIN` in SQL (which is an expensive query-time operation), Links in an Ontology are often modeled as a **Graph**, allowing for very fast and intuitive traversal.

## 3. The Semantic Layer

The **Semantic Layer** is an abstraction layer residing between **Raw Data** (Data Lake, DB) and **Users/Applications**.

```mermaid
graph TD
    User[Users / Apps] <--> Semantic[Ontology / Semantic Layer]
    Semantic <--> Chaos[Raw Data / Databases / APIs]
```

Roles of the Semantic Layer:
1.  **Translation:** Translating from technical language (`SELECT * FROM tbl_usr_01`) to business language (`Get Employee "John Doe"`).
2.  **Unification:** Presenting a single Object even if data is scattered across 5 different systems (ERP, CRM, HRIS...).
3.  **Context:** Providing additional meaning to data. For example: The number `10,000,000` is not just a number, but is defined as the `Base Salary` of this `Employee`.

## Conclusion

Ontology is not a new storage technology meant to replace Databases. It is a **Modeling Layer** that sits on top, helping transform "Inert Data" into "Actionable Knowledge."

## Related Documents
- **Next**: [Palantir Foundry Case Study](./02-case-study-palantir-foundry.md)
- **Strategic Value**: [Why Ontology Matters](./03-strategic-value.md)
- **Our Solution**: [Ontology-Driven Development](../03-Solution/07-concept-odd.md)

---

# 01. Ontology Concept (THE WHAT) (Vietnamese Original)

> [!NOTE]
> **Mục tiêu**: Giải thích các khái niệm cơ bản về Ontology trong bối cảnh Khoa học Dữ liệu và Kỹ thuật Phần mềm, tách biệt khỏi các triển khai cụ thể.

Tài liệu này giải thích các khái niệm cơ bản về **Ontology** trong bối cảnh Khoa học Dữ liệu và Kỹ thuật Phần mềm, tách biệt khỏi các triển khai cụ thể (như Palantir).

## 1. Ontology là gì?

Trong khoa học máy tính và thông tin, **Ontology** (Bản thể học) là một cách chính thức để biểu diễn tri thức như một tập hợp các khái niệm trong một miền (domain) và các mối quan hệ giữa chúng.

Khác với **Database Schema** (Lược đồ cơ sở dữ liệu) tập trung vào việc lưu trữ dữ liệu hiệu quả (hàng, cột, khóa ngoại, chỉ mục), **Ontology** tập trung vào **Ý nghĩa** (Semantics) và **Ngữ cảnh** (Context) của dữ liệu đó đối với thế giới thực.

### Sự khác biệt cốt lõi

| Đặc điểm | Database Schema (RDBMS) | Ontology (Semantic Layer) |
| :--- | :--- | :--- |
| **Đơn vị cơ sở** | Table, Row, Column | Object (Entity), Property, Link |
| **Mục tiêu** | Tối ưu hóa lưu trữ, tính toàn vẹn dữ liệu (ACID) | Tối ưu hóa sự hiểu biết của con người và máy móc |
| **Mối quan hệ** | Foreign Key (JOIN) - mang tính kỹ thuật | Relationship/Link - mang tính ý nghĩa (Semantic) |
| **Góc nhìn** | "Dữ liệu trông như thế nào khi lưu vào đĩa?" | "Thực thể này là gì trong thế giới thực?" |

## 2. Các thành phần cốt lõi của Ontology

Một hệ thống Ontology thường được xây dựng dựa trên ba trụ cột chính (thường được gọi là bộ ba **Object-Property-Link**):

### 2.1 Objects (Entities) - Thực thể
Đây là các "Danh từ" của hệ thống. Object đại diện cho một vật thể, con người, hoặc khái niệm trong thế giới thực.
*   **Ví dụ:** `Employee` (Nhân viên), `Flight` (Chuyến bay), `Ticket` (Vé), `Incident` (Sự cố).
*   **Lưu ý:** Một Object có thể được tổng hợp (aggregate) từ nhiều bảng dữ liệu khác nhau. Ví dụ, Object `Employee` có thể lấy thông tin cơ bản từ bảng `HR_PROFILE` và thông tin lương từ bảng `PAYROLL`.

### 2.2 Properties (Attributes) - Thuộc tính
Đây là các đặc điểm mô tả Object.
*   **Ví dụ:** Object `Employee` có các properties: `Name`, `Employee ID`, `Start Date`, `Role`.
*   Properties không chỉ là giá trị text/number mà còn có thể là metadata về trạng thái, độ tin cậy của dữ liệu.

### 2.3 Links (Relationships) - Mối quan hệ
Đây là các kết nối có ý nghĩa giữa các Objects. Trong Ontology, Link là "First-class citizen" (công dân hạng nhất), quan trọng ngang hàng với Object.
*   **Ví dụ:**
    *   `Employee` *works for* `Department`.
    *   `Plane` *flights on* `Route`.
    *   `Customer` *filed* `Complaint`.
*   Khác với `JOIN` trong SQL (vốn là một thao tác tốn kém khi truy vấn), Links trong Ontology thường được mô hình hóa dưới dạng một **Graph** (Đồ thị), cho phép duyệt (traverse) rất nhanh và trực quan.

## 3. The Semantic Layer (Lớp ngữ nghĩa)

**Semantic Layer** là lớp trừu tượng nằm giữa **Dữ liệu thô** (Data Lake, DB) và **Người dùng/Ứng dụng**.

```mermaid
graph TD
    User[Users / Apps] <--> Semantic[Ontology / Semantic Layer]
    Semantic <--> Chaos[Raw Data / Databases / APIs]
```

Vai trò của Semantic Layer:
1.  **Translation (Dịch thuật):** Dịch từ ngôn ngữ kỹ thuật (`SELECT * FROM tbl_usr_01`) sang ngôn ngữ nghiệp vụ (`Get Employee "Nguyen Van A"`).
2.  **Unification (Hợp nhất):** Nhìn thấy một Object duy nhất dù dữ liệu nằm rải rác ở 5 hệ thống khác nhau (ERP, CRM, HRIS...).
3.  **Context (Ngữ cảnh):** Cung cấp thêm ý nghĩa cho dữ liệu. Ví dụ: Số `10,000,000` không chỉ là một con số, mà được định nghĩa là `Base Salary` (Lương cơ bản) của `Employee` này.

## Kết luận

Ontology không phải là một công nghệ lưu trữ mới thay thế Database. Nó là một **lớp mô hình hóa** (Modeling Layer) nằm bên trên, giúp biến đổi "Dữ liệu vô tri" thành "Tri thức có thể hành động" (Actionable Knowledge).

## Related Documents
- **Next**: [Palantir Foundry Case Study](./02-case-study-palantir-foundry.md)
- **Strategic Value**: [Why Ontology Matters](./03-strategic-value.md)
- **Our Solution**: [Ontology-Driven Development](../03-Solution/07-concept-odd.md)

