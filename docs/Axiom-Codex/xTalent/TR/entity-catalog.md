---
domain: TOTAL_REWARDS
module: TR
version: "1.0.0"
status: DRAFT
created: "2026-01-15"

# === ENTITY DATA ===
entities:
  # ==========================================
  # SALARY STRUCTURE
  # ==========================================
  
  - id: E-TR-001
    name: PayGrade
    type: ENTITY
    category: Config
    definition: "A classification level that groups jobs of similar value for compensation purposes."
    key_attributes:
      - id
      - code
      - name
      - description
      - gradeLevel
      - payRangeId
      - effectiveDate
      - endDate
      - status
    relationships:
      - "has one [[PayRange]]"
      - "applies to [[Job]]"
    competitor_reference: "Workday: Grade, SAP: Pay Grade, Oracle: Grade"
    priority: MUST

  - id: E-TR-002
    name: PayRange
    type: ENTITY
    category: Config
    definition: "Minimum, midpoint, and maximum salary values for a pay grade."
    key_attributes:
      - id
      - payGradeId
      - currency
      - minimumAmount
      - midpointAmount
      - maximumAmount
      - rangeSpread
      - effectiveDate
      - endDate
    relationships:
      - "belongsTo [[PayGrade]]"
    priority: MUST

  - id: E-TR-003
    name: SalaryBasis
    type: REFERENCE_DATA
    category: Config
    definition: "How salary is measured and paid (Annual, Monthly, Hourly, etc.)."
    key_attributes:
      - id
      - code
      - name
      - description
      - annualFactor
      - payPeriod
      - status
    priority: MUST

  # ==========================================
  # COMPENSATION PLANS
  # ==========================================

  - id: E-TR-010
    name: CompensationPlan
    type: AGGREGATE_ROOT
    category: Config
    definition: "A configuration that defines a type of compensation (base salary, bonus, allowance, etc.)."
    key_attributes:
      - id
      - code
      - name
      - description
      - planType
      - elementTypeId
      - frequency
      - currency
      - taxable
      - eligibilityRule
      - effectiveDate
      - endDate
      - status
    relationships:
      - "isOfType [[ElementType]]"
      - "has many [[CompensationElement]]"
    competitor_reference: "Workday: Compensation Plan, SAP: Pay Component, Oracle: Element"
    priority: MUST

  - id: E-TR-011
    name: CompensationElement
    type: ENTITY
    category: Config
    definition: "A specific pay component within a compensation plan (e.g., Housing Allowance)."
    key_attributes:
      - id
      - planId
      - code
      - name
      - description
      - defaultAmount
      - amountType
      - calculation
      - status
    relationships:
      - "belongsTo [[CompensationPlan]]"
    priority: MUST

  - id: E-TR-012
    name: ElementType
    type: REFERENCE_DATA
    category: Config
    definition: "Classification of compensation elements (Salary, Bonus, Allowance, Deduction)."
    key_attributes:
      - id
      - code
      - name
      - description
      - category
      - isEarning
      - isRecurring
      - status
    priority: MUST

  # ==========================================
  # EMPLOYEE COMPENSATION
  # ==========================================

  - id: E-TR-020
    name: EmployeeCompensation
    type: AGGREGATE_ROOT
    category: Transaction
    definition: "Complete compensation package assigned to an employee."
    key_attributes:
      - id
      - employeeId
      - assignmentId
      - baseSalary
      - salaryBasisId
      - currency
      - payGradeId
      - compaRatio
      - annualizedSalary
      - effectiveDate
      - endDate
      - status
    relationships:
      - "belongsTo [[Employee]]"
      - "basedOn [[PayGrade]]"
      - "useSalaryBasis [[SalaryBasis]]"
      - "has many [[CompensationAssignment]]"
    competitor_reference: "Workday: Worker Compensation, Oracle: Salary"
    priority: MUST

  - id: E-TR-021
    name: CompensationAssignment
    type: ENTITY
    category: Transaction
    definition: "Assignment of a specific compensation element to an employee."
    key_attributes:
      - id
      - employeeCompensationId
      - compensationElementId
      - amount
      - percentage
      - frequency
      - startDate
      - endDate
      - status
    relationships:
      - "belongsTo [[EmployeeCompensation]]"
      - "uses [[CompensationElement]]"
    priority: MUST

  - id: E-TR-022
    name: CompensationChange
    type: ENTITY
    category: Transaction
    definition: "A record of any change to employee compensation (salary increase, promotion, etc.)."
    key_attributes:
      - id
      - employeeId
      - changeType
      - changeReason
      - previousSalary
      - newSalary
      - changeAmount
      - changePercent
      - effectiveDate
      - approvedBy
      - approvedAt
      - status
    relationships:
      - "belongsTo [[Employee]]"
      - "partOf [[CompensationCycle]]"
    lifecycle: "Proposed → Approved → Effective → Completed"
    priority: MUST

  # ==========================================
  # COMPENSATION PLANNING
  # ==========================================

  - id: E-TR-030
    name: CompensationCycle
    type: AGGREGATE_ROOT
    category: Transaction
    definition: "An annual or periodic compensation review cycle."
    key_attributes:
      - id
      - code
      - name
      - description
      - cycleType
      - year
      - startDate
      - endDate
      - budget
      - budgetSpent
      - status
    relationships:
      - "has many [[CompensationWorksheet]]"
      - "uses [[MeritMatrix]]"
    lifecycle: "Planning → Open → InReview → Approved → Processed → Closed"
    competitor_reference: "Workday: Compensation Review, SAP: Compensation Planning"
    priority: MUST

  - id: E-TR-031
    name: CompensationWorksheet
    type: ENTITY
    category: Transaction
    definition: "Manager's worksheet for making compensation recommendations during a cycle."
    key_attributes:
      - id
      - cycleId
      - managerId
      - departmentId
      - allocatedBudget
      - recommendedTotal
      - status
      - submittedAt
      - approvedBy
    relationships:
      - "belongsTo [[CompensationCycle]]"
      - "ownedBy [[Employee]] (manager)"
      - "has many [[CompensationRecommendation]]"
    lifecycle: "Draft → Submitted → Approved → Processed"
    priority: MUST

  - id: E-TR-032
    name: CompensationRecommendation
    type: ENTITY
    category: Transaction
    definition: "A manager's recommendation for an employee's compensation change."
    key_attributes:
      - id
      - worksheetId
      - employeeId
      - currentSalary
      - proposedSalary
      - meritPercent
      - meritAmount
      - promotionPercent
      - lumpSum
      - totalIncrease
      - compaRatioBefore
      - compaRatioAfter
      - justification
      - status
    relationships:
      - "belongsTo [[CompensationWorksheet]]"
      - "forEmployee [[Employee]]"
    priority: MUST

  - id: E-TR-033
    name: MeritMatrix
    type: ENTITY
    category: Config
    definition: "A grid defining merit increase percentages based on performance rating and compa-ratio."
    key_attributes:
      - id
      - code
      - name
      - description
      - cycleId
      - effectiveDate
      - status
    relationships:
      - "usedBy [[CompensationCycle]]"
      - "has many [[MeritMatrixCell]]"
    priority: SHOULD

  - id: E-TR-034
    name: MeritMatrixCell
    type: VALUE_OBJECT
    category: Config
    definition: "A single cell in the merit matrix with min/target/max increase."
    key_attributes:
      - id
      - matrixId
      - performanceRating
      - compaRatioRangeMin
      - compaRatioRangeMax
      - minPercent
      - targetPercent
      - maxPercent
    relationships:
      - "belongsTo [[MeritMatrix]]"
    priority: SHOULD

  # ==========================================
  # BENEFITS ADMINISTRATION
  # ==========================================

  - id: E-TR-040
    name: BenefitPlan
    type: AGGREGATE_ROOT
    category: Config
    definition: "A benefit offering available to eligible employees."
    key_attributes:
      - id
      - code
      - name
      - description
      - benefitTypeId
      - provider
      - employerContribution
      - employeeContribution
      - coverageOptions
      - eligibilityRule
      - effectiveDate
      - endDate
      - status
    relationships:
      - "isOfType [[BenefitType]]"
      - "has many [[BenefitOption]]"
    competitor_reference: "Workday: Benefit Plan, Oracle: Benefits"
    priority: MUST

  - id: E-TR-041
    name: BenefitType
    type: REFERENCE_DATA
    category: Config
    definition: "Classification of benefits (Health, Life, Retirement, etc.)."
    key_attributes:
      - id
      - code
      - name
      - description
      - category
      - isMandatory
      - status
    priority: MUST

  - id: E-TR-042
    name: BenefitOption
    type: ENTITY
    category: Config
    definition: "Coverage options within a benefit plan (Individual, Family, etc.)."
    key_attributes:
      - id
      - planId
      - optionCode
      - optionName
      - coverageLevel
      - employerAmount
      - employeeAmount
      - status
    relationships:
      - "belongsTo [[BenefitPlan]]"
    priority: SHOULD

  - id: E-TR-043
    name: BenefitEnrollment
    type: ENTITY
    category: Transaction
    definition: "An employee's enrollment in a benefit plan."
    key_attributes:
      - id
      - employeeId
      - benefitPlanId
      - optionId
      - coverageStartDate
      - coverageEndDate
      - employeeContribution
      - employerContribution
      - enrollmentDate
      - status
    relationships:
      - "belongsTo [[Employee]]"
      - "enrollsIn [[BenefitPlan]]"
      - "selectsOption [[BenefitOption]]"
      - "covers [[Dependent]]"
    lifecycle: "Pending → Active → OnHold → Terminated"
    priority: MUST

  - id: E-TR-044
    name: Dependent
    type: ENTITY
    category: Master
    definition: "A family member covered under an employee's benefit."
    key_attributes:
      - id
      - employeeId
      - firstName
      - lastName
      - relationship
      - dateOfBirth
      - gender
      - nationalId
      - status
    relationships:
      - "belongsTo [[Employee]]"
      - "coveredBy [[BenefitEnrollment]]"
    priority: MUST

  - id: E-TR-045
    name: OpenEnrollment
    type: ENTITY
    category: Transaction
    definition: "Annual period when employees can change benefit elections."
    key_attributes:
      - id
      - code
      - name
      - year
      - startDate
      - endDate
      - coverageStartDate
      - status
    relationships:
      - "has many [[BenefitEnrollment]]"
    lifecycle: "Pending → Open → Closed → Processed"
    priority: SHOULD

  # ==========================================
  # VIETNAM SOCIAL INSURANCE
  # ==========================================

  - id: E-TR-050
    name: SocialInsuranceContribution
    type: ENTITY
    category: Transaction
    definition: "Monthly social insurance contribution record for Vietnam compliance."
    key_attributes:
      - id
      - employeeId
      - periodMonth
      - periodYear
      - grossSalary
      - siBase
      - employerSI
      - employeeSI
      - employerHI
      - employeeHI
      - employerUI
      - employeeUI
      - totalEmployer
      - totalEmployee
      - status
    relationships:
      - "belongsTo [[Employee]]"
    priority: MUST

  # ==========================================
  # TOTAL REWARDS STATEMENT
  # ==========================================

  - id: E-TR-060
    name: TotalRewardsStatement
    type: ENTITY
    category: Transaction
    definition: "Annual statement summarizing employee's total compensation and benefits value."
    key_attributes:
      - id
      - employeeId
      - statementYear
      - baseSalary
      - bonuses
      - allowances
      - benefitsValue
      - retirementValue
      - timeOffValue
      - totalValue
      - generatedAt
      - status
    relationships:
      - "belongsTo [[Employee]]"
    priority: SHOULD
---

# Entity Catalog: Total Rewards

> **Note**: YAML above is for AI processing. Tables below for human reading.

## Entity Relationship Diagram

```mermaid
erDiagram
    PayGrade ||--|| PayRange : "has"
    Job }o--|| PayGrade : "assignedTo"
    
    CompensationPlan ||--o{ CompensationElement : "contains"
    CompensationPlan }o--|| ElementType : "isOfType"
    
    Employee ||--o| EmployeeCompensation : "has"
    EmployeeCompensation }o--|| PayGrade : "atGrade"
    EmployeeCompensation ||--o{ CompensationAssignment : "includes"
    CompensationAssignment }o--|| CompensationElement : "uses"
    
    Employee ||--o{ CompensationChange : "receives"
    
    CompensationCycle ||--o{ CompensationWorksheet : "contains"
    CompensationCycle }o--o| MeritMatrix : "uses"
    CompensationWorksheet ||--o{ CompensationRecommendation : "contains"
    CompensationRecommendation }o--|| Employee : "for"
    
    BenefitPlan ||--o{ BenefitOption : "offers"
    BenefitPlan }o--|| BenefitType : "isOfType"
    
    Employee ||--o{ BenefitEnrollment : "enrollsIn"
    BenefitEnrollment }o--|| BenefitPlan : "for"
    BenefitEnrollment }o--o{ Dependent : "covers"
    
    Employee ||--o{ Dependent : "has"
    Employee ||--o{ SocialInsuranceContribution : "contributes"
    Employee ||--o{ TotalRewardsStatement : "receives"
```

---

## A. Salary Structure

| ID | Entity | Type | Definition |
|----|--------|------|------------|
| E-TR-001 | **[[PayGrade]]** | ENTITY | Classification level grouping jobs of similar value. |
| E-TR-002 | **[[PayRange]]** | ENTITY | Min/Mid/Max salary values for a pay grade. |
| E-TR-003 | **[[SalaryBasis]]** | REFERENCE_DATA | How salary is measured (Annual, Monthly, Hourly). |

---

## B. Compensation Plans

| ID | Entity | Type | Definition |
|----|--------|------|------------|
| E-TR-010 | **[[CompensationPlan]]** | AGGREGATE_ROOT | Configuration defining a type of compensation. |
| E-TR-011 | **[[CompensationElement]]** | ENTITY | Specific pay component within a plan. |
| E-TR-012 | **[[ElementType]]** | REFERENCE_DATA | Classification (Salary, Bonus, Allowance, Deduction). |

---

## C. Employee Compensation

| ID | Entity | Lifecycle | Definition |
|----|--------|-----------|------------|
| E-TR-020 | **[[EmployeeCompensation]]** | - | Complete compensation package for an employee. |
| E-TR-021 | **[[CompensationAssignment]]** | - | Assignment of element to employee. |
| E-TR-022 | **[[CompensationChange]]** | Proposed → Approved → Effective → Completed | Record of compensation changes. |

---

## D. Compensation Planning

| ID | Entity | Lifecycle | Definition |
|----|--------|-----------|------------|
| E-TR-030 | **[[CompensationCycle]]** | Planning → Open → InReview → Approved → Processed → Closed | Annual/periodic review cycle. |
| E-TR-031 | **[[CompensationWorksheet]]** | Draft → Submitted → Approved → Processed | Manager's worksheet for recommendations. |
| E-TR-032 | **[[CompensationRecommendation]]** | - | Individual employee recommendation. |
| E-TR-033 | **[[MeritMatrix]]** | - | Performance × Compa-ratio grid. |
| E-TR-034 | **[[MeritMatrixCell]]** | - | Single cell with increase percentages. |

---

## E. Benefits Administration

| ID | Entity | Lifecycle | Definition |
|----|--------|-----------|------------|
| E-TR-040 | **[[BenefitPlan]]** | - | Benefit offering for eligible employees. |
| E-TR-041 | **[[BenefitType]]** | - | Classification (Health, Life, Retirement). |
| E-TR-042 | **[[BenefitOption]]** | - | Coverage options within a plan. |
| E-TR-043 | **[[BenefitEnrollment]]** | Pending → Active → OnHold → Terminated | Employee's enrollment in a plan. |
| E-TR-044 | **[[Dependent]]** | - | Family member covered by benefit. |
| E-TR-045 | **[[OpenEnrollment]]** | Pending → Open → Closed → Processed | Annual enrollment period. |

---

## F. Vietnam Social Insurance

| ID | Entity | Type | Definition |
|----|--------|------|------------|
| E-TR-050 | **[[SocialInsuranceContribution]]** | ENTITY | Monthly SI/HI/UI contribution record. |

---

## G. Total Rewards Statement

| ID | Entity | Type | Definition |
|----|--------|------|------------|
| E-TR-060 | **[[TotalRewardsStatement]]** | ENTITY | Annual statement of total value. |

---

## Summary Statistics

| Category | Count |
|----------|-------|
| AGGREGATE_ROOT | 4 |
| ENTITY | 16 |
| VALUE_OBJECT | 1 |
| REFERENCE_DATA | 3 |
| **Total Entities** | **24** |

---

## Domain Terminology

| Term | Definition |
|------|------------|
| **Compa-ratio** | Employee salary ÷ Range midpoint × 100 |
| **Position-in-Range** | Where salary falls within min-max range |
| **Range Spread** | (Max - Min) ÷ Min × 100 |
| **Merit Increase** | Annual salary increase based on performance |
| **Merit Matrix** | Grid mapping performance to increase % |
| **Total Rewards** | Sum of all compensation and benefits |
| **Social Insurance (SI)** | Vietnam mandatory contribution (17.5% + 8%) |
| **Health Insurance (HI)** | Vietnam mandatory (3% + 1.5%) |
| **Unemployment Insurance (UI)** | Vietnam mandatory (1% + 1%) |
