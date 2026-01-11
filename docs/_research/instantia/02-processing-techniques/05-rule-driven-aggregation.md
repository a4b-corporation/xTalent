# Rule-Driven Aggregation Framework

## Problem Statement

After grouping multi-leg strategies, we need to consolidate them into single rows with calculated fields:

```
Input (3 legs):
Leg 1: Sell Put @ 1.08, $100K
Leg 2: Buy Call @ 1.10, $200K  
Leg 3: Sell Call @ 1.12, $100K

Output (1 row):
original_notional: $100K
original_leverage: $200K
ratio: "1:2"
strike_rate: 1.08
upper_barrier: 1.10
barrier_type: "European"
... (23 total fields)
```

**Challenge**: Different products require different aggregation logic, and requirements change frequently

**Solution**: Configurable rule-based calculation framework

---

## Core Concept: Declarative Rules

Instead of hardcoding calculations:
```python
# BAD: Hardcoded
df['ratio'] = df['leverage'] / df['notional']
```

Use external rule definitions:
```yaml
# GOOD: Configurable
- target_field: ratio
  description: "Leverage to Notional ratio"
  source_fields: [original_leverage_amount, original_notional_amount]
  formula: "leverage / notional if notional > 0 else null"
  format: "1:{x}"
```

---

## Rule Structure

### Basic Rule Components

```yaml
- name: rule_unique_identifier
  target_field: output_field_name
  description: "Human-readable explanation"
  
  # Data source
  source_field: single_input_column
  # OR
  source_fields: [multiple, input, columns]
  
  # Aggregation method
  aggregation: sum | min | max | first | count | custom
  
  # Optional: Filtering
  filter: leg_filter_name
  
  # Optional: Calculation logic
  formula: "python expression"
  
  # Optional: Output formatting
  format: "format string"
```

### Example Rules

**Rule 1: Simple Aggregation**
```yaml
- name: premium_total
  target_field: premium_amt
  source_field: premium_amt
  aggregation: sum
  description: "Total premium across all legs"
```

**Rule 2: Filtered Aggregation** (RMI-aware)
```yaml
- name: notional_lhs
  target_field: original_notional_amount
  source_field: counter_amt
  aggregation: sum
  filter: lhs_notional  # Only Sell-Put legs
  rmi_logic:
    LHS: lhs_notional
    RHS: rhs_notional
  description: "Auto-detect RMI and sum appropriate legs"
```

**Rule 3: Calculated Field**
```yaml
- name: ratio_calculation
  target_field: ratio
  calculated: true
  formula: |
    leverage = row.get('original_leverage_amount', 0)
    notional = row.get('original_notional_amount', 0)
    return leverage / notional if notional > 0 else None
  format: "1:{:.1f}"
  description: "Ratio of leverage to notional"
```

---

## Aggregation Types

### Direct Aggregations

**Sum**: Total across legs
```yaml
aggregation: sum
use_case: amounts, premiums
example: sum([100, 200, 100]) → 400
```

**Min**: Smallest value
```yaml
aggregation: min
use_case: lower barriers, floor strikes
example: min([1.08, 1.06, 1.10]) → 1.06
```

**Max**: Largest value
```yaml
aggregation: max
use_case: upper barriers, cap strikes
example: max([1.08, 1.10, 1.12]) → 1.12
```

**First**: First non-null value
```yaml
aggregation: first
use_case: identifiers, dates (when same across legs)
example: first([null, "EUR/USD", "EUR/USD"]) → "EUR/USD"
```

**Count**: Number of legs
```yaml
aggregation: count
use_case: leg_sequence field
example: count([leg1, leg2, leg3]) → 3
```

### Conditional Aggregations

**Min Non-Zero**:
```yaml
aggregation: min_nonzero
formula: |
  values = filter(lambda x: x > 0, source_values)
  return min(values) if values else None
```

**Weighted Average**:
```yaml
aggregation: weighted_avg
formula: |
  weights = [leg.counter_amt for leg in legs]
  values = [leg.rate for leg in legs]
  return sum(v*w for v,w in zip(values, weights)) / sum(weights)
```

---

## RMI-Aware Aggregation

### Leg Filtering

Define filter patterns:
```yaml
leg_filters:
  lhs_notional:
    conditions:
      buy_sell: Sell
      call_put: Put
  
  lhs_leverage:
    conditions:
      buy_sell: Buy
      call_put: Call
  
  rhs_notional:
    conditions:
      buy_sell: Sell
      call_put: Call
  
  rhs_leverage:
    conditions:
      buy_sell: Buy
      call_put: Put
```

### RMI Logic Mapping

```yaml
- target_field: original_notional_amount
  source_field: counter_amt
  aggregation: sum
  rmi_logic:
    LHS: lhs_notional  # Use Sell-Put filter for LHS
    RHS: rhs_notional  # Use Sell-Call filter for RHS
```

**Execution**:
```python
def aggregate_with_rmi(strategy, rule, rmi_type):
    filter_name = rule['rmi_logic'][rmi_type]
    filtered_legs = apply_filter(strategy.legs, filter_name)
    return aggregate(filtered_legs, rule['aggregation'])
```

---

## Calculated Fields

### Formula Execution

**Simple Calculation**:
```yaml
formula: "leverage / notional"

Executes as:
  result = row['leverage'] / row['notional']
```

**Complex Logic**:
```yaml
formula: |
  if row['barrier_1'] and float(row['barrier_1']) > 0:
      if row['window_start'] >= datetime(1990, 1, 1):
          return 'American'
      else:
          return 'Window'
  else:
      return 'European'
```

### Safe Execution

**Error Handling**:
```python
try:
    result = eval(formula, safe_context, row_dict)
except ZeroDivisionError:
    result = None
except Exception as e:
    log_error(f"Formula failed: {formula}, error: {e}")
    result = None
```

**Safe Context** (restricted functions):
```python
safe_context = {
    'float': float,
    'int': int,
    'str': str,
    'min': min,
    'max': max,
    'sum': sum,
    'abs': abs,
    # NO: os, sys, __import__, etc.
}
```

---

## Output Formatting

### Format Patterns

**Numbers**:
```yaml
format: "{:,.2f}"
input: 1234567.89
output: "1,234,567.89"
```

**Rates**:
```yaml
format: "{:.4f}"
input: 1.08125
output: "1.0813"
```

**Ratios**:
```yaml
format: "1:{:.1f}"
input: 2.5
output: "1:2.5"
```

**Dates**:
```yaml
format: "%Y-%m-%d"
input: datetime(2024, 6, 15)
output: "2024-06-15"
```

---

## Rule Execution Order

### Dependency Resolution

**Problem**: Some fields depend on others
```yaml
ratio:
  depends_on: [original_notional, original_leverage]

original_notional:
  depends_on: [counter_amt]  # From source data
```

**Solution**: Topological sort
```python
execution_order = [
    'original_notional',  # No dependencies
    'original_leverage',  # No dependencies
    'ratio',              # Depends on above
]
```

### Execution Phases

**Phase 1**: Direct aggregations (no dependencies)
```
- original_notional_amount
- original_leverage_amount
- strike_rate
- premium_amt
```

**Phase 2**: Calculated fields (depend on Phase 1)
```
- ratio (needs notional + leverage)
- barrier_type (needs barrier fields + dates)
```

---

## Validation & Quality Checks

### Post-Aggregation Validation

**Check 1**: Required fields populated
```python
required_fields = ['original_notional_amount', 'strike_rate', 'expiry_date']

for field in required_fields:
    if result[field] is None:
        Flag: missing_required_field
```

**Check 2**: Numeric ranges
```python
IF result['ratio'] < 0:
    Flag: invalid_ratio

IF result['strike_rate'] < 0.1 or result['strike_rate'] > 100:
    Flag: suspicious_strike_rate
```

**Check 3**: Logical consistency
```python
IF result['original_leverage'] > result['original_notional'] * 10:
    Flag: extreme_leverage_ratio
```

---

## Configuration Patterns

### Product-Specific Overrides

```yaml
base_rules:
  - target_field: ratio
    formula: "leverage / notional"

product_overrides:
  - product_codes: [FWD, KOF, COL]  # Non-ratio products
    overrides:
      ratio: null  # Don't calculate ratio
      original_leverage: null
  
  - product_codes: [RF, KORF, DRFE]  # Ratio products
    overrides:
      ratio:
        formula: "leverage / notional"
        format: "1:{:.1f}"
```

### Dynamic Rule Selection

```python
def get_applicable_rules(strategy):
    rules = base_rules.copy()
    
    # Check product overrides
    product = strategy.fp_product_code
    for override in product_overrides:
        if product in override['product_codes']:
            rules.update(override['overrides'])
    
    return rules
```

---

## Performance Optimization

### Vectorized Aggregation

**Instead of row-by-row**:
```python
# Slow: O(N)
for _, row in df.iterrows():
    result = calculate(row)
```

**Use vectorized operations**:
```python
# Fast: O(1) with broadcasting
df['ratio'] = df['leverage'] / df['notional'].replace(0, np.nan)
```

### Caching Intermediate Results

```python
# Cache expensive calculations
if 'barrier_type' not in cache:
    cache['barrier_type'] = detect_barrier_type(df)

result['barrier_type'] = cache['barrier_type']
```

---

## Testing Strategy

### Unit Tests

**Test 1**: Simple aggregation
```python
legs = [
    {"counter_amt": 100},
    {"counter_amt": 200}
]

rule = {"aggregation": "sum"}

assert aggregate(legs, rule) == 300
```

**Test 2**: Filtered aggregation
```python
legs = [
    {"buy_sell": "Sell", "call_put": "Put", "amount": 100},
    {"buy_sell": "Buy", "call_put": "Call", "amount": 200}
]

filtered = apply_filter(legs, "lhs_notional")

assert len(filtered) == 1
assert filtered[0]["amount"] == 100
```

**Test 3**: Calculated field
```python
row = {
    "original_notional": 100,
    "original_leverage": 200
}

formula = "leverage / notional"

assert execute_formula(formula, row) == 2.0
```

### Integration Tests

**End-to-End**:
```python
input_strategy = {
    "legs": [
        {"buy_sell": "Sell", "call_put": "Put", "counter_amt": 100, "rate": 1.08},
        {"buy_sell": "Buy", "call_put": "Call", "counter_amt": 100, "rate": 1.10}
    ]
}

output = aggregate_strategy(input_strategy, all_rules)

assert output["original_notional_amount"] == 100
assert output["strike_rate"] == 1.08
assert output["upper_barrier_rate"] == 1.10
assert output["ratio"] is None  # Collar has no ratio
```

---

## Summary

**Technique**: Declarative rule-based aggregation framework  
**Benefits**:
- Business logic externalized (YAML)
- Easy to modify without code changes
- RMI-aware calculations
- Configurable per product

**Components**:
- Aggregation functions (sum, min, max, etc.)
- Leg filters (RMI-specific)
- Calculated fields (formulas)
- Output formatting

**Best For**: Multi-leg consolidation with varying business logic  
**Trade-off**: Rules need validation (no type checking)  
**When to Use**: Business logic changes frequently or varies by product type
