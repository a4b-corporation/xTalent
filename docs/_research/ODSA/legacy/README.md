# KnowledgeOS Documentation Hub

> Bộ tài liệu chính quy về **ODSA** (Ontology-Driven System Architecture) — triết lý, tiêu chuẩn và quy trình phát triển phần mềm lấy Ontology làm trung tâm.

---

## Mục lục

### Tầng 1: Ontology Layer (ODDS)

| File | Nội dung | Đối tượng |
|---|---|---|
| [01_odsa_overview.md](./01_odsa_overview.md) | Tổng quan ODSA: mục tiêu, triết lý, tại sao chọn Property Graph | Tất cả |
| [02_odds_standard.md](./02_odds_standard.md) | ODDS v1: chuẩn cấu trúc tài liệu module, templates, conventions | BA, Architect |
| [03_development_workflow.md](./03_development_workflow.md) | Workflow phát triển theo ODSA: vai trò mới, daily tasks, review process | BA, Dev, Architect |
| [04_knowledgeos_architecture.md](./04_knowledgeos_architecture.md) | Kiến trúc nền tảng KnowledgeOS: ingest pipeline, hybrid search, MCP | Dev, Architect |

### Tầng 2: Feature Layer (OFDS)

| File | Nội dung | Đối tượng |
|---|---|---|
| [05_ofds_overview.md](./05_ofds_overview.md) | Tổng quan OFDS: tại sao cần feature layer, mô hình 2 tầng, 5 nguyên tắc | Tất cả |
| [06_ofds_standard.md](./06_ofds_standard.md) | OFDS v1: chuẩn folder `features/`, catalog, index, feature spec template | BA, Dev, Architect |
| [07_ofds_feature_spec.md](./07_ofds_feature_spec.md) | Chi tiết 9 thành phần của Feature Spec + ví dụ thực tế + checklist | BA, Dev, QA |

---

## Đọc theo vai trò

**Product Owner / BA:**
1. `01_odsa_overview.md` — Hiểu vision và triết lý
2. `02_odds_standard.md` — Biết cần viết những artifact ontology nào
3. `05_ofds_overview.md` — Hiểu tầng feature layer
4. `06_ofds_standard.md` — Cấu trúc folder và templates
5. `07_ofds_feature_spec.md` — Cách viết từng thành phần feature spec

**Developer:**
1. `01_odsa_overview.md` — Nắm bối cảnh
2. `03_development_workflow.md` — Biết cách dùng AI Agent trong dev
3. `06_ofds_standard.md` — Hiểu cấu trúc feature docs
4. `04_knowledgeos_architecture.md` — Hiểu hạ tầng KnowledgeOS

**QA Engineer:**
1. `05_ofds_overview.md` — Hiểu mô hình 2 tầng
2. `07_ofds_feature_spec.md` — Thành phần 7 (Edge Cases) + Thành phần 8 (Acceptance Criteria)

**System Architect:**
1. Tất cả 7 documents theo thứ tự

---

## Key Concepts

- **ODSA** — Ontology-Driven System Architecture: phương pháp phát triển lấy Ontology làm Single Source of Truth
- **ODDS** — Ontology-Driven Documentation Standard: tiêu chuẩn cấu trúc tài liệu ontology cho mỗi business module
- **OFDS** — Ontology-driven Feature Documentation Standard: tiêu chuẩn tài liệu feature, bổ sung cho ODDS
- **FSD** — Feature Specification Document (`*.fsd.md`): 1 file = 1 feature, 9 thành phần
- **A2UI** — AI Mockup Builder DSL: format JSON chuẩn cho mockup trong feature spec
- **KnowledgeOS** — Platform thực thi ODSA: ingest artifacts → Hybrid Knowledge Memory → AI Agent interface
- **knowledgeos-mcp** — Decoupled FastMCP client: giao tiếp với KnowledgeOS API qua MCP protocol
