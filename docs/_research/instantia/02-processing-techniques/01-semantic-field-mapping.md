# Semantic Field Mapping Methodology

## Problem Statement

When integrating data from multiple vendors, each source uses different column names for the same business concept:

```
Vendor A: "Counter Amt",    "Strike Price", "Maturity Date"
Vendor B: "Notional Value", "Strike Rate",  "Expiry Date"
Vendor C: "Trade Amount",   "Rate",         "Value Date"
```

**Traditional Approaches**:
- Manual mapping tables (doesn't scale)
- Exact string matching (fragile)
- Fuzzy string distance (misses semantics)

**Our Approach**: Semantic similarity using vector embeddings

---

## Core Concept: Embedding-Based Similarity

### What Are Embeddings?

An embedding is a numerical vector representation of text that captures semantic meaning:

```
"Counter Amount" → [0.21, 0.45, 0.12, 0.67, ..., 0.33]  (384 dimensions)
"Notional"       → [0.19, 0.47, 0.11, 0.69, ..., 0.31]  (384 dimensions)
```

**Key Property**: Similar concepts have similar vectors
- "Counter Amount" and "Notional" → vectors are close
- "Counter Amount" and "Expiry Date" → vectors are far apart

### Why Embeddings Work

**Trained on Massive Text Corpora**:
- Models learn that "amount", "notional", "value" are synonyms
- Context-aware: "rate" (exchange rate) vs "rate" (interest rate)
- Handles variations: "Counter Amt", "Ctr Amount", "CTR_AMT"

---

## The Algorithm

### Step 1: Encode Standard Fields
```
Standard fields = ["counter_amt", "rate", "expiry_date", "buy_sell", ...]

For each standard_field:
    embedding[standard_field] = encode(standard_field)
```

Result:
```
embeddings = {
    "counter_amt": [0.21, 0.45, ...],
    "rate": [0.12, 0.78, ...],
    "expiry_date": [0.33, 0.11, ...],
    ...
}
```

### Step 2: Encode Source Columns
```
Source columns = ["Counter Amt", "Strike Price", "Maturity"]

For each source_column:
    embedding[source_column] = encode(source_column)
```

### Step 3: Calculate Similarity
For each source column, compare against all standard fields:

```
For source_column in source_columns:
    For standard_field in standard_fields:
        similarity = cosine_similarity(
            embedding[source_column],
            embedding[standard_field]
        )
```

**Cosine Similarity Formula**:
```
cos(θ) = (A · B) / (||A|| × ||B||)

Where:
- A, B are embedding vectors
- · is dot product
- ||A|| is magnitude of vector A
- Result range: -1 (opposite) to +1 (identical)
```

### Step 4: Find Best Match
```
For each source_column:
    best_match = standard_field with highest similarity score
    IF similarity > threshold (e.g., 0.5):
        map source_column → best_match
```

---

## Example Walkthrough

### Input Data
```
Standard fields: ["counter_amt", "rate", "expiry_date"]
Source columns: ["Counter Amt", "Strike Price", "Maturity"]
```

### Encoding
```
Embeddings (simplified to 3D for visualization):
counter_amt:    [0.9, 0.1, 0.2]
rate:           [0.1, 0.8, 0.3]
expiry_date:    [0.2, 0.3, 0.9]

Counter Amt:    [0.85, 0.15, 0.18]  (similar to counter_amt)
Strike Price:   [0.12, 0.82, 0.28]  (similar to rate)
Maturity:       [0.18, 0.25, 0.88]  (similar to expiry_date)
```

### Similarity Calculation
```
Similarity("Counter Amt", "counter_amt"):
  = (0.85*0.9 + 0.15*0.1 + 0.18*0.2) / (||A|| × ||B||)
  = 0.92 ✅ HIGH

Similarity("Counter Amt", "rate"):
  = (0.85*0.1 + 0.15*0.8 + 0.18*0.3) / (||A|| × ||B||)
  = 0.23 ❌ LOW

Similarity("Counter Amt", "expiry_date"):
  = (0.85*0.2 + 0.15*0.3 + 0.18*0.9) / (||A|| × ||B||)
  = 0.34 ❌ LOW
```

### Mapping Result
```
"Counter Amt" → "counter_amt" (similarity: 0.92)
"Strike Price" → "rate" (similarity: 0.89)
"Maturity" → "expiry_date" (similarity: 0.95)
```

---

## Advantages Over Alternatives

### vs Manual Mapping Tables
```
Manual:
IF source = "Counter Amt" THEN map to "counter_amt"
IF source = "Notional Value" THEN map to "counter_amt"
...

❌ Requires predefined rules for every vendor
❌ Breaks on new terminology
❌ High maintenance cost
```

Embeddings:
```
✅ Zero configuration for new vendors
✅ Handles unseen column names
✅ Self-maintaining
```

### vs Fuzzy String Matching
```
Levenshtein distance("Counter Amt", "counter_amt") = 6 edits
Levenshtein distance("Notional", "counter_amt") = 9 edits

❌ "Notional" farther from "counter_amt" than random strings
❌ Doesn't capture that "Notional" = "Amount" semantically
```

Embeddings:
```
✅ similarity("Notional", "counter_amt") = 0.85 (high!)
✅ Captures semantic equivalence
```

### vs Rule-Based NLP
```
Rules:
IF column contains ["amt", "amount", "notional", "value"] 
   THEN map to "counter_amt"

❌ Misses synonyms not in list
❌ False positives (e.g., "premium_amt" also matches)
❌ Requires linguistic expertise
```

Embeddings:
```
✅ Learns semantics from data
✅ Context-aware distinctions
✅ No expert rules needed
```

---

## Implementation Considerations

### Choice of Embedding Model

**Requirements**:
- Fast inference (< 100ms per batch)
- Small model size (< 500MB)
- Good semantic understanding
- Multilingual support (if needed)

**Popular Options**:
- `all-MiniLM-L6-v2`: 80MB, 384 dimensions, fast
- `all-mpnet-base-v2`: 420MB, 768 dimensions, more accurate
- `multilingual-e5-small`: 118MB, multilingual

**Trade-off**: Speed vs accuracy

### Threshold Selection

```
Similarity threshold determines mapping confidence:

threshold = 0.3: Aggressive (many matches, some wrong)
threshold = 0.5: Balanced (good precision/recall)
threshold = 0.7: Conservative (few matches, high confidence)
```

**Recommended**: Start at 0.5, adjust based on domain

### Performance Optimization

**Batch Encoding**:
```
Instead of:
  for column in columns:
      embedding = encode(column)  # 50ms × 20 columns = 1 second

Do:
  embeddings = encode(columns)  # 200ms for all 20 columns
```

**Caching**:
```
# Standard field embeddings are reusable
standard_embeddings = encode_once(standard_fields)
save_to_cache(standard_embeddings)

# For each new vendor:
source_embeddings = encode(source_columns)
compare_to_cached(source_embeddings, standard_embeddings)
```

### Handling Edge Cases

**Multiple High-Similarity Matches**:
```
Problem:
"Amount" → "counter_amt" (0.85)
"Amount" → "premium_amt" (0.82)

Solution:
- Pick highest score
- OR flag for manual review if difference < 0.1
```

**Low-Similarity Across All Fields**:
```
Problem:
"XYZ_Field" → all similarities < 0.3

Solution:
- Leave unmapped
- Flag as "Unknown field"
- Allow manual mapping
```

**Homonyms** (same word, different meaning):
```
Problem:
"Rate" could mean:
- Exchange rate
- Interest rate
- Tax rate

Solution:
- Use full column name for context
- Consider surrounding column names
- Provide manual override
```

---

## Evaluation Metrics

### Precision
```
Precision = Correct Mappings / Total Auto-Mappings

Measures: How many auto-mappings are correct?
Target: > 90%
```

### Recall
```
Recall = Correct Mappings / Total Columns

Measures: How many columns were successfully mapped?
Target: > 85%
```

### F1 Score
```
F1 = 2 × (Precision × Recall) / (Precision + Recall)

Balances precision and recall
Target: > 0.87
```

---

## Validation Strategy

### Approach 1: Hold-Out Vendor
```
1. Train/test on vendors A, B, C
2. Validate on vendor D (never seen before)
3. Measure accuracy on vendor D
```

### Approach 2: Manual Review
```
1. Auto-map all fields
2. Present to domain expert
3. Track correction rate
4. Adjust threshold to minimize corrections
```

### Approach 3: A/B Testing
```
Method A: Manual mapping (baseline)
Method B: Embedding-based (new)

Compare:
- Time taken
- Error rate
- User satisfaction
```

---

## Summary

**Technique**: Vector embeddings + cosine similarity  
**Benefit**: Zero-shot semantic field matching  
**Best For**: Multi-vendor data integration  
**Trade-off**: Requires ML model, not 100% accurate  
**When to Use**: Column names vary but concepts are standard
