
## 2. Gợi ý cấu trúc: Module-first + có Global

### 2.1. Top-level

```text
/docs
  /00-global
  /01-modules
  /_templates
  /_ai-prompts
```

* `00-global`: ontology & glossary dùng chung toàn hệ thống.
* `01-modules`: từng module, đây là nơi chính bạn làm việc.
* `_templates`: khung SpecKit, skeleton file.
* `_ai-prompts`: prompt mẫu cho AI agents (generate spec, code, test…).

---

### 2.2. Global layer (dùng chung)

```text
/docs/00-global
  /ontology
    core-domain.yaml        # Person, Worker, LegalEntity, OrgUnit, Job, Position...
    time-absence-core.yaml  # Các khái niệm cross-module trong Time & Absence
    total-rewards-core.yaml
  /glossary
    domain-glossary.md      # Từ điển khái niệm chung
  /speckit
    spec-structure.md       # Guideline dùng SpecKit (overview, conceptual, spec…)
  /standards
    naming-conventions.md
    http-api-standard.md
    ui-ux-guidelines.md
```

Đây là “**gốc**” cho toàn hệ thống – nơi AI/Dev/BA đọc để biết *luật chơi chung*.

---

### 2.3. Theo module: ví dụ Time & Absence → Absence submodule

```text
/docs/01-modules
  /time-absence
    /absence
      /00-ontology
      /01-concept
      /02-spec
      /03-design
      /04-api
      /05-ui
      /06-tests
      /07-impl-notes
```

Giờ zoom sâu từng phần.

---

## 3. Chi tiết từng folder trong một module

### `00-ontology/` – Tầng domain

```text
/docs/01-modules/time-absence/absence/00-ontology
  absence-ontology.yaml      # Entities, relationships, rules của Absence
  absence-glossary.md        # Từ điển riêng cho Absence
  absence-state-machines.md  # Lifecycle của Leave Request, Balance, Event...
```

* Format: JSON/YAML + MD.
* Liên kết về global ontology bằng ID (vd: `Person`, `OrgUnit` không khai lại, chỉ reference).

---

### `01-concept/` – Concept docs (SpecKit tầng 1–3)

```text
/docs/01-modules/time-absence/absence/01-concept
  01-concept-overview.md
  02-conceptual-guide.md
  03-concept-entity-guides/
    leave-type.md
    leave-class.md
    policy.md
    event-movement.md
```

* `Concept Overview`: mục tiêu business, scope, value.
* `Conceptual Guide`: cách Absence vận hành tổng thể.
* `Concept Entity Guides`: giải thích từng domain entity (không đi vào field-level design).

---

### `02-spec/` – Behaviour & system spec (tầng “spec” bạn nhắc)

```text
/docs/01-modules/time-absence/absence/02-spec
  01-behaviour-spec.md       # Flow, scenario, business rule
  02-use-cases.md            # UC theo dạng “As a … I want…”
  03-scenarios/
    request-leave-basic.md
    request-leave-cross-year.md
    carryover-end-year.md
  04-non-functional.md       # Permission, audit, performance, multi-tenant
```

Đây là **bridge** từ concept → system design. AI đọc phần này để biết **logic thực thi**.

---

### `03-design/` – System & data design

```text
/docs/01-modules/time-absence/absence/03-design
  01-data-model.dbml         # DBML cho Absence
  02-data-model-notes.md     # Ghi chú mapping từ ontology → DB
  03-event-model.md          # Event, Movement, ledger thiết kế
  04-integration.md          # Liên kết với HR Core, Payroll, Scheduling...
```

* Từ đây, AI có thể generate migrations, repository, entity classes.

---

### `04-api/` – Headless API spec

```text
/docs/01-modules/time-absence/absence/04-api
  absence-openapi.yaml       # OpenAPI 3.x
  api-guidelines.md          # Các nguyên tắc bổ sung nếu có
  example-requests.md        # Sample payloads
```

* Sinh từ ontology + spec.
* Là input cho frontend, integration, AI agent.

---

### `05-ui/` – UI spec & mockup ✅ *Chính là câu hỏi của bạn*

```text
/docs/01-modules/time-absence/absence/05-ui
  01-ui-principles.md        # Behaviour UI chung cho Absence
  02-screens/
    leave-type-list.md
    leave-type-editor.md
    policy-library.md
  03-mockups/
    leave-type-list.html     # HTMX + Shoelace demo
    leave-type-editor.html
```

* **Ở đây mới chứa mockup**, không nằm ở concept.
* Mỗi `*-screen.md` mô tả:

  * Fields
  * Validation
  * State (view/edit/readonly)
  * Interaction (button → action → API)

AI có thể dùng:

* Spec + API + UI spec → generate code `view.html`, `controller.js`, `data.json` (đúng kiểu bạn đang làm Absence/Comp Core).

---

### `06-tests/` – Test & scenario

```text
/docs/01-modules/time-absence/absence/06-tests
  01-acceptance-criteria.md
  02-test-scenarios.md
  03-playwright-specs/
    leave-type.e2e.md
  04-test-data.yaml
```

* Là nơi QA + AI cùng sinh test.
* Có thể generate từ các scenario ở `02-spec`.

---

### `07-impl-notes/` – Ghi chú dev / quyết định design

```text
/docs/01-modules/time-absence/absence/07-impl-notes
  tech-decisions.md          # ADR – Architectural Decision Records
  limitations.md
  future-todos.md
```

Để team không “quên lý do” đã chọn design X/Y.

---

## 4. Kết luận ngắn gọn cho câu hỏi của bạn

> **Nên tổ chức theo MODULE**, trong mỗi module có phân tầng:
> `00-ontology → 01-concept → 02-spec → 03-design → 04-api → 05-ui → 06-tests`.

* Ontology: tầng cấu trúc domain, JSON/YAML + glossary MD.
* Concept: Overview, Conceptual Guide, Comprehensive Concept.
* Spec: behaviour, scenario, system spec.
* Design: DBML, event model, integration.
* API: OpenAPI.
* UI: **đây mới là nơi mockup xuất hiện**.
* Tests: acceptance, e2e, test scripts.

Thêm top-level `/00-global` cho ontology & chuẩn chung; và `_templates`, `_ai-prompts` để feed AI.

---

Nếu bạn muốn, ở bước tiếp theo mình có thể:

* Soạn **sẵn một bộ folder & file trống cho module Absence** (với template nội dung từng file),
* Hoặc **viết mẫu đầy đủ cho 1 entity (LeaveType)**: ontology YAML → concept entity guide → spec → DBML → OpenAPI → UI spec, để bạn dùng làm “chuẩn vàng” cho cả team.
