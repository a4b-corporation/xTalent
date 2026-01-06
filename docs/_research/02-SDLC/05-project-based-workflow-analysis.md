# 05. Phân tích Quy trình Dự án (Project-Based Workflows)

Tài liệu này tập trung vào mô hình phát triển theo **Dự án** (Outsourcing, Client Projects) hoặc phát triển tính năng theo yêu cầu (Request-based). Đặc trưng của mô hình này là sự chuyển giao ý tưởng từ "Khách hàng" sang "Đội ngũ thực thi" thông qua một chuỗi các tài liệu dày đặc.

## 1. The Standard Workflow (Quy trình chuẩn)

Mô hình này thường đi theo dạng thác nước (Waterfall) hoặc V-Model, ngay cả khi team tuyên bố họ làm Agile. Các bước tiêu chuẩn bao gồm:

### Step 1: User Stories / Requirements gathering
*   **Input:** Khách hàng nói "Tôi muốn quản lý nhân sự".
*   **Activity:** Business Analyst (BA) phỏng vấn, ghi chép.
*   **Output:** **User Stories** (e.g., "Là HR manager, tôi muốn xem danh sách nhân viên để...").

### Step 2: BRD (Business Requirement Document)
*   **Mục tiêu:** Định nghĩa cái **WHAT** (Cái gì) ở mức độ kinh doanh.
*   **Nội dung:** Phạm vi dự án (Scope), Mục tiêu kinh doanh, Các quy trình nghiệp vụ (Business Flows), Ràng buộc (Constraints).
*   **Đối tượng đọc:** Stakeholders, Project Managers.

### Step 3: SRS (Software Requirements Specification) - "Kinh thánh của dự án"
*   **Mục tiêu:** Chuyển hóa Business thành **System Requirement**. Đây thường là tài liệu quan trọng nhất dùng để ký hợp đồng (Sign-off).
*   **Nội dung:**
    *   Functional Requirements (FR): Hệ thống phải làm gì (Input, Output, Validation).
    *   Non-Functional Requirements (NFR): Performance, Security, Scalability.
    *   Use Cases chi tiết.

### Step 4: FSD (Functional Specification Document) & Design
*   **Mục tiêu:** Định nghĩa cái **HOW** (Như thế nào) ở mức độ giao diện và hành vi.
*   **Nội dung:** Wireframes, Mockups, Sơ đồ màn hình (Screen Flow), Logic chi tiết của từng nút bấm.

### Step 5: TDD (Technical Design Document)
*   **Mục tiêu:** Dành cho Developer.
*   **Nội dung:** Database Schema (ERD), API Specification (Swagger), Class Diagrams, Sequence Diagrams.

---

## 2. Pain Points: "Paperwork Paralysis" (Sự tê liệt vì giấy tờ)

Mặc dù quy trình trên trông rất chặt chẽ, nhưng thực tế triển khai thường gặp vô số vấn đề:

### 2.1 The "Lost in Translation" Gap (Khe hở dịch thuật)
*   Từ **BRD** sang **SRS**: BA hiểu sai ý Khách hàng.
*   Từ **SRS** sang **Code**: Dev hiểu sai ý BA.
*   **Vấn đề:** Ngôn ngữ tự nhiên (Tiếng Việt/Anh) rất đa nghĩa (ambiguous). Một câu "Hệ thống phải nhanh" có thể được hiểu theo 10 cách khác nhau.

### 2.2 The "Frozen Spec" Fallacy (Ảo tưởng về Spec chết)
*   **Thực tế:** Các dự án thường bắt ký chốt (Sign-off) SRS từ đầu dự án.
*   **Vấn đề:** Khi Dev bắt đầu code (tháng thứ 3), họ mới phát hiện ra logic trong SRS là bất khả thi hoặc thiếu sót.
*   **Hậu quả:**
    *   Hoặc là làm sai (để đúng Spec đã ký).
    *   Hoặc là làm thủ tục Change Request (CR) tốn kém và mệt mỏi.
    *   Tài liệu SRS dần trở nên vô dụng vì Code thực tế đã đi xa so với tài liệu gốc, mà không ai quay lại cập nhật SRS.

### 2.3 Documentation vs. Delivery (Tài liệu hay Sản phẩm?)
*   Team mất quá nhiều thời gian để viết và format tài liệu cho đẹp để "lấy tiền" khách hàng, thay vì tập trung vào giải pháp thực sự.
*   Tài liệu thường quá dài (hàng trăm trang), không ai (kể cả Dev) có đủ kiên nhẫn đọc hết. Họ chỉ hỏi miệng hoặc đoán mò.

### 2.4 Lack of Traceability (Thiếu khả năng truy vết)
*   Khách hàng hỏi: "Tại sao màn hình này lại có nút bấm này?"
*   Dev trả lời: "Em thấy Design vẽ thế."
*   Designer: "Em thấy SRS ghi thế."
*   BA: "Em không nhớ, chắc lúc họp khách hàng nói thế."
*   **Vấn đề:** Không có đường dây liên kết (Link) từ dòng Code -> Design -> Requirement -> Business Goal ban đầu. Khi sửa một Requirement, không biết phải sửa những dòng code nào.

---

## 3. Câu hỏi đặt ra

Liệu có cách nào để tài liệu (Specification) trở nên "Sống" (Living Documentation) và gắn liền với Code hơn không?
Liệu chúng ta có thể thay thế SRS hàng trăm trang bằng một format khác (như Ontology, Low-code configuration) dễ hiểu hơn và chính xác hơn không?
