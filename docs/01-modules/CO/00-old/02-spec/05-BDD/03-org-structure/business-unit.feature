# language: en
Feature: Business Unit Management
  As an Organization Administrator
  I want to manage business units
  So that I can maintain organizational structure and reporting hierarchy

  Background:
    Given I am logged in as "Organization Admin"
    And the following business unit types exist:
      | id            | code       | name       | level_order |
      | type-div-01   | DIVISION   | Division   | 1           |
      | type-dept-01  | DEPARTMENT | Department | 2           |
      | type-team-01  | TEAM       | Team       | 3           |

  # ============================================================================
  # CRUD Operations
  # ============================================================================

  Scenario: Create root business unit (division)
    When I create a business unit with:
      | code      | ENG_DIV                    |
      | name      | Engineering Division       |
      | type_id   | type-div-01                |
      | parent_id | null                       |
      | legal_entity_code | VNG_HQ            |
      | status_code | DRAFT                    |
    Then the business unit should be created successfully
    And the business unit should have:
      | path      | /                          |
      | level     | 0                          |
      | is_root   | true                       |
    And the closure table should contain self-reference

  Scenario: Create child business unit with manager
    Given a business unit exists with code "ENG_DIV"
    And an active employee exists with id "emp-manager-001"
    When I create a business unit with:
      | code      | BACKEND_DEPT                      |
      | name      | Backend Development Department    |
      | type_id   | type-dept-01                      |
      | parent_id | <ENG_DIV.id>                      |
      | manager_employee_id | emp-manager-001         |
      | legal_entity_code | VNG_HQ                  |
    Then the business unit should be created successfully
    And the closure table should contain:
      | ancestor_id | descendant_id    | depth |
      | <ENG_DIV.id> | <BACKEND_DEPT.id> | 1    |

  Scenario: Update business unit manager
    Given a business unit exists with code "BACKEND_DEPT"
    And an active employee exists with id "emp-new-manager-001"
    When I update the business unit with:
      | manager_employee_id | emp-new-manager-001 |
      | effective_date | 2025-07-01              |
      | reason | Manager change                   |
    Then the update should succeed
    And the new version should have manager "emp-new-manager-001"

  Scenario: Reorganization - Move business unit
    Given the following business unit hierarchy:
      | code         | parent_code |
      | ENG_DIV      | null        |
      | PRODUCT_DIV  | null        |
      | BACKEND_DEPT | ENG_DIV     |
    When I move "BACKEND_DEPT" to parent "PRODUCT_DIV"
    Then the move should succeed
    And the path should change from "/eng_div/" to "/product_div/"
    And the closure table should be rebuilt for the subtree

  # ============================================================================
  # Validation Rules
  # ============================================================================

  Scenario: Cannot create business unit with duplicate code
    Given a business unit exists with code "ENG_DIV"
    When I create a business unit with code "ENG_DIV"
    Then the creation should fail
    And I should see the error "Business unit code already exists"

  Scenario: Cannot assign inactive employee as manager
    Given an inactive employee exists with id "emp-inactive-001"
    When I create a business unit with:
      | code | BACKEND_DEPT                |
      | manager_employee_id | emp-inactive-001 |
    Then the creation should fail
    And I should see the error "Manager must be an active employee"

  Scenario: Cannot exceed maximum hierarchy depth
    Given a business unit hierarchy with 15 levels
    When I create a business unit as child of level 15
    Then the creation should fail
    And I should see the error "Maximum hierarchy depth (15) exceeded"

  Scenario: Cannot delete business unit with active children
    Given a business unit "ENG_DIV" has active child "BACKEND_DEPT"
    When I delete the business unit "ENG_DIV"
    Then the deletion should fail
    And I should see the error "Cannot delete business unit with active children"

  # ============================================================================
  # Hierarchy Queries (Closure Table)
  # ============================================================================

  Scenario: Query all ancestors using closure table
    Given the following business unit hierarchy:
      | code          | parent_code   |
      | ENG_DIV       | null          |
      | BACKEND_DEPT  | ENG_DIV       |
      | API_TEAM      | BACKEND_DEPT  |
    When I query ancestors of "API_TEAM"
    Then I should get in O(1) time:
      | code          | depth |
      | BACKEND_DEPT  | 1     |
      | ENG_DIV       | 2     |

  Scenario: Query all descendants using closure table
    Given the following business unit hierarchy:
      | code          | parent_code   |
      | ENG_DIV       | null          |
      | BACKEND_DEPT  | ENG_DIV       |
      | FRONTEND_DEPT | ENG_DIV       |
      | API_TEAM      | BACKEND_DEPT  |
    When I query descendants of "ENG_DIV"
    Then I should get in O(1) time:
      | code          | depth |
      | BACKEND_DEPT  | 1     |
      | FRONTEND_DEPT | 1     |
      | API_TEAM      | 2     |

  Scenario: Query direct reports only
    Given the following business unit hierarchy:
      | code          | parent_code   |
      | ENG_DIV       | null          |
      | BACKEND_DEPT  | ENG_DIV       |
      | FRONTEND_DEPT | ENG_DIV       |
      | API_TEAM      | BACKEND_DEPT  |
    When I query direct reports of "ENG_DIV"
    Then I should get:
      | code          |
      | BACKEND_DEPT  |
      | FRONTEND_DEPT |
    And I should not get:
      | code     |
      | API_TEAM |

  # ============================================================================
  # Lifecycle Transitions
  # ============================================================================

  Scenario: Activate business unit
    Given a business unit in "DRAFT" state
    When I activate the business unit
    Then the state should change to "ACTIVE"
    And the event "BusinessUnitActivated" should be emitted

  Scenario: Deactivate business unit
    Given a business unit in "ACTIVE" state
    When I deactivate the business unit with reason "Pending reorganization"
    Then the state should change to "INACTIVE"

  Scenario: Dissolve business unit
    Given a business unit in "ACTIVE" state
    And the business unit has no active employees
    And the business unit has no active children
    When I dissolve the business unit
    Then the state should change to "DISSOLVED"

  # ============================================================================
  # Manager Validation
  # ============================================================================

  Scenario: Manager must be Employee (not Worker)
    Given a worker exists with id "worker-001" (not an employee)
    When I create a business unit with:
      | code | BACKEND_DEPT        |
      | manager_employee_id | worker-001 |
    Then the creation should fail
    And I should see the error "Manager must be an active employee"

  Scenario: Manager must have organizational authority
    Given an employee exists without organizational authority
    When I assign them as business unit manager
    Then the assignment should fail
    And I should see the error "Manager must have organizational authority"

  # ============================================================================
  # Security & Permissions
  # ============================================================================

  Scenario: User can access units in their hierarchy
    Given I am logged in as user assigned to "BACKEND_DEPT"
    And the hierarchy is:
      | ENG_DIV → BACKEND_DEPT → API_TEAM |
    When I query business units
    Then I should see:
      | code         |
      | BACKEND_DEPT |
      | API_TEAM     |
    And I should not see:
      | code          |
      | FRONTEND_DEPT |

  Scenario: Manager can access their unit and descendants
    Given I am logged in as manager of "ENG_DIV"
    When I query business units
    Then I should see all descendants of "ENG_DIV"

  # ============================================================================
  # Performance & Closure Table
  # ============================================================================

  Scenario: Closure table provides O(1) ancestor queries
    Given a business unit hierarchy with 1000 units and depth 10
    When I query ancestors of any unit
    Then the query should complete in O(1) time
    And should use the closure table index

  Scenario: Reorganization rebuilds closure table efficiently
    Given a business unit "BACKEND_DEPT" with 50 descendants
    When I move "BACKEND_DEPT" to a new parent
    Then the closure table should be rebuilt for 51 units (subtree)
    And should complete in under 1 second

  # ============================================================================
  # Integration Scenarios
  # ============================================================================

  Scenario: Create business unit with tags
    When I create a business unit with tags:
      | code | BACKEND_DEPT          |
      | tags | TECH, COST_CENTER_123 |
    Then the business unit should be created
    And the tags should be assigned

  Scenario: Link to legal entity by code
    When I create a business unit with:
      | code | BACKEND_DEPT |
      | legal_entity_code | VNG_HQ |
    Then the legal entity link should be flexible
    And should survive legal entity restructuring
