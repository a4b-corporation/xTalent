---
domain: CORE_HR
module: CO
version: "1.0.0"
status: DRAFT
created: "2026-01-07"

# === ENTITY DATA ===
entities:
  # ═══════════════════════════════════════════════════════════
  # SUB-MODULE: 01-PERSON
  # ═══════════════════════════════════════════════════════════
  
  # --- Aggregate Root ---
  - id: E-CO-001
    name: Worker
    type: AGGREGATE_ROOT
    sub_module: 01-PERSON
    category: Master
    definition: "Person who has or had a working relationship with the organization. Central entity for all person-related data."
    key_attributes:
      - worker_id
      - person_number
      - worker_type (EMPLOYEE | CONTRACTOR | CONTINGENT)
      - hire_date
      - termination_date
      - status (ACTIVE | INACTIVE | TERMINATED)
    relationships:
      - "has many [[Contact]]"
      - "has many [[Address]]"
      - "has many [[Document]]"
      - "has many [[SkillAssignment]]"
      - "has many [[EducationRecord]]"
      - "has many [[Dependent]]"
      - "has one [[Employee]]"
    lifecycle: "Pre-hire → Active → On Leave → Terminated"
    competitor_reference: "Workday: Worker, SAP: Employee, Oracle: Person"

  # --- Child Entities ---
  - id: E-CO-002
    name: Contact
    type: ENTITY
    sub_module: 01-PERSON
    category: Master
    definition: "Contact information (phone, email) for a worker."
    key_attributes:
      - contact_id
      - contact_type (PHONE | EMAIL | SOCIAL)
      - contact_value
      - is_primary
    relationships:
      - "belongs to [[Worker]]"

  - id: E-CO-003
    name: Address
    type: ENTITY
    sub_module: 01-PERSON
    category: Master
    definition: "Physical or mailing address for a worker."
    key_attributes:
      - address_id
      - address_type (HOME | MAILING | WORK)
      - address_line_1
      - city
      - country_code
    relationships:
      - "belongs to [[Worker]]"

  - id: E-CO-004
    name: Document
    type: ENTITY
    sub_module: 01-PERSON
    category: Master
    definition: "Identity or legal documents (passport, ID card, visa)."
    key_attributes:
      - document_id
      - document_type (PASSPORT | ID_CARD | VISA)
      - document_number
      - issue_date
      - expiry_date
    relationships:
      - "belongs to [[Worker]]"

  - id: E-CO-005
    name: SkillAssignment
    type: ENTITY
    sub_module: 01-PERSON
    category: Master
    definition: "Skill assigned to a worker with proficiency level."
    key_attributes:
      - skill_id
      - proficiency_level (BEGINNER | INTERMEDIATE | ADVANCED | EXPERT)
      - years_of_experience
    relationships:
      - "belongs to [[Worker]]"
      - "references [[Skill]]"

  - id: E-CO-006
    name: EducationRecord
    type: ENTITY
    sub_module: 01-PERSON
    category: Master
    definition: "Education history of a worker."
    key_attributes:
      - education_id
      - institution_name
      - degree
      - major
      - graduation_year
    relationships:
      - "belongs to [[Worker]]"

  - id: E-CO-007
    name: Dependent
    type: ENTITY
    sub_module: 01-PERSON
    category: Master
    definition: "Family member or dependent of a worker for benefits."
    key_attributes:
      - dependent_id
      - relationship (SPOUSE | CHILD | PARENT)
      - date_of_birth
      - is_beneficiary
    relationships:
      - "belongs to [[Worker]]"

  # ═══════════════════════════════════════════════════════════
  # SUB-MODULE: 02-EMPLOYMENT
  # ═══════════════════════════════════════════════════════════
  
  - id: E-CO-010
    name: Employee
    type: AGGREGATE_ROOT
    sub_module: 02-EMPLOYMENT
    category: Transaction
    definition: "Employment relationship between Worker and Legal Entity."
    key_attributes:
      - employee_id
      - employee_number
      - legal_entity_id
      - hire_date
      - probation_end_date
      - employment_status (PROBATION | CONFIRMED | TERMINATED)
    relationships:
      - "belongs to [[Worker]]"
      - "employed by [[LegalEntity]]"
      - "has many [[Contract]]"
      - "has many [[Assignment]]"
    lifecycle: "Offer → Probation → Confirmed → Resigned/Terminated"
    competitor_reference: "Workday: Employee, SAP: Employment, Oracle: Assignment"

  - id: E-CO-011
    name: Contract
    type: ENTITY
    sub_module: 02-EMPLOYMENT
    category: Transaction
    definition: "Employment contract with terms and conditions."
    key_attributes:
      - contract_id
      - contract_type (INDEFINITE | FIXED_TERM | SEASONAL)
      - start_date
      - end_date
      - salary_amount
      - working_hours_per_week
    relationships:
      - "belongs to [[Employee]]"
    lifecycle: "Draft → Active → Expired → Renewed"

  - id: E-CO-012
    name: Assignment
    type: ENTITY
    sub_module: 02-EMPLOYMENT
    category: Transaction
    definition: "Assignment of employee to a position."
    key_attributes:
      - assignment_id
      - position_id
      - assignment_type (PRIMARY | SECONDARY | TEMPORARY)
      - start_date
      - end_date
      - fte_percentage
    relationships:
      - "belongs to [[Employee]]"
      - "assigned to [[Position]]"

  # ═══════════════════════════════════════════════════════════
  # SUB-MODULE: 03-ORG-STRUCTURE
  # ═══════════════════════════════════════════════════════════
  
  - id: E-CO-020
    name: LegalEntity
    type: AGGREGATE_ROOT
    sub_module: 03-ORG-STRUCTURE
    category: Master
    definition: "Legal company entity that employs workers."
    key_attributes:
      - legal_entity_id
      - legal_name
      - registration_number
      - tax_id
      - country_code
      - currency_code
    relationships:
      - "has many [[BusinessUnit]]"
      - "has many [[Employee]]"
    competitor_reference: "SAP: Legal Entity, Oracle: Legal Entity"

  - id: E-CO-021
    name: BusinessUnit
    type: AGGREGATE_ROOT
    sub_module: 03-ORG-STRUCTURE
    category: Master
    definition: "Business unit or department within a legal entity."
    key_attributes:
      - business_unit_id
      - business_unit_code
      - name
      - parent_id
      - level
      - manager_id
    relationships:
      - "belongs to [[LegalEntity]]"
      - "has parent [[BusinessUnit]]"
      - "has many [[Position]]"
      - "managed by [[Employee]]"
    competitor_reference: "SAP: Business Unit, Workday: Supervisory Organization"

  - id: E-CO-022
    name: CostCenter
    type: ENTITY
    sub_module: 03-ORG-STRUCTURE
    category: Master
    definition: "Cost center for financial tracking."
    key_attributes:
      - cost_center_id
      - cost_center_code
      - name
      - budget_owner_id
    relationships:
      - "belongs to [[LegalEntity]]"

  - id: E-CO-023
    name: Location
    type: ENTITY
    sub_module: 03-ORG-STRUCTURE
    category: Master
    definition: "Work location or office."
    key_attributes:
      - location_id
      - location_code
      - name
      - address
      - timezone
    relationships:
      - "belongs to [[LegalEntity]]"

  # ═══════════════════════════════════════════════════════════
  # SUB-MODULE: 04-JOB-POSITION
  # ═══════════════════════════════════════════════════════════
  
  - id: E-CO-030
    name: Job
    type: AGGREGATE_ROOT
    sub_module: 04-JOB-POSITION
    category: Master
    definition: "Job definition in the job catalog."
    key_attributes:
      - job_id
      - job_code
      - job_title
      - job_family_id
      - job_level
      - min_salary
      - max_salary
    relationships:
      - "belongs to [[JobFamily]]"
      - "has many [[Position]]"
      - "has many [[JobCompetency]]"
    competitor_reference: "Workday: Job Profile, SAP: Job, Oracle: Job"

  - id: E-CO-031
    name: Position
    type: AGGREGATE_ROOT
    sub_module: 04-JOB-POSITION
    category: Master
    definition: "Specific position in organization structure."
    key_attributes:
      - position_id
      - position_code
      - position_title
      - job_id
      - business_unit_id
      - headcount
      - status (OPEN | FILLED | FROZEN)
    relationships:
      - "instances of [[Job]]"
      - "belongs to [[BusinessUnit]]"
      - "has many [[Assignment]]"
      - "reports to [[Position]]"
    lifecycle: "Proposed → Approved → Open → Filled → Frozen"
    competitor_reference: "Workday: Position, SAP: Position, Oracle: Position"

  - id: E-CO-032
    name: JobFamily
    type: ENTITY
    sub_module: 04-JOB-POSITION
    category: Config
    definition: "Grouping of related jobs."
    key_attributes:
      - job_family_id
      - job_family_code
      - name
      - parent_id
    relationships:
      - "has many [[Job]]"

  - id: E-CO-033
    name: CareerPath
    type: AGGREGATE_ROOT
    sub_module: 04-JOB-POSITION
    category: Config
    definition: "Career progression path between jobs."
    key_attributes:
      - career_path_id
      - name
      - from_job_id
      - to_job_id
      - typical_duration_months
    relationships:
      - "from [[Job]]"
      - "to [[Job]]"

  # ═══════════════════════════════════════════════════════════
  # SUB-MODULE: 05-MASTER-DATA
  # ═══════════════════════════════════════════════════════════
  
  - id: E-CO-040
    name: Skill
    type: REFERENCE_DATA
    sub_module: 05-MASTER-DATA
    category: Config
    definition: "Skill definition in skill dictionary."
    key_attributes:
      - skill_id
      - skill_code
      - name
      - category
      - is_active
    relationships:
      - "used by [[SkillAssignment]]"

  - id: E-CO-041
    name: Competency
    type: REFERENCE_DATA
    sub_module: 05-MASTER-DATA
    category: Config
    definition: "Competency definition for performance."
    key_attributes:
      - competency_id
      - competency_code
      - name
      - competency_type (CORE | FUNCTIONAL | LEADERSHIP)
    relationships:
      - "used by [[JobCompetency]]"

  - id: E-CO-042
    name: Country
    type: REFERENCE_DATA
    sub_module: 05-MASTER-DATA
    category: Config
    definition: "Country reference data."
    key_attributes:
      - country_code
      - country_name
      - currency_code
      - timezone
    relationships: []

  - id: E-CO-043
    name: Currency
    type: REFERENCE_DATA
    sub_module: 05-MASTER-DATA
    category: Config
    definition: "Currency reference data."
    key_attributes:
      - currency_code
      - currency_name
      - symbol
      - decimal_places
    relationships: []

  # ═══════════════════════════════════════════════════════════
  # SUB-MODULE: 07-ELIGIBILITY
  # ═══════════════════════════════════════════════════════════
  
  - id: E-CO-050
    name: EligibilityProfile
    type: AGGREGATE_ROOT
    sub_module: 07-ELIGIBILITY
    category: Config
    definition: "Cross-module eligibility profile defining who is eligible for what."
    key_attributes:
      - profile_id
      - profile_code
      - name
      - target_module (BENEFITS | LEAVE | PAYROLL)
      - eligibility_type (INCLUDE | EXCLUDE)
    relationships:
      - "has many [[EligibilityRule]]"
    competitor_reference: "Workday: Eligibility Rule, Oracle: Eligibility Profile"

  - id: E-CO-051
    name: EligibilityRule
    type: ENTITY
    sub_module: 07-ELIGIBILITY
    category: Config
    definition: "Rule condition for eligibility evaluation."
    key_attributes:
      - rule_id
      - field_name
      - operator (EQUALS | IN | GREATER_THAN | LESS_THAN)
      - value
    relationships:
      - "belongs to [[EligibilityProfile]]"
---

# Entity Catalog: Core HR

> **Note**: YAML above is for AI processing. Tables below for human reading.

## A. Core Master Data (AGGREGATE_ROOT)

| ID | Entity | Sub-module | Definition |
|----|--------|------------|------------|
| E-CO-001 | **[[Worker]]** | Person | Central person master data |
| E-CO-010 | **[[Employee]]** | Employment | Employment relationship |
| E-CO-020 | **[[LegalEntity]]** | Org Structure | Legal company entity |
| E-CO-021 | **[[BusinessUnit]]** | Org Structure | Business unit/department |
| E-CO-030 | **[[Job]]** | Job & Position | Job catalog definition |
| E-CO-031 | **[[Position]]** | Job & Position | Position in org structure |
| E-CO-033 | **[[CareerPath]]** | Job & Position | Career progression path |
| E-CO-050 | **[[EligibilityProfile]]** | Eligibility | Cross-module eligibility |

## B. Child Entities (ENTITY)

| ID | Entity | Parent | Definition |
|----|--------|--------|------------|
| E-CO-002 | [[Contact]] | Worker | Phone, email contacts |
| E-CO-003 | [[Address]] | Worker | Physical addresses |
| E-CO-004 | [[Document]] | Worker | Identity documents |
| E-CO-005 | [[SkillAssignment]] | Worker | Skills with proficiency |
| E-CO-006 | [[EducationRecord]] | Worker | Education history |
| E-CO-007 | [[Dependent]] | Worker | Family dependents |
| E-CO-011 | [[Contract]] | Employee | Employment contract |
| E-CO-012 | [[Assignment]] | Employee | Position assignment |
| E-CO-022 | [[CostCenter]] | LegalEntity | Cost center |
| E-CO-023 | [[Location]] | LegalEntity | Work location |
| E-CO-032 | [[JobFamily]] | - | Job grouping |
| E-CO-051 | [[EligibilityRule]] | EligibilityProfile | Eligibility condition |

## C. Reference Data (REFERENCE_DATA)

| ID | Entity | Sub-module | Definition |
|----|--------|------------|------------|
| E-CO-040 | [[Skill]] | Master Data | Skill dictionary |
| E-CO-041 | [[Competency]] | Master Data | Competency definitions |
| E-CO-042 | [[Country]] | Master Data | Country reference |
| E-CO-043 | [[Currency]] | Master Data | Currency reference |

## D. Entity Relationship Map

```mermaid
erDiagram
    Worker ||--o{ Contact : "has"
    Worker ||--o{ Address : "has"
    Worker ||--o{ Document : "has"
    Worker ||--o{ SkillAssignment : "has"
    Worker ||--o{ EducationRecord : "has"
    Worker ||--o{ Dependent : "has"
    Worker ||--|| Employee : "becomes"
    
    Employee }o--|| LegalEntity : "employed by"
    Employee ||--o{ Contract : "has"
    Employee ||--o{ Assignment : "has"
    
    LegalEntity ||--o{ BusinessUnit : "contains"
    LegalEntity ||--o{ CostCenter : "has"
    LegalEntity ||--o{ Location : "has"
    
    BusinessUnit ||--o{ Position : "contains"
    BusinessUnit }o--o| BusinessUnit : "parent"
    
    Job ||--o{ Position : "instances"
    Job }o--|| JobFamily : "belongs to"
    Position ||--o{ Assignment : "has"
    Position }o--o| Position : "reports to"
    
    EligibilityProfile ||--o{ EligibilityRule : "has"
```
