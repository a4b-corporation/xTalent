# Shell Framework Standards

> Tiêu chuẩn cho bộ khung ứng dụng (Application Shell)

---

## Tổng Quan

Shell Framework định nghĩa các thành phần cố định của ứng dụng: Header Bar, Left Navigation, và Content Area structure. Đây là "vỏ" bọc ngoài tất cả các pages.

## Scope

```
┌────────────────────────────────────────────────────────────────────┐
│                         Application Shell                          │
├──────────┬─────────────────────────────────────────────────────────┤
│          │  [Header Bar]  ← 06-header-toolbar.md                   │
│          │  ┌─────────┬───────────────────────┬──────────────────┐ │
│          │  │App/Mod  │    Global Search      │ User│Notify│Help │ │
│          │  │Switcher │    (Cmd+K)            │                  │ │
│          │  └─────────┴───────────────────────┴──────────────────┘ │
│          │   ↑ 03-app-module-switcher.md                           │
│          │            ↑ 04-search-bar.md, 05-command-palette.md    │
│          ├─────────────────────────────────────────────────────────┤
│   LEFT   │                                                         │
│   NAV    │              Main Content Area                          │
│   MENU   │              → See 01-page-patterns/                    │
│   TREE   │              → See 02-content-layouts/                  │
│    ↑     │              → See 03-interaction-modes/                │
│ 02-nav   │                                                         │
│          ├─────────────────────────────────────────────────────────┤
│          │  [Footer / Status Bar]                                  │
└──────────┴─────────────────────────────────────────────────────────┘
```

---

## Document Structure

| File | Nội dung |
|------|----------|
| [01-shell-layout.md](./01-shell-layout.md) | Application Shell & Layout Standards |
| [02-navigation-menu.md](./02-navigation-menu.md) | Left Navigation Menu Tree |
| [03-app-module-switcher.md](./03-app-module-switcher.md) | App & Module Switcher |
| [04-search-bar.md](./04-search-bar.md) | Global Search Standards |
| [05-command-palette.md](./05-command-palette.md) | Quick Action Palette (Cmd+K) |
| [06-header-toolbar.md](./06-header-toolbar.md) | Header & Toolbar Standards |
| [07-responsive-mobile.md](./07-responsive-mobile.md) | Responsive & Mobile Guidelines |

---

## Related Documents

| Folder | Relationship |
|--------|--------------|
| [../01-page-patterns/](../01-page-patterns/) | Định nghĩa nội dung bên trong Content Area |
| [../02-content-layouts/](../02-content-layouts/) | Layout patterns trong từng page |
| [../03-interaction-modes/](../03-interaction-modes/) | View/Edit/Create modes |

---

## Mục Tiêu UX

| Tiêu chí | Mô tả |
|----------|-------|
| **Efficiency** | Tối ưu số bước để hoàn thành task |
| **Consistency** | Đồng nhất patterns xuyên suốt modules |
| **Discoverability** | Dễ dàng tìm kiếm features |
| **Accessibility** | Hỗ trợ đa dạng người dùng |
| **Personalization** | Cho phép tùy biến theo role/preference |

---

## Nguyên Tắc Chung

1. **Mobile-First Design** - Responsive trên mọi device
2. **Role-Based UI** - Hiển thị phù hợp với vai trò người dùng
3. **Keyboard Navigation** - Hỗ trợ đầy đủ keyboard shortcuts
4. **No Dead Ends** - Luôn có đường quay lại hoặc hướng dẫn tiếp
5. **Progressive Disclosure** - Hiển thị thông tin phù hợp theo context

---

## Industry Reference

| Platform | Design System | Shell Pattern |
|----------|--------------|---------------|
| **SAP SuccessFactors** | Fiori | Shell Bar + Tool Page |
| **Workday** | Canvas | Global Nav + Content |
| **Oracle HCM** | Redwood | Navigator + Springboard |
