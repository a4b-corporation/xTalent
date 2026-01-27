# Dynamic Entity Platform Analysis

Detailed analysis of how major platforms handle dynamic entity definition and database schema management.

---

## 1. STRAPI CMS

### Overview
Headless CMS with Content-Type Builder for defining dynamic content structures.

### Database Architecture
- **Supported:** PostgreSQL, MySQL, SQLite
- **Dropped:** MongoDB (từ v4)
- **Reason for dropping MongoDB:** Maintenance overhead, low adoption rate

### Schema Management

```
Content-Type Builder (UI)
         │
         ▼
    schema.json (file)
         │
         ▼
   Strapi Runtime
         │
         ▼
   SQL Tables
```

| Component | Approach |
|-----------|----------|
| Schema Storage | `schema.json` files trong codebase |
| Content Types | Thành SQL tables |
| Fields | Thành columns với appropriate types |
| Relationships | Foreign keys (SQL native) |
| Components | Separate tables hoặc JSONB |
| Dynamic Zones | JSONB với component references |

### Key Characteristics
- **Schema-as-Code:** Định nghĩa trong files, version control
- **Not Runtime Dynamic:** Cần redeploy khi schema thay đổi
- **Auto API:** REST và GraphQL được sinh tự động

### Lessons for xTalent
✅ Schema file-based approach tốt cho version control
❌ Redeploy requirement không phù hợp cho runtime flexibility
✅ Cấu trúc schema.json có thể tham khảo

---

## 2. Alfresco DMS

### Overview
Enterprise Content Management với flexible content modeling.

### Database Architecture
- **Supported:** PostgreSQL, MySQL, Oracle
- **Pattern:** RDBMS với metadata abstraction

### Schema Management

```
Content Model (XML)
         │
         ▼
   ┌─────┴─────┐
   ▼           ▼
 Types      Aspects
(1 per node) (many per node)
   │           │
   └─────┬─────┘
         ▼
    Node Tables
```

| Component | Description |
|-----------|-------------|
| **Types** | Fixed node type, single per node |
| **Aspects** | Attachable/detachable at runtime → **TRUE DYNAMIC** |
| **Properties** | Defined within types/aspects |
| **Constraints** | Static or dynamic list |

### Aspect-Based Extensibility

```xml
<aspect name="my:nda">
    <title>NDA Document</title>
    <properties>
        <property name="my:expirationDate">
            <type>d:datetime</type>
        </property>
    </properties>
</aspect>
```

**Key Insight:** Aspects có thể apply/remove runtime mà không cần schema change.

### Deployment Options
1. **Bootstrap:** XML + Spring bean, requires restart
2. **Model Manager UI:** Admin-friendly, no XML
3. **Dynamic Model (legacy):** Runtime reload without restart

### Lessons for xTalent
✅ Aspect pattern xuất sắc cho runtime extension
✅ Tách Types (core) vs Aspects (extensions) là pattern tốt
❌ XML-heavy, complex learning curve
✅ Model Manager UI concept cho citizen developers

---

## 3. Liferay Portal

### Overview
Enterprise portal với Service Builder ORM và Liferay Objects (UI-based).

### Database Architecture
- **Supported:** PostgreSQL, MySQL, Oracle, DB2
- **Pattern:** Dual-track (developer + citizen developer)

### Schema Management

```
┌─────────────────────────────────────────────┐
│            Developer Track                   │
│  service.xml → Service Builder → SQL Tables  │
│  (Requires build + deploy)                   │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│          Citizen Developer Track             │
│  Liferay Objects UI → Auto Tables           │
│  (No code, runtime)                          │
└─────────────────────────────────────────────┘
```

### Service Builder (Developer Track)

```xml
<entity name="Employee" table="employee">
    <column name="employeeId" primary="true" type="long"/>
    <column name="firstName" type="String"/>
    <column name="customData" type="String" convert-null="true"/>
</entity>
```

**Process:**
1. Define entity trong `service.xml`
2. Run `gradlew buildService`
3. Generate: Model, Persistence, Service layers
4. Deploy module
5. Liferay creates/updates tables

**Schema Changes:** UpgradeProcess class required.

### Liferay Objects (7.4+, Citizen Developer Track)
- Define entities via UI
- Auto table generation
- No redeploy needed
- **TRUE RUNTIME DYNAMIC**

### Lessons for xTalent
✅ Dual-track pattern: Service Builder (developers) + Objects (citizen developers)
✅ UpgradeProcess pattern cho schema migrations
✅ Liferay Objects là model tốt cho runtime definition
❌ Complex lifecycle, learning curve

---

## 4. Palantir Foundry

### Overview
Enterprise data platform với Ontology as semantic layer.

### Database Architecture
- **Storage:** Proprietary Object Store
- **Pattern:** Microservices với Ontology Metadata

### Ontology Architecture

```
┌──────────────────────────────────────────────┐
│              Ontology Manager                 │
│  Define: Objects, Links, Properties           │
└─────────────────┬────────────────────────────┘
                  ▼
┌──────────────────────────────────────────────┐
│        Ontology Metadata Service (OMS)        │
│  Stores entity definitions as metadata        │
└─────────────────┬────────────────────────────┘
                  ▼
┌──────────────────────────────────────────────┐
│           Object Data Funnel                  │
│  Ingests data from sources                    │
│  Indexes into Object Databases                │
└─────────────────┬────────────────────────────┘
                  ▼
┌──────────────────────────────────────────────┐
│           Object Databases                    │
│  Stores actual entity data                    │
└──────────────────────────────────────────────┘
```

### 3-Layer Architecture

| Layer | Description |
|-------|-------------|
| **Semantic** | Objects + Links (nouns of business) |
| **Kinetic** | Actions + Behaviors (verbs of business) |
| **Dynamic** | Evolution + Adaptability |

### Key Concepts
- **Objects:** Entities represented in ontology
- **Links:** Relationships as first-class citizens
- **Properties:** Attributes including time-series, geospatial
- **Actions:** Business operations on objects
- **Pipeline Builder:** Maps raw data → ontology objects

### Foundry Branching
- Monorepo với trunk-based development
- Schema changes tested on short-lived branches
- Enforces version control cho ontology

### Lessons for xTalent
✅ Ontology as semantic layer concept
✅ Link Types as first-class citizens (cf. Axiom Codex)
✅ 3-layer separation (Semantic/Kinetic/Dynamic)
❌ Requires significant platform investment
✅ Pipeline Builder concept cho mapping

---

## 5. Salesforce

### Overview
CRM platform với metadata-driven multi-tenant architecture.

### Database Architecture
- **Storage:** Oracle (multi-tenant)
- **Pattern:** Virtualized schema via metadata tables

### Metadata-Driven Architecture

```
┌──────────────────────────────────────────────┐
│         Universal Data Dictionary (UDD)       │
│  ┌────────────┐  ┌────────────┐              │
│  │ MT_Objects │  │ MT_Fields  │              │
│  │ (metadata) │  │ (metadata) │              │
│  └────────────┘  └────────────┘              │
└─────────────────┬────────────────────────────┘
                  ▼
┌──────────────────────────────────────────────┐
│              MT_Data (Shared)                 │
│  ┌────────┬────────┬────────┬──────────┐     │
│  │ OrgID  │ ObjID  │ FieldN │ Value    │     │
│  │ (tenant)│ (type) │ (flex) │ (data)   │     │
│  └────────┴────────┴────────┴──────────┘     │
└──────────────────────────────────────────────┘
```

### How It Works

1. **Creating Custom Object:**
   - UI/API defines object
   - Metadata stored in MT_Objects
   - NO physical table created

2. **Adding Custom Field:**
   - Field definition stored in MT_Fields
   - Data stored in flex columns of MT_Data

3. **Query Execution:**
   - SOQL → Interpret metadata → Generate SQL
   - Runtime materializes virtual schema

### Custom Metadata Types (CMDTs)
- Configuration data (not business data)
- Deployable, version-controlled
- Suffix: `__mdt` (vs `__c` for custom objects)

### Key Characteristics
- **Full Runtime Dynamic:** No deployment for schema changes
- **Multi-tenant:** OrgID segregation
- **SOQL → SQL Translation:** Query abstraction
- **Flex Columns:** Pre-provisioned slots in MT_Data

### Lessons for xTalent
✅ **Gold standard** for metadata-driven architecture
✅ Virtual schema pattern is proven at massive scale
✅ Flex column approach for performance
❌ Complex to implement from scratch
✅ CMDTs concept cho configuration vs data separation

---

## 6. PostgreSQL JSONB + JSON Schema

### Overview
Native PostgreSQL approach using JSONB for flexible schema.

### Architecture

```
┌──────────────────────────────────────────────┐
│         JSON Schema (Definition)              │
│  Stored as: File, Table, or Config            │
└─────────────────┬────────────────────────────┘
                  ▼
┌──────────────────────────────────────────────┐
│         Validation Layer                      │
│  - Application side: ajv, everit              │
│  - DB side: pg_jsonschema extension           │
└─────────────────┬────────────────────────────┘
                  ▼
┌──────────────────────────────────────────────┐
│         PostgreSQL JSONB Column               │
│  - GIN index for containment queries          │
│  - Expression indexes for paths               │
└──────────────────────────────────────────────┘
```

### Performance Considerations

| Factor | Impact | Mitigation |
|--------|--------|------------|
| TOAST storage | > 2KB triggers out-of-line storage | Keep JSONB compact |
| GIN index | Great for `@>` operator | Use for containment queries |
| Path operators | `->`, `->>` need explicit indexes | Create expression indexes |

### Validation Options

**Option A: Application-side (Recommended)**
```java
// Using everit JSON Schema
Schema schema = SchemaLoader.load(schemaJson);
schema.validate(data);
```

**Option B: DB-side with pg_jsonschema**
```sql
ALTER TABLE entities
ADD CONSTRAINT data_valid
CHECK (jsonschema_is_valid(data, json_schema));
```

### Hybrid Approach (Recommended)

```sql
CREATE TABLE employees (
    id UUID PRIMARY KEY,
    -- Structured core (indexed, performant)
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    -- Dynamic extensions (flexible)
    custom_fields JSONB DEFAULT '{}'
);

CREATE INDEX idx_employees_custom ON employees USING gin (custom_fields);
```

### Lessons for xTalent
✅ Pragmatic, cost-effective approach
✅ Hybrid (structured + JSONB) is recommended pattern
✅ JSON Schema is industry standard for validation
❌ No built-in entity management (need to build)
✅ Native PostgreSQL, no external dependencies

---

## Comparison Summary

| Feature | STRAPI | Alfresco | Liferay | Palantir | Salesforce | PG JSONB |
|---------|--------|----------|---------|----------|------------|----------|
| **DB Type** | RDBMS | RDBMS | RDBMS | Proprietary | Oracle | PostgreSQL |
| **Runtime Dynamic** | ❌ | ✅ (Aspects) | ✅ (Objects) | ✅ | ✅ | ✅ |
| **Schema Storage** | Files | XML | XML/UI | Metadata Svc | Metadata Tables | JSON Schema |
| **Multi-tenant** | ❌ | ✅ | ✅ | ✅ | ✅ (native) | Manual |
| **Complexity** | Low | High | Medium | Very High | High | Low |
| **Open Source** | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ |

---

## Recommendation for xTalent

### Approach: Hybrid with PostgreSQL JSONB

**Why:**
1. Proven pattern (Salesforce virtualization concept)
2. Leverage existing PostgreSQL stack
3. Incremental adoption (add custom_fields to existing entities)
4. JSON Schema for validation (industry standard)
5. Lower complexity than full runtime engine

**Implementation:**
1. **Phase 1:** Custom fields column on existing entities
2. **Phase 2:** Metadata registry if Phase 1 successful
3. **Phase 3:** Full entity definition (inspired by Liferay Objects)
