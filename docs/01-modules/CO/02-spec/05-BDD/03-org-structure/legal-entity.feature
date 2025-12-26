# language: en
Feature: Legal Entity Management
  As a Legal Administrator
  I want to manage legal entities
  So that I can maintain corporate structure and compliance

  # Link to ontology
  # Entity: 00-ontology/domain/03-org-structure/legal-entity.aggregate.yaml
  # Concept: 01-concept/03-org-structure/legal-entity-guide.md

  Background:
    Given I am logged in as "Legal Admin"
    And the following entity types exist:
      | id              | code       | name                |
      | type-company-01 | COMPANY    | Company             |
      | type-branch-01  | BRANCH     | Branch              |
      | type-subsid-01  | SUBSIDIARY | Subsidiary          |

  # ============================================================================
  # CRUD Operations
  # ============================================================================

  Scenario: Create root legal entity (company)
    When I create a legal entity with:
      | code      | VNG_HQ                      |
      | name_vi   | Công ty Cổ phần VNG         |
      | name_en   | VNG Corporation             |
      | type_id   | type-company-01             |
      | parent_id | null                        |
      | effective_start_date | 2004-04-01     |
    Then the legal entity should be created successfully
    And the legal entity should have:
      | path           | /                    |
      | level          | 0                    |
      | is_root        | true                 |
      | is_current_flag| true                 |
    And the event "LegalEntityCreated" should be emitted

  Scenario: Create child legal entity (branch)
    Given a legal entity exists with code "VNG_HQ"
    When I create a legal entity with:
      | code      | VNG_BRANCH_HCM                           |
      | name_vi   | Chi nhánh Công ty VNG tại TP.HCM         |
      | name_en   | VNG Company Branch in Ho Chi Minh City   |
      | type_id   | type-branch-01                           |
      | parent_id | <VNG_HQ.id>                              |
      | effective_start_date | 2010-06-01                  |
    Then the legal entity should be created successfully
    And the legal entity should have:
      | path           | /vng_hq/             |
      | level          | 1                    |
      | is_root        | false                |
    And the closure table should contain:
      | ancestor_id    | descendant_id        | depth |
      | <VNG_HQ.id>    | <VNG_BRANCH_HCM.id>  | 1     |
      | <VNG_BRANCH_HCM.id> | <VNG_BRANCH_HCM.id> | 0 |

  Scenario: Update legal entity name (SCD2)
    Given a legal entity exists with:
      | code    | VNG_BRANCH_HCM                    |
      | name_vi | Chi nhánh Công ty VNG tại TP.HCM  |
    When I update the legal entity with:
      | name_vi | Công ty TNHH VNG Đà Nẵng |
      | effective_date | 2025-06-01        |
      | reason  | Changed to limited liability company |
    Then the update should succeed
    And the old record should have:
      | effective_end_date | 2025-05-31 |
      | is_current_flag    | false      |
    And the new record should have:
      | effective_start_date | 2025-06-01 |
      | is_current_flag      | true       |
      | name_vi              | Công ty TNHH VNG Đà Nẵng |
    And the event "LegalEntityUpdated" should be emitted

  Scenario: Delete legal entity (soft delete)
    Given a legal entity exists with code "VNG_BRANCH_HCM"
    And the legal entity has no active children
    And the legal entity has no active business units
    And the legal entity has no active employees
    When I delete the legal entity with:
      | reason         | Branch closed        |
      | effective_date | 2025-12-31           |
    Then the deletion should succeed
    And the legal entity should have:
      | effective_end_date | 2025-12-31 |
      | is_current_flag    | false      |
    And the event "LegalEntityDeleted" should be emitted

  # ============================================================================
  # Validation Rules
  # ============================================================================

  Scenario: Cannot create legal entity with duplicate code
    Given a legal entity exists with code "VNG_HQ"
    When I create a legal entity with code "VNG_HQ"
    Then the creation should fail
    And I should see the error "Legal entity code already exists"

  Scenario: Cannot create legal entity with invalid parent
    When I create a legal entity with:
      | code      | VNG_BRANCH_HCM |
      | parent_id | invalid-uuid   |
    Then the creation should fail
    And I should see the error "Invalid parent legal entity ID"

  Scenario: Cannot exceed maximum hierarchy depth
    Given a legal entity hierarchy with 10 levels
    When I create a legal entity as child of level 10
    Then the creation should fail
    And I should see the error "Maximum hierarchy depth (10) exceeded"

  Scenario: Cannot delete legal entity with active children
    Given a legal entity "VNG_HQ" has active child "VNG_BRANCH_HCM"
    When I delete the legal entity "VNG_HQ"
    Then the deletion should fail
    And I should see the error "Cannot delete legal entity with active children"

  # ============================================================================
  # Hierarchy Queries
  # ============================================================================

  Scenario: Query all ancestors
    Given the following legal entity hierarchy:
      | code           | parent_code    |
      | VNG_HQ         | null           |
      | VNG_SUBSID_SG  | VNG_HQ         |
      | VNG_BRANCH_MY  | VNG_SUBSID_SG  |
    When I query ancestors of "VNG_BRANCH_MY"
    Then I should get:
      | code           | depth |
      | VNG_SUBSID_SG  | 1     |
      | VNG_HQ         | 2     |

  Scenario: Query all descendants
    Given the following legal entity hierarchy:
      | code           | parent_code    |
      | VNG_HQ         | null           |
      | VNG_BRANCH_HCM | VNG_HQ         |
      | VNG_BRANCH_HN  | VNG_HQ         |
      | VNG_SUBSID_SG  | VNG_HQ         |
    When I query descendants of "VNG_HQ"
    Then I should get:
      | code           | depth |
      | VNG_BRANCH_HCM | 1     |
      | VNG_BRANCH_HN  | 1     |
      | VNG_SUBSID_SG  | 1     |

  # ============================================================================
  # Lifecycle Transitions
  # ============================================================================

  Scenario: Activate legal entity
    Given a legal entity in "DRAFT" state
    And the legal entity has:
      | name_vi populated    | true |
      | type_id assigned     | true |
      | at least one license | true |
    When I activate the legal entity
    Then the state should change to "ACTIVE"
    And the event "LegalEntityActivated" should be emitted

  Scenario: Cannot activate legal entity without license
    Given a legal entity in "DRAFT" state
    And the legal entity has no business licenses
    When I activate the legal entity
    Then the activation should fail
    And I should see the error "At least one business license required"

  Scenario: Deactivate legal entity
    Given a legal entity in "ACTIVE" state
    When I deactivate the legal entity with reason "Pending restructuring"
    Then the state should change to "INACTIVE"
    And the event "LegalEntityDeactivated" should be emitted

  Scenario: Dissolve legal entity
    Given a legal entity in "ACTIVE" state
    And the legal entity has no active employees
    And the legal entity has no active business units
    When I dissolve the legal entity with:
      | dissolution_date | 2025-12-31           |
      | reason           | Company liquidation  |
    Then the state should change to "DISSOLVED"
    And the event "LegalEntityDissolved" should be emitted

  # ============================================================================
  # Security & Authorization
  # ============================================================================

  Scenario: Legal Admin can create legal entity
    Given I am logged in as "Legal Admin"
    When I create a legal entity
    Then the creation should succeed

  Scenario: Regular user cannot create legal entity
    Given I am logged in as "Regular User"
    When I create a legal entity
    Then the creation should fail
    And I should see the error "Insufficient permissions"

  Scenario: User can only access legal entities in their hierarchy
    Given I am logged in as user assigned to "VNG_BRANCH_HCM"
    When I query legal entities
    Then I should see:
      | code           |
      | VNG_BRANCH_HCM |
    And I should not see:
      | code           |
      | VNG_BRANCH_HN  |
      | VNG_SUBSID_SG  |

  # ============================================================================
  # Integration Scenarios
  # ============================================================================

  Scenario: Create legal entity with profile
    When I create a legal entity with profile:
      | code                 | VNG_HQ                    |
      | name_vi              | Công ty Cổ phần VNG       |
      | profile.tax_id       | 0123456789                |
      | profile.legal_name_local | Công ty Cổ phần VNG  |
      | profile.address1_country_code | VN            |
    Then the legal entity should be created
    And the entity profile should be created
    And the profile should have:
      | tax_id       | 0123456789 |
      | legal_name_local | Công ty Cổ phần VNG |

  Scenario: Hierarchy change updates closure table
    Given a legal entity "VNG_BRANCH_HCM" with parent "VNG_HQ"
    When I move "VNG_BRANCH_HCM" to parent "VNG_SUBSID_SG"
    Then the closure table should be updated
    And the path should change from "/vng_hq/" to "/vng_hq/vng_subsid_sg/"
