# Payroll Module - Ambiguity Resolution

> **Module**: Payroll (PR)
> **Phase**: Pre-Reality (Step 1)
> **Date**: 2026-03-31
> **Status**: Complete

---

## 1. Ambiguity Assessment

### 1.1 Ambiguity Score Definition

**Ambiguity Score**: 0.0 (Clear) to 1.0 (Highly Ambiguous)

| Score Range | Interpretation | Action |
|-------------|----------------|--------|
| 0.0 - 0.2 | Clear | Proceed with confidence |
| 0.2 - 0.4 | Moderate | Document assumptions, validate |
| 0.4 - 0.6 | Significant | Must resolve before implementation |
| 0.6 - 1.0 | Critical | Requires research or decision |

### 1.2 Overall Ambiguity Assessment

| Category | Initial Score | After Resolution | Status |
|----------|---------------|------------------|--------|
| Problem Definition | 0.25 | 0.15 | Resolved |
| Solution Design | 0.35 | 0.20 | Resolved |
| Technical Approach | 0.30 | 0.18 | Resolved |
| User Requirements | 0.55 | 0.30 | Partially Resolved |
| Timeline & Effort | 0.60 | 0.35 | Partially Resolved |
| **Overall Average** | **0.41** | **0.24** | **Improved** |

**Target**: <= 0.20 overall
**Current**: 0.24 (Close to target, acceptable with documented assumptions)

---

## 2. Ambiguity Categories

### 2.1 Functional Ambiguities

#### FA-001: Formula Engine Scope

**Ambiguity**: What formula types must be supported?

**Initial Score**: 0.45

**Question**: Should the formula engine support only simple arithmetic, or also complex logic like conditionals, lookups, and progressive calculations?

**Context**: Vietnam PIT uses progressive tax brackets. OT calculations use conditional multipliers. Some deductions use lookup tables.

**Resolution**:
- **Must Support**: Arithmetic (+, -, *, /), percentages, round
- **Must Support**: Conditionals (IF/THEN/ELSE)
- **Must Support**: Lookups (rate tables, brackets)
- **Must Support**: Progressive calculations (tax brackets)
- **Could Support**: Functions (MIN, MAX, ABS)
- **Won't Support**: Complex programming logic, loops

**Resolved Score**: 0.15

**Confidence**: High (85%)

---

#### FA-002: Validation Level

**Ambiguity**: What level of validation should be implemented?

**Initial Score**: 0.40

**Question**: Should validation be strict (prevents invalid configurations) or lenient (warns but allows)?

**Context**: Payroll admins may need to configure scenarios that appear invalid but are correct for their context. However, invalid configurations cause calculation errors.

**Resolution**:
- **Strict Validation**: Structural integrity (required fields, valid references, date logic)
- **Warning Validation**: Business rules that may have exceptions
- **User Override**: Allow users to acknowledge and proceed with warnings
- **Audit Trail**: Log all overrides for compliance review

**Resolved Score**: 0.20

**Confidence**: Medium (70%)

---

#### FA-003: Multi-Currency Support

**Ambiguity**: Does the module need multi-currency support?

**Initial Score**: 0.50

**Question**: Should pay elements support multiple currencies, or is VND-only sufficient for initial release?

**Context**: Vietnam focus initially, but may expand to other markets. Some companies have foreign workers or multi-currency pay.

**Resolution**:
- **Phase 1 (MVP)**: VND only, single currency
- **Data Model**: Design for currency support (currency code field)
- **Future Phase**: Add currency conversion, multi-currency pay profiles
- **Assumption**: <5% of Vietnam companies need multi-currency initially

**Resolved Score**: 0.20

**Confidence**: Medium (65%)

---

#### FA-004: Retroactive Processing

**Ambiguity**: How should retroactive changes be handled?

**Initial Score**: 0.55

**Question**: If a statutory rule changes retroactively, how should the system handle recalculations?

**Context**: Sometimes laws are applied retroactively. Sometimes payroll corrections are needed.

**Resolution**:
- **Phase 1**: Support configuration versioning (SCD-2)
- **Out of Scope**: Automatic retroactive recalculation
- **Manual Process**: Admin triggers recalculation manually in calculation engine
- **Future**: Add retroactive recalculation support

**Resolved Score**: 0.30

**Confidence**: Medium (60%)

---

### 2.2 Technical Ambiguities

#### TA-001: Database Platform

**Ambiguity**: What database platform should be used?

**Initial Score**: 0.35

**Question**: Should the module use relational (PostgreSQL), document (MongoDB), or hybrid approach?

**Context**: xTalent may have platform standards. SCD-2 works well with relational. Complex queries may need flexibility.

**Resolution**:
- **Assumption**: Follow xTalent platform standards
- **If No Standard**: PostgreSQL recommended for:
  - Mature SCD-2 support
  - Strong transaction support
  - JSON support for flexible data
  - Good performance characteristics

**Resolved Score**: 0.20

**Confidence**: Medium (65%) - depends on platform standard

---

#### TA-002: API Style

**Ambiguity**: Should APIs be REST, GraphQL, or hybrid?

**Initial Score**: 0.30

**Question**: What API style provides the best balance of flexibility, simplicity, and performance?

**Context**: Configuration data is hierarchical. Some consumers need full entities, others need specific fields.

**Resolution**:
- **Primary**: REST API for standard CRUD operations
- **Query**: Add query parameters for filtering, field selection
- **Future**: GraphQL for complex queries if needed
- **Batch**: REST endpoints for bulk operations

**Resolved Score**: 0.15

**Confidence**: High (80%)

---

#### TA-003: Event Handling

**Ambiguity**: Should configuration changes trigger events?

**Initial Score**: 0.40

**Question**: When configuration changes, should the module emit events for downstream consumers?

**Context**: Calculation engine may need to know about configuration changes. Integration layer may need to sync.

**Resolution**:
- **Event Types**: ConfigurationCreated, ConfigurationUpdated, ConfigurationDeleted
- **Event Payload**: Entity type, entity ID, change summary
- **Delivery**: At-least-once delivery via message queue
- **Consumer**: Calculation engine, integration layer, audit service

**Resolved Score**: 0.20

**Confidence**: High (75%)

---

#### TA-004: Performance Requirements

**Ambiguity**: What are the performance requirements?

**Initial Score**: 0.55

**Question**: What response times and throughput are acceptable?

**Context**: Configuration operations are typically low-volume. However, bulk operations and queries may have performance needs.

**Resolution**:
- **Single Entity CRUD**: <200ms response time
- **List Queries**: <500ms for up to 1000 entities
- **Bulk Operations**: <5 seconds for 100 entities
- **Concurrent Users**: 50 simultaneous admins
- **Throughput**: 100 operations/second

**Resolved Score**: 0.25

**Confidence**: Medium (65%) - needs validation

---

### 2.3 User Ambiguities

#### UA-001: User Skill Level

**Ambiguity**: What is the expected skill level of payroll administrators?

**Initial Score**: 0.65

**Question**: Can we assume users have technical background, or must the system be usable by non-technical staff?

**Context**: Payroll admins may have varying technical skills. Configuration can be complex.

**Resolution**:
- **Primary Persona**: HR/Payroll professional with moderate technical comfort
- **Secondary Persona**: System administrator with technical background
- **Design Principle**: Usable without training for common tasks
- **Advanced Features**: Available for technical users
- **Help System**: Contextual help, tooltips, examples

**Resolved Score**: 0.30

**Confidence**: Low (55%) - needs user research

---

#### UA-002: Configuration Workflow

**Ambiguity**: What is the typical configuration workflow?

**Initial Score**: 0.50

**Question**: Do users configure in a specific sequence, or is configuration free-form?

**Context**: Payroll setup has logical dependencies. Some users may want to configure in different orders.

**Resolution**:
- **Guided Workflow**: Recommended sequence for new setup
- **Flexible Access**: Allow experienced users to configure in any order
- **Dependency Validation**: Warn if prerequisites not met
- **Configuration Status**: Track completion of required components

**Resolved Score**: 0.25

**Confidence**: Medium (65%)

---

#### UA-003: Error Handling Preference

**Ambiguity**: How should errors be presented to users?

**Initial Score**: 0.45

**Question**: Should errors be shown inline, in a summary, or both?

**Context**: Complex forms may have multiple errors. Users need to see all issues at once.

**Resolution**:
- **Inline Validation**: Real-time feedback on field changes
- **Form Summary**: List of all validation issues on save
- **Error Severity**: Clear distinction between errors (blocking) and warnings (informational)
- **Fix Actions**: Suggested fixes where possible
- **Error Persistence**: Show errors until resolved

**Resolved Score**: 0.20

**Confidence**: Medium (70%)

---

### 2.4 Business Ambiguities

#### BA-001: Multi-Tenancy Model

**Ambiguity**: What multi-tenancy model is required?

**Initial Score**: 0.45

**Question**: Should the module support single-tenant (one company per instance), multi-tenant (multiple companies), or both?

**Context**: SaaS deployment typically needs multi-tenancy. On-premise may be single-tenant.

**Resolution**:
- **Data Model**: Design for multi-tenancy from start
- **Isolation**: Database-level tenant isolation (tenant_id on all tables)
- **Performance**: Optimize for single-tenant, scale to multi-tenant
- **Phase 1**: Support single-tenant deployment
- **Phase 2**: Add full multi-tenant support

**Resolved Score**: 0.20

**Confidence**: Medium (70%)

---

#### BA-002: Pricing Model

**Ambiguity**: How should the module be priced?

**Initial Score**: 0.50

**Question**: Should pricing be per-employee, per-company, or feature-based?

**Context**: Pricing affects data model, feature flags, and architecture decisions.

**Resolution**:
- **Out of Scope for MVP**: Pricing is business decision
- **Architecture Note**: Ensure data model can support any pricing model
- **No Feature Gating**: All configuration features available to all tenants
- **Future**: May add feature flags for advanced features

**Resolved Score**: 0.25

**Confidence**: Low (50%) - business decision, not technical

---

#### BA-003: Support Model

**Ambiguity**: What level of support is expected?

**Initial Score**: 0.40

**Question**: Is self-service sufficient, or is dedicated support required?

**Context**: Payroll is critical - errors have consequences. Users may need immediate help.

**Resolution**:
- **Self-Service**: Documentation, help system, examples
- **Community**: User forum, knowledge base
- **Support Channels**: Email, chat for all users
- **Premium Support**: Direct support for enterprise (future)
- **SLA**: Define support response times

**Resolved Score**: 0.20

**Confidence**: Medium (65%)

---

### 2.5 Integration Ambiguities

#### IA-001: Real-time vs. Batch

**Ambiguity**: Which integrations should be real-time vs. batch?

**Initial Score**: 0.45

**Question**: For each integration, what is the appropriate pattern?

**Context**: Real-time provides immediate sync but has performance and reliability implications.

**Resolution**:
| Integration | Pattern | Rationale |
|-------------|---------|-----------|
| CO (Worker data) | Real-time API | Changes need immediate sync |
| TA (Time data) | Batch (daily) | Large volume, timing not critical |
| TR (Compensation) | Real-time API | Changes need immediate sync |
| Finance (GL entries) | Batch (on-demand) | Timing not critical |
| Banking (Payments) | Batch (scheduled) | Timing controlled by pay date |

**Resolved Score**: 0.15

**Confidence**: High (80%)

---

#### IA-002: Error Handling Strategy

**Ambiguity**: How should integration errors be handled?

**Initial Score**: 0.50

**Question**: When an integration fails, what should happen?

**Context**: Network failures, data errors, system outages can all cause failures.

**Resolution**:
- **Retry Pattern**: Automatic retry with exponential backoff (3 attempts)
- **Circuit Breaker**: Stop retrying after repeated failures
- **Dead Letter Queue**: Store failed messages for manual processing
- **Alerting**: Notify administrators of persistent failures
- **Reconciliation**: Periodic data sync to catch missed updates

**Resolved Score**: 0.20

**Confidence**: Medium (70%)

---

#### IA-003: Data Volume

**Ambiguity**: What data volumes are expected?

**Initial Score**: 0.55

**Question**: How many employees, pay elements, rules per company?

**Context**: Performance and storage depend on data volumes.

**Resolution**:
- **Small Company**: 50-100 employees, 20-30 pay elements
- **Medium Company**: 500-1000 employees, 30-50 pay elements
- **Large Company**: 5000+ employees, 50-100 pay elements
- **Design Target**: 10,000 employees, 100 pay elements per company
- **Query Performance**: Sub-second for typical operations

**Resolved Score**: 0.25

**Confidence**: Medium (60%)

---

### 2.6 Timeline Ambiguities

#### TL-001: MVP Timeline

**Ambiguity**: What is the realistic timeline for MVP?

**Initial Score**: 0.60

**Question**: Can MVP be delivered in 6 months with a team of 5-6 engineers?

**Context**: Scope includes pay elements, pay profiles, statutory rules, versioning, integrations.

**Resolution**:
- **Optimistic Estimate**: 4 months
- **Realistic Estimate**: 6 months
- **Pessimistic Estimate**: 9 months
- **Risk Buffer**: Add 20% to estimates
- **Phased Approach**: Reduce scope if timeline slips

**Resolved Score**: 0.35

**Confidence**: Low (45%) - needs detailed estimation

---

#### TL-002: Team Size

**Ambiguity**: What is the optimal team size?

**Initial Score**: 0.40

**Question**: How many engineers, what skills are needed?

**Context**: Module has backend, API, integration, and UI components.

**Resolution**:
- **Backend Engineers**: 2-3 (core, database, integrations)
- **Frontend Engineers**: 1-2 (UI, UX)
- **Full-stack**: 1-2 (flexibility)
- **QA**: 1 (testing, validation)
- **Total**: 5-6 engineers

**Resolved Score**: 0.20

**Confidence**: Medium (65%)

---

## 3. Ambiguity Resolution Summary

### 3.1 Resolved Ambiguities

| ID | Category | Initial | Resolved | Status |
|----|----------|---------|----------|--------|
| FA-001 | Functional | 0.45 | 0.15 | Resolved |
| FA-002 | Functional | 0.40 | 0.20 | Resolved |
| FA-003 | Functional | 0.50 | 0.20 | Resolved |
| TA-001 | Technical | 0.35 | 0.20 | Resolved |
| TA-002 | Technical | 0.30 | 0.15 | Resolved |
| TA-003 | Technical | 0.40 | 0.20 | Resolved |
| UA-002 | User | 0.50 | 0.25 | Resolved |
| UA-003 | User | 0.45 | 0.20 | Resolved |
| BA-001 | Business | 0.45 | 0.20 | Resolved |
| BA-003 | Business | 0.40 | 0.20 | Resolved |
| IA-001 | Integration | 0.45 | 0.15 | Resolved |
| IA-002 | Integration | 0.50 | 0.20 | Resolved |
| TL-002 | Timeline | 0.40 | 0.20 | Resolved |

### 3.2 Partially Resolved Ambiguities

| ID | Category | Initial | Resolved | Outstanding |
|----|----------|---------|----------|-------------|
| FA-004 | Functional | 0.55 | 0.30 | Retroactive processing scope |
| TA-004 | Technical | 0.55 | 0.25 | Performance validation |
| UA-001 | User | 0.65 | 0.30 | User research needed |
| BA-002 | Business | 0.50 | 0.25 | Pricing model decision |
| IA-003 | Integration | 0.55 | 0.25 | Volume validation |
| TL-001 | Timeline | 0.60 | 0.35 | Detailed estimation |

### 3.3 Resolution Methods Used

| Method | Count | Ambiguities |
|--------|-------|-------------|
| Decision with rationale | 8 | FA-001, FA-002, TA-002, TA-003, UA-003, BA-001, IA-001, IA-002 |
| Assumption with validation plan | 4 | FA-003, TA-001, TA-004, IA-003 |
| Scope reduction | 2 | FA-004, BA-002 |
| Research required | 2 | UA-001, TL-001 |

---

## 4. Outstanding Items

### 4.1 Items Requiring Validation

| Item | Owner | Timeline | Method |
|------|-------|----------|--------|
| User skill level (UA-001) | Product | Week 1-2 | User interviews |
| Performance requirements (TA-004) | Engineering | Week 2 | Load testing POC |
| Timeline estimation (TL-001) | Engineering | Week 2-3 | Detailed estimation |
| Data volumes (IA-003) | Product | Week 1-2 | Customer research |

### 4.2 Items Requiring Decisions

| Item | Decision Maker | Timeline | Options |
|------|----------------|----------|---------|
| Pricing model (BA-002) | Business | Phase 2 | Per-employee, per-company, feature-based |
| Retroactive processing (FA-004) | Product | Phase 2 | Automatic, manual, hybrid |

### 4.3 Assumptions Documented

| Assumption | Rationale | Risk |
|------------|-----------|------|
| VND only for Phase 1 | Vietnam focus | Low |
| PostgreSQL if no platform standard | SCD-2 support | Low |
| REST API primary | Simplicity | Low |
| Single-tenant first | Faster delivery | Medium |
| Manual retroactive processing | Scope control | Medium |

---

## 5. Ambiguity Score Trajectory

```
Initial:     ████████████████████ 0.41
Resolved:    ████████████████░░░░ 0.24
Target:      ████████████████     0.20

Progress:    65% reduction achieved
Gap to target: 0.04 (acceptable)
```

**Assessment**: Ambiguity has been significantly reduced. Remaining ambiguity is within acceptable range with documented assumptions and validation plans.

---

## 6. Recommendations

### 6.1 Proceed to Requirements

With documented assumptions and validation plans, proceed to Requirements phase.

### 6.2 Parallel Validation

Conduct user interviews and technical estimation in parallel with requirements gathering.

### 6.3 Checkpoint Review

Review ambiguity resolution after 2 weeks with validation results.

---

**Final Ambiguity Score**: 0.24 (Target: <= 0.20)
**Status**: Acceptable with documented assumptions

**Next Artifact**: requirements.md