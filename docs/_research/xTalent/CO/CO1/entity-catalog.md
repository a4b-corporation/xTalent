---
domain: Core HR
module: CO
version: "1.0.0"
status: DRAFT
created: "2026-01-23"

# === ENTITY DATA ===
entities:
  # ===========================================
  # A. CORE MASTER DATA - Worker & Person
  # ===========================================
  - id: E-CO-001
    name: Person
    type: AGGREGATE_ROOT
    category: Master
    stability: HIGH
    change_frequency: RARE
    definition: "Represents a unique individual in the system. A Person may have multiple Workers (employment relationships) over time."
    key_attributes:
      - id
      - firstName
      - lastName
      - dateOfBirth
      - gender
      - nationalId
      - email
      - phone
    relationships:
      - "has many [[Worker]]"
      - "has many [[PersonAddress]]"
      - "has many [[EmergencyContact]]"
      - "has many [[Dependent]]"
    dependencies:
      upstream: []
      downstream: ["Payroll.Payee", "Benefits.Beneficiary"]
    lifecycle: null
    pii_sensitivity: HIGH
    competitor_reference: "Workday: Person, SAP: Person (PA), Oracle: Person"
    decision_ref: null

  - id: E-CO-002
    name: Worker
    type: AGGREGATE_ROOT
    category: Master
    stability: HIGH
    change_frequency: RARE
    definition: "Represents an individual's employment relationship with the organization. A Person can be a Worker multiple times (rehire). Worker types include Employee, Contractor, Intern."
    key_attributes:
      - id
      - workerId
      - workerType
      - hireDate
      - terminationDate
      - status
      - personId
    relationships:
      - "belongs to [[Person]]"
      - "has many [[Employment]]"
      - "has many [[WorkerDocument]]"
    dependencies:
      upstream: ["Identity.User"]
      downstream: ["Payroll.Worker", "Time.Worker", "Benefits.Employee", "Talent.Employee"]
    lifecycle: "Pre-Hire → Active → On Leave → Terminated → Rehired"
    pii_sensitivity: MEDIUM
    competitor_reference: "Workday: Worker, SAP: Employee, Oracle: Worker"
    decision_ref: "ADR-CO-002"

  - id: E-CO-003
    name: Employment
    type: ENTITY
    category: Transaction
    stability: MEDIUM
    change_frequency: YEARLY
    definition: "A specific employment instance with effective dates. Captures position assignment, compensation, and organizational placement at a point in time."
    key_attributes:
      - id
      - workerId
      - positionId
      - jobProfileId
      - effectiveDate
      - endDate
      - employmentType
      - workSchedule
    relationships:
      - "belongs to [[Worker]]"
      - "references [[Position]]"
      - "references [[JobProfile]]"
      - "references [[Department]]"
      - "references [[Location]]"
    dependencies:
      upstream: []
      downstream: ["Payroll.Assignment", "Time.Assignment"]
    lifecycle: null
    pii_sensitivity: LOW
    competitor_reference: "Workday: Position Assignment, SAP: Employment Record"
    decision_ref: "ADR-CO-003"

  # ===========================================
  # B. ORGANIZATION STRUCTURE
  # ===========================================
  - id: E-CO-010
    name: LegalEntity
    type: AGGREGATE_ROOT
    category: Master
    stability: HIGH
    change_frequency: RARE
    definition: "A legally registered business entity. Employees are hired into a Legal Entity for payroll and tax purposes."
    key_attributes:
      - id
      - code
      - name
      - taxId
      - country
      - currency
      - status
    relationships:
      - "has many [[BusinessUnit]]"
      - "has many [[Worker]]"
    dependencies:
      upstream: []
      downstream: ["Payroll.LegalEntity", "Finance.Company"]
    lifecycle: null
    pii_sensitivity: NONE
    competitor_reference: "Workday: Company, SAP: Company Code, Oracle: Legal Entity"
    decision_ref: null

  - id: E-CO-011
    name: BusinessUnit
    type: ENTITY
    category: Master
    stability: MEDIUM
    change_frequency: YEARLY
    definition: "A division or major organizational unit within a Legal Entity. Used for reporting and cost allocation."
    key_attributes:
      - id
      - code
      - name
      - legalEntityId
      - parentBusinessUnitId
      - status
    relationships:
      - "belongs to [[LegalEntity]]"
      - "has many child [[BusinessUnit]]"
      - "has many [[Department]]"
    dependencies:
      upstream: []
      downstream: ["Finance.CostCenter", "Reporting.Hierarchy"]
    lifecycle: null
    pii_sensitivity: NONE
    competitor_reference: "Workday: Supervisory Organization, SAP: Business Area"
    decision_ref: null

  - id: E-CO-012
    name: Department
    type: ENTITY
    category: Master
    stability: MEDIUM
    change_frequency: YEARLY
    definition: "A functional unit within an organization where employees are assigned. Forms the basis of org chart."
    key_attributes:
      - id
      - code
      - name
      - businessUnitId
      - parentDepartmentId
      - managerId
      - costCenterId
      - status
    relationships:
      - "belongs to [[BusinessUnit]]"
      - "has manager [[Worker]]"
      - "has many [[Position]]"
    dependencies:
      upstream: []
      downstream: ["Reporting.OrgChart", "Approval.Hierarchy"]
    lifecycle: null
    pii_sensitivity: NONE
    competitor_reference: "Workday: Department, SAP: Organizational Unit, Oracle: Department"
    decision_ref: null

  - id: E-CO-013
    name: Location
    type: REFERENCE_DATA
    category: Config
    stability: HIGH
    change_frequency: YEARLY
    definition: "A physical or virtual work location where employees may be assigned."
    key_attributes:
      - id
      - code
      - name
      - addressLine1
      - city
      - country
      - timezone
      - status
    relationships:
      - "used by [[Position]]"
      - "used by [[Employment]]"
    dependencies:
      upstream: []
      downstream: ["Time.LocationCalendar"]
    lifecycle: null
    pii_sensitivity: NONE
    competitor_reference: "Workday: Location, SAP: Location, Oracle: Location"
    decision_ref: null

  - id: E-CO-014
    name: CostCenter
    type: REFERENCE_DATA
    category: Config
    stability: MEDIUM
    change_frequency: YEARLY
    definition: "Accounting unit for tracking labor costs. Positions and departments are assigned to cost centers."
    key_attributes:
      - id
      - code
      - name
      - legalEntityId
      - status
    relationships:
      - "used by [[Department]]"
      - "used by [[Position]]"
    dependencies:
      upstream: []
      downstream: ["Finance.CostCenter", "Payroll.CostAllocation"]
    lifecycle: null
    pii_sensitivity: NONE
    competitor_reference: "Workday: Cost Center, SAP: Cost Center, Oracle: Cost Center"
    decision_ref: null

  # ===========================================
  # C. POSITION & JOB
  # ===========================================
  - id: E-CO-020
    name: JobProfile
    type: REFERENCE_DATA
    category: Config
    stability: HIGH
    change_frequency: RARE
    definition: "A template defining a role's responsibilities, requirements, and compensation grade. Jobs are reusable across positions."
    key_attributes:
      - id
      - code
      - title
      - jobFamily
      - jobLevel
      - gradeId
      - description
      - status
    relationships:
      - "belongs to [[JobFamily]]"
      - "has [[Grade]]"
      - "template for [[Position]]"
    dependencies:
      upstream: []
      downstream: ["Compensation.JobGrade", "Recruiting.JobPosting"]
    lifecycle: null
    pii_sensitivity: NONE
    competitor_reference: "Workday: Job Profile, SAP: Job, Oracle: Job"
    decision_ref: null

  - id: E-CO-021
    name: JobFamily
    type: REFERENCE_DATA
    category: Config
    stability: HIGH
    change_frequency: RARE
    definition: "A grouping of related jobs for career pathing and compensation benchmarking."
    key_attributes:
      - id
      - code
      - name
      - description
      - status
    relationships:
      - "has many [[JobProfile]]"
    dependencies:
      upstream: []
      downstream: ["Talent.CareerPath"]
    lifecycle: null
    pii_sensitivity: NONE
    competitor_reference: "Workday: Job Family, SAP: Job Family, Oracle: Job Family"
    decision_ref: null

  - id: E-CO-022
    name: Position
    type: AGGREGATE_ROOT
    category: Master
    stability: MEDIUM
    change_frequency: QUARTERLY
    definition: "A specific seat in the organization that can be filled by a worker. Positions enable headcount control and budget tracking."
    key_attributes:
      - id
      - positionId
      - title
      - jobProfileId
      - departmentId
      - locationId
      - costCenterId
      - reportsToPositionId
      - status
      - filled
    relationships:
      - "uses template [[JobProfile]]"
      - "belongs to [[Department]]"
      - "located at [[Location]]"
      - "reports to [[Position]]"
      - "has [[Employment]]"
    dependencies:
      upstream: []
      downstream: ["Recruiting.Requisition", "Payroll.Position"]
    lifecycle: "Open → Filled → Vacant → Closed"
    pii_sensitivity: NONE
    competitor_reference: "Workday: Position, SAP: Position, Oracle: Position"
    decision_ref: "ADR-CO-001"

  # ===========================================
  # D. LEAVE & TIME FOUNDATION
  # ===========================================
  - id: E-CO-030
    name: LeaveType
    type: REFERENCE_DATA
    category: Config
    stability: HIGH
    change_frequency: YEARLY
    definition: "Types of leave available (Annual, Sick, Maternity, Paternity, Unpaid, etc.). Configurable per legal entity."
    key_attributes:
      - id
      - code
      - name
      - isPaid
      - maxDaysPerYear
      - accrualRule
      - legalEntityId
      - status
    relationships:
      - "used by [[LeaveRequest]]"
      - "used by [[LeaveBalance]]"
    dependencies:
      upstream: []
      downstream: ["Time.LeavePolicy"]
    lifecycle: null
    pii_sensitivity: NONE
    competitor_reference: "Workday: Time Off Type, SAP: Absence Type, Oracle: Absence Type"
    decision_ref: null

  - id: E-CO-031
    name: LeaveBalance
    type: ENTITY
    category: Transaction
    stability: MEDIUM
    change_frequency: QUARTERLY
    definition: "Tracks available leave days for a worker by leave type. Updated through accruals and usage."
    key_attributes:
      - id
      - workerId
      - leaveTypeId
      - accrued
      - used
      - available
      - asOfDate
    relationships:
      - "belongs to [[Worker]]"
      - "for [[LeaveType]]"
    dependencies:
      upstream: []
      downstream: ["Time.LeaveBalance"]
    lifecycle: null
    pii_sensitivity: LOW
    competitor_reference: "Workday: Time Off Balance, SAP: Leave Balance"
    decision_ref: null

  - id: E-CO-032
    name: LeaveRequest
    type: AGGREGATE_ROOT
    category: Transaction
    stability: LOW
    change_frequency: REALTIME
    definition: "An employee's request to take leave. Subject to approval workflow."
    key_attributes:
      - id
      - workerId
      - leaveTypeId
      - startDate
      - endDate
      - duration
      - status
      - approverId
      - approvedAt
      - comments
    relationships:
      - "submitted by [[Worker]]"
      - "for [[LeaveType]]"
      - "approved by [[Worker]]"
    dependencies:
      upstream: []
      downstream: ["Time.Absence", "Payroll.LeaveDeduction"]
    lifecycle: "Draft → Submitted → Approved → Taken → Cancelled"
    pii_sensitivity: LOW
    competitor_reference: "Workday: Time Off Request, SAP: Leave Request, Oracle: Absence Request"
    decision_ref: null

  - id: E-CO-033
    name: HolidayCalendar
    type: REFERENCE_DATA
    category: Config
    stability: HIGH
    change_frequency: YEARLY
    definition: "Defines public holidays and company holidays for a legal entity or location."
    key_attributes:
      - id
      - name
      - legalEntityId
      - locationId
      - year
      - status
    relationships:
      - "has many [[Holiday]]"
      - "used by [[LeaveBalance]]"
    dependencies:
      upstream: []
      downstream: ["Time.WorkCalendar", "Payroll.Calendar"]
    lifecycle: null
    pii_sensitivity: NONE
    competitor_reference: "Workday: Holiday Calendar, SAP: Holiday Calendar"
    decision_ref: null

  # ===========================================
  # E. EMPLOYEE PERSONAL DATA
  # ===========================================
  - id: E-CO-040
    name: PersonAddress
    type: ENTITY
    category: Master
    stability: MEDIUM
    change_frequency: YEARLY
    definition: "Physical addresses associated with a person (home, mailing, etc.)."
    key_attributes:
      - id
      - personId
      - addressType
      - addressLine1
      - addressLine2
      - city
      - province
      - postalCode
      - country
      - isPrimary
      - effectiveDate
    relationships:
      - "belongs to [[Person]]"
    dependencies:
      upstream: []
      downstream: ["Payroll.TaxAddress"]
    lifecycle: null
    pii_sensitivity: HIGH
    competitor_reference: "Workday: Address, SAP: Address, Oracle: Person Address"
    decision_ref: null

  - id: E-CO-041
    name: EmergencyContact
    type: ENTITY
    category: Master
    stability: MEDIUM
    change_frequency: YEARLY
    definition: "Emergency contact information for a person."
    key_attributes:
      - id
      - personId
      - name
      - relationship
      - phone
      - email
      - priority
    relationships:
      - "belongs to [[Person]]"
    dependencies:
      upstream: []
      downstream: []
    lifecycle: null
    pii_sensitivity: HIGH
    competitor_reference: "Workday: Emergency Contact, SAP: Emergency Contact"
    decision_ref: null

  - id: E-CO-042
    name: Dependent
    type: ENTITY
    category: Master
    stability: MEDIUM
    change_frequency: YEARLY
    definition: "Family members or dependents of a worker for benefits and tax purposes."
    key_attributes:
      - id
      - personId
      - name
      - relationship
      - dateOfBirth
      - gender
      - nationalId
      - status
    relationships:
      - "belongs to [[Person]]"
    dependencies:
      upstream: []
      downstream: ["Benefits.Enrollment", "Payroll.TaxDeduction"]
    lifecycle: null
    pii_sensitivity: HIGH
    competitor_reference: "Workday: Dependent, SAP: Family Member, Oracle: Dependent"
    decision_ref: null

  - id: E-CO-043
    name: BankAccount
    type: ENTITY
    category: Master
    stability: MEDIUM
    change_frequency: YEARLY
    definition: "Worker's bank account information for salary payment."
    key_attributes:
      - id
      - workerId
      - bankName
      - bankCode
      - accountNumber
      - accountHolder
      - isPrimary
      - status
    relationships:
      - "belongs to [[Worker]]"
    dependencies:
      upstream: []
      downstream: ["Payroll.PaymentMethod"]
    lifecycle: null
    pii_sensitivity: HIGH
    competitor_reference: "Workday: Payment Election, SAP: Bank Details, Oracle: Personal Payment Method"
    decision_ref: null

  # ===========================================
  # F. DOCUMENTS & COMPLIANCE
  # ===========================================
  - id: E-CO-050
    name: WorkerDocument
    type: ENTITY
    category: Transaction
    stability: MEDIUM
    change_frequency: YEARLY
    definition: "Documents associated with a worker (contracts, ID copies, certificates, etc.)."
    key_attributes:
      - id
      - workerId
      - documentType
      - title
      - fileUrl
      - uploadedAt
      - expiryDate
      - status
    relationships:
      - "belongs to [[Worker]]"
      - "categorized by [[DocumentType]]"
    dependencies:
      upstream: []
      downstream: []
    lifecycle: null
    pii_sensitivity: HIGH
    competitor_reference: "Workday: Worker Document, SAP: Employee Document"
    decision_ref: null

  - id: E-CO-051
    name: DataConsent
    type: ENTITY
    category: Transaction
    stability: LOW
    change_frequency: QUARTERLY
    definition: "Records employee consent for data processing as required by PDPL/GDPR."
    key_attributes:
      - id
      - workerId
      - consentType
      - consentedAt
      - expiresAt
      - version
      - status
    relationships:
      - "given by [[Worker]]"
    dependencies:
      upstream: []
      downstream: []
    lifecycle: "Pending → Consented → Withdrawn → Expired"
    pii_sensitivity: LOW
    competitor_reference: "Workday: Consent, SAP: Data Protection"
    decision_ref: "ADR-CO-005"

  - id: E-CO-052
    name: AuditLog
    type: ENTITY
    category: Transaction
    stability: LOW
    change_frequency: REALTIME
    definition: "Tracks all changes to sensitive employee data for compliance and audit purposes."
    key_attributes:
      - id
      - entityType
      - entityId
      - action
      - field
      - oldValue
      - newValue
      - changedBy
      - changedAt
      - ipAddress
    relationships:
      - "tracks [[Worker]]"
      - "tracks [[Person]]"
    dependencies:
      upstream: []
      downstream: []
    lifecycle: null
    pii_sensitivity: LOW
    competitor_reference: "Workday: Business Process History, SAP: Change Log"
    decision_ref: null

  # ===========================================
  # G. REFERENCE DATA - LOOKUPS
  # ===========================================
  - id: E-CO-060
    name: WorkerType
    type: REFERENCE_DATA
    category: Config
    stability: HIGH
    change_frequency: RARE
    definition: "Classification of workers: Employee, Contractor, Intern, Probation, etc."
    key_attributes:
      - code
      - name
      - isEmployee
      - status
    dependencies:
      upstream: []
      downstream: []
    pii_sensitivity: NONE
    competitor_reference: "Workday: Worker Type, SAP: Employee Class"
    decision_ref: "ADR-CO-002"

  - id: E-CO-061
    name: EmploymentType
    type: REFERENCE_DATA
    category: Config
    stability: HIGH
    change_frequency: RARE
    definition: "Employment arrangement: Full-time, Part-time, Fixed-term, etc."
    key_attributes:
      - code
      - name
      - hoursPerWeek
      - status
    dependencies:
      upstream: []
      downstream: ["Payroll.WorkSchedule"]
    pii_sensitivity: NONE
    competitor_reference: "Workday: Employment Type, SAP: Contract Type"
    decision_ref: null

  - id: E-CO-062
    name: TerminationReason
    type: REFERENCE_DATA
    category: Config
    stability: HIGH
    change_frequency: YEARLY
    definition: "Reasons for employment termination: Resignation, Retirement, Layoff, Termination for Cause, etc."
    key_attributes:
      - code
      - name
      - category
      - isVoluntary
      - status
    dependencies:
      upstream: []
      downstream: ["Analytics.Turnover"]
    pii_sensitivity: NONE
    competitor_reference: "Workday: Termination Reason, SAP: Reason for Leaving"
    decision_ref: null

  - id: E-CO-063
    name: DocumentType
    type: REFERENCE_DATA
    category: Config
    stability: HIGH
    change_frequency: YEARLY
    definition: "Types of worker documents: Contract, ID Card, Passport, Certificate, etc."
    key_attributes:
      - code
      - name
      - retentionYears
      - isMandatory
      - status
    dependencies:
      upstream: []
      downstream: []
    pii_sensitivity: NONE
    competitor_reference: "Workday: Document Category, SAP: Document Type"
    decision_ref: null
---

# Entity Catalog: Core HR

> **Note**: YAML above is for AI processing. Tables below for human reading.

## A. Core Master Data - Worker & Person

| ID | Entity | Stability | Frequency | PII | Definition |
|----|--------|-----------|-----------|-----|------------|
| E-CO-001 | **[[Person]]** | HIGH | RARE | HIGH | Unique individual in the system |
| E-CO-002 | **[[Worker]]** | HIGH | RARE | MEDIUM | Employment relationship with organization |
| E-CO-003 | **[[Employment]]** | MEDIUM | YEARLY | LOW | Specific employment instance with effective dates |

**Key Relationships:**
- Person → Worker (one-to-many: rehires)
- Worker → Employment (one-to-many: transfers, promotions)
- Worker → Position (via Employment)

**Competitor Mapping:**
- Workday: Person / Worker / Position Assignment
- SAP: Person / Employee / Employment Record
- Oracle: Person / Worker / Assignment

---

## B. Organization Structure

| ID | Entity | Stability | Frequency | Definition |
|----|--------|-----------|-----------|------------|
| E-CO-010 | **[[LegalEntity]]** | HIGH | RARE | Legally registered business entity |
| E-CO-011 | **[[BusinessUnit]]** | MEDIUM | YEARLY | Division within Legal Entity |
| E-CO-012 | **[[Department]]** | MEDIUM | YEARLY | Functional unit, basis of org chart |
| E-CO-013 | **[[Location]]** | HIGH | YEARLY | Physical/virtual work location |
| E-CO-014 | **[[CostCenter]]** | MEDIUM | YEARLY | Accounting unit for labor costs |

**Dependencies:**
- Downstream: Finance.CostCenter, Payroll, Reporting

---

## C. Position & Job

| ID | Entity | Stability | Frequency | Lifecycle |
|----|--------|-----------|-----------|-----------|
| E-CO-020 | **[[JobProfile]]** | HIGH | RARE | - |
| E-CO-021 | **[[JobFamily]]** | HIGH | RARE | - |
| E-CO-022 | **[[Position]]** | MEDIUM | QUARTERLY | Open → Filled → Vacant → Closed |

**Key Relationships:**
- JobFamily → JobProfile (categorization)
- JobProfile → Position (template)
- Position → Employment (assignment)
- Position → Position (reporting hierarchy)

---

## D. Leave & Time Foundation

| ID | Entity | Stability | Frequency | Lifecycle |
|----|--------|-----------|-----------|-----------|
| E-CO-030 | **[[LeaveType]]** | HIGH | YEARLY | - |
| E-CO-031 | **[[LeaveBalance]]** | MEDIUM | QUARTERLY | - |
| E-CO-032 | **[[LeaveRequest]]** | LOW | REALTIME | Draft → Submitted → Approved → Taken |
| E-CO-033 | **[[HolidayCalendar]]** | HIGH | YEARLY | - |

---

## E. Employee Personal Data

| ID | Entity | Stability | Frequency | PII |
|----|--------|-----------|-----------|-----|
| E-CO-040 | **[[PersonAddress]]** | MEDIUM | YEARLY | HIGH |
| E-CO-041 | **[[EmergencyContact]]** | MEDIUM | YEARLY | HIGH |
| E-CO-042 | **[[Dependent]]** | MEDIUM | YEARLY | HIGH |
| E-CO-043 | **[[BankAccount]]** | MEDIUM | YEARLY | HIGH |

---

## F. Documents & Compliance

| ID | Entity | Stability | Frequency | Lifecycle |
|----|--------|-----------|-----------|-----------|
| E-CO-050 | **[[WorkerDocument]]** | MEDIUM | YEARLY | - |
| E-CO-051 | **[[DataConsent]]** | LOW | QUARTERLY | Pending → Consented → Withdrawn |
| E-CO-052 | **[[AuditLog]]** | LOW | REALTIME | - |

---

## G. Reference Data

| ID | Entity | Frequency | Definition |
|----|--------|-----------|------------|
| E-CO-060 | **[[WorkerType]]** | RARE | Employee, Contractor, Intern |
| E-CO-061 | **[[EmploymentType]]** | RARE | Full-time, Part-time, Fixed-term |
| E-CO-062 | **[[TerminationReason]]** | YEARLY | Resignation, Layoff, etc. |
| E-CO-063 | **[[DocumentType]]** | YEARLY | Contract, ID, Certificate |

---

## H. Entity Relationships

```mermaid
erDiagram
    Person ||--o{ Worker : "has many"
    Person ||--o{ PersonAddress : "has"
    Person ||--o{ EmergencyContact : "has"
    Person ||--o{ Dependent : "has"
    
    Worker ||--o{ Employment : "has many"
    Worker ||--o{ BankAccount : "has"
    Worker ||--o{ WorkerDocument : "has"
    Worker ||--o{ LeaveBalance : "has"
    Worker ||--o{ LeaveRequest : "submits"
    Worker ||--o{ DataConsent : "gives"
    
    LegalEntity ||--o{ BusinessUnit : "contains"
    BusinessUnit ||--o{ Department : "contains"
    Department ||--o{ Position : "has"
    
    JobFamily ||--o{ JobProfile : "groups"
    JobProfile ||--o{ Position : "templates"
    
    Position ||--o{ Employment : "filled by"
    Position }o--|| Position : "reports to"
    Position }o--|| Location : "located at"
    Position }o--|| CostCenter : "charged to"
    
    LeaveType ||--o{ LeaveBalance : "for"
    LeaveType ||--o{ LeaveRequest : "for"
```

---

## I. Change Frequency Analysis

| Frequency | Count | Entities | Architecture |
|-----------|-------|----------|--------------|
| **RARE** (< 5yr) | 8 | Person, Worker, LegalEntity, JobProfile, JobFamily, WorkerType, EmploymentType, Location | Hard-coded schema |
| **YEARLY** | 10 | Employment, BusinessUnit, Department, CostCenter, LeaveType, PersonAddress, EmergencyContact, Dependent, BankAccount, TerminationReason | Configuration tables |
| **QUARTERLY** | 3 | Position, LeaveBalance, DataConsent | State machine, workflows |
| **REALTIME** | 2 | LeaveRequest, AuditLog | Event stream, eventual consistency |

---

## J. PII Sensitivity Summary

| Level | Count | Entities | Compliance |
|-------|-------|----------|------------|
| **HIGH** | 7 | Person, PersonAddress, EmergencyContact, Dependent, BankAccount, WorkerDocument, AuditLog (contains PII) | PDPL consent, encryption at rest, access logging |
| **MEDIUM** | 1 | Worker | Standard data protection |
| **LOW** | 5 | Employment, LeaveBalance, LeaveRequest, DataConsent, AuditLog | Standard access control |
| **NONE** | 10 | All organizational and reference data | No special handling |
