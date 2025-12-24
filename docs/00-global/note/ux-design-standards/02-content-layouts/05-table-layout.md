# Table Layout Standards

> Tiêu chuẩn cho layout data tables

---

## 1. Table Anatomy

```
┌─────────────────────────────────────────────────────────────────────┐
│ TOOLBAR                                                             │
│ [🔍 Search] [Filter ▼] [Sort ▼]           [Columns ▼] [Export] [⟳] │
├─────────────────────────────────────────────────────────────────────┤
│ TABLE HEADER (sticky)                                               │
│ □ │ Name          │ Department  │ Status  │ Date      │ Actions   │
├─────────────────────────────────────────────────────────────────────┤
│ □ │ Nguyen Van A  │ Engineering │ Active  │ Jan 2024  │ [⋮]       │
│ □ │ Tran Thi B    │ HR          │ Active  │ Jan 2024  │ [⋮]       │
│ □ │ Le Van C      │ Finance     │ Inactive│ Dec 2023  │ [⋮]       │
├─────────────────────────────────────────────────────────────────────┤
│ FOOTER                                                              │
│ Showing 1-25 of 1,234                    [← 1 2 3 ... 50 →]        │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. Column Types

| Type | Alignment | Width |
|------|-----------|-------|
| Text | Left | Auto/flex |
| Number | Right | Fixed |
| Date | Left | Fixed (120px) |
| Status | Center | Fixed (100px) |
| Actions | Center | Fixed (60px) |
| Checkbox | Center | Fixed (40px) |

---

## 3. Row Features

| Feature | Description |
|---------|-------------|
| **Selection** | Checkbox column |
| **Hover** | Row highlight |
| **Click** | Navigate to detail |
| **Actions** | More menu (⋮) |
| **Expandable** | Nested content |

---

## 4. Table States

| State | Display |
|-------|---------|
| **Loading** | Skeleton rows |
| **Empty** | Empty state message |
| **Error** | Error message + retry |
| **Filtered** | Show active filters |

---

## 5. Pagination Options

| Option | Use Case |
|--------|----------|
| **Numbered** | Standard lists |
| **Load More** | Social-style |
| **Infinite Scroll** | Long lists |

---

## 6. Mobile Table

| Approach | Description |
|----------|-------------|
| **Card View** | Row → Card |
| **Horizontal Scroll** | Swipe table |
| **Priority Columns** | Show key columns only |

---

## 7. Quy Định

| Mã | Quy định | Priority |
|----|----------|----------|
| TL-01 | Sticky header | P0 |
| TL-02 | Sortable columns indicated | P0 |
| TL-03 | Pagination required | P0 |
| TL-04 | Row actions accessible | P0 |
| TL-05 | Responsive on mobile | P0 |
| TL-06 | Column resizable | P2 |
| TL-07 | Column reorderable | P2 |
