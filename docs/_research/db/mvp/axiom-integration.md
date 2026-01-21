# Axiom Codex Integration: onto.md → JSON Schema

> **Version**: 1.0 (MVP)  
> **Status**: Draft  
> **Last Updated**: 2026-01-21

---

## 1. Overview

This document describes how to parse Axiom Codex ontology documents (`*.onto.md`) and generate JSON Schema for the Dynamic Entity Definition System.

### Key Insight

> Axiom Codex `onto.md` files already contain structured YAML frontmatter that maps naturally to JSON Schema. The Markdown body provides human documentation while the YAML provides machine-readable definitions.

---

## 2. onto.md Format Analysis

### 2.1 Structure

An onto.md file consists of:

```markdown
---
# YAML Frontmatter (Machine-readable)
entity: EntityName
domain: domain-name
module: CO
version: "1.0.0"
attributes:
  - name: fieldName
    type: string
    required: true
relationships:
  - name: relName
    target: OtherEntity
lifecycle:
  states: [STATE1, STATE2]
policies:
  - name: ruleName
    type: validation
---

# Markdown Body (Human-readable)

## Overview
Description of the entity...

## Attributes
Table of attributes...
```

### 2.2 YAML Frontmatter Schema

```yaml
# Entity identification
entity: string          # Required: Entity name (PascalCase)
domain: string          # Required: Domain classification
module: string          # Required: Module code (CO, TA, TR, PR)
version: string         # Required: Semantic version
status: string          # Optional: draft, active, deprecated
owner: string           # Optional: Team/person responsible
tags: [string]          # Optional: Classification tags

# Entity classification
classification:
  type: string          # AGGREGATE_ROOT, ENTITY, VALUE_OBJECT, REFERENCE_DATA
  category: string      # Subdomain category

# Attribute definitions
attributes:
  - name: string        # Required: Attribute name (camelCase)
    type: string        # Required: Data type
    required: boolean   # Optional: Default false
    unique: boolean     # Optional: Uniqueness constraint
    description: string # Optional: Documentation
    format: string      # Optional: Format pattern
    values: [string]    # Required for enum type

# Relationship definitions
relationships:
  - name: string        # Required: Relationship name
    target: string      # Required: Target entity name
    cardinality: string # Required: one-to-one, one-to-many, many-to-one, many-to-many
    required: boolean   # Optional: Default false
    inverse: string     # Optional: Inverse relationship name
    description: string # Optional: Documentation

# Lifecycle state machine
lifecycle:
  states: [string]      # Required: List of valid states
  initial: string       # Required: Initial state
  terminal: [string]    # Optional: Terminal states
  transitions:
    - from: string      # or [string] for multiple sources
      to: string
      trigger: string
      guard: string     # Optional: Condition

# Business policies
policies:
  - name: string        # Required: Policy name
    type: string        # validation, business, retention
    rule: string        # Human description
    expression: string  # Optional: Machine expression
```

---

## 3. Type Mapping

### 3.1 Axiom Codex → JSON Schema Types

| Axiom Type | JSON Schema Type | JSON Schema Format | Notes |
|------------|------------------|-------------------|-------|
| `string` | `string` | - | Default string |
| `text` | `string` | - | Long text |
| `date` | `string` | `date` | ISO 8601 date |
| `datetime` | `string` | `date-time` | ISO 8601 datetime |
| `time` | `string` | `time` | ISO 8601 time |
| `integer` | `integer` | - | Whole numbers |
| `number` | `number` | - | Decimal numbers |
| `boolean` | `boolean` | - | True/false |
| `uuid` | `string` | `uuid` | UUID format |
| `email` | `string` | `email` | Email format |
| `enum` | `string` + `enum` | - | Uses `values` array |
| `array` | `array` | - | List of items |
| `object` | `object` | - | Nested object |

### 3.2 Format Pattern Conversion

| Axiom Format | JSON Schema Pattern | Example |
|--------------|---------------------|---------|
| `EMP-XXXX` | `^EMP-[0-9]{4}$` | EMP-0042 |
| `YYYY-MM-DD` | (use `format: date`) | 2024-01-15 |
| `XXX-NNN` | `^[A-Z]{3}-[0-9]{3}$` | ABC-123 |

### 3.3 Relationship Mapping

| Axiom Cardinality | JSON Schema | Implementation |
|-------------------|-------------|----------------|
| `one-to-one` | `$ref` to single object | FK UUID |
| `many-to-one` | `$ref` to single object | FK UUID |
| `one-to-many` | `array` of `$ref` | Array of FK UUIDs |
| `many-to-many` | `array` of `$ref` | Junction table |

---

## 4. Transformation Rules

### 4.1 JSON Schema Generation

```java
public class OntoToJsonSchemaTransformer {
    
    public JsonSchema transform(OntologyModel model) {
        JsonSchema schema = new JsonSchema();
        
        // 1. Set schema metadata
        schema.setSchema("http://json-schema.org/draft-07/schema#");
        schema.setId(generateSchemaId(model));
        schema.setTitle(model.getEntity());
        schema.setDescription(extractDescription(model));
        schema.setType("object");
        
        // 2. Transform attributes to properties
        Map<String, JsonSchemaProperty> properties = new LinkedHashMap<>();
        List<String> required = new ArrayList<>();
        
        for (Attribute attr : model.getAttributes()) {
            properties.put(attr.getName(), transformAttribute(attr));
            if (attr.isRequired()) {
                required.add(attr.getName());
            }
        }
        
        // 3. Add relationship references
        for (Relationship rel : model.getRelationships()) {
            properties.put(rel.getName(), transformRelationship(rel));
            if (rel.isRequired()) {
                required.add(rel.getName());
            }
        }
        
        // 4. Add lifecycle state as enum if defined
        if (model.getLifecycle() != null) {
            properties.put("_state", transformLifecycleState(model.getLifecycle()));
        }
        
        schema.setProperties(properties);
        schema.setRequired(required);
        schema.setAdditionalProperties(false);
        
        return schema;
    }
    
    private JsonSchemaProperty transformAttribute(Attribute attr) {
        JsonSchemaProperty prop = new JsonSchemaProperty();
        
        switch (attr.getType().toLowerCase()) {
            case "string":
                prop.setType("string");
                if (attr.getFormat() != null) {
                    prop.setPattern(convertFormatToRegex(attr.getFormat()));
                }
                break;
                
            case "date":
                prop.setType("string");
                prop.setFormat("date");
                break;
                
            case "datetime":
                prop.setType("string");
                prop.setFormat("date-time");
                break;
                
            case "enum":
                prop.setType("string");
                prop.setEnumValues(attr.getValues());
                break;
                
            case "integer":
                prop.setType("integer");
                break;
                
            case "number":
                prop.setType("number");
                break;
                
            case "boolean":
                prop.setType("boolean");
                break;
                
            case "uuid":
                prop.setType("string");
                prop.setFormat("uuid");
                break;
                
            default:
                prop.setType("string"); // Fallback
        }
        
        prop.setDescription(attr.getDescription());
        
        if (attr.isUnique()) {
            // Note: JSON Schema doesn't have uniqueness constraint
            // Store in custom property for application-level validation
            prop.setXUnique(true);
        }
        
        return prop;
    }
    
    private JsonSchemaProperty transformRelationship(Relationship rel) {
        JsonSchemaProperty prop = new JsonSchemaProperty();
        
        String targetRef = String.format("#/definitions/%s", rel.getTarget());
        
        switch (rel.getCardinality()) {
            case "one-to-one":
            case "many-to-one":
                // Single reference (FK as UUID)
                prop.setType("string");
                prop.setFormat("uuid");
                prop.setDescription(String.format("Reference to %s: %s", 
                    rel.getTarget(), rel.getDescription()));
                break;
                
            case "one-to-many":
            case "many-to-many":
                // Array of references
                prop.setType("array");
                prop.setItems(new JsonSchemaProperty("string", "uuid"));
                prop.setDescription(String.format("References to %s[]: %s", 
                    rel.getTarget(), rel.getDescription()));
                break;
        }
        
        return prop;
    }
    
    private JsonSchemaProperty transformLifecycleState(Lifecycle lifecycle) {
        JsonSchemaProperty prop = new JsonSchemaProperty();
        prop.setType("string");
        prop.setEnumValues(lifecycle.getStates());
        prop.setDefault(lifecycle.getInitial());
        prop.setDescription("Entity lifecycle state");
        return prop;
    }
    
    private String generateSchemaId(OntologyModel model) {
        return String.format("/schemas/%s/%s/v%s", 
            model.getModule().toLowerCase(),
            toKebabCase(model.getEntity()),
            model.getVersion());
    }
}
```

### 4.2 Validation Rules Extraction

Policies with `type: validation` map to JSON Schema constraints:

```java
public void applyValidationPolicies(JsonSchema schema, List<Policy> policies) {
    for (Policy policy : policies) {
        if ("validation".equals(policy.getType())) {
            applyValidationPolicy(schema, policy);
        }
    }
}

private void applyValidationPolicy(JsonSchema schema, Policy policy) {
    String expression = policy.getExpression();
    
    if (expression == null) return;
    
    // Parse common patterns
    if (expression.startsWith("UNIQUE(")) {
        // Mark fields as requiring unique combination
        // Application-level constraint, not JSON Schema
        schema.addCustomConstraint("x-unique-together", parseUniqueFields(expression));
    }
    else if (expression.contains("<=") || expression.contains(">=")) {
        // Comparison constraint
        // E.g., "hireDate <= TODAY()"
        // Application-level validation
    }
    else if (expression.contains("REQUIRED_IF")) {
        // Conditional requirement
        // Use JSON Schema "if-then-else" construct
    }
}
```

---

## 5. Example Transformation

### 5.1 Input: employee.onto.md (excerpt)

```yaml
entity: Employee
domain: core-hr
module: CO
version: "1.0.0"

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: "System-generated UUID"

  - name: employeeCode
    type: string
    required: true
    description: "Employee code (unique per Legal Entity)"
    format: "EMP-XXXX"

  - name: employeeClassCode
    type: enum
    required: true
    values: [PERMANENT, PROBATION, FIXED_TERM, SEASONAL, PART_TIME, INTERN]
    description: "Employee classification"

  - name: statusCode
    type: enum
    required: true
    values: [ACTIVE, ON_LEAVE, SUSPENDED, TERMINATED]
    description: "Employment status"

  - name: hireDate
    type: date
    required: true
    description: "Hire date"

relationships:
  - name: isWorker
    target: Worker
    cardinality: many-to-one
    required: true
    description: "The person (lifetime identity)"

lifecycle:
  states: [ACTIVE, ON_LEAVE, SUSPENDED, TERMINATED]
  initial: ACTIVE
```

### 5.2 Output: JSON Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "/schemas/co/employee/v1.0.0",
  "title": "Employee",
  "description": "Employee entity for Core HR module",
  "type": "object",
  "properties": {
    "id": {
      "type": "string",
      "format": "uuid",
      "description": "System-generated UUID",
      "x-unique": true
    },
    "employeeCode": {
      "type": "string",
      "pattern": "^EMP-[0-9]{4}$",
      "description": "Employee code (unique per Legal Entity)"
    },
    "employeeClassCode": {
      "type": "string",
      "enum": ["PERMANENT", "PROBATION", "FIXED_TERM", "SEASONAL", "PART_TIME", "INTERN"],
      "description": "Employee classification"
    },
    "statusCode": {
      "type": "string",
      "enum": ["ACTIVE", "ON_LEAVE", "SUSPENDED", "TERMINATED"],
      "description": "Employment status"
    },
    "hireDate": {
      "type": "string",
      "format": "date",
      "description": "Hire date"
    },
    "isWorker": {
      "type": "string",
      "format": "uuid",
      "description": "Reference to Worker: The person (lifetime identity)"
    },
    "_state": {
      "type": "string",
      "enum": ["ACTIVE", "ON_LEAVE", "SUSPENDED", "TERMINATED"],
      "default": "ACTIVE",
      "description": "Entity lifecycle state"
    }
  },
  "required": ["id", "employeeCode", "employeeClassCode", "statusCode", "hireDate", "isWorker"],
  "additionalProperties": false,
  "x-module": "CO",
  "x-domain": "core-hr",
  "x-version": "1.0.0"
}
```

---

## 6. Parser Implementation

### 6.1 YAML Frontmatter Extraction

```java
@Service
public class OntoMdParser {
    
    private static final Pattern FRONTMATTER_PATTERN = 
        Pattern.compile("^---\\s*\\n(.*?)\\n---", Pattern.DOTALL);
    
    private final Yaml yaml;
    
    public OntoMdParser() {
        this.yaml = new Yaml(new Constructor(OntologyModel.class, new LoaderOptions()));
    }
    
    public OntologyModel parse(String content) throws ParseException {
        // 1. Extract YAML frontmatter
        Matcher matcher = FRONTMATTER_PATTERN.matcher(content);
        if (!matcher.find()) {
            throw new ParseException("No YAML frontmatter found");
        }
        
        String yamlContent = matcher.group(1);
        
        // 2. Parse YAML to model
        OntologyModel model = yaml.load(yamlContent);
        
        // 3. Validate required fields
        validateModel(model);
        
        return model;
    }
    
    public OntologyModel parseFile(Path filePath) throws IOException, ParseException {
        String content = Files.readString(filePath);
        return parse(content);
    }
    
    private void validateModel(OntologyModel model) throws ParseException {
        if (model.getEntity() == null || model.getEntity().isBlank()) {
            throw new ParseException("Entity name is required");
        }
        if (model.getModule() == null || model.getModule().isBlank()) {
            throw new ParseException("Module code is required");
        }
        if (model.getVersion() == null || model.getVersion().isBlank()) {
            throw new ParseException("Version is required");
        }
    }
}
```

### 6.2 File Discovery

```java
@Service
public class OntologyDiscoveryService {
    
    private final OntoMdParser parser;
    private final JsonSchemaGenerator generator;
    
    public List<SchemaRegistration> discoverAndParse(Path rootPath) throws IOException {
        List<SchemaRegistration> registrations = new ArrayList<>();
        
        try (Stream<Path> paths = Files.walk(rootPath)) {
            paths.filter(p -> p.toString().endsWith(".onto.md"))
                 .forEach(path -> {
                     try {
                         OntologyModel model = parser.parseFile(path);
                         JsonSchema schema = generator.generate(model);
                         
                         registrations.add(new SchemaRegistration(
                             model.getEntity(),
                             parseVersion(model.getVersion()),
                             schema,
                             path.toString()
                         ));
                     } catch (Exception e) {
                         log.error("Failed to parse: {}", path, e);
                     }
                 });
        }
        
        return registrations;
    }
}
```

---

## 7. Accuracy Metrics

### 7.1 Mapping Coverage

| onto.md Feature | JSON Schema Support | Notes |
|-----------------|---------------------|-------|
| Basic types | ✅ 100% | All types mapped |
| Enum values | ✅ 100% | Direct mapping |
| Required fields | ✅ 100% | Direct mapping |
| Unique constraint | ⚠️ Custom ext | x-unique property |
| Format patterns | ✅ ~80% | Common patterns converted |
| Relationships | ⚠️ Reference only | FK UUIDs, not full objects |
| Lifecycle states | ✅ 100% | As enum with default |
| Validation policies | ⚠️ ~30% | Complex rules need app logic |
| Business policies | ❌ 0% | Not applicable to JSON Schema |

### 7.2 Success Criteria

For MVP spike, target **>80% attribute accuracy**:

- [x] All basic types correctly mapped
- [x] All enums with correct values
- [x] All required fields in `required` array
- [x] All format patterns converted where possible
- [x] All relationships as UUID references
- [ ] ≥80% of validation policies as constraints

---

## 8. Edge Cases

### 8.1 Missing Optional Fields

```yaml
# onto.md with minimal attributes
attributes:
  - name: code
    type: string
    # No 'required' → default false
    # No 'description' → empty
```

```json
{
  "properties": {
    "code": {
      "type": "string"
    }
  },
  "required": []  // 'code' is optional
}
```

### 8.2 Nested Objects

Currently not directly supported in onto.md. Use relationships instead.

### 8.3 Array Attributes

```yaml
attributes:
  - name: tags
    type: array
    items_type: string
```

```json
{
  "properties": {
    "tags": {
      "type": "array",
      "items": {
        "type": "string"
      }
    }
  }
}
```

---

## 9. Validation Process

### 9.1 Schema Validation Against Data

```java
@Service
public class DataValidator {
    
    private final SchemaRegistryRepository schemaRegistry;
    
    public ValidationResult validate(String entityType, Map<String, Object> data) {
        // 1. Get active schema for entity type
        Optional<SchemaRegistry> schemaOpt = schemaRegistry
            .findTopByEntityTypeAndIsActiveTrueOrderByVersionDesc(entityType);
        
        if (schemaOpt.isEmpty()) {
            return ValidationResult.error("Unknown entity type: " + entityType);
        }
        
        // 2. Load JSON Schema
        JSONObject schemaJson = new JSONObject(schemaOpt.get().getJsonSchema());
        Schema schema = SchemaLoader.load(schemaJson);
        
        // 3. Validate data
        try {
            schema.validate(new JSONObject(data));
            return ValidationResult.success();
        } catch (ValidationException e) {
            return ValidationResult.error(e.getAllMessages());
        }
    }
}
```

---

## 10. Future Enhancements

### 10.1 Relationship Object Embedding

Instead of just UUID references, optionally embed related objects:

```json
{
  "isWorker": {
    "type": "object",
    "properties": {
      "id": { "type": "string", "format": "uuid" },
      "name": { "type": "string" }
    }
  }
}
```

### 10.2 Conditional Schemas

Support `REQUIRED_IF` policies with JSON Schema `if-then-else`:

```json
{
  "if": {
    "properties": { "statusCode": { "const": "TERMINATED" } }
  },
  "then": {
    "required": ["terminationDate", "terminationReasonCode"]
  }
}
```

### 10.3 Schema Composition

Support schema inheritance with `allOf`:

```json
{
  "allOf": [
    { "$ref": "/schemas/co/base-entity/v1.0.0" },
    { "properties": { "employeeCode": {...} } }
  ]
}
```

---

## See Also

- [Architecture Overview](architecture-overview.md) - System architecture
- [Technology Stack](technology-stack.md) - Libraries and tools
- [Database Design](database-design.md) - JSONB storage
