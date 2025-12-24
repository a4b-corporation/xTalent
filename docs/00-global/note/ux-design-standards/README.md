# Enterprise HCM UX Design Standards

> **Version:** 2.0.0  
> **Last Updated:** 2024-12-24  
> **Reference Solutions:** SAP SuccessFactors (Fiori), Workday, Oracle HCM Cloud (Redwood)

---

## Tổng Quan

Tài liệu này định nghĩa các tiêu chuẩn UX design cho xTalent HCM Solution, được xây dựng dựa trên nghiên cứu và tham khảo các giải pháp HCM enterprise hàng đầu thế giới.

## Hierarchy

```
Application
├── Shell (Header + Left Nav + Content Area)
│   ├── Header Bar
│   ├── Left Navigation Menu
│   └── Content Area
│       └── Page
│           ├── Page Header (Breadcrumb + Title + Actions)
│           ├── Page Body
│           │   ├── Tabs / Sections
│           │   ├── Cards / Widgets
│           │   └── Tables / Forms
│           └── Page Footer (optional)
```

---

## Document Structure

### `00-shell-framework/` - Application Shell Standards

| File | Nội dung |
|------|----------|
| [00-README.md](./00-shell-framework/00-README.md) | Shell framework overview |
| [01-shell-layout.md](./00-shell-framework/01-shell-layout.md) | Application Shell & Layout |
| [02-navigation-menu.md](./00-shell-framework/02-navigation-menu.md) | Left Navigation Menu Tree |
| [03-app-module-switcher.md](./00-shell-framework/03-app-module-switcher.md) | App & Module Switcher |
| [04-search-bar.md](./00-shell-framework/04-search-bar.md) | Global Search Bar |
| [05-command-palette.md](./00-shell-framework/05-command-palette.md) | Command Palette (Cmd+K) |
| [06-header-toolbar.md](./00-shell-framework/06-header-toolbar.md) | Header & Toolbar |
| [07-responsive-mobile.md](./00-shell-framework/07-responsive-mobile.md) | Responsive & Mobile |

---

### `01-page-patterns/` - Page Type Standards

| File | Nội dung | Use Cases |
|------|----------|-----------|
| [00-overview.md](./01-page-patterns/00-overview.md) | Page patterns overview | - |
| [01-master-data-page.md](./01-page-patterns/01-master-data-page.md) | Master Data pages | Employee, Department, Location |
| [02-transaction-page.md](./01-page-patterns/02-transaction-page.md) | Transaction pages | Leave Request, Payroll Run |
| [03-wizard-page.md](./01-page-patterns/03-wizard-page.md) | Multi-step wizards | Onboarding, Enrollment |
| [04-workflow-page.md](./01-page-patterns/04-workflow-page.md) | Workflow & Approval pages | Leave Approval, Timesheets |
| [05-config-page.md](./01-page-patterns/05-config-page.md) | Configuration screens | Settings, Policies |
| [06-dashboard-page.md](./01-page-patterns/06-dashboard-page.md) | Dashboard & Analytics | HR Dashboard, Self-service |

---

### `02-content-layouts/` - Content Layout Standards

| File | Nội dung |
|------|----------|
| [01-tabs-layout.md](./02-content-layouts/01-tabs-layout.md) | Tab-based content |
| [02-split-view.md](./02-content-layouts/02-split-view.md) | Master-Detail split view |
| [03-card-grid.md](./02-content-layouts/03-card-grid.md) | Card/Widget grid layouts |
| [04-form-layout.md](./02-content-layouts/04-form-layout.md) | Form arrangements |
| [05-table-layout.md](./02-content-layouts/05-table-layout.md) | Data table layouts |

---

### `03-interaction-modes/` - Interaction Mode Standards

| File | Nội dung |
|------|----------|
| [01-view-mode.md](./03-interaction-modes/01-view-mode.md) | Read-only display mode |
| [02-edit-mode.md](./03-interaction-modes/02-edit-mode.md) | Inline/Form editing mode |
| [03-create-mode.md](./03-interaction-modes/03-create-mode.md) | New record creation mode |

---

## Quick Reference Matrix

| Page Type | Layout | Modes | Common Actions |
|-----------|--------|-------|----------------|
| **Master Data List** | Table + Toolbar | View | Filter, Export, Create |
| **Master Data Detail** | Tabs + Sections | View/Edit | Edit, Delete, Actions |
| **Transaction Form** | Form | Create/Edit | Save, Submit, Cancel |
| **Wizard** | Steps + Content | Create | Next, Back, Cancel, Complete |
| **Workflow** | Split + Cards | View/Action | Approve, Reject, Comment |
| **Config** | Tabs + Forms | View/Edit | Save, Reset |
| **Dashboard** | Widget Grid | View | Customize, Drill-down |

---

## Industry Benchmarks

| Platform | Design System | Key Patterns |
|----------|--------------|--------------|
| **SAP SuccessFactors** | Fiori | List Report, Object Page, Wizard |
| **Workday** | Workday Canvas | Landing Page, Related Actions |
| **Oracle HCM** | Redwood | Navigator, Smart Actions |

---

## Cách Sử Dụng

### Khi Design một Page mới:

1. **Xác định Page Pattern** → Xem [01-page-patterns/00-overview.md](./01-page-patterns/00-overview.md)
2. **Chọn Content Layout** → Xem [02-content-layouts/](./02-content-layouts/)
3. **Xác định Interaction Modes** → Xem [03-interaction-modes/](./03-interaction-modes/)
4. **Áp dụng Shell Framework** → Xem [00-shell-framework/](./00-shell-framework/)

### Workflow:

```
Requirement → Page Pattern → Content Layout → Interaction Mode → Implementation
      ↓             ↓              ↓                 ↓
   Use Case    Master Data?    Tabs/Split?      View/Edit?
               Transaction?    Cards/Table?     Create?
               Wizard?
```

### Rule ID Convention:

| Prefix | Scope |
|--------|-------|
| `HL-` | Header Layout |
| `LN-` | Left Navigation |
| `NAV-` | Navigation Menu |
| `AS-` | App Switcher |
| `MS-` | Module Switcher |
| `SR-` | Search |
| `ML-` | Master List |
| `MD-` | Master Detail |
| `TF-` | Transaction Form |
| `WZ-` | Wizard |
| `WF-` | Workflow |
| `CF-` | Config |
| `DB-` | Dashboard |
| `TB-` | Tabs |
| `SV-` | Split View |
| `CG-` | Card Grid |
| `FL-` | Form Layout |
| `TL-` | Table Layout |
| `VM-` | View Mode |
| `EM-` | Edit Mode |
| `CM-` | Create Mode |
