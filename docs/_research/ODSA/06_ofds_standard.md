# OFDS — Feature Documentation Standard v1

> **Mục tiêu:** Chuẩn hoá cấu trúc thư mục, tên file, templates và conventions cho tầng Feature Documentation trong hệ sinh thái ODSA.

---

## 1. Cấu trúc thư mục chuẩn

Thư mục `features/` được thêm vào bên cạnh `ontology/`, `design/`, `system/` của ODDS:

```text
module_name/
│
├── ontology/           ← ODDS v1 (Ontology Layer)
│   ├── concepts/
│   ├── relationships.yaml
│   ├── lifecycle.yaml
│   └── rules.yaml
│
├── design/             ← ODDS v1 (Narrative Docs)
│   ├── purpose.md
│   ├── use_cases.md
│   ├── workflows.md
│   └── api_intent.md
│
├── system/             ← ODDS v1 (Implementation Skeleton)
│   ├── db.dbml
│   ├── canonical_api.openapi.yaml
│   └── events.yaml
│
├── governance/         ← ODDS v1
│   └── metadata.yaml
│
└── features/           ← OFDS (Feature Documentation Layer) ← MỚI
    ├── catalog.md          ← Module Feature Catalog
    ├── abs/                ← Sub-module folder (viết tắt sub-module)
    │   ├── index.md        ← Sub-module Feature Index
    │   ├── ABS-LR-001.fsd.md  ← Feature Spec (1 file = 1 feature)
    │   ├── ABS-LR-002.fsd.md
    │   ├── ABS-APR-001.fsd.md
    │   └── ...
    ├── att/
    │   ├── index.md
    │   ├── ATT-TT-001.fsd.md
    │   └── ...
    └── shared/             ← Features dùng chung giữa sub-modules
        ├── index.md
        └── SH-CAL-001.fsd.md
```

---

## 2. Naming Conventions

### Feature ID Format

```text
{SUB-MODULE}-{CATEGORY}-{NNN}

Ví dụ:
  ABS-LR-001   → Absence, Leave Request, #001
  ABS-APR-002  → Absence, Approval, #002
  ATT-TT-001   → Attendance, Time Tracking, #001
  SH-CAL-001   → Shared, Calendar, #001
```

### File Naming

```text
Features folder:   snake_case/
Feature Spec file: {FEATURE-ID}.fsd.md    (e.g., ABS-LR-001.fsd.md)
Catalog:           catalog.md
Index:             index.md
```

### Status Lifecycle

```text
Identified → Specified → Reviewed → Ready → In Dev → Done → Deprecated
```

| Status | Ý nghĩa | Người chịu trách nhiệm |
|--------|---------|----------------------|
| `Identified` | Đã liệt kê, chưa có spec | BA/PO |
| `Specified` | Đã viết đủ 9 thành phần | BA/PO |
| `Reviewed` | Đã qua Domain + Architecture Review | Architect |
| `Ready` | Sẵn sàng để dev implement | Dev Lead |
| `In Dev` | Đang phát triển | Developer |
| `Done` | Đã xong, merge vào main | Dev Lead |
| `Deprecated` | Không còn sử dụng | BA/PO |

---

## 3. Feature Catalog (`catalog.md`)

### Mục đích

Cái nhìn tổng quan toàn bộ features của module: tổng số, phân phối theo priority, gap analysis, cross-reference với ontology concepts chính.

### Template

```markdown
# Feature Catalog: {Module Name}

## Document Information

| Field | Value |
|-------|-------|
| **Module** | {Module Name} ({Module Code}) |
| **Version** | {X.Y} |
| **Tổng số features** | {N} |
| **Số sub-modules** | {N} |
| **Ngày cập nhật** | {YYYY-MM-DD} |
| **Status** | Draft / Active |

---

## Tổng quan kiến trúc feature

```text
{Module}
├── {Sub-module 1}
│   ├── {Category A}
│   └── {Category B}
└── {Sub-module 2}
    └── {Category C}
```

---

## Feature Distribution

| Sub-module | Category | Count | P0 | P1 | P2 |
|-----------|---------|-------|----|----|-----|
| {SUB-1} | {CAT-A} | {N} | {N} | {N} | {N} |
| **TOTAL** | — | **{N}** | **{N}** | **{N}** | **{N}** |

## Gap Analysis Summary

| Gap Type | Count | Strategy |
|----------|-------|----------|
| Standard Fit | {N} | Configure only |
| Config Gap | {N} | Customize config |
| Extension Gap | {N} | Build extension |
| **Core Gap** | {N} | **ARB approval required** |

## Ontology Concepts Mapping

| Feature Category | Primary Concepts | Rules |
|----------------|-----------------|-------|
| {Category} | {Concept1, Concept2} | {rule_id_1, rule_id_2} |

---

## Feature Index toàn module

| ID | Feature Name | Sub-module | Priority | Status | Gap Type |
|----|-------------|-----------|---------|--------|---------|
| {ID} | {Name} | {SUB} | {Px} | {Status} | {Type} |

---

## Cross-references

- **Ontology Layer:** `../ontology/`
- **Sub-module Indexes:**
  - [{SUB-1} Index](./{sub-1}/index.md)
  - [{SUB-2} Index](./{sub-2}/index.md)
```

---

## 4. Feature Index (`index.md` per sub-module)

### Mục đích

Danh sách tất cả features trong một sub-module, tổ chức theo category, với priority breakdown và dependency overview.

### Template

```markdown
# Feature Index: {Sub-module Name} ({SUB-CODE})

## Sub-module Overview

**Mục đích:** {Mô tả ngắn gọn sub-module làm gì}

**Số lượng features:** {N} | **Categories:** {N}

| Category | Code | Count | Priority |
|---------|------|-------|---------|
| {Category Name} | {CAT} | {N} | P0: {N}, P1: {N}, P2: {N} |

---

## Category {CAT-01}: {Category Name}

**Mục đích:** {Mô tả}

| ID | Feature Name | Priority | Status | Dependencies |
|----|-------------|---------|--------|-------------|
| [{ID}](./{ID}.fsd.md) | {Name} | {Px} | {Status} | {IDs} |

---

## Category {CAT-02}: {Category Name}

...

---

## Ontology References

| Ontology Artifact | Path |
|------------------|------|
| Primary Concepts | [`../ontology/concepts/{concept}.yaml`](../ontology/concepts/{concept}.yaml) |
| Lifecycle | [`../ontology/lifecycle.yaml`](../ontology/lifecycle.yaml) |
| Rules | [`../ontology/rules.yaml`](../ontology/rules.yaml) |
| Events | [`../system/events.yaml`](../system/events.yaml) |
```

---

## 5. Feature Specification Document (`*.fsd.md`)

### Mục đích

Spec đầy đủ cho **một feature cụ thể** — đủ để dev implement, QA test, và designer mockup mà không cần hỏi thêm.

### YAML Frontmatter (Machine-readable metadata)

```yaml
---
id: {FEATURE-ID}
name: {Feature Name}
module: {MODULE_CODE}
sub_module: {SUB_CODE}
category: {Category Name}
priority: P0  # P0 | P1 | P2
status: Specified  # Identified | Specified | Reviewed | Ready | In Dev | Done
differentiation: Parity  # Parity | Innovation | Compliance
gap_type: Standard Fit  # Standard Fit | Config Gap | Extension Gap | Core Gap
phase: 1  # Release phase: 1 | 2 | 3

ontology_refs:
  concepts:
    - {ConceptName}
  rules:
    - {rule_id}
  lifecycle: {LifecycleName}
  events:
    - {EventName}

dependencies:
  requires:
    - {FEATURE-ID}: "{reason}"
  required_by:
    - {FEATURE-ID}: "{reason}"
  external:
    - "{External system or service}"

created: {YYYY-MM-DD}
updated: {YYYY-MM-DD}
author: {Name}
---
```

### Document Sections (9 thành phần)

```markdown
# {FEATURE-ID}: {Feature Name}

> {Mô tả ngắn 1 dòng — feature làm gì, cho ai}

---

## 1. Business Context

### Problem Statement
{Mô tả vấn đề kinh doanh mà feature này giải quyết}

### Job Story
> Khi **{ngữ cảnh cụ thể}**, tôi muốn **{thực hiện hành động}**, để tôi có thể **{đạt được lợi ích}**.

### Success Metrics
| Metric | Framework | Target |
|--------|----------|--------|
| {Metric name} | HEART / AARRR | {Value} |

---

## 2. UI Workflow & Mockup

### Screen Flow
```text
[Entry Point] → [Step 1] → [Step 2] → [Exit Point]
                               ↓
                         [Error State]
```

### Mockup

> Format: A2UI JSON DSL (AI Mockup Builder — 30 components)

```json
{
  "type": "page",
  "theme": "light",
  "children": [
    ...
  ]
}
```

### Micro UI States

**Empty State:**
- Message: "{Khi chưa có dữ liệu, hiển thị gì}"
- CTA: "{Nút hoặc link dẫn đến hành động}"

**Error State:**
- Lỗi validation: "{Thông báo}"
- Lỗi hệ thống: "{Thông báo}"

**Loading State:**
- Spinner / Skeleton: "{Mô tả}"
- Disable buttons: Yes/No

---

## 3. System Events

| Event | Trigger | Actor | Payload |
|-------|---------|-------|---------|
| `{EventName}` | {When} | {Who} | {Fields} |

**Event Flow:**
```text
[Actor] → Command: {CommandName}
         → System processes...
         → Event: {EventName} emitted
         → Policy: {What happens next}
```

*Reference: [`../system/events.yaml`](../system/events.yaml)*

---

## 4. Business Rules

### Rule References (from Ontology)

| Rule ID | Description | Severity |
|---------|-------------|---------|
| [`{rule_id}`](../ontology/rules.yaml) | {Description} | Error / Warning |

### Feature-specific Rules

> Chỉ viết rules KHÔNG có trong `ontology/rules.yaml`

| Rule | Condition | Action |
|------|-----------|--------|
| {Description} | If {condition} | Then {action} |

### Decision Table

| Condition A | Condition B | Result |
|------------|------------|--------|
| True | True | {Output} |
| True | False | {Output} |

---

## 5. NFRs & Constraints

### Non-Functional Requirements

| Chất lượng (ISO 25010) | Yêu cầu | Đo lường |
|----------------------|---------|---------|
| Performance | Response time ≤ {Xms} at P95 | Load test |
| Security | {Requirement} | Security audit |
| Usability | {Requirement} | User testing |

### Constraints

| Loại | Constraint |
|------|-----------|
| Technical | {e.g., "Phải tương thích với API version hiện tại"} |
| Business | {e.g., "Không thay đổi UI đang dùng"} |
| Regulatory | {e.g., "Tuân thủ GDPR"} |

---

## 6. Dependency Map

### Internal Dependencies

```text
{THIS FEATURE} depends on:
  → {FEATURE-ID}: {reason} [Finish-to-Start]

{THIS FEATURE} is required by:
  ← {FEATURE-ID}: {reason}
```

### External Dependencies

- **{External system}:** {reason and risk level}

---

## 7. Edge & Corner Cases

### Edge Cases (1 biến số cực đoan)

| Case | Input Condition | Expected Behavior |
|------|----------------|------------------|
| {Name} | {Condition} | {Expected} |

### Corner Cases (≥2 biến số cực đoan đồng thời)

| Case | Conditions | Handling Strategy |
|------|-----------|-----------------|
| {Name} | {Condition A} + {Condition B} | Exception handler |

### Edge Case Checklist

- [ ] Input boundary: max/min values tested
- [ ] Special characters / SQL injection potential
- [ ] Concurrent access / race conditions
- [ ] Session expiry during operation
- [ ] Permission boundary violations

---

## 8. Acceptance Criteria

> Format: Gherkin BDD (Declarative, not imperative)

```gherkin
Feature: {Feature Name}

  Background:
    Given {Common precondition for all scenarios}

  Scenario: {Happy Path}
    Given {Initial state}
    When {User action}
    Then {Expected outcome}
    And {Additional outcome}

  Scenario: {Error / Edge Case}
    Given {State}
    When {Boundary action}
    Then {Error handling}
```

---

## 9. Release Planning

| Phase | Target Users | Scope | Criteria |
|-------|-------------|-------|---------|
| **Alpha** (Private) | Internal team | Core happy path | No breaking errors |
| **Beta** (Public Preview) | Opt-in users | Full feature + edge cases | NFRs met |
| **GA** | All users | Feature-complete | 100% AC passed |

**Out of scope (v1):**
- {Feature / behavior NOT included in this version}
```

---

## 6. Review Process cho OFDS

```text
Identified → Specified → Domain Review → Architecture Review → Ready
```

| Stage | Reviewer | Checklist |
|-------|---------|----------|
| **Specified** | BA/PO | Đủ 9 thành phần, ontology refs chính xác |
| **Domain Review** | PO / Lead BA | Job story đúng, business rules đủ |
| **Architecture Review** | Architect | Events đủ payload, NFRs khả thi |
| **Ready** | Dev Lead | Feature đủ để implement mà không cần hỏi thêm |

### Review Checklist cho mỗi Feature Spec

**Domain Review:**
- [ ] Job Story rõ ràng, người dùng và ngữ cảnh xác định được
- [ ] Ontology refs chính xác (concepts, rules, events tồn tại)
- [ ] Business rules đủ (không thiếu rule quan trọng)
- [ ] Edge cases covers các tình huống thực tế

**Architecture Review:**
- [ ] Events có đủ payload cho downstream consumers
- [ ] NFRs có thể đo lường và kiểm tra được
- [ ] Mockup A2UI JSON hợp lệ
- [ ] Dependencies không tạo circular reference

---

## 7. Anti-patterns cần tránh

| Anti-pattern | Vấn đề | Cách đúng |
|-------------|--------|----------|
| Viết lại business rules đã có trong `rules.yaml` | Duplicate, dễ mâu thuẫn | Chỉ reference với link |
| Feature spec không có Acceptance Criteria | QA không biết test gì | Gherkin AC bắt buộc |
| Gộp nhiều feature vào 1 file | Khó kiểm soát thay đổi | 1 file = 1 feature |
| Mockup không theo A2UI DSL | Không machine-readable | Luôn dùng A2UI JSON format |
| Không điền `ontology_refs` | AI Agent không link được | YAML frontmatter bắt buộc |
| Status mãi là `Identified` | Feature không được specify | Cần spec trước Ready |
