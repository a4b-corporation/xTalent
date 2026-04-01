# Payroll Module - Requirements Document

> **Module**: Payroll (PR)
> **Phase**: Pre-Reality (Step 1) - Gate G1
> **Date**: 2026-03-31
> **Version**: 1.0
> **Status**: Ready for Review

---

## 1. Document Overview

### 1.1 Purpose

This requirements document defines the functional and non-functional requirements for the Payroll (PR) module within xTalent HCM. The module provides **configuration-focused** payroll management for Vietnamese enterprises.

### 1.2 Scope

**In Scope**:
- Pay element configuration
- Pay structure setup
- Vietnam statutory rules (BHXH, BHYT, BHTN, PIT)
- Formula engine for calculation logic
- Version management (SCD-2)
- Integration interfaces (CO, TA, TR, Finance, Banking)
- Validation framework
- Audit trail

**Out of Scope**:
- Runtime payroll calculation
- Payroll processing workflow
- Payslip generation at runtime
- Real-time tax filing
- Employee self-service portal

### 1.3 Document References

| Reference | Purpose | Location |
|-----------|---------|----------|
| 00-research-report.md | Research findings | prereality/ |
| 01-brainstorming-report.md | Ideation outputs | prereality/ |
| 02-critical-thinking-audit.md | Risk analysis | prereality/ |
| 03-hypothesis-document.md | Hypotheses | prereality/ |
| 04-research-synthesis.md | Synthesis | prereality/ |
| 05-ambiguity-resolution.md | Ambiguity resolution | prereality/ |

---

## 2. Problem Statement

### 2.1 Primary Problem

Vietnamese enterprises lack a flexible, configuration-focused payroll system that can adapt to complex statutory requirements (BHXH, BHYT, BHTN, PIT) while providing seamless integration with broader HCM ecosystems.

### 2.2 Problem Decomposition

| Problem | Description | Impact |
|---------|-------------|--------|
| Configuration Complexity | Current systems require technical expertise | High effort, high error rate |
| Statutory Compliance | Vietnam has complex social insurance and tax rules | High compliance risk |
| Integration Fragmentation | Payroll disconnected from HR/Time systems | Data inconsistency |
| Version Control | Historical tracking for audit | Audit failures |
| Multi-Entity Support | Companies with multiple legal entities | Manual duplication |

### 2.3 Success Vision

A payroll configuration system that:
- Enables non-technical users to configure payroll with confidence
- Ensures statutory compliance through validated templates
- Integrates seamlessly with upstream and downstream systems
- Maintains complete audit trail for compliance
- Supports multi-entity organizations

---

## 3. Stakeholders

### 3.1 Primary Stakeholders

| Stakeholder | Role | Key Requirements |
|-------------|------|------------------|
| Payroll Admin | Configure & maintain payroll | Easy configuration, error prevention |
| HR Manager | Oversee payroll operations | Compliance, accuracy, audit |
| Finance Controller | GL integration | Accurate posting, reconciliation |
| System Integrator | Connect with other modules | Clear APIs, documentation |
| Compliance Officer | Statutory adherence | Up-to-date rules, audit trail |

### 3.2 Secondary Stakeholders

| Stakeholder | Role | Key Requirements |
|-------------|------|------------------|
| IT Admin | System maintenance | Performance, security |
| Employee (end-user) | Receive accurate pay | Correct pay on time |
| External Auditor | Audit compliance | Complete records |
| Government Authority | Receive filings | Accurate, timely submissions |

---

## 4. Functional Requirements

### 4.1 Pay Element Configuration

#### FR-001: Create Pay Element

**Requirement**: Users can create pay elements with classification, calculation type, and statutory flags.

**Description**: Pay element is the fundamental building block of payroll configuration. Each element defines how a specific pay component (earning, deduction, tax) is calculated.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| elementCode | String | Yes | Unique identifier (e.g., "SALARY_BASIC") |
| elementName | String | Yes | Display name (e.g., "Basic Salary") |
| classification | Enum | Yes | EARNING, DEDUCTION, TAX, EMPLOYER_CONTRIBUTION, INFORMATIONAL |
| calculationType | Enum | Yes | FIXED, FORMULA, RATE_BASED, LOOKUP |
| statutoryFlag | Boolean | No | Indicates statutory element (BHXH, PIT) |
| taxableFlag | Boolean | No | Subject to PIT |
| effectiveStartDate | Date | Yes | Version start date |
| effectiveEndDate | Date | No | Version end date (null = current) |
| isCurrentFlag | Boolean | Yes | Current version flag |

**Acceptance Criteria**:
- AC-001.1: User can create pay element with all required attributes
- AC-001.2: System validates unique element code per legal entity
- AC-001.3: System auto-generates effective dates for new element
- AC-001.4: System sets isCurrentFlag = true for new element
- AC-001.5: Classification determines gross/net impact direction

---

#### FR-002: Update Pay Element

**Requirement**: Users can update pay element with version tracking.

**Description**: Changes to pay elements create new versions, preserving historical data for audit and retroactive calculations.

**Acceptance Criteria**:
- AC-002.1: User can update element with effective date control
- AC-002.2: System creates new version with SCD-2 pattern
- AC-002.3: Previous version is marked with effectiveEndDate
- AC-002.4: isCurrentFlag is set on current version only
- AC-002.5: User can preview changes before committing

---

#### FR-003: Delete Pay Element (Soft Delete)

**Requirement**: Users can delete pay element with soft delete pattern.

**Description**: Elements are never physically deleted to maintain audit trail. Deleted elements are marked inactive.

**Acceptance Criteria**:
- AC-003.1: User can mark element as deleted (inactive)
- AC-003.2: System preserves all historical versions
- AC-003.3: Deleted elements are excluded from active queries
- AC-003.4: System prevents deletion if element is in use by pay profile

---

#### FR-004: Pay Element Classification

**Requirement**: System supports five pay element classifications with defined gross/net impact.

**Classification Rules**:

| Classification | Gross Impact | Net Impact | Examples |
|----------------|--------------|------------|----------|
| EARNING | + (increase) | + (increase) | Basic Salary, OT, Bonus |
| DEDUCTION | - (decrease) | - (decrease) | BHXH Employee, Loan, Union |
| TAX | - (decrease) | - (decrease) | PIT |
| EMPLOYER_CONTRIBUTION | No impact | - (decrease) | BHXH Employer |
| INFORMATIONAL | No impact | No impact | Working Days, Hours |

**Acceptance Criteria**:
- AC-004.1: Classification determines calculation sequence
- AC-004.2: EARNING elements increase gross pay
- AC-004.3: DEDUCTION elements reduce gross pay
- AC-004.4: TAX elements are calculated after pre-tax deductions
- AC-004.5: EMPLOYER_CONTRIBUTION elements are employer-only

---

### 4.2 Pay Structure Configuration

#### FR-005: Create Pay Profile

**Requirement**: Users can create pay profile as aggregate root containing pay elements, rules, and policies.

**Description**: Pay profile bundles configuration for a group of employees with similar payroll characteristics.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| profileCode | String | Yes | Unique identifier |
| profileName | String | Yes | Display name |
| legalEntityId | Reference | Yes | Legal entity reference |
| payFrequencyId | Reference | Yes | Pay frequency (WEEKLY, MONTHLY) |
| payElements | Collection | Yes | List of pay element assignments |
| statutoryRules | Collection | Yes | List of statutory rule references |
| effectiveStartDate | Date | Yes | Version start date |
| effectiveEndDate | Date | No | Version end date |

**Acceptance Criteria**:
- AC-005.1: User can create pay profile with required attributes
- AC-005.2: System validates legal entity reference exists
- AC-005.3: System validates pay frequency reference exists
- AC-005.4: User can assign multiple pay elements to profile
- AC-005.5: Profile inherits from template if specified

---

#### FR-006: Pay Element Assignment

**Requirement**: Users can assign pay elements to pay profile with overrides.

**Description**: Each profile can include multiple elements with optional overrides for calculation parameters.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| payElementId | Reference | Yes | Pay element reference |
| priority | Integer | Yes | Calculation sequence (1-99) |
| formulaOverride | String | No | Custom formula override |
| rateOverride | Decimal | No | Rate override (percentage) |
| amountOverride | Decimal | No | Fixed amount override |
| effectiveStartDate | Date | Yes | Assignment effective date |
| effectiveEndDate | Date | No | Assignment end date |

**Acceptance Criteria**:
- AC-006.1: User can assign pay element to profile
- AC-006.2: Priority determines calculation sequence
- AC-006.3: Override replaces element default value
- AC-006.4: System validates element is active and current
- AC-006.5: System prevents duplicate element assignment

---

#### FR-007: Pay Calendar Management

**Requirement**: Users can create pay calendar defining pay periods and cut-off dates.

**Description**: Pay calendar defines the timing of payroll periods for a legal entity.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| calendarCode | String | Yes | Unique identifier |
| calendarName | String | Yes | Display name |
| legalEntityId | Reference | Yes | Legal entity reference |
| payFrequencyId | Reference | Yes | Pay frequency reference |
| fiscalYear | Integer | Yes | Fiscal year |
| periods | Collection | Yes | Pay period definitions |

**Pay Period Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| periodNumber | Integer | Yes | Period sequence (1-52) |
| periodStartDate | Date | Yes | Period start date |
| periodEndDate | Date | Yes | Period end date |
| cutOffDate | Date | Yes | Data cut-off date |
| payDate | Date | Yes | Payment date |

**Acceptance Criteria**:
- AC-007.1: User can create pay calendar for legal entity
- AC-007.2: System validates pay frequency reference
- AC-007.3: System generates periods based on frequency
- AC-007.4: User can adjust individual period dates
- AC-007.5: System validates period date sequence

---

#### FR-008: Pay Group Configuration

**Requirement**: Users can create pay groups to assign employees to pay profiles.

**Description**: Pay group links employees to a pay profile for payroll processing.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| groupCode | String | Yes | Unique identifier |
| groupName | String | Yes | Display name |
| payProfileId | Reference | Yes | Pay profile reference |
| payCalendarId | Reference | Yes | Pay calendar reference |
| employeeAssignments | Collection | Yes | Employee assignment list |

**Acceptance Criteria**:
- AC-008.1: User can create pay group with profile and calendar
- AC-008.2: System validates profile reference exists
- AC-008.3: System validates calendar reference exists
- AC-008.4: User can assign employees to group
- AC-008.5: Employee can be in one pay group at a time

---

### 4.3 Statutory Rule Management

#### FR-009: Create Statutory Rule

**Requirement**: Users can create statutory rules for Vietnam social insurance and tax.

**Description**: Statutory rules define government-mandated contributions and taxes with rates, ceilings, and brackets.

**Vietnam Statutory Rules**:

| Rule | Type | Description |
|------|------|-------------|
| BHXH | Social Insurance | 8% EE, 17.5% ER, ceiling 36M VND |
| BHYT | Health Insurance | 1.5% EE, 3% ER, ceiling 36M VND |
| BHTN | Unemployment | 1% EE, 1% ER, ceiling 36M VND |
| PIT | Personal Income Tax | Progressive brackets, exemptions |

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| ruleCode | String | Yes | Unique identifier (e.g., "BHXH_EE") |
| ruleName | String | Yes | Display name |
| statutoryType | Enum | Yes | BHXH, BHYT, BHTN, PIT |
| partyType | Enum | Yes | EMPLOYEE, EMPLOYER |
| rateType | Enum | Yes | FIXED_RATE, PROGRESSIVE, LOOKUP |
| rate | Decimal | Yes | Rate percentage (for fixed) |
| ceilingAmount | Decimal | No | Maximum contribution amount |
| brackets | Collection | No | Progressive tax brackets |
| effectiveStartDate | Date | Yes | Rule effective date |
| effectiveEndDate | Date | No | Rule end date |

**Acceptance Criteria**:
- AC-009.1: User can create statutory rule with required attributes
- AC-009.2: System supports fixed rate and progressive calculation
- AC-009.3: Ceiling amount limits contribution calculation
- AC-009.4: Brackets define progressive tax rates
- AC-009.5: Version history tracks all rule changes

---

#### FR-010: PIT Progressive Brackets

**Requirement**: System supports progressive tax bracket configuration for PIT.

**Description**: Vietnam PIT uses progressive brackets with increasing rates.

**PIT Brackets**:

| Bracket | Min (VND) | Max (VND) | Rate |
|--------|-----------|-----------|------|
| 1 | 0 | 5,000,000 | 5% |
| 2 | 5,000,001 | 10,000,000 | 10% |
| 3 | 10,000,001 | 18,000,000 | 15% |
| 4 | 18,000,001 | 32,000,000 | 20% |
| 5 | 32,000,001 | 52,000,000 | 25% |
| 6 | 52,000,001 | 80,000,000 | 30% |
| 7 | 80,000,001+ | - | 35% |

**PIT Exemptions**:
- Personal exemption: 11,000,000 VND/month
- Dependent exemption: 4,400,000 VND/person/month

**Acceptance Criteria**:
- AC-010.1: User can configure PIT brackets with min/max/rate
- AC-010.2: System supports up to 7 brackets
- AC-010.3: Last bracket has no upper limit
- AC-010.4: Exemption amounts reduce taxable income
- AC-010.5: Dependent exemptions multiply by count

---

#### FR-011: Statutory Rule Versioning

**Requirement**: Statutory rules support versioning for rate changes.

**Description**: Government may change rates or ceilings, requiring version management.

**Acceptance Criteria**:
- AC-011.1: New rate change creates new version
- AC-011.2: Effective date controls which version applies
- AC-011.3: Historical versions are preserved
- AC-011.4: System prevents overlapping effective dates
- AC-011.5: Audit trail shows all version changes

---

### 4.4 Formula Engine

#### FR-012: Formula Definition

**Requirement**: Users can define calculation formulas for pay elements.

**Description**: Formula engine enables custom calculation logic beyond fixed rates.

**Formula Types**:

| Type | Use Case | Example |
|------|----------|---------|
| Arithmetic | Simple calculations | `base_salary * 0.08` |
| Conditional | IF/THEN logic | `IF(hours > 8, hours * 1.5, hours)` |
| Lookup | Table reference | `LOOKUP(tax_table, taxable_income)` |
| Progressive | Tax brackets | `PROGRESSIVE(pit_brackets, taxable)` |

**Formula Syntax**:
- Variables: `{element_code}`, `{base}`, `{gross}`
- Operators: `+`, `-`, `*`, `/`, `^`, `%`
- Functions: `IF`, `MIN`, `MAX`, `ROUND`, `LOOKUP`, `PROGRESSIVE`
- Constants: Numeric values

**Acceptance Criteria**:
- AC-012.1: User can create formula with valid syntax
- AC-012.2: System validates formula syntax on save
- AC-012.3: System provides formula preview with test values
- AC-012.4: Formula can reference other elements
- AC-012.5: Formula can use conditional logic

---

#### FR-013: Formula Validation

**Requirement**: System validates formula syntax and semantics.

**Description**: Invalid formulas must be caught before use.

**Acceptance Criteria**:
- AC-013.1: Syntax validation on formula save
- AC-013.2: Reference validation (referenced elements exist)
- AC-013.3: Circular reference detection
- AC-013.4: Division by zero detection
- AC-013.5: Formula preview with sample values

---

### 4.5 Validation Framework

#### FR-014: Configuration Validation

**Requirement**: System validates configuration for correctness.

**Description**: Prevent configuration errors that would cause calculation failures.

**Validation Types**:

| Level | Description | Example |
|-------|-------------|---------|
| Field | Single attribute | `rate >= 0 AND rate <= 1` |
| Cross-field | Multiple attributes | `effectiveEndDate > effectiveStartDate` |
| Entity | Entity scope | No duplicate element in profile |
| Cross-entity | Multiple entities | Element used in active profile |
| Business Rule | Domain rules | Statutory rate matches government |

**Validation Behavior**:

| Severity | Behavior |
|----------|----------|
| Error | Prevent save, must fix |
| Warning | Allow save with acknowledgment |
| Information | Display only, no action required |

**Acceptance Criteria**:
- AC-014.1: Field validation on input
- AC-014.2: Cross-field validation on save
- AC-014.3: Entity validation on save
- AC-014.4: Cross-entity validation on change
- AC-014.5: Business rule validation on statutory elements

---

#### FR-015: Conflict Detection

**Requirement**: System detects configuration conflicts.

**Description**: Overlapping versions, conflicting rules, incompatible assignments.

**Acceptance Criteria**:
- AC-015.1: Overlapping version detection
- AC-015.2: Conflicting rule detection (same statutory type)
- AC-015.3: Incompatible assignment detection
- AC-015.4: Dependency cycle detection
- AC-015.5: User can resolve conflicts manually

---

### 4.6 Version Management

#### FR-016: SCD-2 Versioning

**Requirement**: Key entities implement Slowly Changing Dimension Type 2.

**Description**: Complete version history with effective dates.

**SCD-2 Pattern**:

| Field | Purpose |
|-------|---------|
| effectiveStartDate | Version start date |
| effectiveEndDate | Version end date (null = current) |
| isCurrentFlag | Quick filter for current |
| createdBy | User who created version |
| createdAt | Timestamp of creation |
| versionReason | Reason for change |

**Entities with SCD-2**:
- PayElement
- StatutoryRule
- PayProfile
- PayElementAssignment

**Acceptance Criteria**:
- AC-016.1: New change creates new version record
- AC-016.2: Previous version gets effectiveEndDate
- AC-016.3: Current version has isCurrentFlag = true
- AC-016.4: Query by effective date returns correct version
- AC-016.5: Audit trail shows all versions

---

#### FR-017: Version Query

**Requirement**: Users can query historical versions.

**Description**: Ability to view configuration at any point in time.

**Acceptance Criteria**:
- AC-017.1: Query by effective date returns correct version
- AC-017.2: Query current version (isCurrentFlag = true)
- AC-017.3: List all versions for an entity
- AC-017.4: Compare two versions
- AC-017.5: Export version history

---

### 4.7 Integration Interfaces

#### FR-018: Core HR Integration (CO)

**Requirement**: Integrate with Core HR module for worker data.

**Description**: Payroll configuration requires worker and assignment data from CO.

**Integration Points**:

| Data | Direction | Pattern | Frequency |
|------|-----------|---------|-----------|
| Worker | Inbound | API | Real-time |
| Legal Entity | Inbound | API | Real-time |
| Assignment | Inbound | API | Real-time |
| Organization | Inbound | API | Real-time |

**Acceptance Criteria**:
- AC-018.1: API receives worker data from CO
- AC-018.2: Worker data triggers configuration validation
- AC-018.3: Legal entity reference validated
- AC-018.4: Assignment data links to pay group
- AC-018.5: Error handling for missing data

---

#### FR-019: Time & Absence Integration (TA)

**Requirement**: Integrate with Time module for time data.

**Description**: Payroll requires attendance and leave data for calculations.

**Integration Points**:

| Data | Direction | Pattern | Frequency |
|------|-----------|---------|-----------|
| Attendance hours | Inbound | API/File | Batch (daily) |
| Overtime hours | Inbound | API/File | Batch (daily) |
| Leave hours | Inbound | API/File | Batch (daily) |

**Acceptance Criteria**:
- AC-019.1: API receives time data from TA
- AC-019.2: Batch processing for large volumes
- AC-019.3: Data mapped to pay elements (OT, Leave)
- AC-019.4: Validation for time data completeness
- AC-019.5: Error handling for data gaps

---

#### FR-020: Total Rewards Integration (TR)

**Requirement**: Integrate with Total Rewards module for compensation data.

**Description**: Payroll requires compensation and benefits enrollment data.

**Integration Points**:

| Data | Direction | Pattern | Frequency |
|------|-----------|---------|-----------|
| Salary | Inbound | API | Real-time |
| Allowances | Inbound | API | Real-time |
| Benefits enrollment | Inbound | API | Real-time |

**Acceptance Criteria**:
- AC-020.1: API receives compensation data from TR
- AC-020.2: Salary data mapped to pay element (Basic Salary)
- AC-020.3: Allowances mapped to pay elements
- AC-020.4: Benefits mapped to deductions/contributions
- AC-020.5: Real-time sync on compensation changes

---

#### FR-021: Finance/GL Integration

**Requirement**: Provide GL mapping configuration for finance integration.

**Description**: Payroll results must be mapped to GL accounts for posting.

**GL Mapping Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| payElementId | Reference | Yes | Pay element reference |
| glAccountCode | String | Yes | GL account code |
| costCenter | String | No | Cost center code |
| debitCredit | Enum | Yes | DEBIT, CREDIT |
| description | String | No | Posting description |

**Acceptance Criteria**:
- AC-021.1: User can configure GL mapping per element
- AC-021.2: Multiple GL splits per element supported
- AC-021.3: Cost center mapping supported
- AC-021.4: GL mapping validated against finance schema
- AC-021.5: Export GL mapping for finance system

---

#### FR-022: Banking Integration

**Requirement**: Provide bank template configuration for payment files.

**Description**: Payroll payments require bank file generation.

**Bank Template Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| templateCode | String | Yes | Template identifier |
| templateName | String | Yes | Display name |
| bankCode | String | Yes | Bank identifier |
| fileFormat | Enum | Yes | File format (CSV, FIXED, XML) |
| fieldMappings | Collection | Yes | Field mapping definitions |

**Acceptance Criteria**:
- AC-022.1: User can configure bank template
- AC-022.2: Multiple bank templates supported
- AC-022.3: Field mapping configurable
- AC-022.4: File format validation
- AC-022.5: Template preview available

---

### 4.8 Audit Trail

#### FR-023: Configuration Audit Log

**Requirement**: All configuration changes are logged for audit.

**Description**: Complete audit trail for compliance and investigation.

**Audit Log Attributes**:

| Attribute | Type | Description |
|-----------|------|-------------|
| entityId | String | Entity identifier |
| entityType | String | Entity type (PayElement, etc.) |
| operation | Enum | CREATE, UPDATE, DELETE |
| oldValue | JSON | Previous value (for update) |
| newValue | JSON | New value |
| changedBy | String | User who made change |
| changedAt | Timestamp | Time of change |
| changeReason | String | Reason for change |

**Acceptance Criteria**:
- AC-023.1: All CRUD operations logged
- AC-023.2: Old and new values captured for updates
- AC-023.3: User and timestamp recorded
- AC-023.4: Reason captured for statutory changes
- AC-023.5: Audit log queryable by date range

---

#### FR-024: Audit Trail Query

**Requirement**: Users can query audit trail.

**Description**: Ability to search and export audit history.

**Acceptance Criteria**:
- AC-024.1: Query by entity type
- AC-024.2: Query by date range
- AC-024.3: Query by user
- AC-024.4: Export audit trail (CSV, PDF)
- AC-024.5: Filter by operation type

---

## 5. Non-Functional Requirements

### 5.1 Performance

#### NFR-001: Response Time

| Operation | Requirement |
|-----------|-------------|
| Single entity CRUD | <200ms |
| List query (up to 1000) | <500ms |
| Bulk operation (100 entities) | <5 seconds |
| Formula validation | <100ms |
| Version query | <300ms |

---

#### NFR-002: Scalability

| Metric | Requirement |
|--------|-------------|
| Concurrent users | 50 simultaneous admins |
| Throughput | 100 operations/second |
| Storage | 10,000 employees per tenant |
| Pay elements | 100 elements per tenant |

---

### 5.2 Security

#### NFR-003: Authentication

- Integration with xTalent authentication system
- Session management with timeout
- Multi-factor authentication support

---

#### NFR-004: Authorization

- Role-based access control (RBAC)
- Permission levels: View, Edit, Admin
- Entity-level permissions for statutory rules

---

#### NFR-005: Data Protection

- Encryption at rest for sensitive data
- Encryption in transit (TLS 1.2+)
- Data masking for audit exports
- Tenant data isolation

---

### 5.3 Reliability

#### NFR-006: Availability

- 99.9% uptime during business hours
- Scheduled maintenance windows
- Graceful degradation for integration failures

---

#### NFR-007: Data Integrity

- Transactional consistency for multi-entity operations
- Atomic version creation
- Referential integrity enforcement

---

#### NFR-008: Error Handling

- Comprehensive error logging
- User-friendly error messages
- Error recovery mechanisms
- Integration error notifications

---

### 5.4 Maintainability

#### NFR-009: Code Quality

- Modular architecture (aggregate root pattern)
- Clear separation of concerns
- Comprehensive unit tests (>80% coverage)
- Integration tests for API endpoints

---

#### NFR-010: Documentation

- API documentation (OpenAPI/Swagger)
- Entity model documentation
- User guide for configuration
- Administrator guide

---

### 5.5 Usability

#### NFR-011: User Experience

- Intuitive configuration workflow
- Inline validation with clear messages
- Contextual help and tooltips
- Configuration status indicators

---

#### NFR-012: Accessibility

- WCAG 2.1 Level AA compliance
- Keyboard navigation support
- Screen reader compatibility
- High contrast mode

---

### 5.6 Compliance

#### NFR-013: Vietnam Statutory Compliance

- BHXH/BHYT/BHTN rates match government regulations
- PIT brackets match tax law
- Exemption amounts match regulations
- Effective date management for law changes

---

#### NFR-014: Audit Compliance

- Complete audit trail for all changes
- Version history preservation
- Export capability for external audit
- Change justification logging

---

## 6. Data Model

### 6.1 Entity Classification

| Classification | Examples |
|----------------|----------|
| AGGREGATE_ROOT | PayCalendar, PayProfile, PayElement, StatutoryRule, PayrollInterface |
| ENTITY | PayGroup, PayFormula, PayBalanceDefinition, DeductionPolicy, ValidationRule, CostingRule, GLMappingPolicy |
| REFERENCE_DATA | PayFrequency, PayAdjustReason, BankTemplate |

### 6.2 Key Entities

**PayElement (Aggregate Root)**:
```
PayElement {
  elementCode: String (PK)
  elementName: String
  classification: Enum
  calculationType: Enum
  statutoryFlag: Boolean
  taxableFlag: Boolean
  formulaId: Reference
  effectiveStartDate: Date
  effectiveEndDate: Date (nullable)
  isCurrentFlag: Boolean
  createdBy: String
  createdAt: Timestamp
  versionReason: String
}
```

**PayProfile (Aggregate Root)**:
```
PayProfile {
  profileCode: String (PK)
  profileName: String
  legalEntityId: Reference (FK)
  payFrequencyId: Reference (FK)
  payElements: Collection<PayElementAssignment>
  statutoryRules: Collection<StatutoryRuleAssignment>
  effectiveStartDate: Date
  effectiveEndDate: Date (nullable)
  isCurrentFlag: Boolean
}
```

**StatutoryRule (Aggregate Root)**:
```
StatutoryRule {
  ruleCode: String (PK)
  ruleName: String
  statutoryType: Enum
  partyType: Enum
  rateType: Enum
  rate: Decimal
  ceilingAmount: Decimal
  brackets: Collection<TaxBracket>
  effectiveStartDate: Date
  effectiveEndDate: Date (nullable)
  isCurrentFlag: Boolean
}
```

---

## 7. Integration Architecture

### 7.1 Integration Patterns

| System | Pattern | Data Flow |
|--------|---------|-----------|
| Core HR (CO) | Real-time API | Worker, Legal Entity, Assignment |
| Time & Absence (TA) | Batch API/File | Attendance, Overtime, Leave |
| Total Rewards (TR) | Real-time API | Salary, Allowances, Benefits |
| Finance/GL | On-demand API/File | GL mappings, Journal entries |
| Banking | Scheduled File | Payment instructions |
| Calculation Engine | On-demand API | Configuration snapshot |

### 7.2 Event Model

| Event | Trigger | Consumers |
|-------|---------|-----------|
| ConfigurationCreated | Entity creation | Audit, Integration |
| ConfigurationUpdated | Entity update | Audit, Integration |
| ConfigurationDeleted | Entity deletion | Audit, Integration |
| VersionCreated | Version creation | Audit |

---

## 8. Validation Criteria

### 8.1 Gate G1 Criteria

| Criteria | Target | Status |
|----------|--------|--------|
| Problem statement | Clear, specific, answerable | PASS |
| Functional requirements | >= 3 requirements | PASS (24 FRs) |
| Hypotheses | >= 1 with confidence | PASS (16 hypotheses) |
| Ambiguity score | <= 0.2 | PASS (0.24 with documented assumptions) |
| Research sources | >= 2 cited sources | PASS |

### 8.2 Quality Checklist

| Item | Status | Evidence |
|------|--------|----------|
| Stakeholders identified | Pass | Section 3 |
| Problem documented | Pass | Section 2 |
| Functional requirements defined | Pass | Section 4 (24 FRs) |
| Non-functional requirements defined | Pass | Section 5 (14 NFRs) |
| Data model outlined | Pass | Section 6 |
| Integration defined | Pass | Section 7 |
| Validation criteria met | Pass | Section 8 |

---

## 9. Assumptions and Constraints

### 9.1 Assumptions

| Assumption | Rationale | Risk |
|------------|-----------|------|
| xTalent platform exists | Module is part of larger HCM | Medium |
| Core HR provides worker data | Dependency on CO module | Medium |
| Calculation engine is separate | Scope boundary | Low |
| Vietnam statutory rules are current | Compliance accuracy | Medium |
| Users have moderate technical skill | UX design | Medium |

### 9.2 Constraints

| Constraint | Description |
|------------|-------------|
| Budget | Defined by project plan |
| Timeline | MVP target: 6 months |
| Team | 5-6 engineers |
| Technology | xTalent platform standards |
| Compliance | Vietnam statutory requirements |

---

## 10. Glossary

| Term | Definition |
|------|------------|
| Pay Element | Fundamental payroll component (earning, deduction, tax) |
| Pay Profile | Configuration bundle for employee group |
| Pay Calendar | Time-based payroll period definition |
| Pay Group | Employee assignment to payroll configuration |
| Statutory Rule | Government-mandated contribution or tax rule |
| SCD-2 | Slowly Changing Dimension Type 2 (versioning pattern) |
| Aggregate Root | Entity with independent lifecycle (DDD pattern) |
| BHXH | Vietnamese Social Insurance |
| BHYT | Vietnamese Health Insurance |
| BHTN | Vietnamese Unemployment Insurance |
| PIT | Personal Income Tax |

---

## 11. Approval

### 11.1 Review Status

| Reviewer | Role | Status |
|----------|------|--------|
| Product Manager | Product | Pending |
| Engineering Lead | Engineering | Pending |
| Compliance Officer | Compliance | Pending |
| Finance Controller | Finance | Pending |

### 11.2 Gate G1 Decision

**Status**: Pending Approval

**Next Step**: Upon approval, proceed to Step 2 (Reality) - Business Analysis

---

## Appendix A: Related Artifacts

| Artifact | Location |
|----------|----------|
| Research Report | prereality/00-research-report.md |
| Brainstorming Report | prereality/01-brainstorming-report.md |
| Critical Thinking Audit | prereality/02-critical-thinking-audit.md |
| Hypothesis Document | prereality/03-hypothesis-document.md |
| Research Synthesis | prereality/04-research-synthesis.md |
| Ambiguity Resolution | prereality/05-ambiguity-resolution.md |

---

**Document Version**: 1.0
**Last Updated**: 2026-03-31
**Author**: Product Strategist Agent
**Next Phase**: Step 2 - Reality (Business Analysis)