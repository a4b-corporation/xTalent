# Organization Structure API Catalog

> **Module**: Core HR - Organization Structure Management  
> **Version**: 1.0.0  
> **Status**: Draft  
> **Last Updated**: 2026-01-29  
> **Reference**: Oracle HCM, SAP SuccessFactors, Workday patterns

---

## Overview

This document catalogs all necessary APIs for the **Organization Structure** entities. It covers legal structure, organizational hierarchy, and signing authority.

### Organization Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│  LEGAL LAYER (Tax/Compliance Boundary)                             │
│  ┌──────────────────┐                                               │
│  │   LegalEntity    │ ← Company registration, tax ID, BHXH code    │
│  │   (Legal Employer)│                                              │
│  └────────┬─────────┘                                               │
│           │ hasRepresentatives                                      │
│           ▼                                                         │
│  ┌──────────────────┐                                               │
│  │LegalRepresentative│ ← Contract signing authority                │
│  └──────────────────┘                                               │
└─────────────────────────────────────────────────────────────────────┘
                           │
                           │ hasDepartments
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│  ORGANIZATIONAL LAYER (Reporting Structure)                        │
│  ┌──────────────────┐                                               │
│  │   BusinessUnit   │ ← Dynamic hierarchy (BU→Division→Dept→Team) │
│  │   (N-level)      │                                               │
│  └──────────────────┘                                               │
│           │                                                         │
│           ├── hasPositions → Position                               │
│           └── hasEmployees → Employee (via Assignment)              │
└─────────────────────────────────────────────────────────────────────┘
```

### Entities Covered

| Entity | Description | File |
|--------|-------------|------|
| **LegalEntity** | Legal company with tax/compliance identity | LegalEntity.onto.md |
| **BusinessUnit** | Organizational hierarchy (dynamic N-level) | BusinessUnit.onto.md |
| **LegalRepresentative** | Authorized person for contract signing | LegalRepresentative.onto.md |

---

## 1. LegalEntity APIs

> **Entity**: `LegalEntity`  
> **Domain**: Legal/Compliance  
> **Base Path**: `/api/v1/legal-entities`

### 1.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/legal-entities` | Create legal entity | Super Admin |
| `GET` | `/legal-entities/{id}` | Get by ID | Read |
| `GET` | `/legal-entities` | List (paginated) | Read |
| `PATCH` | `/legal-entities/{id}` | Update | Admin |
| `DELETE` | `/legal-entities/{id}` | Soft delete | Super Admin |

### 1.2 Business Actions - Lifecycle

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/legal-entities/{id}/actions/activate` | Activate pending entity | Registration complete |
| `POST` | `/legal-entities/{id}/actions/deactivate` | Deactivate (suspend) | Admin |
| `POST` | `/legal-entities/{id}/actions/reactivate` | Reactivate from suspension | Admin |
| `POST` | `/legal-entities/{id}/actions/dissolve` | Dissolve (close company) | Legal closure |
| `POST` | `/legal-entities/{id}/actions/merge` | Merge into another entity | M&A |

### 1.3 Business Actions - Registration & Compliance

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/legal-entities/{id}/actions/updateRegistration` | Update business registration | Legal change |
| `POST` | `/legal-entities/{id}/actions/updateTaxInfo` | Update tax IDs (VAT, Federal) | Tax change |
| `POST` | `/legal-entities/{id}/actions/updateVnCompliance` | Update VN-specific (BHXH, MKS) | VN compliance |
| `POST` | `/legal-entities/{id}/actions/changeParent` | Change parent entity (group structure) | Restructuring |
| `POST` | `/legal-entities/{id}/actions/validateCompliance` | Validate compliance setup | Pre-activation |

### 1.4 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/legal-entities/{id}/employees` | Get employees in LE | `status`, `asOfDate` |
| `GET` | `/legal-entities/{id}/business-units` | Get departments/BUs | `type`, `isActive` |
| `GET` | `/legal-entities/{id}/representatives` | Get legal representatives | `type`, `isActive` |
| `GET` | `/legal-entities/{id}/work-locations` | Get work locations | `type` |
| `GET` | `/legal-entities/{id}/contracts` | Get labor contracts | `status` |
| `GET` | `/legal-entities/query/by-country/{countryCode}` | Get by country | - |
| `GET` | `/legal-entities/query/legal-employers` | Get where isLegalEmployer=true | - |
| `GET` | `/legal-entities/tree` | Get hierarchy tree (parent/child) | `depth` |
| `GET` | `/legal-entities/search` | Search by name/code/taxId | `q` |

### 1.5 VN-Specific Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/legal-entities/{id}/bhxh-info` | Get social insurance info | - |
| `POST` | `/legal-entities/{id}/actions/registerBhxh` | Register BHXH code | VN |
| `POST` | `/legal-entities/{id}/actions/updateMst` | Update tax code (MST) | VN |

---

## 2. BusinessUnit APIs

> **Entity**: `BusinessUnit`  
> **Domain**: Organization Structure  
> **Base Path**: `/api/v1/business-units`

### 2.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/business-units` | Create business unit | HR Admin |
| `GET` | `/business-units/{id}` | Get by ID | Read |
| `GET` | `/business-units` | List (paginated) | Read |
| `PATCH` | `/business-units/{id}` | Update | HR Admin |
| `DELETE` | `/business-units/{id}` | Soft delete | HR Admin |

### 2.2 Business Actions - Lifecycle

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/business-units/{id}/actions/activate` | Activate planned BU | Setup complete |
| `POST` | `/business-units/{id}/actions/deactivate` | Deactivate (suspend) | Admin |
| `POST` | `/business-units/{id}/actions/reactivate` | Reactivate | Admin |
| `POST` | `/business-units/{id}/actions/close` | Permanently close | Dissolution |

### 2.3 Business Actions - Hierarchy Management

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/business-units/{id}/actions/moveToParent` | Reparent to new parent | Reorganization |
| `POST` | `/business-units/{id}/actions/merge` | Merge into another BU | Consolidation |
| `POST` | `/business-units/{id}/actions/split` | Split into child BUs | Growth |
| `POST` | `/business-units/{id}/actions/recalculateHierarchyPath` | Recalculate path for tree | After move |

### 2.4 Business Actions - Personnel & Resources

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/business-units/{id}/actions/assignManager` | Assign/change manager | Admin |
| `POST` | `/business-units/{id}/actions/removeManager` | Remove manager | Admin |
| `POST` | `/business-units/{id}/actions/transferEmployees` | Transfer all employees to another BU | Closure/Merge |
| `POST` | `/business-units/{id}/actions/updateCostCenter` | Update cost center | Finance |
| `POST` | `/business-units/{id}/actions/setProfitCenter` | Set as P&L center | Finance |

### 2.5 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/business-units/{id}/children` | Get child BUs | `recursive`, `isActive` |
| `GET` | `/business-units/{id}/ancestors` | Get path to root | - |
| `GET` | `/business-units/{id}/descendants` | Get all descendants | `maxDepth` |
| `GET` | `/business-units/{id}/positions` | Get positions in BU | `isActive` |
| `GET` | `/business-units/{id}/employees` | Get employees | `status`, `asOfDate` |
| `GET` | `/business-units/{id}/headcount` | Get headcount summary | `asOfDate` |
| `GET` | `/business-units/{id}/manager` | Get current manager | - |
| `GET` | `/business-units/tree/{legalEntityId}` | Get org tree for LE | `depth`, `type` |
| `GET` | `/business-units/query/by-legal-entity/{leId}` | Get by LE | `type`, `isActive` |
| `GET` | `/business-units/query/by-type/{type}` | Get by unit type | `legalEntityId` |
| `GET` | `/business-units/query/profit-centers` | Get P&L centers only | `legalEntityId` |
| `GET` | `/business-units/query/without-manager` | Get BUs without manager | - |
| `GET` | `/business-units/search` | Search by name/code | `q`, `legalEntityId` |

---

## 3. LegalRepresentative APIs

> **Entity**: `LegalRepresentative`  
> **Domain**: Compliance/Authorization  
> **Base Path**: `/api/v1/legal-representatives`

### 3.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/legal-representatives` | Create representative | Admin |
| `GET` | `/legal-representatives/{id}` | Get by ID | Read |
| `GET` | `/legal-representatives` | List (paginated) | Read |
| `PATCH` | `/legal-representatives/{id}` | Update | Admin |
| `DELETE` | `/legal-representatives/{id}` | Soft delete | Admin |

### 3.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/legal-representatives/{id}/actions/expire` | Mark as expired (end date reached) | System/Admin |
| `POST` | `/legal-representatives/{id}/actions/revoke` | Revoke before expiry | Resignation/Termination |
| `POST` | `/legal-representatives/{id}/actions/extend` | Extend appointment period | Admin |
| `POST` | `/legal-representatives/{id}/actions/transfer` | Transfer authority to another person | Succession |
| `POST` | `/legal-representatives/{id}/actions/uploadAuthorization` | Upload authorization document | Admin |

### 3.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/legal-representatives/query/by-legal-entity/{leId}` | Get by LE | `isActive`, `type` |
| `GET` | `/legal-representatives/query/active/{leId}` | Get active reps for LE | - |
| `GET` | `/legal-representatives/query/by-type/{type}` | Get by rep type | `legalEntityId` |
| `GET` | `/legal-representatives/query/contract-signers/{leId}` | Get who can sign contracts | - |
| `GET` | `/legal-representatives/query/expiring-soon` | Get expiring in N days | `days`, `legalEntityId` |
| `GET` | `/legal-representatives/{id}/authorization-document` | Get authorization document | - |

---

## Summary

### API Count by Entity

| Entity | CRUD | Actions | Query | Total |
|--------|------|---------|-------|-------|
| LegalEntity | 5 | 10 | 12 | **27** |
| BusinessUnit | 5 | 13 | 13 | **31** |
| LegalRepresentative | 5 | 5 | 6 | **16** |
| **Total** | **15** | **28** | **31** | **74** |

### Priority Matrix

| Priority | APIs | Description |
|----------|------|-------------|
| **P0** | 15 | CRUD - MVP |
| **P1** | 12 | Core Lifecycle (activate, deactivate, close) |
| **P2** | 8 | Hierarchy Operations (move, merge, split) |
| **P3** | 8 | Personnel Management (assignManager, transfer) |
| **P4** | 31 | Query & Navigation |

### Key Use Cases

| Use Case | APIs Involved |
|----------|---------------|
| **Setup New Company** | POST /legal-entities → activate → POST /legal-representatives |
| **Create Org Structure** | POST /business-units (multiple) → tree structure |
| **Reorganization** | moveToParent → recalculateHierarchyPath |
| **M&A Scenario** | merge legal-entities → transferEmployees |
| **Close Department** | transferEmployees → close business-unit |
| **Contract Signing** | GET /legal-representatives/query/contract-signers |

---

## Appendix: VN Compliance

### Legal Entity VN Requirements

| Field | VN Name | Description |
|-------|---------|-------------|
| taxIdentificationNumber | Mã số thuế (MST) | Tax code (required) |
| socialInsuranceCode | Mã đơn vị BHXH | Social insurance code |
| healthInsuranceCode | Mã đơn vị BHYT | Health insurance code |
| unionCode | Mã công đoàn | Trade union code |

### Representative Types (VN)

| Type | VN Name | Can Sign Contract? |
|------|---------|-------------------|
| LEGAL_REP | Người đại diện pháp luật | ✓ Yes |
| AUTHORIZED_REP | Người được ủy quyền | ✓ Yes (with authorization doc) |
| CEO | Giám đốc | ✓ If legal rep |
| CHAIRMAN | Chủ tịch HĐQT | ✓ If legal rep |

---

*Document Status: DRAFT*  
*References: [[LegalEntity]], [[BusinessUnit]], [[LegalRepresentative]]*
