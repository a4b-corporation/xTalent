# Navigation Flows - Payroll Module (PR)

> **Module**: Payroll (PR)
> **Phase**: Experience (Step 5)
> **Date**: 2026-03-31
> **Version**: 1.0

---

## Overview

This document defines cross-feature navigation flows for P0 user stories. Each flow shows how users navigate between screens to complete a task.

---

## P0 User Story Flows

### Flow 1: Create Pay Element (US-001)

**User Story**: As a Payroll Admin, I want to create a new pay element with classification and calculation type.

```
Start: Pay Element List Screen
│
├── 1. Click "Create" button
│   └── Navigate to: Pay Element Create Screen
│
├── 2. Fill form fields
│   ├── Enter elementCode
│   ├── Enter elementName
│   ├── Select legalEntity (dropdown from CO)
│   ├── Select classification (EARNING, DEDUCTION, TAX, EMPLOYER_CONTRIBUTION)
│   │   └── Inline: Show classification impact description
│   ├── Select calculationType (FIXED, FORMULA, RATE_BASED, HOURS_BASED)
│   ├── If FORMULA: Lookup formula (opens Formula Picker)
│   ├── Enter rate (if RATE_BASED)
│   ├── Enter amount (if FIXED)
│   ├── Set effectiveStartDate
│   ├── Toggle statutoryFlag
│   ├── Toggle taxableFlag
│
├── 3. Click "Save"
│   ├── If validation passes:
│   │   ├── POST /pay-elements
│   │   ├── Toast: Success "Pay Element created successfully"
│   │   ├── Navigate to: Pay Element Detail Screen
│   │   └── Badge: Version 1 badge shown
│   │
│   └── If validation fails:
│   │   ├── Inline: Field-level errors shown
│   │   ├── Modal: Validation Error Modal (if critical)
│   │   └── Stay on: Pay Element Create Screen
│
└── 4. From Detail Screen
    ├── Click "View Versions" → Version Timeline Screen
    ├── Click "Edit" → Pay Element Edit Screen
    └── Click "Back" → Pay Element List Screen
```

---

### Flow 2: Update Pay Element with Version Tracking (US-002)

**User Story**: As a Payroll Admin, I want to update a pay element with version tracking.

```
Start: Pay Element Detail Screen
│
├── 1. Click "Edit" button
│   └── Navigate to: Pay Element Edit Screen
│       └── Load: Current version data
│
├── 2. Modify fields
│   ├── Change rate/amount/classification
│   ├── Select "Preview" button
│   │   └── Modal: Version Comparison Preview
│   │       └── Show: Old vs New values side-by-side
│   │       └── Buttons: Commit, Cancel
│   │
│   ├── Enter versionReason (required)
│   ├── Select effectiveStartDate
│   │   └── Inline: Validate no overlap with existing versions
│
├── 3. Click "Commit"
│   ├── POST /pay-elements/{code}/versions
│   ├── Toast: Success "New version created (v2)"
│   ├── Navigate to: Pay Element Detail Screen (v2)
│   └── Previous version: isCurrentFlag = false
│
└── 4. From Detail Screen
    ├── Click "View Versions" → Version Timeline Screen
    │   ├── Timeline shows: v1 (closed), v2 (current)
    │   ├── Click v1 → View v1 detail
    │   ├── Click "Compare" → Version Comparison Modal
    │   │   ├── Select v1 and v2
    │   │   └── Show highlighted changes
    │   └── Export version history → CSV/PDF
    └── Click "Back" → Pay Element List Screen
```

---

### Flow 3: Create Pay Profile with Element Assignment (US-005, US-006)

**User Story**: As a Payroll Admin, I want to create a pay profile to bundle pay elements and rules.

```
Start: Pay Profile List Screen
│
├── 1. Click "Create" button
│   └── Navigate to: Pay Profile Create Screen
│
├── 2. Fill profile info
│   ├── Enter profileCode
│   ├── Enter profileName
│   ├── Select legalEntity (dropdown from CO)
│   ├── Select payFrequency (dropdown from CO)
│   ├── Enter description
│   ├── Set effectiveStartDate
│
├── 3. Assign pay elements
│   ├── Click "Add Element" button
│   │   └── Modal: Assign Element Modal
│   │       ├── Search: Pay Element dropdown
│   │       ├── Enter: Priority (1-99)
│   │       ├── Optional: Formula override
│   │       ├── Optional: Rate override
│   │       ├── Optional: Amount override
│   │       ├── Set: Effective start date
│   │       ├── Click: Add
│   │       └── Modal closes, element added to list
│   │
│   ├── Panel: Element Assignment Panel (shows assigned elements)
│   │   ├── Drag to reorder priority
│   │   ├── Click override icon → Override Configuration Modal
│   │   ├── Click remove icon → Confirm removal
│   │
│   ├── Assign statutory rules (similar flow)
│   │   └── Click "Add Rule" → Select Statutory Rule → Add
│
├── 4. Click "Save Profile"
│   ├── POST /pay-profiles
│   ├── Toast: Success "Pay Profile created with 5 elements"
│   ├── Navigate to: Pay Profile Detail Screen
│
└── 5. From Detail Screen
    ├── Tab: Element Assignments
    ├── Tab: Statutory Rules
    ├── Tab: Version History
    ├── Click "Create Pay Group" → Quick create group from profile
    └── Click "Back" → Pay Profile List Screen
```

---

### Flow 4: Configure PIT Progressive Brackets (US-010)

**User Story**: As a Payroll Admin, I want to configure progressive tax brackets for PIT.

```
Start: Statutory Rule List Screen
│
├── 1. Find or create PIT rule
│   ├── If existing: Click on PIT rule row
│   │   └── Navigate to: Statutory Rule Detail Screen
│   │
│   └── If new: Click "Create"
│   │   └── Navigate to: Statutory Rule Create Screen
│   │       ├── Enter ruleCode: "PIT_VN_2026"
│   │       ├── Enter ruleName: "Vietnam PIT 2026"
│   │       ├── Select statutoryType: "PIT"
│   │       ├── Select partyType: "EMPLOYEE"
│   │       ├── Select rateType: "PROGRESSIVE"
│   │       ├── Save → Navigate to Detail Screen
│
├── 2. Configure brackets
│   ├── Click "Configure Brackets" button
│   │   └── Navigate to: PIT Bracket Configuration Screen
│   │
│   ├── Panel: Bracket Editor
│   │   ├── Table: Bracket #, Min Amount, Max Amount, Rate
│   │   ├── Row 1: 0 - 5,000,000 @ 5%
│   │   ├── Row 2: 5,000,001 - 10,000,000 @ 10%
│   │   ├── ... (7 rows total)
│   │   ├── Row 7: 80,000,001 - null @ 35%
│   │   ├── Click row → Modal: Bracket Editor Modal
│   │   │   └── Edit values
│   │   ├── Click "Add Bracket" → Add row
│   │   ├── Click "Remove Bracket" → Confirm removal
│   │
│   ├── Panel: Bracket Visualization Chart
│   │   └── Bar chart showing progressive rates
│   │   └── Hover → Show bracket details
│   │
│   ├── Validation
│   │   ├── Inline: "Brackets must cover full range" warning
│   │   ├── Inline: "Gap detected between bracket 3 and 4"
│   │   ├── Toast: "Last bracket must have null max amount"
│   │
├── 3. Configure exemptions
│   ├── Enter personalExemption: 11,000,000 VND
│   ├── Enter dependentExemption: 4,400,000 VND
│   └── Modal: Exemption Configuration Modal (optional advanced)
│
├── 4. Click "Save Configuration"
│   ├── PUT /statutory-rules/{code}/configure-pit-brackets
│   ├── Toast: Success "PIT brackets configured (7 brackets)"
│   ├── Navigate to: Statutory Rule Detail Screen
│
└── 5. View version history
    ├── Click "View Versions" → Version Timeline Screen
    └── Government rate changes trigger version creation
```

---

### Flow 5: Create Pay Calendar with Period Generation (US-007)

**User Story**: As a Payroll Admin, I want to create a pay calendar with pay periods.

```
Start: Pay Calendar List Screen
│
├── 1. Click "Create" button
│   └── Navigate to: Pay Calendar Create Screen
│
├── 2. Fill calendar info
│   ├── Enter calendarCode
│   ├── Enter calendarName
│   ├── Select legalEntity (dropdown from CO)
│   ├── Select payFrequency (MONTHLY, SEMI_MONTHLY, etc.)
│   ├── Enter fiscalYear: 2026
│   ├── Enter startDate: 2026-01-01
│   ├── Enter endDate: 2026-12-31
│
├── 3. Preview generated periods
│   ├── Click "Preview Periods" button
│   │   └── Modal: Period Generation Preview Modal
│   │       ├── Table: Shows 12 generated periods
│   │       ├── Columns: Period #, Start, End, Cut-off, Pay Date
│   │       ├── Adjust: Default cut-off days, default pay days
│   │       ├── Validate: Sequential dates
│   │       ├── Click "Generate" or "Cancel"
│   │
│   ├── If gaps detected:
│   │   └── Toast: Warning "Period dates not sequential"
│   │
├── 4. Click "Save Calendar"
│   ├── POST /pay-calendars
│   ├── POST /pay-calendars/{code}/generate-periods (auto-trigger)
│   ├── Toast: Success "Calendar created with 12 periods"
│   ├── Navigate to: Pay Calendar Detail Screen
│       └── Tab: Pay Periods
│       └── Table: Periods list with status
│
├── 5. Adjust individual period
│   ├── Click on period row
│   │   └── Modal: Period Adjustment Modal
│   │       ├── Edit cutOffDate
│   │       ├── Edit payDate
│   │       ├── Enter adjustmentReason
│   │       ├── Click "Save Adjustment"
│   │       └── Toast: Success "Period 3 adjusted"
│   │
├── 6. Period status workflow
│   ├── OPEN → Click "Close" → Confirm → Status: CLOSED
│   ├── CLOSED → Click "Reopen" → Confirm → Status: REOPENED
│   ├── CLOSED → Click "Mark Paid" → Status: PAID
│
└── 7. Navigate back
    └── Click "Back" → Pay Calendar List Screen
```

---

### Flow 6: Assign Employee to Pay Group (US-008)

**User Story**: As a Payroll Admin, I want to create a pay group and assign employees.

```
Start: Pay Group List Screen
│
├── 1. Click "Create" button
│   └── Navigate to: Pay Group Create Screen
│
├── 2. Configure pay group
│   ├── Enter groupCode
│   ├── Enter groupName
│   ├── Lookup payProfileId
│   │   └── Modal: Pay Profile Picker
│   │       └── Search profiles, select one
│   ├── Lookup payCalendarId
│   │   └── Modal: Pay Calendar Picker
│   │       └── Search calendars, select one
│   ├── Enter description
│
├── 3. Click "Create Group"
│   ├── POST /pay-groups
│   ├── Toast: Success "Pay Group created"
│   ├── Navigate to: Pay Group Detail Screen
│       └── Tab: Employee Assignments
│
├── 4. Assign employees
│   ├── Click "Assign Employee" button
│   │   └── Modal: Employee Picker Modal
│   │       ├── Search: Employee name/ID (calls CO API)
│   │       ├── List: Employee results with status
│   │       ├── Select: Employee row
│   │       ├── Dropdown: Assignment Reason (NEW_HIRE, TRANSFER, etc.)
│   │       ├── Date: Assignment Date
│   │       ├── Click: "Assign"
│   │       │
│   │       ├── If employee already assigned:
│   │       │   └── Toast: Error "Employee EMP001 already in GRP_STAFF"
│   │       │   └── Stay in modal
│   │       │
│   │       ├── If validation passes:
│   │       │   └── POST /pay-groups/{code}/assign-employee
│   │       │   └── Toast: Success "Employee assigned"
│   │       │   └── Modal closes
│   │       │   └── Assignment list refreshes
│   │
│   ├── Panel: Assignment History (per employee)
│   │   └── Click employee row → Show history panel
│   │   └── List: Previous assignments, removals
│   │
├── 5. Remove employee
│   ├── Click remove icon on employee row
│   │   └── Modal: Confirm Removal
│   │       ├── Dropdown: Removal Reason
│   │       ├── Click: "Confirm Removal"
│   │       └── DELETE /pay-groups/{code}/employees/{id}
│   │       └── Toast: Success "Employee removed"
│   │
└── 6. Navigate back
    └── Click "Back" → Pay Group List Screen
```

---

### Flow 7: View Audit Trail (US-023)

**User Story**: As an HR Manager, I want to view audit logs of all configuration changes.

```
Start: Main Menu
│
├── 1. Click "Audit Trail" menu item
│   └── Navigate to: Audit Trail Query Screen
│
├── 2. Configure search filters
│   ├── Select date range (start, end)
│   ├── Select entity type filter (dropdown)
│   │   └── Options: PayElement, PayProfile, StatutoryRule, PayCalendar, PayGroup, Formula
│   ├── Select user filter (who made change)
│   ├── Select operation filter
│   │   └── Options: CREATE, UPDATE, DELETE, ASSIGN, VERSION_CREATE
│
├── 3. Click "Search"
│   ├── GET /audit-logs?filters
│   ├── Table: Results display
│   │   └── Columns: Entity Type, Entity ID, Entity Name, Operation, Changed By, Changed At, Change Reason
│   │   └── Pagination: 20 per page
│   │
│   ├── If no results:
│   │   └── Message: "No audit entries found for selected criteria"
│   │
├── 4. View entry detail
│   ├── Click on audit entry row
│   │   └── Navigate to: Audit Entry Detail Screen
│   │       ├── Panel: Entry Metadata
│   │       │   └── Entity type, ID, operation, user, timestamp, reason
│   │       ├── Panel: Change Details
│   │       │   ├── Split view: Old Value (JSON) | New Value (JSON)
│   │       │   └── Highlighted: Changed fields
│   │       ├── Link: View version (if VERSION_CREATE)
│   │       └── Click: View entity → Navigate to entity detail
│   │
├── 5. Export audit trail
│   ├── Click "Export CSV" button
│   │   └── GET /audit-logs/export?format=CSV
│   │   └── Download: audit-trail-2026-03-31.csv
│   │
│   ├── Click "Export PDF" button
│   │   └── GET /audit-logs/export?format=PDF
│   │   └── Download: audit-report-2026-03-31.pdf
│   │       └── PDF includes: Header, summary, all entries
│   │
└── 6. Navigate back
    └── Click "Back" → Audit Trail Query Screen
```

---

### Flow 8: Configuration Validation (US-014)

**User Story**: As a Payroll Admin, I want to receive validation feedback when configuring payroll.

This flow is embedded within other flows, not a standalone navigation.

```
Embedded in: Pay Element Create/Edit Screen
│
├── Field Validation (inline)
│   ├── On input change:
│   │   ├── Validate field format
│   │   ├── If error: Show inline error below field
│   │   │   └── Example: "Rate must be between 0 and 1"
│   │   ├── If valid: Clear error
│   │
├── Cross-field Validation (on blur)
│   ├── Example: effectiveStartDate vs effectiveEndDate
│   │   ├── If end < start: Show inline error "End date must be after start date"
│   │
├── Entity Validation (on save)
│   ├── Click "Save":
│   │   ├── Run entity-level validation
│   │   ├── Example: Profile has no elements
│   │   │   └── Banner: Warning "Profile has no pay elements assigned"
│   │   │   └── Button: "Acknowledge and Save"
│   │
├── Cross-entity Validation (on save)
│   ├── Run reference validation
│   │   ├── Example: Element is in use
│   │   │   └── Modal: Error "Cannot delete - Element is in use by PROFILE_STAFF"
│   │   │   └── Block: Save prevented
│   │
├── Business Rule Validation (on save)
│   ├── Example: Statutory rate mismatch
│   │   ├── Modal: Warning "Rate differs from government rate 8%. Are you sure?"
│   │   │   ├── Button: "Proceed with custom rate"
│   │   │   │   └── Log override decision
│   │   │   ├── Button: "Use recommended rate"
│   │   │   │   ├── Update rate to 8%
│   │   │   │   └── Proceed to save
```

---

## Cross-Feature Navigation Paths

### Path 1: Element → Profile → Group Assignment

```
Pay Element Detail Screen
│
├── "Used in Profiles" section
│   └── List: Profiles using this element
│   └── Click profile → Pay Profile Detail Screen
│       │
│       ├── "Used in Groups" section
│       │   └── List: Groups using this profile
│       │   └── Click group → Pay Group Detail Screen
│       │       │
│       │       ├── "Assigned Employees" tab
│       │       │   └── List: Employees in group
│       │       │   └── Click employee → Employee Detail (CO module)
```

### Path 2: Calendar → Period → Group Assignment

```
Pay Calendar Detail Screen
│
├── "Pay Periods" tab
│   └── List: Periods with status
│   └── Click period → Period Adjustment Modal
│
├── "Used in Groups" section
│   └── List: Groups using this calendar
│   └── Click group → Pay Group Detail Screen
```

### Path 3: Statutory Rule → Profile → Version

```
Statutory Rule Detail Screen
│
├── "Assigned to Profiles" section
│   └── List: Profiles using this rule
│   └── Click profile → Pay Profile Detail Screen
│       │
│       ├── "Version History" tab
│       │   └── Click version → Version Detail
│       │
│       ├── "Rule Version History" link
│       │   └── Navigate to: Statutory Rule Version Timeline
```

---

## Quick Navigation Shortcuts

| Shortcut | Action | Navigation Target |
|----------|--------|-------------------|
| Ctrl+E | Create Pay Element | Pay Element Create Screen |
| Ctrl+P | Create Pay Profile | Pay Profile Create Screen |
| Ctrl+G | Create Pay Group | Pay Group Create Screen |
| Ctrl+A | Audit Trail | Audit Trail Query Screen |
| Ctrl+V | Validation Results | Validation Result Screen |

---

## Error Recovery Navigation

| Error Type | Recovery Action | Navigation |
|------------|----------------|------------|
| Validation Error | Fix field, retry save | Stay on current screen |
| Conflict Detected | Resolve in Conflict Queue | Conflict Queue Screen |
| In-Use Error | Remove from profile first | Navigate to profile detail |
| Version Overlap | Adjust effective date | Stay on edit screen |

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Experience Architect Agent