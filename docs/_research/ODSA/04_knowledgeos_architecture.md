# Kiến trúc KnowledgeOS Platform

> **Mục tiêu:** Mô tả kiến trúc kỹ thuật của KnowledgeOS — nền tảng biến ODSA artifacts thành Hybrid Knowledge Memory cho AI Agents, triển khai tại `/myapp/knowledgeOS`.

---

## 1. Tổng quan

KnowledgeOS là một **local-first knowledge platform** có nhiệm vụ:

1. **Ingest** ODSA artifacts (LinkML, Markdown, DBML, OpenAPI)
2. **Transform** chúng thành Hybrid Knowledge Memory
3. **Expose** knowledge thông qua REST API và MCP (Model Context Protocol)
4. **Enable** AI Agents query semantic context về hệ thống

```text
┌──────────────────────────────────────────────────────────────┐
│                      ODSA Artifacts                          │
│   LinkML YAML │ Markdown │ DBML │ OpenAPI YAML               │
└───────────────────────────┬──────────────────────────────────┘
                            │ Ingest Pipeline
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                 Hybrid Knowledge Memory                      │
│                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────────────┐ │
│  │ Property    │  │ sqlite-vec  │  │ FTS5 (SQLite)        │ │
│  │ Graph       │  │ (Embeddings)│  │ Full-text Search     │ │
│  │ (LadybugDB) │  │             │  │                      │ │
│  └─────────────┘  └─────────────┘  └──────────────────────┘ │
└───────────────────────────┬──────────────────────────────────┘
                            │
                  ┌─────────┴─────────┐
                  │                   │
            REST API             MCP Interface
           (FastAPI)          (knowledgeos-mcp)
                  │                   │
            NiceGUI UI          AI Agents
           (Admin Panel)    (Gemini / Claude)
```

---

## 2. Hybrid Knowledge Memory — 3 Tầng Storage

### Tầng 1: Property Graph (LadybugDB)

**Mục đích:** Lưu trữ cấu trúc semantic của domain knowledge — entities, relationships, lifecycles.

**Data source:** LinkML YAML, DBML, OpenAPI

**Node types:**

| Node Type | Source | Mô tả |
|---|---|---|
| `Concept` | LinkML classes | Business entities |
| `Slot` | LinkML slots | Entity attributes |
| `Lifecycle` | LinkML/Markdown | State machine definition |
| `State` | LinkML/Markdown | Individual states |
| `Transition` | LinkML/Markdown | State transitions |
| `DomainEvent` | LinkML/Markdown | Domain events |
| `Table` | DBML | Database tables |
| `Column` | DBML | Table columns |
| `APIEndpoint` | OpenAPI | API endpoints |
| `Document` | Markdown | Design documents |

**Key relationships:**

```text
Concept -[HAS_SLOT]-> Slot
Concept -[INHERITS]-> Concept
Concept -[HAS_LIFECYCLE]-> Lifecycle
Lifecycle -[HAS_STATE]-> State
Lifecycle -[HAS_TRANSITION]-> Transition
Transition -[TRIGGERS]-> DomainEvent
Table -[IMPLEMENTS]-> Concept
APIEndpoint -[USES]-> Concept
Document -[REFERENCES]-> Concept
```

**Ví dụ query (Cypher):**

```cypher
// Tìm tất cả APIs liên quan đến Worker
MATCH (a:APIEndpoint)-[:USES]->(c:Concept {name: 'Worker'})
RETURN a.path, a.method, a.summary
```

### Tầng 2: Vector Store (sqlite-vec)

**Mục đích:** Semantic similarity search — tìm kiếm theo nghĩa, không phải từ khoá.

**Data source:** Markdown chunks + concept descriptions

**Cách hoạt động:**

```text
Markdown file
    ↓ chunk by headers (H2/H3)
    ↓ embed each chunk (embedding model)
    ↓ store in sqlite-vec table
```

**Query:** AI Agent hỏi "worker suspension requirements" → vector search tìm chunks liên quan nhất.

### Tầng 3: Full-Text Search (FTS5)

**Mục đích:** Keyword-based search, đặc biệt hữu ích với technical terms và proper nouns.

**Data source:** Tất cả text content (concepts, docs, events)

**Query:** Tìm kiếm exact match hoặc prefix match.

---

## 3. Ingest Pipeline

Pipeline biến ODSA artifacts thành Hybrid Knowledge Memory.

### Luồng xử lý

```text
                    ┌─────────────────────┐
                    │   Input: File Path  │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │  Detect File Type   │
                    │  .yaml/.yml → LinkML│
                    │  .md → Markdown     │
                    │  .dbml → DBML       │
                    │  .yaml (api) → OAPI │
                    └──────────┬──────────┘
                               │
               ┌───────────────┼───────────────┐
               ▼               ▼               ▼
        ┌──────────┐    ┌──────────┐    ┌──────────┐
        │  LinkML  │    │ Markdown │    │   DBML   │
        │ Ingestor │    │ Ingestor │    │ Ingestor │
        └────┬─────┘    └────┬─────┘    └────┬─────┘
             │               │               │
             ▼               ▼               ▼
       Graph nodes     Vector chunks    Graph nodes
        + edges         + FTS index      + edges
             │               │               │
             └───────────────┴───────────────┘
                             │
                    ┌────────▼────────┐
                    │ Hybrid Knowledge│
                    │    Memory       │
                    └─────────────────┘
```

### Chi tiết từng ingestor

**LinkML Ingestor:**
```text
Classes → Concept nodes
Slots → Slot nodes + HAS_SLOT edges
Enums → Enum + EnumValue nodes
is_a → INHERITS edges
ranges (class refs) → RELATES_TO edges
Descriptions → Text chunks → FTS5
```

**Markdown Ingestor:**
```text
Split by H1/H2/H3 headers → chunks
Embed each chunk → sqlite-vec
Index all text → FTS5
Create Document node
Link Document → REFERENCES → Concepts (name matching)
```

**DBML Ingestor:**
```text
Tables → Table nodes
Columns → Column nodes + HAS_COLUMN edges
Foreign keys → HAS_FOREIGN_KEY edges
Name matching → Table -[IMPLEMENTS]-> Concept
```

**OpenAPI Ingestor:**
```text
Paths → APIEndpoint nodes
Request bodies → RequestPayload nodes + HAS_REQUEST edges
Responses → ResponsePayload nodes + HAS_RESPONSE edges
Schema refs → USES edges to Concept nodes
```

---

## 4. Hybrid Search

KnowledgeOS cung cấp 3 loại search, thường dùng kết hợp (hybrid search):

### Semantic Search (Vector)

```http
POST /api/search/semantic
{
  "query": "worker suspension requirements",
  "top_k": 5
}
```

Trả về: chunks từ design docs và ontology descriptions có nghĩa gần nhất với query.

### Fulltext Search (FTS5)

```http
POST /api/search/fulltext
{
  "query": "WorkerSuspended",
  "limit": 10
}
```

Trả về: keyword matches — hữu ích cho tên event, API endpoint, concept names.

### Hybrid Search (Recommended)

```http
POST /api/search/hybrid
{
  "query": "worker suspension requirements",
  "top_k": 5,
  "include_graph": true
}
```

Trả về: kết hợp semantic + FTS + graph traversal. **Đây là search method chính cho AI Agents.**

---

## 5. REST API Layer

FastAPI app được mount tại `/api-app` trong NiceGUI server.

### API Groups

| Prefix | Mô tả |
|---|---|
| `GET/POST /api/graph/query` | Cypher query trực tiếp |
| `GET /api/graph/neighbors/{type}/{id}` | Explore node neighbors |
| `GET /api/graph/schema` | Graph schema info |
| `GET /api/graph/concepts` | List all concepts |
| `GET /api/graph/concepts/{id}` | Concept full detail |
| `POST /api/search/hybrid` | Hybrid search |
| `POST /api/ingest/file` | Trigger file ingest |
| `GET /api/ingest/jobs` | List ingest jobs |

**Base URL (local):** `http://localhost:8080/api-app/api`

---

## 6. MCP Interface (AI Agent Layer)

### Decoupled FastMCP Client (`knowledgeos-mcp`)

Project độc lập nằm tại `/myapp/knowledgeos-mcp`. Đây là một **thin HTTP client** viết bằng FastMCP 3.0, không chứa bất kỳ business logic hay database access nào — chỉ proxy calls tới REST API.

**Cài đặt:** `pip install -e .` (một lần duy nhất trong `myenv`)

**Kích hoạt:** `/Users/nguyenhuyvu/.pyenv/versions/myenv/bin/knowledgeos-mcp`

**MCP Config (Gemini/Claude/Cursor):**

```json
{
  "knowledgeos": {
    "command": "/Users/nguyenhuyvu/.pyenv/versions/myenv/bin/knowledgeos-mcp",
    "env": {
      "KNOWLEDGEOS_API_URL": "http://localhost:8080/api-app/api"
    }
  }
}
```

### 8 MCP Tools cho AI Agents

| Tool | API Endpoint | Mô tả |
|---|---|---|
| `knowledge_search` | `POST /search/hybrid` | Hybrid search (vector + FTS + graph) |
| `graph_query` | `POST /graph/query` | Cypher query thẳng vào graph |
| `graph_explore` | `GET /graph/neighbors/{type}/{id}` | Explore node relationships |
| `graph_schema` | `GET /graph/schema` | Xem graph schema |
| `list_concepts` | `GET /graph/concepts` | List all domain concepts |
| `concept_detail` | `GET /graph/concepts/{id}` | Full concept info |
| `ingest_file` | `POST /ingest/file` | Trigger ingest từ AI |
| `ingest_status` | `GET /ingest/jobs` | Kiểm tra ingest status |

### Ví dụ AI Agent sử dụng MCP

```text
AI Agent (Gemini/Claude) nhận request:
"Implement worker suspension API"

AI tự động:
1. knowledge_search("worker suspension requirements")
   → Nhận chunks từ design/use_cases.md

2. concept_detail("Worker")
   → Nhận slots, lifecycle reference, relationships

3. graph_query("MATCH (l:Lifecycle {name:'WorkerLifecycle'})-[:HAS_TRANSITION]->(t:Transition) WHERE t.trigger = 'SuspendWorker' RETURN t")
   → Nhận transition details, event to emit

4. AI tổng hợp → Generate code với đầy đủ business context
```

---

## 7. NiceGUI Admin Panel

**URL (local):** `http://localhost:8080`

**Khởi động:** `python -m src.ui.main` (từ `myapp/knowledgeOS/`)

### Pages

| Page | URL | Mô tả |
|---|---|---|
| Dashboard | `/` | Knowledge base stats, node/edge counts |
| LLM Config | `/config/llm` | API keys, model selection |
| Prompts | `/config/prompts` | Prompt template management |
| Knowledge Browser | `/knowledge` | Graph visualization, search |
| Ingest Manager | `/ingest` | Trigger ingest, view job history |

---

## 8. Vòng đời của một Knowledge Update

```text
1. BA/Dev cập nhật ontology file trong Git repo
   (Ví dụ: hr_core/ontology/concepts/worker.yaml)

2. Trigger ingest qua:
   a. AI Agent: ingest_file(path) tool
   b. Admin UI: Ingest Manager → trigger
   c. API: POST /api/ingest/file {"path": "..."}

3. Pipeline chạy:
   - Parse LinkML → extract nodes/edges
   - Upsert vào Property Graph (LadybugDB)
   - Update FTS5 index
   - (Nếu có descriptions) → embed → update sqlite-vec

4. AI Agent context updated automatically
   - Lần query tiếp theo sẽ nhận knowledge mới nhất
```

---

## 9. Yêu cầu hệ thống

### Startup sequence

```bash
# Bước 1: Bật KnowledgeOS server
cd /myapp/knowledgeOS
python -m src.ui.main
# → Chạy NiceGUI + FastAPI tại http://localhost:8080

# Bước 2: Gemini/Cursor tự động kết nối qua MCP
# (knowledgeos-mcp được spawn tự động bởi MCP client)
```

> **Quan trọng:** KnowledgeOS server phải đang chạy trước khi AI Agents có thể sử dụng MCP tools.

### Dependencies

| Component | Technology | Purpose |
|---|---|---|
| Web server | NiceGUI + FastAPI | Admin UI + REST API |
| Graph DB | LadybugDB (Kuzu-based) | Property Graph storage |
| Vector store | sqlite-vec | Embedding similarity search |
| Full-text | FTS5 (SQLite) | Keyword search |
| Embedding | MLX / sentence-transformers | Text → vectors |
| MCP | FastMCP 3.0 | AI Agent interface |
| HTTP client | httpx | MCP → API communication |

---

## 10. Roadmap

### Phase 1 (Hiện tại) — Knowledge Layer ✅

AI Agent có semantic context để hỗ trợ design/development.

- [x] Ingest pipeline (LinkML, Markdown, DBML, OpenAPI)
- [x] Hybrid Knowledge Memory (Graph + Vector + FTS)
- [x] REST API layer
- [x] MCP interface (standalone `knowledgeos-mcp`)
- [x] Admin UI

### Phase 2 (Tương lai) — Runtime Intelligence

AI Agent query runtime data và trực tiếp manipulate system thông qua Canonical APIs.

- [ ] Runtime event feed → update knowledge graph dynamically
- [ ] AI Agent có thể discover và call canonical APIs
- [ ] Frontend-less application paradigm: AI là UI

---

## Đọc thêm

- **[01_odsa_overview.md](./01_odsa_overview.md)** — Triết lý và mục tiêu ODSA
- **[02_odds_standard.md](./02_odds_standard.md)** — Cấu trúc tài liệu chuẩn ODDS v1
- **[03_development_workflow.md](./03_development_workflow.md)** — Workflow theo ODSA
