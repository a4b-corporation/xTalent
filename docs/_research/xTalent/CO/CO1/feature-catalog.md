---
domain: Core HR
module: CO
version: "1.0.0"
status: DRAFT
created: "2026-01-23"

# === FEATURE DATA ===
capabilities:
  # ===========================================
  # 1. WORKER MANAGEMENT
  # ===========================================
  - name: "Worker Management"
    subdomain_type: CORE
    description: "Manage worker lifecycle from hire to termination, including all employment data and personal information."
    features:
      # --- Hiring ---
      - id: FR-CO-001
        name: "Hire New Employee"
        description: "As an HR Admin, I want to hire a new employee by creating Person, Worker, and Employment records so that the employee is officially onboarded."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Workflow
        complexity: MEDIUM
        risk: medium
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        decision_ref: null
        related_entities:
          - "[[Person]]"
          - "[[Worker]]"
          - "[[Employment]]"
          - "[[Position]]"
        business_rules:
          - "Person duplicate check by National ID or Email"
          - "Position must be in 'Open' or 'Vacant' status"
          - "Hire date cannot be in future beyond 90 days"
          - "Mandatory fields: Name, DOB, National ID, Hire Date"

      - id: FR-CO-002
        name: "Hire Contingent Worker"
        description: "As an HR Admin, I want to hire contingent workers (contractors, consultants) with limited data requirements so that external resources can be tracked."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Workflow
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle (3/4)"
        source_ref: "Market Leader"
        decision_ref: "ADR-CO-002"
        related_entities:
          - "[[Person]]"
          - "[[Worker]]"
        business_rules:
          - "Worker type must be 'Contractor' or 'Consultant'"
          - "Contract end date is mandatory"
          - "Reduced mandatory fields compared to Employee"

      - id: FR-CO-003
        name: "Rehire Former Employee"
        description: "As an HR Admin, I want to rehire a previously terminated employee by linking to existing Person record so that historical data is preserved."
        priority: SHOULD
        differentiation: PARITY
        stability: HIGH
        type: Workflow
        complexity: MEDIUM
        risk: low
        competitor_reference: "Workday, SAP, Oracle (3/4)"
        source_ref: "Market Leader"
        related_entities:
          - "[[Person]]"
          - "[[Worker]]"
        business_rules:
          - "Previous Worker record must be in 'Terminated' status"
          - "New Worker record created, linked to same Person"
          - "Clearance check from previous termination"

      # --- Employment Changes ---
      - id: FR-CO-010
        name: "Transfer Employee"
        description: "As an HR Admin, I want to transfer an employee to a different position/department so that organizational changes are reflected."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Workflow
        complexity: MEDIUM
        risk: medium
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[Employment]]"
          - "[[Position]]"
          - "[[Department]]"
        business_rules:
          - "Effective date required for all changes"
          - "Approval workflow for cross-department transfers"
          - "Previous employment record ended (effective dating)"
          - "New employment record created with new position"

      - id: FR-CO-011
        name: "Promote Employee"
        description: "As an HR Admin, I want to promote an employee to a higher-level position so that career progression is tracked."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Workflow
        complexity: MEDIUM
        risk: medium
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[Employment]]"
          - "[[Position]]"
          - "[[JobProfile]]"
        business_rules:
          - "New job level must be higher than current"
          - "Compensation change typically accompanies promotion"
          - "Approval workflow required"

      - id: FR-CO-012
        name: "Change Job/Position"
        description: "As an HR Admin, I want to change an employee's job without promotion (lateral move) so that role changes are captured."
        priority: SHOULD
        differentiation: PARITY
        stability: HIGH
        type: Workflow
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle (3/4)"
        source_ref: "Market Leader"
        related_entities:
          - "[[Employment]]"
          - "[[Position]]"
        business_rules:
          - "Effective dating for historical tracking"
          - "Manager approval may be required"

      - id: FR-CO-013
        name: "Change Employment Type"
        description: "As an HR Admin, I want to change employment type (full-time to part-time, etc.) so that work arrangement changes are reflected."
        priority: SHOULD
        differentiation: PARITY
        stability: HIGH
        type: Workflow
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP (2/4)"
        source_ref: "Market Leader"
        related_entities:
          - "[[Employment]]"
          - "[[EmploymentType]]"
        business_rules:
          - "May affect benefits eligibility"
          - "May affect leave accrual rates"

      # --- Termination ---
      - id: FR-CO-020
        name: "Terminate Employee"
        description: "As an HR Admin, I want to terminate an employee's employment so that offboarding is properly processed."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Workflow
        complexity: HIGH
        risk: high
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard, Labor Code 2019"
        decision_ref: null
        related_entities:
          - "[[Worker]]"
          - "[[Employment]]"
          - "[[TerminationReason]]"
        business_rules:
          - "Termination reason mandatory"
          - "Last working day required"
          - "Notice period validation (per Labor Code)"
          - "Triggers final pay calculation in Payroll"
          - "Triggers access revocation in IAM"
          - "Data retention rules apply (7 years per PDPL)"

      - id: FR-CO-021
        name: "Voluntary Resignation"
        description: "As an Employee, I want to submit my resignation through self-service so that the termination process begins."
        priority: SHOULD
        differentiation: INNOVATION
        stability: MEDIUM
        type: Workflow
        complexity: MEDIUM
        risk: low
        competitor_reference: "Workday, SAP (2/4)"
        source_ref: "Market Leader"
        related_entities:
          - "[[Worker]]"
          - "[[LeaveRequest]]"
        business_rules:
          - "Minimum notice period per contract/policy"
          - "Manager notification triggered"
          - "Exit interview scheduling"

  # ===========================================
  # 2. ORGANIZATION MANAGEMENT
  # ===========================================
  - name: "Organization Management"
    subdomain_type: CORE
    description: "Define and manage organizational structure including legal entities, business units, departments, and reporting hierarchies."
    features:
      - id: FR-CO-030
        name: "Maintain Legal Entities"
        description: "As a System Admin, I want to create and maintain legal entities so that employment contracts and payroll are correctly configured."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[LegalEntity]]"
        business_rules:
          - "Tax ID must be unique"
          - "Currency must be valid ISO code"
          - "Cannot delete if employees exist"

      - id: FR-CO-031
        name: "Maintain Business Units"
        description: "As an HR Admin, I want to create and manage business unit hierarchy so that organizational structure is accurate."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle (3/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[BusinessUnit]]"
          - "[[LegalEntity]]"
        business_rules:
          - "Must belong to a Legal Entity"
          - "Hierarchical structure allowed"

      - id: FR-CO-032
        name: "Maintain Departments"
        description: "As an HR Admin, I want to create and manage department hierarchy so that employees can be assigned to teams."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: MEDIUM
        risk: low
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[Department]]"
          - "[[Worker]]"
        business_rules:
          - "Department manager optional but recommended"
          - "Parent department creates hierarchy"
          - "Cost center assignment optional"

      - id: FR-CO-033
        name: "View Organization Chart"
        description: "As an Employee, I want to view the organizational chart so that I can understand reporting relationships."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: UI/UX
        complexity: MEDIUM
        risk: low
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[Department]]"
          - "[[Position]]"
          - "[[Worker]]"
        business_rules:
          - "Display active employees only"
          - "Show position hierarchy via Position.reportsTo"
          - "Clickable nodes to view employee profile"
          - "Search and filter capability"

      - id: FR-CO-034
        name: "Maintain Locations"
        description: "As an HR Admin, I want to create and manage work locations so that employees can be assigned to offices."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle (3/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[Location]]"
        business_rules:
          - "Address fields required"
          - "Timezone for scheduling"
          - "Associated holiday calendar"

      - id: FR-CO-035
        name: "Maintain Cost Centers"
        description: "As a Finance Admin, I want to create and manage cost centers so that labor costs are properly allocated."
        priority: SHOULD
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle (3/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[CostCenter]]"
        business_rules:
          - "Unique cost center code per Legal Entity"
          - "Integration with Finance module"

  # ===========================================
  # 3. POSITION & JOB MANAGEMENT
  # ===========================================
  - name: "Position & Job Management"
    subdomain_type: CORE
    description: "Manage job profiles, positions, and staffing models for headcount control and organizational planning."
    features:
      - id: FR-CO-040
        name: "Maintain Job Profiles"
        description: "As an HR Admin, I want to create and manage job profiles so that positions can be templated with standard attributes."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[JobProfile]]"
          - "[[JobFamily]]"
        business_rules:
          - "Job title required"
          - "Can belong to Job Family for grouping"
          - "Grade/Level optional"

      - id: FR-CO-041
        name: "Maintain Job Families"
        description: "As an HR Admin, I want to group related jobs into families so that career paths can be defined."
        priority: SHOULD
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle (3/4)"
        source_ref: "Market Leader"
        related_entities:
          - "[[JobFamily]]"
        business_rules:
          - "Used for compensation benchmarking"
          - "Used for career progression planning"

      - id: FR-CO-042
        name: "Create/Manage Positions"
        description: "As an HR Admin, I want to create positions based on job profiles so that headcount can be controlled."
        priority: MUST
        differentiation: PARITY
        stability: MEDIUM
        type: Functional
        complexity: MEDIUM
        risk: medium
        competitor_reference: "Workday, SAP, Oracle (3/4)"
        source_ref: "Market Leader"
        decision_ref: "ADR-CO-001"
        related_entities:
          - "[[Position]]"
          - "[[JobProfile]]"
          - "[[Department]]"
        business_rules:
          - "Position inherits defaults from Job Profile"
          - "Department and Location required"
          - "Reports To position required (except top)"
          - "Cost Center for budgeting"

      - id: FR-CO-043
        name: "View Position Hierarchy"
        description: "As an HR Manager, I want to see position-based reporting structure so that I understand the org design."
        priority: SHOULD
        differentiation: PARITY
        stability: HIGH
        type: UI/UX
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP (2/4)"
        source_ref: "Market Leader"
        related_entities:
          - "[[Position]]"
        business_rules:
          - "Show filled vs open positions"
          - "Color coding by status"

      - id: FR-CO-044
        name: "Track Headcount"
        description: "As an HR Executive, I want to see headcount by department/location/cost center so that workforce planning is informed."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Calculation
        complexity: MEDIUM
        risk: low
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[Position]]"
          - "[[Worker]]"
          - "[[Employment]]"
        business_rules:
          - "Count active workers only"
          - "FTE calculation for part-time"
          - "Point-in-time and trend views"

  # ===========================================
  # 4. LEAVE MANAGEMENT (Foundation)
  # ===========================================
  - name: "Leave Management"
    subdomain_type: CORE
    description: "Core leave request and balance management. Advanced time tracking belongs to Time & Attendance module."
    features:
      - id: FR-CO-050
        name: "Configure Leave Types"
        description: "As an HR Admin, I want to configure leave types (Annual, Sick, Maternity, etc.) so that policies are defined."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard, Labor Code 2019"
        related_entities:
          - "[[LeaveType]]"
        business_rules:
          - "Paid vs Unpaid indicator"
          - "Max days per year"
          - "Accrual rules optional (for Core HR, detailed in Time module)"
          - "Per Legal Entity configuration"

      - id: FR-CO-051
        name: "View Leave Balances"
        description: "As an Employee, I want to view my current leave balances so that I can plan my time off."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: UI/UX
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[LeaveBalance]]"
          - "[[Worker]]"
        business_rules:
          - "Show accrued, used, available"
          - "By leave type"
          - "Mobile accessible"

      - id: FR-CO-052
        name: "Submit Leave Request"
        description: "As an Employee, I want to submit a leave request so that I can take time off."
        priority: MUST
        differentiation: PARITY
        stability: MEDIUM
        type: Workflow
        complexity: MEDIUM
        risk: low
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[LeaveRequest]]"
          - "[[LeaveType]]"
          - "[[LeaveBalance]]"
        business_rules:
          - "Check available balance before submit"
          - "Date range validation"
          - "Conflict detection (existing requests)"
          - "Auto-route to manager for approval"
          - "Notification to manager"

      - id: FR-CO-053
        name: "Approve/Reject Leave Request"
        description: "As a Manager, I want to approve or reject leave requests from my team so that absences are authorized."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Workflow
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[LeaveRequest]]"
        business_rules:
          - "Only manager of worker can approve"
          - "Optional: HR override capability"
          - "Comments on rejection"
          - "Notification to requester"

      - id: FR-CO-054
        name: "Cancel Leave Request"
        description: "As an Employee, I want to cancel a pending or approved leave request so that plans can change."
        priority: SHOULD
        differentiation: PARITY
        stability: HIGH
        type: Workflow
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP (2/4)"
        source_ref: "Market Leader"
        related_entities:
          - "[[LeaveRequest]]"
        business_rules:
          - "Cannot cancel if leave already started"
          - "Manager notification on cancel"
          - "Balance restoration"

      - id: FR-CO-055
        name: "View Team Calendar"
        description: "As a Manager, I want to see my team's leave calendar so that I can plan coverage."
        priority: SHOULD
        differentiation: PARITY
        stability: HIGH
        type: UI/UX
        complexity: MEDIUM
        risk: low
        competitor_reference: "Workday, SAP, Oracle (3/4)"
        source_ref: "Market Leader"
        related_entities:
          - "[[LeaveRequest]]"
          - "[[Worker]]"
        business_rules:
          - "Show approved absences"
          - "Show pending requests differently"
          - "Holiday calendar overlay"

      - id: FR-CO-056
        name: "Configure Holiday Calendar"
        description: "As an HR Admin, I want to configure holiday calendars so that public holidays are tracked."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle (3/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[HolidayCalendar]]"
        business_rules:
          - "Per location or legal entity"
          - "Recurring and one-time holidays"
          - "Integration with leave balance calculation"

  # ===========================================
  # 5. EMPLOYEE SELF-SERVICE
  # ===========================================
  - name: "Employee Self-Service"
    subdomain_type: CORE
    description: "Empower employees to view and update their own information, reducing HR administrative burden."
    features:
      - id: FR-CO-060
        name: "View Personal Profile"
        description: "As an Employee, I want to view my complete profile so that I can verify my information is correct."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: UI/UX
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[Person]]"
          - "[[Worker]]"
          - "[[Employment]]"
        business_rules:
          - "Display current employment details"
          - "Display position and manager"
          - "Mobile accessible"

      - id: FR-CO-061
        name: "Update Personal Information"
        description: "As an Employee, I want to update my personal information (phone, email, address) so that records are current."
        priority: MUST
        differentiation: PARITY
        stability: MEDIUM
        type: Workflow
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[Person]]"
          - "[[PersonAddress]]"
        business_rules:
          - "Some fields require approval (e.g., name change)"
          - "Address changes may require documentation"
          - "Audit trail for all changes"

      - id: FR-CO-062
        name: "Manage Emergency Contacts"
        description: "As an Employee, I want to add/update emergency contacts so that they can be reached if needed."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[EmergencyContact]]"
        business_rules:
          - "At least one emergency contact recommended"
          - "Priority order for multiple contacts"

      - id: FR-CO-063
        name: "Manage Dependents"
        description: "As an Employee, I want to add/update dependents information so that benefits enrollment is accurate."
        priority: SHOULD
        differentiation: PARITY
        stability: MEDIUM
        type: Workflow
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle (3/4)"
        source_ref: "Market Leader"
        related_entities:
          - "[[Dependent]]"
        business_rules:
          - "Documentation may be required for verification"
          - "Triggers benefits eligibility recalculation"
          - "Approval workflow for dependent changes"

      - id: FR-CO-064
        name: "Manage Bank Account"
        description: "As an Employee, I want to update my bank account details so that salary is deposited correctly."
        priority: MUST
        differentiation: PARITY
        stability: MEDIUM
        type: Workflow
        complexity: LOW
        risk: high
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[BankAccount]]"
        business_rules:
          - "Requires verification/approval"
          - "Security controls (OTP, confirmation)"
          - "Audit trail mandatory"
          - "Previous accounts retained for audit"

      - id: FR-CO-065
        name: "Upload Documents"
        description: "As an Employee, I want to upload required documents so that my file is complete."
        priority: SHOULD
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle (3/4)"
        source_ref: "Market Leader"
        related_entities:
          - "[[WorkerDocument]]"
        business_rules:
          - "File type restrictions (PDF, JPG)"
          - "File size limits"
          - "Expiry date tracking for IDs"

  # ===========================================
  # 6. MANAGER SELF-SERVICE
  # ===========================================
  - name: "Manager Self-Service"
    subdomain_type: CORE
    description: "Empower managers to manage their team and initiate HR processes."
    features:
      - id: FR-CO-070
        name: "View Team Members"
        description: "As a Manager, I want to view all my direct reports so that I can manage my team."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: UI/UX
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[Worker]]"
          - "[[Position]]"
        business_rules:
          - "Show direct and indirect reports"
          - "Filter by status"
          - "Quick actions (approve leave, etc.)"

      - id: FR-CO-071
        name: "Initiate Employee Changes"
        description: "As a Manager, I want to initiate transfers, promotions, or job changes for my team so that changes are processed."
        priority: SHOULD
        differentiation: PARITY
        stability: MEDIUM
        type: Workflow
        complexity: MEDIUM
        risk: medium
        competitor_reference: "Workday, SAP (2/4)"
        source_ref: "Market Leader"
        related_entities:
          - "[[Employment]]"
          - "[[Position]]"
        business_rules:
          - "HR approval required"
          - "Compensation review may be triggered"
          - "Effective date in future allowed"

      - id: FR-CO-072
        name: "View Team Calendar"
        description: "As a Manager, I want to see team availability including leaves and holidays."
        priority: SHOULD
        differentiation: PARITY
        stability: HIGH
        type: UI/UX
        complexity: MEDIUM
        risk: low
        competitor_reference: "Workday, SAP, Microsoft (3/4)"
        source_ref: "Market Leader"
        related_entities:
          - "[[LeaveRequest]]"
          - "[[HolidayCalendar]]"
        business_rules:
          - "Aggregate view of all direct reports"
          - "Holiday calendar overlay"

  # ===========================================
  # 7. DOCUMENT MANAGEMENT
  # ===========================================
  - name: "Document Management"
    subdomain_type: SUPPORTING
    description: "Manage employee documents including contracts, IDs, and certificates."
    features:
      - id: FR-CO-080
        name: "Store Employee Documents"
        description: "As an HR Admin, I want to upload and categorize employee documents so that files are centralized."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle (3/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[WorkerDocument]]"
          - "[[DocumentType]]"
        business_rules:
          - "Document type classification"
          - "Secure storage with encryption"
          - "Access control by role"

      - id: FR-CO-081
        name: "Track Document Expiry"
        description: "As an HR Admin, I want to track document expiration dates so that renewals are timely."
        priority: SHOULD
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: LOW
        risk: low
        competitor_reference: "SAP, Oracle (2/4)"
        source_ref: "Market Leader"
        related_entities:
          - "[[WorkerDocument]]"
        business_rules:
          - "Alert before expiry (configurable days)"
          - "Dashboard for expiring documents"
          - "Notification to employee and HR"

      - id: FR-CO-082
        name: "Generate Employment Letter"
        description: "As an HR Admin, I want to generate employment confirmation letters so that employee requests are fulfilled."
        priority: SHOULD
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: MEDIUM
        risk: low
        competitor_reference: "SAP, Oracle (2/4)"
        source_ref: "Market Leader"
        related_entities:
          - "[[Worker]]"
          - "[[Employment]]"
        business_rules:
          - "Template-based generation"
          - "Auto-fill employee data"
          - "Digital signature optional"

  # ===========================================
  # 8. COMPLIANCE & AUDIT
  # ===========================================
  - name: "Compliance & Audit"
    subdomain_type: CORE
    description: "Ensure data privacy compliance, consent management, and audit trail for regulatory requirements."
    features:
      - id: FR-CO-090
        name: "Manage Data Consent"
        description: "As an HR Admin, I want to track employee consent for data processing so that PDPL/GDPR compliance is maintained."
        priority: MUST
        differentiation: COMPLIANCE
        stability: LOW
        type: Workflow
        complexity: HIGH
        risk: high
        competitor_reference: "Workday, SAP (2/4)"
        source_ref: "Vietnam PDPL (Law 91/2025), GDPR"
        decision_ref: "ADR-CO-005"
        related_entities:
          - "[[DataConsent]]"
          - "[[Worker]]"
        business_rules:
          - "Consent required for sensitive data processing"
          - "Version-controlled consent forms"
          - "Consent withdrawal supported"
          - "Expiry and renewal tracking"
          - "Audit trail of all consent actions"

      - id: FR-CO-091
        name: "Classify PII Data"
        description: "As a System Admin, I want fields classified by PII sensitivity so that access control is appropriate."
        priority: MUST
        differentiation: COMPLIANCE
        stability: HIGH
        type: Functional
        complexity: MEDIUM
        risk: high
        competitor_reference: "Workday, SAP (2/4)"
        source_ref: "Vietnam PDPL, GDPR"
        related_entities:
          - "[[Person]]"
          - "[[BankAccount]]"
        business_rules:
          - "Field-level sensitivity classification"
          - "HIGH PII: National ID, Bank Account, Health data"
          - "MEDIUM PII: Phone, Email, Address"
          - "Different access rules per sensitivity"

      - id: FR-CO-092
        name: "Audit Trail for Sensitive Data"
        description: "As a Compliance Officer, I want all changes to sensitive data logged so that audits can be performed."
        priority: MUST
        differentiation: COMPLIANCE
        stability: LOW
        type: Functional
        complexity: MEDIUM
        risk: high
        competitor_reference: "Workday, SAP, Oracle (3/4)"
        source_ref: "Vietnam PDPL, GDPR, SOX"
        related_entities:
          - "[[AuditLog]]"
        business_rules:
          - "Log all CRUD operations on PII fields"
          - "Store who, what, when, before/after values"
          - "Immutable audit log"
          - "Retention per regulatory requirement (7 years)"

      - id: FR-CO-093
        name: "Data Retention Management"
        description: "As an HR Admin, I want terminated employee data archived per retention rules so that compliance is maintained."
        priority: SHOULD
        differentiation: COMPLIANCE
        stability: HIGH
        type: Functional
        complexity: HIGH
        risk: high
        competitor_reference: "Workday, SAP (2/4)"
        source_ref: "Vietnam PDPL, Labor Code"
        related_entities:
          - "[[Worker]]"
          - "[[WorkerDocument]]"
        business_rules:
          - "7-year retention for employment records"
          - "Anonymization after retention period"
          - "Right to erasure with legal exceptions"

      - id: FR-CO-094
        name: "Access Request Logging"
        description: "As a Compliance Officer, I want all access to sensitive data logged so that data breaches can be investigated."
        priority: SHOULD
        differentiation: COMPLIANCE
        stability: LOW
        type: Functional
        complexity: MEDIUM
        risk: medium
        competitor_reference: "SAP, Oracle (2/4)"
        source_ref: "ISO 27001, PDPL"
        related_entities:
          - "[[AuditLog]]"
        business_rules:
          - "Log read access to HIGH PII fields"
          - "Anomaly detection for unusual access patterns"

  # ===========================================
  # 9. REPORTING & ANALYTICS
  # ===========================================
  - name: "Reporting & Analytics"
    subdomain_type: SUPPORTING
    description: "Standard HR reports and dashboards. Advanced analytics belong to separate module."
    features:
      - id: FR-CO-100
        name: "Headcount Report"
        description: "As an HR Executive, I want to run headcount reports by various dimensions so that workforce metrics are available."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Calculation
        complexity: MEDIUM
        risk: low
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[Worker]]"
          - "[[Employment]]"
          - "[[Department]]"
        business_rules:
          - "Slice by: Department, Location, Cost Center, Employment Type"
          - "Point-in-time and trend analysis"
          - "FTE and headcount views"

      - id: FR-CO-101
        name: "New Hires Report"
        description: "As an HR Manager, I want to see new hires over a period so that onboarding is tracked."
        priority: SHOULD
        differentiation: PARITY
        stability: HIGH
        type: Calculation
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle (3/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[Worker]]"
        business_rules:
          - "Filter by date range, department, location"
          - "Show new hire details"

      - id: FR-CO-102
        name: "Terminations Report"
        description: "As an HR Manager, I want to see terminations and reasons so that turnover is analyzed."
        priority: SHOULD
        differentiation: PARITY
        stability: HIGH
        type: Calculation
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle (3/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[Worker]]"
          - "[[TerminationReason]]"
        business_rules:
          - "Filter by date range, department, reason"
          - "Voluntary vs Involuntary breakdown"

      - id: FR-CO-103
        name: "Employee Directory/Search"
        description: "As an Employee, I want to search the employee directory so that I can find colleagues."
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: UI/UX
        complexity: LOW
        risk: low
        competitor_reference: "Workday, SAP, Oracle, Microsoft (4/4)"
        source_ref: "Industry Standard"
        related_entities:
          - "[[Worker]]"
          - "[[Person]]"
        business_rules:
          - "Search by name, department, location, job title"
          - "Display public profile information"
          - "Click to view org chart position"
          - "Contact information based on permissions"
---

# Feature Catalog: Core HR

> **Note**: YAML above is for AI processing. Tables below for human reading.

---

## Feature Mindmap

```mermaid
mindmap
  root((Core HR Features))
    Worker Management [CORE]
      Hire Employee [MUST]
      Hire Contingent [MUST]
      Rehire [SHOULD]
      Transfer [MUST]
      Promote [MUST]
      Terminate [MUST]
    Organization [CORE]
      Legal Entity [MUST]
      Business Unit [MUST]
      Department [MUST]
      Location [MUST]
      Org Chart [MUST]
    Position & Job [CORE]
      Job Profile [MUST]
      Job Family [SHOULD]
      Position [MUST]
      Headcount [MUST]
    Leave [CORE]
      Leave Types [MUST]
      Balances [MUST]
      Request [MUST]
      Approval [MUST]
      Calendar [SHOULD]
    Employee Self-Service [CORE]
      View Profile [MUST]
      Update Info [MUST]
      Emergency Contact [MUST]
      Dependents [SHOULD]
      Bank Account [MUST]
    Manager Self-Service [CORE]
      View Team [MUST]
      Initiate Changes [SHOULD]
    Documents [SUPPORTING]
      Store Docs [MUST]
      Track Expiry [SHOULD]
    Compliance [CORE]
      Data Consent [MUST]
      PII Classification [MUST]
      Audit Trail [MUST]
      Retention [SHOULD]
    Reporting [SUPPORTING]
      Headcount [MUST]
      Hires [SHOULD]
      Terminations [SHOULD]
      Directory [MUST]
```

---

## Summary Statistics

| Metric | Count |
|--------|-------|
| **Total Features** | 47 |
| **MUST Priority** | 32 (68%) |
| **SHOULD Priority** | 15 (32%) |
| **Parity (Table Stakes)** | 42 (89%) |
| **Innovation (USP)** | 1 (2%) |
| **Compliance (Mandatory)** | 6 (13%) |

---

## Priority Distribution by Capability

| Capability | MUST | SHOULD | Total |
|------------|------|--------|-------|
| Worker Management | 5 | 3 | 8 |
| Organization Management | 5 | 1 | 6 |
| Position & Job Management | 3 | 2 | 5 |
| Leave Management | 4 | 3 | 7 |
| Employee Self-Service | 4 | 2 | 6 |
| Manager Self-Service | 1 | 2 | 3 |
| Document Management | 1 | 2 | 3 |
| Compliance & Audit | 2 | 3 | 5 |
| Reporting & Analytics | 2 | 2 | 4 |
| **TOTAL** | **27** | **20** | **47** |

---

## Differentiation Analysis

### Parity Features (Table Stakes)

All competitors have these - must match industry standard:

| ID | Feature | Competitors |
|----|---------|-------------|
| FR-CO-001 | Hire New Employee | 4/4 |
| FR-CO-010 | Transfer Employee | 4/4 |
| FR-CO-020 | Terminate Employee | 4/4 |
| FR-CO-033 | View Org Chart | 4/4 |
| FR-CO-052 | Submit Leave Request | 4/4 |
| FR-CO-060 | View Personal Profile | 4/4 |
| FR-CO-103 | Employee Directory | 4/4 |

**Strategy:** Match industry standard, don't over-invest.

### Innovation Features (USP)

Opportunity to differentiate:

| ID | Feature | Advantage |
|----|---------|-----------|
| FR-CO-021 | Voluntary Resignation Self-Service | Better employee experience, reduce HR workload |

**Strategy:** Invest to differentiate, improve UX.

### Compliance Features (Mandatory)

Legal/regulatory requirements:

| ID | Feature | Legal Source | Risk |
|----|---------|--------------|------|
| FR-CO-090 | Manage Data Consent | PDPL (Law 91/2025) | HIGH - Fines, lawsuits |
| FR-CO-091 | Classify PII Data | PDPL, GDPR | HIGH |
| FR-CO-092 | Audit Trail | PDPL, GDPR, SOX | HIGH |
| FR-CO-093 | Data Retention | PDPL, Labor Code | HIGH |
| FR-CO-094 | Access Request Logging | ISO 27001, PDPL | MEDIUM |

**Strategy:** Must-have, no shortcuts. Jan 2026 PDPL deadline.

---

## Complexity Distribution

| Complexity | Count | Features |
|------------|-------|----------|
| **HIGH** | 4 | Terminate Employee, Data Consent, Data Retention, Access Logging |
| **MEDIUM** | 16 | Hire, Transfer, Promote, Position Management, Headcount, Leave Request, etc. |
| **LOW** | 27 | Most CRUD and view features |

---

## Risk Analysis

| Risk Level | Count | Key Features |
|------------|-------|--------------|
| **HIGH** | 5 | Termination, Bank Account, Data Consent, PII Classification, Audit Trail |
| **MEDIUM** | 8 | Transfer, Promote, Position, Initiate Changes |
| **LOW** | 34 | Most features |

---

## ADR Cross-Reference

| Feature | Decision | Rationale |
|---------|----------|-----------|
| FR-CO-002 | ADR-CO-002 | Single Worker entity with type discriminator |
| FR-CO-042 | ADR-CO-001 | Position-based staffing model |
| FR-CO-090 | ADR-CO-005 | Consent management for PDPL compliance |
