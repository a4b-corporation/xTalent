# Dynamic Entity Definition Research Report

> **Verdict:** TEST with MVP Scope
> 
> **Research Date:** 2026-01-22
> 
> **Methodology:** Hypothesis-Driven Workflow with Sequential Thinking (6 steps)

## Executive Summary

Nghiên cứu giải pháp tương đương Palantir Foundry runtime cho phép định nghĩa entity từ spec document và auto-implement xuống DB layer.

### Key Findings

| Aspect | Finding |
|--------|---------|
| **Database Choice** | All major platforms (STRAPI, Alfresco, Liferay, Salesforce) use **RDBMS**, NOT DocumentDB |
| **MongoDB Status** | STRAPI dropped MongoDB from v4 due to maintenance overhead |
| **Pattern** | Metadata-driven with virtualized schema is proven at enterprise scale |
| **PostgreSQL Fit** | JSONB + JSON Schema validation is viable, mature |
| **Recommendation** | Hybrid approach (structured core + JSONB extensions) for incremental adoption |

### Verdict: TEST

- **Two-way Door decision** → acceptable to experiment
- **HIGH technical confidence** (proven patterns)
- **MEDIUM business confidence** (no customer validation yet)
- **Bounded investment** (4 weeks max, clear kill criteria)

---

## 1. Research Scope

### User Requirements
- Giải pháp tương đương Palantir Foundry runtime
- Định nghĩa spec ở document → auto implement xuống DB
- Quản lý chặt chẽ giữa spec changes và DB
- Đã rõ: Spring Data + JSON Schema + PostgreSQL JSONB

### Research Questions
1. STRAPI CMS - Cơ chế động như thế nào?
2. Alfresco DMS - Schema management architecture?
3. Liferay Portal - Service Builder mechanism?
4. Database types: RDBMS vs DocumentDB vs Hybrid?
5. Schema evolution & migration strategies?

---

## 2. Platform Analysis Summary

| Platform | Database | Dynamic Level | Mechanism |
|----------|----------|---------------|-----------|
| **STRAPI** | PostgreSQL/MySQL (dropped MongoDB) | Deploy-time | schema.json files |
| **Alfresco** | PostgreSQL/MySQL/Oracle | Runtime (Aspects) | XML + Bootstrap |
| **Liferay** | PostgreSQL/MySQL/Oracle | Dual | service.xml + Liferay Objects UI |
| **Palantir** | Proprietary Object Store | Full Runtime | Ontology Metadata Service |
| **Salesforce** | Oracle (multi-tenant) | Full Runtime | Virtualized Metadata Tables |

> **Insight:** None of the major platforms use DocumentDB for their core dynamic entity functionality.

---

## 3. Recommended Architecture

### Primary: PostgreSQL JSONB + Metadata Registry

```
┌────────────────────────────────────────────┐
│         Metadata Registry                   │
│  entity_definitions                         │
│  - id, entity_name, json_schema, version    │
└─────────────────┬──────────────────────────┘
                  ▼
┌────────────────────────────────────────────┐
│         Data Storage                        │
│  entity_data                                │
│  - id, entity_def_id, tenant_id, data(JSONB)│
│  + GIN indexes                              │
└─────────────────┬──────────────────────────┘
                  ▼
┌────────────────────────────────────────────┐
│         Validation Layer                    │
│  Application-side JSON Schema validation    │
└────────────────────────────────────────────┘
```

### Implementation Path (Phased)

**Phase 1 (MVP):** Hybrid approach
- Add `custom_fields: JSONB` to existing entities
- Build simple metadata registry
- Application-level JSON Schema validation

**Phase 2 (If validated):** Full Metadata-Driven
- entity_definitions registry
- entity_data flexible storage
- Migration tools for existing entities

---

## 4. MVP Proposal

### Scope (2 weeks)

**Week 1: Technical Spike**
- PostgreSQL JSONB CHECK constraint với json_schema
- Axiom Codex .onto.md → JSON Schema converter (POC)

**Week 2: Prototype**
- Single entity: Employee custom fields
- CRUD API (Spring Boot + JSONB)
- JSON Schema validation
- Performance benchmarks (10K records)

### Success Criteria
- Prototype trong 2 tuần
- Performance within 20% of static ORM
- Schema evolution validated (add, rename, change type)

### Kill Criteria
- > 4 weeks để prototype
- > 50% performance degradation
- Team negative feedback
- No customer demand

---

## 5. Related Documents

- [Platform Analysis](./platform-analysis.md) - Detailed analysis of STRAPI, Alfresco, Liferay, Palantir, Salesforce
- [Architecture Proposal](./architecture-proposal.md) - Technical architecture design
- [Spike Plan](./spike-plan.md) - Technical spike tasks

---

## References

### Tier 1 (Official Documentation)
- Strapi Documentation: Content Types, Database Configuration
- Alfresco Documentation: Content Modeling, Aspects
- Liferay Documentation: Service Builder, Liferay Objects
- Palantir Documentation: Ontology, Object Storage V2
- Salesforce Documentation: Multi-tenant Architecture, Custom Objects

### Tier 2 (Engineering Blogs)
- PostgreSQL JSONB best practices
- JSON Schema validation patterns
