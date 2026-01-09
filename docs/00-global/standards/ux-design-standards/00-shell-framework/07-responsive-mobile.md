# Responsive & Mobile Guidelines

> Quy định về thiết kế responsive và trải nghiệm di động

---

## 1. Tổng Quan

xTalent phải hoạt động tốt trên mọi thiết bị - từ desktop đến smartphone. Mobile-first design đảm bảo trải nghiệm nhất quán cho workforce đa dạng.

### 1.1 Reference Architecture

| Platform | Mobile Approach |
|----------|----------------|
| **SAP SuccessFactors** | Responsive web + Native apps |
| **Workday** | Mobile-first, same experience |
| **Oracle HCM** | Mobile-responsive design |

---

## 2. Breakpoint System

### 2.1 Breakpoint Definitions

| Name | Range | Device |
|------|-------|--------|
| **xs** | 0 - 479px | Small phone |
| **sm** | 480 - 767px | Large phone |
| **md** | 768 - 1023px | Tablet |
| **lg** | 1024 - 1439px | Desktop |
| **xl** | 1440px+ | Large desktop |

### 2.2 CSS Variables

```css
:root {
  --breakpoint-xs: 0;
  --breakpoint-sm: 480px;
  --breakpoint-md: 768px;
  --breakpoint-lg: 1024px;
  --breakpoint-xl: 1440px;
}

/* Usage in media queries */
@media (max-width: 767px) { /* Mobile */ }
@media (min-width: 768px) and (max-width: 1023px) { /* Tablet */ }
@media (min-width: 1024px) { /* Desktop */ }
```

---

## 3. Layout Transformations

### 3.1 Desktop Layout (≥1024px)

```
┌─────────────────────────────────────────────────────────────────────┐
│ [Header Bar - Full]                                                 │
├──────────┬──────────────────────────────────────────────────────────┤
│          │                                                          │
│  LEFT    │             CONTENT AREA                                 │
│  NAV     │                                                          │
│  (240px) │   ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐           │
│          │   │ Card   │ │ Card   │ │ Card   │ │ Card   │           │
│          │   └────────┘ └────────┘ └────────┘ └────────┘           │
│          │                                                          │
└──────────┴──────────────────────────────────────────────────────────┘
```

### 3.2 Tablet Layout (768-1023px)

```
┌─────────────────────────────────────────────────────────────────────┐
│ [Header - Condensed]                                                │
├─────┬───────────────────────────────────────────────────────────────┤
│     │                                                               │
│ NAV │             CONTENT AREA                                      │
│(56) │                                                               │
│     │   ┌──────────────────┐  ┌──────────────────┐                  │
│     │   │ Card             │  │ Card             │                  │
│     │   └──────────────────┘  └──────────────────┘                  │
│     │                                                               │
└─────┴───────────────────────────────────────────────────────────────┘
Nav is collapsed to icon-only (56px)
```

### 3.3 Mobile Layout (<768px)

```
┌─────────────────────────┐
│ [☰] [Logo] [🔍] [👤]   │ ← Minimal header
├─────────────────────────┤
│                         │
│    CONTENT AREA         │
│    (Full width)         │
│                         │
│   ┌───────────────────┐ │
│   │ Card (stacked)    │ │
│   └───────────────────┘ │
│                         │
│   ┌───────────────────┐ │
│   │ Card (stacked)    │ │
│   └───────────────────┘ │
│                         │
├─────────────────────────┤
│ [🏠][📝][⏰][👤][⋯]    │ ← Bottom nav (optional)
└─────────────────────────┘
```

---

## 4. Component-Specific Behaviors

### 4.1 Navigation Menu

| Breakpoint | Behavior |
|------------|----------|
| **Desktop** | Left panel, 240px, always visible |
| **Tablet** | Left panel, 56px, collapsed by default |
| **Mobile** | Hidden, hamburger → drawer overlay |

#### Mobile Drawer

```
┌─────────────────────────┐─┐
│ ← Close                 │ │
├─────────────────────────┤ │
│ [Search menu...]        │ │
├─────────────────────────┤ │
│ 🏠 Home                 │ │
│ 👥 Core HR              │ │
│    ├─ Employees         │ │
│    └─ Organizations     │ │
│ ⏰ Time & Absence       │ │
│ 💰 Payroll              │ │
│                         │ │ ← Swipe left to close
│ ───────────             │ │
│ ⭐ Favorites            │ │
│ ⚙️ Settings             │ │
└─────────────────────────┘─┘
```

### 4.2 Header Bar

| Component | Desktop | Tablet | Mobile |
|-----------|---------|--------|--------|
| Menu toggle | Hidden | Visible | Visible |
| App Switcher | Visible | Hidden | Hidden |
| Logo | Full | Icon only | Icon |
| Module Switcher | Visible | Hidden | In drawer |
| Search Bar | Expanded | Icon → modal | Icon → modal |
| Notifications | Icon + badge | Icon + badge | Icon only |
| Help | Visible | In profile | In drawer |
| Language | Visible | In profile | In drawer |
| Profile | Dropdown | Dropdown | Dropdown |

### 4.3 Data Tables

| Breakpoint | Behavior |
|------------|----------|
| **Desktop** | Full table với all columns |
| **Tablet** | Priority columns + horizontal scroll |
| **Mobile** | Card view hoặc stacked rows |

#### Mobile Table → Card Transformation

```
Desktop Row:
│ Name         │ Department  │ Status  │ Hire Date  │ Actions │

Mobile Card:
┌─────────────────────────────────────────┐
│ Nguyen Van A                      [⋮]  │
│ Senior Developer                        │
│ ───────────────────────────────────     │
│ Dept: Engineering                       │
│ Status: 🟢 Active                       │
│ Hired: Jan 15, 2023                     │
└─────────────────────────────────────────┘
```

### 4.4 Forms

| Desktop | Mobile |
|---------|--------|
| Multi-column (2-3) | Single column |
| Inline labels | Stacked labels |
| Wide inputs | Full-width inputs |
| Date picker popup | Native date input |

---

## 5. Touch Interactions

### 5.1 Touch Targets

| Element | Min Size | Spacing |
|---------|----------|---------|
| Buttons | 44×44px | 8px |
| List items | 48px height | 0 (full width) |
| Icons | 44×44px touch area | 8px |
| Form inputs | 48px height | 16px between |

### 5.2 Gestures

| Gesture | Action |
|---------|--------|
| **Swipe Left** (drawer) | Close navigation drawer |
| **Swipe Right** (from edge) | Open navigation drawer |
| **Pull Down** | Refresh (where applicable) |
| **Long Press** | Context menu (list items) |
| **Pinch** | Zoom (images, charts only) |

### 5.3 Quy Định Touch

| Mã | Quy định | Priority |
|----|----------|----------|
| TC-01 | Tất cả interactive elements ≥ 44×44px | P0 |
| TC-02 | Spacing giữa touch targets ≥ 8px | P0 |
| TC-03 | Feedback visual khi touch (ripple/highlight) | P1 |
| TC-04 | No hover-dependent features on touch | P0 |

---

## 6. Mobile-Specific Features

### 6.1 Bottom Navigation (Optional)

Cho mobile-first apps với high-frequency actions:

```
┌─────────────────────────────────────────┐
│        [🏠]    [📝]    [⏰]    [👤]     │
│        Home   Tasks   Time   Profile    │
└─────────────────────────────────────────┘
```

| Mã | Quy định |
|----|----------|
| BN-01 | Max 5 items trong bottom nav |
| BN-02 | Most frequent actions only |
| BN-03 | Current tab highlighted |
| BN-04 | Badge cho pending items |

### 6.2 Floating Action Button (FAB)

Cho primary action (e.g., Create):

```
                          ┌─────┐
                          │  +  │ ← FAB
                          └─────┘
```

| Mã | Quy định |
|----|----------|
| FAB-01 | Position: bottom-right, 16px from edges |
| FAB-02 | Size: 56×56px |
| FAB-03 | Single primary action only |
| FAB-04 | Hide on scroll down, show on scroll up |

### 6.3 Pull-to-Refresh

```
      ↓ Pull down to refresh
   ┌─────────────────────────┐
   │ ⟳ Loading...            │
   └─────────────────────────┘
```

---

## 7. Performance Considerations

### 7.1 Mobile Optimization

| Concern | Solution |
|---------|----------|
| **Large images** | Responsive images, lazy loading |
| **Heavy JS** | Code splitting, defer non-critical |
| **Data tables** | Virtual scrolling, pagination |
| **Animations** | Reduce on `prefers-reduced-motion` |

### 7.2 Offline Capabilities

| Feature | Offline Support |
|---------|-----------------|
| View cached data | ✅ Yes |
| Submit forms | ⬜ Queue for sync |
| Search | ⬜ Limited (cached) |
| Notifications | ❌ No |

---

## 8. Testing Requirements

### 8.1 Device Testing Matrix

| Device Category | Examples |
|-----------------|----------|
| **iOS Phone** | iPhone SE, iPhone 14 Pro |
| **iOS Tablet** | iPad Air, iPad Pro |
| **Android Phone** | Pixel 7, Samsung S23 |
| **Android Tablet** | Samsung Tab S8 |
| **Desktop** | Chrome, Firefox, Safari, Edge |

### 8.2 Responsive Testing Checklist

- [ ] Navigation works at all breakpoints
- [ ] No horizontal scroll on mobile
- [ ] Touch targets are large enough
- [ ] Text is readable without zoom
- [ ] Forms are usable on small screens
- [ ] Tables adapt gracefully
- [ ] Modals fit on mobile screens

---

## 9. Accessibility on Mobile

| Requirement | Implementation |
|-------------|----------------|
| Screen readers | VoiceOver (iOS), TalkBack (Android) support |
| Text scaling | Support up to 200% font size |
| Color contrast | Same as desktop (4.5:1 min) |
| Focus indicators | Visible on keyboard/switch access |
| Orientation | Support both portrait and landscape |

---

## See Also

| Document | Relationship |
|----------|--------------|
| [01-shell-layout.md](./01-shell-layout.md) | Breakpoints definition |
| [02-navigation-menu.md](./02-navigation-menu.md) | Nav drawer mobile |
| [../01-page-patterns/01-master-data-page.md](../01-page-patterns/01-master-data-page.md) | Table → Card on mobile |
| [../02-content-layouts/01-tabs-layout.md](../02-content-layouts/01-tabs-layout.md) | Tab overflow mobile |
| [../02-content-layouts/04-form-layout.md](../02-content-layouts/04-form-layout.md) | Form single-column mobile |
