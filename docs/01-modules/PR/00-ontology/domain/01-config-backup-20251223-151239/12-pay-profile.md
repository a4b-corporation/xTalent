# PayProfile

**Module**: Payroll (PR)
**Submodule**: CONFIG
**Version**: 2.0
**Last Updated**: 2025-12-23

---

## Entity: PayProfile {#pay-profile}

**Classification**: CORE_ENTITY  

**Definition**: Defines payroll policy profiles that bundle elements, rules, and configurations for specific employee groups

**Purpose**: Enables flexible payroll policy management by grouping related configurations into reusable profiles

**Key Characteristics**:
- Can be scoped to legal entity or market
- SCD Type 2 for historical tracking
- Contains metadata for profile configuration
- Can be assigned to pay groups or individual employees

---

### Attributes

| Attribute | Type | Required | Constraints | Description |
|-----------|------|----------|-------------|-------------|
| `id` | UUID | ✅ | PK | Primary identifier |
| `code` | varchar(50) | ✅ | UNIQUE, NOT NULL | Unique profile code |
| `name` | varchar(100) | ✅ | NOT NULL | Profile display name |
| `legal_entity_id` | UUID | ❌ | FK → Core.LegalEntity | Owning legal entity |
| `market_id` | UUID | ❌ | FK → Core.TalentMarket | Applicable market |
| `description` | text | ❌ | NULL | Profile description |
| `status_code` | varchar(20) | ✅ | Default: 'ACTIVE' | Profile status |
| `metadata` | jsonb | ❌ | NULL | Profile configuration |
| `effective_start_date` | date | ✅ | NOT NULL | Profile effective start |
| `effective_end_date` | date | ❌ | NULL | Profile expiration |
| `is_current_flag` | boolean | ✅ | Default: true | Current version flag |
| `created_at` | timestamp | ✅ | Auto-generated | Creation timestamp |
| `updated_at` | timestamp | ❌ | Auto-updated | Last modification timestamp |

---

### Examples

#### Example 1: Standard Office Worker Profile

```yaml
PayProfile:
  code: "PROFILE_OFFICE_VN"
  name: "Vietnam Office Worker Profile"
  legal_entity_id: "vng-corp-uuid"
  market_id: "vietnam-market-uuid"
  description: "Standard payroll profile for Vietnam office workers"
  status_code: "ACTIVE"
  metadata:
    included_elements:
      - "BASIC_SAL"
      - "OT_1_5"
      - "ALLOWANCE_MEAL"
    included_rules:
      - "VN_PIT_2025"
      - "VN_SI_2025"
  effective_start_date: "2025-01-01"
  is_current_flag: true
```

---

### Best Practices

✅ **DO**:
- Group related policies into profiles
- Use descriptive profile names
- Document profile purpose

❌ **DON'T**:
- Don't create too many overlapping profiles
- Don't change profiles mid-period
- Don't delete profiles (inactivate instead)

---

### Related Entities

**Parent/Upstream**:
- Core.LegalEntity - Owning entity
- Core.TalentMarket - Applicable market

**Children/Downstream**:
- [PayProfileMap](#pay-profile-map) - Profile assignments

---

### Related Workflows

- [WF-PR-CONFIG-002](../workflows/config-workflows.md#wf-pr-config-002) - Pay Group Configuration

---

## Entity: PayProfileMap {#pay-profile-map}

**Classification**: CORE_ENTITY  

**Definition**: Maps payroll profiles to pay groups or individual employees for policy application

**Purpose**: Provides flexible assignment of payroll profiles to organizational units or employees

**Key Characteristics**:
- Can map to pay group OR employee (not both)
- SCD Type 2 for historical tracking
- Supports period-based assignments
- Enables dynamic policy application

---

### Attributes

| Attribute | Type | Required | Constraints | Description |
|-----------|------|----------|-------------|-------------|
| `id` | UUID | ✅ | PK | Primary identifier |
| `pay_profile_id` | UUID | ✅ | FK → [PayProfile](#pay-profile) | Assigned profile |
| `pay_group_id` | UUID | ❌ | FK → [PayGroup](#pay-group) | Target pay group |
| `employee_id` | UUID | ❌ | FK → Core.Employee | Target employee |
| `period_start` | date | ✅ | NOT NULL | Assignment start date |
| `period_end` | date | ❌ | NULL | Assignment end date |
| `effective_start_date` | date | ✅ | NOT NULL | Mapping effective start |
| `effective_end_date` | date | ❌ | NULL | Mapping expiration |
| `is_current_flag` | boolean | ✅ | Default: true | Current version flag |
| `metadata` | jsonb | ❌ | NULL | Additional flexible data |
| `created_at` | timestamp | ✅ | Auto-generated | Creation timestamp |
| `updated_at` | timestamp | ❌ | Auto-updated | Last modification timestamp |

---

### Business Rules

| Rule ID | Rule Name | Description | Validation Trigger |
|---------|-----------|-------------|----------------------|
| BR-PR-PROFMAP-001 | Group OR Employee | Must specify either pay_group_id OR employee_id, not both | On Create/Update |
| BR-PR-PROFMAP-002 | No Overlapping Assignments | Cannot have overlapping period assignments for same target | On Create/Update |

---

### Examples

#### Example 1: Profile Assignment to Pay Group

```yaml
PayProfileMap:
  pay_profile_id: "profile-office-vn-uuid"
  pay_group_id: "vn-office-monthly-uuid"
  employee_id: null
  period_start: "2025-01-01"
  period_end: null
  effective_start_date: "2025-01-01"
  is_current_flag: true
```

#### Example 2: Profile Assignment to Individual Employee

```yaml
PayProfileMap:
  pay_profile_id: "profile-executive-vn-uuid"
  pay_group_id: null
  employee_id: "employee-ceo-uuid"
  period_start: "2025-01-01"
  period_end: null
  effective_start_date: "2025-01-01"
  is_current_flag: true
```

---

### Best Practices

✅ **DO**:
- Assign profiles at pay group level when possible
- Use employee-level assignments for exceptions
- Document assignment rationale in metadata

❌ **DON'T**:
- Don't create overlapping assignments
- Don't assign both group and employee
- Don't change assignments mid-period

---

### Related Entities

**Parent/Upstream**:
- [PayProfile](#pay-profile) - Assigned profile
- [PayGroup](#pay-group) - Target pay group
- Core.Employee - Target employee

---

### Related Workflows

- [WF-PR-CONFIG-002](../workflows/config-workflows.md#wf-pr-config-002) - Pay Group Configuration

---

## References

- **Workflow Catalog**: [../workflows/config-workflows.md](../workflows/config-workflows.md)
- **Glossary**: [../glossary-config.md](../glossary-config.md) (quick reference)
- **Concept Guides**: [../../01-concept/02-config/](../../01-concept/02-config/)
- **Database Schema**: [../../03-design/5.Payroll.V3.dbml](../../03-design/5.Payroll.V3.dbml)
- **API Specification**: [../../02-spec/02-api-specification.md](../../02-spec/02-api-specification.md)

---

**Document Version**: 1.0 (Complete)  
**Last Review**: 2025-12-23  
**Reviewed By**: xTalent Documentation Team

**Total CONFIG Entities**: 13
- ✅ PayFrequency
- ✅ PayCalendar
- ✅ PayGroup
- ✅ PayElement
- ✅ BalanceDefinition
- ✅ CostingRule
- ✅ StatutoryRule
- ✅ GLMapping
- ✅ ValidationRule
- ✅ PayslipTemplate
- ✅ PayFormula
- ✅ PayProfile
- ✅ PayProfileMap


---

## References

- **Sub-module Index**: [README.md](./README.md)
- **Glossary**: [../../glossary-config.md](../../glossary-config.md)
- **Database Schema**: [../../../03-design/5.Payroll.V3.dbml](../../../03-design/5.Payroll.V3.dbml)