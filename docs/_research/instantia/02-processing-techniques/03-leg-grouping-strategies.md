# Multi-Leg Strategy Grouping

## Problem Statement

FX option trades are executed as individual legs but logically form multi-leg strategies:

```
Input CSV (4 rows):
trade_id=101, date=2024-01-15, expiry=2024-06-15, pair=EUR/USD, Sell Put @ 1.08
trade_id=102, date=2024-01-15, expiry=2024-06-15, pair=EUR/USD, Buy Call @ 1.10
trade_id=103, date=2024-01-16, expiry=2024-06-15, pair=EUR/USD, Sell Put @ 1.06
trade_id=104, date=2024-01-16, expiry=2024-06-15, pair=EUR/USD, Buy Call @ 1.12

Desired grouping:
Strategy 1: [trade_101, trade_102]  → Same day, expiry, pair
Strategy 2: [trade_103, trade_104]  → Different day
```

**Challenge**: No explicit "strategy_id" in source data → must infer grouping

---

## Core Concept: Composite Key Grouping

### Grouping Key Definition

A **grouping key** is a combination of attributes that uniquely identifies a strategy:

```
grouping_key = f"{trade_date}|{expiry_date}|{currency_pair}|{company}"
```

**Rationale**: Legs executed on the same day, for the same expiry, in the same currency, by the same client → likely part of one strategy

### Key Selection Criteria

**Must Include**:
- `trade_date`: When executed
- `expiry_date`: When options mature
- `currency_pair`: EUR/USD, GBP/USD, etc.

**Should Include** (if available):
- `company_code`: Client identifier
- `portfolio`: Trading book
- `trader_id`: Who executed

**May Include** (optional):
- `original_trade_no`: Parent trade reference
- `strategy_ref`: Explicit strategy marker (rare)

---

## Multi-Level Grouping Algorithm

### Level 1: Exact Match

**Logic**: Group rows with identical keys

```python
Step 1: Build composite key for each row
  row1_key = "2024-01-15|2024-06-15|EUR/USD|ACME"
  row2_key = "2024-01-15|2024-06-15|EUR/USD|ACME"
  row3_key = "2024-01-16|2024-06-15|EUR/USD|ACME"

Step 2: Group by key
  groups = {
      "2024-01-15|2024-06-15|EUR/USD|ACME": [row1, row2],
      "2024-01-16|2024-06-15|EUR/USD|ACME": [row3]
  }

Step 3: Assign strategy IDs
  group1 → strategy_id = STR001
  group2 → strategy_id = STR002
```

### Level 2: Fuzzy Match (Optional)

**Problem**: Data entry errors create false splits

```
Row 1: expiry_date = 2024-06-15
Row 2: expiry_date = 2024-06-16  ← Typo! Should be 06-15

Level 1 result: Two separate groups (wrong)
```

**Solution**: Fuzzy matching with tolerance

```yaml
fuzzy_rules:
  expiry_date:
    tolerance: ±1 day
  
  trade_date:
    tolerance: same day only  # No fuzzy matching
  
  currency_pair:
    tolerance: exact match only
```

**Algorithm**:
```python
For each pair of groups:
    IF trade_date matches exactly
    AND currency_pair matches exactly
    AND expiry_date within ±1 day
    THEN: merge groups
```

### Level 3: Hierarchical Grouping (Advanced)

**Use Case**: Same-day amendments or incremental strategies

```
Morning trade:
  Sell Put @ 1.08, Buy Call @ 1.10 → Strategy A

Afternoon amendment (same day):
  Add: Buy Put @ 1.06 → Extends Strategy A to a spread
```

**Grouping**:
```python
Primary key: trade_date + expiry + pair
Secondary key: amendment_time

IF amendment_flag == True:
    link to parent strategy
ELSE:
    create new strategy
```

---

## Grouping Key Design Patterns

### Pattern 1: Conservative (High Precision)

```yaml
grouping_keys:
  - trade_date
  - expiry_date
  - currency_pair
  - company_code
  - portfolio

behavior: Strict matching → Few false positives
risk: May split legitimate multi-leg strategies
```

**Best For**: Clean data with reliable identifiers

### Pattern 2: Permissive (High Recall)

```yaml
grouping_keys:
  - expiry_date
  - currency_pair

fuzzy:
  expiry_date: ±2 days

behavior: Loose matching → Captures more strategies
risk: May group unrelated trades
```

**Best For**: Poor data quality, missing fields

### Pattern 3: Hybrid (Balanced)

```yaml
grouping_keys:
  required:
    - trade_date
    - expiry_date
    - currency_pair
  
  optional:
    - company_code  # Use if available

fuzzy:
  expiry_date: ±1 day  # Only if no exact match
```

**Best For**: Mixed data quality

---

## Handling Edge Cases

### Case 1: Single-Leg "Strategies"

```
Input:
trade_id=105, Sell Put @ 1.08

Grouping result:
Strategy STR003: [trade_105]  → Single leg
```

**Handling**:
- Still assign strategy_id
- Flag as `leg_count=1`
- May represent vanilla option or incomplete data

### Case 2: Orphaned Legs

```
Problem:
trade_id=106, date=2024-01-15, expiry=2024-06-15  (Sell Put)
trade_id=107, date=2024-01-15, expiry=2024-06-20  (Buy Call)

Different expiry dates → Cannot group
```

**Handling**:
```
Strategy STR004: [trade_106]  (Orphan)
Strategy STR005: [trade_107]  (Orphan)

Flag: likely_incomplete = True
```

### Case 3: Asymmetric Amounts

```
Strategy:
Leg 1: Sell Put $100,000
Leg 2: Buy Call $200,000  ← Double notional

Still grouped together (same key)
```

**Validation**:
- Group first, validate later
- Fingerprint matching will catch ratio products

### Case 4: Mixed Dates

```
trade_id=108, trade_date=2024-01-15, expiry=2024-06-15
trade_id=109, trade_date=2024-01-15, expiry=2024-06-15
trade_id=110, trade_date=2024-01-16, expiry=2024-06-15  ← Next day

Should 110 join the group?
```

**Decision Rules**:
```
Strict mode: NO (different trade_date)
Fuzzy mode: Check if amendment or correction
User override: Manual grouping allowed
```

---

## Performance Optimization

### Hash-Based Grouping

**Instead of nested loops**:
```python
# Slow: O(N²)
for i in range(len(rows)):
    for j in range(i+1, len(rows)):
        if keys_match(rows[i], rows[j]):
            group_together(rows[i], rows[j])
```

**Use hash tables**: O(N)
```python
groups = {}

for row in rows:
    key = build_key(row)
    
    if key not in groups:
        groups[key] = []
    
    groups[key].append(row)
```

### Vectorized Operations

```python
# Pandas vectorization
df['grouping_key'] = (
    df['trade_date'].astype(str) + '|' +
    df['expiry_date'].astype(str) + '|' +
    df['currency_pair']
)

df['strategy_id'] = df.groupby('grouping_key').ngroup()
```

---

## Validation Checks

### Post-Grouping Validation

**Check 1**: Leg count distribution
```
Expected: Most strategies have 2-3 legs
If >50% single-leg: Grouping may be too strict
If >20% 5+ legs: Grouping may be too loose
```

**Check 2**: Position balance
```
For each group:
    Sell-Put count + Sell-Call count >= 1
    Buy-Put count + Buy-Call count >= 1

If only sells or only buys: Likely incomplete
```

**Check 3**: Amount coherence
```
For each group:
    amounts = [leg.counter_amt for leg in group]
    
    IF std_dev(amounts) > 50% of mean:
        Flag: unusual_amounts
```

### Quality Metrics

**Grouping Rate**:
```
grouped_strategies = count(strategy_id with leg_count > 1)
total_strategies = count(unique strategy_id)

grouping_rate = grouped_strategies / total_strategies
Target: > 60%
```

**Average Legs Per Strategy**:
```
avg_legs = total_legs / total_strategies
Target: 2.0 - 2.5 (for typical option products)
```

---

## Configurable Grouping Strategy

### Configuration Example

```yaml
grouping:
  # Primary grouping keys
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
  
  # Filtering bad trades
  filters:
    exclude_if:
      - trade_id <= 0
      - expiry_date is null
  
  # Multi-level strategy
  levels:
    - name: exact
      enabled: true
    
    - name: fuzzy
      enabled: true
      fields: [expiry_date]
```

### Dynamic Key Selection

```python
# Adapt to available fields
available_fields = df.columns

grouping_keys = []

if 'trade_date' in available_fields:
    grouping_keys.append('trade_date')

if 'company_code' in available_fields:
    grouping_keys.append('company_code')

# Fallback to minimal keys
if len(grouping_keys) < 2:
    grouping_keys = ['expiry_date', 'currency_pair']
```

---

## Testing Strategy

### Unit Tests

**Test 1**: Exact grouping
```python
input = [
    {"date": "2024-01-15", "expiry": "2024-06-15", "pair": "EUR/USD"},
    {"date": "2024-01-15", "expiry": "2024-06-15", "pair": "EUR/USD"},
]

result = group(input)

assert len(result) == 1  # Single group
assert result[0].leg_count == 2
```

**Test 2**: Split groups
```python
input = [
    {"date": "2024-01-15", "expiry": "2024-06-15", "pair": "EUR/USD"},
    {"date": "2024-01-16", "expiry": "2024-06-15", "pair": "EUR/USD"},
]

result = group(input)

assert len(result) == 2  # Two separate groups
```

**Test 3**: Fuzzy grouping
```python
input = [
    {"expiry": "2024-06-15"},
    {"expiry": "2024-06-16"},  # Off by 1 day
]

result = group(input, fuzzy=True, tolerance="±1 day")

assert len(result) == 1  # Grouped together
```

---

## Summary

**Technique**: Composite key grouping with multi-level matching  
**Key Components**:
- Hash-based grouping for performance
- Configurable keys and fuzzy rules
- Post-grouping validation

**Benefits**:
- Handles missing explicit strategy IDs
- Robust to data entry errors (fuzzy mode)
- Configurable for different data quality

**Best For**: Batch processing of trade legs  
**Trade-off**: Risk of false positives (grouping unrelated trades)  
**When to Use**: Source data has consistent attributes but no strategy ID field
