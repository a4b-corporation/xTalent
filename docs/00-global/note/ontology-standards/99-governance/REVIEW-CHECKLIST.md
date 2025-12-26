# Ontology Review Checklist

**Version**: 1.0  
**Last Updated**: 2025-12-25  
**Purpose**: Comprehensive checklist for reviewing ontology changes

---

## 🎯 How to Use This Checklist

1. **Before Review**: Understand the change category (Minor/Standard/Major)
2. **During Review**: Check all applicable items
3. **After Review**: Document any exceptions in PR comments

---

## ✅ General Quality

### Metadata Completeness
- [ ] Has valid `$schema` reference
- [ ] Has unique `$id` in URI format (`xtalent:module:domain:entity`)
- [ ] Has non-empty `entity` name
- [ ] Has appropriate `classification` (AGGREGATE_ROOT, ENTITY, VALUE_OBJECT, REF_DATA)
- [ ] Has meaningful `definition` (not just the entity name restated)
- [ ] Has clear `purpose` explaining business value

### Naming Conventions
- [ ] Entity name is **PascalCase** and singular (e.g., `Employee`, not `Employees`)
- [ ] Attribute names are **snake_case** (e.g., `hire_date`, not `hireDate`)
- [ ] File name matches entity name in **kebab-case** (e.g., `employee.entity.yaml`)
- [ ] No abbreviations unless industry-standard (e.g., `SSN` is OK)

### Documentation Quality
- [ ] Definition is understandable by non-technical stakeholders
- [ ] Examples are provided for complex attributes
- [ ] Edge cases are documented
- [ ] Aliases are defined for alternative terms

---

## 📋 Entity-Specific Checks

### For AGGREGATE_ROOT
- [ ] Has `lifecycle` section with states and transitions
- [ ] Has primary business identifier (not just UUID)
- [ ] Owns all VALUE_OBJECT children
- [ ] Has audit fields (`created_at`, `updated_at`, `created_by`, `updated_by`)

### For ENTITY
- [ ] Clearly belongs to one AGGREGATE_ROOT
- [ ] Has reference to parent aggregate
- [ ] Does not have independent lifecycle (uses parent's)

### For VALUE_OBJECT
- [ ] Is immutable (no `updated_at`)
- [ ] Has no `id` field (embedded in parent)
- [ ] All fields are required (no optionals)

### For REF_DATA (Reference Data)
- [ ] Is system-managed, not user-managed
- [ ] Has `code` and `name` at minimum
- [ ] Has effective dates if time-varying

---

## 🔗 Relationship Checks

### Cardinality
- [ ] `1:1` — Verified that it's truly 1:1, not 1:N
- [ ] `1:N` — Parent side has collection, child has single reference
- [ ] `N:M` — Junction entity exists or is explicitly avoided
- [ ] `N:1` — Uses `required: true/false` correctly

### Relationship Integrity
- [ ] Both sides of relationship are defined (if bidirectional)
- [ ] `inverse` property points to correct attribute
- [ ] No orphan relationships (target entity exists)
- [ ] Cascade behavior is specified for delete scenarios

### Cross-Module Relationships
- [ ] Uses `$ref` with full URI for external entities
- [ ] Dependency is documented in module manifest
- [ ] No circular module dependencies

---

## 🔄 Lifecycle Checks

### State Machine
- [ ] All states are clearly defined
- [ ] Initial state is specified
- [ ] Terminal states are identified
- [ ] All transitions have named actions
- [ ] No unreachable states
- [ ] No dead-end states (unless terminal)

### State Diagram Validation
```
Example valid lifecycle:
DRAFT → ACTIVE → INACTIVE → TERMINATED
              ↘ SUSPENDED ↗

Check:
- [ ] Can reach all non-initial states from initial
- [ ] Terminal states have no outgoing transitions
```

---

## ✏️ Attribute Checks

### Type Validation
- [ ] Type is from allowed set: `string`, `integer`, `decimal`, `boolean`, `date`, `datetime`, `uuid`, `enum`, `array`, `object`
- [ ] Enums have at least 2 values
- [ ] Arrays specify item type
- [ ] Objects have nested schema

### Constraints
- [ ] `required: true/false` is specified for all attributes
- [ ] `unique: true` only on genuinely unique fields
- [ ] `pattern` regex is valid and tested
- [ ] `min`/`max` constraints are reasonable
- [ ] `default` values are valid for the type

### Sensitive Data
- [ ] PII fields are marked with `pii: true`
- [ ] Sensitive fields have appropriate access controls documented
- [ ] Data retention requirements specified

---

## 📚 Traceability Checks

### Cross-References
- [ ] `glossary_refs` link to valid glossary terms
- [ ] `concept_guide` path exists
- [ ] `business_rules` path exists or is marked N/A
- [ ] `bdd_scenarios` path exists or is planned

### Version Compatibility
- [ ] New required fields have defaults (backward compatible)
- [ ] Removed fields are marked deprecated first
- [ ] Breaking changes follow deprecation policy

---

## 🧪 Testing Readiness

### BDD Coverage
- [ ] Happy path scenario exists
- [ ] Edge cases are covered
- [ ] Error scenarios defined
- [ ] At least one example per business rule

### Data Generation
- [ ] Sample data can be generated from schema
- [ ] Constraints allow realistic test data
- [ ] Enum values include test/demo options

---

## 🚫 Red Flags

Immediately reject if:
- [ ] **Duplicate Concept**: Entity already exists under different name
- [ ] **Wrong Layer**: Workflow or transaction mistakenly classified as entity
- [ ] **Missing Identity**: AGGREGATE_ROOT without business identifier
- [ ] **Circular Dependency**: Entity A depends on B depends on A
- [ ] **Orphan Entity**: No relationships to any other entity
- [ ] **God Entity**: More than 30 attributes (needs decomposition)

---

## 📝 Review Decision

After completing checklist:

### ✅ APPROVE if:
- All required items checked
- No red flags
- Minor issues can be fixed post-merge

### 🔄 REQUEST CHANGES if:
- Missing required metadata
- Naming convention violations
- Relationship inconsistencies
- Missing tests

### ❌ REJECT if:
- Red flags present
- Fundamental design issues
- Breaking changes without migration plan
- Cross-module impact not addressed

---

## 🔗 Related Documents

- [CHANGE-PROCESS.md](./CHANGE-PROCESS.md) — Change management process
- [ARCHITECT-APPROVAL.md](./ARCHITECT-APPROVAL.md) — When to escalate
- [ENTITY-SCHEMA.md](../03-schemas/ENTITY-SCHEMA.md) — Full schema reference
- [WHAT-IS-NOT-ONTOLOGY.md](../00-getting-started/WHAT-IS-NOT-ONTOLOGY.md) — Classification guidance
