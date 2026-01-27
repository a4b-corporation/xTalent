---
entity: Location
domain: facility
version: "1.0.0"
status: approved
owner: Facilities Domain Team
tags: [location, facility, floor, room, internal-map]

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
    description: Business code for the location (e.g., ETOWN_F5, BUILD_A_R501)
    constraints:
      maxLength: 50
  
  - name: name
    type: string
    required: true
    description: Display name of the location
    constraints:
      maxLength: 255
  
  # === CLASSIFICATION ===
  - name: locationTypeCode
    type: enum
    required: true
    description: Type of physical location within a Place
    values: [FLOOR, WING, ZONE, BUILDING_SECTION, ROOM, OFFICE, MEETING_ROOM, LAB, DESK, WORKSTATION, PARKING, CAFETERIA, GYM, RECEPTION, STORAGE, OTHER]
  
  # === PLACE REFERENCE ===
  - name: placeId
    type: string
    required: true
    description: FK → Place.id. The geographic place this location belongs to.
  
  # === HIERARCHY (Within Place) ===
  - name: parentId
    type: string
    required: false
    description: FK → Location.id. Parent location (e.g., Floor contains Rooms). Null = direct child of Place.
  
  - name: levelOrder
    type: integer
    required: false
    description: Numeric level in hierarchy (1 = highest within Place, 2, 3...). Useful for sorting.
    constraints:
      min: 1
      max: 20
  
  # === GEOLOCATION (Internal) ===
  - name: latitude
    type: decimal
    required: false
    description: Precise latitude (for indoor mapping/GPS)
    constraints:
      min: -90.0
      max: 90.0
  
  - name: longitude
    type: decimal
    required: false
    description: Precise longitude (for indoor mapping/GPS)
    constraints:
      min: -180.0
      max: 180.0
  
  - name: floorPlanUrl
    type: string
    required: false
    description: URL to floor plan image/document
    constraints:
      maxLength: 500
  
  # === CAPACITY & FEATURES ===
  - name: capacity
    type: integer
    required: false
    description: Maximum occupancy/seats in this location
    constraints:
      min: 0
  
  - name: features
    type: json
    required: false
    description: "Room features array (e.g., [\"VIDEO_CONF\", \"WHITEBOARD\", \"PROJECTOR\", \"PHONE\"])"
  
  - name: isBookable
    type: boolean
    required: true
    default: false
    description: Can this location be booked (meeting rooms, desks)?
  
  # === STATUS ===
  - name: isActive
    type: boolean
    required: true
    default: true
    description: Is this location currently active?
  
  # === METADATA ===
  - name: description
    type: string
    required: false
    description: Description of the location
  
  - name: metadata
    type: json
    required: false
    description: Additional data (equipment, access codes, etc.)
  
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
  - name: belongsToPlace
    target: Place
    cardinality: many-to-one
    required: true
    inverse: hasLocations
    description: The geographic place this location belongs to.
  
  - name: parent
    target: Location
    cardinality: many-to-one
    required: false
    inverse: children
    description: Parent location (e.g., Floor contains Rooms). Self-referential.
  
  - name: children
    target: Location
    cardinality: one-to-many
    required: false
    inverse: parent
    description: Child locations within this location.
  
  - name: hasWorkLocations
    target: WorkLocation
    cardinality: one-to-many
    required: false
    inverse: belongsToLocation
    description: HR work locations mapped to this physical location.

lifecycle:
  states: [ACTIVE, INACTIVE, UNDER_RENOVATION, DECOMMISSIONED]
  initial: ACTIVE
  terminal: [DECOMMISSIONED]
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: No active work locations using this location
    - from: ACTIVE
      to: UNDER_RENOVATION
      trigger: startRenovation
      guard: Renovation work begins
    - from: UNDER_RENOVATION
      to: ACTIVE
      trigger: completeRenovation
      guard: Renovation complete
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate
    - from: [ACTIVE, INACTIVE, UNDER_RENOVATION]
      to: DECOMMISSIONED
      trigger: decommission
      guard: Location permanently removed

policies:
  - name: UniqueCodeGlobally
    type: validation
    rule: Location code must be unique across all locations
    expression: "UNIQUE(code)"
  
  - name: PlaceRequired
    type: validation
    rule: Every location must belong to a Place
    expression: "placeId IS NOT NULL"
  
  - name: ParentSamePlace
    type: validation
    rule: Parent location must be in the same Place
    expression: "parentId IS NULL OR parent.placeId = this.placeId"
  
  - name: ParentHigherLevel
    type: validation
    rule: Parent location must have lower levelOrder (higher in hierarchy)
    expression: "parentId IS NULL OR parent.levelOrder < this.levelOrder"
    severity: WARNING
  
  - name: CapacityNonNegative
    type: validation
    rule: Capacity must be non-negative
    expression: "capacity IS NULL OR capacity >= 0"
  
  - name: BookableRequiresCapacity
    type: business
    rule: Bookable locations should have capacity defined
    expression: "isBookable = false OR capacity IS NOT NULL"
    severity: WARNING
---

# Entity: Location

## 1. Overview

**Location** represents a **physical subdivision within a Place** - an internal location on a "small map" (floor plan level). This is Tier 2 in the 3-tier location hierarchy, supporting up to 20 levels of self-referential hierarchy.

```
Place (Big Map - Google Maps)
└── Location (Internal Map - Floor Plan) ← YOU ARE HERE
    ├── Floor → Wing → Room → Desk
    └── WorkLocation (HR Assignment)
```

**Key Concept**:
```
Location = Internal subdivision of a Place (has floor plan, not street address)
Examples: Floor 5, Wing A, Room 501, Desk 501-A
```

```mermaid
mindmap
  root((Location))
    Identity
      id
      code
      name
    Classification
      locationTypeCode
    Place Reference
      placeId
    Hierarchy
      parentId
      levelOrder
      children
    Geolocation
      latitude
      longitude
      floorPlanUrl
    Capacity & Features
      capacity
      features
      isBookable
    Status
      isActive
    Relationships
      belongsToPlace
      parent
      children
      hasWorkLocations
    Lifecycle
      ACTIVE
      INACTIVE
      UNDER_RENOVATION
      DECOMMISSIONED
```

### Industry Alignment

| Vendor | Equivalent Concept |
|--------|-------------------|
| Workday | Work Space (up to 10 levels) |
| Google | Floor + Room (Calendar Resources) |
| Oracle HCM | Site sub-locations |
| SAP | Location sub-elements |

---

## 2. Attributes

### 2.1 Identity

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique identifier (UUID) |
| code | string | ✓ | Business code (e.g., ETOWN_F5_R501) |
| name | string | ✓ | Display name |

### 2.2 Classification

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| locationTypeCode | enum | ✓ | FLOOR, WING, ZONE, ROOM, OFFICE, MEETING_ROOM, LAB, DESK, WORKSTATION, PARKING, CAFETERIA, etc. |

### 2.3 Place Reference

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| **placeId** | string | ✓ | FK → [[Place]]. Required - every location belongs to a place |

### 2.4 Hierarchy

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| parentId | string | | FK → Location. Parent location (self-ref) |
| levelOrder | integer | | Level in hierarchy (1 = highest) |

### 2.5 Geolocation (Internal)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| latitude | decimal | | Precise latitude (indoor GPS) |
| longitude | decimal | | Precise longitude (indoor GPS) |
| floorPlanUrl | string | | Link to floor plan document |

### 2.6 Capacity & Features

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| capacity | integer | | Maximum occupancy |
| features | json | | Room features (VIDEO_CONF, WHITEBOARD, etc.) |
| isBookable | boolean | ✓ | Can be booked (meeting rooms)? |

---

## 3. Relationships

```mermaid
erDiagram
    Place ||--o{ Location : hasLocations
    Location ||--o{ Location : "parent/children"
    Location ||--o{ WorkLocation : hasWorkLocations
    
    Location {
        string id PK
        string code UK
        string name
        enum locationTypeCode
        string placeId FK
        string parentId FK
        int levelOrder
        int capacity
        boolean isBookable
    }
    
    Place {
        string id PK
        string code
    }
    
    WorkLocation {
        string id PK
        string locationId FK
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[Place]] | belongsToPlace | N:1 | Geographic place (required) |
| [[Location]] | parent / children | N:1 / 1:N | Self-referential hierarchy |
| [[WorkLocation]] | hasWorkLocations | 1:N | HR work locations |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> ACTIVE: Create Location
    
    ACTIVE --> INACTIVE: Deactivate
    ACTIVE --> UNDER_RENOVATION: Start Renovation
    
    UNDER_RENOVATION --> ACTIVE: Complete Renovation
    INACTIVE --> ACTIVE: Reactivate
    
    ACTIVE --> DECOMMISSIONED: Decommission
    INACTIVE --> DECOMMISSIONED: Decommission
    UNDER_RENOVATION --> DECOMMISSIONED: Decommission
    
    DECOMMISSIONED --> [*]
    
    note right of ACTIVE
        Normal operation
        Can be assigned
    end note
    
    note right of UNDER_RENOVATION
        Temporarily unavailable
        Construction work
    end note
    
    note right of DECOMMISSIONED
        Permanently removed
        Demolished, repurposed
    end note
```

---

## 5. Business Rules Reference

### Validation Rules
- **UniqueCodeGlobally**: Code unique across all locations
- **PlaceRequired**: Must belong to a Place
- **ParentSamePlace**: Parent must be in same Place
- **ParentHigherLevel**: Parent must have lower levelOrder (WARNING)
- **CapacityNonNegative**: Capacity >= 0

### Business Constraints
- **BookableRequiresCapacity**: Bookable locations should have capacity (WARNING)

### Location Types (Hierarchy Example)

```
FLOOR (Level 1)
├── WING (Level 2)
│   ├── OFFICE (Level 3)
│   │   └── DESK (Level 4)
│   └── MEETING_ROOM (Level 3)
└── CAFETERIA (Level 2)
```

### Room Features (examples)

| Feature Code | Description |
|--------------|-------------|
| VIDEO_CONF | Video conferencing |
| WHITEBOARD | Whiteboard |
| PROJECTOR | Projector |
| PHONE | Conference phone |
| ACCESSIBILITY | Wheelchair accessible |
| NATURAL_LIGHT | Windows/natural light |

---

*Document Status: APPROVED*  
*Based on: Workday Work Space (10 levels), Google Floor/Room, industry patterns*
