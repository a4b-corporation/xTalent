# Interaction Map - Payroll Module (PR)

> **Module**: Payroll (PR)
> **Phase**: Experience (Step 5)
> **Date**: 2026-03-31
> **Version**: 1.0

---

## Overview

This document maps features to interaction points. In the AI-native era, interaction points include screens, chat interfaces, voice commands, notifications, and AI agent prompts. Each feature has at least one interaction point.

---

## Interaction Point Types

| Type | Code | Description | Example |
|------|------|-------------|---------|
| Screen | S | Traditional web/mobile UI screen | Pay Element List Screen |
| Modal | M | Overlay dialog for focused action | Create Pay Element Modal |
| Panel | P | Side panel for contextual actions | Element Assignment Panel |
| Toast | T | Notification message | Success/Error toast |
| Badge | B | Status indicator | Conflict count badge |
| Chat | C | AI chat interface | Formula Assistant Chat |
| Voice | V | Voice command (future) | "Show BHXH rate changes" |
| Export | E | File download action | Export Audit Trail CSV |

---

## Feature-to-Interaction Point Mapping

### PR-PC-M-001: Pay Element Management

| Interaction ID | Type | Name | Purpose | Primary Actor |
|----------------|------|------|---------|---------------|
| I-PE-001 | S | Pay Element List Screen | Browse, filter, search pay elements | Payroll Admin |
| I-PE-002 | S | Pay Element Create Screen | Create new pay element | Payroll Admin |
| I-PE-003 | S | Pay Element Edit Screen | Update pay element (creates version) | Payroll Admin |
| I-PE-004 | S | Pay Element Detail Screen | View element details and assignments | Payroll Admin |
| I-PE-005 | S | Version Timeline Screen | Visual timeline of versions | Payroll Admin |
| I-PE-006 | M | Version Comparison Modal | Side-by-side compare two versions | Payroll Admin |
| I-PE-007 | M | Version Creation Modal | Create new version with reason | Payroll Admin |
| I-PE-008 | M | Delete Confirmation Modal | Confirm soft delete with reason | Payroll Admin |
| I-PE-009 | T | Success Toast | Operation completed successfully | System |
| I-PE-010 | T | Error Toast | Validation or operation failed | System |
| I-PE-011 | B | Version Badge | Show version count on element | System |

**Screen Layout**:

| Screen | Layout | Components |
|--------|--------|------------|
| Pay Element List | Table + Filters | Search bar, Classification filter, Legal Entity filter, Status filter, Table with columns: Code, Name, Classification, Calculation Type, Version Badge, Actions |
| Pay Element Create | Form | Element Code, Element Name, Legal Entity dropdown, Classification select, Calculation Type select, Formula lookup, Rate input, Amount input, Effective Start Date, Taxable Flag, Statutory Flag, Save/Cancel buttons |
| Pay Element Edit | Form + Version | Same as Create, plus Version Reason textarea, Preview changes button |
| Version Timeline | Timeline Visual | Horizontal timeline showing versions, click to view detail |

---

### PR-PC-M-002: Pay Profile Management

| Interaction ID | Type | Name | Purpose | Primary Actor |
|----------------|------|------|---------|---------------|
| I-PP-001 | S | Pay Profile List Screen | Browse pay profiles | Payroll Admin |
| I-PP-002 | S | Pay Profile Create Screen | Create new pay profile | Payroll Admin |
| I-PP-003 | S | Pay Profile Detail Screen | View profile with assignments | Payroll Admin |
| I-PP-004 | P | Element Assignment Panel | Assign elements to profile | Payroll Admin |
| I-PP-005 | M | Assign Element Modal | Add element with overrides | Payroll Admin |
| I-PP-006 | M | Override Configuration Modal | Set formula/rate/amount override | Payroll Admin |
| I-PP-007 | S | Version Timeline Screen | View profile version history | Payroll Admin |
| I-PP-008 | M | Version Comparison Modal | Compare profile versions | Payroll Admin |
| I-PP-009 | T | Success/Error Toast | Operation feedback | System |

**Screen Layout**:

| Screen | Layout | Components |
|--------|--------|------------|
| Pay Profile List | Table + Filters | Profile Code, Profile Name, Legal Entity, Pay Frequency, Element Count, Version Badge, Actions |
| Pay Profile Detail | Tabs | Profile Info tab, Element Assignments tab, Statutory Rules tab, Version History tab |
| Element Assignment Panel | Table + Drag | Element table with Priority (drag reorder), Override indicators, Add/Remove buttons |

---

### PR-PC-M-003: Pay Formula Management

| Interaction ID | Type | Name | Purpose | Primary Actor |
|----------------|------|------|---------|---------------|
| I-FM-001 | S | Formula List Screen | Browse formulas | Payroll Admin |
| I-FM-002 | S | Formula Builder Screen | Create/edit formula | Payroll Admin |
| I-FM-003 | P | Validation Feedback Panel | Real-time validation feedback | System |
| I-FM-004 | M | Formula Preview Modal | Preview with sample values | Payroll Admin |
| I-FM-005 | M | Element Reference Picker | Select elements to reference | Payroll Admin |
| I-FM-006 | T | Validation Toast | Syntax/validation result | System |
| I-FM-007 | C | AI Formula Chat (Future) | AI-powered formula assistance | Payroll Admin |

**Screen Layout**:

| Screen | Layout | Components |
|--------|--------|------------|
| Formula Builder | Split Panel | Left: Expression editor with syntax highlighting, Right: Validation panel with errors/warnings, Element reference list, Preview button |
| Formula Preview | Modal | Sample value inputs for each referenced element, Calculate button, Result display |

---

### PR-SC-M-001: Statutory Rule Management

| Interaction ID | Type | Name | Purpose | Primary Actor |
|----------------|------|------|---------|---------------|
| I-SR-001 | S | Statutory Rule List Screen | Browse statutory rules | Payroll Admin, Compliance Officer |
| I-SR-002 | S | Statutory Rule Create Screen | Create new statutory rule | Payroll Admin |
| I-SR-003 | S | Statutory Rule Detail Screen | View rule details | Payroll Admin, Compliance Officer |
| I-SR-004 | S | PIT Bracket Configuration Screen | Configure progressive tax brackets | Compliance Officer |
| I-SR-005 | M | Bracket Editor Modal | Edit individual bracket | Compliance Officer |
| I-SR-006 | S | Bracket Visualization Chart | Visual progressive rate chart | Compliance Officer |
| I-SR-007 | M | Exemption Configuration Modal | Set personal/dependent exemptions | Compliance Officer |
| I-SR-008 | S | Version Timeline Screen | View rule version history | Payroll Admin, Compliance Officer |
| I-SR-009 | M | Rate Change Warning Modal | Confirm rate change with compliance warning | Payroll Admin |
| I-SR-010 | T | Government Rate Warning | Rate differs from reference rate | System |
| I-SR-011 | T | Success/Error Toast | Operation feedback | System |

**Screen Layout**:

| Screen | Layout | Components |
|--------|--------|------------|
| Statutory Rule List | Table + Filters | Rule Code, Rule Name, Type (BHXH/BHYT/BHTN/PIT), Party (Employee/Employer), Rate, Ceiling, Version Badge, Actions |
| PIT Bracket Configuration | Table + Chart | Bracket table (Bracket #, Min Amount, Max Amount, Rate), Visual bar chart showing progressive rates, Exemption fields, Save button |
| Bracket Visualization | Chart | Bar chart or step chart showing tax rate progression across brackets |

---

### PR-PC-M-004: Pay Calendar Management

| Interaction ID | Type | Name | Purpose | Primary Actor |
|----------------|------|------|---------|---------------|
| I-PC-001 | S | Pay Calendar List Screen | Browse calendars | Payroll Admin |
| I-PC-002 | S | Pay Calendar Create Screen | Create new calendar | Payroll Admin |
| I-PC-003 | S | Pay Calendar Detail Screen | View calendar with periods | Payroll Admin |
| I-PC-004 | S | Pay Period List Screen | View periods within calendar | Payroll Admin |
| I-PC-005 | M | Period Generation Preview Modal | Preview generated periods | Payroll Admin |
| I-PC-006 | M | Period Adjustment Modal | Adjust cut-off/pay date | Payroll Admin |
| I-PC-007 | T | Period Generated Toast | Periods created successfully | System |
| I-PC-008 | T | Sequential Warning | Period dates not sequential | System |

**Screen Layout**:

| Screen | Layout | Components |
|--------|--------|------------|
| Pay Calendar Create | Form | Calendar Code, Calendar Name, Legal Entity dropdown, Pay Frequency dropdown, Fiscal Year, Generate Periods toggle, Preview button |
| Pay Period List | Table | Period #, Period Name, Start Date, End Date, Cut-off Date, Pay Date, Status (OPEN/CLOSED/PAID), Adjustment button |

---

### PR-PA-M-001: Pay Group Management

| Interaction ID | Type | Name | Purpose | Primary Actor |
|----------------|------|------|---------|---------------|
| I-PG-001 | S | Pay Group List Screen | Browse pay groups | Payroll Admin |
| I-PG-002 | S | Pay Group Create Screen | Create new pay group | Payroll Admin |
| I-PG-003 | S | Pay Group Detail Screen | View group with assignments | Payroll Admin |
| I-PG-004 | S | Employee Assignment Screen | View assigned employees | Payroll Admin |
| I-PG-005 | M | Employee Picker Modal | Select employee from CO module | Payroll Admin |
| I-PG-006 | M | Assignment Confirmation Modal | Confirm assignment with reason | Payroll Admin |
| I-PG-007 | P | Assignment History Panel | View assignment history for employee | Payroll Admin |
| I-PG-008 | T | Assignment Conflict Toast | Employee already assigned | System |
| I-PG-009 | T | Success/Error Toast | Operation feedback | System |

**Screen Layout**:

| Screen | Layout | Components |
|--------|--------|------------|
| Pay Group Create | Form | Group Code, Group Name, Pay Profile lookup, Pay Calendar lookup, Description, Save button |
| Employee Assignment Screen | Table + Search | Employee search (calls CO API), Assignment table (Employee Name, Assignment Date, Reason, Remove button) |
| Employee Picker | Modal + Search | Search field, Employee list from CO, Assignment Reason dropdown, Confirm button |

---

### PR-FI-M-001: GL Mapping Configuration

| Interaction ID | Type | Name | Purpose | Primary Actor |
|----------------|------|------|---------|---------------|
| I-GL-001 | S | GL Mapping List Screen | Browse GL mappings | Finance Controller |
| I-GL-002 | S | GL Mapping Create Screen | Create GL mapping | Finance Controller |
| I-GL-003 | P | GL Split Configuration Panel | Configure percentage splits | Finance Controller |
| I-GL-004 | E | Export GL Mappings | Download mappings for finance system | Finance Controller |
| I-GL-005 | T | Percentage Total Warning | Splits must total 100% | System |

---

### PR-FI-M-002: Bank Template Configuration

| Interaction ID | Type | Name | Purpose | Primary Actor |
|----------------|------|------|---------|---------------|
| I-BT-001 | S | Bank Template List Screen | Browse templates | Payroll Admin |
| I-BT-002 | S | Bank Template Create Screen | Create template | Payroll Admin |
| I-BT-003 | P | Field Mapping Configuration Panel | Configure source-to-target mappings | Payroll Admin |
| I-BT-004 | M | Template Preview Modal | Preview generated file | Payroll Admin |
| I-BT-005 | T | Success/Error Toast | Operation feedback | System |

---

### PR-CV-T-001: Configuration Validation

| Interaction ID | Type | Name | Purpose | Primary Actor |
|----------------|------|------|---------|---------------|
| I-CV-001 | S | Validation Result Screen | View validation results | Payroll Admin |
| I-CV-002 | M | Validation Error Modal | Critical errors blocking save | System |
| I-CV-003 | B | Validation Warning Banner | Non-blocking warnings | System |
| I-CV-004 | T | Inline Validation Feedback | Field-level validation errors | System |
| I-CV-005 | B | Validation Status Badge | Pass/Fail indicator | System |

**Interaction Pattern**: Validation is primarily inline and reactive, not a separate screen flow.

---

### PR-CV-T-002: Conflict Detection

| Interaction ID | Type | Name | Purpose | Primary Actor |
|----------------|------|------|---------|---------------|
| I-CD-001 | S | Conflict Queue Screen | View detected conflicts | Payroll Admin |
| I-CD-002 | S | Conflict Detail Screen | View conflict details | Payroll Admin |
| I-CD-003 | M | Resolution Action Modal | Choose resolution (Override/Correction/Ignore) | Payroll Admin |
| I-CD-004 | B | Conflict Badge | Show conflict count in header | System |
| I-CD-005 | T | Conflict Detected Toast | New conflict notification | System |

---

### PR-AT-A-001: Audit Trail Query

| Interaction ID | Type | Name | Purpose | Primary Actor |
|----------------|------|------|---------|---------------|
| I-AT-001 | S | Audit Trail Query Screen | Search and filter audit entries | HR Manager, Compliance Officer |
| I-AT-002 | S | Audit Entry Detail Screen | View entry details with old/new values | HR Manager, Compliance Officer |
| I-AT-003 | E | Export Audit Trail CSV | Download audit entries as CSV | Compliance Officer |
| I-AT-004 | E | Export Audit Trail PDF | Download audit report as PDF | Compliance Officer |
| I-AT-005 | M | Change Detail Modal | View JSON diff of changes | HR Manager, Compliance Officer |
| I-AT-006 | C | AI Audit Query Chat (Future) | Natural language audit query | Compliance Officer |

**Screen Layout**:

| Screen | Layout | Components |
|--------|--------|------------|
| Audit Trail Query | Form + Table | Date range picker, Entity type filter, User filter, Operation filter, Search button, Results table (Entity Type, Entity ID, Entity Name, Operation, Changed By, Changed At, Change Reason), Export buttons |
| Audit Entry Detail | Split View | Left: Entry metadata, Right: Old/New value comparison (JSON diff) |

---

### PR-VM-A-001: Version History Viewer

| Interaction ID | Type | Name | Purpose | Primary Actor |
|----------------|------|------|---------|---------------|
| I-VH-001 | S | Version Timeline Screen | Visual timeline of versions | Payroll Admin, Compliance Officer |
| I-VH-002 | S | Version Detail Screen | View version attributes | Payroll Admin, Compliance Officer |
| I-VH-003 | M | Version Comparison Modal | Compare two versions side-by-side | Payroll Admin, Compliance Officer |
| I-VH-004 | M | Version Query Modal | Query version by effective date | Payroll Admin, Compliance Officer |
| I-VH-005 | E | Export Version History | Download version history | Payroll Admin, Compliance Officer |

**Screen Layout**:

| Screen | Layout | Components |
|--------|--------|------------|
| Version Timeline | Timeline + Details | Horizontal timeline with version markers, Click to view details, Compare button |
| Version Comparison | Split Modal | Left: Version A, Right: Version B, Highlighted changes |

---

### PR-AI-T-001: AI Formula Assistant (Future)

| Interaction ID | Type | Name | Purpose | Primary Actor |
|----------------|------|------|---------|---------------|
| I-AI-FM-001 | C | AI Formula Chat Panel | Natural language formula creation | Payroll Admin |
| I-AI-FM-002 | M | AI Suggestion Dropdown | Formula autocomplete suggestions | Payroll Admin |
| I-AI-FM-003 | T | AI Error Explanation | AI explains formula errors | Payroll Admin |

---

### PR-AI-A-001: AI Audit Query Assistant (Future)

| Interaction ID | Type | Name | Purpose | Primary Actor |
|----------------|------|------|---------|---------------|
| I-AI-AT-001 | C | AI Audit Chat Panel | Natural language audit query | HR Manager, Compliance Officer |
| I-AI-AT-002 | S | AI Query Result Display | Display AI-generated audit insights | HR Manager, Compliance Officer |

---

## Interaction Point Summary

| Feature | Screens | Modals | Panels | Toasts | Badges | Chat | Export | Total |
|---------|:-------:|:------:|:------:|:------:|:------:|:----:|:------:|:-----:|
| PR-PC-M-001 | 5 | 4 | 0 | 2 | 1 | 0 | 0 | 12 |
| PR-PC-M-002 | 4 | 4 | 1 | 1 | 0 | 0 | 0 | 10 |
| PR-PC-M-003 | 2 | 2 | 1 | 1 | 0 | 1 | 0 | 6 |
| PR-SC-M-001 | 5 | 4 | 0 | 2 | 0 | 0 | 0 | 11 |
| PR-PC-M-004 | 4 | 2 | 0 | 2 | 0 | 0 | 0 | 8 |
| PR-PA-M-001 | 4 | 2 | 1 | 2 | 0 | 0 | 0 | 9 |
| PR-FI-M-001 | 2 | 0 | 1 | 1 | 0 | 0 | 1 | 4 |
| PR-FI-M-002 | 2 | 1 | 1 | 1 | 0 | 0 | 0 | 4 |
| PR-CV-T-001 | 1 | 1 | 0 | 1 | 2 | 0 | 0 | 5 |
| PR-CV-T-002 | 2 | 1 | 0 | 1 | 1 | 0 | 0 | 4 |
| PR-AT-A-001 | 2 | 1 | 0 | 0 | 0 | 1 | 2 | 6 |
| PR-VM-A-001 | 2 | 2 | 0 | 0 | 0 | 0 | 1 | 5 |
| PR-AI-T-001 | 0 | 1 | 1 | 1 | 0 | 1 | 0 | 3 |
| PR-AI-A-001 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 2 |
| **Total** | **32** | **23** | **5** | **14** | **4** | **3** | **4** | **83** |

---

## AI-Native Interaction Patterns

### Pattern 1: AI-Assisted Configuration

| Feature | AI Capability | Trigger | User Action |
|---------|--------------|---------|-------------|
| Formula Builder | Formula suggestions | User starts typing | Accept suggestion or continue |
| Formula Builder | Error explanation | Validation fails | View AI explanation |
| Formula Builder | Template recommendation | New formula | Select from AI-recommended templates |

### Pattern 2: AI-Assisted Query

| Feature | AI Capability | Trigger | User Action |
|---------|--------------|---------|-------------|
| Audit Trail | Natural language query | User types question | View AI-generated results |
| Version History | Summarize changes | User asks "What changed?" | View AI summary |

### Pattern 3: Proactive AI Notifications

| Feature | AI Capability | Trigger | User Action |
|---------|--------------|---------|-------------|
| Statutory Rules | Rate change alert | Government rate update detected | Review and update |
| Validation | Anomaly detection | Unusual pattern detected | Investigate |

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Experience Architect Agent