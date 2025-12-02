# BusinessUnit Sub-Module - Glossary

**Version**: 2.0  
**Last Updated**: 2025-12-01  
**Sub-Module**: Operational Organization Units

---

## 📋 Overview

Business Units represent the operational structure of the organization (divisions, departments, teams). This is distinct from the legal entity structure and supports flexible organizational modeling.

**New in v2.0**: Supervisory Organization concept separates reporting/approval hierarchy from operational structure.

### Entities (3)
1. **UnitType** 🔄 (Enhanced with Supervisory support)
2. **Unit** - Business unit instances
3. **UnitTag** - Flexible unit classification

---

## 🔑 Key Entities

### UnitType 🔄 ENHANCED

**Definition**: Types of business units that define the organizational structure.

**Purpose**:
- Classify business units by function and purpose
- Define hierarchy rules and constraints
- Support both operational and supervisory structures
- Enable organization-specific configurations

**Key Attributes**:
- `code` - Unit type code
- `name` - Display name
- `level_order` - Hierarchy level (1=highest, e.g., Division)
- `is_supervisory` ✨ - Flag for supervisory organization (NEW in v2.0)
- `metadata` - Type-specific configurations
- SCD Type 2 fields

**Unit Types** (Enhanced in v2.0):

| Code | Name | Level | Supervisory | Purpose |
|------|------|-------|-------------|---------|
| DIVISION | Division | 1 | No | Top-level business division |
| DEPARTMENT | Department | 2 | No | Department within division |
| TEAM | Team | 3 | No | Work team |
| ✨ SUPERVISORY | Supervisory Org | Varies | Yes | Reporting/approval hierarchy |
| ✨ COST_CENTER | Cost Center | Varies | No | Cost accounting unit |
| ✨ MATRIX | Matrix Org | Varies | No | Matrix organization unit |
| PROJECT | Project Team | 3 | No | Temporary project organization |

**Supervisory vs Operational** ✨ NEW CONCEPT:

```yaml
# Operational Structure (how work is organized)
UnitTypes:
  - code: DIVISION
    level_order: 1
    is_supervisory: false
    
  - code: DEPARTMENT
    level_order: 2
    is_supervisory: false
    
  - code: TEAM
    level_order: 3
    is_supervisory: false

# Supervisory Structure (reporting/approval hierarchy)
  - code: SUPERVISORY
    level_order: null  # Can exist at any level
    is_supervisory: true
    metadata:
      purpose: "Reporting and approval hierarchy"
      affects_security: true
      affects_approvals: true
```

**Why Supervisory Organizations?**

In many enterprises, the **operational structure** (how work is organized) differs from the **reporting structure** (who reports to whom):

```
Operational Structure:
  Sales Division
    ├─ Enterprise Sales Dept
    ├─ SMB Sales Dept
    └─ Channel Sales Dept

Supervisory Structure (for reporting/approvals):
  VP Sales (Supervisory Org)
    ├─ Regional Sales Director APAC
    │   ├─ Country Manager Vietnam
    │   └─ Country Manager Singapore
    └─ Regional Sales Director EMEA
```

**Business Rules**:
- ✅ SUPERVISORY type units define reporting hierarchy and approval chains
- ✅ Supervisory organizations can differ from operational (DIVISION/DEPARTMENT) structure
- ✅ Security permissions often tied to supervisory organization membership
- ✅ One employee can be in operational unit AND supervisory organization
- ✅ Approval workflows follow supervisory hierarchy, not operational

**Metadata Examples**:
```yaml
UnitType: SUPERVISORY
metadata:
  allowed_child_types: ["SUPERVISORY"]
  requires_manager: true
  approval_authority_levels:
    - EXPENSE_APPROVAL: 10000
    - LEAVE_APPROVAL: true
    - HIRE_APPROVAL: true
  security_implications:
    - "Members inherit data access from supervisory org"
    - "Managers can view subordinate data"
```

---

### Unit

**Definition**: Business unit instance representing a specific organizational unit.

**Purpose**:
- Represent operational organizational structure
- Support hierarchical organization charts
- Link employees to organizational units
- Enable reporting and analytics by organization

**Key Attributes**:
- `id` - Unique unit identifier
- `code` - Unit code (e.g., BU-SALES-HCMC)
- `name` - Unit name
- `type_id` - Links to UnitType
- `parent_id` - Parent unit (for hierarchy)
- `legal_entity_code` - Associated legal entity
- `manager_worker_id` - Unit manager
- `path` - Materialized path (e.g., /division/department/team)
- `level` - Hierarchy level (computed from path)
- `cost_center_code` - Associated cost center
- `location_id` - Primary location
- `metadata` - Unit-specific data
- SCD Type 2 fields

**Hierarchy Example**:
```yaml
# Operational Hierarchy
Units:
  - code: VNG-CORP
    name: "VNG Corporation"
    type: DIVISION
    parent: null
    path: "/VNG-CORP"
    level: 1
    
  - code: VNG-ENG
    name: "Engineering Division"
    type: DIVISION
    parent: VNG-CORP
    path: "/VNG-CORP/VNG-ENG"
    level: 2
    manager: WORKER-001
    
  - code: VNG-ENG-BACKEND
    name: "Backend Engineering Dept"
    type: DEPARTMENT
    parent: VNG-ENG
    path: "/VNG-CORP/VNG-ENG/VNG-ENG-BACKEND"
    level: 3
    manager: WORKER-010
    
  - code: VNG-ENG-BACKEND-API
    name: "API Team"
    type: TEAM
    parent: VNG-ENG-BACKEND
    path: "/VNG-CORP/VNG-ENG/VNG-ENG-BACKEND/VNG-ENG-BACKEND-API"
    level: 4
    manager: WORKER-050

# Supervisory Hierarchy (parallel structure)
  - code: SUP-ENG-VP
    name: "Engineering VP Supervisory Org"
    type: SUPERVISORY
    parent: null
    is_supervisory: true
    manager: WORKER-001
    metadata:
      approval_levels:
        expense: 50000
        hire: true
        
  - code: SUP-ENG-DIR-BACKEND
    name: "Backend Engineering Director"
    type: SUPERVISORY
    parent: SUP-ENG-VP
    is_supervisory: true
    manager: WORKER-010
```

**Business Rules**:
- ✅ Must link to legal entity (every unit belongs to a legal entity)
- ✅ Path must reflect actual hierarchy
- ✅ Parent unit must be of higher or equal level_order
- ✅ Manager must have active assignment in same or parent unit
- ✅ Cannot delete unit with active assignments
- ✅ SCD Type 2 tracks organizational changes over time

**Metadata Examples**:
```yaml
Unit: Engineering Division
metadata:
  budget_annual: 10000000
  headcount_target: 150
  headcount_actual: 142
  strategic_focus:
    - "Cloud Infrastructure"
    - "AI/ML Platform"
  kpis:
    - name: "Deployment Frequency"
      target: "10/day"
    - name: "MTTR"
      target: "< 1 hour"
```

---

### UnitTag

**Definition**: Flexible tagging system for business units to support cross-cutting classifications.

**Purpose**:
- Add flexible classifications beyond hierarchy
- Support matrix organization views
- Enable dynamic grouping and filtering
- Tag-based reporting and analytics

**Key Attributes**:
- `unit_id` - Tagged unit
- `tag_type_code` - Tag category (from CodeList)
- `tag_value` - Tag value
- `is_primary` - Primary tag of this type
- SCD Type 2

**Common Tag Types**:

| Tag Type | Values | Purpose |
|----------|--------|---------|
| REGION | APAC, EMEA, AMERICAS | Geographic region |
| COST_CENTER | CC-1000, CC-2000 | Cost accounting |
| STRATEGIC_INITIATIVE | DIGITAL_TRANSFORM, CLOUD_FIRST | Strategic programs |
| CUSTOMER_SEGMENT | ENTERPRISE, SMB, CONSUMER | Customer focus |
| PRODUCT_LINE | PRODUCT_A, PRODUCT_B | Product affiliation |
| INNOVATION_LAB | YES, NO | Innovation designation |
| REMOTE_FIRST | YES, NO | Remote work policy |

**Use Cases**:

#### 1. Regional Grouping
```yaml
# Tag units by region (cross-cutting hierarchy)
UnitTags:
  - unit: VNG-ENG-BACKEND
    tag_type: REGION
    tag_value: APAC
    
  - unit: VNG-SALES-VIETNAM
    tag_type: REGION
    tag_value: APAC
    
  - unit: VNG-SALES-SINGAPORE
    tag_type: REGION
    tag_value: APAC

# Query: All APAC units across divisions
```

#### 2. Cost Center Mapping
```yaml
# Multiple units can share same cost center
UnitTags:
  - unit: VNG-ENG-BACKEND
    tag_type: COST_CENTER
    tag_value: CC-ENG-1000
    
  - unit: VNG-ENG-FRONTEND
    tag_type: COST_CENTER
    tag_value: CC-ENG-1000
    
  - unit: VNG-ENG-MOBILE
    tag_type: COST_CENTER
    tag_value: CC-ENG-2000
```

#### 3. Strategic Initiative Tracking
```yaml
# Tag units participating in strategic initiatives
UnitTags:
  - unit: VNG-ENG-BACKEND
    tag_type: STRATEGIC_INITIATIVE
    tag_value: CLOUD_MIGRATION
    
  - unit: VNG-ENG-DEVOPS
    tag_type: STRATEGIC_INITIATIVE
    tag_value: CLOUD_MIGRATION
    
  - unit: VNG-SALES-ENTERPRISE
    tag_type: STRATEGIC_INITIATIVE
    tag_value: DIGITAL_TRANSFORM
```

**Business Rules**:
- ✅ Multiple tags per unit allowed
- ✅ One primary tag per tag type
- ✅ Tags don't affect hierarchy
- ✅ Tag values from CodeList for consistency

---

## 💡 Supervisory Organization Deep Dive ✨ NEW

### What Problem Does It Solve?

**Problem**: In real organizations, **how work is organized** (operational structure) often differs from **who reports to whom** (reporting structure).

**Example Scenario**:
```
Company: Global Tech Corp

Operational Structure (how teams are organized):
  Engineering
    ├─ Backend Team (Vietnam)
    ├─ Frontend Team (Vietnam)
    ├─ Mobile Team (Singapore)
    └─ DevOps Team (Singapore)

Reporting Structure (who approves what):
  CTO
    ├─ VP Engineering APAC
    │   ├─ Engineering Manager Vietnam (manages Backend + Frontend)
    │   └─ Engineering Manager Singapore (manages Mobile + DevOps)
    └─ VP Engineering EMEA
        └─ ...
```

### How Supervisory Orgs Work

**1. Dual Membership**:
```yaml
Employee: John (Backend Engineer)
  Operational Assignment:
    business_unit: Backend Team
    
  Supervisory Assignment:
    supervisory_org: Engineering Manager Vietnam
    manager: WORKER-MGR-VN
```

**2. Approval Flows**:
```yaml
# Leave Request by John
Approval Chain:
  1. Direct Manager (from Supervisory Org): Engineering Manager Vietnam
  2. Skip Level (from Supervisory Org): VP Engineering APAC
  3. Final (from Supervisory Org): CTO

# NOT based on operational structure!
```

**3. Security & Data Access**:
```yaml
Engineering Manager Vietnam (Supervisory Org):
  Can access data for:
    - All members of "Engineering Manager Vietnam" supervisory org
    - Includes: Backend Team + Frontend Team members
    
  Cannot access:
    - Mobile Team (different supervisory org)
    - DevOps Team (different supervisory org)
```

### Implementation Patterns

**Pattern 1: Parallel Structures**
```yaml
# Maintain both structures separately
Operational Units:
  - Backend Team
  - Frontend Team
  
Supervisory Organizations:
  - Engineering Manager Vietnam (contains both teams)
```

**Pattern 2: Hybrid Approach**
```yaml
# Some units are both operational AND supervisory
Unit: Engineering Division
  is_operational: true
  is_supervisory: true
  manager: VP Engineering
```

**Pattern 3: Matrix Organization**
```yaml
Employee: Jane
  Operational Unit: Product Team A
  Supervisory Org (Functional): Engineering Manager
  Supervisory Org (Project): Project Lead Alpha
  
  # Dual reporting: functional + project
```

---

## 🔄 Common Scenarios

### Scenario 1: Simple Hierarchy
```yaml
# Traditional single hierarchy
Company
  ├─ Sales Division
  │   ├─ Enterprise Sales
  │   └─ SMB Sales
  └─ Engineering Division
      ├─ Backend
      └─ Frontend

# Operational = Supervisory (same structure)
```

### Scenario 2: Geographic Matrix
```yaml
# Operational by function, Supervisory by geography
Operational:
  Engineering
    ├─ Backend
    ├─ Frontend
    └─ Mobile

Supervisory:
  APAC Engineering
    ├─ Vietnam Engineering Manager
    └─ Singapore Engineering Manager
```

### Scenario 3: Reorganization
```yaml
# Before (2024-01-01 to 2024-06-30)
Unit: Backend Team
  parent: Engineering Division
  manager: WORKER-001
  effective_start: 2024-01-01
  effective_end: 2024-06-30
  is_current: false

# After (2024-07-01 onwards)
Unit: Backend Team
  parent: Platform Division  # Changed!
  manager: WORKER-002        # New manager!
  effective_start: 2024-07-01
  effective_end: null
  is_current: true

# SCD Type 2 preserves history
```

---

## ⚠️ Important Notes

### Supervisory Organization Best Practices
- ✅ Use supervisory orgs for approval workflows
- ✅ Use supervisory orgs for security/data access
- ✅ Keep operational structure simple and stable
- ✅ Allow supervisory structure to be more dynamic
- ⚠️ Don't mix operational and supervisory in same hierarchy

### Unit Hierarchy Guidelines
- ✅ Keep hierarchy depth reasonable (3-5 levels max)
- ✅ Use materialized path for query performance
- ✅ Update paths when hierarchy changes
- ✅ Use tags for cross-cutting concerns
- ⚠️ Avoid circular references

### Organizational Change Management
- ✅ Plan reorganizations carefully
- ✅ Use SCD Type 2 to preserve history
- ✅ Communicate changes to affected employees
- ✅ Update reporting relationships in assignments
- ⚠️ Consider impact on in-flight approvals

---

## 🔗 Related Glossaries

- **LegalEntity** - Parent legal structure
- **Employment** - Assignments to units
- **OrganizationRelation** - Dynamic relationships between units
- **Person** - Workers assigned to units

---

## 📚 References

- Workday: Supervisory Organization concept
- SAP SuccessFactors: Organizational Management
- Oracle HCM: Organization Structures

---

**Document Version**: 2.0  
**Last Review**: 2025-12-01
