# Payroll Module - Research Report

> **Module**: Payroll (PR)  
> **Phase**: Pre-Reality (Step 1)  
> **Date**: 2026-03-31  
> **Status**: Complete

---

## 1. Executive Summary

This research report synthesizes findings from existing reference documentation and industry analysis for the Payroll (PR) module within xTalent HCM solution. The module is designed as a **configuration-focused** system for managing payroll structures, elements, statutory rules, and integrations - with the actual payroll calculation engine being out of scope.

### Key Findings

| Finding | Significance | Source |
|---------|--------------|--------|
| Configuration-first design | Module handles configuration, not runtime calculation | PR-concept-overview.md |
| Vietnam-specific focus | BHXH, BHYT, BHTN, PIT with specific rates and ceilings | PR-conceptual-guide.md |
| Multi-integration architecture | CO, TA, TR, Finance/GL, Banking integrations | PR-concept-overview.md |
| SCD-2 versioning pattern | Historical tracking for elements and rules | PR-conceptual-guide.md |
| Entity classification model | AGGREGATE_ROOT, ENTITY, REFERENCE_DATA taxonomy | PR-concept-overview.md |

---

## 2. Reference Document Analysis

### 2.1 Documents Reviewed

| Document | Status | Content Summary |
|----------|--------|-----------------|
| `PR-concept-overview.md` | Available | Domain model, entity relationships, architecture overview |
| `PR-conceptual-guide.md` | Available | Detailed conceptual guide (660 lines) covering all major concepts |
| `README.md` | Available | Module overview, key features, integration points |

### 2.2 Gap Analysis

| Gap | Priority | Action Required |
|-----|----------|-----------------|
| No ontology files exist | HIGH | Create entity definitions, glossary |
| No specification documents | HIGH | Define behavioral specifications |
| No data model (DBML) | HIGH | Design database schema |
| No API specifications | MEDIUM | Define headless APIs |
| No UI specifications | MEDIUM | Define screen layouts |
| No test scenarios | MEDIUM | Create acceptance criteria |

---

## 3. Domain Research

### 3.1 Core Domain Concepts

#### Pay Structure Hierarchy

```
PayFrequency (Reference)
    └── PayCalendar (Aggregate Root)
            └── PayGroup (Entity)
                    └── Employee Assignment
```

The structure follows a clear hierarchy:
1. **PayFrequency**: Reference data defining pay cycles (WEEKLY, BIWEEKLY, MONTHLY, etc.)
2. **PayCalendar**: Aggregate root managing periods, cut-offs, pay dates per legal entity
3. **PayGroup**: Entity grouping employees with same payroll characteristics
4. **PayProfile**: Configuration bundle containing elements, rules, policies

#### Pay Element Classification

| Classification | Gross Impact | Net Impact | Examples |
|----------------|--------------|------------|----------|
| EARNING | + (increase) | - | Basic Salary, OT, Bonus |
| DEDUCTION | - | - (decrease) | BHXH EE, Loan |
| TAX | - | - (decrease) | PIT |
| EMPLOYER_CONTRIBUTION | - | - | BHXH ER |
| INFORMATIONAL | - | - | Working Days |

#### Statutory Rules (Vietnam-Specific)

| Rule | Employee Rate | Employer Rate | Ceiling (VND) |
|------|---------------|---------------|---------------|
| BHXH (Social Insurance) | 8% | 17.5% | 36,000,000 |
| BHYT (Health Insurance) | 1.5% | 3% | 36,000,000 |
| BHTN (Unemployment) | 1% | 1% | 36,000,000 |
| **Total** | **10.5%** | **21.5%** | - |

#### Personal Income Tax (PIT) Brackets

| Bracket | Taxable Income (VND) | Tax Rate |
|---------|----------------------|----------|
| 1 | 0 - 5,000,000 | 5% |
| 2 | 5,000,001 - 10,000,000 | 10% |
| 3 | 10,000,001 - 18,000,000 | 15% |
| 4 | 18,000,001 - 32,000,000 | 20% |
| 5 | 32,000,001 - 52,000,000 | 25% |
| 6 | 52,000,001 - 80,000,000 | 30% |
| 7 | Above 80,000,000 | 35% |

**Exemptions:**
- Personal: 11,000,000 VND/month
- Dependent: 4,400,000 VND/person/month

### 3.2 Calculation Priority Sequence

```
1. Basic Salary → 2. Allowances → 3. Overtime
       ↓
4. Gross Subtotal
       ↓
5. Pre-tax Deductions (BHXH, BHYT, BHTN)
       ↓
6. Taxable Income
       ↓
7. Tax Calculation (PIT)
       ↓
8. Post-tax Deductions (Loans, Union)
       ↓
9. Net Pay
```

---

## 4. Integration Architecture Research

### 4.1 Upstream Dependencies (Inbound)

| System | Data Provided | Integration Pattern |
|--------|---------------|---------------------|
| Core HR (CO) | Worker data, Assignments, Legal Entity | API (Real-time) |
| Time & Absence (TA) | Attendance, Leave, Overtime hours | API/File (Batch) |
| Total Rewards (TR) | Compensation, Benefits enrollment | API (Real-time) |

### 4.2 Downstream Consumers (Outbound)

| System | Data Consumed | Integration Pattern |
|--------|---------------|---------------------|
| Finance/GL | Journal entries, Cost allocation | API/File (Batch) |
| Banking | Payment instructions, Bank files | File (Batch) |
| Tax Authorities | Tax reports, Filings | File/API |

### 4.3 Integration Patterns

```
[TA] --(Time Data)--> [PR] --(GL Entries)--> [Finance]
[CO] --(Worker Data)--> [PR] --(Bank Files)--> [Banking]
[TR] --(Compensation)--> [PR] --(Tax Reports)--> [Tax Authority]
```

---

## 5. Entity Classification Model

### 5.1 Classification Taxonomy

| Classification | Description | Lifecycle | Examples |
|----------------|-------------|-----------|----------|
| **AGGREGATE_ROOT** | Primary entities with independent lifecycle | Full CRUD + versioning | PayCalendar, PayProfile, PayElement, StatutoryRule, PayrollInterface |
| **ENTITY** | Dependent entities, owned by aggregate | CRUD within aggregate context | PayGroup, PayFormula, PayBalanceDefinition, DeductionPolicy, ValidationRule, CostingRule, GLMappingPolicy |
| **REFERENCE_DATA** | Lookup tables, rarely changed | Admin-managed | PayFrequency, PayAdjustReason, BankTemplate |

### 5.2 SCD-2 Versioning

Entities requiring historical tracking implement Slowly Changing Dimension Type 2:

| Field | Purpose |
|-------|---------|
| effectiveStartDate | Version start date |
| effectiveEndDate | Version end date (null = current) |
| isCurrentFlag | Quick filter for current version |

---

## 6. Industry Best Practices Research

### 6.1 Configuration Management

**Best Practice**: Separate configuration from calculation
- Configuration module handles setup, rules, policies
- Calculation engine consumes configuration at runtime
- This enables versioning, auditing, and compliance

**Application**: PR module follows this pattern - configuration only, no runtime calculation.

### 6.2 Multi-Tenancy Patterns

**Pattern**: Market-based configuration hierarchy
```
Global Template
    └── Market Template (VN, SG, US)
            └── Legal Entity Configuration
                    └── Pay Group Overrides
```

**Application**: PayProfile supports inheritance hierarchy for multi-market deployments.

### 6.3 Compliance Tracking

**Best Practice**: Versioned statutory rules
- Track effective dates for all statutory changes
- Maintain historical rules for retroactive calculations
- Enable audit trail for compliance reporting

**Application**: StatutoryRule entity with SCD-2 versioning addresses this.

---

## 7. Technical Considerations

### 7.1 Data Model Patterns

| Pattern | Application | Entities |
|---------|--------------|----------|
| Aggregate Root | Root entities with child collections | PayCalendar, PayProfile, PayElement |
| Value Object | Immutable, no identity | PayFormula parameters |
| SCD-2 Versioning | Historical tracking | StatutoryRule, PayElement |
| Soft Delete | Audit trail preservation | All entities |

### 7.2 Formula Engine Requirements

Based on concept analysis, the formula engine must support:

| Formula Type | Use Case | Example |
|--------------|----------|---------|
| Percentage | Rate-based calculations | `base * 0.08` |
| Progressive | Tax brackets | PIT calculation |
| Conditional | If-then logic | OT multipliers |
| Lookup | Table reference | Statutory rates |

### 7.3 Validation Requirements

| Validation Type | Level | Behavior |
|-----------------|-------|----------|
| Field | Single attribute | `gross_amount >= 0` |
| Cross-field | Multiple attributes | `net <= gross` |
| Business Rule | Entity scope | Date overlaps, rule conflicts |
| Cross-entity | Multiple entities | Element-rule compatibility |

---

## 8. Competitive Landscape

### 8.1 HCM Payroll Solutions Comparison

| Feature | SAP SuccessFactors | Workday | Oracle HCM | xTalent (Target) |
|---------|-------------------|---------|------------|------------------|
| Multi-country | Yes | Yes | Yes | Yes |
| Statutory rules | Built-in | Built-in | Built-in | Configuration-based |
| Formula engine | Limited | Flexible | Limited | Flexible |
| GL Integration | Yes | Yes | Yes | Yes |
| Bank integration | Standard | Standard | Standard | Standard |
| Vietnam-specific | Localized | Limited | Localized | Full support |

### 8.2 Differentiation Opportunities

1. **Configuration-first approach**: Separate config from execution for flexibility
2. **Vietnam localization**: Deep statutory compliance for VN market
3. **API-first design**: Headless architecture for integration flexibility
4. **Transparent formulas**: User-definable calculation logic

---

## 9. Risk Assessment

### 9.1 Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Complex statutory rule changes | High | High | Versioned rules, audit trail |
| Multi-currency calculations | Medium | Medium | Currency conversion layer |
| Large payroll batch processing | Medium | High | Async processing, chunking |
| Integration failures | Medium | High | Retry logic, reconciliation |

### 9.2 Compliance Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Late statutory updates | Medium | High | Automated compliance monitoring |
| Calculation errors | Low | Critical | Validation rules, test coverage |
| Data privacy violations | Low | Critical | Encryption, access controls |
| Audit trail gaps | Low | High | Comprehensive logging |

---

## 10. Research Conclusions

### 10.1 Key Insights

1. **Clear domain model exists**: The concept documents provide a solid foundation with well-defined entities and relationships.

2. **Vietnam focus is appropriate**: Deep statutory compliance for Vietnam market provides clear differentiation.

3. **Configuration separation is strategic**: Keeping configuration separate from calculation enables flexibility and compliance.

4. **Integration architecture is sound**: Clear upstream/downstream dependencies with appropriate patterns.

5. **Versioning is essential**: SCD-2 pattern for statutory rules and elements is critical for audit and compliance.

### 10.2 Recommendations

1. **Prioritize ontology creation**: Define all entities, relationships, and business rules formally.

2. **Start with Vietnam statutory**: Focus initial development on Vietnam compliance as primary market.

3. **Design for multi-market**: Architecture should support future expansion to other markets.

4. **Invest in formula engine**: Flexible formula definition is key differentiator.

5. **Build comprehensive validation**: Payroll errors are costly - invest heavily in validation.

---

## Appendix A: Research Sources

### Internal Documents
- `PR-concept-overview.md` - Domain model and architecture
- `PR-conceptual-guide.md` - Detailed conceptual guide
- `README.md` - Module overview

### Industry Standards
- ISO 4217 - Currency codes
- ISO 8601 - Date/time formats
- Vietnamese Labor Code - Statutory requirements

### Competitive Analysis
- SAP SuccessFactors Payroll
- Workday Payroll
- Oracle HCM Cloud

---

**Next Steps**: Proceed to Brainstorming Report (`01-brainstorming-report.md`)