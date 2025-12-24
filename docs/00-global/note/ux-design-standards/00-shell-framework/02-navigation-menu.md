# Left Navigation Menu Tree Standards

> Quy định về Menu Tree bên tay trái - Primary Navigation Pattern

---

## 1. Tổng Quan

Menu Tree bên trái là phương thức điều hướng chính trong ứng dụng xTalent, cho phép người dùng truy cập các modules, sub-modules và features.

### 1.1 Reference Architecture

| Platform | Navigation Pattern |
|----------|-------------------|
| **SAP SuccessFactors** | Side Navigation với Fiori Shell |
| **Workday** | Global Navigation Menu (left-side) |
| **Oracle HCM** | Navigator (Hamburger Menu) |

---

## 2. Menu Structure

### 2.1 Hierarchy Levels

| Level | Ví dụ | Max Items |
|-------|-------|-----------|
| **L1 - Module** | Core, Time & Absence, Payroll | 10-15 |
| **L2 - Sub-module** | Absence Management, Attendance | 8-12 per module |
| **L3 - Feature** | Leave Request, Leave Approval | 10-15 per sub-module |

### 2.2 Cấu Trúc Visual

```
┌─────────────────────────────────────┐
│ 🏠 Home                              │ ← L0 (Dashboard)
├─────────────────────────────────────┤
│ ▼ 👥 Core                            │ ← L1 (Module)
│   ├── 📋 Organization                │ ← L2 (Sub-module)
│   │   ├─ Legal Entities              │ ← L3 (Feature)
│   │   ├─ Business Units              │
│   │   └─ Locations                   │
│   ├── 👤 People                      │
│   │   ├─ Employee Directory          │
│   │   └─ New Hire                    │
│   └── 📝 Contracts                   │
│                                      │
│ ▼ ⏰ Time & Absence                  │
│   ├── 🏖️ Absence Management          │
│   │   ├─ Leave Request               │
│   │   ├─ Leave Approval              │
│   │   └─ Leave Calendar              │
│   └── ⏱️ Time & Attendance            │
│       ├─ Time Entry                  │
│       └─ Timesheet Approval          │
│                                      │
│ ► 💰 Payroll                         │ ← Collapsed L1
│ ► 🎁 Total Rewards                   │
│ ► 📈 Performance                     │
├─────────────────────────────────────┤
│ ⭐ Favorites                         │ ← User personalized
│ 🕐 Recent                            │ ← System tracked
├─────────────────────────────────────┤
│ ⚙️ Settings                          │ ← Bottom fixed
│ ❓ Help & Support                    │
└─────────────────────────────────────┘
```

---

## 3. Quy Định Bắt Buộc

| Mã | Quy định | Priority |
|----|----------|----------|
| NAV-01 | Menu PHẢI có icon cho mọi L1 và L2 items | P0 |
| NAV-02 | Expanded/Collapsed state PHẢI được lưu per-user | P0 |
| NAV-03 | Active item PHẢI được highlight rõ ràng | P0 |
| NAV-04 | Breadcrumb PHẢI sync với current menu location | P0 |
| NAV-05 | Max depth = 3 levels (L1 → L2 → L3) | P0 |
| NAV-06 | L3 items không được có children | P0 |
| NAV-07 | Scroll PHẢI được hỗ trợ khi menu dài | P1 |
| NAV-08 | Keyboard navigation (↑↓←→) PHẢI hoạt động | P1 |
| NAV-09 | Favorites section PHẢI ở cuối menu chính | P1 |
| NAV-10 | Settings & Help PHẢI ở bottom fixed position | P1 |

---

## 4. Menu Item States

### 4.1 Visual States

| State | Visual Indicator |
|-------|------------------|
| **Default** | Normal text, icon |
| **Hover** | Background highlight, cursor pointer |
| **Active** | Bold text, left border accent, filled icon |
| **Expanded** | Chevron ▼, children visible |
| **Collapsed** | Chevron ►, children hidden |
| **Disabled** | Muted text/icon, no cursor |

### 4.2 CSS Tokens

```css
:root {
  /* Nav Menu Colors */
  --nav-bg: #1a1a2e;
  --nav-text: #e0e0e0;
  --nav-text-active: #ffffff;
  --nav-hover-bg: rgba(255,255,255,0.08);
  --nav-active-bg: rgba(99,102,241,0.15);
  --nav-active-border: #6366f1;
  --nav-icon: #a0a0a0;
  --nav-icon-active: #6366f1;
  
  /* Dimensions */
  --nav-width-expanded: 240px;
  --nav-width-collapsed: 56px;
  --nav-item-height: 40px;
  --nav-indent-per-level: 16px;
}
```

---

## 5. Role-Based Menu Visibility

### 5.1 Menu Filtering

| Người dùng | Visible Modules |
|------------|-----------------|
| **Employee (Self-Service)** | Limited: My Profile, Leave Request, My Payslip |
| **Manager** | Team views + Self-service |
| **HR Admin** | Full Core, TA, TR modules |
| **Payroll Admin** | Full Payroll module |
| **System Admin** | All modules + Settings |

### 5.2 Quy Định Access Control

| Mã | Quy định | 
|----|----------|
| AC-01 | Chỉ hiển thị menu items mà user có quyền truy cập |
| AC-02 | Empty parent (không có children visible) PHẢI được ẩn |
| AC-03 | Không hiển thị disabled items thay vì hidden |

---

## 6. Favorites & Recent

### 6.1 Favorites
- User có thể "star" bất kỳ L2/L3 item
- Favorites section hiển thị riêng
- Max 10 favorites
- Drag-drop để reorder

### 6.2 Recent
- System tự động track 10 items gần nhất
- Hiển thị timestamp "2h ago", "Yesterday"
- Clear history option

---

## 7. Search Integration

### 7.1 Menu Search (In-nav filter)

```
┌─────────────────────────────────────┐
│ 🔍 Filter menu...                   │ ← Inline filter
├─────────────────────────────────────┤
│ ▼ Matching results:                 │
│   Leave Request                     │ ← Highlighted match
│   Leave Approval                    │
│   Leave Calendar                    │
└─────────────────────────────────────┘
```

| Mã | Quy định |
|----|----------|
| MS-01 | Filter box PHẢI visible ở top của menu |
| MS-02 | Real-time filtering khi user gõ |
| MS-03 | Highlight matching text trong results |
| MS-04 | Show full path: "Time & Absence > Leave Request" |

---

## 8. Collapsed Mode Behavior

### 8.1 Icon-Only View

```
┌──────┐
│ 🏠   │ → Tooltip: "Home"
│ 👥   │ → Hover: Flyout submenu
│ ⏰   │
│ 💰   │
│ ...  │
├──────┤
│ ⭐   │
│ 🕐   │
├──────┤
│ ⚙️   │
│ ❓   │
└──────┘
```

### 8.2 Flyout Menu

| Rule | Description |
|------|-------------|
| Hover icon → Flyout panel appears | Position: to the right of collapsed nav |
| Click icon → Expands nav OR flyout | Config-dependent |
| Flyout width | Same as expanded nav (240px) |
| Flyout delay | 200ms before show, 300ms before hide |

---

## 9. Mobile Behavior

| Screen | Behavior |
|--------|----------|
| **< 768px** | Nav hidden, hamburger icon reveals drawer |
| **Drawer mode** | Full-screen overlay, swipe to close |
| **Search** | Prominent in drawer header |

---

## 10. Accessibility (a11y)

| Requirement | Implementation |
|-------------|----------------|
| Keyboard nav | Arrow keys, Tab, Enter, Escape |
| Screen reader | ARIA roles: navigation, tree, treeitem |
| Focus visible | Clear focus indicator on all items |
| Skip link | "Skip to content" at the top |
| Announcements | Route changes announced |

---

## See Also

| Document | Relationship |
|----------|--------------|
| [01-shell-layout.md](./01-shell-layout.md) | Overall shell structure |
| [03-app-module-switcher.md](./03-app-module-switcher.md) | Module switching context |
| [07-responsive-mobile.md](./07-responsive-mobile.md) | Mobile drawer behavior |
| [../01-page-patterns/01-master-data-page.md](../01-page-patterns/01-master-data-page.md) | List pages linked from menu |
| [../01-page-patterns/06-dashboard-page.md](../01-page-patterns/06-dashboard-page.md) | Dashboard/Home page |
