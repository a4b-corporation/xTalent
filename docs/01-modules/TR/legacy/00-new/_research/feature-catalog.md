---
domain: Total Rewards
module: TR
version: "1.0.0"
status: DRAFT
created: "2026-01-30"

# === FEATURE DATA ===
capabilities:
  # ========================================
  # CAPABILITY 1: COMPENSATION MANAGEMENT
  # ========================================
  - name: "Compensation Management"
    subdomain_type: CORE
    description: "Complete compensation planning, structure management, and salary administration for competitive and equitable pay"
    features:
      - id: FR-TR-001
        name: "Compensation Planning & Budgeting"
        description: "As an HR manager, I want to create and manage compensation budgets for merit cycles so that salary increases are planned within financial constraints"
        priority: MUST
        differentiation: PARITY
        stability: MEDIUM
        type: Functional
        complexity: HIGH
        risk: high
        competitor_reference: "Oracle, SAP, Workday (3/3)"
        source_ref: "Industry standard"
        decision_ref: null
        related_entities:
          - "[[CompensationReview]]"
          - "[[CompensationPlan]]"
        business_rules:
          - "Budget must be approved before distribution"
          - "Budget rollup by department hierarchy"
          - "Budget can be allocated in currency or percentage"

      - id: FR-TR-002
        name: "Salary Structure Management"
        description: "As a compensation analyst, I want to define pay grades with salary ranges so that job compensation is market-aligned and internally equitable"
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: MEDIUM
        risk: medium
        competitor_reference: "Oracle, SAP, Workday, Microsoft (4/4)"
        source_ref: "Industry standard"
        related_entities:
          - "[[SalaryStructure]]"
          - "[[SalaryGrade]]"
        business_rules:
          - "Grades must have min <= mid <= max"
          - "Ranges can overlap between adjacent grades"
          - "Structure effective dating required"

      - id: FR-TR-003
        name: "Base Pay Management"
        description: "As an HR manager, I want to assign and update employee base salaries so that employees are compensated according to their job and grade"
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: MEDIUM
        risk: medium
        competitor_reference: "Oracle, SAP, Workday, Microsoft (4/4)"
        source_ref: "Industry standard"
        related_entities:
          - "[[CompensationAssignment]]"
          - "[[SalaryHistory]]"
        business_rules:
          - "Salary effective date required"
          - "Reason code mandatory for changes"
          - "Salary must meet minimum wage requirements"
          - "Changes create audit history"

      - id: FR-TR-004
        name: "Variable Pay & Bonus Management"
        description: "As a compensation manager, I want to configure bonus plans with targets and payouts so that employees are rewarded based on performance"
        priority: MUST
        differentiation: PARITY
        stability: MEDIUM
        type: Calculation
        complexity: HIGH
        risk: high
        competitor_reference: "Oracle, SAP, Workday, Microsoft (4/4)"
        source_ref: "Industry standard"
        related_entities:
          - "[[BonusPlan]]"
          - "[[CompensationComponent]]"
        business_rules:
          - "Bonus tied to performance rating optional"
          - "Pro-rata calculation for partial year"
          - "Multiple bonus plans can apply to employee"

      - id: FR-TR-005
        name: "Merit Increase Processing"
        description: "As a manager, I want to recommend merit increases during review cycles so that high performers are rewarded appropriately"
        priority: MUST
        differentiation: PARITY
        stability: MEDIUM
        type: Workflow
        complexity: HIGH
        risk: high
        competitor_reference: "Oracle, SAP, Workday (3/4)"
        source_ref: "Industry standard"
        related_entities:
          - "[[CompensationReview]]"
          - "[[CompensationAssignment]]"
        business_rules:
          - "Merit budget guidelines by grade"
          - "Performance rating can influence guideline"
          - "Multi-level approval workflow"
          - "Compa-ratio impact calculation"

      - id: FR-TR-006
        name: "Equity & Stock Compensation"
        description: "As a compensation manager, I want to manage stock grants and equity awards so that employees share in company success"
        priority: SHOULD
        differentiation: INNOVATION
        stability: MEDIUM
        type: Functional
        complexity: HIGH
        risk: high
        competitor_reference: "Oracle, Workday (2/4)"
        source_ref: "Tech industry practice"
        related_entities:
          - "[[CompensationComponent]]"
          - "[[CompensationAssignment]]"
        business_rules:
          - "Vesting schedule configuration"
          - "Grant date and exercise tracking"
          - "Fair value calculation support"

      - id: FR-TR-007
        name: "Allowance Management"
        description: "As an HR admin, I want to manage various allowances (housing, transport, meal) so that employees receive their entitled allowances"
        priority: MUST
        differentiation: PARITY
        stability: MEDIUM
        type: Functional
        complexity: MEDIUM
        risk: medium
        competitor_reference: "Oracle, SAP (2/4)"
        source_ref: "Vietnam Labor Law, common practice"
        related_entities:
          - "[[CompensationComponent]]"
          - "[[CompensationAssignment]]"
        business_rules:
          - "Allowance eligibility by job/location"
          - "Tax treatment per allowance type"
          - "SI applicability configuration"

      - id: FR-TR-008
        name: "Global Compensation Support"
        description: "As a global HR manager, I want to manage compensation across multiple currencies and countries so that all employees are compensated appropriately"
        priority: SHOULD
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: HIGH
        risk: medium
        competitor_reference: "Oracle, SAP, Workday (3/4)"
        source_ref: "Global enterprise need"
        related_entities:
          - "[[CompensationPlan]]"
          - "[[CompensationAssignment]]"
        business_rules:
          - "Multi-currency support"
          - "Exchange rate handling"
          - "Local regulatory compliance per country"

      - id: FR-TR-009
        name: "Compensation Review Workflow"
        description: "As a manager, I want to participate in structured compensation review cycles so that salary changes are processed consistently"
        priority: MUST
        differentiation: PARITY
        stability: MEDIUM
        type: Workflow
        complexity: HIGH
        risk: high
        competitor_reference: "Oracle, SAP, Workday (3/4)"
        source_ref: "Industry standard"
        related_entities:
          - "[[CompensationReview]]"
        business_rules:
          - "Review cycle with defined timeline"
          - "Manager worksheet access"
          - "Budget compliance enforcement"
          - "Mass approval and processing"

  # ========================================
  # CAPABILITY 2: BENEFITS ADMINISTRATION
  # ========================================
  - name: "Benefits Administration"
    subdomain_type: CORE
    description: "Comprehensive benefits program management from plan configuration to employee enrollment and carrier integration"
    features:
      - id: FR-TR-010
        name: "Benefits Program Definition"
        description: "As a benefits administrator, I want to create benefit programs grouping related plans so that benefits are organized logically for employees"
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: MEDIUM
        risk: low
        competitor_reference: "Oracle, SAP, Workday, Microsoft (4/4)"
        source_ref: "Industry standard"
        related_entities:
          - "[[BenefitProgram]]"
        business_rules:
          - "Programs have effective dates"
          - "Programs can span multiple legal entities"
          - "Default programs by employment type"

      - id: FR-TR-011
        name: "Benefits Plan Configuration"
        description: "As a benefits administrator, I want to configure detailed benefit plans with costs and options so that employees can make informed selections"
        priority: MUST
        differentiation: PARITY
        stability: MEDIUM
        type: Functional
        complexity: HIGH
        risk: medium
        competitor_reference: "Oracle, SAP, Workday, Microsoft (4/4)"
        source_ref: "Industry standard"
        related_entities:
          - "[[BenefitPlan]]"
          - "[[BenefitOption]]"
        business_rules:
          - "Plan with multiple coverage tiers"
          - "Employee and employer cost split"
          - "Pre-tax vs post-tax configuration"
          - "Annual plan year cycle"

      - id: FR-TR-012
        name: "Eligibility Rules Engine"
        description: "As a benefits administrator, I want to define eligibility rules so that only qualified employees can enroll in specific benefits"
        priority: MUST
        differentiation: PARITY
        stability: MEDIUM
        type: Validation
        complexity: HIGH
        risk: high
        competitor_reference: "Oracle, SAP, Workday (3/4)"
        source_ref: "Industry standard"
        related_entities:
          - "[[EligibilityRule]]"
          - "[[BenefitProgram]]"
        business_rules:
          - "Waiting period rules"
          - "Employment type filter"
          - "Job level/grade filter"
          - "Work location filter"
          - "Hours per week minimum"

      - id: FR-TR-013
        name: "Open Enrollment Management"
        description: "As a benefits administrator, I want to run annual open enrollment so that employees can review and change their benefits"
        priority: MUST
        differentiation: PARITY
        stability: MEDIUM
        type: Workflow
        complexity: HIGH
        risk: high
        competitor_reference: "Oracle, SAP, Workday, Microsoft (4/4)"
        source_ref: "Industry standard"
        related_entities:
          - "[[BenefitEnrollment]]"
          - "[[BenefitElection]]"
        business_rules:
          - "Defined enrollment window"
          - "Reminder notifications"
          - "Default election handling"
          - "Confirmation process"

      - id: FR-TR-014
        name: "Life Event Processing"
        description: "As an employee, I want to report life events so that I can change my benefits outside of open enrollment when qualified"
        priority: MUST
        differentiation: PARITY
        stability: LOW
        type: Workflow
        complexity: HIGH
        risk: high
        competitor_reference: "Oracle, Workday (2/4)"
        source_ref: "Industry standard, IRS regulations (US context)"
        related_entities:
          - "[[LifeEvent]]"
          - "[[BenefitEnrollment]]"
        business_rules:
          - "Qualifying event types defined"
          - "Enrollment window per event type"
          - "Documentation requirements"
          - "Auto-detect events (marriage, birth)"

      - id: FR-TR-015
        name: "Benefits Self-Service Enrollment"
        description: "As an employee, I want to enroll in benefits online so that I can select the best options for my needs without HR assistance"
        priority: MUST
        differentiation: PARITY
        stability: MEDIUM
        type: UI/UX
        complexity: MEDIUM
        risk: medium
        competitor_reference: "Oracle, SAP, Workday, Microsoft (4/4)"
        source_ref: "Industry standard, employee experience"
        related_entities:
          - "[[BenefitEnrollment]]"
          - "[[BenefitElection]]"
        business_rules:
          - "Side-by-side plan comparison"
          - "Cost calculator"
          - "Mobile-friendly interface"
          - "Confirmation email"

      - id: FR-TR-016
        name: "Dependent & Beneficiary Management"
        description: "As an employee, I want to manage my dependents and beneficiaries so that they are covered under my benefits"
        priority: MUST
        differentiation: PARITY
        stability: MEDIUM
        type: Functional
        complexity: MEDIUM
        risk: medium
        competitor_reference: "Oracle, SAP, Workday, Microsoft (4/4)"
        source_ref: "Industry standard"
        related_entities:
          - "[[Dependent]]"
          - "[[BenefitElection]]"
        business_rules:
          - "Relationship type validation (spouse, child)"
          - "Age eligibility rules for dependents"
          - "Documentation requirements"
          - "Beneficiary percentage allocation"

      - id: FR-TR-017
        name: "Flex Credit Programs"
        description: "As a benefits administrator, I want to offer flex credits so that employees can customize their benefits package"
        priority: SHOULD
        differentiation: INNOVATION
        stability: MEDIUM
        type: Functional
        complexity: HIGH
        risk: medium
        competitor_reference: "Workday, Microsoft (2/4)"
        source_ref: "Modern benefits trend"
        related_entities:
          - "[[BenefitProgram]]"
          - "[[BenefitElection]]"
        business_rules:
          - "Credit allocation by level/grade"
          - "Buy-up and buy-down options"
          - "Unused credit handling (cash out, rollover)"
          - "Pro-rata for mid-year hires"

      - id: FR-TR-018
        name: "Benefits Carrier Integration"
        description: "As a benefits administrator, I want to sync enrollment data with carriers so that coverage is activated without manual processes"
        priority: SHOULD
        differentiation: PARITY
        stability: HIGH
        type: Integration
        complexity: HIGH
        risk: high
        competitor_reference: "Oracle, SAP, Workday (3/4)"
        source_ref: "Operational efficiency"
        decision_ref: "ADR-TR-005"
        related_entities:
          - "[[BenefitEnrollment]]"
          - "[[BenefitCarrier]]"
        business_rules:
          - "Standard EDI/API formats"
          - "Daily or real-time sync options"
          - "Error handling and reconciliation"
          - "Carrier-specific mapping"

  # ========================================
  # CAPABILITY 3: RECOGNITION & REWARDS
  # ========================================
  - name: "Recognition & Rewards"
    subdomain_type: CORE
    description: "Employee recognition programs including peer-to-peer kudos, manager awards, milestone celebrations, and rewards redemption"
    features:
      - id: FR-TR-019
        name: "Recognition Program Setup"
        description: "As an HR admin, I want to create recognition programs with budgets and rules so that recognition is managed consistently"
        priority: MUST
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: MEDIUM
        risk: low
        competitor_reference: "Oracle Celebrate, SAP Spot Awards (2/4)"
        source_ref: "Industry standard"
        decision_ref: "ADR-TR-001"
        related_entities:
          - "[[RecognitionProgram]]"
          - "[[AwardType]]"
        business_rules:
          - "Budget allocation by department"
          - "Award limits per sender/recipient"
          - "Approval thresholds"
          - "Tax implications per award type"

      - id: FR-TR-020
        name: "Peer-to-Peer Recognition"
        description: "As an employee, I want to recognize my colleagues for great work so that appreciation is shared across the organization"
        priority: MUST
        differentiation: INNOVATION
        stability: LOW
        type: UI/UX
        complexity: MEDIUM
        risk: low
        competitor_reference: "Oracle Celebrate, SAP Appreciate (2/4)"
        source_ref: "Modern employee experience"
        related_entities:
          - "[[RecognitionAward]]"
          - "[[AwardType]]"
        business_rules:
          - "All employees can send recognition"
          - "Link to company values"
          - "Message and optional points/cash"
          - "Public or private option"

      - id: FR-TR-021
        name: "Manager Recognition Awards"
        description: "As a manager, I want to give meaningful awards to my team so that exceptional performance is formally recognized"
        priority: MUST
        differentiation: PARITY
        stability: MEDIUM
        type: Workflow
        complexity: MEDIUM
        risk: medium
        competitor_reference: "Oracle, SAP, Workday (3/4)"
        source_ref: "Industry standard"
        related_entities:
          - "[[RecognitionAward]]"
          - "[[RecognitionProgram]]"
        business_rules:
          - "Budget tracking per manager"
          - "Approval for high-value awards"
          - "Nomination justification required"
          - "Integration with payroll for cash awards"

      - id: FR-TR-022
        name: "Milestone Celebrations"
        description: "As an employee, I want to be celebrated on anniversaries and birthdays so that I feel valued on special occasions"
        priority: SHOULD
        differentiation: INNOVATION
        stability: MEDIUM
        type: Functional
        complexity: MEDIUM
        risk: low
        competitor_reference: "Oracle Celebrate (1/4)"
        source_ref: "Employee experience best practice"
        related_entities:
          - "[[MilestoneEvent]]"
          - "[[RecognitionAward]]"
        business_rules:
          - "Automated detection from HR data"
          - "Configurable milestones (1, 3, 5, 10 years)"
          - "Birthday opt-in/out"
          - "Auto-generate celebration post"

      - id: FR-TR-023
        name: "Spot Awards"
        description: "As a manager, I want to give immediate spot bonuses so that exceptional contributions are rewarded in the moment"
        priority: MUST
        differentiation: PARITY
        stability: LOW
        type: Functional
        complexity: MEDIUM
        risk: medium
        competitor_reference: "Oracle, SAP (2/4)"
        source_ref: "Industry standard"
        related_entities:
          - "[[RecognitionAward]]"
          - "[[AwardType]]"
        business_rules:
          - "Instant or quick approval"
          - "Budget deduction real-time"
          - "Tax withholding application"
          - "Direct to payroll integration"

      - id: FR-TR-024
        name: "Points-Based Rewards"
        description: "As an employee, I want to earn and redeem points so that I can choose rewards that matter to me"
        priority: SHOULD
        differentiation: INNOVATION
        stability: LOW
        type: Functional
        complexity: HIGH
        risk: medium
        competitor_reference: "Third-party focus (e.g., O.C. Tanner, Achievers)"
        source_ref: "Modern recognition trend"
        related_entities:
          - "[[RecognitionAward]]"
          - "[[PointsBalance]]"
        business_rules:
          - "Points earned from recognition"
          - "Points expiration policy"
          - "Conversion rate to cash/rewards"
          - "Points transfer capability"

      - id: FR-TR-025
        name: "Rewards Catalog & Redemption"
        description: "As an employee, I want to browse and redeem rewards from a catalog so that I can choose meaningful prizes"
        priority: SHOULD
        differentiation: INNOVATION
        stability: LOW
        type: Integration
        complexity: HIGH
        risk: medium
        competitor_reference: "Third-party (Awardco, Fond)"
        source_ref: "Modern recognition practice"
        decision_ref: "ADR-TR-001"
        related_entities:
          - "[[RewardsCatalog]]"
          - "[[RecognitionAward]]"
        business_rules:
          - "Gift cards, merchandise, experiences"
          - "Third-party catalog integration"
          - "Regional catalog variations"
          - "Order tracking and fulfillment"

      - id: FR-TR-026
        name: "Social Recognition Feed"
        description: "As an employee, I want to see colleague recognitions in a social feed so that celebrations are visible across the company"
        priority: SHOULD
        differentiation: INNOVATION
        stability: LOW
        type: UI/UX
        complexity: MEDIUM
        risk: low
        competitor_reference: "Oracle Celebrate (1/4)"
        source_ref: "Modern employee experience"
        related_entities:
          - "[[RecognitionAward]]"
          - "[[SocialFeed]]"
        business_rules:
          - "Real-time feed updates"
          - "Like and comment capability"
          - "Share to external platforms option"
          - "Privacy controls"

  # ========================================
  # CAPABILITY 4: WELL-BEING PROGRAMS
  # ========================================
  - name: "Well-being Programs"
    subdomain_type: GENERIC
    description: "Employee wellness and well-being support including physical, mental, and financial health integrations"
    features:
      - id: FR-TR-027
        name: "Wellness Program Integration"
        description: "As an HR admin, I want to integrate wellness platforms so that employees can access health programs through one portal"
        priority: COULD
        differentiation: PARITY
        stability: HIGH
        type: Integration
        complexity: MEDIUM
        risk: low
        competitor_reference: "Oracle, SAP (2/4)"
        source_ref: "Employee well-being trend"
        related_entities:
          - "[[WellnessProgram]]"
        business_rules:
          - "SSO integration"
          - "Activity tracking optional"
          - "Wellness incentive connection"
          - "Privacy-compliant data sharing"

      - id: FR-TR-028
        name: "Mental Health Resources"
        description: "As an employee, I want to access mental health resources so that I can get support when needed"
        priority: COULD
        differentiation: PARITY
        stability: HIGH
        type: Integration
        complexity: LOW
        risk: low
        competitor_reference: "Modern Health, Headspace integration"
        source_ref: "Employee well-being trend"
        business_rules:
          - "EAP program information"
          - "Confidential access"
          - "Third-party provider links"

      - id: FR-TR-029
        name: "Financial Wellness Tools"
        description: "As an employee, I want to access financial wellness resources so that I can manage my finances better"
        priority: COULD
        differentiation: PARITY
        stability: HIGH
        type: Integration
        complexity: LOW
        risk: low
        competitor_reference: "Oracle (1/4)"
        source_ref: "Employee well-being trend"
        business_rules:
          - "Financial education content"
          - "Retirement planning tools"
          - "Student loan assistance info"

      - id: FR-TR-030
        name: "Work-Life Balance Features"
        description: "As an employee, I want to manage work-life balance through flexible arrangements so that I can be more productive"
        priority: COULD
        differentiation: PARITY
        stability: HIGH
        type: Functional
        complexity: LOW
        risk: low
        competitor_reference: "All vendors have limited (indirect)"
        source_ref: "Modern workplace trend"
        business_rules:
          - "Flexible work arrangement tracking"
          - "Connection to Time & Absence"
          - "Wellbeing check-ins"

  # ========================================
  # CAPABILITY 5: TOTAL REWARDS ANALYTICS
  # ========================================
  - name: "Total Rewards Analytics"
    subdomain_type: CORE
    description: "Comprehensive analytics for compensation statements, pay equity, benchmarking, and ROI measurement"
    features:
      - id: FR-TR-031
        name: "Total Compensation Statements"
        description: "As an employee, I want to view my total compensation statement so that I understand the full value of my rewards package"
        priority: MUST
        differentiation: PARITY
        stability: MEDIUM
        type: UI/UX
        complexity: HIGH
        risk: medium
        competitor_reference: "Oracle, SAP, Workday (3/4)"
        source_ref: "Industry standard"
        decision_ref: "ADR-TR-002"
        related_entities:
          - "[[TotalRewardsStatement]]"
        business_rules:
          - "Include all comp components"
          - "Include benefits value"
          - "Include recognition awards"
          - "PDF export capability"
          - "Configurable sections"

      - id: FR-TR-032
        name: "Pay Equity Analytics"
        description: "As an HR leader, I want to analyze pay equity across demographics so that we can identify and address pay gaps"
        priority: MUST
        differentiation: INNOVATION
        stability: MEDIUM
        type: Calculation
        complexity: HIGH
        risk: high
        competitor_reference: "Workday, Oracle (2/4)"
        source_ref: "Regulatory trend, DEI initiatives"
        related_entities:
          - "[[PayEquityAnalysis]]"
        business_rules:
          - "Gender pay gap calculation"
          - "Compa-ratio analysis by group"
          - "Statistical significance testing"
          - "Trend analysis over time"

      - id: FR-TR-033
        name: "Compensation Benchmarking"
        description: "As a compensation analyst, I want to compare our pay to market data so that we can ensure competitive compensation"
        priority: SHOULD
        differentiation: INNOVATION
        stability: MEDIUM
        type: Integration
        complexity: HIGH
        risk: medium
        competitor_reference: "Oracle, Workday (2/4)"
        source_ref: "Compensation best practice"
        decision_ref: "ADR-TR-004"
        related_entities:
          - "[[MarketData]]"
          - "[[SalaryStructure]]"
        business_rules:
          - "Market data import (survey providers)"
          - "Job matching to market"
          - "Percentile comparison"
          - "Recommendations engine"

      - id: FR-TR-034
        name: "Benefits Cost Analysis"
        description: "As a benefits manager, I want to analyze benefits costs and utilization so that programs are optimized for value"
        priority: SHOULD
        differentiation: PARITY
        stability: MEDIUM
        type: Calculation
        complexity: MEDIUM
        risk: low
        competitor_reference: "Oracle, SAP (2/4)"
        source_ref: "Benefits management practice"
        related_entities:
          - "[[BenefitEnrollment]]"
          - "[[BenefitPlan]]"
        business_rules:
          - "Cost per employee analysis"
          - "Enrollment trends"
          - "Plan utilization rates"
          - "Year-over-year comparison"

      - id: FR-TR-035
        name: "Rewards ROI Dashboard"
        description: "As an HR executive, I want to measure ROI of total rewards programs so that investment decisions are data-driven"
        priority: COULD
        differentiation: INNOVATION
        stability: MEDIUM
        type: UI/UX
        complexity: HIGH
        risk: medium
        competitor_reference: "Limited (emerging)"
        source_ref: "Strategic HR practice"
        related_entities:
          - "[[TotalRewardsStatement]]"
          - "[[RecognitionAward]]"
        business_rules:
          - "Engagement correlation"
          - "Retention impact analysis"
          - "Program participation rates"
          - "Cost per outcome metrics"

  # ========================================
  # CAPABILITY 6: VIETNAM COMPLIANCE
  # ========================================
  - name: "Vietnam Regulatory Compliance"
    subdomain_type: COMPLIANCE
    description: "Vietnam-specific labor law and social insurance compliance features required by regulation"
    features:
      - id: FR-TR-036
        name: "Regional Minimum Wage Management"
        description: "As an HR admin, I want to configure regional minimum wages so that salary assignments are validated against legal minimums"
        priority: MUST
        differentiation: COMPLIANCE
        stability: LOW
        type: Validation
        complexity: MEDIUM
        risk: high
        competitor_reference: "Vietnam-specific"
        source_ref: "Vietnam Labor Code 2019, Regional wage decrees"
        related_entities:
          - "[[MinimumWageRegion]]"
          - "[[CompensationAssignment]]"
        business_rules:
          - "4 regional wage levels"
          - "7% premium for trained workers"
          - "Annual update effective date"
          - "Validation on salary assignment"

      - id: FR-TR-037
        name: "Social Insurance Calculation"
        description: "As an HR admin, I want SI contributions calculated automatically so that BHXH/BHYT/BHTN deductions are correct"
        priority: MUST
        differentiation: COMPLIANCE
        stability: LOW
        type: Calculation
        complexity: HIGH
        risk: high
        competitor_reference: "Vietnam-specific (local vendors)"
        source_ref: "Vietnam Social Insurance Law 2024"
        decision_ref: "ADR-TR-003"
        related_entities:
          - "[[SocialInsuranceRate]]"
          - "[[CompensationAssignment]]"
        business_rules:
          - "BHXH: 17.5% employer + 8% employee"
          - "BHYT: 3% employer + 1.5% employee"
          - "BHTN: 1% employer + 1% employee"
          - "Salary cap: 20x statutory minimum wage"
          - "Effective dating for rate changes"

      - id: FR-TR-038
        name: "Overtime Pay Calculation"
        description: "As an HR admin, I want overtime pay calculated per labor law so that employees receive correct overtime compensation"
        priority: MUST
        differentiation: COMPLIANCE
        stability: HIGH
        type: Calculation
        complexity: MEDIUM
        risk: high
        competitor_reference: "Vietnam-specific"
        source_ref: "Vietnam Labor Code 2019, Art. 98"
        related_entities:
          - "[[CompensationComponent]]"
          - "[[TimeAndAbsence.OvertimeRecord]]"
        business_rules:
          - "Normal day: 150% of hourly wage"
          - "Weekly rest day: 200% of hourly wage"
          - "Holiday: 300% of hourly wage"
          - "Night shift premium: 30% additional"

      - id: FR-TR-039
        name: "13th Month Salary Support"
        description: "As an HR admin, I want to manage 13th month salary bonuses so that employees receive this common benefit correctly"
        priority: MUST
        differentiation: COMPLIANCE
        stability: HIGH
        type: Calculation
        complexity: MEDIUM
        risk: medium
        competitor_reference: "Vietnam market practice"
        source_ref: "Common practice in Vietnam"
        related_entities:
          - "[[BonusPlan]]"
          - "[[CompensationComponent]]"
        business_rules:
          - "Pro-rata calculation for partial year"
          - "Timing: before Tet holiday"
          - "Included in gross income for tax"
          - "Optional: performance multiplier"

      - id: FR-TR-040
        name: "Statutory Benefits Compliance"
        description: "As an HR admin, I want statutory benefits tracked so that minimum requirements are met per Vietnam law"
        priority: MUST
        differentiation: COMPLIANCE
        stability: HIGH
        type: Validation
        complexity: MEDIUM
        risk: high
        competitor_reference: "Vietnam-specific"
        source_ref: "Vietnam Labor Code 2019"
        related_entities:
          - "[[BenefitProgram]]"
          - "[[BenefitEnrollment]]"
        business_rules:
          - "Annual leave: 12 days minimum"
          - "Maternity leave: 6 months"
          - "Sickness leave: per SI contribution years"
          - "Marriage/funeral leave: 3 days"
---

# Feature Catalog: Total Rewards (TR)

> **Note**: YAML above is for AI processing. Tables and diagrams below for human reading.

---

## Feature Mindmap

```mermaid
mindmap
  root((Total Rewards))
    Compensation [CORE]
      FR-001 Comp Planning [Parity]
      FR-002 Salary Structure [Parity]
      FR-003 Base Pay [Parity]
      FR-004 Variable Pay [Parity]
      FR-005 Merit Increase [Parity]
      FR-006 Equity/Stock [Innovation]
      FR-007 Allowances [Parity]
      FR-008 Global Comp [Parity]
      FR-009 Review Workflow [Parity]
    Benefits [CORE]
      FR-010 Program Setup [Parity]
      FR-011 Plan Config [Parity]
      FR-012 Eligibility Rules [Parity]
      FR-013 Open Enrollment [Parity]
      FR-014 Life Events [Parity]
      FR-015 Self-Service [Parity]
      FR-016 Dependents [Parity]
      FR-017 Flex Credits [Innovation]
      FR-018 Carrier Integration [Parity]
    Recognition [CORE]
      FR-019 Program Setup [Parity]
      FR-020 Peer-to-Peer [Innovation]
      FR-021 Manager Awards [Parity]
      FR-022 Milestones [Innovation]
      FR-023 Spot Awards [Parity]
      FR-024 Points System [Innovation]
      FR-025 Rewards Catalog [Innovation]
      FR-026 Social Feed [Innovation]
    Well-being [GENERIC]
      FR-027 Wellness Integration [Parity]
      FR-028 Mental Health [Parity]
      FR-029 Financial Wellness [Parity]
      FR-030 Work-Life Balance [Parity]
    Analytics [CORE]
      FR-031 Total Comp Statement [Parity]
      FR-032 Pay Equity [Innovation]
      FR-033 Benchmarking [Innovation]
      FR-034 Benefits Cost [Parity]
      FR-035 Rewards ROI [Innovation]
    VN Compliance [COMPLIANCE]
      FR-036 Min Wage [Compliance]
      FR-037 SI Calculation [Compliance]
      FR-038 Overtime Pay [Compliance]
      FR-039 13th Month [Compliance]
      FR-040 Statutory Benefits [Compliance]
```

---

## Capability 1: Compensation Management

**Type:** CORE Domain  
Complete compensation planning, structure management, and salary administration for competitive and equitable pay

| ID | Feature | Priority | Differentiation | Complexity | Competitor |
|----|---------|----------|-----------------|------------|------------|
| FR-TR-001 | **Compensation Planning & Budgeting** | MUST | Parity | HIGH | Oracle, SAP, Workday (3/3) |
| FR-TR-002 | **Salary Structure Management** | MUST | Parity | MEDIUM | All vendors (4/4) |
| FR-TR-003 | **Base Pay Management** | MUST | Parity | MEDIUM | All vendors (4/4) |
| FR-TR-004 | **Variable Pay & Bonus Management** | MUST | Parity | HIGH | All vendors (4/4) |
| FR-TR-005 | **Merit Increase Processing** | MUST | Parity | HIGH | Oracle, SAP, Workday (3/4) |
| FR-TR-006 | **Equity & Stock Compensation** | SHOULD | Innovation | HIGH | Oracle, Workday (2/4) |
| FR-TR-007 | **Allowance Management** | MUST | Parity | MEDIUM | Oracle, SAP (2/4) |
| FR-TR-008 | **Global Compensation Support** | SHOULD | Parity | HIGH | Oracle, SAP, Workday (3/4) |
| FR-TR-009 | **Compensation Review Workflow** | MUST | Parity | HIGH | Oracle, SAP, Workday (3/4) |

---

## Capability 2: Benefits Administration

**Type:** CORE Domain  
Comprehensive benefits program management from plan configuration to employee enrollment and carrier integration

| ID | Feature | Priority | Differentiation | Complexity | Competitor |
|----|---------|----------|-----------------|------------|------------|
| FR-TR-010 | **Benefits Program Definition** | MUST | Parity | MEDIUM | All vendors (4/4) |
| FR-TR-011 | **Benefits Plan Configuration** | MUST | Parity | HIGH | All vendors (4/4) |
| FR-TR-012 | **Eligibility Rules Engine** | MUST | Parity | HIGH | Oracle, SAP, Workday (3/4) |
| FR-TR-013 | **Open Enrollment Management** | MUST | Parity | HIGH | All vendors (4/4) |
| FR-TR-014 | **Life Event Processing** | MUST | Parity | HIGH | Oracle, Workday (2/4) |
| FR-TR-015 | **Benefits Self-Service Enrollment** | MUST | Parity | MEDIUM | All vendors (4/4) |
| FR-TR-016 | **Dependent & Beneficiary Management** | MUST | Parity | MEDIUM | All vendors (4/4) |
| FR-TR-017 | **Flex Credit Programs** | SHOULD | Innovation | HIGH | Workday, Microsoft (2/4) |
| FR-TR-018 | **Benefits Carrier Integration** | SHOULD | Parity | HIGH | Oracle, SAP, Workday (3/4) |

---

## Capability 3: Recognition & Rewards

**Type:** CORE Domain (Differentiator)  
Employee recognition programs including peer-to-peer kudos, manager awards, milestone celebrations, and rewards redemption

| ID | Feature | Priority | Differentiation | Complexity | Competitor |
|----|---------|----------|-----------------|------------|------------|
| FR-TR-019 | **Recognition Program Setup** | MUST | Parity | MEDIUM | Oracle Celebrate, SAP Spot (2/4) |
| FR-TR-020 | **Peer-to-Peer Recognition** | MUST | Innovation | MEDIUM | Oracle, SAP (2/4) |
| FR-TR-021 | **Manager Recognition Awards** | MUST | Parity | MEDIUM | Oracle, SAP, Workday (3/4) |
| FR-TR-022 | **Milestone Celebrations** | SHOULD | Innovation | MEDIUM | Oracle Celebrate (1/4) |
| FR-TR-023 | **Spot Awards** | MUST | Parity | MEDIUM | Oracle, SAP (2/4) |
| FR-TR-024 | **Points-Based Rewards** | SHOULD | Innovation | HIGH | Third-party focus |
| FR-TR-025 | **Rewards Catalog & Redemption** | SHOULD | Innovation | HIGH | Third-party focus |
| FR-TR-026 | **Social Recognition Feed** | SHOULD | Innovation | MEDIUM | Oracle Celebrate (1/4) |

---

## Capability 4: Well-being Programs

**Type:** GENERIC Subdomain  
Employee wellness and well-being support including physical, mental, and financial health integrations

| ID | Feature | Priority | Differentiation | Complexity | Competitor |
|----|---------|----------|-----------------|------------|------------|
| FR-TR-027 | **Wellness Program Integration** | COULD | Parity | MEDIUM | Oracle, SAP (2/4) |
| FR-TR-028 | **Mental Health Resources** | COULD | Parity | LOW | Third-party focus |
| FR-TR-029 | **Financial Wellness Tools** | COULD | Parity | LOW | Oracle (1/4) |
| FR-TR-030 | **Work-Life Balance Features** | COULD | Parity | LOW | Indirect support |

---

## Capability 5: Total Rewards Analytics

**Type:** CORE Domain  
Comprehensive analytics for compensation statements, pay equity, benchmarking, and ROI measurement

| ID | Feature | Priority | Differentiation | Complexity | Competitor |
|----|---------|----------|-----------------|------------|------------|
| FR-TR-031 | **Total Compensation Statements** | MUST | Parity | HIGH | Oracle, SAP, Workday (3/4) |
| FR-TR-032 | **Pay Equity Analytics** | MUST | Innovation | HIGH | Workday, Oracle (2/4) |
| FR-TR-033 | **Compensation Benchmarking** | SHOULD | Innovation | HIGH | Oracle, Workday (2/4) |
| FR-TR-034 | **Benefits Cost Analysis** | SHOULD | Parity | MEDIUM | Oracle, SAP (2/4) |
| FR-TR-035 | **Rewards ROI Dashboard** | COULD | Innovation | HIGH | Emerging |

---

## Capability 6: Vietnam Regulatory Compliance

**Type:** COMPLIANCE (Mandatory)  
Vietnam-specific labor law and social insurance compliance features required by regulation

| ID | Feature | Priority | Differentiation | Legal Source | Risk |
|----|---------|----------|-----------------|--------------|------|
| FR-TR-036 | **Regional Minimum Wage Management** | MUST | Compliance | Labor Code 2019 | HIGH |
| FR-TR-037 | **Social Insurance Calculation** | MUST | Compliance | SI Law 2024 | HIGH |
| FR-TR-038 | **Overtime Pay Calculation** | MUST | Compliance | Labor Code Art. 98 | HIGH |
| FR-TR-039 | **13th Month Salary Support** | MUST | Compliance | Market practice | MEDIUM |
| FR-TR-040 | **Statutory Benefits Compliance** | MUST | Compliance | Labor Code 2019 | HIGH |

---

## Differentiation Analysis

### Parity Features (Table Stakes)

| Count | Features | Strategy |
|-------|----------|----------|
| 22 | Core compensation, benefits enrollment, basic recognition | Match industry standard, don't over-invest |

**Examples:** Salary Structure, Base Pay, Open Enrollment, Manager Awards

### Innovation Features (USP)

| Count | Features | Strategy |
|-------|----------|----------|
| 12 | Peer recognition, social feed, points system, pay equity | Invest heavily - these are differentiators |

**Examples:** 
- FR-TR-020: Peer-to-Peer Recognition
- FR-TR-026: Social Recognition Feed
- FR-TR-032: Pay Equity Analytics

### Compliance Features (Mandatory)

| Count | Features | Strategy |
|-------|----------|----------|
| 5 | Vietnam regulations | Must-have, no shortcuts |

**Examples:** SI Calculation, Minimum Wage, Overtime Pay

---

## Complexity Distribution

| Complexity | Count | Features | Architecture Recommendation |
|------------|-------|----------|---------------------------|
| **HIGH** | 16 | Planning, Eligibility, SI Calc, Pay Equity | Dedicated team, thorough testing, rule engines |
| **MEDIUM** | 17 | Structures, Awards, Milestones | Standard development, configurable |
| **LOW** | 7 | Reference data, Wellness links | Quick wins, out-of-box patterns |

---

## Priority Summary

| Priority | Count | Description |
|----------|-------|-------------|
| **MUST** | 28 | Core features required for MVP |
| **SHOULD** | 9 | Important features for competitive parity |
| **COULD** | 4 | Nice-to-haves for future phases |

---

## ADR Cross-Reference

| Feature | Decision | Rationale Summary |
|---------|----------|-------------------|
| FR-TR-019, FR-TR-025 | ADR-TR-001 | Build recognition natively, integrate reward catalog |
| FR-TR-031 | ADR-TR-002 | On-demand generation with PDF caching |
| FR-TR-037 | ADR-TR-003 | Internal SI engine with versioned rules |
| FR-TR-033 | ADR-TR-004 | Integrate external benchmarking data providers |
| FR-TR-018 | ADR-TR-005 | Standard API connectors with file fallback |
