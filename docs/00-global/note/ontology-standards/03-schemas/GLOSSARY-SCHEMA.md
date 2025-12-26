# Glossary Schema Specification

**Version**: 3.0  
**Format**: YAML  
**Audience**: Everyone (especially BAs, Domain Experts)

---

## 🎯 Purpose

The glossary defines the **Ubiquitous Language** — the shared vocabulary that:

1. **Eliminates ambiguity** across teams
2. **Bridges technical and business** understanding
3. **Provides definitions** for AI agents
4. **Documents domain knowledge**

---

## 📋 Glossary File Schema

```yaml
# ============================================================================
# GLOSSARY SCHEMA v3.0
# ============================================================================
# File: 00-ontology/glossary/workforce.glossary.yaml

$schema: "https://xtalent.io/schemas/glossary/v3"
$id: "xtalent:core-hr:glossary:workforce"

module: CORE-HR
submodule: workforce
version: "1.0"

# Domain context
domain: "Human Resource Management"
subdomain: "Workforce Administration"

description: |
  Terminology related to workforce management including employees,
  positions, assignments, and organizational relationships.

# ============================================================================
# TERMS
# ============================================================================
terms:

  # ---------------------------------------------------------------------------
  # ENTITY TERMS
  # ---------------------------------------------------------------------------
  
  employee:
    term: "Employee"
    type: ENTITY
    definition: |
      A person who is employed by the organization under a formal 
      employment contract. This includes full-time, part-time, and 
      contract workers on payroll.
    
    aliases:
      - "Worker"
      - "Staff Member"
      - "Team Member"
    
    # What it is NOT (to avoid confusion)
    not_to_be_confused_with:
      - term: "Contractor"
        reason: "Contractors are external resources, not on payroll"
      - term: "Candidate"
        reason: "Candidates become Employees only after hiring completes"
    
    # Business context
    context: |
      In xTalent, Employee is the central entity in the Core HR module.
      All workforce-related transactions (assignments, leave, payroll)
      link back to the Employee record.
    
    # Link to formal definition
    entity_ref: "xtalent:core-hr:workforce:employee"
    
    # Related terms
    related_terms:
      - hire_date
      - employment_status
      - assignment
      - position
    
    # Examples
    examples:
      - "John Doe, a full-time Software Engineer"
      - "Jane Smith, a part-time HR Assistant"
    
    # Translations (for international teams)
    translations:
      vi: "Nhân viên"
      ja: "従業員"

  # ---------------------------------------------------------------------------
  
  assignment:
    term: "Assignment"
    type: ENTITY
    definition: |
      A formal placement of an employee in a specific position within 
      a department for a defined period. An employee may have multiple 
      concurrent assignments (e.g., primary role + project role).
    
    aliases:
      - "Job Assignment"
      - "Position Assignment"
      - "Role Assignment"
    
    not_to_be_confused_with:
      - term: "Position"
        reason: "Position is the job slot; Assignment is the employee filling it"
      - term: "Employment"
        reason: "Employment is the overall relationship; Assignment is specific placement"
    
    context: |
      Assignments enable:
      - Multiple roles for one employee (concurrent assignments)
      - Historical tracking (SCD Type 2)
      - Cost allocation to departments/projects
    
    entity_ref: "xtalent:core-hr:workforce:assignment"
    
    related_terms:
      - employee
      - position
      - assignment_status

  # ---------------------------------------------------------------------------
  
  position:
    term: "Position"
    type: ENTITY
    definition: |
      A specific job slot within the organization structure. A position 
      defines the role, responsibilities, and reporting relationships 
      independent of who fills it.
    
    aliases:
      - "Job Position"
      - "Role"
      - "Slot"
    
    context: |
      Positions exist even when vacant. When an employee is assigned 
      to a position, an Assignment record is created.
    
    entity_ref: "xtalent:core-hr:org-structure:position"
    
    related_terms:
      - job_family
      - department
      - assignment

  # ---------------------------------------------------------------------------
  # ATTRIBUTE TERMS
  # ---------------------------------------------------------------------------
  
  hire_date:
    term: "Hire Date"
    type: ATTRIBUTE
    definition: |
      The official date when an employee's employment begins. This is 
      the date used for calculating years of service, benefits eligibility,
      and other tenure-based calculations.
    
    aliases:
      - "Start Date"
      - "Employment Start Date"
      - "Date of Hire"
    
    not_to_be_confused_with:
      - term: "Offer Date"
        reason: "Offer Date is when job offer was extended"
      - term: "First Day"
        reason: "First Day may differ if employee starts mid-week"
    
    data_type: "date"
    format: "YYYY-MM-DD"
    
    validation_rules:
      - "Cannot be in the future"
      - "Cannot be before company founding date"
    
    belongs_to: "xtalent:core-hr:workforce:employee"
    
    translations:
      vi: "Ngày vào làm"

  # ---------------------------------------------------------------------------
  
  employment_status:
    term: "Employment Status"
    type: ATTRIBUTE
    definition: |
      The current state of an employee's employment relationship 
      with the organization.
    
    values:
      - value: "DRAFT"
        definition: "Employee record created but not yet activated"
      - value: "ACTIVE"
        definition: "Currently employed and working"
      - value: "INACTIVE"
        definition: "Temporarily not working (leave, suspension)"
      - value: "TERMINATED"
        definition: "Employment relationship has ended"
    
    belongs_to: "xtalent:core-hr:workforce:employee"
    
    related_terms:
      - termination_reason
      - rehire_eligibility

  # ---------------------------------------------------------------------------
  # WORKFLOW TERMS
  # ---------------------------------------------------------------------------
  
  onboarding:
    term: "Onboarding"
    type: WORKFLOW
    definition: |
      The comprehensive process of integrating a new employee into 
      the organization, from offer acceptance through completion of 
      initial orientation and training.
    
    aliases:
      - "New Hire Onboarding"
      - "Employee Orientation"
    
    includes:
      - "Creating employee record"
      - "System account provisioning"
      - "Equipment assignment"
      - "Orientation scheduling"
      - "Benefits enrollment"
    
    workflow_ref: "xtalent:core-hr:workforce:WF-001-employee-onboarding"
    
    typical_duration: "5-10 business days"

  # ---------------------------------------------------------------------------
  
  termination:
    term: "Termination"
    type: WORKFLOW
    definition: |
      The process of ending an employment relationship, whether 
      voluntary (resignation) or involuntary (dismissal).
    
    includes:
      - "Exit interview"
      - "Final settlement"
      - "Asset recovery"
      - "System access revocation"
      - "Benefits termination"
    
    workflow_ref: "xtalent:core-hr:workforce:WF-002-employee-offboarding"
    
    related_terms:
      - termination_reason
      - final_pay_date
      - rehire_eligibility

  # ---------------------------------------------------------------------------
  # BUSINESS CONCEPT TERMS
  # ---------------------------------------------------------------------------
  
  years_of_service:
    term: "Years of Service"
    type: DERIVED
    definition: |
      The number of complete years an employee has been employed, 
      calculated from hire_date to current date (or termination date).
    
    formula: "YEAR(today) - YEAR(hire_date)"
    
    usage:
      - "Benefit eligibility calculations"
      - "Leave accrual rates"
      - "Promotion eligibility"
      - "Recognition programs"
    
    belongs_to: "xtalent:core-hr:workforce:employee"

  # ---------------------------------------------------------------------------
  
  direct_report:
    term: "Direct Report"
    type: RELATIONSHIP
    definition: |
      An employee who reports directly to a manager in the 
      organizational hierarchy.
    
    inverse: "manager"
    
    context: |
      The direct reporting relationship is captured through the 
      manager_id field on the Employee entity. An employee has 
      zero or one manager, and a manager can have zero or more 
      direct reports.

  # ---------------------------------------------------------------------------
  # BUSINESS RULE TERMS
  # ---------------------------------------------------------------------------
  
  rehire_eligibility:
    term: "Rehire Eligibility"
    type: RULE_CONCEPT
    definition: |
      An indicator of whether a terminated employee may be 
      considered for future employment.
    
    values:
      - value: true
        meaning: "Eligible for rehire - left in good standing"
      - value: false
        meaning: "Not eligible - policy violation or performance issues"
    
    determined_by:
      - "Termination reason"
      - "Performance history"
      - "Policy compliance"
    
    business_rule_ref: "xtalent:core-hr:workforce:BR-010"

# ============================================================================
# TERM CATEGORIES
# ============================================================================
categories:
  entities:
    description: "Core domain entities"
    terms: [employee, assignment, position, department]
    
  attributes:
    description: "Entity attributes and their meanings"
    terms: [hire_date, employment_status, termination_date]
    
  workflows:
    description: "Business processes"
    terms: [onboarding, termination, transfer, promotion]
    
  derived:
    description: "Calculated/computed values"
    terms: [years_of_service, is_manager, headcount]
    
  rules:
    description: "Business rule concepts"
    terms: [rehire_eligibility, probation_period]

# ============================================================================
# CROSS-MODULE REFERENCES
# ============================================================================
imports_from:
  - module: ORG-STRUCTURE
    terms: [department, cost_center, location]
  - module: PAYROLL
    terms: [pay_frequency, pay_element]

exports_to:
  - module: PAYROLL
    terms: [employee, assignment]
  - module: TIME-ATTENDANCE
    terms: [employee]
  - module: BENEFITS
    terms: [employee, hire_date]

# ============================================================================
# METADATA
# ============================================================================
metadata:
  domain_expert: "HR Business Analyst"
  last_reviewed: "2024-12-24"
  review_status: "APPROVED"
  
  # Version history
  history:
    - version: "1.0"
      date: "2024-12-24"
      changes: "Initial glossary creation"
```

---

## 🏷️ Term Types

| Type | Description | Example |
|------|-------------|---------|
| `ENTITY` | Domain entity/object | Employee, Assignment |
| `ATTRIBUTE` | Entity property | hire_date, status |
| `WORKFLOW` | Business process | Onboarding, Termination |
| `ACTION` | Atomic operation | Terminate, Promote |
| `DERIVED` | Computed value | years_of_service |
| `RELATIONSHIP` | Entity connection | direct_report, manager |
| `RULE_CONCEPT` | Business rule term | rehire_eligibility |
| `ENUMERATION` | List of values | employment_status values |

---

## 📖 Usage Guidelines

### For Business Analysts

1. **Define terms early** — before entity modeling
2. **Get domain expert approval** — ensure accuracy
3. **Include examples** — concrete beats abstract
4. **Document what it's NOT** — prevents confusion

### For Developers

1. **Use exact term names** in code — match glossary
2. **Reference glossary** in code comments
3. **Add to glossary** when creating new concepts

### For AI Agents

1. **Load glossary first** — before processing entities
2. **Use definitions** when explaining domain
3. **Check aliases** when user uses different terms
4. **Reference translations** for localized content

---

## 🔗 Glossary Index

Create a master index linking all submodule glossaries:

```yaml
# File: 00-ontology/glossary-index.yaml

$schema: "https://xtalent.io/schemas/glossary-index/v3"
$id: "xtalent:core-hr:glossary:index"

module: CORE-HR
version: "1.0"

glossaries:
  - submodule: workforce
    file: "./workforce.glossary.yaml"
    term_count: 25
    
  - submodule: org-structure
    file: "./org-structure.glossary.yaml"
    term_count: 15
    
  - submodule: compensation
    file: "./compensation.glossary.yaml"
    term_count: 20

# Quick reference - alphabetical
all_terms:
  - term: assignment
    glossary: workforce
    
  - term: department
    glossary: org-structure
    
  - term: employee
    glossary: workforce
    
  # ... etc
```

---

## 📚 Related Documents

- [01-ARCHITECTURE.md](./01-ARCHITECTURE.md) — Framework overview
- [02-ENTITY-SCHEMA.md](./02-ENTITY-SCHEMA.md) — Entity definitions
- [07-AI-AGENT-GUIDE.md](./07-AI-AGENT-GUIDE.md) — AI agent usage
