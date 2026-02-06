# Graph Database vs In-Memory Graph Engine

Câu hỏi rất hay - đây là architectural decision quan trọng.

## Hai approaches

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         APPROACH 1                                      │
│                  Full Graph Database                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   ┌─────────────┐     ┌─────────────────┐     ┌──────────────────┐    │
│   │   HCM App   │────▶│  Graph Database │────▶│  Query Results   │    │
│   └─────────────┘     │  (JanusGraph,   │     └──────────────────┘    │
│                       │   Neptune...)    │                             │
│                       └─────────────────┘                              │
│                                                                         │
│   Employee data lives IN graph database                                │
│   Gremlin queries run directly on DB                                   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                         APPROACH 2                                      │
│            Schema-only Graph + Query Translation                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   ┌─────────────┐     ┌─────────────────┐     ┌──────────────────┐    │
│   │   HCM App   │────▶│   Eligibility   │────▶│   RDBMS / API    │    │
│   └─────────────┘     │     Engine      │     └──────────────────┘    │
│                       │                 │                              │
│                       │  - Graph Schema │     Employee data lives      │
│                       │  - Gremlin Rule │     in existing systems      │
│                       │  - Translator   │                              │
│                       └─────────────────┘                              │
│                                                                         │
│   Gremlin → SQL/API translation at runtime                             │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Phân tích chi tiết

### Approach 1: Full Graph Database

**Khi nào phù hợp:**
- Greenfield project hoặc có thể migrate data
- Employee data có relationships phức tạp, deep hierarchies
- Nhiều use cases khác cần graph queries (org chart, skill matching, succession planning)
- Scale lớn với complex traversals

**Trade-offs:**
- Cần sync data từ source systems → Graph DB
- Thêm infrastructure để maintain
- Team cần learn graph database operations

### Approach 2: Schema-only + Translation

**Khi nào phù hợp:**
- Employee data đã tồn tại trong RDBMS/API
- Chỉ cần eligibility filtering, không cần deep graph operations
- Muốn minimize infrastructure changes
- Rules chủ yếu filter trên attributes, ít complex traversals

**Trade-offs:**
- Translation layer có thể complex
- Không leverage full Gremlin power
- Performance có thể kém hơn cho complex queries

---

## Approach 3 (Recommended): Hybrid - TinkerGraph In-Memory

**Đây có thể là sweet spot cho use case của bạn:**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         APPROACH 3                                      │
│              In-Memory TinkerGraph + Lazy Loading                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   ┌──────────────────────────────────────────────────────────┐         │
│   │                  Eligibility Engine                      │         │
│   │  ┌────────────────────────────────────────────────────┐ │         │
│   │  │              TinkerGraph (In-Memory)               │ │         │
│   │  │                                                    │ │         │
│   │  │   Employee vertices + relationships               │ │         │
│   │  │   Loaded on-demand, cached, refreshed periodically│ │         │
│   │  └────────────────────────────────────────────────────┘ │         │
│   │                          ▲                              │         │
│   │                          │ Load/Sync                    │         │
│   │                          │                              │         │
│   └──────────────────────────┼──────────────────────────────┘         │
│                              │                                         │
│              ┌───────────────┴───────────────┐                        │
│              ▼                               ▼                        │
│      ┌──────────────┐               ┌──────────────┐                  │
│      │    RDBMS     │               │  HR System   │                  │
│      │  (Employee   │               │    APIs      │                  │
│      │   tables)    │               │              │                  │
│      └──────────────┘               └──────────────┘                  │
│                                                                        │
│   - No separate DB infrastructure                                      │
│   - Full Gremlin power                                                │
│   - Data synced periodically hoặc on-demand                           │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Implementation: In-Memory TinkerGraph Engine

```java
@Service
public class EligibilityEngine {
    
    private final Graph graph;
    private final GraphTraversalSource g;
    private final EmployeeDataSource employeeDataSource;
    private final ScriptEngine gremlinEngine;
    
    private volatile LocalDateTime lastRefresh;
    private final Duration refreshInterval = Duration.ofMinutes(15);
    
    public EligibilityEngine(EmployeeDataSource employeeDataSource) {
        this.employeeDataSource = employeeDataSource;
        this.graph = TinkerGraph.open();
        this.g = graph.traversal();
        this.gremlinEngine = new GremlinGroovyScriptEngine();
        
        // Initial load
        refreshGraph();
    }
    
    /**
     * Load/refresh employee data vào in-memory graph
     */
    @Scheduled(fixedRate = 900000) // 15 minutes
    public synchronized void refreshGraph() {
        log.info("Refreshing employee graph...");
        
        // Clear existing
        g.V().drop().iterate();
        
        // Load employees
        List<EmployeeDTO> employees = employeeDataSource.getAllEmployees();
        Map<String, Vertex> employeeVertices = new HashMap<>();
        
        for (EmployeeDTO emp : employees) {
            Vertex v = g.addV("employee")
                .property("id", emp.getId())
                .property("name", emp.getName())
                .property("email", emp.getEmail())
                .property("employment_type", emp.getEmploymentType())
                .property("hire_date", emp.getHireDate())
                .property("tenure_years", emp.getTenureYears())
                .property("status", emp.getStatus())
                .next();
            employeeVertices.put(emp.getId(), v);
        }
        
        // Load departments
        Map<String, Vertex> deptVertices = new HashMap<>();
        for (DepartmentDTO dept : employeeDataSource.getAllDepartments()) {
            Vertex v = g.addV("department")
                .property("id", dept.getId())
                .property("name", dept.getName())
                .property("code", dept.getCode())
                .next();
            deptVertices.put(dept.getId(), v);
        }
        
        // Load positions, grades, locations...
        Map<String, Vertex> positionVertices = loadPositions();
        Map<String, Vertex> gradeVertices = loadGrades();
        Map<String, Vertex> locationVertices = loadLocations();
        
        // Create edges (relationships)
        for (EmployeeDTO emp : employees) {
            Vertex empVertex = employeeVertices.get(emp.getId());
            
            // works_in department
            if (emp.getDepartmentId() != null) {
                g.V(empVertex).addE("works_in")
                    .to(deptVertices.get(emp.getDepartmentId()))
                    .iterate();
            }
            
            // has_position
            if (emp.getPositionId() != null) {
                g.V(empVertex).addE("has_position")
                    .to(positionVertices.get(emp.getPositionId()))
                    .iterate();
            }
            
            // works_at location
            if (emp.getLocationId() != null) {
                g.V(empVertex).addE("works_at")
                    .to(locationVertices.get(emp.getLocationId()))
                    .iterate();
            }
            
            // reports_to manager
            if (emp.getManagerId() != null && employeeVertices.containsKey(emp.getManagerId())) {
                g.V(empVertex).addE("reports_to")
                    .to(employeeVertices.get(emp.getManagerId()))
                    .iterate();
            }
        }
        
        // Position -> Grade edges
        for (PositionDTO pos : employeeDataSource.getAllPositions()) {
            if (pos.getGradeId() != null) {
                g.V(positionVertices.get(pos.getId()))
                    .addE("has_grade")
                    .to(gradeVertices.get(pos.getGradeId()))
                    .iterate();
            }
        }
        
        lastRefresh = LocalDateTime.now();
        log.info("Graph refreshed: {} employees, {} departments", 
            employees.size(), deptVertices.size());
    }
    
    /**
     * Execute eligibility rule - NO validation needed (đã validate khi save)
     */
    public List<String> getEligibleEmployeeIds(String gremlinQuery) {
        ensureFreshGraph();
        
        Bindings bindings = gremlinEngine.createBindings();
        bindings.put("g", g);
        bindHelperFunctions(bindings);
        
        try {
            @SuppressWarnings("unchecked")
            GraphTraversal<Vertex, Vertex> traversal = 
                (GraphTraversal<Vertex, Vertex>) gremlinEngine.eval(gremlinQuery, bindings);
            
            return traversal.toStream()
                .map(v -> (String) v.property("id").value())
                .collect(Collectors.toList());
                
        } catch (ScriptException e) {
            // Should not happen if validated at save time
            throw new RuleExecutionException("Unexpected error executing rule", e);
        }
    }
    
    /**
     * Check single employee
     */
    public boolean isEligible(String gremlinQuery, String employeeId) {
        ensureFreshGraph();
        
        // Optimize: filter to single employee first
        String optimizedQuery = gremlinQuery.replaceFirst(
            "g\\.V\\(\\)\\.hasLabel\\(['\"]employee['\"]\\)",
            "g.V().hasLabel('employee').has('id', '" + employeeId + "')"
        );
        
        Bindings bindings = gremlinEngine.createBindings();
        bindings.put("g", g);
        bindHelperFunctions(bindings);
        
        try {
            GraphTraversal<?, ?> traversal = 
                (GraphTraversal<?, ?>) gremlinEngine.eval(optimizedQuery, bindings);
            return traversal.hasNext();
        } catch (ScriptException e) {
            throw new RuleExecutionException("Unexpected error", e);
        }
    }
    
    private void ensureFreshGraph() {
        if (lastRefresh == null || 
            Duration.between(lastRefresh, LocalDateTime.now()).compareTo(refreshInterval) > 0) {
            refreshGraph();
        }
    }
    
    private void bindHelperFunctions(Bindings bindings) {
        bindings.put("today", LocalDate.now());
        bindings.put("yearsAgo", (IntFunction<LocalDate>) years -> 
            LocalDate.now().minusYears(years));
        bindings.put("monthsAgo", (IntFunction<LocalDate>) months -> 
            LocalDate.now().minusMonths(months));
        bindings.put("daysAgo", (IntFunction<LocalDate>) days -> 
            LocalDate.now().minusDays(days));
    }
}
```

---

## Rule Service với Pre-validated Queries

```java
@Service
public class EligibilityRuleService {
    
    private final EligibilityRuleRepository repository;
    private final RuleValidator validator;
    private final EligibilityEngine engine;
    
    /**
     * Save rule - VALIDATE HERE, không validate khi execute
     */
    public EligibilityRule saveRule(EligibilityRule rule) {
        // Validate syntax và security
        ValidationResult validation = validator.validate(rule.getGremlinQuery());
        
        if (!validation.isValid()) {
            throw new InvalidRuleException(validation.getErrors());
        }
        
        // Test execute với limit để ensure nó chạy được
        try {
            String testQuery = rule.getGremlinQuery() + ".limit(1)";
            engine.getEligibleEmployeeIds(testQuery);
        } catch (Exception e) {
            throw new InvalidRuleException("Rule failed test execution: " + e.getMessage());
        }
        
        rule.setStatus(RuleStatus.VALIDATED);
        rule.setValidatedAt(LocalDateTime.now());
        
        return repository.save(rule);
    }
    
    /**
     * Execute rule - NO validation, trust pre-validated query
     */
    public List<String> executeRule(String ruleId) {
        EligibilityRule rule = repository.findById(ruleId)
            .orElseThrow(() -> new RuleNotFoundException(ruleId));
        
        if (rule.getStatus() != RuleStatus.VALIDATED && 
            rule.getStatus() != RuleStatus.ACTIVE) {
            throw new InvalidRuleStateException("Rule not validated");
        }
        
        // Direct execution - no validation overhead
        return engine.getEligibleEmployeeIds(rule.getGremlinQuery());
    }
}
```

---

## Graph Schema Definition

Lưu schema để validate queries và document structure:

```java
@Configuration
public class EmployeeGraphSchema {
    
    /**
     * Schema definition - used for validation và documentation
     */
    public static final GraphSchema SCHEMA = GraphSchema.builder()
        
        // Vertex labels với properties
        .vertex("employee", v -> v
            .property("id", String.class, required())
            .property("name", String.class, required())
            .property("email", String.class, required())
            .property("employment_type", String.class, required())  // full-time, part-time, contractor
            .property("hire_date", LocalDate.class, required())
            .property("tenure_years", Integer.class, computed())
            .property("status", String.class, required())  // active, inactive, terminated
            .property("birth_date", LocalDate.class, optional())
            .property("gender", String.class, optional())
        )
        
        .vertex("department", v -> v
            .property("id", String.class, required())
            .property("name", String.class, required())
            .property("code", String.class, required())
            .property("cost_center", String.class, optional())
        )
        
        .vertex("position", v -> v
            .property("id", String.class, required())
            .property("title", String.class, required())
            .property("job_family", String.class, optional())
        )
        
        .vertex("grade", v -> v
            .property("id", String.class, required())
            .property("name", String.class, required())
            .property("level", Integer.class, required())  // 1-15
        )
        
        .vertex("location", v -> v
            .property("id", String.class, required())
            .property("name", String.class, required())
            .property("city", String.class, required())
            .property("country", String.class, required())
            .property("region", String.class, optional())
        )
        
        .vertex("benefit_plan", v -> v
            .property("id", String.class, required())
            .property("name", String.class, required())
            .property("plan_type", String.class, required())  // health, dental, vision, 401k
        )
        
        // Edge labels với directions
        .edge("works_in", e -> e
            .from("employee").to("department")
            .property("start_date", LocalDate.class, optional())
        )
        
        .edge("has_position", e -> e
            .from("employee").to("position")
            .property("start_date", LocalDate.class, optional())
        )
        
        .edge("has_grade", e -> e
            .from("position").to("grade")
        )
        
        .edge("works_at", e -> e
            .from("employee").to("location")
        )
        
        .edge("reports_to", e -> e
            .from("employee").to("employee")
        )
        
        .edge("enrolled_in", e -> e
            .from("employee").to("benefit_plan")
            .property("enrollment_date", LocalDate.class, optional())
            .property("coverage_level", String.class, optional())
        )
        
        .edge("belongs_to", e -> e
            .from("department").to("division")
        )
        
        .build();
}
```

---

## So sánh final

| Aspect | Full Graph DB | In-Memory TinkerGraph |
|--------|---------------|----------------------|
| **Infrastructure** | Separate DB cluster | JVM heap only |
| **Data freshness** | Real-time possible | Periodic refresh |
| **Scale** | Millions of employees | Thousands (heap limited) |
| **Query power** | Full Gremlin | Full Gremlin |
| **Latency** | Network + DB | In-memory, very fast |
| **Complexity** | Higher ops overhead | Simpler deployment |
| **Cost** | DB licensing/hosting | Minimal |

---

## Recommendation

Với HCM system, **In-Memory TinkerGraph** là lựa chọn tốt vì:

1. Employee count thường < 100K (fit trong memory)
2. Eligibility rules không cần real-time data (refresh 15-30 phút OK)
3. Simpler architecture, không cần thêm infrastructure
4. Full Gremlin power cho complex rules
5. Validation tại save time, execution tại runtime không cần re-validate

Bạn có muốn tôi elaborate thêm về refresh strategy, caching, hoặc handling edge cases (new employees, terminated employees)?


----
