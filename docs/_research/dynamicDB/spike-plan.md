# Technical Spike Plan: Dynamic Entity Definition

2-week technical spike to validate dynamic entity architecture.

---

## Objective

Validate PostgreSQL JSONB + JSON Schema approach for dynamic entity definition by:
1. Parsing Axiom Codex Ontology → JSON Schema
2. Implementing CRUD with JSONB and validation
3. Benchmarking performance vs static ORM

---

## Week 1: Foundation

### Day 1-2: Environment Setup & Parser POC

**Tasks:**
- [ ] Setup Spring Boot 3.x project với PostgreSQL 15
- [ ] Add dependencies: Hibernate Types, everit-json-schema
- [ ] POC: Parse simple .onto.md → JSON Schema

**Deliverables:**
- Working Spring Boot app with PostgreSQL connection
- Basic ontology parser (read Entity, Attributes)

**Validation:**
```bash
# Test parser with sample ontology
./gradlew test --tests "OntologyParserTest"
```

### Day 3-4: Database Schema & JSONB Integration

**Tasks:**
- [ ] Create `custom_field_definitions` table
- [ ] Add `custom_fields JSONB` to Employee entity
- [ ] Configure Hibernate for JSONB mapping
- [ ] Create GIN index on custom_fields

**Deliverables:**
- Flyway migrations for schema
- Employee entity with customFields property

**SQL to validate:**
```sql
-- Check JSONB column exists
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'employees' AND column_name = 'custom_fields';

-- Check GIN index
SELECT indexname FROM pg_indexes WHERE tablename = 'employees';
```

### Day 5: JSON Schema Validation Service

**Tasks:**
- [ ] Implement JsonSchemaValidator service
- [ ] Integrate với Employee service (validate on save)
- [ ] Unit tests for validation pass/fail cases

**Deliverables:**
- JsonSchemaValidator bean
- Integration with EmployeeService

**Test cases:**
```java
@Test
void shouldPassValidCustomFields() { ... }

@Test
void shouldFailInvalidCustomFields() { ... }

@Test
void shouldFailMissingRequiredField() { ... }
```

---

## Week 2: CRUD API & Benchmarks

### Day 1-2: CRUD API Implementation

**Tasks:**
- [ ] POST /employees với customFields
- [ ] GET /employees với customFields trong response
- [ ] PATCH /employees/{id}/custom-fields
- [ ] Query API: filter by customFields

**Deliverables:**
- Complete REST API for Employee with custom fields
- OpenAPI spec updated

**API tests:**
```bash
# Create employee with custom fields
curl -X POST http://localhost:8080/api/employees \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "customFields": {
      "emergencyContact": {"name": "Jane", "phone": "+84123456789"},
      "skills": ["java", "sql"]
    }
  }'

# Query by custom field
curl "http://localhost:8080/api/employees?customFilter=skills:contains:java"
```

### Day 3: Field Definition API

**Tasks:**
- [ ] CRUD for custom_field_definitions
- [ ] Composite JSON Schema generation from field definitions
- [ ] Validation using generated schema

**Deliverables:**
- CustomFieldDefinitionController
- Schema composition service

### Day 4-5: Performance Benchmarks

**Tasks:**
- [ ] Generate 10K employees với 5 custom fields each
- [ ] Benchmark queries:
  - Containment query (`@>`)
  - Path query (`->>`)
  - Aggregation on custom field
- [ ] Compare với static ORM approach

**Benchmark script:**
```sql
-- Setup: Generate test data
INSERT INTO employees (first_name, last_name, custom_fields)
SELECT 
    'Employee' || n,
    'Test' || n,
    jsonb_build_object(
        'emergencyContact', jsonb_build_object('name', 'Contact' || n, 'phone', '+8490' || n),
        'skills', jsonb_build_array('java', 'sql'),
        'performanceRating', (random() * 4 + 1)::int
    )
FROM generate_series(1, 10000) n;

-- Benchmark 1: Containment query
EXPLAIN ANALYZE
SELECT * FROM employees 
WHERE custom_fields @> '{"skills": ["java"]}';

-- Benchmark 2: Path query
EXPLAIN ANALYZE
SELECT * FROM employees 
WHERE (custom_fields->>'performanceRating')::int >= 4;

-- Benchmark 3: Aggregation
EXPLAIN ANALYZE
SELECT 
    (custom_fields->>'performanceRating')::int as rating,
    COUNT(*) 
FROM employees 
GROUP BY (custom_fields->>'performanceRating')::int;
```

**Expected results:**
| Query Type | Target Latency | Acceptable |
|------------|----------------|------------|
| Containment | < 50ms | < 100ms |
| Path query | < 50ms | < 100ms |
| Aggregation | < 100ms | < 200ms |

---

## Exit Criteria

### Success Criteria (Proceed to Full Build)
- [ ] Prototype completed trong 2 weeks
- [ ] All CRUD operations working
- [ ] JSON Schema validation working
- [ ] Performance within 20% of static ORM
- [ ] Schema evolution validated (add field, change type)

### Kill Criteria (Stop)
- [ ] > 4 weeks để complete
- [ ] Performance > 50% worse than static
- [ ] Critical blockers (e.g., Hibernate JSONB issues)
- [ ] Team feedback negative

---

## Output Artifacts

After spike completion:
1. Working prototype (Git branch)
2. Benchmark results document
3. Go/No-Go recommendation
4. If Go: Refined architecture for full build

---

## Resource Requirements

| Resource | Allocation |
|----------|------------|
| Developer | 1 person full-time |
| PostgreSQL | Dev instance |
| Time | 2 weeks (10 working days) |

---

## Risk Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Hibernate JSONB issues | Medium | High | Use native queries as fallback |
| Performance degradation | Low | High | Add more indexes, optimize queries |
| JSON Schema complexity | Low | Medium | Start with simple schemas |
| Ontology parsing complexity | Medium | Medium | Parse subset of features first |
