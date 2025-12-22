# Verification Gateway System

**Purpose**: Enable AI-to-AI verification through structured validation gates  
**Approach**: Constraint-based validation + Independent Verifier Agent

---

## 1. Verification Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         VERIFICATION ARCHITECTURE                           │
│                                                                             │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐              │
│  │  Phase 1 │───▶│  Gate 1  │───▶│  Phase 2 │───▶│  Gate 2  │───▶ ...     │
│  │  Ingest  │    │  Verify  │    │  Analyze │    │  Verify  │              │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘              │
│       │               │               │               │                     │
│       ▼               ▼               ▼               ▼                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐              │
│  │  Output  │    │ Manifest │    │  Output  │    │ Manifest │              │
│  │   + Log  │    │  Check   │    │   + Log  │    │  Check   │              │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘              │
│                                                                             │
│                    ┌─────────────────────────────┐                          │
│                    │   INDEPENDENT VERIFIER      │                          │
│                    │   (Cross-validation Agent)  │                          │
│                    └─────────────────────────────┘                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Verification Levels

### Level 1: Structural Validation (Automated)
- Format compliance
- Required fields present
- Data types correct
- No placeholders (TODO, TBD)

### Level 2: Consistency Validation (Automated)
- Cross-references valid
- IDs unique
- Relationships bidirectional
- Naming conventions followed

### Level 3: Traceability Validation (AI-Assisted)
- Every output traces to input
- No orphan elements
- Coverage complete

### Level 4: Semantic Validation (AI Verifier)
- Logic makes sense
- Domain patterns correct
- No contradictions
- Assumptions reasonable

---

## 3. Gate Definitions

### Gate 1: Post-Ingest Verification

**Location**: After Phase 1, before Phase 2  
**Manifest**: `_output/_logs/gate-1-manifest.yaml`

```yaml
gate: 1
name: "Post-Ingest Verification"
phase_verified: "Phase 1 - Ingest"
timestamp: "[ISO timestamp]"

# Structural Checks (Automated)
structural_checks:
  - check: "ingestion-report.md exists"
    status: PASS | FAIL
    
  - check: "All input files cataloged"
    status: PASS | FAIL
    details:
      input_files_count: [N]
      cataloged_count: [N]
      missing: []
      
  - check: "File summaries present"
    status: PASS | FAIL
    details:
      files_with_summary: [N]
      files_without_summary: []

# Consistency Checks (Automated)
consistency_checks:
  - check: "No duplicate file entries"
    status: PASS | FAIL
    
  - check: "All file paths valid"
    status: PASS | FAIL

# Traceability Checks
traceability_checks:
  - check: "project-context.md processed"
    status: PASS | FAIL
    evidence: "[quote from ingestion report]"

# Verification Result
result:
  status: PASS | FAIL | WARN
  blocking_failures: []
  warnings: []
  
proceed_to_next_phase: true | false
```

### Gate 2: Post-Analysis Verification

**Location**: After Phase 2, before Phase 3  
**Manifest**: `_output/_logs/gate-2-manifest.yaml`

```yaml
gate: 2
name: "Post-Analysis Verification"
phase_verified: "Phase 2 - Analyze"
timestamp: "[ISO timestamp]"

# Structural Checks
structural_checks:
  - check: "analysis-report.md exists"
    status: PASS | FAIL
    
  - check: "Entities section present"
    status: PASS | FAIL
    details:
      entity_count: [N]
      
  - check: "Workflows section present"
    status: PASS | FAIL
    details:
      workflow_count: [N]
      
  - check: "Business rules section present"
    status: PASS | FAIL
    details:
      rule_count: [N]

# Consistency Checks
consistency_checks:
  - check: "All entities have classification"
    status: PASS | FAIL
    details:
      classified: [N]
      unclassified: []
      
  - check: "All entities have confidence level"
    status: PASS | FAIL
    
  - check: "Confidence levels valid (HIGH|MEDIUM|LOW|ASSUMED)"
    status: PASS | FAIL
    invalid_values: []

# Traceability Checks (Critical)
traceability_checks:
  - check: "Every entity traces to input source"
    status: PASS | FAIL
    details:
      with_source: [N]
      without_source: []
      sources_referenced:
        - source: "user-stories.md"
          entities_from_source: [list]
        - source: "interview-hr.md"
          entities_from_source: [list]
          
  - check: "Every workflow traces to input source"
    status: PASS | FAIL
    details:
      with_source: [N]
      without_source: []
      
  - check: "Assumed items documented"
    status: PASS | FAIL
    details:
      assumed_count: [N]
      assumed_items:
        - item: "[item]"
          assumption_documented: true | false

# Semantic Checks (AI Verifier)
semantic_checks:
  - check: "Entity names follow domain conventions"
    status: PASS | FAIL | WARN
    notes: "[AI reasoning]"
    
  - check: "Workflow actors align with roles in context"
    status: PASS | FAIL | WARN
    notes: "[AI reasoning]"
    
  - check: "No obvious missing entities for domain"
    status: PASS | FAIL | WARN
    notes: "[AI reasoning]"
    potential_missing: []

# Coverage Analysis
coverage:
  input_files_processed: [N] / [Total]
  entities_per_source:
    "[source1]": [N]
    "[source2]": [N]
  coverage_gaps: []

# Verification Result
result:
  status: PASS | FAIL | WARN
  blocking_failures: []
  warnings: []
  
proceed_to_next_phase: true | false
```

### Gate 3: Post-DRD Verification

**Location**: After Phase 3, before Phase 4  
**Manifest**: `_output/_logs/gate-3-manifest.yaml`

```yaml
gate: 3
name: "Post-DRD Verification"
phase_verified: "Phase 3 - Synthesize DRD"
timestamp: "[ISO timestamp]"

# Structural Checks
structural_checks:
  - check: "DRD document exists"
    status: PASS | FAIL
    
  - check: "All required sections present"
    status: PASS | FAIL
    details:
      required_sections:
        - section: "1. Context"
          present: true | false
        - section: "2. Domain Concepts"
          present: true | false
        - section: "3. Business Rules"
          present: true | false
        - section: "4. Workflows"
          present: true | false
        - section: "5. Data Examples"
          present: true | false
          
  - check: "No TODO/TBD placeholders"
    status: PASS | FAIL
    details:
      placeholders_found: []

# Consistency Checks
consistency_checks:
  - check: "All entities from analysis appear in DRD"
    status: PASS | FAIL
    details:
      analysis_entities: [N]
      drd_entities: [N]
      missing_in_drd: []
      
  - check: "All workflows from analysis appear in DRD"
    status: PASS | FAIL
    details:
      analysis_workflows: [N]
      drd_workflows: [N]
      missing_in_drd: []
      
  - check: "Business rule IDs unique"
    status: PASS | FAIL
    duplicates: []
    
  - check: "Workflow IDs unique"
    status: PASS | FAIL
    duplicates: []

# Traceability Checks
traceability_checks:
  - check: "DRD concepts trace to analysis entities"
    status: PASS | FAIL
    mapping:
      "[DRD Concept 1]": "[Analysis Entity]"
      "[DRD Concept 2]": "[Analysis Entity]"
      
  - check: "Confidence markers present throughout"
    status: PASS | FAIL
    sections_without_confidence: []

# Semantic Checks (AI Verifier)
semantic_checks:
  - check: "Business rules are actionable"
    status: PASS | FAIL | WARN
    notes: "[AI reasoning]"
    vague_rules: []
    
  - check: "Workflow steps are complete"
    status: PASS | FAIL | WARN
    notes: "[AI reasoning]"
    incomplete_workflows: []
    
  - check: "Examples are realistic"
    status: PASS | FAIL | WARN
    notes: "[AI reasoning]"

# Verification Result
result:
  status: PASS | FAIL | WARN
  blocking_failures: []
  warnings: []
  
proceed_to_next_phase: true | false
```

### Gate 4: Post-Generate Verification (Final)

**Location**: After Phase 4  
**Manifest**: `_output/_logs/gate-4-manifest.yaml`

```yaml
gate: 4
name: "Post-Generate Verification (Final)"
phase_verified: "Phase 4 - Generate Ontology"
timestamp: "[ISO timestamp]"

# Structural Checks
structural_checks:
  - check: "Ontology README exists"
    status: PASS | FAIL
    
  - check: "All entity files generated"
    status: PASS | FAIL
    details:
      expected: [list]
      generated: [list]
      missing: []
      
  - check: "All workflow catalogs generated"
    status: PASS | FAIL
    
  - check: "All concept guides generated"
    status: PASS | FAIL
    
  - check: "No empty files"
    status: PASS | FAIL
    empty_files: []

# Consistency Checks
consistency_checks:
  - check: "All cross-references valid"
    status: PASS | FAIL
    details:
      total_links: [N]
      valid_links: [N]
      broken_links: []
      
  - check: "Entity anchors (#entity-name) exist"
    status: PASS | FAIL
    missing_anchors: []
    
  - check: "Workflow catalog links to concept guides"
    status: PASS | FAIL
    unlinked_workflows: []

# Traceability Checks (End-to-End)
traceability_checks:
  - check: "Every entity traces to DRD concept"
    status: PASS | FAIL
    mapping:
      "[Entity 1]": "[DRD Section 2.x]"
      
  - check: "Every workflow traces to DRD workflow"
    status: PASS | FAIL
    
  - check: "End-to-end traceability: Input → Output"
    status: PASS | FAIL
    trace_matrix:
      - input: "user-stories.md#US-001"
        analysis: "Entity: LeaveRequest"
        drd: "Section 2.1: Leave Request"
        ontology: "domain/leave-entities.md#leave-request"
        concept: "01-concept/leave/request-guide.md"

# Semantic Checks (AI Verifier)
semantic_checks:
  - check: "Entity definitions are complete"
    status: PASS | FAIL | WARN
    incomplete_entities: []
    
  - check: "Concept guides have diagrams"
    status: PASS | FAIL | WARN
    guides_without_diagrams: []
    
  - check: "Business rules linked to entities"
    status: PASS | FAIL | WARN
    unlinked_rules: []

# Quality Metrics
quality_metrics:
  completeness:
    entities_with_examples: "[N]/[Total]"
    entities_with_relationships: "[N]/[Total]"
    workflows_with_exception_handling: "[N]/[Total]"
    
  consistency:
    naming_convention_compliance: "[%]"
    cross_reference_validity: "[%]"
    
  traceability:
    input_to_output_coverage: "[%]"
    assumed_items_ratio: "[%]"

# Final Verification Result
result:
  status: PASS | FAIL | WARN
  blocking_failures: []
  warnings: []
  
pipeline_complete: true | false
ready_for_human_review: true | false
confidence_score: "[0-100]"
```

---

## 4. Independent Verifier Agent

### Purpose

A separate AI Agent that:
1. Did NOT participate in generation
2. Has different prompt/perspective  
3. Cross-validates output against input
4. Challenges assumptions

### Verifier Agent Skill

See: `skills/verifier-agent/SKILL.md`

### Verification Approach

```
┌─────────────────────────────────────────────────────────────────┐
│  INDEPENDENT VERIFIER WORKFLOW                                  │
│                                                                 │
│  1. Load original inputs (_input/)                              │
│  2. Load generated outputs (_output/)                           │
│  3. For each output element:                                    │
│     - Find source in input                                      │
│     - Validate transformation accuracy                          │
│     - Check for missing information                             │
│     - Identify unsupported claims                               │
│  4. Generate verification report                                │
│  5. Flag issues for resolution                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. Constraint Definitions

### Entity Constraints

```yaml
entity_constraints:
  required_fields:
    - name: "Must have name"
    - description: "Must have description (min 20 chars)"
    - classification: "Must be CORE|VALUE_OBJECT|REFERENCE|TRANSACTION"
    
  attribute_constraints:
    - each_attribute_has_type: true
    - each_attribute_has_description: true
    - at_least_one_attribute: true
    
  relationship_constraints:
    - target_entity_exists: true
    - cardinality_valid: "1:1|1:N|N:M|N:1"
    
  traceability_constraints:
    - has_source_reference: true
    - has_confidence_level: true
```

### Workflow Constraints

```yaml
workflow_constraints:
  required_fields:
    - id: "WF-XXX-NNN format"
    - name: "Must have name"
    - trigger: "Must specify trigger"
    - actors: "At least one actor"
    
  flow_constraints:
    - has_main_flow: true
    - main_flow_has_steps: "min 2 steps"
    - each_step_has_actor: true
    
  completeness_constraints:
    - has_outcomes: true
    - references_entities: true
    
  traceability_constraints:
    - has_source_reference: true
    - has_concept_guide_link: true
```

### Business Rule Constraints

```yaml
rule_constraints:
  required_fields:
    - id: "BR-XXX-NNN format"
    - description: "Clear description"
    
  actionability_constraints:
    - has_condition: "When/If clause"
    - has_action: "Then clause"
    
  linkage_constraints:
    - linked_to_entity_or_workflow: true
```

---

## 6. Verification Report Format

### Summary Report

```markdown
# Pipeline Verification Report

**Pipeline Run**: [timestamp]
**Verified By**: [Generator Agent | Independent Verifier]

## Executive Summary

| Gate | Status | Blocking Issues | Warnings |
|------|--------|-----------------|----------|
| Gate 1 | ✅ PASS | 0 | 2 |
| Gate 2 | ⚠️ WARN | 0 | 5 |
| Gate 3 | ✅ PASS | 0 | 1 |
| Gate 4 | ✅ PASS | 0 | 3 |

**Overall Status**: PASS with warnings  
**Confidence Score**: 87/100

## Traceability Matrix

| Input Source | Entities | Workflows | Rules | Coverage |
|--------------|----------|-----------|-------|----------|
| user-stories.md | 5 | 3 | 8 | 100% |
| interview-hr.md | 3 | 2 | 4 | 100% |
| existing-docs/ | 2 | 1 | 2 | 80% |

## Issues Found

### Blocking (Must Fix)
None

### Warnings (Should Review)
1. [Gate 2] Entity "ApprovalChain" has no source reference
2. [Gate 3] Business rule BR-LV-005 is vague
3. ...

## Recommendations
1. Add source for ApprovalChain entity
2. Clarify BR-LV-005 with specific conditions
3. ...
```

---

## 7. Usage

### Option A: Self-Verification (Same Agent)

```
AI Agent runs pipeline with gates:
1. Execute Phase 1
2. Run Gate 1 verification → Generate manifest
3. If PASS: Execute Phase 2
4. Run Gate 2 verification → Generate manifest
5. Continue...
```

### Option B: Independent Verification (Separate Agent)

```
Agent 1 (Generator):
1. Execute full pipeline
2. Generate outputs

Agent 2 (Verifier):
1. Load inputs and outputs
2. Run all gate verifications
3. Generate verification report
4. Flag issues
```

### Option C: Hybrid

```
Generator Agent:
1. Execute phase
2. Run structural/consistency checks (automated)
3. Generate manifest

Verifier Agent:
1. Run semantic checks
2. Validate traceability
3. Challenge assumptions
```
