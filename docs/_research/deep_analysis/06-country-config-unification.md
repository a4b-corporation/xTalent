# Country & Holiday Configuration Unification

**Scope**: Consolidate fragmented country/holiday config into single source  
**Assessed**: 2026-03-16

---

## 1. Current State — 4+ Sources

### 1.1 Country/Market Data Sources

| # | Location | Entity | Fields | Used by |
|:-:|----------|--------|--------|---------|
| 1 | **Core** | `geo.country` | code_alpha2, name, region | All modules |
| 2 | **Core** | `common.talent_market` | code, country_code, currency_code | Core, TR |
| 3 | **Core** | `common.talent_market_parameter` | talent_market_id, max_si_basis, min_wage | Core |
| 4 | **TR** | `comp_core.country_config` | country_code, currency, tax_system, si_system, working_hours/days | TR |

### 1.2 Holiday Data Sources

| # | Location | Entity | Fields | Used by |
|:-:|----------|--------|--------|---------|
| 5 | **TA** | `absence.holiday_calendar` + `absence.holiday_date` | calendar per region, date + name | Absence |
| 6 | **TA** | `shared.holiday` | calendar_id, date, recurring, half_day | Shared TA |
| 7 | **TR** | `comp_core.holiday_calendar` | country_code, year, date, type, ot_multiplier | TR calc |

### 1.3 Problems

```
Problem 1: "What are the working hours/days for Vietnam?"
  → Core: talent_market_parameter has min_wage, SI caps — NOT working hours
  → TR: country_config has standard_working_hours_per_day = 8
  → PR: (nothing — relies on hardcoded or TR query)
  → TA: (nothing — uses shift definitions)

Problem 2: "Is March 15 a holiday?"
  → TA: Query absence.holiday_date WHERE calendar_id = ?
  → TR: Query comp_core.holiday_calendar WHERE country_code = 'VN'
  → PR: (nothing — can't determine OT multiplier independently)

Problem 3: "What's the OT rate for working on a holiday?"
  → TR: comp_core.holiday_calendar.ot_multiplier
  → PR: Drools rules (hardcoded multipliers per rule)
  → TA: (not tracked — just knows it's holiday)
```

---

## 2. Target State — Unified Configuration

### 2.1 Design: Core as Single Source

```
Core Module (Single Source of Truth)
│
├── geo.country (existing ✅)
│   └── ISO-3166 country master data
│
├── common.talent_market (existing ✅)
│   └── Market definition (1 country → N markets)
│
├── common.country_config [MOVE from TR] 
│   ├── country_code (FK → geo.country)
│   ├── currency_code
│   ├── tax_system: PROGRESSIVE | FLAT | DUAL
│   ├── si_system: MANDATORY | OPTIONAL | HYBRID
│   ├── standard_working_hours_per_day: 8
│   ├── standard_working_days_per_week: 5
│   ├── standard_working_days_per_month: 22
│   ├── config_json: { ... country-specific ... }
│   └── is_active
│
├── common.talent_market_parameter (existing ✅)
│   └── Market-specific: max_si_basis, min_wage
│
└── common.holiday_calendar [CONSOLIDATE]
    ├── country_code (FK → geo.country)
    ├── jurisdiction (state/province)
    ├── year, holiday_date, holiday_name
    ├── holiday_type: NATIONAL | REGIONAL | BANK | OPTIONAL
    ├── is_paid, is_half_day, is_recurring
    └── ot_multiplier: decimal(4,2)
```

### 2.2 Module Consumption

```
                    Core
                    ├── common.country_config
                    └── common.holiday_calendar
                         │
        ┌────────────────┼─────────────────┐
        ▼                ▼                 ▼
    TA Module         TR Module         PR Module
    │                 │                 │
    │ Holiday check   │ Proration calc  │ OT multiplier
    │ for leave       │ Country params  │ Working days
    │ calendar        │ Statement data  │ Tax/SI params
    │                 │                 │
    └── READ only     └── READ only     └── READ only
```

---

## 3. Migration Plan

### Phase 1: Create Target Tables in Core (0.5 sprint)

**New `common.country_config`** (moved from TR `comp_core.country_config`):

```dbml
Table common.country_config {
  id              uuid [pk]
  country_code    char(2) [unique, not null, ref: > geo.country.code_alpha2]
  country_name    varchar(100) [not null]
  currency_code   char(3) [not null]
  
  tax_system      varchar(30)     // PROGRESSIVE | FLAT | DUAL
  si_system       varchar(30)     // MANDATORY | OPTIONAL | HYBRID
  
  standard_working_hours_per_day   int [default:8]
  standard_working_days_per_week   int [default:5]
  standard_working_days_per_month  int [default:22]
  
  config_json     jsonb [null]    // Country-specific settings
  is_active       boolean [default:true]
  
  created_at      timestamp [default:`now()`]
  updated_at      timestamp [null]
  
  Indexes { (country_code), (is_active) }
}
```

**New `common.holiday_calendar`** (merged from TR + TA):

```dbml
Table common.holiday_calendar {
  id              uuid [pk]
  country_code    char(2) [not null, ref: > geo.country.code_alpha2]
  jurisdiction    varchar(50) [null]   // State/Province
  
  year            int [not null]
  holiday_date    date [not null]
  holiday_name    varchar(200) [not null]
  holiday_type    varchar(30)          // NATIONAL | REGIONAL | BANK | OPTIONAL
  
  is_paid         boolean [default:true]
  is_half_day     boolean [default:false]
  is_recurring    boolean [default:false]
  ot_multiplier   decimal(4,2) [null]  // OT rate if work on holiday (e.g., 3.0)
  
  metadata        jsonb [null]
  created_at      timestamp [default:`now()`]
  
  Indexes { 
    (country_code, year, holiday_date) [unique],
    (country_code, jurisdiction, year),
    (holiday_date),
    (year)
  }
}
```

### Phase 2: Data Migration + Deprecation (0.5 sprint)

1. **Migrate TR data**: Copy `comp_core.country_config` → `common.country_config`
2. **Merge holidays**: Merge `comp_core.holiday_calendar` + `absence.holiday_calendar/date` → `common.holiday_calendar`
3. **Deprecate**: Mark TR/TA originals as deprecated
4. **Update FKs**: TA `absence.leave_type.support_scope` → reference `common.country_config`

### Phase 3: Module Updates (per module)

| Module | Change | Effort |
|--------|--------|:------:|
| TA | Replace `absence.holiday_calendar/date` refs → `common.holiday_calendar` | 0.5 sprint |
| TR | Replace `comp_core.country_config/holiday_calendar` → read from Core | 0.5 sprint |
| PR | Add FK to `common.country_config` + `common.holiday_calendar` | 0.5 sprint |
| TA shared | Deprecate `shared.holiday`, `shared.period_profile` → reference Core | 0.5 sprint |

---

## 4. Relationship: Talent Market vs Country Config

```
geo.country (VN)
  ├── common.country_config (1:1)
  │     └── Working hours, tax/SI system type
  │
  └── common.talent_market (1:N — multiple markets per country)
        ├── VN_HCM (Ho Chi Minh market)
        │     └── talent_market_parameter: min_wage=zone1, SI caps
        ├── VN_HN (Ha Noi market)  
        │     └── talent_market_parameter: min_wage=zone1, SI caps
        └── VN_RURAL (Regional market)
              └── talent_market_parameter: min_wage=zone4, SI caps
```

- `country_config`: Country-wide constants (working hours, tax system type)
- `talent_market_parameter`: Market-specific parameters (min wage by zone, SI cap amounts)

→ **Not overlapping** — different granularity levels. Both needed.

---

## 5. Impact Summary

| Total Effort | 2 sprints |
|:------------:|:---------:|
| Core additions | 0.5 sprint |
| Data migration | 0.5 sprint |
| Module updates | 1 sprint (TA + TR + PR parallel) |

**Benefits**:
- ✅ Single source of truth for holiday data
- ✅ All modules can determine OT multipliers independently
- ✅ PR can do proration without querying TR
- ✅ TA/Absence can check holidays without separate calendar
- ✅ Eliminates 3 duplicates → 1 canonical source

---

*← [05 Eligibility Consolidation](./05-eligibility-consolidation.md) · [07 TR-PR Boundary Resolution →](./07-tr-pr-boundary-resolution.md)*
