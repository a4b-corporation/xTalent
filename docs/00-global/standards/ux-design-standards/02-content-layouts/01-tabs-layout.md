# Tab-Based Content Layout

> Tiêu chuẩn cho layout sử dụng tabs để tổ chức content

---

## 1. Khi Nào Dùng Tabs

| Scenario | Dùng Tabs? |
|----------|------------|
| Content có thể chia thành 3-8 nhóm logical | ✅ |
| User cần switch context thường xuyên | ✅ |
| Mỗi tab độc lập, không cần xem đồng thời | ✅ |
| Content cần scroll liên tục | ❌ Use Sections |
| Chỉ có 2 options | ❌ Use Toggle/Segmented |

---

## 2. Tab Variants

### 2.1 Horizontal Tabs (Default)

```
┌─────────────────────────────────────────────────────────────────────┐
│ [Overview] [Personal] [Employment] [Compensation] [Documents] [▼]  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│ Tab Content: Personal Information                                   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 Vertical Tabs (Side)

```
┌─────────────────────┬───────────────────────────────────────────────┐
│ Overview            │                                               │
│ ● Personal          │ Tab Content: Personal Information             │
│ Employment          │                                               │
│ Compensation        │ [Content here...]                             │
│ Documents           │                                               │
└─────────────────────┴───────────────────────────────────────────────┘
```

### 2.3 Pills Style

```
┌─────────────────────────────────────────────────────────────────────┐
│ [All] [●Active] [Inactive] [Pending]                                │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Tab States

| State | Visual |
|-------|--------|
| **Default** | Normal text |
| **Active** | Bold, underline/filled, accent color |
| **Hover** | Background highlight |
| **Disabled** | Muted, no pointer |
| **With Badge** | `[Tab Name (5)]` |

---

## 4. Tab Overflow

```
When tabs exceed container width:
┌─────────────────────────────────────────────────────────────────────┐
│ [◀] [Overview] [Personal] [Employment] [Compensation] [▼ More]     │
└─────────────────────────────────────────────────────────────────────┘

More dropdown:
┌───────────────┐
│ Documents     │
│ History       │
│ Notes         │
└───────────────┘
```

---

## 5. Quy Định

| Mã | Quy định | Priority |
|----|----------|----------|
| TB-01 | Max 8 visible tabs (desktop) | P0 |
| TB-02 | Overflow vào "More" dropdown | P0 |
| TB-03 | Active tab indicator rõ ràng | P0 |
| TB-04 | Lazy load tab content | P1 |
| TB-05 | Preserve tab state trong URL | P1 |
| TB-06 | Keyboard: Arrow left/right | P1 |

---

## 6. Mobile

- Horizontal tabs → Scrollable hoặc Dropdown
- Vertical tabs → Accordion style
