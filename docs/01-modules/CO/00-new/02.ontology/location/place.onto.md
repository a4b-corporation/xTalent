---
entity: Place
domain: facility
version: "1.0.0"
status: approved
owner: Facilities Domain Team
tags: [location, facility, geography, google-maps]

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
    description: Business code for the place (e.g., QT_SOFTWARE_CITY, ETOWN_COMPLEX)
    constraints:
      maxLength: 50
  
  - name: name
    type: string
    required: true
    description: Display name of the place
    constraints:
      maxLength: 255
  
  # === CLASSIFICATION ===
  - name: placeTypeCode
    type: enum
    required: true
    description: Type of physical place
    values: [CAMPUS, OFFICE_PARK, BUILDING, INDUSTRIAL_ZONE, FACTORY, WAREHOUSE, DATA_CENTER, RETAIL_COMPLEX, HOSPITAL, UNIVERSITY, OTHER]
  
  # === HIERARCHY ===
  - name: parentId
    type: string
    required: false
    description: FK → Place.id. Parent place (e.g., Campus contains Buildings). Null = top-level.
  
  # === GEOGRAPHIC CONTEXT ===
  - name: adminAreaId
    type: string
    required: false
    description: FK → AdminArea.id. Lowest-level administrative area (Ward/District) where place is located.
  
  - name: addressId
    type: string
    required: false
    description: FK → Address.id. Full street address of the place.
  
  - name: timeZoneCode
    type: string
    required: false
    description: IANA Time Zone (e.g., Asia/Ho_Chi_Minh). Inherited by child locations.
    constraints:
      maxLength: 50
  
  # === GEOLOCATION ===
  - name: latitude
    type: decimal
    required: false
    description: Latitude coordinate (for map display, e.g., Google Maps)
    constraints:
      min: -90.0
      max: 90.0
  
  - name: longitude
    type: decimal
    required: false
    description: Longitude coordinate (for map display)
    constraints:
      min: -180.0
      max: 180.0
  
  - name: mapsUrl
    type: string
    required: false
    description: Direct link to Google Maps or equivalent
    constraints:
      maxLength: 500
  
  # === CONTACT ===
  - name: primaryContactWorkerId
    type: string
    required: false
    description: FK → Worker.id. Primary contact/site manager for this place.
  
  - name: contactPhone
    type: string
    required: false
    description: Main phone number for the place
    constraints:
      maxLength: 50
  
  - name: contactEmail
    type: string
    required: false
    description: Main email for the place
    constraints:
      maxLength: 100
  
  # === STATUS ===
  - name: isActive
    type: boolean
    required: true
    default: true
    description: Is this place currently active?
  
  # === METADATA ===
  - name: description
    type: string
    required: false
    description: Description of the place
  
  - name: metadata
    type: json
    required: false
    description: Additional data (parking info, access instructions, etc.)
  
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
    target: Place
    cardinality: many-to-one
    required: false
    inverse: children
    description: Parent place (e.g., Campus contains Buildings). Self-referential.
  
  - name: children
    target: Place
    cardinality: one-to-many
    required: false
    inverse: parent
    description: Child places within this place.
  
  - name: locatedInAdminArea
    target: AdminArea
    cardinality: many-to-one
    required: false
    inverse: hasPlaces
    description: Administrative area where place is located.
  
  - name: hasAddress
    target: Address
    cardinality: one-to-one
    required: false
    inverse: belongsToPlace
    description: Street address of this place.
  
  - name: primaryContact
    target: Worker
    cardinality: many-to-one
    required: false
    inverse: managedPlaces
    description: Site manager/primary contact.
  
  - name: hasLocations
    target: Location
    cardinality: one-to-many
    required: false
    inverse: belongsToPlace
    description: Physical locations within this place.

lifecycle:
  states: [ACTIVE, INACTIVE, CLOSED]
  initial: ACTIVE
  terminal: [CLOSED]
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: No active work locations using this place
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate
    - from: [ACTIVE, INACTIVE]
      to: CLOSED
      trigger: close
      guard: Place permanently closed (demolished, sold, etc.)

policies:
  - name: UniqueCodeGlobally
    type: validation
    rule: Place code must be unique across all places
    expression: "UNIQUE(code)"
  
  - name: ParentMustBeActive
    type: validation
    rule: Parent place must be active
    expression: "parentId IS NULL OR parent.isActive = true"
    severity: WARNING
  
  - name: GeolocationValidation
    type: validation
    rule: Latitude (-90 to 90), Longitude (-180 to 180)
    expression: "(latitude IS NULL OR (latitude >= -90 AND latitude <= 90)) AND (longitude IS NULL OR (longitude >= -180 AND longitude <= 180))"
  
  - name: AddressRecommended
    type: business
    rule: Place should have an address for proper identification
    expression: "addressId IS NOT NULL"
    severity: WARNING
---

# Entity: Place

## 1. Overview

**Place** represents a **geographic point on the world map** - a large physical location with a recognizable street address (e.g., campus, office park, building, factory). This is the entry point in the 3-tier location hierarchy:

```
Place (Big Map - Google Maps level)
└── Location (Internal Map - Floor/Room level)
    └── WorkLocation (HR Assignment - Employee placement)
```

**Key Concept**:
```
Place = Geographic presence on world map (has street address)
Examples: Quang Trung Software City, E-Town Central, VNG Campus
```

```mermaid
mindmap
  root((Place))
    Identity
      id
      code
      name
    Classification
      placeTypeCode
    Hierarchy
      parentId
      children
    Geographic Context
      adminAreaId
      addressId
      timeZoneCode
    Geolocation
      latitude
      longitude
      mapsUrl
    Contact
      primaryContactWorkerId
      contactPhone
      contactEmail
    Status
      isActive
    Relationships
      parent
      children
      locatedInAdminArea
      hasAddress
      hasLocations
    Lifecycle
      ACTIVE
      INACTIVE
      CLOSED
```

### Industry Alignment

| Vendor | Equivalent Concept |
|--------|-------------------|
| Workday | Location (Business Site) |
| Google | Building |
| Oracle HCM | HR_LOCATIONS_ALL |
| SAP | Location (Foundation Object) |

---

## 2. Attributes

### 2.1 Identity

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| id | string | ✓ | Unique identifier (UUID) | facility.place.id |
| code | string | ✓ | Business code (e.g., QT_SOFTWARE_CITY) | facility.place.code |
| name | string | ✓ | Display name | facility.place.name |

### 2.2 Classification

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| placeTypeCode | enum | ✓ | CAMPUS, OFFICE_PARK, BUILDING, INDUSTRIAL_ZONE, FACTORY, WAREHOUSE, DATA_CENTER, RETAIL_COMPLEX, etc. | facility.place.place_type_code → common.code_list(PLACE_TYPE) |

### 2.3 Hierarchy

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| parentId | string | | FK → Place. Parent place (Campus contains Buildings) | facility.place.parent_id → facility.place.id |

### 2.4 Geographic Context

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| adminAreaId | string | | FK → [[AdminArea]]. Administrative area | facility.place.admin_area_id → geo.admin_area.id |
| addressId | string | | FK → [[Address]]. Street address | (facility.place.metadata.address_id) |
| timeZoneCode | string | | IANA timezone (Asia/Ho_Chi_Minh) | (facility.place.metadata.time_zone_code) |

### 2.5 Geolocation

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| latitude | decimal | | Latitude (-90 to 90) | (facility.place.metadata.latitude) |
| longitude | decimal | | Longitude (-180 to 180) | (facility.place.metadata.longitude) |
| mapsUrl | string | | Google Maps link | (facility.place.metadata.maps_url) |

### 2.6 Contact

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| primaryContactWorkerId | string | | FK → [[Worker]]. Site manager | (facility.place.metadata.primary_contact_worker_id) |
| contactPhone | string | | Main phone | (facility.place.metadata.contact_phone) |
| contactEmail | string | | Main email | (facility.place.metadata.contact_email) |

---

## 3. Relationships

```mermaid
erDiagram
    Place ||--o{ Place : "parent/children"
    Place }o--|| AdminArea : locatedInAdminArea
    Place ||--o| Address : hasAddress
    Place }o--o| Worker : primaryContact
    Place ||--o{ Location : hasLocations
    
    Place {
        string id PK
        string code UK
        string name
        enum placeTypeCode
        string parentId FK
        string adminAreaId FK
        string addressId FK
        string timeZoneCode
    }
    
    Location {
        string id PK
        string placeId FK
    }
    
    AdminArea {
        string id PK
        string code
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[Place]] | parent / children | N:1 / 1:N | Self-referential hierarchy |
| [[AdminArea]] | locatedInAdminArea | N:1 | Administrative area |
| [[Address]] | hasAddress | 1:1 | Street address |
| [[Worker]] | primaryContact | N:1 | Site manager |
| [[Location]] | hasLocations | 1:N | Physical locations within |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> ACTIVE: Create Place
    
    ACTIVE --> INACTIVE: Deactivate
    INACTIVE --> ACTIVE: Reactivate
    
    ACTIVE --> CLOSED: Close (permanent)
    INACTIVE --> CLOSED: Close (permanent)
    
    CLOSED --> [*]
    
    note right of ACTIVE
        Place is operational
        New locations can be added
    end note
    
    note right of INACTIVE
        Temporarily not in use
        Existing locations preserved
    end note
    
    note right of CLOSED
        Permanently closed
        Demolished, sold, relocated
    end note
```

---

## 5. Business Rules Reference

### Validation Rules
- **UniqueCodeGlobally**: Code unique across all places
- **ParentMustBeActive**: Parent place must be active (WARNING)
- **GeolocationValidation**: Valid lat/long ranges

### Business Constraints
- **AddressRecommended**: Places should have addresses (WARNING)

### Place Types

| Type | VN Example | Description |
|------|------------|-------------|
| CAMPUS | Quang Trung Software City | Multi-building complex |
| OFFICE_PARK | E-Town Central | Office building cluster |
| BUILDING | Bitexco Tower | Single building |
| INDUSTRIAL_ZONE | Tân Thuận EPZ | Industrial/export zone |
| FACTORY | Nhà máy Samsung | Manufacturing facility |
| WAREHOUSE | Kho Lazada | Storage facility |
| DATA_CENTER | FPT Data Center | IT infrastructure |

---

*Document Status: APPROVED*  
*Based on: Workday Location (Business Site), Google Building, Oracle HR_LOCATIONS*
