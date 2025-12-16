# Total Rewards (TR) Module - Ontology

**Version**: 2.0  
**Last Updated**: 2025-12-15  
**Purpose**: Entity definitions and data model for the Total Rewards module

---

## 📚 Documents

### Core Ontology Files

| Document | Description | Entities | Status |
|----------|-------------|----------|--------|
| [tr-ontology.yaml](./tr-ontology.yaml) | Complete TR ontology | 70 entities across 11 sub-modules | ✅ Complete |

### Glossary Documents

| Document | Description | Entities | Status |
|----------|-------------|----------|--------|
| [glossary-index.md](./glossary-index.md) | Master index of all glossaries | All 70 entities | ✅ Complete |
| [glossary-core-compensation.md](./glossary-core-compensation.md) | Fixed pay, grades, ranges | 14 | ✅ Complete |
| [glossary-calculation-rules.md](./glossary-calculation-rules.md) | Tax, SI, overtime, proration | 6 | ✅ Complete |
| [glossary-variable-pay.md](./glossary-variable-pay.md) | Bonuses, equity, commissions | 9 | ✅ Complete |
| [glossary-benefits.md](./glossary-benefits.md) | Health, retirement, wellness | 14 | ✅ Complete |
| [glossary-recognition.md](./glossary-recognition.md) | Points, perks, awards | 7 | ✅ Complete |
| [glossary-offer-management.md](./glossary-offer-management.md) | Offer packages, e-signature | 5 | ✅ Complete |
| [glossary-tr-statement.md](./glossary-tr-statement.md) | Total rewards statements | 4 | ✅ Complete |
| [glossary-deductions.md](./glossary-deductions.md) | Loans, garnishments, advances | 4 | ✅ Complete |
| [glossary-tax-withholding.md](./glossary-tax-withholding.md) | Tax elections, declarations | 3 | ✅ Complete |
| [glossary-taxable-bridge.md](./glossary-taxable-bridge.md) | Payroll integration bridge | 1 | ✅ Complete |
| [glossary-audit.md](./glossary-audit.md) | Audit trail for compliance | 1 | ✅ Complete |

### Planning & Review Documents

| Document | Description | Status |
|----------|-------------|--------|
| [TR-GLOSSARY-PLAN.md](../TR-GLOSSARY-PLAN.md) | Glossary documentation plan | ✅ Complete |
| [ONTOLOGY-SIZE-ANALYSIS.md](../ONTOLOGY-SIZE-ANALYSIS.md) | Size and complexity analysis | ✅ Complete |
| [ONTOLOGY-GAPS-RESOLUTION.md](../ONTOLOGY-GAPS-RESOLUTION.md) | Gap analysis and resolution | ✅ Complete |

---

## 🎯 Quick Start

**For Developers**: Start with [tr-ontology.yaml](./tr-ontology.yaml) - complete entity definitions with attributes, relationships, and business rules

**For Business Analysts**: Read [glossary-index.md](./glossary-index.md) for term definitions, then explore specific glossaries by domain

**For Architects**: Review planning documents for design decisions and gap analysis

---

## 📖 Entity Categories

### 1. Core Compensation (14 entities)
- **Salary Structure**: SalaryBasis, PayComponentDefinition, SalaryBasisComponentMap
- **Dependencies**: ComponentDependency, ProrationRule
- **Grades & Ranges**: GradeVersion, GradeLadder, GradeLadderGrade, GradeLadderStep, PayRange
- **Compensation Management**: CompensationPlan, CompensationCycle, CompensationAdjustment
- **History & Budget**: EmployeeCompensationSnapshot, SalaryHistory, BudgetAllocation

### 2. Calculation Rules (6 entities)
- **Rule Engine**: CalculationRuleDefinition, ComponentCalculationRule, BasisCalculationRule
- **Performance**: TaxCalculationCache
- **Configuration**: CountryConfiguration, HolidayCalendar

### 3. Variable Pay (9 entities)
- **Bonuses**: BonusPlan, BonusCycle, BonusPool, BonusAllocation
- **Equity**: EquityGrant, EquityVestingEvent, EquityTransaction
- **Commissions**: CommissionPlan, CommissionTier, CommissionTransaction

### 4. Benefits (14 entities)
- **Plans**: BenefitPlan, BenefitOption
- **Eligibility**: EligibilityProfile, PlanEligibility
- **Enrollment**: Enrollment, EnrollmentPeriod, LifeEvent
- **Dependents**: EmployeeDependent, BenefitBeneficiary
- **Claims**: ReimbursementRequest, ReimbursementLine, HealthcareClaimHeader, HealthcareClaimLine

### 5. Recognition (7 entities)
- **Configuration**: RecognitionEventType, PerkCategory, PerkCatalog
- **Accounts**: PointAccount
- **Transactions**: RecognitionEvent, RewardPointTransaction, PerkRedemption

### 6. Offer Management (5 entities)
- **Templates**: OfferTemplate, OfferTemplateEvent
- **Offers**: OfferPackage, OfferEvent, OfferAcceptance

### 7. Total Rewards Statement (4 entities)
- **Configuration**: StatementConfiguration, StatementSection
- **Generation**: StatementJob, StatementLine

### 8. Deductions (4 entities)
- **Configuration**: DeductionType
- **Employee Deductions**: EmployeeDeduction, DeductionSchedule, DeductionTransaction

### 9. Tax Withholding (3 entities)
- **Management**: TaxWithholding, TaxDeclaration, TaxAdjustment

### 10. Taxable Bridge (1 entity)
- **Integration**: TaxableItem

### 11. Audit (1 entity)
- **Compliance**: AuditLog

---

## 🌟 Key Features (v2.0)

### Enterprise Best Practices
- ✅ **SCD Type 2 Versioning** - Historical tracking for grades (GradeVersion)
- ✅ **Multi-Country Support** - Country-specific tax, SI, and holiday rules
- ✅ **Component-Based Architecture** - Flexible pay component composition
- ✅ **Calculation Engine** - Rule-based tax, SI, overtime, proration
- ✅ **Comprehensive Audit** - Immutable audit trail with 7-year retention

### Advanced Patterns
- ✅ **Flexible Salary Basis** - Support for hourly, daily, weekly, monthly, annual
- ✅ **Multi-Ladder Grades** - Management, Technical, Specialist, Sales, Executive tracks
- ✅ **Pay Range Scopes** - Global, Legal Entity, Business Unit, Position levels
- ✅ **Equity Management** - RSU, Options, ESPP with vesting schedules
- ✅ **Benefits Enrollment** - Life events, eligibility, dependents, beneficiaries
- ✅ **Recognition Programs** - Point-based system with FIFO expiration
- ✅ **Offer Packages** - Template versioning, e-signature, counter-offers

### Multi-Country Compliance
- ✅ **Tax Calculation** - Country-specific tax brackets and rules
- ✅ **Social Insurance** - SI calculation with caps and exemptions
- ✅ **Holiday Calendars** - Country and region-specific holidays
- ✅ **Currency Support** - Multi-currency with ISO 4217 codes
- ✅ **Legal References** - Compliance documentation for all rules

### Integration Points
- ✅ **Core Module** - Employee, Assignment, LegalEntity, Worker
- ✅ **Payroll Module** - TaxableItem bridge for payroll processing
- ✅ **Performance Management** - Performance ratings for bonus allocation
- ✅ **Time & Attendance** - Overtime calculations
- ✅ **Talent Acquisition** - Offer management integration

---

## 📊 Module Statistics

| Metric | Value |
|--------|-------|
| Total Entities | 70 |
| Sub-modules | 11 |
| Glossary Files | 12 |
| Lines of YAML | 6,266 |
| Ontology Size | 183 KB |
| Documentation Coverage | 100% |

### Entity Distribution

| Sub-module | Entities | % of Total |
|------------|----------|------------|
| Core Compensation | 14 | 20% |
| Benefits | 14 | 20% |
| Variable Pay | 9 | 13% |
| Recognition | 7 | 10% |
| Calculation Rules | 6 | 9% |
| Offer Management | 5 | 7% |
| Deductions | 4 | 6% |
| TR Statement | 4 | 6% |
| Tax Withholding | 3 | 4% |
| Taxable Bridge | 1 | 1% |
| Audit | 1 | 1% |

---

## 🔗 Related Documentation

- [TR Concept Guides](../01-concept/) - Conceptual documentation and guides
- [TR Specification](../02-spec/) - Detailed requirements and business rules
- [TR Design](../03-design/) - Database schema (DBML) and API design
- [Module Documentation Standards](../../MODULE-DOCUMENTATION-STANDARDS.md) - Documentation guidelines

---

## 📋 Documentation Compliance

### Ontology File (tr-ontology.yaml)
- ✅ Module metadata (name, code, description)
- ✅ Sub-module structure (11 sub-modules)
- ✅ Entity definitions (70 entities)
- ✅ Attribute specifications (type, required, constraints)
- ✅ Relationship mappings (cardinality, descriptions)
- ✅ Business rules
- ✅ Indexes and constraints
- ✅ Audit metadata (SCD Type 2 where applicable)

### Glossary Files
- ✅ Entity definitions with purpose
- ✅ Key characteristics
- ✅ Complete attribute tables
- ✅ Relationship mappings
- ✅ Business rules with IDs
- ✅ Real-world examples (YAML format)
- ✅ Best practices (DO/DON'T)
- ✅ Related entities
- ✅ Integration points

---

## 🎓 Learning Path

### For New Developers
1. Start with [glossary-index.md](./glossary-index.md) - Get overview of all entities
2. Read [glossary-core-compensation.md](./glossary-core-compensation.md) - Understand foundation
3. Review [tr-ontology.yaml](./tr-ontology.yaml) - See complete technical specs
4. Explore concept guides in [../01-concept/](../01-concept/) - Learn business context

### For Business Analysts
1. Read [glossary-index.md](./glossary-index.md) - Navigation guide
2. Explore domain-specific glossaries based on your area
3. Review examples in each glossary
4. Check concept guides for detailed workflows

### For Architects
1. Review [tr-ontology.yaml](./tr-ontology.yaml) - Complete data model
2. Study [ONTOLOGY-SIZE-ANALYSIS.md](../ONTOLOGY-SIZE-ANALYSIS.md) - Complexity analysis
3. Check [ONTOLOGY-GAPS-RESOLUTION.md](../ONTOLOGY-GAPS-RESOLUTION.md) - Design decisions
4. Review integration points across modules

---

## 🚀 Next Steps

### Completed ✅
- ✅ Ontology definition (tr-ontology.yaml)
- ✅ All 11 glossary files
- ✅ Glossary index
- ✅ Planning documents

### In Progress 🔄
- 🔄 Concept guides (../01-concept/)
- 🔄 Specification documents (../02-spec/)

### Planned 📋
- 📋 Database design (../03-design/)
- 📋 API specifications (../04-api/)
- 📋 UI mockups (../05-ui/)
- 📋 Test cases (../06-tests/)

---

## 📞 Support

For questions or clarifications about the TR ontology:
- Review the [glossary-index.md](./glossary-index.md) for quick reference
- Check concept guides for detailed explanations
- Consult the ontology YAML for technical specifications
- Refer to MODULE-DOCUMENTATION-STANDARDS.md for documentation guidelines

---

**Maintained by**: xTalent Documentation Team  
**Last Review**: 2025-12-15  
**Status**: ✅ Complete and Ready for Development
