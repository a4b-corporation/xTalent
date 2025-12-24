# Page Patterns Overview

> Hướng dẫn chọn và áp dụng đúng page pattern cho từng use case

---

## 1. Page Pattern Matrix

| Pattern | Use Case | Data Type | User Goal |
|---------|----------|-----------|-----------|
| **Master Data** | List & manage entities | Reference data | Browse, Find, Maintain |
| **Transaction** | Create/Edit records | Transactional | Submit, Modify |
| **Wizard** | Multi-step processes | Complex input | Complete guided flow |
| **Workflow** | Approvals & actions | Pending items | Review, Decide |
| **Config** | System settings | Configuration | Customize |
| **Dashboard** | Overview & metrics | Aggregated | Monitor, Analyze |

---

## 2. Decision Tree

```
Start
  │
  ├── Need to manage a list of entities?
  │     └── YES → Master Data Pattern (01)
  │
  ├── Creating/Editing a single record?
  │     └── YES → Is it multi-step?
  │                 ├── YES → Wizard Pattern (03)
  │                 └── NO → Transaction Pattern (02)
  │
  ├── Reviewing items for approval?
  │     └── YES → Workflow Pattern (04)
  │
  ├── Changing system settings?
  │     └── YES → Config Pattern (05)
  │
  └── Viewing overview/metrics?
        └── YES → Dashboard Pattern (06)
```

---

## 3. Pattern Components

### 3.1 Common Page Structure

```
┌─────────────────────────────────────────────────────────────────────┐
│ [Breadcrumb: Module > Sub-module > Page]                            │
├─────────────────────────────────────────────────────────────────────┤
│ [Page Title]                                    [Action Buttons]    │
│ [Subtitle / Description - optional]                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│                    PAGE BODY (pattern-specific)                     │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│ [Page Footer - optional: pagination, save bar, etc.]                │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 Components by Pattern

| Pattern | Header Actions | Body Layout | Footer |
|---------|----------------|-------------|--------|
| Master Data List | Create, Export | Toolbar + Table | Pagination |
| Master Data Detail | Edit, Delete | Tabs + Sections | - |
| Transaction | Save, Cancel | Form | Action Bar |
| Wizard | Cancel | Steps + Content | Navigation |
| Workflow | Approve, Reject | Split + Cards | - |
| Config | Save, Reset | Tabs + Forms | Action Bar |
| Dashboard | Customize | Widget Grid | - |

---

## 4. Industry Pattern Mapping

| xTalent Pattern | SAP Fiori Floorplan | Workday Equivalent |
|-----------------|---------------------|-------------------|
| Master Data List | List Report | Landing Page |
| Master Data Detail | Object Page | Worker Profile |
| Transaction | Form Entry | Task Page |
| Wizard | Wizard | Multi-Step Process |
| Workflow | Worklist | Inbox |
| Config | Settings | Tenant Setup |
| Dashboard | Overview Page | Home Page |

---

## 5. Navigation Flow

```
Dashboard ←→ Master Data List ←→ Master Data Detail
                    ↓                    ↓
              Transaction           Edit Mode
                    │
                    ├── Simple Form
                    │
                    └── Wizard (if complex)
                            ↓
                      Confirmation
                            ↓
                      Workflow (if approval needed)
```

---

## 6. Quy Định Chung

| Mã | Quy định | Áp dụng |
|----|----------|---------|
| PP-01 | Mỗi page PHẢI có breadcrumb navigation | All |
| PP-02 | Page title PHẢI rõ ràng và mô tả context | All |
| PP-03 | Primary action ở góc phải của header | All |
| PP-04 | Loading state cho async operations | All |
| PP-05 | Error handling với user-friendly messages | All |
| PP-06 | Responsive layout cho mobile | All |
