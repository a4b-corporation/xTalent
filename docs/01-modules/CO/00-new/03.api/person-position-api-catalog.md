# Person & Position API Catalog

> **Module**: Core HR - Person Data & Position Management  
> **Version**: 1.0.0  
> **Status**: Draft  
> **Last Updated**: 2026-01-29  
> **Reference**: Oracle HCM, SAP SuccessFactors, Workday patterns

---

## Overview

This document catalogs all necessary APIs for **Person Data** (contacts, bank accounts, documents, qualifications, relationships) and **Position Management** entities.

### Domain Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│  PERSONAL DATA (Polymorphic - Worker/Employee/Company)             │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐               │
│  │ BankAccount │  │   Contact    │  │   Document   │               │
│  │ (Payroll)   │  │ (Phone/Email)│  │ (Files/IDs)  │               │
│  └─────────────┘  └──────────────┘  └──────────────┘               │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  WORKER EXTENSIONS                                                  │
│  ┌─────────────────────┐  ┌──────────────────────┐                 │
│  │ WorkerQualification │  │  WorkerRelationship  │                 │
│  │ (Education/Certs)   │  │  (Family/Dependents) │                 │
│  └─────────────────────┘  └──────────────────────┘                 │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  ORGANIZATIONAL STRUCTURE                                          │
│  ┌──────────────┐                                                   │
│  │   Position   │ ← "Chair" in org chart (instance of Job)        │
│  │  (Org Chart) │                                                   │
│  └──────────────┘                                                   │
└─────────────────────────────────────────────────────────────────────┘
```

### Entities Covered

| Entity | Description | File |
|--------|-------------|------|
| **BankAccount** | Polymorphic bank account for payroll | BankAccount.onto.md |
| **Contact** | Phone, Email, Emergency contacts | Contact.onto.md |
| **Document** | File attachments, identity documents | Document.onto.md |
| **Position** | Organizational chair (instance of Job) | position.onto.md |
| **WorkerQualification** | Education, Certifications, Licenses | worker-qualification.onto.md |
| **WorkerRelationship** | Family members, Dependents, Beneficiaries | worker-relationship.onto.md |

---

## 1. BankAccount APIs

> **Entity**: `BankAccount`  
> **Domain**: Common (Polymorphic)  
> **Base Path**: `/api/v1/bank-accounts`

### 1.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/bank-accounts` | Create bank account | Admin |
| `GET` | `/bank-accounts/{id}` | Get by ID | Read |
| `GET` | `/bank-accounts` | List (paginated) | Read |
| `PATCH` | `/bank-accounts/{id}` | Update | Admin |
| `DELETE` | `/bank-accounts/{id}` | Soft delete | Admin |

### 1.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/bank-accounts/{id}/actions/verify` | Verify account (test transfer) | Admin |
| `POST` | `/bank-accounts/{id}/actions/setPrimary` | Set as primary for payroll | Admin |
| `POST` | `/bank-accounts/{id}/actions/block` | Block account (fraud, investigation) | Security |
| `POST` | `/bank-accounts/{id}/actions/unblock` | Unblock account | Security |
| `POST` | `/bank-accounts/{id}/actions/deactivate` | Deactivate (closed, changed) | Admin |
| `POST` | `/bank-accounts/{id}/actions/cancel` | Cancel pending verification | Admin |

### 1.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/bank-accounts/query/by-owner` | Get by owner | `ownerType`, `ownerId` |
| `GET` | `/bank-accounts/query/primary` | Get primary for payroll | `ownerType`, `ownerId` |
| `GET` | `/bank-accounts/query/pending` | Get pending verification | `ownerType` |
| `GET` | `/bank-accounts/query/by-currency/{code}` | Get by currency | - |
| `GET` | `/bank-accounts/query/by-bank/{bankCode}` | Get by bank | - |

### 1.4 VN-Specific

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/bank-accounts/{id}/actions/validateVnFormat` | Validate VN account format |
| `GET` | `/bank-accounts/vn/banks` | Get VN bank list (CITAD codes) |

---

## 2. Contact APIs

> **Entity**: `Contact`  
> **Domain**: Common (Polymorphic)  
> **Base Path**: `/api/v1/contacts`

### 2.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/contacts` | Create contact | Admin |
| `GET` | `/contacts/{id}` | Get by ID | Read |
| `GET` | `/contacts` | List (paginated) | Read |
| `PATCH` | `/contacts/{id}` | Update | Admin |
| `DELETE` | `/contacts/{id}` | Soft delete | Admin |

### 2.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/contacts/{id}/actions/verify` | Verify contact (OTP, email link) | System |
| `POST` | `/contacts/{id}/actions/setPrimary` | Set as primary for type | Admin |
| `POST` | `/contacts/{id}/actions/deactivate` | Deactivate | Admin |
| `POST` | `/contacts/{id}/actions/reactivate` | Reactivate | Admin |
| `POST` | `/contacts/{id}/actions/sendVerification` | Send verification code | System |

### 2.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/contacts/query/by-owner` | Get by owner | `ownerType`, `ownerId` |
| `GET` | `/contacts/query/primary-phone` | Get primary phone | `ownerType`, `ownerId` |
| `GET` | `/contacts/query/primary-email` | Get primary email | `ownerType`, `ownerId` |
| `GET` | `/contacts/query/emergency` | Get emergency contacts | `ownerId` |
| `GET` | `/contacts/query/by-type/{type}` | Get by contact type | `ownerType`, `ownerId` |
| `GET` | `/contacts/query/unverified` | Get unverified contacts | `ownerType` |

---

## 3. Document APIs

> **Entity**: `Document`  
> **Domain**: Common (Polymorphic)  
> **Base Path**: `/api/v1/documents`

### 3.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/documents` | Upload document | Admin |
| `GET` | `/documents/{id}` | Get by ID | Read |
| `GET` | `/documents` | List (paginated) | Read |
| `PATCH` | `/documents/{id}` | Update metadata | Admin |
| `DELETE` | `/documents/{id}` | Soft delete | Admin |

### 3.2 Business Actions - Lifecycle

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/documents/{id}/actions/activate` | Activate draft | Admin |
| `POST` | `/documents/{id}/actions/submitForVerification` | Submit for verification | Admin |
| `POST` | `/documents/{id}/actions/verify` | Mark as verified | Verifier |
| `POST` | `/documents/{id}/actions/reject` | Reject verification | Verifier |
| `POST` | `/documents/{id}/actions/expire` | Mark as expired | System/Admin |
| `POST` | `/documents/{id}/actions/archive` | Archive (retention ended) | System |

### 3.3 Business Actions - File Operations

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/documents/{id}/actions/createNewVersion` | Upload new version | Admin |
| `POST` | `/documents/{id}/actions/download` | Get signed download URL | Read |
| `POST` | `/documents/{id}/actions/share` | Generate shareable link | Admin |
| `POST` | `/documents/{id}/actions/preview` | Get preview URL | Read |

### 3.4 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/documents/query/by-owner` | Get by owner | `ownerType`, `ownerId` |
| `GET` | `/documents/query/by-type/{type}` | Get by document type | `ownerType`, `ownerId` |
| `GET` | `/documents/query/expiring-soon` | Get expiring within N days | `days`, `ownerType` |
| `GET` | `/documents/query/pending-verification` | Get pending verification | `ownerType` |
| `GET` | `/documents/{id}/versions` | Get version history | - |
| `GET` | `/documents/query/by-retention` | Get by retention date | `before`, `after` |

### 3.5 VN Document Types

| Code | VN Name | Description |
|------|---------|-------------|
| `CCCD` | Căn cước công dân | Citizen ID (12-digit) |
| `CMND` | Chứng minh nhân dân | Old ID (9-digit) |
| `LABOR_CONTRACT` | Hợp đồng lao động | Labor contract |
| `BHXH_BOOK` | Sổ BHXH | Social insurance book |
| `WORK_PERMIT` | Giấy phép lao động | Work permit (foreigners) |

---

## 4. Position APIs

> **Entity**: `Position`  
> **Domain**: Org Structure  
> **Base Path**: `/api/v1/positions`

### 4.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/positions` | Create position | HR Admin |
| `GET` | `/positions/{id}` | Get by ID | Read |
| `GET` | `/positions` | List (paginated) | Read |
| `PATCH` | `/positions/{id}` | Update | HR Admin |
| `DELETE` | `/positions/{id}` | Soft delete | HR Admin |

### 4.2 Business Actions - Lifecycle

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/positions/{id}/actions/activate` | Activate draft position | Admin |
| `POST` | `/positions/{id}/actions/freeze` | Freeze (no new hires) | Headcount control |
| `POST` | `/positions/{id}/actions/unfreeze` | Unfreeze position | Admin |
| `POST` | `/positions/{id}/actions/deactivate` | Deactivate (temporary) | Admin |
| `POST` | `/positions/{id}/actions/close` | Permanently close | Org change |
| `POST` | `/positions/{id}/actions/reactivate` | Reactivate | Admin |

### 4.3 Business Actions - Management

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/positions/{id}/actions/clone` | Clone position | New headcount |
| `POST` | `/positions/{id}/actions/changeSupervisor` | Change supervisor position | Reorg |
| `POST` | `/positions/{id}/actions/updateHeadcount` | Update planned headcount | Planning |
| `POST` | `/positions/{id}/actions/transferToBusinessUnit` | Move to another BU | Reorg |
| `POST` | `/positions/{id}/actions/markCritical` | Mark as critical role | Risk |
| `POST` | `/positions/{id}/actions/planSuccession` | Mark succession planned | Succession |
| `POST` | `/positions/{id}/actions/createVersion` | SCD Type-2 new version | Major change |

### 4.4 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/positions/{id}/subordinates` | Get direct reports | `recursive` |
| `GET` | `/positions/{id}/ancestors` | Get path to top | - |
| `GET` | `/positions/{id}/assignments` | Get current incumbents | `asOfDate` |
| `GET` | `/positions/{id}/vacancy-status` | Get vacancy info | - |
| `GET` | `/positions/tree/{buId}` | Get org chart for BU | `depth`, `positionId` |
| `GET` | `/positions/query/by-business-unit/{buId}` | Get by BU | `status`, `isVacant` |
| `GET` | `/positions/query/by-job/{jobId}` | Get by job template | - |
| `GET` | `/positions/query/vacant` | Get vacant positions | `buId`, `jobId` |
| `GET` | `/positions/query/frozen` | Get frozen positions | `buId` |
| `GET` | `/positions/query/critical` | Get critical roles | `buId` |
| `GET` | `/positions/query/without-successor` | Get critical without succession | - |
| `GET` | `/positions/search` | Search by title/code | `q`, `buId` |

---

## 5. WorkerQualification APIs

> **Entity**: `WorkerQualification`  
> **Domain**: Person Extensions  
> **Base Path**: `/api/v1/worker-qualifications`

### 5.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/worker-qualifications` | Create qualification | Admin |
| `GET` | `/worker-qualifications/{id}` | Get by ID | Read |
| `GET` | `/worker-qualifications` | List (paginated) | Read |
| `PATCH` | `/worker-qualifications/{id}` | Update | Admin |
| `DELETE` | `/worker-qualifications/{id}` | Soft delete | Admin |

### 5.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/worker-qualifications/{id}/actions/verify` | Verify qualification | Verifier |
| `POST` | `/worker-qualifications/{id}/actions/expire` | Mark as expired | System |
| `POST` | `/worker-qualifications/{id}/actions/renew` | Renew certification | Admin |
| `POST` | `/worker-qualifications/{id}/actions/invalidate` | Mark as invalid/fraudulent | Security |
| `POST` | `/worker-qualifications/{id}/actions/attachDocument` | Attach supporting document | Admin |
| `POST` | `/worker-qualifications/batch` | Batch create/update | Admin |

### 5.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/worker-qualifications/query/by-worker/{workerId}` | Get by worker | `type`, `isVerified` |
| `GET` | `/worker-qualifications/query/by-type/{type}` | Get by type | `workerId` |
| `GET` | `/worker-qualifications/query/expiring-soon` | Get expiring soon | `days`, `type` |
| `GET` | `/worker-qualifications/query/verified/{workerId}` | Get verified only | - |
| `GET` | `/worker-qualifications/query/education/{workerId}` | Get education records | - |
| `GET` | `/worker-qualifications/query/certifications/{workerId}` | Get certifications | - |

### 5.4 Qualification Types

| Type | Description | Examples |
|------|-------------|----------|
| `EDUCATION` | Academic degrees | Bachelor, Master, PhD |
| `CERTIFICATION` | Professional certifications | PMP, AWS, CPA |
| `LICENSE` | Professional licenses | Medical, Legal, CFA |
| `LANGUAGE` | Language proficiency | IELTS, TOEFL, JLPT |
| `TRAINING` | Training completions | Internal training, workshops |
| `AWARD` | Awards and recognitions | Employee of the Year |

---

## 6. WorkerRelationship APIs

> **Entity**: `WorkerRelationship`  
> **Domain**: Person Extensions  
> **Base Path**: `/api/v1/worker-relationships`

### 6.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/worker-relationships` | Create relationship | Admin |
| `GET` | `/worker-relationships/{id}` | Get by ID | Read |
| `GET` | `/worker-relationships` | List (paginated) | Read |
| `PATCH` | `/worker-relationships/{id}` | Update | Admin |
| `DELETE` | `/worker-relationships/{id}` | Soft delete | Admin |

### 6.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/worker-relationships/{id}/actions/deactivate` | Deactivate (divorce, etc.) | Admin |
| `POST` | `/worker-relationships/{id}/actions/reactivate` | Reactivate | Admin |
| `POST` | `/worker-relationships/{id}/actions/recordDeceased` | Mark as deceased | Admin |
| `POST` | `/worker-relationships/{id}/actions/setAsDependent` | Register as tax dependent | Tax |
| `POST` | `/worker-relationships/{id}/actions/removeAsDependent` | Remove as tax dependent | Tax |
| `POST` | `/worker-relationships/{id}/actions/setAsBeneficiary` | Set as insurance beneficiary | Benefits |
| `POST` | `/worker-relationships/{id}/actions/setAsEmergency` | Set as emergency contact | Admin |
| `POST` | `/worker-relationships/{id}/actions/updatePriority` | Update emergency priority | Admin |

### 6.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/worker-relationships/query/by-worker/{workerId}` | Get by worker | `relationCode`, `isActive` |
| `GET` | `/worker-relationships/query/dependents/{workerId}` | Get tax dependents | - |
| `GET` | `/worker-relationships/query/beneficiaries/{workerId}` | Get insurance beneficiaries | - |
| `GET` | `/worker-relationships/query/emergency-contacts/{workerId}` | Get emergency contacts | - |
| `GET` | `/worker-relationships/query/by-type/{type}` | Get by relationship type | `workerId` |
| `GET` | `/worker-relationships/query/spouse/{workerId}` | Get spouse info | - |
| `GET` | `/worker-relationships/query/children/{workerId}` | Get children | - |

### 6.4 VN Tax Dependent

| Field | Description |
|-------|-------------|
| `isDependentFlag` | Is tax dependent (người phụ thuộc) |
| `dependentDeductionStartMonth` | Start month for PIT deduction |
| `nationalId` | ID for registration |
| `taxCode` | Personal tax code (MST cá nhân) |

---

## Summary

### API Count by Entity

| Entity | CRUD | Actions | Query | Total |
|--------|------|---------|-------|-------|
| BankAccount | 5 | 7 | 5 | **17** |
| Contact | 5 | 5 | 6 | **16** |
| Document | 5 | 10 | 6 | **21** |
| Position | 5 | 13 | 12 | **30** |
| WorkerQualification | 5 | 6 | 6 | **17** |
| WorkerRelationship | 5 | 8 | 7 | **20** |
| **Total** | **30** | **49** | **42** | **121** |

### Priority Matrix

| Priority | APIs | Description |
|----------|------|-------------|
| **P0** | 30 | CRUD - MVP |
| **P1** | 20 | Core Actions (verify, activate, setPrimary) |
| **P2** | 15 | Lifecycle (expire, archive, deactivate) |
| **P3** | 14 | Position Management (freeze, clone, transfer) |
| **P4** | 42 | Query & Navigation |

### Key Use Cases

| Use Case | APIs Involved |
|----------|---------------|
| **Add Payroll Bank** | POST /bank-accounts → verify → setPrimary |
| **Update Emergency Contact** | POST /contacts (EMERGENCY) → setAsEmergency |
| **Upload ID Document** | POST /documents → submitForVerification → verify |
| **Create Position** | POST /positions → activate |
| **Register Tax Dependent** | POST /worker-relationships → setAsDependent |
| **Org Chart View** | GET /positions/tree/{buId} |

---

*Document Status: DRAFT*  
*References: [[BankAccount]], [[Contact]], [[Document]], [[Position]], [[WorkerQualification]], [[WorkerRelationship]]*
