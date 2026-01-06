# 04. Phân tích Mô hình Phát triển Sản phẩm (Product Development Models)

Tài liệu này đi sâu vào phân tích quy trình phát triển phần mềm theo tư duy **Product** (Sản phẩm dài hạn), so sánh sự khác biệt giữa mô hình Enterprise và Startup, đồng thời vạch trần các "điểm đau" (Pain Points) cốt tử trong việc quản lý tri thức và tính nhất quán.

## 1. Hai thái cực của Phát triển Sản phẩm

Không phải mọi "Sản phẩm" đều được xây dựng giống nhau. Có hai mô hình phổ biến với văn hóa và quy trình hoàn toàn trái ngược:

### 1.1 The Enterprise Model (Mô hình Doanh nghiệp lớn)
Đặc trưng bởi sự ổn định, quy mô lớn và tính chuyên môn hóa cao.

*   **Structure (Cấu trúc):** Team được tổ chức theo Ma trận (Matrix). Một Developer báo cáo cho Engineering Manager (về con người) và Product Owner (về công việc).
*   **Roles (Vai trò):** Rất rõ ràng.
    *   **Architect:** Người vẽ sơ đồ, ít khi code, tập trung vào high-level design.
    *   **DevOps:** Người lo hạ tầng, Dev không được chạm vào Production.
    *   **QA/QC:** Team riêng biệt để bắt lỗi.
*   **Process (Quy trình):** Nặng nề nhưng an toàn.
    *   Mọi thay đổi phải qua **Change Request (CR)**.
    *   Phải viết **ADR (Architecture Decision Records)** trước khi chọn công nghệ mới.
    *   Review code qua nhiều lớp (Peer review, Tech Lead review).
*   **Ưu điểm:** Hệ thống ổn định, ít lỗi ngớ ngẩn, khả năng mở rộng (Scale) tốt.
*   **Nhược điểm:** Tốc độ chậm (Sluggish). Đôi khi mất 2 tuần chỉ để đổi màu một cái nút bấm vì quy trình phê duyệt.

### 1.2 The Startup/Agile Model (Mô hình Khởi nghiệp)
Đặc trưng bởi tốc độ, sự hỗn loạn và tinh thần "Move Fast and Break Things".

*   **Structure:** Team nhỏ (Scrum team, Squad), đa năng (Cross-functional).
*   **Roles:** Mờ nhạt.
    *   **Full-stack Developer:** Làm tất cả từ Frontend, Backend đến Deploy DB.
    *   **Founder/CTO:** Vừa đi gặp khách hàng, vừa về fix bug lúc nửa đêm.
*   **Process:** Tối giản.
    *   Daily Standup 15 phút.
    *   Deploy lên Production nhiều lần trong ngày (CI/CD).
    *   "Done is better than perfect".
*   **Ưu điểm:** Tốc độ cực nhanh, phản ứng tức thời với thị trường.
*   **Nhược điểm:** **Technical Debt** (Nợ kỹ thuật) khổng lồ. Code "Spaghetti" (rối rắm) vì chắp vá quá nhiều. Hệ thống dễ sập khi lượng user tăng đột ngột.

---

## 2. Pain Points: Tại sao các team thất bại?

Dù theo mô hình nào, các team phát triển sản phẩm đều gặp phải những vấn đề nan giải sau đây liên quan đến con người và kiến thức:

### 2.1 The "Bus Factor" & Brain Drain
*   **Vấn đề:** Trong mọi dự án, luôn có 1-2 "ngôi sao" (Key Person) nắm giữ tường tận logic hệ thống trong đầu họ (Mental Model).
*   **Rủi ro:** Nếu người này bị "xe bus tông" (hoặc đơn giản là nghỉ việc), dự án tê liệt.
*   **Nguyên nhân:** Kiến thức nằm trong đầu (Implicit Knowledge), không nằm trong tài liệu (Explicit Knowledge). Code quá phức tạp để người mới có thể hiểu nhanh.

### 2.2 The "Consistency vs. Entropy" War
*   **Định luật Entropy phần mềm:** "Phần mềm có xu hướng trở nên hỗn loạn theo thời gian nếu không có tác động ngược lại."
*   **Vấn đề:**
    *   Tháng 1: Dev A viết code theo style X.
    *   Tháng 2: Dev B vào, thích style Y.
    *   Tháng 3: Dev A nghỉ, Dev C vào, trộn style Z vào.
    *   **Kết quả:** Sau 1 năm, Codebase trông như một bãi rác (Frankenstein monster), không có chuẩn mực chung. Việc maintain trở thành ác mộng.
*   **Thách thức:** Làm sao để 50 Developers viết code giống như được viết bởi 1 người duy nhất?

### 2.3 The "Telephone Game" (Tam sao thất bản)
Thông tin bị méo mó khi đi qua các tầng lớp giao tiếp:

1.  **Founder/Stakeholder:** "Tôi muốn một cái xe có thể bay." (Tầm nhìn)
2.  **Product Manager:** "Tính năng: Xe có cánh." (Requirement)
3.  **Designer:** Vẽ một cái xe ô tô gắn cánh chim. (Design)
4.  **Tech Lead:** "Cần engine phản lực." (Spec)
5.  **Junior Dev:** Code một cái xe đạp có gắn quạt máy. (Implementation)

**Hậu quả:** Sản phẩm làm ra đúng "Spec" (theo cách hiểu của Dev) nhưng sai hoàn toàn "Vision" (của Founder).

### 2.4 Knowledge Silos (H ốc đảo tri thức)
*   Team Backend không biết Frontend làm gì.
*   Team Sales hứa với khách hàng những tính năng mà Team Tech chưa hề nghe nói tới.
*   Kiến thức bị cô lập trong các nhóm nhỏ, dẫn đến việc xây dựng các tính năng trùng lặp hoặc xung đột nhau.

---

## 3. Kết luận cho Phần 1

Sự khó khăn của làm Product không chỉ nằm ở công nghệ (Technology), mà nằm ở **Communication** (Giao tiếp) và **Knowledge Management** (Quản trị tri thức).

*   Enterprise quá cứng nhắc, giết chết sáng tạo.
*   Startup quá lỏng lẻo, tạo ra nợ kỹ thuật.
*   Cả hai đều sợ mất người (Brain Drain) và sợ sự thiếu nhất quán (Inconsistency).
