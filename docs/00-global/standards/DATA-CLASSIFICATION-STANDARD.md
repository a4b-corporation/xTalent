# Data Classification Standard

**Version**: 1.1  
**Last Updated**: 2025-12-17  
**Applies To**: xTalent HCM Platform  
**Changelog v1.1**: Added Category 2B (Linked Entities with Business Dates) and Relationship Patterns Summary

---

## Purpose

This standard defines how data in the xTalent HCM platform should be classified based on its temporal characteristics, and provides clear guidance on when to apply SCD Type 2 (Slowly Changing Dimension Type 2) versioning.

---

## Data Categories

xTalent data is classified into **four categories** based on its temporal behavior and history tracking requirements:

| Category | SCD2 Required | Key Characteristic | Example |
|----------|---------------|-------------------|---------|
| **Master Data** | ✅ Yes | Slowly changing, needs full history | Employee, Job, Position |
| **Transaction Data** | ❌ No | Has natural effective/value date | Leave Request, Payroll Run |
| **Reference Data** | ⚠️ Optional | Static lookup, rarely changes | Country, Currency |
| **Audit/Log Data** | ❌ No | Immutable, insert-only | Eligibility Evaluation Log |

---

## Category 1: Master Data

### Definition

Master Data represents core business entities that:
- Change slowly over time
- Require full history tracking for audit and reporting
- Need "point-in-time" query capability (what was the data at date X?)
- Do NOT have a natural business effective date

### SCD2 Requirements

**Mandatory fields:**

```sql
effective_start_date DATE NOT NULL
effective_end_date   DATE NULL          -- NULL = currently effective
is_current_flag      BOOLEAN DEFAULT TRUE
```

### Examples in xTalent

| Schema | Table | Business Key | Description |
|--------|-------|--------------|-------------|
| `org_legal` | `entity` | `code` | Legal entities (companies) |
| `org_bu` | `unit` | `code` | Business units |
| `jobpos` | `job` | `job_code` (within tree) | Job definitions |
| `jobpos` | `position` | `code` | Positions |
| `jobpos` | `job_profile` | `job_id + locale_code` | Job descriptions |
| `employment` | `employee` | `employee_code` (within LE) | Employment records |
| `employment` | `assignment` | - | Employee assignments |
| `common` | `code_list` | `group_code + code` | System code lists |

### Decision Criteria

Apply SCD2 when **ALL** of these conditions are met:

- [ ] Data represents a core business entity (not a transaction)
- [ ] Historical versions are needed for audit/compliance
- [ ] Users need to query "what was X on date Y?"
- [ ] Entity does NOT have a natural effective date from business process

---

## Category 2: Transaction Data

### Definition

Transaction Data represents discrete business events or transactions that:
- Have a **natural effective/value date** from the business process
- Each record is an independent event
- History is preserved by the records themselves (not by versioning)
- Corrections are made via adjustment/reversal records

### SCD2 Requirements

**NOT required.** Use the natural effective date instead.

### Examples in xTalent

| Schema | Table | Natural Date Field(s) | Description |
|--------|-------|----------------------|-------------|
| `tr` | `compensation_adjustment` | `effective_date` | Salary changes |
| `tr` | `bonus_payout` | `payout_date` | Bonus payments |
| `ta` | `leave_request` | `start_date`, `end_date` | Leave requests |
| `ta` | `time_entry` | `work_date` | Time tracking entries |
| `employment` | `contract` | `start_date`, `end_date` | Employment contracts |
| `payroll` | `payroll_run` | `pay_period_start/end` | Payroll runs |

### Why NOT SCD2?

1. **Date is inherent**: The effective date is a core business attribute
2. **Immutable by design**: Original transactions are preserved; corrections create new records
3. **Natural history**: Query by effective date provides point-in-time data

### Correction Pattern

Instead of updating transaction records:

```sql
-- ❌ WRONG: Don't update transaction records
UPDATE compensation_adjustment SET amount = 5000 WHERE id = 'xxx';

-- ✅ CORRECT: Create adjustment record
INSERT INTO compensation_adjustment (
    employee_id, adjustment_type, amount, effective_date, 
    reference_adjustment_id, reason
) VALUES (
    'emp-001', 'CORRECTION', -500, '2025-01-15',
    'original-adjustment-id', 'Correcting calculation error'
);
```

---

## Category 2B: Linked Entities with Business Dates

> [!IMPORTANT]
> **Key Distinction**: Child/linked entities that have **natural effective dates** from business process should be treated as **Transaction Data**, NOT as SCD2 entities.

### Definition

These are entities that:
- Are linked to a Master Data entity (parent)
- Have their own **effective dates from business** (issue date, start date, end date)
- Changes are tracked via new records, not versioning
- The dates themselves **ARE** the history

### Examples in xTalent

| Parent (SCD2) | Child Entity | Has Business Dates | SCD2? | Reason |
|---------------|-------------|-------------------|-------|--------|
| `org_legal.entity` | `entity_license` | ✅ `issue_date`, `effective_start/end_date` | ❌ NO | New license = new record |
| `org_legal.entity` | `entity_representative` | ✅ `effective_start/end_date` | ❌ NO | New rep = new record |
| `org_legal.entity` | `entity_bank_account` | ❌ No effective dates | ❌ NO | Simple CRUD, use `is_primary` |
| `employment.employee` | `employment.contract` | ✅ `start_date`, `end_date` | ❌ NO | New contract = new record |
| `person.worker` | `person.contact` | ✅ `effective_start/end_date` | ⚠️ Optional | Could be SCD2 if need history |

### Pattern: Parent (SCD2) → Child (Business Dates)

```sql
-- Parent: org_legal.entity (SCD2)
-- Has: effective_start_date, effective_end_date, is_current_flag

-- Child: entity_license (NOT SCD2 - has business dates)
CREATE TABLE org_legal.entity_license (
    id UUID PRIMARY KEY,
    legal_entity_code VARCHAR(50) NOT NULL,   -- FK to parent (by code)
    license_number VARCHAR(100),
    issue_date DATE,                           -- Business date
    effective_start_date DATE NOT NULL,        -- Business date (NOT SCD2!)
    effective_end_date DATE,                   -- Business date (NOT SCD2!)
    -- NO is_current_flag needed
    created_at TIMESTAMP DEFAULT NOW()
);

-- Query: Get all active licenses for a legal entity
SELECT * FROM org_legal.entity_license
WHERE legal_entity_code = 'VNG_VN'
  AND effective_start_date <= CURRENT_DATE
  AND (effective_end_date IS NULL OR effective_end_date >= CURRENT_DATE);
```

### How to Change a License?

```sql
-- Scenario: License LIC001 expires, company gets new license LIC002

-- Option A: End old license and create new one
UPDATE org_legal.entity_license
SET effective_end_date = '2025-12-31'
WHERE license_number = 'LIC001';

INSERT INTO org_legal.entity_license (
    id, legal_entity_code, license_number, issue_date, effective_start_date
) VALUES (
    gen_random_uuid(), 'VNG_VN', 'LIC002', '2025-12-15', '2026-01-01'
);

-- Option B: If license content changes (same number, new terms)
-- Just create new record with same license_number, different dates
INSERT INTO org_legal.entity_license (
    id, legal_entity_code, license_number, issue_date, effective_start_date
) VALUES (
    gen_random_uuid(), 'VNG_VN', 'LIC001', '2025-12-15', '2026-01-01'
);
```

---

## Relationship Patterns Summary

### Pattern Matrix

| Link Type | Parent | Child | Child has business dates? | Child uses SCD2? |
|-----------|--------|-------|---------------------------|------------------|
| **1-1 Extension** | SCD2 | Profile | ❌ No | Follow parent |
| **1-N with dates** | SCD2 | License, Rep | ✅ Yes | ❌ NO |
| **1-N simple** | SCD2 | Bank Account | ❌ No | ❌ NO (CRUD) |
| **N-N mapping** | SCD2 | SCD2 | Mapping dates | ❌ NO (dates in mapping) |

### Decision Rule for Linked Entities

```
Does the child entity have effective dates from business process?
    │
    ├── YES → NOT SCD2 (dates are the history)
    │         Examples: license, representative, contract
    │
    └── NO → Does it need history tracking?
              │
              ├── YES → Follow parent's SCD2 lifecycle
              │         Examples: entity_profile (1-1)
              │
              └── NO → Simple CRUD
                        Examples: bank_account, photo
```

---

## Category 3: Reference Data

### Definition

Reference Data is static or semi-static lookup data that:
- Rarely changes (e.g., ISO codes)
- Used for validation and display
- May need soft-delete capability

### SCD2 Requirements

**Optional.** Recommended patterns:

| Change Frequency | Recommended Approach |
|-----------------|---------------------|
| Never changes (ISO codes) | No SCD2, use `is_active` flag only |
| Rarely changes (tax rates) | Lightweight SCD2 (effective dates only) |
| Sometimes changes (internal codes) | Full SCD2 if history tracking needed |

### Examples in xTalent

| Schema | Table | Recommended Approach |
|--------|-------|---------------------|
| `geo` | `country` | Optional SCD2 (rarely changes) |
| `common` | `currency` | Optional SCD2 |
| `common` | `time_zone` | Optional SCD2 |
| `common` | `contact_type` | Full SCD2 (internal config) |

---

## Category 4: Audit/Log Data

### Definition

Audit/Log Data is immutable event data that:
- Is INSERT-only (never updated)
- Records what happened and when
- Used for audit trail and troubleshooting

### SCD2 Requirements

**NOT required.** Data is immutable by design.

### Examples in xTalent

| Schema | Table | Description |
|--------|-------|-------------|
| `eligibility` | `eligibility_evaluation` | Eligibility check results |
| `org_snapshot` | `unit` | Organization structure snapshots |
| `org_snapshot` | `entity` | Legal entity snapshots |

### Key Characteristic

```sql
-- Audit tables should NOT allow updates
-- Enforce via application logic or database triggers
```

---

## Decision Tree

Use this flowchart to determine the appropriate data category:

```
                    ┌─────────────────────────┐
                    │   What type of data?    │
                    └───────────┬─────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
   ┌─────────────┐       ┌─────────────┐        ┌───────────────┐
   │ Represents  │       │ Represents  │        │ Is it lookup/ │
   │ a discrete  │       │ a core      │        │ reference     │
   │ event/      │       │ entity that │        │ data?         │
   │ transaction?│       │ changes?    │        │               │
   └──────┬──────┘       └──────┬──────┘        └───────┬───────┘
          │                     │                       │
          ▼                     ▼                       ▼
   ┌─────────────┐       ┌─────────────┐        ┌───────────────┐
   │ Does it have│       │ Need to     │        │ REFERENCE     │
   │ a natural   │       │ track       │        │ DATA          │
   │ value/      │       │ history?    │        │ (Optional     │
   │ effective   │       │             │        │  SCD2)        │
   │ date?       │       │             │        └───────────────┘
   └──────┬──────┘       └──────┬──────┘
          │                     │
     Yes  │                Yes  │
          ▼                     ▼
   ┌─────────────┐       ┌─────────────┐
   │ Is it       │       │ MASTER DATA │
   │ immutable   │       │ (Full SCD2) │
   │ (insert     │       └─────────────┘
   │ only)?      │
   └──────┬──────┘
          │
    ┌─────┴─────┐
    │           │
   Yes          No
    │           │
    ▼           ▼
┌─────────┐  ┌─────────────┐
│ AUDIT/  │  │ TRANSACTION │
│ LOG     │  │ DATA        │
│ DATA    │  │ (No SCD2,   │
│ (No     │  │  use natural│
│  SCD2)  │  │  dates)     │
└─────────┘  └─────────────┘
```

---

## Related Documents

- [SCD2 Implementation Standard](./SCD2-IMPLEMENTATION-STANDARD.md) - Technical implementation details
- [SCD2 Guide](./SCD2-guide.md) - Developer guide with code examples
- [Naming Conventions](./naming-conventions.md) - Field naming standards

---

**Document Owner**: xTalent Architecture Team  
**Review Cycle**: Annual or upon major schema changes
