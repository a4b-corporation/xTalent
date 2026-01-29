---
entity: Address
domain: common
version: "1.0.0"
status: approved
owner: Common Domain Team
tags: [address, location, contact, vn-compliance]

attributes:
  # === IDENTITY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  # === OWNER REFERENCE (Polymorphic) ===
  - name: ownerType
    type: enum
    required: true
    description: Type of entity that owns this address
    values: [WORKER, EMPLOYEE, LEGAL_ENTITY, BUSINESS_UNIT]
  
  - name: ownerId
    type: string
    required: true
    description: Reference to owner entity (polymorphic - Worker, Employee, LegalEntity, or BusinessUnit)
  
  # === ADDRESS TYPE ===
  - name: addressTypeCode
    type: enum
    required: true
    description: Type of address. Aligned with xTalent naming convention and VN requirements.
    values: [PERMANENT, TEMPORARY, HOME, WORK, MAILING, EMERGENCY]
    default: HOME
  
  - name: isPrimary
    type: boolean
    required: true
    default: false
    description: Is this the primary address for the owner?
  
  # === ADDRESS LINES ===
  - name: addressLine1
    type: string
    required: true
    description: Street address line 1 (Số nhà, Đường/Phố)
    constraints:
      maxLength: 200
  
  - name: addressLine2
    type: string
    required: false
    description: Address line 2 (additional street info)
    constraints:
      maxLength: 200
  
  - name: addressLine3
    type: string
    required: false
    description: Address line 3 (additional info)
    constraints:
      maxLength: 200
  
  # === VN ADMINISTRATIVE HIERARCHY ===
  - name: ward
    type: string
    required: false
    description: Ward/Commune (Phường/Xã/Thị trấn - VN specific)
    constraints:
      maxLength: 100
  
  - name: district
    type: string
    required: false
    description: District (Quận/Huyện - VN specific)
    constraints:
      maxLength: 100
  
  - name: city
    type: string
    required: false
    description: City/Municipality (Thành phố/Thị xã)
    constraints:
      maxLength: 100
  
  - name: provinceCode
    type: string
    required: false
    description: Province/State code (Tỉnh/Thành phố - legacy field, prefer adminAreaId)
    constraints:
      maxLength: 20
  
  # === ADMIN AREA REFERENCE (NEW - Unified Hierarchy) ===
  - name: adminAreaId
    type: string
    required: false
    description: "FK → AdminArea.id. Reference to lowest-level admin area (e.g., Ward for VN). Enables hierarchy traversal. Preferred over flat string fields."
  
  - name: postalCode
    type: string
    required: false
    description: Postal/ZIP code
    constraints:
      maxLength: 20
  
  - name: countryCode
    type: string
    required: true
    description: Country code (ISO 3166-1 alpha-2). Reference to Country entity.
    constraints:
      pattern: "^[A-Z]{2}$"
  
  # === BUILDING DETAILS ===
  - name: buildingName
    type: string
    required: false
    description: Building/complex name (Tên tòa nhà)
    constraints:
      maxLength: 200
  
  - name: floorNumber
    type: string
    required: false
    description: Floor number (Tầng)
    constraints:
      maxLength: 20
  
  - name: unitNumber
    type: string
    required: false
    description: Unit/apartment number (Số căn hộ)
    constraints:
      maxLength: 20
  
  # === GEOLOCATION ===
  - name: latitude
    type: decimal
    required: false
    description: Latitude coordinate (for geolocation services)
    constraints:
      min: -90.0
      max: 90.0
  
  - name: longitude
    type: decimal
    required: false
    description: Longitude coordinate (for geolocation services)
    constraints:
      min: -180.0
      max: 180.0
  
  - name: isVerified
    type: boolean
    required: true
    default: false
    description: Has this address been verified (address validation service)?
  
  # === DATE EFFECTIVENESS ===
  - name: effectiveStartDate
    type: date
    required: false
    description: Date this address becomes effective
  
  - name: effectiveEndDate
    type: date
    required: false
    description: Date this address expires (null = current)
  
  # === METADATA ===
  - name: metadata
    type: json
    required: false
    description: Additional flexible data (delivery instructions, access codes, etc.)
  
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
  - name: locatedInCountry
    target: Country
    cardinality: many-to-one
    required: true
    inverse: hasAddresses
    description: Country where address is located.
  
  - name: locatedInAdminArea
    target: AdminArea
    cardinality: many-to-one
    required: false
    inverse: hasAddresses
    description: "Administrative area (lowest level, e.g., Ward for VN). Enables hierarchy traversal to get district, province automatically."

lifecycle:
  states: [ACTIVE, INACTIVE]
  initial: ACTIVE
  terminal: [INACTIVE]
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: Address no longer valid (moved, etc.)

policies:
  - name: OnePrimaryAddressPerTypePerOwner
    type: validation
    rule: Owner can have at most ONE primary address of each type
    expression: "COUNT(Address WHERE ownerId = X AND ownerType = Y AND addressTypeCode = Z AND isPrimary = true) <= 1"
    severity: WARNING
  
  - name: EffectiveDateConsistency
    type: validation
    rule: effectiveStartDate must be before effectiveEndDate (if set)
    expression: "effectiveEndDate IS NULL OR effectiveStartDate < effectiveEndDate"
  
  - name: VNPermanentAddressRequired
    type: business
    rule: For VN Workers, PERMANENT address (Hộ khẩu thường trú) is required for labor contract
    expression: "countryCode != 'VN' OR EXISTS(Address WHERE ownerType = WORKER AND addressTypeCode = PERMANENT)"
    severity: WARNING
  
  - name: VNAdministrativeHierarchy
    type: business
    rule: For VN addresses, ward/district/province should follow VN administrative structure
    severity: INFO
  
  - name: AdminAreaConsistency
    type: validation
    rule: "If adminAreaId is set, flat fields (ward, district, city) should match the hierarchy path from AdminArea"
    severity: WARNING
  
  - name: GeolocationValidation
    type: validation
    rule: Latitude must be between -90 and 90, Longitude between -180 and 180
    expression: "(latitude IS NULL OR (latitude >= -90 AND latitude <= 90)) AND (longitude IS NULL OR (longitude >= -180 AND longitude <= 180))"
---

# Entity: Address

## 1. Overview

The **Address** entity stores physical and mailing addresses for persons and organizations. It is a **polymorphic entity** that can be owned by Worker, Employee, LegalEntity, or BusinessUnit. Vietnam has specific requirements for permanent residence (hộ khẩu thường trú) vs temporary residence (địa chỉ tạm trú).

**Key Concept**:
```
Address = Polymorphic (Worker/Employee/LegalEntity/BusinessUnit)
VN Requirement: PERMANENT address (hộ khẩu thường trú) for labor contract
```

```mermaid
mindmap
  root((Address))
    Identity
      id
    Owner (Polymorphic)
      ownerType
      ownerId
    Address Type
      addressTypeCode
      isPrimary
    Address Lines
      addressLine1
      addressLine2
      addressLine3
    VN Hierarchy
      ward
      district
      city
      provinceCode
      postalCode
      countryCode
      adminAreaId (NEW)
    Building Details
      buildingName
      floorNumber
      unitNumber
    Geolocation
      latitude
      longitude
      isVerified
    Date Effectiveness
      effectiveStartDate
      effectiveEndDate
    Relationships
      locatedInCountry
      locatedInAdminArea
    Lifecycle
      ACTIVE
      INACTIVE
```

**Design Rationale**:
- **Polymorphic Owner**: Same entity for Worker, Employee, LegalEntity, BusinessUnit addresses
- **VN Compliance**: PERMANENT (hộ khẩu thường trú) + TEMPORARY (địa chỉ tạm trú) support
- **Administrative Hierarchy**: adminAreaId → AdminArea (N-level). Flat fields (ward, district) for convenience.
- **Geolocation**: Optional lat/long for mapping services

---

## 2. Attributes

### 2.1 Identity Attributes

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| id | string | ✓ | Unique internal identifier (UUID) | person.address.id |

### 2.2 Owner Reference (Polymorphic)

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| ownerType | enum | ✓ | WORKER, EMPLOYEE, LEGAL_ENTITY, BUSINESS_UNIT | (person.address.metadata.owner_type) |
| ownerId | string | ✓ | Reference to owner entity | person.address.worker_id → person.worker.id |

### 2.3 Address Type

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| addressTypeCode | enum | ✓ | PERMANENT, TEMPORARY, HOME, WORK, MAILING, EMERGENCY | person.address.address_type_code → common.code_list(ADDRESS_TYPE) |
| isPrimary | boolean | ✓ | Primary address flag | person.address.is_primary |

### 2.4 Address Lines

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| addressLine1 | string | ✓ | Street address line 1 (Số nhà, Đường) | person.address.street_line |
| addressLine2 | string | | Address line 2 | (person.address.metadata.address_line2) |
| addressLine3 | string | | Address line 3 | (person.address.metadata.address_line3) |

### 2.5 Administrative Hierarchy (VN & Generic)

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| ward | string | | Phường/Xã/Thị trấn (VN) - flat field for search | (person.address.metadata.ward) |
| district | string | | Quận/Huyện (VN) - flat field for search | (person.address.metadata.district) |
| city | string | | Thành phố/Thị xã | (person.address.metadata.city) |
| provinceCode | string | | Tỉnh/Thành phố code (legacy - prefer adminAreaId) | (person.address.metadata.province_code) |
| postalCode | string | | Postal/ZIP code | person.address.postal_code |
| countryCode | string | ✓ | Country code (ISO 3166-1) | (person.address.metadata.country_code) |
| **adminAreaId** | string | | **FK → [[AdminArea]]** (preferred). Links to lowest-level admin area (e.g., Ward). Enables hierarchy traversal. | person.address.admin_area_id → geo.admin_area.id |

### 2.6 Building Details

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| buildingName | string | | Building/complex name | (person.address.metadata.building_name) |
| floorNumber | string | | Floor number | (person.address.metadata.floor_number) |
| unitNumber | string | | Unit/apartment number | (person.address.metadata.unit_number) |

### 2.7 Geolocation

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| latitude | decimal | | Latitude (-90 to 90) | (person.address.metadata.latitude) |
| longitude | decimal | | Longitude (-180 to 180) | (person.address.metadata.longitude) |
| isVerified | boolean | ✓ | Address verified? | (person.address.metadata.is_verified) |

### 2.8 Date Effectiveness

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| effectiveStartDate | date | | Address becomes effective | person.address.effective_start_date |
| effectiveEndDate | date | | Address expires | person.address.effective_end_date |

### 2.9 Audit Attributes

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|----------|
| createdAt | datetime | ✓ | Record creation timestamp | person.address.created_at |
| updatedAt | datetime | ✓ | Last modification timestamp | person.address.updated_at |
| createdBy | string | ✓ | User who created record | <<person.address.created_by>> |
| updatedBy | string | ✓ | User who last modified | <<person.address.updated_by>> |

---

## 3. Relationships

```mermaid
erDiagram
    Country ||--o{ Address : hasAddresses
    AdminArea ||--o{ Address : hasAddresses
    Worker ||--o{ Address : "hasAddresses (polymorphic)"
    Employee ||--o{ Address : "hasAddresses (polymorphic)"
    LegalEntity ||--o{ Address : "hasAddresses (polymorphic)"
    BusinessUnit ||--o{ Address : "hasAddresses (polymorphic)"
    
    Address {
        string id PK
        enum ownerType
        string ownerId FK
        enum addressTypeCode
        string addressLine1
        string ward
        string district
        string adminAreaId FK
        string countryCode FK
        boolean isPrimary
    }
    
    AdminArea {
        string id PK
        string code
        string name
        enum levelCode
        string parentId FK
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[Country]] | locatedInCountry | N:1 | Country where address is located |
| [[AdminArea]] | locatedInAdminArea | N:1 | Administrative area (Ward → District → Province hierarchy) |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> ACTIVE: Create Address
    
    ACTIVE --> INACTIVE: Deactivate (moved, no longer valid)
    
    INACTIVE --> [*]
    
    note right of ACTIVE
        Currently valid address
        Can be used for correspondence
    end note
    
    note right of INACTIVE
        No longer valid
        Historical record
    end note
```

### State Descriptions

| State | Description | Allowed Operations |
|-------|-------------|-------------------|
| **ACTIVE** | Currently valid address | Can deactivate |
| **INACTIVE** | No longer valid | Read-only, historical |

### Transition Rules

| From | To | Trigger | Guard Condition |
|------|-----|---------|--------------------|
| ACTIVE | INACTIVE | deactivate | Address no longer valid (moved, etc.) |

---

## 5. Business Rules Reference

### Validation Rules
- **OnePrimaryAddressPerTypePerOwner**: At most ONE primary address of each type per owner (WARNING)
- **EffectiveDateConsistency**: effectiveStartDate < effectiveEndDate (if set)
- **GeolocationValidation**: Latitude (-90 to 90), Longitude (-180 to 180)
- **AdminAreaConsistency**: If adminAreaId is set, flat fields (ward, district, city) should match hierarchy path (WARNING)

### Business Constraints
- **VNPermanentAddressRequired**: VN Workers need PERMANENT address for labor contract (WARNING)
- **VNAdministrativeHierarchy**: VN addresses should follow ward → district → city → province structure

### VN Labor Law Compliance
- **Hộ khẩu thường trú** (PERMANENT): Required for labor contract
- **Địa chỉ tạm trú** (TEMPORARY): If different from permanent
- **Administrative Hierarchy**: Phường/Xã → Quận/Huyện → Tỉnh/Thành phố

### Address Types

| Type | VN Name | Description | Use Case |
|------|---------|-------------|----------|
| PERMANENT | Hộ khẩu thường trú | Permanent residence | Labor contract (required) |
| TEMPORARY | Địa chỉ tạm trú | Temporary residence | If different from permanent |
| HOME | Địa chỉ nhà | Home address | Personal correspondence |
| WORK | Địa chỉ công ty | Work address | Office location |
| MAILING | Địa chỉ nhận thư | Mailing address | Mail delivery |
| EMERGENCY | Địa chỉ liên hệ khẩn | Emergency contact address | Emergency situations |

### VN Address Format

```
[Số nhà], [Đường/Phố]
[Phường/Xã], [Quận/Huyện]
[Tỉnh/Thành phố], Việt Nam

Example:
123 Nguyễn Huệ
Phường Bến Nghé, Quận 1
TP. Hồ Chí Minh, Việt Nam
```

### Related Business Rules Documents
- See `[[address-management.brs.md]]` for complete business rules catalog
- See `[[vn-address-validation.brs.md]]` for VN address validation rules
- See `[[geolocation-services.brs.md]]` for geolocation integration

---

## 6. Use Cases

### Use Case 1: Worker Permanent Address (VN Labor Contract)

```yaml
Address:
  id: "addr-001"
  ownerType: "WORKER"
  ownerId: "worker-001"
  addressTypeCode: "PERMANENT"
  isPrimary: true
  addressLine1: "123 Nguyễn Huệ"
  ward: "Phường Bến Nghé"           # Flat field (for search)
  district: "Quận 1"                # Flat field (for search)
  city: "TP. Hồ Chí Minh"
  adminAreaId: "26734"              # NEW: FK → AdminArea (Ward level)
  countryCode: "VN"
  
# Hierarchy traversal from adminAreaId:
# Ward(26734) → District(760) → Province(VN-SG) → Country(VN)

# Labor Contract Text:
# "Hộ khẩu thường trú: 123 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM"
```

### Use Case 2: Legal Entity Office Address

```yaml
Address:
  id: "addr-002"
  ownerType: "LEGAL_ENTITY"
  ownerId: "le-001"
  addressTypeCode: "WORK"
  isPrimary: true
  addressLine1: "Tầng 5, Tòa nhà E-Town Central"
  addressLine2: "11 Đoàn Văn Bơ"
  ward: "Phường 12"
  district: "Quận 4"
  city: "TP. Hồ Chí Minh"
  provinceCode: "VN-SG"
  countryCode: "VN"
  buildingName: "E-Town Central"
  floorNumber: "5"
```

### Use Case 3: Employee Temporary Address

```yaml
# Permanent Address (hộ khẩu)
Address_Permanent:
  ownerType: "WORKER"
  addressTypeCode: "PERMANENT"
  addressLine1: "456 Lê Lợi"
  city: "Huế"
  provinceCode: "VN-26"  # Thừa Thiên Huế

# Temporary Address (tạm trú)
Address_Temporary:
  ownerType: "WORKER"
  addressTypeCode: "TEMPORARY"
  addressLine1: "789 Võ Văn Tần"
  city: "TP. Hồ Chí Minh"
  provinceCode: "VN-SG"
```

---

*Document Status: APPROVED - Based on Oracle HCM, SAP SuccessFactors, Workday patterns*  
*VN Compliance: Labor Code 2019 (permanent residence requirement)*
