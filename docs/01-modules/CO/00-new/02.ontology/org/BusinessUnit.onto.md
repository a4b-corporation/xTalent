---
entity: BusinessUnit
domain: organization
version: "1.0.0"
status: approved
owner: Organization Domain Team
tags: [business-unit, organization, hierarchy, department]

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
    description: Business code for business unit (unique across system)
    constraints:
      pattern: "^[A-Z0-9-]{2,50}$"
  
  - name: name
    type: string
    required: true
    description: Full name of business unit
    constraints:
      maxLength: 200
  
  - name: shortName
    type: string
    required: false
    description: Abbreviated name for display
    constraints:
      maxLength: 100
  
  - name: statusCode
    type: enum
    required: true
    description: Current business unit status. Aligned with xTalent naming convention.
    values: [ACTIVE, INACTIVE, PLANNED, CLOSED]
    default: ACTIVE
  
  # === ORGANIZATIONAL TYPE ===
  - name: unitTypeCode
    type: string
    required: false
    description: Type of organizational unit (BUSINESS_UNIT, DIVISION, DEPARTMENT, TEAM, etc.). Reference to CODELIST_UNIT_TYPE.
    constraints:
      reference: CODELIST_UNIT_TYPE
  
  # === HIERARCHY ===
  - name: parentBusinessUnitId
    type: string
    required: false
    description: Reference to parent business unit (self-referential for hierarchy)
  
  - name: hierarchyLevel
    type: integer
    required: false
    description: Level in organizational hierarchy (1 = top level, 2 = second level, etc.)
    constraints:
      min: 1
      max: 10
  
  - name: hierarchyPath
    type: string
    required: false
    description: Full hierarchy path (e.g., /BU1/DIV1/DEPT1) for efficient queries
    constraints:
      maxLength: 500
  
  # === LEGAL ENTITY REFERENCE ===
  - name: legalEntityCode
    type: string
    required: true
    description: Default legal entity code for this business unit. All employees in this BU typically belong to this legal entity.
  
  # === MANAGEMENT ===
  - name: managerEmployeeId
    type: string
    required: false
    description: Reference to Employee who heads this business unit (Head of BU)
  
  # === LOCATION ===
  - name: primaryLocationId
    type: string
    required: false
    description: Reference to primary/main location for this business unit
  
  # === FINANCIAL ===
  - name: costCenterId
    type: string
    required: false
    description: Default cost center for this business unit
  
  - name: defaultCurrencyCode
    type: string
    required: false
    description: Functional currency for this business unit (ISO 4217 code)
    constraints:
      pattern: "^[A-Z]{3}$"
  
  - name: isProfitCenter
    type: boolean
    required: true
    default: false
    description: Is this business unit a profit center (P&L responsibility)?
  
  # === DESCRIPTION ===
  - name: description
    type: string
    required: false
    description: Description of business unit function and purpose
    constraints:
      maxLength: 1000
  
  # === DATE EFFECTIVENESS ===
  - name: effectiveStartDate
    type: date
    required: true
    description: Date this business unit becomes effective
  
  - name: effectiveEndDate
    type: date
    required: false
    description: Date this business unit becomes inactive (null = indefinite)
  
  # === METADATA ===
  - name: metadata
    type: json
    required: false
    description: Additional flexible data (logo URL, contact info, etc.)
  
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
  - name: belongsToLegalEntity
    target: LegalEntity
    cardinality: many-to-one
    required: true
    inverse: hasDepartments
    description: Default legal entity for this business unit. INVERSE - LegalEntity.hasDepartments must reference this BusinessUnit.
  
  - name: hasParentUnit
    target: BusinessUnit
    cardinality: many-to-one
    required: false
    inverse: hasChildUnits
    description: Parent business unit in hierarchy (self-referential). INVERSE - BusinessUnit.hasChildUnits must reference this BusinessUnit.
  
  - name: hasChildUnits
    target: BusinessUnit
    cardinality: one-to-many
    required: false
    inverse: hasParentUnit
    description: Child business units (divisions, departments, teams) - self-referential. INVERSE - BusinessUnit.hasParentUnit must reference this BusinessUnit.
  
  - name: managedByEmployee
    target: Employee
    cardinality: many-to-one
    required: false
    inverse: managesBusinessUnits
    description: Employee who heads this business unit. INVERSE - Employee.managesBusinessUnits must reference this BusinessUnit.
  
  - name: basedAtLocation
    target: Location
    cardinality: many-to-one
    required: false
    inverse: hostsBusinessUnits
    description: Primary location for this business unit. INVERSE - Location.hostsBusinessUnits must reference this BusinessUnit.
  
  - name: chargedToCostCenter
    target: CostCenter
    cardinality: many-to-one
    required: false
    inverse: servesBusinessUnits
    description: Default cost center for financial tracking. INVERSE - CostCenter.servesBusinessUnits must reference this BusinessUnit.
  
  - name: hasAssignments
    target: Assignment
    cardinality: one-to-many
    required: false
    inverse: belongsToDepartment
    description: Employee assignments in this business unit. INVERSE - Assignment.belongsToDepartment must reference this BusinessUnit.
  
  - name: hasPositions
    target: Position
    cardinality: one-to-many
    required: false
    inverse: belongsToBusinessUnit
    description: Positions defined in this business unit. INVERSE - Position.belongsToBusinessUnit must reference this BusinessUnit.
  
  - name: ownsJobs
    target: Job
    cardinality: one-to-many
    required: false
    inverse: ownerBusinessUnit
    description: Jobs owned by this business unit. INVERSE - Job.ownerBusinessUnit.
  
  - name: hasWorkLocations
    target: WorkLocation
    cardinality: one-to-many
    required: false
    inverse: defaultForBusinessUnit
    description: Work locations where this BU operates. INVERSE - WorkLocation.defaultForBusinessUnit.

lifecycle:
  states: [PLANNED, ACTIVE, INACTIVE, CLOSED]
  initial: PLANNED
  terminal: [CLOSED]
  transitions:
    - from: PLANNED
      to: ACTIVE
      trigger: activate
      guard: Business unit setup completed, ready to operate
    - from: ACTIVE
      to: INACTIVE
      trigger: suspend
      guard: Temporary suspension (reorganization, etc.)
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate
      guard: Suspension lifted, resume operations
    - from: ACTIVE
      to: CLOSED
      trigger: close
      guard: Business unit permanently closed (merger, dissolution)
    - from: INACTIVE
      to: CLOSED
      trigger: close
      guard: Close during suspension period

policies:
  - name: BusinessUnitCodeUniqueness
    type: validation
    rule: code must be unique across all business units
    expression: "COUNT(BusinessUnit WHERE code = X) = 1"
    severity: ERROR
  
  - name: EffectiveDateConsistency
    type: validation
    rule: effectiveStartDate must be before effectiveEndDate (if set)
    expression: "effectiveEndDate IS NULL OR effectiveStartDate < effectiveEndDate"
  
  - name: ParentChildConsistency
    type: validation
    rule: Business unit cannot be its own parent (prevent circular hierarchy)
    expression: "parentBusinessUnitId IS NULL OR parentBusinessUnitId != id"
    severity: ERROR
  
  - name: HierarchyLevelConsistency
    type: business
    rule: Child unit's hierarchyLevel should be parent's level + 1
    expression: "parentBusinessUnitId IS NULL OR hierarchyLevel = parent.hierarchyLevel + 1"
    severity: WARNING
  
  - name: LegalEntityMatch
    type: business
    rule: Business unit should belong to same legal entity as parent (or be explicitly different)
    severity: WARNING
  
  - name: ManagerMustBeActive
    type: validation
    rule: Manager must be an ACTIVE employee (if set)
    expression: "managerEmployeeId IS NULL OR manager.statusCode = ACTIVE"
    severity: WARNING
  
  - name: ActiveUnitRequirements
    type: business
    rule: ACTIVE business unit should have manager assigned
    expression: "statusCode != ACTIVE OR managerEmployeeId IS NOT NULL"
    severity: WARNING
  
  - name: ClosedUnitRestrictions
    type: business
    rule: CLOSED business units cannot have new assignments or positions
    trigger: ON_CREATE(Assignment, Position)
    severity: ERROR
  
  - name: HierarchyPathUpdate
    type: business
    rule: When parent changes, hierarchyPath should be recalculated for this unit and all descendants
    trigger: ON_UPDATE(parentBusinessUnitId)
    severity: INFO
---

# Entity: BusinessUnit

## 1. Overview

The **BusinessUnit** entity represents an organizational structure used to partition data and manage business functions. It is a **flexible, self-referential hierarchy** that can represent Business Units, Divisions, Departments, Teams, or any other organizational level.

**Key Concept**:
```
LegalEntity (legal/tax) ≠ BusinessUnit (management hierarchy)
BusinessUnit = Organizational structure for reporting, P&L, management
```

This is a **dynamic hierarchy** - the same entity type can represent different levels (BU → Division → Department → Team).

```mermaid
mindmap
  root((BusinessUnit))
    Identity
      id
      code
      name
      shortName
      statusCode
    Organizational Type
      unitTypeCode
    Hierarchy
      parentBusinessUnitId
      hierarchyLevel
      hierarchyPath
      hasChildUnits
    Legal Entity
      legalEntityCode
    Management
      managerEmployeeId
    Location
      primaryLocationId
    Financial
      costCenterId
      defaultCurrencyCode
      isProfitCenter
    Description
      description
    Date Effectiveness
      effectiveStartDate
      effectiveEndDate
    Relationships
      belongsToLegalEntity
      hasParentUnit
      hasChildUnits
      managedByEmployee
      basedAtLocation
      chargedToCostCenter
      hasAssignments
      hasPositions
    Lifecycle
      PLANNED
      ACTIVE
      INACTIVE
      CLOSED
```

**Design Rationale**:
- **Separation from Legal Entity**: Management hierarchy ≠ Legal structure
- **Self-Referential**: Same entity for all levels (flexible, dynamic)
- **Hierarchy Path**: Efficient queries for "all descendants" or "all ancestors"
- **P&L Responsibility**: isProfitCenter flag for business units with P&L

---

## 2. Attributes

### 2.1 Identity Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique internal identifier (UUID) |
| code | string | ✓ | Business code (unique) |
| name | string | ✓ | Full name |
| shortName | string | | Abbreviated name |
| statusCode | enum | ✓ | PLANNED, ACTIVE, INACTIVE, CLOSED |

### 2.2 Organizational Type

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| unitTypeCode | string | | BUSINESS_UNIT, DIVISION, DEPARTMENT, TEAM, etc. |

### 2.3 Hierarchy Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| parentBusinessUnitId | string | | Parent unit (self-referential) |
| hierarchyLevel | integer | | Level in hierarchy (1 = top) |
| hierarchyPath | string | | Full path (e.g., /BU1/DIV1/DEPT1) |

### 2.4 Legal Entity Reference

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| legalEntityCode | string | ✓ | Default legal entity |

### 2.5 Management Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| managerEmployeeId | string | | Head of business unit |

### 2.6 Location Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| primaryLocationId | string | | Primary location |

### 2.7 Financial Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| costCenterId | string | | Default cost center |
| defaultCurrencyCode | string | | Functional currency (ISO 4217) |
| isProfitCenter | boolean | ✓ | P&L responsibility? |

### 2.8 Description

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| description | string | | Function and purpose |

### 2.9 Date Effectiveness

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| effectiveStartDate | date | ✓ | Unit becomes effective |
| effectiveEndDate | date | | Unit becomes inactive |

### 2.10 Audit Attributes

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
    LegalEntity ||--o{ BusinessUnit : hasDepartments
    BusinessUnit ||--o{ BusinessUnit : hasChildUnits
    Employee ||--o{ BusinessUnit : managesBusinessUnits
    Location ||--o{ BusinessUnit : hostsBusinessUnits
    CostCenter ||--o{ BusinessUnit : servesBusinessUnits
    BusinessUnit ||--o{ Assignment : hasAssignments
    BusinessUnit ||--o{ Position : hasPositions
    
    BusinessUnit {
        string id PK
        string code UK
        string name
        string parentBusinessUnitId FK
        string legalEntityCode FK
        string managerEmployeeId FK
        enum statusCode
        integer hierarchyLevel
        string hierarchyPath
    }
    
    LegalEntity {
        string id PK
        string code UK
    }
    
    Employee {
        string id PK
        string employeeCode UK
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[LegalEntity]] | belongsToLegalEntity | N:1 | Default legal entity |
| [[BusinessUnit]] | hasParentUnit | N:1 | Parent unit (self-ref) |
| [[BusinessUnit]] | hasChildUnits | 1:N | Child units (self-ref) |
| [[Employee]] | managedByEmployee | N:1 | Head of business unit |
| [[Location]] | basedAtLocation | N:1 | Primary location |
| [[CostCenter]] | chargedToCostCenter | N:1 | Default cost center |
| [[Assignment]] | hasAssignments | 1:N | Employee assignments |
| [[Position]] | hasPositions | 1:N | Positions in this unit |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> PLANNED: Create Business Unit
    
    PLANNED --> ACTIVE: Activate (setup complete)
    
    ACTIVE --> INACTIVE: Suspend
    INACTIVE --> ACTIVE: Reactivate
    
    ACTIVE --> CLOSED: Close
    INACTIVE --> CLOSED: Close during suspension
    
    CLOSED --> [*]
    
    note right of PLANNED
        Setup phase
        Not yet operational
        Preparing structure
    end note
    
    note right of ACTIVE
        Currently operational
        Can have employees
        Normal business operations
    end note
    
    note right of INACTIVE
        Temporarily suspended
        Reorganization in progress
        Cannot hire new employees
    end note
    
    note right of CLOSED
        Permanently closed
        Terminal state
        Historical record only
        (Merger, dissolution, etc.)
    end note
```

### State Descriptions

| State | Description | Allowed Operations |
|-------|-------------|-------------------|
| **PLANNED** | Setup phase, not yet operational | Can activate when ready |
| **ACTIVE** | Currently operational | Can suspend, close, manage employees |
| **INACTIVE** | Temporarily suspended | Can reactivate, close |
| **CLOSED** | Permanently closed | Read-only, historical record |

### Transition Rules

| From | To | Trigger | Guard Condition |
|------|-----|---------|--------------------|
| PLANNED | ACTIVE | activate | Setup completed, ready to operate |
| ACTIVE | INACTIVE | suspend | Temporary suspension (reorganization) |
| INACTIVE | ACTIVE | reactivate | Suspension lifted |
| ACTIVE | CLOSED | close | Permanently closed (merger, dissolution) |
| INACTIVE | CLOSED | close | Close during suspension |

---

## 5. Business Rules Reference

### Validation Rules
- **BusinessUnitCodeUniqueness**: code unique across all business units
- **EffectiveDateConsistency**: effectiveStartDate < effectiveEndDate (if set)
- **ParentChildConsistency**: Unit cannot be its own parent (prevent circular)
- **ManagerMustBeActive**: Manager must be ACTIVE employee (WARNING)

### Business Constraints
- **HierarchyLevelConsistency**: Child level = parent level + 1 (WARNING)
- **LegalEntityMatch**: Child should belong to same legal entity as parent (WARNING)
- **ActiveUnitRequirements**: ACTIVE unit should have manager (WARNING)
- **ClosedUnitRestrictions**: CLOSED units cannot have new assignments/positions
- **HierarchyPathUpdate**: Recalculate path when parent changes

### Organizational Hierarchy Pattern
- **Self-Referential**: Same entity for all levels (BU, Division, Department, Team)
- **Hierarchy Levels**: 1 = top level, 2 = second level, etc.
- **Hierarchy Path**: `/BU1/DIV1/DEPT1` for efficient "all descendants" queries
- **Unit Types**: BUSINESS_UNIT, DIVISION, DEPARTMENT, TEAM (configurable)

### Separation from Legal Entity
- **Legal Entity**: Legal/tax boundary (who signs contracts, pays taxes)
- **Business Unit**: Management hierarchy (who reports to whom, P&L)
- **Example**: VNG Corporation (Legal Entity) → Cloud Services BU → Engineering Dept

### P&L Responsibility
- **Profit Center**: isProfitCenter = true for units with P&L responsibility
- **Cost Center**: isProfitCenter = false for support/shared services units
- **Example**: Sales BU (profit center) vs HR Dept (cost center)

### Related Business Rules Documents
- See `[[business-unit-management.brs.md]]` for complete business rules catalog
- See `[[organizational-hierarchy.brs.md]]` for hierarchy management rules
- See `[[reorganization.brs.md]]` for reorganization process rules

---

## 6. Hierarchy Examples

### Example 1: Simple Hierarchy

```yaml
# Top Level - Business Unit
BU_Cloud:
  code: "BU-CLOUD"
  name: "Cloud Services Business Unit"
  unitTypeCode: "BUSINESS_UNIT"
  parentBusinessUnitId: null
  hierarchyLevel: 1
  hierarchyPath: "/BU-CLOUD"
  legalEntityCode: "VNG-HCM"
  isProfitCenter: true

# Second Level - Division
DIV_Engineering:
  code: "DIV-ENG"
  name: "Engineering Division"
  unitTypeCode: "DIVISION"
  parentBusinessUnitId: "bu-cloud-id"
  hierarchyLevel: 2
  hierarchyPath: "/BU-CLOUD/DIV-ENG"
  legalEntityCode: "VNG-HCM"
  isProfitCenter: false

# Third Level - Department
DEPT_Backend:
  code: "DEPT-BE"
  name: "Backend Engineering Department"
  unitTypeCode: "DEPARTMENT"
  parentBusinessUnitId: "div-eng-id"
  hierarchyLevel: 3
  hierarchyPath: "/BU-CLOUD/DIV-ENG/DEPT-BE"
  legalEntityCode: "VNG-HCM"
  isProfitCenter: false
```

### Example 2: Flat Structure (No Divisions)

```yaml
# Legal Entity → Department (skip BU/Division)
DEPT_HR:
  code: "DEPT-HR"
  name: "Human Resources Department"
  unitTypeCode: "DEPARTMENT"
  parentBusinessUnitId: null
  hierarchyLevel: 1
  hierarchyPath: "/DEPT-HR"
  legalEntityCode: "VNG-HCM"
  isProfitCenter: false
```

### Example 3: Matrix Organization

```yaml
# Employee can be in multiple business units via Assignments
Assignment_1:
  employeeId: "emp-001"
  departmentId: "dept-be-id"  # Primary: Backend Dept
  isPrimary: true
  fte: 0.6

Assignment_2:
  employeeId: "emp-001"
  departmentId: "dept-ai-id"  # Secondary: AI Research Dept
  isPrimary: false
  fte: 0.4
```

---

*Document Status: APPROVED - Based on Oracle HCM, SAP SuccessFactors, Workday patterns*  
*Organizational Design: Flexible self-referential hierarchy for dynamic structures*
