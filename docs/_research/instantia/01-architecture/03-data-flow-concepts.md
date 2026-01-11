# Core Data Flow Concepts

This document explains the fundamental data transformation concepts used in the pipeline, independent of any specific technology.

---

## 1. Semantic Field Standardization

### Problem
Different data sources use different terminology:
```
Source A: "Counter Amount", "Strike Price", "Option Type"
Source B: "Notional", "Strike Rate", "Call/Put"  
Source C: "Trade Amount", "Rate", "CP Flag"
```

### Concept: Embedding-Based Similarity Matching

**Core Idea**: Represent both standard fields and source columns as numerical vectors (embeddings) in a high-dimensional space. Similar concepts cluster together.

**How It Works**:
1. **Encode standard fields**: Convert "counter_amt" → vector representation
2. **Encode source columns**: Convert "Counter Amount" → vector representation  
3. **Measure similarity**: Calculate distance between vectors (cosine similarity)
4. **Auto-map**: Match source to standard with highest similarity score

**Mathematical Basis**:
```
similarity(A, B) = cos(θ) = (A · B) / (||A|| × ||B||)

Where:
- A, B are embedding vectors
- · is dot product
- ||A|| is vector magnitude
```

**Advantages**:
- **Zero-shot**: No training data needed for new vendors
- **Semantic**: Captures meaning, not just keywords
- **Robust**: Handles typos and variations

### Example Workflow
```
Standard field: "counter_amt" → embedding: [0.21, 0.45, 0.12, ...]

Source columns:
"Counter Amt"    → [0.19, 0.47, 0.11, ...] → similarity: 0.92 ✅
"Strike Price"   → [0.05, 0.31, 0.68, ...] → similarity: 0.23 ❌
"Maturity Date"  → [0.11, 0.09, 0.87, ...] → similarity: 0.15 ❌

Best match: "Counter Amt" → maps to "counter_amt"
```

---

## 2. Multi-Leg Strategy Grouping

### Problem
A single trading strategy is represented as multiple rows (legs):
```
Row 1: Sell Put  @ 1.08, Amount: $100K, Date: 2024-01-15
Row 2: Buy Call  @ 1.10, Amount: $100K, Date: 2024-01-15
```

These need to be identified as belonging to the same strategy.

### Concept: Composite Key Grouping

**Core Idea**: Combine multiple attributes to create a unique identifier for strategy groups.

**Grouping Keys** (typical):
- `trade_date`: When trade was executed
- `expiry_date`: When options expire
- `currency_pair`: EUR/USD, GBP/USD, etc.
- `company_code`: Client identifier
- *(optional)* `original_trade_no`: Parent trade reference

**Algorithm**:
```python
For each row:
  key = concatenate(trade_date, expiry_date, currency_pair)
  assign row to group[key]
  
For each group:
  assign unique strategy_id
```

### Multi-Level Grouping Strategy

**Level 1: Exact Match**
```
Key = trade_date + expiry_date + pair
→ Groups rows with identical keys
```

**Level 2: Fuzzy Match** (optional)
```
If expiry_date differs by ≤ 1 day:
  → Still group together (handles data entry errors)
```

### Example
```
Input:
Row 1: trade_date=2024-01-15, expiry=2024-06-15, pair=EUR/USD
Row 2: trade_date=2024-01-15, expiry=2024-06-15, pair=EUR/USD
Row 3: trade_date=2024-01-15, expiry=2024-06-16, pair=EUR/USD (typo!)
Row 4: trade_date=2024-01-16, expiry=2024-06-15, pair=EUR/USD

Level 1 (exact):
  Group A: [Row 1, Row 2] → strategy_id = STR001
  Group B: [Row 3]        → strategy_id = STR002
  Group C: [Row 4]        → strategy_id = STR003

Level 2 (fuzzy, if enabled):
  Group A: [Row 1, Row 2, Row 3] → strategy_id = STR001
  Group C: [Row 4]               → strategy_id = STR002
```

---

## 3. Pattern-Based Product Classification

### Problem
Identify what product a strategy is without hardcoding rules for each vendor.

### Concept: Fingerprint Matching

**Core Idea**: Define each product as a pattern (fingerprint) of characteristics. Match strategies against these patterns.

**Fingerprint Components**:
```yaml
Product: Collar
  leg_count: 2
  positions:
    - buy_sell: Sell, call_put: Put
    - buy_sell: Buy,  call_put: Call
  barrier_count: 0
  strike_relationship: "equal amounts"
```

**Matching Algorithm**:
```
For each strategy:
  For each product fingerprint:
    IF leg_count matches
    AND positions match
    AND barrier conditions match
    THEN: classify as this product
```

### Fingerprint Hierarchy

**Primary Match**: Structural pattern (legs, positions)
**Secondary**: Business rules (strikes, ratios)
**Fallback**: Unknown product

### Example
```
Strategy: [Sell Put @ 1.08, Buy Call @ 1.10]

Check Collar fingerprint:
  ✓ leg_count: 2 (matches)
  ✓ Sell-Put present (matches)
  ✓ Buy-Call present (matches)
  ✓ No barriers (matches)
  → MATCH: Collar

Check Straddle fingerprint:
  ✓ leg_count: 2 (matches)
  ✗ Buy-Call AND Buy-Put required (fails)
  → NO MATCH
```

---

## 4. RMI Perspective Detection

### Problem
FX options are viewed from two perspectives:
- **LHS (Importer)**: Protecting against currency appreciation
- **RHS (Exporter)**: Protecting against currency depreciation

The aggregation logic differs based on perspective.

### Concept: Leg-Based Perspective Inference

**Detection Rule**:
```
IF strategy contains Sell-Put:
  → Perspective = LHS (Left Hand Side / Importer)
  → Notional source: Sell-Put legs
  → Leverage source: Buy-Call legs

ELSE IF strategy contains Sell-Call:
  → Perspective = RHS (Right Hand Side / Exporter)
  → Notional source: Sell-Call legs
  → Leverage source: Buy-Put legs
```

### Why It Matters

**LHS Example** (Importer protecting EUR receivable):
```
Sell Put EUR/USD @ 1.08 → Notional: $100K
Buy Call EUR/USD @ 1.10 → Leverage: $100K

Correct aggregation:
  original_notional = sum(Sell-Put amounts) = $100K
  strike_rate = Sell-Put rate = 1.08
```

**RHS Example** (Exporter protecting EUR payable):
```
Sell Call EUR/USD @ 1.10 → Notional: $100K
Buy Put EUR/USD @ 1.08  → Leverage: $100K

Correct aggregation:
  original_notional = sum(Sell-Call amounts) = $100K
  strike_rate = Sell-Call rate = 1.10
```

**Wrong Perspective → Wrong Calculation**:
```
If we mistakenly aggregate LHS as RHS:
  original_notional = sum(Sell-Call) = $0 ❌ (no Sell-Call legs!)
```

---

## 5. Rule-Driven Field Calculation

### Problem
Output fields need complex calculations:
- Ratio = leverage / notional
- Barrier type detection (European vs American)
- Residual amounts after partial delivery

### Concept: Configurable Calculation Rules

**Core Idea**: Express calculation logic as external rules (YAML), not hardcoded.

**Rule Structure**:
```yaml
calculated_field: ratio
formula: |
  leverage = get_field('original_leverage_amount')
  notional = get_field('original_notional_amount')
  return leverage / notional if notional > 0 else null
format: "1:{x}"
```

**Benefits**:
- **Transparency**: Business users can read/understand rules
- **Flexibility**: Change logic without code deployment
- **Auditability**: Version control tracks rule changes

### Example Rule Execution

**Input Data**:
```
original_notional_amount: 100,000
original_leverage_amount: 200,000
```

**Rule**:
```yaml
target: ratio
logic: "leverage / notional"
```

**Output**:
```
ratio: "1:2" (200K / 100K = 2)
```

---

## 6. Barrier Type Classification

### Problem
Determine if barriers are:
- **European**: Active only at expiry
- **American**: Active from trade date to expiry
- **Window**: Active from window_start to expiry

### Concept: Date-Based Inference

**Logic**:
```
IF no barriers present:
  → barrier_type = "European" (default)

ELSE IF barrier exists AND window_start is valid date:
  IF trade_date >= window_start:
    → barrier_type = "American"
  ELSE IF trade_date < window_start:
    → barrier_type = "Window"

ELSE:
  → barrier_type = "European"
```

**Valid Date Check**: `window_start >= 1990-01-01` (filters out null/invalid dates)

### Example
```
Trade: barrier_1 = 1.12, window_start = 2024-02-01
  trade_date = 2024-02-15 (AFTER window_start)
  → barrier_type = "American" (active from Feb 15)

Trade: barrier_1 = 1.12, window_start = 2024-03-01
  trade_date = 2024-02-15 (BEFORE window_start)
  → barrier_type = "Window" (active from Mar 1)
```

---

## Summary: Key Transformation Patterns

| Concept | Input → Output | Method |
|---------|----------------|--------|
| Standardization | Vendor columns → Standard fields | Embedding similarity |
| Grouping | Individual legs → Strategy groups | Composite key matching |
| Classification | Strategy legs → Product name | Pattern/fingerprint |
| Perspective | Strategy legs → LHS/RHS | Leg type detection |
| Aggregation | Multi-leg → Single row | RMI-aware filtering + formulas |
| Calculation | Raw fields → Derived fields | Rule execution |

All concepts are **technology-agnostic** and can be implemented using any programming language or data processing framework.
