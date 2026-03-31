# Menu Map - Payroll Module (PR)

> **Module**: Payroll (PR)
> **Phase**: Experience (Step 5)
> **Date**: 2026-03-31
> **Version**: 1.0

---

## Menu Hierarchy

The menu structure follows a task-based organization, grouping features by user workflow rather than by entity. This ensures users navigate by what they need to do, not by what data exists.

---

## Top-Level Menu Structure

```
Payroll Configuration
├── Elements & Profiles
│   ├── Pay Elements
│   ├── Pay Profiles
│   └── Formula Builder
│
├── Statutory Compliance
│   ├── Statutory Rules
│   └── PIT Configuration
│
├── Calendar & Groups
│   ├── Pay Calendars
│   ├── Pay Groups
│   └── Employee Assignment
│
├── Finance Integration
│   ├── GL Mappings
│   ├── Bank Templates
│
├── Validation & Audit
│   ├── Configuration Validation
│   ├── Conflict Queue
│   ├── Audit Trail
│   └── Version History
│
└── AI Assistants (Future)
    ├── Formula Assistant
    └── Audit Query Assistant
```

---

## Menu Items with Role Visibility

### Level 1: Elements & Profiles

| Menu Item | Feature ID | Roles | Description |
|-----------|------------|-------|-------------|
| Pay Elements | PR-PC-M-001 | Payroll Admin | Manage pay elements with classification and versioning |
| Pay Profiles | PR-PC-M-002 | Payroll Admin | Manage pay profiles with element assignments |
| Formula Builder | PR-PC-M-003 | Payroll Admin | Create and validate calculation formulas |

### Level 1: Statutory Compliance

| Menu Item | Feature ID | Roles | Description |
|-----------|------------|-------|-------------|
| Statutory Rules | PR-SC-M-001 | Payroll Admin, Compliance Officer | Manage BHXH, BHYT, BHTN, PIT rules |
| PIT Configuration | PR-SC-M-001 | Compliance Officer | Configure PIT brackets and exemptions |

### Level 1: Calendar & Groups

| Menu Item | Feature ID | Roles | Description |
|-----------|------------|-------|-------------|
| Pay Calendars | PR-PC-M-004 | Payroll Admin | Manage pay calendars and periods |
| Pay Groups | PR-PA-M-001 | Payroll Admin | Manage pay groups |
| Employee Assignment | PR-PA-M-001 | Payroll Admin | Assign employees to pay groups |

### Level 1: Finance Integration

| Menu Item | Feature ID | Roles | Description |
|-----------|------------|-------|-------------|
| GL Mappings | PR-FI-M-001 | Finance Controller | Configure GL account mappings |
| Bank Templates | PR-FI-M-002 | Payroll Admin | Configure bank file templates |

### Level 1: Validation & Audit

| Menu Item | Feature ID | Roles | Description |
|-----------|------------|-------|-------------|
| Configuration Validation | PR-CV-T-001 | Payroll Admin | View validation results |
| Conflict Queue | PR-CV-T-002 | Payroll Admin | Review and resolve conflicts |
| Audit Trail | PR-AT-A-001 | HR Manager, Compliance Officer | Query configuration audit trail |
| Version History | PR-VM-A-001 | Payroll Admin, Compliance Officer | View version history for SCD-2 entities |

### Level 1: AI Assistants (Future)

| Menu Item | Feature ID | Roles | Description |
|-----------|------------|-------|-------------|
| Formula Assistant | PR-AI-T-001 | Payroll Admin | AI-powered formula creation |
| Audit Query Assistant | PR-AI-A-001 | HR Manager, Compliance Officer | Natural language audit query |

---

## Role-Based Menu Visibility Matrix

| Menu Item | Payroll Admin | Finance Controller | Compliance Officer | HR Manager |
|-----------|:-------------:|:-----------------:|:-----------------:|:---------:|
| Pay Elements | YES | NO | NO | NO |
| Pay Profiles | YES | NO | NO | NO |
| Formula Builder | YES | NO | NO | NO |
| Statutory Rules | YES | NO | YES | NO |
| PIT Configuration | NO | NO | YES | NO |
| Pay Calendars | YES | NO | NO | NO |
| Pay Groups | YES | NO | NO | NO |
| Employee Assignment | YES | NO | NO | NO |
| GL Mappings | NO | YES | NO | NO |
| Bank Templates | YES | NO | NO | NO |
| Configuration Validation | YES | NO | NO | NO |
| Conflict Queue | YES | NO | NO | NO |
| Audit Trail | NO | NO | YES | YES |
| Version History | YES | NO | YES | NO |
| AI Formula Assistant | YES | NO | NO | NO |
| AI Audit Assistant | NO | NO | YES | YES |

---

## Menu Icons and Labels

| Menu Item | Icon | Label | Tooltip |
|-----------|------|-------|---------|
| Pay Elements | dollar-sign | Pay Elements | Manage pay elements and their classifications |
| Pay Profiles | layers | Pay Profiles | Configure pay profiles with element assignments |
| Formula Builder | calculator | Formula Builder | Create and validate calculation formulas |
| Statutory Rules | shield | Statutory Rules | Configure BHXH, BHYT, BHTN, PIT rules |
| PIT Configuration | chart-bar | PIT Configuration | Set up progressive tax brackets |
| Pay Calendars | calendar | Pay Calendars | Define pay periods and cut-off dates |
| Pay Groups | users | Pay Groups | Create pay groups for employee assignment |
| Employee Assignment | user-plus | Employee Assignment | Assign employees to pay groups |
| GL Mappings | book | GL Mappings | Map pay elements to GL accounts |
| Bank Templates | file-text | Bank Templates | Configure bank file formats |
| Configuration Validation | check-circle | Validation | View configuration validation results |
| Conflict Queue | alert-triangle | Conflicts | Review and resolve configuration conflicts |
| Audit Trail | file-search | Audit Trail | Query configuration change history |
| Version History | git-branch | Versions | View version history for entities |

---

## Quick Actions Bar

In addition to the menu, users have quick actions accessible from the header:

| Quick Action | Roles | Action |
|--------------|-------|--------|
| Create Pay Element | Payroll Admin | Opens create modal |
| Create Pay Profile | Payroll Admin | Opens create modal |
| Validate Configuration | Payroll Admin | Runs full validation |
| View Audit Trail | HR Manager, Compliance Officer | Opens audit search |
| Conflict Badge | Payroll Admin | Shows conflict count, opens queue |

---

## Context Menu Actions

Right-click or action menus available on list views:

### Pay Element List Actions

| Action | Description | Roles |
|--------|-------------|-------|
| View | Open element detail | All visible roles |
| Edit | Update element (creates version) | Payroll Admin |
| View Versions | Open version timeline | Payroll Admin |
| Delete | Soft delete element | Payroll Admin |
| Assign to Profile | Quick assign to selected profile | Payroll Admin |

### Pay Profile List Actions

| Action | Description | Roles |
|--------|-------------|-------|
| View | Open profile detail | Payroll Admin |
| Edit | Update profile | Payroll Admin |
| View Versions | Open version timeline | Payroll Admin |
| Assign Elements | Open assignment panel | Payroll Admin |
| Create Pay Group | Create group from profile | Payroll Admin |

---

## Breadcrumb Navigation

All screens follow a consistent breadcrumb pattern:

```
Payroll Configuration > [Section] > [Entity] > [Action]
```

**Examples**:
- Payroll Configuration > Elements & Profiles > Pay Elements
- Payroll Configuration > Elements & Profiles > Pay Elements > SALARY_BASIC
- Payroll Configuration > Elements & Profiles > Pay Elements > SALARY_BASIC > Version 2

---

## Mobile Menu Considerations

For mobile devices, the menu collapses to:

1. **Primary Navigation**: Bottom tab bar with 4 items
   - Home (dashboard)
   - Elements (Pay Elements, Profiles)
   - Compliance (Statutory Rules)
   - More (expanded menu)

2. **Secondary Navigation**: Side drawer for remaining items

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Experience Architect Agent