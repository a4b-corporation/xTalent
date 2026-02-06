# Position Override Rules

**Version**: 1.0  
**Last Updated**: 2025-12-17  
**Applies To**: Core Module - Job & Position Management

---

## 📋 Overview

This document defines the rules for how **Position** (instance) can override properties from **Job** (template/class).

### Key Principle

> [!IMPORTANT]
> **Position as Job Instance**
> 
> - **Job** = Template/Class (defines WHAT work + compensation level)
> - **Position** = Instance (WHERE in org structure + local customization)
> - **Compensation attributes (grade, level) CANNOT be overridden**
> - **Organizational attributes (title, reporting) CAN be overridden**

---

## 🎯 The Job-Position Relationship

### Conceptual Model

```
Job (Template/Class)                Position (Instance)
├─ grade_code: "G7"                ├─ Inherits: grade_code = "G7" ✅
├─ level_code: "L3"                ├─ Inherits: level_code = "L3" ✅
├─ job_title: "Software Engineer"  ├─ Can override: title = "SW Engineer - AI" ✅
├─ job_type: "TECH"                ├─ Inherits: job_type = "TECH" ✅
└─ (Global definition)             └─ Located in: BU_HANOI, reports to MGR-001
```

### Database Relationship

```sql
Table jobpos.position {
  id                uuid [pk]
  
  // === CORE REFERENCES ===
  job_id            uuid [ref: > jobpos.job.id]  -- REQUIRED
  job_profile_id    uuid [ref: > jobpos.job_profile.id, null]  -- OPTIONAL
  business_unit_id  uuid [ref: > org_bu.unit.id]
  
  // === POSITION-SPECIFIC (can override) ===
  title             varchar(255)  -- Can differ from job.job_title
  reports_to_id     uuid          -- Position-specific reporting
  full_time_equiv   decimal(4,2)  -- Position-specific FTE
  
  // === INHERITED (cannot override, accessed via job_id) ===
  // grade_code → ALWAYS job.grade_code
  // level_code → ALWAYS job.level_code
  // job_type   → ALWAYS job.job_type_code
}
```

---

## ✅ Override Rules Matrix

| Property | Source | Can Override? | Rationale |
|----------|--------|---------------|-----------|
| **grade_code** | Job | ❌ **NO** | Compensation must be consistent across all positions of same job |
| **level_code** | Job | ❌ **NO** | Seniority level is job-defined, not position-specific |
| **job_type_code** | Job | ❌ **NO** | Job classification is inherent to the job |
| **title** | Position | ✅ **YES** | Can add context (e.g., "Engineer - AI Team") |
| **reports_to_id** | Position | ✅ **YES** | Org structure is position-specific |
| **business_unit_id** | Position | ✅ **YES** | Position is placed in specific BU |
| **full_time_equiv** | Position | ✅ **YES** | FTE can vary by position (0.5, 1.0, etc.) |
| **position_class_code** | Position | ✅ **YES** | Position-specific classification |
| **position_type_code** | Position | ✅ **YES** | Position-specific type (REGULAR, TEMPORARY, etc.) |
| **max_incumbents** | Position | ✅ **YES** | Position-specific slot count |
| **status_code** | Position | ✅ **YES** | Position-specific status (ACTIVE, FROZEN, etc.) |

---

## 📖 Detailed Rules

### ❌ CANNOT Override: Compensation Attributes

#### 1. Grade Code

**Rule**: Position MUST inherit `grade_code` from Job

**Rationale**:
- Grade determines compensation (pay range)
- All positions of same job must have same grade
- Ensures pay equity across organization

**Example**:
```yaml
Job: "Senior Software Engineer"
  grade_code: "G7"
  
Position 1: "Senior SW Engineer - Hanoi"
  job_id: JOB-001
  grade_code: → "G7" (inherited, cannot change)
  
Position 2: "Senior SW Engineer - HCMC"
  job_id: JOB-001
  grade_code: → "G7" (inherited, cannot change)
```

**Access Pattern**:
```sql
-- Get grade for position
SELECT 
    p.code AS position_code,
    j.grade_code  -- From Job, not Position
FROM jobpos.position p
JOIN jobpos.job j ON j.id = p.job_id
WHERE p.id = 'position-uuid';
```

---

#### 2. Level Code

**Rule**: Position MUST inherit `level_code` from Job

**Rationale**:
- Level defines seniority/career progression
- Job-level policies apply based on job.level_code
- Consistent career framework

**Example**:
```yaml
Job: "Software Engineer"
  level_code: "L3"  # Senior level
  
Position: "SW Engineer - Team Lead"
  job_id: JOB-001
  level_code: → "L3" (inherited)
  # Even if position has "Team Lead" in title, level is still L3
```

---

#### 3. Job Type Code

**Rule**: Position MUST inherit `job_type_code` from Job

**Rationale**:
- Job type is fundamental classification (TECH, SALES, ADMIN)
- Used for workforce analytics
- Determines applicable policies

---

### ✅ CAN Override: Organizational Attributes

#### 1. Position Title

**Rule**: Position CAN have different title from Job

**Rationale**:
- Add local context or team name
- More specific than job title
- Better org chart readability

**Examples**:

```yaml
# Example 1: Team-specific
Job: "Software Engineer"
  job_title: "Software Engineer"
  
Position: "Software Engineer - AI Platform Team"
  title: "Software Engineer - AI Platform Team"  # More specific

# Example 2: Location-specific
Job: "Regional Sales Manager"
  job_title: "Regional Sales Manager"
  
Position: "Regional Sales Manager - North Vietnam"
  title: "Regional Sales Manager - North Vietnam"

# Example 3: Project-specific
Job: "Project Manager"
  job_title: "Project Manager"
  
Position: "Project Manager - Digital Transformation"
  title: "Project Manager - Digital Transformation"
```

**Guidelines**:
- Keep job title as prefix
- Add context after dash (-)
- Max 255 characters

---

#### 2. Reporting Line (reports_to_id)

**Rule**: Position MUST define its own reporting line

**Rationale**:
- Org structure is position-specific
- Same job can report to different managers in different BUs

**Example**:
```yaml
Job: "Software Engineer"
  # No reports_to (job is template)
  
Position 1: "SW Engineer - Team A"
  reports_to_id: MGR-001 (Manager of Team A)
  
Position 2: "SW Engineer - Team B"
  reports_to_id: MGR-002 (Manager of Team B)
```

---

#### 3. Full-Time Equivalent (FTE)

**Rule**: Position CAN have different FTE

**Rationale**:
- Part-time vs full-time is position-specific
- Job sharing scenarios

**Example**:
```yaml
Job: "Marketing Specialist"
  # No FTE at job level
  
Position 1: "Marketing Specialist - Full Time"
  full_time_equiv: 1.0
  
Position 2: "Marketing Specialist - Part Time"
  full_time_equiv: 0.5
```

---

#### 4. Position Classification & Type

**Rule**: Position CAN have its own classification and type

**Rationale**:
- Position-specific attributes
- Different from job classification

**Example**:
```yaml
Position:
  position_class_code: "CRITICAL"  # This position is critical
  position_type_code: "TEMPORARY"  # This position is temporary
  
  # But still inherits:
  job.job_type_code: "TECH"  # Job type is still TECH
```

---

## 🔄 Data Access Patterns

### Pattern 1: Get Position with Job Info

```sql
-- Recommended view
CREATE VIEW jobpos.position_with_job_info AS
SELECT 
    -- Position attributes
    p.id,
    p.code AS position_code,
    p.title AS position_title,
    p.business_unit_id,
    p.reports_to_id,
    p.full_time_equiv,
    p.position_class_code,
    p.position_type_code,
    
    -- Inherited from Job (CANNOT override)
    j.id AS job_id,
    j.job_code,
    j.job_title,
    j.grade_code,      -- ✅ Inherited
    j.level_code,      -- ✅ Inherited
    j.job_type_code,   -- ✅ Inherited
    
    -- Optional: JobProfile for description
    jp.locale_code,
    jp.summary AS job_description
    
FROM jobpos.position p
JOIN jobpos.job j ON j.id = p.job_id AND j.is_current_flag = true
LEFT JOIN jobpos.job_profile jp ON jp.id = p.job_profile_id AND jp.is_current_flag = true
WHERE p.is_current_flag = true;
```

### Pattern 2: Get Compensation for Position

```sql
-- Get pay range for position
SELECT 
    p.code AS position_code,
    p.title AS position_title,
    j.grade_code,
    gv.name AS grade_name,
    pr.min_amount,
    pr.mid_amount,
    pr.max_amount,
    pr.currency
FROM jobpos.position p
JOIN jobpos.job j ON j.id = p.job_id
JOIN tr.grade_version gv ON gv.grade_code = j.grade_code AND gv.is_current_version = true
JOIN tr.pay_range pr ON pr.grade_v_id = gv.id 
    AND pr.scope_type = 'POSITION' 
    AND pr.scope_id = p.id
    AND pr.is_active = true
WHERE p.id = 'position-uuid';
```

### Pattern 3: Validate Position-Job Consistency

```sql
-- Validation: Ensure position inherits from job correctly
SELECT 
    p.code AS position_code,
    p.title AS position_title,
    j.grade_code AS job_grade,
    j.level_code AS job_level,
    -- No grade/level on position table to validate
    CASE 
        WHEN p.job_id IS NULL THEN 'ERROR: Missing job_id'
        ELSE 'OK'
    END AS validation_status
FROM jobpos.position p
LEFT JOIN jobpos.job j ON j.id = p.job_id
WHERE p.is_current_flag = true;
```

---

## ⚠️ Common Mistakes to Avoid

### ❌ Mistake 1: Trying to Override Grade

```sql
-- WRONG: Trying to give position different grade
-- This is NOT possible because grade is on Job, not Position
UPDATE jobpos.position 
SET grade_code = 'G8'  -- ❌ Column doesn't exist!
WHERE id = 'position-uuid';

-- CORRECT: Change job's grade (affects ALL positions)
UPDATE jobpos.job
SET grade_code = 'G8'
WHERE id = 'job-uuid';
```

### ❌ Mistake 2: Duplicating Job Title

```sql
-- WRONG: Just copying job title
Position:
  title: "Software Engineer"  -- ❌ Same as job.job_title, no value added
  
-- BETTER: Add context
Position:
  title: "Software Engineer - AI Platform"  -- ✅ More specific
```

### ❌ Mistake 3: Creating Position Without Job

```sql
-- WRONG: Position without job_id
INSERT INTO jobpos.position (code, title, business_unit_id)
VALUES ('POS-001', 'Engineer', 'BU-001');  -- ❌ Missing job_id!

-- CORRECT: Always link to job
INSERT INTO jobpos.position (code, title, job_id, business_unit_id)
VALUES ('POS-001', 'Engineer - AI', 'JOB-001', 'BU-001');  -- ✅
```

---

## 📊 Use Case Examples

### Use Case 1: Same Job, Different Locations

```yaml
Job: "Regional Sales Manager"
  grade_code: "G9"
  level_code: "L4"
  job_title: "Regional Sales Manager"

Position 1: "Regional Sales Manager - North"
  job_id: JOB-RSM-001
  title: "Regional Sales Manager - North Vietnam"
  business_unit_id: BU-NORTH
  reports_to_id: VP-SALES-NORTH
  grade_code: → "G9" (inherited)

Position 2: "Regional Sales Manager - South"
  job_id: JOB-RSM-001
  title: "Regional Sales Manager - South Vietnam"
  business_unit_id: BU-SOUTH
  reports_to_id: VP-SALES-SOUTH
  grade_code: → "G9" (inherited, SAME as Position 1)
```

**Key Point**: Both positions have same grade (pay equity) but different reporting lines (org structure).

---

### Use Case 2: Part-Time Position

```yaml
Job: "Customer Service Representative"
  grade_code: "G5"
  level_code: "L2"

Position 1: "CSR - Full Time"
  job_id: JOB-CSR-001
  full_time_equiv: 1.0
  grade_code: → "G5" (inherited)

Position 2: "CSR - Part Time"
  job_id: JOB-CSR-001
  full_time_equiv: 0.5
  grade_code: → "G5" (inherited, SAME grade)
  # Note: Salary will be prorated based on FTE, but grade is same
```

---

### Use Case 3: Team-Specific Positions

```yaml
Job: "Software Engineer"
  grade_code: "G7"
  level_code: "L3"
  job_title: "Software Engineer"

Position 1: "SW Engineer - AI Platform"
  job_id: JOB-SWE-001
  title: "Software Engineer - AI Platform Team"
  reports_to_id: MGR-AI-PLATFORM
  grade_code: → "G7"

Position 2: "SW Engineer - Mobile"
  job_id: JOB-SWE-001
  title: "Software Engineer - Mobile Team"
  reports_to_id: MGR-MOBILE
  grade_code: → "G7" (SAME grade as Position 1)
```

---

## 🔍 Validation & Enforcement

### Application-Level Validation

```python
# Example validation in application code
def validate_position(position_data):
    """Validate position data before creation/update"""
    
    # Rule 1: job_id is required
    if not position_data.get('job_id'):
        raise ValidationError("job_id is required")
    
    # Rule 2: Cannot set grade_code (it's inherited)
    if 'grade_code' in position_data:
        raise ValidationError("Cannot set grade_code on position. It's inherited from job.")
    
    # Rule 3: Cannot set level_code (it's inherited)
    if 'level_code' in position_data:
        raise ValidationError("Cannot set level_code on position. It's inherited from job.")
    
    # Rule 4: title should add context, not duplicate
    job = get_job(position_data['job_id'])
    if position_data.get('title') == job.job_title:
        warnings.warn("Position title same as job title. Consider adding context.")
    
    return True
```

### Database Constraints

```sql
-- Constraint: job_id is required
ALTER TABLE jobpos.position
ADD CONSTRAINT position_job_id_required 
CHECK (job_id IS NOT NULL);

-- Note: grade_code and level_code columns don't exist on position table
-- This enforces inheritance by design
```

---

## 📚 Related Documentation

- [Job & Position Management Guide](./03-job-position-guide.md)
- [Staffing Models Guide](./08-staffing-models-guide.md)
- [Core-TR Integration Guide](../../00-integration/CO-TR-integration/02-technical-guide.md)
- [DBML Schema](../../03-design/1.Core.V4.dbml)

---

## ✅ Summary

### Key Takeaways

1. **Position = Instance of Job** in specific org context
2. **Compensation attributes (grade, level) CANNOT be overridden**
3. **Organizational attributes (title, reporting) CAN be overridden**
4. **Always access grade/level via job_id, never store on position**
5. **Use position title to add context, not duplicate job title**

### Quick Reference

```
✅ CAN Override:
- title (add context)
- reports_to_id (org structure)
- full_time_equiv (FTE)
- position_class_code
- position_type_code
- max_incumbents
- status_code

❌ CANNOT Override:
- grade_code (compensation)
- level_code (seniority)
- job_type_code (classification)
```

---

**Version History**:
- v1.0 (2025-12-17): Initial version
