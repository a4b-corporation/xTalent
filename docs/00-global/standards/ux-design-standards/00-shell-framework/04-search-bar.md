# Global Search Bar Standards

> Quy định về thanh Search toàn cục trong Header Bar

---

## 1. Tổng Quan

Global Search là một trong những tính năng quan trọng nhất của enterprise software, cho phép người dùng tìm kiếm mọi thứ từ một điểm duy nhất.

### 1.1 Reference Architecture

| Platform | Search Pattern |
|----------|---------------|
| **Workday** | Omnisearch - starting point for any action |
| **SAP SuccessFactors** | Global Search across modules |
| **Oracle HCM** | Quick Search + Digital Assistant |
| **Salesforce** | Global Search Bar |

---

## 2. Position & Layout

### 2.1 Header Integration

```
┌─────────────────────────────────────────────────────────────────────┐
│ [≡][App][Module▼] │ [🔍 Search employees, menus, actions... ⌘K] │ [Icons]│
│                        └────────────── Centered, flex-grow ──────────┘        │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 Dimensions

| Attribute | Value |
|-----------|-------|
| Position | Center của Header Bar |
| Min Width | 200px |
| Max Width | 600px |
| Height | 40px |
| Width | flex-grow (expand to available space) |

---

## 3. Search Scope

### 3.1 Searchable Entities

| Category | Ví dụ | Icon |
|----------|-------|------|
| **People** | Employees, Candidates, Managers | 👤 |
| **Menus/Pages** | Leave Request page, PIT Declaration | 📄 |
| **Actions** | Create Employee, Run Payroll | ▶️ |
| **Documents** | Policy docs, Templates | 📁 |
| **Reports** | Headcount Report, Turnover Analysis | 📊 |
| **Help** | Knowledge base articles | ❓ |

### 3.2 Quy Định Scope

| Mã | Quy định | Priority |
|----|----------|----------|
| SC-01 | People search PHẢI là default và highest priority | P0 |
| SC-02 | Kết quả PHẢI respects user access permissions | P0 |
| SC-03 | Cross-module search khi không có context | P0 |
| SC-04 | Current module results should be prioritized | P1 |

---

## 4. Search Input

### 4.1 Placeholder Text

```
Default:     "Search employees, menus, actions..."  
Alternative: "Search or press ⌘K"
Vietnamese:  "Tìm kiếm nhân viên, menu, chức năng..."
```

### 4.2 Input Behavior

| Mã | Quy định |
|----|----------|
| IN-01 | Click vào search bar → focus + show dropdown |
| IN-02 | Type → instant filter/search (debounce 300ms) |
| IN-03 | Minimum 2 characters to trigger search |
| IN-04 | Clear button (×) appears when text present |
| IN-05 | ⌘K / Ctrl+K shortcut to focus search bar |

---

## 5. Results Display

### 5.1 Dropdown Panel

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔍 nguyen                                                   [×] │
├─────────────────────────────────────────────────────────────────┤
│ 👤 People                                               See all →│
│ ┌───────────────────────────────────────────────────────────────┤
│ │ [Photo] Nguyen Van A      • Senior Developer    Engineering   │
│ │ [Photo] Nguyen Thi B      • HR Manager          HR Department │
│ │ [Photo] Tran Nguyen C     • Accountant          Finance       │
│ └───────────────────────────────────────────────────────────────┤
├─────────────────────────────────────────────────────────────────┤
│ 📄 Pages & Menus                                                │
│ ├── Leave Request                    Time & Absence             │
│ └── Nguyen Van A Profile             Core > People              │
├─────────────────────────────────────────────────────────────────┤
│ ▶️ Actions                                                       │
│ ├── Create New Employee              Core > People              │
│ └── View Nguyen Van A Payslip        Payroll                    │
├─────────────────────────────────────────────────────────────────┤
│ Press ↵ to select • ↑↓ to navigate • esc to close              │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Result Categories Order

1. **People** (if query looks like name)
2. **Pages & Menus** 
3. **Actions**
4. **Documents**
5. **Reports**
6. **Help Articles**

### 5.3 Quy Định Results

| Mã | Quy định | Priority |
|----|----------|----------|
| RS-01 | Max 10 results per category trong preview | P0 |
| RS-02 | "See all" link khi có nhiều kết quả hơn | P1 |
| RS-03 | Highlight matching text trong results | P0 |
| RS-04 | Show category icon cho mỗi result | P0 |
| RS-05 | Show secondary info (department, module path) | P1 |
| RS-06 | Recent searches section khi search empty | P1 |

---

## 6. Empty & Loading States

### 6.1 Initial State (No Input)

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔍 Search...                                                    │
├─────────────────────────────────────────────────────────────────┤
│ 🕐 Recent Searches                                              │
│    Leave Request                                                │
│    Nguyen Van A                                                 │
│    Payroll Report                                               │
├─────────────────────────────────────────────────────────────────┤
│ ⭐ Popular                                                       │
│    Create Leave Request                                         │
│    View My Payslip                                              │
│    Employee Directory                                           │
└─────────────────────────────────────────────────────────────────┘
```

### 6.2 Loading State

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔍 searching...                                                 │
├─────────────────────────────────────────────────────────────────┤
│ [Skeleton loader animations]                                    │
│ ████████████████████████████                                    │
│ ████████████████                                                │
│ ████████████████████                                            │
└─────────────────────────────────────────────────────────────────┘
```

### 6.3 No Results

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔍 xyzabc123                                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│         🔍 No results found for "xyzabc123"                     │
│                                                                 │
│         Try different keywords or check spelling                │
│                                                                 │
│         [Browse all employees]  [View menu tree]                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 7. Keyboard Navigation

| Key | Action |
|-----|--------|
| `⌘K` / `Ctrl+K` | Open search / focus |
| `↑` `↓` | Navigate results |
| `Enter` | Select highlighted result |
| `Tab` | Move between categories |
| `Escape` | Close dropdown / clear input |
| `/` | Focus search (when not in input) |

---

## 8. Advanced Features

### 8.1 Search Filters

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔍 department:engineering developer                             │
├─────────────────────────────────────────────────────────────────┤
│ Filters: [department:engineering ×]                             │
├─────────────────────────────────────────────────────────────────┤
│ Results filtered by Engineering department...                   │
└─────────────────────────────────────────────────────────────────┘
```

**Supported Filters:**
- `department:` - Filter by department
- `location:` - Filter by location
- `module:` - Filter by module (core, ta, payroll)
- `type:` - Filter by result type (people, page, action)
- `status:` - For people: active, inactive

### 8.2 Natural Language Queries

| Query | Interpretation |
|-------|----------------|
| "John's payslip" | Payslip of employee named John |
| "leave balance" | Leave Balance page |
| "create new employee" | Action: Create Employee |
| "who is my manager" | Your reporting manager |

---

## 9. Performance Requirements

| Metric | Target |
|--------|--------|
| Time to first result | < 200ms |
| Results update debounce | 300ms |
| Max API response time | < 500ms |
| Cache duration (people) | 5 minutes |

---

## 10. Accessibility

| Requirement | Implementation |
|-------------|----------------|
| ARIA role | `role="combobox"` with `aria-expanded` |
| Listbox | Results use `role="listbox"` |
| Keyboard | Full keyboard navigation |
| Screen reader | Announce result count and selection |
| Focus management | Return focus to trigger on close |

---

## See Also

| Document | Relationship |
|----------|--------------|
| [05-command-palette.md](./05-command-palette.md) | Advanced search & commands |
| [06-header-toolbar.md](./06-header-toolbar.md) | Search bar placement |
| [../01-page-patterns/01-master-data-page.md](../01-page-patterns/01-master-data-page.md) | Search results navigation |
| [../02-content-layouts/05-table-layout.md](../02-content-layouts/05-table-layout.md) | Table search/filter |
