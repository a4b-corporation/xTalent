---
entity: LegalEntity
domain: organization
version: "1.0.0"
status: approved
owner: Organization Domain Team
tags: [legal-entity, company, compliance, tax]

attributes:
  # === IDENTITY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  - name: code
    type: string
    required: true
    unique: true
    description: Business code for legal entity (unique across system). Used in Employee.legalEntityCode.
    constraints:
      pattern: "^[A-Z0-9-]{3,20}$"
  
  - name: name
    type: string
    required: true
    description: Full legal registered name (Tên đăng ký kinh doanh)
    constraints:
      maxLength: 200
  
  - name: shortName
    type: string
    required: false
    description: Short/display name for UI
    constraints:
      maxLength: 50
  
  - name: statusCode
    type: enum
    required: true
    description: Current legal entity status. Aligned with xTalent naming convention.
    values: [PENDING, ACTIVE, INACTIVE, DISSOLVED, MERGED]
    default: PENDING
  
  # === LEGAL REGISTRATION ===
  - name: countryCode
    type: string
    required: true
    description: Country of registration (ISO 3166-1 alpha-2). Reference to Country entity.
    constraints:
      pattern: "^[A-Z]{2}$"
  
  - name: legalFormCode
    type: string
    required: false
    description: Legal structure type (LLC, JSC, PRIVATE, PARTNERSHIP, BRANCH, REP_OFFICE). Reference to CODELIST_LEGAL_FORM.
    constraints:
      reference: CODELIST_LEGAL_FORM
  
  - name: registrationNumber
    type: string
    required: false
    description: Business registration number (Mã số doanh nghiệp - VN 10 digits)
    constraints:
      maxLength: 50
    metadata:
      pii: false
      sensitivity: low
  
  - name: incorporationDate
    type: date
    required: false
    description: Date of incorporation/establishment (Ngày thành lập)
  
  - name: registrationAuthority
    type: string
    required: false
    description: Registering government body (e.g., Sở Kế hoạch và Đầu tư TP.HCM)
    constraints:
      maxLength: 200
  
  # === TAX REGISTRATION ===
  - name: taxId
    type: string
    required: false
    description: Primary tax identifier (Mã số thuế - usually same as registrationNumber in VN)
    constraints:
      maxLength: 50
    metadata:
      pii: false
      sensitivity: medium
  
  - name: federalTaxId
    type: string
    required: false
    description: Federal tax ID (for US or federal/state tax systems)
    constraints:
      maxLength: 50
  
  - name: vatNumber
    type: string
    required: false
    description: VAT/GST registration number (if applicable)
    constraints:
      maxLength: 50
  
  # === VN SPECIFIC COMPLIANCE ===
  - name: socialInsuranceCode
    type: string
    required: false
    description: Social Insurance unit code (Mã đơn vị BHXH - VN specific)
    constraints:
      maxLength: 50
    metadata:
      pii: false
      sensitivity: medium
  
  - name: laborRegistrationNumber
    type: string
    required: false
    description: Labor registration number (Đăng ký sử dụng lao động - VN specific)
    constraints:
      maxLength: 50
  
  - name: laborDepartmentCode
    type: string
    required: false
    description: Labor Department code (Mã Sở LĐTBXH - VN specific)
    constraints:
      maxLength: 50
  
  - name: taxDepartmentCode
    type: string
    required: false
    description: Tax Department code (Mã Cục thuế quản lý - VN specific)
    constraints:
      maxLength: 50
  
  # === OPERATIONAL ===
  - name: defaultCurrencyCode
    type: string
    required: false
    description: Default operating currency (ISO 4217 code). Reference to Currency entity.
    constraints:
      pattern: "^[A-Z]{3}$"
  
  - name: industryCode
    type: string
    required: false
    description: Industry/activity classification (ISIC/NAICS code)
    constraints:
      maxLength: 20
  
  # === CLASSIFICATION FLAGS (Oracle Pattern) ===
  - name: isLegalEmployer
    type: boolean
    required: true
    default: true
    description: Can this entity directly employ workers? (Legal Employer classification)
  
  - name: isPayrollStatutoryUnit
    type: boolean
    required: true
    default: false
    description: Is this entity responsible for payroll taxes? (PSU classification)
  
  - name: isTaxReportingUnit
    type: boolean
    required: true
    default: false
    description: Is this entity a tax reporting unit? (TRU classification)
  
  # === HIERARCHY ===
  - name: parentLegalEntityId
    type: string
    required: false
    description: Reference to parent legal entity (for corporate group hierarchy)
  
  # === DATE EFFECTIVENESS ===
  - name: effectiveStartDate
    type: date
    required: true
    description: Date this legal entity becomes active/effective
  
  - name: effectiveEndDate
    type: date
    required: false
    description: Date this legal entity becomes inactive (null = indefinite)
  
  # === METADATA ===
  - name: metadata
    type: json
    required: false
    description: Additional flexible data (licenses, certifications, etc.)
  
  # === AUDIT ===
  - name: createdAt
    type: datetime
    required: true
    description: Record creation timestamp
  
  - name: updatedAt
    type: datetime
    required: true
    description: Last modification timestamp
  
  - name: createdBy
    type: string
    required: true
    description: User who created the record
  
  - name: updatedBy
    type: string
    required: true
    description: User who last modified the record

relationships:
  - name: registeredInCountry
    target: Country
    cardinality: many-to-one
    required: true
    inverse: hasLegalEntities
    description: Country where this legal entity is registered. INVERSE - Country.hasLegalEntities must reference this LegalEntity.
  
  - name: usesDefaultCurrency
    target: Currency
    cardinality: many-to-one
    required: false
    inverse: usedByLegalEntities
    description: Default operating currency. INVERSE - Currency.usedByLegalEntities must reference this LegalEntity.
  
  - name: hasParentEntity
    target: LegalEntity
    cardinality: many-to-one
    required: false
    inverse: hasChildEntities
    description: Parent legal entity in corporate hierarchy (self-referential). INVERSE - LegalEntity.hasChildEntities must reference this LegalEntity.
  
  - name: hasChildEntities
    target: LegalEntity
    cardinality: one-to-many
    required: false
    inverse: hasParentEntity
    description: Child legal entities (subsidiaries, branches) - self-referential. INVERSE - LegalEntity.hasParentEntity must reference this LegalEntity.
  
  - name: hasEmployees
    target: Employee
    cardinality: one-to-many
    required: false
    inverse: belongsToLegalEntity
    description: Employees employed by this legal entity. INVERSE - Employee.belongsToLegalEntity must reference this LegalEntity.
  
  - name: hasWorkRelationships
    target: WorkRelationship
    cardinality: one-to-many
    required: false
    inverse: belongsToLegalEmployer
    description: Work relationships with this legal entity. INVERSE - WorkRelationship.belongsToLegalEmployer must reference this LegalEntity.
  
  - name: hasDepartments
    target: Department
    cardinality: one-to-many
    required: false
    inverse: belongsToLegalEntity
    description: Departments/Business Units under this legal entity. INVERSE - Department.belongsToLegalEntity must reference this LegalEntity.
  
  - name: hasAddresses
    target: Address
    cardinality: one-to-many
    required: false
    inverse: belongsToLegalEntity
    description: Legal/business addresses. INVERSE - Address.belongsToLegalEntity must reference this LegalEntity.
  
  - name: hasBankAccounts
    target: BankAccount
    cardinality: one-to-many
    required: false
    inverse: belongsToLegalEntity
    description: Company bank accounts. INVERSE - BankAccount.belongsToLegalEntity must reference this LegalEntity.
  
  - name: hasRepresentatives
    target: LegalRepresentative
    cardinality: one-to-many
    required: false
    inverse: representsLegalEntity
    description: Legal representatives authorized to sign contracts on behalf of this entity. INVERSE - LegalRepresentative.representsLegalEntity must reference this LegalEntity.
  
  - name: hasWorkLocations
    target: WorkLocation
    cardinality: one-to-many
    required: false
    inverse: ownedByLegalEntity
    description: Work locations owned/operated by this legal entity. INVERSE - WorkLocation.ownedByLegalEntity.

lifecycle:
  states: [PENDING, ACTIVE, INACTIVE, DISSOLVED, MERGED]
  initial: PENDING
  terminal: [DISSOLVED, MERGED]
  transitions:
    - from: PENDING
      to: ACTIVE
      trigger: activate
      guard: Registration completed, all required documents submitted
    - from: ACTIVE
      to: INACTIVE
      trigger: suspend
      guard: Temporary suspension (business license suspended, etc.)
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate
      guard: Suspension lifted, entity resumes operations
    - from: ACTIVE
      to: DISSOLVED
      trigger: dissolve
      guard: Legal dissolution process completed
    - from: ACTIVE
      to: MERGED
      trigger: merge
      guard: Merged into another legal entity (M&A)
    - from: INACTIVE
      to: DISSOLVED
      trigger: dissolve
      guard: Dissolution during suspension period

policies:
  - name: LegalEntityCodeUniqueness
    type: validation
    rule: code must be unique across all legal entities
    expression: "COUNT(LegalEntity WHERE code = X) = 1"
    severity: ERROR
  
  - name: RegistrationNumberUniqueness
    type: validation
    rule: registrationNumber must be unique within country (if set)
    expression: "registrationNumber IS NULL OR COUNT(LegalEntity WHERE registrationNumber = X AND countryCode = Y) = 1"
    severity: ERROR
  
  - name: TaxIdUniqueness
    type: validation
    rule: taxId must be unique within country (if set)
    expression: "taxId IS NULL OR COUNT(LegalEntity WHERE taxId = X AND countryCode = Y) = 1"
    severity: ERROR
  
  - name: EffectiveDateConsistency
    type: validation
    rule: effectiveStartDate must be before effectiveEndDate (if set)
    expression: "effectiveEndDate IS NULL OR effectiveStartDate < effectiveEndDate"
  
  - name: ActiveEntityRequirements
    type: validation
    rule: ACTIVE legal entity must have registrationNumber and taxId
    expression: "statusCode != ACTIVE OR (registrationNumber IS NOT NULL AND taxId IS NOT NULL)"
    severity: WARNING
  
  - name: LegalEmployerFlag
    type: business
    rule: If isLegalEmployer = true, entity can have Employees and WorkRelationships
    severity: INFO
  
  - name: ParentChildConsistency
    type: validation
    rule: Legal entity cannot be its own parent (prevent circular hierarchy)
    expression: "parentLegalEntityId IS NULL OR parentLegalEntityId != id"
    severity: ERROR
  
  - name: VNRegistrationFormat
    type: validation
    rule: For VN entities, registrationNumber should be 10 digits
    expression: "countryCode != 'VN' OR registrationNumber IS NULL OR LENGTH(registrationNumber) = 10"
    severity: WARNING
  
  - name: VNSocialInsuranceRequired
    type: business
    rule: For VN entities with employees, socialInsuranceCode is required
    expression: "countryCode != 'VN' OR socialInsuranceCode IS NOT NULL"
    severity: WARNING
  
  - name: DissolvedEntityRestrictions
    type: business
    rule: DISSOLVED or MERGED entities cannot have new Employees or WorkRelationships
    trigger: ON_CREATE(Employee, WorkRelationship)
    severity: ERROR
  
  - name: InactiveEntityWarning
    type: business
    rule: INACTIVE entities should not have ACTIVE employees
    severity: WARNING
---

# Entity: LegalEntity

## 1. Overview

The **LegalEntity** represents a legally recognized organization with rights and responsibilities under commercial law. It serves as the **legal employer** for payroll, tax reporting, and regulatory compliance purposes. This is the fundamental entity for multi-company HCM implementations.

**Key Concept**:
```
LegalEntity = Legal/Tax boundary for employment
Employee belongs to ONE LegalEntity
WorkRelationship links Worker to LegalEntity
```

```mermaid
mindmap
  root((LegalEntity))
    Identity
      id
      code
      name
      shortName
      statusCode
    Legal Registration
      countryCode
      legalFormCode
      registrationNumber
      incorporationDate
      registrationAuthority
    Tax Registration
      taxId
      federalTaxId
      vatNumber
    VN Compliance
      socialInsuranceCode
      laborRegistrationNumber
      laborDepartmentCode
      taxDepartmentCode
    Operational
      defaultCurrencyCode
      industryCode
    Classification Flags
      isLegalEmployer
      isPayrollStatutoryUnit
      isTaxReportingUnit
    Hierarchy
      parentLegalEntityId
      hasChildEntities
    Date Effectiveness
      effectiveStartDate
      effectiveEndDate
    Relationships
      registeredInCountry
      usesDefaultCurrency
      hasParentEntity
      hasChildEntities
      hasEmployees
      hasWorkRelationships
      hasDepartments
      hasAddresses
      hasBankAccounts
      hasRepresentatives
    Lifecycle
      PENDING
      ACTIVE
      INACTIVE
      DISSOLVED
      MERGED
```

**Design Rationale**:
- **Legal/Tax Focus**: Handles legal registration, tax compliance, NOT management hierarchy
- **Multi-Company Support**: Corporate groups with parent-child relationships
- **VN Compliance**: Full support for VN Enterprise Law and tax requirements
- **Classification Flags**: Oracle pattern for Legal Employer, PSU, TRU

---

## 2. Attributes

### 2.1 Identity Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique internal identifier (UUID) |
| code | string | ✓ | Business code (unique, used in references) |
| name | string | ✓ | Full legal registered name |
| shortName | string | | Short/display name |
| statusCode | enum | ✓ | PENDING, ACTIVE, INACTIVE, DISSOLVED, MERGED |

### 2.2 Legal Registration Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| countryCode | string | ✓ | Country of registration (ISO 3166-1) |
| legalFormCode | string | | Legal structure (LLC, JSC, etc.) |
| registrationNumber | string | | Business registration ID |
| incorporationDate | date | | Date of incorporation |
| registrationAuthority | string | | Registering government body |

### 2.3 Tax Registration Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| taxId | string | | Primary tax identifier |
| federalTaxId | string | | Federal tax ID (US/federal systems) |
| vatNumber | string | | VAT/GST registration |

### 2.4 VN Specific Compliance Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| socialInsuranceCode | string | | Mã đơn vị BHXH |
| laborRegistrationNumber | string | | Đăng ký sử dụng lao động |
| laborDepartmentCode | string | | Mã Sở LĐTBXH |
| taxDepartmentCode | string | | Mã Cục thuế quản lý |

### 2.5 Operational Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| defaultCurrencyCode | string | | Default currency (ISO 4217) |
| industryCode | string | | Industry classification (ISIC/NAICS) |

### 2.6 Classification Flags (Oracle Pattern)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| isLegalEmployer | boolean | ✓ | Can employ workers? |
| isPayrollStatutoryUnit | boolean | ✓ | Responsible for payroll taxes? |
| isTaxReportingUnit | boolean | ✓ | Tax reporting unit? |

### 2.7 Hierarchy Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| parentLegalEntityId | string | | Parent entity (corporate group) |

### 2.8 Date Effectiveness Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| effectiveStartDate | date | ✓ | Entity becomes active |
| effectiveEndDate | date | | Entity becomes inactive |

### 2.9 Audit Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| createdAt | datetime | ✓ | Record creation timestamp |
| updatedAt | datetime | ✓ | Last modification timestamp |
| createdBy | string | ✓ | User who created record |
| updatedBy | string | ✓ | User who last modified |

---

## 3. Relationships

```mermaid
erDiagram
    Country ||--o{ LegalEntity : hasLegalEntities
    Currency ||--o{ LegalEntity : usedByLegalEntities
    LegalEntity ||--o{ LegalEntity : hasChildEntities
    LegalEntity ||--o{ Employee : hasEmployees
    LegalEntity ||--o{ WorkRelationship : hasWorkRelationships
    LegalEntity ||--o{ Department : hasDepartments
    LegalEntity ||--o{ Address : hasAddresses
    LegalEntity ||--o{ BankAccount : hasBankAccounts
    LegalEntity ||--o{ LegalRepresentative : hasRepresentatives
    
    LegalEntity {
        string id PK
        string code UK
        string name
        string countryCode FK
        enum statusCode
        string registrationNumber
        string taxId
        boolean isLegalEmployer
    }
    
    Country {
        string code PK
        string name
    }
    
    Employee {
        string id PK
        string legalEntityCode FK
    }
    
    Department {
        string id PK
        string legalEntityCode FK
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[Country]] | registeredInCountry | N:1 | Country of registration |
| [[Currency]] | usesDefaultCurrency | N:1 | Default currency |
| [[LegalEntity]] | hasParentEntity | N:1 | Parent entity (self-ref) |
| [[LegalEntity]] | hasChildEntities | 1:N | Child entities (self-ref) |
| [[Employee]] | hasEmployees | 1:N | Employees of this entity |
| [[WorkRelationship]] | hasWorkRelationships | 1:N | Work relationships |
| [[Department]] | hasDepartments | 1:N | Departments/Business Units |
| [[Address]] | hasAddresses | 1:N | Legal/business addresses |
| [[BankAccount]] | hasBankAccounts | 1:N | Company bank accounts |
| [[LegalRepresentative]] | hasRepresentatives | 1:N | Legal representatives (sign contracts) |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> PENDING: Create Legal Entity
    
    PENDING --> ACTIVE: Activate (registration complete)
    
    ACTIVE --> INACTIVE: Suspend
    INACTIVE --> ACTIVE: Reactivate
    
    ACTIVE --> DISSOLVED: Dissolve
    INACTIVE --> DISSOLVED: Dissolve during suspension
    
    ACTIVE --> MERGED: Merge (M&A)
    
    DISSOLVED --> [*]
    MERGED --> [*]
    
    note right of PENDING
        Awaiting registration completion
        Cannot employ workers yet
        Setup phase
    end note
    
    note right of ACTIVE
        Currently operating
        Can employ workers
        Normal business operations
    end note
    
    note right of INACTIVE
        Temporarily suspended
        Business license suspended
        Cannot hire new employees
    end note
    
    note right of DISSOLVED
        Legally dissolved/closed
        Terminal state
        Historical record only
    end note
    
    note right of MERGED
        Merged into another entity
        Terminal state
        Employees transferred
    end note
```

### State Descriptions

| State | Description | Allowed Operations |
|-------|-------------|-------------------|
| **PENDING** | Awaiting registration completion | Can activate when ready |
| **ACTIVE** | Currently operating legal entity | Can suspend, dissolve, merge, employ workers |
| **INACTIVE** | Temporarily not operating | Can reactivate, dissolve |
| **DISSOLVED** | Legally dissolved/closed | Read-only, historical record |
| **MERGED** | Merged into another entity | Read-only, historical record |

### Transition Rules

| From | To | Trigger | Guard Condition |
|------|-----|---------|--------------------|
| PENDING | ACTIVE | activate | Registration completed, documents submitted |
| ACTIVE | INACTIVE | suspend | Temporary suspension (license suspended) |
| INACTIVE | ACTIVE | reactivate | Suspension lifted |
| ACTIVE | DISSOLVED | dissolve | Legal dissolution process completed |
| ACTIVE | MERGED | merge | Merged into another entity (M&A) |
| INACTIVE | DISSOLVED | dissolve | Dissolution during suspension |

---

## 5. Business Rules Reference

### Validation Rules
- **LegalEntityCodeUniqueness**: code unique across all entities
- **RegistrationNumberUniqueness**: registrationNumber unique within country
- **TaxIdUniqueness**: taxId unique within country
- **EffectiveDateConsistency**: effectiveStartDate < effectiveEndDate (if set)
- **ActiveEntityRequirements**: ACTIVE entity must have registrationNumber and taxId (WARNING)
- **ParentChildConsistency**: Entity cannot be its own parent (prevent circular hierarchy)
- **VNRegistrationFormat**: VN entities should have 10-digit registrationNumber (WARNING)

### Business Constraints
- **LegalEmployerFlag**: If isLegalEmployer = true, can have Employees/WorkRelationships
- **VNSocialInsuranceRequired**: VN entities with employees need socialInsuranceCode (WARNING)
- **DissolvedEntityRestrictions**: DISSOLVED/MERGED entities cannot have new Employees
- **InactiveEntityWarning**: INACTIVE entities should not have ACTIVE employees (WARNING)

### VN Enterprise Law Compliance
- **Registration Number**: Mã số doanh nghiệp (10 digits)
- **Tax ID**: Mã số thuế (usually same as registration number)
- **Legal Forms**: LLC (TNHH), JSC (Cổ phần), PRIVATE (Tư nhân), PARTNERSHIP (Hợp danh), BRANCH (Chi nhánh), REP_OFFICE (Văn phòng đại diện)
- **Social Insurance**: Mã đơn vị BHXH required for entities with employees
- **Labor Registration**: Đăng ký sử dụng lao động required

### Classification Flags (Oracle Pattern)
- **Legal Employer**: Can directly employ workers (isLegalEmployer = true)
- **Payroll Statutory Unit (PSU)**: Responsible for payroll taxes (isPayrollStatutoryUnit = true)
- **Tax Reporting Unit (TRU)**: Tax reporting unit (isTaxReportingUnit = true)
- **Use Case**: Same entity can be Legal Employer + PSU + TRU (all flags true)

### Corporate Hierarchy
- **Parent-Child**: Legal entities can form hierarchies (holding company → subsidiaries)
- **Circular Prevention**: Entity cannot be its own parent
- **Use Case**: VNG Corporation (parent) → VNG HCM (child), VNG HN (child)

### Separation from Organization
- **Legal Entity**: Legal/tax aspects ONLY (registration, tax, compliance)
- **Department/Business Unit**: Management hierarchy (separate entity)
- **Relationship**: Department.legalEntityCode references LegalEntity.code

### Related Business Rules Documents
- See `[[legal-entity-management.brs.md]]` for complete business rules catalog
- See `[[vn-enterprise-law-compliance.brs.md]]` for Vietnam-specific requirements
- See `[[corporate-hierarchy.brs.md]]` for parent-child relationship rules
- See `[[tax-compliance.brs.md]]` for tax registration and reporting rules

---

## 6. VN Legal Forms Reference

### Common VN Legal Forms

| Code | VN Name | English | Description |
|------|---------|---------|-------------|
| LLC | Công ty TNHH | Limited Liability Company | Most common for SMEs |
| JSC | Công ty Cổ phần | Joint Stock Company | Public/private corporations |
| PRIVATE | Doanh nghiệp tư nhân | Private Enterprise | Individual ownership |
| PARTNERSHIP | Công ty hợp danh | Partnership | General partnership |
| BRANCH | Chi nhánh | Branch Office | Branch of parent company |
| REP_OFFICE | Văn phòng đại diện | Representative Office | Non-trading office |

### Example: VN Legal Entity

```yaml
LegalEntity:
  id: "le-001"
  code: "VNG-HCM"
  name: "Công ty Cổ phần VNG"
  shortName: "VNG Corporation"
  statusCode: "ACTIVE"
  countryCode: "VN"
  legalFormCode: "JSC"
  registrationNumber: "0309675393"  # 10 digits
  taxId: "0309675393"  # Same as registration
  incorporationDate: "2004-04-01"
  registrationAuthority: "Sở Kế hoạch và Đầu tư TP.HCM"
  socialInsuranceCode: "800-0309675393"
  laborDepartmentCode: "LDTBXH-HCM"
  taxDepartmentCode: "TCT-HCM"
  defaultCurrencyCode: "VND"
  isLegalEmployer: true
  isPayrollStatutoryUnit: true
  isTaxReportingUnit: true
  effectiveStartDate: "2004-04-01"
```

---

*Document Status: APPROVED - Based on Oracle HCM, SAP SuccessFactors, Workday patterns*  
*VN Compliance: Enterprise Law 2020, Tax Law, Labor Code 2019*
