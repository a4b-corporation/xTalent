# Employee Guide

**Module**: CO (Core)  
**Sub-Module**: Employment  
**Classification**: AGGREGATE_ROOT

---

## Overview

**Employee** represents the employment relationship between a Worker (person) and a Legal Entity (company). It is the core entity for all HR operations.

---

## Key Concepts

### Employee vs Worker

| Aspect | Worker | Employee |
|--------|--------|----------|
| **Represents** | Person data | Employment relationship |
| **Contains** | Demographics, contacts, skills | Hire date, status, classification |
| **Cardinality** | 1 Worker → N Employees | N Employees → 1 Worker |
| **Example** | John Doe (person) | John Doe employed by VNG |

**Pattern**: SAP SuccessFactors Person → Employment

### 3-Layer Classification

1. **Worker Category** (high-level):
   - EMPLOYEE, CONTRACTOR, INTERN, CONSULTANT

2. **Employee Class** (detailed):
   - FULL_TIME, PART_TIME, TEMPORARY, SEASONAL

3. **Employee Type** (deprecated):
   - Legacy field, use category + class instead

---

## Lifecycle

```
PENDING → ACTIVE → SUSPENDED/ON_LEAVE → TERMINATED
```

**States**:
- **PENDING**: Offer accepted, not yet started
- **ACTIVE**: Currently working
- **SUSPENDED**: Temporarily suspended
- **ON_LEAVE**: Extended leave
- **TERMINATED**: Employment ended

---

## Common Operations

### Create Employee

```yaml
POST /api/v1/employees
{
  "worker_id": "worker-001",
  "legal_entity_code": "VNG_HQ",
  "employee_code": "EMP001234",
  "worker_category_code": "EMPLOYEE",
  "employee_class_code": "FULL_TIME",
  "hire_date": "2025-01-15"
}
```

### Terminate Employee

```yaml
POST /api/v1/employees/{id}/terminate
{
  "termination_date": "2025-12-31",
  "termination_reason": "RESIGNATION"
}
```

---

## Business Rules

**BR-EMP-001**: Employee code must be unique within legal entity  
**BR-EMP-002**: Hire date cannot be more than 1 year in future  
**BR-EMP-003**: Terminated employees must have termination date  
**BR-EMP-004**: Active employees cannot have termination date

---

## Integration Points

- **Contracts**: 1 Employee → N Contracts
- **Assignments**: 1 Employee → N Position Assignments
- **Payroll**: Employee is basis for payroll processing
- **Benefits**: Employee determines benefit eligibility

---

## Related Documentation

- [Entity Definition](../../00-ontology/domain/02-employment/employee.aggregate.yaml)
- [Worker Guide](../01-person/worker-guide.md)
