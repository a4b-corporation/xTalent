# Configuration Guide: Product Fingerprints

## Overview

The `strategy_fingerprints.yaml` file defines patterns for identifying FX option products. Each fingerprint specifies the structural characteristics (leg count, positions, barriers) that uniquely identify a product type.

**Location**: `configs/strategy_fingerprints.yaml`

---

## File Structure

```yaml
strategies:
  - name: <product_name>
    product_code: <internal_code>
    leg_count: <number_or_range>
    has_ratio: <true/false>
    has_barrier: <true/false>
    has_window: <true/false>
    patterns:
      - legs: [{bs: <B/S>, cp: <C/P>}, ...]
        rmi_type: <LHS/RHS>
```

### Field Definitions

| Field | Type | Purpose | Example |
|-------|------|---------|---------|
| `name` | String | Human-readable product name | "Collar", "Ratio Forward" |
| `product_code` | String | Internal abbreviation | COL, RF, KORF |
| `leg_count` | Int/Range | Number of legs | 2, "1-2", 3 |
| `has_ratio` | Boolean | Leverage structure | true (RF), false (COL) |
| `has_barrier` | Boolean | Includes knockout/knock-in | true (KOthe F), false (COL) |
| `has_window` | Boolean | Window observation period | true (WFE) |
| `patterns` | List | Leg position patterns | See below |

---

## Pattern Syntax

### Leg Abbreviations
```yaml
bs: Buy/Sell
  B = Buy
  S = Sell

cp: Call/Put
  C = Call
  P = Put
```

### Example Patterns

**Simple Pattern** (Collar):
```yaml
- legs: [{bs: S, cp: P}, {bs: B, cp: C}]
  rmi_type: LHS
```
Meaning: Sell-Put + Buy-Call → Importer (LHS) perspective

**Multi-Leg Pattern** (Seagull):
```yaml
- legs: [{bs: S, cp: P}, {bs: B, cp: P}, {bs: B, cp: C}]
  rmi_type: LHS
```
Meaning: Sell-Put + Buy-Put + Buy-Call → 3-leg structure

**Repeated Legs** (Ratio Forward):
```yaml
- legs: [{bs: S, cp: P}, {bs: S, cp: P}, {bs: B, cp: C}]
  rmi_type: LHS
```
Meaning: 2× Sell-Put + Buy-Call → Ratio structure (2:1)

---

## Product Categories

### 1. Vanilla Products (1-leg)

**Vanilla Option (VO)**:
```yaml
- name: Vanilla Option (VO)
  product_code: VO
  leg_count: 1
  patterns:
    - legs: [{bs: S, cp: P}]  # Short Put (LHS)
      rmi_type: LHS
    - legs: [{bs: S, cp: C}]  # Short Call (RHS)
      rmi_type: RHS
```

### 2. Forward Structures (2-leg)

**Collar (COL)**:
```yaml
- name: Collar (COL)
  product_code: COL
  leg_count: 2
  has_ratio: false
  has_barrier: false
  patterns:
    - legs: [{bs: S, cp: P}, {bs: B, cp: C}]
      rmi_type: LHS
```

**Ratio Forward (RF)**:
```yaml
- name: Ratio Forward (RF)
  product_code: RF
  leg_count: 2-4
  has_ratio: true  # Key differentiator
  patterns:
    - legs: [{bs: S, cp: P}, {bs: B, cp: C}]
      rmi_type: LHS
```

**Knockout Forward (KOF)**:
```yaml
- name: Knockout Forward (KOF)
  product_code: KOF
  leg_count: 2
  has_barrier: true  # Key differentiator
  patterns:
    - legs: [{bs: S, cp: P}, {bs: B, cp: C}]
      rmi_type: LHS
```

### 3. Seagull Structures (3-leg)

**Call Seagull (SEA)**:
```yaml
- name: Seagull (SEA)
  product_code: SEA
  leg_count: 3
  patterns:
    - legs: [{bs: S, cp: P}, {bs: B, cp: P}, {bs: B, cp: C}]
      rmi_type: LHS
```
Pattern: Sell-Put (floor) + Buy-Put (protection) + Buy-Call (upside)

### 4. Complex Products (4-leg)

**Dynamic Knockout Ratio Forward (DKORF)**:
```yaml
- name: Dynamic Knockout Ratio Forward (DKORF)
  product_code: DKORF
  leg_count: 4
  has_barrier: true
  has_ratio: true
  patterns:
    - legs: [{bs: S, cp: P}, {bs: S, cp: P}, {bs: B, cp: C}, {bs: S, cp: C}]
      rmi_type: LHS
```
Pattern: 2× Sell-Put + Buy-Call + Sell-Call (financing)

---

## Adding a New Product

### Step 1: Analyze Structure
```
New Product: "Enhanced Collar"

Legs:
  - Sell Put @ Lower Strike
  - Buy Call @ Mid Strike  
  - Sell Call @ Higher Strike

Structure: 3 legs, no barriers, no ratio
Similar to: Seagull but with Sell-Call instead of Buy-Put
```

### Step 2: Define Fingerprint
```yaml
- name: Enhanced Collar (EC)
  product_code: EC
  leg_count: 3
  has_ratio: false
  has_barrier: false
  patterns:
    # LHS Pattern
    - legs: [{bs: S, cp: P}, {bs: B, cp: C}, {bs: S, cp: C}]
      rmi_type: LHS
    
    # RHS Pattern (mirror)
    - legs: [{bs: S, cp: C}, {bs: B, cp: P}, {bs: S, cp: P}]
      rmi_type: RHS
```

### Step 3: Position in File
```yaml
# Add after similar products (3-leg section)
# ============== 3-LEG STRATEGIES ==============

  - name: Seagull (SEA)
    ...
  
  - name: Enhanced Collar (EC)  # ← Add here
    ...
```

### Step 4: Test Recognition
```
Test data:
  Strategy: [Sell Put $100K, Buy Call $100K, Sell Call $50K]

Expected match:
  fp_product_code = "EC"
  match_score >= 70
```

---

## Differentiation Strategies

### Problem: Similar Patterns
```
COL:  Sell-Put + Buy-Call (no ratio, no barrier)
RF:   Sell-Put + Buy-Call (has ratio)
KOF:  Sell-Put + Buy-Call (has barrier)
```

All have same leg structure! How to differentiate?

### Solution: Feature Flags
```yaml
# Collar: Basic structure
- name: Collar (COL)
  leg_count: 2
  has_ratio: false  # ← Differentiator
  has_barrier: false
  patterns: [{bs: S, cp: P}, {bs: B, cp: C}]

# Ratio Forward: Leveraged
- name: Ratio Forward (RF)
  leg_count: 2-4
  has_ratio: true  # ← Differentiator
  has_barrier: false
  patterns: [{bs: S, cp: P}, {bs: B, cp: C}]

# Knockout Forward: With barrier
- name: Knockout Forward (KOF)
  leg_count: 2
  has_ratio: false
  has_barrier: true  # ← Differentiator
  patterns: [{bs: S, cp: P}, {bs: B, cp: C}]
```

### Matching Priority
```
1. Check leg_count
2. Check pattern (positions)
3. Check has_barrier
4. Check has_ratio
5. Check has_window
```

---

## RMI Patterns (LHS vs RHS)

### Dual Perspective Products

Many products exist in both LHS (Importer) and RHS (Exporter) forms:

**Collar**:
```yaml
patterns:
  # LHS: Importer (selling EUR, buying USD)
  - legs: [{bs: S, cp: P}, {bs: B, cp: C}]
    rmi_type: LHS
  
  # RHS: Exporter (buying EUR, selling USD)
  - legs: [{bs: S, cp: C}, {bs: B, cp: P}]  # Mirror
    rmi_type: RHS
```

**Key Insight**: LHS and RHS patterns are **mirrors** of each other
- LHS Sell-Put ↔ RHS Sell-Call
- LHS Buy-Call ↔ RHS Buy-Put

---

## Validation Rules

### Required Fields
```yaml
✅ MUST have:
  - name
  - product_code  
  - leg_count
  - patterns (at least 1)

⚠️ SHOULD have (if applicable):
  - has_ratio (if leveraged)
  - has_barrier (if knockout/knock-in)
  - has_window (if window observation)
```

### Pattern Validation
```yaml
✅ GOOD:
  - legs: [{bs: S, cp: P}, {bs: B, cp: C}]
    rmi_type: LHS
  # Clear, complete, RMI specified

❌ BAD:
  - legs: [{b s: S}]  # Incomplete (missing cp)
  - legs: [{bs: X, cp: P}]  # Invalid (bs must be B or S)
  - legs: [{bs: S, cp: P}]  # No rmi_type
```

---

## Testing Your Fingerprints

### Test 1: Unique Match
```python
# Test strategy should match exactly ONE fingerprint
test_strategy = [
    {"buy_sell": "Sell", "call_put": "Put"},
    {"buy_sell": "Buy", "call_put": "Call"}
]

matches = find_matching_fingerprints(test_strategy)

assert len(matches) == 1
assert matches[0]['product_code'] == 'COL'
```

### Test 2: No False Positives
```python
# Similar but different structure should NOT match
almost_collar = [
    {"buy_sell": "Sell", "call_put": "Put"},
    {"buy_sell": "Sell", "call_put": "Call"}  # Wrong: both Sell
]

matches = find_matching_fingerprints(almost_collar)

assert matches[0]['product_code'] != 'COL'
```

### Test 3: RMI Detection
```python
# Verify correct RMI type assigned
lhs_collar = [
    {"buy_sell": "Sell", "call_put": "Put"},
    {"buy_sell": "Buy", "call_put": "Call"}
]

match = find_match(lhs_collar)

assert match['rmi_type'] == 'LHS'
```

---

## Advanced Features

### Leg Count Ranges
```yaml
# Product can have variable leg count
- name: Ratio Forward (RF)
  leg_count: 2-4  # 2, 3, or 4 legs acceptable
  
  # 2-leg: Simple ratio
  # 3-leg: With extra financing leg
  # 4-leg: Complex ratio structure
```

### Conditional Rules
```yaml
- name: Straddle (STRD)
  patterns:
    - legs: [{bs: B, cp: P}, {bs: B, cp: C}]
      rmi_type: LHS/RHS
      note: "Neutral strategy, same strike"
```

---

## Match Priority Configuration

```yaml
match_priority:
  - barrier_check     # Check barriers first
  - ratio_check       # Then check ratio
  - window_check      # Then window
  - leg_count         # Then leg count
  - pattern_match     # Finally pattern

# Higher priority checks run first
# If multiple matches, highest priority wins
```

---

## Summary

**Purpose**: Define structural patterns for product recognition  
**Format**: YAML with product characteristics and leg patterns  
**Usage**: Pattern matching in Match stage  
**Key Features**:
- Leg position patterns
- Feature flags (ratio, barrier, window)
- Dual RMI perspectives (LHS/RHS)

**Best Practice**: Add both LHS and RHS patterns for each product  
**Testing**: Verify unique matches and no false positives  
**Extensibility**: Easy to add new products without code changes
