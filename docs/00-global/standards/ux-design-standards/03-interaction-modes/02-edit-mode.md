# Edit Mode Standards

> Tiêu chuẩn cho chế độ chỉnh sửa (Inline/Form editing)

---

## 1. Edit Mode Types

| Type | Description | Use Case |
|------|-------------|----------|
| **Page Edit** | Full page form | Complex edits |
| **Inline Edit** | Edit in place | Quick single field |
| **Side Panel** | Slide-in form | Quick edits from list |
| **Modal Edit** | Popup form | Simple edits |

---

## 2. Page Edit Mode

### 2.1 Entering Edit Mode

```
View Mode:
┌─────────────────────────────────────────────────────────────────────┐
│ Employee Profile                                   [Edit] [Actions] │
└─────────────────────────────────────────────────────────────────────┘

Edit Mode:
┌─────────────────────────────────────────────────────────────────────┐
│ Edit Employee Profile                              [Cancel] [Save]   │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 Section-Level Edit

```
┌─────────────────────────────────────────────────────────────────────┐
│ Personal Information                                          [Edit]│
│ ─────────────────────────────────────────────────────────────────   │
│ Name:        Nguyen Van A                                           │
│ Email:       nguyen.a@company.com                                   │
└─────────────────────────────────────────────────────────────────────┘

After clicking Edit:
┌─────────────────────────────────────────────────────────────────────┐
│ Personal Information                            [Cancel] [Save]     │
│ ─────────────────────────────────────────────────────────────────   │
│ Name *       [Nguyen Van A                                 ]        │
│ Email *      [nguyen.a@company.com                         ]        │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Inline Edit

```
Normal:
│ Phone:  +84-123-456-789                                    [✏️]     │

Editing:
│ Phone:  [+84-123-456-789                    ] [✓] [×]              │
```

---

## 4. Edit Mode Indicators

| Indicator | Purpose |
|-----------|---------|
| Form fields visible | Editable state |
| Save/Cancel buttons | Action options |
| Dirty indicator | Unsaved changes |
| Field validation | Real-time feedback |

---

## 5. Save Behavior

| Mã | Quy định |
|----|----------|
| EM-01 | Validate before save |
| EM-02 | Show loading state during save |
| EM-03 | Success toast on save |
| EM-04 | Return to view mode after save |
| EM-05 | Undo option (optional) |

---

## 6. Cancel Behavior

```
If unsaved changes:
┌─────────────────────────────────────────────────────────────────────┐
│                   Discard Changes?                                  │
├─────────────────────────────────────────────────────────────────────┤
│ You have unsaved changes. Are you sure you want to discard them?    │
│                                                                     │
│                              [Keep Editing] [Discard Changes]       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 7. Quy Định

| Mã | Quy định | Priority |
|----|----------|----------|
| EM-01 | Clear edit mode indicator | P0 |
| EM-02 | Cancel always available | P0 |
| EM-03 | Unsaved changes warning | P0 |
| EM-04 | Optimistic vs pessimistic locking | P1 |
| EM-05 | Concurrent edit handling | P1 |
