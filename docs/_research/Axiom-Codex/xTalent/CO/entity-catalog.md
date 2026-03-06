---
domain: CORE_HR
module: CO
version: "1.0.0"
status: DRAFT
created: "2026-01-15"

# === ENTITY DATA ===
entities:
  # ==========================================
  # CORE MASTER DATA - People & Workforce
  # ==========================================
  
  - id: E-CO-001
    name: Employee
    type: AGGREGATE_ROOT
    category: Master
    definition: "A person who has an employment relationship with the organization. Central entity linking person data to organizational placement via assignments."
    key_attributes:
      - id
      - employeeCode
      - personId
      - hireDate
      - status
      - primaryAssignmentId
    relationships:
      - "is a [[Person]]"
      - "has many [[Assignment]]"
      - "has many [[Contract]]"
      - "reportsTo [[Employee]] (manager)"
    lifecycle: "PreHire → Onboarding → Probation → Active → OnLeave → Offboarding → Terminated"
    competitor_reference: "Workday: Worker, SAP: Employee, Oracle: Person"
    priority: MUST

  - id: E-CO-002
    name: Person
    type: ENTITY
    category: Master
    definition: "A natural person with personal details. May or may not be an employee (supports pre-hire, contractor, dependent tracking)."
    key_attributes:
      - id
      - firstName
      - lastName
      - middleName
      - dateOfBirth
      - gender
      - nationality
      - nationalId
      - taxId
    relationships:
      - "has many [[Address]]"
      - "has many [[Contact]]"
      - "has many [[Document]]"
      - "has many [[EmergencyContact]]"
      - "has many [[BankAccount]]"
    competitor_reference: "Workday: Person, SAP: Personal Information, Oracle: Person"
    priority: MUST

  - id: E-CO-003
    name: Address
    type: VALUE_OBJECT
    category: Master
    definition: "A physical or mailing address for a person or organization."
    key_attributes:
      - id
      - addressType
      - addressLine1
      - addressLine2
      - city
      - state
      - postalCode
      - country
      - isPrimary
      - effectiveDate
      - endDate
    relationships:
      - "belongsTo [[Person]] or [[Organization]]"
    priority: MUST

  - id: E-CO-004
    name: Contact
    type: VALUE_OBJECT
    category: Master
    definition: "Contact information (phone, email) for a person."
    key_attributes:
      - id
      - contactType
      - contactValue
      - isPrimary
      - isVerified
    relationships:
      - "belongsTo [[Person]]"
    priority: MUST

  - id: E-CO-005
    name: EmergencyContact
    type: VALUE_OBJECT
    category: Master
    definition: "Emergency contact information for an employee."
    key_attributes:
      - id
      - name
      - relationship
      - phone
      - address
      - priority
    relationships:
      - "belongsTo [[Person]]"
    priority: SHOULD

  - id: E-CO-006
    name: BankAccount
    type: VALUE_OBJECT
    category: Master
    definition: "Bank account details for salary payment."
    key_attributes:
      - id
      - bankName
      - bankCode
      - accountNumber
      - accountHolderName
      - isPrimary
      - percentage
    relationships:
      - "belongsTo [[Person]]"
    priority: MUST

  - id: E-CO-007
    name: Document
    type: ENTITY
    category: Master
    definition: "Digital or physical document attached to an employee record."
    key_attributes:
      - id
      - documentType
      - documentNumber
      - issueDate
      - expiryDate
      - issuingAuthority
      - filePath
      - status
    relationships:
      - "belongsTo [[Person]]"
    priority: SHOULD

  # ==========================================
  # ORGANIZATION STRUCTURE
  # ==========================================

  - id: E-CO-010
    name: Organization
    type: AGGREGATE_ROOT
    category: Master
    definition: "A legal entity or business unit within the enterprise. Root of organizational hierarchy."
    key_attributes:
      - id
      - code
      - name
      - legalName
      - taxId
      - registrationNumber
      - organizationType
      - status
      - effectiveDate
    relationships:
      - "has many [[Department]]"
      - "has many [[Location]]"
      - "has many [[CostCenter]]"
      - "parentOrganization [[Organization]]"
    competitor_reference: "Workday: Company, SAP: Legal Entity, Oracle: Business Unit"
    priority: MUST

  - id: E-CO-011
    name: Department
    type: ENTITY
    category: Master
    definition: "A functional unit within an organization."
    key_attributes:
      - id
      - code
      - name
      - description
      - managerId
      - status
      - effectiveDate
      - endDate
    relationships:
      - "belongsTo [[Organization]]"
      - "parentDepartment [[Department]]"
      - "has many [[Position]]"
      - "managedBy [[Employee]]"
    competitor_reference: "Workday: Supervisory Org, SAP: Org Unit, Oracle: Department"
    priority: MUST

  - id: E-CO-012
    name: Location
    type: REFERENCE_DATA
    category: Config
    definition: "A physical work location or site."
    key_attributes:
      - id
      - code
      - name
      - locationType
      - address
      - timeZone
      - country
      - status
    relationships:
      - "belongsTo [[Organization]]"
    priority: MUST

  - id: E-CO-013
    name: CostCenter
    type: REFERENCE_DATA
    category: Config
    definition: "An accounting unit for tracking costs."
    key_attributes:
      - id
      - code
      - name
      - description
      - managerId
      - status
      - effectiveDate
    relationships:
      - "belongsTo [[Organization]]"
      - "managedBy [[Employee]]"
    priority: SHOULD

  # ==========================================
  # POSITION & JOB MANAGEMENT
  # ==========================================

  - id: E-CO-020
    name: Job
    type: ENTITY
    category: Master
    definition: "A generic role definition describing a type of work (e.g., 'Software Engineer'). Not a specific seat."
    key_attributes:
      - id
      - code
      - title
      - description
      - jobFamily
      - jobLevel
      - status
    relationships:
      - "has many [[Position]]"
      - "has one [[JobProfile]]"
      - "belongsTo [[JobFamily]]"
    competitor_reference: "Workday: Job Profile, SAP: Job, Oracle: Job"
    priority: MUST

  - id: E-CO-021
    name: Position
    type: AGGREGATE_ROOT
    category: Master
    definition: "A specific seat in the organization structure. Exists independently of the employee filling it."
    key_attributes:
      - id
      - positionCode
      - positionTitle
      - jobId
      - departmentId
      - locationId
      - costCenterId
      - supervisorPositionId
      - fte
      - status
      - effectiveDate
      - endDate
    relationships:
      - "isA [[Job]]"
      - "belongsTo [[Department]]"
      - "locatedAt [[Location]]"
      - "chargedTo [[CostCenter]]"
      - "reportsTo [[Position]]"
      - "has one [[Assignment]] (current incumbent)"
    lifecycle: "Draft → Active → Frozen → Closed"
    competitor_reference: "Workday: Position, SAP: Position, Oracle: Position"
    priority: MUST

  - id: E-CO-022
    name: JobFamily
    type: REFERENCE_DATA
    category: Config
    definition: "A grouping of similar jobs (e.g., 'Engineering', 'Sales')."
    key_attributes:
      - id
      - code
      - name
      - description
      - status
    relationships:
      - "has many [[Job]]"
    priority: SHOULD

  - id: E-CO-023
    name: JobProfile
    type: ENTITY
    category: Master
    definition: "Required skills, competencies, and qualifications for a job."
    key_attributes:
      - id
      - jobId
      - education
      - experience
      - skills
      - certifications
      - competencies
    relationships:
      - "belongsTo [[Job]]"
      - "has many [[Competency]]"
    priority: SHOULD

  # ==========================================
  # ASSIGNMENT
  # ==========================================

  - id: E-CO-030
    name: Assignment
    type: ENTITY
    category: Transaction
    definition: "Links an employee to a position with specific work conditions. Employee can have multiple concurrent assignments."
    key_attributes:
      - id
      - employeeId
      - positionId
      - assignmentType
      - assignmentNumber
      - startDate
      - endDate
      - isPrimary
      - fte
      - workSchedule
      - probationEndDate
      - status
    relationships:
      - "assignedTo [[Employee]]"
      - "fills [[Position]]"
      - "hasWorkSchedule [[WorkSchedule]]"
    lifecycle: "Pending → Active → OnHold → Ended"
    competitor_reference: "Workday: Job, SAP: Assignment, Oracle: Assignment"
    priority: MUST

  - id: E-CO-031
    name: WorkSchedule
    type: REFERENCE_DATA
    category: Config
    definition: "Defines working hours and patterns."
    key_attributes:
      - id
      - code
      - name
      - hoursPerWeek
      - hoursPerDay
      - workDays
      - shiftPattern
      - status
    relationships:
      - "used by [[Assignment]]"
    priority: SHOULD

  # ==========================================
  # CONTRACT MANAGEMENT
  # ==========================================

  - id: E-CO-040
    name: Contract
    type: AGGREGATE_ROOT
    category: Transaction
    definition: "Employment agreement between employee and organization."
    key_attributes:
      - id
      - contractNumber
      - employeeId
      - contractType
      - startDate
      - endDate
      - signedDate
      - probationPeriod
      - noticePeriod
      - status
      - templateId
    relationships:
      - "signedBy [[Employee]]"
      - "basedOn [[ContractTemplate]]"
      - "has many [[ContractAmendment]]"
    lifecycle: "Draft → PendingSignature → Active → Expiring → Expired → Terminated"
    competitor_reference: "Workday: Worker Contract, SAP: Employment Contract"
    priority: MUST

  - id: E-CO-041
    name: ContractTemplate
    type: ENTITY
    category: Config
    definition: "Reusable template for generating employment contracts."
    key_attributes:
      - id
      - code
      - name
      - contractType
      - countryCode
      - defaultProbation
      - defaultNoticePeriod
      - templateContent
      - status
    relationships:
      - "used by [[Contract]]"
    priority: SHOULD

  - id: E-CO-042
    name: ContractAmendment
    type: ENTITY
    category: Transaction
    definition: "A modification to an existing contract."
    key_attributes:
      - id
      - contractId
      - amendmentType
      - effectiveDate
      - description
      - changes
      - status
    relationships:
      - "belongsTo [[Contract]]"
    priority: SHOULD

  # ==========================================
  # REFERENCE DATA
  # ==========================================

  - id: E-CO-050
    name: EmploymentType
    type: REFERENCE_DATA
    category: Config
    definition: "Classification of employment (Full-time, Part-time, Contractor, etc.)."
    key_attributes:
      - id
      - code
      - name
      - description
      - isFullTime
      - isContractor
      - status
    priority: MUST

  - id: E-CO-051
    name: EmployeeStatus
    type: REFERENCE_DATA
    category: Config
    definition: "Lifecycle status of an employee."
    key_attributes:
      - id
      - code
      - name
      - description
      - isActive
      - allowsPayroll
    priority: MUST

  - id: E-CO-052
    name: ContractType
    type: REFERENCE_DATA
    category: Config
    definition: "Types of employment contracts."
    key_attributes:
      - id
      - code
      - name
      - description
      - maxDuration
      - isRenewable
    priority: MUST

  - id: E-CO-053
    name: TerminationReason
    type: REFERENCE_DATA
    category: Config
    definition: "Reasons for employee termination."
    key_attributes:
      - id
      - code
      - name
      - description
      - category
      - isVoluntary
    priority: SHOULD
---

# Entity Catalog: Core HR

> **Note**: YAML above is for AI processing. Tables below for human reading.

## Entity Relationship Diagram

```mermaid
erDiagram
    Person ||--o{ Employee : "is"
    Person ||--o{ Address : "has"
    Person ||--o{ Contact : "has"
    Person ||--o{ BankAccount : "has"
    Person ||--o{ Document : "has"
    
    Organization ||--o{ Department : "contains"
    Organization ||--o{ Location : "has"
    Organization ||--o{ CostCenter : "has"
    
    Department ||--o{ Position : "contains"
    Department }o--|| Employee : "managedBy"
    
    Job ||--o{ Position : "defines"
    Job ||--o| JobProfile : "has"
    JobFamily ||--o{ Job : "groups"
    
    Position }o--o| Assignment : "filledBy"
    Position }o--|| CostCenter : "chargedTo"
    Position }o--|| Location : "locatedAt"
    
    Employee ||--o{ Assignment : "has"
    Employee ||--o{ Contract : "signs"
    Employee }o--|| Employee : "reportsTo"
    
    Contract }o--|| ContractTemplate : "basedOn"
    Contract ||--o{ ContractAmendment : "has"
```

---

## A. Core Master Data - People & Workforce

| ID | Entity | Type | Definition |
|----|--------|------|------------|
| E-CO-001 | **[[Employee]]** | AGGREGATE_ROOT | Person with employment relationship. Central entity linking person to organization via assignments. |
| E-CO-002 | **[[Person]]** | ENTITY | Natural person with personal details. Supports pre-hire, contractor, dependent. |
| E-CO-003 | **[[Address]]** | VALUE_OBJECT | Physical or mailing address. |
| E-CO-004 | **[[Contact]]** | VALUE_OBJECT | Phone, email contact information. |
| E-CO-005 | **[[EmergencyContact]]** | VALUE_OBJECT | Emergency contact for employee. |
| E-CO-006 | **[[BankAccount]]** | VALUE_OBJECT | Bank details for salary payment. |
| E-CO-007 | **[[Document]]** | ENTITY | Identity documents, certifications attached to person. |

---

## B. Organization Structure

| ID | Entity | Type | Definition |
|----|--------|------|------------|
| E-CO-010 | **[[Organization]]** | AGGREGATE_ROOT | Legal entity or business unit. Root of org hierarchy. |
| E-CO-011 | **[[Department]]** | ENTITY | Functional unit within organization. |
| E-CO-012 | **[[Location]]** | REFERENCE_DATA | Physical work site. |
| E-CO-013 | **[[CostCenter]]** | REFERENCE_DATA | Accounting unit for cost tracking. |

---

## C. Position & Job Management

| ID | Entity | Type | Definition |
|----|--------|------|------------|
| E-CO-020 | **[[Job]]** | ENTITY | Generic role definition (e.g., "Software Engineer"). |
| E-CO-021 | **[[Position]]** | AGGREGATE_ROOT | Specific seat in organization. Exists independently of incumbent. |
| E-CO-022 | **[[JobFamily]]** | REFERENCE_DATA | Grouping of similar jobs. |
| E-CO-023 | **[[JobProfile]]** | ENTITY | Required skills/competencies for a job. |

---

## D. Assignment

| ID | Entity | Lifecycle | Definition |
|----|--------|-----------|------------|
| E-CO-030 | **[[Assignment]]** | Pending → Active → OnHold → Ended | Links employee to position with work conditions. |
| E-CO-031 | **[[WorkSchedule]]** | - | Working hours and patterns. |

---

## E. Contract Management

| ID | Entity | Lifecycle | Definition |
|----|--------|-----------|------------|
| E-CO-040 | **[[Contract]]** | Draft → PendingSignature → Active → Expiring → Expired → Terminated | Employment agreement. |
| E-CO-041 | **[[ContractTemplate]]** | - | Reusable contract template. |
| E-CO-042 | **[[ContractAmendment]]** | - | Modification to existing contract. |

---

## F. Reference/Config Data

| ID | Entity | Type | Definition |
|----|--------|------|------------|
| E-CO-050 | **[[EmploymentType]]** | REFERENCE_DATA | Full-time, Part-time, Contractor classification. |
| E-CO-051 | **[[EmployeeStatus]]** | REFERENCE_DATA | Lifecycle status values. |
| E-CO-052 | **[[ContractType]]** | REFERENCE_DATA | Types of employment contracts. |
| E-CO-053 | **[[TerminationReason]]** | REFERENCE_DATA | Reasons for employee exit. |

---

## Summary Statistics

| Category | Count |
|----------|-------|
| AGGREGATE_ROOT | 5 |
| ENTITY | 10 |
| VALUE_OBJECT | 4 |
| REFERENCE_DATA | 7 |
| **Total Entities** | **26** |
