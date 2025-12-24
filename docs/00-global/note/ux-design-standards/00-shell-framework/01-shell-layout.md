# Application Shell & Layout Standards

> Quy định về cấu trúc layout chính của ứng dụng xTalent

---

## 1. Shell Architecture

### 1.1 Cấu Trúc Chuẩn

```
┌─────────────────────────────────────────────────────────────────────┐
│ HEADER BAR (56px fixed)                                             │
├────────────┬────────────────────────────────────────────────────────┤
│            │                                                        │
│  LEFT NAV  │         MAIN CONTENT AREA                              │
│  (240px)   │         (flex, responsive)                             │
│            │                                                        │
│  Collaps-  │                                                        │
│  ible to   │                                                        │
│  56px      │                                                        │
│            │                                                        │
└────────────┴────────────────────────────────────────────────────────┘
```

### 1.2 Dimensions

| Element | Width/Height | Behavior |
|---------|--------------|----------|
| Header Bar | 100% × 56px | Fixed, always visible |
| Left Nav (Expanded) | 240px × 100% | Collapsible |
| Left Nav (Collapsed) | 56px × 100% | Icon-only mode |
| Content Area | Flex | Responsive |
| Minimum Content Width | 320px | For mobile |

---

## 2. Header Bar Layout

### 2.1 Structure

```
┌─────────────────────────────────────────────────────────────────────┐
│ [≡] [App] │ [Logo] [Module Switcher] │ [──Search Bar──] │ [🔔][?][👤]│
│           │        xTalent           │                   │           │
└─────────────────────────────────────────────────────────────────────┘
  Zone 1        Zone 2                     Zone 3            Zone 4
```

| Zone | Nội dung | Alignment |
|------|----------|-----------|
| **Zone 1** | Menu Toggle + App Switcher | Left |
| **Zone 2** | Logo + Module Switcher | Left |
| **Zone 3** | Global Search (Cmd+K) | Center/Expand |
| **Zone 4** | Notifications, Help, User Profile | Right |

### 2.2 Quy Định

| Mã | Quy định | Bắt buộc |
|----|----------|----------|
| HL-01 | Header Bar PHẢI cố định (sticky) khi scroll | ✅ |
| HL-02 | Logo PHẢI luôn hiển thị và dẫn về Dashboard | ✅ |
| HL-03 | Search Bar PHẢI có keyboard shortcut (Cmd/Ctrl+K) | ✅ |
| HL-04 | Notifications badge PHẢI hiển thị số chưa đọc | ✅ |
| HL-05 | User Profile dropdown PHẢI chứa: Settings, Logout | ✅ |

---

## 3. Left Navigation Panel

### 3.1 States

| State | Width | Content |
|-------|-------|---------|
| **Expanded** | 240px | Full icons + labels |
| **Collapsed** | 56px | Icons only + tooltips |
| **Hidden** | 0px | Mobile drawer mode |

### 3.2 Collapse Behavior

```javascript
// Rules
Rule LN-01: Collapse trigger = hamburger icon OR screen < 1024px
Rule LN-02: Collapsed state preserves icon visibility
Rule LN-03: Hover on collapsed item shows tooltip with label
Rule LN-04: User preference SHOULD be persisted in localStorage
```

---

## 4. Content Area

### 4.1 Page Structure

```
┌─────────────────────────────────────────────────────────────────────┐
│ [Breadcrumb]                                   [Page-level Actions] │
├─────────────────────────────────────────────────────────────────────┤
│ [Page Title]                                                        │
│ [Page Subtitle/Description - optional]                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│                     Page Content                                    │
│                                                                     │
│   ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │
│   │ Card / Section   │  │ Card / Section   │  │ Card / Section   │  │
│   └──────────────────┘  └──────────────────┘  └──────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.2 Spacing System (8px Grid)

| Token | Value | Usage |
|-------|-------|-------|
| `spacing-xs` | 4px | Tight spacing |
| `spacing-sm` | 8px | Small gaps |
| `spacing-md` | 16px | Standard |
| `spacing-lg` | 24px | Section gaps |
| `spacing-xl` | 32px | Large sections |
| `spacing-2xl` | 48px | Page margins |

---

## 5. Responsive Breakpoints

| Breakpoint | Width | Layout Changes |
|------------|-------|----------------|
| **Mobile** | < 768px | Nav hidden → drawer, single column |
| **Tablet** | 768-1024px | Nav collapsed, 2-column possible |
| **Desktop** | 1024-1440px | Nav expanded, multi-column |
| **Large** | > 1440px | Max content width 1440px, centered |

---

## 6. Z-Index Hierarchy

| Layer | Z-Index | Elements |
|-------|---------|----------|
| Base | 0 | Content |
| Dropdown | 100 | Menus, selects |
| Sticky | 200 | Header, nav |
| Overlay | 300 | Modals backdrop |
| Modal | 400 | Modal content |
| Popover | 500 | Tooltips, popovers |
| Toast | 600 | Notifications |
| Command Palette | 700 | Cmd+K overlay |

---

## 7. Reference: Enterprise Patterns

| Platform | Shell Pattern |
|----------|---------------|
| **SAP Fiori** | Shell Bar + Tool Page Layout |
| **Workday** | Global Navigation + Content Area |
| **Oracle Redwood** | Navigator + Springboard Pattern |

### Workday Reference

```
┌──────────────────────────────────────────────────────────────────────┐
│ [☰] Workday    [──Search──]                          [🔔] [👤] [⚙️] │
├─────────┬────────────────────────────────────────────────────────────┤
│ Home    │                                                            │
│ People  │   Dashboard with Worklets                                  │
│ Money   │   ┌─────────┐ ┌─────────┐ ┌─────────┐                      │
│ Time    │   │ Widget  │ │ Widget  │ │ Widget  │                      │
│ Career  │   └─────────┘ └─────────┘ └─────────┘                      │
│ ★ Fav   │                                                            │
│         │                                                            │
└─────────┴────────────────────────────────────────────────────────────┘
```

---

## See Also

| Document | Relationship |
|----------|--------------|
| [02-navigation-menu.md](./02-navigation-menu.md) | Chi tiết Left Navigation |
| [06-header-toolbar.md](./06-header-toolbar.md) | Chi tiết Header Bar |
| [07-responsive-mobile.md](./07-responsive-mobile.md) | Responsive behaviors |
| [../01-page-patterns/](../01-page-patterns/) | Nội dung trong Content Area |
| [../02-content-layouts/03-card-grid.md](../02-content-layouts/03-card-grid.md) | Card/Section layouts |
| [../02-content-layouts/05-table-layout.md](../02-content-layouts/05-table-layout.md) | Table layouts |
