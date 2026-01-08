# 05. Project-Based Workflows Analysis

> [!NOTE]
> **Goal**: Analyze the project-based development model (Outsourcing, Client Projects) with the process of transferring ideas from "Client" to "Execution Team" through a dense chain of documents (BRD -> SRS -> Code).

## 1. Overview: The Waterfall V-Model

This model often follows a Waterfall or V-Model structure, even when teams claim to be Agile.

```mermaid
graph TD
    subgraph "Left Side: Specification"
        A[User Stories] --> B[BRD<br/>Business Requirements]
        B --> C[SRS<br/>Software Requirements]
        C --> D[FSD<br/>Functional Spec]
        D --> E[TDD<br/>Technical Design]
    end
    
    subgraph "Bottom: Implementation"
        E --> F[Code Implementation]
    end
    
    subgraph "Right Side: Verification"
        F --> G[Unit Testing]
        G --> H[Integration Testing]
        H --> I[System Testing]
        I --> J[UAT<br/>User Acceptance]
    end
    
    style C fill:#FFD700
    style F fill:#90EE90
```

---

## 2. The Standard Workflow

### Step 1: User Stories / Requirements Gathering
*   **Input:** Client says, "I want to manage human resources."
*   **Activity:** Business Analyst (BA) interviews and takes notes.
*   **Output:** **User Stories** 
    ```
    As an HR manager, I want to view a list of employees 
    so that I can manage their basic information.
    ```

### Step 2: BRD (Business Requirement Document)
*   **Goal:** Define the **WHAT** at a business level.
*   **Content:** 
    *   Project Scope
    *   Business Goals
    *   Business Flows
    *   Constraints
*   **Audience:** Stakeholders, Project Managers

### Step 3: SRS (Software Requirements Specification) - "The Project Bible"

> [!IMPORTANT]
> The **SRS** is the most critical document, often used for contract signing (Sign-off). Any subsequent changes must go through a costly Change Request (CR) process.

*   **Goal:** Transform Business requirements into **System Requirements**.
*   **Content:**
    *   **Functional Requirements (FR)**: What the system must do (Input, Output, Validation).
    *   **Non-Functional Requirements (NFR)**: Performance, Security, Scalability.
    *   **Use Cases**: Detailed with flow diagrams.

**Example SRS Section:**
```
FR-001: Employee List Display
- The system SHALL display a paginated list of employees.
- Each row SHALL show: ID, Name, Department, Status.
- Default page size: 20 items.
- Response time: < 2 seconds for 10,000 records.
```

### Step 4: FSD (Functional Specification Document) & Design
*   **Goal:** Define the **HOW** at an interface and behavioral level.
*   **Content:** 
    *   Wireframes, Mockups
    *   Screen Flows
    *   Detailed logic for every button

### Step 5: TDD (Technical Design Document)
*   **Goal:** For Developers.
*   **Content:** 
    *   Database Schema (ERD)
    *   API Specification (Swagger/OpenAPI)
    *   Class Diagrams, Sequence Diagrams

---

## 3. Pain Points: "Paperwork Paralysis"

Although the above process looks rigorous, actual implementation often faces numerous issues:

```mermaid
mindmap
  root((Paperwork<br/>Paralysis))
    Lost in Translation
      Ambiguous Language
      Misinterpretation
    Frozen Spec
      Market Changes
      Spec Outdated
    Documentation Burden
      Time Waste
      Nobody Reads
    Lack of Traceability
      Code-Spec Gap
      Impact Unknown
```

### 3.1 The "Lost in Translation" Gap

> [!WARNING]
> Natural languages (Vietnamese/English) are highly ambiguous. A statement like "The system must be fast" can be interpreted in 10 different ways.

**Real-world Example:**
```
BRD: "System must be fast"
↓ (BA interprets)
SRS: "Response time < 3 seconds"
↓ (Dev interprets)
Code: setTimeout(() => showLoader(), 3000) // Wrong!
```

*   From **BRD** to **SRS**: BA misunderstands the Client.
*   From **SRS** to **Code**: Dev misunderstands the BA.
*   **Result**: The final product deviates completely from initial expectations.

### 3.2 The "Frozen Spec" Fallacy

*   **Reality:** Projects often require a Sign-off on the SRS at the beginning (Month 1).
*   **Issue:** When Devs start coding (Month 3), they discover:
    *   Logic in the SRS is impossible.
    *   Critical omissions.
    *   The market has changed (competitors released new features).

*   **Consequences:**
    *   **Option 1**: Implement it wrongly (to match the signed Spec) → Useless product.
    *   **Option 2**: Submit a Change Request (CR) → Costly, time-consuming, erodes trust.
    *   **Option 3**: Code differently but don't update the Spec → Useless documentation.

**Timeline Example:**
```
Month 1: SRS signed (Feature A, B, C)
Month 3: Dev starts, discovers Feature B is impossible
Month 4: CR submitted, waiting for approval
Month 5: CR rejected (out of budget)
Month 6: Delivery without Feature B, customer is angry
```

### 3.3 Documentation vs. Delivery

*   Teams spend too much time writing and formatting documents just to "get paid" by the client.
*   Documents are often too long (hundreds of pages); no one (including Devs) has the patience to read them all.
*   They rely on verbal questions or guesswork instead.

**Statistics (from experience):**
- 📄 Average SRS length: 150-300 pages
- 👀 Percentage actually read: < 20%
- ⏱️ Time spent writing: 2-4 weeks
- 🔄 Time spent updating: 0 (never updated)

### 3.4 Lack of Traceability

**Typical conversation:**
```
Customer: "Why does this screen have this button?"
Dev: "I saw it in the Design."
Designer: "I saw it in the SRS."
BA: "I don't remember; maybe a client said it during a meeting."
```

> [!CAUTION]
> **Severe Issue**: There is no direct link (Traceability) from Code → Design → Requirement → Original Business Goal. When a Requirement changes, it's unknown which lines of code need adjustment.

---

## 4. Real-world Example: E-commerce Project Failure

**Case Study:**
```
Project: Build e-commerce platform
Timeline: 12 months
Budget: $500K

Month 1-2: Write BRD, SRS (200 pages)
Month 3-4: Design UI/UX
Month 5-10: Development
Month 11: Testing discovers: Payment gateway integration 
          was never specified in SRS
Month 12: Rush to add feature, bugs everywhere
Result: Launch delayed 6 months, over budget by $200K
```

**Root Cause:** The SRS was "frozen" in Month 2, with no mechanism to evolve it alongside the project.

---

## 5. Key Takeaways

- 📝 **Heavy Documentation ≠ Clear Communication**: A 200-page SRS does not guarantee a shared understanding.
- 🧊 **Frozen Specs are Fiction**: Markets change, and requirements must change accordingly.
- 🔗 **Traceability is Critical**: A link is needed from Code → Requirement → Business Goal.
- ⚖️ **Balance Needed**: Between Rigor and Agility.

> [!NOTE]
> **The Big Question**: Is there a way for specifications to become "Living Documentation" that is tightly integrated with the Code? → See [The Living Spec](../03-Solution/08-the-living-spec.md)

## Related Documents
- **Previous**: [Product Development Models](./04-product-development-pain-points.md)
- **Next**: [AI Era Challenges](./06-ai-era-challenges.md)
- **Solution**: [The Living Spec](../03-Solution/08-the-living-spec.md)

---

# 05. Phân tích Quy trình Dự án (Project-Based Workflows) (Vietnamese Original)

> [!NOTE]
> **Mục tiêu**: Phân tích mô hình phát triển theo Dự án (Outsourcing, Client Projects) với quy trình chuyển giao ý tưởng từ "Khách hàng" sang "Đội ngũ thực thi" thông qua chuỗi tài liệu dày đặc (BRD -> SRS -> Code).

## 1. Overview: The Waterfall V-Model

Mô hình này thường đi theo dạng thác nước (Waterfall) hoặc V-Model, ngay cả khi team tuyên bố họ làm Agile.

```mermaid
graph TD
    subgraph "Left Side: Specification"
        A[User Stories] --> B[BRD<br/>Business Requirements]
        B --> C[SRS<br/>Software Requirements]
        C --> D[FSD<br/>Functional Spec]
        D --> E[TDD<br/>Technical Design]
    end
    
    subgraph "Bottom: Implementation"
        E --> F[Code Implementation]
    end
    
    subgraph "Right Side: Verification"
        F --> G[Unit Testing]
        G --> H[Integration Testing]
        H --> I[System Testing]
        I --> J[UAT<br/>User Acceptance]
    end
    
    style C fill:#FFD700
    style F fill:#90EE90
```

---

## 2. The Standard Workflow (Quy trình chuẩn)

### Step 1: User Stories / Requirements Gathering
*   **Input:** Khách hàng nói "Tôi muốn quản lý nhân sự".
*   **Activity:** Business Analyst (BA) phỏng vấn, ghi chép.
*   **Output:** **User Stories** 
    ```
    Là HR manager, tôi muốn xem danh sách nhân viên 
    để có thể quản lý thông tin cơ bản của họ.
    ```

### Step 2: BRD (Business Requirement Document)
*   **Mục tiêu:** Định nghĩa cái **WHAT** (Cái gì) ở mức độ kinh doanh.
*   **Nội dung:** 
    *   Phạm vi dự án (Scope)
    *   Mục tiêu kinh doanh
    *   Các quy trình nghiệp vụ (Business Flows)
    *   Ràng buộc (Constraints)
*   **Đối tượng đọc:** Stakeholders, Project Managers

### Step 3: SRS (Software Requirements Specification) - "Kinh thánh của dự án"

> [!IMPORTANT]
> **SRS** là tài liệu quan trọng nhất, thường được dùng để ký hợp đồng (Sign-off). Mọi thay đổi sau này đều phải qua Change Request (CR) tốn kém.

*   **Mục tiêu:** Chuyển hóa Business thành **System Requirement**.
*   **Nội dung:**
    *   **Functional Requirements (FR)**: Hệ thống phải làm gì (Input, Output, Validation)
    *   **Non-Functional Requirements (NFR)**: Performance, Security, Scalability
    *   **Use Cases** chi tiết với flow diagrams

**Example SRS Section:**
```
FR-001: Employee List Display
- System SHALL display a paginated list of employees
- Each row SHALL show: ID, Name, Department, Status
- Default page size: 20 items
- Response time: < 2 seconds for 10,000 records
```

### Step 4: FSD (Functional Specification Document) & Design
*   **Mục tiêu:** Định nghĩa cái **HOW** (Như thế nào) ở mức độ giao diện và hành vi.
*   **Nội dung:** 
    *   Wireframes, Mockups
    *   Sơ đồ màn hình (Screen Flow)
    *   Logic chi tiết của từng nút bấm

### Step 5: TDD (Technical Design Document)
*   **Mục tiêu:** Dành cho Developer.
*   **Nội dung:** 
    *   Database Schema (ERD)
    *   API Specification (Swagger/OpenAPI)
    *   Class Diagrams, Sequence Diagrams

---

## 3. Pain Points: "Paperwork Paralysis" (Sự tê liệt vì giấy tờ)

Mặc dù quy trình trên trông rất chặt chẽ, nhưng thực tế triển khai thường gặp vô số vấn đề:

```mermaid
mindmap
  root((Paperwork<br/>Paralysis))
    Lost in Translation
      Ambiguous Language
      Misinterpretation
    Frozen Spec
      Market Changes
      Spec Outdated
    Documentation Burden
      Time Waste
      Nobody Reads
    Lack of Traceability
      Code-Spec Gap
      Impact Unknown
```

### 3.1 The "Lost in Translation" Gap (Khe hở dịch thuật)

> [!WARNING]
> Ngôn ngữ tự nhiên (Tiếng Việt/Anh) rất đa nghĩa (ambiguous). Một câu "Hệ thống phải nhanh" có thể được hiểu theo 10 cách khác nhau.

**Ví dụ thực tế:**
```
BRD: "System must be fast"
↓ (BA interprets)
SRS: "Response time < 3 seconds"
↓ (Dev interprets)
Code: setTimeout(() => showLoader(), 3000) // Wrong!
```

*   Từ **BRD** sang **SRS**: BA hiểu sai ý Khách hàng
*   Từ **SRS** sang **Code**: Dev hiểu sai ý BA
*   **Kết quả**: Sản phẩm sai lệch hoàn toàn so với mong đợi ban đầu

### 3.2 The "Frozen Spec" Fallacy (Ảo tưởng về Spec chết)

*   **Thực tế:** Các dự án thường bắt ký chốt (Sign-off) SRS từ đầu dự án (tháng 1).
*   **Vấn đề:** Khi Dev bắt đầu code (tháng 3), họ mới phát hiện ra:
    *   Logic trong SRS là bất khả thi
    *   Thiếu sót quan trọng
    *   Thị trường đã thay đổi (competitor ra tính năng mới)

*   **Hậu quả:**
    *   **Option 1**: Làm sai (để đúng Spec đã ký) → Sản phẩm vô dụng
    *   **Option 2**: Làm Change Request (CR) → Tốn kém, mất thời gian, mất lòng tin
    *   **Option 3**: Code khác, không update Spec → Tài liệu vô dụng

**Timeline Example:**
```
Month 1: SRS signed (Feature A, B, C)
Month 3: Dev starts, discovers Feature B is impossible
Month 4: CR submitted, waiting approval
Month 5: CR rejected (out of budget)
Month 6: Deliver without Feature B, customer angry
```

### 3.3 Documentation vs. Delivery (Tài liệu hay Sản phẩm?)

*   Team mất quá nhiều thời gian để viết và format tài liệu cho đẹp để "lấy tiền" khách hàng
*   Tài liệu thường quá dài (hàng trăm trang), không ai (kể cả Dev) có đủ kiên nhẫn đọc hết
*   Họ chỉ hỏi miệng hoặc đoán mò

**Statistics (from experience):**
- 📄 Average SRS length: 150-300 pages
- 👀 Percentage actually read: < 20%
- ⏱️ Time spent writing: 2-4 weeks
- 🔄 Time spent updating: 0 (never updated)

### 3.4 Lack of Traceability (Thiếu khả năng truy vết)

**Typical conversation:**
```
Customer: "Tại sao màn hình này lại có nút bấm này?"
Dev: "Em thấy Design vẽ thế."
Designer: "Em thấy SRS ghi thế."
BA: "Em không nhớ, chắc lúc họp khách hàng nói thế."
```

> [!CAUTION]
> **Vấn đề nghiêm trọng**: Không có đường dây liên kết (Link) từ dòng Code → Design → Requirement → Business Goal ban đầu. Khi sửa một Requirement, không biết phải sửa những dòng code nào.

---

## 4. Real-world Example: E-commerce Project Failure

**Case Study:**
```
Project: Build e-commerce platform
Timeline: 12 months
Budget: $500K

Month 1-2: Write BRD, SRS (200 pages)
Month 3-4: Design UI/UX
Month 5-10: Development
Month 11: Testing discovers: Payment gateway integration 
          was never specified in SRS
Month 12: Rush to add feature, bugs everywhere
Result: Launch delayed 6 months, over budget $200K
```

**Root Cause:** SRS was "frozen" at Month 2, no mechanism to evolve it.

---

## 5. Key Takeaways (Điểm Chính)

- 📝 **Heavy Documentation ≠ Clear Communication**: 200 trang SRS không đảm bảo sự hiểu biết chung
- 🧊 **Frozen Specs are Fiction**: Thị trường thay đổi, yêu cầu phải thay đổi theo
- 🔗 **Traceability is Critical**: Cần link từ Code → Requirement → Business Goal
- ⚖️ **Balance needed**: Giữa tính chặt chẽ (Rigor) và tính linh hoạt (Agility)

> [!NOTE]
> **Câu hỏi đặt ra**: Liệu có cách nào để tài liệu (Specification) trở nên "Sống" (Living Documentation) và gắn liền với Code hơn không? → Xem [The Living Spec](../03-Solution/08-the-living-spec.md)

## Related Documents
- **Previous**: [Product Development Models](./04-product-development-pain-points.md)
- **Next**: [AI Era Challenges](./06-ai-era-challenges.md)
- **Solution**: [The Living Spec](../03-Solution/08-the-living-spec.md)
