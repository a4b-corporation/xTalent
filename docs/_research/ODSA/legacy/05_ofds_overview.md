# OFDS — Ontology-driven Feature Documentation Standard

> **Tổng quan:** Document này giải thích lý do tại sao Ontology (ODDS) chưa đủ để phát triển ứng dụng, và OFDS — tầng Feature Documentation — được thiết kế để bổ sung như thế nào trong hệ sinh thái ODSA.

---

## 1. Vấn đề: Khoảng trống giữa Ontology và Development

ODDS v1 cung cấp nền tảng vững chắc cho domain knowledge: entities, lifecycle, business rules, relationships. Tuy nhiên, Ontology chỉ trả lời câu hỏi **"Hệ thống biết gì?"** — không phải **"Hệ thống làm gì cho người dùng?"**

| Câu hỏi | ODDS (Ontology) | OFDS (Feature) |
|---------|----------------|----------------|
| Entity `LeaveRequest` có những thuộc tính gì? | ✅ `ontology/concepts/leave_request.yaml` | — |
| Lifecycle của `LeaveRequest` gồm những state nào? | ✅ `ontology/lifecycle.yaml` | — |
| Business rule nào áp dụng khi submit đơn nghỉ? | ✅ `ontology/rules.yaml` | References |
| Nhân viên tạo đơn nghỉ trải qua những bước UI nào? | ❌ Không có | ✅ Feature Spec |
| Màn hình khi balance = 0 hiển thị gì? | ❌ Không có | ✅ Feature Spec |
| Acceptance Criteria để QA test tính năng này? | ❌ Không có | ✅ Feature Spec |
| Tính năng nào phụ thuộc vào tính năng nào? | ❌ Không có | ✅ Feature Spec |
| Mockup giao diện của màn hình này là gì? | ❌ Không có | ✅ Feature Spec |

> **Kết luận:** Ontology là nền tảng ngữ nghĩa. Feature Spec là bản thiết kế thực thi. Cả hai đều cần thiết — và phải liên kết chặt chẽ.

---

## 2. Mô hình 2 Tầng trong ODSA

```text
┌─────────────────────────────────────────────────────────┐
│                    FEATURE LAYER (OFDS)                 │
│                                                         │
│  Module Catalog → Sub-module Index → Feature Spec       │
│                                                         │
│  Trả lời: "Hệ thống làm gì cho người dùng?"            │
│  Audience: BA, Dev, QA, Designer                        │
└─────────────────────────────┬───────────────────────────┘
                              │ References & Links
┌─────────────────────────────▼───────────────────────────┐
│                   ONTOLOGY LAYER (ODDS)                 │
│                                                         │
│  concepts/ → lifecycle.yaml → rules.yaml → events.yaml  │
│                                                         │
│  Trả lời: "Hệ thống biết gì / được gì?"                │
│  Audience: Architect, BA, Dev                           │
└─────────────────────────────────────────────────────────┘
```

**Nguyên tắc cốt lõi:** Feature docs KHÔNG sao chép ontology — chúng **tham chiếu** tới ontology. Một Feature Spec cho `Create Leave Request` sẽ viết: *"Xem business rules tại `ontology/rules.yaml#rule_balance_check`"* thay vì viết lại cả rule đó.

---

## 3. Feature Hierarchy — 4 Cấp

```text
Module (TA — Time & Absence)
└── Sub-module (ABS — Absence Management)
    └── Category (Leave Request Management)
        └── Feature (ABS-LR-001: Create Leave Request)
```

| Cấp | Tài liệu | Mục đích |
|-----|----------|----------|
| **Module** | `features/catalog.md` | Tổng quan toàn module, phân phối feature, gap analysis |
| **Sub-module** | `features/{sub}/index.md` | Danh sách features theo category, priority breakdown |
| **Category** | (Trong index.md) | Nhóm logic các feature liên quan |
| **Feature** | `features/{sub}/{FEATURE-ID}.fsd.md` | Spec chi tiết cho từng tính năng (1 file = 1 feature) |

---

## 4. OFDS vs ODDS — Ranh giới rõ ràng

| Thành phần | Nằm ở | Format |
|-----------|-------|--------|
| Entity attributes, data types | `ontology/concepts/*.yaml` | LinkML YAML |
| Lifecycle states & transitions | `ontology/lifecycle.yaml` | YAML |
| Business rules | `ontology/rules.yaml` | YAML |
| Domain events | `system/events.yaml` | YAML |
| DB schema | `system/db.dbml` | DBML |
| API contracts | `system/canonical_api.openapi.yaml` | OpenAPI |
| **Feature list với priority** | `features/catalog.md` | Markdown |
| **Feature dependencies** | `features/{sub}/index.md` | Markdown |
| **UI Workflow & mockup** | `features/{sub}/{ID}.fsd.md` | Markdown + A2UI JSON |
| **Acceptance Criteria (Gherkin)** | `features/{sub}/{ID}.fsd.md` | Markdown |
| **NFRs per feature** | `features/{sub}/{ID}.fsd.md` | Markdown |
| **Edge & Corner Cases** | `features/{sub}/{ID}.fsd.md` | Markdown |

---

## 5. Nguyên tắc thiết kế OFDS

### Principle 1 — Feature-as-Composition

Mỗi feature là sự **kết hợp** (composition) của các ontology concepts. Feature `Create Leave Request` không tự định nghĩa entity `LeaveRequest` — nó sử dụng concept đó từ ontology.

```text
Feature: Create Leave Request
  ↓ composes
  Concepts: LeaveRequest, LeaveType, LeaveBalance (from ontology/concepts/)
  Lifecycle: LeaveRequestLifecycle (from ontology/lifecycle.yaml)
  Rules: rule_balance_check, rule_no_overlap (from ontology/rules.yaml)
  Events: LeaveRequestCreated (from system/events.yaml)
```

### Principle 2 — Reference, Don't Duplicate

Tài liệu feature không viết lại business rules đã có trong `ontology/rules.yaml`. Chỉ **reference** với anchor link:

```markdown
**Business Rules áp dụng:**
- [`rule_balance_check`](../ontology/rules.yaml) — Số dư phải đủ trước khi submit
- [`rule_no_overlap`](../ontology/rules.yaml) — Không được trùng với đơn đã approve
```

### Principle 3 — Development-Ready

Mỗi Feature Spec phải đủ chi tiết để developer implement mà không cần hỏi thêm BA. Điều này có nghĩa:
- UI states (empty, error, loading) rõ ràng
- Acceptance Criteria dạng Gherkin đủ để QA viết test case
- Edge cases đã được xác định trước
- Mockup giao diện bằng A2UI DSL (machine-readable JSON)

### Principle 4 — Machine-Readable Metadata

Mỗi Feature Spec có YAML frontmatter chuẩn hóa để AI Agent và tooling có thể parse:

```yaml
---
id: ABS-LR-001
name: Create Leave Request
module: TA
sub_module: ABS
category: Leave Request Management
priority: P0
status: Specified  # Identified | Specified | Reviewed | Ready | In Dev | Done
ontology_refs:
  concepts: [LeaveRequest, LeaveType, LeaveBalance]
  rules: [rule_balance_check, rule_no_overlap]
  events: [LeaveRequestCreated]
dependencies:
  requires: [ABS-BAL-001]
  required_by: [ABS-LR-002]
---
```

### Principle 5 — Hierarchical Organization

Tài liệu được tổ chức theo hệ thống phân cấp 4 cấp nhất quán. Không có feature spec "floating" — mọi feature đều thuộc một category trong một sub-module.

---

## 6. Vị trí OFDS trong Pipeline ODSA

```text
STAGE 1: Idea → Ontology (ODDS)
  → Concepts, Lifecycle, Rules được định nghĩa

STAGE 2: Ontology → Feature Planning (OFDS ← MỚI)
  → Feature Catalog: liệt kê tính năng từ domain
  → Feature Index: tổ chức theo sub-module
  → Feature Specs: chi tiết từng tính năng

STAGE 3: Feature Specs → System Design
  → DB schema, API, Events được tạo từ cả ontology + feature context

STAGE 4: All Artifacts → Knowledge Graph (KnowledgeOS)
  → Feature docs được ingest vào hybrid memory
  → AI Agent query được "Feature ABS-LR-001 cần những rule nào?"

STAGE 5: Continuous Evolution
  → Khi feature thay đổi, update *.fsd.md → re-ingest
```

---

## 7. Đọc tiếp

- **[06_ofds_standard.md](./06_ofds_standard.md)** — Cấu trúc chuẩn: folder, files, templates, conventions
- **[07_ofds_feature_spec.md](./07_ofds_feature_spec.md)** — Chi tiết 9 thành phần của Feature Specification
- **[02_odds_standard.md](./02_odds_standard.md)** — ODDS v1: chuẩn tài liệu ontology
