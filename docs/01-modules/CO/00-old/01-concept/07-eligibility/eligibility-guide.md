# Eligibility Guide

**Module**: CO (Core)  
**Sub-Module**: Eligibility  
**Classification**: Cross-Module Feature

---

## Overview

**Eligibility** provides centralized eligibility management for cross-module features (Time & Absence, Total Rewards, Learning).

---

## Key Concepts

### Hybrid Model

**Pattern**: Default (Rule-based) + Override (Explicit)

**Components**:
1. **EligibilityProfile**: Defines WHO is eligible (organizational scope)
2. **EligibilityMember**: Cached membership (Default + Override)
3. **EligibilityEvaluation**: Audit trail

### Separation of Concerns

- **Profile**: WHO is eligible (grades, countries, tenure)
- **Consuming Entity**: WHAT they're eligible for (leave type, benefit plan)

---

## Domains

| Domain | Purpose | Examples |
|--------|---------|----------|
| ABSENCE | Time & Absence eligibility | Leave policies, time-off |
| BENEFITS | Benefits eligibility | Health plans, retirement |
| COMPENSATION | Compensation eligibility | Bonus plans, equity |
| CORE | Core module eligibility | General eligibility |

---

## Rule Evaluation

### Rule JSON Structure

```json
{
  "grades": ["G4", "G5", "G6"],
  "countries": ["VN", "US"],
  "min_tenure_months": 12,
  "employee_classes": ["FULL_TIME"],
  "business_units": ["BU_TECH"]
}
```

### Evaluation Logic

1. Fetch employee data (grade, country, tenure, etc.)
2. Evaluate each criterion in rule_json
3. Determine ELIGIBLE or NOT_ELIGIBLE
4. Update eligibility_member (cache)
5. Log in eligibility_evaluation (audit)

---

## Performance

**O(1) Eligibility Check**:
- Cached membership in `eligibility_member`
- No real-time rule evaluation needed
- Fast lookup: `WHERE profile_id = ? AND employee_id = ? AND end_date IS NULL`

**Automatic Re-evaluation**:
- Employee data changes (grade, country, etc.)
- Profile rule changes
- Scheduled batch evaluation

---

## Common Operations

### Create Profile

```yaml
POST /api/v1/eligibility/profiles
{
  "code": "ELIG_SENIOR_STAFF",
  "name": "Senior Staff Eligibility",
  "domain": "BENEFITS",
  "rule_json": {
    "grades": ["G4", "G5"],
    "min_tenure_months": 12
  }
}
```

### Manual Override (Add)

```yaml
POST /api/v1/eligibility/members
{
  "profile_id": "profile-001",
  "employee_id": "emp-001",
  "evaluation_source": "MANUAL",
  "evaluation_reason": "Executive exception"
}
```

---

## Business Rules

**BR-ELIG-001**: Profile code unique within domain  
**BR-ELIG-002**: rule_json must be valid JSON object  
**BR-ELIG-003**: Membership cached for performance  
**BR-ELIG-004**: All evaluations logged for audit

---

## Integration Points

- **Time & Absence**: Leave policy eligibility
- **Total Rewards**: Benefit/compensation eligibility
- **Learning**: Training program eligibility

---

## Related Documentation

- [Entity Definition](../../00-ontology/domain/07-eligibility/eligibility-profile.aggregate.yaml)
