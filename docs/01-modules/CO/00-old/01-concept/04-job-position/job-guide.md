# Job Guide

**Module**: CO (Core)  
**Sub-Module**: Job-Position  
**Classification**: AGGREGATE_ROOT

---

## Overview

**Job** represents a job catalog entry or template that defines the characteristics and requirements of a type of work. Jobs serve as templates for creating Positions.

---

## Key Concepts

### Job vs Position

| Aspect | Job | Position |
|--------|-----|----------|
| **Nature** | Template/Catalog | Instance |
| **Cardinality** | 1 → N | N → 1 |
| **Example** | "Software Engineer" | "Software Engineer - Backend Team - Req #12345" |
| **Defines** | What the work is | Where/when work is done |

**Pattern**: Workday Job Profile → Position

### Multi-Tree Architecture

Jobs exist in **job trees**:

**Corporate Tree** (CORP_JOB):
- Standard jobs for entire organization
- Single source of truth
- Managed centrally

**BU Trees** (BU_{code}_JOB):
- Business unit-specific customizations
- Can inherit or override corporate jobs
- Managed by BU

### Override/Inherit Pattern

**Inherit** (inherit_flag = true):
```
CORP_JOB: "Software Engineer" (grade: E3)
  ↓ inherits
BU_GAME_JOB: "Software Engineer" (adds gaming skills)
```

**Override** (inherit_flag = false):
```
CORP_JOB: "Software Engineer" (grade: E3)
  ↓ overrides
BU_FINTECH_JOB: "Software Engineer" (grade: E4, different requirements)
```

---

## Grade and Level Integration

**17dec2025 Change**: Grade and level moved from job_profile to job

**Rationale**:
- Grade determines compensation (Job concern, not Profile)
- Direct TR integration: Job → grade_code → PayRange
- No duplication across locales
- Position can access grade directly

---

## Common Operations

### Create Corporate Job

```yaml
POST /api/v1/jobs
{
  "tree_id": "corp-tree-001",
  "job_code": "ENG_SOFTWARE",
  "job_title": "Software Engineer",
  "owner_scope": "CORP",
  "level_code": "L3",
  "grade_code": "E3"
}
```

### Create BU Override

```yaml
POST /api/v1/jobs
{
  "tree_id": "bu-game-tree-001",
  "job_code": "ENG_SOFTWARE",
  "job_title": "Software Engineer",
  "parent_id": "corp-job-id",
  "owner_scope": "BU",
  "owner_unit_id": "bu-game-001",
  "inherit_flag": false,
  "override_title": "Game Software Engineer",
  "grade_code": "E4"
}
```

---

## Business Rules

**BR-JOB-001**: Job code must be unique within tree  
**BR-JOB-002**: Parent job must be in same tree  
**BR-JOB-003**: BU-scoped jobs must have owner_unit_id  
**BR-JOB-004**: Override jobs must have override_title

---

## Integration Points

- **Position**: Job is template for Position creation
- **JobProfile**: Multi-locale descriptions
- **JobTaxonomy**: Job classification
- **Compensation**: Grade determines pay range

---

## Related Documentation

- [Entity Definition](../../00-ontology/domain/04-job-position/job.aggregate.yaml)
- [Position Guide](position-guide.md)
