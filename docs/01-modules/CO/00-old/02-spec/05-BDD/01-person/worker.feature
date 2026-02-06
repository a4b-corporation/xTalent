Feature: Worker Management
  As an HR Administrator or Worker
  I want to manage worker records
  So that I can maintain accurate person data throughout the employee lifecycle

  Background:
    Given the system is configured with:
      | setting | value |
      | minimum_working_age | 16 |
      | gdpr_enabled | true |
      | audit_logging | true |

  # ═══════════════════════════════════════════════════════════════════
  # CREATE WORKER
  # ═══════════════════════════════════════════════════════════════════
  
  Scenario: Create worker with complete information
    Given I am authenticated as "HR Admin"
    And I have valid worker data:
      | field | value |
      | first_name | John |
      | middle_name | Michael |
      | last_name | Doe |
      | preferred_name | Johnny |
      | date_of_birth | 1990-05-15 |
      | gender_code | M |
      | nationality_code | VN |
      | marital_status_code | SINGLE |
    When I create a new worker
    Then the worker should be created successfully
    And the worker should have a unique ID
    And the worker state should be "DRAFT"
    And a "WorkerCreated" event should be emitted
    And an audit log entry should be created with operation "CREATE"

  Scenario: Create worker with minimum required fields
    Given I am authenticated as "HR Admin"
    And I have minimal worker data:
      | field | value |
      | first_name | Jane |
      | last_name | Smith |
      | date_of_birth | 1995-08-20 |
      | gender_code | F |
      | nationality_code | US |
    When I create a new worker
    Then the worker should be created successfully
    And the worker should have a unique ID

  Scenario: Prevent creating underage worker
    Given I am authenticated as "HR Admin"
    And I have worker data with date_of_birth "2015-01-01"
    When I attempt to create the worker
    Then the creation should fail
    And I should see error code "ERR_WORKER_TOO_YOUNG"
    And I should see error message "Worker must be at least 16 years old"

  Scenario: Prevent creating worker with invalid name format
    Given I am authenticated as "HR Admin"
    And I have worker data with first_name "John123"
    When I attempt to create the worker
    Then the creation should fail
    And I should see error code "ERR_WORKER_INVALID_NAME"
    And I should see error message containing "special characters"

  Scenario: Warn about potential duplicate worker
    Given I am authenticated as "HR Admin"
    And a worker exists with:
      | first_name | last_name | date_of_birth |
      | John | Doe | 1990-05-15 |
    When I create a new worker with same name and DOB
    Then I should receive a warning about potential duplicate
    But the worker should still be created
    And the warning should be logged for manual review

  # ═══════════════════════════════════════════════════════════════════
  # UPDATE WORKER PROFILE
  # ═══════════════════════════════════════════════════════════════════

  Scenario: Worker updates own preferred name (self-service)
    Given I am authenticated as a worker with ID "550e8400-e29b-41d4-a716-446655440000"
    And my current preferred name is "John"
    When I update my preferred name to "Johnny"
    Then my profile should be updated
    And my preferred name should be "Johnny"
    And a "WorkerUpdated" event should be emitted
    And an audit log entry should record the change

  Scenario: Worker updates own metadata (avatar)
    Given I am authenticated as a worker
    When I update my metadata with avatar_url "https://cdn.example.com/avatar.jpg"
    Then my profile should be updated
    And my metadata should contain the new avatar URL

  Scenario: Worker cannot update restricted fields
    Given I am authenticated as a worker
    When I attempt to update my marital_status_code to "MARRIED"
    Then the update should fail
    And I should see error "You do not have permission to update these fields"

  Scenario: HR Admin updates worker marital status
    Given I am authenticated as "HR Admin"
    And a worker exists with ID "550e8400-e29b-41d4-a716-446655440000"
    When I update the worker's marital_status_code to "MARRIED"
    Then the worker's marital status should be updated
    And an audit log should record:
      | field | old_value | new_value |
      | marital_status_code | SINGLE | MARRIED |

  Scenario: Prevent updating immutable fields
    Given I am authenticated as "HR Admin"
    And a worker exists with date_of_birth "1990-05-15"
    When I attempt to update the worker's date_of_birth
    Then the update should fail
    And I should see error "This field cannot be updated"

  Scenario: Skip update when no actual changes
    Given I am authenticated as "HR Admin"
    And a worker exists with preferred_name "Johnny"
    When I submit an update with preferred_name "Johnny"
    Then no database update should occur
    And I should receive the current worker data
    And no audit log entry should be created

  Scenario: Update with change detection
    Given I am authenticated as "HR Admin"
    And a worker exists with:
      | preferred_name | marital_status_code |
      | John | SINGLE |
    When I update the worker with:
      | preferred_name | marital_status_code |
      | Johnny | MARRIED |
    Then exactly 2 fields should be updated
    And the changes list should contain:
      | field | old_value | new_value |
      | preferred_name | John | Johnny |
      | marital_status_code | SINGLE | MARRIED |

  # ═══════════════════════════════════════════════════════════════════
  # DELETE WORKER (GDPR)
  # ═══════════════════════════════════════════════════════════════════

  Scenario: Delete worker with anonymization (GDPR)
    Given I am authenticated as "HR Admin"
    And a worker exists with:
      | id | first_name | last_name | date_of_birth |
      | 550e8400-e29b-41d4-a716-446655440000 | John | Doe | 1990-05-15 |
    And the worker has no active employment
    When I delete the worker with reason "GDPR request" and anonymize=true
    Then the worker should be archived
    And the worker's PII should be anonymized:
      | field | value |
      | first_name | REDACTED |
      | last_name | REDACTED |
      | date_of_birth | null |
      | metadata | {} |
    But the worker ID should be preserved
    And an audit log should record the deletion

  Scenario: Prevent deleting worker with active employment
    Given I am authenticated as "HR Admin"
    And a worker exists with ID "550e8400-e29b-41d4-a716-446655440000"
    And the worker has an active employment
    When I attempt to delete the worker
    Then the deletion should fail
    And I should see error code "ERR_WORKER_HAS_ACTIVE_EMPLOYMENT"
    And I should see error message "Cannot delete worker with active employment"

  # ═══════════════════════════════════════════════════════════════════
  # WORKER LIFECYCLE
  # ═══════════════════════════════════════════════════════════════════

  Scenario: Worker lifecycle - DRAFT to CANDIDATE
    Given a worker exists in "DRAFT" state
    When the worker completes their profile
    And the worker submits a job application
    Then the worker state should transition to "CANDIDATE"

  Scenario: Worker lifecycle - CANDIDATE to ACTIVE
    Given a worker exists in "CANDIDATE" state
    When the worker is hired and an Employee record is created
    Then the worker state should transition to "ACTIVE"

  Scenario: Worker lifecycle - ACTIVE to ALUMNI
    Given a worker exists in "ACTIVE" state
    When all of the worker's employment relationships end
    And the worker is marked as alumni
    Then the worker state should transition to "ALUMNI"

  # ═══════════════════════════════════════════════════════════════════
  # DERIVED ATTRIBUTES
  # ═══════════════════════════════════════════════════════════════════

  Scenario: Calculate full name
    Given a worker exists with:
      | first_name | middle_name | last_name |
      | John | Michael | Doe |
    When I retrieve the worker's full_name
    Then the full_name should be "John Michael Doe"

  Scenario: Calculate display name with preferred name
    Given a worker exists with:
      | first_name | last_name | preferred_name |
      | John | Doe | Johnny |
    When I retrieve the worker's display_name
    Then the display_name should be "Johnny Doe"

  Scenario: Calculate age from date of birth
    Given a worker exists with date_of_birth "1990-05-15"
    And today's date is "2025-12-25"
    When I retrieve the worker's age
    Then the age should be 35

  # ═══════════════════════════════════════════════════════════════════
  # VALIDATION RULES
  # ═══════════════════════════════════════════════════════════════════

  Scenario: Enforce unique primary contact
    Given a worker exists with ID "550e8400-e29b-41d4-a716-446655440000"
    And the worker has a primary contact "mobile: +84 90 123 4567"
    When I attempt to add another primary contact
    Then the operation should fail
    And I should see error "Worker can have only one primary contact"

  Scenario: Enforce unique primary address
    Given a worker exists
    And the worker has a primary address
    When I attempt to add another primary address
    Then the operation should fail
    And I should see error "Worker can have only one primary address"

  # ═══════════════════════════════════════════════════════════════════
  # SECURITY & AUTHORIZATION
  # ═══════════════════════════════════════════════════════════════════

  Scenario: Worker can only view own data
    Given I am authenticated as worker "A" with ID "550e8400-e29b-41d4-a716-446655440000"
    And another worker "B" exists with ID "660e8400-e29b-41d4-a716-446655440001"
    When I attempt to view worker "B"'s data
    Then the access should be denied
    And I should see error "Access denied"

  Scenario: HR Manager can view all workers
    Given I am authenticated as "HR Manager"
    And multiple workers exist
    When I query for all workers
    Then I should receive the complete list
    And all worker data should be accessible

  Scenario: Audit all worker changes
    Given I am authenticated as "HR Admin"
    And a worker exists
    When I update the worker's preferred_name
    Then an audit log entry should be created with:
      | field | value |
      | entity_type | Worker |
      | operation | UPDATE |
      | user_id | <current_user_id> |
      | changes | preferred_name: old -> new |
