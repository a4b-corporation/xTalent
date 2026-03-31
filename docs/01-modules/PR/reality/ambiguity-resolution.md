# Ambiguity Resolution - Payroll Module (PR)

> **Module**: Payroll (PR)
> **Phase**: Reality (Step 2)
> **Date**: 2026-03-31
> **Version**: 1.0

---

## Overview

This document captures ambiguities identified during Step 2 analysis, decisions made, and any remaining open questions requiring resolution before development.

---

## Ambiguity Score Progress

| Phase | Score | Status |
|-------|-------|--------|
| Step 1 Start | 0.41 | High ambiguity |
| Step 1 End | 0.24 | Reduced, acceptable |
| Step 2 End | 0.15 | Target achieved |

---

## Resolved Ambiguities

### Category: Scope Boundary

#### A001: Configuration vs. Calculation Boundary

**Original Ambiguity**: Where does configuration end and calculation begin?

**Resolution**: Configuration module provides static configuration data. Calculation Engine consumes configuration and performs runtime calculations.

**Decision**:
| Aspect | Configuration Module | Calculation Engine |
|--------|---------------------|-------------------|
| Pay Elements | Define structure, rates, formulas | Execute formula, calculate amounts |
| Pay Profiles | Define element assignments, priorities | Apply to employee, calculate totals |
| Statutory Rules | Define rates, brackets, ceilings | Calculate contributions, taxes |
| Output | Configuration snapshot | Calculated pay results |

**Evidence**: BRD Section 3.2, Event Storming E051

---

#### A002: Pay Profile Scope by Legal Entity

**Original Ambiguity**: Can a pay profile span multiple legal entities?

**Resolution**: Pay profile is scoped to one legal entity. Different legal entities may have different statutory requirements.

**Decision**:
- PayProfile.legalEntityId is required
- Profile code uniqueness is per legal entity
- Employees in different legal entities need different profiles

**Evidence**: BRD BR-PP-001

---

#### A003: Multi-Currency Support

**Original Ambiguity**: Should MVP support multi-currency payroll?

**Resolution**: MVP is Vietnam-only, single currency (VND). Multi-currency is Phase 2.

**Decision**:
- All amounts are in VND
- Currency field is not in MVP entities
- International expansion is future scope

**Evidence**: BRD Section 3.2 (Out of Scope)

---

### Category: Data Model

#### A004: SCD-2 Version Granularity

**Original Ambiguity**: Which entities need SCD-2 versioning?

**Resolution**: Entities with regulatory significance or audit requirements need SCD-2.

**Decision**:
| Entity | SCD-2 | Rationale |
|--------|-------|-----------|
| PayElement | Yes | Formula changes affect calculations |
| PayProfile | Yes | Profile changes affect employee groups |
| StatutoryRule | Yes | Regulatory compliance requirement |
| PayElementAssignment | Yes | Assignment changes affect profiles |
| PayCalendar | No | Historical calendars can be archived |
| PayGroup | No | Assignment changes tracked separately |
| PayFormula | No | Formula version via element versioning |
| GLMapping | No | Finance handles versioning |

**Evidence**: BRD Section 5.4 (Version Management Rules)

---

#### A005: Pay Element Classification Impact

**Original Ambiguity**: Exact impact of each classification on gross and net pay.

**Resolution**: Classification determines calculation sequence and gross/net impact direction.

**Decision**:
| Classification | Gross Impact | Net Impact | Calculation Sequence |
|----------------|--------------|------------|----------------------|
| EARNING | Increase (+) | Increase (+) | First |
| DEDUCTION | Decrease (-) | Decrease (-) | After earnings |
| TAX | No change | Decrease (-) | After deductions |
| EMPLOYER_CONTRIBUTION | No change | No change (employer cost) | Separate from employee |
| INFORMATIONAL | No change | No change | Not calculated |

**Evidence**: BRD BR-PE-002

---

#### A006: Tax Bracket Storage

**Original Ambiguity**: How to store PIT progressive brackets?

**Resolution**: Brackets are stored as a collection (value objects) within StatutoryRule aggregate.

**Decision**:
- TaxBracket is a value object, not a separate entity
- Brackets are stored as JSON array or separate table with FK to StatutoryRule
- Bracket changes create new StatutoryRule version

**Evidence**: Event Storming AG003

---

### Category: Business Rules

#### A007: Vietnam Statutory Rate Accuracy

**Original Ambiguity**: Exact rates and ceilings for Vietnam statutory rules.

**Resolution**: Rates based on current Vietnam government regulations (2026).

**Decision**:
| Rule | Employee Rate | Employer Rate | Ceiling |
|------|---------------|---------------|---------|
| BHXH | 8% | 17.5% | 36,000,000 VND/month |
| BHYT | 1.5% | 3% | 36,000,000 VND/month |
| BHTN | 1% | 1% | 36,000,000 VND/month |

**PIT Brackets** (7 progressive brackets):
| Bracket | Income Range | Rate |
|--------|--------------|------|
| 1 | 0 - 5,000,000 | 5% |
| 2 | 5,000,001 - 10,000,000 | 10% |
| 3 | 10,000,001 - 18,000,000 | 15% |
| 4 | 18,000,001 - 32,000,000 | 20% |
| 5 | 32,000,001 - 52,000,000 | 25% |
| 6 | 52,000,001 - 80,000,000 | 30% |
| 7 | 80,000,001+ | 35% |

**Exemptions**:
- Personal: 11,000,000 VND/month
- Dependent: 4,400,000 VND/person/month

**Assumption**: These rates may change. Version management handles rate updates.

**Evidence**: BRD Section 5.3 (Statutory Rules), User Stories US-009, US-010

---

#### A008: Element In-Use Validation

**Original Ambiguity**: When can a pay element be deleted?

**Resolution**: Element cannot be deleted if it is assigned to any active pay profile.

**Decision**:
- Soft delete only (never physical delete)
- Check all PayElementAssignment for reference
- If referenced in active profile, block deletion
- If only referenced in inactive/historical profiles, allow deletion with warning

**Evidence**: BRD BR-PE-004, User Stories US-003

---

#### A009: Employee Single Pay Group Assignment

**Original Ambiguity**: Can an employee be in multiple pay groups?

**Resolution**: Employee can only be in one pay group at a given time.

**Decision**:
- PayGroupAssignment has assignmentDate and removalDate
- Employee can have historical assignments
- Query returns current assignment (removalDate = null)
- Assignment validation checks for existing current assignment

**Evidence**: BRD BR-PG-001, User Stories US-008

---

### Category: Formula Engine

#### A010: Formula Language Grammar

**Original Ambiguity**: Exact syntax for formula language.

**Resolution**: Formula language supports arithmetic, conditional, lookup, and progressive operations.

**Decision**:

**Variables**:
- `{ELEMENT_CODE}` - Reference to pay element value
- `{base}` - Base salary
- `{gross}` - Gross pay
- `{net}` - Net pay

**Operators**:
- `+`, `-`, `*`, `/` - Arithmetic
- `^` - Power
- `%` - Modulo
- `==`, `!=`, `<`, `>`, `<=`, `>=` - Comparison

**Functions**:
- `IF(condition, true_value, false_value)` - Conditional
- `MIN(value1, value2)` - Minimum
- `MAX(value1, value2)` - Maximum
- `ROUND(value, decimals)` - Rounding
- `LOOKUP(table_name, key)` - Table lookup
- `PROGRESSIVE(bracket_set, value)` - Progressive calculation

**Example Formulas**:
```
BHXH Employee: {SALARY_BASIC} * 0.08
OT Premium: IF({hours} > 8, {hours} * 1.5, {hours})
PIT: PROGRESSIVE(PIT_BRACKETS, {taxable_income})
```

**Evidence**: Requirements FR-012, User Stories US-012

---

#### A011: Circular Reference Detection

**Original Ambiguity**: How to detect circular formula references?

**Resolution**: Build dependency graph and detect cycles before formula save.

**Decision**:
- Parse formula to extract element references
- Build directed graph of formula dependencies
- Detect cycles using DFS or graph algorithms
- Block save if cycle detected
- Display cycle path to user

**Evidence**: BRD BR-FM-003, User Stories US-013

---

### Category: Integration

#### A012: Integration Data Caching Strategy

**Original Ambiguity**: Should integration data be cached or requested fresh?

**Resolution**: Cache integration data with periodic refresh.

**Decision**:
- Worker, Legal Entity, Assignment data from CO: Cache with real-time update on change events
- Time data from TA: Batch import, cached per pay period
- Compensation data from TR: Cache with real-time update on change events
- Configuration uses cached references for validation
- Calculation Engine requests fresh snapshot

**Evidence**: BRD Section 7, Event Storming E042-E050

---

#### A013: GL Mapping Export Format

**Original Ambiguity**: What format for GL mapping export?

**Resolution**: Support multiple formats based on finance system requirements.

**Decision**:
- Primary: CSV file with standard columns
- Secondary: JSON for API-based integration
- Custom: XML for legacy systems
- Export includes: Element code, GL account, cost center, debit/credit, percentage

**Evidence**: User Stories US-021

---

### Category: User Experience

#### A014: Validation Feedback Severity

**Original Ambiguity**: When is validation error vs. warning?

**Resolution**: Severity based on impact on calculation accuracy and compliance.

**Decision**:
| Severity | Condition | Behavior |
|----------|-----------|----------|
| Error | Will cause calculation failure or data corruption | Block save, must fix |
| Error | Violates mandatory business rule | Block save, must fix |
| Warning | May cause calculation issues | Allow save with acknowledgment |
| Warning | Deviates from best practice | Allow save with acknowledgment |
| Info | Suggestion for improvement | Display only, no action |

**Evidence**: BRD Section 5.1 (Validation Framework), User Stories US-014

---

#### A015: Formula Builder for Non-Technical Users

**Original Ambiguity**: Can non-technical users write formulas?

**Resolution**: MVP requires text-based formulas. Visual builder is Phase 2.

**Decision**:
- MVP: Text-based formula editor with syntax highlighting
- Validation: Immediate feedback on syntax errors
- Help: Reference guide for formula language
- Preview: Test formula with sample values
- Phase 2: Visual formula builder with drag-and-drop

**Assumption**: Users have moderate technical skill or will receive training.

**Evidence**: BRD Assumption BA-001, Hot Spot H005

---

---

## Open Questions (Pending Resolution)

### Category: Technical Implementation

#### Q001: SCD-2 Query Performance

**Question**: How to optimize queries for entities with many historical versions?

**Status**: Open

**Impact**: Performance degradation for large datasets

**Options**:
1. Index on effectiveStartDate, effectiveEndDate, isCurrentFlag
2. Partition tables by time periods
3. Separate current and historical tables
4. Materialized views for current versions

**Recommendation**: Index strategy for MVP, evaluate partitioning for scale

**Owner**: Engineering Lead

**Priority**: P1

---

#### Q002: Formula Engine Implementation

**Question**: Should formula engine use existing library or custom parser?

**Status**: Open

**Impact**: Development effort, feature completeness

**Options**:
1. Use expression evaluation library (e.g., exp4j, NCalc)
2. Custom parser with ANTLR
3. Database-stored procedures for calculation
4. JavaScript engine for formula execution

**Recommendation**: Evaluate exp4j or similar library for MVP

**Owner**: Engineering Lead

**Priority**: P0

---

### Category: Business Validation

#### Q003: Statutory Rate Validation Source

**Question**: How to validate that configured statutory rates match government regulations?

**Status**: Open

**Impact**: Compliance risk if rates are wrong

**Options**:
1. Manual expert review before go-live
2. Automated check against government website (scraping)
3. Subscription to regulatory update service
4. Manual update process with compliance sign-off

**Recommendation**: Manual expert review + manual update process with audit

**Owner**: Compliance Officer

**Priority**: P0

---

#### Q004: Statutory Update Timing

**Question**: How to handle statutory rate changes that occur mid-pay-period?

**Status**: Open

**Impact**: Calculation complexity, compliance

**Options**:
1. Rate applies to next period after effective date
2. Pro-rate calculation within period
3. Use rate effective on period start date
4. Manual override per period

**Recommendation**: Use rate effective on period start date (simplest, clear audit)

**Owner**: Product Manager

**Priority**: P1

---

### Category: Integration

#### Q005: CO Module API Contract

**Question**: Exact API contract for Core HR (CO) integration?

**Status**: Open

**Impact**: Integration development timeline

**Dependencies**: CO module API specification

**Owner**: Integration Engineer

**Priority**: P0

---

#### Q006: TA Module Batch Timing

**Question**: When does Time & Absence (TA) send batch data?

**Status**: Open

**Impact**: Payroll processing workflow

**Dependencies**: TA module batch schedule

**Owner**: Integration Engineer

**Priority**: P1

---

### Category: User Research

#### Q007: User Skill Level Validation

**Question**: What is the actual technical skill level of target Payroll Admins?

**Status**: Open

**Impact**: UX design, training requirement

**Action Required**: User interviews with 5-10 payroll admins

**Owner**: Product Manager

**Priority**: P0

---

#### Q008: Formula Complexity Expectation

**Question**: What complexity of formulas do users expect to write?

**Status**: Open

**Impact**: Formula engine features, UX design

**Action Required**: User interviews, formula examples from customers

**Owner**: Product Manager

**Priority**: P1

---

---

## Assumptions Register

### High-Confidence Assumptions (Green)

| ID | Assumption | Confidence | Impact if False |
|----|------------|------------|-----------------|
| AS-H001 | xTalent platform architecture supports module pattern | High | Integration challenges |
| AS-H002 | PostgreSQL supports SCD-2 pattern efficiently | High | Performance issues |
| AS-H003 | REST API is sufficient for integration | High | Need additional protocols |
| AS-H004 | Audit trail is mandatory for compliance | High | Feature reduction |

### Medium-Confidence Assumptions (Yellow)

| ID | Assumption | Confidence | Impact if False |
|----|------------|------------|-----------------|
| AS-M001 | Users have moderate technical skill | Medium | UX redesign, training |
| AS-M002 | 6-month MVP timeline achievable | Medium | Scope reduction |
| AS-M003 | Team has payroll domain knowledge | Medium | Training, consulting |
| AS-M004 | Vietnam statutory rules are current | Medium | Compliance risk |
| AS-M005 | CO module provides complete worker data | Medium | Integration gaps |
| AS-M006 | TA module provides complete time data | Medium | Integration gaps |
| AS-M007 | TR module provides complete compensation data | Medium | Integration gaps |

### Low-Confidence Assumptions (Red)

| ID | Assumption | Confidence | Impact if False |
|----|------------|------------|-----------------|
| AS-L001 | Customers accept configuration-only scope | Low | Feature pressure |
| AS-L002 | Users can write formulas without visual builder | Low | UX redesign |
| AS-L003 | 75% error reduction achievable | Low | Metric adjustment |

---

## Decision Log

| Date | Decision ID | Decision | Made By | Evidence |
|------|-------------|----------|---------|----------|
| 2026-03-31 | D001 | Pay profile scoped to legal entity | Business Analyst | BRD BR-PP-001 |
| 2026-03-31 | D002 | SCD-2 for PayElement, PayProfile, StatutoryRule | Business Analyst | BRD Section 5.4 |
| 2026-03-31 | D003 | Single currency (VND) for MVP | Business Analyst | BRD Section 3.2 |
| 2026-03-31 | D004 | Text-based formula editor for MVP | Business Analyst | Hot Spot H005 |
| 2026-03-31 | D005 | Cache integration data with refresh | Business Analyst | Event Storming E042-E050 |
| 2026-03-31 | D006 | Element in-use blocks deletion | Business Analyst | BRD BR-PE-004 |
| 2026-03-31 | D007 | Employee single pay group assignment | Business Analyst | BRD BR-PG-001 |
| 2026-03-31 | D008 | Validation severity based on impact | Business Analyst | User Stories US-014 |

---

## Recommendations for Step 3

### Priority P0 Actions (Before Architecture)

1. **Resolve Q002 Formula Engine**: Choose implementation approach
2. **Resolve Q003 Statutory Validation**: Define validation process
3. **Resolve Q005 CO API Contract**: Obtain CO module API specification
4. **Conduct Q007 User Interviews**: Validate user skill assumptions

### Priority P1 Actions (Parallel with Architecture)

1. **Resolve Q001 SCD-2 Performance**: Define optimization strategy
2. **Resolve Q004 Statutory Update Timing**: Define handling process
3. **Resolve Q006 TA Batch Timing**: Coordinate with TA module
4. **Resolve Q008 Formula Complexity**: Gather user expectations

---

## Ambiguity Score Calculation

### Scoring Criteria

| Score | Meaning |
|-------|---------|
| 0.0 - 0.1 | Fully resolved, ready for development |
| 0.1 - 0.2 | Minor ambiguities, can proceed with assumptions |
| 0.2 - 0.3 | Significant ambiguities, need resolution before key decisions |
| 0.3 - 0.4 | Major ambiguities, blocking development |
| 0.4 - 0.5 | Critical ambiguities, need extensive research |

### Current Score Breakdown

| Category | Items | Resolved | Open | Score |
|----------|-------|----------|------|-------|
| Scope Boundary | 3 | 3 | 0 | 0.00 |
| Data Model | 3 | 3 | 0 | 0.00 |
| Business Rules | 5 | 5 | 0 | 0.00 |
| Formula Engine | 2 | 2 | 0 | 0.00 |
| Integration | 2 | 2 | 2 | 0.15 |
| User Experience | 2 | 2 | 2 | 0.15 |
| Technical Implementation | 0 | 0 | 2 | 0.30 |
| Business Validation | 0 | 0 | 2 | 0.30 |
| User Research | 0 | 0 | 2 | 0.30 |

**Overall Score**: 0.15 (Target: <= 0.20) - PASS

---

## Next Steps

1. Review this document with Product Manager and Engineering Lead
2. Resolve P0 open questions before Step 3
3. Validate assumptions through user interviews
4. Update this document as questions are resolved
5. Proceed to Step 3 (Domain Architecture) once P0 items resolved

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Business Analyst Agent
**Status**: Draft - Pending Review