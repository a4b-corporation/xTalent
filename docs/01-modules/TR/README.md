# Total Rewards (TR) Module

> Comprehensive compensation and benefits management

## 📋 Overview

The Total Rewards module manages all aspects of employee compensation and benefits:
- **Compensation**: Base pay, bonuses, allowances, commissions
- **Benefits**: Health insurance, retirement plans, perks
- **Grades**: Salary grades and compensation structures
- **Equity**: Stock options and equity compensation

## 📁 Documentation Structure

```
TR/
├── 00-ontology/       # Domain entities (CompensationPlan, Grade, Benefit, etc.)
├── 01-concept/        # What Total Rewards does and why
├── 02-spec/           # Detailed specifications
├── 03-design/         # Data model and system design
├── 04-api/            # API specifications
├── 05-ui/             # UI specs and mockups
├── 06-tests/          # Test scenarios
└── 07-impl-notes/     # Technical decisions
```

## 🎯 Key Features

### Compensation Management
- Compensation plan definition
- Component configuration (salary, bonus, allowance)
- Worker compensation assignment
- Compensation history tracking
- Salary review and adjustment

### Benefits Administration
- Benefit plan configuration
- Enrollment management
- Eligibility rules
- Dependent management
- Benefits cost calculation

### Grade Management
- Grade structure definition
- Salary ranges (min, mid, max)
- Grade progression rules
- Job-to-grade mapping

### Equity Management
- Stock option grants
- Vesting schedules
- Exercise tracking
- Equity value calculation

## 🔗 Integration Points

- **CO (Core HR)**: Uses worker, job, and position data
- **PR (Payroll)**: Provides compensation data for payroll processing
- **TA (Time & Absence)**: Receives overtime data for variable pay
- **External Systems**: Integration with benefits providers

## 📚 Key Entities

| Entity | Description |
|--------|-------------|
| **CompensationPlan** | Compensation structure definition |
| **CompensationComponent** | Individual pay component |
| **CompensationAssignment** | Worker compensation assignment |
| **Grade** | Compensation grade/level |
| **GradeStep** | Step within a grade |
| **BenefitPlan** | Benefit offering definition |
| **BenefitEnrollment** | Worker benefit enrollment |
| **EquityGrant** | Stock/equity grant |

## 🎨 Sub-modules

### Compensation
- Base pay management
- Variable pay (bonus, commission)
- Allowances
- One-time payments
- Compensation review cycles

### Benefits
- Health insurance
- Retirement plans
- Life insurance
- Flexible benefits
- Wellness programs

### Grades
- Grade structure
- Salary ranges
- Progression rules
- Market pricing

### Equity
- Stock options
- RSUs (Restricted Stock Units)
- ESPP (Employee Stock Purchase Plan)
- Vesting management

## 🚀 Getting Started

1. **Understand the Domain**: Read `00-ontology/` and `01-concept/`
2. **Review Specifications**: Check `02-spec/` for detailed requirements
3. **Explore API**: See `04-api/` for API documentation
4. **View UI**: Check `05-ui/` for UI specifications

## 📖 Related Documents

- [Global Ontology](../../00-global/ontology/total-rewards-core.yaml)
- [Domain Glossary](../../00-global/glossary/domain-glossary.md)
- [SpecKit Guide](../../00-global/speckit/spec-structure.md)

## 💡 Common Scenarios

### HR Assigns Compensation
1. HR selects worker
2. Chooses compensation plan and components
3. Enters amounts and effective dates
4. System validates against grade ranges
5. Creates compensation assignment
6. Notifies payroll of changes

### Employee Views Total Compensation
1. Employee accesses compensation statement
2. Views all compensation components
3. Sees benefits value
4. Reviews equity grants
5. Can download statement

### Manager Proposes Salary Increase
1. Manager initiates salary review
2. Views current compensation and grade
3. Proposes new salary within grade range
4. System calculates increase percentage
5. Submits for approval
6. HR approves and processes

### HR Configures Benefit Plan
1. HR creates benefit plan
2. Defines eligibility rules
3. Sets up cost sharing (employee/employer)
4. Configures enrollment periods
5. Assigns to worker groups
6. Opens enrollment

---

**Module Owner**: [Team/Person]  
**Last Updated**: 2025-11-28
