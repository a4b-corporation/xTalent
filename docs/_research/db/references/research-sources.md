# Research Sources: Dynamic Entity Definition System

> **Last Updated**: 2026-01-21

---

## Source Tiering

| Tier | Description | Reliability |
|------|-------------|-------------|
| **Tier 1 (Gold)** | Official docs, academic papers, GitHub source | Highest |
| **Tier 2 (Silver)** | Engineering blogs (Netflix/Uber), reputable news | High |
| **Tier 3 (Bronze)** | Forums (Reddit/StackOverflow) | Sentiment only |
| **Tier 4 (Trash)** | SEO spam, content farms | Ignore |

---

## Tier 1 Sources

### Palantir Foundry

| Source | URL | Key Insight |
|--------|-----|-------------|
| Palantir Official Docs - Ontology | palantir.com | Ontology Manager, Object Types, Actions |
| Palantir Official Docs - Pipeline Builder | palantir.com | Schema hydration, transform generation |
| Palantir Official Docs - Dynamic Schema | palantir.com | Dynamic schema inference for transforms |
| a16z Analysis | a16z.com | Foundry as enterprise operating system |

### PostgreSQL & JSONB

| Source | URL | Key Insight |
|--------|-----|-------------|
| PostgreSQL Official Docs - JSONB | postgresql.org | JSONB operators, GIN indexing |
| PostgreSQL Official Docs - TOAST | postgresql.org | Large value storage, >2KB overhead |
| pganalyze | pganalyze.com | JSONB performance optimization |

### JSON Schema

| Source | URL | Key Insight |
|--------|-----|-------------|
| JSON Schema Official | json-schema.org | Draft-07 specification |
| JSON Schema Case Studies | json-schema.org | GitHub, Postman, 6 River Systems |

### Spring & Hibernate

| Source | URL | Key Insight |
|--------|-----|-------------|
| Hypersistence Utils | github.com/vladmihalcea | JSONB type mapping for Hibernate |
| Baeldung - JSONB | baeldung.com | Spring Data JPA with JSONB |
| Spring Data JPA Docs | spring.io | Repository patterns |

### Confluent Schema Registry

| Source | URL | Key Insight |
|--------|-----|-------------|
| Confluent Docs | confluent.io | Schema Registry concepts |
| Confluent Best Practices | confluent.io | Pre-register schemas, compatibility |

### HCM Vendor Documentation

| Source | URL | Key Insight |
|--------|-----|-------------|
| Workday Official | workday.com | Workday Extend, custom objects |
| Oracle Docs | oracle.com | Flexfields (DFF, EFF, KFF) |
| SAP Docs | sap.com | Key User Extensibility, HANA schema flexibility |

---

## Tier 2 Sources

### Engineering Blogs

| Source | URL | Key Insight |
|--------|-----|-------------|
| Medium - Palantir Architecture | medium.com | 3-layer architecture explanation |
| Medium - Spring Data JSONB | medium.com | Practical implementation examples |
| Medium - JSONB vs Relational | medium.com | Performance comparison benchmarks |
| Heap Engineering | heap.io | JSONB optimization at scale |
| Mirakl Tech | mirakl.tech | JSONB for aggregations |
| GeeksforGeeks | geeksforgeeks.org | PostgreSQL JSONB tutorial |

### Research Papers

| Source | URL | Key Insight |
|--------|-----|-------------|
| ResearchGate - JSON Schema to Relational | researchgate.net | Schema transformation research |
| ResearchGate - Schema Evolution | researchgate.net | Challenges in dynamic schemas |
| ResearchGate - NoSQL vs Relational | researchgate.net | Performance comparisons |

### Technology Analysis

| Source | URL | Key Insight |
|--------|-----|-------------|
| DZone - Schema Registry | dzone.com | Compatibility modes explained |
| NordicAPIs | nordicapis.com | JSON Schema for APIs |
| ER/Studio - JSON Column Support | erstudio.com | Enterprise modeling for JSON |

---

## Tier 3 Sources (Sentiment Only)

### Forums & Communities

| Source | URL | Key Insight |
|--------|-----|-------------|
| Reddit - Palantir | reddit.com | Developer sentiment, learning curve |
| Reddit - Workday | reddit.com | Custom fields experience |
| StackOverflow - JSONB | stackoverflow.com | Common issues and solutions |
| Hacker News - PostgreSQL JSONB | ycombinator.com | Performance discussions |

---

## Key Findings by Topic

### 1. Palantir Foundry Architecture

**Source Consensus**: Strong (3 Tier 1, 2 Tier 2)

- 3-layer architecture: Semantic + Kinetic + Dynamic
- Ontology Manager for defining object types
- Pipeline Builder for data hydration
- Actions for operational changes
- Low-code tools (Workshop, Slate) for UI

### 2. PostgreSQL JSONB Performance

**Source Consensus**: Strong (4 Tier 1, 3 Tier 2)

- GIN indexes provide fast containment queries
- jsonb_path_ops for smaller, faster indexes when only using @>
- TOAST overhead for documents >2KB
- Full document rewrite on updates
- Hybrid approach recommended (relational + JSONB)

### 3. Schema Registry Best Practices

**Source Consensus**: Strong (2 Tier 1, 2 Tier 2)

- Pre-register schemas via CI/CD
- Disable auto-registration in production
- Use backward compatibility by default
- Topic-based subject naming strategy
- Schema is part of broader data contract

### 4. HCM Vendor Extensibility

**Source Consensus**: Strong (3 Tier 1)

- All major vendors support custom fields
- Workday: Object-oriented model, Workday Extend
- Oracle: Flexfields (DFF, EFF, KFF)
- SAP: Key User Extensibility, HANA schema flexibility
- All use hybrid approaches (core + extensions)

### 5. Dynamic Schema Challenges

**Source Consensus**: Medium (1 Tier 1, 4 Tier 2)

- 30% of schema changes go undocumented
- Schema evolution creates compatibility issues
- Data inconsistency risk without governance
- High technical expertise required
- Resistance to change in organizations

---

## Conflict Notes

### JSONB for Updates

| View | Source | Resolution |
|------|--------|------------|
| JSONB updates are expensive | Heap, Medium | True - full document rewrite |
| JSONB is efficient for reads | PostgreSQL docs | True - with proper indexing |
| **Resolution** | - | Use JSONB for read-heavy, extract hot fields for frequent updates |

### Schema-First vs Schema-Last

| View | Source | Resolution |
|------|--------|------------|
| Schema-first is better | Confluent | Prevents compatibility issues |
| Schema-on-read is flexible | NoSQL advocates | But loses validation benefits |
| **Resolution** | - | Schema-first with evolution rules |

---

## Citation Format

When citing these sources in documentation:

```markdown
According to PostgreSQL official documentation [Tier 1], GIN indexes support 
efficient JSONB containment queries using the @> operator.

Industry research by ResearchGate [Tier 2] indicates that approximately 30% 
of schema changes in enterprise systems go undocumented.

Developer sentiment on Reddit [Tier 3] suggests a significant learning curve 
for Palantir Foundry, though production experiences are generally positive.
```

---

## Update Log

| Date | Update |
|------|--------|
| 2026-01-21 | Initial research compilation |
