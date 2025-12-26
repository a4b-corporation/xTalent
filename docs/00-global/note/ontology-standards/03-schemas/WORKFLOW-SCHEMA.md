# Workflow & Action Schema Specification

**Version**: 3.0  
**Format**: YAML  
**Audience**: AI Agents, BAs, Developers

---

> [!CAUTION]
> **Workflow schema MUST NOT be referenced as ontology or business truth.**
> 
> Workflows describe **execution** (how things happen over time), not **semantic truth** (what things are).
> For business meaning and entity definitions, see [ENTITY-SCHEMA.md](./ENTITY-SCHEMA.md).

---

## 🎯 Purpose

This document defines schemas for:
1. **Workflows** (`*.workflow.yaml`) — Multi-step business processes
2. **Actions** (`*.action.yaml`) — Atomic operations (like Palantir Actions)

The key distinction:
- **Actions** are atomic, testable, reusable operations
- **Workflows** compose actions into business processes

---

## 📋 Action Schema

Actions are atomic operations that modify entity state. They map directly to Palantir's Action Types.

```yaml
# ============================================================================
# ACTION SCHEMA v3.0
# ============================================================================

# ----------------------------------------------------------------------------
# HEADER
# ----------------------------------------------------------------------------
$schema: "https://xtalent.io/schemas/action/v3"
$id: "xtalent:core-hr:workforce:terminate-employee"

module: CORE-HR
submodule: workforce
version: "1.0"

# ----------------------------------------------------------------------------
# ACTION DEFINITION
# ----------------------------------------------------------------------------
action: TerminateEmployee
type: MUTATING  # MUTATING | QUERY | SIDE_EFFECT_ONLY

definition: |
  Ends an employee's employment relationship with the organization.
  This is an irreversible action that sets status to TERMINATED.

category: LIFECYCLE  # LIFECYCLE | CRUD | CALCULATION | INTEGRATION | APPROVAL

# ----------------------------------------------------------------------------
# TARGET ENTITY
# ----------------------------------------------------------------------------
target:
  entity: Employee
  entity_ref: "xtalent:core-hr:workforce:employee"
  
# Secondary entities affected
affects:
  - entity: Assignment
    entity_ref: "xtalent:core-hr:workforce:assignment"
    operation: UPDATE  # CREATE | UPDATE | DELETE
  - entity: Benefit
    entity_ref: "xtalent:benefits:enrollment:benefit"
    operation: UPDATE

# ----------------------------------------------------------------------------
# PARAMETERS (Input)
# ----------------------------------------------------------------------------
parameters:
  employee_id:
    type: uuid
    required: true
    description: "ID of employee to terminate"
    source: PATH  # PATH | QUERY | BODY | HEADER
    
  termination_date:
    type: date
    required: true
    description: "Effective date of termination"
    constraints:
      - "termination_date >= today()"
      - "termination_date >= employee.hire_date"
    
  termination_reason:
    type: enum
    required: true
    values:
      - VOLUNTARY_RESIGNATION
      - INVOLUNTARY_TERMINATION
      - RETIREMENT
      - END_OF_CONTRACT
      - DEATH
      - OTHER
    description: "Reason for termination"
    
  termination_notes:
    type: string
    required: false
    max_length: 2000
    description: "Additional notes about the termination"
    
  final_paycheck_date:
    type: date
    required: false
    description: "Date of final paycheck"
    default: "termination_date"
    
  eligible_for_rehire:
    type: boolean
    required: true
    description: "Whether employee is eligible for future rehire"

# ----------------------------------------------------------------------------
# PRECONDITIONS (Guards)
# ----------------------------------------------------------------------------
preconditions:
  - id: PRE-001
    name: "employee_exists"
    expression: "EXISTS(Employee WHERE id = :employee_id)"
    error_code: "ERR_EMPLOYEE_NOT_FOUND"
    error_message: "Employee with ID {employee_id} not found"
    
  - id: PRE-002
    name: "employee_is_active"
    expression: "Employee.status IN ('ACTIVE', 'INACTIVE')"
    error_code: "ERR_INVALID_STATUS"
    error_message: "Can only terminate employees with ACTIVE or INACTIVE status"
    
  - id: PRE-003
    name: "user_has_permission"
    expression: "user.hasPermission('HR_TERMINATE_EMPLOYEE')"
    error_code: "ERR_UNAUTHORIZED"
    error_message: "User does not have permission to terminate employees"
    
  - id: PRE-004
    name: "not_already_terminated"
    expression: "Employee.status != 'TERMINATED'"
    error_code: "ERR_ALREADY_TERMINATED"
    error_message: "Employee is already terminated"

# ----------------------------------------------------------------------------
# MUTATIONS (State Changes)
# ----------------------------------------------------------------------------
mutations:
  - entity: Employee
    operations:
      - attribute: status
        operation: SET
        value: "TERMINATED"
        
      - attribute: termination_date
        operation: SET
        value: ":termination_date"
        
      - attribute: termination_reason
        operation: SET
        value: ":termination_reason"
        
      - attribute: termination_notes
        operation: SET
        value: ":termination_notes"
        
      - attribute: eligible_for_rehire
        operation: SET
        value: ":eligible_for_rehire"
        
  - entity: Assignment
    filter: "employee_id = :employee_id AND status = 'ACTIVE'"
    operations:
      - attribute: status
        operation: SET
        value: "ENDED"
        
      - attribute: end_date
        operation: SET
        value: ":termination_date"

# ----------------------------------------------------------------------------
# SIDE EFFECTS
# ----------------------------------------------------------------------------
side_effects:
  - type: EVENT
    name: "EmployeeTerminated"
    payload:
      employee_id: ":employee_id"
      termination_date: ":termination_date"
      termination_reason: ":termination_reason"
    description: "Domain event published for downstream systems"
    
  - type: NOTIFICATION
    template: "employee_termination_notification"
    recipients:
      - role: HR_MANAGER
      - role: DEPARTMENT_HEAD
      - expression: "Employee.manager"
    channels: [EMAIL, IN_APP]
    
  - type: INTEGRATION
    system: PAYROLL
    endpoint: "/api/v1/employees/{employee_id}/final-settlement"
    method: POST
    payload:
      termination_date: ":termination_date"
      final_paycheck_date: ":final_paycheck_date"
    async: true
    
  - type: AUDIT
    action: "EMPLOYEE_TERMINATED"
    details:
      employee_id: ":employee_id"
      performed_by: ":current_user"
      termination_reason: ":termination_reason"

# ----------------------------------------------------------------------------
# POSTCONDITIONS (Validation after execution)
# ----------------------------------------------------------------------------
postconditions:
  - id: POST-001
    expression: "Employee.status = 'TERMINATED'"
    description: "Employee status must be TERMINATED"
    
  - id: POST-002
    expression: "COUNT(Assignment WHERE employee_id = :employee_id AND status = 'ACTIVE') = 0"
    description: "No active assignments should remain"

# ----------------------------------------------------------------------------
# ERROR HANDLING
# ----------------------------------------------------------------------------
error_handling:
  rollback_on_failure: true
  
  errors:
    - code: ERR_EMPLOYEE_NOT_FOUND
      http_status: 404
      severity: ERROR
      recoverable: false
      
    - code: ERR_INVALID_STATUS
      http_status: 400
      severity: ERROR
      recoverable: false
      
    - code: ERR_UNAUTHORIZED
      http_status: 403
      severity: ERROR
      recoverable: false
      
    - code: ERR_INTEGRATION_FAILURE
      http_status: 500
      severity: WARNING
      recoverable: true
      retry:
        max_attempts: 3
        delay_seconds: 60

# ----------------------------------------------------------------------------
# AUTHORIZATION
# ----------------------------------------------------------------------------
authorization:
  required_permissions:
    - HR_TERMINATE_EMPLOYEE
    
  required_roles:
    - HR_MANAGER
    - HR_ADMIN
    
  additional_checks:
    - "user.department_id = Employee.department_id OR user.is_hr_admin"

# ----------------------------------------------------------------------------
# API MAPPING
# ----------------------------------------------------------------------------
api:
  method: POST
  path: "/api/v1/employees/{employee_id}/terminate"
  request_body:
    content_type: "application/json"
    schema:
      type: object
      required: [termination_date, termination_reason, eligible_for_rehire]
      properties:
        termination_date:
          type: string
          format: date
        termination_reason:
          type: string
          enum: [VOLUNTARY_RESIGNATION, INVOLUNTARY_TERMINATION, ...]
        # ... other parameters
        
  response:
    success:
      status: 200
      body:
        employee_id: uuid
        status: "TERMINATED"
        termination_date: date
    errors:
      - status: 404
        body:
          error_code: "ERR_EMPLOYEE_NOT_FOUND"
          message: string

# ----------------------------------------------------------------------------
# BDD SCENARIO TEMPLATE
# ----------------------------------------------------------------------------
bdd_template: |
  @action(terminate-employee)
  @trace({$id})
  Scenario: Terminate an active employee
    Given an employee with status "ACTIVE"
    And the employee has active assignments
    When I execute action "TerminateEmployee" with:
      | termination_date   | {date}               |
      | termination_reason | VOLUNTARY_RESIGNATION |
      | eligible_for_rehire | true                 |
    Then the employee status should be "TERMINATED"
    And all active assignments should be ended
    And a "EmployeeTerminated" event should be published
    And HR Manager should receive a notification

# ----------------------------------------------------------------------------
# EXAMPLES
# ----------------------------------------------------------------------------
examples:
  - name: "Voluntary Resignation"
    input:
      employee_id: "550e8400-e29b-41d4-a716-446655440000"
      termination_date: "2024-12-31"
      termination_reason: "VOLUNTARY_RESIGNATION"
      eligible_for_rehire: true
    expected_outcome:
      status: "success"
      employee_status: "TERMINATED"
      
  - name: "Involuntary Termination"
    input:
      employee_id: "550e8400-e29b-41d4-a716-446655440001"
      termination_date: "2024-12-15"
      termination_reason: "INVOLUNTARY_TERMINATION"
      termination_notes: "Policy violation"
      eligible_for_rehire: false
    expected_outcome:
      status: "success"

# ----------------------------------------------------------------------------
# REFERENCES
# ----------------------------------------------------------------------------
references:
  entity: "../../domain/01-workforce/employee.aggregate.yaml"
  workflow: "../workflows/employee-offboarding.workflow.yaml"
  business_rules:
    - "../../02-spec/04-BR/BR-01-workforce.md#termination-rules"
  bdd_scenarios: "../../02-spec/05-BDD/01-workforce/termination.feature"
```

---

## 📋 Workflow Schema

Workflows compose actions and decision points into business processes.

```yaml
# ============================================================================
# WORKFLOW SCHEMA v3.0
# ============================================================================

# ----------------------------------------------------------------------------
# HEADER
# ----------------------------------------------------------------------------
$schema: "https://xtalent.io/schemas/workflow/v3"
$id: "xtalent:core-hr:workforce:WF-001-employee-onboarding"

module: CORE-HR
submodule: workforce
version: "1.0"

# ----------------------------------------------------------------------------
# WORKFLOW DEFINITION
# ----------------------------------------------------------------------------
workflow: EmployeeOnboarding
workflow_code: "WF-001"

definition: |
  Complete process for onboarding a new employee from offer acceptance
  to first day completion, including system setup, equipment provisioning,
  and orientation scheduling.

type: TRANSACTIONAL  # TRANSACTIONAL | BATCH | SCHEDULED | EVENT_DRIVEN
category: LIFECYCLE
priority: HIGH
frequency: ON_DEMAND

# Estimated duration
sla:
  target_duration: "5 business days"
  max_duration: "10 business days"

# ----------------------------------------------------------------------------
# TRIGGERS
# ----------------------------------------------------------------------------
triggers:
  - type: EVENT
    event: "OfferAccepted"
    source: "xtalent:recruiting:offers"
    
  - type: MANUAL
    initiator_roles: [HR_SPECIALIST, HR_MANAGER]
    
  - type: API
    endpoint: "/api/v1/workflows/employee-onboarding"
    method: POST

# ----------------------------------------------------------------------------
# ACTORS
# ----------------------------------------------------------------------------
actors:
  - role: HR_SPECIALIST
    responsibilities:
      - "Initiate workflow"
      - "Create employee record"
      - "Verify documentation"
      
  - role: HIRING_MANAGER
    responsibilities:
      - "Approve start date"
      - "Assign equipment"
      
  - role: IT_SUPPORT
    responsibilities:
      - "Create system accounts"
      - "Provision equipment"
      
  - role: NEW_EMPLOYEE
    responsibilities:
      - "Complete paperwork"
      - "Attend orientation"

# ----------------------------------------------------------------------------
# WORKFLOW INPUT
# ----------------------------------------------------------------------------
input:
  offer_id:
    type: uuid
    required: true
    source: "trigger.event.offer_id"
    
  candidate_data:
    type: object
    required: true
    properties:
      first_name: string
      last_name: string
      email: string
      phone: string
      position_id: uuid
      department_id: uuid
      start_date: date
      salary: decimal

# ----------------------------------------------------------------------------
# WORKFLOW STEPS
# ----------------------------------------------------------------------------
steps:
  # Step 1: Create Employee Record
  - id: STEP-001
    name: "Create Employee Record"
    type: ACTION
    action_ref: "xtalent:core-hr:workforce:create-employee"
    
    actor: HR_SPECIALIST
    
    input_mapping:
      first_name: "input.candidate_data.first_name"
      last_name: "input.candidate_data.last_name"
      email: "input.candidate_data.email"
      hire_date: "input.candidate_data.start_date"
      department_id: "input.candidate_data.department_id"
      
    output:
      employee_id: "action.result.employee_id"
      employee_code: "action.result.employee_code"
      
    on_success: STEP-002
    on_failure: STEP-ERR-001
    
    timeout: "1 hour"
    
  # Step 2: Create Assignment
  - id: STEP-002
    name: "Create Job Assignment"
    type: ACTION
    action_ref: "xtalent:core-hr:workforce:create-assignment"
    
    actor: HR_SPECIALIST
    
    input_mapping:
      employee_id: "steps.STEP-001.output.employee_id"
      position_id: "input.candidate_data.position_id"
      effective_date: "input.candidate_data.start_date"
      salary: "input.candidate_data.salary"
      
    on_success: STEP-003
    on_failure: STEP-ERR-001
    
  # Step 3: Parallel Tasks (Gateway)
  - id: STEP-003
    name: "Parallel Provisioning"
    type: PARALLEL_GATEWAY
    
    branches:
      - id: BRANCH-IT
        steps:
          - id: STEP-003A
            name: "Create System Accounts"
            type: ACTION
            action_ref: "xtalent:it-services:accounts:create-user-accounts"
            actor: IT_SUPPORT
            
          - id: STEP-003B
            name: "Provision Equipment"
            type: ACTION
            action_ref: "xtalent:it-services:equipment:provision-workstation"
            actor: IT_SUPPORT
            
      - id: BRANCH-HR
        steps:
          - id: STEP-003C
            name: "Schedule Orientation"
            type: ACTION
            action_ref: "xtalent:learning:sessions:schedule-orientation"
            actor: HR_SPECIALIST
            
          - id: STEP-003D
            name: "Send Welcome Package"
            type: ACTION
            action_ref: "xtalent:communications:emails:send-welcome-email"
            actor: HR_SPECIALIST
            
    join_condition: ALL  # ALL | ANY | N_OF_M
    on_complete: STEP-004
    
  # Step 4: Decision Point
  - id: STEP-004
    name: "Check Documentation Status"
    type: DECISION_GATEWAY
    
    decision_attribute: "employee.documentation_complete"
    
    branches:
      - condition: "documentation_complete = true"
        next: STEP-005
        
      - condition: "documentation_complete = false"
        next: STEP-004A
        
  # Step 4A: Wait for Documentation
  - id: STEP-004A
    name: "Await Documentation"
    type: WAIT
    
    wait_for:
      type: EVENT
      event: "DocumentationCompleted"
      timeout: "5 business days"
      
    on_event: STEP-005
    on_timeout: STEP-ESCALATE
    
  # Step 5: Manager Approval
  - id: STEP-005
    name: "Manager Approval"
    type: APPROVAL
    
    actor: HIRING_MANAGER
    
    approval_request:
      title: "New Employee Ready for Start"
      description: "Please confirm the new employee is ready to start"
      data_to_review:
        - employee_name
        - start_date
        - equipment_status
        - accounts_status
        
    outcomes:
      APPROVED:
        next: STEP-006
      REJECTED:
        next: STEP-005A
        reason_required: true
        
    timeout: "2 business days"
    escalate_on_timeout: true
    
  # Step 6: Complete Onboarding
  - id: STEP-006
    name: "Complete Onboarding"
    type: ACTION
    action_ref: "xtalent:core-hr:workforce:complete-onboarding"
    
    input_mapping:
      employee_id: "steps.STEP-001.output.employee_id"
      
    on_success: STEP-END
    
  # End Step
  - id: STEP-END
    name: "Onboarding Complete"
    type: END
    
    final_status: COMPLETED
    
    output:
      employee_id: "steps.STEP-001.output.employee_id"
      employee_code: "steps.STEP-001.output.employee_code"
      completion_date: "now()"
      
  # Error Handling Step
  - id: STEP-ERR-001
    name: "Handle Error"
    type: ERROR_HANDLER
    
    actions:
      - notify:
          roles: [HR_MANAGER]
          template: "onboarding_error"
      - log:
          level: ERROR
          message: "Onboarding failed"
          
    final_status: FAILED

# ----------------------------------------------------------------------------
# WORKFLOW STATE
# ----------------------------------------------------------------------------
state:
  persistence: DATABASE
  table: workflow_instances
  
  attributes:
    workflow_id: uuid
    workflow_code: string
    status: enum [PENDING, IN_PROGRESS, COMPLETED, FAILED, CANCELLED]
    current_step: string
    started_at: datetime
    completed_at: datetime
    context: jsonb  # Store workflow variables

# ----------------------------------------------------------------------------
# NOTIFICATIONS
# ----------------------------------------------------------------------------
notifications:
  - event: WORKFLOW_STARTED
    template: "onboarding_started"
    recipients: [HR_SPECIALIST, HIRING_MANAGER]
    
  - event: STEP_REQUIRES_ACTION
    template: "action_required"
    recipients: [step.actor]
    
  - event: WORKFLOW_COMPLETED
    template: "onboarding_completed"
    recipients: [HR_SPECIALIST, HIRING_MANAGER, NEW_EMPLOYEE]
    
  - event: WORKFLOW_FAILED
    template: "onboarding_failed"
    recipients: [HR_MANAGER]

# ----------------------------------------------------------------------------
# VISUALIZATION
# ----------------------------------------------------------------------------
diagram: |
  ```mermaid
  stateDiagram-v2
      [*] --> CreateEmployee: Start
      CreateEmployee --> CreateAssignment
      CreateAssignment --> ParallelProvisioning
      
      state ParallelProvisioning {
          [*] --> ITSetup
          [*] --> HRSetup
          ITSetup --> [*]
          HRSetup --> [*]
      }
      
      ParallelProvisioning --> CheckDocumentation
      CheckDocumentation --> AwaitDocs: Incomplete
      CheckDocumentation --> ManagerApproval: Complete
      AwaitDocs --> ManagerApproval: Received
      ManagerApproval --> Complete: Approved
      ManagerApproval --> Revision: Rejected
      Revision --> ManagerApproval
      Complete --> [*]
  ```

# ----------------------------------------------------------------------------
# METRICS
# ----------------------------------------------------------------------------
metrics:
  - name: "avg_completion_time"
    description: "Average time to complete onboarding"
    calculation: "AVG(completed_at - started_at)"
    
  - name: "approval_rate"
    description: "Percentage approved on first attempt"
    calculation: "COUNT(APPROVED) / COUNT(TOTAL)"
    
  - name: "bottleneck_step"
    description: "Step with longest average duration"

# ----------------------------------------------------------------------------
# REFERENCES
# ----------------------------------------------------------------------------
references:
  entities:
    - "../../domain/01-workforce/employee.aggregate.yaml"
    - "../../domain/01-workforce/assignment.entity.yaml"
  actions:
    - "../actions/create-employee.action.yaml"
    - "../actions/create-assignment.action.yaml"
  concept_guide: "../../01-concept/01-workforce/onboarding-guide.md"
  bdd_scenarios: "../../02-spec/05-BDD/01-workforce/onboarding.feature"
```

---

## 🔀 Step Types Reference

| Type | Description | Use Case |
|------|-------------|----------|
| `ACTION` | Execute an atomic action | Create record, update status |
| `APPROVAL` | Request human approval | Manager sign-off |
| `DECISION_GATEWAY` | Branch based on condition | If-then logic |
| `PARALLEL_GATEWAY` | Execute branches in parallel | Multiple departments |
| `WAIT` | Wait for event or timeout | Await documentation |
| `NOTIFICATION` | Send notification only | Inform stakeholders |
| `INTEGRATION` | Call external system | Sync with payroll |
| `END` | Terminal state | Workflow complete |
| `ERROR_HANDLER` | Handle failures | Rollback, notify |

---

## 📚 Related Documents

- [02-ENTITY-SCHEMA.md](./02-ENTITY-SCHEMA.md) — Entity definitions
- [04-QUERY-LANGUAGE.md](./04-QUERY-LANGUAGE.md) — Querying workflows
- [06-BDD-INTEGRATION.md](./06-BDD-INTEGRATION.md) — Testing workflows
