# Dynamic Entity Solution Blueprint

> **Document Type:** Consolidated Best Practices & Solution Design
> 
> **Created:** 2026-01-23
> 
> **Method:** Business Brainstorming (Morphological Analysis + SCAMPER)

---

## Executive Summary

Tài liệu này tổng hợp best practices từ 6 platform (STRAPI, Alfresco, Liferay, Palantir, Salesforce, PostgreSQL JSONB) thành một giải pháp hoàn chỉnh cho xTalent Platform.

### Core Design Principles

| Principle | Source | Application |
|-----------|--------|-------------|
| **Metadata-Driven** | Salesforce | Entity definitions = metadata, runtime interprets |
| **Aspect-Based Extension** | Alfresco | Core types vs. attachable extensions |
| **Dual-Track** | Liferay | Developer (code) + Citizen Developer (UI) |
| **3-Layer Semantic** | Palantir | Semantic (Objects) → Kinetic (Actions) → Dynamic (Evolution) |
| **Hybrid Storage** | PostgreSQL + STRAPI | Structured core + JSONB extensions |

---

## Part 1: Morphological Analysis

### Solution Dimension Matrix

| Dimension | Option A | Option B | Option C | Option D |
|-----------|----------|----------|----------|----------|
| **Schema Storage** | Files (STRAPI) | Metadata Tables (Salesforce) | XML (Alfresco) | Ontology Service (Palantir) |
| **Dynamic Level** | Deploy-time | Runtime (Aspects) | Full Runtime (Virtual) | Hybrid |
| **Database Strategy** | Pure RDBMS | JSONB Extension | Document DB | Multi-model |
| **User Interface** | Admin API only | Model Manager UI | Low-code Builder | Full IDE |
| **Validation** | Application-side | DB Constraints | Schema Service | Runtime Engine |
| **Multi-tenancy** | Single tenant | OrgID Column | Tenant Schema | Hybrid |

### Recommended Combination for xTalent

```
┌─────────────────────────────────────────────────────────────────┐
│  SELECTED CONFIGURATION                                         │
├─────────────────────────────────────────────────────────────────┤
│  Schema Storage:    Metadata Tables (like Salesforce)           │
│  Dynamic Level:     Hybrid (like Liferay dual-track)            │
│  Database Strategy: JSONB Extension (PostgreSQL native)         │
│  User Interface:    Model Manager UI (like Alfresco)            │
│  Validation:        Application-side + DB CHECK (belt & braces) │
│  Multi-tenancy:     OrgID/TenantID Column                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## Part 2: SCAMPER Analysis on Best Practices

### S - Substitute

| Platform Pattern | What to Substitute | xTalent Application |
|------------------|-------------------|----------------------|
| STRAPI schema.json | File-based → Table-based | Store in `entity_definitions` table |
| Alfresco XML | XML → JSON Schema | Use JSON Schema (draft-07) |
| Manual migrations | Manual → Auto-generated | Diff-based migration engine |

### C - Combine

| Combine From | + With | Result |
|--------------|--------|--------|
| Salesforce Virtual Schema | Liferay Objects UI | **Runtime definition with citizen-developer UI** |
| Alfresco Aspects | PostgreSQL JSONB | **Attachable extension fields per entity** |
| Palantir Ontology | Axiom Codex | **Semantic layer with .onto.md as source** |
| STRAPI auto-API | Spring HATEOAS | **Auto-generated hypermedia APIs** |

### A - Adapt

| Industry Pattern | Adaptation for xTalent |
|------------------|------------------------|
| **Salesforce CMDTs** (Custom Metadata Types) | Separate `configuration` vs `business data` in dynamic fields |
| **Palantir Pipeline Builder** | Ontology-to-Schema converter pipeline |
| **Liferay UpgradeProcess** | Schema versioning with rollback capability |
| **Alfresco Model Manager** | Admin UI for field definition without code |

### M - Modify (Magnify/Minify)

| Aspect | Magnify | Minify |
|--------|---------|--------|
| **Flexibility** | Full runtime entity creation (Phase 3) | MVP: Extension fields only |
| **Scope** | All entities | Start with Employee only |
| **UI** | Full visual designer | Simple form-based definition |
| **Validation** | DB + App + Frontend | App-side validation first |

### P - Put to Another Use

| Existing Asset | New Use |
|----------------|---------|
| **Axiom Codex .onto.md** | Source of truth → Auto-generate JSON Schema |
| **Spring Data JPA** | Base → Add JSONB converters |
| **GIN Indexes** | JSONB search → Also for audit log queries |
| **Tenant isolation** | Data segregation → Also for schema segregation |

### E - Eliminate

| What to Eliminate | Why | Source |
|-------------------|-----|--------|
| MongoDB support | Maintenance overhead, STRAPI dropped it | STRAPI lesson |
| XML schema definitions | Complexity, learning curve | Alfresco lesson |
| Full schema redeploy | Runtime flexibility needed | STRAPI limitation |
| Separate schema DB | Reduces complexity | Palantir overhead |

### R - Rearrange

| Current Flow | Rearranged Flow | Benefit |
|--------------|-----------------|---------|
| Code-first → DB | **Spec-first → Schema → Code** | Single source of truth |
| Entity → Fields | **Entity Core + Aspects (extensions)** | Separation of concerns |
| All-at-once deploy | **Phased: MVP → Enhanced → Full** | Risk reduction |

---

## Part 3: Synthesized Solution Architecture

### 3.1 Layered Architecture (Inspired by Palantir 3-Layer)

```
┌─────────────────────────────────────────────────────────────────┐
│                    SPECIFICATION LAYER                          │
│  Axiom Codex .onto.md files                                     │
│  - Entity definitions (core + extensions)                       │
│  - Relationship definitions (links)                             │
│  - Business rules (constraints)                                 │
└─────────────────────────────────┬───────────────────────────────┘
                                  │ Parse & Convert
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                    METADATA LAYER                               │
│  entity_definitions table (JSON Schema)                         │
│  - Schema version control                                       │
│  - Extension field registry                                     │
│  - Relationship metadata                                        │
└─────────────────────────────────┬───────────────────────────────┘
                                  │ Validate & Store
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                    DATA LAYER                                   │
│  PostgreSQL with JSONB                                          │
│  - Core tables (structured columns)                             │
│  - Extension fields (custom_fields JSONB)                       │
│  - GIN indexes for query performance                            │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Dual-Track Pattern (From Liferay)

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEVELOPER TRACK                              │
│  .onto.md → ontology-builder → JSON Schema → entity_definitions │
│  Full control, version controlled, reviewed                     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                 CITIZEN DEVELOPER TRACK                         │
│  Admin UI → custom_field_definitions → Runtime creation         │
│  No code, immediate effect, tenant-scoped                       │
└─────────────────────────────────────────────────────────────────┘
```

### 3.3 Aspect-Based Extension (From Alfresco)

```
┌─────────────────────────────────────────────────────────────────┐
│                    CORE ENTITY                                  │
│  employees (fixed schema)                                       │
│  - id, first_name, last_name, email, department_id              │
│  - These columns are stable, optimized, indexed                 │
└─────────────────────────────────────────────────────────────────┘
                                  +
┌─────────────────────────────────────────────────────────────────┐
│                    EXTENSION ASPECTS                            │
│  Aspect: EmergencyContact                                       │
│    - name, phone, relationship                                  │
│  Aspect: PerformanceData                                        │
│    - rating, review_date, manager_notes                         │
│  Aspect: Skills                                                 │
│    - skill_list[], proficiency_levels{}                         │
│  → All stored in custom_fields JSONB column                     │
└─────────────────────────────────────────────────────────────────┘
```

### 3.4 Database Schema (Synthesized)

```sql
-- ═══════════════════════════════════════════════════════════════
-- METADATA REGISTRY (Salesforce-inspired)
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE entity_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_name VARCHAR(100) NOT NULL,           -- 'employee', 'department'
    entity_type VARCHAR(20) DEFAULT 'extension', -- 'core', 'extension', 'custom'
    display_name VARCHAR(200) NOT NULL,
    description TEXT,
    json_schema JSONB NOT NULL,                  -- Full JSON Schema
    version INTEGER DEFAULT 1,
    status VARCHAR(20) DEFAULT 'draft',          -- draft, active, deprecated
    tenant_id UUID,                              -- Multi-tenant support
    created_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(entity_name, version, tenant_id)
);

-- ═══════════════════════════════════════════════════════════════
-- ASPECT DEFINITIONS (Alfresco-inspired)
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE aspect_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aspect_name VARCHAR(100) NOT NULL,           -- 'emergency_contact', 'skills'
    display_name VARCHAR(200) NOT NULL,
    applicable_entities TEXT[],                   -- ['employee', 'contractor']
    json_schema JSONB NOT NULL,                  -- Schema for this aspect
    is_required BOOLEAN DEFAULT false,
    is_default BOOLEAN DEFAULT false,            -- Auto-attach to new entities
    tenant_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(aspect_name, tenant_id)
);

-- Which aspects are attached to which entity instance
CREATE TABLE entity_aspects (
    entity_type VARCHAR(100) NOT NULL,
    entity_id UUID NOT NULL,
    aspect_id UUID REFERENCES aspect_definitions(id),
    attached_at TIMESTAMPTZ DEFAULT NOW(),
    attached_by UUID,
    
    PRIMARY KEY (entity_type, entity_id, aspect_id)
);

-- ═══════════════════════════════════════════════════════════════
-- DATA STORAGE (Hybrid: Structured + JSONB)
-- ═══════════════════════════════════════════════════════════════

-- Core entity with extension column
ALTER TABLE employees ADD COLUMN IF NOT EXISTS 
    custom_fields JSONB DEFAULT '{}';

ALTER TABLE employees ADD COLUMN IF NOT EXISTS 
    attached_aspects UUID[] DEFAULT '{}';

-- GIN indexes for performance
CREATE INDEX IF NOT EXISTS idx_employees_custom_fields 
    ON employees USING gin(custom_fields);

CREATE INDEX IF NOT EXISTS idx_employees_attached_aspects 
    ON employees USING gin(attached_aspects);

-- ═══════════════════════════════════════════════════════════════
-- SCHEMA VERSIONS (Liferay UpgradeProcess inspired)
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE schema_migrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_definition_id UUID REFERENCES entity_definitions(id),
    from_version INTEGER NOT NULL,
    to_version INTEGER NOT NULL,
    migration_script TEXT,                       -- JSON Patch or SQL
    applied_at TIMESTAMPTZ,
    status VARCHAR(20) DEFAULT 'pending',        -- pending, applied, failed, rolled_back
    error_message TEXT
);
```

---

## Part 4: Implementation Roadmap

### Phase 1: Foundation (2 weeks)

| Component | Description | Best Practice Source |
|-----------|-------------|---------------------|
| `entity_definitions` table | Store JSON Schemas | Salesforce |
| `aspect_definitions` table | Attachable extension groups | Alfresco |
| JSONB on Employee | custom_fields column + GIN index | PostgreSQL |
| Validation Service | Application-side JSON Schema | STRAPI/Everit |
| Basic CRUD API | Create/Read/Update employees with custom fields | Spring Data |

**Success Metrics:**
- CRUD operations work with custom fields
- Validation rejects invalid data
- Query performance < 50ms for 10K records

### Phase 2: Enhanced (3 weeks)

| Component | Description | Best Practice Source |
|-----------|-------------|---------------------|
| Multi-entity support | Department, Position custom fields | Liferay |
| Aspect attachment | Attach/detach aspects runtime | Alfresco |
| Ontology Parser | .onto.md → JSON Schema | Palantir Pipeline |
| Schema Versioning | Migration tracking table | Liferay UpgradeProcess |
| Admin API | Entity/Aspect definition endpoints | Salesforce Metadata API |

**Success Metrics:**
- Parse Axiom Codex ontology files
- Attach/detach aspects at runtime
- Schema versioning with rollback

### Phase 3: Full Platform (6 weeks)

| Component | Description | Best Practice Source |
|-----------|-------------|---------------------|
| Fully Dynamic Entities | entity_data table for new entity types | Salesforce Custom Objects |
| Model Manager UI | Visual entity/field definition | Alfresco Model Manager |
| Relationship Management | Link definitions between entities | Palantir Links |
| Multi-tenant | Tenant-scoped definitions | Salesforce OrgID |
| Query Builder | Dynamic queries on custom fields | Salesforce SOQL |

---

## Part 5: Key Patterns Catalog

### Pattern 1: Virtual Schema (Salesforce)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  MT_Objects │────▶│  MT_Fields  │────▶│   MT_Data   │
│  (what)     │     │  (structure)│     │  (values)   │
└─────────────┘     └─────────────┘     └─────────────┘
                            │
                            ▼
                    Runtime Materializes
                    Virtual Schema
```

**Application:** Store entity definitions as metadata, interpret at runtime.

### Pattern 2: Aspect Composition (Alfresco)

```
           Node
            │
    ┌───────┴───────┐
    ▼               ▼
  Type          Aspects[]
 (1 per node)   (N per node)
    │               │
    └───────┬───────┘
            ▼
      Combined Properties
```

**Application:** Core type stays stable, extensions via attachable aspects.

### Pattern 3: Dual-Track (Liferay)

```
Developer:     service.xml → Build → Deploy → Tables
                    │
                    │ (Different paths, same result)
                    │
Citizen Dev:   UI Definition → Runtime → Tables
```

**Application:** Support both code-driven and UI-driven schema definition.

### Pattern 4: 3-Layer Ontology (Palantir)

```
Semantic Layer:  Objects (Employee, Department)
                 Links (works_in, reports_to)
                      │
                      ▼
Kinetic Layer:   Actions (transfer, promote)
                 Workflows (onboarding)
                      │
                      ▼
Dynamic Layer:   Evolution (schema changes)
                 Adaptability (runtime extensions)
```

**Application:** Separate what (data) from how (actions) from change (evolution).

---

## Part 6: Risk Mitigation Matrix

| Risk | Probability | Impact | Mitigation | Source |
|------|-------------|--------|------------|--------|
| Performance degradation | Medium | High | GIN indexes, expression indexes | PostgreSQL |
| Schema migration failures | Medium | High | Versioning + rollback | Liferay |
| Complexity overload | High | Medium | Phased approach, start MVP | All |
| JSONB query complexity | Medium | Medium | Query builder abstraction | Salesforce SOQL |
| Multi-tenant data leakage | Low | Critical | tenant_id in all queries | Salesforce |
| Developer resistance | Medium | Medium | Dual-track, opt-in extension | Liferay |

---

## Part 7: Decision Checklist

Use this checklist when implementing:

### Phase 1 Decisions
- [ ] Start with Employee entity only (SCAMPER: Minify)
- [ ] Application-side validation first (Simplicity)
- [ ] JSON Schema draft-07 (Industry standard)
- [ ] GIN index on custom_fields (Performance)

### Phase 2 Decisions
- [ ] Aspect-based extension model? (Alfresco pattern)
- [ ] Ontology parser for .onto.md? (Palantir pattern)
- [ ] Schema versioning table? (Liferay pattern)

### Phase 3 Decisions
- [ ] Full virtual schema (new entity types)? (Salesforce pattern)
- [ ] Model Manager UI needed? (Alfresco pattern)
- [ ] Query language abstraction? (SOQL-like)

---

## Appendix: Quick Reference

### Best Practice by Platform

| Platform | Primary Contribution | xTalent Application |
|----------|---------------------|---------------------|
| **Salesforce** | Virtual Schema, Multi-tenant | Metadata tables, tenant isolation |
| **Alfresco** | Aspects, Runtime extension | Attachable field groups |
| **Liferay** | Dual-track, UpgradeProcess | Code + UI paths, versioning |
| **Palantir** | 3-Layer, Links as first-class | Semantic separation, link registry |
| **STRAPI** | Auto API, Schema files | Auto REST generation, JSON schema |
| **PostgreSQL** | JSONB, GIN index | Extension storage, query performance |

### Technology Stack Summary

| Layer | Technology | Pattern Source |
|-------|------------|----------------|
| Spec Definition | Axiom Codex .onto.md | Palantir Ontology |
| Schema Storage | PostgreSQL tables | Salesforce Metadata |
| Validation | everit-json-schema | STRAPI |
| Extension Storage | PostgreSQL JSONB | Best practice |
| Query | Spring Data + JSONB operators | Composite |
| API | Spring REST + HATEOAS | STRAPI auto-API |
