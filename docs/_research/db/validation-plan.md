# Validation Plan: Dynamic Entity Definition System MVP

> **Version**: 1.0  
> **Status**: Draft  
> **Last Updated**: 2026-01-21

---

## 1. Overview

This document defines the validation plan for the Dynamic Entity Definition System MVP, including test scope, success/kill criteria, and checkpoint schedule.

### Validation Goals

1. Validate onto.md → JSON Schema parsing accuracy
2. Benchmark JSONB performance against JPA baseline
3. Test schema evolution without data loss
4. Demonstrate end-to-end workflow

---

## 2. Spike Tests (Week 1)

### 2.1 Ontology Parsing Accuracy Test

**Objective**: Validate that onto.md files can be accurately parsed and converted to JSON Schema.

**Test Files**:
| File | Entity | Attributes | Relationships |
|------|--------|------------|---------------|
| employee.onto.md | Employee | 12 | 4 |
| worker.onto.md | Worker | 8 | 2 |
| position.onto.md | Position | 10 | 3 |
| job.onto.md | Job | 8 | 2 |
| contract.onto.md | Contract | 15 | 3 |

**Test Procedure**:
```bash
# 1. Run parser on each onto.md file
java -jar ontology-parser.jar parse --input employee.onto.md --output employee.schema.json

# 2. Compare generated schema against expected output
diff employee.schema.json expected/employee.schema.json

# 3. Validate sample data against generated schema
java -jar schema-validator.jar validate --schema employee.schema.json --data employee-sample.json
```

**Success Criteria**:
| Metric | Target | Measurement |
|--------|--------|-------------|
| Attribute mapping accuracy | ≥80% | Correctly mapped / Total attributes |
| Enum values correctness | 100% | All enum values match |
| Required fields correctness | 100% | All required fields correctly identified |
| Format patterns conversion | ≥70% | Patterns that produce valid regex |
| Relationship mapping | ≥90% | FK references correctly typed |

**Kill Criteria**:
- Attribute mapping accuracy < 80% after 2 iterations
- Critical parsing errors on any of the 5 test files

### 2.2 Parser Edge Case Tests

| Test Case | Input | Expected Output |
|-----------|-------|-----------------|
| Empty attributes | `attributes: []` | Empty properties object |
| No frontmatter | Markdown only | Parse error with clear message |
| Malformed YAML | Invalid syntax | Parse error with line number |
| Unknown type | `type: custom` | Default to string with warning |
| Missing required field | No entity name | Parse error specifying missing field |

---

## 3. Prototype Tests (Weeks 2-3)

### 3.1 CRUD Operations Test

**Objective**: Validate complete create-read-update-delete workflow.

**Test Scenario**:
```
1. Register JSON Schema for "TestEmployee"
2. Create 100 TestEmployee instances
3. Read each instance by ID
4. Update 50 instances (partial field update)
5. Query instances by JSONB field
6. Delete 25 instances
7. Verify final state
```

**Success Criteria**:
| Operation | Target Latency | Error Rate |
|-----------|---------------|------------|
| Create | <50ms | 0% |
| Read by ID | <10ms | 0% |
| Update | <50ms | 0% |
| Query by field | <100ms | 0% |
| Delete | <20ms | 0% |

### 3.2 Validation Enforcement Test

**Test Cases**:
| Case | Input | Expected Result |
|------|-------|-----------------|
| Valid data | All required + valid | 201 Created |
| Missing required field | Omit employeeCode | 400 Validation Error |
| Invalid enum value | statusCode: "INVALID" | 400 Validation Error |
| Invalid date format | hireDate: "15-01-2024" | 400 Validation Error |
| Invalid pattern | employeeCode: "WRONG" | 400 Validation Error |
| Extra field | unknownField: "value" | 400 additionalProperties error |

### 3.3 API Generation Test

**Generated Endpoints to Test**:
```
POST   /api/v1/entities/{type}          # Create
GET    /api/v1/entities/{type}          # List (paginated)
GET    /api/v1/entities/{type}/{id}     # Get by ID
PUT    /api/v1/entities/{type}/{id}     # Update
DELETE /api/v1/entities/{type}/{id}     # Delete
POST   /api/v1/entities/{type}/query    # Query by fields
GET    /api/v1/schemas/{type}           # Get schema
```

---

## 4. Performance Benchmarks (Week 4)

### 4.1 Baseline: JPA Entity Performance

First, establish baseline with equivalent JPA entity:

```sql
-- Create equivalent JPA table
CREATE TABLE employee_jpa (
    id UUID PRIMARY KEY,
    employee_code VARCHAR(20),
    status_code VARCHAR(20),
    hire_date DATE,
    -- ... other columns
);
```

**Benchmark Queries**:
| Query | Rows | JPA Baseline | Target JSONB |
|-------|------|--------------|--------------|
| Insert single | 1 | <5ms | <10ms |
| Get by ID | 1 | <2ms | <5ms |
| List 100 (page) | 100k | <30ms | <50ms |
| Filter by status | 100k | <20ms | <100ms |
| Complex filter | 100k | <50ms | <200ms |

### 4.2 JSONB Performance Tests

**Test Data Setup**:
```sql
-- Generate 100,000 test records
INSERT INTO dynamic_entity (entity_type, schema_version, data)
SELECT 
    'Employee',
    1,
    jsonb_build_object(
        'id', gen_random_uuid(),
        'employeeCode', 'EMP-' || LPAD(n::text, 4, '0'),
        'statusCode', (ARRAY['ACTIVE', 'ON_LEAVE', 'TERMINATED'])[1 + (n % 3)],
        'hireDate', '2020-01-01'::date + (n % 1000),
        'employeeClassCode', 'PERMANENT'
    )
FROM generate_series(1, 100000) n;
```

**Benchmark Queries**:

```sql
-- Query 1: GIN containment query
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM dynamic_entity 
WHERE entity_type = 'Employee' 
AND data @> '{"statusCode": "ACTIVE"}';

-- Query 2: Expression extract query
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM dynamic_entity 
WHERE entity_type = 'Employee' 
AND data->>'statusCode' = 'ACTIVE';

-- Query 3: Range query
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM dynamic_entity 
WHERE entity_type = 'Employee' 
AND (data->>'hireDate')::date > '2023-01-01';

-- Query 4: Pagination
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM dynamic_entity 
WHERE entity_type = 'Employee'
ORDER BY created_at DESC
LIMIT 100 OFFSET 1000;
```

**Success Criteria**:
- JSONB query performance within **20%** of JPA baseline for read operations
- GIN index effectively used (visible in EXPLAIN output)
- No sequential scans for indexed queries

**Kill Criteria**:
- JSONB query performance > **50%** slower than JPA at 100k records
- GIN index not utilized despite creation

### 4.3 Scale Test (Optional)

If Week 4 time permits, test at 1M records:

| Metric | Target |
|--------|--------|
| Insert 1M records | <10 minutes |
| Query filtered (active) | <500ms |
| Full table count | <1s |
| Storage size | <2GB |

---

## 5. Schema Evolution Tests

### 5.1 Forward Compatible Change (Add Optional Field)

```sql
-- 1. Register new schema version with optional field
INSERT INTO schema_registry (entity_type, version, json_schema)
VALUES ('Employee', 2, '{...schema with new optional field...}');

-- 2. Verify old data still valid against new schema
SELECT COUNT(*) FROM dynamic_entity 
WHERE entity_type = 'Employee' AND schema_version = 1;
-- Should return all records (old data is forward compatible)

-- 3. Create new data with new field
INSERT INTO dynamic_entity (entity_type, schema_version, data)
VALUES ('Employee', 2, '{"...old fields...", "newField": "value"}');

-- 4. Verify old and new data coexist
```

**Success Criteria**:
- Old data passes validation against new schema
- New data with optional field is accepted
- No data migration required

### 5.2 Backward Compatible Migration (Add Required Field with Default)

```sql
-- 1. Add required field with default value to all existing records
UPDATE dynamic_entity 
SET data = data || '{"requiredNewField": "defaultValue"}',
    schema_version = 3
WHERE entity_type = 'Employee';

-- 2. Register new schema requiring the field
INSERT INTO schema_registry (entity_type, version, json_schema)
VALUES ('Employee', 3, '{...schema with required field...}');

-- 3. Verify all records valid against new schema
```

**Success Criteria**:
- Zero data loss during migration
- All records valid after migration
- Migration completes in <1 minute for 100k records

**Kill Criteria**:
- >5% data inconsistency after migration
- Migration causes data corruption

---

## 6. Checkpoint Schedule

### Week 1 Checkpoint (Day 5)

| Gate | Criteria | Pass/Fail |
|------|----------|-----------|
| Parsing accuracy | ≥80% attribute accuracy | |
| All 5 test files parsed | No critical errors | |
| JSON Schema generation | Valid draft-07 schemas | |

**Decision**: If PASS → Proceed to Week 2. If FAIL → Iterate or KILL.

### Week 3 Checkpoint (Day 15)

| Gate | Criteria | Pass/Fail |
|------|----------|-----------|
| CRUD operations | All operations working | |
| Validation enforcement | All cases pass | |
| API generation | All endpoints functional | |

**Decision**: If PASS → Proceed to Week 4. If FAIL → Iterate or reduce scope.

### Week 4 Final Gate (Day 20)

| Gate | Criteria | Pass/Fail |
|------|----------|-----------|
| Performance benchmark | Within 20% of JPA | |
| Schema evolution | Zero data loss | |
| End-to-end demo | Complete workflow works | |

**Decision**: If PASS → PROCEED TO FULL BUILD. If FAIL → KILL or major redesign.

---

## 7. Demo Scenario

### End-to-End Demo Script

```
1. Show existing employee.onto.md file
2. Run ontology parser → Show generated JSON Schema
3. Register schema in Schema Registry
4. Create new Employee via REST API
5. Show data stored in PostgreSQL (JSONB)
6. Query employees by status via REST API
7. Update employee status
8. Demonstrate validation error for invalid data
9. Show schema evolution by adding optional field
10. Verify old data still accessible
```

**Demo Success Criteria**:
- Complete workflow in <15 minutes
- No manual database interventions
- Clear error messages for validation failures

---

## 8. Risk Mitigation During Validation

| Risk | Mitigation |
|------|------------|
| onto.md format variations | Test with real production onto.md files |
| JSONB performance varies | Test at multiple data sizes |
| Team unfamiliar with tools | Pair programming, documentation |
| Scope creep during prototype | Strict MVP feature list |

---

## 9. Post-Validation Deliverables

If MVP validation passes:

1. **Technical Spike Report**: Parsing accuracy results
2. **Performance Benchmark Report**: Latency comparisons
3. **Demo Recording**: End-to-end workflow video
4. **Recommendation**: FULL BUILD proposal with revised estimates

If MVP validation fails:

1. **Kill Report**: What failed and why
2. **Lessons Learned**: Technical insights
3. **Alternative Recommendations**: Other approaches to consider

---

## See Also

- [Hypothesis Record](hypothesis-record.md) - Original hypothesis and kill criteria
- [Architecture Overview](mvp/architecture-overview.md) - System design
- [Technology Stack](mvp/technology-stack.md) - Tools and libraries
