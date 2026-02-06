# OrganizationRelation Sub-Module - Glossary

**Version**: 2.0  
**Last Updated**: 2025-12-01  
**Sub-Module**: Dynamic Organizational Relationships

---

## 📋 Overview

The OrganizationRelation sub-module enables modeling of complex, dynamic relationships between organizational entities beyond simple hierarchies. This supports matrix organizations, project teams, financial reporting structures, and other non-hierarchical relationships.

**Purpose**: Provide flexibility to model multiple relationship graphs overlaid on the organizational structure.

### Entities (3)
1. **RelationSchema** - Relationship graph templates
2. **RelationType** 🔄 (Enhanced with explicit reporting types)
3. **RelationEdge** - Actual relationship instances

---

## 🔑 Key Entities

### RelationType 🔄 ENHANCED

**Definition**: Types of relationships that can exist between organizational entities (legal entities, business units, positions).

**Purpose**:
- Define relationship semantics
- Support multiple relationship contexts
- Enable matrix and network organizations
- Distinguish primary vs secondary relationships

**Key Attributes**:
- `code` - Relationship type code
- `name` - Display name
- `relationship_category` ✨ - Category (NEW in v2.0)
  - `STRUCTURAL` - Organizational structure
  - `REPORTING` - Reporting relationships
  - `FUNCTIONAL` - Functional relationships
  - `FINANCIAL` - Financial/budget flows
- `is_primary_reporting` ✨ - Primary reporting flag (NEW)
- `affects_approval_chain` ✨ - Impacts approvals (NEW)
- `is_bidirectional` - Symmetric relationship
- `inverse_type_id` - Inverse relationship type
- `metadata` - Additional properties
- SCD Type 2

**Relationship Types** (Enhanced in v2.0):

| Code | Category | Primary | Affects Approvals | Description |
|------|----------|---------|-------------------|-------------|
| OWNERSHIP | STRUCTURAL | N/A | No | Legal ownership/shareholding |
| ✨ REPORTING_SOLID_LINE | REPORTING | Yes | Yes | Primary reporting (direct manager) |
| ✨ REPORTING_DOTTED_LINE | REPORTING | No | No | Secondary/matrix reporting |
| FUNCTIONAL | FUNCTIONAL | No | No | Functional relationship without authority |
| MATRIX | STRUCTURAL | No | Varies | Matrix organization relationship |
| DELEGATION | FUNCTIONAL | No | Yes | Delegated authority |
| BUDGET_FLOW | FINANCIAL | N/A | No | Budget allocation flow |
| COST_ALLOCATION | FINANCIAL | N/A | No | Cost sharing/allocation |
| PROJECT_MEMBERSHIP | FUNCTIONAL | No | No | Project team membership |

**Solid vs Dotted Line Reporting** ✨ ENHANCED:

```yaml
RelationTypes:
  - code: REPORTING_SOLID_LINE
    name: "Solid Line Reporting"
    category: REPORTING
    is_primary_reporting: true
    affects_approval_chain: true
    description: "Primary reporting relationship"
    metadata:
      implications:
        - "Performance reviews"
        - "Leave approvals"
        - "Compensation decisions"
        - "Career development"
        
  - code: REPORTING_DOTTED_LINE
    name: "Dotted Line Reporting"
    category: REPORTING
    is_primary_reporting: false
    affects_approval_chain: false
    description: "Secondary/matrix reporting"
    metadata:
      implications:
        - "Project guidance"
        - "Functional expertise"
        - "Informational only"
        - "No approval authority"
```

**Business Rules**:
- ✅ Only solid line affects approval chains
- ✅ Dotted line is informational/guidance only
- ✅ One primary reporting relationship per employee
- ✅ Multiple dotted line relationships allowed
- ✅ Solid line typically follows supervisory org
- ✅ Dotted line supports matrix organizations

**Example - Matrix Organization**:
```yaml
Engineer: John
  Solid Line (Primary):
    type: REPORTING_SOLID_LINE
    to: Engineering Manager (Functional)
    affects_approvals: true
    
  Dotted Line (Secondary):
    type: REPORTING_DOTTED_LINE
    to: Project Lead Alpha (Project)
    affects_approvals: false
    
  # Performance review: Engineering Manager
  # Leave approval: Engineering Manager
  # Project guidance: Project Lead Alpha
```

---

### RelationSchema

**Definition**: Defines a relationship graph schema (template) for a specific purpose.

**Purpose**:
- Create multiple independent relationship graphs
- Support different organizational views
- Enable context-specific relationships
- Maintain separation of concerns

**Key Attributes**:
- `code` - Schema code
- `name` - Schema name
- `description` - Purpose and usage
- `applies_to` - Entity types (LEGAL_ENTITY, BUSINESS_UNIT, POSITION)
- `allowed_relation_types` - Permitted relationship types
- `is_active` - Active flag
- `metadata` - Schema-specific rules

**Common Schemas**:

#### 1. Reporting Organization
```yaml
RelationSchema:
  code: REPORTING_ORG
  name: "Reporting Organization"
  description: "Formal reporting structure (solid + dotted line)"
  applies_to: [POSITION, BUSINESS_UNIT]
  allowed_relation_types:
    - REPORTING_SOLID_LINE
    - REPORTING_DOTTED_LINE
  metadata:
    purpose: "Performance management, approvals"
    update_frequency: "As needed"
```

#### 2. Financial Reporting
```yaml
RelationSchema:
  code: FINANCIAL_REPORTING
  name: "Financial Reporting Structure"
  description: "Budget and cost allocation flows"
  applies_to: [BUSINESS_UNIT, LEGAL_ENTITY]
  allowed_relation_types:
    - BUDGET_FLOW
    - COST_ALLOCATION
  metadata:
    purpose: "Financial consolidation, P&L"
    update_frequency: "Monthly"
```

#### 3. Project Matrix
```yaml
RelationSchema:
  code: PROJECT_MATRIX
  name: "Project Organization"
  description: "Project team structures and relationships"
  applies_to: [POSITION, BUSINESS_UNIT]
  allowed_relation_types:
    - PROJECT_MEMBERSHIP
    - REPORTING_DOTTED_LINE
  metadata:
    purpose: "Project management, resource allocation"
    temporary: true
```

#### 4. Innovation Network
```yaml
RelationSchema:
  code: INNOVATION_NETWORK
  name: "Innovation Collaboration Network"
  description: "Cross-functional innovation relationships"
  applies_to: [BUSINESS_UNIT, POSITION]
  allowed_relation_types:
    - FUNCTIONAL
    - MATRIX
  metadata:
    purpose: "Knowledge sharing, collaboration"
    informal: true
```

**Business Rules**:
- ✅ Multiple schemas can coexist
- ✅ Same entities can participate in multiple schemas
- ✅ Each schema has its own relationship rules
- ✅ Schemas can be temporary (projects) or permanent

---

### RelationEdge

**Definition**: Actual relationship instance (edge in the graph) between two organizational entities.

**Purpose**:
- Represent specific relationships
- Link entities in relationship graphs
- Support weighted/attributed relationships
- Enable graph queries and analytics

**Key Attributes**:
- `schema_id` - Which relationship graph
- `from_entity_type` - Source entity type (LEGAL_ENTITY, BUSINESS_UNIT, POSITION)
- `from_entity_id` - Source entity ID
- `to_entity_type` - Target entity type
- `to_entity_id` - Target entity ID
- `relation_type_id` - Type of relationship
- `weight` - Relationship weight/strength (0.0-1.0)
- `percentage` - Percentage allocation (e.g., 60% time on project)
- `metadata` - Edge-specific attributes
- SCD Type 2

**Example 1 - Matrix Reporting**:
```yaml
# Engineer reports to both functional manager and project lead
RelationEdges:
  # Solid Line (Primary)
  - schema: REPORTING_ORG
    from_type: POSITION
    from_id: POS-ENG-001 (John - Engineer)
    to_type: POSITION
    to_id: POS-MGR-ENG (Engineering Manager)
    relation_type: REPORTING_SOLID_LINE
    weight: 1.0
    metadata:
      primary: true
      
  # Dotted Line (Secondary)
  - schema: REPORTING_ORG
    from_type: POSITION
    from_id: POS-ENG-001 (John - Engineer)
    to_type: POSITION
    to_id: POS-LEAD-PROJ-A (Project Lead Alpha)
    relation_type: REPORTING_DOTTED_LINE
    weight: 0.5
    percentage: 40  # 40% time on project
    metadata:
      project_code: PROJ-ALPHA
      start_date: 2024-01-01
      end_date: 2024-12-31
```

**Example 2 - Legal Entity Ownership**:
```yaml
# Parent company owns subsidiaries
RelationEdges:
  - schema: CORPORATE_STRUCTURE
    from_type: LEGAL_ENTITY
    from_id: LE-PARENT-CORP
    to_type: LEGAL_ENTITY
    to_id: LE-SUBSIDIARY-A
    relation_type: OWNERSHIP
    percentage: 100  # 100% ownership
    
  - schema: CORPORATE_STRUCTURE
    from_type: LEGAL_ENTITY
    from_id: LE-PARENT-CORP
    to_type: LEGAL_ENTITY
    to_id: LE-JOINT-VENTURE-B
    relation_type: OWNERSHIP
    percentage: 51  # 51% ownership (majority)
```

**Example 3 - Budget Flow**:
```yaml
# Budget flows from corporate to divisions
RelationEdges:
  - schema: FINANCIAL_REPORTING
    from_type: BUSINESS_UNIT
    from_id: BU-CORPORATE
    to_type: BUSINESS_UNIT
    to_id: BU-ENGINEERING
    relation_type: BUDGET_FLOW
    metadata:
      annual_budget: 10000000
      fiscal_year: 2024
      
  - schema: FINANCIAL_REPORTING
    from_type: BUSINESS_UNIT
    from_id: BU-CORPORATE
    to_type: BUSINESS_UNIT
    to_id: BU-SALES
    relation_type: BUDGET_FLOW
    metadata:
      annual_budget: 5000000
      fiscal_year: 2024
```

**Business Rules**:
- ✅ Edges must belong to a schema
- ✅ Relationship type must be allowed in schema
- ✅ Entity types must match schema constraints
- ✅ Percentages sum to 100% where applicable
- ✅ SCD Type 2 tracks relationship changes
- ⚠️ Avoid circular dependencies in hierarchical schemas

---

## 💡 Use Cases

### Use Case 1: Matrix Organizations

**Scenario**: Engineering team members report to both functional managers and project leads.

```yaml
# Functional Reporting (Solid Line)
Schema: REPORTING_ORG
Edges:
  Engineer A → Engineering Manager (SOLID_LINE)
  Engineer B → Engineering Manager (SOLID_LINE)
  
# Project Reporting (Dotted Line)
Schema: PROJECT_MATRIX
Edges:
  Engineer A → Project Lead Alpha (DOTTED_LINE, 60% time)
  Engineer A → Project Lead Beta (DOTTED_LINE, 40% time)
  Engineer B → Project Lead Alpha (DOTTED_LINE, 100% time)

# Queries:
# - Who reports to Engineering Manager? (Solid line)
# - Who works on Project Alpha? (Dotted line)
# - What's Engineer A's time allocation?
```

### Use Case 2: Multi-Entity Companies

**Scenario**: Track relationships between legal entities (parent, subsidiaries, joint ventures).

```yaml
Schema: CORPORATE_STRUCTURE
Edges:
  Parent Corp → Subsidiary Vietnam (OWNERSHIP, 100%)
  Parent Corp → Subsidiary Singapore (OWNERSHIP, 100%)
  Parent Corp → Joint Venture Thailand (OWNERSHIP, 51%)
  Partner Corp → Joint Venture Thailand (OWNERSHIP, 49%)

# Queries:
# - What entities does Parent Corp own?
# - What's the ownership structure of JV Thailand?
# - Consolidation for financial reporting
```

### Use Case 3: Project Teams

**Scenario**: Temporary project organization overlaid on functional structure.

```yaml
Schema: PROJECT_ALPHA
Edges:
  # Project team members
  Project Lead → Engineer A (PROJECT_MEMBERSHIP)
  Project Lead → Engineer B (PROJECT_MEMBERSHIP)
  Project Lead → Designer C (PROJECT_MEMBERSHIP)
  
  # Dotted line reporting
  Engineer A → Project Lead (DOTTED_LINE)
  Engineer B → Project Lead (DOTTED_LINE)

# When project ends:
# - Set effective_end_date on all edges
# - Edges become historical (is_current = false)
# - Functional reporting remains unchanged
```

### Use Case 4: Cost Allocation

**Scenario**: Shared services costs allocated to business units.

```yaml
Schema: COST_ALLOCATION
Edges:
  Shared Services → Engineering (COST_ALLOCATION, 40%)
  Shared Services → Sales (COST_ALLOCATION, 30%)
  Shared Services → Operations (COST_ALLOCATION, 30%)

# Monthly cost allocation:
# - Shared Services total cost: $100,000
# - Engineering: $40,000
# - Sales: $30,000
# - Operations: $30,000
```

---

## 🔄 Common Scenarios

### Scenario 1: Simple Reporting Structure
```yaml
# Traditional hierarchy (no matrix)
Schema: REPORTING_ORG
Edges:
  Engineer → Team Lead (SOLID_LINE)
  Team Lead → Engineering Manager (SOLID_LINE)
  Engineering Manager → VP Engineering (SOLID_LINE)
```

### Scenario 2: Matrix Organization
```yaml
# Functional + Project reporting
Functional (SOLID_LINE):
  Engineer → Engineering Manager
  
Project (DOTTED_LINE):
  Engineer → Project Lead A (50% time)
  Engineer → Project Lead B (50% time)
```

### Scenario 3: Reorganization
```yaml
# Before (2024-01-01 to 2024-06-30)
Edge:
  Engineer → Manager A (SOLID_LINE)
  effective_start: 2024-01-01
  effective_end: 2024-06-30
  is_current: false

# After (2024-07-01 onwards)
Edge:
  Engineer → Manager B (SOLID_LINE)
  effective_start: 2024-07-01
  effective_end: null
  is_current: true
```

---

## ⚠️ Important Notes

### Solid vs Dotted Line Best Practices
- ✅ Use solid line for primary reporting (one per employee)
- ✅ Use dotted line for matrix/project reporting (multiple allowed)
- ✅ Solid line determines approval authority
- ✅ Dotted line provides guidance/coordination
- ⚠️ Don't confuse with operational vs supervisory org

### Graph Modeling Guidelines
- ✅ Use schemas to separate different relationship contexts
- ✅ Keep schemas focused (one purpose per schema)
- ✅ Use metadata for edge-specific attributes
- ✅ Leverage SCD Type 2 for historical analysis
- ⚠️ Avoid overly complex graphs (performance impact)

### Relationship Maintenance
- ✅ Regular audits of relationship accuracy
- ✅ Clean up ended project relationships
- ✅ Update relationships during reorganizations
- ✅ Document relationship semantics clearly
- ⚠️ Consider impact on in-flight workflows

---

## 🔗 Related Glossaries

- **BusinessUnit** - Units being related
- **LegalEntity** - Legal entity relationships
- **Employment** - Assignment reporting lines (uses solid/dotted line concepts)
- **JobPosition** - Position relationships

---

## 📚 References

- Graph Database Concepts: Neo4j, property graphs
- Workday: Matrix Organizations
- SAP SuccessFactors: Organizational Relationships
- Oracle HCM: Organization Structures

---

**Document Version**: 2.0  
**Last Review**: 2025-12-01
