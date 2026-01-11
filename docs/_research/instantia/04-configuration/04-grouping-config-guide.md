# Configuration Guide: Grouping Configuration

## Overview

The `grouping_config.yaml` file defines how individual trade legs are grouped into multi-leg strategies based on common attributes like trade date, expiry, and currency pair.

**Location**: `configs/grouping_config.yaml`

---

## File Structure

```yaml
grouping:
  # Grouping keys
  keys:
    - field: <field_name>
      required: <true/false>
      fuzzy: <true/false>
      tolerance: <value>
  
  # Bad trade filters
  filters:
    exclude_if:
      - <condition_expression>
  
  # Multi-level grouping
  levels:
    - name: <level_name>
      enabled: <true/false>
      fields: [<field_list>]
```

---

## Grouping Keys

Keys define which fields must match for legs to be grouped together.

### Basic Key Configuration
```yaml
keys:
  - field: trade_date
    required: true
    fuzzy: false
  
  - field: expiry_date
    required: true
    fuzzy: true
    tolerance: ±1 day
  
  - field: currency_pair
    required: true
    fuzzy: false
  
  - field: company_code
    required: false  # Optional
    fuzzy: false
```

### Field Properties

| Property | Type | Purpose | Example |
|----------|------|---------|---------|
| `field` | String | Column name to group by | `trade_date` |
| `required` | Boolean | Must be present | `true` (exclude if missing) |
| `fuzzy` | Boolean | Allow approximate matching | `true` (±1 day tolerance) |
| `tolerance` | String | Fuzzy match range | `±1 day`, `±2 hours` |

---

## Grouping Strategies

### Strategy 1: Conservative (High Precision)
```yaml
# Group only if ALL keys match exactly
keys:
  - field: trade_date
    required: true
    fuzzy: false
  
  - field: expiry_date
    required: true
    fuzzy: false
  
  - field: currency_pair
    required: true
    fuzzy: false
  
  - field: company_code
    required: true
    fuzzy: false
  
  - field: portfolio
    required: true
    fuzzy: false
```

**Result**: Very few false positives, but may split legitimate strategies

### Strategy 2: Permissive (High Recall)
```yaml
# Minimal keys, allow fuzzy matching
keys:
  - field: expiry_date
    required: true
    fuzzy: true
    tolerance: ±2 days
  
  - field: currency_pair
    required: true
    fuzzy: false
```

**Result**: Captures more strategies, but risk of grouping unrelated trades

### Strategy 3: Balanced (Recommended)
```yaml
keys:
  # Strict fields
  - field: trade_date
    required: true
    fuzzy: false
  
  - field: currency_pair
    required: true
    fuzzy: false
  
  # Fuzzy field (handles typos)
  - field: expiry_date
    required: true
    fuzzy: true
    tolerance: ±1 day
  
  # Optional fields (use if available)
  - field: company_code
    required: false
    fuzzy: false
```

---

## Fuzzy Matching

### Date Fuzzy Matching
```yaml
- field: expiry_date
  fuzzy: true
  tolerance: ±1 day
```

**Example**:
```
Leg 1: expiry = 2024-06-15
Leg 2: expiry = 2024-06-16  (typo)

Exact match: Different groups
Fuzzy match (±1 day): Same group ✅
```

### How It Works
```python
# Exact matching
if leg1['expiry_date'] == leg2['expiry_date']:
    same_group = True

# Fuzzy matching
diff = abs(leg1['expiry_date'] - leg2['expiry_date'])
if diff <= timedelta(days=1):
    same_group = True
```

---

## Bad Trade Filters

Exclude rows that don't meet quality criteria.

```yaml
filters:
  exclude_if:
    - trade_id <= 0
    - trade_id is null
    - expiry_date is null
    - counter_amt <= 0
    - currency_pair is null
```

**Execution**:
```python
# Before grouping, remove bad trades
valid_trades = df[
    (df['trade_id'] > 0) &
    (df['expiry_date'].notna()) &
    (df['counter_amt'] > 0)
]

# Then group
groups = valid_trades.groupby(grouping_keys)
```

---

## Multi-Level Grouping

Try multiple grouping strategies sequentially.

```yaml
levels:
  # Level 1: Strict with company_code
  - name: exact_with_company
    enabled: true
    keys:
      - trade_date
      - expiry_date
      - currency_pair
      - company_code
    fuzzy: false
  
  # Level 2: Without company_code (fallback)
  - name: exact_without_company
    enabled: true
    keys:
      - trade_date
      - expiry_date
      - currency_pair
    fuzzy: false
  
  # Level 3: Fuzzy matching
  - name: fuzzy
    enabled: true
    keys:
      - trade_date
      - expiry_date
      - currency_pair
    fuzzy:
      expiry_date: ±1 day
```

**Execution Flow**:
```
1. Try Level 1 (strictest)
   → If grouping_rate < 50%, proceed to Level 2

2. Try Level 2 (less strict)
   → If grouping_rate < 50%, proceed to Level 3

3. Try Level 3 (fuzzy)
   → Use this result
```

---

## Example Configurations

### Configuration 1: Clean Data
```yaml
# When data is reliable, use strict matching
grouping:
  keys:
    - field: trade_date
      required: true
    - field: expiry_date
      required: true
    - field: currency_pair
      required: true
    - field: company_code
      required: true
  
  filters:
    exclude_if:
      - trade_id <= 0
```

### Configuration 2: Messy Data
```yaml
# When data has errors, use fuzzy matching
grouping:
  keys:
    - field: trade_date
      required: true
      fuzzy: true
      tolerance: ±1 day
    
    - field: expiry_date
      required: true
      fuzzy: true
      tolerance: ±2 days
    
    - field: currency_pair
      required: true
      fuzzy: false
  
  filters:
    exclude_if:
      - trade_id <= 0
      - expiry_date is null
```

### Configuration 3: Mixed Quality
```yaml
# Adaptive - try strict then fall back to fuzzy
grouping:
  levels:
    - name: strict
      keys: [trade_date, expiry_date, currency_pair, company_code]
      fuzzy: false
    
    - name: moderate
      keys: [trade_date, expiry_date, currency_pair]
      fuzzy:
        expiry_date: ±1 day
    
    - name: permissive
      keys: [expiry_date, currency_pair]
      fuzzy:
        expiry_date: ±2 days
```

---

## Customization Guide

### Adding a New Grouping Key
```yaml
# Scenario: Group by trader_id

keys:
  - field: trade_date
    required: true
  
  - field: trader_id  # ← Add this
    required: false   # Optional (may not be in all files)
    fuzzy: false
```

### Adjusting Fuzzy Tolerance
```yaml
# Increase tolerance if seeing too many orphans
- field: expiry_date
  fuzzy: true
  tolerance: ±3 days  # Was ±1 day

# Decrease if seeing false groupings
- field: expiry_date
  fuzzy: true
  tolerance: ±0 days  # Effectively exact match
```

### Adding Filter Conditions
```yaml
filters:
  exclude_if:
    - trade_id <= 0
    - expiry_date is null
    - counter_amt == 0  # ← Add this (exclude zero amounts)
    - status == 'CANCELLED'  # ← Add this
```

---

## Validation Metrics

### Post-Grouping Checks
```yaml
metrics:
  # Grouping rate
  target_grouping_rate: 0.60  # 60% multi-leg
  
  # Orphan rate
  max_orphan_rate: 0.30  # < 30% single-leg
  
  # Average legs per strategy
  expected_avg_legs: 2.5  # 2-3 legs typical
```

**Interpretation**:
```
IF grouping_rate < target:
    → Grouping too strict, relax keys

IF orphan_rate > max:
    → Too many single-leg strategies, check data quality

IF avg_legs > 5:
    → Grouping too loose, add more keys
```

---

## Testing Your Configuration

### Test 1: Known Multi-Leg
```
Input:
  Leg 1: trade=2024-01-15, expiry=2024-06-15, pair=EUR/USD
  Leg 2: trade=2024-01-15, expiry=2024-06-15, pair=EUR/USD

Expected: Same strategy_id
```

### Test 2: Different Trades
```
Input:
  Leg 1: trade=2024-01-15, expiry=2024-06-15, pair=EUR/USD
  Leg 2: trade=2024-01-16, expiry=2024-06-15, pair=EUR/USD

Expected: Different strategy_id (different trade_date)
```

### Test 3: Fuzzy Match
```
Input:
  Leg 1: expiry=2024-06-15
  Leg 2: expiry=2024-06-16  (typo)

Expected (with fuzzy ±1 day): Same strategy_id
Expected (without fuzzy): Different strategy_id
```

---

## Summary

**Purpose**: Define how legs are grouped into strategies  
**Key Concept**: Composite key grouping with fuzzy matching  
**Format**: YAML with keys, filters, and levels  
**Usage**: Group stage (Stage 3)  

**Critical Trade-off**: Precision vs Recall
- Strict keys → High precision, low recall (miss valid groups)
- Fuzzy matching → High recall, lower precision (false groups)

**Best Practice**: Start strict, relax if needed based on metrics  
**Testing**: Always validate with known multi-leg examples
