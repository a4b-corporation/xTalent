# xTalent Documentation

> Comprehensive documentation for xTalent HCM System following Spec-Driven Development methodology

## 📁 Structure Overview

```
docs/
├── 00-global/          # Global ontology, glossary, standards
├── 01-modules/         # Module-specific documentation
│   ├── CO/            # Core HR
│   ├── TA/            # Time & Absence
│   ├── TR/            # Total Rewards
│   └── PR/            # Payroll
├── _templates/         # Document templates
└── _ai-prompts/        # AI agent prompts
```

## 🎯 Documentation Philosophy

This documentation follows the **Spec-Driven Development** approach:

```
Ontology → Concept → Specification → Design → Implementation
```

### Why This Approach?

✅ **Single Source of Truth** - All stakeholders reference the same documentation
✅ **AI-Ready** - Structured specs enable AI-assisted code generation
✅ **Reduced Rework** - Clear specifications prevent misunderstandings
✅ **Faster Onboarding** - New team members can understand the system quickly
✅ **Better Collaboration** - PO, BA, Dev, QA work from shared understanding

## 📚 Documentation Layers

### Layer 0: Global (00-global/)

**Purpose**: Define system-wide concepts, standards, and glossary

**Contents**:
- **ontology/**: Core domain entities used across all modules
- **glossary/**: Domain terminology dictionary
- **speckit/**: SpecKit framework guidelines
- **standards/**: Naming conventions, API standards, UI guidelines

**Who uses it**: Everyone - this is the foundation

---

### Layer 1: Modules (01-modules/)

Each module follows the same structure:

```
{MODULE}/
├── 00-ontology/       # Domain entities, relationships, rules
├── 01-concept/        # What & Why (non-technical)
├── 02-spec/           # Detailed specifications
├── 03-design/         # System & data design
├── 04-api/            # API specifications
├── 05-ui/             # UI specs & mockups
├── 06-tests/          # Test scenarios
└── 07-impl-notes/     # Technical decisions, limitations
```

#### Module Breakdown

**CO (Core HR)**
- Worker management
- Organization structure
- Position management
- Assignment management

**TA (Time & Absence)**
- Leave management
- Attendance tracking
- Time tracking
- Scheduling

**TR (Total Rewards)**
- Compensation management
- Benefits administration
- Grade & salary structure

**PR (Payroll)**
- Payroll calculation
- Tax & deductions
- Payroll reporting

---

## 🚀 Getting Started

### For Product Owners
1. Start with **00-global/glossary/** to understand terminology
2. Read module **01-concept/** to understand what each module does
3. Review **02-spec/** for detailed requirements

### For Business Analysts
1. Understand **00-global/ontology/** - the domain foundation
2. Create/update **{module}/00-ontology/** for new features
3. Write **{module}/01-concept/** documents
4. Define **{module}/02-spec/** with detailed scenarios

### For Developers
1. Read **00-global/** to understand system-wide concepts
2. Review **{module}/00-ontology/** and **01-concept/** for domain understanding
3. Implement based on **02-spec/**, **03-design/**, **04-api/**
4. Use **05-ui/** specs for frontend development
5. Follow **06-tests/** for testing

### For QA Engineers
1. Understand **01-concept/** for feature context
2. Use **02-spec/** to create test scenarios
3. Reference **06-tests/** for acceptance criteria
4. Validate against **04-api/** and **05-ui/** specs

### For AI Agents
1. Read **00-ontology/** for domain model
2. Parse **02-spec/** for business logic
3. Generate code from **03-design/**, **04-api/**, **05-ui/**
4. Create tests from **06-tests/**

---

## 📖 How to Use This Documentation

### Creating New Feature Documentation

1. **Start with Ontology** (`00-ontology/`)
   - Define entities, attributes, relationships
   - Document business rules and constraints
   - Create state machines for entity lifecycle

2. **Write Concept Docs** (`01-concept/`)
   - Explain what the feature does (overview)
   - Describe how it works (conceptual guide)
   - Detail each entity's purpose (entity guides)

3. **Create Specifications** (`02-spec/`)
   - Define use cases and scenarios
   - Specify business logic and validation rules
   - Document edge cases and error handling

4. **Design the System** (`03-design/`)
   - Create data model (DBML)
   - Design event model
   - Plan integrations

5. **Specify APIs** (`04-api/`)
   - Write OpenAPI specification
   - Document request/response schemas
   - Define error codes

6. **Design UI** (`05-ui/`)
   - Create UI specifications
   - Build mockups (HTMX + Shoelace)
   - Define interactions and states

7. **Define Tests** (`06-tests/`)
   - Write acceptance criteria
   - Create test scenarios
   - Specify E2E tests

8. **Document Decisions** (`07-impl-notes/`)
   - Record architectural decisions (ADR)
   - Note limitations and workarounds
   - Plan future improvements

---

## 🤖 AI-Assisted Development

This documentation structure is designed to work seamlessly with AI agents.

### AI Can Generate:

✅ Concept documents from ontology
✅ API specs from ontology + behaviour specs
✅ Database schemas from ontology
✅ UI code from UI specs + API specs
✅ Test code from test scenarios
✅ Implementation code from all specs

### Sample AI Workflows:

```bash
# Generate concept overview from ontology
AI: "Based on TA/00-ontology/absence-ontology.yaml, 
     generate 01-concept/01-concept-overview.md"

# Generate API spec from ontology
AI: "Based on ontology and behaviour-spec.md, 
     generate OpenAPI specification for Leave Request API"

# Generate UI code from specs
AI: "Based on leave-request-form spec and API spec, 
     generate HTMX + Shoelace HTML implementation"

# Generate tests from scenarios
AI: "Based on test-scenarios.md, 
     generate Playwright E2E test specs"
```

See `_ai-prompts/` for more examples.

---

## 📋 Templates

All document templates are available in `_templates/`:

- `ontology-template.yaml` - Entity definition template
- `concept-overview-template.md` - Concept overview template
- `conceptual-guide-template.md` - Conceptual guide template
- `behaviour-spec-template.md` - Behaviour specification template
- `api-spec-template.yaml` - OpenAPI template
- `ui-spec-template.md` - UI specification template
- `test-scenario-template.md` - Test scenario template

---

## 🔍 Finding Information

### By Role

| I want to... | Look in... |
|-------------|-----------|
| Understand a term | `00-global/glossary/` |
| See all entities | `00-global/ontology/` |
| Understand a module | `{module}/01-concept/` |
| See business rules | `{module}/00-ontology/` or `02-spec/` |
| Find API endpoints | `{module}/04-api/` |
| See UI designs | `{module}/05-ui/` |
| Check test cases | `{module}/06-tests/` |

### By Module

- **Core HR**: `01-modules/CO/`
- **Time & Absence**: `01-modules/TA/`
- **Total Rewards**: `01-modules/TR/`
- **Payroll**: `01-modules/PR/`

---

## 🎨 Documentation Standards

### Writing Style
- Use clear, simple language
- Define acronyms on first use
- Use examples to illustrate concepts
- Keep technical jargon in technical sections

### Formatting
- Use Markdown for all documentation
- Use YAML for ontology and data definitions
- Use DBML for database schemas
- Use OpenAPI (YAML) for API specs
- Use Mermaid for diagrams

### Naming Conventions
See `00-global/standards/naming-conventions.md` for detailed guidelines.

---

## 🔄 Keeping Documentation Updated

### When to Update

✅ **Before coding** - Update specs first, then code
✅ **After design decisions** - Document in `07-impl-notes/`
✅ **When requirements change** - Update ontology/concept/spec
✅ **After implementation** - Verify docs match reality

### Review Checklist

- [ ] Ontology reflects current domain model
- [ ] Concept docs explain current features
- [ ] Specs match implementation
- [ ] API docs match actual endpoints
- [ ] UI specs match actual UI
- [ ] Tests cover current scenarios

---

## 📞 Questions?

### Documentation Issues
- Missing information? Create an issue
- Unclear explanation? Suggest improvements
- Found errors? Submit corrections

### Process Questions
- How to structure a new feature? See `00-global/speckit/spec-structure.md`
- How to name things? See `00-global/standards/naming-conventions.md`
- How to use AI? See `_ai-prompts/`

---

## 📈 Metrics

We track documentation quality through:

- **Coverage**: % of features with complete specs
- **Freshness**: Days since last update
- **Completeness**: % of required sections filled
- **Usage**: How often docs are referenced

---

## 🎯 Goals

Our documentation aims to:

1. **Enable autonomous development** - Devs can implement without constant clarification
2. **Facilitate AI assistance** - AI can generate quality code from specs
3. **Accelerate onboarding** - New members productive in days, not weeks
4. **Ensure consistency** - All features follow same patterns
5. **Reduce bugs** - Clear specs prevent misunderstandings

---

**Version**: 1.0.0  
**Last Updated**: 2025-11-28  
**Maintained By**: xTalent Product Team
