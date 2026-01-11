# Design Decisions & Rationale

This document explains the key architectural choices made during the solution design.

---

## 1. Sequential Pipeline vs Monolithic Processing

### Decision: **Sequential 5-Stage Pipeline**

### Alternatives Considered
- **Option A**: Single-pass processing (all transformations in one loop)
- **Option B**: Event-driven architecture (async message passing)
- **✅ Option C**: Sequential pipeline with state persistence

### Why Sequential Pipeline Won

**Advantages**:
- ✅ **Debuggability**: Each stage can be tested independently
- ✅ **Clarity**: Data flow is explicit and traceable
- ✅ **Incremental Processing**: Users can stop at any stage
- ✅ **Rollback**: Easy to re-run from failed stage
- ✅ **Observability**: Clear metrics per stage (time, row count, errors)

**Trade-offs Accepted**:
- ⚠️ Slower than streaming (acceptable for batch processing)
- ⚠️ Higher memory usage (store full DataFrames between stages)

**When This Breaks Down**:
- Real-time streaming requirements (need event-driven)
- Datasets > 10M rows (need distributed processing)

---

## 2. Embedding-Based vs Rule-Based Field Mapping

### Decision: **Embeddings (Semantic Similarity)**

### Alternatives Considered
- **Option A**: Manual mapping rules per vendor
- **Option B**: Fuzzy string matching (Levenshtein distance)
- **✅ Option C**: Sentence embeddings + cosine similarity

### Why Embeddings Won

**Advantages**:
- ✅ **Zero-shot**: Works for unseen vendors without configuration
- ✅ **Semantic**: Captures meaning ("Amount" ≈ "Notional")
- ✅ **Robust**: Handles typos and variations

**Comparison**:
```
Input: "Counter Amt"

Rule-based:
IF column contains "amt" OR "amount" → map to "counter_amt"
❌ Breaks on: "Notional", "Trade Size", "Quantity"

Fuzzy matching:
Levenshtein("Counter Amt", "counter_amt") = 6 edits
❌ Doesn't capture synonyms

Embeddings:
similarity("Counter Amt", "counter_amt") = 0.92
similarity("Notional", "counter_amt") = 0.88
✅ Both matched correctly
```

**Trade-offs Accepted**:
- ⚠️ Requires ML model (~80MB download)
- ⚠️ Not 100% accurate (manual override needed for edge cases)

---

## 3. YAML Configuration vs Database

### Decision: **YAML Files for Business Logic**

### Alternatives Considered
- **Option A**: SQL database for rules and mappings
- **Option B**: Hardcoded Python dictionaries
- **✅ Option C**: YAML configuration files

### Why YAML Won

**Advantages**:
- ✅ **Version Control**: Git tracks changes to rules
- ✅ **Human Readable**: Business users can understand/edit
- ✅ **No Infrastructure**: No database server required
- ✅ **Fast Prototyping**: Instant rule changes without deployment

**Example**: Adding a new product
```yaml
# Just edit this YAML file:
- name: New_Product_XYZ
  leg_count: 3
  positions:
    - {buy_sell: Sell, call_put: Put}
    - {buy_sell: Buy, call_put: Call}
    - {buy_sell: Sell, call_put: Call}
```

**Trade-offs Accepted**:
- ⚠️ No referential integrity checks (DB would validate)
- ⚠️ Limited querying (DB would enable complex queries)

---

## 4. Fingerprint Matching vs Machine Learning Classification

### Decision: **Pattern-Based Fingerprints**

### Alternatives Considered
- **Option A**: Supervised ML (train classifier on labeled data)
- **Option B**: Unsupervised clustering (group similar strategies)
- **✅ Option C**: Rule-based fingerprint matching

### Why Fingerprints Won

**Advantages**:
- ✅ **Explainability**: Clear rules show why product was matched
- ✅ **No Training Data**: Works immediately without historical labels
- ✅ **Deterministic**: Same input always gives same output
- ✅ **Easy Extension**: Add new product = add new fingerprint

**ML Approach Challenges**:
```
Problem: Cold Start
→ New products have no training examples
→ Cannot classify until we collect & label data

Fingerprint Solut
ion:
→ Define pattern upfront
→ Works immediately
```

**Trade-offs Accepted**:
- ⚠️ Requires domain expertise to define fingerprints
- ⚠️ Doesn't learn from data (ML could adapt automatically)

---

## 5. Dual Classification (Internal + Academic)

### Decision: **Two Parallel Taxonomies**

### Rationale

**Internal Codes** (e.g., "RF", "KOF", "COL"):
- Used by operations team
- Specific to bank's product catalog
- Drives downstream systems (risk, P&L)

**Academic Names** (e.g., "Collar", "Seagull"):
- Industry-standard terminology
- Used by traders and portfolio managers
- Facilitates communication across institutions

**Why Both?**
```
Scenario: Two banks discussing a trade
Bank A: "We did a Ratio Forward Extra"
Bank B: "That's a Put Seagull in our book"
→ Same product, different internal names
→ Academic classification creates common language
```

**Implementation**:
- Fingerprint matching → Internal code
- Academic rules → Academic name
- Both stored in output

---

## 6. RMI Auto-Detection vs User Input

### Decision: **Auto-Detect from Leg Patterns**

### Alternatives Considered
- **Option A**: Require user to specify LHS/RHS upfront
- **✅ Option B**: Infer from presence of Sell-Put (LHS) or Sell-Call (RHS)

### Why Auto-Detection Won

**Advantages**:
- ✅ **Zero User Input**: One less field to configure
- ✅ **Accurate**: Based on actual trade structure
- ✅ **Handles Mixed Data**: Different strategies can have different RMI types

**Detection Rules**:
```python
IF strategy contains Sell-Put:
    rmi_type = "LHS"
ELIF strategy contains Sell-Call:
    rmi_type = "RHS"
ELSE:
    rmi_type = "LHS"  # default
```

**Fallback Strategy**: If detection fails, default to LHS (conservative choice)

---

## 7. Multi-Level Grouping

### Decision: **Exact + Fuzzy Matching**

### Why?

**Real-World Problem**:
```
Data Entry Error:
Leg 1: expiry_date = 2024-06-15
Leg 2: expiry_date = 2024-06-16 (typo!)

Result without fuzzy:
→ Two separate strategies (wrong!)

Result with fuzzy (±1 day tolerance):
→ Single strategy (correct!)
```

**Configuration**:
```yaml
grouping:
  level_1: exact_match
  level_2: 
    enabled: true
    fuzzy_fields:
      expiry_date: ±1 day
```

**Trade-off**: Risk of false positives (grouping unrelated trades)

**Mitigation**: Fuzzy matching is optional and configurable

---

## 8. State Persistence Between Stages

### Decision: **In-Memory State Manager**

### Implementation
```
Stage 1 (Extract) → save to state['extract_data']
Stage 2 (Standardize) → load state['extract_data']
                      → save to state['standardize_data']
Stage 3 (Group) → load state['standardize_data']
```

### Why?

**Advantages**:
- ✅ **Data Lineage**: Full audit trail of transformations
- ✅ **Rollback**: Re-run from any stage without reprocessing
- ✅ **Inspection**: Users can view intermediate results

**Alternative (Save to Disk)**:
- Slower (I/O overhead)
- Not needed for typical dataset sizes (<100K rows)

---

## 9. Configurable Aggregation Rules

### Decision: **YAML-Defined Aggregation Logic**

### Example
```yaml
- target_field: ratio
  description: "Leverage to Notional ratio"
  calculated: true
  formula: |
    leverage / notional if notional > 0 else null
  format: "1:{x}"
```

### Why External Configuration?

**Business Logic Changes Frequently**:
- New regulatory requirements
- Market conventions evolve
- Different desks need different calculations

**Without Configuration** (hardcoded):
```python
df['ratio'] = df['leverage'] / df['notional']
→ Change requires code deployment
→ Risk of bugs in production
```

**With Configuration**:
```yaml
# Just edit YAML, no deployment
formula: |
  (leverage * adjustment_factor) / notional
```

---

## 10. UI-Driven vs Programmatic API

### Decision: **Web UI with Manual Override Points**

### Why?

**Users Need Control**:
- AI suggestions are not 100% accurate
- Business rules have exceptions
- Visual confirmation builds trust

**Manual Override Points**:
1. **Stage 2**: Override AI field mappings
2. **Stage 3**: Adjust grouping keys
3. **Stage 4**: Correct misclassified products
4. **Stage 5**: Select custom aggregation rules

**Alternative (Fully Automated)**:
- Faster for clean data
- Fails silently on edge cases
- No visibility into decisions

---

## Summary Matrix

| Decision | Rationale | Key Benefit | Trade-off |
|----------|-----------|-------------|-----------|
| Sequential Pipeline | Clarity & debuggability | Easy to test/extend | Slower than streaming |
| Embeddings | Zero-shot mapping | No vendor training | Needs ML model |
| YAML Config | Version control | Business user editable | No DB validation |
| Fingerprints | Explainability | Works without training data | Manual pattern definition |
| Dual Classification | Cross-institution communication | Common language | Maintain 2 taxonomies |
| RMI Auto-Detect | Zero user input | Accurate from structure | Edge cases default |
| Fuzzy Grouping | Handle data errors | Robust to typos | False positive risk |
| In-Memory State | Fast access | Full audit trail | Memory usage |
| Config Aggregation | Business agility | No code deployment | Formula validation |
| UI Overrides | Human-in-loop | Build trust | Manual effort |

---

## Anti-Patterns Avoided

### ❌ Over-Engineering
**What We Didn't Do**: Build a generic "universal ETL framework"  
**Why**: Scope creep, complexity, harder to use

### ❌ Premature Optimization
**What We Didn't Do**: Distributed processing (Spark, Dask)  
**Why**: Adds complexity; current data size doesn't justify it

### ❌ Black Box AI
**What We Didn't Do**: End-to-end deep learning model  
**Why**: Not explainable; can't debug failures

### ✅ What We Did
Balanced automation (embeddings) with control (configurations) and transparency (fingerprints)
