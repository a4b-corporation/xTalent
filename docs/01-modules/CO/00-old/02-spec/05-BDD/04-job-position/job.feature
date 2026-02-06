# language: en
Feature: Job Management
  As a Job Administrator
  I want to manage jobs in the job catalog
  So that I can create position templates

  Background:
    Given I am logged in as "Job Admin"
    And a corporate job tree exists with code "CORP_JOB"
    And a BU job tree exists with code "BU_GAME_JOB"

  # CRUD Operations
  Scenario: Create corporate job
    When I create a job with:
      | tree_id    | corp-tree-001     |
      | job_code   | ENG_SOFTWARE      |
      | job_title  | Software Engineer |
      | owner_scope| CORP              |
      | level_code | L3                |
      | grade_code | E3                |
    Then the job should be created
    And the job should be in "CORP_JOB" tree

  Scenario: Create BU job with inheritance
    Given a corporate job exists with code "ENG_SOFTWARE"
    When I create a BU job with:
      | tree_id      | bu-game-tree-001  |
      | job_code     | ENG_SOFTWARE      |
      | parent_id    | <corp-job-id>     |
      | owner_scope  | BU                |
      | owner_unit_id| bu-game-001       |
      | inherit_flag | true              |
    Then the job should inherit from corporate job

  Scenario: Create BU job with override
    Given a corporate job exists with code "ENG_SOFTWARE" and grade "E3"
    When I create a BU job with:
      | job_code       | ENG_SOFTWARE           |
      | inherit_flag   | false                  |
      | override_title | Game Software Engineer |
      | grade_code     | E4                     |
    Then the job should override corporate job
    And the grade should be "E4"

  # Validation
  Scenario: Cannot create duplicate job code in same tree
    Given a job exists with code "ENG_SOFTWARE" in "CORP_JOB"
    When I create another job with same code in same tree
    Then the creation should fail
    And I should see error "Job code must be unique within tree"

  Scenario: Parent must be in same tree
    Given a job exists in "CORP_JOB" tree
    When I create a job in "BU_GAME_JOB" with parent from "CORP_JOB"
    Then the creation should fail

  # SCD2
  Scenario: Update job grade creates new version
    Given a job exists with grade "E3"
    When I update the grade to "E4"
    Then a new version should be created
    And the old version should have effective_end_date
    And the new version should have effective_start_date

  # Lifecycle
  Scenario: Deprecate job
    Given an active job
    When I deprecate the job with reason "Obsolete role"
    Then the job status should be "DEPRECATED"
    And no new positions can be created from this job
