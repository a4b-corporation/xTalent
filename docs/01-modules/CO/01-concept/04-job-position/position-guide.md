# Position Guide

**Module**: CO (Core)  
**Sub-Module**: Job-Position  
**Classification**: AGGREGATE_ROOT

---

## Overview

**Position** represents a specific job instance in the organizational structure - a "seat" or "slot" that can be filled by an employee.

---

## Key Concepts

### Position vs Job

| Aspect | Job | Position |
|--------|-----|----------|
| **Nature** | Template | Instance |
| **Example** | "Software Engineer" | "Software Engineer - Backend Team - Req #12345" |
| **Quantity** | Few (100s) | Many (1000s) |
| **Purpose** | Define work | Allocate work |

**Relationship**: Position references Job (N:1)

### 17dec2025 Changes

**job_id**: REQUIRED
- Direct access to grade/level
- TR integration: position → job → grade_code → PayRange
- No need for job_profile for compensation

**job_profile_id**: OPTIONAL
- Use only for detailed descriptions
- Locale-specific content
- Not required for core functionality

---

## Headcount Management

### Planned vs Actual

- **planned_headcount**: Budgeted headcount
- **actual_headcount**: Current assignments
- **max_incumbents**: Maximum allowed (typically 1)

### Vacancy Tracking

```
is_vacant = actual_headcount < max_incumbents
vacancy_count = max_incumbents - actual_headcount
```

---

## Lifecycle

```
PLANNED → APPROVED → OPEN → FILLED
                  ↓
                FROZEN → ELIMINATED
```

**States**:
- **PLANNED**: Not yet approved
- **APPROVED**: Approved, not yet open
- **OPEN**: Open for recruitment
- **FILLED**: All slots filled
- **FROZEN**: Hiring frozen
- **ELIMINATED**: Position eliminated

---

## Common Operations

### Create Position

```yaml
POST /api/v1/positions
{
  "code": "POS-ENG-001",
  "title": "Software Engineer - Backend",
  "job_id": "job-software-eng",
  "business_unit_id": "bu-backend",
  "position_type_code": "STANDARD",
  "max_incumbents": 1
}
```

### Fill Position

```yaml
POST /api/v1/positions/{id}/fill
{
  "employee_id": "emp-001",
  "assignment_start_date": "2025-01-15"
}
```

---

## Business Rules

**BR-POS-001**: Position code must be unique  
**BR-POS-002**: job_id is required (17dec2025)  
**BR-POS-003**: actual_headcount ≤ max_incumbents  
**BR-POS-004**: Cannot eliminate position with active assignments

---

## Integration Points

- **Job**: Position uses Job as template
- **Assignment**: Employees assigned to positions
- **Requisition**: Open positions create requisitions
- **Compensation**: Grade accessed via job.grade_code

---

## Related Documentation

- [Entity Definition](../../00-ontology/domain/04-job-position/position.aggregate.yaml)
- [Job Guide](job-guide.md)
