---
entity: Address
version: "1.0.0"
status: approved
created: 2026-01-25
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# Schema Standards: Address

## 1. Summary

The **Address** entity stores physical and mailing addresses for persons and organizations. All major HCM vendors support multiple addresses per person with type classification (Home, Work, Mailing, etc.). Vietnam has specific requirements for permanent residence (hộ khẩu thường trú) vs temporary residence (địa chỉ tạm trú).

**Confidence**: HIGH - Based on 3 major HCM vendors

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Entity**: `PER_ADDRESSES_F` (date-effective)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| ADDRESS_ID | Number | Y | Unique identifier |
| PERSON_ID | Number | Y | FK to Person |
| ADDRESS_TYPE | Enum | Y | HOME/WORK/MAILING |
| ADDRESS_LINE_1 | String | Y | Street address line 1 |
| ADDRESS_LINE_2 | String | N | Line 2 |
| ADDRESS_LINE_3 | String | N | Line 3 |
| TOWN_OR_CITY | String | N | City/Town |
| REGION_1 | String | N | State/Province |
| REGION_2 | String | N | County/District |
| POSTAL_CODE | String | N | Postal/ZIP code |
| COUNTRY | String | Y | Country code |
| PRIMARY_FLAG | String | N | Primary address |
| EFFECTIVE_START_DATE | Date | Y | Record start |
| EFFECTIVE_END_DATE | Date | Y | Record end |

---

### 2.2 SAP SuccessFactors

**Entity**: `PerAddressDEFLT` + country-specific entities

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| addressType | Enum | Y | Address type |
| address1 | String | Y | Address line 1 |
| address2 | String | N | Address line 2 |
| address3 | String | N | Address line 3 |
| city | String | N | City |
| state | String | N | State/Province |
| county | String | N | County |
| zipCode | String | N | Postal code |
| country | String | Y | Country |
| startDate | Date | Y | Start date |
| endDate | Date | N | End date |

---

### 2.3 Workday

**Entity**: `Address_Data`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Address_ID | String | Y | Unique identifier |
| Address_Line_1 | String | Y | Street address |
| Address_Line_2 | String | N | Line 2 |
| Municipality | String | N | City |
| Submunicipality | String | N | District |
| Region | Reference | N | State/Province |
| Subregion | Reference | N | County |
| Postal_Code | String | N | Postal code |
| Country_Reference | Reference | Y | Country |
| Usage_Type | Reference | Y | Home/Work/Mailing |
| Primary | Boolean | Y | Primary address |
| Public | Boolean | N | Publicly visible |

---

## 3. Common Pattern Analysis

### Universal Attributes (3/3 vendors)
| Attribute | Oracle | SAP | Workday | Type |
|-----------|--------|-----|---------|------|
| Address ID | ✓ | ✓ | ✓ | uuid |
| Person/Owner | ✓ | ✓ | ✓ | reference |
| Address Type | ✓ | ✓ | ✓ | enum |
| Address Line 1 | ✓ | ✓ | ✓ | string |
| City | ✓ | ✓ | ✓ | string |
| Country | ✓ | ✓ | ✓ | reference |

---

## 4. Canonical Schema: Address

### Required Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique identifier | Universal |
| owner | reference | FK to Person or Org | Universal |
| ownerType | enum | PERSON/ORGANIZATION | Best practice |
| addressType | enum | HOME/WORK/MAILING | Universal |
| addressLine1 | string(200) | Street address line 1 | Universal |
| country | reference | FK to Country | Universal |

### Recommended Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| addressLine2 | string(200) | Address line 2 | 3/3 vendors |
| addressLine3 | string(200) | Address line 3 | 3/3 vendors |
| city | string(100) | City/Municipality | 3/3 vendors |
| district | string(100) | District/Submunicipality | 3/3 vendors |
| province | reference | State/Province/Region | 3/3 vendors |
| ward | string(100) | Ward/Commune (VN) | VN specific |
| postalCode | string(20) | Postal/ZIP code | 3/3 vendors |
| isPrimary | boolean | Primary address | 3/3 vendors |
| effectiveDate | date | When address starts | Oracle, SAP |
| endDate | date | When address ends | Oracle, SAP |

### Optional Attributes
| Attribute | Type | When to Include |
|-----------|------|-----------------|
| latitude | decimal | Geolocation services |
| longitude | decimal | Geolocation services |
| isVerified | boolean | Address verification |
| buildingName | string | Office buildings |
| floorNumber | string | Multi-floor buildings |
| unitNumber | string | Apartment/unit |

---

## 5. Address Types

| Code | Description | VN Name |
|------|-------------|---------|
| PERMANENT | Permanent residence | Hộ khẩu thường trú |
| TEMPORARY | Temporary residence | Địa chỉ tạm trú |
| HOME | Home address | Địa chỉ nhà |
| WORK | Work address | Địa chỉ công ty |
| MAILING | Mailing address | Địa chỉ nhận thư |
| EMERGENCY | Emergency contact address | Địa chỉ liên hệ khẩn |

---

## 6. Relationships

| Relationship | Target | Cardinality | Description |
|--------------|--------|-------------|-------------|
| owner | Person/Organization | N:1 | Address owner |
| country | Country | N:1 | Country reference |
| province | Province | N:1 | Province/State |
| district | District | N:1 | District (if master) |
| ward | Ward | N:1 | Ward/Commune (if master) |

---

## 7. Local Adaptations (Vietnam)

### VN Administrative Hierarchy
```
Country (Quốc gia) - Vietnam
└── Province (Tỉnh/Thành phố) - 63 provinces
    └── District (Quận/Huyện)
        └── Ward (Phường/Xã/Thị trấn)
```

### VN Address Format
```
[Số nhà], [Đường/Phố]
[Phường/Xã], [Quận/Huyện]
[Tỉnh/Thành phố], Việt Nam
```

### Required for Labor Contract
- **Hộ khẩu thường trú** (Permanent residence): Required
- **Địa chỉ tạm trú** (Temporary): If different from permanent

### VN-Specific Fields
| Field | VN Name | Description |
|-------|---------|-------------|
| ward | Phường/Xã | Ward/Commune |
| district | Quận/Huyện | District |
| province | Tỉnh/Thành phố | Province/City |
| streetNumber | Số nhà | House number |
| streetName | Tên đường | Street name |

---

*Document Status: APPROVED*
