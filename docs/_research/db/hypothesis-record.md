# Hypothesis Record: Dynamic Entity Definition System

> **Project**: Dynamic Entity Definition System (Palantir-inspired)  
> **Date**: 2026-01-21  
> **Status**: 🧪 TEST (MVP Scope Approved)  
> **Confidence**: MEDIUM  
> **Decision Type**: Two-way Door (Reversible)

---

## Executive Summary

This document records the hypothesis-driven evaluation of building a Dynamic Entity Definition System for xTalent HCM, inspired by Palantir Foundry's ontology-first approach. The solution would allow entities to be defined from Axiom Codex documents and automatically generate database structures using PostgreSQL JSONB.

**Verdict**: **TEST** - Proceed with MVP prototype to validate core assumptions before full investment.

---

## 1. Ideation Summary

### Pain Points Addressed

| Pain Point | Severity | Current Impact |
|------------|----------|----------------|
| Manual entity definition is time-consuming | HIGH | 2-4 weeks per entity |
| Schema changes require code deployments | HIGH | Blocks customer customization |
| Business users cannot define data structures | MEDIUM | Creates developer bottleneck |
| Data model evolution is slow | HIGH | Competitive disadvantage |
| Customer configurations require custom dev | HIGH | Limits scalability |

### Solution Directions Explored

1. **Hybrid Approach** ✅ (Selected): Core entities in JPA, extensions in JSONB
2. **Full Dynamic**: Everything in JSONB - rejected due to performance concerns
3. **Schema-on-Read**: Store raw JSON - rejected due to lack of validation
4. **EAV Pattern**: Entity-Attribute-Value - rejected as outdated approach

### Key Insight

> Palantir Foundry's 3-layer architecture (Semantic + Kinetic + Dynamic) provides a proven blueprint. Combined with xTalent's existing Axiom Codex ontology-first approach, this creates a strong foundation for dynamic entity definition.

---

## 2. Evidence Summary

### Supporting Evidence

| Finding | Source Tier | Details |
|---------|-------------|---------|
| Palantir Foundry validates ontology-first at scale | Tier 1 | Official docs, a16z analysis |
| Spring Data + Hypersistence Utils provides JSONB integration | Tier 1 | Baeldung, GitHub repos |
| JSON Schema is industry standard for data contracts | Tier 1 | json-schema.org, Postman, GitHub |
| Major HCM vendors use hybrid approaches | Tier 1 | Workday Extend, Oracle Flexfields, SAP Key User Extensibility |
| PostgreSQL JSONB with GIN indexes achieves excellent read performance | Tier 1 | PostgreSQL docs, benchmarks |
| Schema Registry patterns are well-established | Tier 1 | Confluent docs |

### Refuting/Warning Evidence

| Warning | Source Tier | Mitigation |
|---------|-------------|------------|
| JSONB updates require full document rewrite | Tier 2 | Keep JSONB documents small, extract hot fields |
| Schema evolution governance is challenging (30% undocumented) | Tier 2 | Implement CI/CD schema registration |
| Large JSONB (>2KB) suffers TOAST overhead | Tier 2 | Design document size limits |
| High technical expertise required | Tier 2 | Include training in timeline |

### Confidence Assessment

| Factor | Score | Evidence |
|--------|-------|----------|
| Technical Feasibility | HIGH | Proven libraries, mature PostgreSQL JSONB |
| Industry Validation | HIGH | Palantir, Workday, SAP, Oracle use similar patterns |
| xTalent Specific Fit | MEDIUM | Need onto.md parsing validation |
| Team Capability | UNKNOWN | Requires assessment |
| Performance at Scale | MEDIUM | Need benchmarks for xTalent workload |

**Overall Confidence**: **MEDIUM**

---

## 3. Hypothesis Statement

### Formal Hypothesis

> **IF** we build a Dynamic Entity Definition System using JSON Schema + PostgreSQL JSONB + Spring Data,  
> **THEN** xTalent customers can define custom entities without code deployment, reducing time-to-market for customizations by 70%  
> **BECAUSE** document-first ontology parsing + schema registry + dynamic repository patterns have been proven at Palantir scale  
> **AND** major HCM vendors (Workday, SAP, Oracle) all implement similar hybrid approaches for extensibility.

### Portfolio Classification

| Dimension | Classification | Rationale |
|-----------|----------------|-----------|
| **Horizon** | Horizon 2 (Growth) | Expands capability, not core optimization |
| **Innovation Type** | Platform/Infrastructure | Enables future features |
| **Budget Allocation** | 20% portfolio | Per 70/20/10 rule |

### Experimental Design

| Phase | Experiment Type | Budget Cap | Duration |
|-------|-----------------|------------|----------|
| Phase 1 | Technical Spike - Parse onto.md → JSON Schema | < $1k | 1 week |
| Phase 2 | Prototype MVP - Dynamic entity CRUD | < $5k | 2 weeks |
| Phase 3 | Benchmark - Performance at 1M records | < $3k | 1 week |

---

## 4. Critical Audit Results

### Decision Classification

- **Type**: Two-way Door (Reversible)
- **Reversibility**: Can migrate back to pure JPA if needed
- **Lock-in Risk**: LOW (PostgreSQL open source, Spring standard)

### Unit Economics

| Metric | Value |
|--------|-------|
| Development Cost | ~$15-30k (3-6 months, 1-2 developers) |
| Cost per Custom Field Request (current) | ~$5k developer time |
| Break-even Point | 6 custom field requests |
| Payback Period | First enterprise deal |

**Verdict**: LTV > CAC ✅

### Riskiest Assumptions

| Assumption | Risk Level | Validation Status |
|------------|------------|-------------------|
| Axiom Codex onto.md can be parsed to JSON Schema | HIGH ⚠️ | **Needs spike** |
| PostgreSQL JSONB suitable for HCM workload | MEDIUM | Industry evidence supports |
| Spring Data can abstract dynamic entities | LOW | Hypersistence Utils proven |
| Team can learn JSONB patterns | LOW | Standard PostgreSQL skill |
| Customers want self-service entity definition | MEDIUM | Need interviews |

### Bias Check

- [x] **Survivorship Bias Risk**: Only seeing Palantir success, not failures → Mitigated by researching challenges
- [ ] Confirmation Bias: Slight risk from Palantir comparison
- [ ] Sunk Cost Fallacy: N/A - Fresh initiative
- [ ] HiPPO Effect: LOW - Technical decision

### Pre-Mortem Analysis

If project fails in 1 year, possible reasons:

| Risk | Probability | Prevention |
|------|-------------|------------|
| 🔴 Schema evolution unmanageable | MEDIUM | Implement governance from day 1 |
| 🔴 Performance degraded at scale | MEDIUM | Benchmark before scaling |
| 🟡 Team never achieved expertise | LOW | Budget for training |
| 🟡 Customers prefer low-code UI | MEDIUM | Plan UI phase after MVP |
| 🟢 Scope creep to full Palantir clone | LOW | Define clear MVP boundaries |

---

## 5. Verdict & Recommendations

### Final Verdict: **TEST**

**Justification**:
1. Two-way door decision → Reversible if fails
2. MEDIUM confidence → Not enough for FULL build
3. Strong technical evidence BUT weak customer validation
4. Riskiest assumption (onto.md parsing) needs validation spike

### Immediate Actions

| Action | Owner | Timeline | Gate |
|--------|-------|----------|------|
| Run 1-week technical spike on onto.md → JSON Schema | Dev Team | Week 1 | Must achieve >80% accuracy |
| Conduct 3-5 customer interviews on customization | Product | Week 1-2 | Validate demand |
| Build MVP prototype if spike passes | Dev Team | Week 2-4 | Performance within 20% of JPA |
| Gate Review | All | Week 5 | Decide FULL BUILD or KILL |

### Approved for MVP

- [x] Core architecture exploration
- [x] Technical spike on onto.md parsing
- [x] Prototype with single entity type
- [x] Basic CRUD operations
- [x] Performance benchmark

### NOT Approved Yet

- [ ] Full production architecture
- [ ] Multi-tenant schema isolation
- [ ] Low-code UI for entity definition
- [ ] Enterprise schema registry
- [ ] Complex relationship mappings

---

## 6. Kill/Success Criteria

### Kill Criteria (Pre-defined Stop Loss)

> We will **KILL** this project if:
> 1. JSON Schema generation from onto.md achieves < 80% accuracy after 2 iterations
> 2. JSONB query performance degrades > 50% compared to JPA at 100k records
> 3. Schema evolution creates > 5% data inconsistency in migration tests
> 4. Team requires > 4 weeks to achieve basic JSONB competency

### Success Criteria (Proceed to Full Build)

> We will **PROCEED TO FULL BUILD** if:
> 1. Prototype demonstrates end-to-end: Document → Schema → Entity → CRUD
> 2. Performance benchmarks within 20% of native JPA for read operations
> 3. Schema evolution successfully migrates test data without loss
> 4. Customer demo receives positive feedback (NPS > 7)

---

## 7. Output Artifacts

This hypothesis evaluation produced the following documentation:

```
_research/db/
├── hypothesis-record.md          # This file
├── mvp/
│   ├── architecture-overview.md  # 3-layer architecture design
│   ├── technology-stack.md       # Tech decisions + alternatives
│   ├── database-design.md        # JSONB schema + indexing
│   └── axiom-integration.md      # onto.md → JSON Schema mapping
├── validation-plan.md            # Test plan with success criteria
└── references/
    └── research-sources.md       # All sources with tiering
```

---

## Appendix: Search Audit Log

| Query | Key Finding | Source Tier |
|-------|-------------|-------------|
| Palantir Foundry ontology architecture | 3-layer: Semantic + Kinetic + Dynamic | Tier 1 |
| Spring Data JPA JSONB PostgreSQL | Hypersistence Utils library | Tier 1/2 |
| JSON Schema enterprise case study | Postman, GitHub, ER/Studio adoption | Tier 1 |
| PostgreSQL JSONB vs relational performance | Hybrid approach recommended, GIN 7x faster | Tier 1/2 |
| Dynamic schema generation challenges | 30% undocumented changes, governance critical | Tier 2 |
| Schema Registry best practices | Confluent patterns, backward compatibility | Tier 1 |
| HCM vendors custom fields | Workday Extend, Oracle Flexfields, SAP Extensibility | Tier 1 |
