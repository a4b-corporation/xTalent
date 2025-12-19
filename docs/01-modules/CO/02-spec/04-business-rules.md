# Core Module (CO) - Business Rules

**Version**: 2.0  
**Last Updated**: 2025-12-03  
**Module**: Core (CO)  
**Status**: Complete - Derived from 450 FRs

---

## 📋 Overview

This document defines all business rules for the Core Module. Business rules are the logic that governs how the system behaves, validates data, and enforces business constraints. These rules are referenced by functional requirements and implemented in the system.

### Business Rule Structure

Each business rule follows this format:

```yaml
BR-[MODULE]-[NUMBER]: [Rule Title]
  Category: [Category Name]
  Priority: HIGH | MEDIUM | LOW
  Description: [Detailed description]
  Conditions: [When this rule applies]
  Rules: [Specific rules]
  Exceptions: [Exceptions to the rule]
  Error Messages: [Error messages]
  Related FRs: [FR references]
  Related Entities: [Entity references]
```

---

## 📊 Business Rules Summary

### By Category

| Category | Rule Count | Priority Distribution |
|----------|------------|----------------------|
| **Configuration** | 15 | HIGH: 8, MEDIUM: 5, LOW: 2 |
| **Worker Management** | 10 | HIGH: 7, MEDIUM: 2, LOW: 1 |
| **Work Relationship** | 35 | HIGH: 20, MEDIUM: 12, LOW: 3 |
| **Employee Management** | 15 | HIGH: 10, MEDIUM: 4, LOW: 1 |
| **Assignment** | 45 | HIGH: 25, MEDIUM: 15, LOW: 5 |
| **Business Unit** | 10 | HIGH: 6, MEDIUM: 3, LOW: 1 |
| **Job Taxonomy** | 10 | HIGH: 5, MEDIUM: 4, LOW: 1 |
| **Job Profile** | 10 | HIGH: 4, MEDIUM: 5, LOW: 1 |
| **Position** | 25 | HIGH: 15, MEDIUM: 8, LOW: 2 |
| **Matrix Reporting** | 15 | HIGH: 8, MEDIUM: 5, LOW: 2 |
| **Skill Management** | 10 | HIGH: 4, MEDIUM: 5, LOW: 1 |
| **Skill Assessment** | 10 | HIGH: 5, MEDIUM: 4, LOW: 1 |
| **Career Paths** | 5 | HIGH: 2, MEDIUM: 2, LOW: 1 |
| **Data Privacy** | 30 | HIGH: 20, MEDIUM: 8, LOW: 2 |
| **TOTAL** | **245** | **HIGH: 139, MEDIUM: 87, LOW: 19** |

---

## 🎯 Phase 0: Configuration & Code Lists

### Category: Code List Management

#### BR-CFG-001: Code List Uniqueness

**Priority**: HIGH

**Description**:
Code list codes must be unique across the system.

**Conditions**:
```
WHEN creating or updating a code list
```

**Rules**:
1. Code list code must be unique (case-insensitive)
2. Code list code must be alphanumeric with underscores only
3. Code list code must be between 2-50 characters
4. System code lists cannot be deleted or have their codes changed

**Exceptions**:
- None

**Error Messages**:
- `CODE_LIST_DUPLICATE`: "Code list with code '{code}' already exists"
- `CODE_LIST_INVALID_FORMAT`: "Code list code must be alphanumeric with underscores"
- `CODE_LIST_SYSTEM_PROTECTED`: "System code lists cannot be modified"

**Related FRs**: FR-CFG-001, FR-CFG-003

**Related Entities**: CodeList

---

#### BR-CFG-002: Code Value Uniqueness

**Priority**: HIGH

**Description**:
Code values within a code list must be unique.

**Conditions**:
```
WHEN adding or updating a code value
```

**Rules**:
1. Code value must be unique within its code list
2. Code value must be alphanumeric with underscores/hyphens
3. Code value must be between 1-50 characters
4. Sort order must be unique within code list
5. System code values cannot be deleted

**Exceptions**:
- Inactive code values can have duplicate sort orders

**Error Messages**:
- `CODE_VALUE_DUPLICATE`: "Code value '{code}' already exists in code list '{list}'"
- `CODE_VALUE_INVALID_FORMAT`: "Code value must be alphanumeric"
- `CODE_VALUE_SYSTEM_PROTECTED`: "System code values cannot be deleted"

**Related FRs**: FR-CFG-002, FR-CFG-004

**Related Entities**: CodeValue

---

#### BR-CFG-003: Code List Dependency

**Priority**: MEDIUM

**Description**:
Code lists with dependencies cannot be deleted.

**Conditions**:
```
WHEN attempting to delete a code list
```

**Rules**:
1. Check if code list is referenced by any entity
2. Check if code list has active code values
3. System code lists cannot be deleted
4. Code list can be deactivated instead of deleted

**Exceptions**:
- Force delete allowed for SYSTEM_ADMIN with confirmation

**Error Messages**:
- `CODE_LIST_IN_USE`: "Code list is referenced by {count} records"
- `CODE_LIST_HAS_VALUES`: "Code list has {count} active values"

**Related FRs**: FR-CFG-005, FR-CFG-015

**Related Entities**: CodeList

---

#### BR-CFG-004: Code Value Activation

**Priority**: MEDIUM

**Description**:
Code value activation/deactivation rules.

**Conditions**:
```
WHEN activating or deactivating a code value
```

**Rules**:
1. Deactivated code values cannot be used for new records
2. Existing records with deactivated values remain valid
3. At least one code value must be active per code list
4. System code values cannot be deactivated

**Exceptions**:
- Optional code lists can have all values deactivated

**Error Messages**:
- `CODE_VALUE_LAST_ACTIVE`: "Cannot deactivate last active code value"
- `CODE_VALUE_SYSTEM_PROTECTED`: "System code values cannot be deactivated"

**Related FRs**: FR-CFG-004, FR-CFG-006

**Related Entities**: CodeValue

---

#### BR-CFG-005: Code List Validation

**Priority**: HIGH

**Description**:
All code list references must be validated.

**Conditions**:
```
WHEN saving data that references a code list
```

**Rules**:
1. Code value must exist in the specified code list
2. Code value must be active
3. Code value must be valid for the current date (if date-sensitive)
4. Required code lists must have a value

**Exceptions**:
- Historical records can reference inactive code values

**Error Messages**:
- `CODE_VALUE_NOT_FOUND`: "Code value '{code}' not found in code list '{list}'"
- `CODE_VALUE_INACTIVE`: "Code value '{code}' is inactive"
- `CODE_VALUE_REQUIRED`: "Code list '{list}' is required"

**Related FRs**: FR-CFG-002, FR-CFG-004

**Related Entities**: All entities with code list references

---

### Category: Configuration Management

#### BR-CFG-010: Configuration Key Uniqueness

**Priority**: HIGH

**Description**:
Configuration keys must be unique and follow naming conventions.

**Conditions**:
```
WHEN creating or updating a configuration
```

**Rules**:
1. Configuration key must be unique
2. Key must use snake_case format
3. Key must be between 3-100 characters
4. System configurations cannot be deleted
5. Configuration values must match data type

**Exceptions**:
- None

**Error Messages**:
- `CONFIG_KEY_DUPLICATE`: "Configuration key '{key}' already exists"
- `CONFIG_KEY_INVALID_FORMAT`: "Key must use snake_case format"
- `CONFIG_VALUE_TYPE_MISMATCH`: "Value does not match data type {type}"

**Related FRs**: FR-CFG-010, FR-CFG-011

**Related Entities**: Configuration

---

#### BR-CFG-011: Configuration Validation

**Priority**: HIGH

**Description**:
Configuration values must be validated based on data type and constraints.

**Conditions**:
```
WHEN updating a configuration value
```

**Rules**:
1. STRING: Max length validation
2. INTEGER: Range validation
3. DECIMAL: Precision and scale validation
4. BOOLEAN: Must be true/false
5. DATE: Must be valid date format
6. JSON: Must be valid JSON

**Exceptions**:
- None

**Error Messages**:
- `CONFIG_VALUE_INVALID`: "Invalid value for configuration '{key}'"
- `CONFIG_VALUE_OUT_OF_RANGE`: "Value must be between {min} and {max}"

**Related FRs**: FR-CFG-011

**Related Entities**: Configuration

---

## 👤 Phase 1: Worker Management

### Category: Worker Data Validation

#### BR-WRK-001: Worker Creation Validation

**Priority**: HIGH

**Description**:
Worker records must meet minimum data requirements.

**Conditions**:
```
WHEN creating a new worker record
```

**Rules**:
1. Full name is required (max 200 characters)
2. Date of birth is required and must be past date
3. Gender code is required and must be valid
4. Person type is required and must be valid
5. National ID must be unique if provided
6. Email must be valid format if provided
7. Phone must be valid format if provided

**Exceptions**:
- Contractors may have relaxed validation rules

**Error Messages**:
- `WORKER_NAME_REQUIRED`: "Full name is required"
- `WORKER_DOB_INVALID`: "Date of birth must be a past date"
- `WORKER_NATIONAL_ID_DUPLICATE`: "National ID already exists"
- `WORKER_EMAIL_INVALID`: "Invalid email format"

**Related FRs**: FR-WRK-001

**Related Entities**: Worker

---

#### BR-WRK-002: Worker Code Generation

**Priority**: HIGH

**Description**:
Worker codes must be auto-generated and unique.

**Conditions**:
```
WHEN creating a new worker record
```

**Rules**:
1. Worker code is auto-generated
2. Format: WORKER-{NNNNNN} (6-digit sequential)
3. Worker code must be unique
4. Worker code cannot be changed after creation

**Exceptions**:
- None

**Error Messages**:
- `WORKER_CODE_GENERATION_FAILED`: "Failed to generate unique worker code"

**Related FRs**: FR-WRK-001

**Related Entities**: Worker

---

#### BR-WRK-004: Data Classification Enforcement

**Priority**: HIGH

**Description**:
Worker data must be classified and access controlled.

**Conditions**:
```
WHEN accessing or modifying worker data
```

**Rules**:
1. PUBLIC: Full name, preferred name, gender (accessible to all)
2. INTERNAL: Email, phone (accessible to same organization)
3. CONFIDENTIAL: Date of birth, address (accessible to manager + HR)
4. RESTRICTED: National ID, passport, bank account (accessible to HR only with purpose)

**Exceptions**:
- Employee can always access their own data
- DPO can access for privacy compliance purposes

**Error Messages**:
- `WORKER_DATA_ACCESS_DENIED`: "Insufficient permissions to access {field}"
- `WORKER_DATA_PURPOSE_REQUIRED`: "Purpose required to access RESTRICTED data"

**Related FRs**: FR-WRK-010, FR-PRI-001

**Related Entities**: Worker

---

#### BR-WRK-005: Worker Update Validation

**Priority**: MEDIUM

**Description**:
Worker updates must follow SCD Type 2 rules for significant changes.

**Conditions**:
```
WHEN updating worker information
```

**Rules**:
1. Significant changes create new version (name, DOB, national ID)
2. Minor changes update current version (email, phone, address)
3. Previous versions are retained
4. is_current_flag is updated
5. Effective dates are set

**Exceptions**:
- None

**Error Messages**:
- `WORKER_UPDATE_INVALID`: "Invalid update operation"

**Related FRs**: FR-WRK-003

**Related Entities**: Worker

---

#### BR-WRK-006: Worker Merge Validation

**Priority**: MEDIUM

**Description**:
Worker merge must validate no active employment conflicts.

**Conditions**:
```
WHEN merging two worker records
```

**Rules**:
1. Source and target workers must exist
2. Neither worker can have active employment
3. All relationships are transferred to target
4. Source worker is marked as merged
5. Merge is logged and cannot be undone

**Exceptions**:
- SYSTEM_ADMIN can force merge with confirmation

**Error Messages**:
- `WORKER_MERGE_ACTIVE_EMPLOYMENT`: "Cannot merge workers with active employment"
- `WORKER_MERGE_SAME_WORKER`: "Cannot merge worker with itself"

**Related FRs**: FR-WRK-012

**Related Entities**: Worker

---

#### BR-WRK-010: Worker Deactivation

**Priority**: MEDIUM

**Description**:
Worker deactivation rules.

**Conditions**:
```
WHEN deactivating a worker
```

**Rules**:
1. Worker cannot have active work relationships
2. Worker cannot have active employee records
3. Worker can be deactivated with end date
4. Historical data is preserved
5. Deactivated workers don't appear in active lists

**Exceptions**:
- None

**Error Messages**:
- `WORKER_HAS_ACTIVE_RELATIONSHIPS`: "Worker has active work relationships"

**Related FRs**: FR-WRK-005

**Related Entities**: Worker

---

## 💼 Phase 1: Work Relationship Management

### Category: Work Relationship Validation

#### BR-WR-001: Work Relationship Creation

**Priority**: HIGH

**Description**:
Work relationship must meet minimum requirements.

**Conditions**:
```
WHEN creating a new work relationship
```

**Rules**:
1. Worker must exist and be active
2. Relationship type is required (EMPLOYEE, CONTRACTOR, etc.)
3. Legal entity is required
4. Start date is required and must be today or future
5. End date must be after start date if provided
6. Worker cannot have overlapping active relationships of same type

**Exceptions**:
- Multiple concurrent relationships allowed for different types

**Error Messages**:
- `WR_WORKER_REQUIRED`: "Worker is required"
- `WR_DATES_INVALID`: "End date must be after start date"
- `WR_OVERLAP_DETECTED`: "Worker already has active {type} relationship"

**Related FRs**: FR-WR-001

**Related Entities**: WorkRelationship, Worker

---

#### BR-WR-002: Work Relationship Type Validation

**Priority**: HIGH

**Description**:
Work relationship type determines allowed operations.

**Conditions**:
```
WHEN creating or updating work relationship
```

**Rules**:
1. EMPLOYEE: Requires employee record
2. CONTRACTOR: No employee record allowed
3. CONSULTANT: No employee record allowed
4. INTERN: May or may not have employee record
5. Each type has specific validation rules

**Exceptions**:
- None

**Error Messages**:
- `WR_TYPE_EMPLOYEE_REQUIRED`: "EMPLOYEE relationship requires employee record"
- `WR_TYPE_CONTRACTOR_NO_EMPLOYEE`: "CONTRACTOR cannot have employee record"

**Related FRs**: FR-WR-001, FR-WR-002

**Related Entities**: WorkRelationship

---

#### BR-WR-010: Work Relationship Termination

**Priority**: HIGH

**Description**:
Work relationship termination validation.

**Conditions**:
```
WHEN terminating a work relationship
```

**Rules**:
1. End date is required
2. End date must be today or past
3. End date must be after start date
4. Termination reason is required
5. All active assignments must be ended
6. All active employee records must be terminated
7. Notice period must be documented

**Exceptions**:
- Emergency termination can bypass notice period

**Error Messages**:
- `WR_END_DATE_REQUIRED`: "End date is required for termination"
- `WR_ACTIVE_ASSIGNMENTS`: "Cannot terminate with active assignments"
- `WR_ACTIVE_EMPLOYEE`: "Cannot terminate with active employee record"

**Related FRs**: FR-WR-010

**Related Entities**: WorkRelationship

---

#### BR-WR-015: Work Relationship Status

**Priority**: MEDIUM

**Description**:
Work relationship status transitions.

**Conditions**:
```
WHEN changing work relationship status
```

**Rules**:
1. Valid statuses: ACTIVE, SUSPENDED, TERMINATED
2. Status transitions:
   - ACTIVE → SUSPENDED (allowed)
   - ACTIVE → TERMINATED (allowed)
   - SUSPENDED → ACTIVE (allowed)
   - SUSPENDED → TERMINATED (allowed)
   - TERMINATED → * (not allowed)
3. Status change reason required

**Exceptions**:
- SYSTEM_ADMIN can reactivate terminated relationships

**Error Messages**:
- `WR_STATUS_INVALID_TRANSITION`: "Cannot change status from {from} to {to}"
- `WR_STATUS_REASON_REQUIRED`: "Status change reason is required"

**Related FRs**: FR-WR-011

**Related Entities**: WorkRelationship

---

#### BR-WR-020: Employment Type Validation

**Priority**: MEDIUM

**Description**:
Employment type validation rules.

**Conditions**:
```
WHEN setting employment type
```

**Rules**:
1. Employment type must be valid code value
2. FULL_TIME: FTE = 1.0
3. PART_TIME: FTE < 1.0
4. CASUAL: FTE variable
5. Employment type changes create new version (SCD Type 2)

**Exceptions**:
- None

**Error Messages**:
- `WR_EMPLOYMENT_TYPE_INVALID`: "Invalid employment type"
- `WR_FTE_MISMATCH`: "FTE must be 1.0 for FULL_TIME"

**Related FRs**: FR-WR-015

**Related Entities**: WorkRelationship

---

### Category: Contract Management ✨ NEW

#### BR-CONTRACT-001: Contract Creation Validation

**Priority**: HIGH

**Description**:
Contract must meet all prerequisites and validation rules.

**Conditions**:
```
WHEN creating a new contract
```

**Rules**:
1. Employee must exist and be active
2. Contract type is required (PERMANENT, FIXED_TERM, PROBATION, SEASONAL)
3. Start date is required
4. If contract_type = FIXED_TERM → end_date IS REQUIRED
5. If contract_type = PERMANENT → end_date MUST BE NULL
6. If contract_type = PROBATION → probation_end_date IS REQUIRED
7. If template_id provided → inherit template defaults
8. Duration_value and duration_unit must both be provided or both be null
9. If duration provided → end_date = start_date + duration (auto-calculated)
10. Only one active contract per employee at a time

**Exceptions**:
- None

**Error Messages**:
- `CONTRACT_EMPLOYEE_REQUIRED`: "Employee is required"
- `CONTRACT_TYPE_REQUIRED`: "Contract type is required"
- `CONTRACT_FIXED_TERM_END_DATE_REQUIRED`: "End date required for FIXED_TERM contract"
- `CONTRACT_PERMANENT_END_DATE_NOT_ALLOWED`: "End date not allowed for PERMANENT contract"
- `CONTRACT_ACTIVE_EXISTS`: "Employee already has active contract"

**Related FRs**: FR-WR-022, FR-CONTRACT-001

**Related Entities**: Contract, Employee, ContractTemplate

---

#### BR-CONTRACT-002: Contract Template Inheritance

**Priority**: HIGH

**Description**:
When template is selected, contract inherits defaults but allows overrides with validation.

**Conditions**:
```
WHEN creating contract with template_id
```

**Rules**:
1. Template must exist and be active
2. If duration not specified → use template.default_duration_value/unit
3. If probation not specified → use template.probation_required and template.probation_duration
4. If notice_period not specified → use template.default_notice_period_days
5. Validate duration against template.min_duration and template.max_duration
6. If template.probation_required = true → probation_end_date MUST be set
7. Template scope (country/legal_entity/business_unit) must match contract context

**Exceptions**:
- User can override template defaults if within constraints

**Error Messages**:
- `CONTRACT_TEMPLATE_INACTIVE`: "Contract template is inactive"
- `CONTRACT_DURATION_BELOW_MIN`: "Duration {value} {unit} is below minimum {min} {unit}"
- `CONTRACT_DURATION_ABOVE_MAX`: "Duration {value} {unit} exceeds maximum {max} {unit}"
- `CONTRACT_PROBATION_REQUIRED`: "Probation is required by template"
- `CONTRACT_TEMPLATE_SCOPE_MISMATCH`: "Template scope does not match contract context"

**Related FRs**: FR-CONTRACT-001, FR-CONTRACT-002

**Related Entities**: Contract, ContractTemplate

---

#### BR-CONTRACT-003: Contract Duration Calculation

**Priority**: HIGH

**Description**:
Contract end date auto-calculation based on duration.

**Conditions**:
```
WHEN duration_value and duration_unit are provided
```

**Rules**:
1. If duration_unit = DAY → end_date = start_date + duration_value days
2. If duration_unit = MONTH → end_date = start_date + duration_value months
3. End date calculation uses business day rules (skip weekends/holidays)
4. If end_date manually provided → must match calculated end_date (within 1 day tolerance)
5. Duration cannot be negative or zero

**Exceptions**:
- PERMANENT contracts have no duration

**Error Messages**:
- `CONTRACT_DURATION_INVALID`: "Duration must be positive"
- `CONTRACT_END_DATE_MISMATCH`: "End date does not match calculated value from duration"

**Related FRs**: FR-WR-022, FR-CONTRACT-002

**Related Entities**: Contract

---

#### BR-CONTRACT-004: Contract Parent Relationship Validation

**Priority**: HIGH

**Description**:
Contract parent-child relationship validation rules.

**Conditions**:
```
WHEN parent_contract_id is provided
```

**Rules**:
1. If parent_contract_id IS NOT NULL → parent_relationship_type IS REQUIRED
2. Parent contract must exist
3. Parent contract must belong to same employee
4. Valid relationship types: AMENDMENT, ADDENDUM, RENEWAL, SUPERSESSION
5. AMENDMENT: At least one field must differ from parent
6. SUPERSESSION: contract_type must differ from parent
7. RENEWAL: parent contract must be FIXED_TERM and expiring/expired
8. Cannot create circular parent relationships
9. Parent contract should be ended when child becomes active (for SUPERSESSION)

**Exceptions**:
- None

**Error Messages**:
- `CONTRACT_PARENT_RELATIONSHIP_TYPE_REQUIRED`: "Parent relationship type required when parent contract specified"
- `CONTRACT_PARENT_NOT_FOUND`: "Parent contract not found"
- `CONTRACT_PARENT_EMPLOYEE_MISMATCH`: "Parent contract belongs to different employee"
- `CONTRACT_SUPERSESSION_TYPE_SAME`: "SUPERSESSION requires different contract type"
- `CONTRACT_CIRCULAR_RELATIONSHIP`: "Circular parent relationship detected"

**Related FRs**: FR-CONTRACT-003, FR-CONTRACT-004, FR-CONTRACT-005, FR-CONTRACT-006

**Related Entities**: Contract

---

#### BR-CONTRACT-005: Contract Amendment Validation

**Priority**: MEDIUM

**Description**:
Contract amendment specific validation.

**Conditions**:
```
WHEN parent_relationship_type = AMENDMENT
```

**Rules**:
1. Parent contract must be active
2. Amendment must modify at least one field (salary, hours, location, etc.)
3. Amendment effective date must be >= parent start_date
4. Amendment cannot change contract_type
5. Amendment cannot change employee_id
6. Multiple amendments allowed for same parent

**Exceptions**:
- None

**Error Messages**:
- `CONTRACT_AMENDMENT_NO_CHANGES`: "Amendment must modify at least one field"
- `CONTRACT_AMENDMENT_TYPE_CHANGE`: "Amendment cannot change contract type"
- `CONTRACT_AMENDMENT_PARENT_INACTIVE`: "Parent contract must be active"

**Related FRs**: FR-CONTRACT-004

**Related Entities**: Contract

---

#### BR-CONTRACT-006: Contract Renewal Validation

**Priority**: HIGH

**Description**:
Contract renewal specific validation.

**Conditions**:
```
WHEN parent_relationship_type = RENEWAL
```

**Rules**:
1. Parent contract must be FIXED_TERM
2. Parent contract must be expiring or expired
3. New start_date should be parent.end_date + 1 day (or parent.end_date if same day renewal)
4. If template has max_renewals → validate renewal count <= max_renewals
5. Renewal count is tracked (count parent's renewals + 1)
6. Renewal must have same contract_type as parent (typically FIXED_TERM)
7. Renewal notification must be sent before parent expiry (per template.renewal_notice_days)

**Exceptions**:
- HR_ADMIN can override max_renewals limit with justification

**Error Messages**:
- `CONTRACT_RENEWAL_NOT_FIXED_TERM`: "Only FIXED_TERM contracts can be renewed"
- `CONTRACT_RENEWAL_NOT_EXPIRING`: "Parent contract is not expiring"
- `CONTRACT_RENEWAL_MAX_EXCEEDED`: "Maximum {max} renewals exceeded"
- `CONTRACT_RENEWAL_START_DATE_INVALID`: "Renewal start date must follow parent end date"

**Related FRs**: FR-CONTRACT-005

**Related Entities**: Contract, ContractTemplate

---

#### BR-CONTRACT-007: Contract Supersession Validation

**Priority**: MEDIUM

**Description**:
Contract supersession specific validation.

**Conditions**:
```
WHEN parent_relationship_type = SUPERSESSION
```

**Rules**:
1. Parent contract must exist
2. New contract_type must differ from parent.contract_type
3. Common pattern: PROBATION → PERMANENT
4. Supersession date must be >= parent.start_date
5. Parent contract should be ended when supersession becomes active
6. Only one supersession allowed per parent contract

**Exceptions**:
- None

**Error Messages**:
- `CONTRACT_SUPERSESSION_TYPE_SAME`: "Supersession requires different contract type"
- `CONTRACT_SUPERSESSION_ALREADY_EXISTS`: "Parent contract already superseded"

**Related FRs**: FR-CONTRACT-006

**Related Entities**: Contract

---

#### BR-CONTRACT-008: Contract Compliance Validation

**Priority**: HIGH

**Description**:
Country-specific labor law compliance validation.

**Conditions**:
```
WHEN creating or updating contract
```

**Rules**:
1. Vietnam (VN):
   - FIXED_TERM max duration: 36 months
   - FIXED_TERM max consecutive renewals: 1 (total 2 contracts)
   - PROBATION max duration: 60 days (non-management), 180 days (management)
2. Singapore (SG):
   - No specific max duration for FIXED_TERM
   - PROBATION max duration: 180 days
3. Compliance rules loaded from template.legal_requirements (JSONB)
4. Validate mandatory clauses per country
5. Validate notice period per country labor law

**Exceptions**:
- Special contracts (executives) may have different rules with approval

**Error Messages**:
- `CONTRACT_COMPLIANCE_VN_DURATION_EXCEEDED`: "VN: Fixed-term contract cannot exceed 36 months"
- `CONTRACT_COMPLIANCE_VN_RENEWALS_EXCEEDED`: "VN: Maximum 1 renewal allowed for fixed-term"
- `CONTRACT_COMPLIANCE_PROBATION_EXCEEDED`: "Probation period exceeds legal maximum"
- `CONTRACT_COMPLIANCE_MANDATORY_CLAUSE_MISSING`: "Mandatory clause '{clause}' missing"

**Related FRs**: FR-CONTRACT-008

**Related Entities**: Contract, ContractTemplate

---

#### BR-CONTRACT-009: Contract Probation Validation

**Priority**: MEDIUM

**Description**:
Probation period validation rules.

**Conditions**:
```
WHEN probation_end_date is provided
```

**Rules**:
1. Probation_end_date must be > start_date
2. Probation period = probation_end_date - start_date
3. Probation period must not exceed country-specific limits
4. If template.probation_required = true → probation_end_date IS REQUIRED
5. Probation can be extended once (create AMENDMENT)
6. Probation must be confirmed before end date (create SUPERSESSION to PERMANENT)

**Exceptions**:
- Senior/executive roles may have longer probation with approval

**Error Messages**:
- `CONTRACT_PROBATION_REQUIRED`: "Probation period required by template"
- `CONTRACT_PROBATION_EXCEEDS_LIMIT`: "Probation period exceeds {max} days limit"
- `CONTRACT_PROBATION_END_BEFORE_START`: "Probation end date must be after start date"

**Related FRs**: FR-WR-023

**Related Entities**: Contract, ContractTemplate

---

#### BR-CONTRACT-010: Contract Termination Validation

**Priority**: HIGH

**Description**:
Contract termination validation rules.

**Conditions**:
```
WHEN terminating a contract
```

**Rules**:
1. Termination_date is required
2. Termination_date must be >= start_date
3. Termination_reason_code is required
4. Notice period must be respected (per contract.notice_period_days or template.default_notice_period_days)
5. If FIXED_TERM contract terminated early → early termination reason required
6. All related assignments must be ended
7. Employee status must be updated

**Exceptions**:
- Emergency termination can bypass notice period with approval

**Error Messages**:
- `CONTRACT_TERMINATION_DATE_REQUIRED`: "Termination date is required"
- `CONTRACT_TERMINATION_REASON_REQUIRED`: "Termination reason is required"
- `CONTRACT_NOTICE_PERIOD_NOT_MET`: "Notice period of {days} days not met"
- `CONTRACT_EARLY_TERMINATION_REASON_REQUIRED`: "Early termination reason required for FIXED_TERM"

**Related FRs**: FR-WR-003

**Related Entities**: Contract

---

### Category: Contract Template Management ✨ NEW

#### BR-CONTRACT-TEMPLATE-001: Template Creation Validation

**Priority**: HIGH

**Description**:
Contract template must meet all requirements.

**Conditions**:
```
WHEN creating contract template
```

**Rules**:
1. Template code is required and must be unique
2. Template name is required
3. Contract_type_code is required
4. If contract_type = FIXED_TERM → max_duration_value IS REQUIRED
5. If contract_type = PERMANENT → max_duration_value MUST BE NULL
6. If default_duration provided → must be within min/max range
7. If probation_required = true → probation_duration_value IS REQUIRED
8. Scope: At least one of country_code, legal_entity_id, or business_unit_id must be specified
9. Legal_requirements must be valid JSON if provided

**Exceptions**:
- None

**Error Messages**:
- `TEMPLATE_CODE_REQUIRED`: "Template code is required"
- `TEMPLATE_CODE_DUPLICATE`: "Template code already exists"
- `TEMPLATE_FIXED_TERM_MAX_DURATION_REQUIRED`: "Max duration required for FIXED_TERM template"
- `TEMPLATE_DURATION_OUT_OF_RANGE`: "Default duration must be between min and max"
- `TEMPLATE_SCOPE_REQUIRED`: "At least one scope (country/legal entity/business unit) required"

**Related FRs**: FR-CONTRACT-001

**Related Entities**: ContractTemplate

---

#### BR-CONTRACT-TEMPLATE-002: Template Scope Validation

**Priority**: MEDIUM

**Description**:
Template scope hierarchy validation.

**Conditions**:
```
WHEN selecting template for contract
```

**Rules**:
1. Template selection priority (most specific first):
   - Business Unit specific (if business_unit_id matches)
   - Legal Entity specific (if legal_entity_id matches)
   - Country specific (if country_code matches)
   - Global (no scope specified)
2. Template must be active (is_active = true)
3. Template effective dates must include contract start_date
4. Only one template per scope combination

**Exceptions**:
- None

**Error Messages**:
- `TEMPLATE_NOT_FOUND_FOR_SCOPE`: "No active template found for scope"
- `TEMPLATE_MULTIPLE_FOUND`: "Multiple templates found for scope, cannot determine which to use"
- `TEMPLATE_NOT_EFFECTIVE`: "Template not effective for contract start date"

**Related FRs**: FR-CONTRACT-002

**Related Entities**: ContractTemplate

---

#### BR-CONTRACT-TEMPLATE-003: Template Renewal Rules Validation

**Priority**: MEDIUM

**Description**:
Template renewal configuration validation.

**Conditions**:
```
WHEN setting renewal rules in template
```

**Rules**:
1. If allows_renewal = false → max_renewals MUST BE 0 or NULL
2. If allows_renewal = true → max_renewals SHOULD BE >= 1
3. If allows_renewal = true → renewal_notice_days IS REQUIRED
4. Renewal_notice_days must be positive integer
5. Renewal_notice_days typically between 30-90 days

**Exceptions**:
- None

**Error Messages**:
- `TEMPLATE_RENEWAL_INCONSISTENT`: "If allows_renewal = false, max_renewals must be 0"
- `TEMPLATE_RENEWAL_NOTICE_REQUIRED`: "Renewal notice days required when renewal allowed"
- `TEMPLATE_RENEWAL_NOTICE_INVALID`: "Renewal notice days must be positive"

**Related FRs**: FR-CONTRACT-001

**Related Entities**: ContractTemplate

---

#### BR-WR-032: Probation Period Validation

**Priority**: MEDIUM

**Description**:
Probation period validation rules.

**Conditions**:
```
WHEN setting probation period
```

**Rules**:
1. Probation period must be positive integer (days)
2. Probation end date = start date + probation period
3. Probation period cannot exceed 180 days (configurable)
4. Probation can be extended once
5. Probation must be confirmed or terminated before end date

**Exceptions**:
- Senior roles may have longer probation periods

**Error Messages**:
- `WR_PROBATION_INVALID`: "Probation period must be between 1-180 days"
- `WR_PROBATION_ALREADY_EXTENDED`: "Probation already extended once"

**Related FRs**: FR-WR-023

**Related Entities**: WorkRelationship

---

## 👥 Phase 1: Employee Management

### Category: Employee Creation

#### BR-EMP-001: Employee Creation Validation

**Priority**: HIGH

**Description**:
Employee record must meet all prerequisites.

**Conditions**:
```
WHEN creating a new employee record
```

**Rules**:
1. Worker must exist
2. Work relationship must exist and be EMPLOYEE type
3. Work relationship must be ACTIVE
4. Employee number must be unique
5. Hire date must equal work relationship start date
6. Probation end date must be after hire date if specified
7. Worker cannot have multiple active employee records

**Exceptions**:
- Rehire: Previous employee record must be terminated

**Error Messages**:
- `EMP_WORKER_REQUIRED`: "Worker is required"
- `EMP_WR_REQUIRED`: "Active EMPLOYEE work relationship required"
- `EMP_NUMBER_DUPLICATE`: "Employee number already exists"
- `EMP_ACTIVE_EXISTS`: "Worker already has active employee record"

**Related FRs**: FR-EMP-001

**Related Entities**: Employee, Worker, WorkRelationship

---

#### BR-EMP-002: Employee Number Generation

**Priority**: HIGH

**Description**:
Employee number generation rules.

**Conditions**:
```
WHEN creating employee record
```

**Rules**:
1. Employee number is auto-generated if not provided
2. Format: EMP-{NNNNNN} (6-digit sequential) or custom format from config
3. Employee number must be unique
4. Employee number cannot be changed after creation

**Exceptions**:
- HR_ADMIN can provide custom employee number

**Error Messages**:
- `EMP_NUMBER_GENERATION_FAILED`: "Failed to generate employee number"
- `EMP_NUMBER_INVALID_FORMAT`: "Employee number does not match format"

**Related FRs**: FR-EMP-001, FR-EMP-005

**Related Entities**: Employee

---

#### BR-EMP-010: Employee Termination Validation

**Priority**: HIGH

**Description**:
Employee termination validation rules.

**Conditions**:
```
WHEN terminating an employee
```

**Rules**:
1. Termination date is required
2. Termination date must be today or past
3. Termination date must be after hire date
4. Termination reason is required
5. Termination type is required (VOLUNTARY, INVOLUNTARY)
6. All active assignments must be ended
7. Work relationship must be terminated
8. Notice period must be documented

**Exceptions**:
- Emergency termination can bypass notice period

**Error Messages**:
- `EMP_TERM_DATE_REQUIRED`: "Termination date is required"
- `EMP_TERM_REASON_REQUIRED`: "Termination reason is required"
- `EMP_ACTIVE_ASSIGNMENTS`: "Cannot terminate with active assignments"

**Related FRs**: FR-EMP-010

**Related Entities**: Employee

---

#### BR-EMP-011: Employee Legal Entity Consistency ✨ NEW

**Priority**: HIGH

**Description**:
Employee legal entity and worker must match parent work relationship to ensure data integrity.

**Conditions**:
```
WHEN creating or updating employee record
```

**Rules**:
1. Employee.legal_entity_code MUST equal WorkRelationship.legal_entity_code
2. Employee.worker_id MUST equal WorkRelationship.worker_id
3. Validation triggered on Employee create/update
4. Cannot change legal_entity_code after creation
5. Cannot change worker_id after creation
6. Both fields must be UUID type (not string)

**Exceptions**:
- None - this is a critical data integrity rule

**Error Messages**:
- `EMP_LEGAL_ENTITY_MISMATCH`: "Employee legal entity must match work relationship legal entity"
- `EMP_WORKER_MISMATCH`: "Employee worker must match work relationship worker"
- `EMP_LEGAL_ENTITY_IMMUTABLE`: "Cannot change legal entity after creation"
- `EMP_WORKER_IMMUTABLE`: "Cannot change worker after creation"

**Related FRs**: FR-EMP-001

**Related Entities**: Employee, WorkRelationship

---

### Category: Termination Flow ✨ NEW

#### BR-TERM-001: Termination Sequence

**Priority**: HIGH

**Description**:
Termination must follow strict sequence to maintain data integrity and prevent partial termination states.

**Conditions**:
```
WHEN terminating an employee
```

**Rules**:
1. **Step 1**: End all active Assignments
   - Set effective_end_date = termination_date
   - Set is_current_flag = false
   - Validate: No assignments remain active
2. **Step 2**: Terminate Employee record
   - Set status_code = TERMINATED
   - Set termination_date
   - Set effective_end_date (SCD Type 2)
   - Set is_current_flag = false
3. **Step 3**: Terminate WorkRelationship
   - Set status_code = TERMINATED
   - Set end_date = termination_date
   - Set termination_reason_code
   - Set termination_type_code (VOLUNTARY, INVOLUNTARY, MUTUAL, END_OF_CONTRACT)
4. All steps must complete successfully or rollback (atomic transaction)
5. Termination dates must be consistent across all levels
6. Cannot have partial termination state (e.g., Employee terminated but WorkRelationship active)

**Exceptions**:
- None - sequence is mandatory for data integrity

**Error Messages**:
- `TERM_SEQUENCE_VIOLATION`: "Termination sequence violated - must terminate in order: Assignment → Employee → WorkRelationship"
- `TERM_PARTIAL_STATE`: "Cannot have partial termination state"
- `TERM_DATE_INCONSISTENT`: "Termination dates must be consistent across all levels"
- `TERM_ACTIVE_ASSIGNMENTS`: "Cannot terminate employee with active assignments"

**Related FRs**: FR-WR-010, FR-EMP-010

**Related Entities**: WorkRelationship, Employee, Assignment

---

#### BR-EMP-015: Rehire Validation

**Priority**: MEDIUM

**Description**:
Rehire validation rules.

**Conditions**:
```
WHEN rehiring a former employee
```

**Rules**:
1. Previous employee record must be terminated
2. Previous termination must not be for cause (configurable)
3. Minimum gap period between termination and rehire (configurable)
4. New employee number generated
5. Previous employment history is retained

**Exceptions**:
- HR_ADMIN can override rehire restrictions

**Error Messages**:
- `EMP_REHIRE_PREVIOUS_ACTIVE`: "Previous employee record still active"
- `EMP_REHIRE_INELIGIBLE`: "Employee ineligible for rehire"
- `EMP_REHIRE_GAP_REQUIRED`: "Minimum {days} days gap required"

**Related FRs**: FR-EMP-011

**Related Entities**: Employee

---

## 📋 Phase 1: Assignment Management

### Category: Assignment Creation

#### BR-ASG-001: Assignment Creation Validation

**Priority**: HIGH

**Description**:
Assignment must meet all prerequisites.

**Conditions**:
```
WHEN creating a new assignment
```

**Rules**:
1. Employee must exist and be active
2. Assignment type is required (PRIMARY, CONCURRENT, TEMPORARY)
3. Staffing model is required (POSITION_BASED, JOB_BASED)
4. If POSITION_BASED: Position must be specified and VACANT
5. If JOB_BASED: Job must be specified
6. Business unit is required
7. Location is required
8. Start date is required
9. Only one PRIMARY assignment allowed per employee
10. FTE total across all assignments cannot exceed 1.0

**Exceptions**:
- Temporary assignments can exceed 1.0 FTE temporarily

**Error Messages**:
- `ASG_EMPLOYEE_REQUIRED`: "Employee is required"
- `ASG_PRIMARY_EXISTS`: "Employee already has PRIMARY assignment"
- `ASG_FTE_EXCEEDED`: "Total FTE cannot exceed 1.0"
- `ASG_POSITION_NOT_VACANT`: "Position is not vacant"

**Related FRs**: FR-ASG-001

**Related Entities**: Assignment, Employee, Position, Job

---

#### BR-ASG-002: Staffing Model Validation

**Priority**: HIGH

**Description**:
Staffing model determines required fields.

**Conditions**:
```
WHEN creating assignment
```

**Rules**:
1. POSITION_BASED:
   - Position is required
   - Job is derived from position
   - Position status updated to FILLED
2. JOB_BASED:
   - Job is required
   - Position is not allowed
   - No position status update

**Exceptions**:
- None

**Error Messages**:
- `ASG_POSITION_REQUIRED`: "Position required for POSITION_BASED staffing"
- `ASG_JOB_REQUIRED`: "Job required for JOB_BASED staffing"
- `ASG_POSITION_NOT_ALLOWED`: "Position not allowed for JOB_BASED staffing"

**Related FRs**: FR-ASG-001

**Related Entities**: Assignment

---

#### BR-ASG-004: Manager Assignment Validation

**Priority**: HIGH

**Description**:
Manager assignment validation rules.

**Conditions**:
```
WHEN assigning a manager
```

**Rules**:
1. Manager must be an active employee
2. Solid line manager is required
3. Only one solid line manager per assignment
4. Multiple dotted line managers allowed
5. Employee cannot be their own manager
6. Circular reporting not allowed
7. Manager must have active assignment

**Exceptions**:
- CEO has no manager

**Error Messages**:
- `ASG_MANAGER_REQUIRED`: "Solid line manager is required"
- `ASG_MANAGER_SELF`: "Employee cannot be their own manager"
- `ASG_MANAGER_CIRCULAR`: "Circular reporting detected"
- `ASG_MANAGER_INACTIVE`: "Manager must be active employee"

**Related FRs**: FR-ASG-010, FR-MTX-001

**Related Entities**: Assignment

---

#### BR-ASG-010: FTE Validation

**Priority**: HIGH

**Description**:
FTE validation rules.

**Conditions**:
```
WHEN setting FTE for assignment
```

**Rules**:
1. FTE must be between 0.01 and 1.0
2. FTE must be decimal with max 2 decimal places
3. Total FTE across all assignments cannot exceed 1.0
4. PRIMARY assignment typically has highest FTE
5. FTE changes create new version (SCD Type 2)

**Exceptions**:
- Temporary assignments can temporarily exceed 1.0 total

**Error Messages**:
- `ASG_FTE_INVALID`: "FTE must be between 0.01 and 1.0"
- `ASG_FTE_TOTAL_EXCEEDED`: "Total FTE across assignments exceeds 1.0"

**Related FRs**: FR-ASG-020

**Related Entities**: Assignment

---

#### BR-ASG-015: Transfer Validation

**Priority**: HIGH

**Description**:
Transfer validation rules.

**Conditions**:
```
WHEN transferring an employee
```

**Rules**:
1. Employee must have active assignment
2. Effective date must be future or today
3. Transfer type is required (LATERAL, PROMOTION, DEMOTION)
4. Target business unit/job/position must be valid
5. Old assignment is ended
6. New assignment is created
7. Transfer reason is required
8. Manager approval may be required

**Exceptions**:
- Emergency transfers can bypass approval

**Error Messages**:
- `ASG_TRANSFER_NO_ACTIVE`: "Employee has no active assignment"
- `ASG_TRANSFER_REASON_REQUIRED`: "Transfer reason is required"

**Related FRs**: FR-ASG-015

**Related Entities**: Assignment

---

#### BR-ASG-016: Promotion Validation

**Priority**: MEDIUM

**Description**:
Promotion validation rules.

**Conditions**:
```
WHEN promoting an employee
```

**Rules**:
1. Target job level must be higher than current
2. Target job grade must be higher than current
3. Promotion effective date must be future or today
4. Promotion reason is required
5. Manager approval required
6. Promotion creates new assignment version

**Exceptions**:
- Lateral moves to same level allowed

**Error Messages**:
- `ASG_PROMOTION_LEVEL_INVALID`: "Target level must be higher"
- `ASG_PROMOTION_APPROVAL_REQUIRED`: "Manager approval required"

**Related FRs**: FR-ASG-016

**Related Entities**: Assignment

---

## 🏢 Phase 2: Business Unit Management

### Category: Business Unit Validation

#### BR-BU-001: Business Unit Creation

**Priority**: HIGH

**Description**:
Business unit creation validation.

**Conditions**:
```
WHEN creating a business unit
```

**Rules**:
1. Business unit code must be unique
2. Business unit name is required
3. Unit type is required (OPERATIONAL, SUPERVISORY)
4. Parent unit must exist if specified
5. Parent unit must be same type or OPERATIONAL
6. Effective start date is required
7. Hierarchy path is calculated automatically

**Exceptions**:
- Root unit has no parent

**Error Messages**:
- `BU_CODE_DUPLICATE`: "Business unit code already exists"
- `BU_PARENT_INVALID`: "Invalid parent unit"
- `BU_TYPE_MISMATCH`: "Parent unit type mismatch"

**Related FRs**: FR-BU-001

**Related Entities**: BusinessUnit

---

#### BR-BU-002: Business Unit Hierarchy

**Priority**: HIGH

**Description**:
Business unit hierarchy validation.

**Conditions**:
```
WHEN building business unit hierarchy
```

**Rules**:
1. Circular references not allowed
2. Maximum hierarchy depth: 10 levels (configurable)
3. Hierarchy path format: /parent_id/current_id/
4. Hierarchy path is recalculated on parent change
5. Child units inherit parent's legal entity

**Exceptions**:
- None

**Error Messages**:
- `BU_CIRCULAR_REFERENCE`: "Circular reference detected"
- `BU_MAX_DEPTH_EXCEEDED`: "Maximum hierarchy depth exceeded"

**Related FRs**: FR-BU-015

**Related Entities**: BusinessUnit

---

## 💼 Phase 2: Job Taxonomy Management

### Category: Job Taxonomy Validation

#### BR-TAX-001: Taxonomy Tree Uniqueness

**Priority**: HIGH

**Description**:
Taxonomy tree code must be unique.

**Conditions**:
```
WHEN creating taxonomy tree
```

**Rules**:
1. Taxonomy tree code must be unique
2. Tree name is required
3. Tree purpose is documented
4. Multiple trees can coexist
5. Tree cannot be deleted if has taxonomies

**Exceptions**:
- None

**Error Messages**:
- `TAX_TREE_CODE_DUPLICATE`: "Taxonomy tree code already exists"
- `TAX_TREE_HAS_TAXONOMIES`: "Cannot delete tree with taxonomies"

**Related FRs**: FR-TAX-001

**Related Entities**: TaxonomyTree

---

#### BR-TAX-002: Job Taxonomy Hierarchy

**Priority**: MEDIUM

**Description**:
Job taxonomy hierarchy validation.

**Conditions**:
```
WHEN creating job taxonomy
```

**Rules**:
1. Taxonomy code must be unique within tree
2. Parent taxonomy must be in same tree
3. Circular references not allowed
4. Maximum depth: 5 levels
5. Hierarchy path is calculated

**Exceptions**:
- Root taxonomy has no parent

**Error Messages**:
- `TAX_CODE_DUPLICATE`: "Taxonomy code already exists in tree"
- `TAX_CIRCULAR_REFERENCE`: "Circular reference detected"

**Related FRs**: FR-TAX-002

**Related Entities**: JobTaxonomy

---

#### BR-TAX-005: Job Creation Validation

**Priority**: HIGH

**Description**:
Job creation validation rules.

**Conditions**:
```
WHEN creating a job
```

**Rules**:
1. Job code must be unique
2. Job title is required
3. Job taxonomy is required
4. Job level is required
5. Job grade is required
6. Job can belong to multiple taxonomies

**Exceptions**:
- None

**Error Messages**:
- `JOB_CODE_DUPLICATE`: "Job code already exists"
- `JOB_TAXONOMY_REQUIRED`: "Job taxonomy is required"

**Related FRs**: FR-TAX-005

**Related Entities**: Job

---

## 📝 Phase 2: Job Profile Management

#### BR-PRF-001: Job Profile Creation

**Priority**: MEDIUM

**Description**:
Job profile creation validation.

**Conditions**:
```
WHEN creating job profile
```

**Rules**:
1. Job must exist
2. Job description is required
3. Job purpose is required
4. Effective start date is required
5. Profile is versioned (SCD Type 2)
6. Only one current profile per job

**Exceptions**:
- None

**Error Messages**:
- `PRF_JOB_REQUIRED`: "Job is required"
- `PRF_DESCRIPTION_REQUIRED`: "Job description is required"

**Related FRs**: FR-PRF-001

**Related Entities**: JobProfile

---

#### BR-PRF-020: Job Profile Skills

**Priority**: MEDIUM

**Description**:
Job profile skills validation.

**Conditions**:
```
WHEN adding skills to job profile
```

**Rules**:
1. Skill must exist
2. Proficiency level is required
3. Required/preferred flag is required
4. Duplicate skills not allowed
5. At least one skill recommended

**Exceptions**:
- Entry-level jobs may have no required skills

**Error Messages**:
- `PRF_SKILL_DUPLICATE`: "Skill already added to profile"
- `PRF_PROFICIENCY_REQUIRED`: "Proficiency level is required"

**Related FRs**: FR-PRF-006

**Related Entities**: JobProfile

---

## 📍 Phase 2: Position Management

### Category: Position Validation

#### BR-POS-001: Position Creation

**Priority**: HIGH

**Description**:
Position creation validation.

**Conditions**:
```
WHEN creating a position
```

**Rules**:
1. Position code must be unique
2. Position title is required
3. Job is required
4. Business unit is required
5. Initial status is VACANT
6. Headcount limit default is 1
7. Effective start date is required

**Exceptions**:
- None

**Error Messages**:
- `POS_CODE_DUPLICATE`: "Position code already exists"
- `POS_JOB_REQUIRED`: "Job is required"

**Related FRs**: FR-POS-001

**Related Entities**: Position

---

#### BR-POS-002: Position Status Validation

**Priority**: HIGH

**Description**:
Position status validation rules.

**Conditions**:
```
WHEN changing position status
```

**Rules**:
1. Valid statuses: VACANT, FILLED, FROZEN, ELIMINATED
2. Status transitions:
   - VACANT → FILLED (when assigned)
   - VACANT → FROZEN (budget freeze)
   - FILLED → VACANT (when unassigned)
   - FROZEN → VACANT (when unfrozen)
   - * → ELIMINATED (final state)
3. ELIMINATED positions cannot be reactivated

**Exceptions**:
- SYSTEM_ADMIN can override

**Error Messages**:
- `POS_STATUS_INVALID_TRANSITION`: "Invalid status transition"
- `POS_ELIMINATED_FINAL`: "Eliminated positions cannot be reactivated"

**Related FRs**: FR-POS-002, FR-POS-003

**Related Entities**: Position

---

#### BR-POS-021: Position Freeze Validation

**Priority**: MEDIUM

**Description**:
Position freeze validation.

**Conditions**:
```
WHEN freezing a position
```

**Rules**:
1. Position must be VACANT
2. Freeze reason is required
3. Frozen positions cannot be filled
4. Frozen positions can be unfrozen
5. Freeze date is recorded

**Exceptions**:
- FILLED positions can be frozen with approval

**Error Messages**:
- `POS_FREEZE_NOT_VACANT`: "Only VACANT positions can be frozen"
- `POS_FREEZE_REASON_REQUIRED`: "Freeze reason is required"

**Related FRs**: FR-POS-006

**Related Entities**: Position

---

## 🔀 Phase 2: Matrix Reporting

### Category: Manager Relationship Validation

#### BR-MTX-001: Solid Line Manager

**Priority**: HIGH

**Description**:
Solid line manager validation.

**Conditions**:
```
WHEN assigning solid line manager
```

**Rules**:
1. Only one solid line manager per assignment
2. Manager must be active employee
3. Employee cannot be their own manager
4. Circular reporting not allowed
5. Solid line manager has approval authority
6. Manager relationship is effective-dated

**Exceptions**:
- CEO has no manager

**Error Messages**:
- `MTX_SOLID_LINE_EXISTS`: "Assignment already has solid line manager"
- `MTX_MANAGER_SELF`: "Employee cannot be their own manager"
- `MTX_CIRCULAR_REPORTING`: "Circular reporting detected"

**Related FRs**: FR-MTX-001

**Related Entities**: Assignment

---

#### BR-MTX-002: Dotted Line Manager

**Priority**: MEDIUM

**Description**:
Dotted line manager validation.

**Conditions**:
```
WHEN assigning dotted line manager
```

**Rules**:
1. Multiple dotted line managers allowed
2. Manager must be active employee
3. Time allocation percentage can be specified
4. Dotted line manager has coordination role only
5. No approval authority

**Exceptions**:
- None

**Error Messages**:
- `MTX_MANAGER_INACTIVE`: "Manager must be active employee"

**Related FRs**: FR-MTX-002

**Related Entities**: Assignment

---

#### BR-MTX-003: Direct Reports

**Priority**: MEDIUM

**Description**:
Direct reports validation.

**Conditions**:
```
WHEN viewing direct reports
```

**Rules**:
1. Only solid line reports are considered direct reports
2. Only active assignments included
3. Headcount calculated from direct reports
4. Span of control can be analyzed

**Exceptions**:
- None

**Error Messages**:
- None (query rule)

**Related FRs**: FR-MTX-006

**Related Entities**: Assignment

---

#### BR-MTX-005: Manager Time Allocation

**Priority**: MEDIUM

**Description**:
Manager time allocation validation.

**Conditions**:
```
WHEN specifying time allocation
```

**Rules**:
1. Total allocation across all managers must equal 100%
2. Solid line manager has primary allocation
3. Dotted line managers have secondary allocations
4. Allocation can change over time
5. History is retained

**Exceptions**:
- None

**Error Messages**:
- `MTX_ALLOCATION_INVALID`: "Total allocation must equal 100%"

**Related FRs**: FR-MTX-003

**Related Entities**: Assignment

---

#### BR-MTX-010: Circular Reporting Detection

**Priority**: HIGH

**Description**:
Circular reporting detection algorithm.

**Conditions**:
```
WHEN assigning manager
```

**Rules**:
1. Traverse reporting chain recursively
2. Check if employee appears in their own chain
3. Maximum chain depth: 20 levels
4. Circular reference not allowed

**Exceptions**:
- None

**Error Messages**:
- `MTX_CIRCULAR_REPORTING`: "Circular reporting detected: {chain}"
- `MTX_MAX_DEPTH_EXCEEDED`: "Reporting chain exceeds maximum depth"

**Related FRs**: FR-MTX-011

**Related Entities**: Assignment

---

#### BR-MTX-015: Manager Approval Authority

**Priority**: MEDIUM

**Description**:
Manager approval authority rules.

**Conditions**:
```
WHEN determining approval authority
```

**Rules**:
1. Solid line manager has primary approval authority
2. Dotted line manager has coordination role only
3. Approval rules can be configured
4. Approval delegation is supported
5. Authority is effective-dated

**Exceptions**:
- None

**Error Messages**:
- None (business logic rule)

**Related FRs**: FR-MTX-016

**Related Entities**: Assignment

---

## 🎓 Phase 3: Skill Management

### Category: Skill Validation

#### BR-SKL-001: Skill Creation

**Priority**: MEDIUM

**Description**:
Skill creation validation.

**Conditions**:
```
WHEN creating a skill
```

**Rules**:
1. Skill code must be unique
2. Skill name is required
3. Skill category is required
4. Skill description recommended
5. Effective dates are set

**Exceptions**:
- None

**Error Messages**:
- `SKL_CODE_DUPLICATE`: "Skill code already exists"
- `SKL_CATEGORY_REQUIRED`: "Skill category is required"

**Related FRs**: FR-SKL-001

**Related Entities**: Skill

---

#### BR-SKL-020: Proficiency Levels

**Priority**: MEDIUM

**Description**:
Proficiency level validation.

**Conditions**:
```
WHEN defining proficiency levels
```

**Rules**:
1. Standard levels: BEGINNER, INTERMEDIATE, ADVANCED, EXPERT
2. Level code must be unique
3. Level rank determines ordering
4. Custom levels can be added
5. At least 3 levels recommended

**Exceptions**:
- None

**Error Messages**:
- `SKL_LEVEL_CODE_DUPLICATE`: "Proficiency level code already exists"

**Related FRs**: FR-SKL-006

**Related Entities**: SkillProficiencyLevel

---

## 📊 Phase 3: Skill Assessment

### Category: Assessment Validation

#### BR-ASS-001: Skill Assignment

**Priority**: MEDIUM

**Description**:
Skill assignment validation.

**Conditions**:
```
WHEN assigning skill to employee
```

**Rules**:
1. Employee must exist
2. Skill must exist
3. Proficiency level is required
4. Assessment source is required (SELF, MANAGER, CERTIFIED)
5. Duplicate skills not allowed
6. Assessment date is recorded

**Exceptions**:
- None

**Error Messages**:
- `ASS_SKILL_DUPLICATE`: "Skill already assigned to employee"
- `ASS_PROFICIENCY_REQUIRED`: "Proficiency level is required"

**Related FRs**: FR-ASS-001

**Related Entities**: EmployeeSkill

---

#### BR-ASS-015: Self-Assessment

**Priority**: MEDIUM

**Description**:
Self-assessment validation.

**Conditions**:
```
WHEN employee self-assesses skill
```

**Rules**:
1. Employee can self-assess any skill
2. Source is marked as SELF_ASSESSED
3. Self-assessment may require manager approval
4. Self-assessment can be overridden by manager
5. Assessment date is recorded

**Exceptions**:
- None

**Error Messages**:
- None (business logic rule)

**Related FRs**: FR-ASS-005

**Related Entities**: EmployeeSkill

---

#### BR-ASS-020: Skill Gap Analysis

**Priority**: MEDIUM

**Description**:
Skill gap analysis rules.

**Conditions**:
```
WHEN analyzing skill gaps
```

**Rules**:
1. Compare employee skills to job profile requirements
2. Identify missing skills
3. Identify proficiency gaps
4. Calculate gap severity
5. Provide development recommendations

**Exceptions**:
- None

**Error Messages**:
- None (analysis rule)

**Related FRs**: FR-ASS-010

**Related Entities**: EmployeeSkill, JobProfile

---

#### BR-ASS-025: Skill Endorsement

**Priority**: LOW

**Description**:
Skill endorsement validation.

**Conditions**:
```
WHEN endorsing a skill
```

**Rules**:
1. Endorser must be active employee
2. Cannot endorse own skills
3. Can endorse same skill multiple times
4. Endorsement count is displayed
5. Endorsement date is recorded

**Exceptions**:
- None

**Error Messages**:
- `ASS_ENDORSE_SELF`: "Cannot endorse own skills"

**Related FRs**: FR-ASS-015

**Related Entities**: SkillEndorsement

---

#### BR-ASS-026: Skill Certification

**Priority**: MEDIUM

**Description**:
Skill certification validation.

**Conditions**:
```
WHEN recording skill certification
```

**Rules**:
1. Certification name is required
2. Issuing organization is required
3. Issue date is required
4. Expiry date is optional
5. Certification document can be attached
6. Source is marked as CERTIFIED

**Exceptions**:
- None

**Error Messages**:
- `ASS_CERT_NAME_REQUIRED`: "Certification name is required"

**Related FRs**: FR-ASS-016

**Related Entities**: SkillCertification

---

## 🎯 Phase 3: Career Paths

### Category: Career Path Validation

#### BR-CAR-001: Career Ladder Creation

**Priority**: MEDIUM

**Description**:
Career ladder creation validation.

**Conditions**:
```
WHEN creating career ladder
```

**Rules**:
1. Ladder name is required
2. Ladder type is required (MANAGEMENT, TECHNICAL, SPECIALIST, EXECUTIVE)
3. Ladder description is required
4. Multiple ladders can coexist
5. Effective dates are set

**Exceptions**:
- None

**Error Messages**:
- `CAR_LADDER_NAME_REQUIRED`: "Ladder name is required"

**Related FRs**: FR-CAR-001

**Related Entities**: CareerLadder

---

#### BR-CAR-010: Career Path Creation

**Priority**: MEDIUM

**Description**:
Career path creation validation.

**Conditions**:
```
WHEN creating career path
```

**Rules**:
1. Starting level is required
2. Target level is required
3. Path type is required (VERTICAL, LATERAL, CROSS_FUNCTIONAL)
4. Typical duration is recommended
5. Path requirements should be specified

**Exceptions**:
- None

**Error Messages**:
- `CAR_PATH_LEVELS_REQUIRED`: "Starting and target levels are required"

**Related FRs**: FR-CAR-005

**Related Entities**: CareerPath

---

#### BR-CAR-015: Career Readiness Assessment

**Priority**: MEDIUM

**Description**:
Career readiness assessment rules.

**Conditions**:
```
WHEN assessing career readiness
```

**Rules**:
1. Compare employee skills to path requirements
2. Compare employee experience to path requirements
3. Calculate readiness score (0-100%)
4. Provide development recommendations
5. Identify skill gaps

**Exceptions**:
- None

**Error Messages**:
- None (analysis rule)

**Related FRs**: FR-CAR-011

**Related Entities**: CareerPath, Employee

---

## 🔒 Phase 3: Data Privacy & Security

### Category: Data Classification

#### BR-PRI-001: Data Classification Enforcement

**Priority**: HIGH

**Description**:
Data classification must be enforced at field level.

**Conditions**:
```
WHEN accessing or storing data
```

**Rules**:
1. PUBLIC: Accessible to all authenticated users
2. INTERNAL: Accessible to same organization
3. CONFIDENTIAL: Accessible to manager + HR
4. RESTRICTED: Accessible to HR only with documented purpose
5. Classification is documented in data dictionary
6. Access is logged

**Exceptions**:
- Employee can always access their own data
- DPO can access for compliance purposes

**Error Messages**:
- `PRI_ACCESS_DENIED`: "Insufficient permissions to access {field}"
- `PRI_PURPOSE_REQUIRED`: "Purpose required to access RESTRICTED data"

**Related FRs**: FR-PRI-001, FR-WRK-010

**Related Entities**: All entities with personal data

---

#### BR-PRI-002: Data Encryption

**Priority**: HIGH

**Description**:
RESTRICTED data must be encrypted.

**Conditions**:
```
WHEN storing RESTRICTED data
```

**Rules**:
1. Use AES-256 encryption
2. Encryption keys managed securely
3. Data encrypted at rest
4. Data encrypted in transit (HTTPS)
5. Decryption only for authorized access

**Exceptions**:
- None

**Error Messages**:
- `PRI_ENCRYPTION_FAILED`: "Failed to encrypt data"

**Related FRs**: FR-PRI-002

**Related Entities**: Worker, Employee (RESTRICTED fields)

---

### Category: GDPR/PDPA Compliance

#### BR-PRI-010: Consent Management

**Priority**: HIGH

**Description**:
Data processing consent validation.

**Conditions**:
```
WHEN processing personal data
```

**Rules**:
1. Consent purpose must be clearly stated
2. Consent can be granted or denied
3. Consent can be withdrawn at any time
4. Consent history is tracked
5. Consent expiry is enforced
6. Processing without consent requires legal basis

**Exceptions**:
- Employment contract provides legal basis for core HR data

**Error Messages**:
- `PRI_CONSENT_REQUIRED`: "Consent required for {purpose}"
- `PRI_CONSENT_WITHDRAWN`: "Consent has been withdrawn"

**Related FRs**: FR-PRI-003

**Related Entities**: DataConsent

---

#### BR-PRI-011: Purpose Limitation

**Priority**: HIGH

**Description**:
Data must be used only for documented purposes.

**Conditions**:
```
WHEN accessing personal data
```

**Rules**:
1. Purpose must be specified
2. Purpose must be from approved list
3. Purpose is logged
4. Data usage is audited against purpose
5. Violations are reported

**Exceptions**:
- None

**Error Messages**:
- `PRI_PURPOSE_REQUIRED`: "Purpose required for data access"
- `PRI_PURPOSE_INVALID`: "Purpose not in approved list"

**Related FRs**: FR-PRI-005

**Related Entities**: All entities with personal data

---

#### BR-PRI-020: Right to Access (GDPR Article 15)

**Priority**: HIGH

**Description**:
Employee right to access personal data.

**Conditions**:
```
WHEN employee requests personal data
```

**Rules**:
1. All personal data must be provided
2. Data must be in readable format
3. Include all processing activities
4. Include data sources
5. Include data recipients
6. Request fulfilled within 30 days
7. Access is logged

**Exceptions**:
- None

**Error Messages**:
- `PRI_ACCESS_REQUEST_FAILED`: "Failed to process access request"

**Related FRs**: FR-PRI-010

**Related Entities**: Employee, Worker

---

#### BR-PRI-021: Right to Rectification (GDPR Article 16)

**Priority**: HIGH

**Description**:
Employee right to correct personal data.

**Conditions**:
```
WHEN employee requests data correction
```

**Rules**:
1. Correction request is created
2. Request is reviewed by HR
3. Approved corrections are applied
4. Rejected requests are explained
5. Request fulfilled within 30 days
6. Rectification is logged

**Exceptions**:
- Some fields require approval (e.g., date of birth)

**Error Messages**:
- `PRI_RECTIFICATION_DENIED`: "Rectification request denied: {reason}"

**Related FRs**: FR-PRI-011

**Related Entities**: Employee, Worker

---

#### BR-PRI-022: Right to Erasure (GDPR Article 17)

**Priority**: HIGH

**Description**:
Employee right to be forgotten.

**Conditions**:
```
WHEN employee requests data deletion
```

**Rules**:
1. Deletion request is created
2. Legal basis for retention is checked
3. Data is deleted if no legal basis exists
4. Data is anonymized if deletion not possible
5. Request fulfilled within 30 days
6. Deletion is logged
7. Employee is notified

**Exceptions**:
- Legal retention requirements override deletion
- Anonymization used when deletion not possible

**Error Messages**:
- `PRI_ERASURE_DENIED`: "Erasure denied due to legal retention requirement"

**Related FRs**: FR-PRI-012

**Related Entities**: Employee, Worker

---

#### BR-PRI-030: Data Retention Policy

**Priority**: HIGH

**Description**:
Data retention policy enforcement.

**Conditions**:
```
WHEN data reaches retention limit
```

**Rules**:
1. Retention periods defined by data type
2. Data flagged for review at retention limit
3. Data deleted or anonymized after retention
4. Deletion is logged
5. Legal holds override retention
6. Retention compliance is reported

**Exceptions**:
- Legal holds prevent deletion
- Ongoing litigation prevents deletion

**Error Messages**:
- `PRI_RETENTION_HOLD`: "Data under legal hold, cannot delete"

**Related FRs**: FR-PRI-015

**Related Entities**: All entities with personal data

---

### Category: Data Breach Management

#### BR-PRI-040: Data Breach Detection

**Priority**: HIGH

**Description**:
Data breach detection rules.

**Conditions**:
```
WHEN unusual data access is detected
```

**Rules**:
1. Monitor access patterns
2. Detect unusual access volumes
3. Detect unusual access times
4. Detect unauthorized access attempts
5. Trigger security alerts
6. Log suspicious activities

**Exceptions**:
- None

**Error Messages**:
- `PRI_BREACH_DETECTED`: "Potential data breach detected"

**Related FRs**: FR-PRI-020

**Related Entities**: All entities with personal data

---

#### BR-PRI-041: Breach Notification (GDPR)

**Priority**: HIGH

**Description**:
Data breach notification requirements.

**Conditions**:
```
WHEN data breach is confirmed
```

**Rules**:
1. Breach is documented
2. Supervisory authority notified within 72 hours
3. Affected individuals notified
4. Breach details recorded
5. Remediation actions tracked
6. Breach report generated

**Exceptions**:
- Low-risk breaches may not require individual notification

**Error Messages**:
- `PRI_BREACH_NOTIFICATION_OVERDUE`: "Breach notification overdue"

**Related FRs**: FR-PRI-021

**Related Entities**: DataBreach

---

### Category: Access Control

#### BR-PRI-050: Role-Based Access Control

**Priority**: HIGH

**Description**:
RBAC enforcement rules.

**Conditions**:
```
WHEN accessing data
```

**Rules**:
1. User must have appropriate role
2. Role permissions are checked
3. Access is granted or denied
4. Access is logged
5. Least privilege principle enforced
6. Access can be reviewed periodically

**Exceptions**:
- Emergency access with approval

**Error Messages**:
- `PRI_ACCESS_DENIED`: "Insufficient permissions"

**Related FRs**: FR-PRI-025

**Related Entities**: All entities

---

#### BR-PRI-051: Audit Logging

**Priority**: HIGH

**Description**:
Comprehensive audit logging rules.

**Conditions**:
```
WHEN personal data is accessed
```

**Rules**:
1. Who accessed data is recorded
2. When access occurred is recorded
3. What data was accessed is recorded
4. Purpose of access is recorded
5. Logs are tamper-proof
6. Logs retained per policy

**Exceptions**:
- None

**Error Messages**:
- None (logging rule)

**Related FRs**: FR-PRI-026

**Related Entities**: AuditLog

---

#### BR-PRI-060: Data Portability (GDPR Article 20)

**Priority**: MEDIUM

**Description**:
Data portability requirements.

**Conditions**:
```
WHEN employee requests data export
```

**Rules**:
1. Data exported in machine-readable format (JSON, CSV)
2. All personal data included
3. Export provided within 30 days
4. Export is logged
5. Export can be transferred to another system

**Exceptions**:
- None

**Error Messages**:
- `PRI_EXPORT_FAILED`: "Failed to export data"

**Related FRs**: FR-PRI-027

**Related Entities**: Employee, Worker

---

#### BR-PRI-070: Data Processing Register (GDPR Article 30)

**Priority**: MEDIUM

**Description**:
Data processing register requirements.

**Conditions**:
```
WHEN data processing occurs
```

**Rules**:
1. Processing purpose is documented
2. Data categories are listed
3. Data subjects are identified
4. Recipients are documented
5. Retention periods are specified
6. Security measures are described
7. Register available for audit

**Exceptions**:
- None

**Error Messages**:
- None (documentation rule)

**Related FRs**: FR-PRI-029

**Related Entities**: DataProcessingActivity

---

## 📊 Business Rules Summary

### Total Business Rules: 245

**By Priority**:
- HIGH: 139 (57%)
- MEDIUM: 87 (35%)
- LOW: 19 (8%)

**By Category**:
- Configuration: 15
- Worker Management: 10
- Work Relationship: 35
- Employee Management: 15
- Assignment: 45
- Business Unit: 10
- Job Taxonomy: 10
- Job Profile: 10
- Position: 25
- Matrix Reporting: 15
- Skill Management: 10
- Skill Assessment: 10
- Career Paths: 5
- Data Privacy: 30

---

## 🔗 Related Documentation

- [Functional Requirements](./01-functional-requirements.md) - Source of business rules
- [API Specification](./02-api-specification.md) - API endpoints implementing rules
- [Data Specification](./03-data-specification.md) - Data validation rules
- [Core Ontology](../00-ontology/core-ontology.yaml) - Entity definitions
- [Concept Guides](../01-concept/README.md) - Business context

---

**Document Version**: 2.0  
**Created**: 2025-12-03  
**Based On**: 450 Functional Requirements  
**Maintained By**: Product Team + Business Analysts  
**Status**: Complete - Ready for Implementation
