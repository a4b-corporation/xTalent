# Card & Widget Grid Layout

> Tiêu chuẩn cho layout sử dụng cards/widgets dạng grid

---

## 1. Card Grid Layout

```
┌─────────────────────────────────────────────────────────────────────┐
│ ┌────────────────────┐ ┌────────────────────┐ ┌────────────────────┐│
│ │ Card 1             │ │ Card 2             │ │ Card 3             ││
│ │ [Content]          │ │ [Content]          │ │ [Content]          ││
│ └────────────────────┘ └────────────────────┘ └────────────────────┘│
│ ┌────────────────────┐ ┌────────────────────┐                       │
│ │ Card 4             │ │ Card 5             │                       │
│ │ [Content]          │ │ [Content]          │                       │
│ └────────────────────┘ └────────────────────┘                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. Grid Columns by Screen

| Screen | Columns | Card Width |
|--------|---------|------------|
| Desktop | 3-4 | 25-33% |
| Tablet | 2 | 50% |
| Mobile | 1 | 100% |

---

## 3. Card Anatomy

```
┌─────────────────────────────────────────┐
│ [Icon] Card Title               [⋮]    │  ← Header
├─────────────────────────────────────────┤
│                                         │
│ Card Body Content                       │  ← Body
│ [Data, charts, lists...]                │
│                                         │
├─────────────────────────────────────────┤
│ [Action Link]              [Button]     │  ← Footer (optional)
└─────────────────────────────────────────┘
```

---

## 4. Card Types

| Type | Content | Height |
|------|---------|--------|
| **Stat Card** | Metric + trend | Fixed small |
| **List Card** | 3-5 items | Fixed medium |
| **Chart Card** | Visualization | Fixed large |
| **Profile Card** | User info | Fixed |
| **Content Card** | Flexible content | Auto |

---

## 5. Quy Định

| Mã | Quy định | Priority |
|----|----------|----------|
| CG-01 | Consistent card heights per row | P1 |
| CG-02 | Card gutter: 16-24px | P0 |
| CG-03 | Card padding: 16px | P0 |
| CG-04 | Cards same style within a page | P0 |
| CG-05 | Loading skeleton per card | P1 |
