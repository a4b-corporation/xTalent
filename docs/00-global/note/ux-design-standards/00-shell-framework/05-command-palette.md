# Command Palette (Quick Action) Standards

> Quy định về thanh nhập nhanh menu/action/feature (kiểu Cmd+K)

---

## 1. Tổng Quan

Command Palette (còn gọi là Quick Actions, Spotlight, hoặc Cmd+K interface) là một pattern UX hiện đại cho phép power users nhanh chóng truy cập bất kỳ chức năng nào trong ứng dụng thông qua keyboard.

### 1.1 Reference Architecture

| Platform | Implementation |
|----------|----------------|
| **VS Code** | Command Palette (Ctrl+Shift+P) |
| **GitHub** | Command Palette (Cmd+K) |
| **Slack** | Quick Switcher (Cmd+K) |
| **Notion** | Quick Find (Cmd+K) |
| **Linear** | Command Menu (Cmd+K) |
| **Raycast/Alfred** | Spotlight-style launcher |

### 1.2 Tại Sao Cần Command Palette?

| Lợi ích | Mô tả |
|---------|-------|
| **Productivity** | Thực hiện actions nhanh hơn 3-5x so với click |
| **Discoverability** | Giúp users khám phá features ẩn |
| **Reduced UI Clutter** | Không cần hiển thị tất cả buttons |
| **Power User Friendly** | Tối ưu cho keyboard-centric workflow |
| **Accessibility** | Hỗ trợ người dùng gặp khó khăn với mouse |

---

## 2. Trigger & UI

### 2.1 Invocation

| Trigger | Keyboard Shortcut |
|---------|-------------------|
| **Primary** | `⌘K` (Mac) / `Ctrl+K` (Windows/Linux) |
| **Secondary** | `⌘/` hoặc `Ctrl+/` |
| **Alternative** | Click icon trong Header (optional) |

### 2.2 Visual Design

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│        ┌─────────────────────────────────────────────────────┐      │
│        │ 🔍 Type a command or search...                      │      │
│        ├─────────────────────────────────────────────────────┤      │
│        │                                                     │      │
│        │  ▶️ Actions                                          │      │
│        │  ├── Create Employee           Core        ⌘⇧E    │      │
│        │  ├── Submit Leave Request      TA          ⌘⇧L    │      │
│        │  └── Run Payroll               Payroll     ⌘⇧P    │      │
│        │                                                     │      │
│        │  📄 Navigation                                       │      │
│        │  ├── Go to Dashboard           Home        ⌘1      │      │
│        │  ├── Go to Employee Directory  Core        ⌘2      │      │
│        │  └── Go to Reports             Analytics   ⌘3      │      │
│        │                                                     │      │
│        │  ⚙️ Settings                                         │      │
│        │  ├── Open Preferences          Settings    ⌘,      │      │
│        │  └── Toggle Dark Mode          Theme               │      │
│        │                                                     │      │
│        ├─────────────────────────────────────────────────────┤      │
│        │  ↵ Select   ↑↓ Navigate   ⎋ Close   ? Help          │      │
│        └─────────────────────────────────────────────────────┘      │
│                                                                     │
│  (Modal backdrop - click to close)                                  │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.3 Dimensions

| Attribute | Value |
|-----------|-------|
| Width | 580px (fixed) |
| Max Height | 60vh |
| Position | Center-top (20% from top) |
| Border Radius | 12px |
| Shadow | Large elevation shadow |
| Backdrop | Semi-transparent overlay (rgba(0,0,0,0.5)) |
| Z-index | 9999 (highest layer) |

---

## 3. Command Categories

### 3.1 Primary Categories

| Category | Prefix | Ví dụ |
|----------|--------|-------|
| **Actions** | `>` hoặc không prefix | `> Create Employee` |
| **Navigation** | `go ` hoặc `/` | `go Dashboard`, `/reports` |
| **People** | `@` | `@Nguyen Van A` |
| **Settings** | `settings:` | `settings: notifications` |
| **Help** | `?` hoặc `help ` | `? Leave policy` |
| **Recent** | (auto) | Hiện tại khi palette mở |

### 3.2 Core Commands

#### Actions (Tạo, Thực Hiện)

| Command | Shortcut | Module |
|---------|----------|--------|
| Create Employee | `⌘⇧E` | Core |
| Create Leave Request | `⌘⇧L` | Time & Absence |
| Submit Timesheet | | Time & Absence |
| Run Payroll | `⌘⇧P` | Payroll |
| Create Job Posting | | Recruitment |
| Add New Candidate | | Recruitment |
| Create Benefit Enrollment | | Total Rewards |
| Generate Report | `⌘⇧R` | Analytics |

#### Navigation (Điều Hướng)

| Command | Shortcut | Target |
|---------|----------|--------|
| Go to Dashboard | `⌘1` | Home |
| Go to My Profile | `⌘2` | Self-service |
| Go to Employee List | `⌘3` | Core |
| Go to Leave Calendar | | TA |
| Go to Payslips | | Payroll |
| Go to Settings | `⌘,` | Settings |

#### Quick Toggles

| Command | Result |
|---------|--------|
| Toggle Dark Mode | Switch UI theme |
| Toggle Sidebar | Collapse/Expand nav |
| Toggle Fullscreen | F11 equivalent |

---

## 4. Search & Filtering

### 4.1 Fuzzy Search

| Input | Matches |
|-------|---------|
| `cre emp` | **Cre**ate **Emp**loyee |
| `lv req` | **L**ea**v**e **Req**uest |
| `run pr` | **Run** **P**ay**r**oll |

### 4.2 Category Filtering

```
> create      → Filter to Actions only
@ nguyen      → Filter to People only  
go dashboard  → Filter to Navigation only
/reports      → Filter to Pages only
? how to      → Filter to Help only
```

### 4.3 Quy Định Search

| Mã | Quy định | Priority |
|----|----------|----------|
| SR-01 | Fuzzy matching PHẢI được hỗ trợ | P0 |
| SR-02 | Results phải instant (< 50ms local) | P0 |
| SR-03 | Match score-based ranking | P1 |
| SR-04 | Recent commands weighted higher | P1 |
| SR-05 | Frequency của user tính vào ranking | P2 |

---

## 5. Result Item Structure

### 5.1 Anatomy

```
┌─────────────────────────────────────────────────────────────────┐
│ [Icon] [Title]                         [Category] [Shortcut]    │
│        [Description - optional]                                 │
└─────────────────────────────────────────────────────────────────┘

Ví dụ:
┌─────────────────────────────────────────────────────────────────┐
│ 👤 Create Employee                     Core HR      ⌘⇧E        │
│    Add a new employee to the system                            │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Required vs Optional

| Element | Required | Description |
|---------|----------|-------------|
| Icon | ✅ | Visual category indicator |
| Title | ✅ | Primary command name |
| Category label | ✅ | Module/section name |
| Keyboard shortcut | ⬜ | If available |
| Description | ⬜ | For complex commands |

---

## 6. Keyboard Navigation

| Key | Action |
|-----|--------|
| `⌘K` / `Ctrl+K` | Open palette |
| `↑` `↓` | Navigate through results |
| `Enter` | Execute selected command |
| `Escape` | Close palette |
| `Tab` | Move to next category |
| `⇧Tab` | Move to previous category |
| `Backspace` (empty input) | Go back (if in sub-menu) |
| `?` | Show keyboard shortcuts help |

---

## 7. Sub-Commands / Multi-Step

### 7.1 Nested Commands

Một số commands có thể mở ra sub-palette:

```
Step 1: Select "Create Employee"
┌─────────────────────────────────────────────────────────────────┐
│ 🔍 Create Employee                                              │
├─────────────────────────────────────────────────────────────────┤
│ Choose employee type:                                           │
│ ├── Full-time Employee                                          │
│ ├── Part-time Employee                                          │
│ ├── Contractor                                                  │
│ └── Intern                                                      │
├─────────────────────────────────────────────────────────────────┤
│ ← Back   ↵ Select                                               │
└─────────────────────────────────────────────────────────────────┘
```

### 7.2 Quy Định Sub-Commands

| Mã | Quy định |
|----|----------|
| SC-01 | Max 2 levels của nesting |
| SC-02 | Breadcrumb hiển thị current path |
| SC-03 | Backspace/←/Escape để quay lại |
| SC-04 | Direct typing vẫn filter trong context |

---

## 8. Empty & Edge States

### 8.1 Initial State (No Input)

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔍 Type a command or search...                                  │
├─────────────────────────────────────────────────────────────────┤
│ 🕐 Recent                                                        │
│    Create Leave Request                    yesterday            │
│    View Payslips                           2 days ago           │
│    @Nguyen Van A                           3 days ago           │
├─────────────────────────────────────────────────────────────────┤
│ ⭐ Suggested                                                     │
│    Submit Timesheet                        Due today            │
│    Approve Leave Request                   3 pending            │
└─────────────────────────────────────────────────────────────────┘
```

### 8.2 No Results

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔍 xyzabc123                                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│              No commands found for "xyzabc123"                  │
│                                                                 │
│              Try different keywords or                          │
│              [Browse all commands]                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 9. Implementation Requirements

### 9.1 Performance

| Metric | Target |
|--------|--------|
| Time to open | < 100ms |
| Filter response | < 50ms |
| Command execution start | < 100ms |

### 9.2 Data Structure

```typescript
interface Command {
  id: string;
  title: string;
  description?: string;
  icon: string;
  category: 'action' | 'navigation' | 'settings' | 'help';
  module?: string;
  shortcut?: string;
  keywords: string[];  // For search matching
  action: () => void | Promise<void>;
  subCommands?: Command[];  // For nested menus
  isAvailable?: () => boolean;  // Dynamic availability
}
```

### 9.3 Registry Pattern

```typescript
// Commands should be registered by each module
commandRegistry.register({
  id: 'core.create-employee',
  title: 'Create Employee',
  module: 'Core HR',
  shortcut: 'Cmd+Shift+E',
  keywords: ['new', 'hire', 'add', 'employee', 'person'],
  action: () => router.push('/core/employees/new')
});
```

---

## 10. Accessibility

| Requirement | Implementation |
|-------------|----------------|
| ARIA role | `role="dialog"` với proper labeling |
| Focus trap | Focus stays within palette |
| Screen reader | Announce results count và current selection |
| Keyboard only | 100% navigable without mouse |
| Escape closes | Reliable escape behavior |
| Return focus | Focus returns to trigger element |

---

## 11. Customization

### 11.1 User Preferences

| Option | Default |
|--------|---------|
| Show keyboard hints | ✅ On |
| Show recent commands | ✅ On |
| Max recent items | 5 |
| Show descriptions | ⬜ Off |

### 11.2 Admin Configuration

| Option | Description |
|--------|-------------|
| Custom commands | Admin có thể add/remove commands |
| Module visibility | Hide commands của disabled modules |
| Branding | Custom icons/colors cho company commands |

---

## See Also

| Document | Relationship |
|----------|--------------|
| [04-search-bar.md](./04-search-bar.md) | Global search integration |
| [01-shell-layout.md](./01-shell-layout.md) | Z-index hierarchy |
| [../01-page-patterns/](../01-page-patterns/) | Navigate commands target pages |
| [../03-interaction-modes/03-create-mode.md](../03-interaction-modes/03-create-mode.md) | Quick create flows |
