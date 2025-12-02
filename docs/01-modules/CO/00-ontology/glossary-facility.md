# Facility Glossary

## Overview

This glossary defines the facility and work location entities used in the xTalent HCM system. Facility entities support physical location management, work location tracking, and space planning.

---

## Entities

### Place

**Definition:** Generic geographic place or point of interest that can be referenced for various purposes (meetings, events, facilities).

**Purpose:**
- Define generic geographic locations
- Support location-based services
- Enable place-based search and discovery
- Provide foundation for work locations

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `code` | string(50) | Yes | Place code |
| `name` | string(150) | No | Place name |
| `place_type` | enum | No | BUILDING, CAMPUS, FLOOR, ROOM, OUTDOOR, VIRTUAL |
| `country_id` | UUID | No | Country reference |
| `admin_area_id` | UUID | No | Administrative area reference |
| `address_line1` | string(255) | No | Address line 1 |
| `address_line2` | string(255) | No | Address line 2 |
| `postal_code` | string(20) | No | Postal code |
| `latitude` | decimal(9,6) | No | Geographic latitude |
| `longitude` | decimal(9,6) | No | Geographic longitude |
| `timezone_id` | UUID | No | Timezone reference |
| `description` | text | No | Place description |
| `metadata` | jsonb | No | Additional place attributes |
| `is_active` | boolean | Yes | Active status (default: true) |
| `effective_start_date` | date | Yes | Effective start date |
| `effective_end_date` | date | No | Effective end date |
| `is_current_flag` | boolean | Yes | Current record indicator |

**Place Types:**

| Type | Description | Example |
|------|-------------|---------|
| `BUILDING` | Physical building | Office building, Factory |
| `CAMPUS` | Campus with multiple buildings | Corporate campus |
| `FLOOR` | Floor within building | 5th Floor |
| `ROOM` | Room or space | Conference room, Office |
| `OUTDOOR` | Outdoor location | Parking lot, Garden |
| `VIRTUAL` | Virtual location | Video conference, Remote |

**Metadata Structure:**
```json
{
  "building_info": {
    "building_name": "VNG Tower",
    "total_floors": 15,
    "year_built": 2015,
    "building_class": "A"
  },
  "accessibility": {
    "wheelchair_accessible": true,
    "elevator_available": true,
    "parking_available": true
  },
  "amenities": [
    "Cafeteria",
    "Gym",
    "Prayer room",
    "Lactation room"
  ],
  "security": {
    "access_control": "CARD_READER",
    "security_desk": true,
    "cctv": true
  },
  "contact": {
    "facility_manager": "worker_fm_001",
    "phone": "+84 24 7300 8855",
    "email": "facility@vng.com.vn"
  }
}
```

**Relationships:**
- **References** `Country`
- **References** `AdminArea`
- **References** `TimeZone`
- **Has many** `Location` (locations at this place)
- **Has many** `WorkLocation` (work locations)

**Business Rules:**
- Place code must be unique
- Coordinates should be accurate for mapping
- Timezone should match geographic location
- SCD Type 2 for historical tracking

**Examples:**

```yaml
# Building
id: place_vng_tower
code: VNG_TOWER
name: "VNG Tower"
place_type: BUILDING
country_id: country_vn_001
admin_area_id: admin_vn_hanoi
address_line1: "182 Le Dai Hanh Street"
address_line2: "Hai Ba Trung District"
postal_code: "100000"
latitude: 21.013715
longitude: 105.846411
timezone_id: tz_asia_hcm
metadata:
  building_info:
    total_floors: 15
    year_built: 2015

# Virtual Location
id: place_remote
code: REMOTE
name: "Remote Work"
place_type: VIRTUAL
description: "Virtual location for remote workers"
```

---

### Location

**Definition:** Specific location within or related to a place, providing more granular location tracking.

**Purpose:**
- Define specific locations within places
- Support detailed space management
- Enable location-based access control
- Track location capacity and occupancy

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `code` | string(50) | Yes | Location code |
| `name` | string(150) | No | Location name |
| `place_id` | UUID | Yes | Place reference |
| `parent_location_id` | UUID | No | Parent location (for hierarchy) |
| `location_type` | enum | No | OFFICE, MEETING_ROOM, WORKSPACE, COMMON_AREA, STORAGE |
| `floor_number` | string(10) | No | Floor number |
| `room_number` | string(20) | No | Room number |
| `capacity` | integer | No | Maximum capacity (people) |
| `area_sqm` | decimal(10,2) | No | Area in square meters |
| `description` | text | No | Location description |
| `metadata` | jsonb | No | Additional location attributes |
| `is_active` | boolean | Yes | Active status |
| `effective_start_date` | date | Yes | Effective start date |
| `effective_end_date` | date | No | Effective end date |
| `is_current_flag` | boolean | Yes | Current record indicator |

**Location Types:**

| Type | Description |
|------|-------------|
| `OFFICE` | Individual or shared office |
| `MEETING_ROOM` | Meeting or conference room |
| `WORKSPACE` | Open workspace, hot desk |
| `COMMON_AREA` | Cafeteria, lounge, break room |
| `STORAGE` | Storage room, archive |
| `FACILITY` | Gym, prayer room, lactation room |

**Metadata Structure:**
```json
{
  "room_features": {
    "seating_capacity": 10,
    "has_projector": true,
    "has_whiteboard": true,
    "has_video_conference": true,
    "equipment": ["TV Screen", "Conference Phone"]
  },
  "booking": {
    "is_bookable": true,
    "booking_system_id": "ROOM_5F_CONF_A",
    "advance_booking_days": 30,
    "max_booking_hours": 4
  },
  "assignment": {
    "assigned_to_department": "bu_engineering",
    "assigned_workers": ["worker_001", "worker_002"],
    "assignment_type": "DEDICATED"
  },
  "maintenance": {
    "last_inspection": "2025-11-15",
    "next_inspection": "2026-05-15",
    "maintenance_schedule": "QUARTERLY"
  }
}
```

**Relationships:**
- **Belongs to** `Place`
- **Belongs to** `Location` (parent location)
- **Has many** `Location` (child locations)
- **Has many** `WorkLocation` (work location assignments)

**Business Rules:**
- Location code must be unique within place
- Capacity should not exceed place capacity
- Parent-child hierarchy supported
- SCD Type 2 for historical tracking

**Examples:**

```yaml
# Meeting Room
id: loc_5f_conf_a
code: 5F_CONF_A
name: "5th Floor Conference Room A"
place_id: place_vng_tower
location_type: MEETING_ROOM
floor_number: "5"
room_number: "5A"
capacity: 10
area_sqm: 25.0
metadata:
  room_features:
    seating_capacity: 10
    has_video_conference: true
  booking:
    is_bookable: true

# Open Workspace
id: loc_3f_workspace
code: 3F_WORKSPACE
name: "3rd Floor Open Workspace"
place_id: place_vng_tower
location_type: WORKSPACE
floor_number: "3"
capacity: 50
area_sqm: 200.0
metadata:
  workspace_type: "HOT_DESK"
  desk_count: 50
```

---

### WorkLocation

**Definition:** Work location assignment linking employees to their primary or secondary work locations. Supports hybrid work models.

**Purpose:**
- Assign employees to work locations
- Support hybrid and remote work models
- Track location-based headcount
- Enable location-based reporting and compliance

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `code` | string(50) | Yes | Work location code |
| `name` | string(150) | No | Work location name |
| `location_id` | UUID | No | Location reference (null for remote) |
| `place_id` | UUID | No | Place reference (denormalized) |
| `work_model` | enum | Yes | ONSITE, REMOTE, HYBRID |
| `is_primary` | boolean | Yes | Primary work location flag |
| `description` | text | No | Work location description |
| `metadata` | jsonb | No | Work model details, policies |
| `is_active` | boolean | Yes | Active status |
| `effective_start_date` | date | Yes | Effective start date |
| `effective_end_date` | date | No | Effective end date |
| `is_current_flag` | boolean | Yes | Current record indicator |

**Work Models:**

| Model | Description | Location Required |
|-------|-------------|-------------------|
| `ONSITE` | Full-time onsite work | Yes |
| `REMOTE` | Full-time remote work | No (can be virtual) |
| `HYBRID` | Mix of onsite and remote | Yes (primary location) |
| `FLEXIBLE` | Flexible location choice | Optional |

**Metadata Structure:**
```json
{
  "work_model_details": {
    "onsite_days_per_week": 3,
    "required_onsite_days": ["MONDAY", "WEDNESDAY", "FRIDAY"],
    "flexible_days": ["TUESDAY", "THURSDAY"],
    "core_hours": "10:00-15:00"
  },
  "remote_work_policy": {
    "policy_code": "HYBRID_POLICY_2025",
    "approval_required": false,
    "equipment_provided": true,
    "internet_allowance": 500000
  },
  "location_preferences": {
    "preferred_desk_type": "STANDING_DESK",
    "preferred_floor": "3",
    "parking_required": true,
    "parking_spot": "P3-A-015"
  },
  "compliance": {
    "tax_jurisdiction": "Hanoi",
    "labor_law_jurisdiction": "Vietnam",
    "data_residency": "Vietnam"
  }
}
```

**Relationships:**
- **References** `Location` (optional)
- **References** `Place` (denormalized)
- **Referenced by** `Assignment` (employee assignments)
- **Referenced by** `Position` (position locations)

**Business Rules:**
- Work location code must be unique
- Remote work locations may not have physical location reference
- Hybrid model requires primary location
- SCD Type 2 for historical tracking
- One primary work location per employee

**Examples:**

```yaml
# Onsite Work Location
id: wl_vng_tower_eng
code: VNG_TOWER_ENG
name: "VNG Tower - Engineering"
location_id: loc_3f_workspace
place_id: place_vng_tower
work_model: ONSITE
is_primary: true
metadata:
  department: "Engineering"
  desk_assignment: "HOT_DESK"

# Hybrid Work Location
id: wl_hybrid_hanoi
code: HYBRID_HANOI
name: "Hybrid - Hanoi Office"
location_id: loc_3f_workspace
place_id: place_vng_tower
work_model: HYBRID
is_primary: true
metadata:
  work_model_details:
    onsite_days_per_week: 3
    required_onsite_days: ["MON", "WED", "FRI"]

# Remote Work Location
id: wl_remote_vietnam
code: REMOTE_VN
name: "Remote - Vietnam"
location_id: null
place_id: place_remote
work_model: REMOTE
is_primary: true
metadata:
  remote_work_policy:
    policy_code: "REMOTE_POLICY_2025"
    equipment_provided: true
```

---

## Work Location Models

### Onsite Model

**Description:** Traditional full-time office-based work.

**Characteristics:**
- Fixed office location
- Assigned desk or workspace
- Standard office hours
- Full access to office amenities

**Example:**
```
Employee → WorkLocation (ONSITE) → Location (Office) → Place (Building)
```

### Remote Model

**Description:** Full-time work from home or remote location.

**Characteristics:**
- No fixed office location
- Home office setup
- Flexible work hours (typically)
- Virtual collaboration tools

**Example:**
```
Employee → WorkLocation (REMOTE) → Place (VIRTUAL)
```

### Hybrid Model

**Description:** Combination of onsite and remote work.

**Characteristics:**
- Primary office location
- Scheduled onsite days
- Flexible remote days
- Hot desk or shared workspace

**Example:**
```
Employee → WorkLocation (HYBRID) → Location (Hot Desk) → Place (Building)
         → Remote days per policy
```

---

## Use Cases

### Space Management
- Track office space utilization
- Plan seating arrangements
- Manage hot desk bookings
- Optimize space allocation

### Hybrid Work Management
- Define hybrid work policies
- Schedule onsite days
- Track location compliance
- Support flexible work arrangements

### Compliance & Reporting
- Track work location for tax purposes
- Report headcount by location
- Ensure labor law compliance
- Support data residency requirements

### Facility Planning
- Forecast space requirements
- Plan office expansions or consolidations
- Optimize facility costs
- Support real estate decisions

### Employee Experience
- Enable location preferences
- Support work-life balance
- Provide location-based services
- Facilitate collaboration

---

## Best Practices

### Location Data Management

1. **Accurate Geocoding:**
   - Maintain accurate coordinates
   - Verify addresses regularly
   - Update timezone information
   - Keep contact details current

2. **Hierarchy Management:**
   - Use place-location hierarchy
   - Support multi-level structures
   - Enable location inheritance
   - Maintain parent-child relationships

3. **Capacity Planning:**
   - Track actual vs. planned capacity
   - Monitor occupancy rates
   - Plan for growth
   - Optimize space utilization

### Hybrid Work Implementation

1. **Clear Policies:**
   - Define work model options
   - Set expectations for onsite days
   - Communicate policies clearly
   - Regular policy reviews

2. **Technology Support:**
   - Provide collaboration tools
   - Enable desk booking systems
   - Support remote access
   - Ensure security compliance

3. **Flexibility:**
   - Allow location preferences
   - Support schedule flexibility
   - Enable location changes
   - Accommodate special needs

---

## Integration Points

### Internal Modules

| Module | Usage |
|--------|-------|
| **Core** | Employee assignments, Position locations |
| **Time & Attendance** | Clock event geofencing, Location tracking |
| **Payroll** | Tax jurisdiction, Location-based pay |
| **Facilities** | Space booking, Maintenance tracking |

### External Systems

| System | Purpose |
|--------|---------|
| **Building Management** | Access control, Security |
| **Desk Booking** | Hot desk reservations |
| **Mapping Services** | Geocoding, Directions |
| **Real Estate** | Lease management, Space planning |

---

## Metrics & KPIs

### Space Utilization

- **Occupancy Rate:** % of space occupied
- **Desk Utilization:** % of desks used daily
- **Meeting Room Usage:** Hours booked vs. available
- **Cost per Seat:** Total facility cost / seats

### Hybrid Work

- **Onsite Attendance:** % of employees onsite daily
- **Remote Work Rate:** % of workforce remote
- **Hybrid Adoption:** % using hybrid model
- **Policy Compliance:** % following onsite day requirements

### Facility Management

- **Space per Employee:** Sqm per employee
- **Facility Cost:** Cost per employee per month
- **Maintenance Response:** Time to resolve issues
- **Employee Satisfaction:** Facility satisfaction score

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | 2025-12-01 | Added hybrid work support, work models |
| 1.0 | 2025-11-01 | Initial facility ontology |

---

## References

- **Facility Management Standards:** Industry best practices
- **Hybrid Work Models:** Modern workplace strategies
- **Space Planning:** Office design and utilization
