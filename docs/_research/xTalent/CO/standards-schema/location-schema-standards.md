---
entity: Location
version: "1.0.0"
status: approved
created: 2026-01-26
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# Schema Standards: Location

## 1. Summary

The **Location** entity represents a physical or virtual place where business activities occur and where employees can be assigned. Unlike a simple Address, a Location is a managed business object with codes, operational attributes (calendars, time zones), and legal/regulatory associations.

**Confidence**: HIGH - Based on 3 major HCM vendors

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Entity**: `HR_LOCATIONS_ALL` / `PER_LOCATIONS`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| LOCATION_ID | Number | Y | Unique identifier |
| LOCATION_CODE | String | Y | Business code |
| LOCATION_NAME | String | Y | Display name |
| DESCRIPTION | String | N | Description |
| ACTIVE_STATUS | Enum | Y | Active/Inactive |
| ADDRESS_ID | Number | N | Link to Address |
| INVENTORY_ORGANIZATION_ID | Number | N | Inventory Org link |
| SHIP_TO_SITE_FLAG | String | N | Shipping enabled |
| BILL_TO_SITE_FLAG | String | N | Billing enabled |
| OFFICE_SITE_FLAG | String | N | Office site flag |
| DESIGNATED_RECEIVER_ID | Number | N | Contact person |
| LANGUAGE | String | N | Language |
| TIMEZONE_CODE | String | N | Time zone |

### 2.2 SAP SuccessFactors

**Entity**: `Location` (Foundation Object)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| externalCode | String | Y | Unique code |
| name | String | Y | Name |
| description | String | N | Description |
| status | Enum | Y | Status |
| start_date | Date | Y | Effective date |
| end_date | Date | N | End date |
| legalEntity | Reference | N | Legal Entity |
| locationGroup | Reference | N | Location Group |
| timeZone | String | N | Time zone |
| standardWeeklyHours | Decimal | N | Std hours |
| geozone | Reference | N | Geo Zone (Pay) |

### 2.3 Workday

**Entity**: `Location` (Business Site)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Location_ID | String | Y | Unique ID |
| Location_Name | String | Y | Name |
| Location_Type | Reference | Y | Business Site/Remote |
| Usage | Reference | N | Business/Shipping |
| Time_Profile | Reference | N | Work schedule |
| Time_Zone | Reference | N | Time zone |
| Address_Data | Complex | Y | Address details |
| Contact_Data | Complex | N | Phone/Email |

---

## 3. Canonical Schema: Location

### Required Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique identifier | Universal |
| code | string(50) | Business code (unique) | Universal |
| name | string(200) | Location name | Universal |
| status | enum | Active/Inactive | Universal |
| address | reference | FK to Address (Master) | Universal |
| effectiveDate | date | Start date | SAP, Oracle |

### Recommended Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| description | text | Location description | 3/3 vendors |
| timeZone | string(50) | IANA Time Zone ID | 3/3 vendors |
| locationType | enum | Office/Factory/Remote/Store | Workday |
| legalEntity | reference | Primary Legal Entity | SAP |
| locationGroup | reference | Grouping (Region/Area) | SAP |
| standardHours | decimal | Standard weekly hours | SAP |
| isMainOffice | boolean | HQ flag | Best practice |
| geoZone | reference | For Geopay differentials | SAP |

### Optional Attributes
| Attribute | Type | When to Include |
|-----------|------|-----------------|
| designatedReceiver | reference | Site contact person |
| capacity | number | Seat capacity |
| calendar | reference | Holiday calendar |
| floorPlanUrl | string | Map/Floor plan |
| shipTo | boolean | Shipping allowed |
| billTo | boolean | Billing allowed |

---

## 4. Key Distinctions

### Location vs Address
*   **Address**: A value object (just lines of text, city, country).
*   **Location**: A business entity (has a Code, Manager, Cost, Time Zone) that *uses* an Address.
*   **Example**:
    *   Location: "HCMC - Campus 1" (Code: VN-HCM-01)
    *   Address: "123 Le Loi, District 1, HCMC"

---

## 5. Relationships

| Relationship | Target | Cardinality | Description |
|--------------|--------|-------------|-------------|
| address | Address | 1:1 | Physical address |
| legalEntity | LegalEntity | N:N | Associated entities |
| locationGroup | LocationGroup | N:1 | Grouping |
| managers | Employee | 1:N | Site managers |
| holidayCalendar | Calendar | N:1 | Public holidays |

---

## 6. Local Adaptations (Vietnam)

- **Tax Location**: Locations may need to be linked to specific Tax Departments (Cục Thuế) for local reporting.
- **Labor Compliance**: Specific locations may be registered as labor usage points.

---

*Document Status: APPROVED*
