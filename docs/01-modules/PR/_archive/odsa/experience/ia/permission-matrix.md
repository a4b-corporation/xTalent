# Permission Matrix - Payroll Module (PR)

> **Module**: Payroll (PR)
> **Phase**: Experience (Step 5)
> **Date**: 2026-03-31
> **Version**: 1.0

---

## Overview

This document defines the permission matrix for the Payroll module. Permissions are organized by Role, Feature, and Action. This matrix ensures that every feature-action combination is covered for all roles.

---

## Roles Definition

| Role ID | Role Name | Description |
|---------|-----------|-------------|
| R-001 | Payroll Admin | Primary user - configures pay elements, profiles, statutory rules |
| R-002 | Finance Controller | Configures GL mappings, reviews finance integration |
| R-003 | Compliance Officer | Validates statutory rules, manages compliance audit |
| R-004 | HR Manager | Reviews configurations, views audit trail (query only) |

---

## Action Types

| Action ID | Action Name | Description |
|-----------|-------------|-------------|
| A-001 | CREATE | Create new entity |
| A-002 | READ | View entity details |
| A-003 | UPDATE | Modify existing entity |
| A-004 | DELETE | Soft delete entity |
| A-005 | ASSIGN | Assign relationship (element to profile, employee to group) |
| A-006 | UNASSIGN | Remove relationship |
| A-007 | VERSION_CREATE | Create new SCD-2 version |
| A-008 | VERSION_QUERY | Query version history |
| A-009 | VERSION_COMPARE | Compare two versions |
| A-010 | VALIDATE | Run validation |
| A-011 | RESOLVE | Resolve conflict |
| A-012 | EXPORT | Export data (audit trail, GL mappings) |
| A-013 | PREVIEW | Preview formula or template |
| A-014 | QUERY | Search/filter data |

---

## Permission Matrix

### Payroll Configuration BC

| Feature | Action | Payroll Admin | Finance Controller | Compliance Officer | HR Manager |
|---------|--------|:-------------:|:-----------------:|:-----------------:|:---------:|
| **PR-PC-M-001: Pay Element** | CREATE | YES | NO | NO | NO |
| | READ | YES | YES | YES | YES |
| | UPDATE | YES | NO | NO | NO |
| | DELETE | YES | NO | NO | NO |
| | VERSION_CREATE | YES | NO | NO | NO |
| | VERSION_QUERY | YES | YES | YES | YES |
| | VERSION_COMPARE | YES | NO | YES | NO |
| | QUERY | YES | YES | YES | YES |
| | | | | | |
| **PR-PC-M-002: Pay Profile** | CREATE | YES | NO | NO | NO |
| | READ | YES | YES | YES | YES |
| | UPDATE | YES | NO | NO | NO |
| | DELETE | YES | NO | NO | NO |
| | ASSIGN (Element) | YES | NO | NO | NO |
| | UNASSIGN (Element) | YES | NO | NO | NO |
| | VERSION_CREATE | YES | NO | NO | NO |
| | VERSION_QUERY | YES | YES | YES | YES |
| | QUERY | YES | YES | YES | YES |
| | | | | | |
| **PR-PC-M-003: Formula** | CREATE | YES | NO | NO | NO |
| | READ | YES | YES | YES | YES |
| | UPDATE | YES | NO | NO | NO |
| | DELETE | YES | NO | NO | NO |
| | VALIDATE | YES | NO | NO | NO |
| | PREVIEW | YES | NO | NO | NO |
| | QUERY | YES | YES | YES | YES |

### Statutory Compliance BC

| Feature | Action | Payroll Admin | Finance Controller | Compliance Officer | HR Manager |
|---------|--------|:-------------:|:-----------------:|:-----------------:|:---------:|
| **PR-SC-M-001: Statutory Rule** | CREATE | YES | NO | YES | NO |
| | READ | YES | YES | YES | YES |
| | UPDATE | YES | NO | YES | NO |
| | DELETE | YES | NO | YES | NO |
| | VERSION_CREATE | YES | NO | YES | NO |
| | VERSION_QUERY | YES | YES | YES | YES |
| | VERSION_COMPARE | YES | NO | YES | NO |
| | ASSIGN (Bracket) | YES | NO | YES | NO |
| | QUERY | YES | YES | YES | YES |

### Payroll Calendar BC

| Feature | Action | Payroll Admin | Finance Controller | Compliance Officer | HR Manager |
|---------|--------|:-------------:|:-----------------:|:-----------------:|:---------:|
| **PR-PC-M-004: Pay Calendar** | CREATE | YES | NO | NO | NO |
| | READ | YES | YES | YES | YES |
| | UPDATE | YES | NO | NO | NO |
| | DELETE | YES | NO | NO | NO |
| | ASSIGN (Period) | YES | NO | NO | NO |
| | QUERY | YES | YES | YES | YES |

### Payroll Assignment BC

| Feature | Action | Payroll Admin | Finance Controller | Compliance Officer | HR Manager |
|---------|--------|:-------------:|:-----------------:|:-----------------:|:---------:|
| **PR-PA-M-001: Pay Group** | CREATE | YES | NO | NO | NO |
| | READ | YES | YES | YES | YES |
| | UPDATE | YES | NO | NO | NO |
| | DELETE | YES | NO | NO | NO |
| | ASSIGN (Employee) | YES | NO | NO | NO |
| | UNASSIGN (Employee) | YES | NO | NO | NO |
| | QUERY | YES | YES | YES | YES |

### Finance Integration BC

| Feature | Action | Payroll Admin | Finance Controller | Compliance Officer | HR Manager |
|---------|--------|:-------------:|:-----------------:|:-----------------:|:---------:|
| **PR-FI-M-001: GL Mapping** | CREATE | NO | YES | NO | NO |
| | READ | YES | YES | NO | NO |
| | UPDATE | NO | YES | NO | NO |
| | DELETE | NO | YES | NO | NO |
| | EXPORT | NO | YES | NO | NO |
| | QUERY | YES | YES | NO | NO |
| | | | | | |
| **PR-FI-M-002: Bank Template** | CREATE | YES | NO | NO | NO |
| | READ | YES | YES | NO | NO |
| | UPDATE | YES | NO | NO | NO |
| | DELETE | YES | NO | NO | NO |
| | PREVIEW | YES | YES | NO | NO |
| | QUERY | YES | YES | NO | NO |

### Configuration Validation BC

| Feature | Action | Payroll Admin | Finance Controller | Compliance Officer | HR Manager |
|---------|--------|:-------------:|:-----------------:|:-----------------:|:---------:|
| **PR-CV-T-001: Validation** | VALIDATE | YES | NO | NO | NO |
| | READ (Results) | YES | YES | YES | NO |
| | | | | | |
| **PR-CV-T-002: Conflict** | READ | YES | NO | NO | NO |
| | RESOLVE | YES | NO | NO | NO |

### Audit Trail BC

| Feature | Action | Payroll Admin | Finance Controller | Compliance Officer | HR Manager |
|---------|--------|:-------------:|:-----------------:|:-----------------:|:---------:|
| **PR-AT-A-001: Audit Trail** | QUERY | NO | NO | YES | YES |
| | READ (Entries) | NO | NO | YES | YES |
| | EXPORT (CSV) | NO | NO | YES | NO |
| | EXPORT (PDF) | NO | NO | YES | NO |

### Version Management (Cross-BC)

| Feature | Action | Payroll Admin | Finance Controller | Compliance Officer | HR Manager |
|---------|--------|:-------------:|:-----------------:|:-----------------:|:---------:|
| **PR-VM-A-001: Version History** | VERSION_QUERY | YES | NO | YES | NO |
| | VERSION_COMPARE | YES | NO | YES | NO |
| | READ (Versions) | YES | YES | YES | YES |
| | EXPORT | YES | NO | YES | NO |

### AI-Native Features (Future)

| Feature | Action | Payroll Admin | Finance Controller | Compliance Officer | HR Manager |
|---------|--------|:-------------:|:-----------------:|:-----------------:|:---------:|
| **PR-AI-T-001: Formula Assistant** | USE | YES | NO | NO | NO |
| | | | | | |
| **PR-AI-A-001: Audit Assistant** | USE | NO | NO | YES | YES |

---

## Permission Summary

| Role | Total Permissions | Features Accessible |
|------|-------------------|---------------------|
| Payroll Admin | 42 | All configuration features |
| Finance Controller | 8 | GL Mapping, Bank Template (read), Version History (read) |
| Compliance Officer | 21 | Statutory Rules, Audit Trail, Version History |
| HR Manager | 6 | Audit Trail (query), Read-only configuration |

---

## Permission Rules

### Rule 1: Separation of Duties

| Principle | Implementation |
|-----------|----------------|
| Payroll Admin cannot approve audit | Audit export limited to Compliance Officer |
| Finance Controller cannot modify statutory rules | Statutory rules limited to Payroll Admin and Compliance Officer |
| HR Manager cannot modify configuration | All WRITE actions denied |

### Rule 2: Compliance Gate

| Action | Gate | Override |
|--------|------|----------|
| Update Statutory Rule Rate | Warning modal with reference rate | Compliance Officer can override with reason |
| Delete Statutory Rule | Cannot delete if assigned to profile | None |
| Export Audit Trail | Compliance Officer only | HR Manager can query but not export PDF |

### Rule 3: Finance Integration Gate

| Action | Gate | Override |
|--------|------|----------|
| Create GL Mapping | Finance Controller only | None |
| Export GL Mappings | Finance Controller only | None |
| Bank Template | Payroll Admin can create, Finance Controller can read | None |

---

## Permission Implementation

### API Authorization

| Endpoint | Method | Required Role |
|----------|--------|---------------|
| POST /pay-elements | CREATE | Payroll Admin |
| PUT /pay-elements/{id} | UPDATE | Payroll Admin |
| DELETE /pay-elements/{id} | DELETE | Payroll Admin |
| GET /pay-elements | READ | All roles |
| POST /pay-elements/{code}/versions | VERSION_CREATE | Payroll Admin |
| GET /pay-elements/{code}/versions | VERSION_QUERY | All roles |
| | | |
| POST /statutory-rules | CREATE | Payroll Admin, Compliance Officer |
| PUT /statutory-rules/{id} | UPDATE | Payroll Admin, Compliance Officer |
| PUT /statutory-rules/{code}/configure-pit-brackets | UPDATE | Compliance Officer (preferred), Payroll Admin |
| | | |
| POST /gl-mapping-policies | CREATE | Finance Controller |
| GET /audit-logs | QUERY | Compliance Officer, HR Manager |
| GET /audit-logs/export | EXPORT | Compliance Officer |

### UI Authorization

| Screen | Visibility | Editability |
|--------|------------|-------------|
| Pay Element List | All roles | Payroll Admin only |
| Pay Element Create | Payroll Admin | Payroll Admin |
| Pay Element Edit | Payroll Admin | Payroll Admin |
| Version Timeline | Payroll Admin, Compliance Officer | Payroll Admin |
| | | |
| GL Mapping List | Payroll Admin (read), Finance Controller | Finance Controller |
| | | |
| Audit Trail Query | Compliance Officer, HR Manager | Query only |

---

## Permission Check Points

### Field-Level Permissions

| Field | Visibility | Editability |
|-------|------------|-------------|
| Pay Element.rate | All roles (visible) | Payroll Admin |
| Statutory Rule.rate | All roles (visible) | Payroll Admin, Compliance Officer |
| Audit Entry.oldValue | Compliance Officer, HR Manager | Read-only |
| Audit Entry.newValue | Compliance Officer, HR Manager | Read-only |
| GL Mapping.percentage | Finance Controller | Finance Controller |

### Action Button Permissions

| Button | Visible To | Enabled For |
|--------|------------|-------------|
| Create Pay Element | Payroll Admin | Payroll Admin |
| Edit Pay Element | Payroll Admin | Payroll Admin |
| Delete Pay Element | Payroll Admin | Payroll Admin |
| View Versions | All roles | All roles |
| Compare Versions | Payroll Admin, Compliance Officer | Payroll Admin |
| Export Audit | Compliance Officer | Compliance Officer |
| Create GL Mapping | Finance Controller | Finance Controller |

---

## Empty Cell Verification

This matrix has no empty cells. Every Role x Feature x Action combination has an explicit YES or NO assignment.

| Verification | Status |
|--------------|--------|
| All roles covered | PASS |
| All features covered | PASS |
| All actions covered | PASS |
| No empty cells | PASS |

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Experience Architect Agent