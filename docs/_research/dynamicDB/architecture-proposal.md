# Dynamic Entity Architecture Proposal

Technical architecture design for dynamic entity definition with PostgreSQL JSONB.

---

## Design Philosophy

Inspired by:
- **Salesforce:** Metadata-driven virtualized schema
- **Liferay Objects:** UI-based entity definition without redeploy
- **Alfresco Aspects:** Runtime extensibility pattern
- **Palantir Ontology:** Semantic layer with Links as first-class citizens

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      xTalent Platform                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                  Entity Definition API                      │ │
│  │  POST /api/entity-definitions                               │ │
│  │  PUT /api/entity-definitions/{id}                           │ │
│  │  GET /api/entity-definitions                                │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              │                                   │
│                              ▼                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                 Metadata Registry                           │ │
│  │  ┌──────────────────────────────────────────────────────┐  │ │
│  │  │  entity_definitions                                   │  │ │
│  │  │  - id: UUID                                           │  │ │
│  │  │  - entity_name: VARCHAR(100)                          │  │ │
│  │  │  - json_schema: JSONB                                 │  │ │
│  │  │  - version: INTEGER                                   │  │ │
│  │  │  - status: ENUM(draft, active, deprecated)            │  │ │
│  │  │  - created_by, created_at, updated_at                 │  │ │
│  │  └──────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              │                                   │
│                              ▼                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                 Validation Service                          │ │
│  │  - JSON Schema validation (everit/ajv)                      │ │
│  │  - Business rule validation                                 │ │
│  │  - Relationship validation                                  │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              │                                   │
│                              ▼                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                  Data Storage Layer                         │ │
│  │  Option A: Dedicated entity_data table                      │ │
│  │  Option B: custom_fields column on existing entities        │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Option A: Centralized Entity Data Table

### Database Schema

```sql
-- Metadata Registry
CREATE TABLE entity_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_name VARCHAR(100) NOT NULL UNIQUE,
    display_name VARCHAR(200),
    description TEXT,
    json_schema JSONB NOT NULL,
    version INTEGER DEFAULT 1,
    status VARCHAR(20) DEFAULT 'draft',  -- draft, active, deprecated
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Entity Data Storage
CREATE TABLE entity_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_def_id UUID REFERENCES entity_definitions(id),
    tenant_id UUID NOT NULL,
    data JSONB NOT NULL,
    created_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_entity_data_entity_def ON entity_data(entity_def_id);
CREATE INDEX idx_entity_data_tenant ON entity_data(tenant_id);
CREATE INDEX idx_entity_data_data ON entity_data USING gin(data);

-- Relationship tracking
CREATE TABLE entity_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_entity_def_id UUID REFERENCES entity_definitions(id),
    target_entity_def_id UUID REFERENCES entity_definitions(id),
    relationship_type VARCHAR(50), -- one_to_one, one_to_many, many_to_many
    source_property VARCHAR(100),
    target_property VARCHAR(100),
    CASCADE_DELETE BOOLEAN DEFAULT false
);
```

### JSON Schema Example

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "title": "CustomEmployee",
  "properties": {
    "emergencyContact": {
      "type": "object",
      "properties": {
        "name": { "type": "string", "maxLength": 100 },
        "phone": { "type": "string", "pattern": "^\\+?[0-9]{10,15}$" },
        "relationship": { "type": "string", "enum": ["spouse", "parent", "sibling", "friend", "other"] }
      },
      "required": ["name", "phone"]
    },
    "skills": {
      "type": "array",
      "items": { "type": "string" },
      "uniqueItems": true
    },
    "performanceRating": {
      "type": "number",
      "minimum": 1,
      "maximum": 5
    }
  },
  "required": ["emergencyContact"]
}
```

### Pros/Cons

| Pros | Cons |
|------|------|
| Clean separation of concerns | Complexity in joins with existing entities |
| Full flexibility for new entity types | Query optimization more complex |
| Clear versioning | Extra table management |

---

## Option B: Hybrid (Custom Fields Column)

### Database Schema

```sql
-- Add custom_fields to existing entities
ALTER TABLE employees ADD COLUMN custom_fields JSONB DEFAULT '{}';
ALTER TABLE departments ADD COLUMN custom_fields JSONB DEFAULT '{}';
ALTER TABLE positions ADD COLUMN custom_fields JSONB DEFAULT '{}';

-- Metadata for field definitions
CREATE TABLE custom_field_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(100) NOT NULL, -- 'employee', 'department', etc.
    field_name VARCHAR(100) NOT NULL,
    display_name VARCHAR(200),
    json_schema JSONB NOT NULL, -- Schema for this specific field
    required BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    tenant_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(entity_type, field_name, tenant_id)
);

-- Indexes on custom_fields
CREATE INDEX idx_employees_custom_fields ON employees USING gin(custom_fields);
CREATE INDEX idx_departments_custom_fields ON departments USING gin(custom_fields);
CREATE INDEX idx_positions_custom_fields ON positions USING gin(custom_fields);
```

### Example Usage

```sql
-- Add custom field definition
INSERT INTO custom_field_definitions (entity_type, field_name, display_name, json_schema, required)
VALUES (
    'employee',
    'emergencyContact',
    'Emergency Contact',
    '{"type": "object", "properties": {"name": {"type": "string"}, "phone": {"type": "string"}}}',
    true
);

-- Query with custom fields
SELECT 
    e.id,
    e.first_name,
    e.last_name,
    e.custom_fields->>'emergencyContact' as emergency_contact,
    e.custom_fields->'skills' as skills
FROM employees e
WHERE e.custom_fields @> '{"performanceRating": 5}';
```

### Pros/Cons

| Pros | Cons |
|------|------|
| Incremental adoption | Mixed structured + unstructured in same table |
| Natural joins with existing entities | Cannot define entirely new entity types |
| Simpler migration | Potential for custom_fields bloat |

---

## Recommended: Phased Approach

### Phase 1: Custom Fields (Option B) - MVP

**Scope:**
- Add `custom_fields JSONB` to Employee entity
- Build `custom_field_definitions` table
- Implement validation service
- Basic CRUD API

**Timeline:** 2 weeks

### Phase 2: Enhanced Features

**If Phase 1 successful:**
- Extend to other entities (Department, Position)
- Add relationship support
- Schema migration tooling

**Timeline:** 2-3 weeks

### Phase 3: Full Entity Definition (Option A)

**If demand validated:**
- Centralized `entity_definitions` registry
- `entity_data` table for fully dynamic entities
- UI for entity definition (like Liferay Objects)

**Timeline:** 4-6 weeks

---

## Technology Stack

| Layer | Technology | Notes |
|-------|------------|-------|
| **Database** | PostgreSQL 15+ | Native JSONB, GIN indexes |
| **Schema Validation** | everit-json-schema (Java) | Draft-07 support |
| **Backend** | Spring Boot 3.x | Spring Data JPA |
| **JSONB Mapping** | Hibernate Types / jackson | JSONB ↔ Java objects |
| **API** | Spring REST + HATEOAS | Dynamic field exposure |

---

## API Design

### Entity Definition API

```yaml
# Create entity definition
POST /api/entity-definitions
{
  "entityName": "employee",
  "displayName": "Employee Custom Fields",
  "jsonSchema": { ... }
}

# Get entity definition
GET /api/entity-definitions/{entityName}

# Update entity definition (versioning)
PUT /api/entity-definitions/{entityName}
{
  "jsonSchema": { ... }
}
```

### Data API with Custom Fields

```yaml
# Create employee with custom fields
POST /api/employees
{
  "firstName": "John",
  "lastName": "Doe",
  "customFields": {
    "emergencyContact": {
      "name": "Jane Doe",
      "phone": "+84123456789"
    },
    "skills": ["java", "sql"]
  }
}

# Query by custom field
GET /api/employees?filter=customFields.performanceRating:gte:4

# Update custom fields only
PATCH /api/employees/{id}/custom-fields
{
  "skills": ["java", "sql", "python"]
}
```

---

## Integration with Axiom Codex

### Ontology to JSON Schema Mapping

```
Axiom Codex .onto.md          →        JSON Schema
─────────────────────────────────────────────────────
entity: Employee              →        {"type": "object", ...}
  attributes:                 →        "properties": {
    - firstName: String       →          "firstName": {"type": "string"},
    - age: Integer            →          "age": {"type": "integer"}
  }
  constraints:                →        "required": [...],
    - required: firstName     →        validation rules
```

### Parser Design

```java
public class OntologyToJsonSchemaConverter {
    
    public JsonNode convert(OntologyFile ontology) {
        ObjectNode schema = mapper.createObjectNode();
        schema.put("$schema", "http://json-schema.org/draft-07/schema#");
        schema.put("type", "object");
        
        ObjectNode properties = mapper.createObjectNode();
        for (Attribute attr : ontology.getAttributes()) {
            properties.set(attr.getName(), convertAttribute(attr));
        }
        schema.set("properties", properties);
        
        // Handle required, constraints, etc.
        return schema;
    }
}
```

---

## Performance Considerations

### Indexing Strategy

```sql
-- Basic GIN for containment queries
CREATE INDEX idx_custom_fields_gin ON employees USING gin(custom_fields);

-- Expression index for frequently queried paths
CREATE INDEX idx_custom_fields_perf_rating 
ON employees ((custom_fields->>'performanceRating')::int)
WHERE custom_fields ? 'performanceRating';

-- Partial index for active employees with custom data
CREATE INDEX idx_active_employees_custom 
ON employees USING gin(custom_fields)
WHERE status = 'active' AND custom_fields != '{}';
```

### Query Examples

```sql
-- Containment query (uses GIN)
SELECT * FROM employees 
WHERE custom_fields @> '{"skills": ["java"]}';

-- Path query (needs expression index)
SELECT * FROM employees 
WHERE (custom_fields->>'performanceRating')::int >= 4;

-- Aggregation on custom field
SELECT 
    custom_fields->>'department' as dept,
    AVG((custom_fields->>'performanceRating')::int) as avg_rating
FROM employees
GROUP BY custom_fields->>'department';
```

### Expected Performance

| Operation | Expected Latency | Notes |
|-----------|------------------|-------|
| Simple CRUD | < 10ms | Comparable to static columns |
| Containment query (GIN) | < 50ms for 100K rows | With proper index |
| Path query (indexed) | < 50ms for 100K rows | Expression index required |
| Full scan on JSONB | > 500ms for 100K rows | Avoid if possible |

---

## Security Considerations

1. **Schema Validation:** Prevent injection via strict JSON Schema
2. **Field-level Permissions:** Control which custom fields users can see/edit
3. **Audit Log:** Track custom field changes
4. **Tenant Isolation:** Ensure custom_field_definitions are tenant-scoped
