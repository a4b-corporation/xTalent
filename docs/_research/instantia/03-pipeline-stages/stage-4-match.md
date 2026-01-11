# Stage 4: Match - Product Classification

## Purpose
Identify what product type each grouped strategy represents using pattern-based fingerprint matching and academic classification.

---

## Input (from Stage 3)

### Grouped DataFrame
```
14 rows × 10 columns with strategy_id

strategy_id  counter_amt  rate  expiry_date  buy_sell  call_put  currency_pair
STR001       100000       1.08  2024-06-15   Sell      Put       EURUSD
STR001       100000       1.10  2024-06-15   Buy       Call      EURUSD
STR001       200000       1.06  2024-06-15   Sell      Put       EURUSD
STR001       200000       1.12  2024-06-15   Buy       Call      EURUSD
STR002       100000       1.08  2024-07-15   Sell      Put       EURUSD
STR002       100000       1.10  2024-07-15   Buy       Call      EURUSD
```

**Objective**: Determine that STR001 is a "Ratio Forward" and STR002 is a "Collar"

---

## Process Flow

### Step 1: Load Product Fingerprints

```yaml
# From: configs/strategy_fingerprints.yaml
- name: "Collar"
  internal_code: "COL"
  
  leg_count: 2
  positions:
    - {buy_sell: Sell, call_put: Put}
    - {buy_sell: Buy, call_put: Call}
  
  barriers:
    ki: 0
    ko: 0

- name: "Ratio Forward"
  internal_code: "RF"
  
  leg_count: 2-4
  positions:
    - {buy_sell: Sell, call_put: Put, count: ">=1"}
    - {buy_sell: Buy, call_put: Call, count: ">=1"}
  
  amount_relationship: "Call amount > Put amount"
```

### Step 2: Extract Strategy Characteristics

For each unique `strategy_id`, analyze the group:

```python
strategy = df[df['strategy_id'] == 'STR001']

characteristics = {
    'leg_count': len(strategy),  # 4
    'positions': [
        ('Sell', 'Put'),   # Row 1
        ('Buy', 'Call'),   # Row 2
        ('Sell', 'Put'),   # Row 3
        ('Buy', 'Call')    # Row 4
    ],
    'strikes': [1.08, 1.10, 1.06, 1.12],
    'amounts': [100K, 100K, 200K, 200K],
    'barriers': {
        'ki': 0,  # No knock-in barriers
        'ko': 0   # No knock-out barriers
    }
}
```

### Step 3: Match Against Fingerprints

```python
for fingerprint in fingerprints:
    score = calculate_match_score(strategy, fingerprint)
    
    if score >= threshold (70):
        matches.append((fingerprint, score))
```

**Scoring Example** (STR001 vs Ratio Forward):
```
✓ leg_count: 4 in range [2-4] → +20
✓ Has Sell-Put positions → +15
✓ Has Buy-Call positions → +15
✓ Call amount (200K) > Put amount (100K) → +10
✓ No barriers → +15
Total: 75/100 → MATCH
```

**Scoring Example** (STR001 vs Collar):
```
✗ leg_count: 4 != 2 → +0
✓ Has Sell-Put → +15
✓ Has Buy-Call → +15
✗ Equal amounts: No (200K ≠ 100K) → +0
Total: 30/100 → NO MATCH
```

### Step 4: Select Best Match

```python
if matches:
    best_match = max(matches, key=lambda x: x[1])  # Highest score
    product_code = best_match[0]['internal_code']
    product_name = best_match[0]['name']
else:
    product_code = "UNKNOWN"
    product_name = "Unknown Product"
```

**Result for STR001**:
```
fp_product_code = "RF"  (Ratio Forward)
fp_product_name = "Ratio Forward"
```

### Step 5: Academic Classification

```yaml
# From: configs/academic_strategies.yaml
academic_rules:
  - name: "Collar"
    conditions:
      - leg_count == 2
      - has_sell_put AND has_buy_call
      - equal_amounts
      - put_strike < call_strike
```

**Apply Rules**:
```python
for rule in academic_rules:
    if all_conditions_met(strategy, rule):
        option_strategy = rule['name']
        break
else:
    option_strategy = "Unknown Structure"
```

**Result for STR002**:
```
STR002: [Sell Put @ 1.08 $100K, Buy Call @ 1.10 $100K]

Academic classification:
  ✓ leg_count == 2
  ✓ Sell-Put + Buy-Call
  ✓ Equal amounts (100K == 100K)
  ✓ Put strike (1.08) < Call strike (1.10)
  
→ option_strategy = "Collar"
```

###Step 6: RMI Type Detection

```python
# Detect Importer (LHS) vs Exporter (RHS)
if any(leg['buy_sell'] == 'Sell' and leg['call_put'] == 'Put'):
    fp_rmi_type = "LHS"
elif any(leg['buy_sell'] == 'Sell' and leg['call_put'] == 'Call'):
    fp_rmi_type = "RHS"
else:
    fp_rmi_type = "LHS"  # Default
```

**Result**:
```
STR001: Has Sell-Put → fp_rmi_type = "LHS"
STR002: Has Sell-Put → fp_rmi_type = "LHS"
```

### Step 7: Add Classification Fields

```python
# Add new columns to DataFrame
for strategy_id in df['strategy_id'].unique():
    mask = df['strategy_id'] == strategy_id
    
    df.loc[mask, 'fp_product_code'] = matched_product
    df.loc[mask, 'option_strategy'] = academic_name
    df.loc[mask, 'fp_rmi_type'] = rmi_type
```

---

## Output Format

### Classified DataFrame

**New Columns**: `fp_product_code`, `option_strategy`, `fp_rmi_type`

```
strategy_id  fp_product_code  option_strategy   fp_rmi_type  counter_amt  rate  buy_sell  call_put
STR001       RF               Ratio Forward     LHS          100000       1.08  Sell      Put
STR001       RF               Ratio Forward     LHS          100000       1.10  Buy       Call
STR001       RF               Ratio Forward     LHS          200000       1.06  Sell      Put
STR001       RF               Ratio Forward     LHS          200000       1.12  Buy       Call
STR002       COL              Collar            LHS          100000       1.08  Sell      Put
STR002       COL              Collar            LHS          100000       1.10  Buy       Call
```

---

## Edge Cases

### Case 1: No Match Found

```
Strategy: [Buy Put, Buy Call, Buy Put]  (unusual structure)

Fingerprint matching: All scores < 70

Handling:
  fp_product_code = "UNKNOWN"
  option_strategy = "Unknown Structure"
  Flag: manual_review_needed
```

### Case 2: Multiple High Scores

```
Strategy matches:
  - Collar: 85
  - Risk Reversal: 82  (very similar structure)

Handling:
  - Select highest (Collar)
  - If difference < 5 points: Flag as ambiguous
```

### Case 3: Conflicting Classifications

```
Fingerprint match: "RF" (Ratio Forward)
Academic rule: "Collar"

Handling:
  - Trust fingerprint (more specific)
  - fp_product_code = "RF"
  - option_strategy = "Ratio Forward" (override academic)
  - Log conflict for review
```

### Case 4: Single-Leg Products

```
Strategy: [Sell Put @ 1.08]  (1 leg)

Classification:
  fp_product_code = "VO" (Vanilla Option)
  option_strategy = "Short Put"
  fp_rmi_type = "LHS"
```

---

## Validation Checks

### Post-Classification Validation

**Check 1**: Classification rate
```
classified = count(fp_product_code != "UNKNOWN")
total = count(unique strategy_id)

classification_rate = classified / total
Target: > 90%
```

**Check 2**: RMI consistency
```
For each strategy:
    IF fp_rmi_type == "LHS":
        assert has_sell_put
    ELIF fp_rmi_type == "RHS":
        assert has_sell_call
```

**Check 3**: Product-RMI coherence
```
# Some products are LHS-only or RHS-only
IF fp_product_code in ["RF", "KORF"]:  # Ratio products
    # Can be either LHS or RHS
ELIF fp_product_code == "COL":
    # Common in both
```

---

## Example: Complete Matching

### Input Strategies
```
STR001: 4 legs [Sell Put 100K, Buy Call 100K, Sell Put 200K, Buy Call 200K]
STR002: 2 legs [Sell Put 100K, Buy Call 100K]
STR003: 3 legs [Sell Put 100K, Buy Call 100K, Sell Call 50K]
STR004: 1 leg [Buy Put 100K]
```

### Process
```
1. Load 15 product fingerprints

2. For each strategy:

   STR001:
     - Extract: leg_count=4, positions=[SP,BC,SP,BC], amounts=[100K,100K,200K,200K]
     - Match vs RF: Score 85 ✅
     - Match vs COL: Score 30 ❌
     - Best: RF (Ratio Forward)
     - Academic: Ratio Forward
     - RMI: LHS (has Sell-Put)

   STR002:
     - Extract: leg_count=2, positions=[SP,BC], amounts=[100K,100K]
     - Match vs COL: Score 100 ✅
     - Best: COL (Collar)
     - Academic: Collar
     - RMI: LHS

   STR003:
     - Extract: leg_count=3, positions=[SP,BC,SC]
     - Match vs SEA: Score 90 ✅ (Seagull)
     - Best: SEA (Call Seagull)
     - Academic: Call Seagull
     - RMI: LHS

   STR004:
     - Extract: leg_count=1, positions=[BP]
     - Match vs VO: Score 100 ✅
     - Best: VO (Vanilla Option)
     - Academic: Long Put
     - RMI: LHS (default)
```

### Output
```
Added 3 columns to all rows:
  - fp_product_code: [RF, COL, SEA, VO]
  - option_strategy: [Ratio Forward, Collar, Call Seagull, Long Put]
  - fp_rmi_type: [LHS, LHS, LHS, LHS]

Classification rate: 100% (4/4 matched)
```

---

## UI/UX Flow

### User Actions
```
1. Navigate to "Match" page
2. View loaded fingerprints (15 products)
3. Click "Classify Strategies"
4. View results table with classifications
```

### User Feedback
```
During matching:
  - "Analyzing 4 strategies..."
  - "Matching against 15 product fingerprints..."

Success:
  - ✅ "4/4 strategies classified (100%)"
  - Show breakdown:
      RF: 1 strategy
      COL: 1 strategy
      SEA: 1 strategy
      VO: 1 strategy

Warnings:
  - ⚠️ "STR005: UNKNOWN (low match scores)"
  - Suggest manual review
```

---

## Performance Considerations

### Fingerprint Matching Optimization

```python
# Early termination on perfect match
for fingerprint in fingerprints:
    score = calculate_score(strategy, fingerprint)
    
    if score == 100:
        return fingerprint  # Stop checking
```

### Parallel Processing

```python
# Classify multiple strategies in parallel
from multiprocessing import Pool

with Pool(workers=4) as pool:
    results = pool.map(classify_strategy, strategy_ids)
```

---

## Data Persistence

### State Storage
```python
state['match_data'] = df_classified
state['match_metadata'] = {
    'classification_rate': 100,
    'product_distribution': {
        'RF': 1,
        'COL': 1,
        'SEA': 1,
        'VO': 1
    },
    'timestamp': datetime.now()
}
```

---

## Summary

**Stage**: Match (Stage 4 of 5)  
**Input**: Grouped DataFrame with strategy_id  
**Output**: DataFrame with fp_product_code, option_strategy, fp_rmi_type  
**Key Technique**: Pattern-based fingerprint matching + academic rules  
**Performance**: < 1 second for typical datasets  
**Next Stage**: Calculate (aggregate multi-leg into single row)

---

## Transition to Stage 5

```
Match Output → Calculate Input

DataFrame: Multi-leg with classifications
Next step: Aggregate to single row per strategy with calculated fields
```
