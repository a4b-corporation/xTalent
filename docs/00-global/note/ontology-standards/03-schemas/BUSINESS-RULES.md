# Business Rules Schema Specification

**Version**: 3.0  
**Format**: YAML  
**Audience**: BAs, Developers, QA, AI Agents

---

## 🎯 Purpose

Business Rules (BR) define **business constraints and policies** that:

1. **Constrain** data validity and integrity
2. **Govern** business behavior and eligibility
3. **Determine** derived values and classifications
4. **Control** access and authorization

> [!NOTE]
> This is a **Business Rule ontology** — it describes rules at the semantic level.
> It is NOT a Rule Engine specification. Avoid terms like `execute`, `calculate`, `apply in order`.
> Instead use: `governs`, `constrains`, `determines`.

---

## 📋 Business Rule Schema

```yaml
# ============================================================================
# BUSINESS RULES SCHEMA v3.0
# ============================================================================
# File: 02-spec/04-BR/BR-01-workforce.br.yaml

$schema: "https://xtalent.io/schemas/business-rules/v3"
$id: "xtalent:core-hr:workforce:business-rules"

module: CORE-HR
submodule: workforce
version: "1.0"

# ============================================================================
# METADATA
# ============================================================================
metadata:
  total_rules: 15
  by_category:
    VALIDATION: 8
    CALCULATION: 3
    AUTHORIZATION: 2
    WORKFLOW: 2
  by_priority:
    CRITICAL: 3
    HIGH: 7
    MEDIUM: 4
    LOW: 1
  last_reviewed: "2024-12-24"
  reviewed_by: "Domain Expert"

# ============================================================================
# BUSINESS RULES
# ============================================================================
rules:

  # ---------------------------------------------------------------------------
  # VALIDATION RULES
  # ---------------------------------------------------------------------------
  
  - id: BR-WF-001
    name: "Hire Date Cannot Be Future"
    category: VALIDATION
    priority: CRITICAL
    status: APPROVED
    
    # What this rule enforces
    description: |
      The hire date of an employee cannot be set to a future date.
      This ensures data integrity and prevents premature employee activation.
    
    # When this rule applies
    applies_to:
      entity: Employee
      entity_ref: "xtalent:core-hr:workforce:employee"
      attributes: [hire_date]
      operations: [CREATE, UPDATE]
    
    # The rule logic
    condition:
      expression: "hire_date <= CURRENT_DATE"
      language: SQL  # SQL | JAVASCRIPT | PYTHON | PSEUDOCODE
    
    # Alternative expressions for different contexts
    implementations:
      sql: "hire_date <= CURRENT_DATE"
      javascript: "new Date(hireDate) <= new Date()"
      python: "hire_date <= date.today()"
      gremlin: "has('hire_date', lte(now()))"
    
    # What happens when rule fails
    on_violation:
      action: REJECT
      error_code: "ERR_FUTURE_HIRE_DATE"
      error_message: "Hire date cannot be in the future. Please enter a date on or before today."
      http_status: 400
      severity: ERROR
    
    # Test scenarios
    test_cases:
      - name: "Valid - Today"
        input:
          hire_date: "2024-12-24"  # Assuming today
        expected: PASS
        
      - name: "Valid - Past Date"
        input:
          hire_date: "2020-01-15"
        expected: PASS
        
      - name: "Invalid - Future Date"
        input:
          hire_date: "2025-06-01"
        expected: FAIL
        error_code: "ERR_FUTURE_HIRE_DATE"
    
    # Traceability
    traces:
      entity: "xtalent:core-hr:workforce:employee"
      functional_requirement: "FR-WF-001"
      bdd_scenario: "02-spec/05-BDD/01-workforce/employee.feature#hire-date-validation"
    
    # Exceptions (when rule can be bypassed)
    exceptions:
      - condition: "user.role = 'SYSTEM_ADMIN' AND override_reason IS NOT NULL"
        requires_approval: true
        approval_role: "HR_DIRECTOR"

  # ---------------------------------------------------------------------------
  
  - id: BR-WF-002
    name: "Termination Date After Hire Date"
    category: VALIDATION
    priority: CRITICAL
    status: APPROVED
    
    description: |
      If an employee has a termination date, it must be on or after 
      their hire date. Cannot terminate before employment started.
    
    applies_to:
      entity: Employee
      entity_ref: "xtalent:core-hr:workforce:employee"
      attributes: [termination_date, hire_date]
      operations: [UPDATE]
    
    condition:
      expression: "termination_date IS NULL OR termination_date >= hire_date"
      language: SQL
    
    on_violation:
      action: REJECT
      error_code: "ERR_INVALID_TERMINATION_DATE"
      error_message: "Termination date must be on or after hire date ({hire_date})."
      http_status: 400
      severity: ERROR
    
    test_cases:
      - name: "Valid - No Termination"
        input:
          hire_date: "2020-01-15"
          termination_date: null
        expected: PASS
        
      - name: "Valid - Termination After Hire"
        input:
          hire_date: "2020-01-15"
          termination_date: "2024-12-31"
        expected: PASS
        
      - name: "Invalid - Termination Before Hire"
        input:
          hire_date: "2020-01-15"
          termination_date: "2019-12-31"
        expected: FAIL

  # ---------------------------------------------------------------------------
  
  - id: BR-WF-003
    name: "Employee Cannot Be Own Manager"
    category: VALIDATION
    priority: HIGH
    status: APPROVED
    
    description: |
      An employee cannot be assigned as their own manager.
      This prevents circular references in the org hierarchy.
    
    applies_to:
      entity: Employee
      entity_ref: "xtalent:core-hr:workforce:employee"
      attributes: [manager_id]
      operations: [CREATE, UPDATE]
    
    condition:
      expression: "manager_id IS NULL OR manager_id != id"
      language: SQL
    
    on_violation:
      action: REJECT
      error_code: "ERR_SELF_MANAGER"
      error_message: "Employee cannot be their own manager."
      http_status: 400
      severity: ERROR

  # ---------------------------------------------------------------------------
  
  - id: BR-WF-004
    name: "Terminated Employee Must Have Reason"
    category: VALIDATION
    priority: HIGH
    status: APPROVED
    
    description: |
      When employee status is TERMINATED, a termination_reason must be provided.
    
    applies_to:
      entity: Employee
      entity_ref: "xtalent:core-hr:workforce:employee"
      attributes: [status, termination_reason]
      operations: [UPDATE]
      trigger: "status changed to TERMINATED"
    
    condition:
      expression: "status != 'TERMINATED' OR termination_reason IS NOT NULL"
      language: SQL
    
    on_violation:
      action: REJECT
      error_code: "ERR_MISSING_TERMINATION_REASON"
      error_message: "Termination reason is required when terminating an employee."
      http_status: 400
      severity: ERROR

  # ---------------------------------------------------------------------------
  
  - id: BR-WF-005
    name: "Minimum Employment Age"
    category: VALIDATION
    priority: CRITICAL
    status: APPROVED
    
    description: |
      Employee must be at least 16 years old at their hire date.
      This complies with labor law requirements.
    
    applies_to:
      entity: Employee
      entity_ref: "xtalent:core-hr:workforce:employee"
      attributes: [birth_date, hire_date]
      operations: [CREATE, UPDATE]
    
    condition:
      expression: "birth_date IS NULL OR DATE_DIFF(hire_date, birth_date, 'year') >= 16"
      language: SQL
    
    implementations:
      sql: "birth_date IS NULL OR DATEDIFF(year, birth_date, hire_date) >= 16"
      javascript: |
        if (!birthDate) return true;
        const age = Math.floor((hireDate - birthDate) / (365.25 * 24 * 60 * 60 * 1000));
        return age >= 16;
    
    on_violation:
      action: REJECT
      error_code: "ERR_UNDERAGE_EMPLOYEE"
      error_message: "Employee must be at least 16 years old at hire date."
      http_status: 400
      severity: ERROR
    
    regulatory_reference:
      law: "Vietnam Labor Code 2019"
      article: "Article 143"
      description: "Minimum working age requirements"

  # ---------------------------------------------------------------------------
  # CALCULATION RULES
  # ---------------------------------------------------------------------------
  
  - id: BR-WF-010
    name: "Calculate Years of Service"
    category: CALCULATION
    priority: MEDIUM
    status: APPROVED
    
    description: |
      Years of service is calculated from hire_date to current date 
      (or termination_date if terminated).
    
    applies_to:
      entity: Employee
      entity_ref: "xtalent:core-hr:workforce:employee"
      derived_attribute: years_of_service
    
    formula:
      expression: |
        CASE 
          WHEN status = 'TERMINATED' THEN 
            ROUND(DATE_DIFF(termination_date, hire_date, 'day') / 365.25, 2)
          ELSE 
            ROUND(DATE_DIFF(CURRENT_DATE, hire_date, 'day') / 365.25, 2)
        END
      language: SQL
    
    dependencies:
      - hire_date
      - termination_date
      - status
    
    recalculate_on:
      - "hire_date changed"
      - "termination_date changed"
      - "status changed"
      - "daily (for active employees)"
    
    test_cases:
      - name: "Active Employee - 4 years"
        input:
          hire_date: "2020-12-24"
          status: "ACTIVE"
          current_date: "2024-12-24"
        expected:
          years_of_service: 4.0
          
      - name: "Terminated Employee"
        input:
          hire_date: "2020-01-01"
          termination_date: "2022-07-01"
          status: "TERMINATED"
        expected:
          years_of_service: 2.5

  # ---------------------------------------------------------------------------
  
  - id: BR-WF-011
    name: "Determine Tenure Category"
    category: CALCULATION
    priority: LOW
    status: APPROVED
    
    description: |
      Categorize employees by tenure for reporting and benefits eligibility.
    
    applies_to:
      entity: Employee
      entity_ref: "xtalent:core-hr:workforce:employee"
      derived_attribute: tenure_category
    
    formula:
      expression: |
        CASE 
          WHEN years_of_service < 1 THEN 'NEW_HIRE'
          WHEN years_of_service < 3 THEN 'DEVELOPING'
          WHEN years_of_service < 5 THEN 'EXPERIENCED'
          WHEN years_of_service < 10 THEN 'SENIOR'
          ELSE 'VETERAN'
        END
      language: SQL
    
    dependencies:
      - years_of_service

  # ---------------------------------------------------------------------------
  
  - id: BR-WF-012
    name: "Promotion Eligibility"
    category: CALCULATION
    priority: MEDIUM
    status: APPROVED
    
    description: |
      Determines if employee meets basic promotion eligibility criteria.
    
    applies_to:
      entity: Employee
      entity_ref: "xtalent:core-hr:workforce:employee"
      derived_attribute: is_eligible_for_promotion
    
    formula:
      expression: |
        status = 'ACTIVE' 
        AND years_of_service >= 2 
        AND (
          SELECT AVG(rating) 
          FROM performance_reviews 
          WHERE employee_id = Employee.id 
          AND review_date >= DATE_SUB(CURRENT_DATE, INTERVAL 2 YEAR)
        ) >= 4.0
      language: SQL
    
    dependencies:
      - status
      - years_of_service
      - performance_reviews (external)

  # ---------------------------------------------------------------------------
  # AUTHORIZATION RULES
  # ---------------------------------------------------------------------------
  
  - id: BR-WF-020
    name: "Only HR Can Terminate Employees"
    category: AUTHORIZATION
    priority: HIGH
    status: APPROVED
    
    description: |
      Only users with HR roles can execute employee termination.
    
    applies_to:
      action: TerminateEmployee
      action_ref: "xtalent:core-hr:workforce:terminate-employee"
    
    condition:
      expression: "user.role IN ('HR_SPECIALIST', 'HR_MANAGER', 'HR_ADMIN')"
      language: PSEUDOCODE
    
    on_violation:
      action: DENY
      error_code: "ERR_UNAUTHORIZED_TERMINATION"
      error_message: "You do not have permission to terminate employees."
      http_status: 403
      severity: ERROR
      
    audit:
      log_attempts: true
      alert_on_violation: true
      alert_recipients: ["security@company.com"]

  # ---------------------------------------------------------------------------
  
  - id: BR-WF-021
    name: "Manager Can Only View Own Team"
    category: AUTHORIZATION
    priority: HIGH
    status: APPROVED
    
    description: |
      Non-HR managers can only view employees in their reporting line.
    
    applies_to:
      entity: Employee
      entity_ref: "xtalent:core-hr:workforce:employee"
      operations: [READ]
    
    condition:
      expression: |
        user.role IN ('HR_SPECIALIST', 'HR_MANAGER', 'HR_ADMIN')
        OR user.employee_id = employee.id
        OR user.employee_id = employee.manager_id
        OR EXISTS (
          -- Recursive check for indirect reports
          SELECT 1 FROM employee_hierarchy 
          WHERE ancestor_id = user.employee_id 
          AND descendant_id = employee.id
        )
      language: PSEUDOCODE
    
    implementation_note: |
      This requires a materialized hierarchy table (employee_hierarchy)
      that is updated whenever manager_id changes.

  # ---------------------------------------------------------------------------
  # WORKFLOW RULES
  # ---------------------------------------------------------------------------
  
  - id: BR-WF-030
    name: "Activation Requires Department"
    category: WORKFLOW
    priority: HIGH
    status: APPROVED
    
    description: |
      Employee cannot be activated (DRAFT → ACTIVE) without 
      being assigned to a department.
    
    applies_to:
      entity: Employee
      entity_ref: "xtalent:core-hr:workforce:employee"
      lifecycle_transition: "DRAFT → ACTIVE"
    
    condition:
      expression: "department_id IS NOT NULL"
      language: SQL
    
    on_violation:
      action: BLOCK_TRANSITION
      error_code: "ERR_ACTIVATION_NO_DEPARTMENT"
      error_message: "Employee must be assigned to a department before activation."
      http_status: 400
      severity: ERROR

  # ---------------------------------------------------------------------------
  
  - id: BR-WF-031
    name: "Activation Requires Assignment"
    category: WORKFLOW
    priority: HIGH
    status: APPROVED
    
    description: |
      Employee cannot be activated without at least one active job assignment.
    
    applies_to:
      entity: Employee
      entity_ref: "xtalent:core-hr:workforce:employee"
      lifecycle_transition: "DRAFT → ACTIVE"
    
    condition:
      expression: |
        EXISTS (
          SELECT 1 FROM assignment 
          WHERE employee_id = Employee.id 
          AND status = 'ACTIVE'
        )
      language: SQL
    
    on_violation:
      action: BLOCK_TRANSITION
      error_code: "ERR_ACTIVATION_NO_ASSIGNMENT"
      error_message: "Employee must have at least one active assignment before activation."
      http_status: 400
      severity: ERROR

# ============================================================================
# RULE DEPENDENCIES
# ============================================================================
dependencies:
  BR-WF-010:
    depends_on: []
    required_by: [BR-WF-011, BR-WF-012]
    
  BR-WF-011:
    depends_on: [BR-WF-010]
    required_by: []
    
  BR-WF-012:
    depends_on: [BR-WF-010]
    required_by: []

# ============================================================================
# TRACEABILITY MATRIX
# ============================================================================
traceability:
  - rule_id: BR-WF-001
    entity: Employee
    fr_id: FR-WF-001
    bdd_scenarios:
      - "employee.feature#hire-date-cannot-be-future"
    test_coverage: 100%
    
  - rule_id: BR-WF-002
    entity: Employee
    fr_id: FR-WF-002
    bdd_scenarios:
      - "employee.feature#termination-date-validation"
    test_coverage: 100%
    
  # ... etc for all rules

# ============================================================================
# REFERENCES
# ============================================================================
references:
  entity_definitions:
    - "../../00-ontology/domain/01-workforce/employee.entity.yaml"
  functional_requirements:
    - "../01-FR/FR-01-workforce.md"
  bdd_scenarios:
    - "../05-BDD/01-workforce/employee.feature"
  concept_guides:
    - "../../01-concept/02-workforce/employee-guide.md"
```

---

## 🏷️ Rule Categories

| Category | Description | Example |
|----------|-------------|---------|
| `VALIDATION` | Data integrity checks | Hire date not future |
| `CALCULATION` | Computed values | Years of service |
| `AUTHORIZATION` | Permission checks | Only HR can terminate |
| `WORKFLOW` | State transition guards | Must have department to activate |
| `INTEGRATION` | Cross-system rules | Sync with payroll |

---

## ⚡ Rule Priority

| Priority | Description | Response Time |
|----------|-------------|---------------|
| `CRITICAL` | System cannot function without | Immediate |
| `HIGH` | Core business logic | < 1 sprint |
| `MEDIUM` | Important but not blocking | < 2 sprints |
| `LOW` | Nice to have | Backlog |

---

## 🔄 Rule Lifecycle

```
DRAFT → REVIEW → APPROVED → ACTIVE → DEPRECATED → RETIRED
```

---

## 🤖 AI Agent Usage

When generating code from business rules:

1. **Read the `condition.expression`** for logic
2. **Use `implementations.*`** for language-specific code
3. **Apply `on_violation`** for error handling
4. **Generate tests from `test_cases`**
5. **Maintain traceability** with `traces`

---

## 📚 Related Documents

- [02-ENTITY-SCHEMA.md](./02-ENTITY-SCHEMA.md) — Entity validation rules
- [03-WORKFLOW-SCHEMA.md](./03-WORKFLOW-SCHEMA.md) — Workflow transitions
- [06-BDD-INTEGRATION.md](./06-BDD-INTEGRATION.md) — Test generation
