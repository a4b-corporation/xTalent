---
domain: CORE_HR
module: CO
version: "1.0.0"
status: DRAFT
created: "2026-01-07"

# === FEATURE DATA ===
capabilities:
  # ═══════════════════════════════════════════════════════════
  # CAPABILITY: Person Management
  # ═══════════════════════════════════════════════════════════
  - name: "Person Management"
    description: "Manage worker personal data, profiles, and related information"
    sub_module: 01-PERSON
    features:
      - id: FR-CO-001
        name: "Create Worker Profile"
        description: "As an HR Admin, I want to create a new worker profile so that I can onboard a new person into the system"
        priority: MUST
        type: Functional
        risk: medium
        competitor_reference: "Workday, SAP, Oracle"
        related_entities:
          - "[[Worker]]"
          - "[[Contact]]"
          - "[[Address]]"
        business_rules:
          - "Worker ID must be unique"
          - "Email must be valid format"
          - "At least one contact is required"

      - id: FR-CO-002
        name: "Update Worker Profile"
        description: "As an Employee, I want to update my personal information so that my records are current"
        priority: MUST
        type: Functional
        risk: low
        related_entities:
          - "[[Worker]]"
        business_rules:
          - "Self-service updates require approval for certain fields"
          - "Audit trail for all changes"

      - id: FR-CO-003
        name: "Manage Worker Documents"
        description: "As an HR Admin, I want to store and manage worker identity documents so that compliance records are maintained"
        priority: MUST
        type: Functional
        risk: high
        related_entities:
          - "[[Worker]]"
          - "[[Document]]"
        business_rules:
          - "Document expiry alerts required"
          - "PII data must be encrypted"

      - id: FR-CO-004
        name: "Manage Worker Skills"
        description: "As an HR Manager, I want to track worker skills and proficiency levels so that I can plan talent development"
        priority: SHOULD
        type: Functional
        risk: low
        related_entities:
          - "[[Worker]]"
          - "[[SkillAssignment]]"
          - "[[Skill]]"

      - id: FR-CO-005
        name: "View Worker Education History"
        description: "As an HR Admin, I want to view and record worker education history for qualification tracking"
        priority: SHOULD
        type: Functional
        risk: low
        related_entities:
          - "[[Worker]]"
          - "[[EducationRecord]]"

      - id: FR-CO-006
        name: "Manage Dependents"
        description: "As an Employee, I want to add my dependents so that they can be enrolled in benefits"
        priority: MUST
        type: Functional
        risk: medium
        related_entities:
          - "[[Worker]]"
          - "[[Dependent]]"
        business_rules:
          - "Dependent relationship must be verified"
          - "Beneficiary allocation must sum to 100%"

  # ═══════════════════════════════════════════════════════════
  # CAPABILITY: Employment Management
  # ═══════════════════════════════════════════════════════════
  - name: "Employment Management"
    description: "Manage employment relationships, contracts, and assignments"
    sub_module: 02-EMPLOYMENT
    features:
      - id: FR-CO-010
        name: "Hire Employee"
        description: "As an HR Admin, I want to convert a worker to employee so that they can start their employment"
        priority: MUST
        type: Workflow
        risk: high
        competitor_reference: "Workday Onboarding, SAP Hiring"
        related_entities:
          - "[[Worker]]"
          - "[[Employee]]"
          - "[[Contract]]"
          - "[[Assignment]]"
        business_rules:
          - "Legal entity must be specified"
          - "Position must be available"
          - "Contract is required"

      - id: FR-CO-011
        name: "Create Employment Contract"
        description: "As an HR Admin, I want to create an employment contract with terms and conditions"
        priority: MUST
        type: Functional
        risk: high
        related_entities:
          - "[[Employee]]"
          - "[[Contract]]"
        business_rules:
          - "Salary must be within job grade range"
          - "Contract end date required for fixed-term"
          - "Working hours must comply with labor law"

      - id: FR-CO-012
        name: "Assign to Position"
        description: "As an HR Admin, I want to assign an employee to a position so that org structure is accurate"
        priority: MUST
        type: Functional
        risk: medium
        related_entities:
          - "[[Employee]]"
          - "[[Assignment]]"
          - "[[Position]]"
        business_rules:
          - "Position must be open or have headcount"
          - "FTE allocation cannot exceed 100%"

      - id: FR-CO-013
        name: "Transfer Employee"
        description: "As an HR Admin, I want to transfer an employee to a new position/department"
        priority: MUST
        type: Workflow
        risk: medium
        related_entities:
          - "[[Employee]]"
          - "[[Assignment]]"
          - "[[Position]]"
        business_rules:
          - "Old assignment must be ended"
          - "New assignment must start without gap"

      - id: FR-CO-014
        name: "Terminate Employment"
        description: "As an HR Admin, I want to process employee termination so that offboarding is complete"
        priority: MUST
        type: Workflow
        risk: high
        related_entities:
          - "[[Employee]]"
          - "[[Contract]]"
        business_rules:
          - "Notice period must be respected"
          - "Final settlement calculation required"
          - "Access must be revoked"

      - id: FR-CO-015
        name: "Renew Contract"
        description: "As an HR Admin, I want to renew an expiring contract so that employment continues"
        priority: MUST
        type: Workflow
        risk: medium
        related_entities:
          - "[[Employee]]"
          - "[[Contract]]"
        business_rules:
          - "Renewal notification before expiry"
          - "Terms can be updated"

  # ═══════════════════════════════════════════════════════════
  # CAPABILITY: Organization Structure
  # ═══════════════════════════════════════════════════════════
  - name: "Organization Structure"
    description: "Manage legal entities, business units, and organizational hierarchy"
    sub_module: 03-ORG-STRUCTURE
    features:
      - id: FR-CO-020
        name: "Manage Legal Entities"
        description: "As a System Admin, I want to configure legal entities so that multi-company setup is supported"
        priority: MUST
        type: Configuration
        risk: high
        competitor_reference: "SAP Legal Entity, Oracle Legal Employer"
        related_entities:
          - "[[LegalEntity]]"
        business_rules:
          - "Tax ID must be unique per country"
          - "Currency and country required"

      - id: FR-CO-021
        name: "Manage Business Units"
        description: "As an HR Admin, I want to create and organize business units so that org structure is defined"
        priority: MUST
        type: Functional
        risk: medium
        competitor_reference: "Workday Supervisory Org"
        related_entities:
          - "[[BusinessUnit]]"
          - "[[LegalEntity]]"
        business_rules:
          - "Parent hierarchy must be valid"
          - "Manager assignment optional"

      - id: FR-CO-022
        name: "View Organization Chart"
        description: "As an Employee, I want to view the organization chart so that I understand reporting structure"
        priority: MUST
        type: UI/UX
        risk: low
        competitor_reference: "Workday Org Studio"
        related_entities:
          - "[[BusinessUnit]]"
          - "[[Position]]"
          - "[[Employee]]"

      - id: FR-CO-023
        name: "Manage Cost Centers"
        description: "As a Finance Admin, I want to define cost centers for expense allocation"
        priority: SHOULD
        type: Configuration
        risk: low
        related_entities:
          - "[[CostCenter]]"
          - "[[LegalEntity]]"

      - id: FR-CO-024
        name: "Manage Locations"
        description: "As an HR Admin, I want to define work locations for facility management"
        priority: SHOULD
        type: Configuration
        risk: low
        related_entities:
          - "[[Location]]"

  # ═══════════════════════════════════════════════════════════
  # CAPABILITY: Job & Position Management
  # ═══════════════════════════════════════════════════════════
  - name: "Job & Position Management"
    description: "Manage job catalog, positions, and career paths"
    sub_module: 04-JOB-POSITION
    features:
      - id: FR-CO-030
        name: "Manage Job Catalog"
        description: "As an HR Admin, I want to define jobs in the catalog so that positions can be created"
        priority: MUST
        type: Functional
        risk: medium
        competitor_reference: "Workday Job Profile"
        related_entities:
          - "[[Job]]"
          - "[[JobFamily]]"
        business_rules:
          - "Job code must be unique"
          - "Salary range required"
          - "Job family assignment required"

      - id: FR-CO-031
        name: "Create Position"
        description: "As an HR Manager, I want to create a position so that I can hire or assign employees"
        priority: MUST
        type: Functional
        risk: medium
        related_entities:
          - "[[Position]]"
          - "[[Job]]"
          - "[[BusinessUnit]]"
        business_rules:
          - "Position must be linked to a job"
          - "Business unit required"
          - "Headcount tracking"

      - id: FR-CO-032
        name: "Manage Position Hierarchy"
        description: "As an HR Admin, I want to define reporting relationships between positions"
        priority: MUST
        type: Functional
        risk: medium
        related_entities:
          - "[[Position]]"
        business_rules:
          - "No circular reporting"
          - "Reports-to must exist"

      - id: FR-CO-033
        name: "Define Career Paths"
        description: "As an HR Admin, I want to define career progression paths so that employees can plan development"
        priority: SHOULD
        type: Configuration
        risk: low
        competitor_reference: "Workday Career Hub"
        related_entities:
          - "[[CareerPath]]"
          - "[[Job]]"

  # ═══════════════════════════════════════════════════════════
  # CAPABILITY: Master Data Management
  # ═══════════════════════════════════════════════════════════
  - name: "Master Data Management"
    description: "Manage reference data and configuration"
    sub_module: 05-MASTER-DATA
    features:
      - id: FR-CO-040
        name: "Manage Skill Dictionary"
        description: "As an HR Admin, I want to define skills in the dictionary for use across the system"
        priority: SHOULD
        type: Configuration
        risk: low
        related_entities:
          - "[[Skill]]"

      - id: FR-CO-041
        name: "Manage Competency Model"
        description: "As an HR Admin, I want to define competencies for performance management"
        priority: SHOULD
        type: Configuration
        risk: low
        related_entities:
          - "[[Competency]]"

      - id: FR-CO-042
        name: "Manage Geographic Data"
        description: "As a System Admin, I want to configure countries and regions for localization"
        priority: MUST
        type: Configuration
        risk: low
        related_entities:
          - "[[Country]]"
          - "[[Currency]]"

  # ═══════════════════════════════════════════════════════════
  # CAPABILITY: Eligibility Management
  # ═══════════════════════════════════════════════════════════
  - name: "Eligibility Management"
    description: "Define cross-module eligibility rules"
    sub_module: 07-ELIGIBILITY
    features:
      - id: FR-CO-050
        name: "Create Eligibility Profile"
        description: "As an HR Admin, I want to create eligibility profiles so that benefits/programs can be targeted"
        priority: MUST
        type: Functional
        risk: medium
        competitor_reference: "Workday Eligibility Rule"
        related_entities:
          - "[[EligibilityProfile]]"
          - "[[EligibilityRule]]"
        business_rules:
          - "Multiple rules can be combined"
          - "AND/OR logic supported"

      - id: FR-CO-051
        name: "Evaluate Eligibility"
        description: "As a System, I want to evaluate if a worker is eligible for a program"
        priority: MUST
        type: Calculation
        risk: medium
        related_entities:
          - "[[EligibilityProfile]]"
          - "[[Worker]]"
        business_rules:
          - "Real-time evaluation"
          - "Batch evaluation for mass changes"
---

# Feature Catalog: Core HR

> **Note**: YAML above is for AI processing. Tables below for human reading.

## Capability: Person Management

| ID | Feature | User Story | Priority | Type |
|----|---------|------------|----------|------|
| FR-CO-001 | **Create Worker Profile** | As an HR Admin, create new worker | MUST | Functional |
| FR-CO-002 | **Update Worker Profile** | As an Employee, update personal info | MUST | Functional |
| FR-CO-003 | **Manage Worker Documents** | As an HR Admin, store identity docs | MUST | Functional |
| FR-CO-004 | **Manage Worker Skills** | As an HR Manager, track skills | SHOULD | Functional |
| FR-CO-005 | **View Education History** | As an HR Admin, view education | SHOULD | Functional |
| FR-CO-006 | **Manage Dependents** | As an Employee, add dependents | MUST | Functional |

## Capability: Employment Management

| ID | Feature | User Story | Priority | Type |
|----|---------|------------|----------|------|
| FR-CO-010 | **Hire Employee** | As an HR Admin, convert to employee | MUST | Workflow |
| FR-CO-011 | **Create Contract** | As an HR Admin, create contract | MUST | Functional |
| FR-CO-012 | **Assign to Position** | As an HR Admin, assign to position | MUST | Functional |
| FR-CO-013 | **Transfer Employee** | As an HR Admin, transfer employee | MUST | Workflow |
| FR-CO-014 | **Terminate Employment** | As an HR Admin, process termination | MUST | Workflow |
| FR-CO-015 | **Renew Contract** | As an HR Admin, renew contract | MUST | Workflow |

## Capability: Organization Structure

| ID | Feature | User Story | Priority | Type |
|----|---------|------------|----------|------|
| FR-CO-020 | **Manage Legal Entities** | As a System Admin, configure entities | MUST | Configuration |
| FR-CO-021 | **Manage Business Units** | As an HR Admin, create org structure | MUST | Functional |
| FR-CO-022 | **View Organization Chart** | As an Employee, view org chart | MUST | UI/UX |
| FR-CO-023 | **Manage Cost Centers** | As a Finance Admin, define cost centers | SHOULD | Configuration |
| FR-CO-024 | **Manage Locations** | As an HR Admin, define locations | SHOULD | Configuration |

## Capability: Job & Position Management

| ID | Feature | User Story | Priority | Type |
|----|---------|------------|----------|------|
| FR-CO-030 | **Manage Job Catalog** | As an HR Admin, define jobs | MUST | Functional |
| FR-CO-031 | **Create Position** | As an HR Manager, create position | MUST | Functional |
| FR-CO-032 | **Manage Position Hierarchy** | As an HR Admin, define reporting | MUST | Functional |
| FR-CO-033 | **Define Career Paths** | As an HR Admin, define career paths | SHOULD | Configuration |

## Capability: Master Data Management

| ID | Feature | User Story | Priority | Type |
|----|---------|------------|----------|------|
| FR-CO-040 | **Manage Skill Dictionary** | As an HR Admin, define skills | SHOULD | Configuration |
| FR-CO-041 | **Manage Competency Model** | As an HR Admin, define competencies | SHOULD | Configuration |
| FR-CO-042 | **Manage Geographic Data** | As a System Admin, configure countries | MUST | Configuration |

## Capability: Eligibility Management

| ID | Feature | User Story | Priority | Type |
|----|---------|------------|----------|------|
| FR-CO-050 | **Create Eligibility Profile** | As an HR Admin, create profiles | MUST | Functional |
| FR-CO-051 | **Evaluate Eligibility** | As a System, evaluate eligibility | MUST | Calculation |

## Feature Summary

| Priority | Count |
|----------|-------|
| MUST | 19 |
| SHOULD | 6 |
| **Total** | **25** |

## Feature Mindmap

```mermaid
mindmap
  root((Core HR Features))
    Person Management
      FR-CO-001 Create Worker
      FR-CO-002 Update Worker
      FR-CO-003 Documents
      FR-CO-006 Dependents
    Employment
      FR-CO-010 Hire
      FR-CO-011 Contract
      FR-CO-013 Transfer
      FR-CO-014 Terminate
    Org Structure
      FR-CO-020 Legal Entities
      FR-CO-021 Business Units
      FR-CO-022 Org Chart
    Job & Position
      FR-CO-030 Job Catalog
      FR-CO-031 Create Position
      FR-CO-033 Career Paths
    Eligibility
      FR-CO-050 Eligibility Profile
      FR-CO-051 Evaluate
```
