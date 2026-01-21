# Technology Stack: Dynamic Entity Definition System

> **Version**: 1.0 (MVP)  
> **Status**: Draft  
> **Last Updated**: 2026-01-21

---

## 1. Overview

This document details the technology decisions for the Dynamic Entity Definition System MVP.

### Stack Summary

| Layer | Technology | Version | Purpose |
|-------|------------|---------|---------|
| **Runtime** | Java | 17+ | Core language |
| **Framework** | Spring Boot | 3.x | Application framework |
| **ORM** | Hibernate | 6.x | JPA implementation |
| **JSONB Support** | Hypersistence Utils | 3.x | JSONB type mapping |
| **Database** | PostgreSQL | 15+ | Primary storage |
| **Schema Validation** | everit-json-schema | 1.14+ | JSON Schema validation |
| **YAML Parsing** | SnakeYAML | 2.x | onto.md parsing |
| **API** | Spring WebMVC | - | REST endpoints |

---

## 2. Core Dependencies

### 2.1 Primary Dependencies

```xml
<dependencies>
    <!-- Spring Boot Starter -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    
    <!-- PostgreSQL Driver -->
    <dependency>
        <groupId>org.postgresql</groupId>
        <artifactId>postgresql</artifactId>
        <scope>runtime</scope>
    </dependency>
    
    <!-- Hypersistence Utils for JSONB -->
    <dependency>
        <groupId>io.hypersistence</groupId>
        <artifactId>hypersistence-utils-hibernate-63</artifactId>
        <version>3.7.0</version>
    </dependency>
    
    <!-- JSON Schema Validation -->
    <dependency>
        <groupId>com.github.erosb</groupId>
        <artifactId>everit-json-schema</artifactId>
        <version>1.14.4</version>
    </dependency>
    
    <!-- YAML Parsing -->
    <dependency>
        <groupId>org.yaml</groupId>
        <artifactId>snakeyaml</artifactId>
        <version>2.2</version>
    </dependency>
    
    <!-- Jackson for JSON -->
    <dependency>
        <groupId>com.fasterxml.jackson.core</groupId>
        <artifactId>jackson-databind</artifactId>
    </dependency>
    <dependency>
        <groupId>com.fasterxml.jackson.datatype</groupId>
        <artifactId>jackson-datatype-jsr310</artifactId>
    </dependency>
</dependencies>
```

### 2.2 Optional Dependencies (Phase 2+)

```xml
<!-- GraphQL Support -->
<dependency>
    <groupId>com.graphql-java</groupId>
    <artifactId>graphql-java</artifactId>
    <version>21.x</version>
</dependency>

<!-- Event Publishing -->
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>
```

---

## 3. Technology Decisions

### 3.1 Why PostgreSQL JSONB?

| Consideration | PostgreSQL JSONB | MongoDB | DynamoDB |
|---------------|------------------|---------|----------|
| **Flexibility** | ✅ Schema-less JSON | ✅ Native document | ✅ Key-value + document |
| **SQL Queries** | ✅ Full SQL support | ❌ Not native | ❌ Query language |
| **Transactions** | ✅ ACID | ⚠️ Limited | ⚠️ Limited |
| **Indexing** | ✅ GIN for JSONB | ✅ Native | ✅ GSI |
| **Existing Stack** | ✅ Already used | ❌ New infra | ❌ New infra |
| **Team Expertise** | ✅ Familiar | ⚠️ Learning curve | ⚠️ Learning curve |

**Decision**: PostgreSQL JSONB - Provides flexibility without new infrastructure.

### 3.2 Why Hypersistence Utils?

| Library | Maturity | Maintenance | Features |
|---------|----------|-------------|----------|
| **Hypersistence Utils** | ✅ Production-ready | ✅ Active (Vlad Mihalcea) | ✅ Full JSONB support |
| Custom AttributeConverter | ⚠️ DIY | ⚠️ Internal | ⚠️ Basic |
| Hibernate Types (old) | ❌ Deprecated | ❌ Migrated to Hypersistence | ❌ Use new version |

**Decision**: Hypersistence Utils - Industry standard, well-maintained.

### 3.3 Why everit-json-schema?

| Library | JSON Schema Version | Performance | Features |
|---------|---------------------|-------------|----------|
| **everit-json-schema** | Draft-07 | ✅ Fast | ✅ Full validation |
| networknt json-schema-validator | Draft-07+ | ✅ Fast | ✅ Full + OpenAPI |
| json-schema (org.json) | Draft-04 | ⚠️ Older | ⚠️ Limited |

**Decision**: everit-json-schema - Good balance of features and performance. Can switch to networknt if OpenAPI integration needed.

### 3.4 Why SnakeYAML?

| Library | Features | Compatibility |
|---------|----------|---------------|
| **SnakeYAML** | ✅ YAML 1.1 | ✅ Spring default |
| Jackson YAML | ✅ YAML 1.1 | ✅ Jackson ecosystem |
| YAMLBeans | ⚠️ Older | ⚠️ Less maintained |

**Decision**: SnakeYAML - Already bundled with Spring, familiar API.

---

## 4. Configuration

### 4.1 PostgreSQL Configuration

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/xtalent
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5

  jpa:
    hibernate:
      ddl-auto: validate  # Use Flyway for migrations
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        jdbc:
          time_zone: UTC
        types:
          print:
            banner: false
```

### 4.2 Hypersistence Utils Configuration

```java
@Configuration
public class HibernateConfig {
    
    @Bean
    public PhysicalNamingStrategy physicalNamingStrategy() {
        return new CamelCaseToUnderscoresNamingStrategy();
    }
}
```

### 4.3 JSON Schema Validator Configuration

```java
@Configuration
public class JsonSchemaConfig {
    
    @Bean
    public SchemaLoaderBuilder schemaLoaderBuilder() {
        return SchemaLoader.builder()
            .draftV7Support()
            .useDefaults(true);
    }
}
```

---

## 5. Code Examples

### 5.1 Dynamic Entity with JSONB

```java
@Entity
@Table(name = "dynamic_entity")
public class DynamicEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @Column(name = "entity_type", nullable = false)
    private String entityType;
    
    @Column(name = "schema_version", nullable = false)
    private Integer schemaVersion;
    
    @Type(JsonType.class)
    @Column(name = "data", columnDefinition = "jsonb")
    private Map<String, Object> data;
    
    @Column(name = "tenant_id")
    private UUID tenantId;
    
    @CreationTimestamp
    @Column(name = "created_at")
    private Instant createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at")
    private Instant updatedAt;
    
    // Getters, setters, etc.
}
```

### 5.2 Schema Registry Entity

```java
@Entity
@Table(name = "schema_registry")
@IdClass(SchemaRegistryId.class)
public class SchemaRegistry {
    
    @Id
    @Column(name = "entity_type")
    private String entityType;
    
    @Id
    @Column(name = "version")
    private Integer version;
    
    @Type(JsonType.class)
    @Column(name = "json_schema", columnDefinition = "jsonb")
    private Map<String, Object> jsonSchema;
    
    @Column(name = "source_document")
    private String sourceDocument;
    
    @Column(name = "compatibility")
    @Enumerated(EnumType.STRING)
    private CompatibilityType compatibility = CompatibilityType.BACKWARD;
    
    @Column(name = "is_active")
    private boolean active = true;
    
    @CreationTimestamp
    @Column(name = "created_at")
    private Instant createdAt;
}

public enum CompatibilityType {
    BACKWARD, FORWARD, FULL, NONE
}
```

### 5.3 Ontology Parser

```java
@Service
public class OntologyParser {
    
    private final Yaml yaml = new Yaml();
    
    public OntologyModel parse(String ontoMdContent) {
        // Extract YAML frontmatter between ---
        String yamlContent = extractFrontmatter(ontoMdContent);
        
        Map<String, Object> yamlData = yaml.load(yamlContent);
        
        return OntologyModel.builder()
            .entity((String) yamlData.get("entity"))
            .domain((String) yamlData.get("domain"))
            .module((String) yamlData.get("module"))
            .version((String) yamlData.get("version"))
            .attributes(parseAttributes(yamlData.get("attributes")))
            .relationships(parseRelationships(yamlData.get("relationships")))
            .lifecycle(parseLifecycle(yamlData.get("lifecycle")))
            .policies(parsePolicies(yamlData.get("policies")))
            .build();
    }
    
    private String extractFrontmatter(String content) {
        // Extract content between first and second ---
        int start = content.indexOf("---") + 3;
        int end = content.indexOf("---", start);
        return content.substring(start, end).trim();
    }
    
    // ... parsing methods
}
```

### 5.4 JSON Schema Generator

```java
@Service
public class JsonSchemaGenerator {
    
    public Map<String, Object> generate(OntologyModel model) {
        Map<String, Object> schema = new LinkedHashMap<>();
        
        schema.put("$schema", "http://json-schema.org/draft-07/schema#");
        schema.put("$id", String.format("/schemas/%s/%s", 
            model.getModule(), model.getEntity()));
        schema.put("title", model.getEntity());
        schema.put("type", "object");
        
        Map<String, Object> properties = new LinkedHashMap<>();
        List<String> required = new ArrayList<>();
        
        for (Attribute attr : model.getAttributes()) {
            properties.put(attr.getName(), generatePropertySchema(attr));
            if (attr.isRequired()) {
                required.add(attr.getName());
            }
        }
        
        schema.put("properties", properties);
        schema.put("required", required);
        schema.put("additionalProperties", false);
        
        return schema;
    }
    
    private Map<String, Object> generatePropertySchema(Attribute attr) {
        Map<String, Object> prop = new LinkedHashMap<>();
        
        // Map Axiom Codex types to JSON Schema types
        switch (attr.getType()) {
            case "string" -> prop.put("type", "string");
            case "date" -> {
                prop.put("type", "string");
                prop.put("format", "date");
            }
            case "enum" -> {
                prop.put("type", "string");
                prop.put("enum", attr.getValues());
            }
            // ... more mappings
        }
        
        if (attr.getFormat() != null) {
            prop.put("pattern", convertFormatToRegex(attr.getFormat()));
        }
        
        prop.put("description", attr.getDescription());
        
        return prop;
    }
}
```

---

## 6. Alternatives Considered

### 6.1 Document Database (MongoDB)

**Pros**:
- Native document storage
- Flexible schema by nature
- Rich query language

**Cons**:
- New infrastructure
- Team learning curve
- Transaction limitations

**Decision**: Not selected - PostgreSQL JSONB provides sufficient flexibility with existing infrastructure.

### 6.2 Full ORM Code Generation

**Pros**:
- Type-safe entities
- Compile-time validation
- Familiar development pattern

**Cons**:
- Requires code deployment for changes
- Not suitable for runtime flexibility
- Defeats purpose of dynamic entities

**Decision**: Not selected - Contradicts core requirement of dynamic definition.

### 6.3 Apache Avro / Protobuf

**Pros**:
- Strong schema evolution
- Compact binary format
- Type safety

**Cons**:
- Overkill for CRUD operations
- Less readable than JSON Schema
- Additional complexity

**Decision**: Deferred - May consider for event streaming in Phase 2.

---

## 7. Performance Considerations

### 7.1 Indexing Strategy

```sql
-- GIN index for JSONB content search
CREATE INDEX idx_de_data_gin ON dynamic_entity USING GIN (data);

-- B-tree for common query patterns
CREATE INDEX idx_de_entity_type ON dynamic_entity(entity_type);
CREATE INDEX idx_de_tenant ON dynamic_entity(tenant_id);
CREATE INDEX idx_de_created ON dynamic_entity(created_at DESC);

-- Expression index for specific JSONB fields (if frequently queried)
CREATE INDEX idx_de_status ON dynamic_entity((data->>'statusCode'));
```

### 7.2 Query Optimization

```sql
-- Efficient JSONB query with GIN
SELECT * FROM dynamic_entity
WHERE entity_type = 'Employee'
AND data @> '{"statusCode": "ACTIVE"}';

-- Avoid full document scan
-- Use containment operator (@>) instead of equality on extracted values
```

### 7.3 Expected Performance

| Operation | Expected Latency | Notes |
|-----------|------------------|-------|
| Insert | <10ms | Single row insert |
| Get by ID | <5ms | Primary key lookup |
| List (paginated) | <50ms | With B-tree index |
| JSONB query | <100ms | With GIN index |
| Full text search | <200ms | With GIN gin_trgm_ops |

---

## 8. Security Considerations

### 8.1 Input Validation

- All JSONB data validated against JSON Schema before storage
- SQL injection prevented by parameterized queries
- XSS prevention by sanitizing JSON string values

### 8.2 Access Control

- Entity type based permissions (future)
- Tenant isolation via `tenant_id` column
- Field-level access control (future Phase 2)

### 8.3 Data Encryption

- PostgreSQL column encryption for sensitive fields (future)
- TLS for data in transit
- Consider pgcrypto for sensitive JSONB fields

---

## See Also

- [Architecture Overview](architecture-overview.md) - System architecture
- [Database Design](database-design.md) - Schema details
- [Axiom Integration](axiom-integration.md) - onto.md parsing
