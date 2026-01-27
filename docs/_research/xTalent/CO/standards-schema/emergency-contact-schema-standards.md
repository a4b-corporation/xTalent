---
entity: EmergencyContact
version: "1.0.0"
status: approved
created: 2026-01-26
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# Schema Standards: Emergency Contact

## 1. Summary

The **Emergency Contact** entity stores details of persons to be contacted in case of emergency involving an employee. Unlike general contacts, these records carry specific priority levels, relationship definitions, and are critical for duty-of-care compliance.

**Confidence**: HIGH - Based on 3 major HCM vendors

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Entity**: `PER_EMERGENCY_CONTACTS`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| CONTACT_ID | Number | Y | Unique identifier |
| PERSON_ID | Number | Y | FK to Employee |
| CONTACT_PERSON_ID | Number | N | FK to Person (if existing) |
| CONTACT_TYPE | Enum | Y | Relationship (Spouse, etc.) |
| SEQUENCE_NUMBER | Number | Y | Priority order |
| PRIMARY_FLAG | String | Y | Primary contact |
| FIRST_NAME | String | N | Contact first name |
| LAST_NAME | String | N | Contact last name |
| WORK_PHONE | String | N | Work phone |
| HOME_PHONE | String | N | Home phone |
| MOBILE_PHONE | String | N | Mobile phone |

### 2.2 SAP SuccessFactors

**Entity**: `PerEmergencyContacts`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| name | String | Y | Contact name |
| relationship | String | Y | Relationship ID |
| phone | String | N | Phone number |
| email | String | N | Email address |
| isPrimary | Boolean | N | Primary flag |
| priority | String | N | Contact priority |
| address | String | N | Contact address |

### 2.3 Workday

**Entity**: `Emergency_Contact_Data`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Priority | Number | Y | 1, 2, 3... |
| Relationship | Reference | Y | Relationship type |
| Primary_Contact | Boolean | Y | Is primary |
| Related_Person | Reference | N | Link to existing person |
| Phone_Data | Complex | Y | Phone details |
| Email_Data | Complex | N | Email details |
| Address_Data | Complex | N | Address details |

---

## 3. Canonical Schema: EmergencyContact

### Required Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique identifier | Universal |
| employee | reference | FK to Employee | Universal |
| contactName | string(200) | Full name of contact | Universal |
| relationship | enum | Relationship to employee | Universal |
| primaryPhone | string(30) | Main phone number | Universal |
| priority | integer | Order (1 = Highest) | Oracle, Workday |

### Recommended Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| isPrimary | boolean | Primary contact flag | 3/3 vendors |
| alternatePhone | string(30) | Secondary phone | Best practice |
| email | string(254) | Email address | SAP, Workday |
| address | string(500) | Physical address | SAP, Workday |
| sameAddressAsEmployee | boolean | Address flag | Best practice |
| notes | text | Special instructions (medical, etc.) | Best practice |

### Optional Attributes
| Attribute | Type | When to Include |
|-----------|------|-----------------|
| contactPerson | reference | If contact is also an employee |
| language | enum | Preferred language |

---

## 4. Relationship Enums (VN Context)

| Code | VN Name | Description |
|------|---------|-------------|
| SPOUSE | Vợ/Chồng | Legal spouse |
| PARENT | Cha/Mẹ | Parent |
| CHILD | Con | Child (adult) |
| SIBLING | Anh/Chị/Em | Sibling |
| FRIEND | Bạn bè | Non-relative |
| COLLEAGUE | Đồng nghiệp | Work colleague |
| OTHER | Khác | Other relationship |

---

## 5. Local Adaptations (Vietnam)

- **Priority**: VN companies often require at least one relative (Spouse/Parent) as priority 1.
- **Address**: Recommended to capture location for emergency logistics.

---

*Document Status: APPROVED*
