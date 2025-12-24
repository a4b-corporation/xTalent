# Create Mode Standards

> Tiêu chuẩn cho chế độ tạo mới (New record creation)

---

## 1. Create Mode Entry Points

| Entry Point | Action |
|-------------|--------|
| **"+ New" button** | From list page toolbar |
| **Quick action** | From dashboard/menu |
| **Context menu** | From related entity |
| **Command palette** | Cmd+K → "Create..." |

---

## 2. Create Page Layout

```
┌─────────────────────────────────────────────────────────────────────┐
│ ← Employees                                                         │
├─────────────────────────────────────────────────────────────────────┤
│ 👤 New Employee                                                     │
│ Add a new employee to the system                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│ [Form fields with empty/default values...]                          │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                              [Cancel] [Create]      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Create vs Edit Differences

| Aspect | Create | Edit |
|--------|--------|------|
| Title | "New [Entity]" | "Edit [Entity Name]" |
| Fields | Empty/defaults | Pre-filled |
| Primary action | "Create" / "Add" | "Save" / "Update" |
| Required fields | All shown | May be locked |
| Delete | Not available | Available |

---

## 4. Default Values

| Field Type | Default Behavior |
|------------|------------------|
| Dates | Today or empty |
| Dropdowns | First option or empty |
| Numbers | 0 or empty |
| Toggles | System default |
| Lookups | Empty (required search) |

---

## 5. Create Actions

| Action | Button | Behavior |
|--------|--------|----------|
| **Create** | Primary | Save and navigate to detail |
| **Create & New** | Secondary | Save and reset form |
| **Cancel** | Text | Return to list |

```
┌─────────────────────────────────────────────────────────────────────┐
│                      [Cancel] [Create & Add Another] [Create]       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 6. After Create

```
Success:
┌─────────────────────────────────────────────────────────────────────┐
│ ✅ Employee Created Successfully                                    │
│ Nguyen Van A has been added to the system.                          │
│                                                                     │
│ [View Employee] [Add Another] [Back to List]                        │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 7. Quy Định

| Mã | Quy định | Priority |
|----|----------|----------|
| CM-01 | Clear "New/Create" title | P0 |
| CM-02 | Sensible default values | P1 |
| CM-03 | Required fields indicated | P0 |
| CM-04 | Cancel returns to origin | P0 |
| CM-05 | Success confirmation | P0 |
| CM-06 | "Create & Add Another" for bulk | P2 |
