# KnowledgeOS Documentation Hub


> Bộ tài liệu chính quy về **ODSA** (Ontology-Driven System Architecture) — triết lý, tiêu chuẩn và quy trình phát triển phần mềm lấy Ontology làm trung tâm.

---

## Mục lục

| File | Nội dung | Đối tượng |
|---|---|---|
| [01_odsa_overview.md](./01_odsa_overview.md) | Tổng quan ODSA: mục tiêu, triết lý, tại sao chọn Property Graph | Tất cả |
| [02_odds_standard.md](./02_odds_standard.md) | ODDS v1: chuẩn cấu trúc tài liệu module, templates, conventions | BA, Architect |
| [03_development_workflow.md](./03_development_workflow.md) | Workflow phát triển theo ODSA: vai trò mới, daily tasks, review process | BA, Dev, Architect |
| [04_knowledgeos_architecture.md](./04_knowledgeos_architecture.md) | Kiến trúc nền tảng KnowledgeOS: ingest pipeline, hybrid search, MCP | Dev, Architect |

---

## Đọc theo vai trò

**Product Owner / BA:**
1. `01_odsa_overview.md` — Hiểu vision và triết lý
2. `02_odds_standard.md` — Biết cần viết những artifact nào
3. `03_development_workflow.md — Biết daily workflow thay đổi thế nào`

**Developer:**
1. `01_odsa_overview.md` — Nắm bối cảnh
2. `03_development_workflow.md` — Biết cách dùng AI Agent trong dev
3. `04_knowledgeos_architecture.md` — Hiểu hạ tầng KnowledgeOS

**System Architect:**
1. Tất cả 4 documents theo thứ tự

---

## Key Concepts

- **ODSA** — Ontology-Driven System Architecture: phương pháp phát triển lấy Ontology làm Single Source of Truth
- **ODDS** — Ontology-Driven Documentation Standard: tiêu chuẩn cấu trúc tài liệu cho mỗi business module
- **KnowledgeOS** — Platform thực thi ODSA: ingest artifacts → Hybrid Knowledge Memory → AI Agent interface
- **knowledgeos-mcp** — Decoupled FastMCP client: giao tiếp với KnowledgeOS API qua MCP protocol
