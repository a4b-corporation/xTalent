# 07. Concept: Ontology-Driven Development (ODD)

> [!NOTE]
> **Mục tiêu**: Định nghĩa phương pháp luận ODD - một cách tiếp cận mới để phát triển phần mềm với Ontology làm trung tâm, giải quyết các pain points đã phân tích ở Session 2.

**Ontology-Driven Development (ODD)** là phương pháp luận phát triển phần mềm mà ở đó **Ontology** (Bản thể học – mô hình các thực thể và mối quan hệ) đóng vai trò là **Source of Truth** (Nguồn chân lý) duy nhất và trung tâm, chi phối cả Data Schema, Business Logic và API Design.

## 1. Định nghĩa cốt lõi

Trong ODD, chúng ta không bắt đầu bằng *"Vẽ bảng Database"* hay *"Vẽ màn hình UI"*. Chúng ta bắt đầu bằng việc **Định nghĩa Tồn tại**.

> "Trước khi một vật có thể được quản lý, nó phải được định nghĩa."

*   **Inputs:** Markdown files (`*.onto.md`).
*   **Process:** Compiler / Generators / AI Assistants.
*   **Outputs:** Database Schema, API Interfaces, Validation Logic, Documentation.

### Visualizing the Shift

```mermaid
graph TD
    subgraph "Traditional Dev"
        A[Requirement] --> B[Database Design]
        B --> C[Backend Code]
        C --> D[Front End]
        B -.-> E[Docs (Outdated)]
    end

    subgraph "Ontology-Driven Dev (ODD)"
        REQ[Requirement] --> ONTO[Ontology Definitions (*.onto.md)]
        ONTO -->|Generate| DB[DB Schema]
        ONTO -->|Generate| API[API Contract]
        ONTO -->|Context| AI[AI Assistant]
        ONTO -->|Render| DOC[Live Docs]
    end
```

## 2. Tại sao ODD giải quyết được các Pain Points?

### 2.1 Giải quyết "Frozen Specs" (Spec chết)
*   **Vấn đề:** Tài liệu (Word/PDF) chết ngay sau khi viết xong vì không ai update.
*   **ODD Solution:** Ontology file (`.md`) nằm ngay trong Git repo cùng với Code. Khi logic thay đổi, Dev phải sửa file `.md` trước (để gen ra code hoặc để AI hiểu), nên tài liệu luôn "Sống" (Living Documentation).

### 2.2 Giải quyết "AI Hallucination" (AI ảo giác)
*   **Vấn đề:** AI viết code bịa đặt nghiệp vụ vì thiếu context.
*   **ODD Solution:** Ontology đóng vai trò là "Guardrails" (Thanh chắn).
    *   File `Employee.onto.md` định nghĩa rõ: `status` chỉ được là `ACTIVE` hoặc `TERMINATED`.
    *   Nếu AI viết code gán `status = 'FIRED'`, Compiler hoặc Linter sẽ báo lỗi ngay lập tức dựa trên Ontology.

### 2.3 Giải quyết "Inconsistency" (Thiếu nhất quán)
*   **Vấn đề:** 5 người đặt tên biến khác nhau (`empId`, `employee_id`, `userID`).
*   **ODD Solution:** Tên biến được chuẩn hóa từ Ontology. Mọi người đều phải dùng `workerId` nếu Ontology đã định nghĩa như vậy.

## 3. Ba trụ cột của ODD (The 3 Pillars)

Để ODD hoạt động, chúng ta cần xây dựng 3 trụ cột (đây sẽ là nền tảng cho **Session 4: The Toolchain**):

1.  **Semantic Definition (Định nghĩa ngữ nghĩa):**
    *   Sử dụng Markdown + YAML Frontmatter để viết định nghĩa. Dễ đọc cho Người, dễ parse cho Máy.
2.  **Structural Validation (Kiểm tra cấu trúc):**
    *   Một công cụ (Linter/Compiler) đảm bảo các file `.md` không mâu thuẫn nhau (ví dụ: Link trỏ đến một Entity không tồn tại).
3.  **Generative Bridge (Cầu nối sinh tạo):**
    *   Cơ chế (Tooling/Prompting) để biến định nghĩa thành Code thực thi.

## Kết luận

ODD không phải là phát minh lại bánh xe, mà là sự **kỷ luật hóa** quy trình Engineering: **Think before you Code**.

> [!IMPORTANT]
> **Paradigm Shift**: Thay vì Think (Nghĩ) → Word Doc (Mất tích) → Code, ODD bắt buộc quy trình: **Think → Ontology → Code**.

## Related Documents
- **Problem**: [AI Era Challenges](../02-Pain-Points/06-ai-era-challenges.md)
- **Next**: [The Living Spec](./08-the-living-spec.md)
- **Implementation**: [Developer Workflow](../04-Framework/11-developer-workflow.md)
