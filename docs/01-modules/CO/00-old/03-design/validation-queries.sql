-- ============================================
-- Validation Queries for Grade Migration
-- Date: 2025-12-17
-- Purpose: Validate DBML changes and data integrity
-- ============================================

-- ============================================
-- PRE-MIGRATION VALIDATION
-- ============================================

-- Query 1: Count current jobs
SELECT 
    'Current jobs' as metric,
    COUNT(*) as count
FROM jobpos.job
WHERE is_current_flag = true;

-- Query 2: Count current job profiles
SELECT 
    'Current job profiles' as metric,
    COUNT(*) as count
FROM jobpos.job_profile
WHERE is_current_flag = true;

-- Query 3: Count current positions
SELECT 
    'Current positions' as metric,
    COUNT(*) as count
FROM jobpos.position
WHERE is_current_flag = true;

-- Query 4: Check job_profile grade distribution
SELECT 
    'Job profiles with grade_code' as metric,
    COUNT(*) FILTER (WHERE grade_code IS NOT NULL) as with_grade,
    COUNT(*) FILTER (WHERE grade_code IS NULL) as without_grade,
    COUNT(*) as total,
    ROUND(COUNT(*) FILTER (WHERE grade_code IS NOT NULL) * 100.0 / COUNT(*), 2) as percentage_with_grade
FROM jobpos.job_profile
WHERE is_current_flag = true;

-- Query 5: Check job_profile level distribution
SELECT 
    'Job profiles with level_code' as metric,
    COUNT(*) FILTER (WHERE level_code IS NOT NULL) as with_level,
    COUNT(*) FILTER (WHERE level_code IS NULL) as without_level,
    COUNT(*) as total
FROM jobpos.job_profile
WHERE is_current_flag = true;

-- Query 6: Check for jobs with multiple profiles
SELECT 
    job_id,
    COUNT(*) as profile_count,
    STRING_AGG(DISTINCT locale_code, ', ') as locales,
    STRING_AGG(DISTINCT grade_code, ', ') as grades
FROM jobpos.job_profile
WHERE is_current_flag = true
GROUP BY job_id
HAVING COUNT(*) > 1
ORDER BY profile_count DESC;

-- Query 7: Check for grade inconsistency across profiles
SELECT 
    'Jobs with inconsistent grades across profiles' as issue,
    COUNT(DISTINCT job_id) as job_count
FROM (
    SELECT 
        job_id,
        COUNT(DISTINCT grade_code) as unique_grades
    FROM jobpos.job_profile
    WHERE is_current_flag = true
      AND grade_code IS NOT NULL
    GROUP BY job_id
    HAVING COUNT(DISTINCT grade_code) > 1
) inconsistent;

-- ============================================
-- POST-MIGRATION VALIDATION
-- ============================================

-- Query 8: Verify jobs have grade_code after migration
SELECT 
    'Jobs with grade_code' as metric,
    COUNT(*) FILTER (WHERE grade_code IS NOT NULL) as with_grade,
    COUNT(*) FILTER (WHERE grade_code IS NULL) as without_grade,
    COUNT(*) as total,
    ROUND(COUNT(*) FILTER (WHERE grade_code IS NOT NULL) * 100.0 / COUNT(*), 2) as percentage_with_grade
FROM jobpos.job
WHERE is_current_flag = true;

-- Query 9: Verify jobs have level_code after migration
SELECT 
    'Jobs with level_code' as metric,
    COUNT(*) FILTER (WHERE level_code IS NOT NULL) as with_level,
    COUNT(*) FILTER (WHERE level_code IS NULL) as without_level,
    COUNT(*) as total
FROM jobpos.job
WHERE is_current_flag = true;

-- Query 10: Check grade consistency between job and job_profile
SELECT 
    'Grade consistency check' as validation,
    COUNT(*) as total_comparisons,
    COUNT(*) FILTER (WHERE j.grade_code = jp.grade_code) as matching,
    COUNT(*) FILTER (WHERE j.grade_code != jp.grade_code) as mismatched,
    COUNT(*) FILTER (WHERE j.grade_code IS NULL AND jp.grade_code IS NOT NULL) as job_missing,
    COUNT(*) FILTER (WHERE j.grade_code IS NOT NULL AND jp.grade_code IS NULL) as profile_missing
FROM jobpos.job j
JOIN jobpos.job_profile jp ON jp.job_id = j.id
WHERE j.is_current_flag = true
  AND jp.is_current_flag = true;

-- Query 11: List mismatched grades (if any)
SELECT 
    j.job_code,
    j.job_title,
    j.grade_code as job_grade,
    jp.locale_code,
    jp.grade_code as profile_grade,
    'MISMATCH' as status
FROM jobpos.job j
JOIN jobpos.job_profile jp ON jp.job_id = j.id
WHERE j.is_current_flag = true
  AND jp.is_current_flag = true
  AND j.grade_code != jp.grade_code
ORDER BY j.job_code, jp.locale_code;

-- Query 12: Verify positions have job_id
SELECT 
    'Positions with job_id' as metric,
    COUNT(*) FILTER (WHERE job_id IS NOT NULL) as with_job_id,
    COUNT(*) FILTER (WHERE job_id IS NULL) as without_job_id,
    COUNT(*) as total,
    ROUND(COUNT(*) FILTER (WHERE job_id IS NOT NULL) * 100.0 / COUNT(*), 2) as percentage_with_job_id
FROM jobpos.position
WHERE is_current_flag = true;

-- Query 13: Check position job_id consistency with job_profile
SELECT 
    'Position job_id consistency' as validation,
    COUNT(*) as total_positions,
    COUNT(*) FILTER (WHERE p.job_id = jp.job_id) as matching,
    COUNT(*) FILTER (WHERE p.job_id != jp.job_id) as mismatched,
    COUNT(*) FILTER (WHERE p.job_id IS NULL) as job_id_missing,
    COUNT(*) FILTER (WHERE p.job_profile_id IS NULL) as profile_id_missing
FROM jobpos.position p
LEFT JOIN jobpos.job_profile jp ON jp.id = p.job_profile_id
WHERE p.is_current_flag = true;

-- Query 14: Verify TR integration - check grade_code exists in TR.GradeVersion
SELECT 
    'TR integration check' as validation,
    COUNT(*) as total_jobs_with_grade,
    COUNT(*) FILTER (WHERE gv.id IS NOT NULL) as valid_grades,
    COUNT(*) FILTER (WHERE gv.id IS NULL) as invalid_grades
FROM jobpos.job j
LEFT JOIN tr.grade_version gv ON gv.grade_code = j.grade_code AND gv.is_current_version = true
WHERE j.is_current_flag = true
  AND j.grade_code IS NOT NULL;

-- Query 15: List jobs with invalid grade_code (not in TR)
SELECT 
    j.job_code,
    j.job_title,
    j.grade_code,
    'INVALID - Not found in TR.GradeVersion' as issue
FROM jobpos.job j
WHERE j.is_current_flag = true
  AND j.grade_code IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM tr.grade_version gv
      WHERE gv.grade_code = j.grade_code
        AND gv.is_current_version = true
  )
ORDER BY j.job_code;

-- Query 16: Verify indexes exist
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'jobpos'
  AND tablename IN ('job', 'position')
  AND (
      indexname LIKE '%grade%' OR 
      indexname LIKE '%level%' OR
      indexname LIKE '%job_id%'
  )
ORDER BY tablename, indexname;

-- Query 17: Check for orphaned positions (no job_id and no job_profile_id)
SELECT 
    'Orphaned positions' as issue,
    COUNT(*) as count
FROM jobpos.position
WHERE is_current_flag = true
  AND job_id IS NULL
  AND job_profile_id IS NULL;

-- Query 18: Sample data verification - show first 10 jobs with grade
SELECT 
    j.job_code,
    j.job_title,
    j.grade_code,
    j.level_code,
    gv.name as grade_name,
    pr.min_amount,
    pr.mid_amount,
    pr.max_amount,
    pr.currency
FROM jobpos.job j
LEFT JOIN tr.grade_version gv ON gv.grade_code = j.grade_code AND gv.is_current_version = true
LEFT JOIN tr.pay_range pr ON pr.grade_v_id = gv.id AND pr.scope_type = 'GLOBAL' AND pr.is_active = true
WHERE j.is_current_flag = true
  AND j.grade_code IS NOT NULL
ORDER BY j.job_code
LIMIT 10;

-- Query 19: Sample position data verification
SELECT 
    p.code as position_code,
    p.title as position_title,
    j.job_code,
    j.grade_code,
    gv.name as grade_name,
    jp.locale_code,
    jp.job_title as profile_title
FROM jobpos.position p
JOIN jobpos.job j ON j.id = p.job_id
LEFT JOIN jobpos.job_profile jp ON jp.id = p.job_profile_id
LEFT JOIN tr.grade_version gv ON gv.grade_code = j.grade_code AND gv.is_current_version = true
WHERE p.is_current_flag = true
ORDER BY p.code
LIMIT 10;

-- Query 20: Grade distribution summary
SELECT 
    j.grade_code,
    gv.name as grade_name,
    COUNT(DISTINCT j.id) as job_count,
    COUNT(DISTINCT p.id) as position_count
FROM jobpos.job j
LEFT JOIN tr.grade_version gv ON gv.grade_code = j.grade_code AND gv.is_current_version = true
LEFT JOIN jobpos.position p ON p.job_id = j.id AND p.is_current_flag = true
WHERE j.is_current_flag = true
  AND j.grade_code IS NOT NULL
GROUP BY j.grade_code, gv.name
ORDER BY gv.name;

-- ============================================
-- SUMMARY REPORT
-- ============================================

-- Query 21: Migration summary report
SELECT 
    'Migration Summary' as report_section,
    jsonb_build_object(
        'total_jobs', (SELECT COUNT(*) FROM jobpos.job WHERE is_current_flag = true),
        'jobs_with_grade', (SELECT COUNT(*) FROM jobpos.job WHERE is_current_flag = true AND grade_code IS NOT NULL),
        'total_positions', (SELECT COUNT(*) FROM jobpos.position WHERE is_current_flag = true),
        'positions_with_job_id', (SELECT COUNT(*) FROM jobpos.position WHERE is_current_flag = true AND job_id IS NOT NULL),
        'valid_tr_grades', (
            SELECT COUNT(*) 
            FROM jobpos.job j
            JOIN tr.grade_version gv ON gv.grade_code = j.grade_code AND gv.is_current_version = true
            WHERE j.is_current_flag = true AND j.grade_code IS NOT NULL
        ),
        'migration_date', CURRENT_DATE
    ) as summary_data;
