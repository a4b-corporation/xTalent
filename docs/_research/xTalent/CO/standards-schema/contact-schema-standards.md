---
entity: Contact
version: "1.0.0"
status: approved
created: 2026-01-25
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# Schema Standards: Contact (Phone/Email/Emergency)

## 1. Summary

The **Contact** entity stores communication information for persons, including phone numbers, email addresses, and emergency contacts. This is typically implemented as multiple specialized entities (Phone, Email, EmergencyContact) or a single polymorphic Contact entity with type classification.

**Confidence**: HIGH - Based on 3 major HCM vendors

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Entity Structure**:
| Entity | Description |
|--------|-------------|
| `PER_PHONES` | Phone numbers |
| `PER_EMAIL_ADDRESSES` | Email addresses |
| `PER_EMERGENCY_CONTACTS` | Emergency contact persons |
| `PER_CONTACT_RELATIONSHIPS` | Person relationships |

**Key Attributes (PER_PHONES)**:
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| PHONE_ID | Number | Y | Unique identifier |
| PERSON_ID | Number | Y | FK to Person |
| PHONE_TYPE | Enum | Y | HOME/MOBILE/WORK |
| PHONE_NUMBER | String | Y | Phone number |
| COUNTRY_CODE | String | N | Country dialing code |
| AREA_CODE | String | N | Area code |
| PRIMARY_FLAG | String | N | Primary phone |
| LEGISLATION_CODE | String | N | Country |

**Key Attributes (PER_EMAIL_ADDRESSES)**:
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| EMAIL_ADDRESS_ID | Number | Y | Unique identifier |
| PERSON_ID | Number | Y | FK to Person |
| EMAIL_TYPE | Enum | Y | HOME/WORK |
| EMAIL_ADDRESS | String | Y | Email address |
| PRIMARY_FLAG | String | N | Primary email |

---

### 2.2 SAP SuccessFactors

**Entity Structure**:
| Entity | Description |
|--------|-------------|
| `PerPhone` | Phone numbers |
| `PerEmail` | Email addresses |
| `PerEmergencyContacts` | Emergency contacts |

**Key Attributes (PerPhone)**:
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| phoneType | Enum | Y | Phone type |
| phoneNumber | String | Y | Phone number |
| countryCode | String | N | Country code |
| areaCode | String | N | Area code |
| extension | String | N | Extension |
| isPrimary | Boolean | N | Primary flag |

**Key Attributes (PerEmail)**:
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| emailType | Enum | Y | Email type |
| emailAddress | String | Y | Email address |
| isPrimary | Boolean | N | Primary flag |

---

### 2.3 Workday

**Entity Structure**:
| Entity | Description |
|--------|-------------|
| `Phone_Data` | Phone information |
| `Email_Address_Data` | Email addresses |
| `Emergency_Contact_Data` | Emergency contacts |

**Key Attributes**:
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Phone_Number | String | Y | Complete phone number |
| Phone_Device_Type | Reference | Y | Mobile/Landline |
| Usage_Type | Reference | Y | Work/Home/Business |
| Primary | Boolean | Y | Primary flag |
| Public | Boolean | N | Publicly visible |

---

## 3. Canonical Schema: Phone

### Required Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique identifier | Universal |
| person | reference | FK to Person | Universal |
| phoneType | enum | HOME/MOBILE/WORK | Universal |
| phoneNumber | string(30) | Phone number | Universal |

### Recommended Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| countryCode | string(5) | Country dialing code | 3/3 vendors |
| areaCode | string(10) | Area code | Oracle, SAP |
| extension | string(10) | Phone extension | SAP |
| isPrimary | boolean | Primary phone flag | 3/3 vendors |
| isVerified | boolean | Verified status | Best practice |
| deviceType | enum | Mobile/Landline | Workday |

---

## 4. Canonical Schema: Email

### Required Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique identifier | Universal |
| person | reference | FK to Person | Universal |
| emailType | enum | HOME/WORK/OTHER | Universal |
| emailAddress | string(254) | Email address | Universal |

### Recommended Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| isPrimary | boolean | Primary email flag | 3/3 vendors |
| isVerified | boolean | Verified status | Best practice |
| isPublic | boolean | Publicly visible | Workday |

---

## 5. Canonical Schema: EmergencyContact

### Required Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique identifier | Universal |
| person | reference | FK to Person (employee) | Universal |
| contactName | string(200) | Contact person name | Universal |
| relationship | enum | Relationship type | Universal |
| primaryPhone | string(30) | Primary phone number | Universal |

### Recommended Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| priority | number | Contact priority (1,2,3) | Best practice |
| alternatePhone | string(30) | Secondary phone | Best practice |
| address | string(500) | Contact address | Oracle |
| isPrimary | boolean | Primary emergency contact | 3/3 vendors |
| notes | text | Special instructions | Best practice |

---

## 6. Relationship Enums

### Phone Types
| Code | Description |
|------|-------------|
| HOME | Home phone |
| MOBILE | Mobile/Cell phone |
| WORK | Work phone |
| FAX | Fax number |
| OTHER | Other |

### Email Types
| Code | Description |
|------|-------------|
| HOME | Personal email |
| WORK | Work email |
| OTHER | Other |

### Relationship Types (Emergency Contact)
| Code | VN Name |
|------|---------|
| SPOUSE | Vợ/Chồng |
| PARENT | Cha/Mẹ |
| CHILD | Con |
| SIBLING | Anh/Chị/Em |
| FRIEND | Bạn bè |
| OTHER | Khác |

---

## 7. Local Adaptations (Vietnam)

### Phone Format
- Country code: +84
- Mobile: 09x, 03x, 07x, 08x (10 digits)
- Landline: Area code + number

### Required for Labor Contract
- At least one phone number
- Emergency contact (recommended)

---

*Document Status: APPROVED*
