# Schema Improvement Roadmap — Prioritized

**Scope**: Consolidated roadmap from all module analyses  
**Assessed**: 2026-03-16

---

## 1. Executive Summary

| Module | Current Score | After Wave 1 | After Wave 2 | After Wave 3 |
|--------|:------------:|:------------:|:------------:|:------------:|
| **Core (CO)** | 4.2/5 | 4.5/5 | 4.8/5 | 4.9/5 |
| **Time & Absence (TA)** | 3.8/5 | 4.2/5 | 4.5/5 | 4.7/5 |
| **Total Rewards (TR)** | 3.9/5 | 4.3/5 | 4.6/5 | 4.8/5 |
| **Payroll (PR)** | 3.3/5 | 4.0/5 | 4.5/5 | 5.0/5 |
| **Cross-Module** | 2.5/5 | 3.5/5 | 4.5/5 | 5.0/5 |

---

## 2. Wave 1 — Foundation Fix (4-5 sprints)

> **Goal**: Clear boundaries, fix critical gaps, no architecture change

### 2.1 Cross-Module Decisions (Discussion — 1 week)

| # | Decision | Recommendation | Impact |
|:-:|----------|----------------|:------:|
| D1 | PR owns calculation logic | **Yes** (Option B, score 4.20/5) | TR, PR |
| D2 | Eligibility consolidated to Core | **Yes** — migrate TR benefit.eligibility | All |
| D3 | Country config at Core | **Yes** — move comp_core.country_config | All |
| D4 | Holiday calendar unified at Core | **Yes** — single common.holiday_calendar | All |
| D5 | compensation.basis stays in Core | **Yes** — rename schema to `emp_comp` | CO, TR |

### 2.2 PR Schema Enrichment (2 sprints)

| # | Task | Effort | From |
|:-:|------|:------:|:----:|
| P1 | Enrich `pay_element`: add tax_treatment, proration_method, si_basis, tax_exempt_cap, calculation_method | 1 sprint | Doc 04 |
| P2 | Upgrade classifications: 3 → 6+ types (BASE, ALLOWANCE, BONUS, OT, EMPLOYER, INFORMATIONAL) | 0.5 sprint | Doc 04 |
| P3 | Add `pay_master.country_config` | 0.5 sprint | Doc 06 |
| P4 | Add `pay_master.holiday_calendar` (or reference Core) | 0.5 sprint | Doc 06 |
| P5 | Decimal precision: `decimal(18,2)` → `decimal(18,4)` | 0.5 sprint | Doc 04 |

### 2.3 TR Boundary Correction (1 sprint)

| # | Task | Effort | From |
|:-:|------|:------:|:----:|
| T1 | Re-scope `calculation_rule_def` → component behavior config only | 0.5 sprint | Doc 07 |
| T2 | Deprecate `basis_calculation_rule` | 0.5 sprint | Doc 07 |
| T3 | Re-scope `component_calculation_rule` → behavior mapping | 0.5 sprint | Doc 07 |
| T4 | Move `tax_calculation_cache` → PR | 0.5 sprint | Doc 07 |

### 2.4 TA Cleanup (1 sprint)

| # | Task | Effort | From |
|:-:|------|:------:|:----:|
| A1 | Remove `_DUPLICATE` tables, rename to canonical | 0.5 sprint | Doc 02 |
| A2 | Archive standalone `3.Absence.v4.dbml` | Trivial | Doc 02 |
| A3 | Add `ta.payroll_summary` for PR consumption | 0.5 sprint | Doc 02 |

### 2.5 Core Additions (1 sprint)

| # | Task | Effort | From |
|:-:|------|:------:|:----:|
| C1 | Create `common.country_config` (moved from TR) | 0.5 sprint | Doc 06 |
| C2 | Create `common.holiday_calendar` (consolidated) | 0.5 sprint | Doc 06 |
| C3 | Extend eligibility domains (TIME_ATTENDANCE, RECOGNITION, PAYROLL) | 0.5 sprint | Doc 05 |

---

## 3. Wave 2 — Integration & API (5-6 sprints)

> **Goal**: Formal API contracts, event-driven architecture, eligibility migration

### 3.1 Eligibility Migration (2 sprints)

| # | Task | Effort | From |
|:-:|------|:------:|:----:|
| E1 | Migrate TR `benefit.eligibility_profile` → Core engine | 1 sprint | Doc 05 |
| E2 | Update TR benefit.plan FKs → Core eligibility | 0.5 sprint | Doc 05 |
| E3 | Deprecate TR eligibility tables | 0.5 sprint | Doc 05 |

### 3.2 PR API Contract (3 sprints)

| # | Task | Effort | From |
|:-:|------|:------:|:----:|
| R1 | Define OpenAPI spec (~28 endpoints) | 2 sprints | Doc 04 (PR research) |
| R2 | Implement compensation snapshot input API (TR→PR) | 1 sprint | Doc 07, 08 |
| R3 | Implement attendance input API (TA→PR) | 1 sprint | Doc 08 |
| R4 | Implement DryRun/Preview API (for TR Offer/Statement) | 1 sprint | Doc 07 |

### 3.3 PR Schema Enrichment Level 2 (2 sprints)

| # | Task | Effort | From |
|:-:|------|:------:|:----:|
| S1 | Enrich `pay_profile`: element ordering, mandatory flags, rule binding | 1 sprint | Doc 04 |
| S2 | Structure `statutory_rule`: rule_category, version tracking, legal_reference | 1 sprint | Doc 04 |
| S3 | Add `pay_staging.*` input staging schema | 1 sprint | Doc 04 |

### 3.4 Event Architecture (1 sprint)

| # | Task | Effort | From |
|:-:|------|:------:|:----:|
| V1 | Define AsyncAPI spec (9 published + 7 consumed events) | 1 sprint | Doc 08 |
| V2 | Implement core event handlers | 1 sprint | Doc 08 |

### 3.5 Naming Convention Rollout (1 sprint)

| # | Task | Effort | From |
|:-:|------|:------:|:----:|
| N1 | Apply naming standards to all modules | 1 sprint | Doc 09 |

---

## 4. Wave 3 — Headless & Scale (6-8 sprints, future)

> **Goal**: PR as standalone service, multi-tenant, full independence

| # | Task | Effort | From |
|:-:|------|:------:|:----:|
| H1 | Independent PR database instance | 1 sprint | Doc 04 |
| H2 | Multi-tenant support | 2 sprints | Doc 04 |
| H3 | API versioning infrastructure | 1 sprint | Doc 04 |
| H4 | Client SDK generation | 1 sprint | Doc 04 |
| H5 | Core: split 1759-line DBML → 7 files | 0.5 sprint | Doc 01 |
| H6 | Core: add explicit entities (probation, termination, emergency_contact, cost_center) | 2 sprints | Doc 01 |
| H7 | TR: add enrollment_dependent for family coverage | 1 sprint | Doc 03 |
| H8 | TA: materialized view `employee_daily_schedule` | 1 sprint | Doc 02 |
| H9 | Service mesh (health check, circuit breaker) | 1 sprint | Doc 04 |

---

## 5. Timeline View

```
Month 1-2: Wave 1 (Foundation Fix)
  ├── Week 1: Decisions (D1-D5)
  ├── Week 2-5: PR enrichment (P1-P5)
  ├── Week 3-4: TR re-scope (T1-T4)
  ├── Week 3-4: TA cleanup (A1-A3)
  └── Week 4-5: Core additions (C1-C3)

Month 3-5: Wave 2 (Integration & API)
  ├── Month 3: Eligibility migration (E1-E3) + API spec (R1)
  ├── Month 4: PR API implementation (R2-R4) + staging (S3)
  └── Month 5: Schema enrichment (S1-S2) + events (V1-V2) + naming (N1)

Month 6+: Wave 3 (Headless — as needed)
  └── Phased rollout per business priority
```

---

## 6. Risk Register

| Risk | Prob | Impact | Mitigation | Wave |
|------|:----:|:------:|------------|:----:|
| TR team pushback on losing calc ownership | High | High | Frame as "re-scope", TR keeps component config | W1 |
| Data migration errors (eligibility) | Med | High | Run both systems in parallel, validate | W2 |
| API design changes after implementation | Med | Med | Prototype with DryRun first | W2 |
| Naming changes break existing code | Low | High | Database migration scripts, no column renames initially | W2 |
| PR multi-tenant complexity | Med | Med | Design first (ADR), implement in controlled phases | W3 |

---

## 7. Success Metrics

| Metric | Current | After Wave 1 | After Wave 2 | Target |
|--------|:-------:|:------------:|:------------:|:------:|
| Duplicate entities across modules | 5+ | 2 | 0 | 0 |
| PR independence score | 1.5/5 | 2.5/5 | 4.0/5 | 5.0/5 |
| Cross-module API coverage | 0% | 20% | 80% | 100% |
| Naming convention compliance | ~60% | ~60% | ~95% | 100% |
| Holiday calendar sources | 3 | 1 | 1 | 1 |
| Average module design score | 3.8 | 4.3 | 4.6 | 4.8+ |

---

*← [09 Naming Convention Standard](./09-naming-convention-standard.md) · [00 Deep Analysis Plan](./00-deep-analysis-plan.md)*
