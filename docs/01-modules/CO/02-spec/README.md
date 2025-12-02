# Core Module (CO) - Specification Index

**Version**: 2.0  
**Last Updated**: 2025-12-02  
**Module**: Core (CO)  
**Phase**: Specification & Requirements

---

## 📚 Documentation Structure

This directory contains detailed specifications for the Core Module. Specifications translate conceptual designs into precise, implementable requirements for developers.

---

## 🎯 What is Specification Phase?

### Purpose

The **Specification Phase** bridges the gap between **Concept** (what the system should do) and **Implementation** (how to build it).

```
Concept (01-concept)
  ↓ Translate business requirements
Specification (02-spec)  ← YOU ARE HERE
  ↓ Implement technical details
Design (03-design)
  ↓ Build the system
Implementation (04-implementation)
```

### Deliverables

| Document Type | Purpose | Audience |
|---------------|---------|----------|
| **Functional Specs** | Detailed feature requirements | Developers, QA, Product |
| **API Specs** | REST API contracts | Backend developers, Frontend |
| **Data Specs** | Data models, validation rules | Database developers, Backend |
| **Business Rules** | Detailed business logic | Developers, Business analysts |
| **Use Case Scenarios** | End-to-end workflows | All stakeholders |
| **Integration Specs** | External system integration | Integration developers |

---

## 📖 Specification Documents

### Core Specifications

| Spec | Status | Description |
|------|--------|-------------|
| [Functional Requirements](./01-functional-requirements.md) | 📝 Planned | Detailed functional requirements for all features |
| [API Specification](./02-api-specification.md) | 📝 Planned | REST API endpoints, request/response formats |
| [Data Specification](./03-data-specification.md) | 📝 Planned | Data models, validation rules, constraints |
| [Business Rules Engine](./04-business-rules.md) | 📝 Planned | Detailed business logic and rules |
| [Integration Specification](./05-integration-spec.md) | 📝 Planned | Integration with external systems |
| [Security Specification](./06-security-spec.md) | 📝 Planned | Authentication, authorization, encryption |

### Use Case Scenarios

| Scenario | Status | Description |
|----------|--------|-------------|
| [Employment Scenarios](./03-scenarios/employment-scenarios.md) | 📝 Planned | Hire, transfer, promotion, termination |
| [Organization Scenarios](./03-scenarios/organization-scenarios.md) | 📝 Planned | Reorganization, manager change, matrix |
| [Job & Position Scenarios](./03-scenarios/job-position-scenarios.md) | 📝 Planned | Job creation, position management |
| [Skill Management Scenarios](./03-scenarios/skill-scenarios.md) | 📝 Planned | Skill assessment, gap analysis |
| [Data Privacy Scenarios](./03-scenarios/privacy-scenarios.md) | 📝 Planned | DSAR, consent management, breach response |

---

## 🏗️ Specification Structure

### 1. Functional Requirements

**Purpose**: Define WHAT the system must do.

**Structure**:
```yaml
Feature: [Feature Name]
  
  Overview:
    - Description
    - Business value
    - User stories
  
  Requirements:
    FR-001: [Requirement description]
      Priority: HIGH/MEDIUM/LOW
      User Story: "As a [role], I want [action] so that [benefit]"
      Acceptance Criteria:
        - Given [context]
        - When [action]
        - Then [expected result]
      
  Dependencies:
    - [Other features/systems]
  
  Constraints:
    - [Technical/business constraints]
```

**Example**:
```yaml
Feature: Employee Hire

  FR-EMP-001: Create Worker Record
    Priority: HIGH
    User Story: "As an HR Admin, I want to create a worker record 
                 so that I can track person identity"
    Acceptance Criteria:
      - Given I am an HR Admin
      - When I submit worker creation form with valid data
      - Then a new worker record is created
      - And worker ID is generated
      - And audit log is created
```

---

### 2. API Specification

**Purpose**: Define REST API contracts.

**Structure**:
```yaml
Endpoint: POST /api/v1/workers

  Description: Create a new worker
  
  Authentication: Required (Bearer token)
  Authorization: HR_ADMIN, RECRUITER
  
  Request:
    Headers:
      Content-Type: application/json
      Authorization: Bearer {token}
    
    Body:
      {
        "full_name": "string (required, max 200)",
        "preferred_name": "string (optional, max 100)",
        "date_of_birth": "date (required, ISO 8601)",
        "gender_code": "string (required, enum: M, F, O, U)",
        "person_type": "string (required, enum: EMPLOYEE, CONTRACTOR, ...)",
        ...
      }
  
  Response:
    Success (201 Created):
      {
        "id": "uuid",
        "code": "WORKER-001",
        "full_name": "Nguyễn Văn An",
        "created_at": "2024-01-15T10:30:00Z"
      }
    
    Error (400 Bad Request):
      {
        "error": "VALIDATION_ERROR",
        "message": "Invalid date of birth",
        "details": [...]
      }
  
  Business Rules:
    - BR-001: Full name is required
    - BR-002: Date of birth must be in the past
    - BR-003: Worker code auto-generated
  
  Validation:
    - full_name: Required, max 200 chars
    - date_of_birth: Required, must be past date
    - gender_code: Required, must be valid code
```

---

### 3. Data Specification

**Purpose**: Define data models, validation, and constraints.

**Structure**:
```yaml
Entity: Worker

  Table: workers
  
  Columns:
    id:
      type: UUID
      primary_key: true
      default: gen_random_uuid()
      
    full_name:
      type: VARCHAR(200)
      required: true
      validation:
        - Not null
        - Max length 200
        - No special characters except Vietnamese
      
    date_of_birth:
      type: DATE
      required: true
      validation:
        - Not null
        - Must be past date
        - Age must be >= 18 (for employees)
      
    national_id:
      type: VARCHAR(20)
      required: false
      sensitive: true
      encryption: AES-256
      data_classification: RESTRICTED
      validation:
        - Format: 9 or 12 digits (Vietnam CMND/CCCD)
        - Unique within system
  
  Indexes:
    - idx_worker_name: (full_name)
    - idx_worker_dob: (date_of_birth)
    - idx_worker_national_id: (national_id) UNIQUE
  
  Constraints:
    - CHK_worker_age: date_of_birth < CURRENT_DATE
    - CHK_worker_name_length: LENGTH(full_name) > 0
  
  Audit:
    - created_at: timestamp
    - created_by: user_id
    - updated_at: timestamp
    - updated_by: user_id
```

---

### 4. Business Rules

**Purpose**: Define detailed business logic.

**Structure**:
```yaml
Business Rule: BR-EMP-001

  Name: "Employee Hire Validation"
  Category: Employment
  Priority: HIGH
  
  Description:
    When hiring a new employee, the system must validate
    all employment prerequisites are met.
  
  Conditions:
    IF employment_type = "EMPLOYEE"
    AND work_relationship_type = "EMPLOYEE"
    
  Rules:
    1. Worker must exist
       - Worker record must be created first
       - Worker must not have active employee relationship
    
    2. Work relationship must be valid
       - Start date must be future or today
       - End date must be null (open-ended)
       - Legal entity must be specified
    
    3. Employee record must be complete
       - Employee number must be unique
       - Hire date = Work relationship start date
       - Probation end date = Hire date + probation period
    
    4. Assignment must be valid
       - Position (if position-based) or Job (if job-based)
       - Business unit must be specified
       - Manager must be specified
       - Location must be specified
  
  Exceptions:
    - Rehire: Allow if previous relationship ended
    - Contractor to Employee: Create new work relationship
  
  Error Messages:
    - "Worker already has active employment"
    - "Invalid work relationship dates"
    - "Employee number already exists"
```

---

### 5. Use Case Scenarios

**Purpose**: Define end-to-end workflows.

**Structure**:
```yaml
Scenario: New Employee Hire

  Actors:
    - HR Administrator
    - Hiring Manager
    - New Employee
  
  Preconditions:
    - Position is approved and vacant (if position-based)
    - Offer letter signed
    - Background check completed
  
  Main Flow:
    1. HR Admin creates worker record
       - Input: Personal information
       - Output: Worker ID generated
       - System: Validates data, creates worker
    
    2. HR Admin creates work relationship
       - Input: Relationship type (EMPLOYEE), start date
       - Output: Work relationship ID
       - System: Creates work relationship
    
    3. HR Admin creates employee record
       - Input: Employee number, hire date, probation
       - Output: Employee ID
       - System: Generates employee number if not provided
    
    4. HR Admin creates assignment
       - Input: Position/Job, business unit, manager
       - Output: Assignment ID
       - System: Creates assignment, updates position status
    
    5. System sends notifications
       - To: New employee, manager, IT, facilities
       - Content: Welcome email, onboarding checklist
  
  Postconditions:
    - Worker record created
    - Work relationship active
    - Employee record active
    - Assignment active
    - Position filled (if position-based)
    - Notifications sent
  
  Alternative Flows:
    A1: Worker already exists (rehire)
      - Skip step 1
      - Continue from step 2
    
    A2: Job-based staffing
      - Step 4: No position, assign to job directly
  
  Exception Flows:
    E1: Validation error
      - Display error message
      - Allow correction
      - Retry
    
    E2: Duplicate employee number
      - Auto-generate new number
      - Continue
  
  Business Rules Applied:
    - BR-EMP-001: Employee hire validation
    - BR-WRK-001: Worker creation validation
    - BR-ASG-001: Assignment validation
  
  Data Changes:
    - workers: INSERT 1 row (if new)
    - work_relationships: INSERT 1 row
    - employees: INSERT 1 row
    - assignments: INSERT 1 row
    - positions: UPDATE 1 row (if position-based)
    - audit_logs: INSERT 4+ rows
```

---

## 🔄 Specification Process

### From Concept to Spec

```yaml
Step 1: Review Concept Guides
  Input: Concept guides (01-concept/*.md)
  Output: Understanding of business requirements
  
Step 2: Identify Features
  Input: Business requirements
  Output: Feature list with priorities
  
Step 3: Write Functional Requirements
  Input: Features
  Output: Detailed FR documents
  Format: FR-[MODULE]-[NUMBER]
  
Step 4: Design APIs
  Input: Functional requirements
  Output: API specification (OpenAPI/Swagger)
  
Step 5: Define Data Models
  Input: Functional requirements, API spec
  Output: Data specification, DBML
  
Step 6: Document Business Rules
  Input: Functional requirements
  Output: Business rules catalog
  
Step 7: Create Use Case Scenarios
  Input: All above
  Output: End-to-end scenarios
  
Step 8: Review and Validate
  Input: All specifications
  Output: Validated, approved specs
  Reviewers: Product, Engineering, QA
```

---

## 📊 Specification Coverage

### Core Module Features

| Feature Area | Functional Spec | API Spec | Data Spec | Business Rules | Scenarios |
|--------------|----------------|----------|-----------|----------------|-----------|
| **Worker Management** | 📝 Planned | 📝 Planned | 📝 Planned | 📝 Planned | 📝 Planned |
| **Employment Lifecycle** | 📝 Planned | 📝 Planned | 📝 Planned | 📝 Planned | 📝 Planned |
| **Organization Structure** | 📝 Planned | 📝 Planned | 📝 Planned | 📝 Planned | 📝 Planned |
| **Job & Position Mgmt** | 📝 Planned | 📝 Planned | 📝 Planned | 📝 Planned | 📝 Planned |
| **Skill Management** | 📝 Planned | 📝 Planned | 📝 Planned | 📝 Planned | 📝 Planned |
| **Data Security** | 📝 Planned | 📝 Planned | 📝 Planned | 📝 Planned | 📝 Planned |

---

## 🎯 Specification Priorities

### Phase 1: Core Employment (High Priority)

```yaml
Priority: HIGH
Timeline: Sprint 1-3

Features:
  1. Worker Management
     - Create, read, update worker
     - Data classification
     - Consent management
  
  2. Work Relationship
     - Create work relationship
     - Employee vs Contractor
     - Status management
  
  3. Employee Management
     - Create employee record
     - Employee number generation
     - Probation tracking
  
  4. Assignment Management
     - Create assignment
     - Position-based vs Job-based
     - Manager assignment
  
  5. Basic Reporting
     - Headcount reports
     - Employee list
     - Org chart

Deliverables:
  - Functional Requirements (FR-001 to FR-050)
  - API Specification (20+ endpoints)
  - Data Specification (10+ tables)
  - Business Rules (30+ rules)
  - Use Case Scenarios (10+ scenarios)
```

### Phase 2: Organization & Jobs (Medium Priority)

```yaml
Priority: MEDIUM
Timeline: Sprint 4-6

Features:
  1. Organization Structure
     - Business units
     - Supervisory organizations
     - Org relationships
  
  2. Job Management
     - Job taxonomy
     - Job profiles
     - Job hierarchy
  
  3. Position Management
     - Position creation
     - Vacancy tracking
     - Position hierarchy
  
  4. Reporting Lines
     - Solid line reporting
     - Dotted line reporting
     - Matrix organizations

Deliverables:
  - Functional Requirements (FR-051 to FR-100)
  - API Specification (15+ endpoints)
  - Data Specification (8+ tables)
  - Business Rules (20+ rules)
  - Use Case Scenarios (8+ scenarios)
```

### Phase 3: Skills & Advanced Features (Lower Priority)

```yaml
Priority: LOW
Timeline: Sprint 7-9

Features:
  1. Skill Management
     - Skill catalog
     - Skill assessment
     - Gap analysis
  
  2. Career Paths
     - Career progression
     - Job progression rules
  
  3. Advanced Reporting
     - Skill reports
     - Gap analysis reports
     - Career path reports
  
  4. Data Privacy
     - DSAR workflows
     - Consent management
     - Audit reports

Deliverables:
  - Functional Requirements (FR-101 to FR-150)
  - API Specification (10+ endpoints)
  - Data Specification (6+ tables)
  - Business Rules (15+ rules)
  - Use Case Scenarios (6+ scenarios)
```

---

## ✅ Specification Quality Checklist

### For Each Functional Requirement

- [ ] Clear, unambiguous description
- [ ] User story format (As a... I want... So that...)
- [ ] Acceptance criteria (Given... When... Then...)
- [ ] Priority assigned (HIGH/MEDIUM/LOW)
- [ ] Dependencies identified
- [ ] Constraints documented
- [ ] Reviewed by stakeholders
- [ ] Approved by product owner

### For Each API Endpoint

- [ ] HTTP method specified (GET, POST, PUT, DELETE)
- [ ] URL path defined
- [ ] Authentication/authorization specified
- [ ] Request format documented (headers, body, params)
- [ ] Response format documented (success, errors)
- [ ] Status codes defined
- [ ] Validation rules specified
- [ ] Business rules referenced
- [ ] Examples provided
- [ ] OpenAPI/Swagger compliant

### For Each Data Model

- [ ] Table name specified
- [ ] All columns defined (name, type, constraints)
- [ ] Primary key identified
- [ ] Foreign keys specified
- [ ] Indexes defined
- [ ] Constraints documented
- [ ] Validation rules specified
- [ ] Data classification assigned
- [ ] Audit fields included
- [ ] SCD Type 2 fields (if applicable)

### For Each Business Rule

- [ ] Unique ID assigned (BR-XXX-NNN)
- [ ] Clear description
- [ ] Category assigned
- [ ] Priority specified
- [ ] Conditions defined
- [ ] Rules detailed
- [ ] Exceptions documented
- [ ] Error messages specified
- [ ] Examples provided
- [ ] Reviewed by business

### For Each Use Case Scenario

- [ ] Actors identified
- [ ] Preconditions specified
- [ ] Main flow documented (step-by-step)
- [ ] Postconditions specified
- [ ] Alternative flows documented
- [ ] Exception flows documented
- [ ] Business rules referenced
- [ ] Data changes documented
- [ ] UI mockups referenced (if applicable)
- [ ] Reviewed by stakeholders

---

## 🔗 Related Documentation

### Prerequisites (Must Read First)
- [Core Ontology](../00-ontology/core-ontology.yaml) - Data model foundation
- [Concept Guides](../01-concept/README.md) - Business requirements
- [Glossaries](../00-ontology/glossary-index.md) - Entity definitions

### Next Steps (After Specifications)
- [Design Documentation](../03-design/README.md) - Technical design
- [Implementation Guides](../04-implementation/README.md) - Development guides
- [API Documentation](../05-api/README.md) - API reference

---

## 📅 Specification Timeline

### Recommended Approach

```yaml
Week 1-2: Functional Requirements
  - Review concept guides
  - Identify all features
  - Write functional requirements
  - Prioritize features
  - Review with stakeholders

Week 3-4: API Specification
  - Design API endpoints
  - Define request/response formats
  - Document authentication/authorization
  - Write OpenAPI/Swagger spec
  - Review with frontend/backend teams

Week 5-6: Data Specification
  - Design database schema
  - Define validation rules
  - Document constraints
  - Create DBML diagrams
  - Review with database team

Week 7-8: Business Rules
  - Extract business logic from FRs
  - Document detailed rules
  - Define validation rules
  - Create rules catalog
  - Review with business analysts

Week 9-10: Use Case Scenarios
  - Write end-to-end scenarios
  - Document workflows
  - Create sequence diagrams
  - Review with all stakeholders
  - Finalize and approve

Week 11-12: Review and Refinement
  - Cross-reference all specs
  - Ensure consistency
  - Fill gaps
  - Final reviews
  - Approval and sign-off
```

---

## 🎓 Best Practices

### Writing Specifications

✅ **DO**:
- Be specific and unambiguous
- Use consistent terminology
- Provide examples
- Reference related specs
- Include diagrams where helpful
- Version control all specs
- Review with stakeholders
- Update specs when requirements change

❌ **DON'T**:
- Use vague language ("should", "might", "probably")
- Assume knowledge
- Skip validation rules
- Ignore edge cases
- Write specs in isolation
- Forget to version
- Skip reviews

### Specification Format

```yaml
# Good Example
FR-EMP-001: Create Worker Record
  Description: System shall create a new worker record with validated data
  Priority: HIGH
  Acceptance Criteria:
    - Given valid worker data
    - When HR Admin submits create form
    - Then worker record is created
    - And worker ID is generated (format: WORKER-NNNNNN)
    - And audit log entry is created

# Bad Example
"The system should probably create workers when needed"
# Too vague, no criteria, no priority
```

---

## 📞 Getting Help

### Questions?
- **Functional Requirements**: Contact Product Owner
- **API Design**: Contact Backend Lead
- **Data Models**: Contact Database Architect
- **Business Rules**: Contact Business Analyst
- **Use Cases**: Contact Product Manager

### Feedback
- Report spec issues via issue tracker
- Suggest improvements via pull requests
- Request clarifications via comments
- Contribute examples and diagrams

---

## 📈 Progress Tracking

### Specification Status

```yaml
Overall Progress: 0% (Not Started)

By Document Type:
  Functional Requirements: 0/150 (0%)
  API Specifications: 0/45 (0%)
  Data Specifications: 0/24 (0%)
  Business Rules: 0/65 (0%)
  Use Case Scenarios: 0/24 (0%)

By Feature Area:
  Worker Management: Not Started
  Employment Lifecycle: Not Started
  Organization Structure: Not Started
  Job & Position Management: Not Started
  Skill Management: Not Started
  Data Security: Not Started
```

---

**Document Version**: 1.0  
**Created**: 2025-12-02  
**Maintained By**: Product Team + Engineering Team  
**Last Review**: 2025-12-02  
**Status**: Planning Phase
