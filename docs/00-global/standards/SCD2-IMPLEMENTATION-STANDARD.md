# SCD2 Implementation Standard

**Version**: 1.0  
**Last Updated**: 2025-12-17  
**Applies To**: xTalent HCM Platform - Master Data Tables

---

## Purpose

This standard defines the technical requirements for implementing SCD Type 2 (Slowly Changing Dimension Type 2) in xTalent database tables. It should be applied to all tables classified as **Master Data** per the [Data Classification Standard](./DATA-CLASSIFICATION-STANDARD.md).

---

## Required Fields

All SCD2 tables **MUST** include these fields:

| Field | Type | Nullable | Default | Description |
|-------|------|----------|---------|-------------|
| `id` | UUID | NOT NULL | `gen_random_uuid()` | Row ID (unique per version) |
| `code` or `*_code` | VARCHAR(50) | NOT NULL | - | Business key (stable across versions) |
| `effective_start_date` | DATE | NOT NULL | - | Version start date (inclusive) |
| `effective_end_date` | DATE | NULL | NULL | Version end date (inclusive), NULL = current |
| `is_current_flag` | BOOLEAN | NOT NULL | TRUE | Current version indicator |

### Field Naming Convention

```sql
-- Business Key: use entity-specific code field
employee_code     -- for employee table
job_code          -- for job table
position_code     -- for position table (or just 'code')

-- SCD2 Fields: always use these exact names
effective_start_date
effective_end_date
is_current_flag
```

---

## Required Indexes

### Mandatory Indexes

```sql
-- 1. Current version lookup (CRITICAL for performance)
CREATE UNIQUE INDEX idx_{table}_current 
ON {table}({business_key}) 
WHERE is_current_flag = TRUE;

-- 2. Business key lookup (for history queries)
CREATE INDEX idx_{table}_business_key 
ON {table}({business_key});

-- 3. Point-in-time queries
CREATE INDEX idx_{table}_effective_dates 
ON {table}(effective_start_date, effective_end_date);
```

### Example for Employee Table

```sql
-- Unique current version per legal entity + employee code
CREATE UNIQUE INDEX idx_employee_current 
ON employment.employee(legal_entity_code, employee_code) 
WHERE is_current_flag = TRUE;

-- History lookup
CREATE INDEX idx_employee_code 
ON employment.employee(employee_code);

-- Point-in-time queries
CREATE INDEX idx_employee_dates 
ON employment.employee(effective_start_date, effective_end_date);
```

---

## Required Constraints

### Check Constraints

```sql
-- 1. End date must be >= start date (when set)
ALTER TABLE {table} ADD CONSTRAINT chk_{table}_dates 
CHECK (effective_end_date IS NULL OR effective_end_date >= effective_start_date);

-- 2. Current flag consistency
ALTER TABLE {table} ADD CONSTRAINT chk_{table}_current_flag
CHECK (
    (is_current_flag = TRUE AND effective_end_date IS NULL) OR
    (is_current_flag = FALSE AND effective_end_date IS NOT NULL)
);
```

---

## Foreign Key Pattern

### Problem

In SCD2, the business key (`code`) can duplicate across versions, so database FK constraints cannot be used.

### Solution: Logical Foreign Keys

Store the business key (`code`) and validate via application logic or triggers.

```sql
-- ❌ CANNOT USE: Database FK on business key
ALTER TABLE assignment 
ADD CONSTRAINT fk_assignment_job 
FOREIGN KEY (job_code) REFERENCES job(job_code);  -- ERROR: job_code not unique

-- ✅ CORRECT: Store code, validate in application
CREATE TABLE employment.assignment (
    id UUID PRIMARY KEY,
    assignment_code VARCHAR(50) NOT NULL,
    -- Logical FK: store code, not UUID
    job_code VARCHAR(50),
    position_code VARCHAR(50),
    -- SCD2 fields
    effective_start_date DATE NOT NULL,
    effective_end_date DATE,
    is_current_flag BOOLEAN DEFAULT TRUE
);

-- Create indexes for FK lookups
CREATE INDEX idx_assignment_job_code ON employment.assignment(job_code);
CREATE INDEX idx_assignment_position_code ON employment.assignment(position_code);
```

### Validation Trigger (Optional)

```sql
CREATE OR REPLACE FUNCTION validate_scd2_fk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.job_code IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM jobpos.job 
            WHERE job_code = NEW.job_code AND is_current_flag = TRUE
        ) THEN
            RAISE EXCEPTION 'Invalid job_code: % does not exist', NEW.job_code;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

---

## Version Transition Rules

### Rule 1: End Date Continuity

```
Version N end_date = Version N+1 start_date - 1 day
```

**Example:**
```
Version 1: 2025-01-01 to 2025-06-30 (end = start of v2 - 1)
Version 2: 2025-07-01 to NULL (current)
```

### Rule 2: One Current Version

For each business key, exactly ONE version must have:
- `is_current_flag = TRUE`
- `effective_end_date = NULL`

### Rule 3: No Overlap

Versions of the same business key must NOT have overlapping date ranges.

---

## Standard Operations

### CREATE: New Entity

```sql
INSERT INTO {table} (
    id, {business_key}, {data_fields},
    effective_start_date, effective_end_date, is_current_flag
) VALUES (
    gen_random_uuid(), 'CODE001', ...,
    '2025-01-01', NULL, TRUE
);
```

### UPDATE: Create New Version

```sql
BEGIN;

-- Step 1: Close current version
UPDATE {table}
SET effective_end_date = '2025-06-30',
    is_current_flag = FALSE,
    updated_at = NOW()
WHERE {business_key} = 'CODE001' AND is_current_flag = TRUE;

-- Step 2: Create new version
INSERT INTO {table} (
    id, {business_key}, {data_fields},
    effective_start_date, effective_end_date, is_current_flag
) VALUES (
    gen_random_uuid(), 'CODE001', {new_values},
    '2025-07-01', NULL, TRUE
);

COMMIT;
```

### DELETE: Soft Delete (Close Current Version)

```sql
UPDATE {table}
SET effective_end_date = '2025-12-31',
    is_current_flag = FALSE,
    updated_at = NOW()
WHERE {business_key} = 'CODE001' AND is_current_flag = TRUE;

-- No row with is_current_flag = TRUE means entity is "deleted"
```

---

## Query Patterns

### Current Version

```sql
-- Method 1: Using flag (fastest with index)
SELECT * FROM {table}
WHERE {business_key} = 'CODE001' AND is_current_flag = TRUE;

-- Method 2: Using end date
SELECT * FROM {table}
WHERE {business_key} = 'CODE001' AND effective_end_date IS NULL;
```

### Point-in-Time Query

```sql
SELECT * FROM {table}
WHERE {business_key} = 'CODE001'
  AND effective_start_date <= '2025-05-15'
  AND (effective_end_date IS NULL OR effective_end_date >= '2025-05-15');
```

### Full History

```sql
SELECT * FROM {table}
WHERE {business_key} = 'CODE001'
ORDER BY effective_start_date DESC;
```

---

## API Design

### Standard Endpoints

```
GET  /api/{entity}/{code}              # Current version
GET  /api/{entity}/{code}?asOf=DATE    # Point-in-time
GET  /api/{entity}/{code}/history      # All versions
POST /api/{entity}                     # Create new
PUT  /api/{entity}/{code}              # Update (creates new version)
DELETE /api/{entity}/{code}            # Soft delete
```

### Request/Response Model

```typescript
interface SCD2Entity {
  id: string;              // Row UUID (version-specific)
  code: string;            // Business key (stable)
  // ... business fields ...
  effectiveStartDate: string;
  effectiveEndDate: string | null;
  isCurrent: boolean;
}

interface UpdateRequest {
  code: string;
  effectiveDate: string;   // When change takes effect
  // ... fields to change ...
}
```

---

## Compliance Checklist

Use this checklist when creating or reviewing SCD2 tables:

- [ ] Has `id` (UUID, PK) for row identity
- [ ] Has business key field (`code` or `*_code`)
- [ ] Has `effective_start_date` (DATE, NOT NULL)
- [ ] Has `effective_end_date` (DATE, NULL allowed)
- [ ] Has `is_current_flag` (BOOLEAN, DEFAULT TRUE)
- [ ] Has unique index on business key WHERE `is_current_flag = TRUE`
- [ ] Has check constraint for date validity
- [ ] Has check constraint for current flag consistency
- [ ] Foreign keys use logical pattern (code, not UUID)
- [ ] Has indexes for FK code columns

---

## Related Documents

- [Data Classification Standard](./DATA-CLASSIFICATION-STANDARD.md) - When to apply SCD2
- [SCD2 Guide](./SCD2-guide.md) - Developer guide with detailed examples
- [Naming Conventions](./naming-conventions.md) - Field naming standards

---

**Document Owner**: xTalent Architecture Team  
**Review Cycle**: Annual or upon major schema changes
