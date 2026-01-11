# Stage 3: Group - Strategy Identification

## Purpose
Identify which individual legs belong to the same multi-leg strategy by grouping rows based on common attributes.

---

## Input (from Stage 2)

### Standardized DataFrame
```
15 rows × 9 columns
All columns have standard names

   counter_amt  rate  expiry_date  buy_sell  call_put  currency_pair  trade_date
0  100000       1.08  2024-06-15   Sell      Put       EURUSD         2024-01-15
1  100000       1.10  2024-06-15   Buy       Call      EURUSD         2024-01-15
2  200000       1.06  2024-06-15   Sell      Put       EURUSD         2024-01-15
3  200000       1.12  2024-06-15   Buy       Call      EURUSD         2024-01-15
4  100000       1.08  2024-07-15   Sell      Put       EURUSD         2024-01-16
5  100000       1.10  2024-07-15   Buy       Call      EURUSD         2024-01-16
...
```

**Problem**: No explicit `strategy_id` field linking related legs

---

## Process Flow

### Step 1: Load Grouping Configuration

```yaml
# From: configs/grouping_config.yaml
grouping:
  keys:
    - field: trade_date
      required: true
    - field: expiry_date
      required: true
    - field: currency_pair
      required: true
    - field: company_code
      required: false
  
  filters:
    exclude_if:
      - trade_id <= 0
      - expiry_date is null
```

### Step 2: Build Composite Grouping Keys

```python
# Concatenate key fields into single string
df['grouping_key'] = (
    df['trade_date'].astype(str) + '|' +
    df['expiry_date'].astype(str) + '|' +
    df['currency_pair']
)
```

**Result**:
```
Row 0: "2024-01-15|2024-06-15|EURUSD"
Row 1: "2024-01-15|2024-06-15|EURUSD"  (same as Row 0)
Row 2: "2024-01-15|2024-06-15|EURUSD"  (same as Row 0)
Row 3: "2024-01-15|2024-06-15|EURUSD"  (same as Row 0)
Row 4: "2024-01-16|2024-07-15|EURUSD"  (different trade_date)
Row 5: "2024-01-16|2024-07-15|EURUSD"  (same as Row 4)
```

### Step 3: Filter Bad Trades

```python
# Remove rows that fail validation
valid_trades = df[
    (df['trade_id'] > 0) &
    (df['expiry_date'].notna())
]

print(f"Filtered out {len(df) - len(valid_trades)} bad trades")
```

### Step 4: Group by Composite Key (Level 1: Exact Match)

```python
strategy_groups = valid_trades.groupby('grouping_key')

# Assign strategy IDs
strategy_id_map = {}
for idx, (key, group) in enumerate(strategy_groups):
    strategy_id = f"STR{idx+1:03d}"  # STR001, STR002, ...
    for row_idx in group.index:
        strategy_id_map[row_idx] = strategy_id

valid_trades['strategy_id'] = valid_trades.index.map(strategy_id_map)
```

**Result**:
```
Group 1 (key="2024-01-15|2024-06-15|EURUSD"):
  Rows: 0, 1, 2, 3 → strategy_id = "STR001"

Group 2 (key="2024-01-16|2024-07-15|EURUSD"):
  Rows: 4, 5 → strategy_id = "STR002"

...
```

### Step 5: Fuzzy Grouping (Level 2, Optional)

```yaml
# Optional: Merge groups with near-matching dates
fuzzy:
  enabled: true
  fields:
    expiry_date:
      tolerance: ±1 day
```

**Process**:
```python
IF fuzzy enabled:
    # Find groups with expiry dates within ±1 day
    for group1, group2 in pairs(strategy_groups):
        if same_trade_date(group1, group2) and \
           same_currency(group1, group2) and \
           expiry_diff(group1, group2) <= 1 day:
            merge_groups(group1, group2)
```

**Example**:
```
Before fuzzy:
  STR001: expiry=2024-06-15
  STR003: expiry=2024-06-16  (typo!)

After fuzzy:
  STR001: Both groups merged
```

### Step 6: Validation & Metrics

```python
# Calculate statistics
total_strategies = df['strategy_id'].nunique()
total_legs = len(df)
avg_legs_per_strategy = total_legs / total_strategies

print(f"Grouped {total_legs} legs into {total_strategies} strategies")
print(f"Average: {avg_legs_per_strategy:.1f} legs/strategy")
```

---

## Output Format

### Grouped DataFrame

**Added Column**: `strategy_id`

```
   strategy_id  counter_amt  rate  expiry_date  buy_sell  call_put  currency_pair  trade_date
0  STR001       100000       1.08  2024-06-15   Sell      Put       EURUSD         2024-01-15
1  STR001       100000       1.10  2024-06-15   Buy       Call      EURUSD         2024-01-15
2  STR001       200000       1.06  2024-06-15   Sell      Put       EURUSD         2024-01-15
3  STR001       200000       1.12  2024-06-15   Buy       Call      EURUSD         2024-01-15
4  STR002       100000       1.08  2024-07-15   Sell      Put       EURUSD         2024-01-16
5  STR002       100000       1.10  2024-07-15   Buy       Call      EURUSD         2024-01-16
```

---

## Edge Cases

### Case 1: Single-Leg Strategies

```
Input:
  Row 10: Sell Put @ 1.08 (no matching legs)

Grouping:
  strategy_id = STR005
  leg_count = 1

Handling:
  - Still assign strategy ID
  - Flag: likely vanilla option or incomplete data
```

### Case 2: Large Strategy Groups

```
Problem:
  Strategy has 10+ legs (unusual)

Validation:
  Warning: "Strategy STR003 has 10 legs (expected 2-4)"
  Suggest: Review grouping keys
```

### Case 3: Missing Grouping Fields

```
Problem:
  Some rows missing expiry_date

Handling:
  Option A: Exclude from grouping (filter out)
  Option B: Group by remaining fields only
  Default: Exclude (safer)
```

### Case 4: Conflicting Grouping

```
Problem:
  User wants to group by company_code,
  but field is not populated

Handling:
  - Detect missing optional key
  - Proceed without it
  - Warning: "company_code not found, grouping without it"
```

---

## Grouping Quality Metrics

### Metric 1: Grouping Rate

```
grouped_strategies = count(strategy_id where leg_count > 1)
total_strategies = count(unique strategy_id)

grouping_rate = grouped_strategies / total_strategies

Target: > 60% (typical for multi-leg products)
```

### Metric 2: Leg Count Distribution

```
Expected distribution:
  - 2 legs: 60%  (Collars, Risk Reversals)
  - 3 legs: 20%  (Seagulls)
  - 4 legs: 10%  (Ratio products with barriers)
  - 1 leg: 10%   (Vanilla options)

IF distribution significantly different:
    Warning: Check grouping logic
```

### Metric 3: Orphan Rate

```
orphans = count(strategy_id where leg_count == 1)
orphan_rate = orphans / total_strategies

IF orphan_rate > 30%:
    Warning: High orphan rate, grouping may be too strict
```

---

## Validation Checks

### Post-Grouping Validation

**Check 1**: Position balance
```python
for strategy_id in strategy_ids:
    group = df[df['strategy_id'] == strategy_id]
    
    sell_count = (group['buy_sell'] == 'Sell').sum()
    buy_count = (group['buy_sell'] == 'Buy').sum()
    
    IF sell_count == 0 OR buy_count == 0:
        Warning: "Unbalanced strategy (only sells or only buys)"
```

**Check 2**: Date consistency
```python
for strategy_id in strategy_ids:
    group = df[df['strategy_id'] == strategy_id]
    
    unique_expiries = group['expiry_date'].nunique()
    
    IF unique_expiries > 1:
        Warning: "Multiple expiry dates in strategy"
```

---

## Example: Complete Grouping

### Input (15 rows)
```
Rows 0-3: trade=2024-01-15, expiry=2024-06-15, pair=EURUSD
Rows 4-5: trade=2024-01-16, expiry=2024-07-15, pair=EURUSD
Rows 6-8: trade=2024-01-15, expiry=2024-06-15, pair=GBPUSD
Rows 9: trade=2024-01-15, expiry=2024-06-15, pair=EURUSD, expiry_null!
Rows 10-14: trade=2024-01-17, expiry=2024-08-15, pair=USD JPY
```

### Process
```
1. Load config: Group by [trade_date, expiry_date, currency_pair]

2. Build keys:
   - Rows 0-3: "2024-01-15|2024-06-15|EURUSD"
   - Rows 4-5: "2024-01-16|2024-07-15|EURUSD"
   - Rows 6-8: "2024-01-15|2024-06-15|GBPUSD"
   - Row 9: null key (expiry missing) → EXCLUDED
   - Rows 10-14: "2024-01-17|2024-08-15|USDJPY"

3. Filter: Exclude Row 9 (missing expiry)

4. Group (exact match):
   - Group A: Rows 0-3 → STR001 (4 legs)
   - Group B: Rows 4-5 → STR002 (2 legs)
   - Group C: Rows 6-8 → STR003 (3 legs)
   - Group D: Rows 10-14 → STR004 (5 legs!)

5. Validate:
   - STR001: 4 legs → OK (ratio product)
   - STR002: 2 legs → OK (collar)
   - STR003: 3 legs → OK (seagull)
   - STR004: 5 legs → WARNING (unusual)
```

### Output
```
14 rows × 10 columns (15 - 1 excluded)
New column: strategy_id

Metrics:
  - Total strategies: 4
  - Average legs/strategy: 3.5
  - Grouping rate: 100% (no orphans)
```

---

## UI/UX Flow

### User Actions
```
1. Navigate to "Group" page
2. Configure grouping keys (checkboxes)
3. Enable/disable fuzzy matching
4. Click "Group Strategies"
5. View results:
   - Strategy count
   - Leg count distribution
   - Grouped data table
```

### User Feedback
```
During grouping:
  - "Grouping by: trade_date, expiry_date, currency_pair"
  - "Processing 15 legs..."

Success:
  - ✅ "Grouped into 4 strategies"
  - "Average: 3.5 legs/strategy"
  - Show strategy breakdown table

Warnings:
  - ⚠️ "Strategy STR004 has 5 legs (unusual)"
  - ⚠️ "1 row excluded (missing expiry_date)"
```

---

## Configurable Grouping

### Multi-Level Strategy

```yaml
grouping:
  level_1:
    keys: [trade_date, expiry_date, currency_pair, company_code]
    fuzzy: false
  
  level_2:
    enabled: true
    keys: [trade_date, expiry_date, currency_pair]
    fuzzy:
      expiry_date: ±1 day
```

**Execution**:
```
1. Try level_1 (strict with company_code)
2. If low grouping rate, fall back to level_2 (without company_code)
3. Apply fuzzy matching on level_2
```

---

## Performance Considerations

### Hash-Based Grouping
```
Time complexity: O(N) for N rows
Space complexity: O(N) for grouping_key column

Much faster than nested loops: O(N²)
```

### Memory Optimization
```python
# Use categorical dtype for strategy_id (smaller memory)
df['strategy_id'] = df['strategy_id'].astype('category')
```

---

## Data Persistence

### State Storage
```python
state['group_data'] = df_grouped
state['group_metadata'] = {
    'strategy_count': total_strategies,
    'avg_legs': avg_legs_per_strategy,
    'grouping_keys': grouping_keys,
    'timestamp': datetime.now()
}
```

---

## Summary

**Stage**: Group (Stage 3 of 5)  
**Input**: Standardized DataFrame (individual legs)  
**Output**: DataFrame with `strategy_id` column  
**Key Technique**: Composite key hash grouping  
**Performance**: < 1 second for typical datasets  
**Next Stage**: Match (classify product types)

---

## Transition to Stage 4

```
Group Output → Match Input

DataFrame: Multi-leg strategies with strategy_id
Next step: Identify what product each strategy is
```
