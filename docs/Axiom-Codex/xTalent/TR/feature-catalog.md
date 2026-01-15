---
domain: TOTAL_REWARDS
module: TR
version: "1.0.0"
status: DRAFT
created: "2026-01-15"

# === FEATURE DATA ===
capabilities:
  # ==========================================
  # SALARY STRUCTURE MANAGEMENT
  # ==========================================
  - name: "Salary Structure Management"
    description: "Configure and manage pay grades, ranges, and salary framework."
    features:
      - id: FR-TR-001
        name: "Manage Pay Grades"
        description: "As an HR Admin, I want to manage pay grades so that jobs are properly classified for compensation."
        priority: MUST
        type: Functional
        competitor_reference: "Workday: Grade, SAP: Pay Grade"
        related_entities:
          - "[[PayGrade]]"
          - "[[PayRange]]"
        sub_features:
          - "Create pay grade"
          - "Define grade levels"
          - "Set effective dates"
          - "Archive grades"

      - id: FR-TR-002
        name: "Manage Pay Ranges"
        description: "As an HR Admin, I want to define pay ranges so that salary limits are established per grade."
        priority: MUST
        type: Functional
        related_entities:
          - "[[PayRange]]"
          - "[[PayGrade]]"
        sub_features:
          - "Set min/mid/max amounts"
          - "Configure by currency"
          - "Calculate range spread"
          - "Update ranges annually"

      - id: FR-TR-003
        name: "View Salary Structure"
        description: "As a Manager, I want to view the salary structure so that I understand pay levels."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[PayGrade]]"
          - "[[PayRange]]"

  # ==========================================
  # COMPENSATION PLAN MANAGEMENT
  # ==========================================
  - name: "Compensation Plan Management"
    description: "Configure compensation plans and elements."
    features:
      - id: FR-TR-010
        name: "Configure Compensation Plans"
        description: "As an HR Admin, I want to configure compensation plans so that different pay types are defined."
        priority: MUST
        type: Functional
        competitor_reference: "Workday: Compensation Plan, Oracle: Element"
        related_entities:
          - "[[CompensationPlan]]"
          - "[[CompensationElement]]"
          - "[[ElementType]]"
        sub_features:
          - "Create salary plans"
          - "Create bonus plans"
          - "Create allowance plans"
          - "Set eligibility rules"
          - "Configure frequency"

      - id: FR-TR-011
        name: "Manage Compensation Elements"
        description: "As an HR Admin, I want to manage compensation elements so that specific pay components are defined."
        priority: MUST
        type: Functional
        related_entities:
          - "[[CompensationElement]]"
          - "[[CompensationPlan]]"
        sub_features:
          - "Create element"
          - "Set default amount"
          - "Configure calculation"
          - "Set tax treatment"

  # ==========================================
  # EMPLOYEE COMPENSATION
  # ==========================================
  - name: "Employee Compensation"
    description: "Manage individual employee compensation packages."
    features:
      - id: FR-TR-020
        name: "View Employee Compensation"
        description: "As a Manager, I want to view an employee's compensation so that I understand their total pay."
        priority: MUST
        type: Functional
        related_entities:
          - "[[EmployeeCompensation]]"
          - "[[CompensationAssignment]]"
        sub_features:
          - "View base salary"
          - "View all elements"
          - "View compa-ratio"
          - "View pay history"

      - id: FR-TR-021
        name: "Update Employee Salary"
        description: "As an HR Admin, I want to update an employee's salary so that pay changes are recorded."
        priority: MUST
        type: Workflow
        related_entities:
          - "[[EmployeeCompensation]]"
          - "[[CompensationChange]]"
        sub_features:
          - "Enter new salary"
          - "Select change reason"
          - "Set effective date"
          - "Approval workflow"
          - "Generate letter"

      - id: FR-TR-022
        name: "Assign Compensation Elements"
        description: "As an HR Admin, I want to assign compensation elements so that employees receive appropriate pay components."
        priority: MUST
        type: Functional
        related_entities:
          - "[[CompensationAssignment]]"
          - "[[CompensationElement]]"
        sub_features:
          - "Add element to employee"
          - "Set amount or percentage"
          - "Set start/end dates"
          - "Remove element"

      - id: FR-TR-023
        name: "Assign Pay Grade to Employee"
        description: "As an HR Admin, I want to assign a pay grade so that the employee's salary range is defined."
        priority: MUST
        type: Functional
        related_entities:
          - "[[EmployeeCompensation]]"
          - "[[PayGrade]]"

      - id: FR-TR-024
        name: "View Compensation History"
        description: "As an Employee, I want to view my compensation history so that I can track my pay changes."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[CompensationChange]]"

  # ==========================================
  # COMPENSATION PLANNING
  # ==========================================
  - name: "Compensation Planning"
    description: "Manage annual compensation review cycles."
    features:
      - id: FR-TR-030
        name: "Create Compensation Cycle"
        description: "As an HR Admin, I want to create a compensation cycle so that annual reviews can be conducted."
        priority: MUST
        type: Functional
        competitor_reference: "Workday: Compensation Review, SAP: Compensation Planning"
        related_entities:
          - "[[CompensationCycle]]"
          - "[[MeritMatrix]]"
        sub_features:
          - "Define cycle period"
          - "Set total budget"
          - "Configure merit matrix"
          - "Set eligibility"
          - "Launch cycle"

      - id: FR-TR-031
        name: "Allocate Budget to Managers"
        description: "As an HR Admin, I want to allocate budget so that managers have defined spending limits."
        priority: MUST
        type: Functional
        related_entities:
          - "[[CompensationWorksheet]]"
          - "[[CompensationCycle]]"
        sub_features:
          - "Top-down allocation"
          - "By department/team"
          - "Set guidelines"

      - id: FR-TR-032
        name: "Make Compensation Recommendations"
        description: "As a Manager, I want to make compensation recommendations so that my team's increases are proposed."
        priority: MUST
        type: Workflow
        related_entities:
          - "[[CompensationWorksheet]]"
          - "[[CompensationRecommendation]]"
        sub_features:
          - "View team members"
          - "See current salary/compa-ratio"
          - "Enter merit increase"
          - "Enter promotion increase"
          - "Enter lump sum"
          - "Add justification"
          - "Submit worksheet"

      - id: FR-TR-033
        name: "Apply Merit Matrix"
        description: "As a Manager, I want the merit matrix applied so that increases align with guidelines."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[MeritMatrix]]"
          - "[[CompensationRecommendation]]"
        sub_features:
          - "Auto-suggest based on matrix"
          - "Show min/target/max"
          - "Flag outliers"

      - id: FR-TR-034
        name: "Approve Compensation Recommendations"
        description: "As an HR Admin, I want to approve recommendations so that increases are authorized."
        priority: MUST
        type: Workflow
        related_entities:
          - "[[CompensationWorksheet]]"
          - "[[CompensationRecommendation]]"
        sub_features:
          - "Review worksheets"
          - "Compare to budget"
          - "Approve/reject"
          - "Escalate exceptions"

      - id: FR-TR-035
        name: "Process Compensation Cycle"
        description: "As an HR Admin, I want to process the cycle so that approved changes take effect."
        priority: MUST
        type: Workflow
        related_entities:
          - "[[CompensationCycle]]"
          - "[[CompensationChange]]"
        sub_features:
          - "Generate changes"
          - "Apply effective dates"
          - "Notify employees"
          - "Close cycle"

  # ==========================================
  # BENEFITS ADMINISTRATION
  # ==========================================
  - name: "Benefits Administration"
    description: "Manage benefit plans and enrollments."
    features:
      - id: FR-TR-040
        name: "Configure Benefit Plans"
        description: "As an HR Admin, I want to configure benefit plans so that offerings are defined."
        priority: MUST
        type: Functional
        competitor_reference: "Workday: Benefit Plan, Oracle: Benefits"
        related_entities:
          - "[[BenefitPlan]]"
          - "[[BenefitOption]]"
          - "[[BenefitType]]"
        sub_features:
          - "Create plan"
          - "Set contribution levels"
          - "Define coverage options"
          - "Set eligibility"

      - id: FR-TR-041
        name: "Manage Open Enrollment"
        description: "As an HR Admin, I want to manage open enrollment so that employees can update elections."
        priority: SHOULD
        type: Workflow
        related_entities:
          - "[[OpenEnrollment]]"
          - "[[BenefitEnrollment]]"
        sub_features:
          - "Define enrollment period"
          - "Notify employees"
          - "Track completion"
          - "Close enrollment"

      - id: FR-TR-042
        name: "Enroll in Benefits"
        description: "As an Employee, I want to enroll in benefits so that I receive coverage."
        priority: MUST
        type: Workflow
        related_entities:
          - "[[BenefitEnrollment]]"
          - "[[BenefitPlan]]"
          - "[[Dependent]]"
        sub_features:
          - "View available plans"
          - "Select coverage level"
          - "Add dependents"
          - "Review costs"
          - "Confirm enrollment"

      - id: FR-TR-043
        name: "Manage Dependents"
        description: "As an Employee, I want to manage my dependents so that they can be covered by benefits."
        priority: MUST
        type: Functional
        related_entities:
          - "[[Dependent]]"
        sub_features:
          - "Add dependent"
          - "Update information"
          - "Remove dependent"
          - "Verify eligibility"

      - id: FR-TR-044
        name: "View Benefit Enrollment"
        description: "As an Employee, I want to view my benefit enrollments so that I know my coverage."
        priority: MUST
        type: Functional
        related_entities:
          - "[[BenefitEnrollment]]"

      - id: FR-TR-045
        name: "Process Life Event"
        description: "As an HR Admin, I want to process life events so that benefit changes are allowed outside enrollment."
        priority: SHOULD
        type: Workflow
        related_entities:
          - "[[BenefitEnrollment]]"
        sub_features:
          - "Marriage/divorce"
          - "Birth/adoption"
          - "Loss of coverage"
          - "Update enrollments"

  # ==========================================
  # VIETNAM SOCIAL INSURANCE
  # ==========================================
  - name: "Vietnam Social Insurance"
    description: "Manage mandatory social insurance contributions."
    features:
      - id: FR-TR-050
        name: "Calculate SI Contributions"
        description: "As an HR Admin, I want to calculate SI contributions so that mandatory amounts are correct."
        priority: MUST
        type: Functional
        related_entities:
          - "[[SocialInsuranceContribution]]"
        sub_features:
          - "Calculate employer SI/HI/UI"
          - "Calculate employee SI/HI/UI"
          - "Apply contribution ceiling"
          - "Handle exemptions"

      - id: FR-TR-051
        name: "View SI Contribution History"
        description: "As an Employee, I want to view my SI contributions so that I can verify payments."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[SocialInsuranceContribution]]"

      - id: FR-TR-052
        name: "Generate SI Report"
        description: "As an HR Admin, I want to generate SI reports so that I can submit to authorities."
        priority: MUST
        type: Reporting
        related_entities:
          - "[[SocialInsuranceContribution]]"

  # ==========================================
  # COMPENSATION ANALYTICS
  # ==========================================
  - name: "Compensation Analytics"
    description: "Analyze compensation data for decision-making."
    features:
      - id: FR-TR-060
        name: "Calculate Compa-Ratio"
        description: "As an HR Admin, I want to calculate compa-ratios so that pay positioning is visible."
        priority: MUST
        type: Functional
        related_entities:
          - "[[EmployeeCompensation]]"
          - "[[PayRange]]"

      - id: FR-TR-061
        name: "Analyze Pay Equity"
        description: "As an HR Admin, I want to analyze pay equity so that I can identify gaps."
        priority: SHOULD
        type: Reporting
        competitor_reference: "Workday: Pay Equity Dashboard"
        related_entities:
          - "[[EmployeeCompensation]]"
        sub_features:
          - "Compare by gender"
          - "Compare by tenure"
          - "Identify outliers"
          - "Generate reports"

      - id: FR-TR-062
        name: "Benchmark Salaries"
        description: "As an HR Admin, I want to benchmark salaries so that we remain competitive."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[PayGrade]]"
          - "[[PayRange]]"

      - id: FR-TR-063
        name: "Generate Total Rewards Statement"
        description: "As an Employee, I want to receive a TRS so that I understand my total value."
        priority: SHOULD
        type: Workflow
        related_entities:
          - "[[TotalRewardsStatement]]"
        sub_features:
          - "Calculate total value"
          - "Include salary"
          - "Include benefits"
          - "Include time off value"
          - "Generate PDF"

# === BUSINESS RULES ===
business_rules:
  - id: BR-TR-001
    title: "Salary Within Range"
    description: "Base salary must be within the assigned pay grade's range (min to max)."
    category: Validation
    severity: WARN
    related_entities:
      - "[[EmployeeCompensation]]"
      - "[[PayRange]]"

  - id: BR-TR-002
    title: "Minimum Wage Compliance"
    description: "Salary must meet or exceed regional minimum wage (Vietnam Regions I-IV)."
    category: Compliance
    severity: BLOCK
    related_entities:
      - "[[EmployeeCompensation]]"

  - id: BR-TR-003
    title: "Merit Within Matrix"
    description: "Merit increase should fall within merit matrix guidelines (min/target/max)."
    category: Validation
    severity: WARN
    related_entities:
      - "[[CompensationRecommendation]]"
      - "[[MeritMatrix]]"

  - id: BR-TR-004
    title: "Budget Not Exceeded"
    description: "Total recommended increases cannot exceed allocated budget."
    category: Validation
    severity: BLOCK
    related_entities:
      - "[[CompensationWorksheet]]"
      - "[[CompensationCycle]]"

  - id: BR-TR-005
    title: "Probation Salary Minimum"
    description: "Probation salary must be at least 85% of official salary (Vietnam)."
    category: Compliance
    severity: BLOCK
    related_entities:
      - "[[EmployeeCompensation]]"

  - id: BR-TR-006
    title: "SI Contribution Ceiling"
    description: "Social insurance base cannot exceed 20x minimum wage."
    category: Compliance
    severity: BLOCK
    related_entities:
      - "[[SocialInsuranceContribution]]"

  - id: BR-TR-007
    title: "Dependent Age Limit"
    description: "Child dependents must be under 18 (or 24 if full-time student)."
    category: Eligibility
    severity: BLOCK
    related_entities:
      - "[[Dependent]]"

  - id: BR-TR-008
    title: "Benefit Eligibility"
    description: "Employee must meet eligibility criteria (tenure, status) for each benefit plan."
    category: Eligibility
    severity: BLOCK
    related_entities:
      - "[[BenefitEnrollment]]"
      - "[[BenefitPlan]]"

  - id: BR-TR-009
    title: "One Primary Pay Grade"
    description: "Employee can have only one active pay grade assignment at a time."
    category: Validation
    severity: BLOCK
    related_entities:
      - "[[EmployeeCompensation]]"
      - "[[PayGrade]]"

  - id: BR-TR-010
    title: "Manager Cannot Self-Approve"
    description: "Managers cannot approve their own compensation recommendations."
    category: Approval
    severity: BLOCK
    related_entities:
      - "[[CompensationWorksheet]]"
---

# Feature Catalog: Total Rewards

> **Note**: YAML above is for AI processing. Tables below for human reading.

## Feature Overview Mindmap

```mermaid
mindmap
  root((Total Rewards Features))
    Salary Structure
      Manage Pay Grades
      Manage Pay Ranges
      View Structure
    Compensation Plans
      Configure Plans
      Manage Elements
    Employee Comp
      View Compensation
      Update Salary
      Assign Elements
      Assign Grade
      View History
    Comp Planning
      Create Cycle
      Allocate Budget
      Make Recommendations
      Apply Merit Matrix
      Approve
      Process Cycle
    Benefits
      Configure Plans
      Open Enrollment
      Enroll Benefits
      Manage Dependents
      Life Events
    Vietnam SI
      Calculate SI
      View History
      Generate Report
    Analytics
      Compa-ratio
      Pay Equity
      Benchmarking
      TRS
```

---

## Capability: Salary Structure Management

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-TR-001 | **Manage Pay Grades** | As an HR Admin, I want to manage pay grades... | MUST | Functional |
| FR-TR-002 | **Manage Pay Ranges** | As an HR Admin, I want to define pay ranges... | MUST | Functional |
| FR-TR-003 | **View Salary Structure** | As a Manager, I want to view salary structure... | SHOULD | Functional |

---

## Capability: Compensation Plan Management

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-TR-010 | **Configure Compensation Plans** | As an HR Admin, I want to configure plans... | MUST | Functional |
| FR-TR-011 | **Manage Compensation Elements** | As an HR Admin, I want to manage elements... | MUST | Functional |

---

## Capability: Employee Compensation

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-TR-020 | **View Employee Compensation** | As a Manager, I want to view compensation... | MUST | Functional |
| FR-TR-021 | **Update Employee Salary** | As an HR Admin, I want to update salary... | MUST | Workflow |
| FR-TR-022 | **Assign Compensation Elements** | As an HR Admin, I want to assign elements... | MUST | Functional |
| FR-TR-023 | **Assign Pay Grade** | As an HR Admin, I want to assign pay grade... | MUST | Functional |
| FR-TR-024 | **View Compensation History** | As an Employee, I want to view history... | SHOULD | Functional |

---

## Capability: Compensation Planning

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-TR-030 | **Create Compensation Cycle** | As an HR Admin, I want to create cycle... | MUST | Functional |
| FR-TR-031 | **Allocate Budget** | As an HR Admin, I want to allocate budget... | MUST | Functional |
| FR-TR-032 | **Make Recommendations** | As a Manager, I want to make recommendations... | MUST | Workflow |
| FR-TR-033 | **Apply Merit Matrix** | As a Manager, I want merit matrix applied... | SHOULD | Functional |
| FR-TR-034 | **Approve Recommendations** | As an HR Admin, I want to approve... | MUST | Workflow |
| FR-TR-035 | **Process Cycle** | As an HR Admin, I want to process cycle... | MUST | Workflow |

---

## Capability: Benefits Administration

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-TR-040 | **Configure Benefit Plans** | As an HR Admin, I want to configure plans... | MUST | Functional |
| FR-TR-041 | **Manage Open Enrollment** | As an HR Admin, I want to manage enrollment... | SHOULD | Workflow |
| FR-TR-042 | **Enroll in Benefits** | As an Employee, I want to enroll... | MUST | Workflow |
| FR-TR-043 | **Manage Dependents** | As an Employee, I want to manage dependents... | MUST | Functional |
| FR-TR-044 | **View Benefit Enrollment** | As an Employee, I want to view enrollments... | MUST | Functional |
| FR-TR-045 | **Process Life Event** | As an HR Admin, I want to process life events... | SHOULD | Workflow |

---

## Capability: Vietnam Social Insurance

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-TR-050 | **Calculate SI Contributions** | As an HR Admin, I want to calculate SI... | MUST | Functional |
| FR-TR-051 | **View SI History** | As an Employee, I want to view SI history... | SHOULD | Functional |
| FR-TR-052 | **Generate SI Report** | As an HR Admin, I want to generate SI report... | MUST | Reporting |

---

## Capability: Compensation Analytics

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-TR-060 | **Calculate Compa-Ratio** | As an HR Admin, I want to calculate compa-ratio... | MUST | Functional |
| FR-TR-061 | **Analyze Pay Equity** | As an HR Admin, I want to analyze pay equity... | SHOULD | Reporting |
| FR-TR-062 | **Benchmark Salaries** | As an HR Admin, I want to benchmark salaries... | SHOULD | Functional |
| FR-TR-063 | **Generate TRS** | As an Employee, I want to receive TRS... | SHOULD | Workflow |

---

## Business Rules Summary

| ID | Rule | Category | Severity |
|----|------|----------|----------|
| BR-TR-001 | Salary must be within pay range | Validation | WARN |
| BR-TR-002 | Must meet minimum wage | Compliance | BLOCK |
| BR-TR-003 | Merit within matrix guidelines | Validation | WARN |
| BR-TR-004 | Cannot exceed budget | Validation | BLOCK |
| BR-TR-005 | Probation salary ≥ 85% | Compliance | BLOCK |
| BR-TR-006 | SI ceiling = 20x min wage | Compliance | BLOCK |
| BR-TR-007 | Dependent age limit | Eligibility | BLOCK |
| BR-TR-008 | Benefit eligibility check | Eligibility | BLOCK |
| BR-TR-009 | One active pay grade | Validation | BLOCK |
| BR-TR-010 | Manager cannot self-approve | Approval | BLOCK |

---

## Summary Statistics

| Category | Count |
|----------|-------|
| Capabilities | 7 |
| Features | 28 |
| Business Rules | 10 |
| Priority MUST | 21 |
| Priority SHOULD | 7 |

---

## Required Document Mapping

### Features → feat.md Files

| Feature | Axiom File | Priority |
|---------|-----------|----------|
| Salary Structure (FR-TR-001-003) | `manage-salary-structure.feat.md` | MUST |
| Compensation Plans (FR-TR-010-011) | `manage-compensation-plans.feat.md` | MUST |
| Employee Compensation (FR-TR-020-024) | `manage-employee-compensation.feat.md` | MUST |
| Compensation Planning (FR-TR-030-035) | `compensation-planning.feat.md` | MUST |
| Benefits (FR-TR-040-045) | `manage-benefits.feat.md` | MUST |
| Vietnam SI (FR-TR-050-052) | `vietnam-si.feat.md` | MUST |
| Analytics (FR-TR-060-063) | `compensation-analytics.feat.md` | SHOULD |

### Business Rules → brs.md Files

| Area | Axiom File | Priority |
|------|-----------|----------|
| Compensation Rules | `compensation-rules.brs.md` | MUST |
| Merit Rules | `merit-rules.brs.md` | MUST |
| Benefit Eligibility | `benefit-eligibility.brs.md` | MUST |
| Vietnam SI Rules | `vietnam-si-rules.brs.md` | MUST |

### Workflows → flow.md Files

| Workflow | Axiom File | Priority |
|----------|-----------|----------|
| Salary Change | `salary-change-flow.flow.md` | MUST |
| Merit Cycle | `merit-cycle-flow.flow.md` | MUST |
| Benefit Enrollment | `benefit-enrollment-flow.flow.md` | MUST |
| TRS Generation | `generate-trs-flow.flow.md` | SHOULD |
