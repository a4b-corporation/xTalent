# {Screen Name} - UI Specification

> Detailed specification for the {Screen Name} user interface

---

## Document Information

- **Screen**: {Screen Name}
- **Module**: {Module Name}
- **Version**: 1.0
- **Last Updated**: {Date}
- **Designer**: {Name}
- **Status**: Draft | Review | Approved

---

## Overview

### Purpose
[What is this screen for?]

### User Roles
[Who can access this screen?]
- {Role 1}: {Access level}
- {Role 2}: {Access level}

### Navigation
[How do users get to this screen?]
- From {Screen A}: Click {Button/Link}
- From {Screen B}: Select {Menu Item}

---

## Layout

### Screen Structure

```
┌─────────────────────────────────────────────────────┐
│ Header: {Screen Title}                    [Actions] │
├─────────────────────────────────────────────────────┤
│                                                     │
│  {Main Content Area}                                │
│                                                     │
│  ┌───────────────────────────────────────────────┐ │
│  │ {Section 1}                                   │ │
│  │                                               │ │
│  └───────────────────────────────────────────────┘ │
│                                                     │
│  ┌───────────────────────────────────────────────┐ │
│  │ {Section 2}                                   │ │
│  │                                               │ │
│  └───────────────────────────────────────────────┘ │
│                                                     │
├─────────────────────────────────────────────────────┤
│ Footer: [Cancel] [Save]                            │
└─────────────────────────────────────────────────────┘
```

### Responsive Behavior

| Breakpoint | Layout Changes |
|------------|----------------|
| Desktop (>1024px) | {Description} |
| Tablet (768-1024px) | {Description} |
| Mobile (<768px) | {Description} |

---

## Components

### Component 1: {Component Name}

**Type**: {Input | Select | Button | Table | etc.}

**Label**: "{Label Text}"

**Properties**:
- **ID**: `{component-id}`
- **Name**: `{componentName}`
- **Required**: Yes | No
- **Disabled**: {Condition when disabled}
- **Visible**: {Condition when visible}
- **Default Value**: {Default value if any}

**Validation**:
- {Validation rule 1}
- {Validation rule 2}

**Error Messages**:
- {Condition}: "{Error message}"

**Help Text**: "{Helper text shown to user}"

**Example**:
```
Component: Leave Type Selector

Type: Dropdown (sl-select)
Label: "Leave Type"
Properties:
  - ID: leave-type-select
  - Name: leaveTypeId
  - Required: Yes
  - Disabled: When form is in view mode
  - Visible: Always
  - Default: None (placeholder shown)

Validation:
  - Must select a value
  - Selected leave type must be active

Error Messages:
  - Empty: "Please select a leave type"
  - Inactive: "This leave type is no longer available"

Help Text: "Select the type of leave you want to request"

Data Source: GET /api/ta/leave-types?status=ACTIVE
Display Format: "{name} ({maxDaysPerYear} days/year)"
```

---

### Component 2: {Component Name}

[Repeat structure for each component]

---

## Fields

### Field Matrix

| Field | Type | Required | Validation | Default | Visible When |
|-------|------|----------|------------|---------|--------------|
| {field1} | {type} | Yes/No | {rules} | {value} | {condition} |
| {field2} | {type} | Yes/No | {rules} | {value} | {condition} |

**Example**:
```
| Field | Type | Required | Validation | Default | Visible When |
|-------|------|----------|------------|---------|--------------|
| leaveTypeId | Select | Yes | Must be active leave type | - | Always |
| startDate | Date | Yes | >= today, <= today+365 | - | Always |
| endDate | Date | Yes | >= startDate | - | Always |
| totalDays | Number | No | - | Calculated | Always (readonly) |
| reason | Textarea | No | Max 500 chars | - | Always |
| attachment | File | No | PDF/Image, max 5MB | - | If leave type allows |
```

---

## States

### State 1: {State Name}

**When**: {Condition that triggers this state}

**UI Changes**:
- {Component 1}: {Change description}
- {Component 2}: {Change description}

**Available Actions**:
- {Action 1}: {Description}
- {Action 2}: {Description}

**Example**:
```
State: Loading

When: Data is being fetched from API

UI Changes:
  - Form: Show skeleton loaders
  - Submit button: Disabled with spinner
  - All inputs: Disabled

Available Actions:
  - None (wait for load to complete)
```

---

### State 2: {State Name}

[Repeat for each state: Initial, Loading, Loaded, Editing, Saving, Error, Success]

---

## Interactions

### Interaction 1: {Interaction Name}

**Trigger**: {What triggers this interaction}

**Steps**:
1. User {action}
2. System {response}
3. UI {update}

**API Call** (if applicable):
```
Method: {GET | POST | PUT | DELETE}
Endpoint: {/api/path}
Payload: {JSON structure}
```

**Success**:
- UI: {What happens on success}
- Message: "{Success message}"
- Navigation: {Where user goes}

**Error**:
- UI: {What happens on error}
- Message: "{Error message}"

**Example**:
```
Interaction: Submit Leave Request

Trigger: User clicks "Submit" button

Steps:
1. User clicks "Submit" button
2. System validates all fields client-side
3. If valid, show loading state
4. Make API call
5. Handle response

API Call:
  Method: POST
  Endpoint: /api/ta/leave-requests
  Payload:
    {
      "leaveTypeId": "uuid",
      "startDate": "2025-02-01",
      "endDate": "2025-02-05",
      "reason": "Family vacation"
    }

Success:
  - UI: Show success toast
  - Message: "Leave request submitted successfully"
  - Navigation: Redirect to leave requests list
  - Clear form data

Error:
  - UI: Show error alert at top of form
  - Message: Display error from API response
  - Navigation: Stay on form
  - Keep form data
```

---

### Interaction 2: {Interaction Name}

[Repeat for each interaction]

---

## Data Binding

### Data Sources

#### Source 1: {API Endpoint}

**Endpoint**: `{HTTP Method} {/api/path}`

**When Called**: {Trigger condition}

**Response Structure**:
```json
{
  "field1": "value",
  "field2": "value"
}
```

**Mapping to UI**:
- `response.field1` → `{component-id}`
- `response.field2` → `{component-id}`

**Error Handling**: {How errors are displayed}

---

### Computed Values

#### Computed 1: {Computed Value Name}

**Formula**: {Calculation logic}

**Depends On**: {List of fields}

**Updates When**: {Trigger}

**Example**:
```
Computed: Total Days

Formula: 
  Count working days between startDate and endDate
  Exclude weekends and public holidays

Depends On: 
  - startDate
  - endDate
  - publicHolidays (from API)

Updates When: 
  - startDate changes
  - endDate changes

Display:
  - Show as readonly field
  - Format: "{X} days"
  - If 0 or negative: Show error
```

---

## Validation

### Client-Side Validation

| Field | Rule | Message | When |
|-------|------|---------|------|
| {field} | {rule} | "{message}" | {trigger} |

**Example**:
```
| Field | Rule | Message | When |
|-------|------|---------|------|
| startDate | Required | "Start date is required" | On submit |
| startDate | >= today | "Start date cannot be in the past" | On change |
| endDate | >= startDate | "End date must be after start date" | On change |
| reason | Max 500 chars | "Reason cannot exceed 500 characters" | On input |
```

### Server-Side Validation

[List validations that happen on the server]

**Validation 1**: {Description}
- **Error Code**: `{ERROR_CODE}`
- **Message**: "{Error message}"
- **UI Response**: {How to display}

---

## Error Handling

### Error Display Patterns

#### Field-Level Errors
- **Location**: Below the field
- **Style**: Red text, error icon
- **Behavior**: Show on blur or submit

#### Form-Level Errors
- **Location**: Top of form
- **Style**: Alert box (danger variant)
- **Behavior**: Show after API error response

#### Global Errors
- **Location**: Toast notification
- **Style**: Error toast (top-right)
- **Behavior**: Auto-dismiss after 5s

### Error Messages

| Error Code | User Message | Action |
|------------|--------------|--------|
| {CODE} | "{Message}" | {What user should do} |

**Example**:
```
| Error Code | User Message | Action |
|------------|--------------|--------|
| INSUFFICIENT_BALANCE | "You have only {X} days available but requested {Y} days" | Reduce requested days |
| OVERLAPPING_DATES | "This request overlaps with leave request #{id}" | Choose different dates |
| NETWORK_ERROR | "Unable to connect. Please check your internet connection" | Retry |
```

---

## Accessibility

### ARIA Labels

| Element | ARIA Label |
|---------|------------|
| {element} | "{label}" |

### Keyboard Navigation

| Key | Action |
|-----|--------|
| Tab | Move to next field |
| Shift+Tab | Move to previous field |
| Enter | Submit form (if on submit button) |
| Esc | Cancel/Close |

### Screen Reader Support

- All form fields have labels
- Error messages are announced
- Loading states are announced
- Success/failure is announced

---

## Performance

### Loading Strategy

- **Initial Load**: {What loads first}
- **Lazy Load**: {What loads on demand}
- **Caching**: {What is cached}

### Optimization

- Debounce search inputs (300ms)
- Throttle scroll events (100ms)
- Virtualize long lists (>100 items)

---

## Mockup Reference

**Figma**: {Link to Figma design}

**HTML Prototype**: `../03-mockups/{screen-name}.html`

**Screenshots**:
- Initial state: `{screen-name}-initial.png`
- Filled state: `{screen-name}-filled.png`
- Error state: `{screen-name}-error.png`
- Success state: `{screen-name}-success.png`

---

## Implementation Notes

### Technology Stack
- **Framework**: {HTMX | React | Vue | etc.}
- **Component Library**: {Shoelace | Material UI | etc.}
- **Styling**: {CSS | Tailwind | etc.}

### Key Components to Use
- `{component-1}`: For {purpose}
- `{component-2}`: For {purpose}

### Special Considerations
- {Note 1}
- {Note 2}

---

## Test Scenarios

### TS-001: {Test Scenario}

**Steps**:
1. {Step}
2. {Step}

**Expected Result**: {Result}

---

## Related Documents

- [Behavioural Spec](../02-spec/01-behaviour-spec.md)
- [API Spec](../04-api/)
- [Mockup](../05-ui/03-mockups/{screen-name}.html)

---

**Approval**

| Role | Name | Signature | Date |
|------|------|-----------|------|
| UX Designer | | | |
| Frontend Lead | | | |
| Product Owner | | | |
