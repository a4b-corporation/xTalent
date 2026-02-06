# language: en
Feature: Employee Management
  As an HR Administrator
  I want to manage employees
  So that I can track employment relationships

  Background:
    Given I am logged in as "HR Admin"
    And a worker exists with id "worker-001"
    And a legal entity exists with code "VNG_HQ"

  # CRUD Operations
  Scenario: Create employee
    When I create an employee with:
      | worker_id            | worker-001  |
      | legal_entity_code    | VNG_HQ      |
      | employee_code        | EMP001234   |
      | worker_category_code | EMPLOYEE    |
      | employee_class_code  | FULL_TIME   |
      | hire_date            | 2025-01-15  |
    Then the employee should be created
    And the status should be "PENDING"

  Scenario: Activate employee on hire date
    Given an employee in "PENDING" status with hire_date "2025-01-15"
    When the hire date is reached
    Then the status should change to "ACTIVE"

  Scenario: Terminate employee
    Given an active employee
    When I terminate the employee with:
      | termination_date   | 2025-12-31  |
      | termination_reason | RESIGNATION |
    Then the status should change to "TERMINATED"
    And all active contracts should be ended
    And all active assignments should be ended

  # Validation
  Scenario: Cannot create duplicate employee code
    Given an employee exists with code "EMP001234" in "VNG_HQ"
    When I create another employee with same code
    Then the creation should fail
    And I should see error "Employee code must be unique within legal entity"

  Scenario: Termination date must be after hire date
    Given an employee with hire_date "2025-01-15"
    When I set termination_date to "2024-12-31"
    Then the update should fail

  # Lifecycle
  Scenario: Employee lifecycle
    Given a new employee in "PENDING" status
    When I activate the employee
    Then the status should be "ACTIVE"
    When I suspend the employee
    Then the status should be "SUSPENDED"
    When I reactivate the employee
    Then the status should be "ACTIVE"
    When I terminate the employee
    Then the status should be "TERMINATED"
