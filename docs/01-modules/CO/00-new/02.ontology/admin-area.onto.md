---
entity: AdminArea
domain: geo
version: "1.0.0"
status: approved
owner: Common Domain Team
tags: [geography, administrative-division, hierarchy, vn-compliance, dynamic]

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
    description: Administrative code (unique within country + level combination)
    constraints:
      maxLength: 20
  
  - name: name
    type: string
    required: true
    description: English/International name
    constraints:
      maxLength: 255
  
  - name: nativeName
    type: string
    required: false
    description: Local language name (Tên tiếng Việt, 日本語名, etc.)
    constraints:
      maxLength: 255
  
  # === HIERARCHY ===
  - name: parentId
    type: string
    required: false
    description: FK → self (AdminArea.id). Null = top level within country (e.g., Province in VN).
  
  - name: countryCode
    type: string
    required: true
    description: FK → Country.code (ISO 3166-1 alpha-2). Country this admin area belongs to.
    constraints:
      pattern: "^[A-Z]{2}$"
  
  - name: levelCode
    type: enum
    required: true
    description: Type of administrative division. Varies by country.
    values: [PROVINCE, STATE, REGION, TERRITORY, DISTRICT, COUNTY, CITY, MUNICIPALITY, WARD, COMMUNE, TOWNSHIP, ZIP_CODE, SUBDISTRICT, OTHER]
  
  - name: levelOrder
    type: integer
    required: true
    description: "Numeric level in hierarchy (1 = highest, 2 = next lower, etc.). VN: Province=1, District=2, Ward=3."
    constraints:
      min: 1
      max: 10
  
  # === GEOLOCATION ===
  - name: latitude
    type: decimal
    required: false
    description: Latitude coordinate (center point)
    constraints:
      min: -90.0
      max: 90.0
  
  - name: longitude
    type: decimal
    required: false
    description: Longitude coordinate (center point)
    constraints:
      min: -180.0
      max: 180.0
  
  # === METADATA ===
  - name: population
    type: integer
    required: false
    description: Population count (for reporting, optional)
  
  - name: metadata
    type: json
    required: false
    description: Additional data (area_km2, timezone, phone_area_code, etc.)
  
  # === SCD TYPE-2 (History) ===
  - name: effectiveStartDate
    type: date
    required: true
    description: Start date of this version (for boundary changes, redistricting)
  
  - name: effectiveEndDate
    type: date
    required: false
    description: End date of this version (null = current)
  
  - name: isCurrent
    type: boolean
    required: true
    default: true
    description: true = current version, false = historical
  
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
  - name: parent
    target: AdminArea
    cardinality: many-to-one
    required: false
    inverse: children
    description: Parent admin area (e.g., Province is parent of District). Self-referential.
  
  - name: children
    target: AdminArea
    cardinality: one-to-many
    required: false
    inverse: parent
    description: Child admin areas (e.g., Districts within Province).
  
  - name: belongsToCountry
    target: Country
    cardinality: many-to-one
    required: true
    inverse: hasAdminAreas
    description: Country this admin area belongs to.
  
  - name: hasAddresses
    target: Address
    cardinality: one-to-many
    required: false
    inverse: locatedInAdminArea
    description: Addresses located in this admin area.
  
  - name: hasPlaces
    target: Place
    cardinality: one-to-many
    required: false
    inverse: locatedInAdminArea
    description: Physical places (buildings, campuses) located in this admin area.

lifecycle:
  states: [ACTIVE, INACTIVE, DEPRECATED]
  initial: ACTIVE
  terminal: [DEPRECATED]
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: "No current addresses reference this area, or replacement area exists"
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate
    - from: [ACTIVE, INACTIVE]
      to: DEPRECATED
      trigger: deprecate
      guard: "Boundary no longer exists (merged with other area, dissolved, etc.)"

policies:
  - name: UniqueCodePerCountryLevel
    type: validation
    rule: Code must be unique within country + levelCode combination
    expression: "UNIQUE(countryCode, levelCode, code) WHERE isCurrent = true"
  
  - name: ParentMustBeHigherLevel
    type: validation
    rule: Parent admin area must have a lower levelOrder (higher in hierarchy)
    expression: "parentId IS NULL OR parent.levelOrder < this.levelOrder"
  
  - name: ParentSameCountry
    type: validation
    rule: Parent must be in the same country
    expression: "parentId IS NULL OR parent.countryCode = this.countryCode"
  
  - name: LevelConsistency
    type: business
    rule: VN - Province=1, District=2, Ward=3. US - State=1, County=2, City=3.
    severity: INFO
  
  - name: SingleCurrentVersion
    type: validation
    rule: Only one current version per code within country+level
    expression: "COUNT(isCurrent = true) = 1 PER (countryCode, levelCode, code)"
---

# Entity: AdminArea

## 1. Overview

**AdminArea** represents a node in an N-level administrative division hierarchy within a country. It is a **dynamic, self-referential** entity that supports varying hierarchy depths per country (e.g., Vietnam has 3 levels: Province → District → Ward, while US may have State → County → City → ZIP).

This design aligns with:
- **DBML `geo.admin_area`** table
- **Oracle HCM Geographic Hierarchy** (up to 10 levels)
- **Workday Location Hierarchy** pattern

**Key Concept**:
```
Country → AdminArea (N-level self-referential)
└── VN: Province (Tỉnh) → District (Quận) → Ward (Phường)
└── US: State → County → City → ZIP Code
└── [Custom per country...]
```

```mermaid
mindmap
  root((AdminArea))
    Identity
      id
      code
      name
      nativeName
    Hierarchy
      parentId
      countryCode
      levelCode
      levelOrder
    Geolocation
      latitude
      longitude
    Metadata
      population
      metadata
    SCD Type-2
      effectiveStartDate
      effectiveEndDate
      isCurrent
    Relationships
      parent (self)
      children (self)
      belongsToCountry
      hasAddresses
    Lifecycle
      ACTIVE
      INACTIVE
      DEPRECATED
```

### Level Codes by Country

| Country | Level 1 | Level 2 | Level 3 | Level 4 |
|---------|---------|---------|---------|---------|
| Vietnam (VN) | PROVINCE (Tỉnh/TP) | DISTRICT (Quận/Huyện) | WARD (Phường/Xã) | - |
| USA (US) | STATE | COUNTY | CITY | ZIP_CODE |
| Japan (JP) | REGION | PREFECTURE | CITY | WARD |
| China (CN) | PROVINCE | CITY | DISTRICT | SUBDISTRICT |

---

## 2. Attributes

### 2.1 Identity Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique internal identifier (UUID) |
| code | string | ✓ | Administrative code (unique per country+level) |
| name | string | ✓ | English/International name |
| nativeName | string | | Local language name (Tên tiếng Việt) |

### 2.2 Hierarchy Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| parentId | string | | FK → self. Null = top level within country |
| countryCode | string | ✓ | FK → Country (ISO 3166-1 alpha-2) |
| levelCode | enum | ✓ | PROVINCE, STATE, DISTRICT, WARD, etc. |
| levelOrder | integer | ✓ | Numeric level (1 = highest, 2, 3...) |

### 2.3 Geolocation

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| latitude | decimal | | Center point latitude (-90 to 90) |
| longitude | decimal | | Center point longitude (-180 to 180) |

### 2.4 Metadata

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| population | integer | | Population count |
| metadata | json | | Extended data (area_km2, timezone, etc.) |

### 2.5 SCD Type-2 (History)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| effectiveStartDate | date | ✓ | Version start date |
| effectiveEndDate | date | | Version end date (null = current) |
| isCurrent | boolean | ✓ | Current version flag |

---

## 3. Relationships

```mermaid
erDiagram
    Country ||--o{ AdminArea : hasAdminAreas
    AdminArea ||--o{ AdminArea : "parent/children"
    AdminArea ||--o{ Address : hasAddresses
    
    AdminArea {
        string id PK
        string code
        string name
        string nativeName
        string parentId FK
        string countryCode FK
        enum levelCode
        int levelOrder
        decimal latitude
        decimal longitude
        boolean isCurrent
    }
    
    Country {
        string code PK
        string name
    }
    
    Address {
        string id PK
        string adminAreaId FK
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[AdminArea]] | parent | N:1 | Parent in hierarchy (self-referential) |
| [[AdminArea]] | children | 1:N | Children in hierarchy (self-referential) |
| [[Country]] | belongsToCountry | N:1 | Country this area belongs to |
| [[Address]] | hasAddresses | 1:N | Addresses in this admin area |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> ACTIVE: Create
    
    ACTIVE --> INACTIVE: Deactivate
    INACTIVE --> ACTIVE: Reactivate
    
    ACTIVE --> DEPRECATED: Deprecate (merged/dissolved)
    INACTIVE --> DEPRECATED: Deprecate
    
    DEPRECATED --> [*]
    
    note right of ACTIVE
        Currently valid admin area
        Can be used for addresses
    end note
    
    note right of INACTIVE
        Temporarily not in use
        Existing addresses preserved
    end note
    
    note right of DEPRECATED
        Permanently retired
        Boundary dissolved or merged
    end note
```

### State Descriptions

| State | Description | Allowed Operations |
|-------|-------------|-------------------|
| **ACTIVE** | Currently valid administrative division | Can be used for new addresses |
| **INACTIVE** | Temporarily disabled | Cannot assign new addresses |
| **DEPRECATED** | Permanently retired (boundary change) | Read-only, historical |

---

## 5. Business Rules Reference

### Validation Rules
- **UniqueCodePerCountryLevel**: Code unique within country + levelCode
- **ParentMustBeHigherLevel**: Parent's levelOrder < this.levelOrder
- **ParentSameCountry**: Parent must be in same country
- **SingleCurrentVersion**: Only one current version per code

### VN Administrative Structure

| Level | levelCode | levelOrder | Vietnamese Name | Count (2024) |
|-------|-----------|------------|-----------------|--------------|
| 1 | PROVINCE | 1 | Tỉnh/Thành phố trực thuộc TW | 63 |
| 2 | DISTRICT | 2 | Quận/Huyện/Thị xã/TP thuộc tỉnh | ~700 |
| 3 | WARD | 3 | Phường/Xã/Thị trấn | ~11,000 |

### Example: VN Hierarchy

```
VN (Country)
└── VN-SG: "Ho Chi Minh City" / "Thành phố Hồ Chí Minh" [PROVINCE, level=1]
    ├── 760: "District 1" / "Quận 1" [DISTRICT, level=2]
    │   ├── 26734: "Ben Nghe Ward" / "Phường Bến Nghé" [WARD, level=3]
    │   ├── 26737: "Da Kao Ward" / "Phường Đa Kao" [WARD, level=3]
    │   └── ...
    ├── 769: "District 3" / "Quận 3" [DISTRICT, level=2]
    └── ...
└── VN-26: "Thua Thien Hue" / "Thừa Thiên Huế" [PROVINCE, level=1]
    └── ...
```

### Use Cases

**1. Address Validation**:
When user enters address, validate ward → district → province chain.

**2. Tax Jurisdiction**:
Determine tax zone from admin area hierarchy.

**3. Redistricting**:
When boundaries change (SCD Type-2), create new version with updated parent.

---

*Document Status: APPROVED*  
*Based on: Oracle HCM Geographic Hierarchy, Workday Location Hierarchy, geo.admin_area DBML*  
*VN Compliance: 63 provinces, ~700 districts, ~11,000 wards*
