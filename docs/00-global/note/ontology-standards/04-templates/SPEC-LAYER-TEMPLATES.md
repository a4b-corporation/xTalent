# Specification Layer Templates

**Version**: 3.0  
**Layer**: 02-spec  
**Audience**: BAs, Developers, QA

---

## 🎯 Purpose

The Specification Layer is the **contract between Business and Development**:

- **Ontology** tells WHAT exists
- **Concept** tells HOW it works
- **Specification** tells EXACTLY what to build ← **Handoff Point**

This layer contains everything a developer needs to implement a feature.

---

## 📐 Layer Structure

```
02-spec/
├── README.md                    # Spec index & status
│
├── 01-FR/                       # Functional Requirements
│   ├── README.md                # FR index
│   └── FR-[NN]-[submodule].md   # Per-submodule FRs
│
├── 02-API/                      # API Specifications
│   ├── README.md
│   ├── openapi.yaml             # Full OpenAPI spec
│   └── [entity]-api.yaml        # Per-entity API (optional)
│
├── 03-DATA/                     # Data Specifications
│   ├── README.md
│   ├── data-dictionary.yaml     # Field definitions
│   └── validation-rules.yaml    # Cross-entity validation
│
├── 04-BR/                       # Business Rules
│   ├── README.md                # BR index
│   └── BR-[NN]-[submodule].br.yaml
│
├── 05-BDD/                      # BDD Scenarios
│   ├── [NN]-[submodule]/
│   │   └── [entity].feature
│   └── ...
│
├── 06-SECURITY/                 # Security Requirements
│   └── security-spec.md
│
├── INTEGRATION-GUIDE.md         # Dev handoff guide
└── FEATURE-LIST.yaml            # Feature breakdown
```

---

## 📋 Template S1: Functional Requirements

**File**: `02-spec/01-FR/FR-01-workforce.md`

```markdown
# Functional Requirements - Workforce

**Module**: CORE-HR  
**Submodule**: workforce  
**Version**: 2.0  
**Status**: APPROVED  
**Last Updated**: 2024-12-24

---

## Overview

**Total Requirements**: 15  
**By Priority**: MUST (8), SHOULD (5), COULD (2)  
**By Status**: Approved (12), Draft (3)

---

## FR-WF-001: Create Employee Record

**Priority**: MUST  
**Status**: APPROVED  
**Complexity**: Medium

### Description

The system shall allow authorized users to create a new employee record 
with all required information.

### Actors

- HR Specialist
- HR Manager
- System (via API)

### Preconditions

1. User is authenticated
2. User has `employee.create` permission
3. Target department exists and is active

### Input Data

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| first_name | string | Yes | 1-100 chars |
| last_name | string | Yes | 1-100 chars |
| email | string | Yes | Valid email, unique |
| hire_date | date | Yes | Not future, ≥ 1990 |
| department_id | uuid | Yes | Must exist |
| employment_type | enum | Yes | FULL_TIME, PART_TIME, etc. |

### Processing

1. Validate all input fields
2. Check email uniqueness
3. Generate employee_code (EMP + 6 digits)
4. Create employee record with status = DRAFT
5. Create audit log entry
6. Return created employee

### Output

**Success (201)**:
```json
{
  "id": "uuid",
  "employee_code": "EMP000001",
  "status": "DRAFT",
  "created_at": "2024-12-24T10:00:00Z"
}
```

**Errors**:
| Code | HTTP | Condition |
|------|------|-----------|
| ERR_DUPLICATE_EMAIL | 409 | Email already exists |
| ERR_FUTURE_HIRE_DATE | 400 | Hire date in future |
| ERR_DEPARTMENT_NOT_FOUND | 404 | Department doesn't exist |

### Business Rules

- BR-WF-001: Hire date cannot be future
- BR-WF-005: Minimum age 16

### Acceptance Criteria

```gherkin
Given I am logged in as HR Specialist
When I create an employee with valid data
Then the employee should be created with status DRAFT
And an employee code should be generated
And I should receive the employee details
```

### Traceability

| Artifact | Reference |
|----------|-----------|
| Entity | xtalent:core-hr:workforce:employee |
| BDD | employee.feature#create-employee |
| API | POST /employees |
| BR | BR-WF-001, BR-WF-005 |

---

## FR-WF-002: Activate Employee

**Priority**: MUST  
**Status**: APPROVED  
**Complexity**: Medium

### Description

The system shall allow transitioning an employee from DRAFT to ACTIVE 
status when all prerequisites are met.

### Actors

- HR Specialist
- HR Manager

### Preconditions

1. Employee exists with status = DRAFT
2. Employee has department assigned
3. Employee has at least one active assignment
4. User has `employee.activate` permission

### Processing

1. Validate preconditions
2. Update status to ACTIVE
3. Set activation_date = current_date
4. Publish EmployeeActivated event
5. Trigger downstream integrations (IT, Payroll)
6. Create audit log entry

### Output

**Success (200)**:
```json
{
  "id": "uuid",
  "status": "ACTIVE",
  "activation_date": "2024-12-24"
}
```

**Errors**:
| Code | HTTP | Condition |
|------|------|-----------|
| ERR_INVALID_STATUS | 400 | Not in DRAFT status |
| ERR_ACTIVATION_NO_DEPARTMENT | 400 | No department |
| ERR_ACTIVATION_NO_ASSIGNMENT | 400 | No active assignment |

### Business Rules

- BR-WF-030: Activation requires department
- BR-WF-031: Activation requires assignment

### Side Effects

1. **IT Integration**: Trigger account provisioning
2. **Payroll Integration**: Create payroll record
3. **Notification**: Send welcome email to employee
4. **Notification**: Notify manager

### Acceptance Criteria

```gherkin
Given an employee in DRAFT status
And the employee has a department assigned
And the employee has an active assignment
When I activate the employee
Then the status should be ACTIVE
And IT should receive provisioning request
And Payroll should receive employee data
```

---

## FR-WF-003: Terminate Employee

[Continue with same structure...]

---

## Traceability Matrix

| FR ID | Entity | Actions | BR | BDD | API | Status |
|-------|--------|---------|----|----|-----|--------|
| FR-WF-001 | Employee | create | BR-001,005 | create-employee | POST /employees | ✅ |
| FR-WF-002 | Employee | activate | BR-030,031 | activate-employee | POST /employees/{id}/activate | ✅ |
| FR-WF-003 | Employee | terminate | BR-002,004 | terminate-employee | POST /employees/{id}/terminate | ✅ |

---

## References

- **Ontology**: [../../00-ontology/domain/01-workforce/](../../00-ontology/domain/01-workforce/)
- **Concept Guide**: [../../01-concept/02-workforce/](../../01-concept/02-workforce/)
- **Business Rules**: [../04-BR/BR-01-workforce.br.yaml](../04-BR/BR-01-workforce.br.yaml)
- **API Spec**: [../02-API/openapi.yaml](../02-API/openapi.yaml)
- **BDD**: [../05-BDD/01-workforce/](../05-BDD/01-workforce/)
```

---

## 📋 Template S2: API Specification

**File**: `02-spec/02-API/openapi.yaml`

```yaml
# OpenAPI 3.0 Specification
# Generated from: xtalent:core-hr:workforce entities and actions

openapi: "3.0.3"
info:
  title: Core HR - Workforce API
  version: "2.0.0"
  description: |
    API for managing employee records, assignments, and related workforce data.
    
    ## Overview
    This API provides CRUD operations for core workforce entities plus 
    lifecycle management (activate, deactivate, terminate).
    
    ## Authentication
    All endpoints require Bearer token authentication.
    
    ## Traceability
    - Module: CORE-HR
    - Submodule: workforce
    - Entity: xtalent:core-hr:workforce:employee

servers:
  - url: https://api.xtalent.io/v2
    description: Production
  - url: https://api-staging.xtalent.io/v2
    description: Staging

tags:
  - name: Employees
    description: Employee management operations

paths:
  /employees:
    get:
      operationId: listEmployees
      summary: List employees
      description: |
        Retrieve a paginated list of employees with optional filtering.
        
        **Traceability**: FR-WF-010
      tags: [Employees]
      parameters:
        - name: status
          in: query
          schema:
            type: string
            enum: [DRAFT, ACTIVE, INACTIVE, TERMINATED]
        - name: department_id
          in: query
          schema:
            type: string
            format: uuid
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: per_page
          in: query
          schema:
            type: integer
            default: 20
            maximum: 100
      responses:
        "200":
          description: List of employees
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/EmployeeList"
        "401":
          $ref: "#/components/responses/Unauthorized"

    post:
      operationId: createEmployee
      summary: Create employee
      description: |
        Create a new employee record. The employee is created in DRAFT status.
        
        **Traceability**: FR-WF-001
        **Business Rules**: BR-WF-001, BR-WF-005
      tags: [Employees]
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/CreateEmployeeRequest"
      responses:
        "201":
          description: Employee created
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Employee"
        "400":
          $ref: "#/components/responses/ValidationError"
        "409":
          description: Duplicate email
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Error"
              example:
                error_code: "ERR_DUPLICATE_EMAIL"
                message: "Email already exists"

  /employees/{id}:
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: string
          format: uuid
          
    get:
      operationId: getEmployee
      summary: Get employee by ID
      tags: [Employees]
      responses:
        "200":
          description: Employee details
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Employee"
        "404":
          $ref: "#/components/responses/NotFound"

    put:
      operationId: updateEmployee
      summary: Update employee
      tags: [Employees]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/UpdateEmployeeRequest"
      responses:
        "200":
          description: Employee updated
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Employee"

  /employees/{id}/activate:
    post:
      operationId: activateEmployee
      summary: Activate employee
      description: |
        Transition employee from DRAFT to ACTIVE status.
        
        **Traceability**: FR-WF-002, Action: activate-employee
        **Business Rules**: BR-WF-030, BR-WF-031
        **Side Effects**: IT provisioning, Payroll creation
      tags: [Employees]
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        "200":
          description: Employee activated
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Employee"
        "400":
          description: Cannot activate
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Error"
              examples:
                no_department:
                  value:
                    error_code: "ERR_ACTIVATION_NO_DEPARTMENT"
                    message: "Employee must be assigned to a department"
                no_assignment:
                  value:
                    error_code: "ERR_ACTIVATION_NO_ASSIGNMENT"
                    message: "Employee must have at least one active assignment"

  /employees/{id}/terminate:
    post:
      operationId: terminateEmployee
      summary: Terminate employee
      description: |
        End employee's employment.
        
        **Traceability**: FR-WF-003, Action: terminate-employee
        **Business Rules**: BR-WF-002, BR-WF-004
      tags: [Employees]
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
            format: uuid
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/TerminateEmployeeRequest"
      responses:
        "200":
          description: Employee terminated

components:
  schemas:
    Employee:
      type: object
      description: |
        Employee entity representation.
        **Entity Ref**: xtalent:core-hr:workforce:employee
      properties:
        id:
          type: string
          format: uuid
        employee_code:
          type: string
          pattern: "^EMP[0-9]{6}$"
        first_name:
          type: string
        last_name:
          type: string
        full_name:
          type: string
          readOnly: true
          description: "Derived: first_name + last_name"
        email:
          type: string
          format: email
        status:
          type: string
          enum: [DRAFT, ACTIVE, INACTIVE, TERMINATED]
        hire_date:
          type: string
          format: date
        years_of_service:
          type: number
          readOnly: true
          description: "Derived: calculated from hire_date"
        department:
          $ref: "#/components/schemas/DepartmentRef"
        created_at:
          type: string
          format: date-time
        updated_at:
          type: string
          format: date-time

    CreateEmployeeRequest:
      type: object
      required:
        - first_name
        - last_name
        - email
        - hire_date
        - department_id
        - employment_type
      properties:
        first_name:
          type: string
          minLength: 1
          maxLength: 100
        last_name:
          type: string
          minLength: 1
          maxLength: 100
        email:
          type: string
          format: email
        hire_date:
          type: string
          format: date
          description: "Cannot be in future (BR-WF-001)"
        department_id:
          type: string
          format: uuid
        employment_type:
          type: string
          enum: [FULL_TIME, PART_TIME, CONTRACT, INTERN, TEMPORARY]

    TerminateEmployeeRequest:
      type: object
      required:
        - termination_date
        - termination_reason
        - eligible_for_rehire
      properties:
        termination_date:
          type: string
          format: date
          description: "Must be >= hire_date (BR-WF-002)"
        termination_reason:
          type: string
          enum: [VOLUNTARY_RESIGNATION, INVOLUNTARY_TERMINATION, RETIREMENT, END_OF_CONTRACT, DEATH, OTHER]
        eligible_for_rehire:
          type: boolean
        notes:
          type: string
          maxLength: 2000

    Error:
      type: object
      properties:
        error_code:
          type: string
        message:
          type: string
        details:
          type: object

  responses:
    Unauthorized:
      description: Authentication required
    NotFound:
      description: Resource not found
    ValidationError:
      description: Validation failed

  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
```

---

## 📋 Template S3: Integration Guide (Dev Handoff)

**File**: `02-spec/INTEGRATION-GUIDE.md`

```markdown
# Integration Guide - Developer Handoff

**Module**: CORE-HR  
**Version**: 2.0  
**Last Updated**: 2024-12-24  
**Author**: BA Team

---

## 🎯 Purpose

This guide provides developers with everything needed to implement 
the Core HR Workforce module. It serves as the primary handoff document 
from BA/PO to Development team.

---

## 📚 Required Reading (In Order)

1. **Business Context**
   - [Module Overview](../01-concept/01-overview.md) — 15 min
   - [Glossary](../00-ontology/glossary/workforce.glossary.yaml) — 10 min

2. **Technical Foundation**
   - [Entity Definitions](../00-ontology/domain/01-workforce/) — 30 min
   - [API Specification](./02-API/openapi.yaml) — 20 min

3. **Business Logic**
   - [Business Rules](./04-BR/BR-01-workforce.br.yaml) — 20 min
   - [Functional Requirements](./01-FR/FR-01-workforce.md) — 30 min

4. **Testing**
   - [BDD Scenarios](./05-BDD/01-workforce/) — Review as needed

---

## 🏗️ Implementation Checklist

### Database

- [ ] Review [Entity Schema](../00-ontology/domain/01-workforce/employee.aggregate.yaml)
- [ ] Generate migration from entity definitions
- [ ] Implement SCD Type 2 for tracked attributes
- [ ] Create indexes as specified
- [ ] Set up audit triggers

**Reference**: [03-design/core-hr.dbml](../03-design/core-hr.dbml)

### API Endpoints

| Endpoint | FR | Action | Priority |
|----------|-----|--------|----------|
| POST /employees | FR-WF-001 | - | P0 |
| GET /employees | FR-WF-010 | - | P0 |
| GET /employees/{id} | FR-WF-011 | - | P0 |
| PUT /employees/{id} | FR-WF-012 | - | P0 |
| POST /employees/{id}/activate | FR-WF-002 | activate-employee | P0 |
| POST /employees/{id}/terminate | FR-WF-003 | terminate-employee | P0 |

**Reference**: [02-API/openapi.yaml](./02-API/openapi.yaml)

### Business Rules Implementation

| Rule | Implementation Point | Notes |
|------|---------------------|-------|
| BR-WF-001 | Create/Update validation | Check before save |
| BR-WF-002 | Update validation | Only on termination |
| BR-WF-003 | Update validation | Self-reference check |
| BR-WF-005 | Create/Update validation | Age calculation |
| BR-WF-030 | Activate action | Precondition |
| BR-WF-031 | Activate action | Precondition |

**Reference**: [04-BR/BR-01-workforce.br.yaml](./04-BR/BR-01-workforce.br.yaml)

### Integrations

| Integration | Trigger | Async | Priority |
|-------------|---------|-------|----------|
| IT Provisioning | Employee activated | Yes | P1 |
| Payroll Creation | Employee activated | Yes | P1 |
| Badge System | Employee activated | Yes | P2 |
| Notification Service | Various events | Yes | P1 |

---

## ⚠️ Critical Implementation Notes

### 1. Employee Code Generation

```
Pattern: EMP + 6-digit zero-padded sequence
Example: EMP000001, EMP000002, ...
Requirement: Thread-safe, no gaps preferred
```

### 2. SCD Type 2 Implementation

Track changes to these fields with history:
- `department_id`
- `manager_id`
- `status`
- `employment_type`

When changed:
1. Set `effective_end_date` on current record to yesterday
2. Create new record with `effective_start_date` = today
3. Set `is_current = true` on new record

### 3. Soft Delete

Never hard delete employee records. Use:
- `is_deleted = true`
- `deleted_at = timestamp`
- `deleted_by = user_id`

### 4. Status Transition Validation

```
DRAFT → ACTIVE: Only transition allowed from DRAFT
ACTIVE → INACTIVE: Allowed
ACTIVE → TERMINATED: Allowed
INACTIVE → ACTIVE: Allowed
INACTIVE → TERMINATED: Allowed
TERMINATED → *: Not allowed (terminal state)
```

---

## 🧪 Testing Requirements

### Unit Test Coverage

- All validation rules (BR-*)
- All derived attribute calculations
- State transitions

### Integration Test Coverage

- API endpoint contracts
- Database constraints
- External system integrations (mocked)

### BDD Test Coverage

All scenarios in [05-BDD/01-workforce/](./05-BDD/01-workforce/):
- employee.feature
- assignment.feature
- onboarding.feature (workflow)
- termination.feature (workflow)

---

## 📞 Contacts

| Role | Person | For Questions About |
|------|--------|---------------------|
| Product Owner | [Name] | Requirements, priority |
| Business Analyst | [Name] | Business rules, scenarios |
| Tech Lead | [Name] | Architecture, design |
| QA Lead | [Name] | Testing, acceptance |

---

## 📅 Timeline

| Milestone | Target Date | Dependencies |
|-----------|-------------|--------------|
| Database schema | Sprint 1 | - |
| CRUD endpoints | Sprint 1 | Database |
| Lifecycle actions | Sprint 2 | CRUD |
| Integrations | Sprint 2 | Lifecycle |
| QA | Sprint 3 | All above |

---

## 🔄 Change Log

| Date | Change | Author |
|------|--------|--------|
| 2024-12-24 | Initial version | BA Team |
```

---

## 📋 Template S4: Feature List

**File**: `02-spec/FEATURE-LIST.yaml`

```yaml
# Feature List - Workforce Module
# Used for sprint planning and tracking

$schema: "https://xtalent.io/schemas/feature-list/v3"
module: CORE-HR
submodule: workforce
version: "2.0"

features:
  - id: F-WF-001
    name: "Employee CRUD"
    description: "Create, read, update, delete employee records"
    priority: P0
    status: IN_PROGRESS
    sprint: 1
    
    user_stories:
      - id: US-001
        as_a: "HR Specialist"
        i_want: "to create a new employee record"
        so_that: "I can onboard new hires"
        acceptance_criteria:
          - "Can enter all required fields"
          - "Employee code is auto-generated"
          - "Status defaults to DRAFT"
        functional_requirements: [FR-WF-001]
        story_points: 5
        
      - id: US-002
        as_a: "HR Specialist"
        i_want: "to search and filter employees"
        so_that: "I can find specific employees quickly"
        functional_requirements: [FR-WF-010]
        story_points: 3
        
    entities: [Employee]
    api_endpoints:
      - POST /employees
      - GET /employees
      - GET /employees/{id}
      - PUT /employees/{id}
    business_rules: [BR-WF-001, BR-WF-003, BR-WF-005]
    
  - id: F-WF-002
    name: "Employee Lifecycle Management"
    description: "Activate, deactivate, terminate employees"
    priority: P0
    status: TODO
    sprint: 2
    
    user_stories:
      - id: US-003
        as_a: "HR Specialist"
        i_want: "to activate a new employee"
        so_that: "they can start working and access systems"
        acceptance_criteria:
          - "Can only activate from DRAFT status"
          - "Must have department assigned"
          - "Must have at least one assignment"
          - "Triggers IT provisioning"
          - "Triggers payroll creation"
        functional_requirements: [FR-WF-002]
        story_points: 8
        
      - id: US-004
        as_a: "HR Manager"
        i_want: "to terminate an employee"
        so_that: "employment ends properly with all documentation"
        functional_requirements: [FR-WF-003]
        story_points: 8
        
    entities: [Employee]
    actions: [activate-employee, deactivate-employee, terminate-employee]
    workflows: [WF-002-offboarding]
    business_rules: [BR-WF-002, BR-WF-004, BR-WF-030, BR-WF-031]

summary:
  total_features: 8
  total_stories: 24
  total_points: 85
  by_priority:
    P0: 3
    P1: 3
    P2: 2
  by_status:
    DONE: 2
    IN_PROGRESS: 1
    TODO: 5
```

---

## 🔗 Connection Points Summary

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     SPECIFICATION LAYER                                  │
│                                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
│  │     FR      │  │    API      │  │     BR      │  │    BDD      │   │
│  │ Requirements│  │   OpenAPI   │  │   Rules     │  │  Scenarios  │   │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘   │
│         │                │                │                │          │
│         └────────────────┴────────────────┴────────────────┘          │
│                                   │                                    │
│                    ┌──────────────┴──────────────┐                    │
│                    │    INTEGRATION-GUIDE.md     │                    │
│                    │    (Developer Handoff)      │                    │
│                    └──────────────┬──────────────┘                    │
│                                   │                                    │
└───────────────────────────────────┼────────────────────────────────────┘
                                    │
                                    ▼
┌───────────────────────────────────────────────────────────────────────────┐
│                          DEVELOPMENT TEAM                                  │
│                                                                            │
│   Backend Dev         Frontend Dev          QA Engineer                    │
│   ───────────        ─────────────         ────────────                   │
│   • API Spec         • API Spec            • BDD Scenarios                │
│   • BR → Code        • FR → UI             • BR → Test Cases              │
│   • Entity → DB      • API → Services      • FR → Acceptance              │
│                                                                            │
└───────────────────────────────────────────────────────────────────────────┘
```

---

## 📚 Related Documents

- [09-CONCEPT-LAYER-TEMPLATES.md](./09-CONCEPT-LAYER-TEMPLATES.md) — Concept templates
- [05-BUSINESS-RULES.md](./05-BUSINESS-RULES.md) — BR schema
- [06-BDD-INTEGRATION.md](./06-BDD-INTEGRATION.md) — BDD scenarios
- [10-DIRECTORY-STRUCTURE.md](./10-DIRECTORY-STRUCTURE.md) — File organization
