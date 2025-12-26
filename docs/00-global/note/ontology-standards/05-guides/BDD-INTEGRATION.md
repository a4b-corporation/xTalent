# BDD Integration Guide

**Version**: 3.0  
**Audience**: QA, Developers, AI Agents  
**Format**: Gherkin/Cucumber

---

## 🎯 Purpose

This document defines how to:
1. Generate Gherkin scenarios from ontology definitions
2. Structure feature files for consistency
3. Link tests to ontology artifacts for traceability
4. Automate test generation with AI agents

---

## 📐 Feature File Structure

### Standard Feature File Template

```gherkin
# ============================================================================
# File: 02-spec/05-BDD/01-workforce/employee.feature
# Entity: xtalent:core-hr:workforce:employee
# Generated: 2024-12-24
# ============================================================================

@module(core-hr)
@submodule(workforce)
@entity(employee)
Feature: Employee Management
  As an HR Specialist
  I want to manage employee records
  So that I can maintain accurate workforce data

  # Link to ontology
  # Entity: 00-ontology/domain/01-workforce/employee.aggregate.yaml
  # Concept: 01-concept/01-workforce/employee-guide.md

  Background:
    Given the following departments exist:
      | id   | name        | code |
      | D001 | Engineering | ENG  |
      | D002 | Sales       | SAL  |
    And the following positions exist:
      | id   | title             | department |
      | P001 | Software Engineer | D001       |
      | P002 | Sales Manager     | D002       |

  # ===========================================================================
  # CRUD Scenarios
  # ===========================================================================
  
  @crud @create
  @trace(xtalent:core-hr:workforce:employee:create)
  Scenario: Successfully create a new employee
    Given I am logged in as "HR_SPECIALIST"
    When I create an employee with:
      | field       | value           |
      | first_name  | John            |
      | last_name   | Doe             |
      | email       | john@company.com|
      | hire_date   | 2024-01-15      |
      | department  | D001            |
    Then the employee should be created
    And the employee status should be "DRAFT"
    And the employee code should match pattern "^EMP\d{6}$"
    And an audit record should be created for "CREATE"

  @crud @read
  Scenario: Retrieve employee by ID
    Given an employee exists with code "EMP000001"
    When I retrieve the employee by ID
    Then I should receive the employee details
    And the response should include "first_name"
    And the response should include "department"

  @crud @update
  Scenario: Update employee information
    Given an employee exists with:
      | code   | EMP000001 |
      | status | ACTIVE    |
    When I update the employee with:
      | field       | value          |
      | phone       | +84901234567   |
    Then the employee should be updated
    And an audit record should be created for "UPDATE"

  @crud @delete @negative
  Scenario: Cannot delete active employee
    Given an employee exists with status "ACTIVE"
    When I attempt to delete the employee
    Then I should receive error "ERR_CANNOT_DELETE_ACTIVE"
    And the employee should still exist

  # ===========================================================================
  # Lifecycle Scenarios
  # ===========================================================================

  @lifecycle @activate
  @trace(xtalent:core-hr:workforce:employee:lifecycle:activate)
  Scenario: Activate a draft employee
    Given an employee exists with status "DRAFT"
    And the employee has all required fields populated
    And the employee has a department assigned
    When I activate the employee
    Then the employee status should be "ACTIVE"
    And a "EmployeeActivated" event should be published
    And HR Manager should receive notification

  @lifecycle @deactivate
  Scenario: Deactivate an active employee
    Given an employee exists with status "ACTIVE"
    When I deactivate the employee with reason "Leave of Absence"
    Then the employee status should be "INACTIVE"
    And all active assignments should be suspended

  @lifecycle @terminate
  @trace(xtalent:core-hr:workforce:terminate-employee)
  Scenario Outline: Terminate employee with different reasons
    Given an employee exists with status "<initial_status>"
    When I terminate the employee with:
      | termination_date   | 2024-12-31              |
      | termination_reason | <reason>                |
      | eligible_for_rehire| <rehire>                |
    Then the employee status should be "TERMINATED"
    And all active assignments should be ended
    
    Examples:
      | initial_status | reason                  | rehire |
      | ACTIVE         | VOLUNTARY_RESIGNATION   | true   |
      | ACTIVE         | INVOLUNTARY_TERMINATION | false  |
      | INACTIVE       | END_OF_CONTRACT         | true   |

  @lifecycle @negative
  Scenario: Cannot terminate already terminated employee
    Given an employee exists with status "TERMINATED"
    When I attempt to terminate the employee
    Then I should receive error "ERR_ALREADY_TERMINATED"

  # ===========================================================================
  # Business Rule Scenarios
  # ===========================================================================

  @rule(BR-001)
  @trace(xtalent:core-hr:workforce:BR-001)
  Scenario: Hire date cannot be in the future
    When I create an employee with hire_date "tomorrow"
    Then I should receive error "ERR_FUTURE_HIRE_DATE"
    And the error message should be "Hire date cannot be in the future"

  @rule(BR-002)
  @trace(xtalent:core-hr:workforce:BR-002)
  Scenario: Employee code must be unique
    Given an employee exists with code "EMP000001"
    When I create another employee with code "EMP000001"
    Then I should receive error "ERR_DUPLICATE_CODE"

  @rule(BR-003)
  Scenario: Employee cannot be their own manager
    Given an employee exists with id "E001"
    When I update the employee setting manager_id to "E001"
    Then I should receive error "ERR_SELF_MANAGER"
    And the error message should be "Employee cannot be their own manager"

  @rule(BR-004)
  Scenario: Termination date must be after hire date
    Given an employee exists with hire_date "2024-01-15"
    When I terminate with termination_date "2024-01-01"
    Then I should receive error "ERR_INVALID_TERMINATION_DATE"

  # ===========================================================================
  # Derived Attribute Scenarios
  # ===========================================================================

  @derived
  Scenario: Calculate years of service
    Given an employee was hired on "2020-01-15"
    And today is "2024-12-24"
    When I retrieve the employee
    Then years_of_service should be 4

  @derived
  Scenario: Determine promotion eligibility
    Given an employee with:
      | hire_date        | 2019-01-01 |
      | status           | ACTIVE     |
      | performance_rating| 4.5       |
    When I check promotion eligibility
    Then is_eligible_for_promotion should be true

  # ===========================================================================
  # Relationship Scenarios
  # ===========================================================================

  @relationship
  Scenario: Employee belongs to department
    Given an employee in department "Engineering"
    When I retrieve the employee with department
    Then the department name should be "Engineering"

  @relationship
  Scenario: Find all employees in a department
    Given the following employees exist in "Engineering":
      | code      | name       |
      | EMP000001 | John Doe   |
      | EMP000002 | Jane Smith |
    When I query employees in department "Engineering"
    Then I should receive 2 employees

  @relationship @hierarchy
  Scenario: Employee has manager
    Given "John" is managed by "Jane"
    When I retrieve John's manager
    Then the manager should be "Jane"

  @relationship @hierarchy
  Scenario: Manager has direct reports
    Given "Jane" manages:
      | John  |
      | Bob   |
      | Alice |
    When I retrieve Jane's direct reports
    Then I should receive 3 employees

  # ===========================================================================
  # Authorization Scenarios
  # ===========================================================================

  @security @authorization
  Scenario: HR Specialist can create employees
    Given I am logged in as "HR_SPECIALIST"
    When I create an employee
    Then the operation should succeed

  @security @authorization @negative
  Scenario: Regular user cannot create employees
    Given I am logged in as "REGULAR_USER"
    When I attempt to create an employee
    Then I should receive error "ERR_UNAUTHORIZED"
    And the error status should be 403

  @security @row-level
  Scenario: Manager can only view own department
    Given I am logged in as manager of "Engineering"
    When I query all employees
    Then I should only see employees in "Engineering"

  # ===========================================================================
  # Integration Scenarios
  # ===========================================================================

  @integration @payroll
  Scenario: Employee termination triggers payroll notification
    Given an active employee with payroll record
    When I terminate the employee
    Then a final settlement request should be sent to Payroll
    And the payroll status should be "PENDING_FINAL_PAY"
```

---

## 🏷️ Tagging Convention

### Required Tags

| Tag | Purpose | Example |
|-----|---------|---------|
| `@module(x)` | Module identifier | `@module(core-hr)` |
| `@submodule(x)` | Submodule identifier | `@submodule(workforce)` |
| `@entity(x)` | Primary entity | `@entity(employee)` |

### Category Tags

| Tag | Category | Description |
|-----|----------|-------------|
| `@crud` | CRUD operations | Basic create/read/update/delete |
| `@lifecycle` | State transitions | Status changes |
| `@rule(BR-XXX)` | Business rules | Validation scenarios |
| `@derived` | Computed fields | Calculated attributes |
| `@relationship` | Entity links | Relationship testing |
| `@security` | Authorization | Permission checks |
| `@integration` | External systems | System interactions |

### Behavior Tags

| Tag | Meaning |
|-----|---------|
| `@positive` | Expected success scenario |
| `@negative` | Expected failure scenario |
| `@edge-case` | Boundary conditions |
| `@regression` | Regression test |
| `@smoke` | Quick sanity check |

### Traceability Tags

```gherkin
# Link to entity
@trace(xtalent:core-hr:workforce:employee)

# Link to action
@trace(xtalent:core-hr:workforce:terminate-employee)

# Link to business rule
@trace(xtalent:core-hr:workforce:BR-001)

# Link to workflow
@trace(xtalent:core-hr:workforce:WF-001)
```

---

## 🔄 Generation from Ontology

### From Entity Definition

**Input**: `employee.aggregate.yaml`

**Generate**:
1. CRUD scenarios for each attribute
2. Lifecycle scenarios from `lifecycle` section
3. Validation scenarios from `validation_rules`
4. Relationship scenarios from `relationships`

### From Action Definition

**Input**: `terminate-employee.action.yaml`

**Generate**:
1. Success scenario from `examples`
2. Precondition failure scenarios from `preconditions`
3. Authorization scenarios from `authorization`
4. Error handling scenarios from `error_handling`

### From Business Rules

**Input**: `BR-01-workforce.br.yaml`

**Generate**:
1. One scenario per business rule
2. Include `@rule(BR-XXX)` tag
3. Include `@trace()` for traceability

---

## 📝 Step Definition Patterns

### Given Steps (Context Setup)

```gherkin
# Entity exists
Given an employee exists with status "ACTIVE"
Given an employee exists with:
  | field  | value     |
  | code   | EMP000001 |
  | status | ACTIVE    |

# Multiple entities
Given the following employees exist:
  | code      | name     | status |
  | EMP000001 | John Doe | ACTIVE |

# Authentication
Given I am logged in as "HR_SPECIALIST"
Given I am logged in as manager of "Engineering"

# Date context
Given today is "2024-12-24"
Given an employee was hired on "2020-01-15"
```

### When Steps (Actions)

```gherkin
# Create
When I create an employee with:
  | field | value |

# Update
When I update the employee with:
  | field | value |

# Delete
When I delete the employee
When I attempt to delete the employee

# Lifecycle
When I activate the employee
When I terminate the employee with:
  | field | value |

# Query
When I retrieve the employee by ID
When I query employees in department "Engineering"
```

### Then Steps (Assertions)

```gherkin
# Status checks
Then the employee should be created
Then the employee status should be "ACTIVE"
Then the operation should succeed

# Error checks
Then I should receive error "ERR_CODE"
Then the error message should be "message"
Then the error status should be 400

# Side effects
Then an audit record should be created for "CREATE"
Then a "EventName" event should be published
Then notification should be sent to "recipient"

# Relationship checks
Then the department name should be "Engineering"
Then I should receive 3 employees

# Derived attribute checks
Then years_of_service should be 4
```

---

## 🔗 Traceability Matrix

Generate traceability report:

```markdown
| Scenario | Entity | Action | BR | WF | Status |
|----------|--------|--------|----|----|--------|
| Create employee | Employee | - | - | - | ✅ |
| Activate employee | Employee | activate | - | WF-001 | ✅ |
| Hire date validation | Employee | - | BR-001 | - | ✅ |
| Terminate employee | Employee | terminate | BR-004 | WF-002 | ✅ |
```

---

## 🤖 AI Agent Instructions

When generating BDD scenarios:

1. **Read entity file** for structure
2. **Check `examples` section** for test data
3. **Generate CRUD scenarios** for all entities
4. **Generate lifecycle scenarios** if `lifecycle` defined
5. **Generate rule scenarios** for each `validation_rule`
6. **Generate action scenarios** from `action.yaml` files
7. **Add traceability tags** using `$id` URIs
8. **Include both positive and negative cases**

### Template for AI Generation

```gherkin
# Prompt: Generate BDD for {entity_name}
# Source: {$id}

@module({module})
@entity({entity_name})
Feature: {Entity} Management
  
  # CRUD from attributes
  @crud @create
  Scenario: Create {entity_name}
    ...

  # Lifecycle from lifecycle section
  @lifecycle
  Scenario: Transition from {state_a} to {state_b}
    ...

  # Rules from validation_rules
  @rule({rule_id})
  Scenario: {rule_name}
    ...
```

---

## 📚 Related Documents

- [02-ENTITY-SCHEMA.md](./02-ENTITY-SCHEMA.md) — Entity definitions
- [03-WORKFLOW-SCHEMA.md](./03-WORKFLOW-SCHEMA.md) — Workflow & Actions
- [05-BUSINESS-RULES.md](./05-BUSINESS-RULES.md) — Business rules format
- [09-TRACEABILITY.md](./09-TRACEABILITY.md) — Traceability matrix
