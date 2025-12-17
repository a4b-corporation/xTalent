# Migration Guide: JobGrade to GradeVersion

**Version**: 1.0  
**Last Updated**: 2025-12-17  
**Audience**: Database Administrators, System Implementers  
**Reading Time**: 20-25 minutes

---

## Overview

This guide provides step-by-step instructions for migrating from `Core.JobGrade` (deprecated) to `TR.GradeVersion`.

---

## Why Migrate?

**Core.JobGrade Limitations**:
- ❌ No version history
- ❌ No career ladder integration
- ❌ Limited pay range scoping
- ❌ Duplicate grade management

**TR.GradeVersion Benefits**:
- ✅ SCD Type 2 versioning
- ✅ Career ladder integration
- ✅ Scoped pay ranges (Position, BU, LE, Global)
- ✅ Single source of truth

---

## Pre-Migration Checklist

```sql
-- 1. Count active job grades
SELECT COUNT(*) as active_job_grades
FROM core.job_grade
WHERE is_active = true AND is_current_flag = true;

-- 2. Check jobs using job_grade
SELECT COUNT(*) as jobs_with_grade_id
FROM core.job
WHERE grade_id IS NOT NULL AND is_current_flag = true;

-- 3. Identify grade codes
SELECT code, name, COUNT(*) as job_count
FROM core.job_grade jg
LEFT JOIN core.job j ON j.grade_id = jg.id
WHERE jg.is_active = true
GROUP BY jg.code, jg.name
ORDER BY jg.grade_order;

-- 4. Check for duplicate grade codes
SELECT code, COUNT(*) as count
FROM core.job_grade
WHERE is_active = true
GROUP BY code
HAVING COUNT(*) > 1;
```

---

## Migration Steps

### Step 1: Backup Data

```sql
-- Create backup tables
CREATE TABLE core.job_grade_backup AS
SELECT * FROM core.job_grade;

CREATE TABLE core.job_backup AS
SELECT * FROM core.job WHERE is_current_flag = true;
```

### Step 2: Create TR.GradeVersion Records

```sql
-- Migrate job grades to grade versions
INSERT INTO tr.grade_version (
    id,
    grade_code,
    name,
    description,
    job_level,
    sort_order,
    effective_start_date,
    effective_end_date,
    version_number,
    previous_version_id,
    is_current_version,
    metadata,
    created_date,
    created_by
)
SELECT 
    gen_random_uuid(),
    jg.code,
    jg.name,
    jg.description,
    jg.grade_order,
    jg.grade_order,
    COALESCE(jg.effective_start_date, CURRENT_DATE),
    NULL,  -- Current version has no end date
    1,  -- First version
    NULL,  -- No previous version
    true,  -- Is current
    jsonb_build_object(
        'migrated_from', 'core.job_grade',
        'original_id', jg.id::text,
        'migration_date', CURRENT_DATE::text
    ),
    NOW(),
    '00000000-0000-0000-0000-000000000000'::uuid  -- System migration user
FROM core.job_grade jg
WHERE jg.is_active = true
  AND jg.is_current_flag = true
  AND NOT EXISTS (
      SELECT 1 FROM tr.grade_version gv
      WHERE gv.grade_code = jg.code
        AND gv.is_current_version = true
  );

-- Verify migration
SELECT 
    'Migrated grades' as check_name,
    COUNT(*) as count
FROM tr.grade_version
WHERE metadata->>'migrated_from' = 'core.job_grade';
```

### Step 3: Migrate Pay Ranges

```sql
-- Create global pay ranges from job grades
INSERT INTO tr.pay_range (
    id,
    grade_v_id,
    scope_type,
    scope_uuid,
    currency,
    min_amount,
    mid_amount,
    max_amount,
    range_spread_pct,
    effective_start_date,
    effective_end_date,
    is_active,
    metadata,
    created_date,
    created_by
)
SELECT 
    gen_random_uuid(),
    gv.id,
    'GLOBAL',
    NULL,
    jg.currency_code,
    jg.min_salary,
    jg.mid_salary,
    jg.max_salary,
    ROUND(
        ((jg.max_salary - jg.min_salary) / NULLIF(jg.mid_salary, 0) * 100)::numeric,
        2
    ),
    COALESCE(jg.effective_start_date, CURRENT_DATE),
    NULL,
    true,
    jsonb_build_object(
        'migrated_from', 'core.job_grade',
        'original_grade_id', jg.id::text,
        'migration_date', CURRENT_DATE::text
    ),
    NOW(),
    '00000000-0000-0000-0000-000000000000'::uuid
FROM core.job_grade jg
JOIN tr.grade_version gv ON gv.grade_code = jg.code
WHERE jg.is_active = true
  AND jg.is_current_flag = true
  AND gv.is_current_version = true
  AND jg.min_salary IS NOT NULL
  AND jg.mid_salary IS NOT NULL
  AND jg.max_salary IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM tr.pay_range pr
      WHERE pr.grade_v_id = gv.id
        AND pr.scope_type = 'GLOBAL'
        AND pr.is_active = true
  );

-- Verify pay ranges
SELECT 
    'Migrated pay ranges' as check_name,
    COUNT(*) as count
FROM tr.pay_range
WHERE metadata->>'migrated_from' = 'core.job_grade';
```

### Step 4: Update Core.Job References

```sql
-- Add grade_code column if not exists
ALTER TABLE core.job 
ADD COLUMN IF NOT EXISTS grade_code VARCHAR(20);

-- Populate grade_code from grade_id
UPDATE core.job j
SET grade_code = (
    SELECT jg.code
    FROM core.job_grade jg
    WHERE jg.id = j.grade_id
)
WHERE j.grade_id IS NOT NULL
  AND j.grade_code IS NULL
  AND j.is_current_flag = true;

-- Verify update
SELECT 
    COUNT(*) FILTER (WHERE grade_code IS NOT NULL) as with_grade_code,
    COUNT(*) FILTER (WHERE grade_id IS NOT NULL AND grade_code IS NULL) as missing_grade_code,
    COUNT(*) as total
FROM core.job
WHERE is_current_flag = true;
```

### Step 5: Create Index

```sql
-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_job_grade_code 
ON core.job(grade_code)
WHERE is_current_flag = true;
```

### Step 6: Mark JobGrade as Deprecated

```sql
-- Add deprecation metadata
UPDATE core.job_grade
SET metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{deprecated}',
    'true'::jsonb
),
metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{deprecated_date}',
    to_jsonb(CURRENT_DATE::text)
),
metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{migration_note}',
    '"Migrated to TR.GradeVersion. Use grade_code for all new implementations."'::jsonb
),
metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{replacement}',
    '"TR.GradeVersion"'::jsonb
);
```

---

## Validation Queries

```sql
-- 1. Verify all jobs have grade_code
SELECT 
    'Jobs missing grade_code' as issue,
    COUNT(*) as count
FROM core.job
WHERE grade_id IS NOT NULL
  AND grade_code IS NULL
  AND is_current_flag = true;

-- 2. Verify grade_code exists in TR
SELECT 
    'Jobs with invalid grade_code' as issue,
    COUNT(*) as count
FROM core.job j
WHERE j.grade_code IS NOT NULL
  AND j.is_current_flag = true
  AND NOT EXISTS (
      SELECT 1 FROM tr.grade_version gv
      WHERE gv.grade_code = j.grade_code
        AND gv.is_current_version = true
  );

-- 3. Verify pay ranges exist
SELECT 
    gv.grade_code,
    gv.name,
    COUNT(pr.id) as pay_range_count
FROM tr.grade_version gv
LEFT JOIN tr.pay_range pr ON pr.grade_v_id = gv.id AND pr.is_active = true
WHERE gv.is_current_version = true
GROUP BY gv.grade_code, gv.name
HAVING COUNT(pr.id) = 0;

-- 4. Compare counts
SELECT 
    (SELECT COUNT(*) FROM core.job_grade WHERE is_active = true) as job_grade_count,
    (SELECT COUNT(*) FROM tr.grade_version WHERE is_current_version = true) as grade_version_count,
    (SELECT COUNT(DISTINCT grade_code) FROM core.job WHERE grade_code IS NOT NULL) as jobs_using_grade_code;
```

---

## Rollback Procedure

```sql
-- If migration needs to be reversed

-- 1. Restore grade_id from grade_code
UPDATE core.job j
SET grade_id = (
    SELECT jg.id
    FROM core.job_grade jg
    WHERE jg.code = j.grade_code
)
WHERE j.grade_code IS NOT NULL
  AND j.is_current_flag = true;

-- 2. Remove deprecation flags
UPDATE core.job_grade
SET metadata = metadata - 'deprecated' - 'deprecated_date' - 'migration_note' - 'replacement';

-- 3. Optionally delete migrated TR data
DELETE FROM tr.pay_range
WHERE metadata->>'migrated_from' = 'core.job_grade';

DELETE FROM tr.grade_version
WHERE metadata->>'migrated_from' = 'core.job_grade';

-- 4. Restore from backup if needed
-- TRUNCATE tr.grade_version;
-- TRUNCATE tr.pay_range;
-- Restore from backup tables
```

---

## Post-Migration Tasks

### 1. Update Application Code

```python
# OLD CODE (deprecated)
job = db.query("SELECT grade_id FROM core.job WHERE id = %s", (job_id,))
grade = db.query("SELECT * FROM core.job_grade WHERE id = %s", (job['grade_id'],))

# NEW CODE (recommended)
job = db.query("SELECT grade_code FROM core.job WHERE id = %s", (job_id,))
grade = db.query("""
    SELECT * FROM tr.grade_version 
    WHERE grade_code = %s AND is_current_version = true
""", (job['grade_code'],))
```

### 2. Update Documentation

- ✅ Mark Core.JobGrade as deprecated in API docs
- ✅ Update integration guides
- ✅ Update code examples

### 3. Monitor Usage

```sql
-- Track usage of deprecated grade_id
SELECT 
    COUNT(*) as jobs_still_using_grade_id
FROM core.job
WHERE grade_id IS NOT NULL
  AND is_current_flag = true;

-- Should be 0 after migration
```

---

## Timeline

| Phase | Duration | Tasks |
|-------|----------|-------|
| **Preparation** | 1 week | Backup, validation, testing |
| **Migration** | 1 day | Execute migration scripts |
| **Validation** | 2 days | Run validation queries, test |
| **Code Updates** | 1 week | Update application code |
| **Monitoring** | 2 weeks | Monitor for issues |

---

**See Also**:
- [Technical Guide](./02-technical-guide.md)
- [Conceptual Guide](./01-conceptual-guide.md)
