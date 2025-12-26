# language: en
Feature: Position Management
  As an HR Administrator
  I want to manage positions
  So that I can plan headcount and fill vacancies

  Background:
    Given I am logged in as "HR Admin"
    And a job exists with code "ENG_SOFTWARE"
    And a business unit exists with code "BACKEND"

  # CRUD Operations
  Scenario: Create position
    When I create a position with:
      | code             | POS-ENG-001        |
      | title            | Software Engineer  |
      | job_id           | <job-id>           |
      | business_unit_id | <bu-id>            |
      | position_type_code | STANDARD         |
      | max_incumbents   | 1                  |
    Then the position should be created
    And the status should be "PLANNED"
    And actual_headcount should be 0

  Scenario: Fill position
    Given an open position with max_incumbents 1
    And an active employee exists
    When I fill the position with the employee
    Then actual_headcount should increase to 1
    And the status should change to "FILLED"

  Scenario: Reopen filled position
    Given a filled position
    When an employee leaves the position
    Then actual_headcount should decrease
    And the status should change to "OPEN"

  # Validation
  Scenario: Cannot exceed max incumbents
    Given a position with max_incumbents 1
    And actual_headcount is 1
    When I try to assign another employee
    Then the assignment should fail
    And I should see error "Actual headcount cannot exceed max incumbents"

  Scenario: job_id is required (17dec2025)
    When I create a position without job_id
    Then the creation should fail
    And I should see error "Job ID is required"

  # Headcount Management
  Scenario: Vacancy tracking
    Given a position with:
      | max_incumbents   | 3 |
      | actual_headcount | 1 |
    Then is_vacant should be true
    And vacancy_count should be 2

  Scenario: Position filled when all slots occupied
    Given a position with max_incumbents 2
    And actual_headcount is 1
    When I assign one more employee
    Then actual_headcount should be 2
    And status should automatically change to "FILLED"

  # Lifecycle
  Scenario: Position lifecycle
    Given a new position in "PLANNED" status
    When I approve the position
    Then the status should be "APPROVED"
    When I open the position
    Then the status should be "OPEN"
    When I fill all slots
    Then the status should be "FILLED"

  Scenario: Eliminate position
    Given a position with no active assignments
    When I eliminate the position with reason "Org restructuring"
    Then the status should be "ELIMINATED"
    And effective_end_date should be set

  # 17dec2025 Changes
  Scenario: Access grade via job_id
    Given a position with job_id referencing job with grade "E3"
    Then effective_grade_code should be "E3"
    And I should not need job_profile_id for compensation

  Scenario: Optional job_profile_id
    When I create a position with only job_id (no job_profile_id)
    Then the creation should succeed
    And the position should function normally
