# Common Sub-Module - Glossary

**Version**: 2.0  
**Last Updated**: 2025-12-01  
**Sub-Module**: Master Data & Reference Tables

---

## 📋 Overview

The Common sub-module provides foundational master data and reference tables used across all modules. These are system-wide catalogs that ensure consistency, standardization, and localization support.

**Purpose**: Central repository for lookup values, classifications, and reference data that multiple modules depend on.

### Entities (10)
1. **CodeList** - Multi-purpose lookup values
2. **Currency** - ISO currency codes
3. **TimeZone** - IANA time zones
4. **Industry** - Industry classification hierarchy
5. **ContactType** - Contact method types
6. **RelationshipGroup** - Relationship groupings
7. **RelationshipType** - Personal relationship types
8. **TalentMarket** - Multi-market structure
9. **SkillMaster** - Technical/functional skills catalog
10. **CompetencyMaster** - Behavioral competencies catalog

---

## 🔑 Key Entities

### CodeList

**Definition**: Flexible multi-purpose lookup table for system-wide code values and classifications.

**Purpose**:
- Centralize lookup values to avoid hardcoding
- Support localization (multiple languages)
- Enable business users to manage codes
- Maintain historical changes (SCD Type 2)

**Key Attributes**:
- `group_code` - Logical grouping (e.g., GENDER, MARITAL_STATUS)
- `code` - Actual code value (e.g., M, F, SINGLE, MARRIED)
- `display_en` - English display text
- `display_local` - Local language display text
- `sort_order` - Display sequence
- `is_active` - Active/inactive flag
- `metadata` - Additional properties (color, icon, validation rules)
- SCD Type 2 fields

**Common Code Groups**:

| Group Code | Values | Usage |
|------------|--------|-------|
| GENDER | M, F, O, U | Worker gender |
| MARITAL_STATUS | SINGLE, MARRIED, DIVORCED, WIDOWED, SEPARATED | Worker marital status |
| EMPLOYEE_STATUS | ACTIVE, TERMINATED, SUSPENDED, ON_LEAVE | Employee status |
| ASSIGNMENT_REASON | HIRE, TRANSFER, PROMOTION, DEMOTION, RETURN | Assignment change reason |
| CONTRACT_TYPE | PERMANENT, FIXED_TERM, PROBATION, SEASONAL | Contract types |
| DOCUMENT_TYPE | NATIONAL_ID, PASSPORT, DEGREE, CERTIFICATE | Document types |

**Business Rules**:
- ✅ Codes within a group must be unique
- ✅ Display text supports multiple languages
- ✅ Inactive codes can't be used for new records
- ✅ Historical codes retained for reporting

**Example**:
```yaml
CodeList:
  - group: MARITAL_STATUS
    code: MARRIED
    display_en: "Married"
    display_local: "Đã kết hôn"
    sort_order: 2
    is_active: true
    metadata:
      icon: "💑"
      tax_impact: true
```

---

### Currency

**Definition**: ISO-4217 currency codes with precision and formatting rules.

**Purpose**:
- Standardize currency handling
- Support multi-currency payroll
- Define decimal precision per currency
- Exchange rate management

**Key Attributes**:
- `code` - ISO-4217 code (VND, USD, EUR)
- `name` - Currency name
- `symbol` - Currency symbol (₫, $, €)
- `decimal_places` - Number of decimal places (0 for VND, 2 for USD)
- `is_active` - Active flag
- SCD Type 2

**Common Currencies**:
```yaml
Currencies:
  - code: VND
    name: "Vietnamese Dong"
    symbol: "₫"
    decimal_places: 0
    
  - code: USD
    name: "US Dollar"
    symbol: "$"
    decimal_places: 2
    
  - code: EUR
    name: "Euro"
    symbol: "€"
    decimal_places: 2
    
  - code: SGD
    name: "Singapore Dollar"
    symbol: "S$"
    decimal_places: 2
```

**Business Rules**:
- ✅ Currency codes follow ISO-4217 standard
- ✅ Decimal places determine rounding rules
- ✅ Used in salary, allowances, expense claims
- ✅ Exchange rates managed separately

---

### TimeZone

**Definition**: IANA time zone database for global time management.

**Purpose**:
- Support global workforce
- Accurate time tracking across regions
- Daylight saving time handling
- Meeting scheduling

**Key Attributes**:
- `code` - IANA timezone code
- `name` - Timezone name
- `utc_offset` - Standard UTC offset
- `supports_dst` - Daylight saving time flag
- `is_active` - Active flag

**Common Time Zones**:
```yaml
TimeZones:
  - code: "Asia/Ho_Chi_Minh"
    name: "Indochina Time"
    utc_offset: "+07:00"
    supports_dst: false
    
  - code: "America/New_York"
    name: "Eastern Time"
    utc_offset: "-05:00"
    supports_dst: true
    
  - code: "Asia/Singapore"
    name: "Singapore Time"
    utc_offset: "+08:00"
    supports_dst: false
```

**Use Cases**:
- Work location time zones
- Global assignment scheduling
- Time & attendance tracking
- Report generation timestamps

---

### Industry

**Definition**: Hierarchical industry classification based on ISIC/NAICS standards.

**Purpose**:
- Classify legal entities by industry
- Support industry-specific regulations
- Benchmark against industry standards
- Reporting and analytics

**Key Attributes**:
- `code` - Industry code
- `name` - Industry name
- `parent_id` - Parent industry (hierarchy)
- `level` - Hierarchy level (1=sector, 2=division, 3=group)
- `path` - Materialized path
- SCD Type 2

**Hierarchy Example**:
```
Technology (Level 1)
  ├─ Software (Level 2)
  │   ├─ SaaS (Level 3)
  │   ├─ Enterprise Software (Level 3)
  │   └─ Mobile Apps (Level 3)
  └─ Hardware (Level 2)
      ├─ Semiconductors (Level 3)
      └─ Consumer Electronics (Level 3)

Financial Services (Level 1)
  ├─ Banking (Level 2)
  └─ Insurance (Level 2)
```

**Business Rules**:
- ✅ Supports up to 4 hierarchy levels
- ✅ Legal entities link to lowest applicable level
- ✅ Used for compliance and reporting

---

### ContactType

**Definition**: Types of contact methods with validation rules and formatting.

**Purpose**:
- Standardize contact information
- Validate contact values
- Support multiple contact channels
- UI rendering (icons, input masks)

**Key Attributes**:
- `code` - Contact type code
- `name` - Display name
- `validation_regex` - Validation pattern
- `input_mask` - Input formatting mask
- `icon` - UI icon reference
- `is_active` - Active flag

**Contact Types**:
```yaml
ContactTypes:
  - code: MOBILE_PERSONAL
    name: "Personal Mobile"
    validation_regex: "^\\+?[0-9]{10,15}$"
    input_mask: "+84-###-###-####"
    icon: "📱"
    
  - code: EMAIL_WORK
    name: "Work Email"
    validation_regex: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
    icon: "📧"
    
  - code: LINKEDIN
    name: "LinkedIn Profile"
    validation_regex: "^(https?://)?(www\\.)?linkedin\\.com/in/[a-zA-Z0-9-]+/?$"
    icon: "💼"
    
  - code: WHATSAPP
    name: "WhatsApp"
    validation_regex: "^\\+?[0-9]{10,15}$"
    icon: "💬"
```

**Business Rules**:
- ✅ Contact values must match validation regex
- ✅ Input masks guide user entry
- ✅ Icons enhance UI/UX

---

### RelationshipGroup

**Definition**: High-level grouping of relationship types.

**Purpose**:
- Organize relationship types logically
- Support different relationship contexts
- Enable group-level permissions

**Groups**:
```yaml
RelationshipGroups:
  - code: FAMILY
    name: "Family Relationships"
    description: "Blood relations and marriage"
    
  - code: FINANCIAL_DEPENDENT
    name: "Financial Dependents"
    description: "Tax and benefits dependents"
    
  - code: EMERGENCY
    name: "Emergency Contacts"
    description: "Emergency contact persons"
    
  - code: PROFESSIONAL
    name: "Professional Network"
    description: "Mentors, references"
```

---

### RelationshipType

**Definition**: Specific types of personal relationships between workers.

**Purpose**:
- Define family relationships
- Track dependents for tax/benefits
- Emergency contacts
- Inverse relationship management

**Key Attributes**:
- `code` - Relationship code
- `name` - Display name
- `group_id` - Links to RelationshipGroup
- `inverse_type_id` - Inverse relationship (FATHER ↔ SON)
- `affects_tax` - Impacts tax calculation
- `is_active` - Active flag

**Relationship Types**:
```yaml
RelationshipTypes:
  - code: FATHER
    name: "Father"
    group: FAMILY
    inverse: SON/DAUGHTER
    affects_tax: false
    
  - code: SPOUSE
    name: "Spouse"
    group: FAMILY
    inverse: SPOUSE
    affects_tax: true
    
  - code: CHILD
    name: "Child"
    group: FAMILY
    inverse: FATHER/MOTHER
    affects_tax: true
    
  - code: DEPENDENT
    name: "Dependent"
    group: FINANCIAL_DEPENDENT
    affects_tax: true
```

**Business Rules**:
- ✅ Inverse relationships auto-created
- ✅ Tax-affecting relationships used in payroll
- ✅ Emergency contacts must have valid phone

---

### TalentMarket

**Definition**: Multi-market organizational structure for global operations.

**Purpose**:
- Support multi-country/region operations
- Market-specific configurations
- Hierarchical market structure
- Localization per market

**Key Attributes**:
- `code` - Market code
- `name` - Market name
- `parent_id` - Parent market (hierarchy)
- `country_code` - Primary country
- `currency_code` - Default currency
- `timezone_code` - Default timezone
- `metadata` - Market-specific configs (seniority rules, probation periods)

**Market Hierarchy**:
```yaml
TalentMarkets:
  - code: GLOBAL
    name: "Global Market"
    parent: null
    
  - code: APAC
    name: "Asia Pacific"
    parent: GLOBAL
    
  - code: VN
    name: "Vietnam Market"
    parent: APAC
    country: VN
    currency: VND
    timezone: "Asia/Ho_Chi_Minh"
    metadata:
      probation_months: 2
      notice_period_days: 30
      
  - code: SG
    name: "Singapore Market"
    parent: APAC
    country: SG
    currency: SGD
    timezone: "Asia/Singapore"
```

**Use Cases**:
- Market-specific job postings
- Regional talent pools
- Localized HR policies
- Cross-market mobility

---

### SkillMaster

**Definition**: Catalog of technical and functional skills.

**Purpose**:
- Standardize skill taxonomy
- Support skill-based matching
- Define proficiency scales
- Career development planning

**Key Attributes**:
- `code` - Skill code
- `name` - Skill name
- `category_code` - Skill category (TECHNICAL, FUNCTIONAL, LANGUAGE)
- `proficiency_scale_id` - Links to proficiency scale
- `is_active` - Active flag
- `metadata` - Related certifications, learning resources

**Skill Categories & Examples**:
```yaml
SkillMaster:
  # Technical Skills
  - code: PYTHON
    name: "Python Programming"
    category: TECHNICAL
    proficiency_scale: TECH_5_LEVEL
    metadata:
      certifications: ["PCEP", "PCAP"]
      
  - code: AWS
    name: "Amazon Web Services"
    category: TECHNICAL
    proficiency_scale: TECH_5_LEVEL
    
  # Functional Skills
  - code: PROJECT_MGMT
    name: "Project Management"
    category: FUNCTIONAL
    proficiency_scale: FUNC_5_LEVEL
    metadata:
      certifications: ["PMP", "PRINCE2"]
      
  # Language Skills
  - code: ENGLISH
    name: "English Language"
    category: LANGUAGE
    proficiency_scale: CEFR
    metadata:
      scale_levels: ["A1", "A2", "B1", "B2", "C1", "C2"]
```

**Proficiency Scales**:
- TECH_5_LEVEL: 1-5 (Beginner to Expert)
- FUNC_5_LEVEL: 1-5 (Basic to Advanced)
- CEFR: A1-C2 (Language proficiency)

**Business Rules**:
- ✅ Skills linked to job profiles
- ✅ Workers assessed against proficiency scales
- ✅ Gap analysis for development planning

---

### CompetencyMaster

**Definition**: Catalog of behavioral competencies (soft skills).

**Purpose**:
- Define leadership/behavioral competencies
- Performance assessment framework
- Succession planning
- 360-degree feedback

**Key Attributes**:
- `code` - Competency code
- `name` - Competency name
- `category_code` - Category (LEADERSHIP, INTERPERSONAL, COGNITIVE)
- `rating_scale_id` - Assessment scale
- `description` - Detailed description
- `behavioral_indicators` - Observable behaviors

**Competency Examples**:
```yaml
CompetencyMaster:
  - code: LEADERSHIP
    name: "Leadership"
    category: LEADERSHIP
    rating_scale: "1-5"
    description: "Ability to inspire and guide individuals or teams"
    behavioral_indicators:
      - "Sets clear vision and direction"
      - "Empowers team members"
      - "Makes decisive decisions"
      
  - code: COMMUNICATION
    name: "Communication"
    category: INTERPERSONAL
    rating_scale: "1-5"
    behavioral_indicators:
      - "Articulates ideas clearly"
      - "Active listening"
      - "Adapts communication style"
      
  - code: PROBLEM_SOLVING
    name: "Problem Solving"
    category: COGNITIVE
    rating_scale: "1-5"
    behavioral_indicators:
      - "Analyzes complex situations"
      - "Generates creative solutions"
      - "Makes data-driven decisions"
```

**Common Competencies**:
- Leadership
- Communication
- Teamwork & Collaboration
- Problem Solving
- Innovation & Creativity
- Customer Focus
- Adaptability
- Strategic Thinking

**Use Cases**:
- Performance reviews
- Leadership development
- Succession planning
- Hiring assessments

---

## 💡 Best Practices

### Code Management
- ✅ Use meaningful, self-documenting codes
- ✅ Keep codes stable (don't change existing codes)
- ✅ Deactivate instead of delete
- ✅ Document code meanings in metadata

### Localization
- ✅ Always provide both English and local language
- ✅ Use Unicode for non-ASCII characters
- ✅ Test display in all supported languages

### Hierarchy Management
- ✅ Use materialized paths for query performance
- ✅ Limit hierarchy depth (typically 3-4 levels)
- ✅ Validate parent-child relationships

---

## 🔗 Related Glossaries

- **Person** - Uses ContactType, RelationshipType, SkillMaster, CompetencyMaster
- **Employment** - References Currency, TimeZone, CodeList
- **JobPosition** - Uses Industry, SkillMaster
- **LegalEntity** - Uses Industry, Currency

---

**Document Version**: 2.0  
**Last Review**: 2025-12-01
