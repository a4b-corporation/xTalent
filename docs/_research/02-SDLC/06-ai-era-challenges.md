# 06. Thách thức trong Kỷ nguyên AI (The AI Era Challenges)

Sự trỗi dậy của GenAI (Generative AI) và các Coding Assistant (Copilot, Cursor, Windsurf) đang thay đổi cuộc chơi phát triển phần mềm nhanh hơn bất kỳ giai đoạn nào trong lịch sử. Tuy nhiên, nó cũng sinh ra những vấn đề hoàn toàn mới.

## 1. Bối cảnh mới: "Code is Cheap"

Trước đây, viết code là công đoạn tốn thời gian và chất xám nhất. Code là tài sản quý giá.
Ngày nay, AI có thể sinh ra hàng nghìn dòng code trong vài giây. Code trở nên rẻ mạt (Commodity).

*   **Sự thay đổi vai trò:** Developer chuyển từ "Người viết" (Writer) sang "Người duyệt" (Reviewer/Auditor).
*   **Tốc độ:** Một Junior Dev có AI hỗ trợ có thể produce lượng code ngang một Senior Dev ngày xưa (nhưng chất lượng thì chưa chắc).

## 2. New Pain Points (Những nỗi đau mới)

### 2.1 Code Bloat & Maintenance Nightmare (Phình to Code)
*   **Vấn đề:** Vì tạo code quá dễ, Developer có xu hướng lạm dụng. Thay vì refactor để code gọn gàng, họ nhờ AI "viết thêm 1 hàm nữa" để patch lỗi.
*   **Hậu quả:** Codebase phình to mất kiểm soát. Số lượng dòng code (LOC) tăng vọt nhưng logic nghiệp vụ (Business Logic) vẫn thế.
*   **Rủi ro:** Càng nhiều code = Càng nhiều bug = Càng khó bảo trì. AI hiện tại chưa giỏi trong việc nhìn toàn cảnh (holistic view) để tối ưu kiến trúc.

### 2.2 The "Senior Syntax, Junior Logic" Trap
*   **Hiện tượng:** AI viết code có cú pháp (syntax) hoàn hảo, dùng các pattern cao cấp, đặt tên biến chuẩn chỉ (như Senior).
*   **Bản chất:** Nhưng logic bên trong có thể sai lầm ngớ ngẩn (hallucination), hoặc hổng lỗ hổng bảo mật chết người.
*   **Nguy hiểm:** Junior Dev nhìn code đẹp, chạy thử thấy OK -> Commit. Lỗi logic nghiệp vụ (Business Logic Flaw) nằm ẩn sâu và chỉ phát nổ trong những trường hợp biên (Edge cases) mà Junior không biết test.

### 2.3 Knowledge Atrophy (Teo tóp kiến thức)
*   **Vấn đề:** Khi con người không còn tự tay viết từng dòng code, não bộ dừng việc xây dựng "Mental Model" về hệ thống.
*   **Hệ quả:**
    *   Developer trở nên phụ thuộc (reliant) vào AI. Nếu tắt AI, họ không code được.
    *   Mất khả năng "Deep Debugging". Khi hệ thống gặp lỗi phức tạp, họ không hiểu luồng đi của dữ liệu vì code đó do AI viết, không phải do họ tư duy ra.
    *   Văn hóa "Copy-Paste-Pray" (Copy-Dán-Cầu nguyện cho nó chạy) lên ngôi.

### 2.4 Context Management (Quản lý ngữ cảnh)
*   AI chỉ thông minh khi có đủ context.
*   Thách thức của con người bây giờ là: Làm sao để nạp đúng và đủ thông tin (Requirements, Ontology, Constraints) vào Context Window của AI?
*   **Documentation as Prompt:** Tài liệu dự án bây giờ không chỉ cho người đọc, mà phải viết sao cho AI đọc hiểu được để nó generate code đúng chuẩn.

---

## 3. Sự tiến hóa của Quy trình (Evolving Processes)

Để sống sót trong kỷ nguyên AI, quy trình làm phần mềm buộc phải thay đổi:

### 3.1 From "Specification" to "Prompt Engineering"
*   SRS truyền thống (văn bản dài) rất khó để AI tiêu thụ hiệu quả.
*   Xu hướng mới: Viết Spec dưới dạng **Semi-structured Data** (như Markdown, YAML, pseudo-code) để có thể feed trực tiếp vào AI Agents.
*   Prompt không còn là những câu chat ngẫu hứng, mà trở thành một phần của Source Code (Prompt Engineering as Code).

### 3.2 Automated Verification (Kiểm thử tự động)
*   Vì không thể tin tưởng 100% vào code sinh bởi AI, vai trò của **Automated Testing** (Unit Test, Integration Test) trở nên quan trọng hơn bao giờ hết.
*   Quy trình: AI viết Code -> AI viết Test -> Con người review Test cases -> Chạy Test để verify Code.

### 3.3 Ontology as Anchor (Ontology là mỏ neo)
*   Trong cơn bão code do AI sinh ra, chúng ta cần một cái gì đó **Cố định** và **Chính xác** để làm mỏ neo.
*   Đó chính là **Ontology**.
    *   Nếu ta định nghĩa rõ `Object Employee` và `Rule Salary`, ta có thể bắt AI tuân thủ nghiêm ngặt định nghĩa này.
    *   Ontology đóng vai trò là "Guardrails" (Thanh chắn bảo vệ) để AI không sáng tạo lung tung sai nghiệp vụ.

---

## 4. Kết luận chung cho cả 3 phần

Ngành phần mềm đang đứng trước ngã ba đường:
1.  **Product:** Cần ổn định và nhất quán.
2.  **Project:** Cần tốc độ và sự chính xác theo hợp đồng.
3.  **AI:** Mang lại tốc độ nhưng đe dọa sự ổn định và chính xác.

Giải pháp tiềm năng chính là việc kết hợp sức mạnh của **Ontology** (sự rõ ràng, ngữ nghĩa) với sức mạnh của **AI** (tốc độ thực thi).
*   Dùng Ontology để định nghĩa "Cái gì" (Strategy/Spec).
*   Dùng AI để thực thi "Dựng nên cái đó" (Implementation).
*   Con người đóng vai trò Kiến trúc sư (Architect) và Người kiểm soát (Auditor).
