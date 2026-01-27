# Core HR API Catalog

> **Module**: Core HR (CO)  
> **Version**: 1.0.0  
> **Status**: Draft  
> **Last Updated**: 2026-01-27  
> **Reference**: Oracle HCM, SAP SuccessFactors, Workday patterns

---

## Overview

This document catalogs all necessary APIs for the Core HR ontology entities. It follows **RESTful** conventions with dedicated **action endpoints** for business operations.

### API Design Patterns

| Pattern | Format | Example |
|---------|--------|---------|
| **CRUD** | `METHOD /entities/{id}` | `GET /workers/123` |
| **Action** | `POST /entities/{id}/actions/{name}` | `POST /workers/123/actions/terminate` |
| **Query** | `GET /entities/query/{name}` | `GET /contracts/query/expiring-soon` |
| **Batch** | `POST /entities/batch` | Bulk operations |
| **Effective-Dated** | `?asOfDate=YYYY-MM-DD` | Historical queries |

### Common Response Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Validation Error |
| 404 | Not Found |
| 409 | Conflict (e.g., duplicate) |
| 422 | Business Rule Violation |

---

## 1. Worker APIs

> **Entity**: `Worker`  
> **Domain**: Person Identity  
> **Base Path**: `/api/v1/workers`

### 1.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/workers` | Create new worker (person) | HR Admin |
| `GET` | `/workers/{id}` | Get worker by ID | Read |
| `GET` | `/workers` | List workers (paginated) | Read |
| `PATCH` | `/workers/{id}` | Update worker data | HR Admin |
| `DELETE` | `/workers/{id}` | Soft delete worker | HR Admin |

### 1.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/workers/{id}/actions/merge` | Merge duplicate worker records | Admin action |
| `POST` | `/workers/{id}/actions/transferData` | Transfer data to another worker (before merge) | Pre-merge |
| `POST` | `/workers/{id}/actions/updatePersonalInfo` | Atomic personal info update with validation | Self-service |
| `POST` | `/workers/{id}/actions/updateLegalName` | Legal name change (creates history) | Life event |
| `POST` | `/workers/{id}/actions/recordDeceased` | Mark worker as deceased | Admin |
| `POST` | `/workers/{id}/actions/anonymize` | GDPR anonymization (redact PII) | Privacy request |

### 1.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/workers/search` | Full-text search | `q`, `fields[]` |
| `GET` | `/workers/query/duplicates` | Find potential duplicates | `threshold` |
| `GET` | `/workers/{id}/employments` | Get all employment records | - |
| `GET` | `/workers/{id}/contacts` | Get all contacts | - |
| `GET` | `/workers/{id}/addresses` | Get all addresses | - |
| `GET` | `/workers/{id}/documents` | Get all documents | - |

---

## 2. Employee APIs

> **Entity**: `Employee`  
> **Domain**: Employment in Legal Entity  
> **Base Path**: `/api/v1/employees`

### 2.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/employees` | Create employee (usually via hire flow) | HR Admin |
| `GET` | `/employees/{id}` | Get employee by ID | Read |
| `GET` | `/employees` | List employees (paginated, filtered) | Read |
| `PATCH` | `/employees/{id}` | Update employee data | HR Admin |
| `DELETE` | `/employees/{id}` | Soft delete (rare) | Super Admin |

### 2.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/employees/{id}/actions/hire` | Full hire process (creates WR + Assignment) | Onboarding |
| `POST` | `/employees/{id}/actions/terminate` | Terminate employee (full offboarding) | Offboarding |
| `POST` | `/employees/{id}/actions/suspend` | Suspend employee | Disciplinary |
| `POST` | `/employees/{id}/actions/reactivate` | Reactivate from suspension | Admin |
| `POST` | `/employees/{id}/actions/startLeave` | Start extended leave (LOA) | Leave management |
| `POST` | `/employees/{id}/actions/endLeave` | End leave, return to work | Leave management |
| `POST` | `/employees/{id}/actions/retire` | Process retirement | Lifecycle |
| `POST` | `/employees/{id}/actions/transferLegalEntity` | Transfer to another legal entity | Reorganization |
| `POST` | `/employees/{id}/actions/changeManager` | Change reporting manager | Org change |
| `POST` | `/employees/{id}/actions/updateEmployeeCode` | Change employee code | Admin |
| `POST` | `/employees/{id}/actions/rehire` | Rehire former employee | Recruiting |

### 2.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/employees/{id}/history` | Employment history timeline | `from`, `to` |
| `GET` | `/employees/{id}/assignments` | All assignments (current + historical) | `isCurrent` |
| `GET` | `/employees/{id}/contracts` | All labor contracts | `status` |
| `GET` | `/employees/{id}/directReports` | Direct reports list | `asOfDate` |
| `GET` | `/employees/query/headcount` | Headcount by criteria | `groupBy[]` |
| `GET` | `/employees/query/new-hires` | New hires in period | `from`, `to` |
| `GET` | `/employees/query/terminations` | Terminations in period | `from`, `to` |
| `GET` | `/employees/query/anniversaries` | Work anniversaries | `month` |

---

## 3. WorkRelationship APIs

> **Entity**: `WorkRelationship`  
> **Domain**: Legal Engagement  
> **Base Path**: `/api/v1/work-relationships`

### 3.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/work-relationships` | Create work relationship | HR Admin |
| `GET` | `/work-relationships/{id}` | Get by ID | Read |
| `GET` | `/work-relationships` | List (paginated) | Read |
| `PATCH` | `/work-relationships/{id}` | Update | HR Admin |
| `DELETE` | `/work-relationships/{id}` | Soft delete | Super Admin |

### 3.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/work-relationships/{id}/actions/activate` | Activate pending WR (hire date reached) | System/Admin |
| `POST` | `/work-relationships/{id}/actions/suspend` | Suspend WR | Disciplinary |
| `POST` | `/work-relationships/{id}/actions/terminate` | Terminate WR | Offboarding |
| `POST` | `/work-relationships/{id}/actions/cancelHire` | Cancel hire before start date | Pre-hire cancel |
| `POST` | `/work-relationships/{id}/actions/completeProbation` | Complete probation (PASS/FAIL) | Probation end |
| `POST` | `/work-relationships/{id}/actions/extendProbation` | Extend probation period | Probation |
| `POST` | `/work-relationships/{id}/actions/convertType` | Convert worker type (Employee → Contractor) | Reclassification |

### 3.3 VN Compliance Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/work-relationships/{id}/actions/closeSocialInsurance` | Close BHXH book (Chốt sổ BHXH) | VN Termination |
| `POST` | `/work-relationships/{id}/actions/returnInsuranceBook` | Return insurance book to worker | VN Termination |
| `POST` | `/work-relationships/{id}/actions/processUnemploymentInsurance` | Process unemployment insurance | VN Termination |
| `POST` | `/work-relationships/{id}/actions/calculateSeverance` | Calculate severance allowance | VN Termination |
| `POST` | `/work-relationships/{id}/actions/issueTerminationDecision` | Issue termination decision number | VN Termination |

---

## 4. Assignment APIs

> **Entity**: `Assignment`  
> **Domain**: Job Placement  
> **Base Path**: `/api/v1/assignments`

### 4.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/assignments` | Create assignment | HR Admin |
| `GET` | `/assignments/{id}` | Get by ID | Read |
| `GET` | `/assignments` | List (paginated) | Read |
| `PATCH` | `/assignments/{id}` | Update | HR Admin |
| `DELETE` | `/assignments/{id}` | Soft delete | Super Admin |

### 4.2 Business Actions - Career & Org Changes

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/assignments/{id}/actions/promote` | Promotion (new job/grade) | Career |
| `POST` | `/assignments/{id}/actions/demote` | Demotion | Disciplinary |
| `POST` | `/assignments/{id}/actions/transfer` | Transfer department/location | Reorganization |
| `POST` | `/assignments/{id}/actions/changePosition` | Change position (same job) | Reorganization |
| `POST` | `/assignments/{id}/actions/changeJob` | Change job (lateral move) | Career |
| `POST` | `/assignments/{id}/actions/changeManager` | Change reporting manager | Org change |
| `POST` | `/assignments/{id}/actions/changeLocation` | Change work location | Mobility |
| `POST` | `/assignments/{id}/actions/changeFTE` | Change FTE/work hours | Adjustment |
| `POST` | `/assignments/{id}/actions/changeCostCenter` | Change cost center | Finance |

### 4.3 Business Actions - Multi-Job

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/assignments/{id}/actions/makePrimary` | Set as primary assignment | Multi-job |
| `POST` | `/assignments/{id}/actions/addConcurrentJob` | Add additional concurrent job | Multi-job |
| `POST` | `/assignments/{id}/actions/endConcurrentJob` | End concurrent job | Multi-job |

### 4.4 Business Actions - Status

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/assignments/{id}/actions/suspend` | Suspend assignment | Temporary |
| `POST` | `/assignments/{id}/actions/terminate` | End assignment | End |
| `POST` | `/assignments/{id}/actions/completeProbation` | Complete assignment-level probation | Probation |

### 4.5 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/assignments/{id}/history` | Assignment history | `from`, `to` |
| `GET` | `/assignments/query/as-of-date` | Get assignments as of date | `asOfDate`, `employeeId` |
| `GET` | `/assignments/query/by-department` | Assignments by department | `departmentId`, `isCurrent` |
| `GET` | `/assignments/query/by-position` | Assignments by position | `positionId`, `isCurrent` |
| `GET` | `/assignments/query/org-chart` | Org chart from assignment | `rootAssignmentId` |

---

## 5. Contract APIs

> **Entity**: `Contract` (Labor Contract)  
> **Domain**: Employment  
> **Base Path**: `/api/v1/contracts`

### 5.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/contracts` | Create contract (from template) | HR Admin |
| `GET` | `/contracts/{id}` | Get by ID | Read |
| `GET` | `/contracts` | List (paginated) | Read |
| `PATCH` | `/contracts/{id}` | Update | HR Admin |
| `DELETE` | `/contracts/{id}` | Soft delete | Super Admin |

### 5.2 Business Actions - Lifecycle

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/contracts/{id}/actions/submitForSignature` | Submit to employee for signature | Workflow |
| `POST` | `/contracts/{id}/actions/sign` | Record signature (employee signed) | eSignature |
| `POST` | `/contracts/{id}/actions/activate` | Activate signed contract | Post-signature |
| `POST` | `/contracts/{id}/actions/renew` | Renew contract (creates new contract) | Expiry |
| `POST` | `/contracts/{id}/actions/terminate` | Early termination | Offboarding |
| `POST` | `/contracts/{id}/actions/expire` | Mark as expired | Auto/Manual |
| `POST` | `/contracts/{id}/actions/cancel` | Cancel draft contract | Admin |
| `POST` | `/contracts/{id}/actions/amend` | Amend active contract (addendum) | Change |

### 5.3 Business Actions - Document

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/contracts/{id}/actions/generateDocument` | Generate PDF from template | Doc gen |
| `POST` | `/contracts/{id}/actions/uploadSignedDocument` | Upload signed PDF | Post-sign |
| `GET` | `/contracts/{id}/document` | Download contract document | Read |

### 5.4 VN Compliance Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/contracts/{id}/actions/validateVNCompliance` | Validate VN labor law compliance | Pre-activation |
| `POST` | `/contracts/{id}/actions/convertToIndefinite` | Convert to indefinite (VN 2x definite rule) | Auto |

### 5.5 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/contracts/query/expiring-soon` | Contracts expiring in N days | `days`, `legalEntityId` |
| `GET` | `/contracts/query/pending-renewal` | Contracts pending renewal | `legalEntityId` |
| `GET` | `/contracts/query/pending-signature` | Contracts pending signature | `employeeId` |
| `GET` | `/contracts/{id}/renewalHistory` | Renewal chain history | - |

---

## 6. ContractTemplate APIs

> **Entity**: `ContractTemplate`  
> **Domain**: Configuration  
> **Base Path**: `/api/v1/contract-templates`

### 6.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/contract-templates` | Create template | Config Admin |
| `GET` | `/contract-templates/{id}` | Get by ID | Read |
| `GET` | `/contract-templates` | List (paginated) | Read |
| `PATCH` | `/contract-templates/{id}` | Update | Config Admin |
| `DELETE` | `/contract-templates/{id}` | Soft delete | Config Admin |

### 6.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/contract-templates/{id}/actions/activate` | Activate template | Admin |
| `POST` | `/contract-templates/{id}/actions/deactivate` | Deactivate template | Admin |
| `POST` | `/contract-templates/{id}/actions/clone` | Clone template | Admin |
| `POST` | `/contract-templates/{id}/actions/preview` | Preview with sample data | Admin |
| `POST` | `/contract-templates/{id}/actions/validatePlaceholders` | Validate all placeholders | Admin |

### 6.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/contract-templates/query/active` | Get active templates by type | `typeCode`, `languageCode` |
| `GET` | `/contract-templates/{id}/placeholders` | Get template placeholders | - |

---

## Summary

### API Count by Entity

| Entity | CRUD | Actions | Query | Total |
|--------|------|---------|-------|-------|
| Worker | 5 | 6 | 6 | **17** |
| Employee | 5 | 11 | 8 | **24** |
| WorkRelationship | 5 | 12 | - | **17** |
| Assignment | 5 | 15 | 5 | **25** |
| Contract | 5 | 12 | 4 | **21** |
| ContractTemplate | 5 | 5 | 2 | **12** |
| **Total** | **30** | **61** | **25** | **116** |

### Priority Matrix

| Priority | APIs | Description |
|----------|------|-------------|
| **P0** | CRUD (30) | Basic operations - MVP |
| **P1** | Core Actions (25) | hire, terminate, promote, transfer |
| **P2** | Secondary Actions (20) | suspend, rehire, convertType |
| **P3** | VN Compliance (10) | BHXH, severance, termination docs |
| **P4** | Query & Reports (25) | Analytics, history, org chart |
| **P5** | Batch & Bulk (6) | Mass operations |

---

## Next Steps

1. Create individual `*.api.md` files for each entity
2. Define request/response schemas
3. Document error scenarios
4. Define authorization rules per endpoint
5. Create OpenAPI/Swagger specification

---

*Document Status: DRAFT*  
*References: [[Worker]], [[Employee]], [[WorkRelationship]], [[Assignment]], [[Contract]], [[ContractTemplate]]*
