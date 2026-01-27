---
entity: WorkLocation
domain: facility
version: "1.0.0"
status: approved
owner: HR Operations Team
tags: [location, work-location, assignment, hr, payroll]

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
    description: Business code for the work location (e.g., WL_ETOWN_F5_HR, WL_REMOTE_VN)
    constraints:
      maxLength: 50
  
  - name: name
    type: string
    required: true
    description: Display name of the work location
    constraints:
      maxLength: 255
  
  # === CLASSIFICATION ===
  - name: workLocTypeCode
    type: enum
    required: true
    description: Type of work location for HR purposes
    values: [OFFICE, REMOTE, HYBRID, HOME, CLIENT_SITE, FIELD, FACTORY_FLOOR, WAREHOUSE, RETAIL_STORE, MOBILE, OTHER]
  
  # === LOCATION REFERENCE ===
  - name: locationId
    type: string
    required: false
    description: FK → Location.id. Physical location (if applicable). Null for REMOTE/HOME.
  
  # === ORGANIZATIONAL CONTEXT ===
  - name: legalEntityId
    type: string
    required: false
    description: FK → LegalEntity.id. Legal entity that owns/operates this work location.
  
  - name: defaultBusinessUnitId
    type: string
    required: false
    description: FK → BusinessUnit.id. Default BU for employees at this location.
  
  # === PAYROLL & COMPLIANCE ===
  - name: geoZoneCode
    type: string
    required: false
    description: Geographic zone code for payroll differentials (geo-pay, regional allowance)
    constraints:
      maxLength: 50
  
  - name: taxLocationCode
    type: string
    required: false
    description: Tax location code for income tax withholding (Cục Thuế for VN)
    constraints:
      maxLength: 50
  
  # === WORK SCHEDULE ===
  - name: timeProfileCode
    type: string
    required: false
    description: Default time profile/work schedule code for this location
    constraints:
      maxLength: 50
  
  - name: standardWeeklyHours
    type: decimal
    required: false
    description: Standard weekly hours for this location (e.g., 40.0, 44.0)
    constraints:
      min: 0
      max: 168
  
  # === CAPACITY ===
  - name: capacity
    type: integer
    required: false
    description: Maximum headcount for this work location
    constraints:
      min: 0
  
  - name: currentHeadcount
    type: integer
    required: false
    description: Current number of employees assigned (derived/cached)
    constraints:
      min: 0
  
  # === STATUS ===
  - name: isActive
    type: boolean
    required: true
    default: true
    description: Is this work location currently active?
  
  - name: isPrimary
    type: boolean
    required: true
    default: false
    description: Is this the primary work location for the business unit?
  
  # === METADATA ===
  - name: description
    type: string
    required: false
    description: Description of the work location
  
  - name: metadata
    type: json
    required: false
    description: Additional data (equipment, safety requirements, etc.)
  
  # === AUDIT ===
  - name: createdAt
    type: datetime
    required: true
    description: Record creation timestamp
  
  - name: updatedAt
    type: datetime
    required: true
    description: Last modification timestamp

relationships:
  - name: belongsToLocation
    target: Location
    cardinality: many-to-one
    required: false
    inverse: hasWorkLocations
    description: Physical location (optional - null for REMOTE/HOME).
  
  - name: ownedByLegalEntity
    target: LegalEntity
    cardinality: many-to-one
    required: false
    inverse: hasWorkLocations
    description: Legal entity owning/operating this work location.
  
  - name: defaultForBusinessUnit
    target: BusinessUnit
    cardinality: many-to-one
    required: false
    inverse: hasWorkLocations
    description: Default business unit for this work location.
  
  - name: hasAssignments
    target: Assignment
    cardinality: one-to-many
    required: false
    inverse: primaryWorkLocation
    description: Employee assignments placed at this work location.

lifecycle:
  states: [ACTIVE, INACTIVE, CLOSED]
  initial: ACTIVE
  terminal: [CLOSED]
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: No active employee assignments
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate
    - from: [ACTIVE, INACTIVE]
      to: CLOSED
      trigger: close
      guard: Work location permanently closed

policies:
  - name: UniqueCodeGlobally
    type: validation
    rule: WorkLocation code must be unique
    expression: "UNIQUE(code)"
  
  - name: LocationRequiredForPhysical
    type: validation
    rule: Physical work locations (OFFICE, FACTORY_FLOOR, etc.) must have locationId
    expression: "workLocTypeCode IN (REMOTE, HOME, FIELD, MOBILE) OR locationId IS NOT NULL"
    severity: WARNING
  
  - name: LegalEntityRecommended
    type: business
    rule: Work locations should have a legal entity for compliance
    expression: "legalEntityId IS NOT NULL"
    severity: WARNING
  
  - name: CapacityTracking
    type: business
    rule: Capacity should be defined for office-based work locations
    expression: "workLocTypeCode NOT IN (OFFICE, FACTORY_FLOOR) OR capacity IS NOT NULL"
    severity: INFO
  
  - name: GeoZoneForPayroll
    type: business
    rule: geoZoneCode recommended for locations with regional pay differentials
    severity: INFO
  
  - name: OnePrimaryPerBU
    type: validation
    rule: Business Unit should have at most one primary work location
    expression: "isPrimary = false OR COUNT(WorkLocation WHERE defaultBusinessUnitId = this.defaultBusinessUnitId AND isPrimary = true) = 1"
    severity: WARNING
---

# Entity: WorkLocation

## 1. Overview

**WorkLocation** represents the **HR assignment point** - where employees are officially assigned for work. This is Tier 3 in the 3-tier location hierarchy, connecting physical infrastructure with organizational structure.

```
Place (Big Map - Geographic presence)
└── Location (Internal Map - Physical subdivision)
    └── WorkLocation (HR Assignment) ← YOU ARE HERE
        ├── Links Location + LegalEntity + BusinessUnit
        └── Assignment references this for employee placement
```

**Key Concept**:
```
WorkLocation = HR assignment point (combines Physical + Organizational)
Purpose: Employee placement, payroll zone, tax jurisdiction, headcount tracking
```

```mermaid
mindmap
  root((WorkLocation))
    Identity
      id
      code
      name
    Classification
      workLocTypeCode
    Location Reference
      locationId
    Organizational Context
      legalEntityId
      defaultBusinessUnitId
    Payroll & Compliance
      geoZoneCode
      taxLocationCode
    Work Schedule
      timeProfileCode
      standardWeeklyHours
    Capacity
      capacity
      currentHeadcount
    Status
      isActive
      isPrimary
    Relationships
      belongsToLocation
      ownedByLegalEntity
      defaultForBusinessUnit
      hasAssignments
    Lifecycle
      ACTIVE
      INACTIVE
      CLOSED
```

### Industry Alignment

| Vendor | Equivalent Concept |
|--------|-------------------|
| Workday | Location (with Business Site usage) + Assignment Location |
| Oracle HCM | Location + Legal Entity linking |
| SAP | Location with Legal Entity + Geo Zone |
| xTalent | WorkLocation (unique 3-tier value-add) |

---

## 2. Attributes

### 2.1 Identity

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique identifier (UUID) |
| code | string | ✓ | Business code (e.g., WL_ETOWN_F5_HR) |
| name | string | ✓ | Display name |

### 2.2 Classification

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| workLocTypeCode | enum | ✓ | OFFICE, REMOTE, HYBRID, HOME, CLIENT_SITE, FIELD, FACTORY_FLOOR, WAREHOUSE, RETAIL_STORE, MOBILE |

### 2.3 Location Reference

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| locationId | string | | FK → [[Location]]. Physical location (null for REMOTE/HOME) |

### 2.4 Organizational Context

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| legalEntityId | string | | FK → [[LegalEntity]]. Owner/operator |
| defaultBusinessUnitId | string | | FK → [[BusinessUnit]]. Default BU |

### 2.5 Payroll & Compliance

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| geoZoneCode | string | | Geographic zone for geo-pay differentials |
| taxLocationCode | string | | Tax jurisdiction code (Cục Thuế for VN) |

### 2.6 Work Schedule

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| timeProfileCode | string | | Default work schedule code |
| standardWeeklyHours | decimal | | Standard hours (40.0, 44.0, etc.) |

### 2.7 Capacity

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| capacity | integer | | Maximum headcount |
| currentHeadcount | integer | | Current assigned employees (derived) |

### 2.8 Status

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| isActive | boolean | ✓ | Is active? |
| isPrimary | boolean | ✓ | Primary for the BU? |

---

## 3. Relationships

```mermaid
erDiagram
    Location ||--o{ WorkLocation : hasWorkLocations
    LegalEntity ||--o{ WorkLocation : hasWorkLocations
    BusinessUnit ||--o{ WorkLocation : hasWorkLocations
    WorkLocation ||--o{ Assignment : hasAssignments
    
    WorkLocation {
        string id PK
        string code UK
        string name
        enum workLocTypeCode
        string locationId FK
        string legalEntityId FK
        string defaultBusinessUnitId FK
        string geoZoneCode
        string taxLocationCode
        decimal standardWeeklyHours
        int capacity
        boolean isPrimary
    }
    
    Location {
        string id PK
        string placeId FK
    }
    
    Assignment {
        string id PK
        string primaryLocationId FK
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[Location]] | belongsToLocation | N:1 | Physical location (optional) |
| [[LegalEntity]] | ownedByLegalEntity | N:1 | Legal entity ownership |
| [[BusinessUnit]] | defaultForBusinessUnit | N:1 | Default business unit |
| [[Assignment]] | hasAssignments | 1:N | Employee assignments |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> ACTIVE: Create WorkLocation
    
    ACTIVE --> INACTIVE: Deactivate
    INACTIVE --> ACTIVE: Reactivate
    
    ACTIVE --> CLOSED: Close (permanent)
    INACTIVE --> CLOSED: Close (permanent)
    
    CLOSED --> [*]
    
    note right of ACTIVE
        Can assign employees
        Headcount tracking active
    end note
    
    note right of INACTIVE
        No new assignments
        Existing employees may remain
    end note
    
    note right of CLOSED
        Permanently closed
        All assignments must be moved
    end note
```

---

## 5. Business Rules Reference

### Validation Rules
- **UniqueCodeGlobally**: Code unique across all work locations
- **LocationRequiredForPhysical**: Physical types need locationId (WARNING)
- **OnePrimaryPerBU**: One primary per BU (WARNING)

### Business Constraints
- **LegalEntityRecommended**: Should have legal entity (WARNING)
- **CapacityTracking**: Office types should have capacity (INFO)
- **GeoZoneForPayroll**: Recommend geo zone for pay differentials (INFO)

### WorkLocation Types

| Type | Physical | Description | Use Case |
|------|----------|-------------|----------|
| OFFICE | ✓ | Office building | Standard office workers |
| REMOTE | ✗ | Work from anywhere | Full remote employees |
| HYBRID | Partial | Mix of office + remote | Hybrid schedule |
| HOME | ✗ | Work from home | Home-based workers |
| CLIENT_SITE | ✓ | Customer premises | Consultants, contractors |
| FIELD | ✗ | Various locations | Sales reps, field technicians |
| FACTORY_FLOOR | ✓ | Manufacturing area | Production workers |
| WAREHOUSE | ✓ | Storage facility | Logistics staff |
| RETAIL_STORE | ✓ | Retail location | Store employees |
| MOBILE | ✗ | No fixed location | Drivers, delivery |

### Use Cases

#### 1. Office Work Location

```yaml
WorkLocation:
  code: "WL_ETOWN_F5_HR"
  name: "E-Town Floor 5 - HR Department"
  workLocTypeCode: "OFFICE"
  locationId: "loc-etown-floor5"      # Physical location
  legalEntityId: "le-vng-corp"        # VNG Corporation
  defaultBusinessUnitId: "bu-hr"      # HR Department
  geoZoneCode: "VN-HCM"               # Ho Chi Minh zone
  taxLocationCode: "CUC_THUE_Q1"      # District 1 tax office
  standardWeeklyHours: 40.0
  capacity: 50
```

#### 2. Remote Work Location

```yaml
WorkLocation:
  code: "WL_REMOTE_VN"
  name: "Remote - Vietnam"
  workLocTypeCode: "REMOTE"
  locationId: null                    # No physical location
  legalEntityId: "le-vng-corp"
  geoZoneCode: "VN-ALL"               # Vietnam-wide
  standardWeeklyHours: 40.0
```

---

*Document Status: APPROVED*  
*Based on: Workday Location+Assignment, Oracle Location+LegalEntity, xTalent 3-tier design*
