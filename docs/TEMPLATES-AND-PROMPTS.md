# Templates & AI Prompts - Quick Reference

> Complete list of available templates and AI prompts for xTalent documentation

---

## 📋 Templates (_templates/)

### 1. **ontology-template.yaml**
**Purpose**: Define domain entities, attributes, relationships, and rules

**When to use**: Creating ontology for a new module or feature

**Key sections**:
- Entity definition
- Attributes with types
- Relationships
- Lifecycle states
- Business rules
- Constraints
- Validations

**Example entities**: LeaveType, LeaveRequest, Worker, Position

---

### 2. **concept-overview-template.md**
**Purpose**: Explain what a module/feature is and why it exists

**When to use**: Starting documentation for a new module

**Key sections**:
- What is this module?
- Problem statement
- High-level solution
- Scope (in/out)
- Key concepts
- Business value
- Integration points
- Assumptions & dependencies

**Audience**: PO, BA, non-technical stakeholders

---

### 3. **conceptual-guide-template.md**
**Purpose**: Explain HOW the system works at a conceptual level

**When to use**: After concept overview, before technical specs

**Key sections**:
- System overview
- Key workflows (with Mermaid diagrams)
- Domain behaviors
- Entity interactions
- State transitions
- Business rules in action
- Integration patterns
- Real-world scenarios

**Audience**: BA, Tech Lead, Developers

---

### 4. **behaviour-spec-template.md**
**Purpose**: Define detailed business logic and behavioral requirements

**When to use**: Ready to specify implementation details

**Key sections**:
- Use cases
- Scenarios (happy path, edge cases)
- Business rules
- Validation rules (field-level, cross-field, entity-level)
- Calculations
- State transitions
- Permissions matrix
- Error handling
- Integration points
- Performance requirements
- Audit requirements
- Test scenarios
- Acceptance criteria

**Audience**: Developers, QA, AI Agents

---

### 5. **api-spec-template.yaml**
**Purpose**: Define RESTful API specification (OpenAPI 3.0)

**When to use**: Designing API for a module

**Key sections**:
- Endpoints (CRUD + custom actions)
- Request/Response schemas
- Query parameters (pagination, filtering, sorting)
- Error responses
- Authentication/Authorization
- Examples

**Audience**: Frontend developers, API consumers, AI Agents

---

### 6. **ui-spec-template.md**
**Purpose**: Define UI layout, components, states, and interactions

**When to use**: Designing user interface for a feature

**Key sections**:
- Layout structure
- Components (fields, buttons, etc.)
- Field matrix
- States (initial, loading, error, success)
- Interactions (user actions → system responses)
- Data binding
- Validation (client-side, server-side)
- Error handling
- Accessibility
- Performance
- Mockup references

**Audience**: Frontend developers, UX designers, AI Agents

---

## 🤖 AI Prompts (_ai-prompts/)

### 1. **generate-concept-from-ontology.md**
**Purpose**: Generate concept documents from ontology

**Input**: Ontology YAML file

**Output**: 
- Concept Overview (MD)
- Conceptual Guide (MD)
- Entity Concept Guides (MD per entity)

**Use case**: 
```
"I have an ontology for Leave Management. Generate concept docs."
```

**Key features**:
- Explains business purpose
- Uses non-technical language
- Includes examples
- Shows workflows

---

### 2. **generate-api-from-ontology.md**
**Purpose**: Generate OpenAPI specification from ontology and behavioural spec

**Input**: 
- Ontology YAML
- Behavioural Spec MD

**Output**: OpenAPI 3.0 YAML specification

**Use case**:
```
"Generate REST API for Leave Request based on ontology and business rules."
```

**Key features**:
- CRUD endpoints
- Pagination, filtering, sorting
- Validation rules → schema constraints
- Error codes → error responses
- Custom actions (approve, reject, etc.)

---

### 3. **generate-ui-from-spec.md**
**Purpose**: Generate UI code (HTML + HTMX + Shoelace) from specifications

**Input**:
- UI Spec MD
- API Spec YAML

**Output**: Complete HTML file with embedded CSS

**Use case**:
```
"Generate leave request form using HTMX and Shoelace."
```

**Key features**:
- Shoelace web components
- HTMX for server interactions
- Client-side validation
- Error handling
- Loading states
- Responsive design
- Accessibility

---

### 4. **generate-tests-from-scenarios.md**
**Purpose**: Generate test code from behavioural specifications

**Input**:
- Behavioural Spec MD
- API Spec YAML (for integration tests)
- UI Spec MD (for E2E tests)

**Output**: Test code (Jest, Playwright)

**Test types**:
- **Unit tests**: Business logic, calculations, validations
- **Integration tests**: API endpoints, error handling
- **E2E tests**: User workflows, UI interactions

**Use case**:
```
"Generate unit tests for leave balance calculation."
"Generate E2E tests for leave request submission flow."
```

**Key features**:
- AAA pattern (Arrange, Act, Assert)
- Positive and negative cases
- Edge cases
- Mocking
- Setup/teardown

---

## 📊 Usage Matrix

| I want to... | Use Template | Then Use AI Prompt |
|--------------|--------------|-------------------|
| Define domain entities | ontology-template.yaml | - |
| Explain module purpose | concept-overview-template.md | generate-concept-from-ontology.md |
| Explain how it works | conceptual-guide-template.md | generate-concept-from-ontology.md |
| Specify business logic | behaviour-spec-template.md | - |
| Design API | api-spec-template.yaml | generate-api-from-ontology.md |
| Design UI | ui-spec-template.md | - |
| Generate UI code | - | generate-ui-from-spec.md |
| Generate tests | - | generate-tests-from-scenarios.md |

---

## 🔄 Typical Workflow

### Phase 1: Define Domain (Manual)
1. Use **ontology-template.yaml** to define entities
2. Review and refine with team

### Phase 2: Generate Concepts (AI-Assisted)
3. Use **generate-concept-from-ontology.md** prompt
4. AI generates concept overview and guides
5. Review and refine generated content

### Phase 3: Specify Behavior (Manual)
6. Use **behaviour-spec-template.md** to define logic
7. Review with BA and Tech Lead

### Phase 4: Design API (AI-Assisted)
8. Use **generate-api-from-ontology.md** prompt
9. AI generates OpenAPI spec
10. Review and refine

### Phase 5: Design UI (Manual)
11. Use **ui-spec-template.md** to define UI
12. Review with UX designer

### Phase 6: Generate Code (AI-Assisted)
13. Use **generate-ui-from-spec.md** to generate UI code
14. Review and customize

### Phase 7: Generate Tests (AI-Assisted)
15. Use **generate-tests-from-scenarios.md** to generate tests
16. Review and add custom tests

---

## 💡 Tips for Success

### Using Templates
✅ **DO**:
- Fill in all sections, even if brief
- Use examples to clarify
- Review with relevant stakeholders
- Keep templates updated as project evolves

❌ **DON'T**:
- Skip sections (mark as "TBD" if needed)
- Copy-paste without customizing
- Forget to version control

### Using AI Prompts
✅ **DO**:
- Provide complete input files
- Specify desired output format
- Review and refine AI output
- Iterate with follow-up prompts
- Save good prompts for reuse

❌ **DON'T**:
- Blindly accept AI output
- Provide incomplete inputs
- Expect AI to invent requirements
- Skip human review

---

## 📈 Metrics

### Templates Created: 6
1. ontology-template.yaml
2. concept-overview-template.md
3. conceptual-guide-template.md
4. behaviour-spec-template.md
5. api-spec-template.yaml
6. ui-spec-template.md

### AI Prompts Created: 4
1. generate-concept-from-ontology.md
2. generate-api-from-ontology.md
3. generate-ui-from-spec.md
4. generate-tests-from-scenarios.md

### Coverage
- ✅ Ontology layer
- ✅ Concept layer
- ✅ Specification layer
- ✅ Design layer (API)
- ✅ UI layer
- ✅ Test layer

---

## 🎯 Next Steps

### Additional Templates to Create (Optional)
- [ ] data-model-template.dbml
- [ ] test-scenario-template.md
- [ ] adr-template.md (Architectural Decision Record)
- [ ] entity-concept-template.md

### Additional AI Prompts to Create (Optional)
- [ ] generate-dbml-from-ontology.md
- [ ] generate-code-from-api.md
- [ ] generate-documentation.md
- [ ] refine-ontology.md

---

## 📞 Support

### Questions?
- **Template usage**: See template comments and examples
- **AI prompt usage**: See prompt documentation and examples
- **Best practices**: See main README.md
- **Workflow**: See STRUCTURE.md

### Feedback
- Template improvements: Create issue or PR
- New template requests: Discuss with team
- AI prompt refinements: Share successful variations

---

**Last Updated**: 2025-11-28  
**Version**: 1.0  
**Maintained By**: xTalent Documentation Team
