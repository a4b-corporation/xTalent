# Core Module (CO) - API Specification

**Version**: 2.0  
**Last Updated**: 2025-12-03  
**Module**: Core (CO)  
**Status**: Complete - 450 FRs Documented

---

## 📋 Overview

This document specifies all REST API endpoints for the Core Module, derived from 450 functional requirements across 15 feature sets. The API follows RESTful principles and supports the complete employment lifecycle, organization management, and HR operations.

### API Design Principles

- **RESTful**: Resource-oriented URLs, HTTP methods
- **Versioned**: `/api/v1/` prefix for all endpoints
- **Authenticated**: Bearer token authentication required
- **Authorized**: Role-based access control (RBAC)
- **Consistent**: Standard request/response formats
- **Validated**: Input validation on all endpoints
- **Audited**: All mutations logged
- **Secure**: HTTPS only, data classification enforced

---

## 🔐 Authentication & Authorization

### Authentication

All API requests require authentication via Bearer token:

```http
Authorization: Bearer {access_token}
```

### Authorization Roles

| Role | Description | Access Level |
|------|-------------|--------------|
| `SYSTEM_ADMIN` | System administrator | Full access |
| `HR_ADMIN` | HR administrator | HR operations |
| `HR_MANAGER` | HR manager | HR read + limited write |
| `MANAGER` | People manager | Team management |
| `EMPLOYEE` | Regular employee | Self-service |
| `RECRUITER` | Recruiter | Hiring operations |
| `DPO` | Data Protection Officer | Privacy operations |

---

## 📊 API Endpoint Summary

### By Feature Area

| Feature Area | Endpoints | FRs | Priority |
|--------------|-----------|-----|----------|
| **Code Lists & Configuration** | 8 | 40 | HIGH |
| **Worker Management** | 12 | 25 | HIGH |
| **Work Relationship** | 15 | 30 | HIGH |
| **Employee Management** | 14 | 25 | HIGH |
| **Assignment Management** | 22 | 45 | HIGH |
| **Basic Reporting** | 20 | 20 | MEDIUM |
| **Business Unit** | 18 | 35 | HIGH |
| **Job Taxonomy** | 16 | 30 | MEDIUM |
| **Job Profile** | 14 | 30 | MEDIUM |
| **Position Management** | 19 | 35 | HIGH |
| **Matrix Reporting** | 12 | 25 | MEDIUM |
| **Skill Catalog** | 10 | 25 | MEDIUM |
| **Skill Assessment** | 14 | 30 | MEDIUM |
| **Career Paths** | 10 | 25 | MEDIUM |
| **Data Privacy** | 16 | 30 | HIGH |
| **TOTAL** | **220** | **450** | - |

---

## 🎯 Phase 0: Code Lists & Configuration

### Code List Management

#### GET /api/v1/code-lists
Get all code lists

**Authorization**: `HR_ADMIN`, `HR_MANAGER`

**Response** (200 OK):
```json
{
  "code_lists": [
    {
      "code": "GENDER",
      "name": "Gender",
      "description": "Gender codes",
      "is_active": true,
      "values_count": 4
    }
  ],
  "total": 50
}
```

**Related FRs**: FR-CFG-001

---

#### GET /api/v1/code-lists/{code}
Get code list details

**Authorization**: `HR_ADMIN`, `HR_MANAGER`, `EMPLOYEE`

**Response** (200 OK):
```json
{
  "code": "GENDER",
  "name": "Gender",
  "description": "Gender codes",
  "values": [
    {
      "code": "M",
      "name": "Male",
      "description": "Male gender",
      "sort_order": 1,
      "is_active": true
    },
    {
      "code": "F",
      "name": "Female",
      "description": "Female gender",
      "sort_order": 2,
      "is_active": true
    }
  ]
}
```

**Related FRs**: FR-CFG-002

---

#### POST /api/v1/code-lists
Create new code list

**Authorization**: `SYSTEM_ADMIN`

**Request**:
```json
{
  "code": "EMPLOYMENT_TYPE",
  "name": "Employment Type",
  "description": "Types of employment",
  "category": "EMPLOYMENT",
  "is_system": false
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "code": "EMPLOYMENT_TYPE",
  "name": "Employment Type",
  "created_at": "2025-12-03T10:00:00Z"
}
```

**Related FRs**: FR-CFG-003

---

#### POST /api/v1/code-lists/{code}/values
Add code value

**Authorization**: `SYSTEM_ADMIN`, `HR_ADMIN`

**Request**:
```json
{
  "code": "FT",
  "name": "Full Time",
  "description": "Full-time employment",
  "sort_order": 1,
  "is_active": true,
  "metadata": {
    "fte": 1.0
  }
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "code": "FT",
  "name": "Full Time",
  "created_at": "2025-12-03T10:00:00Z"
}
```

**Related FRs**: FR-CFG-004

---

### Configuration Management

#### GET /api/v1/configurations
Get system configurations

**Authorization**: `SYSTEM_ADMIN`, `HR_ADMIN`

**Response** (200 OK):
```json
{
  "configurations": [
    {
      "key": "employee_number_format",
      "value": "EMP-{YYYY}-{NNNNNN}",
      "data_type": "STRING",
      "category": "EMPLOYEE"
    }
  ]
}
```

**Related FRs**: FR-CFG-010

---

#### PUT /api/v1/configurations/{key}
Update configuration

**Authorization**: `SYSTEM_ADMIN`

**Request**:
```json
{
  "value": "EMP-{NNNNNN}",
  "description": "Simplified employee number format"
}
```

**Response** (200 OK):
```json
{
  "key": "employee_number_format",
  "value": "EMP-{NNNNNN}",
  "updated_at": "2025-12-03T10:00:00Z"
}
```

**Related FRs**: FR-CFG-011

---

## 👤 Phase 1: Worker Management

### Worker CRUD Operations

#### POST /api/v1/workers
Create worker record

**Authorization**: `HR_ADMIN`, `RECRUITER`

**Request**:
```json
{
  "full_name": "Nguyễn Văn An",
  "preferred_name": "An",
  "date_of_birth": "1990-01-15",
  "gender_code": "M",
  "person_type": "EMPLOYEE",
  "national_id": "001234567890",
  "email": "an.nguyen@company.com",
  "phone": "+84901234567"
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "code": "WORKER-000001",
  "full_name": "Nguyễn Văn An",
  "person_type": "EMPLOYEE",
  "created_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-WRK-001, BR-WRK-002

**Related FRs**: FR-WRK-001

---

#### GET /api/v1/workers/{id}
Get worker details

**Authorization**: `HR_ADMIN`, `HR_MANAGER`, `MANAGER` (own team), `EMPLOYEE` (self)

**Response** (200 OK):
```json
{
  "id": "uuid",
  "code": "WORKER-000001",
  "full_name": "Nguyễn Văn An",
  "preferred_name": "An",
  "date_of_birth": "1990-01-15",
  "gender_code": "M",
  "person_type": "EMPLOYEE",
  "email": "an.nguyen@company.com",
  "phone": "+84901234567",
  "created_at": "2025-12-03T10:00:00Z",
  "updated_at": "2025-12-03T10:00:00Z"
}
```

**Data Classification**: CONFIDENTIAL (date_of_birth, national_id filtered based on role)

**Related FRs**: FR-WRK-002

---

#### PUT /api/v1/workers/{id}
Update worker information

**Authorization**: `HR_ADMIN`, `EMPLOYEE` (self, limited fields)

**Request**:
```json
{
  "preferred_name": "An Nguyen",
  "email": "an.nguyen@newcompany.com",
  "phone": "+84909876543"
}
```

**Response** (200 OK):
```json
{
  "id": "uuid",
  "code": "WORKER-000001",
  "preferred_name": "An Nguyen",
  "updated_at": "2025-12-03T11:00:00Z",
  "version": 2
}
```

**SCD Type 2**: Significant changes create new version

**Related FRs**: FR-WRK-003

---

#### GET /api/v1/workers
Search and list workers

**Authorization**: `HR_ADMIN`, `HR_MANAGER`, `RECRUITER`

**Query Parameters**:
- `name`: string (search by name)
- `person_type`: enum (EMPLOYEE, CONTRACTOR, etc.)
- `status`: enum (ACTIVE, INACTIVE)
- `page`: integer (default: 1)
- `limit`: integer (default: 20, max: 100)

**Response** (200 OK):
```json
{
  "workers": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "pages": 8
  }
}
```

**Related FRs**: FR-WRK-010

---

### Worker Data Management

#### GET /api/v1/workers/{id}/history
Get worker change history

**Authorization**: `HR_ADMIN`, `DPO`

**Response** (200 OK):
```json
{
  "history": [
    {
      "version": 2,
      "changed_at": "2025-12-03T11:00:00Z",
      "changed_by": "user-id",
      "changes": {
        "email": {
          "old": "an.nguyen@company.com",
          "new": "an.nguyen@newcompany.com"
        }
      }
    }
  ]
}
```

**Related FRs**: FR-WRK-015

---

#### GET /api/v1/workers/{id}/audit-trail
Get complete audit trail

**Authorization**: `HR_ADMIN`, `DPO`, `AUDITOR`

**Response** (200 OK):
```json
{
  "audit_logs": [
    {
      "timestamp": "2025-12-03T10:00:00Z",
      "user": "admin@company.com",
      "action": "CREATE",
      "entity": "Worker",
      "entity_id": "uuid",
      "changes": {...}
    }
  ]
}
```

**Related FRs**: FR-WRK-020

---

## 💼 Phase 1: Work Relationship Management

### Work Relationship CRUD

#### POST /api/v1/work-relationships
Create work relationship

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "worker_id": "uuid",
  "relationship_type": "EMPLOYEE",
  "legal_entity_id": "uuid",
  "start_date": "2025-01-01",
  "end_date": null,
  "employment_type": "FULL_TIME",
  "contract_type": "PERMANENT"
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "worker_id": "uuid",
  "relationship_type": "EMPLOYEE",
  "status": "ACTIVE",
  "created_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-WR-001, BR-WR-002

**Related FRs**: FR-WR-001

---

#### PUT /api/v1/work-relationships/{id}
Update work relationship

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "employment_type": "PART_TIME",
  "effective_date": "2025-02-01"
}
```

**Response** (200 OK):
```json
{
  "id": "uuid",
  "employment_type": "PART_TIME",
  "effective_date": "2025-02-01",
  "version": 2
}
```

**SCD Type 2**: Creates new version with effective dating

**Related FRs**: FR-WR-002

---

#### POST /api/v1/work-relationships/{id}/terminate
Terminate work relationship

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "end_date": "2025-12-31",
  "termination_reason": "RESIGNATION",
  "notice_period_days": 30,
  "last_working_day": "2025-12-31"
}
```

**Response** (200 OK):
```json
{
  "id": "uuid",
  "status": "TERMINATED",
  "end_date": "2025-12-31",
  "terminated_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-WR-010

**Related FRs**: FR-WR-010

---

## 👥 Phase 1: Employee Management

### Employee CRUD

#### POST /api/v1/employees
Create employee record

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "worker_id": "uuid",
  "work_relationship_id": "uuid",
  "employee_number": "EMP-000001",
  "hire_date": "2025-01-01",
  "probation_end_date": "2025-04-01",
  "department_id": "uuid",
  "job_id": "uuid"
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "employee_number": "EMP-000001",
  "hire_date": "2025-01-01",
  "status": "ACTIVE",
  "created_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-EMP-001, BR-EMP-002

**Related FRs**: FR-EMP-001

---

#### GET /api/v1/employees/{id}
Get employee details

**Authorization**: `HR_ADMIN`, `HR_MANAGER`, `MANAGER` (own team), `EMPLOYEE` (self)

**Response** (200 OK):
```json
{
  "id": "uuid",
  "employee_number": "EMP-000001",
  "worker": {...},
  "work_relationship": {...},
  "current_assignment": {...},
  "hire_date": "2025-01-01",
  "status": "ACTIVE"
}
```

**Related FRs**: FR-EMP-002

---

#### POST /api/v1/employees/{id}/terminate
Terminate employee

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "termination_date": "2025-12-31",
  "termination_reason": "RESIGNATION",
  "termination_type": "VOLUNTARY",
  "notice_period_days": 30,
  "exit_interview_completed": false
}
```

**Response** (200 OK):
```json
{
  "id": "uuid",
  "status": "TERMINATED",
  "termination_date": "2025-12-31",
  "terminated_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-EMP-010

**Related FRs**: FR-EMP-010

---

## 📄 Phase 1: Contract Management ✨ NEW

### Contract Template Management

#### GET /api/v1/contract-templates
Get all contract templates

**Authorization**: `HR_ADMIN`, `HR_MANAGER`

**Query Parameters**:
- `country_code`: string (optional)
- `legal_entity_id`: uuid (optional)
- `business_unit_id`: uuid (optional)
- `contract_type`: enum (optional)
- `is_active`: boolean (default: true)

**Response** (200 OK):
```json
{
  "templates": [
    {
      "id": "uuid",
      "code": "VN_TECH_FIXED_12M",
      "name": "Vietnam Tech - Fixed Term 12 Months",
      "contract_type_code": "FIXED_TERM",
      "country_code": "VN",
      "business_unit_id": "uuid",
      "default_duration_value": 12,
      "default_duration_unit": "MONTH",
      "is_active": true
    }
  ],
  "total": 15
}
```

**Related FRs**: FR-CONTRACT-001

---

#### GET /api/v1/contract-templates/{id}
Get contract template details

**Authorization**: `HR_ADMIN`, `HR_MANAGER`

**Response** (200 OK):
```json
{
  "id": "uuid",
  "code": "VN_TECH_FIXED_12M",
  "name": "Vietnam Tech - Fixed Term 12 Months",
  "contract_type_code": "FIXED_TERM",
  "country_code": "VN",
  "legal_entity_id": null,
  "business_unit_id": "uuid",
  "default_duration_value": 12,
  "default_duration_unit": "MONTH",
  "min_duration_value": 6,
  "max_duration_value": 36,
  "probation_required": true,
  "probation_duration_value": 60,
  "probation_duration_unit": "DAY",
  "allows_renewal": true,
  "max_renewals": 2,
  "renewal_notice_days": 30,
  "default_notice_period_days": 30,
  "legal_requirements": {
    "max_consecutive_fixed_terms": 2,
    "mandatory_clauses": ["social_insurance", "termination_notice"]
  },
  "is_active": true,
  "created_at": "2025-01-01T00:00:00Z"
}
```

**Related FRs**: FR-CONTRACT-001

---

#### POST /api/v1/contract-templates
Create contract template

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "code": "SG_SALES_PROBATION_3M",
  "name": "Singapore Sales - Probation 3 Months",
  "contract_type_code": "PROBATION",
  "country_code": "SG",
  "business_unit_id": "uuid",
  "default_duration_value": 3,
  "default_duration_unit": "MONTH",
  "max_duration_value": 6,
  "probation_required": true,
  "probation_duration_value": 90,
  "probation_duration_unit": "DAY",
  "default_notice_period_days": 7,
  "is_active": true
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "code": "SG_SALES_PROBATION_3M",
  "name": "Singapore Sales - Probation 3 Months",
  "created_at": "2025-12-09T10:00:00Z"
}
```

**Business Rules**: BR-CONTRACT-TEMPLATE-001

**Related FRs**: FR-CONTRACT-001

---

#### PUT /api/v1/contract-templates/{id}
Update contract template

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "default_duration_value": 4,
  "max_duration_value": 6,
  "is_active": true
}
```

**Response** (200 OK):
```json
{
  "id": "uuid",
  "code": "SG_SALES_PROBATION_3M",
  "updated_at": "2025-12-09T11:00:00Z",
  "version": 2
}
```

**SCD Type 2**: Creates new version with effective dating

**Related FRs**: FR-CONTRACT-001

---

### Contract CRUD Operations

#### POST /api/v1/contracts
Create employment contract

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "employee_id": "uuid",
  "template_id": "uuid",
  "contract_type_code": "PROBATION",
  "start_date": "2025-01-01",
  "duration_value": 60,
  "duration_unit": "DAY",
  "probation_end_date": "2025-03-01",
  "notice_period_days": 7,
  "base_salary": 50000000,
  "salary_currency_code": "VND",
  "salary_frequency_code": "MONTHLY",
  "working_hours_per_week": 40,
  "governing_law_country": "VN"
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "employee_id": "uuid",
  "contract_type_code": "PROBATION",
  "start_date": "2025-01-01",
  "end_date": "2025-03-01",
  "status": "ACTIVE",
  "created_at": "2025-12-09T10:00:00Z"
}
```

**Business Rules**: BR-CONTRACT-001, BR-CONTRACT-002, BR-CONTRACT-003

**Related FRs**: FR-WR-022, FR-CONTRACT-002

---

#### GET /api/v1/contracts/{id}
Get contract details

**Authorization**: `HR_ADMIN`, `HR_MANAGER`, `MANAGER` (own team), `EMPLOYEE` (self)

**Response** (200 OK):
```json
{
  "id": "uuid",
  "employee_id": "uuid",
  "template_id": "uuid",
  "parent_contract_id": null,
  "parent_relationship_type": null,
  "contract_type_code": "PROBATION",
  "start_date": "2025-01-01",
  "end_date": "2025-03-01",
  "duration_value": 60,
  "duration_unit": "DAY",
  "probation_end_date": "2025-03-01",
  "notice_period_days": 7,
  "base_salary": 50000000,
  "salary_currency_code": "VND",
  "working_hours_per_week": 40,
  "status": "ACTIVE",
  "created_at": "2025-12-09T10:00:00Z"
}
```

**Related FRs**: FR-WR-022

---

#### PUT /api/v1/contracts/{id}
Update contract

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "base_salary": 60000000,
  "effective_date": "2025-02-01"
}
```

**Response** (200 OK):
```json
{
  "id": "uuid",
  "base_salary": 60000000,
  "updated_at": "2025-12-09T11:00:00Z",
  "version": 2
}
```

**Related FRs**: FR-WR-022

---

### Contract Hierarchy Operations

#### POST /api/v1/contracts/{id}/amend
Create contract amendment

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "effective_date": "2025-02-01",
  "base_salary": 60000000,
  "working_hours_per_week": 35,
  "reason": "Salary adjustment and reduced hours"
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "parent_contract_id": "{id}",
  "parent_relationship_type": "AMENDMENT",
  "effective_date": "2025-02-01",
  "created_at": "2025-12-09T10:00:00Z"
}
```

**Business Rules**: BR-CONTRACT-004, BR-CONTRACT-005

**Related FRs**: FR-CONTRACT-004

---

#### POST /api/v1/contracts/{id}/renew
Renew contract

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "start_date": "2025-04-01",
  "duration_value": 12,
  "duration_unit": "MONTH",
  "base_salary": 65000000
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "parent_contract_id": "{id}",
  "parent_relationship_type": "RENEWAL",
  "start_date": "2025-04-01",
  "end_date": "2026-03-31",
  "renewal_count": 1,
  "created_at": "2025-12-09T10:00:00Z"
}
```

**Business Rules**: BR-CONTRACT-004, BR-CONTRACT-006

**Related FRs**: FR-CONTRACT-005

---

#### POST /api/v1/contracts/{id}/supersede
Supersede contract (e.g., Probation → Permanent)

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "contract_type_code": "PERMANENT",
  "start_date": "2025-03-01",
  "base_salary": 65000000,
  "notice_period_days": 30
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "parent_contract_id": "{id}",
  "parent_relationship_type": "SUPERSESSION",
  "contract_type_code": "PERMANENT",
  "start_date": "2025-03-01",
  "end_date": null,
  "created_at": "2025-12-09T10:00:00Z"
}
```

**Business Rules**: BR-CONTRACT-004, BR-CONTRACT-007

**Related FRs**: FR-CONTRACT-006

---

#### GET /api/v1/contracts/{id}/hierarchy
Get contract hierarchy

**Authorization**: `HR_ADMIN`, `HR_MANAGER`

**Response** (200 OK):
```json
{
  "root_contract": {
    "id": "uuid",
    "contract_type_code": "PROBATION",
    "start_date": "2025-01-01",
    "end_date": "2025-03-01"
  },
  "children": [
    {
      "id": "uuid",
      "parent_relationship_type": "AMENDMENT",
      "effective_date": "2025-02-01",
      "changes": ["base_salary"]
    },
    {
      "id": "uuid",
      "parent_relationship_type": "SUPERSESSION",
      "contract_type_code": "PERMANENT",
      "start_date": "2025-03-01"
    }
  ]
}
```

**Related FRs**: FR-CONTRACT-003

---

### Contract Document Management

#### POST /api/v1/contracts/{id}/documents
Attach contract document

**Authorization**: `HR_ADMIN`

**Request** (multipart/form-data):
```
file: contract_signed.pdf
document_type: CONTRACT
description: Signed employment contract
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "contract_id": "{id}",
  "document_type": "CONTRACT",
  "file_name": "contract_signed.pdf",
  "file_size": 245678,
  "uploaded_at": "2025-12-09T10:00:00Z"
}
```

**Related FRs**: FR-CONTRACT-009

---

#### GET /api/v1/contracts/{id}/documents
Get contract documents

**Authorization**: `HR_ADMIN`, `HR_MANAGER`, `EMPLOYEE` (self)

**Response** (200 OK):
```json
{
  "documents": [
    {
      "id": "uuid",
      "document_type": "CONTRACT",
      "file_name": "contract_signed.pdf",
      "file_url": "/api/v1/documents/{doc_id}/download",
      "uploaded_at": "2025-12-09T10:00:00Z"
    }
  ]
}
```

**Related FRs**: FR-CONTRACT-009

---

### Contract Reporting

#### GET /api/v1/contracts/expiring
Get expiring contracts

**Authorization**: `HR_ADMIN`, `HR_MANAGER`

**Query Parameters**:
- `days_ahead`: integer (default: 30)
- `contract_type`: enum (optional)
- `business_unit_id`: uuid (optional)

**Response** (200 OK):
```json
{
  "expiring_contracts": [
    {
      "id": "uuid",
      "employee_id": "uuid",
      "employee_name": "Nguyễn Văn An",
      "contract_type_code": "FIXED_TERM",
      "end_date": "2025-12-31",
      "days_until_expiry": 22,
      "renewal_count": 0,
      "max_renewals": 2,
      "can_renew": true
    }
  ],
  "total": 15
}
```

**Related FRs**: FR-CONTRACT-007, FR-CONTRACT-010

---

#### GET /api/v1/reports/contracts/distribution
Get contract distribution report

**Authorization**: `HR_ADMIN`, `HR_MANAGER`

**Query Parameters**:
- `as_of_date`: date (default: today)
- `business_unit_id`: uuid (optional)

**Response** (200 OK):
```json
{
  "as_of_date": "2025-12-09",
  "total_contracts": 1500,
  "by_type": {
    "PERMANENT": 1200,
    "FIXED_TERM": 250,
    "PROBATION": 50
  },
  "by_country": {
    "VN": 1000,
    "SG": 400,
    "US": 100
  },
  "expiring_30_days": 15,
  "expiring_60_days": 28,
  "expiring_90_days": 45
}
```

**Related FRs**: FR-CONTRACT-010

---

## 📋 Phase 1: Assignment Management

### Assignment CRUD

#### POST /api/v1/assignments
Create assignment

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "employee_id": "uuid",
  "assignment_type": "PRIMARY",
  "staffing_model": "POSITION_BASED",
  "position_id": "uuid",
  "job_id": "uuid",
  "business_unit_id": "uuid",
  "location_id": "uuid",
  "start_date": "2025-01-01",
  "fte": 1.0
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "employee_id": "uuid",
  "assignment_type": "PRIMARY",
  "status": "ACTIVE",
  "created_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-ASG-001, BR-ASG-002

**Related FRs**: FR-ASG-001

---

#### POST /api/v1/assignments/{id}/managers/solid-line
Assign solid line manager

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "manager_id": "uuid",
  "effective_date": "2025-01-01"
}
```

**Response** (200 OK):
```json
{
  "assignment_id": "uuid",
  "manager_id": "uuid",
  "manager_type": "SOLID_LINE",
  "effective_date": "2025-01-01"
}
```

**Business Rules**: BR-MTX-001, BR-ASG-004

**Related FRs**: FR-ASG-010, FR-MTX-001

---

#### POST /api/v1/assignments/{id}/managers/dotted-line
Assign dotted line manager

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "manager_id": "uuid",
  "effective_date": "2025-01-01",
  "time_allocation_pct": 30
}
```

**Response** (200 OK):
```json
{
  "assignment_id": "uuid",
  "manager_id": "uuid",
  "manager_type": "DOTTED_LINE",
  "time_allocation_pct": 30,
  "effective_date": "2025-01-01"
}
```

**Business Rules**: BR-MTX-002

**Related FRs**: FR-ASG-011, FR-MTX-002

---

#### POST /api/v1/assignments/transfer
Transfer employee

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "employee_id": "uuid",
  "from_assignment_id": "uuid",
  "to_business_unit_id": "uuid",
  "to_job_id": "uuid",
  "to_position_id": "uuid",
  "effective_date": "2025-02-01",
  "transfer_type": "LATERAL",
  "reason": "Organizational restructure"
}
```

**Response** (201 Created):
```json
{
  "old_assignment_id": "uuid",
  "new_assignment_id": "uuid",
  "transfer_type": "LATERAL",
  "effective_date": "2025-02-01"
}
```

**Business Rules**: BR-ASG-015

**Related FRs**: FR-ASG-015

---

## 📊 Phase 1: Basic Reporting

### Headcount Reports

#### GET /api/v1/reports/headcount
Get current headcount

**Authorization**: `HR_ADMIN`, `HR_MANAGER`, `MANAGER`

**Query Parameters**:
- `as_of_date`: date (default: today)
- `business_unit_id`: uuid (optional)
- `employment_type`: enum (optional)

**Response** (200 OK):
```json
{
  "as_of_date": "2025-12-03",
  "total_headcount": 1500,
  "total_fte": 1450.5,
  "by_employment_type": {
    "FULL_TIME": 1400,
    "PART_TIME": 100
  },
  "by_status": {
    "ACTIVE": 1500,
    "INACTIVE": 0
  }
}
```

**Related FRs**: FR-RPT-001

---

#### GET /api/v1/reports/employee-list
Get employee list

**Authorization**: `HR_ADMIN`, `HR_MANAGER`

**Query Parameters**:
- `business_unit_id`: uuid (optional)
- `job_id`: uuid (optional)
- `manager_id`: uuid (optional)
- `status`: enum (optional)
- `page`: integer
- `limit`: integer

**Response** (200 OK):
```json
{
  "employees": [
    {
      "employee_number": "EMP-000001",
      "full_name": "Nguyễn Văn An",
      "job_title": "Software Engineer",
      "department": "Engineering",
      "manager": "Trần Thị Bình",
      "hire_date": "2025-01-01",
      "status": "ACTIVE"
    }
  ],
  "pagination": {...}
}
```

**Related FRs**: FR-RPT-002

---

#### GET /api/v1/reports/org-chart
Get organization chart

**Authorization**: `HR_ADMIN`, `HR_MANAGER`, `MANAGER`

**Query Parameters**:
- `root_manager_id`: uuid (optional, default: CEO)
- `business_unit_id`: uuid (optional)
- `max_depth`: integer (optional, default: 5)

**Response** (200 OK):
```json
{
  "root": {
    "employee_id": "uuid",
    "employee_number": "EMP-000001",
    "full_name": "CEO Name",
    "job_title": "Chief Executive Officer",
    "direct_reports": [
      {
        "employee_id": "uuid",
        "full_name": "CTO Name",
        "job_title": "Chief Technology Officer",
        "direct_reports": [...]
      }
    ]
  }
}
```

**Related FRs**: FR-RPT-003

---

#### GET /api/v1/reports/turnover
Get turnover report

**Authorization**: `HR_ADMIN`, `HR_MANAGER`

**Query Parameters**:
- `start_date`: date (required)
- `end_date`: date (required)
- `business_unit_id`: uuid (optional)

**Response** (200 OK):
```json
{
  "period": {
    "start_date": "2025-01-01",
    "end_date": "2025-12-31"
  },
  "turnover_rate": 12.5,
  "voluntary_turnover_rate": 8.3,
  "involuntary_turnover_rate": 4.2,
  "terminations": 150,
  "average_headcount": 1200,
  "by_department": [...]
}
```

**Related FRs**: FR-RPT-011

---

## 🏢 Phase 2: Business Unit Management

### Business Unit CRUD

#### POST /api/v1/business-units
Create business unit

**Authorization**: `HR_ADMIN`, `SYSTEM_ADMIN`

**Request**:
```json
{
  "code": "ENG",
  "name": "Engineering",
  "unit_type": "OPERATIONAL",
  "parent_unit_id": "uuid",
  "manager_id": "uuid",
  "effective_start_date": "2025-01-01"
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "code": "ENG",
  "name": "Engineering",
  "unit_type": "OPERATIONAL",
  "hierarchy_path": "/1/5/12/",
  "created_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-BU-001, BR-BU-002

**Related FRs**: FR-BU-001

---

#### GET /api/v1/business-units/hierarchy-tree
Get business unit hierarchy

**Authorization**: `HR_ADMIN`, `HR_MANAGER`, `MANAGER`, `EMPLOYEE`

**Query Parameters**:
- `root_unit_id`: uuid (optional)
- `unit_type`: enum (optional)
- `include_inactive`: boolean (default: false)

**Response** (200 OK):
```json
{
  "root": {
    "id": "uuid",
    "code": "COMPANY",
    "name": "Company",
    "unit_type": "OPERATIONAL",
    "manager": {...},
    "headcount": 1500,
    "children": [
      {
        "id": "uuid",
        "code": "ENG",
        "name": "Engineering",
        "headcount": 500,
        "children": [...]
      }
    ]
  }
}
```

**Related FRs**: FR-BU-025

---

#### GET /api/v1/business-units/{id}/headcount
Get business unit headcount

**Authorization**: `HR_ADMIN`, `HR_MANAGER`, `MANAGER`

**Response** (200 OK):
```json
{
  "business_unit_id": "uuid",
  "business_unit_name": "Engineering",
  "direct_headcount": 50,
  "total_headcount": 500,
  "direct_fte": 48.5,
  "total_fte": 485.0,
  "by_job": [...]
}
```

**Related FRs**: FR-BU-026

---

## 💼 Phase 2: Job Taxonomy Management

### Job Taxonomy CRUD

#### POST /api/v1/taxonomy-trees
Create taxonomy tree

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "code": "FUNCTIONAL",
  "name": "Functional Job Taxonomy",
  "description": "Jobs organized by function",
  "tree_type": "FUNCTIONAL"
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "code": "FUNCTIONAL",
  "name": "Functional Job Taxonomy",
  "created_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-TAX-001

**Related FRs**: FR-TAX-001

---

#### POST /api/v1/job-taxonomies
Create job taxonomy (job family/group)

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "taxonomy_tree_id": "uuid",
  "code": "ENG",
  "name": "Engineering",
  "parent_taxonomy_id": "uuid",
  "description": "Engineering job family"
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "code": "ENG",
  "name": "Engineering",
  "hierarchy_level": 2,
  "hierarchy_path": "/1/5/",
  "created_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-TAX-002, BR-TAX-003

**Related FRs**: FR-TAX-002

---

#### POST /api/v1/jobs
Create job

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "code": "SWE-SR",
  "title": "Senior Software Engineer",
  "job_taxonomy_id": "uuid",
  "job_level": "SENIOR",
  "job_grade": "G7",
  "description": "Senior software engineering role"
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "code": "SWE-SR",
  "title": "Senior Software Engineer",
  "job_family": "Engineering",
  "created_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-TAX-005

**Related FRs**: FR-TAX-005

---

#### GET /api/v1/jobs/catalog
Get job catalog

**Authorization**: `EMPLOYEE`, `HR_ADMIN`, `HR_MANAGER`

**Query Parameters**:
- `job_family`: string (optional)
- `job_level`: enum (optional)
- `job_grade`: enum (optional)

**Response** (200 OK):
```json
{
  "jobs": [
    {
      "id": "uuid",
      "code": "SWE-SR",
      "title": "Senior Software Engineer",
      "job_family": "Engineering",
      "job_level": "SENIOR",
      "job_grade": "G7",
      "description": "..."
    }
  ]
}
```

**Related FRs**: FR-TAX-022

---

## 📝 Phase 2: Job Profile Management

### Job Profile CRUD

#### POST /api/v1/job-profiles
Create job profile

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "job_id": "uuid",
  "job_description": "Detailed job description...",
  "job_purpose": "Purpose of this role...",
  "effective_start_date": "2025-01-01"
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "job_id": "uuid",
  "version": 1,
  "created_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-PRF-001

**Related FRs**: FR-PRF-001

---

#### POST /api/v1/job-profiles/{id}/skills
Add required skills to job profile

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "skills": [
    {
      "skill_id": "uuid",
      "proficiency_level": "ADVANCED",
      "is_required": true,
      "skill_category": "TECHNICAL"
    }
  ]
}
```

**Response** (201 Created):
```json
{
  "job_profile_id": "uuid",
  "skills_added": 5,
  "updated_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-PRF-020

**Related FRs**: FR-PRF-006

---

#### GET /api/v1/job-profiles/{id}/export
Export job profile

**Authorization**: `HR_ADMIN`, `HR_MANAGER`

**Query Parameters**:
- `format`: enum (PDF, WORD, EXCEL)

**Response** (200 OK):
```
Content-Type: application/pdf
Content-Disposition: attachment; filename="job-profile-swe-sr.pdf"

[Binary PDF content]
```

**Related FRs**: FR-PRF-026

---

## 📍 Phase 2: Position Management

### Position CRUD

#### POST /api/v1/positions
Create position

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "code": "POS-ENG-001",
  "title": "Senior Software Engineer - Backend",
  "job_id": "uuid",
  "business_unit_id": "uuid",
  "location_id": "uuid",
  "status": "VACANT",
  "headcount_limit": 1,
  "effective_start_date": "2025-01-01"
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "code": "POS-ENG-001",
  "title": "Senior Software Engineer - Backend",
  "status": "VACANT",
  "created_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-POS-001, BR-POS-002

**Related FRs**: FR-POS-001

---

#### POST /api/v1/positions/{id}/freeze
Freeze position

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "freeze_reason": "Budget constraints",
  "freeze_date": "2025-12-03"
}
```

**Response** (200 OK):
```json
{
  "id": "uuid",
  "status": "FROZEN",
  "freeze_date": "2025-12-03",
  "freeze_reason": "Budget constraints"
}
```

**Business Rules**: BR-POS-021

**Related FRs**: FR-POS-006

---

#### GET /api/v1/positions/vacancies
Get vacancy report

**Authorization**: `HR_ADMIN`, `HR_MANAGER`

**Query Parameters**:
- `business_unit_id`: uuid (optional)
- `job_id`: uuid (optional)
- `critical_only`: boolean (default: false)

**Response** (200 OK):
```json
{
  "vacancies": [
    {
      "position_id": "uuid",
      "position_code": "POS-ENG-001",
      "position_title": "Senior Software Engineer",
      "business_unit": "Engineering",
      "job_title": "Senior Software Engineer",
      "vacant_since": "2025-01-01",
      "vacancy_duration_days": 335,
      "is_critical": true
    }
  ],
  "total_vacancies": 25
}
```

**Related FRs**: FR-POS-016

---

## 🔀 Phase 2: Matrix Reporting

### Manager Relationships

#### POST /api/v1/assignments/{id}/solid-line-manager
Assign solid line manager

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "manager_id": "uuid",
  "effective_date": "2025-01-01"
}
```

**Response** (200 OK):
```json
{
  "assignment_id": "uuid",
  "manager_id": "uuid",
  "manager_type": "SOLID_LINE",
  "effective_date": "2025-01-01"
}
```

**Business Rules**: BR-MTX-001, BR-ASG-004

**Related FRs**: FR-MTX-001

---

#### POST /api/v1/assignments/{id}/dotted-line-manager
Assign dotted line manager

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "manager_id": "uuid",
  "effective_date": "2025-01-01",
  "time_allocation_pct": 30
}
```

**Response** (200 OK):
```json
{
  "assignment_id": "uuid",
  "manager_id": "uuid",
  "manager_type": "DOTTED_LINE",
  "time_allocation_pct": 30,
  "effective_date": "2025-01-01"
}
```

**Business Rules**: BR-MTX-002

**Related FRs**: FR-MTX-002

---

#### GET /api/v1/employees/{id}/reporting-chain
Get employee reporting chain

**Authorization**: `HR_ADMIN`, `HR_MANAGER`, `MANAGER`, `EMPLOYEE` (self)

**Response** (200 OK):
```json
{
  "employee_id": "uuid",
  "reporting_chain": [
    {
      "level": 1,
      "employee_id": "uuid",
      "employee_number": "EMP-000010",
      "full_name": "Direct Manager",
      "job_title": "Engineering Manager"
    },
    {
      "level": 2,
      "employee_id": "uuid",
      "employee_number": "EMP-000005",
      "full_name": "Director",
      "job_title": "Director of Engineering"
    }
  ]
}
```

**Related FRs**: FR-MTX-005

---

#### GET /api/v1/managers/{id}/direct-reports
Get manager's direct reports

**Authorization**: `HR_ADMIN`, `HR_MANAGER`, `MANAGER` (self)

**Response** (200 OK):
```json
{
  "manager_id": "uuid",
  "direct_reports": [
    {
      "employee_id": "uuid",
      "employee_number": "EMP-000020",
      "full_name": "Nguyễn Văn An",
      "job_title": "Software Engineer",
      "assignment_start_date": "2025-01-01"
    }
  ],
  "total_direct_reports": 8
}
```

**Business Rules**: BR-MTX-003

**Related FRs**: FR-MTX-006

---

## 🎓 Phase 3: Skill Catalog Management

### Skill CRUD

#### POST /api/v1/skills
Create skill

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "code": "PYTHON",
  "name": "Python Programming",
  "description": "Python programming language",
  "skill_category": "TECHNICAL",
  "taxonomy_id": "uuid"
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "code": "PYTHON",
  "name": "Python Programming",
  "skill_category": "TECHNICAL",
  "created_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-SKL-001

**Related FRs**: FR-SKL-001

---

#### GET /api/v1/skills/catalog
Get skill catalog

**Authorization**: `EMPLOYEE`, `HR_ADMIN`, `HR_MANAGER`

**Query Parameters**:
- `category`: enum (optional)
- `taxonomy_id`: uuid (optional)

**Response** (200 OK):
```json
{
  "skills": [
    {
      "id": "uuid",
      "code": "PYTHON",
      "name": "Python Programming",
      "category": "TECHNICAL",
      "taxonomy": "Programming Languages",
      "description": "..."
    }
  ]
}
```

**Related FRs**: FR-SKL-016

---

## 📊 Phase 3: Skill Assessment Management

### Employee Skill Management

#### POST /api/v1/employees/{id}/skills
Assign skill to employee

**Authorization**: `HR_ADMIN`, `MANAGER`

**Request**:
```json
{
  "skill_id": "uuid",
  "proficiency_level": "ADVANCED",
  "assessment_source": "MANAGER_ASSESSED",
  "assessment_date": "2025-12-03",
  "comments": "Strong Python skills demonstrated"
}
```

**Response** (201 Created):
```json
{
  "employee_id": "uuid",
  "skill_id": "uuid",
  "proficiency_level": "ADVANCED",
  "assessment_source": "MANAGER_ASSESSED",
  "assessed_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-ASS-001

**Related FRs**: FR-ASS-001

---

#### POST /api/v1/employees/me/skills/self-assess
Self-assess skill

**Authorization**: `EMPLOYEE`

**Request**:
```json
{
  "skill_id": "uuid",
  "proficiency_level": "INTERMEDIATE",
  "comments": "Self-assessed proficiency"
}
```

**Response** (201 Created):
```json
{
  "employee_id": "uuid",
  "skill_id": "uuid",
  "proficiency_level": "INTERMEDIATE",
  "assessment_source": "SELF_ASSESSED",
  "requires_approval": true
}
```

**Business Rules**: BR-ASS-015

**Related FRs**: FR-ASS-005

---

#### GET /api/v1/employees/{id}/skill-gaps
Get skill gap analysis

**Authorization**: `HR_ADMIN`, `HR_MANAGER`, `MANAGER`, `EMPLOYEE` (self)

**Response** (200 OK):
```json
{
  "employee_id": "uuid",
  "current_job": {...},
  "required_skills": [
    {
      "skill_id": "uuid",
      "skill_name": "Python",
      "required_level": "ADVANCED",
      "current_level": "INTERMEDIATE",
      "gap": "1 level",
      "gap_severity": "MEDIUM"
    }
  ],
  "missing_skills": [
    {
      "skill_id": "uuid",
      "skill_name": "Kubernetes",
      "required_level": "INTERMEDIATE"
    }
  ],
  "development_recommendations": [...]
}
```

**Business Rules**: BR-ASS-020

**Related FRs**: FR-ASS-010

---

#### GET /api/v1/employees/search-by-skill
Search employees by skill

**Authorization**: `HR_ADMIN`, `HR_MANAGER`, `MANAGER`

**Query Parameters**:
- `skill_id`: uuid (required)
- `min_proficiency`: enum (optional)
- `business_unit_id`: uuid (optional)

**Response** (200 OK):
```json
{
  "skill": {...},
  "employees": [
    {
      "employee_id": "uuid",
      "employee_number": "EMP-000001",
      "full_name": "Nguyễn Văn An",
      "proficiency_level": "ADVANCED",
      "assessment_date": "2025-12-03"
    }
  ]
}
```

**Related FRs**: FR-ASS-026

---

## 🎯 Phase 3: Career Paths Management

### Career Path CRUD

#### POST /api/v1/career-ladders
Create career ladder

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "name": "Technical Career Ladder",
  "ladder_type": "TECHNICAL",
  "description": "Career progression for technical roles"
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "name": "Technical Career Ladder",
  "ladder_type": "TECHNICAL",
  "created_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-CAR-001

**Related FRs**: FR-CAR-001

---

#### POST /api/v1/career-paths
Create career path

**Authorization**: `HR_ADMIN`

**Request**:
```json
{
  "starting_level_id": "uuid",
  "target_level_id": "uuid",
  "path_type": "VERTICAL",
  "typical_duration_months": 24,
  "description": "Path from Mid to Senior Engineer"
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "starting_level": "Mid Engineer",
  "target_level": "Senior Engineer",
  "path_type": "VERTICAL",
  "created_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-CAR-010

**Related FRs**: FR-CAR-005

---

#### GET /api/v1/employees/me/career-paths
Get my career path options

**Authorization**: `EMPLOYEE`

**Response** (200 OK):
```json
{
  "current_job": {...},
  "current_level": "Mid Engineer",
  "available_paths": [
    {
      "path_id": "uuid",
      "target_level": "Senior Engineer",
      "path_type": "VERTICAL",
      "typical_duration": "24 months",
      "requirements": [...],
      "my_readiness": "60%"
    }
  ]
}
```

**Related FRs**: FR-CAR-010

---

#### GET /api/v1/employees/me/career-readiness/{pathId}
Get career readiness assessment

**Authorization**: `EMPLOYEE`

**Response** (200 OK):
```json
{
  "path": {...},
  "readiness_score": 60,
  "skill_gaps": [...],
  "experience_gaps": [...],
  "development_recommendations": [
    "Complete Python advanced course",
    "Lead 2 major projects",
    "Mentor junior engineers"
  ]
}
```

**Business Rules**: BR-CAR-015

**Related FRs**: FR-CAR-011

---

## 🔒 Phase 3: Data Privacy & Security

### Privacy Rights (GDPR/PDPA)

#### GET /api/v1/employees/me/personal-data
Right to access (GDPR Article 15)

**Authorization**: `EMPLOYEE`

**Response** (200 OK):
```json
{
  "employee_id": "uuid",
  "data_subject": {...},
  "personal_data": {
    "worker": {...},
    "work_relationship": {...},
    "employee": {...},
    "assignments": [...],
    "skills": [...]
  },
  "processing_activities": [...],
  "data_sources": [...],
  "data_recipients": [...],
  "generated_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-PRI-020

**Related FRs**: FR-PRI-010

---

#### POST /api/v1/employees/me/rectification-request
Right to rectification (GDPR Article 16)

**Authorization**: `EMPLOYEE`

**Request**:
```json
{
  "field": "phone",
  "current_value": "+84901234567",
  "requested_value": "+84909876543",
  "reason": "Phone number changed"
}
```

**Response** (201 Created):
```json
{
  "request_id": "uuid",
  "status": "PENDING_REVIEW",
  "submitted_at": "2025-12-03T10:00:00Z",
  "sla_deadline": "2025-12-13T10:00:00Z"
}
```

**Business Rules**: BR-PRI-021

**Related FRs**: FR-PRI-011

---

#### POST /api/v1/employees/me/erasure-request
Right to erasure (GDPR Article 17)

**Authorization**: `EMPLOYEE`

**Request**:
```json
{
  "reason": "No longer employed",
  "data_categories": ["ALL"]
}
```

**Response** (201 Created):
```json
{
  "request_id": "uuid",
  "status": "PENDING_REVIEW",
  "legal_review_required": true,
  "submitted_at": "2025-12-03T10:00:00Z",
  "sla_deadline": "2025-12-13T10:00:00Z"
}
```

**Business Rules**: BR-PRI-022

**Related FRs**: FR-PRI-012

---

#### GET /api/v1/employees/me/export
Data portability (GDPR Article 20)

**Authorization**: `EMPLOYEE`

**Query Parameters**:
- `format`: enum (JSON, CSV)

**Response** (200 OK):
```
Content-Type: application/json
Content-Disposition: attachment; filename="my-data.json"

{
  "employee": {...},
  "assignments": [...],
  "skills": [...],
  "exported_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-PRI-060

**Related FRs**: FR-PRI-027

---

### Consent Management

#### POST /api/v1/employees/{id}/consent
Manage data processing consent

**Authorization**: `HR_ADMIN`, `EMPLOYEE` (self)

**Request**:
```json
{
  "consent_type": "DATA_PROCESSING",
  "purpose": "Performance management",
  "granted": true,
  "consent_date": "2025-12-03"
}
```

**Response** (201 Created):
```json
{
  "consent_id": "uuid",
  "employee_id": "uuid",
  "consent_type": "DATA_PROCESSING",
  "purpose": "Performance management",
  "granted": true,
  "consent_date": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-PRI-010

**Related FRs**: FR-PRI-003

---

### Data Breach Management

#### POST /api/v1/data-breaches
Report data breach

**Authorization**: `DPO`, `SYSTEM_ADMIN`

**Request**:
```json
{
  "breach_type": "UNAUTHORIZED_ACCESS",
  "affected_data_categories": ["PERSONAL_DATA"],
  "affected_individuals_count": 150,
  "breach_date": "2025-12-03",
  "description": "Unauthorized access to employee database",
  "severity": "HIGH"
}
```

**Response** (201 Created):
```json
{
  "breach_id": "uuid",
  "breach_type": "UNAUTHORIZED_ACCESS",
  "status": "UNDER_INVESTIGATION",
  "notification_deadline": "2025-12-06T10:00:00Z",
  "created_at": "2025-12-03T10:00:00Z"
}
```

**Business Rules**: BR-PRI-041

**Related FRs**: FR-PRI-021

---

### Privacy Compliance

#### GET /api/v1/reports/privacy-compliance
Get privacy compliance report

**Authorization**: `DPO`, `SYSTEM_ADMIN`

**Query Parameters**:
- `start_date`: date
- `end_date`: date

**Response** (200 OK):
```json
{
  "period": {...},
  "data_classification_coverage": 100,
  "consent_status": {
    "total_consents": 1500,
    "granted": 1450,
    "denied": 50
  },
  "data_retention_compliance": 98.5,
  "access_requests": {
    "total": 25,
    "completed": 24,
    "pending": 1
  },
  "breaches": {
    "total": 0
  },
  "audit_log_summary": {...}
}
```

**Related FRs**: FR-PRI-030

---

## 📋 Common Response Formats

### Success Response

```json
{
  "data": {...},
  "metadata": {
    "timestamp": "2025-12-03T10:00:00Z",
    "version": "v1"
  }
}
```

### Error Response

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "date_of_birth",
        "message": "Must be a past date"
      }
    ]
  },
  "metadata": {
    "timestamp": "2025-12-03T10:00:00Z",
    "request_id": "uuid"
  }
}
```

### Pagination

```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "pages": 8,
    "has_next": true,
    "has_prev": false
  }
}
```

---

## 🔒 Security

### Authentication

All endpoints require Bearer token authentication:

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Data Classification

Responses are filtered based on user role and data classification:

| Classification | Accessible By |
|----------------|---------------|
| PUBLIC | All authenticated users |
| INTERNAL | Same organization |
| CONFIDENTIAL | Manager + HR |
| RESTRICTED | HR only (with purpose) |

### Rate Limiting

- **Standard**: 1000 requests/hour
- **Reporting**: 100 requests/hour
- **Bulk operations**: 10 requests/hour

---

## 📚 Related Documentation

- [Functional Requirements](./01-functional-requirements.md) - Source of all API endpoints
- [Business Rules](./04-business-rules.md) - Validation and business logic
- [Data Specification](./03-data-specification.md) - Data models and validation
- [Core Ontology](../00-ontology/core-ontology.yaml) - Entity definitions
- [OpenAPI Specification](../05-api/openapi.yaml) - Technical API spec (to be generated)

---

**Document Version**: 2.0  
**Created**: 2025-12-03  
**Based On**: 450 Functional Requirements  
**Maintained By**: Product Team + Engineering Team  
**Status**: Complete - Ready for OpenAPI Generation
