# 20. Knowledge Enrichment: The Self-Improving Graph

> [!NOTE]
> **Mục tiêu**: Giải thích cơ chế "Học ngược" (Reverse Engineering). Hệ thống không chỉ dùng Knowledge Graph để sinh code, mà còn dùng Code để làm giàu lại Knowledge Graph.

## Overview

Knowledge Enrichment là "vòng lặp học tập" của hệ thống ODD. Ban đầu, Knowledge Graph chỉ chứa **Spec** (lý thuyết). Sau mỗi lần implementation, nó được làm giàu thêm với **Code** (thực tế), tạo nên một hệ thống ngày càng thông minh hơn.

**Core Principle**: *"Every implementation teaches the system something new"*

## 1. The Enrichment Cycle

### 1.1. From Theory to Reality

```mermaid
graph TD
    subgraph "Initial State (Theory Only)"
        I1[Feature Spec]
        I2[Ontology]
        I3[Business Rules]
    end
    
    subgraph "After Implementation (Theory + Reality)"
        A1[Feature Spec ✅]
        A2[Ontology]
        A3[Business Rules]
        A4[Source Code]
        A5[API Endpoints]
        A6[Database Schema]
        A7[Test Cases]
    end
    
    I1 --> A1
    I2 --> A2
    I3 --> A3
    
    A1 -.->|"Implemented by"| A4
    A4 -.->|"Exposes"| A5
    A4 -.->|"Uses"| A6
    A4 -.->|"Tested by"| A7
    
    style I1 fill:#fff9c4
    style A4 fill:#c8e6c9
    style A5 fill:#c8e6c9
```

### 1.2. What Gets Enriched?

| Layer | Before Implementation | After Implementation |
|-------|----------------------|----------------------|
| **Feature** | Spec only | Spec + Implementation status + Code locations |
| **Ontology** | Entity definition | Entity + Tables + Code classes |
| **Rules** | Rule definition | Rule + Validation functions + Test cases |
| **Graph** | Logical relationships | Logical + Physical relationships |

## 2. Enrichment Mechanisms

### 2.1. Code Scanning & Metadata Extraction

```mermaid
sequenceDiagram
    participant Git
    participant Scanner as ODD Scanner
    participant Parser as Code Parser
    participant Graph as Knowledge Graph
    
    Git->>Scanner: Post-commit hook
    Scanner->>Parser: Parse TypeScript files
    
    Parser->>Parser: Extract traceability comments
    Note over Parser: Found: // [[FEAT-TA-001]]<br/>// [[BR-TA-001]]
    
    Parser->>Parser: Extract function signatures
    Parser->>Parser: Extract API routes
    Parser->>Parser: Extract DB queries
    
    Parser-->>Scanner: Metadata extracted
    
    Scanner->>Graph: Update feature node
    Scanner->>Graph: Create code nodes
    Scanner->>Graph: Link code to spec
    
    Graph-->>Scanner: Graph updated
    Scanner-->>Git: Enrichment complete
```

### 2.2. The Enriched Graph Structure

```mermaid
graph TD
    subgraph "Logical Layer (Spec)"
        F[Feature: FEAT-TA-001<br/>Submit Leave Request]
        E1[Entity: LeaveRequest]
        E2[Entity: Employee]
        R1[Rule: BR-TA-001]
    end
    
    subgraph "Physical Layer (Code)"
        C1[Class: LeaveRequestService]
        C2[Function: submit]
        C3[Function: checkProbation]
        A1[API: POST /api/leave/requests]
        T1[Table: leave_requests]
        T2[Test: LeaveRequestService.spec.ts]
    end
    
    F -.->|"implemented_by"| C1
    F -.->|"exposes"| A1
    F -.->|"tested_by"| T2
    
    E1 -.->|"persisted_in"| T1
    E1 -.->|"mapped_to"| C1
    
    R1 -.->|"enforced_by"| C3
    
    C1 -->|"contains"| C2
    C1 -->|"contains"| C3
    C2 -->|"writes_to"| T1
    
    style F fill:#fff9c4
    style C1 fill:#c8e6c9
    style T1 fill:#e3f2fd
```

### 2.3. Traceability Comment Format

```typescript
/**
 * Submit a new leave request
 * 
 * @implements [[FEAT-TA-001]] Submit Leave Request
 * @uses [[E-LeaveRequest]] LeaveRequest entity
 * @uses [[E-Employee]] Employee entity
 * @enforces [[BR-TA-001]] Probation check
 * @enforces [[BR-TA-002]] Notice period
 * @enforces [[BR-TA-003]] Balance validation
 * @enforces [[BR-TA-004]] Blackout dates
 * @exposes POST /api/v1/leave/requests
 * @persists leave_requests table
 */
async function submitLeaveRequest(employeeId: string, data: LeaveRequestInput) {
  // Implementation...
}
```

## 3. Benefits of Enrichment

### 3.1. Automated Impact Analysis (Real)

**Query**: "Nếu sửa cột `contractType` trong database, những Feature nào sẽ bị ảnh hưởng?"

```cypher
// Cypher query on enriched graph
MATCH (field:Field {name: 'contractType'})<-[:USES]-(code:Code)
MATCH (code)<-[:IMPLEMENTED_BY]-(feature:Feature)
RETURN feature.title, code.filePath, code.lineNumber
```

**Result**:
```json
{
  "affected_features": [
    {
      "feature": "FEAT-TA-001: Submit Leave Request",
      "code_file": "src/services/LeaveRequestService.ts",
      "line": 45,
      "impact": "Uses contractType in probation check"
    },
    {
      "feature": "FEAT-HR-005: Employee Onboarding",
      "code_file": "src/services/OnboardingService.ts",
      "line": 78,
      "impact": "Checks contractType for benefit eligibility"
    }
  ],
  "total_affected": 2,
  "risk_level": "HIGH"
}
```

### 3.2. Dead Code Detection

```mermaid
graph LR
    subgraph "All Code Files"
        C1[LeaveService.ts]
        C2[OldLeaveService.ts]
        C3[UtilityFunctions.ts]
    end
    
    subgraph "Features in Graph"
        F1[FEAT-TA-001]
        F2[FEAT-TA-002]
    end
    
    C1 -.->|"linked to"| F1
    C3 -.->|"linked to"| F2
    C2 -.->|"❌ No link"| X[Dead Code]
    
    style C2 fill:#ffcdd2
    style X fill:#ffcdd2
```

**Scanner Report**:
```
⚠️ Dead Code Detected:
- src/services/OldLeaveService.ts (250 lines)
  - Not linked to any feature
  - Last modified: 6 months ago
  - Recommendation: Archive or delete

- src/utils/LegacyHelpers.ts (180 lines)
  - Not linked to any feature
  - No test coverage
  - Recommendation: Delete
```

### 3.3. Spec Coverage Analysis

```mermaid
graph TD
    subgraph "Spec Coverage Report"
        S1[Total Features: 50]
        S2[Implemented: 42]
        S3[In Progress: 5]
        S4[Not Started: 3]
    end
    
    S1 --> S2
    S1 --> S3
    S1 --> S4
    
    style S2 fill:#c8e6c9
    style S3 fill:#fff9c4
    style S4 fill:#ffcdd2
```

**Dashboard Output**:
```
📊 Implementation Status

✅ Implemented (84%): 42 features
  - All tests passing
  - Code coverage > 90%

🔄 In Progress (10%): 5 features
  - FEAT-TA-010: Leave Balance Report (60% complete)
  - FEAT-HR-015: Performance Review (30% complete)
  - ...

❌ Not Started (6%): 3 features
  - FEAT-PA-020: Payroll Simulation
  - FEAT-HR-025: Career Path Planning
  - FEAT-TA-030: Shift Scheduling
```

## 4. The Continuous Improvement Loop

### 4.1. The Virtuous Cycle

```mermaid
graph TD
    subgraph "Iteration 1"
        I1_1[Write Spec]
        I1_2[AI Generates Code]
        I1_3[Scanner Enriches Graph]
        I1_4[Graph: 100 nodes]
    end
    
    subgraph "Iteration 2"
        I2_1[Write New Spec]
        I2_2[AI Uses Richer Graph]
        I2_3[Better Code Quality]
        I2_4[Graph: 150 nodes]
    end
    
    subgraph "Iteration 3"
        I3_1[Write Another Spec]
        I3_2[AI Even Smarter]
        I3_3[Excellent Code]
        I3_4[Graph: 200 nodes]
    end
    
    I1_1 --> I1_2 --> I1_3 --> I1_4
    I1_4 --> I2_1
    I2_1 --> I2_2 --> I2_3 --> I2_4
    I2_4 --> I3_1
    I3_1 --> I3_2 --> I3_3 --> I3_4
    
    style I1_4 fill:#ffcdd2
    style I2_4 fill:#fff9c4
    style I3_4 fill:#c8e6c9
```

### 4.2. Learning Patterns

As the graph grows, AI learns:

| Iteration | Graph Size | AI Capability |
|-----------|------------|---------------|
| **1** | 100 nodes | Basic code generation |
| **5** | 300 nodes | Recognizes common patterns |
| **10** | 500 nodes | Suggests best practices |
| **20** | 800 nodes | Predicts edge cases |
| **50** | 1500 nodes | Architectural insights |

**Example**:
```
Iteration 1:
AI: "I'll create a basic validation function"

Iteration 10:
AI: "Based on 8 similar features, I suggest:
     - Use decorator pattern for validation
     - Cache policy lookups
     - Add rate limiting
     - Include audit logging"
```

## 5. Implementation: The Scanner Tool

### 5.1. Scanner Architecture

```python
# odd_scanner.py
import ast
import re
from pathlib import Path
import networkx as nx

class ODDScanner:
    def __init__(self, graph: nx.DiGraph):
        self.graph = graph
        
    def scan_file(self, file_path: Path):
        \"\"\"Scan a TypeScript/Python file for traceability comments\"\"\"
        content = file_path.read_text()
        
        # Extract traceability comments
        features = re.findall(r'@implements \[\[(FEAT-[A-Z]+-\d+)\]\]', content)
        rules = re.findall(r'@enforces \[\[(BR-[A-Z]+-\d+)\]\]', content)
        entities = re.findall(r'@uses \[\[(E-[A-Za-z]+)\]\]', content)
        
        # Create code node
        code_node = {
            'type': 'CODE',
            'file_path': str(file_path),
            'features': features,
            'rules': rules,
            'entities': entities
        }
        
        # Add to graph
        node_id = f\"CODE-{file_path.stem}\"
        self.graph.add_node(node_id, **code_node)
        
        # Link to features
        for feature_id in features:
            if self.graph.has_node(feature_id):
                self.graph.add_edge(feature_id, node_id, rel='implemented_by')
                
        # Link to rules
        for rule_id in rules:
            if self.graph.has_node(rule_id):
                self.graph.add_edge(rule_id, node_id, rel='enforced_by')
                
        return code_node
    
    def detect_dead_code(self):
        \"\"\"Find code files not linked to any feature\"\"\"
        dead_code = []
        
        for node_id, data in self.graph.nodes(data=True):
            if data['type'] == 'CODE':
                # Check if linked to any feature
                has_feature = any(
                    self.graph.nodes[pred]['type'] == 'FEATURE'
                    for pred in self.graph.predecessors(node_id)
                )
                
                if not has_feature:
                    dead_code.append(data['file_path'])
                    
        return dead_code
    
    def impact_analysis(self, entity_name: str, field_name: str):
        \"\"\"Analyze impact of changing an entity field\"\"\"
        affected = []
        
        # Find entity node
        entity_node = f\"E-{entity_name}\"
        
        # Find all code using this entity
        for successor in self.graph.successors(entity_node):
            if self.graph.nodes[successor]['type'] == 'CODE':
                # Find features implemented by this code
                for feature in self.graph.predecessors(successor):
                    if self.graph.nodes[feature]['type'] == 'FEATURE':
                        affected.append({
                            'feature': self.graph.nodes[feature]['title'],
                            'code_file': self.graph.nodes[successor]['file_path']
                        })
                        
        return affected
```

### 5.2. CI/CD Integration

```yaml
# .github/workflows/odd-enrichment.yml
name: ODD Knowledge Enrichment

on:
  push:
    branches: [main, develop]

jobs:
  enrich:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run ODD Scanner
        run: |
          python odd_scanner.py scan --dir src/
          
      - name: Update Knowledge Graph
        run: |
          python odd_scanner.py enrich --graph knowledge_graph.graphml
          
      - name: Generate Reports
        run: |
          python odd_scanner.py report --output reports/
          
      - name: Check for Dead Code
        run: |
          python odd_scanner.py dead-code --fail-on-found
```

## 6. Metrics & Evolution

### 6.1. Graph Growth Over Time

| Month | Nodes | Edges | Features | Code Files | Avg. Connections |
|-------|-------|-------|----------|------------|------------------|
| **Month 1** | 150 | 300 | 10 | 25 | 2.0 |
| **Month 3** | 400 | 950 | 30 | 75 | 2.4 |
| **Month 6** | 800 | 2100 | 50 | 150 | 2.6 |
| **Month 12** | 1500 | 4500 | 80 | 250 | 3.0 |

### 6.2. Quality Improvement

```mermaid
graph LR
    subgraph "Quality Metrics Over Time"
        M1[Month 1]
        M6[Month 6]
        M12[Month 12]
    end
    
    M1 -->|"Impact Analysis: 60% accurate"| M6
    M6 -->|"Impact Analysis: 85% accurate"| M12
    
    M1 -->|"Dead Code: 30%"| M6
    M6 -->|"Dead Code: 10%"| M12
    
    M1 -->|"Spec Coverage: 40%"| M6
    M6 -->|"Spec Coverage: 85%"| M12
    
    style M1 fill:#ffcdd2
    style M6 fill:#fff9c4
    style M12 fill:#c8e6c9
```

## Key Takeaways

1. **Reverse Learning**: Code enriches Spec, making the system smarter
2. **Real Impact Analysis**: Know exactly what breaks when you change something
3. **Dead Code Detection**: Automatically find unused code
4. **Continuous Improvement**: Graph gets better with every implementation
5. **Self-Documenting**: Code automatically updates documentation

> [!IMPORTANT]
> **The Bottom Line**
> 
> Knowledge Enrichment tạo ra một hệ thống "tự học" - càng dùng càng thông minh, càng chính xác, càng hữu ích.

## Related Documents
- **Workflow**: [Agentic Workflow](./19-agentic-workflow.md) - How enrichment fits in the cycle
- **Overview**: [Phase 2 README](../README.md) - Complete Feature Engine vision
- **Foundation**: [Feature Spec Design](../06-Feature-Standard/15-feature-spec-design.md) - What gets enriched
