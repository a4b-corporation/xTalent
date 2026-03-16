# Eligibility Engine Consolidation Plan

**Scope**: Migrate from fragmented eligibility → single Core eligibility engine  
**Assessed**: 2026-03-16

---

## 1. Current State — 3 Implementations

### 1.1 Core `eligibility.*` (Primary — Dec 2025)

| Table | Fields | Features |
|-------|--------|----------|
| `eligibility_profile` | code, name, domain, rule_json, priority, SCD-2 | Rule-based, domain-aware, priority ordering |
| `eligibility_member` | profile_id, employee_id, start/end, eval source/reason | Cached membership, O(1) lookup |
| `eligibility_evaluation` | profile_id, employee_id, result, reason, triggered_by | Immutable audit log |

**Domains supported**: `ABSENCE | BENEFITS | COMPENSATION | CORE`

### 1.2 TR `benefit.*` (Duplicate — Nov 2025)

| Table | Fields | Overlap |
|-------|--------|---------|
| `benefit.eligibility_profile` | code, rule_json, domain, SCD-2 | **100% overlap** with Core structure |
| `benefit.plan_eligibility` | plan_id, profile_id, criteria_json | Bridge: plan → eligibility |

### 1.3 TA `absence.*` (Already Migrated ✅)

TA uses Core eligibility via `default_eligibility_profile_id`:
- `absence.leave_type.default_eligibility_profile_id` → Core
- `absence.leave_class.default_eligibility_profile_id` → Core
- `absence.leave_policy.default_eligibility_profile_id` → Core
- `absence.leave_class.eligibility_json` → **DEPRECATED** ✅

---

## 2. Target State — Single Engine

```
┌─────────────────────────────────────────────────────┐
│ Core Module — eligibility.* schema                   │
│                                                      │
│ eligibility_profile                                  │
│   domain: ABSENCE | BENEFITS | COMPENSATION |        │
│           TIME_ATTENDANCE | CORE | RECOGNITION       │
│   rule_json: { grades, countries, tenure, job_level,│
│               worker_category, ... }                 │
│                                                      │
│ eligibility_member (cached — auto/manual/override)   │
│                                                      │
│ eligibility_evaluation (immutable audit trail)       │
└────────┬────────────────────┬───────────────┬───────┘
         │                    │               │
         ▼                    ▼               ▼
    TA Module             TR Module        PR Module
    leave_type →          benefit.plan →    pay_group →
    eligibility_          eligibility_      eligibility_
    profile_id            profile_id        profile_id
```

---

## 3. Migration Plan

### Phase 1: Data Migration (1 sprint)

**Step 1**: Audit existing TR eligibility profiles

```sql
-- Identify benefits using TR eligibility
SELECT bp.code as plan_code, bep.code as eligibility_code, bep.rule_json
FROM benefit.plan bp
JOIN benefit.plan_eligibility bpe ON bp.id = bpe.plan_id
JOIN benefit.eligibility_profile bep ON bpe.eligibility_profile_id = bep.id;
```

**Step 2**: Create corresponding profiles in Core eligibility

```sql
-- Migrate each TR eligibility profile → Core
INSERT INTO eligibility.eligibility_profile (code, name, domain, rule_json, priority, ...)
SELECT 
  'BEN_' || code,      -- prefix to avoid code conflict
  name,
  'BENEFITS',           -- set domain
  rule_json,            -- same format
  priority,
  effective_start_date, effective_end_date, is_current_flag
FROM benefit.eligibility_profile;
```

**Step 3**: Update benefit.plan references

```sql
-- Replace benefit.plan_eligibility with direct FK
ALTER TABLE benefit.plan ADD COLUMN eligibility_profile_id uuid 
  REFERENCES eligibility.eligibility_profile(id);

-- Backfill from plan_eligibility bridge table
UPDATE benefit.plan bp 
SET eligibility_profile_id = (
  SELECT core_ep.id FROM eligibility.eligibility_profile core_ep
  WHERE core_ep.code = 'BEN_' || (
    SELECT bep.code FROM benefit.plan_eligibility bpe
    JOIN benefit.eligibility_profile bep ON bpe.eligibility_profile_id = bep.id
    WHERE bpe.plan_id = bp.id
    LIMIT 1
  )
);
```

### Phase 2: Deprecation (0.5 sprint)

1. Mark `benefit.eligibility_profile` as **DEPRECATED**
2. Mark `benefit.plan_eligibility` as **DEPRECATED**
3. Add deprecation Note in DBML
4. Application code: read from Core, write to Core
5. Keep TR tables for 2 releases (backward compatibility)

### Phase 3: Cleanup (future)

1. Drop `benefit.eligibility_profile` table
2. Drop `benefit.plan_eligibility` table
3. Remove `criteria_json` from other TR tables (if any)

---

## 4. Extended Domain Support

### New Domains to Add

| Domain | Use Case | Example |
|--------|----------|---------|
| `TIME_ATTENDANCE` | Shift patterns, schedule policies | "Only senior staff get flexible schedule" |
| `RECOGNITION` | Points allocation programs | "Only managers can award gold recognition" |
| `PAYROLL` | Pay group assignment | "Hourly workers use weekly payroll" |
| `TALENT` | Learning/training eligibility | "Only L5+ can access leadership program" |

### Rule JSON Schema Extension

Current:
```json
{
  "grades": ["G4", "G5"],
  "countries": ["VN"],
  "min_tenure_months": 12
}
```

Extended:
```json
{
  "grades": ["G4", "G5"],
  "countries": ["VN"],
  "min_tenure_months": 12,
  "worker_categories": ["REGULAR", "CONTRACT"],
  "employee_classes": ["FULL_TIME"],
  "job_levels": ["L3", "L4", "L5"],
  "business_units": ["BU_ENG", "BU_PRODUCT"],
  "legal_entities": ["LE_VNG_VN"],
  "age_range": { "min": 18, "max": 65 },
  "hire_date_range": { "after": "2020-01-01" },
  "employment_status": ["ACTIVE"],
  "custom_attributes": {
    "has_dependents": true,
    "performance_rating_min": 3
  }
}
```

---

## 5. API Contract for Eligibility

```yaml
# Eligibility Service API
GET  /api/v1/eligibility/profiles?domain={domain}
POST /api/v1/eligibility/profiles
GET  /api/v1/eligibility/profiles/{id}/members
POST /api/v1/eligibility/evaluate
  Body: { profile_id, employee_id }
  Response: { result: ELIGIBLE|NOT_ELIGIBLE, reason, evaluated_at }

# Batch evaluation
POST /api/v1/eligibility/evaluate/batch
  Body: { profile_id, employee_ids: [...] }
  Response: { results: [...] }

# Cache invalidation trigger  
POST /api/v1/eligibility/refresh
  Body: { employee_id }  # re-evaluate all profiles for employee
```

---

## 6. Impact Assessment

| Module | Change Required | Effort |
|--------|----------------|:------:|
| **Core** | Add new domains, extend rule_json schema | 0.5 sprint |
| **TR** | Migrate eligibility, update plan FKs | 1 sprint |
| **TA** | No change needed ✅ | 0 |
| **PR** | Optional: use eligibility for pay_group assignment | 0.5 sprint |
| **Total** | | **2 sprints** |

---

*← [04 PR Analysis](./04-pr-analysis.md) · [06 Country Config Unification →](./06-country-config-unification.md)*
