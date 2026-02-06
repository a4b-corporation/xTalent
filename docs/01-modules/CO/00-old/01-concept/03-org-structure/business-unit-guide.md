# Business Unit Guide

**Module**: CO (Core)  
**Sub-Module**: Organization Structure  
**Classification**: AGGREGATE_ROOT

---

## Overview

A **Business Unit** represents an operational organizational unit (division, department, team) used for hierarchy, reporting, and management structure. Unlike legal entities, business units are dynamic and change frequently with organizational restructuring.

---

## Key Concepts

### Business Unit vs Legal Entity

| Aspect | Business Unit | Legal Entity |
|--------|--------------|--------------|
| **Purpose** | Operational unit | Legal/compliance entity |
| **Quantity** | Many (100s-1000s) | Few (stable) |
| **Changes** | Frequent (reorganization) | Rare (M&A, restructuring) |
| **Hierarchy Depth** | Deep (5-10 levels) | Shallow (2-4 levels) |
| **Examples** | Engineering Dept, Sales Team | VNG Corporation, VNG Branch |

### Hierarchy Structure

```
Engineering Division (Root)
├── Backend Development Department
│   ├── Core Services Team
│   └── API Team
├── Frontend Development Department
│   ├── Web Team
│   └── Mobile Team
└── DevOps Department
```

**Key Features**:
- `parent_id`: References parent business unit
- `path`: Materialized path (e.g., `/eng_div/backend_dept/`)
- **Closure Table**: `org_bu.unit_hierarchy` for efficient queries (CRITICAL for performance)

### Closure Table - Performance Critical

Due to high volume and frequent queries, closure table is **essential**:

**Query Patterns**:
```sql
-- All ancestors (for permissions)
SELECT * FROM unit_hierarchy 
WHERE descendant_id = ? ORDER BY depth DESC;

-- All descendants (for reporting)
SELECT * FROM unit_hierarchy 
WHERE ancestor_id = ? AND depth > 0;

-- Direct reports only
SELECT * FROM unit_hierarchy 
WHERE ancestor_id = ? AND depth = 1;
```

**Performance**: O(1) for all hierarchy queries

---

## Lifecycle

States: DRAFT → ACTIVE → INACTIVE → DISSOLVED

### Key Transitions

**Activate**: Requires name and type
**Deactivate**: Requires reason
**Dissolve**: Requires no active employees or children

---

## Data Structure

### Core Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `code` | String | Unique business code |
| `name` | String | Business unit name |
| `type_id` | UUID | Unit type (DIVISION, DEPARTMENT, TEAM) |
| `parent_id` | UUID | Parent unit |
| `manager_employee_id` | UUID | Manager (must be active Employee) |
| `legal_entity_code` | String | Legal entity link (flexible) |
| `status_code` | String | DRAFT/ACTIVE/INACTIVE/DISSOLVED |

### Manager Validation

**Important**: Manager must be an **active Employee** (not Worker)
- Validates organizational authority
- Ensures proper employment relationship

### Legal Entity Link

Uses `legal_entity_code` (not ID) for flexibility:
- Survives legal entity restructuring
- Easier to manage in configurations
- More resilient to changes

---

## Common Operations

### Create Business Unit

```yaml
POST /api/v1/business-units
{
  "code": "BACKEND_DEPT",
  "name": "Backend Development Department",
  "type_id": "type-department-001",
  "parent_id": "eng-div-id",
  "legal_entity_code": "VNG_HQ",
  "manager_employee_id": "emp-manager-001"
}
```

### Reorganization (Move Unit)

```yaml
PUT /api/v1/business-units/{id}
{
  "updates": {
    "parent_id": "new-parent-id"
  },
  "effective_date": "2025-07-01",
  "reason": "Organizational restructuring"
}
```

**Note**: Moving a unit triggers closure table rebuild for entire subtree.

---

## Business Rules

**BR-ORG-010**: Code must be unique per parent
**BR-ORG-011**: Manager must be active Employee
**BR-ORG-012**: Max hierarchy depth: 15 levels
**BR-ORG-013**: Cannot delete unit with active children or employees

---

## Security & Permissions

### Row-Level Security

Users can access:
- Their own business unit
- All descendant units (via closure table)
- Units they manage

### Hierarchy-Based Permissions

```sql
-- Check if user can access unit
SELECT EXISTS(
  SELECT 1 FROM unit_hierarchy
  WHERE ancestor_id = user.business_unit_id
  AND descendant_id = target_unit_id
);
```

---

## Performance Optimization

### Closure Table Maintenance

**On Create**: Incremental insert (fast)
**On Move**: Rebuild subtree (O(N) where N = subtree size)
**On Delete**: Soft delete (no rebuild needed)

### Caching Strategy

- Cache closure table in Redis
- Invalidate on hierarchy changes
- TTL: 1 hour (or event-driven)

### Batch Operations

For bulk reorganizations:
```sql
-- Disable triggers
ALTER TABLE business_unit DISABLE TRIGGER ALL;

-- Make changes
UPDATE business_unit SET parent_id = ...;

-- Rebuild all hierarchies
CALL rebuild_all_bu_hierarchies();

-- Re-enable triggers
ALTER TABLE business_unit ENABLE TRIGGER ALL;
```

---

## Integration Points

- **Employees**: Assigned to business units
- **Positions**: Belong to business units
- **Budgets**: Allocated to business units
- **Reporting**: Hierarchy-based aggregation

---

## Best Practices

1. **Keep codes meaningful**: Use hierarchical codes (ENG_DIV, ENG_BACKEND_DEPT)
2. **Assign managers**: Every active unit should have a manager
3. **Use tags**: For flexible categorization (region, cost center)
4. **Plan reorganizations**: Batch changes, communicate early
5. **Monitor closure table**: Periodic validation and optimization

---

## Industry References

- **Workday**: Supervisory Organizations
- **SAP SuccessFactors**: Organization Management
- **Oracle HCM Cloud**: Organization Structures

---

## Related Documentation

- [Entity Definition](../../00-ontology/domain/03-org-structure/business-unit.aggregate.yaml)
- [Business Rules](../../02-spec/04-BR/BR-03-org-structure.md)
- [BDD Scenarios](../../02-spec/05-BDD/03-org-structure/business-unit.feature)
