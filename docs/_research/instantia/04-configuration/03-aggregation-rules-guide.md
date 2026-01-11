# Configuration Guide: Aggregation Rules

## Overview

The `aggregation_rules.yaml` file defines how multi-leg strategies are consolidated into single rows with calculated output fields. Rules use **RMI-aware filtering** to ensure correct calculations based on Importer (LHS) or Exporter (RHS) perspective.

**Location**: `configs/aggregation_rules.yaml`

---

## File Structure

```yaml
# Leg filter definitions
leg_filters:
  <filter_name>:
    conditions:
      <field>: <value>

# Aggregation rules
rules:
  - name: <rule_identifier>
    target_field: <output_field_name>
    source_field: <input_column>
    aggregation: <sum|min|max|first|count>
    rmi_logic:
      LHS: <filter_for_lhs>
      RHS: <filter_for_rhs>
```

---

## Leg Filters

Filters define which legs to include in aggregations based on their attributes.

### Example Filters
```yaml
leg_filters:
  # LHS (Importer) filters
  lhs_notional:
    conditions:
      buy_sell: Sell
      call_put: Put
  
  lhs_leverage:
    conditions:
      buy_sell: Buy
      call_put: Call
  
  # RHS (Exporter) filters
  rhs_notional:
    conditions:
      buy_sell: Sell
      call_put: Call
  
  rhs_leverage:
    conditions:
      buy_sell: Buy
      call_put: Put
```

### How Filters Work

**Filter Application**:
```python
# For strategy with RMI=LHS
filtered_legs = legs.filter(
    buy_sell == "Sell" AND call_put == "Put"
)

# Then aggregate
result = filtered_legs['counter_amt'].sum()
```

---

## Aggregation Rules

### Rule Components

| Field | Purpose | Example |
|-------|---------|---------|
| `name` | Rule identifier | `original_notional_lhs` |
| `target_field` | Output field name | `original_notional_amount` |
| `source_field` | Input column | `counter_amt` |
| `aggregation` | How to combine | `sum`, `first`, `max` |
| `rmi_logic` | RMI-specific filters | `{LHS: lhs_notional, RHS: rhs_notional}` |

### Aggregation Types

**sum**: Total across legs
```yaml
- name: total_premium
  target_field: premium_amt
  source_field: premium_amt
  aggregation: sum
```

**first**: First non-null value
```yaml
- name: expiry_date_first
  target_field: expiry_date
  source_field: expiry_date
  aggregation: first
```

**min**: Smallest value
```yaml
- name: lower_barrier
  target_field: lower_barrier_rate
  source_field: rate
  aggregation: min
  rmi_logic:
    RHS: rhs_leverage  # Buy-Put legs for RHS
```

**max**: Largest value
```yaml
- name: upper_barrier_lhs
  target_field: upper_barrier_rate
  source_field: rate
  aggregation: max
  rmi_logic:
    LHS: lhs_leverage  # Buy-Call legs for LHS
```

**count**: Number of legs
```yaml
- name: leg_sequence
  target_field: leg_sequence
  aggregation: count
```

---

## RMI-Aware Aggregation

The key innovation: **same rule, different filters based on RMI type**.

### Example: Notional Amount

**Single Rule**:
```yaml
- name: original_notional_amount
  target_field: original_notional_amount
  source_field: counter_amt
  aggregation: sum
  rmi_logic:
    LHS: lhs_notional  # Use Sell-Put filter
    RHS: rhs_notional  # Use Sell-Call filter
```

**Execution**:
```python
# Step 1: Detect RMI
rmi_type = detect_rmi(strategy)  # → "LHS"

# Step 2: Select filter
filter_name = rule['rmi_logic'][rmi_type]  # → "lhs_notional"

# Step 3: Apply filter
filtered = apply_filter(legs, filter_name)
# → Only Sell-Put legs

# Step 4: Aggregate
result = filtered['counter_amt'].sum()
# → Sum of Sell-Put amounts
```

### Why This Matters

**Wrong RMI → Wrong Result**:
```
LHS Strategy: [Sell Put $100K, Buy Call $100K]

If aggregated as RHS:
  notional = sum(Sell-Call amounts) = $0 ❌ (no Sell-Call!)

If aggregated as LHS:
  notional = sum(Sell-Put amounts) = $100K ✅
```

---

## Complete Rule Examples

### Rule 1: Strike Rate (RMI-Aware)
```yaml
- name: strike_rate
  target_field: strike_rate
  source_field: rate
  aggregation: first
  rmi_logic:
    LHS: lhs_notional  # From Sell-Put
    RHS: rhs_notional  # From Sell-Call
  description: "Primary obligation strike"
```

### Rule 2: Leverage Amount (RMI-Aware)
```yaml
- name: original_leverage_amount
  target_field: original_leverage_amount
  source_field: counter_amt
  aggregation: sum
  rmi_logic:
    LHS: lhs_leverage  # From Buy-Call
    RHS: rhs_leverage  # From Buy-Put
  description: "Leveraged upside/downside amount"
```

### Rule 3: Currency Pair (Non-RMI)
```yaml
-name: currency_pair
  target_field: currency_pair
  source_fields: [normalized_pair, currency_pair, terms]
  aggregation: first
  description: "Currency pair (e.g., EURUSD)"
```

---

## Calculated Fields

Some fields are computed from other fields rather than aggregated from source data.

```yaml
- name: ratio
  target_field: ratio
  description: "Leverage to Notional ratio"
  calculated: true
```

**Execution**:
```python
# After all aggregated fields computed
leverage = row['original_leverage_amount']
notional = row['original_notional_amount']

if notional > 0:
    ratio = leverage / notional
    formatted = f"1:{ratio:.1f}"
else:
    formatted = None
```

---

## Format Rules

Define output formatting for specific data types.

```yaml
format_rules:
  - type: number
    fields: [original_notional_amount, premium_amt]
    format: "{:,.2f}"  # 1,234,567.89
  
  - type: rate
    fields: [strike_rate, upper_barrier_rate]
    format: "{:.4f}"  # 1.0850
  
  - type: date
    fields: [expiry_date, trade_date]
    format: "%Y-%m-%d"  # 2024-06-15
  
  - type: ratio
    fields: [ratio]
    format: "1:{:.1f}"  # 1:2.5
```

---

## Adding a New Rule

### Step 1: Identify Need
```
Requirement: Calculate average strike across all legs

Current: Only first strike captured
Desired: Average of all strikes weighted by amounts
```

### Step 2: Define Rule
```yaml
- name: weighted_avg_strike
  target_field: weighted_avg_strike
  source_field: rate
  aggregation: weighted_avg
  weights_field: counter_amt
  description: "Amount-weighted average strike"
```

### Step 3: Implement Custom Aggregation (if needed)
```python
# In aggregation engine
def weighted_avg(values, weights):
    return sum(v * w for v, w in zip(values, weights)) / sum(weights)
```

### Step 4: Test
```
Input:
  Leg 1: rate=1.08, amount=100K
  Leg 2: rate=1.10, amount=200K

Expected:
  weighted_avg = (1.08*100K + 1.10*200K) / 300K = 1.0933
```

---

## Product-Specific Overrides

Some products need special handling.

```yaml
strategy_overrides:
  # Non-ratio products: Don't calculate ratio
  - product_codes: [FWD, KOF, COL]
    overrides:
      ratio: null
      original_leverage_amount: null
  
  # Ratio products: Calculate ratio
  - product_codes: [RF, KORF, DRFE]
    overrides:
      ratio:
        formula: "leverage / notional"
        format: "1:{:.1f}"
```

---

## Best Practices

### 1. Always Define RMI Logic for Amounts/Rates
```yaml
✅ GOOD:
  - name: original_notional
    rmi_logic:
      LHS: lhs_notional
      RHS: rhs_notional

❌ BAD:
  - name: original_notional
    # No rmi_logic → Same filter for LHS and RHS!
```

### 2. Use Descriptive Rule Names
```yaml
✅ GOOD:
  - name: strike_rate_from_primary_leg
  - name: upper_barrier_from_calls

❌ BAD:
  - name: rule1
  - name: field_agg
```

### 3. Document Financial Logic
```yaml
- name: original_notional_amount
  description: >
    Sum of primary obligation amounts.
    LHS: Sell-Put legs (floor protection)
    RHS: Sell-Call legs (cap protection)
```

---

## Validation

### Post-Aggregation Checks
```yaml
validation_rules:
  - field: original_notional_amount
    check: not_null
    error: "Notional missing"
  
  - field: strike_rate
    check: "value > 0 and value < 100"
    error: "Suspicious strike rate"
  
  - field: ratio
    check: "value is null OR value > 0"
    error: "Invalid ratio"
```

---

## Summary

**Purpose**: Define multi-leg consolidation logic  
**Key Feature**: RMI-aware filtering for correct perspective  
**Format**: YAML with leg filters and aggregation rules  
**Usage**: Calculate stage (Stage 5)  

**Critical Insight**: One rule per field, RMI logic selects appropriate filter  
**Best Practice**: Always test with both LHS and RHS examples  
**Extensibility**: Add new rules without code changes
