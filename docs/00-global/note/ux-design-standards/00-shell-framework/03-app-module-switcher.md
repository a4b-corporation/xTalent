# App & Module Switcher Standards

> Quy định về nút chuyển App và chuyển Module trong Header Bar

---

## 1. Tổng Quan

Trong môi trường enterprise, người dùng thường làm việc với nhiều ứng dụng (Apps) và modules. App Switcher và Module Switcher cung cấp phương thức nhanh để chuyển đổi context.

### 1.1 Phân Biệt

| Element | Mục đích | Scope |
|---------|----------|-------|
| **App Switcher** | Chuyển giữa các ứng dụng/products | Cross-product (xTalent, xFinance, xProject...) |
| **Module Switcher** | Chuyển giữa các modules trong 1 app | Within xTalent (Core, TA, TR, Payroll...) |

### 1.2 Reference Architecture

| Platform | Pattern |
|----------|---------|
| **SAP SuccessFactors** | App Finder (9-dot grid) |
| **Workday** | Global Navigation + Domain Tabs |
| **Oracle HCM** | Navigator + Quick Actions |
| **Microsoft 365** | App Launcher (waffle menu) |
| **Google Workspace** | 3x3 dot grid |

---

## 2. App Switcher

### 2.1 Trigger & Position

```
┌─────────────────────────────────────────────────────────────────────┐
│ [⋮⋮⋮] [xTalent ▼] │ [Search...]                    │ [🔔] [👤]      │
│   │                                                                 │
│   └── App Switcher Button (position: far-left)                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 Visual Design

| Attribute | Value |
|-----------|-------|
| Icon | 3×3 dot grid (⋮⋮⋮) hoặc waffle (▦) |
| Size | 32×32px icon area |
| Position | Far-left của Header Bar |
| Trigger | Click (không phải hover) |

### 2.3 Dropdown Panel

```
┌─────────────────────────────────────────┐
│ 🔍 Search apps...                       │
├─────────────────────────────────────────┤
│ ★ Frequent Apps                         │
│ ┌────────┐  ┌────────┐  ┌────────┐      │
│ │xTalent │  │xFinance│  │xProject│      │
│ │  HCM   │  │        │  │        │      │
│ └────────┘  └────────┘  └────────┘      │
├─────────────────────────────────────────┤
│ All Apps                                │
│ ┌────────┐  ┌────────┐  ┌────────┐      │
│ │xAnalyt │  │xLearn  │  │xRecruit│      │
│ │ics    │  │  LMS   │  │  ATS   │      │
│ └────────┘  └────────┘  └────────┘      │
│ ┌────────┐  ┌────────┐  ┌────────┐      │
│ │xExpense│  │xTravel │  │Admin   │      │
│ │        │  │        │  │Console │      │
│ └────────┘  └────────┘  └────────┘      │
├─────────────────────────────────────────┤
│ [+ Add shortcuts]    [Manage apps →]    │
└─────────────────────────────────────────┘
```

### 2.4 Quy Định

| Mã | Quy định | Priority |
|----|----------|----------|
| AS-01 | App Switcher PHẢI ở vị trí far-left của Header | P0 |
| AS-02 | Panel PHẢI có search/filter box | P0 |
| AS-03 | Frequent Apps (top 3-6) PHẢI hiển thị trước | P1 |
| AS-04 | Mỗi app PHẢI có icon, name, và optional description | P0 |
| AS-05 | Current app PHẢI được highlight | P1 |
| AS-06 | External links open in new tab | P1 |
| AS-07 | Keyboard: Escape closes panel, arrows navigate | P1 |

---

## 3. Module Switcher

### 3.1 Trigger & Position

```
┌─────────────────────────────────────────────────────────────────────┐
│ [⋮⋮⋮] [xTalent] [Core ▼] │ [Search...]                │ [🔔] [👤]   │
│                    │                                                │
│                    └── Module Switcher (dropdown)                   │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 Visual Design

| Attribute | Value |
|-----------|-------|
| Format | Text button với chevron down (▼) |
| Content | Current module name |
| Position | Sau Logo, trước Search Bar |
| Trigger | Click to open dropdown |

### 3.3 Dropdown Panel

```
┌─────────────────────────────────────────┐
│ Switch Module                           │
├─────────────────────────────────────────┤
│ ✓ 👥 Core HR                            │ ← Current (checked)
│   ⏰ Time & Absence                     │
│   💰 Payroll                            │
│   🎁 Total Rewards                      │
│   📈 Performance                        │
│   📚 Learning                           │
│   🎯 Recruitment                        │
│   📊 Workforce Analytics                │
├─────────────────────────────────────────┤
│ ⭐ Favorite Modules                     │
│   ⏰ Time & Absence                     │
│   💰 Payroll                            │
└─────────────────────────────────────────┘
```

### 3.4 Quy Định

| Mã | Quy định | Priority |
|----|----------|----------|
| MS-01 | Module Switcher PHẢI hiển thị current module name | P0 |
| MS-02 | Dropdown list PHẢI sắp xếp theo logical order | P0 |
| MS-03 | Mỗi module PHẢI có icon và name | P0 |
| MS-04 | Current module có checkmark (✓) indicator | P1 |
| MS-05 | Chỉ hiển thị modules user có quyền truy cập | P0 |
| MS-06 | Chuyển module → Navigate to module homepage | P0 |
| MS-07 | Favorites section cho quick access | P2 |

---

## 4. Combined Header Layout

### 4.1 Full Header Specification

```
┌──────────────────────────────────────────────────────────────────────────┐
│ [⋮⋮⋮] │ [🏢 xTalent] │ [👥 Core HR ▼] │ [🔍 Search or press Cmd+K...] │ Actions │
│   │         │              │                      │                    │
│   │         │              │                      │                    │
│  App       Logo          Module              Global Search        User
│  Switcher                Switcher                                 Actions
│                                                                   [🔔][❓][👤]
└──────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Spacing & Sizing

| Element | Width | Spacing |
|---------|-------|---------|
| App Switcher Icon | 40px | margin-right: 8px |
| Logo Container | 120px | margin-right: 16px |
| Module Switcher | auto (min 100px) | margin-right: 24px |
| Search Bar | flex-grow | min-width: 200px |
| Action Icons | 40px each | spacing: 8px |

---

## 5. Interaction Patterns

### 5.1 Click Behavior

| Action | Result |
|--------|--------|
| Click App Switcher | Open grid panel |
| Click App in panel | Navigate to app (new context) |
| Click Module Switcher | Open dropdown |
| Click Module in dropdown | Navigate to module homepage |
| Click outside | Close any open panel |
| Press Escape | Close any open panel |

### 5.2 Animation

| Transition | Duration | Easing |
|------------|----------|--------|
| Panel open | 200ms | ease-out |
| Panel close | 150ms | ease-in |
| Hover highlight | 100ms | linear |

---

## 6. Context Preservation

### 6.1 Khi Chuyển Module

| Mã | Quy định |
|----|----------|
| CP-01 | Chuyển module → Điều hướng về homepage của module mới |
| CP-02 | Breadcrumb reset về module level |
| CP-03 | Left Nav refresh với menu của module mới |
| CP-04 | Preserve user session và auth state |

### 6.2 Khi Chuyển App

| Mã | Quy định |
|----|----------|
| CP-05 | Chuyển app → Full page reload HOẶC SPA routing |
| CP-06 | SSO token phải được share across apps |
| CP-07 | User preferences per app độc lập |

---

## 7. Mobile Considerations

| Screen Size | Behavior |
|-------------|----------|
| **< 768px** | Module Switcher → trong Hamburger menu |
| **< 768px** | App Switcher → collapsed vào More menu |
| **≥ 768px** | Cả hai visible trong header |

---

## 8. Accessibility

| Requirement | Implementation |
|-------------|----------------|
| ARIA role | `role="menu"` cho dropdown |
| Keyboard | Arrow keys, Enter, Escape |
| Focus trap | Khi panel mở, focus bên trong |
| Screen reader | Announce "Switch to [App/Module] name" |

---

## See Also

| Document | Relationship |
|----------|--------------|
| [01-shell-layout.md](./01-shell-layout.md) | Header Bar layout context |
| [02-navigation-menu.md](./02-navigation-menu.md) | Menu updates on module switch |
| [06-header-toolbar.md](./06-header-toolbar.md) | Other header components |
| [../01-page-patterns/06-dashboard-page.md](../01-page-patterns/06-dashboard-page.md) | Module landing pages |
