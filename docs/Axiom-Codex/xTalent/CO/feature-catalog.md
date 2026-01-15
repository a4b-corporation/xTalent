---
domain: CORE_HR
module: CO
version: "1.0.0"
status: DRAFT
created: "2026-01-15"

# === FEATURE DATA ===
capabilities:
  # ==========================================
  # EMPLOYEE MANAGEMENT
  # ==========================================
  - name: "Employee Management"
    description: "Create, view, update, and manage employee records throughout their lifecycle."
    features:
      - id: FR-CO-001
        name: "Onboard New Employee"
        description: "As an HR Admin, I want to onboard a new employee so that they are properly set up in the system before their start date."
        priority: MUST
        type: Workflow
        competitor_reference: "Workday: Hire, SAP: New Hire, Oracle: Onboarding"
        related_entities:
          - "[[Employee]]"
          - "[[Person]]"
          - "[[Assignment]]"
          - "[[Contract]]"
        sub_features:
          - "Create pre-hire record"
          - "Collect personal information"
          - "Set up assignment and position"
          - "Generate employment contract"
          - "Set probation period"
          - "Assign manager"
          - "Trigger onboarding checklist"

      - id: FR-CO-002
        name: "View Employee Profile"
        description: "As a Manager, I want to view an employee's complete profile so that I can understand their background and current status."
        priority: MUST
        type: Functional
        related_entities:
          - "[[Employee]]"
          - "[[Person]]"
          - "[[Assignment]]"

      - id: FR-CO-003
        name: "Update Employee Information"
        description: "As an Employee, I want to update my personal information so that my records are accurate."
        priority: MUST
        type: Functional
        related_entities:
          - "[[Person]]"
          - "[[Address]]"
          - "[[Contact]]"
        sub_features:
          - "Update personal details"
          - "Update contact information"
          - "Update emergency contacts"
          - "Update bank details"
          - "Request document update"

      - id: FR-CO-004
        name: "Search Employees"
        description: "As an HR Admin, I want to search for employees using various criteria so that I can quickly find specific records."
        priority: MUST
        type: Functional
        related_entities:
          - "[[Employee]]"
        sub_features:
          - "Search by name, ID, department"
          - "Filter by status, location"
          - "Advanced search with multiple criteria"
          - "Export search results"

      - id: FR-CO-005
        name: "Manage Employee Documents"
        description: "As an HR Admin, I want to manage employee documents so that all required documents are collected and tracked."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[Document]]"
          - "[[Person]]"
        sub_features:
          - "Upload documents"
          - "Track document expiry"
          - "Request missing documents"
          - "Document verification"

      - id: FR-CO-006
        name: "Transfer Employee"
        description: "As an HR Admin, I want to transfer an employee to a different position/department so that organizational changes are reflected."
        priority: SHOULD
        type: Workflow
        related_entities:
          - "[[Employee]]"
          - "[[Assignment]]"
          - "[[Position]]"
        sub_features:
          - "End current assignment"
          - "Create new assignment"
          - "Update reporting line"
          - "Handle compensation changes"
          - "Notify stakeholders"

      - id: FR-CO-007
        name: "Promote Employee"
        description: "As a Manager, I want to promote an employee to a higher position so that their career progression is recorded."
        priority: SHOULD
        type: Workflow
        related_entities:
          - "[[Employee]]"
          - "[[Assignment]]"
          - "[[Position]]"
          - "[[Contract]]"
        sub_features:
          - "Select new position"
          - "Update job level"
          - "Adjust compensation"
          - "Update assignment"
          - "Generate promotion letter"

      - id: FR-CO-008
        name: "Offboard Employee"
        description: "As an HR Admin, I want to offboard an employee so that their exit is processed properly and all assets are recovered."
        priority: MUST
        type: Workflow
        competitor_reference: "Workday: Terminate, SAP: Offboarding, Oracle: Termination"
        related_entities:
          - "[[Employee]]"
          - "[[Assignment]]"
          - "[[Contract]]"
        sub_features:
          - "Record resignation/termination"
          - "Set last working date"
          - "Trigger offboarding checklist"
          - "Calculate final settlement"
          - "Revoke system access"
          - "Conduct exit interview"
          - "Archive employee record"

  # ==========================================
  # ORGANIZATION MANAGEMENT
  # ==========================================
  - name: "Organization Management"
    description: "Manage organizational structure, departments, and hierarchies."
    features:
      - id: FR-CO-010
        name: "Manage Organization Structure"
        description: "As an HR Admin, I want to define and maintain the organization structure so that the hierarchy is accurately represented."
        priority: MUST
        type: Functional
        competitor_reference: "Workday: Organization, SAP: Org Structure"
        related_entities:
          - "[[Organization]]"
          - "[[Department]]"
        sub_features:
          - "Create legal entities"
          - "Create business units"
          - "Define hierarchy levels"
          - "Set parent-child relationships"

      - id: FR-CO-011
        name: "Manage Departments"
        description: "As an HR Admin, I want to create and manage departments so that employees can be properly organized."
        priority: MUST
        type: Functional
        related_entities:
          - "[[Department]]"
          - "[[Organization]]"
        sub_features:
          - "Create department"
          - "Assign department manager"
          - "Set cost center"
          - "Move department in hierarchy"
          - "Merge/split departments"

      - id: FR-CO-012
        name: "View Organization Chart"
        description: "As an Employee, I want to view the organization chart so that I can understand the reporting structure."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[Department]]"
          - "[[Position]]"
          - "[[Employee]]"
        sub_features:
          - "Interactive org chart"
          - "Search within org chart"
          - "Drill down by department"
          - "View position details"

      - id: FR-CO-013
        name: "Manage Locations"
        description: "As an HR Admin, I want to manage work locations so that employees can be assigned to the correct site."
        priority: MUST
        type: Functional
        related_entities:
          - "[[Location]]"
          - "[[Organization]]"

      - id: FR-CO-014
        name: "Manage Cost Centers"
        description: "As a Finance Admin, I want to manage cost centers so that labor costs can be tracked by organizational unit."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[CostCenter]]"
          - "[[Organization]]"

  # ==========================================
  # POSITION & JOB MANAGEMENT
  # ==========================================
  - name: "Position & Job Management"
    description: "Define jobs, create positions, and manage workforce structure."
    features:
      - id: FR-CO-020
        name: "Manage Job Catalog"
        description: "As an HR Admin, I want to manage the job catalog so that all role definitions are standardized."
        priority: MUST
        type: Functional
        related_entities:
          - "[[Job]]"
          - "[[JobFamily]]"
          - "[[JobProfile]]"
        sub_features:
          - "Create job definition"
          - "Define job family/level"
          - "Set job requirements"
          - "Link competencies"

      - id: FR-CO-021
        name: "Create Position"
        description: "As an HR Admin, I want to create a new position so that we can plan for headcount and hiring."
        priority: MUST
        type: Functional
        competitor_reference: "Workday: Create Position, SAP: Position Management"
        related_entities:
          - "[[Position]]"
          - "[[Job]]"
          - "[[Department]]"
        sub_features:
          - "Select job definition"
          - "Assign to department"
          - "Set location and cost center"
          - "Define reporting line"
          - "Set FTE allocation"

      - id: FR-CO-022
        name: "Manage Position"
        description: "As an HR Admin, I want to update position details so that organizational changes are reflected."
        priority: MUST
        type: Functional
        related_entities:
          - "[[Position]]"
        sub_features:
          - "Update position attributes"
          - "Change reporting line"
          - "Freeze/close position"
          - "View position history"

      - id: FR-CO-023
        name: "View Position Vacancies"
        description: "As a Manager, I want to view vacant positions so that I can plan for hiring."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[Position]]"
          - "[[Department]]"

      - id: FR-CO-024
        name: "Manage Job Profiles"
        description: "As an HR Admin, I want to define job profiles with required competencies so that we can match candidates to roles."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[JobProfile]]"
          - "[[Job]]"

  # ==========================================
  # ASSIGNMENT MANAGEMENT
  # ==========================================
  - name: "Assignment Management"
    description: "Manage employee-position assignments and work conditions."
    features:
      - id: FR-CO-030
        name: "Create Assignment"
        description: "As an HR Admin, I want to assign an employee to a position so that their placement is recorded."
        priority: MUST
        type: Functional
        related_entities:
          - "[[Assignment]]"
          - "[[Employee]]"
          - "[[Position]]"
        sub_features:
          - "Select employee and position"
          - "Set assignment type"
          - "Define work schedule"
          - "Set probation period"
          - "Set effective dates"

      - id: FR-CO-031
        name: "Manage Multiple Assignments"
        description: "As an HR Admin, I want to manage concurrent assignments so that employees can hold multiple roles."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[Assignment]]"
          - "[[Employee]]"
        sub_features:
          - "Add secondary assignment"
          - "Set FTE split"
          - "Define primary assignment"
          - "End assignment"

      - id: FR-CO-032
        name: "Manage Probation"
        description: "As a Manager, I want to manage employee probation so that performance is evaluated before confirmation."
        priority: MUST
        type: Workflow
        related_entities:
          - "[[Assignment]]"
          - "[[Employee]]"
        sub_features:
          - "Set probation end date"
          - "Track probation status"
          - "Conduct probation review"
          - "Confirm or extend probation"
          - "Terminate during probation"

      - id: FR-CO-033
        name: "Manage Work Schedule"
        description: "As an HR Admin, I want to manage work schedules so that working hours are properly defined."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[WorkSchedule]]"
          - "[[Assignment]]"

  # ==========================================
  # CONTRACT MANAGEMENT
  # ==========================================
  - name: "Contract Management"
    description: "Create, manage, and track employment contracts."
    features:
      - id: FR-CO-040
        name: "Generate Employment Contract"
        description: "As an HR Admin, I want to generate an employment contract from a template so that the hiring process is streamlined."
        priority: MUST
        type: Functional
        competitor_reference: "SAP: Contract Generation"
        related_entities:
          - "[[Contract]]"
          - "[[ContractTemplate]]"
          - "[[Employee]]"
        sub_features:
          - "Select contract template"
          - "Auto-fill employee data"
          - "Set contract terms"
          - "Generate PDF"
          - "Send for signature"

      - id: FR-CO-041
        name: "Manage Contract Templates"
        description: "As an HR Admin, I want to manage contract templates so that contracts are standardized."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[ContractTemplate]]"

      - id: FR-CO-042
        name: "Track Contract Expiry"
        description: "As an HR Admin, I want to be notified of expiring contracts so that renewals can be processed on time."
        priority: MUST
        type: Workflow
        related_entities:
          - "[[Contract]]"
        sub_features:
          - "Dashboard of expiring contracts"
          - "Automated notifications"
          - "Renewal workflow"

      - id: FR-CO-043
        name: "Amend Contract"
        description: "As an HR Admin, I want to amend an existing contract so that changes are documented."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[Contract]]"
          - "[[ContractAmendment]]"
        sub_features:
          - "Create amendment"
          - "Track amendment history"
          - "Generate amendment letter"

      - id: FR-CO-044
        name: "Renew Contract"
        description: "As an HR Admin, I want to renew an expiring contract so that employment continues."
        priority: MUST
        type: Workflow
        related_entities:
          - "[[Contract]]"
        sub_features:
          - "Initiate renewal"
          - "Update terms if needed"
          - "Generate new contract"
          - "Obtain signatures"
          - "Archive old contract"

  # ==========================================
  # COMPLIANCE & REPORTING
  # ==========================================
  - name: "Compliance & Reporting"
    description: "Ensure regulatory compliance and generate reports."
    features:
      - id: FR-CO-050
        name: "Manage Eligibility Rules"
        description: "As an HR Admin, I want to define eligibility rules so that benefits and policies are applied correctly."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[Employee]]"
          - "[[Assignment]]"
        sub_features:
          - "Define eligibility criteria"
          - "Automatic eligibility calculation"
          - "Track eligibility changes"

      - id: FR-CO-051
        name: "Data Privacy Management"
        description: "As an HR Admin, I want to manage data privacy settings so that PII is protected."
        priority: MUST
        type: Functional
        related_entities:
          - "[[Person]]"
          - "[[Employee]]"
        sub_features:
          - "Mark PII fields"
          - "Control data access"
          - "Handle data requests"
          - "Anonymize data"

      - id: FR-CO-052
        name: "View Audit Trail"
        description: "As an Auditor, I want to view audit trail so that I can track all changes to employee data."
        priority: MUST
        type: Functional
        related_entities:
          - "[[Employee]]"

      - id: FR-CO-053
        name: "Generate Headcount Report"
        description: "As a Manager, I want to generate headcount reports so that I can understand workforce distribution."
        priority: SHOULD
        type: Reporting
        related_entities:
          - "[[Employee]]"
          - "[[Department]]"
          - "[[Position]]"

      - id: FR-CO-054
        name: "Generate Employee Directory"
        description: "As an Employee, I want to access the employee directory so that I can find colleagues."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[Employee]]"
          - "[[Department]]"

# === BUSINESS RULES ===
business_rules:
  - id: BR-CO-001
    title: "Employee Code Uniqueness"
    description: "Employee code must be unique across the organization."
    category: Validation
    severity: BLOCK
    related_entities:
      - "[[Employee]]"

  - id: BR-CO-002
    title: "Hire Date Validation"
    description: "Hire date cannot be in the future beyond 60 days."
    category: Validation
    severity: BLOCK
    related_entities:
      - "[[Employee]]"

  - id: BR-CO-003
    title: "Position Budget Control"
    description: "New positions require budget approval if headcount exceeds department limit."
    category: Approval
    severity: WARN
    related_entities:
      - "[[Position]]"
      - "[[Department]]"

  - id: BR-CO-004
    title: "Probation Duration Limit"
    description: "Probation period cannot exceed legal maximum based on contract type (Vietnam: 180 days for executive, 60 days for professional, 6 days for others)."
    category: Compliance
    severity: BLOCK
    related_entities:
      - "[[Assignment]]"
      - "[[Contract]]"

  - id: BR-CO-005
    title: "Contract End Date"
    description: "Fixed-term contracts must have an end date. Indefinite contracts must not have an end date."
    category: Validation
    severity: BLOCK
    related_entities:
      - "[[Contract]]"

  - id: BR-CO-006
    title: "Single Primary Assignment"
    description: "An employee can have only one primary assignment at any given time."
    category: Validation
    severity: BLOCK
    related_entities:
      - "[[Assignment]]"
      - "[[Employee]]"

  - id: BR-CO-007
    title: "Manager Cannot Self-Approve"
    description: "Managers cannot approve their own employment changes."
    category: Approval
    severity: BLOCK
    related_entities:
      - "[[Employee]]"

  - id: BR-CO-008
    title: "Notice Period Enforcement"
    description: "Resignation must include notice period as per contract terms."
    category: Compliance
    severity: WARN
    related_entities:
      - "[[Contract]]"
      - "[[Employee]]"

  - id: BR-CO-009
    title: "PII Data Access"
    description: "PII fields can only be viewed/edited by authorized roles."
    category: Security
    severity: BLOCK
    related_entities:
      - "[[Person]]"

  - id: BR-CO-010
    title: "Effective Dating"
    description: "All changes to employee, assignment, and organization data must be effective-dated."
    category: Audit
    severity: BLOCK
    related_entities:
      - "[[Employee]]"
      - "[[Assignment]]"
      - "[[Department]]"
---

# Feature Catalog: Core HR

> **Note**: YAML above is for AI processing. Tables below for human reading.

## Feature Overview Mindmap

```mermaid
mindmap
  root((Core HR Features))
    Employee Management
      Onboard Employee
      View Profile
      Update Information
      Search Employees
      Manage Documents
      Transfer Employee
      Promote Employee
      Offboard Employee
    Organization
      Manage Structure
      Manage Departments
      View Org Chart
      Manage Locations
      Manage Cost Centers
    Position & Job
      Manage Job Catalog
      Create Position
      Manage Position
      View Vacancies
      Manage Job Profiles
    Assignment
      Create Assignment
      Multiple Assignments
      Manage Probation
      Work Schedule
    Contract
      Generate Contract
      Manage Templates
      Track Expiry
      Amend Contract
      Renew Contract
    Compliance
      Eligibility Rules
      Data Privacy
      Audit Trail
      Reports
```

---

## Capability: Employee Management

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-CO-001 | **Onboard New Employee** | As an HR Admin, I want to onboard a new employee... | MUST | Workflow |
| FR-CO-002 | **View Employee Profile** | As a Manager, I want to view an employee's complete profile... | MUST | Functional |
| FR-CO-003 | **Update Employee Information** | As an Employee, I want to update my personal information... | MUST | Functional |
| FR-CO-004 | **Search Employees** | As an HR Admin, I want to search for employees... | MUST | Functional |
| FR-CO-005 | **Manage Employee Documents** | As an HR Admin, I want to manage employee documents... | SHOULD | Functional |
| FR-CO-006 | **Transfer Employee** | As an HR Admin, I want to transfer an employee... | SHOULD | Workflow |
| FR-CO-007 | **Promote Employee** | As a Manager, I want to promote an employee... | SHOULD | Workflow |
| FR-CO-008 | **Offboard Employee** | As an HR Admin, I want to offboard an employee... | MUST | Workflow |

---

## Capability: Organization Management

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-CO-010 | **Manage Organization Structure** | As an HR Admin, I want to define org structure... | MUST | Functional |
| FR-CO-011 | **Manage Departments** | As an HR Admin, I want to manage departments... | MUST | Functional |
| FR-CO-012 | **View Organization Chart** | As an Employee, I want to view the org chart... | SHOULD | Functional |
| FR-CO-013 | **Manage Locations** | As an HR Admin, I want to manage work locations... | MUST | Functional |
| FR-CO-014 | **Manage Cost Centers** | As a Finance Admin, I want to manage cost centers... | SHOULD | Functional |

---

## Capability: Position & Job Management

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-CO-020 | **Manage Job Catalog** | As an HR Admin, I want to manage the job catalog... | MUST | Functional |
| FR-CO-021 | **Create Position** | As an HR Admin, I want to create a new position... | MUST | Functional |
| FR-CO-022 | **Manage Position** | As an HR Admin, I want to update position details... | MUST | Functional |
| FR-CO-023 | **View Position Vacancies** | As a Manager, I want to view vacant positions... | SHOULD | Functional |
| FR-CO-024 | **Manage Job Profiles** | As an HR Admin, I want to define job profiles... | SHOULD | Functional |

---

## Capability: Assignment Management

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-CO-030 | **Create Assignment** | As an HR Admin, I want to assign an employee to a position... | MUST | Functional |
| FR-CO-031 | **Manage Multiple Assignments** | As an HR Admin, I want to manage concurrent assignments... | SHOULD | Functional |
| FR-CO-032 | **Manage Probation** | As a Manager, I want to manage employee probation... | MUST | Workflow |
| FR-CO-033 | **Manage Work Schedule** | As an HR Admin, I want to manage work schedules... | SHOULD | Functional |

---

## Capability: Contract Management

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-CO-040 | **Generate Employment Contract** | As an HR Admin, I want to generate a contract from template... | MUST | Functional |
| FR-CO-041 | **Manage Contract Templates** | As an HR Admin, I want to manage contract templates... | SHOULD | Functional |
| FR-CO-042 | **Track Contract Expiry** | As an HR Admin, I want to be notified of expiring contracts... | MUST | Workflow |
| FR-CO-043 | **Amend Contract** | As an HR Admin, I want to amend an existing contract... | SHOULD | Functional |
| FR-CO-044 | **Renew Contract** | As an HR Admin, I want to renew an expiring contract... | MUST | Workflow |

---

## Capability: Compliance & Reporting

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-CO-050 | **Manage Eligibility Rules** | As an HR Admin, I want to define eligibility rules... | SHOULD | Functional |
| FR-CO-051 | **Data Privacy Management** | As an HR Admin, I want to manage data privacy... | MUST | Functional |
| FR-CO-052 | **View Audit Trail** | As an Auditor, I want to view audit trail... | MUST | Functional |
| FR-CO-053 | **Generate Headcount Report** | As a Manager, I want to generate headcount reports... | SHOULD | Reporting |
| FR-CO-054 | **Generate Employee Directory** | As an Employee, I want to access the directory... | SHOULD | Functional |

---

## Business Rules Summary

| ID | Rule | Category | Severity |
|----|------|----------|----------|
| BR-CO-001 | Employee code must be unique | Validation | BLOCK |
| BR-CO-002 | Hire date cannot be future beyond 60 days | Validation | BLOCK |
| BR-CO-003 | New positions require budget approval | Approval | WARN |
| BR-CO-004 | Probation period max per Vietnam law | Compliance | BLOCK |
| BR-CO-005 | Contract end date validation | Validation | BLOCK |
| BR-CO-006 | Only one primary assignment allowed | Validation | BLOCK |
| BR-CO-007 | Manager cannot self-approve | Approval | BLOCK |
| BR-CO-008 | Notice period enforcement | Compliance | WARN |
| BR-CO-009 | PII data access control | Security | BLOCK |
| BR-CO-010 | All changes must be effective-dated | Audit | BLOCK |

---

## Summary Statistics

| Category | Count |
|----------|-------|
| Capabilities | 6 |
| Features | 27 |
| Business Rules | 10 |
| Priority MUST | 17 |
| Priority SHOULD | 10 |

---

## Required Document Mapping

### Features → feat.md Files

| Feature | Axiom File | Priority |
|---------|-----------|----------|
| Onboard Employee (FR-CO-001) | `onboard-employee.feat.md` | MUST |
| Manage Employee (FR-CO-002,003,004,005) | `manage-employee.feat.md` | MUST |
| Transfer Employee (FR-CO-006) | `transfer-employee.feat.md` | SHOULD |
| Promote Employee (FR-CO-007) | `promote-employee.feat.md` | SHOULD |
| Offboard Employee (FR-CO-008) | `offboard-employee.feat.md` | MUST |
| Manage Organization (FR-CO-010,011,013,014) | `manage-organization.feat.md` | MUST |
| View Org Chart (FR-CO-012) | `view-org-chart.feat.md` | SHOULD |
| Manage Jobs & Positions (FR-CO-020-024) | `manage-position.feat.md` | MUST |
| Manage Assignment (FR-CO-030-033) | `manage-assignment.feat.md` | MUST |
| Manage Contract (FR-CO-040-044) | `manage-contract.feat.md` | MUST |
| Compliance & Reports (FR-CO-050-054) | `compliance-reports.feat.md` | SHOULD |

### Business Rules → brs.md Files

| Area | Axiom File | Priority |
|------|-----------|----------|
| Employee Lifecycle | `employee-lifecycle.brs.md` | MUST |
| Assignment Rules | `assignment-rules.brs.md` | MUST |
| Contract Rules | `contract-rules.brs.md` | MUST |
| Eligibility | `eligibility.brs.md` | SHOULD |
| Data Privacy | `data-privacy.brs.md` | MUST |

### Workflows → flow.md Files

| Workflow | Axiom File | Priority |
|----------|-----------|----------|
| Onboarding | `onboarding-flow.flow.md` | MUST |
| Transfer | `transfer-flow.flow.md` | SHOULD |
| Promotion | `promotion-flow.flow.md` | SHOULD |
| Offboarding | `offboarding-flow.flow.md` | MUST |
| Contract Renewal | `contract-renewal-flow.flow.md` | SHOULD |
| Probation Review | `probation-review-flow.flow.md` | MUST |
