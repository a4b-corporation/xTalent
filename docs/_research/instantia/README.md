# optionETL Project Documentation

Complete documentation for the optionETL FX option trade consolidation pipeline.

---

## 📚 Documentation Structure

### [01-architecture/](01-architecture/) - **PRODUCT LEVEL** ⭐
> Goal: Enable any team to understand and replicate the solution approach

- **Business Problem**: Challenge of multi-vendor FX option data consolidation
- **Solution Approach**: 5-stage sequential pipeline (Extract → Standardize → Group → Match → Calculate)
- **Data Flow Concepts**: 6 core transformation techniques (embeddings, grouping, fingerprints, RMI, aggregation, barriers)
- **Design Decisions**: 10 architectural choices with rationale and trade-offs

**Read this first** to understand the high-level solution.

---

### [02-processing-techniques/](02-processing-techniques/) - **METHODOLOGY FOCUS**
> Goal: Document the "how" behind each transformation, independent of implementation

- **Semantic Field Mapping**: Embedding-based similarity for zero-shot field standardization
- **Pattern-Based Classification**: Fingerprint matching for product identification
- **Leg Grouping Strategies**: Composite key + fuzzy matching for multi-leg detection
- **RMI Perspective Detection**: Auto-detecting Importer (LHS) vs Exporter (RHS)
- **Rule-Driven Aggregation**: Configurable calculation framework with RMI awareness
- **Barrier Type Inference**: Date-based European/American/Window classification

**Technology-agnostic** - can be implemented in any language/stack.

---

### [03-pipeline-stages/](03-pipeline-stages/) - **PROCESS LEVEL**
> Goal: Detailed breakdown of each transformation stage with examples

- **Stage 1: Extract** - Data ingestion (Excel/CSV/PDF)
- **Stage 2: Standardize** - Field mapping using semantic similarity
- **Stage 3: Group** - Strategy identification via composite keys
- **Stage 4: Match** - Product classification using fingerprints
- **Stage 5: Calculate** - RMI-aware multi-leg aggregation

Each stage includes: input/output, process flow, edge cases, validation checks, and complete examples.

---

### [04-configuration/](04-configuration/) - **CUSTOMIZATION**
> Goal: How to configure and extend the system

- **Standard Fields Guide**: Add vendor-specific aliases for field mapping
- **Product Fingerprints Guide**: Define new product patterns
- **Aggregation Rules Guide**: Customize calculation logic (RMI-aware)
- **Grouping Config Guide**: Adjust grouping strategy (keys + fuzzy matching)

All business logic is **externalized in YAML** - no code changes needed.

---

### [05-user-guide/](05-user-guide/) - **PRACTICAL**
> Goal: Hands-on guidance for end users

- **Getting Started**: 5-minute quick start, stage-by-stage workflow
- Common tasks (add vendor, add product, adjust grouping)
- Data preparation tips
- Troubleshooting guide

---

### [07-case-studies/](07-case-studies/) - **REAL-WORLD EXAMPLES**
> Goal: Learn from concrete scenarios

- **LHS vs RHS Analysis**: Importer/Exporter perspective handling (6 legs → 3 strategies)
- **Ratio Forward Consolidation**: Complex 4-leg structure with leverage calculation

Each case study shows: input data → pipeline processing → final output → business impact.

---

## 🚀 Quick Navigation

### I want to...

**Understand the solution**  
→ Start with [01-architecture/02-solution-approach.md](01-architecture/02-solution-approach.md)

**Use the system**  
→ Read [05-user-guide/01-getting-started.md](05-user-guide/01-getting-started.md)

**Add a new vendor**  
→ Follow [04-configuration/01-standard-fields-guide.md](04-configuration/01-standard-fields-guide.md)

**Add a new product**  
→ Follow [04-configuration/02-product-fingerprints-guide.md](04-configuration/02-product-fingerprints-guide.md)

**Customize calculations**  
→ Edit [04-configuration/03-aggregation-rules-guide.md](04-configuration/03-aggregation-rules-guide.md)

**See real examples**  
→ Review [07-case-studies/](07-case-studies/)

**Learn the techniques**  
→ Study [02-processing-techniques/](02-processing-techniques/)

---

## 📊 Pipeline Summary

```
Input: Raw Excel/PDF (15 vendor-specific rows)
    ↓ Stage 1: Extract
Raw DataFrame (vendor columns)
    ↓ Stage 2: Standardize (AI semantic mapping)
Standard DataFrame (standard columns)
    ↓ Stage 3: Group (composite key grouping)
Grouped DataFrame (strategy_id added)
    ↓ Stage 4: Match (fingerprint classification)
Classified DataFrame (product codes + RMI type)
    ↓ Stage 5: Calculate (RMI-aware aggregation)
Output: Consolidated (4 strategies, 23 output fields)

Time: < 10 seconds
Accuracy: > 95%
```

---

## 🎯 Key Concepts

### 1. Semantic Field Mapping
Use **embeddings** to map vendor columns to standard fields without manual rules:
- "Counter Amt" → `counter_amt` (0.92 similarity)
- Zero-shot: Works for new vendors immediately

### 2. RMI-Aware Processing
Auto-detect perspective (Importer/Exporter) and apply correct aggregation:
- **LHS**: Notional from Sell-Put, Leverage from Buy-Call
- **RHS**: Notional from Sell-Call, Leverage from Buy-Put
- Wrong perspective → Wrong calculations ❌

### 3. Pattern-Based Classification
Match strategy legs against product fingerprints:
- `[Sell Put, Buy Call]` → Collar (100% match)
- `[2× Sell Put, 2× Buy Call]` → Ratio Forward (95% match)

### 4. Configuration-Driven
All business logic in YAML (no hardcoding):
- Add vendor: Update `standard_fields.yaml`
- Add product: Update `strategy_fingerprints.yaml`
- Change calculation: Update `aggregation_rules.yaml`

---

## 📈 Business Value

### Before
- **Manual processing**: 4-7 hours per report
- **Error rate**: 10-15%
- **Vendor onboarding**: 2-3 days
- **New products**: Code changes required

### After
- **Automated**: < 1 minute
- **Error rate**: < 1%
- **Vendor onboarding**: Add aliases to YAML (< 30 min)
- **New products**: Add fingerprint to YAML (< 30 min)

---

## 🛠️ For Different Audiences

### Product Managers
- Business problem: [01-architecture/01-business-problem.md](01-architecture/01-business-problem.md)
- Design decisions: [01-architecture/04-design-decisions.md](01-architecture/04-design-decisions.md)
- Case studies: [07-case-studies/](07-case-studies/)

### Business Users
- Getting started: [05-user-guide/01-getting-started.md](05-user-guide/01-getting-started.md)
- Configuration: [04-configuration/](04-configuration/)

### Data Analysts
- Pipeline stages: [03-pipeline-stages/](03-pipeline-stages/)
- Case studies: [07-case-studies/](07-case-studies/)

### Developers
- Processing techniques: [02-processing-techniques/](02-processing-techniques/)
- Architecture: [01-architecture/](01-architecture/)

---

## 📝 Documentation Standards

All docs follow these principles:
- ✅ **Product-level** (not code-level)
- ✅ **Technology-agnostic** (methodology over implementation)
- ✅ **Practical examples** (concrete data, not abstract theory)
- ✅ **Multi-audience** (business + technical perspectives)

---

## 📞 Support

- **Issues**: Check [Troubleshooting](05-user-guide/01-getting-started.md#troubleshooting)
- **Config Help**: See [Configuration Guides](04-configuration/)
- **Examples**: Review [Case Studies](07-case-studies/)

---

## 🎓 Learning Path

1. **Beginner** (Understanding)
   - [Business Problem](01-architecture/01-business-problem.md)
   - [Solution Approach](01-architecture/02-solution-approach.md)
   - [Getting Started](05-user-guide/01-getting-started.md)

2. **Intermediate** (Using)
   - [Pipeline Stages](03-pipeline-stages/)
   - [Configuration Guides](04-configuration/)
   - [Case Studies](07-case-studies/)

3. **Advanced** (Extending)
   - [Processing Techniques](02-processing-techniques/)
   - [Design Decisions](01-architecture/04-design-decisions.md)
   - Custom fingerprint development

---

**Last Updated**: 2026-01-11  
**Documentation Version**: 1.0  
**Pipeline Version**: Compatible with optionETL v2.0+
