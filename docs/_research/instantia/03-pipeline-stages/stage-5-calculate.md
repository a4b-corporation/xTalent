# Stage 5: Calculate - Multi-Leg Aggregation

## Purpose
Aggregate multi-leg strategies into single rows with consolidated calculated output fields using RMI-aware aggregation rules.

---

## Input (from Stage 4)

### Classified DataFrame  
```
14 rows × 13 columns (multi-leg with classifications)

strategy_id  fp_product_code  option_strategy  fp_rmi_type  counter_amt  rate  buy_sell  call_put  expiry_date
STR001       RF               Ratio Forward    LHS          100000       1.08  Sell      Put       2024-06-15
STR001       RF               Ratio Forward    LHS          100000       1.10  Buy       Call      2024-06-15
STR001       RF               Ratio Forward    LHS          200000       1.06  Sell      Put       2024-06-15
STR001       RF               Ratio Forward    LHS          200000       1.12  Buy       Call      2024-06-15
STR002       COL              Collar           LHS          100000       1.08  Sell      Put       2024-07-15
STR002       COL              Collar           LHS          100000       1.10  Buy       Call      2024-07-15
```

**Objective**: Consolidate to 2 rows (one per strategy) with all calculated fields

---

## Process Flow

### Step 1: Load Aggregation Rules & Output Fields

```yaml
# From: configs/aggregation_rules.yaml
rules:
  - name: original_notional_amount
    target_field: original_notional_amount
    source_field: counter_amt
    aggregation: sum
    rmi_logic:
      LHS: lhs_notional  # Filter: Sell-Put legs
      RHS: rhs_notional  # Filter: Sell-Call legs

  - name: strike_rate
    target_field: strike_rate
    source_field: rate
    aggregation: first
    rmi_logic:
      LHS: lhs_notional
      RHS: rhs_notional

# From: configs/output_fields.yaml
output_fields:
  - name: strategy_id
  - name: original_notional_amount
  - name: strike_rate
  - name: ratio
  ... (23 total fields)
```

### Step 2: Group by Strategy ID

```python
grouped = df.groupby('strategy_id')

# Process each strategy group
for strategy_id, strategy_df in grouped:
    output_row = aggregate_strategy(strategy_df)
```

### Step 3: Detect RMI Type

```python
def detect_rmi(strategy_df):
    has_sell_put = any(
        (strategy_df['buy_sell'] == 'Sell') & 
        (strategy_df['call_put'] == 'Put')
    )
    
    if has_sell_put:
        return 'LHS'
    else:
        return 'RHS'
```

**Result**:
```
STR001: Has Sell-Put → RMI = LHS
STR002: Has Sell-Put → RMI = LHS
```

### Step 4: Apply RMI-Aware Aggregation

**Example: Original Notional Amount (STR001, LHS)**

```python
# Get applicable rule
rule = find_rule('original_notional_amount')

# Determine filter for LHS
filter_name = rule['rmi_logic']['LHS']  # "lhs_notional"

# Apply filter (Sell-Put legs only)
filtered_legs = strategy_df[
    (strategy_df['buy_sell'] == 'Sell') &
    (strategy_df['call_put'] == 'Put')
]

# Aggregate
original_notional = filtered_legs['counter_amt'].sum()
# = 100,000 + 200,000 = 300,000
```

**Example: Strike Rate (STR001, LHS)**

```python
# Same filter (lhs_notional)
filtered_legs = Sell-Put legs

# Take first rate
strike_rate = filtered_legs['rate'].iloc[0]
# = 1.08
```

**Example: Upper Barrier (STR001, LHS)**

```python
# Filter: Buy-Call legs
filtered_legs = strategy_df[
    (strategy_df['buy_sell'] == 'Buy') &
    (strategy_df['call_put'] == 'Call')
]

# Max rate
upper_barrier = filtered_legs['rate'].max()
# = max(1.10, 1.12) = 1.12
```

### Step 5: Calculate Derived Fields

**Ratio Calculation**:
```python
leverage = row['original_leverage_amount']  # 300,000
notional = row['original_notional_amount']  # 300,000

if notional > 0:
    ratio_value = leverage / notional  # 300K / 300K = 1.0
    ratio = f"1:{ratio_value:.1f}"  # "1:1.0"
else:
    ratio = None
```

**Barrier Type Inference**:
```python
has_barrier = (barrier_1 is not None and barrier_1 > 0)

if not has_barrier:
    barrier_type = "European"
elif window_start and window_start >= datetime(1990, 1, 1):
    if trade_date >= window_start:
        barrier_type = "American"
    else:
        barrier_type = "Window"
else:
    barrier_type = "European"
```

### Step 6: Format Output

```python
# Apply format rules
result['original_notional_amount'] = f"{value:,.2f}"  # "300,000.00"
result['strike_rate'] = f"{value:.4f}"  # "1.0800"
result['expiry_date'] = value.strftime("%Y-%m-%d")  # "2024-06-15"
```

### Step 7: Assemble Output Row

```python
output_row = {
    'strategy_id': 'STR001',
    'fp_product_code': 'RF',
    'option_strategy': 'Ratio Forward',
    'rmi_type': 'LHS',
    'original_notional_amount': 300000.00,
    'original_leverage_amount': 300000.00,
    'strike_rate': 1.08,
    'upper_barrier_rate': 1.12,
    'ratio': '1:1.0',
    'expiry_date': '2024-06-15',
    'currency_pair': 'EURUSD',
    'leg_sequence': 4,
    ... (23 total output fields)
}
```

---

## Output Format

### Final Aggregated DataFrame

**Input**: 14 rows (multi-leg)  
**Output**: 2 rows (one per strategy)

```
strategy_id  fp_product_code  option_strategy  rmi_type  original_notional  strike_rate  upper_barrier  ratio  expiry_date  leg_sequence
STR001       RF               Ratio Forward    LHS       300000.00          1.08         1.12           1:1.0  2024-06-15   4
STR002       COL              Collar           LHS       100000.00          1.08         1.10           null   2024-07-15   2
```

---

## RMI-Specific Examples

### LHS (Importer) Aggregation

**Strategy**: STR002 (Collar, LHS)
```
Legs:
  1. Sell Put @ 1.08, $100K
  2. Buy Call @ 1.10, $100K

Aggregation:
  original_notional_amount = sum(Sell-Put counter_amt) = $100K
  original_leverage_amount = sum(Buy-Call counter_amt) = $100K
  strike_rate = first(Sell-Put rate) = 1.08
  upper_barrier_rate = max(Buy-Call rate) = 1.10
  ratio = leverage / notional = 100K / 100K = "1:1" (but Collar → null)
```

### RHS (Exporter) Aggregation

**Strategy**: STR_RHS (RHS Collar)
```
Legs:
  1. Sell Call @ 1.10, $100K
  2. Buy Put @ 1.08, $100K

Aggregation:
  original_notional_amount = sum(Sell-Call counter_amt) = $100K
  original_leverage_amount = sum(Buy-Put counter_amt) = $100K
  strike_rate = first(Sell-Call rate) = 1.10
  lower_barrier_rate = min(Buy-Put rate) = 1.08
  ratio = null (Collar)
```

---

## Edge Cases

### Case 1: Single-Leg Strategy

```
Strategy: STR_VO (Vanilla Option, 1 leg)
  Leg: Sell Put @ 1.08, $100K

Aggregation:
  - No grouping needed (already 1 row)
  - original_notional = $100K
  - ratio = null (no leverage)
  - leg_sequence = 1
```

### Case 2: Missing Fields

```
Problem: Some legs missing premium_amt

Handling:
  - Aggregate non-null values only
  - IF all null → output null
  - Flag: incomplete_data
```

### Case 3: Inconsistent Data Within Strategy

```
Problem:
  Leg 1: expiry_date = 2024-06-15
  Leg 2: expiry_date = 2024-06-16  (different!)

Handling:
  - Use first() aggregation
  - expiry_date = 2024-06-15
  - Flag: inconsistent_expiry_dates
```

---

## Output Field Calculations

### Standard Fields (Direct Aggregation)

| Field | Source | Aggregation | RMI-Aware |
|-------|---------|-------------|-----------|
| original_notional_amount | counter_amt | sum | ✅ LHS: Sell-Put, RHS: Sell-Call |
| original_leverage_amount | counter_amt | sum | ✅ LHS: Buy-Call, RHS: Buy-Put |
| strike_rate | rate | first | ✅ From notional filter |
| upper_barrier_rate | rate | max | ✅ LHS: Buy-Call, RHS: barrier_1 |
| lower_barrier_rate | rate | min | ✅ RHS: Buy-Put, LHS: barrier_1 |
| expiry_date | expiry_date | first | ❌ |
| currency_pair | currency_pair | first | ❌ |
| premium_amt | premium_amt | sum | ❌ |

### Calculated Fields

| Field | Formula | Notes |
|-------|---------|-------|
| ratio | leverage / notional | Format: "1:x", null for non-ratio products |
| barrier_type | Date logic | European/American/Window |
| current_residual_amount | contract_amt sum | From notional filter |
| leg_sequence | row count | Number of legs in strategy |

---

## Validation Checks

### Post-Aggregation Validation

**Check 1**: All strategies aggregated
```
input_strategies = df_input['strategy_id'].nunique()
output_strategies = len(df_output)

assert input_strategies == output_strategies
```

**Check 2**: Required fields populated
```
required = ['original_notional_amount', 'strike_rate', 'expiry_date']

for field in required:
    null_count = df_output[field].isnull().sum()
    IF null_count > 0:
        Warning: f"{null_count} strategies missing {field}"
```

**Check 3**: Numeric ranges
```
IF df_output['strike_rate'].min() < 0.01:
    Warning: "Suspiciously low strike rates"

IF df_output['original_notional_amount'].min() < 0:
    Error: "Negative notional amounts"
```

---

## Example: Complete Aggregation

### Input (6 rows, 2 strategies)
```
STR001 (4 legs, RF, LHS):
  Sell Put @ 1.08, $100K
  Buy Call @ 1.10, $100K
  Sell Put @ 1.06, $200K
  Buy Call @ 1.12, $200K

STR002 (2 legs, COL, LHS):
  Sell Put @ 1.08, $100K
  Buy Call @ 1.10, $100K
```

### Process
```
1. Load 23 output field definitions
2. Load aggregation rules

3. For STR001 (RMI=LHS):
   - Notional legs: [Sell-Put @ 1.08 $100K, Sell-Put @ 1.06 $200K]
   - Leverage legs: [Buy-Call @ 1.10 $100K, Buy-Call @ 1.12 $200K]
   
   Aggregations:
     original_notional = 100K + 200K = 300K
     original_leverage = 100K + 200K = 300K
     strike_rate = 1.08 (first Sell-Put)
     upper_barrier = max(1.10, 1.12) = 1.12
     ratio = 300K / 300K = "1:1"
     leg_sequence = 4

4. For STR002 (RMI=LHS):
   - Notional legs: [Sell-Put @ 1.08 $100K]
   - Leverage legs: [Buy-Call @ 1.10 $100K]
   
   Aggregations:
     original_notional = 100K
     original_leverage = 100K
     strike_rate = 1.08
     upper_barrier = 1.10
     ratio = null (Collar, override)
     leg_sequence = 2
```

### Output (2 rows)
```
strategy_id  fp_product_code  original_notional  strike_rate  upper_barrier  ratio  leg_sequence
STR001       RF               300000.00          1.08         1.12           1:1.0  4
STR002       COL              100000.00          1.08         1.10           null   2
```

---

## UI/UX Flow

### User Actions
```
1. Navigate to "Calculation" page
2. Review field mappings (source → output)
3. Optional: Override rule selections
4. Click "Calculate"
5. View aggregated output
6. Export to Excel/CSV
```

### User Feedback
```
During calculation:
  - "Aggregating 4 strategies..."
  - "Applying 23 output rules..."

Success:
  - ✅ "Aggregated 14 legs → 4 strategies"
  - "Average: 3.5 legs/strategy"
  - Show output table

Export:
  - 💾 "Download Output.xlsx"
```

---

## Performance Considerations

### Vectorized Aggregation
```python
# Use pandas groupby (optimized C code)
result = df.groupby('strategy_id').agg({
    'counter_amt': 'sum',
    'rate': 'first',
    'expiry_date': 'first',
    ...
})
# Much faster than row-by-row loops
```

### Filtered Aggregation Optimization
```python
# Pre-filter once, reuse for multiple aggregations
sell_put_mask = (df['buy_sell'] == 'Sell') & (df['call_put'] == 'Put')

notional = df[sell_put_mask].groupby('strategy_id')['counter_amt'].sum()
strike = df[sell_put_mask].groupby('strategy_id')['rate'].first()
```

---

## Data Persistence

### State Storage
```python
state['calculate_data'] = df_output
state['calculate_metadata'] = {
    'input_rows': len(df_input),
    'output_rows': len(df_output),
    'compression_ratio': len(df_input) / len(df_output),
    'timestamp': datetime.now()
}
```

### Export Options
```python
# CSV export
df_output.to_csv('output.csv', index=False)

# Excel export with formatting
with pd.ExcelWriter('output.xlsx') as writer:
    df_output.to_excel(writer, sheet_name='Aggregated', index=False)
```

---

## Summary

**Stage**: Calculate (Stage 5 of 5 - FINAL)  
**Input**: Classified multi-leg DataFrame  
**Output**: Single-row DataFrame per strategy with 23 calculated fields  
**Key Technique**: RMI-aware filtered aggregation + rule-driven calculations  
**Performance**: < 1 second for typical datasets  
**Final Output**: Ready for export or downstream systems

---

## Pipeline Complete! 🎉

```
Stage 1: Extract    → Raw data (15 rows)
Stage 2: Standardize → Standard columns
Stage 3: Group      → strategy_id added
Stage 4: Match      → Products classified
Stage 5: Calculate  → Aggregated output (4 rows)

15 multi-leg rows → 4 consolidated strategies
Time: < 10 seconds total
```
