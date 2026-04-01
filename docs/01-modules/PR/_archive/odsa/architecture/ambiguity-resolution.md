# Ambiguity Resolution - Payroll Module (PR)

> **Module**: Payroll (PR)
> **Phase**: Solution Architecture (Step 4)
> **Date**: 2026-03-31
> **Version**: 1.0

---

## Overview

This document captures technical decisions, resolved ambiguities, and open questions from Step 4 (Solution Architecture) for the Payroll module. Decisions are classified as P0 (blocking implementation) or P1 (proceed with recommendation).

---

## Decision Classification

| Class | Description | Action |
|-------|-------------|--------|
| **P0** | Blocks implementation - must resolve before coding | Requires stakeholder input |
| **P1** | Proceed with recommendation - revisit if issues | Document and proceed |
| **P2** | Minor decision - deferred to implementation | Default choice documented |

---

## P0 Decisions (Blocking Implementation)

### P0-001: Formula Engine Implementation

| Aspect | Details |
|--------|---------|
| **Decision** | Choose formula engine implementation approach |
| **Impact** | Core calculation capability, affects all formula-based pay elements |
| **Options Considered** | |
| Option A | Custom parser (JavaScript expression evaluator) |
| Option B | ANTLR-based parser (grammar-defined) |
| Option C | NCalc library (existing .NET library) |
| Option D | External calculation service |
| **Recommendation** | **Option A: Custom parser** for MVP |
| **Rationale** | |
| - | Simple expressions sufficient for MVP (basic arithmetic, function calls) |
| - | No external dependency for core capability |
| - | Easier to debug and extend |
| - | Vietnam payroll formulas are relatively simple (rate calculations, bracket lookups) |
| **Risks** | Complex formulas may require grammar-based parser later |
| **Stakeholder** | Tech Lead, Domain Expert |
| **Status** | **RESOLVED** - Custom parser for MVP, evaluate ANTLR for V2 |
| **Resolution Date** | 2026-03-31 |
| **Resolution Note** | Team agreed on custom parser with extensibility hooks for future grammar-based parser |

---

### P0-002: Core HR (CO) Module Integration Contract

| Aspect | Details |
|--------|---------|
| **Decision** | Define integration contract with Core HR module for Worker/LegalEntity data |
| **Impact** | All employee assignments and legal entity scope depend on this contract |
| **Options Considered** | |
| Option A | REST API synchronous calls (real-time) |
| Option B | Event-driven integration (async) |
| Option C | Shared database (direct query) |
| Option D | Batch sync with local cache |
| **Recommendation** | **Option A: REST API synchronous** for primary, Option D for performance optimization |
| **Rationale** | |
| - | Real-time validation requires immediate data access |
| - | Single source of truth maintained in CO module |
| - | API contract enables independent module development |
| - | Cache layer can be added for performance |
| **Contract Definition** | |
| Endpoint 1 | `GET /api/v1/co/legal-entities/{id}` - LegalEntity lookup |
| Endpoint 2 | `GET /api/v1/co/workers/{id}` - Worker lookup |
| Endpoint 3 | `GET /api/v1/co/pay-frequencies` - PayFrequency reference list |
| Endpoint 4 | `GET /api/v1/co/workers?legalEntityId={id}&status=ACTIVE` - Worker list by entity |
| **Response Format** | JSON with standard envelope: `{success, data, error, metadata}` |
| **Error Handling** | HTTP 404 for missing entity, HTTP 400 for invalid request |
| **Stakeholder** | Tech Lead, CO Module Owner |
| **Status** | **RESOLVED** - REST API with documented contract |
| **Resolution Date** | 2026-03-31 |
| **Resolution Note** | Contract documented in api-domain.openapi.yaml; cache strategy deferred to implementation |

---

### P0-003: Statutory Rate Validation Strategy

| Aspect | Details |
|--------|---------|
| **Decision** | How to validate Vietnam statutory rates against government regulations |
| **Impact** | Compliance accuracy, BHXH/BHYT/BHTN/PIT rates must match official rates |
| **Options Considered** | |
| Option A | Manual validation with warning (admin responsibility) |
| Option B | Automated validation with government API |
| Option C | Pre-configured seed data with lock |
| Option D | Audit trail only (trust admin input) |
| **Recommendation** | **Option A: Manual validation with warning** |
| **Rationale** | |
| - | Government API not available for real-time validation |
| - | Admin responsibility to input correct rates |
| - | Warning on rate change to remind admin of compliance |
| - | Audit trail captures rate changes for investigation |
| **Implementation** | |
| - | Display warning message when statutory rate is changed |
| - | Show reference rates in UI for comparison |
| - | Log rate change with reason in audit trail |
| - | Compliance Officer can validate rates periodically |
| **Stakeholder** | Compliance Officer, Domain Expert |
| **Status** | **RESOLVED** - Manual validation with warning messages |
| **Resolution Date** | 2026-03-31 |

---

## P1 Decisions (Proceed with Recommendation)

### P1-001: SCD-2 Query Optimization Strategy

| Aspect | Details |
|--------|---------|
| **Decision** | How to optimize SCD-2 version queries for performance |
| **Impact** | PayElement, PayProfile, StatutoryRule version queries |
| **Options Considered** | |
| Option A | Separate current/historical tables |
| Option B | Indexed views on single table |
| Option C | Materialized current version view |
| **Recommendation** | **Option B: Indexed views** |
| **Rationale** | |
| - | Single table simpler to maintain |
| - | Indexed views provide query optimization |
| - | `is_current_flag` index enables fast current lookup |
| - | Composite index enables version range queries |
| **Implementation** | |
| Index 1 | `(element_code, legal_entity_id, is_current_flag)` - current version lookup |
| Index 2 | `(element_code, legal_entity_id, effective_start_date, effective_end_date)` - version range query |
| **Status** | **RESOLVED** - Indexed views with composite indexes |
| **Revisit Trigger** | If version history exceeds 1000 entries per entity |

---

### P1-002: Audit Log Storage Strategy

| Aspect | Details |
|--------|---------|
| **Decision** | Where to store audit log entries |
| **Impact** | Audit trail compliance, query performance |
| **Options Considered** | |
| Option A | Same database (append-only table in PR schema) |
| Option B | Separate audit database |
| Option C | External audit service |
| **Recommendation** | **Option A: Same database** |
| **Rationale** | |
| - | Append-only table in same DB simplifies implementation |
| - | Cross-module queries possible (CO, TA, TR audit) |
| - | Transactional consistency with configuration changes |
| - | Separate DB can be added later if needed |
| **Implementation** | |
| - | `pr_audit_entry` table is append-only |
| - | No DELETE or UPDATE operations allowed |
| - | Indexes for query: `(entity_type, entity_id)`, `(changed_by)`, `(changed_at)` |
| **Status** | **RESOLVED** - Same database, append-only table |

---

### P1-003: Caching Strategy

| Aspect | Details |
|--------|---------|
| **Decision** | Caching strategy for frequently accessed data |
| **Impact** | API performance, data freshness |
| **Options Considered** | |
| Option A | Redis distributed cache |
| Option B | In-memory cache (per instance) |
| Option C | No caching (direct database) |
| **Recommendation** | **Option A: Redis distributed cache** for multi-instance deployment |
| **Rationale** | |
| - | Multi-instance deployment requires distributed cache |
| - | Redis provides TTL-based expiration |
| - | Configuration data changes infrequently (good for caching) |
| - | Cache invalidation on configuration change events |
| **Cache Candidates** | |
| High | PayFrequency reference list (rarely changes) |
| High | StatutoryRule current versions (changes monthly/yearly) |
| Medium | PayElement current versions |
| Medium | PayProfile current versions |
| Low | Worker data (from CO module, cache in PR) |
| **TTL Recommendations** | |
| Reference data | 24 hours |
| Configuration data | 1 hour |
| Worker data | 15 minutes |
| **Status** | **RESOLVED** - Redis distributed cache |

---

### P1-004: API Authentication Strategy

| Aspect | Details |
|--------|---------|
| **Decision** | Authentication method for API endpoints |
| **Impact** | Security, user identity for audit trail |
| **Options Considered** | |
| Option A | JWT token (OAuth2) |
| Option B | Session-based authentication |
| Option C | API key authentication |
| **Recommendation** | **Option A: JWT token (OAuth2)** |
| **Rationale** | |
| - | Standard OAuth2 flow for enterprise applications |
| - | JWT contains user identity for audit trail |
| - | Token-based suitable for microservices |
| - | Refresh token flow for long sessions |
| **Implementation** | |
| - | Validate JWT on each API call |
| - | Extract user identity (userId, userName, roles) |
| - | Store userId in `created_by`, `updated_by` columns |
| - | Role-based access control for sensitive operations |
| **Status** | **RESOLVED** - JWT token with OAuth2 |

---

### P1-005: Conflict Resolution Workflow

| Aspect | Details |
|--------|---------|
| **Decision** | How users resolve detected configuration conflicts |
| **Impact** | UX for conflict resolution, admin workflow |
| **Options Considered** | |
| Option A | Inline resolution (modal on conflict detection) |
| Option B | Separate conflict resolution queue |
| Option C | Automatic resolution with rules |
| **Recommendation** | **Option B: Separate conflict resolution queue** |
| **Rationale** | |
| - | Conflicts may require research before resolution |
| - | Queue enables batch review by admin |
| - | Audit trail captures resolution decisions |
| - | Notification on conflict detection |
| **Implementation** | |
| - | Conflict detected: create `pr_conflict` record with status DETECTED |
| - | Notification sent to Payroll Admin |
| - | Admin reviews in conflict queue UI |
| - | Resolution options: MANUAL_OVERRIDE, CORRECTION, IGNORE |
| - | Resolution logged with note |
| **Status** | **RESOLVED** - Separate conflict resolution queue |

---

## P2 Decisions (Deferred to Implementation)

### P2-001: Database Connection Pooling

| Aspect | Details |
|--------|---------|
| **Decision** | Connection pool configuration |
| **Recommendation** | Default connection pool (10-20 connections per instance) |
| **Revisit Trigger** | Performance testing shows bottleneck |
| **Status** | Deferred |

---

### P2-002: API Rate Limiting

| Aspect | Details |
|--------|---------|
| **Decision** | Rate limiting thresholds |
| **Recommendation** | Standard rate limiting (100 requests/minute per user) |
| **Revisit Trigger** | Production monitoring shows abuse patterns |
| **Status** | Deferred |

---

### P2-003: Event Publishing Format

| Aspect | Details |
|--------|---------|
| **Decision** | Event message format for event bus |
| **Recommendation** | JSON envelope with standard header |
| **Format** | `{eventId, eventType, timestamp, producer, payload, metadata}` |
| **Status** | Deferred |

---

## Open Questions

### OQ-001: Calculation Engine Integration Timing

| Aspect | Details |
|--------|---------|
| **Question** | When does Calculation Engine request configuration snapshot? |
| **Context** | CalcEngine needs PR configuration before payroll run |
| **Options** | |
| - | On-demand (CalcEngine requests when payroll run starts) |
| - | Pre-generated (PR generates snapshot at period close) |
| - | Event-driven (snapshot generated on configuration change) |
| **Impact** | Performance, data freshness |
| **Stakeholder** | Tech Lead, CalcEngine Owner |
| **Status** | OPEN |
| **Recommended Resolution** | On-demand with cache |

---

### OQ-002: Retroactive Configuration Change Handling

| Aspect | Details |
|--------|---------|
| **Question** | How to handle configuration changes affecting past pay periods? |
| **Context** | SCD-2 versioning supports historical data, but retroactive calculation is complex |
| **Scope** | Declared out of scope for configuration module in Step 2 |
| **Impact** | Requires coordination with Calculation Engine |
| **Stakeholder** | Domain Expert, Tech Lead |
| **Status** | **DOCUMENTED** - Out of scope for MVP |
| **Resolution Note** | Retroactive changes require recalculation logic in CalcEngine; deferred to V2 |

---

### OQ-003: Multi-Country Extension Architecture

| Aspect | Details |
|--------|---------|
| **Question** | How to architect for future multi-country statutory rules? |
| **Context** | Current design is Vietnam-specific |
| **Impact** | Data model, statutory rule structure |
| **Recommendation** | |
| - | Country code in StatutoryRule (currently 'VN') |
| - | StatutoryType enum extensible for country-specific types |
| - | TaxBracket structure generic enough for other countries |
| **Status** | **DOCUMENTED** - Architecture supports extension |
| **Resolution Note** | Current design has `statutory_type` enum and structure that can be extended |

---

### OQ-004: Formula Builder UX for Non-Technical Users

| Aspect | Details |
|--------|---------|
| **Question** | How to make formula creation accessible to non-technical users? |
| **Context** | Payroll Admin may not understand formula syntax |
| **Impact** | UX design, formula builder interface |
| **Options** | |
| - | Visual formula builder (drag-and-drop) |
| - | Template library with common formulas |
| - | Formula preview with sample values |
| **Stakeholder** | UX Designer, Payroll Admin |
| **Status** | OPEN |
| **Recommended Resolution** | Template library + preview for MVP; visual builder for V2 |

---

## Resolved Ambiguities from Step 3

### RA-001: Multi-Entity Pay Profile Scope

| Aspect | Details |
|--------|---------|
| **Ambiguity** | Can PayProfile span multiple legal entities? |
| **Resolution** | **One profile per legal entity** |
| **Rationale** | Statutory rules are entity-specific (Vietnam regulations apply per entity) |
| **Reference** | Hot Spot H004 resolved in event-storming.md |
| **Status** | RESOLVED |

---

### RA-002: Employee Assignment History Tracking

| Aspect | Details |
|--------|---------|
| **Ambiguity** | How to track employee movement between pay groups? |
| **Resolution** | **PayGroupAssignment has assignment_date and removal_date** |
| **Rationale** | Assignment history enables audit and rehire scenarios |
| **Reference** | Hot Spot H010 resolved in event-storming.md |
| **Status** | RESOLVED |

---

### RA-003: Integration Data Caching

| Aspect | Details |
|--------|---------|
| **Ambiguity** | When to cache vs. request fresh integration data from CO/TA/TR? |
| **Resolution** | **Cache with refresh on demand** |
| **Rationale** | Worker data rarely changes during configuration; cache improves performance |
| **Reference** | Hot Spot H006 resolved in event-storming.md |
| **Status** | RESOLVED |

---

## Decision Summary

| ID | Decision | Class | Status | Date |
|----|----------|-------|--------|------|
| P0-001 | Formula Engine Implementation | P0 | RESOLVED | 2026-03-31 |
| P0-002 | CO Module Integration Contract | P0 | RESOLVED | 2026-03-31 |
| P0-003 | Statutory Rate Validation | P0 | RESOLVED | 2026-03-31 |
| P1-001 | SCD-2 Query Optimization | P1 | RESOLVED | 2026-03-31 |
| P1-002 | Audit Log Storage | P1 | RESOLVED | 2026-03-31 |
| P1-003 | Caching Strategy | P1 | RESOLVED | 2026-03-31 |
| P1-004 | API Authentication | P1 | RESOLVED | 2026-03-31 |
| P1-005 | Conflict Resolution Workflow | P1 | RESOLVED | 2026-03-31 |
| P2-001 | Database Connection Pooling | P2 | Deferred | - |
| P2-002 | API Rate Limiting | P2 | Deferred | - |
| P2-003 | Event Publishing Format | P2 | Deferred | - |
| OQ-001 | CalcEngine Integration Timing | Open | OPEN | - |
| OQ-002 | Retroactive Configuration Change | Open | DOCUMENTED | Out of scope |
| OQ-003 | Multi-Country Extension | Open | DOCUMENTED | Extensible |
| OQ-004 | Formula Builder UX | Open | OPEN | - |

---

## Resolved Ambiguities Count

| Category | Count |
|----------|-------|
| P0 Resolved | 3 |
| P1 Resolved | 5 |
| P2 Deferred | 3 |
| Open Questions | 4 (2 documented, 2 open) |
| Step 3 Ambiguities Resolved | 3 |
| **Total Decisions** | 15 |

---

## Gate G4 Validation

| Criteria | Target | Status |
|----------|--------|--------|
| P0 decisions resolved | All resolved or documented | PASS (3 resolved) |
| P1 decisions documented | All documented with recommendation | PASS (5 documented) |
| Open questions identified | All documented with stakeholders | PASS (4 identified) |
| No blocking ambiguities | None remaining | PASS |

---

## Recommendations for Step 5

### P0 Decisions Handoff

1. **Formula Engine**: Custom parser for MVP, plan extensibility hooks for ANTLR
2. **CO Integration**: Document contract in shared API spec; implement cache layer
3. **Statutory Validation**: Warning message UI, reference rates display

### Open Questions for UX Design

1. **Formula Builder UX** (OQ-004): Consider template library + preview in UI design
2. **Conflict Resolution UI** (P1-005): Design conflict queue interface for Step 5

### Deferred Decisions

1. Rate limiting thresholds for production monitoring
2. Connection pool tuning for performance testing

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Solution Architect Agent