# Traceability Framework

**Version**: 3.0  
**Audience**: PMs, QA, Architects

---

## 🎯 Purpose

Traceability ensures every requirement is:
1. **Defined** in the ontology
2. **Explained** in concept guides
3. **Specified** precisely
4. **Implemented** in code
5. **Tested** with scenarios

---

## 🔗 URI System

Every artifact has a unique identifier following this pattern:

```
xtalent:{module}:{submodule}:{type}:{name}:{version}

Examples:
xtalent:core-hr:workforce:entity:employee:v2
xtalent:core-hr:workforce:action:terminate-employee
xtalent:core-hr:workforce:workflow:WF-001-onboarding
xtalent:core-hr:workforce:rule:BR-WF-001
xtalent:core-hr:workforce:fr:FR-WF-001
xtalent:core-hr:workforce:bdd:employee-activation
```

---

## 📊 Cross-Layer Traceability Matrix

### Entity → Full Stack Trace

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ENTITY: Employee                                     │
│                  $id: xtalent:core-hr:workforce:employee                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  LAYER 0: ONTOLOGY                                                          │
│  ├── Entity Definition    → employee.aggregate.yaml                            │
│  ├── Glossary Term        → workforce.glossary.yaml#employee                │
│  ├── Related Actions      → activate-employee.action.yaml                   │
│  │                        → terminate-employee.action.yaml                  │
│  └── Related Workflows    → WF-001-onboarding.workflow.yaml                 │
│                           → WF-002-offboarding.workflow.yaml                │
│                                                                              │
│  LAYER 1: CONCEPT                                                           │
│  ├── Entity Guide         → 01-concept/02-workforce/employee-guide.md       │
│  └── Workflow Guides      → 01-concept/02-workforce/onboarding-guide.md     │
│                           → 01-concept/02-workforce/termination-guide.md    │
│                                                                              │
│  LAYER 2: SPECIFICATION                                                     │
│  ├── Functional Reqs      → FR-WF-001 (Create)                              │
│  │                        → FR-WF-002 (Activate)                            │
│  │                        → FR-WF-003 (Terminate)                           │
│  ├── Business Rules       → BR-WF-001 to BR-WF-031                          │
│  ├── API Endpoints        → POST /employees                                 │
│  │                        → GET /employees/{id}                             │
│  │                        → POST /employees/{id}/activate                   │
│  │                        → POST /employees/{id}/terminate                  │
│  └── BDD Scenarios        → employee.feature (15 scenarios)                 │
│                           → onboarding.feature (8 scenarios)                │
│                                                                              │
│  LAYER 3: DESIGN                                                            │
│  ├── Database Schema      → core-hr.dbml#employee                           │
│  ├── ER Diagram           → diagrams/workforce-erd.mermaid                  │
│  └── Sequence Diagrams    → diagrams/sequence/employee-lifecycle.mermaid   │
│                                                                              │
│  LAYER 4: IMPLEMENTATION                                                    │
│  ├── Backend Code         → src/modules/workforce/entities/Employee.ts     │
│  │                        → src/modules/workforce/services/EmployeeService │
│  ├── Database Migration   → migrations/001_create_employee.sql              │
│  └── Tests                → tests/workforce/employee.spec.ts                │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📋 Traceability Matrix Template

### Business Rule Traceability

```yaml
# File: 02-spec/TRACEABILITY-MATRIX.yaml

$schema: "https://xtalent.io/schemas/traceability/v3"
module: CORE-HR
submodule: workforce
generated_at: "2024-12-24T10:00:00Z"

# Business Rule → All Artifacts
business_rules:
  - rule_id: BR-WF-001
    rule_name: "Hire Date Cannot Be Future"
    
    ontology:
      entity: "xtalent:core-hr:workforce:employee"
      attribute: hire_date
      validation_rule: hire_date_not_future
      
    concept:
      guides:
        - path: "01-concept/02-workforce/employee-guide.md"
          section: "#key-attributes-explained"
          
    specification:
      functional_requirement: FR-WF-001
      api_validation:
        endpoint: "POST /employees"
        field: hire_date
        error_code: ERR_FUTURE_HIRE_DATE
        
    bdd:
      feature: "02-spec/05-BDD/01-workforce/employee.feature"
      scenarios:
        - name: "Hire date cannot be in future"
          line: 45
          
    implementation:
      backend:
        file: "src/modules/workforce/validators/EmployeeValidator.ts"
        function: "validateHireDate"
        line: 23
      database:
        constraint: "ck_employee_hire_date"
        
    test:
      unit:
        file: "tests/workforce/validators/employee.spec.ts"
        cases: ["should reject future hire date"]
      integration:
        file: "tests/integration/employee-api.spec.ts"
        cases: ["POST /employees returns 400 for future hire date"]
        
    coverage:
      unit_test: true
      integration_test: true
      bdd_scenario: true
      status: COMPLETE

  - rule_id: BR-WF-002
    rule_name: "Termination Date After Hire Date"
    # ... continue for all rules

# Functional Requirement → All Artifacts  
functional_requirements:
  - fr_id: FR-WF-001
    fr_name: "Create Employee Record"
    
    ontology:
      entities:
        - "xtalent:core-hr:workforce:employee"
      actions: []
      
    concept:
      guides:
        - "01-concept/02-workforce/employee-guide.md"
        
    specification:
      business_rules: [BR-WF-001, BR-WF-005]
      api:
        method: POST
        path: /employees
        
    bdd:
      scenarios:
        - "employee.feature#create-employee"
        - "employee.feature#create-employee-validation"
        
    implementation:
      backend:
        controller: "EmployeeController.create"
        service: "EmployeeService.createEmployee"
        
    test:
      unit: ["EmployeeService.spec.ts#create"]
      integration: ["employee-api.spec.ts#POST"]
      e2e: ["employee-crud.e2e.ts"]
      
    status: IMPLEMENTED

# Coverage Summary
coverage_summary:
  business_rules:
    total: 15
    with_bdd: 15
    with_unit_test: 15
    with_integration_test: 14
    fully_covered: 14
    
  functional_requirements:
    total: 12
    implemented: 10
    tested: 10
    
  entities:
    total: 5
    with_crud_tests: 5
    with_lifecycle_tests: 3
```

---

## 🔍 Coverage Reports

### Generate Coverage Report

```bash
# Check BR coverage
xtalent coverage --type br --module core-hr

# Output:
# ┌─────────┬───────────┬──────┬──────┬──────┬────────┐
# │ Rule    │ Name      │ BDD  │ Unit │ Int  │ Status │
# ├─────────┼───────────┼──────┼──────┼──────┼────────┤
# │ BR-WF-001│ Hire Date │ ✅   │ ✅   │ ✅   │ ✅     │
# │ BR-WF-002│ Term Date │ ✅   │ ✅   │ ✅   │ ✅     │
# │ BR-WF-003│ Self Mgr  │ ✅   │ ✅   │ ❌   │ ⚠️     │
# └─────────┴───────────┴──────┴──────┴──────┴────────┘
# Coverage: 93% (14/15 fully covered)
```

### Coverage Thresholds

| Artifact Type | Minimum Coverage | Target |
|--------------|------------------|--------|
| Business Rules | 95% | 100% |
| Functional Requirements | 90% | 100% |
| Entity CRUD | 100% | 100% |
| Lifecycle Transitions | 100% | 100% |
| API Endpoints | 95% | 100% |

---

## 🔄 Change Impact Analysis

When an artifact changes, trace the impact:

### Example: Changing Employee.hire_date validation

```
CHANGE: BR-WF-001 now allows hire_date up to 30 days in future

IMPACT ANALYSIS:
├── Ontology
│   └── employee.aggregate.yaml
│       └── UPDATE: validation_rules.hire_date_not_future
│
├── Concept
│   └── employee-guide.md
│       └── UPDATE: Key Attributes section
│
├── Specification
│   ├── FR-WF-001.md
│   │   └── UPDATE: Validation description
│   ├── openapi.yaml
│   │   └── UPDATE: hire_date description
│   └── employee.feature
│       └── UPDATE: hire date scenarios
│
├── Implementation
│   ├── EmployeeValidator.ts
│   │   └── UPDATE: validateHireDate function
│   └── employee migration
│       └── UPDATE: check constraint
│
└── Tests
    ├── employee.spec.ts
    │   └── UPDATE: hire date test cases
    └── employee-api.spec.ts
        └── UPDATE: API validation tests

ESTIMATED EFFORT: 4 hours
RISK: Medium (affects new employee creation)
```

---

## 📊 Traceability Dashboard

### Widget: Requirement Coverage

```
┌─────────────────────────────────────────────────┐
│         REQUIREMENT COVERAGE                     │
├─────────────────────────────────────────────────┤
│                                                  │
│  Business Rules     ████████████████░░ 93%     │
│  Func Requirements  ██████████████████ 100%    │
│  API Endpoints      ████████████████░░ 95%     │
│  BDD Scenarios      ████████████████░░ 92%     │
│                                                  │
│  OVERALL: 95%                                   │
│                                                  │
└─────────────────────────────────────────────────┘
```

### Widget: Implementation Status

```
┌─────────────────────────────────────────────────┐
│         IMPLEMENTATION STATUS                    │
├─────────────────────────────────────────────────┤
│                                                  │
│  ✅ Implemented: 42 features                    │
│  🔄 In Progress: 5 features                     │
│  ⏳ Pending: 8 features                         │
│  ❌ Blocked: 1 feature                          │
│                                                  │
│  Sprint 5 Progress: 72%                         │
│                                                  │
└─────────────────────────────────────────────────┘
```

---

## 🤖 AI Agent Traceability Commands

When AI agent needs to trace artifacts:

```
# Find all artifacts related to an entity
TRACE ENTITY xtalent:core-hr:workforce:employee

# Find all tests for a business rule
TRACE RULE BR-WF-001 --type tests

# Find implementation for a functional requirement
TRACE FR FR-WF-002 --type implementation

# Check coverage gaps
TRACE GAPS --module core-hr --submodule workforce
```

---

## 📚 Related Documents

- [01-ARCHITECTURE.md](./01-ARCHITECTURE.md) — Layer architecture
- [07-AI-AGENT-GUIDE.md](./07-AI-AGENT-GUIDE.md) — AI traceability usage
- [05-BUSINESS-RULES.md](./05-BUSINESS-RULES.md) — BR format with traces
- [06-BDD-INTEGRATION.md](./06-BDD-INTEGRATION.md) — BDD with trace tags
