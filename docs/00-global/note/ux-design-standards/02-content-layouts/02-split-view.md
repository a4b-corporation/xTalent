# Split View Layout (Master-Detail)

> Tiêu chuẩn cho layout chia đôi màn hình Master-Detail

---

## 1. Khi Nào Dùng Split View

| Scenario | Dùng? |
|----------|-------|
| List + Detail mà user cần xem đồng thời | ✅ |
| Quick preview mà không rời list context | ✅ |
| Workflow với worklist + detail | ✅ |
| Complex detail cần full screen | ❌ |
| Mobile-first scenario | ❌ |

---

## 2. Split Layouts

### 2.1 Horizontal Split (Side by Side)

```
┌───────────────────────────┬─────────────────────────────────────────┐
│ MASTER (List)             │ DETAIL                                  │
│ Width: 30-40%             │ Width: 60-70%                           │
│                           │                                         │
│ [List items...]           │ [Selected item detail...]               │
│                           │                                         │
└───────────────────────────┴─────────────────────────────────────────┘
```

### 2.2 Vertical Split (Stacked)

```
┌─────────────────────────────────────────────────────────────────────┐
│ MASTER (List)                                           Height: 40%│
│ [List items in table/cards...]                                      │
├─────────────────────────────────────────────────────────────────────┤
│ DETAIL                                                  Height: 60%│
│ [Selected item detail...]                                           │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.3 Collapsible Master

```
Normal:
┌─────────────────────┬───────────────────────────────────────────────┐
│ MASTER (240px)      │ DETAIL                                        │
│ [☰] [List...]       │ [Content...]                                  │
└─────────────────────┴───────────────────────────────────────────────┘

Collapsed:
┌─────┬───────────────────────────────────────────────────────────────┐
│ [☰] │ DETAIL (expanded)                                             │
│     │ [Content...]                                                  │
└─────┴───────────────────────────────────────────────────────────────┘
```

---

## 3. Selection Behavior

| Mã | Quy định |
|----|----------|
| SV-01 | Click master item → load detail |
| SV-02 | Highlight selected item |
| SV-03 | Empty state for detail if nothing selected |
| SV-04 | Preserve selection khi filter |

---

## 4. Responsive

| Screen | Behavior |
|--------|----------|
| Desktop | Side-by-side |
| Tablet | Stack or narrow master |
| Mobile | List-first, tap → full detail |

---

## 5. Quy Định

| Mã | Quy định | Priority |
|----|----------|----------|
| SV-01 | Resizable divider (optional) | P2 |
| SV-02 | Detail scroll independently | P0 |
| SV-03 | Back button on detail (mobile) | P0 |
| SV-04 | Empty state cho detail panel | P1 |
