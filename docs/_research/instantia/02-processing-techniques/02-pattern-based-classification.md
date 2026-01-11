# Pattern-Based Product Classification

## Problem Statement

Given a multi-leg FX option strategy, determine what product it represents:
- Is it a Collar? Seagull? Ratio Forward?
- What's the internal product code?
- Is this a known or unknown structure?

**Challenge**: Same product can appear in different forms:
```
Strategy A: [Sell Put @ 1.08, Buy Call @ 1.10] → Collar
Strategy B: [Buy Call @ 1.12, Sell Put @ 1.06] → Also Collar (different strikes)
```

**Traditional Approach**: Hardcoded if-else rules → brittle, hard to extend

**Our Approach**: Pattern-based fingerprint matching

---

## Core Concept: Product Fingerprinting

A fingerprint is a **structural pattern** that uniquely identifies a product type.

### Fingerprint Components

```yaml
product:
  name: "Collar"
  internal_code: "COL"
  
  # Structural constraints
  leg_count: 2
  
  positions:
    - buy_sell: "Sell"
      call_put: "Put"
    - buy_sell: "Buy"
      call_put: "Call"
  
  # Economic constraints
  strike_relationship: "Put strike < Call strike"
  amount_relationship: "Equal notional"
  
  # Barrier constraints
  ki_barriers: 0
  ko_barriers: 0
```

**Key Idea**: Match observed strategy structure against fingerprint library

---

## The Matching Algorithm

### Step 1: Extract Strategy Characteristics
```
Input strategy: [Leg1, Leg2, ..., LegN]

Extract:
  leg_count = N
  positions = [(buy_sell1, call_put1), (buy_sell2, call_put2), ...]
  strikes = [strike1, strike2, ...]
  barriers = count of barrier fields with values
  amounts = [amount1, amount2, ...]
```

### Step 2: Match Against Fingerprints
```
For each fingerprint in library:
    score = 0
    
    # Check leg count
    IF fingerprint.leg_count == strategy.leg_count:
        score += 10
    
    # Check positions
    IF all positions match:
        score += 20
    
    # Check barriers
    IF barrier count matches:
        score += 5
    
    # Check business rules
    IF economic constraints satisfied:
        score += 10
    
    IF score >= threshold:
        candidate_matches.append(fingerprint)
```

### Step 3: Select Best Match
```
IF no matches found:
    return "Unknown Product"

IF one match found:
    return matched_product

IF multiple matches found:
    return highest_score_product
    # OR flag for manual review
```

---

## Fingerprint Design Patterns

### Pattern 1: Position-Based (Most Common)

**Example: Collar**
```yaml
positions:
  - {buy_sell: Sell, call_put: Put}
  - {buy_sell: Buy, call_put: Call}

Logic:
  Must have exactly these two position types
  Order doesn't matter
```

### Pattern 2: Leg Count + Barriers

**Example: Knockout Forward (KOF)**
```yaml
leg_count: 1
barriers:
  ko_count: 1
  ki_count: 0

Logic:
  Single option leg with knock-out barrier
```

### Pattern 3: Ratio Detection

**Example: Ratio Forward (RF)**
```yaml
positions:
  - {buy_sell: Sell, call_put: Put, count: 1}
  - {buy_sell: Buy, call_put: Call, count: "N"}

amount_relationship: "Call amount > Put amount"

Logic:
  Leveraged structure (ratio > 1:1)
```

### Pattern 4: Multi-Barrier Structures

**Example: Dynamic Knockout Ratio Forward (DKORF)**
```yaml
positions:
  - {buy_sell: Sell, call_put: Put, count: 2}  # Two puts
  - {buy_sell: Buy, call_put: Call, count: 1}
  - {buy_sell: Sell, call_put: Call, count: 1}

barriers:
  ki_count: 1
  ko_count: 1

Logic:
  Complex 4-leg with two barrier types
```

---

## Position Matching Logic

### Unordered Matching
Strategy legs can appear in any order:
```
Strategy A: [Sell Put, Buy Call]
Strategy B: [Buy Call, Sell Put]

Both match Collar fingerprint
```

### Count-Based Matching
```
Fingerprint specifies:
  positions:
    - {buy_sell: Sell, call_put: Put, count: 2}

Strategy must have exactly 2 Sell-Put legs
```

### Wildcard Matching
```
Fingerprint:
  positions:
    - {buy_sell: Sell, call_put: "*"}

Matches:
  - Sell Put
  - Sell Call
```

---

## Economic Constraint Validation

### Strike Relationships

**Collar**: Put strike < Call strike
```python
put_strike = leg where call_put == "Put"
call_strike = leg where call_put == "Call"

IF put_strike >= call_strike:
    reject match
```

**Straddle**: Same strike for both legs
```python
strikes = unique([leg.strike for leg in legs])

IF len(strikes) != 1:
    reject match
```

### Amount Relationships

**Equal Notional**:
```python
amounts = [leg.counter_amt for leg in legs]

IF not all_equal(amounts):
    reject match
```

**Ratio Structure**:
```python
leverage_amt = sum(Buy-Call amounts)
notional_amt = sum(Sell-Put amounts)

ratio = leverage_amt / notional_amt

IF ratio <= 1.0:
    reject match  # Not a ratio product
```

---

## Barrier Detection Logic

### Barrier Counting
```python
ki_count = count(barriers where type == "knock_in")
ko_count = count(barriers where type == "knock_out")

# Check if leg has barrier_1 or barrier_2 field populated
has_ki = any(leg.barrier_2 is not null)
has_ko = any(leg.barrier_1 is not null)
```

### Barrier Type Inference
```yaml
# No barrier fields
barriers:
  ki: 0
  ko: 0
→ Vanilla structure

# Only barrier_1 populated
barriers:
  ki: 0
  ko: 1
→ Knockout structure

# Both barrier_1 and barrier_2
barriers:
  ki: 1
  ko: 1
→ Dynamic/Double barrier structure
```

---

## Scoring System

### Scoring Weights
```python
scores = {
    'leg_count_match': 20,       # Must match
    'position_match': 30,        # Critical
    'barrier_match': 15,         # Important
    'amount_ratio': 10,          # Can vary
    'strike_relationship': 10,   # Can vary
    'barrier_type': 15           # Important for classification
}

total_possible = 100
threshold = 70  # 70% match required
```

### Example Scoring
```
Strategy: [Sell Put @ 1.08 $100K, Buy Call @ 1.10 $100K]

Against Collar fingerprint:
  ✓ leg_count: 2 == 2 → +20
  ✓ Sell-Put present → +15
  ✓ Buy-Call present → +15
  ✓ No barriers → +15
  ✓ Equal amounts → +10
  ✓ Put strike < Call strike → +10
  ✓ Barrier type: European → +15
  
  Total: 100/100 ✅ MATCH

Against Straddle fingerprint:
  ✓ leg_count: 2 == 2 → +20
  ✗ Need Buy-Put + Buy-Call → +0
  
  Total: 20/100 ❌ REJECT
```

---

## Handling Ambiguity

### Multiple Matches

**Scenario**: Two fingerprints both score > threshold
```
Strategy matches:
  1. Collar (score: 85)
  2. Risk Reversal (score: 82)
```

**Resolution Strategies**:
```python
# Strategy 1: Highest score wins
return fingerprints[argmax(scores)]

# Strategy 2: Tie-breaker rules
IF score_diff < 5:
    check_secondary_rules()
    # E.g., Collar requires equal amounts, RR allows unequal

# Strategy 3: Manual review
flag_for_review(strategy, matches)
```

### No Matches

**Scenario**: All fingerprints score < threshold

**Handling**:
```python
IF max(scores) < threshold:
    product_code = "UNKNOWN"
    option_strategy = "Unknown Structure"
    
    # Log for analysis
    log_unknown_pattern(strategy)
    
    # Suggest closest match
    closest = fingerprints[argmax(scores)]
    suggest_match = closest.name
```

---

## Extending the Fingerprint Library

### Adding a New Product

**Step 1**: Analyze the structure
```
Product: Put Spread Collar (PSC)

Legs:
  - Sell Put @ 1.08  ($100K)
  - Buy Put @ 1.06   ($100K)
  - Buy Call @ 1.10  ($100K)

Pattern:
  3 legs
  Sell-Put + Buy-Put (spread on downside)
  Buy-Call (upside protection)
```

**Step 2**: Define fingerprint
```yaml
- name: "Put Spread Collar"
  internal_code: "PSC"
  
  leg_count: 3
  
  positions:
    - {buy_sell: Sell, call_put: Put}  # Sold put
    - {buy_sell: Buy, call_put: Put}   # Bought put (lower strike)
    - {buy_sell: Buy, call_put: Call}  # Bought call
  
  constraints:
    - "Sell-Put strike > Buy-Put strike"  # Spread structure
    - "All amounts equal"
  
  barriers:
    ki: 0
    ko: 0
```

**Step 3**: Test against known examples
```python
test_strategies = [
    known_psc_example_1,
    known_psc_example_2,
    similar_but_different  # Should NOT match
]

for strategy in test_strategies:
    result = match(strategy, psc_fingerprint)
    assert result == expected
```

---

## Performance Considerations

### Sequential vs Parallel Matching

**Sequential** (check fingerprints one by one):
```
Time complexity: O(N × M)
  N = number of strategies
  M = number of fingerprints
```

**Parallel** (check all fingerprints simultaneously):
```
Time complexity: O(N) with M workers
```

### Early Termination

```python
# Stop checking once perfect match found
for fingerprint in fingerprints:
    score = calculate_score(strategy, fingerprint)
    
    IF score == 100:
        return fingerprint  # Perfect match, stop checking
```

### Fingerprint Ordering

```python
# Order fingerprints from most to least common
# Common products matched first → faster on average

fingerprints = sort_by_frequency([
    collar,      # Very common
    seagull,     # Common
    butterfly,   # Rare
])
```

---

## Validation & Testing

### Test Coverage

**Known Products** (positive test):
```python
# Each product should have 5-10 example strategies
test_collar = [
    {"legs": [...]},  # Example 1
    {"legs": [...]},  # Example 2
    ...
]

for example in test_collar:
    assert match(example).code == "COL"
```

**Edge Cases** (boundary test):
```python
# Near-misses should NOT match
almost_collar = {
    "legs": [
        {"buy_sell": "Sell", "call_put": "Put"},
        {"buy_sell": "Sell", "call_put": "Call"}  # Wrong: should be Buy
    ]
}

assert match(almost_collar).code != "COL"
```

**Unknown Products** (negative test):
```python
# Novel structures should be flagged
unknown = {
    "legs": [
        # Unusual 5-leg structure never seen before
    ]
}

assert match(unknown).code == "UNKNOWN"
```

---

## Summary

**Technique**: Pattern-based fingerprint matching  
**Components**: Structural patterns + economic constraints  
**Matching**: Score-based with configurable threshold  
**Benefits**: 
- Explainable (clear rules)
- Extensible (add new fingerprints)
- Deterministic (reproducible)

**Best For**: Structured product classification with known types  
**Trade-off**: Requires domain expertise to define patterns  
**When to Use**: Product catalog is well-defined and relatively stable
